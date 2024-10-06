library MenuTestPlugin;

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  Adodb,
  AdoConnHelper,
  Windows,
  ShellApi,
  CmDbPluginShare in 'CmDbPluginShare.pas';

{$R *.res}

const
  // Ctrl+Shift+G to generate new GUIDs
  GUID_THIS_PLUGIN: TGUID = '{27ABE456-C433-481D-9FD9-5CF7ED544CB0}';
  GUID_1: TGUID = '{862A4FA7-A508-44F6-AFFF-090378342741}';
  GUID_2: TGUID = '{FAA3A129-9307-410D-BAEB-D3DF1B34D235}';
  GUID_3: TGUID = '{DFB5D0CB-9746-4C23-8746-6DA9BD5DFA74}';

resourcestring
  DESC_PLUGIN_SHORT = 'Folder Check';
  DESC_1 = 'Commissions without folders';
  DESC_2 = 'Commission folders invalid / not existing';
  DESC_3 = 'Comparison Drive / Database folders';

function VtsPluginID(lpTypeOut: PGUID; lpIdOut: PGUID; lpVerOut: PDWORD; lpAuthorInfo: Pointer): HRESULT; stdcall;
var
  AuthorInfo: TVtsPluginAuthorInfo;
resourcestring
  S_Info_PluginName = 'Folder Check Plugin';
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

      AdoConn.ExecSQL('insert into [STATISTICS] (ID, PLUGIN, NO, NAME) values ('+AdoConn.SQLStringEscape(GUID_1.ToString)+', '+AdoConn.SQLStringEscape(DESC_PLUGIN_SHORT)+', 100, '+AdoConn.SQLStringEscape(DESC_1)+');');
      AdoConn.ExecSQL('insert into [STATISTICS] (ID, PLUGIN, NO, NAME) values ('+AdoConn.SQLStringEscape(GUID_2.ToString)+', '+AdoConn.SQLStringEscape(DESC_PLUGIN_SHORT)+', 200, '+AdoConn.SQLStringEscape(DESC_2)+');');
      AdoConn.ExecSQL('insert into [STATISTICS] (ID, PLUGIN, NO, NAME) values ('+AdoConn.SQLStringEscape(GUID_3.ToString)+', '+AdoConn.SQLStringEscape(DESC_PLUGIN_SHORT)+', 300, '+AdoConn.SQLStringEscape(DESC_3)+');');

      AdoConn.Disconnect;
    finally
      FreeAndNil(AdoConn);
    end;

    result := S_PLUGIN_OK;
  except
    Exit(E_PLUGIN_GENERIC_FAILURE);
  end;
end;

function _ListContainsIgnoreCase(List: TStringList; const Value: string): Boolean;
var
  Item: string;
begin
  Result := False;
  for Item in List do
  begin
    if SameText(Item, Value) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure _CompareFolders(AdoConn: TAdoConnection);
var
  SQLQuery: TAdoDataset;
  DBFolders: TStringList;
  FSFolders: TStringList;
  Folder: string;
  Path: string;
  DBFolderName: string;
begin
  Path := 'D:\OneDrive\Commissions\'; // TODO: bestimmen durch DB Abfrage

  AdoConn.ExecSQL('delete from '+TempTableName(GUID_3, 'FOLDER_COMPARE'));

  // Liste der Verzeichnisse im Dateisystem
  FSFolders := TStringList.Create;
  FSFolders.Duplicates := dupIgnore;
  FSFolders.Sorted := true;
  try
    // Rekursiv alle Ordner im Verzeichnis sammeln
    for Folder in TDirectory.GetDirectories(Path, '*', TSearchOption.soTopDirectoryOnly) do
    begin
      FSFolders.Add(IncludeTrailingPathDelimiter(Path) + ExtractFileName(Folder));
    end;

    // SQL Abfrage, um die Verzeichnisnamen aus der Tabelle zu holen
    SQLQuery := AdoConn.GetTable('select art.MANDATOR_ID, cm.FOLDER ' +
                                 'from COMMISSION cm ' +
                                 'left join ARTIST art on art.ID = cm.ARTIST_ID');
    try
      // Liste der Verzeichnisse aus der Datenbank erstellen
      DBFolders := TStringList.Create;
      DBFolders.Duplicates := dupIgnore;
      DBFolders.Sorted := true;
      try
        while not SQLQuery.Eof do
        begin
          DBFolderName := SQLQuery.FieldByName('FOLDER').AsWideString;
          DBFolders.Add(DBFolderName);
          SQLQuery.Next;
        end;

        // 1. Ordner, die im Dateisystem, aber nicht in der Datenbank existieren
//        Writeln('Ordner im Dateisystem, aber nicht in der Datenbank:');
        for Folder in FSFolders do
        begin
          if not _ListContainsIgnoreCase(DBFolders, Folder) then
          begin
            AdoConn.ExecSQL('insert into '+TempTableName(GUID_3, 'FOLDER_COMPARE')+' select newid(), '+AdoConn.SQLStringEscape(SQLQuery.FieldByName('MANDATOR_ID').AsWideString)+', N''InFilesystem / NotInDatabase'', '+AdoConn.SQLStringEscape(Folder)+';');
//            Writeln(Folder);
          end;
        end;

        // 2. Ordner, die in der Datenbank, aber nicht im Dateisystem existieren
//        Writeln('Ordner in der Datenbank, aber nicht im Dateisystem:');
        for Folder in DBFolders do
        begin
          if not _ListContainsIgnoreCase(FSFolders, Folder) then
          begin
            AdoConn.ExecSQL('insert into '+TempTableName(GUID_3, 'FOLDER_COMPARE')+' select newid(), '+AdoConn.SQLStringEscape(SQLQuery.FieldByName('MANDATOR_ID').AsWideString)+', N''InDatabase / NotInFilesystem'', '+AdoConn.SQLStringEscape(Folder)+';');
//            Writeln(Folder);
          end;
        end;

      finally
        FreeAndNil(DBFolders);
      end;
    finally
      FreeAndNil(SQLQuery);
    end;

  finally
    FreeAndNil(FSFolders);
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

    {$REGION 'Stat 1: Commissions without folders'}
    if IsEqualGuid(StatGuid, GUID_1) then
    begin
      // TODO: Implement
    end
    {$ENDREGION}
    {$REGION 'Stat 2: Commission folders invalid / not existing'}
    else if IsEqualGuid(StatGuid, GUID_2) then
    begin
      // TODO: Implement
    end
    {$ENDREGION}
    {$REGION 'Stat 3: Comparison Drive / Database folders'}
    else if IsEqualGuid(StatGuid, GUID_3) then
    begin
      // TODO: Implement
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
          if not AdoConn.TableExists(TempTableName(GUID_3, 'FOLDER_COMPARE')) then
          begin
            AdoConn.ExecSQL('create table '+TempTableName(GUID_3, 'FOLDER_COMPARE')+' ( __ID uniqueidentifier NOT NULL, __MANDATOR_ID uniqueidentifier NOT NULL, PROBLEM nvarchar(50), FOLDER nvarchar(250) );');
          end;
          _CompareFolders(AdoConn);
        finally
          FreeAndNil(AdoConn);
        end;
        Response.Handled := true;
        Response.Action := craStatistics;
        Response.StatId := StatGuid;
        Response.StatName := DESC_3;
        Response.SqlTable := TempTableName(GUID_3, 'FOLDER_COMPARE');
        Response.SqlInitialOrder := 'PROBLEM, FOLDER';
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
