unit fr_kitchen;

interface
uses
  U_order,
  Fr_pad,
  Fr_floor,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Generics.Collections,
  FMX.Types,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.DialogService.Sync,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.Controls;

type

  TKitchen = class(TFrame)
    LayoutFooter: TLayout;
    LblTime: TLabel;
    TimerSecond: TTimer;
    Pass: TTabControl;
    Pin: TTabItem;

    private type
      TKitchenOrder = class
        KOrderID: Word;
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
      function CreateTab: TTabItem;
      procedure OrderToKitchen(var KOrder: TKitchenOrder);
      procedure HandleTabClick(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y: Single);
      procedure HandleTabMouseEnter(Sender: TObject);
      procedure HandleTabMouseLeave(Sender: TObject);
      procedure RemoveOrder(var KOrder: TKitchenOrder);
      procedure HandleOrderNew(AOrder: TOrder = nil);
      procedure HandleOrderCancel(var AOrder: TOrder);
      procedure HandleOrderCommit(var AOrder: TOrder);
      function AskUserOrderDelete: Boolean;
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

  if Assigned(ListOrders) then
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
  if Assigned(Floor) then
    FreeAndNil(Floor);

  Floor := TFloor.Create(Pin);
  Floor.OnOrder := HandleOrderNew;
  Pin.AddObject(Floor);
end;

procedure TKitchen.StartTimer(Sender: TObject);
begin
  LblTime.Text := FormatDateTime('ddd dd/mm/yy hh:mm:ss', Now)
end;


procedure TKitchen.OrderToKitchen(var KOrder: TKitchenOrder);
begin
  try
    ListOrders.Add(KOrder);
    KOrder.KOrderID := NOrders;

    KOrder.Tab := CreateTab;
    KOrder.Tab.Tag := NOrders;
    KOrder.Tab.Text := KOrder.Order.StockOrderID;

    Inc(NOrders);

    KOrder.Pad := TPad.Create(KOrder.Tab, KOrder.Order, KOrder.KOrderID);
    KOrder.Pad.OnOrderCancel := HandleOrderCancel;
    KOrder.Pad.OnOrderCommit := HandleOrderCommit;

    KOrder.Tab.AddObject(KOrder.Pad);

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
    if (KitchenOrder.KOrderID = Tab.Tag) then
    begin
      KOrder := KitchenOrder;
      KOrder.Pad.AddNewProduce;
    end;

  if (X >= Btn.BoundsRect.Left) then
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


procedure TKitchen.HandleOrderNew(AOrder: TOrder = nil);
var
  KOrder: TKitchenOrder;
begin
  if (AOrder.StockOrderID <> '0') then
    for var KitchenOrder in ListOrders do
      if KitchenOrder.Order.StockOrderID = AOrder.StockOrderID then
        Exit;

  KOrder := TKitchenOrder.Create;
  KOrder.Order := AOrder;
  OrderToKitchen(KOrder);
end;

procedure TKitchen.HandleOrderCancel(var AOrder: TOrder);
var
  KOrder: TKitchenOrder;
begin
//  AskUserOrderDelete;

  {
    if (FOrder.Status = EStatusOrder.Commited) and AskUserOrderDelete then
    FOrder.Delete;
  }
  {
    try
    FOrder.Delete;
    except
    on E: EOrder do
    HandleOrderError(E);
    end;
  }
  // OnOrderCancel(FKOrderID);
  {
    for var KitchenOrder in ListOrders do
    if (KitchenOrder.KOrderID = KOrderID) then
    KOrder := KitchenOrder;

    RemoveOrder(KOrder);
    RenderFloor;
  }
end;

procedure TKitchen.HandleOrderCommit(var AOrder: TOrder);
begin
{

  TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          for var KitchenOrder in ListOrders do
            if (KitchenOrder.KOrderID = KOrderID) then
              KitchenOrder.Tab.Text := KitchenOrder.Order.StockOrderID;
          RenderFloor;
        end);
    end).Start;
    }

end;

function TKitchen.AskUserOrderDelete: Boolean;
var
  Input: Integer;
const
  Msg = 'Ç ðáñáããåëéá å÷åé áðïèçêåõìåíåò êéíçóåéò. Íá äéáãñáöåé?';
begin

  Input := TDialogServiceSync.MessageDialog(Msg, TMsgDlgType.MtConfirmation,
      [TMsgDlgBtn.MbYes, TMsgDlgBtn.MbNo], TMsgDlgBtn.MbNo, MrNone);

  if (Input = MrYes) then
    Result := True
  else
    Result := False;

end;

end.
