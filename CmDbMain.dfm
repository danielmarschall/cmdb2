object MainForm: TMainForm
  Left = 0
  Top = 0
  ClientHeight = 612
  ClientWidth = 777
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = MainMenu1
  WindowState = wsMaximized
  WindowMenu = Window1
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object WaitLabel: TLabel
    Left = 16
    Top = 16
    Width = 167
    Height = 41
    Caption = 'Please wait...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -30
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object Timer1: TTimer
    Interval = 10
    OnTimer = Timer1Timer
    Left = 288
    Top = 168
  end
  object MainMenu1: TMainMenu
    Left = 344
    Top = 136
    object Exit1: TMenuItem
      Caption = 'File'
      object RestoreBackup1: TMenuItem
        Caption = 'Restore Backup...'
        OnClick = RestoreBackup1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object BackupandExit1: TMenuItem
        Caption = 'Backup and Exit'
        OnClick = BackupandExit1Click
      end
    end
    object OpenDatabase1: TMenuItem
      Caption = 'Open Database'
      OnClick = OpenDatabase1Click
    end
    object Window1: TMenuItem
      Caption = 'Window'
      object Cascade1: TMenuItem
        Caption = 'Cascade'
        OnClick = Cascade1Click
      end
      object TileHorizontally1: TMenuItem
        Caption = 'Tile horizontally'
        OnClick = TileHorizontally1Click
      end
      object TileVertically1: TMenuItem
        Caption = 'Tile vertically'
        OnClick = TileVertically1Click
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object Generalhelp1: TMenuItem
        Caption = 'Read me'
        OnClick = Generalhelp1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object About1: TMenuItem
        Caption = 'About'
        OnClick = About1Click
      end
    end
  end
  object ADOConnection1: TADOConnection
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 288
    Top = 288
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'bak'
    Filter = 'Backup files (*.bak)|*.bak|All files (*.*)|*.*'
    Options = [ofReadOnly, ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofCreatePrompt, ofEnableSizing]
    Left = 40
    Top = 16
  end
end
