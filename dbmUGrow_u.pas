unit dbmUGrow_u;

interface

uses
  System.SysUtils, System.Classes, ADODB, DB;

type
  TdbmUGrow = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    conUGrowDB: TADOConnection;
    tblCustomers, tblOrders, tblOrderProd, tblProducts, tblCart: TADOTable;
    qryCart_NoID, qryCartTotal, qryCustomerOrders, qrySalesPerDay, qryAvgOrderPrice: TADOQuery;
    dscCart_NoID, dscCustomerOrders, dscProducts: TDataSource;
    procedure ClearCart;
  end;

var
  dbmUGrow: TdbmUGrow;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TdbmUGrow.ClearCart;
// Loop through the cart and delete the records
begin
  tblCart.First;
  while not tblCart.Eof do
  begin
    tblCart.Delete;
    tblCart.Next;
  end;
end;

procedure TdbmUGrow.DataModuleCreate(Sender: TObject);
begin
  // Create the various components required for the database connection
  conUGrowDB := TADOConnection.Create(dbmUGrow);

  tblCustomers := TADOTable.Create(dbmUGrow);
  tblOrders := TADOTable.Create(dbmUGrow);
  tblOrderProd := TADOTable.Create(dbmUGrow);
  tblProducts := TADOTable.Create(dbmUGrow);
  tblCart := TADOTable.Create(dbmUGrow);

  qryCart_NoID := TADOQuery.Create(dbmUGrow);
  qryCartTotal := TADOQuery.Create(dbmUGrow);
  qryCustomerOrders := TADOQuery.Create(dbmUGrow);
  qrySalesPerDay := TADOQuery.Create(dbmUGrow);
  qryAvgOrderPrice := TADOQuery.Create(dbmUGrow);

  dscCart_NoID := TDataSource.Create(dbmUGrow);
  dscCustomerOrders := TDataSource.Create(dbmUGrow);
  dscProducts := TDataSource.Create(dbmUGrow);

  // NOTE: database number must be 'UGrow_Database.mdb'
  conUGrowDB.Close;
  conUGrowDB.ConnectionString :=
    'Provider=Microsoft.Jet.OLEDB.4.0;Data Source =' +
    ExtractFilePath(ParamStr(0)) + 'UGrow_Database.mdb' +
    ';Persist Security Info = False';
  conUGrowDB.LoginPrompt := false;
  conUGrowDB.Open;

  // Connect the ADO tables to the database
  tblCustomers.Connection := conUGrowDB;
  tblCustomers.TableName := 'tblCustomers';

  tblOrders.Connection := conUGrowDB;
  tblOrders.TableName := 'tblOrders';

  tblOrderProd.Connection := conUGrowDB;
  tblOrderProd.TableName := 'tblOrderProd';

  tblProducts.Connection := conUGrowDB;
  tblProducts.TableName := 'tblProducts';

  tblCart.Connection := conUGrowDB;
  tblCart.TableName := 'tblCart';

  // Connect the ADO queries to the database
  qryCart_NoID.Connection := conUGrowDB;
  qryCartTotal.Connection := conUGrowDB;
  qryCustomerOrders.Connection := conUGrowDB;
  qrySalesPerDay.Connection := conUGrowDB;
  qryAvgOrderPrice.Connection := conUGrowDB;

  // Connect the datasources to their relavent queries
  dscCart_NoID.DataSet := qryCart_NoID;
  dscCustomerOrders.DataSet := qryCustomerOrders;
  dscProducts.DataSet := tblProducts;

  // Set the primary keys
  tblCustomers.IndexFieldNames := 'CustomerID';
  tblOrders.IndexFieldNames := 'OrderID';
  tblOrderProd.IndexFieldNames := 'OrderProdID';
  tblProducts.IndexFieldNames := 'ProductID';
  tblCart.IndexFieldNames := 'ItemID';

  // Open the tables
  tblCustomers.Open;
  tblOrders.Open;
  tblOrderProd.Open;
  tblProducts.Open;
  tblCart.Open;

  // Clear the cart
  ClearCart;
end;

procedure TdbmUGrow.DataModuleDestroy(Sender: TObject);
begin
  ClearCart;
end;

end.
