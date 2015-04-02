import os

files = os.listdir(".")

lines = {}

first = True

for f in files:
    if ".csv" in f:
        fl = open(f, "r")
        fl = fl.readlines()
        if first:
            print fl[0].replace("\n", "")
            first = False
	fl = fl[1:]
	for l in fl:
            l = l.split(",")
	    if len(l) > 1:
                l[0] = int(l[0])
                l[1] = l[1].replace("\n", "").replace("\"", "")
		if l[0] not in lines:
                    lines[l[0]] = l[1]
		else:
                    lines[l[0]] += "," + l[1]

j = lines.keys()
j.sort()
for i in j:
    print "%d,%s"%(i, lines[i])
