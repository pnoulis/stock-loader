program stockLoader;

uses
 untTypes in 'untTypes.pas',
 untTRegexpSnippets in 'regexp-snippets\untTRegexpSnippets.pas',
 untSnippets in 'regexp-snippets\untSnippets.pas',
 untInput in 'untInput.pas',
 uDBConnect in '..\lib\delphi-utils\src\uDBConnect.pas',
 uFilesystem in '..\lib\delphi-utils\src\uFilesystem.pas',
 System.StartUpCopy,
 FMX.Forms,
 udmServerMSSQL in 'udmServerMSSQL.pas' {dmServerMSSQL: TDataModule} ,
 fr_pass in 'fr_pass.pas' {Pass: TFrame} ,
 f_main_form in 'f_main_form.pas' {mainForm} ,
 fr_kitchen in 'fr_kitchen.pas' {frKitchen: TFrame} ,
 fr_order in 'fr_order.pas' {Order: TFrame} ,
 u_kitchen in 'u_kitchen.pas',
 u_order in 'u_order.pas',
 u_produce in 'u_produce.pas';

{$R *.res}

begin
 Application.Initialize;
 Application.CreateForm(TmainForm, mainForm);
 Application.Run;

end.
