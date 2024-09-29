unit CmDbPluginShare;

interface

uses
  SysUtils;

type
  TCmDbPluginClickResponseAction = (craNone, craObject, craStatistics);

  TCmDbPluginClickResponse = record
    Handled: Boolean;
    Action: TCmDbPluginClickResponseAction;
    // For Action=craObject:
    ObjTable: string;
    ObjId: TGuid;
    // For Action=craStatistics:
    StatId: TGuid;
    StatName: string;
    SqlTable: string;
    SqlInitialOrder: string;
    SqlAdditionalFilter: string;
    BaseTableDelete: string;
    // Read/Write functions
    procedure WritePluginClickResponse(const Memory: Pointer);
    procedure ReadPluginClickResponse(const Memory: Pointer);
  end;



const
  GUID_NIL: TGUID = '{00000000-0000-0000-0000-000000000000}';

function TempTableName(guid: TGUID; info: string): string;

implementation

function TempTableName(guid: TGUID; info: string): string;
begin
  result := 'tmp_'+guid.ToString.Replace('-','').Replace('{','').Replace('}','')+'_'+info;
end;

{ TCmDbPluginClickResponse }

procedure TCmDbPluginClickResponse.WritePluginClickResponse(const Memory: Pointer);

  // Hilfsfunktion: Schreibe einen WideString mit einem Byte Präfix für die Länge
  procedure WriteWideString(var Dest: PByte; const Value: string);
  var
    I, LengthByte: Byte;
  begin
    LengthByte := Length(Value);
    Dest^ := LengthByte;  // Länge als Byte speichern
    Inc(Dest);            // Auf die erste Speicherposition nach dem Byte

    for I := 1 to LengthByte do
    begin
      PWideChar(Dest)^ := Value[I]; // Zeichen als WideChar schreiben
      Inc(Dest, 2);                 // WideChar belegt 2 Bytes
    end;
  end;

var
  Ptr: PByte;
begin
  Ptr := PByte(Memory);
  Ptr^ := Ord(Self.Handled);  // Boolean als Byte schreiben
  Inc(Ptr);
  Ptr^ := Ord(Self.Action);   // Action als Byte schreiben
  Inc(Ptr);

  case Self.Action of
    craObject:
    begin
      WriteWideString(Ptr, Self.ObjTable);  // ObjTable als WideString schreiben
      Move(Self.ObjId, Ptr^, SizeOf(TGuid)); // GUID direkt kopieren
      Inc(Ptr, SizeOf(TGuid));
    end;
    craStatistics:
    begin
      Move(Self.StatId, Ptr^, SizeOf(TGuid));  // GUID direkt kopieren
      Inc(Ptr, SizeOf(TGuid));
      WriteWideString(Ptr, Self.StatName);       // StatName
      WriteWideString(Ptr, Self.SqlTable);       // SqlTable
      WriteWideString(Ptr, Self.SqlInitialOrder);// SqlInitialOrder
      WriteWideString(Ptr, Self.SqlAdditionalFilter); // SqlAdditionalFilter
      WriteWideString(Ptr, Self.BaseTableDelete); // BaseTableDelete
    end;
  end;
end;

// Schreibe die Daten eines Records in einen Speicherblock
// Lese die Daten eines Records aus einem Speicherblock
procedure TCmDbPluginClickResponse.ReadPluginClickResponse(const Memory: Pointer);

  // Hilfsfunktion: Lese einen WideString mit einem Byte Präfix für die Länge
  function ReadWideString(var Src: PByte): string;
  var
    I, LengthByte: Byte;
  begin
    LengthByte := Src^;  // Die Länge aus dem Byte lesen
    Inc(Src);            // Weiter zum ersten WideChar

    SetLength(Result, LengthByte);
    for I := 1 to LengthByte do
    begin
      Result[I] := PWideChar(Src)^;  // WideChar in den String kopieren
      Inc(Src, 2);                   // WideChar belegt 2 Bytes
    end;
  end;

var
  Ptr: PByte;
begin
  Ptr := PByte(Memory);
  Self.Handled := Boolean(Ptr^); // Boolean aus Byte lesen
  Inc(Ptr);
  Self.Action := TCmDbPluginClickResponseAction(Ptr^); // Action aus Byte lesen
  Inc(Ptr);

  case Self.Action of
    craObject:
    begin
      Self.ObjTable := ReadWideString(Ptr);   // ObjTable lesen
      Move(Ptr^, Self.ObjId, SizeOf(TGuid));  // GUID direkt lesen
      Inc(Ptr, SizeOf(TGuid));
    end;
    craStatistics:
    begin
      Move(Ptr^, Self.StatId, SizeOf(TGuid));  // GUID direkt lesen
      Inc(Ptr, SizeOf(TGuid));
      Self.StatName := ReadWideString(Ptr);       // StatName lesen
      Self.SqlTable := ReadWideString(Ptr);       // SqlTable lesen
      Self.SqlInitialOrder := ReadWideString(Ptr);// SqlInitialOrder lesen
      Self.SqlAdditionalFilter := ReadWideString(Ptr); // SqlAdditionalFilter lesen
      Self.BaseTableDelete := ReadWideString(Ptr); // BaseTableDelete lesen
    end;
  end;
end;

end.
