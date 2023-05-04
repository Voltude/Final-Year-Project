----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.04.2023 14:07:03
-- Design Name: 
-- Module Name: Computer_Interface - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;  

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Computer_Interface is
  generic (
    DATA_WIDTH : natural := 32
  );
  Port ( 
    i_CLK100MHZ : in STD_LOGIC;
    i_Reset : in STD_LOGIC;
    i_Data  : in std_logic_vector(DATA_WIDTH-1 downto 0);
    i_Send_data : in std_logic;
    o_Tx : out std_logic;
    o_Busy : out std_logic;
    o_En : out std_logic;
    test : out std_logic
  );
end Computer_Interface;

architecture Behavioral of Computer_Interface is

type states is (idle, convert, send);
signal state : states;
constant o_d_width : natural := 8;
constant num_byte_send : natural := (DATA_WIDTH / 4) + 2;

constant BCD_SIZE : integer := num_byte_send * 4;

-- UART signals
signal n_Rst : std_logic := '0'; 
signal enable : std_logic := '0';
signal busy : std_logic;



-- Convertion to ACII signals
signal bcd : std_logic_vector(BCD_SIZE-1 downto 0);
signal bcd_to_convert : std_logic_vector(3 downto 0);
signal acii_char : std_logic_vector(7 downto 0) := X"00";
signal bcd_to_convert_tmp : std_logic_vector(BCD_SIZE-1 downto 0) := (others=>'0');
signal start_bcd_convertion : std_logic := '0';
signal bcd_ready : std_logic;
signal conversion_complete : std_logic := '0';
signal s_acii_char : std_logic_vector(7 downto 0) := X"00";

begin

o_En <= enable;
n_Rst <= not i_Reset;
test <= conversion_complete;

uart_inst : entity work.uart
  GENERIC map(
    clk_freq    => 100_000_000,  --frequency of system clock in Hertz
    baud_rate => 921_600,      --data link baud rate in bits/second
    os_rate   => o_d_width*2,          --oversampling rate to find center of receive bits (in samples per baud period)
    d_width   => o_d_width,           --data bus width
    parity    => 0,           --0 for no parity, 1 for parity
    parity_eo => '0')        --'0' for even, '1' for odd parity
  PORT map(
    clk      => i_CLK100MHZ,                             --system clock
    reset_n  => n_Rst,                             --ascynchronous reset
    tx_ena   =>  enable,                            --initiate transmission
    tx_data  =>  acii_char,  --data to transmit
    rx       => '0',                             --receive pin
    tx_busy  =>  busy,                             --transmission in progress
    tx       => o_Tx                              --transmit pin
    );


bin_bcd : entity work.bin_to_bcd
    generic map (
        BCD_SIZE => BCD_SIZE,
        NUM_SIZE => DATA_WIDTH,
        NUM_SEGS => num_byte_send,
        SEG_SIZE => 4
    )
    port map (
        reset => i_Reset,
        clock => i_CLK100MHZ,
        start => start_bcd_convertion,
        bin => i_Data,
        bcd => bcd,
        ready => bcd_ready
    );

bcd_acii : entity work.BCD_To_ACII
    port map ( 
        data => bcd_to_convert, 
        acii => acii_char 
    );

send_data: process(i_CLK100MHZ, i_Reset)
variable count : natural range 0 to 100 := 0;
variable bcd_count : natural range 0 to (num_byte_send*2) +1 := 0;

begin
    if i_Reset = '1' then 
        count := 0;
        enable <= '0';
        start_bcd_convertion <= '0';
        bcd_count := 0;
        o_Busy <= '0';
        state <= idle;
        
    elsif rising_edge (i_CLK100MHZ) then
         case state is
            when idle =>
                o_Busy <= '0';
                bcd_count := 0;
                if i_Send_data = '1' then
                    o_Busy <= '1';
                    state <= convert;
                end if;
            
            when convert => 
                start_bcd_convertion <= '1';
            
                if bcd_ready = '1'then 
                    bcd_to_convert_tmp <= bcd;
                    start_bcd_convertion <= '0';
                    state <= send;
                end if;
                
            when send => 
                if bcd_count < num_byte_send+1 then
                    
--                    if bcd_count = num_byte_send then
                    
--                        s_acii_char <= X"0A";
                
                    if enable = '1' and busy = '1' then
                        bcd_to_convert <= bcd_to_convert_tmp(BCD_SIZE-1 downto BCD_SIZE-4);
                        bcd_to_convert_tmp <= std_logic_vector(shift_left(unsigned(bcd_to_convert_tmp), 4));
                        bcd_count := bcd_count + 1;
                    end if;
                        
                    if busy = '0' then
                        if count < 50 then
                            count := count + 1;
                            enable <= '0';
                        else
                            enable <= '1';
                        end if;
                    else
                        count := 0;
                        enable  <= '0';
                    end if;
                else
                    state <= idle;
                end if;
        end case;
    end if;
        
end process;        

end Behavioral;
