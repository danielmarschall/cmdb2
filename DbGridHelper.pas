unit DbGridHelper;

interface

uses
  Windows, System.Classes, Data.DB, Vcl.DBGrids;

type
  TDBGridHelper = class helper for TDbGrid
    function AutoSizeColumns(NoDatasetWidth:integer=120; MaxColWidth:integer=500): Integer;
    procedure HideColumn(const AFieldName: string);
    procedure HideColumnPrefix(const AFieldNamePrefix: string);
    procedure HandleOtherControlKeyDown(var Key: Word; Shift: TShiftState);
  end;

implementation

uses
  Math, StrUtils;

type
  TDBGridAccessor = class(TDBGrid);

// Source: https://stackoverflow.com/questions/13292937/how-to-auto-fit-scale-dbgrids-or-other-similar-columns-widths-according-to-it
// Modified
function TDBGridHelper.AutoSizeColumns(NoDatasetWidth:integer=120; MaxColWidth:integer=500): Integer;
var
  DataSet: TDataSet;
  Bookmark: TBookmark;
  Count, I: Integer;
  ColumnsWidth: array of Integer;
begin
  SetLength(ColumnsWidth, Self.Columns.Count);
  for I := 0 to Self.Columns.Count - 1 do
    if Self.Columns[I].Visible then
      ColumnsWidth[I] := Self.Canvas.TextWidth(Self.Columns[I].Title.Caption + '   ')
    else
      ColumnsWidth[I] := 0;
  if Self.DataSource <> nil then
    DataSet := Self.DataSource.DataSet
  else
    DataSet := nil;
  if (DataSet <> nil) and DataSet.Active then
  begin
    Bookmark := DataSet.GetBookmark;
    DataSet.DisableControls;
    try
      DataSet.First;
      if DataSet.EOF then
      begin
        for I := 0 to Self.Columns.Count - 1 do
        begin
          if ColumnsWidth[I] < NoDatasetWidth then ColumnsWidth[I] := NoDatasetWidth;
        end;
      end;
      while not DataSet.Eof do
      begin
        for I := 0 to Self.Columns.Count - 1 do
        begin
          if Self.Columns[I].Visible then
          begin
            ColumnsWidth[I] := Max(ColumnsWidth[I], Self.Canvas.TextWidth(Self.Columns[I].Field.Text)+50(*Because TextWidth is too small?!*));
          end;
        end;
        DataSet.Next;
      end;
    finally
      DataSet.GotoBookmark(Bookmark);
      DataSet.FreeBookmark(Bookmark);
      DataSet.EnableControls;
    end;
  end;
  Count := 0;
  for I := 0 to Self.Columns.Count - 1 do
  begin
    if ColumnsWidth[I] > MaxColWidth then
      ColumnsWidth[I] := MaxColWidth;
    if Self.Columns[I].Visible then
    begin
      Self.Columns[I].Width := ColumnsWidth[I];
      Inc(Count, ColumnsWidth[I]);
    end;
  end;
  Result := Count - Self.ClientWidth;
end;

procedure TDBGridHelper.HandleOtherControlKeyDown(var Key: Word; Shift: TShiftState);
begin
  if Shift = [ssCtrl] then
  begin
    if Key = VK_DELETE then
    begin
      Key := 0;
      Self.DataSource.DataSet.Delete;
    end;
  end
  else if Shift = [] then
  begin
    if (Key = VK_ESCAPE) and (Self.DataSource.DataSet.State in [dsEdit,dsInsert]) then
    begin
      Key := 0;
      Self.DataSource.DataSet.Cancel;
    end
    else if Key = VK_INSERT then
    begin
      Key := 0;
      Self.DataSource.DataSet.Insert;
      if Self.CanFocus then Self.SetFocus; // so that the user can start entering stuff!
    end
    else if Key = VK_HOME then
    begin
      Key := 0;
      Self.DataSource.Dataset.First;
    end
    else if Key = VK_END then
    begin
      Key := 0;
      Self.DataSource.Dataset.Last;
    end
    else if Key = VK_NEXT then
    begin
      Key := 0;
      Self.DataSource.Dataset.MoveBy((Self.ClientHeight - TDBGridAccessor(Self).RowHeights[0]) div TDBGridAccessor(Self).DefaultRowHeight);
    end
    else if Key = VK_PRIOR then
    begin
      Key := 0;
      Self.DataSource.Dataset.MoveBy(-(Self.ClientHeight - TDBGridAccessor(Self).RowHeights[0]) div TDBGridAccessor(Self).DefaultRowHeight);
    end
    else if Key = VK_UP then
    begin
      Key := 0;
      Self.DataSource.Dataset.Prior;
    end
    else if Key = VK_DOWN then
    begin
      Key := 0;
      Self.DataSource.Dataset.Next;
    end
    else if Key = VK_RETURN then
    begin
      if Assigned(Self.OnDblClick) then
      begin
        Key := 0;
        Self.OnDblClick(Self);
      end;
    end;
  end;
end;

procedure TDBGridHelper.HideColumn(const AFieldName: string);
var i: integer;  //array index
begin
  for i:= 0 to Self.FieldCount -1 do
  begin
    if Self.Columns[i].FieldName = AFieldName then
    begin
      Self.Columns[i].Visible := false;
    end;
  end;
end;

procedure TDBGridHelper.HideColumnPrefix(const AFieldNamePrefix: string);
var i: integer;  //array index
begin
  for i:= 0 to Self.FieldCount -1 do
  begin
    if StartsText(AFieldNamePrefix, Self.Columns[i].FieldName) then
    begin
      Self.Columns[i].Visible := false;
    end;
  end;
end;

end.
