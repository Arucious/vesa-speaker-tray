#!/usr/bin/env python3
"""Flatten the multi-file generator into ONE self-contained .scad for MakerWorld.

MakerWorld's Parametric Model Maker does NOT accept dependency .scad uploads — only a
single .scad that uses pre-installed libraries (BOSL2 is provided by the platform).
This concatenates our files, strips all LOCAL use/include lines (their content is
inlined), and keeps only `include <BOSL2/...>`.

OpenSCAD hoists module/function definitions, but evaluates top-level VARIABLE
assignments in textual order. So we emit, in order:
  1. the customizer parameters (literals only — MakerWorld reads these at the top for its UI),
     which already carry the single `include <BOSL2/std.scad>`
  2. ALL definitions (our params/bracket/pads/assembly functions + modules)
  3. the derived `_` vars + echo + the part-switch geometry (the entry file's `[Hidden]` tail)

Output: vesa_tray_generator_single.scad at the repo root (upload THIS to MakerWorld).
"""
import re, pathlib

REPO = pathlib.Path(__file__).resolve().parent.parent
SRC = REPO / "src"

MAIN = REPO / "vesa_tray.scad"
LIBS = ["params.scad", "bracket.scad", "pads.scad", "assembly.scad"]

LOCAL_INC = re.compile(r'^\s*(use|include)\s*<(?!BOSL2/)[^>]+>\s*;?\s*(//.*)?$')   # drop (inlined)
BOSL_INC = re.compile(r'^\s*include\s*<(BOSL2/[^>]+)>')
seen_bosl = set()


DEST = REPO / "vesa_tray_generator_single.scad"


def build():
    """Return the flattened single-file .scad as a string (no disk write)."""
    seen_bosl = set()

    def clean(lines):
        out = []
        for line in lines:
            if LOCAL_INC.match(line):
                continue
            m = BOSL_INC.match(line)
            if m:
                if m.group(1) in seen_bosl:
                    continue
                seen_bosl.add(m.group(1))
            out.append(line)
        return out

    # split the entry file at `[Hidden]`: params (top) vs derived+geometry (bottom)
    main_lines = MAIN.read_text().splitlines()
    split = next(i for i, l in enumerate(main_lines) if "[Hidden]" in l)
    main_head = clean(main_lines[:split])     # BOSL2 include, customizer params
    main_tail = clean(main_lines[split:])     # $fn, derived _vars, echo, geometry

    parts = ["// AUTO-GENERATED single-file build (scripts/build_single_file.py).",
             "// Upload THIS file to MakerWorld's Parametric Model Maker. BOSL2 is provided by",
             "// the platform; everything else is inlined below. Edit sources in src/ and re-run.",
             "\n// ===================== customizer parameters (entry) ====================="]
    parts += main_head
    for name in LIBS:
        parts.append(f"\n// ===================== src/{name} =====================")
        parts += clean((SRC / name).read_text().splitlines())
    parts.append("\n// ===================== derived values + geometry (entry) =====================")
    parts += main_tail
    return "\n".join(parts) + "\n"


if __name__ == "__main__":
    DEST.write_text(build())
    print("wrote", DEST)
