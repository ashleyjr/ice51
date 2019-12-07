#include "ice51.h"


void main (void){       
   int a, b, c; 

   for(a=100;a<103;a++){
      for(b=100;b<103;b++){
      
         c = a * b;     

         *data = c >> 8;
         while(0x01 & *cont);
         
         *data = c;
         while(0x01 & *cont);
      }
   }
   while(1); 
}

// Check Uart:
// 0x27
// 0x10
// 0x27
// 0x74
// 0x27
// 0xD8
// 0x27
// 0x74
// 0x27
// 0xD9
// 0x28
// 0x3E
// 0x27
// 0xD8
// 0x28
// 0x3E
// 0x28
// 0xA4
