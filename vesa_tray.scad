/*
  Parametric VESA Speaker Tray
  ----------------------------
  A 3D-printable tray that mounts a bookshelf speaker to a monitor-arm VESA head
  (100x100 / 75x75, M4). The speaker sits in a lipped tray; the tray bolts to the
  arm via heat-set inserts (or through-bolts + nut traps) on cylindrical bosses,
  with ribbed bracing carrying the cantilevered load into the perimeter.

  Fully parametric: re-target other speakers / VESA patterns / clearances without
  touching geometry. Edit the values below (or use OpenSCAD's Customizer) and pick
  a Part to export.

  Defaults are PLACEHOLDERS from the spec — measure the actual cabinet with
  calipers before printing. See docs/vesa-speaker-tray-spec.md.

  License: MIT (see LICENSE).
*/

use <src/tray.scad>
use <src/pads.scad>
use <src/assembly.scad>

// `use` does not import these top-level vars into the modules, so every value is
// passed explicitly below.

/* [Output] */
// Which part to render / export.
Part = "tray"; // [tray, pads, assembly]

/* [Speaker] */
speaker_w         = 146;   // cabinet width  (MEASURE)
speaker_d         = 247;   // cabinet depth  (MEASURE)
cabinet_clearance = 0.5;   // per-side gap between cabinet and lip

/* [Tray] */
lip_h   = 18;              // [10:0.5:25] lip height above the floor
lip_t   = 4;               // lip wall thickness
floor_t = 6;               // floor thickness
corner_r= 6;               // outer corner fillet radius

/* [Rear / Front openings] */
rear_cutout_w    = 120;    // width of the rear lip cutout (amp plate, port, cables)
rear_cutout_full = true;   // remove the rear lip entirely across rear_cutout_w
front_window     = false;  // optional window in the front lip

/* [VESA mount] */
vesa_pattern = 100;        // [100, 75] hole spacing (square)
use_inserts  = true;       // heat-set inserts (true) or through-bolts + nut trap (false)
vesa_hole_d  = 4.5;        // M4 clearance through-hole (when use_inserts = false)
insert_d     = 5.6;        // Ruthex M4 heat-set pilot diameter (verify vs datasheet)
insert_depth = 8.5;        // insert pocket depth
boss_d       = 14;         // boss diameter around each hole
boss_h       = 8;          // boss protrusion below the floor

/* [Ribs] */
rib_t       = 4;           // rib thickness
rib_count_x = 2;           // ribs per boss toward the X walls
rib_count_y = 2;           // ribs per boss toward the Y walls

/* [TPU pads] */
pad_recess_depth = 1.5;    // recess depth in the floor for TPU pads
pad_recess_w     = 25;     // pad strip width
pad_count        = 3;      // [1:6] number of pad strips across the floor
lip_pad_recess   = true;   // shallow TPU recesses on the inner lip faces

/* [Options] */
strap_slots = false;       // velcro-strap slots through the floor
mirror_part = false;       // mirror about X for a handed variant

/* [Quality] */
$fn = 64;                  // minimum facets on cylinders (spec)

// ---------------------------------------------------------------------------
if (Part == "tray")
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
else if (Part == "pads")
    tpu_pads(speaker_w = speaker_w, speaker_d = speaker_d,
             cabinet_clearance = cabinet_clearance, pad_recess_depth = pad_recess_depth,
             pad_recess_w = pad_recess_w, pad_count = pad_count,
             lip_pad_recess = lip_pad_recess, lip_h = lip_h, layout = true);
else
    demo_assembly(speaker_w = speaker_w, speaker_d = speaker_d,
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
