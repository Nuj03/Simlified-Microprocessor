library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types_pkg.all;


entity alu is
    port (
        A : in std_logic_vector(DATA_WIDTH-1 downto 0);
        B : in std_logic_vector(DATA_WIDTH-1 downto 0);
        ALU_op : in alu_op_t;
        Result : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity alu;

architecture Behavioral of alu is
    begin
        process(A, B, ALU_op)
        begin
            case ALU_op is
                when ALU_ADD =>
                    Result <= std_logic_vector( unsigned(A) + unsigned(B) );
                when ALU_PASS_A =>
                    Result <= A;
            end case;
        end process;
end Behavioral;
