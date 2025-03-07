object ArtistForm: TArtistForm
  Left = 0
  Top = 0
  Caption = 'ArtistForm'
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
    ActivePage = tsCommissions
    Align = alClient
    TabOrder = 1
    OnChange = PageControl1Change
    object tsCommissions: TTabSheet
      Caption = 'Commissions'
      object dbgCommission: TDBGrid
        Left = 33
        Top = 0
        Width = 1059
        Height = 339
        Align = alClient
        DataSource = dsCommission
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnDrawColumnCell = dbgCommissionDrawColumnCell
        OnDblClick = dbgCommissionDblClick
        OnKeyDown = dbgCommissionKeyDown
        OnTitleClick = dbgCommissionTitleClick
        Columns = <
          item
            Expanded = False
            FieldName = 'NAME'
            Width = 283
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'START_DATE'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'END_DATE'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ART_STATUS'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'PAY_STATUS'
            Width = 200
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'UPLOAD_C'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'UPLOAD_A'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'AMOUNT_LOCAL'
            Visible = True
          end>
      end
      object navCommission: TDBNavigator
        Left = 0
        Top = 0
        Width = 33
        Height = 339
        DataSource = dsCommission
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
        Align = alLeft
        Kind = dbnVertical
        TabOrder = 1
        OnClick = navCommissionClick
      end
      object sbCommission: TPanel
        Left = 0
        Top = 339
        Width = 1092
        Height = 31
        Align = alBottom
        Alignment = taRightJustify
        BevelOuter = bvNone
        TabOrder = 2
        object csvCommission: TButton
          Left = 0
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Save as CSV'
          TabOrder = 0
          OnClick = csvCommissionClick
        end
        object refreshCommission: TBitBtn
          Left = 198
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Refresh'
          Kind = bkRetry
          NumGlyphs = 2
          TabOrder = 2
          OnClick = refreshCommissionClick
        end
        object openCommission: TBitBtn
          Left = 99
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Open'
          NumGlyphs = 2
          TabOrder = 1
          OnClick = openCommissionClick
        end
      end
    end
    object tsPayment: TTabSheet
      Caption = 'Payments'
      ImageIndex = 1
      object navPayment: TDBNavigator
        Left = 0
        Top = 0
        Width = 33
        Height = 339
        DataSource = dsPayment
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
        Align = alLeft
        Kind = dbnVertical
        TabOrder = 0
        OnClick = navPaymentClick
      end
      object dbgPayment: TDBGrid
        Left = 33
        Top = 0
        Width = 1059
        Height = 339
        Align = alClient
        DataSource = dsPayment
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnDrawColumnCell = dbgPaymentDrawColumnCell
        OnKeyDown = dbgPaymentKeyDown
        OnTitleClick = dbgPaymentTitleClick
        Columns = <
          item
            Expanded = False
            FieldName = 'DATE'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'AMOUNT'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'CURRENCY'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'AMOUNT_LOCAL'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'AMOUNT_VERIFIED'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'PAYPROV'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ANNOTATION'
            Width = 200
            Visible = True
          end>
      end
      object sbPayment: TPanel
        Left = 0
        Top = 339
        Width = 1092
        Height = 31
        Align = alBottom
        Alignment = taRightJustify
        BevelOuter = bvNone
        TabOrder = 2
        object csvPayment: TButton
          Left = 0
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Save as CSV'
          TabOrder = 0
          OnClick = csvPaymentClick
        end
        object refreshPayment: TBitBtn
          Left = 99
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Refresh'
          Kind = bkRetry
          NumGlyphs = 2
          TabOrder = 1
          OnClick = refreshPaymentClick
        end
      end
    end
    object tsArtistEvent: TTabSheet
      Caption = 'Events'
      ImageIndex = 2
      object navArtistEvent: TDBNavigator
        Left = 0
        Top = 0
        Width = 33
        Height = 339
        DataSource = dsArtistEvent
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
        Align = alLeft
        Kind = dbnVertical
        TabOrder = 0
        OnClick = navArtistEventClick
      end
      object dbgArtistEvent: TDBGrid
        Left = 33
        Top = 0
        Width = 1059
        Height = 339
        Align = alClient
        DataSource = dsArtistEvent
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnDrawColumnCell = dbgArtistEventDrawColumnCell
        OnKeyDown = dbgArtistEventKeyDown
        OnTitleClick = dbgArtistEventTitleClick
        Columns = <
          item
            Expanded = False
            FieldName = 'DATE'
            Visible = True
          end
          item
            DropDownRows = 25
            Expanded = False
            FieldName = 'STATE'
            PickList.Strings = (
              'annot'
              'offer'
              'start coop'
              'end coop'
              'stopped'
              'hiatus'
              'inactive'
              'recover'
              'born'
              'deceased')
            Width = 94
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ANNOTATION'
            Width = 488
            Visible = True
          end>
      end
      object sbArtistEvent: TPanel
        Left = 0
        Top = 339
        Width = 1092
        Height = 31
        Align = alBottom
        Alignment = taRightJustify
        BevelOuter = bvNone
        TabOrder = 2
        object csvArtistEvent: TButton
          Left = 0
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Save as CSV'
          TabOrder = 0
          OnClick = csvArtistEventClick
        end
        object refreshEvent: TBitBtn
          Left = 99
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Refresh'
          Kind = bkRetry
          NumGlyphs = 2
          TabOrder = 1
          OnClick = refreshEventClick
        end
      end
    end
    object tsCommunication: TTabSheet
      Caption = 'Communication'
      ImageIndex = 3
      object dbgCommunication: TDBGrid
        Left = 33
        Top = 0
        Width = 1059
        Height = 339
        Align = alClient
        DataSource = dsCommunication
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnDrawColumnCell = dbgCommunicationDrawColumnCell
        OnDblClick = dbgCommunicationDblClick
        OnKeyDown = dbgCommunicationKeyDown
        OnTitleClick = dbgCommunicationTitleClick
        Columns = <
          item
            Expanded = False
            FieldName = 'CHANNEL'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ADDRESS'
            Width = 241
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ANNOTATION'
            Width = 326
            Visible = True
          end>
      end
      object navCommunication: TDBNavigator
        Left = 0
        Top = 0
        Width = 33
        Height = 339
        DataSource = dsCommunication
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
        Align = alLeft
        Kind = dbnVertical
        TabOrder = 1
        OnClick = navCommunicationClick
      end
      object sbCommunication: TPanel
        Left = 0
        Top = 339
        Width = 1092
        Height = 31
        Align = alBottom
        Alignment = taRightJustify
        BevelOuter = bvNone
        TabOrder = 2
        object csvCommunication: TButton
          Left = 0
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Save as CSV'
          TabOrder = 0
          OnClick = csvCommunicationClick
        end
        object refreshCommunication: TBitBtn
          Left = 198
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Refresh'
          Kind = bkRetry
          NumGlyphs = 2
          TabOrder = 2
          OnClick = refreshCommunicationClick
        end
        object openCommunication: TBitBtn
          Left = 99
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Open'
          NumGlyphs = 2
          TabOrder = 1
          OnClick = openCommunicationClick
        end
      end
    end
  end
  object HeadPanel: TPanel
    Left = 0
    Top = 0
    Width = 1100
    Height = 41
    Align = alTop
    Color = clDarkseagreen
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 27
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    DesignSize = (
      1100
      41)
    object SearchEdit: TEdit
      Left = 895
      Top = 9
      Width = 165
      Height = 23
      Anchors = [akTop, akRight]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnChange = SearchEditChange
      OnKeyDown = SearchEditKeyDown
    end
    object SearchBtn: TButton
      Left = 1067
      Top = 8
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
      Left = 8
      Top = 8
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
    object GoBackBtn: TButton
      Left = 40
      Top = 8
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
    object TitlePanel: TPanel
      Left = 72
      Top = 1
      Width = 816
      Height = 39
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 4
    end
  end
  object ADOConnection1: TADOConnection
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 96
    Top = 80
  end
  object ttCommission: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforeEdit = ttCommissionBeforeEdit
    BeforePost = ttCommissionBeforePost
    BeforeDelete = ttCommissionBeforeDelete
    AfterScroll = ttCommissionAfterScroll
    OnNewRecord = ttCommissionNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * from vw_COMMISSION')
    Left = 200
    Top = 80
    object ttCommissionID: TGuidField
      FieldName = 'ID'
      FixedChar = True
      Size = 38
    end
    object ttCommissionARTIST_ID: TGuidField
      FieldName = 'ARTIST_ID'
      FixedChar = True
      Size = 38
    end
    object ttCommissionNAME: TWideStringField
      FieldName = 'NAME'
      Size = 100
    end
    object ttCommissionUPLOAD_A: TWideStringField
      FieldName = 'UPLOAD_A'
      ReadOnly = True
      Size = 8
    end
    object ttCommissionUPLOAD_C: TWideStringField
      FieldName = 'UPLOAD_C'
      ReadOnly = True
      Size = 8
    end
    object ttCommissionSTART_DATE: TDateTimeField
      FieldName = 'START_DATE'
      ReadOnly = True
    end
    object ttCommissionEND_DATE: TDateTimeField
      FieldName = 'END_DATE'
      ReadOnly = True
    end
    object ttCommissionART_STATUS: TWideStringField
      FieldName = 'ART_STATUS'
      ReadOnly = True
    end
    object ttCommissionPAY_STATUS: TWideStringField
      FieldName = 'PAY_STATUS'
      ReadOnly = True
      Size = 4000
    end
    object ttCommissionAMOUNT_LOCAL: TBCDField
      FieldName = 'AMOUNT_LOCAL'
      ReadOnly = True
      Precision = 19
    end
    object ttCommissionMANDATOR_ID: TGuidField
      FieldName = 'MANDATOR_ID'
      FixedChar = True
      Size = 38
    end
    object ttCommissionIS_ARTIST: TBooleanField
      FieldName = 'IS_ARTIST'
    end
    object ttCommissionARTIST_NAME: TWideStringField
      FieldName = 'ARTIST_NAME'
      Size = 50
    end
    object ttCommissionFOLDER: TWideStringField
      FieldName = 'FOLDER'
      Size = 200
    end
    object ttCommissionPROJECT_NAME: TWideStringField
      FieldName = 'PROJECT_NAME'
      ReadOnly = True
      Size = 155
    end
  end
  object dsCommission: TDataSource
    DataSet = ttCommission
    Left = 192
    Top = 144
  end
  object ttPayment: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforeEdit = ttPaymentBeforeEdit
    BeforePost = ttPaymentBeforePost
    BeforeDelete = ttPaymentBeforeDelete
    AfterScroll = ttPaymentAfterScroll
    OnNewRecord = ttPaymentNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * from vw_PAYMENT')
    Left = 288
    Top = 88
    object ttPaymentID: TGuidField
      FieldName = 'ID'
      FixedChar = True
      Size = 38
    end
    object ttPaymentARTIST_ID: TGuidField
      FieldName = 'ARTIST_ID'
      FixedChar = True
      Size = 38
    end
    object ttPaymentAMOUNT: TBCDField
      FieldName = 'AMOUNT'
      Precision = 19
    end
    object ttPaymentCURRENCY: TWideStringField
      FieldName = 'CURRENCY'
      Size = 3
    end
    object ttPaymentDATE: TDateTimeField
      FieldName = 'DATE'
    end
    object ttPaymentAMOUNT_LOCAL: TBCDField
      FieldName = 'AMOUNT_LOCAL'
      Precision = 19
    end
    object ttPaymentAMOUNT_VERIFIED: TBooleanField
      FieldName = 'AMOUNT_VERIFIED'
    end
    object ttPaymentPAYPROV: TWideStringField
      FieldName = 'PAYPROV'
      Size = 35
    end
    object ttPaymentANNOTATION: TWideStringField
      FieldName = 'ANNOTATION'
      Size = 200
    end
    object ttPaymentMANDATOR_ID: TGuidField
      FieldName = 'MANDATOR_ID'
      Size = 38
    end
    object ttPaymentIS_ARTIST: TBooleanField
      FieldName = 'IS_ARTIST'
    end
    object ttPaymentARTIST_NAME: TWideStringField
      FieldName = 'ARTIST_NAME'
      Size = 50
    end
    object ttPaymentARTIST_OR_CLIENT_NAME: TWideStringField
      FieldName = 'ARTIST_OR_CLIENT_NAME'
      Size = 100
    end
  end
  object dsPayment: TDataSource
    DataSet = ttPayment
    Left = 288
    Top = 144
  end
  object ttArtistEvent: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforeEdit = ttArtistEventBeforeEdit
    BeforePost = ttArtistEventBeforePost
    BeforeDelete = ttArtistEventBeforeDelete
    AfterScroll = ttArtistEventAfterScroll
    OnNewRecord = ttArtistEventNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * from vw_ARTIST_EVENT')
    Left = 376
    Top = 96
    object ttArtistEventID: TGuidField
      FieldName = 'ID'
      FixedChar = True
      Size = 38
    end
    object ttArtistEventARTIST_ID: TGuidField
      FieldName = 'ARTIST_ID'
      FixedChar = True
      Size = 38
    end
    object ttArtistEventDATE: TDateTimeField
      FieldName = 'DATE'
    end
    object ttArtistEventSTATE: TWideStringField
      FieldName = 'STATE'
    end
    object ttArtistEventANNOTATION: TWideStringField
      FieldName = 'ANNOTATION'
      Size = 250
    end
  end
  object dsArtistEvent: TDataSource
    DataSet = ttArtistEvent
    Left = 368
    Top = 160
  end
  object ttCommunication: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforeEdit = ttCommunicationBeforeEdit
    BeforePost = ttCommunicationBeforePost
    BeforeDelete = ttCommunicationBeforeDelete
    AfterScroll = ttCommunicationAfterScroll
    OnNewRecord = ttCommunicationNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * from vw_COMMUNICATION')
    Left = 464
    Top = 96
    object ttCommunicationID: TGuidField
      FieldName = 'ID'
      FixedChar = True
      Size = 38
    end
    object ttCommunicationARTIST_ID: TGuidField
      FieldName = 'ARTIST_ID'
      FixedChar = True
      Size = 38
    end
    object ttCommunicationCHANNEL: TWideStringField
      FieldName = 'CHANNEL'
      Size = 50
    end
    object ttCommunicationADDRESS: TWideStringField
      FieldName = 'ADDRESS'
      Size = 100
    end
    object ttCommunicationANNOTATION: TWideStringField
      FieldName = 'ANNOTATION'
      Size = 150
    end
  end
  object dsCommunication: TDataSource
    DataSet = ttCommunication
    Left = 464
    Top = 168
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 848
    Top = 16
  end
  object sdCsvCommission: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 196
    Top = 219
  end
  object sdCsvPayment: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 292
    Top = 227
  end
  object sdCsvArtistEvent: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 380
    Top = 227
  end
  object sdCsvCommunication: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 476
    Top = 227
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer2Timer
    Left = 776
    Top = 16
  end
end
