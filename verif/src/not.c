#include "ice51.h"

void main (void){       
   unsigned char a,c;
   for(a=0;a<5;a++){ 
      c = ~a;
      *data = c;
      while(0x01 & *cont);
   } 
   for(a=255;a>250;a--){ 
      c = ~a;
      *data = c;
      while(0x01 & *cont);
   }
   while(1); 
}

// Check Uart:
// 0xFF
// 0xFE
// 0xFD
// 0xFC
// 0xFB
// 0x00
// 0x01
// 0x02
// 0x03
// 0x04
