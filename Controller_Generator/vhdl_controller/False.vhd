----------------------------------------------------------
---------------------   FALSE   --------------------------
----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;
use work.output_vec.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity FALSE is
	port(
		ROW_OUT        : out output_row;                               
		COLUMN_OUT      : out output_col;
		FINISH          : out std_logic;
		CLK             : in std_logic;
		OPERATION_TYPE  : in std_logic_vector(type_len downto 0);
		OPCODE		: in std_logic_vector(opcode_len downto 0);
		BITS_NUM        : in std_logic_vector(num_of_bits downto 0);             --defines the number of the memristors on the column/row of Vw1 
		ROW_INIT_ADDR : in std_logic_vector(num_of_bits downto 0);             --defines the number of the first memristor in the row/column of the first area 
		ROW_FIN_ADDR  : in std_logic_vector(num_of_bits downto 0);             --defines the number of the last memristor in the row/column of the first area
		VW0_INIT_ADDR   : in std_logic_vector(num_of_bits downto 0)             --defines the number of the first memristor in the column/row of Vw1
	);
end FALSE;

architecture arc_FALSE of FALSE is
 
	signal col_vec_size	:	integer range 0 to col_max; 
	signal col_Vw0_addr	:	integer range 0 to col_max;
	signal row_init_ar1	:	integer range 0 to row_max_input;
	signal row_fin_ar1	:	integer range 0 to row_max_input;
	
begin

	col_Vw0_addr      <= conv_integer(VW0_INIT_ADDR);
	col_vec_size      <= conv_integer(BITS_NUM);
	row_init_ar1      <= conv_integer(ROW_INIT_ADDR);  
	row_fin_ar1       <= conv_integer(ROW_FIN_ADDR);  

	
process (CLK)
begin
	if rising_edge (CLK) then
		if (OPERATION_TYPE = "00") and (OPCODE = "00000000") then	--reset
			ROW_OUT <= (others => floating);
			COLUMN_OUT <= (others => floating);
			FINISH <= '0';
			
		elsif (OPERATION_TYPE = "01") and (OPCODE = "00000010") then --false
			FINISH <= '1';                                                                      	
			COLUMN_OUT((col_Vw0_addr-1) downto 0) <= (others => floating);
			COLUMN_OUT((col_Vw0_addr+col_vec_size-1) downto col_Vw0_addr) <= (others => Vw0);
			COLUMN_OUT((col_max-1) downto (col_Vw0_addr+col_vec_size)) <= (others => floating);
                                                                  
			ROW_OUT(row_init_ar1-1 downto 0) <= (others => floating);
			ROW_OUT(row_fin_ar1 downto row_init_ar1) <= (others => gnd);
			ROW_OUT(row_max_input-1 downto (row_fin_ar1+1)) <= (others => floating);
	
			
		else --not false
			FINISH <= '0';
			ROW_OUT <= (others => floating);
			COLUMN_OUT <= (others => floating);
		end if;
	end if;
end process;
	
end arc_FALSE ;