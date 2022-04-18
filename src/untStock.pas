unit untStock;

interface

uses
  {System Units}
  System.Classes,
  System.UITypes,
  System.SysUtils,
  System.Threading,
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
  {Local Units}
  untTypes;

type
  TStockName = class(TEdit)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TStockValue = class(TLabel)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TStock = class(FMX.TRectangle)
  private
    edtStockName: TStockName;
    lblStockValue: TStockValue;
  public
    FIsSelected: Boolean;
    FStockExists: Boolean;
    constructor Create(AOwner: TComponent); override;
    procedure setFocus;
    procedure waitForInput;
    procedure fetchStock;
    procedure displayError(const errMsg: string);
    { event handlers }
    procedure handleStockClick(Sender: TObject);
    procedure handleKey(Sender: TObject; var key: Word; var keyChar: Char;
      Shift: TShiftState);
  end;

implementation

constructor TStockName.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StyleLookup := 'transparentedit';
  StyledSettings := [];
  TextSettings.Font.Family := 'Comic Sans MS';
  Align := TAlignLayout.Client;
  Enabled := true;
  TextSettings.Font.Size := 18.0;
end; { TStockName.Create end }

constructor TStockValue.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StyledSettings := [];
  TextSettings.Font.Family := 'Comic Sans MS';
  Align := TAlignLayout.Right;
  TextSettings.Font.Size := 18.0;
  TextSettings.HorzAlign := TTextAlign.Trailing;
  AutoSize := true;
  Text := '0';
  Visible := false;
end; { TStockValue.create end }

constructor TStock.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetXRadius(10.0);
  SetYRadius(10.0);
  Size.Height := 50.0;
  Margins.Bottom := 20.0;
  Padding.Left := 30.0;
  Padding.Right := 30.0;
  Align := TAlignLayout.Top;
  Enabled := true;
  Sides := [];
  Stroke.Thickness := 3.0;
  Stroke.Color := TAlphaColorRec.White;
  Cursor := TCursor(crHandPoint);
  Fill.Color := TAlphaColorRec.white;

  // events
  self.OnClick := self.handleStockClick;
  //self.FStockExists := true;

  // instantiate edit
  edtStockName := TStockName.Create(self);
  edtStockName.OnClick := self.handleStockClick;
  edtStockName.Text := 'haha';
  self.AddObject(edtStockName);

  // instantiate label
  lblStockValue := TStockValue.Create(self);
  lblStockValue.OnClick := self.handleStockClick;
  self.AddObject(lblStockValue);
end; { TStock.Create end }

procedure TStock.handleStockClick(Sender: TObject);
begin
  if FStockExists and FIsSelected then
  begin
    self.Fill.Color := TAlphaColorRec.white;
    FIsSelected := false;
  end
  else if FStockExists and not FIsSelected then
  begin
    self.Fill.Color := TAlphaColorRec.Red;
    FIsSelected := true;
  end;
end; { Tstock.handleStockClick end }

procedure TStock.setFocus;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      sleep(100);
      TThread.Synchronize(nil,
        procedure
        begin
          self.edtStockName.setFocus;
          self.edtStockName.SelStart := Length(self.edtStockName.GetText);
        end);
    end).Start;
end; { TStock.setFocus end }

procedure TStock.waitForInput;
begin
//  self.OnKeyUp := self.handleKey;
self.edtStockName.OnKeyUp := self.handleKey;
  self.setFocus;
end;

procedure TStock.handleKey(Sender: TObject; var key: Word; var keyChar: Char;
Shift: TShiftState);
begin
if not (key.ToString = '13') then exit;
if self.edtStockName.Text = '' then exit;

self.edtStockName.OnKeyUp := nil;
self.fetchStock;
end; { TStock.handleKey end }

procedure TStock.fetchStock;
begin
self.displayError('some error msg');
end; { TStock.fetchStock end }

procedure TStock.displayError(const errMsg: string);
begin
  self.Sides := [TSide.Top, TSide.Bottom, TSide.Left, TSide.right];
  Stroke.Thickness := 3.0;
  Stroke.Color := TAlphaColorRec.Indianred;
end;

end.
