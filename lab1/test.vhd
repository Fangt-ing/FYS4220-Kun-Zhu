library ieee;
use ieee.std_logic_1164.all;

entity test is
  port (
    key : in std_logic_vector(1 downto 0);
    led : out std_logic_vector(1 downto 0)
  );
end entity;

architecture rtl of test is

begin
  led <= key;

end architecture;