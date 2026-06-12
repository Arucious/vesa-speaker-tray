// Test fixture: VESA mounting-fit check (driven by the pytest harness via -D).
//
// Renders the INTERSECTION of the tray with four M4 "bolts" placed on a VESA
// pattern. If the bolts align with the tray's mounting holes they sit inside the
// hole voids and the intersection is EMPTY (zero volume). A mismatched pattern
// (fit_offset_*) drives the bolts into boss/floor material, giving a non-empty
// solid — so the test can both confirm a good fit and prove it discriminates.
//
// The bolts only reach as deep as a real fastener does: into the blind insert
// pocket (heat-set mode) or all the way through the floor (through-bolt mode).

use <../../src/tray.scad>

/* fixture knobs */
fit_pattern  = 100;   // VESA square spacing under test (75, 100, ...)
fit_bolt_d   = 4;     // M4 shank diameter
fit_offset_x = 0;     // deliberate misalignment (negative control)
fit_offset_y = 0;

/* tray params (kept in sync with the design defaults) */
fit_speaker_w    = 146;
fit_speaker_d    = 247;
fit_use_inserts  = true;
fit_insert_depth = 8.5;
fit_floor_t      = 6;
fit_boss_h       = 8;

$fn = 24;

boss_bottom = -(fit_floor_t + fit_boss_h);
bolt_top = fit_use_inserts ? boss_bottom + fit_insert_depth - 0.2 : 1;
bolt_bot = boss_bottom - 5;   // start below the boss, in open air

intersection() {
    tray(speaker_w = fit_speaker_w, speaker_d = fit_speaker_d,
         vesa_pattern = fit_pattern, use_inserts = fit_use_inserts,
         insert_depth = fit_insert_depth, floor_t = fit_floor_t, boss_h = fit_boss_h);
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * fit_pattern / 2 + fit_offset_x,
                   sy * fit_pattern / 2 + fit_offset_y, bolt_bot])
            cylinder(d = fit_bolt_d, h = bolt_top - bolt_bot, $fn = 24);
}
