#include "ice51.h"

void main (void){       
   unsigned char a,b;
   for(a=10;a<13;a++){ 
      b = 100 / a;
      *data = b;
      while(0x01 & *cont);
   }
   for(a=19;a<22;a++){ 
      b = 255 / a;
      *data = b;
      while(0x01 & *cont);
   }
   while(1); 
}

// Check Uart:
// 0x0A
// 0x09
// 0x08
// 0x0D
// 0x0C
// 0x0C
