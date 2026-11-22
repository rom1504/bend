#!/usr/bin/env python3
"""Run all 19 focused cases from selfhost/tests/phase182/qualification-catalog.json."""
import json, subprocess, sys, tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EMIT = ROOT / "research/agy/emit_obj.mjs"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CAT = json.loads((ROOT / "selfhost/tests/phase182/qualification-catalog.json").read_text())

def main():
    api = Path(sys.argv[1])
    focused = [c for c in CAT["cases"] if c.get("suite") == "focused"]
    assert len(focused) == 19, len(focused)
    passed = 0
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        for c in focused:
            src = ROOT / c["source"]["file"]
            exp = c["expect"]
            obj = td / f"{c['name']}.o"
            exe = td / c["name"]
            r = subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api), str(src), str(obj)],
                               capture_output=True, text=True)
            if exp.get("stage") != "execute":
                if r.returncode == 0:
                    print(f"FAIL (expected reject at {exp.get('stage')}) {c['id']}")
                    sys.exit(1)
                passed += 1
                print(f"PASS {c['id']} (rejected as expected)", flush=True)
                continue
            if r.returncode != 0:
                print(f"FAIL (emit) {c['id']}: {r.stderr.strip()[:200]}")
                sys.exit(1)
            r2 = subprocess.run([CC, "-no-pie", str(obj), str(RT), "-pthread", "-lm", "-o", str(exe)],
                                capture_output=True, text=True)
            if r2.returncode != 0:
                print(f"FAIL (link) {c['id']}: {r2.stderr.strip()[:200]}")
                sys.exit(1)
            r3 = subprocess.run([str(exe)], capture_output=True, text=True)
            if r3.returncode != exp["exitCode"] or r3.stdout != exp["stdout"] or r3.stderr != exp["stderr"]:
                print(f"FAIL (run) {c['id']}: rc={r3.returncode} exp_rc={exp['exitCode']}\n  got={r3.stdout!r}\n  exp={exp['stdout']!r}")
                sys.exit(1)
            passed += 1
            print(f"PASS {c['id']}", flush=True)
    print(f"\nFOCUSED19 PASS: {passed} / {len(focused)}")

if __name__ == "__main__":
    main()
