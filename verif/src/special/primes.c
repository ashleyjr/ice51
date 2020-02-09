#include "uart.h"

unsigned char isprime(unsigned char p){
   unsigned char i,d,t; 
   if(p < 3)
      return 0; 
   for(i=2;i<p;i++){
      d = p / i;
      t = d * i;
      if(p == t)
         return 0;
   }
   return 1;
}

void main (void){       
   unsigned char i;
   for(i=151;i<170;i+=2){
      if(isprime(i)){
         uart_tx(i);
      }
   }
   while(1); 
}

// Check Uart:
// 151
// 157
// 163
// 167
