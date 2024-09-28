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
    ObjTable: string[50];
    ObjId: TGuid;
    // Statistics, for Action=craStatistics
    StatId: TGuid;
    StatName: string[100];
    SqlTable: string[50];
    SqlInitialOrder: string[250];
    SqlAdditionalFilter: string[250];
    BaseTableDelete: string[50];
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
  Forms, Statistics, CmDbMain;

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
  GUID_5: TGUID = '{BEBEE253-6644-4A66-87D1-BB63FFAD57B4}';
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
        //InstallSql(..., 'vw_STAT_RUNNING_COMMISSIONS');
        result.Handled := true;
        result.Action := craStatistics;
        result.StatId := StatGuid;
        result.StatName := 'Running commissions';
        result.SqlTable := 'vw_STAT_RUNNING_COMMISSIONS';
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
        //InstallSql(..., 'vw_STAT_SUM_YEARS');
        result.Handled := true;
        result.Action := craStatistics;
        result.StatId := StatGuid;
        result.StatName := 'Local sum over years';
        result.SqlTable := 'vw_STAT_SUM_YEARS';
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
          AdoConn.ExecSQL('create or alter view vw_tmp_COMMISSIONS as select MANDATOR_ID as __MANDATOR_ID, ID as __ID, iif(IS_ARTIST=1,''OUT'',''IN'') as __DIRECTION, PROJECT_NAME, START_DATE, END_DATE, ART_STATUS, PAY_STATUS, UPLOAD_A, UPLOAD_C, AMOUNT_LOCAL from vw_COMMISSION');
          q := AdoConn.GetTable('select DIRECTION, YEAR from vw_STAT_SUM_YEARS where __ID = '''+ItemGuid.ToString+'''');
          try
            if not q.Eof then
            begin
              result.Handled := true;
              result.Action := craStatistics;
              result.StatId := GUID_2A;
              result.StatName := 'Commissions ('+q.FieldByName('DIRECTION').AsString+') for year ' + q.FieldByName('YEAR').AsString;
              result.SqlTable := 'vw_tmp_COMMISSIONS';
              result.SqlInitialOrder := 'START_DATE';
              result.SqlAdditionalFilter := '__DIRECTION='''+q.FieldByName('DIRECTION').AsString+''' and year(START_DATE)='+q.FieldByName('YEAR').AsString+' and __MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
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
        //InstallSql(..., 'vw_STAT_SUM_MONTHS');
        result.Handled := true;
        result.Action := craStatistics;
        result.StatId := StatGuid;
        result.StatName := 'Local sum over months';
        result.SqlTable := 'vw_STAT_SUM_MONTHS';
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
          AdoConn.ExecSQL('create or alter view vw_tmp_COMMISSIONS as select MANDATOR_ID as __MANDATOR_ID, ID as __ID, iif(IS_ARTIST=1,''OUT'',''IN'') as __DIRECTION, PROJECT_NAME, START_DATE, END_DATE, ART_STATUS, PAY_STATUS, UPLOAD_A, UPLOAD_C, AMOUNT_LOCAL from vw_COMMISSION');
          q := AdoConn.GetTable('select DIRECTION, MONTH from vw_STAT_SUM_MONTHS where __ID = '''+ItemGuid.ToString+'''');
          try
            if not q.Eof then
            begin
              result.Handled := true;
              result.Action := craStatistics;
              result.StatId := GUID_3A;
              result.StatName := 'Commissions ('+q.FieldByName('DIRECTION').AsString+') for month ' + q.FieldByName('MONTH').AsString;
              result.SqlTable := 'vw_tmp_COMMISSIONS';
              result.SqlInitialOrder := 'START_DATE';
              result.SqlAdditionalFilter := '__DIRECTION='''+q.FieldByName('DIRECTION').AsString+''' and cast(cast(year(START_DATE) as nvarchar(4)) + ''-'' + REPLICATE(''0'',2-LEN(month(START_DATE))) + cast(month(START_DATE) as nvarchar(2)) as nvarchar(7)) = '''+q.FieldByName('MONTH').AsString+''' and __MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
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
        //InstallSql(..., 'vw_STAT_TOP_ARTISTS');
        result.Handled := true;
        result.Action := craStatistics;
        result.StatId := StatGuid;
        result.StatName := 'Top artists/clients';
        result.SqlTable := 'vw_STAT_TOP_ARTISTS';
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
    {$REGION 'Stat: Full Text Export'}
    else if IsEqualGuid(StatGuid, GUID_5) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        //InstallSql(..., 'vw_STAT_TEXT_EXPORT');
        result.Handled := true;
        result.Action := craStatistics;
        result.StatId := StatGuid;
        result.StatName := 'Full Text Export';
        result.SqlTable := 'vw_STAT_TEXT_EXPORT';
        result.SqlInitialOrder := 'DATASET_TYPE, DATASET_ID';
        result.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
        result.BaseTableDelete := '';
      end
      else
      begin
        // TODO: We could open the data set here... but we need to query all tables to see which tables has the ItemID
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
      AdoConn.ExecSQL('insert into [##STATISTICS] (ID, NO, NAME) values ('''+GUID_5.ToString+''', ''900'', ''Full Text Export'');');
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
