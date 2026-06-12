// Visual-verification assembly: the tray, the TPU pads, and a translucent
// bounding box standing in for the speaker cabinet. By construction the cabinet
// box clears the inner lip by exactly `cabinet_clearance` per side.

use <tray.scad>
use <pads.scad>
use <params.scad>

module demo_assembly(
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
    demo_speaker_h   = 230   // visualization only; not a tray parameter
) {
    tray(speaker_w = speaker_w, speaker_d = speaker_d,
         cabinet_clearance = cabinet_clearance, lip_h = lip_h, lip_t = lip_t,
         floor_t = floor_t, rear_cutout_w = rear_cutout_w,
         rear_cutout_full = rear_cutout_full, front_window = front_window,
         vesa_pattern = vesa_pattern, vesa_hole_d = vesa_hole_d,
         use_inserts = use_inserts, insert_d = insert_d, insert_depth = insert_depth,
         boss_d = boss_d, boss_h = boss_h, rib_t = rib_t,
         rib_count_x = rib_count_x, rib_count_y = rib_count_y,
         pad_recess_depth = pad_recess_depth, pad_recess_w = pad_recess_w,
         pad_count = pad_count, lip_pad_recess = lip_pad_recess,
         strap_slots = strap_slots, corner_r = corner_r, mirror_part = mirror_part);

    tpu_pads(speaker_w = speaker_w, speaker_d = speaker_d,
             cabinet_clearance = cabinet_clearance, pad_recess_depth = pad_recess_depth,
             pad_recess_w = pad_recess_w, pad_count = pad_count,
             lip_pad_recess = lip_pad_recess, lip_h = lip_h);

    // translucent cabinet bounding box, resting on the floor + 1mm proud pads
    pad_top = pad_recess_depth + 1 - pad_recess_depth;   // = 1mm above floor
    %translate([0, 0, pad_top + demo_speaker_h / 2])
        cube([speaker_w, speaker_d, demo_speaker_h], center = true);
}
