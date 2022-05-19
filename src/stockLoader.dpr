program stockLoader;

uses
  untTypes in 'untTypes.pas',
  untTRegexpSnippets in 'regexp-snippets\untTRegexpSnippets.pas',
  untSnippets in 'regexp-snippets\untSnippets.pas',
  uDBConnect in '..\lib\delphi-utils\src\uDBConnect.pas',
  uFilesystem in '..\lib\delphi-utils\src\uFilesystem.pas',
  System.StartUpCopy,
  FMX.Forms,
  u_order in 'u_order.pas' {/fr_pad in 'fr_pad.pas' {Pad: TFrame},
  udmServerMSSQL in 'udmServerMSSQL.pas' {dmServerMSSQL: TDataModule},
  fr_floor in 'fr_floor.pas' {Pass: TFrame},
  f_main_form in 'f_main_form.pas' {mainForm},
  fr_kitchen in 'fr_kitchen.pas' {frKitchen: TFrame},
  fr_pad in 'fr_pad.pas' {Pad: TFrame},
  u_produce in 'u_produce.pas',
  untInput in 'untInput.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TmainForm, mainForm);
  Application.Run;

end.
