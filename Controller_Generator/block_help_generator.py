# -*- coding: utf-8 -*-
"""
Created on Mon Aug 12 20:04:46 2019

@author: yanac
"""
import os

def check_json_names (JSON_names):
    JSON_names = open("json_names.txt","r") 
    line = JSON_names.readline().replace('\n','')
    while line:
        if not os.path.exists(line):
            print (line + " File not Exist! Please fix json_names.txt file. \n")  
            JSON_names.close()
            return 0 #file doesn't exist
        else:
            line = JSON_names.readline().replace('\n','')
    JSON_names.close()
    return 1 #all files exist
 
def opcodes_file(opcodes, block_names):
    path = 'vhdl_controller'
    if not os.path.exists(path):
        os.makedirs(path)
    
    file_name = "OPCODES"
    full_file_name = file_name + ".txt"
    file = open(os.path.join(path, full_file_name), 'w')
    
    for i in range(len(opcodes)):
        file.writelines("Block Name:" + str(block_names[i]) + " Opcode:" + str(opcodes[i]) + "\n")
        
def init_state(file, numState, dest_vector, row_size, processing_area_init, num_of_inputs):

    if (numState == 0):
        file.writelines(
    "					when state"+str(numState)+ "=>\n");
    else:    
        file.writelines(
    "					        ena_magic_sig	<= '0'; \n\n" +
    "					when state"+str(numState)+ "=>\n" +
    "                                               --update cycle"+str(numState)+  " in crossbar\n"
    );
    #write 1 in the initialiization columns
    for i in dest_vector:
        if int(i) >= int(row_size):
            break;
        elif int(i) < int(num_of_inputs):
            continue;
        else:
         calculated_column = int(processing_area_init) + int(i) - int(num_of_inputs) #calculaate the column to initialize
         file.writelines(
    "						COLUMN_OUT("+ str(calculated_column) + ") <= Vw1; \n");
     #initiate rows
    file.writelines(
    "					        ROW_OUT(row_addr_fin downto row_addr_init) <= (others => gnd);\n");
    file.writelines(
    "						--update next state signals\n" +
    "						current_state	<= state"+str(numState+1)+";\n");

def begin(file):
    file.writelines(
"\n" +
"begin\n" +
"	row_addr_init         <= conv_integer(ROW_INIT_ADDR);\n" +
"	row_addr_fin          <= conv_integer(ROW_FIN_ADDR);\n" +
"	process_area_in       <= PROCESS_AREA_INIT;\n" +
"	u_magic: MAGIC \n" +
"		port map(\n" +
"			ROW_OUT		=>row_magic,\n" +
"        		COLUMN_OUT	=>col_magic,\n" +
"			ENA		=>ena_magic_sig,\n" +
"			STATE		=>state_arith,\n" +
"        		ROW_INIT_ADDR	=>row_init,\n" +
"	        	ROW_FIN_ADDR	=>row_fin,\n" +
"	        	COL_SRC1_ADDR	=>col1_addr,\n" +
"	        	COL_SRC2_ADDR	=>col2_addr,\n" +
"	        	COL_SRC3_ADDR	=>col3_addr,\n" +
"	        	COL_SRC4_ADDR	=>col4_addr,\n" +
"			COL_DEST_ADDR	=>col_dest\n" +
"		);\n" +
"	\n" +
"	\n" +
"	process(CLK)\n" +
"		begin\n" +
"\n" +
"		if rising_edge(CLK) then\n" +
"			ROW_OUT		<= (others => floating);\n" +
"			COLUMN_OUT	<= (others => floating);\n" +
"			FINISH		<= '0';\n" +
"		\n" +
"			if ( ENA = '1') then\n" +
"				case current_state is\n" +
"					\n")
    
def signals(file):
    file.writelines(
    "   \n" +
    "------------------------- Block signals	----------------------------                              \n" +
    "	signal  current_state		: states;\n" +
    "	signal 	process_area_in		: std_logic_vector(num_of_bits downto 0);	  \n" +     
    "------------------------- MAGIC signals	----------------------------                              \n" +
"	signal col1_addr		: std_logic_vector(num_of_bits downto 0):=(others=>'0');\n" +
"	signal col2_addr		: std_logic_vector(num_of_bits downto 0):=(others=>'0');\n" +
"	signal col3_addr		: std_logic_vector(num_of_bits downto 0):=(others=>'0');\n" +
"	signal col4_addr		: std_logic_vector(num_of_bits downto 0):=(others=>'0');\n" +
"	signal col_dest			: std_logic_vector(num_of_bits downto 0):=(others=>'0');\n" +
"	signal row_init    		: std_logic_vector(num_of_bits downto 0):=(others=>'0');\n" +
"	signal row_fin    		: std_logic_vector(num_of_bits downto 0):=(others=>'0');\n" +
"	signal state_arith    		: std_logic_vector(state_len downto 0):=(others=>'0');\n" +
"	signal ena_magic_sig   	  	: std_logic:='0';\n" +
"	signal row_magic      		: output_row;\n" +
"	signal col_magic      		: output_col;\n" +
"	signal row_addr_init            :   integer range 0 to row_max_input;\n" +
"	signal row_addr_fin             :   integer range 0 to row_max_input; \n" +
"	\n" )
    

def find_num_of_inputs_and_outputs(json_file_name):
   json_file_name = json_file_name.replace('\n','')
   json_file_name = json_file_name.replace(' ','')
   simpler = open(json_file_name,"r") 
        
   line = simpler.readline().replace('\n',' ')
    
   for line in simpler:
        line = line.replace(',\n','')
        if line.find("Inputs") != -1:
            if  line.find("Number of Inputs") != -1:
                continue  
            else:
                Inputs = line.split("\"{")[1].split("}\"")[0].split(',')
                num_of_inputs = len (Inputs)     
        elif  line.find("Outputs") != -1:
            if  line.find("Number of Outputs") != -1:
                continue
            else:
                Outputs = line.split("\"{")[1].split("}\"")[0].split(',')
                num_of_outputs = len(Outputs)
   total = int(num_of_inputs)+int(num_of_outputs)
   return int(total)


# i -  the integer to convert
# n - num of bits

def num2binary(i, n):
    if i == 0:
        s = '0'
    else:
        s = ''
        while i:
            if i & 1 == 1:
                s = "1" + s
            else:
                s = "0" + s
            i //= 2
    slen = len(s)
    while (slen < n):
        s = '0'+s;
        slen = slen + 1;
    return s

def entity(file, file_name):
    file.writelines(
    "entity " + file_name + " is\n" +
    "	port (\n" +
    "		FINISH			: out std_logic;\n" +
    "		ROW_OUT			: out output_row;\n" +
    "		COLUMN_OUT		: out output_col;\n" +
    "		PROCESS_AREA_FINISH	: out std_logic_vector(num_of_bits downto 0);\n" +
    "		ENA			: in std_logic;--enable the work of the block\n" +
    "		COL_SRC_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the column of the first src \n" +
    "      		ROW_INIT_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the row of the first input\n" +
    "        	ROW_FIN_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the row of the last input\n" +
    "	        COL_DEST_ADDR		: in std_logic_vector(num_of_bits downto 0);		--defines the column of the output \n"+
    "		PROCESS_AREA_INIT	: in std_logic_vector(num_of_bits downto 0); \n"+
    "		CLK			: in std_logic\n" +
    "	);\n" +
    "end " + file_name + ";\n" +
    "\n" +
    "architecture arc_" + file_name +  " of "+ file_name +" is\n" +
    "\n" + 
    "component MAGIC \n" +
    "	port (\n" +
    "		ROW_OUT		: out output_row;\n" +
    "        	COLUMN_OUT	: out output_col;\n" +
    "		ENA		: in std_logic;					\n" +
    "		STATE		: in std_logic_vector(state_len downto 0);\n" +
    "        	ROW_INIT_ADDR	: in std_logic_vector(num_of_bits downto 0);	\n" +
    "	        ROW_FIN_ADDR	: in std_logic_vector(num_of_bits downto 0);	\n" +
    "	        COL_SRC1_ADDR	: in std_logic_vector(num_of_bits downto 0);	\n" +
    "	        COL_SRC2_ADDR	: in std_logic_vector(num_of_bits downto 0);	\n" +
    "	        COL_SRC3_ADDR	: in std_logic_vector(num_of_bits downto 0);	\n" +
    "	        COL_SRC4_ADDR	: in std_logic_vector(num_of_bits downto 0);	\n" +
    "		COL_DEST_ADDR	: in std_logic_vector(num_of_bits downto 0)\n" +
    "	);\n" +
    "end component; \n" +
    "    \n" +
    "  \n" +
"\n")
    

def finish_state(file):

    file.writelines(
"					\n" +
"					when others => null;\n" +
"					\n" +
"				end case;\n" +
"			else\n" +
"				current_state <= state0;\n" +
"			end if;\n" +
"		end if;\n" +
"	end process;\n" +
"end architecture;		\n" +
"			\n")
    
def states(file, total_cycles):
    file.writelines("	type states is (")
    for i in range(int(total_cycles)):
        file.writelines("state" + (str(i)) + ", ")
    file.writelines("state" + total_cycles + ");")      
                   
def library_use_component(file):
    file.writelines("library ieee; \nuse ieee.std_logic_1164.all; \n" +
                    "use work.Declare.all; \nuse work.output_vec.all; \n" +
                    "use ieee.numeric_std.all; \nuse ieee.std_logic_signed.all; \n" +
                    "use ieee.std_logic_arith.all; \n\n")
