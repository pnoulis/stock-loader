unit fr_kitchen;

interface

uses
 u_order,
 fr_floor,
 udmServerMSSQL,
 System.SysUtils,
 System.Types,
 System.UITypes,
 System.Classes,
 System.Variants,
 System.Generics.Collections,
 FMX.Types,
 FMX.Graphics,
 FMX.Controls,
 FMX.Forms,
 FMX.Dialogs,
 FMX.StdCtrls,
 FMX.TabControl,
 FireDAC.Comp.Client,
 FMX.Objects,
 FMX.Layouts,
 FMX.Controls.Presentation;

type

 TListOrders = TList<TOrder>;

 TKitchen = class(TFrame)
  Pass: TTabControl;
  Pin: TTabItem;

 private
  Floor: TFloor;

  ListOrders: TListOrders;

  procedure renderFloor;
 public
  constructor Create(AOwner: TComponent); override;
  destructor Destroy; override;
 end;

var
 Kitchen: TKitchen;

implementation

{$R *.fmx}
{ Tkitchen }

constructor TKitchen.Create(AOwner: TComponent);
 begin
  inherited Create(AOwner);
  renderFloor;
 end;

destructor TKitchen.Destroy;
 begin

  if Assigned(ListOrders) then
   for var Order in ListOrders do
    FreeAndNil(Order);

  FreeAndNil(ListOrders);

  inherited Destroy;
 end;

procedure TKitchen.renderFloor;
 begin
  if Assigned(Floor) then
   FreeAndNil(Floor);

  Floor := TFloor.Create(Pin);
  Pin.AddObject(Floor);
 end;

end.
