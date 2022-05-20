﻿unit udmServerMSSQL;

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
    queryItem: TFDQuery;
    DataSource1: TDataSource;
    queryAddStockOrder: TFDQuery;
    queryAddStockMove: TFDQuery;
    queryDeleteStockOrder: TFDQuery;
  private type
    TAfterFetch = reference to procedure(Data: TDataSource);
    TAfterCommitOrder = reference to procedure(stockOrderID: string;
      servedDate: TDateTime);
    TAfterCommitMove = reference to procedure(stockMoveID, stockBefore,
      stockIncrease, stockAfter: string);

  public
    onConnected: TOnConnected;
    onConnectionError: TOnConnectionError;
    currentOrderID: uint32;
    procedure connect;
    procedure fetchAsyncOrders(cb: TAfterFetch);
    procedure fetchOrdersFilterDate(dateFrom, dateTo: TDate; cb: TAfterFetch);
    procedure fetchProduce(const orderID: string; cb: TAfterFetch);
    function fetchItem(const itemCID: string): TDataSource;
    procedure addStockOrder(cb: TAfterCommitOrder);
    procedure addStockMove(stockOrderID, itemCID, stockIncrease,
      stockMoveID: string; cb: TdmServerMSSQL.TAfterCommitMove);
      procedure deleteStockOrder(stockOrderID: string);
  end;

var
  DB: TdmServerMSSQL;

procedure initialize;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

const
  DBCONN_CONFIG_FILEPATH = './config/config.ini';
  DBCONN_CONFIG_INI_SECTION = 'DBCONN_TEMP';
  // {$IFDEF RELEASE}
  // 'DBCONN_MSSQL_RELEASE';
  // {$ELSEIF defined(BRATNET)}
  // 'DBCONN_MSSQL_DEBUG_BRATNET';
  // {$ELSE}
  // 'DBCONN_MSSQL_DEBUG';
  // {$IFEND}

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

function TdmServerMSSQL.fetchItem(const itemCID: string): TDataSource;
begin
  var
  query := queryItem;
  try
    query.Active := false;
    query.Open
      ('select a.itemCID, a.itemName, b.qnt from item a, itemStg b where ' +
      'a.itemCID = b.itemCID and a.itemCID = ''' + itemCID + '''');
    query.Active := true;
    DataSource1.DataSet := query;
    result := DataSource1;
  except
    on E: Exception do
    begin
      showMessage(E.Message);
      result := nil;
    end;

  end;
end;

procedure TdmServerMSSQL.fetchAsyncOrders(cb: TAfterFetch);
begin
  var
  table := tableStockOrders;

  try
    table.Active := false;
    table.Filter := '';
    table.Filtered := false;
    table.IndexFieldNames := 'servedDate:D';
    table.Active := true;
    DataSource1.DataSet := tableStockOrders;
    cb(DataSource1);
  except
    cb(nil);
  end;

end;

procedure TdmServerMSSQL.fetchOrdersFilterDate(dateFrom: TDate; dateTo: TDate;
cb: TdmServerMSSQL.TAfterFetch);
begin
  var
  table := tableStockOrders;
  table.Filtered := false;
  table.Filter := '(servedDate >= {d ' + formatDateTime('yyyy-mm-dd', dateFrom) +
    '})' + ' and (servedDate <= {d ' + formatDateTime('yyyy-mm-dd',
    IncDay(dateTo)) + '})';
  table.Filtered := true;
  cb(DataSource1);
end;

procedure TdmServerMSSQL.addStockOrder(cb: TdmServerMSSQL.TAfterCommitOrder);
begin
  var
  query := queryAddStockOrder;
  query.Open('addStockOrder 1');
  query.Active := true;
  cb(query.FieldByName('stockOrderID').AsString,
    query.FieldByName('servedDate').Value);
  query.Close;
end;

procedure TdmServerMSSQL.addStockMove(stockOrderID, itemCID, stockIncrease,
  stockMoveID: string; cb: TdmServerMSSQL.TAfterCommitMove);
begin
  var
  query := queryAddStockMove;
  var
  exe := TStringBuilder.Create;
  exe.Append('addStockMove ' + stockOrderID + ', ' + itemCID.QuotedString + ', '
    + stockIncrease);
  if (stockMoveID <> '') then
  begin
    exe.Append(', ' + stockMoveID);
  end;
  query.Open(exe.ToString);
  query.Active := true;
  cb(query.FieldByName('stockMoveID').AsString, query.FieldByName('stockBefore')
    .AsString, query.FieldByName('stockIncrease').AsString,
    query.FieldByName('stockAfter').AsString);
  query.Close;
end;

procedure TdmServerMSSQL.deleteStockOrder(stockOrderID: string);
begin
  var
  query := queryDeleteStockOrder;
  query.ExecSQL('deleteStockOrder ' + stockOrderID);
  query.Close;
end;

procedure TdmServerMSSQL.fetchProduce(const orderID: string; cb: TAfterFetch);
begin
  var
  query := queryStockMoves;

  try
    query.Active := false;
    query.Open('select * from stockMoves where stockOrderID = ' + orderID);
    query.Active := true;
    DataSource1.DataSet := query;
    cb(DataSource1);
  except
    on E: Exception do
    begin
      showMessage(E.Message);
      cb(nil);
    end;
  end;

end;

begin
  connected := false;

end.
