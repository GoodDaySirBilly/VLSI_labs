package arbitr_types_pkg is
    constant PRIORITY_LEVELS : integer := 5;
    subtype priority_t is integer range -1 to (PRIORITY_LEVELS - 1); -- 5 levels of priority
    type priority_vector_t is array (integer range <>) of priority_t;
end package arbitr_types_pkg;