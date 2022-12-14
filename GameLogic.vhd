library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY GameLogic IS
	GENERIC(
		g_SNAKE_SPEED_CLK : INTEGER := 20000000 --change here for faster/slower snake higher->slower snake
	);
	PORT(
		VGAClk:				IN STD_LOGIC;
		Clk_50:				IN STD_LOGIC;
		Reset: 				IN STD_LOGIC;
		SyncSig: 			IN STD_LOGIC;
		DrawPixel: 			OUT STD_LOGIC;
		Drawfood:			OUT STD_LOGIC;
		DrawHead:			OUT STD_LOGIC;
		in_LFSR_Data : 	IN STD_LOGIC_VECTOR(7 downto 0);
		MovementstateX: 	IN INTEGER RANGE -1 TO 1;
		MovementstateY: 	IN INTEGER RANGE -1 TO 1
	);
END GameLogic;

ARCHITECTURE MainGame OF GameLogic IS
	
-- Type declaration for 2D Integer Array tracking the snake 
	TYPE IntArray IS ARRAY(0 TO 15) OF INTEGER RANGE 0 TO 255;
	TYPE ArrayOfIntArray IS ARRAY(0 TO 15) OF IntArray;

--Needs to be 0 at standard to disable reset
	SIGNAL ResetSig: STD_LOGIC;
--Signal for ClockDivider
	SIGNAL GameClock : 	std_logic := '0';	
--Signals to keep track of HPOS and VPOS for VGAsync module	
	SIGNAL HPOS: INTEGER RANGE 0 TO 1688:=0;
	SIGNAL VPOS: INTEGER RANGE 0 TO 1066:=0; 
--To track Snake body with Numbers	
	SIGNAL TrackSnakeArray: ArrayOfIntArray := (others=>(others=> 0)); 	
-- BiggestNumber is the Head Pos of the Snake
	SIGNAL BiggestNumber: INTEGER RANGE 0 TO 255 := 1;
-- This tracks the Head Pos
	SIGNAL BiggestNumberXPos: INTEGER RANGE 0 TO 15;
	SIGNAL BiggestNumberYPos: INTEGER RANGE 0 TO 15;
--This is the XY Pos of the next Field
	SIGNAL NextMoveXPos: INTEGER RANGE 0 TO 15;
	SIGNAL NextMoveYPos: INTEGER RANGE 0 TO 15;
-- to block updating NextPosMove if TrackSnakeArray(NextMoveYPos)(NextMoveXPos) = (BiggestNumber - 1)
	SIGNAL BlockNextMove: STD_LOGIC := '0'; 
--Signals from Random Number generation
	SIGNAL RandomNumber:	INTEGER RANGE 0 TO 255; 
	SIGNAL FoodPosX:		INTEGER RANGE 0 TO 15 := 7; -- initilized so the food and snake starts someware in the middle 
	SIGNAL FoodPosY:	 	INTEGER RANGE 0 TO 15 := 5;
	
BEGIN	
--------------------------------------------------------------------------------------	
--ClockDivider based on https://electronics.stackexchange.com/questions/72990/fpga-clock-strategy
SnakeSpeed: PROCESS(Clk_50)
VARIABLE Count: INTEGER RANGE 0 TO g_SNAKE_SPEED_CLK; --change here for faster/slower snake 
BEGIN
    IF(RISING_EDGE(Clk_50)) THEN
        IF(Count = g_SNAKE_SPEED_CLK)THEN -- if g_SNAKE_SPEED_CLK is reached 
            GameClock <= '1';
            Count := 0;
        ELSE
            GameClock <= '0';
            Count := Count + 1;
        END IF;
    END IF;
END PROCESS;

--------------------------------------------------------------------------------------

CreateTrackSnakeArray: PROCESS(Clk_50)
BEGIN	
IF(RISING_EDGE(Clk_50)) THEN
--------------------------------------------------------------------------------------

	RandomNumber <= (to_integer(unsigned(in_LFSR_Data)));

	FOR y IN 0 TO 15 LOOP
		FOR x IN 0 TO 15 LOOP
			IF(Reset = '0' AND TrackSnakeArray(y)(x) = 0 AND ((RandomNumber - (x+(15*y))) > 0))THEN
				FoodPosX <= x;
				FoodPosY <= y;
			END IF;
--Searches for the biggest Number !=255 in the Array
			IF((TrackSnakeArray(y)(x) >= BiggestNumber)  AND (TrackSnakeArray(y)(x) < 255))THEN
				BiggestNumberXPos <= x; --gets the x pos
				BiggestNumberYPos <= y; -- gets thy y pos
			END IF;
		END LOOP;
	END LOOP;
------------------------------------------------------------------------------------------
-- Saves the position where the Movementstate is pointing
	IF(BlockNextMove = '0')THEN 
		NextMoveXPos <= (BiggestNumberXPos + MovementstateX);
		NextMoveYPos <= (BiggestNumberYPos + MovementstateY);
	END IF;
------------------------------------------------------------------------------------------
-- When the Number is 255 = Food
	IF(TrackSnakeArray(NextMoveYPos)(NextMoveXPos) = 255)THEN
		TrackSnakeArray(NextMoveYPos)(NextMoveXPos) <= (BiggestNumber + 1);
		BiggestNumber <= BiggestNumber + 1;	
		TrackSnakeArray(FoodPosY)(FoodPosX) <= 255;
--When the Number is > 0 and < 255 -> the Snake ate itself
	ELSIF((TrackSnakeArray(NextMoveYPos)(NextMoveXPos) /= 0))THEN
		IF(TrackSnakeArray(NextMoveYPos)(NextMoveXPos) = (BiggestNumber - 1))THEN -- is to avoid moving the snake into itself 
			NextMoveXPos <= (BiggestNumberXPos + ((-1) * MovementstateX));
			NextMoveYPos <= (BiggestNumberYPos + ((-1) * MovementstateY));
			BlockNextMove <= '1';
		ELSE
			ResetSig <= '1';
		END IF;
	ELSE -- needs this else statement to default to otherwise the reset sig is always triggert
		ResetSig <= '0';
	END IF;

------------------------------------------------------------------------------------------------------------------	
IF(GameClock = '1') THEN
		BlockNextMove <= '0';
		FOR y IN 0 TO 15 LOOP
			FOR x IN 0 TO 15 LOOP
				IF((TrackSnakeArray(y)(x) /= 0) AND (TrackSnakeArray(y)(x) /= 255))THEN
					TrackSnakeArray(y)(x) <= (TrackSnakeArray(y)(x) - 1);
				END IF;
			END LOOP;
		END LOOP;
	TrackSnakeArray(NextMoveYPos)(NextMoveXPos) <= BiggestNumber; --the new field gets the biggest number		
----------------------------------------------------------------------------------------
-- Resets everything if ResetSig is set
	IF((ResetSig = '1') OR (Reset = '1'))THEN
		TrackSnakeArray <= (others=>(others=> 0));
-- Snake head and first Food gets set to this Position
		TrackSnakeArray(FoodPosY + (FoodPosX -1))(FoodPosX + (FoodPosY -1)) <= 1; --minus 1 so that they can never land on same spot?
		-- (5 and 3 are just random numbers so that food is away from snake) 
		TrackSnakeArray(FoodPosY)(FoodPosX) <= 255;
--Biggest Number back to 1
		BiggestNumber <= 1;
-- Disables the ResetSig
		ResetSig <= '0';	
	END IF;
END IF;
---------------
END IF;
END PROCESS;
	
------------------------------------------------------------------------------------------	
	
--To sync with the VGAsync module and count HPOS and VPOS the same way
SyncWithVGAsyc: PROCESS(VGAClk, SyncSig) -- new SyncSig
BEGIN
IF(RISING_EDGE(VGAClk)) THEN
----------------------------------------------------------------------------------------
	IF(SyncSig = '1')THEN
		HPOS <= 0;
		VPOS <= 0;
	ELSIF(HPOS<1688)THEN -- new elsif
		HPOS<=HPOS+1;
	ELSE
		HPOS<=0;
		IF(VPOS<1066)THEN
			VPOS<=VPOS+1;
		ELSE
			VPOS<=0;
		END IF;
	END IF;
END IF;
END PROCESS; 

-- Decides if the Draw Signal should be high for the VGAsync module
CreateDrawPixel: PROCESS(VGAClk)
BEGIN
IF(RISING_EDGE(VGAClk)) THEN
---------------------------------------------------------------------------------------
-- horizontal:  | 408 sync pixels | 128 dead px | 16 edge | 16 x 62 grid px | 16 edge | 128 dead px == 1680 pixel
-- 					1-408            409-536		537-552		553-615 ...
-- vertical:	 | 42 sync pixels  | 16 edge | 16 x 62 grid px | 16 edge | == 1066 pixel
--						1-42					43-58		59-74 ...
DrawPixel 	<= '0';
Drawfood 	<= '0';
DrawHead 	<= '0';
	FOR y in 0 to 15 LOOP 
		FOR x IN 0 to 15 LOOP 
			IF( HPOS>(552+(62*x)) AND HPOS<=(552+62+(62*x)) AND VPOS>(58+62*y) AND VPOS<=(58+62+62*y))THEN
				IF(TrackSnakeArray(y)(x) = BiggestNumber)THEN -- j is the y Position and i is the x position of the square
					DrawHead <= '1';
				ELSIF(TrackSnakeArray(y)(x) = 255)THEN -- j is the y Position and i is the x position of the square
					Drawfood <= '1';
				ELSIF(TrackSnakeArray(y)(x) > 0)THEN -- j is the y Position and i is the x position of the square
					DrawPixel <= '1';
				END IF;
			END IF;
		END LOOP;
	END LOOP;
END IF;
END PROCESS;


END MainGame;