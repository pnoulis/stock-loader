program stockLoader;

uses
  UntTypes in 'untTypes.pas',
  UntTRegexpSnippets in 'regexp-snippets\untTRegexpSnippets.pas',
  UntSnippets in 'regexp-snippets\untSnippets.pas',
  UDBConnect in '..\lib\delphi-utils\src\uDBConnect.pas',
  UFilesystem in '..\lib\delphi-utils\src\uFilesystem.pas',
  System.StartUpCopy,
  FMX.Forms,
  U_order in 'u_order.pas' {/fr_pad in 'fr_pad.pas' {Pad: TFrame},
  UdmServerMSSQL in 'udmServerMSSQL.pas' {dmServerMSSQL: TDataModule},
  Fr_floor in 'fr_floor.pas' {Pass: TFrame},
  F_main_form in 'f_main_form.pas' {mainForm},
  Fr_kitchen in 'fr_kitchen.pas' {frKitchen: TFrame},
  Fr_pad in 'fr_pad.pas' {Pad: TFrame},
  U_produce in 'u_produce.pas',
  UntInput in 'untInput.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TmainForm, MainForm);
  Application.Run;

end.
