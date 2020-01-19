`timescale 1ns/1ps
module mem_1024x8b (
   input    wire        i_nrst,
   input    wire        i_clk,
   input    wire  [9:0] i_addr,
   input    wire        i_we,
   input    wire  [7:0] i_wdata,   
   output   wire  [7:0] o_rdata
);
   
   `ifdef SIM
      reg   [7:0] mem       [1023:0];
      reg   [9:0] p0_raddr; 
  
      `ifdef PRELOAD
         initial $readmemh("load_mem.hex", mem);
      `endif

      assign o_rdata = mem[p0_raddr];

      always@(posedge i_clk or negedge i_nrst) begin 
         if(!i_nrst) p0_raddr <= 'd0; 
         else        p0_raddr <= i_addr;
      end 

      always@(posedge i_clk) begin  
         if(i_we)    mem[i_addr] <= i_wdata; 
      end
   
   `else
      
      wire  [15:0]   s_rdata_a;
      wire  [15:0]   s_rdata_b;
      wire  [15:0]   s_wdata_a;
      wire  [15:0]   s_wdata_b;
   
            
      assign o_rdata  = {  s_rdata_b[13],
                           s_rdata_b[9],
                           s_rdata_b[5],
                           s_rdata_b[1],
                           s_rdata_a[13],
                           s_rdata_a[9],
                           s_rdata_a[5],
                           s_rdata_a[1]  }; 
      
      assign s_wdata_a = { 2'bxx,
                           i_wdata[3],
                           3'bxxx,
                           i_wdata[2],
                           3'bxxx,
                           i_wdata[1],
                           3'bxxx,
                           i_wdata[0],
                           1'bx           };
      
      assign s_wdata_b = { 2'bxx,
                           i_wdata[7],
                           3'bxxx,
                           i_wdata[6],
                           3'bxxx,
                           i_wdata[5],
                           3'bxxx,
                           i_wdata[4],
                           1'bx           };
      SB_RAM40_4K #(
         .WRITE_MODE (32'sd2  ),
         .READ_MODE  (32'sd2  )
      ) ram_a (
         .MASK       (16'hxxxx      ),
         .RDATA      (s_rdata_a     ),
         .RADDR      (i_addr        ),
         .RCLK       (i_clk         ),
         .RCLKE      (1'b1          ),
         .RE         (1'b1          ),
         .WADDR      (i_addr        ),
         .WCLK       (i_clk         ),
         .WCLKE      (1'b1          ),
         .WDATA      (s_wdata_a     ),
         .WE         (i_we          )
      );
      SB_RAM40_4K #(
         .WRITE_MODE (32'sd2  ),
         .READ_MODE  (32'sd2  )
      ) ram_b (
         .MASK       (16'hxxxx      ),
         .RDATA      (s_rdata_b     ),
         .RADDR      (i_addr        ),
         .RCLK       (i_clk         ),
         .RCLKE      (1'b1          ),
         .RE         (1'b1          ),
         .WADDR      (i_addr        ),
         .WCLK       (i_clk         ),
         .WCLKE      (1'b1          ),
         .WDATA      (s_wdata_b     ),
         .WE         (i_we          )
      );
   `endif

endmodule

