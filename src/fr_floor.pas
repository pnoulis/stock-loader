unit fr_floor;

interface

uses
 untTypes,
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
  btnShowHeader: TButton;
  Layout1: TLayout;
  lblDateFilterHeader: TLabel;
  lblDateFrom: TLabel;
  dateFrom: TDateEdit;
  dateTo: TDateEdit;
  lblDateTo: TLabel;
  panelActions: TPanel;
  Rectangle5: TRectangle;
  btnNewOrder: TButton;
  btnShowFilters: TButton;
  btnApplyFilters: TButton;
  btnResetFilters: TButton;
    Label3: TLabel;
  procedure btnShowFiltersClick(Sender: TObject);
  procedure btnShowHeaderClick(Sender: TObject);
  procedure btnApplyFiltersClick(Sender: TObject);
  procedure btnResetFiltersClick(Sender: TObject);
  procedure dateFromChange(Sender: TObject);
  procedure btnNewOrderClick(Sender: TObject);

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
  onOrder: procedure(Order: TOrder = nil) of object;
  constructor Create(AOwner: TComponent); override;
  destructor Destroy; override;
  procedure handleOrderCommit(success: Boolean);
 end;

implementation

uses
 udmServerMSSQL;

const DEFAULT_STORE_ID = 1;

{$R *.fmx}
 { TFloor }

procedure TFloor.btnApplyFiltersClick(Sender: TObject);
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

procedure TFloor.handleOrderCommit(success: Boolean);
 begin
  showMessage('yes it was commited');
 end;

procedure TFloor.btnNewOrderClick(Sender: TObject);
 begin
  var
  newOrder := TOrder.Create(nil, DEFAULT_STORE_ID);
  newOrder.onAfterCommit := handleOrderCommit;
  onOrder(newOrder);
 end;

procedure TFloor.btnResetFiltersClick(Sender: TObject);
 begin
  fetchOrders;
 end;

procedure TFloor.btnShowFiltersClick(Sender: TObject);
 begin
  layoutActions.RemoveObject(panelActions);
  layoutActions.AddObject(panelDateFilter);
  panelDateFilter.Visible := true;
 end;

procedure TFloor.btnShowHeaderClick(Sender: TObject);
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

  // double clicking activates the onClick handler as well
  // this code makes sure to deactivate it
  POrder^.isSelected := true;
  handlePanelClick(Sender);

  onOrder(POrder^.Order.Clone);

 end;

end.
