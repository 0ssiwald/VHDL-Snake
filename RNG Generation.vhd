
-- Based on https://nandland.com/lfsr-linear-feedback-shift-register/
-- A LFSR or Linear Feedback Shift Register
-------------------------------------------------------------------------------
 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY LFSR IS
  PORT (
    i_Clk    	 : IN std_logic;
    o_LFSR_Data : OUT std_logic_vector(7 DOWNTO 0)
    );
END ENTITY LFSR;
 
ARCHITECTURE RTL OF LFSR IS
 
  SIGNAL r_LFSR : std_logic_vector(7 DOWNTO 0) := "10010100"; -- initilized with seed
  SIGNAL w_XNOR : std_logic;
   
BEGIN
 
  p_LFSR : PROCESS(i_Clk) IS
  BEGIN
    IF RISING_EDGE(i_Clk) THEN
         r_LFSR <= r_LFSR(6 DOWNTO 0) & w_XNOR;
      END IF;
  END PROCESS p_LFSR; 
 
  w_XNOR <= r_LFSR(7) xnor r_LFSR(5) xnor r_LFSR(4) xnor r_LFSR(3);  -- these give the most number of states for 8 bit 
  
  o_LFSR_Data <= r_LFSR;
   
END ARCHITECTURE RTL;