library MenuTestPlugin;

uses
  System.SysUtils,
  System.Classes,
  Adodb,
  AdoConnHelper,
  Windows,
  WinInet,
  ShellApi,
  Variants,
  CmDbPluginShare in 'CmDbPluginShare.pas';

{$R *.res}

const
  // Ctrl+Shift+G to generate new GUIDs
  GUID_THIS_PLUGIN: TGUID = '{02017E8E-CC0F-435B-A7A6-3EF39A8411A6}';
  GUID_1: TGUID = '{46914DCB-813A-4284-AC9F-909C388048C5}';
  GUID_2: TGUID = '{28FFFD3A-27B8-4E2A-A478-A1BB671DC5CB}';

resourcestring
  DESC_PLUGIN_SHORT = 'Upload Comparison';
  DESC_1 = 'Uploads found online, but not in CMDB';
  DESC_2 = 'Uploads found at CMDB, but not online';

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
  S_Info_PluginName = 'Upload Comparison Plugin';
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

      //if _VariantToString(AdoConn.GetScalar('select VALUE from CONFIG where NAME = ''INSTALL_ID''')) = '86DCF077-D670-4E8F-BC86-313073F9983F' then
      if AdoConn.GetScalar('select count(*) from CONFIG where NAME = ''DMX_UPLOADCHECK_GALLERYLIST'' or NAME = ''DMX_UPLOADCHECK_URLPART'' or NAME = ''DMX_UPLOADCHECK_USERS'';') = 3 then
      begin
        // Feature currently only available for DMX/SD
        AdoConn.ExecSQL('insert into [STATISTICS] (ID, PLUGIN, NO, NAME) values ('+AdoConn.SQLStringEscape(GUID_1.ToString)+', '+AdoConn.SQLStringEscape(DESC_PLUGIN_SHORT)+', 100, '+AdoConn.SQLStringEscape(DESC_1)+');');
        AdoConn.ExecSQL('insert into [STATISTICS] (ID, PLUGIN, NO, NAME) values ('+AdoConn.SQLStringEscape(GUID_2.ToString)+', '+AdoConn.SQLStringEscape(DESC_PLUGIN_SHORT)+', 200, '+AdoConn.SQLStringEscape(DESC_2)+');');
      end;

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

function _WinInet_DoGet(const Url: string): string;

  const
    USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36';
    MaxRedirects = 5;

  function GetRedirectLocation(hRequest: HINTERNET): string;
  var
    Buffer: array[0..1023] of Char;
    BufferLength, HeaderIndex: DWORD;
  begin
    Result := '';
    BufferLength := SizeOf(Buffer);
    HeaderIndex := 0;

    // Query the "Location" header to get the new URL for redirection
    if HttpQueryInfo(hRequest, HTTP_QUERY_LOCATION, @Buffer, BufferLength, HeaderIndex) then
      Result := string(Buffer);
  end;

  function GetStatusCode(hRequest: HINTERNET): DWORD;
  var
    StatusCode: DWORD;
    StatusCodeLen: DWORD;
    HeaderIndex: DWORD;
  begin
    StatusCode := 0;
    StatusCodeLen := SizeOf(StatusCode);
    HeaderIndex := 0;

    // Query the status code from the HTTP response
    if HttpQueryInfo(hRequest, HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER, @StatusCode, StatusCodeLen, HeaderIndex) then
      Result := StatusCode
    else
      Result := 0;
  end;

var
  AUrl: string;
  databuffer : array[0..4095] of ansichar; // SIC! ansichar!
  Response : ansistring; // SIC! ansistring
  hSession, hRequest: hInternet;
  dwread,dwNumber: cardinal;
  Str    : pansichar; // SIC! pansichar
  StatusCode: DWORD;
  RedirectCount: integer;
begin
  Response:='';
  AUrl := Url;

  hSession:=InternetOpen(USER_AGENT, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if not Assigned(hSession) then
    raise Exception.Create('Error initializing WinInet: ' + SysErrorMessage(GetLastError));
  try
    RedirectCount := 0;
    while true do
    begin
      hRequest:=InternetOpenUrl(hsession, pchar(AUrl), nil, 0, INTERNET_FLAG_RELOAD, 0);
      if not Assigned(hRequest) then
        raise Exception.Create('Error opening request: ' + SysErrorMessage(GetLastError));
      try
        StatusCode := GetStatusCode(hRequest);
        if (StatusCode >= 300) and (StatusCode < 400) then
        begin
          Inc(RedirectCount);

          // Stop following redirects if we exceed the maximum number of allowed redirects.
          if RedirectCount > MaxRedirects then
          begin
            raise Exception.Create('Error: Too many redirects');
          end;

          // Get the "Location" header for the new URL
          AURL := GetRedirectLocation(hRequest);
        end
        else if (StatusCode = 200) then // do not localize
        begin
          dwNumber := 1024;
          while (InternetReadfile(hRequest, @databuffer, dwNumber, DwRead)) do
          begin
            if dwRead =0 then
              break;
            databuffer[dwread]:=#0;
            Str := pansichar(@databuffer);
            Response := Response + Str;
          end;

          // Output the server response.
          Result := Response;

          break;
        end
        else
          raise Exception.CreateFmt('HTTP Error %d with GET request %s', [StatusCode, aurl]);
      finally
        InternetCloseHandle(hRequest);
      end;
    end;
  finally
    InternetCloseHandle(hsession);
  end;
end;

procedure _GalleryComparison(AdoConnection1: TAdoConnection; CacheTime: integer);
var
  GalleryListWeb, URLListWeb, DescListWeb, IdListDB, URLListDB, CmNameListDB, ArtNameListDB: TStringList;

  procedure GetGallerySubmissions(const UserName: string);
  var
    i: Integer;
    WebContent: string;
  begin
    // GET Request ausführen und das Ergebnis als Text holen
    WebContent := _WinInet_DoGet(Format(_VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''DMX_UPLOADCHECK_GALLERYLIST'';')), [UserName, CacheTime]));

    // Zeilenweise durchgehen und die URLs (gerade Zeilen) und Beschreibungen (ungerade Zeilen) speichern
    with TStringList.Create do
    try
      Text := WebContent;
      for i := 0 to Count - 1 do
      begin
        if (i mod 2 = 0) then
        begin
          // URLs (gerade Zeilen: 0, 2, 4, ...)
          GalleryListWeb.Add(UserName);
          URLListWeb.Add(Trim(Strings[i]));
        end
        else
        begin
          // Beschreibungen (ungerade Zeilen: 1, 3, 5, ...)
          DescListWeb.Add(Trim(Strings[i]));
        end;
      end;
    finally
      Free;
    end;
  end;

var
  i: integer;
  qUpload, qMandator: TAdoDataSet;
  users: TArray<string>;
begin
  if not AdoConnection1.TableExists(TempTableName(GUID_1, 'UPLOAD_MISSING_IN_CMDB')) then
  begin
    AdoConnection1.ExecSQL('create table '+TempTableName(GUID_1, 'UPLOAD_MISSING_IN_CMDB')+' ( ' + #13#10 +
                           '__ID uniqueidentifier NOT NULL, ' + #13#10 +
                           '__MANDATOR_ID uniqueidentifier NOT NULL, ' + #13#10 +
                           'GALLERY nvarchar(250), ' + #13#10 +
                           'URL nvarchar(250), ' + #13#10 +
                           'TITLE nvarchar(250) );');
  end;
  AdoConnection1.ExecSQL('delete from '+TempTableName(GUID_1, 'UPLOAD_MISSING_IN_CMDB')); // TODO: might this cause problems with already open windows of that statistics plugin? But if we don't delete them, we might have duplicates in the output

  if not AdoConnection1.TableExists(TempTableName(GUID_2, 'UPLOAD_MISSING_IN_WEB')) then
  begin
    AdoConnection1.ExecSQL('create table '+TempTableName(GUID_2, 'UPLOAD_MISSING_IN_WEB')+' ( ' + #13#10 +
                           '__ID uniqueidentifier NOT NULL, ' + #13#10 +
                           '__MANDATOR_ID uniqueidentifier NOT NULL, ' + #13#10 +
                           'URL nvarchar(250), ' + #13#10 +
                           'ARTIST_OR_CLIENT nvarchar(250), ' + #13#10 +
                           'COMMISSION nvarchar(250) );');
  end;
  AdoConnection1.ExecSQL('delete from '+TempTableName(GUID_2, 'UPLOAD_MISSING_IN_WEB')); // TODO: might this cause problems with already open windows of that statistics plugin? But if we don't delete them, we might have duplicates in the output

  // Initialisierung der Komponenten
  GalleryListWeb := TStringList.Create;
  URLListWeb := TStringList.Create;
  DescListWeb := TStringList.Create;
  IdListDB := TStringList.Create;
  URLListDB := TStringList.Create;
  CmNameListDB := TStringList.Create;
  ArtNameListDB := TStringList.Create;

  try
    users := _VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''DMX_UPLOADCHECK_USERS'';')).Split([';']);
    for i := Low(users) to High(users) do
    begin
      GetGallerySubmissions(users[i]);
    end;

    qMandator := AdoConnection1.GetTable('select ID from MANDATOR');
    try
      while not qMandator.EOF do
      begin
        // Datenbankabfrage ausführen, um die URLs aus der Datenbank in URLListDB zu speichern
        qUpload := AdoConnection1.GetTable('select up.URL, cm.ID as COMMISSION_ID, cm.NAME as COMMISSION_NAME, art.NAME as ARTIST_NAME ' +
                                     'from UPLOAD up '+
                                     'left join COMMISSION_EVENT ev on ev.ID = up.EVENT_ID ' +
                                     'left join COMMISSION cm on cm.ID = ev.COMMISSION_ID ' +
                                     'left join ARTIST art on art.ID = cm.ARTIST_ID '+
                                     'left join MANDATOR man on man.ID = art.MANDATOR_ID ' +
                                     'where ev.STATE = iif(art.IS_ARTIST=1,N''upload c'',N''upload a'') and ' + // TODO: wenn ich die person bin, dann ist upload a == upload c
                                     '      up.URL like (select isnull(VALUE,N''%'') from CONFIG where NAME = N''DMX_UPLOADCHECK_URLPART'') and ' +
                                     '      man.ID = '''+qMandator.FieldByName('ID').AsWideString+''';');
        try
          // URL-Liste aus der Datenbank in URLListDB speichern
          IdListDB.Clear;
          URLListDB.Clear;
          CmNameListDB.Clear;
          ArtNameListDB.Clear;
          while not qUpload.Eof do
          begin
            IdListDB.Add(Trim(qUpload.FieldByName('COMMISSION_ID').AsWideString));
            URLListDB.Add(Trim(qUpload.FieldByName('URL').AsWideString));
            CmNameListDB.Add(Trim(qUpload.FieldByName('COMMISSION_NAME').AsWideString));
            ArtNameListDB.Add(Trim(qUpload.FieldByName('ARTIST_NAME').AsWideString));
            qUpload.Next;
          end;
        finally
          qUpload.Free;
        end;

        // URLs, die nur im Web sind (aber nicht in der Datenbank)
        for i := 0 to URLListWeb.Count - 1 do
        begin
          if URLListDB.IndexOf(URLListWeb[i]) = -1 then
          begin
            AdoConnection1.ExecSQL('insert into '+TempTableName(GUID_1, 'UPLOAD_MISSING_IN_CMDB')+' '+
                                   'select ' +
                                   '    CONVERT(UNIQUEIDENTIFIER, HASHBYTES(''SHA1'', N'+AdoConnection1.SQLStringEscape(URLListWeb[i])+')) as __ID, ' +
                                   '    '''+qMandator.FieldByName('ID').AsWideString+''' as __MANDATOR, ' +
                                   '    '+AdoConnection1.SQLStringEscape(GalleryListWeb[i])+' as GALLERY, ' +
                                   '    '+AdoConnection1.SQLStringEscape(URLListWeb[i])+' as URL, ' +
                                   '    '+AdoConnection1.SQLStringEscape(DescListWeb[i])+' as TITLE ' +
                                   ';');
          end;
        end;

        // URLs, die nur in der Datenbank sind (aber nicht im Web)
        for i := 0 to URLListDB.Count - 1 do
        begin
          if URLListWeb.IndexOf(URLListDB[i]) = -1 then
          begin
            AdoConnection1.ExecSQL('insert into '+TempTableName(GUID_2, 'UPLOAD_MISSING_IN_WEB')+' '+
                                   'select ' +
                                   '    '+AdoConnection1.SQLStringEscape(IdListDB[i])+' as __ID, ' +
                                   '    '''+qMandator.FieldByName('ID').AsWideString+''' as __MANDATOR, ' +
                                   '    '+AdoConnection1.SQLStringEscape(URLListDB[i])+' as URL, ' +
                                   '    '+AdoConnection1.SQLStringEscape(ArtNameListDB[i])+' as ARTIST_OR_CLIENT, ' +
                                   '    '+AdoConnection1.SQLStringEscape(CmNameListDB[i])+' as COMMISSION ' +
                                   ';');
          end;
        end;

        qMandator.Next;
      end;
    finally
      FreeAndNil(qMandator);
    end;

  finally
    // Freigabe der Ressourcen
    URLListWeb.Free;
    DescListWeb.Free;
    URLListDB.Free;
    CmNameListDB.Free;
    ArtNameListDB.Free;
    IdListDB.Free;
    GalleryListWeb.Free;
  end;
end;

function ClickEventW(DBConnStr: PChar; MandatorGuid, StatGuid,
  ItemGuid: TGuid; ResponseData: Pointer): HRESULT; stdcall;
var
  AdoConn: TADOConnection;
  Response: TCmDbPluginClickResponse;
resourcestring
  SReloadQuestion = 'Load up-to-date date from online galleries? (Takes a long time)';
begin
  if ResponseData = nil then Exit(E_PLUGIN_BAD_ARGS);
  try
    Response.Handled := false;

    {$REGION 'Stat 1: Uploads found at FA, but not in CMDB'}
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
          case MessageBox(0, PChar(SReloadQuestion), PChar(DESC_PLUGIN_SHORT), MB_YESNOCANCEL or MB_ICONQUESTION or MB_TASKMODAL) of
            ID_YES:
              _GalleryComparison(AdoConn, 1);
            ID_NO:
              _GalleryComparison(AdoConn, 999999999);
            ID_CANCEL:
            begin
              Response.Handled := true;
              Response.Action := craNone;
            end;
          end;
        finally
          FreeAndNil(AdoConn);
        end;
        if not Response.Handled then
        begin
          Response.Handled := true;
          Response.Action := craStatistics;
          Response.StatId := StatGuid;
          Response.StatName := DESC_1;
          Response.SqlTable := TempTableName(GUID_1, 'UPLOAD_MISSING_IN_CMDB');
          Response.SqlInitialOrder := 'GALLERY, len(URL), URL, TITLE';
          Response.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
          Response.BaseTableDelete := '';
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
          try
            Response.Handled := true;
            Response.Action := craNone;
            ShellExecute(0, 'open', PChar(_VariantToString(AdoConn.GetScalar('select URL from '+TempTableName(GUID_1, 'UPLOAD_MISSING_IN_CMDB')+' where __ID = ''' + ItemGuid.ToString + ''''))), '', '', SW_NORMAL);
          except
            on E: EAbort do Exit(E_ABORT);
            on E: Exception do Exit(E_PLUGIN_GENERIC_FAILURE);
          end;
        finally
          FreeAndNil(AdoConn);
        end;
      end;
    end;
    {$ENDREGION}

    {$REGION 'Stat 2: Uploads found in CMDB, but not at Web'}
    if IsEqualGuid(StatGuid, GUID_2) then
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
          case MessageBox(0, PChar(SReloadQuestion), PChar(DESC_PLUGIN_SHORT), MB_YESNOCANCEL or MB_ICONQUESTION or MB_TASKMODAL) of
            ID_YES:
              _GalleryComparison(AdoConn, 1);
            ID_NO:
              _GalleryComparison(AdoConn, 999999999);
            ID_CANCEL:
            begin
              Response.Handled := true;
              Response.Action := craNone;
            end;
          end;
        finally
          FreeAndNil(AdoConn);
        end;
        if not Response.Handled then
        begin
          Response.Handled := true;
          Response.Action := craStatistics;
          Response.StatId := StatGuid;
          Response.StatName := DESC_2;
          Response.SqlTable := TempTableName(GUID_2, 'UPLOAD_MISSING_IN_WEB');
          Response.SqlInitialOrder := 'ARTIST_OR_CLIENT, COMMISSION, URL';
          Response.SqlAdditionalFilter := '__MANDATOR_ID = ''' + MandatorGuid.ToString + '''';
          Response.BaseTableDelete := 'COMMISSION';
          Response.ScrollToEnd := false;
          Response.DisplayEditFormats := '';
        end;
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
    on E: EAbort do Exit(E_ABORT);
    on E: Exception do Exit(E_PLUGIN_GENERIC_FAILURE);
  end;
end;

exports
  VtsPluginID, InitW, ClickEventW;

begin
end.
