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

# key1 - used as interrupt, as GENSOR_INT1,2 added, key is assigned to 
set_location_assignment PIN_A7 -to irq[0]

# SPI pinning
set_location_assignment PIN_V11 -to GSENSOR_SDI
set_location_assignment PIN_V12 -to GSENSOR_SDO
set_location_assignment PIN_AB16 -to GSENSOR_CS_n
set_location_assignment PIN_AB15 -to GSENSOR_SCLK
# GENSOR_INT1 assigned to irq bit 1
set_location_assignment PIN_Y14 -to irq[1]
# GENSOR_INT2 assigned to irq bit 2
set_location_assignment PIN_Y13 -to irq[2]

set_location_assignment PIN_V10 -to tx
set_location_assignment PIN_W10 -to rx

#To avoid that the FPGA is driving an unintended value on pins that are not in use:
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
