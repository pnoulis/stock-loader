program stockLoader;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmStockLoader in 'frmStockLoader.pas' {frmLoader},
  untStock in 'untStock.pas',
  untLoader in 'untLoader.pas',
  untTypes in 'untTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLoader, frmLoader);
  Application.Run;
end.
