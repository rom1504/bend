#!/usr/bin/env python3
"""Run the 19 focused qualification cases on a candidate api.mjs + runtime.o."""
import json, subprocess, sys, tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EMIT = ROOT / "research/agy/emit_obj.mjs"
CAT = json.loads((ROOT / "selfhost/tests/phase182/qualification-catalog.json").read_text())

api_path = Path(sys.argv[1])
rt_path = Path(sys.argv[2])
cases = [c for c in CAT["cases"] if c["suite"] == "focused"]
assert len(cases) == 19, f"expected 19 focused cases, got {len(cases)}"

passed = 0
failed = []
with tempfile.TemporaryDirectory(prefix="w2_f19_") as td:
    td = Path(td)
    for c in cases:
        cid = c["id"]
        src = ROOT / c["source"]["file"]
        stage = c["expect"]["stage"]
        obj = td / f"{c['name']}.o"
        exe = td / f"{c['name']}"
        try:
            r_emit = subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api_path), str(src), str(obj)],
                                    capture_output=True, text=True)
            if stage != "execute":
                if r_emit.returncode != 0 and not obj.exists():
                    passed += 1
                    print(f"PASS {cid} ({stage} rejected)")
                else:
                    failed.append((cid, f"expected rejection for {stage}, got rc={r_emit.returncode}"))
                    print(f"FAIL {cid}: {failed[-1][1]}")
                continue
            if r_emit.returncode != 0:
                raise RuntimeError(f"emit failed: {r_emit.stderr.strip()}")
            exp_out = c["expect"]["stdout"]
            exp_code = c["expect"]["exitCode"]
            subprocess.run([CC, "-no-pie", str(obj), str(rt_path), "-pthread", "-lm", "-o", str(exe)],
                           capture_output=True, text=True, check=True)
            r = subprocess.run([str(exe)], capture_output=True, text=True, timeout=30)
            if r.returncode == exp_code and r.stdout == exp_out:
                passed += 1
                print(f"PASS {cid}")
            else:
                failed.append((cid, f"rc={r.returncode} (exp {exp_code}), out={r.stdout!r} (exp {exp_out!r})"))
                print(f"FAIL {cid}: {failed[-1][1]}")
        except Exception as e:
            failed.append((cid, str(e)))
            print(f"ERROR {cid}: {e}")

print(f"\nfocused19: {passed}/{len(cases)} passed")
if failed:
    sys.exit(1)
