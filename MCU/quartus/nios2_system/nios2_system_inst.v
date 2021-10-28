	nios2_system u0 (
		.clk_clk                            (<connected-to-clk_clk>),                            //                         clk.clk
		.pio_irq_external_connection_export (<connected-to-pio_irq_external_connection_export>), // pio_irq_external_connection.export
		.pio_led_external_connection_export (<connected-to-pio_led_external_connection_export>), // pio_led_external_connection.export
		.pio_sw_external_connection_export  (<connected-to-pio_sw_external_connection_export>),  //  pio_sw_external_connection.export
		.reset_reset_n                      (<connected-to-reset_reset_n>),                      //                       reset.reset_n
		.spi_external_MISO                  (<connected-to-spi_external_MISO>),                  //                spi_external.MISO
		.spi_external_MOSI                  (<connected-to-spi_external_MOSI>),                  //                            .MOSI
		.spi_external_SCLK                  (<connected-to-spi_external_SCLK>),                  //                            .SCLK
		.spi_external_SS_n                  (<connected-to-spi_external_SS_n>),                  //                            .SS_n
		.uart_basic_uart_rx                 (<connected-to-uart_basic_uart_rx>),                 //             uart_basic_uart.rx
		.uart_basic_uart_tx                 (<connected-to-uart_basic_uart_tx>)                  //                            .tx
	);

