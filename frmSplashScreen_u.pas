unit frmSplashScreen_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.ComCtrls, Vcl.StdCtrls;

type
  TfrmSplashScreen = class(TForm)
    tmrShowSplash: TTimer;
    imgSplashScreen: TImage;
    tmrLoading: TTimer;
    shpLoadingBar: TShape;
    lblLoading: TLabel;
    tmrLoadingCaption: TTimer;
    procedure tmrShowSplashTimer(Sender: TObject);
    procedure tmrLoadingTimer(Sender: TObject);
    procedure tmrLoadingCaptionTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSplashScreen: TfrmSplashScreen;

implementation

{$R *.dfm}

procedure TfrmSplashScreen.FormCreate(Sender: TObject);
begin
  imgSplashScreen.Picture.LoadFromFile('UGrow_SplashScreen.png');
end;

procedure TfrmSplashScreen.tmrLoadingCaptionTimer(Sender: TObject);
begin
  // Animate lblLoading
  if lblLoading.Caption = 'Loading .' then
  begin
    lblLoading.Caption := 'Loading . .';
  end
  else if lblLoading.Caption = 'Loading . .' then
  begin
    lblLoading.Caption := 'Loading . . .';
  end
  else if lblLoading.Caption = 'Loading . . .' then
  begin
    lblLoading.Caption := 'Loading .';
  end;
end;

procedure TfrmSplashScreen.tmrLoadingTimer(Sender: TObject);
begin
  // Progress the loading bar until it reaches the end
  if shpLoadingBar.Width < 500 then
  begin
    shpLoadingBar.Width := shpLoadingBar.Width + 7;
  end
  else
    lblLoading.Caption := 'Done!';
end;

procedure TfrmSplashScreen.tmrShowSplashTimer(Sender: TObject);
begin
  // Close the form when the animation is done
  Close;
end;

end.
