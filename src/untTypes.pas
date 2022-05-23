unit untTypes;

interface
uses
  System.Threading,
  System.RegularExpressionsCore,
  System.Generics.Collections;

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
  EStatusOrder =(Served, Commited, Cached, Scratch);
  TAsyncCB = Reference to procedure;

procedure RunAsync(const Cb: TAsyncCB;const Delay: UInt32 = 0);

implementation
uses
  System.SysUtils,
  System.Classes;

procedure RunAsync(const Cb: TAsyncCB;const Delay: UInt32 = 0);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      if Delay > 0 then
        Sleep(Delay);
      Cb();
      TThread.Synchronize(nil,
        procedure
        begin
        end);
    end).Start;
end;

end.
