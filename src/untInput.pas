unit untInput;

interface

uses
 System.SysUtils,
 System.Classes,
 FMX.Edit,
 FMX.Menus,
 untTypes,
 untTRegexpSnippets;

type
 TPopupMenu = class(FMX.Menus.TPopupMenu)
 private
  FEnabled: Boolean;
 public
  procedure Popup(X, Y: Single); override;
  property Enabled: Boolean read FEnabled write FEnabled;
 end; { TProduceCached end }

 TInputText = class(TEdit)
  { Interface }
 public
  constructor Create(AOwner: TComponent); override;
  destructor Destroy; override;
  procedure handleKey(Sender: TObject; var key: Word; var keyChar: Char;
   Shift: TShiftState);

 var // event emitters
  onInputSuccess: procedure(Sender: TInputText) of object;
  onInputFailure: procedure(Sender: TInputText) of object;

  FSnippets: TRegexpSnippets;
  isValid: Boolean;
  validate: procedure(Sender: TInputText) of object;
  FErrors: TErrors;
 end;

implementation

uses
 FMX.Dialogs;

const
 KEY_ENTER: Word = 13;

procedure TPopupMenu.Popup(X, Y: Single);
 begin
  onPopup(self);
 end; { TPopupMenu.popup end }

constructor TInputText.Create(AOwner: TComponent);
 begin
  inherited Create(AOwner);
 end; { TInputText.Create end }

destructor TInputText.Destroy;
 begin
  setLength(FErrors, 0);
  inherited;
 end;

procedure TInputText.handleKey(Sender: TObject; var key: Word;
 var keyChar: Char; Shift: TShiftState);
 begin
  if not(key = KEY_ENTER) then
   exit;

  self.OnKeyUp := nil;

  isValid := true;
  validate(self);
  if isValid then
   onInputSuccess(self)
  else
   onInputFailure(self);

 end; { TInputText.handleKey end }

end.
