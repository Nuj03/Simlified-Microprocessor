
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types_pkg.all;

entity memory is
    port (
        clk : in std_logic;
        addr : in std_logic_vector(MEM_ADDR_W-1 downto 0);
        data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        write_en : in std_logic;
        read_en : in std_logic;
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity memory;

architecture Behavioral of memory is

    type memory_array_t is array (0 to MEM_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem : memory_array_t := (others => (others => '0'));
    
begin

    process(clk)
        begin
            if rising_edge(clk) then
                if write_en = '1' then
                    mem(to_integer(unsigned(addr))) <= data_in;
                end if;
            end if;
    end process;
    
    data_out <= mem(to_integer(unsigned(addr))) when read_en = '1'
        else (others => '0');
    
    
    

end Behavioral;
