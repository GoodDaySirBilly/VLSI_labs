library ieee;
use ieee.std_logic_1164.all;

entity comb_schema is
    port (
        A : in std_logic;
        B : in std_logic;
        C : in std_logic;
        D : in std_logic;
        Y : out std_logic
    );
end entity comb_schema;

architecture rtl of comb_schema is
begin
    Y <= A and not (B or C or D);
end architecture rtl;