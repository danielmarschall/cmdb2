CREATE OR ALTER VIEW [dbo].[vw_CONFIG] AS
select
	NAME,
	VALUE, 
	cast(case
		when NAME = 'BACKUP_PATH'            then N'Path on the server machine to stored SQL Server Backups, or empty for the default path (for LocalDB: The user profile folder)'
		when NAME = 'LOCAL_CURRENCY'         then N'3-Letter currency code (e.g. USD) which will be used for currency convertions'
		when NAME = 'CURRENCY_LAYER_API_KEY' then N'CurrencyLayer.com API key for the currency conversion'
		when NAME = 'PICKLIST_COMMUNICATION' then N'Semicolon-separated picklist for the artist=>communication database grid'
		when NAME = 'PICKLIST_PAYPROVIDER'   then N'Semicolon-separated picklist for the artist=>payment database grid'
		when NAME = 'PICKLIST_ARTPAGES'      then N'Semicolon-separated picklist for the artpage upload event in a commission'
	end as nvarchar(4000)) as HELP_TEXT
from CONFIG
where NAME <> 'DB_VERSION'
and   NAME <> 'CUSTOMIZATION_ID'
and   NAME <> 'INSTALL_ID'
