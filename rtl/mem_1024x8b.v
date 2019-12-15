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
      wire  [15:0]   s_wdata;
      wire           we_a;
      wire           we_b;

      assign we_a = i_we &  i_addr[0];
      assign we_b = i_we & ~i_addr[0];
      
      always@(posedge i_clk or negedge i_nrst) begin 
         if(!i_nrst)    a_n_b <= 1'b0; 
         else           a_n_b <= i_addr[0];  
      end 

      assign o_rdata = a_n_b ? m_rdata_a : m_rdata_b;

      assign m_rdata_a = { s_rdata_a[14],
                           s_rdata_a[12],
                           s_rdata_a[10],
                           s_rdata_a[8],
                           s_rdata_a[6],
                           s_rdata_a[4],
                           s_rdata_a[2],
                           s_rdata_a[0]  }; 
      assign m_rdata_b = { s_rdata_b[14],
                           s_rdata_b[12],
                           s_rdata_b[10],
                           s_rdata_b[8],
                           s_rdata_b[6],
                           s_rdata_b[4],
                           s_rdata_b[2],
                           s_rdata_b[0]  }; 
      assign s_wdata = {1'bx,
                        i_wdata[7],
                        1'bx,
                        i_wdata[6],
                        1'bx,
                        i_wdata[5],
                        1'bx,
                        i_wdata[4],
                        1'bx,
                        i_wdata[3],
                        1'bx,
                        i_wdata[2],
                        1'bx,
                        i_wdata[1],
                        1'bx,
                        i_wdata[0] };
      SB_RAM40_4K #(
         .WRITE_MODE (32'sd0  ),
         .READ_MODE  (32'sd0  )
      ) ram_a (
         .MASK       (16'hxxxx      ),
         .RDATA      (s_rdata_a     ),
         .RADDR      (i_addr[8:1]   ),
         .RCLK       (i_clk         ),
         .RCLKE      (1'b1          ),
         .RE         (1'b1          ),
         .WADDR      (i_addr[8:1]   ),
         .WCLK       (i_clk         ),
         .WCLKE      (1'b1          ),
         .WDATA      (s_wdata       ),
         .WE         (we_a          )
      );
      SB_RAM40_4K #(
         .WRITE_MODE (32'sd0  ),
         .READ_MODE  (32'sd0  )
      ) ram_b (
         .MASK       (16'hxxxx      ),
         .RDATA      (s_rdata_b     ),
         .RADDR      (i_addr[8:1]   ),
         .RCLK       (i_clk         ),
         .RCLKE      (1'b1          ),
         .RE         (1'b1          ),
         .WADDR      (i_addr[8:1]   ),
         .WCLK       (i_clk         ),
         .WCLKE      (1'b1          ),
         .WDATA      (s_wdata       ),
         .WE         (we_b          )
      );
   `endif

endmodule

