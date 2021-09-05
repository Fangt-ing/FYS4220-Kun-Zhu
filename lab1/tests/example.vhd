-- prs = process
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity example is
    port(
        A, B, sel : in std_logic;
        Y : out std_logic
    );
end entity;

architecture rtl of example is
    begin

        p_lable: process (sel, A, B) is
            begin
                if sel = '1' then
                    Y <= A;
                else
                    Y <= B;                    
                end if ;
        end process;
end architecture;