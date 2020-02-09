#include "uart.h"

void main (void){        
   int i;
   char a,b;
   i = -2;
   while(i < 3){ 
      a = i >> 8;
      b = i;
      uart_tx(a);
      uart_tx(b);
      i++;
   }
   
   while(1); 
}

// Check Uart:
// 0xff
// 0xfe
// 0xff
// 0xff
// 0x00
// 0x00
// 0x00
// 0x01
// 0x00
// 0x02
