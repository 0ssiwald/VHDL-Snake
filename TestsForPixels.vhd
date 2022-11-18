library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY VEKTOR IS 
PORT(
	Y0: IN STD_LOGIC_VECTOR(0 to 15);
	Y1: IN STD_LOGIC_VECTOR(0 to 15);
	Y2: IN STD_LOGIC_VECTOR(0 to 15)
	
	);
END VEKTOR;

ARCHITECTURE MAIN OF VEKTOR IS

-- horizontal:  | 408 sync pixels | 128 dead px | 16 edge | 16 x 62 grid px | 16 edge | 128 dead px == 1280
-- 					1-408            409-536		537-552		553-569 ...
	IF(Y0[0] == 1)THEN
		