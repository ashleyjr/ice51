#include "ice51.h"

void main (void){       
   unsigned char a;
   unsigned short b;
   while(1){
      while(0 == *rx_cont);
      a = *rx_data;
      b = a * a;
      while(0x01 & *cont);
      *data = b;
      while(0x01 & *cont);
      *data = b >> 8;
   }; 
}

/// Drive Uart:
// 0x08
// p
// 0xFC
// End

// Check Uart:
// 0x40
// 0x00
// p
// 0x10
// 0xF8
// End

