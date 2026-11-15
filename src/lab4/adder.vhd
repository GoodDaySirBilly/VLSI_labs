library ieee;
use ieee.std_logic_1164.all;
use work.alu_types_pkg.all;

entity adder is
    generic (
        USE_CLA : std_logic := '1'
    );
    port (
        A : in  std_logic_vector(15 downto 0);
        B : in  std_logic_vector(15 downto 0);
        flags_in : in  alu_flags;

        C : out std_logic_vector(31 downto 0);
        flags_out : out alu_flags
    );
end entity adder;

architecture rtl of adder is 
    signal s_vector_16_bit : std_logic_vector(15 downto 0);
begin

    GEN_ADDER : if USE_CLA = '1' generate
        CLA_ADDER : entity work.rca_of_cla_16bit
            port map(
                A => A,
                B => B,
                C_in => flags_in.C,
                S => s_vector_16_bit,
                N => flags_out.N,
                Z => flags_out.Z,
                V => flags_out.V,
                C_out => flags_out.C
            );
    else generate
        RCA_ADDER : entity work.rca_of_fa_16bit
            port map(
                A => A,
                B => B,
                C_in => flags_in.C,
                S => s_vector_16_bit,
                N => flags_out.N,
                Z => flags_out.Z,
                V => flags_out.V,
                C_out => flags_out.C
            );
    end generate GEN_ADDER;

    C(31 downto 16) <= x"0000";
    C(15 downto 0) <= s_vector_16_bit;

end architecture rtl;
