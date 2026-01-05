library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types_pkg.all;

entity microcode_rom is
    port (
        current_state : in state_types;
        microinstr_out : out microinstr_t
    );
end microcode_rom;

architecture Behavioral of microcode_rom is
    
begin
    process(current_state)
    variable microinstr : microinstr_t;
    begin
        microinstr.mem_read_en := '0';
        microinstr.mem_write_en := '0';
        microinstr.alu_op := ALU_PASS_A;
        microinstr.reg_write_en := '0';
        microinstr.reg_src_sel := '0';
        microinstr.next_state := S_HALT;
        case current_state is
            when S_FETCH_0 =>
                microinstr.mem_read_en := '1';
                microinstr.mem_write_en := '0';
                microinstr.alu_op := ALU_PASS_A;
                microinstr.reg_write_en := '0';
                microinstr.reg_src_sel := '0';
                microinstr.next_state := S_FETCH_1;
            when others =>
                null;   
        end case;
        microinstr_out <= microinstr;
    end process;
end Behavioral;
