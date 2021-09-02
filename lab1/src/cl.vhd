library IEEE;
use ieee.std_logic_1164.all;

entity cl is
  port (
      sw : in std_logic_vector (4 downto 0);
      led : out std_logic_vector (4 downto 0);
      seven : out std_logic_vector(4 downto 0) -- seven as the acronym for 7-segment display.
  ) ;
end cl;

architecture ss of cl is

begin
    led <= sw;
    seven <= sw;
end ss;