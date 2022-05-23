unit f_main_form;

interface
uses
  UdmServerMSSQL,
  UFilesystem,
  Fr_kitchen,
  System.Threading,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
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
    LayoutHeader: TLayout;
    Spinner: TAniIndicator;
    Lbl1: TLabel;
    StyleBook1: TStyleBook;
    Rectangle1: TRectangle;
    procedure FormCreate(Sender: TObject);
    private
      procedure ConnectDB;
      procedure HandleDBConnected;
      procedure HandleDBConnectionError(const ErrMsg:string);
      procedure RenderKitchen;
  end;

var
  MainForm: TmainForm;

implementation
{$R *.fmx}

procedure TmainForm.ConnectDB;
begin
  UdmServerMSSQL.Initialize;
  UdmServerMSSQL.DB.OnConnected := HandleDBConnected;
  UdmServerMSSQL.DB.OnConnectionError := HandleDBConnectionError;
  UdmServerMSSQL.DB.Connect;
end;

procedure TmainForm.HandleDBConnected;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
{$IFDEF RELEASE}
      Sleep(3000);
{$ENDIF}
      TThread.Synchronize(nil,
        procedure
        begin
          RenderKitchen;
        end);
    end).Start;
end;

procedure TmainForm.HandleDBConnectionError(const ErrMsg:string);
begin
  Lbl1.Text := 'Failed to connect to database';
  Spinner.Enabled := False;
  Spinner.Visible := False;
  ShowMessage(ErrMsg);
end;

procedure TmainForm.RenderKitchen;
begin
  Lbl1.Visible := False;
  Spinner.Enabled := False;
  Spinner.Visible := False;

  Application.CreateForm(TKitchen, Kitchen);
  Kitchen.Align := TAlignLayout.Client;
  AddObject(Kitchen);
end;

procedure TmainForm.FormCreate(Sender: TObject);
begin
  UFilesystem.AnchorProjectRoot('stock-loader');
  ConnectDB;
end;

end.
