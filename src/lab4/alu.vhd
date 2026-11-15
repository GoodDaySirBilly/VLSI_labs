library ieee;
use ieee.std_logic_1164.all;
use work.alu_types_pkg.all;

entity alu is
    port (
        A         : in  std_logic_vector(15 downto 0);
        B         : in  std_logic_vector(15 downto 0);
        opcode    : in  std_logic_vector(2 downto 0);
        flags_in  : in  alu_flags;

        C         : out std_logic_vector(31 downto 0);
        flags_out : out alu_flags
    );
end entity alu;

architecture rtl of alu is
    signal res_not       : std_logic_vector(31 downto 0);
    signal res_add_cla   : std_logic_vector(31 downto 0);
    signal res_add_rca   : std_logic_vector(31 downto 0);
    signal res_mul_uns   : std_logic_vector(31 downto 0);
    signal res_mul_sgn   : std_logic_vector(31 downto 0);
    signal res_xor       : std_logic_vector(31 downto 0);
    signal res_shift     : std_logic_vector(31 downto 0);

    signal flg_not       : alu_flags;
    signal flg_add_cla   : alu_flags;
    signal flg_add_rca   : alu_flags;
    signal flg_mul_uns   : alu_flags;
    signal flg_mul_sgn   : alu_flags;
    signal flg_xor       : alu_flags;
    signal flg_shift     : alu_flags;
begin

    U_NOT : entity work.noter
        port map (
            A         => A,
            B         => B,
            flags_in  => flags_in,
            C         => res_not,
            flags_out => flg_not
        );

    U_ADD_CLA : entity work.adder
        generic map (
            USE_CLA => '1'
        )
        port map (
            A         => A,
            B         => B,
            flags_in  => flags_in,
            C         => res_add_cla,
            flags_out => flg_add_cla
        );

    U_MUL_UNS : entity work.multiplier
        generic map (
            IS_SIGNED => '0'
        )
        port map (
            A         => A,
            B         => B,
            flags_in  => flags_in,
            C         => res_mul_uns,
            flags_out => flg_mul_uns
        );

    U_XOR : entity work.xorer
        port map (
            A         => A,
            B         => B,
            flags_in  => flags_in,
            C         => res_xor,
            flags_out => flg_xor
        );

    U_SHIFT : entity work.shifter
        port map (
            A         => A,
            B         => B,
            flags_in  => flags_in,
            C         => res_shift,
            flags_out => flg_shift
        );

    U_ADD_RCA : entity work.adder
        generic map (
            USE_CLA => '0'
        )
        port map (
            A         => A,
            B         => B,
            flags_in  => flags_in,
            C         => res_add_rca,
            flags_out => flg_add_rca
        );

    U_MUL_SGN : entity work.multiplier
        generic map (
            IS_SIGNED => '1'
        )
        port map (
            A         => A,
            B         => B,
            flags_in  => flags_in,
            C         => res_mul_sgn,
            flags_out => flg_mul_sgn
        );

    process(all)
    begin
        case opcode is
            when "000" => -- 0: NOT
                C         <= res_not;
                flags_out <= flg_not;

            when "001" => -- 1: ADD (CLA)
                C         <= res_add_cla;
                flags_out <= flg_add_cla;

            when "010" => -- 2: MUL (unsigned)
                C         <= res_mul_uns;
                flags_out <= flg_mul_uns;

            when "011" => -- 3: XOR
                C         <= res_xor;
                flags_out <= flg_xor;

            when "100" => -- 4: SHIFT (ROL)
                C         <= res_shift;
                flags_out <= flg_shift;

            when "101" => -- 5: ADD (RCA)
                C         <= res_add_rca;
                flags_out <= flg_add_rca;

            when "110" => -- 6: MUL (signed)
                C         <= res_mul_sgn;
                flags_out <= flg_mul_sgn;

            when others =>
                C         <= (others => '0');
                flags_out <= flags_in;
        end case;
    end process;

end architecture rtl;
