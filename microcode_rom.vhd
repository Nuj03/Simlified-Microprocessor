library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types_pkg.all;

entity microcode_rom is
    port (
        current_state : in state_types;
        IR : in std_logic_vector(7 downto 0);
        microinstr_out : out microinstr_t
    );
end microcode_rom;

architecture Behavioral of microcode_rom is
    
begin
    process(current_state)
    variable microinstr : microinstr_t;
    begin

        --default microinstruction values
        microinstr.mem_read_en := '0';
        microinstr.mem_write_en := '0';
        microinstr.alu_op := ALU_PASS_A;
        microinstr.reg_write_en := '0';
        microinstr.reg_src_sel := '0';
        microinstr.next_state := S_HALT;

        case current_state is
         
            -- reset state
            when S_RESET =>
                microinstr.next_state := S_FETCH_0;

            -- instruction fetch states    
            when S_FETCH_0 =>
                microinstr.mem_read_en := '1';
                microinstr.next_state := S_FETCH_1;
            when S_FETCH_1 =>
                microinstr.mem_read_en := '1';
                microinstr.next_state := S_FETCH_2;
            when S_FETCH_2 =>
                microinstr.next_state := S_DECODE;

            -- instruction decode state
            when S_DECODE =>
                if IR(7 downto 5) = OP_LOAD then
                    microinstr.next_state := S_EXECUTE_LOAD_0;
                elsif IR(7 downto 5) = OP_STORE then
                    microinstr.next_state := S_EXECUTE_STORE_0;
                elsif IR(7 downto 5) = OP_ADD then
                    microinstr.next_state := S_EXECUTE_ALU_0;
                elsif IR(7 downto 5) = OP_HALT then
                    microinstr.next_state := S_HALT;
                else
                    microinstr.next_state := S_FETCH_0;
                end if;

            -- instruction execute load states
            when S_EXECUTE_LOAD_0 =>
                microinstr.mem_read_en := '1';
                microinstr.next_state := S_EXECUTE_LOAD_1;
            when S_EXECUTE_LOAD_1 =>
                microinstr.mem_read_en := '1';
                microinstr.next_state := S_EXECUTE_LOAD_2;
            when S_EXECUTE_LOAD_2 =>
                microinstr.reg_write_en := '1';
                microinstr.reg_src_sel := '1'; 
                microinstr.next_state := S_FETCH_0;

            -- instruction execute store states
            when S_EXECUTE_STORE_0 =>
                microinstr.next_state := S_EXECUTE_STORE_1;
            when S_EXECUTE_STORE_1 =>
                microinstr.mem_write_en := '1';
                microinstr.next_state := S_FETCH_0;

            -- instruction execute ALU states
            when S_EXECUTE_ALU_0 =>
                microinstr.alu_op := ALU_ADD;
                microinstr.reg_write_en := '1';
                microinstr.reg_src_sel := '0';
                microinstr.next_state := S_FETCH_0;
                
            when S_HALT =>
                microinstr.next_state := S_HALT;
            when others =>
                null;   
        end case;
        microinstr_out <= microinstr;
    end process;
end Behavioral;
