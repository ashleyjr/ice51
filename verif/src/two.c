#include "ice51.h"

void main (void){       
   *data = 0xBB;
   while(0x01 & *cont);
   *data = 0xCC;
   while(1); 
}

// Check Uart:
// 0xBB
// 0xCC
