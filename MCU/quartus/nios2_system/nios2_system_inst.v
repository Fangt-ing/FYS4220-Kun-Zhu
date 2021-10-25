	nios2_system u0 (
		.clk_clk                            (<connected-to-clk_clk>),                            //                         clk.clk
		.pio_led_external_connection_export (<connected-to-pio_led_external_connection_export>), // pio_led_external_connection.export
		.pio_sw_external_connection_export  (<connected-to-pio_sw_external_connection_export>),  //  pio_sw_external_connection.export
		.reset_reset_n                      (<connected-to-reset_reset_n>),                      //                       reset.reset_n
		.pio_irq_external_connection_export (<connected-to-pio_irq_external_connection_export>)  // pio_irq_external_connection.export
	);

