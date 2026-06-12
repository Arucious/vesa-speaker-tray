// Pure functions: derived dimensions, VESA hole coordinates, pad spacing, and
// validation predicates. NO geometry and NO customizer variables live here, so
// this file is safe to `use <params.scad>` from the geometry modules.
//
// `use <file>` does NOT import a file's top-level variables (only its modules
// and functions), so everything the geometry needs from here is exposed as a
// function and every customizer value is threaded through as a module argument.
// (Same lesson as cable_clamp's params.scad.)

// ---- derived tray dimensions ------------------------------------------------
function tray_inner_w(speaker_w, clearance) = speaker_w + 2 * clearance;
function tray_inner_d(speaker_d, clearance) = speaker_d + 2 * clearance;
function tray_outer_w(speaker_w, clearance, lip_t) =
    tray_inner_w(speaker_w, clearance) + 2 * lip_t;
function tray_outer_d(speaker_d, clearance, lip_t) =
    tray_inner_d(speaker_d, clearance) + 2 * lip_t;

// ---- VESA geometry ----------------------------------------------------------
// Four holes on a centered square of side `vesa_pattern`.
function vesa_offsets(vesa_pattern) = [
    for (sx = [-1, 1], sy = [-1, 1]) [sx * vesa_pattern / 2, sy * vesa_pattern / 2]
];

// Across-corners diameter of a hexagon given its across-flats size (for nut traps
// and for $fn=6 cylinders, whose nominal diameter is the across-corners value).
function hex_corner_d(across_flats) = across_flats / cos(30);

// ---- TPU pad strip placement (running in X, distributed across the depth) ----
// Center Y of pad strip `i` of `n`, kept fully inside the floor cavity.
function pad_center_y(i, n, inner_d, pad_w) =
    n <= 1 ? 0
    : let (lo = -inner_d / 2 + pad_w / 2, hi = inner_d / 2 - pad_w / 2)
      lo + (hi - lo) * i / (n - 1);

// ---- validation predicates (asserted by tray()) -----------------------------
// Bosses must not overlap each other or spill past the tray footprint.
function bosses_fit(vesa_pattern, boss_d, outer_w, outer_d) =
    boss_d < vesa_pattern
    && vesa_pattern / 2 + boss_d / 2 <= outer_w / 2 + 1e-3
    && vesa_pattern / 2 + boss_d / 2 <= outer_d / 2 + 1e-3;

// Heat-set pocket opens at the boss underside and must stop short of the floor
// top surface (z = 0) so it stays blind. Total material below z=0 = floor_t+boss_h.
function insert_pocket_blind(use_inserts, insert_depth, floor_t, boss_h) =
    !use_inserts || insert_depth < floor_t + boss_h;
