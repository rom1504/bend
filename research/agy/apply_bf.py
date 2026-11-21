#!/usr/bin/env python3
"""Apply AGY-001 binary-fork linearization pass to a compiler.bend source."""
import sys
from pathlib import Path

root = Path("/home/ai/bend2_agy")
src = Path(sys.argv[1]).read_text()
out = Path(sys.argv[2])
bf = (root / "research/agy/bf_linearize.bend").read_text()

anchor = "@unsafe\ndef p86_plan_annotated("
assert src.count(anchor) == 1
old_call = "u => p205_ready(context,stops,verdict,annotated,p205u_decls(context,annotated,missing(),False{}))"
assert src.count(old_call) == 1
new_call = "u => agy_bf_plan(context,stops,verdict,annotated)"

patched = src.replace(old_call, new_call, 1).replace(anchor, bf + "\n\n" + anchor, 1)
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(patched)
print(f"Wrote {out} ({len(patched)} bytes)")
