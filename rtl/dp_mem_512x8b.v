`timescale 1ns/1ps
module dp_mem_512x8b (
   input    wire        i_nrst,
   input    wire        i_clk,
   input    wire        i_we,
   input    wire  [8:0] i_waddr, 
   input    wire  [7:0] i_wdata, 
   input    wire  [8:0] i_raddr, 
   output   wire  [7:0] o_rdata
);
 
   `ifdef SIM
      reg [7:0] mem        [511:0];
      reg [8:0] p0_raddr;

      assign o_rdata = mem[p0_raddr];

      always@(posedge i_clk or negedge i_nrst) begin 
         if(!i_nrst) p0_raddr <= 'd0; 
         else        p0_raddr <= i_raddr;
      end 

      always@(posedge i_clk) begin  
         if(i_we)    mem[i_waddr] <= i_wdata; 
      end
   `else
      wire  [15:0]   s_rdata;
      wire  [15:0]   s_wdata;

      assign o_rdata = {s_rdata[14],
                        s_rdata[12],
                        s_rdata[10],
                        s_rdata[8],
                        s_rdata[6],
                        s_rdata[4],
                        s_rdata[2],
                        s_rdata[0]  }; 
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
         .WRITE_MODE (32'sd1  ),
         .READ_MODE  (32'sd1  )
      ) ram (
         .MASK       (16'hxxxx),
         .RDATA      (s_rdata ),
         .RADDR      (i_raddr ),
         .RCLK       (i_clk   ),
         .RCLKE      (1'b1    ),
         .RE         (1'b1    ),
         .WADDR      (i_waddr ),
         .WCLK       (i_clk   ),
         .WCLKE      (1'b1    ),
         .WDATA      (s_wdata ),
         .WE         (i_we    )
      );

   `endif

endmodule
