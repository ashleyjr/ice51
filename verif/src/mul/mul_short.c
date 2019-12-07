#include "ice51.h"

void main (void){       
   char a,b;
   short c;
   for(a=100;a<103;a++){
      c = a * 100;
      
      *data = c >> 8;
      while(0x01 & *cont);
      
      *data = c;
      while(0x01 & *cont);
   }
   while(1); 
}

// Check Uart:
// 0x27
// 0x10
// 0x27 
// 0x74
// 0x27 
// 0xD8
