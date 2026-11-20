library ieee;
use ieee.std_logic_1164.all;

entity or_block is
    port (
        A : in std_logic;
        B : in std_logic;
        C : out std_logic
    );
end entity or_block;

architecture rtl of or_block is
begin
    C <= A or B;
end architecture rtl;