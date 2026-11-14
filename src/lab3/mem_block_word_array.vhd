library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_block_types_pkg.all;

entity mem_block_word_array is 
    generic (
        INTERFACES_NUM : integer := 4
    );
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_addr : in addr_array_t(INTERFACES_NUM - 1 downto 0);
        i_wdata : in data_array_t(INTERFACES_NUM - 1 downto 0);
        o_rdata : out data_array_t(INTERFACES_NUM - 1 downto 0);
        i_we : in std_logic_vector(INTERFACES_NUM - 1 downto 0)
    );
end entity mem_block_word_array;

architecture rtl of mem_block_word_array is

    type word_array_t is array (0 to (2**C_ADDR_WIDTH) - 1) of std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal word_array : word_array_t := (others => (others => '0'));

begin

    process(i_clk)
    begin
        if rising_edge(i_clk) then

            if i_rst = '1' then

                word_array <= (others => (others => '0'));
                o_rdata <= (others => (others => '0'));

            else
        
                for i in 0 to INTERFACES_NUM - 1 loop

                    if i_we(i) = '1' then
                        word_array(to_integer(unsigned(i_addr(i)))) <= i_wdata(i);
                    end if;
                    
                    o_rdata(i) <= word_array(to_integer(unsigned(i_addr(i))));
                
                end loop;
            end if;
        end if;

    end process;

end architecture rtl;