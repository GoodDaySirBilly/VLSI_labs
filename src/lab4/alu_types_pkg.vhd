library ieee;
use ieee.std_logic_1164.all;

package alu_types_pkg is

    type alu_flags is record
        N : std_logic;
        Z : std_logic;
        V : std_logic;
        C : std_logic;
    end record alu_flags;

end package alu_types_pkg;