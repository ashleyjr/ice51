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


    '''
    Phase check
    '''
    drive_phases = 1
    for d in drives.split('\n')[0:-1]:
        if d == '200':
            drive_phases += 1
    check_phases = 1
    for c in checks.split('\n')[0:-1]:
        if c == '200':
            check_phases += 1


    if drive_phases != check_phases:
        print "Phases mismatch"
        print "FAILED"
        sys.exit(0)
    print "Phases:           %d" % (check_phases-1)

    '''
    Build phases
    '''
    d_ptr = 0
    c_ptr = 0
    phases = []
    ds = drives.split('\n')[0:-1]
    cs = checks.split('\n')[0:-1]
    for i in range(0, check_phases):
        phase = {}

        drive = []
        while ds[d_ptr] != '200':
            if (ds[d_ptr] != '000'):
                drive.append(int(ds[d_ptr][1:3],16))
            d_ptr += 1
            if d_ptr == len(ds):
                break
        d_ptr += 1

        check = []
        while cs[c_ptr] != '200':
            if (cs[c_ptr] != '000'):
                check.append(int(cs[c_ptr][1:3],16))
            c_ptr += 1
            if c_ptr == len(cs):
                break
        c_ptr += 1

        if (len(check) > 0) and (len(drive) > 0):
            phase['check'] = check
            phase['drive'] = drive
            phases.append(phase)

    ok = True
    last_progress = 0
    for p in range(len(phases)):
        for t in phases[p]['drive']:
            u.tx(t)
            if options.debug:
                print "UART_TX: " + str(hex(t))
        for c in phases[p]['check']:
            a = u.rx()
            if options.debug:
                print "UART RX: " +str(hex(a)) + ", Exp: " +str(hex(c))
            if a != c:
                ok = False
                break
        if not ok:
            break

        if not options.debug:
            progress = (30 * (p+1)) / len(phases)
            sys.stdout.write("\r|")
            for i in range(0, 31):
                if i <= progress:
                    sys.stdout.write("#")
                else:
                    sys.stdout.write(" ")
            sys.stdout.write("|\r")
            last_progress = progress

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
