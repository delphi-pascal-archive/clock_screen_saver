program ClockScr;

uses
  Forms,
  Unit1 in 'Unit1.pas' {frmClkScr};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmClkScr, frmClkScr);
  Application.Run;
end.
