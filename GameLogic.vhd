library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- for the array data type 
use work.ArraysInYPosition_type.all;


ENTITY GameLogic IS
	PORT(
		VGAClk:				IN STD_LOGIC;
		Clk_50:				IN STD_LOGIC;
		Reset: 				IN STD_LOGIC;
		SyncSig: 			IN STD_LOGIC;
		DrawPixel: 			OUT STD_LOGIC;
		in_LFSR_Data : 	IN std_logic_vector(7 downto 0);
		MovementstateX: 	IN INTEGER RANGE -1 TO 1;
		MovementstateY: 	IN INTEGER RANGE -1 TO 1
	);
END GameLogic;

ARCHITECTURE MainGame OF GameLogic IS

--Needs to be 0 at standard because it means Reset is disabled
	SIGNAL ResetSig: STD_LOGIC := '0';
--Signal for ClockDivider
	SIGNAL GameClock : 	std_logic := '0';	
--Signals to keep track of HPOS and VPOS for VGAsync module	
	SIGNAL HPOS: INTEGER RANGE 0 TO 1688:=0;
	SIGNAL VPOS: INTEGER RANGE 0 TO 1066:=0; 
--To track Snake body with Numbers	
	SIGNAL TrackSnakeArray: ArrayOfIntArray := (others=>(others=> 0));	
-- BiggestNumber is the Head Pos of the Snake
	SIGNAL BiggestNumber: INTEGER RANGE 0 TO 255 := 1;
	SIGNAL BiggestNumberFuture: INTEGER RANGE 0 TO 255 := 1;
-- This tracks the Head Pos
	SIGNAL BiggestNumberXPos: INTEGER RANGE 0 TO 15;
	SIGNAL BiggestNumberYPos: INTEGER RANGE 0 TO 15;
--This is the XY Pos of the next Field
	SIGNAL NextMoveXPos: INTEGER RANGE 0 TO 15;
	SIGNAL NextMoveYPos: INTEGER RANGE 0 TO 15;
--Next Task: -1 = Eat, 0 = Walk, 1 = Reset 	
	SIGNAL NextTask:		INTEGER RANGE -1 TO 1 := 0;
-- to block updating NextPosMove if TrackSnakeArray(NextMoveYPos)(NextMoveXPos) = (BiggestNumber - 1)
	SIGNAL BlockNextMove: STD_LOGIC := '0'; 
--Signals from Random Number generation
	SIGNAL RandomNumber:	INTEGER RANGE 0 TO 255;
	SIGNAL FoodPosX:		INTEGER RANGE 0 TO 15;
	SIGNAL FoodPosY:	 	INTEGER RANGE 0 TO 15;
	
BEGIN	
--------------------------------------------------------------------------------------	
--ClockDivider based on https://electronics.stackexchange.com/questions/72990/fpga-clock-strategy
PROCESS(Clk_50)
VARIABLE Count: INTEGER RANGE 0 TO 20000000; --change here for faster/slower snake 
BEGIN
    IF(RISING_EDGE(Clk_50)) THEN
        IF(Count = Count'HIGH) THEN
            GameClock <= '1';
            Count := 0;
        ELSE
            GameClock <= '0';
            Count := Count + 1;
        END IF;
    END IF;
END PROCESS;

--------------------------------------------------------------------------------------

PROCESS(Clk_50)
BEGIN	
IF(RISING_EDGE(Clk_50)) THEN
--------------------------------------------------------------------------------------

	RandomNumber <= (to_integer(unsigned(in_LFSR_Data))- BiggestNumber);

--Searches for the biggest Number !=255 in the Array
	FOR y IN 0 TO 15 LOOP
		FOR x IN 0 TO 15 LOOP
			IF(Reset = '0')THEN
				IF(TrackSnakeArray(y)(x) = 0)THEN
					IF((RandomNumber - (x+(16*y))) > 0)THEN
						FoodPosX <= x;
						FoodPosY <= y;
					END IF;
				END IF;
			END IF;
			IF(((TrackSnakeArray(y)(x) > BiggestNumber) OR (TrackSnakeArray(y)(x) = BiggestNumber))  AND (TrackSnakeArray(y)(x) < 255) AND (TrackSnakeArray(y)(x) > 0))THEN
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
		NextTask <= -1;
-- When the Number is 0	
	ELSIF(TrackSnakeArray(NextMoveYPos)(NextMoveXPos) = 0)THEN
		NextTask <= 0;
--When the Number is > 0 and < 255 -> the Snake bit itself
	ELSIF((TrackSnakeArray(NextMoveYPos)(NextMoveXPos) > 0) AND (TrackSnakeArray(NextMoveYPos)(NextMoveXPos) < 255))THEN
		IF(TrackSnakeArray(NextMoveYPos)(NextMoveXPos) = (BiggestNumber - 1))THEN -- is to avoid moving the snake into itself 
			NextTask <= 0;
			NextMoveXPos <= (BiggestNumberXPos + ((-1) * MovementstateX));
			NextMoveYPos <= (BiggestNumberYPos + ((-1) * MovementstateY));
			BlockNextMove <= '1';
		ELSE
			NextTask <= 1;
		END IF;
	END IF;
------------------------	
IF(GameClock = '1') THEN
------------------------------------------------------------------------------------------
	BlockNextMove <= '0';
-- Decides what to to depending on NextTask
-- When the Number is 255 = Food
	IF(NextTask = -1)THEN
		TrackSnakeArray(NextMoveYPos)(NextMoveXPos) <= (BiggestNumber + 1);
		BiggestNumber <= BiggestNumber + 1;	
		TrackSnakeArray(FoodPosX)(FoodPosY) <= 255;	
-- When the Number is 0	
	ELSIF(NextTask = 0)THEN
		FOR y IN 0 TO 15 LOOP
			FOR x IN 0 TO 15 LOOP
				IF((TrackSnakeArray(y)(x) > 0) AND (TrackSnakeArray(y)(x) < 255))THEN
					TrackSnakeArray(y)(x) <= (TrackSnakeArray(y)(x) - 1);
				END IF;
			END LOOP;
		END LOOP;
	TrackSnakeArray(NextMoveYPos)(NextMoveXPos) <= BiggestNumber; --the new field gets the biggest number
--When the Number is > 0 and < 255 -> the Snake bit itself
	ELSIF(NextTask = 1)THEN
		ResetSig <= '1';
	END IF;	

----------------------------------------------------------------------------------------
-- Resets everything if ResetSig is set
		IF((ResetSig = '1') OR (Reset = '1'))THEN
		--	HoldPos <= '1';
			TrackSnakeArray <= (others=>(others=> 0));
-- Snake head and first Food gets set to this Position
				TrackSnakeArray(FoodPosX + 5)(FoodPosY + 3) <= 1;
				TrackSnakeArray(FoodPosX)(FoodPosY) <= 255;
--Biggest Number back to 1
			BiggestNumber <= 1;
-- Disables the ResetSig
			ResetSig <= '0';			
		END IF;
------------------------------------------------------------------------------------------		
END IF;	
END IF;
END PROCESS;
	
------------------------------------------------------------------------------------------	
	
--To sync with the VGAsync module and count HPOS and VPOS the same way
PROCESS(VGAClk)
VARIABLE Hold: STD_LOGIC := '0'; -- To Disable setting the DrawPixel to 0 if the first if statement in the loop was sucsessful
BEGIN
IF(VGAClk'EVENT and VGAClk='1') THEN
----------------------------------------------------------------------------------------
	IF(SyncSig = '1')THEN
		HPOS <= 0;
		VPOS <= 0;
	END IF;
	---------------
	IF(HPOS<1688)THEN
		HPOS<=HPOS+1;
	ELSE
		HPOS<=0;
		IF(VPOS<1066)THEN
			VPOS<=VPOS+1;
		ELSE
			VPOS<=0;
		END IF;
	END IF;
---------------------------------------------------------------------------------------
-- horizontal:  | 408 sync pixels | 128 dead px | 16 edge | 16 x 62 grid px | 16 edge | 128 dead px == 1680 pixel
-- 					1-408            409-536		537-552		553-615 ...
-- vertical:	 | 42 sync pixels  | 16 edge | 16 x 62 grid px | 16 edge | == 1066 pixel
--						1-42					43-58		59-74 ...

-- Decides if the Draw Signal should be high for the VGAsync module
	IF(HPOS > 552 AND HPOS < 1544 AND VPOS > 62 AND VPOS < 1050) THEN --necessary to disable Draw Pixel when HPOS is not on the field
		FOR y in 0 to 15 LOOP 
			FOR x IN 0 to 15 LOOP 
				IF(HPOS>(552+(62*x)) AND HPOS<(552+62+(62*x)) AND VPOS>(58+62*y) AND VPOS<(58+62+62*y) AND TrackSnakeArray(y)(x) > 0)THEN -- j is the y Position and i is the x position of the square
					DrawPixel <= '1';
					Hold 		 := '1';
				END IF;
				IF(Hold = '0')THEN
					DrawPixel <= '0';
				END IF;
			END LOOP;
		END LOOP;
	ELSE
		DrawPixel <= '0';
	END IF;
	Hold :='0';
END IF;
END PROCESS;




END MainGame;