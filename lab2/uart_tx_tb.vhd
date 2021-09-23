library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx_tb is
end;

architecture bench of uart_tx_tb is

  component uart_tx
    port (
      clk           : in std_logic;
      arst_n        : in std_logic;
      tx_data       : in std_logic_vector (7 downto 0);
      tx_data_valid : in std_logic;
      tx_busy       : out std_logic;
      tx            : out std_logic
    );
  end component;

  -- Clock period
  constant clk_period : time := 20 ns;
  -- Generics

  -- Ports
  signal clk           : std_logic;
  signal arst_n        : std_logic := '0';
  signal tx_data       : std_logic_vector (7 downto 0);
  signal tx_data_valid : std_logic;
  signal tx_busy       : std_logic;
  signal tx            : std_logic;

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

  clk <= not clk after clk_period when clk_ena else '0';

  stimuli_process : process
  begin
    clk_ena <= true;
    wait for clk_period;
    tx_data_valid <= '1';
    wait for clk_period * 10;
    tx_data_valid <= '0';
    wait for clk_period * 424;

    tx_data_valid <= '1';
    wait for clk_period * 5;
    tx_data_valid <= '0';
    wait for clk_period * 434;

    arst_n  <= '0';
    clk_ena <= false;
    wait;
  end process;
  --   clk_process : process
  --   begin
  --   clk <= '1';
  --   wait for clk_period/2;
  --   clk <= '0';
  --   wait for clk_period/2;
  --   end process clk_process;

end architecture;