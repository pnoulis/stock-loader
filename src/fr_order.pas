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
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Edit, u_TTextInput;

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
    Label1: TLabel;
    label2: TLabel;
    scrollProduce: TVertScrollBox;
    inputProduceID: TTextInput;
    inputPanelTemplate: TPanel;
    Rectangle3: TRectangle;
    inputProduceIncrBy: TTextInput;
    inputProduceAfter: TTextInput;
    inputProduceName: TTextInput;
    TextInput1: TTextInput;
    procedure btnCancelOrderClick(Sender: TObject);
  private
    procedure fetchProduce;
  public
  var
    Order: TOrder;
    ListProduce: TListProduce;
    tabIndex: Cardinal;
    onCancelOrderClick: procedure(FOrder: TFOrder) of object;
    constructor Create(AOwner: TComponent; Order: TOrder);
    destructor Destroy; override;
    procedure addProduce;
  end;

implementation

{$R *.fmx}
{ FOrder }

procedure TFOrder.addProduce;
var
  panel: TPanel;
begin
  var
  lnProduce := length(ListProduce);
  setLength(ListProduce, lnProduce + 1);

  showMessage(TextInput1.ClassName);
  panel := TPanel(inputPanelTemplate.Clone(self));
  panel.Align := TAlignLayout.Top;
  panel.Margins.Bottom := 20.0;
  panel.Visible := true;

  ListProduce[lnProduce] := TProduce.Create(Order.status, panel);

  scrollProduce.AddObject(panel);
  //ListProduce[lnProduce].waitForProduce;
end;

procedure TFOrder.btnCancelOrderClick(Sender: TObject);
begin
  onCancelOrderClick(self);
end;

constructor TFOrder.Create(AOwner: TComponent; Order: TOrder);
begin
  inherited Create(AOwner);

  memoOrderID.Lines.Add(Order.id.toString);

  self.Order := Order;

  if (Order.status = EStatusOrder.scratch) then
  begin
    self.addProduce
  end
  else if (Order.status = EStatusOrder.commited) then
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
    freeAndNil(ListProduce[i]);
  setLength(ListProduce, 0);
  inherited;
end;

procedure TFOrder.fetchProduce;
var
  ListFields: TArray<Tfields>;
  panel: TPanel;

begin

  try
    ListFields := DB.fetchProduce(Order.status, Order.id);
    setLength(ListProduce, length(ListFields));

    for var i := low(ListFields) to High(ListFields) do
    begin
      panel := inputPanelTemplate.Create(self);
      ListProduce[i] := TProduce.Create(Order.status, inputPanelTemplate,
        ListFields[i]);
      scrollProduce.AddObject(panel);
    end;

    setLength(ListFields, 0);

  except
    on E: Exception do
    begin
      setLength(ListFields, 0);
      showMessage(E.Message);
    end;

  end;

end;

end.
