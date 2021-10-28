	component nios2_system is
		port (
			clk_clk                            : in  std_logic                    := 'X';             -- clk
			pio_irq_external_connection_export : in  std_logic_vector(2 downto 0) := (others => 'X'); -- export
			pio_led_external_connection_export : out std_logic_vector(9 downto 0);                    -- export
			pio_sw_external_connection_export  : in  std_logic_vector(9 downto 0) := (others => 'X'); -- export
			reset_reset_n                      : in  std_logic                    := 'X';             -- reset_n
			spi_external_MISO                  : in  std_logic                    := 'X';             -- MISO
			spi_external_MOSI                  : out std_logic;                                       -- MOSI
			spi_external_SCLK                  : out std_logic;                                       -- SCLK
			spi_external_SS_n                  : out std_logic;                                       -- SS_n
			uart_basic_uart_rx                 : in  std_logic                    := 'X';             -- rx
			uart_basic_uart_tx                 : out std_logic                                        -- tx
		);
	end component nios2_system;

	u0 : component nios2_system
		port map (
			clk_clk                            => CONNECTED_TO_clk_clk,                            --                         clk.clk
			pio_irq_external_connection_export => CONNECTED_TO_pio_irq_external_connection_export, -- pio_irq_external_connection.export
			pio_led_external_connection_export => CONNECTED_TO_pio_led_external_connection_export, -- pio_led_external_connection.export
			pio_sw_external_connection_export  => CONNECTED_TO_pio_sw_external_connection_export,  --  pio_sw_external_connection.export
			reset_reset_n                      => CONNECTED_TO_reset_reset_n,                      --                       reset.reset_n
			spi_external_MISO                  => CONNECTED_TO_spi_external_MISO,                  --                spi_external.MISO
			spi_external_MOSI                  => CONNECTED_TO_spi_external_MOSI,                  --                            .MOSI
			spi_external_SCLK                  => CONNECTED_TO_spi_external_SCLK,                  --                            .SCLK
			spi_external_SS_n                  => CONNECTED_TO_spi_external_SS_n,                  --                            .SS_n
			uart_basic_uart_rx                 => CONNECTED_TO_uart_basic_uart_rx,                 --             uart_basic_uart.rx
			uart_basic_uart_tx                 => CONNECTED_TO_uart_basic_uart_tx                  --                            .tx
		);

