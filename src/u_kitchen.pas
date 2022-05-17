unit u_kitchen;

interface

uses
  u_order,
  untTypes,
  fr_floor,
  udmServerMSSQL,
  FireDAC.Comp.Client,
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
    Pass: TFloor;
    ListOrders: TListOrders;
    newOrders: TListOrders;
    procedure renderPass;
    procedure renderPin;
    procedure fetchOrders;
  public
    constructor Create(AOwner: TComponent); override;
    procedure handleNewTab(Order: TOrder = nil);
    procedure handleTabClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure handleOrderDblClick(AOrder: TOrder);
    procedure handleCancelOrderClick(Pad: TPad);
    procedure handleCommitOrder(Pad: TPad);
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

procedure TKitchen.renderPin;
begin
  Pin := add;
  Pin.Cursor := TCursor(crHandPoint);
  Pin.text := 'Παραγγελιες';
end;

procedure TKitchen.fetchOrders;
var
  data: TFDTable;
begin

  try
    data := DB.fetchOrders;
    setLength(ListOrders, data.RecordCount);

    for var i := 0 to data.RecordCount - 1 do
    begin
      ListOrders[i] := TOrder.Create(i, data);
      ListOrders[i].onOrderDblClick := handleOrderDblClick;
      data.Next;
    end;

  except
    on E: Exception do
      showMessage(E.Message);
  end;

end;

procedure TKitchen.renderPass;
begin
  fetchOrders;
  Pass := TFloor.Create(Pin);
  Pass.onNewOrder := handleNewTab;
  Pin.AddObject(Pass);
  for var Order in ListOrders do
    Pass.orderToPass(Order);
end;

procedure TKitchen.handleCancelOrderClick(Pad: TPad);
begin

  if (Pad.Order.status = EStatusOrder.scratch) then
    freeAndNil(newOrders[TTabItem(Pad.TagObject).Index])
  else
    Pad.Order.isDisplayed := false;

  self.First(TTabTransition.none, TTabTransitionDirection.Normal);
  delete(TTabItem(Pad.TagObject).Index);

end;

procedure TKitchen.handleCommitOrder(Pad: TPad);
begin
  var proc := db.addStockOrder;
  var tmp: TPad;
  Pad.Order.stockOrderID := proc.FieldByName('stockOrderID').AsInteger;
  Pad.Order.storeID := proc.FieldByName('storeID').AsInteger;
  Pad.Order.date.commited := proc.FieldByName('moveDate').AsDateTime;
  Pad.Order.status := EStatusOrder.commited;
  Pad.order.isFetching := false;
  self.Pass.orderToPass(Pad.Order);
  Pad.Order.isDisplayed := true;
  TTabItem(Pad.TagObject).Text := forder.Order.stockOrderID.tostring;
  forder.commitProduce;
end;

procedure TKitchen.handleNewTab(Order: TOrder = nil);
var
  tab: TTabItem;
  lnOrders, nextID: cardinal;
  tabGap: integer;
  Pad: TPad;
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

      // Order := TOrder.Create(nextID);
      Order := TOrder.Create(0);
      Order.onOrderDblClick := handleOrderDblClick;
      newOrders[lnOrders - 1] := Order;
      setLength(newOrders, lnOrders + 1);
    end
    else
    begin
      // Order := TOrder.Create(nextID);
      Order := TOrder.Create(0);
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

  Pad := TPad.Create(tab, Order);
  Pad.TagObject := tab;
  Pad.onCancelOrderClick := handleCancelOrderClick;
  Pad.onCommitOrder := handleCommitOrder;
  tab.AddObject(Pad);
  tab.TagObject := Order;
  Order.isDisplayed := true;
  ActiveTab := tab;
end;

procedure TKitchen.handleOrderDblClick(AOrder: TOrder);
var
  Pad: TPad;
  tab: TTabItem;
begin

  if AOrder.isDisplayed then
    exit;

  tab := add;
  with tab do
  begin
    StyleLookup := 'tabItemClose';
    text := AOrder.stockOrderID.tostring;
    autoSize := false;
    Size.Width := TAB_WIDTH;
    Size.Height := TAB_HEIGHT;
    Cursor := TCursor(crHandPoint);
    OnMouseUp := handleTabClick;
  end;

  Pad := TPad.Create(tab, AOrder);
  Pad.TagObject := tab;
  Pad.onCancelOrderClick := handleCancelOrderClick;
  tab.AddObject(Pad);
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

  if Order.isFetching then exit;

  if (X >= btn.BoundsRect.Left) then
  begin

    if (Order.status = EStatusOrder.scratch) then
      freeAndNil(newOrders[index - 1])
    else
      Order.isDisplayed := false;

    self.First(TTabTransition.none, TTabTransitionDirection.Normal);
    delete(index);
  end;

end;

end.
