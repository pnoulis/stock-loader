unit u_order;

interface

uses
 data.DB,
// udmServerMSSQL,
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
 EStatusOrder = (served, commited, scratchpad);

 TOrder = class(TObject)
 private type
  TOrderDate = record
   commited: TDateTime;
   issue: string;
   render: string;
  end;
 private
 var
  date: TOrderDate;
  isSelected: Boolean;
  procedure fetchProduce;
 public
 var
  id: cardinal;
  status: EStatusOrder;
  isDisplayed: Boolean;
  onOrderDblClick: procedure(order: TOrder) of object;
  constructor Create(const orderID: cardinal; const data: TFDTable = nil);
  function renderSelf(aOwner: TComponent; template: TPanel): TPanel;
  procedure handleClick(Sender: TObject);
  procedure handleDblClick(Sender: TObject);
 end;

implementation
uses
 udmServerMSSQL;
{ TOrder }

function todayForDB: string;
 var date, time: string;
 begin
  dateTimeToString(date, 'yyyy-mm-dd', today);
  dateTimeToString(time, 'hh-mm-ss', GetTime);
  result := date + ' ' + time;
 end;

function renderDate(const aValue: TDateTime): string;
 begin
  dateTimeToString(result, 'dddddd', aValue);
 end;

constructor TOrder.Create(const orderID: cardinal; const data: TFDTable = nil);
 var time: string;
 begin
  inherited Create;
  id := orderID;
  isSelected := false;

  if assigned(data) then
   begin
    date.commited := data.FieldByName('moveDate').Value;
    date.render := renderDate(date.commited);
    if isToday(date.commited) then
     status := EStatusOrder.served
    else
     status := EStatusOrder.commited;
   end
  else
   begin
    date.render := renderDate(today);
    status := EStatusOrder.scratchpad;
   end;

 end;

procedure TOrder.fetchProduce;
 begin
  var
  i := 0;
  const query = DB.queryStockMoves;

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
  handleClick(Sender);
  self.onOrderDblClick(self);
 end;

function TOrder.renderSelf(aOwner: TComponent; template: TPanel): TPanel;
 begin
  result := TPanel(template.clone(aOwner));
  result.Align := TAlignLayout.Top;
  result.Margins.Bottom := 20.0;
  result.visible := true;
  result.OnClick := handleClick;
  result.OnDblClick := handleDblClick;
  TLabel(result.Components[1]).text := id.toString;
  TLabel(result.Components[2]).text := date.render;
 end;

end.
