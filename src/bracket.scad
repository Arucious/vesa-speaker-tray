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

include <BOSL2/std.scad>
use <params.scad>

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
                _lip();
                if (fastening == "insert") _insert_bosses();
                if (retention_style == "rails") _rails();
                if (rear_heel) _rear_heel();
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

    // Side rails: walls flanking the cabinet, `rail_h` tall. Buried 1mm into the
    // shelf and the lip, and stopped 1mm shy of the rear edge, so no union face
    // is tangent or coplanar with an exterior face.
    module _rails() {
        y_rear  = 0;                         // reach the rear edge so the rail
                                             // lands on the bed (no floating end)
        y_front = -(shelf_d - lip_t + 1);    // bury 1mm into the front lip
        len = y_rear - y_front;
        for (sx = [-1, 1])
            translate([sx * (speaker_w / 2 + cabinet_clearance + rail_t / 2),
                       (y_rear + y_front) / 2, -1])
                cuboid([rail_t, len, rail_h + 1],
                       rounding = min(1.9, rail_t / 2 - 0.1), edges = "Z",
                       anchor = BOTTOM);
    }

    // Rear heel: two posts at the shelf rear edge, behind the cabinet, that stop
    // it sliding/tipping backward off the open rear. A central notch
    // (rear_heel_notch_w) lets the speaker's cables pass through and drop down
    // the arm side of the plate.
    module _rear_heel() {
        pw = (shelf_w - 2 * corner_r - rear_heel_notch_w) / 2;
        if (pw > 1)
            for (sx = [-1, 1])
                translate([sx * (rear_heel_notch_w / 2 + pw / 2),
                           -lip_t / 2, -1])
                    cube([pw, lip_t, rear_heel_h + 1], anchor = BOTTOM);
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
