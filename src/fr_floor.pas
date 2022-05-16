unit fr_floor;

interface

uses
 untTypes,
 udmServerMSSQL,
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
 FireDAC.Comp.Client,
 FMX.Controls.Presentation,
 Data.DB,
 FMX.Layouts,
 FMX.Objects,
 FMX.Calendar,
 FMX.DateTimeCtrls;

type
 TFloor = class(TFrame)
  layoutActions: TLayout;
  layoutHeader: TLayout;
  lblOrderID: TLabel;
  lblOrderDate: TLabel;
  scrollOrders: TVertScrollBox;
  Rectangle2: TRectangle;
  templateFloorOrder: TPanel;
  Label1: TLabel;
  Label2: TLabel;
  Rectangle3: TRectangle;
  panelDateFilter: TPanel;
  Rectangle4: TRectangle;
  btnShowHeaderClick: TButton;
  Layout1: TLayout;
  lblDateFilterHeader: TLabel;
  lblDateFrom: TLabel;
  dateFrom: TDateEdit;
  dateTo: TDateEdit;
  lblDateTo: TLabel;
  panelActions: TPanel;
  Rectangle5: TRectangle;
  btnNewOrderClick: TButton;
  Button4: TButton;
  btnShowFiltersClick: TButton;
  btnApplyFilterClick: TButton;
  btnRefreshFilterClick: TButton;
  procedure btnShowFiltersClickClick(Sender: TObject);
  procedure btnShowHeaderClickClick(Sender: TObject);
  procedure dateFromChange(Sender: TObject);
  procedure btnApplyFilterClickClick(Sender: TObject);
  procedure btnRefreshFilterClickClick(Sender: TObject);

 private type
  TFloorOrder = record
   isSelected: Boolean;
   Order: TOrder;
  end;

  TListFloorOrders = array of TFloorOrder;

 var
  FScrollHeight: Double;
  FContentHeight: Double;
  ListOrders: TListFloorOrders;
  procedure flushFloor;
  procedure fetchOrders;
  procedure OrdersToFloor(Data: TDataSet);
  procedure OrderToFloor(AOrderRecord: TFields; const IndexRecord: cardinal);
  procedure renderOrder(AOrder: TPanel);
  function formatDate(const ADate: TDateTime): string;
  procedure handlePanelClick(Sender: TObject);
  procedure handlePanelDblClick(Sender: TObject);
 public
  onNewOrder: procedure(Order: TOrder = nil) of object;
  constructor Create(AOwner: TComponent); override;
  destructor Destroy; override;
 end;

implementation

{$R *.fmx}
{ TFloor }

procedure TFloor.btnApplyFilterClickClick(Sender: TObject);
 begin
  DB.fetchOrdersFilterDate(dateFrom.Date, dateTo.Date,
    procedure(Data: TDataSource)
    begin
     if (Data <> nil) then
      OrdersToFloor(Data.DataSet)
     else
      OrdersToFloor(nil);
    end);
 end;

procedure TFloor.btnRefreshFilterClickClick(Sender: TObject);
 begin
  fetchOrders;
 end;

procedure TFloor.btnShowFiltersClickClick(Sender: TObject);
 begin
  layoutActions.RemoveObject(panelActions);
  layoutActions.AddObject(panelDateFilter);
  panelDateFilter.Visible := true;
 end;

procedure TFloor.btnShowHeaderClickClick(Sender: TObject);
 begin
  layoutActions.RemoveObject(panelDateFilter);
  layoutActions.AddObject(panelActions);
 end;

procedure TFloor.dateFromChange(Sender: TObject);
 begin
  dateTo.Date := TDateEdit(Sender).Date;
 end;

constructor TFloor.Create(AOwner: TComponent);
 begin
  inherited Create(AOwner);
  FScrollHeight := 0.0;
  FContentHeight := 0.0;
  fetchOrders;
 end;

destructor TFloor.Destroy;
 begin
  flushFloor;
  inherited Destroy;
 end;

procedure TFloor.flushFloor;
 begin

  for var i := 0 to High(ListOrders) do
   FreeAndNil(ListOrders[i].Order);

  setLength(ListOrders, 0);

  scrollOrders.BeginUpdate;
  scrollOrders.Content.DeleteChildren;
  scrollOrders.RealignContent;
  scrollOrders.EndUpdate;

  FScrollHeight := 0.0;
  FContentHeight := 0.0;
 end;

procedure TFloor.fetchOrders;
 begin

  DB.fetchAsyncOrders(
   procedure(Data: TDataSource)
    begin
     if (Data <> nil) then
      OrdersToFloor(Data.DataSet)
     else
      OrdersToFloor(nil);
    end);

 end;

procedure TFloor.OrdersToFloor(Data: TDataSet);
 begin

  if not assigned(Data) then
   exit;

  flushFloor;
  setLength(ListOrders, Data.RecordCount);
  while not Data.Eof do
   begin
    OrderToFloor(Data.Fields, Data.RecNo);
    Data.Next;
   end;

 end;

procedure TFloor.OrderToFloor(AOrderRecord: TFields;
const IndexRecord: cardinal);
 begin
  var
  Order := TOrder.Create(AOrderRecord);
  var
  Panel := templateFloorOrder.Clone(scrollOrders) as TPanel;

  TLabel(Panel.Components[1]).Text := Order.StockOrderID.ToString;
  TLabel(Panel.Components[2]).Text := formatDate(Order.Date.commited);
  Panel.Visible := true;
  Panel.TabOrder := IndexRecord;
  Panel.Tag := IndexRecord;

  Panel.OnDblClick := handlePanelDblClick;
  if not(Order.Status = EStatusOrder.served) then
   Panel.OnClick := handlePanelClick;

  ListOrders[IndexRecord - 1].Order := Order;
  ListOrders[IndexRecord - 1].isSelected := false;

  renderOrder(Panel);
 end;

procedure TFloor.renderOrder(AOrder: TPanel);
 begin

  if FScrollHeight = 0 then
   FScrollHeight := AOrder.Size.Height + AOrder.Margins.Bottom;

  FContentHeight := FContentHeight + FScrollHeight;
  AOrder.Position.Y := FContentHeight;

  {
    if FContentHeight > scrollOrders.Height then
    scrollOrders.scrollBy(0.0, -FContentHeight);
  }

  scrollOrders.AddObject(AOrder);
 end;

function TFloor.formatDate(const ADate: TDateTime): string;
 Begin
  datetimetostring(result, 'ddd dd/mm/yy hh:mm', ADate);
 end;

procedure TFloor.handlePanelClick(Sender: TObject);
 var
  POrder: ^TFloorOrder;
 begin
  var
  Style := TRectangle(TPanel(Sender).Components[0]);
  POrder := @ListOrders[TPanel(Sender).Tag - 1];

  POrder^.isSelected := not POrder^.isSelected;

  if POrder^.isSelected then
   Style.fill.Color := TAlphaColorRec.Cornflowerblue
  else
   Style.fill.Color := TAlphaColorRec.white;
 end;

procedure TFloor.handlePanelDblClick(Sender: TObject);
 var
  POrder: ^TFloorOrder;
 begin
  POrder := @ListOrders[TPanel(Sender).Tag - 1];

  if assigned(TPanel(Sender).OnClick) then
   begin
    POrder^.isSelected := true;
    handlePanelClick(Sender);
   end;

 end;

end.
