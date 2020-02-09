#include "uart.h"
#define LEN 20

void main (void){        
   unsigned char i,add;
   unsigned char adds[LEN];
   adds[0] = 1;
   for(i=1;i<(LEN+1);i++){
      adds[i] = adds[i-1] + i;
   }
   for(i=0;i<(LEN+1);i++){
      add = adds[i];
      uart_tx(add);
   }
   while(1); 
}

// Check Uart:
// 0x01
// 0x02
// 0x04
// 0x07
// 0x0b
// 0x10
// 0x16
// 0x1d
// 0x25
// 0x2e
// 0x38
// 0x43
// 0x4f
// 0x5c
// 0x6a
// 0x79
// 0x89
// 0x9a
// 0xac
// 0xbf
// 0xd3
