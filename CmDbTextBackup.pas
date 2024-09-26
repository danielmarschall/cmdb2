unit CmDbTextBackup;

interface

uses
  Classes, AdoDb;

procedure CompressAndStoreText(AdoConnection1: TAdoConnection; const sl: TStrings);
function RetrieveAndDecompressText(AdoConnection1: TAdoConnection; Id: Integer): string;

implementation

uses
  System.ZLib, SysUtils, DB;

procedure CompressAndStoreText(AdoConnection1: TAdoConnection; const sl: TStrings);
var
  CompressedStream: TMemoryStream;
  InputStream: TStringStream;
  ADOCommand: TADOCommand;
begin
  // Erstellen der Datenbankverbindung
  ADOCommand := TADOCommand.Create(nil);
  CompressedStream := TMemoryStream.Create;
  InputStream := TStringStream.Create(sl.Text, TEncoding.UTF8);

  try
    // Komprimieren des Textes mit ZLib
    InputStream.Position := 0;
    ZCompressStream(InputStream, CompressedStream);
    CompressedStream.Position := 0;

    // SQL-Befehl zum Einfügen der komprimierten Daten
    ADOCommand.Connection := ADOConnection1;
    ADOCommand.CommandText := 'INSERT INTO TEXT_BACKUP (BAK_DATE, BAK_DATA, BAK_LINES) VALUES (getdate(), :CompressedData, :Lines)';
    ADOCommand.Parameters.ParamByName('CompressedData').LoadFromStream(CompressedStream, ftBlob);
    ADOCommand.Parameters.ParamByName('Lines').Value := sl.Count;

    // Ausführen des SQL-Befehls
    ADOCommand.Execute;
  finally
    // Freigeben der Ressourcen
    ADOCommand.Free;
    CompressedStream.Free;
    InputStream.Free;
  end;
end;

function RetrieveAndDecompressText(AdoConnection1: TAdoConnection; Id: Integer): string;
var
  CompressedStream: TMemoryStream;
  DecompressedStream: TStringStream;
  ADOQuery: TADOQuery;
resourcestring
  SDatasetNotFound = 'Datensatz nicht gefunden';
begin
  // Erstellen der Datenbankverbindung
  ADOQuery := TADOQuery.Create(nil);
  CompressedStream := TMemoryStream.Create;
  DecompressedStream := TStringStream.Create('', TEncoding.UTF8);

  try
    // SQL-Befehl zum Abrufen der komprimierten Daten
    ADOQuery.Connection := ADOConnection1;
    ADOQuery.SQL.Text := 'SELECT BAK_DATA FROM TEXT_BACKUP WHERE BAK_ID = :Id';
    ADOQuery.Parameters.ParamByName('Id').Value := Id;
    ADOQuery.Open;

    // Komprimierte Daten in den Stream laden
    if not ADOQuery.Eof then
    begin
      TBlobField(ADOQuery.FieldByName('BAK_DATA')).SaveToStream(CompressedStream);
      CompressedStream.Position := 0;

      // Dekomprimieren der Daten
      ZDecompressStream(CompressedStream, DecompressedStream);
      Result := DecompressedStream.DataString;
    end
    else
      raise Exception.Create(SDatasetNotFound);
  finally
    // Freigeben der Ressourcen
    ADOQuery.Free;
    CompressedStream.Free;
    DecompressedStream.Free;
  end;
end;

end.
