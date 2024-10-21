
--1. prüfen, hat customer ('cancel c') oder artist ('cancel a') cancelled?
-- OK!
select art.NAME, cm.NAME, ev.* from cmdb2.dbo.COMMISSION_EVENT ev
left join cmdb2.dbo.COMMISSION cm on ev.COMMISSION_ID = cm.ID
left join cmdb2.dbo.ARTIST art on cm.ARTIST_ID = art.ID
where ev.STATE = 'cancel x'
order by art.NAME, cm.NAME;

--2. sicherstellen, dass es diesen status nicht mehr gibt
-- OK!
--select * from cmdb2.dbo.COMMISSION_EVENT where STATE = 'td bez' or STATE = 'aw invoice' or STATE = 'aw refund';

--3. Ungültige Währungen prüfen
-- OK!
--select * from cmdb2.dbo.QUOTE where CURRENCY = '???';
-- OK!
--select * from cmdb2.dbo.PAYMENT where CURRENCY = '???';

--4. Check missing prices (written as 0.1234)
-- OK!
--select art.NAME, pay.* from cmdb2.dbo.PAYMENT pay 
--left join cmdb2.dbo.ARTIST art on art.ID = pay.ARTIST_ID
--where (abs(AMOUNT) between 0.11 and 0.13) or (abs(AMOUNT_LOCAL) between 0.11 and 0.13);

--5. Check missing prices (written as 0.1234)
-- OK!
--select art.NAME, cm.NAME, pay.* from cmdb2.dbo.QUOTE pay 
--left join cmdb2.dbo.COMMISSION_EVENT ev on ev.ID = pay.EVENT_ID
--left join cmdb2.dbo.COMMISSION cm on cm.ID = ev.COMMISSION_ID
--left join cmdb2.dbo.ARTIST art on art.ID = cm.ARTIST_ID
--where (abs(AMOUNT) between 0.11 and 0.13) or (abs(AMOUNT_LOCAL) between 0.11 and 0.13);

--6. Vergleichen, ob laufende CM wirklich korrekt übereinstimmen
-- OK!
--select ART_STATUS, NAME from cmdb2.dbo.vw_COMMISSION where ART_STATUS <> 'fin' and ART_STATUS <> 'postponed' and ART_STATUS <> 'idea' and ART_STATUS <> 'cancel c' and ART_STATUS <> 'cancel x' and ART_STATUS <> 'cancel a' and ART_STATUS <> 'rejected' and ART_STATUS <> 'c td initcm' order by ART_STATUS
