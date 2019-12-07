#include "ice51.h"

void main (void){       
   unsigned long a,b,c;
   a=1777;
   for(b=10;b<13;b++){  
      c = a / b;
      
      while(0x01 & *cont);
      *data = c >> 24;
      while(0x01 & *cont);
      *data = c >> 16;
      while(0x01 & *cont);
      *data = c >> 8;
      while(0x01 & *cont);
      *data = c;
   }     
   while(1); 
}

// Check Uart:
// 0
// 0
// 0
// 177
// 0
// 0
// 0
// 161
// 0
// 0
// 0
// 148

