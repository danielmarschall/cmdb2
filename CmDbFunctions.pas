unit CmDbFunctions;

interface

uses
  Windows, Forms, Variants, Graphics, Classes, DBGrids, AdoDb, AdoConnHelper, SysUtils,
  Db, DateUtils, Vcl.Grids, System.UITypes, VCL.DBCtrls, Vcl.Menus, Vcl.ComCtrls;

procedure CmDb_DropTempTables(AdoConnection1: TAdoConnection);
function CmDb_GetPasswordHash(AdoConnection1: TAdoConnection; const password: string): string;
function CmDb_DatabasePasswordcheck(AdoConnection1: TAdoConnection): boolean;
procedure DefragIndexes(AdoConnection: TAdoConnection; FragmentierungSchwellenWert: integer=10);
function ShellExecuteWait(aWnd: HWND; Operation: string; ExeName: string; Params: string; WorkingDirectory: string; ncmdShow: Integer; wait: boolean): Integer;
function CmDb_GetDefaultDataPath: string;
function CmDb_GetDefaultBackupPath: string;
function CmDb_GetTempPath: string;
procedure CmDb_RestoreDatabase(AdoConnection1: TAdoConnection; const BakFilename: string);
procedure CmDb_ConnectViaLocalDb(AdoConnection1: TAdoConnection; const DataBaseName: string);
procedure CmDb_InstallOrUpdateSchema(AdoConnection1: TAdoConnection);
procedure CmDb_GetFullTextDump(AdoConnection1: TAdoConnection; sl: TStrings);
function VariantToInteger(Value: Variant): Integer;
function VariantToString(const Value: Variant): string;
function CmDb_ShowRows(ttQuery: TDataSet): string;
function GetBuildTimestamp(const ExeFile: string): TDateTime;
procedure SaveGridToCsv(grid: TDbGrid; const filename: string);
function TitleButtonHelper(Column: TColumn): boolean;
function AscDesc(asc: boolean): string;
procedure AdoQueryRefresh(ADataset: TAdoQuery; const ALocateField: string);
procedure DisableAllMenuItems(MainMenu: TMainMenu);
procedure EnableAllMenuItems(MainMenu: TMainMenu);

procedure InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbg: TDBGrid; nav: TDBNavigator);
procedure InsteadOfDeleteWorkaround_BeforeEdit(DataSet: TCustomADODataSet; const localField: string);
procedure InsteadOfDeleteWorkaround_BeforeDelete(DataSet: TCustomADODataSet; const localField, baseTable, baseTableField: string);
procedure InsteadOfDeleteWorkaround_DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState; const localField: string);

procedure WinInet_DownloadFile(const URL, FileName: string; pb: TProgressBar);

implementation

uses
  ShlObj, ShellApi, System.Hash, Dialogs, WinInet,
  CmDbMain, Artist, Commission, Mandator, Statistics, Registry;

const
  LOCALDB_INSTANCE_NAME = 'MSSQLLocalDB';

procedure CmDb_DropTempTables(AdoConnection1: TAdoConnection);
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

function CmDb_GetPasswordHash(AdoConnection1: TAdoConnection; const password: string): string;
var
  salt: string;
begin
  salt := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''INSTALL_ID'';'));
  result := THashSHA2.GetHashString(salt + password);
end;

function CmDb_DatabasePasswordcheck(AdoConnection1: TAdoConnection): boolean;
var
  hashedPassword: string;
  enteredPassword: string;
resourcestring
  SEnterPassword = 'Enter password:';
begin
  hashedPassword := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''PASSWORD_HASHED'';'));
  if hashedPassword <> '' then
  begin
    // If a ZIP has been compressed previously, try its password first
    if SameText(CmDb_GetPasswordHash(AdoConnection1, MainForm.CmDbZipPassword), hashedPassword) then
    begin
      Exit(true);
    end;

    // Otherwise, ask the user for the password
    while true do
    begin
      if InputQuery(Application.Title, #0{password star} + SEnterPassword, enteredPassword) then
      begin
        if SameText(CmDb_GetPasswordHash(AdoConnection1, enteredPassword), hashedPassword) then
        begin
          if MainForm.CmDbZipPassword = '' then
            MainForm.CmDbZipPassword := enteredPassword;
          Exit(true);
        end
        else
        begin
          enteredPassword := '';
        end;
      end
      else
      begin
        Exit(false);
      end;
    end;
  end
  else
  begin
    Exit(true);
  end;
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

function _GetUserDirectory: string;
var
  Path: array [0..MAX_PATH] of Char;
begin
  // Use SHGetFolderPath to get the user profile directory
  if Succeeded(SHGetFolderPath(0, CSIDL_PROFILE, 0, 0, @Path[0])) then
    Result := Path
  else
    Result := ''; // Return an empty string if it fails
end;

function CmDb_GetDefaultDataPath: string;
begin
  result := IncludeTrailingPathDelimiter(_GetUserDirectory) + 'CMDB2\Data';
  ForceDirectories(result);
end;

function CmDb_GetDefaultBackupPath: string;
begin
  result := IncludeTrailingPathDelimiter(_GetUserDirectory) + 'CMDB2\Backup';
  ForceDirectories(result);
end;

function CmDb_GetTempPath: string;
begin
  result := IncludeTrailingPathDelimiter(_GetUserDirectory) + 'CMDB2\Temp';
  ForceDirectories(result);
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
    '    MOVE N'+AdoConnection1.SQLStringEscape(LogicalNameData)+' TO N'+AdoConnection1.SQLStringEscape(IncludeTrailingPathDelimiter(CmDb_GetDefaultDataPath) + TempDbName + '.mdf')+', ' +
    '    MOVE N'+AdoConnection1.SQLStringEscape(LogicalNameLog)+' TO N'+AdoConnection1.SQLStringEscape(IncludeTrailingPathDelimiter(CmDb_GetDefaultDataPath) + TempDbName + '.ldf')+', ' +
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

  ADOConnection1.ConnectNtAuth('(localdb)\'+LOCALDB_INSTANCE_NAME, 'master');  // do not localize
  ADOConnection1.ExecSQL(
    'IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'+AdoConnection1.SQLStringEscape(DataBaseName)+') ' +
    'BEGIN ' +
    '  CREATE DATABASE '+AdoConnection1.SQLDatabaseNameEscape(DataBaseName)+' ' +
    '  ON PRIMARY ' +
    '  ( ' +
    '      NAME = N'+AdoConnection1.SQLStringEscape(LogicalNameData)+', '+
    '      FILENAME = N'+AdoConnection1.SQLStringEscape(IncludeTrailingPathDelimiter(CmDb_GetDefaultDataPath) + DatabaseName + '.mdf')+', '+
    '      SIZE = 10MB, ' +
    '      MAXSIZE = UNLIMITED, ' +
    '      FILEGROWTH = 5MB ' +
    '  ) ' +
    '  LOG ON ' +
    '  ( ' +
    '      NAME = N'+AdoConnection1.SQLStringEscape(LogicalNameLog)+', '+
    '      FILENAME = N'+AdoConnection1.SQLStringEscape(IncludeTrailingPathDelimiter(CmDb_GetDefaultDataPath) + DatabaseName + '.ldf')+', ' +
    '      SIZE = 5MB, ' +
    '      MAXSIZE = 50MB, ' +
    '      FILEGROWTH = 1MB ' +
    '  ); ' +
    '  ALTER DATABASE '+AdoConnection1.SQLDatabaseNameEscape(DataBaseName)+' SET MULTI_USER; ' +
    'END'
  );
  ADOConnection1.ConnectNtAuth('(localdb)\'+LOCALDB_INSTANCE_NAME, DataBaseName);  // do not localize
end;

procedure CmDb_GetFullTextDump(AdoConnection1: TAdoConnection; sl: TStrings);

  function MakeLine(q: TAdoDataSet): string;
  var
    sb: TStringBuilder;
    i: integer;
  const
    SEPARATOR = '; ';
  begin
    sb := TStringBuilder.Create;
    try
      for i := 0 to q.Fields.Count-1 do
      begin
        if q.Fields[i].FieldName = 'ID' then continue;
        if q.Fields[i].FieldName.EndsWith('_ID') then continue;
        if q.Fields[i].FieldName.StartsWith('__') then continue;
        if q.Fields[i].FieldName = 'IS_ARTIST' then continue;
        if q.Fields[i].FieldName = 'NAME' then
          sb.Append(q.Fields[i].AsWideString + SEPARATOR)
        else if q.Fields[i].AsWideString <> '' then
          sb.Append(q.Fields[i].FieldName + '=' + q.Fields[i].AsWideString + SEPARATOR);
      end;
      result := sb.ToString;
      result := Copy(result, 1, Length(result)-2);
    finally
      sb.Free;
    end;
  end;

var
  qConfig, qMandator, qArtist, qArtistEvent, qCommission, qCommunication, qPayment, qCommissionEvent, qQuote, qUpload: TADODataSet;
begin
  sl.BeginUpdate;
  try
    {$REGION 'Query database (the order is cruicial!)}
    qConfig := ADOConnection1.GetTable(
      'select cnf.NAME as __CNF_NAME, cnf.* ' +
      'from CONFIG cnf ' +
      'order by cnf.NAME');
    qMandator := ADOConnection1.GetTable(
      'select man.ID as __MAN_ID, man.* ' +
      'from MANDATOR man ' +
      'order by man.NAME, man.ID');
    qArtist := AdoConnection1.GetTable(
      'select man.ID as __MAN_ID, art.ID as __ART_ID, art.* ' +
      'from ARTIST art ' +
      'left join MANDATOR man on man.ID = art.MANDATOR_ID ' +
      'order by man.NAME, man.ID, art.IS_ARTIST, art.NAME, art.ID');
    qArtistEvent := AdoConnection1.GetTable(
      'select man.ID as __MAN_ID, art.ID as __ART_ID, ev.ID as __EV_ID, ev.* ' +
      'from ARTIST_EVENT ev ' +
      'left join ARTIST art on art.ID = ev.ARTIST_ID ' +
      'left join MANDATOR man on man.ID = art.MANDATOR_ID ' +
      'order by man.NAME, man.ID, art.IS_ARTIST, art.NAME, art.ID, ev.DATE, ev.STATE, ev.ID');
    qPayment := AdoConnection1.GetTable(
      'select man.ID as __MAN_ID, art.ID as __ART_ID, pay.ID as __PAY_ID, pay.* ' +
      'from PAYMENT pay ' +
      'left join ARTIST art on art.ID = pay.ARTIST_ID ' +
      'left join MANDATOR man on man.ID = art.MANDATOR_ID ' +
      'order by man.NAME, man.ID, art.IS_ARTIST, art.NAME, art.ID, pay.DATE, pay.ID');
    qCommunication := AdoConnection1.GetTable(
      'select man.ID as __MAN_ID, art.ID as __ART_ID, comm.ID as __COMM_ID, comm.* ' +
      'from COMMUNICATION comm ' +
      'left join ARTIST art on art.ID = comm.ARTIST_ID ' +
      'left join MANDATOR man on man.ID = art.MANDATOR_ID ' +
      'order by man.NAME, man.ID, art.IS_ARTIST, art.NAME, art.ID, comm.CHANNEL, comm.ADDRESS, comm.ID');
    qCommission := AdoConnection1.GetTable(
      'select man.ID as __MAN_ID, art.ID as __ART_ID, cm.ID as __CM_ID, cm.* ' +
      'from COMMISSION cm ' +
      'left join ARTIST art on art.ID = cm.ARTIST_ID ' +
      'left join MANDATOR man on man.ID = art.MANDATOR_ID ' +
      'order by man.NAME, man.ID, art.IS_ARTIST, art.NAME, art.ID, cm.NAME, cm.ID');
    qCommissionEvent := AdoConnection1.GetTable(
      'select man.ID as __MAN_ID, art.ID as __ART_ID, cm.ID as __CM_ID, ev.ID as __EV_ID, ev.* ' +
      'from COMMISSION_EVENT ev ' +
      'left join COMMISSION cm on cm.ID = ev.COMMISSION_ID ' +
      'left join ARTIST art on art.ID = cm.ARTIST_ID ' +
      'left join MANDATOR man on man.ID = art.MANDATOR_ID ' +
      'order by man.NAME, man.ID, art.IS_ARTIST, art.NAME, art.ID, cm.NAME, cm.ID, ev.DATE, ev.STATE, ev.ID');
    qQuote := AdoConnection1.GetTable(
      'select man.ID as __MAN_ID, art.ID as __ART_ID, cm.ID as __CM_ID, ev.ID as __EV_ID, q.ID as __Q_ID, q.* ' +
      'from QUOTE q ' +
      'left join COMMISSION_EVENT ev on ev.ID = q.EVENT_ID ' +
      'left join COMMISSION cm on cm.ID = ev.COMMISSION_ID ' +
      'left join ARTIST art on art.ID = cm.ARTIST_ID ' +
      'left join MANDATOR man on man.ID = art.MANDATOR_ID ' +
      'order by man.NAME, man.ID, art.IS_ARTIST, art.NAME, art.ID, cm.NAME, cm.ID, ev.DATE, ev.STATE, ev.ID, q.NO, q.ID');
    qUpload := AdoConnection1.GetTable(
      'select man.ID as __MAN_ID, art.ID as __ART_ID, cm.ID as __CM_ID, ev.ID as __EV_ID, up.ID as __UP_ID, up.* ' +
      'from UPLOAD up ' +
      'left join COMMISSION_EVENT ev on ev.ID = up.EVENT_ID ' +
      'left join COMMISSION cm on cm.ID = ev.COMMISSION_ID ' +
      'left join ARTIST art on art.ID = cm.ARTIST_ID ' +
      'left join MANDATOR man on man.ID = art.MANDATOR_ID ' +
      'order by man.NAME, man.ID, art.IS_ARTIST, art.NAME, art.ID, cm.NAME, cm.ID, ev.DATE, ev.STATE, ev.ID, up.NO, up.ID');
    {$ENDREGION}

    {$REGION 'Config'}
    while not qConfig.EOF do
    begin
      sl.Add('Config: ' + MakeLine(qConfig));
      qConfig.Next;
    end;
    {$ENDREGION}
    {$REGION 'Mandator'}
    while not qMandator.EOF do
    begin
      sl.Add('Mandator: ' + MakeLine(qMandator));
      {$REGION 'Artist/Client'}
      while not qArtist.EOF and
            IsEqualGUID(qArtist.FieldByName('__MAN_ID').AsGuid, qMandator.FieldByName('__MAN_ID').AsGuid) do
      begin
        if qArtist.FieldByName('IS_ARTIST').AsBoolean then
          sl.Add(#9 + 'Artist: ' + MakeLine(qArtist))
        else
          sl.Add(#9 + 'Client: ' + MakeLine(qArtist));
        {$REGION 'Artist Event'}
        while not qArtistEvent.EOF and
              IsEqualGUID(qArtistEvent.FieldByName('__ART_ID').AsGuid, qArtist.FieldByName('__ART_ID').AsGuid) do
        begin
          if qArtist.FieldByName('IS_ARTIST').AsBoolean then
            sl.Add(#9#9 + 'Artist Event: ' + MakeLine(qArtistEvent))
          else
            sl.Add(#9#9 + 'Client Event: ' + MakeLine(qArtistEvent));
          qArtistEvent.Next;
        end;
        {$ENDREGION}
        {$REGION 'Communication'}
        while not qCommunication.EOF and
              IsEqualGUID(qCommunication.FieldByName('__ART_ID').AsGuid, qArtist.FieldByName('__ART_ID').AsGuid) do
        begin
          sl.Add(#9#9 + 'Communication: ' + MakeLine(qCommunication));
          qCommunication.Next;
        end;
        {$ENDREGION}
        {$REGION 'Payment'}
        while not qPayment.EOF and
              IsEqualGUID(qPayment.FieldByName('__ART_ID').AsGuid, qArtist.FieldByName('__ART_ID').AsGuid) do
        begin
          sl.Add(#9#9 + 'Payment: ' + MakeLine(qPayment));
          qPayment.Next;
        end;
        {$ENDREGION}
        {$REGION 'Artist Event'}
        while not qArtistEvent.EOF and
              IsEqualGUID(qArtistEvent.FieldByName('__ART_ID').AsGuid, qArtist.FieldByName('__ART_ID').AsGuid) do
        begin
          if qArtist.FieldByName('IS_ARTIST').AsBoolean then
            sl.Add(#9#9 + 'Artist Event: ' + MakeLine(qArtistEvent))
          else
            sl.Add(#9#9 + 'Client Event: ' + MakeLine(qArtistEvent));
          qArtistEvent.Next;
        end;
        {$ENDREGION}
        {$REGION 'Commission'}
        while not qCommission.EOF and
              IsEqualGUID(qCommission.FieldByName('__ART_ID').AsGuid, qArtist.FieldByName('__ART_ID').AsGuid) do
        begin
          sl.Add(#9#9 + 'Commission: ' + MakeLine(qCommission));
          {$REGION 'Commission Event'}
          while not qCommissionEvent.EOF and
                IsEqualGUID(qCommissionEvent.FieldByName('__CM_ID').AsGuid, qCommission.FieldByName('__CM_ID').AsGuid) do
          begin
            sl.Add(#9#9#9 + 'Commission Event: ' + MakeLine(qCommissionEvent));
            {$REGION 'Quote'}
            while not qQuote.EOF and
                  IsEqualGUID(qQuote.FieldByName('__EV_ID').AsGuid, qCommissionEvent.FieldByName('__EV_ID').AsGuid) do
            begin
              sl.Add(#9#9#9#9 + 'Quote: ' + MakeLine(qQuote));
              qQuote.Next;
            end;
            {$ENDREGION}
            {$REGION 'Upload'}
            while not qUpload.EOF and
                  IsEqualGUID(qUpload.FieldByName('__EV_ID').AsGuid, qCommissionEvent.FieldByName('__EV_ID').AsGuid) do
            begin
              sl.Add(#9#9#9#9 + 'Upload: ' + MakeLine(qUpload));
              qUpload.Next;
            end;
            {$ENDREGION}
            qCommissionEvent.Next;
          end;
          {$ENDREGION}
          qCommission.Next;
        end;
        {$ENDREGION}
        qArtist.Next;
      end;
      {$ENDREGION}
      qMandator.Next;
    end;
    {$ENDREGION}

    FreeAndNil(qUpload);
    FreeAndNil(qQuote);
    FreeAndNil(qCommissionEvent);
    FreeAndNil(qCommission);
    FreeAndNil(qCommunication);
    FreeAndNil(qPayment);
    FreeAndNil(qArtistEvent);
    FreeAndNil(qArtist);
    FreeAndNil(qMandator);
    FreeAndNil(qConfig);
  finally
    sl.EndUpdate;
  end;
end;

function GetSystemCurrencyCode: string;
var
  Reg: TRegistry;
begin
  try
    Result := '';
    Reg := TRegistry.Create(KEY_READ);
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKeyReadOnly('Control Panel\International') then // do not localize
      begin
        Result := Reg.ReadString('sCurrency'); // do not localize
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;

    // Optional: Konvertiere das Währungssymbol in einen ISO-Code
    if Result = '€' then
      Result := 'EUR'
    else if Result = '$' then
      Result := 'USD'
    else if Result = '£' then
      Result := 'GBP'
    else if Result = '¥' then
      Result := 'JPY';

    Result := UpperCase(Result);
    if Length(Result) <> 3 then Result := '';
  except
    Result := '';
  end;
end;

procedure CmDb_InstallOrUpdateSchema(AdoConnection1: TAdoConnection);
resourcestring
  SSchemaDUnknown = 'Schema %d is unknown. The database is probably newer than the software version.';
  SDbInstallError = 'DB Install %s error: %s';
  SMandator0Default = 'Mandator 0 (Testing)';
  SMandator1Default = 'Mandator 1 (Productive)';

  procedure InstallSql(fil: string);
  var
    sl: TStringList;
    rcStream: TResourceStream;
  begin
    try
      sl := TStringList.Create;
      rcStream := TResourceStream.Create(HInstance, 'SQL_'+fil, RT_RCDATA);
      try
        sl.LoadFromStream(rcStream);
        AdoConnection1.ExecSQL(sl.Text);
      finally
        FreeAndNil(sl);
        FreeAndNil(rcStream);
      end;
    except
      on E: Exception do
      begin
        raise Exception.CreateFmt(SDbInstallError, [fil, E.Message]);
      end;
    end;
  end;

var
  sCurCode: string;
  schemaVer: integer;
const
  CUR_SCHEMA = 7;
begin
  if not AdoConnection1.TableExists('CONFIG') then
    schemaVer := 0
  else
    schemaVer := VariantToInteger(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''DB_VERSION'';'));

  if schemaVer > CUR_SCHEMA then
  begin
    raise Exception.CreateFmt(SSchemaDUnknown, [schemaVer]);
  end;

  if schemaVer < CUR_SCHEMA then
  begin
    AdoConnection1.BeginTrans;
    try
      {$REGION 'CONFIG'}
      if not AdoConnection1.TableExists('CONFIG') then
      begin
        InstallSql('CONFIG');
      end;
      sCurCode := GetSystemCurrencyCode;
      if sCurCode = '' then sCurCode := 'USD';
      AdoConnection1.ExecSQL('if not exists (select NAME from CONFIG where NAME = ''BACKUP_PATH'') '+
                             'insert into [CONFIG] (NAME, VALUE) values (''BACKUP_PATH'', '''');');
      AdoConnection1.ExecSQL('if not exists (select NAME from CONFIG where NAME = ''CURRENCY_LAYER_API_KEY'') '+
                             'insert into [CONFIG] (NAME, VALUE) values (''CURRENCY_LAYER_API_KEY'', '''');');
      AdoConnection1.ExecSQL('if not exists (select NAME from CONFIG where NAME = ''DB_VERSION'') '+
                             'insert into [CONFIG] (NAME, VALUE) values (''DB_VERSION'', ''0'');');
      AdoConnection1.ExecSQL('delete from CONFIG where NAME = ''CUSTOMIZATION_ID'''); // use INSTALL_ID instead
      AdoConnection1.ExecSQL('if not exists (select NAME from CONFIG where NAME = ''INSTALL_ID'') '+
                             'insert into [CONFIG] (NAME, VALUE) values (''INSTALL_ID'', cast(newid() as varchar(100)));');
      AdoConnection1.ExecSQL('if not exists (select NAME from CONFIG where NAME = ''LOCAL_CURRENCY'') '+
                             'insert into [CONFIG] (NAME, VALUE) values (''LOCAL_CURRENCY'', '+AdoConnection1.SQLStringEscape(sCurCode)+');');
      AdoConnection1.ExecSQL('if not exists (select NAME from CONFIG where NAME = ''NEW_PASSWORD'') '+
                             'insert into [CONFIG] (NAME, VALUE) values (''NEW_PASSWORD'', '''');');
      AdoConnection1.ExecSQL('if not exists (select NAME from CONFIG where NAME = ''PASSWORD_HASHED'') '+
                             'insert into [CONFIG] (NAME, VALUE) values (''PASSWORD_HASHED'', '''');');
      AdoConnection1.ExecSQL('if not exists (select NAME from CONFIG where NAME = ''PICKLIST_ARTPAGES'') '+
                             'insert into [CONFIG] (NAME, VALUE) values (''PICKLIST_ARTPAGES'', ''DeviantArt;FurAffinity;Imgur;Inkbunny;Mastodon.ART;Pixiv;Sheezy;SoFurry;Transfur;Tumblr;Weasyl'');');
      AdoConnection1.ExecSQL('if not exists (select NAME from CONFIG where NAME = ''PICKLIST_COMMUNICATION'') '+
                             'insert into [CONFIG] (NAME, VALUE) values (''PICKLIST_COMMUNICATION'', ''(Other);Alias;Bank account;Battle.net;Birthday;Bluesky;Boosty;Credit Card;DeviantArt;Discord;donationalerts;EasyBusy / EasyStaff / EasyStarter;E-Mail;Facebook;F-List;Full name;FurAffinity;Furry Network;Gender;Google Hangouts;Hipolink;ICQ;IMVU;InkBunny;Instagram;Ko-Fi;Language;Location / Postal;Minecraft;Nickname;Patreon;PayPal;Phone (mobile);Phone (private);Phone (work);Picarto;PlayStationNetwork;QQ;Reddit;Skype;SoFurry;Spotify;Steam;Switch Friend Code;Telegram;Time Zone;ToyHou.se;Tumblr;Twitch;Twitter;URL;VK;Weasyl;Website;WhatsApp;WiiU Friend Code;Xbox Live;YouTube'');');
      AdoConnection1.ExecSQL('if not exists (select NAME from CONFIG where NAME = ''PICKLIST_PAYPROVIDER'') '+
                             'insert into [CONFIG] (NAME, VALUE) values (''PICKLIST_PAYPROVIDER'', ''Boosty;donationalerts;EasyBusy / EasyStaff / EasyStarter;Etsy;hipolink.me;Mastercard;Patreon;Payoneer;PayPal;PayPal (customs);PayPal (friend);PayPal (invoice);PayPal.me;PaySend;Second Life;SEPA/Wiretransfer'');');
      if not AdoConnection1.ColumnExists('CONFIG', 'READ_ONLY') then
      begin
        AdoConnection1.ExecSQL('alter table CONFIG add READ_ONLY bit;');
        AdoConnection1.ExecSQL('update CONFIG set READ_ONLY = 0');
        AdoConnection1.ExecSQL('alter table CONFIG alter column READ_ONLY bit NOT NULL');
      end;
      if not AdoConnection1.ColumnExists('CONFIG', 'HIDDEN') then
      begin
        AdoConnection1.ExecSQL('alter table CONFIG add HIDDEN bit;');
        AdoConnection1.ExecSQL('update CONFIG set HIDDEN = iif(NAME=''DB_VERSION'' or NAME=''INSTALL_ID'' or NAME=''PASSWORD_HASHED'', 1, 0)');
        AdoConnection1.ExecSQL('alter table CONFIG alter column HIDDEN bit NOT NULL');
      end;
      {$ENDREGION}

      {$REGION 'MANDATOR'}
      if not AdoConnection1.TableExists('MANDATOR') then
      begin
        InstallSql('MANDATOR');
        AdoConnection1.ExecSQL('insert into MANDATOR (NAME) values ('+AdoConnection1.SQLStringEscape(SMandator0Default)+');');
        AdoConnection1.ExecSQL('insert into MANDATOR (NAME) values ('+AdoConnection1.SQLStringEscape(SMandator1Default)+');');
      end;
      {$ENDREGION}

      {$REGION 'ARTIST'}
      if not AdoConnection1.TableExists('ARTIST') then
        InstallSql('ARTIST');
      if AdoConnection1.ColumnExists('ARTIST', 'LEGACY_ID') then
        AdoConnection1.ExecSQL('alter table ARTIST drop column LEGACY_ID;');
      {$ENDREGION}

      {$REGION 'ARTIST_EVENT'}
      if not AdoConnection1.TableExists('ARTIST_EVENT') then
        InstallSql('ARTIST_EVENT');
      if AdoConnection1.ColumnExists('ARTIST_EVENT', 'LEGACY_ID') then
        AdoConnection1.ExecSQL('alter table ARTIST_EVENT drop column LEGACY_ID;');
      {$ENDREGION}

      {$REGION 'COMMISSION'}
      if not AdoConnection1.TableExists('COMMISSION') then
        InstallSql('COMMISSION');
      if AdoConnection1.ColumnExists('COMMISSION', 'LEGACY_ID') then
        AdoConnection1.ExecSQL('alter table COMMISSION drop column LEGACY_ID;');
      {$ENDREGION}

      {$REGION 'COMMISSION_EVENT'}
      if not AdoConnection1.TableExists('COMMISSION_EVENT') then
        InstallSql('COMMISSION_EVENT');
      AdoConnection1.ExecSQL('update COMMISSION_EVENT set STATE = ''c aw sk'' where STATE = ''ack''');
      {$ENDREGION}

      {$REGION 'QUOTE'}
      if not AdoConnection1.TableExists('QUOTE') then
        InstallSql('QUOTE');
      if AdoConnection1.ColumnExists('QUOTE', 'LEGACY_ID') then
        AdoConnection1.ExecSQL('alter table QUOTE	drop column LEGACY_ID;');
      {$ENDREGION}

      {$REGION 'UPLOAD'}
      if not AdoConnection1.TableExists('UPLOAD') then
        InstallSql('UPLOAD');
      if AdoConnection1.ColumnExists('UPLOAD', 'LEGACY_ID') then
        AdoConnection1.ExecSQL('alter table UPLOAD drop column LEGACY_ID;');
      {$ENDREGION}

      {$REGION 'PAYMENT'}
      if not AdoConnection1.TableExists('PAYMENT') then
        InstallSql('PAYMENT');
      {$ENDREGION}

      {$REGION 'COMMUNICATION'}
      if not AdoConnection1.TableExists('COMMUNICATION') then
        InstallSql('COMMUNICATION');
      if AdoConnection1.ColumnExists('COMMUNICATION', 'LEGACY_ID') then
        AdoConnection1.ExecSQL('alter table COMMUNICATION	drop column LEGACY_ID;');
      {$ENDREGION}

      {$REGION 'STATISTICS'}
      if not AdoConnection1.TableExists('STATISTICS') or
         AdoConnection1.ColumnExists('STATISTICS', 'SQL_VIEW') then
      begin
        AdoConnection1.DropTableOrView('STATISTICS');
        InstallSql('STATISTICS');
      end;
      {$ENDREGION}

      {$REGION 'BACKUP'}
      if not AdoConnection1.TableExists('BACKUP') then
      begin
        InstallSql('BACKUP');
      end
      else if schemaVer < 4 then
      begin
        // Remove Identity from BACKUP table, because the next value cannot be predicted due to Microsoft's crap decision
        // see https://github.com/danielmarschall/cmdb2/issues/4
        AdoConnection1.ExecSQL('EXEC sp_rename ''BACKUP'', ''BACKUP_OLD'';');
        AdoConnection1.ExecSQL('EXEC sp_rename ''PK_BACKUP'', ''PK_BACKUP_OLD'';');
        InstallSql('BACKUP');
        AdoConnection1.ExecSQL('insert into [BACKUP] select * from BACKUP_OLD;');
        AdoConnection1.ExecSQL('drop table BACKUP_OLD;');
      end;
      {$ENDREGION}

      {$REGION 'Obsolete tables and views'}
      AdoConnection1.DropTableOrView('TEXT_BACKUP');
      AdoConnection1.DropTableOrView('vw_TEXT_BACKUP');
      AdoConnection1.DropTableOrView('vw_TEXT_BACKUP_GENERATE');
      AdoConnection1.DropTableOrView('vw_STAT_TEXT_EXPORT');
      AdoConnection1.DropTableOrView('vw_STAT_RUNNING_COMMISSIONS');
      AdoConnection1.DropTableOrView('vw_STAT_SUM_YEARS');
      AdoConnection1.DropTableOrView('vw_STAT_SUM_MONTHS');
      AdoConnection1.DropTableOrView('vw_STAT_TOP_ARTISTS');
      {$ENDREGION}

      {$REGION 'Views'}
      InstallSql('vw_CONFIG');
      InstallSql('vw_MANDATOR');
      InstallSql('vw_COMMISSION_EVENT');
      InstallSql('vw_COMMISSION');
      InstallSql('vw_ARTIST_EVENT');
      InstallSql('vw_ARTIST'); // requires vw_COMMISSION, vw_ARTIST_EVENT
      InstallSql('vw_QUOTE');
      InstallSql('vw_UPLOAD');
      InstallSql('vw_PAYMENT');
      InstallSql('vw_COMMUNICATION');
      InstallSql('vw_STATISTICS');
      InstallSql('vw_BACKUP');
      {$ENDREGION}

      AdoConnection1.ExecSQL('update CONFIG set VALUE = '+AdoConnection1.SQLStringEscape(IntToStr(CUR_SCHEMA))+' where NAME = ''DB_VERSION'';');

      AdoConnection1.CommitTrans;
    except
      AdoConnection1.RollbackTrans;
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

function CmDb_ShowRows(ttQuery: TDataSet): string;
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
resourcestring
  SGetBuildTimestampFailed = 'GetBuildTimestamp(%s) failed';
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
      raise Exception.CreateFmt(SGetBuildTimestampFailed, [ExeFile]);
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

function TitleButtonHelper(Column: TColumn): boolean; // return true=asc
var
  i: integer;
begin
  assert(Column.Field.DataSet.Active); // if dataset is not active, then Field.FieldNo is 0, which is bad.

  if Column.Grid.DataSource.DataSet.State in [dsEdit,dsInsert] then
  begin
    Column.Grid.DataSource.DataSet.Post;
  end;

  for i := 0 to TDbGrid(Column.Grid).Columns.Count-1 do
  begin
    if i = Column.Index then
      TDbGrid(Column.Grid).Columns.Items[i].Color := clAqua
    else
      TDbGrid(Column.Grid).Columns.Items[i].Color := clWhite; // MUST be clWhite, see comparison at InsteadOfDeleteWorkaround_DrawColumnCell
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
    result := 'asc' // do not localize
  else
    result := 'desc'; // do not localize
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

type
  TMenuState = record
    ItemEnabled: Boolean;   // Status des Top-Level-Menüitems
    SubItemsEnabled: TArray<Boolean>; // Status der Sub-Menüitems
  end;

var
  MenuStates: array of TMenuState;  // Liste zum Speichern der Aktivierungszustände

procedure DisableAllMenuItems(MainMenu: TMainMenu);
var
  i, j: Integer;
  MenuState: TMenuState;
begin
  SetLength(MenuStates, MainMenu.Items.Count);  // Größe des Arrays auf die Anzahl der Menüeinträge setzen

  // Loop through all top-level menu items
  for i := 0 to MainMenu.Items.Count - 1 do
  begin
    // Speichere den Zustand des Top-Level-Menüeintrags
    MenuState.ItemEnabled := MainMenu.Items[i].Enabled;

    // Speichere den Zustand der Sub-Menüeinträge
    SetLength(MenuState.SubItemsEnabled, MainMenu.Items[i].Count);
    for j := 0 to MainMenu.Items[i].Count - 1 do
    begin
      // Speichere den Zustand jedes Untermenüeintrags
      MenuState.SubItemsEnabled[j] := MainMenu.Items[i].Items[j].Enabled;

      // Deaktivieren des Sub-Menüeintrags
      MainMenu.Items[i].Items[j].Enabled := False;
    end;

    // Speichere den Zustand in unserer Liste
    MenuStates[i] := MenuState;

    // Deaktivieren des Top-Level-Menüeintrags
    MainMenu.Items[i].Enabled := False;
  end;
end;

procedure EnableAllMenuItems(MainMenu: TMainMenu);
var
  i, j: Integer;
begin
  // Loop through all top-level menu items and restore their state
  for i := 0 to MainMenu.Items.Count - 1 do
  begin
    // Stelle den Zustand des Top-Level-Menüeintrags wieder her
    MainMenu.Items[i].Enabled := MenuStates[i].ItemEnabled;

    // Stelle den Zustand der Sub-Menüeinträge wieder her
    for j := 0 to MainMenu.Items[i].Count - 1 do
    begin
      MainMenu.Items[i].Items[j].Enabled := MenuStates[i].SubItemsEnabled[j];
    end;
  end;
end;

// These 4 procedures are used to prevent that a delete command in an ADO Query
// causes deletion in all connected tables.
// For some reason, if you delete something from a DBGrid, then the
// command to the SQL Server will be delete commands to the connected tables.
// There is no delete SQL query to the actual view; hence, it is not possible
// to solve this with a "instead of delete" trigger on that view!

// NOTE:
// The InsteadOfDelete* methods do some additional stuff to CmDB:
// - Show "cream" color for read-only columns
// - Close windows that were attached to a dataset to be deleted

var
  DeletedList: TStringList;

function _DeletedListName(DataSet: TDataSet; const IdFieldName: string): string;
begin
  //result := IntToStr(Int64(Pointer(Dataset)))+':'+IdFieldName+':'+DataSet.FieldByName(IdFieldName).AsWideString;
  result := DataSet.Owner.Name+'.'+DataSet.Name+':'+IdFieldName+':'+DataSet.FieldByName(IdFieldName).AsWideString;
end;

procedure InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbg: TDBGrid; nav: TDBNavigator);
begin
  nav.ConfirmDelete := false;
  dbg.Options := dbg.Options - [dgConfirmDelete];
end;

procedure InsteadOfDeleteWorkaround_BeforeEdit(DataSet: TCustomADODataSet; const localField: string);
begin
  if DeletedList.Contains(_DeletedListName(DataSet, localField)) then Abort;
end;

procedure InsteadOfDeleteWorkaround_BeforeDelete(DataSet: TCustomADODataSet; const localField, baseTable, baseTableField: string);
resourcestring
  SReallyDelete = 'Do you really want to delete this line and all data connected to it?';
var
  q: TADODataSet;
  i: integer;
  id, listname: string;
begin
  if DeletedList.Contains(_DeletedListName(DataSet, localField)) then Abort;
  if MessageBox(Application.Handle, PChar(SReallyDelete), PChar(Application.Title), MB_YESNOCANCEL or MB_ICONQUESTION or MB_TASKMODAL) <> ID_YES then Abort;

  // Gather some basic info required for the next steps
  id := DataSet.FieldByName(localField).AsWideString;
  listname := _DeletedListName(DataSet, localField);

  {$REGION 'Close windows attached to this dataset'}
  if BaseTable = 'MANDATOR' then
  begin
    // Delete Mandator => Close Mandator Window
    for I := Application.MainForm.MDIChildCount-1 downto 0 do
    begin
      if Application.MainForm.MDIChildren[i] is TMandatorForm then
      begin
        if IsEqualGUID(TMandatorForm(Application.MainForm.MDIChildren[i]).MandatorId, StrToGUID(PChar(id))) then
        begin
          Application.MainForm.MDIChildren[i].Release;
        end;
      end;
    end;
    // Delete Mandator => Close Artist Window
    q := Dataset.Connection.GetTable('select ID from ARTIST where MANDATOR_ID = ''' + id + '''');
    try
      while not q.EOF do
      begin
        for I := Application.MainForm.MDIChildCount-1 downto 0 do
        begin
          if Application.MainForm.MDIChildren[i] is TArtistForm then
          begin
            if IsEqualGUID(TArtistForm(Application.MainForm.MDIChildren[i]).ArtistId, q.FieldByName('ID').AsGuid) then
            begin
              Application.MainForm.MDIChildren[i].Release;
            end;
          end;
        end;
        q.Next;
      end;
    finally
      FreeAndNil(q);
    end;
    // Delete Mandator => Close Commission Window
    q := Dataset.Connection.GetTable('select COMMISSION.ID from COMMISSION left join ARTIST on ARTIST.ID = COMMISSION.ARTIST_ID where ARTIST.MANDATOR_ID = ''' + id + '''');
    try
      while not q.EOF do
      begin
        for I := Application.MainForm.MDIChildCount-1 downto 0 do
        begin
          if Application.MainForm.MDIChildren[i] is TCommissionForm then
          begin
            if IsEqualGUID(TCommissionForm(Application.MainForm.MDIChildren[i]).CommissionId, q.FieldByName('ID').AsGuid) then
            begin
              Application.MainForm.MDIChildren[i].Release;
            end;
          end;
        end;
        q.Next;
      end;
    finally
      FreeAndNil(q);
    end;
    // Delete Mandator => Close Statistics Window
    for I := Application.MainForm.MDIChildCount-1 downto 0 do
    begin
      if Application.MainForm.MDIChildren[i] is TStatisticsForm then
      begin
        if IsEqualGUID(TStatisticsForm(Application.MainForm.MDIChildren[i]).MandatorId, StrToGUID(PChar(id))) then
        begin
          Application.MainForm.MDIChildren[i].Release;
        end;
      end;
    end;
  end
  else if BaseTable = 'ARTIST' then
  begin
    // Delete Artist => Close Artist Window
    for I := Application.MainForm.MDIChildCount-1 downto 0 do
    begin
      if Application.MainForm.MDIChildren[i] is TArtistForm then
      begin
        if IsEqualGUID(TArtistForm(Application.MainForm.MDIChildren[i]).ArtistId, StrToGUID(PChar(id))) then
        begin
          Application.MainForm.MDIChildren[i].Release;
        end;
      end;
    end;
    // Delete Artist => Close Commission Windows
    q := Dataset.Connection.GetTable('select ID from COMMISSION where ARTIST_ID = ''' + id + '''');
    try
      while not q.EOF do
      begin
        for I := Application.MainForm.MDIChildCount-1 downto 0 do
        begin
          if Application.MainForm.MDIChildren[i] is TCommissionForm then
          begin
            if IsEqualGUID(TCommissionForm(Application.MainForm.MDIChildren[i]).CommissionId, q.FieldByName('ID').AsGuid) then
            begin
              Application.MainForm.MDIChildren[i].Release;
            end;
          end;
        end;
        q.Next;
      end;
    finally
      FreeAndNil(q);
    end;
  end
  else if BaseTable = 'COMMISSION' then
  begin
    // Delete Commission => Close Commission Window
    for I := Application.MainForm.MDIChildCount-1 downto 0 do
    begin
      if Application.MainForm.MDIChildren[i] is TCommissionForm then
      begin
        if IsEqualGUID(TCommissionForm(Application.MainForm.MDIChildren[i]).CommissionId, StrToGUID(PChar(id))) then
        begin
          Application.MainForm.MDIChildren[i].Release;
        end;
      end;
    end;
  end;
  {$ENDREGION}

  // Now delete for real
  Dataset.Connection.ExecSQL('delete from '+Dataset.Connection.SQLObjectNameEscape(basetable)+' '+  // do not localize
                             'where '+Dataset.Connection.SQLFieldNameEscape(baseTableField)+' = ' + Dataset.Connection.SQLStringEscape(id));  // do not localize

  // Mark the dataset as deleted
  DeletedList.Add(listname);

  // Jump to next line, or at previous line if we are at the end
  Dataset.Next;
  if Dataset.EOF then Dataset.Prior;

  // prevent the default delete action
  Abort;
end;

procedure InsteadOfDeleteWorkaround_DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState; const localField: string);
var
  txt: string;
  txtWidth: Integer;
begin
  // Set the background color (optional)
  if gdSelected in State then
  begin
    TDBGrid(Sender).Canvas.Brush.Color := clHighlight;       // Set highlight background
    TDBGrid(Sender).Canvas.Font.Color := clHighlightText;    // Set text color to highlight text
  end
  else
  begin
    if Column.Color = clWhite then
    begin
      if Column.ReadOnly or Column.Field.ReadOnly then
        TDBGrid(Sender).Canvas.Brush.Color := clCream
      else
        TDBGrid(Sender).Canvas.Brush.Color := clWindow;
    end
    else
    begin
      TDBGrid(Sender).Canvas.Brush.Color := Column.Color;
    end;
  end;

  // Check if the record should be struck through
  if DeletedList.Contains(_DeletedListName(TDBGrid(Sender).DataSource.DataSet, localField)) then
  begin
    TDBGrid(Sender).Canvas.Font.Color := clGray;
    TDBGrid(Sender).Canvas.Font.Style := TDBGrid(Sender).Canvas.Font.Style + [fsStrikeOut];  // Add strikethrough
  end
  else
  begin
    TDBGrid(Sender).Canvas.Font.Style := [];  // Regular font style (no strikethrough)
  end;

  // Clear the background
  TDBGrid(Sender).Canvas.FillRect(Rect);

  // Get the text of the column field
  txt := Column.Field.AsWideString;

  // Use DisplayFormat for non-numeric fields as well, if available
  if (Column.Field is TNumericField) and (TNumericField(Column.Field).DisplayFormat <> '') then
    txt := FormatFloat(TNumericField(Column.Field).DisplayFormat, Column.Field.AsFloat)
  else if (Column.Field is TDateTimeField) and (TDateTimeField(Column.Field).DisplayFormat <> '') then
    txt := FormatDateTime(TDateTimeField(Column.Field).DisplayFormat, Column.Field.AsDateTime)
  else if (Column.Field is TSQLTimeStampField) and (TSQLTimeStampField(Column.Field).DisplayFormat <> '') then
    txt := FormatDateTime(TSQLTimeStampField(Column.Field).DisplayFormat, Column.Field.AsDateTime)
  else if (Column.Field is TAggregateField) and (TAggregateField(Column.Field).DisplayFormat <> '') then
    txt := FormatFloat(TAggregateField(Column.Field).DisplayFormat, Column.Field.AsFloat);

  // Do we have the OnGetText Event??
  if Assigned(Column.Field.OnGetText) then
    Column.Field.OnGetText(Column.Field, txt, true);

  // Check if the field is numeric and has a DisplayFormat
  if Column.Field.DataType in [ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftInteger, ftSmallint, ftWord, ftLargeint] then
  begin
    // Calculate the width of the formatted text for right alignment
    txtWidth := TDBGrid(Sender).Canvas.TextWidth(txt);

    // Right-align the text by adjusting the Rect.Left position
    TDBGrid(Sender).Canvas.TextRect(Rect, Rect.Right - txtWidth - 2, Rect.Top + 2, txt);
  end
  else
  begin
    // Left-align the text (default)
    TDBGrid(Sender).Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2, txt);
  end;

  // Reset font style after drawing
  TDBGrid(Sender).Canvas.Font.Style := [];
end;

procedure WinInet_DownloadFile(const URL, FileName: string; pb: TProgressBar);

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
  hSession, hRequest: HINTERNET;
  Buffer: array[0..1023] of Byte;
  BufferLen: DWORD;
  FileStream: TFileStream;
  FileSize, TotalRead: DWORD;
  dwSize: DWORD;
  reserved: DWORD;
  StatusCode: DWORD;
  RedirectCount: integer;
resourcestring
  SInternetOpenFailed = 'Error initializing WinInet: %s';
  SInternetOpenUrlFailed = 'Error opening request: %s';
  STooManyRedirects = 'Error: Too many redirects';
  SHTTPError = 'HTTP Error %d with %s request %s';
begin
  AUrl := Url;

  hSession := InternetOpen(USER_AGENT, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if not Assigned(hSession) then
    raise Exception.CreateFmt(SInternetOpenFailed, [SysErrorMessage(GetLastError)]);
  try
    RedirectCount := 0;
    while true do
    begin
      if Assigned(Application) and Application.Terminated then Abort;
      hRequest := InternetOpenUrl(hSession, PChar(AURL), nil, 0, INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_CACHE_WRITE, 0);
      if not Assigned(hRequest) then
        raise Exception.CreateFmt(SInternetOpenUrlFailed, [SysErrorMessage(GetLastError)]);
      try
        StatusCode := GetStatusCode(hRequest);
        if (StatusCode >= 300) and (StatusCode < 400) then
        begin
          Inc(RedirectCount);

          // Stop following redirects if we exceed the maximum number of allowed redirects.
          if RedirectCount > MaxRedirects then
          begin
            raise Exception.Create(STooManyRedirects);
          end;

          // Get the "Location" header for the new URL
          AURL := GetRedirectLocation(hRequest);
        end
        else if (StatusCode = 200) then
        begin
          dwSize := SizeOf(FileSize);
          reserved := 0;
          if pb <> nil then
          begin
            if HttpQueryInfo(hRequest, HTTP_QUERY_CONTENT_LENGTH or HTTP_QUERY_FLAG_NUMBER, @FileSize, dwSize, reserved) then
              pb.Max := FileSize div 1024 // Number of KiB
            else
              pb.Max := 0;
          end;

          FileStream := TFileStream.Create(FileName, fmCreate);
          try
            TotalRead := 0;
            repeat
              // Lese Daten von der URL
              InternetReadFile(hRequest, @Buffer, SizeOf(Buffer), BufferLen);
              if BufferLen > 0 then
              begin
                FileStream.Write(Buffer, BufferLen);
                TotalRead := TotalRead + BufferLen;
                if pb <> nil then pb.Position := TotalRead div 1024;
              end;
              if Assigned(Application) and Application.Terminated then Abort;
            until BufferLen = 0;
          finally
            FileStream.Free;
          end;

          break;
        end
        else
          raise Exception.CreateFmt(SHTTPError, [StatusCode, 'GET', aurl]);
      finally
        InternetCloseHandle(hRequest);
      end;
    end;
  finally
    InternetCloseHandle(hSession);
  end;
end;

initialization
  DeletedList := TStringList.Create;

finalization
  FreeAndNil(DeletedList);

end.
