#include "ice51.h"
#include "uart.h"

unsigned char uart_rx(void){
   while(0 == *rx_cont);
   return *rx_data;
}

void uart_tx(unsigned char a){
   while(0x01 & *cont);
   *data = a;
}

