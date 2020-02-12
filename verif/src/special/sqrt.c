#include "uart.h"
void main (void){       
   unsigned char i;
   unsigned long num, sqrt, p0_sqrt, p1_sqrt;
   while(1){
      for(i=0;i<4;i++){
         num = (num << 8) | uart_rx();
      }
      sqrt    = num / 2;
      p0_sqrt = 0; 
      p1_sqrt = 0;
      while(1){ 
         if(sqrt == p0_sqrt){
            break;
         }
         if(sqrt == p1_sqrt){
            break;
         }
         p1_sqrt = p0_sqrt;
         p0_sqrt = sqrt;
         sqrt    = ((num / sqrt) + sqrt) / 2; 
      }
      if(p0_sqrt < sqrt){
         sqrt = p0_sqrt; 
      }
      uart_tx(sqrt >> 24); 
      uart_tx(sqrt >> 16);
      uart_tx(sqrt >> 8);
      uart_tx(sqrt);
   }
}

// Drive Uart:
// 0
// 0
// 0
// 81
// p
// 0x00
// 0x01
// 0x02
// 0x01
// p
// 0xFF
// 0xFF
// 0xFF
// 0xFF
// End
// Check Uart:
// 0
// 0
// 0
// 9
// p
// 0x00
// 0x00
// 0x01
// 0x01
// p
// 0x00
// 0x00
// 0xFF
// 0xFF
// End
