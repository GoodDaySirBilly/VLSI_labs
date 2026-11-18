# GTKWave layout for alu_tb.
# Installed as tests/lab4/alu_tb.tcl; loaded by `make wave PROJECT=lab4`.
# No comment/separator traces: indices remain aligned with getDisplayedSignals.

# GHW can expose a vector as an individual facility bit (e.g. A[0]),
# while the displayed trace is the reconstructed bus (e.g. A[15:0]).
set facilities [list]
for {set i 0} {$i < [gtkwave::getNumFacs]} {incr i} {
    set actual [gtkwave::getFacName $i]
    set normalized [string tolower $actual]
    regsub -all {\(([0-9]+)\)} $normalized {[\1]} normalized
    lappend facilities [list $normalized $actual]
}

# Signal layout: control, operands, incoming flags, result, outgoing flags.
# Each entry: {testbench-level signal, color}.
set layout {
    {opcode Violet}
    {a Blue}
    {b Blue}
    {flags_in.n Cyan}
    {flags_in.z Cyan}
    {flags_in.v Cyan}
    {flags_in.c Cyan}
    {c Yellow}
    {flags_out.n Green}
    {flags_out.z Green}
    {flags_out.v Green}
    {flags_out.c Green}
}

# Map each displayed trace to a requested color by its normalized base name.
set colors_by_name [dict create]
foreach item $layout {
    lassign $item name color
    set pattern [format {(^|\.)alu_tb\.%s(\[[0-9]+(:[0-9]+)?\])?$} \
        [string map {. {\.}} $name]]

    set found 0
    foreach facility $facilities {
        lassign $facility normalized actual
        if {[regexp -- $pattern $normalized]} {
            if {[gtkwave::addSignalsFromList [list $actual]] > 0} {
                dict set colors_by_name $name $color
                set found 1
                break
            }
        }
    }
    if {!$found} {
        puts stderr "GTKWave: signal not found: alu_tb.$name"
    }
}

# Use displayed-trace indices: unlike facility-based highlighting, this also
# handles buses reconstructed from a single-bit facility in GHW.
# With no comments/blank traces, getDisplayedSignals and trace indices align.
set displayed [gtkwave::getDisplayedSignals]
for {set i 0} {$i < [llength $displayed]} {incr i} {
    set trace [string tolower [lindex $displayed $i]]
    # Drop only the final vector range; preserve other hierarchy indices.
    regsub {\[[0-9]+(:[0-9]+)?\]$} $trace {} trace
    if {![regexp {(^|\.)alu_tb\.(.+)$} $trace -> _ signal_name]} {
        continue
    }
    if {![dict exists $colors_by_name $signal_name]} {
        continue
    }

    gtkwave::/Edit/UnHighlight_All
    gtkwave::setTraceHighlightFromIndex $i on
    gtkwave::/Edit/Color_Format/[dict get $colors_by_name $signal_name]
    gtkwave::/Edit/UnHighlight_All
}

gtkwave::/Time/Zoom/Zoom_Full
