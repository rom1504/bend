#!/usr/bin/env python3
"""Tier-2 Adversarial Differential Test Suite for Wave 2 Track A.

Tests every subtle edge case of Pass 1 + Pass 2a + Pass 2b against BOTH:
  1. Upstream Bend (`bun bend2/main.ts`)
  2. Phase 205 baseline (`selfhost/build/agy/api-base/api.mjs`)

Uses an opaque `dyn_zero()` helper (exceeding CTFE fuel) so runtime x86 codegen
paths are guaranteed to execute rather than being folded away by CTFE, while
also testing compile-time F32 constant folding (`w2_fc_nodes`) directly.
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
CAND_API = ROOT / "selfhost/build/agy/wave2_ray/api_p2b.mjs"
P205_RT = ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
TMP = ROOT / "selfhost/build/agy/tier2_audit_a/adv_tmp"

DYN_ZERO = """
def dyn_zero_go(n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: dyn_zero_go(p, U32.and(acc, 0))

def dyn_zero() -> U32:
  dyn_zero_go(U32.to_nat(300000), 0)
"""

TESTS = {
    "1_f32_const_fold_signed_zero_nan_inf": f"""import Base
{DYN_ZERO}
def b2u(b: Bool) -> U32:
  match b:
    case False{{}}: 0
    case True{{}}: 1

def check_const(+tag: U32) -> String:
  +p0 = U32.to_f32(0)
  +n0 = F32.sub(U32.to_f32(0), U32.to_f32(0))
  +neg0 = F32.mul(F32.sub(U32.to_f32(0), U32.to_f32(1)), U32.to_f32(0))
  +add_nn = F32.add(neg0, neg0)
  +add_np = F32.add(neg0, p0)
  +sq_p0 = F32.bits(F32.sqrt(p0))
  +sq_n0 = F32.bits(F32.sqrt(neg0))
  +sq_neg = F32.sqrt(F32.sub(U32.to_f32(0), U32.to_f32(1)))
  +sq_neg_nan = b2u(F32.is_ne(sq_neg, sq_neg))
  +pinf = F32.div(U32.to_f32(1), p0)
  +ninf = F32.div(U32.to_f32(1), neg0)
  +nan = F32.div(p0, p0)
  +u_p0 = F32.to_u32(p0)
  +u_n0 = F32.to_u32(neg0)
  +u_neg = F32.to_u32(F32.sub(U32.to_f32(0), U32.to_f32(1)))
  +u_nan = F32.to_u32(nan)
  +u_pinf = F32.to_u32(pinf)
  +u_ninf = F32.to_u32(ninf)
  +u_max = F32.to_u32(U32.to_f32(4294967295))
  +b_max = F32.bits(U32.to_f32(4294967295))
  +u_below = F32.to_u32(U32.to_f32(4294967040))
  U32.show(U32.add(tag, F32.bits(p0))) ++ "," ++
  U32.show(F32.bits(n0)) ++ "," ++
  U32.show(F32.bits(neg0)) ++ "," ++
  U32.show(F32.bits(add_nn)) ++ "," ++
  U32.show(F32.bits(add_np)) ++ "," ++
  U32.show(sq_p0) ++ "," ++
  U32.show(sq_n0) ++ "," ++
  U32.show(sq_neg_nan) ++ "," ++
  U32.show(F32.bits(pinf)) ++ "," ++
  U32.show(F32.bits(ninf)) ++ "," ++
  U32.show(b2u(F32.is_ne(nan, nan))) ++ "," ++
  U32.show(u_p0) ++ "," ++
  U32.show(u_n0) ++ "," ++
  U32.show(u_neg) ++ "," ++
  U32.show(u_nan) ++ "," ++
  U32.show(u_pinf) ++ "," ++
  U32.show(u_ninf) ++ "," ++
  U32.show(u_max) ++ "," ++
  U32.show(b_max) ++ "," ++
  U32.show(u_below)

def check_dyn(+z: U32) -> String:
  +p0 = U32.to_f32(z)
  +neg0 = F32.mul(F32.sub(p0, U32.to_f32(1)), p0)
  +sq_n0 = F32.bits(F32.sqrt(neg0))
  +sq_neg = F32.sqrt(F32.sub(p0, U32.to_f32(1)))
  +sq_neg_nan = b2u(F32.is_ne(sq_neg, sq_neg))
  +pinf = F32.div(U32.to_f32(1), p0)
  +ninf = F32.div(U32.to_f32(1), neg0)
  +nan = F32.div(p0, p0)
  U32.show(F32.bits(neg0)) ++ "," ++
  U32.show(sq_n0) ++ "," ++
  U32.show(sq_neg_nan) ++ "," ++
  U32.show(F32.to_u32(neg0)) ++ "," ++
  U32.show(F32.to_u32(F32.sub(p0, U32.to_f32(1)))) ++ "," ++
  U32.show(F32.to_u32(nan)) ++ "," ++
  U32.show(F32.to_u32(pinf)) ++ "," ++
  U32.show(F32.to_u32(ninf))

def main() -> IO(Unit):
  +z = dyn_zero()
  IO.print(check_const(z) ++ "|" ++ check_dyn(z))
""",
    "2_f32_fused_cmp_nan_all_ops": f"""import Base
{DYN_ZERO}
def add_if(b: Bool, r: U32, bit: U32) -> U32:
  match b:
    case True{{}}: U32.add(r, bit)
    case False{{}}: r

def cmp_all(+a: F32, +b: F32) -> U32:
  +r = add_if(F32.is_lt(a, b), 0, 1)
  +r = add_if(F32.is_le(a, b), r, 2)
  +r = add_if(F32.is_gt(a, b), r, 4)
  +r = add_if(F32.is_ge(a, b), r, 8)
  +r = add_if(F32.is_eq(a, b), r, 16)
  +r = add_if(F32.is_ne(a, b), r, 32)
  +r = add_if(Bool.not(F32.is_lt(a, b)), r, 64)
  +r = add_if(Bool.not(F32.is_le(a, b)), r, 128)
  +r = add_if(Bool.not(F32.is_gt(a, b)), r, 256)
  +r = add_if(Bool.not(F32.is_ge(a, b)), r, 512)
  +r = add_if(Bool.not(F32.is_eq(a, b)), r, 1024)
  add_if(Bool.not(F32.is_ne(a, b)), r, 2048)

def run_pairs(+z: U32) -> String:
  +p0 = U32.to_f32(z)
  +n0 = F32.mul(F32.sub(p0, U32.to_f32(1)), p0)
  +one = U32.to_f32(1)
  +two = U32.to_f32(2)
  +nan = F32.div(p0, p0)
  +pinf = F32.div(one, p0)
  +ninf = F32.div(F32.sub(p0, one), p0)
  U32.show(cmp_all(nan, one)) ++ "," ++
  U32.show(cmp_all(one, nan)) ++ "," ++
  U32.show(cmp_all(nan, nan)) ++ "," ++
  U32.show(cmp_all(p0, n0)) ++ "," ++
  U32.show(cmp_all(n0, p0)) ++ "," ++
  U32.show(cmp_all(ninf, pinf)) ++ "," ++
  U32.show(cmp_all(pinf, ninf)) ++ "," ++
  U32.show(cmp_all(one, one)) ++ "," ++
  U32.show(cmp_all(one, two)) ++ "," ++
  U32.show(cmp_all(two, one))

def main() -> IO(Unit):
  IO.print(run_pairs(dyn_zero()))
""",
    "3_table_clamp_bounds_and_diff_lengths": f"""import Base
{DYN_ZERO}
def t3(i: Nat) -> F32:
  match i:
    case 0n: 100.0
    case 1n: 200.0
    case 2n+k: 300.0

def t5a(i: Nat) -> F32:
  match i:
    case 0n: 1.0
    case 1n: 2.0
    case 2n: 3.0
    case 3n: 4.0
    case 4n+k: 5.0

def t5b(i: Nat) -> F32:
  match i:
    case 0n: 10.0
    case 1n: 20.0
    case 2n: 30.0
    case 3n: 40.0
    case 4n+k: 50.0

def probe_one(+i: Nat) -> U32:
  +a = t5a(i)
  +b = t3(i)
  +c = t5a(i)
  +d = t5b(i)
  F32.to_u32(F32.add(F32.add(a, b), F32.add(c, d)))

def main() -> IO(Unit):
  +z = dyn_zero()
  +r0 = probe_one(U32.to_nat(z))
  +r1 = probe_one(U32.to_nat(U32.add(z, 1)))
  +r2 = probe_one(U32.to_nat(U32.add(z, 2)))
  +r3 = probe_one(U32.to_nat(U32.add(z, 3)))
  +r4 = probe_one(U32.to_nat(U32.add(z, 4)))
  +r5 = probe_one(U32.to_nat(U32.add(z, 5)))
  +rmax = probe_one(U32.to_nat(U32.add(z, 4294967295)))
  IO.print(
    U32.show(r0) ++ "," ++ U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++
    U32.show(r3) ++ "," ++ U32.show(r4) ++ "," ++ U32.show(r5) ++ "," ++ U32.show(rmax))
""",
    "4_xmm10_15_hoist_sqrt_slowpath_subnormal_nan": f"""import Base
{DYN_ZERO}
def b2u(b: Bool) -> U32:
  match b:
    case False{{}}: 0
    case True{{}}: 1

def loop(n: Nat, +inv1: F32, +inv2: F32, +inv3: F32, +inv4: F32, +x: F32, acc: U32) -> U32:
  match n:
    case 0n:
      +fin = F32.add(F32.add(inv1, inv2), F32.add(inv3, F32.add(inv4, x)))
      U32.xor(acc, F32.bits(fin))
    case 1n+p:
      +p0 = U32.to_f32(0)
      +neg0 = F32.mul(F32.sub(p0, U32.to_f32(1)), p0)
      +sq_neg = F32.sqrt(F32.sub(p0, inv1))
      +sq_nan = F32.sqrt(F32.div(p0, p0))
      +sq_n0 = F32.sqrt(neg0)
      +sub_in = F32.div(inv2, F32.mul(F32.mul(10000000000.0, 10000000000.0), F32.mul(10000000000.0, 10000000000.0)))
      +sq_sub = F32.sqrt(sub_in)
      +flags = U32.add(b2u(F32.is_ne(sq_neg, sq_neg)), U32.mul(b2u(F32.is_ne(sq_nan, sq_nan)), 2))
      +y = F32.add(F32.mul(x, inv1), F32.sub(inv2, F32.mul(inv3, inv4)))
      +next_x = F32.add(F32.mul(y, 0.25), F32.mul(inv4, 0.75))
      +q = U32.xor(F32.bits(sq_n0), U32.xor(F32.bits(sq_sub), U32.add(flags, F32.to_u32(F32.mul(next_x, 100.0)))))
      loop(p, inv1, inv2, inv3, inv4, next_x, U32.xor(U32.mul(acc, 16777619), q))

def main() -> IO(Unit):
  +z = dyn_zero()
  IO.print(U32.show(loop(U32.to_nat(U32.add(z, 40)), 1.25, 0.5, 0.125, 2.5, 3.0, 17)))
""",
    "5_xmm10_15_hoist_nested_call_fallback": f"""import Base
{DYN_ZERO}
def helper(+a: F32, +b: F32) -> F32:
  +t1 = F32.add(a, b)
  +t2 = F32.mul(t1, 1.5)
  +t3 = F32.sub(t2, 0.25)
  +t4 = F32.div(t3, 2.0)
  +t5 = F32.add(t4, F32.mul(a, 0.75))
  +t6 = F32.sub(t5, F32.mul(b, 0.125))
  F32.sqrt(F32.add(F32.mul(t6, t6), 1.0))

def loop_with_call(n: Nat, +inv1: F32, +inv2: F32, +inv3: F32, +x: F32, acc: U32) -> U32:
  match n:
    case 0n: U32.xor(acc, F32.bits(F32.add(F32.add(inv1, inv2), F32.add(inv3, x))))
    case 1n+p:
      +h = helper(F32.add(x, inv1), F32.add(inv2, inv3))
      +nx = F32.add(F32.mul(h, 0.5), inv1)
      loop_with_call(p, inv1, inv2, inv3, nx, U32.xor(U32.mul(acc, 16777619), F32.bits(nx)))

def main() -> IO(Unit):
  +z = dyn_zero()
  IO.print(U32.show(loop_with_call(U32.to_nat(U32.add(z, 20)), 1.25, 2.5, 3.75, 0.5, 99)))
""",
    "6_x198qm_divmod_constants_edges": f"""import Base
{DYN_ZERO}
def dm_one(+x: U32) -> U32:
  +h = U32.add(U32.div(x, 1), U32.mul(U32.mod(x, 1), 3))
  +h = U32.xor(U32.mul(h, 16777619), U32.add(U32.div(x, 2), U32.mul(U32.mod(x, 2), 5)))
  +h = U32.xor(U32.mul(h, 16777619), U32.add(U32.div(x, 3), U32.mul(U32.mod(x, 3), 7)))
  +h = U32.xor(U32.mul(h, 16777619), U32.add(U32.div(x, 7), U32.mul(U32.mod(x, 7), 11)))
  +h = U32.xor(U32.mul(h, 16777619), U32.add(U32.div(x, 255), U32.mul(U32.mod(x, 255), 13)))
  +h = U32.xor(U32.mul(h, 16777619), U32.add(U32.div(x, 4294967295), U32.mul(U32.mod(x, 4294967295), 17)))
  h

def main() -> IO(Unit):
  +z = dyn_zero()
  +h = dm_one(z)
  +h = U32.xor(U32.mul(h, 16777619), dm_one(U32.add(z, 1)))
  +h = U32.xor(U32.mul(h, 16777619), dm_one(U32.add(z, 2)))
  +h = U32.xor(U32.mul(h, 16777619), dm_one(U32.add(z, 7)))
  +h = U32.xor(U32.mul(h, 16777619), dm_one(U32.add(z, 254)))
  +h = U32.xor(U32.mul(h, 16777619), dm_one(U32.add(z, 255)))
  +h = U32.xor(U32.mul(h, 16777619), dm_one(U32.add(z, 256)))
  +h = U32.xor(U32.mul(h, 16777619), dm_one(U32.add(z, 2147483647)))
  +h = U32.xor(U32.mul(h, 16777619), dm_one(U32.add(z, 2147483648)))
  +h = U32.xor(U32.mul(h, 16777619), dm_one(U32.add(z, 4294967294)))
  +h = U32.xor(U32.mul(h, 16777619), dm_one(U32.add(z, 4294967295)))
  IO.print(U32.show(h))
""",
    "7_asr_live_intermediate_s2_and_m": f"""import Base
{DYN_ZERO}
def sel.go(x: U32, y: U32, z: Bool) -> U32:
  match z:
    case True{{}}: x
    case False{{}}: y

def sel(t: U32, x: U32, y: U32) -> U32:
  sel.go(x, y, U32.is_zero(t))

def asr8_use_s2(+v: U32) -> U32:
  +s1 = U32.shrn(v, 8n)
  +s2 = U32.shrn(v, 31n)
  +m = sel(s2, 0, 4278190080)
  +r = U32.or(s1, m)
  U32.add(r, U32.mul(s2, 12345))

def asr8_use_m(+v: U32) -> U32:
  +s1 = U32.shrn(v, 8n)
  +s2 = U32.shrn(v, 31n)
  +m = sel(s2, 0, 4278190080)
  +r = U32.or(s1, m)
  U32.xor(r, m)

def asr8_use_s1(+v: U32) -> U32:
  +s1 = U32.shrn(v, 8n)
  +s2 = U32.shrn(v, 31n)
  +m = sel(s2, 0, 4278190080)
  +r = U32.or(s1, m)
  U32.add(r, s1)

def main() -> IO(Unit):
  +z = dyn_zero()
  +v1 = U32.add(3735928559, z)
  +v2 = U32.add(123456, z)
  IO.print(
    U32.show(asr8_use_s2(v1)) ++ "," ++ U32.show(asr8_use_m(v1)) ++ "," ++ U32.show(asr8_use_s1(v1)) ++ "," ++
    U32.show(asr8_use_s2(v2)) ++ "," ++ U32.show(asr8_use_m(v2)) ++ "," ++ U32.show(asr8_use_s1(v2)))
""",
    "8_xmm_carried_swap_and_multi_exit": f"""import Base
{DYN_ZERO}
def swap_loop(n: Nat, +a: F32, +b: F32, +k: F32, acc: U32) -> U32:
  match n:
    case 0n: U32.xor(acc, F32.bits(F32.add(a, F32.mul(b, k))))
    case 1n+p:
      +na = F32.add(b, F32.mul(a, 0.25))
      +nb = F32.sub(a, F32.mul(k, 0.125))
      +sq = F32.sqrt(F32.sub(U32.to_f32(0), k))
      +q = U32.xor(F32.bits(na), U32.xor(F32.bits(nb), F32.bits(sq)))
      swap_loop(p, na, nb, k, U32.xor(U32.mul(acc, 16777619), q))

def main() -> IO(Unit):
  +z = dyn_zero()
  IO.print(U32.show(swap_loop(U32.to_nat(U32.add(z, 30)), 1.5, 2.25, 0.75, 7)))
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
        print(f"{status:4s} {name:46s} up={up.strip()!r}", flush=True)
        if not ok:
            print(f"     p205={p205.strip()!r}", flush=True)
            print(f"     cand={cand.strip()!r}", flush=True)
            failures.append((name, up, p205, cand))
        src.unlink(missing_ok=True)
    if failures:
        print(f"\nTIER-2 ADVERSARIAL SUITE FAILED: {len(failures)}/{len(TESTS)} failures!")
        sys.exit(1)
    print(f"\nTIER-2 ADVERSARIAL SUITE PASSED: {len(TESTS)}/{len(TESTS)} (upstream == Phase205 == Track A)!")


if __name__ == "__main__":
    main()
