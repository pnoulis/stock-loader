unit untSnippets;

interface
type
  TSnippet = record
    Key:string;
    Value:string;
  end;

const
  COUNT_SNIPPET = 6;
  LIST_SNIPPET: array[0 .. COUNT_SNIPPET - 1] of TSnippet =((Key: 'any';
      Value: '.*'),
      // anything other than an alphanumeric character
      (Key: '!alnum'; Value: '[^[:alnum:]]'),// not alphanumeric
      // anything other than the syntax of a real number
      (Key: '!rNum'; Value: '[^[:digit:],.]'),
      // the syntax of a real number
      (Key: 'rNum'; Value: '[[:digit:]]+[.|,][[:digit:]]*'),
      // anything other than the syntax of an integer
      (Key: '!iNum'; Value: '[^[:digit:]]'),
      // the syntax of an integer
      (Key: 'iNum'; Value: '[[:digit:]]'));

implementation
begin
end.
