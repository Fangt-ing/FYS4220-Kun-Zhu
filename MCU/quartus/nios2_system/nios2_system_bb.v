
module nios2_system (
	clk_clk,
	pio_irq_external_connection_export,
	pio_led_external_connection_export,
	pio_sw_external_connection_export,
	reset_reset_n,
	spi_external_MISO,
	spi_external_MOSI,
	spi_external_SCLK,
	spi_external_SS_n,
	uart_basic_uart_rx,
	uart_basic_uart_tx);	

	input		clk_clk;
	input	[2:0]	pio_irq_external_connection_export;
	output	[9:0]	pio_led_external_connection_export;
	input	[9:0]	pio_sw_external_connection_export;
	input		reset_reset_n;
	input		spi_external_MISO;
	output		spi_external_MOSI;
	output		spi_external_SCLK;
	output		spi_external_SS_n;
	input		uart_basic_uart_rx;
	output		uart_basic_uart_tx;
endmodule
