#!/usr/bin/env python3
"""Adversarial & boundary differential tests for AGY-W2-ROREC and AGY-W2-DPLOOP
against upstream Bend (bun /home/ai/bend2_agy/bend2/main.ts).
"""
import subprocess, sys, tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = "/home/ai/bend2_agy/selfhost/.assets/bin/bun"
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EMIT = ROOT / "research/agy/emit_obj.mjs"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"

ROREC_TEST = r'''import Base

type T is Data:
  TVar{}
  TLit{v: U32}
  TAdd{a: T, b: T}
  TSub{a: T, b: T}
  TMul{a: T, b: T}
  TXor{a: T, b: T}
  TAnd{a: T, b: T}
  TOr{a: T, b: T}

def teval(e: T, +x: U32) -> U32:
  match e:
    case TVar{}: x
    case TLit{v}: v
    case TAdd{a, b}: U32.add(teval(a, x), teval(b, x))
    case TSub{a, b}: U32.sub(teval(a, x), teval(b, x))
    case TMul{a, b}: U32.mul(teval(a, x), teval(b, x))
    case TXor{a, b}: U32.xor(teval(a, x), teval(b, x))
    case TAnd{a, b}: U32.and(teval(a, x), teval(b, x))
    case TOr{a, b}: U32.or(teval(a, x), teval(b, x))

def tsize(e: T) -> U32:
  match e:
    case TVar{}: 1
    case TLit{v}: 1
    case TAdd{a, b}: U32.add(1, U32.add(tsize(a), tsize(b)))
    case TSub{a, b}: U32.add(1, U32.add(tsize(a), tsize(b)))
    case TMul{a, b}: U32.add(1, U32.add(tsize(a), tsize(b)))
    case TXor{a, b}: U32.add(1, U32.add(tsize(a), tsize(b)))
    case TAnd{a, b}: U32.add(1, U32.add(tsize(a), tsize(b)))
    case TOr{a, b}: U32.add(1, U32.add(tsize(a), tsize(b)))

# Build a deep chain exceeding budget=256 to force bailout to slow path
def mk_deep(+n: Nat, acc: T) -> T:
  match n:
    case 0n: acc
    case 1n+p: mk_deep(p, TSub{TAdd{acc, TLit{3}}, TLit{1}})

# Build a diamond-shared DAG (internal nodes also have tag 0x82!)
def mk_dag(+n: Nat, base: T) -> T:
  match n:
    case 0n: base
    case 1n+p:
      +s = mk_dag(p, base)
      TAdd{TSub{s, TLit{7}}, TXor{s, TMul{TVar{}, TLit{5}}}}

# Evaluate shared tree repeatedly to stress refcount decrement + no leaks
def eval_loop(+n: Nat, +e: T, acc: U32) -> U32:
  match n:
    case 0n: U32.add(acc, tsize(e))
    case 1n+p:
      +x = U32.from_nat(p)
      eval_loop(p, e, U32.xor(U32.mul(acc, 1664525), teval(e, x)))

def main() -> IO(Unit):
  # 1. Nullary and inline-U32 leaf roots (shared & unshared)
  +v0 : T = TVar{}
  +l0 : T = TLit{4294967295}
  r1 = U32.add(eval_loop(10n, v0, 0), eval_loop(10n, l0, 0))
  # 2. All 6 ops + non-commutative Sub + U32 overflow/underflow
  +e_ops : T = TOr{TAnd{TSub{TLit{3}, TLit{10}}, TXor{TMul{TLit{65536}, TLit{65536}}, TAdd{TLit{4294967295}, TVar{}}}}, TSub{TVar{}, TLit{100}}}
  r2 = eval_loop(20n, e_ops, 0)
  # 3. Diamond-shared DAG (internal RFC nodes!)
  +dag = mk_dag(6n, TSub{TVar{}, TLit{13}})
  r3 = eval_loop(25n, dag, 0)
  # 4. Deep tree (> 256 depth -> forces bailout to p114r slow path!)
  +deep = mk_deep(300n, TVar{})
  r4 = eval_loop(4n, deep, 0)
  # 5. Unique (unshared, tag 0x02) root
  r5 = teval(TSub{TAdd{TLit{10}, TVar{}}, TLit{25}}, 7)
  IO.print(U32.show(r1) ++ " " ++ U32.show(r2) ++ " " ++ U32.show(r3) ++ " " ++ U32.show(r4) ++ " " ++ U32.show(r5))
'''

DPLOOP_TEST = r'''import Base

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

def fill(+n: Nat, +k: U32, +base: U32, x: Array<U32>) -> Array<U32>:
  match n:
    case 0n: x
    case 1n+q: fill(q, U32.inc(k), base, x[k] <- U32.add(base, U32.mul(k, 3)))

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

def run_case(+n: Nat, +j: U32, +ai: U32, +base: U32) -> U32:
  a = [0 : U32*8n]
  b = fill(8n, 0, base, [0 : U32*8n])
  prev = fill(16n, 0, U32.add(base, 1), [0 : U32*16n])
  cur = fill(16n, 0, U32.add(base, 2), [0 : U32*16n])
  hash_dp(15n, row(n, j, ai, Dp{a, b, prev, cur}))

def run_wrap(+n: Nat, +j: U32, +ai: U32) -> U32:
  # Small 8-slot prev/cur so j+n >= 8 forces wrap-around fallback to slow path!
  a = [0 : U32*8n]
  b = fill(8n, 0, 1, [0 : U32*8n])
  prev = fill(8n, 0, 2, [0 : U32*8n])
  cur = fill(8n, 0, 3, [0 : U32*8n])
  hash_dp(7n, row(n, j, ai, Dp{a, b, prev, cur}))

def main() -> IO(Unit):
  # 1. n = 0 (must still swap prev and cur!)
  t1 = run_case(0n, 0, 1, 0)
  # 2. n = 1 (single cell)
  t2 = run_case(1n, 0, 0, 0)
  # 3. non-zero j (j = 3, n = 5, exact boundary j + n == 8 == b_size!)
  t3 = run_case(5n, 3, 9, 0)
  # 4. full fast path (j = 0, n = 8)
  t4 = run_case(8n, 0, 3, 0)
  # 5. U32 overflow values (0xfffffffe, 0xffffffff)
  t5 = run_case(8n, 0, 4294967294, 4294967290)
  # 6. wrap-around (j = 5, n = 6 on size-8 arrays -> forces slow path!)
  t6 = run_wrap(6n, 5, 4)
  # 7. exact wrap boundary (j = 0, n = 8 on size-8 prev/cur -> j+n == 8 == size -> forces slow path!)
  t7 = run_wrap(8n, 0, 1)
  IO.print(U32.show(t1) ++ " " ++ U32.show(t2) ++ " " ++ U32.show(t3) ++ " " ++ U32.show(t4) ++ " " ++ U32.show(t5) ++ " " ++ U32.show(t6) ++ " " ++ U32.show(t7))
'''

def run_test(api_path: Path, name: str, code: str):
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        src = td / f"{name}.bend"
        obj = td / f"{name}.o"
        exe = td / name
        src.write_text(code)

        # Upstream Bend oracle
        up = subprocess.run([BUN, str(ROOT / "bend2/main.ts"), str(src)],
                            capture_output=True, text=True, check=True)
        exp = up.stdout.strip()

        # Candidate native x86
        subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api_path), str(src), str(obj)],
                       capture_output=True, text=True, check=True)
        subprocess.run([CC, "-no-pie", str(obj), str(RT), "-pthread", "-lm", "-o", str(exe)],
                       capture_output=True, text=True, check=True)
        got = subprocess.run([str(exe)], capture_output=True, text=True, check=True).stdout.strip()
        ok = (got == exp)
        print(f"[{name}] {'PASS' if ok else 'FAIL'}\n  expected: {exp}\n  observed: {got}")
        if not ok:
            sys.exit(1)

def main():
    api_path = Path(sys.argv[1])
    run_test(api_path, "rorec_adversarial", ROREC_TEST)
    run_test(api_path, "dploop_adversarial", DPLOOP_TEST)
    print("ALL ADVERSARIAL DIFFERENTIAL TESTS PASSED!")

if __name__ == "__main__":
    main()
