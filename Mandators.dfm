object MandatorsForm: TMandatorsForm
  Left = 0
  Top = 0
  Hint = 'Show help'
  Caption = 'MandatorsForm'
  ClientHeight = 329
  ClientWidth = 624
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
    Width = 624
    Height = 288
    ActivePage = tsConfig
    Align = alClient
    TabOrder = 1
    OnChange = PageControl1Change
    object tsMandator: TTabSheet
      Caption = 'Mandators'
      object navMandator: TDBNavigator
        Left = 0
        Top = 0
        Width = 33
        Height = 227
        DataSource = dsMandator
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
        Align = alLeft
        Kind = dbnVertical
        TabOrder = 1
      end
      object dbgMandator: TDBGrid
        Left = 33
        Top = 0
        Width = 583
        Height = 227
        Align = alClient
        DataSource = dsMandator
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnDrawColumnCell = dbgMandatorDrawColumnCell
        OnDblClick = dbgMandatorDblClick
        OnKeyDown = dbgMandatorKeyDown
        OnTitleClick = dbgMandatorTitleClick
        Columns = <
          item
            Expanded = False
            FieldName = 'NAME'
            Visible = True
          end>
      end
      object sbMandator: TPanel
        Left = 0
        Top = 227
        Width = 616
        Height = 31
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object csvMandator: TButton
          Left = 0
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Save as CSV'
          TabOrder = 0
          OnClick = csvMandatorClick
        end
        object refreshMandator: TBitBtn
          Left = 99
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Refresh'
          Kind = bkRetry
          NumGlyphs = 2
          TabOrder = 1
          OnClick = refreshMandatorClick
        end
      end
    end
    object tsTextDumps: TTabSheet
      Caption = 'Backups'
      ImageIndex = 1
      object dbgTextBackup: TDBGrid
        Left = 33
        Top = 0
        Width = 583
        Height = 227
        Align = alClient
        DataSource = dsTextBackup
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnKeyDown = dbgTextBackupKeyDown
        OnTitleClick = dbgTextBackupTitleClick
        Columns = <
          item
            Expanded = False
            FieldName = 'BAK_ID'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'BAK_DATE'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'BAK_LINES'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ANNOTATION'
            Visible = True
          end>
      end
      object navTextBackup: TDBNavigator
        Left = 0
        Top = 0
        Width = 33
        Height = 227
        DataSource = dsTextBackup
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbEdit, nbPost, nbCancel]
        Align = alLeft
        Kind = dbnVertical
        TabOrder = 1
      end
      object sbTextBackup: TPanel
        Left = 0
        Top = 227
        Width = 616
        Height = 31
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object csvTextBackup: TButton
          Left = 0
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Save as CSV'
          TabOrder = 0
          OnClick = csvTextBackupClick
        end
        object refreshTextBackup: TBitBtn
          Left = 99
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Refresh'
          Kind = bkRetry
          NumGlyphs = 2
          TabOrder = 1
          OnClick = refreshTextBackupClick
        end
      end
    end
    object tsConfig: TTabSheet
      Caption = 'Settings'
      ImageIndex = 2
      object navConfig: TDBNavigator
        Left = 0
        Top = 0
        Width = 33
        Height = 227
        DataSource = dsConfig
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbEdit, nbPost, nbCancel]
        Align = alLeft
        Kind = dbnVertical
        TabOrder = 0
      end
      object dbgConfig: TDBGrid
        Left = 33
        Top = 0
        Width = 583
        Height = 227
        Align = alClient
        DataSource = dsConfig
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnDblClick = dbgConfigDblClick
        OnKeyDown = dbgConfigKeyDown
        OnTitleClick = dbgConfigTitleClick
        Columns = <
          item
            Expanded = False
            FieldName = 'NAME'
            Width = 123
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'VALUE'
            Width = 200
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'HELP_TEXT'
            Width = 300
            Visible = True
          end>
      end
      object sbConfig: TPanel
        Left = 0
        Top = 227
        Width = 616
        Height = 31
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object csvConfig: TButton
          Left = 0
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Save as CSV'
          TabOrder = 0
          OnClick = csvConfigClick
        end
        object refreshConfig: TBitBtn
          Left = 99
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Refresh'
          Kind = bkRetry
          NumGlyphs = 2
          TabOrder = 1
          OnClick = refreshConfigClick
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 41
    Align = alTop
    Color = clBlueviolet
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = 27
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    DesignSize = (
      624
      41)
    object Edit1: TEdit
      Left = 422
      Top = 12
      Width = 171
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
      Left = 595
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
  object dsMandator: TDataSource
    DataSet = ttMandator
    Left = 192
    Top = 144
  end
  object ADOConnection1: TADOConnection
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 88
    Top = 72
  end
  object ttMandator: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforeEdit = ttMandatorBeforeEdit
    BeforeDelete = ttMandatorBeforeDelete
    AfterScroll = ttMandatorAfterScroll
    OnNewRecord = ttMandatorNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * from vw_MANDATOR')
    Left = 200
    Top = 80
    object ttMandatorID: TGuidField
      FieldName = 'ID'
      FixedChar = True
      Size = 38
    end
    object ttMandatorNAME: TWideStringField
      FieldName = 'NAME'
      Size = 50
    end
  end
  object ttTextBackup: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforeInsert = ttTextBackupBeforeInsert
    BeforeDelete = ttTextBackupBeforeDelete
    AfterScroll = ttTextBackupAfterScroll
    OnNewRecord = ttMandatorNewRecord
    Parameters = <>
    SQL.Strings = (
      'select BAK_ID, BAK_DATE, BAK_LINES, ANNOTATION from vw_BACKUP')
    Left = 272
    Top = 88
    object ttTextBackupBAK_ID: TAutoIncField
      FieldName = 'BAK_ID'
      ReadOnly = True
    end
    object ttTextBackupBAK_DATE: TDateTimeField
      FieldName = 'BAK_DATE'
      ReadOnly = True
    end
    object ttTextBackupBAK_LINES: TIntegerField
      FieldName = 'BAK_LINES'
      ReadOnly = True
    end
    object ttTextBackupCHECKSUM: TStringField
      FieldName = 'CHECKSUM'
      Size = 64
    end
    object ttTextBackupANNOTATION: TWideStringField
      FieldName = 'ANNOTATION'
      Size = 250
    end
  end
  object dsTextBackup: TDataSource
    DataSet = ttTextBackup
    Left = 288
    Top = 152
  end
  object ttConfig: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforeInsert = ttConfigBeforeInsert
    BeforeEdit = ttConfigBeforeEdit
    BeforePost = ttConfigBeforePost
    BeforeDelete = ttConfigBeforeDelete
    AfterScroll = ttConfigAfterScroll
    OnNewRecord = ttMandatorNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * from vw_CONFIG')
    Left = 360
    Top = 88
    object ttConfigNAME: TWideStringField
      FieldName = 'NAME'
      ReadOnly = True
      Size = 50
    end
    object ttConfigVALUE: TWideStringField
      FieldName = 'VALUE'
      Size = 4000
    end
    object ttConfigHELP_TEXT: TWideStringField
      FieldName = 'HELP_TEXT'
      ReadOnly = True
      Size = 4000
    end
    object ttConfigHIDDEN: TBooleanField
      FieldName = 'HIDDEN'
    end
    object ttConfigREAD_ONLY: TBooleanField
      FieldName = 'READ_ONLY'
    end
  end
  object dsConfig: TDataSource
    DataSet = ttConfig
    Left = 360
    Top = 152
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 380
    Top = 8
  end
  object sdCsvMandator: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 196
    Top = 219
  end
  object sdCsvTextBackup: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 276
    Top = 219
  end
  object sdCsvConfig: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 364
    Top = 219
  end
end
