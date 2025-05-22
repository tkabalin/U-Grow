unit frmCreateAccount_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  strutils,
  Vcl.Imaging.jpeg, math, Vcl.Mask, System.Actions, Vcl.ActnList, Vcl.ExtActns,
  Vcl.Imaging.pngimage, System.UITypes, Vcl.WinXPickers;

type
  TfrmCreateAccount = class(TForm)
    lblCreatePassword: TLabel;
    edtPassword: TEdit;
    edtEmail: TEdit;
    lblEnterEmail: TLabel;
    btnCreateAccount: TButton;
    bttHidePassword: TBitBtn;
    bttShowPassword: TBitBtn;
    bttBack: TBitBtn;
    imgForest: TImage;
    lblCreateAccount: TLabel;
    lblPasswordValid: TLabel;
    imgLogo: TImage;
    edtFirstName: TEdit;
    edtLastName: TEdit;
    lblFirstName: TLabel;
    lblLastName: TLabel;
    dtpDateOfBirth: TDatePicker;
    lblDateOfBirth: TLabel;
    lblHelp: TLabel;
    shpHelp: TShape;
    procedure bttShowPasswordClick(Sender: TObject);
    procedure bttHidePasswordClick(Sender: TObject);
    procedure bttBackClick(Sender: TObject);
    procedure btnCreateAccountClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  frmCreateAccount: TfrmCreateAccount;

implementation

uses
  frmCustomerHome_u, dbmUGrow_u, clsValidation_u, frmSellerHome_u,
  frmProductDetails_u, frmCart_u, frmLogin_u;

var
  objValidate: TValidation;

{$R *.dfm}

procedure TfrmCreateAccount.bttHidePasswordClick(Sender: TObject);
begin
  // Hide the password
  edtPassword.PasswordChar := '*';
  bttShowPassword.Visible := true;
  bttHidePassword.Visible := false;
end;

procedure TfrmCreateAccount.bttShowPasswordClick(Sender: TObject);
begin
  // Show the password
  edtPassword.PasswordChar := #0;
  bttShowPassword.Visible := false;
  bttHidePassword.Visible := true;
end;

procedure TfrmCreateAccount.FormCreate(Sender: TObject);
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

procedure TfrmCreateAccount.lblHelpClick(Sender: TObject);
begin
  frmLogin.ShowHelp;
end;

procedure TfrmCreateAccount.btnCreateAccountClick(Sender: TObject);
var
  sFirstName, sLastName, sPassword, sEmail, sCustomerID: string;
  dtDateOfBirth: TDateTime;
begin
  // Extract the entered information
  sEmail := Lowercase(edtEmail.Text);
  sFirstName := edtFirstName.Text;
  sLastName := edtLastName.Text;
  dtDateOfBirth := dtpDateOfBirth.Date;
  sPassword := edtPassword.Text;

  // Check that the email is valid
  if not objValidate.IsValidEmail(sEmail) then
  begin
    MessageDlg('Enter a valid email', mtError, [mbOK], 0);
    exit;
  end;

  // Check that the email is not already registered
  if not objValidate.IsUnique(sEmail, dbmUGrow.tblCustomers, 'Email') then
  begin
    MessageDlg('Email address already registered', mtError, [mbOK], 0);
    exit;
  end;

  // Check that the first and last names are valid
  if not objValidate.IsValidName(sFirstName, sLastName, 30) then
  begin
    MessageDlg('Enter a valid first and last name', mtError, [mbOK], 0);
    exit;
  end;

  // Check that the age is valid
  // Do not need to perform a data type check due to the component used
  if not objValidate.IsValidAge(dtDateOfBirth, 13) then
  begin
    MessageDlg('Age must be greater than 13', mtError, [mbOK], 0);
    exit;
  end;

  // Check that the password is not blank, is not too long and only contains valid characters
  if (sPassword.IsEmpty) OR (not objValidate.IsValidLength(sPassword, 128)) OR
    (not objValidate.IsValidString(sPassword)) then
  begin
    MessageDlg('Enter a valid password', mtError, [mbOK], 0);
    exit;
  end;

  // Add the customer to the database
  with dbmUGrow do
  begin
    { Create a CustomerID from the first letter of the first name, first 2 letters of the last name
      and 3 random numbers }
    Randomize;
    repeat
      sCustomerID := UpperCase(Copy(sFirstName, 1, 1)) +
        UpperCase(Copy(sLastName, 1, 2)) + IntToStr(RandomRange(100, 1000));
    until objValidate.IsUnique(sCustomerID, dbmUGrow.tblCustomers,
      'CustomerID');

    // Insert a new record and set the fields to the correct values
    try
      tblCustomers.Insert;
      tblCustomers['CustomerID'] := sCustomerID;
      tblCustomers['FirstName'] := sFirstName;
      tblCustomers['LastName'] := sLastName;
      tblCustomers['DateOfBirth'] := dtDateOfBirth;
      tblCustomers['Email'] := sEmail;
      tblCustomers['Password'] := sPassword;
      // The customer has not yet made any purchases, so the outstanding balance is R0
      tblCustomers['OutstandingBalance'] := 0;
      tblCustomers.Post;
    except
      begin
        MessageDlg('Could not add account to the database. Please try again',
          TMsgDlgType.mtError, [mbOK], 0);
        exit;
      end;
    end;
  end;

  // Tell the program the CustomerID of the current user
  frmLogin.sCustomerID := sCustomerID;
  MessageDlg('Account Created, Welcome to U-Grow!', mtInformation, [mbOK], 0);

  // Clear the components on the create account form
  edtEmail.Clear;
  edtPassword.Clear;
  edtFirstName.Clear;
  edtLastName.Clear;
  dtpDateOfBirth.Date := Date;

  // Open the program
  frmCustomerHome.show;
  frmSellerHome.hide;
  frmCreateAccount.hide;
  frmProductDetails.hide;
  frmCart.hide;

end;

procedure TfrmCreateAccount.bttBackClick(Sender: TObject);
begin
  frmCreateAccount.hide;
end;

end.
