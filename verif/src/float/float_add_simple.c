#include "uart.h"

void main (void){        
   unsigned char i;
   float a;
   
   a = 6.4; 
   for(i=0;i<9;i++){
      a += 6.4;
   }
   i = (unsigned char)a;
   uart_tx(i); 
   
   a = 25.5; 
   for(i=0;i<9;i++){
      a += 25.5;
   }
   i = (unsigned char)a; 
   uart_tx(i);   
   
   a  = 0.1;
   a += 0.4;
   for(i=0;i<5;i++){
      a += 0.1;
   }
   i = (unsigned char)a;
   uart_tx(i);  
   
   while(1); 
}

// Check Uart:
// 64
// 255
// 1
