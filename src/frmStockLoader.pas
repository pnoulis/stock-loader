unit frmStockLoader;

interface

uses
  {System Units}
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Threading,
  {FMX Units}
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit,
  FMX.Objects,
  {Local Units}
  untInputValidation,
  untKitchen,
  untTypes;

type

  TfrmLoader = class(TForm)
    { Design Time Visual Components }
    layoutNewLoad: TLayout;
    btnNewLoad: TButton;
    layoutCommitLoad: TFlowLayout;
    btnCommitLoad: TButton;
    btnCancelLoad: TButton;
    btnEditStock: TButton;
    btnRemoveStock: TButton;
    layoutStockHeaders: TLayout;
    lblCodeHeader: TLabel;
    lblAmountHeader: TLabel;
    Label1: TLabel;
    add: TButton;

    { Design Time Event Handlers }
    procedure FormCreate(Sender: TObject);
    procedure btnNewLoadClick(Sender: TObject);
    procedure btnCancelLoadClick(Sender: TObject);
    procedure addClick(Sender: TObject);

    { Run Time Managed Components }
  private
    FIsInitFreakout: Boolean;
  public
    FKitchen: untKitchen.TKitchen;
    FDimensions: untTypes.TDimensions;
  end; { TFrmLoader end }

var
  frmLoader: TfrmLoader;

implementation

{$R *.fmx}

procedure TfrmLoader.addClick(Sender: TObject);
begin
self.FKitchen.handleNewOrder;
end;

procedure TfrmLoader.btnCancelLoadClick(Sender: TObject);
begin
  layoutCommitLoad.visible := false;
  layoutStockHeaders.visible := false;
  layoutNewLoad.visible := true;
  FKitchen.handleCancelOrder;
end;

procedure TfrmLoader.btnNewLoadClick(Sender: TObject);
begin
  layoutNewLoad.visible := false;
  layoutCommitLoad.visible := true;
  layoutStockHeaders.visible := true;
  FKitchen.handleNewOrder;

  // when 2nd layout becomes visible delphi draws lines
  // where it shouldnt. Thread is instructed to redraw the
  // canvas. Why not redraw it from within the event?
  // Because lovely click event blocks redrawing.
  // After initial fix delphi seems to deal with it.
  if not FIsInitFreakout then
    TThread.CreateAnonymousThread(
      procedure
      begin
      sleep(100);
        TThread.Synchronize(nil,
          procedure
          begin
            self.Recreate;
          end);
      end).Start;

  FIsInitFreakout := true;
end;

procedure TfrmLoader.FormCreate(Sender: TObject);
begin
  // Initializing Dimenions
  FDimensions.clientWidth := clientWidth;
  FDimensions.clientHeight := clientHeight;

  // Initializing Container
  FKitchen := TKitchen.Create(self, FDimensions);

  // Events
  btnEditStock.OnClick := FKitchen.handleEditProduce;
  btnRemoveStock.OnClick := FKitchen.handleCancelProduce;

  self.AddObject(FKitchen);
end;

{ TFrmLoader.FormCreate end }

end.
