library ieee;
-- context ieee.ieee_std_context;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- UVVM Utility Library
-------------------------------------------------------------------------------
library uvvm_util;
context uvvm_util.uvvm_util_context;
-- The context statement is a way to group together packages that you would
-- like to include in your test bench.
-- The uvvm context can be found here:
-- https://github.com/UVVM/UVVM_Light/blob/master/src_util/uvvm_util_context.vhd
-- Have a look at the following description on how to use context
-- https://www.doulos.com/knowhow/vhdl/vhdl-2008-incorporates-existing-standards/#context

-- The UVVM library contains a bus functional models (BFMs) for the Avalon memory mapped
-- interface, and the UART TX and RX protocol
-- These two package provide access to procedures that can be used to write to and read from an Avalon Memory mapped
-- interface, and to read and write to a UART.
use uvvm_util.uart_bfm_pkg.all;
use uvvm_util.avalon_mm_bfm_pkg.all;
-------------------------------------------------------------------------------

entity uart_tb is
end;

architecture bench of uart_tb is

    component uart
        generic (
            GC_SYSTEM_CLK : integer;
            GC_BAUD_RATE  : integer
        );
        port (
            clk    : in std_logic;
            arst_n : in std_logic;
            we     : in std_logic;
            re     : in std_logic;
            wdata  : in std_logic_vector (31 downto 0);
            addr   : in std_logic_vector (1 downto 0);
            rdata  : out std_logic_vector (31 downto 0);
            rx     : in std_logic;
            tx     : out std_logic
        );
    end component;

    -- Clock period
    constant clk_period : time := 20 ns;
    -- Generics
    constant GC_SYSTEM_CLK : integer := 50_000_000;
    constant GC_BAUD_RATE  : integer := 115_200;

    -- Ports
    signal clk    : std_logic;
    signal arst_n : std_logic;
    signal we     : std_logic;
    signal re     : std_logic;
    signal wdata  : std_logic_vector (31 downto 0);
    signal addr   : std_logic_vector (1 downto 0);
    signal rdata  : std_logic_vector (31 downto 0);
    signal rx     : std_logic;
    signal tx     : std_logic;

    signal clk_ena : boolean := false;
begin

    -- uart_inst : uart
    -- generic map(
    --     GC_SYSTEM_CLK => GC_SYSTEM_CLK,
    --     GC_BAUD_RATE  => GC_BAUD_RATE
    -- )
    -- port map(
    --     clk    => clk,
    --     arst_n => arst_n,
    --     we     => we,
    --     re     => re,
    --     wdata  => wdata,
    --     addr   => addr,
    --     rdata  => rdata,
    --     rx     => rx,
    --     tx     => tx
    -- );

    -- clk <= not clk after clk_period/2 when clk_ena else '0';

    -- Main test sequencer
    p_main_test_sequencer : process
        constant C_SCOPE : string := "TB seq.";
    begin
        ----------------------------------------------------------------------------------
        -- Set and report init conditions
        ----------------------------------------------------------------------------------
        report_global_ctrl(VOID);
        report_msg_id_panel(VOID);
        enable_log_msg(ALL_MESSAGES);

        ------------------------
        -- Begin simulation
        ------------------------
        log(ID_LOG_HDR, "Start Simulation of TB for UART controller", C_SCOPE);
        ------------------------
        -- End simulation
        ------------------------
        report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
        log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);
        wait;
    end process;
end architecture;