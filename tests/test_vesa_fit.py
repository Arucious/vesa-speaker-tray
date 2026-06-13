"""Parametric VESA mounting-fit validation.

Confirms that an M4 bolt array on a given VESA square pattern actually mates
with the bracket's rear-face mounting holes (bolts clear the hole voids), and
that the check discriminates (a wrong pattern collides with plate material).
Add a pattern to ``VESA_PATTERNS`` to validate another plate type.
"""

import pytest

from conftest import fit_collision_volume, requires_openscad

# Standard square VESA plate types the design supports. Extend as needed.
VESA_PATTERNS = [75, 100]

# A clean fit may leave tiny numerical slivers; require it to be negligible.
FIT_EPS_MM3 = 20.0
# A 6mm misalignment must drive the bolts well into plate material. The bolts
# sit ~9mm deep in solid plate: ~110 mm^3 at Ø4, so 80 keeps margin.
MISS_MIN_MM3 = 80.0


@requires_openscad
@pytest.mark.parametrize("pattern", VESA_PATTERNS)
def test_vesa_plate_bolts_fit(pattern):
    # Bolts on the matching pattern sit in the pocket voids -> empty intersection.
    vol = fit_collision_volume({"fit_pattern": pattern})
    assert vol <= FIT_EPS_MM3, (
        f"M4 bolts on a {pattern}x{pattern} VESA plate collide with the bracket "
        f"({vol:.1f} mm^3 of material in the bolt path)"
    )


@requires_openscad
@pytest.mark.parametrize("pattern", VESA_PATTERNS)
def test_vesa_plate_through_bolt_fit(pattern):
    # Same check in through-bolt mode (no heat-set inserts).
    vol = fit_collision_volume({"fit_pattern": pattern, "fit_fastening": "through"})
    assert vol <= FIT_EPS_MM3, (
        f"M4 through-bolts on a {pattern}x{pattern} plate collide ({vol:.1f} mm^3)"
    )


@requires_openscad
@pytest.mark.parametrize("pattern", VESA_PATTERNS)
def test_misaligned_pattern_is_detected(pattern):
    # Negative control: a 6mm-off pattern must NOT fit (proves the test works).
    vol = fit_collision_volume({"fit_pattern": pattern, "fit_offset_x": 6})
    assert vol >= MISS_MIN_MM3, (
        f"misaligned {pattern}x{pattern} pattern was not detected as a collision "
        f"(only {vol:.1f} mm^3) — the fit check is not discriminating"
    )
