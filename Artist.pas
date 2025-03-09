unit Artist;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls, Data.Win.ADODB,
  Vcl.StdCtrls;

type
  TArtistForm = class(TForm)
    PageControl1: TPageControl;
    tsCommissions: TTabSheet;
    dbgCommission: TDBGrid;
    navCommission: TDBNavigator;
    ADOConnection1: TADOConnection;
    ttCommission: TADOQuery;
    dsCommission: TDataSource;
    tsPayment: TTabSheet;
    HeadPanel: TPanel;
    ttPayment: TADOQuery;
    dsPayment: TDataSource;
    navPayment: TDBNavigator;
    dbgPayment: TDBGrid;
    ttCommissionID: TGuidField;
    ttCommissionARTIST_ID: TGuidField;
    ttCommissionNAME: TWideStringField;
    ttCommissionUPLOAD_A: TWideStringField;
    ttCommissionUPLOAD_C: TWideStringField;
    ttPaymentID: TGuidField;
    ttPaymentARTIST_ID: TGuidField;
    ttPaymentAMOUNT: TBCDField;
    ttPaymentCURRENCY: TWideStringField;
    ttPaymentDATE: TDateTimeField;
    ttPaymentAMOUNT_LOCAL: TBCDField;
    ttCommissionSTART_DATE: TDateTimeField;
    ttCommissionEND_DATE: TDateTimeField;
    ttCommissionART_STATUS: TWideStringField;
    ttCommissionPAY_STATUS: TWideStringField;
    ttPaymentAMOUNT_VERIFIED: TBooleanField;
    ttPaymentPAYPROV: TWideStringField;
    ttPaymentANNOTATION: TWideStringField;
    SearchEdit: TEdit;
    SearchBtn: TButton;
    tsArtistEvent: TTabSheet;
    ttArtistEvent: TADOQuery;
    dsArtistEvent: TDataSource;
    navArtistEvent: TDBNavigator;
    dbgArtistEvent: TDBGrid;
    tsCommunication: TTabSheet;
    dbgCommunication: TDBGrid;
    navCommunication: TDBNavigator;
    ttCommunication: TADOQuery;
    dsCommunication: TDataSource;
    ttArtistEventID: TGuidField;
    ttArtistEventARTIST_ID: TGuidField;
    ttArtistEventDATE: TDateTimeField;
    ttArtistEventSTATE: TWideStringField;
    ttArtistEventANNOTATION: TWideStringField;
    ttCommunicationID: TGuidField;
    ttCommunicationARTIST_ID: TGuidField;
    ttCommunicationCHANNEL: TWideStringField;
    ttCommunicationADDRESS: TWideStringField;
    ttCommunicationANNOTATION: TWideStringField;
    ttCommissionAMOUNT_LOCAL: TBcdField;
    ttCommissionMANDATOR_ID: TGuidField;
    ttCommissionIS_ARTIST: TBooleanField;
    ttCommissionARTIST_NAME: TWideStringField;
    ttCommissionFOLDER: TWideStringField;
    ttCommissionPROJECT_NAME: TWideStringField;
    Timer1: TTimer;
    sbCommission: TPanel;
    csvCommission: TButton;
    sbPayment: TPanel;
    csvPayment: TButton;
    sbArtistEvent: TPanel;
    csvArtistEvent: TButton;
    sbCommunication: TPanel;
    csvCommunication: TButton;
    sdCsvCommission: TSaveDialog;
    sdCsvPayment: TSaveDialog;
    sdCsvArtistEvent: TSaveDialog;
    sdCsvCommunication: TSaveDialog;
    refreshCommunication: TBitBtn;
    refreshEvent: TBitBtn;
    refreshPayment: TBitBtn;
    refreshCommission: TBitBtn;
    ttPaymentARTIST_OR_CLIENT_NAME: TWideStringField;
    ttPaymentMANDATOR_ID: TGuidField;
    ttPaymentIS_ARTIST: TBooleanField;
    ttPaymentARTIST_NAME: TWideStringField;
    HelpBtn: TButton;
    GoBackBtn: TButton;
    Timer2: TTimer;
    openCommission: TBitBtn;
    openCommunication: TBitBtn;
    TitlePanel: TPanel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbgCommissionDblClick(Sender: TObject);
    procedure ttCommissionNewRecord(DataSet: TDataSet);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ttPaymentNewRecord(DataSet: TDataSet);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchEditChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure SearchEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchBtnClick(Sender: TObject);
    procedure ttCommunicationNewRecord(DataSet: TDataSet);
    procedure ttArtistEventNewRecord(DataSet: TDataSet);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure ttCommissionBeforeDelete(DataSet: TDataSet);
    procedure ttPaymentBeforeDelete(DataSet: TDataSet);
    procedure ttArtistEventBeforeDelete(DataSet: TDataSet);
    procedure ttCommunicationBeforeDelete(DataSet: TDataSet);
    procedure ttCommissionAfterScroll(DataSet: TDataSet);
    procedure ttPaymentAfterScroll(DataSet: TDataSet);
    procedure ttArtistEventAfterScroll(DataSet: TDataSet);
    procedure ttCommunicationAfterScroll(DataSet: TDataSet);
    procedure dbgCommissionTitleClick(Column: TColumn);
    procedure dbgPaymentTitleClick(Column: TColumn);
    procedure dbgArtistEventTitleClick(Column: TColumn);
    procedure dbgCommunicationTitleClick(Column: TColumn);
    procedure csvCommissionClick(Sender: TObject);
    procedure csvPaymentClick(Sender: TObject);
    procedure csvArtistEventClick(Sender: TObject);
    procedure csvCommunicationClick(Sender: TObject);
    procedure refreshCommunicationClick(Sender: TObject);
    procedure refreshEventClick(Sender: TObject);
    procedure refreshPaymentClick(Sender: TObject);
    procedure refreshCommissionClick(Sender: TObject);
    procedure ttPaymentBeforePost(DataSet: TDataSet);
    procedure ttArtistEventBeforePost(DataSet: TDataSet);
    procedure HelpBtnClick(Sender: TObject);
    procedure GoBackBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure dbgCommissionKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgPaymentKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgArtistEventKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgCommunicationKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ttArtistEventBeforeEdit(DataSet: TDataSet);
    procedure dbgArtistEventDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ttCommissionBeforeEdit(DataSet: TDataSet);
    procedure dbgCommissionDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ttCommunicationBeforeEdit(DataSet: TDataSet);
    procedure dbgCommunicationDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ttPaymentBeforeEdit(DataSet: TDataSet);
    procedure dbgPaymentDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure Timer2Timer(Sender: TObject);
    procedure ttCommunicationBeforePost(DataSet: TDataSet);
    procedure ttCommissionBeforePost(DataSet: TDataSet);
    procedure dbgCommunicationDblClick(Sender: TObject);
    procedure openCommissionClick(Sender: TObject);
    procedure openCommunicationClick(Sender: TObject);
    procedure navCommunicationClick(Sender: TObject; Button: TNavigateBtn);
    procedure navArtistEventClick(Sender: TObject; Button: TNavigateBtn);
    procedure navPaymentClick(Sender: TObject; Button: TNavigateBtn);
    procedure navCommissionClick(Sender: TObject; Button: TNavigateBtn);
  private
    SearchEditSav: TStringList;
    SqlQueryCommission_Init: boolean;
    SqlQueryCommission_Order: string;
    SqlQueryCommission_Asc: boolean;
    SqlQueryPayment_Init: boolean;
    SqlQueryPayment_Order: string;
    SqlQueryPayment_Asc: boolean;
    SqlQueryArtistEvent_Init: boolean;
    SqlQueryArtistEvent_Order: string;
    SqlQueryArtistEvent_Asc: boolean;
    SqlQueryCommunication_Init: boolean;
    SqlQueryCommunication_Order: string;
    SqlQueryCommunication_Asc: boolean;
    function SqlQueryCommission(const search: string): string;
    function SqlQueryPayment(const search: string): string;
    function SqlQueryArtistEvent(const search: string): string;
    function SqlQueryCommunication(const search: string): string;
    procedure DoRefresh(dbg: TDbGrid; const ALocateField: string);
  protected
    ArtistName: string;
  public
    ArtistId: TGUID;
    procedure Init;
  end;

implementation

{$R *.dfm}

uses
  CmDbMain, Commission, DbGridHelper, AdoConnHelper, CmDbFunctions,
  VtsCurConvDLLHeader, StrUtils, ShellAPI;

procedure TArtistForm.ttArtistEventAfterScroll(DataSet: TDataSet);
begin
  sbArtistEvent.Caption := CmDb_ShowRows(DataSet)+'   ';
end;

procedure TArtistForm.ttArtistEventBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeDelete(Dataset as TAdoQuery, 'ID', 'ARTIST_EVENT', 'ID');
end;

procedure TArtistForm.ttArtistEventBeforeEdit(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeEdit(Dataset as TAdoQuery, 'ID');
end;

procedure TArtistForm.ttArtistEventBeforePost(DataSet: TDataSet);
var
  i: integer;
resourcestring
  SInvalidEventType = 'Invalid event type. Please pick one from the list.';
begin
  DataSet.FieldByName('ANNOTATION').AsWideString := Trim(DataSet.FieldByName('ANNOTATION').AsWideString);
  for i := 0 to dbgArtistEvent.Columns.Count-1 do
    if dbgArtistEvent.Columns.Items[i].Field.FieldName = 'STATE' then
      if dbgArtistEvent.Columns.Items[i].PickList.IndexOf(Dataset.FieldByName('STATE').AsWideString) = -1 then
        raise Exception.Create(SInvalidEventType);
end;

procedure TArtistForm.ttArtistEventNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := ADOConnection1.NewSeqGuid;
  DataSet.FieldByName('ARTIST_ID').AsGuid := ArtistId;
  DataSet.FieldByName('DATE').AsDateTime := Date;
end;

procedure TArtistForm.ttCommissionAfterScroll(DataSet: TDataSet);
begin
  sbCommission.Caption := CmDb_ShowRows(DataSet)+'   ';
end;

procedure TArtistForm.ttCommissionBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeDelete(Dataset as TAdoQuery, 'ID', 'COMMISSION', 'ID');
end;

procedure TArtistForm.ttCommissionBeforeEdit(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeEdit(Dataset as TAdoQuery, 'ID');
end;

procedure TArtistForm.ttCommissionBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('NAME').AsWideString := Trim(DataSet.FieldByName('NAME').AsWideString);
end;

procedure TArtistForm.ttCommissionNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := ADOConnection1.NewSeqGuid;
  DataSet.FieldByName('ARTIST_ID').AsGuid := ArtistId;
end;

procedure TArtistForm.ttCommunicationAfterScroll(DataSet: TDataSet);
begin
  sbCommunication.Caption := CmDb_ShowRows(DataSet)+'   ';
  openCommunication.Enabled :=
      StartsText('http://', ttCommunicationADDRESS.AsWideString) or
      StartsText('https://', ttCommunicationADDRESS.AsWideString) or
      StartsText('mailto:', ttCommunicationADDRESS.AsWideString); // <-- TODO: Better: E-Mail-Address detection!
end;

procedure TArtistForm.ttCommunicationBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeDelete(Dataset as TAdoQuery, 'ID', 'COMMUNICATION', 'ID');
end;

procedure TArtistForm.ttCommunicationBeforeEdit(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeEdit(Dataset as TAdoQuery, 'ID');
end;

procedure TArtistForm.ttCommunicationBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('CHANNEL').AsWideString := Trim(DataSet.FieldByName('CHANNEL').AsWideString);
  DataSet.FieldByName('ADDRESS').AsWideString := Trim(DataSet.FieldByName('ADDRESS').AsWideString);
  DataSet.FieldByName('ANNOTATION').AsWideString := Trim(DataSet.FieldByName('ANNOTATION').AsWideString);
end;

procedure TArtistForm.ttCommunicationNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := ADOConnection1.NewSeqGuid;
  DataSet.FieldByName('ARTIST_ID').AsGuid := ArtistId;
end;

procedure TArtistForm.ttPaymentAfterScroll(DataSet: TDataSet);
begin
  sbPayment.Caption := CmDb_ShowRows(DataSet)+'   ';
end;

procedure TArtistForm.ttPaymentBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeDelete(Dataset as TAdoQuery, 'ID', 'PAYMENT', 'ID');
end;

procedure TArtistForm.ttPaymentBeforeEdit(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeEdit(Dataset as TAdoQuery, 'ID');
end;

procedure TArtistForm.ttPaymentBeforePost(DataSet: TDataSet);
var
  CurrencyLayerApiKey: string;
  LocalCurrency: string;
  convertedValue: double;
  dummyTimestamp: TDateTime;
resourcestring
  SInvalidCurrency = 'Invalid currency code. Please enter a valid 3-character code, e.g. USD.';
const
  CacheMaxAge = 24*60*60;
begin
  DataSet.FieldByName('ANNOTATION').AsWideString := Trim(DataSet.FieldByName('ANNOTATION').AsWideString);
  DataSet.FieldByName('PAYPROV').AsWideString := Trim(DataSet.FieldByName('PAYPROV').AsWideString);

  if Length(ttPaymentCURRENCY.AsWideString) <> 3 then
    raise Exception.Create(SInvalidCurrency)
  else
    ttPaymentCURRENCY.AsWideString := ttPaymentCURRENCY.AsWideString.ToUpper;

  LocalCurrency := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''LOCAL_CURRENCY'';'));

  if ttPaymentAMOUNT_VERIFIED.IsNull then
    ttPaymentAMOUNT_VERIFIED.AsBoolean := False;

  if ttPaymentAMOUNT.IsNull then
  begin
    ttPaymentAMOUNT_LOCAL.Clear;
  end
  else if not ttPaymentAMOUNT_VERIFIED.AsBoolean and
          ((VarCompareValue(ttPaymentAMOUNT.OldValue, ttPaymentAMOUNT.NewValue) <> vrEqual) or (VarCompareValue(ttPaymentCURRENCY.OldValue, ttPaymentCURRENCY.NewValue) <> vrEqual)) and
          SameText(ttPaymentCURRENCY.AsWideString, LocalCurrency) then
  begin
    // Note: do not set AMOUNT_VERIFIED=1, because there might be additional fees beside the conversion
    ttPaymentAMOUNT_LOCAL.AsFloat := ttPaymentAMOUNT.AsFloat;
    ttPaymentAMOUNT_VERIFIED.AsBoolean := False;
  end
  else if not ttPaymentAMOUNT_VERIFIED.AsBoolean and
          ((VarCompareValue(ttPaymentAMOUNT.OldValue, ttPaymentAMOUNT.NewValue) <> vrEqual) or (VarCompareValue(ttPaymentCURRENCY.OldValue, ttPaymentCURRENCY.NewValue) <> vrEqual)) and
          (Length(ttPaymentCURRENCY.AsWideString)=3) then
  begin
    if (Length(LocalCurrency)=3) then
    begin
      CurrencyLayerApiKey := Trim(VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''CURRENCY_LAYER_API_KEY'';')));
      if CurrencyLayerApiKey <> '' then
      begin
        if Succeeded(VtsCurConvDLLHeader.WriteAPIKey(PChar(CurrencyLayerApiKey), CONVERT_KEYSTORE_MEMORY, false)) then
        begin
          // Try historic date
          if Succeeded(VtsCurConvDLLHeader.ConvertEx(ttPaymentAMOUNT.AsFloat,
                                                     PChar(UpperCase(ttPaymentCURRENCY.AsWideString)),
                                                     PChar(UpperCase(LocalCurrency)),
                                                     CacheMaxAge, CONVERT_FALLBACK_TO_CACHE or CONVERT_DONT_SHOW_ERRORS,
                                                     ttPaymentDATE.AsDateTime,
                                                     @convertedValue, @dummyTimestamp))
          // or if failed (date invalid?) then try today
          or Succeeded(VtsCurConvDLLHeader.ConvertEx(ttPaymentAMOUNT.AsFloat,
                                                     PChar(UpperCase(ttPaymentCURRENCY.AsWideString)),
                                                     PChar(UpperCase(LocalCurrency)),
                                                     CacheMaxAge, CONVERT_FALLBACK_TO_CACHE,
                                                     0,
                                                     @convertedValue, @dummyTimestamp)) then
          begin
            ttPaymentAMOUNT_LOCAL.AsFloat := convertedValue;
            ttPaymentAMOUNT_VERIFIED.AsBoolean := False;
          end;
        end;
      end;
    end;
  end;
end;

procedure TArtistForm.ttPaymentNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := ADOConnection1.NewSeqGuid;
  DataSet.FieldByName('ARTIST_ID').AsGuid := ArtistId;
  DataSet.FieldByName('DATE').AsDateTime := Date;
end;

procedure TArtistForm.refreshCommissionClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    AdoQueryRefresh(ttCommission, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TArtistForm.refreshCommunicationClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    AdoQueryRefresh(ttCommunication, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TArtistForm.refreshEventClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    AdoQueryRefresh(ttArtistEvent, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TArtistForm.refreshPaymentClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    AdoQueryRefresh(ttPayment, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TArtistForm.SearchBtnClick(Sender: TObject);
begin
  if SearchEdit.Text <> '' then
    SearchEdit.Clear;
  if SearchEdit.CanFocus then
    SearchEdit.SetFocus;
end;

procedure TArtistForm.HelpBtnClick(Sender: TObject);
begin
  MainForm.ShowHelpWindow('HELP_ArtistClientWindow.md');
end;

procedure TArtistForm.csvArtistEventClick(Sender: TObject);
begin
  if sdCsvArtistEvent.Execute then
    SaveGridToCsv(dbgArtistEvent, sdCsvArtistEvent.FileName);
end;

procedure TArtistForm.csvCommissionClick(Sender: TObject);
begin
  if sdCsvCommission.Execute then
    SaveGridToCsv(dbgCommission, sdCsvCommission.FileName);
end;

procedure TArtistForm.csvCommunicationClick(Sender: TObject);
begin
  if sdCsvCommunication.Execute then
    SaveGridToCsv(dbgCommunication, sdCsvCommunication.FileName);
end;

procedure TArtistForm.csvPaymentClick(Sender: TObject);
begin
  if sdCsvPayment.Execute then
    SaveGridToCsv(dbgPayment, sdCsvPayment.FileName);
end;

procedure TArtistForm.dbgArtistEventDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'ID');
end;

procedure TArtistForm.dbgArtistEventKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    Key := 0;
    Screen.Cursor := crHourGlass;
    try
      DoRefresh(Sender as TDbGrid, 'ID');
    finally
      Screen.Cursor := crDefault;
    end;
  end
  else if Key = VK_INSERT then
  begin
    Key := 0;
    TDbGrid(Sender).DataSource.DataSet.Append;
  end;
end;

procedure TArtistForm.dbgArtistEventTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryArtistEvent_Order := Column.FieldName;
    SqlQueryArtistEvent_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryArtistEvent(SearchEdit.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TArtistForm.dbgCommissionDblClick(Sender: TObject);
begin
  if ttCommission.State in [dsEdit,dsInsert] then ttCommission.Post;
  if ttCommission.FieldByName('ID').IsNull then exit;
  MainForm.OpenDbObject('COMMISSION', ttCommission.FieldByName('ID').AsGuid);
end;

procedure TArtistForm.dbgCommissionDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'ID');
end;

procedure TArtistForm.dbgCommissionKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    Key := 0;
    Screen.Cursor := crHourGlass;
    try
      DoRefresh(Sender as TDbGrid, 'ID');
    finally
      Screen.Cursor := crDefault;
    end;
  end
  else if Key = VK_INSERT then
  begin
    Key := 0;
    TDbGrid(Sender).DataSource.DataSet.Append;
  end;
end;

procedure TArtistForm.dbgCommissionTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryCommission_Order := Column.FieldName;
    SqlQueryCommission_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryCommission(SearchEdit.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TArtistForm.dbgCommunicationDblClick(Sender: TObject);
begin
  if ttCommunication.State in [dsEdit,dsInsert] then exit;
  if ttCommunication.RecordCount = 0 then exit;
  if ttCommunicationADDRESS.AsWideString = '' then exit;
  if openCommunication.Enabled then
  begin
    ShellExecute(Handle, 'open', PChar(ttCommunicationADDRESS.AsWideString), '', '', SW_NORMAL);
  end;
end;

procedure TArtistForm.dbgCommunicationDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'ID');
end;

procedure TArtistForm.dbgCommunicationKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    Key := 0;
    Screen.Cursor := crHourGlass;
    try
      DoRefresh(Sender as TDbGrid, 'ID');
    finally
      Screen.Cursor := crDefault;
    end;
  end
  else if Key = VK_INSERT then
  begin
    Key := 0;
    TDbGrid(Sender).DataSource.DataSet.Append;
  end;
end;

procedure TArtistForm.dbgCommunicationTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryCommunication_Order := Column.FieldName;
    SqlQueryCommunication_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryCommunication(SearchEdit.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TArtistForm.dbgPaymentDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'ID');
end;

procedure TArtistForm.DoRefresh(dbg: TDbGrid; const ALocateField: string);
begin
  AdoQueryRefresh(dbg.DataSource.DataSet as TAdoQuery, ALocateField);
  dbg.AutoSizeColumns;
end;

procedure TArtistForm.dbgPaymentKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    Key := 0;
    Screen.Cursor := crHourGlass;
    try
      DoRefresh(Sender as TDbGrid, 'ID');
    finally
      Screen.Cursor := crDefault;
    end;
  end
  else if Key = VK_INSERT then
  begin
    Key := 0;
    TDbGrid(Sender).DataSource.DataSet.Append;
  end;
end;

procedure TArtistForm.dbgPaymentTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryPayment_Order := Column.FieldName;
    SqlQueryPayment_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryPayment(SearchEdit.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TArtistForm.PageControl1Change(Sender: TObject);
begin
  if Assigned(SearchEditSav) then
    SearchEdit.Text := SearchEditSav.Values[TPageControl(Sender).ActivePage.Name]
  else
    SearchEdit.Text := '';
  Timer1.Enabled := False;
end;

function TArtistForm.SqlQueryArtistEvent(const search: string): string;
begin
  if not SqlQueryArtistEvent_Init then
  begin
    SqlQueryArtistEvent_Init := true;
    SqlQueryArtistEvent_order := '';
    SqlQueryArtistEvent_asc := true;
  end;
  result := 'select * ';
  result := result + 'from vw_ARTIST_EVENT ';
  result := result + 'where ARTIST_ID = ''' + ArtistId.ToString + ''' ';
  if Trim(search) <> '' then
    result := result + 'and ' + BuildSearchCondition(search, dbgArtistEvent);
  if SqlQueryArtistEvent_order = '' then
    result := result + 'order by case when abs(datediff(year,getdate(),DATE))>100 and STATE=''born'' then 0 ' +
                       '              when abs(datediff(year,getdate(),DATE))>100 and STATE=''deceased'' then 2 ' +
                       '              else 1 end '+AscDesc(SqlQueryArtistEvent_asc)+', DATE '+AscDesc(SqlQueryArtistEvent_asc)+', STATE, ID '+AscDesc(SqlQueryArtistEvent_asc)
  else
    result := result + 'order by ' + SqlQueryArtistEvent_order + ' ' + AscDesc(SqlQueryArtistEvent_asc);
end;

function TArtistForm.SqlQueryCommission(const search: string): string;
begin
  if not SqlQueryCommission_Init then
  begin
    SqlQueryCommission_Init := true;
    SqlQueryCommission_order := 'START_DATE';
    SqlQueryCommission_asc := true;
  end;
  result := 'select * ';
  result := result + 'from vw_COMMISSION ';
  result := result + 'where ARTIST_ID = ''' + ArtistId.ToString + ''' ';
  if Trim(search) <> '' then
    result := result + 'and ' + BuildSearchCondition(search, dbgCommission);
  if SqlQueryCommission_order = 'START_DATE' then
    result := result + 'order by isnull(START_DATE,CONVERT(DATETIME, ''31.12.2999'', 104)) '+AscDesc(SqlQueryCommission_asc)+', ID '+AscDesc(SqlQueryCommission_asc)
  else
    result := result + 'order by ' + SqlQueryCommission_order + ' ' + AscDesc(SqlQueryCommission_asc);
end;

function TArtistForm.SqlQueryCommunication(const search: string): string;
begin
  if not SqlQueryCommunication_Init then
  begin
    SqlQueryCommunication_Init := true;
    SqlQueryCommunication_order := 'CHANNEL';
    SqlQueryCommunication_asc := true;
  end;
  result := 'select * ';
  result := result + 'from vw_COMMUNICATION ';
  result := result + 'where ARTIST_ID = ''' + ArtistId.ToString + ''' ';
  if Trim(search) <> '' then
    result := result + 'and ' + BuildSearchCondition(search, dbgCommunication);
  if SqlQueryCommunication_order = 'CHANNEL' then
    result := result + 'order by CHANNEL '+AscDesc(SqlQueryCommunication_asc)+', ADDRESS, ID '+AscDesc(SqlQueryCommunication_asc)
  else
    result := result + 'order by ' + SqlQueryCommunication_order + ' ' + AscDesc(SqlQueryCommunication_asc);
end;

function TArtistForm.SqlQueryPayment(const search: string): string;
begin
  if not SqlQueryPayment_Init then
  begin
    SqlQueryPayment_Init := true;
    SqlQueryPayment_order := 'DATE';
    SqlQueryPayment_asc := true;
  end;
  result := 'select * ';
  result := result + 'from vw_PAYMENT ';
  result := result + 'where ARTIST_ID = ''' + ArtistId.ToString + ''' ';
  if Trim(search) <> '' then
    result := result + 'and ' + BuildSearchCondition(search, dbgPayment);
  if SqlQueryPayment_order = 'DATE' then
    result := result + 'order by DATE '+AscDesc(SqlQueryPayment_asc)+', ID '+AscDesc(SqlQueryPayment_asc)
  else if SqlQueryPayment_order = 'PAYPROV' then
    result := result + 'order by PAYPROV '+AscDesc(SqlQueryPayment_asc)+', DATE'
  else
    result := result + 'order by ' + SqlQueryPayment_order + ' ' + AscDesc(SqlQueryPayment_asc);
end;

procedure TArtistForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  if Assigned(SearchEditSav) then
  begin
    SearchEditSav.Values[PageControl1.ActivePage.Name] := SearchEdit.Text;
  end;
  if PageControl1.ActivePage = tsCommissions then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttCommission.Active := false;
      ttCommission.SQL.Text := SqlQueryCommission(SearchEdit.Text);
      ttCommission.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
  if PageControl1.ActivePage = tsPayment then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttPayment.Active := false;
      ttPayment.SQL.Text := SqlQueryPayment(SearchEdit.Text);
      ttPayment.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
  if PageControl1.ActivePage = tsArtistEvent then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttArtistEvent.Active := false;
      ttArtistEvent.SQL.Text := SqlQueryArtistEvent(SearchEdit.Text);
      ttArtistEvent.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
  if PageControl1.ActivePage = tsCommunication then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttCommunication.Active := false;
      ttCommunication.SQL.Text := SqlQueryCommunication(SearchEdit.Text);
      ttCommunication.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TArtistForm.Timer2Timer(Sender: TObject);
begin
  // https://stackoverflow.com/questions/54401270/when-i-perform-the-ondblclick-event-form1-to-open-form2-it-fires-the-oncellcl
  Timer2.Enabled := false;
  dbgCommission.Enabled := true;
  dbgCommission.Invalidate;
end;

procedure TArtistForm.SearchEditChange(Sender: TObject);
begin
  Timer1.Enabled := false;
  Timer1.Enabled := true;
end;

procedure TArtistForm.SearchEditKeyDown(Sender: TObject; var Key: Word;
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
  else if PageControl1.ActivePage = tsCommissions then
  begin
    dbgCommission.HandleOtherControlKeyDown(Key, Shift);
  end
  else if PageControl1.ActivePage = tsPayment then
  begin
    dbgPayment.HandleOtherControlKeyDown(Key, Shift);
  end
  else if PageControl1.ActivePage = tsArtistEvent then
  begin
    dbgArtistEvent.HandleOtherControlKeyDown(Key, Shift);
  end
  else if PageControl1.ActivePage = tsCommunication then
  begin
    dbgCommunication.HandleOtherControlKeyDown(Key, Shift);
  end;
end;

procedure TArtistForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TArtistForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (ttCommission.State=dsEdit) or ((ttCommission.State=dsInsert) and (ttCommissionNAME.AsWideString<>'')) then
    ttCommission.Post;
  if (ttPayment.State=dsEdit) or ((ttPayment.State=dsInsert) and (ttPaymentAMOUNT.AsWideString<>'')) then
    ttPayment.Post;
  if (ttArtistEvent.State=dsEdit) or ((ttArtistEvent.State=dsInsert) and (ttArtistEventSTATE.AsWideString<>'')) then
    ttArtistEvent.Post;
  if (ttCommunication.State=dsEdit) or ((ttCommunication.State=dsInsert) and ((ttCommunicationCHANNEL.AsWideString<>'') or (ttCommunicationADDRESS.AsWideString<>''))) then
    ttCommunication.Post;
end;

procedure TArtistForm.FormCreate(Sender: TObject);
begin
  SearchEditSav := TStringList.Create;
  PageControl1.ActivePageIndex := 0;
end;

procedure TArtistForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(SearchEditSav);
end;

procedure TArtistForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // We must use FormKeyDown AND FormKeyUp. Why?
  // If we only use FormKeyDown only, then ESC will not only close this window, but also windows below (even if Key:=0 will be performed)
  // If we only use FormKeyUp, we don't get the correct dataset state (since dsEdit,dsInsert got reverted during KeyDown)
  if (Key = VK_ESCAPE) and not (ttCommission.State in [dsEdit,dsInsert])
                       and not (ttPayment.State in [dsEdit,dsInsert])
                       and not (ttArtistEvent.State in [dsEdit,dsInsert])
                       and not (ttCommunication.State in [dsEdit,dsInsert]) then
  begin
    Key := 0;
    Tag := 1; // tell FormKeyUp that we may close
  end;
end;

procedure TArtistForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Tag = 1) then
  begin
    Key := 0;
    Close;
  end;
end;

procedure TArtistForm.GoBackBtnClick(Sender: TObject);
var
  parentId: string;
begin
  parentId := VarToStr(ADOConnection1.GetScalar('select MANDATOR_ID from ARTIST where ID = ''' + ArtistId.ToString + ''''));
  MainForm.OpenDbObject('MANDATOR', StringToGuid(parentId));
end;

procedure TArtistForm.Init;
var
  ttArtist: TAdoDataSet;
  LocalCurrency: string;
resourcestring
  SArtistSforS = 'Artist %s for %s';
  SClientSforS = 'Client %s for %s';
begin
  ttArtist := ADOConnection1.GetTable('select art.NAME, art.IS_ARTIST, man.NAME as MANDATOR_NAME from ARTIST art left join MANDATOR man on man.ID = art.MANDATOR_ID where art.ID = ''' + ArtistId.ToString + '''');
  try
    ArtistName := ttArtist.FieldByName('NAME').AsWideString;
    if ttArtist.FieldByName('IS_ARTIST').AsBoolean then
      Caption := Format(SArtistSforS, [ttArtist.FieldByName('NAME').AsWideString, ttArtist.FieldByName('MANDATOR_NAME').AsWideString])
    else
      Caption := Format(SClientSforS, [ttArtist.FieldByName('NAME').AsWideString, ttArtist.FieldByName('MANDATOR_NAME').AsWideString]);
  finally
    FreeAndNil(ttArtist);
  end;

  LocalCurrency := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''LOCAL_CURRENCY'';'));

  // We cannot use OnShow(), because TForm.Create() calls OnShow(), even if Visible=False
  TitlePanel.Caption := StringReplace(Caption, '&', '&&', [rfReplaceAll]);
  Screen.Cursor := crHourGlass;
  try
    {$REGION 'ttCommission / dbgCommission'}
    ttCommission.Active := false;
    ttCommission.SQL.Text := SqlQueryCommission('');
    ttCommission.Active := true;
    ttCommission.Last;
    dbgCommission.AutoSizeColumns;
    InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbgCommission, navCommission);
    ttCommissionAMOUNT_LOCAL.DisplayFormat := Trim('#,##0.00 ' + LocalCurrency);
    ttCommissionAMOUNT_LOCAL.EditFormat := Trim('#,##0.00');
    {$ENDREGION}
    {$REGION 'ttPayment / dbgPayment'}
    ttPayment.Active := false;
    ttPayment.SQL.Text := SqlQueryPayment('');
    ttPayment.Active := true;
    ttPayment.Last;
    dbgPayment.AutoSizeColumns;
    dbgPayment.Columns[5].PickList.Delimiter := ';';
    dbgPayment.Columns[5].PickList.StrictDelimiter := True;
    dbgPayment.Columns[5].PickList.DelimitedText := VariantToString(ADOConnection1.GetScalar('select VALUE from CONFIG where NAME = ''PICKLIST_PAYPROVIDER'''));
    dbgPayment.Columns[5].DropDownRows := 15;
    InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbgPayment, navPayment);
    ttPaymentAMOUNT_LOCAL.DisplayFormat := Trim('#,##0.00 ' + LocalCurrency);
    ttPaymentAMOUNT_LOCAL.EditFormat := Trim('#,##0.00');
    {$ENDREGION}
    {$REGION 'ttArtistEvent / dbgArtistEvent'}
    ttArtistEvent.Active := false;
    ttArtistEvent.SQL.Text := SqlQueryArtistEvent('');
    ttArtistEvent.Active := true;
    //ttArtistEvent.Last;
    dbgArtistEvent.AutoSizeColumns;
    InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbgArtistEvent, navArtistEvent);
    {$ENDREGION}
    {$REGION 'ttCommunication / dbgCommunication'}
    ttCommunication.Active := false;
    ttCommunication.SQL.Text := SqlQueryCommunication('');
    ttCommunication.Active := true;
    //ttCommunication.First;
    dbgCommunication.AutoSizeColumns;
    dbgCommunication.Columns[0].PickList.Delimiter := ';';
    dbgCommunication.Columns[0].PickList.StrictDelimiter := True;
    dbgCommunication.Columns[0].PickList.DelimitedText := VariantToString(ADOConnection1.GetScalar('select VALUE from CONFIG where NAME = ''PICKLIST_COMMUNICATION'''));
    dbgCommunication.Columns[0].DropDownRows := 15;
    InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbgCommunication, navCommunication);
    {$ENDREGION}
  finally
    Screen.Cursor := crDefault;
  end;

  // https://stackoverflow.com/questions/54401270/when-i-perform-the-ondblclick-event-form1-to-open-form2-it-fires-the-oncellcl
  dbgCommission.Enabled := false;
  Timer2.Enabled := true;
end;

procedure TArtistForm.openCommissionClick(Sender: TObject);
begin
  dbgCommissionDblClick(dbgCommission);
end;

procedure TArtistForm.openCommunicationClick(Sender: TObject);
begin
  dbgCommunicationDblClick(dbgCommunication);
end;

procedure TArtistForm.navArtistEventClick(Sender: TObject;
  Button: TNavigateBtn);
begin
  if Button = nbInsert then
    TDbNavigator(Sender).DataSource.DataSet.Append;
end;

procedure TArtistForm.navCommissionClick(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
    TDbNavigator(Sender).DataSource.DataSet.Append;
end;

procedure TArtistForm.navCommunicationClick(Sender: TObject;
  Button: TNavigateBtn);
begin
  if Button = nbInsert then
    TDbNavigator(Sender).DataSource.DataSet.Append;
end;

procedure TArtistForm.navPaymentClick(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
    TDbNavigator(Sender).DataSource.DataSet.Append;
end;

end.
