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


def render(defines: dict | None = None, part: str = "tray", *, check: bool = True):
    """Render a part to STL and return the CompletedProcess (and STL path).

    Returns ``(proc, stl_path)``. With ``check=False`` a failed render is
    returned rather than raised (used to assert that bad params are rejected).
    """
    defines = dict(defines or {})
    defines.setdefault("Part", part)
    defines.setdefault("$fn", _TEST_FN)

    tmp = tempfile.NamedTemporaryFile(suffix=".stl", delete=False)
    tmp.close()
    args = [OPENSCAD_BIN, "-o", tmp.name, "--export-format=binstl"]
    for key, val in defines.items():
        args += ["-D", f"{key}={_fmt(val)}"]
    args.append(str(MAIN))

    proc = subprocess.run(
        args, capture_output=True, text=True, env=_env(), check=False
    )
    if check and proc.returncode != 0:
        raise AssertionError(
            f"OpenSCAD render failed (rc={proc.returncode}):\n{proc.stderr}"
        )
    return proc, tmp.name


def load_mesh(defines: dict | None = None, part: str = "tray") -> trimesh.Trimesh:
    _, stl = render(defines, part=part, check=True)
    mesh = trimesh.load(stl, force="mesh")
    os.unlink(stl)
    return mesh
