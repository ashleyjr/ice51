#include "ice51.h"

void main (void){        
   unsigned char a,b,c,d,e,f,g,h,i;
   a = 1;
   b = 1;
   c = a + b;                          while(0x01 & *cont); *data = c;
   d = a + b + c;                      while(0x01 & *cont); *data = d; 
   e = a + b + c + d;                  while(0x01 & *cont); *data = e; 
   f = a + b + c + d + e;              while(0x01 & *cont); *data = f; 
   g = a + b + c + d + e + f;          while(0x01 & *cont); *data = g; 
   h = a + b + c + d + e + f + g;      while(0x01 & *cont); *data = h;
   i = a + b + c + d + e + f + g + h;  while(0x01 & *cont); *data = i;
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
