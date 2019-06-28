#include "ice51.h"

void main (void){       
   *d = 0xBB;
   while(0x01 & *c);
   *d = 0xCC;
   while(1); 
}

// Check Uart:
// 0xBB
// 0xCC
