# system_top.sdc

create_clock -name clk -period 20.000 [get_ports {clk}]
derive_clock_uncertainty