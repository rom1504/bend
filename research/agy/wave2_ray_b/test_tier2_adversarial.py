#!/usr/bin/env python3
"""Tier-2 Adversarial & Boundary Differential Test Suite for Wave 2B Track A:
  - Carried F32 in XMM across P113DAgain (including XMM 10..15 exhaustion!)
  - Float copy coalescing + commutative addss/mulss
  - Unboxed/boxed Bool branch fast-path
  - Sound post-DCE sarl (asr) with boundary values & live intermediates

Requires bit-exact stdout across:
  1. Upstream Bend (bun /home/ai/bend2_agy/bend2/main.ts)
  2. Phase 205 hosted x86 API (api-base/api.mjs)
  3. Wave 2B Track A candidate hosted x86 API (arg 1)
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
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
TMP_ROOT = ROOT / "selfhost/build/agy/tier2_audit_w2b_a/adv_tmp"

CASES = [
    # ------------------------------------------------------------------
    # 1. Carried F32 XMM register exhaustion bug!
    #    6 invariant F32 params exhaust xmm10..xmm15 -> w2_xl_pick_carried returns cxmm=0,
    #    while w2b_find_carried_idx already allowed vals[cidx] (y_next) to live ONLY in XMM!
    # ------------------------------------------------------------------
    (
        "w2b_carried_xmm_reg_exhaust",
        r'''import Base

def loop_ex3(n: Nat, +y: F32, +z: F32) -> F32:
  match n:
    case 0n: F32.add(y, z)
    case 1n+p:
      t1 = F32.mul(y, 0.75)
      t2 = F32.add(t1, 0.25)
      t3 = F32.mul(t2, 0.5)
      t4 = F32.add(t3, 0.125)
      t5 = F32.mul(t4, 0.875)
      t6 = F32.add(t5, 0.0625)
      y_next = F32.add(t6, 0.1875)
      z_next = F32.add(z, y)
      loop_ex3(p, y_next, z_next)

def main() -> IO(Unit):
  IO.print(U32.show(F32.bits(loop_ex3(12n, 1.5, 2.5))))
''',
    ),
    # ------------------------------------------------------------------
    # 2. Carried F32 also read as GPR bits (F32.bits), swapped carried F32s, exit use
    # ------------------------------------------------------------------
    (
        "w2b_carried_bits_and_swap",
        r'''import Base

def loop_bits(n: Nat, +y: F32, +k: F32, acc: U32) -> U32:
  match n:
    case 0n: U32.xor(acc, F32.bits(y))
    case 1n+p:
      loop_bits(p, F32.add(F32.mul(y, k), 0.5), k, U32.xor(acc, F32.bits(y)))

def loop_swap(n: Nat, +a: F32, +b: F32) -> U32:
  match n:
    case 0n: U32.xor(F32.bits(a), F32.bits(b))
    case 1n+p:
      loop_swap(p, b, F32.add(F32.mul(a, 0.5), F32.mul(b, 0.25)))

def main() -> IO(Unit):
  r1 = loop_bits(10n, 1.25, 0.75, 0)
  r2 = loop_swap(10n, 1.0, 2.0)
  IO.print(U32.show(r1) ++ " " ++ U32.show(r2))
''',
    ),
    # ------------------------------------------------------------------
    # 3. Float copy coalescing + commutative addss/mulss aliasing & signed zero / NaN
    # ------------------------------------------------------------------
    (
        "w2b_coalesce_and_comm_edges",
        r'''import Base

def f_chain(+x: F32, +y: F32) -> U32:
  +a = F32.add(x, x)
  +b = F32.mul(y, y)
  +c = F32.add(a, b)
  d = F32.add(b, c)
  e = F32.mul(c, d)
  f = F32.sub(e, a)
  U32.xor(F32.bits(f), F32.bits(c))

def f_neg_zero() -> U32:
  +nz = F32.neg(0.0)
  +pz : F32 = 0.0
  a = F32.add(nz, pz)
  b = F32.add(pz, nz)
  c = F32.add(nz, nz)
  d = F32.mul(nz, 2.0)
  U32.xor(U32.xor(F32.bits(a), F32.bits(b)), U32.xor(F32.bits(c), F32.bits(d)))

def main() -> IO(Unit):
  IO.print(U32.show(f_chain(1.5, 2.25)) ++ " " ++ U32.show(f_neg_zero()))
''',
    ),
    # ------------------------------------------------------------------
    # 4. Unboxed & boxed Bool branch fast-path
    # ------------------------------------------------------------------
    (
        "w2b_bool_boxed_and_unboxed",
        r'''import Base

type BBox is Data:
  BB{b: Bool, v: U32}

def choose_u(b: Bool, x: U32, y: U32) -> U32:
  match b:
    case False{}: x
    case True{}: y

def choose_rev(b: Bool, x: U32, y: U32) -> U32:
  match b:
    case True{}: y
    case False{}: x

def eval_box(bx: BBox) -> U32:
  match bx:
    case BB{+b, +v}:
      U32.add(choose_u(b, v, U32.mul(v, 3)), choose_rev(b, U32.add(v, 1), U32.add(v, 2)))

def main() -> IO(Unit):
  +t_unbox : Bool = F32.is_lt(1.0, 2.0)
  +f_unbox : Bool = F32.is_lt(2.0, 1.0)
  r1 = U32.add(choose_u(t_unbox, 10, 20), choose_u(f_unbox, 30, 40))
  r2 = U32.add(choose_rev(t_unbox, 10, 20), choose_rev(f_unbox, 30, 40))
  r3 = U32.add(eval_box(BB{True{}, 7}), eval_box(BB{False{}, 7}))
  r4 = U32.add(eval_box(BB{t_unbox, 9}), eval_box(BB{f_unbox, 9}))
  IO.print(U32.show(r1) ++ " " ++ U32.show(r2) ++ " " ++ U32.show(r3) ++ " " ++ U32.show(r4))
''',
    ),
    # ------------------------------------------------------------------
    # 5. Sound post-DCE sarl (asr) with boundary values & live intermediate uses
    # ------------------------------------------------------------------
    (
        "w2b_asr_boundaries_and_live",
        r'''import Base

def sel(c: Bool, a: U32, b: U32) -> U32:
  match c:
    case True{}: a
    case False{}: b

def asr8(+v: U32) -> U32:
  s1 = U32.shrn(v, 8n)
  neg = U32.is_ne(U32.shrn(v, 31n), 0)
  m = sel(neg, 4278190080, 0)
  U32.or(s1, m)

def asr1(+v: U32) -> U32:
  s1 = U32.shrn(v, 1n)
  neg = U32.is_ne(U32.shrn(v, 31n), 0)
  m = sel(neg, 2147483648, 0)
  U32.or(s1, m)

def asr31(+v: U32) -> U32:
  s1 = U32.shrn(v, 31n)
  neg = U32.is_ne(U32.shrn(v, 31n), 0)
  m = sel(neg, 4294967294, 0)
  U32.or(s1, m)

# Intermediate s1 AND m are BOTH live after the or!
def asr8_live(+v: U32) -> U32:
  +s1 = U32.shrn(v, 8n)
  neg = U32.is_ne(U32.shrn(v, 31n), 0)
  +m = sel(neg, 4278190080, 0)
  res = U32.or(s1, m)
  U32.xor(res, U32.add(s1, m))

def main() -> IO(Unit):
  a = U32.xor(U32.xor(asr8(0), asr8(1)), U32.xor(asr8(2147483647), U32.xor(asr8(2147483648), asr8(4294967295))))
  b = U32.xor(U32.xor(asr1(0), asr1(2147483647)), U32.xor(asr1(2147483648), asr1(4294967295)))
  c = U32.xor(U32.xor(asr31(0), asr31(2147483647)), U32.xor(asr31(2147483648), asr31(4294967295)))
  d = U32.xor(asr8_live(2147483648), asr8_live(123456))
  IO.print(U32.show(a) ++ " " ++ U32.show(b) ++ " " ++ U32.show(c) ++ " " ++ U32.show(d))
''',
    ),
]


def run_upstream(src: Path) -> str:
    r = subprocess.run([str(BUN), str(ROOT / "bend2/main.ts"), str(src)],
                       capture_output=True, text=True, timeout=60)
    if r.returncode != 0:
        return f"UP_ERR({r.returncode}): {r.stderr.strip()[:200]}"
    return r.stdout.strip()


def run_x86(api: Path, src: Path, tag: str) -> str:
    obj = TMP_ROOT / f"{tag}.o"
    exe = TMP_ROOT / f"{tag}.exe"
    try:
        r = subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api), str(src), str(obj)],
                           capture_output=True, text=True, timeout=90)
        if r.returncode != 0:
            return f"EMIT_ERR({r.returncode}): {r.stderr.strip()[:200]}"
        r2 = subprocess.run([CC, "-no-pie", str(obj), str(RT), "-pthread", "-lm", "-o", str(exe)],
                            capture_output=True, text=True, timeout=30)
        if r2.returncode != 0:
            return f"LINK_ERR({r2.returncode}): {r2.stderr.strip()[:200]}"
        r3 = subprocess.run([str(exe)], capture_output=True, text=True, timeout=30)
        if r3.returncode != 0:
            return f"RUN_ERR({r3.returncode}): {r3.stderr.strip()[:200]}"
        return r3.stdout.strip()
    finally:
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)


def main():
    cand_api = Path(sys.argv[1])
    TMP_ROOT.mkdir(parents=True, exist_ok=True)
    failures = []
    for name, code in CASES:
        src = TMP_ROOT / f"{name}.bend"
        src.write_text(code)
        up = run_upstream(src)
        p205 = run_x86(BASE_API, src, f"{name}.p205")
        cand = run_x86(cand_api, src, f"{name}.cand")
        ok = (up == p205 == cand) and not up.startswith("UP_ERR")
        status = "PASS" if ok else "FAIL"
        print(f"[{name}] {status}", flush=True)
        print(f"  upstream : {up}", flush=True)
        print(f"  phase205 : {p205}", flush=True)
        print(f"  w2b_a    : {cand}", flush=True)
        if not ok:
            failures.append((name, up, p205, cand))
        src.unlink(missing_ok=True)
    if failures:
        print(f"\nTIER-2 ADVERSARIAL AUDIT FAILED ({len(failures)}/{len(CASES)} failures)!")
        sys.exit(1)
    print(f"\nALL {len(CASES)} TIER-2 ADVERSARIAL DIFFERENTIAL TESTS PASSED!")


if __name__ == "__main__":
    main()
