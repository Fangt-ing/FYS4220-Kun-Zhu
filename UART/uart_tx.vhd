library ieee;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity uart_tx is
  port (
    clk           : in std_logic; -- 50 MHz system clock
    arst_n        : in std_logic; -- Asynchronous active low reset
    tx_data       : in std_logic_vector (7 downto 0); -- Input data to be transmitted on the RX line
    tx_data_valid : in std_logic; -- Valid data on tx_data. Start transmission.
    tx_busy       : out std_logic; -- Module busy, transmission ongoing (active high)
    tx            : out std_logic -- UART TX output
  );
end entity;

architecture rtl of uart_tx is
  -- defines 2 states, Idle waits for signal to come
  -- transmit will allow data transmition
  type state_type is (SIdle, STransmit);

  signal tx_state : state_type;

  signal baud_cnt : unsigned(8 downto 0) := "000000000";

  -- signal bit_cnt : unsigned(3 downto 0) := "0000"; -- enables the bit to count up in the register
  -- baudrate = 115200 bits/s, then 1 bit period = 1/115200 = 8.68 us
  -- constant bit_period : time := 8.68 us --> bit_period = time/clk = 434 times of changes
  constant bit_period : integer := 434;

  signal tx_buffer : std_logic_vector(9 downto 0); -- data type need to be kept the same as tx_data_valid when related.

begin

  tx_process : process (clk, arst_n) is
  variable bit_cnt : unsigned(3 downto 0) := "0000";
  begin
    if rising_edge(clk) then
      case tx_state is
        when SIdle =>
          tx_busy  <= '0';
          tx       <= '0';
          baud_cnt <= "000000000";
          tx_busy  <= '0';
          bit_cnt  := "0000";
          if tx_data_valid = '1' then
            tx_buffer <= '1' & tx_data & '0';
            tx_state  <= STransmit;
            tx_busy   <= '1';
          end if;

        when STransmit =>
          tx_busy  <= '1';
          tx       <= tx_buffer(to_integer(bit_cnt));
          baud_cnt <= baud_cnt + 1;

          if to_integer(baud_cnt) = bit_period then
            baud_cnt <= "000000000";
            bit_cnt  := bit_cnt + 1;
          end if;
          if to_integer(bit_cnt) = 10 then
            tx_state <= SIdle;
          end if;
      end case;
    end if;

    if arst_n = '1' then
      tx_state <= SIdle;
    end if;
  end process;
end architecture;