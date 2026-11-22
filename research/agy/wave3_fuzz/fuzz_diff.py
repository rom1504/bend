#!/usr/bin/env python3
"""Track Q1 — Grammar-Based Differential Fuzzer for Wave 2 Unified Compiler.

Generates 245 deterministic, well-typed random Bend programs (35 per family across
7 families exercising all 14 Wave 1 & Wave 2 passes) and asserts bit-exact stdout
equality between:
  1. Upstream Bend (`bun /home/ai/bend2_agy/bend2/main.ts`)
  2. Wave 2 Unified (`wave2_unified/api.mjs` + `unified/runtime-agy.o`)
  3. On ANY mismatch, also runs Phase 205 (`api-base/api.mjs` + `runtime-live-scan.o`)
     to isolate whether the bug was introduced in Wave 1/2.

Temp .o/.exe files are deleted immediately after each test to keep disk < 40 MiB.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import os
import random
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
BATCH_EMIT = ROOT / "research/agy/wave3_fuzz/batch_emit.mjs"

W2_API = ROOT / "selfhost/build/agy/wave2_unified/api.mjs"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
BASE_API = ROOT / "selfhost/build/agy/api-base/api.mjs"
P205_RT = ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o"
WORK_DIR = ROOT / "selfhost/build/agy/wave3_fuzz/run_tmp"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

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

U32_EDGES = [
    0, 1, 2, 3, 7, 15, 31, 32, 33, 35, 63, 64, 127, 255,
    65535, 65536, 2147483647, 2147483648, 4294967294, 4294967295,
]


def bend_str_lit(s: str) -> str:
    esc = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{esc}"'


# =============================================================================
# Family 1: CTFE & Boundary Arithmetic
# =============================================================================
def gen_family1_ctfe_arith(rng: random.Random, idx: int) -> str:
    u32_binops = [
        "U32.add", "U32.sub", "U32.mul", "U32.div", "U32.mod",
        "U32.and", "U32.or", "U32.xor", "U32.shln", "U32.shrn",
    ]
    u32_cmps = ["U32.is_eq", "U32.is_ne", "U32.is_lt", "U32.is_le", "U32.is_gt", "U32.is_ge"]
    f32_binops = ["F32.add", "F32.sub", "F32.mul", "F32.div"]
    f32_cmps = ["F32.is_eq", "F32.is_ne", "F32.is_lt", "F32.is_le", "F32.is_gt", "F32.is_ge"]

    def rand_u32_atom(dyn_var: str | None) -> str:
        r = rng.random()
        if dyn_var and r < 0.25:
            return dyn_var
        if r < 0.70:
            return str(rng.choice(U32_EDGES))
        return str(rng.randint(0, 4294967295))

    def rand_u32_expr(depth: int, dyn_var: str | None) -> str:
        if depth <= 0:
            return rand_u32_atom(dyn_var)
        choice = rng.random()
        if choice < 0.12:
            if rng.random() < 0.5:
                return f"U32.inc({rand_u32_expr(depth - 1, dyn_var)})"
            return f"U32.sub({rand_u32_expr(depth - 1, dyn_var)}, 1)"
        if choice < 0.24:
            # Absorbing identity stress
            e = rand_u32_expr(depth - 1, dyn_var)
            kind = rng.randint(0, 4)
            if kind == 0:
                return f"U32.mul({e}, 0)"
            if kind == 1:
                return f"U32.and({e}, 0)"
            if kind == 2:
                return f"U32.or({e}, 4294967295)"
            if kind == 3:
                return f"U32.div({e}, 0)"
            return f"U32.mod({e}, 0)"
        if choice < 0.36:
            op = rng.choice(u32_cmps)
            return f"b2u({op}({rand_u32_expr(depth - 1, dyn_var)}, {rand_u32_expr(depth - 1, dyn_var)}))"
        op = rng.choice(u32_binops)
        if op in ("U32.shln", "U32.shrn"):
            sh = rng.choice([0, 1, 7, 15, 31, 32, 33, 35])
            return f"{op}({rand_u32_expr(depth - 1, dyn_var)}, {sh}n)"
        return f"{op}({rand_u32_expr(depth - 1, dyn_var)}, {rand_u32_expr(depth - 1, dyn_var)})"

    def rand_f32_atom(dyn_f: str | None) -> str:
        atoms = [
            "0.0", "1.0", "2.5", "0.125", "100.25",
            "F32.sub(0.0, 1.0)",
            "F32.mul(F32.sub(0.0, 1.0), 0.0)",  # -0.0
            "F32.div(0.0, 0.0)",                # NaN
            "F32.div(1.0, 0.0)",                # +Inf
            "F32.div(F32.sub(0.0, 1.0), 0.0)",  # -Inf
            "U32.to_f32(4294967295)",
        ]
        if dyn_f and rng.random() < 0.25:
            return dyn_f
        return rng.choice(atoms)

    def rand_f32_expr(depth: int, dyn_f: str | None) -> str:
        if depth <= 0:
            return rand_f32_atom(dyn_f)
        if rng.random() < 0.22:
            return f"F32.sqrt({rand_f32_expr(depth - 1, dyn_f)})"
        op = rng.choice(f32_binops)
        return f"{op}({rand_f32_expr(depth - 1, dyn_f)}, {rand_f32_expr(depth - 1, dyn_f)})"

    closed_u = rand_u32_expr(rng.randint(3, 5), None)
    dyn_u = rand_u32_expr(rng.randint(3, 4), "x")
    closed_f = rand_f32_expr(rng.randint(2, 4), None)
    dyn_f = rand_f32_expr(rng.randint(2, 4), "fx")
    fcmp = rng.choice(f32_cmps)
    nat_case = rng.choice([
        "U32.from_nat(0n)",
        "U32.from_nat(1n)",
        "U32.from_nat(U32.to_nat(4294967295))",
        "U32.from_nat(Succ{U32.to_nat(4294967295)})",
        "U32.from_nat(Succ{Succ{U32.to_nat(4294967294)}})",
        f"U32.from_nat(U32.to_nat({rng.choice(U32_EDGES)}))",
    ])
    s1 = "".join(rng.choices("abc012", k=rng.randint(0, 6)))
    s2 = "".join(rng.choices("xyz789", k=rng.randint(0, 6)))
    dyn_seed = rng.choice(U32_EDGES)

    return f"""import Base
{DYN_ZERO}
{COMMON_HELPERS}

def closed_u() -> U32:
  {closed_u}

def dyn_u(+x: U32) -> U32:
  {dyn_u}

def closed_f() -> U32:
  +v = {closed_f}
  U32.xor(f32_cbits(v), F32.to_u32(v))

def dyn_f(+fx: F32) -> U32:
  +v = {dyn_f}
  +c = b2u({fcmp}(v, fx))
  U32.xor(U32.xor(f32_cbits(v), F32.to_u32(v)), U32.mul(c, 131))

def nat_edge() -> U32:
  {nat_case}

def str_closed() -> U32:
  +s = String.append({bend_str_lit(s1)}, {bend_str_lit(s2)})
  U32.add(U32.from_nat(String.length(s)), b2u(String.eq(s, {bend_str_lit(s1 + s2)})))

def main() -> IO(Unit):
  +z = dyn_zero()
  +r1 = closed_u()
  +r2 = dyn_u(U32.add(z, {dyn_seed}))
  +r3 = closed_f()
  +r4 = dyn_f(U32.to_f32(U32.add(z, {rng.randint(0, 100)})))
  +r5 = nat_edge()
  +r6 = str_closed()
  IO.print(
    U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r3) ++ "," ++
    U32.show(r4) ++ "," ++ U32.show(r5) ++ "," ++ U32.show(r6))
"""


# =============================================================================
# Family 2: ROREC & Recursive ADT Evaluators
# =============================================================================
def gen_family2_rorec_adt(rng: random.Random, idx: int) -> str:
    ops = ["U32.add", "U32.sub", "U32.mul", "U32.xor", "U32.and", "U32.or"]

    def rand_op():
        return rng.choice(ops)

    def rand_leaf_expr(has_x: bool, depth: int) -> str:
        if depth <= 0:
            if has_x and rng.random() < 0.5:
                return "x"
            return str(rng.choice([0, 1, 3, 7, 17, 31, 100, 65535, 4294967295]))
        return f"{rand_op()}({rand_leaf_expr(has_x, depth - 1)}, {rand_leaf_expr(has_x, depth - 1)})"

    def rand_lit_expr(has_x: bool, depth: int) -> str:
        if depth <= 0:
            cands = ["v", str(rng.choice([1, 5, 13, 255, 4294967295]))]
            if has_x:
                cands.append("x")
            return rng.choice(cands)
        return f"{rand_op()}({rand_lit_expr(has_x, depth - 1)}, {rand_lit_expr(has_x, depth - 1)})"

    def rand_unary_expr(call: str, has_x: bool) -> str:
        rhs = rand_leaf_expr(has_x, rng.randint(0, 2))
        if rng.random() < 0.5:
            return f"{rand_op()}({call}, {rhs})"
        return f"{rand_op()}({rhs}, {call})"

    def rand_bin_expr(c1: str, c2: str, has_x: bool) -> str:
        style = rng.randint(0, 3)
        if style == 0:
            return f"{rand_op()}({c1}, {c2})"
        if style == 1:
            rhs = rand_leaf_expr(has_x, rng.randint(1, 2))
            return f"{rand_op()}({c1}, {rand_op()}({c2}, {rhs}))"
        if style == 2:
            # Nested RoBin on RHS without RoRec (tests %edx clobber!)
            rhs = rand_leaf_expr(has_x, 2)
            return f"{rand_op()}({c1}, {rhs})"
        lhs = rand_leaf_expr(has_x, 1)
        return f"{rand_op()}({rand_op()}({lhs}, {c1}), {c2})"

    # Pick depths including crossing budget=256
    chain_depth = rng.choice([0, 1, 2, 15, 64, 128, 254, 255, 256, 257, 258, 270, 300])
    dag_mid_depth = rng.choice([2, 10, 60, 128, 130])
    dag_top_depth = rng.choice([1, 5, 60, 127, 130])
    x1 = rng.choice([0, 1, 7, 42, 4294967295])
    x2 = rng.choice([2, 9, 131, 65535])

    return f"""import Base
{DYN_ZERO}

type E is Data:
  ELeaf{{}}
  ELit{{v: U32}}
  EUn{{a: E}}
  EBin1{{a: E, b: E}}
  EBin2{{a: E, b: E}}

def eval1(e: E) -> U32:
  match e:
    case ELeaf{{}}: {rand_leaf_expr(False, rng.randint(0, 2))}
    case ELit{{+v}}: {rand_lit_expr(False, rng.randint(1, 2))}
    case EUn{{a}}: {rand_unary_expr("eval1(a)", False)}
    case EBin1{{a, b}}: {rand_bin_expr("eval1(a)", "eval1(b)", False)}
    case EBin2{{a, b}}: {rand_bin_expr("eval1(a)", "eval1(b)", False)}

def eval2(e: E, +x: U32) -> U32:
  match e:
    case ELeaf{{}}: {rand_leaf_expr(True, rng.randint(0, 2))}
    case ELit{{+v}}: {rand_lit_expr(True, rng.randint(1, 2))}
    case EUn{{a}}: {rand_unary_expr("eval2(a, x)", True)}
    case EBin1{{a, b}}: {rand_bin_expr("eval2(a, x)", "eval2(b, x)", True)}
    case EBin2{{a, b}}: {rand_bin_expr("eval2(a, x)", "eval2(b, x)", True)}

# Non-certified observer (uses U32.inc) to verify shared roots remain intact
def obs_count(e: E) -> U32:
  match e:
    case ELeaf{{}}: 1
    case ELit{{v}}: U32.inc(U32.and(v, 255))
    case EUn{{a}}: U32.inc(obs_count(a))
    case EBin1{{a, b}}: U32.inc(U32.add(obs_count(a), obs_count(b)))
    case EBin2{{a, b}}: U32.inc(U32.xor(obs_count(a), obs_count(b)))

def mk_chain(+n: Nat, acc: E) -> E:
  match n:
    case 0n: acc
    case 1n+p: mk_chain(p, EUn{{acc}})

def static_tree() -> E:
  EBin1{{EBin2{{ELit{{17}}, ELeaf{{}}}}, EUn{{ELit{{42}}}}}}

def main() -> IO(Unit):
  +z = dyn_zero()
  +ch = mk_chain(U32.to_nat(U32.add(z, {chain_depth})), ELit{{U32.add(z, {rng.randint(1, 99)})}})
  +mid = mk_chain(U32.to_nat(U32.add(z, {dag_mid_depth})), EBin2{{ELit{{11}}, ELeaf{{}}}})
  +dag = mk_chain(U32.to_nat(U32.add(z, {dag_top_depth})), EBin1{{mid, mid}})
  +r1 = U32.xor(eval1(ch), eval2(ch, U32.add(z, {x1})))
  +r2 = U32.xor(eval2(ch, U32.add(z, {x2})), obs_count(ch))
  +r3 = U32.xor(eval1(dag), U32.xor(eval2(dag, {x1}), obs_count(dag)))
  +r4 = U32.xor(eval1(static_tree()), eval2(static_tree(), {x2}))
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r3) ++ "," ++ U32.show(r4))
"""


# =============================================================================
# Family 3: F32 Loops, XMM Hoisting, Tables & Fused Compares
# =============================================================================
def gen_family3_f32_xmm(rng: random.Random, idx: int) -> str:
    n_f32_params = rng.randint(1, 9)
    n_inv = rng.randint(0, min(4, n_f32_params - 1))
    n_car = n_f32_params - n_inv
    inv_names = [f"c{i}" for i in range(n_inv)]
    car_names = [f"v{i}" for i in range(n_car)]
    all_names = inv_names + car_names

    f32_ops = ["F32.add", "F32.sub", "F32.mul", "F32.div"]
    f32_cmps = ["F32.is_eq", "F32.is_ne", "F32.is_lt", "F32.is_le", "F32.is_gt", "F32.is_ge"]

    def rand_f32_val():
        return rng.choice(["0.25", "0.5", "1.0", "1.25", "2.0", "3.5", "0.0625", "0.0"])

    def rand_fexpr(depth: int) -> str:
        if depth <= 0:
            if rng.random() < 0.7:
                return rng.choice(all_names)
            return rand_f32_val()
        if rng.random() < 0.15:
            return f"F32.sqrt({rand_fexpr(depth - 1)})"
        op = rng.choice(f32_ops)
        return f"{op}({rand_fexpr(depth - 1)}, {rand_fexpr(depth - 1)})"

    # Build loop body updates
    body_lines = []
    new_cars = []
    for i, vn in enumerate(car_names):
        tmp = f"n{i}"
        expr = rand_fexpr(rng.randint(1, 3))
        body_lines.append(f"      +{tmp} = {expr}")
        new_cars.append(tmp)

    # Branch with fused compare + call that clobbers XMM
    cmp1 = rng.choice(f32_cmps)
    cmp2 = rng.choice(f32_cmps)
    a_var = rng.choice(all_names)
    b_var = rng.choice(all_names)
    c_var = rng.choice(all_names)
    body_lines.append(f"      +t1 = ft5(p)")
    body_lines.append(f"      +t2 = ft3(p)")
    body_lines.append(f"      +br = branch_clob({cmp1}({a_var}, {b_var}), {a_var}, {b_var}, F32.add(t1, t2))")
    body_lines.append(f"      +flg = b2u({cmp2}(br, {c_var}))")
    body_lines.append(f"      +q = F32.to_u32(F32.add(br, {new_cars[0]}))")
    body_lines.append(f"      +h2 = U32.xor(U32.mul(h, 16777619), U32.add(U32.xor(q, f32_cbits(br)), flg))")

    params_sig = ", ".join(f"+{nm}: F32" for nm in all_names)
    rec_args = ", ".join(inv_names + new_cars)
    init_vals = ", ".join(rand_f32_val() for _ in all_names)
    iters = rng.choice([0, 1, 2, 5, 10, 16])

    # Also test sqrt on edge values (positive, negative, -0.0, NaN, +Inf)
    sqrt_edge = rng.choice([
        "F32.sqrt(U32.to_f32(U32.add(z, 9)))",
        "F32.sqrt(F32.sub(U32.to_f32(z), 4.0))",
        "F32.sqrt(F32.mul(F32.sub(U32.to_f32(z), 1.0), U32.to_f32(z)))",
        "F32.sqrt(F32.div(U32.to_f32(z), U32.to_f32(z)))",
        "F32.sqrt(F32.div(1.0, U32.to_f32(z)))",
    ])
    oob_idx = rng.choice([0, 1, 2, 3, 4, 5, 10, 50])

    return f"""import Base
{DYN_ZERO}
{COMMON_HELPERS}

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
    case 1n: F32.sub(0.0, 5.0)
    case 2n+k: 30.0

def clobber(n: Nat, x: F32) -> F32:
  match n:
    case 0n: x
    case 1n+p:
      +a = F32.add(x, 0.125)
      +b = F32.mul(a, 1.0005)
      clobber(p, F32.div(F32.sub(b, 0.0625), 1.0002))

def branch_clob(cond: Bool, +a: F32, +b: F32, +c: F32) -> F32:
  match cond:
    case True{{}}: F32.sub(clobber(3n, a), F32.div(b, F32.add(F32.mul(c, c), 1.0)))
    case False{{}}: F32.div(F32.sub(c, a), F32.add(F32.mul(b, b), 2.0))

def floop(+n: Nat, {params_sig}, +h: U32) -> U32:
  match n:
    case 0n: U32.xor(h, f32_cbits({car_names[0]}))
    case 1n+p:
{chr(10).join(body_lines)}
      floop(p, {rec_args}, h2)

def main() -> IO(Unit):
  +z = dyn_zero()
  +r1 = floop(U32.to_nat(U32.add(z, {iters})), {init_vals}, 17)
  +sq = {sqrt_edge}
  +r2 = U32.xor(f32_cbits(sq), F32.to_u32(sq))
  +r3 = U32.xor(f32_cbits(ft5(U32.to_nat(U32.add(z, {oob_idx})))), f32_cbits(ft3(U32.to_nat(U32.add(z, {oob_idx})))))
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r3))
"""


# =============================================================================
# Family 4: Map (set/get/del) Random Operation Sequences
# =============================================================================
def gen_family4_map_ops(rng: random.Random, idx: int) -> str:
    use_str_val = (idx % 2 == 1)
    k63 = "012345678901234567890123456789012345678901234567890123456789012"
    k64 = k63 + "3"
    k65a = k64 + "A"
    k65b = k64 + "B"
    k70 = k65a + "zzzzz"
    key_pool = [
        "", "a", "b", "c", "ab", "ac", "abc", "abd", "k1", "k2", "k3",
        k63, k64, k65a, k65b, k70,
        "α", "β", "αβ", "🚀", "日本語",
    ]
    n_ops = rng.randint(12, 36)
    lines = []
    snap_vars = []
    get_accs = []
    val_ty = "String" if use_str_val else "U32"

    # Optional static base map on some seeds
    if rng.random() < 0.35 and not use_str_val:
        lines.append("  m = static_base()")
    else:
        lines.append(f"  m = Map.new(&2, {val_ty})")

    for step in range(n_ops):
        op = rng.choices(["set", "get", "del", "snap"], weights=[45, 25, 22, 8])[0]
        k = bend_str_lit(rng.choice(key_pool))
        if op == "set":
            if use_str_val:
                tag = f"v{step}_"
                lines.append(f"  m = Map.set(&2, String, m, {k}, String.append({bend_str_lit(tag)}, U32.show(U32.add(z, {step}))))")
            else:
                v = rng.choice([0, 1, step, 4294967295, rng.randint(0, 100000)])
                lines.append(f"  m = Map.set(&2, U32, m, {k}, U32.add(z, {v}))")
        elif op == "del":
            lines.append(f"  m = Map.del(&2, {val_ty}, m, {k})")
        elif op == "get":
            gv = f"g{step}"
            if use_str_val:
                lines.append(f"  (m, +{gv}) = get_str(Map.get(String, \"DEF\", m, {k}))")
                get_accs.append(f"s_hash({gv}, 17)")
            else:
                lines.append(f"  (m, +{gv}) = get_u32(Map.get(U32, 999, m, {k}))")
                get_accs.append(gv)
        else:
            # Snapshot +m via helper!
            sv = f"sn{len(snap_vars)}"
            if use_str_val:
                lines.append(f"  (m, +{sv}) = snap_str(m)")
            else:
                lines.append(f"  (m, +{sv}) = snap_u32(m)")
            snap_vars.append(sv)

    # Note: Bend doesn't allow `(m, g) = f(...)` directly on computed value!
    # So instead of inline tuple destructuring, we thread (m, acc) through a clean sequence of helper calls!
    # Let's generate clean helper-threaded Bend code!
    return _gen_family4_clean(rng, idx, use_str_val, key_pool, n_ops)


def _gen_family4_clean(rng: random.Random, idx: int, use_str_val: bool, key_pool: list, n_ops: int) -> str:
    val_ty = "String" if use_str_val else "U32"
    helpers = """
def s_hash(s: String, acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{Chr{x}, t}: s_hash(t, U32.add(U32.mul(acc, 31), x))
"""
    if use_str_val:
        helpers += """
def ms_digest(xs: List<&2, Sigma<&2, &2, String, _ => String>>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case (k, v) <> t: ms_digest(t, U32.xor(U32.mul(s_hash(k, acc), 16777619), s_hash(v, 31)))

def hash_map(m: Map<&2, String>) -> U32:
  ms_digest(Map.to_list(&2, String, m), 2166136261)

def do_get(r: Map<&2, String> & String, acc: U32) -> Map<&2, String> & U32:
  (m, v) = r
  (m, U32.xor(U32.mul(acc, 131), s_hash(v, 19)))

def do_snap(+m: Map<&2, String>, acc: U32) -> Map<&2, String> & U32:
  (m, U32.xor(U32.mul(acc, 257), hash_map(m)))

def step_set(st: Map<&2, String> & U32, k: String, v: String) -> Map<&2, String> & U32:
  (m, acc) = st
  (Map.set(&2, String, m, k, v), acc)

def step_del(st: Map<&2, String> & U32, k: String) -> Map<&2, String> & U32:
  (m, acc) = st
  (Map.del(&2, String, m, k), acc)

def step_get(st: Map<&2, String> & U32, k: String) -> Map<&2, String> & U32:
  (m, acc) = st
  do_get(Map.get(String, "MISS", m, k), acc)

def step_snap(st: Map<&2, String> & U32) -> Map<&2, String> & U32:
  (m, acc) = st
  do_snap(m, acc)

def finish(st: Map<&2, String> & U32) -> U32:
  (m, acc) = st
  U32.xor(acc, hash_map(m))
"""
    else:
        helpers += """
def m_digest(xs: List<&2, Sigma<&2, &2, String, _ => U32>>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case (k, v) <> t: m_digest(t, U32.xor(U32.mul(s_hash(k, acc), 16777619), v))

def hash_map(m: Map<&2, U32>) -> U32:
  m_digest(Map.to_list(&2, U32, m), 2166136261)

def static_base() -> Map<&2, U32>:
  MNode{24n, MLeaf{"a", 10}, MLeaf{"b", 20}}

def do_get(r: Map<&2, U32> & U32, acc: U32) -> Map<&2, U32> & U32:
  (m, v) = r
  (m, U32.xor(U32.mul(acc, 131), v))

def do_snap(+m: Map<&2, U32>, acc: U32) -> Map<&2, U32> & U32:
  (m, U32.xor(U32.mul(acc, 257), hash_map(m)))

def step_set(st: Map<&2, U32> & U32, k: String, v: U32) -> Map<&2, U32> & U32:
  (m, acc) = st
  (Map.set(&2, U32, m, k, v), acc)

def step_del(st: Map<&2, U32> & U32, k: String) -> Map<&2, U32> & U32:
  (m, acc) = st
  (Map.del(&2, U32, m, k), acc)

def step_get(st: Map<&2, U32> & U32, k: String) -> Map<&2, U32> & U32:
  (m, acc) = st
  do_get(Map.get(U32, 999, m, k), acc)

def step_snap(st: Map<&2, U32> & U32) -> Map<&2, U32> & U32:
  (m, acc) = st
  do_snap(m, acc)

def finish(st: Map<&2, U32> & U32) -> U32:
  (m, acc) = st
  U32.xor(acc, hash_map(m))
"""

    ops_lines = []
    if rng.random() < 0.35 and not use_str_val:
        ops_lines.append("  st : Map<&2, U32> & U32 = (static_base(), 7)")
    else:
        ops_lines.append(f"  st : Map<&2, {val_ty}> & U32 = (Map.new(&2, {val_ty}), 7)")

    for step in range(n_ops):
        op = rng.choices(["set", "get", "del", "snap"], weights=[45, 22, 23, 10])[0]
        k = bend_str_lit(rng.choice(key_pool))
        if op == "set":
            if use_str_val:
                tag = f"v{step}_"
                ops_lines.append(f"  st = step_set(st, {k}, String.append({bend_str_lit(tag)}, U32.show(U32.add(z, {step}))))")
            else:
                v = rng.choice([0, 1, step, 4294967295, rng.randint(0, 100000)])
                ops_lines.append(f"  st = step_set(st, {k}, U32.add(z, {v}))")
        elif op == "del":
            ops_lines.append(f"  st = step_del(st, {k})")
        elif op == "get":
            ops_lines.append(f"  st = step_get(st, {k})")
        else:
            ops_lines.append("  st = step_snap(st)")

    return f"""import Base
{DYN_ZERO}
{helpers}

def main() -> IO(Unit):
  +z = dyn_zero()
{chr(10).join(ops_lines)}
  IO.print(U32.show(finish(st)))
"""


# =============================================================================
# Family 5: BST Zipper & Bitonic flow + Perceus Reuse
# =============================================================================
def gen_family5_bst_flow_reuse(rng: random.Random, idx: int) -> str:
    if idx % 2 == 0:
        return _gen_family5_bst(rng, idx)
    return _gen_family5_flow_reuse(rng, idx)


def _gen_family5_bst(rng: random.Random, idx: int) -> str:
    n_ins = rng.randint(8, 28)
    key_choices = [0, 1, 2, 10, 20, 30, 40, 50, 100, 4294967294, 4294967295]
    keys = [rng.choice(key_choices) if rng.random() < 0.6 else rng.randint(0, 100) for _ in range(n_ins)]
    fuels = [rng.choice(["0n", "1n", "2n", "3n", "8n", "20n", "big_fuel"]) for _ in range(n_ins)]

    ins_lines = ["  t : BTree = BLeaf{}"]
    for i, (k, fl) in enumerate(zip(keys, fuels)):
        ins_lines.append(f"  t = bst.insert({fl}, U32.add(z, {k}), t)")

    sh_k = rng.choice(key_choices)
    sh_fl = rng.choice(["0n", "1n", "4n", "10n", "big_fuel"])

    return f"""import Base
{DYN_ZERO}

type BTree is Data:
  BLeaf{{}}
  BNode{{l: BTree, v: U32, r: BTree}}

type BF is Data:
  BF{{v: U32, other: BTree, left: Bool}}

def bst.pick(l: BTree, v: U32, r: BTree, path: List<&2, BF>, go_left: Bool) -> BTree & List<&2, BF>:
  match go_left:
    case True{{}}: (l, Con{{BF{{v, r, True{{}}}}, path}})
    case False{{}}: (r, Con{{BF{{v, l, False{{}}}}, path}})

def bst.down(fuel: Nat, +x: U32, st: BTree & List<&2, BF>) -> BTree & List<&2, BF>:
  match fuel:
    case 0n: st
    case 1n+f:
      (t, path) = st
      match t:
        case BLeaf{{}}: (BLeaf{{}}, path)
        case BNode{{l, +v, r}}: bst.down(f, x, bst.pick(l, v, r, path, U32.is_lt(x, v)))

def bst.up(path: List<&2, BF>, acc: BTree) -> BTree:
  match path:
    case Nil{{}}: acc
    case Con{{BF{{v, other, left}}, rest}}:
      match left:
        case True{{}}: bst.up(rest, BNode{{acc, v, other}})
        case False{{}}: bst.up(rest, BNode{{other, v, acc}})

def bst.fin(x: U32, st: BTree & List<&2, BF>) -> BTree:
  (t, path) = st
  match t:
    case BLeaf{{}}: bst.up(path, BNode{{BLeaf{{}}, x, BLeaf{{}}}})
    case BNode{{l, v, r}}: bst.up(path, BNode{{l, v, r}})

def bst.insert(fuel: Nat, +x: U32, t: BTree) -> BTree:
  bst.fin(x, bst.down(fuel, x, (t, Nil{{}})))

def thash(t: BTree) -> U32:
  match t:
    case BLeaf{{}}: 17
    case BNode{{l, v, r}}:
      U32.xor(U32.add(U32.mul(thash(l), 131), v), U32.mul(thash(r), 313))

def static_bst() -> BTree:
  BNode{{BNode{{BLeaf{{}}, 10, BLeaf{{}}}}, 25, BNode{{BLeaf{{}}, 40, BLeaf{{}}}}}}

def main() -> IO(Unit):
  +z = dyn_zero()
  +big_fuel : Nat = Succ{{U32.to_nat(4294967295)}}
{chr(10).join(ins_lines)}
  +sh : BTree = BNode{{BNode{{BLeaf{{}}, 15, BLeaf{{}}}}, 30, BNode{{BLeaf{{}}, 45, BLeaf{{}}}}}}
  root : BTree = BNode{{BNode{{sh, 60, BLeaf{{}}}}, 80, BNode{{BLeaf{{}}, 90, BLeaf{{}}}}}}
  out1 = bst.insert({sh_fl}, U32.add(z, {sh_k}), root)
  out2 = bst.insert(8n, U32.add(z, {sh_k}), static_bst())
  IO.print(U32.show(thash(t)) ++ "," ++ U32.show(thash(sh)) ++ "," ++ U32.show(thash(out1)) ++ "," ++ U32.show(thash(out2)))
"""


def _gen_family5_flow_reuse(rng: random.Random, idx: int) -> str:
    d_build = rng.randint(1, 5)
    d_flow1 = rng.choice([0, 1, 2, d_build, 64, 65, 70])
    d_flow2 = rng.choice([0, 1, d_build])
    dir1 = rng.choice(["True{}", "False{}"])
    dir2 = rng.choice(["True{}", "False{}"])
    seed_v = rng.randint(1, 1000)
    reuse_iters = rng.randint(5, 25)

    return f"""import Base
{DYN_ZERO}

type Tree is Data:
  Leaf{{v: U32}}
  Node{{l: Tree, r: Tree}}

type Box3 is Data:
  B3A{{a: U32, b: U32, c: U32}}
  B3B{{a: U32, b: U32, c: U32}}

def cmp_swap(a: U32, b: U32, s: Bool, cond: Bool) -> Tree:
  match cond:
    case True{{}}: Node{{Leaf{{b}}, Leaf{{a}}}}
    case False{{}}: Node{{Leaf{{a}}, Leaf{{b}}}}

def swap_flag(a: U32, b: U32, s: Bool) -> Bool:
  match s:
    case True{{}}: U32.is_gt(a, b)
    case False{{}}: U32.is_lt(a, b)

def join_warp(wa: Tree, wb: Tree) -> Tree:
  match wa wb:
    case Node{{aal, aar}} Node{{bbl, bbr}}:
      Node{{Node{{aal, bbl}}, Node{{aar, bbr}}}}
    case _ _: Leaf{{0}}

def warp(a: Tree, b: Tree, +s: Bool) -> Tree:
  match a b:
    case Leaf{{+x}} Leaf{{+y}}: cmp_swap(x, y, s, swap_flag(x, y, s))
    case Node{{al, ar}} Node{{bl, br}}:
      wa wb = warp(al, bl, s) warp(ar, br, s)
      join_warp(wa, wb)
    case _ _: Leaf{{0}}

def wn(t: Tree, +s: Bool) -> Tree:
  match t:
    case Leaf{{v}}: Leaf{{v}}
    case Node{{a, b}}: warp(a, b, s)

def flow(+d: Nat, +s: Bool, w: Tree) -> Tree:
  match d:
    case 0n:
      match w:
        case Leaf{{v}}: Leaf{{v}}
        case Node{{a, b}}: Node{{a, b}}
    case 1n+p:
      match w:
        case Leaf{{v}}: Leaf{{v}}
        case Node{{wa, wb}}:
          fa fb = flow(p, s, wn(wa, s)) flow(p, s, wn(wb, s))
          Node{{fa, fb}}

def mk_tree(+d: Nat, +v: U32) -> Tree:
  match d:
    case 0n: Leaf{{v}}
    case 1n+p: Node{{mk_tree(p, U32.add(U32.mul(v, 1103515245), 12345)), mk_tree(p, U32.add(U32.mul(v, 1664525), 1013904223))}}

def thash(t: Tree) -> U32:
  match t:
    case Leaf{{v}}: U32.add(v, 3)
    case Node{{l, r}}: U32.xor(U32.mul(thash(l), 131), U32.add(thash(r), 17))

def flip_box(b: Box3) -> Box3:
  match b:
    case B3A{{+a, b, c}}: B3B{{U32.add(a, 1), U32.xor(b, a), U32.sub(c, 1)}}
    case B3B{{a, b, +c}}: B3A{{U32.xor(a, c), U32.add(b, 2), U32.add(c, 3)}}

def reuse_loop(n: Nat, b: Box3) -> Box3:
  match n:
    case 0n: b
    case 1n+p: reuse_loop(p, flip_box(b))

def box_hash(b: Box3) -> U32:
  match b:
    case B3A{{a, b, c}}: U32.xor(a, U32.add(U32.mul(b, 31), c))
    case B3B{{a, b, c}}: U32.xor(c, U32.add(U32.mul(a, 37), b))

def main() -> IO(Unit):
  +z = dyn_zero()
  t1 = mk_tree(U32.to_nat(U32.add(z, {d_build})), U32.add(z, {seed_v}))
  r1 = thash(flow(U32.to_nat(U32.add(z, {d_flow1})), {dir1}, t1))
  +sub = mk_tree(2n, U32.add(z, {seed_v + 7}))
  r2 = thash(flow(U32.to_nat(U32.add(z, {d_flow2})), {dir2}, Node{{sub, sub}}))
  r_sub = thash(sub)
  +sh_box : Box3 = B3A{{U32.add(z, 10), 20, 30}}
  rb1 = box_hash(reuse_loop(U32.to_nat(U32.add(z, {reuse_iters})), B3A{{1, 2, 3}}))
  rb2 = U32.xor(box_hash(flip_box(sh_box)), box_hash(sh_box))
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r_sub) ++ "," ++ U32.show(rb1) ++ "," ++ U32.show(rb2))
"""


# =============================================================================
# Family 6: W2D String foldl + U32 Interval + LISTAPP + ARRLIST
# =============================================================================
def gen_family6_w2d_list_arr(rng: random.Random, idx: int) -> str:
    arr_sz = rng.choice([1, 2, 4, 8, 16, 32, 64])
    n_writes = rng.randint(1, min(8, arr_sz))
    w_lines = []
    for _ in range(n_writes):
        wi = rng.randint(0, arr_sz - 1)
        wv = rng.choice([0, 1, 42, 4294967295, rng.randint(0, 1000)])
        w_lines.append(f"  a = a[{wi}] <- U32.add(z, {wv})")

    base_u = rng.choice([4294967285, 4294967290, 4294967294, 4294967295, 0, 1])
    mod_k = rng.choice([0, 1, 2, 5, 10, 16])
    and_m = rng.choice([0, 1, 3, 5, 7, 15])
    str_iters = rng.randint(0, 8)
    s_lit = "".join(rng.choices("abcXYZ019", k=rng.randint(0, 6)))
    uni_lit = rng.choice(["", "αβ", "🚀", "hi"])
    pref_len = rng.randint(0, 6)
    suf_len = rng.randint(0, 6)

    return f"""import Base
{DYN_ZERO}
{COMMON_HELPERS}

type M is Data:
  Gap{{}}
  Tok{{h: U32}}

def pick1(b: Bool) -> Char:
  match b:
    case True{{}}: '+'
    case False{{}}: '-'

def pick2(b: Bool) -> Char:
  match b:
    case True{{}}: '='
    case False{{}}: ':'

def bld1(+u: U32, rest: String) -> String:
  SCon{{pick1(U32.is_ne(U32.and(u, 1), 0)), rest}}

def bld2(+u: U32, rest: String) -> String:
  SCon{{pick2(U32.is_ne(U32.and(u, 2), 0)), rest}}

def step(m: M, +c: U32, acc: U32) -> M & U32:
  match m:
    case Gap{{}}: (Tok{{c}}, U32.add(U32.mul(acc, 31), c))
    case Tok{{h}}: (Gap{{}}, U32.xor(U32.mul(acc, 37), U32.add(h, c)))

def fin(m: M, acc: U32) -> U32:
  match m:
    case Gap{{}}: acc
    case Tok{{h}}: U32.add(acc, h)

def lex(s: String, r: M & U32) -> U32:
  match s:
    case SNil{{}}:
      (m, acc) = r
      fin(m, acc)
    case SCon{{Chr{{c}}, t}}:
      (m, acc) = r
      lex(t, step(m, c, acc))

def lex_loop(n: Nat, +u: U32, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      s = bld1(u, bld2(u, String.append({bend_str_lit(s_lit)}, {bend_str_lit(uni_lit)})))
      lex_loop(p, U32.add(u, 1), lex(s, (Gap{{}}, acc)))

def interval_probe(+x: U32) -> U32:
  +m0 = U32.mod(x, {mod_k})
  +w1 = U32.add({base_u}, m0)
  +w2 = U32.add({base_u}, U32.and(x, {and_m}))
  +c1 = b2u(U32.is_eq(w1, 4294967295))
  +c2 = b2u(U32.is_lt(w1, 10))
  +c3 = b2u(U32.is_ge(w2, {base_u}))
  +c4 = b2u(U32.is_le(w2, 4294967295))
  U32.xor(U32.add(w1, w2), U32.add(c1, U32.add(U32.mul(c2, 2), U32.add(U32.mul(c3, 4), U32.mul(c4, 8)))))

def mk_list(n: Nat, +v: U32) -> List<&2, U32>:
  match n:
    case 0n: Nil{{}}
    case 1n+p: Con{{v, mk_list(p, U32.add(v, 1))}}

def sum_list(xs: List<&2, U32>, acc: U32) -> U32:
  match xs:
    case Nil{{}}: acc
    case Con{{h, t}}: sum_list(t, U32.xor(U32.mul(acc, 31), h))

def sum_list1(xs: List<U32>, acc: U32) -> U32:
  match xs:
    case Nil{{}}: acc
    case Con{{h, t}}: sum_list1(t, U32.xor(U32.mul(acc, 31), h))

def sum_slist1(xs: List<String>, acc: U32) -> U32:
  match xs:
    case Nil{{}}: acc
    case Con{{s, t}}: sum_slist1(t, U32.add(U32.mul(acc, 31), U32.from_nat(String.length(s))))

def static_pref() -> List<&2, U32>:
  Con{{10, Con{{20, Nil{{}}}}}}

def main() -> IO(Unit):
  +z = dyn_zero()
  +r_lex = lex_loop(U32.to_nat(U32.add(z, {str_iters})), z, 7)
  +r_int = U32.xor(interval_probe(z), interval_probe(U32.add(z, 4294967295)))
  +sh_l = mk_list(U32.to_nat(U32.add(z, {pref_len})), 10)
  l1 = List.append(&2, U32, mk_list(U32.to_nat(U32.add(z, {pref_len})), 1), mk_list(U32.to_nat(U32.add(z, {suf_len})), 50))
  l2 = List.append(&2, U32, sh_l, mk_list(U32.to_nat(U32.add(z, {suf_len})), 80))
  l3 = List.append(&2, U32, static_pref(), Con{{99, Nil{{}}}})
  +r_app = U32.xor(sum_list(l1, 0), U32.xor(sum_list(l2, 0), U32.xor(sum_list(sh_l, 0), sum_list(l3, 0))))
  a = [U32.add(z, 3) : U32*{arr_sz}n]
{chr(10).join(w_lines)}
  +r_ar1 = sum_list1(Array.to_list(U32, a), 1)
  b = ["ab" : String*4n]
  b = Array.set(String, b, 1, String.append("z", U32.show(z)))
  +r_ar2 = sum_slist1(Array.to_list(String, b), 1)
  IO.print(U32.show(r_lex) ++ "," ++ U32.show(r_int) ++ "," ++ U32.show(r_app) ++ "," ++ U32.show(r_ar1) ++ "," ++ U32.show(r_ar2))
"""


# =============================================================================
# Family 7: DPLOOP & DEADARR
# =============================================================================
def gen_family7_dp_deadarr(rng: random.Random, idx: int) -> str:
    if idx % 2 == 0:
        return _gen_family7_dploop(rng, idx)
    return _gen_family7_deadarr(rng, idx)


def _gen_family7_dploop(rng: random.Random, idx: int) -> str:
    k = rng.choice([1, 2, 4, 8, 16, 32])
    n_run = rng.choice([0, 1, max(0, k - 1), k, k + 1])
    j_start = rng.choice([0, 0, 0, 1, 4294967290, 4294967295])
    ai_val = rng.choice([0, 1, 7, 77, 4294967295])
    init_vals = [0, 1, 7, 77, 4294967294, 4294967295]

    writes = []
    for arr_name in ("b", "prev", "cur"):
        for _ in range(rng.randint(1, min(6, k))):
            wi = rng.randint(0, k - 1)
            wv = rng.choice(init_vals)
            writes.append(f"  {arr_name} = {arr_name}[{wi}] <- U32.add(z, {wv})")

    use_two_rows = rng.random() < 0.35
    if use_two_rows:
        n_run2 = rng.choice([0, 1, max(0, k - 1), k, k + 1])
        ai_val2 = rng.choice([0, 1, 7, 77, 4294967295])
        setup_block = f"""  a = [0 : U32*{k}n]
  b = [U32.add(z, {rng.choice(init_vals)}) : U32*{k}n]
  prev = [U32.add(z, {rng.choice(init_vals)}) : U32*{k}n]
  cur = [U32.add(z, {rng.choice(init_vals)}) : U32*{k}n]
{chr(10).join(writes)}
  st1 = row(U32.to_nat(U32.add(z, {n_run})), U32.add(z, {j_start}), U32.add(z, {ai_val}), Dp{{a, b, prev, cur}})
  st2 = row(U32.to_nat(U32.add(z, {n_run2})), 0, U32.add(z, {ai_val2}), st1)
  res = hash_dp({k}n, st2)
  IO.print(U32.show(res))"""
    else:
        setup_block = f"""  a = [0 : U32*{k}n]
  b = [U32.add(z, {rng.choice(init_vals)}) : U32*{k}n]
  prev = [U32.add(z, {rng.choice(init_vals)}) : U32*{k}n]
  cur = [U32.add(z, {rng.choice(init_vals)}) : U32*{k}n]
{chr(10).join(writes)}
  res = hash_dp({k}n, row(U32.to_nat(U32.add(z, {n_run})), U32.add(z, {j_start}), U32.add(z, {ai_val}), Dp{{a, b, prev, cur}}))
  IO.print(U32.show(res))"""

    return f"""import Base
{DYN_ZERO}
{COMMON_HELPERS}

type Dp is Type:
  Dp{{a: Array<U32>, b: Array<U32>, prev: Array<U32>, cur: Array<U32>}}

def umin.go(x: U32, y: U32, lt: Bool) -> U32:
  match lt:
    case True{{}}: x
    case False{{}}: y

def umin(+x: U32, +y: U32) -> U32:
  umin.go(x, y, U32.is_lt(x, y))

def cell.f4(+j: U32, cost: U32, diag: U32, up: U32, a: Array<U32>,
            b: Array<U32>, prev: Array<U32>, r: Array<U32> & U32) -> Dp:
  (cur, left) = r
  v = umin(umin(U32.inc(up), U32.inc(left)), U32.add(diag, cost))
  Dp{{a, b, prev, cur[U32.inc(j)] <- v}}

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
  Dp{{a, b, prev, cur}} = st
  cell.f1(j, ai, a, prev, cur, Array.get(U32, b, j))

def row(+n: Nat, +j: U32, +ai: U32, st: Dp) -> Dp:
  match n:
    case 0n:
      Dp{{a, b, prev, cur}} = st
      Dp{{a, b, cur, prev}}
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
  Dp{{a, b, prev, cur}} = st
  h1 = hash_arr.go(sz, 0, (prev, 17))
  h2 = hash_arr.go(sz, 0, (cur, 31))
  U32.xor(U32.mul(h1, 2654435761), h2)

def main() -> IO(Unit):
  +z = dyn_zero()
{setup_block}
"""


def _gen_family7_deadarr(rng: random.Random, idx: int) -> str:
    k = rng.choice([1, 2, 4, 8, 16, 64, 128])
    n1 = rng.choice([0, 1, max(0, k - 1), k, k + 1, k + 5])
    i0 = rng.choice([0, 0, 1, 5, 4294967294])
    seed_v = rng.choice([0, 1, 77, 123456789, 4294967295])
    acc0 = rng.choice([0, 10, 4294967290, 4294967295])
    step_expr = "U32.inc(i)" if rng.random() < 0.7 else "U32.add(i, 2)"

    return f"""import Base
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
    case 1n+q: fold.loop(q, {step_expr}, fold.cell(i, st))

def fold.finish(r: Array<U32> & U32) -> U32:
  (a, acc) = r
  acc

def fold.finish_live2(acc: U32, r: Array<U32> & U32) -> U32:
  (a, v0) = r
  U32.xor(acc, v0)

def fold.finish_live(r: Array<U32> & U32) -> U32:
  (a, acc) = r
  fold.finish_live2(acc, Array.get(U32, a, 0))

def run_dead(+n: U32, seed: U32, acc0: U32) -> U32:
  fold.finish(fold.loop(U32.to_nat(n), {i0}, ([seed : U32*{k}n], acc0)))

def run_live(+n: U32, seed: U32, acc0: U32) -> U32:
  fold.finish_live(fold.loop(U32.to_nat(n), {i0}, ([seed : U32*{k}n], acc0)))

def main() -> IO(Unit):
  +z = dyn_zero()
  +r1 = run_dead(U32.add(z, {n1}), U32.add(z, {seed_v}), U32.add(z, {acc0}))
  +r2 = run_live(U32.add(z, {n1}), U32.add(z, {seed_v}), U32.add(z, {acc0}))
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2))
"""


FAMILIES = [
    ("1_ctfe_arith", gen_family1_ctfe_arith),
    ("2_rorec_adt", gen_family2_rorec_adt),
    ("3_f32_xmm", gen_family3_f32_xmm),
    ("4_map_ops", gen_family4_map_ops),
    ("5_bst_flow_reuse", gen_family5_bst_flow_reuse),
    ("6_w2d_list_arr", gen_family6_w2d_list_arr),
    ("7_dp_deadarr", gen_family7_dp_deadarr),
]


def run_upstream(src: Path) -> tuple[bool, str]:
    try:
        r = subprocess.run(
            [str(BUN), str(ROOT / "bend2/main.ts"), str(src)],
            capture_output=True, text=True, timeout=45,
        )
        if r.returncode != 0:
            return False, f"UP_ERR({r.returncode}): {r.stderr.strip()[:240]}"
        return True, r.stdout
    except subprocess.TimeoutExpired:
        return False, "UP_TIMEOUT"


def batch_emit(api: Path, jobs: list, manifest: Path) -> dict:
    manifest.write_text(json.dumps(jobs))
    r = subprocess.run(
        [NODE, "--stack-size=8192", str(BATCH_EMIT), str(api), str(manifest)],
        capture_output=True, text=True, timeout=900,
    )
    if r.returncode != 0:
        raise RuntimeError(f"batch_emit failed rc={r.returncode}: {r.stderr[:400]}")
    return {item["id"]: item for item in json.loads(r.stdout)}


def link_run_cleanup(obj: Path, rt: Path, exe: Path) -> tuple[bool, str]:
    try:
        r_cc = subprocess.run(
            [CC, "-no-pie", str(obj), str(rt), "-pthread", "-lm", "-o", str(exe)],
            capture_output=True, text=True, timeout=30,
        )
        if r_cc.returncode != 0:
            return False, f"LINK_ERR: {r_cc.stderr.strip()[:240]}"
        try:
            r_run = subprocess.run(
                [str(exe), *RTS_ARGS],
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
    ap.add_argument("--seed", type=int, default=20261122)
    ap.add_argument("--per-family", type=int, default=35)
    ap.add_argument("--workers", type=int, default=8)
    ap.add_argument("--out-json", type=Path, default=None)
    ap.add_argument("--only-family", type=str, default=None)
    args = ap.parse_args()

    t0 = time.perf_counter()
    WORK_DIR.mkdir(parents=True, exist_ok=True)
    src_dir = WORK_DIR / "src"
    obj_dir = WORK_DIR / "obj"
    exe_dir = WORK_DIR / "exe"
    for d in (src_dir, obj_dir, exe_dir):
        d.mkdir(parents=True, exist_ok=True)

    # Generate all programs deterministically
    cases = []
    seen_hashes = set()
    for f_idx, (fname, gen_fn) in enumerate(FAMILIES):
        if args.only_family and fname != args.only_family:
            continue
        fam_rng = random.Random(args.seed + f_idx * 100003)
        generated = 0
        attempt = 0
        while generated < args.per_family and attempt < args.per_family * 5:
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

    print(f"Generated {len(cases)} distinct programs ({args.per_family}/family, seed={args.seed})", flush=True)

    # Step 1: Run Wave 2 batch_emit + Upstream oracle in parallel!
    t_emit = time.perf_counter()
    w2_jobs = [{"id": c["id"], "src": str(c["src"]), "out": str(c["obj"])} for c in cases]
    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        f_w2 = ex.submit(batch_emit, W2_API, w2_jobs, WORK_DIR / "w2_manifest.json")
        f_ups = {c["id"]: ex.submit(run_upstream, c["src"]) for c in cases}
        w2_emitted = f_w2.result()
        up_results = {cid: fut.result() for cid, fut in f_ups.items()}
    emit_sec = round(time.perf_counter() - t_emit, 2)
    print(f"Wave 2 batch emit + Upstream oracle finished in {emit_sec:.2f}s", flush=True)

    # Step 2: Link & execute all Wave 2 objects in parallel, deleting .o/.exe immediately
    t_exec = time.perf_counter()
    w2_run_results = {}
    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        futs = {}
        for c in cases:
            cid = c["id"]
            em = w2_emitted[cid]
            if not em["ok"]:
                w2_run_results[cid] = (False, f"W2_{em['stage'].upper()}_ERR: {em['error'][:240]}")
                c["obj"].unlink(missing_ok=True)
            else:
                futs[ex.submit(link_run_cleanup, c["obj"], AGY_RT, c["exe"])] = cid
        for fut in as_completed(futs):
            w2_run_results[futs[fut]] = fut.result()
    exec_sec = round(time.perf_counter() - t_exec, 2)
    print(f"Wave 2 link + exec finished in {exec_sec:.2f}s", flush=True)

    # Step 3: Compare results & isolate any mismatch against Phase 205
    family_stats = {fname: {"total": 0, "pass": 0, "fail": 0, "up_err": 0} for fname, _ in FAMILIES}
    mismatches = []
    for c in cases:
        cid = c["id"]
        fname = c["family"]
        family_stats[fname]["total"] += 1
        up_ok, up_out = up_results[cid]
        w2_ok, w2_out = w2_run_results[cid]
        if not up_ok:
            family_stats[fname]["up_err"] += 1
            mismatches.append({"id": cid, "family": fname, "kind": "upstream_error", "up": up_out, "w2": w2_out, "src": str(c["src"])})
        elif w2_ok and up_out == w2_out:
            family_stats[fname]["pass"] += 1
            c["src"].unlink(missing_ok=True)
        else:
            family_stats[fname]["fail"] += 1
            mismatches.append({"id": cid, "family": fname, "kind": "mismatch", "up": up_out, "w2": w2_out, "src": str(c["src"])})

    # Isolate mismatches with Phase 205
    real_mismatches = [m for m in mismatches if m["kind"] == "mismatch"]
    if real_mismatches:
        print(f"!!! FOUND {len(real_mismatches)} MISMATCH(ES) — isolating with Phase 205...", flush=True)
        p205_jobs = [{"id": m["id"], "src": m["src"], "out": str(obj_dir / f"{m['id']}.p205.o")} for m in real_mismatches]
        p205_em = batch_emit(BASE_API, p205_jobs, WORK_DIR / "p205_manifest.json")
        for m in real_mismatches:
            cid = m["id"]
            em = p205_em[cid]
            if not em["ok"]:
                m["p205"] = f"P205_{em['stage'].upper()}_ERR: {em['error'][:240]}"
            else:
                ok, out = link_run_cleanup(obj_dir / f"{cid}.p205.o", P205_RT, exe_dir / f"{cid}.p205.exe")
                m["p205"] = out if ok else out
            print(f"  FAIL {cid}: up={m['up'].strip()!r} | w2={m['w2'].strip()!r} | p205={m['p205'].strip()!r}", flush=True)

    total_sec = round(time.perf_counter() - t0, 2)
    total_pass = sum(s["pass"] for s in family_stats.values())
    total_all = sum(s["total"] for s in family_stats.values())
    total_up_err = sum(s["up_err"] for s in family_stats.values())
    total_fail = sum(s["fail"] for s in family_stats.values())

    print("\n=== WAVE 3 DIFFERENTIAL FUZZER SUMMARY ===")
    for fname, st in family_stats.items():
        print(f"  {fname:20s}: {st['pass']:3d}/{st['total']:3d} PASS (fail={st['fail']}, up_err={st['up_err']})")
    print(f"  TOTAL               : {total_pass:3d}/{total_all:3d} PASS (fail={total_fail}, up_err={total_up_err}) in {total_sec:.2f}s")

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
