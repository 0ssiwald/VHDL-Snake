
-- Based on https://nandland.com/lfsr-linear-feedback-shift-register/
-- A LFSR or Linear Feedback Shift Register
-------------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;
 
entity LFSR is
  port (
    i_Clk    	 : in std_logic;
    o_LFSR_Data : out std_logic_vector(7 downto 0)
    );
end entity LFSR;
 
architecture RTL of LFSR is
 
  signal r_LFSR : std_logic_vector(8 downto 1) := (others=> '0');
  signal w_XNOR : std_logic;
 -- Optional Seed Value
  signal i_Seed_DV   : std_logic := '1';
  signal i_Seed_Data : std_logic_vector(7 downto 0) := "10010100";
  
  signal i_Enable : std_logic := '1';
   
begin
 
  p_LFSR : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
     if i_Enable = '1' then
       if i_Seed_DV = '1' then
          r_LFSR <= i_Seed_Data;
			 i_Seed_DV <= '0';
        else
          r_LFSR <= r_LFSR(r_LFSR'left-1 downto 1) & w_XNOR;
       end if;
      end if;
    end if;
  end process p_LFSR; 
 
  w_XNOR <= r_LFSR(8) xnor r_LFSR(6) xnor r_LFSR(5) xnor r_LFSR(4);  
  
  o_LFSR_Data <= r_LFSR(r_LFSR'left downto 1);
   
end architecture RTL;