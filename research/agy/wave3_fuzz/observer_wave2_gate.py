#!/usr/bin/env python3
"""Track Q1 — Live-Metadata Observer Gate for Wave 2 Fast Paths.

1. Runs the 44+2 `abi-contract.c` + `observer.c` (`owner-hot` / `owner-cap`) probe
   against `unified/runtime-agy.o`.
2. Compiles targeted Wave 2 fast-path probes (`Map.set`, `Map.del`, `Map.get`,
   `BST Zipper`, `flow`, `Perceus reuse`, `LISTAPP`, `ARRLIST`) with
   `wave2_unified/api.mjs` + `runtime-agy.o` + `observer_gate_hook.c` and runs
   each under:
     - `normal`
     - `cap-no8` (live `capabilities &= ~8`)
     - `all-hot` (live `cid_hot[*] = 1`)
   Verifying BOTH stdout equality with upstream AND zero `OBSERVER_VIOLATION`s
   (no unsealed heap child left inside a hot or cap-no8 parent constructor)!
"""
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
RUNTIME_DIR = ROOT / "selfhost/src/runtime/qbe"
BATCH_EMIT = ROOT / "research/agy/wave3_fuzz/batch_emit.mjs"
HOOK_C = ROOT / "research/agy/wave3_fuzz/observer_gate_hook.c"
W2_API = ROOT / "selfhost/build/agy/wave2_unified/api.mjs"
AGY_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
WORK_DIR = ROOT / "selfhost/build/agy/wave3_fuzz/obs_tmp"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

DYN_ZERO = """
def dyn_zero_go(n: Nat, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: dyn_zero_go(p, U32.and(acc, 0))

def dyn_zero() -> U32:
  dyn_zero_go(U32.to_nat(300000), 0)
"""

PROBES = {
    "map_set_del_get": f"""import Base
{DYN_ZERO}
def s_hash(s: String, acc: U32) -> U32:
  match s:
    case SNil{{}}: acc
    case SCon{{Chr{{x}}, t}}: s_hash(t, U32.add(U32.mul(acc, 31), x))

def ms_digest(xs: List<&2, Sigma<&2, &2, String, _ => String>>, acc: U32) -> U32:
  match xs:
    case Nil{{}}: acc
    case (k, v) <> t: ms_digest(t, U32.xor(U32.mul(s_hash(k, acc), 16777619), s_hash(v, 31)))

def do_get(r: Map<&2, String> & String) -> Map<&2, String> & U32:
  (m, v) = r
  (m, s_hash(v, 7))

def fin(r: Map<&2, String> & U32) -> U32:
  (m, g) = r
  U32.xor(g, ms_digest(Map.to_list(&2, String, m), 2166136261))

def main() -> IO(Unit):
  +z = dyn_zero()
  m = Map.new(&2, String)
  m = Map.set(&2, String, m, "alpha", String.append("v1_", U32.show(z)))
  m = Map.set(&2, String, m, "beta", String.append("v2_", U32.show(U32.add(z, 1))))
  m = Map.set(&2, String, m, "gamma", String.append("v3_", U32.show(U32.add(z, 2))))
  m = Map.set(&2, String, m, "delta", String.append("v4_", U32.show(U32.add(z, 3))))
  m = Map.del(&2, String, m, "beta")
  m = Map.set(&2, String, m, "alpha", String.append("v1_new_", U32.show(U32.add(z, 4))))
  IO.print(U32.show(fin(do_get(Map.get(String, "MISS", m, "gamma")))))
""",
    "bst_zipper": f"""import Base
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
    case BNode{{l, v, r}}: U32.xor(U32.add(U32.mul(thash(l), 131), v), U32.mul(thash(r), 313))

def main() -> IO(Unit):
  +z = dyn_zero()
  t = bst.insert(10n, U32.add(z, 20), BLeaf{{}})
  t = bst.insert(10n, U32.add(z, 10), t)
  t = bst.insert(10n, U32.add(z, 30), t)
  t = bst.insert(10n, U32.add(z, 5), t)
  t = bst.insert(10n, U32.add(z, 15), t)
  IO.print(U32.show(thash(t)))
""",
    "flow_native": f"""import Base
{DYN_ZERO}
type Tree is Data:
  Leaf{{v: U32}}
  Node{{l: Tree, r: Tree}}

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
    case Node{{aal, aar}} Node{{bbl, bbr}}: Node{{Node{{aal, bbl}}, Node{{aar, bbr}}}}
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
    case 1n+p: Node{{mk_tree(p, U32.add(v, 3)), mk_tree(p, U32.add(v, 7))}}

def thash(t: Tree) -> U32:
  match t:
    case Leaf{{v}}: U32.add(v, 3)
    case Node{{l, r}}: U32.xor(U32.mul(thash(l), 131), U32.add(thash(r), 17))

def main() -> IO(Unit):
  +z = dyn_zero()
  t = mk_tree(3n, U32.add(z, 10))
  IO.print(U32.show(thash(flow(3n, True{{}}, t))))
""",
    "perceus_reuse": f"""import Base
{DYN_ZERO}
type Box2 is Data:
  B2A{{l: Box2, r: Box2}}
  B2B{{l: Box2, r: Box2}}
  B2L{{v: U32}}

def swap_boxes(b: Box2) -> Box2:
  match b:
    case B2L{{v}}: B2L{{U32.add(v, 1)}}
    case B2A{{l, r}}: B2B{{swap_boxes(r), swap_boxes(l)}}
    case B2B{{l, r}}: B2A{{swap_boxes(r), swap_boxes(l)}}

def bhash(b: Box2) -> U32:
  match b:
    case B2L{{v}}: v
    case B2A{{l, r}}: U32.xor(U32.mul(bhash(l), 31), U32.add(bhash(r), 1))
    case B2B{{l, r}}: U32.xor(U32.mul(bhash(l), 37), U32.add(bhash(r), 2))

def main() -> IO(Unit):
  +z = dyn_zero()
  t : Box2 = B2A{{B2B{{B2L{{U32.add(z, 1)}}, B2L{{2}}}}, B2A{{B2L{{3}}, B2L{{4}}}}}}
  IO.print(U32.show(bhash(swap_boxes(swap_boxes(t)))))
""",
    "listapp_arrlist": f"""import Base
{DYN_ZERO}
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

def main() -> IO(Unit):
  +z = dyn_zero()
  l1 = List.append(&2, U32, mk_list(U32.to_nat(U32.add(z, 4)), 10), mk_list(U32.to_nat(U32.add(z, 4)), 20))
  s1 = String.append(String.append("abc", U32.show(z)), "xyz")
  a = [U32.add(z, 7) : U32*8n]
  a = a[3] <- 99
  l2 = Array.to_list(U32, a)
  IO.print(U32.show(U32.xor(sum_list(l1, 1), U32.add(sum_list1(l2, 2), U32.from_nat(String.length(s1))))))
""",
}


def main():
    WORK_DIR.mkdir(parents=True, exist_ok=True)

    # 1. Run runtime ABI + observer.c (44 + 2)
    sys.path.insert(0, str(ROOT / "research/agy/rt"))
    import build_rt
    build_rt.run_abi_probes(WORK_DIR, AGY_RT, "wave2-unified")

    # 2. Compile hook object
    hook_o = WORK_DIR / "observer_gate_hook.o"
    subprocess.run(
        [CC, "-std=gnu11", "-Wall", "-Wextra", "-O2", "-I", str(RUNTIME_DIR),
         "-c", str(HOOK_C), "-o", str(hook_o)],
        check=True,
    )

    # 3. Emit all probe objects in one batch
    jobs = []
    for name, code in PROBES.items():
        sp = WORK_DIR / f"{name}.bend"
        sp.write_text(code)
        jobs.append({"id": name, "src": str(sp), "out": str(WORK_DIR / f"{name}.o")})

    manifest = WORK_DIR / "obs_manifest.json"
    manifest.write_text(json.dumps(jobs))
    r_em = subprocess.run(
        [NODE, "--stack-size=8192", str(BATCH_EMIT), str(W2_API), str(manifest)],
        capture_output=True, text=True, check=True,
    )
    em_map = {x["id"]: x for x in json.loads(r_em.stdout)}

    results = {}
    violations = []
    for name in PROBES:
        sp = WORK_DIR / f"{name}.bend"
        obj = WORK_DIR / f"{name}.o"
        exe = WORK_DIR / f"{name}.exe"
        up = subprocess.run([str(BUN), str(ROOT / "bend2/main.ts"), str(sp)], capture_output=True, text=True, check=True).stdout
        assert em_map[name]["ok"], f"emit failed for {name}: {em_map[name]}"
        subprocess.run(
            [CC, "-no-pie",
             "-Wl,--wrap=p111_rt_main",
             "-Wl,--wrap=p125_rt_take1", "-Wl,--wrap=p125_rt_take2",
             "-Wl,--wrap=p125_rt_take3", "-Wl,--wrap=p125_rt_take4",
             str(obj), str(hook_o), str(AGY_RT), "-pthread", "-lm", "-o", str(exe)],
            check=True,
        )
        mode_res = {}
        for mode in ("normal", "cap-no8", "all-hot"):
            env = dict(os.environ, OBS_MODE=mode)
            r = subprocess.run([str(exe), *RTS_ARGS], capture_output=True, text=True, env=env, timeout=30)
            ok = (r.returncode == 0 and r.stdout == up and "OBSERVER_VIOLATION" not in r.stderr and r.stderr == "")
            mode_res[mode] = {
                "ok": ok,
                "rc": r.returncode,
                "stdout": r.stdout.strip(),
                "expected": up.strip(),
                "stderr": r.stderr.strip(),
            }
            tag = "PASS" if ok else "FAIL"
            print(f"  [{tag}] {name:18s} mode={mode:8s} out={r.stdout.strip()!r} err={r.stderr.strip()!r}", flush=True)
            if not ok:
                violations.append((name, mode, mode_res[mode]))
        results[name] = mode_res
        obj.unlink(missing_ok=True)
        exe.unlink(missing_ok=True)
        sp.unlink(missing_ok=True)

    hook_o.unlink(missing_ok=True)
    manifest.unlink(missing_ok=True)

    out_path = ROOT / "selfhost/build/agy/wave3_fuzz/observer_gate_results.json"
    out_path.write_text(json.dumps({"abi_observer_probe": "44+2 PASS", "probes": results, "violations": len(violations)}, indent=2) + "\n")
    print(f"\nObserver Gate finished: {len(PROBES)*3 - len(violations)}/{len(PROBES)*3} PASS ({len(violations)} violations)")
    sys.exit(0 if not violations else 1)


if __name__ == "__main__":
    main()
