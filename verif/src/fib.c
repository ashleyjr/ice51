__xdata unsigned char * __code d = 0x201;
__xdata unsigned char * __code c = 0x200;

void main (void){       
   char i;
   unsigned char l,m;
   l = 1;
   m = 1;
   *d = l;
   for(i=0;i<12;i++){
      while(0x01 & *c);
      m = l + m;
      l = l ^ m;  // XOR swap
      m = l ^ m;
      l = l ^ m;
      *d = m;
   }
   while(1); 
}

// Check Uart:
// 0x01
// 0x01
// 0x02
// 0x03
// 0x05
// 0x08
// 0x0D
// 0x15
// 0x22
// 0x37
// 0x59
// 0x90
// 0xE9
