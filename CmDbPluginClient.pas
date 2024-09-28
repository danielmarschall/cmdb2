unit CmDbPluginClient;

interface

uses
  SysUtils, ADODb, AdoConnHelper;

type
  TCmDbPluginClickResponse = record
    Handled: boolean;
    SqlTable: string;
    SqlInitialOrder: string;
  end;

type
  TCmDbPluginClient = class(TObject)
  public
    class procedure CreateTables(AdoConn: TAdoConnection);
    class procedure InitAllPlugins(AdoConn: TAdoConnection);
    class function ClickEvent(AdoConn: TAdoConnection; ItemGuid: TGuid): TCmDbPluginClickResponse;
  end;

type
  TCmDbPlugin = class(TObject)
  private
    FPluginDllFilename: string;
  public
    procedure Init(const DBConnStr: string);
    function ClickEvent(const DBConnStr: string; ItemGuid: TGuid): TCmDbPluginClickResponse;
    constructor Create(const APluginDllFilename: string);
  end;

implementation

{ TCmDbPlugin }

const
  GUID_1: TGUID = '{6F7E0568-3612-4BD0-BEA6-B23560A5F594}';
  GUID_2: TGUID = '{08F3D4C0-8DBD-4F3E-8891-241858779E49}';
  GUID_3: TGUID = '{2A7F1225-08A6-4B55-9EF7-75C7933DFBCA}';
  GUID_4: TGUID = '{636CD096-DB61-4ECF-BA79-00445AEB8798}';
  GUID_5: TGUID = '{BEBEE253-6644-4A66-87D1-BB63FFAD57B4}';

constructor TCmDbPlugin.Create(const APluginDllFilename: string);
begin
  inherited Create;
  FPluginDllFilename := APluginDllFilename;
end;

function TCmDbPlugin.ClickEvent(const DBConnStr: string; ItemGuid: TGuid): TCmDbPluginClickResponse;
begin
  // TODO: Call DLL instead
  if FPluginDllFilename = 'PLG_STD_STAT.DLL' then
  begin
    if IsEqualGUID(ItemGuid, GUID_1) then
    begin
      //InstallSql(1, 'vw_STAT_RUNNING_COMMISSIONS');
      result.Handled := true;
      result.SqlTable := 'vw_STAT_RUNNING_COMMISSIONS';
      result.SqlInitialOrder := '__STATUS_ORDER, ART_STATUS, FOLDER';
    end
    else if IsEqualGUID(ItemGuid, GUID_2) then
    begin
      //InstallSql(1, 'vw_STAT_SUM_YEARS');
      result.Handled := true;
      result.SqlTable := 'vw_STAT_SUM_YEARS';
      result.SqlInitialOrder := 'YEAR desc, DIRECTION';
    end
    else if IsEqualGUID(ItemGuid, GUID_3) then
    begin
      //InstallSql(1, 'vw_STAT_SUM_MONTHS');
      result.Handled := true;
      result.SqlTable := 'vw_STAT_SUM_MONTHS';
      result.SqlInitialOrder := 'MONTH desc, DIRECTION';
    end
    else if IsEqualGUID(ItemGuid, GUID_4) then
    begin
      //InstallSql(1, 'vw_STAT_TOP_ARTISTS');
      result.Handled := true;
      result.SqlTable := 'vw_STAT_TOP_ARTISTS';
      result.SqlInitialOrder := 'COUNT_COMMISSIONS desc, AMOUNT_LOCAL desc';
    end
    else if IsEqualGUID(ItemGuid, GUID_5) then
    begin
      //InstallSql(1, 'vw_STAT_TEXT_EXPORT');
      result.Handled := true;
      result.SqlTable := 'vw_STAT_TEXT_EXPORT';
      result.SqlInitialOrder := 'DATASET_TYPE, DATASET_ID';
    end
    else
    begin
      result.Handled := false;
    end;
  end;
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

class function TCmDbPluginClient.ClickEvent(AdoConn: TAdoConnection; ItemGuid: TGuid): TCmDbPluginClickResponse;
var
  p: TCmDbPlugin;
begin
  // TODO: Ask all plugins
  Result.Handled := false;
  p := TCmDbPlugin.Create('PLG_STD_STAT.DLL');
  try
    result := p.ClickEvent(AdoConn.ConnectionString, ItemGuid);
    if Result.Handled then Exit;
  finally
    p.Free;
  end;
end;

end.
