// AUTO-GENERATED single-file build (scripts/build_single_file.py).
// Upload THIS file to MakerWorld's Parametric Model Maker. BOSL2 is provided by
// the platform; everything else is inlined below. Edit sources in src/ and re-run.

// ===================== customizer parameters (entry) =====================
/*
  Parametric VESA Speaker Bracket (v2)
  ------------------------------------
  Mounts a bookshelf speaker to a monitor-arm VESA head (100x100 / 75x75, M4)
  kept in its normal, vertical orientation: a vertical VESA plate sits below a
  cantilevered shelf braced by triangular gussets. The speaker rests on TPU
  pads inside a seamless wrap-around rim (low front lip, tall side rails, rear
  heel with a cable notch); its rear face — port and I/O — stays unobstructed.

  GENERATOR USE: for most speakers you only need to set the Speaker width and
  depth (and weight, for the print-setting hint). Everything else auto-sizes;
  the Advanced groups are there if you want to tune the mount or the rim.

  Speaker defaults are the Edifier S880DB MK2 manufacturer specs — verify
  against the actual cabinet with calipers before printing.

  License: MIT (see LICENSE).
*/

// BOSL2 must be included at the entry point: its top-level special-variable
// defaults ($tags_shown etc.) resolve through the caller's dynamic scope, and
// OpenSCAD >= 2026 (MakerWorld's renderer) errors if they're missing here.
include <BOSL2/std.scad>


/* [Speaker — START HERE] */
// Cabinet WIDTH in mm (measure with calipers)
speaker_w = 145; // [60:400]
// Cabinet DEPTH / length in mm (measure with calipers)
speaker_d = 207; // [80:400]
// Cabinet WEIGHT per speaker in kg (sets the recommended print settings below)
speaker_weight_kg = 3.5; // [0.5:0.5:15]

/* [Output] */
// Which part to render / export. Print "bracket" in PETG and "pads" in TPU.
Part = "bracket"; // [bracket, pads, assembly]

/* [Mounting] */
// VESA hole spacing (square). 100 is most common; 75 for smaller heads.
vesa_pattern = 100; // [75, 100]
// Heat-set inserts (blind, rear face) or M4 through-bolts + front nut traps
fastening = "insert"; // [insert, through]

/* [Retention] */
// rails = seamless wrap-around rim (recommended); lip = front only; strap = lip + velcro slots
retention_style = "rails"; // [rails, lip, strap]
// Low rear stop behind the cabinet (part of the rim)
rear_heel = true;
// Optional eyelet tab below the plate for a cable tie
cable_hook = false;

/* [Advanced: Fit & shelf] */
// Per-side gap between the cabinet and the rim
cabinet_clearance = 0.5;
// Shelf width in mm — 0 = auto-size to the speaker
shelf_w = 0;
// Shelf depth in mm — 0 = auto-size to the speaker
shelf_d = 0;
// Shelf thickness
shelf_t = 7;
// Cabinet height in mm (assembly preview only)
speaker_h = 237;

/* [Advanced: VESA plate] */
plate_w = 130;
plate_h = 130;
plate_t = 8;
// Shelf top -> VESA square center; raise if your arm head is tall
vesa_drop = 70;
// Ruthex RX-M4 pilot bore per datasheet (4.0 is the screw, not the bore!)
insert_d = 5.6;
insert_depth = 9;
insert_boss_d = 12;
insert_boss_h = 4;
// M4 clearance bore (through mode)
vesa_hole_d = 4.5;
// DIN 934 M4 nut across-flats (through mode)
nut_af = 7.0;
nut_trap_depth = 3.2;

/* [Advanced: Rim] */
// EFFECTIVE front-lip height above the pad top
lip_h = 6;
// Rim wall thickness
lip_t = 4;
rail_t = 4;
// Side-rail height above the shelf top
rail_h = 35;
rear_heel_h = 25;
// Central cable gap in the rear heel
rear_heel_notch_w = 40;
lip_pad_recess = true;

/* [Advanced: Gussets] */
gusset_count = 2;
gusset_t = 5;
// 0 = auto: full usable depth
gusset_depth = 0;
// 0 = auto: full plate height
gusset_h = 0;
// Shelf-to-plate junction fillet
fillet_r = 3;

/* [Advanced: Pads] */
// Deepen to ~2.2 for 3.2mm sorbothane/EVA sheet instead of printed TPU
pad_recess_depth = 1.5;
pad_recess_w = 25;
pad_count = 3;
// How far pads stand above the shelf top
pad_proud = 1;

/* [Advanced: Misc] */
corner_r = 6;
mirror_part = false;


// ===================== src/params.scad =====================
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

// ---- auto-sized shelf (0 = derive from the speaker) -----------------------------
// Shelf depth that fully supports the cabinet so the rear heel contacts it.
function auto_shelf_d(shelf_d, speaker_d, cabinet_clearance, rail_t) =
    shelf_d > 0 ? shelf_d : speaker_d + 2 * cabinet_clearance + 2 * rail_t;
// Shelf width: cabinet + clearance + rim wall + a 3mm border each side.
function auto_shelf_w(shelf_w, speaker_w, cabinet_clearance, rail_t) =
    shelf_w > 0 ? shelf_w : speaker_w + 2 * cabinet_clearance + 2 * rail_t + 6;

// ---- print-setting recommendations (informational; echoed by the entry file) ----
// Bending stress scales ~linearly with speaker weight; even these deliberately
// conservative values keep PETG far below its creep threshold (see README,
// "Print strength"). Returned as plain numbers for echo / display.
function recommended_walls(weight_kg) = max(4, min(8, 2 + ceil(weight_kg / 2)));
function recommended_infill_pct(weight_kg) = max(15, min(40, 5 + 5 * ceil(weight_kg / 2)));

// ===================== src/bracket.scad =====================
// Parametric VESA speaker bracket body (v2: vertical plate + gusseted shelf).
//
// Coordinate convention (from the spec):
//   - X = speaker width, Y = depth (front of speaker = -Y), Z = up.
//   - shelf top surface = z 0; plate REAR face (arm side) = y 0.
//   - shelf spans y -shelf_d..0; plate spans y -plate_t..0, z -plate_h..0.
//   - VESA hole square centered at [x 0, z -vesa_drop] on the plate.
//
// bracket() takes every tunable as an argument (no reliance on top-level
// customizer vars leaking in through `use`).


module bracket(
    speaker_w        = 145,
    speaker_d        = 207,
    cabinet_clearance= 0.5,
    shelf_w          = 160,
    shelf_d          = 216,   // supports the full cabinet depth (rear heel needs this)
    shelf_t          = 7,
    lip_h            = 6,
    lip_t            = 4,
    plate_w          = 130,
    plate_h          = 130,
    plate_t          = 8,
    vesa_drop        = 70,
    vesa_pattern     = 100,
    fastening        = "insert",   // "insert" | "through"
    insert_d         = 5.6,        // Ruthex RX-M4 pilot bore (datasheet)
    insert_depth     = 9,
    insert_boss_d    = 12,
    insert_boss_h    = 4,
    vesa_hole_d      = 4.5,
    nut_af           = 7.0,        // DIN 934 M4 hex nut across-flats
    nut_trap_depth   = 3.2,
    gusset_count     = 2,
    gusset_t         = 5,
    gusset_depth     = 0,          // 0 = auto (full usable depth)
    gusset_h         = 0,          // 0 = auto (full plate height)
    fillet_r         = 3,
    pad_recess_depth = 1.5,
    pad_recess_w     = 25,
    pad_count        = 3,
    pad_proud        = 1,
    lip_pad_recess   = true,
    retention_style  = "rails",    // "lip" | "strap" | "rails"
    rail_t           = 4,
    rail_h           = 35,         // side-rail height above the shelf top
    rear_heel        = true,       // low rear stop behind the cabinet
    rear_heel_h      = 25,
    rear_heel_notch_w= 40,         // central cable gap in the rear heel
    cable_hook       = false,
    corner_r         = 6,
    mirror_part      = false
) {
    keepout = vesa_keepout_r(fastening, insert_boss_d, vesa_hole_d);
    g_depth = gusset_depth_eff(gusset_depth, shelf_d, plate_t, lip_t);
    g_h     = gusset_h_eff(gusset_h, plate_h, corner_r);
    lip_hh  = lip_total_h(lip_h, pad_proud);
    span_d  = shelf_usable_d(shelf_d, lip_t);   // lip inner face .. rear edge

    // ----- validation (fail loudly rather than emit broken geometry) ---------
    assert(vesa_fits_plate(vesa_pattern, keepout, plate_w, plate_h, vesa_drop,
                           shelf_t, fillet_r),
           "VESA holes (incl. boss/bore wall) don't fit the plate: grow plate_w/plate_h or adjust vesa_drop");
    assert(gussets_clear_vesa(gusset_count, gusset_t, plate_w, vesa_pattern, keepout),
           "A gusset crosses a VESA hole column: change gusset_count/gusset_t or plate_w");
    assert(insert_pocket_blind(fastening, insert_depth, plate_t, insert_boss_h),
           "Insert pocket would break through: need insert_depth <= plate_t + insert_boss_h - 1.5");
    assert(lip_h >= 3, "Effective lip height (lip_h, above the pad top) must be >= 3mm");
    assert(rails_fit(retention_style, speaker_w, cabinet_clearance, rail_t, shelf_w),
           "Side rails fall off the shelf: grow shelf_w or shrink rail_t");

    ovh = rear_overhang(speaker_d, cabinet_clearance, shelf_d, lip_t);
    echo(str("rear_overhang = ", ovh,
             "mm past the plate rear face (keep the arm head below the cabinet)"));
    if (rear_heel && ovh > 1)
        echo(str("WARNING: rear_heel is on but the cabinet overhangs the shelf by ",
                 ovh, "mm, so the heel sits under the cabinet and won't contact ",
                 "its rear face. Deepen shelf_d to ~",
                 speaker_d + cabinet_clearance + lip_t * 2, "mm."));

    if (mirror_part) mirror([1, 0, 0]) _body();
    else _body();

    // -------------------------------------------------------------------------
    module _body() {
        difference() {
            union() {
                _plate();
                _shelf();
                _junction_fillet();
                _gussets();
                if (fastening == "insert") _insert_bosses();
                if (retention_style == "rails") _rim();   // seamless wrap-around
                else _lip();                              // "lip" / "strap"
                if (cable_hook) _cable_eyelet();
            }
            _vesa_holes();
            _pad_recesses();
            if (lip_pad_recess) _lip_recess();
            if (retention_style == "strap") _strap_slots();
            if (cable_hook) _eyelet_hole();
        }
    }

    // Vertical plate, rear face at y=0, top edge buried in the shelf.
    module _plate() {
        translate([0, -plate_t / 2, 0])
            cuboid([plate_w, plate_t, plate_h], rounding = corner_r, edges = "Y",
                   anchor = TOP);
    }

    // Horizontal shelf, top at z=0, rear edge flush with the plate rear face.
    module _shelf() {
        translate([0, -shelf_d / 2, 0])
            cuboid([shelf_w, shelf_d, shelf_t], rounding = corner_r, edges = "Z",
                   anchor = TOP);
    }

    // Concave fillet bead along the plate-front / shelf-underside corner. The
    // legs overlap 0.6mm into the plate and shelf so no union face is coplanar.
    module _junction_fillet() {
        translate([0, -plate_t, -shelf_t])
            rotate([90, 0, 90])
                linear_extrude(height = plate_w - 2 * corner_r, center = true)
                    difference() {
                        polygon([[0.6, 0.6], [-fillet_r, 0.6], [0.6, -fillet_r]]);
                        translate([-fillet_r, -fillet_r]) circle(r = fillet_r, $fn = 48);
                    }
    }

    // Right-triangle gussets under the shelf, spread across the plate width.
    // 1mm buried into the plate (rear) and the shelf (top) for clean unions.
    module _gussets() {
        for (i = [0 : max(0, gusset_count - 1)]) {
            x = gusset_x(i, gusset_count, plate_w, gusset_t);
            translate([x, 0, 0])
                rotate([90, 0, 90])
                    linear_extrude(height = gusset_t, center = true)
                        polygon([[-plate_t + 1, -shelf_t + 1],
                                 [-plate_t - g_depth, -shelf_t + 1],
                                 [-plate_t + 1, -g_h]]);
        }
    }

    // Front retention lip, outer face flush with the shelf front edge, spanning
    // between the shelf's rounded corners. Physical height = lip_h + pad_proud
    // so the effective lip above the pad is lip_h.
    module _lip() {
        translate([0, -shelf_d + lip_t / 2, 0])
            cuboid([shelf_w - 2 * corner_r, lip_t, lip_hh],
                   rounding = min(1.9, lip_t / 2 - 0.1), edges = "Z",
                   anchor = BOTTOM);
    }

    // Bosses on the plate FRONT face: the blind dead-end behind each pocket.
    module _insert_bosses() {
        for (o = vesa_offsets(vesa_pattern))
            translate([o[0], -plate_t + 0.01, -vesa_drop + o[1]])
                rotate([90, 0, 0])
                    cylinder(d = insert_boss_d, h = insert_boss_h + 0.01,
                             $fn = max(64, $fn));
    }

    // "insert": blind Ruthex pockets opening on the REAR face (arm side).
    // "through": M4 clearance bores + hex nut traps on the front face.
    module _vesa_holes() {
        for (o = vesa_offsets(vesa_pattern))
            translate([o[0], 0, -vesa_drop + o[1]]) {
                if (fastening == "insert") {
                    translate([0, 0.01, 0])
                        rotate([90, 0, 0])
                            cylinder(d = insert_d, h = insert_depth + 0.01, $fn = 64);
                    // Shallow relief counterbore: heat-set installation squeezes
                    // out a small lip of plastic; keep it below flush so the
                    // arm's VESA plate still seats flat on the rear face.
                    translate([0, 0.01, 0])
                        rotate([90, 0, 0])
                            cylinder(d = insert_d + 2, h = 0.41, $fn = 64);
                } else {
                    translate([0, 1, 0])
                        rotate([90, 0, 0])
                            cylinder(d = vesa_hole_d, h = plate_t + 2, $fn = 64);
                    translate([0, -plate_t + nut_trap_depth, 0])
                        rotate([90, 0, 0])
                            rotate([0, 0, 30])
                                cylinder(d = hex_corner_d(nut_af),
                                         h = nut_trap_depth + 0.01, $fn = 6);
                }
            }
    }

    // TPU pad recesses in the shelf top, strips running in X across the cabinet
    // footprint, distributed between the lip inner face and the rear edge.
    module _pad_recesses() {
        for (i = [0 : max(0, pad_count - 1)]) {
            y = -shelf_d + lip_t + span_d / 2 + pad_center_y(i, pad_count, span_d, pad_recess_w);
            translate([0, y, -pad_recess_depth / 2 + 0.005])
                cube([speaker_w, pad_recess_w, pad_recess_depth + 0.01], center = true);
        }
    }

    // Shallow (1mm) TPU recess on the lip's inner face.
    module _lip_recess() {
        d = 1; h = lip_hh * 0.7;
        translate([0, -shelf_d + lip_t - d / 2 + 0.01, lip_hh * 0.45])
            cube([pad_recess_w, d + 0.02, h], center = true);
    }

    // Two velcro-strap slots through the shelf, placed at 30% / 70% of the
    // usable depth — between the pad strips, never under one.
    module _strap_slots() {
        for (k = [0, 1]) {
            y = -shelf_d + lip_t + span_d * (k == 0 ? 0.3 : 0.7);
            translate([0, y, -shelf_t / 2])
                cube([25, 4, shelf_t + 2], center = true);
        }
    }

    // Seamless wrap-around rim ("rails" retention): one continuous rounded wall
    // around the cabinet pocket — tall side rails (`rail_h`), a low front lip
    // (`lip_hh`), and a rear heel (`rear_heel_h`) with a central cable notch.
    // Built from a single rect_tube (fused corners), then the top edge is carved
    // to a ramped profile: the front lip rises at 45 deg into the side rails and
    // the rails fall at 45 deg into the rear heel, so the whole rim top flows.
    module _rim() {
        ow = speaker_w + 2 * cabinet_clearance + 2 * rail_t;   // outer width
        od = shelf_d;                                          // front edge..rear edge
        irad = max(0.1, corner_r - rail_t);
        front_inner = -shelf_d + rail_t;     // inner face of the front lip
        rear_inner  = -rail_t;               // inner face of the rear heel
        fr = rail_h - lip_hh;                // 45 deg front ramp (rise = run)
        rr = rail_h - rear_heel_h;           // 45 deg rear ramp
        top = rail_h + 10;
        // Top-edge cut profile in (y, z): low across the front lip, ramping up to
        // the side rails, holding, then ramping down to the rear heel.
        profile = rear_heel
            ? [[-shelf_d - 1, lip_hh], [front_inner, lip_hh],
               [front_inner + fr, rail_h], [rear_inner - rr, rail_h],
               [rear_inner, rear_heel_h], [1, rear_heel_h], [1, top], [-shelf_d - 1, top]]
            : [[-shelf_d - 1, lip_hh], [front_inner, lip_hh],
               [front_inner + fr, rail_h], [1, rail_h], [1, top], [-shelf_d - 1, top]];
        difference() {
            translate([0, -shelf_d / 2, -1])
                rect_tube(h = rail_h + 1, size = [ow, od], wall = rail_t,
                          rounding = corner_r, irounding = irad, anchor = BOTTOM);
            // carve the ramped top profile across the full width
            rotate([0, 0, 90]) rotate([90, 0, 0])
                linear_extrude(height = ow + 4, center = true)
                    polygon(profile);
            if (rear_heel)
                // central cable notch through the rear heel
                translate([-rear_heel_notch_w / 2, rear_inner - 2, -2])
                    cube([rear_heel_notch_w, rail_t + 3, rail_h + 5]);
            else {
                // open back: drop the rear wall but keep the side rails full-length
                inner_half = ow / 2 - rail_t;
                translate([-inner_half, rear_inner, -2])
                    cube([2 * inner_half, rail_t + 1, rail_h + 5]);
            }
        }
    }

    // Rounded eyelet tab below the plate, flush with the REAR face (prints flat
    // on the bed). Takes a velcro/cable loop through an 8mm hole.
    module _cable_eyelet() {
        translate([0, -2.5, -plate_h + 1])
            cuboid([26, 5, 19], rounding = 8, edges = [BOTTOM + LEFT, BOTTOM + RIGHT],
                   anchor = TOP);
    }
    module _eyelet_hole() {
        translate([0, 1, -plate_h - 9])
            rotate([90, 0, 0])
                cylinder(d = 8, h = 7, $fn = 48);
    }
}

// ===================== src/pads.scad =====================
// Separately-printed TPU 95A pads that drop into the shelf's pad recesses.
// Pads are 0.3mm undersized in plan (press fit) and `pad_recess_depth +
// pad_proud` thick, so they stand `pad_proud` above the shelf and grip the
// cabinet. 95A is firm: slice with ~10-20% gyroid and few/no top layers for
// compliance (the slicer supplies the softness, not the geometry).


module tpu_pads(
    speaker_w        = 145,
    shelf_d          = 180,
    lip_t            = 4,
    pad_recess_depth = 1.5,
    pad_recess_w     = 25,
    pad_count        = 3,
    pad_proud        = 1,
    lip_pad_recess   = true,
    lip_h            = 6,
    layout           = false   // true = lay pads flat & spaced for a print plate
) {
    echo("NOTE: tpu_pads() prints in TPU 95A (flexible). Render Part=\"pads\" and slice separately from the PETG bracket.");

    span_d = shelf_usable_d(shelf_d, lip_t);
    lip_hh = lip_total_h(lip_h, pad_proud);

    pad_len = speaker_w - 0.3;
    pad_t   = pad_recess_depth + pad_proud;
    fit_w   = pad_recess_w - 0.3;

    if (layout) {
        // flat on the bed, spaced out for printing
        for (i = [0 : pad_count - 1])
            translate([0, i * (pad_recess_w + 5), 0])
                cube([pad_len, fit_w, pad_t], center = true);
        if (lip_pad_recess)
            translate([0, -pad_recess_w - 5, 0])
                cube([fit_w, lip_hh * 0.7 - 0.3, 2], center = true);
    } else {
        // in-situ in the shelf recesses for preview / assembly
        for (i = [0 : pad_count - 1]) {
            y = -shelf_d + lip_t + span_d / 2
                + pad_center_y(i, pad_count, span_d, pad_recess_w);
            // bottom at the recess floor, top `pad_proud` above the shelf
            translate([0, y, -pad_recess_depth + pad_t / 2])
                cube([pad_len, fit_w, pad_t], center = true);
        }
        if (lip_pad_recess) {
            // 1mm seated in the lip recess + 1mm proud of the lip inner face
            translate([0, -shelf_d + lip_t, lip_hh * 0.45])
                cube([fit_w, 2, lip_hh * 0.7 - 0.3], center = true);
        }
    }
}

// ===================== src/assembly.scad =====================
// Visual-verification assembly: the bracket, the TPU pads, and a translucent
// bounding box standing in for the speaker cabinet. By construction the cabinet
// box sits against the lip (front) with `cabinet_clearance`, on top of the
// pads, and its rear face overhangs the plate by `rear_overhang` — above where
// the arm head lives.


module demo_assembly(
    speaker_w        = 145,
    speaker_d        = 207,
    speaker_h        = 237,
    cabinet_clearance= 0.5,
    shelf_w          = 160,
    shelf_d          = 216,
    shelf_t          = 7,
    lip_h            = 6,
    lip_t            = 4,
    plate_w          = 130,
    plate_h          = 130,
    plate_t          = 8,
    vesa_drop        = 70,
    vesa_pattern     = 100,
    fastening        = "insert",
    insert_d         = 5.6,
    insert_depth     = 9,
    insert_boss_d    = 12,
    insert_boss_h    = 4,
    vesa_hole_d      = 4.5,
    nut_af           = 7.0,
    nut_trap_depth   = 3.2,
    gusset_count     = 2,
    gusset_t         = 5,
    gusset_depth     = 0,
    gusset_h         = 0,
    fillet_r         = 3,
    pad_recess_depth = 1.5,
    pad_recess_w     = 25,
    pad_count        = 3,
    pad_proud        = 1,
    lip_pad_recess   = true,
    retention_style  = "rails",
    rail_t           = 4,
    rail_h           = 35,
    rear_heel        = true,
    rear_heel_h      = 25,
    rear_heel_notch_w= 40,
    cable_hook       = false,
    corner_r         = 6,
    mirror_part      = false
) {
    bracket(speaker_w = speaker_w, speaker_d = speaker_d,
            cabinet_clearance = cabinet_clearance,
            shelf_w = shelf_w, shelf_d = shelf_d, shelf_t = shelf_t,
            lip_h = lip_h, lip_t = lip_t,
            plate_w = plate_w, plate_h = plate_h, plate_t = plate_t,
            vesa_drop = vesa_drop, vesa_pattern = vesa_pattern,
            fastening = fastening, insert_d = insert_d, insert_depth = insert_depth,
            insert_boss_d = insert_boss_d, insert_boss_h = insert_boss_h,
            vesa_hole_d = vesa_hole_d, nut_af = nut_af,
            nut_trap_depth = nut_trap_depth,
            gusset_count = gusset_count, gusset_t = gusset_t,
            gusset_depth = gusset_depth, gusset_h = gusset_h,
            fillet_r = fillet_r,
            pad_recess_depth = pad_recess_depth, pad_recess_w = pad_recess_w,
            pad_count = pad_count, pad_proud = pad_proud,
            lip_pad_recess = lip_pad_recess,
            retention_style = retention_style, rail_t = rail_t, rail_h = rail_h,
            rear_heel = rear_heel, rear_heel_h = rear_heel_h,
            rear_heel_notch_w = rear_heel_notch_w,
            cable_hook = cable_hook, corner_r = corner_r,
            mirror_part = mirror_part);

    tpu_pads(speaker_w = speaker_w, shelf_d = shelf_d, lip_t = lip_t,
             pad_recess_depth = pad_recess_depth, pad_recess_w = pad_recess_w,
             pad_count = pad_count, pad_proud = pad_proud,
             lip_pad_recess = lip_pad_recess, lip_h = lip_h);

    // translucent cabinet, front face against the lip (+ clearance), resting
    // on the proud pads; the rear face overhangs the plate rear face.
    cab_front = -shelf_d + lip_t + cabinet_clearance;
    %translate([0, cab_front + speaker_d / 2, pad_proud + speaker_h / 2])
        cube([speaker_w, speaker_d, speaker_h], center = true);
}

// ===================== derived values + geometry (entry) =====================
/* [Hidden] */
$fn = 64;

// ---- auto-sized shelf + print-setting hint -----------------------------------
_shelf_w = auto_shelf_w(shelf_w, speaker_w, cabinet_clearance, rail_t);
_shelf_d = auto_shelf_d(shelf_d, speaker_d, cabinet_clearance, rail_t);

echo(str("[PRINT] For ", speaker_weight_kg, " kg: PETG, ",
         recommended_walls(speaker_weight_kg), " walls, ",
         recommended_infill_pct(speaker_weight_kg),
         "% gyroid infill, printed plate-rear-face DOWN, no supports."));

if (Part == "bracket")
    bracket(speaker_w = speaker_w, speaker_d = speaker_d,
            cabinet_clearance = cabinet_clearance,
            shelf_w = _shelf_w, shelf_d = _shelf_d, shelf_t = shelf_t,
            lip_h = lip_h, lip_t = lip_t,
            plate_w = plate_w, plate_h = plate_h, plate_t = plate_t,
            vesa_drop = vesa_drop, vesa_pattern = vesa_pattern,
            fastening = fastening, insert_d = insert_d,
            insert_depth = insert_depth, insert_boss_d = insert_boss_d,
            insert_boss_h = insert_boss_h, vesa_hole_d = vesa_hole_d,
            nut_af = nut_af, nut_trap_depth = nut_trap_depth,
            gusset_count = gusset_count, gusset_t = gusset_t,
            gusset_depth = gusset_depth, gusset_h = gusset_h,
            fillet_r = fillet_r,
            pad_recess_depth = pad_recess_depth, pad_recess_w = pad_recess_w,
            pad_count = pad_count, pad_proud = pad_proud,
            lip_pad_recess = lip_pad_recess,
            retention_style = retention_style, rail_t = rail_t, rail_h = rail_h,
            rear_heel = rear_heel, rear_heel_h = rear_heel_h,
            rear_heel_notch_w = rear_heel_notch_w,
            cable_hook = cable_hook, corner_r = corner_r,
            mirror_part = mirror_part);
else if (Part == "pads")
    tpu_pads(speaker_w = speaker_w, shelf_d = _shelf_d, lip_t = lip_t,
             pad_recess_depth = pad_recess_depth, pad_recess_w = pad_recess_w,
             pad_count = pad_count, pad_proud = pad_proud,
             lip_pad_recess = lip_pad_recess, lip_h = lip_h,
             layout = true);
else if (Part == "assembly")
    demo_assembly(speaker_w = speaker_w, speaker_d = speaker_d,
                  speaker_h = speaker_h, cabinet_clearance = cabinet_clearance,
                  shelf_w = _shelf_w, shelf_d = _shelf_d, shelf_t = shelf_t,
                  lip_h = lip_h, lip_t = lip_t,
                  plate_w = plate_w, plate_h = plate_h, plate_t = plate_t,
                  vesa_drop = vesa_drop, vesa_pattern = vesa_pattern,
                  fastening = fastening, insert_d = insert_d,
                  insert_depth = insert_depth, insert_boss_d = insert_boss_d,
                  insert_boss_h = insert_boss_h, vesa_hole_d = vesa_hole_d,
                  nut_af = nut_af, nut_trap_depth = nut_trap_depth,
                  gusset_count = gusset_count, gusset_t = gusset_t,
                  gusset_depth = gusset_depth, gusset_h = gusset_h,
                  fillet_r = fillet_r,
                  pad_recess_depth = pad_recess_depth,
                  pad_recess_w = pad_recess_w, pad_count = pad_count,
                  pad_proud = pad_proud, lip_pad_recess = lip_pad_recess,
                  retention_style = retention_style, rail_t = rail_t,
                  rail_h = rail_h, rear_heel = rear_heel,
                  rear_heel_h = rear_heel_h, rear_heel_notch_w = rear_heel_notch_w,
                  cable_hook = cable_hook, corner_r = corner_r,
                  mirror_part = mirror_part);
else
    assert(false, str("Unknown Part: ", Part));
