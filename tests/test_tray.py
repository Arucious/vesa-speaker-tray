"""Acceptance tests for the parametric VESA speaker tray.

Maps to the spec's acceptance criteria:
  1. defaults render watertight (no CGAL/Manifold errors)
  2. vesa_pattern=75 + speaker_w=120 stays valid with no manual edits
  4. rear cutout leaves zero lip material within rear_cutout_w
  5. insert pockets stay blind (asserted in-SCAD; verified via a failing render)
"""

import numpy as np
import pytest

from conftest import load_mesh, render, requires_openscad


@requires_openscad
def test_default_tray_watertight():
    mesh = load_mesh(part="tray")
    assert mesh.is_watertight, "default tray is not watertight"
    assert mesh.volume > 0


@requires_openscad
def test_vesa75_speaker120_valid():
    # Acceptance #2: smaller VESA + narrower speaker, no manual edits.
    mesh = load_mesh({"vesa_pattern": 75, "speaker_w": 120}, part="tray")
    assert mesh.is_watertight
    assert mesh.volume > 0


@requires_openscad
def test_through_bolt_variant_watertight():
    mesh = load_mesh({"use_inserts": False}, part="tray")
    assert mesh.is_watertight


@requires_openscad
def test_pads_render():
    mesh = load_mesh(part="pads")
    assert mesh.volume > 0


@requires_openscad
def test_assembly_renders():
    # demo_assembly includes a % ghost cube; just confirm it renders cleanly.
    proc, _ = render(part="assembly", check=False)
    assert proc.returncode == 0, proc.stderr


@requires_openscad
def test_rear_cutout_removes_lip():
    # Acceptance #4: no lip material in the rear cutout window.
    mesh = load_mesh(part="tray")
    v = mesh.vertices
    speaker_d, clearance, lip_t = 247, 0.5, 4
    inner_d = speaker_d + 2 * clearance
    inner_half = inner_d / 2                       # inner wall starts here
    in_rear_window = (
        (v[:, 1] > inner_half + 0.5)               # out in the rear lip band
        & (np.abs(v[:, 0]) < 55)                   # within rear_cutout_w/2 (120/2)
        & (v[:, 2] > 1.0)                          # above the floor top
    )
    assert not in_rear_window.any(), "lip material remains inside the rear cutout"


@requires_openscad
def test_insert_too_deep_is_rejected():
    # Acceptance #5: a pocket deeper than floor_t+boss_h must fail the assert.
    proc, _ = render({"insert_depth": 20}, part="tray", check=False)
    assert proc.returncode != 0
    assert "insert_depth" in proc.stderr or "blind" in proc.stderr.lower() \
        or "floor" in proc.stderr.lower()


@requires_openscad
def test_boss_overlap_is_rejected():
    # Oversized bosses on a 75mm pattern must trip the footprint/overlap assert.
    proc, _ = render({"vesa_pattern": 75, "boss_d": 80}, part="tray", check=False)
    assert proc.returncode != 0
