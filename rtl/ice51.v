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
            INCA  = 8'h04, // inc a
            INCD  = 8'h05, // inc (direct)
            INCR  = 8'h08, // inc r?
            LCALL = 8'h12, // lcall addr16
            RRC   = 8'h13, // rrc
            DECA  = 8'h14, // dec a
            DECR  = 8'h18, // dec r?
            JB    = 8'h20, // jb
            RET   = 8'h22, // ret
            RL    = 8'h23, // rl a
            ADDAI = 8'h24, // add a, #imm
            ADDAD = 8'h25, // add a, (direct)
            ADDAR = 8'h28, // add a, r?
            JNB   = 8'h30, // jnb, bit, address
            RLC   = 8'h33, // rlc
            ADDCI = 8'h34, // addc a, #imm
            ADDCD = 8'h35, // addc a, (direct) 
            ADDCR = 8'h38, // addc a, r?
            JC    = 8'h40, // jc
            ORLDI = 8'h43, // orl (direct), #imm
            JNC   = 8'h50, // jnc
            ANLAI = 8'h54, // anl a, #imm 
            XRLDA = 8'h62, // xrl d,a
            XRLDI = 8'h63, // xrl (direct), #imm
            XRLA  = 8'h64, // xrl a,#imm
            JZ    = 8'h60, // jz 
            JNZ   = 8'h70, // jnz 
            MOVAI = 8'h74, // mov r?, #imm
            MOVDI = 8'h75, // mov direct, #imm
            MOVRI = 8'h78, // mov r?, #imm
            SJMP  = 8'h80,
            DIV   = 8'h84, // div
            MOVDD = 8'h85, // mov (direct), (direct)
            MOVDT0= 8'h86, // mpv (direct), @r0
            MOVDT1= 8'h87, // mpv (direct), @r1
            MOVD  = 8'h88, // mov (direct), r?
            MOVDP = 8'h90, // mov dptr, #imm
            MOVC  = 8'h93, // movc a, @a+dptr
            SUBBAI= 8'h94, // subb a,#imm
            SUBBAD= 8'h95, // subb a, direct
            SUBBAR= 8'h98, // subb a, r?
            MOVCB = 8'hA2, // mov c, bit
            MUL   = 8'hA4, // mul
            MOVRD = 8'hA8, // mov r, (direct)
            CPLB  = 8'hB2, // cpl (bit)
            CJNEAD= 8'hB5, // cjne a, (direct), offset
            CJNERI= 8'hB8, // cjne r?, #imm, offset
            PUSH  = 8'hC0, // push r?
            CLRB  = 8'hC2, // clr bit
            CLRC  = 8'hC3, // clr c
            XCHDI = 8'hC5, // xch a, (direct)
            XCHAR = 8'hC8, // xch a r?
            POP   = 8'hD0, // pop
            SETBC = 8'hD3, // setb c
            DJNZR = 8'hD8, // djnz r?, offset
            MOVXAD= 8'hE0, // movx a, @dptr
            CLRA  = 8'hE4, // clr a
            MOVAD = 8'hE5, // mov a, direct
            MOVAR = 8'hE8, // mov a, r?
            MOVXDA= 8'hF0, // movx @dptr, a
            CPLA  = 8'hF4, // cpl a
            MOVDA = 8'hF5, // mov (direct), a
            MOVT1A= 8'hF7, // mov @r1, a
            MOVRA = 8'hF8; // mov r?, a

// DIRECT
parameter   SP    = 8'h81,
            DPL   = 8'h82,
            DPH   = 8'h83,
            ACC   = 8'hE0,
            BB    = 8'hF0;

// BIT
parameter   BIT_F0 = 8'hD5,
            BIT_ACC = 8'hE0;

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
wire  [6:0]                   pc_add;
wire  [8:0]                   pc_1;
wire  [8:0]                   pc_2;

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
wire  [8:0]                   acc_add_wrap; 
wire  [7:0]                   acc_add;
wire  [7:0]                   acc_sub;
wire  [8:0]                   acc_carry;
wire                          acc_zero;

// DPTR
reg   [7:0]                   l_dptr; 
wire  [7:0]                   l_dptr_next;
reg   [7:0]                   h_dptr;
wire  [7:0]                   h_dptr_next;
wire  [15:0]                  dptr;

// CARRY
reg                           carry;
wire                          carry_next;
wire                          carry_upd;

// B
reg   [7:0]                   b;
wire  [7:0]                   b_next;

// SP
reg   [7:0]                   sp;
wire  [7:0]                   sp_next;
wire  [7:0]                   sp_inc;
wire  [7:0]                   sp_dec;
wire                          sp_upd;

// F
reg                           f;
wire                          f_next;

// DIV
wire  [8:0]                   div_shift;
reg   [2:0]                   div_i;
wire  [2:0]                   div_i_next;
reg   [8:0]                   div_r;
wire  [8:0]                   div_r_next;
reg   [7:0]                   div_q; 
wire  [7:0]                   div_q_next; 
reg   [7:0]                   div_n; 
wire  [7:0]                   div_n_next;
reg   [7:0]                   div_d; 
wire  [7:0]                   div_d_next;
wire  [7:0]                   div_sub;
reg                           div_done;

// MUL
reg                           n_mul_idle; 
wire                          n_mul_idle_next;
wire                          mul_start;
wire                          mul_done;
reg   [7:0]                   mul_count;
wire  [7:0]                   mul_count_next;
reg   [7:0]                   mul_a;
reg   [15:0]                  mul_ab;
wire  [15:0]                  mul_ab_next;

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

assign o_data_wr   = (op_movdd & smd2 & (l_data != DPL) & (l_data != DPH) & (l_data != BB)) |
                     (op_lcall & (smd0 | smd1)) |
                     sme & (
                        op_incd |
                        (op_movda & ~d_bb) | 
                        (op_movdi & ~d_bb) | 
                        op_push |
                        op_movt1a |
                        (op_orldi & (h_data > 8'h07)) |
                        (op_movd & (i_code_data > 8'h07))
                     );
assign o_data_addr = (op_orldi)               ? h_data:
                     (op_incd & (smd1 | sme)) ? h_data:
                     (op_movdt0             ) ? r[0]:
                     (op_movdt1 | op_movt1a ) ? r[1]:
                     (op_movdd & smd2 & (l_data != DPL) & (l_data != DPH) & (l_data != BB))       ? l_data: 
                     (op_movdi  | op_movdd  | op_cjnead) ? h_data:
                     (op_push | op_lcall    ) ? sp_inc:
                     (op_ret | op_pop       ) ? sp:
                                                i_code_data; 
assign o_data_data = (op_orldi & (h_data > 8'h07)) ? (i_data_data | l_data):
                     (op_movdd & (h_data == DPH)) ? h_dptr:
                     (op_movdd & (h_data == DPL)) ? l_dptr:
                     (op_incd & sme) ? (i_data_data + 'd1):
                     (op_movdd & (h_data == BB)) ? b:
                     (op_movdd         ) ? i_data_data:
                     (op_push & (h_data == BB)) ? b:
                     (op_movd | op_push) ? r_sel: 
                     (op_movdi         ) ? i_code_data:
                     (op_lcall & smd0    ) ? pc_2[7:0]:
                     (op_lcall & smd1    ) ? {7'h00, pc_1[8]}:
                                           acc;

///////////////////////////////////////////////////////////////////////////////////////////////////////
// OPS

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
assign op_div     = (op == DIV);
assign op_cpla    = (op == CPLA);
assign op_decr    = (op5 == (DECR >> 3));
assign op_inca    = (op == INCA);
assign op_setbc   = (op == SETBC);
assign op_push    = (op == PUSH);
assign op_pop     = (op == POP);
assign op_ret     = (op == RET);
assign op_xchdi   = (op == XCHDI);
assign op_clrb    = (op == CLRB);
assign op_cplb    = (op == CPLB);
assign op_addci   = (op == ADDCI);
assign op_addcd   = (op == ADDCD);
assign op_addcr   = (op5 == (ADDCR >> 3));
assign op_incd    = (op == INCD);
assign op_cjnead  = (op == CJNEAD);
assign op_rrc     = (op == RRC);
assign op_movcb   = (op == MOVCB);
assign op_rl      = (op == RL);
assign op_anlai   = (op == ANLAI);
assign op_orldi   = (op == ORLDI);
assign op_jnz     = (op == JNZ);
assign op_xchar   = (op5 == (XCHAR >> 3));
assign op_djnzr   = (op5 == (DJNZR >> 3));

///////////////////////////////////////////////////////////////////////////////////////////////////////
// DIRECTS

assign d_bb  = (i_code_data == BB);
assign d_acc = (i_code_data == ACC);

///////////////////////////////////////////////////////////////////////////////////////////////////////
// STATE

assign smf  = (state == SM_FETCH);
assign smd0 = (state == SM_DECODE0);
assign smd1 = (state == SM_DECODE1);
assign smd2 = (state == SM_DECODE2);
assign sme  = (state == SM_EXECUTE);  

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
            op_movrd  |
            op_xrlda  |
            op_push   |
            op_pop    |
            op_clrb   |
            op_cplb  |
            op_xchdi |
            op_addci |
            op_incd ;

assign d3 = op_jnb    | 
            op_ljmp   | 
            op_movdp  | 
            op_jb     | 
            op_cjneri | 
            op_movdd  | 
            op_xrldi  |
            op_lcall  |
            op_ret   |
            op_cjnead |
            op_orldi;

assign state_next = (smf  & uart_load_done         ) ? SM_DECODE0:  
                    (smd0 & (d3 | d1)              ) ? SM_DECODE1:  
                    (smd0                          ) ? SM_EXECUTE:  
                    (smd1 & d3                     ) ? SM_DECODE2:  
                    (smd1                          ) ? SM_EXECUTE:  
                    (smd2                          ) ? SM_EXECUTE: 
                    (sme & (
                     (~op_mul & ~op_div) |
                     (op_mul & mul_done & ~mul_start) |
                     (op_div & div_done)       )) ? SM_FETCH: 
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

assign pc_replace       = sme & (op_ljmp | op_lcall);

assign pc_jb            = sme & op_jb & (acc[h_data[3:0]] == 1'b1); 
assign pc_jb_bck        = pc_jb & l_data[7]; 
assign pc_jb_fwd        = pc_jb & ~l_data[7];

assign pc_jnb           = sme & op_jnb & (
                           (~acc[h_data[2:0]] & (h_data[7:3] == (BIT_ACC >> 3))) |
                           ((f == 1'b0) & (h_data == BIT_F0))  
                        );

assign pc_jc            = sme & op_jc & carry;
assign pc_jc_bck        = pc_jc & h_data[7];
assign pc_jc_fwd        = pc_jc & ~h_data[7];

assign pc_jnc           = sme & op_jnc & ~carry;
assign pc_jnc_bck       = pc_jnc & h_data[7];
assign pc_jnc_fwd       = pc_jnc & ~h_data[7];  

assign pc_djnzr_bck      = sme & op_djnzr & (r_next != 8'h00) & i_code_data[7];

assign pc_cjne          = sme & op_cjneri & (r_sel != h_data);

assign pc_cjne_bck      = (pc_cjne | pc_cjnead) & l_data[7];
assign pc_cjne_fwd      = (pc_cjne | pc_cjnead) & ~l_data[7]; 

assign pc_cjnead        = sme & op_cjnead & ( 
                           ((h_data > 8'h07) & (i_data_data != acc)) |
                           ((h_data < 8'h08) & (r_sel != acc)));

assign pc_jz_fwd        = sme & op_jz & ~i_code_data[7] & acc_zero;
assign pc_jz_bck        = sme & op_jz &  i_code_data[7] & acc_zero;

assign pc_jnz_bck       = sme & op_jnz & i_code_data[7] & ~acc_zero;

assign pc_ret_top = smd1 & op_ret;
assign pc_ret_bot = smd2 & op_ret;

assign pc_1 = pc + 'd1;
assign pc_2 = pc + 'd2;

assign pc_inc     = (smd1 & ~(  op_movrd |
                                 op_pop |
                                 op_clrb |
                                 op_cplb  |
                                 op_xchdi |
                                 op_addci))  |
                    (smf & uart_load_done)   |
                    (smd0  & ~(  op_xchar    |
                                 op_rl       |
                                 op_div      |
                                 op_mul      | 
                                 op_rlc      |
                                 op_clrc     |
                                 op_jc       |
                                 op_jnc      |
                                 op_incr     |
                                 op_decr     |
                                 op_movt1a   |
                                 op_movdt0   |
                                 op_movdt1   |
                                 op_cpla     |
                                 op_deca     |
                                 op_inca     |
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
                                 op_addar    |
                                 op_xrlda    |
                                 op_setbc    |
                                 op_push     |
                                 op_addcr));

assign pc_add     = (pc_jnc_fwd              ) ? h_data[6:0] :  
                    (pc_jc_fwd | pc_jnc_fwd  ) ? h_data[6:0] - 'd2:  
                    (pc_jz_fwd               ) ? i_code_data[6:0]:
                                                 'd1;

assign pc_next    = (pc_ret_top                                   ) ? {i_data_data, pc[7:0]}: 
                    (pc_ret_bot                                   ) ? {pc[15:8], i_data_data}:
                    (pc_jnb | pc_jb_fwd | pc_cjne_fwd             ) ? pc + l_data[6:0]:
                    (pc_bck                                       ) ? pc - pc_twos - 'd1:
                    (pc_replace                                   ) ? hl_data:
                    (pc_jb_bck | pc_cjne_bck                      ) ? pc_bck_l_data:
                    (pc_jc_bck | pc_jnc_bck                       ) ? pc_bck_h_data: 
                    (pc_jnz_bck | pc_jz_bck | pc_djnzr_bck        ) ? pc - pc_twos - 'd1:
                    (pc_jc_fwd | pc_jnc_fwd | pc_jz_fwd | pc_inc  ) ? pc + pc_add:  
                                                                      pc;

always@(posedge i_clk or negedge i_nrst) begin
   if(!i_nrst)    pc  <= 'd0;
   else           pc  <= pc_next;
end
 
///////////////////////////////////////////////////////////////////////////////////////////////////////
// REGS

assign r_next = op_xchar                                    ? acc:
                (op_movrd & (h_data == DPH)               ) ? h_dptr:
                (op_movrd & (h_data == DPL)               ) ? l_dptr:
                (op_movrd & (h_data == BB)                ) ? b:
                (op_movdt0 | op_movdt1 | op_movrd | op_pop) ? i_data_data:
                op_orldi                                    ? (r_sel | l_data):
                op_xrlda                                    ? (acc ^ r_sel):      
                op_movri                                    ? h_data:
                op_incr                                     ? (r_sel + 'd1):
                (op_decr | op_djnzr)                        ? (r_sel - 'd1):
                op_movra                                    ? acc: 
                                                              r_sel;

assign r_upd  = sme & (op_movra | op_decr | op_incr | op_movri | op_xrlda | op_movdt0 | op_movdt1 | op_movrd | 
                       op_djnzr |
                        op_xchar |
                        (op_orldi & (h_data < 8'h08)) | 
                       (op_pop & (h_data < 8'h08)) | 
                       (op_movd & (i_code_data < 8'h08)));
  
assign r_index =  (op_movdt0 | op_movdt1 | op_xrlda | op_push | op_pop | op_pop | op_orldi) ? h_data[2:0] : op[2:0];

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


assign acc_sub = (op_subbai) ? h_data:
                 (op_subbar) ? r_sel:
                 (op_subbad & (i_code_data != BB)) ? i_code_data: 
                               b;

assign acc_carry        = acc - carry;
assign acc_sub_wrap     = acc_carry - acc_sub; 

assign acc_add = (op_addci) ? h_data:
                 (op_addcd) ? b: 
                 (op_addai) ? i_code_data: 
                 (op_addad & (h_data == ACC)) ? acc:
                 (op_addad & (h_data == DPH)) ? h_dptr:
                 (op_addad & (h_data == BB)) ? b:
                 (op_addad) ? i_data_data :
                 (op_addar | op_addcr) ? r_sel:
                              {7'h00, op_inca}; 

assign acc_add_wrap = acc + acc_add + (carry & (op_addci | op_addcd | op_addcr));

assign acc_zero = (acc == 'd0);

assign acc_next = (op_anlai                                 ) ? (acc & i_code_data):
                  (op_xchdi & (h_data == BB)                ) ? b:
                  (op_xchdi & (h_data == DPL)               ) ? l_dptr:
                  (op_xchdi & (h_data == DPH)               ) ? h_dptr:
                  (op_xchar                                 ) ? r_sel:
                  (op_cpla                                  ) ? ~acc:
                  (op_mul & mul_done                        ) ? mul_ab[7:0]:
                  (op_div & div_done                        ) ? div_q:
                  (op_subbad      |op_subbai | op_subbar) ? acc_sub_wrap[7:0]:
                  (op_rl                                    ) ? {acc[6:0], acc[7]}:
                  (op_rrc                                   ) ? {carry,    acc[7:1]}: 
                  (op_rlc                                   ) ? {acc[6:0], carry}: 
                  (op_movad & (h_data == BB)                ) ? b:
                  (op_movad & (h_data == DPH)               ) ? dptr[15:8]:
                  (op_movad & (h_data == DPL)               ) ? dptr[7:0]:
                  (op_movad                                 ) ? i_data_data:
                  (op_xrla                                  ) ? (acc ^ h_data): 
                  (op_subbad & d_acc                        ) ? (8'h00 - carry):
                  (op_movar                                 ) ? r_sel: 
                  (op_deca | op_mul                         ) ? acc - 'd1:
                  (op_clra                                  ) ? 'd0:                                 
                  ((op_movc | op_movai)                     ) ? i_code_data:
                  (op_movxad & (dptr == 16'h200)            ) ? {7'd0, (uart_tx_state != SM_UART_TX_IDLE)}:        
                                                                acc_add_wrap[7:0];

always@(posedge i_clk or negedge i_nrst) begin
   if(!i_nrst)    acc <= 'd0;
   else if(sme)   acc <= acc_next;
end
 
///////////////////////////////////////////////////////////////////////////////////////////////////////
// DPTR

assign l_dptr_code =  (i_code_data == DPL);
assign l_dptr_data =  (l_data== DPL);

assign l_dptr_next = (op_movdi) ? i_code_data:
                     (op_xchdi) ? acc:
                     (op_movda & l_dptr_code) ? acc:
                     l_dptr_code ? r_sel:
                     l_dptr_data ? i_data_data:
                                   l_data; 
assign l_dptr_upd  = sme & (
                     (op_movdi & (h_data == DPL)) |
                     (op_xchdi & (h_data == DPL)) |
                     (op_movdp) |
                     (op_movda & l_dptr_code) |
                     (op_movd  & l_dptr_code) |
                        (op_movdd & l_dptr_data));

   assign h_dptr_code =  (i_code_data == DPH);
   assign h_dptr_data =  (l_data== DPH);
   
   assign h_dptr_next = (op_movdi) ? i_code_data:
                        (op_xchdi) ? acc:
                        (op_movda & h_dptr_code) ? acc:
                        h_dptr_code ? r_sel:
                        h_dptr_data ? i_data_data:
                                      h_data;
   assign h_dptr_upd  = sme & (
                        (op_movdi & (h_data == DPH)) |
                        (op_xchdi & (h_data == DPH)) | 
                        (op_movdp) |
                        (op_movda & h_dptr_code) |
                        (op_movd  & h_dptr_code) |
                        (op_movdd & h_dptr_data));
                         
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)          l_dptr <= 'd0;
      else if(l_dptr_upd)  l_dptr <= l_dptr_next;
   end
   
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)          h_dptr <= 'd0;
      else if(h_dptr_upd)  h_dptr <= h_dptr_next;
   end
   
   assign dptr = {h_dptr,l_dptr};

   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // CARRY
  
   assign carry_next = (op_subbad & carry & d_acc) |
                       (((op_subbad & d_bb) | op_subbar | op_subbai) & acc_sub_wrap[8]) |
                       ((op_addai | op_inca | op_addar | op_addcr | op_addad) & acc_add_wrap[8]) |                      
                       (op_movcb & (i_code_data[7:3] == (ACC >> 3)) & acc[i_code_data[2:0]]) | 
                       (op_rrc & acc[0]) |
                       (op_rlc & acc[7]) | 
                       (op_cjnead & (acc < r_sel)) |
                       (op_cjneri & (r_sel < h_data)) |
                       op_setbc;

   assign carry_upd  = sme & (op_movcb | op_clrc | op_cjneri | op_cjnead | op_addad |  op_subbai | op_subbar | op_rlc | op_rrc | op_subbad | op_addai | op_inca | op_setbc | op_addar | op_addcr); 

    always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)          carry <= 1'b0;
      else if(carry_upd)   carry <= carry_next;
   end
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // B
 
   assign b_next = (op_pop & (h_data == BB)) ? i_data_data:
                   (op_movdd & (l_data == BB)  ) ? i_data_data:
                   (op_xchdi & (h_data == BB)  ) ? acc:  
                   (op_mul & mul_done          ) ? mul_ab[15:8]:
                   (op_movda & d_bb            ) ? acc:
                   (op_movdi & (h_data == BB)  ) ? i_code_data:
                   (op_movd & d_bb             ) ? r_sel:
                   (op_xrldi & (h_data == BB)  ) ? b ^ l_data:
                                                   b;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    b <= 'd0;
      else if(sme)   b <= b_next;
   end
    
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // Stack pointer
  
   assign sp_inc  = sp + 1;
   assign sp_dec  = sp - 1;
   assign sp_next = ((sme & op_push) | (op_lcall & (smd0 | smd1))) ? sp_inc : 
                    ((sme & op_pop)  | ((smd0 | smd1) & op_ret)  ) ? sp_dec :
                    (sme & op_movdi & (h_data == SP))              ? i_code_data:
                                                                     sp;
                                
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) sp <= 8'h07;
      else        sp <= sp_next;
   end
    
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // F
  
   assign f_next =   (op_clrb & (h_data == BIT_F0)) ? 1'b0:
                     (op_cplb & (h_data == BIT_F0)) ? ~f:
                                                      f;
   
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    f <= 1'b0;
      else if(sme)   f <= f_next;
   end 

   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // DIV

   assign div_start  = op_div & smd0;
   assign div_go     = op_div & sme & ~div_done;
   assign div_shift  = {div_r[7:0],div_n[7]}; 
   assign div_comp   = (div_shift >= div_d);
   assign div_stop   = (div_i == 'd0);

   assign div_sub    = (div_comp ) ? div_d : 'd0;

   assign div_n_next = (div_start) ? acc : (div_n << 1);

   assign div_i_next = (div_go  & ~div_stop ) ? div_i - 'd1:
                       (div_done            ) ? 3'h7:
                                                div_i;
 
   assign div_r_next = (div_go  ) ? div_shift - div_sub:
                       (div_stop) ? 8'h00:
                                    div_r;  

   assign div_q_next = (div_go) ? {div_q[6:0], div_comp}:
                                  8'h00;  

   assign div_d_next = (div_start) ? b:
                                     div_d;

   always@(posedge i_clk or negedge i_nrst) begin
		if(!i_nrst)    div_n <= 'd0;
      else           div_n <= div_n_next;
   end

   always@(posedge i_clk or negedge i_nrst) begin
		if(!i_nrst)    div_d <= 'd0;
      else           div_d <= div_d_next;
   end

   always@(posedge i_clk or negedge i_nrst) begin
		if(!i_nrst)    div_q <= 'd0;
      else           div_q <= div_q_next;
   end

   always@(posedge i_clk or negedge i_nrst) begin
		if(!i_nrst)    div_r <= 'd0;
      else           div_r <= div_r_next;
   end

	always@(posedge i_clk or negedge i_nrst) begin
		if(!i_nrst)    div_i <= 'd0; 
	   else           div_i <= div_i_next;
   end

	always@(posedge i_clk or negedge i_nrst) begin
		if(!i_nrst)    div_done <= 'd0;
      else           div_done <= div_stop; 
	end
   
   ///////////////////////////////////////////////////////////////////////////////////////////////////////
   // MUL
  
   assign mul_start        = ~n_mul_idle & op_mul & sme;
   assign mul_done         = acc_zero;
   assign n_mul_idle_next  = mul_start | (n_mul_idle & ~mul_done);    
   assign mul_ab_next      = (n_mul_idle_next & ~acc_zero) ? (mul_ab + b) : 16'h0000;
   
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)                                   mul_ab <= 'd0;
      else if(~acc_zero | (mul_start & acc_zero))  mul_ab <= mul_ab_next;
   end 

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    n_mul_idle <= 'd0;
      else           n_mul_idle <= n_mul_idle_next;
   end 

endmodule
