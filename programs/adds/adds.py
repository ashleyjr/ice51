import random as r

vectors = 10000
check   = []
drive   = []
for v in range(vectors):
    a = r.randint(0,255)
    b = r.randint(0,255)
    c = a + b
    if c > 255:
        c -= 256
    drive.append(a)
    drive.append(b)
    check.append(c)


print "// Check Uart:"
for c in check:
    print '// 0x%02x' % c
print "// End"
print "// Drive Uart:"
for d in drive:
    print '// 0x%02x' % d
print "// End"

