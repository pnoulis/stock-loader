unit udmEliza;

interface

uses
  uDBConnect, fmx.dialogs, System.Variants, System.DateUtils,
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL;

type
  TOrder = record
   moveID: uint32;
   moveDate: string;
  end;

  TListOrder = array of TOrder;

  TdmEliza = class(TDataModule)
    connection: TFDConnection;
    driverMSSQL: TFDPhysMSSQLDriverLink;
    tableStockMovesLog: TFDTable;
  private
    { Private declarations }
  public
    { Public declarations }
    currentOrderID: uint32;
    procedure connect;
    function getOrders: TListOrder;
  end;

var
  dmEliza: TdmEliza;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TdmEliza.connect;
begin
 if connection.Connected then exit;
 try
 uDBConnect.setupDBconn(connection, 'DBCONN_MSSQL', '.\config\config.ini');
// tableStockMovesLog.IndexFieldNames := 'moveDate:D';
// tableStockMovesLog.Active := true;
 showMessage('database connected');
 except
 raise;
 end;
end;

function TdmEliza.getOrders: TListOrder;
begin
var today: string;
var orders: tListOrder;
var i: uint32 := 0;

tableStockMovesLog.IndexFieldNames := 'moveDate:D';
tableStockMovesLog.Active := true;
setLength(orders, tableStockMovesLog.RecordCount);
//dateTimeToString(today, 'yyyy-mm-dd', system.sysutils.date);
//var formatedToday: string;
//dateTimeToString(formatedToday, 'dddddd', system.sysutils.date);
//showMessage(today + ' ');
//showMessage(tableStockMovesLog.RecordCount.toString);

while not tableStockMovesLog.eof do
begin
orders[i].moveID := tableStockMoveslog.FieldByName('moveID').Value;
orders[i].moveDate := tableStockMovesLog.FieldByName('moveDate').Value;
tableStockMovesLog.Next;
Inc(i);
end;
self.currentOrderID := length(orders);
tableStockMovesLog.Close;
result := orders;
end;

end.
