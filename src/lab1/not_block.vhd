library ieee;
use ieee.std_logic_1164.all;

entity not_block is
    port (
        A : in std_logic;
        C : out std_logic
    );
end entity not_block;

architecture rtl of not_block is
begin
    C <= not A;
end architecture rtl;