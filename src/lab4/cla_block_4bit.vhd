library ieee;
use ieee.std_logic_1164.all;

entity cla_block_4bit is
    port (
        A : in std_logic_vector(3 downto 0);
        B : in std_logic_vector(3 downto 0);
        C_in : in std_logic;

        S : out std_logic_vector(3 downto 0);
        C_out : out std_logic;

        N: out std_logic;
        Z: out std_logic;
        V: out std_logic
    );
end entity cla_block_4bit;


architecture rtl of cla_block_4bit is
    signal G : std_logic_vector(3 downto 0);
    signal P : std_logic_vector(3 downto 0);
    signal C : std_logic_vector(4 downto 1);
begin
    G <= A and B;
    P <= A xor B;

    C(1) <= G(0) or (P(0) and C_in);
    C(2) <= G(1) or (P(1) and G(0)) or (P(1) and P(0) and C_in);
    C(3) <= G(2) or (P(2) and G(1)) or (P(2) and P(1) and G(0)) or (P(2) and P(1) and P(0) and C_in);
    C(4) <= G(3) or (P(3) and G(2)) or (P(3) and P(2) and G(1)) or (P(3) and P(2) and P(1) and G(0)) or (P(3) and P(2) and P(1) and P(0) and C_in);

    S(0) <= P(0) xor C_in;
    S(1) <= P(1) xor C(1);
    S(2) <= P(2) xor C(2);
    S(3) <= P(3) xor C(3);

    N <= S(3);
    Z <= not (S(0) or S(1) or S(2) or S(3));
    V <= C(4) xor C(3);
    C_out <= C(4);
end architecture rtl;