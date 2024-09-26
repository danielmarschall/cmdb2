CREATE OR ALTER VIEW [dbo].[vw_STAT_TOP_ARTISTS] AS
select 
	man.ID as __MANDATOR_ID, art.NAME as ARTISTNAME,
	count(distinct cm.ID) as COUNT_COMMISSIONS,
	SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0))) as AMOUNT_LOCAL,
	SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0)))/count(distinct cm.ID) as MEAN_SINGLE
from vw_COMMISSION cm
left join COMMISSION_EVENT ev on ev.COMMISSION_ID = cm.ID
left join QUOTE q on q.EVENT_ID = ev.ID and ev.STATE = 'quote'
left join ARTIST art on art.ID = cm.ARTIST_ID
left join MANDATOR man on man.ID = art.MANDATOR_ID
where not (cm.ART_STATUS = 'idea' or cm.ART_STATUS = 'postponed' or cm.ART_STATUS like 'cancel %' or cm.ART_STATUS = 'c td initcm' or cm.ART_STATUS = 'rejected')
group by man.ID, art.ID, art.NAME
