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
    RX_BUFFER_SIZE = 1024

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

    def tx(self, d):
        self.ser.write(chr(d))
        return

    def rx(self):
        while(self.rx_buf_tail == self.rx_buf_head):
            pass
        d = self.rx_buf[self.rx_buf_tail]
        self.rx_buf_tail += 1
        self.rx_buf_tail %= self.RX_BUFFER_SIZE
        return d

    def finish(self):
        self.stop = True
        return

def main(options):

    u = uart()

    print "Connected:     " + u.getName()
    print "Running test:  " + options.test
    h = options.test.replace(".c",".hex")
    print "Loading hex:   " + h

    f = open(h, 'r')
    data = f.read()
    f.close()

    byts = 0
    for d in data.split('\n')[0:-1]:
        c = int('0x'+d, 16)
        u.tx(c)
        byts += 1

    print "Bytes written: " + str(byts)

    for i in range(0,10):
        time.sleep(0.1)
        print u.rx()

    u.finish()

if "__main__" == __name__:
    parser = OptionParser()
    parser.add_option("-t", "--test", dest="test", help="Test to check")
    (options, args) = parser.parse_args()
    main(options)
