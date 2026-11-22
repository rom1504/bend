#!/usr/bin/env python3
"""Tier-2 Adversarial Differential Test Suite for Wave 2C Track A.

Tests all 6 Wave 2C passes against BOTH:
  1. Upstream Bend (`bun bend2/main.ts`)
  2. Phase 205 baseline (`selfhost/build/agy/api-base/api.mjs`)
"""
import subprocess
import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EMIT = ROOT / "research/agy/emit_obj.mjs"
BASE_API = ROOT / "selfhost/build/agy/api-base/api.mjs"
CAND_API = ROOT / "selfhost/build/agy/wave2c_ray/api_w2c.mjs"
P205_RT = ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
TMP = ROOT / "selfhost/build/agy/tier2_audit_w2c_a/adv_tmp"

DYN_ZERO = """
def dyn_zero_go(n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: dyn_zero_go(p, U32.and(acc, 0))

def dyn_zero() -> U32:
  dyn_zero_go(U32.to_nat(300000), 0)
"""

TESTS = {
    "1_xmm_across_branch_diamond_and_call": f"""import Base
{DYN_ZERO}
def clobber_all(n: Nat, x: F32) -> F32:
  match n:
    case 0n: x
    case 1n+p:
      +a = F32.add(x, 0.125)
      +b = F32.mul(a, 1.0002)
      +c = F32.sub(b, 0.0625)
      clobber_all(p, F32.div(c, 1.0001))

def arm_yes_call(cond: Bool, a: F32, b: F32, c: F32) -> F32:
  match cond:
    case True{{}}: F32.add(clobber_all(4n, a), b)
    case False{{}}: F32.sub(c, b)

def arm_no_call(cond: Bool, a: F32, b: F32, c: F32) -> F32:
  match cond:
    case True{{}}: F32.sub(a, c)
    case False{{}}: F32.add(clobber_all(4n, b), c)

def arm_overwrite_one(cond: Bool, a: F32, b: F32) -> F32:
  match cond:
    case True{{}}: F32.add(F32.mul(a, 3.0), b)
    case False{{}}: a

def diamond_loop(n: Nat, +x: F32, +y: F32, acc: F32) -> F32:
  match n:
    case 0n: acc
    case 1n+p:
      +a = F32.add(F32.mul(x, 1.5), 0.25)
      +b = F32.sub(F32.mul(y, 2.0), a)
      +c = F32.div(F32.add(a, 3.0), F32.add(F32.mul(b, b), 1.0))
      +r1 = arm_yes_call(F32.is_lt(a, b), a, b, c)
      +r2 = arm_no_call(F32.is_gt(b, c), a, b, c)
      +r3 = arm_overwrite_one(F32.is_le(r1, r2), a, b)
      +out = F32.add(F32.add(a, b), F32.add(c, F32.add(r1, F32.add(r2, r3))))
      diamond_loop(p, F32.add(x, 0.13), F32.sub(y, 0.07), F32.add(acc, out))

def main() -> IO(Unit):
  +z = dyn_zero()
  +r = diamond_loop(U32.to_nat(U32.add(z, 15)), 0.5, 1.25, 0.0)
  IO.print(U32.show(F32.bits(r)))
""",
    "2_table_to_xmm_mixed_f32_u32_and_oob": f"""import Base
{DYN_ZERO}
def ft5(i: Nat) -> F32:
  match i:
    case 0n: 1.25
    case 1n: F32.sub(0.0, 2.5)
    case 2n: 3.75
    case 3n: 0.0
    case 4n+k: 9.5

def ft3(i: Nat) -> F32:
  match i:
    case 0n: 10.0
    case 1n: 20.0
    case 2n+k: 30.0

def probe_mixed(+i: Nat, +x: F32) -> U32:
  +a = ft5(i)
  +b = ft3(i)
  +c = ft5(i)
  +fsum = F32.add(F32.sub(F32.mul(a, x), b), c)
  +bits_a = F32.bits(a)
  U32.xor(F32.bits(fsum), bits_a)

def main() -> IO(Unit):
  +z = dyn_zero()
  +r0 = probe_mixed(U32.to_nat(z), 2.0)
  +r1 = probe_mixed(U32.to_nat(U32.add(z, 1)), 2.0)
  +r2 = probe_mixed(U32.to_nat(U32.add(z, 2)), 2.0)
  +r3 = probe_mixed(U32.to_nat(U32.add(z, 3)), 2.0)
  +r4 = probe_mixed(U32.to_nat(U32.add(z, 4)), 2.0)
  +r5 = probe_mixed(U32.to_nat(U32.add(z, 5)), 2.0)
  +rmax = probe_mixed(U32.to_nat(U32.add(z, 4294967295)), 2.0)
  IO.print(
    U32.show(r0) ++ "," ++ U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++
    U32.show(r3) ++ "," ++ U32.show(r4) ++ "," ++ U32.show(r5) ++ "," ++ U32.show(rmax))
""",
    "3_mem_sse_noncomm_subss_divss_spills": f"""import Base
{DYN_ZERO}
def spill_noncomm(+x: F32) -> U32:
  +f0 = F32.add(x, 1.0)
  +f1 = F32.add(x, 2.0)
  +f2 = F32.add(x, 3.0)
  +f3 = F32.add(x, 4.0)
  +f4 = F32.add(x, 5.0)
  +f5 = F32.add(x, 6.0)
  +f6 = F32.add(x, 7.0)
  +f7 = F32.add(x, 8.0)
  +f8 = F32.add(x, 9.0)
  +f9 = F32.add(x, 10.0)
  +f10 = F32.add(x, 11.0)
  +f11 = F32.add(x, 12.0)
  +f12 = F32.add(x, 13.0)
  +f13 = F32.add(x, 14.0)
  +f14 = F32.add(x, 15.0)
  +f15 = F32.add(x, 16.0)
  # Non-commutative sub & div in both directions across spilled and register operands
  +d0 = F32.sub(f0, f15)
  +d1 = F32.sub(f15, f1)
  +d2 = F32.div(f2, f14)
  +d3 = F32.div(f14, f3)
  +d4 = F32.sub(f4, f13)
  +d5 = F32.div(f12, f5)
  +d6 = F32.sub(f6, f11)
  +d7 = F32.div(f7, f10)
  +d8 = F32.sub(f8, f9)
  +d9 = F32.div(f9, f8)
  +s = F32.sub(F32.add(d0, d1), F32.div(F32.add(d2, d3), F32.add(F32.mul(d4, d4), 1.0)))
  +t = F32.div(F32.sub(d5, d6), F32.add(F32.mul(d7, d7), 2.0))
  +u = F32.sub(F32.div(d8, F32.add(F32.mul(d9, d9), 3.0)), f0)
  +v = F32.add(F32.add(s, t), F32.add(u, F32.sub(f15, f14)))
  F32.bits(v)

def main() -> IO(Unit):
  +z = dyn_zero()
  +x = F32.add(U32.to_f32(z), 1.375)
  IO.print(U32.show(spill_noncomm(x)))
""",
    "4_empty_if_mul2_wrap_and_movd": f"""import Base
{DYN_ZERO}
def test_mul2(+x: U32) -> U32:
  +a = U32.mul(2, x)
  +b = U32.mul(x, 2)
  +c = U32.mul(2, a)
  +d = U32.mul(b, 2)
  U32.xor(U32.add(a, b), U32.add(c, d))

def dead_if_pick(b: Bool, x: U32) -> U32:
  match b:
    case True{{}}: U32.add(x, 1)
    case False{{}}: U32.add(x, 2)

def test_dead_if(+x: U32) -> U32:
  _unused = dead_if_pick(U32.is_eq(U32.and(x, 1), 0), x)
  U32.mul(2, x)

def test_movd_rt(+x: F32) -> U32:
  +y = F32.add(F32.mul(x, 1.5), 0.25)
  +b = F32.bits(y)
  +z = F32.sub(y, 0.5)
  U32.xor(b, F32.bits(z))

def main() -> IO(Unit):
  +z = dyn_zero()
  +h = test_mul2(z)
  +h = U32.xor(U32.mul(h, 16777619), test_mul2(U32.add(z, 1)))
  +h = U32.xor(U32.mul(h, 16777619), test_mul2(U32.add(z, 1073741824)))
  +h = U32.xor(U32.mul(h, 16777619), test_mul2(U32.add(z, 2147483647)))
  +h = U32.xor(U32.mul(h, 16777619), test_mul2(U32.add(z, 2147483648)))
  +h = U32.xor(U32.mul(h, 16777619), test_mul2(U32.add(z, 4294967295)))
  +h = U32.xor(U32.mul(h, 16777619), test_dead_if(U32.add(z, 2147483648)))
  +h = U32.xor(U32.mul(h, 16777619), test_movd_rt(F32.add(U32.to_f32(z), 2.75)))
  IO.print(U32.show(h))
""",
    "5_table_64bit_str_and_nat_in_float_fn": f"""import Base
{DYN_ZERO}
def stbl(i: Nat) -> String:
  match i:
    case 0n: "alpha"
    case 1n: "beta"
    case 2n: "gamma"
    case 3n+k: "delta"

def pick_s(b: Bool, s: String) -> String:
  match b:
    case True{{}}: s
    case False{{}}: "neg"

def float_and_str(+i: Nat, +x: F32) -> String:
  +y = F32.add(F32.mul(x, 2.5), 1.0)
  +s = stbl(i)
  pick_s(F32.is_gt(y, 0.0), s)

def main() -> IO(Unit):
  +z = dyn_zero()
  IO.print(
    float_and_str(U32.to_nat(z), 1.5) ++ "," ++
    float_and_str(U32.to_nat(U32.add(z, 1)), 1.5) ++ "," ++
    float_and_str(U32.to_nat(U32.add(z, 5)), 1.5))
""",
}


def run_upstream(src: Path) -> str:
    r = subprocess.run([str(BUN), str(ROOT / "bend2/main.ts"), str(src)],
                       capture_output=True, text=True, timeout=30)
    if r.returncode != 0:
        return f"UP_ERR({r.returncode}): {r.stderr.strip()[:200]}"
    return r.stdout


def run_x86(api: Path, rt: Path, src: Path, tag: str) -> str:
    obj = TMP / f"{tag}.o"
    exe = TMP / f"{tag}.exe"
    try:
        em = subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api), str(src), str(obj)],
                            capture_output=True, text=True, timeout=60)
        if em.returncode != 0:
            return f"EMIT_ERR({em.returncode}): {em.stderr.strip()[:200]}"
        lk = subprocess.run([CC, "-no-pie", str(obj), str(rt), "-pthread", "-lm", "-o", str(exe)],
                            capture_output=True, text=True, timeout=30)
        if lk.returncode != 0:
            return f"LINK_ERR({lk.returncode}): {lk.stderr.strip()[:200]}"
        run = subprocess.run([str(exe)], capture_output=True, text=True, timeout=30)
        if run.returncode != 0:
            return f"RUN_ERR({run.returncode}): {run.stderr.strip()[:200]}"
        if run.stderr:
            return f"STDERR: {run.stderr.strip()[:200]}"
        return run.stdout
    finally:
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)


def main():
    TMP.mkdir(parents=True, exist_ok=True)
    failures = []
    for name, code in TESTS.items():
        src = TMP / f"{name}.bend"
        src.write_text(code)
        up = run_upstream(src)
        p205 = run_x86(BASE_API, P205_RT, src, f"{name}.p205")
        cand = run_x86(CAND_API, AGY_RT, src, f"{name}.cand")
        ok = (up == p205 == cand) and not up.startswith("UP_ERR")
        status = "PASS" if ok else "FAIL"
        print(f"{status:4s} {name:42s} up={up.strip()!r}", flush=True)
        if not ok:
            print(f"     p205={p205.strip()!r}", flush=True)
            print(f"     cand={cand.strip()!r}", flush=True)
            failures.append((name, up, p205, cand))
        src.unlink(missing_ok=True)
    if failures:
        print(f"\nTIER-2 ADVERSARIAL SUITE FAILED: {len(failures)}/{len(TESTS)} failures!")
        sys.exit(1)
    print(f"\nTIER-2 ADVERSARIAL SUITE PASSED: {len(TESTS)}/{len(TESTS)} (upstream == Phase205 == Wave 2C Track A)!")


if __name__ == "__main__":
    main()
