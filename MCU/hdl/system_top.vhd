library ieee;
context ieee.ieee_std_context;
use ieee.math_real.all;
entity system_top is
    port (
        clk    : in std_logic;
        arst_n : in std_logic;

    );
end entity;

architecture rtl of system_top is
    component nios2sys is
        port (
            clk_clk       : in std_logic := 'X'; -- clk
            reset_reset_n : in std_logic := 'X'  -- reset_n
        );
    end component nios2sys;

begin

    u0 : component nios2sys
        port map(
            clk_clk       => clk,   --   clk.clk
            reset_reset_n => arst_n -- reset.reset_n
        );

    end architecture;