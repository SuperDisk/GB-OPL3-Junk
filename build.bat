rgbasm -o playa.obj playa.asm
rgblink -m playa.map -o playa.gb playa.obj
rgbfix -p0 -v -m MBC5 playa.gb
