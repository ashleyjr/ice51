import sys

CHECK_SIZE = 128

if "__main__" == __name__:
    f = open(sys.argv[1],'r')
    g = open(sys.argv[1].replace('.c','.checks'), 'w+')
    found = False
    checks = 0
    for j in f.read().split('\n'):
        if found:

            # Hex
            if ("0x" in j):
                g.write("1"+j.split("0x")[1].lower() + "\n")

            # Chars
            elif found and ("\'" in j):
                c = j.split("\'")[1]
                c =str(hex(ord(c)))[2:4]
                g.write("1"+c.lower() + "\n")

            # Negs Dec
            elif ("//" in j) and ("-" in j):
                d = j.replace("//","")
                d = d.replace("-","")
                d = str(bin(int(d))).split('b')[1]
                while(len(d) < 8):
                    d = "0" + d
                p = 128
                t = 0
                for s in d:
                    if "0" == s:
                        t += p
                    p = p >> 1
                d = str(hex(t + 1))[2:4]
                g.write("1" + d + "\n")

            # Pos Dec
            elif "//" in j:
                d = j.replace("//","")
                d = str(hex(int(d)))[2:4]
                if len(d) < 2:
                    d = "0" + d
                g.write("1" + d + "\n")

            checks = checks + 1

        if "// Check Uart" in j:
            found = True

    while(checks < 128):
        g.write("000\n")
        checks = checks + 1

    f.close()
    g.close()
