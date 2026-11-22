#!/usr/bin/env python3
"""Adversarial correctness & observer-safety tests for Wave 4 W4-2 (p113a/p117v array fast-path).

Verifies exact stdout equality against upstream `bun bend2/main.ts` AND zero
`OBSERVER_VIOLATION`s under `normal`, `cap-no8`, and `all-hot` modes across:
  1. shared_fork_loop: Array.fork + Array.join + p117v loop (get, set, swap, size)
  2. nested_fork_oob: multi-level Array.fork + out-of-bounds index wrapping (0xffffffff, size+k)
  3. clone_isolation: Array.clone on an RFC-wrapped TAG_BUF vs mutating original
  4. nonscalar_array: Array<List<U32>> (scalar=False -> TAG_ARR fallback stays 100% sound)
  5. mixed_ctor_array: Arrays stored inside ADTs with observer_gate_hook (normal/cap-no8/all-hot)
"""
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
BATCH_EMIT = ROOT / "research/agy/wave3_fuzz/batch_emit.mjs"
HOOK_C = ROOT / "research/agy/wave3_fuzz/observer_gate_hook.c"
API = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "selfhost/build/agy/wave4_array/api.mjs"
RT = Path(sys.argv[2]) if len(sys.argv) > 2 else ROOT / "selfhost/build/agy/unified/runtime-agy.o"
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]

CASES = {
    "shared_fork_loop": """import Base

def fill_range(n: Nat, +at: U32, +val: U32, a: Array<U32>) -> Array<U32>:
  match n:
    case 0n: a
    case 1n+p: fill_range(p, U32.inc(at), U32.add(val, 7), a[at] <- val)

def sum_range(n: Nat, +at: U32, +acc: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  match n r:
    case 0n Tuple{a, v}: (a, U32.add(U32.mul(acc, 31), v))
    case 1n+p Tuple{a, v}: sum_range(p, U32.inc(at), U32.add(U32.mul(acc, 31), v), a[U32.inc(at)])

def after_sum(+sw: U32, +sz: U32, r: Array<U32> & U32) -> U32:
  (a, s) = r
  U32.xor(s, U32.add(sw, sz))

def after_size(+sw: U32, r: Array<U32> & U32) -> U32:
  (a, sz) = r
  after_sum(sw, sz, sum_range(63n, 0, 0, a[0]))

def after_swap(r: Array<U32> & U32) -> U32:
  (a, old) = r
  after_size(U32.xor(old, 999), Array.size(U32, a))

def after_fork(p: Array<U32> & Array<U32>) -> U32:
  (a1, a2) = p
  a3 = Array.join(U32, fill_range(32n, 0, 11, a1), fill_range(32n, 32, 500, a2))
  after_swap(Array.swap(U32, a3, 17, 999))

def main() -> IO(Unit):
  IO.print(U32.show(after_fork(Array.fork(U32, Array.new(U32, 6n, 3)))))
""",
    "nested_fork_oob": """import Base

def write_oob(n: Nat, +i: U32, a: Array<U32>) -> Array<U32>:
  match n:
    case 0n: a
    case 1n+p: write_oob(p, U32.add(i, 19), a[i] <- U32.xor(i, 4294967295))

def read_oob(n: Nat, +i: U32, +acc: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  match n r:
    case 0n Tuple{a, v}: (a, U32.xor(U32.mul(acc, 16777619), v))
    case 1n+p Tuple{a, v}: read_oob(p, U32.add(i, 13), U32.xor(U32.mul(acc, 16777619), v), a[U32.add(i, 13)])

def fin_read(r: Array<U32> & U32) -> U32:
  (z, h) = r
  h

def after_y(x3: Array<U32>, r: Array<U32> & U32) -> U32:
  (y1, h1) = r
  z = Array.join(U32, x3, y1)
  fin_read(read_oob(15n, 0, h1, z[0]))

def after_inner(y: Array<U32>, p: Array<U32> & Array<U32>) -> U32:
  (x1, x2) = p
  x3 = Array.join(U32, write_oob(20n, 4294967290, x1), x2[4294967295] <- 777)
  after_y(x3, read_oob(31n, 1000, 1, y[1000]))

def after_outer(p: Array<U32> & Array<U32>) -> U32:
  (x, y) = p
  after_inner(y, Array.fork(U32, x))

def main() -> IO(Unit):
  IO.print(U32.show(after_outer(Array.fork(U32, Array.new(U32, 4n, 5)))))
""",
    "clone_isolation": """import Base

def sum_at(r: Array<U32> & U32) -> U32:
  (a, v) = r
  v

def after_clone(a2: Array<U32>, p: Array<U32> & Array<U32>) -> U32:
  (a1b, c) = p
  c2 = c[2] <- 999
  a3 = Array.join(U32, a1b, a2)
  U32.add(U32.mul(sum_at(a3[2]), 1000), sum_at(c2[2]))

def after_fork(p: Array<U32> & Array<U32>) -> U32:
  (a1, a2) = p
  after_clone(a2, Array.clone(U32, a1[2] <- 42))

def main() -> IO(Unit):
  IO.print(U32.show(after_fork(Array.fork(U32, Array.new(U32, 3n, 10)))))
""",
    "nonscalar_array": """import Base

def list_sum(xs: List<&2, U32>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case Con{h, t}: list_sum(t, U32.add(acc, h))

def step2(+s1: U32, r: Array<List<&2, U32>> & List<&2, U32>) -> U32:
  (a, xs) = r
  U32.add(s1, list_sum(xs, 0))

def step1(r: Array<List<&2, U32>> & List<&2, U32>) -> U32:
  (a, xs) = r
  step2(list_sum(xs, 0), Array.get(List<&2, U32>, a, 1))

def main() -> IO(Unit):
  a = Array.new(List<&2, U32>, 3n, Con{1, Con{2, Nil{}}})
  a2 = Array.set(List<&2, U32>, a, 5, Con{10, Con{20, Con{30, Nil{}}}})
  IO.print(U32.show(step1(Array.get(List<&2, U32>, a2, 5))))
""",
    "mixed_ctor_array": """import Base

type Box is Type:
  Box{tag: U32, arr: Array<U32>}

def bump_box(b: Box, +i: U32, +v: U32) -> Box:
  match b:
    case Box{t, a}: Box{U32.inc(t), a[i] <- v}

def finish_read(+t: U32, r: Array<U32> & U32) -> U32:
  (a, v) = r
  U32.add(U32.mul(t, 100), v)

def read_box(b: Box, +i: U32) -> U32:
  match b:
    case Box{t, a}: finish_read(t, a[i])

def join_boxes(b1: Box, b2: Box) -> U32:
  match b1 b2:
    case Box{t1, r1} Box{t2, r2}:
      r = Array.join(U32, r1, r2)
      U32.add(read_box(Box{U32.add(t1, t2), r}, 3), 1000)

def after_fork(p: Array<U32> & Array<U32>) -> U32:
  (a1, a2) = p
  join_boxes(bump_box(Box{1, a1}, 3, 55), bump_box(Box{2, a2}, 4, 88))

def main() -> IO(Unit):
  IO.print(U32.show(after_fork(Array.fork(U32, Array.new(U32, 4n, 7)))))
""",
}


def main():
    with tempfile.TemporaryDirectory(prefix="w4_adv_") as td:
        td = Path(td)
        hook_o = td / "hook.o"
        subprocess.run([CC, "-O2", "-I", str(ROOT / "selfhost/src/runtime/qbe"), "-c", str(HOOK_C), "-o", str(hook_o)], check=True)

        jobs = []
        for name, code in CASES.items():
            sp = td / f"{name}.bend"
            sp.write_text(code)
            jobs.append({"id": name, "src": str(sp), "out": str(td / f"{name}.o")})
        mf = td / "mf.json"
        mf.write_text(json.dumps(jobs))

        r_em = subprocess.run(
            [NODE, "--stack-size=65536", str(BATCH_EMIT), str(API), str(mf)],
            capture_output=True, text=True, check=True,
        )
        em_map = {x["id"]: x for x in json.loads(r_em.stdout)}

        passed = 0
        total = 0
        failed = []
        for name in CASES:
            sp = td / f"{name}.bend"
            obj = td / f"{name}.o"
            exe = td / f"{name}.exe"
            assert em_map[name]["ok"], f"emit failed for {name}: {em_map[name]}"
            up = subprocess.run(
                [str(BUN), str(ROOT / "bend2/main.ts"), str(sp)],
                capture_output=True, text=True, check=True,
            ).stdout
            subprocess.run(
                [CC, "-no-pie",
                 "-Wl,--wrap=p111_rt_main",
                 "-Wl,--wrap=p125_rt_take1", "-Wl,--wrap=p125_rt_take2",
                 "-Wl,--wrap=p125_rt_take3", "-Wl,--wrap=p125_rt_take4",
                 str(obj), str(hook_o), str(RT), "-pthread", "-lm", "-o", str(exe)],
                check=True,
            )
            for mode in ("normal", "cap-no8", "all-hot"):
                total += 1
                env = dict(os.environ, OBS_MODE=mode)
                r = subprocess.run([str(exe), *RTS_ARGS], capture_output=True, text=True, env=env, timeout=30)
                ok = (r.returncode == 0 and r.stdout == up and "OBSERVER_VIOLATION" not in r.stderr and r.stderr == "")
                tag = "PASS" if ok else "FAIL"
                print(f"  [{tag}] {name:18s} mode={mode:8s} out={r.stdout.strip()!r} exp={up.strip()!r} err={r.stderr.strip()!r}")
                if ok:
                    passed += 1
                else:
                    failed.append((name, mode, r.returncode, r.stdout, up, r.stderr))

        print(f"\nArray Adversarial + Observer Gate: {passed}/{total} PASS ({len(failed)} failures)")
        if failed:
            sys.exit(1)


if __name__ == "__main__":
    main()
