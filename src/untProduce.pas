unit untProduce;

interface

 uses
  {System Units}
  System.Classes,
  System.UITypes,
  System.SysUtils,
  System.Threading,
  System.Generics.Collections,
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
  untInput,
  untTRegexpSnippets,
  untTypes;

 type
  TProduceCached = reference to procedure;
  TCB = reference to procedure;
  TErrors = array of string;

  TDisplayError = class(TLabel)
   public
    constructor Create(AOwner: TComponent);override;
  end; { TDisplayError end }

  TProduce = class(FMX.TRectangle)
   private
    edtProduceName: untInput.TInputText;
    edtProduceIncrBy: untInput.TInputText;
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
    procedure displayError(const errMsg: string = '');

   public
    constructor Create(AOwner: TComponent);override;
    procedure waitForProduce;
    procedure setFocus(Target: TControl = nil);

    { event handlers }
    procedure handleProduceSelected(Sender: TObject);
    procedure handleInputSuccess(Sender: TInputText);
    procedure handleInputFailure(Sender: TInputText);

   var
    { event emitters }
    onProduceCached: TProduceCached; // cb
    { properties }
    property isSelected: Boolean read FIsSelected;
    property isCached: Boolean read FIsCached;

  end; { TProduce end }

implementation

 var
  regexpSnippets: untTRegexpSnippets.TRegexpSnippets;

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

 procedure styleProduceName(obj: untInput.TInputText);
  begin

   with obj do
    begin
     name := 'produceName';
     StyleLookup := 'transparentedit';
     StyledSettings := [];
     TextSettings.Font.Family := 'Comic Sans MS';
     align := TAlignLayout.Client;
     Enabled := true;
     TextSettings.Font.Size := 18.0;
     Text := 'haha';
     HitTest := false;
    end;
  end;

 procedure validateProduceName(Sender: TInputText);
  begin
   with Sender do
    begin
     if length(FErrors) = 0 then
      setLength(FErrors,2);

     FSnippets['!iNum'].subject := Text;
     if Text = '' then
      begin
       FErrors[0] := 'Wrong Input! Name cannot be empty';
       isValid := false;
      end
     else if FSnippets['!iNum'].match then
      begin
       FErrors[0] := 'Wrong Input! Name only accepts integers';
       isValid := false;
      end;

    end;
  end;

 procedure styleProduceIncrBy(obj: untInput.TInputText);
  begin
   with obj do
    begin
     Name := 'produceIncrBy';
     StyleLookup := 'transparentedit';
     StyledSettings := [];
     TextSettings.Font.Family := 'Comic Sans MS';
     align := TAlignLayout.Right;
     TextSettings.Font.Size := 18.0;
     TextSettings.HorzAlign := TTextAlign.Leading;
     Text := '0';
     ReadOnly := true;
     HitTest := false;
    end;
  end;

 procedure validateProduceIncrBy(Sender: TInputText);
  begin
   with Sender do
    begin
     if length(FErrors) = 0 then
      setLength(FErrors,2);

     FSnippets['!rNum'].subject := Text;
     if Text = '' then
      begin
       FErrors[0] := 'Wrong Input! Amount cannot be empty';
       isValid := false;
      end
     else if FSnippets['!rNum'].match then
      begin
       FErrors[0] := 'Wrong Input! Amount only accepts integers';
       isValid := false;
      end;

    end;
  end;

 constructor TProduce.Create(AOwner: TComponent);
  var
   popup: TPopupmenu;
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

   // instantiate edit #1
   edtProduceName := TInputText.Create(self);
   styleProduceName(edtProduceName);
//   edtProduceName.validate := validateProduceName;
   edtProduceName.onInputSuccess := handleInputSuccess;
   edtProduceName.onInputFailure := handleInputFailure;
   AddObject(edtProduceName);

   // instantiate edit #2
   edtProduceIncrBy := TInputText.Create(self);
   styleProduceIncrBy(edtProduceIncrBy);
  // edtProduceIncrBy.validate := @validateProduceIncrBy;
   edtProduceIncrBy.onInputSuccess := handleInputSuccess;
   edtProduceIncrBy.onInputFailure := handleInputFailure;
   AddObject(edtProduceIncrBy);

   // instantiate error display label
   lblError := TDisplayError.Create(self);
   AddObject(lblError);

  end; { TProduce.Create end }

 procedure TProduce.handleProduceSelected(Sender: TObject);
  begin
   if not FIsCached then
    exit;
   if Sender.Classname = 'TPopupMenu' then  // right click
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

 procedure TProduce.handleInputSuccess(Sender: TInputText);
  begin

   if Sender.name = 'produceName' then
    begin
     self.displayError;
     Sender.OnKeyUp := nil;
     fetchProduce;
    end
   else if Sender.name = 'produceIncrBy' then
    begin
     self.displayError;
     Sender.OnKeyUp := nil;
     cacheUpdatedStocklevels;
    end;

  end; { TProduce.handleInputSuccess end }

 procedure TProduce.handleInputFailure(Sender: TInputText);
  begin
   self.displayError(Sender.FErrors[0]);
  end; { TProduce.handleInputFailure end }

 procedure TProduce.setFocus(Target: TControl = nil);
  begin
   TThread.CreateAnonymousThread(
     procedure
     begin
      sleep(100);
      TThread.Synchronize(nil,
        procedure
        begin
         if not assigned(Target) then
          self.edtProduceName.setFocus
         else
          Target.setFocus;
        end);
     end).Start;
  end; { TProduce.setFocus end }

 procedure TProduce.waitForProduce;
  begin
   disableInteractivity(edtProduceName);
   disableInteractivity(edtProduceIncrBy);
   if FIsCached then
    askNewStockToBeAdded
   else
    askProduceName;
  end; { TProduce.waitForProduce end }

 procedure TProduce.askProduceName;
  begin
   showMessage('ask produce name');
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
   showMessage('record current stock levels');
  end; { TProduce.recordCurrentStockLevels end }

 procedure TProduce.askNewStockToBeAdded;
  begin
   showMessage('ask new stock to be added');
   edtProduceIncrBy.Text := '';
   edtProduceIncrBy.ReadOnly := false;
   edtProduceIncrBy.OnKeyUp := edtProduceIncrBy.handleKey;
   setFocus(edtProduceIncrBy);
  end; { TProduce.askProduceQuantity end }

 procedure TProduce.cacheUpdatedStocklevels;
  begin
   showMessage('cache updated stock levels');
   FIsCached := true;
   onProduceCached();
   enableInteractivity(edtProduceName);
   enableInteractivity(edtProduceIncrBy);
  end; { TProduce.cacheUpdatedStocklevels end }

 procedure TProduce.enableInteractivity(Target: TEdit);
  var
   popup: TPopupmenu;
  begin
   Cursor := TCursor(crHandPoint);
   Target.Cursor := TCursor(crHandPoint);
   OnClick := handleProduceSelected;
   popup := TPopupmenu.Create(self);
   popup.OnPopup := handleProduceSelected;
   PopupMenu := popup;
  end; { TProduce.enableInteractivity end }

 procedure TProduce.disableInteractivity(Target: TEdit);
  begin
   Cursor := TCursor(crIBeam);
   Target.Cursor := TCursor(crIBeam);
   onClick := nil;
   PopupMenu.Free;
  end; { TProduce.disableInteractivity end }

 procedure TProduce.commitUpdatedStocklevels;
  begin
   showMessage('commit updated stock levels');
  end; { TProduce.commitProduce end }

 procedure TProduce.displayError(const errMsg: string = '');
  begin
   if errMsg = '' then
    begin
     Sides := [];
     Stroke.Color := TAlphaColorRec.White;
     Stroke.Thickness := 0.0;
     lblError.Text := '';
     lblError.Visible := false;
     margins.Bottom := 20.0;
    end
   else
    begin
     Sides := [TSide.Top,TSide.Bottom,TSide.Left,TSide.Right];
     Stroke.Thickness := 3.0;
     Stroke.Color := TAlphaColorRec.Crimson;
     lblError.Text := errMsg;
     lblError.Visible := true;
     Margins.Bottom := 40.0;
    end;
  end; { TProduce.displayError end }

initialization

 begin
  try
   regexpSnippets := TRegexpSnippets.Create;
   regexpSnippets.compileSnippets(['!iNum','!rNum']);
  except
   on E: Exception do
    showMessage(E.message);
  end;

 end; { initialization end }

finalization

 begin
  regexpSnippets.Free;
 end;

end.
