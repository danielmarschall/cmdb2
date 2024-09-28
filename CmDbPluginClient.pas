unit CmDbPluginClient;

interface

uses
  SysUtils, ADODb, AdoConnHelper;

type
  TCmDbPluginClickResponse = record
    Handled: boolean;
    // Statistics
    StatId: TGuid;
    StatName: string;
    SqlTable: string;
    SqlInitialOrder: string;
    // Normal object
    ObjTable: string;
    ObjId: TGuid;
  end;

type
  TCmDbPluginClient = class(TObject)
  public
    class procedure CreateTables(AdoConn: TAdoConnection);
    class procedure InitAllPlugins(AdoConn: TAdoConnection);
    class function ClickEvent(AdoConn: TAdoConnection; StatGuid: TGuid; ItemGuid: TGuid): TCmDbPluginClickResponse;
  end;

type
  TCmDbPlugin = class(TObject)
  private
    FPluginDllFilename: string;
  public
    procedure Init(const DBConnStr: string);
    function ClickEvent(const DBConnStr: string; StatGuid: TGuid; ItemGuid: TGuid): TCmDbPluginClickResponse;
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
  MandatorName: string;
resourcestring
  SSForS = '%s for %s';
begin
  if not resp.Handled then exit;
  if resp.ObjTable <> '' then
  begin
    MainForm.OpenDbObject(resp.ObjTable, resp.ObjId);
  end;
  if resp.SqlTable <> '' then
  begin
    StatisticsForm := MainForm.FindForm(resp.StatId) as TStatisticsForm;
    if Assigned(StatisticsForm) then
    begin
      MainForm.RestoreMdiChild(StatisticsForm);
    end
    else
    begin
      MandatorName := AdoConn.GetScalar('select NAME from MANDATOR where ID = ''' + MandatorId.ToString + '''');
      StatisticsForm := TStatisticsForm.Create(Application.MainForm);
      StatisticsForm.StatisticsId := resp.StatId;
      StatisticsForm.StatisticsName := resp.StatName;
      StatisticsForm.SqlTable := resp.SqlTable;
      StatisticsForm.SqlInitialOrder := resp.SqlInitialOrder;
      StatisticsForm.MandatorId := MandatorId;
      StatisticsForm.MandatorName := MandatorName;
      StatisticsForm.Caption := Format(SSForS, [resp.StatName, MandatorName]);
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
  GUID_3: TGUID = '{2A7F1225-08A6-4B55-9EF7-75C7933DFBCA}';
  GUID_4: TGUID = '{636CD096-DB61-4ECF-BA79-00445AEB8798}';
  GUID_5: TGUID = '{BEBEE253-6644-4A66-87D1-BB63FFAD57B4}';

function TCmDbPlugin.ClickEvent(const DBConnStr: string; StatGuid,
  ItemGuid: TGuid): TCmDbPluginClickResponse;
begin
  // TODO: Call DLL instead
  Result.Handled := false;
  if FPluginDllFilename = 'PLG_STD_STAT.DLL' then
  begin
    if IsEqualGuid(StatGuid, GUID_1) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        //InstallSql(..., 'vw_STAT_RUNNING_COMMISSIONS');
        result.Handled := true;
        result.StatId := StatGuid;
        result.StatName := 'Running commissions';
        result.SqlTable := 'vw_STAT_RUNNING_COMMISSIONS';
        result.SqlInitialOrder := '__STATUS_ORDER, ART_STATUS, FOLDER';
      end
      else
      begin
        result.Handled := true;
        result.ObjTable := 'COMMISSION';
        result.ObjId := ItemGuid;
      end;
    end
    else if IsEqualGuid(StatGuid, GUID_2) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        //InstallSql(..., 'vw_STAT_SUM_YEARS');
        result.Handled := true;
        result.StatId := StatGuid;
        result.StatName := 'Local sum over years';
        result.SqlTable := 'vw_STAT_SUM_YEARS';
        result.SqlInitialOrder := 'YEAR desc, DIRECTION';
      end
      else
      begin
        // TODO: Open a list with commissions of that year, and maybe there you can double click to get to the commission?!
      end;
    end
    else if IsEqualGuid(StatGuid, GUID_3) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        //InstallSql(..., 'vw_STAT_SUM_MONTHS');
        result.Handled := true;
        result.StatId := StatGuid;
        result.StatName := 'Local sum over months';
        result.SqlTable := 'vw_STAT_SUM_MONTHS';
        result.SqlInitialOrder := 'MONTH desc, DIRECTION';
      end
      else
      begin
        // TODO: Open a list with commissions of that month, and maybe there you can double click to get to the commission?!
      end;
    end
    else if IsEqualGuid(StatGuid, GUID_4) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        //InstallSql(..., 'vw_STAT_TOP_ARTISTS');
        result.Handled := true;
        result.StatId := StatGuid;
        result.StatName := 'Top artists/clients';
        result.SqlTable := 'vw_STAT_TOP_ARTISTS';
        result.SqlInitialOrder := 'COUNT_COMMISSIONS desc, AMOUNT_LOCAL desc';
      end
      else
      begin
        result.Handled := true;
        result.ObjTable := 'ARTIST';
        result.ObjId := ItemGuid;
      end;
    end
    else if IsEqualGuid(StatGuid, GUID_5) then
    begin
      if IsEqualGuid(ItemGuid, GUID_NIL) then
      begin
        //InstallSql(..., 'vw_STAT_TEXT_EXPORT');
        result.Handled := true;
        result.StatId := StatGuid;
        result.StatName := 'Full Text Export';
        result.SqlTable := 'vw_STAT_TEXT_EXPORT';
        result.SqlInitialOrder := 'DATASET_TYPE, DATASET_ID';
      end
      else
      begin
        // TODO: We could open the data set here... but we need to query all tables to see which tables has the ItemID
      end;
    end;
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
    end;

    AdoConn.Disconnect;
  finally
    AdoConn.Free;
  end;
end;

{ TCmDbPluginClient }

class function TCmDbPluginClient.ClickEvent(AdoConn: TAdoConnection; StatGuid,
  ItemGuid: TGuid): TCmDbPluginClickResponse;
var
  p: TCmDbPlugin;
begin
  // TODO: Ask all plugins
  Result.Handled := false;
  p := TCmDbPlugin.Create('PLG_STD_STAT.DLL');
  try
    result := p.ClickEvent(AdoConn.ConnectionString, StatGuid, ItemGuid);
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
