library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_types_pkg.all;

entity shifter is
    port (
        A : in  std_logic_vector(15 downto 0);
        B : in  std_logic_vector(15 downto 0);
        flags_in : in  alu_flags;

        C : out std_logic_vector(31 downto 0);
        flags_out : out alu_flags
    );
end entity shifter;

architecture rtl of shifter is 
    signal s_vector_16_bit : std_logic_vector(15 downto 0);
    signal shift_amount    : integer range -16 to 15;
begin

    shift_amount    <= to_integer(signed(B(4 downto 0)));
    s_vector_16_bit <= std_logic_vector(unsigned(A) rol shift_amount);

    flags_out.N <= s_vector_16_bit(15);
    flags_out.Z <= not(or(s_vector_16_bit));
    flags_out.V <= flags_in.V;
    flags_out.C <= flags_in.C when shift_amount = 0 else
                   s_vector_16_bit(0) when shift_amount > 0 else
                   s_vector_16_bit(15);

    C(31 downto 16) <= x"0000";
    C(15 downto 0)  <= s_vector_16_bit;

end architecture rtl;
