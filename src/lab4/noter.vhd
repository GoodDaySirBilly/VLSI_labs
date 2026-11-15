library ieee;
use ieee.std_logic_1164.all;
use work.alu_types_pkg.all;

entity noter is
    port (
        A : in  std_logic_vector(15 downto 0);
        B : in  std_logic_vector(15 downto 0);
        flags_in : in  alu_flags;

        C : out std_logic_vector(31 downto 0);
        flags_out : out alu_flags
    );
end entity noter;

architecture rtl of noter is 
    signal c_vector : std_logic_vector(15 downto 0);
begin

    c_vector <= not A;
    flags_out.N <= c_vector(15);
    flags_out.Z <= not(or(c_vector));
    flags_out.V <= flags_in.V;
    flags_out.C <= flags_in.C;

    C(31 downto 16) <= x"0000";
    C(15 downto 0) <= c_vector;

end architecture rtl;
