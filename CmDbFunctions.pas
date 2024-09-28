unit CmDbFunctions;

interface

uses
  Windows, Forms, Variants, Graphics, Classes, DBGrids, AdoDb, AdoConnHelper, SysUtils,
  Db, DateUtils;

function ShellExecuteWait(aWnd: HWND; Operation: string; ExeName: string; Params: string; WorkingDirectory: string; ncmdShow: Integer; wait: boolean): Integer;
function GetUserDirectory: string;
procedure CmDb_RestoreDatabase(AdoConnection1: TAdoConnection; const BakFilename: string);
procedure CmDb_ConnectViaLocalDb(AdoConnection1: TAdoConnection; const DataBaseName: string);
procedure CmDb_InstallOrUpdateSchema(AdoConnection1: TAdoConnection);
function VariantToInteger(Value: Variant): Integer;
function VariantToString(const Value: Variant): string;
function CmDbShowRows(ttQuery: TDataSet): string;
function GetBuildTimestamp(const ExeFile: string): TDateTime;
procedure SaveGridToCsv(grid: TDbGrid; const filename: string);
function TitleButtonHelper(Column: TColumn): boolean;
function AscDesc(asc: boolean): string;
procedure AdoQueryRefresh(ADataset: TAdoQuery; const ALocateField: string);
procedure InsteadOfDeleteWorkaround(DataSet: TAdoQuery; const localField, baseTable, baseTableField: string);

implementation

uses
  ShlObj, ShellApi;

// Returns Windows Error Code (i.e. 0=success), NOT the ShellExecute() code (>32 = success)
function ShellExecuteWait(aWnd: HWND; Operation: string; ExeName: string; Params: string; WorkingDirectory: string; ncmdShow: Integer; wait: boolean): Integer;

  function _ShellExecuteWait(aWnd: HWND; Operation, FileName, Parameters, Directory: string; ShowCmd: Integer; wait: boolean): Integer;
  var
    Info: TShellExecuteInfo;
    pInfo: PShellExecuteInfo;
    exitCode: DWord; // Achtung: Muss DWORD sein (Ticket 38498)
    wdir: PChar;
  begin
    pInfo := @Info;
    ZeroMemory(pInfo, SizeOf(Info));
    if Directory = '' then wdir := nil else wdir := PChar(Directory);
    with Info do
    begin
      cbSize       := SizeOf(Info);
      fMask        := SEE_MASK_NOCLOSEPROCESS;
      wnd          := aWnd;
      lpVerb       := PChar(Operation);
      lpFile       := PChar(FileName);
      lpParameters := PChar(Parameters + #0);
      lpDirectory  := wdir;
      nShow        := ShowCmd;
      hInstApp     := 0;
    end;

    if not ShellExecuteEx(pInfo) then
    begin
      result := -GetLastError;
      exit;
    end;

    try
      if not wait then
      begin
        result := 0;
        exit;
      end;

      repeat
        exitCode := WaitForSingleObject(Info.hProcess, 100);
        Sleep(50);
        if Windows.GetCurrentThreadId = System.MainThreadID then
          Application.ProcessMessages;
        if Assigned(Application) and Application.Terminated then Abort;
      until (exitCode <> WAIT_TIMEOUT);

      if not GetExitCodeProcess(Info.hProcess, exitCode) then
      begin
        result := -GetLastError;
        exit;
      end;

      result := exitCode;
    finally
      if Info.hProcess <> 0 then
        CloseHandle(Info.hProcess);
    end;
  end;

  function _CreateProcess(Operation, FileName, Parameters, Directory: string; ShowCmd: Integer; wait: boolean): Integer;
  var
      StartupInfo: TStartupInfo;
      ProcessInformation: TProcessInformation;
      Res: Bool;
      lpExitCode: DWORD;
      ExeAndParams: string;
      wdir: PChar;
  begin
      FillChar(StartUpInfo, sizeof(tstartupinfo), 0);
      with StartupInfo do
      begin
          cb := SizeOf(TStartupInfo);
          lpReserved := nil;
          lpDesktop := nil;
          lpTitle := nil;
          dwFlags := STARTF_USESHOWWINDOW;
          wShowWindow := ncmdShow;
          cbReserved2 := 0;
          lpReserved2 := nil;
      end;
      ExeAndParams := '"' + ExeName + '" ' + params;
      if Directory = '' then wdir := nil else wdir := PChar(Directory);
      Res := CreateProcess(PChar(ExeName), PChar(ExeAndParams), nil, nil, True,
          CREATE_DEFAULT_ERROR_MODE
          or NORMAL_PRIORITY_CLASS, nil, wdir, StartupInfo, ProcessInformation);
      try
        if not Res then
        begin
          result := -GetLastError;
          exit;
        end;
        if not Wait then
        begin
          Result := 0;
          exit;
        end;
        while True do
        begin
            GetExitCodeProcess(ProcessInformation.hProcess, lpExitCode);
            if lpExitCode <> STILL_ACTIVE then
                Break;
            Sleep(50);
            if Windows.GetCurrentThreadId = System.MainThreadID then
              Application.ProcessMessages;
            if Assigned(Application) and Application.Terminated then Abort;
        end;
        Result := Integer(lpExitCode);
      finally
        if ProcessInformation.hProcess <> 0 then
          CloseHandle(ProcessInformation.hProcess);
        if ProcessInformation.hThread <> 0 then
          CloseHandle(ProcessInformation.hThread);
      end;
  end;

begin
  if not SameText(Operation, 'open') then
  begin
    result := _ShellExecuteWait(awnd, PChar(Operation), PChar(ExeName), PChar(Params), PChar(WorkingDirectory), ncmdShow, wait);
    exit;
  end;

  result := _CreateProcess(Operation, ExeName, Params, WorkingDirectory, ncmdshow, wait);
  if (result = -193) then  // Fehler 193 = Keine zulässige Win32-Anwendung (z.B. "Hallo.txt")
  begin
    result := _ShellExecuteWait(awnd, PChar(Operation), PChar(ExeName), PChar(Params), PChar(WorkingDirectory), ncmdShow, wait);
  end;
end;

function GetUserDirectory: string;
var
  Path: array [0..MAX_PATH] of Char;
begin
  // Use SHGetFolderPath to get the user profile directory
  if Succeeded(SHGetFolderPath(0, CSIDL_PROFILE, 0, 0, @Path[0])) then
    Result := Path
  else
    Result := ''; // Return an empty string if it fails
end;

const
  LogicalNameData = 'cmdb_data';
  LogicalNameLog = 'cmdb_log';

procedure CmDb_RestoreDatabase(AdoConnection1: TAdoConnection; const BakFilename: string);
const
  TempDbName = 'cmdb2_recovery_temp';
var
  AdoConnection2: TAdoConnection;
begin
  ADOConnection1.ExecSQL(
    'IF EXISTS (SELECT name FROM sys.databases WHERE name = N'+AdoConnection1.SQLStringEscape(TempDbName)+') ' +
    'BEGIN ' +
    '    ALTER DATABASE '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+' SET SINGLE_USER WITH ROLLBACK IMMEDIATE; ' +
    '    DROP DATABASE '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+'; ' +
    'END;');

  ADOConnection1.ExecSQL(
    'RESTORE DATABASE '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+' ' +
    'FROM DISK = N'+AdoConnection1.SQLStringEscape(BakFileName)+' ' +
    'WITH ' +
    '    MOVE N'+AdoConnection1.SQLStringEscape(LogicalNameData)+' TO N'+AdoConnection1.SQLStringEscape(IncludeTrailingPathDelimiter(GetUserDirectory) + TempDbName + '.mdf')+', ' +
    '    MOVE N'+AdoConnection1.SQLStringEscape(LogicalNameLog)+' TO N'+AdoConnection1.SQLStringEscape(IncludeTrailingPathDelimiter(GetUserDirectory) + TempDbName + '.ldf')+', ' +
    '    REPLACE, ' +
    '    RECOVERY;');

  // Make sure the schema is equal
  ADOConnection2 := TAdoConnection.Create(AdoConnection1.Owner);
  try
    AdoConnection2.LoginPrompt := false;
    CmDb_ConnectViaLocalDb(AdoConnection2, TempDbName);
    CmDb_InstallOrUpdateSchema(AdoConnection2);
    AdoConnection2.Disconnect;
  finally
    AdoConnection2.Free;
  end;

  AdoConnection1.BeginTrans;
  try
    AdoConnection1.ExecSQL('delete from [MANDATOR];');
    AdoConnection1.ExecSQL('delete from [ARTIST];');
    AdoConnection1.ExecSQL('delete from [ARTIST_EVENT];');
    AdoConnection1.ExecSQL('delete from [COMMISSION];');
    AdoConnection1.ExecSQL('delete from [COMMISSION_EVENT];');
    AdoConnection1.ExecSQL('delete from [PAYMENT];');
    AdoConnection1.ExecSQL('delete from [QUOTE];');
    AdoConnection1.ExecSQL('delete from [UPLOAD];');
    AdoConnection1.ExecSQL('delete from [COMMUNICATION];');
    AdoConnection1.ExecSQL('delete from [CONFIG];');
    //AdoConnection1.ExecSQL('delete from [TEXT_BACKUP];');

    AdoConnection1.ExecSQL('insert into [MANDATOR] select * from '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+'.[dbo].[MANDATOR];');
    AdoConnection1.ExecSQL('insert into [ARTIST] select * from '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+'.[dbo].[ARTIST];');
    AdoConnection1.ExecSQL('insert into [ARTIST_EVENT] select * from '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+'.[dbo].[ARTIST_EVENT];');
    AdoConnection1.ExecSQL('insert into [COMMISSION] select * from '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+'.[dbo].[COMMISSION];');
    AdoConnection1.ExecSQL('insert into [COMMISSION_EVENT] select * from '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+'.[dbo].[COMMISSION_EVENT];');
    AdoConnection1.ExecSQL('insert into [PAYMENT] select * from '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+'.[dbo].[PAYMENT];');
    AdoConnection1.ExecSQL('insert into [QUOTE] select * from '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+'.[dbo].[QUOTE];');
    AdoConnection1.ExecSQL('insert into [UPLOAD] select * from '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+'.[dbo].[UPLOAD];');
    AdoConnection1.ExecSQL('insert into [COMMUNICATION] select * from '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+'.[dbo].[COMMUNICATION];');
    AdoConnection1.ExecSQL('insert into [CONFIG] select * from '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+'.[dbo].[CONFIG];');
    //AdoConnection1.ExecSQL('insert into [TEXT_BACKUP] select * from '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+'.[dbo].[TEXT_BACKUP];');

    AdoConnection1.CommitTrans;
  except
    AdoConnection1.RollbackTrans;
    raise;
  end;

  // For some reason I CmDb2.exe keeps the connection to the temp db, so we need to forcefully disconnect. Weird!
  ADOConnection1.ExecSQL('ALTER DATABASE '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;');

  ADOConnection1.ExecSQL('DROP DATABASE '+AdoConnection1.SQLDatabaseNameEscape(TempDbName));
end;

procedure CmDb_ConnectViaLocalDb(AdoConnection1: TAdoConnection; const DataBaseName: string);
begin
  // Troubleshoot default instance not working:
  // 1. Install LocalDB
  // 2. sqllocaldb create MSSQLLocalDB
  //    sqllocaldb start MSSQLLocalDB

  ADOConnection1.ConnectNtAuth('(localdb)\MSSQLLocalDB', 'master');
  ADOConnection1.ExecSQL(
    'IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'+AdoConnection1.SQLStringEscape(DataBaseName)+') ' +
    'BEGIN ' +
    '  CREATE DATABASE '+AdoConnection1.SQLDatabaseNameEscape(DataBaseName)+' ' +
    '  ON PRIMARY ' +
    '  ( ' +
    '      NAME = N'+AdoConnection1.SQLStringEscape(LogicalNameData)+', '+
    '      FILENAME = N'+AdoConnection1.SQLStringEscape(IncludeTrailingPathDelimiter(GetUserDirectory) + DatabaseName + '.mdf')+', '+
    '      SIZE = 10MB, ' +
    '      MAXSIZE = UNLIMITED, ' +
    '      FILEGROWTH = 5MB ' +
    '  ) ' +
    '  LOG ON ' +
    '  ( ' +
    '      NAME = N'+AdoConnection1.SQLStringEscape(LogicalNameLog)+', '+
    '      FILENAME = N'+AdoConnection1.SQLStringEscape(IncludeTrailingPathDelimiter(GetUserDirectory) + DatabaseName + '.ldf')+', ' +
    '      SIZE = 5MB, ' +
    '      MAXSIZE = 50MB, ' +
    '      FILEGROWTH = 1MB ' +
    '  ); ' +
    '  ALTER DATABASE '+AdoConnection1.SQLDatabaseNameEscape(DataBaseName)+' SET MULTI_USER; ' +
    'END'
  );
  ADOConnection1.ConnectNtAuth('(localdb)\MSSQLLocalDB', DataBaseName);
end;

procedure CmDb_InstallOrUpdateSchema(AdoConnection1: TAdoConnection);
resourcestring
  SSchemaDUnknown = 'Schema %d is unknown. The database is probably newer than the software version.';
  SDbInstallError = 'DB Install %s error: %s';

  procedure InstallSql(targetSchema: integer; fil: string);
  var
    sl: TStringList;
  begin
    try
      sl := TStringList.Create;
      try
        sl.LoadFromFile(ExtractFilePath(ParamStr(0))+'\DB\Schema'+IntToStr(targetSchema)+'\'+'['+fil+'].sql');
        AdoConnection1.ExecSQL(sl.Text);
      finally
        sl.Free;
      end;
    except
      on E: Exception do
      begin
        raise Exception.CreateFmt(SDbInstallError, [fil, E.Message]);
      end;
    end;
  end;

var
  schemaVer: integer;
begin
  while true do
  begin
    if not AdoConnection1.TableExists('CONFIG') then
      schemaVer := 0
    else
      schemaVer := VariantToInteger(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''DB_VERSION'';'));

    if schemaVer = 0 then
    begin
      {$REGION 'Install schema 1'}
      if not AdoConnection1.TableExists('CONFIG') then
        InstallSql(1, 'CONFIG');
      if not AdoConnection1.TableExists('MANDATOR') then
        InstallSql(1, 'MANDATOR');
      if not AdoConnection1.TableExists('ARTIST') then
        InstallSql(1, 'ARTIST');
      if not AdoConnection1.TableExists('ARTIST_EVENT') then
        InstallSql(1, 'ARTIST_EVENT');
      if not AdoConnection1.TableExists('COMMISSION') then
        InstallSql(1, 'COMMISSION');
      if not AdoConnection1.TableExists('COMMISSION_EVENT') then
        InstallSql(1, 'COMMISSION_EVENT');
      if not AdoConnection1.TableExists('QUOTE') then
        InstallSql(1, 'QUOTE');
      if not AdoConnection1.TableExists('UPLOAD') then
        InstallSql(1, 'UPLOAD');
      if not AdoConnection1.TableExists('PAYMENT') then
        InstallSql(1, 'PAYMENT');
      if not AdoConnection1.TableExists('COMMUNICATION') then
        InstallSql(1, 'COMMUNICATION');
      if not AdoConnection1.TableExists('STATISTICS') then
        InstallSql(1, 'STATISTICS');
      if not AdoConnection1.TableExists('TEXT_BACKUP') then
        InstallSql(1, 'TEXT_BACKUP');

      InstallSql(1, 'vw_CONFIG');
      InstallSql(1, 'vw_MANDATOR');

      InstallSql(1, 'vw_COMMISSION');
      InstallSql(1, 'vw_ARTIST'); // requires vw_COMMISSION
      InstallSql(1, 'vw_ARTIST_EVENT');
      InstallSql(1, 'vw_COMMISSION_EVENT');
      InstallSql(1, 'vw_QUOTE');
      InstallSql(1, 'vw_UPLOAD');
      InstallSql(1, 'vw_PAYMENT');
      InstallSql(1, 'vw_COMMUNICATION');
      InstallSql(1, 'vw_STATISTICS');
      InstallSql(1, 'vw_TEXT_BACKUP');

      InstallSql(1, 'vw_STAT_RUNNING_COMMISSIONS');
      InstallSql(1, 'vw_STAT_SUM_YEARS');
      InstallSql(1, 'vw_STAT_SUM_MONTHS');
      InstallSql(1, 'vw_STAT_TEXT_EXPORT');
      InstallSql(1, 'vw_STAT_TOP_ARTISTS');

      InstallSql(1, 'DEFAULT'); // STATISTICS and CONFIG entries
      {$ENDREGION}
    end
    else if schemaVer = 1 then
    begin
      // Future update code goes here!
      // ...
      //AdoConnection1.ExecSQL('update CONFIG set VALUE = ''2'' where NAME = ''DB_VERSION''');


      // TODO: Once all things are decided, label everything as Schema #2
      if AdoConnection1.ViewExists('vw_STATISTICS') then
        AdoConnection1.DropTableOrView('vw_STATISTICS');
      if AdoConnection1.TableExists('STATISTICS') then
        AdoConnection1.DropTableOrView('STATISTICS');

      InstallSql(2, 'vw_STAT_TOP_ARTISTS');
      InstallSql(2, 'vw_STAT_RUNNING_COMMISSIONS');
      InstallSql(2, 'vw_STAT_TEXT_EXPORT');


      // We have reached the highest supported version and can now exit the loop.
      Exit;
    end
    else
    begin
      raise Exception.CreateFmt(SSchemaDUnknown, [schemaVer]);
    end;
  end;
end;

function VariantToInteger(Value: Variant): Integer;
begin
  if VarIsNull(Value) then
    Result := 0
  else
    Result := Value;
end;

function VariantToString(const Value: Variant): string;
begin
  if VarIsNull(Value) then
    Result := ''
  else
    Result := VarToStr(Value);
end;

function CmDbShowRows(ttQuery: TDataSet): string;
resourcestring
  SDRow = '%s row';
  SDRows = '%s rows';
begin
  if ttQuery.RecordCount = 0 then
    result := ''
  else if ttQuery.RecordCount = 1 then
    result := Format(SDRow, [IntToStr(ttQuery.RecordCount)])
  else
    result := Format(SDRows, [IntToStr(ttQuery.RecordCount)]);
end;

function GetBuildTimestamp(const ExeFile: string): TDateTime;
var
  fs: TFileStream;
  unixTime: integer;
  peOffset: Integer;
begin
  try
    fs := TFileStream.Create(ExeFile, fmOpenRead or fmShareDenyNone);
    try
      fs.Seek($3C, soFromBeginning);
      fs.Read(peOffset, 4);

      fs.Seek(peOffset+8, soFromBeginning);
      fs.Read(unixTime, 4);

      {$IF CompilerVersion >= 20.0} // geraten
      result := UnixToDateTime(unixTime, false);
      {$ELSE}
      result := UnixToDateTime(unixTime);
      {$IFEND}
    finally
      FreeAndNil(fs);
    end;
  except
    // Sollte nicht passieren
    if not FileAge(ExeFile, result) then
      raise Exception.CreateFmt('GetBuildTimestamp(%s) fehlgeschlagen', [ExeFile]);
  end;
end;

procedure SaveGridToCsv(grid: TDBGrid; const filename: string);
var
  i: Integer;
  csvFile: TStreamWriter;
  line: string;
  bookmark: TBookmark;
begin
  // Save current record position (Bookmark)
  bookmark := grid.DataSource.DataSet.GetBookmark;

  // Create StreamWriter to write the CSV file in UTF-8 encoding
  csvFile := TStreamWriter.Create(filename, False, TEncoding.UTF8);
  try
    // Write column headers as the first row
    line := '';
    for i := 0 to grid.Columns.Count - 1 do
    begin
      line := line + '"' + StringReplace(grid.Columns[i].Title.Caption, '"', '""', [rfReplaceAll]) + '"';
      if i < grid.Columns.Count - 1 then
        line := line + ';';
    end;
    csvFile.WriteLine(line);

    // Iterate through the dataset rows and write each one to the CSV
    grid.DataSource.DataSet.First;
    while not grid.DataSource.DataSet.Eof do
    begin
      line := '';
      for i := 0 to grid.Columns.Count - 1 do
      begin
        // Fetch the field value and append to CSV line
        line := line + '"' + StringReplace(grid.Columns[i].Field.AsWideString, '"', '""', [rfReplaceAll]) + '"';
        if i < grid.Columns.Count - 1 then
          line := line + ';';
      end;
      csvFile.WriteLine(line);
      grid.DataSource.DataSet.Next;
    end;
  finally
    // Close the CSV file
    csvFile.Free;

    // Return to the saved record position (Bookmark)
    if grid.DataSource.DataSet.BookmarkValid(bookmark) then
      grid.DataSource.DataSet.GotoBookmark(bookmark);

    // Free the bookmark
    grid.DataSource.DataSet.FreeBookmark(bookmark);
  end;
end;

function TitleButtonHelper(Column: TColumn): boolean; // true=asc
var
  i: integer;
begin
  assert(Column.Field.DataSet.Active); // if dataset is not active, then Field.FieldNo is 0, which is bad.

  for i := 0 to TDbGrid(Column.Grid).Columns.Count-1 do
  begin
    if i = Column.Index then
      TDbGrid(Column.Grid).Columns.Items[i].Color := clAqua
    else
      TDbGrid(Column.Grid).Columns.Items[i].Color := clWhite;
  end;

  // Tag =  0 means yet sorted by the OnTitleClick event.
  // Tag = +X means sorted by column X asc
  // Tag = -X means sorted by column X desc
  result := (Column.Grid.Tag <> Column.Field.FieldNo);
  if result then
    Column.Grid.Tag := Column.Field.FieldNo
  else
    Column.Grid.Tag := -Column.Field.FieldNo;
end;

function AscDesc(asc: boolean): string;
begin
  if asc then
    result := 'asc'
  else
    result := 'desc';
end;

procedure AdoQueryRefresh(ADataset: TAdoQuery; const ALocateField: string);
var
  id: string;
begin
  if ALocateField <> '' then
    id := ADataset.FieldByName(ALocateField).AsWideString
  else
    id := '';
  try
    ADataset.Requery;
  finally
    if id <> '' then ADataset.Locate(ALocateField, id, []);
  end;
end;

procedure InsteadOfDeleteWorkaround(DataSet: TAdoQuery; const localField, baseTable, baseTableField: string);
  // This procedure is used to prevent that a delete command in an ADO Query
  // causes deletion in all connected tables.
  // For some reason, if you delete something from a DBGrid, then the
  // command to the SQL Server will be delete commands to the connected tables.
  // There is no delete SQL query to the actual view; hence, it is not possible
  // to solve this with a "instead of delete" trigger on that view!
  // This procedure is a workaround for this. It will be called in the
  // BeforeDelete event of the view TAdoQuery, and it will delete the dataset
  // on the base table and then reload the query, trying to maintain the position.

var
  id: string;
begin
  Dataset.Connection.ExecSQL('delete from '+Dataset.Connection.SQLObjectNameEscape(basetable)+' where '+Dataset.Connection.SQLFieldNameEscape(baseTableField)+' = ''' + DataSet.FieldByName(localField).AsWideString + '''');

  Dataset.Next;
  if Dataset.EOF then Dataset.Prior;
  if Dataset.BOF then
    id := ''
  else
    id := Dataset.FieldByName(localField).AsWideString;
  try
    Dataset.Requery;
  finally
    if id <> '' then Dataset.Locate(localField, id, []);
  end;

  Abort;
end;

end.
