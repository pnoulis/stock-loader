program delphiUtils;
uses
  System.StartUpCopy,
  FMX.Forms,
  uDBConnect in 'uDBConnect.pas',
  uMainForm in 'uMainForm.pas' {mainForm},
  test.uDBConnect in '..\tests\test.uDBConnect.pas' {testUDBconnect},
  uFilesystem in 'uFilesystem.pas',
  test.uFilesystem in '..\tests\test.uFilesystem.pas' {testUFilesystem};

{$R *.res}
begin
  Application.Initialize;
  Application.CreateForm(TmainForm, mainForm);
  Application.CreateForm(TtestUDBconnect, testUDBconnect);
  Application.CreateForm(TTestUFilesystem, testUFilesystem);
  Application.Run;
end.
