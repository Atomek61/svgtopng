unit maindlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtDlgs,
  ExtCtrls, ComCtrls, IniPropStorage, BGRABitmap, BGRASVG, BGRABitmapTypes,
  FPWritePNG, PropertyStorage, Buttons;

type

  { TMainDialog }

  TMainDialog = class(TForm)
    ApplicationProperties1: TApplicationProperties;
    ButtonOpen: TBitBtn;
    ButtonRepeat: TBitBtn;
    EditSizes: TEdit;
    ImageList1: TImageList;
    IniPropStorage: TIniPropStorage;
    Label1: TLabel;
    Label2: TLabel;
    Log: TMemo;
    OpenDialog: TOpenDialog;
    Shape1: TShape;
    Timer1: TTimer;
    procedure ButtonOpenClick(Sender: TObject);
    procedure ButtonRepeatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
  private
    FFilenames :array of string;
    procedure Convert(const Filename :string);
  public

  end;

var
  MainDialog: TMainDialog;

implementation

{$R *.lfm}

{ TMainDialog }

procedure TMainDialog.ButtonOpenClick(Sender: TObject);
var
  Filename :string;
  i :integer;
begin
  if OpenDialog.Execute then begin
    SetLength(FFilenames, OpenDialog.Files.Count);
    for i:=0 to OpenDialog.Files.Count-1 do
      FFilenames[i] := OpenDialog.Files[i];
    ButtonRepeat.Enabled := true;
    for Filename in OpenDialog.Files do
       Convert(Filename);
  end;
end;

procedure TMainDialog.ButtonRepeatClick(Sender: TObject);
var
  Filename :string;
begin
  for Filename in FFilenames do
    Convert(Filename);
end;

procedure TMainDialog.FormCreate(Sender: TObject);
begin
  if Application.HasOption('f', '') then begin
    OpenDialog.InitialDir := Application.getOptionValue('f');
  end;
end;

procedure TMainDialog.FormDropFiles(Sender: TObject; const FileNames: array of string);
var
  Filename :string;
  i :integer;
begin
  SetLength(FFilenames, Length(Filenames));
  for i:=0 to High(Filenames) do
    FFilenames[i] := Filenames[i];
  ButtonRepeat.Enabled := true;
  for Filename in Filenames do
    Convert(Filename);
end;

procedure TMainDialog.Convert(const Filename :string);
var
  s :array of integer;
  v :string;
  item :string;
  i, n :integer;
  bmp :TBGRABitmap;
  svg: TBGRASVG;
  writer :TFPWriterPNG;
  folders :array of string;
  targetfilename :string;
begin

  try
    // Parse Sizes
    s := nil;
    v := EditSizes.Text;
    n := 0;
    for item in v.Split(',') do begin
      SetLength(s, n+1);
      s[n] := StrToInt(item);
      inc(n);
    end;

    // Create folders
    folders := nil;
    SetLength(folders, Length(s));
    for i:=0 to High(s) do begin
      folders[i] := Format('%simg%d\', [ExtractFilepath(Filename), s[i]]);
      if not DirectoryExists(folders[i]) then
        MkDir(folders[i]);
    end;

    bmp := TBGRABitmap.Create;
    svg := TBGRASVG.Create;
    writer := TFPWriterPNG.Create;
    writer.UseAlpha := true;
    try
      Log.Lines.Add(Format('Converting ''%s''...', [Filename]));
      svg.LoadFromFile(Filename);
      for i:=0 to n-1 do begin
        bmp.SetSize(s[i], s[i]);
        svg.StretchDraw(bmp.Canvas2D, taCenter, tlCenter, 0,0, s[i], s[i]);
        targetfilename := folders[i]+ChangeFileExt(ExtractFilename(Filename), '.png');
        bmp.SaveToFile(targetfilename, writer);
        Log.Lines.Add(Format('...%s', [targetfilename]));
      end;
    finally
      writer.free;
      svg.Free;
      bmp.Free;
    end;
  except on E :Exception do
    Log.Lines.Add('Error - converting file '+Filename);
  end;
end;

end.

