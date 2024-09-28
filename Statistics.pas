unit Statistics;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls, Data.Win.ADODB,
  Vcl.StdCtrls, AdoConnHelper;

type
  TStatisticsForm = class(TForm)
    PageControl1: TPageControl;
    tsQuery: TTabSheet;
    dbgQuery: TDBGrid;
    navQuery: TDBNavigator;
    ADOConnection1: TADOConnection;
    ttQuery: TADOQuery;
    dsQuery: TDataSource;
    Panel1: TPanel;
    Edit1: TEdit;
    SearchBtn: TButton;
    Timer1: TTimer;
    sbQuery: TPanel;
    csvQuery: TButton;
    sdCsvQuery: TSaveDialog;
    refreshQuery: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit1Change(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchBtnClick(Sender: TObject);
    procedure dbgQueryDblClick(Sender: TObject);
    procedure ttQueryBeforeInsert(DataSet: TDataSet);
    procedure ttQueryBeforeDelete(DataSet: TDataSet);
    procedure ttQueryBeforeEdit(DataSet: TDataSet);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure ttQueryAfterScroll(DataSet: TDataSet);
    procedure dbgQueryTitleClick(Column: TColumn);
    procedure csvQueryClick(Sender: TObject);
    procedure refreshQueryClick(Sender: TObject);
  private
    SqlQueryStatistics_Init: boolean;
    SqlQueryStatistics_Order: string;
    SqlQueryStatistics_Asc: boolean;
    function SqlQueryStatistics(const search: string): string;
  protected
    MandatorName: string;
  public
    StatisticsId: TGUID;
    StatisticsName: string;
    MandatorId: TGUID;
    SqlTable: string;
    SqlInitialOrder: string;
    SqlAdditionalFilter: string;
    BaseTableDelete: string;
    class function AddInfo(mandatorId: TGUID; sqlTable, sqlInitialOrder, sqlAdditionalFilter: string): string;
    procedure Init;
  end;

implementation

{$R *.dfm}

uses
  DbGridHelper, CmDbFunctions, CmDbPluginClient, CmDbMain;

procedure TStatisticsForm.SearchBtnClick(Sender: TObject);
begin
  if Edit1.Text <> '' then
    Edit1.Clear;
end;

procedure TStatisticsForm.PageControl1Change(Sender: TObject);
begin
  if Edit1.Text <> '' then
  begin
    Edit1.Clear;
    Timer1.Enabled := false;
  end;
end;

procedure TStatisticsForm.refreshQueryClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    AdoQueryRefresh(ttQuery, '');
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TStatisticsForm.SqlQueryStatistics(const search: string): string;
var
  q: TAdoDataSet;
begin
  if not SqlQueryStatistics_Init then
  begin
    SqlQueryStatistics_Init := true;
    SqlQueryStatistics_order := '';
    SqlQueryStatistics_asc := true;
  end;
  result := 'select * ';
  result := result + 'from ' + ADOConnection1.SQLObjectNameEscape(SqlTable) + ' ';
  result := result + 'where 1=1 ';
  if SqlAdditionalFilter <> '' then
    result := result + 'and (' + SqlAdditionalFilter + ') ';
  if trim(search)<>'' then
  begin
    result := result + ' and (1=0 ';
    q := AdoConnection1.GetTable('select COLUMN_NAME ' +
                                 'from INFORMATION_SCHEMA.COLUMNS ' +
                                 'where TABLE_NAME = '+ADOConnection1.SQLStringEscape(SqlTable)+' ' +
                                 //'and TABLE_SCHEMA = ''dbo'' ' +
                                 'and COLUMN_NAME not like ''\_\_%'' escape ''\'';');
    while not q.EOF do
    begin
      result := result + 'or ' + ADOConnection1.SQLFieldNameEscape(q.Fields[0].AsWideString) + ' like ' + AdoConnection1.SQLStringEscape('%'+search+'%');
      q.Next;
    end;
    q.Free;
    result := result + ') ';
  end;
  if (SqlQueryStatistics_order = '') and (SqlInitialOrder <> '') then
    result := result + 'order by ' + SqlInitialOrder // {No, because the DB might have asc/desc:} + ' ' + AscDesc(SqlQueryStatistics_asc)
  else if (SqlQueryStatistics_order = '') and (SqlInitialOrder = '') then
    result := result + ''
  else
    result := result + 'order by ' + SqlQueryStatistics_order + ' ' + AscDesc(SqlQueryStatistics_asc);
end;

procedure TStatisticsForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  if PageControl1.ActivePage = tsQuery then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttQuery.Active := false;
      ttQuery.SQL.Text := SqlQueryStatistics(Edit1.Text);
      ttQuery.Active := true;
      dbgQuery.HideColumnPrefix('__');
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TStatisticsForm.ttQueryAfterScroll(DataSet: TDataSet);
begin
  sbQuery.Caption := CmDbShowRows(DataSet);
end;

procedure TStatisticsForm.ttQueryBeforeDelete(DataSet: TDataSet);
resourcestring
  SDeleteNotPossible = 'Delete not possible';
begin
  if BaseTableDelete <> '' then
    InsteadOfDeleteWorkaround(ttQuery, '__ID', BaseTableDelete, 'ID')
  else
    raise Exception.Create(SDeleteNotPossible);
end;

procedure TStatisticsForm.ttQueryBeforeEdit(DataSet: TDataSet);
begin
  Abort;
end;

procedure TStatisticsForm.ttQueryBeforeInsert(DataSet: TDataSet);
begin
  Abort;
end;

class function TStatisticsForm.AddInfo(mandatorId: TGUID; sqlTable,
  sqlInitialOrder, sqlAdditionalFilter: string): string;
begin
  result := mandatorId.ToString + '/' + sqlTable + '/' + sqlInitialOrder + '/' + sqlAdditionalFilter;
end;

procedure TStatisticsForm.csvQueryClick(Sender: TObject);
begin
  if sdCsvQuery.Execute then
    SaveGridToCsv(dbgQuery, sdCsvQuery.FileName);
end;

procedure TStatisticsForm.dbgQueryDblClick(Sender: TObject);
var
  resp: TCmDbPluginClickResponse;
begin
  if ttQuery.FindField('__ID') <> nil then
  begin
    resp := TCmDbPluginClient.ClickEvent(ADOConnection1, MandatorId, StatisticsId, ttQuery.FieldByName('__ID').AsGuid);
    HandleClickResponse(AdoConnection1, MandatorId, resp);
  end;
end;

procedure TStatisticsForm.dbgQueryTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryStatistics_Order := Column.FieldName;
    SqlQueryStatistics_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryStatistics(Edit1.Text);
    ds.Active := true;
    TDbGrid(Column.Grid).HideColumnPrefix('__');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TStatisticsForm.Edit1Change(Sender: TObject);
begin
  Timer1.Enabled := false;
  Timer1.Enabled := true;
end;

procedure TStatisticsForm.Edit1KeyDown(Sender: TObject; var Key: Word;
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
  else if PageControl1.ActivePage = tsQuery then
  begin
    dbgQuery.HandleOtherControlKeyDown(Key, Shift);
  end;
end;

procedure TStatisticsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TStatisticsForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ttQuery.State in [dsEdit,dsInsert] then ttQuery.Post;
end;

procedure TStatisticsForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // We must use FormKeyDown AND FormKeyUp. Why?
  // If we only use FormKeyDown only, then ESC will not only close this window, but also windows below (even if Key:=0 will be performed)
  // If we only use FormKeyUp, we don't get the correct dataset state (since dsEdit,dsInsert got reverted during KeyDown)
  if (Key = VK_ESCAPE) and not (ttQuery.State in [dsEdit,dsInsert]) then
  begin
    Tag := 1; // tell FormKeyUp that we may close
    Key := 0;
  end;
end;

procedure TStatisticsForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Tag = 1) then
  begin
    Close;
    Key := 0;
  end;
end;

procedure TStatisticsForm.Init;
var
  ttMandator: TAdoDataSet;
resourcestring
  SSForS = '%s for %s';
begin
  ttMandator := ADOConnection1.GetTable('select NAME from MANDATOR where ID = ''' + MandatorId.ToString + '''');;
  try
    MandatorName := ttMandator.FieldByName('NAME').AsWideString;
    Caption := Format(SSForS, [StatisticsName, MandatorName]);
  finally
    FreeAndNil(ttMandator);
  end;

  if BaseTableDelete = '' then
  begin
    navQuery.VisibleButtons := navQuery.VisibleButtons - [nbDelete];
    dbgQuery.Options :=dbgQuery.Options - [dgConfirmDelete];
  end;

  // We cannot use OnShow(), because TForm.Create() calls OnShow(), even if Visible=False
  PageControl1.ActivePageIndex := 0;
  Panel1.Caption := Caption;
  Screen.Cursor := crHourGlass;
  try
    {$REGION 'ttQuery / dbgQuery'}
    ttQuery.Active := false;
    ttQuery.SQL.Text := SqlQueryStatistics('');
    ttQuery.Active := true;
    dbgQuery.Columns.RebuildColumns; // otherwise column colors won't work!
    dbgQuery.HideColumnPrefix('__');
    dbgQuery.AutoSizeColumns;
    {$ENDREGION}
  finally
    Screen.Cursor := crDefault;
  end;
end;

end.
