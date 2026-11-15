library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity cla_block_4bit_tb is
end entity cla_block_4bit_tb;

architecture sim of cla_block_4bit_tb is
    signal A     : std_logic_vector(3 downto 0) := (others => '0');
    signal B     : std_logic_vector(3 downto 0) := (others => '0');
    signal C_in  : std_logic := '0';
    signal S     : std_logic_vector(3 downto 0);
    signal C_out : std_logic;
    signal N     : std_logic;
    signal Z     : std_logic;
    signal V     : std_logic;
begin

    dut : entity work.cla_block_4bit
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
        variable sum_5bit : unsigned(4 downto 0);
        variable exp_S    : std_logic_vector(3 downto 0);
        variable exp_Cout : std_logic;
        variable exp_N    : std_logic;
        variable exp_Z    : std_logic;
        variable exp_V    : std_logic;
    begin
        for c_val in 0 to 1 loop
            if c_val = 0 then C_in <= '0'; else C_in <= '1'; end if;

            for a_val in 0 to 15 loop
                for b_val in 0 to 15 loop
                    A <= std_logic_vector(to_unsigned(a_val, 4));
                    B <= std_logic_vector(to_unsigned(b_val, 4));
                    wait for 2 ns;

                    sum_5bit := resize(to_unsigned(a_val, 4), 5) + resize(to_unsigned(b_val, 4), 5) + c_val;
                    exp_S    := std_logic_vector(sum_5bit(3 downto 0));
                    exp_Cout := sum_5bit(4);

                    exp_N := exp_S(3);
                    if exp_S = "0000" then 
                        exp_Z := '1'; 
                    else 
                        exp_Z := '0'; 
                    end if;
                    
                    exp_V := (A(3) xnor B(3)) and (A(3) xor exp_S(3));

                    assert S = exp_S
                        report "Sum mismatch for A=" & integer'image(a_val) & " B=" & integer'image(b_val)
                        severity failure;

                    assert C_out = exp_Cout
                        report "C_out mismatch for A=" & integer'image(a_val) & " B=" & integer'image(b_val)
                        severity failure;

                    assert N = exp_N
                        report "Flag N mismatch for A=" & integer'image(a_val) & " B=" & integer'image(b_val)
                        severity failure;

                    assert Z = exp_Z
                        report "Flag Z mismatch for A=" & integer'image(a_val) & " B=" & integer'image(b_val)
                        severity failure;

                    assert V = exp_V
                        report "Flag V mismatch for A=" & integer'image(a_val) & " B=" & integer'image(b_val)
                        severity failure;
                end loop;
            end loop;
        end loop;

        report "All 512 tests passed successfully!" severity note;
        wait for 1 ns;
        finish;
    end process;

end architecture sim;
