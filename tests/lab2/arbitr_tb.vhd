library ieee;
use ieee.std_logic_1164.all;
use work.arbitr_types_pkg.all;
use std.env.all;

entity arbitr_tb is
end entity arbitr_tb;

architecture sim of arbitr_tb is

    constant DEVICES_NUM : integer := 4;
    constant CLK_PERIOD : time := 10 ns;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal prio : priority_vector_t(DEVICES_NUM - 1 downto 0) := (others => 0);
    signal req  : std_logic_vector(DEVICES_NUM - 1 downto 0) := (others => '0');
    signal resp : std_logic_vector(DEVICES_NUM - 1 downto 0);

begin

    dut : entity work.arbitr
        generic map (DEVICES_NUM => DEVICES_NUM)
        port map (
            i_clk => clk,
            i_reset => rst,
            i_prioreties => prio,
            i_request => req,
            o_response => resp
        );

    clk <= not clk after CLK_PERIOD / 2;

    stim : process
    begin
        rst <= '1';
        wait for 3 * CLK_PERIOD;
        rst <= '0';
        wait until falling_edge(clk);

        prio <= (0, 0, 0, 0);

        req <= "0001";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0001"
            report "T1 fail: expected 0001, got " & to_string(resp)
            severity failure;

        req <= "0010";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0010"
            report "T2 fail: expected 0010, got " & to_string(resp)
            severity failure;

        req <= "0011";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0001"
            report "T3 fail: expected 0001, got " & to_string(resp)
            severity failure;

        req <= "0011";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0010"
            report "T4 fail: expected 0010, got " & to_string(resp)
            severity failure;

        req <= "0011";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0001"
            report "T5 fail: expected 0001, got " & to_string(resp)
            severity failure;

        req <= "1000";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "1000"
            report "T6 fail: expected 1000, got " & to_string(resp)
            severity failure;

        req <= "0000";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0000"
            report "T7 fail: expected 0000 (no req), got " & to_string(resp)
            severity failure;

        rst <= '1';
        wait for 3 * CLK_PERIOD;
        rst <= '0';
        wait until falling_edge(clk);

        prio <= (0 => 0, 1 => 0, 2 => 1, 3 => 1);

        wait for 2 * CLK_PERIOD;
        wait until falling_edge(clk);

        req  <= "0101";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0100"
            report "T8 fail: high prio should win, got " & to_string(resp)
            severity failure;

        req <= "0011";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0001"
            report "T9 fail: expected 0001, got " & to_string(resp)
            severity failure;

        req <= "1100";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "1000"
            report "T10 fail: expected 1000 (dev3 with ctr=3), got " & to_string(resp)
            severity failure;

        req <= "0011";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0010"
            report "T11 CRITICAL: RR state lost after preemption, got "
                   & to_string(resp)
            severity failure;

        rst <= '1';
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0000"
            report "T12 fail: reset should clear resp, got " & to_string(resp)
            severity failure;
        rst <= '0';
        wait until falling_edge(clk);

        req <= "0011";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0001"
            report "T13 fail: expected 0001 after reset, got " & to_string(resp)
            severity failure;

        report "ALL TESTS PASSED";

        wait for 1 ns;
        finish;
    end process;

end architecture sim;