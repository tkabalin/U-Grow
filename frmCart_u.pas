unit frmCart_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg, Vcl.Samples.Spin, System.UITypes, StrUtils, math;

type
  TfrmCart = class(TForm)
    dbgCart: TDBGrid;
    imgBanner: TImage;
    imgLogo: TImage;
    bttBack: TBitBtn;
    shpBorder: TShape;
    imgProduct: TImage;
    lblProduct: TLabel;
    sedQuantity: TSpinEdit;
    lblQuantity: TLabel;
    lblTotal: TLabel;
    edtTotal: TEdit;
    bttPlaceOrder: TBitBtn;
    bttRemove: TBitBtn;
    grpProduct: TGroupBox;
    btnSaveQuantity: TButton;
    procedure bttBackClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GetCart;
    procedure FormShow(Sender: TObject);
    procedure LoadProductDetails;
    procedure dbgCartCellClick(Column: TColumn);
    procedure bttRemoveClick(Sender: TObject);
    procedure GetTotal;
    procedure UpdateQuantity;
    procedure btnSaveQuantityClick(Sender: TObject);
    procedure bttPlaceOrderClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCart: TfrmCart;

implementation

uses
  frmProductDetails_u, frmCustomerHome_u, dbmUGrow_u, clsValidation_u,
  frmLogin_u;

var
  objValidate: TValidation;

{$R *.dfm}

procedure TfrmCart.bttBackClick(Sender: TObject);
begin
  frmCustomerHome.show;
  frmCart.Hide;
end;

procedure TfrmCart.bttPlaceOrderClick(Sender: TObject);
var
  sOrderID: string;
begin
  with dbmUGrow do
  begin
    // Check if the cart is empty
    if tblCart.IsEmpty then
    begin
      MessageDlg('Cart is empty, please add a product', mtError, [mbOk], 0);
      exit;
    end;

    // Check that there is enough of each product in stock
    tblCart.First;
    while not tblCart.Eof do
    begin
      tblProducts.Locate('ProductID', tblCart['ProductID'], []);
      if tblCart['Quantity'] > tblProducts['Stock'] then
      begin
        MessageDlg('You have tried to order  ' + IntToStr(tblCart['Quantity']) +
          ' of product: ' + tblCart['ProductName'] + ', but there are only ' +
          IntToStr(tblProducts['Stock']) + ' in stock.', mtError, [mbOk], 0);

        // Reduce the quantity in the cart to the maximum amount
        tblCart.Edit;
        tblCart['Quantity'] := tblProducts['Stock'];
        tblCart['ItemTotal'] := tblProducts['Stock'] * tblProducts['UnitPrice'];
        tblCart.Post;
        tblCart.Refresh;

        GetCart;
        GetTotal;
        exit;
      end;

      tblCart.Next;
    end;

    // Create an OrderID consisting of 'INV' and 5 random didgits
    Randomize;
    repeat
      sOrderID := 'INV' + IntToStr(RandomRange(10000, 100000));
    until objValidate.IsUnique(sOrderID, dbmUGrow.tblOrders, 'OrderID');

    try
      // Add the order to the orders table
      tblOrders.Insert;
      tblOrders['OrderID'] := sOrderID;
      tblOrders['CustomerID'] := frmLogin.sCustomerID;
      tblOrders['OrderDate'] := date;
      tblOrders.Post;

      // Add each product to tblOrderProd and reduce the stock of the products
      tblCart.First;
      while not tblCart.Eof do
      begin
        tblOrderProd.Insert;
        tblOrderProd['OrderID'] := tblOrders['OrderID'];
        tblOrderProd['ProductID'] := tblCart['ProductID'];
        tblOrderProd['Quantity'] := tblCart['Quantity'];

        tblProducts.Locate('ProductID', tblCart['ProductID'], []);
        tblProducts.Edit;
        tblProducts['Stock'] := tblProducts['Stock'] - tblCart['Quantity'];

        tblCart.Next;
      end;
      tblOrderProd.Post;
      tblProducts.Post;

      // Increase the outstanding balance of the customer
      tblCustomers.Locate('CustomerID', frmLogin.sCustomerID, []);
      GetTotal;
      tblCustomers.Edit;
      tblCustomers['OutstandingBalance'] := tblCustomers['OutstandingBalance'] +
        qryCartTotal.FieldByName('Total').AsCurrency;
      tblCustomers.Post;
    except
      begin
        MessageDlg('Could not place order. Please try again',
          TMsgDlgType.mtError, [mbOk], 0);
        exit;
      end;
    end;

    // Clear the cart
    ClearCart;

    MessageDlg
      ('Thank you for your order. Please go the nearest U-Grow store to pick up your products and make your payment.',
      mtInformation, [mbOk], 0);
    frmCustomerHome.show;
    frmCart.Hide;
  end;
end;

procedure TfrmCart.bttRemoveClick(Sender: TObject);
begin
  if MessageDlg('Are you sure you want to remove this item?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
  begin
    with dbmUGrow do
    begin
      // Locate and delete the product from the cart
      tblCart.Locate('ProductID', qryCart_NoID['ProductID'], []);
      tblCart.Delete;
      tblCart.Refresh;
    end;

    // Update the cart
    GetCart;
    GetTotal;
    grpProduct.Hide;
  end;
end;

procedure TfrmCart.btnSaveQuantityClick(Sender: TObject);
begin
  // Update the cart with the new quantity
  UpdateQuantity;
  grpProduct.Hide;
  GetCart;
  GetTotal;
end;

procedure TfrmCart.dbgCartCellClick(Column: TColumn);
begin
  LoadProductDetails;
end;

procedure TfrmCart.FormCreate(Sender: TObject);
begin
  // Load the decorative images
  try
    imgBanner.Picture.LoadFromFile('Decorative_Images\Microgreens_Header.jpg');
    imgLogo.Picture.LoadFromFile('Decorative_Images\UGrow_Logo_Standard.png');
  except
    on E: Exception do
    begin
      // Display a single error message for both image loading failures
      MessageDlg('Failed to load one or more images: ' + E.Message, mtError,
        [mbOk], 0);
    end;
  end;
end;

procedure TfrmCart.FormShow(Sender: TObject);
begin
  // Load the cart
  GetCart;
  LoadProductDetails;
  GetTotal;
end;

procedure TfrmCart.GetCart;
begin
  with dbmUGrow do
  begin
    // Create a query to get the required fields from the cart
    qryCart_NoID.active := false;
    qryCart_NoID.SQL.Text :=
      'SELECT tblCart.ProductID, tblCart.ProductName, tblCart.Quantity, tblCart.ItemTotal FROM tblCart '
      + 'WHERE tblCart.Quantity > 0';
    qryCart_NoID.active := true;
    dbgCart.DataSource := dscCart_NoID;

    // Set the format of the ItemTotal to currency
    TFloatField(qryCart_NoID.FieldByName('ItemTotal')).DisplayFormat := 'R0.00';
  end;

  // Hide the ProductID, as it is needed for calculations but not by the user
  dbgCart.Columns[0].Width := 0;
end;

procedure TfrmCart.GetTotal;
var
  rTotal: real;
begin
  with dbmUGrow do
  begin
    // Check if there are any items in the cart
    if not tblCart.IsEmpty then
    begin
      // If there are, get the total cost of all the items as a number
      qryCartTotal.SQL.Text :=
        'SELECT CDBL(SUM(tblCart.ItemTotal)) AS Total FROM tblCart';
      qryCartTotal.Open;
      rTotal := StrToFloat(qryCartTotal.FieldByName('Total').AsString);

      // Format and display the cost as currency
      edtTotal.Text := FormatCurr('R#,##0.00', rTotal);
    end
    else
      edtTotal.Text := FormatCurr('R#,##0.00', 0)
  end;

end;

procedure TfrmCart.LoadProductDetails;
begin
  with dbmUGrow do
  begin
    // Check that there are items in the cart
    if not qryCart_NoID.IsEmpty then
    begin
      // Load the product information into the components in the group box
      grpProduct.Visible := true;
      lblProduct.Caption := qryCart_NoID['ProductName'];

      if FileExists('Product_Images\' + qryCart_NoID['ProductID'] + '.jpg') then
      begin
        imgProduct.Picture.LoadFromFile('Product_Images\' + qryCart_NoID
          ['ProductID'] + '.jpg');
      end
      else
        MessageDlg('Product image for ProductID ' + qryCart_NoID['ProductID'] +
          ' not found', mtError, [mbOk], 0);

      { Set the max value of the spin edit so that customers cannot add more
        products than are in stock to the cart }
      tblProducts.Locate('ProductID', qryCart_NoID['ProductID'], []);
      if tblProducts['Stock'] = 1 then
      begin
        sedQuantity.Enabled := false;
      end
      else if tblProducts['Stock'] > 1 then
      begin
        sedQuantity.Enabled := true;
        sedQuantity.MaxValue := tblProducts['Stock'];
      end;
      sedQuantity.Value := qryCart_NoID['Quantity'];
    end
    else
    begin
      grpProduct.Visible := false;
    end;
  end;
end;

procedure TfrmCart.UpdateQuantity;
begin
  with dbmUGrow do
  begin
    // Locate the product in the cart
    tblCart.Locate('ProductID', qryCart_NoID['ProductID'], []);

    // Check that the quantity has changed
    if sedQuantity.Value <> tblCart['Quantity'] then
    begin
      // Update the quantity and item total
      tblCart.Edit;
      tblCart['Quantity'] := sedQuantity.Value;
      tblCart['ItemTotal'] := sedQuantity.Value * tblProducts['UnitPrice'];
      tblCart.Post;
      tblCart.Refresh;
    end;
  end;
end;

end.
