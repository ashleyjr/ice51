#include "uart.h"

void main (void){       
   int a, b, c; 

   for(a=100;a<103;a++){
      for(b=100;b<103;b++){
      
         c = a * b;     

         uart_tx(c >> 8);
         uart_tx(c);
      }
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
// 0x27
// 0x74
// 0x27
// 0xD9
// 0x28
// 0x3E
// 0x27
// 0xD8
// 0x28
// 0x3E
// 0x28
// 0xA4
