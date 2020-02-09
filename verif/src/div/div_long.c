#include "uart.h"

void main (void){       
   unsigned long a,b,c;
   a=1777;
   for(b=10;b<13;b++){  
      c = a / b; 
      uart_tx(c >> 24);
      uart_tx(c >> 16);
      uart_tx(c >> 8); 
      uart_tx(c);
   }     
   while(1); 
}

// Check Uart:
// 0
// 0
// 0
// 177
// 0
// 0
// 0
// 161
// 0
// 0
// 0
// 148

