unit untInput;

interface
uses
System.Classes,
FMX.Edit,
untTypes,
untTRegexpSnippets;

type

TInputText = class(TEdit)
 { types }
 type
 TOnInputValidationSuccess = procedure(const caller: string) of object;
 TOnInputValidationFailure = procedure(const caller: string;
 errors: TErrors) of object;

 { state }
 private
 FSnippets: TRegexpSnippets;
 FErrors: TErrors;

 procedure validate;
 procedure handleInputSuccess;
 procedure handleInputFailure;

 { Interface }
 public
 constructor Create(AOwner: TComponent); override;
 procedure handleKey(Sender: TObject; var key: Word; var keyChar: Char;
 Shift: TShiftState);

 var  // event emitters
 onInputSuccess: TOnInputValidationSuccess;
 onInputFailure: TOnInputValidationFailure;
end;

implementation
const KEY_ENTER = 13;

constructor TInputText.Create(AOwner: TComponent);
begin

end; { TInputText.Create end }

procedure TInputText.handleKey(Sender: TObject; var key: Word;
 var keyChar: Char; Shift: TShiftState);
begin
if not Key = KEY_ENTER then exit;
{
  showMessage('validating' + ' ' + self.validate);
  validate;
  ReadOnly := true;
  OnKeyUp := nil;
  onValidatedInput();
  }
end; { TInputText.handleKey end }

procedure TInputText.validate;
begin

end; { TInputText.validate end }

procedure TInputText.handleInputSuccess;
begin

end; { TInputText.handleInputFailure end }


procedure TInputText.handleInputFailure;
begin

end; { TInputText.handleInputFailure end }

end.
