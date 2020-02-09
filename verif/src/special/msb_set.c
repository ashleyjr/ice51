#include "uart.h"

#define MSB_SET(x) ((x >> (8*sizeof(x)-1)) & 1)

void main (void){       
   unsigned long a,b;
   unsigned char t;
   
   a = 0;
   do {
      a <<= 1; 
      a |= 1;
      t = MSB_SET(a);
   } while(0 == t); 
    
   uart_tx(a >> 24);
   uart_tx(a >> 16);
   uart_tx(a >> 8); 
   uart_tx(a);
   
   while(1); 
}

// Check Uart:
// 0xFF
// 0xFF
// 0xFF
// 0xFF
