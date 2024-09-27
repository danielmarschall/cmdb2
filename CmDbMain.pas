unit CmDbMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Data.DB,
  Data.Win.ADODB;

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
    function FindForm(guid: TGuid): TForm;
    procedure ShowHelpWindow(const MDFile: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  Mandators, CmDbTextBackup, AdoConnHelper, StrUtils, Help,
  Artist, Commission, Mandator, Statistics, CmDbFunctions;

const
  CmDbDefaultDatabaseName = 'cmdb2';

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
  ShowMessage(Format(S_Version, [Application.Title, bits, FormatDateTime('YYYY-mm-dd', dateidatum)])); // do not localize
end;

procedure TMainForm.BackupandExit1Click(Sender: TObject);
resourcestring
  S_BackupFailed = 'Backup failed (%s). Will exit without backup.';
var
  q: TAdoDataset;
  sl: TStringList;
  DBName, BackupPath, BackupFileName: string;
  LastBackupID: integer;
begin
  Screen.Cursor := crHourGlass;
  try
    try
      {$REGION '1. Make a Text Dump if something has changed'}
      q := ADOConnection1.GetTable('select * from vw_STAT_TEXT_EXPORT order by __MANDATOR_NAME, __MANDATOR_ID, DATASET_TYPE, DATASET_ID');
      sl := TStringList.Create;
      try
        sl.Add('MANDATOR_ID;MANDATOR_NAME;DATASET_ID;DATASET_TYPE;NAME;MORE_DATA');
        while not q.EOF do
        begin
          sl.Add(q.Fields[0].AsWideString+';'+q.Fields[1].AsWideString+';'+q.Fields[2].AsWideString+';'+q.Fields[3].AsWideString+';'+q.Fields[4].AsWideString+';'+q.Fields[5].AsWideString);
          q.Next;
        end;
        LastBackupID := VariantToInteger(AdoConnection1.GetScalar('select max(BAK_ID) from TEXT_BACKUP'));
        if (LastBackupID = 0) or (RetrieveAndDecompressText(AdoConnection1, LastBackupId) <> sl.Text) then
        begin
          CompressAndStoreText(AdoConnection1, sl);
          LastBackupID := VariantToInteger(AdoConnection1.GetScalar('select max(BAK_ID) from TEXT_BACKUP'));
        end;
      finally
        FreeAndNil(q);
        FreeAndNil(sl);
      end;
      {$ENDREGION}

      {$REGION '2. Make a SQL Backup'}
      BackupPath := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''BACKUP_PATH'';'));
      DBName := AdoConnection1.DatabaseName;
      if BackupPath <> '' then BackupPath := IncludeTrailingPathDelimiter(BackupPath);
      BackupFileName := BackupPath + CmDbDefaultDatabaseName + '_backup_' + Format('%.5d', [LastBackupID]) + '.bak';
      if AdoConnection1.SupportsBackupCompression then
        AdoConnection1.ExecSQL('BACKUP DATABASE ' + ADOConnection1.SQLDatabaseNameEscape(DBName) + ' TO DISK = ' + ADOConnection1.SQLStringEscape(BackupFileName) + ' with format, compression;')
      else
        AdoConnection1.ExecSQL('BACKUP DATABASE ' + ADOConnection1.SQLDatabaseNameEscape(DBName) + ' TO DISK = ' + ADOConnection1.SQLStringEscape(BackupFileName) + ' with format;');
      {$ENDREGION}
    except
      on E: Exception do
      begin
        ShowMessageFmt(S_BackupFailed, [E.Message]);
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  // 3. Exit
  Close;
end;

procedure TMainForm.Exitwithoutbackup1Click(Sender: TObject);
begin
  Close;
end;

function TMainForm.FindForm(guid: TGuid): TForm;
var
  i: integer;
begin
  for i := 0 to MDIChildCount-1 do
  begin
    if MdiChildren[i] is TArtistForm then
    begin
      if IsEqualGUID(TArtistForm(MdiChildren[i]).ArtistId, guid) then
        Exit(MdiChildren[i]);
    end;
    if MdiChildren[i] is TCommissionForm then
    begin
      if IsEqualGUID(TCommissionForm(MdiChildren[i]).CommissionId, guid) then
        Exit(MdiChildren[i]);
    end;
    if MdiChildren[i] is TMandatorForm then
    begin
      if IsEqualGUID(TMandatorForm(MdiChildren[i]).MandatorId, guid) then
        Exit(MdiChildren[i]);
    end;
    if MdiChildren[i] is TStatisticsForm then
    begin
      if IsEqualGUID(TStatisticsForm(MdiChildren[i]).StatisticsId, guid) then
        Exit(MdiChildren[i]);
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
  SSHelp = '%s Help: %s';
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
  HelpForm.ShowMarkDownHelp(MDFile);
  HelpForm.Caption := Format(SSHelp, [Caption, MDFile.Replace('HELP_', '', [rfIgnoreCase]).Replace('.md', '', [rfIgnoreCase])]);
end;

procedure TMainForm.Generalhelp1Click(Sender: TObject);
begin
  ShowHelpWindow('README.md');
end;

procedure TMainForm.OpenDatabase1Click(Sender: TObject);
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

procedure TMainForm.RestoreBackup1Click(Sender: TObject);
begin
  OpenDialog1.InitialDir := GetUserDirectory;
  if OpenDialog1.Execute(Handle) then
  begin
    while MDIChildCount > 0 do
      MDIChildren[0].Free;
    CmDb_RestoreDatabase(AdoConnection1, OpenDialog1.FileName);
    OpenDatabase1.Click;
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
begin
  Timer1.Enabled := false;

  try
    CmDb_ConnectViaLocalDb(ADOConnection1, CmDbDefaultDatabaseName);
    CmDb_InstallOrUpdateSchema(ADOConnection1);
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Close;
      Exit;
    end;
  end;

  OpenDatabase1.Click;
end;

end.
