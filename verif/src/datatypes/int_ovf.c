#include "uart.h"

void main (void){        
   int i;
   char a,b;
   i = 32766;
   while((i < -32765) || (i > 32765)){ 
      a = i >> 8;
      b = i;
      uart_tx(a);
      uart_tx(b);
      i++;
   }
   
   while(1); 
}

// Check Uart:
// 0x7f
// 0xfe
// 0x7f
// 0xff
// 0x80
// 0x00
// 0x80
// 0x01
// 0x80
// 0x02
