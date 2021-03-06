program UltraGen;

{$mode objfpc}{$H+}

uses
    {$IFDEF UNIX}
    cthreads,
    {$ENDIF}
    Classes, sysutils, StrUtils, LazUTF8, FileUtil, Process, Dos,
    { you can add units after this }

    { Classes }
     WebServerClass, TemplateClass, QueueListClass,
     ThreadedTemplateClass, GenFileSetClass, ParserClass, ExtensionClass,

    { Globals }
    TypesGlobals, VariablesGlobals, ConstantsGlobals,

    { Utils }
    FileHandlingUtils, StringsFunctions;
var
  iter,iterA, GenPath, ADefault:string;
  Start:TDateTime;
  FlowLines,AuxGens,AuxGroup,AuxTemp, ParamDump:TStringList;
  LookSub, Live, AsString, IsGenSetCall, IsGenpathCall, ShowHelp:boolean;
  i, j, interval, paramStart:integer;
  Server:TUltraGenServer;
  ATemplate:TTemplate;
  AGenSet:TGenFileSet;

  UHome:string;

begin
  UHome := U_HOME;
  Start := now;
  GlobalQueue := TQueueSet.Create;
  AVerifyThread := TThreadVerify.Create;
  if ParamCount > 2 then
  begin
    if (ParamStr(ParamCount-1) = ENABLE_THREADS) then
    begin
      interval := StrToInt(Trim(ParamStr(ParamCount)));
      if interval < 1 then
        interval := 1;
      GlobalQueue.Interval := interval*1000;
      AVerifyThread.Start;
    end;
  end;

  randomize;
  AuxGens :=  TStringList.Create;
  AuxGroup :=  TStringList.Create;
  //calling modes
  //a set of gens example
  //ultragen -set src1.gen|src2.gen -templates teste.ultra.txt|teste2.ultra.txt
  //new call        f
  //ultragen [template name] [genmode] [genpath]

  // server mode
  //--serve appName mode port
  if (ParamStr(1) = '--serve') then
  begin
    IsGenSetCall := False;
    IsGenPathCall := False;
    if not FileExists(ParamStr(2)) then
    begin
      WriteLn('Config App Gen ',GetFileName(ParamStr(2),False),' not found.');
      WriteLn('See docs for details. Exitting');
      Exit;
    end;
    if ParamCount = 2 then
    begin
    //-- serve appName

      Server := TUltraGenServer.Create(2020, ParamStr(2), '--dev')
    end
    else if ParamCount = 3 then
    //-- serve appName port
      Server := TUltraGenServer.Create(StrToInt(ParamStr(3)), ParamStr(2), '--dev')
    else if ParamCount = 4 then
    // --serve appName port mode
      if ParamStr(4) = '--prod' then
        Server := TUltraGenServer.Create(StrToInt(ParamStr(3)), ParamStr(2), '--prod')
      else
        Server := TUltraGenServer.Create(StrToInt(ParamStr(3)), ParamStr(2), '--dev');
      if not Server.RunServer then
        exit;
  end;
  Live := True;

  ShowHelp := False;
  IsGenSetCall := False;
  IsGenPathCall := False;
  if (ParamStr(2) = GENSET_CALL) or (ParamStr(2) = GENSET_CALL_S) then
    IsGenSetCall := True
  else if (ParamStr(2) = GENPATH_CALL) or (ParamStr(2) = GENPATH_CALL_S) then
    IsGenPathCall := True
  else if (ParamStr(1) = '--help') then
  begin
    StringsFunctions.PrintHelp(UHome);
    ShowHelp := True;
  end;


  if not ShowHelp then
  begin
    if IsGenSetCall then
    begin
      if (ParamStr(2) = GENSET_CALL) or (ParamStr(2) = GENSET_CALL_S) then
      begin
        paramStart := 4;
        if (ParamStr(4) = LIVE_CALL) or (ParamStr(4) = LIVE_CALL_S) then
        begin
          Live := False;
          paramStart := 5;
        end;
        AuxGens.SkipLastLineBreak := True;
        AuxGens.StrictDelimiter := True;
        AuxGens.Delimiter := SET_SEP;
        AuxGens.DelimitedText := ParamStr(3);
        ATemplate := TTemplate.Create(ParamStr(1));
        // uw temp.ultra -g src.gen -p param1 param2 param3
        ParamDump := TStringList.Create;
        ATemplate.SetVariable('param','');
        if ParamCount >= paramStart then
        begin

          for j:=paramStart to ParamCount do
          begin
            ATemplate.SetVariable('param['+IntToStr(j-paramStart)+']',ParamStr(j));
            ParamDump.Add(ParamStr(j));
          end;
          ATemplate.SetVariable('param',ParamDump.Text);
        end;
        ParamDump.Free;
        AGenSet := TGenFileSet.Create;
        for iter in AuxGens do
        begin
          AuxGroup.Clear;
          AuxGroup.SkipLastLineBreak := True;
          AuxGroup.StrictDelimiter := True;
          AuxGroup.Delimiter := SET_GROUP;
          AuxGroup.DelimitedText := iter;
          AGenSet.ClearSet;
          for iterA in AuxGroup do
            AGenSet.Add(iterA);
          ATemplate.ParseTemplate(AGenSet);
          if Live then
            ATemplate.PrintParsed
          else
            ATemplate.Save;
        end;
        ATemplate.Free;
      end;
    end
    else if IsGenPathCall then
    begin
      //temp.ultra --genpath [folder]
      paramStart := 4;
      //dummy
      Live := False;
      LookSub := False;
      GenPath := ParamStr(3);
      if ParamStr(3) = LOOK_SUB_FLAG then
      begin
        LookSub := True;
        paramStart := 5;
        GenPath := ParamStr(4);
      end;
      FindAllFiles(AuxGens,GenPath,'*.GEN;*.gen',LookSub);
      AuxGens.Sort;
      if AuxGens.Count > 0 then
      begin
        ATemplate := TTemplate.Create(ParamStr(1));
        ParamDump := TStringList.Create;
        ATemplate.SetVariable('param','');
        if ParamCount >= paramStart then
        begin

          for j:=paramStart to ParamCount do
          begin
            ATemplate.SetVariable('param['+IntToStr(j-paramStart)+']',ParamStr(j));
            ParamDump.Add(ParamStr(j));
          end;
          ATemplate.SetVariable('param',ParamDump.Text);
        end;
        ParamDump.Free;
        AGenSet := TGenFileSet.Create;
        for i:=0 to AuxGens.Count-1 do
        begin
          AGenSet.ClearSet;
          AGenSet.Add(AuxGens[i]);
          ATemplate.ParseTemplate(AGenSet);
          ATemplate.Save;
        end;
        ATemplate.Free;
      end;
    end
    else if ParamCount > 0 then
    begin
      paramStart := 2;
      if (ParamStr(2) = LIVE_CALL) or (ParamStr(2) = LIVE_CALL_S) then
      begin
        Live := False;
        paramStart := 3;
      end;
      ATemplate := TTemplate.Create(ParamStr(1));
      ParamDump := TStringList.Create;
      ATemplate.SetVariable('param','');
      if ParamCount >= paramStart then
      begin

        for j:=paramStart to ParamCount do
        begin
          ATemplate.SetVariable('param['+IntToStr(j-paramStart)+']',ParamStr(j));
          ParamDump.Add(ParamStr(j));
        end;
        ATemplate.SetVariable('param',ParamDump.Text);
      end;
      ParamDump.Free;
      AGenSet := TGenFileSet.Create;
      ATemplate.ParseTemplate(AGenSet);
      if Live then
        ATemplate.PrintParsed
      else
        ATemplate.Save;
      ATemplate.free;
    end;

    if (not Live) and (ParamCount > 0) then
    begin
      if AuxGens.Count > 0 then
        WriteLn('UltraGen processed ',AuxGens.Count,' files in: ',FormatDateTime('ss.zzz',Now-Start))
      else
        WriteLn('UltraGen processed 1 file in: ',FormatDateTime('ss.zzz',Now-Start))
    end;
  end;

  AuxGens.Free;
  AuxGroup.Free;

  if ParamCount = 0 then
  begin
    WriteLn('UltraGen');
    WriteLn('Advanced script language/template engine');
    WriteLn('Version: '+VERSION);
    WriteLn('You must provide parameters to execute UltraGen');
    WriteLn('Run ultragen --help for instructions');

  end;

  GlobalQueue.Free;
  AVerifyThread.Terminate;

end.

