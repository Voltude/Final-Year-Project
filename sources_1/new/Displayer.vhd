----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.04.2023 17:22:03
-- Design Name: 
-- Module Name: Displayer - Behavioral
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

entity Displayer is
    Port ( i_Clk : in STD_LOGIC;
           i_Reset : in STD_LOGIC;
           i_Data : in STD_LOGIC_VECTOR (31 downto 0);
           o_C    : out STD_LOGIC_VECTOR(0 to 6);
           o_AN   : out STD_LOGIC_VECTOR(0 to 7));
end Displayer;

architecture Behavioral of Displayer is

component BCD_to_7SEG is
   Port ( bcd_in: in std_logic_vector (3 downto 0);	-- Input BCD vector
          leds_out: out	std_logic_vector (0 to 6));		-- Output 7-Seg vector 
end component BCD_to_7SEG; 

signal Val_0, Val_1, Val_2, Val_3, Val_4, Val_5, Val_6, Val_7 : std_logic_vector(6 downto 0) := (others => '0');
--signal bcd0, bcd1, bcd2, bcd3, bcd4, bcd5, bcd6, bcd7: std_logic_vector(3 downto 0) := (others => '0');
signal BCD : std_logic_vector(31 downto 0) := (others => '0');

signal s_Clk_1000 : std_logic;

signal SEL_AN : std_logic_vector(2 downto 0) := "000";
signal Test_Data : std_logic_vector(23 downto 0) := (others => '0');

signal bcd0, bcd1, bcd2, bcd3, bcd4, bcd5, bcd6 : std_logic_vector(3 downto 0) := (others => '0');

begin

Test_Data <= std_logic_vector(resize(unsigned(i_Data(23 downto 0)), Test_Data'length)); 

Clock_Divider : entity work.clk_divider
    generic map (
        FREQ_OUT => 1000)
    port map (
        clk_in => i_Clk,
        clk_out => s_Clk_1000);
       

--Making_BCD : entity work.bin_to_bcd
--    port map (
--        reset => i_Reset,
--        clock => i_Clk,            
--        start => '1',
--        bin   => Test_Data,
--        bcd   => BCD,
--        ready => open);
        
making_bcd : entity work.binary_bcd
        generic map (
            N => 24
        )
        port map (
            reset => i_Reset, 
            clk => i_Clk, 
            binary_in => Test_Data, 
            bcd0 => bcd0, 
            bcd1 => bcd1, 
            bcd2 => bcd2, 
            bcd3 => bcd3, 
            bcd4 => bcd4, 
            bcd5 => bcd5, 
            bcd6 => bcd6);

        
--ANODE1 : BCD_to_7SEG port map (bcd_in => BCD(3 downto 0), leds_out => Val_0);
--ANODE2 : BCD_to_7SEG port map (bcd_in => BCD(7 downto 4), leds_out => Val_1);
--ANODE3 : BCD_to_7SEG port map (bcd_in => BCD(11 downto 8), leds_out => Val_2);
--ANODE4 : BCD_to_7SEG port map (bcd_in => BCD(15 downto 12), leds_out => Val_3);  
--ANODE5 : BCD_to_7SEG port map (bcd_in => BCD(19 downto 16), leds_out => Val_4);  
--ANODE6 : BCD_to_7SEG port map (bcd_in => BCD(23 downto 20), leds_out => Val_5);  
--ANODE7 : BCD_to_7SEG port map (bcd_in => BCD(27 downto 24), leds_out => Val_6);
--ANODE8 : BCD_to_7SEG port map (bcd_in => BCD(31 downto 28), leds_out => Val_7);

INPUT_ANODE1 : BCD_to_7SEG port map (bcd_in => bcd0, leds_out => Val_0);
INPUT_ANODE2 : BCD_to_7SEG port map (bcd_in => bcd1, leds_out => Val_1);
INPUT_ANODE3 : BCD_to_7SEG port map (bcd_in => bcd2, leds_out => Val_2);
INPUT_ANODE4 : BCD_to_7SEG port map (bcd_in => bcd3, leds_out => Val_3);  
INPUT_ANODE5 : BCD_to_7SEG port map (bcd_in => bcd4, leds_out => Val_4);  
INPUT_ANODE6 : BCD_to_7SEG port map (bcd_in => bcd5, leds_out => Val_5);  
INPUT_ANODE7 : BCD_to_7SEG port map (bcd_in => bcd6, leds_out => Val_6);  



Anode_Select : process (s_Clk_1000)
begin   
    if rising_edge(s_Clk_1000) then
        case SEL_AN is					 
            when "000" => 
                o_AN <= "01111111";
                o_C <= Val_0;
                SEL_AN <= "001";
            when "001" =>
                o_AN <= "10111111";
                o_C <= Val_1;
                SEL_AN <= "010";
            when "010" =>
                o_AN <= "11011111";
                o_C <= Val_2;
                SEL_AN <= "011";
            when "011" =>
                o_AN <= "11101111";
                o_C <= Val_3;
                SEL_AN <= "100";
            when "100" =>
                o_AN <= "11110111";
                o_C <= Val_4;
                SEL_AN <= "101";
            when "101" => 
                o_AN <= "11111011";
                o_C <= Val_5;
                SEL_AN <= "110";
            when "110" =>
                o_AN <= "11111101";
                o_C <= Val_6;
                SEL_AN <= "111";
            when "111" =>
                o_AN <= "11111110";
                o_C <= Val_7;
                SEL_AN <= "000";
            when others =>
                o_AN <= "01111111";
                o_C <= Val_0;
                SEL_AN <= "001";
		end case;
    end if;
end process;


end Behavioral;
