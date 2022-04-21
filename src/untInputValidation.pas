unit untInputValidation;

interface

uses
  System.Generics.Collections,
  System.RegularExpressionsCore;

type
  TDictNameToRegexp = TDictionary<string, TPerlRegEx>;

  TRegexpSnippets = class(TDictionary<string, TPerlRegEx>)
  private
  function getSnippet(const key: string): string;
  public
    procedure free;
    function generateSnippets(keys: array of string): TRegexpSnippets;
  end;

function generateInputValidations(keys: array of string): TDictNameToRegexp;

implementation
uses
  System.sysUtils,
  FMX.Dialogs;

type
  snippet = record
    key, value: string;
  end;

const
  snippetList: array [0 .. 3] of snippet = (
  (key: 'any'; value: '.*'), // match anything
  (key: '!alnum'; value: '[^[:alnum:]]'), // not alphanumeric
  (key: '!rNum'; value: '[^[:digit:],.]'), // not real numbers
  (key: '!iNum'; value: '[^[:digit:]]') // not integers
  );



function TRegexpSnippets.getSnippet(const key: string): string;
begin
  for var snippet in snippetList do
    if key = snippet.key then
      exit(snippet.value);

  raise Exception.CreateFmt('No match for candidate key: %s', [key]);
end;

procedure TRegexpSnippets.free;
begin

for var snippet in Values do
begin
snippet.Free;
end;

inherited;
end;

function TRegexpSnippets.generateSnippets(keys: array of string): TRegexpSnippets;
begin

end;


// generate input validations
function generateInputValidations(keys: array of string): TDictNameToRegexp;
begin
  var
  i := length(keys);

  if i = 0 then
    raise EArgumentOutOfRangeException.Create('Not enough actual parameters');

  result := TDictNameToRegexp.Create(i);
  {
  result.OnValueNotify := procedure(Sender: TObject; const item: TPerlRegEx;
  action: TCollectionNotification) begin
  showMessage('tehoutenhs');
  end;
  }

  try
    for var key in keys do
    begin
    result.Add(key, TPerlRegEx.Create);
    result[key].RegEx := getRegexp(key);
    result[key].Study;
    end;
  except
    on Exception do
    begin
      for var value in result.Values.ToArray do
        value.Free;
      freeAndNil(result);
      raise
    end;
  end;

end; { generateInputValidations end }

end.
