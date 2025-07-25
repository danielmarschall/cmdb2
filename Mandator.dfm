object MandatorForm: TMandatorForm
  Left = 0
  Top = 0
  Hint = 'Show help'
  Caption = 'MandatorForm'
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
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  TextHeight = 15
  object PageControl1: TPageControl
    Left = 0
    Top = 41
    Width = 1100
    Height = 400
    ActivePage = tsArtists
    Align = alClient
    TabOrder = 1
    OnChange = PageControl1Change
    object tsArtists: TTabSheet
      Caption = 'Artists'
      object dbgArtists: TDBGrid
        Left = 33
        Top = 0
        Width = 1059
        Height = 339
        Align = alClient
        DataSource = dsArtists
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnDrawColumnCell = dbgArtistsDrawColumnCell
        OnDblClick = dbgArtistsDblClick
        OnKeyDown = dbgArtistsKeyDown
        OnTitleClick = dbgArtistsTitleClick
        Columns = <
          item
            Expanded = False
            FieldName = 'NAME'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'STATUS'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'PAY_STATUS'
            Width = 250
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'RUNNING'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'LAST_UPDATE'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'FIRST_UPDATE'
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
            FieldName = 'AMOUNT_TOTAL_LOCAL'
            Visible = True
          end>
      end
      object navArtists: TDBNavigator
        Left = 0
        Top = 0
        Width = 33
        Height = 339
        DataSource = dsArtists
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
        Align = alLeft
        Kind = dbnVertical
        TabOrder = 1
        OnClick = navArtistsClick
      end
      object sbArtists: TPanel
        Left = 0
        Top = 339
        Width = 1092
        Height = 31
        Align = alBottom
        Alignment = taRightJustify
        BevelOuter = bvNone
        TabOrder = 2
        object csvArtists: TButton
          Left = 0
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Save as CSV'
          TabOrder = 0
          OnClick = csvArtistsClick
        end
        object refreshArtists: TBitBtn
          Left = 198
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Refresh'
          Kind = bkRetry
          NumGlyphs = 2
          TabOrder = 2
          OnClick = refreshArtistsClick
        end
        object openArtist: TBitBtn
          Left = 99
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Open'
          NumGlyphs = 2
          TabOrder = 1
          OnClick = openArtistClick
        end
      end
    end
    object tsClients: TTabSheet
      Caption = 'Clients'
      object dbgClients: TDBGrid
        Left = 33
        Top = 0
        Width = 1059
        Height = 339
        Align = alClient
        DataSource = dsClients
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnDrawColumnCell = dbgClientsDrawColumnCell
        OnDblClick = dbgClientsDblClick
        OnKeyDown = dbgClientsKeyDown
        OnTitleClick = dbgClientsTitleClick
        Columns = <
          item
            Expanded = False
            FieldName = 'NAME'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'STATUS'
            Width = 130
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'PAY_STATUS'
            Width = 109
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'RUNNING'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'FIRST_UPDATE'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'LAST_UPDATE'
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
            FieldName = 'AMOUNT_TOTAL_LOCAL'
            Visible = True
          end>
      end
      object navClients: TDBNavigator
        Left = 0
        Top = 0
        Width = 33
        Height = 339
        DataSource = dsClients
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
        Align = alLeft
        Kind = dbnVertical
        TabOrder = 1
        OnClick = navClientsClick
      end
      object sbClients: TPanel
        Left = 0
        Top = 339
        Width = 1092
        Height = 31
        Align = alBottom
        Alignment = taRightJustify
        BevelOuter = bvNone
        TabOrder = 2
        object csvClients: TButton
          Left = 0
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Save as CSV'
          TabOrder = 0
          OnClick = csvClientsClick
        end
        object refreshClients: TBitBtn
          Left = 198
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Refresh'
          Kind = bkRetry
          NumGlyphs = 2
          TabOrder = 2
          OnClick = refreshClientsClick
        end
        object openClients: TBitBtn
          Left = 99
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Open'
          NumGlyphs = 2
          TabOrder = 1
          OnClick = openClientsClick
        end
      end
    end
    object tsCommissions: TTabSheet
      Caption = 'Commissions'
      ImageIndex = 3
      object dbgCommissions: TDBGrid
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
        OnDrawColumnCell = dbgCommissionsDrawColumnCell
        OnDblClick = dbgCommissionsDblClick
        OnKeyDown = dbgCommissionsKeyDown
        OnTitleClick = dbgCommissionsTitleClick
        Columns = <
          item
            Expanded = False
            FieldName = 'PROJECT_NAME'
            Width = 345
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'START_DATE'
            Width = 90
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'END_DATE'
            Width = 80
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
            Width = 120
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'UPLOAD_A'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'UPLOAD_C'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'AMOUNT_LOCAL'
            Visible = True
          end>
      end
      object navCommissions: TDBNavigator
        Left = 0
        Top = 0
        Width = 33
        Height = 339
        DataSource = dsCommission
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbDelete, nbPost, nbCancel]
        Align = alLeft
        Kind = dbnVertical
        TabOrder = 1
      end
      object sbCommissions: TPanel
        Left = 0
        Top = 339
        Width = 1092
        Height = 31
        Align = alBottom
        Alignment = taRightJustify
        BevelOuter = bvNone
        TabOrder = 2
        object csvCommissions: TButton
          Left = 0
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Save as CSV'
          TabOrder = 0
          OnClick = csvCommissionsClick
        end
        object refreshCommissions: TBitBtn
          Left = 198
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Refresh'
          Kind = bkRetry
          NumGlyphs = 2
          TabOrder = 2
          OnClick = refreshCommissionsClick
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
      ImageIndex = 4
      object sbPayment: TPanel
        Left = 0
        Top = 339
        Width = 1092
        Height = 31
        Align = alBottom
        Alignment = taRightJustify
        BevelOuter = bvNone
        TabOrder = 0
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
            FieldName = 'ARTIST_OR_CLIENT_NAME'
            ReadOnly = True
            Width = 186
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
      object navPayment: TDBNavigator
        Left = 0
        Top = 0
        Width = 33
        Height = 339
        DataSource = dsPayment
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbDelete, nbEdit, nbPost, nbCancel]
        Align = alLeft
        Kind = dbnVertical
        TabOrder = 2
      end
    end
    object tsStatistics: TTabSheet
      Caption = 'Statistics'
      ImageIndex = 1
      object navStatistics: TDBNavigator
        Left = 0
        Top = 0
        Width = 33
        Height = 339
        DataSource = dsStatistics
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbPost, nbCancel]
        Align = alLeft
        Kind = dbnVertical
        TabOrder = 0
      end
      object dbgStatistics: TDBGrid
        Left = 33
        Top = 0
        Width = 1059
        Height = 339
        Align = alClient
        DataSource = dsStatistics
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnDrawColumnCell = dbgStatisticsDrawColumnCell
        OnDblClick = dbgStatisticsDblClick
        OnKeyDown = dbgStatisticsKeyDown
        OnTitleClick = dbgStatisticsTitleClick
        Columns = <
          item
            Expanded = False
            FieldName = 'PLUGIN'
            Width = 154
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'NO'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'NAME'
            Visible = True
          end>
      end
      object sbStatistics: TPanel
        Left = 0
        Top = 339
        Width = 1092
        Height = 31
        Align = alBottom
        Alignment = taRightJustify
        BevelOuter = bvNone
        TabOrder = 2
        object csvStatistics: TButton
          Left = 0
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Save as CSV'
          TabOrder = 0
          OnClick = csvStatisticsClick
        end
        object refreshStatistics: TBitBtn
          Left = 198
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Refresh'
          Kind = bkRetry
          NumGlyphs = 2
          TabOrder = 2
          OnClick = refreshStatisticsClick
        end
        object openStatistics: TBitBtn
          Left = 99
          Top = 0
          Width = 99
          Height = 31
          Align = alLeft
          Caption = 'Open'
          NumGlyphs = 2
          TabOrder = 1
          OnClick = openStatisticsClick
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
    Color = clBurlywood
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
      OnKeyPress = SearchEditKeyPress
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
      Hint = 'Go back to Database'
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
  object dsArtists: TDataSource
    DataSet = ttArtists
    Left = 200
    Top = 152
  end
  object dsClients: TDataSource
    DataSet = ttClients
    Left = 280
    Top = 152
  end
  object ADOConnection1: TADOConnection
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 88
    Top = 72
  end
  object ttArtists: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforeEdit = ttArtistsBeforeEdit
    BeforePost = ttArtistsBeforePost
    BeforeDelete = ttArtistsBeforeDelete
    AfterScroll = ttArtistsAfterScroll
    OnNewRecord = ttArtistsNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * from vw_ARTIST')
    Left = 200
    Top = 80
    object ttArtistsID: TGuidField
      FieldName = 'ID'
      FixedChar = True
      Size = 38
    end
    object ttArtistsMANDATOR_ID: TGuidField
      FieldName = 'MANDATOR_ID'
      FixedChar = True
      Size = 38
    end
    object ttArtistsNAME: TWideStringField
      FieldName = 'NAME'
      Size = 50
    end
    object ttArtistsAMOUNT_TOTAL_LOCAL: TBCDField
      FieldName = 'AMOUNT_TOTAL_LOCAL'
      ReadOnly = True
      Precision = 19
    end
    object ttArtistsCOMMISSION_COUNT: TIntegerField
      FieldName = 'COMMISSION_COUNT'
      ReadOnly = True
    end
    object ttArtistsPAY_STATUS: TWideStringField
      FieldName = 'PAY_STATUS'
      ReadOnly = True
      Size = 4000
    end
    object ttArtistsUPLOADS_A: TIntegerField
      FieldName = 'UPLOADS_A'
      ReadOnly = True
    end
    object ttArtistsUPLOADS_C: TIntegerField
      FieldName = 'UPLOADS_C'
      ReadOnly = True
    end
    object ttArtistsPROHIBIT_A: TIntegerField
      FieldName = 'PROHIBIT_A'
      ReadOnly = True
    end
    object ttArtistsPROHIBIT_C: TIntegerField
      FieldName = 'PROHIBIT_C'
      ReadOnly = True
    end
    object ttArtistsCOMMISSION_RUNNING: TIntegerField
      FieldName = 'COMMISSION_RUNNING'
      ReadOnly = True
    end
    object ttArtistsUPLOAD_A: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'UPLOAD_A'
      ReadOnly = True
      OnGetText = ttArtistsUPLOAD_AGetText
      Size = 8
      Calculated = True
    end
    object ttArtistsUPLOAD_C: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'UPLOAD_C'
      ReadOnly = True
      OnGetText = ttArtistsUPLOAD_CGetText
      Size = 8
      Calculated = True
    end
    object ttArtistsRUN: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'RUNNING'
      ReadOnly = True
      OnGetText = ttArtistsRUNGetText
      Size = 8
      Calculated = True
    end
    object ttArtistsIS_ARTIST: TBooleanField
      FieldName = 'IS_ARTIST'
    end
    object ttArtistsSTATUS: TWideStringField
      FieldName = 'STATUS'
      ReadOnly = True
      Size = 50
    end
    object ttArtistsLAST_UPDATE_COMMISSION: TDateField
      FieldName = 'LAST_UPDATE_COMMISSION'
    end
    object ttArtistsLAST_UPDATE_ARTISTEVENT: TDateField
      FieldName = 'LAST_UPDATE_ARTISTEVENT'
    end
    object ttArtistsLAST_UPDATE: TDateField
      FieldKind = fkCalculated
      FieldName = 'LAST_UPDATE'
      ReadOnly = True
      OnGetText = ttArtistsLAST_UPDATEGetText
      Calculated = True
    end
    object ttArtistsFIRST_UPDATE_COMMISSION: TDateField
      FieldName = 'FIRST_UPDATE_COMMISSION'
    end
    object ttArtistsFIRST_UPDATE_ARTISTEVENT: TDateField
      FieldName = 'FIRST_UPDATE_ARTISTEVENT'
    end
    object ttArtistsFIRST_UPDATE: TDateField
      FieldKind = fkCalculated
      FieldName = 'FIRST_UPDATE'
      ReadOnly = True
      OnGetText = ttArtistsFIRST_UPDATEGetText
      Calculated = True
    end
  end
  object ttClients: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforeEdit = ttClientsBeforeEdit
    BeforePost = ttClientsBeforePost
    BeforeDelete = ttClientsBeforeDelete
    AfterScroll = ttClientsAfterScroll
    OnNewRecord = ttClientsNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * from vw_ARTIST')
    Left = 280
    Top = 80
    object ttClientsID: TGuidField
      FieldName = 'ID'
      FixedChar = True
      Size = 38
    end
    object ttClientsMANDATOR_ID: TGuidField
      FieldName = 'MANDATOR_ID'
      FixedChar = True
      Size = 38
    end
    object ttClientsNAME: TWideStringField
      FieldName = 'NAME'
      Size = 50
    end
    object ttClientsAMOUNT_TOTAL_LOCAL: TBCDField
      FieldName = 'AMOUNT_TOTAL_LOCAL'
      ReadOnly = True
      Precision = 19
    end
    object ttClientsCOMMISSION_COUNT: TIntegerField
      FieldName = 'COMMISSION_COUNT'
      ReadOnly = True
    end
    object ttClientsPAY_STATUS: TWideStringField
      FieldName = 'PAY_STATUS'
      ReadOnly = True
      Size = 4000
    end
    object ttClientsUPLOADS_A: TIntegerField
      FieldName = 'UPLOADS_A'
      ReadOnly = True
    end
    object ttClientsUPLOADS_C: TIntegerField
      FieldName = 'UPLOADS_C'
      ReadOnly = True
    end
    object ttClientsPROHIBIT_A: TIntegerField
      FieldName = 'PROHIBIT_A'
      ReadOnly = True
    end
    object ttClientsPROHIBIT_C: TIntegerField
      FieldName = 'PROHIBIT_C'
      ReadOnly = True
    end
    object ttClientsCOMMISSION_RUNNING: TIntegerField
      FieldName = 'COMMISSION_RUNNING'
      ReadOnly = True
    end
    object ttClientsUPLOAD_A: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'UPLOAD_A'
      ReadOnly = True
      OnGetText = ttClientsUPLOAD_AGetText
      Size = 8
      Calculated = True
    end
    object ttClientsUPLOAD_C: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'UPLOAD_C'
      ReadOnly = True
      OnGetText = ttClientsUPLOAD_CGetText
      Size = 8
      Calculated = True
    end
    object ttClientsRUN: TWideStringField
      FieldKind = fkCalculated
      FieldName = 'RUNNING'
      ReadOnly = True
      OnGetText = ttClientsRUNGetText
      Size = 8
      Calculated = True
    end
    object ttClientsIS_ARTIST: TBooleanField
      FieldName = 'IS_ARTIST'
    end
    object ttClientsSTATUS: TWideStringField
      FieldName = 'STATUS'
      ReadOnly = True
      Size = 50
    end
    object ttClientsLAST_UPDATE_COMMISSION: TDateField
      FieldName = 'LAST_UPDATE_COMMISSION'
    end
    object ttClientsLAST_UPDATE_ARTISTEVENT: TDateField
      FieldName = 'LAST_UPDATE_ARTISTEVENT'
    end
    object ttClientsLAST_UPDATE: TDateField
      FieldKind = fkCalculated
      FieldName = 'LAST_UPDATE'
      ReadOnly = True
      OnGetText = ttClientsLAST_UPDATEGetText
      Calculated = True
    end
    object ttClientsFIRST_UPDATE_COMMISSION: TDateField
      FieldName = 'FIRST_UPDATE_COMMISSION'
    end
    object ttClientsFIRST_UPDATE_ARTISTEVENT: TDateField
      FieldName = 'FIRST_UPDATE_ARTISTEVENT'
    end
    object ttClientsFIRST_UPDATE: TDateField
      FieldKind = fkCalculated
      FieldName = 'FIRST_UPDATE'
      ReadOnly = True
      OnGetText = ttClientsFIRST_UPDATEGetText
      Calculated = True
    end
  end
  object ttStatistics: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforeInsert = ttStatisticsBeforeInsert
    BeforeEdit = ttStatisticsBeforeEdit
    BeforeDelete = ttStatisticsBeforeDelete
    AfterScroll = ttStatisticsAfterScroll
    Parameters = <>
    SQL.Strings = (
      'select * from [vw_STATISTICS]')
    Left = 544
    Top = 96
    object ttStatisticsID: TGuidField
      FieldName = 'ID'
      ReadOnly = True
      FixedChar = True
      Size = 38
    end
    object ttStatisticsPLUGIN: TWideStringField
      FieldName = 'PLUGIN'
      ReadOnly = True
      Size = 50
    end
    object ttStatisticsNO: TIntegerField
      FieldName = 'NO'
      ReadOnly = True
    end
    object ttStatisticsNAME: TWideStringField
      FieldName = 'NAME'
      ReadOnly = True
      Size = 100
    end
  end
  object dsStatistics: TDataSource
    DataSet = ttStatistics
    Left = 544
    Top = 168
  end
  object ttCommission: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforeInsert = ttCommissionBeforeInsert
    BeforeEdit = ttCommissionBeforeEdit
    BeforeDelete = ttCommissionBeforeDelete
    AfterScroll = ttCommissionAfterScroll
    Parameters = <>
    SQL.Strings = (
      'select * from vw_COMMISSION')
    Left = 352
    Top = 88
    object ttCommissionID: TGuidField
      FieldName = 'ID'
      ReadOnly = True
      FixedChar = True
      Size = 38
    end
    object ttCommissionARTIST_ID: TGuidField
      FieldName = 'ARTIST_ID'
      ReadOnly = True
      FixedChar = True
      Size = 38
    end
    object ttCommissionIS_ARTIST: TBooleanField
      FieldKind = fkCalculated
      FieldName = 'IS_ARTIST'
      ReadOnly = True
      Calculated = True
    end
    object ttCommissionNAME: TWideStringField
      FieldName = 'NAME'
      ReadOnly = True
      Size = 100
    end
    object ttCommissionFOLDER: TWideStringField
      FieldName = 'FOLDER'
      ReadOnly = True
      Size = 200
    end
    object ttCommissionPROJECT_NAME: TWideStringField
      FieldName = 'PROJECT_NAME'
      ReadOnly = True
      Size = 155
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
    object ttCommissionMANDATOR_ID: TGuidField
      FieldName = 'MANDATOR_ID'
      ReadOnly = True
      FixedChar = True
      Size = 38
    end
    object ttCommissionARTIST_NAME: TWideStringField
      FieldName = 'ARTIST_NAME'
      ReadOnly = True
      Size = 50
    end
  end
  object dsCommission: TDataSource
    DataSet = ttCommission
    Left = 360
    Top = 160
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 750
    OnTimer = Timer1Timer
    Left = 792
    Top = 16
  end
  object sdCsvArtists: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 196
    Top = 219
  end
  object sdCsvClients: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 276
    Top = 219
  end
  object sdCsvCommission: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 364
    Top = 227
  end
  object sdCsvStatistics: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 556
    Top = 227
  end
  object ttPayment: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforeInsert = ttPaymentBeforeInsert
    BeforeEdit = ttPaymentBeforeEdit
    BeforePost = ttPaymentBeforePost
    BeforeDelete = ttPaymentBeforeDelete
    AfterScroll = ttPaymentAfterScroll
    Parameters = <>
    SQL.Strings = (
      'select * from vw_PAYMENT')
    Left = 448
    Top = 96
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
    object ttPaymentARTIST_NAME2: TWideStringField
      FieldName = 'ARTIST_NAME'
      Size = 50
    end
    object ttPaymentARTIST_NAME: TWideStringField
      FieldName = 'ARTIST_OR_CLIENT_NAME'
      Size = 100
    end
  end
  object dsPayment: TDataSource
    DataSet = ttPayment
    Left = 448
    Top = 152
  end
  object sdCsvPayment: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 452
    Top = 235
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer2Timer
    Left = 744
    Top = 16
  end
end
