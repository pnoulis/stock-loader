﻿program stockLoader;

uses
  untTypes in 'untTypes.pas',
  untTRegexpSnippets in 'regexp-snippets\untTRegexpSnippets.pas',
  untSnippets in 'regexp-snippets\untSnippets.pas',
  uDBConnect in '..\lib\delphi-utils\src\uDBConnect.pas',
  uFilesystem in '..\lib\delphi-utils\src\uFilesystem.pas',
  System.StartUpCopy,
  FMX.Forms,
  udmServerMSSQL in 'udmServerMSSQL.pas' {dmServerMSSQL: TDataModule},
  fr_floor in 'fr_floor.pas' {Pass: TFrame},
  f_main_form in 'f_main_form.pas' {mainForm},
  fr_kitchen in 'fr_kitchen.pas' {frKitchen: TFrame},
  u_order in 'u_order.pas',
  fr_order in 'fr_order.pas' {FOrder: TFrame},
  u_produce in 'u_produce.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TmainForm, mainForm);
  Application.Run;

end.
