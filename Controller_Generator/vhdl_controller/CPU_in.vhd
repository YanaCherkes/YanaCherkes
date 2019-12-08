----------------------------------------------------------
--------------------- CPU In Block -----------------------
----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;
use work.output_vec.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity CPU_IN is
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
end CPU_IN;

architecture arc_CPU_IN of CPU_IN is

begin
	process (CLK)
	begin
		if rising_edge (CLK)  then
			if (ENABLE = '1') then
				OPERATION_TYPE		 <= INSTRUCTION(operation_len downto operation_len-type_len);
				
				if (INSTRUCTION(operation_len downto operation_len-type_len) = "00") then			--Arithmetic
					OPCODE			<= INSTRUCTION(operation_len-type_len-1 downto operation_len-type_len-1-opcode_len);
					STATE			<= INSTRUCTION(operation_len-type_len-1-opcode_len-1 downto operation_len-type_len-1-opcode_len-1-state_len);
					ROW_INIT 		<= INSTRUCTION(operation_len-type_len-1-opcode_len-1-state_len-1 downto operation_len-type_len-1-opcode_len-1-state_len-1-num_of_bits);
					ROW_FINISH		<= INSTRUCTION(operation_len-type_len-1-opcode_len-1-state_len-1-num_of_bits-1 downto operation_len-type_len-1-opcode_len-1-state_len-1-2*num_of_bits-1);
					BITS_NUM		<= INSTRUCTION(operation_len-type_len-1-opcode_len-1-state_len-1-2*num_of_bits-2 downto operation_len-type_len-1-opcode_len-1-state_len-1-3*num_of_bits-2);
					COL_DESTINATION		<= INSTRUCTION(operation_len-type_len-1-opcode_len-1-state_len-1-3*num_of_bits-3 downto operation_len-type_len-1-opcode_len-1-state_len-1-4*num_of_bits-3);
					COL_SOURCE1		<= INSTRUCTION(operation_len-type_len-1-opcode_len-1-state_len-1-4*num_of_bits-4 downto operation_len-type_len-1-opcode_len-1-state_len-1-5*num_of_bits-4);
					COL_SOURCE2		<= INSTRUCTION(operation_len-type_len-1-opcode_len-1-state_len-1-5*num_of_bits-5 downto operation_len-type_len-1-opcode_len-1-state_len-1-6*num_of_bits-5);
					COL_SOURCE3		<= INSTRUCTION(operation_len-type_len-1-opcode_len-1-state_len-1-6*num_of_bits-6 downto operation_len-type_len-1-opcode_len-1-state_len-1-7*num_of_bits-6);
					COL_SOURCE4		<= INSTRUCTION(operation_len-type_len-1-opcode_len-1-state_len-1-7*num_of_bits-7 downto operation_len-type_len-1-opcode_len-1-state_len-1-8*num_of_bits-7);

				elsif (INSTRUCTION(operation_len downto operation_len-type_len) = "01") then			--Read, TRUE, FALSE
					OPCODE			<= INSTRUCTION(operation_len-type_len-1 downto operation_len-type_len-1-opcode_len);
					ADDR_ROW_INIT1		<= INSTRUCTION(operation_len-type_len-1-opcode_len-1 downto operation_len-type_len-1-opcode_len-1-num_of_bits); 
					ADDR_ROW_FIN1		<= INSTRUCTION(operation_len-type_len-1-opcode_len-1-num_of_bits-1 downto operation_len-type_len-1-opcode_len-1-2*num_of_bits-1);
					BITS_NUM		<= INSTRUCTION(operation_len-type_len-1-opcode_len-1-2*num_of_bits-2 downto operation_len-type_len-1-opcode_len-1-3*num_of_bits-2);  
					ADDR_VR_VW_INIT		<= INSTRUCTION(operation_len-type_len-1-opcode_len-1-3*num_of_bits-3 downto operation_len-type_len-1-opcode_len-1-4*num_of_bits-3); --false, true, read
					ADDR_ROW_INIT2		<= INSTRUCTION(operation_len-type_len-1-opcode_len-1-4*num_of_bits-4 downto operation_len-type_len-1-opcode_len-1-5*num_of_bits-4);   
					ADDR_ROW_FIN2	 	<= INSTRUCTION(operation_len-type_len-1-opcode_len-1-5*num_of_bits-5 downto operation_len-type_len-1-opcode_len-1-6*num_of_bits-5);
					
								
				elsif (INSTRUCTION(operation_len downto operation_len-type_len) = "10") then			--Write01 (data inside the instruction)
					ADDR_ROW_INIT1		<= INSTRUCTION(operation_len-type_len-1 downto operation_len-type_len-1-num_of_bits);
					ADDR_ROW_FIN1		<= INSTRUCTION(operation_len-type_len-1-num_of_bits-1 downto operation_len-type_len-1-2*num_of_bits-1);
					ADDR_VR_VW_INIT		<= INSTRUCTION(operation_len-type_len-1-2*num_of_bits-2 downto operation_len-type_len-1-3*num_of_bits-2);
					BITS_NUM		<= INSTRUCTION(operation_len-type_len-1-3*num_of_bits-3 downto operation_len-type_len-1-4*num_of_bits-3);
					DATA10			<= INSTRUCTION(operation_len-type_len-1-4*num_of_bits-4 downto 0); -- 46 bits to for data to write inside the instruction

				elsif (INSTRUCTION(operation_len downto operation_len-type_len) = "11") then			--Write11 (only data)
					DATA11			<= INSTRUCTION(operation_len - type_len - 1  downto 0); -- operation_len - type_len  bits with data
				end if;

			elsif (ENABLE='0') then
					OPERATION_TYPE	<= "00";	--resets all blocks
					OPCODE		<= "00000000";
			end if;
		end if;
  end process;
  
end arc_CPU_IN;
