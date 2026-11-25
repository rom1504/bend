#!/usr/bin/env python3
"""Executable Law-First Generality Matrix & machine-code contract gate for bend5k.

Links the formal proofs in `selfhost/bend5k/laws/ownership_laws.bend` to real
x86-64 ELF `.o` output from `bend5k`:
  - Contract A (`ret2` Law 1): 0 hot `p111_rt_ctor` calls in `queens:$direct.solve`
    AND 0 total hot `p111_rt_ctor` calls in an unrelated holdout 2-scalar loop.
  - Contract B (`IReuse` Law 2): in-place unique-slot reuse active (0 hot
    `p111_rt_ctor` calls, direct slot stores, slow-path-only fallback) in
    `tree-bitonic:$direct.warp` AND an unrelated holdout tree-map workload.
  - Contract C (`.rodata` LUT): `.rodata` RIP-relative indexed table lookup
    (`lea ...(%rip)` + `.rodata` reloc, <10 conditional branches) in
    `merkle:$direct.spk` AND an unrelated holdout 10-case `Nat`-match table.
  - Contract D (`borrow` Law 3): STRICT PASS by default — enforces 0
    `p111_rt_take` calls in `symreg:$direct.eval` and `hashmap:$direct.has`.
  - Contract E (`Linear-Array Hoist` Law 4): checks `editdist:$direct.row`,
    `terrain:$direct.erode`, plus 3 diverse unrelated holdout shapes
    (`holdout:ro_arr_sum`, `holdout:lin_swap_dead`, `holdout:two_arr_copy`),
    asserting preheader handle hoist (`preheader_decodes >= 1`) and 0 inner-loop
    `p111_rt_op` / array-handle tag-decode / uninlined helper calls. Reported as
    `[GEN-MATRIX]` PASS/RED by default, and enforced strictly when
    `--strict-array-hoist` is passed.
  - Harder Generality Matrix (`[GEN-MATRIX]` PASS/RED):
    - Contract D (borrow): 6-arg borrow-walk (`arity=6`), 2-arg tree-zip borrow.
    - Contract B (IReuse): nested-match 2-node reuse (`merge`-style).

Run with `--self-test-fault-injection` to verify that every enforced contract
(`A`, `B`, `C`, `D`, and `E` under `--strict-array-hoist`) fails loudly when
optimizations are disabled (`-O0`) or faults are injected.
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


# ---------------------------------------------------------------------------
# Disassembly & hot/cold/loop analysis
# ---------------------------------------------------------------------------

INSN_RE = re.compile(r"^\s*([0-9a-f]+):\s+(?:[0-9a-f]{2}\s+)+\s*(.+)$")
RELOC_RE = re.compile(r"^\s*([0-9a-f]+):\s+R_X86_64_\w+\s+(.+)$")
JCC_RE = re.compile(r"^(je|jne|jg|jge|jl|jle|ja|jae|jb|jbe|js|jns|jo|jno)\b")
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
            elif "$direct." in target and in_loop:
                if not target.startswith(symbol):
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
    strict_array_hoist: bool = False,
) -> ContractResult:
    """Contract E (`Linear-Array Hoist` Law 4): editdist:$direct.row,
    terrain:$direct.erode, and 3 diverse unrelated holdout shapes.
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

    return cells


def run_fault_injection_self_test(
    bend5k_bin: Path, tmpdir: Path, cpu_pin: str | None
) -> bool:
    """Verify every enforced contract (A, B, C, D, and E under --strict-array-hoist)
    trips loudly when optimizations are disabled (-O0) or synthetic faults are injected.
    """
    print("=== FAULT-INJECTION SELF-TEST (expecting EVERY contract to FAIL) ===")
    all_tripped = True

    # 1. Contracts A, B, C at -O0
    for fn in (check_contract_a, check_contract_b, check_contract_c):
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

    # 3. Contract E under --strict-array-hoist at -O0
    res_e = check_contract_e(
        bend5k_bin, tmpdir, "-O0", cpu_pin, strict_array_hoist=True
    )
    tripped_e = res_e.status == "FAIL"
    tag_e = "TRIPPED-OK" if tripped_e else "MISSED-FAULT"
    print(f"  [{tag_e}] {res_e.name} (-O0 --strict-array-hoist): {res_e.detail}")
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

    print(
        f"=== FAULT-INJECTION RESULT: {'PASS (all contracts tripped)' if all_tripped else 'FAIL'} ==="
    )
    return all_tripped


def main() -> int:
    ap = argparse.ArgumentParser(
        description="bend5k Law-First Generality Matrix & machine-code contract gate"
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
        help="Enforce PASS on all Contract E (Linear-Array Hoist) cells",
    )
    ap.add_argument(
        "--self-test-fault-injection",
        action="store_true",
        help="Verify every enforced contract (A, B, C, D, E) trips loudly on faults",
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
        ]

        failed = False
        for r in results:
            print(f"[{r.status:6s}] {r.name}: {r.detail}")
            if r.status == "FAIL":
                failed = True

        # Print full [GEN-MATRIX] (Contract E cells + harder generality holdouts)
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
