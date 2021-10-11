{
MakarovSDK
модуль: makarovQuadric
разработчик: Макаров М.М.
дата создания: 14 июня 2005
}
unit makarovQuadric;

interface

uses
  OpenGL;

type
  TmakarovQuadric = class
  private
    quadObj:GLUquadricObj;
    _segments:Integer;
  public
    constructor Create;
    destructor Destroy;override;
    property segments:Integer read _segments write _segments;
    procedure Sphere(radius:Double);
    procedure Cylinder(radius,height:Double);
    //procedure Cone;
    //procedure Disk;
  end;

implementation

constructor TmakarovQuadric.Create;
begin
  quadObj:=gluNewQuadric;
  _segments:=15;
  gluQuadricDrawStyle(quadObj,GLU_FILL);
  gluQuadricOrientation(quadObj,GLU_OUTSIDE);
  gluQuadricNormals(quadObj,GLU_SMOOTH);
end;

destructor TmakarovQuadric.Destroy;
begin
  gluDeleteQuadric(quadObj);
  Inherited
end;

procedure TmakarovQuadric.Sphere(radius:Double);
begin
  gluSphere(quadObj,radius,_segments,_segments);
end;

procedure TmakarovQuadric.Cylinder(radius,height:Double);
begin
  gluCylinder(quadObj,radius,radius,height,_segments,_segments);
end;

end.
