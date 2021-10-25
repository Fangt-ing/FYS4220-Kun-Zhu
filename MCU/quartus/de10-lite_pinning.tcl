# de10-lite_pinning.tcl

# Dedicated FPGA clock pin for 50 MHz clock
set_location_assignment PIN_P11 -to clk

# key0 - used as reset
set_location_assignment PIN_B8 -to arst_n

#Toggle switches
set_location_assignment PIN_C10 -to pio_sw_external_connection_export[0]
set_location_assignment PIN_C11 -to pio_sw_external_connection_export[1]
set_location_assignment PIN_D12 -to pio_sw_external_connection_export[2]
set_location_assignment PIN_C12 -to pio_sw_external_connection_export[3]
set_location_assignment PIN_A12 -to pio_sw_external_connection_export[4]
set_location_assignment PIN_B12 -to pio_sw_external_connection_export[5]
set_location_assignment PIN_A13 -to pio_sw_external_connection_export[6]
set_location_assignment PIN_A14 -to pio_sw_external_connection_export[7]
set_location_assignment PIN_B14 -to pio_sw_external_connection_export[8]
set_location_assignment PIN_F15 -to pio_sw_external_connection_export[9]

#LED outputs
set_location_assignment PIN_A8 -to pio_led_external_connection_export[0]
set_location_assignment PIN_A9 -to pio_led_external_connection_export[1]
set_location_assignment PIN_A10 -to pio_led_external_connection_export[2]
set_location_assignment PIN_B10 -to pio_led_external_connection_export[3]
set_location_assignment PIN_D13 -to pio_led_external_connection_export[4]
set_location_assignment PIN_C13 -to pio_led_external_connection_export[5]
set_location_assignment PIN_E14 -to pio_led_external_connection_export[6]
set_location_assignment PIN_D14 -to pio_led_external_connection_export[7]
set_location_assignment PIN_A11 -to pio_led_external_connection_export[8]
set_location_assignment PIN_B11 -to pio_led_external_connection_export[9]

# key1 - used as interrupt
set_location_assignment PIN_A7 -to irq

#To avoid that the FPGA is driving an unintended value on pins that are not in use:
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"