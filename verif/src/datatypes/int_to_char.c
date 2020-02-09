#include "uart.h"

void main (void){       
   unsigned char i,a,b,c;
   
   for(i=99;i<200;i+=17){
      
      a = i;
      b = a / 100;
      c = b + 48;

      uart_tx(c);
  
      a -= b*100;
      b = a / 10;
      c = b + 48;
      
      uart_tx(c);
      
      a -= b*10;
      c = a + 48;

      uart_tx(c);

   }
   while(1); 
}

// Check Uart:
// '0'
// '9'
// '9'
// '1'
// '1'
// '6'
// '1'
// '3'
// '3'
// '1'
// '5'
// '0'
// '1'
// '6'
// '7'
// '1'
// '8'
// '4'
