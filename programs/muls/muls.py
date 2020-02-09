import random as r

vectors = 1000
check   = []
drive   = []
for v in range(vectors):
    a = r.randint(0,255)
    b = r.randint(0,255)
    c = a * b
    drive.append(a)
    drive.append(b)
    check.append(c & 0xFF)
    check.append((c >> 8) & 0xFF)


print "// Check Uart:"
for i in range(len(check)):
    print '// 0x%02x' % check[i]
    if (0 == ((i+1) % 2)):
        print '// p'
print "// End"
print "// Drive Uart:"
for i in range(0,len(drive)):
    print '// 0x%02x' % drive[i]
    if (0 == ((i+1) % 2)):
        print '// p'
print "// End"

