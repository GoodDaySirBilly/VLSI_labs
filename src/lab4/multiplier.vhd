library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_types_pkg.all;

entity multiplier is
    generic (
        IS_SIGNED : std_logic := '0'
    );
    port (
        A : in  std_logic_vector(15 downto 0);
        B : in  std_logic_vector(15 downto 0);
        flags_in : in  alu_flags;

        C : out std_logic_vector(31 downto 0);
        flags_out : out alu_flags
    );
end entity multiplier;

architecture rtl of multiplier is 
    signal m_vector_32_bit : std_logic_vector(31 downto 0);
    signal overflow_flag : std_logic;
begin

    GEN_MULTIPLIER : if IS_SIGNED = '1' generate
        m_vector_32_bit <= std_logic_vector(signed(A) * signed(B));
        flags_out.N <= m_vector_32_bit(31);
        overflow_flag <= '0' when
            (m_vector_32_bit(31 downto 16) = x"0000" and m_vector_32_bit(15) = '0')
            or
            (m_vector_32_bit(31 downto 16) = x"FFFF" and m_vector_32_bit(15) = '1')
        else '1';
    else generate
        m_vector_32_bit <= std_logic_vector(unsigned(A) * unsigned(B));
        flags_out.N     <= '0';
        overflow_flag   <= or(m_vector_32_bit(31 downto 16));
    end generate GEN_MULTIPLIER;

    flags_out.Z <= not(or(m_vector_32_bit));
    flags_out.V <= overflow_flag;
    flags_out.C <= overflow_flag;
    C <= m_vector_32_bit;

end architecture rtl;
