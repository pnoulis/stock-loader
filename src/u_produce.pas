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
  procedure setstockAfter(const stockAfter: string);
  procedure renderItemCID;
  procedure renderItemName;
  procedure renderStockAfter;
  procedure renderStockIncrease;
  procedure renderError;
  procedure handleInputSuccess(Sender: TInputText);
  procedure handleInputFailure(Sender: TInputText);

  procedure askItemCID;
  procedure fetchProduce;
  procedure recordCurrentStockLevels;
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
   Data: TFDQuery = nil);
  procedure waitForProduce;
  procedure setFocus(Target: TControl = nil);


 end;

implementation

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
  showMessage('wait for produce');
  disableInteractivity(FitemName);
  disableInteractivity(FstockIncrease);

  if (statusProduce = EStatusOrder.commited) then
   askNewStockToBeAdded
  else
   askItemCID;

 end;

procedure TProduce.askItemCID;
 begin
  showMessage('ask produce name');
  enableInteractivity(FitemCID);
 end;

procedure TProduce.recordCurrentStockLevels;
 begin
  showMessage('record current stock levels');
 end;

procedure TProduce.askNewStockToBeAdded;
 begin
  showMessage('ask new stock to be added');
  enableInteractivity(FstockIncrease);
 end;

procedure TProduce.cacheUpdatedStocklevels;
 begin
  showMessage('cache updated stock levels');
 statusProduce := EStatusOrder.cached;
 onProduceCached;
 end;

procedure TProduce.commitUpdatedStocklevels;
 begin
  showMessage('commit updated stock levels');
 end;

procedure validateItemCID(Sender: TInputText);
 begin
  showMessage('validating');
  with Sender do
   begin
    if length(FErrors) = 0 then
     setLength(FErrors, 2);

    regexpSnippets['!iNum'].subject := Text;
    showMessage('after snippets');
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
  showMessage('validating');
  with Sender do
   begin
    if length(FErrors) = 0 then
     setLength(FErrors, 2);

    regexpSnippets['!rNum'].subject := Text;
    showMessage('after regexp');
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

procedure TProduce.handleInputSuccess(Sender: TInputText);
 begin
  showMessage('handleInputSuccess');
  displayError; // clears errors
  disableInteractivity(Sender);

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

constructor TProduce.Create(status: EStatusOrder; template: TPanel;
Data: TFDQuery = nil);
 begin

  statusOrder := status;
  isSelected := false;
  graphic := template;

  if (statusOrder = EStatusOrder.served) then
   begin
    TEdit(template.Components[4]).Text := Data.FieldByName('itemCID').Value;
    TEdit(template.Components[2]).Text := Data.FieldByName('itemName').Value;
    TEdit(template.Components[1]).Text := Data.FieldByName('stockAfter').Value;
    TEdit(template.Components[3]).Text :=
        Data.FieldByName('stockIncrease').Value;
    exit;
   end;

  if (statusOrder = EStatusOrder.commited) then
   begin
    statusProduce := EStatusOrder.commited;
    setItemCID(Data.FieldByName('itemCID').ToString);
    setitemName(Data.FieldByName('itemName').ToString);
    setstockAfter(Data.FieldByName('stockAfter').toString);
    setstockIncrease(Data.FieldByName('stockIncrease').toString);
   end
  else
   begin
    statusProduce := EStatusOrder.scratch;
    setItemCID('');
    setitemName('');
    setstockAfter('');
    setstockIncrease('');
   end;

  renderStockIncrease;
  renderStockAfter;
  renderItemCID;
  renderItemName;
  renderError;
 end;

procedure TProduce.setFocus(Target: TControl = nil);
 begin
  TThread.CreateAnonymousThread(
   procedure
    begin
     sleep(100);
     TThread.Synchronize(nil,
       procedure
       begin
        if Target.name = 'itemCID' then
         FitemCID.setFocus
        else
         FstockIncrease.setFocus;
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
    TextSettings.Font.Size := 12.0;
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
    Text := 'haha';
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
    TextSettings.Font.Size := 12.0;
    TextSettings.HorzAlign := TTextAlign.Center;
    ReadOnly := true;
    HitTest := false;
    Margins.Right := 20;
   end;
  TRectangle(graphic.Components[0]).AddObject(FstockAfter);
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
    TextSettings.Font.Size := 12.0;
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
    Margins.Left := 40.0;
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
    FError.Text := '';
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
  showMessage('enable interactivity');
  Target.ReadOnly := false;
  Target.HitTest := true;
  Target.OnKeyUp := Target.handleKey;
  Target.Text := '';
  setFocus(Target);
 end;

procedure TProduce.disableInteractivity(Target: TInputText);
 begin
  showMessage('disable interactivity');
  Target.ReadOnly := true;
  Target.HitTest := false;
  Target.OnKeyUp := nil;
  // graphic.OnClick := nil;
 end;

procedure TProduce.fetchProduce;
 begin
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
    displayError(FitemCID.Text + ' does not exist!');
    waitForProduce;
   end;

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
