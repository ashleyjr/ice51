#include "uart.h"

void main (void){       
   unsigned char a;
   unsigned short b;
   while(1){
      a = uart_rx();
      b = a * a;
      uart_tx(b);
      uart_tx(b >> 8);
   }; 
}

/// Drive Uart:
// 0x08
// p
// 0xFC
// End

// Check Uart:
// 0x40
// 0x00
// p
// 0x10
// 0xF8
// End

