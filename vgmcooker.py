with open('output.vgm', 'rb') as f:
    vgm = bytearray(f.read())

print(type(vgm))
print(vgm[0])

idx = 0xC0
while True:
    if idx >= len(vgm):
        break
    cmd = vgm[idx]
    if cmd == 0x5E:
        idx += 3
    elif cmd == 0x5F:
        idx += 3
    elif cmd == 0x61:
        num = round((vgm[idx+1] | (vgm[idx+2] << 8)) / 734)
        vgm[idx+1] = num & 0x0F
        vgm[idx+2] = (num & 0xF0) >> 8
        idx += 3
    elif cmd == 0x66:
        break
    else:
        print("UH OH!", hex(cmd))

with open('cooked.vgm', 'wb') as f:
    f.write(vgm)

print("donezorz")
