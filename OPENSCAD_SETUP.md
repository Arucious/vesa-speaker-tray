# OpenSCAD / toolchain setup (pinned for MakerWorld parity)

This project targets MakerWorld's Parametric Model Maker, so the toolchain is
pinned to match its renderer (same pins as `cable-clamp-generator`).

## OpenSCAD
- **Version: 2026.01.14 snapshot** — exactly matches MakerWorld's Parametric
  Model Maker renderer.
  - macOS: `https://files.openscad.org/snapshots/OpenSCAD-2026.01.14.dmg`
    (mount with `hdiutil`, copy to `/Applications`, clear quarantine with
    `xattr -dr com.apple.quarantine`). Binary:
    `/Applications/OpenSCAD-2026.01.14.app/Contents/MacOS/OpenSCAD`
  - Linux: `https://files.openscad.org/snapshots/OpenSCAD-2026.01.14-x86_64.AppImage`
    (this is what CI uses — see `.github/workflows/ci.yml`).
- Do **not** use the 2021.01 stable release: besides being five years behind the
  MakerWorld renderer, its special-variable scoping silently tolerates a BOSL2
  include pattern that the 2026 renderer rejects (and the old macOS build is
  flagged by Gatekeeper).
- Override the binary the test harness/scripts call with `OPENSCAD_BIN`
  (default: `openscad` on `PATH`).

## BOSL2 (required — NOT bundled; MakerWorld provides BOSL2)
- The geometry uses [BOSL2](https://github.com/BelfrySCAD/BOSL2) for rounded
  prisms and anchored primitives (`include <BOSL2/std.scad>`).
- **Pinned commit: `7e5dfe5275b23f1b568962e2e286f0630c0c9b57`** (2026-01-18,
  contemporary with the pinned OpenSCAD build).
- Install it into your OpenSCAD user library dir so `include <BOSL2/std.scad>`
  resolves:
  - Linux: `~/.local/share/OpenSCAD/libraries/BOSL2`
  - macOS: `~/Documents/OpenSCAD/libraries/BOSL2`
  - or any dir, then put its parent on `OPENSCADPATH`.
- The test harness adds `OPENSCAD_LIBDIR` (if set) to `OPENSCADPATH`, e.g.
  `OPENSCAD_LIBDIR=$PWD/.libs` with BOSL2 cloned to `.libs/BOSL2`.

```sh
# one-time local setup (macOS path shown)
LIB="${HOME}/Documents/OpenSCAD/libraries/BOSL2"
mkdir -p "$LIB" && git -C "$LIB" init -q
git -C "$LIB" fetch -q --depth 1 https://github.com/BelfrySCAD/BOSL2 \
    7e5dfe5275b23f1b568962e2e286f0630c0c9b57
git -C "$LIB" checkout -q FETCH_HEAD
```

## Entry-point include rule (renderer-version sensitive)
BOSL2 sets special-variable defaults (`$tags_shown`, …) at the top level of
`std.scad`, and special variables resolve through the **caller's** dynamic
scope. Any file rendered directly (`vesa_tray.scad`, test fixtures) must
therefore `include <BOSL2/std.scad>` itself — having it only inside a `use`d
file breaks on OpenSCAD ≥ 2026 (`Assertion '$tags_shown...' failed`).

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
