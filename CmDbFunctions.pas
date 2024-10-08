unit CmDbFunctions;

interface

uses
  Windows, Forms, Variants, Graphics, Classes, DBGrids, AdoDb, AdoConnHelper, SysUtils,
  Db, DateUtils, Vcl.Grids, System.UITypes, VCL.DBCtrls;

procedure CmDbDropTempTables(AdoConnection1: TAdoConnection);
function CmDbGetPasswordHash(AdoConnection1: TAdoConnection; const password: string): string;
procedure DefragIndexes(AdoConnection: TAdoConnection; FragmentierungSchwellenWert: integer=10);
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

procedure InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbg: TDBGrid; nav: TDBNavigator);
procedure InsteadOfDeleteWorkaround_BeforeEdit(DataSet: TCustomADODataSet; const localField: string);
procedure InsteadOfDeleteWorkaround_BeforeDelete(DataSet: TCustomADODataSet; const localField, baseTable, baseTableField: string);
procedure InsteadOfDeleteWorkaround_DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState; const localField: string);

implementation

uses
  ShlObj, ShellApi, System.Hash, Dialogs;

const
  LOCALDB_INSTANCE_NAME = 'MSSQLLocalDB';

procedure CmDbDropTempTables(AdoConnection1: TAdoConnection);
var
  q: TAdoDataSet;
begin
  q := AdoConnection1.GetTable('select name from sysobjects where name like ''tmp_%'';');
  try
    while not q.EOF do
    begin
      AdoConnection1.DropTableOrView(q.Fields[0].AsWideString);
      q.Next;
    end;
  finally
    FreeAndNil(q);
  end;
end;

function CmDbGetPasswordHash(AdoConnection1: TAdoConnection; const password: string): string;
var
  salt: string;
begin
  salt := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''INSTALL_ID'';'));
  result := THashSHA2.GetHashString(salt + password);
end;

procedure DefragIndexes(AdoConnection: TAdoConnection; FragmentierungSchwellenWert: integer=10);
var
  q: TAdoDataSet;
  SchemaName, TableName, IndexName: string;
begin
  q := AdoConnection.GetTable(
    'SELECT ' +
    '  s.name AS SchemaName, ' +
    '  t.name AS TableName, ' +
    '  i.name AS IndexName, ' +
    '  ips.index_type_desc AS IndexType, ' +
    '  ips.avg_fragmentation_in_percent ' +
    'FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, ''LIMITED'') ips ' +
    'JOIN sys.tables t ON ips.object_id = t.object_id ' +
    'JOIN sys.schemas s ON t.schema_id = s.schema_id ' +
    'JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id ' +
    'WHERE ips.avg_fragmentation_in_percent > '+IntToStr(FragmentierungSchwellenWert)+' ' +
    'ORDER BY ips.avg_fragmentation_in_percent DESC');
  try
    while not q.Eof do
    begin
      SchemaName := q.FieldByName('SchemaName').AsWideString;
      TableName := q.FieldByName('TableName').AsWideString;
      IndexName := q.FieldByName('IndexName').AsWideString;

      if q.FieldByName('IndexType').AsWideString = 'HEAP' then
      begin
        AdoConnection.ExecSQL(Format('ALTER TABLE [%s].[%s] REBUILD;', [SchemaName, TableName]));
      end
      else
      begin
        AdoConnection.ExecSQL(Format('ALTER INDEX [%s] ON [%s].[%s] REBUILD;', [IndexName, SchemaName, TableName]));
      end;

      q.Next;
    end;
  finally
    FreeAndNil(q);
  end;
end;

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
    FreeAndNil(AdoConnection2);
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
    //AdoConnection1.ExecSQL('delete from [BACKUP];');

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
    //AdoConnection1.ExecSQL('insert into [BACKUP] select * from '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+'.[dbo].[BACKUP];');

    AdoConnection1.CommitTrans;
  except
    AdoConnection1.RollbackTrans;
    raise;
  end;

  // For some reason CmDb2.exe keeps the connection to the temp db, so we need to forcefully disconnect. Weird!
  ADOConnection1.ExecSQL('ALTER DATABASE '+AdoConnection1.SQLDatabaseNameEscape(TempDbName)+' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;');

  ADOConnection1.ExecSQL('DROP DATABASE '+AdoConnection1.SQLDatabaseNameEscape(TempDbName));
end;

procedure CmDb_ConnectViaLocalDb(AdoConnection1: TAdoConnection; const DataBaseName: string);
begin
  // Troubleshoot default instance not working:
  // 1. Install LocalDB
  // 2. sqllocaldb create MSSQLLocalDB
  //    sqllocaldb start MSSQLLocalDB

  ADOConnection1.ConnectNtAuth('(localdb)\'+LOCALDB_INSTANCE_NAME, 'master');
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
  ADOConnection1.ConnectNtAuth('(localdb)\'+LOCALDB_INSTANCE_NAME, DataBaseName);
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
        sl.LoadFromFile(ExtractFilePath(ParamStr(0))+'\..\DB\Schema'+IntToStr(targetSchema)+'\'+'['+fil+'].sql');
        AdoConnection1.ExecSQL(sl.Text);
      finally
        FreeAndNil(sl);
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
      {$REGION 'Update schema 1 => 2'}

      {$REGION 'Statistics schema 2: Statistics are not in the core anymore, but instead in a Plugin'}
      if AdoConnection1.ColumnExists('STATISTICS', 'SQL_VIEW') or not AdoConnection1.TableExists('STATISTICS') then
      begin
        AdoConnection1.DropTableOrView('STATISTICS');
        InstallSql(2, 'STATISTICS');
        InstallSql(2, 'vw_STATISTICS');
      end;

      if AdoConnection1.TableExists('vw_STAT_RUNNING_COMMISSIONS') then
        AdoConnection1.DropTableOrView('vw_STAT_RUNNING_COMMISSIONS');
      if AdoConnection1.TableExists('vw_STAT_SUM_YEARS') then
        AdoConnection1.DropTableOrView('vw_STAT_SUM_YEARS');
      if AdoConnection1.TableExists('vw_STAT_SUM_MONTHS') then
        AdoConnection1.DropTableOrView('vw_STAT_SUM_MONTHS');
      if AdoConnection1.TableExists('vw_STAT_TOP_ARTISTS') then
        AdoConnection1.DropTableOrView('vw_STAT_TOP_ARTISTS');
      if AdoConnection1.TableExists('vw_STAT_TEXT_EXPORT') then
        AdoConnection1.DropTableOrView('vw_STAT_TEXT_EXPORT');
      {$ENDREGION}

      // The text dump generation is not a statistics anymore, but a core feature
      InstallSql(2, 'vw_TEXT_BACKUP_GENERATE');

      // Downpayment now uses the quote data rather than the commission date
      InstallSql(2, 'vw_COMMISSION');

      {$REGION 'New config table fields'}
      if not AdoConnection1.ColumnExists('CONFIG', 'READ_ONLY') then
      begin
        AdoConnection1.ExecSQL('alter table CONFIG add READ_ONLY bit;');
        AdoConnection1.ExecSQL('update CONFIG set READ_ONLY = 0');
        AdoConnection1.ExecSQL('alter table CONFIG alter column READ_ONLY bit NOT NULL');
      end;
      if not AdoConnection1.ColumnExists('CONFIG', 'HIDDEN') then
      begin
        AdoConnection1.ExecSQL('alter table CONFIG add HIDDEN bit;');
        AdoConnection1.ExecSQL('update CONFIG set HIDDEN = iif(NAME=''DB_VERSION'' or NAME=''CUSTOMIZATION_ID'' or NAME=''INSTALL_ID'', 1, 0)');
        AdoConnection1.ExecSQL('alter table CONFIG alter column HIDDEN bit NOT NULL');
      end;
      {$ENDREGION}

      AdoConnection1.ExecSQL('if not exists (select NAME from CONFIG where NAME = ''PASSWORD_HASHED'') '+
                             'insert into CONFIG (NAME, VALUE, READ_ONLY, HIDDEN) select ''PASSWORD_HASHED'', '''', 0, 1;');
      AdoConnection1.ExecSQL('if not exists (select NAME from CONFIG where NAME = ''NEW_PASSWORD'') '+
                             'insert into CONFIG (NAME, VALUE, READ_ONLY, HIDDEN) select ''NEW_PASSWORD'', '''', 0, 0;');
      InstallSql(2, 'vw_CONFIG');

      {$REGION 'Text dumps now as files and not in database anymore'}
      if AdoConnection1.TableExists('TEXT_BACKUP') then
      begin
        AdoConnection1.DropTableOrView('TEXT_BACKUP');
        AdoConnection1.DropTableOrView('vw_TEXT_BACKUP');
        InstallSql(2, 'BACKUP');
        InstallSql(2, 'vw_BACKUP');
      end;
      {$ENDREGION}

      AdoConnection1.ExecSQL('update COMMISSION_EVENT set STATE = ''c aw sk'' where STATE = ''ack''');

      AdoConnection1.ExecSQL('update CONFIG set VALUE = ''2'' where NAME = ''DB_VERSION''');

      AdoConnection1.ExecSQL('delete from CONFIG where NAME = ''CUSTOMIZATION_ID'''); // use INSTALL_ID instead

      {$ENDREGION}
    end
    else if schemaVer = 2 then
    begin
      // <<< Future update code goes here! >>>

      //AdoConnection1.ExecSQL('update CONFIG set VALUE = ''3'' where NAME = ''DB_VERSION''');

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
    FreeAndNil(csvFile);

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

// These 4 procedures are used to prevent that a delete command in an ADO Query
// causes deletion in all connected tables.
// For some reason, if you delete something from a DBGrid, then the
// command to the SQL Server will be delete commands to the connected tables.
// There is no delete SQL query to the actual view; hence, it is not possible
// to solve this with a "instead of delete" trigger on that view!

var
  DeletedList: TStringList;

procedure InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbg: TDBGrid; nav: TDBNavigator);
begin
  nav.ConfirmDelete := false;
  dbg.Options := dbg.Options - [dgConfirmDelete];
end;

procedure InsteadOfDeleteWorkaround_BeforeEdit(DataSet: TCustomADODataSet; const localField: string);
begin
  showmessage(DataSet.UnitName+'.'+DataSet.Name);
  if DeletedList.Contains(IntToStr(Int64(Pointer(Dataset)))+':'+DataSet.FieldByName(localField).AsWideString) then Abort;
end;

procedure InsteadOfDeleteWorkaround_BeforeDelete(DataSet: TCustomADODataSet; const localField, baseTable, baseTableField: string);
resourcestring
  SReallyDelete = 'Do you really want to delete this line and all connected data to it?';
begin
  if DeletedList.Contains(IntToStr(Int64(Pointer(Dataset)))+':'+DataSet.FieldByName(localField).AsWideString) then Abort;
  if MessageDlg(SReallyDelete, TMsgDlgType.mtConfirmation, mbYesNoCancel, 0) <> ID_YES then Abort;
  DeletedList.Add(IntToStr(Int64(Pointer(Dataset)))+':'+DataSet.FieldByName(localField).AsWideString);
  Dataset.Connection.ExecSQL('delete from '+Dataset.Connection.SQLObjectNameEscape(basetable)+' '+
                             'where '+Dataset.Connection.SQLFieldNameEscape(baseTableField)+' = ''' + DataSet.FieldByName(localField).AsWideString + '''');

  // Jump to next line, or at previous line if we are at the end
  Dataset.Next;
  if Dataset.EOF then Dataset.Prior;

  Abort; // prevent the default delete action
end;

procedure InsteadOfDeleteWorkaround_DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState; const localField: string);
begin
  // We strike through the deleted record, because a requery might cause a re-ordering
  // and if the user deletes multiple lines, then they might delete wrong record!

  // Set the background color (optional)
  if gdSelected in State then
  begin
    // Handle selected cell (focused or selected) background and text
    TDBGrid(Sender).Canvas.Brush.Color := clHighlight;       // Set highlight background
    TDBGrid(Sender).Canvas.Font.Color := clHighlightText;    // Set text color to highlight text
  end
  else
  begin
    // Handle regular cell background
    TDBGrid(Sender).Canvas.Brush.Color := clWhite;
    TDBGrid(Sender).Canvas.Font.Color := clBlack;
  end;

  // Check if the record should be struck through
  if DeletedList.Contains(IntToStr(Int64(Pointer(TDBGrid(Sender).DataSource.DataSet)))+':'+TDBGrid(Sender).DataSource.DataSet.FieldByName(localField).AsWideString) then
  begin
    TDBGrid(Sender).Canvas.Font.Color := clGray;
    TDBGrid(Sender).Canvas.Font.Style := TDBGrid(Sender).Canvas.Font.Style + [fsStrikeOut];  // Add strikethrough
  end
  else
  begin
    TDBGrid(Sender).Canvas.Font.Style := [];  // Regular font style (no strikethrough)
  end;

  // Finally, draw the text inside the cell
  TDBGrid(Sender).Canvas.FillRect(Rect);  // Clear the background
  TDBGrid(Sender).Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2, Column.Field.AsWideString);

  // Optional: Reset font style after drawing
  TDBGrid(Sender).Canvas.Font.Style := [];
end;

initialization
  DeletedList := TStringList.Create;

finalization
  FreeAndNil(DeletedList);

end.
