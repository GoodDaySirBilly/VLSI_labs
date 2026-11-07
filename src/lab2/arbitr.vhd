library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.arbitr_types_pkg.all;

entity arbitr is
    generic (
        DEVICES_NUM : integer := 10
    );
    port (
        i_clk : in std_logic;
        i_reset : in std_logic;

        i_prioreties : in priority_vector_t(DEVICES_NUM - 1 downto 0);
        
        i_request : in std_logic_vector(DEVICES_NUM - 1 downto 0);
        o_response : out std_logic_vector(DEVICES_NUM - 1 downto 0)
    );
end entity arbitr;

architecture rtl of arbitr is

    type priority_masks_array_t is array (0 to (PRIORITY_LEVELS - 1)) of std_logic_vector(DEVICES_NUM - 1 downto 0);
    signal priority_masks_array : priority_masks_array_t := (others => (others => '0'));

    type counters_array_t is array (0 to (PRIORITY_LEVELS -1)) of integer range 0 to (DEVICES_NUM - 1);
    signal counters_array : counters_array_t := (others => 0);

begin

    process(i_prioreties)
        variable mask : std_logic_vector(DEVICES_NUM - 1 downto 0);
    begin
        for level in 0 to (PRIORITY_LEVELS - 1) loop

            mask := (others => '0');

            for idx in 0 to (DEVICES_NUM - 1) loop
                if i_prioreties(idx) = level then
                    mask(idx) := '1';
                end if;
            end loop;

            priority_masks_array(level) <= mask;
        end loop;
    end process;

    process(i_clk, i_reset)
        variable current_priority : priority_t;
        variable actual_request : std_logic_vector(DEVICES_NUM - 1 downto 0);
        variable idx_winner : integer range 0 to (DEVICES_NUM - 1);
        variable idx_start : integer range 0 to (DEVICES_NUM - 1);
    begin

        if i_reset = '1' then

            counters_array <= (others => 0);
            o_response <= (others => '0');

        elsif rising_edge(i_clk) then

            o_response <= (others => '0');

            current_priority := -1;
            for level in (PRIORITY_LEVELS - 1) downto 0 loop
                if or(priority_masks_array(level) and i_request) = '1' then
                    current_priority := level;
                    exit;
                end if;
            end loop;

            if current_priority >= 0 then
                actual_request := priority_masks_array(current_priority) and i_request;
                idx_start := counters_array(current_priority);

                for idx_offset in 0 to (DEVICES_NUM - 1) loop
                    idx_winner := (idx_start + idx_offset) mod DEVICES_NUM;
                    if actual_request(idx_winner) = '1' then
                        o_response(idx_winner) <= '1';
                        counters_array(current_priority) <= (idx_winner + 1) mod DEVICES_NUM;
                        exit;
                    end if;
                end loop;
            end if;

        end if;
    end process;


end architecture rtl;