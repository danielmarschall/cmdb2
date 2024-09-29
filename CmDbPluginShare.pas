unit CmDbPluginShare;

interface

uses
  SysUtils;

type
  TCmDbPluginClickResponseAction = (craNone, craObject, craStatistics);

type
  // TODO: These shortstrings are not Unicode capable. What to do?
  TCmDbPluginClickResponse = packed record              // Variant Record
    Handled: Boolean;                                   // 1 byte (packed)
    case Action: TCmDbPluginClickResponseAction of      // 1 byte (packed)
      craNone: (                                        // --- Variant 1
        ReservedNone: array[0..4093] of AnsiChar;       // 4094 bytes to fill up to 4096
      );
      craObject: (                                      // --- Variant 2
        ObjTable: string[100];                          // 101 bytes (100 chars + 1 byte for length)
        ObjId: TGuid;                                   // 16 bytes
        ReservedObject: array[0..3976] of AnsiChar;     // 3977 bytes to fill up to 4096
      );
      craStatistics: (                                  // --- Variant 3
        StatId: TGuid;                                  // 16 bytes
        StatName: string[100];                          // 101 bytes (100 chars + 1 byte for length)
        SqlTable: string[100];                          // 101 bytes (100 chars + 1 byte for length)
        SqlInitialOrder: string[250];                   // 251 bytes (250 chars + 1 byte for length)
        SqlAdditionalFilter: string[250];               // 251 bytes (250 chars + 1 byte for length)
        BaseTableDelete: string[100];                   // 101 bytes (100 chars + 1 byte for length)
        ReservedStatistics: array[0..3272] of AnsiChar; // 3273 bytes to fill up to 4096
      );
  end;
  PCmDbPluginClickResponse = ^TCmDbPluginClickResponse;

const
  GUID_NIL: TGUID = '{00000000-0000-0000-0000-000000000000}';

function TempTableName(guid: TGUID; info: string): string;

implementation

function TempTableName(guid: TGUID; info: string): string;
begin
  result := 'tmp_'+guid.ToString.Replace('-','').Replace('{','').Replace('}','')+'_'+info;
end;

end.
