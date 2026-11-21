#!/usr/bin/env python3
"""Permanent differential test for AGY-005a CTFE U32/Nat boundary soundness.

Requires identical stdout across:
  1. Upstream Bend CLI (bend2/main.ts)
  2. Phase 205 hosted x86 API (api-base/api.mjs)
  3. Repaired Agy unified hosted x86 API (unified/api.mjs)
on both Phase 205 runtime and Agy unified runtime.
"""
import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EMIT = ROOT / "research/agy/emit_obj.mjs"
BASE_API = ROOT / "selfhost/build/agy/api-base/api.mjs"
AGY_API = ROOT / "selfhost/build/agy/unified/api.mjs"
P205_RT = ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"

CASES = [
    (
        "nat_succ_u32max_overflow",
        """import Base

def boundary() -> Bool:
  Nat.is_eq(Succ{U32.to_nat(4294967295)}, 0n)

def main() -> IO(Unit):
  IO.print(Bool.show(boundary()))
""",
        "False\n",
    ),
    (
        "nat_succ_u32max_adjacent_representable",
        """import Base

def adj_eq() -> Bool:
  Nat.is_eq(Succ{U32.to_nat(4294967294)}, U32.to_nat(4294967295))

def adj_ne() -> Bool:
  Nat.is_eq(Succ{U32.to_nat(4294967294)}, 0n)

def main() -> IO(Unit):
  IO.print(String.append(Bool.show(adj_eq()), String.append(",", Bool.show(adj_ne()))))
""",
        "True,False\n",
    ),
    (
        "nat_nested_succ_overflow_and_representable",
        """import Base

def nested_over_0() -> Bool:
  Nat.is_eq(Succ{Succ{U32.to_nat(4294967294)}}, 0n)

def nested_over_1() -> Bool:
  Nat.is_eq(Succ{Succ{U32.to_nat(4294967295)}}, 1n)

def nested_repr() -> Bool:
  Nat.is_eq(Succ{Succ{U32.to_nat(4294967293)}}, U32.to_nat(4294967295))

def main() -> IO(Unit):
  IO.print(String.append(Bool.show(nested_over_0()), String.append(",", String.append(Bool.show(nested_over_1()), String.append(",", Bool.show(nested_repr()))))))
""",
        "False,False,True\n",
    ),
    (
        "nat_return_reify_overflow",
        """import Base

def big() -> Nat:
  Succ{U32.to_nat(4294967295)}

def main() -> IO(Unit):
  IO.print(Bool.show(Nat.is_eq(big(), 0n)))
""",
        "False\n",
    ),
]


def sha256_file(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def run_upstream(src: Path) -> str:
    r = subprocess.run([str(BUN), str(ROOT / "bend2/main.ts"), str(src)],
                       capture_output=True, text=True, check=True)
    return r.stdout


def run_x86(api: Path, src: Path, tmp: Path, tag: str) -> dict:
    obj = tmp / f"{tag}.o"
    subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api), str(src), str(obj)],
                   capture_output=True, text=True, check=True)
    res = {"objSha256": sha256_file(obj), "objBytes": obj.stat().st_size}
    for rt_name, rt_path in [("p205_rt", P205_RT), ("agy_rt", AGY_RT)]:
        exe = tmp / f"{tag}.{rt_name}"
        subprocess.run([CC, "-no-pie", str(obj), str(rt_path), "-pthread", "-lm", "-o", str(exe)],
                       capture_output=True, text=True, check=True)
        r = subprocess.run([str(exe)], capture_output=True, text=True, check=True)
        assert r.stderr == "", (tag, rt_name, r.stderr)
        res[rt_name] = r.stdout
    return res


def main():
    report = {"kind": "agy-ctfe-nat-boundary-v1", "cases": {}, "allPassed": False}
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        for name, code, expected in CASES:
            src = tmp / f"{name}.bend"
            src.write_text(code)
            up = run_upstream(src)
            p205 = run_x86(BASE_API, src, tmp, f"{name}.p205")
            agy = run_x86(AGY_API, src, tmp, f"{name}.agy")
            ok = (
                up == expected
                and p205["p205_rt"] == expected
                and p205["agy_rt"] == expected
                and agy["p205_rt"] == expected
                and agy["agy_rt"] == expected
            )
            report["cases"][name] = {
                "expected": expected,
                "upstream": up,
                "p205": p205,
                "agy": agy,
                "passed": ok,
            }
            print(f"{name:44s} up={up.strip()!r} p205={p205['p205_rt'].strip()!r} agy={agy['agy_rt'].strip()!r} PASS={ok}", flush=True)
            assert ok, f"Mismatch on {name}: {report['cases'][name]}"
    report["allPassed"] = True
    if len(sys.argv) > 1:
        Path(sys.argv[1]).write_text(json.dumps(report, indent=2) + "\n")
    print("\nALL 4 CTFE U32/Nat BOUNDARY DIFFERENTIAL TESTS PASSED (upstream == Phase205 == Agy)!")


if __name__ == "__main__":
    main()
