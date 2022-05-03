unit uListOrders;

interface

 uses
  {System units}
  System.sysutils,
  System.classes,
  System.Generics.Collections,
  System.UITypes,
  {FMX Units}
  FMX.Objects,
  FMX.Dialogs,
  FMX.Controls,
  FMX.Layouts,
  FMX.Types,
  FMX.Edit,
  FMX.StdCtrls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Menus,
  {Local Units}
  udmEliza;

  type
  TListOrders = class(TVertScrollBox)
            private
    FContentHeight: double;
    FProduceHeight: double;
    public
  constructor Create(AOwner: TComponent);
  procedure fill;
  function addOrder(order: TOrder): TRectangle;
  end;

implementation

{ TListOrders }

function TListOrders.addOrder(order: TOrder): TRectangle;
var
box: TRectangle;
aLabel: TLabel;
begin
box := TRectangle.create(self);
aLabel := TLabel.create(box);
with box do
begin
cursor := TCursor(crHandPoint);
align := TAlignLayout.Top;
size.Width := 480.0;
size.Height := 50.0;
size.PlatformDefault := false;
xRadius := 10.0;
yRadius := 10.0;
Margins.bottom := 20.0;
end;

with aLabel do
begin
 Cursor := TCursor(crHandPoint);
 size.Width := 240.0;
 Align := TAlignLayout.Left;
 size.Height := 50.0;
 StyledSettings := [];
 textSettings.Font.family := 'Comic Sans MS';
 textSettings.Font.size := 18.0;
 textSettings.HorzAlign := tTextAlign.Center;
 textSettings.Font.Style := textSettings.Font.style + [TFontStyle.fsbold];
 text := order.moveID.ToString;
end;
box.AddObject(aLabel);
aLabel := TLabel(aLabel.Clone(box));

aLabel.Align := TAlignLayout.right;
alabel.text := order.moveDate;
box.addObject(aLabel);

result := box;
end;

constructor TListOrders.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
  Align := TAlignLayout.Client;
  Margins.Bottom := 10.0;
  padding.Top := 100.0;
  Padding.Left := Application.mainform.clientWidth -
    application.mainform.clientWidth / 1.05;
  Padding.Right := Application.mainform.clientWidth -
    Application.mainform.clientWidth / 1.05;
  Enabled := true;
end;

procedure TListOrders.fill;
var aOrder: TRectangle;
begin
var orders := udmEliza.dmEliza.getOrders;
var i := 1;

for var order in orders do
begin
aOrder := Self.addOrder(order);
self.AddObject(aOrder);
  if FProduceHeight = 0 then
    FProduceHeight := aOrder.Size.Height + aOrder.Margins.Height;

  FContentHeight := FContentHeight + FProduceHeight;
  aOrder.Position.Y := FContentHeight;

  if FContentHeight > Size.Height then
    scrollBy(0.0, -FProduceHeight);
end;
end;

end.
