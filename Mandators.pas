unit Mandators;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Data.Win.ADODB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.Buttons, Vcl.DBCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls;

type
  TMandatorsForm = class(TForm)
    dbgMandator: TDBGrid;
    dsMandator: TDataSource;
    ADOConnection1: TADOConnection;
    ttMandator: TADOQuery;
    navMandator: TDBNavigator;
    PageControl1: TPageControl;
    tsMandator: TTabSheet;
    Panel1: TPanel;
    ttMandatorID: TGuidField;
    ttMandatorNAME: TWideStringField;
    Edit1: TEdit;
    SearchBtn: TButton;
    ttTextBackup: TADOQuery;
    dsTextBackup: TDataSource;
    tsTextDumps: TTabSheet;
    dbgTextBackup: TDBGrid;
    navTextBackup: TDBNavigator;
    ttTextBackupBAK_ID: TAutoIncField;
    ttTextBackupBAK_DATE: TDateTimeField;
    ttTextBackupBAK_LINES: TIntegerField;
    ttTextBackupANNOTATION: TWideStringField;
    ttConfig: TADOQuery;
    dsConfig: TDataSource;
    ttConfigNAME: TWideStringField;
    ttConfigVALUE: TWideStringField;
    ttConfigHELP_TEXT: TWideStringField;
    tsConfig: TTabSheet;
    navConfig: TDBNavigator;
    dbgConfig: TDBGrid;
    Timer1: TTimer;
    sbConfig: TPanel;
    csvConfig: TButton;
    sbTextBackup: TPanel;
    csvTextBackup: TButton;
    sbMandator: TPanel;
    csvMandator: TButton;
    sdCsvMandator: TSaveDialog;
    sdCsvTextBackup: TSaveDialog;
    sdCsvConfig: TSaveDialog;
    refreshConfig: TBitBtn;
    refreshTextBackup: TBitBtn;
    refreshMandator: TBitBtn;
    HelpBtn: TButton;
    ttConfigHIDDEN: TBooleanField;
    ttConfigREAD_ONLY: TBooleanField;
    ttTextBackupCHECKSUM: TStringField;
    Timer2: TTimer;
    openMandator: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgMandatorDblClick(Sender: TObject);
    procedure ttMandatorNewRecord(DataSet: TDataSet);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Edit1Change(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchBtnClick(Sender: TObject);
    procedure ttTextBackupBeforeInsert(DataSet: TDataSet);
    procedure ttConfigBeforeInsert(DataSet: TDataSet);
    procedure ttConfigBeforeDelete(DataSet: TDataSet);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure ttMandatorAfterScroll(DataSet: TDataSet);
    procedure ttTextBackupAfterScroll(DataSet: TDataSet);
    procedure ttConfigAfterScroll(DataSet: TDataSet);
    procedure ttTextBackupBeforeDelete(DataSet: TDataSet);
    procedure ttMandatorBeforeDelete(DataSet: TDataSet);
    procedure dbgMandatorTitleClick(Column: TColumn);
    procedure dbgTextBackupTitleClick(Column: TColumn);
    procedure dbgConfigTitleClick(Column: TColumn);
    procedure csvMandatorClick(Sender: TObject);
    procedure csvTextBackupClick(Sender: TObject);
    procedure csvConfigClick(Sender: TObject);
    procedure refreshMandatorClick(Sender: TObject);
    procedure refreshTextBackupClick(Sender: TObject);
    procedure refreshConfigClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure ttConfigBeforeEdit(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure dbgMandatorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgTextBackupKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgConfigKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ttConfigBeforePost(DataSet: TDataSet);
    procedure dbgMandatorDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ttMandatorBeforeEdit(DataSet: TDataSet);
    procedure dbgTextBackupDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure dbgConfigDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure Timer2Timer(Sender: TObject);
    procedure ttTextBackupBeforePost(DataSet: TDataSet);
    procedure ttMandatorBeforePost(DataSet: TDataSet);
    procedure openMandatorClick(Sender: TObject);
  private
    Edit1Sav: TStringList;
    SqlQueryMandator_Init: boolean;
    SqlQueryMandator_Order: string;
    SqlQueryMandator_Asc: boolean;
    SqlQueryTextBackup_Init: boolean;
    SqlQueryTextBackup_Order: string;
    SqlQueryTextBackup_Asc: boolean;
    SqlQueryConfig_Init: boolean;
    SqlQueryConfig_Order: string;
    SqlQueryConfig_Asc: boolean;
    function SqlQueryMandator(const search: string): string;
    function SqlQueryTextBackup(const search: string): string;
    function SqlQueryConfig(const search: string): string;
  public
    procedure Init;
  end;

implementation

{$R *.dfm}

uses
  CmDbMain, Mandator, DbGridHelper, CmDbFunctions, AdoConnHelper;

procedure TMandatorsForm.ttConfigAfterScroll(DataSet: TDataSet);
begin
  sbConfig.Caption := CmDb_ShowRows(DataSet);
end;

procedure TMandatorsForm.ttConfigBeforeDelete(DataSet: TDataSet);
resourcestring
  SDeleteNotPossible = 'Delete not possible';
  SPasswordProtectionDisabled = 'Password protection disabled';
  SNoPasswordToRemove = 'Nothing to remove. Database is not password protected.';
  SReallyUnsetPassword = 'Do you really want to disable password protection?';
begin
  if (ttConfigNAME.AsWideString = 'NEW_PASSWORD') then
  begin
    if VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''PASSWORD_HASHED'';')) = '' then
    begin
      MessageBox(Application.Handle, PChar(SNoPasswordToRemove), PChar(Application.Title), MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    end
    else
    begin
      if MessageBox(Application.Handle, PChar(SReallyUnsetPassword), PChar(Application.Title), MB_YESNOCANCEL or MB_ICONQUESTION or MB_TASKMODAL) <> ID_YES then Abort;
      ADOConnection1.ExecSQL('update CONFIG set VALUE = '''' where NAME = ''PASSWORD_HASHED'';');
      MainForm.CmDbZipPassword := '';
      MessageBox(Application.Handle, PChar(SPasswordProtectionDisabled), PChar(Application.Title), MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
    end;
  end;
  Abort;
end;

procedure TMandatorsForm.ttConfigBeforeInsert(DataSet: TDataSet);
begin
  Abort;
end;

procedure TMandatorsForm.ttConfigBeforePost(DataSet: TDataSet);
var
  oldHashed: string;
resourcestring
  SInvalidCurrency = 'Invalid currency code. Please enter a valid 3-character code, e.g. USD.';
  SPasswordProtectionEnabled = 'Password protection enabled';
  SPasswordChanged = 'Password changed';
  SDirectoryDoesNotExist = 'Directory does not exist! Please enter a valid directory, or leave the value blank for the user directory.';
begin
  DataSet.FieldByName('VALUE').AsWideString := Trim(DataSet.FieldByName('VALUE').AsWideString);

  if (ttConfigNAME.AsWideString = 'BACKUP_PATH') then
  begin
    if (ttConfigVALUE.AsWideString <> '') and not DirectoryExists(ttConfigVALUE.AsWideString) then
    begin
      raise Exception.Create(SDirectoryDoesNotExist);
    end;
  end
  else if (ttConfigNAME.AsWideString = 'LOCAL_CURRENCY') then
  begin
    if Length(ttConfigVALUE.AsWideString) <> 3 then
      raise Exception.Create(SInvalidCurrency)
    else
      ttConfigVALUE.AsWideString := ttConfigVALUE.AsWideString.ToUpper;
  end
  else if (ttConfigNAME.AsWideString = 'NEW_PASSWORD') and (ttConfigVALUE.AsWideString <> '') then
  begin
    oldHashed := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''PASSWORD_HASHED'';'));
    ADOConnection1.ExecSQL('update CONFIG set VALUE = '+ADOConnection1.SQLStringEscape(CmDb_GetPasswordHash(AdoConnection1, ttConfigVALUE.AsWideString))+' where NAME = ''PASSWORD_HASHED'';');
    if oldHashed = '' then
      MessageBox(Application.Handle, PChar(SPasswordProtectionEnabled), PChar(Application.Title), MB_OK or MB_ICONINFORMATION or MB_TASKMODAL)
    else
      MessageBox(Application.Handle, PChar(SPasswordChanged), PChar(Application.Title), MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
    MainForm.CmDbZipPassword := ttConfigVALUE.AsWideString;
    ttConfigVALUE.AsWideString := '';
  end;
end;

procedure TMandatorsForm.ttMandatorAfterScroll(DataSet: TDataSet);
begin
  sbMandator.Caption := CmDb_ShowRows(DataSet);
end;

procedure TMandatorsForm.ttMandatorBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeDelete(Dataset as TAdoQuery, 'ID', 'MANDATOR', 'ID');
end;

procedure TMandatorsForm.ttMandatorBeforeEdit(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeEdit(Dataset as TAdoQuery, 'ID');
end;

procedure TMandatorsForm.ttMandatorBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('NAME').AsWideString := Trim(DataSet.FieldByName('NAME').AsWideString);
end;

procedure TMandatorsForm.ttMandatorNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := TGUID.NewGuid;
end;

procedure TMandatorsForm.ttTextBackupAfterScroll(DataSet: TDataSet);
begin
  sbTextBackup.Caption := CmDb_ShowRows(DataSet);
end;

procedure TMandatorsForm.ttTextBackupBeforeDelete(DataSet: TDataSet);
begin
  Abort;
end;

procedure TMandatorsForm.ttTextBackupBeforeInsert(DataSet: TDataSet);
begin
  Abort;
end;

procedure TMandatorsForm.ttTextBackupBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('ANNOTATION').AsWideString := Trim(DataSet.FieldByName('ANNOTATION').AsWideString);
end;

procedure TMandatorsForm.SearchBtnClick(Sender: TObject);
begin
  if Edit1.Text <> '' then
    Edit1.Clear;
end;

procedure TMandatorsForm.HelpBtnClick(Sender: TObject);
begin
  MainForm.ShowHelpWindow('HELP_DatabaseWindow.md');
end;

procedure TMandatorsForm.csvConfigClick(Sender: TObject);
begin
  if sdCsvConfig.Execute then
    SaveGridToCsv(dbgConfig, sdCsvConfig.FileName);
end;

procedure TMandatorsForm.csvMandatorClick(Sender: TObject);
begin
  if sdCsvMandator.Execute then
    SaveGridToCsv(dbgMandator, sdCsvMandator.FileName);
end;

procedure TMandatorsForm.csvTextBackupClick(Sender: TObject);
begin
  if sdCsvTextBackup.Execute then
    SaveGridToCsv(dbgTextBackup, sdCsvTextBackup.FileName);
end;

procedure TMandatorsForm.dbgConfigDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'NAME');
end;

procedure TMandatorsForm.dbgConfigKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    Screen.Cursor := crHourGlass;
    try
      AdoQueryRefresh(TDbGrid(Sender).DataSource.DataSet as TAdoQuery, 'NAME');
      TDbGrid(Sender).AutoSizeColumns;
    finally
      Screen.Cursor := crDefault;
    end;
    Key := 0;
  end;
end;

procedure TMandatorsForm.dbgConfigTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryConfig_Order := Column.FieldName;
    SqlQueryConfig_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryConfig(Edit1.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorsForm.dbgMandatorDblClick(Sender: TObject);
begin
  if ttMandator.State in [dsEdit,dsInsert] then ttMandator.Post;
  if ttMandator.FieldByName('ID').IsNull then exit;
  MainForm.OpenDbObject('MANDATOR', ttMandator.FieldByName('ID').AsGuid);
end;

procedure TMandatorsForm.dbgMandatorDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'ID');
end;

procedure TMandatorsForm.dbgMandatorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    Screen.Cursor := crHourGlass;
    try
      AdoQueryRefresh(TDbGrid(Sender).DataSource.DataSet as TAdoQuery, 'ID');
      TDbGrid(Sender).AutoSizeColumns;
    finally
      Screen.Cursor := crDefault;
    end;
    Key := 0;
  end;
end;

procedure TMandatorsForm.dbgMandatorTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryMandator_Order := Column.FieldName;
    SqlQueryMandator_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryMandator(Edit1.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorsForm.dbgTextBackupDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'BAK_ID');
end;

procedure TMandatorsForm.dbgTextBackupKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    Screen.Cursor := crHourGlass;
    try
      AdoQueryRefresh(TDbGrid(Sender).DataSource.DataSet as TAdoQuery, 'BAK_ID');
      TDbGrid(Sender).AutoSizeColumns;
    finally
      Screen.Cursor := crDefault;
    end;
    Key := 0;
  end;
end;

procedure TMandatorsForm.dbgTextBackupTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryTextBackup_Order := Column.FieldName;
    SqlQueryTextBackup_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryTextBackup(Edit1.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorsForm.PageControl1Change(Sender: TObject);
begin
  if Assigned(Edit1Sav) then
    Edit1.Text := Edit1Sav.Values[TPageControl(Sender).ActivePage.Name]
  else
    Edit1.Text := '';
  Timer1.Enabled := False;
end;

procedure TMandatorsForm.refreshConfigClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    AdoQueryRefresh(ttConfig, 'NAME');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorsForm.refreshMandatorClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    AdoQueryRefresh(ttMandator, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorsForm.refreshTextBackupClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    AdoQueryRefresh(ttTextBackup, 'BAK_ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TMandatorsForm.SqlQueryMandator(const search: string): string;
begin
  if not SqlQueryMandator_Init then
  begin
    SqlQueryMandator_Init := true;
    SqlQueryMandator_order := 'NAME';
    SqlQueryMandator_asc := true;
  end;
  result := 'select * from vw_MANDATOR ';
  if trim(search)<>'' then
    result := result + 'where lower(NAME) like ''%'+StringReplace(AnsiLowerCase(trim(search)), '''', '`', [rfReplaceAll])+'%'' ';
  result := result + 'order by ' + SqlQueryMandator_order + ' ' + AscDesc(SqlQueryMandator_asc);
end;

function TMandatorsForm.SqlQueryTextBackup(const search: string): string;
begin
  if not SqlQueryTextBackup_Init then
  begin
    SqlQueryTextBackup_Init := true;
    SqlQueryTextBackup_order := 'BAK_ID';
    SqlQueryTextBackup_asc := true;
  end;
  result := 'select BAK_ID, BAK_DATE, BAK_LINES, ANNOTATION, CHECKSUM from vw_BACKUP ';
  if trim(search)<>'' then
    result := result + 'where lower(ANNOTATION) like ''%'+StringReplace(AnsiLowerCase(trim(search)), '''', '`', [rfReplaceAll])+'%'' ';
  result := result + 'order by ' + SqlQueryTextBackup_order + ' ' + AscDesc(SqlQueryTextBackup_asc);
end;

procedure TMandatorsForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  if Assigned(Edit1Sav) then
  begin
    Edit1Sav.Values[PageControl1.ActivePage.Name] := Edit1.Text;
  end;
  if PageControl1.ActivePage = tsMandator then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttMandator.Active := false;
      ttMandator.SQL.Text := SqlQueryMandator(Edit1.Text);
      ttMandator.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
  if PageControl1.ActivePage = tsTextDumps then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttTextBackup.Active := false;
      ttTextBackup.SQL.Text := SqlQueryTextBackup(Edit1.Text);
      ttTextBackup.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
  if PageControl1.ActivePage = tsConfig then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttConfig.Active := false;
      ttConfig.SQL.Text := SqlQueryConfig(Edit1.Text);
      ttConfig.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TMandatorsForm.Timer2Timer(Sender: TObject);
begin
  // https://stackoverflow.com/questions/54401270/when-i-perform-the-ondblclick-event-form1-to-open-form2-it-fires-the-oncellcl
  Timer2.Enabled := false;
  dbgMandator.Enabled := true;
  dbgMandator.Invalidate;
end;

function TMandatorsForm.SqlQueryConfig(const search: string): string;
begin
  if not SqlQueryConfig_Init then
  begin
    SqlQueryConfig_Init := true;
    SqlQueryConfig_order := 'NAME';
    SqlQueryConfig_asc := true;
  end;
  result := 'select * from vw_CONFIG ';
  if trim(search)<>'' then
    result := result + 'where lower(NAME) like ''%'+StringReplace(AnsiLowerCase(trim(search)), '''', '`', [rfReplaceAll])+'%'' ';
  result := result + 'order by ' + SqlQueryConfig_order + ' ' + AscDesc(SqlQueryConfig_asc);
end;

procedure TMandatorsForm.Edit1Change(Sender: TObject);
begin
  Timer1.Enabled := false;
  Timer1.Enabled := true;
end;

procedure TMandatorsForm.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    if Timer1.Enabled then
    begin
      Timer1.Enabled := false;
      Timer1Timer(Timer1);
    end;
  end;

  if Key = VK_LEFT then
  begin
    Key := 0;
    PageControl1.ActivePageIndex := (PageControl1.ActivePageIndex - 1) mod PageControl1.PageCount;
  end
  else if Key = VK_RIGHT then
  begin
    Key := 0;
    PageControl1.ActivePageIndex := (PageControl1.ActivePageIndex + 1) mod PageControl1.PageCount;
  end
  else if PageControl1.ActivePage = tsMandator then
  begin
    dbgMandator.HandleOtherControlKeyDown(Key, Shift);
  end
  else if PageControl1.ActivePage = tsTextDumps then
  begin
    dbgTextBackup.HandleOtherControlKeyDown(Key, Shift);
  end
  else if PageControl1.ActivePage = tsConfig then
  begin
    dbgConfig.HandleOtherControlKeyDown(Key, Shift);
  end;
end;

procedure TMandatorsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMandatorsForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (ttMandator.State=dsEdit) or ((ttMandator.State=dsInsert) and (ttMandatorNAME.AsWideString<>'')) then
    ttMandator.Post;
  if (ttTextBackup.State=dsEdit) then
    ttTextBackup.Post;
  if (ttConfig.State=dsEdit) then
    ttConfig.Post;
end;

procedure TMandatorsForm.FormCreate(Sender: TObject);
begin
  Edit1Sav := TStringList.Create;
  PageControl1.ActivePageIndex := 0;
end;

procedure TMandatorsForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Edit1Sav);
end;

procedure TMandatorsForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // We must use FormKeyDown AND FormKeyUp. Why?
  // If we only use FormKeyDown only, then ESC will not only close this window, but also windows below (even if Key:=0 will be performed)
  // If we only use FormKeyUp, we don't get the correct dataset state (since dsEdit,dsInsert got reverted during KeyDown)
  if (Key = VK_ESCAPE) and
    not (ttMandator.State in [dsEdit,dsInsert]) and
    not (ttTextBackup.State in [dsEdit,dsInsert]) and
    not (ttConfig.State in [dsEdit,dsInsert]) then
  begin
    Tag := 1; // tell FormKeyUp that we may close
    Key := 0;
  end;
end;

procedure TMandatorsForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Tag = 1) then
  begin
    Close;
    Key := 0;
  end;
end;

procedure TMandatorsForm.Init;
begin
  // We cannot use OnShow(), because TForm.Create() calls OnShow(), even if Visible=False
  Panel1.Caption := StringReplace(Caption, '&', '&&', [rfReplaceAll]);
  if not CmDb_DatabasePasswordcheck(AdoConnection1) then
  begin
    Close;
    Exit;
  end;
  MainForm.DatabaseOpenedOnce := true;
  Screen.Cursor := crHourGlass;
  try
    {$REGION 'ttMandator / dbgMandator'}
    ttMandator.Active := false;
    ttMandator.SQL.Text := SqlQueryMandator('');
    ttMandator.Active := true;
    dbgMandator.AutoSizeColumns;
    InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbgMandator, navMandator);
    {$ENDREGION}
    {$REGION 'ttTextBackup / dbgTextBackup'}
    ttTextBackup.Active := false;
    ttTextBackup.SQL.Text := SqlQueryTextBackup('');
    ttTextBackup.Active := true;
    ttTextBackup.Last;
    dbgTextBackup.AutoSizeColumns;
    {$ENDREGION}
    {$REGION 'ttConfig / dbgConfig'}
    ttConfig.Active := false;
    ttConfig.SQL.Text := SqlQueryConfig('');
    ttConfig.Active := true;
    dbgConfig.AutoSizeColumns;
    {$ENDREGION}
  finally
    Screen.Cursor := crDefault;
  end;

  // https://stackoverflow.com/questions/54401270/when-i-perform-the-ondblclick-event-form1-to-open-form2-it-fires-the-oncellcl
  dbgMandator.Enabled := false;
  Timer2.Enabled := true;
end;

procedure TMandatorsForm.openMandatorClick(Sender: TObject);
begin
  dbgMandatorDblClick(dbgMandator);
end;

procedure TMandatorsForm.ttConfigBeforeEdit(DataSet: TDataSet);
begin
  if ttConfigREAD_ONLY.AsBoolean then Abort; // Note: Unfortunately, we probably cannot make this cell cream colored!
end;

end.
