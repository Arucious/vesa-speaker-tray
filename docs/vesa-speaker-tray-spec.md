# Parametric VESA Speaker Tray — OpenSCAD Design Spec

## Purpose

A 3D-printable tray that mounts a passive/active bookshelf speaker (Edifier S880DB MK II) to a standard monitor arm VESA head (Secretlab arm, 100x100 VESA, M4 hardware). The speaker sits in a lipped tray; the tray bolts to the arm. Fully parametric so the same .scad file can be re-used for other speakers, other VESA patterns, and tweaked clearances without editing geometry code.

Two trays will be printed (one per speaker). The left/active and right/passive cabinets are externally identical, so a single design suffices — but include a `mirror_part` boolean parameter anyway in case asymmetric features (e.g., rear cutout offset) are added later.

## Coordinate convention

- Origin at the center of the tray floor, top surface of the floor = Z 0.
- X = speaker width axis, Y = speaker depth axis (front of speaker = -Y), Z = up.
- Speaker cabinet rests on the tray floor; VESA interface is on the underside (Z negative).

## Parameters (all in mm unless noted; defaults shown are PLACEHOLDERS — final values come from caliper measurement of the actual cabinet)

| Parameter | Default | Notes |
|---|---|---|
| `speaker_w` | 146 | Cabinet width — MEASURE |
| `speaker_d` | 247 | Cabinet depth — MEASURE |
| `cabinet_clearance` | 0.5 | Per-side gap between cabinet and lip |
| `lip_h` | 18 | Lip height above tray floor (range 15–20) |
| `lip_t` | 4 | Lip wall thickness |
| `floor_t` | 6 | Tray floor thickness |
| `rear_cutout_w` | 120 | Width of rear lip cutout (amp plate, port, knobs, cables) |
| `rear_cutout_full` | true | If true, rear lip removed entirely across `rear_cutout_w`, down to floor level |
| `front_window` | false | Optional front lip window for aesthetics/weight |
| `vesa_pattern` | 100 | 100 or 75; hole spacing, square |
| `vesa_hole_d` | 4.5 | Through-hole for M4 clearance — OR see insert option |
| `use_inserts` | true | If true, holes sized for heat-set inserts instead of through-bolts |
| `insert_d` | 5.6 | Ruthex M4 (RX-M4x8.1) nominal pilot diameter — verify against Ruthex datasheet |
| `insert_depth` | 8.5 | Pocket depth for insert |
| `boss_d` | 14 | Cylindrical boss diameter around each VESA hole |
| `boss_h` | 8 | Boss protrusion below tray floor |
| `rib_t` | 4 | Rib thickness |
| `rib_count_x` | 2 | Ribs per side running boss→lip in X |
| `rib_count_y` | 2 | Ribs per side running boss→lip in Y |
| `pad_recess_depth` | 1.5 | Recess in floor for TPU pads |
| `pad_recess_w` | 25 | TPU pad strip width |
| `pad_count` | 3 | Pad strips across floor (front, middle, rear), running in X |
| `lip_pad_recess` | true | Shallow (1mm) recesses on inner lip faces for TPU strips |
| `strap_slots` | false | Optional: two 25x4 slots in floor near front and rear for a velcro strap |
| `corner_r` | 6 | Outer fillet radius on tray corners |
| `mirror_part` | false | Mirror about X for a handed variant |

Derived values:
- `tray_inner_w = speaker_w + 2*cabinet_clearance`
- `tray_inner_d = speaker_d + 2*cabinet_clearance`
- `tray_outer_w = tray_inner_w + 2*lip_t`
- `tray_outer_d = tray_inner_d + 2*lip_t`

## Geometry description

1. **Tray floor**: solid plate, `tray_outer_w` x `tray_outer_d` x `floor_t`, rounded corners (`corner_r`).
2. **Lip**: perimeter wall on all four sides, height `lip_h`, thickness `lip_t`. Rear side gets the cutout per `rear_cutout_w` / `rear_cutout_full` so the amp plate, bass-reflex port, rear knobs, and cabling are never obstructed and the speaker can be lifted out backward-tilted.
3. **VESA interface (underside)**: four cylindrical bosses on the `vesa_pattern` square, centered on the tray. If `use_inserts`, blind pockets sized `insert_d` x `insert_depth` opening downward (insert installed from below, bolt enters from the arm side). Else, M4 clearance through-holes with hex-nut pockets recessed into the floor top (nut trap, 7.0mm across flats, 3.2mm deep — verify DIN 934).
4. **Ribs**: from each boss, radial ribs (`rib_t` thick, full `boss_h` + `floor_t` tall at the boss, tapering toward the lip) tie the cantilevered load path into the perimeter. The dominant load case is a ~3.5 kg speaker with the arm holding the tray horizontally; bending concentrates at the boss-to-floor junction.
5. **TPU pad recesses**: `pad_count` strips recessed `pad_recess_depth` into the floor's top surface, full inner width, for separately printed TPU 95A pads (model the pads as a second part in the same file, 0.3mm undersized for press fit, `pad_recess_depth + 1`mm thick so they proud the floor by 1mm). Same treatment on inner lip faces if `lip_pad_recess`.
6. **Optional strap slots** per `strap_slots`.

## Output / module structure

- Top-level modules: `tray()`, `tpu_pads()` (echo a note that pads print in TPU), and a `demo_assembly()` showing tray + translucent speaker bounding box for visual verification.
- A `part` selector variable ("tray" / "pads" / "assembly") for export workflow.
- All features must remain valid across `vesa_pattern` 75/100 and ±20% on speaker dimensions (no overlapping holes, ribs auto-spacing).
- `$fn = 64` minimum on cylinders.

## Printing intent (informs design, not code)

- Body: PETG or PETG-CF, printed floor-down, 6 walls, 40%+ infill or solid in the boss region (the agent should keep boss/rib geometry friendly to this orientation — no floating overhangs > 50°).
- Pads: TPU 95A.
- Bambu P1S, 0.4 nozzle; minimum feature thickness 1.6mm.

## Acceptance criteria

1. With defaults, renders watertight (no CGAL errors), prints without supports floor-down.
2. Changing `vesa_pattern` to 75 and `speaker_w` to 120 produces valid geometry with no manual edits.
3. Speaker bounding box in `demo_assembly()` clears the lip by exactly `cabinet_clearance` per side.
4. Rear cutout leaves zero lip material within `rear_cutout_w` when `rear_cutout_full` is true.
5. Insert pockets are blind (do not break through the tray floor's top surface).
