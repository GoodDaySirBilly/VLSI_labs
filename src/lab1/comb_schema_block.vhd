library ieee;
use ieee.std_logic_1164.all;

entity comb_schema_block is
    port (
        A : in std_logic;
        B : in std_logic;
        C : in std_logic;
        D : in std_logic;
        Y : out std_logic
    );
end entity comb_schema_block;

architecture rtl of comb_schema_block is
    signal BorC : std_logic;
    signal BorCorD : std_logic;
    signal notBorCorD : std_logic;
begin
    
    OR_BLOCK0 : entity work.or_block
        port map(
            A => B,
            B => C,
            C => BorC
        );

    OR_BLOCK1 : entity work.or_block
        port map(
            A => BorC,
            B => D,
            C => BorCorD
        );

    NOT_BLOCK0 : entity work.not_block
        port map(
            A => BorCorD,
            C => notBorCorD
        );

    AND_BLOCK0 : entity work.and_block
        port map(
            A => A,
            B => notBorCorD,
            C => Y
        );

end architecture rtl;