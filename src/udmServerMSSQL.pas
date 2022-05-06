﻿unit udmServerMSSQL;

interface

uses
 untTypes,
 FMX.Forms,
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
 TOrder = record
  moveID: uint32;
  moveDate: string;
 end;

 TOnConnected = reference to procedure;
 TOnConnectionError = procedure(const errMsg: string) of object;

 TListOrder = array of TOrder;

 TdmServerMSSQL = class(TDataModule)
  connection: TFDConnection;
  driverMSSQL: TFDPhysMSSQLDriverLink;
  tableStockMovesLog: TFDTable;
 private
 public
  onConnected: TOnConnected;
  onConnectionError: TOnConnectionError;
  currentOrderID: uint32;
  procedure connect;
  function getOrders: TListOrder;
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
    'DBCONN_MSSQL_RELEASE';
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

function TdmServerMSSQL.getOrders: TListOrder;
 begin
  var
   today: string;
  var
   orders: TListOrder;
  var
   i: uint32 := 0;

  tableStockMovesLog.IndexFieldNames := 'moveDate:D';
  tableStockMovesLog.Active := true;
  setLength(orders, tableStockMovesLog.RecordCount);
  // dateTimeToString(today, 'yyyy-mm-dd', system.sysutils.date);
  // var formatedToday: string;
  // dateTimeToString(formatedToday, 'dddddd', system.sysutils.date);
  // showMessage(today + ' ');
  // showMessage(tableStockMovesLog.RecordCount.toString);

  for var field in tableStockMovesLog.fields do
   begin
    showMessage(field.FullName);
    // showMessage(field.AsString);
    showMessage(field.Value);
   end;

  while not tableStockMovesLog.eof do
   begin
    orders[i].moveID := tableStockMovesLog.FieldByName('moveID').Value;
    orders[i].moveDate := tableStockMovesLog.FieldByName('moveDate').Value;
    tableStockMovesLog.Next;
    Inc(i);
   end;
  self.currentOrderID := length(orders);
  tableStockMovesLog.Close;
  result := orders;
 end;

begin
 connected := false;

end.
