unit u_order;

interface

uses
 data.DB,
 u_produce,
 untTypes,
 FireDAC.Comp.Client,
 system.DateUtils,
 system.Classes,
 system.SysUtils,
 system.UITypes,
 FMX.Objects,
 FMX.Dialogs,
 FMX.Controls,
 FMX.Layouts,
 FMX.Types,
 FMX.Edit,
 FMX.StdCtrls,
 FMX.Forms,
 FMX.Graphics,
 FMX.Menus,
 FMX.Controls.Presentation,
 system.Generics.Collections;

type

 TOrder = class(TObject)
 private type
  TOrderDate = record
   commited: TDateTime;
   issued: TDateTime;
  end;

  TAfterOperation = procedure(success: Boolean) of object;

 var
  FDate: TOrderDate;
  FStockOrderID: cardinal;
  FStoreID: byte;
  FStatus: EStatusOrder;
  FProduce: TDataSource;
  FListOnAfterCommit: array of TAfterOperation;
  FListOnAfterDelete: array of TAfterOperation;

  procedure registerAfterCommit(cb: TAfterOperation);
  procedure registerAfterDelete(cb: TAfterOperation);

  function fetchProduce: TDataSource;
  procedure commitOrder;
  procedure commitProduce(ListProduce: TListProduce);
  procedure deleteOrder;
  procedure deleteProduce(ListProduce: TListProduce);
 public
 var
  constructor Create(data: TFields = nil; const storeID: byte = 0);
  procedure commit(ListProduce: TListProduce = nil);
  procedure delete(ListProduce: TListProduce = nil);

  property Date: TOrderDate read FDate;
  property StockOrderID: cardinal read FStockOrderID;
  property storeID: byte read FStoreID;
  property Status: EStatusOrder read FStatus;
  property onAfterCommit: TAfterOperation write registerAfterCommit;
  property onAfterDelete: TAfterOperation write registerAfterDelete;
  property produce: TDataSource read fetchProduce;
 end;

implementation

uses
 udmServerMSSQL;
{ TOrder }

function todayForDB: string;
 var
  Date, time: string;
 begin
  dateTimeToString(Date, 'yyyy-mm-dd', today);
  dateTimeToString(time, 'hh-mm-ss', GetTime);
  result := Date + ' ' + time;
 end;

procedure TOrder.commit(ListProduce: TListProduce = nil);
 begin

  showMessage('commit');
 end;

procedure TOrder.delete(ListProduce: TListProduce = nil);
 begin
  showMessage('delete');
 end;

procedure TOrder.commitOrder;
 begin

  {
    for var listener in FListOnAfterCommit do
    listener(true);
  }

 end;

procedure TOrder.commitProduce(ListProduce: TListProduce);
 begin
  showMessage('commit produce');
 end;

procedure TOrder.deleteOrder;
 begin
  showMessage('delete order');
 end;

procedure TOrder.deleteProduce(ListProduce: TListProduce);
 begin
  showMessage('delete produce');
 end;

procedure TOrder.registerAfterCommit(cb: TAfterOperation);
 begin
  var
  index := length(FListOnAfterCommit);

  SetLength(FListOnAfterCommit, index + 1);
  FListOnAfterCommit[index] := cb;
 end;

procedure TOrder.registerAfterDelete(cb: TAfterOperation);
 begin
  var
  index := length(FListOnAfterDelete);

  SetLength(FListOnAfterDelete, index + 1);
  FListOnAfterDelete[index] := cb;
 end;

constructor TOrder.Create(data: TFields = nil; const storeID: byte = 0);
 begin
  inherited Create;

  if assigned(data) then
   begin
    FStockOrderID := data.FieldByName('stockOrderID').Value;
    FDate.commited := data.FieldByName('moveDate').Value;
    FStoreID := data.FieldByName('storeID').Value;

    if isToday(FDate.commited) then
     FStatus := EStatusOrder.commited
    else
     FStatus := EStatusOrder.served;
   end
  else // is a new order
   begin
    FStockOrderID := 0;
    FStatus := EStatusOrder.scratch;
    FStoreID := storeID;
   end;

 end;

function TOrder.fetchProduce: TDataSource;
 begin
  showMessage('fetch produce');
 end;

end.
