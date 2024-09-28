unit CmDbPluginClient;

interface

uses
  SysUtils, ADODb, AdoConnHelper;

type
  TCmDbPluginClickResponseAction = (craNone, craObject, craStatistics);

type
  TCmDbPluginClickResponse = record
    Handled: boolean;
    Action: TCmDbPluginClickResponseAction;
    // Normal object, for Action=CraObject
    ObjTable: string[100];
    ObjId: TGuid;
    // Statistics, for Action=craStatistics
    StatId: TGuid;
    StatName: string[100];
    SqlTable: string[100];
    SqlInitialOrder: string[250];
    SqlAdditionalFilter: string[250];
    BaseTableDelete: string[100];
  end;

type
  TCmDbPluginClient = class(TObject)
  public
    class procedure CreateTables(AdoConn: TAdoConnection);
    class procedure InitAllPlugins(AdoConn: TAdoConnection);
    class function ClickEvent(AdoConn: TAdoConnection; MandatorGuid, StatGuid, ItemGuid: TGuid): TCmDbPluginClickResponse;
  end;

type
  TCmDbPlugin = class(TObject)
  private
    FPluginDllFilename: string;
  public
    procedure Init(const DBConnStr: string);
    function ClickEvent(const DBConnStr: string; MandatorGuid, StatGuid, ItemGuid: TGuid): TCmDbPluginClickResponse;
    constructor Create(const APluginDllFilename: string);
  end;

procedure HandleClickResponse(AdoConn: TAdoConnection; MandatorId: TGUID; resp: TCmDbPluginClickResponse);

const
  GUID_NIL: TGUID = '{00000000-0000-0000-0000-000000000000}';

implementation

uses
  Forms, Statistics, CmDbMain, CmDbFunctions;

procedure HandleClickResponse(AdoConn: TAdoConnection; MandatorId: TGUID; resp: TCmDbPluginClickResponse);
var
  StatisticsForm: TStatisticsForm;
  addinfo1: string;
begin
  if not resp.Handled then exit;
  if resp.Action = craObject then
  begin
    MainForm.OpenDbObject(resp.ObjTable, resp.ObjId);
  end
  else if resp.Action = craStatistics then
  begin
    addinfo1 := TStatisticsForm.AddInfo(mandatorid, resp.SqlTable, resp.SqlInitialOrder, resp.SqlAdditionalFilter);
    StatisticsForm := MainForm.FindForm(resp.StatId, addinfo1) as TStatisticsForm;
    if Assigned(StatisticsForm) then
    begin
      MainForm.RestoreMdiChild(StatisticsForm);
    end
    else
    begin
      StatisticsForm := TStatisticsForm.Create(Application.MainForm);
      StatisticsForm.StatisticsId := resp.StatId;
      StatisticsForm.StatisticsName := resp.StatName;
      StatisticsForm.SqlTable := resp.SqlTable;
      StatisticsForm.SqlInitialOrder := resp.SqlInitialOrder;
      StatisticsForm.SqlAdditionalFilter := resp.SqlAdditionalFilter;
      StatisticsForm.BaseTableDelete := resp.BaseTableDelete;
      StatisticsForm.MandatorId := MandatorId;
      StatisticsForm.ADOConnection1.Connected := false;
      StatisticsForm.ADOConnection1.ConnectionString := AdoConn.ConnectionString;
      StatisticsForm.Init;
    end;
  end;
end;

{ TCmDbPlugin }

const
  GUID_1: TGUID = '{6F7E0568-3612-4BD0-BEA6-B23560A5F594}';
  GUID_2: TGUID = '{08F3D4C0-8DBD-4F3E-8891-241858779E49}';
  GUID_2A: TGUID = '{8B46FC53-21E8-4E8C-AB60-AC9811B8D8B4}';
  GUID_3: TGUID = '{2A7F1225-08A6-4B55-9EF7-75C7933DFBCA}';
  GUID_3A: TGUID = '{804E25DD-5756-47E8-9727-5849DCF63E32}';
  GUID_4: TGUID = '{636CD096-DB61-4ECF-BA79-00445AEB8798}';

  GUID_9: TGUID = '{4DCE53CA-8744-408C-ABA8-3702DCC9C51E}';
  GUID_9A: TGUID = '{AC6FE7BE-91CD-43D0-9971-C6229C3F596D}';
  GUID_9B: TGUID = '{5FF02681-8A21-4218-B1D2-38ECC9827CD2}';

function TCmDbPlugin.ClickEvent(const DBConnStr: string; MandatorGuid,
  StatGuid, ItemGuid: TGuid): TCmDbPluginClickResponse;
var
  AdoConn: TADOConnection;
  q: TADODataSet;
begin
  // TODO: Call DLL instead
  Result.Handled := false;
  if FPluginDllFilename = 'PLG_STD_STAT.DLL' then
  begin
    {$REGION 'Stat: Running commissions'}
    if IsEqualGuid(StatGuid, GUID_1) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          AdoConn.LoginPrompt := false;
          AdoConn.ConnectConnStr(DBConnStr);
          AdoConn.ExecSQL('create or alter view '+TempTableName(GUID_1, 'RUNNING_COMMISSIONS')+' as ' + #13#10 +
                          'select man.ID as __MANDATOR_ID, case ' + #13#10 +
                          '	when cm.ART_STATUS = ''c aw ack'' then 1 ' + #13#10 +
                          '	when cm.ART_STATUS = ''ack'' then 2 ' + #13#10 +
                          '	when cm.ART_STATUS = ''c aw sk'' then 3 ' + #13#10 +
                          '	when cm.ART_STATUS = ''c td feedback'' then 4 ' + #13#10 +
                          '	when cm.ART_STATUS = ''c aw cont'' then 5 ' + #13#10 +
                          '	when cm.ART_STATUS = ''c aw hires'' then 6 ' + #13#10 +
                          '	else 7 ' + #13#10 +
                          'end as __STATUS_ORDER, cm.ART_STATUS, art.NAME as ARTIST, cm.NAME, cm.ID as __ID, ' + #13#10 +
                          '    CASE ' + #13#10 +
                          '        WHEN CHARINDEX(''\'', cm.FOLDER) > 0 THEN RIGHT(cm.FOLDER, CHARINDEX(''\'', REVERSE(cm.FOLDER)) - 1) ' + #13#10 +
                          '        ELSE cm.FOLDER ' + #13#10 +
                          '    END AS FOLDER ' + #13#10 +
                          'from vw_COMMISSION cm ' + #13#10 +
                          'left join ARTIST art on art.ID = cm.ARTIST_ID ' + #13#10 +
                          'left join MANDATOR man on man.ID = art.MANDATOR_ID ' + #13#10 +
                          'where not (cm.ART_STATUS = ''fin'' or cm.ART_STATUS = ''idea'' or cm.ART_STATUS = ''postponed'' or cm.ART_STATUS like ''cancel %'' or cm.ART_STATUS = ''c td initcm'' or cm.ART_STATUS = ''rejected'')');
        finally
          FreeAndNil(AdoConn);
        end;
        result.Handled := true;
        result.Action := craStatistics;
        result.StatId := StatGuid;
        result.StatName := 'Running commissions';
        result.SqlTable := TempTableName(GUID_1, 'RUNNING_COMMISSIONS');
        result.SqlInitialOrder := '__STATUS_ORDER, ART_STATUS, FOLDER';
        result.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
        result.BaseTableDelete := 'COMMISSION';
      end
      else
      begin
        result.Handled := true;
        result.Action := craObject;
        result.ObjTable := 'COMMISSION';
        result.ObjId := ItemGuid;
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
          AdoConn.LoginPrompt := false;
          AdoConn.ConnectConnStr(DBConnStr);
          AdoConn.ExecSQL('create or alter view '+TempTableName(GUID_2, 'SUM_YEARS')+' as ' + #13#10 +
                          'select ' + #13#10 +
                          '	CONVERT(UNIQUEIDENTIFIER, HASHBYTES(''SHA1'', N'''+TempTableName(GUID_2, 'SUM_YEARS')+'''+cast(man.ID as nvarchar(100))+CAST(year(cm.START_DATE) AS NVARCHAR(30)) + CAST(art.IS_ARTIST AS NVARCHAR(1)))) as __ID, ' + #13#10 +
                          '	man.ID as __MANDATOR_ID, ' + #13#10 +
                          '	iif(art.IS_ARTIST=1, ''OUT'', ''IN'') as DIRECTION, ' + #13#10 +
                          '	year(cm.START_DATE) as YEAR, ' + #13#10 +
                          '	count(distinct cm.ID) as COUNT_COMMISSIONS, ' + #13#10 +
                          '	SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0))) as AMOUNT_LOCAL, ' + #13#10 +
                          '	SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0)))/count(distinct cm.ID) as MEAN_SINGLE ' + #13#10 +
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
        result.Handled := true;
        result.Action := craStatistics;
        result.StatId := StatGuid;
        result.StatName := 'Local sum over years';
        result.SqlTable := TempTableName(GUID_2, 'SUM_YEARS');
        result.SqlInitialOrder := 'YEAR desc, DIRECTION';
        result.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
        result.BaseTableDelete := '';
      end
      else
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          AdoConn.LoginPrompt := false;
          AdoConn.ConnectConnStr(DBConnStr);
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
              result.Handled := true;
              result.Action := craStatistics;
              result.StatId := GUID_2A;
              result.StatName := 'Commissions ('+q.FieldByName('DIRECTION').AsWideString+') for year ' + q.FieldByName('YEAR').AsWideString;
              result.SqlTable := TempTableName(GUID_2A, 'COMMISSIONS');
              result.SqlInitialOrder := 'START_DATE';
              result.SqlAdditionalFilter := '__DIRECTION='''+q.FieldByName('DIRECTION').AsWideString+''' and year(START_DATE)='+q.FieldByName('YEAR').AsWideString+' and __MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
              result.BaseTableDelete := 'COMMISSION';
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
      result.Handled := true;
      result.Action := craObject;
      result.ObjTable := 'COMMISSION';
      result.ObjId := ItemGuid;
    end
    {$ENDREGION}
    {$REGION 'Stat: Local sum over months'}
    else if IsEqualGuid(StatGuid, GUID_3) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          AdoConn.LoginPrompt := false;
          AdoConn.ConnectConnStr(DBConnStr);
          AdoConn.ExecSQL('create or alter view '+TempTableName(GUID_3, 'SUM_MONTHS')+' as ' + #13#10 +
                          'select ' + #13#10 +
                          '	CONVERT(UNIQUEIDENTIFIER, HASHBYTES(''SHA1'', N'''+TempTableName(GUID_3, 'SUM_MONTHS')+'''+cast(man.ID as nvarchar(100))+CAST(year(cm.START_DATE) AS NVARCHAR(30))+CAST(month(cm.START_DATE) AS NVARCHAR(30)) + CAST(art.IS_ARTIST AS NVARCHAR(1)))) as __ID, ' + #13#10 +
                          '	man.ID as __MANDATOR_ID, ' + #13#10 +
                          '	iif(art.IS_ARTIST=1, ''OUT'', ''IN'') as DIRECTION, ' + #13#10 +
                          '	cast(cast(year(cm.START_DATE) as nvarchar(4)) + ''-'' + REPLICATE(''0'',2-LEN(month(cm.START_DATE))) + cast(month(cm.START_DATE) as nvarchar(2)) as nvarchar(7)) as MONTH, ' + #13#10 +
                          '	count(distinct cm.ID) as COUNT_COMMISSIONS, ' + #13#10 +
                          '	SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0))) as AMOUNT_LOCAL, ' + #13#10 +
                          '	SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0)))/count(distinct cm.ID) as MEAN_SINGLE ' + #13#10 +
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
        result.Handled := true;
        result.Action := craStatistics;
        result.StatId := StatGuid;
        result.StatName := 'Local sum over months';
        result.SqlTable := TempTableName(GUID_3, 'SUM_MONTHS');
        result.SqlInitialOrder := 'MONTH desc, DIRECTION';
        result.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
        result.BaseTableDelete := '';
      end
      else
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          AdoConn.LoginPrompt := false;
          AdoConn.ConnectConnStr(DBConnStr);
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
              result.Handled := true;
              result.Action := craStatistics;
              result.StatId := GUID_3A;
              result.StatName := 'Commissions ('+q.FieldByName('DIRECTION').AsWideString+') for month ' + q.FieldByName('MONTH').AsWideString;
              result.SqlTable := TempTableName(GUID_3A, 'COMMISSIONS');
              result.SqlInitialOrder := 'START_DATE';
              result.SqlAdditionalFilter := '__DIRECTION='''+q.FieldByName('DIRECTION').AsWideString+''' and cast(cast(year(START_DATE) as nvarchar(4)) + ''-'' + REPLICATE(''0'',2-LEN(month(START_DATE))) + cast(month(START_DATE) as nvarchar(2)) as nvarchar(7)) = '''+q.FieldByName('MONTH').AsWideString+''' and __MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
              result.BaseTableDelete := 'COMMISSION';
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
        result.Handled := true;
        result.Action := craObject;
        result.ObjTable := 'COMMISSION';
        result.ObjId := ItemGuid;
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
          AdoConn.LoginPrompt := false;
          AdoConn.ConnectConnStr(DBConnStr);
          AdoConn.ExecSQL('create or alter view '+TempTableName(GUID_4, 'SUM_MONTHS')+' as ' + #13#10 +
                          'select ' + #13#10 +
                          '	man.ID as __MANDATOR_ID, art.NAME as ARTISTNAME, ' + #13#10 +
                          '	art.ID as __ID, ' + #13#10 +
                          '	count(distinct cm.ID) as COUNT_COMMISSIONS, ' + #13#10 +
                          '	SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0))) as AMOUNT_LOCAL, ' + #13#10 +
                          '	SUM(isnull(nullif(q.AMOUNT_LOCAL,0),isnull(q.AMOUNT,0)))/count(distinct cm.ID) as MEAN_SINGLE ' + #13#10 +
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
        result.Handled := true;
        result.Action := craStatistics;
        result.StatId := StatGuid;
        result.StatName := 'Top artists/clients';
        result.SqlTable := TempTableName(GUID_4, 'SUM_MONTHS');
        result.SqlInitialOrder := 'COUNT_COMMISSIONS desc, AMOUNT_LOCAL desc';
        result.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
        result.BaseTableDelete := 'ARTIST';
      end
      else
      begin
        result.Handled := true;
        result.Action := craObject;
        result.ObjTable := 'ARTIST';
        result.ObjId := ItemGuid;
      end;
    end
    {$ENDREGION}
    {$REGION 'Test menu plugin'}
    else if IsEqualGuid(StatGuid, GUID_9) then
    begin
      // This is an example for creating a plugin that outputs a "menu" with custom actions (which can be anything!)
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          AdoConn.LoginPrompt := false;
          AdoConn.ConnectConnStr(DBConnStr);
          if not AdoConn.TableExists('##xx_about') then
            AdoConn.ExecSQL('create table ##xx_about ( __ID uniqueidentifier NOT NULL, NAME varchar(200) NOT NULL );');
          AdoConn.ExecSQL('delete from ##xx_about');
          AdoConn.ExecSQL('insert into ##xx_about select '''+GUID_9A.ToString+''', ''View Source Code'';');
          AdoConn.ExecSQL('insert into ##xx_about select '''+GUID_9B.ToString+''', ''Download latest version'';');
        finally
          // TODO: temp table gets deleted here!
//          FreeAndNil(AdoConn);
        end;

        result.Handled := true;
        result.Action := craStatistics;
        result.StatId := StatGuid;
        result.StatName := 'About CMDB2';
        result.SqlTable := '##xx_about';
        result.SqlInitialOrder := '';
        result.SqlAdditionalFilter := '';
        result.BaseTableDelete := '';
      end
      else if IsEqualGUID(ItemGuid, GUID_9A) then
      begin
        result.Handled := true;
        result.Action := craNone;
        Application.MessageBox('Hello World!', ''); // TODO: test
      end
      else if IsEqualGUID(ItemGuid, GUID_9B) then
      begin
        result.Handled := true;
        result.Action := craNone;
        Application.MessageBox('Hello World 2!', ''); // TODO: test
      end;
    end;
    {$ENDREGION}
  end;
end;

constructor TCmDbPlugin.Create(const APluginDllFilename: string);
begin
  inherited Create;
  FPluginDllFilename := APluginDllFilename;
end;

procedure TCmDbPlugin.Init(const DBConnStr: string);
var
  AdoConn: TAdoConnection;
begin
  // TODO: Call DLL instead
  AdoConn := TAdoConnection.Create(nil);
  try
    AdoConn.LoginPrompt := false;
    AdoConn.ConnectConnStr(DBConnStr);

    if FPluginDllFilename = 'PLG_STD_STAT.DLL' then
    begin
      AdoConn.ExecSQL('insert into [##STATISTICS] (ID, NO, NAME) values ('''+GUID_1.ToString+''', ''50'', ''Running commissions'');');
      AdoConn.ExecSQL('insert into [##STATISTICS] (ID, NO, NAME) values ('''+GUID_2.ToString+''', ''100'', ''Local sum over years'');');
      AdoConn.ExecSQL('insert into [##STATISTICS] (ID, NO, NAME) values ('''+GUID_3.ToString+''', ''101'', ''Local sum over months'');');
      AdoConn.ExecSQL('insert into [##STATISTICS] (ID, NO, NAME) values ('''+GUID_4.ToString+''', ''200'', ''Top artists/clients'');');
      AdoConn.ExecSQL('insert into [##STATISTICS] (ID, NO, NAME) values ('''+GUID_9.ToString+''', ''950'', ''--- About CMDB2 ---'');');
    end;

    AdoConn.Disconnect;
  finally
    AdoConn.Free;
  end;
end;

{ TCmDbPluginClient }

class function TCmDbPluginClient.ClickEvent(AdoConn: TAdoConnection; MandatorGuid,
  StatGuid, ItemGuid: TGuid): TCmDbPluginClickResponse;
var
  p: TCmDbPlugin;
begin
  // TODO: Ask all plugins
  Result.Handled := false;
  p := TCmDbPlugin.Create('PLG_STD_STAT.DLL');
  try
    result := p.ClickEvent(AdoConn.ConnectionString, MandatorGuid, StatGuid, ItemGuid);
    if Result.Handled then Exit;
  finally
    p.Free;
  end;
end;

class procedure TCmDbPluginClient.CreateTables(AdoConn: TAdoConnection);
begin
  AdoConn.ExecSQL('IF NOT EXISTS (SELECT * FROM tempdb.sys.tables WHERE name = ''##STATISTICS'') ' +
                  'BEGIN ' +
                  ' CREATE TABLE [dbo].[##STATISTICS]( ' +
                  ' 	[ID] [uniqueidentifier] NOT NULL, ' +
                  ' 	[NO] [int] NOT NULL, ' +
                  ' 	[NAME] [nvarchar](100) NOT NULL, ' +
                  '  CONSTRAINT [PK_STATISTICS] PRIMARY KEY CLUSTERED ' +
                  ' ( ' +
                  ' 	[ID] ASC ' +
                  ' )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY] ' +
                  ' ) ON [PRIMARY]; ' +
                  'END');
  AdoConn.ExecSQL('delete from ##STATISTICS');
end;

class procedure TCmDbPluginClient.InitAllPlugins(AdoConn: TAdoConnection);
var
  p: TCmDbPlugin;
begin
  // TODO: Iterate all plugins
  p := TCmDbPlugin.Create('PLG_STD_STAT.DLL');
  try
    p.Init(AdoConn.ConnectionString);
  finally
    p.Free;
  end;
end;

end.
