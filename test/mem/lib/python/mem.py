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

    def clearRx(self):
        while(self.rx_buf_tail != self.rx_buf_head):
            self.rx()


    def finish(self):
        self.stop = True
        return

    def loadDataBuffer(self, data):
        nibbles = []
        nibbles.append(0xf & (data >> 28))
        nibbles.append(0xf & (data >> 24))
        nibbles.append(0xf & (data >> 20))
        nibbles.append(0xf & (data >> 16))
        nibbles.append(0xf & (data >> 12))
        nibbles.append(0xf & (data >> 8))
        nibbles.append(0xf & (data >> 4))
        nibbles.append(0xf & (data >> 0))
        for n in nibbles:
            self.tx((n << 4) | 1)
        return data

    def unloadDataBuffer(self):
        data = 0
        for i in range(0, 4):
            self.tx(0)  # Read
            self.tx(2)  # Shift right
        data |= self.rx()
        data |= self.rx() << 8
        data |= self.rx() << 16
        data |= self.rx() << 24
        return data

    def loadAddrBuffer(self, data):
        nibbles = []
        nibbles.append(0xf & (data >> 28))
        nibbles.append(0xf & (data >> 24))
        nibbles.append(0xf & (data >> 20))
        nibbles.append(0xf & (data >> 16))
        nibbles.append(0xf & (data >> 12))
        nibbles.append(0xf & (data >> 8))
        nibbles.append(0xf & (data >> 4))
        nibbles.append(0xf & (data >> 0))
        for n in nibbles:
            self.tx((n << 4) | 4)
        return data

    def unloadAddrBuffer(self):
        data = 0
        for i in range(0, 4):
            self.tx(3)  # Read
            self.tx(5)  # Shift right
        data |= self.rx()
        data |= self.rx() << 8
        data |= self.rx() << 16
        data |= self.rx() << 24
        return data


def main():

    u = uart()

    print "Connected:     " + u.getName()

    print " - Checking LEDs"

    pattern = [ 0x01, 0x00, 0x01, 0x00,
                0x02, 0x04, 0x08, 0x10, 0x00,
                0x1E, 0x00, 0x1E, 0x00          ]
    for p in pattern:
        u.tx(p)
        time.sleep(0.2)

    u.clearRx()

    print " - Checking data buffer"

    o = u.loadDataBuffer(0x12345678)
    i = u.unloadDataBuffer()

    if o == i:
        print "   > PASS"

    print " - Checking addr buffer"

    o = u.loadDataBuffer(0x87654321)
    i = u.unloadDataBuffer()

    if o == i:
        print "   > PASS"




    print "Finished"
    u.finish()

if "__main__" == __name__:
    main()
