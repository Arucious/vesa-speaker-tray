// Visual-verification assembly: the bracket, the TPU pads, and a translucent
// bounding box standing in for the speaker cabinet. By construction the cabinet
// box sits against the lip (front) with `cabinet_clearance`, on top of the
// pads, and its rear face overhangs the plate by `rear_overhang` — above where
// the arm head lives.

use <bracket.scad>
use <pads.scad>
use <params.scad>

module demo_assembly(
    speaker_w        = 145,
    speaker_d        = 207,
    speaker_h        = 237,
    cabinet_clearance= 0.5,
    shelf_w          = 150,
    shelf_d          = 180,
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
    retention_style  = "strap",
    rail_t           = 4,
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
            retention_style = retention_style, rail_t = rail_t,
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
