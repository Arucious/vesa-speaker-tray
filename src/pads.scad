// Separately-printed TPU 95A pads that drop into the shelf's pad recesses.
// Pads are 0.3mm undersized in plan (press fit) and `pad_recess_depth +
// pad_proud` thick, so they stand `pad_proud` above the shelf and grip the
// cabinet. 95A is firm: slice with ~10-20% gyroid and few/no top layers for
// compliance (the slicer supplies the softness, not the geometry).

use <params.scad>

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
