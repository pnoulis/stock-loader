unit fr_pass;

interface

uses
untTypes,
  u_order,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Layouts,
  FMX.Objects;

type
  TPass = class(TFrame)
    layoutActions: TLayout;
    btnDeleteOrder: TButton;
    btnNewOrder: TButton;
    layoutHeader: TLayout;
    lblOrderID: TLabel;
    lblOrderDate: TLabel;
    scrollOrders: TVertScrollBox;
    Rectangle2: TRectangle;
    Rectangle1: TRectangle;
    panelOrderTemplate: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Rectangle3: TRectangle;
    procedure btnNewOrderClick(Sender: TObject);
  private
  public
    onNewOrder: procedure(order: TOrder = nil) of object;
    procedure orderToPass(AOrder: TOrder);
  end;

implementation
var
scrollHeight, contentHeight: Double;
{$R *.fmx}
{ TPass }

procedure TPass.btnNewOrderClick(Sender: TObject);
begin
onNewOrder;
end;

procedure TPass.orderToPass(AOrder: TOrder);
begin

var some := AOrder.renderSelf(self, panelOrderTemplate);
some.Align := TAlignLayout.Top;
some.Margins.Bottom := 20.0;

  if scrollHeight = 0 then
    scrollHeight := panelOrderTemplate.Size.Height + panelOrderTemplate.Margins.Height;

  contentHeight := contentHeight + scrollHeight + 200;
  panelOrderTemplate.Position.Y := contentHeight;

  {
  if contentHeight > Size.Height then
    scrollOrders.scrollBy(0.0, -contentHeight);
    }

scrollOrders.AddObject(some);
end;

begin
contentHeight := 0;
scrollHeight := 0;
end.
