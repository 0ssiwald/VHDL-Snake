library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY VGAcontroller IS
	PORT(
--Buttons for Game 
		ButtonIn: 				IN STD_LOGIC_VECTOR (3 DOWNTO 0);  --1000=down 0100=right 0010=left 0001=up
--Reset Game
		Reset: 					IN STD_LOGIC;
--those are additional outputs that the DAC ADV7123 (who creates the analog RGB signals) need
		VGA_SYNC:				OUT STD_LOGIC;
		VGA_BLANK:				OUT STD_LOGIC;
		VGA_CLK_OUT:			OUT STD_LOGIC; 
--MainClock des Boards mit 50 MHz
		CLOCK_50:				IN STD_LOGIC;  
--Synchronization Signals 
		VGA_HS,VGA_VS:			OUT STD_LOGIC;
--RGB Coulor Canels 
		VGA_R,VGA_G,VGA_B: 	OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);

END VGAcontroller;

ARCHITECTURE MAIN OF VGAcontroller IS 
---------------------------------------------------------
COMPONENT LFSR IS
  PORT (
    i_Clk    	 : IN std_logic;
    o_LFSR_Data : OUT std_logic_vector(7 DOWNTO 0)
    );
END COMPONENT LFSR;
----------------------------------------------------------
--Processes the Input
COMPONENT Joypad IS 

	PORT(
		Clk_50:				IN STD_LOGIC;
		ButtonIn: 			IN STD_LOGIC_VECTOR (3 DOWNTO 0); --1000=down 0100=right 0010=left 0001=up
		MovementstateX:	OUT INTEGER RANGE -1 TO 1;
		MovementstateY:	OUT INTEGER RANGE -1 TO 1
	);
END COMPONENT Joypad;
-------------------------------------------------------
--with PLL generated Clock
COMPONENT PLL IS
			PORT(
				inclk0		: IN STD_LOGIC	 := '0';
				c0				: OUT STD_LOGIC 
			);
	END COMPONENT PLL;
-------------------------------------------------------	
--include SYNC Component from VGAsync file 
COMPONENT SYNC IS 
	PORT(
		VGACLK:			IN STD_LOGIC;
		HSYNC,VSYNC: 	OUT STD_LOGIC;
		R,G,B	:			OUT STD_LOGIC_VECTOR(7 downto 0);
		SyncSig: 		OUT STD_LOGIC;
		DrawPixel: 		IN STD_LOGIC;
		DrawHead:		IN STD_LOGIC;
		DrawFood:		IN STD_LOGIC
	);
END COMPONENT SYNC;
------------------------------------------------------
COMPONENT GameLogic IS
	PORT(
		Clk_50:				IN STD_LOGIC;
		VGAClk:				IN STD_LOGIC;
		Reset: 				IN STD_LOGIC;
		SyncSig: 			IN STD_LOGIC;
		DrawPixel: 			OUT STD_LOGIC;
		DrawHead: 			OUT STD_LOGIC;
		DrawFood: 			OUT STD_LOGIC;
		in_LFSR_Data : 	IN std_logic_vector(7 downto 0);
		MovementstateX:	IN INTEGER RANGE -1 TO 1;
		MovementstateY:	IN INTEGER RANGE -1 TO 1
	);
END  COMPONENT GameLogic;
-----------------------------------------------------
--Testsignals to connect the Componens with port maps
--SIGNAL Game: ArraysInYPosition;
SIGNAL VGACLKSig: 			STD_LOGIC;
SIGNAL SyncSig: 				STD_LOGIC;
SIGNAL DrawPixelSig: 		STD_LOGIC;
SIGNAL DrawHeadSig: 			STD_LOGIC;
SIGNAL DrawFoodSig:			STD_LOGIC;
SIGNAL MovementstateXSig:	INTEGER RANGE -1 TO 1;
SIGNAL MovementstateYSig:	INTEGER RANGE -1 TO 1;
SIGNAL LFSR_DataSig:			STD_LOGIC_VECTOR(7 downto 0);

BEGIN
--these outputs to the VGA DAC ADV7123 just need to be in this state 
--according to post https://stackoverflow.com/questions/62039827/trying-to-display-on-640x480-vga-display-with-fpga
VGA_SYNC	 	<= '0';
VGA_BLANK 	<= '1';
VGA_CLK_OUT <= VGACLKSig;


----------------------------------------------------
RNG_Inst: LFSR PORT MAP(
    i_Clk    		=> CLOCK_50,
    o_LFSR_Data 	=> LFSR_DataSig
    );
---------------------------------------------------
--Include the Sync component
Sync_inst: SYNC PORT MAP(
			VGACLK => VGACLKSig,
			HSYNC => VGA_HS,
			VSYNC => VGA_VS,
			R => VGA_R,
			G => VGA_G,
			B => VGA_B,
			SyncSig => SyncSig,
			DrawPixel => DrawPixelSig,
			DrawFood => DrawFoodSig,
			DrawHead => DrawHeadSig
			);
----------------------------------------------------
--Include the GameLogic componet
GameLogic_inst: GameLogic PORT MAP(
			Clk_50				=> CLOCK_50,
			VGACLK 				=> VGACLKSig,
			Reset					=> Reset,
			SyncSig 				=> SyncSig,
			DrawPixel			=> DrawPixelSig,
			DrawFood 			=> DrawFoodSig,
			DrawHead 			=> DrawHeadSig,
			in_LFSR_Data 		=> LFSR_DataSig,
			MovementstateX		=> MovementstateXSig,
			MovementstateY		=> MovementstateYSig
			);
----------------------------------------------------
--Include the PLL component
PLL_inst : PLL PORT MAP (
			inclk0		=> CLOCK_50,
			c0	 			=> VGACLKSig
	);
---------------------------------------------------
--Include the Joypad component
Joypad_inst: Joypad PORT MAP(
			Clk_50				=> CLOCK_50,
			ButtonIn 			=> ButtonIn,
			MovementstateX		=> MovementstateXSig,
			MovementstateY		=> MovementstateYSig
	);
					
-----------------------------------------------------			
END MAIN;
