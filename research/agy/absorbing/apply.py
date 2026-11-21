#!/usr/bin/env python3
"""Apply AGY-005b general absorbing-state early-exit pass to a compiler.bend source."""
import sys
from pathlib import Path

root = Path("/home/ai/bend2_agy")
src = Path(sys.argv[1]).read_text()
out = Path(sys.argv[2])
pass_src = (root / "research/agy/absorbing/absorbing.bend").read_text()

anchor = "@unsafe\ndef p86_plan_annotated("
assert src.count(anchor) == 1, f"anchor count={src.count(anchor)}"
old_call = "u => p205_ready(context,stops,verdict,annotated,p205u_decls(context,annotated,missing(),False{}))"
assert src.count(old_call) == 1, f"old_call count={src.count(old_call)}"
new_call = "u => agy_abs_plan(context,stops,verdict,annotated)"

patched = src.replace(old_call, new_call, 1).replace(anchor, pass_src + "\n\n" + anchor, 1)
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(patched)
print(f"Wrote {out} ({len(patched)} bytes)")
