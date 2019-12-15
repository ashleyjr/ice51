`timescale 1ns/1ps

module ice51_tb;

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

   ice51_top ice51_top (
      .i_clk      (i_clk      ),
      .i_nrst     (i_nrst     ),
      .i_uart_rx  (i_uart_rx  ),
      .o_uart_tx  (o_uart_tx  )
   );

	initial begin
		i_clk = 0;
      while(1) begin
			#(CLK_PERIOD_NS/2)   i_clk = 0;
			#(CLK_PERIOD_NS/2)   i_clk = 1;
		end
	end

	initial begin
		$dumpfile("ice51.vcd");
	   $dumpvars(0,ice51_tb); 
	   
   end

   integer     i;
   reg [7:0]   load_mem    [0:MEM_SIZE-1];
   reg [11:0]  uart_checks [0:CHECK_SIZE-1];

   initial begin 
      $readmemh("load_mem.hex",  load_mem);
      $readmemh("checks.hex",    uart_checks);
       //for(i=0;i<MEM_SIZE;i=i+1)     $dumpvars(0,ice51_tb.load_mem[i]); 
       //for(i=0;i<CHECK_SIZE;i=i+1)   $dumpvars(0,ice51_tb.uart_checks[i]); 
       //for(i=0;i<MEM_SIZE;i=i+1)     $dumpvars(0,ice51_tb.ice51_top.code.mem[i]); 
      for(i=0;i<8;i=i+1)               $dumpvars(0,ice51_tb.ice51_top.registers.mem[i]); 
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

   integer   j;
   integer   rx_ptr; 
   integer   exp_rx;
   reg [7:0] uart_tx;
   reg [7:0] rxs [0:CHECK_SIZE-1];

   initial begin
      // Expected rxs
      j = 0;
      exp_rx = 0;
      while(1 == uart_checks[j][8]) begin
         exp_rx = exp_rx + 1;
         j = j + 1;
      end
      
      // Wait for reset
      repeat(2) 
         @(posedge i_nrst);
      
      // Look for expected
      rx_ptr = 0;
      while(rx_ptr != exp_rx) begin 
         uart_tx = 0; 
         while(o_uart_tx) 
            @(posedge i_clk); 
         for(j=7;j>-1;j=j-1) begin
            #SAMPLE_TB  uart_tx[j] = o_uart_tx;
         end 
         #SAMPLE_TB
         $display("UART RX: 0x%x (exp == 0x%x)",uart_tx,uart_checks[rx_ptr][7:0]); 
         
         if(uart_tx != uart_checks[rx_ptr][7:0]) begin
            repeat(1000)
               @(posedge i_clk);
            $display("ERROR: Unexpected rx");
            $finish;
         end
         
         rxs[rx_ptr] = uart_tx;
         rx_ptr = rx_ptr + 1; 
      end

      // Check no unwanted rxs
      repeat(10000) begin
         @(posedge i_clk);
         if(!o_uart_tx) begin
            repeat(1000)
               @(posedge i_clk);     
            $display("ERROR: Unwanted rx");
            $finish;
         end
      end

      // All is well
      $display("PASSED");
      $finish;
   end
   
   initial begin 
					   i_uart_rx   = 1;
                  i_nrst		= 1;
      #1000       i_nrst      = 0;
      #1000       i_nrst      = 1;

      `ifndef PRELOAD
         for(i=0;i<MEM_SIZE;i=i+1)
            #(SAMPLE_TB) uart_send(load_mem[i]);
      `endif

      #10000000
      $display("ERROR: Timeout");
      $finish;
	end

endmodule
