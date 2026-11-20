library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity comb_schema_tb is
end entity comb_schema_tb;

architecture sim of comb_schema_tb is
    signal a, b, c, d : std_logic := '0';
    signal y1, y2     : std_logic;
    signal y_ref      : std_logic;
begin

    dut1 : entity work.comb_schema
        port map (A => a, B => b, C => c, D => d, Y => y1);

    dut2 : entity work.comb_schema_block
        port map (A => a, B => b, C => c, D => d, Y => y2);

    y_ref <= a and not (b or c or d);

    stimulus : process
    begin
        for i in 0 to 15 loop
            (a, b, c, d) <= std_logic_vector(to_unsigned(i, 4));
            wait for 1 ns;   -- дать комбинационной логике установиться

            assert y1 = y_ref
                report "DUT1 mismatch at i=" & integer'image(i)
                severity failure;
            assert y2 = y_ref
                report "DUT2 mismatch at i=" & integer'image(i)
                severity failure;
        end loop;

        report "All tests passed" severity note;
        finish;
    end process;

end architecture sim;