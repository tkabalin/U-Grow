program UGrow_p;

uses
  Vcl.Forms,
  frmLogin_u in 'frmLogin_u.pas' {frmLogin},
  frmCreateAccount_u in 'frmCreateAccount_u.pas' {frmCreateAccount},
  Vcl.Themes,
  Vcl.Styles,
  frmSplashScreen_u in 'frmSplashScreen_u.pas' {frmSplashScreen},
  frmCustomerHome_u in 'frmCustomerHome_u.pas' {frmCustomerHome},
  frmSellerHome_u in 'frmSellerHome_u.pas' {frmSellerHome},
  frmProductDetails_u in 'frmProductDetails_u.pas' {frmProductDetails},
  frmCart_u in 'frmCart_u.pas' {frmCart},
  dbmUGrow_u in 'dbmUGrow_u.pas' {dbmUGrow: TDataModule},
  clsValidation_u in 'clsValidation_u.pas',
  clsReceipt_u in 'clsReceipt_u.pas';

{$R *.res}

begin
  Application.Initialize;
  // Create and display the splash screen
  frmSplashScreen := TfrmSplashScreen.Create(nil);
  frmSplashScreen.ShowModal;
  // Hide the splash screen
  frmSplashScreen.Free;
  frmSplashScreen := nil;
  // Create the rest of the forms
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10');
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmCreateAccount, frmCreateAccount);
  Application.CreateForm(TfrmCustomerHome, frmCustomerHome);
  Application.CreateForm(TfrmSellerHome, frmSellerHome);
  Application.CreateForm(TfrmProductDetails, frmProductDetails);
  Application.CreateForm(TfrmCart, frmCart);
  Application.CreateForm(TdbmUGrow, dbmUGrow);
  Application.Run;
end.
