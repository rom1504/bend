#!/usr/bin/env python3
"""Verify focused19 (19/19) + 7 adversarial upstream differential tests for AGY-W2B-1 & AGY-W2B-2."""
import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
UPSTREAM = ROOT / "bend2/main.ts"
EMIT_OBJ = ROOT / "research/agy/emit_obj.mjs"
RT_OBJ = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
QUAL_CAT = ROOT / "selfhost/tests/phase182/qualification-catalog.json"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"

ADVERSARIAL_TESTS = {
    "reuse_rfc_shared": """
import Base

type Box3 is Data:
  B3{a: U32, b: U32, c: U32}

type Alt3 is Data:
  A3{x: U32, y: U32, z: U32}

def flip(n: Nat, t: Box3) -> Box3:
  match n:
    case 0n: t
    case 1n+p:
      match t:
        case B3{a, b, c}:
          flip(p, B3{U32.add(b, 1), U32.add(c, 2), U32.add(a, 3)})

def sum3(t: Box3) -> U32:
  match t:
    case B3{a, b, c}: U32.add(U32.mul(a, 100), U32.add(U32.mul(b, 10), c))

def run(+shared: Box3) -> U32:
  # shared is RFC-wrapped because of +shared used twice!
  # Mutating shared in-place during flip would corrupt the second sum3(shared)!
  r1 = flip(5n, shared)
  r2 = sum3(shared)
  U32.add(U32.mul(sum3(r1), 10000), r2)

def main() -> IO(Unit):
  IO.print(U32.show(run(B3{1, 2, 3})))
""",
    "reuse_static_term": """
import Base

type Tri is Data:
  T3{a: U32, b: U32, c: U32}

def static_tri() -> Tri:
  T3{7, 8, 9}

def bump(t: Tri) -> Tri:
  match t:
    case T3{a, b, c}: T3{U32.add(a, 1), U32.add(b, 2), U32.add(c, 3)}

def score(t: Tri) -> U32:
  match t:
    case T3{a, b, c}: U32.add(U32.mul(a, 100), U32.add(U32.mul(b, 10), c))

def loop(n: Nat, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop(p, U32.add(acc, score(bump(static_tri()))))

def main() -> IO(Unit):
  IO.print(U32.show(loop(10n, 0)))
""",
    "reuse_cross_arity": """
import Base

type Quad is Data:
  Q4{a: U32, b: U32, c: U32, d: U32}

type Triple is Data:
  T3{x: U32, y: U32, z: U32}

def q_to_t(q: Quad) -> Triple:
  match q:
    case Q4{a, b, c, d}: T3{U32.add(a, d), b, c}

def t_to_q(t: Triple) -> Quad:
  match t:
    case T3{+x, y, z}: Q4{y, z, x, U32.add(x, 1)}

def bounce(n: Nat, q: Quad) -> Quad:
  match n:
    case 0n: q
    case 1n+p: bounce(p, t_to_q(q_to_t(q)))

def score_q(q: Quad) -> U32:
  match q:
    case Q4{a, b, c, d}:
      U32.add(U32.mul(a, 1000), U32.add(U32.mul(b, 100), U32.add(U32.mul(c, 10), d)))

def main() -> IO(Unit):
  IO.print(U32.show(score_q(bounce(25n, Q4{1, 2, 3, 4}))))
""",
    "p114h_deep_dag": """
import Base

type BTree is Data:
  L{v: U32}
  N{l: BTree, r: BTree}

def mk(+d: Nat, +x: U32) -> BTree:
  match d:
    case 0n: L{x}
    case 1n+p: N{mk(p, U32.add(U32.mul(x, 2), 1)), mk(p, U32.add(U32.mul(x, 2), 2))}

def sum_t(t: BTree) -> U32:
  match t:
    case L{v}: v
    case N{l, r}: U32.add(sum_t(l), sum_t(r))

def wrap_sum(t: BTree) -> U32:
  match t:
    case L{v}: U32.add(v, 1)
    case N{l, r}: U32.add(sum_t(l), sum_t(r))

def double_tree(+d: Nat, t: BTree) -> BTree:
  match d t:
    case 0n L{v}: L{U32.mul(v, 3)}
    case 0n N{l, r}: N{l, r}
    case 1n+p L{v}: L{v}
    case 1n+p N{l, r}: N{double_tree(p, l), double_tree(p, r)}

def wrap_double(d: Nat, t: BTree) -> U32:
  wrap_sum(double_tree(d, t))

def main() -> IO(Unit):
  IO.print(U32.show(wrap_double(5n, mk(5n, 3))))
""",
    "p114h_many_args": """
import Base

type BTree is Data:
  L{v: U32}
  N{l: BTree, r: BTree}

# 6 user args -> state + 6 + 3 = 10 machine args (tests stack args in p114r_ calls!)
def accum(t: BTree, +a: U32, +b: U32, +c: U32, +d: U32, +e: U32) -> U32:
  match t:
    case L{v}: U32.add(v, U32.add(a, U32.add(b, U32.add(c, U32.add(d, e)))))
    case N{l, r}: U32.add(accum(l, a, b, c, d, e), accum(r, b, c, d, e, a))

def wrap6(t: BTree, +a: U32, +b: U32, +c: U32, +d: U32, +e: U32) -> U32:
  U32.add(accum(t, a, b, c, d, e), 7)

def outer(n: Nat, +a: U32, +b: U32, +c: U32, +d: U32, +e: U32) -> U32:
  match n:
    case 0n: 0
    case 1n+p:
      t : BTree = N{N{L{a}, L{b}}, N{L{c}, L{d}}}
      U32.add(wrap6(t, a, b, c, d, e), outer(p, b, c, d, e, a))

def main() -> IO(Unit):
  IO.print(U32.show(outer(4n, 1, 2, 3, 5, 8)))
""",
    "zero_arg_ctor_variants": """
import Base

type Color is Data:
  Red{}
  Green{}
  Blue{}
  Yellow{}
  Black{}

def pick_m(m: U32) -> Color:
  match m:
    case 0: Red{}
    case 1: Green{}
    case 2: Blue{}
    case 3: Yellow{}
    case _: Black{}

def pick(x: U32) -> Color:
  pick_m(U32.mod(x, 5))

def code(c: Color) -> U32:
  match c:
    case Red{}: 11
    case Green{}: 23
    case Blue{}: 37
    case Yellow{}: 53
    case Black{}: 71

def loop(n: Nat, +i: U32, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop(p, U32.add(i, 1), U32.add(U32.mul(acc, 31), code(pick(i))))

def main() -> IO(Unit):
  IO.print(U32.show(loop(20n, 0, 0)))
""",
    "reuse_with_drop_and_0arg": """
import Base

type Node is Data:
  Leaf{}
  Branch{l: Node, v: U32, r: Node}

def build(n: Nat, +v: U32) -> Node:
  match n:
    case 0n: Leaf{}
    case 1n+p: Branch{Leaf{}, v, build(p, U32.add(v, 1))}

def inc_all(t: Node) -> Node:
  match t:
    case Leaf{}: Leaf{}
    case Branch{l, v, r}: Branch{inc_all(l), U32.add(v, 10), inc_all(r)}

def sum_n(t: Node) -> U32:
  match t:
    case Leaf{}: 0
    case Branch{l, v, r}: U32.add(v, U32.add(sum_n(l), sum_n(r)))

def main() -> IO(Unit):
  IO.print(U32.show(sum_n(inc_all(build(12n, 1)))))
""",
}

def run_cmd(cmd, timeout=60):
    return subprocess.run(list(map(str, cmd)), capture_output=True, text=True, timeout=timeout)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--api", type=Path, required=True)
    ap.add_argument("--rt", type=Path, default=RT_OBJ)
    a = ap.parse_args()

    failed = []
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)

        # 1. Adversarial differential tests vs upstream Bend
        print(f"=== Adversarial Upstream Differential Tests ({len(ADVERSARIAL_TESTS)}) ===")
        for name, src_text in ADVERSARIAL_TESTS.items():
            src = td / f"{name}.bend"
            src.write_text(src_text.lstrip())
            up = run_cmd([BUN, UPSTREAM, src])
            if up.returncode != 0:
                print(f"  [FAIL] {name}: upstream failed: {up.stderr.strip()}")
                failed.append(name)
                continue
            obj = td / f"{name}.o"
            binp = td / f"{name}.bin"
            c1 = run_cmd([BUN, EMIT_OBJ, a.api, src, obj])
            if c1.returncode != 0:
                print(f"  [FAIL] {name}: emit_obj failed: {c1.stderr.strip()}")
                failed.append(name)
                continue
            c2 = run_cmd([CC, "-O2", "-no-pie", obj, a.rt, "-o", binp, "-lm", "-pthread"])
            if c2.returncode != 0:
                print(f"  [FAIL] {name}: link failed: {c2.stderr.strip()}")
                failed.append(name)
                continue
            ev = run_cmd([binp])
            if ev.returncode != 0 or ev.stdout != up.stdout:
                print(f"  [FAIL] {name}: mismatch! upstream={up.stdout!r} cand={ev.stdout!r} rc={ev.returncode}")
                failed.append(name)
            else:
                print(f"  [PASS] {name}: {ev.stdout.strip()!r}")

        # 2. focused19 from qualification-catalog.json
        cat = json.loads(QUAL_CAT.read_text())
        focused = [c for c in cat["cases"] if c["suite"] == "focused"]
        print(f"\n=== focused19 ({len(focused)} cases) ===")
        for c in focused:
            cid = c["id"]
            src = ROOT / c["source"]["file"]
            exp = c["expect"]
            obj = td / f"{c['name']}.o"
            binp = td / f"{c['name']}.bin"
            c1 = run_cmd([BUN, EMIT_OBJ, a.api, src, obj])
            if exp["stage"] != "execute":
                if c1.returncode != 0:
                    print(f"  [PASS] {cid} (expected refusal)")
                else:
                    print(f"  [FAIL] {cid}: expected refusal, but compiled!")
                    failed.append(cid)
                continue
            if c1.returncode != 0:
                print(f"  [FAIL] {cid}: emit_obj failed: {c1.stderr.strip()[:200]}")
                failed.append(cid)
                continue
            c2 = run_cmd([CC, "-O2", "-no-pie", obj, a.rt, "-o", binp, "-lm", "-pthread"])
            if c2.returncode != 0:
                print(f"  [FAIL] {cid}: link failed: {c2.stderr.strip()[:200]}")
                failed.append(cid)
                continue
            ev = run_cmd([binp])
            if ev.returncode != exp["exitCode"] or ev.stdout != exp["stdout"] or ev.stderr != exp["stderr"]:
                print(f"  [FAIL] {cid}: rc={ev.returncode} (exp {exp['exitCode']}), stdout={ev.stdout!r} (exp {exp['stdout']!r})")
                failed.append(cid)
            else:
                print(f"  [PASS] {cid}")

    print(f"\nSUMMARY: {len(ADVERSARIAL_TESTS) + len(focused) - len(failed)} / {len(ADVERSARIAL_TESTS) + len(focused)} PASS")
    if failed:
        print("FAILED:", failed)
        sys.exit(1)

if __name__ == "__main__":
    main()
