unit CmDbPluginClient;

interface

uses
  Windows, SysUtils, Classes, ADODb, AdoConnHelper, CmDbPluginShare;

type
  TCmDbPluginClient = class(TObject)
  public
    class procedure GetVersionInfoOfPlugins(outSL: TStringList); static;
    class procedure InitAllPlugins(AdoConn: TAdoConnection);
    class function ClickEvent(AdoConn: TAdoConnection; MandatorGuid, StatGuid, ItemGuid: TGuid): TCmDbPluginClickResponse;
  end;

type
  TCmDbPlugin = class(TObject)
  private
    FDLLHandle: THandle;
    FPluginDllFilename: string;
  public
    VerInfo: TVtsPluginAuthorInfo;
    constructor Create(const APluginDllFilename: string);
    destructor Destroy; override;
    procedure Init(const DBConnStr: string);
    function ClickEvent(const DBConnStr: string; MandatorGuid, StatGuid, ItemGuid: TGuid): TCmDbPluginClickResponse;
  end;

procedure HandleClickResponse(AdoConn: TAdoConnection; MandatorId: TGUID; resp: TCmDbPluginClickResponse);

implementation

uses
  Forms, Statistics, CmDbMain, CmDbFunctions, ShellApi, Dialogs, System.UITypes,
  SyncObjs;

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
      StatisticsForm.MandatorId := MandatorId;
      StatisticsForm.ADOConnection1.Connected := false;
      StatisticsForm.ADOConnection1.ConnectionString := AdoConn.ConnectionString;
      StatisticsForm.Init(resp);
    end;
  end
  else if resp.Action = craAbort then
  begin
    Abort;
  end;
end;

{ TCmDbPlugin }

constructor TCmDbPlugin.Create(const APluginDllFilename: string);
var
  VtsPluginID: TVtsPluginID;
  plgType, plgId: TGUID;
  plgVer: DWORD;
  AuthorInfo: Pointer;
resourcestring
  SFailedToLoadS = 'Failed to load %s';
  SNotAValidPlugin = '%s is not a valid CMDB2 Statistics Plugin';
const
  BUF_SIZE = 4096;
begin
  inherited Create;

  FPluginDllFilename := APluginDllFilename;

  FDLLHandle := LoadLibrary(PChar(FPluginDllFilename));
  if FDLLHandle = 0 then
    raise Exception.CreateFmt(SFailedToLoadS, [FPluginDllFilename]);
  try
    @VtsPluginID := GetProcAddress(FDLLHandle, 'VtsPluginID'); // do not localize
    GetMem(AuthorInfo, BUF_SIZE);
    try
      ZeroMemory(AuthorInfo, BUF_SIZE);
      if not Assigned(VtsPluginID) or Failed(VtsPluginID(@plgType, @plgId, @plgVer, AuthorInfo)) or not IsEqualGUID(plgType, CMDB2_STATSPLUGIN_V1_TYPE) then
        raise Exception.CreateFmt(SNotAValidPlugin, [FPluginDllFilename]);
      VerInfo.ReadFromMemory(AuthorInfo);
    finally
      FreeMem(AuthorInfo);
    end;
  except
    on E: EAbort do
    begin
      Abort;
    end;
    on E: Exception do
    begin
      if FDLLHandle <> 0 then
      begin
        FreeLibrary(FDLLHandle);
        FDLLHandle := 0;
      end;
      raise;
    end;
  end;
end;

destructor TCmDbPlugin.Destroy;
begin
  if FDLLHandle <> 0 then
  begin
    FreeLibrary(FDLLHandle);
    FDLLHandle := 0;
  end;
  inherited;
end;

resourcestring
  SFunctionNotFound = 'Function %s not found in %s';
  SCallToSFailed = 'Call to %s failed in %s';

procedure TCmDbPlugin.Init(const DBConnStr: string);
type
  TInitW = function(DBConnStr: PChar): HRESULT; stdcall;
var
  InitW: TInitW;
const
  DllProcInit = 'InitW';
begin
  @InitW := GetProcAddress(FDLLHandle, DllProcInit);
  if not Assigned(InitW) then
    raise Exception.CreateFmt(SFunctionNotFound, [DllProcInit, FPluginDllFilename]);
  if Failed(InitW(PChar(DBConnStr))) then
    raise Exception.CreateFmt(SCallToSFailed, [DllProcInit, FPluginDllFilename]);
end;

function TCmDbPlugin.ClickEvent(const DBConnStr: string; MandatorGuid,
  StatGuid, ItemGuid: TGuid): TCmDbPluginClickResponse;
type
  TClickEventW = function(DBConnStr: PChar; MandatorGuid, StatGuid,
    ItemGuid: TGuid; ResponseData: Pointer): HRESULT; stdcall;
var
  ClickEventW: TClickEventW;
  ResponseData: Pointer;
const
  DllProcClickEvent = 'ClickEventW';
const
  BUF_SIZE = 4096;
begin
  @ClickEventW := GetProcAddress(FDLLHandle, DllProcClickEvent);
  if not Assigned(ClickEventW) then
    raise Exception.CreateFmt(SFunctionNotFound, [DllProcClickEvent, FPluginDllFilename]);

  GetMem(ResponseData, BUF_SIZE);
  try
    ZeroMemory(ResponseData, BUF_SIZE);
    if Failed(ClickEventW(PChar(DBConnStr), MandatorGuid, StatGuid, ItemGuid, ResponseData)) then
      raise Exception.CreateFmt(SCallToSFailed, [DllProcClickEvent, FPluginDllFilename]);
    Result.ReadFromMemory(ResponseData);
  finally
    FreeMem(ResponseData);
  end;
end;

{ TCmDbPluginClient }

var
  CsPluginTableFill: TCriticalSection;

class procedure TCmDbPluginClient.GetVersionInfoOfPlugins(outSL: TStringList);
var
  SearchRec: TSearchRec;
  p: TCmDbPlugin;
  isFirst: boolean;
resourcestring
  SBy = 'by';
  SLicense = 'License';
begin
  isFirst := True;
  if FindFirst(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'*.spl', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        try
          p := TCmDbPlugin.Create(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+SearchRec.Name);
          try
            if isFirst then
              isFirst := false
            else
              outSL.Add('');
            outSL.Add('[ ' + SearchRec.Name + ' ]');
            outSL.Add(p.VerInfo.PluginName + ' ' + p.VerInfo.PluginVersion + ' ' + SBy + ' ' + p.VerInfo.PluginAuthor);
            outSL.Add(p.VerInfo.PluginCopyright);
            outSL.Add(SLicense + ': ' + p.VerInfo.PluginLicense);
            if p.VerInfo.PluginMoreInfo <> '' then outSL.Add(p.VerInfo.PluginMoreInfo);
          finally
            FreeAndNil(p);
          end;
        except
          on E: EAbort do
          begin
            Abort;
          end;
          on E: Exception do
          begin
            MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title), MB_OK or MB_ICONWARNING or MB_TASKMODAL);
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      SysUtils.FindClose(SearchRec);
    end;
  end;
end;

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
              FreeAndNil(p);
            end;
          except
            on E: EAbort do
            begin
              Abort;
            end;
            on E: Exception do
            begin
              MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title), MB_OK or MB_ICONWARNING or MB_TASKMODAL);
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
            if Result.Handled then
            begin
              if Result.Action = craAbort then Abort; // can cancel clicking "Refresh" button
              Exit;
            end
            else
            begin
              Beep;
            end;
          finally
            FreeAndNil(p);
          end;
        except
          on E: EAbort do
          begin
            Abort;
          end;
          on E: Exception do
          begin
            MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title), MB_OK or MB_ICONWARNING or MB_TASKMODAL);
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
