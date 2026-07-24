create_clock -name "clk_i" -period 10 [get_ports clk_i]
set_clock_uncertainty 0.2 [get_clock clk_i]
set_false_path -from [get_port rst_ni]
