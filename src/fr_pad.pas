unit fr_pad;

interface
uses
  U_produce,
  UntTypes,
  U_order,
  System.SysUtils,
  Data.DB,
  System.UITypes,
  System.Classes,
  System.Generics.Collections,
  FMX.Forms,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Objects,
  FMX.Layouts,
  FMX.DialogService.Sync,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Edit,
  FMX.Controls,
  FMX.Dialogs,
  FMX.Types;

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
    LayoutBody: TLayout;
    ScrollProduce: TVertScrollBox;
    LblStockAfter: TLabel;
    LblStockMoveID: TLabel;
    EdtStockAfter: TEdit;
    EdtStockMoveID: TEdit;

    private
    var
      ListProduce: TObjectList<TProduce>;
      FOrder: TOrder;
      FScrollHeight: Double;
      FContentHeight: Double;
      procedure RenderHeaderOrder;
      function FormatDate(const ADate: TDateTime): string;
      procedure OrderToFloor;
      procedure ProduceToFloor(AProduceRecord: TFields;
          const IndexRecord: Cardinal);
      procedure RenderNewProduce(AProduce: TPanel);
      procedure FlushPad;
      procedure HandleOrderError(Err: EOrder);
      function AskOrderCancelConfirmation: Boolean;
      procedure HandleBtnOrderCancelClick(Sender: TObject);
      procedure HandleBtnOrderCommitClick(Sender: TObject);
      procedure HandleBtnProduceDeleteClick(Sender: TObject);
    public
    var
      FKOrderID: Word;
      OnOrderCancel: procedure(var KOrderID: Word) of object;
      OnOrderCommit: procedure(var KOrderID: Word) of object;
      constructor Create(AOwner: TComponent; Order: TOrder;
          const KOrderID: Word);
      destructor Destroy; override;
      procedure AddNewProduce;
      procedure SetFocus;
  end;

implementation
{$R *.fmx}

procedure TPad.HandleBtnOrderCancelClick(Sender: TObject);
begin
  var
  Cancel := True;

  for var Produce in ListProduce do
    if (Produce.StatusProduce <= EStatusOrder.Commited) then
    begin
      Cancel := AskOrderCancelConfirmation;
      Break;
    end;

  if Cancel then
  begin
    FOrder.Delete;
    OnOrderCancel(FKOrderID);
  end;
end;

procedure TPad.HandleBtnOrderCommitClick(Sender: TObject);
var
  ToCommit: TListProduce;
begin

  for var I := 0 to ListProduce.Count - 1 do
    if (ListProduce[I].StatusProduce < EStatusOrder.Scratch) then
    begin
      Setlength(ToCommit, I + 1);
      ToCommit[I] := ListProduce[I];
    end;

  if Length(ToCommit) = 0 then
  begin
    AddNewProduce;
    Exit;
  end;

  FOrder.Commit(ToCommit);
  RenderHeaderOrder;
  OnOrderCommit(FKOrderID);
  AddNewProduce;
end;

procedure TPad.HandleBtnProduceDeleteClick(Sender: TObject);
var
  ToBeRemoved: TListProduce;
begin
  var
  LnToBeRemoved := 0;

  for var Produce in Listproduce do
    if Produce.IsSelected then
    begin
      Inc(LnToBeRemoved);
      SetLength(ToBeRemoved, LnToBeRemoved);
      ToBeRemoved[LnToBeRemoved - 1] := Produce;
    end;

  FOrder.Delete(ToBeRemoved);

  for var Produce in ToBeRemoved do
    ListProduce.Remove(Produce);

  SetLength(ToBeRemoved, 0);
  AddNewProduce;
end;

function TPad.AskOrderCancelConfirmation: Boolean;
var
  Input: Integer;
const
  Msg = 'Η Παραγγελια εχει καταχωρημενες κινησεις. Να ακυρωθει?';
begin

  Input := TDialogServiceSync.MessageDialog(Msg, TMsgDlgType.MtConfirmation,
      [TMsgDlgBtn.MbYes, TMsgDlgBtn.MbNo], TMsgDlgBtn.MbNo, MrNone);

  if (Input = MrYes) then
    Result := True
  else
    Result := False;
end;

procedure TPad.HandleOrderError(Err: EOrder);
begin
  if (Err.Name = 'EOrderDeleteNotLast') then
  begin
    ShowMessage
        ('Μπορειτε να διαγραψεται μια παραγγελια μονο υπο την προυποθεση οτι ειναι η τελευταια στην αριθμιση');
  end;
end;

procedure TPad.SetFocus;
begin

end;

constructor TPad.Create(AOwner: TComponent; Order: TOrder;
    const KOrderID: Word);
begin
  inherited Create(AOwner);
  FOrder := Order;
  FKOrderID := KOrderID;
  ListProduce := TObjectList<TProduce>.Create;
  ListProduce.Capacity := 10;
  ListProduce.OwnsObjects := True;
  RenderHeaderOrder;
  OrderToFloor;

  if (FOrder.Status > EStatusOrder.Served) then
  begin
    BtnCommitOrder.OnClick := HandleBtnOrderCommitClick;
    BtnCancelOrder.OnClick := HandleBtnOrderCancelClick;
    BtnDeleteProduce.OnClick := HandleBtnProduceDeleteClick;
    AddNewProduce;
  end;
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

  if (FOrder.Date.Commited <> 0) then
    MemoOrderID.Lines.Add(FormatDate(FOrder.Date.Commited))
  else
    MemoOrderID.Lines.Add('-');

  MemoOrderID.Lines.Add('Αρ. Παραγγελιας:');
  MemoOrderID.Lines.Add(FOrder.StockOrderID);
end;

function TPad.FormatDate(const ADate: TDateTime): string;
begin
  Datetimetostring(Result, 'ddd dd/mm/yy hh:mm', ADate);
end;

procedure TPad.OrderToFloor;
begin

  FOrder.Fetch(
    procedure(Data: TDataset)
    begin

      if (Data = nil) then
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
  if (FOrder.Status > EStatusOrder.Served) then
    Template := TPanel(InputPanelTemplate.Clone(ScrollProduce))
  else
    Template := TPanel(PanelProduceTemplate.Clone(ScrollProduce));

  ListProduce.Add(TProduce.Create(FOrder.Status, Template, AProduceRecord));
  RenderNewProduce(Template);
end;

procedure TPad.AddNewProduce;
var
  Template: TPanel;
  Produce: TProduce;
begin

  if (ScrollProduce.ComponentCount > 1) and
      (ListProduce.Last.StatusProduce = EStatusOrder.Scratch) then
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
  InputPanelTemplate.Position.Y := FContentHeight +
      InputPanelTemplate.Size.Height;

  ScrollProduce.AddObject(AProduce);
  AProduce.Visible := True;

  if FContentHeight > ScrollProduce.Size.Height then
    ScrollProduce.ScrollBy(0.0, -FContentHeight);

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

end.
