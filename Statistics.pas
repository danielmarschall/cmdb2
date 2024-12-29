unit Statistics;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls, Data.Win.ADODB,
  Vcl.StdCtrls, AdoConnHelper, CmDbPluginShare;

type
  TStatisticsForm = class(TForm)
    PageControl1: TPageControl;
    tsQuery: TTabSheet;
    dbgQuery: TDBGrid;
    navQuery: TDBNavigator;
    ADOConnection1: TADOConnection;
    ttQuery: TADOQuery;
    dsQuery: TDataSource;
    HeadPanel: TPanel;
    SearchEdit: TEdit;
    SearchBtn: TButton;
    Timer1: TTimer;
    sbQuery: TPanel;
    csvQuery: TButton;
    sdCsvQuery: TSaveDialog;
    refreshQuery: TBitBtn;
    GoBackBtn: TButton;
    HelpBtn: TButton;
    Timer2: TTimer;
    openQuery: TBitBtn;
    TitlePanel: TPanel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchEditChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure SearchEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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
    procedure GoBackBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure dbgQueryKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgQueryDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure Timer2Timer(Sender: TObject);
    procedure openQueryClick(Sender: TObject);
  private
    SearchEditSav: TStringList;
    SqlQueryStatistics_Init: boolean;
    SqlQueryStatistics_Order: string;
    SqlQueryStatistics_Asc: boolean;
    function SqlQueryStatistics(const search: string): string;
    procedure SetFormats;
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
    DisplayEditFormats: string;
    class function AddInfo(mandatorId: TGUID; sqlTable, sqlInitialOrder, sqlAdditionalFilter: string): string;
    procedure Init(resp: TCmDbPluginClickResponse);
  end;

implementation

{$R *.dfm}

uses
  DbGridHelper, CmDbFunctions, CmDbPluginClient, CmDbMain, Generics.Collections;

procedure TStatisticsForm.SearchBtnClick(Sender: TObject);
begin
  if SearchEdit.Text <> '' then
    SearchEdit.Clear;
end;

procedure TStatisticsForm.PageControl1Change(Sender: TObject);
begin
  if Assigned(SearchEditSav) then
    SearchEdit.Text := SearchEditSav.Values[TPageControl(Sender).ActivePage.Name]
  else
    SearchEdit.Text := '';
  Timer1.Enabled := False;
end;

procedure TStatisticsForm.refreshQueryClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    // Note: ClickEvent will be called to refresh or regenerate the data
    //       (this is important if the dataset is not a view but a table filled by the plugin).
    //       TCmDbPluginClickResponse will not be evaluated, because it should have stayed the same.
    TCmDbPluginClient.ClickEvent(ADOConnection1, MandatorId, StatisticsId, GUID_NIL);
    AdoQueryRefresh(ttQuery, '__ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TStatisticsForm.SqlQueryStatistics(const search: string): string;

  function _RemoveDuplicatesIgnoreOrderSuffix(const Input: string): string;
  var
    Words, ResultList: TArray<string>;
    SeenWords: TDictionary<string, Boolean>;
    CleanWord: string;
    i: Integer;
  begin
    // Den Eingabestring in Wörter aufteilen
    Words := Input.Split([','], TStringSplitOptions.ExcludeEmpty);

    // Ein Dictionary zur Verfolgung der bereits gesehenen "bereinigten" Wörter
    SeenWords := TDictionary<string, Boolean>.Create;

    try
      // Durch die Wörter iterieren und nur die ersten Vorkommen in die Ergebnisliste einfügen
      for i := 0 to High(Words) do
      begin
        // Bereinige das Wort, indem " ASC" und " DESC" entfernt wird
        CleanWord := Trim(Words[i]);
        if String.EndsText(' ASC', CleanWord) then
          CleanWord := CleanWord.Substring(0, CleanWord.Length - 4)
        else if String.EndsText(' DESC', CleanWord) then
          CleanWord := CleanWord.Substring(0, CleanWord.Length - 5);

        // Füge das ursprüngliche Wort hinzu, wenn es noch nicht gesehen wurde
        if not SeenWords.ContainsKey(CleanWord) then
        begin
          ResultList := ResultList + [Trim(Words[i])];
          SeenWords.Add(CleanWord, True);
        end;
      end;

      // Den neuen String aus den eindeutigen Wörtern zusammensetzen
      Result := String.Join(', ', ResultList);
    finally
      FreeAndNil(SeenWords);
    end;
  end;

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
    try
      while not q.EOF do
      begin
        result := result + 'or ' + ADOConnection1.SQLFieldNameEscape(q.Fields[0].AsWideString) + ' like ' + AdoConnection1.SQLStringEscape('%'+search+'%');
        q.Next;
      end;
    finally
      FreeAndNil(q);
    end;
    result := result + ') ';
  end;

  if (SqlQueryStatistics_order = '') and (SqlInitialOrder <> '') then
    result := result + 'order by ' + SqlInitialOrder // {No, because the DB might have asc/desc:} + ' ' + AscDesc(SqlQueryStatistics_asc)
  else if (SqlQueryStatistics_order = '') and (SqlInitialOrder = '') then
    result := result + ''
  else if (SqlQueryStatistics_order <> '') and (SqlInitialOrder <> '') then
    result := result + 'order by ' + _RemoveDuplicatesIgnoreOrderSuffix(SqlQueryStatistics_order + ' ' + AscDesc(SqlQueryStatistics_asc) + ', ' + SqlInitialOrder)
  else if (SqlQueryStatistics_order <> '') and (SqlInitialOrder = '') then
    result := result + 'order by ' + SqlQueryStatistics_order + ' ' + AscDesc(SqlQueryStatistics_asc);
end;

procedure TStatisticsForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  if Assigned(SearchEditSav) then
  begin
    SearchEditSav.Values[PageControl1.ActivePage.Name] := SearchEdit.Text;
  end;
  if PageControl1.ActivePage = tsQuery then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttQuery.Active := false;
      ttQuery.SQL.Text := SqlQueryStatistics(SearchEdit.Text);
      ttQuery.Active := true;
      dbgQuery.HideColumnPrefix('__');
      SetFormats;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TStatisticsForm.Timer2Timer(Sender: TObject);
begin
  // https://stackoverflow.com/questions/54401270/when-i-perform-the-ondblclick-event-form1-to-open-form2-it-fires-the-oncellcl
  Timer2.Enabled := false;
  dbgQuery.Enabled := true;
  dbgQuery.Invalidate;
end;

procedure TStatisticsForm.ttQueryAfterScroll(DataSet: TDataSet);
begin
  sbQuery.Caption := CmDb_ShowRows(DataSet)+'   ';
end;

procedure TStatisticsForm.ttQueryBeforeDelete(DataSet: TDataSet);
resourcestring
  SDeleteNotPossible = 'Delete not possible';
begin
  if BaseTableDelete <> '' then
    InsteadOfDeleteWorkaround_BeforeDelete(Dataset as TAdoQuery, '__ID', BaseTableDelete, 'ID')
  else
    raise Exception.Create(SDeleteNotPossible);
end;

procedure TStatisticsForm.ttQueryBeforeEdit(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeEdit(Dataset as TAdoQuery, '__ID');
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
    Screen.Cursor := crHourGlass;
    try
      resp := TCmDbPluginClient.ClickEvent(ADOConnection1, MandatorId, StatisticsId, ttQuery.FieldByName('__ID').AsGuid);
      HandleClickResponse(AdoConnection1, MandatorId, resp);
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TStatisticsForm.dbgQueryDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, '__ID');
end;

procedure TStatisticsForm.dbgQueryKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    Screen.Cursor := crHourGlass;
    try
      // Note: ClickEvent will be called to refresh or regenerate the data
      //       (this is important if the dataset is not a view but a table filled by the plugin).
      //       TCmDbPluginClickResponse will not be evaluated, because it should have stayed the same.
      TCmDbPluginClient.ClickEvent(ADOConnection1, MandatorId, StatisticsId, GUID_NIL);
      AdoQueryRefresh(TDbGrid(Sender).DataSource.DataSet as TAdoQuery, '__ID');
      TDbGrid(Sender).AutoSizeColumns;
    finally
      Screen.Cursor := crDefault;
    end;
    Key := 0;
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
    ds.SQL.Text := SqlQueryStatistics(SearchEdit.Text);
    ds.Active := true;
    TDbGrid(Column.Grid).HideColumnPrefix('__');
    SetFormats; // for some reason, we need it only in this form, nowhere else. Because field list is dynamic? ( https://github.com/danielmarschall/cmdb2/issues/11 )
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TStatisticsForm.SearchEditChange(Sender: TObject);
begin
  Timer1.Enabled := false;
  Timer1.Enabled := true;
end;

procedure TStatisticsForm.SearchEditKeyDown(Sender: TObject; var Key: Word;
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
  if (ttQuery.State=dsEdit) then
    ttQuery.Post;
end;

procedure TStatisticsForm.FormCreate(Sender: TObject);
begin
  SearchEditSav := TStringList.Create;
end;

procedure TStatisticsForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(SearchEditSav);
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

procedure TStatisticsForm.GoBackBtnClick(Sender: TObject);
begin
  MainForm.OpenDbObject('MANDATOR', MandatorId);
end;

procedure TStatisticsForm.HelpBtnClick(Sender: TObject);
begin
  MainForm.ShowHelpWindow('HELP_Statistics.md');
end;

procedure TStatisticsForm.SetFormats;
var
  FormatParts: TArray<string>;
  i: Integer;
  FieldName, DisplayFormat, EditFormat: string;
resourcestring
  SInvalidFormatString = 'Invalid format string';
  SInvalidFormatField = 'Field %s is not a field that supports DisplayFormat.';
begin
  // Split the string by '||'
  FormatParts := DisplayEditFormats.Split(['||']);

  // The string must have a number of parts that is a multiple of 3 (3 per field)
  if (Length(FormatParts) mod 3) <> 0 then
    raise Exception.Create(SInvalidFormatString);

  // Iterate through the parts in groups of 3
  for i := 0 to (Length(FormatParts) div 3) - 1 do
  begin
    FieldName := FormatParts[i * 3];
    DisplayFormat := Trim(FormatParts[i * 3 + 1]);
    EditFormat := Trim(FormatParts[i * 3 + 2]);

    // Set the formats for the field
    if ttQuery.FieldByName(FieldName) is TNumericField then
    begin
      TNumericField(ttQuery.FieldByName(FieldName)).DisplayFormat := DisplayFormat;
      TNumericField(ttQuery.FieldByName(FieldName)).EditFormat := EditFormat;
    end
    else if ttQuery.FieldByName(FieldName) is TDateTimeField then
    begin
      TDateTimeField(ttQuery.FieldByName(FieldName)).DisplayFormat := DisplayFormat;
      //TDateTimeField(ttQuery.FieldByName(FieldName)).EditFormat := EditFormat;
    end
    else if ttQuery.FieldByName(FieldName) is TSQLTimeStampField then
    begin
      TSQLTimeStampField(ttQuery.FieldByName(FieldName)).DisplayFormat := DisplayFormat;
      //TSQLTimeStampField(ttQuery.FieldByName(FieldName)).EditFormat := EditFormat;
    end
    else if ttQuery.FieldByName(FieldName) is TAggregateField then
    begin
      TAggregateField(ttQuery.FieldByName(FieldName)).DisplayFormat := DisplayFormat;
      //TAggregateField(ttQuery.FieldByName(FieldName)).EditFormat := EditFormat;
    end
    else
      raise Exception.CreateFmt(SInvalidFormatField, [FieldName]);
  end;
end;

procedure TStatisticsForm.Init(resp: TCmDbPluginClickResponse);
var
  ttMandator: TAdoDataSet;
  i: Integer;
resourcestring
  SSForS = '%s for %s';
begin
  StatisticsId := resp.StatId;
  StatisticsName := resp.StatName;
  SqlTable := resp.SqlTable;
  SqlInitialOrder := resp.SqlInitialOrder;
  SqlAdditionalFilter := resp.SqlAdditionalFilter;
  BaseTableDelete := resp.BaseTableDelete;
  DisplayEditFormats := resp.DisplayEditFormats;

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
    navQuery.ConfirmDelete := false;
    dbgQuery.Options := dbgQuery.Options - [dgConfirmDelete];
  end;

  // We cannot use OnShow(), because TForm.Create() calls OnShow(), even if Visible=False
  PageControl1.ActivePageIndex := 0;
  TitlePanel.Caption := StringReplace(Caption, '&', '&&', [rfReplaceAll]);
  Screen.Cursor := crHourGlass;
  try
    {$REGION 'ttQuery / dbgQuery'}
    ttQuery.Active := false;
    ttQuery.SQL.Text := SqlQueryStatistics('');
    ttQuery.Active := true;
    dbgQuery.Columns.RebuildColumns; // otherwise column colors won't work!
    dbgQuery.HideColumnPrefix('__');
    dbgQuery.AutoSizeColumns;
    InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbgQuery, navQuery);
    SetFormats;
    for i := 0 to ttQuery.FieldCount-1 do
    begin
      ttQuery.Fields[i].ReadOnly := true;
    end;
    if resp.ScrollToEnd then ttQuery.Last;
    {$ENDREGION}
  finally
    Screen.Cursor := crDefault;
  end;

  // https://stackoverflow.com/questions/54401270/when-i-perform-the-ondblclick-event-form1-to-open-form2-it-fires-the-oncellcl
  dbgQuery.Enabled := false;
  Timer2.Enabled := true;
end;

procedure TStatisticsForm.openQueryClick(Sender: TObject);
begin
  // TODO: It is unknown if it is implemented!
  dbgQueryDblClick(dbgQuery);
end;

end.
