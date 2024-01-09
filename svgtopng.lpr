program svgtopng;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, maindlg;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='SvgToPng';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainDialog, MainDialog);
  Application.Run;
end.

