unit uMainForm;

interface

 uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Layouts;

 type
  TmainForm = class(TForm)
   GridLayout1: TGridLayout;
   btnTestUDBConnection: TMemo;
    btnTestUFilesystem: TMemo;
   procedure btnTestUDBConnectionClick(Sender: TObject);
    procedure btnTestUFilesystemClick(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
  end;

 var
  mainForm: TmainForm;

implementation
 uses
  test.uDBConnect,
  test.uFilesystem;
 {$R *.fmx}

 procedure TmainForm.btnTestUDBConnectionClick(Sender: TObject);
  begin
  test.uDBConnect.testUDBconnect.Show;
  end;

procedure TmainForm.btnTestUFilesystemClick(Sender: TObject);
begin

test.uFilesystem.testUFilesystem.Show;
end;

end.
