#include "uart.h"

char add(char a, char b){
   return a + b;
}

void main (void){       
   char i,j;
   for(i=13;i<15;i++){
      for(j=13;j<15;j++){
         uart_tx(add(i,j));  
      }
   }
   while(1); 
}

// Check Uart:
// 26
// 27
// 27
// 28
