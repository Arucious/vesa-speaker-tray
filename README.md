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
scripts/build_single_file.py  flatten src/ -> vesa_tray_generator_single.scad (MakerWorld)
tests/                  pytest + trimesh watertightness / acceptance / VESA-fit checks
docs/                   the design spec (source of truth)
```

## MakerWorld (single-file generator)

MakerWorld's Parametric Model Maker accepts only **one** `.scad` file and provides
BOSL2 itself. Develop in the multi-file `src/` layout; upload the flattened
[`vesa_tray_generator_single.scad`](vesa_tray_generator_single.scad) (regenerate
with `python scripts/build_single_file.py`). It inlines all of `src/`, keeps only
`include <BOSL2/std.scad>`, and is render-identical to the multi-file source (a
test enforces this). The "Speaker — START HERE" group (width / depth / weight) is
all most users need to touch.

**Grab the upload file from the [latest release](../../releases/latest)** instead
of building locally — each release attaches the ready-to-upload
`vesa_tray_generator_single.scad`.

## Releases & CI

Two GitHub Actions workflows ([`​.github/workflows/`](.github/workflows)):

- **`ci.yml`** — on every push and pull request: installs the pinned toolchain
  (OpenSCAD 2026.01.14 + BOSL2, see `OPENSCAD_SETUP.md`) and runs `pytest`. The
  suite also checks that `vesa_tray_generator_single.scad` is **in sync with
  `src/`** and renders identically, so the upload file can't silently go stale.
- **`release.yml`** — on a `vX.Y.Z` tag: rebuilds the single file, fails if it is
  stale, then creates a GitHub Release with `vesa_tray_generator_single.scad`
  attached as the upload artifact.

Cut a release:

```sh
# after committing any src/ change, regenerate + commit the single file first:
python scripts/build_single_file.py
git add vesa_tray_generator_single.scad && git commit -m "rebuild single file"

# then tag and push — the release (with the .scad asset) is created automatically:
git tag -a v1.1.0 -m "what changed"
git push origin v1.1.0
```

Tags are `vMAJOR.MINOR.PATCH`. If you forget to rebuild the single file, both the
CI test and the release job fail loudly rather than shipping a stale artifact.

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

## Design rationale (the physics)

Why the bracket is shaped the way it is — the reasoning behind each decision,
not just the result.

**Vertical plate, not a tray on top.** The obvious design is a tray that bolts to
an upward-facing VESA head. But a monitor arm's tilt joint can't usually rotate
the head to face the ceiling — the Secretlab MAGNUS tops out at **+70°** — so that
tray could never mount. Keeping the plate vertical uses the arm in its normal
orientation, and the tilt joint sees the same ~3.6 N·m whether the plate is
vertical or horizontal (the moment comes from the speaker's offset mass, not the
plate's angle), so nothing is lost by staying vertical.

**Plate below the shelf, not behind the cabinet.** The cabinet is rear-ported with
its I/O on the back, connectors protruding 20–40 mm. A plate *behind* the speaker
would block them or need a tall standoff (which lengthens the moment arm). Putting
the plate entirely *below* the shelf keeps the rear face in open air; cables exit
the back, drop through the rear-heel notch, and run down the arm.

**The load case.** A ~3.5 kg speaker with its mass centroid ~105 mm forward of the
plate is a cantilever: **moment ≈ 3.6 N·m** at the root. That resolves to ~18 N of
tension on the top fastener pair (trivial — heat-set M4 inserts pull out above
~1000 N) and a peak **sustained material stress of ~0.26 MPa** in the structure.

**Creep governs, not breaking.** PETG won't *fracture* here — 0.26 MPa is ~190×
below its ~50 MPa yield. The real long-term risk for any plastic under constant
load is **creep** (slow cold-flow sag), which becomes significant above roughly
**10 MPa** sustained. At 0.26 MPa we're ~40× under that, so the shelf holds its
shape for years rather than drooping. This is *why* the design leans on geometry
(deep gussets) instead of dense infill — see [Print strength](#print-strength-walls--infill).

**Gussets are the structure.** A 5 mm-thick gusset that's 123 mm deep at the root
has a huge section modulus, so it carries the cantilever moment at near-zero
stress. They're the primary anti-sag feature — the spec forbids shrinking or
omitting them. The shelf itself barely bends because the gussets support it along
nearly its full depth.

**Full-depth shelf (a deliberate trade-off).** An earlier version ran the shelf
shorter than the cabinet so the rear overhung into open air — that lowered the
moment (~2.5 N·m) and let cables drop freely. But it leaves nothing behind the
speaker to stop it tipping backward, and a strap over a 237 mm-tall cabinet is
impractical. Supporting the full depth raises the moment to ~3.6 N·m (still ~40×
under creep) and buys a **rear heel** for positive containment — a worthwhile
trade.

**Retention by capture, not friction.** A tall speaker on a smooth shelf is one
bump from the floor. The seamless rim (front lip + tall side rails + rear heel)
captures the cabinet on all sides so it's mechanically retained, not just resting
on pad friction. The strap-through-slots idea was abandoned: the slots sat *under*
the cabinet (it covered them), and no reasonable strap loops a 237 mm cabinet.

**Print orientation is part of the engineering.** Printed **plate-rear-face down**,
the gussets are in-plane triangles and the bending load runs favorably relative to
the layers — so layer adhesion (FDM's weak axis) isn't the limiting factor (and at
0.26 MPa there's still ~100× margin even across layers). The 45° rim ramps and the
rails reaching the bed keep it **support-free** in exactly this orientation.

**Walls beat infill.** For a part like this the load is carried in the solid
shell's section modulus, not the infill core, so wall count matters far more than
density. The print-setting recommendation adds walls before infill as weight rises.

**Fasteners.** Screws load mostly in shear, the top pair in light tension; a relief
counterbore around each insert keeps heat-set squeeze-out below flush so the arm's
VESA plate still seats flat. Use wave washers or nylon-patch screws against
vibration — **never liquid threadlocker on PETG** (it crazes the plastic).

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
  (hypotenuse ≈ 45° from vertical, no supports), and the rim lands flat on the
  bed. 0.2 mm layers, solid around the insert bosses (the walls handle this).
- Pads: TPU 95A, ~10–20% gyroid, 2 perimeters, few/no top layers (95A is
  firm — the slicer supplies the compliance, not the geometry).
- Tuned for a Bambu P1S, 0.4 mm nozzle; minimum feature thickness 1.6 mm.

## Print strength (walls & infill)

This is a cantilever holding a speaker, so the questions that matter are *will
it break* and *will it sag over time (creep)*. Both come down to keeping the
sustained stress well below PETG's creep threshold (~10 MPa). The good news:
the deep gussets make the stresses tiny. At the 3.5 kg default the worst-case
sustained stress is about **0.26 MPa** — ~40× below the creep threshold and
~190× below yield — so even modest settings have enormous margin.

Stress scales roughly linearly with speaker weight, so the recommendation just
steps up gently with mass. The generator echoes the matching line for the
weight you enter; the equation is in [`src/params.scad`](src/params.scad)
(`recommended_walls` / `recommended_infill_pct`):

```
walls   = clamp(2 + ceil(kg / 2), 4, 8)
infill% = clamp(5 + 5 * ceil(kg / 2), 15, 40)   // gyroid
```

| Speaker weight | Walls | Infill (gyroid) |
|---|---|---|
| ≤ 4 kg | 4 | 15% |
| 4.5–6 kg | 5 | 20% |
| 6.5–8 kg | 6 | 25% |
| 8.5–10 kg | 7 | 30% |
| 10.5–12 kg | 8 | 35% |
| > 12 kg | 8 | 40% |

These are deliberately conservative — walls matter far more than infill for a
part like this, so the table adds walls before density. **Always: PETG, printed
plate-rear-face down, gyroid infill.** Keep the bracket out of sustained heat
above ~60 °C (where PETG creep accelerates); a desk near electronics is fine.

## License

MIT — see [LICENSE](LICENSE). BOSL2 is a separate dependency (not bundled) under
its own license.
