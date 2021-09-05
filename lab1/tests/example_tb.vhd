library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity example_tb is
end entity;

architecture tb of example_tb is

  component example is
    port(
        A, B, sel : in std_logic;
        Y : out std_logic
    );
  end component;

  signal A, B, sel, Y : std_logic;
    
begin
    
  inst1: example port map (
    A => A,
    B => B,
    sel => sel,
    Y => Y
  );
    
  p_stimuli : process
  begin
    A <= '0';
    B <= '1';
    sel <= '1';
    wait for 20 ns;
    sel <= '0';
    wait for 20 ns;

    wait;
    
  end process;
    
end architecture;