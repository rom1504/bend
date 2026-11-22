#!/usr/bin/env python3
"""Adversarial & boundary differential tests for Wave 2 Track D (p205v + W2D deforestation)
against upstream Bend (bun bend2/main.ts)."""
import subprocess, sys, tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
NODE = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
BUN = ROOT / "selfhost/.assets/bin/bun"
UPSTREAM = ROOT / "bend2/main.ts"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
EMIT = ROOT / "research/agy/emit_obj.mjs"
API = ROOT / "selfhost/build/agy/wave2_lexrec/api_lex.mjs"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"

TESTS = {
  # 1. U32 interval wrap boundary: (4294967290 + (x % 10)) wraps past 2^32-1 for x%10 >= 6!
  "u32_interval_wrap": r"""
import Base
def b2u(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0
def wrap_check(+x: U32) -> U32:
  +c = U32.add(4294967290, U32.mod(x, 10))
  b2u(U32.is_ge(c, 4294967290))
def walk(s: String, +acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{Chr{c}, t}: walk(t, U32.add(acc, wrap_check(c)))
def mk(n: Nat, +k: U32, rest: String) -> String:
  match n:
    case 0n: rest
    case 1n+p: SCon{Chr{k}, mk(p, U32.add(k, 1), rest)}
def run(+x: U32) -> U32:
  walk(mk(12n, x, SNil{}), 0)
def main() -> IO(Unit):
  IO.print(U32.show(U32.add(U32.mul(run(0), 100), run(5))))
""",

  # 2. Zero-count builder + adjacent mixed/same classes ("ii", "nn", "in", "ni", ";", "")
  "adjacent_and_zero": r"""
import Base
type M is Data:
  G{}
  A{h: U32}
  B{v: U32}
def prng(+x: U32) -> U32:
  U32.xor(U32.mul(x, 1664525), 1013904223)
def mkA(n: Nat, t: U32, rest: String) -> String:
  match n:
    case 0n: rest
    case 1n+p:
      +u = prng(t)
      SCon{Chr{U32.add(97, U32.mod(u, 26))}, mkA(p, u, rest)}
def mkB(n: Nat, t: U32, rest: String) -> String:
  match n:
    case 0n: rest
    case 1n+p:
      +u = prng(t)
      SCon{Chr{U32.add(48, U32.mod(u, 10))}, mkB(p, u, rest)}
def is_a(+c: U32) -> Bool:
  U32.is_le(97, c) && U32.is_le(c, 122)
def is_b(+c: U32) -> Bool:
  U32.is_le(48, c) && U32.is_le(c, 57)
def step_go(m: M, la: Bool, lb: Bool, c: U32, acc: U32) -> M & U32:
  match m la lb:
    case G{} True{} _: (A{c}, acc)
    case G{} False{} True{}: (B{U32.sub(c, 48)}, acc)
    case G{} False{} False{}: (G{}, U32.add(U32.mul(acc, 31), c))
    case A{h} True{} _: (A{U32.add(U32.mul(h, 33), c)}, acc)
    case A{h} False{} True{}: (B{U32.sub(c, 48)}, U32.add(U32.mul(acc, 31), h))
    case A{h} False{} False{}: (G{}, U32.add(U32.mul(U32.add(U32.mul(acc, 31), h), 31), c))
    case B{v} True{} _: (A{c}, U32.add(U32.mul(acc, 31), v))
    case B{v} False{} True{}: (B{U32.add(U32.mul(v, 10), U32.sub(c, 48))}, acc)
    case B{v} False{} False{}: (G{}, U32.add(U32.mul(U32.add(U32.mul(acc, 31), v), 31), c))
def step(m: M, +c: U32, acc: U32) -> M & U32:
  step_go(m, is_a(c), is_b(c), c, acc)
def fin(m: M, acc: U32) -> U32:
  match m:
    case G{}: acc
    case A{h}: U32.add(U32.mul(acc, 31), h)
    case B{v}: U32.add(U32.mul(acc, 31), v)
def consume(s: String, r: M & U32) -> U32:
  match s:
    case SNil{}:
      (m, acc) = r
      fin(m, acc)
    case SCon{Chr{c}, t}:
      (m, acc) = r
      consume(t, step(m, c, acc))
def run(+seed: U32) -> U32:
  # Tests 0n builders, adjacent A+A, A+B, B+A, B+B, and trailing open token without space!
  +s0 = mkA(0n, seed, mkA(3n, seed, mkA(2n, U32.add(seed, 1), mkB(0n, seed, mkB(2n, U32.add(seed, 2), SCon{Chr{59}, mkA(2n, U32.add(seed, 3), SNil{})})))))
  consume(s0, (G{}, 0))
def main() -> IO(Unit):
  IO.print(U32.show(U32.xor(run(0), U32.xor(run(42), run(4294967295)))))
""",

  # 3. Observed intermediate string (used twice: String.length + fold) -> must NOT drop/corrupt!
  "observed_intermediate": r"""
import Base
def mk(n: Nat, +k: U32, rest: String) -> String:
  match n:
    case 0n: rest
    case 1n+p: SCon{Chr{U32.add(65, U32.mod(k, 26))}, mk(p, U32.add(k, 3), rest)}
def sum_ch(s: String, +acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{Chr{c}, t}: sum_ch(t, U32.add(acc, c))
def len_u32(s: String, +acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{_, t}: len_u32(t, U32.add(acc, 1))
def run(+k: U32) -> U32:
  +s = mk(5n, k, SCon{Chr{33}, SNil{}})
  U32.add(len_u32(s, 0), sum_ch(s, 0))
def main() -> IO(Unit):
  IO.print(U32.show(U32.add(run(7), run(4294967295))))
""",

  # 4. Template unfold with Unicode + custom renamed fold (no lexer names anywhere)
  "unicode_template_fold": r"""
import Base
def emit_n(n: Nat, +x: U32, tail: String) -> String:
  match n:
    case 0n: tail
    case 1n+p: SCon{Chr{U32.add(48, U32.mod(x, 10))}, emit_n(p, U32.add(x, 7), tail)}
def expand_if(eq: Bool, c: U32, +x: U32, tail: String) -> String:
  match eq:
    case True{}: emit_n(U32.to_nat(U32.add(1, U32.and(x, 3))), x, tail)
    case False{}: SCon{Chr{c}, tail}
def expand_c(+c: U32, +x: U32, tail: String) -> String:
  expand_if(U32.is_eq(c, 35), c, x, tail)
def build(tpl: String, +x: U32) -> String:
  match tpl:
    case SNil{}: SNil{}
    case SCon{Chr{c}, rest}: expand_c(c, x, build(rest, U32.add(x, 13)))
def fold_str(s: String, +h: U32) -> U32:
  match s:
    case SNil{}: h
    case SCon{Chr{c}, t}: fold_str(t, U32.xor(U32.mul(h, 16777619), c))
def run(+seed: U32) -> U32:
  fold_str(build("a#α#b#", seed), 2166136261)
def main() -> IO(Unit):
  IO.print(U32.show(U32.xor(run(0), U32.xor(run(17), run(4294967295)))))
""",

  # 5. Lexer extreme boundary seeds: depth=0 (single line), seed=0, seed=4294967295
  "lexer_boundary_seeds": None,
}

with tempfile.TemporaryDirectory(prefix="w2d_adv_") as td:
    td = Path(td)
    # Build lexer_boundary_seeds from real lexer.bend
    lex_src = (ROOT / "selfhost/tools/bench/catalogs/native45/fixtures/lexer.bend").read_text()
    cut = lex_src.index("def p88_original_main")
    TESTS["lexer_boundary_seeds"] = lex_src[:cut] + """
def main() -> IO(Unit):
  +a = batch(0n, 0)
  +b = batch(0n, 4294967295)
  +c = batch(2n, 4294967294)
  IO.print(U32.show(U32.xor(a, U32.xor(b, c))))
"""
    passed = 0
    for name, code in TESTS.items():
        src = td / f"{name}.bend"
        src.write_text(code)
        # Upstream Bend reference
        up = subprocess.run([str(BUN), str(UPSTREAM), str(src)], capture_output=True, text=True, check=True, timeout=60)
        exp_out = up.stdout
        # Candidate native x86
        obj = td / f"{name}.o"
        exe = td / f"{name}"
        subprocess.run([NODE, "--stack-size=4096", str(EMIT), str(API), str(src), str(obj)],
                       capture_output=True, text=True, check=True)
        subprocess.run([CC, "-no-pie", str(obj), str(RT), "-pthread", "-lm", "-o", str(exe)],
                       capture_output=True, text=True, check=True)
        cand = subprocess.run([str(exe)], capture_output=True, text=True, check=True, timeout=30)
        if cand.stdout == exp_out:
            passed += 1
            print(f"PASS {name}: out={cand.stdout.strip()!r}")
        else:
            print(f"FAIL {name}: cand={cand.stdout!r} != upstream={exp_out!r}")
            sys.exit(1)
    print(f"\nadversarial differential tests: {passed}/{len(TESTS)} passed")
