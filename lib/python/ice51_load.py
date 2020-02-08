import serial
import serial.tools.list_ports
import time
import sys
import random
import threading
import time
from optparse import OptionParser


class uart:
    BAUDRATE= 115200
    RX_BUFFER_SIZE = 100000

    def __init__(self):
        ports =  serial.tools.list_ports.comports()

        found = ""
        self.name = ""
        for port, desc, hwid in sorted(ports):
            if "Lattice FTUSB" in desc:
                found = port
                self.name = port + ": " + desc
                break

        self.ser = serial.Serial(
            port=found,
            baudrate=self.BAUDRATE,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            bytesize=serial.EIGHTBITS
        )

        self.ser.flushInput()
        self.ser.flushOutput()

        self.rx_buf = [0] * self.RX_BUFFER_SIZE
        self.rx_buf_head = 0
        self.rx_buf_tail = 0

        self.stop = False
        threading.Thread(target=self.rx_buffer).start()

    def getName(self):
        return self.name

    def rx_buffer(self):
        while not self.stop:
            while(self.ser.inWaiting() != 0):
                self.rx_buf[self.rx_buf_head] = ord(self.ser.read(1))
                self.rx_buf_head += 1
                self.rx_buf_head %= self.RX_BUFFER_SIZE

    def rx_buffer_level(self):
        if(self.rx_buf_head == self.rx_buf_tail):
            return 0
        elif(self.rx_buf_head > self.rx_buf_tail):
            return self.rx_buf_head - self.rx_buf_tail
        else:
            return self.rx_buf_head + (RX_BUFFER_SIZE - self.rx_buf_tail)

    def rx_buffer_empty(self):
        return self.rx_buffer_level() == 0

    def tx(self, d):
        self.ser.write(chr(d))
        return

    def rx(self):
        while(self.rx_buf_tail == self.rx_buf_head):
            pass
        d = self.rx_buf[self.rx_buf_tail]
        self.rx_buf_tail += 1
        self.rx_buf_tail %= self.RX_BUFFER_SIZE
        return d#ord(self.ser.read(1))

    def finish(self):
        self.stop = True
        return

def main(options):

    u = uart()

    print "Connected:      " + u.getName()
    print "Running test:   " + options.test
    h = options.test.replace(".c",".hex")
    print "Loading hex:    " + h

    f = open(h, 'r')
    data = f.read()
    f.close()

    byts = 0
    for d in data.split('\n')[0:-1]:
        c = int('0x'+d, 16)
        u.tx(c)
        byts += 1

    print "Bytes written:  " + str(byts)

    c = options.test.replace(".c",".checks")
    print "Loading checks: " + c
    f = open(c, 'r')
    checks = f.read()
    f.close()

    c = options.test.replace(".c",".drives")
    print "Loading drives: " + c
    f = open(c, 'r')
    drives = f.read()
    f.close()

    drive = []
    for d in drives.split('\n')[0:-1]:
        if d != '000':
            drive.append(d)
    check = []
    for c in checks.split('\n')[0:-1]:
        if c != '000':
            check.append(c)


    l_check = len(check)
    l_drive = len(drive)
    print "Checks:         " + str(l_check)
    print "Drives:         " + str(l_drive)

    ok = True
    drive_index = 0
    check_index = 0
    while (drive_index < l_drive) or \
          (check_index < l_check):

        if drive_index < len(drive):
            a = int(drive[drive_index][1:3], 16)
            u.tx(a)
            time.sleep(0.0001)
            if options.debug:
                print "Sent: " +str(hex(a))
            drive_index += 1

        if (check_index < len(check)) and not u.rx_buffer_empty():
            a = int(check[check_index][1:3], 16)
            b = u.rx()
            if options.debug:
                print "Got: " +str(hex(a)) + ", Exp: " +str(hex(b))
            if a != b:
                ok = False
                break
            check_index += 1


        if not options.debug:
            progress = drive_index + check_index
            progress = (30 * progress) / (l_drive + l_check)
            print "\r|",
            for i in range(0, 31):
                if i <= progress:
                    print "#",
                else:
                    print " ",
            print "|",

    print "\n",
    if ok:
        print "PASSED"
    else:
        print "FAILED"

    u.finish()

if "__main__" == __name__:
    parser = OptionParser()
    parser.add_option("-d", "--debug",  dest="debug",   action="store_true",    help="Output debug")
    parser.add_option("-t", "--test",   dest="test",                            help="Test to check")
    (options, args) = parser.parse_args()
    main(options)
