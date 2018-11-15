--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------
--add in the package with addition
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY hw_image_generator IS
	GENERIC(
		pixels_y :	INTEGER := 1700; --100 	--bigger the y, wider the row
		pixels_x	:	INTEGER := 1200;--400	--bigger the x, longer the column
		location_x : INTEGER := 450;
		location_y : INTEGER := 710);
		
	PORT(
		disp_ena		:	IN		STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row			:	IN		INTEGER;		--row pixel coordinate
		column		:	IN		INTEGER;		--column pixel coordinate
		red			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --blue magnitude output to DAC
		ps2_code		: 	IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		ps2_code_new:	IN 	STD_LOGIC;
		clk :  IN  STD_LOGIC);
		
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

	SIGNAL xloc : INTEGER RANGE 0 TO (pixels_y) := 450;
	signal counter : std_logic_vector(24 downto 0);  -- signal that does the counting
   signal CLK_1HZ : std_logic;


		
BEGIN
	PROCESS(disp_ena, row, column)
	BEGIN
		
		IF(disp_ena = '1') THEN		--display time
			
			IF(row < pixels_y  AND column < pixels_x and row > 200) THEN 
			
				IF( row > xloc and row < xloc+240 and column > location_y and column < location_y+240) THEN				--user object
					red <= (OTHERS => '1');--(OTHERS => '0')
					green	<= (OTHERS => '1');
					blue <= (OTHERS => '1');
				ELSIF ( row > 940 and row < 980 and column > 50 and column < 350)	THEN			--yellow line one
					red <= "11111111";
					green	<= "11111111";
					blue <= "01100110";
				ELSIF ( row > 940 and row < 980 and column > 700 and column < 1000)	THEN		--yellow line two
					red <= "11111111";
					green	<= "11111111";
					blue <= "01100110";
				ELSE																									--rest of road
					red <= "11000000";
					green	<= "11000000";
					blue <= "11000000";
				end IF;
				
			ELSE																										--grass
				red <= (OTHERS => '0');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '0');
			END IF;
		ELSE								--blanking time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		END IF;
	
	END PROCESS;
	
	Prescaler: process (clk)
   begin  -- process Prescaler

      if clk'event and clk = '1' then  -- rising clock edge
         if counter < "1011111010111100001000000" then   -- Binary value is
                                                         -- 25e6
            counter <= counter + 1;
         else
            CLK_1Hz <= not CLK_1Hz;
            counter <= (others => '0');
         end if;
      end if;
   end process Prescaler;

	
	PROCESS(ps2_code_new, ps2_code)
	BEGIN	
--		IF(CLK_1HZ'EVENT AND CLK_1HZ = '1') THEN
		IF(ps2_code_new'EVENT AND ps2_code_new = '1') THEN
			IF(ps2_code = "00110100") THEN													--g key moves left
				IF(xloc <= 200) THEN
					xloc <= 200;
				ELSE
					xloc <= xloc - 20;
				END IF;
			ELSIF(ps2_code = "00110011") THEN												--H key moves right
				IF(xloc >= pixels_y-240) THEN
					xloc <= pixels_y-240;
				ELSE
					xloc <= xloc + 20;
				END IF;
			ELSE
				xloc <= xloc;
			END IF;
		END IF;
	END PROCESS;
END behavior;