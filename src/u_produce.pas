unit u_produce;

interface

uses
  FireDAC.Comp.Client,
  system.DateUtils,
  system.Classes,
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
  u_TTextInput,
  untTypes;

type
  TProduce = class;
  TListProduce = array of TProduce;

  TProduce = class(TObject)
  private
  FProduceName: TTextInput;
  FProduceID: TTextInput;
  FStockBefore: TTextInput;
  FStockIncrease: TTextInput;
  FStockAfter: TTextInput;

    procedure askProduceName;
    procedure fetchProduce;
    procedure recordCurrentStockLevels;
    procedure askNewStockToBeAdded;
    procedure cacheUpdatedStocklevels;
    procedure enableInteractivity(Target: TEdit);
    procedure disableInteractivity(Target: TEdit);
    procedure commitUpdatedStocklevels;
    procedure displayError(const errMsg: string = '');

  public var
    ID: Cardinal;
    moveID: Cardinal;
    produceID: Cardinal;
    produceName: string;
    stockBefore: cardinal;
    stockIncrease: cardinal;
    stockAfter: cardinal;
    isSelected: Boolean;
    status: EStatusOrder;
    graphic: TPanel;
    constructor Create(orderStatus: EStatusOrder; template: TPanel; data: TFields = nil);
    function renderSelf(AOwner: TComponent; template: TPanel): TPanel;
    procedure waitForProduce;
  end;

implementation

{ TProduce }

procedure TProduce.askNewStockToBeAdded;
begin
showMessage('ask new stock to be added');
end;

procedure TProduce.askProduceName;
begin
showMessage('ask produce name');
end;

procedure TProduce.cacheUpdatedStocklevels;
begin
showMessage('cache updated stock levels');
end;

procedure TProduce.commitUpdatedStocklevels;
begin
showMessage('commit updated stock levels');
end;

constructor TProduce.Create(OrderStatus: EStatusOrder; template: TPanel; data: TFields = nil);
begin

showMessage(template.ControlsCount.tostring);
//var tmp := template.Components[0].FindComponent('inputProduceAfter');
//if tmp <> nil then showMessage('component found');
{
result := TPanel(template.Clone(AOwner));
result.Align := TAlignLayout.Top;
result.Margins.Bottom := 20.0;
result.Visible := true;

TEdit(result.Components[4]).Text := produceID.ToString;
Tedit(result.Components[2]).Text := produceName;
Tedit(result.Components[1]).Text := stockAfter.toString;
TEdit(result.Components[3]).Text := stockIncrease.ToString;

  //ID := produceID;
  isSelected := false;

  if assigned(data) then
  begin
  setProduceID(data.FieldByName('itemCID').Value);
  setProduceName(data.FieldByName('itemName').Value);
  setStockBefore(data.FieldByName('stockBefore').Value);
  setStockAfter(data.FieldByName('stockAfter').Value);
  setStockIncrease(data.FieldByName('stockIncrease').Value);

  {
  tmpproduceID := data.FieldByName('itemCID').Value;
  tmpproduceName := data.FieldByName('itemName').Value;
  tmpstockBefore := data.FieldByName('stockBefore').Value;
  tmpstockAfter := data.FieldByName('stockAfter').Value;
  tmpstockIncrease := data.FieldByName('stockIncrease').Value;
  }
//  end;

  status := orderstatus;
end;

procedure TProduce.disableInteractivity(Target: TEdit);
begin
showMessage('disable interactivity');
end;

procedure TProduce.displayError(const errMsg: string);
begin
showMessage('display error');
end;

procedure TProduce.enableInteractivity(Target: TEdit);
begin
showMessage('enable interactivity');
end;

procedure TProduce.fetchProduce;
begin
showMessage('fetch produce');
end;

procedure TProduce.recordCurrentStockLevels;
begin
showMessage('record current stock levels');
end;

function TProduce.renderSelf(AOwner: TComponent; template: TPanel): TPanel;
var tmp: TEdit;
begin
result := TPanel(template.Clone(AOwner));
result.Align := TAlignLayout.Top;
result.Margins.Bottom := 20.0;
result.Visible := true;

TEdit(result.Components[4]).Text := produceID.ToString;
Tedit(result.Components[2]).Text := produceName;
Tedit(result.Components[1]).Text := stockAfter.toString;
TEdit(result.Components[3]).Text := stockIncrease.ToString;

end;

procedure TProduce.waitForProduce;
begin
showMessage('wait for produce');
{
 disableInteractivity(edtProduceName);
   disableInteractivity(edtProduceIncrBy);
   if FIsCached then
    askNewStockToBeAdded
   else
    askProduceName;
    }
end;

end.
