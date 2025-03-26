library MenuTestPlugin;

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  Adodb,
  AdoConnHelper,
  Windows,
  Variants,
  ShellApi,
  Vcl.Dialogs,
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
  DESC_2 = 'Commission folders not existing';
  DESC_3 = 'Comparison File System folders / Database folders';

function _VariantToString(const Value: Variant): string;
begin
  if VarIsNull(Value) then
    Result := ''
  else
    Result := VarToStr(Value);
end;

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
        on E: EAbort do Exit(E_ABORT);
        on E: Exception do Exit(E_PLUGIN_CONN_FAIL);
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
    on E: EAbort do Exit(E_ABORT);
    on E: Exception do Exit(E_PLUGIN_GENERIC_FAILURE);
  end;
end;

function ClickEventW(DBConnStr: PChar; MandatorGuid, StatGuid,
  ItemGuid: TGuid; ResponseData: Pointer): HRESULT; stdcall;

  {$REGION 'Helper functions for Stat 3: Comparison File System folders / Database folders'}

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

  function _Stat3_CompareFolders(AdoConn: TAdoConnection): boolean;
  var
    SQLQuery: TAdoDataset;
    DBFolders: TStringList;
    FSFolders: TStringList;
    Folder: string;
    Path: string;
    DBFolderName: string;
  resourcestring
    SEnterBasePath = 'Enter the commission base path which should be compared with the commission folders in the database';
    SProblem1 = 'NotInDatabase / HasBaseCommissionFolder';
    SProblem2 = 'InDatabase / NoBaseCommissionFolder';
  begin
    // This query gives the most used parent folder for commissions in the database
    Path := _VariantToString(AdoConn.GetScalar('WITH tmp_BASEFOLDER AS ( ' + #13#10 +
                              '    SELECT ' + #13#10 +
                              '        LEFT(FOLDER, LEN(FOLDER) - CHARINDEX(''\'', REVERSE(FOLDER))) AS BASEFOLDER ' + #13#10 +
                              '    FROM ' + #13#10 +
                              '        COMMISSION ' + #13#10 +
                              ') ' + #13#10 +
                              'SELECT top 1 ' + #13#10 +
                              '    BASEFOLDER ' + #13#10 +
                              'FROM ' + #13#10 +
                              '    tmp_BASEFOLDER ' + #13#10 +
                              'GROUP BY ' + #13#10 +
                              '    BASEFOLDER ' + #13#10 +
                              'ORDER BY ' + #13#10 +
                              '    count(*) DESC;'));


    if not InputQuery(DESC_3, SEnterBasePath, Path) then Exit(False);

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
      SQLQuery := AdoConn.GetTable('select art.MANDATOR_ID, cm.FOLDER, cm.PROJECT_NAME, cm.ID as COMMISSION_ID ' +
                                   'from vw_COMMISSION cm ' +
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

            // 2. Ordner, die in der Datenbank, aber nicht im Dateisystem existieren
            if not _ListContainsIgnoreCase(FSFolders, DBFolderName) then
            begin
              AdoConn.ExecSQL('insert into '+TempTableName(GUID_3, 'FOLDER_COMPARE')+' '+
                              'select '''+SQLQuery.FieldByName('COMMISSION_ID').AsWideString+''', '+
                              AdoConn.SQLStringEscape(SQLQuery.FieldByName('MANDATOR_ID').AsWideString)+', '+
                              '2, '+
                              'N'''+SProblem2+''', '+
                              AdoConn.SQLStringEscape(SQLQuery.FieldByName('PROJECT_NAME').AsWideString)+', '+
                              AdoConn.SQLStringEscape(DBFolderName)+';');
            end;

            SQLQuery.Next;
          end;

          // 1. Ordner, die im Dateisystem, aber nicht in der Datenbank existieren
          for Folder in FSFolders do
          begin
            if not _ListContainsIgnoreCase(DBFolders, Folder) then
            begin
              AdoConn.ExecSQL('insert into '+TempTableName(GUID_3, 'FOLDER_COMPARE')+' '+
                              'select newid(), '+
                              AdoConn.SQLStringEscape(SQLQuery.FieldByName('MANDATOR_ID').AsWideString)+', '+
                              '1, '+
                              'N'''+SProblem1+''', '+
                              'null, '+
                              AdoConn.SQLStringEscape(Folder)+';');
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

    Exit(true);
  end;

  {$ENDREGION}

var
  AdoConn: TADOConnection;
  Response: TCmDbPluginClickResponse;
  q: TADODataSet;
begin
  if ResponseData = nil then Exit(E_PLUGIN_BAD_ARGS);
  try
    Response.Handled := false;

    {$REGION 'Stat 1: Commissions without folders'}
    if IsEqualGuid(StatGuid, GUID_1) then
    begin
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
          AdoConn.ExecSQL('create or alter view '+TempTableName(GUID_1, 'COMMISSION_NO_FOLDER')+' as ' + #13#10 +
                          'select ' + #13#10 +
                          '    man.ID as __MANDATOR_ID, ' + #13#10 +
                          '    cm.ID as __ID, ' + #13#10 +
                          '    art.NAME as ARTIST, ' + #13#10 +
                          '    cm.NAME, ' + #13#10 +
                          '    cm.ART_STATUS, ' + #13#10 +
                          '    cm.FOLDER ' + #13#10 +
                          'from vw_COMMISSION cm ' + #13#10 +
                          'left join ARTIST art on art.ID = cm.ARTIST_ID ' + #13#10 +
                          'left join MANDATOR man on man.ID = art.MANDATOR_ID ' + #13#10 +
                          'where len(cm.FOLDER) < 4');
        finally
          FreeAndNil(AdoConn);
        end;
        Response.Handled := true;
        Response.Action := craStatistics;
        Response.StatId := StatGuid;
        Response.StatName := DESC_1;
        Response.SqlTable := TempTableName(GUID_1, 'COMMISSION_NO_FOLDER');
        Response.SqlInitialOrder := 'ARTIST, NAME';
        Response.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
        Response.BaseTableDelete := 'COMMISSION';
        Response.ScrollToEnd := false;
        Response.DisplayEditFormats := '';
      end
      else
      begin
        Response.Handled := true;
        Response.Action := craObject;
        Response.ObjTable := 'COMMISSION';
        Response.ObjId := ItemGuid;
      end;
    end
    {$ENDREGION}
    {$REGION 'Stat 2: Commission folders not existing'}
    else if IsEqualGuid(StatGuid, GUID_2) then
    begin
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
          if not AdoConn.TableExists(TempTableName(GUID_2, 'FOLDER_NOT_EXISTING')) then
          begin
            AdoConn.ExecSQL('create table '+TempTableName(GUID_2, 'FOLDER_NOT_EXISTING')+' ( ' + #13#10 +
                            '__MANDATOR_ID uniqueidentifier NOT NULL, ' + #13#10 +
                            '__ID uniqueidentifier NOT NULL, ' + #13#10 +
                            'ARTIST nvarchar(50), ' + #13#10 +
                            'NAME nvarchar(100), ' + #13#10 +
                            'ART_STATUS nvarchar(20), ' + #13#10 +
                            'FOLDER nvarchar(200) );');
          end;
          q := AdoConn.GetTable(
                          'select ' + #13#10 +
                          '    man.ID as __MANDATOR_ID, ' + #13#10 +
                          '    cm.ID as __ID, ' + #13#10 +
                          '    art.NAME as ARTIST, ' + #13#10 +
                          '    cm.NAME, ' + #13#10 +
                          '    cm.ART_STATUS, ' + #13#10 +
                          '    cm.FOLDER ' + #13#10 +
                          'from vw_COMMISSION cm ' + #13#10 +
                          'left join ARTIST art on art.ID = cm.ARTIST_ID ' + #13#10 +
                          'left join MANDATOR man on man.ID = art.MANDATOR_ID ' + #13#10 +
                          'where len(cm.FOLDER) >= 4');
          try
            while not q.EOF do
            begin
              if not TDirectory.Exists(q.Fields[5{FOLDER}].AsWideString) then
              begin
                AdoConn.ExecSQL('insert into '+TempTableName(GUID_2, 'FOLDER_NOT_EXISTING')+' ' +
                                'select ' + AdoConn.SQLStringEscape(q.Fields[0].AsWideString) + ', ' +
                                            AdoConn.SQLStringEscape(q.Fields[1].AsWideString) + ', ' +
                                            AdoConn.SQLStringEscape(q.Fields[2].AsWideString) + ', ' +
                                            AdoConn.SQLStringEscape(q.Fields[3].AsWideString) + ', ' +
                                            AdoConn.SQLStringEscape(q.Fields[4].AsWideString) + ', ' +
                                            AdoConn.SQLStringEscape(q.Fields[5].AsWideString) + ';');
              end;
              q.Next;
            end;
          finally
            FreeAndNil(q);
          end;
        finally
          FreeAndNil(AdoConn);
        end;
        Response.Handled := true;
        Response.Action := craStatistics;
        Response.StatId := StatGuid;
        Response.StatName := DESC_3;
        Response.SqlTable := TempTableName(GUID_2, 'FOLDER_NOT_EXISTING');
        Response.SqlInitialOrder := 'ARTIST, NAME';
        Response.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
        Response.BaseTableDelete := 'COMMISSION';
        Response.ScrollToEnd := false;
        Response.DisplayEditFormats := '';
      end
      else
      begin
        Response.Handled := true;
        Response.Action := craObject;
        Response.ObjTable := 'COMMISSION';
        Response.ObjId := ItemGuid;
      end;
    end
    {$ENDREGION}
    {$REGION 'Stat 3: Comparison File System folders / Database folders'}
    else if IsEqualGuid(StatGuid, GUID_3) then
    begin
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
          if not AdoConn.TableExists(TempTableName(GUID_3, 'FOLDER_COMPARE')) then
          begin
            AdoConn.ExecSQL('create table '+TempTableName(GUID_3, 'FOLDER_COMPARE')+' ( ' + #13#10 +
                            '__ID uniqueidentifier NOT NULL, ' + #13#10 +
                            '__MANDATOR_ID uniqueidentifier NOT NULL, ' + #13#10 +
                            '__PROBLEM_INT int, ' + #13#10 +
                            'PROBLEM nvarchar(50), ' + #13#10 +
                            'COMMISSION nvarchar(200), ' + #13#10 +
                            'FOLDER nvarchar(250) );');
          end;
          if not _Stat3_CompareFolders(AdoConn) then
          begin
            Response.Handled := true;
            Response.Action := craAbort;
          end;
        finally
          FreeAndNil(AdoConn);
        end;
        if not Response.Handled then
        begin
          Response.Handled := true;
          Response.Action := craStatistics;
          Response.StatId := StatGuid;
          Response.StatName := DESC_3;
          Response.SqlTable := TempTableName(GUID_3, 'FOLDER_COMPARE');
          Response.SqlInitialOrder := 'PROBLEM, FOLDER';
          Response.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
          Response.BaseTableDelete := 'COMMISSION';
          Response.ScrollToEnd := false;
          Response.DisplayEditFormats := '';
        end;
      end
      else
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
          q := AdoConn.GetTable('select top 1 * from '+TempTableName(GUID_3, 'FOLDER_COMPARE')+' where __ID = ''' + ItemGuid.ToString + '''');
          try
            if q.FieldByName('__PROBLEM_INT').AsInteger = 1 then
            begin
              // 1 = NotInDatabase / HasBaseCommissionFolder
              Response.Handled := true;
              Response.Action := craNone;
              //ShellExecute(0, 'open', 'explorer.exe', PChar('/select,"'+q.FieldByName('FOLDER').AsWideString+'"'), '', SW_NORMAL);
              ShellExecute(0, 'open', 'explorer.exe', PChar(q.FieldByName('FOLDER').AsWideString), '', SW_NORMAL);
            end
            else if q.FieldByName('__PROBLEM_INT').AsInteger = 2 then
            begin
              // 2 = InDatabase / NoBaseCommissionFolder
              Response.Handled := true;
              Response.Action := craObject;
              Response.ObjTable := 'COMMISSION';
              Response.ObjId := ItemGuid;
            end;
          finally
            FreeAndNil(q);
          end;
        finally
          FreeAndNil(AdoConn);
        end;
      end;
    end;
    {$ENDREGION}

    Response.WriteToMemory(ResponseData);
    result := S_PLUGIN_OK;
  except
    on E: EAbort do Exit(E_ABORT);
    on E: Exception do Exit(E_PLUGIN_GENERIC_FAILURE);
  end;
end;

exports
  VtsPluginID, InitW, ClickEventW;

begin
end.
