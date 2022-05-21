out = {}
for i in range(1,255):
    #print(i,':',(1/(4096 / (255 - i)))*1000)
    out[round((1/(4096 / (255 - i)))*1000)] = i

for k,v in out.items():
    print(f"ms_div({k}, {v}).")
