library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types_pkg.all;
entity cpu_core is
    port(
        clk : in std_logic;
        rst : in std_logic
    );
end entity cpu_core;

architecture Behavioral of cpu_core is

    --internal CPU signals
    signal PC : std_logic_vector(MEM_ADDR_W-1 downto 0);
    signal IR : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal AR : std_logic_vector(MEM_ADDR_W-1 downto 0);
    signal DR : std_logic_vector(DATA_WIDTH-1 downto 0);
    
    --general purpose register file signals
    signal regW_addr : std_logic_vector(REG_INDEX_W-1 downto 0);
    signal regA_addr : std_logic_vector(REG_INDEX_W-1 downto 0);
    signal regB_addr : std_logic_vector(REG_INDEX_W-1 downto 0);
    
    --register file data signals
    signal regA : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal regB : std_logic_vector(DATA_WIDTH-1 downto 0);
    
    --control signals
    signal reg_write_en : std_logic;
    signal reg_write_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg_source_select : std_logic; -- '0' for ALU, '1' for DR
    
    --ALU signals
    signal alu_result : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal alu_op : alu_op_t;
    
    --memory signals
    signal memory_read_en : std_logic;
    signal memory_write_en : std_logic;
    signal memory_data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    

    
    signal current_state, next_state : state_types;

begin

    --THE CPU REGISTERS
    u_regfile : entity work.regfile
        port map(
                clk => clk,
                write_enable => reg_write_en,
                write_address => regW_addr,
                write_data => reg_write_data,
                readA_address => regA_addr,
                readB_address => regB_addr,
                readA_data => regA,
                readB_data => regB
        );

    --THE ARITHMETIC LOGIC UNIT
    u_alu : entity work.alu
        port map(
            A => regA,
            B => regB,
            ALU_op => alu_op,
            Result => alu_result
        );
    
    --THE MEMORY UNIT
    u_memory : entity work.memory
        port map(
            clk => clk,
            addr => AR,
            data_in => regB,
            write_en => memory_write_en,
            read_en => memory_read_en,
            data_out => memory_data_out
        );

    --THE CONTROL UNIT
    u_control_unit : entity work.control_unit
        port map(
            clk => clk,
            rst => rst,
            IR => IR,
            mem_read_en => memory_read_en,
            mem_write_en => memory_write_en,
            alu_op => alu_op,
            reg_write_en => reg_write_en,
            reg_src_sel => reg_source_select,
            next_state => next_state
        );
    
    FSM_reg_proc : process(clk, rst)
    begin
        if rst = '1' then
            current_state <= S_RESET;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;    

    register_update_proc : process(clk, rst)
    begin
        if rst = '1' then
            PC <= (others => '0');
            AR <= (others => '0');
            IR <= (others => '0');
            DR <= (others => '0');
            regA_addr <= (others => '0');
            regB_addr <= (others => '0');
            regW_addr <= (others => '0');
        elsif rising_edge(clk) then
            case current_state is
            
                -- Fetch Cycle
                when S_FETCH_0 => 
                    AR <= PC;
                when S_FETCH_1 =>
                    DR <= memory_data_out;
                when S_FETCH_2 =>
                    IR <= DR;
                    PC <= std_logic_vector(unsigned(PC) + 1);

                -- Execute Load Cycle
                when S_EXECUTE_LOAD_0 =>
                    AR <= IR(2 downto 0);
                when S_EXECUTE_LOAD_2 =>
                    regW_addr <= IR(4 downto 3);

                -- Execute Store Cycle    
                when S_EXECUTE_STORE_0 =>
                    AR <= IR(2 downto 0);

                -- Execute ALU Operation Cycle
                when S_EXECUTE_ALU_0 =>
                    regA_addr <= IR(4 downto 3);
                    regB_addr <= IR(2 downto 1);
                    regW_addr <= IR(4 downto 3); -- Destination register
                
                when others => null;
            end case;
        end if;
    end process;
    
    reg_write_data <= alu_result when reg_source_select = '0'
        else DR;

end Behavioral;
