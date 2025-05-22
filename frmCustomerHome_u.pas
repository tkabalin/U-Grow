unit frmCustomerHome_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, math, Data.DB, strutils,
  System.UITypes, RichEdit,
  Vcl.ComCtrls;

type
  TfrmCustomerHome = class(TForm)
    imgBanner: TImage;
    imgLogo: TImage;
    bttCart: TBitBtn;
    bttLogout: TBitBtn;
    bttBalance: TBitBtn;
    grpFilterSort: TGroupBox;
    imgProduct1: TImage;
    imgProduct2: TImage;
    imgProduct3: TImage;
    imgProduct4: TImage;
    imgProduct5: TImage;
    imgProduct6: TImage;
    lblProd1: TLabel;
    shpBorder: TShape;
    lblPrice1: TLabel;
    lblProd2: TLabel;
    lblPrice2: TLabel;
    lblProd3: TLabel;
    lblPrice3: TLabel;
    lblProd4: TLabel;
    lblPrice4: TLabel;
    lblProd5: TLabel;
    lblPrice5: TLabel;
    lblProd6: TLabel;
    lblPrice6: TLabel;
    rgpAvailability: TRadioGroup;
    cmbSort: TComboBox;
    lblSort: TLabel;
    pnlProducts: TPanel;
    btnNext: TButton;
    btnBack: TButton;
    shpHelp: TShape;
    lblHelp: TLabel;
    procedure bttCartClick(Sender: TObject);
    procedure bttLogoutClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LoadProductIDs;
    procedure PopulateComponents(sCompName, sValue: string; iIndex: integer;
      CompClass: TComponentClass);
    procedure HideComponents;
    procedure LoadProductDetails;
    procedure cmbSortChange(Sender: TObject);
    procedure rgpAvailabilityClick(Sender: TObject);
    procedure OpenProductDetails(sCompName: string);
    procedure ProdNameClick(Sender: TObject);
    procedure ProdImageClick(Sender: TObject);
    procedure CreateBalanceDlg;
    procedure DestroyBalanceDlg;
    procedure bttBalanceClick(Sender: TObject);
    procedure GetOutstandingBalance;
    procedure btnNextClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure GetReceipts;
    procedure lblHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    sSelectedID: string;
  end;

var
  frmCustomerHome: TfrmCustomerHome;
  pnlBalance: TPanel;
  redReceipts: TRichEdit;
  lblBalance: TLabel;
  edtBalance: TEdit;
  iPageIndex: integer;

implementation

uses
  frmProductDetails_u, frmCart_u, dbmUGrow_u, clsValidation_u, frmLogin_u,
  clsReceipt_u, frmSellerHome_u;

var
  arrProductIDs: array of string;
  arrReceipts: array of TReceipt;
  objValidate: TValidation;

{$R *.dfm}

procedure TfrmCustomerHome.btnNextClick(Sender: TObject);
begin
  // Increase the page index and load the next page
  iPageIndex := iPageIndex + 1;
  LoadProductDetails;
end;

procedure TfrmCustomerHome.bttBalanceClick(Sender: TObject);
begin
  // Check what state the product page is in
  if pnlProducts.Visible then
  // If the product page is currently being displayed
  begin
    // Display the balance page
    CreateBalanceDlg;
    GetOutstandingBalance;
    GetReceipts;
    grpFilterSort.Enabled := false;
    bttBalance.Caption := 'Products';
  end
  else
  begin
    // Close the balance page
    DestroyBalanceDlg;
    grpFilterSort.Enabled := true;
    bttBalance.Caption := 'Balance';
  end;
end;

procedure TfrmCustomerHome.bttCartClick(Sender: TObject);
begin
  // Open the cart
  frmCart.show;
  frmCustomerHome.Hide;
end;

procedure TfrmCustomerHome.bttLogoutClick(Sender: TObject);
begin
  // Close the form and clear the cart
  frmCustomerHome.Hide;
  dbmUGrow.ClearCart;
end;

procedure TfrmCustomerHome.btnBackClick(Sender: TObject);
begin
  // Decrease the page index and load the previous page
  iPageIndex := iPageIndex - 1;
  LoadProductDetails;
end;

procedure TfrmCustomerHome.cmbSortChange(Sender: TObject);
begin
  // Go to the first page and load the products
  iPageIndex := 0;
  LoadProductDetails;
end;

procedure TfrmCustomerHome.CreateBalanceDlg;
begin
  // Create the panel
  pnlBalance := TPanel.Create(Self);
  with pnlBalance do
  begin
    Parent := Self;
    Top := 184;
    Left := 275;
    Width := 680;
    Height := 464;
  end;

  // Create the rich edit control
  redReceipts := TRichEdit.Create(Self);
  with redReceipts do
  begin
    Parent := pnlBalance;
    Left := 30;
    Top := 100;
    Width := 620;
    Height := 334;
    ScrollBars := ssVertical;
    ReadOnly := true;
    Font.Size := 11;
    Paragraph.TabCount := 1;
    Paragraph.Tab[0] := 125;
  end;

  // Create the label
  lblBalance := TLabel.Create(Self);
  with lblBalance do
  begin
    Parent := pnlBalance;
    Left := 30;
    Top := 32;
    Caption := 'Outstanding Balance:';
    Font.Size := 13;
  end;

  // Create the edit box
  edtBalance := TEdit.Create(Self);
  with edtBalance do
  begin
    Parent := pnlBalance;
    Left := 250;
    Top := 30;
    Width := 100;
    Height := 38;
    ReadOnly := true;
    Font.Size := 13;
  end;

  pnlProducts.Hide;
end;

procedure TfrmCustomerHome.DestroyBalanceDlg;
begin
  // Hide the balance page and show the product page
  pnlBalance.free;
  pnlProducts.show;
end;

procedure TfrmCustomerHome.FormCreate(Sender: TObject);
var
  iComp: integer;
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
        [mbOK], 0);
    end;
  end;

  // Loop through the product components and set their 'OnClick' events
  for iComp := 1 to 6 do
  begin
    TLabel(FindComponent('lblProd' + IntToStr(iComp))).OnClick := ProdNameClick;
    TImage(FindComponent('imgProduct' + IntToStr(iComp))).OnClick :=
      ProdImageClick;
  end;
end;

procedure TfrmCustomerHome.FormShow(Sender: TObject);
begin
  // Set the page index to 0 and load the products
  iPageIndex := 0;
  LoadProductDetails;
end;

procedure TfrmCustomerHome.GetOutstandingBalance;
begin
  // Locate the customer in the database and display their outstanding balance
  with dbmUGrow do
  begin
    tblCustomers.Locate('CustomerID', frmLogin.sCustomerID, []);
    edtBalance.Text := FloatToStrF(tblCustomers['OutstandingBalance'],
      ffCurrency, 8, 2);
  end;
end;

procedure TfrmCustomerHome.GetReceipts;
var
  sCustomerID: string;
  iIndex: integer;
  sReceiptList: TStringList;
begin
  // Check if the receipts file exists
  if not FileExists('Receipts.txt') then
  begin
    MessageDlg('Receipts file cannot be found', mtError, [mbOK], 0);
    exit;
  end;

  // Check that the receipt file is not empty
  if not objValidate.IsFileEmpty('Receipts.txt') then
  begin
    // Create a string list of the receipts
    sReceiptList := TStringList.Create;
    sReceiptList.LoadFromFile('Receipts.txt');
  end
  else
  begin
    MessageDlg('No receipts on record', mtError, [mbOK], 0);
    exit;
  end;

  // Ensure that the string list is not empty
  if sReceiptList.Count > 0 then
  begin
    // Set the length of the array of objects to the number of receipts stored in the file
    SetLength(arrReceipts, sReceiptList.Count);

    // Loop through the array of objects and create the receipts from the string list
    for iIndex := 0 to high(arrReceipts) do
    begin
      if not sReceiptList[iIndex].IsEmpty then
        arrReceipts[iIndex] := TReceipt.Create(sReceiptList[iIndex]);
    end;
  end;

  sReceiptList.free;

  // Filter the receipts by the current CustomerID
  sCustomerID := frmLogin.sCustomerID;
  for iIndex := high(arrReceipts) downto 0 do
  // Loops through the receipts from newest to oldest
  begin
    // Display the receipts that match the current CustomerID
    if arrReceipts[iIndex].getCustomerID = sCustomerID then
    begin
      redReceipts.Lines.Add(arrReceipts[iIndex].toString);
    end;
  end;

  // Return to the start of the rich edit
  redReceipts.SelStart := 0;
  redReceipts.Perform(EM_SCROLLCARET, 0, 0);
end;

procedure TfrmCustomerHome.HideComponents;
var
  iCompNum: integer;
begin
  // Loop through the product components and hide them
  for iCompNum := 1 to 6 do
  begin
    // Components are found using their naming structure
    TLabel(FindComponent('lblProd' + IntToStr(iCompNum))).Visible := false;
    TLabel(FindComponent('lblPrice' + IntToStr(iCompNum))).Visible := false;
    TImage(FindComponent('imgProduct' + IntToStr(iCompNum))).Visible := false;
  end;
end;

procedure TfrmCustomerHome.lblHelpClick(Sender: TObject);
begin
  frmLogin.ShowHelp;
end;

procedure TfrmCustomerHome.LoadProductDetails;
var
  iIndex: integer;
begin
  LoadProductIDs;
  HideComponents;

  // Loop through the array of ProductIDs and load the product details into the relevant components
  for iIndex := low(arrProductIDs) to High(arrProductIDs) do
  begin
    PopulateComponents('lblProd', 'ProductName', iIndex, TLabel);
    PopulateComponents('lblPrice', 'UnitPrice', iIndex, TLabel);
    PopulateComponents('imgProduct', 'Product_Images\' + arrProductIDs[iIndex] +
      '.jpg', iIndex, TImage);
  end;
end;

procedure TfrmCustomerHome.LoadProductIDs;
var
  iIndex: integer;
begin
  // Sort the database before loading the ProductIDs
  case cmbSort.ItemIndex of
    0:
      dbmUGrow.tblProducts.Sort := 'ProductName ASC';
    1:
      dbmUGrow.tblProducts.Sort := 'ProductName DESC';
    2:
      dbmUGrow.tblProducts.Sort := 'UnitPrice DESC';
    3:
      dbmUGrow.tblProducts.Sort := 'UnitPrice ASC';
  end;

  // Filter the database before loading the ProductIDs
  case rgpAvailability.ItemIndex of
    0: // In and out of stock
      begin
        dbmUGrow.tblProducts.Filter := '';
        dbmUGrow.tblProducts.Filtered := false;
      end;
    1: // In stock
      begin
        dbmUGrow.tblProducts.Filter := 'Stock > 0';
        dbmUGrow.tblProducts.Filtered := true;
      end;
    2: // Out of stock
      begin
        dbmUGrow.tblProducts.Filter := 'Stock = 0';
        dbmUGrow.tblProducts.Filtered := true;
      end;
  end;

  // If the current page is not the first, then enable the back button
  btnBack.Enabled := iPageIndex > 0;
  btnNext.Enabled := false;

  try
    if dbmUGrow.tblProducts.RecordCount IN [1 .. 6] then
    begin
      // There is only one page of products (i.e. < 6), so all the products are loaded into one array
      SetLength(arrProductIDs, dbmUGrow.tblProducts.RecordCount);
      // Loop through the products and add their IDs to the array
      dbmUGrow.tblProducts.First;
      for iIndex := Low(arrProductIDs) to High(arrProductIDs) do
      begin
        arrProductIDs[iIndex] := dbmUGrow.tblProducts['ProductID'];
        dbmUGrow.tblProducts.Next;
      end;
    end
    else if dbmUGrow.tblProducts.RecordCount > 6 then
    // There is more than 1 page of products
    begin
      // Navigate to the correct place in the table
      dbmUGrow.tblProducts.First;
      for iIndex := 0 to iPageIndex * 6 - 1 do
      // Loop to the number of products that have been displayed, minus 1 due to the array index starting from 0
      begin
        dbmUGrow.tblProducts.Next;
      end;

      if dbmUGrow.tblProducts.RecordCount - (iPageIndex * 6) > 6 then
      { If the total number of products minus the number that have been displayed is more than 6,
        then there are more than 6 products left to display }
      begin
        btnNext.Enabled := true;
        SetLength(arrProductIDs, 6); // Only the next 6 will be displayed
        // Add the 6 products to the array
        for iIndex := 0 to 5 do
        begin
          arrProductIDs[iIndex] := dbmUGrow.tblProducts['ProductID'];
          dbmUGrow.tblProducts.Next;
        end;
      end
      else if dbmUGrow.tblProducts.RecordCount - (iPageIndex * 6) = 6 then
      // If there are exactly 6 products left to display, the next button should not be enabled
      begin
        // Set the length of the array to 6
        SetLength(arrProductIDs, 6);
        // Add the 6 products to the array
        for iIndex := 0 to 5 do
        begin
          arrProductIDs[iIndex] := dbmUGrow.tblProducts['ProductID'];
          dbmUGrow.tblProducts.Next;
        end;
      end
      else
      // If there are less than 6 products to display
      begin
        SetLength(arrProductIDs, dbmUGrow.tblProducts.RecordCount -
          (iPageIndex * 6 - 1) - 1);

        // Add the products to the array
        for iIndex := 0 to High(arrProductIDs) do
        begin
          arrProductIDs[iIndex] := dbmUGrow.tblProducts['ProductID'];
          dbmUGrow.tblProducts.Next;
        end;
      end;
    end;
  except
    MessageDlg('Error loading ProductIDs', TMsgDlgType.mtError, [mbOK], 0);
  end;

end;

procedure TfrmCustomerHome.OpenProductDetails(sCompName: string);
var
  iIndex: integer;
begin
  // Get the Index of the selected product from the name of the component that was selected
  iIndex := StrToInt(RightStr(sCompName, 1));
  sSelectedID := arrProductIDs[iIndex - 1];

  // Open the product details form
  frmProductDetails.show;
  frmCustomerHome.Hide;
end;

procedure TfrmCustomerHome.PopulateComponents(sCompName, sValue: string;
  iIndex: integer; CompClass: TComponentClass);
var
  sComponent: string;
  iCode: integer;
  rUnitPrice: real;
begin
  // Dynamically predict the component name according to the naming scheme of the program
  sComponent := sCompName + IntToStr(iIndex + 1);

  // Check that the component exists and is of the correct type
  if Assigned(FindComponent(sComponent)) and
    (FindComponent(sComponent) is CompClass) then
  begin
    dbmUGrow.tblProducts.Locate('ProductID', arrProductIDs[iIndex], []);
    // If a component with the generated name and type is found, set its properties depending on what type it is
    if CompClass = TLabel then
    begin
      TLabel(FindComponent(sComponent)).Visible := true;

      // Check whether the caption should be formated as a string or currency
      val(dbmUGrow.tblProducts[sValue], rUnitPrice, iCode);
      if iCode = 0 then
      begin
        // Load the product price onto the label
        TLabel(FindComponent(sComponent)).Caption :=
          FloatToStrF(rUnitPrice, ffCurrency, 8, 2);
      end
      else
      begin
        // Load the product name onto the label
        TLabel(FindComponent(sComponent)).Caption :=
          dbmUGrow.tblProducts[sValue];
        TLabel(FindComponent(sComponent)).Hint := dbmUGrow.tblProducts
          ['ProductName'];
      end;
    end
    else if CompClass = TImage then
    begin
      if not FileExists(sValue) then
      begin
        MessageDlg('Product image for ProductID ' + arrProductIDs[iIndex] +
          ' not found', mtError, [mbOK], 0);
      end
      else
      begin
        // Load the product image onto the component
        TImage(FindComponent(sComponent)).Visible := true;
        TImage(FindComponent(sComponent)).Picture.LoadFromFile(sValue);
        TImage(FindComponent(sComponent)).Hint := dbmUGrow.tblProducts
          ['ProductName'];
      end;
    end;
  end;
end;

procedure TfrmCustomerHome.ProdImageClick(Sender: TObject);
begin
  OpenProductDetails((Sender as TImage).Name);
end;

procedure TfrmCustomerHome.ProdNameClick(Sender: TObject);
begin
  OpenProductDetails((Sender as TLabel).Name);
end;

procedure TfrmCustomerHome.rgpAvailabilityClick(Sender: TObject);
begin
  iPageIndex := 0;
  LoadProductDetails;
end;

end.
