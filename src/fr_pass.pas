unit fr_pass;

interface

uses
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
    listOrders: TVertScrollBox;
    Rectangle2: TRectangle;
    Rectangle1: TRectangle;
    panelOrderTemplate: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Rectangle3: TRectangle;
  private
  public
    onNewOrder: procedure(order: TOrder) of object;
    constructor Create(AOwner: TComponent; orders: u_order.TListOrders);
    procedure handleNewOrderClick(Sender: TObject);
  end;

implementation

{$R *.fmx}
{ TPass }

constructor TPass.Create(AOwner: TComponent; orders: u_order.TListOrders);
var
  tmp: TPanel;
begin
  inherited Create(AOwner);

  Align := TAlignLayout.Client;
  listOrders.Padding.Left := 25.0;
  listOrders.Padding.Right := 25.0;

  for var order in orders do
    listOrders.AddObject(order.renderSelf(listOrders, panelOrderTemplate));

  btnNewOrder.OnClick := handleNewOrderClick;
end;

procedure TPass.handleNewOrderClick(Sender: TObject);
begin
  onNewOrder(nil);
end;

end.
