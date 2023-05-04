----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.04.2023 11:20:18
-- Design Name: 
-- Module Name: Top_TEST - Behavioral
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

entity Top_TEST is
--  Port ( );
end Top_TEST;

architecture Behavioral of Top_TEST is

component Top is
    port (
        CLK100MHZ   : in    std_logic; --FPGA Clock
        --i_RST       : in    std_logic; -- FPGA Reset
        
        JA          : out   std_logic_vector(3 downto 0);
        i_JA        : in    std_logic;
        test_mode   : in    std_logic;
        LED         : out   std_logic_vector(15 downto 0);
        C           : out   std_logic_vector(0 to 6);
        AN          : out   std_logic_vector(7 downto 0);
        BTNC        : in    std_logic;
        BTNU        : in    std_logic;
        BTND        : in    std_logic
--        out_ACLK    : out std_logic;
--        state       : out   std_logic_vector(1 downto 0)
    );
end component Top;

signal t_CLK100MHZ : std_logic := '0';
signal t_JA : std_logic_vector(3 downto 0) := (others => '0');
signal t_i_JA : std_logic := '0';
signal t_test_mode : std_logic := '0';
signal t_LED : std_logic_vector(15 downto 0) := (others => '0');
signal t_C : std_logic_vector(0 to 6) := (others => '0');
signal t_AN : std_logic_vector(7 downto 0) := (others => '0');
signal t_BTNC : std_logic := '0';
signal t_BTNU : std_logic := '0';
signal t_BTND : std_logic := '0'; 

signal t_out_ACLK : std_logic := '0';
signal state : std_logic_vector(1 downto 0);

constant c_CLK_PERIOD : time := 10 ns;
constant TEST_DATA : std_logic_vector(31 downto 0) := X"01234567";



signal DATA_YES      : std_logic := '0';

procedure SEND_DATA (
        data            : std_logic_vector;
        signal t_o_SCLK      : in std_logic;
        signal t_o_CS       : in std_logic;
        signal data_out : out std_logic
    ) is
     
begin
    if DATA_YES = '1' then
        wait until falling_edge(t_o_CS);
        data_out <= '0'; 
        for i in data' range loop
            data_out <= data(i);
            wait until falling_edge(t_o_SCLK);    
        end loop;
        data_out <= '0';
    end if;
end SEND_DATA;  

begin


t_CLK100MHZ <= not t_CLK100MHZ after c_CLK_PERIOD / 2;
--t_test_mode <= '0', '1' after 1000 * c_CLK_PERIOD;

--process
--    variable done : std_logic := '0';
--begin
--    if done = '0' then
--        wait for 1000 * c_CLK_PERIOD;
--        t_test_mode <= '1';
--        wait for 1000 * c_CLK_PERIOD;
--        t_test_mode <= '0';
--        done := '1';
--    end if;
--end process;

process(t_JA(1))
    variable count : natural range 0 to 10 := 0;
begin
    if falling_edge (t_JA(1)) then
        if count < 1 then
            count := count + 1;
            DATA_YES <= '0';
        else 
            DATA_YES <= '1';
        end if;
    end if;
end process;

SEND_DATA(TEST_DATA ,    t_JA(0),      t_JA(1),     t_i_JA); 

UUT : Top
    port map (
        CLK100MHZ => t_CLK100MHZ,        
        JA        => t_JA,
        i_JA      => t_i_JA,
        test_mode => '0',
        LED       => t_LED,
        C         => t_C,
        AN        => t_AN,
        BTNC      => t_BTNC,
        BTNU      => '0',
        BTND      => '0');
--        out_ACLK => t_out_ACLK,
--        state => state);

end Behavioral;
