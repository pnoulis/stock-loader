unit untLoader;

interface

uses
  {System Units}
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Contnrs,
  {FMX Units}
  FMX.Layouts,
  FMX.Dialogs,
  FMX.Types,
  FMX.Edit,
  FMX.Forms,
  {Local Units}
  untStock,
  untTypes;

type

  TContainer = class(TVertScrollBox)
  public
    PDimensions: untTypes.TDimensions;
    constructor Create(AOwner: TComponent; pDimens: TDimensions);
    procedure addStock;
    { Event Handlers }
    procedure handleEditStock(Sender: TObject);
    procedure handleRemoveStock(Sender: TObject);
    procedure handleCancelLoad;
    procedure handleNewLoad;
  end; { TContainer end }

implementation

constructor TContainer.Create(AOwner: TComponent; pDimens: TDimensions);
begin
  inherited Create(AOwner);
  PDimensions := pDimens;
  Align := TAlignLayout.Client;
  Margins.Top := 50.0;
  Margins.Bottom := 10.0;
  Padding.Left := PDimensions.clientWidth - PDimensions.clientWidth / 1.05;
  Padding.Right := PDimensions.clientWidth - PDimensions.clientWidth / 1.05;
  Enabled := true;
end; { TContainer.Create end }

procedure TContainer.handleEditStock(Sender: TObject);
begin
  repaint();
end; { TContainer.handleEditStock end }

procedure TContainer.handleRemoveStock(Sender: TObject);
var
  i: integer;
begin
  // downto 1 because components[0] is the actuall scrollbars
  for i := self.ComponentCount - 1 downto 1 do
    if TStock(components[i]).FIsSelected then
      components[i].Free;

  TStock(self.components[self.ComponentCount - 1]).SetFocus;
end; { TContainer.handleRemoveStock end }

procedure TContainer.handleCancelLoad;
begin
  for var i := self.ComponentCount - 1 downto 1 do
    self.components[i].Free;
end; { TContainer.handleCancelLoad end }

procedure TContainer.handleNewLoad;
begin
  addStock;
end; { TContainer.handleNewLoad end }

procedure TContainer.addStock;
var
  stock: untStock.TStock;
begin
  stock := TStock.Create(self);
  self.AddObject(stock);
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
  stock.Position.Y := self.ComponentCount *
    (stock.Size.Height + stock.Margins.Bottom);

  stock.waitForInput;

  {
    for var i := 0 to 3 do
    begin
    stock := TStock.Create(self);
    stock.edtStockName.Text := i.toString;
    self.AddObject(stock);


    stock.Position.Y := self.ComponentCount * 70.0;
    end;
  }
end; { TContainer.addStock end }

end.
