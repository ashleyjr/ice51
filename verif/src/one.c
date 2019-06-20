__xdata unsigned char * __code d = 0x201;

void main (void){      
   *d = 0xBB;
   while(1); 
}

// Check Uart:
// 0xBB
