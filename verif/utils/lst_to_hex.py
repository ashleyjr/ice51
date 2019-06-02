import sys

def lst_to_hex(in_file):
    out = ["00"] * 64
    for line in in_file.split("\n")[0:-1]:
        if '[' in line:
            ptr = int(line[6:12], 16)
            codes = line[13:21]
            if 'r' in codes:
                spl = 'r'
            else:
                spl = ' '
            for code in codes.split(spl):
                if '' == code:
                    out[ptr] = "00"
                else:
                    out[ptr] = code
                ptr += 1
    return out

def main(name):
    f = open(name)
    h = f.read()
    f.close()
    o = ""
    for i in lst_to_hex(h):
        o += i
        o += "\n"
    return o

if "__main__" == __name__:
    print main(sys.argv[1])
