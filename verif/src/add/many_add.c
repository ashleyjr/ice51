#include "ice51.h"

void main (void){        
   unsigned char a,b,c,d,e,f,g,h,i;
   a = 1;
   b = 1;
   c = a + b;                          uart_tx(c);
   d = a + b + c;                      uart_tx(d); 
   e = a + b + c + d;                  uart_tx(e); 
   f = a + b + c + d + e;              uart_tx(f); 
   g = a + b + c + d + e + f;          uart_tx(g); 
   h = a + b + c + d + e + f + g;      uart_tx(h);
   i = a + b + c + d + e + f + g + h;  uart_tx(i);
   while(1); 
}

// Check Uart:
// 0x02
// 0x04
// 0x08
// 0x10
// 0x20
// 0x40
// 0x80
