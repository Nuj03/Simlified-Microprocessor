
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_types_pkg.all;


entity control_unit is
    port (
        clk : in std_logic;
        rst : in std_logic;
        IR : in std_logic_vector(7 downto 0);
        mem_read_en : out std_logic;
        mem_write_en : out std_logic;
        alu_op : out alu_op_t;
        reg_write_en : out std_logic;
        reg_src_sel : out std_logic;
        next_state : out state_types
     );
end control_unit;

architecture Behavioral of control_unit is
    signal current_state_sig : state_types := S_RESET;
    signal microinstr : microinstr_t;
begin
    u_microcode_rom : entity work.microcode_rom
        port map(
            current_state => current_state_sig,
            IR => IR,
            microinstr_out => microinstr
        );

    process(clk, rst)
    begin
        if rst = '1' then
            current_state_sig <= S_RESET;
        elsif rising_edge(clk) then
            current_state_sig <= microinstr.next_state;
        end if;
    end process;

    mem_read_en  <= microinstr.mem_read_en;
    mem_write_en <= microinstr.mem_write_en;
    alu_op       <= microinstr.alu_op;
    reg_write_en <= microinstr.reg_write_en;
    reg_src_sel  <= microinstr.reg_src_sel;
    next_state   <= current_state_sig;
end Behavioral;
