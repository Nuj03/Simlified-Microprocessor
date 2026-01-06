library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types_pkg.all;

entity tb_cpu_core is
end entity;

architecture Behavioral of tb_cpu_core is

    -- Clock and reset signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    -- CPU outputs for monitoring
    signal PC_out : std_logic_vector(MEM_ADDR_W-1 downto 0);
    signal IR_out : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- CPU input/output ports internally
    -- Only clk and rst are inputs, outputs exposed
begin

    -- Instantiate the CPU
    uut: entity work.cpu_core
        port map(
            clk => clk,
            rst => rst,
            PC_out => PC_out,
            IR_out => IR_out
        );

    -- Clock generation: 10 ns period
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Reset pulse
    rst_process : process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait;
    end process;

    -- Monitor process
    monitor_proc : process(clk)
    begin
        if rising_edge(clk) then
            report "Time=" & time'image(now) &
                   " PC=" & integer'image(to_integer(unsigned(PC_out))) &
                   " IR=" & to_hstring(IR_out);
        end if;
    end process;

end architecture;
