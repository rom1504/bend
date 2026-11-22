#!/usr/bin/env python3
"""Adversarial & boundary differential tests for Wave 2 Track A passes vs upstream Bend."""
import subprocess, sys, tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EMIT = ROOT / "research/agy/emit_obj.mjs"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"

TESTS = {
    "f32_const_nan_inf_bounds": """import Base

def b2u(b: Bool) -> U32:
  match b:
    case False{}: 0
    case True{}: 1

def cmp4(+a: F32, +b: F32) -> U32:
  c1 = b2u(F32.is_lt(a, b))
  c2 = U32.mul(b2u(F32.is_le(a, b)), 2)
  c3 = U32.mul(b2u(F32.is_gt(a, b)), 4)
  c4 = U32.mul(b2u(F32.is_ge(a, b)), 8)
  U32.add(U32.add(c1, c2), U32.add(c3, c4))

def f32_edges(+z: U32) -> U32:
  +zero = U32.to_f32(z)
  +neg0 = F32.sub(U32.to_f32(0), zero)
  +one = U32.to_f32(1)
  +nan = F32.div(zero, zero)
  +pinf = F32.div(one, zero)
  +ninf = F32.div(F32.sub(zero, one), zero)
  +sqneg = F32.sqrt(F32.sub(zero, one))
  +h1 = cmp4(zero, neg0)
  +h2 = cmp4(nan, one)
  +h3 = cmp4(one, nan)
  +h4 = cmp4(nan, nan)
  +h5 = cmp4(ninf, pinf)
  +h6 = cmp4(pinf, ninf)
  +h7 = cmp4(sqneg, zero)
  +u1 = F32.to_u32(F32.sub(zero, one))
  +u2 = F32.to_u32(neg0)
  +u3 = F32.to_u32(nan)
  +u4 = F32.to_u32(pinf)
  +u5 = F32.to_u32(ninf)
  +u6 = F32.to_u32(U32.to_f32(4294967295))
  +u7 = F32.to_u32(U32.to_f32(16777217))
  +u8 = F32.to_u32(F32.div(U32.to_f32(1000), U32.to_f32(3)))
  +s1 = U32.add(U32.mul(h1, 17), U32.add(U32.mul(h2, 31), U32.add(U32.mul(h3, 47), U32.mul(h4, 61))))
  +s2 = U32.add(U32.mul(h5, 73), U32.add(U32.mul(h6, 89), U32.mul(h7, 101)))
  +s3 = U32.add(U32.add(u1, u2), U32.add(U32.add(u3, u4), U32.add(u5, U32.add(u6, U32.add(u7, u8)))))
  U32.add(U32.add(s1, s2), s3)

def main() -> IO(Unit):
  IO.print(U32.show(f32_edges(0)))
""",
    "xloop_sqrt_slowpath_and_carried": """import Base

def pick_q(b: Bool, y: F32) -> U32:
  match b:
    case True{}: 999
    case False{}: F32.to_u32(F32.mul(y, 100.0))

def loop(n: Nat, +inv1: F32, +inv2: F32, +x: F32, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      +neg_sq = F32.sqrt(F32.sub(U32.to_f32(0), inv1))
      +y = F32.add(F32.mul(x, inv1), inv2)
      +q = pick_q(F32.is_lt(neg_sq, inv2), y)
      loop(p, inv1, inv2, F32.sub(y, F32.mul(0.5, x)), U32.xor(U32.mul(acc, 16777619), q))

def main() -> IO(Unit):
  +r0 = loop(0n, 1.25, 0.5, 2.0, 42)
  +r1 = loop(1n, 1.25, 0.5, 2.0, 42)
  +r2 = loop(25n, 1.25, 0.5, 2.0, 42)
  IO.print(U32.show(U32.add(U32.add(r0, r1), r2)))
""",
    "table_clamp_and_multitable": """import Base

def t1(i: Nat) -> F32:
  match i:
    case 0n: 1.0
    case 1n: 2.0
    case 2n: 3.0
    case 3n: 4.0
    case 4n+k: 5.0

def t2(i: Nat) -> F32:
  match i:
    case 0n: 10.0
    case 1n: 20.0
    case 2n: 30.0
    case 3n: 40.0
    case 4n+k: 50.0

def probe(+n: Nat, +acc: F32) -> F32:
  match n:
    case 0n: acc
    case 1n++k:
      +a = t1(k)
      +b = t2(k)
      +c = t1(Nat.add(k, 100n))
      probe(k, F32.add(acc, F32.add(F32.mul(a, b), c)))

def main() -> IO(Unit):
  IO.print(U32.show(F32.to_u32(probe(12n, 0.0))))
""",
    "qm_divmod_and_asr_bounds": """import Base

def sel.go(x: U32, y: U32, z: Bool) -> U32:
  match z:
    case True{}: x
    case False{}: y

def sel(t: U32, x: U32, y: U32) -> U32:
  sel.go(x, y, U32.is_zero(t))

def asr8(+v: U32) -> U32:
  U32.or(U32.shrn(v, 8n), sel(U32.shrn(v, 31n), 0, 4278190080))

def asr1(+v: U32) -> U32:
  U32.or(U32.shrn(v, 1n), sel(U32.shrn(v, 31n), 0, 2147483648))

def not_asr8(+v: U32) -> U32:
  U32.or(U32.shrn(v, 8n), sel(U32.shrn(v, 31n), 0, 4278190081))

def mix(+v: U32) -> U32:
  +a = asr8(v)
  +b = asr1(v)
  +c = not_asr8(v)
  +d1 = U32.div(v, 80)
  +m1 = U32.mod(v, 80)
  +d2 = U32.div(v, 4096)
  +m2 = U32.mod(v, 4096)
  +d3 = U32.div(v, 97)
  +m3 = U32.mod(v, 97)
  U32.xor(U32.add(a, U32.add(b, c)), U32.add(U32.add(d1, m1), U32.add(U32.add(d2, m2), U32.add(d3, m3))))

def main() -> IO(Unit):
  +h = mix(0)
  +h = U32.xor(U32.mul(h, 16777619), mix(1))
  +h = U32.xor(U32.mul(h, 16777619), mix(79))
  +h = U32.xor(U32.mul(h, 16777619), mix(80))
  +h = U32.xor(U32.mul(h, 16777619), mix(2147483647))
  +h = U32.xor(U32.mul(h, 16777619), mix(2147483648))
  +h = U32.xor(U32.mul(h, 16777619), mix(3735928559))
  +h = U32.xor(U32.mul(h, 16777619), mix(4294967295))
  IO.print(U32.show(h))
""",
}


def main():
    api_path = Path(sys.argv[1])
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        passed = 0
        for name, code in TESTS.items():
            src = td / f"{name}.bend"
            src.write_text(code)
            up = subprocess.run([str(BUN), str(ROOT / "bend2/main.ts"), str(src)], capture_output=True, text=True)
            if up.returncode != 0:
                raise RuntimeError(f"upstream failed on {name}: {up.stderr}")
            expected = up.stdout
            obj = td / f"{name}.o"
            exe = td / name
            em = subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(api_path), str(src), str(obj)], capture_output=True, text=True)
            if em.returncode != 0:
                raise RuntimeError(f"emit failed on {name}: {em.stderr}")
            lk = subprocess.run([CC, "-no-pie", str(obj), str(RT), "-pthread", "-lm", "-o", str(exe)], capture_output=True, text=True)
            if lk.returncode != 0:
                raise RuntimeError(f"link failed on {name}: {lk.stderr}")
            run = subprocess.run([str(exe)], capture_output=True, text=True)
            if run.returncode != 0:
                raise RuntimeError(f"run failed on {name}: {run.stderr}")
            if run.stdout != expected:
                raise AssertionError(f"MISMATCH on {name}: got {run.stdout!r}, expected {expected!r}")
            print(f"PASS {name:35s} stdout={run.stdout.strip()}")
            passed += 1
        print(f"\nALL ADVERSARIAL TESTS PASSED: {passed}/{len(TESTS)}")


if __name__ == "__main__":
    main()
