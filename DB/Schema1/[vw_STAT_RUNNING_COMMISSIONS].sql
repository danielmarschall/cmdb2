CREATE OR ALTER VIEW [dbo].[vw_STAT_RUNNING_COMMISSIONS] AS
select man.ID as __MANDATOR_ID, case
	when cm.ART_STATUS = 'c aw ack' then 1
	when cm.ART_STATUS = 'ack' then 2
	when cm.ART_STATUS = 'c aw sk' then 3
	when cm.ART_STATUS = 'c td feedback' then 4
	when cm.ART_STATUS = 'c aw cont' then 5
	when cm.ART_STATUS = 'c aw hires' then 6
	else 7
end as __STATUS_ORDER, cm.ART_STATUS, art.NAME as ARTIST, cm.NAME,
	CASE 
		WHEN CHARINDEX('\', cm.FOLDER) > 0 THEN RIGHT(cm.FOLDER, CHARINDEX('\', REVERSE(cm.FOLDER)) - 1)
		ELSE cm.FOLDER
	END AS FOLDER
from vw_COMMISSION cm
left join ARTIST art on art.ID = cm.ARTIST_ID
left join MANDATOR man on man.ID = art.MANDATOR_ID
where not (cm.ART_STATUS = 'fin' or cm.ART_STATUS = 'idea' or cm.ART_STATUS = 'postponed' or cm.ART_STATUS like 'cancel %' or cm.ART_STATUS = 'c td initcm' or cm.ART_STATUS = 'rejected')
