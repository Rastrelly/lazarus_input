unit ulazinput;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, LCLType,
  DateUtils;

type

  uent = record
    x,y:real;
    rx,ry:integer;
    kx,ky:integer;
    rkx,rky:real;
    spd:real;
    r:real;
    rr:integer;
  end;

  uinp = record
    kx,ky:integer;
  end;


  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    Timer1: TTimer;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    function ktoang(kx,ky:integer):real;
    procedure render;
    procedure runsim;
    procedure initstartstate;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  iw, ih:integer;

  plr:uent;
  inps:uinp;

  ts1,ts2:TDateTime;
  dt:real;

  lexit:boolean=false;

implementation

{$R *.lfm}

{ TForm1 }

procedure tform1.initstartstate;
begin
  //init plr entuty
  plr.kx:=0;
  plr.ky:=0;
  plr.x:=iw/2;
  plr.y:=ih/2;
  plr.r:=20;
  plr.rr:=round(plr.r);
  plr.spd:=100;

  //init input entity
  inps.kx:=0;
  inps.ky:=0;

  //time manager
  ts1:=Now; ts2:=Now; dt:=0;
end;

function tform1.ktoang(kx,ky:integer):real;
begin
  if ((kx=0) and (ky=0)) then result:=-1;
  if ((kx=1) and (ky=0)) then result:=0;
  if ((kx=1) and (ky=1)) then result:=45;
  if ((kx=0) and (ky=1)) then result:=90;
  if ((kx=-1) and (ky=1)) then result:=135;
  if ((kx=-1) and (ky=0)) then result:=180;
  if ((kx=-1) and (ky=-1)) then result:=225;
  if ((kx=0) and (ky=-1)) then result:=270;
  if ((kx=1) and (ky=-1)) then result:=315;
end;

procedure tform1.render;
var rbmp:TBitmap;
begin

  rbmp:=TBitmap.Create;
  rbmp.Width:=iw; rbmp.Height:=ih;

  with rbmp.Canvas do
  begin
    Pen.Color:=clBlack;
    Brush.Color:=clWhite;
    Rectangle(0,0,iw,ih);
    Brush.Color:=clRed;
    Ellipse(plr.rx-plr.rr,plr.ry-plr.rr,plr.rx+plr.rr,plr.ry+plr.rr);
  end;

  Image1.Canvas.CopyRect(rect(0,0,iw,ih),rbmp.Canvas,rect(0,0,iw,ih));

  rbmp.Free;

end;

procedure tform1.runsim;
var ang,orang:real;
    sout:string;
begin
  while (true) do
  begin

    sout:='';

    if (lexit) then break;

    ts2:=now;
    dt:=MilliSecondsBetween(ts2,ts1)/1000;
    ts1:=ts2;

    plr.kx:=inps.kx;
    plr.ky:=inps.ky;

    orang:=ktoang(plr.kx,plr.ky);
    ang:=orang*3.14/180;

    if (round(orang)<>-1) then
    begin
      plr.rkx:=cos(ang)*plr.spd*dt;
      plr.rky:=sin(ang)*plr.spd*dt;
      sout:='(+) ';
    end
    else
    begin
      plr.rkx:=0;
      plr.rky:=0;
      sout:='(-) ';
    end;


    sout:=sout+'ang='+floattostr(orang)+'; kx='+inttostr(inps.kx)+'; ky='
                   +inttostr(inps.ky)+'; rkx='+floattostr(plr.rkx)
                   +'; rky='+floattostr(plr.rky);

    plr.x:=plr.x+plr.rkx;
    plr.y:=plr.y+plr.rky;

    if (plr.x-plr.r < 0)  then plr.x:=plr.r;
    if (plr.y-plr.r < 0)  then plr.y:=plr.r;
    if (plr.x+plr.r > iw) then plr.x:=iw-plr.r;
    if (plr.y+plr.r > ih) then plr.y:=ih-plr.r;

    plr.rx:=round(plr.x);
    plr.ry:=round(plr.y);

    render;

    Form1.Caption:=sout;

    Application.ProcessMessages;
  end;
  Application.Terminate;
end;


procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if (Key=VK_UP) then
  begin
    inps.ky:=-1;
  end;
  if (Key=VK_DOWN) then
  begin
    inps.ky:=1;
  end;
  if (Key=VK_LEFT) then
  begin
    inps.kx:=-1;
  end;
  if (Key=VK_RIGHT) then
  begin
    inps.kx:=1;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  lexit:=true;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key=VK_UP) then
  begin
    inps.ky:=0;
  end;
  if (Key=VK_DOWN) then
  begin
    inps.ky:=0;
  end;
  if (Key=VK_LEFT) then
  begin
    inps.kx:=0;
  end;
  if (Key=VK_RIGHT) then
  begin
    inps.kx:=0;
  end;
  if (Key=VK_ESCAPE) then
  begin
    lexit:=true;
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Timer1.Enabled:=true;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Image1.Picture.Bitmap.Width:=image1.Width;
  Image1.Picture.Bitmap.Height:=image1.Height;
  iw:=Image1.Width;
  ih:=Image1.Height;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled:=false;
  runsim;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  iw:=Image1.Height;
  ih:=Image1.Height;
  initstartstate;
end;

end.

