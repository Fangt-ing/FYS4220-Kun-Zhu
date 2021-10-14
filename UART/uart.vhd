library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity uart is
    generic (
        GC_SYSTEM_CLK : integer := 50_000_000;
        GC_BAUD_RATE  : integer := 115_200
    );

    port (
        clk    : in std_logic;
        arst_n : in std_logic;

        -- processor interface
        we    : in std_logic; -- <--use the same names as the testbench file
        re    : in std_logic;
        wdata : in std_logic_vector (31 downto 0);
        -- addr "00" <---stored--- tx_data
        -- addr "01" <---stored--- rx_data
        -- addr "02" <---stored--- status
        addr  : in std_logic_vector (1 downto 0);
        rdata : out std_logic_vector (31 downto 0);

        -- uart interface
        rx : in std_logic;
        tx : out std_logic

    );
end entity uart;

architecture rtl of uart is
    -- declaration for tx ports
    -- component uart_tx is
    --     port (
    --         clk           : in std_logic;                     -- 50 MHz system clock
    --         arst_n        : in std_logic;                     -- Asynchronous active low reset
    --         tx_data       : in std_logic_vector (7 downto 0); -- Input data to be transmitted on the RX line
    --         tx_data_valid : in std_logic;                     -- Valid data on tx_data. Start transmission.
    --         tx_busy       : out std_logic;                    -- Module busy, transmission ongoing (active high)
    --         tx            : out std_logic                     -- UART TX output
    --     );
    -- end component;

    -- declaration for rx ports
    component uart_rx is
        port (
            clk     : in std_logic;                      -- 50 MHz system clock
            arst_n  : in std_logic;                      -- Asynchronous active low reset
            rx      : in std_logic;                      -- UART TX input
            rx_data : out std_logic_vector (7 downto 0); -- Input data to be transmitted on the RX line
            rx_err  : out std_logic := '0';              -- Flag incorrect stop or start bit (active high). Reset on new reception
            rx_busy : out std_logic                      -- Module busy, transmission ongoing (active high)
        );
    end component;

    -- processor interface
    -- wdata --> tx_data --> tx
    signal tx_data : std_logic_vector(31 downto 0);
    -- rdata <-- rx_data <-- rx
    signal rx_data : std_logic_vector(31 downto 0);
    -- status(0) --> data_valid,  status(1) --> tx_busy, 
    -- status(2) --> rx_busy, status(3) --> rx_err
    signal status : std_logic_vector(31 downto 0);
    -- tx signals
    signal tx_data_valid : std_logic := '0';
    signal tx_busy       : std_logic; -- signal value comes from tx
    signal tx_busy_temp  : std_logic := '0';
    -- rx signals
    signal rx_err  : std_logic := '0';
    signal rx_busy : std_logic; -- signal value comes from rx 

begin

    -- tx port map
    -- entity work.uart_tx
    -- port map(
    --     clk           => clk,
    --     arst_n        => arst_n,
    --     tx_data       => tx_data,
    --     tx_data_valid => tx_data_valid,
    --     tx_busy       => tx_busy,
    --     tx            => tx
    -- );

    -- rx port map
    rx_inst : uart_rx
    port map(
        clk     => clk,
        arst_n  => arst_n,
        rx      => rx,
        rx_data => rx_data(7 downto 0),
        rx_err  => rx_err,
        rx_busy => rx_busy
    );

    p_clk : process (clk)
    begin
        -- reset the signlas. 
        if arst_n = '1' then
            tx_data       <= (others => '0');
            tx_data_valid <= '0';
            tx            <= '0';
            tx_busy       <= '0';
            rx_err        <= '0';
            tx_busy_temp  <= '0';
            status        <= (others => '0');
        end if;
        -- start the clk/ synchronization
        if rising_edge(clk) then
            tx_busy_temp <= tx_busy;
            -- assing the status bits to relevant values
            status(0) <= tx_data_valid;
            status(1) <= tx_busy;
            status(2) <= rx_busy;
            status(3) <= rx_err;
            -- enable cpu --write--> to processor interface @ addr "00"
            if we = '1' then
                if addr = "00" then
                    -- toggles tx_data_valid to enable the cpu writing to processor interface
                    tx_data_valid <= '1';
                    tx_data       <= wdata;
                end if;
            end if;
            -- enable cpu to read from processor interface
            if re = '1' then
                case addr is
                    when "01" =>
                        rdata <= rx_data;
                    when "10" =>
                        rdata <= status;
                    when others => null;
                end case;
            end if;

            -- detect the flip-flop rising eadge to determine weather to transmit data to tx.
            if tx_busy_temp = '0' and tx_busy = '1' then
                -- stops cpu to write further while tx_busy at the rising_edge
                tx_data_valid <= '1';
            elsif tx_busy_temp = '1' and tx_busy = '0' then
                tx_data_valid <= '0';
            end if;
        end if;
    end process;
end architecture;