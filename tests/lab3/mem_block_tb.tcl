# GTKWave startup layout for mem_block_tb (4 interfaces).
# Called automatically by `make wave PROJECT=lab3`.
# Show testbench reset/clock, then one group for each interface.

# GTKWave's GHW facility names may use either (0) or [0] for array indices.
# Normalize indices to [0] for matching; keep the original name for GTKWave.
set facilities [list]
for {set i 0} {$i < [gtkwave::getNumFacs]} {incr i} {
    set actual [gtkwave::getFacName $i]
    set normalized [string tolower $actual]
    regsub -all {\(([0-9]+)\)} $normalized {[\1]} normalized
    lappend facilities [list $normalized $actual]
}

# Add one signal in the requested position; return its name for coloring.
proc add_matching_signal {pattern label} {
    global facilities

    foreach facility $facilities {
        lassign $facility normalized actual
        if {[regexp -- $pattern $normalized]} {
            if {[gtkwave::addSignalsFromList [list $actual]] > 0} {
                return $actual
            }
        }
    }

    puts stderr "GTKWave: signal not found: $label"
    return ""
}

# Top-level testbench control signals.
add_matching_signal {(^|\.)mem_block_tb\.rst$} rst
add_matching_signal {(^|\.)mem_block_tb\.clk$} clk

# Interface signal order matches the desired waveform layout.
set fields {
    {addr mosi}
    {addr_valid mosi}
    {addr_ack miso}
    {rw mosi}
    {rdata miso}
    {rdata_valid miso}
    {rdata_ready mosi}
    {wdata mosi}
    {wdata_valid mosi}
    {wdata_ack miso}
}

# GTKWave colors for interfaces 0-3.
set colors {Yellow Red Blue Violet}

for {set interface 0} {$interface < 4} {incr interface} {

    # Collect successfully added signals for coloring.
    set group_signals [list]

    foreach field_spec $fields {
        lassign $field_spec field direction

        # Match mosi[0].addr, miso[0].rdata[15:0], etc.
        set pattern [format {(^|\.)%s\[%d\]\.%s(\[|$)} \
            $direction $interface $field]

        set signal [add_matching_signal \
            $pattern "${direction}($interface).$field"]

        if {$signal ne ""} {
            lappend group_signals $signal
        }
    }

    # FSM state is inside dut.gen_interfaces(0).u_fsm.state.
    set state_pattern [format \
        {\.gen_interfaces\[%d\]\.u_fsm\.state$} $interface]

    set signal [add_matching_signal \
        $state_pattern "interface $interface FSM state"]

    if {$signal ne ""} {
        lappend group_signals $signal
    }

    puts "GTKWave displayed signals:"
    foreach signal [gtkwave::getDisplayedSignals] {
        puts "  $signal"
    }

    # Apply the interface color to all its signals.
    if {[llength $group_signals] > 0} {
        set color [lindex $colors $interface]

        gtkwave::/Edit/UnHighlight_All

        # Select traces by their displayed positions.
        # This works for both scalar signals and vector buses.
        set displayed [gtkwave::getDisplayedSignals]

        for {set i 0} {$i < [llength $displayed]} {incr i} {
            set trace [lindex $displayed $i]

            foreach signal $group_signals {
                # Strip vector suffixes from both names.
                set trace_base [regsub {\[[0-9]+:[0-9]+\]$} $trace ""]
                set signal_base [regsub {\[[0-9]+\]$} $signal ""]

                if {$trace_base eq $signal_base} {
                    gtkwave::setTraceHighlightFromIndex $i on
                    break
                }
            }
        }

        gtkwave::/Edit/Color_Format/$color
        gtkwave::/Edit/UnHighlight_All
    }
}

gtkwave::/Time/Zoom/Zoom_Full