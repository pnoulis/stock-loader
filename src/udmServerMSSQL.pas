unit udmServerMSSQL;

interface
uses
  U_order,
  FMX.Forms,
  UDBConnect,
  FMX.Dialogs,
  System.DateUtils,
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSSQL,
  FireDAC.VCLUI.Wait,
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
  FireDAC.DApt;

type
  TOnConnected = Reference to procedure;
  TOnConnectionError = procedure(const ErrMsg: string) of object;

  TdmServerMSSQL = class(TDataModule)
    Connection: TFDConnection;
    DriverMSSQL: TFDPhysMSSQLDriverLink;
    TableStockOrders: TFDTable;
    QueryStockMoves: TFDQuery;
    QueryItem: TFDQuery;
    DataSource1: TDataSource;
    QueryAddStockOrder: TFDQuery;
    QueryAddStockMove: TFDQuery;
    QueryDeleteStockOrder: TFDQuery;
    Query: TFDQuery;
    Sproc: TFDStoredProc;
    private type
      TAfterFetch = Reference to procedure(Data: TDataSource);
      TAfterCommitOrder = Reference to procedure(StockOrderID: string;
          ServedDate: TDateTime);
      TAfterCommitMove = Reference to procedure(StockMoveID: string;
          StockBefore, StockIncrease, StockAfter: Double);

    public
      OnConnected: TOnConnected;
      OnConnectionError: TOnConnectionError;
      CurrentOrderID: Uint32;
      procedure Connect;
      procedure FetchAsyncOrders(Cb: TAfterFetch);
      procedure FetchOrdersFilterDate(DateFrom, DateTo: TDate; Cb: TAfterFetch);
      procedure FetchProduce(const OrderID: string; Cb: TAfterFetch);
      function FetchItem(const ItemCID: string): TDataSource;
      function CountRecords(const Table: string): Cardinal;
      procedure AddStockOrder(Cb: TAfterCommitOrder);
      procedure AddStockMove(StockOrderID, ItemCID, StockIncrease,
          StockMoveID: string; Cb: TdmServerMSSQL.TAfterCommitMove);
      procedure DeleteStockOrder(StockOrderID: string);
      procedure DeleteStockMove(StockMoveID: string);
  end;

var
  DB: TdmServerMSSQL;

procedure Initialize;

implementation
{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}
const
  DBCONN_CONFIG_FILEPATH = './config/config.ini';
  DBCONN_CONFIG_INI_SECTION = 'DBCONN_MSSQL_RELEASE';
var
  Connected: Boolean;
  ErrMsg: string;
  DataSource1: TDataSource;

procedure Initialize;
begin
  if not Assigned(DB) then
    Application.CreateForm(TdmServerMSSQL, DB);
end;

procedure TdmServerMSSQL.Connect;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      if not Connected then
      begin

        try
          UDBConnect.SetupDBconn(Connection, DBCONN_CONFIG_INI_SECTION,
              DBCONN_CONFIG_FILEPATH);
          Connected := True;
        except
          on E: Exception do
            ErrMsg := E.Message;
        end;

      end;

      TThread.Synchronize(nil,
        procedure
        begin

          if Connected then
            OnConnected()
          else
            OnConnectionError(ErrMsg);

        end);

    end).Start;
end;

function TdmServerMSSQL.CountRecords(const Table: string): Cardinal;
begin
  var
  Command := TStringBuilder.Create('SELECT COUNT_BIG(*) FROM ');

  if (Table = '') then
    raise Exception.Create('CountRecords empty table arg');

  Command.Append(Table);

  Query.Open(Command.ToString);
  Result := Query.FieldList.Fields[0].Value;
  Query.Close;
end;

function TdmServerMSSQL.FetchItem(const ItemCID: string): TDataSource;
begin
  Query.Close;
  Query.Open('fetchItem ' + ItemCID.QuotedString);
  Query.Active;
  Datasource1.DataSet := Query;
  Result := DataSource1;
end;

procedure TdmServerMSSQL.FetchAsyncOrders(Cb: TAfterFetch);
begin
  var
  Table := TableStockOrders;

  try
    Table.Active := False;
    Table.Filter := '';
    Table.Filtered := False;
    Table.IndexFieldNames := 'stockOrderID:D';
    Table.Active := True;
    DataSource1.DataSet := TableStockOrders;
    Cb(DataSource1);
  except
    Cb(nil);
  end;

end;

procedure TdmServerMSSQL.FetchOrdersFilterDate(DateFrom: TDate; DateTo: TDate;
Cb: TdmServerMSSQL.TAfterFetch);
begin
  var
  Table := TableStockOrders;
  Table.Filtered := False;
  Table.Filter := '(servedDate >= {d ' + FormatDateTime('yyyy-mm-dd', DateFrom)
      + '})' + ' and (servedDate <= {d ' + FormatDateTime('yyyy-mm-dd',
      IncDay(DateTo)) + '})';
  Table.Filtered := True;
  Cb(DataSource1);
end;

procedure TdmServerMSSQL.AddStockOrder(Cb: TdmServerMSSQL.TAfterCommitOrder);
begin
  var
  Query := QueryAddStockOrder;
  Query.Open('addStockOrder 5');
  Query.Active := True;
  Cb(Query.FieldByName('stockOrderID').AsString,
      Query.FieldByName('servedDate').Value);
  Query.Close;
end;

procedure TdmServerMSSQL.AddStockMove(StockOrderID, ItemCID, StockIncrease,
    StockMoveID: string; Cb: TdmServerMSSQL.TAfterCommitMove);
begin
  var
  Query := QueryAddStockMove;
  var
  Exe := TStringBuilder.Create;
  Exe.Append('addStockMove ' + StockOrderID + ', ' + ItemCID.QuotedString + ', '
      + StockIncrease);
  if (StockMoveID <> '') then
  begin
    Exe.Append(', ' + StockMoveID);
  end;
  Query.Open(Exe.ToString);
  Cb(Query.FieldByName('stockMoveID').AsString, Query.FieldByName('stockBefore')
      .Value, Query.FieldByName('stockIncrease').Value,
      Query.FieldByName('stockAfter').Value);
  Query.Close;
end;

procedure TdmServerMSSQL.DeleteStockOrder(StockOrderID: string);
begin
  var
  Query := QueryDeleteStockOrder;
  Query.ExecSQL('deleteStockOrder ' + StockOrderID);
  Query.Close;
end;

procedure TdmServerMSSQL.DeleteStockMove(StockMoveID: string);
begin
  with Sproc do
  begin
    SchemaName := 'dbo';
    StoredProcName := 'reverseStockMove';
    Prepare;
    ParamByName('@stockMoveID').Value := StockMoveID.ToInt64;
    ExecProc;
  end;
end;

procedure TdmServerMSSQL.FetchProduce(const OrderID: string; Cb: TAfterFetch);
begin
  var
  Query := QueryStockMoves;

  try
    Query.Active := False;
    Query.Open('select * from stockMoves where stockOrderID = ' + OrderID);
    Query.Active := True;
    DataSource1.DataSet := Query;
    Cb(DataSource1);
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Cb(nil);
    end;
  end;

end;

begin
  Connected := False;

end.
