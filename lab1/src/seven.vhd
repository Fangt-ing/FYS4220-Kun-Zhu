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
    hex0 <= 
    "11000000" when "0000000000", --0
    "11111001" when "0000000001", --1
    "10100100" when "0000000010", --2
    "10110000" when "0000000011", --3
    "10011001" when "0000000100", --4
    "10010010" when "0000000101", --5
    "10000010" when "0000000110", --6
    "11111000" when "0000000111", --7
    "10000000" when "0000001000", --8
    "10010000" when "0000001001", --9
    "10001000" when "0000001010", --A
    "10000011" when "0000001011", --b
    "11000110" when "0000001100", --C
    "10100001" when "0000001101", --d
    "10000110" when "0000001110", --E
    "10001110" when "0000001111", --F
    "01111111" when others; --7seg dot is lighted

end architecture top_level;