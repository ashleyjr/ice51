__xdata unsigned char * __code data = 0x201;
__xdata unsigned char * __code cont = 0x200;

void main (void){        
   int i;
   char a,b;
   i = 32766;
   while((i < -32765) || (i > 32765)){ 
      a = i >> 8;
      b = i;
      *data = a;  
      while(0x01 & *cont);
      *data = b;  
      while(0x01 & *cont); 
      i++;
   }
   
   while(1); 
}

// Check Uart:
// 0x7f
// 0xfe
// 0x7f
// 0xff
// 0x80
// 0x00
// 0x80
// 0x01
// 0x80
// 0x02
