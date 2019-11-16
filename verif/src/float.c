#include "ice51.h"

void main (void){        
   unsigned char i;
   float a,b;
   a = 7.7;
   b = 1.2;
   for(i=0;i<10;i++){
      a += b;
   }
   i = (unsigned char)a;
   *data = i;  
   while(0x01 & *cont); 
   while(1); 
}

// Check Uart:
// 10 
