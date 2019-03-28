unit ufMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Edit, FMX.ListView, Data.DB, Datasnap.DBClient, FMX.Objects,
  System.Classes, FMX.ScrollBox,
  FMX.Memo, System.Generics.Collections, System.ImageList, FMX.ImgList;

type
  TfrmMain = class(TForm)
    edtCaminhoRTC: TEdit;
    btnCarregarProjeto: TButton;
    lvProjetos: TListView;
    btnCompilar: TButton;
    ilIcones: TImageList;
    memFilterOrder: TMemo;
    Label1: TLabel;
    btnSaveFilter: TButton;
    btnSelecionarDiretorio: TButton;
    btnSelecionarTodos: TButton;
    btnCopiarSelecionadosLista: TButton;
    procedure btnCarregarProjetoClick(Sender: TObject);
    procedure btnCompilarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSaveFilterClick(Sender: TObject);
    procedure btnSelecionarDiretorioClick(Sender: TObject);
    procedure btnSelecionarTodosClick(Sender: TObject);
    procedure btnCopiarSelecionadosListaClick(Sender: TObject);
  private
    FFiles: TList<string>;
    procedure CreateNewItem(pFile: string);
    procedure ExecuteScript(pProjects: TList<string>);
    procedure ReadDirectories(pPathDirectory: string);
    function AddFileIfDproj(pFile: string): boolean;
    procedure CreateComponentList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  System.IOUtils, SHELLAPI, Winapi.Windows, System.RegularExpressions,
  uCompilationScriptCreator;

const
  FILTER_ORDER_FILES = '.filterOrder';

{$R *.fmx}

procedure TfrmMain.btnCarregarProjetoClick(Sender: TObject);
begin
  lvProjetos.Items.Clear;
  FFiles.Clear;
  ReadDirectories(edtCaminhoRTC.text);
  CreateComponentList;
end;

procedure TfrmMain.btnCompilarClick(Sender: TObject);
var
  lList: TList<string>;
  lItem: TListViewItem;
begin
  lList := TList<string>.Create;
  try
    for lItem in lvProjetos.Items do
    begin
      if lItem.Checked then
        lList.add(lItem.Detail);
    end;

    ExecuteScript(lList);
  finally
    lList.Free;
  end;
end;

procedure TfrmMain.btnCopiarSelecionadosListaClick(Sender: TObject);
var
  lItem: TListViewItem;
begin
  for lItem in lvProjetos.Items do
  begin
    if lItem.Checked then
      memFilterOrder.lines.add(lItem.text);
  end;
end;

procedure TfrmMain.btnSelecionarDiretorioClick(Sender: TObject);
const
  SELDIRHELP = 1000;
var
  lDir: string;
begin
  if SelectDirectory('RTC', lDir, lDir) then
    edtCaminhoRTC.text := lDir;
end;

procedure TfrmMain.btnSelecionarTodosClick(Sender: TObject);
var
  lItem: TListViewItem;
begin
  for lItem in lvProjetos.Items do
  begin
    lItem.Checked := True;
  end;
end;

procedure TfrmMain.btnSaveFilterClick(Sender: TObject);
begin
  memFilterOrder.lines.SaveToFile(FILTER_ORDER_FILES);
end;

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited;
  FFiles := TList<string>.Create;

{$IFDEF DEBUG}
  edtCaminhoRTC.text := 'c:\source\projeto1';

{$ENDIF}
end;

procedure TfrmMain.CreateComponentList;
var
  lFilterFile: string;
  lFile: string;
begin
  if memFilterOrder.Lines.Text.Trim.IsEmpty then
  begin
    for lFile in FFiles do
      self.CreateNewItem(lFile);

    exit;
  end;

  for lFilterFile in memFilterOrder.lines do
    for lFile in FFiles do
      if TPath.GetFileName(lFile).ToLower = lFilterFile.ToLower then
      begin
        self.CreateNewItem(lFile);
        Break;
      end;
end;

procedure TfrmMain.CreateNewItem(pFile: string);
var
  lItem: TListViewItem;
  lsize: TSizeF;
begin
  lItem := lvProjetos.Items.add;
  lItem.text := TPath.GetFileName(pFile);
  lItem.Detail := pFile;
  lsize.cx := 48;
  lsize.cy := 48;
  lItem.Bitmap.Assign(ilIcones.Bitmap(lsize, 0))
end;

destructor TfrmMain.Destroy;
begin
  FFiles.Free;
  inherited;
end;

procedure TfrmMain.ExecuteScript(pProjects: TList<string>);
var
  lScriptFile: string;
  lProject: string;
  lCompilationScriptCreator: TCompilationScriptCreator;
begin
  lCompilationScriptCreator := TCompilationScriptCreator.Create;
  try
    for lProject in pProjects do
      lCompilationScriptCreator.AddProjet(lProject);

    lCompilationScriptCreator.Generate;

    lScriptFile := lCompilationScriptCreator.ScriptFileName;
  finally
    lCompilationScriptCreator.Free;
  end;

  sleep(500);
  lScriptFile := '"' + lScriptFile + '"';
  ShellExecute(cardinal(self.Handle), 'open', 'cmd.exe',
    PChar('/c' + lScriptFile), nil, SW_SHOWNORMAL);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  if Tfile.Exists(FILTER_ORDER_FILES) then
    memFilterOrder.lines.LoadFromFile(FILTER_ORDER_FILES);
end;

procedure TfrmMain.ReadDirectories(pPathDirectory: string);
var
  lDirectories: TStringDynArray;
  lDirectory: string;
  lFiles: TStringDynArray;
  lFile: string;
begin
  lDirectories := TDirectory.GetDirectories(pPathDirectory);
  for lDirectory in lDirectories do
    if not lDirectory.IsEmpty then
      ReadDirectories(lDirectory);

  lFiles := TDirectory.GetFiles(pPathDirectory);
  for lFile in lFiles do
    if not lFile.isEmpty then
      AddFileIfDproj(lFile);
end;

function TfrmMain.AddFileIfDproj(pFile: string): boolean;
begin
  result := false;
  if TPath.GetExtension(pFile).ToLower <> '.dproj' then
    exit;

  FFiles.add(pFile);
  result := True;
end;

end.
