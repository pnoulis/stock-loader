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
    FDStoredProc1: TFDStoredProc;
    queryItem: TFDQuery;
    storedProc: TFDStoredProc;
  private
  public
    onConnected: TOnConnected;
    onConnectionError: TOnConnectionError;
    currentOrderID: uint32;
    procedure connect;
    function fetchOrders: TFDTable;
    function fetchProduce(const orderStatus: EStatusOrder;
      const orderID: cardinal): TFDQuery;
    function fetchItem(const itemCID: string): TFDQuery;
    function addStockOrder: TFDStoredProc;
    function addStockMove: TFDStoredproc;
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
  result.Open('select itemCID, itemName, itemAmount from item where itemCID = ' +
    itemCID);
end;

function TdmServerMSSQL.fetchOrders: TFDTable;
begin
result := tableStockOrders;
result.active := false;
result.IndexFieldNames := 'moveDate:D';
result.active := true;
end;

function TDMServerMSSQL.addStockOrder: TFDStoredProc;
begin
storedProc.Close;
storedProc.StoredProcName := 'addStockOrder';
storedProc.SchemaName := 'dbo';
storedProc.Prepare;
storedProc.Params[1].value := 1;
storedProc.open;
result := storedProc;
end;

function TdmServerMSSQL.fetchProduce(const orderStatus: EStatusOrder;
const orderID: cardinal): TFDQuery;
begin

  result := queryStockMoves;
  result.active := false;
  result.Open('select * from stockMoves where stockOrderID = ' +
    orderID.ToString);
end;

begin
  connected := false;

end.
