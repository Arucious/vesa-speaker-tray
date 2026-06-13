// Pure functions: derived dimensions, VESA hole coordinates, pad spacing, and
// validation predicates. NO geometry and NO customizer variables live here, so
// this file is safe to `use <params.scad>` from the geometry modules.
//
// `use <file>` does NOT import a file's top-level variables (only its modules
// and functions), so everything the geometry needs from here is exposed as a
// function and every customizer value is threaded through as a module argument.
// (Same lesson as cable_clamp's params.scad.)

// ---- derived bracket dimensions ----------------------------------------------
// Usable shelf depth: lip inner face -> shelf rear edge (= plate rear face).
function shelf_usable_d(shelf_d, lip_t) = shelf_d - lip_t;

// How far the cabinet rear face hangs past the plate rear face (over the arm
// head). Negative = cabinet fully on the shelf.
function rear_overhang(speaker_d, cabinet_clearance, shelf_d, lip_t) =
    speaker_d + lip_t + cabinet_clearance - shelf_d;

// Physical lip height above the shelf top, preserving `lip_h` of effective
// retention above the pad top.
function lip_total_h(lip_h, pad_proud) = lip_h + pad_proud;

// ---- VESA geometry -------------------------------------------------------------
// Four holes on a centered square of side `vesa_pattern`, on the vertical plate:
// [x, z] offsets relative to the square's center (x 0, z -vesa_drop).
function vesa_offsets(vesa_pattern) = [
    for (sx = [-1, 1], sz = [-1, 1]) [sx * vesa_pattern / 2, sz * vesa_pattern / 2]
];

// Radius of material needed around a hole center: insert boss in "insert" mode,
// bare bore + wall in "through" mode.
function vesa_keepout_r(fastening, insert_boss_d, vesa_hole_d) =
    fastening == "insert" ? insert_boss_d / 2 : vesa_hole_d / 2 + 2;

// Across-corners diameter of a hexagon given its across-flats size (for nut traps
// and for $fn=6 cylinders, whose nominal diameter is the across-corners value).
function hex_corner_d(across_flats) = across_flats / cos(30);

// ---- gusset placement ----------------------------------------------------------
// Center X of gusset `i` of `n`, spread evenly across the plate width with a
// 2mm edge inset.
function gusset_x(i, n, plate_w, gusset_t) =
    n <= 1 ? 0
    : let (span = plate_w - 2 * 2 - gusset_t)
      -span / 2 + span * i / (n - 1);

// Auto depth/height: 0 means "as far as it can go".
function gusset_depth_eff(gusset_depth, shelf_d, plate_t, lip_t) =
    gusset_depth > 0 ? gusset_depth : shelf_d - plate_t - lip_t;
function gusset_h_eff(gusset_h, plate_h, corner_r) =
    gusset_h > 0 ? gusset_h : plate_h - corner_r - 1;

// ---- TPU pad strip placement (running in X, distributed along the depth) -------
// Center of pad strip `i` of `n` within a span of length `span_d`, kept fully
// inside the span. Returned as offset from the span center.
function pad_center_y(i, n, span_d, pad_w) =
    n <= 1 ? 0
    : let (lo = -span_d / 2 + pad_w / 2, hi = span_d / 2 - pad_w / 2)
      lo + (hi - lo) * i / (n - 1);

// ---- validation predicates (asserted by bracket()) ------------------------------
// VESA holes + their keepout must stay inside the plate: clear of the side
// edges, below the shelf-junction fillet, above the bottom rounding.
function vesa_fits_plate(vesa_pattern, keepout_r, plate_w, plate_h, vesa_drop,
                         shelf_t, fillet_r) =
    vesa_pattern / 2 + keepout_r <= plate_w / 2 - 1 + 1e-3
    && vesa_drop - vesa_pattern / 2 - keepout_r >= shelf_t + fillet_r + 1
    && vesa_drop + vesa_pattern / 2 + keepout_r <= plate_h - 1 + 1e-3;

// No gusset may cross a VESA hole column (keepout + 1mm clearance).
function gussets_clear_vesa(gusset_count, gusset_t, plate_w, vesa_pattern, keepout_r) =
    min([for (i = [0 : max(0, gusset_count - 1)])
            min(abs(abs(gusset_x(i, gusset_count, plate_w, gusset_t)) - vesa_pattern / 2),
                abs(gusset_x(i, gusset_count, plate_w, gusset_t)) + vesa_pattern / 2)])
        >= gusset_t / 2 + keepout_r + 1;

// Heat-set pocket opens at the plate REAR face and must dead-end >= 1.5mm before
// the insert boss's front face, so it stays blind.
function insert_pocket_blind(fastening, insert_depth, plate_t, insert_boss_h) =
    fastening != "insert" || insert_depth <= plate_t + insert_boss_h - 1.5;

// Side rails ("rails" retention) must fit on the shelf.
function rails_fit(retention_style, speaker_w, cabinet_clearance, rail_t, shelf_w) =
    retention_style != "rails"
    || speaker_w / 2 + cabinet_clearance + rail_t <= shelf_w / 2 + 1e-3;
