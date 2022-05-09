unit f_main_form;

interface

 uses
  udmServerMSSQL,
  uFilesystem,
  fr_kitchen,
  system.Threading, system.SysUtils, system.Types,
  system.UITypes, system.Classes, system.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

 type
  TmainForm = class(TForm)
   Layout1: TLayout;
   AniIndicator1: TAniIndicator;
   Label1: TLabel;
    Button1: TButton;
    StyleBook1: TStyleBook;
    Panel1: TPanel;
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
   Label1.Text := 'Failed to connect to database';
   AniIndicator1.Enabled := false;
   AniIndicator1.visible := false;
   showMessage(errMsg);
  end;

 procedure TmainForm.renderKitchen;
  begin
   Layout1.visible := false;
   AniIndicator1.Enabled := false;
   AniIndicator1.visible := false;
   Application.CreateForm(TFrKitchen, frKitchen);
   frKitchen.Align := TAlignLayout.Client;
   addObject(frKitchen);
  end;

 procedure TmainForm.FormCreate(Sender: TObject);
  begin
   uFilesystem.anchorProjectRoot('stock-loader');
   connectDB;
  end;

end.
