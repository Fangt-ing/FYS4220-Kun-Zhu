quit -sim

vlib work
vmap work work

vcom uart_tx.vhd
vcom uart_tx_tb.vhd

vsim uart_tx_tb

view wave

add wave -noupdate -divider uart_tx
add wave uart_tx_tb/clk_ena
add wave uart_tx_tb/clk
add wave uart_tx_tb/tx_data_valid

add wave -noupdate -divider tx_state

add wave uart_tx_tb/tx_busy
add wave uart_tx_tb/tx
