__xdata unsigned char * __code d = 0x201;
__xdata unsigned char * __code c = 0x200;

void main (void){       
   *d = 0xBB;
   while(0x01 & *c);
   *d = 0xCC;
   while(1); 
}

// Check Uart:
// 0xBB
// 0xCC
