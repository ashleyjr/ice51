`timescale 1ns/1ps

module ice51_tb;

   // CLK = 12 MHz
	parameter   CLK_PERIOD_NS = 83;

   // Mem size
   parameter   MEM_SIZE = 1024;

   // Check size
   parameter   CHECK_SIZE = 65536;

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
      #20000000
      $display("ERROR: Timeout");
      $finish;
	end

	initial begin
		$dumpfile("ice51.vcd");
	   $dumpvars(0,ice51_tb);  
   end

   integer     i;
   reg [7:0]   load_mem    [0:MEM_SIZE-1];
   reg [11:0]  uart_checks [0:CHECK_SIZE-1];
   reg [11:0]  uart_drives [0:CHECK_SIZE-1];

   initial begin 
      $readmemh("load_mem.hex",  load_mem);
      $readmemh("checks.hex",    uart_checks);
      $readmemh("drives.hex",    uart_drives); 
      for(i=0;i<8;i=i+1)         
         $dumpvars(0,ice51_tb.ice51_top.registers.mem[i]); 
   end
  	
   task uart_tx;
      input [7:0] send;
      integer i;
      begin
         i_uart_rx = 0;
         for(i=0;i<=7;i=i+1) begin
            #SAMPLE_TB  i_uart_rx = send[i];
         end
         #SAMPLE_TB  i_uart_rx = 1;
         #SAMPLE_TB;
      end
   endtask
   
   task uart_rx;
      output [7:0] rx;
      integer i;
      begin
         while(o_uart_tx) 
            @(posedge i_clk); 
         for(j=0;j<8;j=j+1) begin
            #SAMPLE_TB  rx[j] = o_uart_tx;
         end 
         #SAMPLE_TB;
      end
   endtask

   integer     check_phases;
   integer     drive_phases;
   integer     phase;
   integer     j;
   integer     rx_ptr; 
   integer     tx_ptr;
   integer     exp_rx;
   reg [7:0]   rx;
   reg [7:0]   rxs      [0:CHECK_SIZE-1];

   initial begin
      // Check phases
      j = 0;
      check_phases = 1;
      while(4'h0 != uart_checks[j][11:8]) begin
         if(4'h2 == uart_checks[j][11:8]) begin
            check_phases = check_phases + 1;
         end
         j = j + 1;
      end     

      // Drive phases
      j = 0;
      drive_phases = 1;
      while(4'h0 != uart_drives[j][11:8]) begin
         if(4'h2 == uart_drives[j][11:8]) begin
            drive_phases = drive_phases + 1;
         end
         j = j + 1;
      end     

      // Fail of phases do not match
      if(check_phases != drive_phases) begin
         $display("ERROR: Phase mismatch");
         $finish;
      end

      // Reset phase
                  i_uart_rx   = 1;
                  i_nrst		= 1;
      #1000       i_nrst      = 0;
      #1000       i_nrst      = 1;

      // Load code
      `ifndef PRELOAD
         for(i=0;i<MEM_SIZE;i=i+1)
            uart_tx(load_mem[i]);
      `endif


      // Run phases  
      rx_ptr = 0;
      tx_ptr = 0;

      for(phase=0;phase<check_phases;phase=phase+1) begin 
         $display("Phase %d of %d",phase,check_phases-1);
         fork 
            // RX
            begin 
               while(4'h1 == uart_checks[rx_ptr][11:8]) begin
                  uart_rx(rx);
                  $display("UART RX: 0x%x (exp == 0x%x)",rx,uart_checks[rx_ptr][7:0]);
                  if(rx != uart_checks[rx_ptr][7:0]) begin
                     $display("ERROR: Mismatch");
                     $finish;
                  end
                  rx_ptr = rx_ptr + 1;
               end
               rx_ptr = rx_ptr + 1; 
            end
         
            // TX
            begin
            
               while(4'h1 == uart_drives[tx_ptr][11:8])    begin
                  uart_tx(uart_drives[tx_ptr][7:0]);
                  $display("UART TX: 0x%x",uart_drives[tx_ptr][7:0]); 
                  tx_ptr = tx_ptr + 1;
               end
               tx_ptr = tx_ptr + 1;
            end
         join
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


endmodule
