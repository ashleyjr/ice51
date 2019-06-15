module ice51_top(
   input    wire        i_clk,
   input    wire        i_nrst,
   input    wire        i_uart_rx,
   output   wire        o_uart_tx 
);
   wire        code_wr;
   wire  [8:0] code_addr;
   wire  [7:0] code_data_wr;
   wire  [7:0] code_data_rd;

   wire        data_wr;
   wire  [8:0] data_addr;
   wire  [7:0] data_data_wr;
   wire  [7:0] data_data_rd;


   ice51 ice51(
      .i_clk         (i_clk         ),
      .i_nrst        (i_nrst        ),
      .i_uart_rx     (i_uart_rx     ),
      .o_uart_tx     (o_uart_tx     ),
      .o_code_wr     (code_wr       ),
      .o_code_addr   (code_addr     ),
      .o_code_data   (code_data_wr  ),
      .i_code_data   (code_data_rd  ),
      .o_data_wr     (data_wr       ),
      .o_data_addr   (data_addr     ),
      .o_data_data   (data_data_wr  )
   );

   mem_512x8b code(
      .i_clk   (i_clk            ),
      .i_nrst  (i_nrst           ),
      .i_we    (code_wr          ),
      .i_addr  (code_addr        ),
      .i_wdata (code_data_wr     ),
      .i_re    (1'b1             ),
      .o_rdata (code_data_rd     ) 
   );

   mem_512x8b data(
      .i_clk   (i_clk            ),
      .i_nrst  (i_nrst           ),
      .i_we    (data_wr          ),
      .i_addr  (data_addr        ),
      .i_wdata (data_data_wr     ),
      .i_re    (1'b1             ),
      .o_rdata (     ) 
   );
endmodule
