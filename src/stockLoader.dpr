program stockLoader;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmStockLoader in 'frmStockLoader.pas' {frmLoader},
  untProduce in 'untProduce.pas',
  untKitchen in 'untKitchen.pas',
  untTypes in 'untTypes.pas',
  untTRegexpSnippets in 'regexp-snippets\untTRegexpSnippets.pas',
  untSnippets in 'regexp-snippets\untSnippets.pas',
  untInput in 'untInput.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLoader, frmLoader);
  Application.Run;
end.
