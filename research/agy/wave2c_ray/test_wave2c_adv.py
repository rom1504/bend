#!/usr/bin/env python3
"""Wave 2C adversarial differential tests vs upstream Bend (bun bend2/main.ts)."""
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
BUN = str(ROOT / "selfhost/.assets/bin/bun")
EMIT = str(ROOT / "research/agy/emit_obj.mjs")
RT = str(ROOT / "selfhost/build/agy/unified/runtime-agy.o")

TESTS = {
    "xmm_across_branch_and_call": r"""import Base

def opaque_clobber(n: Nat, x: F32) -> F32:
  match n:
    case 0n: x
    case 1n+p: opaque_clobber(p, F32.add(F32.mul(x, 1.0001), 0.25))

def pick_t(cond: Bool, b: F32, disc: F32) -> F32:
  match cond:
    case True{}: 100.0
    case False{}: F32.sub(F32.sub(0.0, b), F32.sqrt(disc))

def pick_c2(cond: Bool, b: F32, dx: F32, t1: F32) -> F32:
  match cond:
    case True{}: F32.add(opaque_clobber(3n, dx), b)
    case False{}: F32.add(F32.mul(b, 2.0), t1)

def branch_loop(n: Nat, +ox: F32, +dx: F32, acc: F32) -> F32:
  match n:
    case 0n: acc
    case 1n+p:
      +b = F32.add(F32.mul(ox, dx), 0.5)
      +disc = F32.sub(F32.mul(b, b), 1.25)
      +t1 = pick_t(F32.is_lt(disc, 0.0), b, disc)
      c2 = pick_c2(F32.is_gt(ox, 1.5), b, dx, t1)
      branch_loop(p, F32.add(ox, 0.37), F32.sub(dx, 0.11), F32.add(acc, F32.add(c2, t1)))

def main() -> IO(Unit):
  r = branch_loop(12n, 0.25, 1.75, 0.0)
  IO.print(U32.show(F32.to_u32(F32.mul(F32.add(r, 10000.0), 100.0))) ++ "\n")
""",
    "table_to_xmm_mixed_and_int": r"""import Base

def ftbl(k: U32) -> F32:
  match k:
    case 0: 1.25
    case 1: F32.sub(0.0, 2.5)
    case 2: 3.75
    case 3: 0.0
    case _: 9.5

def itbl(k: U32) -> U32:
  match k:
    case 0: 100
    case 1: 200
    case 2: 300
    case 3: 400
    case _: 999

def mix_loop(n: Nat, +k: U32, fa: F32, ia: U32) -> U32:
  match n:
    case 0n: U32.add(F32.to_u32(F32.mul(F32.add(fa, 10000.0), 100.0)), ia)
    case 1n+p:
      fv = ftbl(k)
      +iv = itbl(k)
      mix_loop(p, U32.add(k, 1), F32.add(fa, F32.mul(fv, 2.0)), U32.add(ia, U32.add(U32.mul(iv, 2), U32.mul(2, iv))))

def main() -> IO(Unit):
  IO.print(U32.show(mix_loop(8n, 0, 0.5, 1)) ++ "\n")
""",
    "mul2_wrap_and_empty_if_asr": r"""import Base

def asr8_pick(neg: Bool, s: U32) -> U32:
  match neg:
    case True{}: s
    case False{}: U32.or(s, 4278190080)

def asr8(+x: U32) -> U32:
  s = (x >> 8n : U32)
  asr8_pick(U32.is_eq((x >> 31n : U32), 0), s)

def step(n: Nat, +x: U32, +y: U32, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      +a = U32.mul(2, x)
      +b = U32.mul(y, 2)
      c = asr8(a)
      d = asr8(b)
      step(p, U32.add(x, 2147483649), U32.sub(y, 1073741823), U32.xor(acc, U32.add(U32.add(a, b), U32.add(c, d))))

def main() -> IO(Unit):
  r1 = step(20n, 2147483648, 4294967295, 0)
  r2 = step(20n, 0, 2147483647, r1)
  IO.print(U32.show(r2) ++ "\n")
""",
}


def run_upstream(bend_path: Path) -> str:
    res = subprocess.run(
        [BUN, str(ROOT / "bend2/main.ts"), str(bend_path)],
        capture_output=True, text=True, timeout=60,
    )
    if res.returncode != 0:
        raise RuntimeError(f"upstream failed on {bend_path.name}:\n{res.stdout}\n{res.stderr}")
    return res.stdout.strip()


def run_cand(api: str, bend_path: Path, tmp: Path, name: str) -> str:
    obj = tmp / f"{name}.o"
    exe = tmp / f"{name}.exe"
    subprocess.run([NODE, EMIT, api, str(bend_path), str(obj)], check=True, timeout=120)
    subprocess.run(["cc", "-O2", str(obj), RT, "-lm", "-lpthread", "-o", str(exe)], check=True, timeout=60)
    res = subprocess.run([str(exe)], capture_output=True, text=True, check=True, timeout=30)
    return res.stdout.strip()


def main():
    api = sys.argv[1]
    passed = 0
    with tempfile.TemporaryDirectory(prefix="w2c_adv_") as td:
        tmp = Path(td)
        for name, code in TESTS.items():
            bp = tmp / f"{name}.bend"
            bp.write_text(code)
            exp = run_upstream(bp)
            got = run_cand(api, bp, tmp, name)
            if exp != got:
                print(f"FAIL {name}: expected={exp!r} got={got!r}")
                sys.exit(1)
            print(f"PASS {name:34s} stdout={got}")
            passed += 1
    print(f"\nWAVE 2C ADVERSARIAL TESTS PASSED: {passed}/{len(TESTS)}")


if __name__ == "__main__":
    main()
