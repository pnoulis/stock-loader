unit fr_kitchen;

interface

uses
 u_order,
 fr_order,
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
  Pass: TTabControl;
  Pin: TTabItem;
  layoutFooter: TLayout;
  lblTime: TLabel;
  timerSecond: TTimer;

 private type
  TKitchenOrder = record
   isNew: Boolean;
   isDisplayed: Boolean;
   tab: TTabItem;
   order: TOrder;
   pad: TFrame;
  end;

 var
  ListOrders: array of TKitchenOrder;
  Floor: TFloor;

  procedure renderFloor;
  procedure startTimer(Sender: TObject);
  procedure handleOrder(order: TOrder = nil);
  function createTab: TTabItem;
 public
  constructor Create(AOwner: TComponent); override;
  destructor Destroy; override;
 end;

var
 Kitchen: TKitchen;

implementation

const
 TAB_WIDTH = 130.0;
 TAB_HEIGHT = 40.0;

{$R *.fmx}
 { Tkitchen }

constructor TKitchen.Create(AOwner: TComponent);
 begin
  inherited Create(AOwner);
  renderFloor;
  startTimer(self);
  timerSecond.OnTimer := startTimer;
 end;

destructor TKitchen.Destroy;
 begin

  if Assigned(ListOrders) then
   for var KitchenOrder in ListOrders do
    FreeAndNil(KitchenOrder.order);

  setlength(ListOrders, 0);

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

procedure TKitchen.handleOrder(order: TOrder = nil);
 var tab: TTabItem;
 var newKitchenOrder: TKitchenOrder;
 begin
  newKitchenOrder.isNew := true;

  if Assigned(order) then
   begin
    for var KitchenOrder in ListOrders do
     if KitchenOrder.order.StockOrderID = order.StockOrderID then
      exit;
    newKitchenOrder.isNew := false;
   end;

  newKitchenOrder.order := order;
  newKitchenOrder.isDisplayed := true;
  newKitchenOrder.tab := createTab;
  newKitchenOrder.pad := TFOrder.Create(newKitchenOrder.tab, order);
  newKitchenOrder.tab.AddObject(newKitchenOrder.pad);
  Pass.SetActiveTabWithTransition(newKitchenOrder.tab, TTabTransition.None);
 end;

function TKitchen.createTab: TTabItem;
 begin
  result := Pass.Add(TTabItem);
  result.StyleLookup := 'tabItemClose';
  result.AutoSize := false;
  result.Width := TAB_WIDTH;
  result.Height := TAB_HEIGHT;
 end;

end.
