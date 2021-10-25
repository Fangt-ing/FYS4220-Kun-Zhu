	component nios2_system is
		port (
			clk_clk                            : in  std_logic                    := 'X';             -- clk
			pio_led_external_connection_export : out std_logic_vector(9 downto 0);                    -- export
			pio_sw_external_connection_export  : in  std_logic_vector(9 downto 0) := (others => 'X'); -- export
			reset_reset_n                      : in  std_logic                    := 'X';             -- reset_n
			pio_irq_external_connection_export : in  std_logic                    := 'X'              -- export
		);
	end component nios2_system;

	u0 : component nios2_system
		port map (
			clk_clk                            => CONNECTED_TO_clk_clk,                            --                         clk.clk
			pio_led_external_connection_export => CONNECTED_TO_pio_led_external_connection_export, -- pio_led_external_connection.export
			pio_sw_external_connection_export  => CONNECTED_TO_pio_sw_external_connection_export,  --  pio_sw_external_connection.export
			reset_reset_n                      => CONNECTED_TO_reset_reset_n,                      --                       reset.reset_n
			pio_irq_external_connection_export => CONNECTED_TO_pio_irq_external_connection_export  -- pio_irq_external_connection.export
		);

