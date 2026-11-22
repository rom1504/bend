#!/usr/bin/env python3
"""Tier-2 Adversarial & Boundary Differential Test Suite for Track B:
  - AGY-W2B-1 (apply_reuse.py --reuse --take)
  - AGY-W2B-2 (apply_p114h_mp.py)

Requires bit-exact stdout across:
  1. Upstream Bend (bun /home/ai/bend2_agy/bend2/main.ts)
  2. Phase 205 hosted x86 API (api-base/api.mjs)
  3. Track B candidate hosted x86 API (arg 1)
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
TMP_ROOT = ROOT / "selfhost/build/agy/tier2_audit_b/adv_tmp"

CASES = [
    # ------------------------------------------------------------------
    # 1. AGY-W2B-2: Deep mutual recursion between two self-recursive p114r_ workers!
    #    Pass 1 admits BOTH ping and pong into hready; at emit time ping calls p114r_pong(...,0,0,0)
    #    and pong calls p114r_ping(...,0,0,0), resetting depth=0 on every hop -> C-stack overflow!
    # ------------------------------------------------------------------
    (
        "p114h_mutual_rec_deep",
        r'''import Base

law pong:
  for n: Nat
  U32

@unsafe
def ping(n: Nat) -> U32:
  match n:
    case 0n: 1
    case 1n+p:
      match p:
        case 0n: U32.add(ping(0n), 2)
        case 1n+q: U32.add(pong(q), 3)

@unsafe
def pong(n):
  match n:
    case 0n: 4
    case 1n+p:
      match p:
        case 0n: U32.add(pong(0n), 5)
        case 1n+q: U32.add(ping(q), 6)

def main() -> IO(Unit):
  # 60000 alternating non-tail hops (~30000 ping + ~30000 pong = 60000 C frames if direct-called!)
  # Each p114r_ frame has 2048-byte scratch alloca -> 60000 * 2.1 KiB = ~126 MiB >> 8 MiB ulimit -s!
  IO.print(U32.show(ping(U32.to_nat(60000))))
''',
    ),
    # ------------------------------------------------------------------
    # 2. AGY-W2B-2: Exact 8-arg boundary (state + 8 user args + 3 p114r args = 12 machine args!)
    # ------------------------------------------------------------------
    (
        "p114h_8_args_stack_spill",
        r'''import Base

type T is Data:
  L{v: U32}
  N{l: T, r: T}

def f8(t: T, +a: U32, +b: U32, +c: U32, +d: U32, +e: U32, +f: U32, +g: U32) -> U32:
  match t:
    case L{v}:
      U32.add(v, U32.add(a, U32.add(U32.mul(b, 2), U32.add(U32.mul(c, 3),
        U32.add(U32.mul(d, 5), U32.add(U32.mul(e, 7), U32.add(U32.mul(f, 11), U32.mul(g, 13))))))))
    case N{l, r}:
      U32.add(f8(l, b, c, d, e, f, g, a), f8(r, g, f, e, d, c, b, a))

def wrap8(t: T, +a: U32, +b: U32, +c: U32, +d: U32, +e: U32, +f: U32, +g: U32) -> U32:
  U32.xor(f8(t, a, b, c, d, e, f, g), 12345)

def main() -> IO(Unit):
  t : T = N{N{L{1}, L{2}}, N{L{3}, N{L{4}, L{5}}}}
  IO.print(U32.show(wrap8(t, 1, 2, 3, 4, 5, 6, 7)))
''',
    ),
    # ------------------------------------------------------------------
    # 3. AGY-W2B-2: Closures / partial applications & erased args mixed with p114r_
    # ------------------------------------------------------------------
    (
        "p114h_closures_and_erased",
        r'''import Base

type T is Data:
  L{v: U32}
  N{l: T, r: T}

def apply_fn(f: U32 -> U32, x: U32) -> U32:
  f(x)

def map_sum(t: T, +k: U32) -> U32:
  match t:
    case L{v}: apply_fn(y => U32.add(y, k), v)
    case N{l, r}: U32.add(map_sum(l, k), map_sum(r, k))

def erased_wrap(-tag: U32, t: T, +k: U32) -> U32:
  U32.add(map_sum(t, k), 10)

def main() -> IO(Unit):
  t : T = N{N{L{10}, L{20}}, L{30}}
  IO.print(U32.show(erased_wrap(999, t, 5)))
''',
    ),
    # ------------------------------------------------------------------
    # 4. AGY-W2B-1: Reuse branch asymmetry, intervening calls, field aliasing,
    #    unique parent with shared 0x82 child, cross-arity class 1 & class 2, cross-class non-fusion
    # ------------------------------------------------------------------
    (
        "reuse_branch_alias_and_mixed",
        r'''import Base

type P1 is Data:
  One{a: U32}
  Two{a: U32, b: U32}

type P2 is Data:
  Three{a: U32, b: U32, c: U32}
  Four{a: U32, b: U32, c: U32, d: U32}

type Tree is Data:
  Leaf{v: U32}
  Node{k: U32, l: Tree, r: Tree}

# Class 1: One <-> Two with asymmetric branch + field permutation
def step1(p: P1, flag: U32) -> P1:
  match p:
    case One{+a}: Two{a, U32.add(a, 7)}
    case Two{a, b}:
      match flag:
        case 0: One{U32.add(a, b)}
        case _: Two{b, U32.sub(a, 1)}

# Cross-class: Two (class 1) -> Three (class 2) -> Two (class 1) must NOT mis-reuse!
def cross_class(p: P1) -> P2:
  match p:
    case One{a}: Three{a, 1, 2}
    case Two{+a, +b}: Three{b, a, U32.add(a, b)}

def back_class(q: P2) -> P1:
  match q:
    case Three{a, b, c}: Two{U32.add(a, c), b}
    case Four{a, b, c, d}: Two{U32.add(a, b), U32.add(c, d)}

# Unique parent containing RFC-shared child: reusing parent must NOT corrupt shared child!
def bump_root(t: Tree) -> Tree:
  match t:
    case Leaf{v}: Leaf{U32.add(v, 1)}
    case Node{k, l, r}: Node{U32.add(k, 100), r, l}

def tsum(t: Tree) -> U32:
  match t:
    case Leaf{v}: v
    case Node{k, l, r}: U32.add(k, U32.add(tsum(l), tsum(r)))

def loop1(+n: Nat, p: P1) -> U32:
  match n:
    case 0n:
      match p:
        case One{a}: a
        case Two{a, b}: U32.add(U32.mul(a, 13), b)
    case 1n+q:
      p2 = back_class(cross_class(step1(p, U32.mod(U32.from_nat(q), 3))))
      loop1(q, p2)

def main() -> IO(Unit):
  r1 = loop1(30n, Two{5, 9})
  +shared_child : Tree = Node{7, Leaf{11}, Leaf{13}}
  parent : Tree = Node{1, shared_child, Leaf{2}}
  bumped = bump_root(parent)
  r2 = U32.add(tsum(bumped), U32.mul(tsum(shared_child), 1000))
  IO.print(U32.show(r1) ++ " " ++ U32.show(r2))
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
        print(f"  track_b  : {cand}", flush=True)
        if not ok:
            failures.append((name, up, p205, cand))
        src.unlink(missing_ok=True)
    if failures:
        print(f"\nTIER-2 ADVERSARIAL AUDIT FAILED ({len(failures)}/{len(CASES)} failures)!")
        sys.exit(1)
    print(f"\nALL {len(CASES)} TIER-2 ADVERSARIAL DIFFERENTIAL TESTS PASSED!")


if __name__ == "__main__":
    main()
