
-- Based on https://nandland.com/lfsr-linear-feedback-shift-register/
-- A LFSR or Linear Feedback Shift Register
-------------------------------------------------------------------------------
 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY LFSR IS
  PORT (
    i_Clk    	 : IN STD_LOGIC;
    o_LFSR_Data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY LFSR;
 
ARCHITECTURE RTL OF LFSR IS
 
  SIGNAL r_LFSR : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11010100"; -- initilized with seed
  SIGNAL w_XNOR : STD_LOGIC; -- new bit from XNOR
   
BEGIN
 
  p_LFSR : PROCESS(i_Clk) IS
  BEGIN
    IF RISING_EDGE(i_Clk) THEN
         r_LFSR <= r_LFSR(6 DOWNTO 0) & w_XNOR;
      END IF;
  END PROCESS p_LFSR; 
 
  w_XNOR <= r_LFSR(7) XNOR r_LFSR(5) XNOR r_LFSR(4) XNOR r_LFSR(3);  -- these give the most number of states for 8 bit 
  
  o_LFSR_Data <= r_LFSR;
   
END ARCHITECTURE RTL;