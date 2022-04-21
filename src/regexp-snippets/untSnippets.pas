unit untSnippets;

interface
type
  snippet = record
    key: string;
    value: string;
  end;

const
  COUNT_SNIPPET = 6;
  LIST_SNIPPET: array[0..COUNT_SNIPPET - 1] of snippet = (
    // anything
    (key: 'any'; value: '.'),
    // anything other than an alphanumeric character
    (key: '!alnum'; value: '[^[:alnum:]]'), // not alphanumeric
    // anything other than the syntax of a real number
    (key: '!rNum'; value: '[^[:digit:],.]'),
    // the syntax of a real number
    (key: 'rNum'; value: '[[:digit:]]+[.|,][[:digit:]]*'),
    // anything other than the syntax of an integer
    (key: '!iNum'; value: '[^[:digit:]]'),
    // the syntax of an integer
    (key: 'iNum'; value: '[[:digit:]]')
  );


begin
end.




