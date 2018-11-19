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
		location_y : INTEGER := 710
		
		);
		
	PORT(
		disp_ena		:	IN		STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row			:	IN		INTEGER;		--row pixel coordinate
		column		:	IN		INTEGER;		--column pixel coordinate
		red			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  	--red magnitude output to DAC
		green			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  	--green magnitude output to DAC
		blue			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');	--blue magnitude output to DAC
		ps2_code		: 	IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		ps2_code_new:	IN 	STD_LOGIC;
		clk :  IN  STD_LOGIC);
		
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

	SIGNAL xloc : INTEGER RANGE 0 TO (pixels_y) := 450;
	signal counter : INTEGER := 0;  					-- signal that does the clock counting //std_logic_vector--(24 downto 0);
	signal timer : std_logic_vector(24 downto 0);
   signal CLK_1HZ : std_logic;
	signal e1 : std_logic := '1';
	signal e2 : std_logic := '1';
	signal obj_x1 : INTEGER := 400;
	signal obj_y1 : INTEGER := 0;
	signal obj_x2 : INTEGER := 800;
	signal obj_y2 : INTEGER := 0;

		
BEGIN
	PROCESS(disp_ena, row, column)
	BEGIN
		
		IF(disp_ena = '1') THEN		--display time
			
			IF(row < pixels_y  AND column < pixels_x and row > 200) THEN 
			
				IF( row > xloc and row < xloc+240 and column > location_y and column < location_y+240) THEN				--user object
					red <= (OTHERS => '1');--(OTHERS => '0')
					green	<= (OTHERS => '1');
					blue <= (OTHERS => '1');
				ElSIF( row > obj_x1+200 and row < obj_x1+440 and column > obj_y1 and column < obj_y1+240 and e1 ='1') THEN				--object 1
					red <= (OTHERS => '1');
					green	<= (OTHERS => '0');
					blue <= (OTHERS => '1');
				ElSIF( row > obj_x2+200 and row < obj_x2+440 and column > obj_y2 and column < obj_y2+240 and e2 ='1') THEN				--object 2
					red <= (OTHERS => '1');
					green	<= (OTHERS => '0');
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

      if clk'event and clk = '1' then  													
         if counter < 1280 then  								
																										
            counter <= counter + 1;
         else 
            counter <= 0;
         end if;
			
			if timer < "000010111110101111000010" then			-- rising clock edge    "101111101011110000100000"
				timer <= timer + 1;										-- Binary value is 25e6/16   (16 cycle per second)
			else
				timer <= (OTHERS => '0');
				CLK_1Hz <= not CLK_1Hz;
				
			end if;
		end if;
   end process Prescaler;
	
	
	PROCESS(CLK_1Hz)
	begin
	
		if CLK_1Hz'event and CLK_1Hz = '1' then 
			if e1 = '0' then																			--give values for object 1
				obj_x1 <= counter;
				if ((obj_x2 < obj_x1 and obj_x2+240 > obj_x1)) then				--e2 = '1' and 
					if(obj_x1 > 1040) then
						obj_x1 <= obj_x1 - 240;
					else
						obj_x1 <= obj_x1	 + 240;
					end if;
				end if;
					
				obj_y1 <= 0;
				e1 <= '1';
				
			end if;
		
			if  e2 = '0' then																			--give values for object 2
				obj_x2 <= counter;
				if ((obj_x1 < obj_x2 and obj_x1+240 > obj_x2)) then						--e1 = '1' and 
					if(obj_x2 > 1040) then
						obj_x2 <= obj_x2 - 240;
					else
						obj_x2 <= obj_x2	 + 240;
					end if;
				end if;
					
				obj_y2 <= 0;
				e2 <= '1';
			end if;
			
			if(e1 = '1' and obj_y1 >= 1080) then
				e1 <= '0';
				obj_y1 <= 0;
			elsif(e2 = '1' and obj_y2 >= 1080) then
				e2 <= '0';
				obj_y2 <= 0;
			else
				obj_y1 <= obj_y1 + 4;
				obj_y2 <= obj_y2 + 3;
			end if;
		end if;
		
	end process;
	


	
	
	
	PROCESS(ps2_code_new, ps2_code)															--This process moves the user block
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