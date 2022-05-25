unit u_order;

interface
uses
  Data.DB,
  U_produce,
  UntTypes,
  FMX.Dialogs,
  System.DateUtils,
  System.SysUtils,
  System.Generics.Collections;

type

  EOrder = class(Exception)
    ErrorCode: word;
    name: string;
  end;

  EOrderDeleteNotLast = class(EOrder)
    public const
      message = 'Trying do delete not last stockOrderID : %d';
      ErrorCode = 1;
      name = 'EOrderDeleteNotLast';
      constructor Create(const StockOrderID: Cardinal);
  end;

  TOrder = class(TObject)
    private type
      TOrderDate = record
        Commited: TDateTime;
        Issued: TDateTime;
      end;

      TAfterOperation = procedure(Success: Boolean) of object;
      TAfterFetch = Reference to procedure(Data: TDataset);

    var
      FDate: TOrderDate;
      FStockOrderID: string;
      FStoreID: Byte;
      FStatus: EStatusOrder;
      FProduce: TDataSource;

      procedure CommitOrder;
      procedure CommitProduce(ListProduce: TListProduce);
    public
    var
      constructor Create(Data: TFields = nil; const StoreID: Byte = 0);
      procedure Commit(ListProduce: TListProduce = nil);
      procedure Delete(ListProduce: TListProduce = nil);
      function Clone: TOrder;
      procedure Fetch(Cb: TAfterFetch);

      property Date: TOrderDate read FDate;
      property StockOrderID: string read FStockOrderID;
      property StoreID: Byte read FStoreID;
      property Status: EStatusOrder read FStatus;
  end;

implementation
uses
  UdmServerMSSQL;
{ TOrder }

constructor EOrderDeleteNotLast.Create(const StockOrderID: Cardinal);
begin
  inherited CreateFmt(message, [StockOrderID]);
  with self as EOrder do
  begin
    ErrorCode := self.ErrorCode;
    name := self.name;
  end;
end;

procedure TOrder.Commit(ListProduce: TListProduce = nil);
begin

  if Status <> EStatusOrder.Commited then
    CommitOrder;

  CommitProduce(ListProduce);
end;

procedure TOrder.Delete(ListProduce: TListProduce = nil);
var
  Res: Cardinal;
begin
  if (StockOrderID.ToInt64 < DB.CountRecords('stockOrders')) then
    raise EOrderDeleteNotLast.Create(StockOrderID.ToInt64);
  // DB.DeleteStockOrder(StockOrderID);
end;

function TOrder.Clone: TOrder;
begin
  Result := TOrder.Create(nil, FStoreID);
  Result.FDate := Self.Date;
  Result.FStockOrderID := Self.FStockOrderID;
  Result.FStatus := Self.FStatus;
end;

procedure TOrder.Fetch(Cb: TAfterFetch);
begin

  if FStockOrderID = '0' then
    Cb(nil);

  DB.FetchProduce(FStockOrderID,
    procedure(Data: TDataSource)
    begin
      if (Data <> nil) then
        Cb(Data.DataSet)
      else
        Cb(nil);
    end);

end;

procedure TOrder.CommitOrder;
begin
  DB.AddStockOrder(
    procedure(StockOrderID: string; ServedDate: TDateTime)
    begin
      FStockOrderID := StockOrderID;
      FDate.Commited := ServedDate;
      FStatus := EStatusOrder.Commited;
    end);
end;

procedure TOrder.CommitProduce(ListProduce: TListProduce);
begin
  for var Produce in ListProduce do
    if (Produce.StatusProduce <> EStatusOrder.Commited) then
    begin
      DB.AddStockMove(FStockOrderID, Produce.ItemCID,
          FloatToStr(Produce.StockIncrease, GLocaleFormat), '',
        procedure(StockMoveID: string; StockBefore, StockIncrease,
            StockAfter: Double)
        begin
          Produce.StatusProduce := EStatusOrder.Commited;
          Produce.StockMoveID := StockMoveID;
          Produce.StockBefore := StockBefore;
          Produce.StockIncrease := StockIncrease;
          Produce.StockAfter := StockAfter;
        end)
    end;
end;

constructor TOrder.Create(Data: TFields = nil; const StoreID: Byte = 0);
begin
  inherited Create;

  if Assigned(Data) then
  begin
    FStockOrderID := Data.FieldByName('stockOrderID').AsString;
    FDate.Commited := Data.FieldByName('servedDate').Value;
    FStoreID := Data.FieldByName('storeID').Value;

    if IsToday(FDate.Commited) then
      FStatus := EStatusOrder.Commited
    else
      FStatus := EStatusOrder.Served;
  end
  else // is a new order
  begin
    FStockOrderID := '0';
    FStatus := EStatusOrder.Scratch;
    FStoreID := StoreID;
  end;

end;
end.
