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
        write_en : in std_logic;
        read_en  : in std_logic;
        write_d  : in std_logic_vector (31 downto 0);
        -- addr "00" <---stored--- tx_data
        -- addr "01" <---stored--- rx_data
        -- addr "02" <---stored--- status
        addr   : in std_logic_vector (1 downto 0);
        read_d : out std_logic_vector (31 downto 0);

        -- uart interface
        rx : in std_logic;
        tx : out std_logic

    );
end entity uart;

architecture rtl of uart is
    -- processor interface
    -- write_d --> tx_data --> tx
    signal tx_data : std_logic_vector(31 downto 0);
    -- read_d <-- rx_data <-- rx
    signal rx_data : std_logic_vector(31 downto 0);
    signal status  : std_logic_vector(31 downto 0);
    -- tx signals
    signal tx_data_valid : std_logic;
    signal tx_busy       : std_logic;
    signal tx_busy_temp  : std_logic;
    -- rx signals
    signal rx_err : std_logic;
begin
    p_clk : process (clk)
    begin
        -- reset the signlas. 
        if arst_n = true then
            tx_data       <= (others => '0');
            tx_data_valid <= '0';
            tx            <= '0';
            tx_busy       <= '0';
            rx_err        <= '0';
            tx_busy_temp  <= '0';
        end if;
        -- start the clk/ synchronization
        if rising_edge(clk) then
            tx_busy_temp <= tx_busy;
            -- enable cpu --write--> to processor interface @ addr "00"
            if write_d = true then
                if addr = "00" then
                    -- toggles tx_data_valid to enable the cpu writing to processor interface
                    tx_data_valid <= '1';
                    tx_data       <= write_d;
                end if;
            end if;
            -- enable cpu to read from processor interface
            if read_d = true then
                case addr is
                    when "01" =>
                        read_d <= rx_data;
                end case;
            end if;
            -- allows the cpu to check the status
            if addr = "03" then
            end if;
            -- detect the flip-flop rising eadge to determine weather to transmit data to tx.
            if tx_busy_temp = '0' and tx_busy = '1' then
                -- stops cpu to write further while tx_busy at the rising_edge
                tx_data_valid <= '0';
            end if;
        end if;
    end process;
end architecture;