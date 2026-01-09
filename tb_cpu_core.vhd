library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types_pkg.all;

entity tb_cpu_core is
end entity;

architecture Behavioral of tb_cpu_core is

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

begin

    -- Instantiate the CPU
    CPU: entity work.cpu_core
        port map(
            clk => clk,
            rst => rst
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
        wait for 10 ns;
        rst <= '0';
        wait;
    end process;

end architecture;
