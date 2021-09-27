library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_tb is
end;

architecture bench of uart_rx_tb is

  component uart_rx
    port (
      clk     : in std_logic;
      arst_n  : in std_logic := '0';
      rx      : in std_logic := '1';
      rx_data : out std_logic_vector (7 downto 0);
      rx_err  : out std_logic := '0';
      rx_busy : out std_logic := '0'
    );
  end component;

  -- Clock period
  constant clk_period : time                         := 20 ns;
  signal clk_ena      : boolean                      := false;
  signal rx_test_data : std_logic_vector(7 downto 0) := "10110101";
  -- Generics

  -- Ports
  signal clk     : std_logic;
  signal arst_n  : std_logic;
  signal rx      : std_logic;
  signal rx_data : std_logic_vector (7 downto 0);
  signal rx_err  : std_logic;
  signal rx_busy : std_logic;

begin

  uart_rx_inst : uart_rx
  port map(
    clk     => clk,
    arst_n  => arst_n,
    rx      => rx,
    rx_data => rx_data,
    rx_err  => rx_err,
    rx_busy => rx_busy
  );
  clk <= not clk after clk_period/2 when clk_ena else '0';

  stimuli_process : process
  begin
    clk_ena <= true;
    wait for clk_period * 10;

    -- brings the state machine to rx state for receiving data
    -- for a normal senario case
    rx <= '0';
    wait for clk_period * 434; -- 434 is one bit period.

    for i in 0 to 7 loop
      rx <= rx_test_data(i);
      wait for clk_period * 434;
    end loop;

    rx <= '1';
    wait for clk_period * 434;

    -- arst_n  <= '0';
    -- clk_ena <= false;

    wait for clk_period * 10;

    -- brings the state machine to rx state for receiving data
    -- for a normal senario case
    rx <= '0';
    wait for clk_period * 434/3; -- 434 is one bit period.
    rx <= '1';
    wait for clk_period * 434 *2/3;

    for i in 0 to 7 loop
      rx <= rx_test_data(i);
      wait for clk_period * 434;
    end loop;

    rx <= '1';
    wait for clk_period * 434;

    arst_n  <= '0';
    clk_ena <= false;
    wait;

  end process;

end;