unit Commission;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls, Data.Win.ADODB,
  Vcl.StdCtrls, Vcl.Shell.ShellCtrls;

type
  TCommissionForm = class(TForm)
    PageControl1: TPageControl;
    tsQuotes: TTabSheet;
    dbgQuotes: TDBGrid;
    navQuotes: TDBNavigator;
    dsQuotes: TDataSource;
    ttQuotes: TADOQuery;
    ADOConnection1: TADOConnection;
    Panel1: TPanel;
    tsEvents: TTabSheet;
    navEvents: TDBNavigator;
    dbgEvents: TDBGrid;
    ttEvents: TADOQuery;
    dsEvents: TDataSource;
    ttEventsID: TGuidField;
    ttEventsCOMMISSION_ID: TGuidField;
    ttEventsSTATE: TWideStringField;
    ttEventsANNOTATION: TWideStringField;
    ttQuotesID: TGuidField;
    ttQuotesAMOUNT: TBCDField;
    ttQuotesCURRENCY: TWideStringField;
    ttQuotesAMOUNT_LOCAL: TBCDField;
    ttEventsDATE: TDateTimeField;
    Panel2: TPanel;
    PageControl2: TPageControl;
    Splitter1: TSplitter;
    ttQuotesEVENT_ID: TGuidField;
    ttQuotesDESCRIPTION: TWideStringField;
    tsUploads: TTabSheet;
    navUploads: TDBNavigator;
    dbgUploads: TDBGrid;
    ttUploads: TADOQuery;
    dsUploads: TDataSource;
    ttUploadsID: TGuidField;
    ttUploadsEVENT_ID: TGuidField;
    ttUploadsNO: TIntegerField;
    ttUploadsPAGE: TWideStringField;
    ttUploadsURL: TWideStringField;
    ttUploadsPROHIBIT: TBooleanField;
    ttUploadsANNOTATION: TWideStringField;
    ttUploadsLEGACY_ID: TIntegerField;
    ttQuotesNO: TIntegerField;
    ttQuotesIS_FREE: TBooleanField;
    tsFiles: TTabSheet;
    ShellListView: TShellListView;
    Panel3: TPanel;
    FolderEdit: TEdit;
    BtnFolderSelect: TButton;
    BtnFolderOpen: TButton;
    BtnFolderSave: TButton;
    ShellChangeNotifier: TShellChangeNotifier;
    HelpBtn: TButton;
    GoBackBtn: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ttQuotesNewRecord(DataSet: TDataSet);
    procedure ttEventsNewRecord(DataSet: TDataSet);
    procedure ttEventsAfterScroll(DataSet: TDataSet);
    procedure ttEventsBeforePost(DataSet: TDataSet);
    procedure ttQuotesAfterPost(DataSet: TDataSet);
    procedure ttQuotesBeforePost(DataSet: TDataSet);
    procedure ttUploadsAfterPost(DataSet: TDataSet);
    procedure ttUploadsNewRecord(DataSet: TDataSet);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ttEventsBeforeDelete(DataSet: TDataSet);
    procedure ttQuotesBeforeDelete(DataSet: TDataSet);
    procedure ttUploadsBeforeDelete(DataSet: TDataSet);
    procedure dbgEventsTitleClick(Column: TColumn);
    procedure dbgQuotesTitleClick(Column: TColumn);
    procedure dbgUploadsTitleClick(Column: TColumn);
    procedure ShellListViewDblClick(Sender: TObject);
    procedure BtnFolderSaveClick(Sender: TObject);
    procedure ShellChangeNotifierChange;
    procedure BtnFolderSelectClick(Sender: TObject);
    procedure BtnFolderOpenClick(Sender: TObject);
    procedure ttQuotesAMOUNT_LOCALGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure HelpBtnClick(Sender: TObject);
    procedure GoBackBtnClick(Sender: TObject);
    procedure dbgEventsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgQuotesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgUploadsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    SqlQueryCommissionEvent_Init: boolean;
    SqlQueryCommissionEvent_Order: string;
    SqlQueryCommissionEvent_Asc: boolean;
    SqlQueryQuote_Init: boolean;
    SqlQueryQuote_Order: string;
    SqlQueryQuote_Asc: boolean;
    SqlQueryUpload_Init: boolean;
    SqlQueryUpload_Order: string;
    SqlQueryUpload_Asc: boolean;
    function SqlQueryCommissionEvent(const search: string): string;
    function SqlQueryQuote(const search: string): string;
    function SqlQueryUpload(const search: string): string;
    procedure TryShowFileList(const AFolder: string='');
    procedure RegnerateUploadAnnotation;
    procedure RegnerateQuoteAnnotation;
  protected
    CommissionName: string;
  public
    CommissionId: TGUID;
    procedure Init;
  end;

implementation

{$R *.dfm}

uses
  AdoConnHelper, DbGridHelper, VtsCurConvDLLHeader, Math, CmDbFunctions,
  ShellAPI, StrUtils, CmDbMain;

procedure TCommissionForm.RegnerateQuoteAnnotation;
begin
  if not (ttEvents.State in [dsEdit,dsInsert]) then ttEvents.Edit;
  ttEvents.Tag := 1; // disable Annotation change check
  try
    ttEventsANNOTATION.AsWideString :=
      VariantToString(ADOConnection1.GetScalar(
        'WITH AggregatedAmounts AS ( ' +
        '    SELECT ' +
        '        EVENT_ID, ' +
        '        IS_FREE, ' +
        '        CURRENCY, ' +
        '        SUM(AMOUNT) AS TotalAmount ' +
        '    FROM QUOTE ' +
        '    GROUP BY EVENT_ID, IS_FREE, CURRENCY ' +
        ') ' +
        'SELECT ' +
        '    isnull(STRING_AGG( ' +
        '        CASE ' +
        '            WHEN IS_FREE = 0 THEN N''Price '' + CAST(TotalAmount AS NVARCHAR(10)) + N'' '' + CURRENCY ' +
        '            WHEN IS_FREE = 1 THEN CAST(TotalAmount AS NVARCHAR(10)) + N'' '' + CURRENCY + N'' Free'' ' +
        '        END, ' +
        '        '' + '' ' +
        '    ),'''') AS AggregatedResult ' +
        'FROM AggregatedAmounts ' +
        'WHERE EVENT_ID = ' + ADOConnection1.SQLStringEscape(ttEvents.FieldByName('ID').AsWideString) + ' ' +
        'GROUP BY EVENT_ID'
        ));
    ttEvents.Post;
  finally
    ttEvents.Tag := 0; // enable Annotation change check
  end;
end;

procedure TCommissionForm.ttQuotesAfterPost(DataSet: TDataSet);
begin
  RegnerateQuoteAnnotation;
end;

var
  localCur: string;

procedure TCommissionForm.ttQuotesAMOUNT_LOCALGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  if localCur = '' then
    localCur := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''LOCAL_CURRENCY'';'));
  Text := FormatFloat('#,##0.00', Sender.AsFloat) + ' ' + localCur;
end;

procedure TCommissionForm.ttQuotesBeforeDelete(DataSet: TDataSet);
begin
  try
    InsteadOfDeleteWorkaround(DataSet as TAdoQuery, 'ID', 'QUOTE', 'ID');
  finally
    RegnerateQuoteAnnotation;
  end;
end;

procedure TCommissionForm.ttQuotesBeforePost(DataSet: TDataSet);
var
  CurrencyLayerApiKey: string;
  LocalCurrency: string;
  convertedValue: double;
  dummyTimestamp: TDateTime;
const
  CacheMaxAge = 24*60*60;
begin
  ttQuotesCURRENCY.AsWideString := ttQuotesCURRENCY.AsWideString.ToUpper;
  LocalCurrency := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''LOCAL_CURRENCY'';'));

  if ttQuotesAMOUNT.IsNull then
  begin
    ttQuotesAMOUNT_LOCAL.Clear;
  end
  else if ttQuotesIS_FREE.AsBoolean then
  begin
    ttQuotesAMOUNT_LOCAL.AsFloat := 0;
  end
  else if ((VarCompareValue(ttQuotesAMOUNT.OldValue, ttQuotesAMOUNT.NewValue) <> vrEqual) or (VarCompareValue(ttQuotesCURRENCY.OldValue, ttQuotesCURRENCY.NewValue) <> vrEqual)) and
          SameText(ttQuotesCURRENCY.AsWideString, LocalCurrency) then
  begin
    ttQuotesAMOUNT_LOCAL.AsFloat := ttQuotesAMOUNT.AsFloat;
  end
  else if ((VarCompareValue(ttQuotesAMOUNT.OldValue, ttQuotesAMOUNT.NewValue) <> vrEqual) or (VarCompareValue(ttQuotesCURRENCY.OldValue, ttQuotesCURRENCY.NewValue) <> vrEqual)) and
          (Length(ttQuotesCURRENCY.AsWideString)=3) then
  begin
    if (Length(LocalCurrency)=3) then
    begin
      CurrencyLayerApiKey := Trim(VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''CURRENCY_LAYER_API_KEY'';')));
      if CurrencyLayerApiKey <> '' then
      begin
        if Succeeded(VtsCurConvDLLHeader.WriteAPIKey(PChar(CurrencyLayerApiKey), CONVERT_KEYSTORE_MEMORY, false)) then
        begin
          // Try historic date
          if Succeeded(VtsCurConvDLLHeader.ConvertEx(ttQuotesAMOUNT.AsFloat,
                                                     PChar(UpperCase(ttQuotesCURRENCY.AsWideString)),
                                                     PChar(UpperCase(LocalCurrency)),
                                                     CacheMaxAge, CONVERT_FALLBACK_TO_CACHE or CONVERT_DONT_SHOW_ERRORS,
                                                     ttEventsDATE.AsDateTime,
                                                     @convertedValue, @dummyTimestamp))
          // or if failed (date invalid?) then try today
          or Succeeded(VtsCurConvDLLHeader.ConvertEx(ttQuotesAMOUNT.AsFloat,
                                                     PChar(UpperCase(ttQuotesCURRENCY.AsWideString)),
                                                     PChar(UpperCase(LocalCurrency)),
                                                     CacheMaxAge, CONVERT_FALLBACK_TO_CACHE,
                                                     0,
                                                     @convertedValue, @dummyTimestamp)) then
          begin
            ttQuotesAMOUNT_LOCAL.AsFloat := convertedValue;
          end;
        end;
      end;
    end;
  end;
end;

procedure TCommissionForm.ttQuotesNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := TGUID.NewGuid;
  DataSet.FieldByName('NO').AsInteger :=
    VariantToInteger(ADOConnection1.GetScalar('select isnull(max(NO),0)+1 from QUOTE where EVENT_ID = ' +
      ADOConnection1.SQLStringEscape(ttEvents.FieldByName('ID').AsWideString)
      ));
  DataSet.FieldByName('EVENT_ID').AsGuid := ttEvents.FieldByName('ID').AsGuid;
  DataSet.FieldByName('IS_FREE').AsBoolean := false;
end;

procedure TCommissionForm.RegnerateUploadAnnotation;
begin
  if not (ttEvents.State in [dsEdit,dsInsert]) then ttEvents.Edit;
  ttEvents.Tag := 1; // disable Annotation change check
  try
    ttEventsANNOTATION.AsWideString :=
      VariantToString(ADOConnection1.GetScalar(
        'WITH AggregatedAmounts AS ( ' +
        '    SELECT ' +
        '        EVENT_ID, ' +
        '        PROHIBIT, ' +
        '        PAGE, ' +
        '        COUNT(*) AS TotalAmount ' +
        '    FROM UPLOAD ' +
        '    GROUP BY EVENT_ID, PROHIBIT, PAGE ' +
        ') ' +
        'SELECT ' +
        '    STRING_AGG( ' +
        '        CASE ' +
        '            WHEN PROHIBIT = 0 THEN PAGE + N'' ('' + CAST(TotalAmount AS NVARCHAR(10)) + N'')'' ' +
        '            WHEN PROHIBIT = 1 and isnull(PAGE,'''')='''' THEN N''PROHIBITED'' ' +
        '            WHEN PROHIBIT = 1 and isnull(PAGE,'''')<>'''' THEN PAGE + N'' (PROHIBITED)'' ' +
        '        END, ' +
        '        '', '' ' +
        '    ) AS AggregatedResult ' +
        'FROM AggregatedAmounts ' +
        'WHERE EVENT_ID = ' + ADOConnection1.SQLStringEscape(ttEvents.FieldByName('ID').AsWideString) + ' ' +
        'GROUP BY EVENT_ID'
        ));
    ttEvents.Post;
  finally
    ttEvents.Tag := 0; // enable Annotation change check
  end;
end;

procedure TCommissionForm.ttUploadsAfterPost(DataSet: TDataSet);
begin
  RegnerateUploadAnnotation;
end;

procedure TCommissionForm.ttUploadsBeforeDelete(DataSet: TDataSet);
begin
  try
    InsteadOfDeleteWorkaround(DataSet as TAdoQuery, 'ID', 'UPLOAD', 'ID');
  finally
    RegnerateUploadAnnotation;
  end;
end;

procedure TCommissionForm.ttUploadsNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := TGUID.NewGuid;
  DataSet.FieldByName('NO').AsInteger :=
    VariantToInteger(ADOConnection1.GetScalar('select isnull(max(NO),0)+1 from UPLOAD where EVENT_ID = ' +
      ADOConnection1.SQLStringEscape(ttEvents.FieldByName('ID').AsWideString)
      ));
  DataSet.FieldByName('EVENT_ID').AsGuid := ttEvents.FieldByName('ID').AsGuid;
  DataSet.FieldByName('PROHIBIT').AsBoolean := false;
end;

procedure TCommissionForm.ttEventsAfterScroll(DataSet: TDataSet);
var
  i: integer;
begin
  for i := 0 to PageControl2.PageCount-1 do
  begin
    PageControl2.pages[i].Visible := false;
    PageControl2.pages[i].TabVisible := false;
  end;
  if Dataset.FieldByName('STATE').AsWideString = 'quote' then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttQuotes.Active := false;
      ttQuotes.SQL.Text := SqlQueryQuote('');
      ttQuotes.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
    tsQuotes.Visible := true;
    tsQuotes.TabVisible := true;
    PageControl2.ActivePage := tsQuotes;
  end;
  if (Dataset.FieldByName('STATE').AsWideString = 'upload a') or
     (Dataset.FieldByName('STATE').AsWideString = 'upload c') or
     (Dataset.FieldByName('STATE').AsWideString = 'upload x') then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttUploads.Active := false;
      ttUploads.SQL.Text := SqlQueryUpload('');
      ttUploads.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
    tsUploads.Visible := true;
    tsUploads.TabVisible := true;
    PageControl2.ActivePage := tsUploads;
  end;
end;

procedure TCommissionForm.ttEventsBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround(DataSet as TAdoQuery, 'ID', 'COMMISSION_EVENT', 'ID');
end;

procedure TCommissionForm.ttEventsBeforePost(DataSet: TDataSet);
var
  i: integer;
resourcestring
  SInvalidEventType = 'Invalid event type. Please pick one from the list.';
  SEventTypeNotChangeable = 'The event type of that row can only be changed during creation of the row.';
  SAnnotationSetNotAllowed = 'Annotations for Quotes and Uploads are automatically filled. Please remove the annotation you have entered.';
  SAnnotationEditNotAllowed = 'Annotations for Quotes and Uploads are automatically filled. You must not edit them.';
begin
  for i := 0 to dbgEvents.Columns.Count-1 do
    if dbgEvents.Columns.Items[i].Field.FieldName = 'STATE' then
      if dbgEvents.Columns.Items[i].PickList.IndexOf(Dataset.FieldByName('STATE').AsWideString) = -1 then
        raise Exception.Create(SInvalidEventType);

  if (Dataset.FieldByName('STATE').AsWideString = 'quote') or
     StartsText('upload ', Dataset.FieldByName('STATE').AsWideString) then
  begin
    if (ttEvents.Tag <> 1) and (DataSet.State = dsEdit) and (Dataset.FieldByName('ANNOTATION').OldValue <> Dataset.FieldByName('ANNOTATION').NewValue) then
      raise Exception.Create(SAnnotationEditNotAllowed);

    if (ttEvents.Tag <> 1) and (DataSet.State = dsInsert) and (Trim(Dataset.FieldByName('ANNOTATION').AsWideString) <> '') then
      raise Exception.Create(SAnnotationSetNotAllowed);
  end;

  // Event type is not changeable, because Quotes and Uploads might be attached to it
  if (Dataset.State = dsEdit) and (Dataset.FieldByName('STATE').OldValue <> Dataset.FieldByName('STATE').NewValue) then
    raise Exception.Create(SEventTypeNotChangeable);
end;

procedure TCommissionForm.ttEventsNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := TGUID.NewGuid;
  DataSet.FieldByName('COMMISSION_ID').AsGuid := CommissionId;
  DataSet.FieldByName('DATE').AsDateTime := Date;
end;

procedure TCommissionForm.TryShowFileList(const AFolder: string='');
begin
  if ShellListView = nil then exit;

  ShellListView.Items.BeginUpdate;
  try
    try
      if AFolder <> '' then
      begin
        ShellListView.Root := 'C:\'; // hack to allow that the next line works a second time
        ShellListView.Root := AFolder;
        ShellChangeNotifier.Root := ShellListView.Root;
      end
      else
      begin
        ShellListView.Refresh;
      end;
      ShellListView.ViewStyle := vsReport;
      ShellListView.Sorted := true;
      ShellListView.Columns[0{Name}].Width := 300; // Does not work:  ShellListView.Columns[0].Width := LVSCW_AUTOSIZE or LVSCW_AUTOSIZE_USEHEADER;
      ShellListView.Columns[1{Size}].Width := 95;
      ShellListView.Columns[2{Type}].Width := 200;
      ShellListView.Columns[3{Date}].Width := 115;
      ShellListView.Visible := not SameText(ShellListView.Root, 'C:\');
    except
      ShellListView.Visible := false;
      raise;
    end;
  finally
    ShellListView.Items.EndUpdate;
  end;
end;

procedure TCommissionForm.BtnFolderSelectClick(Sender: TObject);
begin
  // https://stackoverflow.com/questions/7422689/selecting-a-directory-with-topendialog
  with TFileOpenDialog.Create(nil) do
  begin
    try
      Options := [fdoPickFolders];
      if Execute then
      begin
        FolderEdit.Text := FileName;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TCommissionForm.HelpBtnClick(Sender: TObject);
begin
  MainForm.ShowHelpWindow('HELP_CommissionWindow.md');
end;

procedure TCommissionForm.BtnFolderOpenClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(FolderEdit.Text), '', '', SW_NORMAL);
end;

procedure TCommissionForm.BtnFolderSaveClick(Sender: TObject);
begin
  TryShowFileList(Trim(FolderEdit.Text));
  ADOConnection1.ExecSQL('update COMMISSION set FOLDER = '+ADOConnection1.SQLStringEscape(Trim(FolderEdit.Text))+' where ID = '+ADOConnection1.SQLStringEscape(CommissionId.ToString));
end;

procedure TCommissionForm.ShellChangeNotifierChange;
begin
  TryShowFileList;
end;

procedure TCommissionForm.ShellListViewDblClick(Sender: TObject);
var
  LFolder: TShellFolder;
begin
  LFolder := ShellListView.SelectedFolder;
  if Assigned(LFolder) then
  begin
    ShellExecute(Handle, 'open', PChar(LFolder.PathName), '', '', SW_NORMAL);
  end;
end;

function TCommissionForm.SqlQueryCommissionEvent(const search: string): string;
begin
  if not SqlQueryCommissionEvent_Init then
  begin
    SqlQueryCommissionEvent_Init := true;
    SqlQueryCommissionEvent_order := '';
    SqlQueryCommissionEvent_asc := true;
  end;
  result := 'select * ';
  result := result + 'from vw_COMMISSION_EVENT ';
  result := result + 'where COMMISSION_ID = ''' + CommissionId.ToString + ''' ';
  if trim(search)<>'' then
    result := result + 'and lower(ANNOTATION) like ''%'+StringReplace(AnsiLowerCase(trim(search)), '''', '`', [rfReplaceAll])+'%'' ';
  if SqlQueryCommissionEvent_order = '' then
    result := result + 'order by case when abs(datediff(year,getdate(),DATE))>100 and STATE=''ack'' then 0 ' +
                       '              when abs(datediff(year,getdate(),DATE))>100 and STATE like ''cancel%'' then 2 ' +
                       '              when abs(datediff(year,getdate(),DATE))>100 and STATE=''fin'' then 3 ' +
                       '              when abs(datediff(year,getdate(),DATE))>100 and STATE like ''upload%'' then 4 ' +
                       '              else 1 end '+AscDesc(SqlQueryCommissionEvent_asc)+', DATE, STATE, ANNOTATION'
  else
    result := result + 'order by ' + SqlQueryCommissionEvent_order + ' ' + AscDesc(SqlQueryCommissionEvent_asc);
end;

function TCommissionForm.SqlQueryQuote(const search: string): string;
begin
  if not SqlQueryQuote_Init then
  begin
    SqlQueryQuote_Init := true;
    SqlQueryQuote_order := 'NO';
    SqlQueryQuote_asc := true;
  end;
  result := 'select * ';
  result := result + 'from vw_QUOTE ';
  result := result + 'where EVENT_ID = ''' + ttEvents.FieldByName('ID').AsWideString + ''' ';
  if trim(search)<>'' then
    result := result + 'and lower(DESCRIPTION) like ''%'+StringReplace(AnsiLowerCase(trim(search)), '''', '`', [rfReplaceAll])+'%'' ';
  if SqlQueryQuote_order = 'NO' then
    result := result + 'order by NO '+AscDesc(SqlQueryQuote_asc)+', DESCRIPTION'
  else
    result := result + 'order by ' + SqlQueryQuote_order + ' ' + AscDesc(SqlQueryQuote_asc);
end;

function TCommissionForm.SqlQueryUpload(const search: string): string;
begin
  if not SqlQueryUpload_Init then
  begin
    SqlQueryUpload_Init := true;
    SqlQueryUpload_order := 'NO';
    SqlQueryUpload_asc := true;
  end;
  result := 'select * ';
  result := result + 'from vw_UPLOAD ';
  result := result + 'where EVENT_ID = ''' + ttEvents.FieldByName('ID').AsWideString + ''' ';
  if trim(search)<>'' then
    result := result + 'and ( lower(PAGE) like ''%'+StringReplace(AnsiLowerCase(trim(search)), '''', '`', [rfReplaceAll])+'%'' or ' +
                       'or    lower(URL) like ''%'+StringReplace(AnsiLowerCase(trim(search)), '''', '`', [rfReplaceAll])+'%'' or ' +
                       'or    lower(ANNOTATION) like ''%'+StringReplace(AnsiLowerCase(trim(search)), '''', '`', [rfReplaceAll])+'%'' ' +
                       '    ) ';
  if SqlQueryUpload_order = 'NO' then
    result := result + 'order by NO '+AscDesc(SqlQueryUpload_asc)+', PAGE, URL'
  else
    result := result + 'order by ' + SqlQueryUpload_order + ' ' + AscDesc(SqlQueryUpload_asc);
end;

procedure TCommissionForm.dbgEventsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    Screen.Cursor := crHourGlass;
    try
      AdoQueryRefresh(TDbGrid(Sender).DataSource.DataSet as TAdoQuery, 'ID');
    finally
      Screen.Cursor := crDefault;
    end;
    Key := 0;
  end;
end;

procedure TCommissionForm.dbgEventsTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryCommissionEvent_Order := Column.FieldName;
    SqlQueryCommissionEvent_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryCommissionEvent('');
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TCommissionForm.dbgQuotesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    Screen.Cursor := crHourGlass;
    try
      AdoQueryRefresh(TDbGrid(Sender).DataSource.DataSet as TAdoQuery, 'ID');
    finally
      Screen.Cursor := crDefault;
    end;
    Key := 0;
  end;
end;

procedure TCommissionForm.dbgQuotesTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryQuote_Order := Column.FieldName;
    SqlQueryQuote_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryQuote('');
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TCommissionForm.dbgUploadsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    Screen.Cursor := crHourGlass;
    try
      AdoQueryRefresh(TDbGrid(Sender).DataSource.DataSet as TAdoQuery, 'ID');
    finally
      Screen.Cursor := crDefault;
    end;
    Key := 0;
  end;
end;

procedure TCommissionForm.dbgUploadsTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryUpload_Order := Column.FieldName;
    SqlQueryUpload_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryUpload('');
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TCommissionForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TCommissionForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ttEvents.State in [dsEdit,dsInsert] then ttEvents.Post;
  if ttQuotes.State in [dsEdit,dsInsert] then ttQuotes.Post;
  if ttUploads.State in [dsEdit,dsInsert] then ttUploads.Post;
end;

procedure TCommissionForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // We must use FormKeyDown AND FormKeyUp. Why?
  // If we only use FormKeyDown only, then ESC will not only close this window, but also windows below (even if Key:=0 will be performed)
  // If we only use FormKeyUp, we don't get the correct dataset state (since dsEdit,dsInsert got reverted during KeyDown)
  if (Key = VK_ESCAPE) and not (ttEvents.State in [dsEdit,dsInsert])
                       and not (ttQuotes.State in [dsEdit,dsInsert])
                       and not (ttUploads.State in [dsEdit,dsInsert]) then
  begin
    Tag := 1; // tell FormKeyUp that we may close
    Key := 0;
  end;
end;

procedure TCommissionForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Tag = 1) then
  begin
    Close;
    Key := 0;
  end;
end;

procedure TCommissionForm.GoBackBtnClick(Sender: TObject);
var
  parentId: string;
begin
  parentId := VarToStr(ADOConnection1.GetScalar('select ARTIST_ID from COMMISSION where ID = ''' + CommissionId.ToString + ''''));
  MainForm.OpenDbObject('ARTIST', StringToGuid(parentId));
end;

procedure TCommissionForm.Init;
var
  i: integer;
  ttCommission: TAdoDataset;
resourcestring
  SCommissionSbyS = 'Commission %s by %s';
  SCommissionSforS = 'Commission %s for %s';
begin
  ttCommission := ADOConnection1.GetTable('select * from vw_COMMISSION where ID = ''' + CommissionId.ToString + '''');
  try
    CommissionName := ttCommission.FieldByName('NAME').AsWideString;
    if ttCommission.FieldByName('IS_ARTIST').AsBoolean then
    begin
      Caption :=
        Format(SCommissionSbyS, [ttCommission.FieldByName('NAME').AsWideString, ttCommission.FieldByName('ARTIST_NAME').AsWideString]);
    end
    else
    begin
      Caption :=
        Format(SCommissionSforS, [ttCommission.FieldByName('NAME').AsWideString, ttCommission.FieldByName('ARTIST_NAME').AsWideString]);
    end;
  finally
    FreeAndNil(ttCommission);
  end;

  // We cannot use OnShow(), because TForm.Create() calls OnShow(), even if Visible=False
  PageControl1.ActivePageIndex := 0;
  for i := 0 to PageControl2.PageCount-1 do
  begin
    PageControl2.pages[i].Visible := false;
    PageControl2.pages[i].TabVisible := false;
  end;
  Panel1.Caption := Caption;
  Screen.Cursor := crHourGlass;
  try
    {$REGION 'ttEvents / dbgEvents'}
    ttEvents.Active := false;
    ttEvents.SQL.Text := SqlQueryCommissionEvent('');
    ttEvents.Active := true;
    dbgEvents.AutoSizeColumns;
    {$ENDREGION}

    dbgUploads.Columns[1].PickList.Delimiter := ';';
    dbgUploads.Columns[1].PickList.StrictDelimiter := True;
    dbgUploads.Columns[1].PickList.DelimitedText := VariantToString(ADOConnection1.GetScalar('select VALUE from CONFIG where NAME = ''PICKLIST_ARTPAGES'''));

    try
      FolderEdit.Text := VariantToString(ADOConnection1.GetScalar('select FOLDER from COMMISSION where ID = ' + ADOConnection1.SQLStringEscape(CommissionId.ToString)));
      TryShowFileList(FolderEdit.Text);
    except
    end;
  finally
    Screen.Cursor := crDefault;
  end;
  dbgEvents.SetFocus; // Because TabOrder does only select the tab, not the page contents
end;

end.
