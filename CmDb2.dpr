program CmDb2;

uses
  Vcl.Forms,
  CmDbMain in 'CmDbMain.pas' {MainForm},
  Mandators in 'Mandators.pas' {MandatorsForm},
  Mandator in 'Mandator.pas' {MandatorForm},
  Artist in 'Artist.pas' {ArtistForm},
  Commission in 'Commission.pas' {CommissionForm},
  AdoConnHelper in 'AdoConnHelper.pas',
  Statistics in 'Statistics.pas' {StatisticsForm},
  DbGridHelper in 'DbGridHelper.pas',
  CmDbTextBackup in 'CmDbTextBackup.pas',
  VtsCurConvDLLHeader in 'VtsCurConvDLLHeader.pas',
  CmDbFunctions in 'CmDbFunctions.pas',
  Help in 'Help.pas' {HelpForm},
  CmDbPluginClient in 'CmDbPluginClient.pas';

{$R *.res}

begin
  Application.Title := 'Commission Database 2.0';
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
