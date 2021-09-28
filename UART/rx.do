quit -sim

vlib work
vmap work work

vcom uart_rx.vhd
vcom uart_rx_tb.vhd

vsim uart_rx_tb

view wave

add wave -noupdate -divider uart_rx
add wave uart_rx_tb/clk_ena
add wave uart_rx_tb/clk
add wave uart_rx_tb/rx




add wave -noupdate -divider rx_state

add wave uart_rx_tb/rx_busy
