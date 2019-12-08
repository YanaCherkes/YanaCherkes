----------------------------------------------------------------
---------------- MAGIC Crossbar Memory Model -------------------
----------------------------------------------------------------
-- File: Crossbar.vhd
-- Design: magic_controller
-- Authors: Adi Havazelet and Ben Hadad
-- description: memory model for MAGIC simulations
-- #######################################################
-- version		date		changes / remarks
-- 1.00			09/10/16	based on imply_controller's Crossbar
-- ####################################################### 
library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;
use work.output_vec.all;
--use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;

entity CROSSBAR is
	port (
		ROW		: in output_row;
		COLUMN		: in output_col;
		CLK		: in std_logic;
		OUTPUT		: out std_logic_vector(col_max-1 downto 0);
		VALID		: out std_logic
	);
end CROSSBAR;

architecture arc_CROSSBAR of CROSSBAR is
	signal M : mem_matrix; 
begin
	process (CLK)
	begin
--		OUTPUT <= (others => '0');
		if rising_edge (CLK) then
			VALID <= '0';
			for I in 0 to row_max_input-1 loop -- I - row number
				if (ROW(I) /= Visolate) then 
					if (ROW(I) = Rref) then				--read
						for col1 in 0 to col_max-1 loop
							if (COLUMN(col1) = Vr) then
								OUTPUT(col1) <= M(I, col1);
								VALID <= '1';		
							end if;
						end loop;
					elsif (ROW(I) = Vr) then 										
						for col1 in 0 to col_max-1 loop
							if (COLUMN(col1) = Rref) then
								OUTPUT(I) <= M(I, col1);
								VALID <= '1';			
							end if;
						end loop;
					elsif (ROW(I) = gnd) then					
						for col1 in 0 to col_max-1 loop
							if (COLUMN(col1) = Vw0) then	--write '0'
								M(I, col1) <= '0';
							elsif (COLUMN(col1) = Vw1) then	--write '1'
								M(I, col1) <= '1';
							end if;
						end loop;
					elsif (ROW(I) = floating) then			--MAGIC columns
						for col1 in 0 to col_max-1 loop
							if (COLUMN(col1) = Vg1) then -- one input
								for colOut in 0 to col_max-1 loop	
									if (COLUMN(colOut) = gnd) then									
										if M(I,colOut) = '1' then
											if (M(I,col1) = '0') then		   		
												M(I,colOut) <= '1';
											else
												M(I,colOut) <= '0';
											end if;
										else
											-- assert - result memristor wasnt initalized to '1'
											assert false report "put '1' to the result memristors1" severity warning;
										end if;
									end if;												
								end loop;	
							
							elsif (COLUMN(col1) = Vg2) then    -- two inputs 					  		
								for col2 in (col1+1) to (col_max-1) loop
									if (COLUMN(col2) = Vg2) then
										for colOut in 0 to col_max-1 loop
											if (COLUMN(colOut) = gnd) then									
												if M(I,colOut) = '1' then
													if (M(I,col1) = '0' and M(I,col2) = '0') then		   		
														M(I,colOut) <= '1';
													else
														M(I,colOut) <= '0';
													end if;
												else
													-- assert - result memristor wasnt initalized to '1'
													assert false report "put '1' to the result memristors1" severity warning;
												end if;
											end if;												
										end loop;	
									end if;
								end loop;
							elsif (COLUMN(col1) = Vg3) then    -- three inputs 					  		
								for col2 in (col1+1) to (col_max-1) loop
									if (COLUMN(col2) = Vg3) then
										for col3 in (col2+1) to (col_max-1) loop
											if (COLUMN(col3) = Vg3) then
												for colOut in 0 to col_max-1 loop
													if (COLUMN(colOut) = gnd) then									
														if M(I,colOut) = '1' then
															if (M(I,col1) = '0' and M(I,col2) = '0' and M(I,col3) = '0') then		   		
																M(I,colOut) <= '1';
															else
																M(I,colOut) <= '0';
															end if;
														else
															-- assert - result memristor wasnt initalized to '1'
															assert false report "put '1' to the result memristors1" severity warning;
														end if;
													end if;												
												end loop;
											end if;	
										end loop;											
									end if;
								end loop;
							elsif (COLUMN(col1) = Vg4) then    -- four inputs 					  		
								for col2 in (col1+1) to (col_max-1) loop
									if (COLUMN(col2) = Vg4) then
										for col3 in (col2+1) to (col_max-1) loop
											if (COLUMN(col3) = Vg4) then
												for col4 in (col3+1) to (col_max-1) loop
													if (COLUMN(col4) = Vg4) then
														for colOut in 0 to col_max-1 loop											
															if (COLUMN(colOut) = gnd) then									
																if M(I,colOut) = '1' then
																	if (M(I,col1) = '0' and M(I,col2) = '0' and M(I,col3) = '0' and M(I,col4) = '0') then		   		
																		M(I,colOut) <= '1';
																	else
																		M(I,colOut) <= '0';
																	end if;
																else
																	-- assert - result memristor wasnt initalized to '1'
																	assert false report "put '1' to the result memristors1" severity warning;
																end if;
															end if;												
														end loop;
													end if;
												end loop;
											end if;	
										end loop;											
									end if;
								end loop;
							end if;
						end loop;
					end if;
				end if;
			end loop;
		end if;
	end process;

end arc_CROSSBAR ;

