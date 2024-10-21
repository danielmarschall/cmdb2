unit Memo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TMemoForm = class(TForm)
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

var
  MemoForm: TMemoForm;

implementation

{$R *.dfm}

procedure TMemoForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MemoForm := nil;
  Action := caFree;
end;

end.
