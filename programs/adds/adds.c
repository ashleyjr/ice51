#include "ice51.h"
void main (void){
   char a,b;
   while(1){
      while(0 == *rx_cont);
      a = *rx_data;
      while(0 == *rx_cont);
      b = *rx_data;
      a = a + b;
      while(0x01 & *cont);
      *data = a;
   }
}
