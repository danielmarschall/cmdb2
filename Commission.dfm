object CommissionForm: TCommissionForm
  Left = 0
  Top = 0
  Caption = 'CommissionForm'
  ClientHeight = 583
  ClientWidth = 758
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
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  TextHeight = 15
  object PageControl1: TPageControl
    Left = 0
    Top = 41
    Width = 758
    Height = 542
    ActivePage = tsEvents
    Align = alClient
    TabOrder = 0
    object tsEvents: TTabSheet
      Caption = 'Events/Quotes/Uploads'
      ImageIndex = 1
      object Splitter1: TSplitter
        Left = 0
        Top = 209
        Width = 750
        Height = 3
        Cursor = crVSplit
        Align = alTop
        ExplicitWidth = 167
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 750
        Height = 209
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object navEvents: TDBNavigator
          Left = 0
          Top = 0
          Width = 33
          Height = 209
          DataSource = dsEvents
          VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
          Align = alLeft
          Kind = dbnVertical
          TabOrder = 1
        end
        object dbgEvents: TDBGrid
          Left = 33
          Top = 0
          Width = 717
          Height = 209
          Align = alClient
          DataSource = dsEvents
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          OnKeyDown = dbgEventsKeyDown
          OnTitleClick = dbgEventsTitleClick
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
                'idea'
                'c td initcm'
                'c aw ack'
                'quote'
                'c aw sk'
                'c td feedback'
                'c aw cont'
                'c aw hires'
                'fin'
                'annot'
                'cancel a'
                'cancel c'
                'rejected'
                'postponed'
                'upload a'
                'upload c'
                'upload x')
              Width = 94
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'ANNOTATION'
              Width = 352
              Visible = True
            end>
        end
      end
      object PageControl2: TPageControl
        Left = 0
        Top = 212
        Width = 750
        Height = 300
        ActivePage = tsUploads
        Align = alClient
        TabOrder = 1
        object tsQuotes: TTabSheet
          Caption = 'Quote'
          object navQuotes: TDBNavigator
            Left = 0
            Top = 0
            Width = 33
            Height = 270
            DataSource = dsQuotes
            VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
            Align = alLeft
            Kind = dbnVertical
            TabOrder = 0
          end
          object dbgQuotes: TDBGrid
            Left = 33
            Top = 0
            Width = 709
            Height = 270
            Align = alClient
            DataSource = dsQuotes
            TabOrder = 1
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -12
            TitleFont.Name = 'Segoe UI'
            TitleFont.Style = []
            OnKeyDown = dbgQuotesKeyDown
            OnTitleClick = dbgQuotesTitleClick
            Columns = <
              item
                Expanded = False
                FieldName = 'NO'
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
                FieldName = 'IS_FREE'
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'DESCRIPTION'
                Width = 261
                Visible = True
              end>
          end
        end
        object tsUploads: TTabSheet
          Caption = 'Upload'
          ImageIndex = 1
          object navUploads: TDBNavigator
            Left = 0
            Top = 0
            Width = 33
            Height = 270
            DataSource = dsUploads
            VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
            Align = alLeft
            Kind = dbnVertical
            TabOrder = 0
          end
          object dbgUploads: TDBGrid
            Left = 33
            Top = 0
            Width = 709
            Height = 270
            Align = alClient
            DataSource = dsUploads
            TabOrder = 1
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -12
            TitleFont.Name = 'Segoe UI'
            TitleFont.Style = []
            OnDblClick = dbgUploadsDblClick
            OnKeyDown = dbgUploadsKeyDown
            OnTitleClick = dbgUploadsTitleClick
            Columns = <
              item
                Expanded = False
                FieldName = 'NO'
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'PAGE'
                Width = 131
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'URL'
                Width = 242
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'PROHIBIT'
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'ANNOTATION'
                Width = 200
                Visible = True
              end>
          end
        end
      end
    end
    object tsFiles: TTabSheet
      Caption = 'Files'
      ImageIndex = 1
      object ShellListView: TShellListView
        AlignWithMargins = True
        Left = 3
        Top = 44
        Width = 744
        Height = 465
        AutoNavigate = False
        ObjectTypes = [otFolders, otNonFolders]
        Root = 'c:\'
        Sorted = True
        Align = alClient
        ColumnClick = False
        OnDblClick = ShellListViewDblClick
        ReadOnly = False
        GridLines = True
        HideSelection = False
        TabOrder = 0
        ViewStyle = vsReport
      end
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 750
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          750
          41)
        object FolderEdit: TEdit
          Left = 8
          Top = 8
          Width = 563
          Height = 23
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          Text = 'FolderEdit'
        end
        object BtnFolderSelect: TButton
          Left = 577
          Top = 8
          Width = 50
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Select'
          TabOrder = 1
          OnClick = BtnFolderSelectClick
        end
        object BtnFolderOpen: TButton
          Left = 690
          Top = 8
          Width = 51
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Open'
          TabOrder = 3
          OnClick = BtnFolderOpenClick
        end
        object BtnFolderSave: TButton
          Left = 633
          Top = 8
          Width = 51
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Save'
          TabOrder = 2
          OnClick = BtnFolderSaveClick
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 758
    Height = 41
    Align = alTop
    Color = clCadetblue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = 27
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 1
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
      TabOrder = 0
      OnClick = HelpBtnClick
    end
    object GoBackBtn: TButton
      Left = 43
      Top = 10
      Width = 25
      Height = 25
      Hint = 'Go back to Artist/Client'
      Caption = '<'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 20
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = GoBackBtnClick
    end
  end
  object dsQuotes: TDataSource
    DataSet = ttQuotes
    Left = 56
    Top = 424
  end
  object ttQuotes: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforePost = ttQuotesBeforePost
    AfterPost = ttQuotesAfterPost
    BeforeDelete = ttQuotesBeforeDelete
    OnNewRecord = ttQuotesNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * from vw_QUOTE')
    Left = 56
    Top = 360
    object ttQuotesID: TGuidField
      FieldName = 'ID'
      FixedChar = True
      Size = 38
    end
    object ttQuotesEVENT_ID: TGuidField
      FieldName = 'EVENT_ID'
      FixedChar = True
      Size = 38
    end
    object ttQuotesNO: TIntegerField
      FieldName = 'NO'
    end
    object ttQuotesAMOUNT: TBCDField
      FieldName = 'AMOUNT'
      Precision = 19
    end
    object ttQuotesCURRENCY: TWideStringField
      FieldName = 'CURRENCY'
      Size = 3
    end
    object ttQuotesAMOUNT_LOCAL: TBCDField
      FieldName = 'AMOUNT_LOCAL'
      OnGetText = ttQuotesAMOUNT_LOCALGetText
      Precision = 19
    end
    object ttQuotesDESCRIPTION: TWideStringField
      FieldName = 'DESCRIPTION'
      Size = 100
    end
    object ttQuotesIS_FREE: TBooleanField
      FieldName = 'IS_FREE'
    end
  end
  object ADOConnection1: TADOConnection
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 88
    Top = 72
  end
  object ttEvents: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    BeforePost = ttEventsBeforePost
    BeforeDelete = ttEventsBeforeDelete
    AfterScroll = ttEventsAfterScroll
    OnNewRecord = ttEventsNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * from vw_COMMISSION_EVENT')
    Left = 184
    Top = 96
    object ttEventsID: TGuidField
      FieldName = 'ID'
      FixedChar = True
      Size = 38
    end
    object ttEventsCOMMISSION_ID: TGuidField
      FieldName = 'COMMISSION_ID'
      FixedChar = True
      Size = 38
    end
    object ttEventsDATE: TDateTimeField
      FieldName = 'DATE'
    end
    object ttEventsSTATE: TWideStringField
      FieldName = 'STATE'
    end
    object ttEventsANNOTATION: TWideStringField
      DisplayWidth = 50
      FieldName = 'ANNOTATION'
      Size = 200
    end
  end
  object dsEvents: TDataSource
    DataSet = ttEvents
    Left = 184
    Top = 152
  end
  object ttUploads: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    AfterPost = ttUploadsAfterPost
    BeforeDelete = ttUploadsBeforeDelete
    OnNewRecord = ttUploadsNewRecord
    Parameters = <>
    SQL.Strings = (
      'select * from vw_UPLOAD')
    Left = 120
    Top = 360
    object ttUploadsID: TGuidField
      FieldName = 'ID'
      FixedChar = True
      Size = 38
    end
    object ttUploadsEVENT_ID: TGuidField
      FieldName = 'EVENT_ID'
      FixedChar = True
      Size = 38
    end
    object ttUploadsNO: TIntegerField
      FieldName = 'NO'
    end
    object ttUploadsPAGE: TWideStringField
      FieldName = 'PAGE'
      Size = 50
    end
    object ttUploadsURL: TWideStringField
      FieldName = 'URL'
      Size = 150
    end
    object ttUploadsPROHIBIT: TBooleanField
      FieldName = 'PROHIBIT'
    end
    object ttUploadsANNOTATION: TWideStringField
      FieldName = 'ANNOTATION'
      Size = 100
    end
    object ttUploadsLEGACY_ID: TIntegerField
      FieldName = 'LEGACY_ID'
    end
  end
  object dsUploads: TDataSource
    DataSet = ttUploads
    Left = 120
    Top = 424
  end
  object ShellChangeNotifier: TShellChangeNotifier
    NotifyFilters = [nfFileNameChange, nfDirNameChange, nfSizeChange, nfWriteChange]
    Root = 'C:\'
    WatchSubTree = True
    OnChange = ShellChangeNotifierChange
    Left = 264
    Top = 96
  end
end
