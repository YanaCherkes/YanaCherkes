----------------------------------------------------------
-------------   Define the input vectors   ---------------
----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Declare.all;

package output_vec is
type output_row is array(row_max_input-1 DOWNTO 0) of Vin;
type output_col is array(col_max-1 DOWNTO 0) of Vin;
type mem_matrix is array(row_max_input-1 DOWNTO 0, col_max-1 DOWNTO 0) of std_logic;
end output_vec;