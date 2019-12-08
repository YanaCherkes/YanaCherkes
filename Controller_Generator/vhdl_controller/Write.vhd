----------------------------------------------------------
----------------------   WRITE   --------------------------
----------------------------------------------------------
-- File: Write.vhd
-- Design: magic_controller
-- Authors: Shiraz Sulimani and Yana Cherkes
-- description: 
-- type 10:
-- receives column to start writing data to
-- recieves a start and end row to write to
-- recieves data to write
-- gets total number of bits to write in a row
-- implements NOR operation between given terms
-- type 11:
-- recieves data to write
-- total bit of both functions: BIT NUMS 
-- #######################################################
-- version		date		changes / remarks
-- 1.00			10/01/19	--
-- #######################################################
library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;
use work.output_vec.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

entity WRITE is
  port (
		ROW_OUT         : out output_row;                               
        	COLUMN_OUT      : out output_col;
		FINISH          : out std_logic;
		CLK		: in std_logic;
		OPERATION_TYPE  : in std_logic_vector(type_len downto 0);
		BITS_NUM	: in std_logic_vector(num_of_bits downto 0); -- defines number of memristors to write
		DATA10   	: in std_logic_vector(operation_len - type_len - 1 - 4*num_of_bits - 4 downto 0); -- partial data inside a write command
		DATA11   	: in std_logic_vector(operation_len - type_len - 1 downto 0); -- full data, an opcode for only writing (depends on previous operation)
		VW_COL_ADDR	: in std_logic_vector(num_of_bits downto 0); -- first column of memristor
		ROW_INIT_ADDR  	: in std_logic_vector(num_of_bits downto 0); -- first row of memristor
		ROW_FIN_ADDR   	: in std_logic_vector(num_of_bits downto 0) -- last row of memristor
		);
end WRITE;

architecture arc_WRITE of WRITE is
 
	type states is (
			init_st,  --initialize all the signals and writes zeroes to destination
			write_10_state, 
			op_type_11_init_st, --11 state is full writing 
			write_11_state,
			finish_st
			);
				
				
	signal write_st            	: states;

	signal col_vec_size             :   integer range 0 to col_max;
	signal col_vec_size_11          :   integer range 0 to col_max;
  
	signal col_Vw_addr              :   integer range 0 to col_max;

	signal row_addr_init            :   integer range 0 to row_max_input;
	signal row_addr_fin             :   integer range 0 to row_max_input;
	
	signal counter             	:   std_logic_vector(2 downto 0);
	
	signal data_10			: std_logic_vector(operation_len - type_len - 1 - 4*num_of_bits - 4 downto 0);
	signal data_11			: std_logic_vector(operation_len - type_len - 1 downto 0);

	
begin

	col_Vw_addr           <= conv_integer(VW_COL_ADDR);
	col_vec_size          <= conv_integer(BITS_NUM);
	
	row_addr_init         <= conv_integer(ROW_INIT_ADDR);  
	row_addr_fin          <= conv_integer(ROW_FIN_ADDR);  

	data_10 	      <= DATA10;
	data_11 	      <= DATA11;
	
process (CLK)
begin
	if rising_edge (CLK) then

		case write_st is
			when init_st => --initiate writing
				ROW_OUT <= (others => floating);
				COLUMN_OUT <= (others => floating);
				FINISH <= '0';
				counter <= "000";
				if (OPERATION_TYPE = "10") then
					write_st <= write_10_state;
				elsif (OPERATION_TYPE = "11") then
					write_st <= op_type_11_init_st;
				end if;
				
			when write_10_state => -- write partial data (maximum 46 bits)
					if (col_vec_size <= 46) then -- the vector we want to write is given in one instruction
						COLUMN_OUT((col_Vw_addr-1) downto 0) <= (others => floating);
						for I in 0 to col_vec_size-1 loop
							if (data_10(I) = '0') then
								COLUMN_OUT(col_Vw_addr+I) <= Vw0;
							elsif (data_10(I) = '1') then
								COLUMN_OUT(col_Vw_addr+I) <= Vw1;
							
							end if;
						end loop;
						COLUMN_OUT((col_max-1) downto (col_Vw_addr+col_vec_size)) <= (others => floating);
						write_st <= finish_st;

					elsif (col_vec_size > 46) then
						COLUMN_OUT((col_Vw_addr-1) downto 0) <= (others => floating);
						for I in 0 to 45 loop  -- col_vec_size-1=45
							if (data_10(I) = '0') then
								COLUMN_OUT(col_Vw_addr+I) <= Vw0;
							elsif (data_10(I) = '1') then
								COLUMN_OUT(col_Vw_addr+I) <= Vw1;
							end if;
						end loop;
						COLUMN_OUT((col_max-1) downto (col_Vw_addr+46)) <= (others => floating);
						write_st <= op_type_11_init_st;
					end if;

					ROW_OUT(row_addr_init-1 downto 0) <= (others => floating);
					ROW_OUT(row_addr_fin downto row_addr_init) <= (others => gnd);
					ROW_OUT(row_max_input-1 downto (row_addr_fin+1)) <= (others => floating);			
					
			when op_type_11_init_st => -- initiate writing next data
				ROW_OUT <= (others => floating);
				COLUMN_OUT <= (others => floating);
				FINISH <= '0';
				col_vec_size_11 <= col_vec_size - 46; --46 bits were already written in states write 0 and write 1
				if (OPERATION_TYPE = "11") then
					write_st <= write_11_state;
				else
					write_st <= finish_st;
				end if;

			
			when write_11_state => -- write given data (over 46 bits)
					COLUMN_OUT((col_Vw_addr+46-1) downto 0) <= (others => floating);
					for I in 0 to col_vec_size_11-1 loop
						if (data_11(I) = '0') then
							COLUMN_OUT(col_Vw_addr+46+I) <= Vw0;
						elsif (data_11(I) = '1') then
							COLUMN_OUT(col_Vw_addr+46+I) <= Vw1;
						end if;
					end loop;
					COLUMN_OUT((col_max-1) downto (col_Vw_addr+46+col_vec_size_11)) <= (others => floating);
					ROW_OUT(row_addr_init-1 downto 0) <= (others => floating);
					ROW_OUT(row_addr_fin downto row_addr_init) <= (others => gnd);
					ROW_OUT(row_max_input-1 downto (row_addr_fin+1)) <= (others => floating);
				write_st <= finish_st;

			when finish_st =>
				ROW_OUT <= (others => floating);
				COLUMN_OUT <= (others => floating);
				FINISH <= '1';
				counter <= counter + 1;
				if (counter = "111") then
					write_st <= init_st;
					counter <= "000";
				end if;
		end case;
	end if;
end process;
  
end arc_WRITE;

