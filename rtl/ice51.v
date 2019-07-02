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
   output   wire  [7:0] o_data_data,
   input    wire  [7:0] i_data_data
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
               SM_EXECUTE  = 3'd4;

   // OPCODES
   parameter   LJMP  = 8'h02, // ljmp addr16
               INCR  = 8'h08, // inc r?
               LCALL = 8'h12, // lcall addr16
               DECA  = 8'h14, // dec a
               JB    = 8'h20, // jb
               ADDAI = 8'h24, // add a, #imm
               ADDAD = 8'h25, // add a, (direct)
               ADDAR = 8'h28, // add a, r?
               JNB   = 8'h30, // jnb, bit, address
               RLC   = 8'h33, // rlc
               JC    = 8'h40, // jc
               JNC   = 8'h50, // jnc
               XRLDA = 8'h62, // xrl d,a
               XRLDI = 8'h63, // xrl (direct), #imm
               XRLA  = 8'h64, // xrl a,#imm
               JZ    = 8'h60, // jz 
               JNZ   = 8'h70, // jnz 
               MOVAI = 8'h74, // mov r?, #imm
               MOVDI = 8'h75, // mov direct, #imm
               MOVRI = 8'h78, // mov r?, #imm
               SJMP  = 8'h80,
               MOVDD = 8'h85, // mov (direct), (direct)
               MOVDT0= 8'h86, // mpv (direct), @r0
               MOVDT1= 8'h87, // mpv (direct), @r1
               MOVD  = 8'h88, // mov (direct), r?
               MOVDP = 8'h90, // mov dptr, #imm
               MOVC  = 8'h93, // movc a, @a+dptr
               SUBBAI= 8'h94, // subb a,#imm
               SUBBAD= 8'h95, // subb a, direct
               SUBBAR= 8'h98, // subb a, r?
               MUL   = 8'hA4, // mul
               MOVRD = 8'hA8, // mov r, (direct)
               CJNERI= 8'hB8, // cjne r?, #imm, offset
               CLRC  = 8'hC3, // clr c
               MOVXAD= 8'hE0, // movx a, @dptr
               CLRA  = 8'hE4, // clr a
               MOVAD = 8'hE5, // mov a, direct
               MOVAR = 8'hE8, // mov a, r?
               MOVXDA= 8'hF0, // movx @dptr, a
               MOVDA = 8'hF5, // mov (direct), a
               MOVT1A= 8'hF7, // mov @r1, a
               MOVRA = 8'hF8; // mov r?, a

   // DIRECT
   parameter   DPL   = 8'h82,
               DPH   = 8'h83,
               ACC   = 8'hE0,
               BB    = 8'hF0;
  
   // BIT
   parameter   BIT0_ACC = 8'hE0;
   
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
   reg   [3:0]                   uart_tx_bit_count;
   wire  [3:0]                   uart_tx_bit_count_next;
   wire                          uart_tx_sample;
   wire                          uart_tx_finish;
   reg   [1:0]                   uart_tx_state;
   wire  [1:0]                   uart_tx_state_next;
   
   // CODE
   wire  [7:0]                   op;
   wire  [4:0]                   op5;
   reg   [7:0]                   op_latched;
   wire  [7:0]                   h_data;
   reg   [7:0]                   h_data_latched;
   wire  [7:0]                   l_data;
   reg   [7:0]                   l_data_latched;
   wire  [15:0]                  hl_data;

   // STATE
   reg   [2:0]                   state;
   wire  [2:0]                   state_next;

   // PROGRAM COUNTER
   reg   [8:0]                   pc;
   wire  [8:0]                   pc_next;
   wire  [6:0]                   pc_twos;  
   wire  [6:0]                   pc_n_l_data7;
   wire  [6:0]                   pc_n_h_data7;
   wire  [8:0]                   pc_bck_l_data;
   wire  [8:0]                   pc_bck_h_data;
   
   // REGS
   wire                          r_upd;
   reg   [7:0]                   r[7:0];
   wire  [7:0]                   r_sel;
   wire  [7:0]                   r_next;
   wire  [2:0]                   r_index;
   wire  [2:0]                   r_next_index;

   // ACCUMULATOR
   wire  [7:0]                   acc_next;
   reg   [7:0]                   acc; 
   wire  [8:0]                   acc_sub_wrap;
   wire  [8:0]                   acc_subbar_wrap;
   wire  [8:0]                   acc_subbad_wrap;

   // DPTR
   wire  [15:0]                  dptr_next;
   reg   [15:0]                  dptr;

   // CARRY
   reg                           carry;
   wire                          carry_next;
   wire                          carry_upd;

   // B
   reg   [7:0]                   b;
   wire  [7:0]                   b_next;

   // Mul
   wire  [15:0]                  mul_ab;

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
  
   `ifdef PRELOAD
   assign uart_load_done = 1'b1;
   `else
   assign uart_load_done = ((uart_rx_count_next == 'd0) & uart_done) | 
                           uart_load_done_latched;
   `endif

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) uart_load_done_latched  <= 'd0;
      else        uart_load_done_latched  <= uart_load_done;
   end
    
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // UART TX

   assign uart_tx_start = (sme & op_movxda & (dptr == 16'h0201));
   assign uart_tx_shift = (uart_tx_state == SM_UART_TX_SEND) & uart_tx_sample;
   assign uart_tx_next  = (uart_tx_start) ? o_data_data:
                          (uart_tx_shift) ? {uart_tx[6:0],1'b1}:
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
  
   assign uart_tx_finish = uart_tx_sample & ('d10 == uart_tx_bit_count); // Final shift forces a 1

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
   assign op5         = op[7:3];
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
  
   assign hl_data = {h_data,l_data};

   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // DATA

   assign o_data_wr   = sme & (op_movda | op_movdi | op_movt1a | (op_movd & (i_code_data > 8'h07)));
   assign o_data_addr = (op_movdt0)             ? r[0]:
                        (op_movdt1 | op_movt1a) ? r[1]:
                        (op_movdi  | op_movdd ) ? h_data:
                                                  i_code_data; 
   assign o_data_data = (op_movd ) ? r_sel: 
                        (op_movdi) ? i_code_data:
                                     acc;

   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // STATE
   
   assign op_ljmp    = (op == LJMP);
   assign op_movdi   = (op == MOVDI);
   assign op_lcall   = (op == LCALL);
   assign op_movad   = (op == MOVAD);
   assign op_sjmp    = (op == SJMP);
   assign op_movdp   = (op == MOVDP);
   assign op_clra    = (op == CLRA);
   assign op_movc    = (op == MOVC);
   assign op_movra   = (op5 == (MOVRA >> 3));
   assign op_movai   = (op == MOVAI);
   assign op_movd    = (op5  == (MOVD >> 3));
   assign op_movxda  = (op == MOVXDA);
   assign op_movxad  = (op == MOVXAD);
   assign op_movar   = (op5 == (MOVAR >> 3));
   assign op_jb      = (op == JB);
   assign op_incr    = (op5 == (INCR >> 3));
   assign op_xrla    = (op == XRLA); 
   assign op_subbai  = (op == SUBBAI);
   assign op_movri   = (op5 == (MOVRI >> 3));
   assign op_jc      = (op == JC); 
   assign op_addar   = (op5 == (ADDAR >> 3)); 
   assign op_xrlda   = (op == XRLDA); 
   assign op_movda   = (op == MOVDA);
   assign op_addad   = (op == ADDAD);
   assign op_addai   = (op == ADDAI);
   assign op_deca    = (op == DECA);
   assign op_movdt0  = (op == MOVDT0);
   assign op_movdt1  = (op == MOVDT1);
   assign op_movt1a  = (op == MOVT1A);
   assign op_cjneri  = (op5 == (CJNERI >> 3));
   assign op_clrc    = (op == CLRC); 
   assign op_jnb     = (op == JNB);
   assign op_rlc     = (op == RLC);
   assign op_subbad  = (op == SUBBAD);
   assign op_movrd   = (op5 == (MOVRD >> 3));
   assign op_movdd   = (op == MOVDD);
   assign op_jnc     = (op == JNC);
   assign op_subbar  = (op5 == (SUBBAR >> 3));
   assign op_xrldi   = (op == XRLDI); 
   assign op_jz      = (op == JZ); 
   assign op_mul     = (op == MUL);

   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // STATE

   assign smf  = (state == SM_FETCH);
   assign smd0 = (state == SM_DECODE0);
   assign smd1 = (state == SM_DECODE1);
   assign smd2 = (state == SM_DECODE2);
   assign sme  = (state == SM_EXECUTE); 
   assign smj  = (state == SM_JUMP);
  
   assign d1 = op_xrla   | 
               op_subbai | 
               op_movri  | 
               op_jnc    | 
               op_jc     | 
               op_movad  | 
               op_addad  | 
               op_movdi  | 
               op_movdt0 | 
               op_movdt1 | 
               op_movrd;
   
   assign d3 = op_jnb    | 
               op_ljmp   | 
               op_movdp  | 
               op_jb     | 
               op_cjneri | 
               op_movdd  | 
               op_xrldi;
   

   assign state_next = (smf  & uart_load_done   ) ? SM_DECODE0:  
                       (smd0 & (d3 | d1)        ) ? SM_DECODE1:  
                       (smd0                    ) ? SM_EXECUTE:  
                       (smd1 & d3               ) ? SM_DECODE2:  
                       (smd1                    ) ? SM_EXECUTE:  
                       (smd2                    ) ? SM_EXECUTE: 
                       (sme                     ) ? SM_FETCH: 
                                                    state;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) state  <= 'd0;
      else        state  <= state_next;
   end
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // PROGRAM COUNTER
  
   assign pc_n_l_data7     = ~l_data[6:0];
   assign pc_n_h_data7     = ~h_data[6:0];
   assign pc_twos          = ~i_code_data[6:0];
   
   assign pc_bck_l_data    = pc - pc_n_l_data7 - 'd1;
   assign pc_bck_h_data    = pc - pc_n_h_data7 - 'd1;
   
   assign pc_bck           = sme & op_sjmp & i_code_data[7];
   assign pc_fwd           = sme & op_sjmp & ~i_code_data[7];
   
   assign pc_replace       = sme & op_ljmp;
   
   assign pc_jb_bck        = sme & op_jb & (acc[h_data[3:0]] == 1'b1) & l_data[7]; 
   assign pc_jb_fwd        = sme & op_jb & (acc[h_data[3:0]] == 1'b1) & ~l_data[7];
  
   assign pc_jnb           = sme & op_jnb & (~acc[0] & (h_data == BIT0_ACC));
   
   assign pc_jc_bck        = sme & op_jc & carry & h_data[7];
   assign pc_jc_fwd        = sme & op_jc & carry & ~h_data[7];
   assign pc_jnc_bck       = sme & op_jnc & ~carry & h_data[7];
   assign pc_jnc_fwd       = sme & op_jnc & ~carry & ~h_data[7];  
   
   assign pc_cjne_bck      = sme & op_cjneri & l_data[7]  & (r_sel != h_data);
   assign pc_cjne_fwd      = sme & op_cjneri & ~l_data[7] & (r_sel != h_data); 

   assign pc_jz_fwd        = sme & op_jz & ~i_code_data[7] & (acc == 'd0);

   assign pc_inc     = (smd1 & ~op_movrd)       | 
                       (smf & uart_load_done)   |
                       (smd0  & ~(  op_mul      | 
                                    op_rlc      |
                                    op_clrc     |
                                    op_jc       |
                                    op_jnc      |
                                    op_incr     |
                                    op_movt1a   |
                                    op_movdt0   |
                                    op_movdt1   |
                                    op_deca     |
                                    op_movri    |
                                    op_clra     |
                                    op_movad    |
                                    op_movc     |
                                    op_addad    |
                                    op_movra    |
                                    op_movxda   |
                                    op_movxad   |
                                    op_movar    |
                                    op_xrla     |
                                    op_subbai   |
                                    op_subbar   |
                                    op_addar   ));
                       
   assign pc_next    = (pc_jnb | pc_jb_fwd | pc_cjne_fwd ) ? pc + l_data[6:0]:
                       (pc_bck                           ) ? pc - pc_twos - 'd1:
                       (pc_replace                       ) ? hl_data:
                       (pc_jb_bck | pc_cjne_bck          ) ? pc_bck_l_data:
                       (pc_jc_bck | pc_jnc_bck           ) ? pc_bck_h_data: 
                       (pc_jc_fwd                        ) ? pc + h_data[6:0] - 'd2: 
                       (pc_jnc_fwd                       ) ? pc + h_data[6:0]:  
                       (pc_jz_fwd                        ) ? pc + i_code_data[6:0]:
                       (pc_inc                           ) ? pc + 'd1 :
                                                             pc;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    pc  <= 'd3;
      else           pc  <= pc_next;
   end
    
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // REGS
  
   assign r_next = (op_movdt0 | op_movdt1 | op_movrd) ? i_data_data:
                   op_xrlda                           ? (acc ^ r_sel):      
                   op_movri                           ? h_data:
                   op_incr                            ? (r_sel + 'd1):
                   op_movra                           ? acc: 
                                                        r_sel;
   
   assign r_upd  = sme & (op_movra | op_incr | op_movri | op_xrlda | op_movdt0 | op_movdt1 | op_movrd | 
                          (op_movd & (i_code_data < 8'h08)));
     
   assign r_index =  (op_movdt0 | op_movdt1) ? h_data[2:0]:
                     (op_xrlda)              ? i_code_data[2:0] : 
                                               op[2:0];

   assign r_sel  = r[r_index];

   assign r_next_index = (op_movd) ? i_code_data[2:0] : r_index;
   
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    {  r[0],
                        r[1],
                        r[2],
                        r[3],
                        r[4],
                        r[5],
                        r[6],
                        r[7]  }     <= 'd0;
      else if(r_upd)    r[r_next_index]  <= r_next;
   end
   
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // ACCUMULATOR 

   assign acc_sub_wrap = (acc - h_data - carry);

   assign acc_subbar_wrap = (acc - r_sel - carry);

   assign acc_subbad_wrap = (acc - b - carry);
   
   assign acc_next = (op_mul                            ) ? mul_ab[7:0]:
                     (op_subbad & (i_code_data == BB)   ) ? acc_subbad_wrap[7:0]:
                     (op_rlc                            ) ? {acc[6:0], carry}:
                     (op_addai                          ) ? (acc + i_code_data):
                     (op_addad                          ) ? (acc + i_data_data):
                     (op_movad                          ) ? i_data_data:
                     (op_xrla                           ) ? (acc ^ h_data):
                     (op_subbai                         ) ? acc_sub_wrap[7:0]:
                     (op_subbar                         ) ? acc_subbar_wrap[7:0]:
                     (op_subbad & (i_code_data == ACC)  ) ? (8'h00 - carry):
                     (op_movar                          ) ? r_sel:
                     (op_addar                          ) ? acc + r_sel:
                     (op_deca                           ) ? acc - 'd1:
                     (op_clra                           ) ? 'd0:                                 
                     ((op_movc | op_movai)              ) ? i_code_data:
                     (op_movxad & (dptr == 16'h200)     ) ? {7'd0, (uart_tx_state != SM_UART_TX_IDLE)}:        
                                                                   acc;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    acc <= 'd0;
      else if(sme)   acc <= acc_next;
   end
    
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // DPTR
   
   assign dptr_next = (op_movdp)                        ? hl_data:
                      (op_movd  & (i_code_data == DPL)) ? {dptr[15:8], r_sel}:
                      (op_movd  & (i_code_data == DPH)) ? {r_sel,      dptr[7:0]}:
                      (op_movdd & (l_data == DPL))      ? {dptr[15:8], i_data_data}:
                      (op_movdd & (l_data == DPH))      ? {i_data_data,dptr[7:0]}:                                          
                                                                 dptr;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    dptr <= 'd0;
      else if(sme)   dptr <= dptr_next;
   end
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // CARRY
  
   assign carry_next = (op_subbad & carry & (i_code_data == ACC)) |
                       (op_subbad & acc_subbad_wrap[8] & (i_code_data == BB)) |
                       (op_rlc & acc[7]) |
                       (op_cjneri & (r_sel < h_data)) |
                       (op_subbar & acc_subbar_wrap[8]) |
                       (op_subbai & acc_sub_wrap[8]);

   assign carry_upd  = sme & (op_clrc | op_cjneri | op_subbai | op_subbar | op_rlc | op_subbad); 

    always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)          carry <= 1'b0;
      else if(carry_upd)   carry <= carry_next;
   end
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // B
 
   assign b_next = (op_mul                        ) ? mul_ab[15:8]:
                   (op_movd & (i_code_data == BB) ) ? r_sel:
                   (op_xrldi & (h_data == BB)     ) ? b ^ l_data:
                                                             b;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    b <= 'd0;
      else if(sme)   b <= b_next;
   end
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // MUL

   assign mul_ab = 'd0;//acc * b;
   
endmodule
