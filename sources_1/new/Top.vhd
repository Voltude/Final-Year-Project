----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.03.2023 13:01:43
-- Design Name: 
-- Module Name: Top - Behavioral
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

entity Top is
    port (
        CLK100MHZ   : in    std_logic; --FPGA Clock       
        JA          : out   std_logic_vector(4 downto 0);
        i_JA        : in    std_logic;
        test_mode   : in    std_logic;
        LED         : out   std_logic_vector(15 downto 0);
        C           : out   std_logic_vector(6 downto 0);
        AN          : out   std_logic_vector(7 downto 0);
        BTNC        : in    std_logic;
        BTNU        : in    std_logic;
        BTND        : in    std_logic
    );
end Top;

architecture Behavioral of Top is


type t_SPI_States is (IDLE, WRITE, READ, TESTING);
signal r_State : t_SPI_States := IDLE;

constant    c_DATA_WIDTH  : natural := 32;

signal      r_RST       : std_logic := '1';
constant    c_CNT_RST   : natural := 500;
signal      r_CNT_RST   : natural range 0 to c_CNT_RST := 0;

signal      r_WCLK       : std_logic := '0'; -- Wave clk
constant    c_CNT_WCLK   : natural := 156;
signal      r_CNT_WCLK   : natural range 0 to c_CNT_WCLK := 0;

signal      r_sine_value : std_logic_vector(15 downto 0);
signal      r_cos_value  : std_logic_vector(15 downto 0);

signal      read_reg     : std_logic_vector(c_DATA_WIDTH-1 downto 0);
signal      BTN_C        : std_logic;
signal      BTN_U        : std_logic;
signal      BTN_D        : std_logic;


signal      Test_Display : std_logic_vector(31 downto 0) := (others => '0');

signal      CLK_1_HZ     : std_logic;
signal      CLK_100000_HZ : std_logic;

signal      test_mode_delay : std_logic;

signal MISO : std_logic;
signal MOSI : std_logic;
signal CS   : std_logic;
signal SCLK : std_logic;

--Quad Signals
signal I : std_logic_vector (c_DATA_WIDTH-1 downto 0);
signal Q : std_logic_vector (c_DATA_WIDTH-1 downto 0);
signal Demod_Ready : std_logic;

-- Computer interface signals
signal Computer_Data : std_logic_vector(c_DATA_WIDTH-1 downto 0) := (others=>'0');
signal UART_Busy : std_logic := '0';
signal Sending : std_logic := '0';
signal Tx : std_logic;

--attribute mark_debug : string;
--attribute mark_debug of r_WCLK : signal is "true";
--attribute mark_debug of r_RST : signal is "true";
--attribute mark_debug of MISO : signal is "true";
--attribute mark_debug of MOSI : signal is "true";
--attribute mark_debug of CS : signal is "true";
--attribute mark_debug of SCLK : signal is "true";

begin


LED <= read_reg(c_DATA_WIDTH-1 downto 16);
JA(0) <= SCLK;
JA(1) <= CS;
JA(2) <= MOSI;
JA(3) <= not r_RST;
JA(4) <= Tx;
MISO <= i_JA;

Clock_Divider_2 : entity work.clk_divider
    generic map (
        FREQ_OUT => 100000)
    port map (
        clk_in => CLK100MHZ,
        clk_out => CLK_100000_HZ);

Debouncer_Inst_1 : entity work.debounce
port map (
            reset => '0',
            clock => CLK100MHZ, -- was 100MHZ
            input => BTNC,
            output => BTN_C);
            
Debouncer_Inst_2 : entity work.debounce
port map (
            reset => '0',
            clock => CLK100MHZ, -- was 100MHZ
            input => BTNU,
            output => BTN_U);
         
Debouncer_Inst_3 : entity work.debounce
port map (
            reset => '0',
            clock => CLK100MHZ, -- was 100MHZ
            input => BTND,
            output => BTN_D);
            
Clock_Divider : entity work.clk_divider
    generic map (
        FREQ_OUT => 1)
    port map (
        clk_in => CLK100MHZ,
        clk_out => CLK_1_HZ);

Disp : entity work.display
    generic map (
           NUM_SIZE => 16,
           NUM_SEGS => 6 
    )
    Port map ( reset => r_RST,
               clock => CLK100MHZ,
               error => '0',
               number => read_reg(c_DATA_WIDTH-1 downto 16),
               anodes => AN(5 downto 0),
               cathodes => C);
      
AN(7 downto 6) <= "11";         
process (CLK_1_HZ, r_RST)
begin
    if r_RST = '1' then
        Test_Display <= (others => '0');
    elsif rising_edge (CLK_1_HZ) then
        Test_Display <= std_logic_vector(resize((unsigned(Test_Display) + 1), Test_Display'length));
    end if;
end process;

ADC_Interface : entity work.SPI
    Port map(  i_CLK100MHZ => CLK100MHZ,
               i_Reset => r_RST,
               i_BTNC => BTN_C,
               i_BTNU => BTN_U,
               i_BTND => BTN_D,
               i_Aquisition_Clk => r_WCLK,
               i_Test_Mode => test_mode,
               o_SCLK => SCLK,
               o_MOSI => MOSI,
               i_MISO => MISO,
               o_CS   => CS,
               o_Read_Out => read_reg);

quad_demodulation : entity work.Data_Processing
    Port map (
           i_WCLK =>  r_WCLK,  -- Wave clock
           i_RST =>  r_RST,
           i_Data => read_reg(c_DATA_WIDTH-1 downto 16),
           i_Sin =>  r_sine_value,
           i_Cos =>  r_cos_value,
           o_I => I,
           o_Q => Q,
           o_Out_Ready => Demod_Ready
           );

wave_LUT : entity work.Sine_Cosine_Values
port map (
    clock       =>  r_WCLK,
    reset       =>  r_RST,
    output_sine =>  r_sine_value,
    output_cos  =>  r_cos_value
    );

uart_computer_interface : entity work.Computer_Interface
  Port map ( 
    i_CLK100MHZ => CLK100MHZ,
    i_Reset => r_RST,
    i_Data => Computer_Data,
    --i_Data => X"1CBE991A75",
    i_Send_data => Sending,
    o_Tx => Tx,
    o_Busy => UART_Busy
  );
    
process(CLK100MHZ)
    variable Sending_I : boolean := true;
    
    variable I_Q_Sent : natural := 0;
    
begin
    if rising_edge(CLK100MHZ) then
    
        if UART_Busy = '1' then         
            Sending <= '0';
        end if;
        
        if Demod_Ready = '1' then
            
            if Sending_I then
                Computer_Data <= I;
                Sending <= '1';
                Sending_I := false;
            else
                Computer_Data <= Q;
                Sending <= '1';
                Sending_I := true;
            end if;
        end if;

    end if;
end process;
  

start_up : process (CLK100MHZ, test_mode)
    begin
        if rising_edge (CLK100MHZ) then
            if r_CNT_RST < c_CNT_RST then
                r_RST <= '1';
                r_CNT_RST <= r_CNT_RST + 1;
            else
                r_RST <= '0';
            end if;
        end if;
end process;

wave_gen_clk : process (CLK100MHZ)
    begin
        if rising_edge (CLK100MHZ) then
            if r_CNT_WCLK = c_CNT_WCLK then
                r_WCLK <= not r_WCLK;
                r_CNT_WCLK <= 0;
                
            else
                r_CNT_WCLK <= r_CNT_WCLK + 1;
            end if;
        end if;
end process;

end Behavioral;
