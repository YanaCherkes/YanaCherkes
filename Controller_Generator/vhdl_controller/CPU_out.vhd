----------------------------------------------------------
-------------------- CPU Out Block -----------------------
----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;
use work.output_vec.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity CPU_OUT is
	port (
		FINISH			: out std_logic;					--CPU IF
		DATA_OUT		: out std_logic_vector(col_max-1 downto 0);	--CPU IF
		CLK			: in std_logic;
		DATA_FROM_MEM		: in std_logic_vector(col_max-1 downto 0);	--ROW_OR_COL IF
		VALID			: in std_logic;					--ROW_OR_COL IF
		TRANSACTION_FINISH	: in std_logic
	);

end CPU_OUT;

architecture arc_CPU_OUT of CPU_OUT is

begin
	process (CLK)
	begin
		if rising_edge (CLK)  then
			if (TRANSACTION_FINISH = '1') then
				if (VALID = '1') then
					DATA_OUT <= DATA_FROM_MEM;
					FINISH <= '1';
				elsif (VALID = '0') then
					DATA_OUT <= (others => '0');
					FINISH <= '0';
				end if;
			elsif (TRANSACTION_FINISH = '0') then
				DATA_OUT <= (others => '0');
				FINISH <= '0';
			end if;
		end if;
  end process;
  
end arc_CPU_OUT;	---add mux that checks which componnent finished the transaction
