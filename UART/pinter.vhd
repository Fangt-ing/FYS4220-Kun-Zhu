library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pinter is
    port (
        clk   : in std_logic;
        arst_n : in std_logic;
        
        to_tx : in std_logic;
        from_rx: in std_logic
        
    );
end entity pinter;

architecture rtl of pinter is

begin

    

end architecture;