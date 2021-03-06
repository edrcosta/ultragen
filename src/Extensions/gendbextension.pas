unit GenDBExtension;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtensionClass, StrUtils, TemplateClass;

type
  TGenDBExtension = class
    private
      FPureParams, FParams:TStringList;
      FName :string;
      FTemplate: TTemplate;
    public
      constructor Create(AProc:string; var APureParams:TStringList; var AParams:TStringList; var ATemplate:TTemplate);
      procedure CallProc;
      function CallFunc:string;

      { procedures }
      procedure FindWhere;
      procedure FindFirst;



      { functions }
  end;

implementation
uses
  ConstantsGlobals, VariablesGlobals, TypesGlobals, GenFileClass, FileUtil;

constructor TGenDBExtension.Create(AProc:string; var APureParams:TStringList; var AParams:TStringList; var ATemplate:TTemplate);
begin
  FPureParams := APureParams;
  FParams := AParams;
  FName := AProc;
  FTemplate := ATemplate;
end;

procedure TGenDBExtension.CallProc;
begin
  if FName = 'findAll' then
    FindWhere
  else if FName = 'find' then
    FindFirst;
end;

function TGenDBExtension.CallFunc:string;
begin
  if FName = 'go' then
  begin
    FParams.SkipLastLineBreak := True;
    FParams.LineBreak := ', ';
    Result := FParams.Text;
  end;
end;

{ procedures }

procedure TGenDBExtension.FindWhere;
var
  // APath, AKey, AValue, APrefix: string;
  i: integer=0;
  a:integer;
  AGenFile:TGenFile;
  Files:TStringList;
  F:string;
begin
  AGenFile := TGenFile.Create;
  Files := TStringList.Create;
  FindAllFiles(Files, FParams[0], '*.gen;*.GEN', True);
  for F in Files do
  begin
    AGenFile.Load(F);
    if AGenFile.GetValue(FParams[2]).Value = FParams[3] then
    begin
      A := FTemplate.GenFileSet.Add(True, FParams[1]+GEN_SUB_LEVEL+IntToStr(i));
      AGenFile.CopyGen(FTemplate.GenFileSet.GenFiles[A].GenFile);
      i := i + 1;
    end;
  end;
  Files.Free;
  AGenFile.Free;
end;

procedure TGenDBExtension.FindFirst;
var
  // APath, AKey, AValue, APrefix: string;
  i: integer=0;
  a:integer;
  AGenFile:TGenFile;
  Files:TStringList;
  F:string;
begin
  AGenFile := TGenFile.Create;
  Files := TStringList.Create;
  FindAllFiles(Files, FParams[0], '*.gen;*.GEN', True);
  for F in Files do
  begin
    AGenFile.Load(F);
    if AGenFile.GetValue(FParams[2]).Value = FParams[3] then
    begin
      A := FTemplate.GenFileSet.Add(True, FParams[1]);
      AGenFile.CopyGen(FTemplate.GenFileSet.GenFiles[A].GenFile);
      Break;
    end;
  end;
  Files.Free;
  AGenFile.Free;
end;



end.

