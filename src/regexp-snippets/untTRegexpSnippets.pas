unit untTRegexpSnippets;

interface
uses
  System.Generics.Collections,
  System.RegularExpressionscore;

type
  TRegexpSnippets = class(TDictionary<string, TPerlRegEx>)
    private
      function GetSnippet(const Key:string):string;
    public
      procedure Free;
      procedure CompileSnippets(Keys: array of string);
  end;

implementation
uses
  System.SysUtils,
  FMX.Dialogs,
  UntSnippets;

function TRegexpSnippets.GetSnippet(const Key:string):string;
begin
  for var Snippet in UntSnippets.LIST_SNIPPET do
    if Key = Snippet.Key then
      Exit(Snippet.Value);
  raise Exception.CreateFmt('Unknown snippet: %s',[Key]);
end;

procedure TRegexpSnippets.CompileSnippets(Keys: array of string);
begin
  const
    I = Length(Keys);

    if I = 0 then raise Exception.Create('Not Enough actual parameters');
  Capacity := I;

  try
    for var Key in Keys do
    begin
      if Self.ContainsKey(Key)then
        Continue;
      Self.Add(Key, TPerlRegEx.Create);
      Self[Key].RegEx := GetSnippet(Key);
      // System.regularExpressionsCore suggests that invoking
      // study more than once will increase performance
      Self[Key].Study;
      Self[Key].Study;
    end;
  except
    on Exception do
    begin
      for var Value in Values do
        if Assigned(Value)then
          Value.Free;
      raise;
    end;
  end;

end;

procedure TRegexpSnippets.Free;
begin

  for var Snippet in Values do
    Snippet.Free;
  inherited;

end;

end.
