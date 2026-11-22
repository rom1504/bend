#!/usr/bin/env python3
"""Run the 19 focused qualification cases from selfhost/tests/phase182/qualification-catalog.json."""
import json, subprocess, sys, tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EMIT = ROOT / "research/agy/emit_obj.mjs"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CAT = json.loads((ROOT / "selfhost/tests/phase182/qualification-catalog.json").read_text())


def main():
    api_path = Path(sys.argv[1])
    focused = [c for c in CAT["cases"] if c.get("suite") == "focused"]
    assert len(focused) == 19, f"Expected 19 focused cases, got {len(focused)}"
    passed = 0
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        for c in focused:
            cid = c["id"]
            src = ROOT / c["source"]["file"]
            exp = c["expect"]
            obj = td / f"{c['name']}.o"
            exe = td / c["name"]
            em = subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api_path), str(src), str(obj)], capture_output=True, text=True)
            if exp["stage"] != "execute":
                if em.returncode == 0:
                    raise AssertionError(f"FAIL {cid}: expected refusal at {exp['stage']}, but emitted cleanly")
                print(f"PASS {cid:40s} (expected refusal)")
                passed += 1
                continue
            if em.returncode != 0:
                raise RuntimeError(f"FAIL {cid}: emit failed: {em.stderr[:300]}")
            lk = subprocess.run([CC, "-no-pie", str(obj), str(RT), "-pthread", "-lm", "-o", str(exe)], capture_output=True, text=True)
            if lk.returncode != 0:
                raise RuntimeError(f"FAIL {cid}: link failed: {lk.stderr[:300]}")
            run = subprocess.run([str(exe)], capture_output=True, text=True)
            if run.returncode != exp["exitCode"] or run.stdout != exp["stdout"]:
                raise AssertionError(f"FAIL {cid}: rc={run.returncode} (exp {exp['exitCode']}), out={run.stdout!r} (exp {exp['stdout']!r})")
            print(f"PASS {cid:40s}")
            passed += 1
    print(f"\nFOCUSED19: PASS {passed}/{len(focused)}")


if __name__ == "__main__":
    main()
