CREATE OR ALTER VIEW [dbo].[vw_TEXT_BACKUP_GENERATE] AS

select
	man.ID as __MANDATOR_ID,
	man.NAME as __MANDATOR_NAME,
	ds.ID as DATASET_ID,
	iif(ds.IS_ARTIST=1,N'Artist',N'Client') as DATASET_TYPE,
	ds.NAME,
	'LegacyID '+isnull(cast(ds.LEGACY_ID as nvarchar(10)),'n/a') as MORE_DATA
from ARTIST ds
left join MANDATOR man on man.ID = ds.MANDATOR_ID

union

select
	man.ID as __MANDATOR_ID,
	man.NAME as __MANDATOR_NAME,
	ds.ID as DATASET_ID,
	iif(art.IS_ARTIST=1,N'ArtistEvent',N'ClientEvent') as DATASET_TYPE,
	art.NAME,
	ds.STATE+' '+isnull(ds.ANNOTATION,'')+'@'+CONVERT(VARCHAR(10), ds.DATE, 23)+' / LegacyID '+isnull(cast(ds.LEGACY_ID as nvarchar(10)),'n/a') as MORE_DATA
from ARTIST_EVENT ds
left join ARTIST art on art.ID = ds.ARTIST_ID
left join MANDATOR man on man.ID = art.MANDATOR_ID

union

select
	man.ID as __MANDATOR_ID,
	man.NAME as __MANDATOR_NAME,
	ds.ID as DATASET_ID,
	N'Commission' as DATASET_TYPE,
	ds.NAME + iif(art.IS_ARTIST=1,' by ',' for ') + art.NAME,
	'Folder: '+isnull(ds.FOLDER,'n/a')+' / LegacyID '+isnull(cast(ds.LEGACY_ID as nvarchar(10)),'n/a') as MORE_DATA
from COMMISSION ds
left join ARTIST art on art.ID = ds.ARTIST_ID
left join MANDATOR man on man.ID = art.MANDATOR_ID

union

select
	man.ID as __MANDATOR_ID,
	man.NAME as __MANDATOR_NAME,
	ds.ID as DATASET_ID,
	N'CommissionEvent' as DATASET_TYPE,
	cm.NAME + iif(art.IS_ARTIST=1,' by ',' for ') + art.NAME,
	ds.STATE+' '+isnull(ds.ANNOTATION,'')+'@'+CONVERT(VARCHAR(10), ds.DATE, 23) as MORE_DATA
from COMMISSION_EVENT ds
left join COMMISSION cm on cm.ID = ds.COMMISSION_ID
left join ARTIST art on art.ID = cm.ARTIST_ID
left join MANDATOR man on man.ID = art.MANDATOR_ID

union

select
	man.ID as __MANDATOR_ID,
	man.NAME as __MANDATOR_NAME,
	ds.ID as DATASET_ID,
	iif(art.IS_ARTIST=1,N'ArtistCommunication',N'ClientCommunication') as DATASET_TYPE,
	ds.CHANNEL + ' of ' + art.NAME,
	isnull(ds.ADDRESS,'') + ' / Annotation: ' + isnull(ds.ANNOTATION,'n/a') + ' / LegacyID '+isnull(cast(ds.LEGACY_ID as nvarchar(10)),'n/a') as MORE_DATA
from COMMUNICATION ds
left join ARTIST art on art.ID = ds.ARTIST_ID
left join MANDATOR man on man.ID = art.MANDATOR_ID

union

select
	null as __MANDATOR_ID,
	null as __MANDATOR_NAME,
	null as DATASET_ID,
	N'Config' as DATASET_TYPE,
	ds.NAME,
	ds.VALUE as MORE_DATA
from CONFIG ds

union 

select
	ds.ID as __MANDATOR_ID,
	ds.NAME as __MANDATOR_NAME,
	null as DATASET_ID,
	N'Mandator' as DATASET_TYPE,
	null,
	null as MORE_DATA
from MANDATOR ds

union

select
	man.ID as __MANDATOR_ID,
	man.NAME as __MANDATOR_NAME,
	ds.ID as DATASET_ID,
	iif(art.IS_ARTIST=1,N'ArtistPayment',N'ClientPayment') as DATASET_TYPE,
	art.NAME,
	'PayProv: ' + ISNULL(ds.PAYPROV,'n/a')+' / '+
	'Annotation: ' + ISNULL(ds.ANNOTATION,'n/a')+' / '+
	'AmountVerified: ' + iif(ISNULL(ds.AMOUNT_VERIFIED,0)=1,'Y','N')+' / '+
	'Amount: ' + ISNULL(cast(ds.AMOUNT as nvarchar(10)),'n/a')+' / '+
	'Currency: ' + ISNULL(ds.CURRENCY,'n/a')+' / '+
	'AmountLocal: ' + ISNULL(cast(ds.AMOUNT_LOCAL as nvarchar(10)),'n/a')+' / '+
	'@'+CONVERT(VARCHAR(10), ds.DATE, 23) as MORE_DATA
from PAYMENT ds
left join ARTIST art on art.ID = ds.ARTIST_ID
left join MANDATOR man on man.ID = art.MANDATOR_ID

union

select
	man.ID as __MANDATOR_ID,
	man.NAME as __MANDATOR_NAME,
	ds.ID as DATASET_ID,
	N'Quote' as DATASET_TYPE,
	cm.NAME + ' by ' + art.NAME,
	'No.: ' + ISNULL(cast(ds.NO as nvarchar(10)),'n/a')+' / '+
	'Amount: ' + ISNULL(cast(ds.AMOUNT as nvarchar(10)),'n/a')+' / '+
	'Currency: ' + ISNULL(ds.CURRENCY,'n/a')+' / '+
	'AmountLocal: ' + ISNULL(cast(ds.AMOUNT_LOCAL as nvarchar(10)),'n/a')+' / '+
	'Description: ' + ISNULL(ds.DESCRIPTION,'n/a')+' / '+
	'IsFree: ' + iif(ISNULL(ds.IS_FREE,0)=1,'Y','N')+' / '+
	'LegacyID '+isnull(cast(ds.LEGACY_ID as nvarchar(10)),'n/a')
	as MORE_DATA
from QUOTE ds
left join COMMISSION_EVENT ev on ev.ID = ds.EVENT_ID
left join COMMISSION cm on cm.ID = ev.COMMISSION_ID
left join ARTIST art on art.ID = cm.ARTIST_ID
left join MANDATOR man on man.ID = art.MANDATOR_ID

union

select
	man.ID as __MANDATOR_ID,
	man.NAME as __MANDATOR_NAME,
	ds.ID as DATASET_ID,
	N'Upload' as DATASET_TYPE,
	cm.NAME + ' by ' + art.NAME,
	'No.: ' + ISNULL(cast(ds.NO as nvarchar(10)),'n/a')+' / '+
	'Page: ' + ISNULL(ds.PAGE,'n/a')+' / '+
	'URL: ' + ISNULL(ds.URL,'n/a')+' / '+
	'Prohibit: ' + iif(ISNULL(ds.PROHIBIT,0)=1,'Y','N')+' / '+
	'Annotation: ' + ISNULL(ds.ANNOTATION,'n/a')+' / '+
	'LegacyID '+isnull(cast(ds.LEGACY_ID as nvarchar(10)),'n/a')
	as MORE_DATA
from UPLOAD ds
left join COMMISSION_EVENT ev on ev.ID = ds.EVENT_ID
left join COMMISSION cm on cm.ID = ev.COMMISSION_ID
left join ARTIST art on art.ID = cm.ARTIST_ID
left join MANDATOR man on man.ID = art.MANDATOR_ID

--union

-- Do not do that, otherwise the dump cannot be compared!
--select
--	null as __MANDATOR_ID,
--	null as __MANDATOR_NAME,
--	null as DATASET_ID,
--	'$ID$' as DATASET_TYPE,
--	'CMDB2 Text Export' as NAME,
--	'Date: '+CONVERT(VARCHAR(30), GETDATE(), 20) as MORE_DATA


-- order by __MANDATOR_ID, DATASET_TYPE, DATASET_ID
