program stockLoader;

uses
 untProduce in 'untProduce.pas',
 untKitchen in 'untKitchen.pas',
 untTypes in 'untTypes.pas',
 untTRegexpSnippets in 'regexp-snippets\untTRegexpSnippets.pas',
 untSnippets in 'regexp-snippets\untSnippets.pas',
 untInput in 'untInput.pas',
 uDBConnect in '..\lib\delphi-utils\src\uDBConnect.pas',
 uFilesystem in '..\lib\delphi-utils\src\uFilesystem.pas',
 uListOrders in 'uListOrders.pas',
 System.StartUpCopy,
 FMX.Forms,
 frmStockLoader in 'frmStockLoader.pas' {frmLoader} ,
 udmEliza in 'udmEliza.pas' {dmEliza: TDataModule} ,
 frPass in 'frPass.pas' {Pass: TFrame} ,
 foMain in 'foMain.pas' {mainForm} ,
 frKitchen in 'frKitchen.pas' {kitchen: TFrame} ,
 frOrder in 'frOrder.pas' {Order: TFrame};

{$R *.res}

begin
 Application.Initialize;
 Application.CreateForm(TmainForm, mainForm);
 Application.Run;
end.
