#include "ice51.h"
void main (void){
   int i;
   char a,b;
   for(i=0;i<1000;i++){
      while(0 == *rx_cont);
      a = *rx_data;
      while(0 == *rx_cont);
      b = *rx_data;
      a = a + b;
      while(0x01 & *cont);
      *data = a;
   }
   *rst = 0;
}
