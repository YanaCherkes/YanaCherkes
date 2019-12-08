LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.Declare.all;
use work.output_vec.all;
use ieee.std_logic_textio.all;
use std.textio.all;


ENTITY tb_top is
END tb_top;

ARCHITECTURE behavior of tb_top is
-- Component Declaration for the Unit Under Test (UUT)
component CONTROLLER_TOP is
	port (
		ROW			: out output_row;						--Memory IF
		COLUMN			: out output_col;						--Memory IF
		DATA_FROM_MEM		: in std_logic_vector(col_max-1 downto 0);			--Memory IF
		DATA_VALID		: in std_logic;							--Memory IF
		FINISH			: out std_logic;						--CPU IF
		DATA_OUT		: out std_logic_vector(col_max-1 downto 0);       		--CPU IF
		DATA_OUT_FINISH		: out std_logic;
		ENABLE			: in std_logic;							--CPU IF
		INSTRUCTION		: in std_logic_vector(operation_len downto 0);				--CPU IF
		CLK			: in std_logic
	);
end component;

component CROSSBAR is
	port (
		ROW			: in output_row;
		COLUMN			: in output_col;
		CLK			: in std_logic;
		OUTPUT			: out std_logic_vector(col_max-1 downto 0);
		VALID			: out std_logic
	); 
end component;

component STD_FIFO
	Generic (
		constant DATA_WIDTH	: positive := operation_len+1;
		constant FIFO_DEPTH	: positive := 256
	);

	port (
		CLK			: in std_logic;
		RST			: in std_logic;
		DataIn			: in std_logic_vector(operation_len downto 0);
		WriteEn			: in std_logic;
		ReadEn			: in std_logic;
		DataOut			: out std_logic_vector(operation_len downto 0);
		Full			: out std_logic;
		Empty			: out std_logic
	);
end component;


-------------   Change the clk_period according to Requirements   -------------
	constant clk_period : time := 8 ns; --SET THE CLK CYCLE

    -- Signals declararion
	signal clk			: std_logic;
	signal instruction		: std_logic_vector(operation_len downto 0);
	signal enable			: std_logic;
	signal row			: output_row;
	signal column			: output_col;
	signal data_out			: std_logic_vector(col_max-1 downto 0);
	signal data_valid		: std_logic;
	signal flag			: std_logic;
	signal finish			: std_logic;
	signal good			: boolean;
	signal endoffile		: std_logic := '0';
	--FIFO
	signal RST			: std_logic := '0';
	signal DataIn			: std_logic_vector(operation_len downto 0) := (others => '0');
	signal ReadEn			: std_logic := '0';
	signal WriteEn			: std_logic := '0';
	signal DataOut			: std_logic_vector(operation_len downto 0);
	signal Empty			: std_logic;
	signal Full			: std_logic;

	
begin
-- Instantiate the Unit Under Test (UUT)
u_top: CONTROLLER_TOP 
	port map (
        	ROW		=> row,                                      
        	COLUMN		=> column,
		DATA_FROM_MEM	=> data_out,
		DATA_VALID	=> data_valid,
 		FINISH		=> finish,           
        	DATA_OUT	=> OPEN,  
		ENABLE		=> enable,
        	INSTRUCTION	=> instruction,            
        	CLK		=> clk  
	);
		
u_crossbar: CROSSBAR 
	port map (
		ROW   		 => row,            
		COLUMN		 => column,    
		CLK   		 => clk,           
		OUTPUT 		 => data_out,
		VALID		 => data_valid
	); 
		
u_fifo: STD_FIFO
	port map (
		CLK		=> CLK,
		RST		=> RST,
		DataIn		=> DataIn,
		WriteEn		=> WriteEn,
		ReadEn		=> ReadEn,
		DataOut		=> DataOut,
		Full		=> Full,
		Empty		=> Empty
	);
----------------------------------------------------------
------------   Clock generation process   ----------------
----------------  (50% duty cycle)  ----------------------
----------------------------------------------------------

clk_process :process
	begin
        	clk <= '0';
        	wait for clk_period/2;  --for 0.5*clk_period signal is '0'.
        	clk <= '1';
        	wait for clk_period/2;  --for next 0.5*clk_period signal is '1'.
end process;
   
wr_proc : process
		variable  inline		: line; 
		variable  instruction_tmp	: std_logic_vector(operation_len downto 0);
		constant  filename		: string := "C:\Users\yanac\Desktop\instruction_list.txt";--SET THE LOCATION OF YOUR FILE
		--constant  filename		: string := "C:\Users\sulim\Desktop\instruction_list.txt";--SET THE LOCATION OF YOUR FILE
		file infile			: text; 
		variable good 			: boolean;
	begin
		file_open(infile,filename,read_mode);
		wait until clk = '1' and clk'event;
		RST <= '1';
		wait until clk = '1' and clk'event;
		RST <= '0';
		wait until clk = '1' and clk'event;
		wait until clk = '1' and clk'event;
		while (not endfile(infile)) loop
			while (Full = '0'and (not endfile(infile))) loop	--checking the "END OF FILE" is not reached.
					flag <= '1';
					readline(infile, inline);		--reading a line from the file.
					read(inline, instruction_tmp,good);
					DataIn 	<= instruction_tmp; 
					WriteEn <= '1';
			wait until clk = '1' and clk'event;
			end loop;
			wait until clk = '1' and clk'event;
			WriteEn 	<= '0';
		end loop;
		endoffile 	<='1';         --set signal to tell end of file read file is reached.
		WriteEn 	<='0';
		file_close(infile);
		wait;
end process;

rd_proc : process
	begin
	while(endoffile='0') loop
		while ( Empty='0') loop
			wait until clk = '1' and clk'event;
			if (finish = '1') then
				ReadEn 		<= '1';
				wait until clk = '1' and clk'event;
				ReadEn 		<= '0';
				wait until clk = '1' and clk'event;
				instruction <= DataOut;
				enable 		<= '1';
				wait until finish = '1' and finish'event;
			else
				ReadEn 		<= '0';
			end if;
		end loop;
	wait until clk = '1' and clk'event;
	ReadEn 		<= '0';
	enable 		<= '0';
	end loop;
	wait;
end process;
END;