"""The flattened single-file build (for MakerWorld) must stay in sync with src/.

MakerWorld's Parametric Model Maker only accepts ONE .scad file, so
`vesa_tray_generator_single.scad` is the upload artifact. These tests fail if it
drifts from the multi-file source (regenerate with scripts/build_single_file.py).
"""
import importlib.util
import pathlib

import trimesh

from conftest import ROOT, render, requires_openscad

SINGLE = ROOT / "vesa_tray_generator_single.scad"

_spec = importlib.util.spec_from_file_location(
    "build_single_file", ROOT / "scripts" / "build_single_file.py")
_build = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_build)


def test_single_file_up_to_date():
    # Committed upload artifact must equal a fresh build (no OpenSCAD needed).
    assert SINGLE.exists(), "run scripts/build_single_file.py"
    assert SINGLE.read_text() == _build.build(), (
        "vesa_tray_generator_single.scad is stale — run scripts/build_single_file.py"
    )


def test_single_file_has_no_local_includes():
    # Only BOSL2 may be included; local use/include must be inlined away.
    for line in SINGLE.read_text().splitlines():
        s = line.strip()
        if s.startswith(("use <", "include <")):
            assert "BOSL2/" in s, f"local dependency leaked into single file: {line}"


@requires_openscad
def test_single_file_renders_like_multifile():
    # The flattened file must produce the same bracket as the multi-file source.
    _, a = render(part="bracket")
    _, b = render(part="bracket", scad=SINGLE)
    va = trimesh.load(a, force="mesh")
    vb = trimesh.load(b, force="mesh")
    assert vb.is_watertight
    assert abs(va.volume - vb.volume) < 1.0, (va.volume, vb.volume)
