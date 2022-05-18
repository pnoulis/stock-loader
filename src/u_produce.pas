unit u_produce;

interface

uses
 FireDAC.Comp.Client,
 system.DateUtils,
 system.Classes,
 system.Threading,
 system.SysUtils,
 system.UITypes,
 Data.DB,
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
 FMX.Controls.Presentation,
 system.Generics.Collections,
 untInput,
 untTRegexpSnippets,
 untTypes;

type
 TProduce = class;
 TListProduce = array of TProduce;

 TProduce = class(TObject)
 private
  FmoveID: TInputText;
  FstockOrderID: TInputText;
  FitemCID: TInputText;
  FitemName: TInputText;
  FstockBefore: TInputText;
  FstockIncrease: TInputText;
  FstockAfter: TInputText;
  FError: TLabel;

  procedure setMoveID(const moveID: string);
  procedure setStockOrderID(const stockOrderID: string);
  procedure setItemCID(const itemCID: string);
  procedure setitemName(const itemName: string);
  procedure setstockBefore(const stockBefore: string);
  procedure setstockIncrease(const stockIncrease: string);

  function getMoveID: cardinal;
  function getStockOrderID: cardinal;
  function getItemCID: string;
  function getStockIncrease: integer;

  procedure setstockAfter(const stockAfter: string);
  procedure renderItemCID;
  procedure renderItemName;
  procedure renderStockAfter;
  procedure renderStockIncrease;
  procedure renderStockBefore;
  procedure renderError;
  procedure handleInputSuccess(Sender: TInputText);
  procedure handleInputFailure(Sender: TInputText);

  procedure askItemCID;
  procedure fetchProduce;
  procedure recordCurrentStockLevels(fetched: TFDQuery);
  procedure askNewStockToBeAdded;
  procedure cacheUpdatedStocklevels;
  procedure enableInteractivity(Target: TInputText);
  procedure disableInteractivity(Target: TInputText);
  procedure commitUpdatedStocklevels;
  procedure displayError(const errMsg: string = '');

 public
 var
  isSelected: Boolean;
  statusOrder: EStatusOrder;
  statusProduce: EStatusOrder;
  graphic: TPanel;
  onProduceCached: procedure of object;

  constructor Create(status: EStatusOrder; template: TPanel;
   Data: TFields = nil);
  procedure waitForProduce;
  procedure setFocus(Sender: TInputText = nil);
  procedure handleGraphicClick(Sender: TObject);

  property moveID: cardinal read getMoveID;
  property itemCID: string read getItemCID;
  property stockIncrease: integer read getStockIncrease;
 end;

implementation

uses
 udmServerMSSQL;

var
 regexpSnippets: untTRegexpSnippets.TRegexpSnippets;

 { TProduce }

procedure enableAsyncKey(Target: TInputText);
 begin
  TThread.CreateAnonymousThread(
    procedure
    begin
     sleep(2000);
     TThread.Synchronize(nil,
       procedure
       begin
        Target.OnKeyUp := Target.handleKey;
       end);
    end).Start;
 end;

procedure TProduce.waitForProduce;
 begin
  disableInteractivity(FitemName);
  disableInteractivity(FstockIncrease);

  if (statusProduce = EStatusOrder.scratch) then
   askItemCID
  else
   askNewStockToBeAdded;
 end;

procedure TProduce.askItemCID;
 begin
  enableInteractivity(FitemCID);
 end;

procedure TProduce.fetchProduce;
 begin
  var fetched: TFDQuery;

  try
   fetched := DB.fetchItem(FitemCID.Text);
  except
   on E: Exception do
    showMessage(E.message);
  end;

  if fetched.RecordCount < 1 then
   begin
    displayError(FitemCID.Text + ' does not exist!');
    waitForProduce;
   end
  else
   begin
    recordCurrentStockLevels(fetched);
    askNewStockToBeAdded;
   end;

 end;

procedure TProduce.recordCurrentStockLevels(fetched: TFDQuery);
 begin
  setitemName(fetched.FieldByName('itemName').Value);
  setstockBefore(fetched.FieldByName('itemAmount').Value);
 end;

procedure TProduce.askNewStockToBeAdded;
 begin
  enableInteractivity(FstockIncrease);
 end;

procedure TProduce.cacheUpdatedStocklevels;
 var
  popup: TPopupMenu;
 begin
  statusProduce := EStatusOrder.cached;
  onProduceCached;
  graphic.OnClick := handleGraphicClick;
  popup := TPopupMenu.Create(graphic);
  popup.OnPopup := handleGraphicClick;
  graphic.PopupMenu := popup;
 end;

procedure TProduce.commitUpdatedStocklevels;
 begin
  showMessage('commit updated stock levels');
 end;

procedure validateItemCID(Sender: TInputText);
 begin
  with Sender do
   begin
    if length(FErrors) = 0 then
     setLength(FErrors, 2);

    regexpSnippets['!iNum'].subject := Text;
    if Text = '' then
     begin
      FErrors[0] := 'Wrong Input! Name cannot be empty';
      isValid := false;
     end
    else if regexpSnippets['!iNum'].match then
     begin
      FErrors[0] := 'Wrong Input! Name only accepts integers';
      isValid := false;
     end;

   end;
 end;

procedure validateStockIncrease(Sender: TInputText);
 begin
  with Sender do
   begin
    if length(FErrors) = 0 then
     setLength(FErrors, 2);

    regexpSnippets['!rNum'].subject := Text;
    if Text = '' then
     begin
      FErrors[0] := 'Wrong Input! Ammount cannot be empty';
      isValid := false;
     end
    else if regexpSnippets['!rNum'].match then
     begin
      FErrors[0] := 'Wrong Input! Ammount only accepts integers';
      isValid := false;
     end;

   end;
 end;

procedure TProduce.handleInputSuccess(Sender: TInputText);
 begin
  disableInteractivity(Sender);
  displayError;

  if Sender.name = 'itemCID' then
   fetchProduce
  else
   cacheUpdatedStocklevels;

 end;

procedure TProduce.handleInputFailure(Sender: TInputText);
 begin
  self.displayError(Sender.FErrors[0]);
  enableAsyncKey(Sender);
 end;

procedure TProduce.handleGraphicClick(Sender: TObject);
 begin
  if statusProduce = EStatusOrder.scratch then
   exit;

  if Sender.Classname = 'TPopupMenu' then // right click
   begin
    waitForProduce;
    exit;
   end;

  with graphic.Components[0] as TRectangle do
   begin
    if isSelected then
     begin
      Fill.Color := TAlphaColorRec.White;
      isSelected := false;
     end
    else
     begin
      Fill.Color := TAlphaColorRec.Cornflowerblue;
      isSelected := true;
     end;
   end;

 end;

constructor TProduce.Create(status: EStatusOrder; template: TPanel;
Data: TFields = nil);
 begin

  statusOrder := status;
  isSelected := false;
  graphic := template;

  if assigned(Data) then
   begin

    if (statusOrder = EStatusOrder.served) then
     begin
      TEdit(template.Components[4]).Text := Data.FieldByName('itemCID').Value;
      TEdit(template.Components[2]).Text := Data.FieldByName('itemName').Value;
      TEdit(template.Components[1]).Text :=
          Data.FieldByName('stockAfter').Value;
      TEdit(template.Components[3]).Text :=
          Data.FieldByName('stockIncrease').Value;
      exit;
     end;

   end;

  if (statusOrder = EStatusOrder.commited) and assigned(Data) then
   begin
    statusProduce := EStatusOrder.commited;
    setItemCID(Data.FieldByName('itemCID').Value);
    setitemName(Data.FieldByName('itemName').Value);
    setstockAfter(Data.FieldByName('stockAfter').AsString);
    setstockIncrease(Data.FieldByName('stockIncrease').asString);
   end
  else
   begin
    statusProduce := EStatusOrder.scratch;
    setItemCID('');
    setitemName('');
    setstockAfter('');
    setstockIncrease('');
    setMoveID('');
   end;

  renderStockIncrease;
  renderStockAfter;
  renderItemCID;
  renderItemName;
  renderError;

 end;

procedure TProduce.setFocus(Sender: TInputText = nil);
 begin
  TThread.CreateAnonymousThread(
   procedure
    begin
     sleep(100);
     TThread.Synchronize(nil,
       procedure
       begin
        if (Sender <> nil) then
         Sender.setFocus
        else if (statusProduce = EStatusOrder.cached) then
         FstockIncrease.setFocus
        else
         FitemCID.setFocus;
       end);
    end).Start;
 end;

procedure TProduce.setItemCID(const itemCID: string);
 begin
  if not(assigned(FitemCID)) then
   FitemCID := TInputText.Create(graphic);

  FitemCID.Text := itemCID;
 end;

procedure TProduce.setMoveID(const moveID: string);
 begin
  if not(assigned(FmoveID)) then
   FmoveID := TInputText.Create(graphic);

  FmoveID.Text := moveID;
 end;

procedure TProduce.setStockOrderID(const stockOrderID: string);
 begin
  if not(assigned(FstockOrderID)) then
   FstockOrderID := TInputText.Create(graphic);

  FstockOrderID.Text := stockOrderID;
 end;

procedure TProduce.setstockAfter(const stockAfter: string);
 begin
  if not(assigned(FstockAfter)) then
   FstockAfter := TInputText.Create(graphic);

  FstockAfter.Text := stockAfter;
 end;

procedure TProduce.setstockBefore(const stockBefore: string);
 begin
  if not(assigned(FstockBefore)) then
   FstockBefore := TInputText.Create(graphic);

  FstockBefore.Text := stockBefore;
 end;

procedure TProduce.setstockIncrease(const stockIncrease: string);
 begin
  if not(assigned(FstockIncrease)) then
   FstockIncrease := TInputText.Create(graphic);

  FstockIncrease.Text := stockIncrease;
 end;

procedure TProduce.setitemName(const itemName: string);
 begin
  if not(assigned(FitemName)) then
   FitemName := TInputText.Create(graphic);

  FitemName.Text := itemName;
 end;

function TProduce.getMoveID: cardinal;
 begin
  if FmoveID.Text = '' then
   result := 0
  else
   result := strToInt(FmoveID.Text);
 end;

function TProduce.getStockOrderID: cardinal;
 begin
  result := strToInt(FstockOrderID.Text);
 end;

function TProduce.getItemCID: string;
 begin
  result := FitemCID.Text;
 end;

function TProduce.getStockIncrease: integer;
 begin
  result := strToInt(FstockIncrease.Text);
 end;

procedure TProduce.renderItemCID;
 begin
  with FitemCID do
   begin
    Name := 'itemCID';
    StyleLookup := 'transparentedit';
    StyledSettings := [];
    TextSettings.Font.Family := 'Comic Sans MS';
    Enabled := true;
    align := TAlignLayout.Left;
    TextSettings.Font.Size := 14.0;
    TextSettings.HorzAlign := TTextAlign.Center;
    ReadOnly := true;
    HitTest := false;
    Margins.Right := 20;
    validate := @validateItemCID;
    onInputSuccess := self.handleInputSuccess;
    onInputFailure := self.handleInputFailure;
   end;
  TRectangle(graphic.Components[0]).AddObject(FitemCID);
 end;

procedure TProduce.renderItemName;
 begin
  with FitemName do
   begin
    name := 'itemName';
    StyleLookup := 'transparentedit';
    StyledSettings := [];
    TextSettings.Font.Family := 'Comic Sans MS';
    align := TAlignLayout.Client;
    TextSettings.HorzAlign := TTextAlign.Center;
    Enabled := true;
    TextSettings.Font.Size := 14.0;
    HitTest := false;
    Margins.Right := 20.0;
   end;

  TRectangle(graphic.Components[0]).AddObject(FitemName);
 end;

procedure TProduce.renderStockAfter;
 begin
  with FstockAfter do
   begin
    Name := 'stockAfter';
    StyleLookup := 'transparentedit';
    StyledSettings := [];
    TextSettings.Font.Family := 'Comic Sans MS';
    Enabled := true;
    align := TAlignLayout.Right;
    TextSettings.Font.Size := 14.0;
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.HorzAlign := TTextAlign.Center;
    ReadOnly := true;
    HitTest := false;
    Margins.Right := 20;
   end;
  TRectangle(graphic.Components[0]).AddObject(FstockAfter);
 end;

procedure TProduce.renderStockBefore;
 begin
  with FstockBefore do
   begin
    Name := 'stockAfter';
    StyleLookup := 'transparentedit';
    StyledSettings := [];
    TextSettings.Font.Family := 'Comic Sans MS';
    Enabled := true;
    align := TAlignLayout.Right;
    TextSettings.Font.Size := 14.0;
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.HorzAlign := TTextAlign.Center;
    ReadOnly := true;
    HitTest := false;
    Margins.Right := 20;
   end;
  TRectangle(graphic.Components[0]).AddObject(FstockBefore);
 end;

procedure TProduce.renderStockIncrease;
 begin
  with FstockIncrease do
   begin
    Name := 'stockIncrease';
    StyleLookup := 'transparentedit';
    StyledSettings := [];
    TextSettings.Font.Family := 'Comic Sans MS';
    align := TAlignLayout.Right;
    Enabled := true;
    TextSettings.Font.Size := 14.0;
    TextSettings.HorzAlign := TTextAlign.Center;
    ReadOnly := true;
    HitTest := false;
    validate := @validateStockIncrease;
    onInputSuccess := self.handleInputSuccess;
    onInputFailure := self.handleInputFailure;
   end;

  TRectangle(graphic.Components[0]).AddObject(FstockIncrease);
 end;

procedure TProduce.renderError;
 begin
  FError := TLabel.Create(graphic.Components[0]);

  with FError do
   begin
    StyledSettings := [];
    Position.Y := 65.0;
    Size.Width := graphic.Size.Width;
    Margins.Left := 50.0;
    TextAlign := TTextAlign.Center;
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.Font.Size := 18.0;
    TextSettings.FontColor := TAlphaColorRec.Crimson;
    AutoSize := true;
    Text := '-';
    Visible := false;
   end;
  TRectangle(graphic.Components[0]).AddObject(FError);
 end;

procedure TProduce.displayError(const errMsg: string);
 begin
  var
  rect := TRectangle(graphic.Components[0]);

  if errMsg = '' then
   begin
    rect.Sides := [];
    rect.Stroke.Color := TAlphaColorRec.White;
    rect.Stroke.thickness := 0.0;
    FError.Text := '-';
    FError.Visible := false;
    graphic.Margins.Bottom := 20.0;
   end
  else
   begin
    rect.Sides := [TSide.Top, TSide.Bottom, TSide.Left, TSide.Right];
    rect.Stroke.thickness := 3.0;
    rect.Stroke.Color := TAlphaColorRec.Crimson;
    FError.Text := errMsg;
    FError.Visible := true;
    graphic.Margins.Bottom := 40.0;
   end;

 end;

procedure TProduce.enableInteractivity(Target: TInputText);
 begin
  Target.ReadOnly := false;
  Target.HitTest := true;
  Target.OnKeyUp := Target.handleKey;
  Target.Text := '';
  setFocus(Target);
 end;

procedure TProduce.disableInteractivity(Target: TInputText);
 begin
  graphic.OnClick := nil;
  graphic.PopupMenu.Free;
  Target.ReadOnly := true;
  Target.HitTest := false;
  Target.OnKeyUp := nil;
 end;

initialization

begin
 try
  regexpSnippets := TRegexpSnippets.Create;
  regexpSnippets.compileSnippets(['!iNum', '!rNum']);
 except
  on E: Exception do
   showMessage(E.message);
 end;
end;

finalization

begin
 regexpSnippets.Free;
end;

end.
