
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types_pkg.all;

entity regfile is
    port (
        clk : in std_logic;
        write_enable : in std_logic;
        write_address : in std_logic_vector(REG_INDEX_W-1 downto 0);
        write_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
        readA_address : in std_logic_vector(REG_INDEX_W-1 downto 0);
        readB_address : in std_logic_vector(REG_INDEX_W-1 downto 0);
        readA_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
        readB_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity regfile;

architecture Behavioral of regfile is
    type reg_array_t is array (0 to REG_COUNT-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal registers : reg_array_t := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if write_enable = '1' then
                registers( to_integer( unsigned(write_address) ) ) <= write_data;
            end if;
        end if;
    end process;
    readA_data <= registers( to_integer( unsigned(readA_address) ) );
    readB_data <= registers( to_integer( unsigned(readB_address) ) );


end Behavioral;
