#include "ice51.h"
void main (void){
   unsigned char a,b;
   unsigned short c;
   while(1){
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
}
