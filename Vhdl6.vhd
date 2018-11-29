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
		pixels_y :	INTEGER := 1700; 	--bigger the y, wider the row
		pixels_x	:	INTEGER := 1200	--bigger the x, longer the column
		--location_x : INTEGER := 450;
		--location_y : INTEGER := 710
		
		);
		
	PORT(
		testLED 		:  OUT 	STD_LOGIC;
		score1 		:  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000001";
		score2 		:  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000001";
		score3 		:  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000001";
		score4 		:  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000001";
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
	SIGNAL yloc : INTEGER RANGE 0 TO (pixels_x) := 710;
	signal counter : INTEGER := 200;  					-- signal that does the clock counting //std_logic_vector--(24 downto 0);
	signal timer : std_logic_vector(24 downto 0);
   signal CLK_1HZ : std_logic;
	signal e1 : std_logic := '1';
	signal e2 : std_logic := '1';
	signal obj_x1 : INTEGER := 400;
	signal obj_y1 : INTEGER := 0;
	signal obj_x2 : INTEGER := 800;
	signal obj_y2 : INTEGER := 1;
	signal collide : std_logic := '1';
	signal scoreCount : std_logic_vector(2 downto 0) := "000";
	signal s1 : std_logic_vector(6 downto 0) := "0000001";
	signal s2 : std_logic_vector(6 downto 0) := "0000001";
	signal s3 : std_logic_vector(6 downto 0) := "0000001";
	signal s4 : std_logic_vector(6 downto 0) := "0000001";
	signal start	: std_logic := '1';
	signal prevStart : std_logic := '1';
	signal reset	: std_logic := '0';
	signal lineloc1 : INTEGER RANGE -300 TO (pixels_y) := 50;
	signal lineloc2 : INTEGER RANGE -300 TO (pixels_y) := 700;
	signal difficulty : INTEGER RANGE 0 TO 10 := 0;
		
BEGIN
	PROCESS(disp_ena, row, column)
	BEGIN
--	  IF reset = '1' then
--			xloc <= 450;
--			yloc <= 710;
--			
--	  end if;
		
		IF(disp_ena = '1') THEN		--display time
			
			IF(row < pixels_y  AND column < pixels_x and row > 200) THEN 
			
				IF( row > xloc and row < xloc+240 and column > yloc and column < yloc+240) THEN				--user object
					if( row > xloc + 30 and row < xloc+210 and column > yloc + 40 and column < yloc+90 ) then
						red <= (OTHERS => '0');
						green	<= (OTHERS => '1');
						blue <= (OTHERS => '1');
					elsif(( row < xloc + 20 or row > xloc+220) and column > yloc + 10 and column < yloc+50 ) then
						red <= (OTHERS => '0');
						green	<= (OTHERS => '0');
						blue <= (OTHERS => '0');
					elsif(( row < xloc + 20 or row > xloc+220) and column > yloc + 190 and column < yloc+230 ) then
						red <= (OTHERS => '0');
						green	<= (OTHERS => '0');
						blue <= (OTHERS => '0');
					else
						red <= (OTHERS => '1');
						green	<= (OTHERS => '0');
						blue <= (OTHERS => '0');
					end if;
				ElSIF( row > obj_x1 and row < obj_x1+240 and column > obj_y1 and column < obj_y1+240 and e1 ='1') THEN--obj_x1+200				--object 1
					if( row > obj_x1 + 30 and row < obj_x1+210 and column > obj_y1 + 40 and column < obj_y1+90 ) then
						red <= (OTHERS => '0');
						green	<= (OTHERS => '1');
						blue <= (OTHERS => '1');
					elsif(( row < obj_x1 + 20 or row > obj_x1+220) and column > obj_y1 + 10 and column < obj_y1+50 ) then
						red <= (OTHERS => '0');
						green	<= (OTHERS => '0');
						blue <= (OTHERS => '0');
					elsif(( row < obj_x1 + 20 or row > obj_x1+220) and column > obj_y1 + 190 and column < obj_y1+230 ) then
						red <= (OTHERS => '0');
						green	<= (OTHERS => '0');
						blue <= (OTHERS => '0');
					else
						red <= (OTHERS => '1');
						green	<= (OTHERS => '0');
						blue <= (OTHERS => '1');
					end if;
				ElSIF( row > obj_x2 and row < obj_x2+240 and column > obj_y2 and column < obj_y2+240 and e2 ='1') THEN--obj_x2+200 and obj_x2+440	--object 2
					if( row > obj_x2 + 30 and row < obj_x2+210 and column > obj_y2 + 40 and column < obj_y2+90 ) then
						red <= (OTHERS => '0');
						green	<= (OTHERS => '1');
						blue <= (OTHERS => '1');
					elsif(( row < obj_x2 + 20 or row > obj_x2+220) and column > obj_y2 + 10 and column < obj_y2+50 ) then
						red <= (OTHERS => '0');
						green	<= (OTHERS => '0');
						blue <= (OTHERS => '0');
					elsif(( row < obj_x2 + 20 or row > obj_x2+220) and column > obj_y2 + 190 and column < obj_y2+230 ) then
						red <= (OTHERS => '0');
						green	<= (OTHERS => '0');
						blue <= (OTHERS => '0');
					else
						red <= (OTHERS => '1');
						green	<= (OTHERS => '0');
						blue <= (OTHERS => '1');
					end if;
				ELSIF ( row > 940 and row < 980 and column > lineloc1 and column < lineloc1 + 300)	THEN			--yellow line one
					red <= "11111111";
					green	<= "11111111";
					blue <= "01100110";
				ELSIF ( row > 940 and row < 980 and column > lineloc2 and column < lineloc2 + 300)	THEN		--yellow line two
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
		ELSE															--blanking time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		END IF;
	
	END PROCESS;
	
	--Process involves clock values
	Prescaler: process (clk)
   begin 
	  

      if clk'event and clk = '1' then
			IF reset = '1' then
			counter <= 200;
			timer <= (OTHERS => '0');
		end if;
		
         if counter < 1460 then  								--the counter randomly assigns a possition to the falling objects	 						
																										
            counter <= counter + 1;
         else 
            counter <= 200;  
         end if;
																			--timer will give pace for our CLK_1Hz variable
			if timer < "000010111110101111000010" then		-- rising clock edge    "101111101011110000100000"
				timer <= timer + 1;									-- Binary value is 25e6/16   (16 cycle per second)
			else																
				timer <= (OTHERS => '0');
				CLK_1Hz <= not CLK_1Hz;
			end if;
						
		end if;
		
			
   end process Prescaler;
	
	--testLED <= '1';
	--Process moves everything
	PROCESS(CLK_1Hz)
	begin
	  
		
		if CLK_1Hz'event and CLK_1Hz = '1' then
		
		if reset = '1' then
		 collide <= '1';
		 obj_x1 <= 400;
		 obj_y1 <= 0;
		 obj_x2 <= 800;
		 obj_y2 <= 1;
		 e1	<= '1';
		 e2	<= '1';
		 s1 <= "0000001";
		 s2 <= "0000001";
		 s3 <= "0000001";
		 s4 <= "0000001";
		 score1 <= "0000001";
		 score2 <= "0000001";
		 score3 <= "0000001";
		 score4 <= "0000001";
		 scoreCount <= "000";
		 prevStart <= '1';
	  end if;
			
			if prevStart = '1' and start = '0' then
					collide <= start;
			end if;

	
		 if collide = '0' then 	--we could put all of this in the process above to avoid jumping at the top of the screen
			prevStart <= '0';
			--give values for object 1
			if e1 = '0' then																			
				obj_x1 <= counter;
				obj_y1 <= 0;
				e1 <= '1';
			END IF;
			
			--give values for object 2
			if  e2 = '0' then																			
				obj_x2 <= counter;
				obj_y2 <= 1;
				e2 <= '1';
			END IF;
			
			--checks for overlap of falling objects
			if (obj_x1 < obj_x2 and obj_x1 + 240 > obj_x2) then
			
				if (obj_y2 < obj_y1) then
					if(obj_x1 < 960) then
						obj_x2 <= obj_x2 + 245;
					else
						obj_x2 <= obj_x2 - 490;
					end if;
				else
					if (obj_x1 < 960) then
						obj_x1 <= obj_x1 + 490;
					else
						obj_x1 <= obj_x1 - 245;
					end if;
				end if;
				
			elsif (obj_x1 > obj_x2  and obj_x1 < obj_x2 + 240 ) then
			
				if( obj_y2 < obj_y1) then
					if(obj_x2 < 960) then
						obj_x2 <= obj_x2 + 490;
					else
						obj_x2 <= obj_x2 - 245;
					end if;
				else
					if(obj_x2 < 960) then
						obj_x1 <= obj_x1 + 245;
					else
						obj_x1 <= obj_x1 - 490;
					end if;
				end if;
				
			elsif(obj_x1 = obj_x2) then
			
				if( obj_y2 < obj_y1) then
					if(obj_x2 < 960) then
						obj_x2 <= obj_x2 + 250;
					else
						obj_x2 <= obj_x2 - 300;
					end if;
				else
					if(obj_x2 < 960) then
						obj_x1 <= obj_x1 + 250;
					else
						obj_x1 <= obj_x1 - 300;
					end if;
				end if;
			end if;	
			
			--controls objects moving down the screen
			if(e1 = '1' and obj_y1 >= 1080) then		--object one is off screen
				e1 <= '0';
				obj_y1 <= 0;
				testLED <= '0';
			elsif(e2 = '1' and obj_y2 >= 1080) then	--object two is off screen
				e2 <= '0';
				obj_y2 <= 0;
			else													--speed of the objects
				obj_y1 <= obj_y1 + 6 + difficulty;--4   7						--moves object one down
				obj_y2 <= obj_y2 + 5 + difficulty;--3						--moves object two down
			end if;
			
			--moves yellow lines
			IF(lineloc1 > 1080) then
				lineloc1 <= -300;
			else
				lineloc1 <= lineloc1 + 10 + difficulty;
			end if;
			if(lineloc2 > 1080)then
				lineloc2 <= -300;
			else
				lineloc2 <= lineloc2 + 10 + difficulty;
			end if;
			
		
			--tests object 1 for collisions
			if(obj_x1 + 240 > xloc and obj_x1 < xloc and obj_y1 +240 > yloc and obj_y1 < yloc) then				
				collide <= '1';
			elsif(obj_x1 + 240 > xloc and obj_x1 < xloc and obj_y1 - 240 < yloc and obj_y1 > yloc) then
				collide <= '1';
			elsif(obj_x1 - 240 < xloc and obj_x1 > xloc and obj_y1 - 240 < yloc and obj_y1 > yloc) then
				collide <= '1';
			elsif(obj_x1 - 240 < xloc and obj_x1 > xloc and obj_y1 +240 > yloc and obj_y1 < yloc) then
				collide <= '1';
			end if;
			
			--tests object 2 for collisions
			if(obj_x2 + 240 > xloc and obj_x2 < xloc and obj_y2 +240 > yloc and obj_y2 < yloc) then				
				collide <= '1';
			elsif(obj_x2 + 240 > xloc and obj_x2 < xloc and obj_y2 - 240 < yloc and obj_y2 > yloc) then
				collide <= '1';
			elsif(obj_x2 - 240 < xloc and obj_x2 > xloc and obj_y2 - 240 < yloc and obj_y2 > yloc) then
				collide <= '1';
			elsif(obj_x2 - 240 < xloc and obj_x2 > xloc and obj_y2 +240 > yloc and obj_y2 < yloc) then
				collide <= '1';
			end if;
		
			scoreCount <= scoreCount + 1;
			if scoreCount = "111" then
				
				--setting thousands place
				if	s3 = "0001100" and s2 = "0001100" and s1 = "0001100" then	--if tens, ones, and hundreds place is 9
					--once the score hits 9999 it will reset to 9000
--					if s3 = "0001100" then
--						score3 <= "0000001";
--						s3 <= "0000001";
					if s4 = "0000001" then					--1000
						score4 <= "1001111";
						s4 <= "1001111";
					elsif s4 = "1001111" then					--2000
						score4 <= "0010010";
						s4 <= "0010010";
					elsif s4 = "0010010" then					--3000
						score4 <= "0000110";
						s4 <= "0000110";
					elsif s4 = "0000110" then					--4000
						score4 <= "1001100";
						s4 <= "1001100";
					elsif s4 = "1001100" then					--5000
						score4 <= "0100100";
						s4 <= "0100100";
					elsif s4 = "0100100" then					--6000
						score4 <= "0100000";
						s4 <= "0100000";
					elsif s4 = "0100000" then					--7000
						score4 <= "0001111";
						s4 <= "0001111";
					elsif s4 = "0001111" then					--8000
						score4 <= "0000000";
						s4 <= "0000000";
					elsif s4 = "0000000" then					--9000
						score4 <= "0001100";
						s4 <= "0001100";
					end if;
				end if;
				
				--setting hundreds place
				if	s2 = "0001100" and s1 = "0001100" then	--if tens and ones place is 9
					if s3 = "0001100" then						--000
						score3 <= "0000001";
						s3 <= "0000001";
					elsif s3 = "0000001" then					--100
						score3 <= "1001111";
						s3 <= "1001111";
					elsif s3 = "1001111" then					--200
						score3 <= "0010010";
						s3 <= "0010010";
					elsif s3 = "0010010" then					--300
						score3 <= "0000110";
						s3 <= "0000110";
					elsif s3 = "0000110" then					--400
						score3 <= "1001100";
						s3 <= "1001100";
					elsif s3 = "1001100" then					--500
						score3 <= "0100100";
						s3 <= "0100100";
					elsif s3 = "0100100" then					--600
						score3 <= "0100000";
						s3 <= "0100000";
					elsif s3 = "0100000" then					--700
						score3 <= "0001111";
						s3 <= "0001111";
					elsif s3 = "0001111" then					--800
						score3 <= "0000000";
						s3 <= "0000000";
					elsif s3 = "0000000" then					--900
						score3 <= "0001100";
						s3 <= "0001100";
					end if;
				end if;
				
				--setting tens place
				if	s1 = "0001100" then					--if ones place is 9
					difficulty <= difficulty + 1;
					if s2 = "0001100" then				--00
						score2 <= "0000001";
						s2 <= "0000001";
					elsif s2 = "0000001" then			--10
						score2 <= "1001111";
						s2 <= "1001111";
					elsif s2 = "1001111" then			--20
						score2 <= "0010010";
						s2 <= "0010010";
					elsif s2 = "0010010" then			--30
						score2 <= "0000110";
						s2 <= "0000110";
					elsif s2 = "0000110" then			--40
						score2 <= "1001100";
						s2 <= "1001100";
					elsif s2 = "1001100" then			--50
						score2 <= "0100100";
						s2 <= "0100100";
					elsif s2 = "0100100" then			--60
						score2 <= "0100000";
						s2 <= "0100000";
					elsif s2 = "0100000" then			--70
						score2 <= "0001111";
						s2 <= "0001111";
					elsif s2 = "0001111" then			--80
						score2 <= "0000000";
						s2 <= "0000000";
					elsif s2 = "0000000" then			--90
						score2 <= "0001100";
						s2 <= "0001100";
					end if;
				end if;
				
				--setting ones place
				if s1 = "0001100" then				--0
					score1 <= "0000001";
					s1 <= "0000001";
					--scoreCount <= "000";
				elsif s1 = "0000001" then			--1
					score1 <= "1001111";
					s1 <= "1001111";
				elsif s1 = "1001111" then			--2
					score1 <= "0010010";
					s1 <= "0010010";
				elsif s1 = "0010010" then			--3
					score1 <= "0000110";
					s1 <= "0000110";
				elsif s1 = "0000110" then			--4
					score1 <= "1001100";
					s1 <= "1001100";
				elsif s1 = "1001100" then			--5
					score1 <= "0100100";
					s1 <= "0100100";
				elsif s1 = "0100100" then			--6
					score1 <= "0100000";
					s1 <= "0100000";
				elsif s1 = "0100000" then			--7
					score1 <= "0001111";
					s1 <= "0001111";
				elsif s1 = "0001111" then			--8
					score1 <= "0000000";
					s1 <= "0000000";
				elsif s1 = "0000000" then			--9
					score1 <= "0001100";
					s1 <= "0001100";
				end if;
				
			end if;	--if statement for entire scoring
		 end if; 	--if statement for collision
		end if;		--if statement for entire process
	end process;
	
	
	
	--This process moves the user block
	PROCESS(ps2_code_new, ps2_code)															
	BEGIN	
	
		IF(ps2_code_new'EVENT AND ps2_code_new = '1' AND ps2_code = "00101101") THEN
			reset <= '1';
			start <= '1';
			xloc <= 450;
		END IF;
	
		IF(ps2_code_new'EVENT AND ps2_code_new = '1' AND start = '1') THEN
			IF(ps2_code = "00011011") THEN													--g key moves left
				start <= '0';
				reset <= '0';
			END IF;
		END IF;
	
	
--		IF(CLK_1HZ'EVENT AND CLK_1HZ = '1') THEN
		IF(ps2_code_new'EVENT AND ps2_code_new = '1' AND collide = '0') THEN
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
