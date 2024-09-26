insert into [STATISTICS] (NO, NAME, SQL_VIEW, SQL_ORDER) values ('50', 'Running commissions', 'vw_STAT_RUNNING_COMMISSIONS', '__STATUS_ORDER, ART_STATUS, FOLDER');
insert into [STATISTICS] (NO, NAME, SQL_VIEW, SQL_ORDER) values ('100', 'Local sum over years (commissions outgoing)', 'vw_STAT_SUM_YEARS', 'YEAR desc');
insert into [STATISTICS] (NO, NAME, SQL_VIEW, SQL_ORDER) values ('101', 'Local sum over months (commissions outgoing)', 'vw_STAT_SUM_MONTHS', 'MONTH desc');
insert into [STATISTICS] (NO, NAME, SQL_VIEW, SQL_ORDER) values ('200', 'Top artists/clients', 'vw_STAT_TOP_ARTISTS', 'COUNT_COMMISSIONS desc, AMOUNT_LOCAL desc');
insert into [STATISTICS] (NO, NAME, SQL_VIEW, SQL_ORDER) values ('900', 'Full Text Export', 'vw_STAT_TEXT_EXPORT', 'DATASET_TYPE, DATASET_ID');

insert into [CONFIG] (NAME, VALUE) values ('BACKUP_PATH', '');
insert into [CONFIG] (NAME, VALUE) values ('CURRENCY_LAYER_API_KEY', '');
insert into [CONFIG] (NAME, VALUE) values ('LOCAL_CURRENCY', 'USD');
insert into [CONFIG] (NAME, VALUE) values ('PICKLIST_ARTPAGES', 'DeviantArt;FurAffinity;Imgur;SoFurry;Tumblr');
insert into [CONFIG] (NAME, VALUE) values ('PICKLIST_COMMUNICATION', '(Other);AIM;Alias;Bank account;Battle.net;Birthday;Boosty;Credit Card;DeviantArt;Discord;donationalerts;EasyBusy / EasyStaff / EasyStarter;E-Mail;Facebook;F-List;Full name;FurAffinity;FurryNetwork;Gender;Google Hangouts;Hipolink;ICQ;InkBunny;Instagram;Ko-Fi;Language;Location / Postal;Minecraft;Nickname;Patreon;PayPal;Phone (mobile);Phone (private);Phone (work);Picarto;PlayStationNetwork;QQ;Reddit;Skype;SoFurry;Spotify;Steam;Telegram;Time Zone;ToyHou.se;Tumblr;Twitch;Twitter;URL;VK;Weasyl;Website;WhatsApp;Xbox Live;YIM;YouTube');
insert into [CONFIG] (NAME, VALUE) values ('PICKLIST_PAYPROVIDER', 'Boosty;donationalerts;EasyBusy / EasyStaff / EasyStarter;hipolink.me;Mastercard;Patreon;Payoneer;PayPal;PayPal (customs);PayPal (friend);PayPal (invoice);PayPal.me;PaySend;SEPA');
insert into [CONFIG] (NAME, VALUE) values ('DB_VERSION', '1');
insert into [CONFIG] (NAME, VALUE) values ('CUSTOMIZATION_ID', '');
insert into [CONFIG] (NAME, VALUE) values ('INSTALL_ID', cast(newid() as varchar(100)));

