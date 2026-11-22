#!/usr/bin/env python3
"""Pass-specific adversarial differential tests vs upstream bend2/main.ts
for Wave 3 Track S2 (C1 special-ctor inlining, C2 borrow_guard + 64-bit rfc peek,
C3 early-exit string_eq, plus runtime-opt-w3.o)."""
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
UPSTREAM = ROOT / "bend2/main.ts"
EMIT_OBJ = ROOT / "research/agy/emit_obj.mjs"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"

API = ROOT / "selfhost/build/agy/wave3_sc_hot/api.mjs"
RT = ROOT / "selfhost/build/agy/wave3_sc_hot/runtime-opt-w3.o"

TESTS = {
    "c1_special_ctors_bool_nat_chr": """
import Base

def b_to_u(b: Bool) -> U32:
  match b:
    case False{}: 0
    case True{}: 1

def check_zero(n: Nat) -> U32:
  match n:
    case 0n: 100
    case 1n+p: U32.add(1, check_zero(p))

def make_flags(x: U32) -> U32:
  a = b_to_u(False{})
  b = b_to_u(True{})
  c = check_zero(0n)
  d = check_zero(3n)
  e = Char.to_u32('Z')
  U32.add(U32.mul(a, 10000), U32.add(U32.mul(b, 1000), U32.add(c, U32.add(d, U32.add(e, x)))))

def main() -> IO(Unit):
  IO.print(U32.show(make_flags(7)))
""",
    "c2_borrowed_rfc_and_unsealed_reads": """
import Base

type Big8 is Data:
  Big8{+a: String, +b: String, +c: U32, +d: U32, +e: U32, +f: U32, +g: U32, +h: U32}
  Small1{+x: U32}
  Empty0{}

@unsafe
def str_eq_go(same: Bool, a: String, b: String) -> Bool:
  match same:
    case False{}: False{}
    case True{}:
      match a b:
        case SNil{} SNil{}: True{}
        case SNil{} SCon{h, t}: False{}
        case SCon{h, t} SNil{}: False{}
        case SCon{h1, t1} SCon{h2, t2}:
          str_eq_go(Char.is_eq(h1, h2), t1, t2)

def finish(r: Bool, a: String, b: String) -> Bool:
  r

def str_eq(+a: String, +b: String) -> Bool:
  finish(str_eq_go(True{}, a, b), a, b)

def tag_check(x: Big8, +k: String) -> U32:
  match x:
    case Big8{a, b, c, d, e, f, g, h}:
      r1 = str_eq(a, k)
      r2 = str_eq(b, k)
      U32.add(Bool.to_u32(r1), U32.add(U32.mul(Bool.to_u32(r2), 10), U32.add(c, h)))
    case Small1{v}: U32.add(100, v)
    case Empty0{}: 999

def run(+s1: String, +s2: String, +b: Big8) -> U32:
  # Shared RFC strings & Big8 (used multiple times -> cnt > 1 -> exercises p111_rt_take + span_fade + borrow)
  r1 = tag_check(b, s1)
  r2 = tag_check(b, s2)
  r3 = tag_check(b, "nope")
  r4 = tag_check(Small1{42}, s1)
  r5 = tag_check(Empty0{}, s2)
  r6 = Bool.to_u32(str_eq("", ""))
  r7 = Bool.to_u32(str_eq("", s1))
  r8 = Bool.to_u32(str_eq(s1, ""))
  r9 = Bool.to_u32(str_eq("abcdef", "abcdeg"))
  r10 = Bool.to_u32(str_eq("abcdef", "abcdef"))
  U32.add(r1, U32.add(r2, U32.add(r3, U32.add(r4, U32.add(r5, U32.add(r6, U32.add(r7, U32.add(r8, U32.add(r9, r10)))))))))

def main() -> IO(Unit):
  +s1 : String = "alpha_beta_gamma"
  +s2 : String = "delta_epsilon"
  +b : Big8 = Big8{s1, s2, 1, 2, 3, 4, 5, 6}
  IO.print(U32.show(run(s1, s2, b)))
""",
    "c3_deep_list_and_tree_drop_shared": """
import Base

type Tree is Data:
  Leaf{v: U32}
  Node{l: Tree, r: Tree}

def mk_tree(+n: Nat, +base: U32) -> Tree:
  match n:
    case 0n: Leaf{base}
    case 1n+p: Node{mk_tree(p, U32.mul(base, 2)), mk_tree(p, U32.add(U32.mul(base, 2), 1))}

def sum_tree(t: Tree) -> U32:
  match t:
    case Leaf{v}: v
    case Node{l, r}: U32.add(sum_tree(l), sum_tree(r))

def mk_list(n: Nat, +s: String) -> List<&2, String>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{s, mk_list(p, s)}

def drop_and_sum(+t: Tree, +xs: List<&2, String>) -> U32:
  # Forces shared RFC drop on both binary tree and string list, plus unshared drop
  a = sum_tree(t)
  b = sum_tree(t)
  U32.add(a, b)

def main() -> IO(Unit):
  +t : Tree = mk_tree(8n, 1)
  +xs : List<&2, String> = mk_list(64n, "hello_world_long_string_1234567890")
  IO.print(U32.show(drop_and_sum(t, xs)))
""",
}


def main():
    failed = []
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        for name, code in TESTS.items():
            src = td / f"{name}.bend"
            src.write_text(code)
            up = subprocess.run([str(BUN), str(UPSTREAM), str(src)], capture_output=True, text=True, timeout=30)
            if up.returncode != 0:
                print(f"[FAIL] {name}: upstream failed: {up.stderr}")
                failed.append(name)
                continue
            obj = td / f"{name}.o"
            exe = td / f"{name}.bin"
            c1 = subprocess.run([str(BUN), str(EMIT_OBJ), str(API), str(src), str(obj)], capture_output=True, text=True, timeout=60)
            if c1.returncode != 0:
                print(f"[FAIL] {name}: emit_obj failed: {c1.stderr}")
                failed.append(name)
                continue
            c2 = subprocess.run([CC, "-O2", "-no-pie", str(obj), str(RT), "-lm", "-pthread", "-o", str(exe)], capture_output=True, text=True)
            if c2.returncode != 0:
                print(f"[FAIL] {name}: link failed: {c2.stderr}")
                failed.append(name)
                continue
            ev = subprocess.run([str(exe)], capture_output=True, text=True, timeout=30)
            if ev.returncode != 0 or ev.stdout != up.stdout:
                print(f"[FAIL] {name}: mismatch upstream={up.stdout!r} got={ev.stdout!r} rc={ev.returncode}")
                failed.append(name)
            else:
                print(f"[PASS] {name}: {ev.stdout.strip()!r}")
    if failed:
        sys.exit(1)
    print(f"ALL {len(TESTS)}/{len(TESTS)} ADVERSARIAL TESTS PASSED!")


if __name__ == "__main__":
    main()
