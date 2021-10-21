library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- UVVM Utility Library
-------------------------------------------------------------------------------
library uvvm_util;
context uvvm_util.uvvm_util_context;

-- The UVVM library contains a bus functional models (BFMs) for the Avalon memory mapped
-- interface, and the UART TX and RX protocol
-- These two package provide access to procedures that can be used to write to and read from an Avalon Memory mapped
-- interface, and to read and write to a UART.
use uvvm_util.uart_bfm_pkg.all;
use uvvm_util.avalon_mm_bfm_pkg.all;
-------------------------------------------------------------------------------

entity uart_tb is
end uart_tb;
architecture sim of uart_tb is

    constant GC_SYSTEM_CLK : integer := 50_000_000;
    constant GC_BAUD_RATE  : integer := 115_200;

    constant C_BIT_PERIOD : time := 1 sec / GC_BAUD_RATE;
    constant C_CLK_PERIOD : time := 1 sec / GC_SYSTEM_CLK;

    signal clk_ena : boolean   := false;
    signal clk     : std_logic := '1';
    signal arst_n  : std_logic := '1';
    signal rx      : std_logic;
    signal tx      : std_logic;
    signal irq     : std_logic;
    --------------------
    -- Avalon BFM setup
    --------------------

    -- The UVVM avalon bus functional model (BFM) has a certain set of default configuration parameters that needs to be updated in order to be used in this project. Use the following settings.
    constant C_AVALON_MM_BFM_CONFIG : t_avalon_mm_bfm_config := (
        max_wait_cycles          => 10,
        max_wait_cycles_severity => TB_FAILURE,
        clock_period             => C_CLK_PERIOD,
        clock_period_margin      => 0 ns,
        clock_margin_severity    => TB_ERROR,
        setup_time               => C_CLK_PERIOD/4, -- recommended
        hold_time                => C_CLK_PERIOD/4, -- recommended
        bfm_sync                 => SYNC_ON_CLOCK_ONLY,
        match_strictness         => MATCH_STD_INCL_Z,
        num_wait_states_read     => 1,
        num_wait_states_write    => 0,
        use_waitrequest          => false,
        use_readdatavalid        => false,
        use_response_signal      => false,
        use_begintransfer        => false,
        id_for_bfm               => ID_BFM,
        id_for_bfm_wait          => ID_BFM_WAIT,
        id_for_bfm_poll          => ID_BFM_POLL
    );

    -- The UVVM BFM package uses a record type to group the MM IF signals
    -- Create interface signal of record type t_avalon_mm_if;
    -- See avalon_mm_if_bfm_pkg.vhd for definition
    -- Records are similar to structures in C, and are often used to define a new VHDL type.  This new type contains a group of signals that the user desire to e.g. simplify an interface.
    -- The t_avalon_mm_if needs to be constrained as some of the record members are defined as std_logic_vector without specifying the length of the vector.
    signal avalon_mm_if : t_avalon_mm_if(address(1 downto 0),
    byte_enable(3 downto 0),
    writedata(31 downto 0),
    readdata(31 downto 0));

    --------------------
    -- UART BFM setup
    --------------------

    -- Similar to the Avalon MM BFM, the UART BFM has set of default
    -- configuration parameters that needs to be updated for this specific test bench.
    -- In particular the baud rate (bit_time), number of bits, and parity and
    -- stop bits. 
    constant C_UART_BFM_CONFIG_DEFAULT : t_uart_bfm_config := (
        bit_time                              => 8.68 us, -- 115 200
        num_data_bits                         => 8,
        idle_state                            => '1',
        num_stop_bits                         => STOP_BITS_ONE,
        parity                                => PARITY_NONE,
        timeout                               => 20 * C_BIT_PERIOD,
        timeout_severity                      => error,
        num_bytes_to_log_before_expected_data => 0,
        match_strictness                      => MATCH_EXACT,
        id_for_bfm                            => ID_BFM,
        id_for_bfm_wait                       => ID_BFM_WAIT,
        id_for_bfm_poll                       => ID_BFM_POLL,
        id_for_bfm_poll_summary               => ID_BFM_POLL_SUMMARY,
        error_injection                       => C_BFM_ERROR_INJECTION_INACTIVE
    );

    -- To test the error flag of the RX module, we can active error injection on
    -- these bits.
    -- Testing stop bit. This will set a low value during the stop bit period. 
    constant C_BFM_ERROR_INJECTION_ACTIVE : t_bfm_error_injection := (
        parity_bit_error => false,
        stop_bit_error   => true
    );

    -- Create a new set of defaults for error injection purpose
    constant C_UART_BFM_CONFIG_STOP_ERROR : t_uart_bfm_config := (
        bit_time                              => 8.68 us,
        num_data_bits                         => 8,
        idle_state                            => '1',
        num_stop_bits                         => STOP_BITS_ONE,
        parity                                => PARITY_NONE,
        timeout                               => 20 * C_BIT_PERIOD, -- will default never time out
        timeout_severity                      => error,
        num_bytes_to_log_before_expected_data => 0,
        match_strictness                      => MATCH_EXACT,
        id_for_bfm                            => ID_BFM,
        id_for_bfm_wait                       => ID_BFM_WAIT,
        id_for_bfm_poll                       => ID_BFM_POLL,
        id_for_bfm_poll_summary               => ID_BFM_POLL_SUMMARY,
        error_injection                       => C_BFM_ERROR_INJECTION_ACTIVE
    );
    -- The UART receive BFM can be terminated prematurely by setting the
    -- terminate_loop to 1. We do not use this functionality.
    signal terminate_loop : std_logic := '0';

begin
    -- Generate clock signal
    clk <= not clk after C_CLK_PERIOD / 2 when clk_ena else '0';

    -- Connect UART module
    UUT : entity work.uart(rtl)
        generic map(
            GC_SYSTEM_CLK => GC_SYSTEM_CLK,
            GC_BAUD_RATE  => GC_BAUD_RATE
        )
        port map(
            clk    => clk,
            arst_n => arst_n,
            -- processor interface
            we    => avalon_mm_if.write,
            re    => avalon_mm_if.read,
            addr  => avalon_mm_if.address,
            wdata => avalon_mm_if.writedata,
            rdata => avalon_mm_if.readdata,
            irq   => avalon_mm_if.irq,
            -- UART interface
            rx => rx,
            tx => tx
        );

    -- Main test sequencer
    p_main_test_sequencer : process
        constant C_SCOPE               : string := "TB seq.";
        variable tx_data               : std_logic_vector(31 downto 0);
        variable rx_data               : std_logic_vector(31 downto 0);
        variable uart_bfm_send_data    : std_logic_vector(7 downto 0) := (others => '0');
        variable uart_bfm_receive_data : std_logic_vector(7 downto 0) := (others => '0');
        variable mm_reg_addr           : unsigned(1 downto 0)         := (others => '0');

    begin
        ----------------------------------------------------------------------------------
        -- Set and report init conditions
        ----------------------------------------------------------------------------------
        -- Increment alert counter as one warning is expected when testing writing
        -- to ID register which is read only
        --increment_expected_alerts(warning, 0);
        -- Print the configuration to the log: report/enable logging/alert conditions
        report_global_ctrl(VOID);
        report_msg_id_panel(VOID);
        enable_log_msg(ALL_MESSAGES);
        disable_log_msg(ID_POS_ACK); --make output a bit cleaner

        ------------------------
        -- Begin simulation
        ------------------------
        log(ID_LOG_HDR, "Start Simulation of TB for UART controller", C_SCOPE);
        log(ID_SEQUENCER, "Set default values for I/O and enable clock and reset system", C_SCOPE);
        -- default values
        arst_n  <= '1';
        clk_ena <= true; --Enable the system clk
        rx      <= '1';  -- set initial default value of rx line.
        wait for 5 * C_CLK_PERIOD;

        -----------------------
        -- Toggle reset
        ----------------------
        log(ID_SEQUENCER, "Activate async. reset for clk periods", C_SCOPE);
        arst_n <= '0', '1' after 5 * C_CLK_PERIOD;
        wait for C_CLK_PERIOD * 10;
        ----------------------
        --Test TX
        ----------------------
        -- Write to processor interface to initiate transactions
        log(ID_SEQUENCER, "Testing TX", C_SCOPE);
        tx_data     := x"000000AA";
        mm_reg_addr := "00";                                                            -- data register
        avalon_mm_write(mm_reg_addr, tx_data, "MM if Write transaction to UART data reg -- enabeling TX transaction", clk, avalon_mm_if, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG);

        -- Use UART BFM to monitor RX line and check that received data matches tx_data
        uart_receive(uart_bfm_receive_data, "UART receive transaction", tx, terminate_loop, C_UART_BFM_CONFIG_DEFAULT, C_SCOPE, shared_msg_id_panel);
        check_value(uart_bfm_receive_data, tx_data(7 downto 0), warning, "Checking tx data");

        -- wait for irq signal to be activated indicating transmitting complete
        await_value(irq, '1', 0 ns, C_BIT_PERIOD, error, "Interrupt expected", C_SCOPE);

        -- Read status register to check for tx irq
        mm_reg_addr := "10";
        avalon_mm_check(mm_reg_addr, x"00000010", "MM IF transaction to verify correct TX IRQ value in status register", clk, avalon_mm_if, warning, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG);
        -- write any value to the status register to reset the tx irq
        avalon_mm_write(mm_reg_addr, x"00000000", "MM IF Write transaction to reset irq in status register", clk, avalon_mm_if, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG);

        wait for 100 * C_CLK_PERIOD;

        ----------------------
        --Test RX
        ----------------------
        log(ID_SEQUENCER, "Testing RX", C_SCOPE);
        -- USE UART BFM to send data to RX line
        uart_bfm_send_data := x"55";
        uart_transmit(uart_bfm_send_data, "UART TX", rx, C_UART_BFM_CONFIG_DEFAULT, C_SCOPE, shared_msg_id_panel);
        wait for 5 * C_CLK_PERIOD;
        -- Read rx register of UART moduel to check if data has been received.
        mm_reg_addr := "01";
        avalon_mm_check(mm_reg_addr, x"00000055", "MM IF transaction to verify correct value in RX data register", clk, avalon_mm_if, warning, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG);
        -- Read status register to check for rx irq
        mm_reg_addr := "10";
        avalon_mm_check(mm_reg_addr, x"00000020", "MM IF transaction to verify correct TX IRQ value in status register", clk, avalon_mm_if, warning, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG);
        -- Reset tx irq
        avalon_mm_write(mm_reg_addr, x"00000000", "MM IF Write transaction to reset irq in status register", clk, avalon_mm_if, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG);

        ----------------------
        --Test RX with error injection for stop bit.
        ----------------------
        log(ID_SEQUENCER, "Testing RX with error injections on stop bit", C_SCOPE);
        -- USE UART BFM to send data to RX line
        uart_bfm_send_data := x"55";
        uart_transmit(uart_bfm_send_data, "UART TX", rx, C_UART_BFM_CONFIG_STOP_ERROR, C_SCOPE, shared_msg_id_panel);
        ----------------------

        -- with error injection for stop bit.
        wait for 5 * C_CLK_PERIOD;
        -- First read rx register of UART moduel to check if data has been received.
        mm_reg_addr := "01";
        avalon_mm_check(mm_reg_addr, x"00000055", "MM IF transaction to verify correct value in RX data register", clk, avalon_mm_if, warning, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG);
        -- Then read status register and check that rx_err and rx irq bits are set.
        mm_reg_addr := "10";
        avalon_mm_check(mm_reg_addr, x"00000028", "MM IF transaction to verify correct value in RX data register", clk, avalon_mm_if, warning, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG);
        -- Reset tx irq
        avalon_mm_write(mm_reg_addr, x"00000000", "MM IF Write transaction to reset irq in status register", clk, avalon_mm_if, C_SCOPE, shared_msg_id_panel, C_AVALON_MM_BFM_CONFIG);
        wait for 5 * C_CLK_PERIOD;

        clk_ena <= false;
        report_alert_counters(FINAL); -- Report final counters and print conclusion for simulation (Success/Fail)
        log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);
        wait;
    end process;
end architecture;