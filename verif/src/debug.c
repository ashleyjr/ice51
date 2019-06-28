__xdata unsigned char * __code data = 0x201;
__xdata unsigned char * __code cont = 0x200;

const char debug[6] = {'d','e','b','u','g','\0'};

void main (void){        
   char i;
   i = 0;
   while(debug[i] != '\0'){
      *data = debug[i];  
      while(0x01 & *cont);
      i++;
   } 
   while(1); 
}

// Check Uart:
// 'd'
// 'e'
// 'b'
// 'u'
// 'g'
