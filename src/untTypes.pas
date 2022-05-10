unit untTypes;

interface

uses
  System.Threading,
  System.RegularExpressionsCore,
  System.Generics.Collections;

type
  TDimensions = record
    width: single;
    height: single;
    clientWidth: single;
    clientHeight: single;
    tpadding: single;
    rpadding: single;
    bpadding: single;
    lpadding: single;
    tmargin: single;
    rmargin: single;
    bmargin: single;
    lmargin: single;
  end;

  TErrors = array of string;
  EStatusOrder = (served, commited, scratch);
  TAsyncCB = reference to procedure;

procedure runAsync(const cb: TAsyncCB; const delay: UInt32 = 0);

implementation

uses
  System.SysUtils,
  System.Classes;

procedure runAsync(const cb: TAsyncCB; const delay: UInt32 = 0);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      if delay > 0 then
        sleep(delay);
        cb();
      TThread.Synchronize(nil,
        procedure
        begin
        end);
    end).Start;
end;

end.
