#include "ice51.h"

void main (void){       
   char a,b,c;
   for(a=10;a<13;a++){
      for(b=10;b<13;b++){
         c = a * b;
         *data = c;
         while(0x01 & *cont);
      }
   }
   while(1); 
}

// Check Uart:
// 100
// 110
// 120
// 110
// 121 
// 132
// 120
// 132
// 144
