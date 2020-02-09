#include "uart.h"

long factorial(long f){
   if(f == 1)
      return 1; 
   else
      return f * factorial(f-1);
}

void main (void){       
   long a;

   a = 12; // Largest factorial in 32 bits

   a = factorial(a);     
  
   uart_tx(a >> 24); 
   uart_tx(a >> 16);
   uart_tx(a >> 8);
   uart_tx(a);
 
   while(1); 
}

// Check Uart:
// 0x1C
// 0x8C
// 0xFC 
// 0x00
