#include "ice51.h"

void main (void){        
   int i;
   char a,b;
   i = -2;
   while(i < 3){ 
      a = i >> 8;
      b = i;
      *data = a;  
      while(0x01 & *cont);
      *data = b;  
      while(0x01 & *cont); 
      i++;
   }
   
   while(1); 
}

// Check Uart:
// 0xff
// 0xfe
// 0xff
// 0xff
// 0x00
// 0x00
// 0x00
// 0x01
// 0x00
// 0x02
