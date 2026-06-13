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

use <src/bracket.scad>
use <src/pads.scad>
use <src/assembly.scad>
use <src/params.scad>

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
