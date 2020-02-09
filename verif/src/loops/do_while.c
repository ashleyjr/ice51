#include "uart.h"

void main (void){       
   unsigned char sum = 0;
   unsigned char x   = 10;
   do{
      sum += x;
   }while(--x); 

   uart_tx(sum);
   
   while(1); 
}

// Check Uart:
// 55
