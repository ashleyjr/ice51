#include "uart.h"

const char debug[6] = {'d','e','b','u','g','\0'};

void main (void){        
   char i;
   i = 0;
   while(debug[i] != '\0'){
      uart_tx(debug[i]); 
      i++;
   } 
   while(1); 
}

// Check Uart:
// 'd'
// 'e'
// 'b'
// 'u'
// 'g'
