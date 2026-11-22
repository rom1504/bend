#!/usr/bin/env python3
"""Tier-2 Adversarial Differential Test Suite for Wave 2B Track C.

Tests AGY-W2B-F32LOOP (`apply_f32_loop.py`) and AGY-W2B-DEADARR (`apply_dead_arr_scan.py`)
against BOTH:
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
CAND_API = ROOT / "selfhost/build/agy/wave2_editsym_b/api_w2b.mjs"
P205_RT = ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
TMP = ROOT / "selfhost/build/agy/tier2_audit_w2b_c/adv_tmp"

DYN_ZERO = """
def dyn_zero_go(n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: dyn_zero_go(p, U32.and(acc, 0))

def dyn_zero() -> U32:
  dyn_zero_go(U32.to_nat(300000), 0)
"""

TESTS = {
    "1_f32loop_obs_depth_clobber_xmm8": f"""import Base
{DYN_ZERO}
def loop(n: Nat, +x: F32, +h: U32) -> U32:
  match n:
    case 0n: h
    case 1n+p:
      +y = F32.add(F32.mul(x, 0.5), 1.0)
      +e1 = F32.add(x, 1.0)
      +e2 = F32.mul(1.0, F32.add(1.0, e1))
      +e3 = F32.add(1.0, F32.mul(0.5, e2))
      +e4 = F32.add(1.0, F32.mul(0.5, e3))
      +e5 = F32.add(1.0, F32.mul(0.5, e4))
      +obs = F32.add(y, e5)
      +q = F32.to_u32(obs)
      loop(p, y, U32.add(h, q))

def main() -> IO(Unit):
  +z = dyn_zero()
  IO.print(U32.show(loop(U32.to_nat(U32.add(z, 10)), 1.25, 0)))
""",
    "2_f32loop_h_is_string_64bit_truncation": f"""import Base
{DYN_ZERO}
def loop_str(n: Nat, +x: F32, +s: String) -> String:
  match n:
    case 0n: s
    case 1n+p:
      +y = F32.add(x, 1.0)
      loop_str(p, y, s)

def main() -> IO(Unit):
  +z = dyn_zero()
  IO.print(loop_str(U32.to_nat(U32.add(z, 5)), 1.0, "hello_world"))
""",
    "3_f32loop_to_u32_edges_and_n0_n1": f"""import Base
{DYN_ZERO}
def f_loop(n: Nat, +x: F32, +h: U32) -> U32:
  match n:
    case 0n: h
    case 1n+p:
      +y = F32.add(x, 0.0)
      +q = F32.to_u32(y)
      f_loop(p, y, U32.xor(U32.mul(h, 16777619), q))

def main() -> IO(Unit):
  +z = dyn_zero()
  +p0 = U32.to_f32(z)
  +neg0 = F32.mul(F32.sub(p0, 1.0), p0)
  +neg1 = F32.sub(p0, 1.0)
  +nan = F32.div(p0, p0)
  +pinf = F32.div(1.0, p0)
  +ninf = F32.div(neg1, p0)
  +near_max = U32.to_f32(4294967040)
  +at_2p32 = U32.to_f32(4294967295)
  +r0 = f_loop(U32.to_nat(z), near_max, 777)
  +r1 = f_loop(U32.to_nat(U32.add(z, 1)), near_max, 0)
  +r2 = f_loop(U32.to_nat(U32.add(z, 3)), at_2p32, 11)
  +r3 = f_loop(U32.to_nat(U32.add(z, 3)), neg0, 13)
  +r4 = f_loop(U32.to_nat(U32.add(z, 3)), neg1, 17)
  +r5 = f_loop(U32.to_nat(U32.add(z, 3)), nan, 19)
  +r6 = f_loop(U32.to_nat(U32.add(z, 3)), pinf, 23)
  +r7 = f_loop(U32.to_nat(U32.add(z, 3)), ninf, 29)
  IO.print(
    U32.show(r0) ++ "," ++ U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r3) ++ "," ++
    U32.show(r4) ++ "," ++ U32.show(r5) ++ "," ++ U32.show(r6) ++ "," ++ U32.show(r7))
""",
    "4_f32loop_noncomm_sub_div_and_nested_u32": f"""import Base
{DYN_ZERO}
def nc_loop(n: Nat, +x: F32, +h: U32) -> U32:
  match n:
    case 0n: h
    case 1n+p:
      +y = F32.div(F32.sub(10.0, x), F32.add(x, 2.0))
      +q = F32.to_u32(F32.mul(F32.sub(y, x), 100.0))
      +h2 = U32.sub(U32.xor(h, U32.add(q, 17)), U32.sub(U32.mul(q, 3), U32.and(h, 255)))
      nc_loop(p, y, h2)

def main() -> IO(Unit):
  +z = dyn_zero()
  IO.print(U32.show(nc_loop(U32.to_nat(U32.add(z, 25)), 1.5, 42)))
""",
    "5_deadarr_k1_and_overflow_and_aliasing": f"""import Base
{DYN_ZERO}
def fold.step(+i: U32, +acc: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (a, v) = r
  +next = U32.add(acc, v)
  (a[i] <- U32.xor(next, i), next)

def fold.cell(+i: U32, st: Array<U32> & U32) -> Array<U32> & U32:
  (a, acc) = st
  fold.step(i, acc, Array.get(U32, a, i))

def fold.loop(+n: Nat, +i: U32, st: Array<U32> & U32) -> Array<U32> & U32:
  match n:
    case 0n: st
    case 1n+q: fold.loop(q, U32.inc(i), fold.cell(i, st))

def fold.finish(r: Array<U32> & U32) -> U32:
  (a, acc) = r
  acc

def fold.finish_live_arr2(+acc: U32, r: Array<U32> & U32) -> U32:
  (a, v0) = r
  U32.xor(acc, v0)

def fold.finish_live_arr(r: Array<U32> & U32) -> U32:
  (a, acc) = r
  fold.finish_live_arr2(acc, Array.get(U32, a, 0))

def run_k1(+n: U32, seed: U32, acc0: U32) -> U32:
  fold.finish(fold.loop(U32.to_nat(n), 0, ([seed : U32*1n], acc0)))

def run_k128_over(+n: U32, seed: U32, acc0: U32) -> U32:
  fold.finish(fold.loop(U32.to_nat(n), 5, ([seed : U32*128n], acc0)))

def run_k128_live(+n: U32, seed: U32) -> U32:
  fold.finish_live_arr(fold.loop(U32.to_nat(n), 0, ([seed : U32*128n], 0)))

def main() -> IO(Unit):
  +z = dyn_zero()
  +a0 = run_k1(z, 123456789, 10)
  +a1 = run_k1(U32.add(z, 1), 123456789, 10)
  +a2 = run_k1(U32.add(z, 2), 123456789, 10)
  +a3 = run_k1(U32.add(z, 5), 123456789, 10)
  +b0 = run_k128_over(U32.add(z, 128), 100000007, 4294967290)
  +b1 = run_k128_over(U32.add(z, 129), 100000007, 4294967290)
  +c0 = run_k128_live(U32.add(z, 10), 77)
  IO.print(
    U32.show(a0) ++ "," ++ U32.show(a1) ++ "," ++ U32.show(a2) ++ "," ++ U32.show(a3) ++ "," ++
    U32.show(b0) ++ "," ++ U32.show(b1) ++ "," ++ U32.show(c0))
""",
    "6_deadarr_step2_not_scan4": f"""import Base
{DYN_ZERO}
def s2.step(+i: U32, +acc: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (a, v) = r
  +next = U32.add(acc, v)
  (a[i] <- U32.xor(next, i), next)

def s2.cell(+i: U32, st: Array<U32> & U32) -> Array<U32> & U32:
  (a, acc) = st
  s2.step(i, acc, Array.get(U32, a, i))

def s2.loop(+n: Nat, +i: U32, st: Array<U32> & U32) -> Array<U32> & U32:
  match n:
    case 0n: st
    case 1n+q: s2.loop(q, U32.add(i, 2), s2.cell(i, st))

def s2.finish(r: Array<U32> & U32) -> U32:
  (a, acc) = r
  acc

def run_step2(+n: U32, seed: U32) -> U32:
  s2.finish(s2.loop(U32.to_nat(n), 0, ([seed : U32*8n], 0)))

def main() -> IO(Unit):
  +z = dyn_zero()
  IO.print(U32.show(run_step2(U32.add(z, 6), 19)) ++ "," ++ U32.show(run_step2(U32.add(z, 8), 19)))
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
    print(f"\nTIER-2 ADVERSARIAL SUITE PASSED: {len(TESTS)}/{len(TESTS)} (upstream == Phase205 == Wave 2B Track C)!")


if __name__ == "__main__":
    main()
