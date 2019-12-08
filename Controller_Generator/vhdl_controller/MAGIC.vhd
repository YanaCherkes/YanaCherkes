----------------------------------------------------------
---------------------   MAGIC   --------------------------
----------------------------------------------------------
-- File: MAGIC.vhd
-- Design: magic_controller
-- Authors: Shiraz Sulimani and Yana Cherkes
-- description: async MAGIC implementation
-- #######################################################
-- version		date		changes / remarks
-- 1.00			24/02/19	-
-- #######################################################

library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;
use work.output_vec.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity MAGIC is
	port (
		ROW_OUT		: out output_row;                               
        	COLUMN_OUT	: out output_col;
		ENA		: in std_logic;					--enable the work of the block
		STATE		: in std_logic_vector(state_len downto 0);		--defines the bits num of each operation (00 - 1 bit (not), 01 - 2 bits, 10 - 3 bits, 11 - 4 bits)
        	ROW_INIT_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the row of the first input 
        	ROW_FIN_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the row of the last input
        	COL_SRC1_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the source column of the first src 
        	COL_SRC2_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the source column of the second src
        	COL_SRC3_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the source column of the third src
        	COL_SRC4_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the source column of the fourth src
		COL_DEST_ADDR	: in std_logic_vector(num_of_bits downto 0)		--defines the column of the output
	);           
end MAGIC;

architecture arc_MAGIC of MAGIC is
-------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------Process:--------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------

begin
	process(ENA,STATE,ROW_INIT_ADDR,ROW_FIN_ADDR,COL_SRC1_ADDR,COL_SRC2_ADDR,COL_SRC3_ADDR,COL_SRC4_ADDR,COL_DEST_ADDR)
	--define variables for row and column addreses
	variable state_arith	:   integer range 0 to 3;
	variable col1_addr	:   integer range 0 to col_max;
	variable col2_addr	:   integer range 0 to col_max;
	variable col3_addr	:   integer range 0 to col_max;
	variable col4_addr	:   integer range 0 to col_max;
	variable col_dest	:   integer range 0 to col_max;

	variable row_init	:   integer range 0 to row_max_input;
	variable row_fin	:   integer range 0 to row_max_input;
		

begin
	-- Get the cols and rows 
	state_arith	:= conv_integer(STATE);
	col1_addr	:= conv_integer(COL_SRC1_ADDR);
	col2_addr	:= conv_integer(COL_SRC2_ADDR);
	col3_addr	:= conv_integer(COL_SRC3_ADDR);
	col4_addr	:= conv_integer(COL_SRC4_ADDR);
	col_dest	:= conv_integer(COL_DEST_ADDR);
	
	row_init	:= conv_integer(ROW_INIT_ADDR);
	row_fin		:= conv_integer(ROW_FIN_ADDR);
	
	--Put Visolate voultage all over the memory
	ROW_OUT <= (others => Visolate);
	COLUMN_OUT <= (others => Visolate);
	
	--Put Vg voultage in the right columns
	if ENA = '1' then
		if (state_arith = 0)	then		-- one input
			COLUMN_OUT(col1_addr) <= Vg1;
		elsif	(state_arith = 1)	then	-- two inputs
			COLUMN_OUT(col1_addr) <= Vg2;    
			COLUMN_OUT(col2_addr) <= Vg2;
		elsif	(state_arith = 2)	then	-- three inputs
			COLUMN_OUT(col1_addr) <= Vg3;    
			COLUMN_OUT(col2_addr) <= Vg3;
			COLUMN_OUT(col3_addr) <= Vg3;
		elsif	(state_arith = 3)	then	-- four inputs
			COLUMN_OUT(col1_addr) <= Vg4;    
			COLUMN_OUT(col2_addr) <= Vg4;
			COLUMN_OUT(col3_addr) <= Vg4;    
			COLUMN_OUT(col4_addr) <= Vg4;
		end if;
		COLUMN_OUT(col_dest) <= gnd; --apply GND on result column
		ROW_OUT(row_fin downto row_init) <=(others => floating); --apply Vfloating on the rows inputs
	end if;
	
	end process;
  
end arc_MAGIC ;