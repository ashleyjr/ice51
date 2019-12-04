#include "ice51.h"

void main (void){        
   unsigned char i;
   float a;
   a = 2;
   // Loop to avoid opt 10.5 + 10.5
   for(i=0;i<1;i++){
      a += 2;
   }
   i = (unsigned char)a;
   *data = i;  
   while(0x01 & *cont); 
   while(1); 
}

// Check Uart:
// 4
