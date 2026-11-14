library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_block_types_pkg.all;


entity mem_block is
    generic (
        INTERFACES_NUM : integer := 4
    );
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_mosi : in mem_block_mosi_array_t(INTERFACES_NUM - 1 downto 0);
        o_miso : out mem_block_miso_array_t(INTERFACES_NUM - 1 downto 0)
    );
end entity mem_block;

architecture structural of mem_block is
    signal interface_addr : addr_array_t (INTERFACES_NUM - 1 downto 0);
    signal interface_wdata : data_array_t (INTERFACES_NUM - 1 downto 0);
    signal interface_rdata : data_array_t (INTERFACES_NUM - 1 downto 0);
    signal interface_we : std_logic_vector (INTERFACES_NUM - 1 downto 0);
begin

    GEN_INTERFACES : for i in 0 to INTERFACES_NUM - 1 generate
        U_FSM : entity work.mem_block_interface_fsm
            port map (
                i_clk  => i_clk,
                i_rst  => i_rst,

                i_mosi => i_mosi(i),
                o_miso => o_miso(i),

                o_addr  => interface_addr(i),
                o_wdata => interface_wdata(i),
                o_we    => interface_we(i),
                i_rdata => interface_rdata(i)
            );
    end generate GEN_INTERFACES;

    U_RAM : entity work.mem_block_word_array
        generic map (
            INTERFACES_NUM => INTERFACES_NUM
        )
        port map (
            i_clk => i_clk,
            i_rst => i_rst,
            i_addr => interface_addr,
            i_wdata => interface_wdata,
            o_rdata => interface_rdata,
            i_we => interface_we
        );

end architecture structural;