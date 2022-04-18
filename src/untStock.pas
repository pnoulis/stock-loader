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
  TProduceCached = reference to procedure;
  TCB = reference to procedure;

  TStockName = class(TEdit)
   public
    constructor Create(AOwner: TComponent);override;
     procedure handleKey(Sender: TObject;var key: Word;var keyChar: Char;
     Shift: TShiftState);

  end;

  TStockValue = class(TEdit)
   public
    constructor Create(AOwner: TComponent);override;
         procedure handleKey(Sender: TObject;var key: Word;var keyChar: Char;
     Shift: TShiftState);

  end;

  TDisplayError = class(TLabel)
   public
    constructor Create(AOwner: TComponent);override;
  end;

  TStock = class(FMX.TRectangle)
   private
    edtStockName: TStockName;
    edtStockValue: TStockValue;
    lblError: TDisplayError;
    FStockExists: Boolean;
    FInputCompleted: Boolean;
    FProduceCached: Boolean;
    FIsSelected: Boolean;

    procedure displayError(const errMsg: string);
    procedure askProduceName;
    procedure fetchProduce;
    procedure cacheCurrentProduce;
    procedure askProduceQuantity;
    procedure cacheUpdatedProduce;
    procedure commitProduce;

   public
    constructor Create(AOwner: TComponent);override;
    procedure waitForProduce;
    procedure setFocus(target: TControl = nil);

    { event handlers }
    procedure handleStockClick(Sender: TObject);
    { event emitter }
    var
    onProduceCached: TProduceCached;
    { properties }
    property isSelected: Boolean read FIsSelected;
  end;

implementation

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

 constructor TStockName.Create(AOwner: TComponent);
  begin
   inherited Create(AOwner);
   StyleLookup := 'transparentedit';
   StyledSettings := [];
   TextSettings.Font.Family := 'Comic Sans MS';
   align := TAlignLayout.Client;
   Enabled := true;
   TextSettings.Font.Size := 18.0;
  end; { TStockName.Create end }

  procedure TStockName.handleKey(Sender: TObject; var key: Word; var keyChar: Char;
  Shift: TShiftState);
  begin
  if not (key.toString = '13') then exit;
  OnKeyUp := nil;
  ReadOnly := true;
  // do input validation here
  // if input valid then fetchstock
  // otherwise produre error
  end; { TStockName.handleKey end }

 constructor TStockValue.Create(AOwner: TComponent);
  begin
   inherited Create(AOwner);
   StyleLookup := 'transparentedit';
   StyledSettings := [];
   TextSettings.Font.Family := 'Comic Sans MS';
   align := TAlignLayout.Right;
   TextSettings.Font.Size := 18.0;
   TextSettings.HorzAlign := TTextAlign.Trailing;
   //AutoSize := true;
   Text := '0';
   //Visible := false;
  end; { TStockValue.create end }


  procedure TStockValue.handleKey(Sender: TObject; var key: Word; var keyChar: Char;
  Shift: TShiftState);
  begin
  if not (key.toString = '13') then exit;
  OnKeyUp := nil;
  ReadOnly := true;
  // do input validation here
  // if input valid then stock has been loaded
  // otherwise produre error
  // cache product should be done here
  end; { TStockName.handleKey end }


 constructor TStock.Create(AOwner: TComponent);
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
   Cursor := TCursor(crHandPoint);
   Fill.Color := TAlphaColorRec.White;

   // events
   self.OnClick := self.handleStockClick;

   self.FStockExists := false;
   self.FInputCompleted := false;

   // instantiate edit
   edtStockName := TStockName.Create(self);
   edtStockName.OnClick := self.handleStockClick;
   edtStockName.Text := 'haha';
   self.AddObject(edtStockName);

   // instantiate label
   edtStockValue := TStockValue.Create(self);
   edtStockValue.OnClick := self.handleStockClick;
   self.AddObject(edtStockValue);

   // instantiate error display label
   lblError := TDisplayError.Create(self);
   self.AddObject(lblError);

  end; { TStock.Create end }

 procedure TStock.handleStockClick(Sender: TObject);
  begin
   if FInputCompleted and FIsSelected then
    begin
     self.Fill.Color := TAlphaColorRec.White;
     FIsSelected := false;
    end
   else if FInputCompleted and not FIsSelected then
    begin
     self.Fill.Color := TAlphaColorRec.Red;
     FIsSelected := true;
    end;
  end; { Tstock.handleStockClick end }

 procedure TStock.setFocus(target: TControl = nil);
  begin
   TThread.CreateAnonymousThread(
     procedure
     begin
      sleep(100);
      TThread.Synchronize(nil,
        procedure
        begin
        if not assigned(target) then self.edtStockName.setFocus
         else target.SetFocus;
//         self.edtStockName.setFocus;
//         self.edtStockName.SelStart := Length(self.edtStockName.GetText);
        end);
     end).Start;
  end; { TStock.setFocus end }

  procedure TStock.waitForProduce;
  begin
  if FProduceCached then askProduceQuantity
  else askProduceName;
  end; { TStock.waitForProduce end }

  procedure TStock.askProduceName;
  begin
  edtStockName.ReadOnly := false;
  edtSTockName.Text := '';
  edtStockName.OnKeyUp := edtStockName.handleKey;
  setFocus(edtStockName);
  end; { TStock.askProduceName end }

  procedure TStock.fetchProduce;
  begin
     // get database info from here
     var fetched: Boolean := true;
     if fetched then
     begin
      cacheCurrentProduce;
      askProduceQuantity;
     end
     else
     begin
     displayError(edtStockName.Text + ' does not exist!');
     waitForProduce;
     end;
  end; { TStock.fetchProduce end }

  procedure TStock.cacheCurrentProduce;
  begin
  showMessage('i should be doing something');
  end; { TStock.cacheCurrentProduce end }


  procedure TStock.askProduceQuantity;
  begin
  edtStockValue.ReadOnly := false;
  edtStockValue.Text := '';
  edtStockValue.OnKeyUp := edtStockValue.handleKey;
  setFocus(edtStockValue);
  end; { TStock.askProduceQuantity end }

  procedure TStock.cacheUpdatedProduce;
  begin
  showMessage('i should be doing something');
  end; { Tstock.cacheUpdatedProduce end }

  procedure TStock.commitProduce;
  begin
  showMessage('i should be doing something');
  end; { TStock.commitProduce end }

 procedure TStock.displayError(const errMsg: string);
  begin
   Sides := [TSide.Top,TSide.Bottom,TSide.Left,TSide.Right];
   Stroke.Thickness := 3.0;
   Stroke.Color := TAlphaColorRec.Crimson;
   Stroke.Thickness := 3.0;
   lblError.Text := errMsg;
   lblError.Visible := true;
   self.Margins.Bottom := self.Margins.Bottom + 20.0;
  end; { TStock.displayError end }

end.
