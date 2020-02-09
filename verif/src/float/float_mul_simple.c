#include "uart.h"

void main (void){        
   unsigned char i,j;
   float a;
   
   a = 2.5; 
   for(i=0;i<1;i++){
      a *= 100;
      j = (unsigned char)a;
      uart_tx(j); 
   }
   while(1); 
}

// Check Uart: 
// 250
