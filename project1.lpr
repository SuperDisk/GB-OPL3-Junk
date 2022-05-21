program project1;

uses math, sysutils, strutils, opl3;

const
   CYCLES_PER_SAMPLE = 72;
	 VOLUME = 15;

var
  Command: Char;
  hexstr: string[4];
  Bstr: string[2];
  chip: p_opl3_chip;
  buf3: array[0..1] of Int16;
  savedval: Byte;
  Q: Integer;
  Samp: Integer;

procedure sendsamples(value: integer);
begin
  write(Format('%0.4X', [value]));
end;

begin
  New(chip);
  OPL3_Reset(chip, 44100);

  while True do begin
    Read(Command);

    case Command of
      'a': begin
        Read(hexstr);
        OPL3_GenerateResampled(chip, buf3);
        Q := Hex2Dec(hexstr);
        Samp := ((Integer(buf3[0] + buf3[1]) div 2) + (10502)) * 120 div (10502*2);
        Samp *= Q;

        sendsamples(Samp);
      end;
      'w': begin
        Read(hexstr);
        Read(Bstr);

        Q := Hex2Dec(hexstr);

        case Hex2Dec(hexstr) of
          $0001: SavedVal := Hex2Dec(Bstr);
          $0002: OPL3_WriteRegBuffered(chip, savedval, hex2dec(bstr));
          $0003: SavedVal := Hex2Dec(Bstr);
          $0004: OPL3_WriteRegBuffered(chip, $F00 or savedval, hex2dec(bstr));
        end;

        write('0');
      end;
      #10, #13: continue;
      else begin
        Writeln(StdErr, 'Unknown command received: ', Command);
        Halt;
      end;
    end;
  end;
end.
