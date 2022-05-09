unit u_kitchen;

interface

uses
 u_order,
 fr_order,
 fr_pass,
 udmServerMSSQL,
 System.sysUtils,
 System.classes,
 System.UITypes,
 fmx.Forms,
 fmx.Dialogs,
 fmx.Types,
 fmx.Controls,
 fmx.StdCtrls,
 fmx.TabControl;

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
  procedure handleOrderDblClick(AOrder: TOrder);
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

  Orders := DB.fetchOrders;
  for var Order in Orders do
   Order.onOrderDblClick := handleOrderDblClick;

 end;

procedure TKitchen.handleNewTab(Order: TOrder);
 var
  tab: TTabItem;
  lnOrders, nextID: cardinal;
  tabGap: integer;
  FOrder: TFOrder;
 begin
  tab := add;
  lnOrders := length(newOrders);
  tabGap := -1;
  nextID := 1;

  if not assigned(Order) then
   begin

    for var i := 0 to lnOrders - 1 do
     begin

      if not assigned(newOrders[i]) and (tabGap < 0) then
       tabGap := i;

      if assigned(newOrders[i]) and (newOrders[i].id >= nextID) then
       begin
        nextID := newOrders[i].id + 1;
       end;

     end;

    if (tabGap < 0) or (tabGap = lnOrders - 1) then
     begin
      Order := TOrder.Create(nextID);
      Order.onOrderDblClick := handleOrderDblClick;
      newOrders[lnOrders - 1] := Order;
      setLength(newOrders, lnOrders + 1);
     end
    else
     begin
      Order := TOrder.Create(nextID);
      Order.onOrderDblClick := handleOrderDblClick;

      newOrders[tabGap] := Order;
     end;

   end;

  with tab do
   begin
    StyleLookup := 'tabItemClose';
    text := Order.id.toString;
    autoSize := false;
    Size.Width := TAB_WIDTH;
    Size.Height := TAB_HEIGHT;
    Cursor := TCursor(crHandPoint);
    OnMouseUp := handleTabClick;
   end;

  FOrder := TFOrder.Create(tab, Order);
  tab.AddObject(FOrder);
  tab.TagObject := Order;
  Order.isDisplayed := true;
  ActiveTab := tab;
 end;

procedure TKitchen.handleOrderDblClick(AOrder: TOrder);
 var
  FOrder: TFOrder;
  tab: TTabItem;
 begin

  if AOrder.isDisplayed then
   exit;

  tab := add;
  with tab do
   begin
    StyleLookup := 'tabItemClose';
    text := AOrder.id.toString;
    autoSize := false;
    Size.Width := TAB_WIDTH;
    Size.Height := TAB_HEIGHT;
    Cursor := TCursor(crHandPoint);
    OnMouseUp := handleTabClick;
   end;

  FOrder := TFOrder.Create(tab, AOrder);
  tab.AddObject(FOrder);
  tab.TagObject := AOrder;
  AOrder.isDisplayed := true;
  ActiveTab := tab;
 end;

procedure TKitchen.handleTabClick(Sender: TObject; Button: TMouseButton;
 Shift: TShiftState; X, Y: Single);
 begin
  var
  btn := TButton(TTabItem(Sender).FindStyleResource('btnClose'));
  var
  index := TTabItem(Sender).Index;
  var
  Order := TOrder(TTabItem(Sender).TagObject);

  if (X >= btn.BoundsRect.Left) then

   begin
    if (Order.status = EStatusOrder.scratchpad) then
     begin
      freeAndNil(newOrders[index - 1]);
      delete(TTabItem(Sender).Index);
     end
    else
     Order.isDisplayed := false;
    delete(TTabItem(Sender).Index);
   end;

 end;

procedure TKitchen.renderPass;
 begin
  fetchOrders;
  Pass := TPass.Create(Pin, Orders);
  Pass.onNewOrder := handleNewTab;
  Pin.AddObject(Pass);
 end;

procedure TKitchen.renderPin;
 begin
  Pin := add;
  Pin.Cursor := TCursor(crHandPoint);
  Pin.text := 'Παραγκελιες';
 end;

end.
