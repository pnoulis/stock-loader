﻿unit fr_pad;

interface
uses
  U_produce,
  UntTypes,
  U_order,
  UdmServerMSSQL,
  System.SysUtils,
  Data.DB,
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
    LayoutActions: TLayout;
    BtnCommitOrder: TButton;
    BtnCancelOrder: TButton;
    BtnDeleteProduce: TButton;
    Rectangle2: TRectangle;
    MemoOrderID: TMemo;
    LayoutStockHeaders: TLayout;
    LblitemCID: TLabel;
    LblStockIncrease: TLabel;
    PanelProduceTemplate: TPanel;
    Rectangle4: TRectangle;
    EdtStockBefore: TEdit;
    EdtStockIncrease: TEdit;
    EdtItemCID: TEdit;
    EdtItemName: TEdit;
    LblStockBefore: TLabel;
    LblItemName: TLabel;
    InputPanelTemplate: TPanel;
    Rectangle3: TRectangle;
    Loader: TAniIndicator;
    LayoutBody: TLayout;
    ScrollProduce: TVertScrollBox;
    LblStockAfter: TLabel;
    LblStockMoveID: TLabel;
    EdtStockAfter: TEdit;
    EdtStockMoveID: TEdit;
    procedure BtnCancelOrderClick(Sender: TObject);
    procedure BtnDeleteProduceClick(Sender: TObject);
    procedure BtnCommitOrderClick(Sender: TObject);

    private
    var
      ListProduce: TObjectList<TProduce>;
      FOrder: TOrder;
      FKitchenID: Word;
      FScrollHeight: Double;
      FContentHeight: Double;
      procedure RenderHeaderOrder;
      function FormatDate(const ADate: TDateTime):string;
      procedure OrderToFloor;
      procedure ProduceToFloor(AProduceRecord: TFields;
          const IndexRecord: Cardinal);
      procedure SwitchLoading;
      procedure AddNewProduce;
      procedure RenderNewProduce(AProduce: TPanel);
      procedure FlushPad;
      function AskUserOrderDelete: Boolean;
    public
    var
      OnOrderCancel: procedure(const KitchenID: Word)of object;
      OnOrderCommit: procedure(const KitchenID: Word)of object;
      constructor Create(AOwner: TComponent; Order: TOrder;
          const KitchenID: Word);
      destructor Destroy; override;
  end;

implementation
{$R *.fmx}

procedure TPad.BtnCancelOrderClick(Sender: TObject);
begin

  if(FOrder.Status = EStatusOrder.Commited)and AskUserOrderDelete then
    FOrder.Delete;

  OnOrderCancel(FKitchenID);
end;

procedure TPad.BtnDeleteProduceClick(Sender: TObject);
begin
  var
  ToBeRemoved := TList<TProduce>.Create;

  for var Produce in ListProduce do
    if(Produce.IsSelected)and(Produce.StatusProduce <> EStatusOrder.Commited)
    then
      ToBeRemoved.Add(Produce);

  for var Produce in ToBeRemoved do
    ListProduce.Remove(Produce);

  ToBeRemoved.Free;
  ListProduce.Last.SetFocus;
end;

procedure TPad.BtnCommitOrderClick(Sender: TObject);
var
  LastOrder: TProduce;
begin

  if(FOrder.Status = EStatusOrder.Served)then
    Exit;

  LastOrder := ListProduce.Last;
  ListProduce.Extract(LastOrder);
  FOrder.Commit(ListProduce);
  ListProduce.Add(LastOrder);
  RenderHeaderOrder;
  OnOrderCommit(FKitchenID);
end;

constructor TPad.Create(AOwner: TComponent; Order: TOrder;
    const KitchenID: Word);
begin
  inherited Create(AOwner);
  FOrder := Order;
  FKitchenID := KitchenID;
  ListProduce := TObjectList<TProduce>.Create;
  ListProduce.Capacity := 10;
  ListProduce.OwnsObjects := True;
  RenderHeaderOrder;
  OrderToFloor;

  if(FOrder.Status = EStatusOrder.Scratch)then
    AddNewProduce;
end;

destructor TPad.Destroy;
begin
  ListProduce.Free;
  inherited Destroy;
end;

procedure TPad.RenderHeaderOrder;
begin
  MemoOrderID.Lines.Clear;

  MemoOrderID.Lines.Add('Ημερομηνια Εκδοσης:');

  if(FOrder.Date.Commited <> 0)then
    MemoOrderID.Lines.Add(FormatDate(FOrder.Date.Commited))
  else
    MemoOrderID.Lines.Add('-');

  MemoOrderID.Lines.Add('Αρ. Παραγγελιας:');
  MemoOrderID.Lines.Add(FOrder.StockOrderID);
end;

function TPad.FormatDate(const ADate: TDateTime):string;
begin
  Datetimetostring(Result, 'ddd dd/mm/yy hh:mm', ADate);
end;

procedure TPad.SwitchLoading;
begin
  ScrollProduce.Visible := not ScrollProduce.Visible;
  Loader.Visible := not Loader.Visible;
  Loader.Enabled := not Loader.Enabled;
end;

procedure TPad.OrderToFloor;
begin

  FOrder.Fetch(
    procedure(Data: TDataset)
    begin

      if(Data = nil)then
        Exit;

      while not Data.Eof do
      begin
        ProduceToFloor(Data.Fields, Data.RecNo);
        Data.Next;
      end;

    end);

end;

procedure TPad.ProduceToFloor(AProduceRecord: TFields;
const IndexRecord: Cardinal);
var
  Template: TPanel;
begin
  Template := TPanel(PanelProduceTemplate.Clone(ScrollProduce));
  ListProduce.Add(TProduce.Create(FOrder.Status, Template, AProduceRecord));
  ScrollProduce.AddObject(Template);
  Template.Visible := True;
end;

procedure TPad.AddNewProduce;
var
  Template: TPanel;
  Produce: TProduce;
begin

  if(ScrollProduce.ComponentCount > 1)and
      (ListProduce.Last.StatusProduce = EStatusOrder.Scratch)then
  begin
    ListProduce.Last.SetFocus;
    Exit;
  end;

  Template := TPanel(InputPanelTemplate.Clone(ScrollProduce));
  Produce := TProduce.Create(FOrder.Status, Template);

  Produce.OnProduceCached := AddNewProduce;
  ListProduce.Add(Produce);

  RenderNewProduce(Template);
  Produce.WaitForProduce;
end;

procedure TPad.RenderNewProduce(AProduce: TPanel);
begin
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
  if FScrollHeight = 0 then
    FScrollHeight := InputPanelTemplate.Size.Height +
        InputPanelTemplate.Margins.Height;

  FContentHeight := FContentHeight + FScrollHeight;
  InputPanelTemplate.Position.Y := FContentHeight;

  if FContentHeight > Size.Height then
    ScrollProduce.ScrollBy(0.0, -FContentHeight);

  ScrollProduce.AddObject(AProduce);
  AProduce.Visible := True;
end;

procedure TPad.FlushPad;
begin
  ScrollProduce.BeginUpdate;
  ScrollProduce.Content.DeleteChildren;
  ScrollProduce.RealignContent;
  ScrollProduce.EndUpdate;

  FScrollHeight := 0.0;
  FContentHeight := 0.0;
end;

function TPad.AskUserOrderDelete: Boolean;
var
  Input: Integer;
const
  Msg = 'Η παραγγελια εχει αποθηκευμενες κινησεις. Να διαγραφει?';
begin

  Input := TDialogServiceSync.MessageDialog(Msg, TMsgDlgType.MtConfirmation,
      [TMsgDlgBtn.MbYes, TMsgDlgBtn.MbNo], TMsgDlgBtn.MbNo, MrNone);

  if(Input = MrYes)then
    Result := True
  else
    Result := False;

end;

end.
