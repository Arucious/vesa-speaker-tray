// Test fixture: VESA mounting-fit check (driven by the pytest harness via -D).
//
// Renders the INTERSECTION of the bracket with four M4 "bolts" entering the
// plate's REAR face (the arm side) on a VESA pattern. If the bolts align with
// the bracket's mounting holes they sit inside the hole voids and the
// intersection is EMPTY (zero volume). A mismatched pattern (fit_offset_*)
// drives the bolts into plate material, giving a non-empty solid — so the test
// both confirms a good fit and proves it discriminates.
//
// The bolts only reach as deep as a real fastener does: into the blind insert
// pocket (heat-set mode) or all the way through the plate (through-bolt mode).

// Entry point, so BOSL2's special-variable defaults must be set here (see
// the note in vesa_tray.scad).
include <BOSL2/std.scad>

use <../../src/bracket.scad>

/* fixture knobs */
fit_pattern  = 100;        // VESA square spacing under test (75, 100, ...)
fit_bolt_d   = 4;          // M4 shank diameter
fit_offset_x = 0;          // deliberate misalignment (negative control)
fit_offset_z = 0;
fit_fastening = "insert";  // "insert" | "through"

/* bracket params (kept in sync with the design defaults) */
fit_vesa_drop    = 70;
fit_insert_depth = 9;
fit_plate_t      = 8;

$fn = 24;

// Bolt runs along -Y from open air behind the plate to the fastener's reach.
bolt_start = 5;            // behind the plate rear face (y=0)
bolt_tip   = fit_fastening == "insert" ? -(fit_insert_depth - 0.2)
                                       : -(fit_plate_t + 1);

intersection() {
    bracket(vesa_pattern = fit_pattern, fastening = fit_fastening,
            insert_depth = fit_insert_depth, plate_t = fit_plate_t,
            vesa_drop = fit_vesa_drop);
    for (sx = [-1, 1], sz = [-1, 1])
        translate([sx * fit_pattern / 2 + fit_offset_x,
                   bolt_start,
                   -fit_vesa_drop + sz * fit_pattern / 2 + fit_offset_z])
            rotate([90, 0, 0])
                cylinder(d = fit_bolt_d, h = bolt_start - bolt_tip, $fn = 24);
}
