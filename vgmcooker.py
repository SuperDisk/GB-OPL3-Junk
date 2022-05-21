with open('output.vgm', 'rb') as f:
    vgm = bytearray(f.read())

print(type(vgm))
print(vgm[0])

idx = 0xc0
while True:
    if idx >= len(vgm):
        break
    cmd = vgm[idx]
    if cmd == 0x5E:
        idx += 3
    elif cmd == 0x5F:
        idx += 3
    elif cmd in [0x61, 0x63]:
        if cmd == 0x63:
            q = 882
            vgm[idx] = 0x61
            vgm[idx+1:0] = [0,0]
        else:
            q = (vgm[idx+1] | (vgm[idx+2] << 8))
        #print('q:',q,'q/44100*1024=',(q / 44100)*1024)
        num = round((q / 44100)*(60))
        #print('writing',num,'=',hex(num), 'aka', hex(num & 0xFF), hex((num & 0xFF00) >> 8))
        vgm[idx+1] = num & 0xFF
        vgm[idx+2] = (num & 0xFF00) >> 8
        idx += 3
    elif cmd == 0x66:
        break
    else:
        print("UH OH!", hex(cmd))

with open('cooked.vgm', 'wb') as f:
    f.write(vgm)

print("donezorz")
