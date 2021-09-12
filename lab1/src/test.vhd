library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- entity description
entity test is
  port (
    click  : in std_logic;
    clk    : in std_logic;
    reset : in std_logic;
    hex0   : out std_logic_vector(7 downto 0)
  );
end entity test;
-- architecture
architecture func of test is

  --declaration
  signal counter : unsigned(3 downto 0) := "0000";

  --internal signals for registers
  signal ena_i : std_logic_vector(2 downto 0);
  --signal ena1, ena2, ena3 : std_logic;
  -- decleration area
begin
  process (clk)
  begin
    if rising_edge(clk) then
      --ena1 <= ena_n;
      --ena2 <= ena1;
      --ena3 <= ena2;
      ena_i <= ena_i(1 downto 0) & click;
    end if;
  end process;

  process (clk)
  begin
    if reset = '0' then
      counter <= "0000";
    elsif rising_edge(clk) then
      if ena_i(1) = '0' and ena_i(2) = '1' then
        counter <= counter + 1;
      end if;
    end if;
  end process;

  with counter select
    hex0 <= "11111111" when "0000", --0
    "11111001" when "0001", --1
    "10100100" when "0010", --2
    "10110000" when "0011", --3
    "10011001" when "0100", --4
    "10010010" when "0101", --5
    "10000010" when "0110", --6
    "11111000" when "0111", --7
    "10000000" when "1000", --8
    "10010000" when "1001", --9
    "00000000" when others;

end architecture;