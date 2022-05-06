unit fr_kitchen;

interface

uses
 u_kitchen,
 System.SysUtils,
 System.Types,
 System.UITypes,
 System.Classes,
 System.Variants,
 FMX.Types,
 FMX.Graphics,
 FMX.Controls,
 FMX.Forms,
 FMX.Dialogs,
 FMX.StdCtrls,
 FMX.TabControl;

type
 TfrKitchen = class(TFrame)
 private
  Kitchen: TKitchen;
 public
  constructor Create(AOwner: TComponent); override;
 end;

var frKitchen: TfrKitchen;

implementation

{$R *.fmx}
{ Tkitchen }

constructor TfrKitchen.Create(AOwner: TComponent);
 begin
  inherited;
  Kitchen := TKitchen.Create(self);
  addObject(Kitchen);
 end;

end.
