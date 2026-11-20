# GTKWave layout for comb_schema_tb.
# Installed as tests/lab1/comb_schema_tb.tcl; loaded by `make wave PROJECT=lab1`.

set facilities [list]
for {set i 0} {$i < [gtkwave::getNumFacs]} {incr i} {
    set actual [gtkwave::getFacName $i]
    set normalized [string tolower $actual]
    regsub -all {\(([0-9]+)\)} $normalized {[\1]} normalized
    lappend facilities [list $normalized $actual]
}

# Signal layout: inputs first, then reference, then DUT outputs.
set layout {
    {a Blue}
    {b Blue}
    {c Blue}
    {d Blue}
    {y_ref Yellow}
    {y_1 Green}
    {y_2 Red}
}

set color_by_base [dict create]
foreach item $layout {
    lassign $item name color
    set candidates [list $name]
    if {$name eq "y_1"} { lappend candidates "y1" }
    if {$name eq "y_2"} { lappend candidates "y2" }

    set found 0
    foreach cand $candidates {
        set pattern [format {(^|\.)comb_schema_tb\.%s(\[[0-9]+(:[0-9]+)?\])?$} \
            [string map {. {\.}} $cand]]
        foreach facility $facilities {
            lassign $facility normalized actual
            if {[regexp -- $pattern $normalized]} {
                if {[gtkwave::addSignalsFromList [list $actual]] > 0} {
                    set base [string tolower [lindex [split $actual .] end]]
                    dict set color_by_base $base $color
                    set found 1
                    break
                }
            }
        }
        if {$found} break
    }
    if {!$found} {
        puts stderr "GTKWave: signal not found: comb_schema_tb.$name"
    }
}

set displayed [gtkwave::getDisplayedSignals]
for {set i 0} {$i < [llength $displayed]} {incr i} {
    set trace [string tolower [lindex $displayed $i]]
    regsub {\[[0-9]+(:[0-9]+)?\]$} $trace {} trace
    if {![regexp {(^|\.)comb_schema_tb\.(.+)$} $trace -> _ signal_name]} {
        continue
    }
    if {![dict exists $color_by_base $signal_name]} {
        continue
    }

    gtkwave::/Edit/UnHighlight_All
    gtkwave::setTraceHighlightFromIndex $i on
    gtkwave::/Edit/Color_Format/[dict get $color_by_base $signal_name]
    gtkwave::/Edit/UnHighlight_All
}
