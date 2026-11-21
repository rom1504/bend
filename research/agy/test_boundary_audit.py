#!/usr/bin/env python3
"""Expanded differential boundary & adverse-perf audit across upstream Bend, Phase 205, and Agy.

Covers:
  - CTFE Nat boundaries (add/mul overflow, sub underflow, div/mod 0, U32.from_nat overflow, match default)
  - CTFE U32 boundaries (wraparound, div/mod 0, shln/shrn at 0, 31, 32, 33, 100000)
  - CTFE F32 boundaries (F32.to_u32 on 0, 42.9, -1.0, +Inf, NaN, >=2^32; -0.0 vs +0.0; NaN eq)
  - CTFE String/Char boundaries (empty, Unicode, >256-char decline)
  - AGY-001 binary-fork boundary (d=0, 1, 5, U32 wraparound x & STEP)
  - CTFE adverse compile-time fuel-exhaustion guardrail
"""
import json
import subprocess
import sys
import tempfile
import time
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
        "nat_arith_boundaries",
        """import Base

def add_over_eq0() -> Bool:
  Nat.is_eq(Nat.add(U32.to_nat(4294967295), 1n), 0n)

def add_over_eqs() -> Bool:
  Nat.is_eq(Nat.add(U32.to_nat(4294967295), 1n), Succ{U32.to_nat(4294967295)})

def mul_over_eq0() -> Bool:
  Nat.is_eq(Nat.mul(U32.to_nat(65536), U32.to_nat(65536)), 0n)

def sub_under() -> Nat:
  Nat.sub(3n, 10n)

def from_nat_over() -> U32:
  U32.from_nat(Succ{U32.to_nat(4294967295)})

def nat_match_def_go(n: Nat) -> U32:
  match n:
    case 0n: 99
    case x: U32.from_nat(x)

def nat_match_def() -> U32:
  nat_match_def_go(5n)

def main() -> IO(Unit):
  IO.print(Bool.show(add_over_eq0()) ++ "," ++ Bool.show(add_over_eqs()) ++ "," ++ Bool.show(mul_over_eq0()) ++ "," ++ U32.show(U32.from_nat(sub_under())) ++ "," ++ U32.show(from_nat_over()) ++ "," ++ U32.show(nat_match_def()))
""",
    ),
    (
        "nat_div_mod_zero",
        """import Base

def d0() -> Nat:
  Nat.div(7n, 0n)

def m0() -> Nat:
  Nat.mod(7n, 0n)

def main() -> IO(Unit):
  IO.print(U32.show(U32.from_nat(d0())) ++ "," ++ U32.show(U32.from_nat(m0())))
""",
    ),
    (
        "u32_wrap_and_div0",
        """import Base

def w_inc() -> U32:
  U32.inc(4294967295)

def w_add() -> U32:
  U32.add(4294967295, 2)

def w_sub() -> U32:
  U32.sub(0, 1)

def w_mul() -> U32:
  U32.mul(65536, 65536)

def w_div0() -> U32:
  U32.div(7, 0)

def w_mod0() -> U32:
  U32.mod(7, 0)

def main() -> IO(Unit):
  IO.print(U32.show(w_inc()) ++ "," ++ U32.show(w_add()) ++ "," ++ U32.show(w_sub()) ++ "," ++ U32.show(w_mul()) ++ "," ++ U32.show(w_div0()) ++ "," ++ U32.show(w_mod0()))
""",
    ),
    (
        "u32_shift_boundaries",
        """import Base

def s0() -> U32:
  U32.shln(1, 0n)

def s31() -> U32:
  U32.shln(1, 31n)

def s32() -> U32:
  U32.shln(1, 32n)

def s33() -> U32:
  U32.shln(1, 33n)

def r31() -> U32:
  U32.shrn(2147483648, 31n)

def r32() -> U32:
  U32.shrn(2147483648, 32n)

def sbig() -> U32:
  U32.shln(1, U32.to_nat(100000))

def main() -> IO(Unit):
  IO.print(U32.show(s0()) ++ "," ++ U32.show(s31()) ++ "," ++ U32.show(s32()) ++ "," ++ U32.show(s33()) ++ "," ++ U32.show(r31()) ++ "," ++ U32.show(r32()) ++ "," ++ U32.show(sbig()))
""",
    ),
    (
        "f32_to_u32_edges",
        """import Base

def f_zero() -> U32:
  F32.to_u32(0.0)

def f_pos() -> U32:
  F32.to_u32(42.9)

def f_neg() -> U32:
  F32.to_u32(F32.neg(1.0))

def f_inf() -> U32:
  F32.to_u32(F32.div(1.0, 0.0))

def f_nan() -> U32:
  F32.to_u32(F32.div(0.0, 0.0))

def f_big() -> U32:
  F32.to_u32(F32.mul(65536.0, 65536.0))

def main() -> IO(Unit):
  IO.print(U32.show(f_zero()) ++ "," ++ U32.show(f_pos()) ++ "," ++ U32.show(f_neg()) ++ "," ++ U32.show(f_inf()) ++ "," ++ U32.show(f_nan()) ++ "," ++ U32.show(f_big()))
""",
    ),
    (
        "f32_zero_nan_bits",
        """import Base

def neg_zero_bits() -> U32:
  F32.bits(F32.neg(0.0))

def neg_zero_eq() -> Bool:
  F32.is_eq(0.0, F32.neg(0.0))

def nan_eq() -> Bool:
  F32.is_eq(F32.div(0.0, 0.0), F32.div(0.0, 0.0))

def nan_ne() -> Bool:
  F32.is_ne(F32.div(0.0, 0.0), F32.div(0.0, 0.0))

def main() -> IO(Unit):
  IO.print(U32.show(neg_zero_bits()) ++ "," ++ Bool.show(neg_zero_eq()) ++ "," ++ Bool.show(nan_eq()) ++ "," ++ Bool.show(nan_ne()))
""",
    ),
    (
        "string_unicode_and_long",
        """import Base

def rep_str(n: Nat, +s: String) -> String:
  match n:
    case 0n: ""
    case 1n+p: String.append(s, rep_str(p, s))

def empty_s() -> String:
  rep_str(0n, "x")

def uni_s() -> String:
  String.append("h\\u{00e9}", "llo")

def long_s() -> String:
  rep_str(30n, "0123456789")

def main() -> IO(Unit):
  IO.print(U32.show(U32.from_nat(String.length(empty_s()))) ++ "," ++ uni_s() ++ "," ++ U32.show(U32.from_nat(String.length(long_s()))))
""",
    ),
    (
        "bf_linearize_wrap_boundary",
        """import Base

def bf_sum(+d: Nat, +x: U32, +k: U32) -> U32:
  match d:
    case 0n: U32.mul(x, k)
    case 1n+p:
      a = bf_sum(p, x, k)
      b = bf_sum(p, U32.add(x, U32.shln(17, p)), k)
      U32.add(a, b)

def main() -> IO(Unit):
  IO.print(U32.show(bf_sum(0n, 4294967290, 3)) ++ "," ++ U32.show(bf_sum(1n, 4294967290, 3)) ++ "," ++ U32.show(bf_sum(5n, 4294967290, 3)))
""",
    ),
    (
        "ctfe_adverse_fuel_exhaust",
        """import Base

def burn(n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: burn(p, U32.add(acc, 1))

def big_burn() -> U32:
  burn(U32.to_nat(300000), 0)

def main() -> IO(Unit):
  IO.print(U32.show(big_burn()))
""",
    ),
]


def run_upstream(src: Path) -> str:
    r = subprocess.run([str(BUN), str(ROOT / "bend2/main.ts"), str(src)],
                       capture_output=True, text=True, timeout=30)
    if r.returncode != 0:
        return f"ERR({r.returncode}): {r.stderr.strip()[:200]}"
    return r.stdout


def run_x86(api: Path, rt: Path, src: Path, tmp: Path, tag: str) -> tuple:
    obj = tmp / f"{tag}.o"
    exe = tmp / f"{tag}"
    t0 = time.perf_counter()
    r_emit = subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api), str(src), str(obj)],
                            capture_output=True, text=True, timeout=60)
    dt_emit = time.perf_counter() - t0
    if r_emit.returncode != 0:
        return (f"EMIT_ERR({r_emit.returncode}): {r_emit.stderr.strip()[:200]}", dt_emit)
    subprocess.run([CC, "-no-pie", str(obj), str(rt), "-pthread", "-lm", "-o", str(exe)],
                   capture_output=True, text=True, check=True)
    r = subprocess.run([str(exe)], capture_output=True, text=True, timeout=30)
    if r.returncode != 0:
        return (f"RUN_ERR({r.returncode}): {r.stderr.strip()[:200]}", dt_emit)
    return (r.stdout, dt_emit)


def main():
    report = {"kind": "agy-boundary-audit-v1", "cases": {}, "mismatches": []}
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        for name, code in CASES:
            src = tmp / f"{name}.bend"
            src.write_text(code)
            up = run_upstream(src)
            p205_out, p205_dt = run_x86(BASE_API, P205_RT, src, tmp, f"{name}.p205")
            agy_out, agy_dt = run_x86(AGY_API, AGY_RT, src, tmp, f"{name}.agy")
            ok = (up == p205_out == agy_out) and not up.startswith("ERR")
            report["cases"][name] = {
                "upstream": up, "p205": p205_out, "agy": agy_out,
                "p205EmitSec": round(p205_dt, 3), "agyEmitSec": round(agy_dt, 3),
                "passed": ok,
            }
            status = "PASS" if ok else "MISMATCH"
            print(f"{name:28s} {status:8s} emit(p205={p205_dt:.2f}s agy={agy_dt:.2f}s) up={up.strip()!r} p205={p205_out.strip()!r} agy={agy_out.strip()!r}", flush=True)
            if not ok:
                report["mismatches"].append(name)
    if len(sys.argv) > 1:
        Path(sys.argv[1]).write_text(json.dumps(report, indent=2) + "\n")
    if report["mismatches"]:
        print(f"\nFOUND {len(report['mismatches'])} MISMATCH(ES): {report['mismatches']}")
        sys.exit(1)
    print(f"\nALL {len(CASES)} BOUNDARY & ADVERSE-PERF AUDIT CASES PASSED!")


if __name__ == "__main__":
    main()
