unit CmDbMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Data.DB,
  Data.Win.ADODB, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TMainForm = class(TForm)
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    ADOConnection1: TADOConnection;
    BackupandExit1: TMenuItem;
    OpenDatabase1: TMenuItem;
    About1: TMenuItem;
    Help1: TMenuItem;
    Generalhelp1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    OpenDialog1: TOpenDialog;
    RestoreBackup1: TMenuItem;
    N2: TMenuItem;
    WaitLabel: TLabel;
    Window1: TMenuItem;
    Cascade1: TMenuItem;
    TileHorizontally1: TMenuItem;
    TileVertically1: TMenuItem;
    Showtextdump1: TMenuItem;
    N3: TMenuItem;
    ProgressBar1: TProgressBar;
    procedure Timer1Timer(Sender: TObject);
    procedure BackupandExit1Click(Sender: TObject);
    procedure OpenDatabase1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Generalhelp1Click(Sender: TObject);
    procedure RestoreBackup1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Cascade1Click(Sender: TObject);
    procedure TileHorizontally1Click(Sender: TObject);
    procedure TileVertically1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Showtextdump1Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FCloseStarted: boolean;
    function RealBackupPath: string;
    procedure PerformBackupAndDefrag;
    class procedure ZeichneHintergrundschrift(text1_normal,
      text2_kursiv: string; minScale: double); static;
  public
    CmDbZipPassword: string;
    DatabaseOpenedOnce: boolean;
    procedure RestoreMdiChild(frm: TForm);
    procedure OpenDbObject(const ATableName: string; DsGuid: TGUID);
    procedure OpenDatabaseForm;
    function FindForm(guid: TGuid; addinfo1: string=''): TForm;
    procedure ShowHelpWindow(const MDFile: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  Database, AdoConnHelper, StrUtils, Help, CmDbPluginClient,
  Artist, Commission, Mandator, Statistics, CmDbFunctions, Registry,
  ShellApi, System.UITypes, System.Hash, DateUtils,
  EncryptedZipFile, System.Zip, Memo, System.IOUtils;

const
  CmDbDefaultDatabaseName = 'cmdb2';

procedure TMainForm.OpenDbObject(const ATableName: string; DsGuid: TGUID);
var
  MandatorForm: TMandatorForm;
  Artistform: TArtistForm;
  CommissionForm: TCommissionForm;
begin
  if VarIsNull(ADOConnection1.GetScalar('select top 1 ID from ' + ATableName + ' where ID = ' + AdoConnection1.SQLStringEscape(DsGuid.ToString))) then Exit;
  if ATableName = 'MANDATOR' then // do not localize
  begin
    MandatorForm := MainForm.FindForm(DsGuid) as TMandatorForm;
    if Assigned(MandatorForm) then
    begin
      MainForm.RestoreMdiChild(MandatorForm);
    end
    else
    begin
      MandatorForm := TMandatorForm.Create(Application.MainForm);
      MandatorForm.MandatorId := DsGuid;
      MandatorForm.ADOConnection1.Connected := false;
      MandatorForm.ADOConnection1.ConnectionString := ADOConnection1.ConnectionString;
      MandatorForm.Init;
    end;
  end
  else if ATableName = 'ARTIST' then // do not localize
  begin
    ArtistForm := MainForm.FindForm(DsGuid) as TArtistForm;
    if Assigned(ArtistForm) then
    begin
      MainForm.RestoreMdiChild(ArtistForm);
    end
    else
    begin
      ArtistForm := TArtistForm.Create(Application.MainForm);
      ArtistForm.ArtistId := DsGuid;
      ArtistForm.ADOConnection1.Connected := false;
      ArtistForm.ADOConnection1.ConnectionString := ADOConnection1.ConnectionString;
      ArtistForm.Init;
    end;
  end
  else if ATableName = 'COMMISSION' then // do not localize
  begin
    CommissionForm := MainForm.FindForm(DsGuid) as TCommissionForm;
    if Assigned(CommissionForm) then
    begin
      MainForm.RestoreMdiChild(CommissionForm);
    end
    else
    begin
      CommissionForm := TCommissionForm.Create(Application.MainForm);
      CommissionForm.CommissionId := DsGuid;
      CommissionForm.ADOConnection1.Connected := false;
      CommissionForm.ADOConnection1.ConnectionString := ADOConnection1.ConnectionString;
      CommissionForm.Init;
    end;
  end;
end;

procedure TMainForm.About1Click(Sender: TObject);
var
  dateidatum: TDateTime;
  bits: integer;
  slPlugins: TStringList;
  CopyRightYear: string;
  InstallId: string;
resourcestring
  S_Version = '%s (%d Bit), Version %s'+#13#10+'(C) %s %s'+#13#10+'License: %s';
  S_InstallId = 'Installation ID: %s';
  S_InstalledPlugins = 'Installed plugins:';
const
  Author = 'Daniel Marschall, ViaThinkSoft';
  License = 'Apache 2.0';
  DevelopmentStartYear = 2024; // DO NOT CHANGE; this is the start year, not the current year
  GitHubVersion = '1.8.0'; // Change this once you release something new
begin
  dateidatum := GetBuildTimestamp(ParamStr(0));
  InstallId := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''INSTALL_ID'';'));
  {$IFDEF WIN64}
  bits := 64;
  {$ELSE}
  bits := 32;
  {$ENDIF}
  slPlugins := TStringList.Create;
  try
    TCmDbPluginClient.GetVersionInfoOfPlugins(slPlugins);
    if slPlugins.Count > 0 then
    begin
      slPlugins.Insert(0, '');
      slPlugins.Insert(0, S_InstalledPlugins);
      slPlugins.Insert(0, '');
    end;
    if YearOf(dateidatum) > DevelopmentStartYear then
      CopyRightYear := IntToStr(DevelopmentStartYear) + '-' + IntToStr(YearOf(dateidatum))
    else
      CopyRightYear := IntToStr(DevelopmentStartYear);
    slPlugins.Insert(0, '');
    slPlugins.Insert(0, Format(S_InstallId, [InstallId]));
    slPlugins.Insert(0, '');
    slPlugins.Insert(0, Format(S_Version, [Application.Title, bits, GitHubVersion + ' / ' + FormatDateTime('YYYY-mm-dd', dateidatum), CopyRightYear, Author, License])); // do not localize

    MessageBox(Application.Handle, PChar(slPlugins.Text), PChar(Application.Title), MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
  finally
    FreeAndNil(slPlugins);
  end;
end;

function TMainForm.RealBackupPath: string;
begin
  Result := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''BACKUP_PATH'';'));
  if Result = '' then Result := CmDb_GetDefaultBackupPath;
end;

procedure TMainForm.BackupandExit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.PerformBackupAndDefrag;
resourcestring
  S_BackupFailed = 'Backup failed (%s). Will exit without backup.';
  SPleaseWaitDefragBackup = 'Please wait... Defrag and create backup...';
var
  sl: TStringList;
  DBName, BackupFileName: string;
  NextBackupID: integer;
  i: integer;
  ChecksumNow, ChecksumThen: string;
  zip: TZipFile;
const
  BACKUP_TXT_EXT = '.txt';
  BACKUP_ZIP_EXT = '.zip';
  BACKUP_BAK_EXT = '.bak';
begin
  for i := MDIChildCount - 1 downto 0 do
  begin
    MDIChildren[i].Close; // This will call CloseQuery
  end;

  Screen.Cursor := crHourGlass;
  WaitLabel.Caption := SPleaseWaitDefragBackup;
  WaitLabel.Visible := true;
  Application.ProcessMessages;
  try
    try
      NextBackupID := -1;

      // Avoid that the user clicks something!
      DisableAllMenuItems(MainMenu1);
      Application.ProcessMessages;

      if DatabaseOpenedOnce then
      begin
        // Just make sure that these are all correct (they can be wrong if the data was edited outside of CMDB2)
        TCommissionForm.RegnerateQuoteAnnotationAll(AdoConnection1);
        TCommissionForm.RegnerateUploadAnnotationAll(AdoConnection1);

        // Make some optimizations for performance
        CmDb_DropTempTables(AdoConnection1);
        ADOConnection1.ExecSQL('delete from [STATISTICS]'); // this is also some kind of temporary table, since it will be always re-built
        DefragIndexes(AdoConnection1);
        ADOConnection1.ExecSQL('exec sp_updatestats');
      end;

      sl := TStringList.Create;
      try
        if DatabaseOpenedOnce then
        begin
          {$REGION 'Check if something has changed'}
          CmDb_GetFullTextDump(AdoConnection1, sl);
          CheckSumNow := THashSHA2.GetHashString(sl.Text); // SHA256
          ChecksumThen := VariantToString(ADOConnection1.GetScalar('select top 1 CHECKSUM from [BACKUP] order by BAK_ID desc'));
          if not SameText(ChecksumThen, ChecksumNow) then
          begin
            NextBackupID := VariantToInteger(AdoConnection1.GetScalar('select isnull(max(BAK_ID),0)+1 from [BACKUP];'));
          end;
          {$ENDREGION}
        end;

        if NextBackupID > 0 then
        begin
          {$REGION '1. Make a SQL Backup'}
          DBName := AdoConnection1.DatabaseName;
          BackupFileName := IncludeTrailingPathDelimiter(RealBackupPath) + CmDbDefaultDatabaseName + '_backup_' + Format('%.5d', [NextBackupID]) + '.bak';
          if AdoConnection1.SupportsBackupCompression then
            AdoConnection1.ExecSQL('BACKUP DATABASE ' + ADOConnection1.SQLDatabaseNameEscape(DBName) + ' TO DISK = ' + ADOConnection1.SQLStringEscape(BackupFileName) + ' with format, compression;')
          else
            AdoConnection1.ExecSQL('BACKUP DATABASE ' + ADOConnection1.SQLDatabaseNameEscape(DBName) + ' TO DISK = ' + ADOConnection1.SQLStringEscape(BackupFileName) + ' with format;');
          {$ENDREGION}

          {$REGION '2. Write the Text Dump and Protocol Entry'}
          sl.SaveToFile(IncludeTrailingPathDelimiter(RealBackupPath) + CmDbDefaultDatabaseName + '_backup_' + Format('%.5d', [NextBackupID]) + BACKUP_TXT_EXT);
          ADOConnection1.ExecSQL('INSERT INTO [BACKUP] (BAK_ID, BAK_DATE, BAK_LINES, CHECKSUM) VALUES ('+IntToStr(NextBackupID)+', getdate(), '+IntToStr(sl.Count)+', '+AdoConnection1.SQLStringEscape(ChecksumNow)+')');
          {$ENDREGION}

          {$REGION 'Password-Encrypt ZIP file'}
          try
            if CmDbZipPassword = '' then
              zip := TZipFile.Create()
            else
              zip := TEncryptedZipFile.Create(CmDbZipPassword);
            try
              zip.Open(IncludeTrailingPathDelimiter(RealBackupPath) + CmDbDefaultDatabaseName + '_backup_' + Format('%.5d', [NextBackupID]) + BACKUP_ZIP_EXT, TZipMode.zmWrite);
              try
                zip.Add(IncludeTrailingPathDelimiter(RealBackupPath) + CmDbDefaultDatabaseName + '_backup_' + Format('%.5d', [NextBackupID]) + BACKUP_BAK_EXT);
                zip.Add(IncludeTrailingPathDelimiter(RealBackupPath) + CmDbDefaultDatabaseName + '_backup_' + Format('%.5d', [NextBackupID]) + BACKUP_TXT_EXT);
              finally
                zip.Close;
              end;
              DeleteFile(IncludeTrailingPathDelimiter(RealBackupPath) + CmDbDefaultDatabaseName + '_backup_' + Format('%.5d', [NextBackupID]) + BACKUP_BAK_EXT);
              DeleteFile(IncludeTrailingPathDelimiter(RealBackupPath) + CmDbDefaultDatabaseName + '_backup_' + Format('%.5d', [NextBackupID]) + BACKUP_TXT_EXT);
            finally
              FreeAndNil(zip);
            end;
          except
            on E: EAbort do
            begin
              Abort;
            end;
            on E: Exception do
            begin
              DeleteFile(IncludeTrailingPathDelimiter(RealBackupPath) + CmDbDefaultDatabaseName + '_backup_' + Format('%.5d', [NextBackupID]) + BACKUP_ZIP_EXT);
            end;
          end;
          {$ENDREGION}
        end;
      finally
        FreeAndNil(sl);
      end;
    except
      on E: EAbort do
      begin
        Abort;
      end;
      on E: Exception do
      begin
        MessageBox(Application.Handle, PChar(Format(S_BackupFailed, [E.Message])), PChar(Application.Title), MB_OK or MB_ICONERROR or MB_TASKMODAL);
      end;
    end;
  finally
    Screen.Cursor := crDefault;
    WaitLabel.Visible := false;
    Application.ProcessMessages;
  end;
end;

function TMainForm.FindForm(guid: TGuid; addinfo1: string=''): TForm;
var
  i: integer;
begin
  for i := 0 to MDIChildCount-1 do
  begin
    if MdiChildren[i] is TArtistForm then
    begin
      if IsEqualGUID(TArtistForm(MdiChildren[i]).ArtistId, guid) then
        Exit(MdiChildren[i]);
    end
    else if MdiChildren[i] is TCommissionForm then
    begin
      if IsEqualGUID(TCommissionForm(MdiChildren[i]).CommissionId, guid) then
        Exit(MdiChildren[i]);
    end
    else if MdiChildren[i] is TMandatorForm then
    begin
      if IsEqualGUID(TMandatorForm(MdiChildren[i]).MandatorId, guid) then
        Exit(MdiChildren[i]);
    end
    else if MdiChildren[i] is TStatisticsForm then
    begin
      if IsEqualGUID(TStatisticsForm(MdiChildren[i]).StatisticsId, guid) then
      begin
        if addinfo1 = TStatisticsForm.AddInfo(TStatisticsForm(MdiChildren[i]).MandatorId, TStatisticsForm(MdiChildren[i]).SqlTable, TStatisticsForm(MdiChildren[i]).SqlInitialOrder, TStatisticsForm(MdiChildren[i]).SqlAdditionalFilter) then
          Exit(MdiChildren[i]);
      end;
    end;
  end;
  Exit(nil);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FCloseStarted then Exit;
  FCloseStarted := true;
  try
    PerformBackupAndDefrag;
  except
    on E: EAbort do
    begin
      Abort;
    end;
    on E: Exception do
    begin
      // ignore
    end;
  end;
  try
    AdoConnection1.Disconnect;
  except
    on E: EAbort do
    begin
      Abort;
    end;
    on E: Exception do
    begin
      // ignore
    end;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := Application.Title;
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // TODO: Does not work. FormKeyUp is not called
  if (Key = VK_F1) and (Shift = []) and (ActiveMDIChild = nil) then
  begin
    Generalhelp1.Click;
  end;
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  ZeichneHintergrundschrift('CMDB2', '', 0.55);
end;

procedure TMainForm.Cascade1Click(Sender: TObject);
begin
  // Cascade all MDI child forms
  Cascade;
end;

procedure TMainForm.TileHorizontally1Click(Sender: TObject);
begin
  // Tile MDI child forms horizontally
  TileMode := tbHorizontal;
  Tile;
end;

procedure TMainForm.TileVertically1Click(Sender: TObject);
begin
  // Tile MDI child forms vertically
  TileMode := tbVertical;
  Tile;
end;

procedure TMainForm.ShowHelpWindow(const MDFile: string);
resourcestring
  SSHelp = '%s Help';
begin
  if Assigned(HelpForm) then
  begin
    RestoreMdiChild(HelpForm);
  end
  else
  begin
    HelpForm := THelpForm.Create(self);
    HelpForm.Left := Round(ClientWidth * 0.1);
    HelpForm.Top := Round(ClientHeight * 0.1);
    HelpForm.Width := Round(ClientWidth * 0.8);
    HelpForm.Height := Round(ClientHeight * 0.8);
    HelpForm.Show;
  end;
  HelpForm.ShowMarkDownHelp(MDFile);
  HelpForm.Caption := Format(SSHelp, [Caption]);
end;

procedure TMainForm.Generalhelp1Click(Sender: TObject);
begin
  ShowHelpWindow('README.md');
end;

procedure TMainForm.OpenDatabaseForm;
var
  DatabaseForm: TDatabaseForm;
  i: integer;
resourcestring
  SDatabase = 'Database';
begin
  for I := 0 to MDIChildCount-1 do
  begin
    if MDIChildren[i] is TDatabaseForm then
    begin
      RestoreMdiChild(MdiChildren[i]);
      exit;
    end;
  end;

  DatabaseForm := TDatabaseForm.Create(Application.MainForm);
  DatabaseForm.Caption := SDatabase;
  DatabaseForm.ADOConnection1.Connected := false;
  DatabaseForm.ADOConnection1.ConnectionString := ADOConnection1.ConnectionString;
  DatabaseForm.Init;
end;

procedure TMainForm.OpenDatabase1Click(Sender: TObject);
begin
  OpenDatabaseForm;
end;

class procedure TMainForm.ZeichneHintergrundschrift(text1_normal, text2_kursiv: string; minScale: double);
var
  coraFontColor: TColor;
  frm: TForm;

  procedure _ChangeToText1(size: integer);
  begin
    frm.Canvas.Font.Color := coraFontColor;
    frm.Canvas.Font.Name := 'Arial';
    frm.Canvas.Font.Height := -size;
    frm.Canvas.Font.Style := [fsBold];
  end;

  procedure _ChangeToText2(size: integer);
  begin
    frm.Canvas.Font.Color := coraFontColor;
    frm.Canvas.Font.Name := 'Arial';
    frm.Canvas.Font.Height := -size;
    frm.Canvas.Font.Style := [fsBold, fsItalic];
  end;

var
  x1, x2, y1, y2, w1, w2, h1, h2, size: Int64;
begin
  frm := Application.MainForm;

  coraFontColor := $151515; //IncreaseColorLightness(frm.Color, 20);

  frm.Canvas.Lock;
  try
    size := 10;
    repeat
      _ChangeToText1(size);
      w1 := frm.Canvas.TextWidth(text1_normal);
      _ChangeToText2(size);
      w2 := frm.Canvas.TextWidth(text2_kursiv);
      Inc(size);
      if size > 1000 then exit; // irgendwas läuft schief. Notbremse ziehen.
    until (w1+w2)/frm.ClientWidth > minScale;

    _ChangeToText1(size);
    w1 := frm.Canvas.TextWidth(text1_normal);
    h1 := frm.Canvas.TextHeight(text1_normal);

    _ChangeToText2(size);
    w2 := frm.Canvas.TextWidth(text2_kursiv);
    h2 := frm.Canvas.TextHeight(text2_kursiv);

    x1 := frm.ClientWidth div 2 - (w1+w2) div 2;
    y1 := frm.ClientHeight div 2 - h1 div 2;
    x2 := x1 + w1;
    y2 := frm.ClientHeight div 2 - h2 div 2;

    _ChangeToText1(size);
    frm.Canvas.TextOut(x1, y1, text1_normal);
    _ChangeToText2(size);
    frm.Canvas.TextOut(x2, y2, text2_kursiv);
  finally
    frm.Canvas.Unlock;
  end;
end;

procedure TMainForm.RestoreBackup1Click(Sender: TObject);
var
  i: integer;
  bakFileName: string;
  zip: TEncryptedZipFile;
  stmp: string;
  deleteBakFileAfterwards: boolean;
resourcestring
  SInvalidBackupFile = 'Invalid backup file';
  SZipPassword = 'ZIP Password';
  SPleaseWaitRestore = 'Please wait... Restore database...';
begin
  OpenDialog1.InitialDir := RealBackupPath;
  if OpenDialog1.Execute(Handle) then
  begin
    if string.EndsText('.bak', OpenDialog1.FileName) then
    begin
      bakFileName := OpenDialog1.FileName;
      deleteBakFileAfterwards := false;
    end
    else if string.EndsText('.zip', OpenDialog1.FileName) then
    begin
      {$REGION 'Extract ZIP file'}
      if CmDbZipPassword = '' then
        zip := TEncryptedZipFile.Create('dummy') // 'dummy' password, we need to enter "any" non-empty password until we can ask the user
      else
        zip := TEncryptedZipFile.Create(CmDbZipPassword);
      try
        zip.open(OpenDialog1.FileName, zmRead);
        while true do
        begin
          try
            bakFileName := '';
            for stmp in zip.FileNames do
            begin
              if string.StartsText('cmdb2_backup_', stmp) and string.EndsText('.bak', stmp) then
              begin
                bakFileName := stmp;
                break;
              end;
            end;
            if bakFileName = '' then raise Exception.Create(SInvalidBackupFile);
            zip.Extract(bakFileName, CmDb_GetTempPath, false);
            bakFileName := IncludeTrailingPathDelimiter(CmDb_GetTempPath) + bakFileName;
            deleteBakFileAfterwards := true;
            if zip.Password <> '' then CmDbZipPassword := zip.Password;
            break;
          except
            on E: EAbort do
            begin
              Abort;
            end;
            on E: EZipInvalidPassword do
            begin
              zip.Password := InputBox(Caption, #0+SZipPassword, '');
            end;
            on E: EZipNoPassword do
            begin
              Abort;
            end;
            on E: Exception do
            begin
              raise;
            end;
          end;
        end;
        zip.Close;
      finally
        FreeAndNil(zip);
      end;
      {$ENDREGION}
    end
    else
    begin
      raise Exception.Create(SInvalidBackupFile);
    end;
    Screen.Cursor := crHourGlass;
    WaitLabel.Caption := SPleaseWaitRestore;
    WaitLabel.Visible := true;
    Application.ProcessMessages;
    try
      for i := MDIChildCount - 1 downto 0 do
      begin
        MDIChildren[i].Release; // No need to call OnCloseQuery, because we will destroy all data anyways
      end;
      Application.ProcessMessages;

      // Avoid that the user clicks something!
      DisableAllMenuItems(MainMenu1);
      Application.ProcessMessages;
      try
        CmDb_RestoreDatabase(AdoConnection1, bakFileName);
        OpenDatabaseForm;
      finally
        EnableAllMenuItems(MainMenu1);
        Application.ProcessMessages;
      end;
    finally
      if deleteBakFileAfterwards then
        DeleteFile(bakFileName);
      Screen.Cursor := crDefault;
      WaitLabel.Visible := false;
      Application.ProcessMessages;
    end;
  end;
end;

procedure TMainForm.RestoreMdiChild(frm: TForm);
begin
  if frm.WindowState = TWindowState.wsMinimized then
  begin
    if Assigned(ActiveMDIChild) and (ActiveMDIChild.WindowState=TWindowState.wsMaximized) then
      frm.WindowState := TWindowState.wsMaximized
    else
      frm.WindowState := TWindowState.wsNormal;
  end;
  frm.BringToFront;
  frm.SetFocus;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);

  function IsLocalDbInstalled: boolean;
  var
    reg: TRegistry;
  begin
    result := false;
    reg := TRegistry.Create;
    try
      reg.RootKey := HKEY_LOCAL_MACHINE;
      if reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Microsoft SQL Server Local DB\Installed Versions') then // do not localize
      begin
        result := reg.HasSubKeys;
        reg.CloseKey;
      end;
    finally
      FreeAndNil(reg);
    end;
  end;

  function SqlServerClientDriverInstalled: boolean;
  var
    reg: TRegistry;
  begin
    reg := TRegistry.Create;
    try
      reg.RootKey := HKEY_CLASSES_ROOT;
      result := reg.KeyExists('CLSID\{EE5DE99A-4453-4C96-861C-F8832A7F59FE}')  // Generation 3, Version 19+
             or reg.KeyExists('CLSID\{5A23DE84-1D7B-4A16-8DED-B29C09CB648D}'); // Generation 3
          // Generation 1 does not support LocalDB, and version 2 only supports LocalDB until SQL Server 2012.
          // or reg.KeyExists('CLSID\{397C2819-8272-4532-AD3A-FB5E43BEAA39}')  // Generation 2
          // or reg.KeyExists('CLSID\{0C7FF16C-38E3-11d0-97AB-00C04FC2AD98}'); // Generation 1
    finally
      FreeAndNil(reg);
    end;
  end;

  type
    TGetLocalOrDownloadedExeResult = record
      filename: string;
      isTemp: boolean;
    end;

  function _GetLocalOrDownloadedExe(const ExeRelName, ProductName: string): TGetLocalOrDownloadedExeResult;
  var
    LocalExe, DownloadUrl: string;
  begin
    // TPath.GetFullPath() is very important, because msiexec.exe won't work if there is a "..\" in the path
    LocalExe := TPath.GetFullPath(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + '..\Redist\' + ExeRelName);
    DownloadUrl := 'https://github.com/danielmarschall/cmdb2/raw/refs/heads/master/Redist/' + ExeRelName;
    if FileExists(LocalExe) then
    begin
      result.filename := LocalExe;
      result.isTemp := false;
    end
    else
    begin
      WaitLabel.Caption := 'Downloading '+ProductName+'...';
      Application.ProcessMessages;
      result.filename := IncludeTrailingPathDelimiter(CmDb_GetTempPath) + ExtractFileName(LocalExe);
      result.isTemp := true;
      ProgressBar1.Visible := true;
      try
        ProgressBar1.Min := 0;
        ProgressBar1.Position := 0;
        WinInet_DownloadFile(DownloadUrl, result.filename, ProgressBar1);
      finally
        ProgressBar1.Visible := false;
      end;
    end;
    WaitLabel.Caption := 'Installing '+ProductName+'...';

    Application.ProcessMessages;
  end;

  procedure _DeleteIfTemporary(f: TGetLocalOrDownloadedExeResult);
  begin
    if f.isTemp and FileExists(f.filename) then DeleteFile(f.filename);
  end;

resourcestring
  SRequireComponents = 'CMDB2 requires some Microsoft SQL Server components to be installed. Install them now?';
  SPleaseAcceptUac = 'Please accept the permission dialog (blinking in the task bar?)';
var
  _IsLocalDbInstalled: boolean;
  _SqlServerClientDriverInstalled: boolean;
  tmpDF: TGetLocalOrDownloadedExeResult;
begin
  Timer1.Enabled := false;

  _IsLocalDbInstalled := IsLocalDbInstalled;
  _SqlServerClientDriverInstalled := SqlServerClientDriverInstalled;

  if not _IsLocalDbInstalled or not _SqlServerClientDriverInstalled then
  begin
    if ParamStr(1) = '/installredist' then
    begin
      {$REGION 'Redist install'}
      Screen.Cursor := crHourGlass;
      WaitLabel.Visible := true;
      Application.ProcessMessages;
      try
        // Avoid that the user clicks something!
        DisableAllMenuItems(MainMenu1);
        Application.ProcessMessages;

        // 1. Visual C++ Runtime (both 32bit and 64bit required according to Microsoft)
        if WindowsBits = 64 then
        begin
          tmpDF := _GetLocalOrDownloadedExe('VC_redist.x86.exe', 'Visual C++ Redistributable (32 Bit)');
          ShellExecuteWait(Handle, 'runas', PChar(tmpDF.filename), '/install /quiet /norestart', '', SW_NORMAL, True);
          _DeleteIfTemporary(tmpDF);

          tmpDF := _GetLocalOrDownloadedExe('VC_redist.x64.exe', 'Visual C++ Redistributable (64 Bit)');
          ShellExecuteWait(Handle, 'runas', PChar(tmpDF.filename), '/install /quiet /norestart', '', SW_NORMAL, True);
          _DeleteIfTemporary(tmpDF);
        end
        else
        begin
          tmpDF := _GetLocalOrDownloadedExe('VC_redist.x86.exe', 'Visual C++ Redistributable (32 Bit)');
          ShellExecuteWait(Handle, 'runas', PChar(tmpDF.filename), '/install /quiet /norestart', '', SW_NORMAL, True);
          _DeleteIfTemporary(tmpDF);
        end;

        // 2. LocalDB
        if not _IsLocalDbInstalled then
        begin
          if WindowsBits = 64 then
          begin
            tmpDF := _GetLocalOrDownloadedExe('SqlLocalDB.x64.msi', 'SQL Server LocalDB (64 Bit)');
            ShellExecuteWait(Handle, 'runas', 'msiexec.exe', PChar('/i "'+tmpDF.filename+'" /passive /qn IACCEPTSQLLOCALDBLICENSETERMS=YES'), '', SW_NORMAL, True);
            _DeleteIfTemporary(tmpDF);
          end
          else
          begin
            tmpDF := _GetLocalOrDownloadedExe('SqlLocalDB.x86.msi', 'SQL Server LocalDB (32 Bit)');
            ShellExecuteWait(Handle, 'runas', 'msiexec.exe', PChar('/i "'+tmpDF.filename+'" /passive /qn IACCEPTSQLLOCALDBLICENSETERMS=YES'), '', SW_NORMAL, True);
            _DeleteIfTemporary(tmpDF);
          end;
        end;

        // 3. OleDB Driver
        if not _SqlServerClientDriverInstalled then
        begin
          if WindowsBits = 64 then
          begin
            tmpDF := _GetLocalOrDownloadedExe('msoledbsql19.x64.msi', 'SQL Server OLE DB Provider (64 Bit)');
            ShellExecuteWait(Handle, 'runas', 'msiexec.exe', PChar('/i "'+tmpDF.filename+'" /passive /qn IACCEPTMSOLEDBSQLLICENSETERMS=YES'), '', SW_NORMAL, True);
            _DeleteIfTemporary(tmpDF);
          end
          else
          begin
            tmpDF := _GetLocalOrDownloadedExe('msoledbsql19.x86.msi', 'SQL Server OLE DB Provider (32 Bit)');
            ShellExecuteWait(Handle, 'runas', 'msiexec.exe', PChar('/i "'+tmpDF.filename+'" /passive /qn IACCEPTMSOLEDBSQLLICENSETERMS=YES'), '', SW_NORMAL, True);
            _DeleteIfTemporary(tmpDF);
          end;
        end;
      finally
        Screen.Cursor := crDefault;
        WaitLabel.Visible := false;
        Application.ProcessMessages;
      end;

      ShellExecute(Handle, 'open', PChar(ParamStr(0)), '', PChar(ExtractFilePath(ParamStr(0))), SW_NORMAL);
      {$ENDREGION}
    end
    else if MessageBox(Application.Handle, PChar(SRequireComponents), PChar(Application.Title), MB_YESNOCANCEL or MB_ICONQUESTION or MB_TASKMODAL) = ID_YES then
    begin
      WaitLabel.Caption := SPleaseAcceptUac;
      WaitLabel.Visible := true;
      ShellExecute(Handle, 'runas', PChar(ParamStr(0)), '/installredist', PChar(ExtractFilePath(ParamStr(0))), SW_NORMAL);
    end;
    Close;
    Exit;
  end;

  try
    Screen.Cursor := crHourGlass;
    WaitLabel.Visible := true;
    Application.ProcessMessages;
    try
      CmDb_ConnectViaLocalDb(ADOConnection1, CmDbDefaultDatabaseName);
      CmDb_InstallOrUpdateSchema(ADOConnection1);
      CmDb_DropTempTables(ADOConnection1); // Plugins won't drop existing tables to avoid that states of open windows are destroyed. So, we make sure no old temp tables exist
      OpenDatabaseForm;
    finally
      Screen.Cursor := crDefault;
      WaitLabel.Visible := false;
      Application.ProcessMessages;
    end;
  except
    on E: EAbort do
    begin
      Abort;
    end;
    on E: Exception do
    begin
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title), MB_OK or MB_ICONERROR or MB_TASKMODAL);
      Close;
      Exit;
    end;
  end;
end;

procedure TMainForm.Showtextdump1Click(Sender: TObject);
var
  sl: TStrings;
resourcestring
  SPleaseWait = 'Please wait... create text dump...';
  STextdump = 'Text dump';
begin
  if not CmDb_DatabasePasswordcheck(AdoConnection1) then exit;
  if Assigned(MemoForm) then
  begin
    RestoreMdiChild(MemoForm);
    MemoForm.Memo1.Clear;
  end
  else
  begin
    MemoForm := TMemoForm.Create(self);
    MemoForm.Left := Round(ClientWidth * 0.1);
    MemoForm.Top := Round(ClientHeight * 0.1);
    MemoForm.Width := Round(ClientWidth * 0.8);
    MemoForm.Height := Round(ClientHeight * 0.8);
  end;
  MemoForm.Caption := SPleaseWait;
  Screen.Cursor := crHourGlass;
  sl := TStringList.Create;
  try
    CmDb_GetFullTextDump(AdoConnection1, sl);
    MemoForm.Memo1.Lines.AddStrings(sl);
  finally
    FreeAndNil(sl);
    Screen.Cursor := crDefault;
  end;
  MemoForm.Caption := STextDump;
  MemoForm.Show;
end;

end.
