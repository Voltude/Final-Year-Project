----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.04.2023 12:16:17
-- Design Name: 
-- Module Name: UART_TB - Behavioral
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

entity UART_TB is
--  Port ( );
end UART_TB;

architecture Behavioral of UART_TB is

component Computer_Interface is
  Port ( 
    i_CLK100MHZ     : in STD_LOGIC;
    i_Reset         : in STD_LOGIC;
    i_Data          : std_logic_vector(39 downto 0);
    i_Send_data     : std_logic;
    o_Tx            : out std_logic;
    o_Busy          : out std_logic;
    o_En : out std_logic;
    test : out std_logic;
    t_bcd : out std_logic_vector(47 downto 0)
  );
end component Computer_Interface;

constant c_CLK_PERIOD : time := 10 ns;
constant t_TEST_DATA : std_logic_vector(39 downto 0) := X"1CBE991A75";

signal t_CLK100MHZ : std_logic := '0';
signal t_i_SPI_RST : std_logic := '0';

signal t_i_Send_data : std_logic := '0';
signal t_o_Tx : std_logic;
signal t_o_Busy : std_logic;
signal t_o_En : std_logic;
signal t_t_bcd : std_logic_vector(47 downto 0);


signal t_test : std_logic;

begin


t_CLK100MHZ <= not t_CLK100MHZ after c_CLK_PERIOD / 2;
t_i_SPI_RST <= '1', '0' after 3 * c_CLK_PERIOD;

process (t_CLK100MHZ)
    begin 
        if t_o_Busy = '0' then 
            t_i_Send_data <= '1';
        else 
            t_i_Send_data <= '0';
        end if;
end process; 



UUT : Computer_Interface
port map (
    i_CLK100MHZ => t_CLK100MHZ,
    i_Reset     => t_i_SPI_RST,
    i_Data      => t_TEST_DATA,
    i_Send_data => t_i_Send_data,
    o_Tx        => t_o_Tx,
    o_Busy      => t_o_Busy,
    o_En        => t_o_En,
    test => t_test,
    t_bcd       => t_t_bcd);

end Behavioral;
