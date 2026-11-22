#!/usr/bin/env python3
"""Tier-2 Adversarial & Boundary Differential Test Suite for Wave 2 Track D:
  - $w2d$m2$<ctor> / $w2d$ch$<code> lifted-Mat name collision bug!
  - p205v U32 interval wraparound, mod 0, and, endpoint comparisons (0, 4294967295)
  - W2D String foldl deforestation & $c unboxing: empty "", 0n, Unicode >65535,
    non-linear observed strings, order-sensitive folds

Requires bit-exact stdout across:
  1. Upstream Bend (bun /home/ai/bend2_agy/bend2/main.ts)
  2. Phase 205 hosted x86 API (api-base/api.mjs)
  3. Wave 2 Track D candidate hosted x86 API (arg 1)
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
TMP_ROOT = ROOT / "selfhost/build/agy/tier2_audit_d/adv_tmp"

CASES = [
    # ------------------------------------------------------------------
    # 1. W2D: $w2d$m2$<ctor> name collision silent miscompilation!
    #    op1 (+ - * /) and op2 (= ; : ,) both hoist Gap{} -> second call silently
    #    reuses op1's $w2d$m2$Gap instead of emitting op2's Mat!
    # ------------------------------------------------------------------
    (
        "w2d_m2_name_collision",
        r'''import Base

type M is Data:
  Gap{}
  Tok{h: U32}

def op1_pick(b1: Bool, b0: Bool) -> Char:
  match b1 b0:
    case False{} False{}: '+'
    case False{} True{}: '-'
    case True{} False{}: '*'
    case True{} True{}: '/'

def op2_pick(b1: Bool, b0: Bool) -> Char:
  match b1 b0:
    case False{} False{}: '='
    case False{} True{}: ';'
    case True{} False{}: ':'
    case True{} True{}: ','

def op1(+t: U32, rest: String) -> String:
  SCon{op1_pick(U32.is_ne(U32.and(t, 2), 0), U32.is_ne(U32.and(t, 1), 0)), rest}

def op2(+t: U32, rest: String) -> String:
  SCon{op2_pick(U32.is_ne(U32.and(t, 2), 0), U32.is_ne(U32.and(t, 1), 0)), rest}

def step(m: M, c: U32, acc: U32) -> M & U32:
  match m:
    case Gap{}: (Gap{}, U32.add(U32.mul(acc, 31), c))
    case Tok{h}: (Gap{}, U32.add(U32.mul(acc, 31), U32.add(h, c)))

def fin(m: M, acc: U32) -> U32:
  match m:
    case Gap{}: acc
    case Tok{h}: U32.add(acc, h)

def lex(s: String, r: M & U32) -> U32:
  match s:
    case SNil{}:
      (m, acc) = r
      fin(m, acc)
    case SCon{Chr{c}, t}:
      (m, acc) = r
      lex(t, step(m, c, acc))

def run(+u: U32, acc: U32) -> U32:
  lex(op1(u, op2(u, SNil{})), (Gap{}, acc))

def loop(n: Nat, +u: U32, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop(p, U32.add(u, 1), run(u, acc))

def main() -> IO(Unit):
  IO.print(U32.show(loop(4n, 0, 7)))
''',
    ),
    # ------------------------------------------------------------------
    # 2. p205v: U32 interval wraparound, mod 0, and, endpoint comparisons (0, 4294967295)
    # ------------------------------------------------------------------
    (
        "w2d_u32_interval_edges",
        r'''import Base

def b2u(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0

def check_intervals(+x: U32) -> U32:
  # mod 0 must NOT crash or mis-fold!
  +m0 = U32.mod(x, 0)
  # add wraparound at 4294967295
  +w1 = U32.add(4294967290, U32.mod(x, 10))
  # exact no-wrap boundary: 4294967290 + (x & 5) <= 4294967295
  +w2 = U32.add(4294967290, U32.and(x, 5))
  # endpoint comparisons at 0 and 4294967295
  c1 = b2u(U32.is_eq(m0, 0))
  c2 = b2u(U32.is_lt(w1, 10))
  c3 = b2u(U32.is_ge(w2, 4294967290))
  c4 = b2u(U32.is_le(w2, 4294967295))
  c5 = b2u(U32.is_eq(w2, 4294967295))
  U32.add(c1, U32.add(U32.mul(c2, 2), U32.add(U32.mul(c3, 4), U32.add(U32.mul(c4, 8), U32.mul(c5, 16)))))

def loop(n: Nat, +x: U32, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop(p, U32.add(x, 1), U32.add(U32.mul(acc, 37), check_intervals(x)))

def main() -> IO(Unit):
  IO.print(U32.show(loop(16n, 0, 0)))
''',
    ),
    # ------------------------------------------------------------------
    # 3. W2D: empty "", 0n builder, Unicode > 65535 (Chr{128512}), non-linear string,
    #    order-sensitive fold
    # ------------------------------------------------------------------
    (
        "w2d_unicode_empty_and_order",
        r'''import Base

def mk_uni(n: Nat, +k: U32, rest: String) -> String:
  match n:
    case 0n: rest
    case 1n+p: SCon{Chr{U32.add(128512, U32.mod(k, 16))}, mk_uni(p, U32.add(k, 3), rest)}

def fold_ord(s: String, acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{Chr{c}, t}: fold_ord(t, U32.sub(U32.mul(acc, 131), c))

def run(+k: U32) -> U32:
  +s = mk_uni(4n, k, SCon{Chr{945}, mk_uni(0n, k, SNil{})})
  a = fold_ord(SNil{}, 17)
  b = fold_ord(mk_uni(3n, k, SNil{}), 19)
  c = U32.xor(fold_ord(s, 23), fold_ord(s, 29))
  U32.xor(a, U32.xor(b, c))

def main() -> IO(Unit):
  IO.print(U32.show(U32.xor(run(0), run(4294967295))))
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
        print(f"  track_d  : {cand}", flush=True)
        if not ok:
            failures.append((name, up, p205, cand))
        src.unlink(missing_ok=True)
    if failures:
        print(f"\nTIER-2 ADVERSARIAL AUDIT FAILED ({len(failures)}/{len(CASES)} failures)!")
        sys.exit(1)
    print(f"\nALL {len(CASES)} TIER-2 ADVERSARIAL DIFFERENTIAL TESTS PASSED!")


if __name__ == "__main__":
    main()
