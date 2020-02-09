#include "uart.h"

unsigned long mul(unsigned int a, unsigned int b){
   unsigned int i,j,k,l; 
   unsigned char au, al, bu, bl; 
   unsigned long temp, acc;

   
   au = a >> 8;
   al = a;
   bu = b >> 8;
   bl = b;

   i  = al * bl;
   j  = au * bl;
   k  = al * bu;
   l  = au * bu;
    
   acc   = i; 
   
   temp  = j; 
   temp  = temp << 8;
   temp += acc;
   acc   = temp;
    
   temp  = k;
   temp  = temp << 8;
   temp += acc;
   acc   = temp;

   temp  = l;
   temp  = temp << 16;
   temp += acc;
   acc   = temp; 
   
   return acc;
}

void main (void){       
   unsigned int a,b; 
   unsigned long acc;

   for(a=1000;a<1003;a++){
      for(b=1000;b<1003;b++){
      
         acc = mul(a,b); 
                  
         uart_tx(acc >> 24);
         uart_tx(acc >> 16); 
         uart_tx(acc >> 8);
         uart_tx(acc);
      }
   }
   while(1); 
}

// Check Uart:
// 0x00
// 0x0F
// 0x42 
// 0x40
// 0x00
// 0x0F
// 0x46
// 0x28
// 0x00
// 0x0F
// 0x4A
// 0x10
// 0x00
// 0x0F
// 0x46
// 0x28
// 0x00
// 0x0F
// 0x4A
// 0x11
// 0x00
// 0x0F
// 0x4D
// 0xFA
// 0x00
// 0x0F
// 0x4A
// 0x10
// 0x00
// 0x0F
// 0x4D
// 0xFA
// 0x00
// 0x0F
// 0x51
// 0xE4

