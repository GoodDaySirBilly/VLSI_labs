library ieee;
use ieee.std_logic_1164.all;

entity rca_of_fa_16bit is
    port (
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        C_in : in std_logic;

        S : out std_logic_vector(15 downto 0);
        C_out : out std_logic;

        N: out std_logic;
        Z: out std_logic;
        V: out std_logic
    );
end entity rca_of_fa_16bit;

architecture rtl of rca_of_fa_16bit is 
    signal s_vector : std_logic_vector(15 downto 0);
    signal c_vector : std_logic_vector(16 downto 0);
begin

    c_vector(0) <= C_in;

    GEN_FULL_ADDERS : for i in 0 to 15 generate
        FULL_ADDER_I : entity work.full_adder
            port map (
                A => A(i),
                B => B(i),
                C_in => c_vector(i),

                S => s_vector(i),
                C_out => c_vector(i+1)
            );
    end generate GEN_FULL_ADDERS;
    
    S <= s_vector;
    C_out <= c_vector(16);

    N <= s_vector(15);
    Z <= not(or(s_vector));
    V <= c_vector(16) xor c_vector(15);

end architecture rtl;