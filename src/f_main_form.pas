unit f_main_form;

interface

uses
 udmServerMSSQL,
 uFilesystem,
 fr_kitchen,
 system.Threading,
 system.SysUtils,
 system.Types,
 system.UITypes,
 system.Classes,
 system.Variants,
 FMX.Types,
 FMX.Controls,
 FMX.Forms,
 FMX.Graphics,
 FMX.Dialogs,
 FMX.Controls.Presentation,
 FMX.StdCtrls,
 FMX.Layouts,
 FMX.Memo.Types,
 FMX.ScrollBox,
 FMX.Memo,
 FMX.TabControl,
 FMX.Objects,
 FMX.DateTimeCtrls;

type
 TmainForm = class(TForm)
  layoutHeader: TLayout;
  Spinner: TAniIndicator;
  lbl1: TLabel;
  StyleBook1: TStyleBook;
  Rectangle1: TRectangle;
  procedure FormCreate(Sender: TObject);
 private
  procedure connectDB;
  procedure handleDBConnected;
  procedure handleDBConnectionError(const errMsg: string);
  procedure renderKitchen;
 end;

var
 mainForm: TmainForm;

implementation

{$R *.fmx}

procedure TmainForm.connectDB;
 begin
  udmServerMSSQL.initialize;
  udmServerMSSQL.DB.onConnected := handleDBConnected;
  udmServerMSSQL.DB.onConnectionError := handleDBConnectionError;
  udmServerMSSQL.DB.connect;
 end;

procedure TmainForm.handleDBConnected;
 begin
  TThread.CreateAnonymousThread(
    procedure
    begin
{$IFDEF RELEASE}
     sleep(3000);
{$ENDIF}
     TThread.Synchronize(nil,
       procedure
       begin
        renderKitchen;
       end);
    end).Start;
 end;

procedure TmainForm.handleDBConnectionError(const errMsg: string);
 begin
  lbl1.Text := 'Failed to connect to database';
  Spinner.Enabled := false;
  Spinner.visible := false;
  showMessage(errMsg);
 end;

procedure TmainForm.renderKitchen;
 begin
  lbl1.visible := false;
  Spinner.Enabled := false;
  Spinner.visible := false;

  Application.CreateForm(TKitchen, Kitchen);
  Kitchen.Align := TAlignLayout.Client;
  addObject(Kitchen);
 end;

procedure TmainForm.FormCreate(Sender: TObject);
 begin
  uFilesystem.anchorProjectRoot('stock-loader');
  connectDB;
 end;

end.
