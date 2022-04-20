unit untInputValidation;

interface
uses
  System.RegularExpressionsCore;

type
  TListInputValidations = TArray<TPerlRegEx>;

function generateInputValidations(keys: array of string): TListInputValidations;

implementation
uses
  System.Generics.Collections,
  System.sysUtils;

var
  mapRegexp: TDictionary<string, string>;

function generateInputValidations(keys: array of string): TListInputValidations;
begin

if length(keys) = 0 then
setLength(result, length(keys));

  for var i := low(keys) to high(keys) do
  begin

  end;

end; { generateInputValidations end }

initialization

mapRegexp := TDictionary<string, string>.Create(1);
mapRegexp.Add('nonAlnum', '^[:alnum:]]');

finalization

freeAndNil(mapRegexp);

end.
