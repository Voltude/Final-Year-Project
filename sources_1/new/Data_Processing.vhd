----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.04.2023 12:48:12
-- Design Name: 
-- Module Name: Data_Processing - Behavioral
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

entity Data_Processing is
    generic (
        accumulator_size : natural := 256;
        IN_DATA_WIDTH       : natural := 16;
        OUT_DATA_WIDTH       : natural := 32
    );
    Port ( i_WCLK : in STD_LOGIC;  -- Wave clock
           i_RST : in STD_LOGIC;
           i_Data : in STD_LOGIC_VECTOR (IN_DATA_WIDTH-1 downto 0);
           i_Sin : in STD_LOGIC_VECTOR (IN_DATA_WIDTH-1 downto 0);
           i_Cos : in STD_LOGIC_VECTOR (IN_DATA_WIDTH-1 downto 0);
           o_I : out std_logic_vector (OUT_DATA_WIDTH-1 downto 0);
           o_Q : out std_logic_vector (OUT_DATA_WIDTH-1 downto 0);
           o_Out_Ready : out std_logic);
end Data_Processing;

architecture Behavioral of Data_Processing is

constant filter_data_width  : natural := 40; 

signal r_Sine_Accumulator : signed(filter_data_width-1 downto 0) := (others => '0');
signal r_Cos_Accumulator : signed(filter_data_width-1 downto 0) := (others => '0');

signal r_I_Filtered : signed(31 downto 0) := (others => '0');
signal r_Q_Filtered : signed(31 downto 0) := (others => '0');

signal r_Accumulator_Counter : natural range 0 to accumulator_size := 0;

signal out_ready : std_logic;


begin

o_Out_Ready <= out_ready;

process (i_WCLK, i_RST)
begin
    if i_RST = '1' then 
        r_Sine_Accumulator <= (others => '0');
        r_Cos_Accumulator <= (others => '0');
        r_I_Filtered <= (others => '0');
        r_Q_Filtered <= (others => '0');
        out_ready <= '0';
        
    elsif rising_edge(i_WCLK) then
    
        if out_ready = '1' then
            r_Sine_Accumulator <= (others => '0');
            r_Cos_Accumulator <= (others => '0');
        end if;
        
        if r_Accumulator_Counter < 32 then
            r_Sine_Accumulator <= r_Sine_Accumulator + (signed(i_Sin) * signed(i_Data));
            r_Cos_Accumulator <= r_Cos_Accumulator + (signed(i_Cos) * signed(i_Data));
            r_Accumulator_Counter <= r_Accumulator_Counter + 1;
            out_ready <= '0';
            
        else
            
            r_I_Filtered <= shift_right(r_Cos_Accumulator, 8)(OUT_DATA_WIDTH-1 downto 0);
            r_Q_Filtered <= shift_right(r_Sine_Accumulator, 8)(OUT_DATA_WIDTH-1 downto 0);
            
            out_ready <= '1';
            
            r_Accumulator_Counter <= 0;
        
        end if;
     end if;
end process;

o_I <= std_logic_vector(r_I_Filtered);
o_Q <= std_logic_vector(r_Q_Filtered);

end Behavioral;
