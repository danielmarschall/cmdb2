unit CmDbPluginShare;

interface

uses
  SysUtils;

type
  TCmDbPluginClickResponseAction = (craNone, craObject, craStatistics);

type
  TCmDbPluginClickResponse = packed record
    Handled: boolean;
    Action: TCmDbPluginClickResponseAction;
    // Normal object, for Action=CraObject
    ObjTable: string[100];
    ObjId: TGuid;
    // Statistics, for Action=craStatistics
    StatId: TGuid;
    StatName: string[100];
    SqlTable: string[100];
    SqlInitialOrder: string[250];
    SqlAdditionalFilter: string[250];
    BaseTableDelete: string[100];
    Reserved: array[0..4*1024-1] of AnsiChar;
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
