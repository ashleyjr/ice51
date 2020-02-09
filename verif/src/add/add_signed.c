#include "uart.h"

void main (void){       
   char i;
   for(i=-5;i<6;i++){
      uart_tx(i);
   }
   while(1); 
}

// Check Uart:
// -5
// -4
// -3
// -2
// -1
// 0
// 1
// 2
// 3
// 4
// 5
