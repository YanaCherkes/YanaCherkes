----------------------------------------------------------
--------------------  AND - MAGIC  -----------------------
----------------------------------------------------------
-- File: AND_VEC.vhd
-- Design: magic_controller
-- Authors: Shiraz Sulimani and Yana Cherkes
-- description:
-- receives up to 4 terms
-- all terms have the same start and end row
-- each term has up to BIT_NUMS source columns
-- the calculations are done in iterations through the columns
-- implements AND operation between given terms
-- #######################################################
-- version		date		changes / remarks
-- 1.00			24/02/19	-
-- #######################################################
library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;
use work.output_vec.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

entity AND_VEC is
	port (
		FINISH			: out std_logic;
		ROW_OUT			: out output_row;                               
		COLUMN_OUT		: out output_col;
		PROCESS_AREA_FINISH	: out std_logic_vector(num_of_bits downto 0);		--defines the col of the process area's end

		ENA			: in std_logic;					--enable the work of the block
		STATE			: in std_logic_vector(state_len downto 0);		--defines the bits num of each operation (00 - 1 bit (not), 01 - 2 bits, 10 - 3 bits, 11 - 4 bits)
		BITS_NUM 		: in std_logic_vector(num_of_bits downto 0);		--defines the bits num of each src
		COL_SRC1_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the source column of the first src 
		COL_SRC2_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the source column of the second src
		COL_SRC3_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the source column of the third src
		COL_SRC4_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the source column of the fourth src
      		ROW_INIT_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the row of the first input
        	ROW_FIN_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the row of the last input
		COL_DEST_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the column of the output
		PROCESS_AREA_INIT	: in std_logic_vector(num_of_bits downto 0);		--defines the col of the process area's start
		CLK			: in std_logic
	);
end AND_VEC;

architecture arc_AND_VEC of AND_VEC is
-------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------Components:--------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------

component MAGIC 
	port (
		ROW_OUT		: out output_row;                            
        	COLUMN_OUT	: out output_col;
		ENA		: in std_logic;					
		STATE		: in std_logic_vector(1 downto 0);
        	ROW_INIT_ADDR	: in std_logic_vector(num_of_bits downto 0);	
	        ROW_FIN_ADDR	: in std_logic_vector(num_of_bits downto 0);	
	        COL_SRC1_ADDR	: in std_logic_vector(num_of_bits downto 0);	
	        COL_SRC2_ADDR	: in std_logic_vector(num_of_bits downto 0);	
	        COL_SRC3_ADDR	: in std_logic_vector(num_of_bits downto 0);	
	        COL_SRC4_ADDR	: in std_logic_vector(num_of_bits downto 0);	
		COL_DEST_ADDR	: in std_logic_vector(num_of_bits downto 0)
	);
end component; 

-------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------States:------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------

type states is (initial_values, magic_not_src1, magic_not_src2, magic_not_src3, magic_not_src4, magic_nor, finish_st);

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------Signals:----------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------

signal  and_st			: states;
signal 	process_area_in		: std_logic_vector(num_of_bits downto 0);
signal 	bit_num_signal		: std_logic_vector(num_of_bits downto 0); --save the bits num of each src
signal 	counter			: std_logic_vector(num_of_bits downto 0);	--counts the number of bits that have been calculate
signal 	A_col			: std_logic_vector(num_of_bits downto 0);	--A is the vector of the first src                  
signal 	B_col			: std_logic_vector(num_of_bits downto 0); --B is the vector of the second src   		
signal 	C_col			: std_logic_vector(num_of_bits downto 0);	--C is the vector of the third src                  
signal 	D_col			: std_logic_vector(num_of_bits downto 0); --D is the vector of the fourth src
signal 	magic_not_src1_dest	: std_logic_vector(num_of_bits downto 0); --saves the output col of magic_not_src1
signal 	magic_not_src2_dest	: std_logic_vector(num_of_bits downto 0); --saves the output col of magic_not_src2
signal 	magic_not_src3_dest	: std_logic_vector(num_of_bits downto 0); --saves the output col of magic_not_src3
signal 	magic_not_src4_dest	: std_logic_vector(num_of_bits downto 0); --saves the output col of magic_not_src4
 
----------------------------- MAGIC signals --------------------------------                              
signal col1_addr		: std_logic_vector(num_of_bits downto 0):=(others=>'0');
signal col2_addr		: std_logic_vector(num_of_bits downto 0):=(others=>'0');
signal col3_addr		: std_logic_vector(num_of_bits downto 0):=(others=>'0');
signal col4_addr		: std_logic_vector(num_of_bits downto 0):=(others=>'0');
signal col_dest			: std_logic_vector(num_of_bits downto 0):=(others=>'0');
signal row_init    		: std_logic_vector(num_of_bits downto 0):=(others=>'0');
signal row_fin    		: std_logic_vector(num_of_bits downto 0):=(others=>'0');
signal state_arith    		: std_logic_vector(1 downto 0):=(others=>'0');
signal ena_magic_sig   	  	: std_logic:='0';
signal row_magic      		: output_row;
signal col_magic      		: output_col;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------Port maps:--------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------

begin			
	u_magic: MAGIC 
		port map(
			ROW_OUT		=>row_magic,
        		COLUMN_OUT	=>col_magic,
			ENA		=>ena_magic_sig,
			STATE		=>state_arith,
        		ROW_INIT_ADDR	=>row_init,
	        	ROW_FIN_ADDR	=>row_fin,
	        	COL_SRC1_ADDR	=>col1_addr,
	        	COL_SRC2_ADDR	=>col2_addr,
	        	COL_SRC3_ADDR	=>col3_addr,
	        	COL_SRC4_ADDR	=>col4_addr,
			COL_DEST_ADDR	=>col_dest
		);			
	
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------Process:----------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------

process(CLK)
	begin

		if rising_edge(CLK) then
			ROW_OUT		<= (others => floating);
			COLUMN_OUT	<= (others => floating);
			FINISH		<= '0';

			if ( ENA = '1') then
				case and_st is
					when initial_values =>

						and_st		<= magic_not_src1;
						--initiate all variables and signals
						A_col		<= COL_SRC1_ADDR;
						B_col		<= COL_SRC2_ADDR;
						C_col		<= COL_SRC3_ADDR;
						D_col		<= COL_SRC4_ADDR;

						ena_magic_sig	<= '0';
						bit_num_signal	<= BITS_NUM;
						counter		<= "000000001";
						state_arith	<= (others => '0');
						col1_addr	<= (others => '0');
						col2_addr	<= (others => '0');
						col3_addr	<= (others => '0');
						col4_addr	<= (others => '0');
						col_dest	<= (others => '0');
						magic_not_src1_dest    <= (others => '0');
						magic_not_src2_dest    <= (others => '0');
						magic_not_src3_dest    <= (others => '0');
						magic_not_src4_dest    <= (others => '0');
						row_init	<= (others => '0');
						row_fin		<= (others => '0');
						process_area_in	<= PROCESS_AREA_INIT;
					
					when magic_not_src1 =>
						and_st 		<= magic_not_src2;
						state_arith	<="00"; --not
						--- NOT(A) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= A_col;				
						col2_addr	<= A_col;
						col3_addr	<= A_col;				
						col4_addr	<= A_col;	
						col_dest	<= process_area_in;
						magic_not_src1_dest	<= process_area_in;
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;	
						process_area_in <= process_area_in + "000000001";
					
					when magic_not_src2 => 
						--defines the next state according to the arith state
						if (STATE = "10") then
							and_st 	<= magic_not_src3;
						elsif (STATE = "11") then
							and_st 	<= magic_not_src3;
						else
							and_st <= magic_nor;
						end if;
						state_arith	<="00"; --not

						--- NOT(B) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= B_col;				
						col2_addr	<= B_col;
						col3_addr	<= B_col;				
						col4_addr	<= B_col;	
						col_dest	<= process_area_in;
						magic_not_src2_dest	<= process_area_in;
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;	
						process_area_in <= process_area_in + "000000001";
						--update not(A) in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;

					when magic_not_src3 =>
						--defines the next state according to the arith state
						if (STATE = "11") then
							and_st 	<= magic_not_src4;
						else
							and_st <= magic_nor;
						end if;
						state_arith	<="00"; --not
						--- NOT(C) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= C_col;				
						col2_addr	<= C_col;
						col3_addr	<= C_col;				
						col4_addr	<= C_col;	
						col_dest	<= process_area_in;
						magic_not_src3_dest	<= process_area_in;
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;
						process_area_in <= process_area_in + "000000001";	
						--update not(B) in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;

					when magic_not_src4 =>
						and_st 		<= magic_nor;
						state_arith	<="00"; --not
						--- NOT(D) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= D_col;				
						col2_addr	<= D_col;
						col3_addr	<= D_col;				
						col4_addr	<= D_col;	
						col_dest	<= process_area_in;
						magic_not_src4_dest	<= process_area_in;
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;	
						process_area_in <= process_area_in + "000000001";
						--update not(C) in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;

				
					when magic_nor =>
						and_st 		<= finish_st;
						state_arith	<= STATE;
						--- NOR(A',B',C',D')=AND(A,B,C,D) ---
						ena_magic_sig	<= '1';   	 					
						col1_addr	<= magic_not_src1_dest;				
						col2_addr	<= magic_not_src2_dest;
						col3_addr	<= magic_not_src3_dest;				
						col4_addr	<= magic_not_src4_dest;		
						col_dest	<= COL_DEST_ADDR + counter - "000000001";--the output here is written directly to the begining of the processing area
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;
						--update not(D) in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;	
					
					when finish_st =>
						--update the current valid col of the processing area
						PROCESS_AREA_FINISH	<= process_area_in;
						--update and(A,B,C,D) in crossbar
						ROW_OUT			<= row_magic; 	                       
						COLUMN_OUT		<= col_magic;
						if (counter < bit_num_signal) then -- updates addresses of the next bits
							and_st 		<= magic_not_src1;
							A_col		<= COL_SRC1_ADDR + counter;
							B_col		<= COL_SRC2_ADDR + counter;
							C_col		<= COL_SRC3_ADDR + counter;
							D_col		<= COL_SRC4_ADDR + counter;
							counter		<= counter + "000000001";
						else	-- finish all
							FINISH		<= '1';
						end if;

					when others => null;
				
				end case;
			else	--ENA = '0'
				and_st	<= initial_values;
			end if;
		end if;
end process;
end architecture;		
			
