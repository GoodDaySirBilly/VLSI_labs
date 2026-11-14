library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mem_block_types_pkg is

    constant C_DATA_WIDTH : integer := 16;
    constant C_ADDR_WIDTH : integer := 4;

    type mem_block_mosi_t is record
        addr : std_logic_vector(C_ADDR_WIDTH - 1 downto 0);
        addr_valid : std_logic;
        rw : std_logic;
        wdata : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        wdata_valid : std_logic;
        rdata_ready : std_logic;
    end record mem_block_mosi_t;

    type mem_block_miso_t is record
        addr_ack : std_logic;
        wdata_ack : std_logic;
        rdata : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        rdata_valid : std_logic;
    end record mem_block_miso_t;

    
    type mem_block_mosi_array_t is array (integer range <>) of mem_block_mosi_t;
    type mem_block_miso_array_t is array (integer range <>) of mem_block_miso_t;
    type addr_array_t is array (natural range <>) of std_logic_vector(C_ADDR_WIDTH - 1 downto 0);
    type data_array_t is array (natural range <>) of std_logic_vector(C_DATA_WIDTH - 1 downto 0);
end package mem_block_types_pkg;