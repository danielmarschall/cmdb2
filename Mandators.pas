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
    ttTextBackupCHECKSUM: TIntegerField;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgMandatorDblClick(Sender: TObject);
    procedure ttMandatorNewRecord(DataSet: TDataSet);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Edit1Change(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchBtnClick(Sender: TObject);
    procedure ttTextBackupBeforeInsert(DataSet: TDataSet);
    procedure dbgConfigDblClick(Sender: TObject);
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
  private
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
  CmDbMain, Mandator, DbGridHelper, CmDbFunctions;

procedure TMandatorsForm.ttConfigAfterScroll(DataSet: TDataSet);
begin
  sbConfig.Caption := CmDbShowRows(DataSet);
end;

procedure TMandatorsForm.ttConfigBeforeDelete(DataSet: TDataSet);
resourcestring
  SDeleteNotPossible = 'Delete not possible';
begin
  raise Exception.Create(SDeleteNotPossible);
end;

procedure TMandatorsForm.ttConfigBeforeInsert(DataSet: TDataSet);
begin
  Abort;
end;

procedure TMandatorsForm.ttMandatorAfterScroll(DataSet: TDataSet);
begin
  sbMandator.Caption := CmDbShowRows(DataSet);
end;

procedure TMandatorsForm.ttMandatorBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround(DataSet as TAdoQuery, 'ID', 'MANDATOR', 'ID');
end;

procedure TMandatorsForm.ttMandatorNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := TGUID.NewGuid;
end;

procedure TMandatorsForm.ttTextBackupAfterScroll(DataSet: TDataSet);
begin
  sbTextBackup.Caption := CmDbShowRows(DataSet);
end;

procedure TMandatorsForm.ttTextBackupBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround(DataSet as TAdoQuery, 'BAK_ID', 'BACKUP', 'BAK_ID');
end;

procedure TMandatorsForm.ttTextBackupBeforeInsert(DataSet: TDataSet);
begin
  Abort;
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

procedure TMandatorsForm.dbgConfigDblClick(Sender: TObject);
begin
  // Nothing here
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
  if Edit1.Text <> '' then
  begin
    Edit1.Clear;
    Timer1.Enabled := false;
  end;
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
  if ttMandator.State in [dsEdit,dsInsert] then ttMandator.Post;
  if ttTextBackup.State in [dsEdit,dsInsert] then ttTextBackup.Post;
  if ttConfig.State in [dsEdit,dsInsert] then ttConfig.Post;
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
  PageControl1.ActivePageIndex := 0;
  Panel1.Caption := Caption;
  Screen.Cursor := crHourGlass;
  try
    {$REGION 'ttMandator / dbgMandator'}
    ttMandator.Active := false;
    ttMandator.SQL.Text := SqlQueryMandator('');
    ttMandator.Active := true;
    dbgMandator.AutoSizeColumns;
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
end;

procedure TMandatorsForm.ttConfigBeforeEdit(DataSet: TDataSet);
begin
  if ttConfigREAD_ONLY.AsBoolean then Abort;
end;

end.
