unit Database;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Data.Win.ADODB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.Buttons, Vcl.DBCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls;

type
  TDatabaseForm = class(TForm)
    dbgMandator: TDBGrid;
    dsMandator: TDataSource;
    ADOConnection1: TADOConnection;
    ttMandator: TADOQuery;
    navMandator: TDBNavigator;
    PageControl1: TPageControl;
    tsMandator: TTabSheet;
    HeadPanel: TPanel;
    ttMandatorID: TGuidField;
    ttMandatorNAME: TWideStringField;
    SearchEdit: TEdit;
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
    TitlePanel: TPanel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgMandatorDblClick(Sender: TObject);
    procedure ttMandatorNewRecord(DataSet: TDataSet);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SearchEditChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure SearchEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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
    procedure navMandatorClick(Sender: TObject; Button: TNavigateBtn);
    procedure SearchEditKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    SearchEditSav: TStringList;
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
    procedure DoRefresh(dbg: TDbGrid; const ALocateField: string);
  public
    procedure Init;
  end;

implementation

{$R *.dfm}

uses
  CmDbMain, Mandator, DbGridHelper, CmDbFunctions, AdoConnHelper;

procedure TDatabaseForm.ttConfigAfterScroll(DataSet: TDataSet);
begin
  sbConfig.Caption := CmDb_ShowRows(DataSet)+'   ';
end;

procedure TDatabaseForm.ttConfigBeforeDelete(DataSet: TDataSet);
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

procedure TDatabaseForm.ttConfigBeforeInsert(DataSet: TDataSet);
begin
  Abort;
end;

procedure TDatabaseForm.ttConfigBeforePost(DataSet: TDataSet);
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

procedure TDatabaseForm.ttMandatorAfterScroll(DataSet: TDataSet);
begin
  sbMandator.Caption := CmDb_ShowRows(DataSet)+'   ';
end;

procedure TDatabaseForm.ttMandatorBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeDelete(Dataset as TAdoQuery, 'ID', 'MANDATOR', 'ID');
end;

procedure TDatabaseForm.ttMandatorBeforeEdit(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeEdit(Dataset as TAdoQuery, 'ID');
end;

procedure TDatabaseForm.ttMandatorBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('NAME').AsWideString := Trim(DataSet.FieldByName('NAME').AsWideString);
end;

procedure TDatabaseForm.ttMandatorNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := ADOConnection1.NewSeqGuid;
end;

procedure TDatabaseForm.ttTextBackupAfterScroll(DataSet: TDataSet);
begin
  sbTextBackup.Caption := CmDb_ShowRows(DataSet)+'   ';
end;

procedure TDatabaseForm.ttTextBackupBeforeDelete(DataSet: TDataSet);
begin
  Abort;
end;

procedure TDatabaseForm.ttTextBackupBeforeInsert(DataSet: TDataSet);
begin
  Abort;
end;

procedure TDatabaseForm.ttTextBackupBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('ANNOTATION').AsWideString := Trim(DataSet.FieldByName('ANNOTATION').AsWideString);
end;

procedure TDatabaseForm.SearchBtnClick(Sender: TObject);
begin
  if SearchEdit.Text <> '' then
    SearchEdit.Clear;
  if SearchEdit.CanFocus then
    SearchEdit.SetFocus;
end;

procedure TDatabaseForm.HelpBtnClick(Sender: TObject);
begin
  MainForm.ShowHelpWindow('HELP_DatabaseWindow.md');
end;

procedure TDatabaseForm.csvConfigClick(Sender: TObject);
begin
  if sdCsvConfig.Execute then
    SaveGridToCsv(dbgConfig, sdCsvConfig.FileName);
end;

procedure TDatabaseForm.csvMandatorClick(Sender: TObject);
begin
  if sdCsvMandator.Execute then
    SaveGridToCsv(dbgMandator, sdCsvMandator.FileName);
end;

procedure TDatabaseForm.csvTextBackupClick(Sender: TObject);
begin
  if sdCsvTextBackup.Execute then
    SaveGridToCsv(dbgTextBackup, sdCsvTextBackup.FileName);
end;

procedure TDatabaseForm.dbgConfigDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'NAME');
end;

procedure TDatabaseForm.dbgConfigKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F5) and (Shift = []) then
  begin
    Key := 0;
    Screen.Cursor := crHourGlass;
    try
      DoRefresh(dbgConfig, 'NAME');
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TDatabaseForm.dbgConfigTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryConfig_Order := Column.FieldName;
    SqlQueryConfig_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryConfig(SearchEdit.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TDatabaseForm.dbgMandatorDblClick(Sender: TObject);
begin
  if ttMandator.State in [dsEdit,dsInsert] then ttMandator.Post;
  if ttMandator.FieldByName('ID').IsNull then begin Beep; Exit; end;
  MainForm.OpenDbObject('MANDATOR', ttMandator.FieldByName('ID').AsGuid);
end;

procedure TDatabaseForm.dbgMandatorDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'ID');
end;

procedure TDatabaseForm.dbgMandatorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F5) and (Shift = []) then
  begin
    Key := 0;
    Screen.Cursor := crHourGlass;
    try
      DoRefresh(dbgMandator, 'ID');
    finally
      Screen.Cursor := crDefault;
    end;
  end
  else if (Key = VK_INSERT) and (Shift = []) then
  begin
    Key := 0;
    TDbGrid(Sender).DataSource.DataSet.Append;
  end;
end;

procedure TDatabaseForm.dbgMandatorTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryMandator_Order := Column.FieldName;
    SqlQueryMandator_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryMandator(SearchEdit.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TDatabaseForm.dbgTextBackupDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'BAK_ID');
end;

procedure TDatabaseForm.DoRefresh(dbg: TDbGrid; const ALocateField: string);
begin
  AdoQueryRefresh(dbg.DataSource.DataSet as TAdoQuery, ALocateField);
  dbg.AutoSizeColumns;
end;

procedure TDatabaseForm.dbgTextBackupKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F5) and (Shift = []) then
  begin
    Key := 0;
    Screen.Cursor := crHourGlass;
    try
      DoRefresh(dbgTextBackup, 'BAK_ID');
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TDatabaseForm.dbgTextBackupTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryTextBackup_Order := Column.FieldName;
    SqlQueryTextBackup_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryTextBackup(SearchEdit.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TDatabaseForm.PageControl1Change(Sender: TObject);
begin
  if Assigned(SearchEditSav) then
    SearchEdit.Text := SearchEditSav.Values[TPageControl(Sender).ActivePage.Name]
  else
    SearchEdit.Text := '';
  Timer1.Enabled := False;
end;

procedure TDatabaseForm.refreshConfigClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    DoRefresh(dbgConfig, 'NAME');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TDatabaseForm.refreshMandatorClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    DoRefresh(dbgMandator, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TDatabaseForm.refreshTextBackupClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    DoRefresh(dbgTextBackup, 'BAK_ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TDatabaseForm.SqlQueryMandator(const search: string): string;
begin
  if not SqlQueryMandator_Init then
  begin
    SqlQueryMandator_Init := true;
    SqlQueryMandator_order := 'NAME';
    SqlQueryMandator_asc := true;
  end;
  result := 'select * from vw_MANDATOR ';
  if Trim(search) <> '' then
    result := result + 'where ' + BuildSearchCondition(search, dbgMandator);
  result := result + 'order by ' + SqlQueryMandator_order + ' ' + AscDesc(SqlQueryMandator_asc);
end;

function TDatabaseForm.SqlQueryTextBackup(const search: string): string;
begin
  if not SqlQueryTextBackup_Init then
  begin
    SqlQueryTextBackup_Init := true;
    SqlQueryTextBackup_order := 'BAK_ID';
    SqlQueryTextBackup_asc := true;
  end;
  result := 'select BAK_ID, BAK_DATE, BAK_LINES, ANNOTATION, CHECKSUM from vw_BACKUP ';
  if Trim(search) <> '' then
    result := result + 'where ' + BuildSearchCondition(search, dbgTextBackup);
  result := result + 'order by ' + SqlQueryTextBackup_order + ' ' + AscDesc(SqlQueryTextBackup_asc);
end;

procedure TDatabaseForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  if Assigned(SearchEditSav) then
  begin
    SearchEditSav.Values[PageControl1.ActivePage.Name] := SearchEdit.Text;
  end;
  if PageControl1.ActivePage = tsMandator then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttMandator.Active := false;
      ttMandator.SQL.Text := SqlQueryMandator(SearchEdit.Text);
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
      ttTextBackup.SQL.Text := SqlQueryTextBackup(SearchEdit.Text);
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
      ttConfig.SQL.Text := SqlQueryConfig(SearchEdit.Text);
      ttConfig.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TDatabaseForm.Timer2Timer(Sender: TObject);
begin
  // https://stackoverflow.com/questions/54401270/when-i-perform-the-ondblclick-event-form1-to-open-form2-it-fires-the-oncellcl
  Timer2.Enabled := false;
  dbgMandator.Enabled := true;
  dbgMandator.Invalidate;
end;

function TDatabaseForm.SqlQueryConfig(const search: string): string;
begin
  if not SqlQueryConfig_Init then
  begin
    SqlQueryConfig_Init := true;
    SqlQueryConfig_order := 'NAME';
    SqlQueryConfig_asc := true;
  end;
  result := 'select * from vw_CONFIG ';
  if Trim(search) <> '' then
    result := result + 'where ' + BuildSearchCondition(search, dbgConfig);
  result := result + 'order by ' + SqlQueryConfig_order + ' ' + AscDesc(SqlQueryConfig_asc);
end;

procedure TDatabaseForm.SearchEditChange(Sender: TObject);
begin
  Timer1.Enabled := false;
  Timer1.Enabled := true;
end;

procedure TDatabaseForm.SearchEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Shift = []) then
  begin
    // DO NOT Key := 0;
    if Timer1.Enabled then
    begin
      Timer1.Enabled := false;
      Timer1Timer(Timer1);
    end;
  end; // DO NOT "else"

  if (Key = VK_LEFT) and (Shift = []) then
  begin
    Key := 0;
    PageControl1.ActivePageIndex := (PageControl1.ActivePageIndex - 1) mod PageControl1.PageCount;
  end
  else if (Key = VK_RIGHT) and (Shift = []) then
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
  if Key = 0 then SearchEdit.Tag := 1; // avoid "Ding" sound
end;

procedure TDatabaseForm.SearchEditKeyPress(Sender: TObject; var Key: Char);
begin
  if SearchEdit.Tag = 1 then
  begin
    Key := #0; // avoid "Ding" sound
    SearchEdit.Tag := 0;
  end;
end;

procedure TDatabaseForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TDatabaseForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (ttMandator.State=dsEdit) or ((ttMandator.State=dsInsert) and (ttMandatorNAME.AsWideString<>'')) then
    ttMandator.Post;
  if (ttTextBackup.State=dsEdit) then
    ttTextBackup.Post;
  if (ttConfig.State=dsEdit) then
    ttConfig.Post;
end;

procedure TDatabaseForm.FormCreate(Sender: TObject);
begin
  SearchEditSav := TStringList.Create;
  PageControl1.ActivePageIndex := 0;
end;

procedure TDatabaseForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(SearchEditSav);
end;

procedure TDatabaseForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // We must use FormKeyDown AND FormKeyUp. Why?
  // If we only use FormKeyDown only, then ESC will not only close this window, but also windows below (even if Key:=0 will be performed)
  // If we only use FormKeyUp, we don't get the correct dataset state (since dsEdit,dsInsert got reverted during KeyDown)
  if (Key = VK_ESCAPE) and (Shift = []) and
    not (ttMandator.State in [dsEdit,dsInsert]) and
    not (ttTextBackup.State in [dsEdit,dsInsert]) and
    not (ttConfig.State in [dsEdit,dsInsert]) then
  begin
    Key := 0;
    Tag := 1; // tell FormKeyUp that we may close
  end;
end;

procedure TDatabaseForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Tag = 1 then
  begin
    Key := #0; // avoid "Ding" sound
  end;
end;

procedure TDatabaseForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Shift = []) and (Tag = 1) then
  begin
    Key := 0;
    Close;
  end;
  if (Key = VK_F1) and (Shift = []) then
  begin
    HelpBtn.Click;
  end;
end;

procedure TDatabaseForm.Init;
begin
  // We cannot use OnShow(), because TForm.Create() calls OnShow(), even if Visible=False
  TitlePanel.Caption := StringReplace(Caption, '&', '&&', [rfReplaceAll]);
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

procedure TDatabaseForm.navMandatorClick(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
    TDbNavigator(Sender).DataSource.DataSet.Append;
end;

procedure TDatabaseForm.openMandatorClick(Sender: TObject);
begin
  dbgMandatorDblClick(dbgMandator);
end;

procedure TDatabaseForm.ttConfigBeforeEdit(DataSet: TDataSet);
begin
  if ttConfigREAD_ONLY.AsBoolean then Abort; // Note: Unfortunately, we probably cannot make this cell cream colored!
end;

end.
