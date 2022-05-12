unit fr_kitchen;

interface

uses
  u_order,
  fr_floor,
  udmServerMSSQL,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Generics.Collections,
  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.TabControl,
  FireDAC.Comp.Client,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation;

type
  TKitchen = class(TFrame)
    Pass: TTabControl;
    Pin: TTabItem;
  private
    Floor: TFloor;
    ListOrdersServed: TList<TOrder>;
    ListOrdersNew: TList<TOrder>;
    procedure renderFloor;
    procedure fetchOrders;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Kitchen: TKitchen;

implementation

{$R *.fmx}
{ Tkitchen }

constructor TKitchen.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // Kitchen := TKitchen.Create(self);
  // addObject(Kitchen);
  ListOrdersServed := TList<TOrder>.Create;
  ListOrdersNew := TList<TOrder>.Create;
  ListOrdersServed.Capacity := 2000;
  ListOrdersNew.Capacity := 10;

  renderFloor;
end;

destructor TKitchen.Destroy;
begin
  for var order in ListOrdersServed do
    FreeAndNil(order);

  for var order in ListOrdersNew do
    FreeAndNil(order);

  FreeAndNil(ListOrdersServed);
  FreeAndNil(ListOrdersNew);

  inherited Destroy;
end;

procedure TKitchen.renderFloor;
begin
  if assigned(Floor) then
    FreeAndNil(Floor);

  Floor := TFloor.Create(Pin);
  Pin.AddObject(Floor);
end;

procedure TKitchen.fetchOrders;
var
  Orders: TFDTable;
  Order: TOrder;
begin

  try
    Orders := DB.fetchOrders;
    // setLength(ListOrders, data.RecordCount);

    for var row in Orders do
    begin
    Order := TOrder.Create(row);
    Orders.Next;
    end;

  except
    on E: Exception do
      showMessage(E.Message);
  end;

end;

end.
