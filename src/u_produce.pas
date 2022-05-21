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
  // Fields & their setters, getters and renders
  FStockMoveID: TInputText;
  FStockOrderID: TInputText;
  FItemCID: TInputText;
  FItemName: TInputText;
  FStockBefore: TInputText;
  FStockIncrease: TInputText;
  FStockAfter: TInputText;
  FError: TLabel;
  procedure setStockMoveID(const stockMoveID: string);
  procedure setStockOrderID(const stockOrderID: string);
  procedure setItemCID(const itemCID: string);
  procedure setItemName(const itemName: string);
  procedure setStockBefore(const stockBefore: string);
  procedure setStockIncrease(const stockIncrease: string);
  procedure setStockAfter(const stockAfter: string);
  function getStockMoveID: string;
  function getStockOrderID: string;
  function getItemCID: string;
  function getItemName: string;
  function getStockBefore: string;
  function getStockIncrease: string;
  function getStockAfter: string;
  procedure renderStockMoveID;
  procedure renderItemCID;
  procedure renderItemName;
  procedure renderStockBefore;
  procedure renderStockIncrease;
  procedure renderStockAfter;
  procedure renderError;

  // input validation
  procedure validateItemCID(Sender: TInputText);
  procedure validateStockIncrease(Sender: TInputText);
  procedure handleInputSuccess(Sender: TInputText);
  procedure handleInputFailure(Sender: TInputText);

  // interactivity switches
  procedure enableInteractivity(Target: TInputText);
  procedure disableInteractivity(Target: TInputText);
  procedure handleGraphicClick(Sender: TObject);

  // actions
  procedure askItemCID;
  procedure fetchItem;
  procedure recordCurrentStockLevels(Data: TFields);
  procedure askStockIncreaseAmount;
  procedure cacheUpdatedStockLevels;
  procedure commitUpdatedStockLevels;
  procedure displayError(const errMsg: string = '');

 public
  isSelected: Boolean;
  graphic: TPanel;
  statusOrder: EStatusOrder;
  statusProduce: EStatusOrder;
  onProduceCached: procedure of object;
  constructor Create(statusOrder: EStatusOrder; template: TPanel;
   Data: TFields = nil);
  procedure waitForProduce;
  procedure setFocus(Sender: TInputText = nil);

  // properties
  property stockMoveID: string read getStockMoveID write setStockMoveID;
  property stockOrderID: string read getStockOrderID write setStockOrderID;
  property itemCID: string read getItemCID write setItemCID;
  property itemName: string read getItemName write setItemName;
  property stockBefore: string read getStockBefore write setStockBefore;
  property stockIncrease: string read getStockIncrease write setStockIncrease;
  property stockAfter: string read getStockAfter write setStockAfter;
 end;

implementation

uses
 udmServerMSSQL;

var
 regexpSnippets: untTRegexpSnippets.TRegexpSnippets;

 { TProduce }
constructor TProduce.Create(statusOrder: EStatusOrder; template: TPanel;
 Data: TFields = nil);
 var
  edt: TEdit;
 begin
  inherited Create;

  statusOrder := statusOrder;
  statusProduce := statusOrder;
  isSelected := false;
  graphic := template;

  if assigned(Data) then
   begin
    TEdit(graphic.Components[6]).Text :=
        Data.FieldByName('stockMoveID').AsString;
    TEdit(graphic.Components[4]).Text := Data.FieldByName('itemCID').AsString;
    TEdit(graphic.Components[2]).Text := Data.FieldByName('itemName').AsString;
    TEdit(graphic.Components[1]).Text :=
        Data.FieldByName('stockBefore').AsString;
    TEdit(graphic.Components[3]).Text :=
        Data.FieldByName('stockIncrease').AsString;
    TEdit(graphic.Components[5]).Text := Data.FieldByName('stockAfter')
        .AsString;
   end
  else
   begin
    FStockMoveID := TInputText.Create(graphic);
    FStockOrderID := TInputText.Create(graphic);
    FItemCID := TInputText.Create(graphic);
    FItemName := TInputText.Create(graphic);
    FStockBefore := TInputText.Create(graphic);
    FStockIncrease := TInputText.Create(graphic);
    FStockAfter := TInputText.Create(graphic);
    FError := TLabel.Create(graphic);

    statusProduce := EStatusOrder.scratch;

    setStockMoveID('-');
    setStockOrderID('-');
    setItemCID('itemCID');
    setItemName('-');
    setStockBefore('-');
    setStockIncrease('0');
    setStockAfter('-');

    renderStockAfter;
    renderStockIncrease;
    renderStockBefore;
    renderItemCID;
    renderStockMoveID;
    renderItemName;
    renderError;
   end;

 end;

procedure TProduce.waitForProduce;
 begin
  disableInteractivity(FItemCID);
  disableInteractivity(FStockIncrease);

  if (statusProduce = EStatusOrder.scratch) then
   askItemCID
  else
   askStockIncreaseAmount;
 end;

procedure TProduce.setFocus(Sender: TInputText = nil);
 begin
  TThread.CreateAnonymousThread(
    procedure
    begin
     TThread.Synchronize(nil,
       procedure
       begin
        if (Sender <> nil) then
         Sender.setFocus
        else if (statusProduce = EStatusOrder.cached) then
         FStockIncrease.setFocus
        else
         FItemCID.setFocus;
       end);
    end).Start;
 end;

// Private Actions
procedure TProduce.enableInteractivity(Target: TInputText);
 begin
  Target.OnKeyUp := Target.handleKey;
  Target.Text := '';
  Target.ReadOnly := false;
  Target.HitTest := true;
  setFocus(Target);
 end;

procedure TProduce.disableInteractivity(Target: TInputText);
 begin
  Target.OnKeyUp := nil;
  graphic.PopupMenu.Free;
  graphic.OnClick := nil;
  Target.HitTest := false;
  Target.ReadOnly := true;
 end;

procedure TProduce.askItemCID;
 begin
  enableInteractivity(FItemCID);
 end;

procedure TProduce.fetchItem;
 var
  fetched: TDataSource;
 begin

  fetched := DB.fetchItem(itemCID);

  if (fetched <> nil) and (fetched.DataSet.RecordCount > 0) then
   begin
    recordCurrentStockLevels(fetched.DataSet.Fields);
    askStockIncreaseAmount;
   end
  else
   begin
    displayError(itemCID + ' does not exist');
    waitForProduce;
   end;

 end;

procedure TProduce.recordCurrentStockLevels(Data: TFields);
 begin
  setItemName(Data.FieldByName('itemName').AsString);
  setStockBefore(Data.FieldByName('Qnt').AsString);
 end;

procedure TProduce.askStockIncreaseAmount;
 begin
  enableInteractivity(FStockIncrease);
 end;

procedure TProduce.cacheUpdatedStockLevels;
 begin
  var
  popup := TPopupMenu.Create(graphic);
  setStockAfter((strToFloat(stockBefore) + StrToFloat(stockIncrease)).ToString);
  graphic.PopupMenu := popup;
  statusProduce := EStatusOrder.cached;
  graphic.OnClick := handleGraphicClick;
  popup.OnPopup := handleGraphicClick;

  onProduceCached;
 end;

procedure TProduce.commitUpdatedStockLevels;
 begin
 end;

procedure TProduce.displayError(const errMsg: string = '');
 begin
  var
  rect := TRectangle(graphic.Components[0]);

  if (errMsg = '') then
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

// Input Validation
procedure TProduce.validateItemCID(Sender: TInputText);
 begin
  disableInteractivity(Sender);
  with Sender do
   begin
    if (length(FErrors) = 0) then
     setLength(FErrors, 2);

    regexpSnippets['!iNum'].Subject := Text;
    if (Text = '') then
     begin
      FErrors[0] := 'Wrong Input! Name cannot be empty';
      isValid := false;
     end
    else if (regexpSnippets['!iNum'].Match) then
     begin
      FErrors[0] := 'Wrong Input! Name only accepts integers';
      isValid := false;
     end;
   end;
 end;

procedure TProduce.validateStockIncrease(Sender: TInputText);
 begin
  disableInteractivity(Sender);
  with Sender do
   begin
    if length(FErrors) = 0 then
     setLength(FErrors, 2);

    regexpSnippets['!rNum'].Subject := Text;
    if Text = '' then
     begin
      FErrors[0] := 'Wrong Input! Ammount cannot be empty';
      isValid := false;
     end
    else if regexpSnippets['!rNum'].Match then
     begin
      FErrors[0] := 'Wrong Input! Ammount only accepts integers';
      isValid := false;
     end;

   end;
 end;

procedure TProduce.handleInputSuccess(Sender: TInputText);
 begin
  displayError;
  if Sender.Name = 'itemCID' then
   fetchItem
  else
   cacheUpdatedStockLevels;
 end;

procedure TProduce.handleInputFailure(Sender: TInputText);
 begin
  displayError(Sender.FErrors[0]);
  enableInteractivity(Sender);
 end;

procedure TProduce.handleGraphicClick(Sender: TObject);
 begin
  if (statusProduce = EStatusOrder.scratch) then
   exit;

  if (Sender.ClassName = 'TPopupMenu') then
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

// Fields & their setters, getters & renders
procedure TProduce.setStockMoveID(const stockMoveID: string);
 begin
  FStockMoveID.Text := stockMoveID;
 end;

procedure TProduce.setStockOrderID(const stockOrderID: string);
 begin
  FStockOrderID.Text := stockOrderID;
 end;

procedure TProduce.setItemCID(const itemCID: string);
 begin
  FItemCID.Text := itemCID;
 end;

procedure TProduce.setItemName(const itemName: string);
 begin
  FItemName.Text := itemName;
 end;

procedure TProduce.setStockBefore(const stockBefore: string);
 begin
  FStockBefore.Text := stockBefore;
 end;

procedure TProduce.setStockIncrease(const stockIncrease: string);
 begin
  FStockIncrease.Text := stockIncrease;
 end;

procedure TProduce.setStockAfter(const stockAfter: string);
 begin
  FStockAfter.Text := stockAfter;
 end;

function TProduce.getStockMoveID: string;
 begin
  result := FStockMoveID.Text;
 end;

function TProduce.getStockOrderID: string;
 begin
  result := FStockOrderID.Text;
 end;

function TProduce.getItemCID: string;
 begin
  result := FItemCID.Text;
 end;

function TProduce.getItemName: string;
 begin
  result := FItemName.Text;
 end;

function TProduce.getStockBefore: string;
 begin
  result := FStockBefore.Text;
 end;

function TProduce.getStockIncrease: string;
 begin
  result := FStockIncrease.Text;
 end;

function TProduce.getStockAfter: string;
 begin
  result := FStockAfter.Text;
 end;

procedure TProduce.renderStockMoveID;
 begin
  with FStockMoveID do
   begin
    Name := 'stockMoveID';
    StyleLookup := 'transparentedit';
    StyledSettings := [];
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.Font.Size := 12.0;
    Enabled := true;
    align := TAlignLayout.Left;
    Size.Width := 75.0;
    Size.PlatformDefault := false;
    ReadOnly := true;
    HitTest := false;
    tabOrder := 1;
   end;
  TRectangle(graphic.Components[0]).AddObject(FStockMoveID);
 end;

procedure TProduce.renderItemCID;
 begin
  with FItemCID do
   begin
    Name := 'itemCID';
    StyleLookup := 'transparentedit';
    StyledSettings := [];
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.Font.Size := 12.0;
    Enabled := true;
    align := TAlignLayout.Left;
    Size.Width := 75.0;
    Size.PlatformDefault := false;
    ReadOnly := true;
    HitTest := false;
    validate := self.validateItemCID;
    onInputSuccess := self.handleInputSuccess;
    onInputFailure := self.handleInputFailure;
    tabOrder := 2;
   end;
  TRectangle(graphic.Components[0]).AddObject(FItemCID);
 end;

procedure TProduce.renderItemName;
 begin
  with FItemName do
   begin
    name := 'itemName';
    StyleLookup := 'transparentedit';
    StyledSettings := [];
    align := TAlignLayout.Client;
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.Font.Size := 13.0;
    Enabled := true;
    HitTest := false;
    ReadOnly := true;
    tabOrder := 3;
   end;
  TRectangle(graphic.Components[0]).AddObject(FItemName);
 end;

procedure TProduce.renderStockBefore;
 begin
  with FStockBefore do
   begin
    Name := 'stockBefore';
    StyleLookup := 'transparentedit';
    StyledSettings := [];
    Enabled := true;
    align := TAlignLayout.Right;
    Size.Width := 85.0;
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.Font.Size := 12.0;
    Size.PlatformDefault := false;
    ReadOnly := true;
    HitTest := false;
    tabOrder := 4;
   end;
  TRectangle(graphic.Components[0]).AddObject(FStockBefore);
 end;

procedure TProduce.renderStockIncrease;
 begin
  with FStockIncrease do
   begin
    Name := 'stockIncrease';
    StyleLookup := 'transparentedit';
    StyledSettings := [];
    align := TAlignLayout.Right;
    Enabled := true;
    Size.Width := 85.0;
    Size.PlatformDefault := false;
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.Font.Size := 12.0;
    tabOrder := 5;
    ReadOnly := true;
    HitTest := false;
    validate := validateStockIncrease;
    onInputSuccess := self.handleInputSuccess;
    onInputFailure := self.handleInputFailure;
   end;
  TRectangle(graphic.Components[0]).AddObject(FStockIncrease);
 end;

procedure TProduce.renderStockAfter;
 begin
  with FStockAfter do
   begin
    Name := 'stockAfter';
    StyleLookup := 'transparentedit';
    StyledSettings := [];
    Enabled := true;
    align := TAlignLayout.Right;
    Size.Width := 85.0;
    Size.PlatformDefault := false;
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.Font.Style := [TFontStyle.fsBold];
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.Font.Size := 12.0;
    ReadOnly := true;
    HitTest := false;
    tabOrder := 6;
   end;
  TRectangle(graphic.Components[0]).AddObject(FStockAfter);
 end;

procedure TProduce.renderError;
 begin
  with FError do
   begin
    StyledSettings := [];
    Size.Width := graphic.Size.Width;
    TextAlign := TTextAlign.Center;
    Position.Y := 45.0;
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.Font.Size := 18.0;
    TextSettings.FontColor := TAlphaColorRec.Crimson;
    AutoSize := true;
    Text := '-';
    Visible := false;
   end;
  TRectangle(graphic.Components[0]).AddObject(FError);
 end;

initialization

begin
 try
  regexpSnippets := TRegexpSnippets.Create;
  regexpSnippets.compileSnippets(['!iNum', '!rNum']);
 except
  on E: Exception do
   showMessage(E.Message);
 end;
end;

finalization

begin
 regexpSnippets.Free;
end;

end.
