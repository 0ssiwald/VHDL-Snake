library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- packige do define array for the 16 y vekors
-- inspired by https://stackoverflow.com/questions/20308514/declaring-an-array-within-an-entity-in-vhdl

PACKAGE ArraysInYPosition_type IS
--	Type to keep track of the whole Screen (16 x 16)
--  TYPE ArraysInYPosition IS ARRAY(0 TO 15) OF STD_LOGIC_VECTOR (0 TO 15);
--Type to Track the oldest Part of the Snake by crating a 2D array of Numbers
	 TYPE IntArray IS ARRAY(0 TO 15) OF INTEGER RANGE 0 TO 255;
	 TYPE ArrayOfIntArray IS ARRAY(0 TO 15) OF IntArray;
	 
	-- TYPE XYCOMP IS ARRAY(0 TO 1) OF INTEGER RANGE 0 TO 15;
	 --TYPE ArrayOfXYComp IS ARRAY(0 TO 255) OF XYComp;
	
	 
END PACKAGE ArraysInYPosition_type;

