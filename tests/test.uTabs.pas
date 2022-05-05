unit test.uTabs;

interface

 uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Controls.Presentation, FMX.StdCtrls;

 type
  TtestUTabs = class(TForm)
    TabControl1: TTabControl;
    btnAddTab: TButton;
    TabItem1: TTabItem;
    StyleBook1: TStyleBook;
    TabItem2: TTabItem;
    procedure btnAddTabClick(Sender: TObject);
    procedure TabItem1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
   private
    { Private declarations }
   public
    { Public declarations }
  end;

 var
  testUTabs: TtestUTabs;

implementation

 uses
  uTabs;

 {$R *.fmx}

procedure TtestUTabs.btnAddTabClick(Sender: TObject);
begin
tabControl1.Add(utabs.TTab);
end;

procedure TtestUTabs.TabItem1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
showMessage('hello');
var btn := TTabItem(sender).FindStyleResource('btnClose');
if (x > TButton(btn).position.x) then showMessage('it should delete it');
exit;
end;

end.
