set sigs [list]

lappend sigs "i_clk"
lappend sigs "i_nrst"
lappend sigs "i_rx"
lappend sigs "o_tx"
lappend sigs "rx_data"
lappend sigs "rx_state"
lappend sigs "rx_count"
lappend sigs "rx_half_sample"
lappend sigs "rx_full_sample"
lappend sigs "tx_data"
lappend sigs "tx_state"
lappend sigs "tx_count"
lappend sigs "rx_cmd"
lappend sigs "cmd_data_read"
lappend sigs "cmd_data_load"
lappend sigs "cmd_data_rhs"
lappend sigs "data"
lappend sigs "cmd_addr_read"
lappend sigs "cmd_addr_load"
lappend sigs "cmd_addr_rhs"
lappend sigs "addr"


set added [ gtkwave::addSignalsFromList $sigs ]
gtkwave::/Time/Zoom/Zoom_Full
