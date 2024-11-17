CREATE or ALTER view [dbo].[vw_ARTIST] as

WITH FilteredUploads AS (
	SELECT
		art.ID AS ARTIST_ID,
		art.NAME AS ARTIST_NAME,
		ev.ID AS EVENT_ID,
		ev.STATE,
		upl.PROHIBIT,
		ROW_NUMBER() OVER (PARTITION BY cm.ID, ev.STATE ORDER BY upl.ID) AS rn
	FROM 
		ARTIST art
	LEFT JOIN 
		COMMISSION cm ON cm.ARTIST_ID = art.ID
	LEFT JOIN 
		COMMISSION_EVENT ev ON ev.COMMISSION_ID = cm.ID
	LEFT JOIN 
		UPLOAD upl ON upl.EVENT_ID = ev.ID
),
UploadStuff as (
	SELECT 
		ARTIST_ID,
		SUM(CASE WHEN STATE = 'upload a' AND rn = 1 AND PROHIBIT = 0 THEN 1 ELSE 0 END) AS UPLOADS_A,
		SUM(CASE WHEN STATE = 'upload c' AND rn = 1 AND PROHIBIT = 0 THEN 1 ELSE 0 END) AS UPLOADS_C,
		SUM(CASE WHEN STATE = 'upload a' AND rn = 1 AND PROHIBIT = 1 THEN 1 ELSE 0 END) AS PROHIBIT_A,
		SUM(CASE WHEN STATE = 'upload c' AND rn = 1 AND PROHIBIT = 1 THEN 1 ELSE 0 END) AS PROHIBIT_C
	FROM 
		FilteredUploads
	GROUP BY 
		ARTIST_ID
),
CommSums as (

	SELECT art.ID as ARTIST_ID, COUNT(distinct cm.ID) as COUNT_COMM,
	--SUM(q.AMOUNT) as SUM_AMOUNT,
	SUM(q.AMOUNT_LOCAL) as SUM_AMOUNT_LOCAL
	from ARTIST art
	left join COMMISSION cm on cm.ARTIST_ID = art.ID
	left join COMMISSION_EVENT ev on ev.COMMISSION_ID = cm.ID and ev.STATE = 'quote'
	left join QUOTE q on q.EVENT_ID = ev.ID
	group by art.ID

),
tmp1_ARTIST_DEBT as (
	select art.ID as ARTIST_ID, art.NAME as ARTIST_NAME, q.CURRENCY, SUM(isnull(q.AMOUNT,0)) as QUOTE_SUM
	from ARTIST art
	left join COMMISSION cm on cm.ARTIST_ID = art.ID
	left join COMMISSION_EVENT ev on ev.COMMISSION_ID = cm.ID and ev.STATE = 'quote'
	left join QUOTE q on q.EVENT_ID = ev.ID
	where ISNULL(q.IS_FREE,0) = 0
	group by art.ID, art.NAME, q.CURRENCY

	union

	select art.ID as ARTIST_ID, art.NAME as ARTIST_NAME, p.CURRENCY, -SUM(isnull(p.AMOUNT,0)) as QUOTE_SUM
	from ARTIST art
	left join PAYMENT p on p.ARTIST_ID = art.ID
	group by art.ID, art.NAME, p.CURRENCY
),
tmp2_ARTIST_DEBT as (
	select ARTIST_ID, ARTIST_NAME, CURRENCY, SUM(QUOTE_SUM) as DEBT
	from tmp1_ARTIST_DEBT
	group by ARTIST_ID, ARTIST_NAME, CURRENCY
)
select art.*,

cast(isnull((
	select top 1
	case 
		when ev.STATE = 'deceased' then N'Deceased'
		when ev.STATE = 'end coop' then N'Cooperation ended'
		when ev.STATE = 'stopped' then N'Stopped service'
		when ev.STATE = 'inactive' then N'Inactive'
		when ev.STATE = 'hiatus' then N'Hiatus'
		else null
	end as STATUS
	from ARTIST_EVENT ev
	where ev.ARTIST_ID = art.ID
	order by
	case
		when ev.STATE = 'deceased' then 4
		when ev.STATE = 'end coop' then 3
		when ev.STATE = 'stopped' then 2
		when ev.STATE = 'inactive' then 1
		when ev.STATE = 'hiatus' then 1
		when ev.STATE = 'recovered' then 1
	end desc, ev.DATE desc
), N'Active') as nvarchar(50)) as STATUS,

upl.UPLOADS_A,
upl.UPLOADS_C,
upl.PROHIBIT_A,
upl.PROHIBIT_C,
cs.SUM_AMOUNT_LOCAL as AMOUNT_TOTAL_LOCAL,
cs.COUNT_COMM as COMMISSION_COUNT,

-- TODO: this is slow! (1sec)
(
select COUNT(distinct cm.ID)
from vw_COMMISSION cm
where cm.ARTIST_ID = art.ID
and not (cm.ART_STATUS = 'fin' or cm.ART_STATUS = 'idea' or cm.ART_STATUS like 'postponed%' or cm.ART_STATUS like 'on hold%' or cm.ART_STATUS like 'cancel %' or cm.ART_STATUS = 'c td initcm' or cm.ART_STATUS = 'rejected')
) as COMMISSION_RUNNING,

-- TODO: this is slow! (1sec)
(
	SELECT 
		isnull(STRING_AGG(
		CASE WHEN deb.DEBT > 0 THEN N'DEBT '+cast(deb.DEBT as nvarchar(20))+N' '+deb.CURRENCY
			 WHEN deb.DEBT < 0 THEN N'CREDIT '+cast(-deb.DEBT as nvarchar(20))+N' '+deb.CURRENCY
			 ELSE null
		END, N' /// '), N'OKAY')
	FROM
		tmp2_ARTIST_DEBT deb where deb.ARTIST_ID = art.ID
) as PAY_STATUS

from ARTIST art
left join UploadStuff upl on upl.ARTIST_ID = art.ID
left join CommSums cs on cs.ARTIST_ID = art.ID
