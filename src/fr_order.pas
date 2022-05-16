unit fr_order;

interface

uses
 u_produce,
 untTypes,
 u_order,
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
 FMX.Edit;

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
  procedure btnDeleteProduceClick(Sender: TObject);
  procedure btnCommitOrderClick(Sender: TObject);
 private
 var
  scrollHeight: Double;
  contentHeight: Double;
 public
 var
  Order: TOrder;
  ListProduce: TListProduce;
  constructor Create(AOwner: TComponent; Order: TOrder);
  destructor Destroy; override;
 end;

implementation

{$R *.fmx}

 { FOrder }
procedure TFOrder.btnCancelOrderClick(Sender: TObject);
 begin
  showMessage('cancel order click');
 end;

procedure TFOrder.btnDeleteProduceClick(Sender: TObject);
 begin
  showMessage('delete produce click');
 end;

procedure TFOrder.btnCommitOrderClick(Sender: TObject);
 begin
  showMessage('commit order click');
 end;

constructor TFOrder.Create(AOwner: TComponent; Order: TOrder);
 begin
  inherited Create(AOwner);
 end;

destructor TFOrder.Destroy;
 begin

 end;

end.
