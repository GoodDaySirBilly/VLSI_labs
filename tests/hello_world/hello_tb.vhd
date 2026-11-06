library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity tb_hello is
end entity tb_hello;

architecture sim of tb_hello is
    signal a : std_logic := '0';
    signal y : std_logic;
begin

    dut : entity work.hello
        port map (
            a => a,
            y => y
        );

    stimulus : process
    begin

        a <= '0';
        wait for 10 ns;

        assert y = '0'
            report "Test failed: expected 0"
            severity failure;

        a <= '1';
        wait for 10 ns;

        assert y = '1'
            report "Test failed: expected 1"
            severity failure;

        report "Hello World! All tests passed." severity note;

        wait for 1 ns;
        finish;
    end process;

end architecture sim;