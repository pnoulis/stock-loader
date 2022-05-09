unit fr_order;

interface

uses
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
 FMX.StdCtrls, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Edit;

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
    listProduce: TVertScrollBox;
    panelProduceTemplate: TPanel;
    Rectangle4: TRectangle;
    edtProduceAfter: TEdit;
    edtProduceIncrBy: TEdit;
    edtProduceStockID: TEdit;
    edtProduceName: TEdit;
    Label1: TLabel;
    label2: TLabel;
 private
 public
  constructor Create(AOwner: TComponent; Order: TOrder);
 end;

implementation

{$R *.fmx}

{ FOrder }

constructor TFOrder.Create(AOwner: TComponent; Order: TOrder);
begin
inherited Create(AOwner);

memoOrderID.Lines.Add(Order.id.ToString);
end;

end.
