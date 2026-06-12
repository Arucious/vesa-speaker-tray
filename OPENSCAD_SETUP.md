# OpenSCAD / toolchain setup

## OpenSCAD
- A recent OpenSCAD with the **Manifold** backend is recommended (2023+ snapshot or
  2026.x). The design uses only standard CSG + BOSL2 helpers, so it also renders on
  the CGAL backend.
- Override the binary the test harness/scripts call with `OPENSCAD_BIN`
  (default: `openscad` on `PATH`).

## BOSL2 (required — not bundled)
- The geometry uses [BOSL2](https://github.com/BelfrySCAD/BOSL2) for rounded prisms
  and anchored primitives (`include <BOSL2/std.scad>`).
- Install it into your OpenSCAD user library dir so `include <BOSL2/std.scad>`
  resolves:
  - Linux: `~/.local/share/OpenSCAD/libraries/BOSL2`
  - macOS: `~/Documents/OpenSCAD/libraries/BOSL2`
  - or any dir, then put its parent on `OPENSCADPATH`.
- The test harness adds `OPENSCAD_LIBDIR` (if set) to `OPENSCADPATH`, e.g.
  `OPENSCAD_LIBDIR=$PWD/.libs` with BOSL2 cloned to `.libs/BOSL2`.

```sh
# one-time local setup
git clone --depth 1 https://github.com/BelfrySCAD/BOSL2 \
    "${HOME}/.local/share/OpenSCAD/libraries/BOSL2"
```

## Python (tests)
- Python 3.12+. Dev deps in `tests/requirements-dev.txt`: trimesh, numpy, pytest.

```sh
python -m venv .venv && . .venv/bin/activate
pip install -r tests/requirements-dev.txt
pytest          # skips automatically if OpenSCAD is not installed
```

## Rendering / export
```sh
scripts/render.sh tray                       # dist/vesa_tray-tray.stl
scripts/render.sh pads                       # dist/vesa_tray-pads.stl
scripts/render.sh tray vesa_pattern=75 speaker_w=120
```
Or open `vesa_tray.scad` in the OpenSCAD GUI and use the Customizer panel; pick the
part with the `Part` variable (`tray` / `pads` / `assembly`).
