/*
  Parametric VESA Speaker Bracket (v2)
  ------------------------------------
  Mounts a bookshelf speaker to a monitor-arm VESA head (100x100 / 75x75, M4)
  kept in its normal, vertical orientation: a vertical VESA plate sits below a
  cantilevered shelf braced by triangular gussets. The speaker rests on TPU
  pads behind a front retention lip (plus an optional strap or side rails);
  its rear face — bass-reflex port and all I/O — stays fully unobstructed.

  v1 (a tray bolting to an upward-facing VESA head) is unmountable on arms
  that cannot tilt the head past +70°, like the Secretlab MAGNUS. See
  docs/vesa-speaker-tray-spec.md for the v2 rationale and load case.

  Fully parametric: re-target other speakers / VESA patterns / clearances
  without touching geometry. Edit the values below (or use OpenSCAD's
  Customizer) and pick a Part to export.

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

// `use` does not import these top-level vars into the modules, so every value
// is passed explicitly below.

/* [Output] */
// Which part to render / export.
Part = "bracket"; // [bracket, pads, assembly]

/* [Speaker] */
// Cabinet width — verify with calipers
speaker_w = 145;
// Cabinet depth — verify with calipers
speaker_d = 207;
// Cabinet height (assembly preview only)
speaker_h = 237;
// Per-side gap between cabinet and lip/rails
cabinet_clearance = 0.5;

/* [Shelf] */
shelf_w = 150;
// Less than speaker_d on purpose: the cabinet overhangs the rear, above the arm head
shelf_d = 180;
shelf_t = 7;
// EFFECTIVE retention height above the pad top
lip_h = 6;
lip_t = 4;

/* [VESA plate] */
plate_w = 130;
plate_h = 130;
plate_t = 8;
// Shelf top -> VESA square center; raise if your arm head is tall
vesa_drop = 70;
// Hole spacing, square
vesa_pattern = 100; // [75, 100]

/* [Fastening] */
// Heat-set inserts (blind, rear face) or M4 through-bolts + front nut traps
fastening = "insert"; // [insert, through]
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

/* [Gussets] */
gusset_count = 2;
gusset_t = 5;
// 0 = auto: full usable depth
gusset_depth = 0;
// 0 = auto: full plate height
gusset_h = 0;
// Shelf-to-plate junction fillet
fillet_r = 3;

/* [Pads] */
// Deepen to ~2.2 for 3.2mm sorbothane/EVA sheet instead of printed TPU
pad_recess_depth = 1.5;
pad_recess_w = 25;
pad_count = 3;
// How far pads stand above the shelf top
pad_proud = 1;
lip_pad_recess = true;

/* [Retention] */
// lip = front lip only; strap = lip + velcro slots; rails = lip + side rails
retention_style = "strap"; // [lip, strap, rails]
rail_t = 4;

/* [Extras] */
// Eyelet tab below the plate for a cable loop
cable_hook = false;
corner_r = 6;
mirror_part = false;

/* [Hidden] */
$fn = 64;

if (Part == "bracket")
    bracket(speaker_w = speaker_w, speaker_d = speaker_d,
            cabinet_clearance = cabinet_clearance,
            shelf_w = shelf_w, shelf_d = shelf_d, shelf_t = shelf_t,
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
            retention_style = retention_style, rail_t = rail_t,
            cable_hook = cable_hook, corner_r = corner_r,
            mirror_part = mirror_part);
else if (Part == "pads")
    tpu_pads(speaker_w = speaker_w, shelf_d = shelf_d, lip_t = lip_t,
             pad_recess_depth = pad_recess_depth, pad_recess_w = pad_recess_w,
             pad_count = pad_count, pad_proud = pad_proud,
             lip_pad_recess = lip_pad_recess, lip_h = lip_h,
             layout = true);
else if (Part == "assembly")
    demo_assembly(speaker_w = speaker_w, speaker_d = speaker_d,
                  speaker_h = speaker_h, cabinet_clearance = cabinet_clearance,
                  shelf_w = shelf_w, shelf_d = shelf_d, shelf_t = shelf_t,
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
                  cable_hook = cable_hook, corner_r = corner_r,
                  mirror_part = mirror_part);
else
    assert(false, str("Unknown Part: ", Part));
