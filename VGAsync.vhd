library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- VGA Controller for 1280 x 1024 pixel @60 Hz with 108 MHz Pixelclock
-- based on https://www.youtube.com/watch?v=WK5FT5RD1sU

--Horizontal Line has 1280 visible pixels, 48 front porch, 112 sync pulse, 248 back porch  =  1688 pixel
--Vertical Line has 1024 visible pixels, 1 front porch, 3 sync pulse, 38 back portch  = 1066 pixel
ENTITY SYNC IS 
PORT(
	VGACLK: 				IN STD_LOGIC;
	HSYNC, VSYNC: 		OUT STD_LOGIC;
	R: 					OUT STD_LOGIC_VECTOR(7 downto 0);
	G: 					OUT STD_LOGIC_VECTOR(7 downto 0);
	B: 					OUT STD_LOGIC_VECTOR(7 downto 0);
	SyncSig: 			OUT STD_LOGIC;
	DrawPixel: 			IN STD_LOGIC;
	Drawfood:			IN STD_LOGIC;
	DrawHead:			IN STD_LOGIC
	);
END SYNC;
 
ARCHITECTURE MAIN OF SYNC IS
--Current Position on Screen (HPOS and VPOS)
	SIGNAL HPOS: INTEGER RANGE 0 TO 1688 := 0;
	SIGNAL VPOS: INTEGER RANGE 0 TO 1066 := 0;
BEGIN

VGASignals: PROCESS(VGACLK)
BEGIN
 
	IF(VGACLK'EVENT AND VGACLK='1')THEN   ---nochmal verstehen
---------------------------------------------------------------------------------------------------------------------------------------		
--With Clock Cycle HPOS gets increased by 1 till End of Line then reset to 0 and VPOS is increassed by 1
		IF(HPOS<1688)THEN
			HPOS<=HPOS+1;
			SyncSig <= '0'; 
		ELSE
			HPOS<=0;
			IF(VPOS<1066)THEN
				VPOS<=VPOS+1;
			ELSE
				VPOS<=0;
				SyncSig <= '1';
			END IF;
		END IF;
-------------------------------------------------------------------------------------------------------------------------------------------
--Sycronization programmed 
--horizontals sync must be low between front porch and back porch otherwise its high
		IF(HPOS>48 AND HPOS<=(48+112))THEN
			HSYNC<='0';
		ELSE
			HSYNC<='1';
		END IF;
--Same for verticals sync 
		IF(VPOS>1 AND VPOS<=(1+3))THEN 
			VSYNC<='0';
		ELSE
			VSYNC<='1';
		END IF;
------------------------------------------------------------------------------------------------------------------------------------------
	IF(DrawPixel ='1')THEN
		R <= (others=>'1');
		G <= (others=>'1');
		B <= (others=>'1');
	ELSIF(DrawHead ='1')THEN
		R <= "01000000";
		G <= "01000000";
		B <= "01000000";
	ELSIF(DrawFood ='1')THEN
		R <= (others=>'1');
		G <= (others=>'0');
		B <= (others=>'0');
	ELSE
		R <= (others=>'0');
		G <= (others=>'0');
		B <= (others=>'0');
	END IF;
-------------------------------------------------------------------------------------------------------------------------------------				
-- to display the bounderies of the playing fied
		IF(HPOS>(408+128) AND HPOS<(1688-128) AND ((VPOS>42 AND VPOS<=(42+16)) OR (VPOS>(1066-16) AND VPOS<=1066)))THEN
			R <= (others=>'0');
			G <= (others=>'1');
			B <= (others=>'0');
		END IF;
		IF((HPOS>(408+128) AND HPOS<=(408+128+16)) OR (HPOS>(1688-128-16) AND HPOS<=(1688-128)))THEN
			R <= (others=>'0');
			G <= (others=>'1');
			B <= (others=>'0');
		END IF;

---------------------------------------------------------------------------------------------------------------------------------------

--From Front Porch to End of Back Porch RGB should be low 
		IF((HPOS>0 AND HPOS<408) OR (VPOS>0 AND VPOS<42))THEN
			R<=(others=>'0');
			G<=(others=>'0');
			B<=(others=>'0');
		END IF;
--------------------------------------------------------------------------------------------------------------------------------------------
	END IF;
END PROCESS;
END MAIN;
	