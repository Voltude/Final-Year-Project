----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.03.2023 13:31:10
-- Design Name: 
-- Module Name: Sine_Values - Behavioral
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

entity Sine_Cosine_Values is
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           output_sine : out STD_LOGIC_VECTOR(15 downto 0);
           output_cos : out STD_LOGIC_VECTOR(15 downto 0));
end Sine_Cosine_Values;

architecture Behavioral of Sine_Cosine_Values is

constant inital_sine_index : natural := 0;
constant inital_cos_index : natural := 8; 


signal Sine_index : natural range 0 to 32 := inital_sine_index;
signal Cos_index : natural range 0 to 32 := inital_cos_index;



type array_LUT_t is array (0 to 31) of integer range -32768 to 32767;

constant sine_vals : array_LUT_t := (
0,
6392,
12539,
18204,
23170,
27245,
30273,
32137,
32767,
32137,
30273,
27245,
23170,
18204,
12539,
6392,
0,
-6393,
-12540,
-18205,
-23171,
-27246,
-30274,
-32138,
-32768,
-32138,
-30274,
-27246,
-23171,
-18205,
-12540,
-6393);

begin

process(clock, reset)
begin
    if reset = '1' then
        Sine_index <= inital_sine_index;
        Cos_index <= inital_cos_index;
        output_sine <= std_logic_vector(to_signed(sine_vals(inital_sine_index), 16));
        output_cos <= std_logic_vector(to_signed(sine_vals(inital_cos_index), 16));
    elsif rising_edge(clock) then
        output_sine <= std_logic_vector(to_signed(sine_vals(Sine_index), 16));
        output_cos <= std_logic_vector(to_signed(sine_vals(Cos_index), 16));
        if Sine_index < 31 then
            Sine_index <= Sine_index + 1;
        else
            Sine_index <= 0;
        end if;
        
        if Cos_index < 31 then
            Cos_index <= Cos_index + 1;
        else
            Cos_index <= 0;
        end if;
    end if;
end process;

end Behavioral;
