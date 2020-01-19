`timescale 1ns/1ps

module mem(
	input    wire  i_clk,
	input    wire  i_nrst,
	input	   wire  i_rx,
	output	wire	o_tx,
   output   wire	o_led4,
	output   wire	o_led3,
	output   wire	o_led2,
	output   wire	o_led1,
	output   wire	o_led0
);
   
   parameter   SAMPLE      = 105,  
               SM_RX_IDLE  = 2'b00,
               SM_RX_START = 2'b01,
               SM_RX_DONE  = 2'b11,
               SM_RX_WAIT  = 2'b10,
               START_BIT   = 8'h80,
               SM_TX0      = 4'h0,
               SM_TX1      = 4'h1,
               SM_TX2      = 4'h2,
               SM_TX3      = 4'h3,
               SM_TX4      = 4'h4,
               SM_TX5      = 4'h5,
               SM_TX6      = 4'h6,
               SM_TX7      = 4'h7,
               SM_TX_END   = 4'h8,
               SM_TX_IDLE  = 4'h9,
               SM_TX_START = 4'hA,
               CMD_DATA_READ  = 4'h0,
               CMD_DATA_LOAD  = 4'h1,
               CMD_DATA_RHS   = 4'h2,
               CMD_ADDR_READ  = 4'h3,
               CMD_ADDR_LOAD  = 4'h4,
               CMD_ADDR_RHS   = 4'h5,
               CMD_1024X8B_WE = 4'h6,
               CMD_1024X8B_RE = 4'h7;

   // RESYNC
   reg                           rx0;
   reg                           rx1;

   // UART RX
   reg   [1:0]                   rx_state;
   wire  [1:0]                   rx_state_next;
   reg   [$clog2(SAMPLE)-1:0]    rx_count;
   wire  [$clog2(SAMPLE)-1:0]    rx_count_next;
   reg   [7:0]                   rx_data;
   wire  [7:0]                   rx_data_next; 

   // UART TX
   wire  [3:0]                   tx_state_next;
   reg   [3:0]                   tx_state;
   wire  [$clog2(SAMPLE)-1:0]    tx_count_next;
   reg   [$clog2(SAMPLE)-1:0]    tx_count;
   wire  [7:0]                   tx_data_next;
   reg   [7:0]                   tx_data;

   // COMMAND
   wire  [3:0]                   rx_cmd; 
   wire  [31:0]                  data_next;
   reg   [31:0]                  data;
   wire  [31:0]                  addr_next;
   reg   [31:0]                  addr;

   // MEMORY
   wire  [7:0]                   mem_1024x8b_rdata;


   assign   {o_led4, o_led3, o_led2, o_led1, o_led0} = rx_data[4:0];
   
   ////////////////////////////////////////////////////////////////////////////////////////////////////
   // RESYNC

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) begin 
         rx0   <= 1'b1;
         rx1   <= 1'b1;
      end else begin
         rx0   <= i_rx;
         rx1   <= rx0;
      end
   end

   ////////////////////////////////////////////////////////////////////////////////////////////////////
   // UART RX
     
   // State 
   assign   sm_rx_idle     = (rx_state == SM_RX_IDLE);
   assign   sm_rx_start    = (rx_state == SM_RX_START);
   assign   sm_rx_done     = (rx_state == SM_RX_DONE);
   assign   sm_rx_wait     = (rx_state == SM_RX_WAIT);
   assign   rx_state_next  = (sm_rx_idle  & ~rx1            ) ? SM_RX_START:
                             (sm_rx_start & rx_half_sample  ) ? SM_RX_WAIT: 
                             (sm_rx_wait  & rx_full_sample  ) ? ((rx_data[0]) ? SM_RX_DONE : SM_RX_WAIT):
                             (sm_rx_done  & rx_full_sample  ) ? SM_RX_IDLE:
                                                                rx_state;
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) rx_state <= SM_RX_IDLE;	
      else        rx_state <= rx_state_next;   
   end

   // Count
   assign rx_full_sample = (rx_count == SAMPLE        );
   assign rx_half_sample = (rx_count == (SAMPLE >> 1) );
 
   assign rx_count_next = (  sm_rx_idle | 
                            (sm_rx_start & rx_half_sample) | 
                           ((sm_rx_done | sm_rx_wait) & rx_full_sample)) ? 'd0 : (rx_count + 'd1);

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) rx_count <= 'd0;	
      else        rx_count <= rx_count_next;   
   end

   // rx_data
   assign rx_data_next = (sm_rx_idle & ~rx1          ) ? START_BIT:
                         (sm_rx_wait & rx_full_sample) ? {rx1, rx_data[7:1]}:
                                                         rx_data;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) rx_data <= 'd0;	
      else        rx_data <= rx_data_next;   
   end

   assign rx_valid = sm_rx_done & rx_full_sample;

   ////////////////////////////////////////////////////////////////////////////////////////////////////
   // UART TX
 
   // Count
   assign tx_full_sample = (tx_count == SAMPLE        ); 
 
   assign tx_count_next = (sm_tx_idle | tx_full_sample) ? 'd0 : (tx_count + 'd1);

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) tx_count <= 'd0;	
      else        tx_count <= tx_count_next;   
   end
   
   // TX DATA
   assign   tx_valid       = cmd_data_read | cmd_addr_read;  
   assign   tx_data_next   = (cmd_data_read) ? data[7:0] :
                             (cmd_addr_read) ? addr[7:0] :
                                               tx_data;

  
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)       tx_data <= 'd0;	
      else if(tx_valid) tx_data <= tx_data_next;   
   end

   // TX STATE
   assign sm_tx_idle    = (tx_state == SM_TX_IDLE  );
   assign sm_tx_start   = (tx_state == SM_TX_START );
   assign sm_tx0        = (tx_state == SM_TX0      );
   assign sm_tx1        = (tx_state == SM_TX1      );
   assign sm_tx2        = (tx_state == SM_TX2      );
   assign sm_tx3        = (tx_state == SM_TX3      );
   assign sm_tx4        = (tx_state == SM_TX4      );
   assign sm_tx5        = (tx_state == SM_TX5      );
   assign sm_tx6        = (tx_state == SM_TX6      );
   assign sm_tx7        = (tx_state == SM_TX7      );


   assign tx_state_next = (sm_tx_idle  & tx_valid        ) ? SM_TX_START:
                          (sm_tx_start & tx_full_sample  ) ? SM_TX0:
                          (sm_tx0      & tx_full_sample  ) ? SM_TX1:
                          (sm_tx1      & tx_full_sample  ) ? SM_TX2:
                          (sm_tx2      & tx_full_sample  ) ? SM_TX3:
                          (sm_tx3      & tx_full_sample  ) ? SM_TX4:
                          (sm_tx4      & tx_full_sample  ) ? SM_TX5:
                          (sm_tx5      & tx_full_sample  ) ? SM_TX6:
                          (sm_tx6      & tx_full_sample  ) ? SM_TX7:
                          (sm_tx7      & tx_full_sample  ) ? SM_TX_IDLE:
                                                             tx_state;
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    tx_state <= SM_TX_IDLE;	
      else           tx_state <= tx_state_next;   
   end
   
   // Ouput
   assign o_tx =  (sm_tx_start) ? 1'b0:
                  (sm_tx0     ) ? tx_data[0]:        
                  (sm_tx1     ) ? tx_data[1]:
                  (sm_tx2     ) ? tx_data[2]:
                  (sm_tx3     ) ? tx_data[3]:
                  (sm_tx4     ) ? tx_data[4]:
                  (sm_tx5     ) ? tx_data[5]:
                  (sm_tx6     ) ? tx_data[6]:
                  (sm_tx7     ) ? tx_data[7]:
                                  1'b1;

   ////////////////////////////////////////////////////////////////////////////////////////////////////
   // COMMAND

   assign rx_cmd = rx_data[3:0];
   
   // Data 
   assign cmd_data_read       = rx_valid & (rx_cmd == CMD_DATA_READ);   // TX lowest 8 bits
   assign cmd_data_load       = rx_valid & (rx_cmd == CMD_DATA_LOAD);   // Shift left 4 bits and put in nibble at bottom
   assign cmd_data_rhs        = rx_valid & (rx_cmd == CMD_DATA_RHS);    // Shift right 8 bits
   assign cmd_data_1024x8b_re = rx_valid & (rx_cmd == CMD_1024X8B_RE);


   assign data_next = (cmd_data_load      ) ? {data[27:0],  rx_data[7:4]      }:
                      (cmd_data_rhs       ) ? {8'h00,       data[31:8]        }:
                      (cmd_data_1024x8b_re) ? {data[31:8],  mem_1024x8b_rdata }:
                                              data;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) data <= 'd0;
      else        data <= data_next; 
   end

   // Addr
   assign cmd_addr_read = rx_valid & (rx_cmd == CMD_ADDR_READ);   // TX lowest 8 bits
   assign cmd_addr_load = rx_valid & (rx_cmd == CMD_ADDR_LOAD);   // Shift left 4 bits and put in nibble at bottom
   assign cmd_addr_rhs  = rx_valid & (rx_cmd == CMD_ADDR_RHS);    // Shift right 8 bits
   

   assign addr_next = (cmd_addr_load) ? {addr[27:0],  rx_data[7:4]}:
                      (cmd_addr_rhs ) ? {8'h00,       addr[31:8]  }:
                                        addr;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) addr <= 'd0;
      else        addr <= addr_next; 
   end


   ////////////////////////////////////////////////////////////////////////////////////////////////////
   // MEMORY

   assign mem_1024x8b_we = rx_valid & (rx_cmd == CMD_1024X8B_WE);
   


   mem_1024x8b mem_1024x8b (
      .i_nrst     (i_nrst           ),
      .i_clk      (i_clk            ),
      .i_addr     (addr[9:0]        ),
      .i_we       (mem_1024x8b_we   ),
      .i_wdata    (data[7:0]        ),   
      .o_rdata    (mem_1024x8b_rdata)
   );
   

   
   

endmodule
