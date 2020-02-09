void main (void){       
   char a,b;
   while(1){
      a = uart_rx();
      b = uart_rx();
      a = a + b;
      uart_tx(a);
   } 
}

// Drive Uart:
// 0x10
// 0x10
// p
// 0x00
// 0x00
// p
// 0xAA
// 0xAA
// End

// Check Uart:
// 0x20
// p
// 0x00
// p
// 0x54
// End

