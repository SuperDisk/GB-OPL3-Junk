program pasplaya;

uses opl3, classes, pipes, sysutils;

var
  chip: p_opl3_chip;
  S: TStream;
  DataOffset: Integer;

  Cmd, Value, Reg, Wait: Integer;
  SndPtr: array of Int16;

  OutS: TStream;
   I: Integer;
   Samp: array [0..1] of Int16;
begin
  OutS := TOutputPipeStream.Create(GetFileHandle(Output));
  //OutS := TFileStream.Create('pasout.bin', fmCreate);

  S := TFileStream.Create('nikku.vgm', fmOpenRead);
  S.Seek($34, soBeginning);

  DataOffset := S.ReadQWord;
  S.Seek($34 + DataOffset, soBeginning);

  New(Chip);
  OPL3_Reset(chip, 44100);

  while S.Read(Cmd, 1) <> 0 do begin
    if Cmd = $66 then Break;

    if not (Cmd in [$5e, $5f, $61]) then
      writeln('BAD!');

    if Cmd = $61 then begin
      S.Read(Wait, 2);
       for I := 0 to Wait do begin
          OPL3_GenerateResampled(Chip, Samp);
          OutS.WriteBuffer(Samp, SizeOf(Int16)*2);
       end;
      {SetLength(SndPtr, 2 * Wait);
      OPL3_GenerateStream(Chip, @SndPtr[0], Wait);
      OutS.WriteBuffer(SndPtr[0], Length(SndPtr) * SizeOf(Int16));}
      Continue;
    end;

    Reg := 0;
    Value := 0;
    S.Read(Reg, 1);
    S.Read(Value, 1);

    if Cmd = $5f then
      Reg := Reg or $F00;

    OPL3_WriteRegBuffered(Chip, Reg, Value);
  end;

  writeln('yeah');
  readln;
end.
