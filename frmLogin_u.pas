unit frmLogin_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Math, Vcl.Imaging.jpeg,
  System.ImageList, Vcl.ImgList, Vcl.ComCtrls, strUtils, Vcl.Imaging.pngimage,
  System.UITypes, ShellAPI, SHDocVw, Vcl.OleCtrls;

type
  TfrmLogin = class(TForm)
    edtEmail: TEdit;
    btnCustLogin: TButton;
    bttClose: TBitBtn;
    lblEmail: TLabel;
    lblNoAccount: TLabel;
    lblCreateAccount: TLabel;
    imgForest: TImage;
    lblLogin: TLabel;
    imgLogo: TImage;
    btnSellLog: TButton;
    edtPassword: TEdit;
    lblPassword: TLabel;
    bttShow: TBitBtn;
    bttHide: TBitBtn;
    lblHelp: TLabel;
    shpHelp: TShape;
    procedure lblCreateAccountClick(Sender: TObject);
    procedure bttCloseClick(Sender: TObject);
    procedure bttShowClick(Sender: TObject);
    procedure bttHideClick(Sender: TObject);
    procedure btnCustLoginClick(Sender: TObject);
    procedure btnSellLogClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblHelpClick(Sender: TObject);
    procedure ShowHelp;

  private
    { Private declarations }
  public
    { Public declarations }
    sCustomerID: string;

  end;

var
  frmLogin: TfrmLogin;

implementation

uses
  frmCreateAccount_u, frmCustomerHome_u, frmSellerHome_u, dbmUGrow_u,
  clsValidation_u, frmCart_u, frmProductDetails_u;

{$R *.dfm}

procedure TfrmLogin.btnCustLoginClick(Sender: TObject);
var
  sEmail, sPassword: string;
begin
  // Extract the email and password
  sEmail := LowerCase(edtEmail.Text);
  sPassword := edtPassword.Text;

  // Check an email address has been inputted
  if sEmail.IsEmpty then
  begin
    MessageDlg('Enter an email address', mtError, [mbOK], 0);
    exit;
  end;

  // Check an password has been inputted
  if sPassword.IsEmpty then
  begin
    MessageDlg('Enter a password', mtError, [mbOK], 0);
    exit;
  end;

  // Check if the email address exists in the 'customers' table of the database
  if not dbmUGrow.tblCustomers.Locate('Email', sEmail, []) then
  begin
    MessageDlg('Email address is not registered', mtError, [mbOK], 0);
    exit;
  end;

  // Check if the password is correct
  if dbmUGrow.tblCustomers['Password'] = sPassword then
  begin
    // Clear the form
    edtEmail.Clear;
    edtPassword.Clear;
    dbmUGrow.ClearCart;

    // Record which customer has logged in
    sCustomerID := dbmUGrow.tblCustomers['CustomerID'];

    // Open the application
    frmCustomerHome.show;
    frmSellerHome.hide;
    frmCreateAccount.hide;
    frmProductDetails.hide;
    frmCart.hide;
  end
  else
  begin
    MessageDlg('Password incorrect', mtError, [mbOK], 0);
  end;

end;

procedure TfrmLogin.btnSellLogClick(Sender: TObject);
var
  sUsername, sPassword, sLine: string;
  tLoginInfo: TextFile;
begin
  // Extract the username and password
  sUsername := edtEmail.Text;
  sPassword := edtPassword.Text;

  // Check if the username is empty
  if sUsername.IsEmpty then
  begin
    MessageDlg('Enter a username', mtError, [mbOK], 0);
    exit;
  end;

  // Check if the password is empty
  if sPassword.IsEmpty then
  begin
    MessageDlg('Enter a password', mtError, [mbOK], 0);
    exit;
  end;

  // Check if the login info is missing
  if not FileExists('Seller_Logins.txt') then
  begin
    MessageDlg('Login info missing', mtError, [mbOK], 0);
    exit;
  end;

  // Open the login info text file for reading
  AssignFile(tLoginInfo, 'Seller_Logins.txt');
  Reset(tLoginInfo);

  // Loop through the text file to check each line
  while not Eof(tLoginInfo) do
  begin
    Readln(tLoginInfo, sLine);
    // Check if email and password are both correct
    if (sLine = sUsername + '#' + sPassword) then
    begin
      // If login detail were correct, clear the edit boxes and open program
      edtEmail.Clear;
      edtPassword.Clear;
      CloseFile(tLoginInfo);

      frmSellerHome.show;
      frmCustomerHome.hide;
      frmProductDetails.hide;
      frmCart.hide;
      frmCreateAccount.hide;
      exit;
    end
    // Check if the username has been registered, but password is incorrect
    else if ContainsStr(sLine, sUsername + '#') then
    begin
      MessageDlg('Password incorrect', mtError, [mbOK], 0);
      CloseFile(tLoginInfo);
      exit;
    end;
  end; // Once the whole text file has been checked,
  // Presume that the username does not exist
  MessageDlg('Username does not exist', mtError, [mbOK], 0);
  CloseFile(tLoginInfo);
end;

procedure TfrmLogin.bttCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmLogin.bttHideClick(Sender: TObject);
begin
  // Hide the password
  edtPassword.PasswordChar := '*';
  bttShow.Visible := true;
  bttHide.Visible := false;
end;

procedure TfrmLogin.bttShowClick(Sender: TObject);
begin
  // Show the password
  edtPassword.PasswordChar := #0;
  bttShow.Visible := false;
  bttHide.Visible := true;
end;


procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  try
    imgForest.Picture.LoadFromFile('Decorative_Images\Forest.jpeg');
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

procedure TfrmLogin.lblHelpClick(Sender: TObject);
begin
  ShowHelp;
end;


procedure TfrmLogin.ShowHelp;
var
  sHTMLFile: string;
begin
  sHTMLFile := 'U-GROW - Project Notes (Web Page).htm';
  ShellExecute(0, 'open', PChar(sHTMLFile), nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmLogin.lblCreateAccountClick(Sender: TObject);
begin
  frmCreateAccount.show;
end;

end.
