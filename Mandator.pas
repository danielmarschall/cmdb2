unit Mandator;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.DBCtrls, Data.Win.ADODB, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls,
  Vcl.StdCtrls;

type
  TMandatorForm = class(TForm)
    ADOConnection1: TADOConnection;
    PageControl1: TPageControl;
    HeadPanel: TPanel;
    SearchEdit: TEdit;
    tsStatistics: TTabSheet;
    SearchBtn: TButton;

    tsClients: TTabSheet;
    navClients: TDBNavigator;
    dbgClients: TDBGrid;
    dsClients: TDataSource;
    ttClients: TADOQuery;
    ttClientsID: TGuidField;
    ttClientsMANDATOR_ID: TGuidField;
    ttClientsNAME: TWideStringField;
    ttClientsAMOUNT_TOTAL_LOCAL: TBCDField;
    ttClientsCOMMISSION_COUNT: TIntegerField;
    ttClientsPAY_STATUS: TWideStringField;
    ttClientsUPLOADS_A: TIntegerField;
    ttClientsUPLOADS_C: TIntegerField;
    ttClientsPROHIBIT_A: TIntegerField;
    ttClientsPROHIBIT_C: TIntegerField;
    ttClientsCOMMISSION_RUNNING: TIntegerField;
    ttClientsUPLOAD_A: TWideStringField;
    ttClientsUPLOAD_C: TWideStringField;
    ttClientsRUN: TWideStringField;

    tsArtists: TTabSheet;
    navArtists: TDBNavigator;
    dbgArtists: TDBGrid;
    dsArtists: TDataSource;
    ttArtists: TADOQuery;
    ttArtistsID: TGuidField;
    ttArtistsMANDATOR_ID: TGuidField;
    ttArtistsNAME: TWideStringField;
    ttArtistsAMOUNT_TOTAL_LOCAL: TBCDField;
    ttArtistsCOMMISSION_COUNT: TIntegerField;
    ttArtistsPAY_STATUS: TWideStringField;
    ttArtistsUPLOADS_A: TIntegerField;
    ttArtistsUPLOADS_C: TIntegerField;
    ttArtistsPROHIBIT_A: TIntegerField;
    ttArtistsPROHIBIT_C: TIntegerField;
    ttArtistsCOMMISSION_RUNNING: TIntegerField;
    ttArtistsUPLOAD_A: TWideStringField;
    ttArtistsUPLOAD_C: TWideStringField;
    ttArtistsRUN: TWideStringField;
    ttArtistsIS_ARTIST: TBooleanField;
    ttClientsIS_ARTIST: TBooleanField;
    navStatistics: TDBNavigator;
    dbgStatistics: TDBGrid;
    ttStatistics: TADOQuery;
    dsStatistics: TDataSource;
    ttStatisticsID: TGuidField;
    ttStatisticsNO: TIntegerField;
    ttStatisticsNAME: TWideStringField;
    tsCommissions: TTabSheet;
    ttCommission: TADOQuery;
    dsCommission: TDataSource;
    dbgCommissions: TDBGrid;
    navCommissions: TDBNavigator;
    ttCommissionID: TGuidField;
    ttCommissionARTIST_ID: TGuidField;
    ttCommissionNAME: TWideStringField;
    ttCommissionFOLDER: TWideStringField;
    ttCommissionPROJECT_NAME: TWideStringField;
    ttCommissionSTART_DATE: TDateTimeField;
    ttCommissionEND_DATE: TDateTimeField;
    ttCommissionART_STATUS: TWideStringField;
    ttCommissionPAY_STATUS: TWideStringField;
    ttCommissionAMOUNT_LOCAL: TBCDField;
    ttCommissionUPLOAD_A: TWideStringField;
    ttCommissionUPLOAD_C: TWideStringField;
    ttCommissionIS_ARTIST: TBooleanField;
    ttCommissionMANDATOR_ID: TGuidField;
    ttCommissionARTIST_NAME: TWideStringField;
    Timer1: TTimer;
    sbArtists: TPanel;
    csvArtists: TButton;
    sbClients: TPanel;
    csvClients: TButton;
    sbCommissions: TPanel;
    csvCommissions: TButton;
    sbStatistics: TPanel;
    csvStatistics: TButton;
    sdCsvArtists: TSaveDialog;
    sdCsvClients: TSaveDialog;
    sdCsvCommission: TSaveDialog;
    sdCsvStatistics: TSaveDialog;
    refreshStatistics: TBitBtn;
    refreshCommissions: TBitBtn;
    refreshClients: TBitBtn;
    refreshArtists: TBitBtn;
    ttArtistsSTATUS: TWideStringField;
    ttClientsSTATUS: TWideStringField;
    tsPayment: TTabSheet;
    sbPayment: TPanel;
    csvPayment: TButton;
    refreshPayment: TBitBtn;
    dbgPayment: TDBGrid;
    navPayment: TDBNavigator;
    ttPayment: TADOQuery;
    ttPaymentID: TGuidField;
    ttPaymentARTIST_ID: TGuidField;
    ttPaymentAMOUNT: TBCDField;
    ttPaymentCURRENCY: TWideStringField;
    ttPaymentDATE: TDateTimeField;
    ttPaymentAMOUNT_LOCAL: TBCDField;
    ttPaymentAMOUNT_VERIFIED: TBooleanField;
    ttPaymentPAYPROV: TWideStringField;
    ttPaymentANNOTATION: TWideStringField;
    dsPayment: TDataSource;
    sdCsvPayment: TSaveDialog;
    ttPaymentARTIST_NAME: TWideStringField;
    ttPaymentMANDATOR_ID: TGuidField;
    ttPaymentIS_ARTIST: TBooleanField;
    ttPaymentARTIST_NAME2: TWideStringField;
    HelpBtn: TButton;
    GoBackBtn: TButton;
    ttStatisticsPLUGIN: TWideStringField;
    Timer2: TTimer;
    ttArtistsLAST_UPDATE_COMMISSION: TDateField;
    ttArtistsLAST_UPDATE_ARTISTEVENT: TDateField;
    ttArtistsLAST_UPDATE: TDateField;
    ttClientsLAST_UPDATE_COMMISSION: TDateField;
    ttClientsLAST_UPDATE_ARTISTEVENT: TDateField;
    ttClientsLAST_UPDATE: TDateField;
    ttArtistsFIRST_UPDATE_COMMISSION: TDateField;
    ttArtistsFIRST_UPDATE_ARTISTEVENT: TDateField;
    ttArtistsFIRST_UPDATE: TDateField;
    ttClientsFIRST_UPDATE_COMMISSION: TDateField;
    ttClientsFIRST_UPDATE_ARTISTEVENT: TDateField;
    ttClientsFIRST_UPDATE: TDateField;
    openArtist: TBitBtn;
    openClients: TBitBtn;
    openCommission: TBitBtn;
    openStatistics: TBitBtn;
    TitlePanel: TPanel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ttArtistsNewRecord(DataSet: TDataSet);
    procedure ttClientsNewRecord(DataSet: TDataSet);
    procedure dbgArtistsDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SearchEditChange(Sender: TObject);
    procedure SearchEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PageControl1Change(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchBtnClick(Sender: TObject);
    procedure ttArtistsUPLOAD_AGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure ttArtistsUPLOAD_CGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure ttArtistsRUNGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure ttClientsUPLOAD_AGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure ttClientsUPLOAD_CGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure ttClientsRUNGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure dbgClientsDblClick(Sender: TObject);
    procedure dbgStatisticsDblClick(Sender: TObject);
    procedure ttStatisticsBeforeInsert(DataSet: TDataSet);
    procedure ttStatisticsBeforeDelete(DataSet: TDataSet);
    procedure ttStatisticsBeforeEdit(DataSet: TDataSet);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ttCommissionBeforeDelete(DataSet: TDataSet);
    procedure ttCommissionBeforeEdit(DataSet: TDataSet);
    procedure ttCommissionBeforeInsert(DataSet: TDataSet);
    procedure dbgCommissionsDblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ttArtistsBeforeDelete(DataSet: TDataSet);
    procedure ttClientsBeforeDelete(DataSet: TDataSet);
    procedure ttArtistsAfterScroll(DataSet: TDataSet);
    procedure ttClientsAfterScroll(DataSet: TDataSet);
    procedure ttCommissionAfterScroll(DataSet: TDataSet);
    procedure ttStatisticsAfterScroll(DataSet: TDataSet);
    procedure dbgArtistsTitleClick(Column: TColumn);
    procedure dbgClientsTitleClick(Column: TColumn);
    procedure dbgCommissionsTitleClick(Column: TColumn);
    procedure dbgStatisticsTitleClick(Column: TColumn);
    procedure csvArtistsClick(Sender: TObject);
    procedure csvClientsClick(Sender: TObject);
    procedure csvCommissionsClick(Sender: TObject);
    procedure csvStatisticsClick(Sender: TObject);
    procedure refreshArtistsClick(Sender: TObject);
    procedure refreshClientsClick(Sender: TObject);
    procedure refreshCommissionsClick(Sender: TObject);
    procedure refreshStatisticsClick(Sender: TObject);
    procedure csvPaymentClick(Sender: TObject);
    procedure refreshPaymentClick(Sender: TObject);
    procedure dbgPaymentTitleClick(Column: TColumn);
    procedure ttPaymentAfterScroll(DataSet: TDataSet);
    procedure ttPaymentBeforeDelete(DataSet: TDataSet);
    procedure ttPaymentBeforeInsert(DataSet: TDataSet);
    procedure HelpBtnClick(Sender: TObject);
    procedure ttPaymentBeforePost(DataSet: TDataSet);
    procedure GoBackBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure dbgArtistsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgClientsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgCommissionsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgPaymentKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgStatisticsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ttPaymentBeforeEdit(DataSet: TDataSet);
    procedure dbgPaymentDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure dbgCommissionsDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ttClientsBeforeEdit(DataSet: TDataSet);
    procedure dbgClientsDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ttArtistsBeforeEdit(DataSet: TDataSet);
    procedure dbgArtistsDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure Timer2Timer(Sender: TObject);
    procedure dbgStatisticsDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ttArtistsBeforePost(DataSet: TDataSet);
    procedure ttClientsBeforePost(DataSet: TDataSet);
    procedure ttArtistsLAST_UPDATEGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure ttClientsLAST_UPDATEGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure ttArtistsFIRST_UPDATEGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure ttClientsFIRST_UPDATEGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure openArtistClick(Sender: TObject);
    procedure openClientsClick(Sender: TObject);
    procedure openCommissionClick(Sender: TObject);
    procedure openStatisticsClick(Sender: TObject);
    procedure navArtistsClick(Sender: TObject; Button: TNavigateBtn);
    procedure navClientsClick(Sender: TObject; Button: TNavigateBtn);
    procedure SearchEditKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    SearchEditSav: TStringList;
    SqlQueryArtistClient_Init: boolean;
    SqlQueryArtistClient_Order: string;
    SqlQueryArtistClient_Asc: boolean;
    SqlQueryCommissions_Init: boolean;
    SqlQueryCommissions_Order: string;
    SqlQueryCommissions_Asc: boolean;
    SqlQueryPayment_Init: boolean;
    SqlQueryPayment_Order: string;
    SqlQueryPayment_Asc: boolean;
    SqlQueryStatistics_Init: boolean;
    SqlQueryStatistics_Order: string;
    SqlQueryStatistics_Asc: boolean;
    function SqlQueryArtistClient(isArtist: boolean; const search: string): string;
    function SqlQueryCommissions(const search: string): string;
    function SqlQueryPayment(const search: string): string;
    function SqlQueryStatistics(const search: string): string;
    procedure DoRefresh(dbg: TDbGrid; const ALocateField: string);
  protected
    MandatorName: string;
  public
    MandatorId: TGUID;
    procedure Init;
  end;

implementation

{$R *.dfm}

uses
  CmDbMain, Artist, Statistics, DbGridHelper, Commission, AdoConnHelper,
  CmDbFunctions, VtsCurConvDLLHeader, CmDbPluginClient, CmDbPluginShare,
  Math, Database;

procedure TMandatorForm.ttArtistsAfterScroll(DataSet: TDataSet);
begin
  sbArtists.Caption := CmDb_ShowRows(DataSet)+'   ';
end;

procedure TMandatorForm.ttArtistsBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeDelete(Dataset as TAdoQuery, 'ID', 'ARTIST', 'ID');
end;

procedure TMandatorForm.ttArtistsBeforeEdit(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeEdit(Dataset as TAdoQuery, 'ID');
end;

procedure TMandatorForm.ttArtistsBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('NAME').AsWideString := Trim(DataSet.FieldByName('NAME').AsWideString);
end;

procedure TMandatorForm.ttArtistsLAST_UPDATEGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  if Sender.DataSet.FieldByName('LAST_UPDATE_COMMISSION').AsDateTime >
     Sender.DataSet.FieldByName('LAST_UPDATE_ARTISTEVENT').AsDateTime then
  begin
    if Sender.DataSet.FieldByName('LAST_UPDATE_COMMISSION').IsNull then
      Text := ''
    else
      Text := DateToStr(Sender.DataSet.FieldByName('LAST_UPDATE_COMMISSION').AsDateTime);
  end
  else
  begin
    if Sender.DataSet.FieldByName('LAST_UPDATE_ARTISTEVENT').IsNull then
      Text := ''
    else
      Text := DateToStr(Sender.DataSet.FieldByName('LAST_UPDATE_ARTISTEVENT').AsDateTime);
  end;
end;

procedure TMandatorForm.ttArtistsFIRST_UPDATEGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  if Sender.DataSet.FieldByName('FIRST_UPDATE_COMMISSION').AsDateTime >
     Sender.DataSet.FieldByName('FIRST_UPDATE_ARTISTEVENT').AsDateTime then
  begin
    if Sender.DataSet.FieldByName('FIRST_UPDATE_COMMISSION').IsNull then
      Text := ''
    else
      Text := DateToStr(Sender.DataSet.FieldByName('FIRST_UPDATE_COMMISSION').AsDateTime);
  end
  else
  begin
    if Sender.DataSet.FieldByName('FIRST_UPDATE_ARTISTEVENT').IsNull then
      Text := ''
    else
      Text := DateToStr(Sender.DataSet.FieldByName('FIRST_UPDATE_ARTISTEVENT').AsDateTime);
  end;
end;

procedure TMandatorForm.ttArtistsNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := ADOConnection1.NewSeqGuid;
  DataSet.FieldByName('MANDATOR_ID').AsGuid := MandatorId;
  DataSet.FieldByName('IS_ARTIST').AsBoolean := true;
end;

procedure TMandatorForm.ttClientsAfterScroll(DataSet: TDataSet);
begin
  sbClients.Caption := CmDb_ShowRows(DataSet)+'   ';
end;

procedure TMandatorForm.ttClientsBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeDelete(Dataset as TAdoQuery, 'ID', 'ARTIST', 'ID');
end;

procedure TMandatorForm.ttClientsBeforeEdit(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeEdit(Dataset as TAdoQuery, 'ID');
end;

procedure TMandatorForm.ttClientsBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('NAME').AsWideString := Trim(DataSet.FieldByName('NAME').AsWideString);
end;

procedure TMandatorForm.ttClientsLAST_UPDATEGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  if Sender.DataSet.FieldByName('LAST_UPDATE_COMMISSION').AsDateTime >
     Sender.DataSet.FieldByName('LAST_UPDATE_ARTISTEVENT').AsDateTime then
  begin
    if Sender.DataSet.FieldByName('LAST_UPDATE_COMMISSION').IsNull then
      Text := ''
    else
      Text := DateToStr(Sender.DataSet.FieldByName('LAST_UPDATE_COMMISSION').AsDateTime);
  end
  else
  begin
    if Sender.DataSet.FieldByName('LAST_UPDATE_ARTISTEVENT').IsNull then
      Text := ''
    else
      Text := DateToStr(Sender.DataSet.FieldByName('LAST_UPDATE_ARTISTEVENT').AsDateTime);
  end;
end;

procedure TMandatorForm.ttClientsFIRST_UPDATEGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  if Sender.DataSet.FieldByName('FIRST_UPDATE_COMMISSION').AsDateTime >
     Sender.DataSet.FieldByName('FIRST_UPDATE_ARTISTEVENT').AsDateTime then
  begin
    if Sender.DataSet.FieldByName('FIRST_UPDATE_COMMISSION').IsNull then
      Text := ''
    else
      Text := DateToStr(Sender.DataSet.FieldByName('FIRST_UPDATE_COMMISSION').AsDateTime);
  end
  else
  begin
    if Sender.DataSet.FieldByName('FIRST_UPDATE_ARTISTEVENT').IsNull then
      Text := ''
    else
      Text := DateToStr(Sender.DataSet.FieldByName('FIRST_UPDATE_ARTISTEVENT').AsDateTime);
  end;
end;

procedure TMandatorForm.ttClientsNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := ADOConnection1.NewSeqGuid;
  DataSet.FieldByName('MANDATOR_ID').AsGuid := MandatorId;
  DataSet.FieldByName('IS_ARTIST').AsBoolean := false;
end;

procedure TMandatorForm.ttArtistsRUNGetText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  Text := IntToStr(ttArtistsCOMMISSION_RUNNING.AsInteger) +
    '/' + IntToStr(ttArtistsCOMMISSION_COUNT.AsInteger);
end;

procedure TMandatorForm.ttClientsRUNGetText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  Text := IntToStr(ttClientsCOMMISSION_RUNNING.AsInteger) +
    '/' + IntToStr(ttClientsCOMMISSION_COUNT.AsInteger);
end;

procedure TMandatorForm.ttArtistsUPLOAD_AGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  Text := IntToStr(ttArtistsUPLOADS_A.AsInteger) +
    '/' + IntToStr(ttArtistsCOMMISSION_COUNT.AsInteger
    - ttArtistsPROHIBIT_A.AsInteger);
end;

procedure TMandatorForm.ttClientsUPLOAD_AGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  Text := IntToStr(ttClientsUPLOADS_A.AsInteger) +
    '/' + IntToStr(ttClientsCOMMISSION_COUNT.AsInteger
    - ttClientsPROHIBIT_A.AsInteger);
end;

procedure TMandatorForm.ttArtistsUPLOAD_CGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  Text := IntToStr(ttArtistsUPLOADS_C.AsInteger) +
    '/' + IntToStr(ttArtistsCOMMISSION_COUNT.AsInteger
    - ttArtistsPROHIBIT_C.AsInteger);
end;

procedure TMandatorForm.ttClientsUPLOAD_CGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  Text := IntToStr(ttClientsUPLOADS_C.AsInteger) +
    '/' + IntToStr(ttClientsCOMMISSION_COUNT.AsInteger
    - ttClientsPROHIBIT_C.AsInteger);
end;

procedure TMandatorForm.ttCommissionAfterScroll(DataSet: TDataSet);
begin
  sbCommissions.Caption := CmDb_ShowRows(DataSet)+'   ';
end;

procedure TMandatorForm.ttCommissionBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeDelete(Dataset as TAdoQuery, 'ID', 'COMMISSION', 'ID');
end;

procedure TMandatorForm.ttCommissionBeforeEdit(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeEdit(Dataset as TAdoQuery, 'ID');
end;

procedure TMandatorForm.ttCommissionBeforeInsert(DataSet: TDataSet);
begin
  Abort;
end;

procedure TMandatorForm.ttPaymentAfterScroll(DataSet: TDataSet);
begin
  sbPayment.Caption := CmDb_ShowRows(DataSet)+'   ';
end;

procedure TMandatorForm.ttPaymentBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeDelete(Dataset as TAdoQuery, 'ID', 'PAYMENT', 'ID');
end;

procedure TMandatorForm.ttPaymentBeforeEdit(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeEdit(Dataset as TAdoQuery, 'ID');
end;

procedure TMandatorForm.ttPaymentBeforeInsert(DataSet: TDataSet);
begin
  Abort;
end;

procedure TMandatorForm.ttPaymentBeforePost(DataSet: TDataSet);
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
  if Length(ttPaymentCURRENCY.AsWideString) <> 3 then
    raise Exception.Create(SInvalidCurrency)
  else
    ttPaymentCURRENCY.AsWideString := ttPaymentCURRENCY.AsWideString.ToUpper;

  LocalCurrency := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''LOCAL_CURRENCY'';'));

  if ttPaymentAMOUNT_VERIFIED.IsNull then
    ttPaymentAMOUNT_VERIFIED.AsBoolean := False;

  // Note: Do not use NewValue, because it is null when a record is inserted!

  if ttPaymentAMOUNT.IsNull then
  begin
    ttPaymentAMOUNT_LOCAL.Clear;
  end
  else if not ttPaymentAMOUNT_VERIFIED.AsBoolean and
          (
            (CompareValue(VariantToFloat(ttPaymentAMOUNT.OldValue), ttPaymentAMOUNT.AsFloat) <> 0) //(VarCompareValue(ttPaymentAMOUNT.OldValue, ttPaymentAMOUNT.NewValue) <> vrEqual)
            or
            not SameText(VariantToString(ttPaymentCURRENCY.OldValue), ttPaymentCURRENCY.AsWideString) // (VarCompareValue(ttQuotesCURRENCY.OldValue, ttQuotesCURRENCY.NewValue) <> vrEqual)
          )
          and SameText(ttPaymentCURRENCY.AsWideString, LocalCurrency) then
  begin
    // Note: do not set AMOUNT_VERIFIED=1, because there might be additional fees beside the conversion
    ttPaymentAMOUNT_LOCAL.AsFloat := ttPaymentAMOUNT.AsFloat;
    ttPaymentAMOUNT_VERIFIED.AsBoolean := False;
  end
  else if not ttPaymentAMOUNT_VERIFIED.AsBoolean and
          (
            (CompareValue(VariantToFloat(ttPaymentAMOUNT.OldValue), ttPaymentAMOUNT.AsFloat) <> 0) // (VarCompareValue(ttPaymentAMOUNT.OldValue, ttPaymentAMOUNT.NewValue) <> vrEqual)
            or
            not SameText(VariantToString(ttPaymentCURRENCY.OldValue), ttPaymentCURRENCY.AsWideString) // (VarCompareValue(ttQuotesCURRENCY.OldValue, ttQuotesCURRENCY.NewValue) <> vrEqual)
          )
          and (CompareValue(VariantToFloat(ttPaymentAMOUNT_LOCAL.OldValue), ttPaymentAMOUNT_LOCAL.AsFloat) = 0) // (VarCompareValue(ttPaymentAMOUNT_LOCAL.OldValue, ttPaymentAMOUNT_LOCAL.NewValue) = vrEqual)
          and (Length(ttPaymentCURRENCY.AsWideString)=3) then
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

procedure TMandatorForm.ttStatisticsAfterScroll(DataSet: TDataSet);
begin
  sbStatistics.Caption := CmDb_ShowRows(DataSet)+'   ';
end;

procedure TMandatorForm.ttStatisticsBeforeDelete(DataSet: TDataSet);
resourcestring
  SDeleteNotPossible = 'Delete not possible';
begin
  raise Exception.Create(SDeleteNotPossible);
end;

procedure TMandatorForm.ttStatisticsBeforeEdit(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround_BeforeEdit(Dataset as TAdoQuery, 'ID');
end;

procedure TMandatorForm.ttStatisticsBeforeInsert(DataSet: TDataSet);
begin
  Abort;
end;

procedure TMandatorForm.SearchBtnClick(Sender: TObject);
begin
  if SearchEdit.Text <> '' then
    SearchEdit.Clear;
  if SearchEdit.CanFocus then
    SearchEdit.SetFocus;
end;

procedure TMandatorForm.HelpBtnClick(Sender: TObject);
begin
  MainForm.ShowHelpWindow('HELP_MandatorWindow.md');
end;

procedure TMandatorForm.csvArtistsClick(Sender: TObject);
begin
  if sdCsvArtists.Execute then
    SaveGridToCsv(dbgArtists, sdCsvArtists.FileName);
end;

procedure TMandatorForm.csvClientsClick(Sender: TObject);
begin
  if sdCsvClients.Execute then
    SaveGridToCsv(dbgClients, sdCsvClients.FileName);
end;

procedure TMandatorForm.csvCommissionsClick(Sender: TObject);
begin
  if sdCsvCommission.Execute then
    SaveGridToCsv(dbgCommissions, sdCsvCommission.FileName);
end;

procedure TMandatorForm.csvPaymentClick(Sender: TObject);
begin
  if sdCsvPayment.Execute then
    SaveGridToCsv(dbgPayment, sdCsvPayment.FileName);
end;

procedure TMandatorForm.csvStatisticsClick(Sender: TObject);
begin
  if sdCsvStatistics.Execute then
    SaveGridToCsv(dbgStatistics, sdCsvStatistics.FileName);
end;

procedure TMandatorForm.dbgArtistsDblClick(Sender: TObject);
begin
  if ttArtists.State in [dsEdit,dsInsert] then ttArtists.Post;
  if ttArtists.FieldByName('ID').IsNull then begin Beep; Exit; end;
  MainForm.OpenDbObject('ARTIST', ttArtists.FieldByName('ID').AsGuid);
end;

procedure TMandatorForm.dbgArtistsDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'ID');
end;

procedure TMandatorForm.dbgArtistsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F5) and (Shift = []) then
  begin
    Key := 0;
    Screen.Cursor := crHourGlass;
    try
      DoRefresh(dbgArtists, 'ID');
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

procedure TMandatorForm.dbgArtistsTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryArtistClient_Order := Column.FieldName;
    SqlQueryArtistClient_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryArtistClient(true, SearchEdit.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.dbgClientsDblClick(Sender: TObject);
begin
  if ttClients.State in [dsEdit,dsInsert] then ttClients.Post;
  if ttClients.FieldByName('ID').IsNull then begin Beep; Exit; end;
  MainForm.OpenDbObject('ARTIST', ttClients.FieldByName('ID').AsGuid);
end;

procedure TMandatorForm.dbgClientsDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'ID');
end;

procedure TMandatorForm.dbgClientsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F5) and (Shift = []) then
  begin
    Key := 0;
    Screen.Cursor := crHourGlass;
    try
      DoRefresh(dbgClients, 'ID');
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

procedure TMandatorForm.dbgClientsTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryArtistClient_Order := Column.FieldName;
    SqlQueryArtistClient_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryArtistClient(false, SearchEdit.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.dbgCommissionsDblClick(Sender: TObject);
begin
  if ttCommission.State in [dsEdit,dsInsert] then ttCommission.Post;
  if ttCommission.FieldByName('ID').IsNull then begin Beep; Exit; end;
  MainForm.OpenDbObject('COMMISSION', ttCommission.FieldByName('ID').AsGuid);
end;

procedure TMandatorForm.dbgCommissionsDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'ID');
end;

procedure TMandatorForm.dbgCommissionsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F5) and (Shift = []) then
  begin
    Key := 0;
    Screen.Cursor := crHourGlass;
    try
      DoRefresh(dbgCommissions, 'ID');
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TMandatorForm.dbgCommissionsTitleClick(Column: TColumn);
var
  ds: TAdoQuery;
begin
  Screen.Cursor := crHourGlass;
  try
    SqlQueryCommissions_Order := Column.FieldName;
    SqlQueryCommissions_Asc := TitleButtonHelper(Column);
    ds := Column.Grid.DataSource.DataSet as TAdoQuery;
    ds.Active := false;
    ds.SQL.Text := SqlQueryCommissions(SearchEdit.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.dbgPaymentDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'ID');
end;

procedure TMandatorForm.dbgPaymentKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F5) and (Shift = []) then
  begin
    Key := 0;
    Screen.Cursor := crHourGlass;
    try
      DoRefresh(dbgPayment, 'ID');
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TMandatorForm.dbgPaymentTitleClick(Column: TColumn);
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

procedure TMandatorForm.dbgStatisticsDblClick(Sender: TObject);
var
  resp: TCmDbPluginClickResponse;
begin
  if ttStatistics.State in [dsEdit,dsInsert] then ttStatistics.Post;
  if ttStatistics.FieldByName('ID').IsNull then begin Beep; Exit; end;

  Screen.Cursor := crHourGlass;
  try
    resp := TCmDbPluginClient.ClickEvent(AdoConnection1, MandatorId, ttStatistics.FieldByName('ID').AsGuid, GUID_ORIGIN_MANDATOR);
    HandleClickResponse(AdoConnection1, MandatorId, resp);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.dbgStatisticsDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  InsteadOfDeleteWorkaround_DrawColumnCell(Sender, Rect, DataCol, Column, State, 'ID');
end;

procedure TMandatorForm.DoRefresh(dbg: TDbGrid; const ALocateField: string);
begin
  AdoQueryRefresh(dbg.DataSource.DataSet as TAdoQuery, ALocateField);
  dbg.AutoSizeColumns;
end;

procedure TMandatorForm.dbgStatisticsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F5) and (Shift = []) then
  begin
    Key := 0;
    Screen.Cursor := crHourGlass;
    try
      DoRefresh(dbgStatistics, 'ID');
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TMandatorForm.dbgStatisticsTitleClick(Column: TColumn);
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
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.PageControl1Change(Sender: TObject);
begin
  if Assigned(SearchEditSav) then
    SearchEdit.Text := SearchEditSav.Values[TPageControl(Sender).ActivePage.Name]
  else
    SearchEdit.Text := '';
  Timer1.Enabled := False;
end;

procedure TMandatorForm.refreshArtistsClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    DoRefresh(dbgArtists, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.refreshClientsClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    DoRefresh(dbgClients, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.refreshCommissionsClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    DoRefresh(dbgCommissions, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.refreshPaymentClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    DoRefresh(dbgPayment, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.refreshStatisticsClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    DoRefresh(dbgStatistics, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TMandatorForm.SqlQueryArtistClient(isArtist: boolean; const search: string): string;
begin
  if not SqlQueryArtistClient_Init then
  begin
    SqlQueryArtistClient_Init := true;
    SqlQueryArtistClient_order := 'NAME';
    SqlQueryArtistClient_asc := true;
  end;
  result := 'select * from vw_ARTIST ';
  result := result + 'where MANDATOR_ID = ''' + MandatorId.ToString + ''' ';
  if Trim(search) <> '' then
  begin
    if isArtist then
      result := result + 'and ' + BuildSearchCondition(search, dbgArtists)
    else
      result := result + 'and ' + BuildSearchCondition(search, dbgClients);
  end;
  if isArtist then
    result := result + 'and IS_ARTIST = 1 '
  else
    result := result + 'and IS_ARTIST = 0 ';
  if SqlQueryArtistClient_order = 'RUNNING' then
    result := result + 'order by COMMISSION_RUNNING ' + AscDesc(SqlQueryArtistClient_asc) + ', COMMISSION_COUNT'
  else if SqlQueryArtistClient_order = 'UPLOAD_A' then
    result := result + 'order by UPLOADS_A ' + AscDesc(SqlQueryArtistClient_asc) + ', COMMISSION_COUNT'
  else if SqlQueryArtistClient_order = 'UPLOAD_C' then
    result := result + 'order by UPLOADS_C ' + AscDesc(SqlQueryArtistClient_asc) + ', COMMISSION_COUNT'
  else if SqlQueryArtistClient_order = 'LAST_UPDATE' then
    result := result + 'order by iif(isnull(LAST_UPDATE_COMMISSION,0)>isnull(LAST_UPDATE_ARTISTEVENT,0),isnull(LAST_UPDATE_COMMISSION,0),isnull(LAST_UPDATE_ARTISTEVENT,0)) ' + AscDesc(SqlQueryArtistClient_asc)
  else if SqlQueryArtistClient_order = 'FIRST_UPDATE' then
    result := result + 'order by iif(isnull(FIRST_UPDATE_COMMISSION,0)>isnull(FIRST_UPDATE_ARTISTEVENT,0),isnull(FIRST_UPDATE_COMMISSION,0),isnull(FIRST_UPDATE_ARTISTEVENT,0)) ' + AscDesc(SqlQueryArtistClient_asc)
  else
    result := result + 'order by ' + SqlQueryArtistClient_order + ' ' + AscDesc(SqlQueryArtistClient_asc);
end;

function TMandatorForm.SqlQueryCommissions(const search: string): string;
begin
  if not SqlQueryCommissions_Init then
  begin
    SqlQueryCommissions_Init := true;
    SqlQueryCommissions_order := 'START_DATE';
    SqlQueryCommissions_asc := true;
  end;
  result := 'select * from vw_COMMISSION ';
  result := result + 'where MANDATOR_ID = ''' + MandatorId.ToString + ''' ';
  if Trim(search) <> '' then
    result := result + 'and ' + BuildSearchCondition(search, dbgCommissions);
  if SqlQueryCommissions_order = 'START_DATE' then
    result := result + 'order by START_DATE '+AscDesc(SqlQueryCommissions_asc)+', ID '+AscDesc(SqlQueryCommissions_asc)
  else
    result := result + 'order by ' + SqlQueryCommissions_order + ' ' + AscDesc(SqlQueryCommissions_asc);
end;

function TMandatorForm.SqlQueryPayment(const search: string): string;
begin
  if not SqlQueryPayment_Init then
  begin
    SqlQueryPayment_Init := true;
    SqlQueryPayment_order := 'DATE';
    SqlQueryPayment_asc := true;
  end;
  result := 'select * from vw_PAYMENT ';
  result := result + 'where MANDATOR_ID = ''' + MandatorId.ToString + ''' ';
  if Trim(search) <> '' then
    result := result + 'and ' + BuildSearchCondition(search, dbgPayment);
  if SqlQueryPayment_order = 'DATE' then
    result := result + 'order by DATE '+AscDesc(SqlQueryPayment_asc)+', PAYPROV, ARTIST_OR_CLIENT_NAME'
  else if SqlQueryPayment_order = 'PAYPROV' then
    result := result + 'order by PAYPROV '+AscDesc(SqlQueryPayment_asc)+', DATE, ARTIST_OR_CLIENT_NAME'
  else if SqlQueryPayment_order = 'ARTIST_OR_CLIENT_NAME' then
    result := result + 'order by ARTIST_OR_CLIENT_NAME '+AscDesc(SqlQueryPayment_asc)+', DATE, PAYPROV'
  else
    result := result + 'order by ' + SqlQueryPayment_order + ' ' + AscDesc(SqlQueryPayment_asc);
end;

function TMandatorForm.SqlQueryStatistics(const search: string): string;
begin
  if not SqlQueryStatistics_Init then
  begin
    SqlQueryStatistics_Init := true;
    SqlQueryStatistics_order := 'PLUGIN';
    SqlQueryStatistics_asc := true;
  end;
  result := 'select * from vw_STATISTICS ';
  if Trim(search) <> '' then
    result := result + 'where ' + BuildSearchCondition(search, dbgStatistics);
  if SqlQueryStatistics_order = 'NO' then
    result := result + 'order by NO '+AscDesc(SqlQueryStatistics_asc)+', PLUGIN, NAME'
  else if SqlQueryStatistics_order = 'PLUGIN' then
    result := result + 'order by PLUGIN '+AscDesc(SqlQueryStatistics_asc)+', NO, NAME'
  else
    result := result + 'order by ' + SqlQueryStatistics_order + ' ' + AscDesc(SqlQueryStatistics_asc);
end;

procedure TMandatorForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  if Assigned(SearchEditSav) then
  begin
    SearchEditSav.Values[PageControl1.ActivePage.Name] := SearchEdit.Text;
  end;
  if PageControl1.ActivePage = tsArtists then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttArtists.Active := false;
      ttArtists.SQL.Text := SqlQueryArtistClient(true, SearchEdit.Text);
      ttArtists.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
  if PageControl1.ActivePage = tsClients then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttClients.Active := false;
      ttClients.SQL.Text := SqlQueryArtistClient(false, SearchEdit.Text);
      ttClients.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
  if PageControl1.ActivePage = tsCommissions then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttCommission.Active := false;
      ttCommission.SQL.Text := SqlQueryCommissions(SearchEdit.Text);
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
  if PageControl1.ActivePage = tsStatistics then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttStatistics.Active := false;
      ttStatistics.SQL.Text := SqlQueryStatistics(SearchEdit.Text);
      ttStatistics.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TMandatorForm.Timer2Timer(Sender: TObject);
begin
  // https://stackoverflow.com/questions/54401270/when-i-perform-the-ondblclick-event-form1-to-open-form2-it-fires-the-oncellcl
  Timer2.Enabled := false;
  dbgArtists.Enabled := true;
  dbgartists.Invalidate;
end;

procedure TMandatorForm.SearchEditChange(Sender: TObject);
begin
  Timer1.Enabled := false;
  Timer1.Enabled := true;
end;

procedure TMandatorForm.SearchEditKeyDown(Sender: TObject; var Key: Word;
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
  else if PageControl1.ActivePage = tsArtists then
  begin
    dbgArtists.HandleOtherControlKeyDown(Key, Shift);
  end
  else if PageControl1.ActivePage = tsClients then
  begin
    dbgClients.HandleOtherControlKeyDown(Key, Shift);
  end
  else if PageControl1.ActivePage = tsCommissions then
  begin
    dbgCommissions.HandleOtherControlKeyDown(Key, Shift);
  end
  else if PageControl1.ActivePage = tsStatistics then
  begin
    dbgStatistics.HandleOtherControlKeyDown(Key, Shift);
  end;
  if Key = 0 then SearchEdit.Tag := 1; // avoid "Ding" sound
end;

procedure TMandatorForm.SearchEditKeyPress(Sender: TObject; var Key: Char);
begin
  if SearchEdit.Tag = 1 then
  begin
    Key := #0; // avoid "Ding" sound
    SearchEdit.Tag := 0;
  end;
end;

procedure TMandatorForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMandatorForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (ttArtists.State=dsEdit) or ((ttArtists.State=dsInsert) and (ttArtistsNAME.AsWideString<>'')) then
    ttArtists.Post;
  if (ttClients.State=dsEdit) or ((ttClients.State=dsInsert) and (ttClientsNAME.AsWideString<>'')) then
    ttClients.Post;
  if (ttCommission.State=dsEdit) then
    ttCommission.Post;
  if (ttPayment.State=dsEdit) then
    ttPayment.Post;
  if (ttStatistics.State=dsEdit) then
    ttStatistics.Post;
end;

procedure TMandatorForm.FormCreate(Sender: TObject);
begin
  SearchEditSav := TStringList.Create;
  PageControl1.ActivePageIndex := 0;
end;

procedure TMandatorForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(SearchEditSav);
end;

procedure TMandatorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // We must use FormKeyDown AND FormKeyUp. Why?
  // If we only use FormKeyDown only, then ESC will not only close this window, but also windows below (even if Key:=0 will be performed)
  // If we only use FormKeyUp, we don't get the correct dataset state (since dsEdit,dsInsert got reverted during KeyDown)
  if (Key = VK_ESCAPE) and (Shift = []) and
    not (ttArtists.State in [dsEdit,dsInsert]) and
    not (ttClients.State in [dsEdit,dsInsert]) and
    not (ttCommission.State in [dsEdit,dsInsert]) and
    not (ttPayment.State in [dsEdit,dsInsert]) and
    not (ttStatistics.State in [dsEdit,dsInsert]) then
  begin
    Key := 0;
    Tag := 1; // tell FormKeyUp that we may close
  end;
end;

procedure TMandatorForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Tag = 1 then
  begin
    Key := #0; // avoid "Ding" sound
  end;
end;

procedure TMandatorForm.FormKeyUp(Sender: TObject; var Key: Word;
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

procedure TMandatorForm.GoBackBtnClick(Sender: TObject);
var
  DatabaseForm: TDatabaseForm;
begin
  DatabaseForm := MainForm.OpenDatabaseForm as TDatabaseForm;
  if Assigned(DatabaseForm) then
  begin
    DatabaseForm.PageControl1.ActivePage := DatabaseForm.tsMandator;
    DatabaseForm.ttMandator.Locate('ID', MandatorId.ToString, []);
  end;
end;

procedure TMandatorForm.Init;
resourcestring
  SMandatorS = 'Mandator %s';
var
  ttMandator: TAdoDataSet;
  LocalCurrency: string;
begin
  ttMandator := ADOConnection1.GetTable('select * from MANDATOR where ID = ''' + MandatorId.ToString + '''');
  try
    MandatorName := ttMandator.FieldByName('NAME').AsWideString;
    Caption := Format(SMandatorS, [ttMandator.FieldByName('NAME').AsWideString]);
  finally
    FreeAndNil(ttMandator);
  end;

  LocalCurrency := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''LOCAL_CURRENCY'';'));

  // We cannot use OnShow(), because TForm.Create() calls OnShow(), even if Visible=False
  TitlePanel.Caption := StringReplace(Caption, '&', '&&', [rfReplaceAll]);
  Screen.Cursor := crHourGlass;
  try
    {$REGION 'ttArtists / dbgArtists'}
    ttArtists.Active := false;
    ttArtists.SQL.Text := SqlQueryArtistClient(true, '');
    ttArtists.Active := true;
    dbgArtists.AutoSizeColumns;
    InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbgArtists, navArtists);
    ttArtistsAMOUNT_TOTAL_LOCAL.DisplayFormat := Trim('#,##0.00 ' + LocalCurrency);
    ttArtistsAMOUNT_TOTAL_LOCAL.EditFormat := Trim('#,##0.00');
    {$ENDREGION}
    {$REGION 'ttClients / dbgClients'}
    ttClients.Active := false;
    ttClients.SQL.Text := SqlQueryArtistClient(false, '');
    ttClients.Active := true;
    dbgClients.AutoSizeColumns;
    InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbgClients, navClients);
    ttClientsAMOUNT_TOTAL_LOCAL.DisplayFormat := Trim('#,##0.00 ' + LocalCurrency);
    ttClientsAMOUNT_TOTAL_LOCAL.EditFormat := Trim('#,##0.00');
    {$ENDREGION}
    {$REGION 'ttCommission / dbgCommissions'}
    ttCommission.Active := false;
    ttCommission.SQL.Text := SqlQueryCommissions('');
    ttCommission.Active := true;
    ttCommission.Last;
    dbgCommissions.AutoSizeColumns;
    InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbgCommissions, navCommissions);
    ttCommissionAMOUNT_LOCAL.DisplayFormat := Trim('#,##0.00 ' + LocalCurrency);
    ttCommissionAMOUNT_LOCAL.EditFormat := Trim('#,##0.00');
    {$ENDREGION}
    {$REGION 'ttPayment / dbgPayment'}
    ttPayment.Active := false;
    ttPayment.SQL.Text := SqlQueryPayment('');
    ttPayment.Active := true;
    ttPayment.Last;
    dbgPayment.AutoSizeColumns;
    dbgPayment.Columns[6].PickList.Delimiter := ';';
    dbgPayment.Columns[6].PickList.StrictDelimiter := True;
    dbgPayment.Columns[6].PickList.DelimitedText := VariantToString(ADOConnection1.GetScalar('select VALUE from CONFIG where NAME = ''PICKLIST_PAYPROVIDER'''));
    dbgPayment.Columns[6].DropDownRows := 15;
    InsteadOfDeleteWorkaround_PrepareDeleteOptions(dbgPayment, navPayment);
    ttPaymentAMOUNT_LOCAL.DisplayFormat := Trim('#,##0.00 ' + LocalCurrency);
    ttPaymentAMOUNT_LOCAL.EditFormat := Trim('#,##0.00');
    {$ENDREGION}
    {$REGION 'ttStatistics / dbgStatistics'}
    TCmDbPluginClient.InitAllPlugins(AdoConnection1); // re-fills STATISTICS from plugins
    ttStatistics.Active := false;
    ttStatistics.SQL.Text := SqlQueryStatistics('');
    ttStatistics.Active := true;
    dbgStatistics.AutoSizeColumns;
    {$ENDREGION}
  finally
    Screen.Cursor := crDefault;
  end;

  if (ttArtists.RecordCount = 0) and (ttClients.RecordCount > 0) then
    PageControl1.ActivePage := tsClients
  else
    PageControl1.ActivePage := tsArtists;

  // https://stackoverflow.com/questions/54401270/when-i-perform-the-ondblclick-event-form1-to-open-form2-it-fires-the-oncellcl
  dbgArtists.Enabled := false;
  Timer2.Enabled := true;
end;

procedure TMandatorForm.openArtistClick(Sender: TObject);
begin
  dbgArtistsDblClick(dbgArtists);
end;

procedure TMandatorForm.openClientsClick(Sender: TObject);
begin
  dbgClientsDblClick(dbgClients);
end;

procedure TMandatorForm.openCommissionClick(Sender: TObject);
begin
  dbgCommissionsDblClick(dbgCommissions);
end;

procedure TMandatorForm.openStatisticsClick(Sender: TObject);
begin
  dbgStatisticsDblClick(dbgStatistics);
end;

procedure TMandatorForm.navArtistsClick(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
    TDbNavigator(Sender).DataSource.DataSet.Append;
end;

procedure TMandatorForm.navClientsClick(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
    TDbNavigator(Sender).DataSource.DataSet.Append;
end;

end.
