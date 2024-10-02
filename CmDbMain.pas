unit CmDbMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Data.DB,
  Data.Win.ADODB, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    ADOConnection1: TADOConnection;
    BackupandExit1: TMenuItem;
    Exitwithoutbackup1: TMenuItem;
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
    procedure Timer1Timer(Sender: TObject);
    procedure BackupandExit1Click(Sender: TObject);
    procedure Exitwithoutbackup1Click(Sender: TObject);
    procedure OpenDatabase1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Generalhelp1Click(Sender: TObject);
    procedure RestoreBackup1Click(Sender: TObject);
  public
    procedure RestoreMdiChild(frm: TForm);
    procedure OpenDbObject(const ATableName: string; DsGuid: TGUID);
    procedure OpenMandatorsForm;
    function FindForm(guid: TGuid; addinfo1: string=''): TForm;
    procedure ShowHelpWindow(const MDFile: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  Mandators, AdoConnHelper, StrUtils, Help,
  Artist, Commission, Mandator, Statistics, CmDbFunctions, Registry,
  ShellApi, System.UITypes;

const
  CmDbDefaultDatabaseName = 'cmdb2';

procedure TMainForm.OpenDbObject(const ATableName: string; DsGuid: TGUID);
resourcestring
  SUnexpectedTableName = 'Unexpected TableName %s';
var
  MandatorForm: TMandatorForm;
  Artistform: TArtistForm;
  CommissionForm: TCommissionForm;
begin
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
  end
  else
  begin
    raise Exception.CreateFmt(SUnexpectedTableName, [ATableName]);
  end;
end;

procedure TMainForm.About1Click(Sender: TObject);
var
  dateidatum: TDateTime;
  bits: integer;
resourcestring
  S_Version = '%s (%d Bit)'+#13#10+'Version %s'+#13#10+'by Daniel Marschall, ViaThinkSoft';
begin
  dateidatum := GetBuildTimestamp(ParamStr(0));
  {$IFDEF WIN64}
  bits := 64;
  {$ELSE}
  bits := 32;
  {$ENDIF}
  ShowMessage(Format(S_Version, [Application.Title, bits, FormatDateTime('YYYY-mm-dd', dateidatum)]));
end;

procedure TMainForm.BackupandExit1Click(Sender: TObject);
resourcestring
  S_BackupFailed = 'Backup failed (%s). Will exit without backup.';
var
  q: TAdoDataset;
  sl: TStringList;
  DBName, BackupPath, BackupFileName: string;
  LastBackupID: integer;
  i: integer;
  ChecksumNow, ChecksumThen: DWORD;
  NeedNewBackup: boolean;
begin
  for i := MDIChildCount - 1 downto 0 do
  begin
    MDIChildren[i].Close; // This will call CloseQuery
  end;

  Screen.Cursor := crHourGlass;
  WaitLabel.Visible := true;
  Application.ProcessMessages;
  try
    try
      BackupPath := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''BACKUP_PATH'';'));
      if BackupPath = '' then BackupPath := GetUserDirectory;

      NeedNewBackup := false;

      {$REGION '1. Make a Text Dump if something has changed'}
      sl := TStringList.Create;
      try
        q := ADOConnection1.GetTable('select * from vw_TEXT_BACKUP_GENERATE order by __MANDATOR_NAME, __MANDATOR_ID, DATASET_TYPE, DATASET_ID');
        try
          sl.Add('MANDATOR_ID;MANDATOR_NAME;DATASET_ID;DATASET_TYPE;NAME;MORE_DATA');
          while not q.EOF do
          begin
            sl.Add('"'+q.Fields[0].AsWideString+'";"'+q.Fields[1].AsWideString+'";"'+q.Fields[2].AsWideString+'";"'+q.Fields[3].AsWideString+'";"'+q.Fields[4].AsWideString+'";"'+q.Fields[5].AsWideString);
            q.Next;
          end;
        finally
          FreeAndNil(q);
        end;

        CheckSumNow := Adler32(sl.Text);

        q := ADOConnection1.GetTable('select top 1 BAK_ID, CHECKSUM from TEXT_BACKUP order by BAK_ID desc');
        try
          ChecksumThen := q.FieldByName('CHECKSUM').AsInteger;
          LastBackupId := q.FieldByName('BAK_ID').AsInteger;
          if (q.RecordCount = 0) or (ChecksumThen <> ChecksumNow) then
          begin
            ADOConnection1.ExecSQL('INSERT INTO TEXT_BACKUP (BAK_DATE, BAK_LINES, CHECKSUM) VALUES (getdate(), '+IntToStr(sl.Count)+', '+IntToStr(ChecksumNow)+')');
            LastBackupID := VariantToInteger(AdoConnection1.GetScalar('select max(BAK_ID) from TEXT_BACKUP'));
            sl.SaveToFile(IncludeTrailingPathDelimiter(BackupPath) + CmDbDefaultDatabaseName + '_backup_' + Format('%.5d', [LastBackupID]) + '.csv');
            NeedNewBackup := true;
          end;
        finally
          FreeAndNil(q);
        end;
      finally
        FreeAndNil(sl);
      end;
      {$ENDREGION}

      if NeedNewBackup then
      begin
        {$REGION '2. Make a SQL Backup'}
        DBName := AdoConnection1.DatabaseName;
        if BackupPath <> '' then BackupPath := IncludeTrailingPathDelimiter(BackupPath);
        BackupFileName := BackupPath + CmDbDefaultDatabaseName + '_backup_' + Format('%.5d', [LastBackupID]) + '.bak';
        if AdoConnection1.SupportsBackupCompression then
          AdoConnection1.ExecSQL('BACKUP DATABASE ' + ADOConnection1.SQLDatabaseNameEscape(DBName) + ' TO DISK = ' + ADOConnection1.SQLStringEscape(BackupFileName) + ' with format, compression;')
        else
          AdoConnection1.ExecSQL('BACKUP DATABASE ' + ADOConnection1.SQLDatabaseNameEscape(DBName) + ' TO DISK = ' + ADOConnection1.SQLStringEscape(BackupFileName) + ' with format;');
        {$ENDREGION}
      end;
    except
      on E: Exception do
      begin
        ShowMessageFmt(S_BackupFailed, [E.Message]);
      end;
    end;
  finally
    Screen.Cursor := crDefault;
    WaitLabel.Visible := false;
    Application.ProcessMessages;
  end;

  // 3. Exit
  Close;
end;

procedure TMainForm.Exitwithoutbackup1Click(Sender: TObject);
begin
  Close;
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

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := Application.Title;
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
    HelpForm.Left := Round(Screen.Width * 0.1);
    HelpForm.Top := Round(Screen.Height * 0.1);
    HelpForm.Width := Round(Screen.Width * 0.8);
    HelpForm.Height := Round(Screen.Height * 0.8);
    HelpForm.Show;
  end;
  HelpForm.ShowMarkDownHelp(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'..\'+MDFile);
  HelpForm.Caption := Format(SSHelp, [Caption]);
end;

procedure TMainForm.Generalhelp1Click(Sender: TObject);
begin
  ShowHelpWindow('README.md');
end;

procedure TMainForm.OpenMandatorsForm;
var
  MandatorsForm: TMandatorsForm;
  i: integer;
resourcestring
  SDatabase = 'Database';
begin
  for I := 0 to MDIChildCount-1 do
  begin
    if MDIChildren[i] is TMandatorsForm then
    begin
      RestoreMdiChild(MdiChildren[i]);
      exit;
    end;
  end;

  MandatorsForm := TMandatorsForm.Create(Application.MainForm);
  MandatorsForm.Caption := SDatabase;
  MandatorsForm.ADOConnection1.Connected := false;
  MandatorsForm.ADOConnection1.ConnectionString := ADOConnection1.ConnectionString;
  MandatorsForm.Init;
end;

procedure TMainForm.OpenDatabase1Click(Sender: TObject);
begin
  OpenMandatorsForm;
end;

procedure TMainForm.RestoreBackup1Click(Sender: TObject);
var
  i: integer;
begin
  OpenDialog1.InitialDir := GetUserDirectory;
  if OpenDialog1.Execute(Handle) then
  begin
    Screen.Cursor := crHourGlass;
    WaitLabel.Visible := true;
    Application.ProcessMessages;
    try
      for i := MDIChildCount - 1 downto 0 do
      begin
        MDIChildren[i].Free; // No need to call OnCloseQuery, because we will destroy all data anyways
      end;
      CmDb_RestoreDatabase(AdoConnection1, OpenDialog1.FileName);
      OpenDatabase1.Click;
    finally
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
      result := reg.KeyExists('CLSID\{EE5DE99A-4453-4C96-861C-F8832A7F59FE}') or  // Generation 3, Version 19+
                reg.KeyExists('CLSID\{5A23DE84-1D7B-4A16-8DED-B29C09CB648D}') or  // Generation 3
                reg.KeyExists('CLSID\{397C2819-8272-4532-AD3A-FB5E43BEAA39}') or  // Generation 2
                reg.KeyExists('CLSID\{0C7FF16C-38E3-11d0-97AB-00C04FC2AD98}');    // Generation 1
    finally
      FreeAndNil(reg);
    end;
  end;

  procedure DisableAllMenuItems(MainMenu: TMainMenu);
  var
    i, j: Integer;
  begin
    // Loop through all top-level menu items
    for i := 0 to MainMenu.Items.Count - 1 do
    begin
      // Disable the top-level menu item
      MainMenu.Items[i].Enabled := False;

      // Loop through all submenu items and disable them as well
      for j := 0 to MainMenu.Items[i].Count - 1 do
      begin
        MainMenu.Items[i].Items[j].Enabled := False;
      end;
    end;
  end;

resourcestring
  SRequireComponents = 'CMDB2 requires some Microsoft SQL Server components to be installed. Install them now?';
var
  _IsLocalDbInstalled: boolean;
  _SqlServerClientDriverInstalled: boolean;
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

        // 1. VC++ Runtime (both 32bit and 64bit required according to Microsoft)
        {$IFDEF Win64}
        WaitLabel.Caption := 'Installing Visual C++ Redistributable (32 Bit)...';
        Application.ProcessMessages;
        ShellExecuteWait(Handle, 'runas', PChar(ExtractFilePath(ParamStr(0))+'..\Redist\VC_redist.x86.exe'), '/install /quiet /norestart', '', SW_NORMAL, True);
        WaitLabel.Caption := 'Installing Visual C++ Redistributable (64 Bit)...';
        Application.ProcessMessages;
        ShellExecuteWait(Handle, 'runas', PChar(ExtractFilePath(ParamStr(0))+'..\Redist\VC_redist.x64.exe'), '/install /quiet /norestart', '', SW_NORMAL, True);
        {$ELSE}
        WaitLabel.Caption := 'Installing Visual C++ Redistributable (32 Bit)...';
        Application.ProcessMessages;
        ShellExecuteWait(Handle, 'runas', PChar(ExtractFilePath(ParamStr(0))+'..\Redist\VC_redist.x86.exe'), '/install /norestart', '', SW_NORMAL, True);
        {$ENDIF}

        // 2. LocalDB
        if not _IsLocalDbInstalled then
        begin
          {$IFDEF Win64}
          WaitLabel.Caption := 'Installing SQL Server LocalDB (64 Bit)...';
          Application.ProcessMessages;
          ShellExecuteWait(Handle, 'runas', 'msiexec.exe', PChar('/i "'+ExtractFilePath(ParamStr(0))+'..\Redist\SqlLocalDB.x64.msi" /passive /qn IACCEPTSQLLOCALDBLICENSETERMS=YES'), '', SW_NORMAL, True);
          {$ELSE}
          WaitLabel.Caption := 'Installing SQL Server LocalDB (32 Bit)...';
          Application.ProcessMessages;
          ShellExecuteWait(Handle, 'runas', 'msiexec.exe', PChar('/i "'+ExtractFilePath(ParamStr(0))+'..\Redist\SqlLocalDB.x86.msi" /passive /qn IACCEPTSQLLOCALDBLICENSETERMS=YES'), '', SW_NORMAL, True);
          {$ENDIF}
        end;

        // 3. OleDB Driver
        if not _SqlServerClientDriverInstalled then
        begin
          {$IFDEF Win64}
          WaitLabel.Caption := 'Installing SQL Server OLE DB Provider (64 Bit)...';
          Application.ProcessMessages;
          ShellExecuteWait(Handle, 'runas', 'msiexec.exe', PChar('/i "'+ExtractFilePath(ParamStr(0))+'..\Redist\msoledbsql19.x64.msi" /passive /qn IACCEPTMSOLEDBSQLLICENSETERMS=YES'), '', SW_NORMAL, True);
          {$ELSE}
          WaitLabel.Caption := 'Installing SQL Server OLE DB Provider (32 Bit)...';
          Application.ProcessMessages;
          ShellExecuteWait(Handle, 'runas', 'msiexec.exe', PChar('/i "'+ExtractFilePath(ParamStr(0))+'..\Redist\msoledbsql19.x86.msi" /passive /qn IACCEPTMSOLEDBSQLLICENSETERMS=YES'), '', SW_NORMAL, True);
          {$ENDIF}
        end;
      finally
        Screen.Cursor := crDefault;
        WaitLabel.Visible := false;
        Application.ProcessMessages;
      end;

      ShellExecute(Handle, 'open', PChar(ParamStr(0)), '', PChar(ExtractFilePath(ParamStr(0))), SW_NORMAL);
      {$ENDREGION}
    end
    else if MessageDlg(SRequireComponents, TMsgDlgType.mtConfirmation, mbYesNoCancel, 0) = mrYes then
    begin
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
      OpenDatabase1.Click;
    finally
      Screen.Cursor := crDefault;
      WaitLabel.Visible := false;
      Application.ProcessMessages;
    end;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Close;
      Exit;
    end;
  end;
end;

end.
