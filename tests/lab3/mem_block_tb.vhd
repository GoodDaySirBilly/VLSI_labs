library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;
use work.mem_block_types_pkg.all;

entity mem_block_tb is
end entity mem_block_tb;

architecture sim of mem_block_tb is
    constant INTERFACES_NUM : integer := 4;
    constant CLK_PERIOD : time := 10 ns;
    
    signal clk  : std_logic := '0';
    signal rst  : std_logic := '1';
    signal mosi : mem_block_mosi_array_t(INTERFACES_NUM - 1 downto 0);
    signal miso : mem_block_miso_array_t(INTERFACES_NUM - 1 downto 0);

    -- Вспомогательная процедура: полный цикл записи слова
    procedure do_write(
        constant idx    : in integer;
        constant addr   : in std_logic_vector(C_ADDR_WIDTH - 1 downto 0);
        constant data   : in std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        signal sig_mosi : out mem_block_mosi_array_t(INTERFACES_NUM - 1 downto 0); -- переименовано
        signal sig_miso : in  mem_block_miso_array_t(INTERFACES_NUM - 1 downto 0); -- переименовано
        signal sig_clk  : in  std_logic                                            -- переименовано
    ) is
    begin
        -- 1. Выставляем адрес
        sig_mosi(idx).addr <= addr;
        sig_mosi(idx).rw <= '1';
        sig_mosi(idx).addr_valid <= '1';
        
        wait until rising_edge(sig_clk);
        while sig_miso(idx).addr_ack /= '1' loop
            wait until rising_edge(sig_clk);
        end loop;
        sig_mosi(idx).addr_valid <= '0';

        -- 2. Выставляем данные
        sig_mosi(idx).wdata <= data;
        sig_mosi(idx).wdata_valid <= '1';
        
        wait until rising_edge(sig_clk);
        while sig_miso(idx).wdata_ack /= '1' loop
            wait until rising_edge(sig_clk);
        end loop;
        sig_mosi(idx).wdata_valid <= '0';
        
        wait until rising_edge(sig_clk); -- Завершение транзакции
    end procedure;

    -- Вспомогательная процедура: полный цикл чтения слова
    procedure do_read(
        constant idx    : in integer;
        constant addr   : in std_logic_vector(C_ADDR_WIDTH - 1 downto 0);
        signal sig_mosi : out mem_block_mosi_array_t(INTERFACES_NUM - 1 downto 0); -- переименовано
        signal sig_miso : in  mem_block_miso_array_t(INTERFACES_NUM - 1 downto 0); -- переименовано
        signal sig_clk  : in  std_logic;                                           -- переименовано
        variable data   : out std_logic_vector(C_DATA_WIDTH - 1 downto 0)
    ) is
    begin
        -- 1. Выставляем адрес
        sig_mosi(idx).addr <= addr;
        sig_mosi(idx).rw <= '0';
        sig_mosi(idx).addr_valid <= '1';
        
        wait until rising_edge(sig_clk);
        while sig_miso(idx).addr_ack /= '1' loop
            wait until rising_edge(sig_clk);
        end loop;
        sig_mosi(idx).addr_valid <= '0';

        -- 2. Ждем данные
        wait until rising_edge(sig_clk);
        while sig_miso(idx).rdata_valid /= '1' loop
            wait until rising_edge(sig_clk);
        end loop;
        data := sig_miso(idx).rdata;
        
        -- 3. Подтверждаем получение
        sig_mosi(idx).rdata_ready <= '1';
        wait until rising_edge(sig_clk);
        sig_mosi(idx).rdata_ready <= '0';
        wait until rising_edge(sig_clk);
    end procedure;

begin

    dut : entity work.mem_block
        generic map (
            INTERFACES_NUM => INTERFACES_NUM
        )
        port map (
            i_clk  => clk,
            i_rst  => rst,
            i_mosi => mosi,
            o_miso => miso
        );

    clk <= not clk after CLK_PERIOD/2;

    stim_proc: process
        variable rdata : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    begin
        -- Инициализация всех портов
        for i in 0 to INTERFACES_NUM - 1 loop
            mosi(i).addr <= (others => '0');
            mosi(i).addr_valid <= '0';
            mosi(i).rw <= '0';
            mosi(i).wdata <= (others => '0');
            mosi(i).wdata_valid <= '0';
            mosi(i).rdata_ready <= '0';
        end loop;

        rst <= '1';
        wait for 3 * CLK_PERIOD;
        rst <= '0';
        wait until rising_edge(clk);

        -- ========================================================
        -- TEST 1: Обычный сценарий (Запись -> Чтение)
        -- ========================================================
        report "=== TEST 1: Basic Write/Read ===";
        do_write(0, x"1", x"AAAA", mosi, miso, clk);
        do_read (0, x"1", mosi, miso, clk, rdata);
        assert rdata = x"AAAA" report "Test 1 Failed: Read data mismatch" severity failure;

        -- ========================================================
        -- TEST 2: Параллельное чтение (READ-READ разрешено)
        -- ========================================================
        report "=== TEST 2: Parallel Reads ===";
        do_write(0, x"2", x"BBBB", mosi, miso, clk);
        do_write(0, x"3", x"CCCC", mosi, miso, clk);
        
        -- Выставляем запросы на чтение одновременно
        mosi(1).addr <= x"2"; mosi(1).rw <= '0'; mosi(1).addr_valid <= '1';
        mosi(2).addr <= x"3"; mosi(2).rw <= '0'; mosi(2).addr_valid <= '1';
        
        wait until rising_edge(clk);
        while miso(1).addr_ack /= '1' or miso(2).addr_ack /= '1' loop
            wait until rising_edge(clk);
        end loop;
        mosi(1).addr_valid <= '0'; mosi(2).addr_valid <= '0';
        
        wait until rising_edge(clk);
        while miso(1).rdata_valid /= '1' or miso(2).rdata_valid /= '1' loop
            wait until rising_edge(clk);
        end loop;
        
        assert miso(1).rdata = x"BBBB" report "Test 2 Failed: Intf 1 read" severity failure;
        assert miso(2).rdata = x"CCCC" report "Test 2 Failed: Intf 2 read" severity failure;
        
        mosi(1).rdata_ready <= '1'; mosi(2).rdata_ready <= '1';
        wait until rising_edge(clk);
        mosi(1).rdata_ready <= '0'; mosi(2).rdata_ready <= '0';
        wait until rising_edge(clk);

        -- ========================================================
        -- TEST 3: Конкурентное чтение/запись (РАЗНЫЕ адреса)
        -- ========================================================
        report "=== TEST 3: Concurrent Read/Write (Diff Addr) ===";
        mosi(3).addr <= x"4"; mosi(3).rw <= '1'; mosi(3).addr_valid <= '1'; -- Запись
        mosi(0).addr <= x"1"; mosi(0).rw <= '0'; mosi(0).addr_valid <= '1'; -- Чтение
        
        wait until rising_edge(clk);
        while miso(3).addr_ack /= '1' or miso(0).addr_ack /= '1' loop
            wait until rising_edge(clk);
        end loop;
        mosi(3).addr_valid <= '0'; mosi(0).addr_valid <= '0';
        
        mosi(3).wdata <= x"DDDD"; mosi(3).wdata_valid <= '1';
        wait until rising_edge(clk);
        
        while miso(0).rdata_valid /= '1' loop wait until rising_edge(clk); end loop;
        assert miso(0).rdata = x"AAAA" report "Test 3 Failed: Concurrent read mismatch" severity failure;
        mosi(0).rdata_ready <= '1';
        
        while miso(3).wdata_ack /= '1' loop wait until rising_edge(clk); end loop;
        mosi(3).wdata_valid <= '0';
        wait until rising_edge(clk);
        mosi(0).rdata_ready <= '0';
        wait until rising_edge(clk);
        
        do_read(0, x"4", mosi, miso, clk, rdata);
        assert rdata = x"DDDD" report "Test 3 Failed: Concurrent write mismatch" severity failure;

        -- ========================================================
        -- TEST 4: Конкурентное чтение/запись (ОДИН адрес)
        -- ========================================================
        report "=== TEST 4: Concurrent Read/Write (Same Addr) ===";
        do_write(0, x"5", x"1111", mosi, miso, clk);
        
        mosi(1).addr <= x"5"; mosi(1).rw <= '1'; mosi(1).addr_valid <= '1'; -- Запись
        mosi(2).addr <= x"5"; mosi(2).rw <= '0'; mosi(2).addr_valid <= '1'; -- Чтение
        
        wait until rising_edge(clk);
        while miso(1).addr_ack /= '1' or miso(2).addr_ack /= '1' loop
            wait until rising_edge(clk);
        end loop;
        mosi(1).addr_valid <= '0'; mosi(2).addr_valid <= '0';
        
        mosi(1).wdata <= x"EEEE"; mosi(1).wdata_valid <= '1';
        wait until rising_edge(clk);
        
        while miso(2).rdata_valid /= '1' loop wait until rising_edge(clk); end loop;
        -- Синхронная RAM должна выдать СТАРОЕ значение (1111), так как запись защелкнется в этот же фронт
        assert miso(2).rdata = x"1111" report "Test 4 Failed: Expected old data" severity failure;
        mosi(2).rdata_ready <= '1';
        
        while miso(1).wdata_ack /= '1' loop wait until rising_edge(clk); end loop;
        mosi(1).wdata_valid <= '0';
        wait until rising_edge(clk);
        mosi(2).rdata_ready <= '0';
        wait until rising_edge(clk);
        
        do_read(0, x"5", mosi, miso, clk, rdata);
        assert rdata = x"EEEE" report "Test 4 Failed: Write didn't stick" severity failure;

        -- ========================================================
        -- TEST 5: Конкурентная запись (ОДИН адрес)
        -- ========================================================
        report "=== TEST 5: Concurrent Writes (Same Addr) ===";
        mosi(3).addr <= x"6"; mosi(3).rw <= '1'; mosi(3).addr_valid <= '1';
        mosi(1).addr <= x"6"; mosi(1).rw <= '1'; mosi(1).addr_valid <= '1';
        mosi(0).addr <= x"6"; mosi(0).rw <= '1'; mosi(0).addr_valid <= '1';
        
        wait until rising_edge(clk);
        while miso(3).addr_ack /= '1' or miso(1).addr_ack /= '1' or miso(0).addr_ack /= '1' loop
            wait until rising_edge(clk);
        end loop;
        mosi(3).addr_valid <= '0'; mosi(1).addr_valid <= '0'; mosi(0).addr_valid <= '0';
        
        mosi(3).wdata <= x"3333"; mosi(3).wdata_valid <= '1';
        mosi(1).wdata <= x"2222"; mosi(1).wdata_valid <= '1';
        mosi(0).wdata <= x"1111"; mosi(0).wdata_valid <= '1';
        
        wait until rising_edge(clk);
        while miso(3).wdata_ack /= '1' or miso(1).wdata_ack /= '1' or miso(0).wdata_ack /= '1' loop
            wait until rising_edge(clk);
        end loop;
        mosi(3).wdata_valid <= '0'; mosi(1).wdata_valid <= '0'; mosi(0).wdata_valid <= '0';
        wait until rising_edge(clk);
        
        do_read(0, x"6", mosi, miso, clk, rdata);
        -- Ожидаем 3333, так как интерфейс 3 обрабатывается последним в цикле 0 to 3
        assert rdata = x"3333" report "Test 5 Failed: Highest index should win (last assignment)" severity failure;

        -- ========================================================
        -- TEST 6: Back-to-Back (Без тактов простоя)
        -- ========================================================
        report "=== TEST 6: Back-to-Back Operations ===";
        mosi(2).addr <= x"7"; mosi(2).rw <= '1'; mosi(2).addr_valid <= '1';
        wait until rising_edge(clk);
        while miso(2).addr_ack /= '1' loop wait until rising_edge(clk); end loop;
        mosi(2).addr_valid <= '0';
        
        mosi(2).wdata <= x"7777"; mosi(2).wdata_valid <= '1';
        wait until rising_edge(clk);
        while miso(2).wdata_ack /= '1' loop wait until rising_edge(clk); end loop;
        mosi(2).wdata_valid <= '0';
        
        -- Сразу же, без задержек, даем команду на чтение
        mosi(2).addr <= x"7"; mosi(2).rw <= '0'; mosi(2).addr_valid <= '1';
        wait until rising_edge(clk);
        while miso(2).addr_ack /= '1' loop wait until rising_edge(clk); end loop;
        mosi(2).addr_valid <= '0';
        
        wait until rising_edge(clk);
        while miso(2).rdata_valid /= '1' loop wait until rising_edge(clk); end loop;
        assert miso(2).rdata = x"7777" report "Test 6 Failed: Back-to-Back failed" severity failure;
        mosi(2).rdata_ready <= '1';
        wait until rising_edge(clk);
        mosi(2).rdata_ready <= '0';
        wait until rising_edge(clk);
        wait for 1 ns;

        report "=== ALL TESTS PASSED ===";
        finish;
    end process;

end architecture sim;