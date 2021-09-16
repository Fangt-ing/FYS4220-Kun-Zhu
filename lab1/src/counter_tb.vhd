library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_tb is
end;

architecture bench of counter_tb is

  component counter
    port (
      sw    : in std_logic_vector(9 downto 0);
      clk   : in std_logic;
      click : in std_logic;
      reset : in std_logic;
      led   : out std_logic_vector(9 downto 0);
      hex0  : out std_logic_vector(7 downto 0)
    );
  end component;

  -- Clock period
  constant clk_period : time := 20 ns;
  -- Generics

  -- Ports
  signal sw    : std_logic_vector(9 downto 0);
  signal clk   : std_logic;
  signal click : std_logic;
  signal reset : std_logic;
  signal led   : std_logic_vector(9 downto 0);
  signal hex0  : std_logic_vector(7 downto 0);

  -- Clock enable
  signal clk_ena : boolean := false;
begin

  counter_inst : counter port map(
    sw    => sw,
    clk   => clk,
    click => click,
    reset => reset,
    led   => led,
    hex0  => hex0
  );
  clk <= not clk after clk_period/2 when clk_ena else '0';
  
  stimuli_process : process

  begin
    sw    <= "0000000000";
    click <= '1';
    reset <= '1';
    clk_ena <= true;
    -- led  <= "000000000";
    -- hex0 <= "00000000";
    wait for clk_period;
    click <= '1';
    wait for clk_period * 5;
    click <= '0';
    wait for clk_period * 10;
    click <= '1';
    wait for clk_period * 10.2;
    click <= '0';
    wait for clk_period * 5.5;
    click <= '1';
    wait for clk_period * 2;
    click <= '0';
    wait for clk_period * 5;
    reset <= '1';
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