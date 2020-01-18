set sigs [list]

lappend sigs "i_clk"
lappend sigs "i_nrst"
lappend sigs "i_rx"
lappend sigs "o_tx"
lappend sigs "rx_data"
lappend sigs "rx_state"
lappend sigs "rx_count"
lappend sigs "half_sample"
lappend sigs "full_sample"

set added [ gtkwave::addSignalsFromList $sigs ]
gtkwave::/Time/Zoom/Zoom_Full
