unit untProduce;

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
  FMX.Menus,
  {Local Units}
  untTypes;

type
  TProduceCached = reference to procedure;
  TCB = reference to procedure;

  TPopupMenu = class(FMX.Menus.TPopupMenu)
   private
   FEnabled: Boolean;
   public
   procedure Popup(X, Y: Single); override;
   property Enabled: Boolean read FEnabled write FEnabled;
  end;

  TProduceName = class(TEdit)
  public
    constructor Create(AOwner: TComponent); override;
    procedure handleKey(Sender: TObject; var key: Word; var keyChar: Char;
      Shift: TShiftState);
  var
    onValidatedInput: TCB;
  end; { TProduceName end }

  TProduceIncrBy = class(TEdit)
  public
    constructor Create(AOwner: TComponent); override;
    procedure handleKey(Sender: TObject; var key: Word; var keyChar: Char;
      Shift: TShiftState);
  var
    onValidatedInput: TCB;
  end; { TProduceIncrBy end }

  TDisplayError = class(TLabel)
  public
    constructor Create(AOwner: TComponent); override;
  end; { TDisplayError end }

  TProduce = class(FMX.TRectangle)
  private
    edtProduceName: TProduceName;
    edtProduceIncrBy: TProduceIncrBy;
    lblError: TDisplayError;

    // Flags
    FIsCached: Boolean;
    FIsSelected: Boolean;

    procedure askProduceName;
    procedure fetchProduce;
    procedure recordCurrentStockLevels;
    procedure askNewStockToBeAdded;
    procedure cacheUpdatedStocklevels;
    procedure enableInteractivity(Target: TEdit);
    procedure disableInteractivity(Target: TEdit);
    procedure commitUpdatedStocklevels;
    procedure displayError(const errMsg: string);

  public
    constructor Create(AOwner: TComponent); override;
    procedure waitForProduce;
    procedure setFocus(target: TControl = nil);
    procedure handleProduceSelected(Sender: TObject);

  var
    onProduceCached: TProduceCached; // cb
    property isSelected: Boolean read FIsSelected;
    property isCached: Boolean read FIsCached;

  end; { TProduce end }

implementation

procedure TPopupMenu.popup(X, Y: Single);
begin
onPopup(self);
end;

constructor TDisplayError.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StyledSettings := [];
  Position.Y := 50.0;
  align := TAlignLayout.Horizontal;
  self.TextAlign := TTextAlign.Center;
  TextSettings.Font.Family := 'Comic Sans MS';
  TextSettings.Font.Size := 20.0;
  TextSettings.FontColor := TAlphaColorRec.Crimson;
  AutoSize := true;
  Text := '-';
  Visible := false;
end; { TDisplayError.Create end }

constructor TProduceName.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StyleLookup := 'transparentedit';
  StyledSettings := [];
  TextSettings.Font.Family := 'Comic Sans MS';
  align := TAlignLayout.Client;
  Enabled := true;
  TextSettings.Font.Size := 18.0;
end; { TProduceName.Create end }

procedure TProduceName.handleKey(Sender: TObject; var key: Word;
  var keyChar: Char; Shift: TShiftState);
begin
  if not(key.toString = '13') then
    exit;
  OnKeyUp := nil;
  ReadOnly := true;
  self.Cursor := TCursor(crHandPoint);
  onValidatedInput();
  // do input validation here
  // if input valid then fetchstock
  // otherwise produre error
end; { TProduceName.handleKey end }

constructor TProduceIncrBy.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StyleLookup := 'transparentedit';
  StyledSettings := [];
  TextSettings.Font.Family := 'Comic Sans MS';
  align := TAlignLayout.Right;
  TextSettings.Font.Size := 18.0;
  TextSettings.HorzAlign := TTextAlign.Leading;
  Text := '0';
  ReadOnly := true;
end; { TProduceIncrBy.create end }

procedure TProduceIncrBy.handleKey(Sender: TObject; var key: Word;
  var keyChar: Char; Shift: TShiftState);
begin
  if not(key.toString = '13') then
    exit;
  OnKeyUp := nil;
  ReadOnly := true;
  Cursor := TCursor(crHandPoint);
  onValidatedInput();
  // do input validation here
  // if input valid then stock has been loaded
  // otherwise produre error
  // cache product should be done here
end; { TProduceName.handleKey end }

constructor TProduce.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetXRadius(10.0);
  SetYRadius(10.0);
  Size.Height := 50.0;
  Margins.Bottom := 20.0;
  Padding.Left := 30.0;
  Padding.Right := 30.0;
  align := TAlignLayout.Top;
  Enabled := true;
  Sides := [];
  Stroke.Color := TAlphaColorRec.White;
  Stroke.Thickness := 0.0;
  Cursor := TCursor(crIBeam);
  Fill.Color := TAlphaColorRec.White;
  self.PopupMenu := nil;

  // events
  self.onClick := handleProduceSelected;

  // instantiate edit #1
  edtProduceName := TProduceName.Create(self);
  edtProduceName.Text := 'haha';
  //edtProduceName.onClick := handleProduceSelected;
  edtProduceName.onValidatedInput := procedure
    begin
      fetchProduce;
    end;
  AddObject(edtProduceName);

  // instantiate edit #2
  edtProduceIncrBy := TProduceIncrBy.Create(self);
  //edtProduceIncrBy.onClick := self.handleProduceSelected;
  edtProduceIncrBy.onValidatedInput := procedure
    begin
      cacheUpdatedStocklevels;
    end;
  AddObject(edtProduceIncrBy);

  // instantiate error display label
  lblError := TDisplayError.Create(self);
  AddObject(lblError);

end; { TProduce.Create end }

procedure TProduce.handleProduceSelected(Sender: TObject);
begin
   if not FIsCached then exit;
   if Sender.Classname = 'TPopupMenu' then
   begin
    waitForProduce;
    exit;
   end;

  if FIsSelected then
  begin
    self.Fill.Color := TAlphaColorRec.White;
    FIsSelected := false;
  end
  else
  begin
    self.Fill.Color := TAlphaColorRec.Red;
    FIsSelected := true;
  end;
end; { Tstock.handleProduceSelected end }

procedure TProduce.setFocus(target: TControl = nil);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      sleep(100);
      TThread.Synchronize(nil,
        procedure
        begin
          if not assigned(target) then
            self.edtProduceName.setFocus
          else
            target.setFocus;
          // self.edtProduceName.setFocus;
          // self.edtProduceName.SelStart := Length(self.edtProduceName.GetText);
        end);
    end).Start;
end; { TProduce.setFocus end }

procedure TProduce.waitForProduce;
begin
  if FIsCached then
    askNewStockToBeAdded
  else
    askProduceName;
end; { TProduce.waitForProduce end }

procedure TProduce.askProduceName;
begin
showMessage('ask produce name');
  disableInteractivity(edtProduceName);
  edtProduceName.ReadOnly := false;
  edtProduceName.Text := '';
  edtProduceName.OnKeyUp := edtProduceName.handleKey;
  setFocus(edtProduceName);
end; { TProduce.askProduceName end }

procedure TProduce.fetchProduce;
begin
  // get database info from here
  showMessage('fetch produce');
  var
    fetched: Boolean := true;
  if fetched then
  begin
    recordCurrentStockLevels;
    askNewStockToBeAdded;
  end
  else
  begin
    displayError(edtProduceName.Text + ' does not exist!');
    waitForProduce;
  end;
end; { TProduce.fetchProduce end }

procedure TProduce.recordCurrentStockLevels;
begin
  showMessage('i should be doing something');
end; { TProduce.recordCurrentStockLevels end }

procedure TProduce.askNewStockToBeAdded;
begin
showMessage('ask new stock to be added');
  edtProduceIncrBy.ReadOnly := false;
  edtProduceIncrBy.Text := '';
  edtProduceIncrBy.OnKeyUp := edtProduceIncrBy.handleKey;
  setFocus(edtProduceIncrBy);
end; { TProduce.askProduceQuantity end }

procedure TProduce.cacheUpdatedStocklevels;
begin
  showMessage('i should be doing something');
  Cursor := TCursor(crHandPoint);
  FIsCached := true;
  onProduceCached();
  enableInteractivity(edtProduceName);
  enableInteractivity(edtProduceIncrBy);
end; { Tstock.cacheUpdatedStocklevels end }

procedure  TProduce.enableInteractivity(Target: TEdit);
var popup: TPopupMenu;
begin
  Target.onClick := handleProduceSelected;
  popup := TPopupMenu.Create(Target);
  popup.OnPopup := handleProduceSelected;
  Target.PopupMenu := popup;
end; { TProduce.enableInteractivity end }

procedure TProduce.disableInteractivity(Target: TEdit);
begin
  Target.OnClick := nil;
  target.PopupMenu.Free;
end; { TProduce.disableInteractivity end }

procedure TProduce.commitUpdatedStocklevels;
begin
  showMessage('i should be doing something');
end; { TProduce.commitProduce end }

procedure TProduce.displayError(const errMsg: string);
begin
  Sides := [TSide.Top, TSide.Bottom, TSide.Left, TSide.Right];
  Stroke.Thickness := 3.0;
  Stroke.Color := TAlphaColorRec.Crimson;
  Stroke.Thickness := 3.0;
  lblError.Text := errMsg;
  lblError.Visible := true;
  self.Margins.Bottom := self.Margins.Bottom + 20.0;
end; { TProduce.displayError end }

end.
