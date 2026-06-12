// Separately-printed TPU 95A pads that drop into the tray's pad recesses.
// Pads are 0.3mm undersized in plan (press fit) and `pad_recess_depth + 1`mm
// thick, so they stand 1mm proud of the floor and grip the cabinet.

use <params.scad>

module tpu_pads(
    speaker_w        = 146,
    speaker_d        = 247,
    cabinet_clearance= 0.5,
    pad_recess_depth = 1.5,
    pad_recess_w     = 25,
    pad_count        = 3,
    lip_pad_recess   = true,
    lip_h            = 18,
    layout           = false   // true = lay pads flat & spaced for a print plate
) {
    echo("NOTE: tpu_pads() prints in TPU 95A (flexible). Render Part=\"pads\" and slice separately from the PETG tray.");

    inner_w = tray_inner_w(speaker_w, cabinet_clearance);
    inner_d = tray_inner_d(speaker_d, cabinet_clearance);

    pad_w = inner_w - 0.3;
    pad_t = pad_recess_depth + 1;            // proud by 1mm
    fit_w = pad_recess_w - 0.3;

    if (layout) {
        // flat on the bed, spaced out for printing
        for (i = [0 : pad_count - 1])
            translate([0, i * (pad_recess_w + 5), 0])
                cube([pad_w, fit_w, pad_t], center = true);
    } else {
        // in-situ in the floor recesses for preview / assembly
        for (i = [0 : pad_count - 1]) {
            y = pad_center_y(i, pad_count, inner_d, pad_recess_w);
            // bottom sits at the recess floor (-pad_recess_depth), top 1mm proud
            translate([0, y, -pad_recess_depth + pad_t / 2])
                cube([pad_w, fit_w, pad_t], center = true);
        }
        if (lip_pad_recess) {
            lip_t_pad = 2;                   // 1mm seated + 1mm proud
            for (sx = [-1, 1])
                translate([sx * (inner_w / 2 - 0.5), 0, lip_h * 0.5])
                    cube([lip_t_pad, fit_w, lip_h * 0.7 - 0.3], center = true);
        }
    }
}
