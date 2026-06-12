# Parametric VESA Speaker Tray

A 3D-printable, fully parametric tray that mounts a bookshelf speaker (default
target: Edifier S880DB MK II) to a monitor-arm VESA head (100×100 / 75×75, M4).
The speaker sits in a lipped tray; the tray bolts to the arm through heat-set
inserts (or through-bolts with hex nut traps) on ribbed cylindrical bosses.

> Defaults are **placeholders** from the design spec. **Measure your cabinet with
> calipers** and update `speaker_w` / `speaker_d` (and friends) before printing.

## Layout

```
vesa_tray.scad          entry point: customizer parameters + Part selector
src/
  params.scad           pure functions: derived dims, VESA coords, pad spacing, validation
  tray.scad             tray() — floor, lip, rear cutout, bosses, inserts/nut traps, ribs, recesses
  pads.scad             tpu_pads() — separately printed TPU 95A pads (0.3mm press fit, 1mm proud)
  assembly.scad         demo_assembly() — tray + pads + translucent speaker bounding box
scripts/render.sh       render a Part to dist/*.stl
tests/                  pytest + trimesh watertightness / acceptance checks
docs/                   the design spec (source of truth)
```

## Parts

Select with the `Part` variable (OpenSCAD Customizer) or `-D Part=...`:

| Part | Material | Notes |
|---|---|---|
| `tray` | PETG / PETG-CF | print floor-down, no supports, solid/40%+ infill at the bosses |
| `pads` | TPU 95A | flexible grip pads; press into the floor recesses, stand 1mm proud |
| `assembly` | — | preview only: tray + pads + a translucent speaker box for fit-checking |

## Quick start

```sh
# 1. install BOSL2 + python deps — see OPENSCAD_SETUP.md
# 2. render
scripts/render.sh tray
scripts/render.sh pads
# 3. re-target a different speaker / VESA pattern, no code edits:
scripts/render.sh tray vesa_pattern=75 speaker_w=120 speaker_d=210
```

## Key parameters

See the full table and rationale in [`docs/vesa-speaker-tray-spec.md`](docs/vesa-speaker-tray-spec.md).
Most-used: `speaker_w`, `speaker_d`, `cabinet_clearance`, `vesa_pattern`,
`use_inserts`, `insert_d` / `insert_depth`, `boss_d` / `boss_h`, `lip_h`,
`rear_cutout_w`, `pad_count`.

## Design invariants (enforced by `assert` in `tray()`)

- VESA bosses never overlap each other or spill past the tray footprint.
- Heat-set insert pockets stay **blind** — `insert_depth < floor_t + boss_h`, so
  they never break the floor's top surface.
- `rear_cutout_w` never exceeds the inner cavity width.

These hold across `vesa_pattern` 75/100 and ±20% on speaker dimensions; an
out-of-range combination fails the render loudly instead of producing bad
geometry.

## Tests

`pytest` renders the model through the OpenSCAD CLI and checks watertightness and
the spec's acceptance criteria with trimesh. It **skips automatically** when
OpenSCAD isn't installed. See `OPENSCAD_SETUP.md`.

`test_vesa_fit.py` validates the actual mounting fit: it intersects the tray with
an M4 bolt array on a VESA pattern (via `tests/fixtures/vesa_fit.scad`) and asserts
the bolts clear the holes — for every pattern in `VESA_PATTERNS` (currently 75×75
and 100×100), in both heat-set and through-bolt modes, with a misalignment
negative control. Add a plate type by appending its spacing to `VESA_PATTERNS`.

## Printing intent

- Body: PETG or PETG-CF, floor-down, 6 walls, 40%+ infill (solid around the
  bosses). Geometry avoids overhangs > 50° in that orientation.
- Pads: TPU 95A.
- Tuned for a Bambu P1S, 0.4mm nozzle; minimum feature thickness 1.6mm.

## License

MIT — see [LICENSE](LICENSE). BOSL2 is a separate dependency (not bundled) under
its own license.
