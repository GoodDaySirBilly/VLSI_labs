library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;

entity rca_of_fa_16bit_tb is
end entity rca_of_fa_16bit_tb;

architecture sim of rca_of_fa_16bit_tb is
    signal A     : std_logic_vector(15 downto 0) := (others => '0');
    signal B     : std_logic_vector(15 downto 0) := (others => '0');
    signal C_in  : std_logic := '0';
    signal S     : std_logic_vector(15 downto 0);
    signal C_out : std_logic;
    signal N     : std_logic;
    signal Z     : std_logic;
    signal V     : std_logic;
begin

    dut : entity work.rca_of_fa_16bit
        port map (
            A     => A,
            B     => B,
            C_in  => C_in,
            S     => S,
            C_out => C_out,
            N     => N,
            Z     => Z,
            V     => V
        );

    stimulus : process
        -- Вспомогательная процедура для проверки одного тестового вектора
        procedure check_add(
            in_a : std_logic_vector(15 downto 0);
            in_b : std_logic_vector(15 downto 0);
            in_c : std_logic
        ) is
            variable sum_17bit : unsigned(16 downto 0);
            variable c_int     : unsigned(0 downto 0);
            variable exp_S     : std_logic_vector(15 downto 0);
            variable exp_Cout  : std_logic;
            variable exp_N     : std_logic;
            variable exp_Z     : std_logic;
            variable exp_V     : std_logic;
        begin
            A <= in_a;
            B <= in_b;
            C_in <= in_c;
            wait for 2 ns;

            if in_c = '1' then c_int := "1"; else c_int := "0"; end if;

            sum_17bit := resize(unsigned(in_a), 17) + resize(unsigned(in_b), 17) + resize(c_int, 17);
            exp_S     := std_logic_vector(sum_17bit(15 downto 0));
            exp_Cout  := sum_17bit(16);

            exp_N := exp_S(15);
            if exp_S = x"0000" then
                exp_Z := '1';
            else
                exp_Z := '0';
            end if;
            exp_V := (in_a(15) xnor in_b(15)) and (in_a(15) xor exp_S(15));

            assert S = exp_S
                report "Sum mismatch: got " & to_hstring(S) & ", expected " & to_hstring(exp_S)
                severity failure;

            assert C_out = exp_Cout
                report "C_out mismatch"
                severity failure;

            assert N = exp_N
                report "Flag N mismatch"
                severity failure;

            assert Z = exp_Z
                report "Flag Z mismatch"
                severity failure;

            assert V = exp_V
                report "Flag V mismatch"
                severity failure;
        end procedure;

        variable seed1, seed2 : positive := 42;
        variable rand_val     : real;
        variable rand_a, rand_b : std_logic_vector(15 downto 0);
        variable rand_c       : std_logic;
    begin
        -- 1. Направленные тесты (критические и граничные случаи)
        check_add(x"0000", x"0000", '0'); -- Нули (Z=1, N=0, V=0, C=0)
        check_add(x"FFFF", x"0000", '1'); -- Сквозной перенос через все 4 тетрады (Z=1, C=1, V=0)
        check_add(x"FFFF", x"0001", '0'); -- То же самое без C_in (Z=1, C=1)
        check_add(x"7FFF", x"0001", '0'); -- Знаковое переполнение (+32767 + 1 = -32768 -> N=1, V=1, C=0)
        check_add(x"8000", x"8000", '0'); -- Знаковое переполнение (-32768 + -32768 = 0 -> Z=1, V=1, C=1)
        check_add(x"FFFF", x"FFFF", '0'); -- Сложение двух -1 (-1 + -1 = -2 -> N=1, C=1, V=0)
        check_add(x"000F", x"0001", '0'); -- Перенос из 0-й тетрады в 1-ю
        check_add(x"00FF", x"0001", '0'); -- Перенос из 1-й тетрады во 2-ю
        check_add(x"0FFF", x"0001", '0'); -- Перенос из 2-й тетрады в 3-ю

        -- 2. 1000 случайных проверок для полного покрытия
        for i in 1 to 10 loop
            uniform(seed1, seed2, rand_val);
            rand_a := std_logic_vector(to_unsigned(integer(rand_val * 65535.0), 16));
            
            uniform(seed1, seed2, rand_val);
            rand_b := std_logic_vector(to_unsigned(integer(rand_val * 65535.0), 16));
            
            uniform(seed1, seed2, rand_val);
            if rand_val > 0.5 then rand_c := '1'; else rand_c := '0'; end if;

            check_add(rand_a, rand_b, rand_c);
        end loop;

        report "All 16-bit RCA tests passed." severity note;
        wait for 1 ns;
        finish;
    end process;

end architecture sim;
