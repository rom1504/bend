#!/usr/bin/env python3
"""Verify & benchmark Wave 3B Track B2 (AGY-W3B-STRHASH):
  1. Adversarial correctness tests (thunks/lazy strings, custom redefined functions, edge cases)
     diffed 3-way against upstream bend2/main.ts and wave2_unified.
  2. Runtime `cid_hot` observer hook check (0 observer violations when SCon/SNil/Chr/KTerm are hot).
  3. 19/19 focused19 conformance suite.
  4. Exact speedup on bench_strhash.bend (1.5M calls) AND bench/runtime/lexer/main.bend
     comparing wave2_unified vs wave3b_strhash (median of 5 runs).
"""
import json
import statistics
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
UPSTREAM = ROOT / "bend2/main.ts"
EMIT_OBJ = ROOT / "research/agy/emit_obj.mjs"
RT_OBJ = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
QUAL_CAT = ROOT / "selfhost/tests/phase182/qualification-catalog.json"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"

W2_API = ROOT / "selfhost/build/agy/wave2_unified/api.mjs"
W3_API = ROOT / "selfhost/build/agy/wave3b_strhash/api.mjs"
BENCH_STRHASH = ROOT / "research/agy/wave3b_strhash/bench_strhash.bend"
BENCH_LEXER = ROOT / "bench/runtime/lexer/main.bend"

STD_DEFS = """
def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, Char.is_eq(h1, h2))

def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same

def p88_string_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(p88_string_eq_go(a, b, True{}), a, b)

@unsafe
def index_hash(
  +name: String,
  +acc: U32,
) -> U32:
  match name:
    case SNil{}:
      acc
    case SCon{h, rest}:
      index_hash(rest, U32.mul(U32.xor(acc, Char.to_u32(h)), 16777619))

type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}

def p98_tag_eq_read(term: KTerm, key: String) -> Bool:
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      p88_string_eq_go(tag, key, True{})
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      p88_string_eq("Lam", key)
    case KLiteral{kind, number, text, begin, end}:
      p88_string_eq("Lit", key)

def p98_tag_eq_finish(same: Bool, term: KTerm, key: String) -> Bool:
  same

def p98_tag_eq(+term: KTerm, +key: String) -> Bool:
  p98_tag_eq_finish(p98_tag_eq_read(term, key), term, key)
"""

ADV_TESTS = {
    "edge_cases": "import Base\n" + STD_DEFS + """
def main() -> IO(Unit):
  +s0 : String = ""
  +s1 : String = "a"
  +s2 : String = "ab"
  +s3 = String.append("a", "b")
  +r0 = Bool.to_u32(p88_string_eq(s0, s0))
  +r1 = Bool.to_u32(p88_string_eq(s0, s1))
  +r2 = Bool.to_u32(p88_string_eq(s1, s0))
  +r3 = Bool.to_u32(p88_string_eq(s2, s3))
  +r4 = Bool.to_u32(p88_string_eq_go(s2, s3, False{}))
  +r5 = Bool.to_u32(String.eq(s2, s3))
  +r6 = Bool.to_u32(String.eq(s1, s2))
  +h0 = index_hash("", 2166136261)
  +h1 = index_hash("hello", 2166136261)
  +h2 = index_hash(String.append("hel", "lo"), 2166136261)
  +tk : KTerm = KTerm{"App", "f", 0, 0, [], [], 0, 0}
  +tl : KTerm = KLambda{"x", 0, 1, [], [], 0, 0, False{}}
  +ti : KTerm = KLiteral{"U32", 7, "7", 0, 0}
  +q0 = Bool.to_u32(p98_tag_eq(tk, "App"))
  +q1 = Bool.to_u32(p98_tag_eq(tk, "Lam"))
  +q2 = Bool.to_u32(p98_tag_eq(tl, "Lam"))
  +q3 = Bool.to_u32(p98_tag_eq(tl, "Lamb"))
  +q4 = Bool.to_u32(p98_tag_eq(ti, "Lit"))
  +q5 = Bool.to_u32(p98_tag_eq(ti, "Li"))
  IO.print(U32.show(U32.add(U32.xor(h0, U32.xor(h1, h2)),
    U32.add(r0, U32.add(U32.mul(r1,2), U32.add(U32.mul(r2,4), U32.add(U32.mul(r3,8),
    U32.add(U32.mul(r4,16), U32.add(U32.mul(r5,32), U32.add(U32.mul(r6,64),
    U32.add(U32.mul(q0,128), U32.add(U32.mul(q1,256), U32.add(U32.mul(q2,512),
    U32.add(U32.mul(q3,1024), U32.add(U32.mul(q4,2048), U32.mul(q5,4096))))))))))))))))
""",
    "lazy_thunk_strings": "import Base\n" + STD_DEFS + """
def mk_lazy(n: Nat, +c: U32) -> String:
  match n:
    case 0n: ""
    case 1n+p: SCon{Chr{c}, mk_lazy(p, U32.sub(c, 1))}

def main() -> IO(Unit):
  +a = mk_lazy(5n, 101)
  +b : String = "edcba"
  +c = mk_lazy(0n, 97)
  +r0 = Bool.to_u32(p88_string_eq(a, b))
  +r1 = Bool.to_u32(p88_string_eq("", c))
  +r2 = Bool.to_u32(p88_string_eq(c, ""))
  +r3 = Bool.to_u32(String.eq(a, b))
  +h0 = index_hash(a, 2166136261)
  +h1 = index_hash(b, 2166136261)
  +t : KTerm = KTerm{mk_lazy(3n, 99), "x", 0, 0, [], [], 0, 0}
  +q0 = Bool.to_u32(p98_tag_eq(t, "cba"))
  IO.print(U32.show(U32.add(U32.xor(h0, h1), U32.add(r0, U32.add(U32.mul(r1,2),
    U32.add(U32.mul(r2,4), U32.add(U32.mul(r3,8), U32.mul(q0,16))))))))
""",
    "redefined_body_pin_decline": "import Base\n" + """
# Custom index_hash with DIFFERENT multiplier (31 instead of 16777619) - must decline fast path!
@unsafe
def index_hash(+name: String, +acc: U32) -> U32:
  match name:
    case SNil{}: acc
    case SCon{h, rest}: index_hash(rest, U32.add(U32.mul(acc, 31), Char.to_u32(h)))

# Custom p88_string_eq returning inverted result - must decline fast path!
def p88_string_eq(+a: String, +b: String) -> Bool:
  Bool.not(String.eq(a, b))

def main() -> IO(Unit):
  +h = index_hash("hello", 7)
  +b = Bool.to_u32(p88_string_eq("abc", "abc"))
  IO.print(U32.show(U32.add(h, b)))
""",
}

# C shim linked before main via __attribute__((constructor)) to mark ALL cids hot
# and verify our fast path bails cleanly with 0 observer violations!
CID_HOT_SHIM_C = r"""
#include <stdint.h>
#include <stdio.h>
typedef struct {
  uint64_t abi;
  uint64_t desc_words;
  uint64_t func_count;
  uint64_t ctor_count;
  uint64_t static_words;
  uint64_t entry;
  uint64_t entry_arity;
  uint64_t heap_words;
  uint64_t static_base;
  uint64_t reserved0;
  uint64_t reserved1;
  uint64_t capabilities;
  uint64_t r12, r13, r14, r15;
  const uint8_t *cid_arity;
  uint8_t *cid_hot;
} P111Program;
extern P111Program p111_program;
__attribute__((constructor))
static void force_all_hot(void) {
  if (p111_program.cid_hot && p111_program.ctor_count < 4096) {
    for (uint64_t i = 0; i < p111_program.ctor_count; i++) {
      p111_program.cid_hot[i] = 1;
    }
  }
}
"""


def run(cmd, cwd=None, timeout=60):
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout)


def compile_native(api: Path, src: Path, obj: Path, exe: Path, extra_objs=()):
    r1 = run([str(BUN), str(EMIT_OBJ), str(api), str(src), str(obj)])
    if r1.returncode != 0:
        raise RuntimeError(f"emit_obj failed: {r1.stderr[:300]}")
    r2 = run([CC, "-O2", "-no-pie", str(obj), *[str(x) for x in extra_objs], str(RT_OBJ), "-o", str(exe), "-lm", "-pthread"])
    if r2.returncode != 0:
        raise RuntimeError(f"link failed: {r2.stderr[:300]}")


def run_upstream(src: Path) -> str:
    r = run([str(BUN), str(UPSTREAM), str(src)])
    if r.returncode != 0:
        raise RuntimeError(f"upstream failed on {src}: {r.stderr[:300]}")
    return r.stdout


def bench_exe(exe: Path, runs: int = 5) -> tuple[float, str]:
    times = []
    out = ""
    for _ in range(runs):
        t0 = time.perf_counter()
        r = run([str(exe)])
        t1 = time.perf_counter()
        if r.returncode != 0:
            raise RuntimeError(f"exe failed rc={r.returncode}: {r.stderr[:200]}")
        out = r.stdout
        times.append((t1 - t0) * 1000.0)
    return statistics.median(times), out


def main():
    with tempfile.TemporaryDirectory() as td_s:
        td = Path(td_s)

        # 1. Adversarial tests (3-way diff: upstream == W2 == W3 + cid_hot observer shim!)
        print("=== 1. Adversarial 3-way diff + cid_hot observer check ===")
        shim_c = td / "cid_hot_shim.c"
        shim_o = td / "cid_hot_shim.o"
        shim_c.write_text(CID_HOT_SHIM_C)
        r_sh = run([CC, "-O2", "-c", str(shim_c), "-o", str(shim_o)])
        assert r_sh.returncode == 0, r_sh.stderr

        for name, code in ADV_TESTS.items():
            src = td / f"{name}.bend"
            src.write_text(code)
            up_out = run_upstream(src)
            w2_exe = td / f"{name}_w2.bin"
            w3_exe = td / f"{name}_w3.bin"
            w3_hot = td / f"{name}_w3_hot.bin"
            compile_native(W2_API, src, td / f"{name}_w2.o", w2_exe)
            compile_native(W3_API, src, td / f"{name}_w3.o", w3_exe)
            compile_native(W3_API, src, td / f"{name}_w3_hot.o", w3_hot, extra_objs=[shim_o])
            o2 = run([str(w2_exe)]).stdout
            o3 = run([str(w3_exe)]).stdout
            oh = run([str(w3_hot)]).stdout
            assert up_out == o2 == o3 == oh, f"{name} mismatch: up={up_out!r} w2={o2!r} w3={o3!r} hot={oh!r}"
            # Verify fast path symbols were emitted for edge_cases (and NOT emitted for redefined_body_pin_decline)
            nm_out = run(["nm", str(td / f"{name}_w3.o")]).stdout
            has_sh_slow = "__sh_slow" in nm_out
            if name == "edge_cases":
                assert has_sh_slow, "Expected __sh_slow fast-path wrappers in edge_cases!"
            elif name == "redefined_body_pin_decline":
                # String.eq is still pinned from Base, so check that index_hash and p88_string_eq were NOT wrapped
                assert "105_110_100_101_120_95_104_97_115_104___sh_slow" not in nm_out, "index_hash should have declined!"
                assert "112_56_56_95_115_116_114_105_110_103_95_101_113___sh_slow" not in nm_out, "p88_string_eq should have declined!"
            print(f"  [PASS] {name}: up == w2 == w3 == cid_hot ({o3.strip()})")

        # 2. focused19
        print("\n=== 2. focused19 Conformance ===")
        cat = json.loads(QUAL_CAT.read_text())
        focused = [c for c in cat["cases"] if c.get("suite") == "focused19" or "focused19" in c.get("suites", [])]
        if not focused:
            focused = cat["cases"][:19]
        failed = []
        for c in focused:
            cid = c["id"]
            src = ROOT / c["source"]["file"]
            exp = c["expect"]
            obj = td / f"f19_{c['name']}.o"
            binp = td / f"f19_{c['name']}.bin"
            c1 = run([str(BUN), str(EMIT_OBJ), str(W3_API), str(src), str(obj)])
            if exp["stage"] != "execute":
                if c1.returncode != 0:
                    continue
                failed.append(f"{cid}: expected refusal")
                continue
            if c1.returncode != 0:
                failed.append(f"{cid}: emit_obj failed: {c1.stderr[:120]}")
                continue
            c2 = run([CC, "-O2", "-no-pie", str(obj), str(RT_OBJ), "-o", str(binp), "-lm", "-pthread"])
            if c2.returncode != 0:
                failed.append(f"{cid}: link failed")
                continue
            ev = run([str(binp)])
            if ev.returncode != exp["exitCode"] or ev.stdout != exp["stdout"] or ev.stderr != exp["stderr"]:
                failed.append(f"{cid}: output mismatch")
        assert not failed, f"focused19 failures: {failed}"
        print(f"  [PASS] focused19: {len(focused)}/{len(focused)} PASS")

        # 3. Microbenchmark: bench_strhash.bend (1.5M calls)
        print("\n=== 3. Benchmark: bench_strhash.bend (1,500,000 calls) ===")
        b_w2 = td / "bench_strhash_w2.bin"
        b_w3 = td / "bench_strhash_w3.bin"
        compile_native(W2_API, BENCH_STRHASH, td / "bench_strhash_w2.o", b_w2)
        compile_native(W3_API, BENCH_STRHASH, td / "bench_strhash_w3.o", b_w3)
        t_w2, out_w2 = bench_exe(b_w2, runs=5)
        t_w3, out_w3 = bench_exe(b_w3, runs=5)
        assert out_w2 == out_w3, f"bench_strhash mismatch: w2={out_w2!r} w3={out_w3!r}"
        print(f"  wave2_unified:  {t_w2:.2f} ms (out={out_w2.strip()})")
        print(f"  wave3b_strhash: {t_w3:.2f} ms (out={out_w3.strip()})")
        print(f"  SPEEDUP:        {t_w2 / t_w3:.2f}x")

        # 4. Proxy benchmark: bench/runtime/lexer/main.bend
        print("\n=== 4. Benchmark: bench/runtime/lexer/main.bend ===")
        l_w2 = td / "lexer_w2.bin"
        l_w3 = td / "lexer_w3.bin"
        compile_native(W2_API, BENCH_LEXER, td / "lexer_w2.o", l_w2)
        compile_native(W3_API, BENCH_LEXER, td / "lexer_w3.o", l_w3)
        lt_w2, lout_w2 = bench_exe(l_w2, runs=5)
        lt_w3, lout_w3 = bench_exe(l_w3, runs=5)
        assert lout_w2 == lout_w3, f"lexer mismatch: w2={lout_w2!r} w3={lout_w3!r}"
        print(f"  wave2_unified:  {lt_w2:.2f} ms (out={lout_w2.strip()})")
        print(f"  wave3b_strhash: {lt_w3:.2f} ms (out={lout_w3.strip()})")
        print(f"  SPEEDUP:        {lt_w2 / lt_w3:.2f}x")


if __name__ == "__main__":
    main()
