CREATE OR ALTER view [dbo].[vw_COMMISSION] as

WITH UploadStuff AS (
	select cm.ID as COMMISSION_ID,
	SUM(iif(upl.ID is not null and ev.STATE='upload a',1,0)) as COUNT_A,
	SUM(iif(upl.ID is not null and ev.STATE='upload c',1,0)) as COUNT_C,
	SUM(iif(upl.PROHIBIT=1 and ev.STATE='upload a',1,0)) as PROHIBIT_A,
	SUM(iif(upl.PROHIBIT=1 and ev.STATE='upload c',1,0)) as PROHIBIT_C
	from COMMISSION cm
	left join COMMISSION_EVENT ev on ev.COMMISSION_ID = cm.ID
	LEFT join UPLOAD upl on upl.EVENT_ID = ev.ID
	group by cm.ID
),
ZahlungenSummiert AS (
	SELECT 
		art.ID as ARTIST_ID, 
		pay.CURRENCY,
		SUM(ISNULL(pay.AMOUNT, 0)) AS GesamtsummeZahlungen
	FROM 
		ARTIST art
	LEFT JOIN PAYMENT pay ON pay.ARTIST_ID = art.ID
	GROUP BY art.ID, pay.CURRENCY
),
AggregierteQuotes AS (
	SELECT 
		cm.ID as COMMISSION_ID,
		art.NAME as ARTIST_NAME,
		cm.ARTIST_ID,
		cm.NAME as COMMISSION_NAME,
		MIN(ev.DATE) as QUOTE_DATE, -- Nimm das früheste Datum der Quote für die Sortierung
		q.CURRENCY,
		SUM(q.AMOUNT) as QUOTE_AMOUNT, -- Summe aller Quotes pro Commission und Währung
		SUM(q.AMOUNT_LOCAL) as QUOTE_AMOUNT_LOCAL
	FROM 
		COMMISSION cm
	LEFT JOIN COMMISSION_EVENT ev ON ev.COMMISSION_ID = cm.ID AND ev.STATE = 'quote'
	LEFT JOIN QUOTE q ON q.EVENT_ID = ev.ID
	LEFT JOIN ARTIST art on art.ID = cm.ARTIST_ID
	where isnull(q.IS_FREE,0) = 0 -- q.DESCRIPTION not like '%free%' and q.DESCRIPTION not like '%gift%'
	GROUP BY 
		cm.ID, cm.ARTIST_ID, art.NAME, cm.NAME, q.CURRENCY
),
LeistungenMitZahlungen AS (
	SELECT 
		aq.ARTIST_ID,
		aq.ARTIST_NAME,
		aq.COMMISSION_ID,
		aq.COMMISSION_NAME,
		aq.QUOTE_DATE,
		aq.QUOTE_AMOUNT,
		aq.QUOTE_AMOUNT_LOCAL,
		aq.CURRENCY,
		COALESCE(zs.GesamtsummeZahlungen, 0) AS GesamtsummeZahlungen
	FROM 
		AggregierteQuotes aq
	LEFT JOIN ZahlungenSummiert zs ON aq.ARTIST_ID = zs.ARTIST_ID AND aq.CURRENCY = zs.CURRENCY
),
KumulierteLeistungen AS (
	SELECT 
		ARTIST_ID,
		ARTIST_NAME,
		COMMISSION_ID,
		COMMISSION_NAME,
		QUOTE_DATE,
		QUOTE_AMOUNT,
		QUOTE_AMOUNT_LOCAL,
		CURRENCY,
		GesamtsummeZahlungen,
		SUM(QUOTE_AMOUNT) OVER (PARTITION BY ARTIST_ID, CURRENCY ORDER BY QUOTE_DATE) AS KumulierteLeistungen
	FROM 
		LeistungenMitZahlungen
),
VorherigeLeistungen AS (
	SELECT
		ARTIST_ID,
		ARTIST_NAME,
		COMMISSION_ID,
		COMMISSION_NAME,
		QUOTE_DATE,
		QUOTE_AMOUNT,
		QUOTE_AMOUNT_LOCAL,
		CURRENCY,
		GesamtsummeZahlungen,
		KumulierteLeistungen,
		LAG(KumulierteLeistungen, 1, 0) OVER (PARTITION BY ARTIST_ID, CURRENCY ORDER BY QUOTE_DATE) AS VorherigeKumulierteLeistungen
	FROM
		KumulierteLeistungen
),
DownPayment AS (
	SELECT 
		ARTIST_ID,
		COMMISSION_ID,
		--ARTIST_NAME,
		--COMMISSION_NAME,
		QUOTE_AMOUNT,
		QUOTE_AMOUNT_LOCAL,
		--QUOTE_DATE,
		CURRENCY,
		--GesamtsummeZahlungen,
		--KumulierteLeistungen,
		--VorherigeKumulierteLeistungen,
		CASE
			WHEN QUOTE_AMOUNT is null THEN null
			WHEN QUOTE_AMOUNT <  0 then N'' -- should not happen. you receive get a commission get paid for receiving it. (refunds will be made by removing/neutralizing the cost of the commission.)
			WHEN QUOTE_AMOUNT >= 0 and GesamtsummeZahlungen >= KumulierteLeistungen THEN N'Paid'
			WHEN QUOTE_AMOUNT >= 0 and GesamtsummeZahlungen > VorherigeKumulierteLeistungen THEN N'Partially Paid'
			WHEN QUOTE_AMOUNT >= 0 THEN N'Not Paid'
			ELSE N'Undef.'
		END AS PAY_STATUS
	FROM 
		VorherigeLeistungen
	--ORDER BY 
	--	ARTIST_ID, CURRENCY, QUOTE_DATE;

union

	select
		cm.ARTIST_ID,
		ev.COMMISSION_ID,
		SUM(q.AMOUNT) as QUOTE_AMOUNT,
		0 as QUOTE_AMOUNT_LOCAL,
		q.CURRENCY,
		N'FREE' as PAY_STATUS
		from QUOTE q
		left join COMMISSION_EVENT ev on ev.ID = q.EVENT_ID
		left join COMMISSION cm on cm.ID = ev.COMMISSION_ID
		where isnull(q.IS_FREE,0) = 1 -- (q.DESCRIPTION like '%gift%') or (q.DESCRIPTION like '%free%')
		group by cm.ARTIST_ID, ev.COMMISSION_ID, q.CURRENCY

),
AggregatedPaymentStatus AS (
	SELECT 
		dp.COMMISSION_ID,
		STRING_AGG(
			dp.PAY_STATUS+' '+cast(dp.QUOTE_AMOUNT as nvarchar(20))+' '+dp.CURRENCY
		, ' + ') AS PAY_STATUS,
		SUM(dp.QUOTE_AMOUNT_LOCAL) as QUOTE_AMOUNT_LOCAL
	FROM DownPayment dp
	GROUP BY dp.COMMISSION_ID
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
	              else 3 end, ev.DATE desc
) as ART_STATUS,

aps.PAY_STATUS,

aps.QUOTE_AMOUNT_LOCAL as AMOUNT_LOCAL,

cast((
	select case when upl.COUNT_A=0 then N'No' when upl.PROHIBIT_A>0 then N'Prohibit' else N'Yes' end from UploadStuff upl where upl.COMMISSION_ID = cm.ID
) as nvarchar(8)) as UPLOAD_A,

cast((
	select case when upl.COUNT_C=0 then N'No' when upl.PROHIBIT_C>0 then N'Prohibit' else N'Yes' end from UploadStuff upl where upl.COMMISSION_ID = cm.ID
) as nvarchar(8)) as UPLOAD_C

from COMMISSION cm
left join ARTIST art on art.ID = cm.ARTIST_ID
left join AggregatedPaymentStatus aps on aps.COMMISSION_ID = cm.ID
