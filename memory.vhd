
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
    --memory array declaration
    type memory_array_t is array (0 to MEM_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem : memory_array_t := (
        0 => "00000101", -- LOAD R0, [5]
        1 => "00001110", -- LOAD R1, [6]
        2 => "01000010", -- ADD R0 = R0 + R1  (RegA=R0, RegB=R1)
        3 => "00101111", -- STORE R1, [7]
        4 => "11100000", -- HALT
        5 => "00011111", -- Data: 31
        6 => "00001010", -- Data: 10
        others => (others => '0')
    );
    
begin

    process(clk)
        begin
            if rising_edge(clk) then
            --write operation
                if write_en = '1' then
                    mem(to_integer(unsigned(addr))) <= data_in;
                end if;
            end if;
    end process;
    
    --read operation
    data_out <= mem(to_integer(unsigned(addr))) when read_en = '1'
        else (others => '0');
    
    
    

end Behavioral;
