unit uCompilationScriptCreator;

interface

uses
  System.Generics.Collections, System.Classes;

type
  TCompilationScriptCreator = class
  private
    FScriptFileName: string;
    FProjectList: TList<string>;

    procedure SaveFile(pScript: TStringList);
    function GetPathDefault: string;
  public

    procedure AddProjet(pFileName: string);
    procedure Generate;

    constructor Create;
    destructor Destroy; override;

    property ScriptFileName: string read FScriptFileName write FScriptFileName;
  end;

implementation

uses
  System.IoUtils, SysUtils;

{ TCompilationScriptCreator }

procedure TCompilationScriptCreator.AddProjet(pFileName: string);
begin
  FProjectList.Add(pFileName);
end;

constructor TCompilationScriptCreator.Create;
begin
  FProjectList := TList<string>.Create;
end;

destructor TCompilationScriptCreator.Destroy;
begin
  FProjectList.Free;
  inherited;
end;

procedure TCompilationScriptCreator.Generate;
var
  lStringList: TStringList;
  lProjeto: string;
begin
  lStringList := TStringList.Create();
  try
    lStringList.Add('call rsvars.bat');

    for lProjeto in FProjectList do
    begin
      lStringList.Add('cd "' + TPath.GetDirectoryName(lProjeto) + '"');
      lStringList.Add('msbuild ' + TPath.GetFileName(lProjeto));
    end;

    lStringList.Add('pause');

    self.SaveFile(lStringList);
  finally
    lStringList.Free;
  end;
end;

function TCompilationScriptCreator.GetPathDefault:string;
var
  lDirAtual: string;
begin
  lDirAtual := TPath.GetDirectoryName(ParamStr(0));
  Result := TPath.Combine(lDirAtual, 'script.bat');
end;

procedure TCompilationScriptCreator.SaveFile(pScript: TStringList);
begin
  if FScriptFileName.isEmpty then
     FScriptFileName := GetPathDefault;

  pScript.SaveToFile(FScriptFileName);
end;

end.
