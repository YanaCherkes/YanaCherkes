----------------------------------------------------------
-----------------   Full_Adder - MAGIC  -------------------
----------------------------------------------------------
-- File: Full_Adder.vhd
-- Design: magic_controller
-- Authors: Shiraz Sulimani And Yana Cherkes
-- description:
-- 2 bit full adder
-- #######################################################
-- version		date		changes / remarks
-- 1.00			12/01/19	based on JASON output
-- #######################################################
library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;
use work.output_vec.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

entity Full_Adder is
	port (
		FINISH			: out std_logic;
		ROW_OUT			: out output_row;
		COLUMN_OUT		: out output_col;
		PROCESS_AREA_FINISH	: out std_logic_vector(num_of_bits downto 0);
		ENA			: in std_logic;					--enable the work of the block
		STATE			: in std_logic_vector(state_len downto 0);		--defines the arithemetic state
		COL_SRC1_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the column of the first src 
		COL_SRC2_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the column of the second src
		COL_SRC3_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the column of the third src 
		COL_SRC4_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the column of the fourth src
      		ROW_INIT_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the row of the first input
        	ROW_FIN_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the row of the last input
		COL_DEST_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the column of the output 
		PROCESS_AREA_INIT	: in std_logic_vector(num_of_bits downto 0);
		CLK			: in std_logic
	);
end Full_Adder;

architecture arc_Full_Adder of Full_Adder is

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
    
  

	type states is (initial_values, not_A, not_B, nor_w1_w2, nor_A_B, nor_w4_w5, nor_w6_Cin, not_w6, not_Cin, nor_w3_w7, nor_w9_w8, nor_w5_w9, not_w10, finish_st);
   
   
	signal  full_adder_st		: states;
	signal 	process_area_in		: std_logic_vector(num_of_bits downto 0);	       
	signal 	A_col			: std_logic_vector(num_of_bits downto 0);	--A is the vector of the first term                  
	signal 	B_col			: std_logic_vector(num_of_bits downto 0); --B is the vector of the second term
	signal 	C_col			: std_logic_vector(num_of_bits downto 0);	--C is the vector of the third term                  
	signal 	D_col			: std_logic_vector(num_of_bits downto 0); --D is the vector of the fourth term	
	
	signal 	w1			: std_logic_vector(num_of_bits downto 0);
	signal  w2			: std_logic_vector(num_of_bits downto 0);		 
	signal 	w3			: std_logic_vector(num_of_bits downto 0);
	signal  w4			: std_logic_vector(num_of_bits downto 0);		
	signal 	w5			: std_logic_vector(num_of_bits downto 0);
	signal  w6			: std_logic_vector(num_of_bits downto 0);		 
	signal 	w7			: std_logic_vector(num_of_bits downto 0);
	signal  w8			: std_logic_vector(num_of_bits downto 0);	
	signal 	w9			: std_logic_vector(num_of_bits downto 0);
	signal  w10			: std_logic_vector(num_of_bits downto 0);		 	
------------------------- MAGIC signals	----------------------------                              
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
	
	
	process(CLK)
		begin

		if rising_edge(CLK) then
			ROW_OUT		<= (others => floating);
			COLUMN_OUT	<= (others => floating);
			FINISH		<= '0';
		
			if ( ENA = '1') then
				case full_adder_st is
					
					when initial_values =>
						full_adder_st	<= not_A;
						--initiate all variables and signals
		
						A_col		<= COL_SRC1_ADDR;
						B_col		<= COL_SRC2_ADDR;
						C_col		<= COL_SRC3_ADDR;
						D_col		<= COL_SRC4_ADDR;

						ena_magic_sig	<= '0';
						state_arith	<= (others => '0');
						col1_addr	<= (others => '0');
						col2_addr	<= (others => '0');
						col3_addr	<= (others => '0');
						col4_addr	<= (others => '0');
						col_dest	<= (others => '0');       
						row_init	<= (others => '0');
						row_fin		<= (others => '0');

						w1		<= (others => '0');
						w2		<= (others => '0');
						w3		<= (others => '0');
						w4		<= (others => '0');
						w5		<= (others => '0');
						w6		<= (others => '0');
						w7		<= (others => '0');
						w8		<= (others => '0');
						w9		<= (others => '0');
						w10		<= (others => '0');
						process_area_in	<= PROCESS_AREA_INIT;	
					
					--"T1": "w1(3)=inv1{A(0)}"
					when not_A =>
						full_adder_st 	<= not_B;
						state_arith	<="00"; -- not
						--- NOT(A) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= A_col;				
						col2_addr	<= A_col;	--not used
						col3_addr	<= A_col;	--not used			
						col4_addr	<= A_col;	--not used
						col_dest	<= process_area_in;
						w1		<= process_area_in; --save the column of not(A)
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;	
						process_area_in <= process_area_in + "000000001"; --increase process area index
					
					--"T2": "w2(4)=inv1{B(1)}"		
					when not_B => 
						full_adder_st 	<= nor_w1_w2;
						state_arith	<="00";--not
						--- NOT(B) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= B_col;				
						col2_addr	<= B_col;--not used
						col3_addr	<= B_col;--not used				
						col4_addr	<= B_col;--not used	
						col_dest	<= process_area_in;
						w2 		<= process_area_in; --save the location of not(B)
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;
						process_area_in <= process_area_in + "000000001";
						--update previous in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;

					--"T3": "w5(5)=nor2{w1(3),w2(4)}"
					when nor_w1_w2 =>
						full_adder_st 	<= nor_A_B;
						state_arith	<="01"; --two bit nor
						--- NOR(W1,W2) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= w1;				
						col2_addr	<= w2;
						col3_addr	<= w1;	--not used			
						col4_addr	<= w2;	--not used
						col_dest	<= process_area_in;
						w5		<= process_area_in;--save the result 
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;
						process_area_in <= process_area_in + "000000001";	
						--update previous in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;

					--"T4": "w4(6)=nor2{A(0),B(1)}"
					when nor_A_B =>
						full_adder_st 	<= nor_w4_w5;
						state_arith	<="01"; --nor
						--- NOR(A,B) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= A_col;				
						col2_addr	<= B_col;
						col3_addr	<= A_col;	--not used			
						col4_addr	<= B_col;	--not used
						col_dest	<= process_area_in;
						w4		<= process_area_in; --save result column
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;	
						process_area_in <= process_area_in + "000000001";
						--update previous in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;

					--"T5": "w6(7)=nor2{w4(6),w5(5)}"
					when nor_w4_w5 =>
						full_adder_st 	<= nor_w6_Cin;
						state_arith	<="01"; --nor
						--- NOR(W4,W5) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= w4;				
						col2_addr	<= w5;
						col3_addr	<= w4;	--not used			
						col4_addr	<= w5;	--not used
						col_dest	<= process_area_in;
						w6		<= process_area_in; --save result column
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;	
						process_area_in <= process_area_in + "000000001";

						--update previous in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;
					
					--"T6": "w8(8)=nor2{w6(7),Cin(2)}"
					when nor_w6_Cin => 
						full_adder_st 	<= not_w6;
						state_arith	<="01"; --nor
						--- NOR(W6,Cin) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= w6;				
						col2_addr	<= C_col;
						col3_addr	<= w6;	--not used			
						col4_addr	<= C_COL;	--not used
						col_dest	<= process_area_in;
						w8		<= process_area_in; --save result column
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;	
						process_area_in <= process_area_in + "000000001";

						--update previous in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;
					
					--"T7": "w7(9)=inv1{w6(7)}"
					when not_w6 => 
						full_adder_st 	<= not_Cin;
						state_arith	<="00"; --nor
						--- NOT(W6) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= w6;				
						col2_addr	<= w6;	--not used	
						col3_addr	<= w6;	--not used			
						col4_addr	<= w6;	--not used
						col_dest	<= process_area_in;
						w7		<= process_area_in; --save result column
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;	
						process_area_in <= process_area_in + "000000001";

						--update previous in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;	

					--"T8": "w3(10)=inv1{Cin(2)}"
					when not_Cin => 
						full_adder_st 	<= nor_w3_w7;
						state_arith	<="00"; --not
						--- NOT(Cin) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= C_col;				
						col2_addr	<= C_col;	--not used	
						col3_addr	<= C_col;	--not used			
						col4_addr	<= C_col;	--not used
						col_dest	<= process_area_in;
						w3		<= process_area_in; --save result column
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;	
						process_area_in <= process_area_in + "000000001";

						--update previous in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;	

					--"T9": "w9(11)=nor2{w3(10),w7(9)}"
					when nor_w3_w7 => 
						full_adder_st 	<= nor_w9_w8;
						state_arith	<="01"; --nor
						--- NOR(W3,W7) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= w3;				
						col2_addr	<= w7;	
						col3_addr	<= w3;	--not used			
						col4_addr	<= w7;	--not used
						col_dest	<= process_area_in;
						w9		<= process_area_in; --save result column
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;	
						process_area_in <= process_area_in + "000000001";

						--update previous in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;	

				--"T10": "S(12)=nor2{w9(11),w8(8)}"
				when nor_w9_w8 => 
						full_adder_st 	<= nor_w5_w9;
						state_arith	<="01"; --nor
						--- NOR(W9,W8) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= w9;				
						col2_addr	<= w8;	
						col3_addr	<= w9;	--not used			
						col4_addr	<= w8;	--not used
						col_dest	<= COL_DEST_ADDR; --write result S in the destination
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;	
						process_area_in <= process_area_in + "000000001";

						--update previous in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;	

				-- "T11": "w10(13)=nor2{w5(5),w9(11)}"
				when nor_w5_w9 => 
						full_adder_st 	<= not_w10;
						state_arith	<="01"; --nor
						--- NOR(W9,W5) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= w9;				
						col2_addr	<= w5;	
						col3_addr	<= w9;	--not used			
						col4_addr	<= w5;	--not used
						col_dest	<= process_area_in;
						w10		<= process_area_in;
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;	
						process_area_in <= process_area_in + "000000001";

						--update previous in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;

					--"T12": "Cout(14)=inv1{w10(13)}"
					when not_w10 => 
						full_adder_st 	<= finish_st;
						state_arith	<="00"; --not
						--- NOR(W9,W5) ---
						ena_magic_sig	<= '1';											
						col1_addr	<= w10;				
						col2_addr	<= w10;	--not used	
						col3_addr	<= w10;	--not used			
						col4_addr	<= w10;	--not used
						col_dest	<= COL_DEST_ADDR + "000000001"; -- write result Cout
						row_init	<= ROW_INIT_ADDR;
						row_fin		<= ROW_FIN_ADDR;	
						process_area_in <= process_area_in + "000000001";

						--update previous in crossbar
						ROW_OUT		<= row_magic; 	                       
						COLUMN_OUT	<= col_magic;

					when finish_st =>
						PROCESS_AREA_FINISH	<= process_area_in;
						FINISH 			<= '1';
						ROW_OUT  	 	<= row_magic;      
						COLUMN_OUT 		<= col_magic;
					
					when others => null;
					
				end case;
			else
				full_adder_st <= initial_values;
			end if;
		end if;
	end process;
end architecture;		
			
