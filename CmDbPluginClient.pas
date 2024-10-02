unit CmDbPluginClient;

interface

uses
  SysUtils, ADODb, AdoConnHelper, CmDbPluginShare;

type
  TCmDbPluginClient = class(TObject)
  public
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
  Windows, Forms, Statistics, CmDbMain, CmDbFunctions, ShellApi, Dialogs, System.UITypes,
  SyncObjs;

type
  TVtsPluginID = function(lpTypeOut: PGUID; lpIdOut: PGUID; lpVerOut: PDWORD): HRESULT; stdcall;

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
  TInitW = function(DBConnStr: PChar): HRESULT; stdcall;
var
  DLLHandle: THandle;
  InitW: TInitW;
  VtsPluginID: TVtsPluginID;
  plgType, plgId: TGUID;
  plgVer: DWORD;
begin
  DLLHandle := LoadLibrary(PChar(FPluginDllFilename));
  if DLLHandle = 0 then
    raise Exception.CreateFmt('Failed to load %s', [FPluginDllFilename]);
  try
    @VtsPluginID := GetProcAddress(DLLHandle, 'VtsPluginID');
    if not Assigned(VtsPluginID) or Failed(VtsPluginID(@plgType, @plgId, @plgVer)) or not IsEqualGUID(plgType, CMDB2_STATSPLUGIN_V1_TYPE) then
      raise Exception.CreateFmt('%s is not a valid CMDB2 Statistics Plugins', [FPluginDllFilename]);

    @InitW := GetProcAddress(DLLHandle, 'InitW');
    if not Assigned(InitW) then
      raise Exception.CreateFmt('Function %s not found in %s', ['InitW', FPluginDllFilename]);
    if Failed(InitW(PChar(DBConnStr))) then
      raise Exception.CreateFmt('Call to %s failed in %s', ['InitW', FPluginDllFilename]);
  finally
    FreeLibrary(DLLHandle);
  end;
end;

function TCmDbPlugin.ClickEvent(const DBConnStr: string; MandatorGuid,
  StatGuid, ItemGuid: TGuid): TCmDbPluginClickResponse;
type
  TClickEventW = function(DBConnStr: PChar; MandatorGuid, StatGuid,
    ItemGuid: TGuid; ResponseData: Pointer): HRESULT; stdcall;
var
  DLLHandle: THandle;
  ClickEventW: TClickEventW;
  ResponseData: Pointer;
  VtsPluginID: TVtsPluginID;
  plgType, plgId: TGUID;
  plgVer: DWORD;
begin
  DLLHandle := LoadLibrary(PChar(FPluginDllFilename));
  if DLLHandle = 0 then
    raise Exception.CreateFmt('Failed to load %s', [FPluginDllFilename]);
  try
    @VtsPluginID := GetProcAddress(DLLHandle, 'VtsPluginID');
    if not Assigned(VtsPluginID) or Failed(VtsPluginID(@plgType, @plgId, @plgVer)) or not IsEqualGUID(plgType, CMDB2_STATSPLUGIN_V1_TYPE) then
      raise Exception.CreateFmt('%s is not a valid CMDB2 Statistics Plugins', [FPluginDllFilename]);

    @ClickEventW := GetProcAddress(DLLHandle, 'ClickEventW');
    if not Assigned(ClickEventW) then
      raise Exception.CreateFmt('Function %s not found in %s', ['ClickEventW', FPluginDllFilename]);

    GetMem(ResponseData, 4096);
    try
      if Failed(ClickEventW(PChar(DBConnStr), MandatorGuid, StatGuid, ItemGuid, ResponseData)) then
        raise Exception.CreateFmt('Call to %s failed in %s', ['ClickEventW', FPluginDllFilename]);
      Result.ReadPluginClickResponse(ResponseData);
    finally
      FreeMem(ResponseData);
    end;
  finally
    FreeLibrary(DLLHandle);
  end;
end;

{ TCmDbPluginClient }

var
  CsPluginTableFill: TCriticalSection;

class procedure TCmDbPluginClient.InitAllPlugins(AdoConn: TAdoConnection);
var
  SearchRec: TSearchRec;
  p: TCmDbPlugin;
begin
  CsPluginTableFill.Enter; // we cannot use a DB transaction, because EXE and DLL have two contexts
  try
    AdoConn.ExecSQL('delete from [STATISTICS]');
    if FindFirst(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'*.spl', faAnyFile, SearchRec) = 0 then
    begin
      try
        repeat
          try
            p := TCmDbPlugin.Create(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+SearchRec.Name);
            try
              p.Init(AdoConn.ConnectionString);
            finally
              p.Free;
            end;
          except
            on E: Exception do
            begin
              MessageDlg(E.Message, TMsgDlgType.mtWarning, [mbOk], 0);
            end;
          end;
        until FindNext(SearchRec) <> 0;
      finally
        SysUtils.FindClose(SearchRec);
      end;
    end;
  finally
    CsPluginTableFill.Leave;
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
        try
          p := TCmDbPlugin.Create(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+SearchRec.Name);
          try
            result := p.ClickEvent(AdoConn.ConnectionString, MandatorGuid, StatGuid, ItemGuid);
            if Result.Handled then Exit;
          finally
            p.Free;
          end;
        except
          on E: Exception do
          begin
            MessageDlg(E.Message, TMsgDlgType.mtWarning, [mbOk], 0);
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      SysUtils.FindClose(SearchRec);
    end;
  end;
end;

initialization
  CsPluginTableFill := TCriticalSection.Create;
finalization
  FreeAndNil(CsPluginTableFill);
end.
