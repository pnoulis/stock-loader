unit u_kitchen;

interface

uses
 u_order,
 fr_pass,
 udmServerMSSQL,
 System.sysUtils,
 System.classes,
 System.UITypes,
 fmx.Forms,
 FMX.Dialogs,
 FMX.Types,
 fmx.Controls,
 fmx.StdCtrls,
 FMX.TabControl;

type
 TKitchen = class(TTabControl)
 private
  Pin: TTabItem;
  Pass: TPass;
  Orders: TListOrders;
  newOrders: TListOrders;
  procedure renderPass;
  procedure renderPin;
  procedure fetchOrders;
 public
  constructor Create(AOwner: TComponent); override;
  procedure handleNewTab(Order: TOrder);
  procedure handleTabClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
 end;

implementation
const
TAB_WIDTH = 130.0;
TAB_HEIGHT = 30.0;

{ TKitchen }

constructor TKitchen.Create(AOwner: TComponent);
 begin
  inherited;
  Align := TAlignLayout.Client;
  renderPin;
  renderPass;
  setLength(newOrders, 1);
 end;

procedure TKitchen.fetchOrders;
begin
var i := 0;
const table = db.tableStockMovesLog;
table.IndexFieldNames := 'moveDate:D';
table.active := true;
setLength(Orders, table.RecordCount);

while not table.Eof do
begin
orders[i] := u_order.TOrder.Create(
table.FieldByName('moveID').Value,
table
);
table.Next;
inc(i);
end;

end;
procedure TKitchen.handleNewTab(Order: TOrder);
begin
var tab := add;
var lnOrders := length(newOrders);
var tabGap := - 1;


if not assigned(Order) then
begin

for var i := 0 to lnOrders - 1 do
if not assigned(newOrders[i]) then
tabGap := i;

if (tabGap < 0) then
begin
  order := TOrder.Create(lnOrders);
  newOrders[lnOrders - 1] := order;
  setlength(newOrders, lnOrders + 1);
end
else
begin
  order := TOrder.Create(tabGap + 1);
  newOrders[tabGap] := order;
end;

end;

with tab do
begin
StyleLookup := 'tabItemClose';
text := order.id.toString;
autoSize := false;
Size.Width := TAB_WIDTH;
Size.Height := TAB_HEIGHT;
Cursor := TCursor(crHandPoint);
OnMouseUp := handleTabClick;
end;

self.ActiveTab := tab;
end;

procedure TKitchen.handleTabClick(Sender: TObject; Button: TMouseButton;
Shift: TShiftState; X, Y: Single);
begin
var btn := TButton(TTabItem(Sender).FindStyleResource('btnClose'));
var index := TTabItem(sender).Index;

if (X >= btn.BoundsRect.Left) then
begin
freeAndNil(newOrders[index - 1]);
delete(TTabItem(sender).Index);
end;

end;

procedure TKitchen.renderPass;
 begin
 fetchOrders;
 Pass := TPass.Create(Pin, orders);
 pass.onNewOrder := handleNewTab;
 Pin.AddObject(Pass);
 end;

procedure TKitchen.renderPin;
 begin
 Pin := Add;
 Pin.Cursor := TCursor(crHandPoint);
 Pin.Text := 'Παραγκελιες';
 end;

end.
