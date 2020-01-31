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
      while(0x01 & *cont);
   } 
}

// Drive Uart:
// 0x10
// 0x10
// End

// Check Uart:
// 0x20
// End

