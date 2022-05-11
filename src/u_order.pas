unit u_order;

interface

uses
  data.DB,
  untTypes,
  u_produce,
  FireDAC.Comp.Client,
  system.DateUtils,
  system.Classes,
  system.SysUtils,
  system.UITypes,
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
  system.Generics.Collections;

type
  TOrder = class;
  TListOrders = array of TOrder;

  TOrder = class(TObject)
  private type
    TOrderDate = record
      commited: TDateTime;
      issue: string;
      render: string;
    end;
  private
  var
    isSelected: Boolean;
  public
  var
    date: TOrderDate;
    listProduce: TListProduce;
    id: cardinal;
    stockOrderID: cardinal;
    storeID: cardinal;
    status: EStatusOrder;
    isDisplayed: Boolean;
    isFetching: Boolean;
    onOrderDblClick: procedure(order: TOrder) of object;
    constructor Create(const index: cardinal; const data: TFDTable = nil);
    function renderSelf(aOwner: TComponent; template: TPanel): TPanel;
    procedure handleClick(Sender: TObject);
    procedure handleDblClick(Sender: TObject);
  end;

implementation

uses
  udmServerMSSQL;
{ TOrder }

function todayForDB: string;
var
  date, time: string;
begin
  dateTimeToString(date, 'yyyy-mm-dd', today);
  dateTimeToString(time, 'hh-mm-ss', GetTime);
  result := date + ' ' + time;
end;

function renderDate(const aValue: TDateTime): string;
begin
  dateTimeToString(result, 'dddddd', aValue);
end;

constructor TOrder.Create(const index: cardinal; const data: TFDTable = nil);
begin
  inherited Create;
  id := index;
  isSelected := false;
  isFetching := false;

  if assigned(data) then
  begin
    stockOrderID := data.FieldByName('stockOrderID').Value;
    date.commited := data.FieldByName('moveDate').Value;
    date.render := renderDate(date.commited);
    if isToday(date.commited) then
    begin
      status := EStatusOrder.commited;
      end
    else
      status := EStatusOrder.served;
  end
  else
  begin
    stockOrderID := 0;
    date.render := renderDate(today);
    status := EStatusOrder.scratch;
  end;

end;

procedure TOrder.handleClick(Sender: TObject);
begin

  isSelected := not isSelected;

  if isSelected then
  begin
    TRectangle(TComponent(Sender).Components[0]).Fill.Color :=
      TAlphaColorRec.Cornflowerblue;
    TRectangle(TComponent(Sender).Components[0]).Stroke.Color :=
      TAlphaColorRec.Cornflowerblue;
  end
  else
  begin
    TRectangle(TComponent(Sender).Components[0]).Fill.Color :=
      TAlphaColorRec.white;
    TRectangle(TComponent(Sender).Components[0]).Stroke.Color :=
      TAlphaColorRec.white;
  end;
end;

procedure TOrder.handleDblClick(Sender: TObject);
begin
  self.onOrderDblClick(self);
  isSelected := true;
  handleClick(Sender);
end;

function TOrder.renderSelf(aOwner: TComponent; template: TPanel): TPanel;
begin
  result := TPanel(template.clone(aOwner));
  result.Align := TAlignLayout.Top;
  result.Margins.Bottom := 20.0;
  result.visible := true;
  result.OnClick := handleClick;
  result.OnDblClick := handleDblClick;
  TLabel(result.Components[1]).text := stockOrderID.toString;
  TLabel(result.Components[2]).text := date.render;
end;

end.
