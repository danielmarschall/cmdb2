CREATE OR ALTER view [dbo].[vw_COMMISSION] as

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
QuoteSums AS (
	select
		q.ID AS QUOTE_ID,
		q.CURRENCY,
		art.ID as ARTIST_ID,
		SUM(CASE 
			WHEN isnull(q.IS_FREE,0) = 0 THEN q.AMOUNT 
			ELSE 0 
		END) OVER (PARTITION BY art.ID, q.CURRENCY ORDER BY
			iif (q.DESCRIPTION like 'nicht bez%' or q.DESCRIPTION like 'not paid%', 1, 0), -- Individual for DMX/SD
			ev.DATE, q.ID
		) AS RunningQuoteSum
	from QUOTE q
	left join COMMISSION_EVENT ev ON ev.ID = q.EVENT_ID
	left join COMMISSION cm ON cm.ID = ev.COMMISSION_ID
	left join ARTIST art ON art.ID = cm.ARTIST_ID
),
QuoteNotPaid as (
	select 
		--q.ID as QUOTE_ID,
		qs.ARTIST_ID,
		cm.ID as COMMISSION_ID,
		q.IS_FREE,
		q.AMOUNT as Amount,
		qs.CURRENCY,
		q.AMOUNT_LOCAL as AmountLocal,
		case
			when qs.RunningQuoteSum - ISNULL(ps.TotalPayment, 0) >= q.AMOUNT then q.AMOUNT -- Not paid
			when qs.RunningQuoteSum - ISNULL(ps.TotalPayment, 0) <  0.00001 then 0.00 -- Paid
			else qs.RunningQuoteSum - ISNULL(ps.TotalPayment, 0) -- Partial paid
		end as NotPaid
	from QuoteSums qs
	left join PaymentSums ps ON qs.ARTIST_ID = ps.ARTIST_ID and qs.CURRENCY = ps.CURRENCY
	left join QUOTE q on q.ID = qs.QUOTE_ID
	left join COMMISSION_EVENT ev on ev.ID = q.EVENT_ID
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
			when sum(qps.NotPaid) >= sum(qps.Amount) then
				N'!!!!!! NOT PAID ' + format(sum(qps.Amount), 'N2') + N' ' + cast(qps.CURRENCY as varchar(100))
			when sum(qps.NotPaid) < 0.00001 then
				N'Paid ' + format(sum(qps.Amount), 'N2') + N' ' + qps.CURRENCY
			else
				N'!!!!!! PART. PAID ' + format(sum(qps.Amount)-sum(qps.NotPaid), 'N2') + N' ' + qps.CURRENCY + N' of ' + format(sum(qps.Amount), 'N2') + N' ' + qps.CURRENCY + N' (Missing: ' + format(sum(qps.NotPaid), 'N2') + N' ' + qps.CURRENCY + N')'
		end as PAY_STATUS,
		case
			when sum(qps.NotPaid) >= sum(qps.Amount) then
				1 -- Not paid
			when sum(qps.NotPaid) < 0.00001 then
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
		STRING_AGG(QuotePayStatus.PAY_STATUS, ' /// ') within group (order by QuotePayStatus.PAY_STATUS_ORDER, QuotePayStatus.AMOUNT desc, QuotePayStatus.CURRENCY) as PAY_STATUS,
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
	order by case when ev.STATE='fin' then 1
	              when ev.STATE like 'cancel %' then 2
	              when ev.STATE like 'c aw hires' then 3
	              when ev.STATE like 'c aw cont' then 4
	              when ev.STATE like 'c td feedback' then 5
	              when ev.STATE like 'c aw sk' then 6
	              when ev.STATE like 'c aw ack' then 7
	              when ev.STATE like 'c td initcm' then 8
	              when ev.STATE like 'idea' then 9
	              else 10 end, ev.DATE desc
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
