This repo contains some random junk which I'm using to test out emulation of an OPL3 connected to Vin.

`playa.c` and `pasplaya.pas` are both players which take in an OPL3 VGM and write PCM to standard out (playable with something like FFPlay).

`playa.asm` takes a "cooked" VGM and plays it back by writing to a simulated OPL3.

`vgmcooker.py` and `vgmcooker.pl` will cook your VGM, although the Prolog one is the latest.

`project1` is a plugin for Emulicious which simulates an OPL3 connected to Vin.
