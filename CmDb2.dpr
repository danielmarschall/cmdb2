program CmDb2;

{$R *.dres}

uses
  Vcl.Forms,
  CmDbMain in 'CmDbMain.pas' {MainForm},
  Database in 'Database.pas' {DatabaseForm},
  Mandator in 'Mandator.pas' {MandatorForm},
  Artist in 'Artist.pas' {ArtistForm},
  Commission in 'Commission.pas' {CommissionForm},
  AdoConnHelper in 'AdoConnHelper.pas',
  Statistics in 'Statistics.pas' {StatisticsForm},
  DbGridHelper in 'DbGridHelper.pas',
  VtsCurConvDLLHeader in 'VtsCurConvDLLHeader.pas',
  CmDbFunctions in 'CmDbFunctions.pas',
  Help in 'Help.pas' {HelpForm},
  CmDbPluginClient in 'CmDbPluginClient.pas',
  CmDbPluginShare in 'CmDbPluginShare.pas',
  EncryptedZipFile in 'EncryptedZipFile.pas',
  Memo in 'Memo.pas' {MemoForm};

{$R *.res}

begin
  Application.Title := 'Commission Database 2.0';
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
