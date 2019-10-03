#include "ice51.h"

void main (void){       
   unsigned int a,b,i,j,k,l; 
   unsigned char au, al, bu, bl; 
   unsigned long temp, acc;


   for(a=1000;a<1003;a++){
      for(b=1000;b<1003;b++){
       
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
                  
         *data = acc >> 24;
         while(0x01 & *cont);
 
         *data = acc >> 16;
         while(0x01 & *cont);     

         *data = acc >> 8;
         while(0x01 & *cont);
         
         *data = acc;
         while(0x01 & *cont);
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

