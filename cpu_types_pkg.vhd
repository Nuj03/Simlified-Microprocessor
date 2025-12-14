library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


package cpu_types_pkg is

constant DATA_WIDTH : integer := 8;
constant REG_COUNT : integer := 4;
constant REG_INDEX_W : integer := 2;
constant MEM_ADDR_W : integer := 3;
constant MEM_DEPTH : integer := 8;

constant OP_LOAD : std_logic_vector(2 downto 0) := "000";
constant OP_STORE : std_logic_vector(2 downto 0) := "001";
constant OP_ADD : std_logic_vector(2 downto 0) := "010";
constant OP_HALT : std_logic_vector(2 downto 0) := "111";

type alu_op_t is (ALU_ADD, ALU_PASS_A);

end package cpu_types_pkg;