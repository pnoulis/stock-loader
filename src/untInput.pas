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
    procedure Popup(X,Y: Single);override;
    property Enabled: Boolean read FEnabled write FEnabled;
  end; { TProduceCached end }

  TInputText = class(TEdit)
    { Interface }
   public
    constructor Create(AOwner: TComponent;
     var snippets: untTRegexpSnippets.TRegexpSnippets);
    destructor Destroy; override;
    procedure handleKey(Sender: TObject;var key: Word;var keyChar: Char;
     Shift: TShiftState);

   var // event emitters
    onInputSuccess: procedure(sender: TInputText) of object;
    onInputFailure: procedure(sender: TInputText) of object;


    FSnippets: TRegexpSnippets;
    isValid: Boolean;
    validate: procedure(sender: TInputText);
    FErrors: TErrors;
  end;

implementation

 const
  KEY_ENTER: Word = 13;

 procedure TPopupMenu.Popup(X,Y: Single);
  begin
   onPopup(self);
  end; { TPopupMenu.popup end }

 constructor TInputText.Create(AOwner: TComponent;
  var snippets: untTRegexpSnippets.TRegexpSnippets);
  begin
   inherited Create(AOwner);
   FSnippets := snippets;
  end; { TInputText.Create end }

 destructor TInputText.Destroy;
  begin
   setLength(FErrors,0);
   inherited;
  end;

 procedure TInputText.handleKey(Sender: TObject;var key: Word;var keyChar: Char;
  Shift: TShiftState);
  begin
   if not(key = KEY_ENTER) then
    exit;
   isValid := true;
   validate(self);
   if isValid then onInputSuccess(self)
   else onInputFailure(self);

  end; { TInputText.handleKey end }

end.
