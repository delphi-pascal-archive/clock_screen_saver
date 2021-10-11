unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, makarovMainOpenGL, ExtCtrls, OpenGL,
  makarovLighting, makarovQuadric, Math;

type
  TfrmClkScr = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    H:HWND;
    NeedToClose:Boolean;
    dix:Boolean;
    ix:Extended;
    demo:Integer;
    main:TmakarovMainOpenGL;
    lc:TmakarovLightCounter;
    dn:TmakarovLight;
    l:TmakarovLight;
    quad:TmakarovQuadric;
    clkrot,clkrot2:Extended;
    function TestParamStr:Char;
    procedure LoadObj(filename:ShortString; n:Integer);
    procedure LoadTexture(PackFile:ShortString;
                          NumberInPack:Integer;
                          NumberInMemory:Integer);
    procedure DrawSceneBox(x,y,z,dx,dy:Extended);
    procedure CalcNormal(x1,y1,z1,x2,y2,z2,x3,y3,z3:Extended; var nx,ny,nz:Extended);
    procedure MoveLight;
    procedure DrawClock;
    procedure DayNight;
  end;

  tex=array[0..255, 0..255, 0..2] of Byte;

const
  GL_CLAMP_TO_EDGE = $812F;

var
  frmClkScr: TfrmClkScr;

implementation

{$R *.dfm}
{$D "Clock Screen Saver designed by Makarov M.M."}

procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;

procedure TfrmClkScr.LoadTexture(PackFile:ShortString;
                                 NumberInPack:Integer;
                                 NumberInMemory:Integer);
var
  arr:tex;
  f:file of tex;
  i:Integer;
begin
  AssignFile(f,PackFile);
  Reset(f);
  for i:=1 to NumberInPack do
  begin
    Read(f,arr);
    if i=NumberInPack then
    begin
      glEnable(GL_TEXTURE_2D);
      glBindTexture(GL_TEXTURE_2D,NumberInMemory);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
      glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,256,256,
        0,GL_RGB,GL_UNSIGNED_BYTE,@arr);
      glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    end;
  end;
end;

procedure TfrmClkScr.CalcNormal(x1,y1,z1,x2,y2,z2,x3,y3,z3:Extended; var nx,ny,nz:Extended);
var
  wrki: Double;
  vx1,vy1,vz1,vx2,vy2,vz2: Double;
begin
  vx1:=x1-x2;
  vy1:=y1-y2;
  vz1:=z1-z2;
  vx2:=x2-x3;
  vy2:=y2-y3;
  vz2:=z2-z3;
  wrki:=sqrt(sqr(vy1*vz2-vz1*vy2)+sqr(vz1*vx2-vx1*vz2)+sqr(vx1*vy2-vy1*vx2));
  nx:=(vy1 * vz2 - vz1 * vy2)/wrki;
  ny:=(vz1 * vx2 - vx1 * vz2)/wrki;
  nz:=(vx1 * vy2 - vy1 * vx2)/wrki;
end;

procedure TfrmClkScr.DrawClock;
var
  i:Integer;
  s, m, h,n:Word;
begin
  glDisable(GL_TEXTURE_2D);
  glScale(0.07, 0.07, 0.08);
  for i:=2 to 10 do
  begin
    glPushMatrix;
    glTranslatef(250*sin(DegToRad(30*(i-1))), 250*cos(DegToRad(30*(i-1))), 0);
    glCallList(i);
    glPopMatrix;
  end;

  glPushMatrix;
  glTranslatef(250*sin(DegToRad(30*(0))), 250*cos(DegToRad(30*(0))), 0);
  glTranslatef(-40,0,0);
  glCallList(2);
  glTranslatef(40,0,0);
  glCallList(3);
  glPopMatrix;

  glPushMatrix;
  glTranslatef(250*sin(DegToRad(30*(-1))), 250*cos(DegToRad(30*(-1))), 0);
  glTranslatef(-40,0,0);
  glCallList(2);
  glTranslatef(40,0,0);
  glCallList(2);
  glPopMatrix;

  glPushMatrix;
  glTranslatef(250*sin(DegToRad(30*(-2))), 250*cos(DegToRad(30*(-2))), 0);
  glTranslatef(-40,0,0);
  glCallList(2);
  glTranslatef(40,0,0);
  glCallList(1);
  glPopMatrix;

  DecodeTime(Now, h, m, s, n);
  glColor3f(1,0,0);
  for i:=1 to 25 do
  begin
    glPushMatrix;
    glTranslatef(i*12*sin(DegToRad(6*(s))), i*12*cos(DegToRad(6*(s))), 0);
    glTranslatef(-40,0,-30);
    quad.Sphere(5);
    glTranslatef(0,0,60);
    quad.Sphere(5);
    glPopMatrix;
  end;

  glColor3f(0,1,0);
  for i:=1 to 7 do
  begin
    glPushMatrix;
    glTranslatef(i*25*sin(DegToRad(6*(m-1))), i*25*cos(DegToRad(6*(m-1))), 0);
    glTranslatef(-40,0,0);
    quad.Sphere(10);
    glPopMatrix;
  end;

  glColor3f(1,1,0);
  for i:=1 to 7 do
  begin
    glPushMatrix;
    glTranslatef(i*25*sin(DegToRad(30*(h))), i*25*cos(DegToRad(30*(h))), 0);
    glTranslatef(-40,0,0);
    quad.Sphere(12);
    glPopMatrix;
  end;
end;

procedure TfrmClkScr.MoveLight;
begin

end;

procedure TfrmClkScr.LoadObj(filename:ShortString; n:Integer);
var
  f:TextFile;
  x1,y1,z1,x2,y2,z2,x3,y3,z3:Extended;
  nx,ny,nz:Extended;
begin
  AssignFile(f,filename);
  Reset(f);
  glNewList(n+1, GL_COMPILE);
  glBegin(GL_TRIANGLES);
  while not EOF(f) do
  begin
    ReadLn(f,x1,y1,z1,x2,y2,z2,x3,y3,z3);
    CalcNormal(x1,y1,z1,x2,y2,z2,x3,y3,z3,nx,ny,nz);
    glNormal3f(nx,ny,nz);
    glVertex3f(x1,y1,z1);
    glVertex3f(x2,y2,z2);
    glVertex3f(x3,y3,z3);
  end;
  glEnd;
  glEndList;
  CloseFile(f);
end;

procedure TfrmClkScr.DayNight;
const
  dx=0.001;
begin
  if ix<=0 then
    dix:=true;
  if ix>=1 then
    dix:=false;
  if dix then
    ix:=ix+dx
  else
    ix:=ix-dx;
  l.Position(0,0,10);
  l.Diffuse(1-ix, ix, 0);
  dn.Diffuse(ix,ix,1-(1-ix)/2);
end;

procedure TfrmClkScr.DrawSceneBox(x,y,z,dx,dy:Extended);
begin
  glEnable(GL_TEXTURE_2D);
  glBegin(GL_QUADS);
  glNormal3f(0,0,1);
  glTexCoord2d(1,1);
  glVertex3f(x,y,z);
  glTexCoord2d(0,1);
  glVertex3f(x+dx,y,z);
  glTexCoord2d(0,0);
  glVertex3f(x+dx,y+dy,z);
  glTexCoord2d(1,0);
  glVertex3f(x,y+dy,z);
  glEnd;
end;

function TfrmClkScr.TestParamStr:Char;
var
  s:ShortString;
  v:Char;
  i:Integer;
begin
  v:=' ';
  i:=-1;
  while (i<10) and ((v<>'p') or (v<>'s') or (v<>'c')) do
  begin
    inc(i);
    s:=ParamStr(i);
    if s[1]='/' then
    begin
      case s[2] of
      'c','C': v:='c';
      's','S': v:='s';
      'p','P': begin
          v:='p';
          s:=ParamStr(i+1);
          H:=StrToInt(s);
        end;
      end;
    end;
  end;
  if v=' ' then v:='s';
  Result:=v;
end;

procedure TfrmClkScr.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmClkScr.FormCreate(Sender: TObject);
var
  i:Integer;
begin
  demo:=600;
  clkrot:=0;
  clkrot2:=0;
  main:=NIL;
  NeedToClose:=false;
  ix:=0;
  dix:=false;
  if TestParamStr='c' then
  begin
    for i:=1 to 3 do
    begin
      Beep;
      Sleep(100);
    end;
  end else begin
    Label1.Destroy;
    Button1.Destroy;
    Color:=clBlack;
    WindowState:=wsMaximized;
    BorderStyle:=bsNone;
    ShowCursor(false);
    if TestParamStr='s' then
      H:=Handle;
    main:=TmakarovMainOpenGL.Create(H);
    lc:=TmakarovLightCounter.Create;
    dn:=TmakarovLight.Create(lc);
    l:=TmakarovLight.Create(lc);
    l.Diffuse(0,1,0);
    glDisable(GL_LIGHT1);
    quad:=TmakarovQuadric.Create;
    for i:=0 to 9 do
      LoadObj('ClockScrM\data\obj'+IntToStr(i)+'.dat', i);
    main.Resize(ClientWidth, ClientHeight);
    if TestParamStr='p' then
    begin
      WindowState:=wsMinimized;
      NeedToClose:=true;
    end;

    LoadTexture('ClockScrM\data\scene.dat', 1, 1);
    LoadTexture('ClockScrM\data\scene.dat', 2, 2);
    LoadTexture('ClockScrM\data\scene.dat', 3, 3);
    LoadTexture('ClockScrM\data\scene.dat', 4, 4);

    Timer1.Enabled:=true;
  end;
end;

procedure TfrmClkScr.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled:=false;
  if main<>NIL then
  begin
    glDeleteLists(1,10);
    dn.Destroy;
    lc.Destroy;
    l.Destroy;
    quad.Destroy;
    main.Destroy;
  end;
  ShowCursor(true);
end;

procedure TfrmClkScr.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=27 then
    Close;
end;

procedure TfrmClkScr.FormResize(Sender: TObject);
begin
  if main<>NIL then
    main.Resize(ClientWidth, ClientHeight);
end;

procedure TfrmClkScr.FormShow(Sender: TObject);
begin
  WindowState:=wsMaximized;
end;

procedure TfrmClkScr.Timer1Timer(Sender: TObject);
const
  x=42.66;
  y=32;
begin
  main.StartPaint;
  glColor3f(1,1,1);
  glClearColor(0,0,0,1);

  glLoadIdentity;
  glTranslatef(0,0,-100);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, 1);
  DrawSceneBox(-x, 0, -20, x, y);
  glBindTexture(GL_TEXTURE_2D, 3);
  DrawSceneBox(0, 0, -20, x, y);
  glBindTexture(GL_TEXTURE_2D, 2);
  DrawSceneBox(-x, -y, -20, x, y);
  glBindTexture(GL_TEXTURE_2D, 4);
  DrawSceneBox(0, -y, -20, x, y);

  DayNight;
  MoveLight;

  clkrot:=clkrot+1;
  clkrot2:=clkrot2+0.5;

  glRotatef(clkrot,1,0,1);
  glRotatef(clkrot2,0,1,0);
  glDisable(GL_LIGHT0);
  glEnable(GL_LIGHT1);
  DrawClock;
  glDisable(GL_LIGHT1);
  glEnable(GL_LIGHT0);

  main.StopPaint;
  if NeedToClose then Close;
end;

end.
