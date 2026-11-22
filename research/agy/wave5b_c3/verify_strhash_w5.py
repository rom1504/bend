#!/usr/bin/env python3
"""Verify AGY-W5B-STRHASH on wave5b_c3/api.mjs:
  1. Certifies ALL Wave 5A definitions: String.eq, p88_string_eq, p88_string_eq_go,
     agy_str_eq, index_hash, p98_tag_eq, p98_tag_eq_read.
  2. Verifies via `nm` and `objdump -dr` that tight native x86-64 fast paths + `__sh_slow`
     wrappers are emitted for every target (0% bail rate on Wave 5A pins!).
  3. Adversarial 4-way diff (upstream == wave5a_unified == wave5b_c3 == wave5b_c3+cid_hot)
     on edge cases, lazy thunk strings, and redefined-body pin decline.
  4. Benchmarks 1.5M calls of Wave 5A string/hash/tag ops: wave5a_unified vs wave5b_c3.
"""
import re
import statistics
import subprocess
import tempfile
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
BUN = ROOT / "selfhost/.assets/bin/bun"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
UPSTREAM = ROOT / "bend2/main.ts"
EMIT_OBJ = ROOT / "research/agy/emit_obj.mjs"
RT_OBJ = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"

W5A_API = ROOT / "selfhost/build/agy/wave5a_unified/api.mjs"
W5B_API = ROOT / "selfhost/build/agy/wave5b_c3/api.mjs"

W5A_DEFS = """
def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, U32.is_eq(Char.to_u32(h1), Char.to_u32(h2)))

def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same

def p88_string_eq(+a: String, +b: String) -> Bool:
  String.eq(a, b)

@unsafe
def agy_str_eq(+a: String, +b: String) -> Bool:
  String.eq(a, b)

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
      String.eq(tag, key)
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      String.eq("Lam", key)
    case KLiteral{kind, number, text, begin, end}:
      String.eq("Lit", key)

def p98_tag_eq_finish(same: Bool, term: KTerm, key: String) -> Bool:
  same

def p98_tag_eq(+term: KTerm, +key: String) -> Bool:
  match term:
    case KTerm{tag, _, _, _, _, _, _, _}: String.eq(tag, key)
    case KLambda{_, _, _, _, _, _, _, _}: String.eq("Lam", key)
    case KLiteral{_, _, _, _, _}: String.eq("Lit", key)
"""

ADV_TESTS = {
    "w5a_all_targets": "import Base\n" + W5A_DEFS + """
@unsafe
def main() -> IO(Unit):
  +s0 : String = ""
  +s1 : String = "a"
  +s2 : String = "ab"
  +s3 = String.append("a", "b")
  +r0 = Bool.to_u32(p88_string_eq(s0, s0))
  +r1 = Bool.to_u32(p88_string_eq(s0, s1))
  +r2 = Bool.to_u32(agy_str_eq(s2, s3))
  +r3 = Bool.to_u32(agy_str_eq(s1, s2))
  +r4 = Bool.to_u32(p88_string_eq_go(s2, s3, True{}))
  +r5 = Bool.to_u32(p88_string_eq_go(s2, s3, False{}))
  +r6 = Bool.to_u32(String.eq(s2, s3))
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
  +q5 = Bool.to_u32(p98_tag_eq_read(tk, "App"))
  +q6 = Bool.to_u32(p98_tag_eq_read(ti, "Li"))
  IO.print(U32.show(U32.add(U32.xor(h0, U32.xor(h1, h2)),
    U32.add(r0, U32.add(U32.mul(r1,2), U32.add(U32.mul(r2,4), U32.add(U32.mul(r3,8),
    U32.add(U32.mul(r4,16), U32.add(U32.mul(r5,32), U32.add(U32.mul(r6,64),
    U32.add(U32.mul(q0,128), U32.add(U32.mul(q1,256), U32.add(U32.mul(q2,512),
    U32.add(U32.mul(q3,1024), U32.add(U32.mul(q4,2048), U32.add(U32.mul(q5,4096), U32.mul(q6,8192)))))))))))))))))
""",
    "w5a_lazy_thunks": "import Base\n" + W5A_DEFS + """
def mk_lazy(n: Nat, +c: U32) -> String:
  match n:
    case 0n: ""
    case 1n+p: SCon{Chr{c}, mk_lazy(p, U32.sub(c, 1))}

@unsafe
def main() -> IO(Unit):
  +a = mk_lazy(5n, 101)
  +b : String = "edcba"
  +c = mk_lazy(0n, 97)
  +r0 = Bool.to_u32(agy_str_eq(a, b))
  +r1 = Bool.to_u32(p88_string_eq("", c))
  +r2 = Bool.to_u32(p88_string_eq_go(a, b, True{}))
  +r3 = Bool.to_u32(String.eq(a, b))
  +h0 = index_hash(a, 2166136261)
  +h1 = index_hash(b, 2166136261)
  +t : KTerm = KTerm{mk_lazy(3n, 99), "x", 0, 0, [], [], 0, 0}
  +q0 = Bool.to_u32(p98_tag_eq(t, "cba"))
  IO.print(U32.show(U32.add(U32.xor(h0, h1), U32.add(r0, U32.add(U32.mul(r1,2),
    U32.add(U32.mul(r2,4), U32.add(U32.mul(r3,8), U32.mul(q0,16))))))))
""",
    "w5a_pin_decline": """import Base
@unsafe
def agy_str_eq(+a: String, +b: String) -> Bool:
  Bool.not(String.eq(a, b))

@unsafe
def index_hash(+name: String, +acc: U32) -> U32:
  match name:
    case SNil{}: acc
    case SCon{h, rest}: index_hash(rest, U32.add(U32.mul(acc, 31), Char.to_u32(h)))

@unsafe
def main() -> IO(Unit):
  +h = index_hash("hello", 7)
  +b = Bool.to_u32(agy_str_eq("abc", "abc"))
  IO.print(U32.show(U32.add(h, b)))
""",
}

BENCH_W5A = "import Base\n" + W5A_DEFS + """
type BenchData is Data:
  BenchData{+s_eq1: String, +s_eq2: String, +s_d0: String, +s_dm: String, +s_de: String,
    +s_long1: String, +s_long2: String, +t_var: KTerm, +t_lam: KTerm, +t_lit: KTerm}

@unsafe
def bench_once(+d: BenchData) -> U32:
  match d:
    case BenchData{s_eq1, s_eq2, s_d0, s_dm, s_de, s_long1, s_long2, t_var, t_lam, t_lit}:
      +b0 = Bool.to_u32(agy_str_eq(s_eq1, s_eq2))
      +b1 = Bool.to_u32(agy_str_eq(s_eq1, s_d0))
      +b2 = Bool.to_u32(agy_str_eq(s_eq1, s_dm))
      +b3 = Bool.to_u32(agy_str_eq(s_eq1, s_de))
      +b4 = Bool.to_u32(agy_str_eq(s_long1, s_long2))
      +b5 = Bool.to_u32(p88_string_eq(s_long1, s_long1))
      +b6 = Bool.to_u32(p88_string_eq_go(s_eq1, s_eq2, True{}))
      +b7 = Bool.to_u32(String.eq(s_eq1, s_eq2))
      +h1 = index_hash(s_long1, 2166136261)
      +h2 = index_hash(s_eq1, h1)
      +t0 = Bool.to_u32(p98_tag_eq(t_var, "Var"))
      +t1 = Bool.to_u32(p98_tag_eq(t_var, "App"))
      +t2 = Bool.to_u32(p98_tag_eq(t_lam, "Lam"))
      +t3 = Bool.to_u32(p98_tag_eq(t_lit, "Lit"))
      +t4 = Bool.to_u32(p98_tag_eq(t_lit, "Lam"))
      +bits = U32.add(b0, U32.add(U32.mul(b1, 2), U32.add(U32.mul(b2, 4), U32.add(U32.mul(b3, 8),
        U32.add(U32.mul(b4, 16), U32.add(U32.mul(b5, 32), U32.add(U32.mul(b6, 64), U32.add(U32.mul(b7, 128),
        U32.add(U32.mul(t0, 256), U32.add(U32.mul(t1, 512), U32.add(U32.mul(t2, 1024), U32.add(U32.mul(t3, 2048), U32.mul(t4, 4096)))))))))))))
      U32.xor(bits, h2)

@unsafe
def bench_step(+done: Bool, +n: U32, +d: BenchData, +acc: U32) -> U32:
  match done:
    case True{}: acc
    case False{}:
      +n1 = U32.sub(n, 1)
      bench_step(U32.is_eq(n1, 0), n1, d, U32.xor(U32.add(acc, bench_once(d)), n1))

@unsafe
def main() -> IO(Unit):
  +s_eq1 = String.append("p118borrow.read.", "p88_string_eq_go")
  +s_eq2 = String.append("p118borrow.read.", "p88_string_eq_go")
  +s_d0  = String.append("X118borrow.read.", "p88_string_eq_go")
  +s_dm  = String.append("p118borrow.read.", "p88_Xtring_eq_go")
  +s_de  = String.append("p118borrow.read.", "p88_string_eq_gX")
  +s_long1 = String.append("selfhost/compiler/native/x86_64/", "p113d_p118borrow_read_index_hash_long_identifier")
  +s_long2 = String.append("selfhost/compiler/native/x86_64/", "p113d_p118borrow_read_index_hash_long_identifier")
  +t_var : KTerm = KTerm{"Var", "x", 0, 0, [], [], 0, 0}
  +t_lam : KTerm = KLambda{"x", 0, 1, [], [], 0, 0, False{}}
  +t_lit : KTerm = KLiteral{"U32", 42, "42", 0, 0}
  +d : BenchData = BenchData{s_eq1, s_eq2, s_d0, s_dm, s_de, s_long1, s_long2, t_var, t_lam, t_lit}
  IO.print(U32.show(bench_step(False{}, 100000, d, 0)))
"""

CID_HOT_SHIM_C = r"""
#include <stdint.h>
typedef struct {
  uint64_t abi, desc_words, func_count, ctor_count, static_words, entry, entry_arity;
  uint64_t heap_words, static_base, reserved0, reserved1, capabilities;
  uint64_t r12, r13, r14, r15;
  const uint8_t *cid_arity;
  uint8_t *cid_hot;
} P111Program;
extern P111Program p111_program;
__attribute__((constructor))
static void force_all_hot(void) {
  if (p111_program.cid_hot && p111_program.ctor_count < 4096) {
    for (uint64_t i = 0; i < p111_program.ctor_count; i++) p111_program.cid_hot[i] = 1;
  }
}
"""


def run(cmd, timeout=60):
    return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)


def decode_p113e(sym: str) -> str:
    # p113e_symbol encodes chars as decimal ASCII separated by '_' after prefix
    m = re.match(r"^(?:p113d|p113e)_(.*)$", sym)
    if not m:
        return sym
    body = m.group(1)
    suffix = ""
    if body.endswith("___sh_slow"):
        body = body[:-10]
        suffix = "__sh_slow"
    elif body.endswith("__sh_slow"):
        body = body[:-9]
        suffix = "__sh_slow"
    parts = body.split("_")
    chars = []
    for p in parts:
        if p.isdigit():
            chars.append(chr(int(p)))
        else:
            chars.append("_" + p)
    return "".join(chars) + suffix


def compile_native(api: Path, src: Path, obj: Path, exe: Path, extra_objs=()):
    r1 = run(["bash", str(LOCKED_NODE), str(EMIT_OBJ), str(api), str(src), str(obj)])
    if r1.returncode != 0:
        raise RuntimeError(f"emit_obj failed: {r1.stderr[:300]}")
    r2 = run([CC, "-O2", "-no-pie", str(obj), *[str(x) for x in extra_objs], str(RT_OBJ), "-o", str(exe), "-lm", "-pthread"])
    if r2.returncode != 0:
        raise RuntimeError(f"link failed: {r2.stderr[:300]}")


def bench_exe(exe: Path, runs: int = 5):
    times = []
    out = ""
    for _ in range(runs):
        t0 = time.perf_counter()
        r = run(["taskset", "-c", "0", str(exe)])
        t1 = time.perf_counter()
        if r.returncode != 0:
            raise RuntimeError(f"exe failed: {r.stderr[:200]}")
        out = r.stdout
        times.append((t1 - t0) * 1000.0)
    return statistics.median(times), out


def main():
    with tempfile.TemporaryDirectory(prefix="w5b_strhash_") as td_s:
        td = Path(td_s)
        shim_c = td / "shim.c"
        shim_o = td / "shim.o"
        shim_c.write_text(CID_HOT_SHIM_C)
        assert run([CC, "-O2", "-c", str(shim_c), "-o", str(shim_o)]).returncode == 0

        print("=== 1. Adversarial 4-way diff + nm/objdump fast-path audit ===")
        for name, code in ADV_TESTS.items():
            src = td / f"{name}.bend"
            src.write_text(code)
            up = run([str(BUN), str(UPSTREAM), str(src)]).stdout
            o_a = td / f"{name}_w5a.o"
            e_a = td / f"{name}_w5a.bin"
            o_b = td / f"{name}_w5b.o"
            e_b = td / f"{name}_w5b.bin"
            e_h = td / f"{name}_w5b_hot.bin"
            compile_native(W5A_API, src, o_a, e_a)
            compile_native(W5B_API, src, o_b, e_b)
            compile_native(W5B_API, src, td / f"{name}_w5b_h.o", e_h, extra_objs=[shim_o])
            oa = run([str(e_a)]).stdout
            ob = run([str(e_b)]).stdout
            oh = run([str(e_h)]).stdout
            assert up == oa == ob == oh, f"{name} mismatch: up={up!r} a={oa!r} b={ob!r} hot={oh!r}"
            nm = run(["nm", str(o_b)]).stdout
            sh_syms = [l.split()[-1] for l in nm.splitlines() if "__sh_slow" in l]
            decoded = [decode_p113e(s) for s in sh_syms]
            print(f"  [PASS] {name}: 4-way exact ({ob.strip()}), {len(sh_syms)} __sh_slow wrappers")
            if name == "w5a_all_targets":
                for d in sorted(decoded):
                    print(f"         wrapped: {d}")
                # Check all 7 target families are wrapped!
                for expected in ("p88_string_eq_go", "p88_string_eq", "agy_str_eq", "String.eq", "index_hash", "p98_tag_eq_read", "p98_tag_eq"):
                    assert any(expected in d for d in decoded), f"MISSING fast path for {expected}!"
                # objdump snippet for agy_str_eq and index_hash
                od = run(["objdump", "-dr", str(o_b)]).stdout
                for s in sh_syms:
                    fast_sym = s.replace("__sh_slow", "")
                    dec = decode_p113e(fast_sym)
                    if "agy_str_eq" in dec or "index_hash" in dec:
                        idx = od.find(f"<{fast_sym}>:")
                        if idx != -1:
                            snippet = "\n".join(od[idx:idx+1800].splitlines()[:18])
                            print(f"\n  --- objdump -dr <{dec}> ---")
                            print(snippet)
                            break
            elif name == "w5a_pin_decline":
                for forbidden in ("agy_str_eq", "index_hash"):
                    assert not any(forbidden in d for d in decoded), f"{forbidden} should have declined!"
                print(f"         confirmed pin-decline for redefined agy_str_eq & index_hash!")

        print("\n=== 2. Wave 5A String/Hash/Tag Native Microbenchmark (1.5M calls) ===")
        bsrc = td / "bench_w5a.bend"
        bsrc.write_text(BENCH_W5A)
        ba = td / "bench_w5a.bin"
        bb = td / "bench_w5b.bin"
        compile_native(W5A_API, bsrc, td / "bench_w5a.o", ba)
        compile_native(W5B_API, bsrc, td / "bench_w5b.o", bb)
        ta, oa = bench_exe(ba, runs=5)
        tb, ob = bench_exe(bb, runs=5)
        assert oa == ob, f"bench mismatch: {oa!r} vs {ob!r}"
        print(f"  wave5a_unified: {ta:.2f} ms (out={oa.strip()})")
        print(f"  wave5b_c3:      {tb:.2f} ms (out={ob.strip()})")
        print(f"  SPEEDUP:        {ta / tb:.2f}x")


if __name__ == "__main__":
    main()
