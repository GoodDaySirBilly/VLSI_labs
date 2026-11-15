library ieee;
use ieee.std_logic_1164.all;

entity rca_of_cla_16bit is
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
end entity rca_of_cla_16bit;

architecture rtl of rca_of_cla_16bit is
    signal Z_vector : std_logic_vector(3 downto 0);
    signal C : std_logic_vector(2 downto 0);
begin

    CLA_0 : entity work.cla_block_4bit
        port map(
            A => A(3 downto 0),
            B => B(3 downto 0),
            C_in => C_in,

            S => S(3 downto 0),
            C_out => C(0),
            
            N => open,
            Z => Z_vector(0),
            V => open 
        );

    CLA_1 : entity work.cla_block_4bit
        port map(
            A => A(7 downto 4),
            B => B(7 downto 4),
            C_in => C(0),

            S => S(7 downto 4),
            C_out => C(1),

            N => open,
            Z => Z_vector(1),
            V => open
        );

    CLA_2 : entity work.cla_block_4bit
        port map(
            A => A(11 downto 8),
            B => B(11 downto 8),
            C_in => C(1),

            S => S(11 downto 8),
            C_out => C(2),

            N => open,
            Z => Z_vector(2),
            V => open
        );

    CLA_3 : entity work.cla_block_4bit
        port map(
            A => A(15 downto 12),
            B => B(15 downto 12),
            C_in => C(2),

            S => S(15 downto 12),
            C_out => C_out,

            N => N,
            Z => Z_vector(3),
            V => V
        );

    Z <= Z_vector(0) and Z_vector(1) and Z_vector(2) and Z_vector(3);

end architecture rtl;