program stockLoader;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmStockLoader in 'frmStockLoader.pas' {frmLoader},
  untProduce in 'untProduce.pas',
  untKitchen in 'untKitchen.pas',
  untTypes in 'untTypes.pas',
  untTRegexpSnippets in 'regexp-snippets\untTRegexpSnippets.pas',
  untSnippets in 'regexp-snippets\untSnippets.pas' {,
  untInput in 'untInput.pas',
  uDBConnect in '..\lib\delphi-utils\src\uDBConnect.pas',
  uFilesystem in '..\lib\delphi-utils\src\uFilesystem.pas',
  udmEliza in 'udmEliza.pas' {dmEliza: TDataModule},
  untInput in 'untInput.pas',
  uDBConnect in '..\lib\delphi-utils\src\uDBConnect.pas',
  uFilesystem in '..\lib\delphi-utils\src\uFilesystem.pas',
  udmEliza in 'udmEliza.pas' {dmEliza: TDataModule},
  uListOrders in 'uListOrders.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLoader, frmLoader);
  Application.CreateForm(TdmEliza, dmEliza);
  Application.Run;
end.
