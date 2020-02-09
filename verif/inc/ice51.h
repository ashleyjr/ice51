#ifndef ICE51_H
#define ICE51_H

__xdata unsigned char * __code rst = 0x205;
__xdata unsigned char * __code rx_data = 0x203;
__xdata unsigned char * __code rx_cont = 0x202;
__xdata unsigned char * __code data = 0x201;
__xdata unsigned char * __code cont = 0x200;

#endif

unsigned char uart_rx(void);

void uart_tx(unsigned char a);

