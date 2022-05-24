unit untTypes;

interface
uses
  System.SysUtils,
  System.RegularExpressionsCore;

type
  TDimensions = record
    Width: Single;
    Height: Single;
    ClientWidth: Single;
    ClientHeight: Single;
    Tpadding: Single;
    Rpadding: Single;
    Bpadding: Single;
    Lpadding: Single;
    Tmargin: Single;
    Rmargin: Single;
    Bmargin: Single;
    Lmargin: Single;
  end;

  TErrors = array of string;
  EStatusOrder = (Served, Commited, Cached, Scratch);
  TAsyncCB = Reference to procedure;
var
  GLocaleFormat: TFormatSettings;

implementation
begin
  GLocaleFormat := TFormatSettings.Create;
  GLocaleFormat.DecimalSeparator := '.';
end.
