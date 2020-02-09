#include "uart.h"

void main (void){        
   long i;
   char a,b,c,d;
   i = -2;
   while(i < 3){ 
      a = i >> 24;
      b = i >> 16;
      c = i >> 8;
      d = i;
      uart_tx(a);
      uart_tx(b);
      uart_tx(c);
      uart_tx(d);
      i++;
   }
   
   while(1); 
}

// Check Uart:
// 0xff
// 0xff
// 0xff
// 0xfe
// 0xff
// 0xff
// 0xff
// 0xff
// 0x00
// 0x00
// 0x00
// 0x00
// 0x00
// 0x00
// 0x00
// 0x01
// 0x00
// 0x00
// 0x00
// 0x02
