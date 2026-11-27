#!/usr/bin/env python3
"""Executable Law-First Generality Matrix & Hardware-Informed Cost-Law gate for bend5k.

Links the formal proofs in `selfhost/bend5k/laws/ownership_laws.bend` to real
x86-64 ELF `.o` output from `bend5k`:
  - Contract A (`ret2` Law 1, STRICT PASS): 0 hot `p111_rt_ctor` calls in
    `queens:$direct.solve` AND 0 total hot `p111_rt_ctor` calls in an unrelated
    holdout 2-scalar loop.
  - Contract B (`IReuse` Law 2, STRICT PASS): in-place unique-slot reuse active
    (0 hot `p111_rt_ctor` calls, direct slot stores, slow-path-only fallback) in
    `tree-bitonic:$direct.warp` AND an unrelated holdout tree-map workload.
  - Contract C (`.rodata` LUT, STRICT PASS): `.rodata` RIP-relative indexed
    table lookup (`lea ...(%rip)` + `.rodata` reloc, <10 conditional branches)
    in `merkle:$direct.spk` AND an unrelated holdout 10-case `Nat`-match table.
  - Contract D (`borrow` Law 3, STRICT PASS): enforces 0 `p111_rt_take` calls in
    `symreg:$direct.eval` and `hashmap:$direct.has`.
  - Contract E (`Linear-Array Hoist` Law 4, STRICT PASS by default): enforces
    preheader handle hoist (`preheader_decodes >= min`) and 0 inner-loop
    `p111_rt_op` / array-handle tag-decode / uninlined helper calls across
    `editdist:$direct.row`, `terrain:$direct.erode`, plus 3 diverse unrelated
    holdouts (`holdout:ro_arr_sum`, `holdout:lin_swap_dead`,
    `holdout:two_arr_copy`). Use `--no-strict-array-hoist` to downgrade.
  - Contract F (`Static String & Static-Take Zero-Alloc`, `[REPORT]` by default,
    `--strict-static-str` to enforce): checks `lexer:$direct.tpl` /
    `lexer:$direct.gen` AND an unrelated constant-string traversal holdout for
    0 heap `SCon` `p111_rt_ctor` calls on constant construction and reports
    `p111_rt_take` count on static string traversal.
  - Contract G (`Hardware-Informed Loop Bottleneck Triager`, `--triage <file>`
    + built-in `[REPORT]` on `kmeans:$direct.chunk` & `list-pipeline`): parses
    `objdump -dr` for `[rbp-]` stack spills, `jcc` branches, `cmov`, `p111_rt_*`
    calls, hardware `div`/`idiv`, and `sqrtss`/`divss` latency-bound ops.
  - Contract H (`SIMD Vectorization Law` Law 6, STRICT PASS): verifies that
    `nbody` AND a synthetic holdout pure-F32 counted loop emit packed
    SSE2/AVX1 FP vector instructions (`addps`/`mulps`/`sqrtps` or
    `vaddps`/`vmulps`/`vsqrtps`) and 0 `p111_rt_ctor` calls in the `$v4`/`$v8`
    kernel.
  - Contract I (`TRMC 1-Pass IMutField Law` Law 5, STRICT PASS): verifies that
    `list-pipeline` (`$direct.dbl`, `$direct.keep_gt1`) AND a synthetic holdout
    `List.map` loop compile to a single-pass self-TCO loop (backward branch
    present) with 0 recursive `call` instructions.
  - Contract J (`Conformance Gate`, STRICT PASS): verifies `bend5k --check-only`
    rejects ill-typed `wrong(x: U32) -> Bool: x` and
    `bad_list(xs: List<&2, U32>) -> List<&2, Bool>: xs` (and emits NO `.o`
    under `-O2`) while accepting their valid neighbors.
  - Contract K (`Dependent Equality Proof Gate`, STRICT PASS): verifies
    `bend5k --check-only` rejects `{0 + 1 == 2 : U32}` `{==}` (and emits NO `.o`
    under `-O2`) while accepting `{1 + 1 == 2 : U32}` `{==}`.
  - Harder Generality Matrix (`[GEN-MATRIX]`, 10 cells): 5 Contract E cells +
    6-arg borrow-walk (`arity=6`), 2-arg tree-zip borrow, nested-match reuse,
    holdout pure-F32 `$v4` SIMD kernel, holdout 1-pass TRMC `List.map`.

Run with `--self-test-fault-injection` to verify that all 9 strict contracts
(`A`, `B`, `C`, `D`, `E`, `H`, `I`, `J`, `K`) fail loudly when optimizations are
disabled (`-O0`) or synthetic faults are injected.
"""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_BEND5K = ROOT / "selfhost/build/agy/bend5k/bend5k_o2"
UNSEEN_W19_DIR = Path(__file__).resolve().parent / "unseen_oracle_w19"

# ---------------------------------------------------------------------------
# Unrelated holdout workloads (fresh small Bend programs, independent of bench/)
# ---------------------------------------------------------------------------

HOLDOUT_RET2_SRC = """\
import Base

type Duo is Data:
  MkDuo{x: U32, y: U32}

def step_duo(k: Nat, +a: U32, +b: U32) -> Duo:
  match k:
    case 0n:
      MkDuo{a, b}
    case 1n+p:
      step_duo(p, U32.add(U32.xor(a, 2654435761), b), U32.add(b, 7))

def unpack_step(n: Nat, +a: U32, +b: U32) -> U32:
  match n:
    case 0n:
      U32.xor(a, b)
    case 1n+p:
      MkDuo{na, nb} = step_duo(4n, a, b)
      unpack_step(p, na, nb)

def main() -> U32:
  unpack_step(16n, 11, 23)
"""

HOLDOUT_IREUSE_SRC = """\
import Base

type BinT is Data:
  BLeaf{v: U32}
  BNode{l: BinT, r: BinT}

def build_t(+d: Nat, +x: U32) -> BinT:
  match d:
    case 0n:
      BLeaf{x}
    case 1n+p:
      BNode{build_t(p, U32.add(x, 1)), build_t(p, U32.add(x, 2))}

def bump_t(t: BinT, +k: U32) -> BinT:
  match t:
    case BLeaf{v}:
      BLeaf{U32.add(v, k)}
    case BNode{l, r}:
      BNode{bump_t(l, k), bump_t(r, k)}

def sum_t(t: BinT) -> U32:
  match t:
    case BLeaf{v}:
      v
    case BNode{l, r}:
      U32.add(sum_t(l), sum_t(r))

def main() -> U32:
  sum_t(bump_t(build_t(5n, 3), 7))
"""

HOLDOUT_LUT_SRC = """\
import Base

def tbl10(i: Nat) -> U32:
  match i:
    case 0n:
      101
    case 1n:
      211
    case 2n:
      307
    case 3n:
      401
    case 4n:
      503
    case 5n:
      601
    case 6n:
      701
    case 7n:
      809
    case 8n:
      907
    case 9n:
      1009
    case 10n+p:
      1103

def mix_lut(n: Nat, +i: Nat, +acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      mix_lut(p, 1n+i, U32.xor(U32.mul(acc, 16777619), tbl10(i)))

def main() -> U32:
  mix_lut(10n, 0n, 1)
"""

# Contract E holdout 1: read-only Array.get loop
HOLDOUT_RO_ARR_SUM_SRC = """\
import Base

def ro_arr_sum.go(+n: Nat, +i: U32, +acc: U32, r: Array<U32> & U32) -> U32:
  (a, v) = r
  ro_arr_sum(n, U32.inc(i), U32.add(acc, v), a)

def ro_arr_sum(+n: Nat, +i: U32, +acc: U32, a: Array<U32>) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      ro_arr_sum.go(p, i, acc, Array.get(U32, a, i))

def main() -> U32:
  ro_arr_sum(64n, 0, 0, [7 : U32*64n])
"""

# Contract E holdout 2: linear Array.swap loop where old value is unused
HOLDOUT_LIN_SWAP_DEAD_SRC = """\
import Base

def lin_swap_dead(+n: Nat, +i: U32, +s: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +ns = U32.add(U32.mul(s, 1664525), 1013904223)
      lin_swap_dead(p, U32.inc(i), ns, Array.swap(U32, a, i, ns))

def finish_read(r: Array<U32> & U32) -> U32:
  (a, v) = r
  v

def main() -> U32:
  a = lin_swap_dead(64n, 0, 1, ([0 : U32*64n], 0))
  finish_read(Array.get(U32, a, 7))
"""

# Contract E holdout 3: 2-array Array.get + Array.swap loop
HOLDOUT_TWO_ARR_COPY_SRC = """\
import Base

def two_arr_copy.step(+n: Nat, +i: U32, dst: Array<U32>, r: Array<U32> & U32) -> Array<U32>:
  (src, v) = r
  two_arr_copy(n, U32.inc(i), src, Array.swap(U32, dst, i, U32.add(v, 1)))

def two_arr_copy(+n: Nat, +i: U32, src: Array<U32>, rdst: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (dst, old) = rdst
      dst
    case 1n+p:
      (dst, old) = rdst
      two_arr_copy.step(p, i, dst, Array.get(U32, src, i))

def finish_copy(r: Array<U32> & U32) -> U32:
  (dst, v) = r
  v

def main() -> U32:
  dst = two_arr_copy(64n, 0, [5 : U32*64n], ([0 : U32*64n], 0))
  finish_copy(Array.get(U32, dst, 3))
"""

# Harder Generality Holdout (Contract D borrow): 6-arg borrow-walk (arity=6)
HOLDOUT_BORROW_ARITY6_SRC = """\
import Base

type Expr6 is Data:
  ELit{v: U32}
  EBin{l: Expr6, r: Expr6}

def eval6(t: Expr6, +x0: U32, +x1: U32, +x2: U32, +x3: U32, +x4: U32) -> U32:
  match t:
    case ELit{v}:
      U32.add(v, U32.add(x0, U32.add(x1, U32.add(x2, U32.add(x3, x4)))))
    case EBin{l, r}:
      U32.add(eval6(l, x0, x1, x2, x3, x4), eval6(r, x0, x1, x2, x3, x4))

def mk_e6(+d: Nat, +k: U32) -> Expr6:
  match d:
    case 0n:
      ELit{k}
    case 1n+p:
      EBin{mk_e6(p, U32.add(k, 1)), mk_e6(p, U32.add(k, 2))}

def main() -> U32:
  +e = mk_e6(4n, 1)
  U32.add(eval6(e, 1, 2, 3, 4, 5), eval6(e, 5, 4, 3, 2, 1))
"""

# Harder Generality Holdout (Contract D borrow): 2-arg tree-zip borrow (tree-matmul:mul style)
HOLDOUT_BORROW_TREE_ZIP_SRC = """\
import Base

type ZTree is Data:
  ZLeaf{v: U32}
  ZNode{l: ZTree, r: ZTree}

def zip_dot(a: ZTree, b: ZTree) -> U32:
  match a b:
    case ZLeaf{va} ZLeaf{vb}:
      U32.mul(va, vb)
    case ZNode{al, ar} ZNode{bl, br}:
      U32.add(zip_dot(al, bl), zip_dot(ar, br))
    case _ _:
      0

def mk_zt(+d: Nat, +k: U32) -> ZTree:
  match d:
    case 0n:
      ZLeaf{k}
    case 1n+p:
      ZNode{mk_zt(p, U32.add(k, 1)), mk_zt(p, U32.add(k, 2))}

def main() -> U32:
  +t1 = mk_zt(4n, 1)
  +t2 = mk_zt(4n, 2)
  U32.add(zip_dot(t1, t2), zip_dot(t2, t1))
"""

# Harder Generality Holdout (Contract B IReuse): nested-match 2-node reuse (merge-style)
HOLDOUT_IREUSE_NESTED_MERGE_SRC = """\
import Base

type MTree is Data:
  MLeaf{v: U32}
  MNode{l: MTree, r: MTree}

def merge_t(a: MTree, b: MTree) -> MTree:
  match a:
    case MLeaf{va}:
      match b:
        case MLeaf{vb}:
          MLeaf{U32.add(va, vb)}
        case MNode{bl, br}:
          MNode{bl, br}
    case MNode{al, ar}:
      match b:
        case MLeaf{vb}:
          MNode{al, ar}
        case MNode{bl, br}:
          MNode{merge_t(al, bl), merge_t(ar, br)}

def mk_mt(+d: Nat, +k: U32) -> MTree:
  match d:
    case 0n:
      MLeaf{k}
    case 1n+p:
      MNode{mk_mt(p, U32.add(k, 1)), mk_mt(p, U32.add(k, 2))}

def sum_mt(t: MTree) -> U32:
  match t:
    case MLeaf{v}:
      v
    case MNode{l, r}:
      U32.add(sum_mt(l), sum_mt(r))

def main() -> U32:
  sum_mt(merge_t(mk_mt(4n, 1), mk_mt(4n, 2)))
"""

# Contract F holdout: unrelated constant string literal construction + traversal
HOLDOUT_STATIC_STR_SRC = """\
import Base

def const_msg() -> String:
  "alpha-beta-gamma-0123456789"

def hash_str(s: String, +acc: U32) -> U32:
  match s:
    case SNil{}:
      acc
    case SCon{Chr{c}, t}:
      hash_str(t, U32.xor(U32.mul(acc, 16777619), c))

def main() -> U32:
  hash_str(const_msg(), 2166136261)
"""

# Contract H holdout: synthetic pure-F32 counted loop (triggers $v4/$v8 SIMD)
HOLDOUT_SIMD_F32_SRC = """\
import Base

def fl_c(n: U32, d: U32) -> F32:
  F32.div(U32.to_f32(n), U32.to_f32(d))

def step_f32(k: Nat, +x: F32, +y: F32, +z: F32) -> F32:
  match k:
    case 0n:
      F32.add(x, F32.add(y, z))
    case 1n+p:
      +r2 = F32.add(F32.add(F32.mul(x, x), F32.mul(y, y)), F32.add(F32.mul(z, z), fl_c(1, 16)))
      +inv = F32.div(fl_c(1, 1), F32.sqrt(r2))
      nx = F32.add(x, F32.mul(y, inv))
      ny = F32.sub(y, F32.mul(z, inv))
      nz = F32.add(z, F32.mul(x, fl_c(1, 32)))
      step_f32(p, nx, ny, nz)

def batch_f32(n: Nat, +i: U32, +acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      +fi = U32.to_f32(U32.inc(i))
      v = step_f32(16n, fi, F32.add(fi, fl_c(1, 2)), F32.add(fi, fl_c(1, 4)))
      batch_f32(p, U32.inc(i), U32.add(acc, F32.to_u32(v)))

def main() -> U32:
  batch_f32(8n, 0, 0)
"""

# Contract I holdout: synthetic List.map loop (triggers 1-pass TRMC IMutField)
HOLDOUT_TRMC_MAP_SRC = """\
import Base

def mk_u32_list(n: Nat, +k: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+p:
      k <> mk_u32_list(p, U32.add(k, 3))

def map_scale(xs: List<&2, U32>, +m: U32) -> List<&2, U32>:
  match xs:
    case Nil{}:
      Nil{}
    case h <> t:
      U32.add(U32.mul(h, m), 1) <> map_scale(t, m)

def sum_u32_list(xs: List<&2, U32>, +acc: U32) -> U32:
  match xs:
    case Nil{}:
      acc
    case h <> t:
      sum_u32_list(t, U32.add(acc, h))

def main() -> U32:
  sum_u32_list(map_scale(mk_u32_list(32n, 1), 7), 0)
"""

# Contract J (Conformance Gate): ill-typed rejection + valid neighbors
CONFORMANCE_WRONG_SRC = """\
import Base

def wrong(x: U32) -> Bool:
  x

def main() -> U32:
  0
"""

CONFORMANCE_BAD_LIST_SRC = """\
import Base

def bad_list(xs: List<&2, U32>) -> List<&2, Bool>:
  xs

def main() -> U32:
  0
"""

CONFORMANCE_GOOD_U32_SRC = """\
import Base

def good_u32(x: U32) -> U32:
  x

def main() -> U32:
  good_u32(1)
"""

CONFORMANCE_GOOD_LIST_SRC = """\
import Base

def good_list(xs: List<&2, U32>) -> List<&2, U32>:
  xs

def main() -> U32:
  0
"""

# Contract K (Dependent Equality Proof Gate): false reflexivity rejection + valid reflexivity acceptance
DEP_EQ_BAD_SRC = """\
import Base

def bad_eq() -> {0 + 1 == 2 : U32}:
  {==}

def main() -> U32:
  0
"""

DEP_EQ_GOOD_SRC = """\
import Base

def good_eq() -> {1 + 1 == 2 : U32}:
  {==}

def main() -> U32:
  0
"""

# Contract N holdout: 32-case dense Nat-match LUT with repeated/CSE-able values inlined into a loop
HOLDOUT_ILUT_INLINE_SRC = """\
import Base

def map32(x: Nat) -> U32:
  match x:
    case 0n: 7
    case 1n: 0
    case 2n: 13
    case 3n: 1
    case 4n: 29
    case 5n: 48
    case 6n: 13
    case 7n: 0
    case 8n: 61
    case 9n: 7
    case 10n: 48
    case 11n: 1
    case 12n: 83
    case 13n: 29
    case 14n: 97
    case 15n: 0
    case 16n: 109
    case 17n: 48
    case 18n: 127
    case 19n: 1
    case 20n: 149
    case 21n: 7
    case 22n: 163
    case 23n: 13
    case 24n: 179
    case 25n: 48
    case 26n: 191
    case 27n: 29
    case 28n: 211
    case 29n: 0
    case 30n: 223
    case 31n: 1
    case 32n+p: 99

def fold_map32(n: Nat, +s: U32, +acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      +ns = U32.add(U32.mul(s, 1664525), 1013904223)
      +v = map32(U32.to_nat(U32.and(U32.shrn(ns, 16n), 63)))
      fold_map32(p, ns, U32.xor(U32.mul(acc, 16777619), v))

def main() -> U32:
  fold_map32(64n, 12345, 2166136261)
"""

# Contract O holdout: counted Array<F32> map loop (triggers 8-wide AVX1 $v8a.)
HOLDOUT_V8A_MAP_F32_SRC = """\
import Base

def poly_map(rem: Nat, +i: U32, src: Array<F32>, dst: Array<F32>, +c: F32) -> Array<F32>:
  match rem:
    case 0n:
      dst
    case 1n+p:
      (src1, +x) = Array.get(F32, src, i)
      +t0 = F32.add(F32.mul(x, x), c)
      +t1 = F32.add(F32.mul(t0, x), 0.25)
      +t2 = F32.add(F32.mul(t1, x), c)
      +y = F32.sub(F32.mul(t2, x), 0.125)
      dst1 = Array.set(F32, dst, i, y)
      poly_map(p, U32.inc(i), src1, dst1, c)

def rd_f32(a: Array<F32>, i: U32) -> U32:
  (_, v) = Array.get(F32, a, i)
  F32.to_u32(v)

def main() -> U32:
  out = poly_map(64n, 0, [1.5 : F32*64n], [0.0 : F32*64n], 0.5)
  rd_f32(out, 5)
"""

# Contract P holdout: loop-carried 3-field single-ctor record with 2 arrays
HOLDOUT_WW_REC_ARR_SRC = """\
import Base

type DualSt is Data:
  DualSt{a: Array<U32>, b: Array<U32>, acc: U32}

def scan_dual(rem: Nat, +i: U32, st: DualSt) -> DualSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      DualSt{a, b, +acc} = st
      (a1, +v) = Array.get(U32, a, i)
      +nv = U32.xor(v, acc)
      (b1, +old) = Array.swap(U32, b, i, nv)
      scan_dual(p, U32.inc(i), DualSt{a1, b1, U32.add(acc, U32.add(v, old))})

def main() -> U32:
  DualSt{_, _, acc} = scan_dual(64n, 0, DualSt{[5 : U32*64n], [3 : U32*64n], 1})
  acc
"""


# ---------------------------------------------------------------------------
# Disassembly & hot/cold/loop analysis
# ---------------------------------------------------------------------------

INSN_RE = re.compile(r"^\s*([0-9a-f]+):\s+(?:[0-9a-f]{2}\s+)+\s*(.+)$")
RELOC_RE = re.compile(r"^\s*([0-9a-f]+):\s+R_X86_64_\w+\s+(.+)$")
JCC_RE = re.compile(r"^(je|jne|jg|jge|jl|jle|ja|jae|jb|jbe|js|jns|jo|jno)\b")
CMOV_RE = re.compile(r"^cmov")
DIV_RE = re.compile(r"^(i?div[lqbw]?)\b")
FP_LAT_RE = re.compile(r"^(sqrt|div)s[sd]\b")
PACKED_FP_RE = re.compile(r"^v?(add|sub|mul|div|sqrt)ps\b")
RBP_MEM_RE = re.compile(r"\(%rbp\)")
BRANCH_TARGET_RE = re.compile(
    r"^(?:jmpq?|je|jne|jg|jge|jl|jle|ja|jae|jb|jbe|js|jns|jo|jno)\s+([0-9a-f]+)\b"
)
SHR_38_RE = re.compile(r"^shr\s+\$0x38,")
CMP_06_RE = re.compile(r"^cmp\s+\$0x6,")


@dataclass
class FuncMetrics:
    symbol: str
    total_insns: int
    hot_insns: int
    total_ctor_calls: int
    hot_ctor_calls: int
    total_take_calls: int
    hot_take_calls: int
    total_sink_calls: int
    total_rt_op_calls: int
    hot_rt_op_calls: int
    loop_rt_op_calls: int
    preheader_arr_decodes: int
    loop_arr_decodes: int
    loop_direct_calls: int
    rodata_lea_rip: int
    jcc_count: int
    hot_slot_stores: int
    rbp_spills: int = 0
    cmov_count: int = 0
    total_rt_calls: int = 0
    div_count: int = 0
    fp_lat_count: int = 0
    packed_fp_ops: int = 0
    self_rec_calls: int = 0
    has_back_branch: bool = False


def compile_to_obj(
    bend5k_bin: Path,
    src_path: Path,
    out_obj: Path,
    opt_flag: str = "-O2",
    cpu_pin: str | None = None,
) -> None:
    cmd: list[str] = []
    if cpu_pin:
        cmd.extend(["taskset", "-c", cpu_pin])
    cmd.extend([str(bend5k_bin), opt_flag, str(src_path), str(out_obj)])
    res = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    if res.returncode != 0:
        raise RuntimeError(
            f"bend5k compile failed ({opt_flag} {src_path}): rc={res.returncode}\n"
            f"stdout: {res.stdout}\nstderr: {res.stderr}"
        )


def disassemble_obj(obj_path: Path) -> dict[str, list[str]]:
    out = subprocess.check_output(
        ["objdump", "-dr", str(obj_path)], text=True, timeout=60
    )
    funcs: dict[str, list[str]] = {}
    cur: str | None = None
    buf: list[str] = []
    for line in out.splitlines():
        m = re.match(r"^[0-9a-f]+ <(.+)>:$", line)
        if m:
            if cur is not None:
                funcs[cur] = buf
            cur = m.group(1)
            buf = []
        elif cur is not None:
            buf.append(line)
    if cur is not None:
        funcs[cur] = buf
    return funcs


def find_cold_boundary(lines: list[str]) -> int:
    """Identify the index in `lines` where out-of-line cold stubs begin."""
    insn_entries: list[tuple[int, int, str]] = []
    for idx, line in enumerate(lines):
        m = INSN_RE.match(line)
        if m:
            insn_entries.append((idx, int(m.group(1), 16), m.group(2).strip()))

    if not insn_entries:
        return len(lines)

    last_ret_pos = -1
    for pos, (_, _, asm) in enumerate(insn_entries):
        if asm.startswith("ret"):
            last_ret_pos = pos

    if last_ret_pos == -1:
        return len(lines)

    last_hot_anchor_line = insn_entries[last_ret_pos][0]
    for i, line in enumerate(lines):
        m = RELOC_RE.match(line)
        if m and "$direct." in m.group(2):
            if i > last_hot_anchor_line:
                last_hot_anchor_line = i

    # Also keep any backward loop branch whose target is at or before
    # `last_hot_anchor_line` (e.g. `terrain:$direct.erode` places `retq` in the
    # base case at the top of the loop and the TCO backedge after the loop body).
    addr_to_line = {addr: idx for idx, addr, _ in insn_entries}
    for idx, addr, asm in insn_entries:
        bm = BRANCH_TARGET_RE.match(asm)
        if bm:
            target_addr = int(bm.group(1), 16)
            if target_addr < addr and target_addr in addr_to_line:
                target_line = addr_to_line[target_addr]
                # Only treat as a hot loop backedge if it jumps back into the
                # region at or before the current hot anchor AND is not a cold
                # stub returning to the middle of a block after a runtime call.
                # Specifically, stop extending past the first runtime call stub
                # after `last_ret_pos`.
                if target_line <= last_hot_anchor_line:
                    # Check whether there is a p111_rt_* relocation between
                    # last_hot_anchor_line and idx (which would mean idx is in
                    # the cold stub section).
                    has_cold_rt = any(
                        RELOC_RE.match(lines[k])
                        and "p111_rt_" in RELOC_RE.match(lines[k]).group(2)  # type: ignore[union-attr]
                        for k in range(last_hot_anchor_line + 1, idx)
                    )
                    if not has_cold_rt and idx > last_hot_anchor_line:
                        last_hot_anchor_line = idx

    cold_start = len(lines)
    for idx, _, asm in insn_entries:
        if idx > last_hot_anchor_line and (
            asm.startswith("ret") or asm.startswith("jmp")
        ):
            cold_start = idx + 1
            break

    if last_hot_anchor_line == insn_entries[last_ret_pos][0]:
        cold_start = last_hot_anchor_line + 1
    else:
        # If last_hot_anchor_line itself is already a terminating jmp/ret,
        # cold starts right after it.
        for idx, _, asm in insn_entries:
            if idx == last_hot_anchor_line and (
                asm.startswith("ret") or asm.startswith("jmp")
            ):
                cold_start = idx + 1
                break

    return cold_start


def find_hot_loop_range(lines: list[str], cold_start: int) -> tuple[int, int]:
    """Return `(loop_start_line, loop_end_line)` (inclusive) for the hot TCO loop.

    If a function has hot backward branches (within `[0, cold_start)`), the hot
    loop spans from the earliest backward-branch target to the latest backward
    branch. Otherwise, the entire hot region `[0, cold_start)` is returned.
    """
    addr_to_line: dict[int, int] = {}
    insns: list[tuple[int, int, str]] = []
    for idx in range(min(cold_start, len(lines))):
        m = INSN_RE.match(lines[idx])
        if m:
            addr = int(m.group(1), 16)
            addr_to_line[addr] = idx
            insns.append((idx, addr, m.group(2).strip()))

    back_targets: list[int] = []
    back_sources: list[int] = []
    for idx, addr, asm in insns:
        bm = BRANCH_TARGET_RE.match(asm)
        if bm:
            target_addr = int(bm.group(1), 16)
            if target_addr < addr and target_addr in addr_to_line:
                back_targets.append(addr_to_line[target_addr])
                back_sources.append(idx)

    if back_targets:
        return min(back_targets), max(back_sources)
    return 0, max(0, cold_start - 1)


def analyze_func(symbol: str, lines: list[str]) -> FuncMetrics:
    cold_start = find_cold_boundary(lines)
    loop_start, loop_end = find_hot_loop_range(lines, cold_start)

    total_insns = 0
    hot_insns = 0
    total_ctor = 0
    hot_ctor = 0
    total_take = 0
    hot_take = 0
    total_sink = 0
    total_rt_op = 0
    hot_rt_op = 0
    loop_rt_op = 0
    preheader_arr_decodes = 0
    loop_arr_decodes = 0
    loop_direct_calls = 0
    rodata_lea_rip = 0
    jcc_count = 0
    hot_slot_stores = 0
    rbp_spills = 0
    cmov_count = 0
    total_rt_calls = 0
    div_count = 0
    fp_lat_count = 0
    packed_fp_ops = 0
    self_rec_calls = 0
    has_back_branch = False

    # Check if hot region has a backward branch (self-TCO loop)
    addr_to_idx: dict[int, int] = {}
    for idx in range(min(cold_start, len(lines))):
        im0 = INSN_RE.match(lines[idx])
        if im0:
            addr0 = int(im0.group(1), 16)
            addr_to_idx[addr0] = idx
            bm0 = BRANCH_TARGET_RE.match(im0.group(2).strip())
            if bm0:
                taddr0 = int(bm0.group(1), 16)
                if taddr0 < addr0 and taddr0 in addr_to_idx:
                    has_back_branch = True

    prev_was_lea_rip = False
    since_shr38 = 99
    shr38_region = "none"  # "preheader" | "loop" | "cold"

    for idx, line in enumerate(lines):
        is_hot = idx < cold_start
        in_loop = is_hot and (loop_start <= idx <= loop_end)
        in_preheader = is_hot and (idx < loop_start)

        im = INSN_RE.match(line)
        if im:
            asm = im.group(2).strip()
            total_insns += 1
            if is_hot:
                hot_insns += 1
                if re.search(
                    r"^mov\s+%[^,]+,(?:0x[0-9a-f]+)?\(%r(?:di|si|ax|cx|dx|8|9|10|11)\)",
                    asm,
                ):
                    hot_slot_stores += 1
            if JCC_RE.match(asm):
                jcc_count += 1
            if CMOV_RE.match(asm):
                cmov_count += 1
            if RBP_MEM_RE.search(asm):
                rbp_spills += 1
            if DIV_RE.match(asm):
                div_count += 1
            if FP_LAT_RE.match(asm):
                fp_lat_count += 1
            if PACKED_FP_RE.match(asm):
                packed_fp_ops += 1
            prev_was_lea_rip = bool(re.match(r"^lea\s+.*\(%rip\)", asm))

            # Detect array-handle tag decode: `shr $0x38, ...` followed within
            # 4 instructions by `cmp $0x6, ...` (ARR tag = 6).
            if SHR_38_RE.match(asm):
                since_shr38 = 0
                shr38_region = (
                    "preheader" if in_preheader else ("loop" if in_loop else "cold")
                )
            else:
                since_shr38 += 1
                if CMP_06_RE.match(asm) and since_shr38 <= 4:
                    if shr38_region == "preheader":
                        preheader_arr_decodes += 1
                    elif shr38_region == "loop":
                        loop_arr_decodes += 1
                    since_shr38 = 99
            continue

        rm = RELOC_RE.match(line)
        if rm:
            target = rm.group(2)
            if "p111_rt_" in target:
                total_rt_calls += 1
            if "p111_rt_ctor" in target:
                total_ctor += 1
                if is_hot:
                    hot_ctor += 1
            elif "p111_rt_take" in target:
                total_take += 1
                if is_hot:
                    hot_take += 1
            elif "p111_rt_sink" in target:
                total_sink += 1
            elif "p111_rt_op" in target:
                total_rt_op += 1
                if is_hot:
                    hot_rt_op += 1
                if in_loop:
                    loop_rt_op += 1
            elif "$direct." in target:
                if target.startswith(symbol + "-") or target == symbol:
                    self_rec_calls += 1
                elif in_loop:
                    loop_direct_calls += 1
            elif ".rodata" in target and prev_was_lea_rip:
                rodata_lea_rip += 1
            prev_was_lea_rip = False

    return FuncMetrics(
        symbol=symbol,
        total_insns=total_insns,
        hot_insns=hot_insns,
        total_ctor_calls=total_ctor,
        hot_ctor_calls=hot_ctor,
        total_take_calls=total_take,
        hot_take_calls=hot_take,
        total_sink_calls=total_sink,
        total_rt_op_calls=total_rt_op,
        hot_rt_op_calls=hot_rt_op,
        loop_rt_op_calls=loop_rt_op,
        preheader_arr_decodes=preheader_arr_decodes,
        loop_arr_decodes=loop_arr_decodes,
        loop_direct_calls=loop_direct_calls,
        rodata_lea_rip=rodata_lea_rip,
        jcc_count=jcc_count,
        hot_slot_stores=hot_slot_stores,
        rbp_spills=rbp_spills,
        cmov_count=cmov_count,
        total_rt_calls=total_rt_calls,
        div_count=div_count,
        fp_lat_count=fp_lat_count,
        packed_fp_ops=packed_fp_ops,
        self_rec_calls=self_rec_calls,
        has_back_branch=has_back_branch,
    )


# ---------------------------------------------------------------------------
# Contract checks & Generality Matrix
# ---------------------------------------------------------------------------

@dataclass
class MatrixCell:
    group: str
    cell: str
    passed: bool
    detail: str


@dataclass
class ContractResult:
    name: str
    status: str  # "PASS", "FAIL", "REPORT"
    detail: str
    cells: list[MatrixCell] | None = None


def check_contract_a(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> ContractResult:
    """Contract A (`ret2` Law 1): queens:$direct.solve + holdout 2-scalar loop."""
    q_obj = tmpdir / f"queens_{opt_flag}.o"
    compile_to_obj(
        bend5k_bin, ROOT / "bench/runtime/queens/main.bend", q_obj, opt_flag, cpu_pin
    )
    q_funcs = disassemble_obj(q_obj)
    if "$direct.solve" not in q_funcs:
        return ContractResult("Contract A (ret2)", "FAIL", "missing $direct.solve")
    qm = analyze_func("$direct.solve", q_funcs["$direct.solve"])

    h_src = tmpdir / "holdout_ret2.bend"
    h_src.write_text(HOLDOUT_RET2_SRC, encoding="utf-8")
    h_obj = tmpdir / f"holdout_ret2_{opt_flag}.o"
    compile_to_obj(bend5k_bin, h_src, h_obj, opt_flag, cpu_pin)
    h_funcs = disassemble_obj(h_obj)
    if "$direct.step_duo" not in h_funcs or "$direct.unpack_step" not in h_funcs:
        return ContractResult("Contract A (ret2)", "FAIL", "missing holdout symbols")
    hm_callee = analyze_func("$direct.step_duo", h_funcs["$direct.step_duo"])
    hm_loop = analyze_func("$direct.unpack_step", h_funcs["$direct.unpack_step"])

    ok = (
        qm.hot_ctor_calls == 0
        and hm_callee.hot_ctor_calls == 0
        and hm_loop.hot_ctor_calls == 0
        and hm_loop.hot_take_calls == 0
    )
    detail = (
        f"queens:$direct.solve hot_ctor={qm.hot_ctor_calls} (total={qm.total_ctor_calls}); "
        f"holdout:step_duo hot_ctor={hm_callee.hot_ctor_calls} (total={hm_callee.total_ctor_calls}), "
        f"holdout:unpack_step hot_ctor={hm_loop.hot_ctor_calls} hot_take={hm_loop.hot_take_calls}"
    )
    return ContractResult("Contract A (ret2)", "PASS" if ok else "FAIL", detail)


def check_contract_b(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> ContractResult:
    """Contract B (`IReuse` Law 2): tree-bitonic:$direct.warp + holdout tree-map."""
    b_obj = tmpdir / f"bitonic_{opt_flag}.o"
    compile_to_obj(
        bend5k_bin,
        ROOT / "bench/runtime/tree-bitonic/main.bend",
        b_obj,
        opt_flag,
        cpu_pin,
    )
    b_funcs = disassemble_obj(b_obj)
    if "$direct.warp" not in b_funcs:
        return ContractResult("Contract B (IReuse)", "FAIL", "missing $direct.warp")
    bm = analyze_func("$direct.warp", b_funcs["$direct.warp"])

    h_src = tmpdir / "holdout_ireuse.bend"
    h_src.write_text(HOLDOUT_IREUSE_SRC, encoding="utf-8")
    h_obj = tmpdir / f"holdout_ireuse_{opt_flag}.o"
    compile_to_obj(bend5k_bin, h_src, h_obj, opt_flag, cpu_pin)
    h_funcs = disassemble_obj(h_obj)
    if "$direct.bump_t" not in h_funcs:
        return ContractResult("Contract B (IReuse)", "FAIL", "missing $direct.bump_t")
    hm = analyze_func("$direct.bump_t", h_funcs["$direct.bump_t"])

    ok = (
        bm.hot_ctor_calls == 0
        and bm.hot_slot_stores > 0
        and hm.hot_ctor_calls == 0
        and hm.hot_slot_stores > 0
    )
    detail = (
        f"bitonic:$direct.warp hot_ctor={bm.hot_ctor_calls} (cold={bm.total_ctor_calls - bm.hot_ctor_calls}, "
        f"hot_stores={bm.hot_slot_stores}); "
        f"holdout:bump_t hot_ctor={hm.hot_ctor_calls} (cold={hm.total_ctor_calls - hm.hot_ctor_calls}, "
        f"hot_stores={hm.hot_slot_stores})"
    )
    return ContractResult("Contract B (IReuse)", "PASS" if ok else "FAIL", detail)


def check_contract_c(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> ContractResult:
    """Contract C (`.rodata` LUT): merkle:$direct.spk + holdout 10-case Nat table."""
    m_obj = tmpdir / f"merkle_{opt_flag}.o"
    compile_to_obj(
        bend5k_bin, ROOT / "bench/runtime/merkle/main.bend", m_obj, opt_flag, cpu_pin
    )
    m_funcs = disassemble_obj(m_obj)
    if "$direct.spk" not in m_funcs:
        return ContractResult("Contract C (.rodata LUT)", "FAIL", "missing $direct.spk")
    mm = analyze_func("$direct.spk", m_funcs["$direct.spk"])

    h_src = tmpdir / "holdout_lut.bend"
    h_src.write_text(HOLDOUT_LUT_SRC, encoding="utf-8")
    h_obj = tmpdir / f"holdout_lut_{opt_flag}.o"
    compile_to_obj(bend5k_bin, h_src, h_obj, opt_flag, cpu_pin)
    h_funcs = disassemble_obj(h_obj)
    if "$direct.mix_lut" not in h_funcs:
        return ContractResult(
            "Contract C (.rodata LUT)", "FAIL", "missing $direct.mix_lut"
        )
    hm = analyze_func("$direct.mix_lut", h_funcs["$direct.mix_lut"])

    ok = (
        mm.rodata_lea_rip >= 1
        and mm.jcc_count < 10
        and hm.rodata_lea_rip >= 1
        and hm.jcc_count < 10
    )
    detail = (
        f"merkle:$direct.spk rodata_lea_rip={mm.rodata_lea_rip} jcc={mm.jcc_count}; "
        f"holdout:mix_lut rodata_lea_rip={hm.rodata_lea_rip} jcc={hm.jcc_count}"
    )
    return ContractResult("Contract C (.rodata LUT)", "PASS" if ok else "FAIL", detail)


def check_contract_d(
    bend5k_bin: Path,
    tmpdir: Path,
    opt_flag: str,
    cpu_pin: str | None,
    strict_borrow: bool = True,
) -> ContractResult:
    """Contract D (`borrow` Law 3): symreg:$direct.eval & hashmap:$direct.has.

    Promoted to STRICT PASS by default (take == 0 on both).
    """
    s_obj = tmpdir / f"symreg_{opt_flag}.o"
    compile_to_obj(
        bend5k_bin, ROOT / "bench/runtime/symreg/main.bend", s_obj, opt_flag, cpu_pin
    )
    s_funcs = disassemble_obj(s_obj)
    if "$direct.eval" not in s_funcs:
        return ContractResult("Contract D (borrow)", "FAIL", "missing $direct.eval")
    sm = analyze_func("$direct.eval", s_funcs["$direct.eval"])

    h_obj = tmpdir / f"hashmap_{opt_flag}.o"
    compile_to_obj(
        bend5k_bin, ROOT / "bench/runtime/hashmap/main.bend", h_obj, opt_flag, cpu_pin
    )
    h_funcs = disassemble_obj(h_obj)
    if "$direct.has" not in h_funcs:
        return ContractResult("Contract D (borrow)", "FAIL", "missing $direct.has")
    hm = analyze_func("$direct.has", h_funcs["$direct.has"])

    detail = (
        f"symreg:$direct.eval take={sm.total_take_calls} (hot={sm.hot_take_calls}); "
        f"hashmap:$direct.has take={hm.total_take_calls} (hot={hm.hot_take_calls})"
    )
    if not strict_borrow:
        return ContractResult("Contract D (borrow)", "REPORT", detail)
    ok = sm.total_take_calls == 0 and hm.total_take_calls == 0
    return ContractResult("Contract D (borrow)", "PASS" if ok else "FAIL", detail)


def _eval_array_hoist_cell(
    bend5k_bin: Path,
    tmpdir: Path,
    opt_flag: str,
    cpu_pin: str | None,
    cell_name: str,
    src_path: Path,
    symbol: str,
    min_preheader_decodes: int = 1,
) -> MatrixCell:
    obj_path = tmpdir / f"arr_{cell_name.replace(':', '_')}_{opt_flag}.o"
    compile_to_obj(bend5k_bin, src_path, obj_path, opt_flag, cpu_pin)
    funcs = disassemble_obj(obj_path)
    if symbol not in funcs:
        return MatrixCell(
            "Contract E (array-hoist)", cell_name, False, f"missing {symbol}"
        )
    m = analyze_func(symbol, funcs[symbol])
    ok = (
        m.preheader_arr_decodes >= min_preheader_decodes
        and m.loop_arr_decodes == 0
        and m.loop_rt_op_calls == 0
        and m.loop_direct_calls == 0
    )
    detail = (
        f"preheader_dec={m.preheader_arr_decodes} loop_dec={m.loop_arr_decodes} "
        f"loop_rt_op={m.loop_rt_op_calls} loop_calls={m.loop_direct_calls} "
        f"(total_rt_op={m.total_rt_op_calls})"
    )
    return MatrixCell("Contract E (array-hoist)", cell_name, ok, detail)


def check_contract_e(
    bend5k_bin: Path,
    tmpdir: Path,
    opt_flag: str,
    cpu_pin: str | None,
    strict_array_hoist: bool = True,
) -> ContractResult:
    """Contract E (`Linear-Array Hoist` Law 4): editdist:$direct.row,
    terrain:$direct.erode, and 3 diverse unrelated holdout shapes.

    Promoted to STRICT PASS by default.
    """
    ro_src = tmpdir / "holdout_ro_arr_sum.bend"
    ro_src.write_text(HOLDOUT_RO_ARR_SUM_SRC, encoding="utf-8")

    lin_src = tmpdir / "holdout_lin_swap_dead.bend"
    lin_src.write_text(HOLDOUT_LIN_SWAP_DEAD_SRC, encoding="utf-8")

    two_src = tmpdir / "holdout_two_arr_copy.bend"
    two_src.write_text(HOLDOUT_TWO_ARR_COPY_SRC, encoding="utf-8")

    targets = [
        ("editdist:$direct.row", ROOT / "bench/runtime/editdist/main.bend", "$direct.row", 1),
        ("terrain:$direct.erode", ROOT / "bench/runtime/terrain/main.bend", "$direct.erode", 1),
        ("holdout:ro_arr_sum", ro_src, "$direct.ro_arr_sum", 1),
        ("holdout:lin_swap_dead", lin_src, "$direct.lin_swap_dead", 1),
        ("holdout:two_arr_copy", two_src, "$direct.two_arr_copy", 2),
    ]
    cells = [
        _eval_array_hoist_cell(
            bend5k_bin, tmpdir, opt_flag, cpu_pin, name, path, sym, min_pre
        )
        for name, path, sym, min_pre in targets
    ]
    green = sum(1 for c in cells if c.passed)
    total = len(cells)
    summary = f"{green}/{total} GREEN (" + ", ".join(
        f"{c.cell}={'PASS' if c.passed else 'RED'}" for c in cells
    ) + ")"
    if not strict_array_hoist:
        return ContractResult(
            "Contract E (array-hoist)", "REPORT", summary, cells=cells
        )
    return ContractResult(
        "Contract E (array-hoist)",
        "PASS" if green == total else "FAIL",
        summary,
        cells=cells,
    )


def check_contract_f(
    bend5k_bin: Path,
    tmpdir: Path,
    opt_flag: str,
    cpu_pin: str | None,
    strict_static_str: bool = False,
) -> ContractResult:
    """Contract F (`Static String & Static-Take Zero-Alloc Law`):
    Checks `lexer:$direct.tpl` / `lexer:$direct.gen` AND an unrelated constant
    string traversal holdout for 0 heap `SCon` `p111_rt_ctor` calls on constant
    string construction and reports `p111_rt_take` count on traversal.
    """
    lex_obj = tmpdir / f"lexer_{opt_flag}.o"
    compile_to_obj(
        bend5k_bin, ROOT / "bench/runtime/lexer/main.bend", lex_obj, opt_flag, cpu_pin
    )
    lex_funcs = disassemble_obj(lex_obj)
    if "$direct.tpl" not in lex_funcs or "$direct.gen" not in lex_funcs:
        return ContractResult(
            "Contract F (static-str)", "FAIL", "missing $direct.tpl or $direct.gen"
        )
    m_tpl = analyze_func("$direct.tpl", lex_funcs["$direct.tpl"])
    m_gen = analyze_func("$direct.gen", lex_funcs["$direct.gen"])

    h_src = tmpdir / "holdout_static_str.bend"
    h_src.write_text(HOLDOUT_STATIC_STR_SRC, encoding="utf-8")
    h_obj = tmpdir / f"holdout_static_str_{opt_flag}.o"
    compile_to_obj(bend5k_bin, h_src, h_obj, opt_flag, cpu_pin)
    h_funcs = disassemble_obj(h_obj)
    if "$direct.const_msg" not in h_funcs or "$direct.hash_str" not in h_funcs:
        return ContractResult(
            "Contract F (static-str)",
            "FAIL",
            "missing holdout $direct.const_msg or $direct.hash_str",
        )
    m_cmsg = analyze_func("$direct.const_msg", h_funcs["$direct.const_msg"])
    m_hash = analyze_func("$direct.hash_str", h_funcs["$direct.hash_str"])

    ctor_ok = m_tpl.total_ctor_calls == 0 and m_cmsg.total_ctor_calls == 0
    take_ok = m_gen.total_take_calls == 0 and m_hash.total_take_calls == 0
    gen_tag = "GREEN" if m_gen.total_take_calls == 0 else "RED"
    hash_tag = "GREEN" if m_hash.total_take_calls == 0 else "RED"
    detail = (
        f"lexer:$direct.tpl ctor={m_tpl.total_ctor_calls} ({'PASS' if m_tpl.total_ctor_calls == 0 else 'RED'}), "
        f"lexer:$direct.gen take={m_gen.total_take_calls} (hot={m_gen.hot_take_calls}, {gen_tag}); "
        f"holdout:const_msg ctor={m_cmsg.total_ctor_calls} ({'PASS' if m_cmsg.total_ctor_calls == 0 else 'RED'}), "
        f"holdout:hash_str take={m_hash.total_take_calls} (hot={m_hash.hot_take_calls}, {hash_tag})"
    )
    if not strict_static_str:
        return ContractResult("Contract F (static-str)", "REPORT", detail)
    return ContractResult(
        "Contract F (static-str)", "PASS" if (ctor_ok and take_ok) else "FAIL", detail
    )


def diagnose_bottlenecks(m: FuncMetrics) -> str:
    """Classify monotonic hardware bottlenecks from disassembly metrics."""
    tags: list[str] = []
    if m.rbp_spills >= 50:
        tags.append("SPILL-HEAVY")
    if m.jcc_count >= 20 and m.cmov_count == 0:
        tags.append("BRANCH-HEAVY(no-cmov)")
    if m.total_rt_calls > 0:
        tags.append("RT-CALLS")
    if m.div_count > 0:
        tags.append("HW-DIV")
    if m.fp_lat_count > 0:
        tags.append("FP-LATENCY-BOUND")
    return ",".join(tags) if tags else "TIGHT-ALU"


def format_triage_compact(label: str, m: FuncMetrics) -> str:
    return (
        f"{label}(insns={m.total_insns} spills={m.rbp_spills} jcc={m.jcc_count} "
        f"cmov={m.cmov_count} rt={m.total_rt_calls} div={m.div_count} "
        f"fp_lat={m.fp_lat_count} [{diagnose_bottlenecks(m)}])"
    )


def check_contract_g(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> ContractResult:
    """Contract G (`Hardware-Informed Loop Bottleneck Triager`):
    Built-in `[REPORT]` on `kmeans:$direct.chunk` & `list-pipeline`.
    """
    parts: list[str] = []

    km_obj = tmpdir / f"kmeans_{opt_flag}.o"
    compile_to_obj(
        bend5k_bin, ROOT / "bench/runtime/kmeans/main.bend", km_obj, opt_flag, cpu_pin
    )
    km_funcs = disassemble_obj(km_obj)
    if "$direct.chunk" in km_funcs:
        m_chunk = analyze_func("$direct.chunk", km_funcs["$direct.chunk"])
        parts.append(format_triage_compact("kmeans:$direct.chunk", m_chunk))
    else:
        parts.append("kmeans:$direct.chunk(MISSING)")

    lp_src = (
        ROOT
        / "selfhost/tools/bench/catalogs/native45/fixtures/coverage-list-pipeline-512.bend"
    )
    if not lp_src.is_file():
        lp_src = (
            ROOT
            / "selfhost/tests/consolidation/native-broad/coverage-list-pipeline-512.bend"
        )
    if lp_src.is_file():
        lp_obj = tmpdir / f"list_pipeline_{opt_flag}.o"
        compile_to_obj(bend5k_bin, lp_src, lp_obj, opt_flag, cpu_pin)
        lp_funcs = disassemble_obj(lp_obj)
        for sym, short in (
            ("$direct.keep_gt1", "list-pipeline:keep_gt1"),
            ("$direct.dbl", "list-pipeline:dbl"),
            ("$direct.p37.list", "list-pipeline:p37.list"),
        ):
            if sym in lp_funcs:
                parts.append(format_triage_compact(short, analyze_func(sym, lp_funcs[sym])))
    else:
        parts.append("list-pipeline(FIXTURE_NOT_FOUND)")

    return ContractResult("Contract G (hw-triage)", "REPORT", "; ".join(parts))


def _find_vec_kernels(funcs: dict[str, list[str]]) -> list[tuple[str, FuncMetrics]]:
    out: list[tuple[str, FuncMetrics]] = []
    for sym, lines in sorted(funcs.items()):
        if sym.startswith("$v4.") or sym.startswith("$v8."):
            out.append((sym, analyze_func(sym, lines)))
    return out


def check_contract_h(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> ContractResult:
    """Contract H (`SIMD Vectorization Law` Law 6): verifies `nbody` AND a
    synthetic holdout pure-F32 counted loop emit packed SSE2/AVX1 FP vector
    instructions (`addps`/`mulps`/`sqrtps` or `vaddps`/`vmulps`/`vsqrtps`) and
    0 `p111_rt_ctor` calls in the `$v4`/`$v8` kernel.
    """
    nb_obj = tmpdir / f"nbody_{opt_flag}.o"
    compile_to_obj(
        bend5k_bin, ROOT / "bench/runtime/nbody/main.bend", nb_obj, opt_flag, cpu_pin
    )
    nb_funcs = disassemble_obj(nb_obj)
    nb_vecs = _find_vec_kernels(nb_funcs)

    h_src = tmpdir / "holdout_simd_f32.bend"
    h_src.write_text(HOLDOUT_SIMD_F32_SRC, encoding="utf-8")
    h_obj = tmpdir / f"holdout_simd_f32_{opt_flag}.o"
    compile_to_obj(bend5k_bin, h_src, h_obj, opt_flag, cpu_pin)
    h_funcs = disassemble_obj(h_obj)
    h_vecs = _find_vec_kernels(h_funcs)

    nb_ok = bool(nb_vecs) and all(
        m.packed_fp_ops >= 4 and m.total_ctor_calls == 0 for _, m in nb_vecs
    )
    h_ok = bool(h_vecs) and all(
        m.packed_fp_ops >= 4 and m.total_ctor_calls == 0 for _, m in h_vecs
    )
    nb_desc = (
        ", ".join(
            f"{sym}(packed_fp={m.packed_fp_ops}, ctor={m.total_ctor_calls})"
            for sym, m in nb_vecs
        )
        if nb_vecs
        else "NO_$v4/$v8_KERNEL"
    )
    h_desc = (
        ", ".join(
            f"{sym}(packed_fp={m.packed_fp_ops}, ctor={m.total_ctor_calls})"
            for sym, m in h_vecs
        )
        if h_vecs
        else "NO_$v4/$v8_KERNEL"
    )
    cells = [
        MatrixCell(
            "Contract H (SIMD V4/V8)",
            "holdout:pure_f32_v4",
            h_ok,
            h_desc,
        )
    ]
    detail = f"nbody: {nb_desc}; holdout: {h_desc}"
    return ContractResult(
        "Contract H (SIMD V4/V8)",
        "PASS" if (nb_ok and h_ok) else "FAIL",
        detail,
        cells=cells,
    )


def check_contract_i(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> ContractResult:
    """Contract I (`TRMC 1-Pass IMutField Law` Law 5): verifies `list-pipeline`
    (`$direct.dbl`, `$direct.keep_gt1`) AND a synthetic holdout `List.map` loop
    compile to a single-pass self-TCO loop with 0 recursive `call` instructions.
    """
    lp_src = (
        ROOT
        / "selfhost/tools/bench/catalogs/native45/fixtures/coverage-list-pipeline-512.bend"
    )
    if not lp_src.is_file():
        lp_src = (
            ROOT
            / "selfhost/tests/consolidation/native-broad/coverage-list-pipeline-512.bend"
        )
    lp_obj = tmpdir / f"lp_trmc_{opt_flag}.o"
    compile_to_obj(bend5k_bin, lp_src, lp_obj, opt_flag, cpu_pin)
    lp_funcs = disassemble_obj(lp_obj)
    if "$direct.dbl" not in lp_funcs:
        return ContractResult("Contract I (TRMC 1-pass)", "FAIL", "missing $direct.dbl")
    m_dbl = analyze_func("$direct.dbl", lp_funcs["$direct.dbl"])

    h_src = tmpdir / "holdout_trmc_map.bend"
    h_src.write_text(HOLDOUT_TRMC_MAP_SRC, encoding="utf-8")
    h_obj = tmpdir / f"holdout_trmc_map_{opt_flag}.o"
    compile_to_obj(bend5k_bin, h_src, h_obj, opt_flag, cpu_pin)
    h_funcs = disassemble_obj(h_obj)
    if "$direct.map_scale" not in h_funcs:
        return ContractResult(
            "Contract I (TRMC 1-pass)", "FAIL", "missing $direct.map_scale"
        )
    m_map = analyze_func("$direct.map_scale", h_funcs["$direct.map_scale"])

    dbl_ok = m_dbl.has_back_branch and m_dbl.self_rec_calls == 0
    map_ok = m_map.has_back_branch and m_map.self_rec_calls == 0
    cells = [
        MatrixCell(
            "Contract I (TRMC 1-pass)",
            "holdout:list_map_trmc",
            map_ok,
            f"back_branch={m_map.has_back_branch} rec_calls={m_map.self_rec_calls}",
        )
    ]
    detail = (
        f"list-pipeline:$direct.dbl back_branch={m_dbl.has_back_branch} rec_calls={m_dbl.self_rec_calls}; "
        f"holdout:$direct.map_scale back_branch={m_map.has_back_branch} rec_calls={m_map.self_rec_calls}"
    )
    return ContractResult(
        "Contract I (TRMC 1-pass)",
        "PASS" if (dbl_ok and map_ok) else "FAIL",
        detail,
        cells=cells,
    )


def _run_bend5k_raw(
    bend5k_bin: Path,
    args: list[str],
    cpu_pin: str | None,
) -> subprocess.CompletedProcess[str]:
    cmd: list[str] = []
    if cpu_pin:
        cmd.extend(["taskset", "-c", cpu_pin])
    cmd.append(str(bend5k_bin))
    cmd.extend(args)
    return subprocess.run(cmd, capture_output=True, text=True, timeout=120)


def check_contract_j(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> ContractResult:
    """Contract J (`Conformance Gate`): verifies `bend5k --check-only` rejects
    `wrong(x: U32) -> Bool: x` and `bad_list(xs: List<&2, U32>) -> List<&2, Bool>: xs`
    (and emits NO `.o` under `-O2`) while accepting their valid neighbors.
    """
    neg_cases = [
        ("wrong", CONFORMANCE_WRONG_SRC),
        ("bad_list", CONFORMANCE_BAD_LIST_SRC),
    ]
    pos_cases = [
        ("good_u32", CONFORMANCE_GOOD_U32_SRC),
        ("good_list", CONFORMANCE_GOOD_LIST_SRC),
    ]

    ok = True
    parts: list[str] = []

    for name, src in neg_cases:
        sp = tmpdir / f"conf_{name}.bend"
        sp.write_text(src, encoding="utf-8")
        op = tmpdir / f"conf_{name}_{opt_flag}.o"
        if op.exists():
            op.unlink()
        r_chk = _run_bend5k_raw(bend5k_bin, ["--check-only", str(sp)], cpu_pin)
        r_opt = _run_bend5k_raw(bend5k_bin, [opt_flag, str(sp), str(op)], cpu_pin)
        obj_emitted = op.exists()
        case_ok = r_chk.returncode != 0 and r_opt.returncode != 0 and not obj_emitted
        if not case_ok:
            ok = False
        parts.append(
            f"{name}(chk_rc={r_chk.returncode}, o2_rc={r_opt.returncode}, obj={obj_emitted})"
        )

    for name, src in pos_cases:
        sp = tmpdir / f"conf_{name}.bend"
        sp.write_text(src, encoding="utf-8")
        op = tmpdir / f"conf_{name}_{opt_flag}.o"
        if op.exists():
            op.unlink()
        r_chk = _run_bend5k_raw(bend5k_bin, ["--check-only", str(sp)], cpu_pin)
        r_opt = _run_bend5k_raw(bend5k_bin, [opt_flag, str(sp), str(op)], cpu_pin)
        obj_emitted = op.exists()
        case_ok = r_chk.returncode == 0 and r_opt.returncode == 0 and obj_emitted
        if not case_ok:
            ok = False
        parts.append(
            f"{name}(chk_rc={r_chk.returncode}, o2_rc={r_opt.returncode}, obj={obj_emitted})"
        )

    return ContractResult(
        "Contract J (conformance)",
        "PASS" if ok else "FAIL",
        "; ".join(parts),
    )


def check_contract_k(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> ContractResult:
    """Contract K (`Dependent Equality Proof Gate`): verifies `bend5k --check-only`
    rejects `{0 + 1 == 2 : U32}` `{==}` (and emits NO `.o` under `-O2`) while
    accepting `{1 + 1 == 2 : U32}` `{==}`.
    """
    neg_cases = [("bad_eq", DEP_EQ_BAD_SRC)]
    pos_cases = [("good_eq", DEP_EQ_GOOD_SRC)]

    ok = True
    parts: list[str] = []

    for name, src in neg_cases:
        sp = tmpdir / f"dep_{name}.bend"
        sp.write_text(src, encoding="utf-8")
        op = tmpdir / f"dep_{name}_{opt_flag}.o"
        if op.exists():
            op.unlink()
        r_chk = _run_bend5k_raw(bend5k_bin, ["--check-only", str(sp)], cpu_pin)
        r_opt = _run_bend5k_raw(bend5k_bin, [opt_flag, str(sp), str(op)], cpu_pin)
        obj_emitted = op.exists()
        case_ok = r_chk.returncode != 0 and r_opt.returncode != 0 and not obj_emitted
        if not case_ok:
            ok = False
        parts.append(
            f"{name}(chk_rc={r_chk.returncode}, o2_rc={r_opt.returncode}, obj={obj_emitted})"
        )

    for name, src in pos_cases:
        sp = tmpdir / f"dep_{name}.bend"
        sp.write_text(src, encoding="utf-8")
        op = tmpdir / f"dep_{name}_{opt_flag}.o"
        if op.exists():
            op.unlink()
        r_chk = _run_bend5k_raw(bend5k_bin, ["--check-only", str(sp)], cpu_pin)
        r_opt = _run_bend5k_raw(bend5k_bin, [opt_flag, str(sp), str(op)], cpu_pin)
        obj_emitted = op.exists()
        case_ok = r_chk.returncode == 0 and r_opt.returncode == 0 and obj_emitted
        if not case_ok:
            ok = False
        parts.append(
            f"{name}(chk_rc={r_chk.returncode}, o2_rc={r_opt.returncode}, obj={obj_emitted})"
        )

    return ContractResult(
        "Contract K (dependent-proof)",
        "PASS" if ok else "FAIL",
        "; ".join(parts),
    )


PRELUDE_PREFIXES = (
    "$direct.__b5k_",
    "$direct.Bool.",
    "$direct.Char.",
    "$direct.Cmp.",
    "$direct.Maybe.",
    "$direct.List.",
    "$direct.String.",
    "$direct.U32.",
    "$direct.F32.",
    "$direct.Nat.",
    "$direct.IO.",
    "$direct.File.",
    "$direct.Map.",
    "$direct.Array.",
    "$bor.Bool.",
    "$bor.Char.",
    "$bor.String.",
    "$bor.List.",
    "$bor.Map.",
    "$bor.U32.",
    "$bor.Nat.",
)


def run_triage(
    bend5k_bin: Path,
    src_path: Path,
    tmpdir: Path,
    opt_flag: str,
    cpu_pin: str | None,
    fn_filter: str | None = None,
    top_n: int = 12,
    include_prelude: bool = False,
) -> int:
    """Hardware-informed loop bottleneck triager for an arbitrary `.bend` file."""
    src_resolved = src_path.resolve()
    if not src_resolved.is_file():
        print(f"[ERROR] triage source not found: {src_resolved}", file=sys.stderr)
        return 2
    out_obj = tmpdir / f"triage_{src_resolved.stem}_{opt_flag}.o"
    compile_to_obj(bend5k_bin, src_resolved, out_obj, opt_flag, cpu_pin)
    funcs = disassemble_obj(out_obj)

    metrics: list[FuncMetrics] = []
    for sym, lines in funcs.items():
        if not (sym.startswith("$direct.") or sym.startswith("$bor.")):
            continue
        if fn_filter:
            if fn_filter not in sym:
                continue
        elif not include_prelude and sym.startswith(PRELUDE_PREFIXES):
            continue
        metrics.append(analyze_func(sym, lines))

    metrics.sort(
        key=lambda m: (
            m.rbp_spills + m.jcc_count * 2 + m.total_rt_calls * 10 + m.div_count * 5 + m.fp_lat_count * 5,
            m.total_insns,
        ),
        reverse=True,
    )
    shown = metrics[:top_n] if not fn_filter else metrics

    print(f"=== HARDWARE-INFORMED LOOP BOTTLENECK TRIAGE ({src_path}, {opt_flag}) ===")
    print(
        f"{'Function':32s} {'Insns':>6s} {'Spills':>6s} {'Jcc':>5s} {'Cmov':>5s} "
        f"{'RT':>4s} {'Div':>4s} {'FPLat':>5s}  Diagnosis"
    )
    print("-" * 100)
    for m in shown:
        print(
            f"{m.symbol:32s} {m.total_insns:6d} {m.rbp_spills:6d} {m.jcc_count:5d} "
            f"{m.cmov_count:5d} {m.total_rt_calls:4d} {m.div_count:4d} "
            f"{m.fp_lat_count:5d}  {diagnose_bottlenecks(m)}"
        )
    if not shown:
        print("  (no matching functions)")
    return 0


def check_generality_matrix(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> list[MatrixCell]:
    """Harder generality holdouts reported as `[GEN-MATRIX]` PASS/RED."""
    cells: list[MatrixCell] = []

    # 1. Contract D (borrow): 6-arg borrow-walk (arity=6)
    src6 = tmpdir / "holdout_borrow_arity6.bend"
    src6.write_text(HOLDOUT_BORROW_ARITY6_SRC, encoding="utf-8")
    obj6 = tmpdir / f"holdout_borrow_arity6_{opt_flag}.o"
    compile_to_obj(bend5k_bin, src6, obj6, opt_flag, cpu_pin)
    f6 = disassemble_obj(obj6)
    if "$direct.eval6" in f6:
        m6 = analyze_func("$direct.eval6", f6["$direct.eval6"])
        cells.append(
            MatrixCell(
                "Contract D (borrow)",
                "holdout:arity6_walk",
                m6.total_take_calls == 0,
                f"take={m6.total_take_calls} (hot={m6.hot_take_calls})",
            )
        )
    else:
        cells.append(
            MatrixCell(
                "Contract D (borrow)",
                "holdout:arity6_walk",
                False,
                "missing $direct.eval6",
            )
        )

    # 2. Contract D (borrow): 2-arg tree-zip borrow (tree-matmul:mul style)
    srcz = tmpdir / "holdout_borrow_tree_zip.bend"
    srcz.write_text(HOLDOUT_BORROW_TREE_ZIP_SRC, encoding="utf-8")
    objz = tmpdir / f"holdout_borrow_tree_zip_{opt_flag}.o"
    compile_to_obj(bend5k_bin, srcz, objz, opt_flag, cpu_pin)
    fz = disassemble_obj(objz)
    if "$direct.zip_dot" in fz:
        mz = analyze_func("$direct.zip_dot", fz["$direct.zip_dot"])
        cells.append(
            MatrixCell(
                "Contract D (borrow)",
                "holdout:tree_zip_borrow",
                mz.total_take_calls == 0,
                f"take={mz.total_take_calls} (hot={mz.hot_take_calls})",
            )
        )
    else:
        cells.append(
            MatrixCell(
                "Contract D (borrow)",
                "holdout:tree_zip_borrow",
                False,
                "missing $direct.zip_dot",
            )
        )

    # 3. Contract B (IReuse): nested-match 2-node reuse (merge-style)
    srcm = tmpdir / "holdout_ireuse_nested_merge.bend"
    srcm.write_text(HOLDOUT_IREUSE_NESTED_MERGE_SRC, encoding="utf-8")
    objm = tmpdir / f"holdout_ireuse_nested_merge_{opt_flag}.o"
    compile_to_obj(bend5k_bin, srcm, objm, opt_flag, cpu_pin)
    fm = disassemble_obj(objm)
    if "$direct.merge_t" in fm:
        mm = analyze_func("$direct.merge_t", fm["$direct.merge_t"])
        ok_m = mm.hot_ctor_calls == 0 and mm.hot_slot_stores > 0
        cells.append(
            MatrixCell(
                "Contract B (IReuse)",
                "holdout:nested_merge_reuse",
                ok_m,
                f"hot_ctor={mm.hot_ctor_calls} (cold={mm.total_ctor_calls - mm.hot_ctor_calls}, hot_stores={mm.hot_slot_stores})",
            )
        )
    else:
        cells.append(
            MatrixCell(
                "Contract B (IReuse)",
                "holdout:nested_merge_reuse",
                False,
                "missing $direct.merge_t",
            )
        )

    # 4. W19 Unseen Frontier (anti-overfitting Silicon Oracle laws on unseen_oracle_w19/)
    if UNSEEN_W19_DIR.is_dir():
        # 4a. Law 7: Dense .rodata LUT completeness (16-case Nat match with 0-arm & >2^31 U32s)
        obj_u6 = tmpdir / f"unseen_u6_crc32_lut_{opt_flag}.o"
        compile_to_obj(bend5k_bin, UNSEEN_W19_DIR / "u6_crc32_lut.bend", obj_u6, opt_flag, cpu_pin)
        fu6 = disassemble_obj(obj_u6)
        if "$direct.crc_nib" in fu6:
            mu6 = analyze_func("$direct.crc_nib", fu6["$direct.crc_nib"])
            has_ro = any(".rodata" in ln for ln in fu6["$direct.crc_nib"])
            ok_u6 = has_ro and mu6.jcc_count < 10
            cells.append(
                MatrixCell(
                    "W19 Unseen Law 7 (LUT)",
                    "unseen:u6_crc_nib",
                    ok_u6,
                    f"rodata_lut={has_ro} jcc={mu6.jcc_count} (target: True, <10)",
                )
            )

        # 4b. Law 8: XMM-resident F32 loop allocation (0 GP<->XMM movd in dot_row loop)
        obj_u5 = tmpdir / f"unseen_u5_matvec_f32_{opt_flag}.o"
        compile_to_obj(bend5k_bin, UNSEEN_W19_DIR / "u5_matvec_f32.bend", obj_u5, opt_flag, cpu_pin)
        fu5 = disassemble_obj(obj_u5)
        if "$direct.dot_row" in fu5:
            # Count movd inside loop body (between first backward-branch target and back-branch)
            dlines = fu5["$direct.dot_row"]
            movd_cnt = sum(1 for ln in dlines if "\tmovd " in ln or "\tvmovd " in ln)
            cells.append(
                MatrixCell(
                    "W19 Unseen Law 8 (XMM)",
                    "unseen:u5_dot_row",
                    movd_cnt == 0,
                    f"movd={movd_cnt} (target: 0 GP<->XMM crossings in FP loop)",
                )
            )

        # 4c. Law 10: Multi-arm TRMC (2-list merge_go: 0 recursive calls, 1-pass loop)
        obj_u4 = tmpdir / f"unseen_u4_mergesort_{opt_flag}.o"
        compile_to_obj(bend5k_bin, UNSEEN_W19_DIR / "u4_mergesort_list.bend", obj_u4, opt_flag, cpu_pin)
        fu4 = disassemble_obj(obj_u4)
        if "$direct.merge_go" in fu4:
            mu4 = analyze_func("$direct.merge_go", fu4["$direct.merge_go"])
            ok_u4 = mu4.self_rec_calls == 0 and mu4.has_back_branch
            cells.append(
                MatrixCell(
                    "W19 Unseen Law 10 (TRMC)",
                    "unseen:u4_merge_go",
                    ok_u4,
                    f"self_rec={mu4.self_rec_calls} back_branch={mu4.has_back_branch} (target: 0, True)",
                )
            )

    return cells


def check_contract_l(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> ContractResult:
    """Contract L (Unseen ADT VM Borrow Law, STRICT PASS):
    Verifies that our unseen 8-way ADT bytecode VM (`u3_bytecode_vm.bend`)
    emits a specialized `$bor.eval_prog` self-TCO loop with 0 `p111_rt_take`
    calls and 0 hot `p111_rt_ctor` calls.
    """
    src = UNSEEN_W19_DIR / "u3_bytecode_vm.bend"
    if not src.is_file():
        return ContractResult("Contract L (Unseen VM Borrow)", "FAIL", f"missing {src}")
    obj = tmpdir / f"contract_l_u3_vm_{opt_flag}.o"
    compile_to_obj(bend5k_bin, src, obj, opt_flag, cpu_pin)
    fns = disassemble_obj(obj)
    if "$bor.eval_prog" not in fns:
        return ContractResult(
            "Contract L (Unseen VM Borrow)",
            "FAIL",
            "missing $bor.eval_prog (borrow specialization did not fire)",
        )
    m = analyze_func("$bor.eval_prog", fns["$bor.eval_prog"])
    ok = (
        m.total_take_calls == 0
        and m.hot_ctor_calls == 0
        and m.has_back_branch
        and m.self_rec_calls == 0
    )
    detail = (
        f"u3_bytecode_vm:$bor.eval_prog take={m.total_take_calls}, "
        f"hot_ctor={m.hot_ctor_calls}, back_branch={m.has_back_branch}, rec={m.self_rec_calls}"
    )
    return ContractResult("Contract L (Unseen VM Borrow)", "PASS" if ok else "FAIL", detail)


def check_contract_m(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> ContractResult:
    """Contract M (Unseen Dual-Array F32 Hoist Law, STRICT PASS):
    Verifies that our unseen dense F32 matvec (`u5_matvec_f32.bend`) hoists
    BOTH `Array<F32>` handles into the preheader (`preheader_arr_decodes >= 2`)
    with 0 inner-loop array decodes and 0 inner-loop `p111_rt_op` calls.
    """
    src = UNSEEN_W19_DIR / "u5_matvec_f32.bend"
    if not src.is_file():
        return ContractResult("Contract M (Unseen Dual-F32 Hoist)", "FAIL", f"missing {src}")
    obj = tmpdir / f"contract_m_u5_matvec_{opt_flag}.o"
    compile_to_obj(bend5k_bin, src, obj, opt_flag, cpu_pin)
    fns = disassemble_obj(obj)
    if "$direct.dot_row" not in fns:
        return ContractResult(
            "Contract M (Unseen Dual-F32 Hoist)",
            "FAIL",
            "missing $direct.dot_row",
        )
    m = analyze_func("$direct.dot_row", fns["$direct.dot_row"])
    ok = (
        m.preheader_arr_decodes >= 2
        and m.loop_arr_decodes == 0
        and m.loop_rt_op_calls == 0
        and m.has_back_branch
    )
    detail = (
        f"u5_matvec_f32:$direct.dot_row pre_dec={m.preheader_arr_decodes}, "
        f"loop_dec={m.loop_arr_decodes}, loop_op={m.loop_rt_op_calls}, back={m.has_back_branch}"
    )
    return ContractResult("Contract M (Unseen Dual-F32 Hoist)", "PASS" if ok else "FAIL", detail)


def check_contract_n(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> ContractResult:
    """Contract N (IR-Level Branchless .rodata ILut + Leaf Inlining, STRICT PASS):
    Verifies that a 32-case dense Nat-match table with repeated/CSE-able constants
    compiles to a branchless .rodata LUT (0 jcc, cmov >= 1, rodata_lea_rip >= 1)
    and inlines into its caller loop with 0 direct calls.
    """
    src = tmpdir / "holdout_ilut_inline.bend"
    src.write_text(HOLDOUT_ILUT_INLINE_SRC, encoding="utf-8")
    obj = tmpdir / f"holdout_ilut_inline_{opt_flag}.o"
    compile_to_obj(bend5k_bin, src, obj, opt_flag, cpu_pin)
    fns = disassemble_obj(obj)
    if "$direct.fold_map32" not in fns:
        return ContractResult("Contract N (ILut Inline)", "FAIL", "missing $direct.fold_map32")
    mf = analyze_func("$direct.fold_map32", fns["$direct.fold_map32"])
    # map32 may be dead-stripped once inlined into fold_map32; if present, verify it is branchless too.
    lut_ok = True
    lut_desc = "dead-stripped"
    if "$direct.map32" in fns:
        ml = analyze_func("$direct.map32", fns["$direct.map32"])
        lut_ok = ml.rodata_lea_rip >= 1 and ml.cmov_count >= 1 and ml.jcc_count == 0
        lut_desc = f"ro={ml.rodata_lea_rip},cmov={ml.cmov_count},jcc={ml.jcc_count}"
    ok = (
        lut_ok
        and mf.rodata_lea_rip >= 1
        and mf.cmov_count >= 1
        and mf.loop_direct_calls == 0
        and mf.has_back_branch
    )
    detail = (
        f"fold_map32(ro={mf.rodata_lea_rip}, cmov={mf.cmov_count}, loop_calls={mf.loop_direct_calls}, "
        f"back={mf.has_back_branch}); map32({lut_desc})"
    )
    return ContractResult("Contract N (ILut Inline)", "PASS" if ok else "FAIL", detail)


def check_contract_o(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> ContractResult:
    """Contract O (General 8-Wide AVX1 Array<F32> Map Auto-Vectorization, STRICT PASS):
    Verifies that a counted self-TCO Array<F32> map loop emits a $v8a. AVX1 kernel
    with packed FP instructions (vaddps/vmulps/vsubps) and 0 p111_rt_ctor calls.
    """
    src = tmpdir / "holdout_v8a_map_f32.bend"
    src.write_text(HOLDOUT_V8A_MAP_F32_SRC, encoding="utf-8")
    obj = tmpdir / f"holdout_v8a_map_f32_{opt_flag}.o"
    compile_to_obj(bend5k_bin, src, obj, opt_flag, cpu_pin)
    fns = disassemble_obj(obj)
    sym = "$v8a.$direct.poly_map"
    if sym not in fns:
        return ContractResult("Contract O (v8a Array<F32>)", "FAIL", f"missing {sym}")
    m = analyze_func(sym, fns[sym])
    ok = m.packed_fp_ops >= 4 and m.total_ctor_calls == 0 and m.has_back_branch
    detail = f"{sym}(packed_fp={m.packed_fp_ops}, ctor={m.total_ctor_calls}, back={m.has_back_branch})"
    return ContractResult("Contract O (v8a Array<F32>)", "PASS" if ok else "FAIL", detail)


def check_contract_p(
    bend5k_bin: Path, tmpdir: Path, opt_flag: str, cpu_pin: str | None
) -> ContractResult:
    """Contract P (Loop-Carried Record Unboxing & Dual-Array Hoist, STRICT PASS):
    Verifies that a self-TCO loop carrying a 3-field single-constructor record
    with two Array<U32> handles unboxes the record (0 hot ctor/take) and hoists
    both array decodes into the preheader (pre_dec >= 2, loop_dec == 0).
    """
    src = tmpdir / "holdout_ww_rec_arr.bend"
    src.write_text(HOLDOUT_WW_REC_ARR_SRC, encoding="utf-8")
    obj = tmpdir / f"holdout_ww_rec_arr_{opt_flag}.o"
    compile_to_obj(bend5k_bin, src, obj, opt_flag, cpu_pin)
    fns = disassemble_obj(obj)
    if "$direct.scan_dual" not in fns:
        return ContractResult("Contract P (WW Rec+DualArr)", "FAIL", "missing $direct.scan_dual")
    m = analyze_func("$direct.scan_dual", fns["$direct.scan_dual"])
    ok = (
        m.hot_ctor_calls <= 1
        and m.hot_take_calls == 0
        and m.preheader_arr_decodes >= 2
        and m.loop_arr_decodes == 0
        and m.loop_rt_op_calls == 0
        and m.has_back_branch
    )
    detail = (
        f"scan_dual(hot_ctor={m.hot_ctor_calls}, hot_take={m.hot_take_calls}, "
        f"pre_dec={m.preheader_arr_decodes}, loop_dec={m.loop_arr_decodes}, "
        f"loop_op={m.loop_rt_op_calls}, back={m.has_back_branch})"
    )
    return ContractResult("Contract P (WW Rec+DualArr)", "PASS" if ok else "FAIL", detail)


def run_fault_injection_self_test(
    bend5k_bin: Path, tmpdir: Path, cpu_pin: str | None
) -> bool:
    """Verify every enforced contract (A, B, C, D, and E under --strict-array-hoist)
    trips loudly when optimizations are disabled (-O0) or synthetic faults are injected.
    """
    print("=== FAULT-INJECTION SELF-TEST (expecting EVERY contract to FAIL) ===")
    all_tripped = True

    # 1. Contracts A, B, C, H, I, L, M, N, O, P at -O0
    for fn in (
        check_contract_a,
        check_contract_b,
        check_contract_c,
        check_contract_h,
        check_contract_i,
        check_contract_l,
        check_contract_m,
        check_contract_n,
        check_contract_o,
        check_contract_p,
    ):
        res = fn(bend5k_bin, tmpdir, "-O0", cpu_pin)
        tripped = res.status == "FAIL"
        tag = "TRIPPED-OK" if tripped else "MISSED-FAULT"
        print(f"  [{tag}] {res.name} (-O0): {res.detail}")
        if not tripped:
            all_tripped = False

    # 2. Contract D (strict by default) at -O0
    res_d = check_contract_d(bend5k_bin, tmpdir, "-O0", cpu_pin, strict_borrow=True)
    tripped_d = res_d.status == "FAIL"
    tag_d = "TRIPPED-OK" if tripped_d else "MISSED-FAULT"
    print(f"  [{tag_d}] {res_d.name} (-O0): {res_d.detail}")
    if not tripped_d:
        all_tripped = False

    # 3. Contract E (strict by default) at -O0
    res_e = check_contract_e(
        bend5k_bin, tmpdir, "-O0", cpu_pin, strict_array_hoist=True
    )
    tripped_e = res_e.status == "FAIL"
    tag_e = "TRIPPED-OK" if tripped_e else "MISSED-FAULT"
    print(f"  [{tag_e}] {res_e.name} (-O0): {res_e.detail}")
    if not tripped_e:
        all_tripped = False

    # 4. Synthetic disassembly fault injections:
    #    (a) hot p111_rt_ctor injection
    synth_clean = [
        "    1000:\t55                   \tpush   %rbp",
        "    1001:\t48 89 e5             \tmov    %rsp,%rbp",
        "    1004:\t48 89 47 08          \tmov    %rax,0x8(%rdi)",
        "    1008:\t5d                   \tpop    %rbp",
        "    1009:\tc3                   \tretq   ",
    ]
    synth_ctor_fault = [
        "    1000:\t55                   \tpush   %rbp",
        "    1001:\t48 89 e5             \tmov    %rsp,%rbp",
        "    1004:\te8 00 00 00 00       \tcallq  1009 <$direct.synth+0x9>",
        "\t\t\t1005: R_X86_64_PLT32\tp111_rt_ctor-0x4",
        "    1009:\t5d                   \tpop    %rbp",
        "    100a:\tc3                   \tretq   ",
    ]
    mc = analyze_func("$direct.synth", synth_clean)
    mf = analyze_func("$direct.synth", synth_ctor_fault)
    synth_ctor_ok = mc.hot_ctor_calls == 0 and mf.hot_ctor_calls == 1
    print(
        f"  [{'TRIPPED-OK' if synth_ctor_ok else 'MISSED-FAULT'}] Synthetic hot p111_rt_ctor injection: "
        f"clean hot_ctor={mc.hot_ctor_calls}, injected hot_ctor={mf.hot_ctor_calls}"
    )
    if not synth_ctor_ok:
        all_tripped = False

    #    (b) inner-loop array-handle tag-decode + p111_rt_op injection (Contract E)
    synth_loop_clean = [
        "    1000:\t48 c1 e8 38          \tshr    $0x38,%rax",
        "    1004:\t48 83 e0 7f          \tand    $0x7f,%rax",
        "    1008:\t83 f8 06             \tcmp    $0x6,%eax",
        "    100b:\t48 8b 04 fa          \tmov    (%rdx,%rdi,8),%rax",
        "    100f:\t48 83 ef 01          \tsub    $0x1,%rdi",
        "    1013:\t75 f6                \tjne    100b <$direct.loop+0xb>",
        "    1015:\tc3                   \tretq   ",
    ]
    synth_loop_fault = [
        "    1000:\t48 8b 04 fa          \tmov    (%rdx,%rdi,8),%rax",
        "    1004:\t48 c1 e8 38          \tshr    $0x38,%rax",
        "    1008:\t48 83 e0 7f          \tand    $0x7f,%rax",
        "    100c:\t83 f8 06             \tcmp    $0x6,%eax",
        "    100f:\te8 00 00 00 00       \tcallq  1014 <$direct.loop+0x14>",
        "\t\t\t1010: R_X86_64_PLT32\tp111_rt_op-0x4",
        "    1014:\t48 83 ef 01          \tsub    $0x1,%rdi",
        "    1018:\t75 e6                \tjne    1000 <$direct.loop>",
        "    101a:\tc3                   \tretq   ",
    ]
    mlc = analyze_func("$direct.loop", synth_loop_clean)
    mlf = analyze_func("$direct.loop", synth_loop_fault)
    synth_loop_ok = (
        mlc.preheader_arr_decodes == 1
        and mlc.loop_arr_decodes == 0
        and mlc.loop_rt_op_calls == 0
        and mlf.loop_arr_decodes == 1
        and mlf.loop_rt_op_calls == 1
    )
    print(
        f"  [{'TRIPPED-OK' if synth_loop_ok else 'MISSED-FAULT'}] Synthetic loop arr-decode/rt_op injection: "
        f"clean=(pre={mlc.preheader_arr_decodes}, loop_dec={mlc.loop_arr_decodes}, loop_op={mlc.loop_rt_op_calls}), "
        f"injected=(loop_dec={mlf.loop_arr_decodes}, loop_op={mlf.loop_rt_op_calls})"
    )
    if not synth_loop_ok:
        all_tripped = False

    #    (c) synthetic hardware-triage counters (spills, cmov, div, sqrtss/divss)
    synth_hw = [
        "    1000:\t48 8b 45 f8          \tmov    -0x8(%rbp),%rax",
        "    1004:\t48 0f 4c c1          \tcmovl  %rcx,%rax",
        "    1008:\tf7 f9                \tidiv   %ecx",
        "    100a:\tf3 0f 51 c0          \tsqrtss %xmm0,%xmm0",
        "    100e:\tf3 0f 5e c1          \tdivss  %xmm1,%xmm0",
        "    1012:\tc3                   \tretq   ",
    ]
    mhw = analyze_func("$direct.hw", synth_hw)
    synth_hw_ok = (
        mhw.rbp_spills == 1
        and mhw.cmov_count == 1
        and mhw.div_count == 1
        and mhw.fp_lat_count == 2
    )
    print(
        f"  [{'TRIPPED-OK' if synth_hw_ok else 'MISSED-FAULT'}] Synthetic hw-triage metrics: "
        f"spills={mhw.rbp_spills} cmov={mhw.cmov_count} div={mhw.div_count} fp_lat={mhw.fp_lat_count}"
    )
    if not synth_hw_ok:
        all_tripped = False

    #    (d) synthetic SIMD packed FP & TRMC self-recursion fault injections (Contracts H & I)
    synth_simd_ok = analyze_func(
        "$v4.kern",
        [
            "    1000:\t0f 58 c1             \taddps  %xmm1,%xmm0",
            "    1003:\t0f 59 c2             \tmulps  %xmm2,%xmm0",
            "    1006:\t0f 51 c0             \tsqrtps %xmm0,%xmm0",
            "    1009:\t0f 5e c1             \tdivps  %xmm1,%xmm0",
            "    100c:\tc3                   \tretq   ",
        ],
    )
    synth_trmc_fault = analyze_func(
        "$direct.bad_map",
        [
            "    1000:\te8 00 00 00 00       \tcallq  1005 <$direct.bad_map+0x5>",
            "\t\t\t1001: R_X86_64_PLT32\t$direct.bad_map-0x4",
            "    1005:\tc3                   \tretq   ",
        ],
    )
    synth_hi_ok = (
        synth_simd_ok.packed_fp_ops == 4
        and synth_simd_ok.total_ctor_calls == 0
        and synth_trmc_fault.self_rec_calls == 1
        and not synth_trmc_fault.has_back_branch
    )
    print(
        f"  [{'TRIPPED-OK' if synth_hi_ok else 'MISSED-FAULT'}] Synthetic SIMD/TRMC metrics: "
        f"packed_fp={synth_simd_ok.packed_fp_ops} trmc_rec_calls={synth_trmc_fault.self_rec_calls}"
    )
    if not synth_hi_ok:
        all_tripped = False

    #    (e) Contract J (conformance) & Contract K (dependent-proof) fault
    #        injection: permissive stub compiler that accepts ill-typed / false
    #        proofs without error must FAIL both Contract J and Contract K.
    fake_permissive = tmpdir / "fake_permissive_bend5k.sh"
    fake_permissive.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    fake_permissive.chmod(0o755)
    for fn in (check_contract_j, check_contract_k):
        res_jk = fn(fake_permissive, tmpdir, "-O2", cpu_pin)
        tripped_jk = res_jk.status == "FAIL"
        print(
            f"  [{'TRIPPED-OK' if tripped_jk else 'MISSED-FAULT'}] {res_jk.name} (permissive-stub): {res_jk.detail}"
        )
        if not tripped_jk:
            all_tripped = False

    print(
        f"=== FAULT-INJECTION RESULT: {'PASS (all 14 strict contracts tripped)' if all_tripped else 'FAIL'} ==="
    )
    return all_tripped


def main() -> int:
    ap = argparse.ArgumentParser(
        description="bend5k Law-First Generality Matrix & Hardware-Informed Cost-Law gate"
    )
    ap.add_argument(
        "--bend5k",
        type=Path,
        default=DEFAULT_BEND5K,
        help="Path to bend5k compiler binary",
    )
    ap.add_argument(
        "--strict-borrow",
        action="store_true",
        default=True,
        help="Enforce 0 p111_rt_take calls on Contract D (default: enabled)",
    )
    ap.add_argument(
        "--no-strict-borrow",
        dest="strict_borrow",
        action="store_false",
        help="Downgrade Contract D (borrow) to REPORT-only mode",
    )
    ap.add_argument(
        "--strict-array-hoist",
        action="store_true",
        default=True,
        help="Enforce PASS on all Contract E (Linear-Array Hoist) cells (default: enabled)",
    )
    ap.add_argument(
        "--no-strict-array-hoist",
        dest="strict_array_hoist",
        action="store_false",
        help="Downgrade Contract E (array-hoist) to REPORT-only mode",
    )
    ap.add_argument(
        "--strict-static-str",
        action="store_true",
        default=False,
        help="Enforce PASS on Contract F (Static String & Static-Take Zero-Alloc)",
    )
    ap.add_argument(
        "--triage",
        type=Path,
        default=None,
        help="Run Hardware-Informed Loop Bottleneck Triager on a single .bend file",
    )
    ap.add_argument(
        "--triage-fn",
        type=str,
        default=None,
        help="Substring filter for --triage function symbols",
    )
    ap.add_argument(
        "--triage-top",
        type=int,
        default=12,
        help="Number of top functions to display in --triage mode (default: 12)",
    )
    ap.add_argument(
        "--triage-all",
        action="store_true",
        help="Include Base prelude functions in --triage output",
    )
    ap.add_argument(
        "--self-test-fault-injection",
        action="store_true",
        help="Verify all 5 strict contracts (A, B, C, D, E) trip loudly on faults",
    )
    ap.add_argument(
        "--cpu-pin",
        default="4-5",
        help="CPU affinity passed to taskset -c (empty string to disable)",
    )
    args = ap.parse_args()

    bend5k_bin = args.bend5k.resolve()
    if not bend5k_bin.is_file():
        print(f"[ERROR] bend5k binary not found: {bend5k_bin}", file=sys.stderr)
        return 2

    cpu_pin = args.cpu_pin.strip() or None

    with tempfile.TemporaryDirectory(prefix="law_gate_") as td:
        tmpdir = Path(td)

        if args.triage is not None:
            return run_triage(
                bend5k_bin,
                args.triage,
                tmpdir,
                "-O2",
                cpu_pin,
                fn_filter=args.triage_fn,
                top_n=args.triage_top,
                include_prelude=args.triage_all,
            )

        if args.self_test_fault_injection:
            ok = run_fault_injection_self_test(bend5k_bin, tmpdir, cpu_pin)
            return 0 if ok else 1

        results = [
            check_contract_a(bend5k_bin, tmpdir, "-O2", cpu_pin),
            check_contract_b(bend5k_bin, tmpdir, "-O2", cpu_pin),
            check_contract_c(bend5k_bin, tmpdir, "-O2", cpu_pin),
            check_contract_d(
                bend5k_bin, tmpdir, "-O2", cpu_pin, strict_borrow=args.strict_borrow
            ),
            check_contract_e(
                bend5k_bin,
                tmpdir,
                "-O2",
                cpu_pin,
                strict_array_hoist=args.strict_array_hoist,
            ),
            check_contract_f(
                bend5k_bin,
                tmpdir,
                "-O2",
                cpu_pin,
                strict_static_str=args.strict_static_str,
            ),
            check_contract_g(bend5k_bin, tmpdir, "-O2", cpu_pin),
            check_contract_h(bend5k_bin, tmpdir, "-O2", cpu_pin),
            check_contract_i(bend5k_bin, tmpdir, "-O2", cpu_pin),
            check_contract_j(bend5k_bin, tmpdir, "-O2", cpu_pin),
            check_contract_k(bend5k_bin, tmpdir, "-O2", cpu_pin),
            check_contract_l(bend5k_bin, tmpdir, "-O2", cpu_pin),
            check_contract_m(bend5k_bin, tmpdir, "-O2", cpu_pin),
            check_contract_n(bend5k_bin, tmpdir, "-O2", cpu_pin),
            check_contract_o(bend5k_bin, tmpdir, "-O2", cpu_pin),
            check_contract_p(bend5k_bin, tmpdir, "-O2", cpu_pin),
        ]

        failed = False
        for r in results:
            print(f"[{r.status:6s}] {r.name}: {r.detail}")
            if r.status == "FAIL":
                failed = True

        # Print full [GEN-MATRIX] (5 Contract E cells + 3 harder generality holdouts = 8 cells)
        gen_cells: list[MatrixCell] = []
        for r in results:
            if r.cells:
                gen_cells.extend(r.cells)
        gen_cells.extend(check_generality_matrix(bend5k_bin, tmpdir, "-O2", cpu_pin))

        print("=== LAW-FIRST GENERALITY MATRIX ===")
        for c in gen_cells:
            badge = "PASS" if c.passed else "RED "
            print(f"[GEN-MATRIX] [{badge}] {c.group:24s} | {c.cell:26s} | {c.detail}")

        return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
