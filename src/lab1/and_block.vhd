library ieee;
use ieee.std_logic_1164.all;

entity and_block is
    port (
        A : in std_logic;
        B : in std_logic;
        C : out std_logic
    );
end entity and_block;

architecture rtl of and_block is
begin
    C <= A and B;
end architecture rtl;