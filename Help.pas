unit Help;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw;

type
  THelpForm = class(TForm)
    WebBrowser1: TWebBrowser;
    procedure WebBrowser1BeforeNavigate2(ASender: TObject;
      const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FDirectory: string;
  public
    procedure ShowHTMLHelp(AHTML: string);
    procedure ShowMarkDownHelp(AMarkDownFile: string);
  end;

var
  HelpForm: THelpForm;

implementation

uses
  MarkDownProcessor, ShellAPI;

{$R *.dfm}

procedure THelpForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  HelpForm := nil;
  Action := caFree;
end;

procedure THelpForm.ShowHTMLHelp(AHTML: string);
var
  DOC: Variant;
begin
  if not Assigned(WebBrowser1.Document) then
    WebBrowser1.Navigate('about:blank'); // do not localize

  DOC := WebBrowser1.Document;
  DOC.Clear;
  DOC.Write(AHTML);
  Doc.Close;
end;

procedure THelpForm.ShowMarkDownHelp(AMarkDownFile: string);
var
  md: TMarkdownProcessor;
  slMarkdown, slHtml, slCss: TStringList;
  sHtml: string;
  rcStream: TResourceStream;
begin
  FDirectory := ExtractFilePath(AMarkDownFile);
  if FDirectory = '' then FDirectory := '.';
  slMarkdown := TStringList.Create();
  slHtml := TStringList.Create();
  slCss := TStringList.Create();
  try
    rcStream := TResourceStream.Create(HInstance, ChangeFileExt(AMarkDownFile, '_MD'), RT_RCDATA);
    try
      slMarkdown.LoadFromStream(rcStream);
    finally
      FreeAndNil(rcStream);
    end;

    rcStream := TResourceStream.Create(HInstance, 'HELPSTYLE_CSS', RT_RCDATA);
    try
      slCss.LoadFromStream(rcStream);
    finally
      FreeAndNil(rcStream);
    end;

    md := TMarkdownProcessor.CreateDialect(mdCommonMark);
    try
      sHtml := md.process(UTF8ToString(RawByteString(slMarkdown.Text)));
      sHtml := sHtml.Replace('<p><img src="CmDb2_Screenshot', '<p><xx src="CmDb2_Screenshot'); // <-- thse images are only for GitHub, not for the integrated help. So invalidate them.
      //md.AllowUnsafe := true;
      ShowHTMLHelp(
        '<html>'+                                                                // do not localize
        '<head>'+                                                                // do not localize
        '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'+   // do not localize
        '<style>'+slCss.Text+'</style>'+                                         // do not localize
        '</head>'+                                                               // do not localize
        '<body>'+                                                                // do not localize
        sHtml+
        '</body>'+                                                               // do not localize
        '</html>');                                                              // do not localize
    finally
      FreeAndNil(md);
    end;
  finally
    FreeAndNil(slMarkdown);
    FreeAndNil(slHtml);
    FreeAndNil(slCss);
  end;
end;

procedure THelpForm.WebBrowser1BeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
begin
  if SameText(Copy(URL,1,7),'http://') or      // do not localize
     SameText(Copy(URL,1,8),'https://') or     // do not localize
     SameText(Copy(URL,1,7),'mailto:') then    // do not localize
  begin
    // Links in default Browser anzeigen
    ShellExecute(handle, 'open', PChar(string(URL)), '', '', SW_NORMAL);  // do not localize
    Cancel := true;
  end
  else if SameText(ExtractFileExt(URL), '.md') then // do not localize
  begin
    if SameText(Copy(URL,1,6), 'about:') then // do not localize
      ShowMarkDownHelp(Copy(URL,7,Length(URL)))
    else
      ShowMarkDownHelp(URL);
    Cancel := true;
  end
  else
  begin
    Cancel := false;
  end;
end;

end.
