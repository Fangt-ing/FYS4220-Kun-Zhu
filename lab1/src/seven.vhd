library IEEE;
use IEEE.std_logic_1164.all;

entity seven is
  port (
    sw   : in std_logic_vector(9 downto 0);
    led  : out std_logic_vector(9 downto 0);
    hex0 : out std_logic_vector(7 downto 0)

  );
end entity seven;

architecture top_level of seven is

begin
  led <= sw;
  with sw select
    hex0 <= "0000001" when "0000000000", --0
    "1001111" when "0000000001", --1
    "0010010" when "0000000010", --2
    "0000110" when "0000000011", --3
    "1001100" when "0000000100", --4
    "0100100" when "0000000101", --5
    "0100000" when "0000000110", --6
    "0001111" when "0000000111", --7
    "0000000" when "0000001000", --8
    "0000100" when "0000001001", --9
    "0001000" when "0000001010", --A
    "1100000" when "0000001011", --b
    "0110001" when "0000001100", --C
    "1000010" when "0000001101", --d
    "0110000" when "0000001110", --E
    "0111000" when "0000001111", --F
    "11111111" when others; --7seg dot is lighted

end architecture top_level;