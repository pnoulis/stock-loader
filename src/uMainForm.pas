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
   btnTestUTabs: TMemo;
   procedure btnTestUDBConnectionClick(Sender: TObject);
   procedure btnTestUFilesystemClick(Sender: TObject);
   procedure btnTestUTabsClick(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
  end;

 var
  mainForm: TmainForm;

implementation

 uses
  test.uTabs,
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

 procedure TmainForm.btnTestUTabsClick(Sender: TObject);
  begin
   test.uTabs.testUTabs.Show;
  end;

end.
