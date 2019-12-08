----------------------------------------------------------
------------------- Controller Top -----------------------
----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;
use work.output_vec.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity MEMORY_OUT is
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
end MEMORY_OUT;

architecture arc_MEMORY_OUT of MEMORY_OUT is

----- Signal declarations -----
signal operation_type_reg  : std_logic_vector(type_len downto 0);	
signal opcode_reg          : std_logic_vector(opcode_len downto 0);

begin

process (CLK)
begin
	if rising_edge(CLK) then
		operation_type_reg <= OPERATION_TYPE;
		opcode_reg <= OPCODE;
		if (operation_type_reg = "00") then			--type a
			ROW      	<= ARITHMETIC_ROW_OUT;
			COLUMN   	<= ARITHMETIC_COLUMN_OUT;						
		elsif (operation_type_reg = "01") then			--type b
		   	if (opcode_reg = "00000001") then			--read
				ROW      	<= READ_ROW_OUT;
				COLUMN   	<= READ_COLUMN_OUT;				
			elsif (opcode_reg = "00000010") then		--false
				ROW      	<= FALSE_ROW_OUT;
				COLUMN   	<= FALSE_COLUMN_OUT;				
			elsif (opcode_reg = "00000011") then		--true
				ROW      	<= TRUE_ROW_OUT;
				COLUMN   	<= TRUE_COLUMN_OUT;
			end if;		
		elsif (operation_type_reg = "10") then			--type c
			ROW      	<= WRITE_ROW_OUT;
			COLUMN   	<= WRITE_COLUMN_OUT;
		elsif (operation_type_reg = "11") then			--type d
			ROW		<= WRITE_ROW_OUT;
			COLUMN		<= WRITE_COLUMN_OUT;
		end if;
	end if;
end process;

end arc_MEMORY_OUT;
