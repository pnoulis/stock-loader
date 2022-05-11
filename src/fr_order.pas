unit fr_order;

interface

uses
 u_produce,
 u_order,
 data.DB,
 untTypes,
 udmServerMSSQL,
 System.SysUtils,
 System.Types,
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
 FMX.Edit,
 u_TTextInput;

type
 TFOrder = class(TFrame)
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
  scrollProduce: TVertScrollBox;
  inputPanelTemplate: TPanel;
  Rectangle3: TRectangle;
  loaderCommit: TAniIndicator;
  procedure btnCancelOrderClick(Sender: TObject);
  procedure Button1Click(Sender: TObject);
  procedure btnDeleteProduceClick(Sender: TObject);
  procedure btnCommitOrderClick(Sender: TObject);
 private
 var
  scrollHeight: Double;
  contentHeight: Double;
  procedure fetchProduce;
 public
 var
  Order: TOrder;
  ListProduce: TListProduce;
  onCancelOrderClick: procedure(FOrder: TFOrder) of object;
  onCommitOrder: procedure(FOrder: TFOrder) of object;
  procedure commitProduce;
  constructor Create(AOwner: TComponent; Order: TOrder);
  destructor Destroy; override;
  procedure addProduce;
 end;

implementation

const DEFAULT_STORE_ID = 1;
{$R *.fmx}
 { FOrder }

procedure TFOrder.commitProduce;
 begin
  memoOrderID.Lines.Delete(1);
  memoOrderID.Lines.Add(Order.stockOrderID.ToString);
  var commitSome: TListProduce;
  var
  i := 0;

  setLength(commitSome, length(ListProduce));

  for var produce in ListProduce do
   if produce.isSelected then
    begin
     commitSome[i] := produce;
     inc(i);
    end;


  for var produce in ListProduce do
   begin
    if produce.statusProduce = EstatusOrder.cached then
     begin
      DB.addStockMove(produce.itemCID, Order.stockOrderID,
       produce.stockIncrease, DEFAULT_STORE_ID, produce.moveID);
     end;

   end;

  {
    if i >= 1 then
    begin

    for var produce in commitSome do
    begin
    if (produce.statusProduce = EstatusOrder.cached) then
    begin
    DB.addStockMove(produce.itemCID, Order.stockOrderID,
    produce.stockIncrease, DEFAULT_STORE_ID, produce.moveID);
    end;
    end;

    end
    else
    begin
    for var produce in ListProduce do
    begin
    if produce.statusProduce = EstatusOrder.cached then
    begin
    DB.addStockMove(produce.itemCID, Order.stockOrderID,
    produce.stockIncrease, DEFAULT_STORE_ID, produce.moveID);
    end;

    end;

    end;
  }
  self.Order.isFetching := false;
  layoutActions.Enabled := true;
  scrollProduce.Visible := true;
  loaderCommit.Visible := false;
  loaderCommit.Enabled := false;
  loaderCommit.SendToBack;
 end;

procedure TFOrder.addProduce;
 var
  panel: TPanel;
 begin
  var
  lnProduce := length(ListProduce);

  // Kitchen is only allowed to add a produce if the last one
  // has been cached. ( TKitchen 1st element is TScrollContent )
  if (lnProduce > 1) and
      (ListProduce[lnProduce - 1].statusProduce = EstatusOrder.scratch) then
   begin
    ListProduce[lnProduce - 1].setFocus;
    exit;
   end;

  setLength(ListProduce, lnProduce + 1);

  panel := TPanel(inputPanelTemplate.Clone(self));
  panel.Align := TAlignLayout.Top;
  panel.Margins.Bottom := 20.0;
  panel.Visible := true;

  ListProduce[lnProduce] := TProduce.Create(Order.status, panel);
  ListProduce[lnProduce].onProduceCached := addProduce;

  scrollProduce.AddObject(panel);

  // Delphi does not know how to position
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
  if scrollHeight = 0 then
   scrollHeight := panel.Size.Height + panel.Margins.Height;

  contentHeight := contentHeight + scrollHeight;
  panel.Position.Y := contentHeight;

  if contentHeight > Size.Height then
   scrollProduce.scrollBy(0.0, -contentHeight);

  TThread.CreateAnonymousThread(
    procedure
    begin
     sleep(500);
     TThread.Synchronize(nil,
       procedure
       begin
        ListProduce[lnProduce].waitForProduce;
       end);
    end).Start;
 end;

procedure TFOrder.btnCancelOrderClick(Sender: TObject);
 begin
  TThread.CreateAnonymousThread(
   procedure
    begin
     TThread.Synchronize(nil,
       procedure
       begin
        onCancelOrderClick(self);
       end);
    end).Start;
 end;

procedure TFOrder.btnCommitOrderClick(Sender: TObject);
 begin
  if length(ListProduce) < 2 then
   exit;
  if Order.stockOrderID > 0 then
   exit;
  self.Order.isFetching := true;
  layoutActions.Enabled := false;
  scrollProduce.Visible := false;
  loaderCommit.Visible := true;
  loaderCommit.Enabled := true;
  loaderCommit.BringToFront;
  onCommitOrder(self);
 end;

procedure TFOrder.btnDeleteProduceClick(Sender: TObject);
 var
  newList: TListProduce;
 begin
  var
  Y := 0;

  for var i := high(ListProduce) - 1 downto low(ListProduce) do
   begin
    if ListProduce[i].isSelected then
     begin
      contentHeight := contentHeight - scrollHeight;
      FreeAndNil(ListProduce[i].graphic);
      FreeAndNil(ListProduce[i]);
     end;
   end;

  setLength(newList, scrollProduce.content.childrencount - 1);

  for var i := low(ListProduce) to high(ListProduce) do
   if assigned(ListProduce[i]) then
    begin
     newList[Y] := ListProduce[i];
     inc(Y);
    end;

  ListProduce := newList;

  ListProduce[Y - 1].setFocus;
 end;

procedure TFOrder.Button1Click(Sender: TObject);
 var
  panel: TPanel;
 begin
  panel := TPanel(inputPanelTemplate.Clone(self));
  panel.Align := TAlignLayout.Top;
  panel.Margins.Bottom := 20.0;
  panel.Visible := true;

  scrollProduce.AddObject(panel);

 end;

constructor TFOrder.Create(AOwner: TComponent; Order: TOrder);
 begin
  inherited Create(AOwner);

  scrollHeight := 0.0;
  contentHeight := 0.0;
  memoOrderID.Lines.Add(Order.stockOrderID.ToString);

  self.Order := Order;


  if (Order.status = EstatusOrder.scratch) then
   begin
    self.addProduce
   end
  else if (Order.status = EstatusOrder.commited) then
   begin
    self.fetchProduce;
    self.addProduce;
   end
  else
   begin
    self.fetchProduce
   end;

 end;

destructor TFOrder.Destroy;
 begin
  for var i := low(ListProduce) to high(ListProduce) do
   FreeAndNil(ListProduce[i]);
  setLength(ListProduce, 0);
  inherited;
 end;

procedure TFOrder.fetchProduce;
 var
  data: TFDQuery;
  panel: TPanel;

 begin

  try
   data := DB.fetchProduce(Order.status, Order.stockOrderID);
   setLength(ListProduce, data.RecordCount);

   if data.RecordCount < 1 then
    exit;

   if (Order.status = EstatusOrder.served) then
    begin

     for var i := low(listProduce) to High(ListProduce) do
      begin
       panel := TPanel(panelProduceTemplate.Clone(self));
       panel.Align := TAlignLayout.Top;
       panel.Visible := true;
       panel.Margins.Bottom := 20.0;

       ListProduce[i] := TProduce.Create(Order.status, panel, data);
       scrollProduce.AddObject(panel);
       data.Next;
      end;

    end
   else
    begin
     for var i := low(listProduce) to High(ListProduce) do
      begin
       panel := TPanel(inputPanelTemplate.Clone(self));
       panel.Align := TAlignLayout.Top;
       panel.Visible := true;
       panel.Margins.Bottom := 20.0;

       ListProduce[i] := TProduce.Create(Order.status, panel, data);
       ListProduce[i].onProduceCached := addProduce;
       scrollProduce.AddObject(panel);

       data.Next;
      end;
    end;

  except
   on E: Exception do
    begin
     showMessage(E.Message);
    end;

  end;

 end;

end.
