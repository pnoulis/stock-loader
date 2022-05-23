unit untInput;

interface
uses
  System.SysUtils,
  System.Classes,
  FMX.Edit,
  FMX.Menus,
  UntTypes,
  UntTRegexpSnippets;

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
      procedure HandleKey(Sender: TObject;var Key: Word;var KeyChar: Char;
          Shift: TShiftState);

    var// event emitters
      OnInputSuccess: procedure(Sender: TInputText)of object;
      OnInputFailure: procedure(Sender: TInputText)of object;

      FSnippets: TRegexpSnippets;
      IsValid: Boolean;
      Validate: procedure(Sender: TInputText)of object;
      FErrors: TErrors;
  end;

implementation
uses
  FMX.Dialogs;

const
  KEY_ENTER: Word = 13;

procedure TPopupMenu.Popup(X, Y: Single);
begin
  OnPopup(Self);
end; { TPopupMenu.popup end }

constructor TInputText.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end; { TInputText.Create end }

destructor TInputText.Destroy;
begin
  SetLength(FErrors, 0);
  inherited;
end;

procedure TInputText.HandleKey(Sender: TObject;var Key: Word;var KeyChar: Char;
    Shift: TShiftState);
begin
  if not(Key = KEY_ENTER)then
    Exit;

  Self.OnKeyUp := nil;

  IsValid := True;
  Validate(Self);
  if IsValid then
    OnInputSuccess(Self)
  else
    OnInputFailure(Self);

end; { TInputText.handleKey end }

end.
