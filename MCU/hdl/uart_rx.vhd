library ieee;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity uart_rx is
  port (
    clk : in std_logic; -- 50 MHz system clock
    arst_n : in std_logic; -- Asynchronous active low reset
    rx : in std_logic; -- UART TX input
    rx_data : out std_logic_vector (7 downto 0); -- Input data to be transmitted on the RX line
    rx_err : out std_logic := '0'; -- Flag incorrect stop or start bit (active high). Reset on new reception
    rx_busy : out std_logic -- Module busy, transmission ongoing (active high)
  );
end entity;

architecture rtl of uart_rx is
  -- defines 2 states, Idle waits for signal to come
  -- transmit will allow data transmition
  type state_type is (SIdle, SReceive);

  signal rx_state : state_type;
  signal baud_cnt : integer := 0; -- can be assigned as integer
  signal bit_cnt : integer := 0; -- enables the bit to count up in the register
  -- baudrate = 115200 bits/s, then 1 bit period = 1/115200 = 8.68 us
  -- constant bit_period : time := 8.68 us --> bit_period = time/clk = 434 times of changes
  constant bit_period : integer := 434;

  signal rx_buffer : std_logic_vector(9 downto 0); -- data type need to be kept the same as tx_data_valid when related.

begin

  rx_process : process (clk, arst_n) is
    -- variables syncronize with the assinged value simultaneously, signal type does not.
    -- so the sample values should be made variable instead of signal.
    variable sample1 : std_logic := '1';
    -- variable sample2 : std_logic := '1'; not necessary.
  begin
    if arst_n = '0' then
      rx_state <= SIdle;
    elsif rising_edge(clk) then
      case rx_state is
        when SIdle =>
          -- rx_err   <= '0';
          rx_busy <= '0';
          baud_cnt <= 0;
          bit_cnt <= 0;
          -- sample1  <= '1'; not signal, can't be defined in state.
          -- sample2  <= '1';
          if rx = '0' then
            rx_state <= SReceive;
            rx_busy <= '1';
            rx_err <= '0';
          end if;

        when SReceive =>
          rx_busy <= '1';
          baud_cnt <= baud_cnt + 1;
          if baud_cnt = bit_period/3 then
            sample1 := rx;
          elsif baud_cnt = bit_period * 2/3 then
            -- sample2 := rx;
            if sample1 = rx then
              rx_buffer(bit_cnt) <= rx;
            else
              rx_err <= '1';
              rx_state <= SIdle;
            end if;
          end if;

          if baud_cnt = bit_period then
            baud_cnt <= 0;
            bit_cnt <= bit_cnt + 1;
            -- rx_data(bit_cnt) <= rx_buffer(bit_cnt + 1);
          end if;
          if bit_cnt = 10 then
            rx_state <= SIdle;
            rx_data <= rx_buffer(8 downto 1);
          end if;
      end case;
    end if;
  end process;
end architecture;