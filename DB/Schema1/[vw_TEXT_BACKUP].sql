CREATE OR ALTER view [dbo].[vw_TEXT_BACKUP] as
select *, cast(CEILING(1.0*LEN(BAK_DATA)/1024) as bigint) as BAK_SIZE_COMPRESSED_KB
from TEXT_BACKUP
