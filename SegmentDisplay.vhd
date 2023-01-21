library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY seg7 IS
  PORT (
			BiggestNumber : 	IN INTEGER RANGE 0 TO 255;
			A, B, C: 			OUT STD_LOGIC_VECTOR(6 DOWNTO 0)			-- 7segment display outout
	);
END seg7;

ARCHITECTURE arch7 OF seg7 IS

  TYPE Digits_type IS ARRAY (2 DOWNTO 0) OF INTEGER RANGE 0 TO 9;
  
  SIGNAL Digits: Digits_type;

BEGIN

  ENCODER_PROC: PROCESS(BiggestNumber, Digits)
  BEGIN
-- get the places of the biggest number with integer division
	Digits(2) <= BiggestNumber / 100;
	Digits(1) <= (BiggestNumber / 10) - ((BiggestNumber / 100) * 10);
	Digits(0) <= BiggestNumber - ((BiggestNumber / 10) * 10);
	
	CASE Digits(0) is
		WHEN 0   => A <= "1000000"; 
		WHEN 1   => A <= "1111001"; 
		WHEN 2   => A <= "0100100"; 
		WHEN 3   => A <= "0110000"; 
		WHEN 4   => A <= "0011001"; 
		WHEN 5   => A <= "0010010"; 
		WHEN 6   => A <= "0000010"; 
		WHEN 7   => A <= "1111000"; 
		WHEN 8   => A <= "0000000"; 
		WHEN 9   => A <= "0010000"; 
		WHEN OTHERS => A <= "1111111";
	END CASE;
	CASE Digits(1) is
		WHEN 0   => B <= "1000000"; 
		WHEN 1   => B <= "1111001"; 
		WHEN 2   => B <= "0100100"; 
		WHEN 3   => B <= "0110000"; 
		WHEN 4   => B <= "0011001"; 
		WHEN 5   => B <= "0010010"; 
		WHEN 6   => B <= "0000010"; 
		WHEN 7   => B <= "1111000"; 
		WHEN 8   => B <= "0000000"; 
		WHEN 9   => B <= "0010000"; 
		WHEN OTHERS => B <= "1111111";
	END CASE;
	CASE Digits(2) is
		WHEN 0   => C <= "1000000"; 
		WHEN 1   => C <= "1111001"; 
		WHEN 2   => C <= "0100100"; 
		WHEN 3   => C <= "0110000"; 
		WHEN 4   => C <= "0011001"; 
		WHEN 5   => C <= "0010010"; 
		WHEN 6   => C <= "0000010"; 
		WHEN 7   => C <= "1111000"; 
		WHEN 8   => C <= "0000000"; 
		WHEN 9   => C <= "0010000"; 
		WHEN OTHERS => C <= "1111111";
	END CASE;
	
  END PROCESS;

END ARCHITECTURE;