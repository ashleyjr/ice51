module ice51_top(
   input    wire        i_clk,
   input    wire        i_nrst,
   input    wire        i_uart_rx,
   output   wire        o_uart_tx, 
   output   wire        o_vcc0,
   output   wire        o_vcc1,
   output   wire        o_led0,
   output   wire        o_led1,
   output   wire        o_led2,
   output   wire        o_led3,
   output   wire        o_led4,
   output   wire        o_led5,
   output   wire        o_led6,
   output   wire        o_led7
);
   wire        code_wr;
   wire  [9:0] code_addr;
   wire  [7:0] code_data_wr;
   wire  [7:0] code_data_rd;

   wire        data_wr;
   wire  [8:0] data_addr;
   wire  [7:0] data_data_wr;
   wire  [7:0] data_data_rd;

   wire        reg_wr;
   wire  [8:0] reg_waddr;
   wire  [7:0] reg_data_wr;
   wire  [8:0] reg_raddr;
   wire  [7:0] reg_data_rd;

   assign o_vcc0 = 1'b1;
   assign o_vcc1 = 1'b1;
   assign { o_led7, o_led6, o_led5, o_led4, 
            o_led3, o_led2, o_led1, o_led0 } = code_data_wr;

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
      .o_data_data   (data_data_wr  ),
      .i_data_data   (data_data_rd  ),
      .o_reg_wr      (reg_wr        ),
      .o_reg_waddr   (reg_waddr     ),
      .o_reg_wdata   (reg_data_wr   ),
      .o_reg_raddr   (reg_raddr     ),
      .i_reg_rdata   (reg_data_rd   )
   );

   mem_1024x8b code(
      .i_clk   (i_clk            ),
      .i_nrst  (i_nrst           ),
      .i_we    (code_wr          ),
      .i_addr  (code_addr        ),
      .i_wdata (code_data_wr     ), 
      .o_rdata (code_data_rd     ) 
   );

   mem_512x8b data(
      .i_clk   (i_clk            ),
      .i_nrst  (i_nrst           ),
      .i_we    (data_wr          ),
      .i_addr  (data_addr        ),
      .i_wdata (data_data_wr     ), 
      .o_rdata (data_data_rd     ) 
   );

   dp_mem_512x8b registers(
      .i_clk   (i_clk            ),
      .i_nrst  (i_nrst           ),
      .i_we    (reg_wr           ),
      .i_waddr (reg_waddr        ),
      .i_wdata (reg_data_wr      ), 
      .i_raddr (reg_raddr        ),
      .o_rdata (reg_data_rd      ) 
   );
endmodule
