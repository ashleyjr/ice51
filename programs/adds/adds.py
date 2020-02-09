import random as r

vectors = 1000
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
    print '// p'
print "// End"
print "// Drive Uart:"
for i in range(0,len(drive)):
    print '// 0x%02x' % drive[i]
    if (0 == ((i+1) % 2)):
        print '// p'
print "// End"

