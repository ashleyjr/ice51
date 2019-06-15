import sys
from intelhex import IntelHex

if "__main__" == __name__:
    i = IntelHex(sys.argv[1])
    for j in range(0, 512):
        print str(hex(i[j])).split('x')[1].lower()
