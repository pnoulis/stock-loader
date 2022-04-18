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
  TStockLoaded = reference to procedure;

  TStockName = class(TEdit)
   public
    constructor Create(AOwner: TComponent);override;
  end;

  TStockValue = class(TLabel)
   public
    constructor Create(AOwner: TComponent);override;
  end;

  TDisplayError = class(TLabel)
   public
    constructor Create(AOwner: TComponent);override;
  end;

  TStock = class(FMX.TRectangle)
   private
    edtStockName: TStockName;
    lblStockValue: TStockValue;
    lblError: TDisplayError;
    procedure fetchStock;
    procedure displayError(const errMsg: string);
    procedure askAmount;
   public
    FIsSelected: Boolean;
    FStockExists: Boolean;
    FInputCompleted: Boolean;
    constructor Create(AOwner: TComponent);override;
    procedure setFocus;
    procedure waitForInput;
    { event handlers }
    procedure handleStockClick(Sender: TObject);
    procedure handleKey(Sender: TObject;var key: Word;var keyChar: Char;
     Shift: TShiftState);

    { event emitter }
   var
    onStockLoaded: TStockLoaded;

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

 constructor TStockValue.Create(AOwner: TComponent);
  begin
   inherited Create(AOwner);
   StyledSettings := [];
   TextSettings.Font.Family := 'Comic Sans MS';
   align := TAlignLayout.Right;
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
   lblStockValue := TStockValue.Create(self);
   lblStockValue.OnClick := self.handleStockClick;
   self.AddObject(lblStockValue);

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
  edtStockName.ReadOnly := false;
   edtStockName.OnKeyUp := handleKey;
   self.setFocus;
   // askStockName
   // askStockIncrBy
  end; { TStock.waitForInput end }

 procedure TStock.handleKey(Sender: TObject;var key: Word;var keyChar: Char;
 Shift: TShiftState);
  begin
   if not(key.ToString = '13') then
    exit;
   if self.edtStockName.Text = '' then
    exit;

   self.edtStockName.OnKeyUp := nil;
   self.fetchStock;
  end; { TStock.handleKey end }

 procedure TStock.fetchStock;
  begin
   var
    fetched: Boolean := true;

   if fetched then
    begin
    self.edtStockName.ReadOnly := true;
     self.askAmount;
    end
   else
    begin
     self.displayError(self.edtStockName.Text + ' does not exist!');
     self.waitForInput;
    end;

  end; { TStock.fetchStock end }

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

 procedure TStock.askAmount;
  begin
  var gotAmount: Boolean := true;
  if gotAmount then
  begin
  self.FInputCompleted := true;
  self.onStockLoaded();
  end
  else
  begin
    self.displayError('only numbers allowed in amount');
    self.waitForInput;
  end;

  end; { TStock.askAmount end }

end.
