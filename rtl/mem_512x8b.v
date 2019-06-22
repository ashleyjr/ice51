`timescale 1ns/1ps
module mem_512x8b (
   input    wire        i_nrst,
   input    wire        i_clk,
   input    wire  [8:0] i_addr,
   input    wire        i_we,
   input    wire  [7:0] i_wdata,  
   input    wire        i_re,
   output   wire  [7:0] o_rdata
);
   
   reg   [7:0]    wdata1;
   reg   [8:0]    addr;
   reg            we1;
   reg            re1,re2;
   wire           we;
   wire           re;

   assign   we = i_we | we1 ;

   assign   re = i_re | re1;

   always@(posedge i_clk or negedge i_nrst) begin 
      if(!i_nrst) begin
         wdata1   <= 'd0; 
         we1      <= 'd0; 
         re1      <= 'd0;
      end else begin
         wdata1   <= i_wdata;
         addr     <= i_addr;
         we1      <= i_we; 
         re1      <= i_re;
      end
   end 

   `ifdef SIM
      reg   [7:0] mem       [511:0];
      reg   [7:0] s_rdata; 
  
      `ifdef PRELOAD
         initial $readmemh("load_mem.hex", mem);
      `endif

      assign o_rdata = s_rdata;

      always@(posedge i_clk or negedge i_nrst) begin
         if(re)   s_rdata <= mem[i_addr];
         else     s_rdata <= 'd0;
      end

      always@(posedge i_clk or negedge i_nrst) begin  
         if(we1)  mem[addr] <= wdata1; 
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
                        wdata1[7],
                        1'bx,
                        wdata1[6],
                        1'bx,
                        wdata1[5],
                        1'bx,
                        wdata1[4],
                        1'bx,
                        wdata1[3],
                        1'bx,
                        wdata1[2],
                        1'bx,
                        wdata1[1],
                        1'bx,
                        wdata1[0] };
      SB_RAM40_4K #(
         .WRITE_MODE (pMODE),
         .READ_MODE  (pMODE)
      ) ram (
         .MASK       (16'hxxxx),
         .RDATA      (s_rdata ),
         .RADDR      (i_addr  ),
         .RCLK       (i_rclk  ),
         .RCLKE      (1'b1    ),
         .RE         (re      ),
         .WADDR      (addr    ),
         .WCLK       (i_wclk  ),
         .WCLKE      (1'b1    ),
         .WDATA      (s_wdata ),
         .WE         (we      )
      );
   `endif

endmodule

