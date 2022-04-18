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
  {Local Units}
  untLoader,
  untTypes, FMX.Objects;

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

    { Design Time Event Handlers }
    procedure FormCreate(Sender: TObject);
    procedure btnNewLoadClick(Sender: TObject);
    procedure btnCancelLoadClick(Sender: TObject);
    procedure adddddClick(Sender: TObject);

    { Run Time Managed Components }
  private
    FIsInitFreakout: Boolean;
  public
    FContainer: untLoader.TContainer;
    FDimensions: untTypes.TDimensions;
  end; { TFrmLoader end }

var
  frmLoader: TfrmLoader;

implementation

{$R *.fmx}

procedure TfrmLoader.adddddClick(Sender: TObject);
begin
self.FContainer.addStock;
end;

procedure TfrmLoader.btnCancelLoadClick(Sender: TObject);
begin
  layoutCommitLoad.visible := false;
  layoutStockHeaders.visible := false;
  layoutNewLoad.visible := true;
  FContainer.handleCancelLoad;
end;

procedure TfrmLoader.btnNewLoadClick(Sender: TObject);
begin
  layoutNewLoad.visible := false;
  layoutCommitLoad.visible := true;
  layoutStockHeaders.visible := true;
  FContainer.handleNewLoad;

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
  FContainer := TContainer.Create(self, FDimensions);

  // Events
  btnEditStock.OnClick := FContainer.handleEditStock;
  btnRemoveStock.OnClick := FContainer.handleRemoveStock;

  self.AddObject(FContainer);
end; { TFrmLoader.FormCreate end }

end.
