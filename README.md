# Parametric VESA Speaker Bracket

A 3D-printable, fully parametric bracket that mounts a bookshelf speaker
(default target: Edifier S880DB MK2) to a monitor-arm VESA head (100×100 /
75×75, M4) kept in its normal, vertical orientation. A vertical VESA plate
sits below a cantilevered shelf braced by triangular gussets; the speaker
rests on TPU pads behind a front retention lip (plus an optional strap or
side rails). The speaker's rear face — bass-reflex port and all I/O — stays
fully unobstructed.

> **Why v2?** v1 was a tray bolting to an upward-facing VESA head. Most arms
> can't tilt that far — the Secretlab MAGNUS tops out at +70° — so v1 could
> never mount. v2 keeps the arm head vertical. See the
> [design spec](docs/vesa-speaker-tray-spec.md) for the full rationale.

> Speaker defaults are the S880DB MK2 manufacturer specs (145×237×207 mm).
> **Verify against your cabinet with calipers** before printing.

## Layout

```
vesa_tray.scad          entry point: customizer parameters + Part selector
src/
  params.scad           pure functions: derived dims, VESA coords, pad spacing, validation
  bracket.scad          bracket() — plate, shelf, gussets, lip, fastening, retention
  pads.scad             tpu_pads() — separately printed TPU 95A pads (0.3mm press fit, 1mm proud)
  assembly.scad         demo_assembly() — bracket + pads + translucent speaker bounding box
scripts/render.sh       render a Part to dist/*.stl
tests/                  pytest + trimesh watertightness / acceptance / VESA-fit checks
docs/                   the design spec (source of truth)
```

## Parts

Select with the `Part` variable (OpenSCAD Customizer) or `-D Part=...`:

| Part | Material | Notes |
|---|---|---|
| `bracket` | PETG | print with the plate's REAR face on the bed, no supports, solid/40%+ infill at the bosses |
| `pads` | TPU 95A | flexible grip pads; press into the shelf recesses, stand 1mm proud |
| `assembly` | — | preview only: bracket + pads + a translucent speaker box for fit-checking |

## Quick start

```sh
# 1. install OpenSCAD + BOSL2 (pinned versions) — see OPENSCAD_SETUP.md
# 2. render
scripts/render.sh bracket
scripts/render.sh pads
# 3. re-target a different speaker / VESA pattern, no code edits:
scripts/render.sh bracket vesa_pattern=75 speaker_w=120 speaker_d=190
```

## Key parameters

See the full table and rationale in [`docs/vesa-speaker-tray-spec.md`](docs/vesa-speaker-tray-spec.md).
Most-used: `speaker_w` / `speaker_d`, `shelf_w` / `shelf_d`, `vesa_pattern`,
`vesa_drop` (raise it if your arm head is tall), `fastening`
(`insert`/`through`), `retention_style` (`lip`/`strap`/`rails`), `lip_h`,
`pad_recess_depth`, `gusset_count`, `cable_hook`.

## Hardware

- 4× M4×10–12 machine screws (the arm's stock VESA screws) with **wave/spring
  washers, or nylon-patch screws** — it's a speaker; plain screws walk loose.
  **No liquid threadlocker** on PETG (it crazes).
- `fastening="insert"`: 4× Ruthex RX-M4 heat-set inserts, melted into the
  Ø5.6 mm rear-face pockets (Ø5.6 is the Ruthex datasheet bore — don't drill
  them out to "M4 size").
- `fastening="through"`: 4× DIN 934 M4 hex nuts seat in the front-face traps.

## Design invariants (enforced by `assert` in `bracket()`)

- VESA holes (including boss/bore walls) stay inside the plate — clear of the
  edges, the shelf junction fillet, and the bottom rounding.
- Gussets never cross a VESA hole column.
- Heat-set pockets stay **blind**: `insert_depth ≤ plate_t + insert_boss_h − 1.5`.
- Effective lip (above the pad top) ≥ 3 mm; side rails must fit the shelf.

These hold across `vesa_pattern` 75/100 and ±20% on speaker dimensions; an
out-of-range combination fails the render loudly instead of producing bad
geometry.

## Tests

`pytest` renders the model through the OpenSCAD CLI and checks watertightness
and the spec's acceptance criteria with trimesh. It **skips automatically**
when OpenSCAD isn't installed. See `OPENSCAD_SETUP.md` for the pinned
toolchain (MakerWorld parity).

`test_vesa_fit.py` validates the actual mounting fit: it intersects the
bracket with an M4 bolt array entering the plate's rear face on a VESA pattern
(via `tests/fixtures/vesa_fit.scad`) and asserts the bolts clear the pockets —
for every pattern in `VESA_PATTERNS` (currently 75×75 and 100×100), in both
heat-set and through-bolt modes, with a misalignment negative control. Add a
plate type by appending its spacing to `VESA_PATTERNS`.

## Printing intent

- Body: PETG (creep resistance), **plate rear face down on the bed** — the
  shelf prints as a vertical wall and the gussets as in-plane triangles
  (hypotenuse ≈ 33° from vertical, no supports). 6 walls, 40–50% infill,
  solid around the insert bosses, 0.2 mm layers.
- Pads: TPU 95A, ~10–20% gyroid, 2 perimeters, few/no top layers (95A is
  firm — the slicer supplies the compliance, not the geometry).
- Tuned for a Bambu P1S, 0.4 mm nozzle; minimum feature thickness 1.6 mm.

## License

MIT — see [LICENSE](LICENSE). BOSL2 is a separate dependency (not bundled) under
its own license.
