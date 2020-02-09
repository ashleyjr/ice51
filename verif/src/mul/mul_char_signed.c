#include "uart.h"

void main (void){       
   char a,b,c;
   for(a=-3;a<2;a++){
      for(b=-3;b<2;b++){
         c = a * b;
         uart_tx(c);
      }
   }
   while(1); 
}

// Check Uart:
// 9
// 6
// 3
// 0
// -3 
// 6
// 4
// 2
// 0
// -2
// 3
// 2
// 1
// 0
// -1
// 0
// 0
// 0
// 0
// 0
// -3
// -2
// -1
// 0
// 1

