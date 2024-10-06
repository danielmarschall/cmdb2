library BasicStatsPlugin;

uses
  System.SysUtils,
  System.Classes,
  Adodb,
  AdoConnHelper,
  Windows,
  ShellApi,
  CmDbPluginShare in 'CmDbPluginShare.pas';

{$R *.res}

const
  // Ctrl+Shift+G to generate new GUIDs
  GUID_STATS_PLUGIN: TGUID = '{72FFE4A5-2C2F-406B-92DE-D6AD8CD81594}';
  GUID_1: TGUID = '{6F7E0568-3612-4BD0-BEA6-B23560A5F594}';
  GUID_2: TGUID = '{08F3D4C0-8DBD-4F3E-8891-241858779E49}';
  GUID_2A: TGUID = '{8B46FC53-21E8-4E8C-AB60-AC9811B8D8B4}';
  GUID_3: TGUID = '{2A7F1225-08A6-4B55-9EF7-75C7933DFBCA}';
  GUID_3A: TGUID = '{804E25DD-5756-47E8-9727-5849DCF63E32}';
  GUID_4: TGUID = '{636CD096-DB61-4ECF-BA79-00445AEB8798}';
  GUID_5: TGUID = '{7A913ECF-16F1-493E-AEBA-5C41711068E2}';
  GUID_6: TGUID = '{1D9DB7D5-A5FD-405D-9AFF-7C1781D6E1C6}';

function VtsPluginID(lpTypeOut: PGUID; lpIdOut: PGUID; lpVerOut: PDWORD; lpAuthorInfo: Pointer): HRESULT; stdcall;
var
  AuthorInfo: TVtsPluginAuthorInfo;
resourcestring
  S_Info_PluginName = 'Basic Stats Plugin';
  S_Info_PluginAuthor = 'Daniel Marschall, ViaThinkSoft';
  S_Info_PluginVersion = '1.0';
  S_Info_PluginCopyright = '(C) 2024 Daniel Marschall, ViaThinkSoft';
  S_Info_PluginLicense = 'Apache 2.0';
  S_Info_PluginMoreInfo = '';
begin
  if Assigned(lpTypeOut) then
  begin
    // identifies this plugin type and interface version
    lpTypeOut^ := CMDB2_STATSPLUGIN_V1_TYPE;
  end;

  if Assigned(lpIDOut) then
  begin
    // identifies this individual plugin (any version)
    lpIDOut^ := GUID_STATS_PLUGIN;
  end;

  if Assigned(lpVerOut) then
  begin
    // this individual plugin version: 1.0.0.0 (1 byte per version part)
    lpVerOut^ := $01000000;
  end;

  if Assigned(lpAuthorInfo) then
  begin
    AuthorInfo.PluginName := S_Info_PluginName;
    AuthorInfo.PluginAuthor := S_Info_PluginAuthor;
    AuthorInfo.PluginVersion := S_Info_PluginVersion;
    AuthorInfo.PluginCopyright := S_Info_PluginCopyright;
    AuthorInfo.PluginLicense := S_Info_PluginLicense;
    AuthorInfo.PluginMoreInfo := S_Info_PluginMoreInfo;
    AuthorInfo.WriteToMemory(lpAuthorInfo);
  end;

  result := S_OK;
end;

function InitW(DBConnStr: PChar): HRESULT; stdcall;
var
  AdoConn: TAdoConnection;
begin
  try
    AdoConn := TAdoConnection.Create(nil);
    try
      try
        if DBConnStr = '' then Exit(E_PLUGIN_BAD_ARGS);
        AdoConn.LoginPrompt := false;
        AdoConn.ConnectConnStr(DBConnStr);
      except
        Exit(E_PLUGIN_CONN_FAIL);
      end;

      AdoConn.ExecSQL('insert into [STATISTICS] (ID, PLUGIN, NO, NAME) values ('''+GUID_1.ToString+''', ''BasicStats'', ''50'', ''Running commissions'');');
      AdoConn.ExecSQL('insert into [STATISTICS] (ID, PLUGIN, NO, NAME) values ('''+GUID_2.ToString+''', ''BasicStats'', ''100'', ''Local sum over years'');');
      AdoConn.ExecSQL('insert into [STATISTICS] (ID, PLUGIN, NO, NAME) values ('''+GUID_3.ToString+''', ''BasicStats'', ''101'', ''Local sum over months'');');
      AdoConn.ExecSQL('insert into [STATISTICS] (ID, PLUGIN, NO, NAME) values ('''+GUID_5.ToString+''', ''BasicStats'', ''301'', ''Things I am waiting for (Art, Payment, Upload)'');');
      AdoConn.ExecSQL('insert into [STATISTICS] (ID, PLUGIN, NO, NAME) values ('''+GUID_6.ToString+''', ''BasicStats'', ''302'', ''Things I need to do (Art, Payment, Upload)'');');
      AdoConn.ExecSQL('insert into [STATISTICS] (ID, PLUGIN, NO, NAME) values ('''+GUID_4.ToString+''', ''BasicStats'', ''900'', ''Top artists/clients'');');

      AdoConn.Disconnect;
    finally
      AdoConn.Free;
    end;

    result := S_PLUGIN_OK;
  except
    Exit(E_PLUGIN_GENERIC_FAILURE);
  end;
end;

function ClickEventW(DBConnStr: PChar; MandatorGuid, StatGuid,
  ItemGuid: TGuid; ResponseData: Pointer): HRESULT; stdcall;
var
  AdoConn: TADOConnection;
  q: TADODataSet;
  Response: TCmDbPluginClickResponse;
begin
  if ResponseData = nil then Exit(E_PLUGIN_BAD_ARGS);
  try
    Response.Handled := false;

    {$REGION 'Stat: Running commissions'}
    if IsEqualGuid(StatGuid, GUID_1) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          try
            if DBConnStr = '' then Exit(E_PLUGIN_BAD_ARGS);
            AdoConn.LoginPrompt := false;
            AdoConn.ConnectConnStr(DBConnStr);
          except
            Exit(E_PLUGIN_CONN_FAIL);
          end;
          AdoConn.ExecSQL('create or alter view '+TempTableName(GUID_1, 'RUNNING_COMMISSIONS')+' as ' + #13#10 +
                          'select ' + #13#10 +
                          '    man.ID as __MANDATOR_ID, ' + #13#10 +
                          '    case ' + #13#10 +
                          '        when cm.ART_STATUS = ''c aw ack'' then 1 ' + #13#10 +
                          '        when cm.ART_STATUS = ''ack'' then 2 ' + #13#10 +
                          '        when cm.ART_STATUS = ''c aw sk'' then 3 ' + #13#10 +
                          '        when cm.ART_STATUS = ''c td feedback'' then 4 ' + #13#10 +
                          '        when cm.ART_STATUS = ''c aw cont'' then 5 ' + #13#10 +
                          '        when cm.ART_STATUS = ''c aw hires'' then 6 ' + #13#10 +
                          '        else 7 ' + #13#10 +
                          '    end as __STATUS_ORDER, ' + #13#10 +
                          '    cm.ART_STATUS, ' + #13#10 +
                          '    art.NAME as ARTIST, ' + #13#10 +
                          '    cm.NAME, ' + #13#10 +
                          '    cm.ID as __ID, ' + #13#10 +
                          '    case ' + #13#10 +
                          '        when CHARINDEX(''\'', cm.FOLDER) > 0 THEN RIGHT(cm.FOLDER, CHARINDEX(''\'', REVERSE(cm.FOLDER)) - 1) ' + #13#10 +
                          '        else cm.FOLDER ' + #13#10 +
                          '    end as FOLDER ' + #13#10 +
                          'from vw_COMMISSION cm ' + #13#10 +
                          'left join ARTIST art on art.ID = cm.ARTIST_ID ' + #13#10 +
                          'left join MANDATOR man on man.ID = art.MANDATOR_ID ' + #13#10 +
                          'where not (cm.ART_STATUS = ''fin'' or cm.ART_STATUS = ''idea'' or cm.ART_STATUS = ''postponed'' or cm.ART_STATUS like ''cancel %'' or cm.ART_STATUS = ''c td initcm'' or cm.ART_STATUS = ''rejected'')');
        finally
          FreeAndNil(AdoConn);
        end;
        Response.Handled := true;
        Response.Action := craStatistics;
        Response.StatId := StatGuid;
        Response.StatName := 'Running commissions';
        Response.SqlTable := TempTableName(GUID_1, 'RUNNING_COMMISSIONS');
        Response.SqlInitialOrder := '__STATUS_ORDER, ART_STATUS, FOLDER';
        Response.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
        Response.BaseTableDelete := 'COMMISSION';
      end
      else
      begin
        Response.Handled := true;
        Response.Action := craObject;
        Response.ObjTable := 'COMMISSION';
        Response.ObjId := ItemGuid;
      end;
    end
    {$ENDREGION}
    {$REGION 'Stat: Local sum over years'}
    else if IsEqualGuid(StatGuid, GUID_2) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          try
            if DBConnStr = '' then Exit(E_PLUGIN_BAD_ARGS);
            AdoConn.LoginPrompt := false;
            AdoConn.ConnectConnStr(DBConnStr);
          except
            Exit(E_PLUGIN_CONN_FAIL);
          end;
          AdoConn.ExecSQL('create or alter view '+TempTableName(GUID_2, 'SUM_YEARS')+' as ' + #13#10 +
                          'select ' + #13#10 +
                          '    CONVERT(UNIQUEIDENTIFIER, HASHBYTES(''SHA1'', N'''+TempTableName(GUID_2, 'SUM_YEARS')+'''+cast(man.ID as nvarchar(100))+CAST(year(cm.START_DATE) AS NVARCHAR(30)) + CAST(art.IS_ARTIST AS NVARCHAR(1)))) as __ID, ' + #13#10 +
                          '    man.ID as __MANDATOR_ID, ' + #13#10 +
                          '    iif(art.IS_ARTIST=1, ''OUT'', ''IN'') as DIRECTION, ' + #13#10 +
                          '    year(cm.START_DATE) as YEAR, ' + #13#10 +
                          '    count(distinct cm.ID) as COUNT_COMMISSIONS, ' + #13#10 +
                          '    SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0))) as AMOUNT_LOCAL, ' + #13#10 +
                          '    SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0)))/count(distinct cm.ID) as MEAN_SINGLE ' + #13#10 +
                          'from vw_COMMISSION cm ' + #13#10 +
                          'left join COMMISSION_EVENT ev on ev.COMMISSION_ID = cm.ID ' + #13#10 +
                          'left join QUOTE q on q.EVENT_ID = ev.ID and ev.STATE = ''quote'' ' + #13#10 +
                          'left join ARTIST art on art.ID = cm.ARTIST_ID ' + #13#10 +
                          'left join MANDATOR man on man.ID = art.MANDATOR_ID ' + #13#10 +
                          'where not (cm.ART_STATUS = ''idea'' or cm.ART_STATUS = ''postponed'' or cm.ART_STATUS like ''cancel %'' or cm.ART_STATUS = ''c td initcm'' or cm.ART_STATUS = ''rejected'') and art.IS_ARTIST = 1 ' + #13#10 +
                          'group by man.ID, year(cm.START_DATE), art.IS_ARTIST');
        finally
          FreeAndNil(AdoConn);
        end;
        Response.Handled := true;
        Response.Action := craStatistics;
        Response.StatId := StatGuid;
        Response.StatName := 'Local sum over years';
        Response.SqlTable := TempTableName(GUID_2, 'SUM_YEARS');
        Response.SqlInitialOrder := 'YEAR desc, DIRECTION';
        Response.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
        Response.BaseTableDelete := '';
      end
      else
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          try
            if DBConnStr = '' then Exit(E_PLUGIN_BAD_ARGS);
            AdoConn.LoginPrompt := false;
            AdoConn.ConnectConnStr(DBConnStr);
          except
            Exit(E_PLUGIN_CONN_FAIL);
          end;
          AdoConn.ExecSQL('create or alter view '+TempTableName(GUID_2A, 'COMMISSIONS')+' as ' + #13#10 +
                          'select MANDATOR_ID as __MANDATOR_ID, ' + #13#10 +
                          '       ID as __ID, ' + #13#10 +
                          'iif(IS_ARTIST=1,''OUT'',''IN'') as __DIRECTION, ' + #13#10 +
                          'PROJECT_NAME, START_DATE, END_DATE, ART_STATUS, PAY_STATUS, UPLOAD_A, UPLOAD_C, AMOUNT_LOCAL ' + #13#10 +
                          'from vw_COMMISSION');
          q := AdoConn.GetTable('select DIRECTION, YEAR from '+TempTableName(GUID_2, 'SUM_YEARS')+' where __ID = '''+ItemGuid.ToString+'''');
          try
            if not q.Eof then
            begin
              Response.Handled := true;
              Response.Action := craStatistics;
              Response.StatId := GUID_2A;
              Response.StatName := 'Commissions ('+q.FieldByName('DIRECTION').AsWideString+') for year ' + q.FieldByName('YEAR').AsWideString;
              Response.SqlTable := TempTableName(GUID_2A, 'COMMISSIONS');
              Response.SqlInitialOrder := 'START_DATE';
              Response.SqlAdditionalFilter := '__DIRECTION='''+q.FieldByName('DIRECTION').AsWideString+''' and year(START_DATE)='+q.FieldByName('YEAR').AsWideString+' and __MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
              Response.BaseTableDelete := 'COMMISSION';
            end;
          finally
            FreeAndNil(q);
          end;
        finally
          FreeAndNil(AdoConn);
        end;
      end;
    end
    else if IsEqualGuid(StatGuid, GUID_2A) then
    begin
      Response.Handled := true;
      Response.Action := craObject;
      Response.ObjTable := 'COMMISSION';
      Response.ObjId := ItemGuid;
    end
    {$ENDREGION}
    {$REGION 'Stat: Local sum over months'}
    else if IsEqualGuid(StatGuid, GUID_3) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          try
            if DBConnStr = '' then Exit(E_PLUGIN_BAD_ARGS);
            AdoConn.LoginPrompt := false;
            AdoConn.ConnectConnStr(DBConnStr);
          except
            Exit(E_PLUGIN_CONN_FAIL);
          end;
          AdoConn.ExecSQL('create or alter view '+TempTableName(GUID_3, 'SUM_MONTHS')+' as ' + #13#10 +
                          'select ' + #13#10 +
                          '    CONVERT(UNIQUEIDENTIFIER, HASHBYTES(''SHA1'', N'''+TempTableName(GUID_3, 'SUM_MONTHS')+'''+cast(man.ID as nvarchar(100))+CAST(year(cm.START_DATE) AS NVARCHAR(30))+CAST(month(cm.START_DATE) AS NVARCHAR(30)) + CAST(art.IS_ARTIST AS NVARCHAR(1)))) as __ID, ' + #13#10 +
                          '    man.ID as __MANDATOR_ID, ' + #13#10 +
                          '    iif(art.IS_ARTIST=1, ''OUT'', ''IN'') as DIRECTION, ' + #13#10 +
                          '    cast(cast(year(cm.START_DATE) as nvarchar(4)) + ''-'' + REPLICATE(''0'',2-LEN(month(cm.START_DATE))) + cast(month(cm.START_DATE) as nvarchar(2)) as nvarchar(7)) as MONTH, ' + #13#10 +
                          '    count(distinct cm.ID) as COUNT_COMMISSIONS, ' + #13#10 +
                          '    SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0))) as AMOUNT_LOCAL, ' + #13#10 +
                          '    SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0)))/count(distinct cm.ID) as MEAN_SINGLE ' + #13#10 +
                          'from vw_COMMISSION cm ' + #13#10 +
                          'left join COMMISSION_EVENT ev on ev.COMMISSION_ID = cm.ID ' + #13#10 +
                          'left join QUOTE q on q.EVENT_ID = ev.ID and ev.STATE = ''quote'' ' + #13#10 +
                          'left join ARTIST art on art.ID = cm.ARTIST_ID ' + #13#10 +
                          'left join MANDATOR man on man.ID = art.MANDATOR_ID ' + #13#10 +
                          'where not (cm.ART_STATUS = ''idea'' or cm.ART_STATUS = ''postponed'' or cm.ART_STATUS like ''cancel %'' or cm.ART_STATUS = ''c td initcm'' or cm.ART_STATUS = ''rejected'') and art.IS_ARTIST = 1 ' + #13#10 +
                          'group by man.ID, year(cm.START_DATE), month(cm.START_DATE), art.IS_ARTIST');
        finally
          FreeAndNil(AdoConn);
        end;
        Response.Handled := true;
        Response.Action := craStatistics;
        Response.StatId := StatGuid;
        Response.StatName := 'Local sum over months';
        Response.SqlTable := TempTableName(GUID_3, 'SUM_MONTHS');
        Response.SqlInitialOrder := 'MONTH desc, DIRECTION';
        Response.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
        Response.BaseTableDelete := '';
      end
      else
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          try
            if DBConnStr = '' then Exit(E_PLUGIN_BAD_ARGS);
            AdoConn.LoginPrompt := false;
            AdoConn.ConnectConnStr(DBConnStr);
          except
            Exit(E_PLUGIN_CONN_FAIL);
          end;
          AdoConn.ExecSQL('create or alter view '+TempTableName(GUID_3A, 'COMMISSIONS')+' as ' + #13#10 +
                          'select MANDATOR_ID as __MANDATOR_ID, ' + #13#10 +
                          '       ID as __ID, ' + #13#10 +
                          'iif(IS_ARTIST=1,''OUT'',''IN'') as __DIRECTION, ' + #13#10 +
                          'PROJECT_NAME, START_DATE, END_DATE, ART_STATUS, PAY_STATUS, UPLOAD_A, UPLOAD_C, AMOUNT_LOCAL ' + #13#10 +
                          'from vw_COMMISSION');
          q := AdoConn.GetTable('select DIRECTION, MONTH from '+TempTableName(GUID_3, 'SUM_MONTHS')+' where __ID = '''+ItemGuid.ToString+'''');
          try
            if not q.Eof then
            begin
              Response.Handled := true;
              Response.Action := craStatistics;
              Response.StatId := GUID_3A;
              Response.StatName := 'Commissions ('+q.FieldByName('DIRECTION').AsWideString+') for month ' + q.FieldByName('MONTH').AsWideString;
              Response.SqlTable := TempTableName(GUID_3A, 'COMMISSIONS');
              Response.SqlInitialOrder := 'START_DATE';
              Response.SqlAdditionalFilter := '__DIRECTION='''+q.FieldByName('DIRECTION').AsWideString+''' and cast(cast(year(START_DATE) as nvarchar(4)) + ''-'' + REPLICATE(''0'',2-LEN(month(START_DATE))) + cast(month(START_DATE) as nvarchar(2)) as nvarchar(7)) = '''+q.FieldByName('MONTH').AsWideString+''' and __MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
              Response.BaseTableDelete := 'COMMISSION';
            end;
          finally
            FreeAndNil(q);
          end;
        finally
          FreeAndNil(AdoConn);
        end;
      end;
    end
    else if IsEqualGuid(StatGuid, GUID_3A) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        // Nothing here.
      end
      else
      begin
        Response.Handled := true;
        Response.Action := craObject;
        Response.ObjTable := 'COMMISSION';
        Response.ObjId := ItemGuid;
      end;
    end
    {$ENDREGION}
    {$REGION 'Stat: Waiting List'}
    else if IsEqualGuid(StatGuid, GUID_5) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          try
            if DBConnStr = '' then Exit(E_PLUGIN_BAD_ARGS);
            AdoConn.LoginPrompt := false;
            AdoConn.ConnectConnStr(DBConnStr);
          except
            Exit(E_PLUGIN_CONN_FAIL);
          end;
          AdoConn.ExecSQL('create or alter view '+TempTableName(GUID_5, 'WAIT_LIST')+' as ' + #13#10 +
                          {$REGION 'Art status'}
                          'select ' + #13#10 +
                          '    cm.MANDATOR_ID as __MANDATOR_ID, ' + #13#10 +
                          '    cm.ID as __ID, ' + #13#10 +
                          '    N''Art: '' + cm.ART_STATUS as TASK, ' + #13#10 +
                          '    cm.PROJECT_NAME as SUBJECT ' + #13#10 +
                          'from vw_COMMISSION cm ' + #13#10 +
                          'where ' + #13#10 +
                          '-- I am the artist (the other person is the customer) and I wait for the customer ' + #13#10 +
                          '((cm.IS_ARTIST = 0) and (cm.ART_STATUS like ''c td %'')) or ' + #13#10 +
                          '-- I am the customer (the other person is the artist) and I wait for the artist ' + #13#10 +
                          '((cm.IS_ARTIST = 1) and (cm.ART_STATUS like ''c aw %'')) ' + #13#10 +
                          {$ENDREGION}
                          ' ' + #13#10 +
                          'union ' + #13#10 +
                          ' ' + #13#10 +
                          {$REGION 'Pay status'}
                          'select ' + #13#10 +
                          '    art.MANDATOR_ID as __MANDATOR_ID, ' + #13#10 +
                          '    art.ID as ID__, ' + #13#10 +
                          '    N''Payment: '' + art.PAY_STATUS as TASK, ' + #13#10 +
                          '    art.NAME + IIF(art.IS_ARTIST=1, N'' (Artist)'', N'' (Client)'') as SUBJECT ' + #13#10 +
                          'from vw_ARTIST art ' + #13#10 +
                          'where ' + #13#10 +
                          '-- I am the artist (the other person is the customer) and the customer has a debt (so I wait for their payment) ' + #13#10 +
                          '(art.IS_ARTIST = 0 and art.PAY_STATUS like ''%DEBT%'') or ' + #13#10 +
                          '-- I am the customer (the other person is the artist) and the artist owes me art or money (so I wait for art or refund) ' + #13#10 +
                          '(art.IS_ARTIST = 1 and art.PAY_STATUS like ''%CREDIT%'') ' + #13#10 +
                          {$ENDREGION}
                          ' ' + #13#10 +
                          'union ' + #13#10 +
                          ' ' + #13#10 +
                          {$REGION 'Upload status'}
                          'select ' + #13#10 +
                          '    MANDATOR_ID as __MANDATOR_ID, ' + #13#10 +
                          '    ID as ID__, ' + #13#10 +
                          '    iif(IS_ARTIST=1, N''Upload by Artist (them)'', N''Upload by Client (them)'') as TASK, ' + #13#10 +
                          '    PROJECT_NAME as SUBJECT ' + #13#10 +
                          'from vw_COMMISSION ' + #13#10 +
                          'where ' + #13#10 +
                          '-- I am the customer and wait for the artist to upload the artwork ' + #13#10 +
                          '(IS_ARTIST = 1 and UPLOAD_A = ''No'') or ' + #13#10 +
                          '-- I am the artist and wait for the cutomer to upload the artwork ' + #13#10 +
                          '(IS_ARTIST = 0 and UPLOAD_C = ''No'')');
                          {$ENDREGION}
        finally
          FreeAndNil(AdoConn);
        end;
        Response.Handled := true;
        Response.Action := craStatistics;
        Response.StatId := StatGuid;
        Response.StatName := 'Things I am waiting for (Art, Payment, Upload)';
        Response.SqlTable := TempTableName(GUID_5, 'WAIT_LIST');
        Response.SqlInitialOrder := 'TASK, SUBJECT';
        Response.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
        Response.BaseTableDelete := ''; // not possible, because there are multiple base items
      end
      else
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          try
            if DBConnStr = '' then Exit(E_PLUGIN_BAD_ARGS);
            AdoConn.LoginPrompt := false;
            AdoConn.ConnectConnStr(DBConnStr);
            if AdoConn.GetScalar('select count(*) from COMMISSION where ID = ''' + ItemGuid.ToString + '''') > 0 then
            begin
              Response.Handled := true;
              Response.Action := craObject;
              Response.ObjTable := 'COMMISSION';
              Response.ObjId := ItemGuid;
            end
            else if AdoConn.GetScalar('select count(*) from ARTIST where ID = ''' + ItemGuid.ToString + '''') > 0 then
            begin
              Response.Handled := true;
              Response.Action := craObject;
              Response.ObjTable := 'ARTIST';
              Response.ObjId := ItemGuid;
            end
            else
            begin
              Response.Handled := false;
            end;
          except
            Exit(E_PLUGIN_CONN_FAIL);
          end;
        finally
          FreeAndNil(AdoConn);
        end;
      end;
    end
    {$ENDREGION}
    {$REGION 'Stat: To Do List'}
    else if IsEqualGuid(StatGuid, GUID_6) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          try
            if DBConnStr = '' then Exit(E_PLUGIN_BAD_ARGS);
            AdoConn.LoginPrompt := false;
            AdoConn.ConnectConnStr(DBConnStr);
          except
            Exit(E_PLUGIN_CONN_FAIL);
          end;
          AdoConn.ExecSQL('create or alter view '+TempTableName(GUID_6, 'TODO_LIST')+' as ' + #13#10 +
                          {$REGION 'Art status'}
                          'select ' + #13#10 +
                          '    cm.MANDATOR_ID as __MANDATOR_ID, ' + #13#10 +
                          '    cm.ID as __ID, ' + #13#10 +
                          '    N''Art: '' + cm.ART_STATUS as TASK, ' + #13#10 +
                          '    cm.PROJECT_NAME as SUBJECT ' + #13#10 +
                          'from vw_COMMISSION cm ' + #13#10 +
                          'where ' + #13#10 +
                          '-- I am the artist (the other person is the customer) and the customer waits for me ' + #13#10 +
                          '((cm.IS_ARTIST = 0) and (cm.ART_STATUS like ''c aw %'')) or ' + #13#10 +
                          '-- I am the customer (the other person is the artist) and the artist waits for me ' + #13#10 +
                          '((cm.IS_ARTIST = 1) and (cm.ART_STATUS like ''c td %'')) ' + #13#10 +
                          {$ENDREGION}
                          ' ' + #13#10 +
                          'union ' + #13#10 +
                          ' ' + #13#10 +
                          {$REGION 'Pay status'}
                          'select ' + #13#10 +
                          '    art.MANDATOR_ID as __MANDATOR_ID, ' + #13#10 +
                          '    art.ID as ID__, ' + #13#10 +
                          '    N''Payment: '' + art.PAY_STATUS as TASK, ' + #13#10 +
                          '    art.NAME + IIF(art.IS_ARTIST=1, N'' (Artist)'', N'' (Client)'') as SUBJECT ' + #13#10 +
                          'from vw_ARTIST art ' + #13#10 +
                          'where ' + #13#10 +
                          '-- I am the artist (the other person is the customer) and the customer has a credit (so I need to refund or deliver art) ' + #13#10 +
                          '(art.IS_ARTIST = 0 and art.PAY_STATUS like ''%CREDIT%'') or ' + #13#10 +
                          '-- I am the customer (the other person is the artist) and owe the artist money (so I need to pay) ' + #13#10 +
                          '(art.IS_ARTIST = 1 and art.PAY_STATUS like ''%DEBT%'') ' + #13#10 +
                          {$ENDREGION}
                          ' ' + #13#10 +
                          'union ' + #13#10 +
                          ' ' + #13#10 +
                          {$REGION 'Upload status'}
                          'select ' + #13#10 +
                          '    MANDATOR_ID as __MANDATOR_ID, ' + #13#10 +
                          '    ID as ID__, ' + #13#10 +
                          '    iif(IS_ARTIST=1, N''Upload by Customer (me)'', N''Upload by Artist (me)'') as TASK, ' + #13#10 +
                          '    PROJECT_NAME as SUBJECT ' + #13#10 +
                          'from vw_COMMISSION ' + #13#10 +
                          'where ' + #13#10 +
                          '-- I am the customer and need to upload the art ' + #13#10 +
                          '(IS_ARTIST = 1 and UPLOAD_C = ''No'') or ' + #13#10 +
                          '-- I am the artist and need to upload the art ' + #13#10 +
                          '(IS_ARTIST = 0 and UPLOAD_A = ''No'')');
                          {$ENDREGION}
        finally
          FreeAndNil(AdoConn);
        end;
        Response.Handled := true;
        Response.Action := craStatistics;
        Response.StatId := StatGuid;
        Response.StatName := 'Things I need to do (Art, Payment, Upload)';
        Response.SqlTable := TempTableName(GUID_6, 'TODO_LIST');
        Response.SqlInitialOrder := 'TASK, SUBJECT';
        Response.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
        Response.BaseTableDelete := ''; // not possible, because there are multiple base items
      end
      else
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          try
            if DBConnStr = '' then Exit(E_PLUGIN_BAD_ARGS);
            AdoConn.LoginPrompt := false;
            AdoConn.ConnectConnStr(DBConnStr);
            if AdoConn.GetScalar('select count(*) from COMMISSION where ID = ''' + ItemGuid.ToString + '''') > 0 then
            begin
              Response.Handled := true;
              Response.Action := craObject;
              Response.ObjTable := 'COMMISSION';
              Response.ObjId := ItemGuid;
            end
            else if AdoConn.GetScalar('select count(*) from ARTIST where ID = ''' + ItemGuid.ToString + '''') > 0 then
            begin
              Response.Handled := true;
              Response.Action := craObject;
              Response.ObjTable := 'ARTIST';
              Response.ObjId := ItemGuid;
            end
            else
            begin
              Response.Handled := false;
            end;
          except
            Exit(E_PLUGIN_CONN_FAIL);
          end;
        finally
          FreeAndNil(AdoConn);
        end;
      end;
    end
    {$ENDREGION}
    {$REGION 'Stat: Top artists/clients'}
    else if IsEqualGuid(StatGuid, GUID_4) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          try
            if DBConnStr = '' then Exit(E_PLUGIN_BAD_ARGS);
            AdoConn.LoginPrompt := false;
            AdoConn.ConnectConnStr(DBConnStr);
          except
            Exit(E_PLUGIN_CONN_FAIL);
          end;
          AdoConn.ExecSQL('create or alter view '+TempTableName(GUID_4, 'SUM_MONTHS')+' as ' + #13#10 +
                          'select ' + #13#10 +
                          '    man.ID as __MANDATOR_ID, ' + #13#10 +
                          '    art.NAME as ARTISTNAME, ' + #13#10 +
                          '    art.ID as __ID, ' + #13#10 +
                          '    count(distinct cm.ID) as COUNT_COMMISSIONS, ' + #13#10 +
                          '    SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0))) as AMOUNT_LOCAL, ' + #13#10 +
                          '    SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0)))/count(distinct cm.ID) as MEAN_SINGLE ' + #13#10 +
                          'from vw_COMMISSION cm ' + #13#10 +
                          'left join COMMISSION_EVENT ev on ev.COMMISSION_ID = cm.ID ' + #13#10 +
                          'left join QUOTE q on q.EVENT_ID = ev.ID and ev.STATE = ''quote'' ' + #13#10 +
                          'left join ARTIST art on art.ID = cm.ARTIST_ID ' + #13#10 +
                          'left join MANDATOR man on man.ID = art.MANDATOR_ID ' + #13#10 +
                          'where not (cm.ART_STATUS = ''idea'' or cm.ART_STATUS = ''postponed'' or cm.ART_STATUS like ''cancel %'' or cm.ART_STATUS = ''c td initcm'' or cm.ART_STATUS = ''rejected'') ' + #13#10 +
                          'group by man.ID, art.ID, art.NAME');
        finally
          FreeAndNil(AdoConn);
        end;
        Response.Handled := true;
        Response.Action := craStatistics;
        Response.StatId := StatGuid;
        Response.StatName := 'Top artists/clients';
        Response.SqlTable := TempTableName(GUID_4, 'SUM_MONTHS');
        Response.SqlInitialOrder := 'COUNT_COMMISSIONS desc, AMOUNT_LOCAL desc';
        Response.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
        Response.BaseTableDelete := 'ARTIST';
      end
      else
      begin
        Response.Handled := true;
        Response.Action := craObject;
        Response.ObjTable := 'ARTIST';
        Response.ObjId := ItemGuid;
      end;
    end;
    {$ENDREGION}

    Response.WriteToMemory(ResponseData);
    result := S_PLUGIN_OK;
  except
    Exit(E_PLUGIN_GENERIC_FAILURE);
  end;
end;

exports
  VtsPluginID, InitW, ClickEventW;

begin
end.
