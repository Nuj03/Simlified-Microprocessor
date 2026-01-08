library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types_pkg.all;

entity tb_cpu is
end tb_cpu;

architecture Behavioral of tb_cpu is

    component cpu_core
    port(
        clk, rst : in std_logic;
        -- Programmer Ports
        prog_we_in   : in std_logic;
        prog_addr_in : in std_logic_vector(MEM_ADDR_W-1 downto 0);
        prog_data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        -- Debug Ports
        PC_view :  out std_logic_vector(MEM_ADDR_W-1 downto 0);
        R0_view, R1_view : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
    end component;

    -- Testbench Signals
    signal clk, rst : std_logic := '0';
    signal prog_we : std_logic := '0';
    signal prog_addr : std_logic_vector(MEM_ADDR_W-1 downto 0) := (others => '0');
    signal prog_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    
    signal PC_view : std_logic_vector(MEM_ADDR_W-1 downto 0);
    signal R0_view, R1_view : std_logic_vector(DATA_WIDTH-1 downto 0);
    constant clk_period : time := 10 ns;

    -- TESTBENCH STATE MACHINE
    type tb_state_t is (
        TB_RESET,       -- Hold Reset
        TB_WRITE_CMD1,  -- Write 1st Instruction
        TB_WRITE_CMD2,  -- Write 2nd Instruction
        TB_WRITE_CMD3,  -- Write 3rd Instruction
        TB_WRITE_DATA1, -- Write Data 10
        TB_WRITE_DATA2, -- Write Data 5
        TB_RUN,         -- Release Reset, Run CPU
        TB_DONE         -- Finished
    );
    signal tb_state : tb_state_t := TB_RESET;

begin

    uut: cpu_core port map (
        clk => clk, rst => rst,
        prog_we_in => prog_we, prog_addr_in => prog_addr, prog_data_in => prog_data,
        PC_view => PC_view, R0_view => R0_view, R1_view => R1_view
    );

    -- Clock Generation
    clk_process :process begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- MAIN STIMULUS FSM
    stim_proc: process(clk)
    begin
        if rising_edge(clk) then
            case tb_state is
                
                -- 1. Reset Phase: Hold CPU in Reset
                when TB_RESET =>
                    rst <= '1';
                    prog_we <= '0';
                    tb_state <= TB_WRITE_CMD1;

                -- 2. Inject Command 1: LOAD R0, [3] (0x03)
                when TB_WRITE_CMD1 =>
                    prog_addr <= "000"; -- Address 0
                    prog_data <= x"03"; -- LOAD R0, [3]
                    prog_we   <= '1';
                    tb_state  <= TB_WRITE_CMD2;

                -- 3. Inject Command 2: LOAD R1, [4] (0x0C)
                when TB_WRITE_CMD2 =>
                    prog_addr <= "001"; -- Address 1
                    prog_data <= x"0C"; -- LOAD R1, [4]
                    prog_we   <= '1';
                    tb_state  <= TB_WRITE_CMD3;

                -- 4. Inject Command 3: ADD R0, R1 (0x42)
                when TB_WRITE_CMD3 =>
                    prog_addr <= "010"; -- Address 2
                    prog_data <= x"42"; -- ADD R0, R1
                    prog_we   <= '1';
                    tb_state  <= TB_WRITE_DATA1;

                -- 5. Inject Data: 10 at Addr 3
                when TB_WRITE_DATA1 =>
                    prog_addr <= "011"; -- Address 3
                    prog_data <= x"0A"; -- Val 10
                    prog_we   <= '1';
                    tb_state  <= TB_WRITE_DATA2;
                    
                -- 6. Inject Data: 5 at Addr 4
                when TB_WRITE_DATA2 =>
                    prog_addr <= "100"; -- Address 4
                    prog_data <= x"05"; -- Val 5
                    prog_we   <= '1';
                    tb_state  <= TB_RUN;

                -- 7. Run Phase: Release Reset, Disable Programmer
                when TB_RUN =>
                    rst <= '0';
                    prog_we <= '0'; -- Stop writing
                    -- Stay here while CPU runs
                    if unsigned(PC_view) >= 4 then
                         tb_state <= TB_DONE;
                    end if;
                    
                when TB_DONE =>
                    -- Simulation effectively stops here
                    null;
                    
            end case;
        end if;
    end process;

end Behavioral;