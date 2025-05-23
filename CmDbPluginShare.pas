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
    ScrollToEnd: boolean;
    DisplayEditFormats: string; // Format example: AMOUNT||#,##0.00 USD||#,##0.00||AMOUNT_LOCAL||#,##0.00 EUR||#,##0.00||...
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
  // see https://www.viathinksoft.de/std/viathinksoft-std-0018-dll-plugin-info.html
  TVtsPluginID = function(lpTypeOut: PGUID; lpIdOut: PGUID; lpVerOut: PDWORD; lpAuthorInfo: Pointer): HRESULT; stdcall;

const
  S_PLUGIN_OK:                HRESULT = HRESULT($20000000); // Success, Customer defined, Facility 0, Code 0
  E_PLUGIN_GENERIC_FAILURE:   HRESULT = HRESULT($A0000000); // Failure, Customer defined, Facility 0, Code 0
  E_PLUGIN_BAD_ARGS:          HRESULT = HRESULT($A0000001); // Failure, Customer defined, Facility 0, Code 1
  E_PLUGIN_CONN_FAIL:         HRESULT = HRESULT($A0000002); // Failure, Customer defined, Facility 0, Code 2

const
  // Item-GUIDs usually indicate where you want to GO TO,
  // however, if one of these GUIDs are used, then they describe
  // where you COME FROM, i.e. directly from the Mandator form (first call),
  // or via the refresh button
  GUID_ORIGIN_MANDATOR: TGUID = '{30E52A13-04D8-4500-B4F1-FDFEF8D1474A}';
  GUID_ORIGIN_REFRESH: TGUID = '{07431C16-C51A-4194-8FB2-1FF84A72E5CC}';

const
  TEMP_TABLE_PREFIX = 'tmp_';

function TempTableName(guid: TGUID; info: string): string;

implementation

function TempTableName(guid: TGUID; info: string): string;
begin
  result := TEMP_TABLE_PREFIX+guid.ToString.Replace('-','').Replace('{','').Replace('}','')+'_'+info;
end;

function _ReadWideString(var Src: PByte): WideString;
var
  I: Integer;
  LengthWord: Word;
begin
  // Die L�nge als Word (16 Bit) lesen
  LengthWord := PWord(Src)^;
  Inc(Src, 2);  // Weiter zum ersten WideChar, 2 Bytes f�r das Word

  // Den Result-String auf die L�nge des gelesenen Wertes setzen
  SetLength(Result, LengthWord);

  // WideChars auslesen und dem Result-String zuweisen
  for I := 1 to LengthWord do
  begin
    Result[I] := PWideChar(Src)^;
    Inc(Src, 2);  // Weiter zum n�chsten WideChar, 2 Bytes pro WideChar
  end;
end;

procedure _WriteWideString(var Dest: PByte; const Value: WideString);
var
  I: Integer;
  LengthWord: Word;
begin
  // L�nge des Strings als Word (16 Bit) speichern
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

function _ReadBool(var Src: PByte): Boolean;
begin
  // Das Byte lesen und True bei 1, False bei 0 zur�ckgeben
  Result := PByte(Src)^ = 1;
  Inc(Src, 1);  // Weiter zur n�chsten Speicherposition nach dem Byte
end;

procedure _WriteBool(var Dest: PByte; const Value: Boolean);
begin
  // Speichert 1 f�r True und 0 f�r False
  if Value then
    PByte(Dest)^ := 1
  else
    PByte(Dest)^ := 0;

  Inc(Dest, 1);  // Weiter zur n�chsten Speicherposition nach dem Byte
end;

{ TCmDbPluginClickResponse }

procedure TCmDbPluginClickResponse.ReadFromMemory(const Memory: Pointer);
var
  Ptr: PByte;
begin
  Ptr := PByte(Memory);
  Self.Handled := Boolean(Ptr^); // Read Boolean from Byte
  Inc(Ptr);
  Self.Action := TCmDbPluginClickResponseAction(Ptr^); // Read Action from Byte
  Inc(Ptr);

  case Self.Action of
    craObject:
    begin
      Self.ObjTable := _ReadWideString(Ptr);   // Read ObjTable
      Move(Ptr^, Self.ObjId, SizeOf(TGuid));  // Read GUID directly
      Inc(Ptr, SizeOf(TGuid));
    end;
    craStatistics:
    begin
      Move(Ptr^, Self.StatId, SizeOf(TGuid));  // Read GUID directly
      Inc(Ptr, SizeOf(TGuid));
      Self.StatName := _ReadWideString(Ptr);       // Read StatName
      Self.SqlTable := _ReadWideString(Ptr);       // Read SqlTable
      Self.SqlInitialOrder := _ReadWideString(Ptr);// Read SqlInitialOrder
      Self.SqlAdditionalFilter := _ReadWideString(Ptr); // Read SqlAdditionalFilter
      Self.BaseTableDelete := _ReadWideString(Ptr); // Read BaseTableDelete
      Self.ScrollToEnd := _ReadBool(Ptr);
      Self.DisplayEditFormats := _ReadWideString(Ptr);
    end;
  end;
end;

procedure TCmDbPluginClickResponse.WriteToMemory(const Memory: Pointer);
var
  Ptr: PByte;
begin
  Ptr := PByte(Memory);
  Ptr^ := Ord(Self.Handled);  // Write Boolean as Byte
  Inc(Ptr);
  Ptr^ := Ord(Self.Action);   // Write Action as Byte
  Inc(Ptr);

  case Self.Action of
    craObject:
    begin
      _WriteWideString(Ptr, Self.ObjTable);  // Write ObjTable as WideString
      Move(Self.ObjId, Ptr^, SizeOf(TGuid)); // Copy GUID directory
      Inc(Ptr, SizeOf(TGuid));
    end;
    craStatistics:
    begin
      Move(Self.StatId, Ptr^, SizeOf(TGuid));  // Copy GUID directly
      Inc(Ptr, SizeOf(TGuid));
      _WriteWideString(Ptr, Self.StatName);       // StatName
      _WriteWideString(Ptr, Self.SqlTable);       // SqlTable
      _WriteWideString(Ptr, Self.SqlInitialOrder);// SqlInitialOrder
      _WriteWideString(Ptr, Self.SqlAdditionalFilter); // SqlAdditionalFilter
      _WriteWideString(Ptr, Self.BaseTableDelete); // BaseTableDelete
      _WriteBool(Ptr, Self.ScrollToEnd);
      _WriteWideString(Ptr, Self.DisplayEditFormats);
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
