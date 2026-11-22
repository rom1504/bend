#!/usr/bin/env python3
"""Tier-2 Adversarial & Boundary Differential Test Suite for Wave 2B Track B:
  - AGY-W2B-3 (apply_bst_zipper.py)
  - AGY-W2B-4 (apply_flow_native.py)

Requires bit-exact stdout across:
  1. Upstream Bend (bun /home/ai/bend2_agy/bend2/main.ts)
  2. Phase 205 hosted x86 API (api-base/api.mjs)
  3. Wave 2B Track B 4-pass candidate hosted x86 API (arg 1)
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
TMP_ROOT = ROOT / "selfhost/build/agy/tier2_audit_w2b_b/adv_tmp"

CASES = [
    # ------------------------------------------------------------------
    # 1. AGY-W2B-3: Unique root with shared 0x82 internal child (partial-descent bailout!)
    #    + fuel == 0, 1, < depth, > U32.max (Succ{U32.to_nat(4294967295)})
    #    + duplicate keys, x == 0, x == 4294967295
    # ------------------------------------------------------------------
    (
        "bst_partial_descent_and_fuel_u32max",
        r'''import Base

type BTree is Data:
  BLeaf{}
  BNode{l: BTree, v: U32, r: BTree}

type BF is Data:
  BF{v: U32, other: BTree, left: Bool}

def bst.pick(l: BTree, v: U32, r: BTree, path: List<&2, BF>, go_left: Bool) -> BTree & List<&2, BF>:
  match go_left:
    case True{}: (l, Con{BF{v, r, True{}}, path})
    case False{}: (r, Con{BF{v, l, False{}}, path})

def bst.down(fuel: Nat, +x: U32, st: BTree & List<&2, BF>) -> BTree & List<&2, BF>:
  match fuel:
    case 0n: st
    case 1n+f:
      (t, path) = st
      match t:
        case BLeaf{}: (BLeaf{}, path)
        case BNode{l, +v, r}: bst.down(f, x, bst.pick(l, v, r, path, U32.is_lt(x, v)))

def bst.up(path: List<&2, BF>, acc: BTree) -> BTree:
  match path:
    case Nil{}: acc
    case Con{BF{v, other, left}, rest}:
      match left:
        case True{}: bst.up(rest, BNode{acc, v, other})
        case False{}: bst.up(rest, BNode{other, v, acc})

def bst.fin(x: U32, st: BTree & List<&2, BF>) -> BTree:
  (t, path) = st
  match t:
    case BLeaf{}: bst.up(path, BNode{BLeaf{}, x, BLeaf{}})
    case BNode{l, v, r}: bst.up(path, BNode{l, v, r})

def bst.insert(fuel: Nat, +x: U32, t: BTree) -> BTree:
  bst.fin(x, bst.down(fuel, x, (t, Nil{})))

def thash(t: BTree) -> U32:
  match t:
    case BLeaf{}: 17
    case BNode{l, v, r}:
      U32.xor(U32.add(U32.mul(thash(l), 131), v), U32.mul(thash(r), 313))

def main() -> IO(Unit):
  # 1. Shared 0x82 internal node 2 levels down inside a unique 0x02 root!
  +sh : BTree = BNode{BNode{BLeaf{}, 10, BLeaf{}}, 20, BNode{BLeaf{}, 30, BLeaf{}}}
  root1 : BTree = BNode{BNode{sh, 40, BLeaf{}}, 50, BNode{BLeaf{}, 60, BLeaf{}}}
  # Inserting 15 descends unique 50 -> unique 40 -> shared 20 (bails out here!)
  out1 = bst.insert(10n, 15, root1)
  # sh MUST be completely unmodified!
  h_sh = thash(sh)
  h_out1 = thash(out1)

  # 2. fuel > U32.max (Succ{U32.to_nat(4294967295)}) + duplicate key + 0 + U32.max
  +big_fuel : Nat = Succ{U32.to_nat(4294967295)}
  t2 = bst.insert(big_fuel, 4294967295, bst.insert(big_fuel, 0, bst.insert(big_fuel, 50, bst.insert(big_fuel, 50, BLeaf{}))))
  # fuel == 0 on Node (unchanged) and fuel == 0 on Leaf (inserts!)
  t3 = bst.insert(0n, 99, t2)
  t4 = bst.insert(0n, 77, BLeaf{})
  # fuel == 1 on depth-2 tree (stops before Leaf -> unchanged)
  t5 = bst.insert(1n, 0, t3)
  IO.print(U32.show(h_sh) ++ " " ++ U32.show(h_out1) ++ " " ++ U32.show(thash(t5)) ++ " " ++ U32.show(thash(t4)))
''',
    ),
    # ------------------------------------------------------------------
    # 2. AGY-W2B-3: Near-miss BST variants (is_le, swapped l/r, modified v on rebuild)
    #    All must cleanly decline certification and match upstream bit-for-bit!
    # ------------------------------------------------------------------
    (
        "bst_nearmiss_variants",
        r'''import Base

type BTree is Data:
  BLeaf{}
  BNode{l: BTree, v: U32, r: BTree}

type BF is Data:
  BF{v: U32, other: BTree, left: Bool}

def pick_norm(l: BTree, v: U32, r: BTree, path: List<&2, BF>, go_left: Bool) -> BTree & List<&2, BF>:
  match go_left:
    case True{}: (l, Con{BF{v, r, True{}}, path})
    case False{}: (r, Con{BF{v, l, False{}}, path})

def pick_swap(l: BTree, v: U32, r: BTree, path: List<&2, BF>, go_left: Bool) -> BTree & List<&2, BF>:
  match go_left:
    case True{}: (r, Con{BF{v, l, False{}}, path})
    case False{}: (l, Con{BF{v, r, True{}}, path})

def up_norm(path: List<&2, BF>, acc: BTree) -> BTree:
  match path:
    case Nil{}: acc
    case Con{BF{v, other, left}, rest}:
      match left:
        case True{}: up_norm(rest, BNode{acc, v, other})
        case False{}: up_norm(rest, BNode{other, v, acc})

def up_inc(path: List<&2, BF>, acc: BTree) -> BTree:
  match path:
    case Nil{}: acc
    case Con{BF{v, other, left}, rest}:
      match left:
        case True{}: up_inc(rest, BNode{acc, U32.add(v, 1), other})
        case False{}: up_inc(rest, BNode{other, U32.add(v, 1), acc})

# Variant 1: U32.is_le instead of U32.is_lt
def down_le(fuel: Nat, +x: U32, st: BTree & List<&2, BF>) -> BTree & List<&2, BF>:
  match fuel:
    case 0n: st
    case 1n+f:
      (t, path) = st
      match t:
        case BLeaf{}: (BLeaf{}, path)
        case BNode{l, +v, r}: down_le(f, x, pick_norm(l, v, r, path, U32.is_le(x, v)))

def fin_norm(x: U32, st: BTree & List<&2, BF>) -> BTree:
  (t, path) = st
  match t:
    case BLeaf{}: up_norm(path, BNode{BLeaf{}, x, BLeaf{}})
    case BNode{l, v, r}: up_norm(path, BNode{l, v, r})

def ins_le(fuel: Nat, +x: U32, t: BTree) -> BTree:
  fin_norm(x, down_le(fuel, x, (t, Nil{})))

# Variant 2: swapped l/r
def down_swap(fuel: Nat, +x: U32, st: BTree & List<&2, BF>) -> BTree & List<&2, BF>:
  match fuel:
    case 0n: st
    case 1n+f:
      (t, path) = st
      match t:
        case BLeaf{}: (BLeaf{}, path)
        case BNode{l, +v, r}: down_swap(f, x, pick_swap(l, v, r, path, U32.is_lt(x, v)))

def ins_swap(fuel: Nat, +x: U32, t: BTree) -> BTree:
  fin_norm(x, down_swap(fuel, x, (t, Nil{})))

# Variant 3: modifies v in up_inc
def down_norm(fuel: Nat, +x: U32, st: BTree & List<&2, BF>) -> BTree & List<&2, BF>:
  match fuel:
    case 0n: st
    case 1n+f:
      (t, path) = st
      match t:
        case BLeaf{}: (BLeaf{}, path)
        case BNode{l, +v, r}: down_norm(f, x, pick_norm(l, v, r, path, U32.is_lt(x, v)))

def fin_inc(x: U32, st: BTree & List<&2, BF>) -> BTree:
  (t, path) = st
  match t:
    case BLeaf{}: up_inc(path, BNode{BLeaf{}, x, BLeaf{}})
    case BNode{l, v, r}: up_inc(path, BNode{l, v, r})

def ins_inc(fuel: Nat, +x: U32, t: BTree) -> BTree:
  fin_inc(x, down_norm(fuel, x, (t, Nil{})))

def thash(t: BTree) -> U32:
  match t:
    case BLeaf{}: 19
    case BNode{l, v, r}:
      U32.xor(U32.add(U32.mul(thash(l), 137), v), U32.mul(thash(r), 317))

def main() -> IO(Unit):
  t1 = ins_le(8n, 10, ins_le(8n, 10, ins_le(8n, 5, ins_le(8n, 10, BLeaf{}))))
  t2 = ins_swap(8n, 3, ins_swap(8n, 15, ins_swap(8n, 10, BLeaf{})))
  t3 = ins_inc(8n, 3, ins_inc(8n, 15, ins_inc(8n, 10, BLeaf{})))
  IO.print(U32.show(thash(t1)) ++ " " ++ U32.show(thash(t2)) ++ " " ++ U32.show(thash(t3)))
''',
    ),
    # ------------------------------------------------------------------
    # 3. AGY-W2B-4: Shared 0x82 children inside unique root, Node{sub, sub} aliasing,
    #    static tree, exact d == 0, 64, 65, and d > U32.max (Succ{U32.to_nat(4294967295)}),
    #    plus Leaf at d > 0
    # ------------------------------------------------------------------
    (
        "flow_shared_children_and_depth_edges",
        r'''import Base

type Tree is Data:
  Leaf{v: U32}
  Node{l: Tree, r: Tree}

def cmp_swap(a: U32, b: U32, s: Bool, cond: Bool) -> Tree:
  match cond:
    case True{}: Node{Leaf{b}, Leaf{a}}
    case False{}: Node{Leaf{a}, Leaf{b}}

def swap_flag(a: U32, b: U32, s: Bool) -> Bool:
  match s:
    case True{}: U32.is_gt(a, b)
    case False{}: U32.is_lt(a, b)

def join_warp(wa: Tree, wb: Tree) -> Tree:
  match wa wb:
    case Node{aal, aar} Node{bbl, bbr}:
      Node{Node{aal, bbl}, Node{aar, bbr}}
    case _ _: Leaf{0}

def warp(a: Tree, b: Tree, +s: Bool) -> Tree:
  match a b:
    case Leaf{+x} Leaf{+y}: cmp_swap(x, y, s, swap_flag(x, y, s))
    case Node{al, ar} Node{bl, br}:
      wa wb = warp(al, bl, s) warp(ar, br, s)
      join_warp(wa, wb)
    case _ _: Leaf{0}

def wn(t: Tree, +s: Bool) -> Tree:
  match t:
    case Leaf{v}: Leaf{v}
    case Node{a, b}: warp(a, b, s)

def flow(+d: Nat, +s: Bool, w: Tree) -> Tree:
  match d:
    case 0n:
      match w:
        case Leaf{v}: Leaf{v}
        case Node{a, b}: Node{a, b}
    case 1n+p:
      match w:
        case Leaf{v}: Leaf{v}
        case Node{wa, wb}:
          fa fb = flow(p, s, wn(wa, s)) flow(p, s, wn(wb, s))
          Node{fa, fb}

def static_tree() -> Tree:
  Node{Node{Leaf{40}, Leaf{10}}, Node{Leaf{30}, Leaf{20}}}

def thash(t: Tree) -> U32:
  match t:
    case Leaf{v}: U32.add(v, 3)
    case Node{l, r}: U32.xor(U32.mul(thash(l), 131), U32.add(thash(r), 17))

def main() -> IO(Unit):
  # 1. Unique root with BOTH children pointing to the SAME shared 0x82 subtree!
  +sub : Tree = Node{Node{Leaf{9}, Leaf{2}}, Node{Leaf{7}, Leaf{4}}}
  uniq_parent : Tree = Node{sub, sub}
  r1 = thash(flow(2n, True{}, uniq_parent))
  # sub MUST be intact!
  r_sub = thash(sub)

  # 2. Static tree (loc < HEAP_OFF)
  r2 = U32.add(thash(flow(2n, True{}, static_tree())), thash(flow(2n, False{}, static_tree())))

  # 3. Exact boundaries: d == 0, d == 64 (fast path max), d == 65 (slow bailout), d > U32.max, Leaf at d > 0
  +t_base : Tree = Node{Node{Leaf{8}, Leaf{1}}, Node{Leaf{5}, Leaf{3}}}
  r3 = thash(flow(0n, True{}, t_base))
  r4 = thash(flow(64n, True{}, t_base))
  r5 = thash(flow(65n, True{}, t_base))
  big_d : Nat = Succ{U32.to_nat(4294967295)}
  r6 = thash(flow(big_d, False{}, t_base))
  r7 = thash(flow(64n, True{}, Leaf{42}))
  IO.print(U32.show(r1) ++ " " ++ U32.show(r_sub) ++ " " ++ U32.show(r2) ++ " " ++ U32.show(r3) ++ " " ++ U32.show(r4) ++ " " ++ U32.show(r5) ++ " " ++ U32.show(r6) ++ " " ++ U32.show(r7))
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
        print(f"  w2b_b    : {cand}", flush=True)
        if not ok:
            failures.append((name, up, p205, cand))
        src.unlink(missing_ok=True)
    if failures:
        print(f"\nTIER-2 ADVERSARIAL AUDIT FAILED ({len(failures)}/{len(CASES)} failures)!")
        sys.exit(1)
    print(f"\nALL {len(CASES)} TIER-2 ADVERSARIAL DIFFERENTIAL TESTS PASSED!")


if __name__ == "__main__":
    main()
