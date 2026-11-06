library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity comb_schema_tb is
end entity comb_schema_tb;

architecture sim of comb_schema_tb is
    signal a : std_logic := '0';
    signal b : std_logic := '0';
    signal c : std_logic := '0';
    signal d : std_logic := '0';
    signal y : std_logic;
begin

    dut : entity work.comb_schema
        port map (
            a => A,
            b => B,
            c => C,
            d => D,
            y => Y
        );

    stimulus : process
    begin
        
        a <= '0'; b <= '0'; c <= '0'; d <= '0'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '0'; b <= '0'; c <= '0'; d <= '1'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '0'; b <= '0'; c <= '1'; d <= '0'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '0'; b <= '0'; c <= '1'; d <= '1'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '0'; b <= '1'; c <= '0'; d <= '0'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '0'; b <= '1'; c <= '0'; d <= '1'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '0'; b <= '1'; c <= '1'; d <= '0'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '0'; b <= '1'; c <= '1'; d <= '1'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '1'; b <= '0'; c <= '0'; d <= '0'; wait for 2 ns;
        assert y = '1' report "Test failed: expected 1" severity failure;

        a <= '1'; b <= '0'; c <= '0'; d <= '1'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '1'; b <= '0'; c <= '1'; d <= '0'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '1'; b <= '0'; c <= '1'; d <= '1'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '1'; b <= '1'; c <= '0'; d <= '0'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '1'; b <= '1'; c <= '0'; d <= '1'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '1'; b <= '1'; c <= '1'; d <= '0'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        a <= '1'; b <= '1'; c <= '1'; d <= '1'; wait for 2 ns;
        assert y = '0' report "Test failed: expected 0" severity failure;

        wait for 1 ns;
        finish;
    end process;

end architecture sim;