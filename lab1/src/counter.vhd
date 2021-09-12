library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    port (
        clk   : in std_logic;
        click : in std_logic_vector;
        reset : in std_logic;
        hex0: out std_logic_vector;
    );
end entity;

architecture rtl of counter is
-- holder is to create registers
signal holder : std_logic_vector(2 downto 0) := "000";
-- counting is to enable counting
signal counting : unsigned(3 downto 0) := "0000";

begin
process (clk)
begin
    
end process;
    

end architecture;