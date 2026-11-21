#!/usr/bin/env python3
"""Adverse & soundness controls for AGY-005a CTFE compiler."""
import subprocess, sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EMIT = ROOT / "research/agy/emit_obj.mjs"
RT = ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o"
API = ROOT / "selfhost/build/agy/big_wins/api-ctfe/api.mjs"
OUT = ROOT / "selfhost/build/agy/big_wins/ctfe-controls"

CONTROLS = {
    "fuel_exhaust": ("""import Base
def spin(n: Nat, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: spin(p, U32.add(acc, 1))
def big() -> U32:
  spin(U32.to_nat(50000), 0)
def main() -> IO(Unit):
  IO.print(U32.show(big()))
""", "50000"),
    "dynamic_arg": ("""import Base
def f(x: U32) -> U32:
  U32.add(U32.mul(x, 3), 7)
def count_args(xs: List<String>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{h, t}: U32.add(1, count_args(t))
def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    IO.print(U32.show(f(count_args(args))))
""", None),
    "io_order": ("""import Base
def side() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print("first")
    IO.print("second")
def main() -> IO(Unit):
  side()
""", "first\nsecond"),
    "div_zero_safe": ("""import Base
def maybe_div(flag: Bool) -> U32:
  match flag:
    case True{}: U32.div(10, 0)
    case False{}: 42
def safe_val() -> U32:
  maybe_div(False{})
def main() -> IO(Unit):
  IO.print(U32.show(safe_val()))
""", "42"),
}

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, (src, exp) in CONTROLS.items():
        sp = OUT / f"{name}.bend"
        op = OUT / f"{name}.o"
        ep = OUT / name
        sp.write_text(src)
        subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(API), str(sp), str(op)], check=True, capture_output=True, text=True)
        subprocess.run([CC, "-no-pie", str(op), str(RT), "-pthread", "-lm", "-o", str(ep)], check=True, capture_output=True, text=True)
        r = subprocess.run([str(ep)], check=True, capture_output=True, text=True)
        got = r.stdout.strip()
        if exp is not None:
            assert got == exp, f"{name}: got {got!r}, expected {exp!r}"
        else:
            # dynamic_arg with 0 extra args -> argv has 1 element (exe path) -> 1*3+7 = 10
            assert got == "10", f"{name}: got {got!r}, expected '10'"
            r2 = subprocess.run([str(ep), "a", "b"], check=True, capture_output=True, text=True)
            assert r2.stdout.strip() == "16", f"{name} (2 args): got {r2.stdout.strip()!r}, expected '16'"
        print(f"PASS control: {name} -> {got!r}")

if __name__ == "__main__":
    main()
