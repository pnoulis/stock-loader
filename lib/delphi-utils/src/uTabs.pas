unit uTabs;

interface

 uses
  System.UITypes,
  System.variants,
  System.sysutils,
  System.classes,
  fmx.Styles,
  fmx.Types,
  fmx.Dialogs,
  fmx.StdCtrls,
  fmx.TabControl;

 type

  TTab = class(TTabItem)
  public
  constructor Create(AOwner: TComponent); override;
  end;

implementation

{ TTab }

constructor TTab.Create(AOwner: TComponent);
begin
inherited Create(AOwner);
var btn := FindStyleResource('text');
if assigned(btn) then showMessage('it was found');
//TButton(btn).Cursor := TCursor(crHandPoint);
//TButton(btn).HitTest := false;

//showMessage(self.Children[0].classname);
//showMessage(self.children[0].FindStyleResource('background').ClassName);
end;

end.
