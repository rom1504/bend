#!/usr/bin/env python3
"""Tier-2 Adversarial & Boundary Differential Test Suite for Track C:
  - AGY-W2-ROREC (apply_rorec.py)
  - AGY-W2-DPLOOP (apply_dp_loop.py)

Requires bit-exact stdout across:
  1. Upstream Bend (bun /home/ai/bend2_agy/bend2/main.ts)
  2. Phase 205 hosted x86 API (api-base/api.mjs)
  3. Track C candidate hosted x86 API (arg 1)
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
TMP_ROOT = ROOT / "selfhost/build/agy/tier2_audit_c/adv_tmp"

CASES = [
    # ------------------------------------------------------------------
    # 1. ROREC: Nested RoBin on RHS without RoRec (%edx clobber bug!)
    # ------------------------------------------------------------------
    (
        "rorec_nested_rhs_bin",
        r'''import Base

type E is Data:
  ELeaf{}
  ELit{v: U32}
  EAdd{a: E, b: E}
  ESub{a: E, b: E}
  EOne{a: E}

def eval2(e: E, +x: U32) -> U32:
  match e:
    case ELeaf{}: U32.sub(100, U32.add(x, 7))
    case ELit{+v}: U32.add(v, U32.mul(v, 2))
    case EAdd{a, b}: U32.add(eval2(a, x), U32.add(x, 11))
    case ESub{a, b}: U32.sub(eval2(a, x), U32.sub(x, 3))
    case EOne{a}: U32.add(eval2(a, x), U32.mul(x, 5))

def eval1(e: E) -> U32:
  match e:
    case ELeaf{}: U32.add(10, U32.add(2, 3))
    case ELit{v}: U32.sub(100, U32.sub(v, 1))
    case EAdd{a, b}: U32.add(eval1(a), U32.add(eval1(b), 1))
    case ESub{a, b}: U32.sub(eval1(a), U32.add(10, 20))
    case EOne{a}: U32.add(eval1(a), U32.mul(3, 7))

def main() -> IO(Unit):
  +t1 : E = ELeaf{}
  +t2 : E = ELit{17}
  +t3 : E = EAdd{ELit{10}, ELeaf{}}
  +t4 : E = ESub{EAdd{ELit{50}, ELeaf{}}, ELit{1}}
  +t5 : E = EOne{ESub{ELit{80}, ELit{2}}}
  r1 = U32.add(eval2(t1, 5), eval2(t1, 9))
  r2 = U32.add(eval2(t2, 5), eval2(t2, 9))
  r3 = U32.add(eval2(t3, 5), eval2(t3, 9))
  r4 = U32.add(eval2(t4, 5), eval2(t4, 9))
  r5 = U32.add(eval2(t5, 5), eval2(t5, 9))
  s1 = U32.add(eval1(t1), eval1(t1))
  s2 = U32.add(eval1(t2), eval1(t2))
  s3 = U32.add(eval1(t3), eval1(t3))
  s4 = U32.add(eval1(t4), eval1(t4))
  s5 = U32.add(eval1(t5), eval1(t5))
  IO.print(U32.show(r1) ++ " " ++ U32.show(r2) ++ " " ++ U32.show(r3) ++ " " ++ U32.show(r4) ++ " " ++ U32.show(r5) ++ " | " ++ U32.show(s1) ++ " " ++ U32.show(s2) ++ " " ++ U32.show(s3) ++ " " ++ U32.show(s4) ++ " " ++ U32.show(s5))
''',
    ),
    # ------------------------------------------------------------------
    # 2. ROREC: Exact budget boundaries 254, 255, 256, 257, 258 + internal 0x82 + reuse
    # ------------------------------------------------------------------
    (
        "rorec_depth_255_256_257_and_reuse",
        r'''import Base

type Chain is Data:
  CZ{}
  CS{next: Chain}
  CB{l: Chain, r: Chain}

def csum(c: Chain, +x: U32) -> U32:
  match c:
    case CZ{}: x
    case CS{n}: U32.add(csum(n, x), 1)
    case CB{l, r}: U32.add(csum(l, x), csum(r, x))

# Non-certified observer (uses U32.inc) to verify tree is intact after csum calls
def check_depth(c: Chain) -> U32:
  match c:
    case CZ{}: 0
    case CS{n}: U32.inc(check_depth(n))
    case CB{l, r}: U32.add(check_depth(l), check_depth(r))

def mk_chain(+n: Nat, acc: Chain) -> Chain:
  match n:
    case 0n: acc
    case 1n+p: mk_chain(p, CS{acc})

def main() -> IO(Unit):
  +c254 = mk_chain(254n, CZ{})
  +c255 = mk_chain(255n, CZ{})
  +c256 = mk_chain(256n, CZ{})
  +c257 = mk_chain(257n, CZ{})
  +c258 = mk_chain(258n, CZ{})
  # Shared internal 0x82 node inside a depth-257 chain (triggers bailout with internal 0x82!)
  +mid = mk_chain(128n, CZ{})
  +dag_deep = mk_chain(128n, CB{mid, mid})
  a = U32.add(csum(c254, 10), check_depth(c254))
  b = U32.add(csum(c255, 10), check_depth(c255))
  c = U32.add(csum(c256, 10), check_depth(c256))
  d = U32.add(csum(c257, 10), check_depth(c257))
  e = U32.add(csum(c258, 10), check_depth(c258))
  f = U32.add(csum(dag_deep, 7), U32.add(csum(dag_deep, 9), check_depth(dag_deep)))
  IO.print(U32.show(a) ++ " " ++ U32.show(b) ++ " " ++ U32.show(c) ++ " " ++ U32.show(d) ++ " " ++ U32.show(e) ++ " " ++ U32.show(f))
''',
    ),
    # ------------------------------------------------------------------
    # 3. ROREC: Swapped non-commutative Sub(b,a), U32.max constants, unused x,
    #    default wildcard arm, dropped field, duplicated field, modified x, erased field
    # ------------------------------------------------------------------
    (
        "rorec_adt_edge_cases",
        r'''import Base

type Sw is Data:
  SZ{}
  SL{v: U32}
  SSub{a: Sw, b: Sw}
  SDrop{a: Sw, b: Sw}
  SDup{a: Sw}
  SExtra{v: U32}

# Swapped Sub(b, a) + U32.max literal constant + default wildcard arm + dropped/duped fields
def eval_sw(e: Sw, +x: U32) -> U32:
  match e:
    case SZ{}: 4294967295
    case SL{v}: U32.sub(v, x)
    case SSub{a, b}: U32.sub(eval_sw(b, x), eval_sw(a, x))
    case SDrop{a, b}: eval_sw(a, x)
    case SDup{+a}: U32.add(eval_sw(a, x), eval_sw(a, x))
    case _: 123456789

# Modified x in recursive call -> must decline certification and still work
def eval_modx(e: Sw, +x: U32) -> U32:
  match e:
    case SZ{}: x
    case SL{v}: U32.add(v, x)
    case SSub{a, b}: U32.sub(eval_modx(a, U32.add(x, 1)), eval_modx(b, U32.add(x, 2)))
    case SDrop{a, b}: eval_modx(a, U32.mul(x, 3))
    case SDup{a}: eval_modx(a, U32.xor(x, 7))
    case SExtra{v}: U32.add(v, x)

# ADT with an erased field -> must decline certification and still work
type Er is Data:
  ErZ{}
  ErN{-tag: U32, a: Er}

def eval_er(e: Er) -> U32:
  match e:
    case ErZ{}: 5
    case ErN{tag, a}: U32.add(eval_er(a), 1)

def main() -> IO(Unit):
  +t1 : Sw = SSub{SL{10}, SL{3}}
  +t2 : Sw = SDrop{SDup{SSub{SZ{}, SL{4294967290}}}, SExtra{99}}
  +t3 : Sw = SSub{SExtra{7}, SL{2}}
  +t4 : Sw = SExtra{42}
  +er : Er = ErN{1, ErN{2, ErZ{}}}
  r1 = U32.add(eval_sw(t1, 4), eval_sw(t1, 4294967295))
  r2 = U32.add(eval_sw(t2, 3), eval_sw(t2, 0))
  r3 = U32.add(eval_sw(t3, 5), eval_sw(t4, 5))
  r4 = U32.add(eval_modx(t1, 10), eval_modx(t2, 10))
  r5 = U32.add(eval_er(er), eval_er(er))
  IO.print(U32.show(r1) ++ " " ++ U32.show(r2) ++ " " ++ U32.show(r3) ++ " " ++ U32.show(r4) ++ " " ++ U32.show(r5))
''',
    ),
    # ------------------------------------------------------------------
    # 4. DPLOOP: j + n U32 overflow, U32.max cell wraparound, match/mismatch at 0 and n-1,
    #    shared (0x84 RFC) arrays & aliasing fallback
    # ------------------------------------------------------------------
    (
        "dploop_adversarial_tier2",
        r'''import Base

type Dp is Type:
  Dp{a: Array<U32>, b: Array<U32>, prev: Array<U32>, cur: Array<U32>}

def b2u(b: Bool) -> U32:
  match b:
    case False{}: 0
    case True{}: 1

def umin.go(x: U32, y: U32, lt: Bool) -> U32:
  match lt:
    case True{}: x
    case False{}: y

def umin(+x: U32, +y: U32) -> U32:
  umin.go(x, y, U32.is_lt(x, y))

def cell.f4(+j: U32, cost: U32, diag: U32, up: U32, a: Array<U32>,
            b: Array<U32>, prev: Array<U32>, r: Array<U32> & U32) -> Dp:
  (cur, left) = r
  v = umin(umin(U32.inc(up), U32.inc(left)), U32.add(diag, cost))
  Dp{a, b, prev, cur[U32.inc(j)] <- v}

def cell.f3(+j: U32, cost: U32, diag: U32, a: Array<U32>, b: Array<U32>,
            cur: Array<U32>, r: Array<U32> & U32) -> Dp:
  (prev, up) = r
  cell.f4(j, cost, diag, up, a, b, prev, Array.get(U32, cur, j))

def cell.f2(+j: U32, cost: U32, a: Array<U32>, b: Array<U32>, cur: Array<U32>,
            r: Array<U32> & U32) -> Dp:
  (prev, diag) = r
  cell.f3(j, cost, diag, a, b, cur, Array.get(U32, prev, U32.inc(j)))

def cell.f1(+j: U32, ai: U32, a: Array<U32>, prev: Array<U32>, cur: Array<U32>,
            r: Array<U32> & U32) -> Dp:
  (b, bj) = r
  cell.f2(j, b2u(U32.is_ne(ai, bj)), a, b, cur, Array.get(U32, prev, j))

def cell(+j: U32, ai: U32, st: Dp) -> Dp:
  Dp{a, b, prev, cur} = st
  cell.f1(j, ai, a, prev, cur, Array.get(U32, b, j))

def row(+n: Nat, +j: U32, +ai: U32, st: Dp) -> Dp:
  match n:
    case 0n:
      Dp{a, b, prev, cur} = st
      Dp{a, b, cur, prev}
    case 1n+q:
      row(q, U32.inc(j), ai, cell(j, ai, st))

def hash_arr.one(+k: U32, acc: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (arr, v) = r
  (arr, U32.xor(U32.mul(acc, 1664525), U32.add(v, k)))

def hash_arr.go(+n: Nat, +k: U32, r: Array<U32> & U32) -> U32:
  match n:
    case 0n:
      (arr, acc) = r
      acc
    case 1n+q:
      (arr, acc) = r
      hash_arr.go(q, U32.inc(k), hash_arr.one(k, acc, Array.get(U32, arr, k)))

def hash_dp(+sz: Nat, st: Dp) -> U32:
  Dp{a, b, prev, cur} = st
  h1 = hash_arr.go(sz, 0, (prev, 17))
  h2 = hash_arr.go(sz, 0, (cur, 31))
  U32.xor(U32.mul(h1, 2654435761), h2)

def test_j_overflow() -> U32:
  a = [0 : U32*8n]
  b = [1 : U32*8n]
  b = b[0] <- 7
  b = b[7] <- 9
  prev = [2 : U32*8n]
  prev = prev[2] <- 4294967295
  cur = [3 : U32*8n]
  # j = 4294967290, n = 10 -> j + n overflows U32.max!
  hash_dp(8n, row(10n, 4294967290, 7, Dp{a, b, prev, cur}))

def test_j_max_one() -> U32:
  a = [0 : U32*8n]
  b = [5 : U32*8n]
  prev = [4 : U32*8n]
  cur = [6 : U32*8n]
  # j = 4294967295, n = 1 -> j + n == 4294967296 > 0xffffffff!
  hash_dp(8n, row(1n, 4294967295, 5, Dp{a, b, prev, cur}))

def test_u32max_cells() -> U32:
  # All combinations of 0, 1, 0xfffffffe, 0xffffffff in prev/cur + match at 0 and last
  a = [0 : U32*8n]
  b = [0 : U32*8n]
  b = b[0] <- 77
  b = b[1] <- 88
  b = b[2] <- 77
  b = b[3] <- 99
  b = b[4] <- 77
  prev = [0 : U32*16n]
  prev = prev[0] <- 4294967295
  prev = prev[1] <- 4294967295
  prev = prev[2] <- 4294967294
  prev = prev[3] <- 0
  prev = prev[4] <- 4294967295
  prev = prev[5] <- 4294967294
  cur = [0 : U32*16n]
  cur = cur[0] <- 4294967295
  hash_dp(8n, row(5n, 0, 77, Dp{a, b, prev, cur}))

def test_exact_bounds_and_mismatch() -> U32:
  # Match/mismatch at index 0 and last index (n-1), different array sizes (b=8, prev=16, cur=32)
  a = [0 : U32*8n]
  b = [11 : U32*8n]
  b = b[0] <- 99
  b = b[7] <- 99
  prev = [2 : U32*16n]
  prev = prev[0] <- 4294967295
  prev = prev[8] <- 4294967294
  cur = [3 : U32*32n]
  cur = cur[0] <- 0
  # j = 0, n = 8: exact b_size == j + n == 8, prev_size == 16 > 8, cur_size == 32 > 8 (fast path!)
  hash_dp(12n, row(8n, 0, 99, Dp{a, b, prev, cur}))

def main() -> IO(Unit):
  t1 = test_j_overflow()
  t2 = test_j_max_one()
  t3 = test_u32max_cells()
  t4 = test_exact_bounds_and_mismatch()
  IO.print(U32.show(t1) ++ " " ++ U32.show(t2) ++ " " ++ U32.show(t3) ++ " " ++ U32.show(t4))
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
        print(f"  track_c  : {cand}", flush=True)
        if not ok:
            failures.append((name, up, p205, cand))
        src.unlink(missing_ok=True)
    if failures:
        print(f"\nTIER-2 ADVERSARIAL AUDIT FAILED ({len(failures)}/{len(CASES)} failures)!")
        sys.exit(1)
    print(f"\nALL {len(CASES)} TIER-2 ADVERSARIAL DIFFERENTIAL TESTS PASSED!")


if __name__ == "__main__":
    main()
