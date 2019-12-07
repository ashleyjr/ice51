#include "ice51.h"

#define MSB_SET(x) ((x >> (8*sizeof(x)-1)) & 1)

void main (void){       
   unsigned long a,b;
   unsigned char t;
   
   a = 0;
   do {
      a <<= 1; 
      a |= 1;
      t = MSB_SET(a);
   } while(0 == t); 
    
   *data = a >> 24;
   while(0x01 & *cont);
   
   *data = a >> 16;
   while(0x01 & *cont);
   
   *data = a >> 8;
   while(0x01 & *cont);
     
   *data = a;
   while(0x01 & *cont);
   
   while(1); 
}

// Check Uart:
// 0xFF
// 0xFF
// 0xFF
// 0xFF
