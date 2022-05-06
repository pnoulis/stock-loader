unit fr_pass;

interface

uses
 System.SysUtils,
 System.Types,
 System.UITypes,
 System.Classes,
 System.Variants,
 FMX.Types,
 FMX.Graphics,
 FMX.Controls,
 FMX.Forms,
 FMX.Dialogs,
 FMX.StdCtrls,
 FMX.Controls.Presentation,
 FMX.Layouts;

type
 TPass = class(TFrame)
  layoutActions: TLayout;
  btnDeleteOrder: TButton;
  btnNewOrder: TButton;
  Button2: TButton;
  layoutHeader: TLayout;
  Label1: TLabel;
  Label2: TLabel;
 private
 public
 end;

implementation

{$R *.fmx}

end.
