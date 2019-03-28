program AuxiliarCompilacaoDelphiDproj;

uses
  System.StartUpCopy,
  FMX.Forms,
  uCompilationScriptCreator in 'src\uCompilationScriptCreator.pas',
  ufMain in 'src\ufMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
