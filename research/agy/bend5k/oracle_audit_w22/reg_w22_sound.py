#!/usr/bin/env python3
"""Permanent Wave-22 soundness regression sweep for bend5k (-O0 and -O2).

Tests:
  1. All 4 Group-A reproducers + B_b4_nat_literal_gt_u32max + B_b6_*
  2. Nat literal boundary (4294967295n ok, 4294967296n / 5000000000n rejected)
  3. Wide in-range Nat [2^32, 2^47] sweep (peel 1n+r, 3n+r, 40n+r, add/sub/mul/div/mod/cmp/show)
  4. Base library self-execution sweep (Char.quote, String.quote, U32.hex, String.*, Nat.show)
  5. Arrow-typed let bindings (single/multi-arrow, block & inline)
"""
from __future__ import annotations

import argparse
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
REP_DIR = Path(__file__).resolve().parent / "reproducers"
DEFAULT_BEND5K = ROOT / "selfhost/build/agy/bend5k/bend5k_o2"
DEFAULT_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"


def run_cmd(cmd: list[str], cpu: int, timeout: int = 30) -> tuple[int, str, str]:
    p = subprocess.run(
        ["taskset", "-c", str(cpu)] + cmd,
        capture_output=True, text=True, timeout=timeout,
    )
    return p.returncode, p.stdout, p.stderr


def compile_and_run(bend5k: Path, rt: Path, opt: str, src: Path, tmp: Path, tag: str, cpu: int) -> tuple[int, str, str]:
    obj = tmp / f"{tag}_{opt.lstrip('-')}.o"
    exe = tmp / f"{tag}_{opt.lstrip('-')}"
    rc, out, err = run_cmd([str(bend5k), opt, str(src), str(obj)], cpu)
    if rc != 0:
        return rc, out, err
    rc, out, err = run_cmd(["gcc", "-no-pie", str(obj), str(rt), "-pthread", "-lm", "-o", str(exe)], cpu)
    if rc != 0:
        return rc, out, err
    return run_cmd([str(exe)], cpu)


INLINE_CASES: list[tuple[str, str, int, str]] = [
    (
        "nat_lit_u32max_ok",
        "import Base\ndef main() -> IO(Unit):\n  IO.print(Nat.show(4294967295n))\n",
        0, "4294967295\n",
    ),
    (
        "nat_lit_u32max_plus1_reject",
        "import Base\ndef main() -> IO(Unit):\n  IO.print(Nat.show(4294967296n))\n",
        1, "",
    ),
    (
        "nat_wide_peel_and_arith",
        """import Base
def p1(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+r: r
def p3(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n: 1n
    case 2n: 2n
    case 3n+r: r
def p40(n: Nat) -> Nat:
  match n:
    case 40n+r: r
    case _: 0n
def main() -> IO(Unit):
  +b32 = Nat.mul(65536n, 65536n)
  +b40 = Nat.mul(b32, 256n)
  +b47 = Nat.mul(b40, 128n)
  +w = Nat.add(Nat.mul(5n, 1000000000n), 3n)
  r1 = Nat.show(p1(b32))
  r2 = Nat.show(p3(w))
  r3 = Nat.show(p40(b47))
  r4 = Nat.show(Nat.add(b47, b32))
  r5 = Nat.show(Nat.sub(b47, b40))
  r6 = Nat.show(Nat.div(b47, 1000000n))
  r7 = Nat.show(Nat.mod(b47, 1000000n))
  IO.print(r1 ++ "|" ++ r2 ++ "|" ++ r3 ++ "|" ++ r4 ++ "|" ++ r5 ++ "|" ++ r6 ++ "|" ++ r7)
""",
        0,
        f"{(1<<32)-1}|5000000000|{(1<<47)-40}|{(1<<47)+(1<<32)}|{(1<<47)-(1<<40)}|{(1<<47)//1000000}|{(1<<47)%1000000}\n",
    ),
    (
        "base_stdlib_sweep",
        """import Base
def main() -> IO(Unit):
  h = U32.hex(0) ++ "," ++ U32.hex(10) ++ "," ++ U32.hex(127) ++ "," ++ U32.hex(3735928559)
  q1 = Char.quote(39, Chr{65}) ++ "," ++ Char.quote(39, Chr{1}) ++ "," ++ Char.quote(39, Chr{127}) ++ "," ++ Char.quote(39, Chr{55296})
  q2 = String.quote("hi\\n\\t\\"\\\\\\u{0001}")
  +s1 = String.concat(["ab", "cd", "ef"])
  l1 = Nat.show(String.length(s1))
  b1 = Bool.show(String.starts_with(s1, "ab")) ++ "," ++ Bool.show(String.ends_with(s1, "ef"))
  IO.print(h ++ "|" ++ q1 ++ "|" ++ q2 ++ "|" ++ s1 ++ "|" ++ l1 ++ "|" ++ b1)
""",
        0,
        ",a,7f,deadbeef|A,\\u{1},\\u{7f},\\u{d800}|\"hi\\n\\t\\\"\\\\\\u{1}\"|abcdef|6|True,True\n",
    ),
    (
        "typed_let_arrows",
        """import Base
def main() -> IO(Unit):
  f : U32 -> U32 = x => U32.add(x, 10)
  g : U32 -> U32 -> U32 = x => y => U32.add(U32.mul(x, 3), y)
  r = g(f(4))(2)
  IO.print(U32.show(r))
""",
        0, "44\n",
    ),
]

REPRO_CASES: list[tuple[str, int, str]] = [
    ("A_char_quote_ascii_plain.bend", 0, "A\n"),
    ("A_str_quote_ascii_plain.bend", 0, "\"hello\"\n"),
    ("A_nat_peel_wide.bend", 0, "0,10,20,5000000030\n"),
    ("A_hof_compose_and_apply_n.bend", 0, "27,31\n"),
    ("B_b4_nat_literal_gt_u32max.bend", 1, ""),
    ("B_b6_char_quote_control.bend", 0, "\\0|\\n|\\'|\\\\|\u00e9\n"),
    ("B_b6_string_escapes_and_unicode.bend", 0, "\"a\\tb\\\"c\\\\d\u00e9\"|8\n"),
]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--bend5k", type=Path, default=DEFAULT_BEND5K)
    ap.add_argument("--runtime", type=Path, default=DEFAULT_RT)
    ap.add_argument("--cpu", type=int, default=0)
    args = ap.parse_args()

    t0 = time.perf_counter()
    passed = 0
    total = 0
    failures: list[str] = []

    with tempfile.TemporaryDirectory(prefix="agy_reg_w22_") as td:
        tmp = Path(td)
        all_cases: list[tuple[str, Path, int, str]] = []
        for fname, exp_rc, exp_out in REPRO_CASES:
            all_cases.append((fname[:-5], REP_DIR / fname, exp_rc, exp_out))
        for name, code, exp_rc, exp_out in INLINE_CASES:
            p = tmp / f"{name}.bend"
            p.write_text(code, encoding="utf-8")
            all_cases.append((name, p, exp_rc, exp_out))

        for name, src, exp_rc, exp_out in all_cases:
            for opt in ("-O0", "-O2"):
                total += 1
                rc, out, err = compile_and_run(args.bend5k, args.runtime, opt, src, tmp, name, args.cpu)
                ok = (rc == 0 and exp_rc == 0 and out == exp_out) or (rc != 0 and exp_rc != 0)
                if ok:
                    passed += 1
                    print(f"[PASS] {name:36s} {opt}")
                else:
                    msg = f"[FAIL] {name:36s} {opt} rc={rc} (exp {exp_rc}) out={out!r} (exp {exp_out!r}) err={err.strip()[:120]!r}"
                    print(msg)
                    failures.append(msg)

    elapsed = time.perf_counter() - t0
    print(f"\nSUMMARY: {passed}/{total} PASS ({elapsed:.2f}s)")
    return 0 if not failures else 1


if __name__ == "__main__":
    sys.exit(main())
