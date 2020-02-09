#include "uart.h"

void main (void){       
   char a,b;
   short c;
   for(a=100;a<103;a++){
      c = a * 100;
      
      uart_tx(c >> 8);
      uart_tx(c);
   }
   while(1); 
}

// Check Uart:
// 0x27
// 0x10
// 0x27 
// 0x74
// 0x27 
// 0xD8
