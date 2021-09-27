library ieee;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity uart_rx is
  port (
    clk     : in std_logic; -- 50 MHz system clock
    arst_n  : in std_logic; -- Asynchronous active low reset
    rx      : in std_logic; -- UART TX input
    rx_data : out std_logic_vector (7 downto 0); -- Input data to be transmitted on the RX line
    rx_err  : out std_logic; -- Flag incorrect stop or start bit (active high). Reset on new reception
    rx_busy : out std_logic -- Module busy, transmission ongoing (active high)
  );
end entity;

architecture rtl of uart_rx is
  -- defines 2 states, Idle waits for signal to come
  -- transmit will allow data transmition
  type state_type is (SIdle, SReceive);

  signal rx_state : state_type;

  signal baud_cnt : unsigned(8 downto 0) := "000000000";

  signal bit_cnt : unsigned(3 downto 0) := "0000"; -- enables the bit to count up in the register
  -- baudrate = 115200 bits/s, then 1 bit period = 1/115200 = 8.68 us
  -- constant bit_period : time := 8.68 us --> bit_period = time/clk = 434 times of changes
  constant bit_period : integer := 434;

  signal rx_buffer : std_logic_vector(9 downto 0); -- data type need to be kept the same as tx_data_valid when related.

begin

  tx_process : process (clk, arst_n) is
    variable sample1 : std_logic := '1';
    variable sample2 : std_logic := '1';
  begin
    if rising_edge(clk) then
      case rx_state is
        when SIdle =>
          rx_err   <= '0';
          rx_busy  <= '0';
          baud_cnt <= "000000000";
          bit_cnt  <= "0000";
          if rx = '0' then
            rx_state <= SReceive;
          end if;

        when SReceive =>
          rx_busy  <= '1';
          baud_cnt <= baud_cnt + 1;
          if to_integer(baud_cnt) = 150 then
            sample1 := rx;
          end if;
          if to_integer(baud_cnt) = 300 then
            sample2 := rx;
            if sample1 = sample2 then
              rx_buffer(to_integer(bit_cnt)) <= rx;
            else
              rx_err   <= '1';
              rx_state <= SIdle;
            end if;
          end if;

          if to_integer(baud_cnt) = bit_period then
            baud_cnt <= "000000000";
            bit_cnt  <= bit_cnt + 1;
            if to_integer(bit_cnt) = 10 then
              rx_state <= SIdle;
              rx_data  <= rx_buffer(8 downto 0);
            end if;
          end if;
      end case;
    end if;
    if arst_n = '1' then
      rx_state <= SIdle;
    end if;
    end process;
  end architecture;