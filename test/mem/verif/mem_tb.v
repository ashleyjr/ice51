`timescale 1ns/1ps

module mem_tb;

   // CLK = 12 MHz
	parameter   CLK_PERIOD_NS = 83;

   // Mem size
   parameter   MEM_SIZE = 1024;

   // Check size
   parameter   CHECK_SIZE = 128;

   // BAUD = 115200
   parameter   SAMPLE_TB = 8681;
   
   reg	      i_clk;
	reg	      i_nrst; 
   reg         i_uart_rx;
   wire        o_uart_tx; 

   mem mem (
      .i_clk   (i_clk      ),
      .i_nrst  (i_nrst     ),
      .i_rx    (i_uart_rx  ),
      .o_tx    (o_uart_tx  )
   );

	initial begin
		i_clk = 0;
      while(1) begin
			#(CLK_PERIOD_NS/2)   i_clk = 0;
			#(CLK_PERIOD_NS/2)   i_clk = 1;
		end
	end

	initial begin
		$dumpfile("mem.vcd");
	   $dumpvars(0,mem_tb); 
	   
   end

   task uart_send;
      input [7:0] send;
      integer i;
      begin
         i_uart_rx = 0;
         for(i=0;i<=7;i=i+1) begin
            #SAMPLE_TB  i_uart_rx = send[i];
         end
         #SAMPLE_TB  i_uart_rx = 1;
      end
   endtask

   integer i;
  
   initial begin 
					         i_uart_rx   = 1;
                        i_nrst		= 1;
      #1000             i_nrst      = 0;
      #1000             i_nrst      = 1;

     
      #(100*SAMPLE_TB)  uart_send(8'hAA); 

      #7777

      #(100*SAMPLE_TB)  uart_send(8'h00); 

      #3333

      #(100*SAMPLE_TB)  uart_send(8'h23); 




      #100000
      $finish;
	end

endmodule
