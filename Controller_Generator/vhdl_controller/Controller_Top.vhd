----------------------------------------------------------
------------------- Controller Top -----------------------
----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;
use work.output_vec.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity CONTROLLER_TOP is
	port (
		ROW          		: out output_row;					--Memory IF
	        COLUMN       		: out output_col;					--Memory IF
		DATA_FROM_MEM	  	: in std_logic_vector(col_max-1 downto 0);	--Memory IF
		DATA_VALID        	: in std_logic;						--Memory IF
		FINISH       		: out std_logic;					--CPU IF
		DATA_OUT     		: out std_logic_vector(col_max-1 downto 0);	--CPU IF
		DATA_OUT_FINISH		: out std_logic;
	        ENABLE        		: in std_logic;						--CPU IF
	        INSTRUCTION 		: in std_logic_vector(operation_len downto 0);			--CPU IF
	        CLK          		: in std_logic
		);
end CONTROLLER_TOP;

architecture arc_CONTROLLER_TOP of CONTROLLER_TOP is

----- Component declarations -----
 
component CPU_OUT is
	port (
		FINISH           	: out std_logic;					--CPU IF
		DATA_OUT         	: out std_logic_vector(col_max-1 downto 0);	--CPU IF
		CLK              	: in std_logic;
		DATA_FROM_MEM    	: in std_logic_vector(col_max-1 downto 0);
		VALID			: in std_logic;
		TRANSACTION_FINISH	: in std_logic	
	);
end component;

component CPU_IN is
	port (
		ENABLE		: in std_logic;                                --CPU IF
		INSTRUCTION	: in std_logic_vector(operation_len downto 0);            --CPU IF
		CLK		: in std_logic;
		OPERATION_TYPE	: out std_logic_vector(type_len downto 0);
		OPCODE		: out std_logic_vector(opcode_len downto 0);
		BITS_NUM	: out std_logic_vector(num_of_bits downto 0);
		--Arithmetic
		STATE		: out std_logic_vector(state_len downto 0);
		ROW_INIT 	: out std_logic_vector(num_of_bits downto 0);
		ROW_FINISH	: out std_logic_vector(num_of_bits downto 0);
		COL_DESTINATION	: out std_logic_vector(num_of_bits downto 0);
		COL_SOURCE1	: out std_logic_vector(num_of_bits downto 0);
		COL_SOURCE2	: out std_logic_vector(num_of_bits downto 0);
		COL_SOURCE3	: out std_logic_vector(num_of_bits downto 0);
		COL_SOURCE4	: out std_logic_vector(num_of_bits downto 0);
		--Write
		DATA10		: out std_logic_vector(operation_len - type_len - 1 - 4*num_of_bits - 4 downto 0);
		DATA11		: out std_logic_vector(operation_len - type_len - 1 downto 0);
		--Read, True, False + Write
		ADDR_VR_VW_INIT: out std_logic_vector(num_of_bits downto 0);
		ADDR_ROW_INIT1	: out std_logic_vector(num_of_bits downto 0);
		ADDR_ROW_FIN1	: out std_logic_vector(num_of_bits downto 0);
		-- True, False
		ADDR_ROW_INIT2	: out std_logic_vector(num_of_bits downto 0);		
		ADDR_ROW_FIN2	: out std_logic_vector(num_of_bits downto 0)
			
	);
end component;

component TRUE is
	port(
		ROW_OUT		: out output_row;                               
	        COLUMN_OUT      : out output_col;
		FINISH          : out std_logic;
		CLK             : in std_logic;
		OPERATION_TYPE  : in std_logic_vector(type_len downto 0);
		OPCODE		: in std_logic_vector(opcode_len downto 0);
		BITS_NUM        : in std_logic_vector(num_of_bits downto 0);             --defines the number of the memristors on the column/row of Vw1 
	        ROW_INIT_ADDR	: in std_logic_vector(num_of_bits downto 0);             --defines the number of the first memristor in the row/column of the first area 
	        ROW_FIN_ADDR	: in std_logic_vector(num_of_bits downto 0);             --defines the number of the last memristor in the row/column of the first area
	        VW1_INIT_ADDR   : in std_logic_vector(num_of_bits downto 0)             --defines the number of the first memristor in the column/row of Vw1
	);
end component;

component FALSE is
	port(
		ROW_OUT		: out output_row;                               
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
end component;

component READ is
	port (
		ROW_OUT         : out output_row;                               
	        COLUMN_OUT      : out output_col;
		FINISH          : out std_logic;
		CLK		: in std_logic;
		OPERATION_TYPE  : in std_logic_vector(type_len downto 0);
		OPCODE		: in std_logic_vector(opcode_len downto 0);
	        VR_COL_ADDR     : in std_logic_vector(num_of_bits downto 0);            	--defines the address of the first memristor in the column of Vr
	        BITS_NUM        : in std_logic_vector(num_of_bits downto 0);             	--defines the number of the memristors in the row/column
	        ROW_READ_ADDR   : in std_logic_vector(num_of_bits downto 0)              --defines the address of the memristors row of reading
	);
end component;

component WRITE is
	port (
		ROW_OUT         : out output_row;                               
        	COLUMN_OUT      : out output_col;
		FINISH          : out std_logic;
		CLK		: in std_logic;
		OPERATION_TYPE  : in std_logic_vector(type_len downto 0);
		BITS_NUM	: in std_logic_vector(num_of_bits downto 0);
		DATA10 		: in std_logic_vector(operation_len - type_len - 1 - 4*num_of_bits - 4 downto 0);
		DATA11 		: in std_logic_vector(operation_len - type_len - 1 downto 0);
		VW_COL_ADDR	: in std_logic_vector(num_of_bits downto 0);
		ROW_INIT_ADDR  	: in std_logic_vector(num_of_bits downto 0);
		ROW_FIN_ADDR   	: in std_logic_vector(num_of_bits downto 0)
	);
end component;

	
component MEMORY_OUT is
	port (
		ROW			: out output_row;                               --Memory IF
        	COLUMN			: out output_col;                               --Memory IF
		OPERATION_TYPE		: in std_logic_vector(type_len downto 0);			
		OPCODE			: in std_logic_vector(opcode_len downto 0);
        	CLK			: in std_logic;

		ARITHMETIC_ROW_OUT	: in output_row;
		ARITHMETIC_COLUMN_OUT	: in output_col;
		ARITHMETIC_FINISH	: in std_logic;

		FALSE_ROW_OUT		: in output_row;
		FALSE_COLUMN_OUT	: in output_col;
		FALSE_FINISH		: in std_logic;

		TRUE_ROW_OUT		: in output_row;
		TRUE_COLUMN_OUT		: in output_col;
		TRUE_FINISH		: in std_logic;
	                          
		READ_ROW_OUT		: in output_row;
		READ_COLUMN_OUT		: in output_col;
		READ_FINISH		: in std_logic;
	                          
		WRITE_ROW_OUT		: in output_row;
		WRITE_COLUMN_OUT	: in output_col;
		WRITE_FINISH		: in std_logic
	);
end component;

component ARITHMETIC_BLOCK is

	port (
		OPERATION_TYPE	 : in std_logic_vector(type_len downto 0);		--defines the type of the operation: 00-arithmetic; 01-true,false, read; 10-write; 11-write
		OPCODE           : in std_logic_vector(opcode_len downto 0);		--5 bits which defines the operation (relevant only for types 00 and 01)

		FINISH		: out std_logic;
		ROW_OUT		: out output_row;                               
		COLUMN_OUT	: out output_col;				
		STATE		: in std_logic_vector(state_len downto 0);		--defines the arithemetic state
		BITS_NUM 	: in std_logic_vector(num_of_bits downto 0);		--defines the bits num
		COL_SRC1_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the first src 
		COL_SRC2_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the second src
		COL_SRC3_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the third src 
		COL_SRC4_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the fourth src
      		ROW_INIT_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the row of the first input
        	ROW_FIN_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the row of the last input
		COL_DEST_ADDR	: in std_logic_vector(num_of_bits downto 0);		--defines the column of the output 
		CLK		: in std_logic
	);
end component;


----- Signal declarations -----
	signal finish_controller	: std_logic:='1';
	signal operation_type		: std_logic_vector(type_len downto 0);
	signal opcode			: std_logic_vector(opcode_len downto 0);
	signal bits_num			: std_logic_vector(num_of_bits downto 0);
	signal arith_state		: std_logic_vector(state_len downto 0);
	signal row_init_addr_arith	: std_logic_vector(num_of_bits downto 0);
	signal row_fin_addr_arith	: std_logic_vector(num_of_bits downto 0);
	signal col_destination		: std_logic_vector(num_of_bits downto 0);
	signal col_src1			: std_logic_vector(num_of_bits downto 0);
	signal col_src2			: std_logic_vector(num_of_bits downto 0);
	signal col_src3			: std_logic_vector(num_of_bits downto 0);
	signal col_src4			: std_logic_vector(num_of_bits downto 0);
	signal data10			: std_logic_vector(operation_len - type_len - 1 - 4*num_of_bits - 4 downto 0);
	signal data11			: std_logic_vector(operation_len - type_len - 1 downto 0);
	signal row1_init_addr		: std_logic_vector(num_of_bits downto 0);
	signal row1_fin_addr		: std_logic_vector(num_of_bits downto 0);
	signal row2_init_addr		: std_logic_vector(num_of_bits downto 0);
	signal row2_fin_addr		: std_logic_vector(num_of_bits downto 0);
	--signal addr_vr_init		: std_logic_vector(num_of_bits downto 0);
	signal addr_vw_vr_init		: std_logic_vector(num_of_bits downto 0);
	signal arith_blk_row_out	: output_row;
	signal arith_blk_column_out	: output_col;
	signal arith_blk_finish		: std_logic;
	signal false_row_out		: output_row;
	signal false_column_out		: output_col;
	signal false_finish		: std_logic;
	signal true_row_out		: output_row;
	signal true_column_out		: output_col;
	signal true_finish		: std_logic;
	signal read_row_out		: output_row;
	signal read_column_out		: output_col;
	signal read_finish		: std_logic;
	signal write_row_out		: output_row;
	signal write_column_out		: output_col;
	signal write_finish		: std_logic;
	signal write_try		: std_logic;	
	signal counter            	: integer := 0;

begin

u_cpu_out: CPU_OUT 
	port map(
		FINISH           		=> DATA_OUT_FINISH,
		DATA_OUT         		=> DATA_OUT,
		CLK              		=> CLK,
		DATA_FROM_MEM    		=> DATA_FROM_MEM,				
		VALID			 	=> DATA_VALID,						
		TRANSACTION_FINISH 		=> '1'				
	);
	
u_cpu_in: CPU_IN 
	port map(
		ENABLE           		=> ENABLE,
		INSTRUCTION 			=> INSTRUCTION,
		CLK             		=> CLK,
		OPERATION_TYPE  		=> operation_type,
		OPCODE		    		=> opcode,
		BITS_NUM	    		=> bits_num,
		--Arithmetic
		STATE				=>arith_state,
		ROW_INIT 			=>row_init_addr_arith,
		ROW_FINISH			=>row_fin_addr_arith,
		COL_DESTINATION			=>col_destination,
		COL_SOURCE1			=>col_src1,
		COL_SOURCE2			=>col_src2,
		COL_SOURCE3			=>col_src3,
		COL_SOURCE4			=>col_src4,			
		--Write
		DATA10   			=> data10,					
		DATA11   			=> data11,
		--Read, True, False + Write
		ADDR_VR_VW_INIT			=> addr_vw_vr_init,
		ADDR_ROW_INIT1  		=> row1_init_addr,
		ADDR_ROW_FIN1  			=> row1_fin_addr,
		-- True, False
		ADDR_ROW_INIT2			=> row2_init_addr,		
		ADDR_ROW_FIN2  			=> row2_fin_addr
	);
	
u_memory_out: MEMORY_OUT 
	port map(
		ROW          		=> ROW, 	
		COLUMN       		=> COLUMN, 	
		OPERATION_TYPE		=> operation_type,
		OPCODE		 	=> opcode,
		CLK          		=> CLK,
	 	ARITHMETIC_ROW_OUT      => arith_blk_row_out,    
		ARITHMETIC_COLUMN_OUT   => arith_blk_column_out, 
		ARITHMETIC_FINISH	=> arith_blk_finish, 	
		FALSE_ROW_OUT   	=> false_row_out,     
		FALSE_COLUMN_OUT	=> false_column_out,  
		FALSE_FINISH		=> false_finish,	 	
		TRUE_ROW_OUT    	=> true_row_out,      
		TRUE_COLUMN_OUT 	=> true_column_out,   
		TRUE_FINISH	 	=> true_finish,	 	
		READ_ROW_OUT     	=> read_row_out,      
		READ_COLUMN_OUT  	=> read_column_out,   
		READ_FINISH		=> read_finish,	 	
		WRITE_ROW_OUT    	=> write_row_out,     
		WRITE_COLUMN_OUT 	=> write_column_out,  
		WRITE_FINISH	 	=> write_finish	 	
	);

u_true: TRUE 
	port map (
		ROW_OUT			=> true_row_out,
		COLUMN_OUT     		=> true_column_out,
		FINISH                  => true_finish,
		CLK            		=> CLK,
		OPERATION_TYPE  	=> operation_type,
		OPCODE		    	=> opcode,
		BITS_NUM        	=> bits_num,
		ROW_INIT_ADDR  		=> row1_init_addr,
		ROW_FIN_ADDR   		=> row1_fin_addr,
		VW1_INIT_ADDR    	=> addr_vw_vr_init
	);
	
u_false: FALSE 
	port map (
		ROW_OUT    	    	=> false_row_out,
		COLUMN_OUT      	=> false_column_out,
		FINISH                  => false_finish,
		CLK             	=> CLK,
		OPERATION_TYPE  	=> operation_type,
		OPCODE		    	=> opcode,
		BITS_NUM        	=> bits_num,
		ROW_INIT_ADDR  	=> row1_init_addr,
		ROW_FIN_ADDR   	=> row1_fin_addr,
		VW0_INIT_ADDR    	=> addr_vw_vr_init
	);
	
u_read: READ 
	port map(
		ROW_OUT			=> read_row_out,
		COLUMN_OUT      	=> read_column_out,
		FINISH                  => read_finish,
		CLK             	=> CLK,
		OPERATION_TYPE  	=> operation_type,
		OPCODE		    	=> opcode,
		VR_COL_ADDR   		=> addr_vw_vr_init,
		BITS_NUM        	=> bits_num,
		ROW_READ_ADDR	    	=> row1_init_addr
	);
	
u_write: WRITE 
	port map(
		ROW_OUT			=> write_row_out,
		COLUMN_OUT		=> write_column_out,
		FINISH			=> write_finish,
		CLK			=> CLK,
		OPERATION_TYPE		=> operation_type,
		BITS_NUM		=> bits_num,
		DATA10			=> data10,
		DATA11			=> data11,
		VW_COL_ADDR		=> addr_vw_vr_init,
		ROW_INIT_ADDR  		=> row1_init_addr,
		ROW_FIN_ADDR		=> row1_fin_addr
	);
	
u_arithmetic_block: ARITHMETIC_BLOCK 
	port map (     	 	
		OPERATION_TYPE		=> operation_type,
		OPCODE			=> opcode,
		FINISH			=> arith_blk_finish,
		ROW_OUT			=> arith_blk_row_out, 
		COLUMN_OUT		=> arith_blk_column_out,
		STATE			=> arith_state,
		BITS_NUM 		=> bits_num,
        	COL_SRC1_ADDR		=> col_src1, 
        	COL_SRC2_ADDR		=> col_src2,
        	COL_SRC3_ADDR		=> col_src3, 
        	COL_SRC4_ADDR		=> col_src4,
        	ROW_INIT_ADDR		=> row_init_addr_arith, 			
		ROW_FIN_ADDR		=> row_fin_addr_arith,
        	COL_DEST_ADDR		=> col_destination,		
		CLK			=> CLK
	);		

	process(CLK)
	begin

	if rising_edge(CLK) then
		FINISH      <= finish_controller;
		case (INSTRUCTION(operation_len downto operation_len-type_len)) is
			when "00" => 
				if(INSTRUCTION(operation_len-type_len-1 downto operation_len-type_len-1-opcode_len)="00000000") then
						finish_controller <= '1';
				else
						finish_controller <= arith_blk_finish;
				end if;
			when "01" =>
				case(INSTRUCTION(operation_len-type_len-1 downto operation_len-type_len-1-opcode_len)) is 
				when "00000001" => finish_controller <= read_finish;
				when "00000010" => finish_controller <= false_finish;
				when "00000011" => finish_controller <= true_finish;
				when others  => finish_controller <= '1';
				end case;
			when "10" => finish_controller <= write_finish;
			when "11" => finish_controller <= write_finish;
			when others => finish_controller <= '1';
			end case;
	end if;
	end process;
		
end arc_CONTROLLER_TOP ;
