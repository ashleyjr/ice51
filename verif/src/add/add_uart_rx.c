#include "ice51.h"

void main (void){       
   char a,b;
   while(1){
      while(0 == *rx_cont);
      a = *rx_data;
      while(0 == *rx_cont);
      b = *rx_data;
      a = a + b;
      *data = a;
   } 
}

// Drive Uart:
// 0x10
// 0x10
// 0x00
// 0x00
// 0xAA
// 0xAA
// End

// Check Uart:
// 0x20
// 0x00
// 0x54
// End

