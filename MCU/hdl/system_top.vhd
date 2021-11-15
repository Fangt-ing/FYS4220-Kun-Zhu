library ieee;
use ieee.std_logic_1164.all;

entity system_top is
    port (
        clk                                : in std_logic;
        arst_n                             : in std_logic;
        pio_led_external_connection_export : out std_logic_vector(9 downto 0); -- export
        pio_sw_external_connection_export  : in std_logic_vector(9 downto 0) := (others => '0'); -- export
        irq                                : in std_logic_vector(2 downto 0); -- KEY1

        rx : in std_logic;
        tx : out std_logic;

        -- GENSOR_INT1  : in std_logic;
        -- GENSOR_INT2  : in std_logic;
        GSENSOR_CS_n : out std_logic;
        GSENSOR_SCLK : out std_logic;
        -- serial data output to slave
        GSENSOR_SDI : out std_logic;
        -- serial data output from slave
        GSENSOR_SDO : in std_logic
    );
end entity;

architecture rtl of system_top is
    component nios2_system is
        port (
            clk_clk                            : in std_logic                    := '0'; -- clk
            pio_irq_external_connection_export : in std_logic_vector(2 downto 0) := (others => '0'); -- export
            pio_led_external_connection_export : out std_logic_vector(9 downto 0); -- export
            pio_sw_external_connection_export  : in std_logic_vector(9 downto 0) := (others => '0'); -- export
            reset_reset_n                      : in std_logic                    := '0'; -- reset_n
            spi_external_MISO                  : in std_logic                    := '0'; -- MISO
            spi_external_MOSI                  : out std_logic; -- MOSI
            spi_external_SCLK                  : out std_logic; -- SCLK
            spi_external_SS_n                  : out std_logic; -- SS_n
            uart_basic_uart_rx                 : in std_logic := '0'; -- rx
            uart_basic_uart_tx                 : out std_logic -- tx
        );
    end component nios2_system;
    -- changed to 4 bits
    signal irq_sync_r1 : std_logic_vector(2 downto 0);
    signal irq_sync_r2 : std_logic_vector(2 downto 0);

begin
    -- The irq input signal is a button press which is asynchronous to the system clock
    -- The irq input must therefore be synchronized
    p_sync : process (clk)
    begin
        if rising_edge(clk) then
            irq_sync_r1 <= irq; --synchronization shift register
            irq_sync_r2 <= irq_sync_r1;
        end if;
    end process;

    u0 : component nios2_system
        port map(
            clk_clk                            => clk, --                         clk.clk
            pio_irq_external_connection_export => irq_sync_r2, -- pio_irq_external_connection.export
            pio_led_external_connection_export => pio_led_external_connection_export, -- pio_led_external_connection.export
            pio_sw_external_connection_export  => pio_sw_external_connection_export, --  pio_sw_external_connection.export
            reset_reset_n                      => arst_n, --                       reset.reset_n

            spi_external_MISO  => GSENSOR_SDO, --                master in slave out
            spi_external_MOSI  => GSENSOR_SDI, --                            master out slave in
            spi_external_SCLK  => GSENSOR_SCLK, --                            .SCLK
            spi_external_SS_n  => GSENSOR_CS_n, --                            .SS_n
            uart_basic_uart_rx => rx, --             uart_basic_uart.rx
            uart_basic_uart_tx => tx --                            .tx
        );

    end architecture;