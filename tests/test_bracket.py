"""Acceptance tests for the parametric VESA speaker bracket (v2).

Maps to the spec's acceptance criteria:
  1. defaults render watertight (no CGAL/Manifold errors)
  2. vesa_pattern=75 + speaker_w=120 stays valid with no manual edits
  4. insert pockets stay blind (asserted in-SCAD; verified via a failing render)
plus envelope/lip sanity checks and the loud-failure asserts.
"""

import numpy as np
import pytest

from conftest import load_mesh, render, requires_openscad


@requires_openscad
def test_default_bracket_watertight():
    mesh = load_mesh(part="bracket")
    assert mesh.is_watertight, "default bracket is not watertight"
    assert mesh.volume > 0


@requires_openscad
def test_vesa75_speaker120_valid():
    # Acceptance #2: smaller VESA + narrower speaker, no manual edits.
    mesh = load_mesh({"vesa_pattern": 75, "speaker_w": 120}, part="bracket")
    assert mesh.is_watertight
    assert mesh.volume > 0


@requires_openscad
def test_through_fastening_watertight():
    mesh = load_mesh({"fastening": "through"}, part="bracket")
    assert mesh.is_watertight


@requires_openscad
def test_rails_and_hook_watertight():
    # Rails need a wider shelf than the 150 default (asserted in-SCAD).
    mesh = load_mesh(
        {"retention_style": "rails", "shelf_w": 162, "cable_hook": True},
        part="bracket",
    )
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
def test_bracket_envelope():
    # Whole part lives where the spec says: shelf top at z=0, lip above it,
    # plate down to -plate_h, shelf out to -shelf_d, plate rear face at y=0.
    mesh = load_mesh(part="bracket")
    (xmin, ymin, zmin), (xmax, ymax, zmax) = mesh.bounds
    assert abs(zmax - 7.0) < 0.2, f"lip top at {zmax}, expected lip_h+pad_proud=7"
    assert abs(zmin + 130.0) < 0.2, f"plate bottom at {zmin}, expected -plate_h=-130"
    assert abs(ymax) < 0.2, f"rear face at {ymax}, expected y=0"
    assert abs(ymin + 180.0) < 0.2, f"front edge at {ymin}, expected -shelf_d=-180"
    assert abs(xmax - 75.0) < 0.2 and abs(xmin + 75.0) < 0.2, "shelf width != 150"


@requires_openscad
def test_lip_retains_at_front():
    # Material above the shelf top must exist only in the lip band at the front.
    mesh = load_mesh({"retention_style": "lip"}, part="bracket")
    v = mesh.vertices
    above = v[v[:, 2] > 0.5]
    assert len(above), "no lip material above the shelf top"
    assert above[:, 1].max() < -180 + 4 + 0.1, "material above shelf top outside the lip band"


@requires_openscad
def test_insert_too_deep_is_rejected():
    # Acceptance #4: a pocket deeper than plate_t + boss_h - 1.5 must fail.
    proc, _ = render({"insert_depth": 20}, part="bracket", check=False)
    assert proc.returncode != 0
    assert "insert_depth" in proc.stderr or "blind" in proc.stderr.lower()


@requires_openscad
def test_vesa_exceeding_plate_is_rejected():
    # A 100mm pattern can't fit a 105mm-wide plate with boss walls.
    proc, _ = render({"plate_w": 105}, part="bracket", check=False)
    assert proc.returncode != 0
    assert "plate" in proc.stderr.lower()


@requires_openscad
def test_gusset_hole_collision_is_rejected():
    # 9 gussets across a 130 plate puts two of them on the VESA hole columns.
    proc, _ = render({"gusset_count": 9}, part="bracket", check=False)
    assert proc.returncode != 0
    assert "gusset" in proc.stderr.lower()
