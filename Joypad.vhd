library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY Joypad IS 

	PORT(
		Clk_50:					IN STD_LOGIC;
		ButtonIn: 				IN STD_LOGIC_VECTOR (3 DOWNTO 0); --0111=down 1011=right 1101=left 1110=up
		MovementstateX: 		OUT INTEGER RANGE -1 TO 1 := -1; -- initilized 
		MovementstateY: 		OUT INTEGER RANGE -1 TO 1 := 0	-- initilized 
	);
END Joypad;

ARCHITECTURE Main OF Joypad IS
BEGIN
	
PROCESS(Clk_50)

	BEGIN
	IF(RISING_EDGE(Clk_50))THEN
------------------------------------------------------------------------------------------
-- Setting the Movementstate by the ButtonIn Input
		IF(ButtonIn = 	"0111")THEN
			MovementstateX <= 0;
			MovementstateY <= 1;
		ELSIF(ButtonIn = "1011")THEN
			MovementstateX <= 1;
			MovementstateY <= 0; 
		ELSIF(ButtonIn = "1101")THEN
			MovementstateX <= -1;
			MovementstateY <= 0;
		ELSIF(ButtonIn = "1110")THEN
			MovementstateX <= 0;
			MovementstateY <= -1;
		END IF;
	END IF;

END PROCESS;

END ARCHITECTURE;
