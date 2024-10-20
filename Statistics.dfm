object StatisticsForm: TStatisticsForm
  Left = 0
  Top = 0
  Hint = 'Show help'
  Caption = 'StatisticsForm'
  ClientHeight = 441
  ClientWidth = 1100
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIChild
  KeyPreview = True
  Visible = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  TextHeight = 15
  object PageControl1: TPageControl
    Left = 0
    Top = 41
    Width = 1100
    Height = 400
    ActivePage = tsQuery
    Align = alClient
    TabOrder = 1
    OnChange = PageControl1Change
    object tsQuery: TTabSheet
      Caption = 'Query'
      object dbgQuery: TDBGrid
        Left = 33
        Top = 0
        Width = 1059
        Height = 339
        Align = alClient
        DataSource = dsQuery
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnDrawColumnCell = dbgQueryDrawColumnCell
        OnDblClick = dbgQueryDblClick
        OnKeyDown = dbgQueryKeyDown
        OnTitleClick = dbgQueryTitleClick
      end
      object navQuery: TDBNavigator
        Left = 0
        Top = 0
        Width = 33
        Height = 339
        DataSource = dsQuery
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbDelete, nbPost, nbCancel]
        Align = alLeft
        Kind = dbnVertical
        TabOrder = 1
      end
      object sbQuery: TPanel
        Left = 0
        Top = 339
        Width = 1092
        Height = 31
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object csvQuery: TButton
          Left = 0
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Save as CSV'
          TabOrder = 0
          OnClick = csvQueryClick
        end
        object refreshQuery: TBitBtn
          Left = 99
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Refresh'
          Kind = bkRetry
          NumGlyphs = 2
          TabOrder = 1
          OnClick = refreshQueryClick
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1100
    Height = 41
    Align = alTop
    Color = clDarkslateblue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = 27
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    DesignSize = (
      1100
      41)
    object Edit1: TEdit
      Left = 898
      Top = 12
      Width = 175
      Height = 23
      Anchors = [akTop, akRight]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnChange = Edit1Change
      OnKeyDown = Edit1KeyDown
    end
    object SearchBtn: TButton
      Left = 1071
      Top = 10
      Width = 25
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'X'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 20
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = SearchBtnClick
    end
    object GoBackBtn: TButton
      Left = 43
      Top = 10
      Width = 25
      Height = 25
      Hint = 'Go back to Mandator'
      Caption = '<'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 20
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = GoBackBtnClick
    end
    object HelpBtn: TButton
      Left = 12
      Top = 10
      Width = 25
      Height = 25
      Hint = 'Show help'
      Caption = '?'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 20
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = HelpBtnClick
    end
  end
  object ADOConnection1: TADOConnection
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 88
    Top = 72
  end
  object ttQuery: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforeInsert = ttQueryBeforeInsert
    BeforeEdit = ttQueryBeforeEdit
    BeforeDelete = ttQueryBeforeDelete
    AfterScroll = ttQueryAfterScroll
    Parameters = <>
    Left = 200
    Top = 80
  end
  object dsQuery: TDataSource
    DataSet = ttQuery
    Left = 200
    Top = 152
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 856
    Top = 8
  end
  object sdCsvQuery: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 204
    Top = 219
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer2Timer
    Left = 800
    Top = 8
  end
end
