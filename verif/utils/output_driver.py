import sys
from optparse import OptionParser

def main(start, end, filename, length):
    f = open(filename,'r')
    found = False
    checks = 0
    for j in f.read().split('\n'):
        if found:

            # Phases
            if ("//" in j) and ("p" in j):
                print("200")

            # Hex
            elif ("0x" in j):
                print("1"+j.split("0x")[1].lower() )

            # Chars
            elif found and ("\'" in j):
                c = j.split("\'")[1]
                c =str(hex(ord(c)))[2:4]
                print ("1"+c.lower() )

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
                print("1" + d )

            # Pos Dec
            elif ("//" in j) and not (end in j):
                d = j.replace("//","")
                d = str(hex(int(d)))[2:4]
                if len(d) < 2:
                    d = "0" + d
                print("1" + d )

            checks = checks + 1

        if ("// "+start) in j:
            found = True

        if ("// "+end) in j:
            found = False

    while(checks < int(length)):
        print("000")
        checks = checks + 1

    f.close()

if "__main__" == __name__:
    p = OptionParser()
    p.add_option("-s", "--start",       dest="start",       help="Start token")
    p.add_option("-e", "--end",         dest="end",         help="End token")
    p.add_option("-f", "--filename",    dest="filename",    help="Input file")
    p.add_option("-l", "--length",      dest="length",      help="Length of output")
    (options, args) = p.parse_args()
    main(   start       = options.start,
            end         = options.end,
            filename    = options.filename,
            length      = options.length)




