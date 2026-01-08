library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types_pkg.all;

entity cpu_core is
    port(
        clk : in std_logic;
        rst : in std_logic;
        
        -- PROGRAMMER INTERFACE (Inputs from Testbench)
        prog_we_in   : in std_logic;
        prog_addr_in : in std_logic_vector(MEM_ADDR_W-1 downto 0);
        prog_data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);

        -- DEBUG PORTS
        PC_view : out std_logic_vector(MEM_ADDR_W-1 downto 0);
        R0_view : out std_logic_vector(DATA_WIDTH-1 downto 0);
        R1_view : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity cpu_core;

architecture Behavioral of cpu_core is

    -- Internal CPU Signals
    signal PC : std_logic_vector(MEM_ADDR_W-1 downto 0);
    signal IR : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal AR : std_logic_vector(MEM_ADDR_W-1 downto 0);
    signal DR : std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- Register File Signals
    signal regW_addr, regA_addr, regB_addr : std_logic_vector(REG_INDEX_W-1 downto 0);
    signal regA, regB : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg_write_en, reg_source_select : std_logic;
    signal reg_write_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- ALU Signals
    signal alu_result : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal alu_op : alu_op_t;
    
    -- MEMORY SIGNALS (These are the ones causing your error)
    signal cpu_mem_read  : std_logic;
    signal cpu_mem_write : std_logic; -- <--- This must be declared here!
    signal memory_data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- FSM Signals
    signal current_state, next_state : state_types;

    -- Multiplexer Signals (Switching between CPU and Testbench)
    signal mux_mem_addr : std_logic_vector(MEM_ADDR_W-1 downto 0);
    signal mux_mem_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mux_mem_we   : std_logic;

begin

    -- 1. MEMORY MULTIPLEXER
    -- When RST is '1', Testbench controls memory (Bootloader Mode)
    -- When RST is '0', CPU controls memory (Run Mode)
    mux_mem_addr <= prog_addr_in when rst = '1' else AR;
    mux_mem_data <= prog_data_in when rst = '1' else regB;
    mux_mem_we   <= prog_we_in   when rst = '1' else cpu_mem_write;

    -- 2. INSTANTIATIONS
    u_regfile : entity work.regfile port map(
        clk => clk, write_enable => reg_write_en, write_address => regW_addr,
        write_data => reg_write_data, readA_address => regA_addr,
        readB_address => regB_addr, readA_data => regA, readB_data => regB
    );

    u_alu : entity work.alu port map(
        A => regA, B => regB, ALU_op => alu_op, Result => alu_result
    );
    
    u_memory : entity work.memory port map(
        clk => clk, 
        addr => mux_mem_addr,    -- Connected to Mux
        data_in => mux_mem_data, -- Connected to Mux
        write_en => mux_mem_we,  -- Connected to Mux
        read_en => '1',          -- Always reading is fine for this simple RAM
        data_out => memory_data_out
    );

    u_control_unit : entity work.control_unit port map(
        clk => clk, rst => rst, IR => IR, 
        mem_read_en => cpu_mem_read,   -- Output from Control Unit
        mem_write_en => cpu_mem_write, -- Output from Control Unit (Connected to Signal)
        alu_op => alu_op,
        reg_write_en => reg_write_en, reg_src_sel => reg_source_select, next_state => next_state
    );
    
    -- 3. PROCESSES
    
    -- State Update
    process(clk, rst) begin
        if rst = '1' then 
            current_state <= S_RESET;
            PC <= (others => '0'); AR <= (others => '0'); IR <= (others => '0'); DR <= (others => '0');
        elsif rising_edge(clk) then
            current_state <= next_state;
            
            -- Datapath Updates
            case current_state is
                when S_FETCH_0 => AR <= PC;
                when S_FETCH_1 => DR <= memory_data_out;
                when S_FETCH_2 => IR <= DR; PC <= std_logic_vector(unsigned(PC) + 1);
                
                when S_EXECUTE_LOAD_0 => AR <= IR(2 downto 0);
                when S_EXECUTE_LOAD_1 => DR <= memory_data_out;
                when S_EXECUTE_LOAD_2 => regW_addr <= IR(4 downto 3);
                
                when S_EXECUTE_STORE_0 => AR <= IR(2 downto 0); regB_addr <= IR(4 downto 3);
                
                when S_EXECUTE_ALU_0 => regA_addr <= IR(4 downto 3); regB_addr <= IR(2 downto 1); regW_addr <= IR(4 downto 3);
                
                when others => null;
            end case;
        end if;
    end process;
    
    reg_write_data <= alu_result when reg_source_select = '0' else DR;

    -- 4. DEBUG OUTPUTS
    PC_view <= PC;
    R0_view <= regA when regA_addr = "00" else (others => '0');
    R1_view <= regA when regA_addr = "01" else (others => '0');

end Behavioral;