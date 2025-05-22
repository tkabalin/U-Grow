unit frmProductDetails_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, Vcl.Samples.Spin, System.UITypes;

type
  TfrmProductDetails = class(TForm)
    imgBanner: TImage;
    imgLogo: TImage;
    bttCart: TBitBtn;
    bttBack: TBitBtn;
    shpBorder: TShape;
    imgProduct: TImage;
    lblProductName: TLabel;
    lblPrice: TLabel;
    lblDescription: TLabel;
    sedQuantity: TSpinEdit;
    bttAddCart: TBitBtn;
    lblQuantity: TLabel;
    lblOutOfStock: TLabel;
    shpHelp: TShape;
    lblHelp: TLabel;
    procedure bttCartClick(Sender: TObject);
    procedure bttBackClick(Sender: TObject);
    procedure LoadProductDetails(sProductID: string);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bttAddCartClick(Sender: TObject);
    procedure lblHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmProductDetails: TfrmProductDetails;

implementation

uses
  frmCustomerHome_u, frmCart_u, dbmUGrow_u, clsValidation_u, frmLogin_u;

{$R *.dfm}

procedure TfrmProductDetails.bttAddCartClick(Sender: TObject);
var
  sProductID: string;
begin
  sProductID := frmCustomerHome.sSelectedID;

  with dbmUGrow do
  begin
    tblProducts.Locate('ProductID', sProductID, []);
    // Check if the product has already been added to the cart
    if not tblCart.Locate('ProductID', sProductID, []) then
    begin
      // If not, insert the product into the cart
      tblCart.Insert;
      tblCart['ProductID'] := sProductID;
      tblCart['ProductName'] := tblProducts['ProductName'];
      tblCart['Quantity'] := sedQuantity.Value;
      tblCart['ItemTotal'] := sedQuantity.Value * tblProducts['UnitPrice'];
    end
    else
    begin
      // If it has already been added, update the quantity
      tblCart.Edit;
      tblCart['Quantity'] := tblCart['Quantity'] + sedQuantity.Value;
      tblCart['ItemTotal'] := tblCart['ItemTotal'] + sedQuantity.Value *
        tblProducts['UnitPrice'];
    end;
    tblCart.Post;
    MessageDlg(IntToStr(sedQuantity.Value) + 'x ' + tblProducts['ProductName'] +
      ' added to cart', mtInformation, [mbOk], 0);
  end;
  LoadProductDetails(sProductID);
end;

procedure TfrmProductDetails.bttBackClick(Sender: TObject);
begin
  frmCustomerHome.Show;
  frmProductDetails.Hide
end;

procedure TfrmProductDetails.bttCartClick(Sender: TObject);
begin
  frmCart.Show;
  frmProductDetails.Hide;
end;

procedure TfrmProductDetails.FormCreate(Sender: TObject);
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

procedure TfrmProductDetails.FormShow(Sender: TObject);
begin
  LoadProductDetails(frmCustomerHome.sSelectedID);
end;

procedure TfrmProductDetails.lblHelpClick(Sender: TObject);
begin
  frmLogin.ShowHelp;
end;

procedure TfrmProductDetails.LoadProductDetails(sProductID: string);
var
  iStockAvailable: integer;
begin
  // Load the product details into their relevant components
  with dbmUGrow do
  begin
    tblProducts.Locate('ProductID', sProductID, []);
    lblProductName.Caption := tblProducts['ProductName'];
    lblPrice.Caption := FloatToStrF(tblProducts['UnitPrice'], ffCurrency, 8, 2);
    lblDescription.Caption := tblProducts['Description'];
  end;

  if FileExists('Product_Images\' + sProductID + '.jpg') then
  begin
    imgProduct.Picture.LoadFromFile('Product_Images\' + sProductID + '.jpg');
  end
  else
    MessageDlg('Product image for ProductID ' + sProductID + ' not found',
      mtError, [mbOk], 0);

  // Check if this product has already been added to cart & set the stock availablity
  with dbmUGrow do
  begin
    if tblCart.Locate('ProductID', sProductID, []) then
    begin
      iStockAvailable := dbmUGrow.tblProducts['Stock'] - dbmUGrow.tblCart
        ['Quantity'];
    end
    else
      iStockAvailable := dbmUGrow.tblProducts['Stock']
  end;

  if iStockAvailable = 0 then // If there is no stock available
  begin
    sedQuantity.Enabled := false;
    bttAddCart.Enabled := false;
    lblOutOfStock.Visible := true;
  end
  else if iStockAvailable = 1 then // if there is one item available
  begin
    sedQuantity.Value := 1;
    sedQuantity.Enabled := false;
    bttAddCart.Enabled := true;
    lblOutOfStock.Visible := false;
  end
  else // if there is more than one product available
  begin
    sedQuantity.Enabled := true;
    sedQuantity.MaxValue := iStockAvailable;
    sedQuantity.Value := 1;
    bttAddCart.Enabled := true;
    lblOutOfStock.Visible := false;
  end;
end;

end.
