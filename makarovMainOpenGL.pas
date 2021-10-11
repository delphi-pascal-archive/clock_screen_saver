{
MakarovSDK
модуль: makarovMainOpenGL
разработчик: Макаров М.М.
дата создания: 14 июня 2005
}
unit makarovMainOpenGL;

interface

uses
  Windows, OpenGL;

type
  TmakarovMainOpenGL = class
  {основной класс для настройки OpenGL}
  private
    WindowHandle:HWND;//дескриптор окна, в которое выводится изображение
    _DC:HDC;//контекст устройства
    _HRC:HGLRC;//контекст рендеринга OpenGL
    ps:TPaintStruct;
    w,h:Integer;//window width and height
    procedure SetDCPixelFormat;
  public
    constructor Create(Handle:HWND);
    destructor Destroy; override;
    procedure Resize(Width,Height:Integer);overload;
    procedure Resize(Width,Height:Integer; fovy,zNear,zFar:Double);overload;
    procedure StartPaint;
    procedure StopPaint;
    property DC:HDC read _DC write _DC;
    property HRC:HGLRC read _HRC write _HRC;
    property Handle:HWND read WindowHandle write WindowHandle;
  end;

implementation

constructor TmakarovMainOpenGL.Create(Handle:HWND);
begin
  WindowHandle := Handle;
  _DC := GetDC(WindowHandle);
  SetDCPixelFormat;
  _HRC:=wglCreateContext(_DC);
  wglMakeCurrent(_DC,_HRC);
  glClearColor(0,0,0,1);
  glEnable(GL_DEPTH_TEST);

  {сглаживание линий, точек и полигонов}
  glEnable(GL_LINE_SMOOTH);
  glEnable(GL_POINT_SMOOTH);
  glEnable(GL_POLYGON_SMOOTH);

  Resize(1024,768);
end;

destructor TmakarovMainOpenGL.Destroy;
begin
  wglMakeCurrent(_DC,_HRC);
  wglDeleteContext(_HRC);
  ReleaseDC(WindowHandle,_DC);
  DeleteDC(_DC);
  Inherited
end;

procedure TmakarovMainOpenGL.Resize(Width,Height:Integer);
begin
  w:=Width;
  h:=Height;
  glViewport(0,0,w,h);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30,w/h,1,1000);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

procedure TmakarovMainOpenGL.Resize(Width,Height:Integer; fovy,zNear,zFar:Double);
begin
  w:=Width;
  h:=Height;
  glViewport(0,0,w,h);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(fovy,w/h,zNear,zFar);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

procedure TmakarovMainOpenGL.SetDCPixelFormat;
{установка формата пикселей}
var
  nPixelFormat:Integer;
  pfd:TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd), 0);
  pfd.dwFlags:=PFD_SUPPORT_OPENGL or
               PFD_DOUBLEBUFFER or
               PFD_DRAW_TO_WINDOW;
  nPixelFormat:=ChoosePixelFormat(_DC,@pfd);
  SetPixelFormat(_DC,nPixelFormat,@pfd);
end;

procedure TmakarovMainOpenGL.StartPaint;
begin
  BeginPaint(WindowHandle,ps);
  glClear(GL_COLOR_BUFFER_BIT or
          GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
end;

procedure TmakarovMainOpenGL.StopPaint;
begin
  EndPaint(WindowHandle,ps);
  SwapBuffers(_DC);
end;

end.
