unit Memo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TMemoForm = class(TForm)
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
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

procedure TMemoForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Key := 0;
  Tag := 1; // tell FormKeyUp that we may close
end;

procedure TMemoForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Tag = 1 then
  begin
    Key := #0; // avoid "Ding" sound
  end;
end;

procedure TMemoForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Shift = []) and (Tag = 1) then
  begin
    Key := 0;
    Close;
  end;
end;

end.
