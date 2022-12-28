library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY Joypad IS 

	PORT(
		Clk_50:					IN STD_LOGIC;
		ButtonIn: 				IN STD_LOGIC_VECTOR (3 DOWNTO 0); --0111=down 1011=right 1101=left 1110=up
		MovementstateX: 		OUT INTEGER RANGE -1 TO 1;
		MovementstateY: 		OUT INTEGER RANGE -1 TO 1
	);
END Joypad;

ARCHITECTURE Main OF Joypad IS
	SIGNAL MovementstateNextX: INTEGER RANGE -1 TO 1 := -1; --These Variables are only to initilize the Movementstates 
	SIGNAL MovementstateNextY: INTEGER RANGE -1 TO 1 := 0;
BEGIN
	
PROCESS(Clk_50)

	BEGIN
	IF(RISING_EDGE(Clk_50))THEN
------------------------------------------------------------------------------------------
-- Setting the Movementstate by the ButtonIn Input
		IF(ButtonIn = 	"0111")THEN
			MovementstateNextX <= 0;
			MovementstateNextY <= 1;
		ELSIF(ButtonIn = "1011")THEN
			MovementstateNextX <= 1;
			MovementstateNextY <= 0; 
		ELSIF(ButtonIn = "1101")THEN
			MovementstateNextX <= -1;
			MovementstateNextY <= 0;
		ELSIF(ButtonIn = "1110")THEN
			MovementstateNextX <= 0;
			MovementstateNextY <= -1;
		END IF;
	END IF;
	MovementstateX <= MovementstateNextX;	
	MovementstateY <= MovementstateNextY;
END PROCESS;

END ARCHITECTURE;
