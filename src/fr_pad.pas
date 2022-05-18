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
 System.Generics.Collections,
 System.UIConsts,
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
 FMX.DialogService.Sync,
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
  ListProduce: TList<TProduce>;
  FOrder: TOrder;
  FKitchenID: word;
  FScrollHeight: Double;
  FContentHeight: Double;
  procedure renderHeaderOrder;
  function formatDate(const ADate: TDateTime): string;
  procedure OrderToFloor;
  procedure ProduceToFloor(AProduceRecord: TFields;
   const IndexRecord: cardinal);
  procedure switchLoading;
  procedure addNewProduce;
  procedure renderNewProduce(AProduce: TPanel);
  procedure flushPad;
  function askUserOrderDelete: Boolean;
 public
 var
  onOrderCancel: procedure(const KitchenID: word) of object;
  constructor Create(AOwner: TComponent; Order: TOrder; const KitchenID: word);
  destructor Destroy; override;
 end;

implementation

{$R *.fmx}

procedure TPad.btnCancelOrderClick(Sender: TObject);
 begin
  askUserOrderDelete;
  {
    if (FOrder.Status = EStatusOrder.commited) and askUserOrderDelete then
    FOrder.delete;

    onOrderCancel(FKitchenID);
  }
 end;

procedure TPad.btnDeleteProduceClick(Sender: TObject);
 begin
  for var produce in ListProduce do
   begin
    if not(produce.isSelected) then
     continue;

    if (produce.statusProduce = EStatusOrder.cached) then
     FOrder.delete([produce]);

    FreeAndNil(produce.graphic);
    produce.Free;
    ListProduce.Remove(produce);
   end;

  ListProduce.Last.setFocus;
 end;

procedure TPad.btnCommitOrderClick(Sender: TObject);
 begin
  showMessage('commit order click');
 end;

constructor TPad.Create(AOwner: TComponent; Order: TOrder;
 const KitchenID: word);
 begin
  inherited Create(AOwner);
  FOrder := Order;
  FKitchenID := KitchenID;
  ListProduce := TList<TProduce>.Create;
  ListProduce.Capacity := 10;
  renderHeaderOrder;
  OrderToFloor;

  if (FOrder.Status = EStatusOrder.scratch) then
   addNewProduce;
 end;

destructor TPad.Destroy;
 begin
  for var produce in ListProduce do
   produce.Free;

  FreeAndNil(ListProduce);

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

  FOrder.fetch(
    procedure(data: TDataset)
    begin

     if (data = nil) then
      exit;

     while not data.Eof do
      begin
       ProduceToFloor(data.Fields, data.RecNo);
       data.Next;
      end;

    end);

 end;

procedure TPad.ProduceToFloor(AProduceRecord: TFields;
const IndexRecord: cardinal);
 var
  template: TPanel;
 begin
  template := TPanel(panelProduceTemplate.Clone(scrollProduce));
  ListProduce.add(TProduce.Create(FOrder.Status, template, AProduceRecord));
  scrollProduce.AddObject(template);
  template.Visible := true;
 end;

procedure TPad.addNewProduce;
 var
  template: TPanel;
  produce: TProduce;
 begin

  if (scrollProduce.ComponentCount > 1) and
      (ListProduce.Last.statusProduce = EStatusOrder.scratch) then
   begin
    ListProduce.Last.setFocus;
    exit;
   end;

  template := TPanel(inputPanelTemplate.Clone(scrollProduce));
  produce := TProduce.Create(FOrder.Status, template);

  produce.onProduceCached := addNewProduce;
  ListProduce.add(produce);

  renderNewProduce(template);
  produce.waitForProduce;
 end;

procedure TPad.renderNewProduce(AProduce: TPanel);
 begin
  // Delphi does not know how to position                          ^
  // dynamically added components into a tvertscrollbox.
  // By default it will insert the objects inverted such as:
  // ... 5 4 3 2 1
  // and the 1st one will always remain at the top such as:
  // 1 4 3 2
  // 1 5 4 3 2...
  // Found a solution to the issue in this article:
  // https://stackoverflow.com/questions/62259407/
  // delphi-fmx-how-to-add-a-dynamically-created-top-aligned-component-under-all-pre
  // stock.align := top (at constructor)
  if FScrollHeight = 0 then
   FScrollHeight := inputPanelTemplate.Size.Height +
       inputPanelTemplate.Margins.Height;

  FContentHeight := FContentHeight + FScrollHeight;
  inputPanelTemplate.Position.Y := FContentHeight;

  if FContentHeight > Size.Height then
   scrollProduce.scrollBy(0.0, -FContentHeight);

  scrollProduce.AddObject(AProduce);
  AProduce.Visible := true;
 end;

procedure TPad.flushPad;
 begin
  scrollProduce.BeginUpdate;
  scrollProduce.Content.DeleteChildren;
  scrollProduce.RealignContent;
  scrollProduce.EndUpdate;

  FScrollHeight := 0.0;
  FContentHeight := 0.0;
 end;

function TPad.askUserOrderDelete: Boolean;
 var input: integer;
 const msg = 'Η παραγγελια εχει αποθηκευμενες κινησεις. Να διαγραφει?';
 begin

  input := TDialogServiceSync.MessageDialog(msg, TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, mrNone);

  if (input = mrYes) then
   result := true
  else
   result := false;

 end;

end.
