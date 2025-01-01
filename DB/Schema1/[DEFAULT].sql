insert into [STATISTICS] (NO, NAME, SQL_VIEW, SQL_ORDER) values ('50', 'Running commissions', 'vw_STAT_RUNNING_COMMISSIONS', '__STATUS_ORDER, ART_STATUS, FOLDER');
insert into [STATISTICS] (NO, NAME, SQL_VIEW, SQL_ORDER) values ('100', 'Local sum over years', 'vw_STAT_SUM_YEARS', 'YEAR desc, DIRECTION');
insert into [STATISTICS] (NO, NAME, SQL_VIEW, SQL_ORDER) values ('101', 'Local sum over months', 'vw_STAT_SUM_MONTHS', 'MONTH desc, DIRECTION');
insert into [STATISTICS] (NO, NAME, SQL_VIEW, SQL_ORDER) values ('200', 'Top artists/clients', 'vw_STAT_TOP_ARTISTS', 'COUNT_COMMISSIONS desc, AMOUNT_LOCAL desc');
insert into [STATISTICS] (NO, NAME, SQL_VIEW, SQL_ORDER) values ('900', 'Full Text Export', 'vw_STAT_TEXT_EXPORT', 'DATASET_TYPE, DATASET_ID');

insert into [CONFIG] (NAME, VALUE) values ('BACKUP_PATH', '');
insert into [CONFIG] (NAME, VALUE) values ('CURRENCY_LAYER_API_KEY', '');
insert into [CONFIG] (NAME, VALUE) values ('LOCAL_CURRENCY', 'USD');
insert into [CONFIG] (NAME, VALUE) values ('PICKLIST_ARTPAGES', 'DeviantArt;FurAffinity;Imgur;Inkbunny;Mastodon.ART;Pixiv;Sheezy;SoFurry;Transfur;Tumblr;Weasyl');
insert into [CONFIG] (NAME, VALUE) values ('PICKLIST_COMMUNICATION', '(Other);Alias;Bank account;Battle.net;Birthday;Bluesky;Boosty;Credit Card;DeviantArt;Discord;donationalerts;EasyBusy / EasyStaff / EasyStarter;E-Mail;Facebook;F-List;Full name;FurAffinity;Furry Network;Gender;Google Hangouts;Hipolink;ICQ;IMVU;InkBunny;Instagram;Ko-Fi;Language;Location / Postal;Minecraft;Nickname;Patreon;PayPal;Phone (mobile);Phone (private);Phone (work);Picarto;PlayStationNetwork;QQ;Reddit;Skype;SoFurry;Spotify;Steam;Switch Friend Code;Telegram;Time Zone;ToyHou.se;Tumblr;Twitch;Twitter;URL;VK;Weasyl;Website;WhatsApp;WiiU Friend Code;Xbox Live;YouTube');
insert into [CONFIG] (NAME, VALUE) values ('PICKLIST_PAYPROVIDER', 'Boosty;donationalerts;EasyBusy / EasyStaff / EasyStarter;Etsy;hipolink.me;Mastercard;Patreon;Payoneer;PayPal;PayPal (customs);PayPal (friend);PayPal (invoice);PayPal.me;PaySend;Second Life;SEPA/Wiretransfer');
insert into [CONFIG] (NAME, VALUE) values ('DB_VERSION', '1');
insert into [CONFIG] (NAME, VALUE) values ('CUSTOMIZATION_ID', '');
insert into [CONFIG] (NAME, VALUE) values ('INSTALL_ID', cast(newid() as varchar(100)));
