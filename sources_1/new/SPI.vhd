----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 05.03.2023 20:45:44
-- Design Name:
-- Module Name: SPI - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI is
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
           o_Read_Out : out STD_LOGIC_VECTOR(31 downto 0);
           state : out STD_LOGIC_VECTOR(1 downto 0));
end SPI;

architecture Behavioral of SPI is

type t_SPI_States is (IDLE, WRITE, READ, TESTING);
signal r_State : t_SPI_States := IDLE;

constant c_Write_Wait_Time : natural := 70;
constant c_Aquisition_Time : natural := 70;
constant c_SPI_CLK_Time : natural := 1;
constant c_Data_Width   : integer := 32;
constant c_Zero_Value : integer := 32768;


constant c_RANGE_REG            : std_logic_vector := X"D0140000";
constant c_ID_REG               : std_logic_vector := X"D0000001";
constant c_Write_Test_1         : std_logic_vector := X"D0240004";  -- Random writing sequence
constant c_Write_Test_2         : std_logic_vector := X"D024FFFF";  -- Random writing sequence
constant c_Write_Test_3         : std_logic_vector := X"D0240000";  -- Random writing sequence
constant c_Read_Test            : std_logic_vector := X"C8240000";
       
signal r_Write_Wait_Count : natural range 0 to c_Write_Wait_Time := 0;
signal r_Write_Data : std_logic_vector(31 downto 0);
signal r_Read_Data  : std_logic_vector(31 downto 0);
signal r_Read_Index : natural range 0 to 32 := 31;
signal r_Write_Index : natural range 0 to 32 := 31;
signal Sample_Valid : std_logic := '0';
signal r_Aquisition_Counter : natural range 0 to c_Aquisition_Time := 0;
signal Init_Counter : natural range 0 to 5 := 0;
signal r_Read_Data_Buffer : std_logic_vector(31 downto 0) := (others => '0');
signal r_State_Delay : t_SPI_States;


-- SPI MASTER SIGNALS
signal i_Aquisition_Clk_Delay : std_logic;
signal Enable : std_logic; 
signal Busy   : std_logic;
signal CS     : std_logic;
signal Busy_Delay : std_logic;
signal reset : std_logic;
signal s_Read_Out : std_logic_vector(c_Data_Width-1 downto 0);
constant SPI_CLK_DIV : integer range 0 to 20 := 3; --3 limit :(

--attribute mark_debug : string;
--attribute mark_debug of Enable : signal is "true";
--attribute mark_debug of Busy : signal is "true";
--attribute mark_debug of CS : signal is "true";
--attribute mark_debug of r_State : signal is "true";

--signal o_SCLK : std_logic;

begin

reset <= not i_Reset;

with r_State select state <=
    "00" when IDLE,
    "01" when WRITE,
    "10" when READ,
    "11" when TESTING,
    "00" when others;
    
o_CS <= CS;
o_Read_Out <= std_logic_vector(to_signed((to_integer(signed(s_Read_Out)) - c_Zero_Value), o_Read_Out'length));
        
SPI_MASTER : ENTITY work.spi_master
  GENERIC map(
    d_width => c_Data_Width)
  PORT map (
    clock   => i_CLK100MHZ,                             --system clock
    reset_n => reset,                             --asynchronous reset
    enable  => Enable,                            --initiate transaction
    cpol    => '0',                         --spi clock polarity
    cpha    => '0',                          --spi clock phase
    cont    => '0',                            --continuous mode command
    clk_div => SPI_CLK_DIV,                             --system clock cycles per 1/2 period of sclk
    tx_data => r_Write_Data, --data to transmit
    miso    => i_MISO,                            --master in, slave out
    sclk    => o_SCLK,                           --spi clock
    cs      => CS,                             --chip select
    mosi    => o_MOSI,                          --master out, slave in
    busy    =>  Busy,                             --busy / data ready signal
    rx_data => s_Read_Out); --data received
    
process (i_CLK100MHZ, i_Reset, i_Aquisition_Clk)
    variable v_BTNC_Pressed : boolean := false;
    variable v_Previous_BTNC : std_logic := '0';
   
    variable v_BTNU_Pressed : boolean := false;
    variable v_Previous_BTNU : std_logic := '0';
   
    variable v_BTND_Pressed : boolean := false;
    variable v_Previous_BTND : std_logic := '0';
    
    variable count : natural range 0 to 100 := 0;
    variable v_Test_Write_Count : natural range 0 to 5 := 0;
    
    variable v_End_Count : natural range 0 to 10 := 0;
    variable v_End_Delay : std_logic := '0';
begin

    i_Aquisition_Clk_Delay <= i_Aquisition_Clk;
    if i_Aquisition_Clk_Delay = '0' and i_Aquisition_Clk = '1' and Sample_Valid = '0' and r_State = READ then
        Sample_Valid <= '1';
    end if;
    
    if i_Reset = '1' then
        Init_Counter <= 0;
        r_State <= IDLE;
        r_Write_Data <= (others => '0');
        r_Read_Data <= (others => '0');
        v_End_Count  := 0;
        v_End_Delay  := '0';
    elsif rising_edge(i_CLK100MHZ) then
   
        case r_State is
            when IDLE =>
                Sample_Valid <= '0';
                
                if i_Test_Mode = '1' then
                    r_State <= TESTING;
                end if;
                v_End_Count  := 0;
                v_End_Delay  := '0';
                count := 0;
                Enable <= '0';
                if Busy = '0' then
                    if Init_Counter = 0 then
                        r_Write_Data <= c_ID_REG;
                        Init_Counter <= Init_Counter + 1;
                        r_State <= WRITE;
                    elsif Init_Counter = 1 then
                        r_Write_Data <= c_RANGE_REG;
                        Init_Counter <= Init_Counter + 1;
                        r_State <= WRITE;
                    else
                        r_Write_Data <= (others => '0');
                        Init_Counter <= 0;
                        r_State <= READ;
                    end if;
                end if;
                
            when WRITE =>
                Busy_Delay <= Busy;
                if (Busy_Delay = '1' and Busy = '0') or v_End_Delay = '1' then
                    if v_End_Count < 10 then
                        v_End_Delay := '1';
                        v_End_Count := v_End_Count + 1;
                    else
                        v_End_Delay := '0';
                        v_End_Count := 0;
                        if i_Test_Mode = '0' then
                            r_State <= IDLE;
                        else
                            r_State <= TESTING;
                        end if;
                    end if;
                    count := 0;
                    Enable <= '0';                
                else
                    if Busy = '0' then
                        if count < 50 then
                            count := count + 1;
                            Enable <= '0';
                        else
                            Enable <= '1';
                        end if;
                    else
                        count := 0;
                        Enable  <= '0';
                    end if;
                end if;
            when READ =>
                r_Write_Data <= (others => '0');
                Busy_Delay <= Busy;
                if (Busy_Delay = '1' and Busy = '0') or v_End_Delay = '1' then
                    if v_End_Count < 10 then
                        v_End_Delay := '1';
                        v_End_Count := v_End_Count + 1;
                    else
                        v_End_Delay := '0';
                        v_End_Count := 0;
                        if i_Test_Mode = '0' then
                            r_State <= READ;
                        else
                            r_State <= TESTING;
                        end if;
                    end if;
                    count := 0;
                    Enable <= '0';                
                else
                    if Busy = '0' then
                        if count < 80 then
                            count := count + 1;
                            Enable <= '0';
                        else
                            Enable <= '1';
                        end if;
                    else
                        count := 0;
                        Enable  <= '0';
                    end if;
                end if;
            when TESTING =>
                v_BTNC_Pressed := v_Previous_BTNC = '0' and i_BTNC = '1';
                v_Previous_BTNC := i_BTNC;
               
                v_BTNU_Pressed := v_Previous_BTNU = '0' and i_BTNU = '1';
                v_Previous_BTNU := i_BTNU;
               
                v_BTND_Pressed := v_Previous_BTND = '0' and i_BTND = '1';
                v_Previous_BTND := i_BTND;
                
                r_Write_Data <= (others => '0');
                Enable <= '0';
                v_End_Count  := 0;
                v_End_Delay  := '0';
                count := 0;
                if i_Test_Mode <= '0' then
                    r_State <= IDLE;
                    Init_Counter <= 0;
                else
                    if Busy = '0' then
                        if v_Test_Write_Count = 0 then
                            if v_BTNC_Pressed then
                                r_State <= WRITE;
                                r_Write_Data <= c_Write_Test_1;
                                v_Test_Write_Count := 1;
                            elsif v_BTNU_Pressed then
                                r_State <= WRITE;
                                r_Write_Data <= c_Write_Test_2;
                                v_Test_Write_Count := 1;
                            elsif v_BTND_Pressed then
                                r_State <= WRITE;
                                r_Write_Data <= c_Write_Test_3;
                                v_Test_Write_Count := 1;
                            else
                                r_State <= TESTING;
                                v_Test_Write_Count := 0;
                            end if;
                        elsif v_Test_Write_Count = 1 then
                            r_State <= WRITE;
                            r_Write_Data <= c_Read_Test;
                            v_Test_Write_Count := 2;
                        else
                            r_State <= READ;
                            r_Write_Data <= (others => '0');
                            v_Test_Write_Count := 0;
                        end if;
                    end if;
                end if;
            when others =>
                r_State <= IDLE;
                r_Write_Data <= (others => '0');
        end case;
    end if;
end process;
   

end Behavioral;