---------------------------------------------------------------
---------------------   ASYNC_TRUE   --------------------------
---------------------------------------------------------------
-- File: ASYNC_TRUE.vhd
-- Design: magic_controller
-- Authors: Shiraz Sulimani And Yana Cherkes
-- description: implements async true operation
-- #######################################################
-- version		date		changes / remarks
-- 1.00			6/01/19	based on magic_controller's async_true
-- ####################################################### 
library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;
use work.output_vec.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ASYNC_TRUE is
	port(
		ROW_OUT			: out output_row;                               
		COLUMN_OUT		: out output_col;
		ENA			: in std_logic;
		BITS_NUM		: in std_logic_vector(num_of_bits downto 0);		--defines the number of the memristors on the column/row of Vw1 
		AREA1_ROW_INIT_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the number of the first memristor in the row/column of the first area 
		AREA1_ROW_FIN_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the number of the last memristor in the row/column of the first area
		VW1_COL_INIT_ADDR	: in std_logic_vector(num_of_bits downto 0)		--defines the number of the first memristor in the column/row of Vw1
	);
end ASYNC_TRUE;

architecture arc_ASYNC_TRUE of ASYNC_TRUE is
	
begin
	
process (ENA, BITS_NUM, AREA1_ROW_INIT_ADDR, AREA1_ROW_FIN_ADDR, VW1_COL_INIT_ADDR)  
	variable col_Vw1_addr       :   integer range 0 to col_max;
	variable col_vec_size       :   integer range 0 to col_max;
	variable row_init_ar1       :   integer range 0 to row_max_input;
	variable row_fin_ar1        :   integer range 0 to row_max_input;
	
begin
	col_Vw1_addr      := conv_integer(VW1_COL_INIT_ADDR);	
	col_vec_size      := conv_integer(BITS_NUM);
	row_init_ar1      := conv_integer(AREA1_ROW_INIT_ADDR);  
	row_fin_ar1       := conv_integer(AREA1_ROW_FIN_ADDR);	
	
	
	ROW_OUT <= (others => floating);
	COLUMN_OUT <= (others => floating);
		
	if ENA = '1' then
			COLUMN_OUT((col_Vw1_addr+col_vec_size) downto col_Vw1_addr) <= (others => Vw1);                                                                  --one area
			ROW_OUT(row_fin_ar1 downto row_init_ar1) <= (others => gnd);

	end if;

end process;
	
end arc_ASYNC_TRUE ;