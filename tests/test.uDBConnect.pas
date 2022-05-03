unit test.uDBConnect;

{
  Test uDBConnect:
  1. throws error if the configuration file to read from is not existent
  2. throws error if user has lacking permissions to rwx the file
  3. throws error if the section of the ini file does not exist
  4. throws error if the connection has not been setup
  5. Successfully sets up a connection to a database
}
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Layouts,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, System.Rtti,
  FMX.Grid.Style, Data.Bind.EngExt, FMX.Bind.DBEngExt, FMX.Bind.Grid,
  System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope, FMX.Grid;

type
  TtestUDBconnect = class(TForm)
    Layout1: TLayout;
    btnTest1: TMemo;
    StyleBook1: TStyleBook;
    btnTest2: TMemo;
    btnTest3: TMemo;
    connection: TFDConnection;
    usersTable: TFDTable;
    Grid1: TGrid;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    btnTest4: TMemo;
    procedure btnTest1Click(Sender: TObject);
    procedure btnTest2Click(Sender: TObject);
    procedure btnTest3Click(Sender: TObject);
    procedure btnTest4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  testUDBconnect: TtestUDBconnect;

procedure test1;
procedure test2;
procedure test3;
procedure test4;

implementation

uses
  FMX.DialogService.Sync,
  uFilesystem,
  uDBConnect;

{$R *.fmx}

type
  dialog = FMX.DialogService.Sync.TDialogServiceSync;

procedure test1;
begin
  var
  input := [''];
  dialog.InputQuery('test #1', ['path to ini file'], input);
  try
    uDBConnect.setupDBconn(testUDBconnect.connection, 'DBCONN_MSSQL', input[0]);
    showMessage('successfull setup');
    testUDBconnect.usersTable.Active := true;
  except
    on E: exception do
      showMessage(E.message);
  end;
end;

procedure test2;
begin
  showMessage
    ('to enable this test the config/config.ini file must have its rwx bits modified');
  try
    uDBConnect.setupDBconn(testUDBconnect.connection, 'DBCONN_MSSQL',
      'config/config.ini');
    showMessage('successfull setup');
    testUDBconnect.usersTable.Active := true;
  except
    on E: exception do
      showMessage(E.message);
  end;
end;

procedure test3;
begin
  var
  input := [''];
  dialog.InputQuery('test #3', ['ini section'], input);
  try
    uDBConnect.setupDBconn(testUDBconnect.connection, input[0],
      'config/config.ini');
    showMessage('successfull setup');
    testUDBconnect.usersTable.Active := true;
  except
    on E: exception do
      showMessage(E.message);
  end;
end;

procedure test4;
begin
  showMessage('test #4');
end;

procedure test5;
begin
  showMessage('test #5');
end;

procedure TtestUDBconnect.btnTest1Click(Sender: TObject);
begin
  test1;
end;

procedure TtestUDBconnect.btnTest2Click(Sender: TObject);
begin
  test2;
end;

procedure TtestUDBconnect.btnTest3Click(Sender: TObject);
begin
  test3;
end;

procedure TtestUDBconnect.btnTest4Click(Sender: TObject);
begin
  test4;
end;

begin
  uFilesystem.anchorProjectRoot('delphi-utils');
end.
