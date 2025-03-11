program CmDb2;

{$R *.dres}

uses
  Vcl.Forms,
  WinApi.Windows,
  WinApi.Messages,
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

const
  MutexName = 'urn:oid:1.3.6.1.4.1.37476.2.75.1';

var
  mHandle: THandle;

procedure CloseSemaphoreHandleIfExists;
begin
  if mHandle <> 0 then CloseHandle(mHandle);
end;

procedure HsSemaphoreCheck;
var
  hWndAndereInstanz: HWND;
  Unique_AppTitle: string;
resourcestring
  SApplicationAlreadyRunning = 'The application is already running';
begin
  Unique_AppTitle := Application.Title;

  SetWindowText(Application.Handle, PChar(Unique_AppTitle));

  CloseSemaphoreHandleIfExists;
  mHandle := CreateMutex(nil, True, MutexName);
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    // Wir ändern unseren Application.Title, damit wir uns nicht selbst finden.
    // Dieser Titel soll aber trotzdem für den Benutzer sinnvoll erscheinen, da dieser Titel
    // z.B. bei etwaigen ShowMessage() Fenstern oder in der Taskleiste erscheint.
    Application.Title := Unique_AppTitle + ' ';

    // Das Fenster der anderen Instanz finden.
    // Wichtig: Das funktioniert erst nach Application.Initialize!
    hWndAndereInstanz := FindWindow('TApplication', PChar(Unique_AppTitle));
    if hWndAndereInstanz <> 0 then
    begin
      // Falls minimiert, wiederherstellen
      (*
      if IsIconic(hWndAndereInstanz) then
        ShowWindow(hWndAndereInstanz, {SW_SHOW}SW_RESTORE);
      *)
      SendMessage(hWndAndereInstanz, WM_SYSCOMMAND, SC_RESTORE, 0);

      // Die Anwendung in den Vordergrund bringen
      SetForegroundWindow(hWndAndereInstanz);
    end
    else
    begin
      // Dies passiert, wenn das Fenster der anderen Anwendung NICHT gefunden wurde.
      // Das sollte eigentlich nicht passieren, aber wir versuchen trotzdem, die Situation gekonnt zu überspielen.
      MessageBox(Application.Handle, PChar(SApplicationAlreadyRunning), PChar(Application.Title), MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
    end;

    // Uns selbst schließen
    Halt;
  end;
end;

begin
  try
    Application.Title := 'Commission Database 2.0';
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    HsSemaphoreCheck;
    Application.CreateForm(TMainForm, MainForm);
    Application.Run;
  finally
    CloseSemaphoreHandleIfExists;
  end;
end.
