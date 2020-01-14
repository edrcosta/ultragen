unit JsonToGenFunctions;

{$mode objfpc}{$H+}

interface

uses
  GenFileClass;

const
  OBJ_O = '{';
  OBJ_C = '}';
  LIST_O = '[';
  LIST_C = ']';
  SEP = ',';
  STR_ENC = '"';
  ATTR = ':';

type
  TJson2Gen = class
  private
    FGenFile: TGenFile;
    FJson:string;
    Fkey:string;
  public
    constructor Create(AStr:String; var AGenFile:TGenFile);
    procedure ParseJson;
    procedure ParseValue(AStr:string);
    procedure ParseStream(AStr:string);
    procedure ParsePair(AStr:string);
    procedure ParseList(AStr:string);
    procedure ParseObj(Astr:string);
    function IsObj(AStr:string):boolean;
    function IsList(AStr:string):boolean;
    function Conform(AStr:String):string;
  end;



implementation

uses
  Classes, SysUtils, ConstantsGlobals, StrUtils;

constructor TJson2Gen.Create(AStr:string; var AGenFile:TGenFile);
begin
  FGenFile := AGenFile;
  FJson := AStr;
  FKey := '';
end;

function TJson2Gen.Conform(AStr:string):string;
begin
  AStr := Trim(AStr);
  if (AStr[1] = STR_ENC) and (AStr[Length(AStr)] = STR_ENC) then
    Result := Copy(AStr,2,Length(AStr)-2)
  else
    Result := AStr;
end;

procedure TJson2Gen.ParseJson;
begin
  //FGenFile.SetValue(FKey,FJson);
  ParseValue(FJson);
end;

procedure TJson2Gen.ParseValue(AStr:string);
begin
  if IsList(AStr) then
    ParseList(Copy(AStr,2,Length(AStr)-2))
  else if IsObj(AStr) then
    ParseObj(Copy(AStr,2,Length(AStr)-2))
  else
    FGenFile.SetValue(FKey,AStr);
end;

procedure TJson2Gen.ParseStream(AStr:string);
begin

end;

procedure TJson2Gen.ParsePair(AStr:string);
begin

end;

procedure TJson2Gen.ParseList(AStr:string);
begin

end;

procedure TJson2Gen.ParseObj(Astr:string);
var
  c:char;
  inStr:boolean=False;
  inVal:boolean=False;
  objLevel, listLevel, AttrPos:integer;
  part:string='';
begin
  objLevel := 0;
  listLevel := 0;
  for c in AStr do
  begin
    if inVal and (c = OBJ_O) then
      objLevel := objLevel + 1;
    if inVal and (c = OBJ_C) then
      objLevel := objLevel - 1;
    if inVal and (c = LIST_O) then
      objLevel := listLevel + 1;
    if inVal and (c = LIST_C) then
      objLevel := listLevel - 1;
    if inVal and (c = STR_ENC) then
      inStr := not inStr;
    if (c = ATTR) and (not inVal) then
    begin
      inVal := True;
      if FKey = '' then
        FKey := Conform(part)
      else
        FKey := FKey + GEN_SUB_LEVEL + Conform(Part);
      part := '';
    end
    else if (c = SEP) and (not inStr) and (listLevel = 0) and (objLevel = 0) then
    begin
      ParseValue(Conform(part));
      AttrPos := RPos(GEN_SUB_LEVEL,FKey);
      if AttrPos > 0 then
        FKey := Copy(FKey,1,AttrPos-1)
      else
        FKey := '';
      part := '';
      inVal := False;
    end
    else
      part := part + c;
  end;

  ParseValue(Conform(Part));
  AttrPos := RPos(GEN_SUB_LEVEL,FKey);
  if AttrPos > 0 then
    FKey := Copy(FKey,1,AttrPos-1)
  else
    FKey := '';
end;

function TJson2Gen.IsObj(AStr:String):boolean;
begin
  if (AStr[1] = OBJ_O) and (AStr[Length(AStr)] = OBJ_C) then
    Result := True
  else
    Result := False;
end;

function TJson2Gen.IsList(AStr:String):boolean;
begin
  if (AStr[1] = LIST_O) and (AStr[Length(AStr)] = LIST_C) then
    Result := True
  else
    Result := False;
end;

end.

