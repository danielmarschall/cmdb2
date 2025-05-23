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
  GUID_THIS_PLUGIN: TGUID = '{F20AF98B-9906-4BB5-9061-9D22FF5E4238}';
  GUID_1: TGUID = '{4DCE53CA-8744-408C-ABA8-3702DCC9C51E}';
  GUID_1A: TGUID = '{AC6FE7BE-91CD-43D0-9971-C6229C3F596D}';
  GUID_1B: TGUID = '{5FF02681-8A21-4218-B1D2-38ECC9827CD2}';
  GUID_1C: TGUID = '{DC56C114-B7D5-4A5A-8EF7-237F52CDEB30}';

resourcestring
  DESC_PLUGIN_SHORT = 'Test';
  DESC_1 = 'Web sources';

function VtsPluginID(lpTypeOut: PGUID; lpIdOut: PGUID; lpVerOut: PDWORD; lpAuthorInfo: Pointer): HRESULT; stdcall;
var
  AuthorInfo: TVtsPluginAuthorInfo;
resourcestring
  S_Info_PluginName = 'Test Plugin';
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
        on E: EAbort do Exit(E_ABORT);
        on E: Exception do Exit(E_PLUGIN_CONN_FAIL);
      end;

      AdoConn.ExecSQL('insert into [STATISTICS] (ID, PLUGIN, NO, NAME) values ('+AdoConn.SQLStringEscape(GUID_1.ToString)+', '+AdoConn.SQLStringEscape(DESC_PLUGIN_SHORT)+', 900, '+AdoConn.SQLStringEscape(DESC_1)+');');

      AdoConn.Disconnect;
    finally
      FreeAndNil(AdoConn);
    end;

    result := S_PLUGIN_OK;
  except
    on E: EAbort do Exit(E_ABORT);
    on E: Exception do Exit(E_PLUGIN_GENERIC_FAILURE);
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

    {$REGION '9: Test menu plugin'}
    if IsEqualGuid(StatGuid, GUID_1) then
    begin
      // This is an example for creating a plugin that outputs a "menu" with custom actions (which can be anything!)
      if IsEqualGuid(ItemGuid, GUID_ORIGIN_MANDATOR) or IsEqualGuid(ItemGuid, GUID_ORIGIN_REFRESH) then
      begin
        AdoConn := TAdoConnection.Create(nil);
        try
          try
            if DBConnStr = '' then Exit(E_PLUGIN_BAD_ARGS);
            AdoConn.LoginPrompt := false;
            AdoConn.ConnectConnStr(DBConnStr);
          except
            on E: EAbort do Exit(E_ABORT);
            on E: Exception do Exit(E_PLUGIN_CONN_FAIL);
          end;
          if not AdoConn.TableExists(TempTableName(GUID_1, 'TEST')) then
          begin
            AdoConn.ExecSQL('create table '+TempTableName(GUID_1, 'TEST')+' ( ' + #13#10 +
                            '__ID uniqueidentifier NOT NULL, ' + #13#10 +
                            'NAME varchar(200) NOT NULL );');
          end;
          AdoConn.ExecSQL('delete from '+TempTableName(GUID_1, 'TEST'));
          AdoConn.ExecSQL('insert into '+TempTableName(GUID_1, 'TEST')+' select '''+GUID_1A.ToString+''', ''View Source Code'';');
          AdoConn.ExecSQL('insert into '+TempTableName(GUID_1, 'TEST')+' select '''+GUID_1B.ToString+''', ''Download latest version'';');
          Randomize;
          AdoConn.ExecSQL('insert into '+TempTableName(GUID_1, 'TEST')+' select '''+GUID_1C.ToString+''', ''Random number: '+IntToStr(Random(10000))+''';');
        finally
          FreeAndNil(AdoConn);
        end;

        Response.Handled := true;
        Response.Action := craStatistics;
        Response.StatId := StatGuid;
        Response.StatName := DESC_1;
        Response.SqlTable := TempTableName(GUID_1, 'TEST');
        Response.SqlInitialOrder := '';
        Response.SqlAdditionalFilter := '';
        Response.BaseTableDelete := '';
        Response.ScrollToEnd := false;
        Response.DisplayEditFormats := '';
      end
      else if IsEqualGUID(ItemGuid, GUID_1A) then
      begin
        Response.Handled := true;
        Response.Action := craNone;
        ShellExecute(0, 'open', 'https://github.com/danielmarschall/cmdb2', '', '', SW_NORMAL);
      end
      else if IsEqualGUID(ItemGuid, GUID_1B) then
      begin
        Response.Handled := true;
        Response.Action := craNone;
        ShellExecute(0, 'open', 'https://github.com/danielmarschall/cmdb2/releases', '', '', SW_NORMAL);
      end;
    end;
    {$ENDREGION}

    Response.WriteToMemory(ResponseData);
    result := S_PLUGIN_OK;
  except
    on E: EAbort do Exit(E_ABORT);
    on E: Exception do Exit(E_PLUGIN_CONN_FAIL);
  end;
end;

exports
  VtsPluginID, InitW, ClickEventW;

begin
end.
