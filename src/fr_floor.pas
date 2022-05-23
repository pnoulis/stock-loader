unit fr_floor;

interface
uses
  UntTypes,
  U_order,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.DateUtils,
  System.Variants,
  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FireDAC.Comp.Client,
  FMX.Controls.Presentation,
  Data.DB,
  FMX.Layouts,
  FMX.Objects,
  FMX.Calendar,
  FMX.DateTimeCtrls;

type
  TFloor = class(TFrame)
    LayoutActions: TLayout;
    LayoutHeader: TLayout;
    LblOrderID: TLabel;
    LblOrderDate: TLabel;
    ScrollOrders: TVertScrollBox;
    Rectangle2: TRectangle;
    TemplateFloorOrder: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Rectangle3: TRectangle;
    PanelDateFilter: TPanel;
    Rectangle4: TRectangle;
    BtnShowHeader: TButton;
    Layout1: TLayout;
    LblDateFilterHeader: TLabel;
    LblDateFrom: TLabel;
    DateFrom: TDateEdit;
    DateTo: TDateEdit;
    LblDateTo: TLabel;
    PanelActions: TPanel;
    Rectangle5: TRectangle;
    BtnNewOrder: TButton;
    BtnShowFilters: TButton;
    BtnApplyFilters: TButton;
    BtnResetFilters: TButton;
    Label3: TLabel;
    procedure BtnShowFiltersClick(Sender: TObject);
    procedure BtnShowHeaderClick(Sender: TObject);
    procedure BtnApplyFiltersClick(Sender: TObject);
    procedure BtnResetFiltersClick(Sender: TObject);
    procedure DateFromChange(Sender: TObject);
    procedure BtnNewOrderClick(Sender: TObject);

    private type
      TFloorOrder = record
        IsSelected: Boolean;
        Order: TOrder;
      end;

      TListFloorOrders = array of TFloorOrder;

    var
      FScrollHeight: Double;
      FContentHeight: Double;
      ListOrders: TListFloorOrders;
      procedure FlushFloor;
      procedure FetchOrders;
      procedure OrdersToFloor(Data: TDataSet);
      procedure OrderToFloor(AOrderRecord: TFields;const IndexRecord: Cardinal);
      procedure RenderOrder(AOrder: TPanel);
      function FormatDate(const ADate: TDateTime):string;
      procedure HandlePanelClick(Sender: TObject);
      procedure HandlePanelDblClick(Sender: TObject);
    public
      OnOrder: procedure(Order: TOrder = nil)of object;
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure HandleOrderCommit(Success: Boolean);
  end;

implementation
uses
  UdmServerMSSQL;

const DEFAULT_STORE_ID = 1;

{$R *.fmx}
  { TFloor }

procedure TFloor.BtnApplyFiltersClick(Sender: TObject);
begin
  DB.FetchOrdersFilterDate(DateFrom.Date, DateTo.Date,
    procedure(Data: TDataSource)
    begin
      if(Data <> nil)then
        OrdersToFloor(Data.DataSet)
      else
        OrdersToFloor(nil);
    end);
end;

procedure TFloor.HandleOrderCommit(Success: Boolean);
begin
end;

procedure TFloor.BtnNewOrderClick(Sender: TObject);
begin
  var
  NewOrder := TOrder.Create(nil, DEFAULT_STORE_ID);
  NewOrder.OnAfterCommit := HandleOrderCommit;
  OnOrder(NewOrder);
end;

procedure TFloor.BtnResetFiltersClick(Sender: TObject);
begin
  FetchOrders;
end;

procedure TFloor.BtnShowFiltersClick(Sender: TObject);
begin
  LayoutActions.RemoveObject(PanelActions);
  LayoutActions.AddObject(PanelDateFilter);
  PanelDateFilter.Visible := True;
end;

procedure TFloor.BtnShowHeaderClick(Sender: TObject);
begin
  LayoutActions.RemoveObject(PanelDateFilter);
  LayoutActions.AddObject(PanelActions);
end;

procedure TFloor.DateFromChange(Sender: TObject);
begin
  DateTo.Date := TDateEdit(Sender).Date;
end;

constructor TFloor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FScrollHeight := 0.0;
  FContentHeight := 0.0;
  DateFrom.Date := Today;
  DateTo.Date := Today;
  FetchOrders;
end;

destructor TFloor.Destroy;
begin
  FlushFloor;
  inherited Destroy;
end;

procedure TFloor.FlushFloor;
begin

  for var I := 0 to high(ListOrders)do
    FreeAndNil(ListOrders[I].Order);

  SetLength(ListOrders, 0);

  ScrollOrders.BeginUpdate;
  ScrollOrders.Content.DeleteChildren;
  ScrollOrders.RealignContent;
  ScrollOrders.EndUpdate;

  FScrollHeight := 0.0;
  FContentHeight := 0.0;
end;

procedure TFloor.FetchOrders;
begin

  DB.FetchAsyncOrders(
    procedure(Data: TDataSource)
    begin
      if(Data <> nil)then
        OrdersToFloor(Data.DataSet)
      else
        OrdersToFloor(nil);
    end);

end;

procedure TFloor.OrdersToFloor(Data: TDataSet);
begin

  if not Assigned(Data)then
    Exit;

  FlushFloor;
  SetLength(ListOrders, Data.RecordCount);
  while not Data.Eof do
  begin
    OrderToFloor(Data.Fields, Data.RecNo);
    Data.Next;
  end;

end;

procedure TFloor.OrderToFloor(AOrderRecord: TFields;
const IndexRecord: Cardinal);
begin
  var
  Order := TOrder.Create(AOrderRecord);
  var
  Panel := TemplateFloorOrder.Clone(ScrollOrders)as TPanel;

  TLabel(Panel.Components[1]).Text := Order.StockOrderID;
  TLabel(Panel.Components[2]).Text := FormatDate(Order.Date.Commited);
  Panel.Visible := True;
  Panel.TabOrder := IndexRecord;
  Panel.Tag := IndexRecord;

  Panel.OnDblClick := HandlePanelDblClick;
  if not(Order.Status = EStatusOrder.Served)then
    Panel.OnClick := HandlePanelClick;

  ListOrders[IndexRecord - 1].Order := Order;
  ListOrders[IndexRecord - 1].IsSelected := False;

  RenderOrder(Panel);
end;

procedure TFloor.RenderOrder(AOrder: TPanel);
begin

  if FScrollHeight = 0 then
    FScrollHeight := AOrder.Size.Height + AOrder.Margins.Bottom;

  FContentHeight := FContentHeight + FScrollHeight;
  AOrder.Position.Y := FContentHeight;

  {
    if FContentHeight > scrollOrders.Height then
    scrollOrders.scrollBy(0.0, -FContentHeight);
  }

  ScrollOrders.AddObject(AOrder);
end;

function TFloor.FormatDate(const ADate: TDateTime):string;
begin
  Datetimetostring(Result, 'ddd dd/mm/yy hh:mm', ADate);
end;

procedure TFloor.HandlePanelClick(Sender: TObject);
var
  POrder:^TFloorOrder;
begin
  var
  Style := TRectangle(TPanel(Sender).Components[0]);
  POrder :=@ListOrders[TPanel(Sender).Tag - 1];

  POrder^.IsSelected := not POrder^.IsSelected;

  if POrder^.IsSelected then
    Style.Fill.Color := TAlphaColorRec.Cornflowerblue
  else
    Style.Fill.Color := TAlphaColorRec.White;
end;

procedure TFloor.HandlePanelDblClick(Sender: TObject);
var
  POrder:^TFloorOrder;
begin
  POrder :=@ListOrders[TPanel(Sender).Tag - 1];

  // double clicking activates the onClick handler as well
  // this code makes sure to deactivate it
  POrder^.IsSelected := True;
  HandlePanelClick(Sender);

  OnOrder(POrder^.Order.Clone);

end;

end.
