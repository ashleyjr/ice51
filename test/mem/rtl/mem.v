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
               START_BIT   = 8'h80;

   // Resync
   reg                           rx0;
   reg                           rx1;

   // UART Rx
   reg   [1:0]                   rx_state;
   wire  [1:0]                   rx_state_next;
   reg   [$clog2(SAMPLE)-1:0]    rx_count;
   wire  [$clog2(SAMPLE)-1:0]    rx_count_next;
   reg   [7:0]                   rx_data;
   wire  [7:0]                   rx_data_next; 


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
   assign   rx_state_next  = (sm_rx_idle  & ~rx1        ) ? SM_RX_START:
                             (sm_rx_start & half_sample ) ? SM_RX_WAIT: 
                             (sm_rx_wait  & full_sample ) ? ((rx_data[0]) ? SM_RX_DONE : SM_RX_WAIT):
                             (sm_rx_done  & full_sample ) ? SM_RX_IDLE:
                                                            rx_state;
   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) rx_state <= SM_RX_IDLE;	
      else        rx_state <= rx_state_next;   
   end

   // Count
   assign full_sample = (rx_count == SAMPLE        );
   assign half_sample = (rx_count == (SAMPLE >> 1) );
 
   assign rx_count_next = (  sm_rx_idle | 
                            (sm_rx_start & half_sample) | 
                           ((sm_rx_done | sm_rx_wait) & full_sample)) ? 'd0 : (rx_count + 'd1);

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) rx_count <= 'd0;	
      else        rx_count <= rx_count_next;   
   end

   // rx_data
   assign rx_data_next = (sm_rx_idle & ~rx1       ) ? START_BIT:
                         (sm_rx_wait & full_sample) ? {rx1, rx_data[7:1]}:
                                                      rx_data;

   always@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) rx_data <= 'd0;	
      else        rx_data <= rx_data_next;   
   end


  
endmodule
