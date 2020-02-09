#include "ice51.h"
void main (void){
   unsigned int i;
   unsigned char a,b;
   unsigned short c;
   for(i=0;i<1000;i++){
      while(0 == *rx_cont);
      a = *rx_data;
      while(0 == *rx_cont);
      b = *rx_data;
      c = a * b;
      while(0x01 & *cont);
      *data = c;
      while(0x01 & *cont);
      *data = c >> 8;
   }
   *rst = 0;
}
