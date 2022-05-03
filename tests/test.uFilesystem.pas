unit test.uFilesystem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo;

type
  TtestUFilesystem = class(TForm)
    Layout1: TLayout;
    Memo1: TMemo;
    procedure Memo1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  testUFilesystem: TtestUFilesystem;

procedure test1;
implementation
uses
 FMX.DialogService.Sync,
 system.IOUtils,
 uFilesystem;

 type
 dialog = TDialogServiceSync;
{$R *.fmx}

procedure test1;
begin
var input := [''];
  dialog.InputQuery('add amount', ['project name'], input);
  uFilesystem.anchorProjectRoot(input[0]);
  showMessage('changed project root:' + TDirectory.GetCurrentDirectory);
end;


procedure TtestUFilesystem.Memo1Click(Sender: TObject);
begin
test1;
end;

end.
