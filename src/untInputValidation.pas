unit untInputValidation;

interface
 uses
 System.Generics.Collections,
  System.RegularExpressionsCore;

 type
  TDictNameToRegexp = TDictionary<string, TPerlRegEx>;

 function generateInputValidations(keys: array of string)
   : TDictNameToRegexp;

implementation
 uses
  System.sysUtils;

 type
  regexp = record
   key,value: string;
  end;

 const
  mapRegexp: array [0 .. 2] of regexp = (
  (key: '!alnum' ; value: '[^[:alnum:]]'), // not alphanumeric
  (key: '!realNumb' ; value: '[^[:digit:],.]'), // not real number plus needed punctuation
  (key: '!IntNumb' ; value: '[^[:digit:]]')
  );

 function getRegexp(const key: string): string;
  begin
   for var candidate in mapRegexp do
    if key = candidate.key then
     exit(candidate.value);

   raise Exception.CreateFmt('No match for candidate key: %s',[key]);
  end;

 // generate input validations
 function generateInputValidations(keys: array of string)
   : TDictNameToRegexp;
  begin
   var
   i := length(keys);

   if i = 0 then
    raise EArgumentOutOfRangeException.Create('Not enough actual parameters');

   result := TDictNameToRegexp.Create(i);
   i := 0;

   try
    for var key in keys do
     begin
      result[key] := TPerlRegEx.Create;
      result[key].RegEx := getRegexp(key);
      result[key].Study;
     end;
   except
    on Exception do
     begin
//     for var value in result.TValueCollection do
      freeAndNil(result);
      raise
     end;
   end;

  end; { generateInputValidations end }

end.
