unit untLoader;

interface

uses
  {System Units}
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Contnrs,
  System.UITypes,
  {FMX Units}
  FMX.Layouts,
  FMX.Dialogs,
  FMX.Types,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Objects,
  FMX.StdCtrls,
  {Local Units}
  untStock,
  untTypes;

type
  TKitchen = class(TVertScrollBox)
  private
    FContentHeight: double;
    FProduceHeight: double;
  public
    PDimensions: untTypes.TDimensions;
    constructor Create(AOwner: TComponent; pDimens: TDimensions);
    procedure addProduce;
    { Event Handlers }
    procedure handleEditProduce(Sender: TObject);
    procedure handleCancelProduce(Sender: TObject);
    procedure handleCancelOrder;
    procedure handleNewOrder;
  end; { TKitchen end }

implementation

constructor TKitchen.Create(AOwner: TComponent; pDimens: TDimensions);
begin
  inherited Create(AOwner);
  FContentHeight := 0.0;
  FProduceHeight := 0.0;
  PDimensions := pDimens;
  Align := TAlignLayout.Client;
  Margins.Bottom := 10.0;
  Padding.Left := PDimensions.clientWidth - PDimensions.clientWidth / 1.05;
  Padding.Right := PDimensions.clientWidth - PDimensions.clientWidth / 1.05;
  Enabled := true;

end; { TKitchen.Create end }

procedure TKitchen.handleEditProduce(Sender: TObject);
var
  i: integer;
begin

  {
    for i := self.ComponentCount - 1 downto 1 do
    if TProduce(components[i]).isSelected then
    for var child in self.Children do
    begin
    showMessage(child.ClassName);
    end;
  }
end; { TKitchen.handleEditProduce end }

procedure TKitchen.handleCancelProduce(Sender: TObject);
var
  i: integer;
begin
  // downto 1 because components[0] is the actuall scrollbars
  for i := self.ComponentCount - 1 downto 1 do
    if TProduce(components[i]).isSelected then
    begin
      FContentHeight := FContentHeight - FProduceHeight;
      components[i].Free;
    end;

  TProduce(self.components[self.ComponentCount - 1]).SetFocus;
end; { TKitchen.handleCancelProduce end }

procedure TKitchen.handleCancelOrder;
begin
  for var i := self.ComponentCount - 1 downto 1 do
    self.components[i].Free;
end; { TKitchen.handleCancelOrder end }

procedure TKitchen.handleNewOrder;
begin
  addProduce;
end; { TKitchen.handleNewOrder end }

procedure TKitchen.addProduce;
var
  produce: untStock.TProduce;
begin
  produce := TProduce.Create(self);
  produce.onProduceCached := procedure
    begin
      self.addProduce;
    end;
  self.AddObject(produce);
  // Delphi does not know how to position
  // dynamically added components into a tvertscrollbox.
  // By default it will insert the objects inverted such as:
  // ... 5 4 3 2 1
  // and the 1st one will always remain at the top such as:
  // 1 4 3 2
  // 1 5 4 3 2...
  // Found a solution to the issue in this article:
  // https://stackoverflow.com/questions/62259407/
  // delphi-fmx-how-to-add-a-dynamically-created-top-aligned-component-under-all-pre
  // stock.align := top (at constructor)
  {
    produce.Position.Y := self.ComponentCount *
    (produce.Size.Height + produce.Margins.Bottom);
  }

  if FProduceHeight = 0 then
    FProduceHeight := produce.Size.Height + produce.Margins.Height;

  FContentHeight := FContentHeight + FProduceHeight;
  produce.Position.Y := FContentHeight;

  if FContentHeight > Size.Height then
    scrollBy(0.0, -FProduceHeight);

  produce.waitForProduce;
end; { TKitchen.addProduce end }

end.
