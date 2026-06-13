# Parametric VESA Speaker Bracket (v2) — OpenSCAD Design Spec

## Purpose

A 3D-printable bracket that mounts a bookshelf speaker (Edifier S880DB MK2) to a
standard monitor-arm VESA head (Secretlab MAGNUS arm, 75×75 / 100×100, M4).
A **vertical VESA plate** sits below a **cantilevered horizontal shelf**, braced
by triangular gussets. The speaker sits on the shelf on TPU pads, retained by a
front lip plus an optional strap or side rails. Two brackets will be printed
(one per speaker); the cabinets are externally identical, but `mirror_part` is
kept for future asymmetric features.

Fully parametric: other speakers, VESA patterns, and clearances are reachable by
changing parameters, never geometry code.

### Why v2 (v1 is unmountable)

v1 was a tray with the VESA interface on its **underside**, requiring the arm
head to tilt until the VESA plate faces the ceiling. The Secretlab MAGNUS arm's
tilt range is **+70°/−90°** (swivel/rotation ±90° don't help), so the plate can
never face up: v1 cannot mount on this arm. v2 keeps the arm in its normal
orientation (plate vertical).

### Why the plate sits BELOW the shelf (not behind the cabinet)

The cabinet is rear-ported and the active speaker's I/O (power, RCA/optical,
knobs) is on the rear face, with connectors protruding 20–40 mm. A plate behind
the cabinet would block them or force a large standoff. Putting the plate
entirely below the shelf keeps the rear face clear; cables exit the rear, pass
through the central notch in the rear heel, and drop down the arm side of the
plate (gathered by the optional cable hook).

### Retention vs. overhang (resolved: full support + rear heel)

An earlier revision ran a shelf shallower than the cabinet so the rear
overhung into open air (less cantilever moment, cables drop freely). That
precludes a rear stop — there's no shelf behind the cabinet to mount one — and
a strap-over-the-top is impractical for a 237 mm cabinet. This revision instead
supports the **full** cabinet depth and captures it on all sides: front lip +
side rails + a rear heel (with a cable notch). The cost is a deeper shelf and a
larger cantilever moment (centroid ≈ 105 mm forward of the plate ⇒ ≈ 3.7 N·m at
3.5 kg), still well within the gusset/insert capacity; creep, not strength,
remains the design driver.

## Coordinate convention

- X = speaker width axis. Y = depth axis, **front of speaker = −Y**. Z = up.
- Origin: shelf top surface = Z 0; **plate rear face = Y 0** (the face the arm's
  VESA plate bolts against). The shelf spans Y −`shelf_d`‥0; the plate spans
  Y −`plate_t`‥0, Z −`plate_h`‥0.
- VESA hole square is centered at X 0, Z −`vesa_drop`, on the plate.

## Load case (sets defaults; not enforced in code)

- Static: 3.5 kg per bracket (active S880DB ≈ 3.4 kg), centroid ≈ 105 mm forward
  of the plate → tipping moment ≈ 3.7 N·m → top-screw tension ≈ 19 N/screw at
  100 mm spacing. Trivial for the inserts; **creep deflection of the cantilevered
  shelf governs** — the gussets are the primary anti-creep feature; do not omit
  or shrink them.
- Dynamic: continuous low-amplitude vibration. Use spring/wave washers or
  nylon-patch M4 screws. **No liquid threadlocker** (crazes PETG). The speaker
  must be mechanically retained (lip + strap/rails), not just resting.

## Parameters (mm; speaker defaults are manufacturer specs — verify with calipers)

| Parameter | Default | Notes |
|---|---|---|
| `speaker_w` | 145 | Cabinet width (S880DB MK2: 145×237×207 W×H×D) |
| `speaker_d` | 207 | Cabinet depth |
| `speaker_h` | 237 | Cabinet height (assembly ghost + strap sizing only) |
| `cabinet_clearance` | 0.5 | Gap between cabinet and lip/rails faces |
| `shelf_w` | 0 = auto | Shelf width; auto = `speaker_w + 2·clearance + 2·rail_t + 6` |
| `shelf_d` | 0 = auto | Shelf depth; auto = `speaker_d + 2·clearance + 2·rail_t` (full support) |
| `shelf_t` | 7 | Shelf thickness (6–8) |
| `lip_h` | 6 | **Effective** lip height above the pad top (5–8) |
| `lip_t` | 4 | Lip thickness |
| `plate_w` | 130 | VESA plate width (≥ 120 to cover both patterns) |
| `plate_h` | 130 | VESA plate height |
| `plate_t` | 8 | VESA plate thickness (6–8) |
| `vesa_drop` | 70 | Shelf top → VESA square center. Raise it if your arm head is tall so it clears the underside of the shelf |
| `vesa_pattern` | 100 | 100 or 75 |
| `fastening` | "insert" | "insert" = Ruthex heat-set, blind; "through" = M4 through-bolt + front hex-nut trap |
| `insert_d` | 5.6 | Ruthex RX-M4 pilot bore — Ø5.6 per datasheet (NOT 4.0; 4.0 is the screw) |
| `insert_depth` | 9 | Blind pocket depth, opens on the REAR face (≥ insert length 8.1) |
| `insert_boss_d` | 12 | Boss on the plate FRONT face giving the pocket its dead end (≥2 mm wall around the bore) |
| `insert_boss_h` | 4 | Boss height; pocket must end ≥1.5 mm before the boss face |
| `vesa_hole_d` | 4.5 | M4 clearance bore ("through" mode) |
| `nut_af` | 7.0 | DIN 934 M4 nut across-flats ("through" mode) |
| `nut_trap_depth` | 3.2 | Hex pocket depth in the plate front face |
| `gusset_count` | 2 | Triangular gussets under the shelf |
| `gusset_t` | 5 | Gusset thickness (5–6) |
| `gusset_depth` | 0 | 0 = auto: full usable depth (to the lip's inner face) |
| `gusset_h` | 0 | 0 = auto: full plate height minus the corner rounding |
| `fillet_r` | 3 | Concave fillet bead at the shelf↔plate junction (≥ 3) |
| `pad_recess_depth` | 1.5 | Pad recess in the shelf top. For 3.2 mm sorbothane/EVA sheet (variant B) deepen to ~2.2 so the sheet sits ~1 mm proud |
| `pad_recess_w` | 25 | Pad strip width |
| `pad_count` | 3 | Strips across the cabinet footprint |
| `pad_proud` | 1 | How far pads stand above the shelf top |
| `lip_pad_recess` | true | 1 mm TPU recess on the lip inner face |
| `retention_style` | "rails" | "lip", "strap" (lip + 2 velcro slots), or "rails" (lip + side rails) |
| `rail_t` | 4 | Side-rail thickness ("rails" mode) |
| `rail_h` | 35 | Side-rail height above the shelf top ("rails" mode) |
| `rear_heel` | true | Low rear stop behind the cabinet (needs full-depth shelf) |
| `rear_heel_h` | 25 | Rear-heel height; keep below the cabinet's rear I/O panel |
| `rear_heel_notch_w` | 40 | Central cable gap in the rear heel |
| `cable_hook` | false | Eyelet tab below the plate for a cable loop/velcro |
| `corner_r` | 6 | Outer rounding (shelf corners, plate bottom corners) |
| `mirror_part` | false | Mirror about X |

Derived (functions in `src/params.scad`):
- `shelf_usable_d = shelf_d - lip_t` (lip inner face → shelf rear edge)
- `rear_overhang = speaker_d + lip_t + cabinet_clearance - shelf_d`
  (cabinet past the plate's rear face; ≤ 0 at defaults = fully supported. If
  positive, `bracket()` warns that the rear heel won't reach the cabinet.)
- `lip_total_h = lip_h + pad_proud` (physical lip height above the shelf top)

## Geometry description

1. **Plate**: vertical `plate_w` × `plate_h` × `plate_t`, top edge merged into
   the shelf's rear underside, corners rounded `corner_r`.
2. **Shelf**: horizontal `shelf_w` × `shelf_d` × `shelf_t`, rear edge flush with
   the plate's rear face, plan corners rounded `corner_r`.
3. **Junction fillet**: concave bead, radius `fillet_r`, across the plate front
   face ↔ shelf underside corner. No sharp internal corners anywhere load-bearing.
4. **Gussets**: `gusset_count` right triangles under the shelf, evenly spread
   across the plate width (outboard of the VESA holes — asserted), running the
   full usable depth and full plate height by default.
5. **VESA fastening** ("insert"): four Ø`insert_d` pockets opening on the REAR
   face, `insert_depth` deep, blind — each backed by a boss on the front face so
   the pocket dead-ends ≥ 1.5 mm before daylight. Each pocket gets a 0.4 mm-deep,
   +2 mm-Ø relief counterbore so heat-set squeeze-out stays below flush and the
   arm's VESA plate seats flat on the rear face. Inserts melt in from the rear;
   the arm's M4 screws (stock M4×10–12 + wave washer) come from the arm side.
   ("through"): Ø`vesa_hole_d` through-bores with hex-nut traps on the front face.
6. **Front lip** at the shelf's front edge, physical height `lip_h + pad_proud`
   so the *effective* retention above the pad top is `lip_h`.
7. **Retention**: a front lip is always present. "rails" (default) adds side
   walls `rail_h` tall at `speaker_w/2 + cabinet_clearance` per side; "strap"
   adds two velcro slots (legacy — impractical for a tall cabinet); "lip" is
   front-only. Independently, `rear_heel` adds two posts at the shelf's rear
   edge behind the cabinet, with a central `rear_heel_notch_w` cable gap. Lip +
   rails + heel capture the cabinet on all sides (drop-in from the top).
8. **Pads**: `pad_count` recessed strips across the cabinet footprint; separately
   printed TPU 95A pads press in 0.3 mm undersized and stand `pad_proud` above
   the shelf. Print pads with low infill / few top layers for compliance (95A is
   firm; the slicer supplies the softness, not the geometry). Variant B: deepen
   `pad_recess_depth` and cut 3.2 mm sorbothane/EVA sheet to the recess instead.
9. **Cable hook** (optional): a rounded eyelet tab extending below the plate,
   flush with the rear face, Ø8 hole for a velcro/cable loop.
10. **No structure behind or beside the cabinet's rear face** — port and I/O
    stay fully unobstructed.

## Validation (asserted by `bracket()` — fail loudly, never emit bad geometry)

- VESA holes (incl. boss/bore wall ≥ 2 mm) stay inside the plate, below the
  junction fillet, above the bottom rounding.
- Gussets never intersect a VESA hole column (bore/boss + 1 mm clearance).
- Insert pockets stay blind: `insert_depth ≤ plate_t + insert_boss_h − 1.5`.
- Effective lip ≥ 3 mm; rails fit inside the shelf width.
- These must hold across `vesa_pattern` 75/100 and ±20 % on speaker dimensions.

## Printing intent

- Body: PETG (creep resistance; lives near electronics warmth), **rear face of
  the plate flat on the bed** — the shelf prints as a vertical wall, gussets as
  in-plane triangles (hypotenuse ≈ 33° from vertical), insert bosses rise from
  the top surface. No supports. 6 walls, 40–50 % infill (solid around the
  bosses), 0.2 mm layers.
- Pads: TPU 95A, ~10–20 % gyroid, 2 perimeters, few/no top layers.
- Bambu P1S, 0.4 mm nozzle; min feature thickness 1.6 mm. One piece — no splitting.

## Acceptance criteria

1. Defaults render watertight; prints support-free in the stated orientation.
2. `vesa_pattern=75` + `speaker_w=120` valid with no manual edits.
3. M4 bolts on the chosen VESA pattern pass through the rear-face pockets/bores
   (empty intersection); a 6 mm-misaligned pattern collides (fit test discriminates).
4. Insert pockets are blind; an over-deep pocket fails the render loudly.
5. The cabinet ghost in `demo_assembly()` clears the lip/rails by
   `cabinet_clearance` and its rear face seats against the rear heel.
