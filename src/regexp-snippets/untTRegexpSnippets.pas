unit untTRegexpSnippets;

interface
uses
  System.Generics.Collections,
  System.RegularExpressionscore;


type
  TRegexpSnippets = class(TDictionary<string, TPerlRegEx>)
  private
    function getSnippet(const key: string): string;
  public
    procedure free;
    procedure compileSnippets(keys: array of string);
  end;


implementation
uses
  untSnippets;


