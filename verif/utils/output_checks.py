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

            # Dec
            else:
                if "//" in j:
                    d = j.replace("//","")
                    d = str(hex(int(d)))[2:4]
                    g.write("1" + d + "\n")

            checks = checks + 1

        if "// Check Uart" in j:
            found = True
    while(checks < 128):
        g.write("000\n")
        checks = checks + 1
    f.close()
    g.close()
