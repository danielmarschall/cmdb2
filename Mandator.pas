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
    Panel1: TPanel;
    Edit1: TEdit;
    tsStatistics: TTabSheet;
    Button1: TButton;

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
    ttStatisticsSQL_VIEW: TWideStringField;
    ttStatisticsSQL_ORDER: TWideStringField;
    tsCommissions: TTabSheet;
    ttCommission: TADOQuery;
    dsCommission: TDataSource;
    dbgCommissions: TDBGrid;
    navCommissions: TDBNavigator;
    ttCommissionID: TGuidField;
    ttCommissionARTIST_ID: TGuidField;
    ttCommissionNAME: TWideStringField;
    ttCommissionLEGACY_ID: TIntegerField;
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ttArtistsNewRecord(DataSet: TDataSet);
    procedure ttClientsNewRecord(DataSet: TDataSet);
    procedure dbgArtistsDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PageControl1Change(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
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
    procedure ttArtistsAMOUNT_TOTAL_LOCALGetText(Sender: TField;
      var Text: string; DisplayText: Boolean);
    procedure ttClientsAMOUNT_TOTAL_LOCALGetText(Sender: TField;
      var Text: string; DisplayText: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ttCommissionBeforeDelete(DataSet: TDataSet);
    procedure ttCommissionBeforeEdit(DataSet: TDataSet);
    procedure ttCommissionBeforeInsert(DataSet: TDataSet);
    procedure dbgCommissionsDblClick(Sender: TObject);
    procedure ttCommissionAMOUNT_LOCALGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
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
  private
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
  public
    MandatorId: TGUID;
    MandatorName: string;
    procedure Init;
  end;

implementation

{$R *.dfm}

uses
  CmDbMain, Artist, Statistics, DbGridHelper, Commission, AdoConnHelper, CmDbFunctions;

var
  localCur: string;

procedure TMandatorForm.ttArtistsAfterScroll(DataSet: TDataSet);
begin
  sbArtists.Caption := CmDbShowRows(DataSet);
end;

procedure TMandatorForm.ttArtistsAMOUNT_TOTAL_LOCALGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  if localCur = '' then
    localCur := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''LOCAL_CURRENCY'';'));
  Text := FormatFloat('#,##0.00', Sender.AsFloat) + ' ' + localCur;
end;

procedure TMandatorForm.ttArtistsBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround(DataSet as TAdoQuery, 'ID', 'ARTIST', 'ID');
end;

procedure TMandatorForm.ttArtistsNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := TGUID.NewGuid;
  DataSet.FieldByName('MANDATOR_ID').AsGuid := MandatorId;
  DataSet.FieldByName('IS_ARTIST').AsBoolean := true;
end;

procedure TMandatorForm.ttClientsAfterScroll(DataSet: TDataSet);
begin
  sbClients.Caption := CmDbShowRows(DataSet);
end;

procedure TMandatorForm.ttClientsAMOUNT_TOTAL_LOCALGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  if localCur = '' then
    localCur := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''LOCAL_CURRENCY'';'));
  Text := FormatFloat('#,##0.00', Sender.AsFloat) + ' ' + localCur;
end;

procedure TMandatorForm.ttClientsBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround(DataSet as TAdoQuery, 'ID', 'ARTIST', 'ID');
end;

procedure TMandatorForm.ttClientsNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('ID').AsGuid := TGUID.NewGuid;
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
  sbCommissions.Caption := CmDbShowRows(DataSet);
end;

procedure TMandatorForm.ttCommissionAMOUNT_LOCALGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  if localCur = '' then
    localCur := VariantToString(AdoConnection1.GetScalar('select VALUE from CONFIG where NAME = ''LOCAL_CURRENCY'';'));
  Text := FormatFloat('#,##0.00', Sender.AsFloat) + ' ' + localCur;
end;

procedure TMandatorForm.ttCommissionBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround(DataSet as TAdoQuery, 'ID', 'COMMISSION', 'ID');
end;

procedure TMandatorForm.ttCommissionBeforeEdit(DataSet: TDataSet);
begin
  Abort;
end;

procedure TMandatorForm.ttCommissionBeforeInsert(DataSet: TDataSet);
begin
  Abort;
end;

procedure TMandatorForm.ttPaymentAfterScroll(DataSet: TDataSet);
begin
  sbPayment.Caption := CmDbShowRows(DataSet);
end;

procedure TMandatorForm.ttPaymentBeforeDelete(DataSet: TDataSet);
begin
  InsteadOfDeleteWorkaround(DataSet as TAdoQuery, 'ID', 'PAYMENT', 'ID');
end;

procedure TMandatorForm.ttPaymentBeforeInsert(DataSet: TDataSet);
begin
  Abort;
end;

procedure TMandatorForm.ttStatisticsAfterScroll(DataSet: TDataSet);
begin
  sbStatistics.Caption := CmDbShowRows(DataSet);
end;

procedure TMandatorForm.ttStatisticsBeforeDelete(DataSet: TDataSet);
resourcestring
  SDeleteNotPossible = 'Delete not possible';
begin
  raise Exception.Create(SDeleteNotPossible);
end;

procedure TMandatorForm.ttStatisticsBeforeEdit(DataSet: TDataSet);
begin
  Abort;
end;

procedure TMandatorForm.ttStatisticsBeforeInsert(DataSet: TDataSet);
begin
  Abort;
end;

procedure TMandatorForm.Button1Click(Sender: TObject);
begin
  if Edit1.Text <> '' then
    Edit1.Clear;
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
var
  ArtistForm: TArtistForm;
resourcestring
  SArtistSforS = 'Artist %s for %s';
begin
  if ttArtists.State in [dsEdit,dsInsert] then ttArtists.Post;
  if ttArtists.FieldByName('ID').IsNull then exit;

  ArtistForm := MainForm.FindForm(ttArtists.FieldByName('ID').AsGuid) as TArtistForm;
  if Assigned(ArtistForm) then
  begin
    MainForm.RestoreMdiChild(ArtistForm);
  end
  else
  begin
    ArtistForm := TArtistForm.Create(Application.MainForm);
    ArtistForm.ArtistId := ttArtists.FieldByName('ID').AsGuid;
    ArtistForm.ArtistName := ttArtists.FieldByName('NAME').AsWideString;
    ArtistForm.Caption :=
      Format(SArtistSforS, [ttArtists.FieldByName('NAME').AsWideString, MandatorName]);
    ArtistForm.ADOConnection1.Connected := false;
    ArtistForm.ADOConnection1.ConnectionString := ADOConnection1.ConnectionString;
    ArtistForm.Init;
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
    ds.SQL.Text := SqlQueryArtistClient(true, Edit1.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.dbgClientsDblClick(Sender: TObject);
var
  ArtistForm: TArtistForm;
resourcestring
  SClientSforS = 'Client %s for %s';
begin
  if ttClients.State in [dsEdit,dsInsert] then ttClients.Post;
  if ttClients.FieldByName('ID').IsNull then exit;

  ArtistForm := MainForm.FindForm(ttClients.FieldByName('ID').AsGuid) as TArtistForm;
  if Assigned(ArtistForm) then
  begin
    MainForm.RestoreMdiChild(ArtistForm);
  end
  else
  begin
    ArtistForm := TArtistForm.Create(Application.MainForm);
    ArtistForm.ArtistId := ttClients.FieldByName('ID').AsGuid;
    ArtistForm.ArtistName := ttClients.FieldByName('NAME').AsWideString;
    ArtistForm.Caption :=
      Format(SClientSforS, [ttClients.FieldByName('NAME').AsWideString, MandatorName]);
    ArtistForm.ADOConnection1.Connected := false;
    ArtistForm.ADOConnection1.ConnectionString := ADOConnection1.ConnectionString;
    ArtistForm.Init;
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
    ds.SQL.Text := SqlQueryArtistClient(false, Edit1.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.dbgCommissionsDblClick(Sender: TObject);
var
  CommissionForm: TCommissionForm;
resourcestring
  SCommissionSbyS = 'Commission %s by %s';
  SCommissionSforS = 'Commission %s for %s';
begin
  if ttCommission.State in [dsEdit,dsInsert] then ttCommission.Post;
  if ttCommission.FieldByName('ID').IsNull then exit;

  CommissionForm := MainForm.FindForm(ttCommission.FieldByName('ID').AsGuid) as TCommissionForm;
  if Assigned(CommissionForm) then
  begin
    MainForm.RestoreMdiChild(CommissionForm);
  end
  else
  begin
    CommissionForm := TCommissionForm.Create(Application.MainForm);
    CommissionForm.CommissionId := ttCommission.FieldByName('ID').AsGuid;
    CommissionForm.CommissionName := ttCommission.FieldByName('NAME').AsWideString;
    if ttCommission.FieldByName('IS_ARTIST').AsBoolean then
    begin
      CommissionForm.Caption :=
        Format(SCommissionSbyS, [ttCommission.FieldByName('NAME').AsWideString, ttCommission.FieldByName('ARTIST_NAME').AsWideString]);
    end
    else
    begin
      CommissionForm.Caption :=
        Format(SCommissionSforS, [ttCommission.FieldByName('NAME').AsWideString, ttCommission.FieldByName('ARTIST_NAME').AsWideString]);
    end;
    CommissionForm.ADOConnection1.Connected := false;
    CommissionForm.ADOConnection1.ConnectionString := ADOConnection1.ConnectionString;
    CommissionForm.Init;
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
    ds.SQL.Text := SqlQueryCommissions(Edit1.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
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
    ds.SQL.Text := SqlQueryPayment(Edit1.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.dbgStatisticsDblClick(Sender: TObject);
var
  StatisticsForm: TStatisticsForm;
resourcestring
  SSForS = '%s for %s';
begin
  if ttStatistics.State in [dsEdit,dsInsert] then ttStatistics.Post;
  if ttStatistics.FieldByName('ID').IsNull then exit;

  StatisticsForm := MainForm.FindForm(ttStatistics.FieldByName('ID').AsGuid) as TStatisticsForm;
  if Assigned(StatisticsForm) then
  begin
    MainForm.RestoreMdiChild(StatisticsForm);
  end
  else
  begin
    StatisticsForm := TStatisticsForm.Create(Application.MainForm);
    StatisticsForm.StatisticsId := ttStatistics.FieldByName('ID').AsGuid;
    StatisticsForm.StatisticsName := ttStatistics.FieldByName('NAME').AsWideString;
    StatisticsForm.MandatorId := MandatorId;
    StatisticsForm.MandatorName := MandatorName;
    StatisticsForm.Caption :=
      Format(SSForS, [ttStatistics.FieldByName('NAME').AsWideString, MandatorName]);
    StatisticsForm.ADOConnection1.Connected := false;
    StatisticsForm.ADOConnection1.ConnectionString := ADOConnection1.ConnectionString;
    StatisticsForm.Init;
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
    ds.SQL.Text := SqlQueryStatistics(Edit1.Text);
    ds.Active := true;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.PageControl1Change(Sender: TObject);
begin
  if Edit1.Text <> '' then
  begin
    Edit1.Clear;
    Timer1.Enabled := False;
  end;
end;

procedure TMandatorForm.refreshArtistsClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    AdoQueryRefresh(ttArtists, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.refreshClientsClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    AdoQueryRefresh(ttClients, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.refreshCommissionsClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    AdoQueryRefresh(ttCommission, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.refreshPaymentClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    AdoQueryRefresh(ttPayment, 'ID');
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMandatorForm.refreshStatisticsClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    AdoQueryRefresh(ttStatistics, 'ID');
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
  if trim(search)<>'' then
    result := result + 'and lower(NAME) like ''%'+StringReplace(AnsiLowerCase(trim(search)), '''', '`', [rfReplaceAll])+'%'' ';
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
  if trim(search)<>'' then
    result := result + 'and lower(PROJECT_NAME) like ''%'+StringReplace(AnsiLowerCase(trim(search)), '''', '`', [rfReplaceAll])+'%'' ';
  if SqlQueryCommissions_order = 'START_DATE' then
    result := result + 'order by START_DATE '+AscDesc(SqlQueryCommissions_asc)+', END_DATE, PROJECT_NAME'
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
  if trim(search)<>'' then
    result := result + 'and (lower(ANNOTATION) like ''%'+StringReplace(AnsiLowerCase(trim(search)), '''', '`', [rfReplaceAll])+'%'' ' +
                       'or  lower(ARTIST_OR_CLIENT_NAME) like ''%'+StringReplace(AnsiLowerCase(trim(search)), '''', '`', [rfReplaceAll])+'%'') ';
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
    SqlQueryStatistics_order := 'NO';
    SqlQueryStatistics_asc := true;
  end;
  result := 'select * from vw_STATISTICS ';
  //result := result + 'where MANDATOR_ID = ''' + MandatorId.ToString + ''' ';
  if trim(search)<>'' then
    result := result + 'where lower(NAME) like ''%'+StringReplace(AnsiLowerCase(trim(search)), '''', '`', [rfReplaceAll])+'%'' ';
  if SqlQueryStatistics_order = 'NO' then
    result := result + 'order by NO '+AscDesc(SqlQueryStatistics_asc)+', NAME'
  else
    result := result + 'order by ' + SqlQueryStatistics_order + ' ' + AscDesc(SqlQueryStatistics_asc);
end;

procedure TMandatorForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  if PageControl1.ActivePage = tsArtists then
  begin
    Screen.Cursor := crHourGlass;
    try
      ttArtists.Active := false;
      ttArtists.SQL.Text := SqlQueryArtistClient(true, Edit1.Text);
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
      ttClients.SQL.Text := SqlQueryArtistClient(false, Edit1.Text);
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
      ttCommission.SQL.Text := SqlQueryCommissions(Edit1.Text);
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
      ttPayment.SQL.Text := SqlQueryPayment(Edit1.Text);
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
      ttStatistics.SQL.Text := SqlQueryStatistics(Edit1.Text);
      ttStatistics.Active := true;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TMandatorForm.Edit1Change(Sender: TObject);
begin
  Timer1.Enabled := false;
  Timer1.Enabled := true;
end;

procedure TMandatorForm.Edit1KeyDown(Sender: TObject; var Key: Word;
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
end;

procedure TMandatorForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMandatorForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ttArtists.State in [dsEdit,dsInsert] then ttArtists.Post;
  if ttClients.State in [dsEdit,dsInsert] then ttClients.Post;
  if ttCommission.State in [dsEdit,dsInsert] then ttCommission.Post;
  if ttStatistics.State in [dsEdit,dsInsert] then ttStatistics.Post;
end;

procedure TMandatorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // We must use FormKeyDown AND FormKeyUp. Why?
  // If we only use FormKeyDown only, then ESC will not only close this window, but also windows below (even if Key:=0 will be performed)
  // If we only use FormKeyUp, we don't get the correct dataset state (since dsEdit,dsInsert got reverted during KeyDown)
  if (Key = VK_ESCAPE) and
    not (ttArtists.State in [dsEdit,dsInsert]) and
    not (ttClients.State in [dsEdit,dsInsert]) and
    not (ttCommission.State in [dsEdit,dsInsert]) and
    not (ttStatistics.State in [dsEdit,dsInsert]) then
  begin
    Tag := 1; // tell FormKeyUp that we may close
    Key := 0;
  end;
end;

procedure TMandatorForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Tag = 1) then
  begin
    Close;
    Key := 0;
  end;
end;

procedure TMandatorForm.Init;
begin
  // We cannot use OnShow(), because TForm.Create() calls OnShow(), even if Visible=False
  PageControl1.ActivePageIndex := 0;
  Panel1.Caption := Caption;
  Screen.Cursor := crHourGlass;
  try
    {$REGION 'ttArtists / dbgArtists'}
    ttArtists.Active := false;
    ttArtists.SQL.Text := SqlQueryArtistClient(true, '');
    ttArtists.Active := true;
    dbgArtists.AutoSizeColumns;
    {$ENDREGION}
    {$REGION 'ttClients / dbgClients'}
    ttClients.Active := false;
    ttClients.SQL.Text := SqlQueryArtistClient(false, '');
    ttClients.Active := true;
    dbgClients.AutoSizeColumns;
    {$ENDREGION}
    {$REGION 'ttCommission / dbgCommissions'}
    ttCommission.Active := false;
    ttCommission.SQL.Text := SqlQueryCommissions('');
    ttCommission.Active := true;
    ttCommission.Last;
    dbgCommissions.AutoSizeColumns;
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
    {$ENDREGION}
    {$REGION 'ttStatistics / dbgStatistics'}
    ttStatistics.Active := false;
    ttStatistics.SQL.Text := SqlQueryStatistics('');
    ttStatistics.Active := true;
    dbgStatistics.AutoSizeColumns;
    {$ENDREGION}
  finally
    Screen.Cursor := crDefault;
  end;
end;

end.
