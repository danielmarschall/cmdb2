unit CmDbPluginShare;

interface

uses
  Windows, SysUtils;

type
  TCmDbPluginClickResponseAction = (craNone, craAbort, craObject, craStatistics);

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
    procedure WriteToMemory(const Memory: Pointer);
    procedure ReadFromMemory(const Memory: Pointer);
  end;

  TVtsPluginAuthorInfo = record
    PluginName: string;
    PluginAuthor: string;
    PluginVersion: string;
    PluginCopyright: string;
    PluginLicense: string;
    PluginMoreInfo: string;
    // Read/Write functions
    procedure WriteToMemory(const Memory: Pointer);
    procedure ReadFromMemory(const Memory: Pointer);
  end;

const
  CMDB2_STATSPLUGIN_V1_TYPE: TGUID = '{73273740-08BA-4E6E-BAAA-D4676E5B1BFF}';

type
  // Note: This technique should be used by all DLL based ViaThinkSoft plugin architectures, not just CMDB2
  TVtsPluginID = function(lpTypeOut: PGUID; lpIdOut: PGUID; lpVerOut: PDWORD; lpAuthorInfo: Pointer): HRESULT; stdcall;

const
  S_PLUGIN_OK:                HRESULT = HRESULT($20000000); // Success, Customer defined, Facility 0, Code 0
  E_PLUGIN_GENERIC_FAILURE:   HRESULT = HRESULT($A0000000); // Failure, Customer defined, Facility 0, Code 0
  E_PLUGIN_BAD_ARGS:          HRESULT = HRESULT($A0000001); // Failure, Customer defined, Facility 0, Code 1
  E_PLUGIN_CONN_FAIL:         HRESULT = HRESULT($A0000002); // Failure, Customer defined, Facility 0, Code 2

const
  GUID_NIL: TGUID = '{00000000-0000-0000-0000-000000000000}';

function TempTableName(guid: TGUID; info: string): string;

implementation

function TempTableName(guid: TGUID; info: string): string;
begin
  result := 'tmp_'+guid.ToString.Replace('-','').Replace('{','').Replace('}','')+'_'+info;
end;

function _ReadWideString(var Src: PByte): WideString;
var
  I: Integer;
  LengthWord: Word;
begin
  // Die Länge als Word (16 Bit) lesen
  LengthWord := PWord(Src)^;
  Inc(Src, 2);  // Weiter zum ersten WideChar, 2 Bytes für das Word

  // Den Result-String auf die Länge des gelesenen Wertes setzen
  SetLength(Result, LengthWord);

  // WideChars auslesen und dem Result-String zuweisen
  for I := 1 to LengthWord do
  begin
    Result[I] := PWideChar(Src)^;
    Inc(Src, 2);  // Weiter zum nächsten WideChar, 2 Bytes pro WideChar
  end;
end;

procedure _WriteWideString(var Dest: PByte; const Value: WideString);
var
  I: Integer;
  LengthWord: Word;
begin
  // Länge des Strings als Word (16 Bit) speichern
  LengthWord := Length(Value);
  PWord(Dest)^ := LengthWord;
  Inc(Dest, 2);  // Weiter zur ersten Speicherposition nach dem Word

  // Zeichen als WideChars schreiben
  for I := 1 to LengthWord do
  begin
    PWideChar(Dest)^ := Value[I];
    Inc(Dest, 2);  // WideChar belegt 2 Bytes
  end;
end;

{ TCmDbPluginClickResponse }

procedure TCmDbPluginClickResponse.ReadFromMemory(const Memory: Pointer);
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
      Self.ObjTable := _ReadWideString(Ptr);   // ObjTable lesen
      Move(Ptr^, Self.ObjId, SizeOf(TGuid));  // GUID direkt lesen
      Inc(Ptr, SizeOf(TGuid));
    end;
    craStatistics:
    begin
      Move(Ptr^, Self.StatId, SizeOf(TGuid));  // GUID direkt lesen
      Inc(Ptr, SizeOf(TGuid));
      Self.StatName := _ReadWideString(Ptr);       // StatName lesen
      Self.SqlTable := _ReadWideString(Ptr);       // SqlTable lesen
      Self.SqlInitialOrder := _ReadWideString(Ptr);// SqlInitialOrder lesen
      Self.SqlAdditionalFilter := _ReadWideString(Ptr); // SqlAdditionalFilter lesen
      Self.BaseTableDelete := _ReadWideString(Ptr); // BaseTableDelete lesen
    end;
  end;
end;

procedure TCmDbPluginClickResponse.WriteToMemory(const Memory: Pointer);
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
      _WriteWideString(Ptr, Self.ObjTable);  // ObjTable als WideString schreiben
      Move(Self.ObjId, Ptr^, SizeOf(TGuid)); // GUID direkt kopieren
      Inc(Ptr, SizeOf(TGuid));
    end;
    craStatistics:
    begin
      Move(Self.StatId, Ptr^, SizeOf(TGuid));  // GUID direkt kopieren
      Inc(Ptr, SizeOf(TGuid));
      _WriteWideString(Ptr, Self.StatName);       // StatName
      _WriteWideString(Ptr, Self.SqlTable);       // SqlTable
      _WriteWideString(Ptr, Self.SqlInitialOrder);// SqlInitialOrder
      _WriteWideString(Ptr, Self.SqlAdditionalFilter); // SqlAdditionalFilter
      _WriteWideString(Ptr, Self.BaseTableDelete); // BaseTableDelete
    end;
  end;
end;

{ TVtsPluginAuthorInfo }

procedure TVtsPluginAuthorInfo.ReadFromMemory(const Memory: Pointer);
var
  Ptr: PByte;
begin
  Ptr := PByte(Memory);
  Self.PluginName := _ReadWideString(Ptr);
  Self.PluginAuthor := _ReadWideString(Ptr);
  Self.PluginVersion := _ReadWideString(Ptr);
  Self.PluginCopyright := _ReadWideString(Ptr);
  Self.PluginLicense := _ReadWideString(Ptr);
  Self.PluginMoreInfo := _ReadWideString(Ptr);
end;

procedure TVtsPluginAuthorInfo.WriteToMemory(const Memory: Pointer);
var
  Ptr: PByte;
begin
  Ptr := PByte(Memory);
  _WriteWideString(Ptr, Self.PluginName);
  _WriteWideString(Ptr, Self.PluginAuthor);
  _WriteWideString(Ptr, Self.PluginVersion);
  _WriteWideString(Ptr, Self.PluginCopyright);
  _WriteWideString(Ptr, Self.PluginLicense);
  _WriteWideString(Ptr, Self.PluginMoreInfo);
end;

end.
