----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.03.2023 21:05:55
-- Design Name: 
-- Module Name: SPI_TEST_BENCH - Behavioral
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

entity SPI_TEST_BENCH is
end SPI_TEST_BENCH;

architecture Behavioral of SPI_TEST_BENCH is

component SPI is
    Port ( i_CLK100MHZ : in STD_LOGIC;
           i_Reset : in STD_LOGIC;
           i_BTNC : in STD_LOGIC;
           i_BTNU : in STD_LOGIC;
           i_BTND : in STD_LOGIC;
           i_Aquisition_Clk : in STD_LOGIC;
           i_Test_Mode : in STD_LOGIC;
           o_SCLK : buffer STD_LOGIC;
           o_MOSI : out STD_LOGIC;
           i_MISO : in STD_LOGIC;
           o_CS : out STD_LOGIC;
           o_Read_Out : out STD_LOGIC_VECTOR(31 downto 0));
end component SPI;

component SPI_2 is
    Port ( i_CLK : in STD_LOGIC;
           i_Reset : in STD_LOGIC;
           i_BTNC : in STD_LOGIC;
           i_BTNU : in STD_LOGIC;
           i_BTND : in STD_LOGIC;
           i_Aquisition_Clk : in STD_LOGIC;
           i_Test_Mode : in STD_LOGIC;
           o_SCLK : out STD_LOGIC;
           o_MOSI : out STD_LOGIC;
           i_MISO : in STD_LOGIC;
           o_CS : out STD_LOGIC;
           o_Read_Out : out STD_LOGIC_VECTOR(31 downto 0));
end component SPI_2;


constant c_BIT_NUM              : natural := 31; -- Number of BITs that make up a frame 

constant c_TEST_DATA            : std_logic_vector := X"01234567";


constant c_CLOCK_PERIOD : time := 10 ns; 
constant c_AQ_CLOCK_PERIOD : time := 3125 ns; 

signal t_clock_100 : std_logic := '0';
signal t_i_SPI_RST : std_logic := '0';
signal t_i_ACQUISITION_CLK : std_logic := '0';
signal t_o_SCLK : std_logic := '0';
signal t_o_MOSI : std_logic;
signal t_i_MISO : std_logic := '0';
signal t_o_CS   : std_logic;
signal t_read   : std_logic_vector(31 downto 0);
signal t_b      : std_logic;
signal t_o_write_complete : std_logic;
signal t_test_mode : std_logic;

constant    c_CNT_WCLK   : natural := 156;
signal      r_CNT_WCLK   : natural range 0 to c_CNT_WCLK;

constant c_CNT_DIV   : natural := 10;  -- This divides the clock by 2
    
signal r_CNT_DIV     : natural range 0 to c_CNT_DIV := 0;
signal r_CLK_DIV     : std_logic := '0';

signal t_BTNC        : std_logic;
signal t_BTNU        : std_logic;
signal t_BTND        : std_logic;
signal DATA_YES      : std_logic := '0';
signal state         : std_logic_vector(1 downto 0);

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

t_clock_100 <= not t_clock_100 after c_CLOCK_PERIOD/2;
t_i_SPI_RST <= '1', '0' after 3 * c_CLOCK_PERIOD;
t_test_mode <= '0';
t_BTNU <= '0', '1' after 10 * c_CLOCK_PERIOD;



process(t_o_CS)
    variable count : natural range 0 to 10 := 0;
begin
    if falling_edge (t_o_CS) then
        if count < 1 then
            count := count + 1;
            DATA_YES <= '0';
        else 
            DATA_YES <= '1';
        end if;
    end if;
end process;

SPI_CLK_GEN : process (t_clock_100, t_i_SPI_RST)
    begin
        if t_i_SPI_RST = '1' then
            r_CNT_DIV <= 0;
            r_CLK_DIV <= '0';
            
        elsif rising_edge (t_clock_100) then   
        
            if r_CNT_DIV = c_CNT_DIV-1 then
                r_CLK_DIV <= not r_CLK_DIV;
                r_CNT_DIV <= 0;
     
            else
                r_CNT_DIV <= r_CNT_DIV + 1;
            end if; 
        end if;
end process SPI_CLK_GEN;

Aquisition_CLK_gen : process(t_clock_100)
begin
    if rising_edge(t_clock_100) then
        if r_CNT_WCLK = c_CNT_WCLK then
                t_i_ACQUISITION_CLK <= not t_i_ACQUISITION_CLK;
                r_CNT_WCLK <= 0;
                
            else
                r_CNT_WCLK <= r_CNT_WCLK + 1;
            end if;
        end if;
end process;

SEND_DATA(c_TEST_DATA ,    t_o_SCLK,      t_o_CS,     t_i_MISO);


--UUT : SPI port map (

--    i_CLK_100MHZ  => t_clock_100,
--    i_SPI_RST     => t_i_SPI_RST,
    
--    i_ACQUISITION_CLK  => t_i_ACQUISITION_CLK,
--    b => t_b,
--    test_mode => t_test_mode,
--    BTN_C     => '0',
--    o_write_complete   => t_o_write_complete,
--    read    => t_read,
--    -- SPI 
--    o_SCLK   => t_o_SCLK,
--    o_MOSI   => t_o_MOSI,
--    i_MISO   => t_i_MISO,
    
--    o_CS     => t_o_CS
--    );
    
UUT : SPI
    port map (
        i_CLK100MHZ => t_clock_100,
        i_Reset => t_i_SPI_RST,
        i_BTNC => t_BTNC,
        i_BTNU => t_BTNU,
        i_BTND => t_BTND,
        i_Aquisition_Clk => t_i_ACQUISITION_CLK,
        i_Test_Mode => t_test_mode,
        o_SCLK => t_o_SCLK,
        o_MOSI => t_o_MOSI,
        i_MISO => t_i_MISO,
        o_CS => t_o_CS,
        o_Read_Out => t_read);

end Behavioral;

