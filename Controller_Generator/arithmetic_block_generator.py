# -*- coding: utf-8 -*-
"""
Created on Sun Sep  1 17:46:42 2019

@author: yanac
"""
from block_help_generator import num2binary
import os

def arithmetic_block_generator (block_names, opcodes, num_of_bits, processing_area_init, processing_area_size):
    
    path = 'vhdl_controller'
    if not os.path.exists(path):
        os.makedirs(path)
    
    file_name = "ARITHMETIC_BLOCK"
    full_file_name = file_name + ".vhd"
    file = open(os.path.join(path, full_file_name), 'w')

    counter = 0
    file.writelines(
    "library ieee;\n" +
    "use ieee.std_logic_1164.all;\n" +
    "use work.Declare.all;\n" +
    "use work.output_vec.all;\n" +
    "use ieee.numeric_std.all;\n" +
    "use ieee.std_logic_unsigned.all;\n" +
    "use ieee.std_logic_arith.all;\n" +
    "\n" +
    "entity ARITHMETIC_BLOCK is\n" +
    "	port (\n" +
    "		OPERATION_TYPE	 : in std_logic_vector(type_len downto 0);		--defines the type of the operation: 00-arithmetic; 01-true,false, read; 10-write; 11-write\n" +
    "		OPCODE           : in std_logic_vector(opcode_len downto 0);		--8 bits which defines the operation (NOR/AND/OR/NOT/NAND/XOR - relevant only for types 00 and 01)\n" +
    "		FINISH		: out std_logic;\n" +
    "		ROW_OUT		: out output_row;                               \n" +
    "		COLUMN_OUT	: out output_col;\n" +
    "		STATE		: in std_logic_vector(state_len downto 0);		--defines the bits num of each operation (00 - 1 bit (not), 01 - 2 bits, 10 - 3 bits, 11 - 4 bits)\n" +
    "		BITS_NUM 	: in std_logic_vector(num_of_bits downto 0);		--defines the bits num of each src\n" +
    "		COL_SRC1_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the first src \n" +
    "		COL_SRC2_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the second src\n" +
    "		COL_SRC3_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the third src \n" +
    "		COL_SRC4_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the fourth src\n" +
    "      		ROW_INIT_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the row of the first input\n" +
    "        	ROW_FIN_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the row of the last input\n" +
    "		COL_DEST_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the output \n" +
    "		CLK		: in std_logic\n" +
    "	);\n" +
    "\n" +
    "end ARITHMETIC_BLOCK;\n" +
    "\n" +
    "architecture arc_ARITHMETIC_BLOCK  of ARITHMETIC_BLOCK  is\n" +
    "\n" +
    "-------------------------------------------------------------------------------------------------------------------------------------------------------------\n" +
    "------------------------------------------------------------------------Components:--------------------------------------------------------------------------\n" +
    "-------------------------------------------------------------------------------------------------------------------------------------------------------------\n" +
    "\n" +
    "component ASYNC_TRUE is\n" +
    "	port(\n" +
    "		ROW_OUT			: out output_row;                               \n" +
    "		COLUMN_OUT		: out output_col;\n" +
    "		ENA			: in std_logic;				        --enable the work of the block\n" +
    "		BITS_NUM		: in std_logic_vector(num_of_bits downto 0);	--defines the number of the memristors on the column of Vw1 \n" +
    "		AREA1_ROW_INIT_ADDR	: in std_logic_vector(num_of_bits downto 0);	--defines the number of the first memristor in the row of the first area \n" +
    "		AREA1_ROW_FIN_ADDR	: in std_logic_vector(num_of_bits downto 0);	--defines the number of the last memristor in the row of the first area\n" +
    "		VW1_COL_INIT_ADDR	: in std_logic_vector(num_of_bits downto 0)	--defines the number of the first memristor in the column of Vw1\n" +
    "	);\n" +
    "end component;\n" +
    "\n" +
    "\n" +
    "component NOR_VEC is\n" +
    "	port (\n" +
    "		FINISH		: out std_logic;\n" +
    "		ROW_OUT		: out output_row;                               \n" +
    "		COLUMN_OUT	: out output_col;\n" +
    "		ENA		: in std_logic;					        --enable the work of the block\n" +
    "		STATE		: in std_logic_vector(state_len downto 0);		--defines the bits num of each operation (00 - 1 bit (not), 01 - 2 bits, 10 - 3 bits, 11 - 4 bits)\n" +
    "		BITS_NUM 	: in std_logic_vector(num_of_bits downto 0);		--defines the bits num of each src\n" +
    "		COL_SRC1_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the first src \n" +
    "		COL_SRC2_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the second src\n" +
    "		COL_SRC3_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the third src \n" +
    "		COL_SRC4_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the fourth src\n" +
    "      		ROW_INIT_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the row of the first input\n" +
    "	        ROW_FIN_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the row of the last input\n" +
    "		COL_DEST_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the output \n" +
    "		CLK		: in std_logic\n" +
    "	);\n" +
    "end component;\n" +
    "\n" +
    "\n" +
    "component NOT_VEC is\n" +
    "	port (\n" +
    "		FINISH		: out std_logic;\n" +
    "		ROW_OUT		: out output_row;                               \n" +
    "		COLUMN_OUT	: out output_col;\n" +
    "		ENA		: in std_logic;					        --enable the work of the block\n" +
    "		STATE		: in std_logic_vector(state_len downto 0);		--defines the bits num of each operation (00 - 1 bit (not), 01 - 2 bits, 10 - 3 bits, 11 - 4 bits)\n" +
    "		BITS_NUM 	: in std_logic_vector(num_of_bits downto 0);		--defines the bits num of each src\n" +
    "		COL_SRC1_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the first src \n" +
    "		COL_SRC2_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the second src\n" +
    "		COL_SRC3_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the third src \n" +
    "		COL_SRC4_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the fourth src\n" +
    "      		ROW_INIT_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the row of the first input\n" +
    "        	ROW_FIN_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the row of the last input\n" +
    "		COL_DEST_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the output \n" +
    "		CLK		: in std_logic\n" +
    "	);\n" +
    "end component;\n" +
    "\n" +
    "component AND_VEC is\n" +
    "	port (\n" +
    "		FINISH			: out std_logic;\n" +
    "		ROW_OUT			: out output_row;                               \n" +
    "		COLUMN_OUT		: out output_col;\n" +
    "		PROCESS_AREA_FINISH	: out std_logic_vector(num_of_bits downto 0);	--defines the col of the process area's end\n" +
    "		ENA			: in std_logic;				        --enable the work of the block\n" +
    "		STATE			: in std_logic_vector(state_len downto 0);	--defines the bits num of each operation (00 - 1 bit (not), 01 - 2 bits, 10 - 3 bits, 11 - 4 bits)\n" +
    "		BITS_NUM 		: in std_logic_vector(num_of_bits downto 0);	--defines the bits num of each src\n" +
    "		COL_SRC1_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the first src \n" +
    "		COL_SRC2_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the second src\n" +
    "		COL_SRC3_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the third src \n" +
    "		COL_SRC4_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the fourth src\n" +
    "      		ROW_INIT_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the row of the first input\n" +
    "        	ROW_FIN_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the row of the last input\n" +
    "		COL_DEST_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the output \n" +
    "		PROCESS_AREA_INIT	: in std_logic_vector(num_of_bits downto 0);	--defines the col of the process area's start\n" +
    "		CLK			: in std_logic\n" +
    "	);\n" +
    "end component;\n" +
    "\n" +
    "\n" +
    "component OR_VEC is\n" +
    "	port (\n" +
    "		FINISH			: out std_logic;\n" +
    "		ROW_OUT			: out output_row;                               \n" +
    "		COLUMN_OUT		: out output_col;\n" +
    "		PROCESS_AREA_FINISH	: out std_logic_vector(num_of_bits downto 0);	--defines the col of the process area's end\n" +
    "		ENA			: in std_logic;				        --enable the work of the block\n" +
    "		STATE			: in std_logic_vector(state_len downto 0);	--defines the bits num of each operation (00 - 1 bit (not), 01 - 2 bits, 10 - 3 bits, 11 - 4 bits)\n" +
    "		BITS_NUM 		: in std_logic_vector(num_of_bits downto 0);	--defines the bits num of each src\n" +
    "		COL_SRC1_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the first src \n" +
    "		COL_SRC2_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the second src\n" +
    "		COL_SRC3_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the third src \n" +
    "		COL_SRC4_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the fourth src\n" +
    "      		ROW_INIT_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the row of the first input\n" +
    "        	ROW_FIN_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the row of the last input\n" +
    "		COL_DEST_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the output \n" +
    "		PROCESS_AREA_INIT	: in std_logic_vector(num_of_bits downto 0);	--defines the col of the process area's start\n" +
    "		CLK			: in std_logic\n" +
    "	);\n" +
    "end component;\n" +
    "\n" +
    "\n" +
    "component NAND_VEC is\n" +
    "	port (\n" +
    "		FINISH			: out std_logic;\n" +
    "		ROW_OUT			: out output_row;                               \n" +
    "		COLUMN_OUT		: out output_col;\n" +
    "		PROCESS_AREA_FINISH	: out std_logic_vector(num_of_bits downto 0);	--defines the col of the process area's end\n" +
    "		ENA			: in std_logic;				        --enable the work of the block\n" +
    "		STATE			: in std_logic_vector(state_len downto 0);	--defines the bits num of each operation (00 - 1 bit (not), 01 - 2 bits, 10 - 3 bits, 11 - 4 bits)\n" +
    "		BITS_NUM 		: in std_logic_vector(num_of_bits downto 0);	--defines the bits num of each src\n" +
    "		COL_SRC1_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the first src \n" +
    "		COL_SRC2_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the second src\n" +
    "		COL_SRC3_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the third src \n" +
    "		COL_SRC4_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the fourth src\n" +
    "      		ROW_INIT_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the row of the first input\n" +
    "        	ROW_FIN_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the row of the last input\n" +
    "		COL_DEST_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the output \n" +
    "		PROCESS_AREA_INIT	: in std_logic_vector(num_of_bits downto 0);	--defines the col of the process area's start\n" +
    "		CLK			: in std_logic\n" +
    "	);\n" +
    "end component;\n" +
    "\n" +
    "\n" +
    "component XOR_VEC is\n" +
    "	port (\n" +
    "		FINISH			: out std_logic;\n" +
    "		ROW_OUT			: out output_row;                               \n" +
    "		COLUMN_OUT		: out output_col;\n" +
    "		PROCESS_AREA_FINISH	: out std_logic_vector(num_of_bits downto 0);	--defines the col of the process area's end\n" +
    "		ENA			: in std_logic;				        --enable the work of the block\n" +
    "		STATE			: in std_logic_vector(state_len downto 0);	--defines the bits num of each operation (00 - 1 bit (not), 01 - 2 bits, 10 - 3 bits, 11 - 4 bits)\n" +
    "		BITS_NUM 		: in std_logic_vector(num_of_bits downto 0);	--defines the bits num of each src\n" +
    "		COL_SRC1_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the first src \n" +
    "		COL_SRC2_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the second src\n" +
    "		COL_SRC3_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the third src \n" +
    "		COL_SRC4_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the fourth src\n" +
    "      		ROW_INIT_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the row of the first input\n" +
    "        	ROW_FIN_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the row of the last input\n" +
    "		COL_DEST_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the output \n" +
    "		PROCESS_AREA_INIT	: in std_logic_vector(num_of_bits downto 0);	--defines the col of the process area's start\n" +
    "		CLK			: in std_logic\n" +
    "	);\n" +
    "end component;\n" +
    "\n" +
    "\n" +
    "component Full_Adder is\n" +
    "	port (\n" +
    "		FINISH			: out std_logic;\n" +
    "		ROW_OUT			: out output_row;                               \n" +
    "		COLUMN_OUT		: out output_col;\n" +
    "		PROCESS_AREA_FINISH	: out std_logic_vector(num_of_bits downto 0);	--defines the col of the process area's end\n" +
    "		ENA			: in std_logic;				        --enable the work of the block\n" +
    "		STATE			: in std_logic_vector(state_len downto 0);	--defines the bits num of each operation (00 - 1 bit (not), 01 - 2 bits, 10 - 3 bits, 11 - 4 bits)\n" +
    "		COL_SRC1_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the first src \n" +
    "		COL_SRC2_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the second src\n" +
    "		COL_SRC3_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the third src \n" +
    "		COL_SRC4_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the fourth src\n" +
    "      		ROW_INIT_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the row of the first input\n" +
    "        	ROW_FIN_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the row of the last input\n" +
    "		COL_DEST_ADDR		: in std_logic_vector(num_of_bits downto 0);	--defines the column of the output \n" +
    "		PROCESS_AREA_INIT	: in std_logic_vector(num_of_bits downto 0);	--defines the col of the process area's start\n" +
    "		CLK			: in std_logic\n" +
    "	);\n" +
    "end component;\n" +
    "\n")
    
    
    for block in block_names:
        file.writelines(
        "component "+ block +" is\n" +
        "	port (\n" +
        "		FINISH			: out std_logic;\n" +
        "		ROW_OUT			: out output_row;\n" +
        "		COLUMN_OUT		: out output_col;\n" +
        "		PROCESS_AREA_FINISH	: out std_logic_vector(num_of_bits downto 0);\n" +
        "		ENA			: in std_logic;                                         --enable the work of the block\n" +
        "		COL_SRC_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the column of the first src \n" +
        "      		ROW_INIT_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the row of the first input\n" +
        "        	ROW_FIN_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the row of the last input\n" +
        "	        COL_DEST_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the column of the output \n" +
        "	        PROCESS_AREA_INIT	: in std_logic_vector(num_of_bits downto 0);  \n" +
        "		CLK			: in std_logic\n" +
        "	);\n" +
        "end component;\n")
    
    file.writelines(
    "\n" +
    "-------------------------------------------------------------------------------------------------------------------------------------------------------------\n" +
    "------------------------------------------------------------------------States:------------------------------------------------------------------------------\n" +
    "-------------------------------------------------------------------------------------------------------------------------------------------------------------\n" +
    "\n" +
    "type arithmetic_state is (reset_process_area_st, ena_operation, wait_st);\n" +
    "\n" +
    "-------------------------------------------------------------------------------------------------------------------------------------------------------------\n" +
    "-------------------------------------------------------------------------Signals:----------------------------------------------------------------------------\n" +
    "-------------------------------------------------------------------------------------------------------------------------------------------------------------\n" +
    "\n" +
    "---------------- ARITHMETIC BLOCK signals--------------------- \n" +
    "signal  arith_st		: arithmetic_state;\n" +
    "--registers to save the current operation and check if there is new operation\n" +
    "signal  opcode_reg              : std_logic_vector(opcode_len downto 0);\n" +
    "signal	bits_num_reg		: std_logic_vector(num_of_bits downto 0); \n" +
    "signal  src1_col_addr_reg	: std_logic_vector(num_of_bits downto 0); \n" +
    "signal  src2_col_addr_reg	: std_logic_vector(num_of_bits downto 0);\n" +
    "signal  src3_col_addr_reg	: std_logic_vector(num_of_bits downto 0); \n" +
    "signal  src4_col_addr_reg	: std_logic_vector(num_of_bits downto 0);\n" +
    "signal  row_init_addr_reg	: std_logic_vector(num_of_bits downto 0); \n" +
    "signal  row_fin_addr_reg	: std_logic_vector(num_of_bits downto 0); \n" +
    "signal  col_dest_addr_reg	: std_logic_vector(num_of_bits downto 0); \n" +
    "\n" +
    "--signals to save the src/dest locations\n" +
    "signal 	A_col			: std_logic_vector(num_of_bits downto 0); --A is the first src col \n" +
    "signal 	B_col			: std_logic_vector(num_of_bits downto 0); --B is the second src col\n" +
    "signal 	C_col			: std_logic_vector(num_of_bits downto 0); --C is the third src col	\n" +
    "signal 	D_col			: std_logic_vector(num_of_bits downto 0); --D is the fourth src col	\n" +
    "signal 	row_init		: std_logic_vector(num_of_bits downto 0);	        \n" +
    "signal 	row_finish		: std_logic_vector(num_of_bits downto 0);	\n" +
    "signal 	col_dest		: std_logic_vector(num_of_bits downto 0);	\n" +
    "\n" +
    "signal  bits_num_signal		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal  counter			: std_logic_vector(num_of_bits downto 0);\n" +
    "signal  state_signal		: std_logic_vector(state_len downto 0);\n" +
    "\n" +
    "--processing area signals\n" +
    "signal  proccess_area_signal			: std_logic_vector(num_of_bits downto 0); --current location that is valid in the processing area\n" +
    "signal  process_area_row_init_reg		: std_logic_vector(num_of_bits downto 0); --the first row of the processing area\n" +
    "signal  process_area_row_fin_reg		: std_logic_vector(num_of_bits downto 0); --the last row of the processing area\n" +
    "signal  process_area_bits_num_reg		: std_logic_vector(num_of_bits downto 0); --the column num of the processing area\n" +
    "signal  process_area_col_init_reg		: std_logic_vector(num_of_bits downto 0); --the first column of the processing area\n" +
    "signal  process_area_col_finish_reg		: std_logic_vector(num_of_bits downto 0); --the last column of the processing area\n" +
    "\n" +
    "--------------------- ASYNC_TRUE signals----------------------------   							\n" +
    "signal col_init_true		: std_logic_vector(num_of_bits downto 0);             \n" +
    "signal row_init_true		: std_logic_vector(num_of_bits downto 0);             \n" +
    "signal row_fin_true		: std_logic_vector(num_of_bits downto 0);             \n" +
    "signal ena_true			: std_logic;\n" +
    "signal bits_num_true		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal flag_true		: std_logic:='0';\n" +
    "signal row_out_true		: output_row;\n" +
    "signal col_out_true		: output_col;\n" +
    "\n" +
    "\n" +
    "--------------------------NOR signals-------------------------\n" +
    "signal src1_col_nor		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src2_col_nor		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal src3_col_nor		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src4_col_nor		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_init_nor		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_fin_nor		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal col_dest_nor		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal bit_num_nor		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal state_nor		: std_logic_vector(state_len downto 0);\n" +
    "signal finish_nor		: std_logic;\n" +
    "signal row_out_nor		: output_row;\n" +
    "signal col_out_nor		: output_col;\n" +
    "signal ena_nor			: std_logic;\n" +
    "\n" +
    "\n" +
    "--------------------------NOT signals-------------------------\n" +
    "signal src1_col_not		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src2_col_not		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal src3_col_not		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src4_col_not		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_init_not		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_fin_not		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal col_dest_not		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal bit_num_not		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal state_not		: std_logic_vector(state_len downto 0);\n" +
    "signal finish_not		: std_logic;\n" +
    "signal row_out_not		: output_row;\n" +
    "signal col_out_not		: output_col;\n" +
    "signal ena_not			: std_logic;\n" +
    "\n" +
    "\n" +
    "--------------------------AND signals-------------------------  \n" +
    "signal src1_col_and		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src2_col_and		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal src3_col_and		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src4_col_and		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_init_and		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_fin_and		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal col_dest_and		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal proccess_area_in_and	: std_logic_vector(num_of_bits downto 0);\n" +
    "signal proccess_area_out_and	: std_logic_vector(num_of_bits downto 0);\n" +
    "signal bit_num_and		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal state_and		: std_logic_vector(state_len downto 0);\n" +
    "signal finish_and		: std_logic;\n" +
    "signal row_out_and		: output_row;\n" +
    "signal col_out_and		: output_col;\n" +
    "signal ena_and			: std_logic;\n" +
    "\n" +
    "\n" +
    "--------------------------OR signals-------------------------          \n" +
    "signal src1_col_or		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src2_col_or		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal src3_col_or		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src4_col_or		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_init_or		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_fin_or		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal col_dest_or		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal proccess_area_in_or	: std_logic_vector(num_of_bits downto 0);\n" +
    "signal proccess_area_out_or	: std_logic_vector(num_of_bits downto 0);\n" +
    "signal bit_num_or		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal state_or			: std_logic_vector(state_len downto 0);\n" +
    "signal finish_or		: std_logic;\n" +
    "signal row_out_or		: output_row;\n" +
    "signal col_out_or		: output_col;\n" +
    "signal ena_or			: std_logic;\n" +
    "\n" +
    "\n" +
    "--------------------------NAND signals-------------------------       \n" +
    "signal src1_col_nand		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src2_col_nand		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal src3_col_nand		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src4_col_nand		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_init_nand		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_fin_nand		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal col_dest_nand		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal bit_num_nand		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal proccess_area_in_nand	: std_logic_vector(num_of_bits downto 0);\n" +
    "signal proccess_area_out_nand	: std_logic_vector(num_of_bits downto 0);\n" +
    "signal state_nand		: std_logic_vector(state_len downto 0);\n" +
    "signal finish_nand		: std_logic;\n" +
    "signal row_out_nand		: output_row;\n" +
    "signal col_out_nand		: output_col;\n" +
    "signal ena_nand			: std_logic;\n" +
    "\n" +
    "\n" +
    "--------------------------XOR signals-------------------------       \n" +
    "signal src1_col_xor		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src2_col_xor		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal src3_col_xor		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src4_col_xor		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_init_xor		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_fin_xor		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal col_dest_xor		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal bit_num_xor		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal proccess_area_in_xor	: std_logic_vector(num_of_bits downto 0);\n" +
    "signal proccess_area_out_xor	: std_logic_vector(num_of_bits downto 0);\n" +
    "signal state_xor		: std_logic_vector(state_len downto 0);\n" +
    "signal finish_xor		: std_logic;\n" +
    "signal row_out_xor		: output_row;\n" +
    "signal col_out_xor		: output_col;\n" +
    "signal ena_xor			: std_logic;\n" +
    "\n" +
    "----------------------FULL ADDER signals-----------------------       \n" +
    "signal src1_col_fa		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src2_col_fa		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal src3_col_fa		: std_logic_vector(num_of_bits downto 0);            \n" +
    "signal src4_col_fa		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_init_fa		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal row_fin_fa		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal col_dest_fa		: std_logic_vector(num_of_bits downto 0);\n" +
    "signal proccess_area_in_fa	: std_logic_vector(num_of_bits downto 0);\n" +
    "signal proccess_area_out_fa	: std_logic_vector(num_of_bits downto 0);\n" +
    "signal state_fa			: std_logic_vector(state_len downto 0);\n" +
    "signal finish_fa		: std_logic;\n" +
    "signal row_out_fa		: output_row;\n" +
    "signal col_out_fa		: output_col;\n" +
    "signal ena_fa			: std_logic;\n" +
    "\n" )
    
    for block in block_names:
        file.writelines(
        "----------------------"+block+" signals-----------------------       \n" +
        "signal finish_"+block+"		: std_logic;\n" +
        "signal row_out_"+block+"		: output_row;\n" +
        "signal col_out_"+block+"		: output_col;\n" +
        "signal processing_area_out_"+block+"   : std_logic_vector(num_of_bits downto 0);\n" +
        "signal ena_"+block+"			: std_logic;\n" +
        "signal src_col_"+block+"		: std_logic_vector(num_of_bits downto 0);\n" +
        "signal row_init_"+block+"		: std_logic_vector(num_of_bits downto 0);\n" +
        "signal row_fin_"+block+"		: std_logic_vector(num_of_bits downto 0);\n" +
        "signal col_dest_"+block+"		: std_logic_vector(num_of_bits downto 0);\n" +
        "signal processing_area_in_"+block+"	: std_logic_vector(num_of_bits downto 0);\n")
        
    file.writelines(   
    "-------------------------------------------------------------------------------------------------------------------------------------------------------------\n" +
    "-------------------------------------------------------------------------Port maps:--------------------------------------------------------------------------\n" +
    "-------------------------------------------------------------------------------------------------------------------------------------------------------------\n" +
    "\n" +
    "begin\n" +
    "\n" +
    "async_true_u0: ASYNC_TRUE\n" +
    "	port map(\n" +
    "		ROW_OUT         	=> row_out_true, \n" +
    "		COLUMN_OUT      	=> col_out_true,\n" +
    "		ENA             	=> ena_true,\n" +
    "		BITS_NUM        	=> bits_num_true,\n" +
    "		AREA1_ROW_INIT_ADDR 	=> row_init_true,\n" +
    "		AREA1_ROW_FIN_ADDR  	=> row_fin_true,\n" +
    "		VW1_COL_INIT_ADDR   	=> col_init_true\n" +
    "	);\n" +
    "\n" +
    "nor_u0: NOR_VEC\n" +
    "	port map(\n" +
    "		FINISH			=> finish_nor,  \n" +
    "		ROW_OUT			=> row_out_nor,\n" +
    "		COLUMN_OUT		=> col_out_nor,\n" +
    "		\n" +
    "		ENA			=> ena_nor,\n" +
    "		STATE			=> state_nor,\n" +
    "		BITS_NUM		=> bit_num_nor,\n" +
    "		COL_SRC1_ADDR		=> src1_col_nor,\n" +
    "		COL_SRC2_ADDR		=> src2_col_nor,\n" +
    "		COL_SRC3_ADDR		=> src3_col_nor,\n" +
    "		COL_SRC4_ADDR		=> src4_col_nor,\n" +
    "		ROW_INIT_ADDR		=> row_init_nor,\n" +
    "		ROW_FIN_ADDR		=> row_fin_nor,\n" +
    "		COL_DEST_ADDR		=> col_dest_nor,\n" +
    "		\n" +
    "		CLK			=> CLK\n" +
    "	);\n" +
    "\n" +
    "and_u0: AND_VEC\n" +
    "	port map(\n" +
    "		FINISH			=> finish_and,  \n" +
    "		ROW_OUT			=> row_out_and,\n" +
    "		COLUMN_OUT		=> col_out_and,\n" +
    "		PROCESS_AREA_FINISH	=> proccess_area_out_and,\n" +
    "		ENA			=> ena_and,\n" +
    "		STATE			=> state_and,\n" +
    "		BITS_NUM		=> bit_num_and,\n" +
    "		COL_SRC1_ADDR		=> src1_col_and,\n" +
    "		COL_SRC2_ADDR		=> src2_col_and,\n" +
    "		COL_SRC3_ADDR		=> src3_col_and,\n" +
    "		COL_SRC4_ADDR		=> src4_col_and,\n" +
    "		ROW_INIT_ADDR		=> row_init_and,\n" +
    "		ROW_FIN_ADDR		=> row_fin_and,\n" +
    "		COL_DEST_ADDR		=> col_dest_and,\n" +
    "		PROCESS_AREA_INIT	=> proccess_area_in_and,\n" +
    "		CLK			=> CLK\n" +
    "	);\n" +
    "\n" +
    "or_u0: OR_VEC\n" +
    "	port map(\n" +
    "		FINISH			=> finish_or,  \n" +
    "		ROW_OUT			=> row_out_or,\n" +
    "		COLUMN_OUT		=> col_out_or,\n" +
    "		PROCESS_AREA_FINISH	=> proccess_area_out_or,\n" +
    "		ENA			=> ena_or,\n" +
    "		STATE			=> state_or,\n" +
    "		BITS_NUM		=> bit_num_or,\n" +
    "		COL_SRC1_ADDR		=> src1_col_or,\n" +
    "		COL_SRC2_ADDR		=> src2_col_or,\n" +
    "		COL_SRC3_ADDR		=> src3_col_or,\n" +
    "		COL_SRC4_ADDR		=> src4_col_or,\n" +
    "		ROW_INIT_ADDR		=> row_init_or,\n" +
    "		ROW_FIN_ADDR		=> row_fin_or,\n" +
    "		COL_DEST_ADDR		=> col_dest_or,\n" +
    "		PROCESS_AREA_INIT	=> proccess_area_in_or,\n" +
    "		CLK			=> CLK\n" +
    "	);\n" +
    "\n" +
    "nand_u0: NAND_VEC\n" +
    "	port map(\n" +
    "		FINISH			=> finish_nand,  \n" +
    "		ROW_OUT			=> row_out_nand,\n" +
    "		COLUMN_OUT		=> col_out_nand,\n" +
    "		PROCESS_AREA_FINISH	=> proccess_area_out_nand,\n" +
    "		ENA			=> ena_nand,\n" +
    "		STATE			=> state_nand,\n" +
    "		BITS_NUM		=> bit_num_nand,\n" +
    "		COL_SRC1_ADDR		=> src1_col_nand,\n" +
    "		COL_SRC2_ADDR		=> src2_col_nand,\n" +
    "		COL_SRC3_ADDR		=> src3_col_nand,\n" +
    "		COL_SRC4_ADDR		=> src4_col_nand,\n" +
    "		ROW_INIT_ADDR		=> row_init_nand,\n" +
    "		ROW_FIN_ADDR		=> row_fin_nand,\n" +
    "		COL_DEST_ADDR		=> col_dest_nand,\n" +
    "		PROCESS_AREA_INIT	=> proccess_area_in_nand,\n" +
    "		CLK			=> CLK\n" +
    "	);\n" +
    "	\n" +
    "not_u0: NOT_VEC\n" +
    "	port map(\n" +
    "		FINISH			=> finish_not,  \n" +
    "		ROW_OUT			=> row_out_not,\n" +
    "		COLUMN_OUT		=> col_out_not,\n" +
    "		ENA			=> ena_not,\n" +
    "		STATE			=> state_not,\n" +
    "		BITS_NUM		=> bit_num_not,\n" +
    "		COL_SRC1_ADDR		=> src1_col_not,\n" +
    "		COL_SRC2_ADDR		=> src2_col_not,\n" +
    "		COL_SRC3_ADDR		=> src3_col_not,\n" +
    "		COL_SRC4_ADDR		=> src4_col_not,\n" +
    "		ROW_INIT_ADDR		=> row_init_not,\n" +
    "		ROW_FIN_ADDR		=> row_fin_not,\n" +
    "		COL_DEST_ADDR		=> col_dest_not,\n" +
    "		CLK			=> CLK\n" +
    "	);\n" +
    "\n" +
    "\n" +
    "xor_u0: XOR_VEC\n" +
    "	port map(\n" +
    "		FINISH			=> finish_xor,\n" +
    "		ROW_OUT			=> row_out_xor,                       \n" +
    "		COLUMN_OUT		=> col_out_xor,\n" +
    "		PROCESS_AREA_FINISH	=> proccess_area_out_xor,\n" +
    "		ENA			=> ena_xor,\n" +
    "		STATE			=> state_xor,\n" +
    "		BITS_NUM		=> bit_num_xor,\n" +
    "		COL_SRC1_ADDR		=> src1_col_xor, \n" +
    "		COL_SRC2_ADDR		=> src2_col_xor,\n" +
    "		COL_SRC3_ADDR		=> src3_col_xor,\n" +
    "		COL_SRC4_ADDR		=> src4_col_xor,\n" +
    "      		ROW_INIT_ADDR		=> row_init_xor,\n" +
    "        	ROW_FIN_ADDR		=> row_fin_xor,\n" +
    "		COL_DEST_ADDR		=> col_dest_xor,\n" +
    "		PROCESS_AREA_INIT	=> proccess_area_in_xor,\n" +
    "		CLK			=> CLK\n" +
    "	);\n" +
    "\n" +
    "fa_u0: Full_Adder\n" +
    "	port map(\n" +
    "		FINISH			=> finish_fa,\n" +
    "		ROW_OUT			=> row_out_fa,                       \n" +
    "		COLUMN_OUT		=> col_out_fa,\n" +
    "		PROCESS_AREA_FINISH	=> proccess_area_out_fa,\n" +
    "		ENA			=> ena_fa,\n" +
    "		STATE			=> state_fa,\n" +
    "		COL_SRC1_ADDR		=> src1_col_fa, \n" +
    "		COL_SRC2_ADDR		=> src2_col_fa,\n" +
    "		COL_SRC3_ADDR		=> src3_col_fa,\n" +
    "		COL_SRC4_ADDR		=> src4_col_fa,\n" +
    "      		ROW_INIT_ADDR		=> row_init_fa,\n" +
    "        	ROW_FIN_ADDR		=> row_fin_fa,\n" +
    "		COL_DEST_ADDR		=> col_dest_fa,\n" +
    "		PROCESS_AREA_INIT	=> proccess_area_in_fa,\n" +
    "		CLK			=> CLK\n" +
    "	);\n" +
    "\n")
    
    
    for block in block_names:
        file.writelines(
        "------------------------------------------"+block + "---------------------------------------\n" +
        block+"_u0: "+ block+"\n" +
        "	port map(\n" +
        "		FINISH			=> finish_"+ block+",\n" +
        "		ROW_OUT			=> row_out_"+ block+",\n" +
        "		COLUMN_OUT		=> col_out_"+ block+",\n" +
        "		PROCESS_AREA_FINISH	=> processing_area_out_"+ block+",\n" +
        "		ENA			=> ena_"+ block+",\n" +
        "      		COL_SRC_ADDR		=> src_col_"+ block+",\n" +
        "      		ROW_INIT_ADDR		=> row_init_"+ block+",\n" +
        "        	ROW_FIN_ADDR		=> row_fin_"+ block+",\n" +
        "        	COL_DEST_ADDR		=> col_dest_"+ block+",\n" +
        "        	PROCESS_AREA_INIT	=> processing_area_in_"+ block+",\n" +

        "		CLK			=> CLK\n" +
        "	);\n" +
        "	\n")
        
        
    file.writelines(
    "-------------------------------------------------------------------------------------------------------------------------------------------------------------\n" +
    "-------------------------------------------------------------------------Process:----------------------------------------------------------------------------\n" +
    "-------------------------------------------------------------------------------------------------------------------------------------------------------------\n" +
    "\n" +
    "process(CLK)\n" +
    "\n" +
    "	begin			\n" +
    "		if rising_edge(CLK) then\n" +
    "			--initial signals\n" +
    "			ROW_OUT 	<= (others => floating);\n" +
    "			COLUMN_OUT  	<= (others => floating);\n" +
    "			FINISH      	<= '0';\n" +
    "			\n" +
    "			if (OPERATION_TYPE = \"00\") then --if the operation type is arithmetic\n" +
    "\n" +
    "				if (OPCODE = \"00000000\") then --Reset\n" +
    "					ROW_OUT 	<= (others => floating);\n" +
    "					COLUMN_OUT  	<= (others => floating);\n" +
    "				else\n" +
    "					case arith_st is\n" +
    "					\n" +
    "					when reset_process_area_st => --Sets processing area to '1'\n" +
    "							\n" +
    "							if (OPCODE = \"00000001\") then --reset process area\n" +
    "								process_area_bits_num_reg	<= \""+ num2binary(processing_area_size, num_of_bits) +"\";\n" +
    "								process_area_row_init_reg	<= ROW_INIT_ADDR;\n" +
    "								process_area_row_fin_reg	<= ROW_FIN_ADDR;\n" +
    "								process_area_col_init_reg	<= \""+ num2binary(processing_area_init, num_of_bits) +"\";\n" +
    "								process_area_col_finish_reg	<= \""+ num2binary(processing_area_init + processing_area_size, num_of_bits) +"\";\n" +
    "								proccess_area_signal		<= \""+ num2binary(processing_area_init, num_of_bits) +"\";\n" +
    "								--true\n" +
    "								col_init_true		<= \""+ num2binary(processing_area_init, num_of_bits) +"\";\n" +
    "								bits_num_true		<= \""+ num2binary(processing_area_size, num_of_bits) +"\";\n" +
    "								ena_true 		<= '1';\n" +
    "								flag_true 		<= '1';\n" +
    "								row_init_true		<= ROW_INIT_ADDR;\n" +
    "								row_fin_true		<= ROW_FIN_ADDR;\n" +
    "								ROW_OUT			<= row_out_true; -- check it\n" +
    "								COLUMN_OUT		<= col_out_true;\n" +
    "								FINISH			<= '1';\n" +
    "								arith_st 		<= reset_process_area_st;\n" +
    "							else	--start initial operation's signals\n" +
    "								--save current operation\n" +
    "								arith_st 	 	<= ena_operation;\n" +
    "								opcode_reg 		<= OPCODE;\n" +
    "								bits_num_reg 		<= ROW_FIN_ADDR-ROW_INIT_ADDR;\n" +
    "								src1_col_addr_reg 	<= COL_SRC1_ADDR;\n" +
    "								src2_col_addr_reg 	<= COL_SRC2_ADDR;\n" +
    "								src3_col_addr_reg 	<= COL_SRC3_ADDR;\n" +
    "								src4_col_addr_reg 	<= COL_SRC4_ADDR;\n" +
    "								row_init_addr_reg 	<= ROW_INIT_ADDR;\n" +
    "								row_fin_addr_reg 	<= ROW_FIN_ADDR;\n" +
    "								col_dest_addr_reg 	<= COL_DEST_ADDR;\n" +
    "\n" +
    "								--initial operation signals\n" +
    "								state_signal		<= STATE;\n" +
    "								bits_num_signal		<= BITS_NUM;\n" +
    "								A_col  			<= COL_SRC1_ADDR;\n" +
    "								B_col  			<= COL_SRC2_ADDR;\n" +
    "								C_col  			<= COL_SRC3_ADDR;\n" +
    "								D_col  			<= COL_SRC4_ADDR;\n" +
    "								row_init  		<= ROW_INIT_ADDR;\n" +
    "								row_finish  		<= ROW_FIN_ADDR;\n" +
    "								col_dest		<= COL_DEST_ADDR;\n" +
    "								\n" +
    "								counter 		<= \""+ num2binary(counter, num_of_bits) +"\";\n" +
    "\n" +
    "								--disable all operations\n" +
    "								ena_nor <= '0';\n" +
    "								ena_and <= '0';\n" +
    "								ena_or <= '0';\n" +
    "								ena_not <= '0';\n" +
    "								ena_nand <= '0';\n" +
    "								ena_xor <= '0';\n" +
    "								ena_fa <= '0';\n")
    
    for block in block_names:
        file.writelines(
    "								ena_"+block+" <= '0'; \n" )
    file.writelines(
    "							end if;\n" +
    "					\n" +
    "						when ena_operation =>\n" +
    "							--stop reset processing area\n" +
    "							ena_true <= '0';\n" +
    "\n" +
    "							case OPCODE  is\n" +
    "								--nor	\n" +
    "								when \"00000110\"=> \n" +
    "										--defines who controls the output\n" +
    "										if (flag_true = '1') then\n" +
    "											ROW_OUT		<= row_out_true;\n" +
    "											COLUMN_OUT	<= col_out_true;\n" +
    "											flag_true 	<= '0';\n" +
    "										else\n" +
    "											ROW_OUT		<= row_out_nor;\n" +
    "											COLUMN_OUT	<= col_out_nor;\n" +
    "										end if;\n" +
    "										--start operation\n" +
    "										if ena_nor = '0' then\n" +
    "											ena_nor	<= '1';\n" +
    "											state_nor	<= state_signal;\n" +
    "											bit_num_nor	<= bits_num_signal;\n" +
    "											src1_col_nor	<= A_col;\n" +
    "											src2_col_nor	<= B_col;\n" +
    "											src3_col_nor	<= C_col;\n" +
    "											src4_col_nor	<= D_col;\n" +
    "											col_dest_nor	<= col_dest;\n" +
    "											row_init_nor	<= row_init;\n" +
    "											row_fin_nor	<= row_finish;\n" +
    "										--wait to finish\n" +
    "										elsif finish_nor = '1' then\n" +
    "											ena_nor		<= '0';\n" +
    "											FINISH		<= '1';\n" +
    "											arith_st	<= wait_st;\n" +
    "										end if;\n" +
    "									\n" +
    "								--and\n" +
    "								when \"00000011\"=>\n" +
    "										--defines who controls the output\n" +
    "										if (flag_true = '1') then\n" +
    "											ROW_OUT		<= row_out_true;\n" +
    "											COLUMN_OUT	<= col_out_true;\n" +
    "											flag_true 	<= '0';\n" +
    "										else\n" +
    "											ROW_OUT		<= row_out_and;\n" +
    "											COLUMN_OUT	<= col_out_and;\n" +
    "										end if;\n" +
    "										--start operation\n" +
    "										if ena_and = '0' then\n" +
    "											ena_and		<= '1';\n" +
    "											state_and	<= state_signal;\n" +
    "											bit_num_and	<= bits_num_signal;\n" +
    "											src1_col_and	<= A_col;\n" +
    "											src2_col_and	<= B_col;\n" +
    "											src3_col_and	<= C_col;\n" +
    "											src4_col_and	<= D_col;\n" +
    "											col_dest_and	<= col_dest;\n" +
    "											row_init_and	<= row_init;\n" +
    "											row_fin_and	<= row_finish;\n" +
    "											if (process_area_col_finish_reg  > (proccess_area_signal + (state_signal + 1 )*bits_num_signal) ) then\n" +
    "												proccess_area_in_and <= proccess_area_signal;\n" +
    "											else\n" +
    "												-- assert - result memristor wasnt initalized to '1'\n" +
    "												assert false report \"Proccessing area is invalid\" severity warning;\n" +
    "											end if;\n" +
    "										--wait to finish\n" +
    "										elsif finish_and = '1' then\n" +
    "											ena_and		<= '0';\n" +
    "											FINISH		<= '1';\n" +
    "											arith_st	<= wait_st;\n" +
    "											proccess_area_signal <= proccess_area_out_and;\n" +
    "										end if;\n" +
    "								--or\n" +
    "								when \"00000101\"=>\n" +
    "										--defines who controls the output\n" +
    "										if (flag_true = '1') then\n" +
    "											ROW_OUT		<= row_out_true;\n" +
    "											COLUMN_OUT	<= col_out_true;\n" +
    "											flag_true 	<= '0';\n" +
    "										else\n" +
    "											ROW_OUT		<= row_out_or;\n" +
    "											COLUMN_OUT	<= col_out_or;\n" +
    "										end if;\n" +
    "										--start operation\n" +
    "										if ena_or = '0' then\n" +
    "											ena_or		<= '1';\n" +
    "											state_or	<= state_signal;\n" +
    "											bit_num_or	<= bits_num_signal;\n" +
    "											src1_col_or	<= A_col;\n" +
    "											src2_col_or	<= B_col;\n" +
    "											src3_col_or	<= C_col;\n" +
    "											src4_col_or	<= D_col;\n" +
    "											col_dest_or	<= col_dest;\n" +
    "											row_init_or	<= row_init;\n" +
    "											row_fin_or	<= row_finish;\n" +
    "											if (process_area_col_finish_reg  > (proccess_area_signal + bits_num_signal) ) then\n" +
    "												proccess_area_in_or <= proccess_area_signal;\n" +
    "											else\n" +
    "												-- assert - result memristor wasnt initalized to '1'\n" +
    "												assert false report \"Proccessing area is invalid\" severity warning;\n" +
    "											end if;\n" +
    "										--wait to finish\n" +
    "										elsif finish_or = '1' then\n" +
    "											ena_or		<= '0';\n" +
    "											FINISH		<= '1';\n" +
    "											arith_st 	<= wait_st;\n" +
    "											proccess_area_signal <= proccess_area_out_or;\n" +
    "										end if;\n" +
    "\n" +
    "								--not\n" +
    "								when \"00000010\"=>\n" +
    "										--defines who controls the output\n" +
    "										if (flag_true = '1') then\n" +
    "											ROW_OUT		<= row_out_true;\n" +
    "											COLUMN_OUT	<= col_out_true;\n" +
    "											flag_true 	<= '0';\n" +
    "										else\n" +
    "											ROW_OUT		<= row_out_not;\n" +
    "											COLUMN_OUT	<= col_out_not;\n" +
    "										end if;\n" +
    "										--start operation\n" +
    "										if ena_not = '0' then\n" +
    "											ena_not		<= '1';\n" +
    "											state_not	<= state_signal;\n" +
    "											bit_num_not	<= bits_num_signal;				\n" +
    "											src1_col_not	<= A_col;\n" +
    "											src2_col_not	<= B_col;\n" +
    "											src3_col_not	<= C_col;\n" +
    "											src4_col_not	<= D_col;\n" +
    "											col_dest_not	<= col_dest;\n" +
    "											row_init_not	<= row_init;\n" +
    "											row_fin_not	<= row_finish;\n" +
    "										--start operation\n" +
    "										elsif finish_not = '1' then\n" +
    "											ena_not		<= '0';\n" +
    "											FINISH		<= '1';\n" +
    "											arith_st 	<= wait_st;\n" +
    "										end if;\n" +
    "\n" +
    "								--nand\n" +
    "								when \"00000100\"=> \n" +
    "										--defines who controls the output\n" +
    "										if (flag_true = '1') then\n" +
    "											ROW_OUT		<= row_out_true;\n" +
    "											COLUMN_OUT	<= col_out_true;\n" +
    "											flag_true 	<= '0';\n" +
    "										else\n" +
    "											ROW_OUT		<= row_out_nand;\n" +
    "											COLUMN_OUT	<= col_out_nand;\n" +
    "										end if;\n" +
    "										--start operation\n" +
    "										if ena_nand = '0' then\n" +
    "											ena_nand	<= '1';\n" +
    "											state_nand	<= state_signal;\n" +
    "											bit_num_nand	<= bits_num_signal;\n" +
    "											src1_col_nand	<= A_col;\n" +
    "											src2_col_nand	<= B_col;\n" +
    "											src3_col_nand	<= C_col;\n" +
    "											src4_col_nand	<= D_col;\n" +
    "											col_dest_nand	<= col_dest;\n" +
    "											row_init_nand	<= row_init;\n" +
    "											row_fin_nand	<= row_finish;\n" +
    "											if (process_area_col_finish_reg  > (proccess_area_signal + (state_signal + 2 )*bits_num_signal) ) then\n" +
    "												proccess_area_in_nand <= proccess_area_signal;\n" +
    "											else\n" +
    "												-- assert - result memristor wasnt initalized to '1'\n" +
    "												assert false report \"Proccessing area is invalid\" severity warning;\n" +
    "											end if;\n" +
    "										--wait to finish\n" +
    "										elsif finish_nand = '1' then\n" +
    "											ena_and		<= '0';\n" +
    "											FINISH		<= '1';\n" +
    "											arith_st 	<= wait_st;\n" +
    "											proccess_area_signal <= proccess_area_out_nand;\n" +
    "										end if;\n" +
    "\n" +
    "								--xor\n" +
    "								when \"00000111\"=> 	\n" +
    "										--defines who controls the output\n" +
    "										if (flag_true = '1') then\n" +
    "											ROW_OUT		<= row_out_true;\n" +
    "											COLUMN_OUT	<= col_out_true;\n" +
    "											flag_true 	<= '0';\n" +
    "										else\n" +
    "											ROW_OUT		<= row_out_xor;\n" +
    "											COLUMN_OUT	<= col_out_xor;\n" +
    "										end if;\n" +
    "										--start operation\n" +
    "										if ena_xor = '0' then\n" +
    "											ena_xor		<= '1';\n" +
    "											state_xor	<= state_signal;\n" +
    "											bit_num_xor	<= bits_num_signal;\n" +
    "											src1_col_xor	<= A_col;\n" +
    "											src2_col_xor	<= B_col;\n" +
    "											src3_col_xor	<= C_col;\n" +
    "											src4_col_xor	<= D_col;\n" +
    "											col_dest_xor	<= col_dest;\n" +
    "											row_init_xor	<= row_init;\n" +
    "											row_fin_xor	<= row_finish;\n" +
    "											if (process_area_col_finish_reg  > (proccess_area_signal + conv_std_logic_vector(4,9)*bits_num_signal) ) then\n" +
    "												proccess_area_in_xor <= proccess_area_signal;\n" +
    "											else\n" +
    "												-- assert - result memristor wasnt initalized to '1'\n" +
    "												assert false report \"Proccessing area is invalid\" severity warning;\n" +
    "											end if;\n" +
    "										--wait to finish\n" +
    "										elsif finish_xor = '1' then\n" +
    "											ena_xor		<= '0';\n" +
    "											FINISH		<= '1';\n" +
    "											arith_st 	<= wait_st;\n" +
    "											proccess_area_signal 	<= proccess_area_out_xor;\n" +
    "										end if;\n" +
    "									\n" +
    "								--full adder\n" +
    "								when \"10000001\"=>\n" +
    "										--defines who controls the output\n" +
    "										if (flag_true = '1') then\n" +
    "											ROW_OUT		<= row_out_true;\n" +
    "											COLUMN_OUT	<= col_out_true;\n" +
    "											flag_true 	<= '0';\n" +
    "										else\n" +
    "											ROW_OUT		<= row_out_fa;\n" +
    "											COLUMN_OUT	<= col_out_fa;\n" +
    "										end if;\n" +
    "										--start operation\n" +
    "										if ena_fa = '0' then\n" +
    "											ena_fa	<= '1';\n" +
    "											state_fa	<= state_signal;\n" +
    "\n" +
    "											src1_col_fa	<= A_col;\n" +
    "											src2_col_fa	<= B_col;\n" +
    "											src3_col_fa	<= C_col;\n" +
    "											src4_col_fa	<= D_col;\n" +
    "											col_dest_fa	<= col_dest;\n" +
    "											row_init_fa	<= row_init;\n" +
    "											row_fin_fa	<= row_finish;\n" +
    "											if (process_area_col_finish_reg  > (proccess_area_signal + 12 )) then\n" +
    "												proccess_area_in_fa <= proccess_area_signal;\n" +
    "											else\n" +
    "												-- assert - result memristor wasnt initalized to '1'\n" +
    "												assert false report \"Proccessing area is invalid\" severity warning;\n" +
    "											end if;\n" +
    "										--wait to finish										\n" +
    "										elsif finish_fa = '1' then\n" +
    "											ena_fa		<= '0';\n" +
    "											FINISH		<= '1';\n" +
    "											arith_st 	<= wait_st;\n" +
    "											proccess_area_signal <= proccess_area_out_fa;										\n" +
    "										end if;\n" +
    "										\n")
    
    for i in range(len(block_names)):
        file.writelines(
    "								--"+block_names[i]+"\n" +
    "								when \""+opcodes[i]+"\"=>\n" +
    "										--defines who controls the output\n" +
    "										ROW_OUT		<= row_out_"+block_names[i]+";\n" +
    "										COLUMN_OUT	<= col_out_"+block_names[i]+";\n" +
    "										--start operation\n" +
    "										if ena_"+block_names[i]+" = '0' then\n" +
    "											ena_"+block_names[i]+"	<= '1';\n" +
    "											src_col_"+block_names[i]+"	<= A_col;\n" +   
    "											col_dest_"+block_names[i]+"	<= col_dest;\n" +   
    "											row_init_"+block_names[i]+"	<= row_init;\n" +
    "											row_fin_"+block_names[i]+"	<= row_finish;\n" +
    "											if (process_area_col_finish_reg  > (proccess_area_signal + "+block_names[i].split("_")[-1]+" )) then\n" + 
    "						                                                      processing_area_in_"+block_names[i]+" <= proccess_area_signal;\n"+ 
    "											else\n"+ 
    "											              -- assert - result memristor wasnt initalized to '1'\n"+ 
    "											              assert false report \"Proccessing area is invalid\" severity warning;\n"+ 
    "											end if;\n"+ 
    "										--wait to finish										\n" +
    "										elsif finish_"+block_names[i]+" = '1' then\n" +
    "											ena_"+block_names[i]+"		<= '0';\n" +
    "											FINISH		<= '1';\n" +
    "											arith_st 	<= wait_st;\n" +
    "											proccess_area_signal <= processing_area_out_"+block_names[i]+";\n "+									
    "										end if;\n" +
    "\n" )
    file.writelines(
    "								when others => 	NULL;       \n" +
    "							end case;\n" +
    "\n" +
    "					when wait_st => --waiting for new command\n" +
    "						if (OPCODE /= opcode_reg) or ((ROW_FIN_ADDR-ROW_INIT_ADDR) /= bits_num_reg) or \n" +
    "							(ROW_INIT_ADDR /= row_init_addr_reg) or (ROW_FIN_ADDR /= row_fin_addr_reg) or \n" +
    "							(COL_SRC1_ADDR /= src1_col_addr_reg) or (COL_SRC2_ADDR /= src2_col_addr_reg) or\n" +
    "							(COL_SRC3_ADDR /= src3_col_addr_reg) or (COL_SRC4_ADDR /= src4_col_addr_reg) or\n" +
    "						   	(col_dest_addr_reg /= COL_DEST_ADDR) then \n" +
    "						   	arith_st	<= reset_process_area_st;\n" +
    "						end if;\n" +
    "					when others => NULL;\n" +
    "				end case;\n" +
    "			end if;\n" +
    "		\n" +
    "		else --(OPERATION_TYPE /= \"00\") \n" +
    "			arith_st <= reset_process_area_st;\n" +
    "		end if;\n" +
    "	end if;\n" +
    "	end process;\n" +
    "end arc_ARITHMETIC_BLOCK;\n")
        