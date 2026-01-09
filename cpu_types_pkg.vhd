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

type state_types is (
        S_RESET, 
        S_FETCH_0, S_FETCH_1, S_FETCH_2, 
        S_DECODE, 
        S_EXECUTE_LOAD_0, S_EXECUTE_LOAD_1, S_EXECUTE_LOAD_2,
        S_EXECUTE_STORE_0, S_EXECUTE_STORE_1,
        S_EXECUTE_ALU_0, S_EXECUTE_ALU_1,
        S_HALT
    );

type microinstr_t is record
    mem_read_en : std_logic;
    mem_write_en : std_logic;
    alu_op : alu_op_t;
    reg_write_en : std_logic;
    reg_src_sel : std_logic;
    next_state : state_types;
end record;

end package cpu_types_pkg;