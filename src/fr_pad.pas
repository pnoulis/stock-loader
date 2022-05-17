unit fr_pad;

interface

uses
 u_produce,
 untTypes,
 u_order,
 udmServerMSSQL,
 System.SysUtils,
 data.DB,
 System.Types,
 System.DateUtils,
 System.UITypes,
 System.Classes,
 System.Variants,
 FMX.Types,
 FMX.Graphics,
 FMX.TabControl,
 FMX.Controls,
 FMX.Forms,
 FMX.Dialogs,
 FMX.StdCtrls,
 FMX.Controls.Presentation,
 FMX.Objects,
 FMX.Layouts,
 FireDAC.Comp.Client,
 FMX.Memo.Types,
 FMX.ScrollBox,
 FMX.Memo,
 FMX.Edit;

type
 TPad = class(TFrame)
  Rectangle1: TRectangle;
  layoutActions: TLayout;
  btnCommitOrder: TButton;
  btnCancelOrder: TButton;
  btnDeleteProduce: TButton;
  Rectangle2: TRectangle;
  memoOrderID: TMemo;
  layoutStockHeaders: TLayout;
  lblCodeHeader: TLabel;
  lblAmountHeader: TLabel;
  panelProduceTemplate: TPanel;
  Rectangle4: TRectangle;
  edtProduceAfter: TEdit;
  edtProduceIncrBy: TEdit;
  edtProduceID: TEdit;
  edtProduceName: TEdit;
  lblStockAfter: TLabel;
  lblItemName: TLabel;
  inputPanelTemplate: TPanel;
  Rectangle3: TRectangle;
  loader: TAniIndicator;
  layoutBody: TLayout;
  scrollProduce: TVertScrollBox;
  procedure btnCancelOrderClick(Sender: TObject);
  procedure btnDeleteProduceClick(Sender: TObject);
  procedure btnCommitOrderClick(Sender: TObject);
 private
 var
  FOrder: TOrder;
  scrollHeight: Double;
  contentHeight: Double;
  procedure renderHeaderOrder;
  function formatDate(const ADate: TDateTime): string;
  procedure OrderToFloor;
  procedure ProduceToFloor;
  procedure switchLoading;
 public
 var
  ListProduce: TListProduce;
  constructor Create(AOwner: TComponent; Order: TOrder);
  destructor Destroy; override;
 end;

implementation

{$R *.fmx}

procedure TPad.btnCancelOrderClick(Sender: TObject);
 begin
  showMessage('cancel order click');
 end;

procedure TPad.btnDeleteProduceClick(Sender: TObject);
 begin
  showMessage('delete produce click');
 end;

procedure TPad.btnCommitOrderClick(Sender: TObject);
 begin
  showMessage('commit order click');
 end;

constructor TPad.Create(AOwner: TComponent; Order: TOrder);
 begin
  inherited Create(AOwner);
  FOrder := Order;
  renderHeaderOrder;
  switchLoading;
 end;

destructor TPad.Destroy;
 begin
  inherited Destroy;
 end;

procedure TPad.renderHeaderOrder;
 begin
  memoOrderID.Lines.add('Ημερομηνια Εκδοσης:');

  if (FOrder.Date.commited <> 0) then
   memoOrderID.Lines.add(formatDate(FOrder.Date.commited))
  else
   memoOrderID.Lines.add('-');

  memoOrderID.Lines.add('Αρ. Παραγγελιας:');
  memoOrderID.Lines.add(FOrder.StockOrderID.ToString);
 end;

function TPad.formatDate(const ADate: TDateTime): string;
 Begin
  datetimetostring(result, 'ddd dd/mm/yy hh:mm', ADate);
 end;

procedure TPad.switchLoading;
 begin
  scrollProduce.Visible := not scrollProduce.Visible;
  loader.Visible := not loader.Visible;
  loader.Enabled := not loader.Enabled;
 end;

procedure TPad.OrderToFloor;
 begin
  switchLoading;

  FOrder.fetch(
  procedure(Data: TDataset)
  begin
  if (data = nil) then exit;

  while not Data.Eof do
  begin

  end;

  end);

  FOrder.fetch;
  flushFloor;
  setLength(ListOrders, Data.RecordCount);
  while not Data.Eof do
   begin
    OrderToFloor(Data.Fields, Data.RecNo);
    Data.Next;
   end;

 end;

procedure TPad.ProduceToFloor;
 begin
 end;

end.
