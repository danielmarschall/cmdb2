object HelpForm: THelpForm
  Left = 0
  Top = 0
  ClientHeight = 484
  ClientWidth = 730
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIChild
  Position = poMainFormCenter
  Visible = True
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  TextHeight = 15
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 0
    Width = 730
    Height = 484
    Align = alClient
    TabOrder = 0
    OnBeforeNavigate2 = WebBrowser1BeforeNavigate2
    ControlData = {
      4C000000734B0000063200000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
end
