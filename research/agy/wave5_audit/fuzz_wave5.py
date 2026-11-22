#!/usr/bin/env python3
"""Wave 5B Track W5B-V1 — Adversarial Differential Fuzzer for Wave 5A Unified.

Generates 90 deterministic, well-typed adversarial Bend programs (15 per family
across 6 Wave 5A families) targeting every new Wave 5A compiler pass:
  - Family 11 (`11_arity64_direct`): Arity 33..64 direct-style scalar/float/mixed,
    tail-rec + non-tail-rec, nested calls, stack-argument ordering verification.
  - Family 12 (`12_nat_succ_edge`): Inline `P111_SPECIAL_SUCC` (`1n+j`) edge cases:
    0n, 1n, U32 max + 1n (>2^32), nested `1n+(1n+j)`, Nat match + `1n+j` in loops,
    thunked/higher-order Nat passed to `1n+j`, doubling toward large Nats.
  - Family 13 (`13_lcu_product`): Loop-Carried Product Unboxing (`w5_lcu_selected`):
    1-level & 2-level nested products, mismatched ctor triggering `fbSym` fallback,
    escaping product (`P113DResult`), product containing mutated `Array<U32>`,
    multi-`P113DAgain` branches (same ctor vs mixed ctors), mixed U32/F32/Bool fields.
  - Family 14 (`14_peel_cmov_sink`): 2-step tiny self-rec loop peeling (`w5_expand_peel`)
    at 0, 1, 2, 3, 4, 7, 100 iters, loop-counter sinking (`w5_sink_body`),
    2-level & 3-level `cmov` diamonds (aliased dst/src, edge U32 cmps), exit-block rotation.
  - Family 15 (`15_bce_inv_min`): `inv_base + min(x, inv_k)` BCE & U32 wraparound torture:
    0xFFFFFFFF, 0x80000000+0x80000000, base>mask, k>mask, base+k>mask, base+k wrap<mask,
    both `U32.is_lt` and `U32.is_le`, array reads AND writes with OOB checks.
  - Family 16 (`16_xmm_gpr_peep`): `w5_xmm_fold`, `w5_gpr_peep`, `subq $1; testq`,
    high-param (>8) F32/GPR regalloc, IEEE-754 edge values (NaN, -0.0, +0.0, subnormals,
    Inf), 3-way swaps, non-commutative `subl`, `xor 1; xor 1`, `imull $3`, and
    Patricia-trie `p113k_join` / `X186FactTrie` CSE stress.

Asserts bit-exact stdout equality between:
  1. Upstream Bend (`bun /home/ai/bend2_agy/bend2/main.ts` via `locked_bun.sh`)
  2. Wave 5A Unified (`wave5a_unified/api.mjs` + `unified/runtime-agy.o`)
  3. On ANY mismatch, also isolates against `wave2_unified/api.mjs`!

All work is pinned to CPUs 0,1,4,5 and Node runs via `locked_node.sh`.
Temp `.o`/`.exe` files are deleted immediately to keep disk footprint tiny.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import random
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
BATCH_EMIT = ROOT / "research/agy/wave3_fuzz/batch_emit.mjs"

W5A_API = ROOT / "selfhost/build/agy/wave5a_unified/api.mjs"
W2_API = ROOT / "selfhost/build/agy/wave2_unified/api.mjs"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
WORK_DIR = ROOT / "selfhost/build/agy/wave5_fuzz/run_tmp"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]
CPU_PIN = ["taskset", "-c", "0,1,4,5"]

DYN_ZERO = """
def dyn_zero_go(n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: dyn_zero_go(p, U32.and(acc, 0))

def dyn_zero() -> U32:
  dyn_zero_go(U32.to_nat(300000), 0)
"""

COMMON_HELPERS = """
def b2u(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0

def f32_canon_go(x: F32, is_nan: Bool) -> U32:
  match is_nan:
    case True{}: 2143289344
    case False{}: F32.bits(x)

def f32_cbits(+x: F32) -> U32:
  f32_canon_go(x, F32.is_ne(x, x))
"""


# =============================================================================
# Family 11: Arity 33..64 Direct-Style Functions (W5-R3)
# =============================================================================
def gen_family11_arity64_direct(rng: random.Random, idx: int) -> str:
    # Deterministic arities covering 33, 34, 36, 40, 44, 48, 52, 56, 60, 64
    arities = [33, 34, 35, 38, 40, 42, 46, 48, 50, 54, 56, 58, 60, 62, 64]
    arity = arities[idx % len(arities)]
    mode = idx % 3  # 0: tail-rec U32, 1: mixed U32+F32+Bool tail-rec, 2: non-tail nested high-arity

    if mode == 0:
        # Tail-recursive function with `arity` params: (n: Nat, +p0..+p_{k-1}: U32)
        k = arity - 1
        pnames = [f"p{i}" for i in range(k)]
        sig = ", ".join(["n: Nat"] + [f"+{p}: U32" for p in pnames])
        # Non-commutative weighted hash of every parameter (catches ANY stack slot swap!)
        h_expr = "0"
        for i, p in enumerate(pnames):
            w = (i * 2 + 3)
            h_expr = f"U32.xor(U32.mul({h_expr}, 31), U32.add(U32.mul({p}, {w}), {i + 7}))"
        # Cyclic permutation + mixing in tail-rec step so every stack slot moves!
        next_args = []
        for i in range(k):
            a = pnames[i]
            b = pnames[(i + 1) % k]
            c = pnames[(i + 7) % k]
            if i % 3 == 0:
                next_args.append(f"U32.add({a}, U32.xor({b}, {i + 1}))")
            elif i % 3 == 1:
                next_args.append(f"U32.sub({b}, U32.and({c}, 255))")
            else:
                next_args.append(f"U32.xor({c}, U32.mul({a}, 3))")
        iters = rng.randint(4, 15)
        init_vals = [f"U32.add(z, {rng.randint(1, 50000)})" for _ in range(k)]
        return f"""import Base
{DYN_ZERO}
def wide_loop({sig}) -> U32:
  match n:
    case 0n: {h_expr}
    case 1n+q: wide_loop(q, {", ".join(next_args)})

def main() -> IO(Unit):
  +z = dyn_zero()
  +res = wide_loop(U32.to_nat(U32.add(z, {iters})), {", ".join(init_vals)})
  IO.print(U32.show(res))
"""

    elif mode == 1:
        # Mixed U32 / F32 / Bool tail-rec with `arity` params
        k = arity - 1
        pnames = [f"p{i}" for i in range(k)]
        types = []
        for i in range(k):
            if i % 4 == 1:
                types.append("F32")
            elif i % 7 == 2:
                types.append("Bool")
            else:
                types.append("U32")
        sig = ", ".join(["n: Nat"] + [f"+{p}: {t}" for p, t in zip(pnames, types)])
        h_expr = "17"
        for i, (p, t) in enumerate(zip(pnames, types)):
            if t == "F32":
                term = f"F32.bits({p})"
            elif t == "Bool":
                term = f"U32.add(Bool.to_u32({p}), {i + 11})"
            else:
                term = f"U32.mul({p}, {i * 2 + 5})"
            h_expr = f"U32.xor(U32.mul({h_expr}, 33), {term})"
        next_args = []
        for i, (p, t) in enumerate(zip(pnames, types)):
            if t == "F32":
                next_args.append(f"F32.add({p}, 0.25)")
            elif t == "Bool":
                next_args.append(f"Bool.not({p})")
            else:
                prev_u = pnames[0] if types[0] == "U32" else p
                next_args.append(f"U32.add(U32.xor({p}, {prev_u}), {i + 3})")
        init_vals = []
        for i, t in enumerate(types):
            if t == "F32":
                init_vals.append(f"U32.to_f32(U32.add(z, {(i + 1) * 3}))")
            elif t == "Bool":
                init_vals.append("True{}" if (i % 2 == 0) else "False{}")
            else:
                init_vals.append(f"U32.add(z, {rng.randint(1, 9999)})")
        iters = rng.randint(3, 12)
        return f"""import Base
{DYN_ZERO}
{COMMON_HELPERS}
def wide_mixed({sig}) -> U32:
  match n:
    case 0n: {h_expr}
    case 1n+q: wide_mixed(q, {", ".join(next_args)})

def main() -> IO(Unit):
  +z = dyn_zero()
  +res = wide_mixed(U32.to_nat(U32.add(z, {iters})), {", ".join(init_vals)})
  IO.print(U32.show(res))
"""

    else:
        # Non-tail-recursive nested high-arity calls (arity params passed across 2 functions)
        k = arity
        pnames = [f"p{i}" for i in range(k)]
        sig = ", ".join([f"+{p}: U32" for p in pnames])
        h1 = "7"
        for i, p in enumerate(pnames):
            h1 = f"U32.xor(U32.mul({h1}, 31), U32.add({p}, {i * 13 + 1}))"
        # Rotate args in caller -> callee
        rot_args = [pnames[(i + 5) % k] for i in range(k)]
        rev_args = [f"U32.add({pnames[k - 1 - i]}, {i + 1})" for i in range(k)]
        init_vals = [f"U32.add(z, {rng.randint(1, 65535)})" for _ in range(k)]
        return f"""import Base
{DYN_ZERO}
def leaf_wide({sig}) -> U32:
  {h1}

def mid_wide({sig}) -> U32:
  +a = leaf_wide({", ".join(rot_args)})
  +b = leaf_wide({", ".join(rev_args)})
  U32.xor(U32.mul(a, 17), b)

def main() -> IO(Unit):
  +z = dyn_zero()
  +res = mid_wide({", ".join(init_vals)})
  IO.print(U32.show(res))
"""


# =============================================================================
# Family 12: Inline `P111_SPECIAL_SUCC` (`1n+j`) Edge Cases (W5-R4)
# =============================================================================
def gen_family12_nat_succ_edge(rng: random.Random, idx: int) -> str:
    mode = idx % 5
    if mode == 0:
        # Nat match + 1n+j inside tight loops (merkle/counter style) + 0n/1n/2n boundaries
        iters = rng.choice([0, 1, 2, 3, 7, 15, 64, 255])
        base_off = rng.choice([0, 1, 2, 100, 65535])
        return f"""import Base
{DYN_ZERO}
def count_up(n: Nat, +acc: Nat, +h: U32) -> U32:
  match n:
    case 0n: U32.xor(h, U32.from_nat(acc))
    case 1n+p:
      count_up(p, 1n+(1n+acc), U32.xor(U32.mul(h, 31), U32.from_nat(1n+acc)))

def main() -> IO(Unit):
  +z = dyn_zero()
  +r0 = count_up(0n, 0n, z)
  +r1 = count_up(1n, 1n, r0)
  +r2 = count_up(U32.to_nat(U32.add(z, {iters})), U32.to_nat(U32.add(z, {base_off})), r1)
  IO.print(U32.show(r2))
"""
    elif mode == 1:
        # Large Nat crossing 2^32 boundary: U32.to_nat(4294967295) + 1n + 1n + ...
        steps = rng.randint(3, 18)
        return f"""import Base
{DYN_ZERO}
def add_succs(k: Nat, x: Nat) -> Nat:
  match k:
    case 0n: x
    case 1n+p: add_succs(p, 1n+x)

def peel_k(k: Nat, +x: Nat, +acc: U32) -> U32:
  match k:
    case 0n: U32.xor(acc, U32.from_nat(x))
    case 1n+kp:
      match x:
        case 0n: acc
        case 1n+xp: peel_k(kp, xp, U32.add(U32.mul(acc, 13), U32.from_nat(xp)))

def main() -> IO(Unit):
  +z = dyn_zero()
  big0 = U32.to_nat(U32.add(z, 4294967295))
  big1 = add_succs(U32.to_nat(U32.add(z, {steps})), big0)
  +r1 = peel_k(U32.to_nat(U32.add(z, {steps + 2})), big1, 7)
  big2 = add_succs(3n, U32.to_nat(U32.add(z, 4294967295)))
  +r2 = peel_k(5n, big2, r1)
  IO.print(U32.show(r2))
"""
    elif mode == 2:
        # Thunked / higher-order / closure-returned Nat passed to `1n+j`
        k1 = rng.randint(1, 40)
        k2 = rng.randint(1, 40)
        return f"""import Base
{DYN_ZERO}
def apply_nat(f: Nat -> Nat, x: Nat) -> Nat:
  1n+f(1n+x)

def mk_adder(k: Nat) -> Nat -> Nat:
  match k:
    case 0n: x => x
    case 1n+p:
      g = mk_adder(p)
      x => 1n+g(x)

def choose_nat(b: Bool, a: Nat, c: Nat) -> Nat:
  match b:
    case True{{}}: 1n+a
    case False{{}}: 1n+(1n+c)

def main() -> IO(Unit):
  +z = dyn_zero()
  f = mk_adder(U32.to_nat(U32.add(z, {k1})))
  n1 = apply_nat(f, U32.to_nat(U32.add(z, {k2})))
  n2 = choose_nat(U32.is_eq(z, 0), n1, 0n)
  n3 = choose_nat(U32.is_ne(z, 0), 0n, n2)
  IO.print(U32.show(U32.from_nat(1n+n3)))
"""
    elif mode == 3:
        # Large Nat crossing 2^32 with triple nested 1n+j in loop
        doublings = rng.randint(33, 44)
        return f"""import Base
{DYN_ZERO}
def mul_add_loop(n: Nat, +x: Nat, +acc: U32) -> U32:
  match n:
    case 0n: U32.xor(acc, U32.from_nat(x))
    case 1n+p:
      mul_add_loop(p, 1n+(1n+(1n+x)), U32.xor(U32.mul(acc, 17), U32.from_nat(1n+(1n+(1n+x)))))

def main() -> IO(Unit):
  +z = dyn_zero()
  base = U32.to_nat(U32.sub(4294967295, U32.add(z, {doublings})))
  +r = mul_add_loop(U32.to_nat(U32.add(z, {doublings + 20})), base, 13)
  IO.print(U32.show(r))
"""
    else:
        # Conditional `1n+j` inside branchy Nat recursion (merkle-like split + accumulate)
        depth = rng.randint(5, 10)
        return f"""import Base
{DYN_ZERO}
def pick_j(b: Bool, +j: Nat) -> Nat:
  match b:
    case True{{}}: 1n+j
    case False{{}}: 1n+(1n+j)

def pick_s(b: Bool, +s2: U32, +j: Nat) -> U32:
  match b:
    case True{{}}: U32.xor(s2, U32.from_nat(j))
    case False{{}}: U32.add(s2, U32.from_nat(1n+j))

def branch_nat(n: Nat, +j: Nat, +s: U32) -> U32:
  match n:
    case 0n: U32.xor(s, U32.from_nat(1n+j))
    case 1n+p:
      +s2 = U32.add(U32.mul(s, 1664525), 1013904223)
      +b = U32.is_eq(U32.and(s2, 1), 0)
      branch_nat(p, pick_j(b, j), pick_s(b, s2, j))

def main() -> IO(Unit):
  +z = dyn_zero()
  +r = branch_nat(U32.to_nat(U32.add(z, {depth * 12})), U32.to_nat(U32.add(z, 4294967290)), U32.add(z, 12345))
  IO.print(U32.show(r))
"""


# =============================================================================
# Family 13: Loop-Carried Product Unboxing (`w5_lcu_selected`, W5-R4)
# =============================================================================
def gen_family13_lcu_product(rng: random.Random, idx: int) -> str:
    mode = idx % 5
    iters = rng.randint(5, 35)
    seed_v = rng.randint(1, 50000)

    if mode == 0:
        # 2-level nested product (bfs-style Outer{Inner{a,b,c}, flag}) + escaping P113DResult
        return f"""import Base
{DYN_ZERO}
type Inner is Data:
  In{{+a: U32, +b: U32, +c: U32}}

type Outer is Data:
  Out{{inn: Inner, +flag: Bool, +k: U32}}

def lcu_loop(n: Nat, st: Outer) -> Outer:
  match n:
    case 0n: st
    case 1n+p:
      match st:
        case Out{{In{{a, b, c}}, flag, k}}:
          +a2 = U32.add(U32.xor(a, b), k)
          +b2 = U32.mul(U32.add(b, 3), 5)
          +c2 = U32.xor(c, U32.add(a2, b2))
          +f2 = Bool.not(flag)
          +k2 = U32.add(k, 1)
          lcu_loop(p, Out{{In{{a2, b2, c2}}, f2, k2}})

def read_outer(st: Outer) -> U32:
  match st:
    case Out{{In{{a, b, c}}, True{{}}, k}}: U32.xor(U32.add(a, b), U32.add(c, k))
    case Out{{In{{a, b, c}}, False{{}}, k}}: U32.xor(U32.sub(a, c), U32.mul(b, U32.add(k, 1)))

def mk_outer(+a: U32, +b: U32, +c: U32, +k: U32) -> Outer:
  Out{{In{{a, b, c}}, True{{}}, k}}

def main() -> IO(Unit):
  +z = dyn_zero()
  st0 = mk_outer(U32.add(z, {seed_v}), U32.add(z, 7), U32.add(z, 19), U32.add(z, 3))
  st1 = lcu_loop(U32.to_nat(U32.add(z, {iters})), st0)
  IO.print(U32.show(read_outer(st1)))
"""

    elif mode == 1:
        # Multi-constructor ADT: entry argument has MISMATCHED ctor triggering `fbSym` fallback!
        return f"""import Base
{DYN_ZERO}
type Box2 is Data:
  CtorA{{+x: U32, +y: U32}}
  CtorB{{+w: U32}}

def multi_loop(n: Nat, b: Box2) -> U32:
  match n:
    case 0n:
      match b:
        case CtorA{{x, y}}: U32.xor(U32.mul(x, 31), y)
        case CtorB{{w}}: U32.add(w, 777)
    case 1n+p:
      match b:
        case CtorA{{x, y}}: multi_loop(p, CtorA{{U32.add(x, y), U32.xor(y, 13)}})
        case CtorB{{w}}: multi_loop(p, CtorA{{U32.mul(w, 3), U32.add(w, 1)}})

def main() -> IO(Unit):
  +z = dyn_zero()
  +r1 = multi_loop(U32.to_nat(U32.add(z, {iters})), CtorA{{U32.add(z, {seed_v}), 5}})
  +r2 = multi_loop(U32.to_nat(U32.add(z, {iters})), CtorB{{U32.add(z, {seed_v})}})
  +r3 = multi_loop(0n, CtorB{{U32.add(z, 99)}})
  IO.print(U32.show(U32.xor(r1, U32.xor(U32.mul(r2, 17), r3))))
"""

    elif mode == 2:
        # Product containing mutated `Array<U32>` + 2-level nesting (`bfs` style)
        cls = rng.choice([3, 4, 5])
        mask = (1 << cls) - 1
        return f"""import Base
{DYN_ZERO}
type ArrSt is Data:
  ASt{{arr: Array<U32>, +idx: U32, +acc: U32}}

def arr_fin_more(more: Bool, +acc: U32, r: Array<U32> & U32) -> U32:
  match more r:
    case True{{}} Tuple{{arr2, v}}: U32.xor(acc, v)
    case False{{}} Tuple{{arr2, v}}: U32.add(acc, U32.mul(v, 3))

def arr_fin(ast: ArrSt, more: Bool) -> U32:
  match ast:
    case ASt{{arr, idx, acc}}:
      arr_fin_more(more, acc, arr[U32.and(idx, {mask})])

def arr_upd(+idx: U32, +acc: U32, more: Bool, r: Array<U32> & U32) -> ArrSt & Bool:
  (arr1, old) = r
  +i = U32.and(idx, {mask})
  +nv = U32.xor(U32.add(old, idx), 17)
  arr2 = arr1[i] <- nv
  +acc2 = U32.xor(U32.mul(acc, 31), nv)
  (ASt{{arr2, U32.add(idx, 3), acc2}}, Bool.not(more))

def arr_one(ast: ArrSt, more: Bool) -> ArrSt & Bool:
  match ast:
    case ASt{{arr, idx, acc}}:
      arr_upd(idx, acc, more, arr[U32.and(idx, {mask})])

def arr_step(n: Nat, st: ArrSt & Bool) -> U32:
  match n:
    case 0n:
      (ast, more) = st
      arr_fin(ast, more)
    case 1n+p:
      (ast, more) = st
      arr_step(p, arr_one(ast, more))

def main() -> IO(Unit):
  +z = dyn_zero()
  a0 = Array.new(U32, {cls}n, U32.add(z, {seed_v}))
  +res = arr_step(U32.to_nat(U32.add(z, {iters})), (ASt{{a0, U32.add(z, 1), 9}}, True{{}}))
  IO.print(U32.show(res))
"""

    elif mode == 3:
        # Multiple P113DAgain paths constructing the SAME product in different branches
        return f"""import Base
{DYN_ZERO}
type Quad is Data:
  Qd{{+a: U32, +b: U32, +c: U32, +d: U32}}

def next_quad(cond: Bool, +a: U32, +b: U32, +c: U32, +d: U32) -> Quad:
  match cond:
    case True{{}}: Qd{{U32.add(a, 3), U32.xor(b, c), U32.add(c, 1), d}}
    case False{{}}: Qd{{U32.xor(a, d), b, U32.sub(c, 2), U32.add(d, 5)}}

def multi_again(n: Nat, q: Quad) -> U32:
  match n:
    case 0n:
      match q:
        case Qd{{a, b, c, d}}: U32.xor(U32.add(a, b), U32.mul(c, U32.add(d, 1)))
    case 1n+p:
      match q:
        case Qd{{a, b, c, d}}:
          multi_again(p, next_quad(U32.is_eq(U32.and(a, 1), 0), a, b, c, d))

def main() -> IO(Unit):
  +z = dyn_zero()
  +res = multi_again(U32.to_nat(U32.add(z, {iters})), Qd{{U32.add(z, {seed_v}), 11, 29, 43}})
  IO.print(U32.show(res))
"""

    else:
        # Product with mixed F32 + U32 fields + nested Tuple
        return f"""import Base
{DYN_ZERO}
{COMMON_HELPERS}
type FSt is Data:
  FS{{+x: F32, +y: F32, +k: U32}}

def f_lcu(n: Nat, st: FSt) -> U32:
  match n:
    case 0n:
      match st:
        case FS{{x, y, k}}: U32.xor(U32.xor(f32_cbits(x), U32.mul(f32_cbits(y), 31)), k)
    case 1n+p:
      match st:
        case FS{{x, y, k}}:
          +x2 = F32.add(F32.mul(x, 0.5), y)
          +y2 = F32.sub(y, 0.125)
          f_lcu(p, FS{{x2, y2, U32.add(k, 7)}})

def main() -> IO(Unit):
  +z = dyn_zero()
  +r = f_lcu(U32.to_nat(U32.add(z, {iters})), FS{{U32.to_f32(U32.add(z, 3)), 1.25, U32.add(z, {seed_v})}})
  IO.print(U32.show(r))
"""


# =============================================================================
# Family 14: 2-Step Loop Peeling + Counter Sinking + Multi-Level `cmov` (W5-R1)
# =============================================================================
def gen_family14_peel_cmov_sink(rng: random.Random, idx: int) -> str:
    mode = idx % 3
    if mode == 0:
        # Tiny self-recursive callee peeled 2 steps, called with 0, 1, 2, 3, 4, 7, 100 iters!
        mul_c = rng.choice([3, 5, 17, 31, 131])
        add_c = rng.randint(1, 999)
        return f"""import Base
{DYN_ZERO}
def tiny_rep(n: Nat, +x: U32, +h: U32) -> U32:
  match n:
    case 0n: h
    case 1n+p: tiny_rep(p, x, U32.add(U32.mul(h, {mul_c}), U32.xor(x, {add_c})))

def call_all(k: Nat, +i: U32, +acc: U32) -> U32:
  match k:
    case 0n: acc
    case 1n+p:
      +cnt = U32.mod(i, 6)
      +h1 = tiny_rep(U32.to_nat(cnt), i, acc)
      call_all(p, U32.add(i, 1), h1)

def main() -> IO(Unit):
  +z = dyn_zero()
  +h0 = tiny_rep(0n, 7, U32.add(z, 1))
  +h1 = tiny_rep(1n, 11, h0)
  +h2 = tiny_rep(2n, 13, h1)
  +h3 = tiny_rep(3n, 17, h2)
  +h4 = tiny_rep(4n, 19, h3)
  +h100 = tiny_rep(U32.to_nat(U32.add(z, 100)), 23, h4)
  +hall = call_all(U32.to_nat(U32.add(z, 30)), z, h100)
  IO.print(U32.show(hall))
"""

    elif mode == 1:
        # Multi-level 2-level and 3-level `cmov` diamonds with edge U32 comparisons & aliased dst/src
        edges = [0, 1, 2, 2147483647, 2147483648, 4294967294, 4294967295]
        e1 = rng.choice(edges)
        e2 = rng.choice(edges)
        e3 = rng.choice(edges)
        iters = rng.randint(12, 40)
        return f"""import Base
{DYN_ZERO}
def pick_u(b: Bool, +t: U32, +f: U32) -> U32:
  match b:
    case True{{}}: t
    case False{{}}: f

def dia3(+x: U32, +y: U32, +a: U32, +b: U32, +c: U32, +d: U32) -> U32:
  +inner_t = pick_u(U32.is_le(y, {e2}), pick_u(U32.is_eq(U32.and(x, 1), 0), a, b), c)
  +inner_f = pick_u(U32.is_gt(x, {e3}), d, x)
  pick_u(U32.is_lt(x, {e1}), inner_t, inner_f)

def cmov_loop(n: Nat, +x: U32, +y: U32, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      +v = dia3(x, y, acc, x, y, U32.xor(x, y))
      +x2 = U32.add(U32.mul(x, 1664525), 1013904223)
      +y2 = U32.sub(y, 2147483647)
      cmov_loop(p, x2, y2, U32.xor(U32.mul(acc, 31), v))

def main() -> IO(Unit):
  +z = dyn_zero()
  +r = cmov_loop(U32.to_nat(U32.add(z, {iters})), U32.add(z, {e1}), U32.add(z, {e2}), 17)
  IO.print(U32.show(r))
"""

    else:
        # Product-array loop with tiny self-rec callee + loop-counter sinking + exit-block rotation
        cls = rng.choice([3, 4, 5])
        mask = (1 << cls) - 1
        iters = rng.randint(8, 32)
        return f"""import Base
{DYN_ZERO}
def rep_mix(k: Nat, +v: U32, +acc: U32) -> U32:
  match k:
    case 0n: acc
    case 1n+p: rep_mix(p, v, U32.xor(U32.mul(acc, 131), v))

def fold_arr(n: Nat, +i: U32, +acc: U32, r: Array<U32> & U32) -> U32:
  match n r:
    case 0n Tuple{{a, v}}: U32.xor(acc, v)
    case 1n+p Tuple{{a, v}}:
      +v0 = v
      +c = U32.and(v0, 3)
      +acc2 = rep_mix(U32.to_nat(c), v0, acc)
      a2 = a[U32.and(i, {mask})] <- U32.add(v0, 1)
      +i2 = U32.add(i, 1)
      fold_arr(p, i2, acc2, a2[U32.and(i2, {mask})])

def main() -> IO(Unit):
  +z = dyn_zero()
  a0 = Array.new(U32, {cls}n, U32.add(z, {rng.randint(0, 7)}))
  +r = fold_arr(U32.to_nat(U32.add(z, {iters})), z, 5, a0[U32.and(z, {mask})])
  IO.print(U32.show(r))
"""


# =============================================================================
# Family 15: `inv_base + min(x, inv_k)` BCE & U32 Wraparound Torture (W5-R1)
# =============================================================================
def gen_family15_bce_inv_min(rng: random.Random, idx: int) -> str:
    cls = rng.choice([3, 4, 5, 6])
    size = 1 << cls
    mask = size - 1
    # Explicit adversarial (base, k) pairs covering EVERY wraparound & boundary case!
    adversarial_pairs = [
        (0, mask),                        # exact fit: 0 + mask == mask
        (mask, 0),                        # exact fit: mask + 0 == mask
        (size // 2, size // 2 - 1),       # exact fit: half + (half-1) == mask
        (size // 2, size // 2),           # OOB by 1: base <= mask, k <= mask, base + k == size > mask!
        (mask, mask),                     # OOB: base <= mask, k <= mask, base + k > mask!
        (size, 0),                        # OOB: base > mask, k <= mask
        (0, size),                        # OOB: base <= mask, k > mask
        (4294967295, 1),                  # U32 wraparound: 0xFFFFFFFF + 1 == 0 <= mask!
        (4294967294, 3),                  # U32 wraparound: 0xFFFFFFFE + 3 == 1 <= mask!
        (2147483648, 2147483648),         # U32 wraparound: 0x80000000 + 0x80000000 == 0 <= mask!
        (2147483649, 2147483649),         # U32 wraparound: 0x80000001 + 0x80000001 == 2 <= mask!
        (4294967295, 4294967295),         # U32 wraparound: max + max == 0xFFFFFFFE
        (2, mask - 2),                    # exact fit
        (mask - 1, 2),                    # OOB by 1
        (1, 4294967295),                  # U32 wraparound: 1 + 0xFFFFFFFF == 0 <= mask!
    ]
    base_v, k_v = adversarial_pairs[idx % len(adversarial_pairs)]
    use_ule = (idx % 2 == 1)
    cmp_op = "U32.is_le" if use_ule else "U32.is_lt"
    iters = rng.randint(10, 28)

    return f"""import Base
{DYN_ZERO}
def pick_min(b: Bool, +x: U32, +k: U32) -> U32:
  match b:
    case True{{}}: x
    case False{{}}: k

def min_u32(+x: U32, +k: U32) -> U32:
  pick_min({cmp_op}(x, k), x, k)

def bce_loop(n: Nat, +base: U32, +k: U32, +x: U32, +acc: U32, r: Array<U32> & U32) -> U32:
  match n r:
    case 0n Tuple{{a, old}}: U32.xor(acc, old)
    case 1n+p Tuple{{a, old}}:
      +m = min_u32(x, k)
      +idx = U32.add(base, m)
      +old0 = old
      a2 = a[idx] <- U32.add(old0, 1)
      +x2 = U32.add(U32.mul(x, 1103515245), 12345)
      +idx2 = U32.add(base, min_u32(x2, k))
      bce_loop(p, base, k, x2, U32.xor(U32.mul(acc, 31), U32.add(old0, idx)), a2[idx2])

def fill_init(n: Nat, +i: U32, a: Array<U32>) -> Array<U32>:
  match n:
    case 0n: a
    case 1n+p: fill_init(p, U32.add(i, 1), a[i] <- U32.add(U32.mul(i, 7), 3))

def main() -> IO(Unit):
  +z = dyn_zero()
  a0 = fill_init({size}n, 0, Array.new(U32, {cls}n, 0))
  +b0 = U32.add(z, {base_v})
  +k0 = U32.add(z, {k_v})
  +idx0 = U32.add(b0, min_u32(z, k0))
  +r1 = bce_loop(U32.to_nat(U32.add(z, {iters})), b0, k0, z, 17, a0[idx0])
  IO.print(U32.show(r1))
"""


# =============================================================================
# Family 16: `w5_xmm_fold`, `w5_gpr_peep`, `subq $1; testq`, & Trie CSE (W5-R2, W5-C2)
# =============================================================================
def gen_family16_xmm_gpr_peep(rng: random.Random, idx: int) -> str:
    mode = idx % 3
    if mode == 0:
        # IEEE-754 F32 torture (NaN, -0.0, +0.0, subnormals, Inf) + high-param (>8) F32 loop (w5_xmm_fold)
        iters = rng.randint(6, 18)
        f32_edges = [
            "0.0",
            "F32.sub(0.0, 0.0)",
            "F32.mul(F32.sub(0.0, 1.0), 0.0)",    # -0.0
            "F32.div(1.0, 0.0)",                   # +Inf
            "F32.div(F32.sub(0.0, 1.0), 0.0)",     # -Inf
            "F32.div(0.0, 0.0)",                   # NaN
            "F32.div(F32.div(1.0, 100000000000000000000000000000.0), 100000000000000.0)",  # pos subnormal
            "F32.sub(0.0, F32.div(F32.div(1.0, 100000000000000000000000000000.0), 100000000000000.0))",  # neg subnormal
            "F32.mul(100000000000000000000.0, 1000000000000000000.0)",  # ~1e38 near FLT_MAX
            "1.0000001",
            "0.33333334",
            "F32.sub(0.0, 0.125)",
        ]
        # 10 carried F32 params (>8 params -> triggers W5-R2 high-param regalloc dispatch!)
        inits = [rng.choice(f32_edges) for _ in range(10)]
        return f"""import Base
{DYN_ZERO}
{COMMON_HELPERS}
def xmm_loop(n: Nat, +a0: F32, +a1: F32, +a2: F32, +a3: F32, +a4: F32, +a5: F32, +a6: F32, +a7: F32, +a8: F32, +a9: F32, +h: U32) -> U32:
  match n:
    case 0n:
      +h1 = U32.xor(U32.mul(h, 31), f32_cbits(a0))
      +h2 = U32.xor(U32.mul(h1, 31), f32_cbits(a1))
      +h3 = U32.xor(U32.mul(h2, 31), f32_cbits(a2))
      +h4 = U32.xor(U32.mul(h3, 31), f32_cbits(a3))
      +h5 = U32.xor(U32.mul(h4, 31), f32_cbits(a4))
      +h6 = U32.xor(U32.mul(h5, 31), f32_cbits(a5))
      +h7 = U32.xor(U32.mul(h6, 31), f32_cbits(a6))
      +h8 = U32.xor(U32.mul(h7, 31), f32_cbits(a7))
      +h9 = U32.xor(U32.mul(h8, 31), f32_cbits(a8))
      U32.xor(U32.mul(h9, 31), f32_cbits(a9))
    case 1n+p:
      +b0 = F32.add(a0, a1)
      +b1 = F32.sub(a1, a2)
      +b2 = F32.mul(a2, a3)
      +b3 = F32.add(F32.mul(a3, 0.5), a4)
      +b4 = F32.sub(a4, F32.mul(a5, 0.25))
      +b5 = F32.add(a5, a6)
      +b6 = F32.mul(a6, a7)
      +b7 = F32.sub(a7, a8)
      +b8 = F32.add(a8, a9)
      +b9 = F32.sqrt(F32.add(F32.mul(a9, a9), 0.25))
      xmm_loop(p, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, U32.xor(h, f32_cbits(b0)))

def main() -> IO(Unit):
  +z = dyn_zero()
  +r = xmm_loop(U32.to_nat(U32.add(z, {iters})), {", ".join(inits)}, U32.add(z, 41))
  IO.print(U32.show(r))
"""

    elif mode == 1:
        # Dense GPR peepholes (G1..G9): 3-way swaps, non-comm subl, xor 1; xor 1, imull $3, subq $1; testq
        iters = rng.randint(10, 40)
        s0 = rng.randint(1, 99999)
        s1 = rng.randint(1, 99999)
        return f"""import Base
{DYN_ZERO}
{COMMON_HELPERS}
def gpr_torture(n: Nat, +a: U32, +b: U32, +c: U32, +d: U32, +e: U32) -> U32:
  match n:
    case 0n: U32.xor(U32.add(a, b), U32.xor(c, U32.add(d, e)))
    case 1n+p:
      # Non-commutative subl + 3-way swap + double xor 1 + mul 3 + cmp/cmov
      +t1 = U32.sub(a, b)
      +t2 = U32.sub(b, a)
      +t3 = U32.add(U32.mul(c, 3), d)
      +flg = b2u(U32.is_lt(t1, t2))
      +flg2 = U32.xor(U32.xor(flg, 1), 1)
      +sel = Bool.pick(U32, U32.is_ne(flg2, 0), t1, t2)
      +a2 = U32.xor(b, sel)
      +b2 = U32.add(c, t3)
      +c2 = U32.sub(d, a)
      +d2 = U32.and(U32.add(e, 1), 65535)
      +e2 = U32.or(U32.add(t1, t2), flg2)
      gpr_torture(p, a2, b2, c2, d2, e2)

def main() -> IO(Unit):
  +z = dyn_zero()
  +r = gpr_torture(U32.to_nat(U32.add(z, {iters})), U32.add(z, {s0}), U32.add(z, {s1}), 17, 4294967295, 2147483648)
  IO.print(U32.show(r))
"""

    else:
        # Patricia-trie `p113k_join` & `X186FactTrie` CSE stress:
        # deeply branched if/else with 20+ locals and commutative + non-commutative repeated exprs
        s0 = rng.randint(1, 50000)
        return f"""import Base
{DYN_ZERO}
def trie_leaf(b: Bool, +t: U32, +f: U32) -> U32:
  match b:
    case True{{}}: t
    case False{{}}: f

def trie_arm(b: Bool, +x: U32, +y: U32, +a1: U32, +a2: U32, +s1: U32, +s2: U32, +m1: U32, +m2: U32) -> U32:
  match b:
    case True{{}}:
      +p1 = U32.add(a1, s1)
      +p2 = U32.sub(s1, a1)
      trie_leaf(U32.is_eq(U32.and(p1, 1), 0), U32.xor(U32.add(p1, m1), U32.add(y, x)), U32.add(U32.sub(p2, m2), U32.sub(x, y)))
    case False{{}}:
      +q1 = U32.add(a2, s2)
      +q2 = U32.sub(s2, a2)
      trie_leaf(U32.is_eq(U32.and(q1, 1), 0), U32.xor(U32.add(q1, m2), U32.sub(y, x)), U32.add(U32.sub(q2, m1), U32.add(x, y)))

def trie_cse_stress(+x: U32, +y: U32, +w: U32) -> U32:
  +a1 = U32.add(x, y)
  +a2 = U32.add(y, x)
  +s1 = U32.sub(x, y)
  +s2 = U32.sub(y, x)
  +m1 = U32.mul(a1, w)
  +m2 = U32.mul(w, a2)
  +u1 = U32.xor(s1, m1)
  +u2 = U32.xor(m2, s2)
  trie_arm(U32.is_lt(u1, u2), x, y, a1, a2, s1, s2, m1, m2)

def run_cse(n: Nat, +x: U32, +y: U32, +w: U32, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      +v = trie_cse_stress(x, y, w)
      run_cse(p, U32.add(x, 7), U32.xor(y, v), U32.add(w, 3), U32.xor(U32.mul(acc, 31), v))

def main() -> IO(Unit):
  +z = dyn_zero()
  +r = run_cse(U32.to_nat(U32.add(z, 25)), U32.add(z, {s0}), U32.add(z, 999), U32.add(z, 13), 5)
  IO.print(U32.show(r))
"""


FAMILIES = [
    ("11_arity64_direct", gen_family11_arity64_direct),
    ("12_nat_succ_edge", gen_family12_nat_succ_edge),
    ("13_lcu_product", gen_family13_lcu_product),
    ("14_peel_cmov_sink", gen_family14_peel_cmov_sink),
    ("15_bce_inv_min", gen_family15_bce_inv_min),
    ("16_xmm_gpr_peep", gen_family16_xmm_gpr_peep),
]


def run_upstream(src: Path) -> tuple[bool, str]:
    try:
        r = subprocess.run(
            [*CPU_PIN, "bash", str(LOCKED_BUN), str(src)],
            capture_output=True, text=True, timeout=65,
        )
        if r.returncode != 0:
            return False, f"UP_ERR({r.returncode}): {r.stderr.strip()[:240]}"
        return True, r.stdout
    except subprocess.TimeoutExpired:
        return False, "UP_TIMEOUT"


def batch_emit(api: Path, jobs: list, manifest: Path) -> dict:
    manifest.write_text(json.dumps(jobs))
    r = subprocess.run(
        [*CPU_PIN, "bash", str(LOCKED_NODE), "--stack-size=8192", str(BATCH_EMIT), str(api), str(manifest)],
        capture_output=True, text=True, timeout=900,
    )
    if r.returncode != 0:
        raise RuntimeError(f"batch_emit failed rc={r.returncode}: {r.stderr[:400]}")
    return {item["id"]: item for item in json.loads(r.stdout)}


def link_run_cleanup(obj: Path, rt: Path, exe: Path) -> tuple[bool, str]:
    try:
        r_cc = subprocess.run(
            [*CPU_PIN, CC, "-no-pie", str(obj), str(rt), "-pthread", "-lm", "-o", str(exe)],
            capture_output=True, text=True, timeout=30,
        )
        if r_cc.returncode != 0:
            return False, f"LINK_ERR: {r_cc.stderr.strip()[:240]}"
        try:
            r_run = subprocess.run(
                [*CPU_PIN, str(exe), *RTS_ARGS],
                capture_output=True, text=True, timeout=30,
            )
            if r_run.returncode != 0:
                return False, f"RUN_ERR({r_run.returncode}): stderr={r_run.stderr.strip()[:200]} stdout={r_run.stdout.strip()[:120]}"
            if r_run.stderr:
                return False, f"RUN_STDERR: {r_run.stderr.strip()[:200]}"
            return True, r_run.stdout
        except subprocess.TimeoutExpired:
            return False, "RUN_TIMEOUT"
    finally:
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=2026112205)
    ap.add_argument("--per-family", type=int, default=15)
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--oracle", choices=["wave2", "upstream"], default="wave2")
    ap.add_argument("--out-json", type=Path, default=ROOT / "experiments/agy/receipts/wave5-fuzz-report.json")
    ap.add_argument("--only-family", type=str, default=None)
    args = ap.parse_args()

    t0 = time.perf_counter()
    WORK_DIR.mkdir(parents=True, exist_ok=True)
    src_dir = WORK_DIR / "src"
    obj_dir = WORK_DIR / "obj"
    exe_dir = WORK_DIR / "exe"
    for d in (src_dir, obj_dir, exe_dir):
        d.mkdir(parents=True, exist_ok=True)

    cases = []
    seen_hashes = set()
    for f_idx, (fname, gen_fn) in enumerate(FAMILIES):
        if args.only_family and fname != args.only_family:
            continue
        fam_rng = random.Random(args.seed + f_idx * 100003)
        generated = 0
        attempt = 0
        while generated < args.per_family and attempt < args.per_family * 10:
            attempt += 1
            code = gen_fn(fam_rng, generated)
            h = hashlib.sha256(code.encode("utf-8")).hexdigest()[:16]
            if h in seen_hashes:
                continue
            seen_hashes.add(h)
            cid = f"{fname}__{generated:03d}"
            sp = src_dir / f"{cid}.bend"
            sp.write_text(code)
            cases.append({
                "id": cid,
                "family": fname,
                "idx": generated,
                "sha256_16": h,
                "src": sp,
                "obj": obj_dir / f"{cid}.o",
                "exe": exe_dir / f"{cid}.exe",
            })
            generated += 1

    print(f"Generated {len(cases)} distinct Wave 5 adversarial programs ({args.per_family}/family, seed={args.seed})", flush=True)

    t_emit = time.perf_counter()
    w5_jobs = [{"id": c["id"], "src": str(c["src"]), "out": str(c["obj"])} for c in cases]
    if args.oracle == "wave2":
        w5_emitted = batch_emit(W5A_API, w5_jobs, WORK_DIR / "w5_manifest.json")
        w2_jobs = [{"id": c["id"], "src": str(c["src"]), "out": str(obj_dir / f"{c['id']}.w2.o")} for c in cases]
        w2_emitted = batch_emit(W2_API, w2_jobs, WORK_DIR / "w2_oracle_manifest.json")
        emit_sec = round(time.perf_counter() - t_emit, 2)
        print(f"Wave 5A + Wave 2 oracle batch emit finished in {emit_sec:.2f}s", flush=True)
        up_results = {}
        with ThreadPoolExecutor(max_workers=args.workers) as ex:
            futs = {}
            for c in cases:
                cid = c["id"]
                em = w2_emitted[cid]
                o2 = obj_dir / f"{cid}.w2.o"
                if not em["ok"]:
                    up_results[cid] = (False, f"W2_{em['stage'].upper()}_ERR: {em['error'][:240]}")
                    o2.unlink(missing_ok=True)
                else:
                    futs[ex.submit(link_run_cleanup, o2, AGY_RT, exe_dir / f"{cid}.w2.exe")] = cid
            for fut in as_completed(futs):
                up_results[futs[fut]] = fut.result()
    else:
        with ThreadPoolExecutor(max_workers=args.workers) as ex:
            f_w5 = ex.submit(batch_emit, W5A_API, w5_jobs, WORK_DIR / "w5_manifest.json")
            f_ups = {c["id"]: ex.submit(run_upstream, c["src"]) for c in cases}
            w5_emitted = f_w5.result()
            up_results = {cid: fut.result() for cid, fut in f_ups.items()}
        emit_sec = round(time.perf_counter() - t_emit, 2)
        print(f"Wave 5A batch emit + Upstream oracle finished in {emit_sec:.2f}s", flush=True)

    t_exec = time.perf_counter()
    w5_run_results = {}
    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        futs = {}
        for c in cases:
            cid = c["id"]
            em = w5_emitted[cid]
            if not em["ok"]:
                w5_run_results[cid] = (False, f"W5A_{em['stage'].upper()}_ERR: {em['error'][:240]}")
                c["obj"].unlink(missing_ok=True)
            else:
                futs[ex.submit(link_run_cleanup, c["obj"], AGY_RT, c["exe"])] = cid
        for fut in as_completed(futs):
            w5_run_results[futs[fut]] = fut.result()
    exec_sec = round(time.perf_counter() - t_exec, 2)
    print(f"Wave 5A link + exec finished in {exec_sec:.2f}s", flush=True)

    family_stats = {fname: {"total": 0, "pass": 0, "fail": 0, "up_err": 0} for fname, _ in FAMILIES if (not args.only_family or fname == args.only_family)}
    mismatches = []
    for c in cases:
        cid = c["id"]
        fname = c["family"]
        family_stats[fname]["total"] += 1
        up_ok, up_out = up_results[cid]
        w5_ok, w5_out = w5_run_results[cid]
        if not up_ok:
            family_stats[fname]["up_err"] += 1
            mismatches.append({"id": cid, "family": fname, "kind": "upstream_error", "up": up_out, "w5a": w5_out, "src": str(c["src"])})
        elif w5_ok and up_out == w5_out:
            family_stats[fname]["pass"] += 1
            c["src"].unlink(missing_ok=True)
        else:
            family_stats[fname]["fail"] += 1
            mismatches.append({"id": cid, "family": fname, "kind": "mismatch", "up": up_out, "w5a": w5_out, "src": str(c["src"])})

    real_mismatches = [m for m in mismatches if m["kind"] == "mismatch"]
    if real_mismatches:
        print(f"!!! FOUND {len(real_mismatches)} MISMATCH(ES) — isolating with Wave 2...", flush=True)
        w2_jobs = [{"id": m["id"], "src": m["src"], "out": str(obj_dir / f"{m['id']}.w2.o")} for m in real_mismatches]
        w2_em = batch_emit(W2_API, w2_jobs, WORK_DIR / "w2_manifest.json")
        for m in real_mismatches:
            cid = m["id"]
            em = w2_em[cid]
            if not em["ok"]:
                m["w2"] = f"W2_{em['stage'].upper()}_ERR: {em['error'][:240]}"
            else:
                ok, out = link_run_cleanup(obj_dir / f"{cid}.w2.o", AGY_RT, exe_dir / f"{cid}.w2.exe")
                m["w2"] = out
            print(f"  FAIL {cid}: up={m['up'].strip()!r} | w5a={m['w5a'].strip()!r} | w2={m['w2'].strip()!r}", flush=True)
    for m in mismatches:
        if m["kind"] == "upstream_error":
            print(f"  UP_ERR {m['id']}: {m['up'][:200]}", flush=True)

    total_sec = round(time.perf_counter() - t0, 2)
    total_pass = sum(s["pass"] for s in family_stats.values())
    total_all = sum(s["total"] for s in family_stats.values())
    total_up_err = sum(s["up_err"] for s in family_stats.values())
    total_fail = sum(s["fail"] for s in family_stats.values())

    print("\n=== WAVE 5A ADVERSARIAL DIFFERENTIAL FUZZER SUMMARY ===")
    for fname, st in family_stats.items():
        print(f"  {fname:24s}: {st['pass']:3d}/{st['total']:3d} PASS (fail={st['fail']}, up_err={st['up_err']})")
    print(f"  TOTAL                   : {total_pass:3d}/{total_all:3d} PASS (fail={total_fail}, up_err={total_up_err}) in {total_sec:.2f}s")

    report = {
        "seed": args.seed,
        "per_family": args.per_family,
        "total": total_all,
        "pass": total_pass,
        "fail": total_fail,
        "up_err": total_up_err,
        "emit_sec": emit_sec,
        "exec_sec": exec_sec,
        "total_sec": total_sec,
        "families": family_stats,
        "mismatches": mismatches,
    }
    if args.out_json:
        args.out_json.parent.mkdir(parents=True, exist_ok=True)
        args.out_json.write_text(json.dumps(report, indent=2) + "\n")
    sys.exit(0 if (total_fail == 0 and total_up_err == 0) else 1)


if __name__ == "__main__":
    main()
