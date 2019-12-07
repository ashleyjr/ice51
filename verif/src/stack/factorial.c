#include "ice51.h"

long factorial(long f){
   if(f == 1)
      return 1; 
   else
      return f * factorial(f-1);
}

void main (void){       
   long a;

   a = 12; // Largest factorial in 32 bits

   a = factorial(a);     
  
   *data = a >> 24;
   while(0x01 & *cont);
   
   *data = a >> 16;
   while(0x01 & *cont);

   *data = a >> 8;
   while(0x01 & *cont);
   
   *data = a;
   while(0x01 & *cont);
 
   while(1); 
}

// Check Uart:
// 0x1C
// 0x8C
// 0xFC 
// 0x00
