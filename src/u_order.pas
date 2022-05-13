unit u_order;

interface

uses
 data.DB,
 untTypes,
 u_produce,
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
 TOrder = class;
 TListOrders = array of TOrder;

 TOrder = class(TObject)
 private type
  TOrderDate = record
   commited: TDateTime;
   issued: TDateTime;
  end;
 var
  FDate: TOrderDate;
  FStockOrderID: cardinal;
  FStoreID: byte;
  FStatus: EStatusOrder;
  FIsFetching: Boolean;

 public
 var
  listProduce: TListProduce;

  onOrderDblClick: procedure(order: TOrder) of object;
  constructor Create(data: TFields = nil);

  property Date: TOrderDate read FDate;
  property StockOrderID: cardinal read FStockOrderID;
  property StoreID: byte read FStoreID;
  property Status: EStatusOrder read FStatus;
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

constructor TOrder.Create(data: TFields = nil);
 begin
  inherited Create;

  FIsFetching := false;

  if assigned(data) then
   begin

    FStockOrderID := data.FieldByName('stockOrderID').Value;
    FDate.commited := data.FieldByName('moveDate').Value;

    if isToday(FDate.commited) then
     FStatus := EStatusOrder.commited
    else
     FStatus := EStatusOrder.served;

   end
  else // is a new order
   begin

    FStockOrderID := 0;
    FStatus := EStatusOrder.scratch;

   end;

 end;

end.
