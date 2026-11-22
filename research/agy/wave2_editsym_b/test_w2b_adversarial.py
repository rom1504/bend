#!/usr/bin/env python3
"""Adversarial & boundary differential tests for AGY-W2B-F32LOOP and AGY-W2B-DEADARR
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

F32LOOP_TEST = r'''import Base

def rec_logistic(n: Nat, +x: F32, h: U32) -> U32:
  match n:
    case 0n: h
    case 1n+p:
      +y = F32.mul(F32.mul(3.75, x), F32.sub(1.0, x))
      rec_logistic(p, y, U32.xor(U32.mul(h, 16777619), F32.to_u32(F32.mul(y, 1000000.0))))

# Non-commutative F32.sub/div + nested U32.sub RHS + huge/negative/NaN floats
def rec_edge(n: Nat, +x: F32, h: U32) -> U32:
  match n:
    case 0n: h
    case 1n+p:
      +y = F32.sub(F32.mul(x, 2.5), 1.25)
      +u = F32.to_u32(y)
      rec_edge(p, y, U32.sub(U32.add(h, 100), U32.xor(u, 7)))

def main() -> IO(Unit):
  # 1. n = 0 (must return h unchanged)
  r1 = rec_logistic(0n, 0.5, 123456789)
  # 2. normal logistic recurrence
  r2 = rec_logistic(64n, 0.37, 42)
  # 3. negative x -> negative y -> F32.to_u32 must return 0
  r3 = rec_edge(10n, F32.sub(0.0, 2.0), 999)
  # 4. large float >= 2^32 (1e20) -> F32.to_u32 must return 0
  r4 = rec_edge(5n, 100000000000000000000.0, 777)
  # 5. NaN (0.0 / 0.0) -> F32.to_u32 must return 0
  r5 = rec_edge(5n, F32.div(0.0, 0.0), 555)
  # 6. +Inf (1.0 / 0.0) -> F32.to_u32 must return 0
  r6 = rec_edge(5n, F32.div(1.0, 0.0), 333)
  # 7. float near 2^32 - 256 (valid unsigned u32 > 2^31!)
  r7 = rec_edge(1n, 1717986816.0, 111)
  IO.print(U32.show(r1) ++ " " ++ U32.show(r2) ++ " " ++ U32.show(r3) ++ " " ++ U32.show(r4) ++ " " ++ U32.show(r5) ++ " " ++ U32.show(r6) ++ " " ++ U32.show(r7))
'''

DEADARR_TEST = r'''import Base

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
    case 1n+q: fold.loop(q, U32.inc(i), fold.cell(i, st))

def fold.finish(r: Array<U32> & U32) -> U32:
  (a, acc) = r
  acc

def run128(+n: U32, seed: U32) -> U32:
  fold.finish(fold.loop(U32.to_nat(n), 0, ([seed : U32*128n], 0)))

def run128_off(+n: U32, seed: U32) -> U32:
  fold.finish(fold.loop(U32.to_nat(n), 4294967290, ([seed : U32*128n], 4294967290)))

def run4(+n: U32, seed: U32) -> U32:
  fold.finish(fold.loop(U32.to_nat(n), 3, ([seed : U32*4n], 19)))

def main() -> IO(Unit):
  # n = 0, 1, 127, 128 (closed form), 129, 300 (stack scan4)
  a0 = run128(0, 17)
  a1 = run128(1, 4294967295)
  a2 = run128(127, 1234567)
  a3 = run128(128, 4294967295)
  a4 = run128(129, 17)
  a5 = run128(300, 99)
  # non-zero wrapping i0 & acc0
  b0 = run128_off(128, 4294967295)
  b1 = run128_off(129, 4294967295)
  # tiny size K=4 around boundary
  c0 = run4(0, 7)
  c1 = run4(4, 7)
  c2 = run4(5, 7)
  c3 = run4(25, 7)
  IO.print(U32.show(a0) ++ " " ++ U32.show(a1) ++ " " ++ U32.show(a2) ++ " " ++ U32.show(a3) ++ " " ++
           U32.show(a4) ++ " " ++ U32.show(a5) ++ " " ++ U32.show(b0) ++ " " ++ U32.show(b1) ++ " " ++
           U32.show(c0) ++ " " ++ U32.show(c1) ++ " " ++ U32.show(c2) ++ " " ++ U32.show(c3))
'''

def run_test(api_path: Path, name: str, code: str):
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        src = td / f"{name}.bend"
        obj = td / f"{name}.o"
        exe = td / name
        src.write_text(code)

        up = subprocess.run([BUN, str(ROOT / "bend2/main.ts"), str(src)],
                            capture_output=True, text=True, check=True)
        exp = up.stdout.strip()

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
    run_test(api_path, "f32loop_adversarial", F32LOOP_TEST)
    run_test(api_path, "deadarr_adversarial", DEADARR_TEST)
    print("ALL WAVE 2B ADVERSARIAL DIFFERENTIAL TESTS PASSED!")

if __name__ == "__main__":
    main()
