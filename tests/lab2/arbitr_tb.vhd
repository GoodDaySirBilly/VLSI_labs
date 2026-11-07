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
        -- ============================================================
        -- Сброс
        -- ============================================================
        rst <= '1';
        wait for 3 * CLK_PERIOD;
        rst <= '0';
        wait until falling_edge(clk);

        -- Все устройства low-priority
        prio <= (0, 0, 0, 0);

        -- ============================================================
        -- T1: один запрос -> грант устройству 0
        -- ============================================================
        req <= "0001";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0001"
            report "T1 fail: expected 0001, got " & to_string(resp)
            severity failure;

        -- ============================================================
        -- T2: один запрос -> грант устройству 1
        -- ============================================================
        req <= "0010";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0010"
            report "T2 fail: expected 0010, got " & to_string(resp)
            severity failure;

        -- ============================================================
        -- T3: два запроса, counter(0)=2 -> wrap -> победил 0
        -- ============================================================
        req <= "0011";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0001"
            report "T3 fail: expected 0001, got " & to_string(resp)
            severity failure;

        -- ============================================================
        -- T4: counter(0)=1 -> победил 1
        -- ============================================================
        req <= "0011";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0010"
            report "T4 fail: expected 0010, got " & to_string(resp)
            severity failure;

        -- ============================================================
        -- T5: counter(0)=2 -> wrap -> победил 0
        -- ============================================================
        req <= "0011";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0001"
            report "T5 fail: expected 0001, got " & to_string(resp)
            severity failure;

        -- ============================================================
        -- T6: запрашивает только 3, counter(0)=1
        --     скан 1,2,3 -> должен победить 3 (не залипнуть на 1!)
        -- ============================================================
        req <= "1000";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "1000"
            report "T6 fail: expected 1000, got " & to_string(resp)
            severity failure;

        -- ============================================================
        -- T7: нет запросов -> resp = 0
        -- ============================================================
        req <= "0000";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0000"
            report "T7 fail: expected 0000 (no req), got " & to_string(resp)
            severity failure;

        -- ============================================================
        -- T8: высокий приоритет вытесняет низкий
        --   устройства 0,1 -> уровень 0
        --   устройства 2,3 -> уровень 1
        --   запрос от 0 (low) и 2 (high) -> должен победить 2
        -- ============================================================
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

        -- ============================================================
        -- T9: возврат к low-prio, counter(0)=0 -> победил 0
        -- ============================================================
        req <= "0011";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0001"
            report "T9 fail: expected 0001, got " & to_string(resp)
            severity failure;

        -- ============================================================
        -- T10: high-prio снова, counter(1)=0 -> должен победить 2
        -- (после T8 counter(1) был 3; здесь counter(1)=0 был присвоен... 
        --  проверим: в T8 победил 2 -> counter(1)=3. Значит на T10 
        --  скан 3->2(wrap)->2 req -> победит 2. Проверяем!)
        -- ============================================================
        req <= "1100";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "1000"
            report "T10 fail: expected 1000 (dev3 with ctr=3), got " & to_string(resp)
            severity failure;

        -- ============================================================
        -- T11 (КРИТИЧНО): RR-состояние low-prio сохранилось!
        --  counter(0)=1 (после T9). High-prio T8/T10 не должен был 
        --  трогать counter(0). Значит следующий победитель в группе 
        --  low-prio — устройство 1 (не 0).
        --  Если бы счётчик был общий — counter(0) обнулился бы и 
        --  победило бы устройство 0. Этот тест ловит именно тот баг.
        -- ============================================================
        req <= "0011";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0010"
            report "T11 CRITICAL: RR state lost after preemption, got "
                   & to_string(resp)
            severity failure;

        -- ============================================================
        -- T12: сброс
        -- ============================================================
        rst <= '1';
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0000"
            report "T12 fail: reset should clear resp, got " & to_string(resp)
            severity failure;
        rst <= '0';
        wait until falling_edge(clk);

        -- ============================================================
        -- T13: после сброса counter(0)=0 -> снова побеждает устройство 0
        -- ============================================================
        req <= "0011";
        wait until rising_edge(clk); wait for 1 ns;
        assert resp = "0001"
            report "T13 fail: expected 0001 after reset, got " & to_string(resp)
            severity failure;

        report "=== ALL TESTS PASSED ===";

        wait for 1 ns;
        finish;
    end process;

end architecture sim;