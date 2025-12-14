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


    component regfile is
        port (
            clk           : in  std_logic;
            write_enable  : in  std_logic;
            write_address : in  std_logic_vector(REG_INDEX_W-1 downto 0);
            write_data    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            readA_address : in  std_logic_vector(REG_INDEX_W-1 downto 0);
            readB_address : in  std_logic_vector(REG_INDEX_W-1 downto 0);
            readA_data    : out std_logic_vector(DATA_WIDTH-1 downto 0);
            readB_data    : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component alu is
        port (
            A      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            B      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            ALU_op : in  alu_op_t;
            Result : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component memory is
        port (
            clk      : in  std_logic;
            addr     : in  std_logic_vector(MEM_ADDR_W-1 downto 0);
            data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            write_en : in  std_logic;
            read_en  : in  std_logic;
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

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
    

    type state_types is (
        S_RESET, 
        S_FETCH_0, 
        S_FETCH_1, 
        S_FETCH_2, 
        S_DECODE, 
        S_HALT
    );
    signal current_state, next_state : state_types;

begin
    u_regfile : regfile
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

    u_alu : alu
        port map(
            A => regA,
            B => regB,
            ALU_op => alu_op,
            Result => alu_result
        );
    
    u_memory : memory
        port map(
            clk => clk,
            addr => AR,
            data_in => regB,
            write_en => memory_write_en,
            read_en => memory_read_en,
            data_out => memory_data_out
        );
    
    FSM_reg_proc : process(clk, rst)
    begin
        if rst = '1' then
            current_state <= S_RESET;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;    

    pc_ar_ir_proc : process(clk, rst)
    begin
        if rst = '1' then
            PC <= (others => '0');
            AR <= (others => '0');
            IR <= (others => '0');
            DR <= (others => '0');
        elsif rising_edge(clk) then
            case current_state is
                when S_FETCH_0 => 
                    AR <= PC;
                when S_FETCH_1 =>
                    DR <= memory_data_out;
                when S_FETCH_2 =>
                    IR <= DR;
                    PC <= std_logic_vector(unsigned(PC) + 1);
                when others => null;
            end case;
        end if;
    end process;
    
    control_fsm_proc : process(current_state)
    begin
        memory_read_en <= '0';
        memory_write_en <= '0';
        next_state <= current_state;
        
        case state is
            when S_RESET =>
                next_state <= S_FETCH_0;
            when S_FETCH_0 =>
                memory_read_en <= '1';
                next_state <= S_FETCH_1;
            when S_FETCH_1 =>
                memory_read_en <= '1';
                next_state <= S_FETCH_2;
            when S_FETCH_2 =>
                next_state <= S_DECODE;
            when S_DECODE =>
                null;
        
    end process;


    reg_write_data <= alu_result when reg_source_select = '0'
        else DR;

end Behavioral;
