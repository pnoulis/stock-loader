unit udmServerMSSQL;

interface

uses
 FMX.Forms,
 u_order,
 untTypes,
 uDBConnect,
 FMX.dialogs,
 System.Variants,
 System.DateUtils,
 System.SysUtils,
 System.Classes,
 FireDAC.Stan.Intf,
 FireDAC.Stan.Option,
 FireDAC.Stan.Error,
 FireDAC.UI.Intf,
 FireDAC.Phys.Intf,
 FireDAC.Stan.Def,
 FireDAC.Stan.Pool,
 FireDAC.Stan.Async,
 FireDAC.Phys,
 FireDAC.FMXUI.Wait,
 FireDAC.Stan.Param,
 FireDAC.DatS,
 FireDAC.DApt.Intf,
 FireDAC.DApt,
 Data.DB,
 FireDAC.Comp.DataSet,
 FireDAC.Comp.Client,
 FireDAC.Phys.MSSQLDef,
 FireDAC.Phys.ODBCBase,
 FireDAC.Phys.MSSQL,
 FireDAC.VCLUI.Wait;

type
 TOnConnected = reference to procedure;
 TOnConnectionError = procedure(const errMsg: string) of object;

 TdmServerMSSQL = class(TDataModule)
  connection: TFDConnection;
  driverMSSQL: TFDPhysMSSQLDriverLink;
  tableStockOrders: TFDTable;
  queryStockMoves: TFDQuery;
  storedGetStockMove: TFDStoredProc;
  queryItem: TFDQuery;
  storedProc: TFDStoredProc;
  DataSource1: TDataSource;
 private type
  TAfterFetch = reference to procedure(Data: TDataSource);

 public
  onConnected: TOnConnected;
  onConnectionError: TOnConnectionError;
  currentOrderID: uint32;
  procedure connect;
  function fetchOrders: TFDTable;
  procedure fetchAsyncOrders(cb: TAfterFetch);
  procedure fetchBetween(cb: TAfterFetch);
  procedure fetchOrdersFilterDate(dateFrom, dateTo: TDate; cb: TAfterFetch);
  procedure fetchProduce(const orderID: cardinal; cb: TAfterFetch);
  function fetchItem(const itemCID: string): TFDQuery;
  function addStockOrder: TFDStoredProc;
  function addStockMove(const itemCID: string; const stockOrderID: cardinal;
   const stockIncrease: integer; const storeID: cardinal;
   const moveID: cardinal = 0): TFDStoredProc;
 end;

var
 DB: TdmServerMSSQL;

procedure initialize;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

const
 DBCONN_CONFIG_FILEPATH = './config/config.ini';
 DBCONN_CONFIG_INI_SECTION =
{$IFDEF RELEASE}
     'DBCONN_MSSQL_RELEASE';
{$ELSEIF defined(BRATNET)}
    'DBCONN_MSSQL_DEBUG_BRATNET';
{$ELSE}
    'DBCONN_MSSQL_DEBUG';
{$IFEND}

var
 connected: Boolean;
 errMsg: string;
 DataSource1: TDataSource;

procedure initialize;
 begin
  if not assigned(DB) then
   Application.CreateForm(TdmServerMSSQL, DB);
 end;

procedure TdmServerMSSQL.connect;
 begin
  TThread.CreateAnonymousThread(
    procedure
    begin
     if not connected then
      begin

       try
        uDBConnect.setupDBconn(connection, DBCONN_CONFIG_INI_SECTION,
         DBCONN_CONFIG_FILEPATH);
        connected := true;
       except
        on E: Exception do
         errMsg := E.Message;
       end;

      end;

     TThread.Synchronize(nil,
       procedure
       begin

        if connected then
         onConnected()
        else
         onConnectionError(errMsg);

       end);

    end).Start;
 end;

function TdmServerMSSQL.fetchItem(const itemCID: string): TFDQuery;
 begin
  result := queryItem;
  result.active := false;
  result.Open
      ('select itemCID, itemName, itemAmount from item where itemCID = ''' +
      itemCID + '''');
 end;

function TdmServerMSSQL.fetchOrders: TFDTable;
 begin
  result := tableStockOrders;
  result.active := false;
  result.IndexFieldNames := 'moveDate:A';
  result.active := true;
 end;

procedure TdmServerMSSQL.fetchAsyncOrders(cb: TAfterFetch);
 begin
  var
  table := tableStockOrders;

  try
   table.active := false;
   table.Filter := '';
   table.Filtered := false;
   // table.IndexFieldNames := 'moveDate:D';
   table.active := true;
   DataSource1.DataSet := tableStockOrders;
   cb(DataSource1);
  except
   cb(nil);
  end;

 end;

procedure TdmServerMSSQL.fetchBetween(cb: TdmServerMSSQL.TAfterFetch);
 begin
  var
  table := tableStockOrders;
  var
  f1 := '( moveDate >= {d ' + '2022-05-12' + '} )' + ' and ( moveDate <= {d ' +
      '2022-05-28' + '} )';
  table.Filtered := false;
  table.Filter := f1;
  table.Filtered := true;
  cb(DataSource1);
 end;

procedure TdmServerMSSQL.fetchOrdersFilterDate(dateFrom: TDate; dateTo: TDate;
cb: TdmServerMSSQL.TAfterFetch);
 begin

  var
  table := tableStockOrders;
  table.Filtered := false;
  table.Filter := '(moveDate >= {d ' + formatDateTime('yyyy-mm-dd', dateFrom) +
      '})' + ' and (moveDate <= {d ' + formatDateTime('yyyy-mm-dd',
      IncDay(dateTo)) + '})';
  table.Filtered := true;
  cb(DataSource1);
 end;

function TdmServerMSSQL.addStockOrder: TFDStoredProc;
 begin
  storedProc.Close;
  storedProc.StoredProcName := 'addStockOrder';
  storedProc.SchemaName := 'dbo';
  storedProc.Prepare;
  storedProc.Params[1].value := 1;
  storedProc.Open;
  result := storedProc;
 end;

function TdmServerMSSQL.addStockMove(const itemCID: string;
const stockOrderID: cardinal; const stockIncrease: integer;
const storeID: cardinal; const moveID: cardinal = 0): TFDStoredProc;
 begin
  try
   var
   proc := storedGetStockMove;
   {
     storedGetStockMove.Close;
     storedGetStockMove.StoredProcName := 'addStockMove';
     storedGetStockMove.SchemaName := 'dbo';
     storedGetStockMove.Prepare;
     storedGetStockMove.Params[0].value := '00009';
     storedGetStockMove.Params[1].value := 21;
     storedGetStockMove.Params[2].value := 100;
     storedGetStockMove.Params[3].value := 1;
     storedGetStockMove.ExecProc;
   }

   proc.Close;
   proc.Prepare;
   proc.Params[1].value := itemCID;
   proc.Params[2].value := stockOrderID;
   proc.Params[3].value := stockIncrease;
   proc.Params[4].value := storeID;
   {
     if moveID <> 0 then
     proc.Params[5].Value := moveID;
   }
   proc.ExecProc;
   {
     proc.Close;
     proc.Prepare;
     proc.Params[1].value := '00009';
     proc.Params[2].value := 21;
     proc.Params[3].value := 100;
     proc.Params[4].value := 1;
     proc.ExecProc;
     {
     storedGetStockMove.ParamByName('itemCID').value := itemCID;
     storedGetStockMove.ParamByName('stockOrderID').value := stockOrderID;
     storedGetStockMove.ParamByName('stockIncrease').value := stockIncrease;
     storedGetStockMove.ParamByName('storeID').value := storeID;
     storedGetStockMove.Params.Delete(4);
   }
  except
   on E: Exception do
    showMessage('my exception = ' + E.Message);
  end;
  // storedGetSTockMove.ParamByName('moveID').Value := nil;

 end;

procedure TdmServerMSSQL.fetchProduce(const orderID: cardinal; cb: TAfterFetch);
 begin
  var
  query := queryStockMoves;

  try
   query.active := false;
   query.active := true;
   query.Open('select * from stockMoves where stockOrderID = ' +
       orderID.ToString);
   DataSource1.DataSet := query;
   cb(DataSource1);
  except
   cb(nil);
  end;

 end;

begin
 connected := false;

end.
