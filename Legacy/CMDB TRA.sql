
------------------------------------------
-- MIGRATION SCRIPT FROM CMDB1 TO CMDB2 --
------------------------------------------

begin transaction

delete from cmdb2.dbo.MANDATOR;
delete from cmdb2.dbo.ARTIST;
delete from cmdb2.dbo.ARTIST_EVENT;
delete from cmdb2.dbo.COMMISSION;
delete from cmdb2.dbo.COMMISSION_EVENT;
delete from cmdb2.dbo.PAYMENT;
delete from cmdb2.dbo.QUOTE;
delete from cmdb2.dbo.UPLOAD;
delete from cmdb2.dbo.COMMUNICATION;

-- LKP_KONTAKTKANAL
delete from cmdb2.dbo.CONFIG where NAME = 'PICKLIST_COMMUNICATION';
insert into cmdb2.dbo.CONFIG (NAME, VALUE, READ_ONLY, HIDDEN)
	select N'PICKLIST_COMMUNICATION',
	STRING_AGG(KONTAKT_TEXT, ';') WITHIN GROUP (ORDER BY KONTAKT_TEXT), 0, 0
	FROM cmdb1.dbo.LKP_KONTAKTKANAL;

-- LKP_PAYPROV
delete from cmdb2.dbo.CONFIG where NAME = 'PICKLIST_PAYPROVIDER';
insert into cmdb2.dbo.CONFIG (NAME, VALUE, READ_ONLY, HIDDEN)
	select N'PICKLIST_PAYPROVIDER',
	STRING_AGG(PAYPROV_TEXT, ';') WITHIN GROUP (ORDER BY PAYPROV_TEXT), 0, 0
	FROM cmdb1.dbo.LKP_PAYPROV;

-- LKP_ARTPAGES
delete from cmdb2.dbo.CONFIG where NAME = 'PICKLIST_ARTPAGES';
insert into cmdb2.dbo.CONFIG (NAME, VALUE, READ_ONLY, HIDDEN)
	select N'PICKLIST_ARTPAGES',
	STRING_AGG(ARTPAGE_TEXT, ';') WITHIN GROUP (ORDER BY ARTPAGE_TEXT), 0, 0
	FROM cmdb1.dbo.LKP_ARTPAGES;

-- MANDATEN EINRICHTEN
insert into cmdb2.dbo.MANDATOR (ID, NAME) values (NEWID(), N'DMX/SD');

-- ARTIST ÜBERTRAGEN
insert into cmdb2.dbo.ARTIST (ID, MANDATOR_ID, NAME, IS_ARTIST, LEGACY_ID)
select
	NEWID() as ID,
	(select top 1 ID from cmdb2.dbo.MANDATOR) as MANDATOR_ID,
	iif(isnull(old_art.SUCHNAME,'')='',old_art.ARTISTNAME,old_art.ARTISTNAME + ' / ' + old_art.SUCHNAME) as NAME,
	1 as IS_ARTIST,
	old_art.ID as LEGACY_ID
from cmdb1.dbo.ARTISTS old_art;

-- Artist Active Status
insert into cmdb2.dbo.ARTIST_EVENT (ID, ARTIST_ID, DATE, STATE, ANNOTATION, LEGACY_ID)
select
	NEWID() as ID,
	art.ID as ARTIST_ID,
	CONVERT(DATETIME, '01.01.1900', 104) as DATE,
	case
		when old_art_act.AKTIV_TEXT = 'Active' then 'start coop'
		when old_art_act.AKTIV_TEXT = 'Hiatus' then 'hiatus'
		when old_art_act.AKTIV_TEXT = 'Cooperation ended' then 'end coop'
		when old_art_act.AKTIV_TEXT = 'Inactive' then 'inactive'
		when old_art_act.AKTIV_TEXT = 'Stopped' then 'stopped'
		when old_art_act.AKTIV_TEXT = 'Deceased' then 'deceased'
		else 'annot'
	end as STATE,
	case
		when old_art_act.AKTIV_TEXT = 'Active' then null
		when old_art_act.AKTIV_TEXT = 'Hiatus' then null
		when old_art_act.AKTIV_TEXT = 'Cooperation ended' then null
		when old_art_act.AKTIV_TEXT = 'Inactive' then null
		when old_art_act.AKTIV_TEXT = 'Stopped' then null
		when old_art_act.AKTIV_TEXT = 'Deceased' then null
		else N'Status: ' + old_art_act.AKTIV_TEXT
	end as ANNOTATION,
	null as LEGACY_ID
	from cmdb1.dbo.ARTISTS old_art
	left join cmdb1.dbo.LKP_ACTIVE as old_art_act on old_art_act.ID = old_art.STATUS
	left join cmdb2.dbo.ARTIST art on art.LEGACY_ID = old_art.ID
	where old_art_act.ID is not null;

-- Artist Currency as Annotation
insert into cmdb2.dbo.ARTIST_EVENT (ID, ARTIST_ID, DATE, STATE, ANNOTATION, LEGACY_ID)
select
	NEWID() as ID,
	art.ID as ARTIST_ID,
	CONVERT(DATETIME, '01.01.1900', 104) as DATE,
	'annot' as STATE,
	'Currency: ' + old_art_cur.CURRENCY_TEXT as ANNOTATION,
	null as LEGACY_ID
	from cmdb1.dbo.ARTISTS old_art
	left join cmdb1.dbo.LKP_CURRENCY as old_art_cur on old_art_cur.ID = old_art.CURRENCY
	left join cmdb2.dbo.ARTIST art on art.LEGACY_ID = old_art.ID
	where old_art_cur.ID is not null;

-- Artist Type as Annotation
insert into cmdb2.dbo.ARTIST_EVENT (ID, ARTIST_ID, DATE, STATE, ANNOTATION, LEGACY_ID)
select
	NEWID() as ID,
	art.ID as ARTIST_ID,
	CONVERT(DATETIME, '01.01.1900', 104) as DATE,
	'annot' as STATE,
	'Artist Type: ' + old_art_typ.ARTISTTYPE_TEXT as ANNOTATION,
	null as LEGACY_ID
	from cmdb1.dbo.ARTISTS old_art
	left join cmdb1.dbo.LKP_ARTISTTYPE as old_art_typ on old_art_typ.ID = old_art.TYPE
	left join cmdb2.dbo.ARTIST art on art.LEGACY_ID = old_art.ID
	where old_art_typ.ID is not null;

-- Artist Trust Level as Annotation
insert into cmdb2.dbo.ARTIST_EVENT (ID, ARTIST_ID, DATE, STATE, ANNOTATION, LEGACY_ID)
select
	NEWID() as ID,
	art.ID as ARTIST_ID,
	CONVERT(DATETIME, '01.01.1900', 104) as DATE,
	'annot' as STATE,
	'Trust Level: ' + old_art_trust.TRUSTLEVEL_TEXT as ANNOTATION,
	null as LEGACY_ID
	from cmdb1.dbo.ARTISTS old_art
	left join cmdb1.dbo.LKP_TRUSTLEVEL as old_art_trust on old_art_trust.ID = old_art.TRUST
	left join cmdb2.dbo.ARTIST art on art.LEGACY_ID = old_art.ID
	where old_art_trust.ID is not null;

-- Artist Pay Provider as Annotation
insert into cmdb2.dbo.ARTIST_EVENT (ID, ARTIST_ID, DATE, STATE, ANNOTATION, LEGACY_ID)
select
	NEWID() as ID,
	art.ID as ARTIST_ID,
	CONVERT(DATETIME, '01.01.1900', 104) as DATE,
	'annot' as STATE,
	'Pay Provider: ' + old_art_payprov.PAYPROV_TEXT as ANNOTATION,
	null as LEGACY_ID
	from cmdb1.dbo.ARTISTS old_art
	left join cmdb1.dbo.LKP_PAYPROV as old_art_payprov on old_art_payprov.ID = old_art.PAYPROV
	left join cmdb2.dbo.ARTIST art on art.LEGACY_ID = old_art.ID
	where old_art_payprov.ID is not null;

-- Artist Pay Condition as Annotation
insert into cmdb2.dbo.ARTIST_EVENT (ID, ARTIST_ID, DATE, STATE, ANNOTATION, LEGACY_ID)
select
	NEWID() as ID,
	art.ID as ARTIST_ID,
	CONVERT(DATETIME, '01.01.1900', 104) as DATE,
	'annot' as STATE,
	'Pay Condition: ' + old_art_paycond.PAYCOND_TEXT as ANNOTATION,
	null as LEGACY_ID
	from cmdb1.dbo.ARTISTS old_art
	left join cmdb1.dbo.LKP_PAYCOND as old_art_paycond on old_art_paycond.ID = old_art.PAYCOND
	left join cmdb2.dbo.ARTIST art on art.LEGACY_ID = old_art.ID
	where old_art_paycond.ID is not null;

-- COMMISSIONS ÜBERTRAGEN (NUR LEGACY_ID, ARTIST, TITEL, ORDNER)
insert into cmdb2.dbo.COMMISSION (ID, ARTIST_ID, NAME, FOLDER, LEGACY_ID)
select
	NEWID() as ID,
	art.ID as ARTIST_ID,
	old_cm.TITLE as NAME,
	case
		when (len(old_cm.ORDNER) < 5 or substring(old_cm.ORDNER, 2, 1) = ':' or left(old_cm.ORDNER, 2) = '\\') then old_cm.ORDNER
		else N'D:\OneDrive\Commissions\' + old_cm.ORDNER -- ' this apostrophe is to avoid that Notepad++ syntax highlighting is off...
	end as FOLDER,
	old_cm.ID as LEGACY_ID
from
	cmdb1.dbo.COMMISSIONS old_cm
left join
	cmdb2.dbo.ARTIST art on art.LEGACY_ID = old_cm.ARTIST;

-- COMMISSIONS ÜBERTRAGEN (ERTEILT EVENT)
insert into cmdb2.dbo.COMMISSION_EVENT (ID, COMMISSION_ID, DATE, STATE, ANNOTATION)
select
	newid() as ID,
	cm.ID as COMMISSION_ID,
	isnull(old_cm.ERTEILT,CONVERT(DATETIME, '01.01.1900', 104)) as DATE,
	'ack' as STATE,
	IIF(old_cm.ERTEILT is null,N'Start Date unknown',N'') as ANNOTATION
from
	cmdb1.dbo.COMMISSIONS old_cm
left join
	cmdb2.dbo.COMMISSION cm on cm.LEGACY_ID = old_cm.ID
where
	old_cm.ERTEILT is not null;

-- COMMISSIONS ÜBERTRAGEN (LETZTES EVENT + ABSCHLUSS DATUM)
with tmp as (
	select
	old_cm.ID as LEGACY_ID,
	old_cm.ERTEILT as LEGACY_START,
	old_cm.ABGESCHLOSSEN as LEGACY_END,
	old_cm.TITLE as NAME,
	st.STATUS_TEXT as LEGACY_STATUS,
	case
		when st.STATUS_TEXT = 'cancelled' then N'cancel x'
		when st.STATUS_TEXT = 'versandet' then N'cancel c'
		when st.STATUS_TEXT = 'fin; td pub' then N'fin'
		when st.STATUS_TEXT = 'fin; aw pub' then N'fin'
		when st.STATUS_TEXT = 'fin; aw psd' then N'c aw hires'
		when st.STATUS_TEXT = 'fin; aw hires' then N'c aw hires'
		when st.STATUS_TEXT = 'ych lost' then N'rejected'
		when st.STATUS_TEXT = 'td artist suche' then N'idea'
		when st.STATUS_TEXT = 'td ych win' then N'idea'
		when st.STATUS_TEXT = 'aw ack' then N'c aw ack'
		when st.STATUS_TEXT = 'aw sk' then N'c aw sk'
		when st.STATUS_TEXT = 'td sk' then N'c aw sk'
		when st.STATUS_TEXT = 'aw ink' then N'c aw cont'
		when st.STATUS_TEXT = 'td ink' then N'c aw cont'
		when st.STATUS_TEXT = 'aw continue' then N'c aw cont'
		when st.STATUS_TEXT = 'aw cor' then N'c aw cont'
		when st.STATUS_TEXT = 'aw shading' then N'c aw cont'
		when st.STATUS_TEXT = 'aw colo' then N'c aw cont'
		when st.STATUS_TEXT = 'td colo' then N'c aw cont'
		when st.STATUS_TEXT = 'td cs' then N'c td feedback'
		when st.STATUS_TEXT = 'td cor' then N'c aw cont'
		when st.STATUS_TEXT = 'aw freigabe' then N'c aw hires'
		when st.STATUS_TEXT = 'aw hires' then N'c aw hires'
		when st.STATUS_TEXT = 'td initcm' then N'c td initcm'
		when st.STATUS_TEXT = 'td finalize' then N'c aw cont'
		when st.STATUS_TEXT = 'aw quote' then N'c aw ack'
		else st.STATUS_TEXT
	end as LEGACY_STATUS_NEW,
	old_cm.ARTIST as LEGACY_ARTIST_ID
	from cmdb1.dbo.COMMISSIONS old_cm
	left join cmdb1.dbo.LKP_STATUS st on st.ID = old_cm.STATUS
)
insert into cmdb2.dbo.COMMISSION_EVENT (ID, COMMISSION_ID, DATE, STATE, ANNOTATION)
select
	newid() as ID,
	cm.ID as COMMISSION_ID,
	case
		when tmp.LEGACY_STATUS_NEW is null and tmp.LEGACY_END is not null then tmp.LEGACY_END
		when tmp.LEGACY_STATUS_NEW='fin' and tmp.LEGACY_END is null then CONVERT(DATETIME, '31.12.2999', 104)
		when tmp.LEGACY_STATUS_NEW='fin' and tmp.LEGACY_END is not null then tmp.LEGACY_END
		when tmp.LEGACY_STATUS_NEW<>'fin' then CONVERT(DATETIME, '31.12.2999', 104)
		else null -- should not happen
	end as DATE,
	case
		when tmp.LEGACY_STATUS_NEW is null and tmp.LEGACY_END is not null then N'fin'
		else tmp.LEGACY_STATUS_NEW
	end as STATE,
	case
		when tmp.LEGACY_STATUS_NEW is null and tmp.LEGACY_END is not null then N'Finish Date (but original state missing)'
		when tmp.LEGACY_STATUS_NEW='fin' and tmp.LEGACY_END is null then N'Finish Date unknown'
		when tmp.LEGACY_STATUS_NEW='fin' and tmp.LEGACY_END is not null then N''
		when tmp.LEGACY_STATUS_NEW<>'fin' then N'Original State '+tmp.LEGACY_STATUS+N' with unknown date'
		else null -- should not happen
	end as ANNOTATION
from
	tmp
left join
	cmdb2.dbo.COMMISSION cm on cm.LEGACY_ID = tmp.LEGACY_ID
where
	tmp.LEGACY_STATUS_NEW is not null or LEGACY_END is not null;

-- COMMISSION_NOTES als Commission Event einfügen
insert into cmdb2.dbo.COMMISSION_EVENT (ID, COMMISSION_ID, DATE, STATE, ANNOTATION)
select
NEWID() as ID,
cm.ID as COMMISSION_ID,
ISNULL(old.DATUM,CONVERT(DATETIME, '01.01.1900', 104)) as DATE,
'annot' as STATE,
old.NOTE as ANNOTATION
from cmdb1.dbo.COMMISSION_NOTES old
left join cmdb2.dbo.COMMISSION cm on cm.LEGACY_ID = old.COMMISSION;

-- Tabelle STATUSCHANGES vearbeiten
insert into cmdb2.dbo.COMMISSION_EVENT (ID, COMMISSION_ID, DATE, STATE, ANNOTATION)
select
NEWID() as ID,
cm.ID as COMMISSION_ID,
ISNULL(old.DATUM,CONVERT(DATETIME, '01.01.1900', 104)) as DATE,
'annot' as STATE,
isnull(old.ORIGIN+': ','')+ISNULL(old.DESCRIPTION,'Unknown Status Change') as ANNOTATION
from cmdb1.dbo.STATUSCHANGES old
left join cmdb2.dbo.COMMISSION cm on cm.LEGACY_ID = old.COMMISSION;

-- Artist offers
insert into cmdb2.dbo.ARTIST_EVENT (ID, ARTIST_ID, DATE, STATE, ANNOTATION, LEGACY_ID)
select
	NEWID() as ID,
	art.ID as ARTIST_ID,
	isnull(ofr.PROPAGATION,CONVERT(DATETIME, '01.01.1900', 104)) as DATE,
	'offer' as STATE,
	ofr.DESCRIPTION + ': ' +
		cast(ofr.PRICE as nvarchar(10)) + ' ' + cur.CURRENCY_TEXT +
		iif(ofr.PERSONAL=1,' (Personalized)', '')
		as ANNOTATION,
	ofr.ID as LEGACY_ID
	from cmdb1.dbo.ARTIST_OFFERS ofr
	left join cmdb1.dbo.LKP_CURRENCY cur on cur.ID = ofr.CURRENCY
	left join cmdb2.dbo.ARTIST art on art.LEGACY_ID = ofr.ARTIST;

-- Artist notes
insert into cmdb2.dbo.ARTIST_EVENT (ID, ARTIST_ID, DATE, STATE, ANNOTATION, LEGACY_ID)
select
	NEWID() as ID,
	art.ID as ARTIST_ID,
	isnull(old.DATUM,CONVERT(DATETIME, '01.01.1900', 104)) as DATE,
	'annot' as STATE,
	old.NOTE as ANNOTATION,
	old.ID as LEGACY_ID
	from cmdb1.dbo.ARTIST_NOTES old
	left join cmdb2.dbo.ARTIST art on art.LEGACY_ID = old.ARTIST;

insert into cmdb2.dbo.COMMUNICATION (ID, ARTIST_ID, CHANNEL, ADDRESS, ANNOTATION, LEGACY_ID)
select 
	NEWID() as ID,
	art.ID as ARTIST_ID,
	cn.KONTAKT_TEXT as CHANNEL,
	isnull(co.ADDRESS,'') as ADDRESS,
	co.COMMENT as ANNOTATION,
	co.ID as LEGACY_ID
	from cmdb1.dbo.COMMUNICATION co
	left join cmdb1.dbo.LKP_KONTAKTKANAL cn on cn.ID = co.CHANNEL
	left join cmdb2.dbo.ARTIST art on art.LEGACY_ID = co.ARTIST;

--...Event part
insert into cmdb2.dbo.COMMISSION_EVENT (ID, COMMISSION_ID, DATE, STATE, ANNOTATION)
select
	NEWID() as ID,
	cm.ID as COMMISSION_ID,
	CONVERT(DATETIME, '01.01.1900', 104) as DATE,
	case
	when up.ARTIST=1 and up.COMMISSIONER=0 then N'upload a'
	when up.ARTIST=0 and up.COMMISSIONER=1 then N'upload c'
	else N'upload x' -- Foreign
	end as STATE,
	null as ANNOTATION
	from cmdb1.dbo.UPLOADS old
	left join cmdb2.dbo.COMMISSION cm on cm.LEGACY_ID = old.COMMISSION
	left join cmdb1.dbo.COMMISSIONS old_cm on old_cm.ID = old.COMMISSION
	left join cmdb1.dbo.LKP_UPLOADPARTY up on up.ID = old.UPLOADPARTY
	group by cm.ID, up.ARTIST, up.COMMISSIONER;
--...Upload part
insert into cmdb2.dbo.UPLOAD (ID, EVENT_ID, NO, PAGE, URL, PROHIBIT, ANNOTATION, LEGACY_ID)
select
	NEWID() as ID,
	ev.ID as EVENT_ID,
	ROW_NUMBER() OVER (PARTITION BY ev.ID ORDER BY (SELECT NULL)) AS NR,
	isnull(old_ap.ARTPAGE_TEXT,'-') as PAGE,
	isnull(upl.URL,'-') as URL,
	iif(upl.URL like 'DO NOT RELEASE',1,0) as PROHIBIT,
	iif(isnull(upl.REVISION,'')='',isnull(upl.KOMMENTAR,''),'Rev. '+upl.REVISION+isnull('; '+upl.KOMMENTAR,'')) as ANNOTATION,
	upl.ID as LEGACY_ID
	from cmdb1.dbo.UPLOADS upl
	left join cmdb2.dbo.COMMISSION cm on cm.LEGACY_ID = upl.COMMISSION
	left join cmdb1.dbo.LKP_ARTPAGES old_ap on old_ap.ID = upl.ARTPAGE
	left join cmdb1.dbo.LKP_UPLOADPARTY up on up.ID = upl.UPLOADPARTY
	left join cmdb2.dbo.COMMISSION_EVENT ev on ev.COMMISSION_ID = cm.ID and 
	ev.STATE = case
	when up.ARTIST=1 and up.COMMISSIONER=0 then N'upload a'
	when up.ARTIST=0 and up.COMMISSIONER=1 then N'upload c'
	else N'upload x' -- Foreign
	end;

-- Fill Quote
-- ... Event Part
insert into cmdb2.dbo.COMMISSION_EVENT (ID, COMMISSION_ID, DATE, STATE, ANNOTATION)
select
	NEWID() as ID,
	cm.ID as COMMISSION_ID,
	isnull(isnull(old.PRICEDATE,old_cm.ERTEILT),CONVERT(DATETIME, '01.01.1900', 104)) as DATE,
	'quote' as STATE,
	null as ANNOTATION
	from cmdb1.dbo.QUOTE old
	left join cmdb2.dbo.COMMISSION cm on cm.LEGACY_ID = old.COMMISSION_ID
	left join cmdb1.dbo.COMMISSIONS old_cm on old_cm.ID = old.COMMISSION_ID
	left join cmdb1.dbo.LKP_CURRENCY old_cur on old_cur.ID = old.CURRENCY
	where isnull(old.PRICE_NATIVE,0)<>0 or isnull(old.PRICE_LOCAL,0)<>0
	group by cm.ID, isnull(isnull(old.PRICEDATE,old_cm.ERTEILT),CONVERT(DATETIME, '01.01.1900', 104));
-- ... Quote Part 1: Regular payments
insert into cmdb2.dbo.QUOTE (ID, EVENT_ID, NO, AMOUNT, CURRENCY, AMOUNT_LOCAL, IS_FREE, DESCRIPTION, LEGACY_ID)
	select
	NEWID() as ID,
	ev.ID as EVENT_ID,
	ROW_NUMBER() OVER (PARTITION BY ev.ID ORDER BY (SELECT NULL)) AS NR,
	isnull(old.PRICE_NATIVE,-0.12345) as AMOUNT,
	isnull(old_cur.CURRENCY_TEXT,'???') as CURRENCY,
	isnull(old.PRICE_LOCAL,-0.12345) as AMOUNT_LOCAL,
	IIF((st.BEZ_TEXT = 'gift') or (st.BEZ_TEXT = 'free'),1,0) as IS_FREE,
	trim(isnull(st.BEZ_TEXT,'')+' '+isnull(old.DESCRIPTION,'')) as DESCRIPTION,
	old.ID as LEGACY_ID
	from cmdb1.dbo.QUOTE old
	left join cmdb2.dbo.COMMISSION cm on cm.LEGACY_ID = old.COMMISSION_ID
	LEFT join cmdb1.dbo.COMMISSIONS old_cm on old_cm.ID = old.COMMISSION_ID
	LEFT join cmdb1.dbo.ARTISTS old_art on old_art.ID = old_cm.ARTIST
	left join cmdb1.dbo.LKP_CURRENCY old_cur on old_cur.ID = isnull(old.CURRENCY,old_art.CURRENCY)
	left join cmdb2.dbo.COMMISSION_EVENT ev on ev.COMMISSION_ID = cm.ID and ev.STATE = 'quote' and ev.DATE = isnull(isnull(old.PRICEDATE,old_cm.ERTEILT),CONVERT(DATETIME, '01.01.1900', 104))
	left join cmdb1.dbo.LKP_BEZAHLSTATUS st on st.ID = old.BEZAHLT
	where isnull(old.PRICE_NATIVE,0)<>0 or isnull(old.PRICE_LOCAL,0)<>0;
-- ... Quote Part 2: Regular payments, cancelled commission status
insert into cmdb2.dbo.QUOTE (ID, EVENT_ID, NO, AMOUNT, CURRENCY, AMOUNT_LOCAL, IS_FREE, DESCRIPTION, LEGACY_ID)
	select
	NEWID() as ID,
	ev.ID as EVENT_ID,
	100+ROW_NUMBER() OVER (PARTITION BY ev.ID ORDER BY (SELECT NULL)) AS NR,
	-isnull(old.PRICE_NATIVE,-0.12345) as AMOUNT,
	isnull(old_cur.CURRENCY_TEXT,'???') as CURRENCY,
	-isnull(old.PRICE_LOCAL,-0.12345) as AMOUNT_LOCAL,
	IIF((st.BEZ_TEXT = 'gift') or (st.BEZ_TEXT = 'free'),1,0) as IS_FREE,
	trim(isnull(st.BEZ_TEXT,'')+' '+isnull(old.DESCRIPTION,''))+' (Cancel)' as DESCRIPTION,
	old.ID as LEGACY_ID
	from cmdb1.dbo.QUOTE old
	left join cmdb2.dbo.COMMISSION cm on cm.LEGACY_ID = old.COMMISSION_ID
	left join cmdb1.dbo.COMMISSIONS old_cm on old_cm.ID = old.COMMISSION_ID
	left join cmdb1.dbo.LKP_STATUS old_st on old_st.ID = old_cm.STATUS
	left join cmdb1.dbo.ARTISTS old_art on old_art.ID = old_cm.ARTIST
	left join cmdb1.dbo.LKP_CURRENCY old_cur on old_cur.ID = isnull(old.CURRENCY,old_art.CURRENCY)
	left join cmdb2.dbo.COMMISSION_EVENT ev on ev.COMMISSION_ID = cm.ID and ev.STATE = 'quote' and ev.DATE = isnull(isnull(old.PRICEDATE,old_cm.ERTEILT),CONVERT(DATETIME, '01.01.1900', 104))
	left join cmdb1.dbo.LKP_BEZAHLSTATUS st on st.ID = old.BEZAHLT
	where (isnull(old.PRICE_NATIVE,0)<>0 or isnull(old.PRICE_LOCAL,0)<>0) and isnull(old_st.ABBRUCH,0)=1;

-- Zahlungen aus Commissons resultieren (QUOTE => PAYMENT)
insert into cmdb2.dbo.PAYMENT (ID, ARTIST_ID, DATE, AMOUNT, CURRENCY, AMOUNT_LOCAL, AMOUNT_VERIFIED, PAYPROV, ANNOTATION)
select
	newid() as ID,
	art.ID as ARTIST_ID,
	isnull(isnull(isnull(q.PAYDATE,q.PRICEDATE),old_cm.ERTEILT),CONVERT(DATETIME, '01.01.1900', 104)) as DATE,
	isnull(nullif(SUM(isnull(q.PRICE_NATIVE,0)),0),-0.12345) as AMOUNT,
	isnull(old_cur.CURRENCY_TEXT,'???') as CURRENCY,
	isnull(nullif(SUM(isnull(q.PRICE_LOCAL,0)),0),-0.12345) as AMOUNT_LOCAL,
	IIF(isnull(q.PRECALC,1)=1,0,1) as AMOUNT_VERIFIED,
	old_pp.PAYPROV_TEXT as PAYPROV,
	'Payment for: '+old_cm.TITLE+ISNULL('; '+q.COMMENT,'')+ISNULL('; PayProv Trace '+q.PROV_TRACE,'')+IIF(q.PAYDATE is null,' (Pay date unknown)','') as ANNOTATION
	from cmdb1.dbo.COMMISSIONS old_cm
	left join cmdb1.dbo.QUOTE q on q.COMMISSION_ID = old_cm.ID
	LEFT join cmdb1.dbo.LKP_STATUS old_cm_st on old_cm_st.ID = old_cm.STATUS
	left join cmdb1.dbo.LKP_BEZAHLSTATUS st on st.ID = q.BEZAHLT
	left join cmdb1.dbo.LKP_CURRENCY old_cur on old_cur.ID = q.CURRENCY
	left join cmdb1.dbo.LKP_PAYPROV old_pp on old_pp.ID = q.PAYPROVIDER
	left join cmdb2.dbo.ARTIST art on art.LEGACY_ID = old_cm.ARTIST
	where st.BEZAHLT = 1 and st.CREDIT = 0 and (old_cm_st.STATUS_TEXT<>'idea')
	group by old_cm.ID, old_cm.TITLE, old_cur.CURRENCY_TEXT, old_pp.PAYPROV_TEXT, q.PRECALC, art.ID, isnull(isnull(q.PAYDATE,q.PRICEDATE),old_cm.ERTEILT), q.PAYDATE, q.PROV_TRACE, q.COMMENT;

-- Akontozahlungen (ZAHLUNGEN => PAYMENT)
insert into cmdb2.dbo.PAYMENT (ID, ARTIST_ID, DATE, AMOUNT, CURRENCY, AMOUNT_LOCAL, AMOUNT_VERIFIED, PAYPROV, ANNOTATION)
-- Hauptzahlung (enthält ggf. fremde Dinge)
select NEWID() as ID,
	art.ID as ARTIST_ID,
	isnull(old_z.DATUM,CONVERT(DATETIME, '01.01.1900', 104)) as DATE,
	old_z.NATIV as AMOUNT,
	old_cur.CURRENCY_TEXT as CURRENCY,
	old_z.BETRAG as AMOUNT_LOCAL,
	1 as AMOUNT_VERIFIED,
	old_pp.PAYPROV_TEXT as PAYPROV,
	old_z.KOMMENTAR+ISNULL('; TA Code: '+old_z.TA_CODE,'')+ISNULL('; PayProv Trace '+old_z.PROV_TRACE,'') as ANNOTATION
from cmdb1.dbo.ZAHLUNGEN old_z
LEFT join cmdb2.dbo.ARTIST art on art.LEGACY_ID = old_z.ARTIST
LEFT join cmdb1.dbo.LKP_CURRENCY old_cur on old_cur.ID = old_z.CURRENCY
left join cmdb1.dbo.LKP_PAYPROV old_pp on old_pp.ID = old_z.PAYPROVIDER
union
-- Abzüge
select NEWID() as ID,
	art.ID as ARTIST_ID,
	isnull(old_z.DATUM,CONVERT(DATETIME, '01.01.1900', 104)) as DATE,
	-old_z.NATIV_ABZUG as AMOUNT,
	old_cur.CURRENCY_TEXT as CURRENCY,
	-old_z.ABZUG as AMOUNT_LOCAL,
	1 as AMOUNT_VERIFIED,
	old_pp.PAYPROV_TEXT as PAYPROV,
	old_z.KOMMENTAR+ISNULL('; TA Code: '+old_z.TA_CODE,'')+ISNULL('; PayProv Trace '+old_z.PROV_TRACE,'') as ANNOTATION
from cmdb1.dbo.ZAHLUNGEN old_z
LEFT join cmdb2.dbo.ARTIST art on art.LEGACY_ID = old_z.ARTIST
LEFT join cmdb1.dbo.LKP_CURRENCY old_cur on old_cur.ID = old_z.CURRENCY
left join cmdb1.dbo.LKP_PAYPROV old_pp on old_pp.ID = old_z.PAYPROVIDER
where isnull(old_z.ABZUG,0)<>0 or isnull(old_z.NATIV_ABZUG,0)<>0;

-- Quote Annotation Reorganisieren
UPDATE ev
SET ev.ANNOTATION = (
    SELECT STRING_AGG(
        CASE 
            WHEN am.IS_FREE = 0 THEN N'Price ' + CAST(am.TotalAmount AS NVARCHAR(10)) + N' ' + am.CURRENCY
            WHEN am.IS_FREE = 1 THEN CAST(am.TotalAmount AS NVARCHAR(10)) + N' ' + am.CURRENCY + N' Free'
        END,
        ' + '
    )
    FROM (
        SELECT
            EVENT_ID,
            IS_FREE,
            CURRENCY,
            isnull(SUM(AMOUNT),'') AS TotalAmount
        FROM cmdb2.dbo.QUOTE
        GROUP BY EVENT_ID, IS_FREE, CURRENCY
    ) am
    WHERE am.EVENT_ID = ev.ID
)
FROM cmdb2.dbo.COMMISSION_EVENT ev
WHERE ev.STATE = 'quote';

-- Upload Event Annotation Reorganisieren
UPDATE ev
SET ev.ANNOTATION = (
    SELECT STRING_AGG(
        CASE 
			WHEN PROHIBIT = 0 THEN PAGE + ' (' + CAST(TotalAmount AS NVARCHAR(10)) + ')'
			WHEN PROHIBIT = 1 and isnull(PAGE,'')='' THEN N'PROHIBITED'
			WHEN PROHIBIT = 1 and isnull(PAGE,'')<>'' THEN PAGE + N' (PROHIBITED)'
        END,
        ', '
    )
    FROM (
		SELECT
			EVENT_ID, 
			PROHIBIT, 
			PAGE, 
			COUNT(*) AS TotalAmount 
		FROM cmdb2.dbo.UPLOAD 
		GROUP BY EVENT_ID, PROHIBIT, PAGE 
    ) am
    WHERE am.EVENT_ID = ev.ID
)
FROM cmdb2.dbo.COMMISSION_EVENT ev
WHERE ev.STATE like 'upload %';

commit
