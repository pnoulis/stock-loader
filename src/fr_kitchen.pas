unit fr_kitchen;

interface
uses
  U_order,
  Fr_pad,
  Fr_floor,
  UdmServerMSSQL,
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
    LayoutFooter: TLayout;
    LblTime: TLabel;
    TimerSecond: TTimer;
    Pass: TTabControl;
    Pin: TTabItem;

    private type
      TKitchenOrder = class
        IsNew: Boolean;
        IsFetching: Boolean;
        KitchenID: Word;
        Tab: TTabItem;
        Order: TOrder;
        Pad: TPad;
      end;

    var
      ListOrders: TList<TKitchenOrder>;
      NOrders: Word;
      Floor: TFloor;

      procedure RenderFloor;
      procedure StartTimer(Sender: TObject);
      procedure HandleOrder(AOrder: TOrder = nil);
      function CreateTab: TTabItem;
      procedure OrderToKitchen(var KOrder: TKitchenOrder);
      procedure HandleTabClick(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y: Single);
      procedure HandleTabMouseEnter(Sender: TObject);
      procedure HandleTabMouseLeave(Sender: TObject);
      procedure RemoveOrder(var KOrder: TKitchenOrder);
      procedure HandleOrderCancel(const KitchenID: Word);
      procedure HandleOrderCommit(const KitchenID: Word);
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
  RenderFloor;
  StartTimer(Self);
  TimerSecond.OnTimer := StartTimer;
  ListOrders := TList<TKitchenOrder>.Create;
  ListOrders.Capacity := 10;
  NOrders := 0;
  Pin.OnMouseEnter := HandleTabMouseEnter;
  Pin.OnMouseLeave := HandleTabMouseLeave;
end;

destructor TKitchen.Destroy;
begin

  if Assigned(ListOrders)then
    for var KitchenOrder in ListOrders do
    begin
      FreeAndNil(KitchenOrder.Order);
      KitchenOrder.Free;
    end;
  FreeAndNil(ListOrders);

  inherited Destroy;
end;

procedure TKitchen.RenderFloor;
begin
  if Assigned(Floor)then
    FreeAndNil(Floor);

  Floor := TFloor.Create(Pin);
  Floor.OnOrder := HandleOrder;
  Pin.AddObject(Floor);
end;

procedure TKitchen.StartTimer(Sender: TObject);
begin
  LblTime.Text := FormatDateTime('ddd dd/mm/yy hh:mm:ss', Now)
end;

procedure TKitchen.HandleOrder(AOrder: TOrder = nil);
var
  KOrder: TKitchenOrder;
begin
  var
  IsNew := True;

  if(AOrder.StockOrderID <> '0')then
  begin
    for var KitchenOrder in ListOrders do
      if KitchenOrder.Order.StockOrderID = AOrder.StockOrderID then
        Exit;
    IsNew := False;
  end;

  KOrder := TKitchenOrder.Create;
  KOrder.IsNew := IsNew;
  KOrder.Order := AOrder;
  OrderToKitchen(KOrder);
end;

procedure TKitchen.OrderToKitchen(var KOrder: TKitchenOrder);
begin
  try
    ListOrders.Add(KOrder);
    KOrder.KitchenID := NOrders;

    KOrder.Tab := CreateTab;
    KOrder.Tab.Tag := NOrders;
    KOrder.Tab.Text := KOrder.Order.StockOrderID;

    Inc(NOrders);

    KOrder.Pad := TPad.Create(KOrder.Tab, KOrder.Order, KOrder.KitchenID);
    KOrder.Pad.OnOrderCancel := HandleOrderCancel;
    KOrder.Pad.OnOrderCommit := HandleOrderCommit;

    KOrder.Tab.AddObject(KOrder.Pad);

    KOrder.IsFetching := False;

    Pass.SetActiveTabWithTransition(KOrder.Tab, TTabTransition.None);
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

function TKitchen.CreateTab: TTabItem;
const
  TAB_WIDTH = 130.0;
  TAB_HEIGHT = 40.0;
begin
  Result := Pass.Add(TTabItem);
  Result.StyleLookup := 'tabItemClose';
  Result.AutoSize := False;
  Result.Width := TAB_WIDTH;
  Result.Height := TAB_HEIGHT;
  Result.OnMouseUp := HandleTabClick;
  Result.OnMouseEnter := HandleTabMouseEnter;
  Result.OnMouseLeave := HandleTabMouseLeave;
end;

procedure TKitchen.HandleTabClick(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X: Single; Y: Single);
var
  KOrder: TKitchenOrder;
begin
  var
  Tab := TTabItem(Sender);
  var
  Btn := TButton(Tab.FindStyleResource('btnClose'));

  for var KitchenOrder in ListOrders do
    if(KitchenOrder.KitchenID = Tab.Tag)then
      KOrder := KitchenOrder;

  if KOrder.IsFetching then
    Exit;

  if(X >= Btn.BoundsRect.Left)then
    RemoveOrder(KOrder);
end;

procedure TKitchen.HandleTabMouseEnter(Sender: TObject);
begin
  TTabItem(Sender).Cursor := CrHandPoint;
end;

procedure TKitchen.HandleTabMouseLeave(Sender: TObject);
begin
  TTabItem(Sender).Cursor := CrArrow;
end;

procedure TKitchen.RemoveOrder(var KOrder: TKitchen.TKitchenOrder);
begin
  Pass.First(TTabTransition.None);
  Pass.Delete(KOrder.Tab.Index);
  FreeAndNil(KOrder.Order);
  KOrder.Free;
  ListOrders.Remove(KOrder);
end;

procedure TKitchen.HandleOrderCancel(const KitchenID: Word);
var
  KOrder: TKitchenOrder;
begin
  for var KitchenOrder in ListOrders do
    if(KitchenOrder.KitchenID = KitchenID)then
      KOrder := KitchenOrder;

  RemoveOrder(KOrder);
  RenderFloor;
end;

procedure TKitchen.HandleOrderCommit(const KitchenID: Word);
begin

  TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          for var KitchenOrder in ListOrders do
            if(KitchenOrder.KitchenID = KitchenID)then
              KitchenOrder.Tab.Text := KitchenOrder.Order.StockOrderID;
          RenderFloor;
        end);
    end).Start;

end;

end.
