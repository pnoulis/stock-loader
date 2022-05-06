unit foMain;

interface

 uses
  udmEliza,
  uFilesystem,
  frKitchen,
  frPass,
  system.Threading,
  system.SysUtils, system.Types, system.UITypes, system.Classes,
  system.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

 type
  TmainForm = class(TForm)
   Layout1: TLayout;
   AniIndicator1: TAniIndicator;
   Label1: TLabel;
   procedure FormCreate(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
    pass: frPass.TPass;
    frmKichen: frKitchen.Tkitchen;
    kitchen: frKitchen.Tkitchen;
    procedure handleDBConnected;
    procedure handleDBConnectionError(const errMsg: string);
  end;

  TCB = procedure;
 var
  mainForm: TmainForm;

implementation

 {$R *.fmx}

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
         Layout1.visible := false;
         AniIndicator1.Enabled := false;
         AniIndicator1.visible := false;
         kitchen := frKitchen.Tkitchen.Create(self);
         addObject(kitchen);
        end);
     end).Start;
  end;

procedure TmainForm.handleDBConnectionError(const errMsg: string);
begin
label1.Text := 'Failed to connect to database';
AniIndicator1.enabled := false;
aniindicator1.Visible := false;
showMessage(errMsg);
end;

procedure TmainForm.FormCreate(Sender: TObject);
  begin
   if not assigned(udmEliza.dmEliza) then
    udmEliza.dmEliza := udmEliza.TdmEliza.Create(self);
    dmEliza.onConnected := self.handleDBConnected;
    dmEliza.onConnectionError := self.handleDBConnectionError;
    dmEliza.connect;
   try
   except
    on E: Exception do
     showMessage(E.message);
   end;
  end;

 begin
  uFilesystem.anchorProjectRoot('stock-loader');

end.
