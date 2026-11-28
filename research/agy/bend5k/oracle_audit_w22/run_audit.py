#!/usr/bin/env python3
"""L22-ORACLE-DIFF: 5-Way Oracle Soundness & Metamorphic Differential Audit.

Compares 5 independent oracles on identical well-typed Bend sources (all pinned to CPU 4):
  1. Independent Python Reference Oracle (mathematical / operational ground truth)
  2. Upstream JS (bend2/main.ts @ 6180be5b, -o out.js + node)
  3. Upstream C  (bend2/main.ts @ 6180be5b, -o out.c + gcc-10 -std=c11 -O2, musttail stripped)
  4. bend5k -O0  (bend5k_o2 -O0 @ 2f59e12b + runtime-agy.o)
  5. bend5k -O2  (bend5k_o2 -O2 @ 2f59e12b + runtime-agy.o)

Strictly separates:
  - Group A: Ordinary, well-typed, fully defined, in-range programs + metamorphic pairs
  - Group B: Boundary & specification-edge probes (F32.show, Nat 2^48 overflow / #2181,
             Nat >2^32-1 literals, U32 wrap/shift/div0, Nat sub underflow/div0,
             F32.to_u32, Char/String escapes)
"""
from __future__ import annotations

import argparse
import collections
import json
import math
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

ROOT = Path("/home/ai/bend2_agy")
OUT_DIR = Path(__file__).resolve().parent
LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"
NODE = Path("/home/ai/.nvm/versions/node/v24.22.1/bin/node")
BEND5K = ROOT / "selfhost/build/agy/bend5k/bend5k_o2"
RUNTIME_AGY = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
GCC = "gcc"
CPU_PIN = 4


@dataclass
class Case:
    id: str
    group: str          # "A" or "B"
    family: str
    description: str
    code: str
    py_oracle: Optional[str]   # exact expected stdout (with trailing \n) or None if spec-open/error
    py_note: str = ""
    pair_id: Optional[str] = None
    pair_side: Optional[str] = None  # "a" or "b"


# =============================================================================
# GROUP A: ORDINARY, WELL-TYPED, FULLY DEFINED, IN-RANGE PROGRAMS
# =============================================================================

def gen_group_a_u32() -> list[Case]:
    """Family 1: Strictly in-range U32 arithmetic, bitwise, comparisons, precedence."""
    cases: list[Case] = []

    arith_specs = [
        ("u32_add_basic", 123456, 789012, "add", lambda a, b: a + b),
        ("u32_add_hi31", 2147483640, 100, "add", lambda a, b: a + b),
        ("u32_sub_basic", 987654, 123456, "sub", lambda a, b: a - b),
        ("u32_sub_hi31", 3000000000, 1000000000, "sub", lambda a, b: a - b),
        ("u32_sub_eq_zero", 424242, 424242, "sub", lambda a, b: a - b),
        ("u32_mul_basic", 12345, 6789, "mul", lambda a, b: a * b),
        ("u32_mul_hi31", 65535, 65535, "mul", lambda a, b: a * b),
        ("u32_div_basic", 1000000, 7, "div", lambda a, b: a // b),
        ("u32_div_hi31", 3500000000, 1000000000, "div", lambda a, b: a // b),
        ("u32_div_hi31_by_hi31", 4000000000, 2500000000, "div", lambda a, b: a // b),
        ("u32_mod_basic", 1000000, 7, "mod", lambda a, b: a % b),
        ("u32_mod_hi31", 3500000007, 1000000000, "mod", lambda a, b: a % b),
        ("u32_and_hi31", 0xF0F0F0F0, 0x3C3C3C3C, "and", lambda a, b: a & b),
        ("u32_or_hi31", 0x80001234, 0x00FF0001, "or", lambda a, b: a | b),
        ("u32_xor_hi31", 0xAAAA5555, 0x8000FFFF, "xor", lambda a, b: a ^ b),
    ]
    for cid, a, b, op, fn in arith_specs:
        expected = f"{fn(a, b)}\n"
        code = f"""import Base

def compute(x: U32, y: U32) -> U32:
  U32.{op}(x, y)

def main() -> IO(Unit):
  IO.print(U32.show(compute({a}, {b})))
"""
        cases.append(Case(cid, "A", "u32_arith_inrange", f"U32.{op}({a}, {b})", code, expected))

    shift_specs = [
        ("u32_shln_0", 12345, 0, "shln", lambda a, s: a << s),
        ("u32_shln_7", 12345, 7, "shln", lambda a, s: a << s),
        ("u32_shln_31", 1, 31, "shln", lambda a, s: a << s),
        ("u32_shrn_1_hi31", 3000000000, 1, "shrn", lambda a, s: a >> s),
        ("u32_shrn_16_hi31", 0xABCD1234, 16, "shrn", lambda a, s: a >> s),
        ("u32_shrn_31_hi31", 0x80000000, 31, "shrn", lambda a, s: a >> s),
    ]
    for cid, a, s, op, fn in shift_specs:
        expected = f"{fn(a, s)}\n"
        code = f"""import Base

def compute(x: U32, k: Nat) -> U32:
  U32.{op}(x, k)

def main() -> IO(Unit):
  IO.print(U32.show(compute({a}, {s}n)))
"""
        cases.append(Case(cid, "A", "u32_arith_inrange", f"U32.{op}({a}, {s}n)", code, expected))

    cmp_pairs = [(10, 20), (20, 20), (3000000000, 1000000000), (1000000000, 3000000000), (4294967295, 0)]
    py_parts = []
    bend_lines = []
    for i, (a, b) in enumerate(cmp_pairs):
        lt = "True" if a < b else "False"
        le = "True" if a <= b else "False"
        gt = "True" if a > b else "False"
        ge = "True" if a >= b else "False"
        eq = "True" if a == b else "False"
        py_parts.append(f"{lt},{le},{gt},{ge},{eq}")
        bend_lines.append(
            f'  r{i} = Bool.show(U32.is_lt({a}, {b})) ++ "," ++ Bool.show(U32.is_le({a}, {b})) ++ "," '
            f'++ Bool.show(U32.is_gt({a}, {b})) ++ "," ++ Bool.show(U32.is_ge({a}, {b})) ++ "," '
            f'++ Bool.show(U32.is_eq({a}, {b}))'
        )
    code = "import Base\n\ndef run_cmps() -> String:\n" + "\n".join(bend_lines) + "\n  " + ' ++ ";" ++ '.join(f"r{i}" for i in range(len(cmp_pairs))) + "\n\ndef main() -> IO(Unit):\n  IO.print(run_cmps())\n"
    cases.append(Case("u32_unsigned_cmps_hi31", "A", "u32_arith_inrange", "Unsigned U32 comparisons across 2^31 boundary", code, ";".join(py_parts) + "\n"))

    a, b = 0x12345678, 123456
    pop = bin(a).count("1")
    lg2 = a.bit_length() - 1
    ctz = (a & -a).bit_length() - 1
    mn, mx = min(a, b), max(a, b)
    clmp = max(100, min(500, 350))
    pw = 3 ** 12
    code = f"""import Base

def main() -> IO(Unit):
  p = Nat.show(U32.popcount({a}))
  l = Nat.show(U32.log2({a}))
  c = Nat.show(U32.ctz({a}))
  m1 = U32.show(U32.min({a}, {b}))
  m2 = U32.show(U32.max({a}, {b}))
  cl = U32.show(U32.clamp(350, 100, 500))
  pw = U32.show(U32.pow(3, 12n))
  IO.print(p ++ "," ++ l ++ "," ++ c ++ "," ++ m1 ++ "," ++ m2 ++ "," ++ cl ++ "," ++ pw)
"""
    cases.append(Case("u32_bit_and_math_helpers", "A", "u32_arith_inrange", "U32.popcount/log2/ctz/min/max/clamp/pow", code, f"{pop},{lg2},{ctz},{mn},{mx},{clmp},{pw}\n"))

    r1 = (100 - 30) - 10
    r2 = (100 // 5) // 2
    r3 = 2 + 3 * 4
    r4 = 4 | (2 & 3)
    r5 = 7 ^ (6 & 3)
    code = """import Base

def prec(+a: U32, b: U32, c: U32) -> String:
  x1 = (a - b - c : U32)
  x2 = (a / 5 / 2 : U32)
  x3 = (2 + 3 * 4 : U32)
  x4 = (4 .|. 2 .&. 3 : U32)
  x5 = (7 .^. 6 .&. 3 : U32)
  U32.show(x1) ++ "," ++ U32.show(x2) ++ "," ++ U32.show(x3) ++ "," ++ U32.show(x4) ++ "," ++ U32.show(x5)

def main() -> IO(Unit):
  IO.print(prec(100, 30, 10))
"""
    cases.append(Case("u32_operator_precedence", "A", "u32_arith_inrange", "U32 operator precedence & left associativity", code, f"{r1},{r2},{r3},{r4},{r5}\n"))

    def py_poly(x: int) -> int:
        s = x * x + 3 * x + 7
        return (s // 5) * 10 + (s % 5)
    val = sum(py_poly(i) for i in range(1, 21))
    code = """import Base

def poly(+x: U32) -> U32:
  +s = U32.add(U32.mul(x, x), U32.add(U32.mul(3, x), 7))
  U32.add(U32.mul(U32.div(s, 5), 10), U32.mod(s, 5))

def loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop(p, U32.add(acc, poly(U32.from_nat(n))))

def main() -> IO(Unit):
  IO.print(U32.show(loop(20n, 0)))
"""
    cases.append(Case("u32_poly_loop_20", "A", "u32_arith_inrange", "Dynamic U32 polynomial loop over 1..20", code, f"{val}\n"))

    return cases


def gen_group_a_nat() -> list[Case]:
    """Family 2: Strictly in-range Nat arithmetic (including wide >2^32 and <2^48 built from valid <=2^32-1 literals)."""
    cases: list[Case] = []

    def nat_expr(n: int) -> str:
        if n <= 4294967295:
            return f"{n}n"
        q, r = divmod(n, 1000000000)
        base = f"Nat.mul({q}n, 1000000000n)"
        return base if r == 0 else f"Nat.add({base}, {r}n)"

    nat_specs = [
        ("nat_add_small", 12345, 67890, "add", lambda a, b: a + b),
        ("nat_add_wide_33bit", 5000000000, 3000000000, "add", lambda a, b: a + b),
        ("nat_add_near_47bit", (1 << 46) + 123, (1 << 46) + 456, "add", lambda a, b: a + b),
        ("nat_sub_small", 99999, 12345, "sub", lambda a, b: a - b),
        ("nat_sub_wide", 10000000000, 4294967296, "sub", lambda a, b: a - b),
        ("nat_sub_exact_zero", 5000000000, 5000000000, "sub", lambda a, b: a - b),
        ("nat_mul_small", 12345, 6789, "mul", lambda a, b: a * b),
        ("nat_mul_wide_40bit", 1000000, 1000000, "mul", lambda a, b: a * b),
        ("nat_mul_wide_47bit", 10000000, 14000000, "mul", lambda a, b: a * b),
        ("nat_div_small", 1234567, 97, "div", lambda a, b: a // b),
        ("nat_div_wide", 100000000000, 3333333, "div", lambda a, b: a // b),
        ("nat_div_wide_gt32_divisor", 100000000000000, 5000000000, "div", lambda a, b: a // b),
        ("nat_mod_small", 1234567, 97, "mod", lambda a, b: a % b),
        ("nat_mod_wide", 100000000007, 5000000000, "mod", lambda a, b: a % b),
        ("nat_min_wide", 5000000001, 5000000000, "min", lambda a, b: min(a, b)),
        ("nat_max_wide", 5000000001, 5000000000, "max", lambda a, b: max(a, b)),
    ]
    for cid, a, b, op, fn in nat_specs:
        expected = f"{fn(a, b)}\n"
        code = f"""import Base

def compute(x: Nat, y: Nat) -> Nat:
  Nat.{op}(x, y)

def main() -> IO(Unit):
  IO.print(Nat.show(compute({nat_expr(a)}, {nat_expr(b)})))
"""
        cases.append(Case(cid, "A", "nat_arith_inrange", f"Nat.{op}({a}n, {b}n)", code, expected))

    a_w = 5000000000
    code = f"""import Base

def main() -> IO(Unit):
  +aw = {nat_expr(a_w)}
  +d = Nat.double(aw)
  +s : Nat = Succ{{Succ{{Succ{{aw}}}}}}
  c1 = Bool.show(Nat.is_lt(aw, d))
  c2 = Bool.show(Nat.is_eq(Nat.sub(s, 3n), aw))
  c3 = Bool.show(Nat.is_gt(d, {nat_expr(4294967296)}))
  IO.print(Nat.show(d) ++ "," ++ Nat.show(s) ++ "," ++ c1 ++ "," ++ c2 ++ "," ++ c3)
"""
    cases.append(Case("nat_wide_double_succ_cmp", "A", "nat_arith_inrange", "Wide Nat.double, Succ peeling, and comparisons >2^32", code, f"{a_w*2},{a_w+3},True,True,True\n"))

    code = """import Base

def main() -> IO(Unit):
  IO.print(Nat.show(Nat.pow(3n, 25n)))
"""
    cases.append(Case("nat_pow_3_25", "A", "nat_arith_inrange", "Nat.pow(3n, 25n) = 847288609443 (>2^39, <2^48)", code, f"{3**25}\n"))

    vals = [0, 1, 65535, 2147483647, 2147483648, 4294967295]
    code = "import Base\n\ndef rt(x: U32) -> U32:\n  U32.from_nat(U32.to_nat(x))\n\ndef main() -> IO(Unit):\n  IO.print(" + ' ++ "," ++ '.join(f"U32.show(rt({v}))" for v in vals) + ")\n"
    cases.append(Case("nat_u32_roundtrip_inrange", "A", "nat_arith_inrange", "U32.from_nat(U32.to_nat(x)) across full U32 range", code, ",".join(str(v) for v in vals) + "\n"))

    code = f"""import Base

def peel(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n: 10n
    case 2n: 20n
    case 3n+rest: Nat.add(30n, rest)

def main() -> IO(Unit):
  IO.print(Nat.show(peel(0n)) ++ "," ++ Nat.show(peel(1n)) ++ "," ++ Nat.show(peel(2n)) ++ "," ++ Nat.show(peel({nat_expr(5000000003)})))
"""
    cases.append(Case("nat_peel_wide", "A", "nat_arith_inrange", "Nat pattern match 0n/1n/2n/3n+rest on wide Nat", code, "0,10,20,5000000030\n"))

    return cases


def gen_group_a_adt() -> list[Case]:
    """Family 3: Constructors, nested ADTs, AST evaluator, trees, enums, polymorphic ADTs."""
    cases: list[Case] = []

    def py_tree_sum(d: int, v: int) -> int:
        if d == 0:
            return v
        return v + py_tree_sum(d - 1, v * 2 + 1) + py_tree_sum(d - 1, v * 2 + 2)

    for depth in [0, 1, 3, 5, 7]:
        s = py_tree_sum(depth, 1)
        code = f"""import Base

type Tree is Data:
  Leaf{{v: U32}}
  Node{{v: U32, l: Tree, r: Tree}}

def mk(+d: Nat, +v: U32) -> Tree:
  match d:
    case 0n: Leaf{{v}}
    case 1n+p: Node{{v, mk(p, U32.add(U32.mul(v, 2), 1)), mk(p, U32.add(U32.mul(v, 2), 2))}}

def tsum(t: Tree) -> U32:
  match t:
    case Leaf{{v}}: v
    case Node{{v, l, r}}: U32.add(v, U32.add(tsum(l), tsum(r)))

def mirror(t: Tree) -> Tree:
  match t:
    case Leaf{{v}}: Leaf{{v}}
    case Node{{v, l, r}}: Node{{v, mirror(r), mirror(l)}}

def main() -> IO(Unit):
  IO.print(U32.show(tsum(mirror(mk({depth}n, 1)))))
"""
        cases.append(Case(f"adt_tree_mirror_sum_d{depth}", "A", "adt_nested_match", f"Binary tree build+mirror+sum depth {depth}", code, f"{s}\n"))

    code = """import Base

type Expr is Data:
  ELit{v: U32}
  EAdd{a: Expr, b: Expr}
  ESub{a: Expr, b: Expr}
  EMul{a: Expr, b: Expr}
  EIfZ{c: Expr, t: Expr, f: Expr}

def pick_u32(cond: U32, vt: U32, vf: U32) -> U32:
  match cond:
    case 0: vt
    case _: vf

def eval(e: Expr) -> U32:
  match e:
    case ELit{v}: v
    case EAdd{a, b}: U32.add(eval(a), eval(b))
    case ESub{a, b}: U32.sub(eval(a), eval(b))
    case EMul{a, b}: U32.mul(eval(a), eval(b))
    case EIfZ{c, t, f}: pick_u32(eval(c), eval(t), eval(f))

def main() -> IO(Unit):
  e1 : Expr = EIfZ{ESub{ELit{10}, ELit{10}}, EMul{EAdd{ELit{7}, ELit{8}}, ESub{ELit{20}, ELit{6}}}, ELit{999}}
  e2 : Expr = EIfZ{ELit{3}, ELit{999}, EAdd{EMul{ELit{4}, ELit{5}}, ELit{11}}}
  IO.print(U32.show(eval(e1)) ++ "," ++ U32.show(eval(e2)))
"""
    cases.append(Case("adt_expr_ast_eval", "A", "adt_nested_match", "5-constructor Expr AST evaluator", code, "210,31\n"))

    code = """import Base

type Tok is Data:
  TZero{}
  TOne{}
  TNum{v: U32}
  TPair{a: U32, b: U32}
  TTriple{a: U32, b: U32, c: U32}
  TFlag{f: Bool, v: U32}
  TWrap{inner: Tok}
  TCombine{x: Tok, y: Tok}

def score(t: Tok) -> U32:
  match t:
    case TZero{}: 1
    case TOne{}: 2
    case TNum{v}: v
    case TPair{a, b}: U32.add(a, U32.mul(b, 2))
    case TTriple{a, b, c}: U32.add(a, U32.add(U32.mul(b, 3), U32.mul(c, 5)))
    case TFlag{False{}, v}: v
    case TFlag{True{}, v}: U32.mul(v, 10)
    case TWrap{inner}: U32.add(100, score(inner))
    case TCombine{x, y}: U32.add(score(x), score(y))

def main() -> IO(Unit):
  t : Tok = TCombine{
    TCombine{TZero{}, TOne{}},
    TCombine{
      TCombine{TNum{7}, TPair{3, 4}},
      TCombine{TTriple{2, 5, 6}, TCombine{TFlag{True{}, 9}, TWrap{TFlag{False{}, 8}}}}
    }
  }
  IO.print(U32.show(score(t)))
"""
    cases.append(Case("adt_8ctor_mixed_payloads", "A", "adt_nested_match", "8-constructor mixed nullary & nested payload ADT", code, "266\n"))

    code = """import Base

type Box is Data:
  BEmpty{}
  BVal{x: U32}
  BNest{b: Box}

def deep(b: Box) -> U32:
  match b:
    case BNest{BNest{BNest{BVal{x}}}}: U32.add(x, 1000)
    case BNest{BNest{BVal{x}}}: U32.add(x, 100)
    case BNest{BVal{x}}: U32.add(x, 10)
    case BVal{x}: x
    case _: 7777

def main() -> IO(Unit):
  r1 = deep(BNest{BNest{BNest{BVal{5}}}})
  r2 = deep(BNest{BNest{BVal{6}}})
  r3 = deep(BNest{BVal{7}})
  r4 = deep(BVal{8})
  r5 = deep(BNest{BNest{BEmpty{}}})
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r3) ++ "," ++ U32.show(r4) ++ "," ++ U32.show(r5))
"""
    cases.append(Case("adt_deep_4level_match", "A", "adt_nested_match", "4-level nested ADT match with wildcard fallback", code, "1005,106,17,8,7777\n"))

    code = """import Base

def safe_div(a: U32, +b: U32) -> Maybe<&2, U32>:
  match b:
    case 0: None{}
    case _: Some{U32.div(a, b)}

def unwrap_or(m: Maybe<&2, U32>, d: U32) -> U32:
  match m:
    case None{}: d
    case Some{v}: v

def either_val(e: Either<&2, &2, U32, U32>) -> U32:
  match e:
    case Inl{v}: U32.mul(v, 2)
    case Inr{v}: U32.add(v, 50)

def main() -> IO(Unit):
  a = unwrap_or(safe_div(100, 4), 999)
  b = unwrap_or(safe_div(100, 0), 999)
  c = either_val(Inl{15})
  d = either_val(Inr{15})
  IO.print(U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d))
"""
    cases.append(Case("adt_poly_maybe_either", "A", "adt_nested_match", "Polymorphic Maybe and Either", code, "25,999,30,65\n"))

    def py_tern(d: int, v: int) -> int:
        if d == 0:
            return v
        return v + py_tern(d - 1, v + 1) + py_tern(d - 1, v + 2) + py_tern(d - 1, v + 3)

    for depth in [1, 3, 4]:
        s = py_tern(depth, 1)
        code = f"""import Base

type Tern is Data:
  TLeaf{{v: U32}}
  TNode{{v: U32, a: Tern, b: Tern, c: Tern}}

def mk(+d: Nat, +v: U32) -> Tern:
  match d:
    case 0n: TLeaf{{v}}
    case 1n+p: TNode{{v, mk(p, U32.add(v, 1)), mk(p, U32.add(v, 2)), mk(p, U32.add(v, 3))}}

def tsum(t: Tern) -> U32:
  match t:
    case TLeaf{{v}}: v
    case TNode{{v, a, b, c}}: U32.add(U32.add(v, tsum(a)), U32.add(tsum(b), tsum(c)))

def main() -> IO(Unit):
  IO.print(U32.show(tsum(mk({depth}n, 1))))
"""
        cases.append(Case(f"adt_ternary_tree_d{depth}", "A", "adt_nested_match", f"Ternary tree sum depth {depth}", code, f"{s}\n"))

    for depth in [2, 5]:
        def py_s(d, v):
            return v if d == 0 else v + py_s(d - 1, v + 1) + py_s(d - 1, v + 2)
        code = f"""import Base

type Tree is Data:
  Leaf{{v: U32}}
  Node{{v: U32, l: Tree, r: Tree}}

def mk(+d: Nat, +v: U32) -> Tree:
  match d:
    case 0n: Leaf{{v}}
    case 1n+p: Node{{v, mk(p, U32.add(v, 1)), mk(p, U32.add(v, 2))}}

def tcount(+t: Tree) -> U32:
  match t:
    case Leaf{{v}}: 1
    case Node{{v, l, r}}: U32.add(1, U32.add(tcount(l), tcount(r)))

def tdepth(+t: Tree) -> U32:
  match t:
    case Leaf{{v}}: 1
    case Node{{v, l, r}}: U32.add(1, U32.max(tdepth(l), tdepth(r)))

def tsum(t: Tree) -> U32:
  match t:
    case Leaf{{v}}: v
    case Node{{v, l, r}}: U32.add(v, U32.add(tsum(l), tsum(r)))

def main() -> IO(Unit):
  +t = mk({depth}n, 1)
  c = tcount(t)
  d = tdepth(t)
  s = tsum(t)
  IO.print(U32.show(c) ++ "," ++ U32.show(d) ++ "," ++ U32.show(s))
"""
        cases.append(Case(f"adt_borrowed_tree_multi_read_d{depth}", "A", "adt_nested_match", f"Borrowed tree count+depth then owned sum depth {depth}", code, f"{(1<<(depth+1))-1},{depth+1},{py_s(depth, 1)}\n"))

    xs = list(range(1, 16))
    rev = list(reversed(xs))
    wsum = sum((i + 1) * v for i, v in enumerate(rev))
    code = """import Base

def mk_list(n: Nat, +cur: U32) -> List<&2, U32>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{cur, mk_list(p, U32.add(cur, 1))}

def rev_go(xs: List<&2, U32>, acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: acc
    case Con{h, t}: rev_go(t, Con{h, acc})

def wsum(xs: List<&2, U32>, +idx: U32, +acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{h, t}: wsum(t, U32.add(idx, 1), U32.add(acc, U32.mul(idx, h)))

def main() -> IO(Unit):
  IO.print(U32.show(wsum(rev_go(mk_list(15n, 1), Nil{}), 1, 0)))
"""
    cases.append(Case("adt_list_reverse_weighted_sum", "A", "adt_nested_match", "List build, reverse, and weighted sum", code, f"{wsum}\n"))

    a, b, c, d, v = 1, 100, True, 2, 5
    for _ in range(10):
        if c:
            a, b, c, d, v = a + v, b + 10, False, d + 1, v + 2
        else:
            a, b, c, d, v = a + d, b + 5, True, d + 3, v + 1
    code = """import Base

type Rec is Data:
  MkRec{a: U32, b: Nat, c: Bool, d: U32, e: Maybe<&2, U32>}

def step(+r: Rec) -> Rec:
  match r:
    case MkRec{a, b, True{}, d, Some{v}}:
      MkRec{U32.add(a, v), Nat.add(b, 10n), False{}, U32.add(d, 1), Some{U32.add(v, 2)}}
    case MkRec{a, b, False{}, d, Some{v}}:
      MkRec{U32.add(a, d), Nat.add(b, 5n), True{}, U32.add(d, 3), Some{U32.add(v, 1)}}
    case MkRec{a, b, c, d, None{}}:
      MkRec{a, b, c, d, None{}}

def run(n: Nat, r: Rec) -> Rec:
  match n:
    case 0n: r
    case 1n+p: run(p, step(r))

def show_rec(r: Rec) -> String:
  match r:
    case MkRec{a, b, c, d, Some{v}}:
      U32.show(a) ++ "," ++ Nat.show(b) ++ "," ++ Bool.show(c) ++ "," ++ U32.show(d) ++ "," ++ U32.show(v)
    case _: "NONE"

def main() -> IO(Unit):
  IO.print(show_rec(run(10n, MkRec{1, 100n, True{}, 2, Some{5}})))
"""
    cases.append(Case("adt_mixed_record_state_loop", "A", "adt_nested_match", "Mixed U32/Nat/Bool/Maybe record threaded through 10 iterations", code, f"{a},{b},{c},{d},{v}\n"))

    enum_vals = [(i * 7 + 3) % 12 for i in range(12)]
    enum_sum = sum((v * v + 1) for v in enum_vals)
    code = """import Base

type Color is Data:
  C0{} C1{} C2{} C3{} C4{} C5{} C6{} C7{} C8{} C9{} C10{} C11{}

def to_c(x: U32) -> Color:
  match x:
    case 0: C0{} case 1: C1{} case 2: C2{} case 3: C3{}
    case 4: C4{} case 5: C5{} case 6: C6{} case 7: C7{}
    case 8: C8{} case 9: C9{} case 10: C10{} case _: C11{}

def from_c(c: Color) -> U32:
  match c:
    case C0{}: 1 case C1{}: 2 case C2{}: 5 case C3{}: 10
    case C4{}: 17 case C5{}: 26 case C6{}: 37 case C7{}: 50
    case C8{}: 65 case C9{}: 82 case C10{}: 101 case C11{}: 122

def loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      idx = U32.mod(U32.add(U32.mul(U32.from_nat(p), 7), 3), 12)
      loop(p, U32.add(acc, from_c(to_c(idx))))

def main() -> IO(Unit):
  IO.print(U32.show(loop(12n, 0)))
"""
    cases.append(Case("adt_12_nullary_enum_roundtrip", "A", "adt_nested_match", "12-variant nullary enum roundtrip", code, f"{enum_sum}\n"))

    return cases


def gen_group_a_multi_match() -> list[Case]:
    """Family 4: Multi-scrutinee & nested pattern matching decision trees."""
    cases: list[Case] = []

    code = """import Base

def f(a: Bool, b: Bool) -> U32:
  match a b:
    case True{} True{}: 11
    case True{} False{}: 10
    case False{} True{}: 1
    case False{} False{}: 0

def main() -> IO(Unit):
  IO.print(U32.show(f(True{}, True{})) ++ "," ++ U32.show(f(True{}, False{})) ++ "," ++ U32.show(f(False{}, True{})) ++ "," ++ U32.show(f(False{}, False{})))
"""
    cases.append(Case("match_2scrut_bool_bool", "A", "multi_scrutinee_match", "2-scrutinee Bool x Bool match", code, "11,10,1,0\n"))

    def py_f3(a, b, c):
        if a and b and c: return 100
        if a and not c: return 200
        if not a and b: return 300
        if c: return 400
        return 500
    outs = [str(py_f3(a, b, c)) for a in [True, False] for b in [True, False] for c in [True, False]]
    calls = [f"U32.show(f({'True{}' if a else 'False{}'}, {'True{}' if b else 'False{}'}, {'True{}' if c else 'False{}'}))"
             for a in [True, False] for b in [True, False] for c in [True, False]]
    code = (
        "import Base\n\n"
        "def f(a: Bool, b: Bool, c: Bool) -> U32:\n"
        "  match a b c:\n"
        "    case True{} True{} True{}: 100\n"
        "    case True{} _ False{}: 200\n"
        "    case False{} True{} _: 300\n"
        "    case _ _ True{}: 400\n"
        "    case _ _ _: 500\n\n"
        "def main() -> IO(Unit):\n"
        "  IO.print(" + ' ++ "," ++ '.join(calls) + ")\n"
    )
    cases.append(Case("match_3scrut_overlapping_wildcards", "A", "multi_scrutinee_match", "3-scrutinee overlapping wildcard decision tree", code, ",".join(outs) + "\n"))

    code = """import Base

def comb(x: Maybe<&2, U32>, y: Maybe<&2, U32>) -> U32:
  match x y:
    case None{} None{}: 0
    case Some{a} None{}: U32.add(a, 10)
    case None{} Some{b}: U32.add(b, 20)
    case Some{a} Some{b}: U32.add(U32.mul(a, 100), b)

def main() -> IO(Unit):
  r1 = comb(None{}, None{})
  r2 = comb(Some{3}, None{})
  r3 = comb(None{}, Some{4})
  r4 = comb(Some{5}, Some{6})
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r3) ++ "," ++ U32.show(r4))
"""
    cases.append(Case("match_2scrut_maybe_maybe", "A", "multi_scrutinee_match", "2-scrutinee Maybe x Maybe", code, "0,13,24,506\n"))

    def py_nat2(a: int, b: int) -> int:
        if a == 0 and b == 0: return 1
        if a == 0: return b + 10
        if b == 0: return a + 20
        return 1 + py_nat2(a - 1, b - 1)
    pairs = [(0, 0), (0, 5), (4, 0), (3, 3), (7, 4), (4, 7)]
    code = """import Base

def nat2(a: Nat, b: Nat) -> Nat:
  match a b:
    case 0n 0n: 1n
    case 0n y: Nat.add(y, 10n)
    case x 0n: Nat.add(x, 20n)
    case 1n+p 1n+q: Nat.add(1n, nat2(p, q))

def main() -> IO(Unit):
  IO.print(""" + ' ++ "," ++ '.join(f"Nat.show(nat2({a}n, {b}n))" for a, b in pairs) + ")\n"
    cases.append(Case("match_2scrut_nat_nat_rec", "A", "multi_scrutinee_match", "2-scrutinee recursive Nat x Nat match", code, ",".join(str(py_nat2(a, b)) for a, b in pairs) + "\n"))

    def py_tri(x: int, m: Optional[int], n: int) -> int:
        if x == 0 and m is None and n == 0: return 1
        if x == 0 and m is not None: return m + n + 10
        if x == 1 and n == 0: return 20 + (m if m is not None else 0)
        if m is not None and n >= 1: return x + m + (n - 1) + 100
        return x + n + 500
    tri_inputs = [
        (0, None, 0), (0, 7, 3), (1, None, 0), (1, 8, 0),
        (2, 5, 4), (2, None, 4), (0, None, 2), (9, 3, 0),
    ]
    def bend_maybe(m):
        return "None{}" if m is None else f"Some{{{m}}}"
    code = """import Base

def tri(x: U32, m: Maybe<&2, U32>, n: Nat) -> U32:
  match x m n:
    case 0 None{} 0n: 1
    case 0 Some{v} k: U32.add(v, U32.add(U32.from_nat(k), 10))
    case 1 None{} 0n: 20
    case 1 Some{v} 0n: U32.add(20, v)
    case u Some{v} 1n+p: U32.add(u, U32.add(v, U32.add(U32.from_nat(p), 100)))
    case u _ k: U32.add(u, U32.add(U32.from_nat(k), 500))

def main() -> IO(Unit):
  IO.print(""" + ' ++ "," ++ '.join(f"U32.show(tri({x}, {bend_maybe(m)}, {n}n))" for x, m, n in tri_inputs) + ")\n"
    cases.append(Case("match_3scrut_u32_maybe_nat", "A", "multi_scrutinee_match", "3-scrutinee U32 x Maybe x Nat decision tree", code, ",".join(str(py_tri(x, m, n)) for x, m, n in tri_inputs) + "\n"))

    def py_sw(x: int) -> int:
        return {0: 10, 1: 20, 2: 30, 5: 55, 10: 110, 100: 999}.get(x, x + 1000)
    xs = [0, 1, 2, 3, 5, 9, 10, 99, 100, 101]
    code = """import Base

def sw(x: U32) -> U32:
  match x:
    case 0: 10
    case 1: 20
    case 2: 30
    case 5: 55
    case 10: 110
    case 100: 999
    case k: U32.add(k, 1000)

def main() -> IO(Unit):
  IO.print(""" + ' ++ "," ++ '.join(f"U32.show(sw({x}))" for x in xs) + ")\n"
    cases.append(Case("match_u32_sparse_default_bind", "A", "multi_scrutinee_match", "Sparse U32 match with bound default variable", code, ",".join(str(py_sw(x)) for x in xs) + "\n"))

    def py_shad(a: int, b: int) -> int:
        if a == 0:
            return (b + 1) * 2
        x = a + 3
        if b == 0:
            return x + 10
        return x + (b + 20)
    spairs = [(0, 5), (4, 0), (4, 7), (1, 1)]
    code = """import Base

def shad_inner(x: U32, b: U32) -> U32:
  match b:
    case 0: U32.add(x, 10)
    case _: U32.add(x, U32.add(b, 20))

def shad(a: U32, b: U32) -> U32:
  match a:
    case 0:
      x = U32.add(b, 1)
      U32.mul(x, 2)
    case _:
      x = U32.add(a, 3)
      shad_inner(x, b)

def main() -> IO(Unit):
  IO.print(""" + ' ++ "," ++ '.join(f"U32.show(shad({a}, {b}))" for a, b in spairs) + ")\n"
    cases.append(Case("match_nested_let_scoping", "A", "multi_scrutinee_match", "Nested match with let-bindings in arms", code, ",".join(str(py_shad(a, b)) for a, b in spairs) + "\n"))

    code = """import Base

def classify(xs: List<&2, U32>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{a, Nil{}}: a
    case Con{a, Con{b, Nil{}}}: U32.add(U32.mul(a, 10), b)
    case Con{a, Con{b, Con{c, _}}}: U32.add(U32.mul(a, 100), U32.add(U32.mul(b, 10), c))

def main() -> IO(Unit):
  r0 = classify(Nil{})
  r1 = classify(Con{7, Nil{}})
  r2 = classify(Con{3, Con{4, Nil{}}})
  r3 = classify(Con{1, Con{2, Con{5, Con{9, Nil{}}}}})
  IO.print(U32.show(r0) ++ "," ++ U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r3))
"""
    cases.append(Case("match_list_prefix_patterns", "A", "multi_scrutinee_match", "List nested prefix patterns (0,1,2,>=3 elems)", code, "0,7,34,125\n"))

    code = """import Base

def cmp_tag(c: Cmp) -> U32:
  match c:
    case LT{}: 1
    case EQ{}: 2
    case GT{}: 3

def tri_cmp(a: U32, b: U32) -> U32:
  cmp_tag(U32.cmp(a, b))

def main() -> IO(Unit):
  IO.print(U32.show(tri_cmp(10, 20)) ++ "," ++ U32.show(tri_cmp(20, 20)) ++ "," ++ U32.show(tri_cmp(3000000000, 20)))
"""
    cases.append(Case("match_u32_cmp_3way", "A", "multi_scrutinee_match", "U32.cmp 3-way match including >2^31", code, "1,2,3\n"))

    code = """import Base

type Tree is Data:
  Leaf{v: U32}
  Node{l: Tree, r: Tree}

def teq(a: Tree, b: Tree) -> Bool:
  match a b:
    case Leaf{x} Leaf{y}: U32.is_eq(x, y)
    case Node{l1, r1} Node{l2, r2}: Bool.and(teq(l1, l2), teq(r1, r2))
    case _ _: False{}

def main() -> IO(Unit):
  +t1 : Tree = Node{Leaf{1}, Node{Leaf{2}, Leaf{3}}}
  t2 : Tree = Node{Leaf{1}, Node{Leaf{2}, Leaf{3}}}
  t3 : Tree = Node{Leaf{1}, Node{Leaf{2}, Leaf{4}}}
  t4 : Tree = Node{Node{Leaf{1}, Leaf{2}}, Leaf{3}}
  IO.print(Bool.show(teq(t1, t2)) ++ "," ++ Bool.show(teq(t1, t3)) ++ "," ++ Bool.show(teq(t1, t4)))
"""
    cases.append(Case("match_2scrut_tree_eq", "A", "multi_scrutinee_match", "2-scrutinee recursive Tree structural equality", code, "True,False,False\n"))

    return cases


def gen_group_a_closures() -> list[Case]:
    """Family 5: Higher-order functions, closures, currying, partial application, closures in ADTs."""
    cases: list[Case] = []

    code = """import Base

def mk1(a: U32) -> U32 -> U32:
  x => U32.add(a, x)

def mk3(a: U32, b: U32, c: U32) -> U32 -> U32:
  x => U32.add(U32.mul(a, x), U32.add(b, c))

def mk5(a: U32, b: U32, c: U32, d: U32, e: U32) -> U32 -> U32:
  x => U32.add(a, U32.add(b, U32.add(c, U32.add(d, U32.add(e, x)))))

def main() -> IO(Unit):
  r1 = mk1(10)(5)
  r2 = mk3(3, 4, 5)(10)
  r3 = mk5(1, 2, 3, 4, 5)(100)
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r3))
"""
    cases.append(Case("hof_closure_capture_1_3_5", "A", "closures_hof", "Closures capturing 1, 3, and 5 free variables", code, "15,39,115\n"))

    code = """import Base

def compose(f: U32 -> U32, g: U32 -> U32) -> U32 -> U32:
  x => f(g(x))

def apply_n(~f: U32 -> U32, n: Nat, x: U32) -> U32:
  match n:
    case 0n: x
    case 1n+p: apply_n(f, p, f(x))

def main() -> IO(Unit):
  f : U32 -> U32 = x => U32.add(U32.mul(2, x), 1)
  g : U32 -> U32 = x => U32.add(x, 3)
  r1 = compose(f, g)(10)
  r2 = apply_n(x => U32.add(U32.mul(2, x), 1), 4n, 1)
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2))
"""
    cases.append(Case("hof_compose_and_apply_n", "A", "closures_hof", "Function composition and iterated apply_n", code, "27,31\n"))

    xs = [1, 2, 3, 4, 5, 6]
    mapped = [x * 3 + 2 for x in xs]
    fl = 0
    for v in mapped:
        fl = fl * 2 + v
    fr = 0
    for v in reversed(mapped):
        fr = fr * 2 + v
    code = """import Base

def lmap(~f: U32 -> U32, xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{h, t}: Con{f(h), lmap(f, t)}

def foldl(~f: U32 -> U32 -> U32, xs: List<&2, U32>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{h, t}: foldl(f, t, f(acc)(h))

def foldr(~f: U32 -> U32 -> U32, xs: List<&2, U32>, z: U32) -> U32:
  match xs:
    case Nil{}: z
    case Con{h, t}: f(h)(foldr(f, t, z))

def mk_xs() -> List<&2, U32>:
  Con{1, Con{2, Con{3, Con{4, Con{5, Con{6, Nil{}}}}}}}

def main() -> IO(Unit):
  ys1 = lmap(x => U32.add(U32.mul(x, 3), 2), mk_xs())
  ys2 = lmap(x => U32.add(U32.mul(x, 3), 2), mk_xs())
  r1 = foldl(acc => v => U32.add(U32.mul(acc, 2), v), ys1, 0)
  r2 = foldr(v => acc => U32.add(U32.mul(acc, 2), v), ys2, 0)
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2))
"""
    cases.append(Case("hof_list_map_foldl_foldr", "A", "closures_hof", "List map, foldl, foldr with capturing closures", code, f"{fl},{fr}\n"))

    code = """import Base

def pick(tag: U32, k: U32) -> U32 -> U32:
  match tag:
    case 0: x => U32.add(x, k)
    case 1: x => U32.mul(x, k)
    case _: x => U32.add(x, U32.add(U32.mul(2, k), 1))

def main() -> IO(Unit):
  r0 = pick(0, 7)(10)
  r1 = pick(1, 7)(10)
  r2 = pick(2, 7)(10)
  IO.print(U32.show(r0) ++ "," ++ U32.show(r1) ++ "," ++ U32.show(r2))
"""
    cases.append(Case("hof_return_closure_from_match", "A", "closures_hof", "Returning distinct closures from match arms", code, "17,70,25\n"))

    code = """import Base

type FnBox is Type:
  MkFn{tag: U32, f: U32 -> U32}

def run_box(b: FnBox, x: U32) -> U32:
  match b:
    case MkFn{tag, f}: U32.add(tag, f(x))

def main() -> IO(Unit):
  b1 : FnBox = MkFn{100, x => U32.mul(x, 3)}
  b2 : FnBox = MkFn{200, x => U32.add(x, 42)}
  IO.print(U32.show(run_box(b1, 7)) ++ "," ++ U32.show(run_box(b2, 7)))
"""
    cases.append(Case("hof_closure_in_adt", "A", "closures_hof", "Storing and invoking closures inside an ADT", code, "121,249\n"))

    code = """import Base

def add3(a: U32, b: U32, c: U32) -> U32:
  U32.add(U32.mul(a, 100), U32.add(U32.mul(b, 10), c))

def f1(b: U32) -> U32 -> U32:
  c => add3(3, b, c)

def main() -> IO(Unit):
  f2 = f1(4)
  IO.print(U32.show(f2(5)) ++ "," ++ U32.show(f1(6)(7)))
"""
    cases.append(Case("hof_curried_partial_app", "A", "closures_hof", "Multi-stage curried partial application", code, "345,367\n"))

    code = """import Base

def fact_cps(+n: Nat, k: U32 -> U32) -> U32:
  match n:
    case 0n: k(1)
    case 1n+p: fact_cps(p, r => k(U32.mul(U32.from_nat(n), r)))

def main() -> IO(Unit):
  IO.print(U32.show(fact_cps(10n, x => x)))
"""
    cases.append(Case("hof_cps_factorial_10", "A", "closures_hof", "CPS factorial(10) building 10 nested closures", code, f"{math.factorial(10)}\n"))

    code = """import Base

def apply1(f: U32 -> U32, x: U32) -> U32:
  f(x)

def make_adder(k: U32) -> U32 -> U32 -> U32:
  a => b => U32.add(k, U32.add(a, b))

def main() -> IO(Unit):
  g = make_adder(10)
  h = g(20)
  IO.print(U32.show(apply1(h, 30)))
"""
    cases.append(Case("hof_nested_closure_chain", "A", "closures_hof", "Nested 2-level closure chain", code, "60\n"))

    code = """import Base

type Tree is Data:
  Leaf{v: U32}
  Node{v: U32, l: Tree, r: Tree}

def tfold(~fl: U32 -> U32, ~fn: U32 -> U32 -> U32 -> U32, t: Tree) -> U32:
  match t:
    case Leaf{v}: fl(v)
    case Node{v, l, r}: fn(v)(tfold(fl, fn, l))(tfold(fl, fn, r))

def main() -> IO(Unit):
  t1 : Tree = Node{10, Leaf{3}, Node{4, Leaf{5}, Leaf{6}}}
  t2 : Tree = Node{10, Leaf{3}, Node{4, Leaf{5}, Leaf{6}}}
  s = tfold(v => v, v => a => b => U32.add(v, U32.add(a, b)), t1)
  p = tfold(v => v, _ => a => b => U32.mul(a, b), t2)
  IO.print(U32.show(s) ++ "," ++ U32.show(p))
"""
    cases.append(Case("hof_tree_fold", "A", "closures_hof", "Higher-order binary tree fold", code, "28,90\n"))

    exp = sum(i * i + 17 for i in range(1, 21))
    code = """import Base

def sum_f(~f: U32 -> U32, +n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: sum_f(f, p, U32.add(acc, f(U32.from_nat(n))))

def sq_plus(base: U32, +x: U32) -> U32:
  U32.add(U32.mul(x, x), base)

def main() -> IO(Unit):
  r = sum_f(x => sq_plus(17, x), 20n, 0)
  IO.print(U32.show(r))
"""
    cases.append(Case("hof_shared_closure_in_loop", "A", "closures_hof", "Shared capturing closure called 20 times in loop", code, f"{exp}\n"))

    return cases


def gen_group_a_recursion() -> list[Case]:
    """Family 6: Tail recursion, non-tail recursion, mutual-encoded state machines, sorting, algorithms."""
    cases: list[Case] = []

    code = """import Base

type Parity is Data:
  PEven{}
  POdd{}

def parity(n: Nat, ph: Parity) -> Bool:
  match n ph:
    case 0n PEven{}: True{}
    case 0n POdd{}: False{}
    case 1n+p PEven{}: parity(p, POdd{})
    case 1n+p POdd{}: parity(p, PEven{})

def main() -> IO(Unit):
  IO.print(Bool.show(parity(0n, PEven{})) ++ "," ++ Bool.show(parity(17n, PEven{})) ++ "," ++ Bool.show(parity(42n, PEven{})) ++ "," ++ Bool.show(parity(17n, POdd{})) ++ "," ++ Bool.show(parity(42n, POdd{})))
"""
    cases.append(Case("rec_mutual_even_odd", "A", "recursion_tail_mutual", "Mutual-state even/odd parity recursion", code, "True,False,True,True,False\n"))

    def py_s0(n, acc):
        return acc if n == 0 else py_s1(n - 1, acc + 1, n)
    def py_s1(n, acc, k):
        return acc + k if n == 0 else py_s2(n - 1, acc + k)
    def py_s2(n, acc):
        return acc * 2 if n == 0 else py_s0(n - 1, acc + 3)
    code = """import Base

type MSt is Data:
  S0{acc: U32}
  S1{acc: U32, k: U32}
  S2{acc: U32}

def run_m(+n: Nat, st: MSt) -> U32:
  match n st:
    case 0n S0{acc}: acc
    case 0n S1{acc, k}: U32.add(acc, k)
    case 0n S2{acc}: U32.mul(acc, 2)
    case 1n+p S0{acc}: run_m(p, S1{U32.add(acc, 1), U32.from_nat(n)})
    case 1n+p S1{acc, k}: run_m(p, S2{U32.add(acc, k)})
    case 1n+p S2{acc}: run_m(p, S0{U32.add(acc, 3)})

def main() -> IO(Unit):
  IO.print(U32.show(run_m(15n, S0{0})) ++ "," ++ U32.show(run_m(16n, S0{0})) ++ "," ++ U32.show(run_m(17n, S0{0})))
"""
    cases.append(Case("rec_3way_mutual_diff_arity", "A", "recursion_tail_mutual", "3-way mutual state machine with differing arities", code, f"{py_s0(15,0)},{py_s0(16,0)},{py_s0(17,0)}\n"))

    def py_ack(m, n):
        if m == 0: return n + 1
        if n == 0: return py_ack(m - 1, 1)
        return py_ack(m - 1, py_ack(m, n - 1))
    code = """import Base

def ack_go(+m: Nat, n: Nat) -> Nat:
  match m n:
    case 0n y: Nat.add(y, 1n)
    case 1n+p 0n: ack_go(p, 1n)
    case 1n+p 1n+q: ack_go(p, ack_go(1n+p, q))

def main() -> IO(Unit):
  IO.print(Nat.show(ack_go(2n, 5n)) ++ "," ++ Nat.show(ack_go(3n, 3n)) ++ "," ++ Nat.show(ack_go(3n, 4n)))
"""
    cases.append(Case("rec_ackermann_small", "A", "recursion_tail_mutual", "Ackermann(2,5), (3,3), (3,4) via higher-order recursion", code, f"{py_ack(2,5)},{py_ack(3,3)},{py_ack(3,4)}\n"))

    def py_fib(n):
        a, b = 0, 1
        for _ in range(n): a, b = b, a + b
        return a
    code = """import Base

def fib_naive(+n: Nat) -> U32:
  match n:
    case 0n: 0
    case 1n: 1
    case 2n+p: U32.add(fib_naive(1n+p), fib_naive(p))

def fib_tail(n: Nat, +a: U32, +b: U32) -> U32:
  match n:
    case 0n: a
    case 1n+p: fib_tail(p, b, U32.add(a, b))

def main() -> IO(Unit):
  IO.print(U32.show(fib_naive(16n)) ++ "," ++ U32.show(fib_tail(35n, 0, 1)))
"""
    cases.append(Case("rec_fib_naive_and_tail", "A", "recursion_tail_mutual", "Fibonacci naive(16) and tail(35)", code, f"{py_fib(16)},{py_fib(35)}\n"))

    code = """import Base

def gcd_go(fuel: Nat, +a: U32, +b: U32) -> U32:
  match fuel b:
    case 0n _: a
    case _ 0: a
    case 1n+p _: gcd_go(p, b, U32.mod(a, b))

def main() -> IO(Unit):
  r1 = gcd_go(100n, 1071, 462)
  r2 = gcd_go(100n, 123456789, 987654321)
  r3 = gcd_go(100n, 3000000000, 1800000000)
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r3))
"""
    cases.append(Case("rec_gcd_euclid", "A", "recursion_tail_mutual", "Euclidean GCD including >2^31 inputs", code, f"{math.gcd(1071,462)},{math.gcd(123456789,987654321)},{math.gcd(3000000000,1800000000)}\n"))

    unsorted = [42, 7, 19, 3, 99, 15, 7, 1, 55, 23]
    srt = sorted(unsorted)
    chk = sum((i + 1) * v for i, v in enumerate(srt))
    list_lit = "Nil{}"
    for v in reversed(unsorted):
        list_lit = f"Con{{{v}, {list_lit}}}"
    code = f"""import Base

def insert_go(le: Bool, x: U32, h: U32, t: List<&2, U32>, rec: List<&2, U32>) -> List<&2, U32>:
  match le:
    case True{{}}: Con{{x, Con{{h, t}}}}
    case False{{}}: Con{{h, rec}}

def insert(+x: U32, +xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{{}}: Con{{x, Nil{{}}}}
    case Con{{h, t}}:
      insert_go(U32.is_le(x, h), x, h, t, insert(x, t))

def isort(xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{{}}: Nil{{}}
    case Con{{h, t}}: insert(h, isort(t))

def checksum(xs: List<&2, U32>, +i: U32, +acc: U32) -> U32:
  match xs:
    case Nil{{}}: acc
    case Con{{h, t}}: checksum(t, U32.add(i, 1), U32.add(acc, U32.mul(i, h)))

def main() -> IO(Unit):
  IO.print(U32.show(checksum(isort({list_lit}), 1, 0)))
"""
    cases.append(Case("rec_insertion_sort_list", "A", "recursion_tail_mutual", "Insertion sort on 10-element List<U32>", code, f"{chk}\n"))

    def py_collatz(n):
        steps = 0
        while n != 1:
            n = n // 2 if n % 2 == 0 else 3 * n + 1
            steps += 1
        return steps
    code = """import Base

def collatz_next(rem: U32, +n: U32) -> U32:
  match rem:
    case 0: U32.div(n, 2)
    case _: U32.add(U32.mul(3, n), 1)

def collatz(fuel: Nat, +n: U32, +steps: U32) -> U32:
  match fuel n:
    case 0n _: steps
    case _ 1: steps
    case 1n+p _: collatz(p, collatz_next(U32.mod(n, 2), n), U32.add(steps, 1))

def main() -> IO(Unit):
  IO.print(U32.show(collatz(200n, 27, 0)) ++ "," ++ U32.show(collatz(200n, 97, 0)))
"""
    cases.append(Case("rec_collatz_27_97", "A", "recursion_tail_mutual", "Collatz step counts for 27 and 97", code, f"{py_collatz(27)},{py_collatz(97)}\n"))

    # Use m=10007 and m=9973 so base*base <= 10^8 < 2^32 (strictly in-range!)
    r1 = pow(7, 13, 10007)
    r2 = pow(123, 45, 9973)
    code = """import Base

def modpow_acc(bit: U32, acc: U32, base: U32, m: U32) -> U32:
  match bit:
    case 1: U32.mod(U32.mul(acc, base), m)
    case _: acc

def modpow(fuel: Nat, +base: U32, +exp: U32, +m: U32, +acc: U32) -> U32:
  match fuel exp:
    case 0n _: acc
    case _ 0: acc
    case 1n+p _:
      nb = U32.mod(U32.mul(base, base), m)
      ne = U32.div(exp, 2)
      nacc = modpow_acc(U32.mod(exp, 2), acc, base, m)
      modpow(p, nb, ne, m, nacc)

def main() -> IO(Unit):
  IO.print(U32.show(modpow(32n, 7, 13, 10007, 1)) ++ "," ++ U32.show(modpow(32n, 123, 45, 9973, 1)))
"""
    cases.append(Case("rec_modpow_fast", "A", "recursion_tail_mutual", "Fast modular exponentiation (strictly in-range m<=10007)", code, f"{r1},{r2}\n"))

    code = """import Base

def comb(+n: Nat, +k: Nat) -> U32:
  match n k:
    case _ 0n: 1
    case 0n _: 0
    case 1n+pn 1n+pk: U32.add(comb(pn, pk), comb(pn, 1n+pk))

def main() -> IO(Unit):
  IO.print(U32.show(comb(12n, 5n)) ++ "," ++ U32.show(comb(14n, 7n)))
"""
    cases.append(Case("rec_pascal_binomial", "A", "recursion_tail_mutual", "Binomial C(12,5) and C(14,7)", code, f"{math.comb(12,5)},{math.comb(14,7)}\n"))

    n_iter = 10000
    exp_sum = n_iter * (n_iter + 1) // 2
    code = f"""import Base

def sum_n(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: sum_n(p, U32.add(acc, U32.from_nat(n)))

def main() -> IO(Unit):
  IO.print(U32.show(sum_n({n_iter}n, 0)))
"""
    cases.append(Case("rec_tail_sum_10000", "A", "recursion_tail_mutual", "Tail-recursive sum 1..10000", code, f"{exp_sum}\n"))

    return cases


def gen_group_a_arrays() -> list[Case]:
    """Family 7: Linear Array operations (new, get, set, swap, size, prefix sum, reverse, ADT elems)."""
    cases: list[Case] = []

    code = """import Base

def step4(r: Array<U32> & U32, sz: U32, v0: U32, v2: U32, v3: U32) -> String:
  match r:
    case Tuple{_, v7}:
      U32.show(sz) ++ "," ++ U32.show(v0) ++ "," ++ U32.show(v2) ++ "," ++ U32.show(v3) ++ "," ++ U32.show(v7)

def step3(r: Array<U32> & U32, sz: U32, v0: U32, v2: U32) -> String:
  match r:
    case Tuple{a, v3}: step4(Array.get(U32, a, 7), sz, v0, v2, v3)

def step2(r: Array<U32> & U32, sz: U32, v0: U32) -> String:
  match r:
    case Tuple{a, v2}: step3(Array.get(U32, a, 3), sz, v0, v2)

def step1(r: Array<U32> & U32, sz: U32) -> String:
  match r:
    case Tuple{a, v0}: step2(Array.get(U32, a, 2), sz, v0)

def step0(r: Array<U32> & U32) -> String:
  match r:
    case Tuple{a, sz}: step1(Array.get(U32, a, 0), sz)

def main() -> IO(Unit):
  a = Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 3n, 5), 0, 10), 3, 42), 7, 99)
  IO.print(step0(Array.size(U32, a)))
"""
    cases.append(Case("arr_basic_new_set_get_size", "A", "linear_arrays", "Array.new/set/get/size on depth-3 U32 array", code, "8,10,5,42,99\n"))

    code = """import Base

def s3(r: Array<U32> & U32, o1: U32, o2: U32) -> String:
  match r:
    case Tuple{_, cur}: U32.show(o1) ++ "," ++ U32.show(o2) ++ "," ++ U32.show(cur)

def s2(r: Array<U32> & U32, o1: U32) -> String:
  match r:
    case Tuple{a, o2}: s3(Array.get(U32, a, 2), o1, o2)

def s1(r: Array<U32> & U32) -> String:
  match r:
    case Tuple{a, o1}: s2(Array.swap(U32, a, 2, 88), o1)

def main() -> IO(Unit):
  IO.print(s1(Array.swap(U32, Array.new(U32, 2n, 10), 2, 77)))
"""
    cases.append(Case("arr_swap_twice_same_idx", "A", "linear_arrays", "Array.swap twice at same index", code, "10,77,88\n"))

    arr = [(i * 7 + 3) for i in range(32)]
    for i in range(1, 32):
        arr[i] += arr[i - 1]
    chk = sum(arr)
    code = """import Base

def fill(n: Nat, +i: U32, a: Array<U32>) -> Array<U32>:
  match n:
    case 0n: a
    case 1n+p: fill(p, U32.add(i, 1), Array.set(U32, a, i, U32.add(U32.mul(i, 7), 3)))

def pref_add(r: Array<U32> & U32, prev: U32, i: U32) -> Array<U32>:
  match r:
    case Tuple{a, cur}: Array.set(U32, a, i, U32.add(prev, cur))

def pref_step(r: Array<U32> & U32, +i: U32) -> Array<U32>:
  match r:
    case Tuple{a, prev}: pref_add(Array.get(U32, a, i), prev, i)

def pref(n: Nat, +i: U32, a: Array<U32>) -> Array<U32>:
  match n:
    case 0n: a
    case 1n+p: pref(p, U32.add(i, 1), pref_step(Array.get(U32, a, U32.sub(i, 1)), i))

def asum_go(n: Nat, +i: U32, +acc: U32, r: Array<U32> & U32) -> U32:
  match n r:
    case 0n Tuple{_, v}: U32.add(acc, v)
    case 1n+p Tuple{a, v}: asum_go(p, U32.add(i, 1), U32.add(acc, v), Array.get(U32, a, U32.add(i, 1)))

def main() -> IO(Unit):
  a = pref(31n, 1, fill(32n, 0, Array.new(U32, 5n, 0)))
  IO.print(U32.show(asum_go(31n, 0, 0, Array.get(U32, a, 0))))
"""
    cases.append(Case("arr_prefix_sum_32", "A", "linear_arrays", "Array fill + prefix sum + sum over 32 elements", code, f"{chk}\n"))

    arr = [i * 3 + 1 for i in range(16)]
    arr.reverse()
    wchk = sum((i + 1) * v for i, v in enumerate(arr))
    code = """import Base

def fill(n: Nat, +i: U32, a: Array<U32>) -> Array<U32>:
  match n:
    case 0n: a
    case 1n+p: fill(p, U32.add(i, 1), Array.set(U32, a, i, U32.add(U32.mul(i, 3), 1)))

def rev_s2(r: Array<U32> & U32, lo: U32) -> Array<U32>:
  match r:
    case Tuple{a, vhi}: Array.set(U32, a, lo, vhi)

def rev_s1(r: Array<U32> & U32, lo: U32, hi: U32) -> Array<U32>:
  match r:
    case Tuple{a, vlo}: rev_s2(Array.swap(U32, a, hi, vlo), lo)

def rev(n: Nat, +lo: U32, +hi: U32, a: Array<U32>) -> Array<U32>:
  match n:
    case 0n: a
    case 1n+p: rev(p, U32.add(lo, 1), U32.sub(hi, 1), rev_s1(Array.get(U32, a, lo), lo, hi))

def wsum_go(n: Nat, +i: U32, +acc: U32, r: Array<U32> & U32) -> U32:
  match n r:
    case 0n Tuple{_, v}: U32.add(acc, U32.mul(U32.add(i, 1), v))
    case 1n+p Tuple{a, v}:
      wsum_go(p, U32.add(i, 1), U32.add(acc, U32.mul(U32.add(i, 1), v)), Array.get(U32, a, U32.add(i, 1)))

def main() -> IO(Unit):
  a = rev(8n, 0, 15, fill(16n, 0, Array.new(U32, 4n, 0)))
  IO.print(U32.show(wsum_go(15n, 0, 0, Array.get(U32, a, 0))))
"""
    cases.append(Case("arr_inplace_reverse_16", "A", "linear_arrays", "In-place array reverse via Array.swap", code, f"{wchk}\n"))

    code = """import Base

def snd_u32(r: Array<U32> & U32) -> U32:
  match r:
    case Tuple{_, v}: v

def check_clone(pair: Array<U32> & Array<U32>) -> String:
  match pair:
    case Tuple{a1, a2}:
      a2b = Array.set(U32, a2, 1, 999)
      U32.show(snd_u32(Array.get(U32, a1, 1))) ++ "," ++ U32.show(snd_u32(Array.get(U32, a2b, 1)))

def main() -> IO(Unit):
  a = Array.set(U32, Array.new(U32, 2n, 10), 1, 20)
  IO.print(check_clone(Array.clone(U32, a)))
"""
    cases.append(Case("arr_clone_isolation", "A", "linear_arrays", "Array.clone mutation isolation", code, "20,999\n"))

    code = """import Base

def unm(m: Maybe<&2, U32>) -> U32:
  match m:
    case None{}: 0
    case Some{v}: v

def g3(r: Array<Maybe<&2, U32>> & Maybe<&2, U32>, v0: U32, v1: U32) -> String:
  match r:
    case Tuple{_, m3}: U32.show(v0) ++ "," ++ U32.show(v1) ++ "," ++ U32.show(unm(m3))

def g2(r: Array<Maybe<&2, U32>> & Maybe<&2, U32>, v0: U32) -> String:
  match r:
    case Tuple{a, m1}: g3(Array.get(Maybe<&2, U32>, a, 3), v0, unm(m1))

def g1(r: Array<Maybe<&2, U32>> & Maybe<&2, U32>) -> String:
  match r:
    case Tuple{a, m0}: g2(Array.get(Maybe<&2, U32>, a, 1), unm(m0))

def main() -> IO(Unit):
  a = Array.set(Maybe<&2, U32>, Array.set(Maybe<&2, U32>, Array.new(Maybe<&2, U32>, 2n, None{}), 1, Some{42}), 3, Some{99})
  IO.print(g1(Array.get(Maybe<&2, U32>, a, 0)))
"""
    cases.append(Case("arr_of_adt_maybe", "A", "linear_arrays", "Array of Maybe<U32> elements", code, "0,42,99\n"))

    code = """import Base

def sq1(+x: U32) -> U32:
  U32.add(U32.mul(x, x), 1)

def lsum(xs: List<&1, U32>, +acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{h, t}: lsum(t, U32.add(acc, h))

def main() -> IO(Unit):
  a = Array.set(U32, Array.set(U32, Array.set(U32, Array.new(U32, 2n, 0), 1, 1), 2, 2), 3, 3)
  b = Array.map(U32, U32, x => sq1(x), a)
  IO.print(U32.show(lsum(Array.to_list(U32, b), 0)))
"""
    cases.append(Case("arr_map_to_list", "A", "linear_arrays", "Array.map and Array.to_list", code, "18\n"))

    code = """import Base

def s3(r: Array<U32> & U32, sa: U32, sb: U32, va: U32) -> String:
  match r:
    case Tuple{_, vb}: U32.show(sa) ++ "," ++ U32.show(sb) ++ "," ++ U32.show(va) ++ "," ++ U32.show(vb)

def s2(r: Array<U32> & U32, b: Array<U32>, sa: U32, sb: U32) -> String:
  match r:
    case Tuple{_, va}: s3(Array.get(U32, b, 3), sa, sb, va)

def s1(ra: Array<U32> & U32, rb: Array<U32> & U32) -> String:
  match ra rb:
    case Tuple{a, sa} Tuple{b, sb}: s2(Array.get(U32, a, 5), b, sa, sb)

def main() -> IO(Unit):
  IO.print(s1(Array.size(U32, [7 : U32^3n]), Array.size(U32, [9 : U32*4n])))
"""
    cases.append(Case("arr_literal_depth_and_count", "A", "linear_arrays", "Array literal syntax ^d vs *n", code, "8,4,7,9\n"))

    return cases


def gen_group_a_strings() -> list[Case]:
    """Family 8: Pure ASCII String, Char, Bool operations (including Base Char.quote / String.quote!)."""
    cases: list[Case] = []

    code = """import Base

def main() -> IO(Unit):
  +s1 = String.append("hello", "_world")
  s2 = String.reverse("abcdef")
  l1 = Nat.show(String.length(s1))
  eq1 = Bool.show(String.eq(s1, "hello_world"))
  eq2 = Bool.show(String.eq(s1, "hello_worl"))
  sw = Bool.show(String.starts_with(s1, "hello"))
  ew = Bool.show(String.ends_with(s1, "world"))
  ct = Bool.show(String.contains(s1, "lo_wo"))
  IO.print(s1 ++ "|" ++ s2 ++ "|" ++ l1 ++ "|" ++ eq1 ++ "|" ++ eq2 ++ "|" ++ sw ++ "|" ++ ew ++ "|" ++ ct)
"""
    cases.append(Case("str_basic_ops", "A", "strings_chars_bools", "String append/reverse/length/eq/starts_with/ends_with/contains", code, "hello_world|fedcba|11|True|False|True|True|True\n"))

    code = """import Base

def main() -> IO(Unit):
  c = Char.from_u32(65)
  u = Char.to_u32(Char.to_lower(c))
  d = Bool.show(Char.is_digit(Char.from_u32(53)))
  a = Bool.show(Char.is_alpha(Char.from_u32(90)))
  IO.print(U32.show(u) ++ "," ++ d ++ "," ++ a)
"""
    cases.append(Case("char_ascii_ops", "A", "strings_chars_bools", "Char from_u32/to_lower/to_u32/is_digit/is_alpha", code, "97,True,True\n"))

    code = """import Base

def main() -> IO(Unit):
  r1 = Bool.and(True{}, False{})
  +r2 = Bool.or(False{}, True{})
  +r3 = Bool.xor(True{}, True{})
  r4 = Bool.not(False{})
  r5 = Bool.pick(U32, r2, 111, 222)
  r6 = Bool.pick(U32, r3, 111, 222)
  IO.print(Bool.show(r1) ++ "," ++ Bool.show(r2) ++ "," ++ Bool.show(r3) ++ "," ++ Bool.show(r4) ++ "," ++ U32.show(r5) ++ "," ++ U32.show(r6))
"""
    cases.append(Case("bool_ops_and_pick", "A", "strings_chars_bools", "Bool and/or/xor/not/pick", code, "False,True,False,True,111,222\n"))

    code = """import Base

def main() -> IO(Unit):
  IO.print(Bool.show(String.is_lt("abc", "abd")) ++ "," ++ Bool.show(String.is_lt("ab", "abc")) ++ "," ++ Bool.show(String.is_gt("z", "aaa")) ++ "," ++ Bool.show(String.is_le("same", "same")))
"""
    cases.append(Case("str_lex_order", "A", "strings_chars_bools", "String lexicographical ordering", code, "True,True,True,True\n"))

    # Ordinary ASCII Base Char.quote and String.quote!
    code = """import Base

def main() -> IO(Unit):
  IO.print(Char.quote(39, Chr{65}))
"""
    cases.append(Case("char_quote_ascii_plain", "A", "strings_chars_bools", "Ordinary ASCII Char.quote(39, Chr{65}) -> 'A'", code, "A\n"))

    code = """import Base

def main() -> IO(Unit):
  IO.print(String.quote("hello"))
"""
    cases.append(Case("str_quote_ascii_plain", "A", "strings_chars_bools", "Ordinary ASCII String.quote(\"hello\") -> '\"hello\"'", code, '"hello"\n'))

    return cases


def gen_group_a_metamorphic() -> list[Case]:
    """Family 9: Metamorphic / equivalent-form pairs exercising different compiler paths."""
    cases: list[Case] = []

    def add_pair(pid: str, subfam: str, desc: str, code_a: str, code_b: str, expected: str):
        cases.append(Case(f"meta_{pid}_a", "A", f"metamorphic_{subfam}", f"{desc} (form A)", code_a, expected, pair_id=pid, pair_side="a"))
        cases.append(Case(f"meta_{pid}_b", "A", f"metamorphic_{subfam}", f"{desc} (form B)", code_b, expected, pair_id=pid, pair_side="b"))

    # --- M1: Literal vs computed tag/scrutinee ---
    add_pair(
        "m1_nat_zero_lit_vs_sub", "lit_vs_computed", "Nat literal 0n vs Nat.sub(k, k)",
        """import Base
def f(n: Nat) -> U32:
  match n:
    case 0n: 42
    case 1n+p: U32.add(100, U32.from_nat(p))
def main() -> IO(Unit):
  IO.print(U32.show(f(0n)))
""",
        """import Base
def f(n: Nat) -> U32:
  match n:
    case 0n: 42
    case 1n+p: U32.add(100, U32.from_nat(p))
def id_nat(+k: Nat) -> Nat:
  Nat.sub(k, k)
def main() -> IO(Unit):
  IO.print(U32.show(f(id_nat(777n))))
""",
        "42\n",
    )

    add_pair(
        "m1_u32_zero_lit_vs_sub", "lit_vs_computed", "U32 literal 0 vs U32.sub(k, k)",
        """import Base
def f(x: U32) -> U32:
  match x:
    case 0: 123
    case 1: 456
    case _: 789
def main() -> IO(Unit):
  IO.print(U32.show(f(0)))
""",
        """import Base
def f(x: U32) -> U32:
  match x:
    case 0: 123
    case 1: 456
    case _: 789
def z(+k: U32) -> U32:
  U32.sub(k, k)
def main() -> IO(Unit):
  IO.print(U32.show(f(z(99999))))
""",
        "123\n",
    )

    add_pair(
        "m1_bool_lit_vs_cmp", "lit_vs_computed", "Bool literal True{} vs computed U32.is_eq(k+1, 1+k)",
        """import Base
def pick(b: Bool, x: U32, y: U32) -> U32:
  match b:
    case True{}: x
    case False{}: y
def main() -> IO(Unit):
  IO.print(U32.show(pick(True{}, 555, 666)))
""",
        """import Base
def pick(b: Bool, x: U32, y: U32) -> U32:
  match b:
    case True{}: x
    case False{}: y
def mk_t(+k: U32) -> Bool:
  U32.is_eq(U32.add(k, 1), U32.add(1, k))
def main() -> IO(Unit):
  IO.print(U32.show(pick(mk_t(12345), 555, 666)))
""",
        "555\n",
    )

    add_pair(
        "m1_adt_tag_lit_vs_computed", "lit_vs_computed", "Literal ADT ctor vs computed ADT ctor",
        """import Base
type Tag is Data:
  A{v: U32}
  B{v: U32}
  C{v: U32}
def eval_t(t: Tag) -> U32:
  match t:
    case A{v}: U32.add(v, 10)
    case B{v}: U32.mul(v, 10)
    case C{v}: U32.sub(v, 10)
def main() -> IO(Unit):
  IO.print(U32.show(eval_t(B{25})))
""",
        """import Base
type Tag is Data:
  A{v: U32}
  B{v: U32}
  C{v: U32}
def eval_t(t: Tag) -> U32:
  match t:
    case A{v}: U32.add(v, 10)
    case B{v}: U32.mul(v, 10)
    case C{v}: U32.sub(v, 10)
def mk_tag_go(r: U32, v: U32) -> Tag:
  match r:
    case 0: A{v}
    case 1: B{v}
    case _: C{v}
def mk_tag(k: U32, v: U32) -> Tag:
  mk_tag_go(U32.mod(k, 3), v)
def main() -> IO(Unit):
  IO.print(U32.show(eval_t(mk_tag(100, 25))))
""",
        "250\n",
    )

    exp_s5 = sum(i * i for i in range(1, 6))
    add_pair(
        "m1_nat_loop_bound_lit_vs_computed", "lit_vs_computed", "Loop bound literal 5n vs Nat.div(25n, 5n)",
        """import Base
def sqsum(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      +k = U32.from_nat(n)
      sqsum(p, U32.add(acc, U32.mul(k, k)))
def main() -> IO(Unit):
  IO.print(U32.show(sqsum(5n, 0)))
""",
        """import Base
def sqsum(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      +k = U32.from_nat(n)
      sqsum(p, U32.add(acc, U32.mul(k, k)))
def main() -> IO(Unit):
  IO.print(U32.show(sqsum(Nat.div(25n, 5n), 0)))
""",
        f"{exp_s5}\n",
    )

    # --- M2: Helper call vs inlined body ---
    def py_mix(a, b, c):
        t = (a * 3 + b) ^ (c + 7)
        return (t & 0xFFFF) + (t >> 4)
    exp_m2 = sum(py_mix(i, i + 1, i + 2) for i in range(1, 31))
    add_pair(
        "m2_helper_vs_inline_arith", "helper_vs_inline", "Helper call vs manually inlined body in loop",
        """import Base
def mix(a: U32, b: U32, c: U32) -> U32:
  +t = U32.xor(U32.add(U32.mul(a, 3), b), U32.add(c, 7))
  U32.add(U32.and(t, 65535), U32.shrn(t, 4n))
def loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      +i = U32.from_nat(n)
      loop(p, U32.add(acc, mix(i, U32.add(i, 1), U32.add(i, 2))))
def main() -> IO(Unit):
  IO.print(U32.show(loop(30n, 0)))
""",
        """import Base
def loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      +i = U32.from_nat(n)
      +t = U32.xor(U32.add(U32.mul(i, 3), U32.add(i, 1)), U32.add(U32.add(i, 2), 7))
      v = U32.add(U32.and(t, 65535), U32.shrn(t, 4n))
      loop(p, U32.add(acc, v))
def main() -> IO(Unit):
  IO.print(U32.show(loop(30n, 0)))
""",
        f"{exp_m2}\n",
    )

    exp_m2b = sum((i * 2) + (i + 5) for i in range(1, 21))
    add_pair(
        "m2_helper_adt_vs_inline", "helper_vs_inline", "Helper returning Pair ADT vs inlined Pair",
        """import Base
type P2 is Data:
  MkP2{a: U32, b: U32}
def mkp(+x: U32) -> P2:
  MkP2{U32.mul(x, 2), U32.add(x, 5)}
def usep(p: P2) -> U32:
  match p:
    case MkP2{a, b}: U32.add(a, b)
def loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop(p, U32.add(acc, usep(mkp(U32.from_nat(n)))))
def main() -> IO(Unit):
  IO.print(U32.show(loop(20n, 0)))
""",
        """import Base
def loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      +x = U32.from_nat(n)
      loop(p, U32.add(acc, U32.add(U32.mul(x, 2), U32.add(x, 5))))
def main() -> IO(Unit):
  IO.print(U32.show(loop(20n, 0)))
""",
        f"{exp_m2b}\n",
    )

    def py_f3c(x): return ((x + 3) * 2) + ((x + 3) // 2)
    exp_m2c = sum(py_f3c(i) for i in range(1, 26))
    add_pair(
        "m2_3helper_chain_vs_fused", "helper_vs_inline", "3-helper call chain vs single fused body",
        """import Base
def h1(x: U32) -> U32: U32.add(x, 3)
def h2(+y: U32) -> U32: U32.mul(y, 2)
def h3(+y: U32) -> U32: U32.div(y, 2)
def combine(x: U32) -> U32:
  +y = h1(x)
  U32.add(h2(y), h3(y))
def loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop(p, U32.add(acc, combine(U32.from_nat(n))))
def main() -> IO(Unit):
  IO.print(U32.show(loop(25n, 0)))
""",
        """import Base
def loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      +y = U32.add(U32.from_nat(n), 3)
      loop(p, U32.add(acc, U32.add(U32.mul(y, 2), U32.div(y, 2))))
def main() -> IO(Unit):
  IO.print(U32.show(loop(25n, 0)))
""",
        f"{exp_m2c}\n",
    )

    # --- M3: Tail-recursive vs non-tail-recursive equivalent ---
    exp_sq50 = sum(i * i for i in range(1, 51))
    add_pair(
        "m3_tail_vs_nontail_sqsum", "tail_vs_nontail", "Tail-recursive vs non-tail-recursive sum of squares 1..50",
        """import Base
def sq_tail(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      +k = U32.from_nat(n)
      sq_tail(p, U32.add(acc, U32.mul(k, k)))
def main() -> IO(Unit):
  IO.print(U32.show(sq_tail(50n, 0)))
""",
        """import Base
def sq_nontail(+n: Nat) -> U32:
  match n:
    case 0n: 0
    case 1n+p:
      +k = U32.from_nat(n)
      U32.add(U32.mul(k, k), sq_nontail(p))
def main() -> IO(Unit):
  IO.print(U32.show(sq_nontail(50n)))
""",
        f"{exp_sq50}\n",
    )

    exp_f11 = math.factorial(11)
    add_pair(
        "m3_tail_vs_nontail_fact11", "tail_vs_nontail", "Tail-recursive vs non-tail-recursive factorial(11)",
        """import Base
def f_tail(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: f_tail(p, U32.mul(acc, U32.from_nat(n)))
def main() -> IO(Unit):
  IO.print(U32.show(f_tail(11n, 1)))
""",
        """import Base
def f_nontail(+n: Nat) -> U32:
  match n:
    case 0n: 1
    case 1n+p: U32.mul(U32.from_nat(n), f_nontail(p))
def main() -> IO(Unit):
  IO.print(U32.show(f_nontail(11n)))
""",
        f"{exp_f11}\n",
    )

    exp_l30 = sum(range(1, 31))
    add_pair(
        "m3_tail_vs_nontail_list_sum", "tail_vs_nontail", "Tail-recursive vs non-tail-recursive List sum",
        """import Base
def mk(+n: Nat) -> List<&2, U32>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{U32.from_nat(n), mk(p)}
def lsum_t(xs: List<&2, U32>, +acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{h, t}: lsum_t(t, U32.add(acc, h))
def main() -> IO(Unit):
  IO.print(U32.show(lsum_t(mk(30n), 0)))
""",
        """import Base
def mk(+n: Nat) -> List<&2, U32>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{U32.from_nat(n), mk(p)}
def lsum_nt(xs: List<&2, U32>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{h, t}: U32.add(h, lsum_nt(t))
def main() -> IO(Unit):
  IO.print(U32.show(lsum_nt(mk(30n))))
""",
        f"{exp_l30}\n",
    )

    exp_p = 3 ** 15
    add_pair(
        "m3_tail_vs_nontail_pow", "tail_vs_nontail", "Tail-recursive vs non-tail-recursive 3^15",
        """import Base
def pw_t(n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: pw_t(p, U32.mul(acc, 3))
def main() -> IO(Unit):
  IO.print(U32.show(pw_t(15n, 1)))
""",
        """import Base
def pw_nt(n: Nat) -> U32:
  match n:
    case 0n: 1
    case 1n+p: U32.mul(3, pw_nt(p))
def main() -> IO(Unit):
  IO.print(U32.show(pw_nt(15n)))
""",
        f"{exp_p}\n",
    )

    # --- M4: Single-ctor record vs unpacked arguments ---
    a, b, c, d = 1, 2, 3, 4
    for _ in range(25):
        a, b, c, d = a + b, b + 1, c + a, d + (c % 7)
    exp_m4a = a + b + c + d
    add_pair(
        "m4_rec4_vs_unpacked", "record_vs_unpacked", "4-field single-ctor record vs 4 unpacked args",
        """import Base
type S4 is Data:
  MkS4{a: U32, b: U32, c: U32, d: U32}
def loop(n: Nat, +s: S4) -> U32:
  match n s:
    case 0n MkS4{a, b, c, d}: U32.add(U32.add(a, b), U32.add(c, d))
    case 1n+p MkS4{a, b, c, d}:
      loop(p, MkS4{U32.add(a, b), U32.add(b, 1), U32.add(c, a), U32.add(d, U32.mod(c, 7))})
def main() -> IO(Unit):
  IO.print(U32.show(loop(25n, MkS4{1, 2, 3, 4})))
""",
        """import Base
def loop(n: Nat, +a: U32, +b: U32, +c: U32, +d: U32) -> U32:
  match n:
    case 0n: U32.add(U32.add(a, b), U32.add(c, d))
    case 1n+p:
      loop(p, U32.add(a, b), U32.add(b, 1), U32.add(c, a), U32.add(d, U32.mod(c, 7)))
def main() -> IO(Unit):
  IO.print(U32.show(loop(25n, 1, 2, 3, 4)))
""",
        f"{exp_m4a}\n",
    )

    vs = [1, 2, 3, 4, 5, 6, 7, 8]
    for _ in range(15):
        vs = [vs[1] + 1, vs[2] + 2, vs[3] + 3, vs[4] + 4, vs[5] + 5, vs[6] + 6, vs[7] + 7, vs[0] + 8]
    exp_m4b = sum(vs)
    add_pair(
        "m4_rec8_vs_unpacked", "record_vs_unpacked", "8-field single-ctor record vs 8 unpacked args",
        """import Base
type S8 is Data:
  MkS8{x0: U32, x1: U32, x2: U32, x3: U32, x4: U32, x5: U32, x6: U32, x7: U32}
def loop(n: Nat, +s: S8) -> U32:
  match n s:
    case 0n MkS8{x0, x1, x2, x3, x4, x5, x6, x7}:
      U32.add(U32.add(U32.add(x0, x1), U32.add(x2, x3)), U32.add(U32.add(x4, x5), U32.add(x6, x7)))
    case 1n+p MkS8{x0, x1, x2, x3, x4, x5, x6, x7}:
      loop(p, MkS8{U32.add(x1, 1), U32.add(x2, 2), U32.add(x3, 3), U32.add(x4, 4), U32.add(x5, 5), U32.add(x6, 6), U32.add(x7, 7), U32.add(x0, 8)})
def main() -> IO(Unit):
  IO.print(U32.show(loop(15n, MkS8{1, 2, 3, 4, 5, 6, 7, 8})))
""",
        """import Base
def loop(n: Nat, x0: U32, x1: U32, x2: U32, x3: U32, x4: U32, x5: U32, x6: U32, x7: U32) -> U32:
  match n:
    case 0n: U32.add(U32.add(U32.add(x0, x1), U32.add(x2, x3)), U32.add(U32.add(x4, x5), U32.add(x6, x7)))
    case 1n+p:
      loop(p, U32.add(x1, 1), U32.add(x2, 2), U32.add(x3, 3), U32.add(x4, 4), U32.add(x5, 5), U32.add(x6, 6), U32.add(x7, 7), U32.add(x0, 8))
def main() -> IO(Unit):
  IO.print(U32.show(loop(15n, 1, 2, 3, 4, 5, 6, 7, 8)))
""",
        f"{exp_m4b}\n",
    )

    # --- M5: match/if vs dense .rodata LUT table ---
    lut16 = [(i * i * 3 + 7 * i + 11) % 997 for i in range(16)]
    exp_lut16 = sum(lut16[i] if i < 16 else 999 for i in range(20))
    match_arms = "\n".join(f"    case {i}: {lut16[i]}" for i in range(16)) + "\n    case _: 999"
    def mk_if_expr(lo: int, hi: int) -> str:
        if lo == hi:
            return str(lut16[lo])
        mid = (lo + hi) // 2
        return f"pick_b(U32.is_le(x, {mid}), {mk_if_expr(lo, mid)}, {mk_if_expr(mid + 1, hi)})"
    if_expr = f"pick_b(U32.is_lt(x, 16), {mk_if_expr(0, 15)}, 999)"
    add_pair(
        "m5_dense_lut16_vs_if_tree", "lut_vs_if", "16-way dense match (.rodata LUT) vs binary if-tree",
        f"""import Base
def f(x: U32) -> U32:
  match x:
{match_arms}
def loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop(p, U32.add(acc, f(U32.from_nat(p))))
def main() -> IO(Unit):
  IO.print(U32.show(loop(20n, 0)))
""",
        f"""import Base
def pick_b(c: Bool, t: U32, f: U32) -> U32:
  match c:
    case True{{}}: t
    case False{{}}: f
def f(+x: U32) -> U32:
  {if_expr}
def loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop(p, U32.add(acc, f(U32.from_nat(p))))
def main() -> IO(Unit):
  IO.print(U32.show(loop(20n, 0)))
""",
        f"{exp_lut16}\n",
    )

    lut32 = [(i * 13 + 5) % 29 for i in range(32)]
    exp_lut32 = sum(lut32[i] if i < 32 else 77 for i in range(36))
    match_arms32 = "\n".join(f"    case {i}: {lut32[i]}" for i in range(32)) + "\n    case _: 77"
    add_pair(
        "m5_dense_lut32_vs_formula", "lut_vs_if", "32-way dense match (.rodata LUT) vs arithmetic formula",
        f"""import Base
def f(x: U32) -> U32:
  match x:
{match_arms32}
def loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop(p, U32.add(acc, f(U32.from_nat(p))))
def main() -> IO(Unit):
  IO.print(U32.show(loop(36n, 0)))
""",
        """import Base
def f_go(lt: Bool, x: U32) -> U32:
  match lt:
    case False{}: 77
    case True{}: U32.mod(U32.add(U32.mul(x, 13), 5), 29)
def f(+x: U32) -> U32:
  f_go(U32.is_lt(x, 32), x)
def loop(+n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop(p, U32.add(acc, f(U32.from_nat(p))))
def main() -> IO(Unit):
  IO.print(U32.show(loop(36n, 0)))
""",
        f"{exp_lut32}\n",
    )

    # --- M6: Unused pure in-range argument vs eliminated argument ---
    add_pair(
        "m6_unused_u32_arg", "unused_arg", "Unused pure in-range U32 argument vs eliminated",
        """import Base
def f(used: U32, unused: U32) -> U32:
  U32.add(U32.mul(used, 3), 7)
def main() -> IO(Unit):
  IO.print(U32.show(f(15, U32.mul(123, 456))))
""",
        """import Base
def f(used: U32) -> U32:
  U32.add(U32.mul(used, 3), 7)
def main() -> IO(Unit):
  IO.print(U32.show(f(15)))
""",
        "52\n",
    )

    add_pair(
        "m6_unused_nat_arg", "unused_arg", "Unused pure in-range Nat argument vs eliminated",
        """import Base
def f(used: U32, unused: Nat) -> U32:
  U32.add(used, 100)
def main() -> IO(Unit):
  IO.print(U32.show(f(42, Nat.mul(1000n, 2000n))))
""",
        """import Base
def f(used: U32) -> U32:
  U32.add(used, 100)
def main() -> IO(Unit):
  IO.print(U32.show(f(42)))
""",
        "142\n",
    )

    add_pair(
        "m6_unused_adt_tree_arg", "unused_arg", "Unused heap ADT tree argument vs eliminated",
        """import Base
type Tree is Data:
  Leaf{v: U32}
  Node{l: Tree, r: Tree}
def mk(+d: Nat) -> Tree:
  match d:
    case 0n: Leaf{1}
    case 1n+p: Node{mk(p), mk(p)}
def f(used: U32, unused: Tree) -> U32:
  U32.mul(used, 11)
def main() -> IO(Unit):
  IO.print(U32.show(f(9, mk(5n))))
""",
        """import Base
def f(used: U32) -> U32:
  U32.mul(used, 11)
def main() -> IO(Unit):
  IO.print(U32.show(f(9)))
""",
        "99\n",
    )

    # --- M7: Shallow vs deep nested ADT matching / borrowing / reuse ---
    code_nested = """import Base
type Box is Data:
  B0{}
  B1{x: U32}
  B2{inner: Box, y: U32}
def eval_b(b: Box) -> U32:
  match b:
    case B2{B1{x}, y}: U32.add(U32.mul(x, 10), y)
    case B2{B0{}, y}: U32.add(y, 100)
    case B2{B2{_, z}, y}: U32.add(z, y)
    case B1{x}: x
    case B0{}: 0
def main() -> IO(Unit):
  r1 = eval_b(B2{B1{7}, 3})
  r2 = eval_b(B2{B0{}, 5})
  r3 = eval_b(B2{B2{B0{}, 20}, 4})
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r3))
"""
    code_shallow = """import Base
type Box is Data:
  B0{}
  B1{x: U32}
  B2{inner: Box, y: U32}
def eval_inner(inner: Box, y: U32) -> U32:
  match inner:
    case B0{}: U32.add(y, 100)
    case B1{x}: U32.add(U32.mul(x, 10), y)
    case B2{_, z}: U32.add(z, y)
def eval_b(b: Box) -> U32:
  match b:
    case B0{}: 0
    case B1{x}: x
    case B2{inner, y}: eval_inner(inner, y)
def main() -> IO(Unit):
  r1 = eval_b(B2{B1{7}, 3})
  r2 = eval_b(B2{B0{}, 5})
  r3 = eval_b(B2{B2{B0{}, 20}, 4})
  IO.print(U32.show(r1) ++ "," ++ U32.show(r2) ++ "," ++ U32.show(r3))
"""
    add_pair("m7_nested_vs_shallow_adt_match", "adt_match_reuse", "Nested single ADT match vs 2-step shallow match", code_nested, code_shallow, "73,105,24\n")

    pa, pb = 1, 2
    for _ in range(12):
        pa, pb = pa + pb, pa + 1
    add_pair(
        "m7_borrow_vs_owned_rebuild", "adt_match_reuse", "Borrowed read then rebuild vs owned destructure",
        """import Base
type MyPair is Data:
  MkP{a: U32, b: U32}
def peek_a(+p: MyPair) -> U32:
  match p:
    case MkP{a, b}: a
def rebuild(p: MyPair, x: U32) -> MyPair:
  match p:
    case MkP{a, b}: MkP{U32.add(a, b), U32.add(x, 1)}
def step(+p: MyPair) -> MyPair:
  rebuild(p, peek_a(p))
def run(n: Nat, p: MyPair) -> U32:
  match n p:
    case 0n MkP{a, b}: U32.add(a, b)
    case 1n+k _: run(k, step(p))
def main() -> IO(Unit):
  IO.print(U32.show(run(12n, MkP{1, 2})))
""",
        """import Base
type MyPair is Data:
  MkP{a: U32, b: U32}
def step(+p: MyPair) -> MyPair:
  match p:
    case MkP{a, b}: MkP{U32.add(a, b), U32.add(a, 1)}
def run(n: Nat, p: MyPair) -> U32:
  match n p:
    case 0n MkP{a, b}: U32.add(a, b)
    case 1n+k _: run(k, step(p))
def main() -> IO(Unit):
  IO.print(U32.show(run(12n, MkP{1, 2})))
""",
        f"{pa + pb}\n",
    )

    xs = [2, 4, 6, 8, 10, 12]
    exp_m7c = sum((x * 2 + 1) * 3 for x in xs)
    add_pair(
        "m7_list_twopass_vs_fused", "adt_match_reuse", "Two-pass list transform (ctor reuse) vs single-pass fused",
        """import Base
def pass1(xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{h, t}: Con{U32.add(U32.mul(h, 2), 1), pass1(t)}
def pass2(xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{h, t}: Con{U32.mul(h, 3), pass2(t)}
def lsum(xs: List<&2, U32>, +acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{h, t}: lsum(t, U32.add(acc, h))
def main() -> IO(Unit):
  xs : List<&2, U32> = Con{2, Con{4, Con{6, Con{8, Con{10, Con{12, Nil{}}}}}}}
  IO.print(U32.show(lsum(pass2(pass1(xs)), 0)))
""",
        """import Base
def lsum_fused(xs: List<&2, U32>, +acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{h, t}: lsum_fused(t, U32.add(acc, U32.mul(U32.add(U32.mul(h, 2), 1), 3)))
def main() -> IO(Unit):
  xs : List<&2, U32> = Con{2, Con{4, Con{6, Con{8, Con{10, Con{12, Nil{}}}}}}}
  IO.print(U32.show(lsum_fused(xs, 0)))
""",
        f"{exp_m7c}\n",
    )

    # --- 35 Deterministic Parametric State Machines ---
    for seed in range(1, 36):
        a0 = (seed * 37 + 11) % 500 + 1
        b0 = (seed * 53 + 29) % 500 + 1
        c0 = (seed * 71 + 7) % 17 + 1
        iters = 10 + (seed % 15)
        a, b, c = a0, b0, c0
        for step_i in range(iters):
            tag = (a + b + step_i) % 4
            if tag == 0:
                a = a + b + c
                b = (b ^ a) & 0xFFFF
            elif tag == 1:
                a = (a * 3 + 5) & 0xFFFFF
                b = b + (a // c)
            elif tag == 2:
                a = abs(a - b) + c
                b = (b << 1) & 0xFFFFF
            else:
                a = (a >> 1) + b
                b = (b % (c + 1)) + 7
        expected = f"{a},{b}\n"
        code = f"""import Base

type St is Data:
  MkSt{{a: U32, b: U32}}

def abs_diff_go(ge: Bool, a: U32, b: U32) -> U32:
  match ge:
    case True{{}}: U32.sub(a, b)
    case False{{}}: U32.sub(b, a)

def abs_diff(+a: U32, +b: U32) -> U32:
  abs_diff_go(U32.is_ge(a, b), a, b)

def step_tag(tag: U32, +a: U32, +b: U32, +c: U32) -> St:
  match tag:
    case 0:
      +na = U32.add(U32.add(a, b), c)
      nb = U32.and(U32.xor(b, na), 65535)
      MkSt{{na, nb}}
    case 1:
      +na = U32.and(U32.add(U32.mul(a, 3), 5), 1048575)
      nb = U32.add(b, U32.div(na, c))
      MkSt{{na, nb}}
    case 2:
      na = U32.add(abs_diff(a, b), c)
      nb = U32.and(U32.shln(b, 1n), 1048575)
      MkSt{{na, nb}}
    case _:
      na = U32.add(U32.shrn(a, 1n), b)
      nb = U32.add(U32.mod(b, U32.add(c, 1)), 7)
      MkSt{{na, nb}}

def step(+st: St, +i: U32, +c: U32) -> St:
  match st:
    case MkSt{{a, b}}:
      step_tag(U32.mod(U32.add(U32.add(a, b), i), 4), a, b, c)

def run(n: Nat, +i: U32, +c: U32, st: St) -> St:
  match n:
    case 0n: st
    case 1n+p: run(p, U32.add(i, 1), c, step(st, i, c))

def show_st(st: St) -> String:
  match st:
    case MkSt{{a, b}}: U32.show(a) ++ "," ++ U32.show(b)

def main() -> IO(Unit):
  IO.print(show_st(run({iters}n, 0, {c0}, MkSt{{{a0}, {b0}}})))
"""
        cases.append(Case(f"fuzz_state_machine_{seed:02d}", "A", "metamorphic_state_sweep", f"Deterministic state machine seed={seed} ({iters} steps)", code, expected))

    return cases


# =============================================================================
# GROUP B: BOUNDARY & SPECIFICATION-EDGE PROBES (KEPT STRICTLY SEPARATE)
# =============================================================================

def gen_group_b() -> list[Case]:
    cases: list[Case] = []

    f32_show_probes = [
        ("b1_f32_show_2097152_25", "2097152.25", "F32.show(2097152.25) — JS vs C/bend5k rounding tie-break"),
        ("b1_f32_show_neg_zero", "F32.neg(0.0)", "F32.show(-0.0) — negative zero sign preservation"),
        ("b1_f32_show_pos_zero", "0.0", "F32.show(0.0)"),
        ("b1_f32_show_0_1", "0.1", "F32.show(0.1) — shortest roundtrip vs fixed digits"),
        ("b1_f32_show_16777216", "16777216.0", "F32.show(2^24) — integer boundary"),
        ("b1_f32_show_inf", "F32.div(1.0, 0.0)", "F32.show(+Inf)"),
        ("b1_f32_show_neg_inf", "F32.div(F32.neg(1.0), 0.0)", "F32.show(-Inf)"),
        ("b1_f32_show_nan", "F32.div(0.0, 0.0)", "F32.show(NaN)"),
        ("b1_f32_show_small_1e_7", "0.0000001", "F32.show(1e-7) — scientific vs decimal notation"),
        ("b1_f32_show_pi", "F32.pi()", "F32.show(F32.pi()) — 7-digit JS/C vs 6-digit bend5k"),
    ]
    for cid, expr, desc in f32_show_probes:
        code = f"""import Base

def main() -> IO(Unit):
  IO.print(F32.show({expr}))
"""
        cases.append(Case(cid, "B", "b1_f32_show", desc, code, None, "Boundary probe: F32.show formatting across JS/C/bend5k"))

    # B2: Nat 2^48 overflow (including live upstream #2181 reproducer!)
    cases.append(Case(
        "b2_nat_2p48_used_mul", "B", "b2_nat_2p48_overflow",
        "Used Nat.mul(2^24, 2^24) = 2^48",
        """import Base
def main() -> IO(Unit):
  IO.print(Nat.show(Nat.mul(16777216n, 16777216n)))
""",
        None, "Upstream law: Nat past 2^48-1 fail-stops (exit 1)"
    ))

    cases.append(Case(
        "b2_nat_2p48_issue2181_match_lit", "B", "b2_nat_2p48_overflow",
        "Upstream #2181: unused overflowing Nat in match on literal 0n (Upstream C returns 7, JS/bend5k fail-stop!)",
        """import Base
def pick(n: Nat, a: U32, b: Nat) -> U32:
  match n:
    case 0n: a
    case 1n+_: U32.from_nat(b)
def main() -> IO(Unit):
  IO.print(U32.show(pick(0n, 7, Nat.mul(16777216n, 16777216n))))
""",
        None, "Upstream #2181: Upstream C specializes pick(0n,...) & drops b -> prints 7; JS/bend5k fail-stop!",
        pair_id="b2_issue2181", pair_side="a"
    ))

    cases.append(Case(
        "b2_nat_2p48_issue2181_match_sub", "B", "b2_nat_2p48_overflow",
        "Upstream #2181 metamorphic twin: match on Nat.sub(5n, 5n) (all 4 backends fail-stop!)",
        """import Base
def pick(n: Nat, a: U32, b: Nat) -> U32:
  match n:
    case 0n: a
    case 1n+_: U32.from_nat(b)
def z(+k: Nat) -> Nat:
  Nat.sub(k, k)
def main() -> IO(Unit):
  IO.print(U32.show(pick(z(5n), 7, Nat.mul(16777216n, 16777216n))))
""",
        None, "Upstream #2181 twin: computed 0n prevents C specialization -> all 4 fail-stop!",
        pair_id="b2_issue2181", pair_side="b"
    ))

    cases.append(Case(
        "b2_nat_2p48_unused_ignore_lit", "B", "b2_nat_2p48_overflow",
        "Unused Nat.mul(2^24, 2^24) passed to ignoring fn",
        """import Base
def ignore(x: Nat) -> U32:
  42
def main() -> IO(Unit):
  IO.print(U32.show(ignore(Nat.mul(16777216n, 16777216n))))
""",
        None, "All 4 backends evaluate argument strictly and fail-stop"
    ))

    cases.append(Case(
        "b2_nat_2p48_succ_used", "B", "b2_nat_2p48_overflow",
        "Used Succ{2^48 - 1} (built from valid <=2^32-1 literals)",
        """import Base
def main() -> IO(Unit):
  x = Nat.mul(16777216n, 16777215n)
  y = Nat.add(x, 16777215n)
  IO.print(Nat.show(Succ{y}))
""",
        None, "Nat Succ overflow at 2^48-1"
    ))

    cases.append(Case(
        "b2_nat_2p48_add_used", "B", "b2_nat_2p48_overflow",
        "Used Nat.add(2^48 - 1, 1n)",
        """import Base
def main() -> IO(Unit):
  x = Nat.mul(16777216n, 16777215n)
  y = Nat.add(x, 16777215n)
  IO.print(Nat.show(Nat.add(y, 1n)))
""",
        None, "Nat.add overflow at 2^48-1"
    ))

    cases.append(Case(
        "b2_nat_2p48_double_used", "B", "b2_nat_2p48_overflow",
        "Used Nat.double(2^47)",
        """import Base
def main() -> IO(Unit):
  x = Nat.mul(16777216n, 8388608n)
  IO.print(Nat.show(Nat.double(x)))
""",
        None, "Nat.double overflow at 2^47"
    ))

    # B3: U32 wraparound, shift >= 32, div/mod by 0
    cases.append(Case(
        "b3_u32_wraparound", "B", "b3_u32_boundaries",
        "U32 add/sub/mul/inc wraparound mod 2^32",
        """import Base
def main() -> IO(Unit):
  a = U32.add(4294967295, 2)
  b = U32.sub(0, 1)
  c = U32.mul(65536, 65536)
  d = U32.inc(4294967295)
  IO.print(U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d))
""",
        "1,4294967295,0,0\n", "Base Word(32n) modular arithmetic mod 2^32"
    ))

    cases.append(Case(
        "b3_u32_shift_ge32_const", "B", "b3_u32_boundaries",
        "U32.shln/shrn with constant shift 32n, 33n, 64n",
        """import Base
def main() -> IO(Unit):
  a = U32.shln(1, 32n)
  b = U32.shln(1, 33n)
  c = U32.shrn(2147483648, 32n)
  d = U32.shrn(2147483648, 33n)
  e = U32.shln(1, 64n)
  IO.print(U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d) ++ "," ++ U32.show(e))
""",
        "0,0,0,0,0\n", "Base U32.shln/shrn defined by Nat recursion over Word(32n) -> 0 for >= 32"
    ))

    cases.append(Case(
        "b3_u32_shift_ge32_dynamic", "B", "b3_u32_boundaries",
        "U32.shln/shrn with dynamic shift >= 32",
        """import Base
def sh(+a: U32, +k: Nat) -> U32:
  U32.add(U32.shln(a, k), U32.shrn(a, k))
def main() -> IO(Unit):
  IO.print(U32.show(sh(2147483649, Nat.add(30n, 2n))) ++ "," ++ U32.show(sh(2147483649, Nat.add(30n, 3n))))
""",
        "0,0\n", "Dynamic shift >= 32 (catches x86/C shift-mask-by-31 UB!)"
    ))

    cases.append(Case(
        "b3_u32_div_mod_zero", "B", "b3_u32_boundaries",
        "U32.div(7, 0), U32.mod(7, 0), U32.div(0, 0), U32.mod(0, 0)",
        """import Base
def main() -> IO(Unit):
  a = U32.div(7, 0)
  b = U32.mod(7, 0)
  c = U32.div(0, 0)
  d = U32.mod(0, 0)
  IO.print(U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d))
""",
        "0,7,0,0\n", "Base U32.div(a,0)=0, U32.mod(a,0)=a"
    ))

    # B4: Nat.sub underflow, Nat.div/mod by 0, and >2^32-1 Nat literal parser boundary
    cases.append(Case(
        "b4_nat_sub_underflow_and_div0", "B", "b4_nat_boundaries",
        "Nat.sub(3n, 10n), Nat.div(7n, 0n), Nat.mod(7n, 0n)",
        """import Base
def main() -> IO(Unit):
  a = Nat.sub(3n, 10n)
  b = Nat.div(7n, 0n)
  c = Nat.mod(7n, 0n)
  IO.print(Nat.show(a) ++ "," ++ Nat.show(b) ++ "," ++ Nat.show(c))
""",
        "0,0,7\n", "Base Nat.sub truncates to 0; Nat.div(7,0)=0, Nat.mod(7,0)=7"
    ))

    cases.append(Case(
        "b4_nat_literal_gt_u32max", "B", "b4_nat_boundaries",
        "Nat literal 5000000000n (>2^32-1): upstream rejects at parse time, bend5k silently truncates mod 2^32!",
        """import Base
def main() -> IO(Unit):
  IO.print(Nat.show(5000000000n))
""",
        None, "Parser boundary: upstream caps Nat literals at 4294967295n; bend5k accepts & prints 705032704!"
    ))

    # B5: F32.to_u32 edges & NaN / -0.0 equality
    cases.append(Case(
        "b5_f32_to_u32_edges", "B", "b5_f32_edges",
        "F32.to_u32 on -1.0, +Inf, NaN, 2^32",
        """import Base
def main() -> IO(Unit):
  a = F32.to_u32(F32.neg(1.0))
  b = F32.to_u32(F32.div(1.0, 0.0))
  c = F32.to_u32(F32.div(0.0, 0.0))
  d = F32.to_u32(F32.mul(65536.0, 65536.0))
  IO.print(U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d))
""",
        "0,0,0,0\n", "Out-of-range F32.to_u32 returns 0 per comp.ts"
    ))

    cases.append(Case(
        "b5_f32_negzero_and_nan_cmp", "B", "b5_f32_edges",
        "F32 -0.0 bits/eq and NaN eq/ne",
        """import Base
def main() -> IO(Unit):
  b1 = F32.bits(F32.neg(0.0))
  e1 = F32.is_eq(0.0, F32.neg(0.0))
  e2 = F32.is_eq(F32.div(0.0, 0.0), F32.div(0.0, 0.0))
  e3 = F32.is_ne(F32.div(0.0, 0.0), F32.div(0.0, 0.0))
  IO.print(U32.show(b1) ++ "," ++ Bool.show(e1) ++ "," ++ Bool.show(e2) ++ "," ++ Bool.show(e3))
""",
        "2147483648,True,False,True\n", "IEEE-754 -0.0 and NaN comparisons"
    ))

    # B6: Char / String escapes & Unicode
    cases.append(Case(
        "b6_string_escapes_and_unicode", "B", "b6_char_string",
        "String escapes (\\t, \\\", \\\\) and Unicode \\u{00e9}",
        r'''import Base
def show_s(+s: String) -> String:
  String.quote(s) ++ "|" ++ Nat.show(String.length(s))
def main() -> IO(Unit):
  IO.print(show_s("a\tb\"c\\d\u{00e9}"))
''',
        '"a\\tb\\"c\\\\dé"|8\n', "String.quote escape & Unicode handling across backends"
    ))

    cases.append(Case(
        "b6_char_quote_control", "B", "b6_char_string",
        "Char.quote on control chars (0, 10, 39, 92, 233)",
        """import Base
def main() -> IO(Unit):
  c0 = Char.quote(39, Chr{0})
  c1 = Char.quote(39, Chr{10})
  c2 = Char.quote(39, Chr{39})
  c3 = Char.quote(39, Chr{92})
  c4 = Char.quote(39, Chr{233})
  IO.print(c0 ++ "|" ++ c1 ++ "|" ++ c2 ++ "|" ++ c3 ++ "|" ++ c4)
""",
        "\\0|\\n|\\'|\\\\|é\n", "Char.quote on null, newline, quote, backslash, non-ASCII"
    ))

    return cases


def build_all_cases() -> list[Case]:
    cases = []
    cases.extend(gen_group_a_u32())
    cases.extend(gen_group_a_nat())
    cases.extend(gen_group_a_adt())
    cases.extend(gen_group_a_multi_match())
    cases.extend(gen_group_a_closures())
    cases.extend(gen_group_a_recursion())
    cases.extend(gen_group_a_arrays())
    cases.extend(gen_group_a_strings())
    cases.extend(gen_group_a_metamorphic())
    cases.extend(gen_group_b())
    return cases


# =============================================================================
# 5-WAY EXECUTION HARNESS (ALL PINNED TO CPU 4)
# =============================================================================

def run_pinned(cmd: list[str], timeout: int = 25) -> dict:
    full = ["taskset", "-c", str(CPU_PIN)] + cmd
    t0 = time.perf_counter()
    try:
        r = subprocess.run(full, capture_output=True, text=True, timeout=timeout)
        return {
            "rc": r.returncode,
            "stdout": r.stdout,
            "stderr": r.stderr,
            "ms": round((time.perf_counter() - t0) * 1000.0, 2),
            "timeout": False,
        }
    except subprocess.TimeoutExpired:
        return {
            "rc": -999,
            "stdout": "",
            "stderr": f"timeout>{timeout}s",
            "ms": round((time.perf_counter() - t0) * 1000.0, 2),
            "timeout": True,
        }


def run_case(c: Case, tmp: Path, bend5k_only: bool = False) -> dict:
    src = tmp / f"{c.id}.bend"
    src.write_text(c.code, encoding="utf-8")

    js_path = tmp / f"{c.id}.js"
    c_path = tmp / f"{c.id}.c"
    c_gcc_path = tmp / f"{c.id}_gcc.c"
    c_bin = tmp / f"{c.id}_c"

    if bend5k_only:
        up_emit = {"rc": 0, "stdout": "", "stderr": "", "ms": 0.0, "timeout": False}
        up_js = {"rc": 0, "stdout": c.py_oracle or "", "stderr": "", "ms": 0.0, "timeout": False}
        up_c = {"rc": 0, "stdout": c.py_oracle or "", "stderr": "", "ms": 0.0, "timeout": False}
    else:
        up_emit = run_pinned(["bash", str(LOCKED_BUN), str(src), "-o", str(js_path), "-o", str(c_path)], timeout=90)

        if up_emit["rc"] == 0 and js_path.exists():
            up_js = run_pinned([str(NODE), str(js_path)], timeout=20)
        else:
            up_js = {"rc": up_emit["rc"], "stdout": "", "stderr": f"UP_EMIT_ERR: {up_emit['stderr'][:300]}", "ms": 0.0, "timeout": up_emit["timeout"]}

        if up_emit["rc"] == 0 and c_path.exists():
            c_text = c_path.read_text(encoding="utf-8").replace("__attribute__((musttail)) ", "")
            c_gcc_path.write_text(c_text, encoding="utf-8")
            c_cc = run_pinned([GCC, "-std=c11", "-O2", str(c_gcc_path), "-lpthread", "-lm", "-o", str(c_bin)], timeout=30)
            if c_cc["rc"] == 0:
                up_c = run_pinned([str(c_bin)], timeout=20)
            else:
                up_c = {"rc": c_cc["rc"], "stdout": "", "stderr": f"UP_C_CC_ERR: {c_cc['stderr'][:300]}", "ms": c_cc["ms"], "timeout": c_cc["timeout"]}
        else:
            up_c = {"rc": up_emit["rc"], "stdout": "", "stderr": f"UP_EMIT_ERR: {up_emit['stderr'][:300]}", "ms": 0.0, "timeout": up_emit["timeout"]}

    b5k = {}
    for opt, key in [("-O0", "bend5k_o0"), ("-O2", "bend5k_o2")]:
        obj = tmp / f"{c.id}_{key}.o"
        exe = tmp / f"{c.id}_{key}"
        em = run_pinned([str(BEND5K), opt, str(src), str(obj)], timeout=30)
        if em["rc"] != 0 or not obj.exists():
            b5k[key] = {"rc": em["rc"], "stdout": "", "stderr": f"B5K_EMIT_ERR: {em['stderr'][:300]}", "ms": em["ms"], "timeout": em["timeout"]}
            continue
        lk = run_pinned([GCC, "-no-pie", str(obj), str(RUNTIME_AGY), "-pthread", "-lm", "-o", str(exe)], timeout=20)
        if lk["rc"] != 0:
            b5k[key] = {"rc": lk["rc"], "stdout": "", "stderr": f"B5K_LINK_ERR: {lk['stderr'][:300]}", "ms": lk["ms"], "timeout": lk["timeout"]}
            continue
        b5k[key] = run_pinned([str(exe)], timeout=20)

    for p in [src, js_path, c_path, c_gcc_path, c_bin,
              tmp / f"{c.id}_bend5k_o0.o", tmp / f"{c.id}_bend5k_o0",
              tmp / f"{c.id}_bend5k_o2.o", tmp / f"{c.id}_bend5k_o2"]:
        if p.exists():
            p.unlink()

    lanes = {
        "upstream_js": up_js,
        "upstream_c": up_c,
        "bend5k_o0": b5k["bend5k_o0"],
        "bend5k_o2": b5k["bend5k_o2"],
    }

    sigs = {k: (v["rc"], v["stdout"]) for k, v in lanes.items()}
    backends_agree = len(set(sigs.values())) == 1
    all_rc0 = all(v["rc"] == 0 for v in lanes.values())

    if c.py_oracle is not None:
        all_5_agree = backends_agree and all_rc0 and (up_js["stdout"] == c.py_oracle)
        wrong_lanes = [k for k, v in lanes.items() if v["rc"] != 0 or v["stdout"] != c.py_oracle]
    else:
        all_5_agree = backends_agree
        wrong_lanes = [] if backends_agree else list(lanes.keys())

    return {
        "id": c.id,
        "group": c.group,
        "family": c.family,
        "description": c.description,
        "pair_id": c.pair_id,
        "pair_side": c.pair_side,
        "py_oracle": c.py_oracle,
        "py_note": c.py_note,
        "up_emit_rc": up_emit["rc"],
        "lanes": lanes,
        "backends_agree": backends_agree,
        "all_5_agree": all_5_agree,
        "wrong_lanes": wrong_lanes,
    }


def main() -> int:
    global BEND5K, RUNTIME_AGY, CPU_PIN
    ap = argparse.ArgumentParser()
    ap.add_argument("--group", choices=("all", "A", "B"), default="all")
    ap.add_argument("--ids", type=str, default="", help="Comma-separated case IDs to run (merges into --out if --merge)")
    ap.add_argument("--merge", action="store_true", help="Merge --ids results into existing --out JSON")
    ap.add_argument("--out", type=Path, default=OUT_DIR / "results.json")
    ap.add_argument("--bend5k", type=Path, default=BEND5K)
    ap.add_argument("--runtime", type=Path, default=RUNTIME_AGY)
    ap.add_argument("--cpu", type=int, default=CPU_PIN)
    ap.add_argument("--bend5k-only", action="store_true", help="Only run bend5k -O0/-O2 against py_oracle")
    ap.add_argument("--no-reproducers", action="store_true", help="Do not overwrite reproducers/ directory")
    args = ap.parse_args()
    BEND5K = args.bend5k
    RUNTIME_AGY = args.runtime
    CPU_PIN = args.cpu

    all_cases = build_all_cases()
    if args.group != "all":
        all_cases = [c for c in all_cases if c.group == args.group]
    if args.ids:
        want = set(args.ids.split(","))
        selected = [c for c in all_cases if c.id in want]
    else:
        selected = all_cases

    print(f"Running {len(selected)} cases on CPU {CPU_PIN}...", flush=True)
    new_results = {}
    t_start = time.perf_counter()

    with tempfile.TemporaryDirectory(prefix="l22_oracle_") as td:
        tmp = Path(td)
        for idx, c in enumerate(selected, 1):
            res = run_case(c, tmp, bend5k_only=args.bend5k_only)
            new_results[c.id] = res
            status = "PASS" if res["all_5_agree"] else "DIFF"
            outs = {k: (v["rc"], v["stdout"].strip()[:40]) for k, v in res["lanes"].items()}
            print(f"[{idx:3d}/{len(selected):3d}] {c.group}:{c.id:36s} {status} py={c.py_oracle!r} lanes={outs}", flush=True)

    elapsed = round(time.perf_counter() - t_start, 2)

    if args.merge and args.out.exists():
        old = json.loads(args.out.read_text(encoding="utf-8"))
        old_by_id = {r["id"]: r for r in old["results"]}
        old_by_id.update(new_results)
        results = [old_by_id[c.id] for c in all_cases if c.id in old_by_id]
        elapsed = round(old.get("elapsed_sec", 0.0) + elapsed, 2)
    else:
        results = [new_results[c.id] for c in selected]

    by_pair: dict[str, dict[str, dict]] = collections.defaultdict(dict)
    for r in results:
        if r["pair_id"]:
            by_pair[r["pair_id"]][r["pair_side"]] = r
    pair_diffs = []
    for pid, sides in sorted(by_pair.items()):
        if "a" in sides and "b" in sides:
            ra, rb = sides["a"], sides["b"]
            for lane in ("upstream_js", "upstream_c", "bend5k_o0", "bend5k_o2"):
                sa = (ra["lanes"][lane]["rc"], ra["lanes"][lane]["stdout"])
                sb = (rb["lanes"][lane]["rc"], rb["lanes"][lane]["stdout"])
                if sa != sb:
                    pair_diffs.append({"pair_id": pid, "lane": lane, "a": sa, "b": sb})

    ga = [r for r in results if r["group"] == "A"]
    gb = [r for r in results if r["group"] == "B"]
    ga_diffs = [r for r in ga if not r["all_5_agree"]]
    gb_diffs = [r for r in gb if not r["backends_agree"]]

    fam_counts = collections.Counter((r["group"], r["family"]) for r in results)

    summary = {
        "audit": "L22-ORACLE-DIFF",
        "cpu_pin": CPU_PIN,
        "commits": {
            "branch_head": "2f59e12ba76395352409166a02e324c23dca84c8",
            "upstream_bend2": "6180be5b21c4af6895395b27ad3cde026909364e",
        },
        "elapsed_sec": elapsed,
        "total_cases": len(results),
        "group_a": {
            "total": len(ga),
            "all_5_agree": sum(1 for r in ga if r["all_5_agree"]),
            "disagreements": len(ga_diffs),
            "disagreement_ids": [r["id"] for r in ga_diffs],
            "metamorphic_pairs": sum(1 for pid, s in by_pair.items() if s.get("a", {}).get("group") == "A"),
            "metamorphic_pair_diffs": [d for d in pair_diffs if not d["pair_id"].startswith("b")],
        },
        "group_b": {
            "total": len(gb),
            "all_4_backends_agree": sum(1 for r in gb if r["backends_agree"]),
            "disagreements": len(gb_diffs),
            "disagreement_ids": [r["id"] for r in gb_diffs],
            "metamorphic_pair_diffs": [d for d in pair_diffs if d["pair_id"].startswith("b")],
        },
        "family_counts": {f"{g}:{f}": n for (g, f), n in sorted(fam_counts.items())},
        "results": results,
    }

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")

    if not args.no_reproducers:
        rep_dir = OUT_DIR / "reproducers"
        rep_dir.mkdir(parents=True, exist_ok=True)
        for old_f in rep_dir.glob("*.bend"):
            old_f.unlink()
        code_by_id = {c.id: c.code for c in all_cases}
        for r in ga_diffs + gb_diffs:
            if r["id"] in code_by_id:
                (rep_dir / f"{r['group']}_{r['id']}.bend").write_text(code_by_id[r["id"]], encoding="utf-8")
        # Also save metamorphic twin for #2181 so both sides are preserved!
        if "b2_nat_2p48_issue2181_match_sub" in code_by_id:
            (rep_dir / "B_b2_nat_2p48_issue2181_match_sub.bend").write_text(code_by_id["b2_nat_2p48_issue2181_match_sub"], encoding="utf-8")

    print("\n=== SUMMARY ===")
    print(f"Elapsed: {elapsed}s | Total: {len(results)}")
    print(f"Group A: {summary['group_a']['all_5_agree']}/{summary['group_a']['total']} all-5-agree | diffs={summary['group_a']['disagreement_ids']}")
    print(f"Group A metamorphic pairs: {summary['group_a']['metamorphic_pairs']} | pair_diffs={len(summary['group_a']['metamorphic_pair_diffs'])}")
    print(f"Group B: {summary['group_b']['all_4_backends_agree']}/{summary['group_b']['total']} all-4-agree | diffs={summary['group_b']['disagreement_ids']}")
    print(f"Group B metamorphic pair diffs: {summary['group_b']['metamorphic_pair_diffs']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
