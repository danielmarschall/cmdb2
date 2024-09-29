unit CmDbPluginClient;

interface

uses
  SysUtils, ADODb, AdoConnHelper, CmDbPluginShare;

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

implementation

uses
  Windows, Forms, Statistics, CmDbMain, CmDbFunctions, ShellApi;

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

constructor TCmDbPlugin.Create(const APluginDllFilename: string);
begin
  inherited Create;
  FPluginDllFilename := APluginDllFilename;
end;

procedure TCmDbPlugin.Init(const DBConnStr: string);
type
  TInitW = procedure(DBConnStr: PChar); stdcall;
var
  DLLHandle: THandle;
  InitW: TInitW;
begin
  DLLHandle := LoadLibrary(PChar(FPluginDllFilename));
  if DLLHandle <> 0 then
  begin
    @InitW := GetProcAddress(DLLHandle, 'InitW');
    if Assigned(InitW) then
    begin
      InitW(PChar(DBConnStr));
    end
    else
    begin
      raise Exception.Create('Failed to load functions from the DLL.');
    end;
    FreeLibrary(DLLHandle);
  end
  else
  begin
    raise Exception.Create('Failed to load DLL.');
  end;
end;

function TCmDbPlugin.ClickEvent(const DBConnStr: string; MandatorGuid,
  StatGuid, ItemGuid: TGuid): TCmDbPluginClickResponse;
type
  TInitW = procedure(DBConnStr: PChar); stdcall;
  TClickEventW = procedure(DBConnStr: PChar; MandatorGuid, StatGuid, ItemGuid: TGuid; ResponseData: Pointer); stdcall;
var
  DLLHandle: THandle;
  ClickEventW: TClickEventW;
  ResponseData: Pointer;
begin
  DLLHandle := LoadLibrary(PChar(FPluginDllFilename));
  if DLLHandle <> 0 then
  begin
    @ClickEventW := GetProcAddress(DLLHandle, 'ClickEventW');
    if Assigned(ClickEventW) then
    begin
      GetMem(ResponseData, 4096);
      try
        ClickEventW(PChar(DBConnStr), MandatorGuid, StatGuid, ItemGuid, ResponseData);
        Result.ReadPluginClickResponse(ResponseData);
      finally
        FreeMem(ResponseData);
      end;
    end
    else
    begin
      raise Exception.Create('Failed to load functions from the DLL.');
    end;
    FreeLibrary(DLLHandle);
  end
  else
  begin
    raise Exception.Create('Failed to load DLL.');
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
  SearchRec: TSearchRec;
  p: TCmDbPlugin;
begin
  if FindFirst(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'*.spl', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        p := TCmDbPlugin.Create(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+SearchRec.Name);
        try
          p.Init(AdoConn.ConnectionString);
        finally
          p.Free;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      SysUtils.FindClose(SearchRec);
    end;
  end;
end;

class function TCmDbPluginClient.ClickEvent(AdoConn: TAdoConnection; MandatorGuid,
  StatGuid, ItemGuid: TGuid): TCmDbPluginClickResponse;
var
  SearchRec: TSearchRec;
  p: TCmDbPlugin;
begin
  Result.Handled := false;
  if FindFirst(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'*.spl', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        p := TCmDbPlugin.Create(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+SearchRec.Name);
        try
          result := p.ClickEvent(AdoConn.ConnectionString, MandatorGuid, StatGuid, ItemGuid);
          if Result.Handled then Exit;
        finally
          p.Free;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      SysUtils.FindClose(SearchRec);
    end;
  end;
end;

end.
