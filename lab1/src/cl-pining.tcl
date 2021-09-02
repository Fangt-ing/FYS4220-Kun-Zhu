#Toggle switches
set_location_assignment PIN_C10 -to sw[0]
set_location_assignment PIN_C11 -to sw[1]
set_location_assignment PIN_D12 -to sw[2]
set_location_assignment PIN_C12 -to sw[3]

#Enable the counter
# set_location_assignment PIN_f15 -to tocount

#LED outputs
set_location_assignment PIN_A8 -to led[0]
set_location_assignment PIN_A9 -to led[1]
set_location_assignment PIN_A10 -to led[2]
set_location_assignment PIN_B10 -to led[3]

# set_location_assignment PIN_B11 -to tocountled

# 7-segment
set_location_assignment PIN_c14 -to sevenled[0]
set_location_assignment PIN_e15 -to sevenled[1]
set_location_assignment PIN_c15 -to sevenled[2]
set_location_assignment PIN_c16 -to sevenled[3]
set_location_assignment PIN_e16 -to sevenled[4]
set_location_assignment PIN_d17 -to sevenled[5]
set_location_assignment PIN_c17 -to sevenled[6]
set_location_assignment PIN_d15 -to sevenled[7]

#To avoid that the FPGA is driving an unintended value on pins that are not in use:
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"