#!/usr/bin/env python3
"""Verify Wave 2B (AGY-W2B-3 BST Zipper + AGY-W2B-4 Native Flow):
7 targeted adversarial/boundary upstream differential tests + 19/19 focused19.
"""
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

BST_CORE = """
type MyTree is Data:
  Empty{}
  Branch{l: MyTree, k: U32, r: MyTree}

type ZStep is Data:
  ZF{k: U32, other: MyTree, left: Bool}

def z_pick(l: MyTree, k: U32, r: MyTree, path: List<&2, ZStep>, z: Bool) -> MyTree & List<&2, ZStep>:
  match z:
    case True{}: (l, ZF{k, r, True{}} <> path)
    case False{}: (r, ZF{k, l, False{}} <> path)

def z_step(+x: U32, st: MyTree & List<&2, ZStep>) -> MyTree & List<&2, ZStep>:
  match st:
    case (Empty{}, path): (Empty{}, path)
    case (Branch{l, v0, r}, path):
      +v = {v0 : U32}
      z_pick(l, v, r, path, U32.is_lt(x, v))

def z_down(fuel: Nat, +x: U32, st: MyTree & List<&2, ZStep>) -> MyTree & List<&2, ZStep>:
  match fuel:
    case 0n: st
    case 1n+f: z_down(f, x, z_step(x, st))

def z_up(path: List<&2, ZStep>, acc: MyTree) -> MyTree:
  match path:
    case Nil{}: acc
    case ZF{k, other, True{}} <> rest: z_up(rest, Branch{acc, k, other})
    case ZF{k, other, False{}} <> rest: z_up(rest, Branch{other, k, acc})

def z_fin(+x: U32, st: MyTree & List<&2, ZStep>) -> MyTree:
  match st:
    case (Empty{}, path): z_up(path, Branch{Empty{}, x, Empty{}})
    case (Branch{l, k, r}, path): z_up(path, Branch{l, k, r})

def z_ins(+fuel: Nat, +x: U32, t: MyTree) -> MyTree:
  z_fin(x, z_down(fuel, x, (t, Nil{})))

def z_fold(t: MyTree, acc: U32) -> U32:
  match t:
    case Empty{}: acc
    case Branch{l, k, r}: z_fold(r, U32.add(U32.mul(z_fold(l, acc), 31), k))
"""

FLOW_CORE = """
type BTree is Data:
  Tip{v: U32}
  Fork{l: BTree, r: BTree}

def wl_go(x: U32, y: U32, t: Bool) -> BTree:
  match t:
    case False{}: Fork{Tip{x}, Tip{y}}
    case True{}: Fork{Tip{y}, Tip{x}}

def wl(+x: U32, +y: U32, s: Bool) -> BTree:
  wl_go(x, y, Bool.xor(s, U32.is_gt(x, y)))

def wz(wa: BTree, wb: BTree) -> BTree:
  match wa wb:
    case Fork{a0, a1} Fork{b0, b1}: Fork{Fork{a0, b0}, Fork{a1, b1}}
    case Fork{a0, a1} Tip{bv}: Tip{0}
    case Tip{av} Fork{b0, b1}: Tip{0}
    case Tip{av} Tip{bv}: Tip{0}

def my_warp(a: BTree, b: BTree, +s: Bool) -> BTree:
  match a b:
    case Tip{av} Tip{bv}: wl(av, bv, s)
    case Tip{av} Fork{ba, bb}: Tip{0}
    case Fork{aa, ab} Tip{bv}: Tip{0}
    case Fork{aa, ab} Fork{ba, bb}:
      wa wb = my_warp(aa, ba, s) my_warp(ab, bb, s)
      wz(wa, wb)

def my_wn(t: BTree, +s: Bool) -> BTree:
  match t:
    case Tip{v}: Tip{v}
    case Fork{a, b}: my_warp(a, b, s)

def my_flow(+d: Nat, +s: Bool, w: BTree) -> BTree:
  match d w:
    case 0n Tip{v}: Tip{v}
    case 0n Fork{wa, wb}: Fork{wa, wb}
    case 1n+p Tip{v}: Tip{v}
    case 1n+p Fork{wa, wb}:
      fa fb = my_flow(p, s, my_wn(wa, s)) my_flow(p, s, my_wn(wb, s))
      Fork{fa, fb}

def t_hash(t: BTree, acc: U32) -> U32:
  match t:
    case Tip{v}: U32.add(U32.mul(acc, 31), v)
    case Fork{a, b}: t_hash(b, t_hash(a, acc))
"""

ADVERSARIAL_TESTS = {
    "bst_zipper_rfc_shared": "import Base\n" + BST_CORE + """
def test_shared(+base: MyTree) -> U32:
  # base is RFC-shared; z_ins MUST bail cleanly and NOT mutate base!
  t1 = z_ins(10n, 3, base)
  t2 = z_ins(10n, 8, base)
  h0 = z_fold(base, 1)
  h1 = z_fold(t1, 1)
  h2 = z_fold(t2, 1)
  U32.xor(U32.mul(h0, 1009), U32.add(h1, U32.mul(h2, 17)))

def main() -> IO(Unit):
  t = z_ins(10n, 5, Empty{})
  t = z_ins(10n, 2, t)
  t = z_ins(10n, 7, t)
  IO.print(U32.show(test_shared(t)))
""",
    "bst_zipper_static_root": "import Base\n" + BST_CORE + """
def static_tree() -> MyTree:
  Branch{Branch{Empty{}, 2, Empty{}}, 5, Branch{Empty{}, 9, Empty{}}}

def loop(n: Nat, +k: U32, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      h = z_fold(z_ins(8n, k, static_tree()), 1)
      loop(p, U32.add(k, 1), U32.add(U32.mul(acc, 13), h))

def main() -> IO(Unit):
  IO.print(U32.show(loop(10n, 1, 0)))
""",
    "bst_zipper_fuel_boundary": "import Base\n" + BST_CORE + """
def main() -> IO(Unit):
  # fuel=0 on Empty MUST insert
  t0 = z_ins(0n, 42, Empty{})
  # fuel=0 on Branch MUST leave unchanged
  t1 = z_ins(0n, 10, t0)
  # fuel=1 on depth-1 inserts
  t2 = z_ins(1n, 10, t1)
  # fuel=1 on depth-2 (going left through 42 -> 10 -> Empty needs fuel=2) leaves unchanged!
  t3 = z_ins(1n, 5, t2)
  # fuel=2 inserts 5!
  t4 = z_ins(2n, 5, t3)
  # duplicate key (42 == 42 goes right) + U32 boundaries 0 and 4294967295
  t5 = z_ins(10n, 42, t4)
  t6 = z_ins(10n, 0, t5)
  t7 = z_ins(10n, 4294967295, t6)
  IO.print(U32.show(z_fold(t7, 7)))
""",
    "flow_rfc_shared": "import Base\n" + FLOW_CORE + """
def test_shared(+t: BTree) -> U32:
  # t is RFC-shared; my_flow MUST NOT mutate t in place!
  a = my_flow(2n, False{}, t)
  b = my_flow(2n, True{}, t)
  U32.xor(t_hash(t, 1), U32.add(U32.mul(t_hash(a, 1), 13), t_hash(b, 1)))

def main() -> IO(Unit):
  t : BTree = Fork{Fork{Tip{9}, Tip{2}}, Fork{Tip{7}, Tip{4}}}
  IO.print(U32.show(test_shared(t)))
""",
    "flow_depth_and_bailout": "import Base\n" + FLOW_CORE + """
def main() -> IO(Unit):
  # d=0 on Leaf & Node, d=5 on Leaf, d=70 (>64 bailout to slow!) on Node
  t1 : BTree = my_flow(0n, False{}, Tip{77})
  t2 : BTree = my_flow(0n, True{}, Fork{Tip{9}, Tip{2}})
  t3 : BTree = my_flow(5n, False{}, Tip{88})
  t4 : BTree = my_flow(70n, False{}, Fork{Fork{Tip{9}, Tip{2}}, Fork{Tip{7}, Tip{4}}})
  h = U32.add(t_hash(t1, 1), U32.add(t_hash(t2, 2), U32.add(t_hash(t3, 3), t_hash(t4, 4))))
  IO.print(U32.show(h))
""",
    "flow_renamed_multi": "import Base\n" + FLOW_CORE + """
def mk(+d: Nat, +x: U32) -> BTree:
  match d:
    case 0n: Tip{x}
    case 1n+p: Fork{mk(p, U32.add(U32.mul(x, 3), 1)), mk(p, U32.add(U32.mul(x, 5), 2))}

def main() -> IO(Unit):
  t = mk(4n, 7)
  r = my_flow(3n, False{}, my_wn(t, False{}))
  IO.print(U32.show(t_hash(r, 11)))
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
        print(f"=== Wave 2B Adversarial Upstream Differential Tests ({len(ADVERSARIAL_TESTS)}) ===")
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
                print(f"  [FAIL] {name}: emit_obj failed: {c1.stderr.strip()[:200]}")
                failed.append(name)
                continue
            c2 = run_cmd([CC, "-O2", "-no-pie", obj, a.rt, "-o", binp, "-lm", "-pthread"])
            if c2.returncode != 0:
                print(f"  [FAIL] {name}: link failed: {c2.stderr.strip()[:200]}")
                failed.append(name)
                continue
            ev = run_cmd([binp])
            if ev.returncode != 0 or ev.stdout != up.stdout:
                print(f"  [FAIL] {name}: mismatch! upstream={up.stdout!r} cand={ev.stdout!r} rc={ev.returncode}")
                failed.append(name)
            else:
                print(f"  [PASS] {name}: {ev.stdout.strip()!r}")

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
                print(f"  [FAIL] {cid}: rc={ev.returncode} stdout={ev.stdout!r} exp={exp['stdout']!r}")
                failed.append(cid)
            else:
                print(f"  [PASS] {cid}")

    total = len(ADVERSARIAL_TESTS) + len(focused)
    print(f"\nSUMMARY: {total - len(failed)} / {total} PASS")
    if failed:
        print("FAILED:", failed)
        sys.exit(1)

if __name__ == "__main__":
    main()
