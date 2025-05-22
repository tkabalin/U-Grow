unit frmSellerHome_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, Vcl.ComCtrls, Data.DB, Vcl.Grids,
  Vcl.DBGrids, VclTee.TeeGDIPlus, VclTee.TeEngine, VclTee.TeeProcs,
  VclTee.Chart,
  Vcl.WinXPickers, Vcl.Samples.Spin, Vcl.WinXCtrls, System.UITypes, ADODB,
  StrUtils, math, dateutils, VclTee.Series;

type
  TfrmSellerHome = class(TForm)
    imgBanner: TImage;
    imgLogo: TImage;
    bttLogout: TBitBtn;
    shpBorder: TShape;
    pgcSeller: TPageControl;
    tbsOrders: TTabSheet;
    tbsProducts: TTabSheet;
    tbsReports: TTabSheet;
    dbgOrders: TDBGrid;
    lstCustomers: TListBox;
    chtSales: TChart;
    lblCustomers: TLabel;
    lblOrder: TLabel;
    btnRecordReceipt: TButton;
    btnViewReceipts: TButton;
    lblBalance: TLabel;
    edtBalance: TEdit;
    dbgProducts: TDBGrid;
    lblProducts: TLabel;
    grpPeriod: TGroupBox;
    dtpFromDate: TDatePicker;
    dtpToDate: TDatePicker;
    lblFrom: TLabel;
    lblTo: TLabel;
    lstProducts: TListBox;
    lblSelect: TLabel;
    bttAdd: TButton;
    bttDelete: TBitBtn;
    cmbSort: TComboBox;
    lblSort: TLabel;
    lblSearch: TLabel;
    grpEdit: TGroupBox;
    edtName: TEdit;
    edtUnitPrice: TEdit;
    sedStock: TSpinEdit;
    redDescription: TRichEdit;
    lblDescription: TLabel;
    lblStock: TLabel;
    lblName: TLabel;
    lblUnitPrice: TLabel;
    bttSave: TBitBtn;
    sbxSearchName: TSearchBox;
    btnSave: TButton;
    Series1: TBarSeries;
    btnChangeGraph: TButton;
    btnRefresh: TButton;
    shpHelp: TShape;
    lblHelp: TLabel;
    procedure bttLogoutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GetProducts;
    procedure cmbSortChange(Sender: TObject);
    procedure sbxSearchNameInvokeSearch(Sender: TObject);
    procedure bttDeleteClick(Sender: TObject);
    procedure LoadProductDetails;
    procedure dbgProductsCellClick(Column: TColumn);
    procedure btnSaveClick(Sender: TObject);
    procedure bttAddClick(Sender: TObject);
    procedure GetCustomers;
    procedure GetOrders;
    procedure lstCustomersClick(Sender: TObject);
    procedure GetProductList;
    procedure bttSaveClick(Sender: TObject);
    procedure CreateSalesPerDayChart;
    procedure lstProductsClick(Sender: TObject);
    procedure btnRecordReceiptClick(Sender: TObject);
    procedure btnViewReceiptsClick(Sender: TObject);
    procedure btnChangeGraphClick(Sender: TObject);
    procedure CreateAvgOrderPriceChart;
    procedure btnRefreshClick(Sender: TObject);
    procedure LoadReceipts;
    procedure dbgOrdersCellClick(Column: TColumn);
    procedure dbgProductsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgProductsMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure lblHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  frmSellerHome: TfrmSellerHome;

implementation

uses
  dbmUGrow_u, clsValidation_u, clsReceipt_u, frmLogin_u;

var
  objValidate: TValidation;
  arrReceipts: array of TReceipt;

{$R *.dfm}

procedure TfrmSellerHome.btnChangeGraphClick(Sender: TObject);
begin
  // Determine which chart is being shown by the caption of the button
  if btnChangeGraph.Caption = 'See Sales Per Day' then
  begin
    // Show the sales per day chart
    btnChangeGraph.Caption := 'See Average Order Price';
    lstProducts.Enabled := true;
    CreateSalesPerDayChart;
  end
  else
  begin
    // Show the average order price chart
    btnChangeGraph.Caption := 'See Sales Per Day';
    lstProducts.Enabled := false;
    CreateAvgOrderPriceChart;
  end;
end;

procedure TfrmSellerHome.btnRecordReceiptClick(Sender: TObject);
var
  sAmountPaid, sCustomerID: string;
  rAmountPaid: Real;
  iCode: Integer;
begin
  // Check that a customer has been selected
  if lstCustomers.ItemIndex = -1 then
  begin
    MessageDlg('Please select a customer', mtError, [mbOK], 0);
    exit;
  end;

  LoadReceipts;

  // Receive the receipt amount from the user
  if not InputQuery('Record Receipt', 'Enter amount paid:', sAmountPaid) then
    exit;

  // Validate the receipt amount
  Val(sAmountPaid, rAmountPaid, iCode);
  RoundTo(rAmountPaid, -2);
  if (iCode > 0) or (rAmountPaid < 0) then
  begin
    MessageDlg('Enter a valid receipt amount', mtError, [mbOK], 0);
    exit;
  end;

  // Locate the selected customer in the database
  sCustomerID := LeftStr(lstCustomers.Items[lstCustomers.ItemIndex], 6);
  dbmUGrow.tblCustomers.Locate('CustomerID', sCustomerID, []);

  // Increase the length of the array of receipts by 1
  SetLength(arrReceipts, Length(arrReceipts) + 1);
  // Create the new receipt
  arrReceipts[high(arrReceipts)] := TReceipt.Create(sCustomerID,
    dbmUGrow.tblCustomers['FirstName'], dbmUGrow.tblCustomers['LastName'],
    rAmountPaid, date);

  GetOrders;
end;

procedure TfrmSellerHome.btnSaveClick(Sender: TObject);
var
  sProductID, sProductName, sDescription: string;
  rUnitPrice: Real;
  iStock, iCode: Integer;
begin
  // Extract the product details
  sProductName := edtName.Text;
  iStock := sedStock.Value;
  sDescription := redDescription.Text;

  // Validate the product name
  if (not objValidate.IsValidString(sProductName)) or sProductName.IsEmpty then
  begin
    MessageDlg('Invalid product name. Please enter a valid name.', mtError,
      [mbOK], 0);
    exit;
  end;
  if not objValidate.IsValidLength(sProductName, 30) then
  begin
    MessageDlg
      ('Product name is too long. Please enter a name with 30 characters or less.',
      mtError, [mbOK], 0);
    exit;
  end;

  // Validate the unit price
  Val(edtUnitPrice.Text, rUnitPrice, iCode);
  RoundTo(rUnitPrice, -2);
  if (iCode > 0) or (rUnitPrice < 0) then
  begin
    MessageDlg('Enter a valid unit price', mtError, [mbOK], 0);
    exit;
  end;

  // Validate the description
  if (not objValidate.IsValidString(sDescription)) or sDescription.IsEmpty then
  begin
    MessageDlg('Invalid description. Please enter a valid description.',
      mtError, [mbOK], 0);
    exit;
  end;
  if not objValidate.IsValidLength(sDescription, 250) then
  begin
    MessageDlg
      ('Description is too long. Please enter a description with 250 characters or less.',
      mtError, [mbOK], 0);
    exit;
  end;

  // Get the current product's ID from tblProducts
  sProductID := dbmUGrow.tblProducts['ProductID'];

  // Update the  product in table
  try
    with dbmUGrow do
    begin
      tblProducts.Edit;
      tblProducts['ProductName'] := sProductName;
      tblProducts['UnitPrice'] := rUnitPrice;
      tblProducts['Stock'] := iStock;
      tblProducts['Description'] := sDescription;
      tblProducts.Post;
      tblProducts.Refresh;
    end;
  except
    begin
      MessageDlg('Error updating product, please try again',
        TMsgDlgType.mtError, [mbOK], 0);
      exit;
    end;
  end;

  MessageDlg('Product updated successfully.', mtInformation, [mbOK], 0);
  GetProducts;
end;

procedure TfrmSellerHome.btnViewReceiptsClick(Sender: TObject);
var
  iIndex: Integer;
  frmReceipts: TForm;
  redReceipts: TRichEdit;
  sCustomerID: string;
begin
  // Check that a customer has been selected
  if lstCustomers.ItemIndex = -1 then
  begin
    MessageDlg('Please select a customer', mtError, [mbOK], 0);
    exit;
  end;

  LoadReceipts;
  sCustomerID := LeftStr(lstCustomers.Items[lstCustomers.ItemIndex], 6);

  // Create the dialog box
  frmReceipts := TForm.Create(nil);
  frmReceipts.Width := 500;
  frmReceipts.Height := 600;
  frmReceipts.Caption := 'Receipts for CustomerID: ' + sCustomerID;

  redReceipts := TRichEdit.Create(frmReceipts);
  with redReceipts do
  begin
    Parent := frmReceipts;
    Align := alClient;
    ScrollBars := ssVertical;
    ReadOnly := true;
    // Display the receipts in neatly formatted columns
    Paragraph.TabCount := 1;
    Paragraph.Tab[0] := 100;
  end;

  // Add the receipts for the selected customer to the dialog box from newest to oldest
  for iIndex := high(arrReceipts) downto 0 do
  begin
    if arrReceipts[iIndex].getCustomerID = sCustomerID then
    begin
      redReceipts.Lines.Add(arrReceipts[iIndex].toString);
    end;
  end;

  // Return to the start of the rich edit
  redReceipts.SelStart := 0;
  redReceipts.Perform(EM_SCROLLCARET, 0, 0);

  frmReceipts.ShowModal;
  redReceipts.Free;
  frmReceipts.Free;
end;

procedure TfrmSellerHome.bttAddClick(Sender: TObject);
var
  sProductID, sProductName, sDescription, sUnitPrice, sStock: string;
  rUnitPrice: Real;
  iStock, iCode: Integer;
begin
  if not InputQuery('Add Product', 'Product Name:', sProductName) then
    exit;

  // Validate the product name
  if (not objValidate.IsValidString(sProductName)) OR sProductName.IsEmpty then
  begin
    MessageDlg('Invalid product name. Please enter a valid name.', mtError,
      [mbOK], 0);
    exit;
  end;
  if not objValidate.IsValidLength(sProductName, 30) then
  begin
    MessageDlg
      ('Product name is too long. Please enter a name with 30 characters or less.',
      mtError, [mbOK], 0);
    exit;
  end;

  if not InputQuery('Add Product', 'Unit Price:', sUnitPrice) then
    exit;

  // Validate the unit price
  Val(sUnitPrice, rUnitPrice, iCode);
  RoundTo(rUnitPrice, -2);
  if (iCode > 0) or (rUnitPrice < 0) then
  begin
    MessageDlg('Enter a valid unit price', mtError, [mbOK], 0);
    exit;
  end;

  if not InputQuery('Add Product', 'Stock:', sStock) then
    exit;

  // Validate the stock amount
  Val(sStock, iStock, iCode);
  if (iCode > 0) or (iStock < 0) then
  begin
    MessageDlg('Enter a valid stock amount', mtError, [mbOK], 0);
    exit;
  end;

  if not InputQuery('Add Product', 'Description:', sDescription) then
    exit;

  // Validate the description
  if not objValidate.IsValidString(sDescription) OR sDescription.IsEmpty then
  begin
    MessageDlg('Invalid description. Please enter a valid description.',
      mtError, [mbOK], 0);
    exit;
  end;
  if not objValidate.IsValidLength(sDescription, 250) then
  begin
    MessageDlg
      ('Description is too long. Please enter a description with 250 characters or less.',
      mtError, [mbOK], 0);
    exit;
  end;

  // Generate a new ProductID
  Randomize;
  repeat
    // ProductID consists of the first 3 letters of the product name and 3 random digits
    sProductID := Uppercase(Copy(sProductName, 1, 3)) +
      IntToStr(RandomRange(100, 1000));
  until objValidate.IsUnique(sProductID, dbmUGrow.tblProducts, 'ProductID');

  // Add the product to the table
  try
    with dbmUGrow do
    begin
      tblProducts.Insert;
      tblProducts['ProductID'] := sProductID;
      tblProducts['ProductName'] := sProductName;
      tblProducts['UnitPrice'] := rUnitPrice;
      tblProducts['Stock'] := iStock;
      tblProducts['Description'] := sDescription;
      tblProducts.Post;
      tblProducts.Refresh;
    end;
  except
    begin
      MessageDlg('Error adding product, please try again', TMsgDlgType.mtError,
        [mbOK], 0);
      exit;
    end;
  end;

  MessageDlg
    ('Product added successfully. Please add a product image to the "Product_Images" folder with the ProductID as the file name.',
    mtInformation, [mbOK], 0);
  GetProducts;
end;

procedure TfrmSellerHome.bttDeleteClick(Sender: TObject);
begin
  if MessageDlg('Are you sure you want delete this product?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
  begin
    with dbmUGrow do
    begin
      try
        // Try to delete the product
        tblProducts.Delete;
        tblProducts.Refresh;
      except
        on E: Exception do
        begin
          // Show an error message if the deletion failed
          MessageDlg
            ('Product cannot be deleted as it is part of one or more orders',
            mtError, [mbOK], 0);
        end;
      end;
    end;
  end;
end;

procedure TfrmSellerHome.bttLogoutClick(Sender: TObject);
begin
  frmSellerHome.Hide;
end;

procedure TfrmSellerHome.bttSaveClick(Sender: TObject);
var
  dlgSavePlan: TSaveDialog;
begin
  try
    // Create the 'save as' dialog
    dlgSavePlan := TSaveDialog.Create(nil);
    dlgSavePlan.Filter := 'Bitmap files (*.bmp)|*.bmp|All files (*.*)|*.*';
    if dlgSavePlan.Execute then
    begin
      if dlgSavePlan.FileName <> '' then
      begin
        // Ensure that the file extension is .bmp
        if ExtractFileExt(dlgSavePlan.FileName) <> '.bmp' then
        begin
          dlgSavePlan.FileName := ChangeFileExt(dlgSavePlan.FileName, '.bmp');
        end;
        // Save it in the selected location with the name specified by the user
        chtSales.SaveToBitmapFile(dlgSavePlan.FileName);
        MessageDlg('Graph saved successfully', mtInformation, [mbOK], 0);
      end
      else
      begin
        // Display an error message if no file name was provided
        MessageDlg('No file name provided.', mtError, [mbOK], 0);
      end;
    end;
  finally
    dlgSavePlan.Free;
  end;

end;

procedure TfrmSellerHome.btnRefreshClick(Sender: TObject);
begin
  chtSales.Series[0].Clear;
  // Determine which graph is currently being displayed by the caption of the button, then update the graph
  if btnChangeGraph.Caption = 'See Sales Per Day' then
  begin
    CreateAvgOrderPriceChart;
  end
  else if btnChangeGraph.Caption = 'See Average Order Price' then
  begin
    CreateSalesPerDayChart;
  end;
end;

procedure TfrmSellerHome.cmbSortChange(Sender: TObject);
begin
  dbmUGrow.tblProducts.Sort := cmbSort.Text;
end;

procedure TfrmSellerHome.CreateAvgOrderPriceChart;
var
  sStartDate, sEndDate: string;
begin
  // Extract the start and end date in the format required for the SQL
  sStartDate := Formatdatetime('mm/dd/yyyy', dtpFromDate.date);
  sEndDate := Formatdatetime('mm/dd/yyyy', dtpToDate.date);
  if CompareDate(dtpToDate.date, dtpFromDate.date) < 0 then
  begin
    MessageDlg('Start date cannot be after the end date', mtError, [mbOK], 0);
    exit;
  end;

  // Prepare the chart
  // NOTE: all other properties (including series, styles and fonts) have been set manually using the object inspector
  chtSales.Title.Text.Text := 'Average Order Price Per Day';
  chtSales.LeftAxis.Title.Text := 'Average Order Price (R)';
  chtSales.Series[0].Clear;

  // Create a query to find the average order price during the specified period
  with dbmUGrow do
  begin
    tblOrders.Filtered := false;
    tblOrderProd.Filtered := false;
    tblProducts.Filtered := false;
    qryAvgOrderPrice.Active := false;
    qryAvgOrderPrice.SQL.Text :=
      'SELECT OrderDate, AVG(total_price) AS AvgOrderPrice FROM (SELECT OrderID, SUM(UnitPrice * Quantity) AS total_price FROM tblOrderProd '
      + 'INNER JOIN tblProducts ON tblOrderProd.ProductID = tblProducts.ProductID GROUP BY OrderID) AS order_totals '
      + 'INNER JOIN tblOrders ON order_totals.OrderID = tblOrders.OrderID GROUP BY OrderDate '
      + 'HAVING OrderDate BETWEEN #' + sStartDate + '# AND #' +
      sEndDate + '#; ';
    qryAvgOrderPrice.Active := true;

    // Add the contents of the query to the chart
    qryAvgOrderPrice.first;
    while not qryAvgOrderPrice.Eof do
    begin
      chtSales.Series[0].Add(qryAvgOrderPrice['AvgOrderPrice'],
        qryAvgOrderPrice['OrderDate']);
      qryAvgOrderPrice.Next;
    end;
  end;

end;

procedure TfrmSellerHome.CreateSalesPerDayChart;
var
  sProductID, sStartDate, sEndDate: string;
begin
  // Extract the start and end date
  sStartDate := Formatdatetime('mm/dd/yyyy', dtpFromDate.date);
  sEndDate := Formatdatetime('mm/dd/yyyy', dtpToDate.date);
  if CompareDate(dtpToDate.date, dtpFromDate.date) < 0 then
  begin
    MessageDlg('Start date cannot be after the end date', mtError, [mbOK], 0);
    exit;
  end;

  // Extract the ProductID
  if lstProducts.ItemIndex > -1 then
  begin
    sProductID := LeftStr(lstProducts.Items[lstProducts.ItemIndex], 6);
  end
  else
    exit;

  // Prepare the chart
  // NOTE: all other properties (including series, styles and fonts) have been set manually using the object inspector
  chtSales.Title.Text.Text := 'Total Sales Per Day';
  chtSales.LeftAxis.Title.Text := 'Total Sales (R)';
  chtSales.Series[0].Clear;

  // Create a query to find the sales per day for the specified product
  with dbmUGrow do
  begin
    tblOrders.Filtered := false;
    tblOrderProd.Filtered := false;
    tblProducts.Filtered := false;

    qrySalesPerDay.Active := false;
    qrySalesPerDay.SQL.Text :=
      'SELECT tblOrders.OrderDate, Sum([tblProducts].[UnitPrice]*[tblOrderProd].[Quantity]) AS TotalSales '
      + 'FROM tblProducts INNER JOIN (tblOrders INNER JOIN tblOrderProd ON tblOrders.OrderID = tblOrderProd.OrderID) ON tblProducts.ProductID = tblOrderProd.ProductID '
      + 'WHERE (((tblOrderProd.ProductID)="' + sProductID + '")) ' +
      'GROUP BY tblOrders.OrderDate ' +
      'HAVING (((tblOrders.OrderDate) Between #' + sStartDate + '# AND #' +
      sEndDate + '#));';
    qrySalesPerDay.Active := true;

    // Add the contents of the query to the chart
    qrySalesPerDay.first;
    while not qrySalesPerDay.Eof do
    begin
      chtSales.Series[0].Add(qrySalesPerDay['TotalSales'],
        qrySalesPerDay['OrderDate']);
      qrySalesPerDay.Next;
    end;
  end;
end;

procedure TfrmSellerHome.dbgOrdersCellClick(Column: TColumn);
var
  sOrderID, sProducts: string;
begin
  sProducts := '';
  with dbmUGrow do
  begin
    // Ensure that the DB grid is not empty
    if dbgOrders.DataSource = dscCustomerOrders then
    begin
      // Extract and locate the OrderID
      sOrderID := qryCustomerOrders['OrderID'];
      tblOrderProd.Locate('OrderID', sOrderID, []);
      // For each entry with the OrderID, add it to the string
      while tblOrderProd['OrderID'] = sOrderID do
      begin
        sProducts := sProducts + tblOrderProd['ProductID'] + sLineBreak;
        tblOrderProd.Next;
      end;
      // Display the string of ProductIDs
      MessageDlg(sProducts, TMsgDlgType.mtInformation, [mbOK], 0);
    end;
  end;
end;

procedure TfrmSellerHome.dbgProductsCellClick(Column: TColumn);
begin
  LoadProductDetails;
end;

procedure TfrmSellerHome.dbgProductsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT] then
  begin
    if not dbmUGrow.tblProducts.Eof then
      LoadProductDetails;
  end;
end;

procedure TfrmSellerHome.dbgProductsMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
 edtName.Clear;
 edtUnitPrice.Clear;
 redDescription.Clear;
 sedStock.Value := 0;
end;

procedure TfrmSellerHome.FormCreate(Sender: TObject);
begin
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
end;

procedure TfrmSellerHome.FormShow(Sender: TObject);
begin
  // Load the required information
  GetProducts;
  LoadProductDetails;
  GetCustomers;
  GetProductList;
  // Set the default values of components
  pgcSeller.TabIndex := 0;
  lstProducts.ItemIndex := 0;
  dbmUGrow.tblProducts.GetFieldNames(cmbSort.Items);
  dtpToDate.date := date;
  dtpFromDate.date := date - 7;
  // Create the chart
  CreateSalesPerDayChart;
end;

procedure TfrmSellerHome.LoadProductDetails;
begin
  with dbmUGrow do
  begin
    if not tblProducts.IsEmpty then
    begin
      // Load the selected product's details into the components
      edtName.Text := tblProducts['ProductName'];
      edtUnitPrice.Text := FloatToStrF(tblProducts['UnitPrice'], ffFixed, 8, 2);
      redDescription.Text := tblProducts['Description'];
      sedStock.Value := tblProducts['Stock'];
      sedStock.MinValue := 0;
      sedStock.MaxValue := 9999999;
    end;
  end;
end;

procedure TfrmSellerHome.LoadReceipts;
var
  iIndex: Integer;
  sReceiptList: TStringList;
begin
  // Check that the receipts file exists
  if not FileExists('Receipts.txt') then
  begin
    MessageDlg('Receipts file cannot be found', mtError, [mbOK], 0);
    exit;
  end;

  // Check that the file is not empty
  if not objValidate.IsFileEmpty('Receipts.txt') then
  begin
    sReceiptList := TStringList.Create;
    sReceiptList.LoadFromFile('Receipts.txt');
  end
  else
  begin
    MessageDlg('No receipts on record', mtError, [mbOK], 0);
    exit;
  end;

  try
    // Check that there are receipts stored
    if sReceiptList.Count > 0 then
    begin
      // Set the length of the array of objects to the number of receipts
      SetLength(arrReceipts, sReceiptList.Count);

      for iIndex := 0 to high(arrReceipts) do
      begin
        if not sReceiptList[iIndex].IsEmpty then
          arrReceipts[iIndex] := TReceipt.Create(sReceiptList[iIndex]);
      end;
    end;
  except
    MessageDlg('Could not load receipts', TMsgDlgType.mtError, [mbOK], 0);
  end;

  sReceiptList.Free;
end;

procedure TfrmSellerHome.lstCustomersClick(Sender: TObject);
begin
  if lstCustomers.ItemIndex > -1 then
    GetOrders;
end;

procedure TfrmSellerHome.lstProductsClick(Sender: TObject);
begin
  CreateSalesPerDayChart;
end;

procedure TfrmSellerHome.GetCustomers;
begin
  lstCustomers.Clear;

  with dbmUGrow do
  begin
    // Loop through all the customers in the tblCustomers table
    tblCustomers.first;
    while not tblCustomers.Eof do
    begin
      // Add the customer name to the list box
      lstCustomers.Items.Add(tblCustomers['CustomerID'] + ': ' + tblCustomers
        ['Email']);
      tblCustomers.Next;
    end;
  end;
end;

procedure TfrmSellerHome.GetOrders;
var
  sCustomerID: string;
begin
  // Extract the CustomerID from the list box
  sCustomerID := LeftStr(lstCustomers.Items[lstCustomers.ItemIndex], 6);

  with dbmUGrow do
  begin
    // Run a query to get the orders belonging to the selected user
    qryCustomerOrders.SQL.Clear;
    qryCustomerOrders.SQL.Add
      ('SELECT tblOrders.OrderID, tblOrders.OrderDate, Sum(tblProducts.UnitPrice*tblOrderProd.Quantity) AS TotalAmount');
    qryCustomerOrders.SQL.Add('FROM tblProducts, tblOrders, tblOrderProd');
    qryCustomerOrders.SQL.Add('WHERE tblOrders.OrderID = tblOrderProd.OrderID');
    qryCustomerOrders.SQL.Add
      ('AND tblProducts.ProductID = tblOrderProd.ProductID');
    qryCustomerOrders.SQL.Add('AND tblOrders.CustomerID = "' +
      sCustomerID + '"');
    qryCustomerOrders.SQL.Add
      ('GROUP BY tblOrders.OrderID, tblOrders.OrderDate;');
    qryCustomerOrders.Open;
    dbgOrders.DataSource := dscCustomerOrders;
    // Set the format of the ItemTotal to currency
    TFloatField(qryCustomerOrders.FieldByName('TotalAmount')).DisplayFormat
      := 'R0.00';

    tblCustomers.Locate('CustomerID', sCustomerID, []);
    edtBalance.Text := FloatToStrF(tblCustomers['OutstandingBalance'],
      ffCurrency, 8, 2);

    // Sort the query by OrderDate
    qryCustomerOrders.Sort := 'OrderDate DESC';
  end;

  dbgOrders.Columns[0].Width := 125;
  dbgOrders.Columns[1].Width := 125;
  dbgOrders.Columns[2].Width := 125;
end;

procedure TfrmSellerHome.GetProductList;
begin
  lstProducts.Clear;

  with dbmUGrow do
  begin
    // Loop through all the products in the tblProducts table
    tblProducts.first;
    while not tblProducts.Eof do
    begin
      // Add the customer name to the list box
      lstProducts.Items.Add(tblProducts['ProductID'] + ': ' + tblProducts
        ['ProductName']);
      tblProducts.Next;
    end;
    tblProducts.first;
  end;
end;

procedure TfrmSellerHome.GetProducts;
begin
  // Prepare the DB grid of products
  dbgProducts.DataSource := dbmUGrow.dscProducts;
  TFloatField(dbmUGrow.tblProducts.FieldByName('UnitPrice')).DisplayFormat
    := 'R0.00';
  dbgProducts.Columns[2].Width := 75;
  dbgProducts.Columns[3].Width := 75;
  sbxSearchName.Text := '';
end;

procedure TfrmSellerHome.lblHelpClick(Sender: TObject);
begin
  frmLogin.ShowHelp;
end;

procedure TfrmSellerHome.sbxSearchNameInvokeSearch(Sender: TObject);
var
  iField: Integer;
  Field: TField;
  SearchResult: TBookmark;
begin
  dbmUGrow.tblProducts.first;
  while not dbmUGrow.tblProducts.Eof do
  begin
    // Loop through all fields and check if they contain the search string
    for iField := 0 to dbmUGrow.tblProducts.Fields.Count - 1 do
    begin
      Field := dbmUGrow.tblProducts.Fields[iField];
      if ContainsText(Field.AsString, sbxSearchName.Text) then
      begin
        // Go to the result in the DBGrid
        SearchResult := dbmUGrow.tblProducts.GetBookmark;
        dbmUGrow.tblProducts.GotoBookmark(SearchResult);
        dbgProducts.SelectedField := Field;
        dbgProducts.SelectedRows.CurrentRowSelected := true;
        dbmUGrow.tblProducts.FreeBookmark(SearchResult);
        exit;
      end;
    end;
    dbmUGrow.tblProducts.Next;
  end;
  MessageDlg('Not Found', mtError, [mbOK], 0);
end;

end.
