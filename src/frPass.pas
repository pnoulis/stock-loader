unit frPass;

interface

uses
  uListOrders, udmEliza,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts;

type
  TPass = class(TFrame)
    Layout1: TLayout;
    Button1: TButton;
    Button2: TButton;
    Layout2: TLayout;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    body: ulistorders.TListOrders;
  public
    { Public declarations }
 //   constructor Create(AOwner: TComponent);  override;
  end;


implementation

{$R *.fmx}

procedure TPass.Button2Click(Sender: TObject);
begin
body := tlistorders.Create(self);
body.Align := TAlignLayout.Client;
addObject(body);
body.fill;
end;

procedure TPass.Button3Click(Sender: TObject);
begin
end;
{
constructor TFrame1.Create(AOwner: TComponent);
begin
inherited;
 body := tlistorders.Create(self);
addObject(body);
body.fill;
end;
}

end.
