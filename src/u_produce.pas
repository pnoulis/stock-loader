unit u_produce;

interface
uses
  FireDAC.Comp.Client,
  System.DateUtils,
  System.Classes,
  System.Threading,
  System.SysUtils,
  System.UITypes,
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
  System.Generics.Collections,
  UntInput,
  UntTRegexpSnippets,
  UntTypes;

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
      procedure SetStockMoveID(const StockMoveID:string);
      procedure SetStockOrderID(const StockOrderID:string);
      procedure SetItemCID(const ItemCID:string);
      procedure SetItemName(const ItemName:string);
      procedure SetStockBefore(const StockBefore:string);
      procedure SetStockIncrease(const StockIncrease:string);
      procedure SetStockAfter(const StockAfter:string);
      function GetStockMoveID:string;
      function GetStockOrderID:string;
      function GetItemCID:string;
      function GetItemName:string;
      function GetStockBefore:string;
      function GetStockIncrease:string;
      function GetStockAfter:string;
      procedure RenderStockMoveID;
      procedure RenderItemCID;
      procedure RenderItemName;
      procedure RenderStockBefore;
      procedure RenderStockIncrease;
      procedure RenderStockAfter;
      procedure RenderError;

      // input validation
      procedure ValidateItemCID(Sender: TInputText);
      procedure ValidateStockIncrease(Sender: TInputText);
      procedure HandleInputSuccess(Sender: TInputText);
      procedure HandleInputFailure(Sender: TInputText);

      // interactivity switches
      procedure EnableInteractivity(Target: TInputText);
      procedure DisableInteractivity(Target: TInputText);
      procedure HandleGraphicClick(Sender: TObject);

      // actions
      procedure AskItemCID;
      procedure FetchItem;
      procedure RecordCurrentStockLevels(Data: TFields);
      procedure AskStockIncreaseAmount;
      procedure CacheUpdatedStockLevels;
      procedure CommitUpdatedStockLevels;
      procedure DisplayError(const ErrMsg:string = '');

    public
      IsSelected: Boolean;
      IsEdited: Boolean;
      Graphic: TPanel;
      StatusOrder: EStatusOrder;
      StatusProduce: EStatusOrder;
      OnProduceCached: procedure of object;
      constructor Create(StatusOrder: EStatusOrder; Template: TPanel;
          Data: TFields = nil);
      destructor Destroy; override;
      procedure WaitForProduce;
      procedure SetFocus(Sender: TInputText = nil);

      // properties
      property StockMoveID:string read GetStockMoveID write SetStockMoveID;
      property StockOrderID:string read GetStockOrderID write SetStockOrderID;
      property ItemCID:string read GetItemCID write SetItemCID;
      property ItemName:string read GetItemName write SetItemName;
      property StockBefore:string read GetStockBefore write SetStockBefore;
      property StockIncrease:string read GetStockIncrease
          write SetStockIncrease;
      property StockAfter:string read GetStockAfter write SetStockAfter;
  end;

implementation
uses
  UdmServerMSSQL;

var
  RegexpSnippets: UntTRegexpSnippets.TRegexpSnippets;

  { TProduce }
constructor TProduce.Create(StatusOrder: EStatusOrder; Template: TPanel;
    Data: TFields = nil);
var
  Edt: TEdit;
begin
  inherited Create;

  StatusOrder := StatusOrder;
  StatusProduce := StatusOrder;
  IsSelected := False;
  IsEdited := False;
  Graphic := Template;

  if Assigned(Data)then
  begin
    TEdit(Graphic.Components[6]).Text :=
        Data.FieldByName('stockMoveID').AsString;
    TEdit(Graphic.Components[4]).Text := Data.FieldByName('itemCID').AsString;
    TEdit(Graphic.Components[2]).Text := Data.FieldByName('itemName').AsString;
    TEdit(Graphic.Components[1]).Text :=
        Data.FieldByName('stockBefore').AsString;
    TEdit(Graphic.Components[3]).Text :=
        Data.FieldByName('stockIncrease').AsString;
    TEdit(Graphic.Components[5]).Text := Data.FieldByName('stockAfter')
        .AsString;
  end
  else
  begin
    FStockMoveID := TInputText.Create(Graphic);
    FStockOrderID := TInputText.Create(Graphic);
    FItemCID := TInputText.Create(Graphic);
    FItemName := TInputText.Create(Graphic);
    FStockBefore := TInputText.Create(Graphic);
    FStockIncrease := TInputText.Create(Graphic);
    FStockAfter := TInputText.Create(Graphic);
    FError := TLabel.Create(Graphic);

    StatusProduce := EStatusOrder.Scratch;

    SetStockMoveID('-');
    SetStockOrderID('-');
    SetItemCID('itemCID');
    SetItemName('-');
    SetStockBefore('-');
    SetStockIncrease('0');
    SetStockAfter('-');

    RenderStockAfter;
    RenderStockIncrease;
    RenderStockBefore;
    RenderItemCID;
    RenderStockMoveID;
    RenderItemName;
    RenderError;
  end;

end;

destructor TProduce.Destroy;
begin
  if Assigned(Graphic)then
    FreeAndNil(Graphic);
  inherited Destroy;
end;

procedure TProduce.WaitForProduce;
begin
  DisableInteractivity(FItemCID);
  DisableInteractivity(FStockIncrease);

  if(StatusProduce = EStatusOrder.Scratch)then
    AskItemCID
  else
    AskStockIncreaseAmount;
end;

procedure TProduce.SetFocus(Sender: TInputText = nil);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          if(Sender <> nil)then
            Sender.SetFocus
          else if(StatusProduce = EStatusOrder.Cached)or
              (StatusProduce = EStatusOrder.Commited)then
            FStockIncrease.SetFocus
          else
            FItemCID.SetFocus;
        end);
    end).Start;
end;

// Private Actions
procedure TProduce.EnableInteractivity(Target: TInputText);
begin
  Target.OnKeyUp := Target.HandleKey;
  Target.Text := '';
  Target.ReadOnly := False;
  Target.HitTest := True;
  SetFocus(Target);
end;

procedure TProduce.DisableInteractivity(Target: TInputText);
begin
  Target.OnKeyUp := nil;
  Graphic.PopupMenu.Free;
  Graphic.OnClick := nil;
  Target.HitTest := False;
  Target.ReadOnly := True;
end;

procedure TProduce.AskItemCID;
begin
  EnableInteractivity(FItemCID);
end;

procedure TProduce.FetchItem;
var
  Fetched: TDataSource;
begin

  Fetched := DB.FetchItem(ItemCID);

  if(Fetched <> nil)and(Fetched.DataSet.RecordCount > 0)then
  begin
    RecordCurrentStockLevels(Fetched.DataSet.Fields);
    AskStockIncreaseAmount;
  end
  else
  begin
    DisplayError('Το ειδος ' + ItemCID + ' δεν βρεθηκε');
    // displayError(itemCID + ' does not exist');
    WaitForProduce;
  end;

end;

procedure TProduce.RecordCurrentStockLevels(Data: TFields);
begin
  SetItemName(Data.FieldByName('itemName').AsString);
  SetStockBefore(Data.FieldByName('Qnt').AsString);
  if StockBefore = '' then
    StockBefore := '0';

end;

procedure TProduce.AskStockIncreaseAmount;
begin
  EnableInteractivity(FStockIncrease);
end;

procedure TProduce.CacheUpdatedStockLevels;
begin
  // var
  // popup := TPopupMenu.Create(graphic);
  StatusProduce := EStatusOrder.Cached;
  // graphic.PopupMenu := popup;
  Graphic.OnClick := HandleGraphicClick;
  // popup.OnPopup := handleGraphicClick;
  {
    if (statusProduce = EStatusOrder.commited) then
    begin
    showMessage('it has been commited');
    isEdited := true;
    end
    else
    begin
    statusProduce := EStatusOrder.cached;
    end;
  }

  // if isEdited then
  // setStockAfter((strToFloat(stockIncrease) + strToFloat(stockAfter)).ToString)
  // else
  SetStockAfter((StrToFloat(StockBefore)+ StrToFloat(StockIncrease)).ToString);

  OnProduceCached;
end;

procedure TProduce.CommitUpdatedStockLevels;
begin
end;

procedure TProduce.DisplayError(const ErrMsg:string = '');
begin
  var
  Rect := TRectangle(Graphic.Components[0]);

  if(ErrMsg = '')then
  begin
    Rect.Sides :=[];
    Rect.Stroke.Color := TAlphaColorRec.White;
    Rect.Stroke.Thickness := 0.0;
    FError.Text := '-';
    FError.Visible := False;
    Graphic.Margins.Bottom := 20.0;
  end
  else
  begin
    Rect.Sides :=[TSide.Top, TSide.Bottom, TSide.Left, TSide.Right];
    Rect.Stroke.Thickness := 3.0;
    Rect.Stroke.Color := TAlphaColorRec.Crimson;
    FError.Text := ErrMsg;
    FError.Visible := True;
    Graphic.Margins.Bottom := 40.0;
  end;

end;

// Input Validation
procedure TProduce.ValidateItemCID(Sender: TInputText);
begin
  DisableInteractivity(Sender);
  with Sender do
  begin
    if(Length(FErrors)= 0)then
      SetLength(FErrors, 2);

    RegexpSnippets['!iNum'].Subject := Text;
    if(Text = '')then
    begin
      FErrors[0]:= 'Ο Κωδικος του ειδους δεν μπόρει να ειναι κενος!';
      // FErrors[0] := 'Wrong Input! Name cannot be empty';
      IsValid := False;
    end
    else if(RegexpSnippets['!iNum'].Match)then
    begin
      FErrors[0]:= 'Ο Κωδικος του ειδους αναγνωριζει μονο νουμερα';
      // FErrors[0] := 'Wrong Input! Name only accepts integers';
      IsValid := False;
    end;
  end;
end;

procedure TProduce.ValidateStockIncrease(Sender: TInputText);
begin
  DisableInteractivity(Sender);
  with Sender do
  begin
    if Length(FErrors)= 0 then
      SetLength(FErrors, 2);

    RegexpSnippets['!rNum'].Subject := Text;
    if Text = '' then
    begin
      FErrors[0]:= 'Πρεπει να καταχωρησετε Αυξηση ποσοτητας';
      // FErrors[0] := 'Wrong Input! Ammount cannot be empty';
      IsValid := False;
    end
    else if RegexpSnippets['!rNum'].Match then
    begin
      FErrors[0]:= 'Η Αυξηση ποσοτητας αναγνωριζει μονο νουμερα';
      // FErrors[0] := 'Wrong Input! Ammount only accepts integers';
      IsValid := False;
    end;

  end;
end;

procedure TProduce.HandleInputSuccess(Sender: TInputText);
begin
  DisplayError;
  if Sender.Name = 'itemCID' then
    FetchItem
  else
    CacheUpdatedStockLevels;
end;

procedure TProduce.HandleInputFailure(Sender: TInputText);
begin
  DisplayError(Sender.FErrors[0]);
  EnableInteractivity(Sender);
end;

procedure TProduce.HandleGraphicClick(Sender: TObject);
begin
  if(StatusProduce = EStatusOrder.Scratch)then
    Exit;

  if(Sender.ClassName = 'TPopupMenu')then
  begin
    WaitForProduce;
    Exit;
  end;

  with Graphic.Components[0] as TRectangle do
  begin
    if IsSelected then
    begin
      Fill.Color := TAlphaColorRec.White;
      IsSelected := False;
    end
    else
    begin
      Fill.Color := TAlphaColorRec.Cornflowerblue;
      IsSelected := True;
    end;
  end;
end;

// Fields & their setters, getters & renders
procedure TProduce.SetStockMoveID(const StockMoveID:string);
begin
  FStockMoveID.Text := StockMoveID;
end;

procedure TProduce.SetStockOrderID(const StockOrderID:string);
begin
  FStockOrderID.Text := StockOrderID;
end;

procedure TProduce.SetItemCID(const ItemCID:string);
begin
  FItemCID.Text := ItemCID;
end;

procedure TProduce.SetItemName(const ItemName:string);
begin
  FItemName.Text := ItemName;
end;

procedure TProduce.SetStockBefore(const StockBefore:string);
begin
  FStockBefore.Text := StockBefore;
end;

procedure TProduce.SetStockIncrease(const StockIncrease:string);
begin
  FStockIncrease.Text := StockIncrease;
end;

procedure TProduce.SetStockAfter(const StockAfter:string);
begin
  FStockAfter.Text := StockAfter;
end;

function TProduce.GetStockMoveID:string;
begin
  Result := FStockMoveID.Text;
end;

function TProduce.GetStockOrderID:string;
begin
  Result := FStockOrderID.Text;
end;

function TProduce.GetItemCID:string;
begin
  Result := FItemCID.Text;
end;

function TProduce.GetItemName:string;
begin
  Result := FItemName.Text;
end;

function TProduce.GetStockBefore:string;
begin
  Result := FStockBefore.Text;
end;

function TProduce.GetStockIncrease:string;
begin
  Result := FStockIncrease.Text;
end;

function TProduce.GetStockAfter:string;
begin
  Result := FStockAfter.Text;
end;

procedure TProduce.RenderStockMoveID;
begin
  with FStockMoveID do
  begin
    name := 'stockMoveID';
    StyleLookup := 'transparentedit';
    StyledSettings :=[];
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.Font.Style :=[TFontStyle.FsBold];
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.Font.Size := 12.0;
    Enabled := True;
    Align := TAlignLayout.Left;
    Size.Width := 75.0;
    Size.PlatformDefault := False;
    readonly := True;
    HitTest := False;
    TabOrder := 1;
  end;
  TRectangle(Graphic.Components[0]).AddObject(FStockMoveID);
end;

procedure TProduce.RenderItemCID;
begin
  with FItemCID do
  begin
    name := 'itemCID';
    StyleLookup := 'transparentedit';
    StyledSettings :=[];
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.Font.Style :=[TFontStyle.FsBold];
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.Font.Size := 12.0;
    Enabled := True;
    Align := TAlignLayout.Left;
    Size.Width := 75.0;
    Size.PlatformDefault := False;
    readonly := True;
    HitTest := False;
    Validate := Self.ValidateItemCID;
    OnInputSuccess := Self.HandleInputSuccess;
    OnInputFailure := Self.HandleInputFailure;
    TabOrder := 2;
  end;
  TRectangle(Graphic.Components[0]).AddObject(FItemCID);
end;

procedure TProduce.RenderItemName;
begin
  with FItemName do
  begin
    name := 'itemName';
    StyleLookup := 'transparentedit';
    StyledSettings :=[];
    Align := TAlignLayout.Client;
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.Font.Size := 13.0;
    Enabled := True;
    HitTest := False;
    readonly := True;
    TabOrder := 3;
  end;
  TRectangle(Graphic.Components[0]).AddObject(FItemName);
end;

procedure TProduce.RenderStockBefore;
begin
  with FStockBefore do
  begin
    name := 'stockBefore';
    StyleLookup := 'transparentedit';
    StyledSettings :=[];
    Enabled := True;
    Align := TAlignLayout.Right;
    Size.Width := 85.0;
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.Font.Style :=[TFontStyle.FsBold];
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.Font.Size := 12.0;
    Size.PlatformDefault := False;
    readonly := True;
    HitTest := False;
    TabOrder := 4;
  end;
  TRectangle(Graphic.Components[0]).AddObject(FStockBefore);
end;

procedure TProduce.RenderStockIncrease;
begin
  with FStockIncrease do
  begin
    name := 'stockIncrease';
    StyleLookup := 'transparentedit';
    StyledSettings :=[];
    Align := TAlignLayout.Right;
    Enabled := True;
    Size.Width := 85.0;
    Size.PlatformDefault := False;
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.Font.Style :=[TFontStyle.FsBold];
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.Font.Size := 12.0;
    TabOrder := 5;
    readonly := True;
    HitTest := False;
    Validate := ValidateStockIncrease;
    OnInputSuccess := Self.HandleInputSuccess;
    OnInputFailure := Self.HandleInputFailure;
  end;
  TRectangle(Graphic.Components[0]).AddObject(FStockIncrease);
end;

procedure TProduce.RenderStockAfter;
begin
  with FStockAfter do
  begin
    name := 'stockAfter';
    StyleLookup := 'transparentedit';
    StyledSettings :=[];
    Enabled := True;
    Align := TAlignLayout.Right;
    Size.Width := 85.0;
    Size.PlatformDefault := False;
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.Font.Style :=[TFontStyle.FsBold];
    TextSettings.HorzAlign := TTextAlign.Center;
    TextSettings.Font.Size := 12.0;
    readonly := True;
    HitTest := False;
    TabOrder := 6;
  end;
  TRectangle(Graphic.Components[0]).AddObject(FStockAfter);
end;

procedure TProduce.RenderError;
begin
  with FError do
  begin
    StyledSettings :=[];
    Size.Width := Graphic.Size.Width;
    TextAlign := TTextAlign.Center;
    Position.Y := 45.0;
    TextSettings.Font.Family := 'Comic Sans MS';
    TextSettings.Font.Size := 18.0;
    TextSettings.FontColor := TAlphaColorRec.Crimson;
    AutoSize := True;
    Text := '-';
    Visible := False;
  end;
  TRectangle(Graphic.Components[0]).AddObject(FError);
end;

initialization
begin
  try
    RegexpSnippets := TRegexpSnippets.Create;
    RegexpSnippets.CompileSnippets(['!iNum', '!rNum']);
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

finalization
begin
  RegexpSnippets.Free;
end;

end.
