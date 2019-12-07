#include "ice51.h"

void main (void){        
   long i;
   char a,b,c,d;
   i = 2147483646;
   while((i < -2147483645) || (i > 2147483645)){ 
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
// 0x7f
// 0xff
// 0xff
// 0xfe
// 0x7f
// 0xff
// 0xff
// 0xff
// 0x80
// 0x00
// 0x00
// 0x00
// 0x80
// 0x00
// 0x00
// 0x01
// 0x80
// 0x00
// 0x00
// 0x02
