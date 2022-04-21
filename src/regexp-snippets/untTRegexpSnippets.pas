unit untTRegexpSnippets;

interface

 uses
  System.Generics.Collections,
  System.RegularExpressionscore;

 type
  TRegexpSnippets = class(TDictionary<string,TPerlRegEx>)
   private
    function getSnippet(const key: string): string;
   public
    procedure free;
    procedure compileSnippets(keys: array of string);
  end;

implementation

 uses
  System.SysUtils,
  FMX.Dialogs,
  untSnippets;

 function TRegexpSnippets.getSnippet(const key: string): string;
  begin
   for var snippet in untSnippets.LIST_SNIPPET do
    if key = snippet.key then
     exit(snippet.value);
   raise Exception.CreateFmt('Unknown snippet: %s',[key]);
  end;

 procedure TRegexpSnippets.compileSnippets(keys: array of string);
  begin
   const
    i = length(keys);

    if i = 0 then raise Exception.Create('Not Enough actual parameters');
   Capacity := i;

   try
    for var key in keys do
     begin
     if self.ContainsKey(key) then continue;
      self.Add(key,TPerlRegEx.Create);
      self[key].RegEx := getSnippet(key);
      // System.regularExpressionsCore suggests that invoking
      // study more than once will increase performance
      self[key].Study;
      self[key].Study;
     end;
   except
    on Exception do
     begin
      for var value in values do
       if assigned(value) then
        value.free;
      raise;
     end;
   end;

  end;

 procedure TRegexpSnippets.free;
  begin

   for var snippet in values do
    snippet.free;
   inherited;

  end;

end.
