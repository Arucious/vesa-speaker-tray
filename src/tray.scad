// Parametric VESA speaker tray body.
//
// Coordinate convention (from the spec):
//   - origin at the center of the tray floor; top surface of the floor = z 0.
//   - X = speaker width, Y = speaker depth (front of speaker = -Y), Z = up.
//   - cabinet rests on the floor (z >= 0); the VESA interface is on the
//     underside (z < 0).
//
// tray() takes every tunable as an argument (no reliance on top-level customizer
// vars leaking in through `use`).

include <BOSL2/std.scad>
use <params.scad>

module tray(
    speaker_w        = 146,
    speaker_d        = 247,
    cabinet_clearance= 0.5,
    lip_h            = 18,
    lip_t            = 4,
    floor_t          = 6,
    rear_cutout_w    = 120,
    rear_cutout_full = true,
    front_window     = false,
    vesa_pattern     = 100,
    vesa_hole_d      = 4.5,
    use_inserts      = true,
    insert_d         = 5.6,
    insert_depth     = 8.5,
    boss_d           = 14,
    boss_h           = 8,
    rib_t            = 4,
    rib_count_x      = 2,
    rib_count_y      = 2,
    pad_recess_depth = 1.5,
    pad_recess_w     = 25,
    pad_count        = 3,
    lip_pad_recess   = true,
    strap_slots      = false,
    corner_r         = 6,
    mirror_part      = false,
    nut_af           = 7.0,    // DIN 934 M4 hex nut across-flats
    nut_trap_depth   = 3.2
) {
    inner_w = tray_inner_w(speaker_w, cabinet_clearance);
    inner_d = tray_inner_d(speaker_d, cabinet_clearance);
    outer_w = inner_w + 2 * lip_t;
    outer_d = inner_d + 2 * lip_t;
    half_v  = vesa_pattern / 2;
    inner_r = max(0.1, corner_r - lip_t);

    // ----- validation (fail loudly rather than emit broken geometry) ---------
    assert(bosses_fit(vesa_pattern, boss_d, outer_w, outer_d),
           "VESA bosses overlap or exceed the tray footprint (check boss_d / vesa_pattern / speaker size)");
    assert(insert_pocket_blind(use_inserts, insert_depth, floor_t, boss_h),
           "Insert pocket would break through the floor top: need insert_depth < floor_t + boss_h");
    assert(rear_cutout_w <= inner_w, "rear_cutout_w exceeds the inner cavity width");

    if (mirror_part) mirror([1, 0, 0]) _body();
    else _body();

    // -------------------------------------------------------------------------
    module _body() {
        difference() {
            union() {
                _floor();
                _lip();
                _bosses();
                _ribs();
            }
            _rear_cutout();
            if (front_window) _front_window();
            _vesa_holes();
            _pad_recesses();
            if (lip_pad_recess) _lip_recesses();
            if (strap_slots) _strap_slots();
        }
    }

    // Solid floor plate, top face at z = 0, extending down by floor_t.
    module _floor() {
        cuboid([outer_w, outer_d, floor_t], rounding = corner_r, edges = "Z",
               anchor = TOP);
    }

    // Perimeter lip, z 0 .. lip_h.
    module _lip() {
        difference() {
            cuboid([outer_w, outer_d, lip_h], rounding = corner_r, edges = "Z",
                   anchor = BOTTOM);
            // inner cavity (slightly taller so the top face cuts cleanly)
            up(-0.5) cuboid([inner_w, inner_d, lip_h + 1], rounding = inner_r,
                            edges = "Z", anchor = BOTTOM);
        }
    }

    // Cylindrical bosses around each VESA hole, z 0 .. -(floor_t+boss_h).
    module _bosses() {
        for (o = vesa_offsets(vesa_pattern))
            translate([o[0], o[1], -(floor_t + boss_h)])
                cylinder(d = boss_d, h = floor_t + boss_h, $fn = max(64, $fn));
    }

    // Radial tapered fins from each boss to the nearest lip walls, tying the
    // cantilevered boss-to-floor junction into the perimeter. Below-floor height
    // is boss_h at the boss, tapering to 0 at the wall.
    module _ribs() {
        for (o = vesa_offsets(vesa_pattern)) {
            sx = sign(o[0]); sy = sign(o[1]);
            lx = inner_w / 2 - half_v - 0.5;   // boss -> near X wall gap
            ly = inner_d / 2 - half_v - 0.5;   // boss -> near Y wall gap
            if (lx > 1)
                for (k = [0 : max(0, rib_count_x - 1)]) {
                    off = rib_count_x <= 1 ? 0 : (k / (rib_count_x - 1) - 0.5) * boss_d * 0.6;
                    translate([o[0], o[1] + off, -floor_t])
                        _fin(lx, boss_h, rib_t, sx > 0 ? 0 : 180);
                }
            if (ly > 1)
                for (k = [0 : max(0, rib_count_y - 1)]) {
                    off = rib_count_y <= 1 ? 0 : (k / (rib_count_y - 1) - 0.5) * boss_d * 0.6;
                    translate([o[0] + off, o[1], -floor_t])
                        _fin(ly, boss_h, rib_t, sy > 0 ? 90 : 270);
                }
        }
    }

    // One fin: grows along +X (rotated by `ang`), thickness in the perpendicular
    // axis, full `height` downward at the near end tapering to ~0 at length.
    module _fin(length, height, thick, ang) {
        rotate([0, 0, ang])
            hull() {
                translate([0, 0, -height / 2]) cube([0.01, thick, height], center = true);
                translate([length, 0, -0.005]) cube([0.01, thick, 0.01], center = true);
            }
    }

    // Rear lip removed across rear_cutout_w, full height down to the floor top.
    module _rear_cutout() {
        if (rear_cutout_full)
            translate([0, outer_d / 2, lip_h / 2 + 0.5])
                cube([rear_cutout_w, 2 * lip_t + 2, lip_h + 2], center = true);
    }

    // Optional aesthetic/weight window in the front (-Y) lip, leaving a base rail.
    module _front_window() {
        w = min(rear_cutout_w * 0.6, inner_w * 0.6);
        h = lip_h * 0.5;
        translate([0, -outer_d / 2, lip_h * 0.6])
            cube([w, 2 * lip_t + 2, h], center = true);
    }

    // Either blind heat-set pockets (opening downward from the boss underside)
    // or M4 clearance through-holes with a hex nut trap recessed into the top.
    module _vesa_holes() {
        for (o = vesa_offsets(vesa_pattern))
            translate([o[0], o[1], 0]) {
                if (use_inserts) {
                    bottom = -(floor_t + boss_h);
                    translate([0, 0, bottom - 0.01])
                        cylinder(d = insert_d, h = insert_depth + 0.01, $fn = 64);
                } else {
                    translate([0, 0, -(floor_t + boss_h) - 1])
                        cylinder(d = vesa_hole_d, h = floor_t + boss_h + 2, $fn = 64);
                    // hex nut trap, recessed into the floor top surface
                    translate([0, 0, -nut_trap_depth])
                        rotate([0, 0, 30])
                            cylinder(d = hex_corner_d(nut_af), h = nut_trap_depth + 0.01,
                                     $fn = 6);
                }
            }
    }

    // TPU pad recesses in the floor top: full inner width, running in X.
    module _pad_recesses() {
        for (i = [0 : pad_count - 1]) {
            y = pad_center_y(i, pad_count, inner_d, pad_recess_w);
            translate([0, y, -pad_recess_depth / 2 + 0.005])
                cube([inner_w, pad_recess_w, pad_recess_depth + 0.01], center = true);
        }
    }

    // Shallow (1mm) TPU recesses on the inner side and front lip faces.
    module _lip_recesses() {
        d = 1; h = lip_h * 0.7;
        for (sx = [-1, 1])
            translate([sx * (inner_w / 2 - d / 2), 0, lip_h * 0.5])
                cube([d + 0.02, pad_recess_w, h], center = true);
        translate([0, -(inner_d / 2 - d / 2), lip_h * 0.5])
            cube([pad_recess_w, d + 0.02, h], center = true);
    }

    // Two velcro-strap slots through the floor near the front and rear.
    module _strap_slots() {
        for (sy = [-1, 1])
            translate([0, sy * (inner_d / 2 - 20), -floor_t / 2])
                cube([25, 4, floor_t + 2], center = true);
    }
}
