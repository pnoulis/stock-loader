unit u_kitchen;

interface

uses
 System.sysUtils,
 System.classes,
 System.UITypes,
 FMX.Dialogs,
 FMX.Types,
 FMX.TabControl;

type
 TKitchen = class(TTabControl)
 private
  Pin: TTabItem;
  procedure renderPass;
  procedure renderPin;
 public
  constructor Create(AOwner: TComponent); override;
 end;

implementation

{ TKitchen }

constructor TKitchen.Create(AOwner: TComponent);
 begin
  inherited;
  Align := TAlignLayout.Client;
  renderPin;
  renderPass;
 end;

procedure TKitchen.renderPass;
 begin

 end;

procedure TKitchen.renderPin;
 begin
 Pin := Add;
 Pin.Text := 'Παραγκελιες';
 end;

end.
