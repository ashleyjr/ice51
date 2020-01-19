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

    
      // Load data 
      #(50*SAMPLE_TB)   uart_send(8'h11); 
      #(50*SAMPLE_TB)   uart_send(8'h21); 
      #(50*SAMPLE_TB)   uart_send(8'h31); 
      #(50*SAMPLE_TB)   uart_send(8'h41); 
      #(50*SAMPLE_TB)   uart_send(8'h51); 
      #(50*SAMPLE_TB)   uart_send(8'h61); 
      #(50*SAMPLE_TB)   uart_send(8'h71); 
      #(50*SAMPLE_TB)   uart_send(8'h81);  
     
      // Echo data
      repeat(4) begin
         #(50*SAMPLE_TB)      uart_send(8'h00); 
         #(50*SAMPLE_TB)      uart_send(8'h02); 
      end

      // Load data 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'hA1);  
     
      // Load addr 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'hF4); 
      #(50*SAMPLE_TB)   uart_send(8'hF4);

      // Write 
      #(50*SAMPLE_TB)   uart_send(8'h06); 

      // Load data 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'h01); 
      #(50*SAMPLE_TB)   uart_send(8'hB1);  
     
      // Load addr 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'hF4); 
      #(50*SAMPLE_TB)   uart_send(8'hE4);

      // Write 
      #(50*SAMPLE_TB)   uart_send(8'h06); 

      // Load addr 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'h04); 
      #(50*SAMPLE_TB)   uart_send(8'hF4); 
      #(50*SAMPLE_TB)   uart_send(8'hF4);

      // Read
      #(50*SAMPLE_TB)   uart_send(8'h07); 


      #100000
      $finish;
	end

endmodule
