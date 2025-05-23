create or alter view [dbo].[vw_PAYMENT] as

select man.ID as MANDATOR_ID, art.IS_ARTIST, art.NAME as ARTIST_NAME, pay.*, cast(case
	when art.IS_ARTIST = 1 then art.NAME + N' (Artist)'
	when art.IS_ARTIST = 0 then art.NAME + N' (Client)'
end as nvarchar(100)) as ARTIST_OR_CLIENT_NAME
from PAYMENT pay
left join ARTIST art on art.ID = pay.ARTIST_ID
left join MANDATOR man on man.ID = art.MANDATOR_ID
