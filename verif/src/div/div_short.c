#include "uart.h"

void main (void){       
   unsigned char a,b;
   for(a=10;a<13;a++){ 
      b = 100 / a;
      uart_tx(b);
   }
   for(a=19;a<22;a++){ 
      b = 255 / a;
      uart_tx(b);
   }
   while(1); 
}

// Check Uart:
// 0x0A
// 0x09
// 0x08
// 0x0D
// 0x0C
// 0x0C
