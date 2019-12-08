----------------------------------------------------------
----------------------   READ   --------------------------
----------------------------------------------------------
-- File: Read.vhd
-- Design: magic_controller
-- Authors: Shiraz Sulimani and Yana Cherkes
-- description:
-- receives a row to read from
-- recievces a starting column to read from
-- recievces the number of bits to read
-- reades the given data and returns it to the Crossbar OUTPUT
-- #######################################################
-- version		date		changes / remarks
-- 1.00			09/01/19	-
-- #######################################################

library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;
use work.output_vec.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity READ is
  port (
	ROW_OUT         : out output_row;                               
        COLUMN_OUT      : out output_col;
	FINISH          : out std_logic;
	CLK		: in std_logic;
	OPERATION_TYPE  : in std_logic_vector(type_len downto 0);
	OPCODE		: in std_logic_vector(opcode_len downto 0);
        VR_COL_ADDR   	: in std_logic_vector(num_of_bits downto 0);            	--defines the address of the first memristor in the column of Vr
        BITS_NUM       	: in std_logic_vector(num_of_bits downto 0);             	--defines the number of the memristors in the row/column
        ROW_READ_ADDR   : in std_logic_vector(num_of_bits downto 0)              --defines the address of the memristors row of reading
	);
end READ;

architecture arc_READ of READ is

	signal col_vec_size             :   integer range 0 to col_max; 
	signal col_Vr_addr              :   integer range 0 to col_max;
	signal row_addr                 :   integer range 0 to row_max_input;

begin
	col_Vr_addr             <= conv_integer(VR_COL_ADDR);
	col_vec_size            <= conv_integer(BITS_NUM);
	row_addr                <= conv_integer(ROW_READ_ADDR);  

	
process (CLK)
begin
	if rising_edge (CLK) then
		
		if (OPERATION_TYPE = "01") and (OPCODE = "00000001") then  --read
			FINISH <= '1';

			--put voltages on columns
			COLUMN_OUT((col_Vr_addr-1) downto 0) <= (others => floating);
			COLUMN_OUT((col_Vr_addr+col_vec_size-1) downto col_Vr_addr) <= (others => Vr);
			COLUMN_OUT((col_max-1) downto (col_Vr_addr+col_vec_size)) <= (others => floating);
	
			--put voltages on rows
			ROW_OUT((row_addr-1) downto 0) <= (others => floating);
			ROW_OUT(row_addr) <= Rref;
			ROW_OUT((row_max_input-1) downto (row_addr+1)) <= (others => floating);

		else
			ROW_OUT <= (others => floating);
			COLUMN_OUT <= (others => floating);
			FINISH <= '0';
			
		end if;
	end if;
end process;
  
end arc_READ;