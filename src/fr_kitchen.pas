﻿unit fr_kitchen;

interface

uses
 u_order,
 fr_pad,
 fr_floor,
 udmServerMSSQL,
 System.SysUtils,
 System.DateUtils,
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
 FMX.Objects,
 FMX.Layouts,
 FMX.Controls.Presentation;

type

 TListOrders = TList<TOrder>;

 TKitchen = class(TFrame)
  layoutFooter: TLayout;
  lblTime: TLabel;
  timerSecond: TTimer;
  Pass: TTabControl;
  Pin: TTabItem;

 private type
  TKitchenOrder = class
   isNew: Boolean;
   isFetching: Boolean;
   kitchenID: word;
   tab: TTabItem;
   order: TOrder;
   pad: TPad;
  end;

 var
  ListOrders: TList<TKitchenOrder>;
  nOrders: word;
  Floor: TFloor;

  procedure renderFloor;
  procedure startTimer(Sender: TObject);
  procedure handleOrder(AOrder: TOrder = nil);
  function createTab: TTabItem;
  procedure orderToKitchen(var KOrder: TKitchenOrder);
  procedure handleTabClick(Sender: TObject; Button: TMouseButton;
   Shift: TShiftState; X, Y: Single);
  procedure handleTabMouseEnter(Sender: TObject);
  procedure handleTabMouseLeave(Sender: TObject);
  procedure removeOrder(var KOrder: TKitchenOrder);
  procedure handleOrderCancel(const kitchenID: word);
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
  renderFloor;
  startTimer(self);
  timerSecond.OnTimer := startTimer;
  ListOrders := TList<TKitchenOrder>.Create;
  ListOrders.Capacity := 10;
  nOrders := 0;
  Pin.OnMouseEnter := handleTabMouseEnter;
  Pin.OnMouseLeave := handleTabMouseLeave;
 end;

destructor TKitchen.Destroy;
 begin

  if Assigned(ListOrders) then
   for var KitchenOrder in ListOrders do
    begin
     FreeAndNil(KitchenOrder.order);
     KitchenOrder.Free;
    end;
  FreeAndNil(ListOrders);

  inherited Destroy;
 end;

procedure TKitchen.renderFloor;
 begin
  if Assigned(Floor) then
   FreeAndNil(Floor);

  Floor := TFloor.Create(Pin);
  Floor.onOrder := handleOrder;
  Pin.AddObject(Floor);
 end;

procedure TKitchen.startTimer(Sender: TObject);
 begin
  lblTime.Text := FormatDateTime('ddd dd/mm/yy hh:mm:ss', now)
 end;

procedure TKitchen.handleOrder(AOrder: TOrder = nil);
 var
  KOrder: TKitchenOrder;
 begin
  var
  isNew := true;

  if (AOrder.StockOrderID <> 0) then
   begin
    for var KitchenOrder in ListOrders do
     if KitchenOrder.order.StockOrderID = AOrder.StockOrderID then
      exit;
    isNew := false;
   end;

  KOrder := TKitchenOrder.Create;
  KOrder.isNew := isNew;
  KOrder.order := AOrder;
  orderToKitchen(KOrder);
 end;

procedure TKitchen.orderToKitchen(var KOrder: TKitchenOrder);
 begin
  try
   ListOrders.Add(KOrder);
   KOrder.kitchenID := nOrders;

   KOrder.tab := createTab;
   KOrder.tab.Tag := nOrders;
   KOrder.tab.Text := KOrder.order.StockOrderID.ToString;

   inc(nOrders);

   KOrder.pad := TPad.Create(KOrder.tab, KOrder.order, KOrder.kitchenID);
   KOrder.pad.onOrderCancel := handleOrderCancel;

   KOrder.tab.AddObject(KOrder.pad);

   KOrder.isFetching := false;

   Pass.SetActiveTabWithTransition(KOrder.tab, TTabTransition.None);
  except
   on E: Exception do
    showMessage(E.Message);
  end;
 end;

function TKitchen.createTab: TTabItem;
 const
  TAB_WIDTH = 130.0;
  TAB_HEIGHT = 40.0;
 begin
  result := Pass.Add(TTabItem);
  result.StyleLookup := 'tabItemClose';
  result.AutoSize := false;
  result.Width := TAB_WIDTH;
  result.Height := TAB_HEIGHT;
  result.OnMouseUp := handleTabClick;
  result.OnMouseEnter := handleTabMouseEnter;
  result.OnMouseLeave := handleTabMouseLeave;
 end;

procedure TKitchen.handleTabClick(Sender: TObject; Button: TMouseButton;
 Shift: TShiftState; X: Single; Y: Single);
 var
  KOrder: TKitchenOrder;
 begin
  var
  tab := TTabItem(Sender);
  var
  btn := TButton(tab.FindStyleResource('btnClose'));

  for var KitchenOrder in ListOrders do
   if (KitchenOrder.kitchenID = tab.Tag) then
    KOrder := KitchenOrder;

  if KOrder.isFetching then
   exit;

  if (X >= btn.boundsRect.left) then
   removeOrder(KOrder);
 end;

procedure TKitchen.handleTabMouseEnter(Sender: TObject);
 begin
  TTabItem(Sender).Cursor := crHandPoint;
 end;

procedure TKitchen.handleTabMouseLeave(Sender: TObject);
 begin
  TTabItem(Sender).Cursor := crArrow;
 end;

procedure TKitchen.removeOrder(var KOrder: TKitchen.TKitchenOrder);
 begin
  Pass.First(TTabTransition.None);
  Pass.Delete(KOrder.tab.Index);
  FreeAndNil(KOrder.order);
  KOrder.Free;
  ListOrders.Remove(KOrder);
 end;

procedure TKitchen.handleOrderCancel(const kitchenID: word);
 var
  KOrder: TKitchenOrder;
 begin
  for var KitchenOrder in ListOrders do
   if (KitchenOrder.kitchenID = kitchenID) then
    KOrder := KitchenOrder;

   removeOrder(KOrder);
 end;

end.
