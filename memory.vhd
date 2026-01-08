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
    
    -- PROGRAM MEMORY INITIALIZATION
    -- 0: LOAD R0, [4]  (Op:000 Dest:00 Addr:100) -> 0x04
    -- 1: LOAD R1, [5]  (Op:000 Dest:01 Addr:101) -> 0x0D
    -- 2: ADD  R0, R1   (Op:010 Dest:00 Src:01)   -> 0x42
    -- 3: STORE R0, [6] (Op:001 Src:00  Addr:110) -> 0x26
    -- 4: DATA (10)     (0x0A)
    -- 5: DATA (5)      (0x05)
    -- 6: EMPTY         (Will receive result 15)
    -- 7: HALT          (Op:111)                  -> 0xE0
    
    signal mem : memory_array_t := (
        others => (others => '0')
    );
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if write_en = '1' then
                mem(to_integer(unsigned(addr))) <= data_in;
            end if;
        end if;
    end process;
    
    data_out <= mem(to_integer(unsigned(addr))) when read_en = '1' else (others => '0');
end Behavioral;