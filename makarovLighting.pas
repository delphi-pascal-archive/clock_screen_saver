{
MakarovSDK
модуль: makarovLighting
разработчик: ћакаров ћ.ћ.
дата создани€: 15 июн€ 2005
}
unit makarovLighting;

interface

uses
  OpenGL;

type
  TmakarovLightCounter = class
  {счЄтчик источников света}
  private
    lights:Array[0..7] of Boolean;
  public
    constructor Create;
    destructor Destroy;override;
  protected
    function AddLight:Integer;
    procedure DelLight(n:Integer);
  end;

  TmakarovLight = class
  {источник света}
  private
    cntr:TmakarovLightCounter;
    n:Integer;
  public
    procedure Position(x,y,z:GLfloat);
    procedure Ambient(r,g,b:GLfloat);
    procedure Diffuse(r,g,b:GLfloat);
    procedure Specular(r,g,b:GLfloat);
    procedure SpotExponent(x:GLfloat);
    procedure SpotCutoff(x:GLfloat);
    procedure Direction(x,y,z:GLfloat);
    constructor Create(counter:TmakarovLightCounter);
    destructor Destroy;override;
  end;

implementation

function TmakarovLightCounter.AddLight:Integer;
{добавл€ет источник света в список и возвращает его номер
 (от 0 до 7). ≈сли все источники света уже зан€ты, то возвращает -1}
var
  i,j:Integer;
begin
  j:=-1;
  i:=-1;
  while (j=-1) and (i<7) do
  begin
    inc(i);
    if not lights[i] then
    begin
      j:=i;
      lights[i]:=true;
    end;
  end;
  if j<>-1 then
  begin
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0 + j);
    glEnable(GL_COLOR_MATERIAL);
  end;
  Result:=j;
end;

procedure TmakarovLightCounter.DelLight(n:Integer);
{удал€ет источник света с номером n (от 0 до 7)}
begin
  lights[n]:=false;
end;

constructor TmakarovLightCounter.Create;
var
  i:Integer;
begin
  for i:=0 to 7 do
    lights[i]:=false;
end;

destructor TmakarovLightCounter.Destroy;
var
  i:Integer;
begin
  for i:=0 to 7 do
    lights[i]:=false;
  Inherited;
end;

procedure TmakarovLight.Position(x,y,z:GLfloat);
{устанавливает координаты источника света}
var
  lposition:Array[0..3] of GLfloat;
begin
  if n<>-1 then
  begin
    lposition[0]:=x;
    lposition[1]:=y;
    lposition[2]:=z;
    lposition[3]:=1.0;
    glLightfv(GL_LIGHT0 + n, GL_POSITION, @lposition);
  end;
end;

procedure TmakarovLight.Ambient(r,g,b:GLfloat);
{устанавливает компоненты ambient}
var
  lambient:Array[0..3] of GLfloat;
begin
  if n<>-1 then
  begin
    lambient[0]:=r;
    lambient[1]:=g;
    lambient[2]:=b;
    lambient[3]:=1.0;
    glLightfv(GL_LIGHT0 + n, GL_AMBIENT, @lambient);
  end;
end;

procedure TmakarovLight.Diffuse(r,g,b:GLfloat);
{устанавливает компоненты diffuse}
var
  ldiffuse:Array[0..3] of GLfloat;
begin
  if n<>-1 then
  begin
    ldiffuse[0]:=r;
    ldiffuse[1]:=g;
    ldiffuse[2]:=b;
    ldiffuse[3]:=1.0;
    glLightfv(GL_LIGHT0 + n, GL_DIFFUSE, @ldiffuse);
  end;
end;

procedure TmakarovLight.Specular(r,g,b:GLfloat);
{устанавливает компоненты specular}
var
  lspecular:Array[0..3] of GLfloat;
begin
  if n<>-1 then
  begin
    lspecular[0]:=r;
    lspecular[1]:=g;
    lspecular[2]:=b;
    lspecular[3]:=1.0;
    glLightfv(GL_LIGHT0 + n, GL_SPECULAR, @lspecular);
  end;
end;

procedure TmakarovLight.Direction(x,y,z:GLfloat);
{направление света}
var
  ldirection:Array[0..3] of GLfloat;
begin
  if n<>-1 then
  begin
    ldirection[0]:=x;
    ldirection[1]:=y;
    ldirection[2]:=z;
    ldirection[3]:=1.0;
    glLightfv(GL_LIGHT0 + n, GL_SPOT_DIRECTION, @ldirection);
  end;
end;

procedure TmakarovLight.SpotExponent(x:GLfloat);
{интенсивность света}
begin
  if n<>-1 then
    glLightf(GL_LIGHT0 + n, GL_SPOT_EXPONENT, x);
end;

procedure TmakarovLight.SpotCutoff(x:GLfloat);
{разброс света}
begin
  if n<>-1 then
    glLightf(GL_LIGHT0 + n, GL_SPOT_CUTOFF, x);
end;

constructor TmakarovLight.Create(counter:TmakarovLightCounter);
begin
  cntr:=counter;
  n:=cntr.AddLight;
  Position(0,0,1);
end;

destructor TmakarovLight.Destroy;
begin
  if n<>-1 then
    cntr.DelLight(n);
  n:=-1;
  Inherited;
end;

end.
