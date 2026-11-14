library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_block_types_pkg.all;

entity mem_block_interface_fsm is 
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;

        i_mosi : in mem_block_mosi_t;
        o_miso : out mem_block_miso_t;

        i_rdata : in std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        o_addr : out std_logic_vector(C_ADDR_WIDTH - 1 downto 0);
        o_wdata : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        o_we : out std_logic
    );
end entity mem_block_interface_fsm;

architecture rtl of mem_block_interface_fsm is
    type state_t is (IDLE, START, READ, WAIT_WRITE, WRITE, FINISH);
    signal state, next_state : state_t;

    signal reg_addr : std_logic_vector(C_ADDR_WIDTH - 1 downto 0);
    signal reg_rw   : std_logic;
    signal reg_word : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
begin

    SYNC_PROC : process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                state <= IDLE;
                reg_addr <= (others => '0');
                reg_rw <= '0';
                reg_word <= (others => '0');
            else

                state <= next_state;

                if state = IDLE and next_state = START then
                    reg_addr <= i_mosi.addr;
                    reg_rw <= i_mosi.rw;
                end if;

                if state = WAIT_WRITE and i_mosi.wdata_valid = '1' then 
                    reg_word <= i_mosi.wdata;
                end if;

            end if;
        end if;
         
    end process;

    NEXT_STATE_PROC : process(state, reg_rw, i_mosi.addr_valid, i_mosi.rdata_ready, i_mosi.wdata_valid)
    begin
         
        next_state <= state;

        case state is
            when IDLE =>
                if i_mosi.addr_valid = '1' then 
                    next_state <= START;
                end if;
            when START =>
                if reg_rw = '0' then
                    next_state <= READ;
                else 
                    next_state <= WAIT_WRITE;
                end if;
            when READ =>
                if i_mosi.rdata_ready = '1' then
                    next_state <= FINISH;
                end if;
            when WAIT_WRITE =>
                if i_mosi.wdata_valid = '1' then
                    next_state <= WRITE;
                end if;
            when WRITE =>
                next_state <= FINISH;
            when FINISH =>
                next_state <= IDLE;
        end case;

    end process;

    OUTPUT_PROC : process(state, reg_addr, reg_word, i_rdata)
    begin
        o_miso.addr_ack <= '0';
        o_miso.wdata_ack <= '0';
        o_miso.rdata_valid <= '0';
        o_we <= '0';

        o_miso.rdata <= i_rdata;
        o_addr <= reg_addr;
        o_wdata <= reg_word;

        case state is
            when IDLE =>
                null;
            when START =>
                o_miso.addr_ack <= '1';
            when READ =>
                o_miso.rdata_valid <= '1';
            when WAIT_WRITE =>
                null;
            when WRITE =>
                o_miso.wdata_ack <= '1';
                o_we <= '1';
            when FINISH =>
                null;
        end case;

    end process;

end architecture rtl;