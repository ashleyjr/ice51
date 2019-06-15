module ice51(
   input    wire        i_clk,
   input    wire        i_nrst,
   input    wire        i_uart_rx,
   output   wire        o_uart_tx,
   output   wire        o_code_wr,
   output   wire  [8:0] o_code_addr,
   output   wire  [7:0] o_code_data,
   input    wire  [7:0] i_code_data,
   output   wire        o_data_wr,
   output   wire  [8:0] o_data_addr,
   output   wire  [7:0] o_data_data
);
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // PARAMETERS
   
   // UART 
   parameter   SAMPLE            = 104,  
               SM_UART_IDLE      = 2'b00,
               SM_UART_RX_START  = 2'b01,
               SM_UART_RX        = 2'b11,
               SM_UART_WAIT      = 2'b10,
               START_BIT         = 8'h80,
               SM_UART_TX_IDLE   = 2'b00,
               SM_UART_TX_START  = 2'b01,
               SM_UART_TX_SEND   = 2'b10;

   // STATE
   parameter   SM_FETCH    = 3'd0,
               SM_DECODE0  = 3'd1,
               SM_DECODE1  = 3'd2,
               SM_DECODE2  = 3'd3,
               SM_EXECUTE0 = 3'd4,
               SM_EXECUTE1 = 3'd5,
               SM_EXECUTE2 = 3'd6;

   // OPCODES
   parameter   LJMP  = 8'h02, // ljmp addr16
               LCALL = 8'h12, // lcall addr16
               DECA  = 8'h14, // dec a
               ADDAR = 8'h28, // add a, r?
               JNZ   = 8'h70, // jnz 
               MOVAI = 8'h74, // mov r?, #imm
               MOVDI = 8'h75, // mov direct, #imm
               MOVRI = 8'h78, // mov r?, #imm
               SJMP  = 8'h80,
               MOVD  = 8'h88, // mov (direct), r?
               MOVDP = 8'h90, // mov dptr, #imm
               MOVC  = 8'h93, // movc a, @a+dptr
               CLRA  = 8'hE4, // clr a
               MOVAD = 8'hE5, // mov a, direct
               MOVAR = 8'hE8, // mov a, r?
               MOVX  = 8'hF0, // movx @dptr, a
               MOVRA = 8'hF8; // mov r?, a

   // DIRECT
   parameter   DPL   = 8'h82,
               DPH   = 8'h83;
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // SIGNALS
  
   // UART
   reg                           uart_p0_rx;
   wire                          uart_full_sample;
   wire                          uart_half_sample;
   reg   [1:0]                   uart_state;
   wire  [1:0]                   uart_state_next;
   reg   [$clog2(SAMPLE)-1:0]    uart_count;
   wire  [$clog2(SAMPLE)-1:0]    uart_count_next;
   reg   [7:0]                   uart_data;
   wire  [7:0]                   uart_data_next; 
   reg   [8:0]                   uart_rx_count;
   wire  [8:0]                   uart_rx_count_next; 
   wire                          uart_load_done;
   reg                           uart_load_done_latched;
   wire  [7:0]                   uart_tx_next;
   reg   [7:0]                   uart_tx;
   reg   [$clog2(SAMPLE)-1:0]    uart_tx_sample_count;
   wire  [$clog2(SAMPLE)-1:0]    uart_tx_sample_count_next;
   reg   [2:0]                   uart_tx_bit_count;
   wire  [2:0]                   uart_tx_bit_count_next;
   wire                          uart_tx_sample;
   wire                          uart_tx_finish;
   reg   [1:0]                   uart_tx_state;
   wire  [1:0]                   uart_tx_state_next;
   
   // CODE
   wire  [7:0]                   op;
   reg   [7:0]                   op_latched;
   wire  [7:0]                   h_data;
   reg   [7:0]                   h_data_latched;
   wire  [7:0]                   l_data;
   reg   [7:0]                   l_data_latched;

   // STATE
   reg   [2:0]                   state;
   wire  [2:0]                   state_next;

   // PROGRAM COUNTER
   reg   [8:0]                   pc;
   wire  [8:0]                   pc_next;
   wire  [6:0]                   pc_twos;

   // REGS
   wire                          r_upd;
   reg   [7:0]                   r[7:0];
   wire  [7:0]                   r_sel;
   wire  [7:0]                   r_next;

   // ACCUMULATOR
   wire  [7:0]                   acc_next;
   reg   [7:0]                   acc;

   // DPTR
   wire  [15:0]                  dptr_next;
   reg   [15:0]                  dptr;

   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // UART RX
   
   // Resync
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) uart_p0_rx <= 1'b1;
      else        uart_p0_rx <= i_uart_rx;
   end

   assign uart_start       = ((uart_state == SM_UART_IDLE) & ~uart_p0_rx);
   assign uart_done        = ((uart_state == SM_UART_WAIT) & uart_full_sample);
   assign uart_full_sample = (uart_count == SAMPLE        );
   assign uart_half_sample = (uart_count == (SAMPLE >> 1) );
   
   assign uart_state_next = (uart_start                                                            ) ? SM_UART_RX_START:
                            ((uart_state == SM_UART_RX_START)  & uart_half_sample                  ) ? SM_UART_RX:
                            ((uart_state == SM_UART_RX)        & uart_full_sample & uart_data[0]   ) ? SM_UART_WAIT:
                            (uart_done                                                             ) ? SM_UART_IDLE:
                                                                                                       uart_state;
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) uart_state  <= SM_UART_IDLE;
      else        uart_state  <= uart_state_next;
   end
  
   assign uart_data_next = (uart_start                                       ) ? START_BIT:
                           ((uart_state == SM_UART_RX)     & uart_full_sample) ? {uart_p0_rx,uart_data[7:1]}:
                                                                                 uart_data;
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) uart_data   <= 'd0;
      else        uart_data   <= uart_data_next;
   end
    
   assign uart_count_next =   (  uart_start                                               |
                                 uart_done                                                |
                                 ((uart_state == SM_UART_RX_START)  & uart_half_sample)   |  
                                 ((uart_state == SM_UART_RX)        & uart_full_sample)   ) ? 'd0 : 
                                                                                              uart_count + 'd1; 
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) uart_count  <= 'd0;
      else        uart_count  <= uart_count_next;
   end
   
   assign uart_rx_count_next  = (uart_done) ? (uart_rx_count + 'd1) : uart_rx_count;
   
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) uart_rx_count  <= 'd0;
      else        uart_rx_count  <= uart_rx_count_next;
   end
   
   assign uart_load_done = ((uart_rx_count_next == 'd0) & uart_done) | 
                           uart_load_done_latched;
   
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) uart_load_done_latched  <= 'd0;
      else        uart_load_done_latched  <= uart_load_done;
   end
    
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // UART TX

   assign uart_tx_start = (sme0 & op_movx & (dptr == 16'h0201));
   assign uart_tx_shift = (uart_tx_state == SM_UART_TX_SEND) & uart_tx_sample;
   assign uart_tx_next  = (uart_tx_start) ? o_data_data:
                          (uart_tx_shift) ? {uart_tx[6:0],1'b0}:
                                            uart_tx;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) uart_tx  <= 'd0;
      else        uart_tx  <= uart_tx_next;
   end
  
   assign uart_tx_state_next = ((uart_tx_state == SM_UART_TX_IDLE ) & uart_tx_start  ) ? SM_UART_TX_START:
                               ((uart_tx_state == SM_UART_TX_START) & uart_tx_sample ) ? SM_UART_TX_SEND:
                               ((uart_tx_state == SM_UART_TX_SEND)  & uart_tx_finish ) ? SM_UART_TX_IDLE:
                                                                                         uart_tx_state;
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) uart_tx_state  <= 'd0;
      else        uart_tx_state  <= uart_tx_state_next;
   end

   assign o_uart_tx = (uart_tx_state == SM_UART_TX_IDLE ) ? 1'b1:
                      (uart_tx_state == SM_UART_TX_START) ? 1'b0:
                                                            uart_tx[7];

   assign uart_tx_sample = (SAMPLE == uart_tx_sample_count); 
   
   assign uart_tx_sample_count_next = ((uart_tx_state == SM_UART_TX_IDLE) | uart_tx_sample) ? 'd0: (uart_tx_sample_count + 'd1);
   
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) uart_tx_sample_count  <= 'd0;
      else        uart_tx_sample_count  <= uart_tx_sample_count_next;
   end
  
   assign uart_tx_finish = uart_tx_sample & ('d7 == uart_tx_bit_count);

   assign uart_tx_bit_count_next = (uart_tx_finish) ? 'd0 : 
                                   (uart_tx_sample) ? (uart_tx_bit_count + 'd1):
                                                      uart_tx_bit_count;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) uart_tx_bit_count  <= 'd0;
      else        uart_tx_bit_count  <= uart_tx_bit_count_next;
   end
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // CODE

   assign o_code_data = uart_data;
   assign o_code_wr   = uart_done & ~uart_load_done;
   assign o_code_addr = (smd0 & op_movc  ) ? (acc + dptr):
                        (uart_load_done  ) ?  pc : 
                                             uart_rx_count; 
   assign op          = (smd0) ? i_code_data : op_latched;
   assign h_data      = (smd1) ? i_code_data : h_data_latched;
   assign l_data      = (smd2) ? i_code_data : l_data_latched;
   
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) op_latched <= 'd0;
      else        op_latched <= op;
   end
   
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) h_data_latched <= 'd0;
      else        h_data_latched <= h_data;
   end 
   
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) l_data_latched <= 'd0;
      else        l_data_latched <= l_data;
   end
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // DATA

   assign o_data_wr   = (sme0 & op_movx);
   assign o_data_addr = dptr; 
   assign o_data_data = acc;

   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // STATE
   
   assign op_ljmp  = (op == LJMP);
   assign op_movdi = (op == MOVDI);
   assign op_lcall = (op == LCALL);
   assign op_movad = (op == MOVAD);
   assign op_sjmp  = (op == SJMP);
   assign op_movdp = (op == MOVDP);
   assign op_clra  = (op == CLRA);
   assign op_movc  = (op == MOVC);
   assign op_movra = (op[7:3] == (MOVRA >> 3));
   assign op_movai = (op == MOVAI);
   assign op_movd  = (op[7:3] == (MOVD >> 3));
   assign op_movx  = (op == MOVX);

   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // STATE

   assign smf  = (state == SM_FETCH);
   assign smd0 = (state == SM_DECODE0);
   assign smd1 = (state == SM_DECODE1);
   assign smd2 = (state == SM_DECODE2);
   assign sme0 = (state == SM_EXECUTE0);
   assign sme1 = (state == SM_EXECUTE1);
   assign sme2 = (state == SM_EXECUTE2);
   assign smj  = (state == SM_JUMP);
  
   assign d3 = op_ljmp | op_movdp;
   assign e3 = 1'b0;

   assign state_next = (smf  & uart_load_done     ) ? SM_DECODE0:  
                       (smd0 & d3                 ) ? SM_DECODE1:  
                       (smd0                      ) ? SM_EXECUTE0:  
                       (smd1 & d3                 ) ? SM_DECODE2:  
                       (smd2                      ) ? SM_EXECUTE0:
                       (sme0 & e3                 ) ? SM_EXECUTE1:
                       (sme0                      ) ? SM_FETCH:
                       (sme1 & e3                 ) ? SM_EXECUTE2:
                       (sme2                      ) ? SM_FETCH:
                                                      state;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) state  <= 'd0;
      else        state  <= state_next;
   end
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // PROGRAM COUNTER
   
   assign pc_twos    = ~i_code_data[6:0];
   assign pc_bck     = sme0 & op_sjmp & i_code_data[7];
   assign pc_fwd     = sme0 & op_sjmp & ~i_code_data[7];
   assign pc_replace = sme0 & op_ljmp;
   assign pc_inc     = (smd0  & ~op_clra & ~op_movc & ~op_movra & ~op_movx) | 
                       smd1 | 
                       (smf & uart_load_done);
   assign pc_next    = (pc_bck    ) ? pc - pc_twos - 'd1:
                       (pc_replace) ? {h_data,l_data}:
                       (pc_inc    ) ? pc + 'd1 :
                                      pc;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) pc  <= 'd3;
      else        pc  <= pc_next;
   end
    
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // REGS
  
   assign r_next = op_movra ?  acc: 
                               r_sel;
   assign r_upd  = sme0 & op_movra;
      
   assign r_sel  = r[op[2:0]];

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    {  r[0],
                        r[1],
                        r[2],
                        r[3],
                        r[4],
                        r[5],
                        r[6],
                        r[7]  }     <= 'd0;
      else if(r_upd)    r[op[2:0]]  <= r_next;
   end
    
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // ACCUMULATOR 
 
   assign acc_next = (sme0 & (op[7:3] == (MOVAR >> 3))) ? r_sel:
                     (sme0 & (op[7:3] == (ADDAR >> 3))) ? acc + r_sel:
                     (sme0 & (op      == DECA        )) ? acc - 'd1:
                     (sme0 & (op      == CLRA        )) ? 'd0:                                 
                     (sme0 & (op_movc | op_movai)     ) ? i_code_data:
                                                          acc;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    acc <= 'd0;
      else           acc <= acc_next;
   end
    
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // DPTR
   
   assign dptr_next = (sme0 & op_movdp)                       ? {h_data,l_data}:
                      (sme0 & op_movd & (i_code_data == DPL)) ? {dptr[15:8], r_sel}:
                      (sme0 & op_movd & (i_code_data == DPH)) ? {r_sel,      dptr[7:0]}:
                                                                dptr;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    dptr <= 'd0;
      else           dptr <= dptr_next;
   end
   
 


endmodule
