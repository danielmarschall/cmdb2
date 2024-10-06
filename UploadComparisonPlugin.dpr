library MenuTestPlugin;

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
  GUID_THIS_PLUGIN: TGUID = '{02017E8E-CC0F-435B-A7A6-3EF39A8411A6}';

resourcestring
  DESC_PLUGIN_SHORT = 'Upload Check';

function VtsPluginID(lpTypeOut: PGUID; lpIdOut: PGUID; lpVerOut: PDWORD; lpAuthorInfo: Pointer): HRESULT; stdcall;
var
  AuthorInfo: TVtsPluginAuthorInfo;
resourcestring
  S_Info_PluginName = 'Upload Check Plugin';
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
    lpIDOut^ := GUID_THIS_PLUGIN;
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

      // TODO: Add code here

      AdoConn.Disconnect;
    finally
      FreeAndNil(AdoConn);
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
  Response: TCmDbPluginClickResponse;
begin
  if ResponseData = nil then Exit(E_PLUGIN_BAD_ARGS);
  try
    Response.Handled := false;

    // TODO: Add code here

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
