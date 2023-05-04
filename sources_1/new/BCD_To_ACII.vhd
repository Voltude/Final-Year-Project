----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.05.2022 16:22:47
-- Design Name: 
-- Module Name: display_sev_seg - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BCD_To_ACII is
    Port ( 
        data : in std_logic_vector (3 downto 0);
        acii : out std_logic_vector (7 downto 0));
end BCD_To_ACII;

architecture Behavioral of BCD_To_ACII is

begin
    with data select acii <=
        "00110000" when "0000", -- 0
        "00110001" when "0001", -- 1
        "00110010" when "0010", -- 2
        "00110011" when "0011", -- 3
        "00110100" when "0100", -- 4
        "00110101" when "0101", -- 5
        "00110110" when "0110", -- 6
        "00110111" when "0111", -- 7
        "00111000" when "1000", -- 8
        "00111001" when "1001", -- 9
        "01000001" when "1010", -- A
        "01000010" when "1011", -- B
        "01000011" when "1100", -- C
        "01000100" when "1101", -- D
        "01000101" when "1110", -- E
        "01000110" when "1111", -- F
        "00001010" when others;
end Behavioral;
