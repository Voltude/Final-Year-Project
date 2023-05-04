----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.05.2022 11:17:46
-- Design Name: 
-- Module Name: debounce - Behavioral
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

entity debounce is
    generic (
           FREQ_IN : integer := 100000000;
           DELAY_MS : integer := 10;
           FF_SIZE : integer := 2
    );
    Port ( reset : in STD_LOGIC;
           clock : in STD_LOGIC;
           input : in STD_LOGIC;
           output : out STD_LOGIC);
end debounce;

architecture Behavioral of debounce is

    constant COUNT_MAX : integer := DELAY_MS * FREQ_IN / 1000;
    constant ZEROS : std_logic_vector(FF_SIZE-1 downto 0) := (others => '0');
    constant ONES : std_logic_vector(FF_SIZE-1 downto 0) := (others => '1');
    
    signal ff : std_logic_vector(FF_SIZE-1 downto 0);
    

begin

    process (clock, reset) 
        variable count: integer := 0;
    begin 
        if reset = '1' then
            count := 0;
            ff <= (others => '0');
        elsif rising_edge (clock) then
            ff <= ff(ff'high -1 downto 0) & input;
            
            if ff /= ZEROS and ff /= ONES then
                count := 0;
            elsif count < COUNT_MAX then
                count := count + 1;
            else
                output <= ff(ff'high);
            end if;
        end if;
    end process;
end Behavioral;
