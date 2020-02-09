#include "uart.h"

void main (void){       
   uart_tx(0xBB);
   uart_tx(0xCC);
   while(1); 
}

// Check Uart:
// 0xBB
// 0xCC
