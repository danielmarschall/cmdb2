create or alter view [dbo].[vw_COMMISSION] as

WITH UploadStuff AS (
	select
		cm.ID as COMMISSION_ID,
		SUM(iif(upl.ID is not null and cev.STATE='upload a',1,0)) as COUNT_A,
		SUM(iif(upl.ID is not null and cev.STATE='upload c',1,0)) as COUNT_C,
		SUM(iif(upl.PROHIBIT=1 and cev.STATE='upload a',1,0)) as PROHIBIT_A,
		SUM(iif(upl.PROHIBIT=1 and cev.STATE='upload c',1,0)) as PROHIBIT_C
	from COMMISSION cm
	left join COMMISSION_EVENT cev on cev.COMMISSION_ID = cm.ID
	left join UPLOAD upl on upl.EVENT_ID = cev.ID
	group by cm.ID
),
PaymentSums AS (
	select
		art.ID as ARTIST_ID,
		p.CURRENCY,
		SUM(p.AMOUNT) AS TotalPayment
	from PAYMENT p
	left join ARTIST art ON art.ID = p.ARTIST_ID
	where p.AMOUNT >= 0
	group by art.ID, p.CURRENCY
),
RefundSums AS (
	select
		art.ID as ARTIST_ID,
		p.CURRENCY,
		SUM(-p.AMOUNT) AS TotalRefund
	from PAYMENT p
	left join ARTIST art ON art.ID = p.ARTIST_ID
	where p.AMOUNT < 0
	group by art.ID, p.CURRENCY
),
QuoteEvents AS (
	select
		q.EVENT_ID,
		SUM(q.AMOUNT) as AMOUNT,
		q.CURRENCY,
		SUM(q.AMOUNT_LOCAL) as AMOUNT_LOCAL,
		q.IS_FREE
	from QUOTE q
	group by q.EVENT_ID, q.CURRENCY, q.IS_FREE
),
QuoteSums AS (
	select
		qev.EVENT_ID,
		qev.CURRENCY,
		art.ID as ARTIST_ID,
		qev.IS_FREE,
		qev.AMOUNT,
		qev.AMOUNT_LOCAL,
		SUM (
			iif(isnull(qev.IS_FREE,0)=0 and qev.AMOUNT>=0,qev.AMOUNT,0)
		) OVER (
			PARTITION BY art.ID, qev.CURRENCY
			ORDER BY cev.DATE, qev.EVENT_ID
			ROWS UNBOUNDED PRECEDING
		) AS RunningQuoteSum_Positive,
		SUM (
			iif(isnull(qev.IS_FREE,0)=0 and qev.AMOUNT<0,-qev.AMOUNT,0)
		) OVER (
			PARTITION BY art.ID, qev.CURRENCY
			ORDER BY cev.DATE, qev.EVENT_ID
			ROWS UNBOUNDED PRECEDING
		) AS RunningQuoteSum_Negative
	from QuoteEvents qev
	left join COMMISSION_EVENT cev ON cev.ID = qev.EVENT_ID
	left join COMMISSION cm ON cm.ID = cev.COMMISSION_ID
	left join ARTIST art ON art.ID = cm.ARTIST_ID
),
QuoteNotPaid as (
	select 
		qs.ARTIST_ID,
		cm.ID as COMMISSION_ID,
		qs.IS_FREE,
		qs.AMOUNT as Amount,
		qs.CURRENCY,
		qs.AMOUNT_LOCAL as AmountLocal,
		case
			when qs.AMOUNT >= 0 and    qs.RunningQuoteSum_Positive - ISNULL(ps.TotalPayment, 0) >= qs.AMOUNT then qs.AMOUNT -- Not paid
			when qs.AMOUNT >= 0 and    qs.RunningQuoteSum_Positive - ISNULL(ps.TotalPayment, 0) < 0.01 then 0.00 -- Paid
			when qs.AMOUNT >= 0 then   qs.RunningQuoteSum_Positive - ISNULL(ps.TotalPayment, 0) -- Partial paid
			when qs.AMOUNT <  0 and    qs.RunningQuoteSum_Negative - ISNULL(rs.TotalRefund, 0) >= -qs.AMOUNT then qs.AMOUNT -- Not refunded
			when qs.AMOUNT <  0 and    qs.RunningQuoteSum_Negative - ISNULL(rs.TotalRefund, 0) > -0.01 then 0.00 -- Refunded
			when qs.AMOUNT <  0 then -(qs.RunningQuoteSum_Negative - ISNULL(rs.TotalRefund, 0)) -- Partial refunded
		end as NotPaid
	from QuoteSums qs
	left join PaymentSums ps ON ps.ARTIST_ID = qs.ARTIST_ID and ps.CURRENCY = qs.CURRENCY
	left join RefundSums  rs ON rs.ARTIST_ID = qs.ARTIST_ID and rs.CURRENCY = qs.CURRENCY
	left join COMMISSION_EVENT cev on cev.ID = qs.EVENT_ID
	left join COMMISSION cm on cm.ID = cev.COMMISSION_ID
),
QuotePayStatus as (
	select
		cm.ID as COMMISSION_ID,
		sum(qnp.Amount) as AMOUNT,
		qnp.CURRENCY,
		sum(qnp.AmountLocal) as AMOUNT_LOCAL,
		case
			when sum(qnp.Amount) < 0.01 then -- no abs() here, because -10 should not show as "paid" (also, that should not happen because you cannot refund more than you paid)
				format(sum(qnp.Amount), 'N2') + N' ' + qnp.CURRENCY
			when abs(sum(qnp.NotPaid)) >= 0.01 and sum(qnp.NotPaid) >= sum(qnp.Amount) then
				N'!!!!!! NOT PAID ' + format(sum(qnp.Amount), 'N2') + N' ' + cast(qnp.CURRENCY as varchar(100))
			when abs(sum(qnp.NotPaid)) < 0.01 then
				N'Paid ' + format(sum(qnp.Amount), 'N2') + N' ' + qnp.CURRENCY
			else
				N'!!!!!! PART. PAID ' + format(sum(qnp.Amount)-sum(qnp.NotPaid), 'N2') + N' ' + qnp.CURRENCY + N' of ' + format(sum(qnp.Amount), 'N2') + N' ' + qnp.CURRENCY + N' (Missing: ' + format(sum(qnp.NotPaid), 'N2') + N' ' + qnp.CURRENCY + N')'
		end as PAY_STATUS,
		case
			when sum(qnp.NotPaid) >= sum(qnp.Amount) then
				1 -- Not paid
			when abs(sum(qnp.NotPaid)) < 0.01 then
				3 -- Paid
			else
				2 -- Partially paid
		end as PAY_STATUS_ORDER
	from COMMISSION cm
	left join ARTIST art on art.ID = cm.ARTIST_ID
	left join QuoteNotPaid qnp on qnp.ARTIST_ID = art.ID and qnp.COMMISSION_ID = cm.ID
	where isnull(qnp.IS_FREE,0) = 0
	group by art.ID, cm.ID, qnp.CURRENCY, isnull(qnp.IS_FREE,0)

	union

	select
		cm.ID as COMMISSION_ID,
		sum(qnp.Amount) as AMOUNT,
		qnp.CURRENCY,
		sum(qnp.AmountLocal) as AMOUNT_LOCAL,
		cast(N'Free ' + format(sum(qnp.Amount), 'N2') + N' ' + qnp.CURRENCY as varchar(100)) as PAY_STATUS,
		4 as PAY_STATUS_ORDER
	from COMMISSION cm
	left join ARTIST art on art.ID = cm.ARTIST_ID
	left join QuoteNotPaid qnp on qnp.ARTIST_ID = art.ID and qnp.COMMISSION_ID = cm.ID
	where ISNULL(qnp.IS_FREE,0) = 1
	group by art.ID, cm.ID, qnp.CURRENCY, isnull(qnp.IS_FREE,0)
),
QuotePayStatusAggr as (
	select
		qps.COMMISSION_ID,
		STRING_AGG(qps.PAY_STATUS, ' + ') within group (order by qps.PAY_STATUS_ORDER, qps.AMOUNT desc, qps.CURRENCY) as PAY_STATUS,
		sum(qps.AMOUNT_LOCAL) as AMOUNT_LOCAL
	from QuotePayStatus qps
	group by qps.COMMISSION_ID
)

select

art.MANDATOR_ID,

art.IS_ARTIST as IS_ARTIST,

art.NAME as ARTIST_NAME,

cm.*,

cm.NAME + iif(art.IS_ARTIST=1,' by ',' for ') + art.NAME as PROJECT_NAME,

(
	select min(DATE) from COMMISSION_EVENT cev where cev.COMMISSION_ID = cm.ID and cev.STATE <> 'quote' and cev.STATE <> 'annot' and cev.STATE not like 'upload %' and cev.STATE <> 'idea' and cev.STATE <> 'c td initcm'
) as START_DATE,

(
	select max(DATE) from COMMISSION_EVENT cev where cev.COMMISSION_ID = cm.ID and cev.STATE = 'fin'
) as END_DATE,

(
	select top 1 STATE from COMMISSION_EVENT cev where cev.COMMISSION_ID = cm.ID and cev.STATE <> 'quote' and cev.STATE <> 'annot' and cev.STATE not like 'upload %'
	order by case when cev.STATE = 'fin'           then 1
	              when cev.STATE like 'cancel %'   then 2
	                                               else 3 end,
	         cev.DATE desc,
	         case
	              when cev.STATE = 'c aw hires'    then 1
	              when cev.STATE = 'c aw cont'     then 2
	              when cev.STATE = 'c td feedback' then 3
	              when cev.STATE = 'c aw sk'       then 4
	              when cev.STATE = 'rejected'      then 5 -- note that a rejected art can become non-rejected in the future
	              when cev.STATE = 'c aw ack'      then 6
	              when cev.STATE = 'c td initcm'   then 7
	              when cev.STATE = 'idea'          then 8
	                                               else 9 end
) as ART_STATUS,

QuotePayStatusAggr.PAY_STATUS,

QuotePayStatusAggr.AMOUNT_LOCAL as AMOUNT_LOCAL,

cast((
	select case when upl.COUNT_A=0 then N'No' when upl.PROHIBIT_A>0 then N'Prohibit' else N'Yes' end from UploadStuff upl where upl.COMMISSION_ID = cm.ID
) as nvarchar(8)) as UPLOAD_A,

cast((
	select case when upl.COUNT_C=0 then N'No' when upl.PROHIBIT_C>0 then N'Prohibit' else N'Yes' end from UploadStuff upl where upl.COMMISSION_ID = cm.ID
) as nvarchar(8)) as UPLOAD_C

from COMMISSION cm
left join ARTIST art on art.ID = cm.ARTIST_ID
left join QuotePayStatusAggr on QuotePayStatusAggr.COMMISSION_ID = cm.ID
