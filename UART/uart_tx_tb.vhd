library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx_tb is
end;

architecture bench of uart_tx_tb is

  component uart_tx
    port (
      clk           : in std_logic;
      arst_n        : in std_logic                     := '0';
      tx_data       : in std_logic_vector (7 downto 0) := "01111010";
      tx_data_valid : in std_logic                     := '0';
      tx_busy       : out std_logic                    := '0';
      tx            : out std_logic
    );
  end component;

  -- Clock period
  constant clk_period : time := 20 ns;
  -- Generics

  -- Ports
  signal clk           : std_logic;
  signal arst_n        : std_logic                     := '0';
  signal tx_data       : std_logic_vector (7 downto 0) := "11001011";
  signal tx_data_valid : std_logic;
  signal tx_busy       : std_logic;
  signal tx            : std_logic;
  -- signal tx_buffer : std_logic_vector(9 downto 0) := '1' & tx_data & '0';
  signal clk_ena : boolean := false;
begin

  tx_inst : uart_tx
  port map(
    clk           => clk,
    arst_n        => arst_n,
    tx_data       => tx_data,
    tx_data_valid => tx_data_valid,
    tx_busy       => tx_busy,
    tx            => tx
  );

  clk <= not clk after clk_period/2 when clk_ena else '0';

  stimuli_process : process
  begin
    -- initialize the clk signal.
    clk_ena <= true;
    wait for clk_period * 10;

    -- enable the tx_data transmission.
    tx_data_valid <= '1';
    tx            <= '1'; -- the first/ starting bit of sending is assigned.
    wait for clk_period * 434; -- wait for one bit_period.
    tx_data_valid <= '0';

    -- assigned the test tx data to send.
    for i in 0 to 7 loop
      tx <= tx_data(i);
      wait for clk_period * 434;
    end loop;
    
    tx            <= '0'; -- the last/ stop bit of sending is assigned.
    tx_data_valid <= '0'; -- transmission disabled.
    wait for clk_period * 434;

    arst_n  <= '0';
    clk_ena <= false;
    wait;
  end process;

end architecture;