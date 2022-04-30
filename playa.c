#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <io.h>
#include <fcntl.h>

#include "opl3.h"

int main(void) {

  FILE* f = fopen("truncated.vgm", "rb");
  rewind(f);
  fseek(f, 0x34, SEEK_SET);
  unsigned int data_offset;
  fread(&data_offset, 4, 1, f);
  /* printf("%d\n", data_offset); */
  fseek(f, data_offset + 0x34, SEEK_SET);
  /* printf("Ready to read, boss: %x\n", ftell(f)); */

  opl3_chip chip;
  OPL3_Reset(&chip, 44100);
  /* puts("Reset the chip"); */

  unsigned char cmd, value, reg;
  unsigned short wait;

  setmode(fileno(stdout),O_BINARY);
  setmode(fileno(stdin),O_BINARY);

  /* FILE* fout = fopen("zogus.bin", "wb"); */

  while (fread(&cmd, 1, 1, f) == 1) {
    if (cmd == 0x66)
      break;

    if ((cmd != 0x5e) && (cmd != 0x5f) && (cmd != 0x61)) {
      /* puts("bitch you crazy!"); */
      return 1;
    }

    if (cmd == 0x61) {
      fread(&wait, 2, 1, f);

      int16_t* sndptr = malloc(2 * 2 * wait); // 2 (channels) * 2 (bytes) * numsamples
      OPL3_GenerateStream(&chip, sndptr, wait);
      fwrite(sndptr, 1, wait*2*2, stdout);
      free(sndptr);
      continue;
    }

    fread(&reg, 1, 1, f);
    fread(&value, 1, 1, f);

    /* if ((reg & 0xF0) == 0xF0) */
    /*   reg = reg & 0x0F; */
    /* if ((value & 0xF0) == 0xF0) */
    /*   value = value & 0x0F; */

    OPL3_WriteRegBuffered(&chip, reg | (cmd == 0x5F ? 0xF00 : 0), value);
  }

  /* puts("Got to the end"); */
  /* fclose(fout); */

  return 0;
}
