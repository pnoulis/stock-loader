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
  {Libraries}
  uDBConnect,
  uFilesystem,
  {Local Units}
  udmEliza,
  uListOrders,
  untKitchen,
  untTypes, FMX.TabControl;

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
   btnConnect: TButton;
   lblOrderID: TLabel;
    StyleBook1: TStyleBook;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    Layout1: TLayout;
    Button1: TButton;
    FlowLayout1: TFlowLayout;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Label1: TLabel;
    btnShowFrame: TButton;

   { Design Time Event Handlers }
   procedure FormCreate(Sender: TObject);
   procedure btnNewLoadClick(Sender: TObject);
   procedure btnCancelLoadClick(Sender: TObject);
   procedure addClick(Sender: TObject);
   procedure btnConnectClick(Sender: TObject);

   { Run Time Managed Components }
   private
    FIsInitFreakout: Boolean;
   public
    listOrder: uListOrders.TListOrders;
    FKitchen: untKitchen.TKitchen;
    FDimensions: untTypes.TDimensions;
  end; { TFrmLoader end }

 var
  frmLoader: TfrmLoader;

implementation

 {$R *.fmx}

 procedure TfrmLoader.addClick(Sender: TObject);
  begin
   // self.FKitchen.handleNewOrder;
  end;

 procedure TfrmLoader.btnCancelLoadClick(Sender: TObject);
  begin
   layoutCommitLoad.visible := false;
   layoutStockHeaders.visible := false;
   layoutNewLoad.visible := true;
   FKitchen.handleCancelOrder;
   self.listOrder := uListOrders.TListOrders.Create(frmLoader);
   frmLoader.AddObject(listOrder);
   listOrder.fill;
  end;

 procedure TfrmLoader.btnConnectClick(Sender: TObject);
  begin
   {
     try
     except
     on E: Exception do
     showMessage(E.message);
     end;
   }
   self.listOrder := uListOrders.TListOrders.Create(frmLoader);
   frmLoader.AddObject(listOrder);
   listOrder.fill;
  end;

 procedure TfrmLoader.btnNewLoadClick(Sender: TObject);
  begin
   layoutNewLoad.visible := false;
   layoutCommitLoad.visible := true;
   layoutStockHeaders.visible := true;
   listOrder.Free;
   FKitchen.handleNewOrder(dmEliza.currentOrderID);
   self.lblOrderID.Text := 'arithmos:' + (dmEliza.currentOrderID + 1).tostring;

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
  end; { TFrmLoader.FormCreate end }

 begin
  uFilesystem.anchorProjectRoot('stock-loader');

end.
