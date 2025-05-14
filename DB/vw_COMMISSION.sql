CREATE OR ALTER   view [dbo].[vw_COMMISSION] as

WITH UploadStuff AS (
	select
		cm.ID as COMMISSION_ID,
		SUM(iif(upl.ID is not null and ev.STATE='upload a',1,0)) as COUNT_A,
		SUM(iif(upl.ID is not null and ev.STATE='upload c',1,0)) as COUNT_C,
		SUM(iif(upl.PROHIBIT=1 and ev.STATE='upload a',1,0)) as PROHIBIT_A,
		SUM(iif(upl.PROHIBIT=1 and ev.STATE='upload c',1,0)) as PROHIBIT_C
	from COMMISSION cm
	left join COMMISSION_EVENT ev on ev.COMMISSION_ID = cm.ID
	left join UPLOAD upl on upl.EVENT_ID = ev.ID
	group by cm.ID
),
PaymentSums AS (
	select
		art.ID as ARTIST_ID,
		p.CURRENCY,
		SUM(p.AMOUNT) AS TotalPayment
	from PAYMENT p
	left join ARTIST art ON art.ID = p.ARTIST_ID
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
		q.EVENT_ID,
		q.CURRENCY,
		art.ID as ARTIST_ID,
		q.IS_FREE,
		q.AMOUNT,
		q.AMOUNT_LOCAL,
		SUM(iif(isnull(q.IS_FREE,0)=0,q.AMOUNT,0))
		OVER (PARTITION BY art.ID, q.CURRENCY ORDER BY
			ev.DATE, q.EVENT_ID
		) AS RunningQuoteSum
	from QuoteEvents q
	left join COMMISSION_EVENT ev ON ev.ID = q.EVENT_ID
	left join COMMISSION cm ON cm.ID = ev.COMMISSION_ID
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
			when qs.RunningQuoteSum - ISNULL(ps.TotalPayment, 0) >= qs.AMOUNT then qs.AMOUNT -- Not paid
			when qs.RunningQuoteSum - ISNULL(ps.TotalPayment, 0) <  0.01 then 0.00 -- Paid
			else qs.RunningQuoteSum - ISNULL(ps.TotalPayment, 0) -- Partial paid
		end as NotPaid
	from QuoteSums qs
	left join PaymentSums ps ON qs.ARTIST_ID = ps.ARTIST_ID and qs.CURRENCY = ps.CURRENCY
	left join COMMISSION_EVENT ev on ev.ID = qs.EVENT_ID
	left join COMMISSION cm on cm.ID = ev.COMMISSION_ID
),
QuotePayStatus as (
	select
		cm.ID as COMMISSION_ID,
		sum(qps.Amount) as AMOUNT,
		qps.CURRENCY,
		--sum(qps.NotPaid) as NOT_PAID_SUM,
		sum(qps.AmountLocal) as AMOUNT_LOCAL,
		case
			when sum(qps.Amount) < 0.01 then
				format(sum(qps.Amount), 'N2') + N' ' + qps.CURRENCY
			when sum(qps.NotPaid) >= 0.01 and sum(qps.NotPaid) >= sum(qps.Amount) then
				N'!!!!!! NOT PAID ' + format(sum(qps.Amount), 'N2') + N' ' + cast(qps.CURRENCY as varchar(100))
			when sum(qps.NotPaid) < 0.01 then
				N'Paid ' + format(sum(qps.Amount), 'N2') + N' ' + qps.CURRENCY
			else
				N'!!!!!! PART. PAID ' + format(sum(qps.Amount)-sum(qps.NotPaid), 'N2') + N' ' + qps.CURRENCY + N' of ' + format(sum(qps.Amount), 'N2') + N' ' + qps.CURRENCY + N' (Missing: ' + format(sum(qps.NotPaid), 'N2') + N' ' + qps.CURRENCY + N')'
		end as PAY_STATUS,
		case
			when sum(qps.NotPaid) >= sum(qps.Amount) then
				1 -- Not paid
			when sum(qps.NotPaid) < 0.01 then
				3 -- Paid
			else
				2 -- Partially paid
		end as PAY_STATUS_ORDER
	from COMMISSION cm
	left join ARTIST art on art.ID = cm.ARTIST_ID
	left join QuoteNotPaid qps on qps.ARTIST_ID = art.ID and qps.COMMISSION_ID = cm.ID
	where isnull(qps.IS_FREE,0) = 0
	group by art.ID, cm.ID, qps.CURRENCY, isnull(qps.IS_FREE,0)

	union

	select
		cm.ID as COMMISSION_ID,
		sum(qps.Amount) as AMOUNT,
		qps.CURRENCY,
		--sum(qps.NotPaid) as NOT_PAID_SUM,
		sum(qps.AmountLocal) as AMOUNT_LOCAL,
		cast(N'Free ' + format(sum(qps.Amount), 'N2') + N' ' + qps.CURRENCY as varchar(100)) as PAY_STATUS,
		4 as PAY_STATUS_ORDER
	from COMMISSION cm
	left join ARTIST art on art.ID = cm.ARTIST_ID
	left join QuoteNotPaid qps on qps.ARTIST_ID = art.ID and qps.COMMISSION_ID = cm.ID
	where ISNULL(qps.IS_FREE,0) = 1
	group by art.ID, cm.ID, qps.CURRENCY, isnull(qps.IS_FREE,0)
),
QuotePayStatusAggr as (
	select
		QuotePayStatus.COMMISSION_ID,
		STRING_AGG(QuotePayStatus.PAY_STATUS, ' + ') within group (order by QuotePayStatus.PAY_STATUS_ORDER, QuotePayStatus.AMOUNT desc, QuotePayStatus.CURRENCY) as PAY_STATUS,
		sum(QuotePayStatus.AMOUNT_LOCAL) as AMOUNT_LOCAL
	from QuotePayStatus
	group by QuotePayStatus.COMMISSION_ID
)

select

art.MANDATOR_ID,

art.IS_ARTIST as IS_ARTIST,

art.NAME as ARTIST_NAME,

cm.*,

cm.NAME + iif(art.IS_ARTIST=1,' by ',' for ') + art.NAME as PROJECT_NAME,

(
	select min(DATE) from COMMISSION_EVENT ev where ev.COMMISSION_ID = cm.ID and ev.STATE <> 'quote' and ev.STATE <> 'annot' and ev.STATE not like 'upload %' and ev.STATE <> 'idea' and ev.STATE <> 'c td initcm'
) as START_DATE,

(
	select max(DATE) from COMMISSION_EVENT ev where ev.COMMISSION_ID = cm.ID and ev.STATE = 'fin'
) as END_DATE,

(
	select top 1 STATE from COMMISSION_EVENT ev where ev.COMMISSION_ID = cm.ID and ev.STATE <> 'quote' and ev.STATE <> 'annot' and ev.STATE not like 'upload %'
	order by case when ev.STATE = 'fin' then 1
	              when ev.STATE like 'cancel %' then 2
	              else 3 end,
	         ev.DATE desc,
	         case
	              when ev.STATE = 'c aw hires' then 1
	              when ev.STATE = 'c aw cont' then 2
	              when ev.STATE = 'c td feedback' then 3
	              when ev.STATE = 'c aw sk' then 4
	              when ev.STATE = 'rejected' then 5 -- note that a rejected art can become non-rejected in the future
	              when ev.STATE = 'c aw ack' then 6
	              when ev.STATE = 'c td initcm' then 7
	              when ev.STATE = 'idea' then 8
	              else 9
	              end
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
