----------------------------------------------------------
---------------------   ASYNC_FALSE   --------------------------
----------------------------------------------------------
-- File: ASYNC_FALSE.vhd
-- Design: magic_controller
-- Authors: Shiraz Sulimani And Yana Cherkes
-- description: implements async false operation
-- #######################################################
-- version		date		changes / remarks
-- 1.00			6/01/19	based on magic_controller's async_false
-- ####################################################### 

library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;
use work.output_vec.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ASYNC_FALSE is
	port(
		ROW_OUT			: out output_row;                               
		COLUMN_OUT		: out output_col;
		ENA			: in std_logic;
		BITS_NUM		: in std_logic_vector(num_of_bits downto 0);		--defines the number of the memristors on the column/row of Vw1 
		ROW_INIT_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the number of the first memristor in the row/column of the first area 
		ROW_FIN_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the number of the last memristor in the row/column of the first area
		VW0_COL_INIT_ADDR	: in std_logic_vector(num_of_bits downto 0)		--defines the number of the first memristor in the column/row of Vw1
	);
end ASYNC_FALSE;

architecture arc_ASYNC_FALSE of ASYNC_FALSE is
	
begin
	
process (ENA, BITS_NUM, ROW_INIT_ADDR, ROW_FIN_ADDR, VW0_COL_INIT_ADDR)  
	variable col_Vw0_addr       :   integer range 0 to col_max;
	variable col_vec_size       :   integer range 0 to col_max;
	variable row_init	    :   integer range 0 to row_max_input;
	variable row_fin            :   integer range 0 to row_max_input;

begin
	col_Vw0_addr    	:= conv_integer(VW0_COL_INIT_ADDR);	
	col_vec_size   		:= conv_integer(BITS_NUM);
	row_init	      	:= conv_integer(ROW_INIT_ADDR);  
	row_fin 	       	:= conv_integer(ROW_FIN_ADDR);	
	
	
	ROW_OUT <= (others => floating);
	COLUMN_OUT <= (others => floating);
		
	if ENA = '1' then
			COLUMN_OUT((col_Vw0_addr+col_vec_size-1) downto col_Vw0_addr) <= (others => Vw0);                                                                  --one area
			ROW_OUT(row_fin downto row_init) <= (others => gnd);

	end if;

end process;
	
end arc_ASYNC_FALSE ;