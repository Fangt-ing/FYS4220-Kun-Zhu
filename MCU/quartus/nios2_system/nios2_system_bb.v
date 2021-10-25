
module nios2_system (
	clk_clk,
	pio_led_external_connection_export,
	pio_sw_external_connection_export,
	reset_reset_n,
	pio_irq_external_connection_export);	

	input		clk_clk;
	output	[9:0]	pio_led_external_connection_export;
	input	[9:0]	pio_sw_external_connection_export;
	input		reset_reset_n;
	input		pio_irq_external_connection_export;
endmodule
