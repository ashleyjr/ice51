#include "ice51.h"

void main (void){        
   long i;
   char a,b,c,d;
   i = -2;
   while(i < 3){ 
      a = i >> 24;
      b = i >> 16;
      c = i >> 8;
      d = i;
      *data = a;  
      while(0x01 & *cont);
      *data = b;  
      while(0x01 & *cont); 
      *data = c;  
      while(0x01 & *cont);
      *data = d;  
      while(0x01 & *cont); 
      i++;
   }
   
   while(1); 
}

// Check Uart:
// 0xff
// 0xff
// 0xff
// 0xfe
// 0xff
// 0xff
// 0xff
// 0xff
// 0x00
// 0x00
// 0x00
// 0x00
// 0x00
// 0x00
// 0x00
// 0x01
// 0x00
// 0x00
// 0x00
// 0x02
