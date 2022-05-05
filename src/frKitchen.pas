unit frKitchen;

interface

uses
  frPass,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.TabControl;

type
  Tkitchen = class(TFrame)
    passTab: TTabControl;
    passLog: TTabItem;
  private
    { Private declarations }
    pass: frPass.tPass;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

{ Tkitchen }

constructor Tkitchen.Create(AOwner: TComponent);
begin
  inherited;
  pass := frPass.TPass.Create(self);
  pass.Align := TAlignLayout.Client;
  passLog.AddObject(pass);
end;

end.
