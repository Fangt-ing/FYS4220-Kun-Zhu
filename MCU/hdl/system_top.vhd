library ieee;
use ieee.std_logic_1164.all;

entity system_top is
    port (
        clk                                : in std_logic;
        arst_n                             : in std_logic;
        pio_led_external_connection_export : out std_logic_vector(9 downto 0); -- export
        pio_sw_external_connection_export  : in std_logic_vector(9 downto 0) := (others => 'X'); -- export
        irq                                : in std_logic -- KEY1
    );
end entity;

architecture rtl of system_top is
    -- signal CONNECTED_TO_clk_clk                            : std_logic;
    -- signal CONNECTED_TO_reset_reset_n                      : std_logic;
    -- signal CONNECTED_TO_pio_led_external_connection_export : std_logic_vector(9 downto 0) := "0000000000";
    -- signal CONNECTED_TO_pio_sw_external_connection_export  : std_logic_vector(9 downto 0) := "0000000000";
    
    component nios2_system is
        port (
            clk_clk                            : in std_logic := 'X'; -- clk
            reset_reset_n                      : in std_logic := 'X'; -- reset_n
            pio_led_external_connection_export : out std_logic_vector(9 downto 0); -- export
            pio_sw_external_connection_export  : in std_logic_vector(9 downto 0) := (others => 'X'); -- export
            pio_irq_external_connection_export : in std_logic
        );
    end component nios2_system;
    signal irq_sync : std_logic_vector(1 downto 0);

begin
    -- The irq input signal is a button press which is asynchronous to the system clock
    -- The irq input must therefore be synchronized
    p_sync : process (clk)
    begin
        if rising_edge(clk) then
            irq_sync <= irq_sync(0) & irq; --synchronization shift register
        end if;
    end process;

    u0 : component nios2_system
        port map(
            clk_clk                            => clk, --                         clk.clk
            reset_reset_n                      => arst_n, --                       reset.reset_n
            pio_led_external_connection_export => pio_led_external_connection_export, -- pio_led_external_connection.export
            pio_sw_external_connection_export  => pio_sw_external_connection_export, --  pio_sw_external_connection.export
            pio_irq_external_connection_export => irq_sync(1)
        );

    end architecture;