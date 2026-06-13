"""Render helpers for the OpenSCAD test suite.

Renders ``vesa_tray.scad`` to STL via the OpenSCAD CLI and loads the result with
trimesh. BOSL2 must be on ``OPENSCADPATH`` (see OPENSCAD_SETUP.md); override the
binary with ``OPENSCAD_BIN`` and the library dir with ``OPENSCAD_LIBDIR``.
"""

from __future__ import annotations

import os
import pathlib
import shutil
import subprocess
import tempfile

import pytest
import trimesh

ROOT = pathlib.Path(__file__).resolve().parents[1]
MAIN = ROOT / "vesa_tray.scad"
FIT_FIXTURE = ROOT / "tests" / "fixtures" / "vesa_fit.scad"
OPENSCAD_BIN = os.environ.get("OPENSCAD_BIN", "openscad")

# Tests run with coarse facets for speed; geometry validity is unaffected.
_TEST_FN = 24


def _have_openscad() -> bool:
    return shutil.which(OPENSCAD_BIN) is not None or os.path.exists(OPENSCAD_BIN)


requires_openscad = pytest.mark.skipif(
    not _have_openscad(), reason="OpenSCAD not installed (set OPENSCAD_BIN)"
)


def _fmt(value) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, str):
        return f'"{value}"'
    return str(value)


def _env() -> dict:
    env = dict(os.environ)
    libdir = os.environ.get("OPENSCAD_LIBDIR")
    if libdir:
        existing = env.get("OPENSCADPATH", "")
        env["OPENSCADPATH"] = f"{libdir}:{existing}" if existing else libdir
    return env


def render(defines: dict | None = None, part: str = "bracket", *,
           scad: pathlib.Path = MAIN, check: bool = True):
    """Render a ``.scad`` to STL and return the CompletedProcess (and STL path).

    Returns ``(proc, stl_path)``. With ``check=False`` a failed render is
    returned rather than raised (used to assert that bad params are rejected).
    """
    defines = dict(defines or {})
    if scad == MAIN:
        defines.setdefault("Part", part)
    defines.setdefault("$fn", _TEST_FN)

    tmp = tempfile.NamedTemporaryFile(suffix=".stl", delete=False)
    tmp.close()
    args = [OPENSCAD_BIN, "-o", tmp.name, "--export-format=binstl"]
    for key, val in defines.items():
        args += ["-D", f"{key}={_fmt(val)}"]
    args.append(str(scad))

    proc = subprocess.run(
        args, capture_output=True, text=True, env=_env(), check=False
    )
    if check and proc.returncode != 0:
        raise AssertionError(
            f"OpenSCAD render failed (rc={proc.returncode}):\n{proc.stderr}"
        )
    return proc, tmp.name


def fit_collision_volume(defines: dict | None = None) -> float:
    """Render the VESA-fit fixture and return the bolt/material collision volume.

    The fixture intersects the tray with an M4 bolt array on a VESA pattern.
    A correct fit yields an empty object (OpenSCAD: "object is empty") -> 0.0.
    A mismatched pattern leaves a non-empty solid -> its volume in mm^3.
    """
    proc, stl = render(defines, scad=FIT_FIXTURE, check=False)
    err = proc.stderr or ""
    try:
        if "ERROR" in err:
            raise AssertionError(f"fit fixture render error:\n{err}")
        if "object is empty" in err.lower():
            return 0.0
        mesh = trimesh.load(stl, force="mesh")
        if mesh is None or len(getattr(mesh, "faces", [])) == 0:
            return 0.0
        return float(abs(mesh.volume))
    finally:
        try:
            os.unlink(stl)
        except OSError:
            pass


def load_mesh(defines: dict | None = None, part: str = "bracket") -> trimesh.Trimesh:
    _, stl = render(defines, part=part, check=True)
    mesh = trimesh.load(stl, force="mesh")
    os.unlink(stl)
    return mesh
