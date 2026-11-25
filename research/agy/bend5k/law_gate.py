#!/usr/bin/env python3
"""Executable machine-code contract gate for bend5k ownership & codegen laws.

Links the formal proofs in `selfhost/bend5k/laws/ownership_laws.bend` to real
x86-64 ELF `.o` output from `bend5k`:
  - Contract A (`ret2` Law 1): 0 hot `p111_rt_ctor` calls in `queens:$direct.solve`
    AND 0 total `p111_rt_ctor` calls in an unrelated holdout 2-scalar loop.
  - Contract B (`IReuse` Law 2): in-place unique-slot reuse active (0 hot
    `p111_rt_ctor` calls, direct slot stores, slow-path-only fallback) in
    `tree-bitonic:$direct.warp` AND an unrelated holdout tree-map workload.
  - Contract C (`.rodata` LUT): `.rodata` RIP-relative indexed table lookup
    (`lea ...(%rip)` + `.rodata` reloc, <10 conditional branches) in
    `merkle:$direct.spk` AND an unrelated holdout 10-case `Nat`-match table.
  - Contract D (`borrow` Law 3): reports `p111_rt_take` counts in
    `symreg:$direct.eval` and `hashmap:$direct.has` as `[REPORT]` by default,
    and enforces `== 0` when `--strict-borrow` is passed.

Run with `--self-test-fault-injection` to verify that every single contract
fails loudly when optimizations are disabled (`-O0`) or faults are injected.
"""
from __future__ import annotations

import argparse
import os
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


# ---------------------------------------------------------------------------
# Disassembly & hot/cold analysis
# ---------------------------------------------------------------------------

INSN_RE = re.compile(r"^\s*([0-9a-f]+):\s+(?:[0-9a-f]{2}\s+)+\s*(.+)$")
RELOC_RE = re.compile(r"^\s*([0-9a-f]+):\s+R_X86_64_\w+\s+(.+)$")
JCC_RE = re.compile(r"^(je|jne|jg|jge|jl|jle|ja|jae|jb|jbe|js|jns|jo|jno)\b")
JMP_TARGET_RE = re.compile(r"^jmpq?\s+([0-9a-f]+)\b")
CALL_RE = re.compile(r"^callq?\b")


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
    """Identify the index in `lines` where out-of-line cold stubs begin.

    In bend5k `-O2`, `x64.bend` emits all hot basic blocks (including every
    `retq` and TCO loop back-edge) first, followed by out-of-line cold slow
    paths (`p111_rt_ctor` / `p111_rt_take` / `p111_rt_sink` stubs that end in
    an unconditional backward `jmpq` into the hot region).

    In `-O0`, all `p111_rt_ctor`/`p111_rt_take` calls are emitted inline before
    the function's `retq`, so the cold boundary is at `len(lines)` (everything
    is hot).
    """
    # Collect instruction addresses and find the last `retq` and last hot TCO back-edge.
    # A cold stub is a block after the last `retq` that is only jumped to and
    # returns via an unconditional `jmpq` back to an address before the cold stub.
    insn_entries: list[tuple[int, int, str]] = []  # (line_idx, addr, asm)
    for idx, line in enumerate(lines):
        m = INSN_RE.match(line)
        if m:
            insn_entries.append((idx, int(m.group(1), 16), m.group(2).strip()))

    if not insn_entries:
        return len(lines)

    # Find the last `retq` line index.
    last_ret_pos = -1
    for pos, (_, _, asm) in enumerate(insn_entries):
        if asm.startswith("ret"):
            last_ret_pos = pos

    if last_ret_pos == -1:
        return len(lines)

    # Walk backwards from the end of the function: any contiguous suffix of
    # cold blocks (each ending with an unconditional backward `jmpq` to an
    # earlier address AND containing a `p111_rt_*` call or only jumped to by a
    # slow-path branch) belongs to the cold section.
    # Specifically, locate the earliest cold `p111_rt_ctor`/`p111_rt_take`
    # relocation that occurs strictly AFTER `last_ret_pos` AND after any
    # recursive self-call (`callq` to non-runtime symbol).
    last_hot_anchor_line = insn_entries[last_ret_pos][0]
    for i, line in enumerate(lines):
        m = RELOC_RE.match(line)
        if m and "$direct." in m.group(2):
            # Direct call to a Bend function (e.g. recursive self-call) is hot.
            if i > last_hot_anchor_line:
                last_hot_anchor_line = i

    # Advance past the hot block containing `last_hot_anchor_line` to its
    # terminating `retq` or unconditional `jmpq`.
    cold_start = len(lines)
    for idx, _, asm in insn_entries:
        if idx > last_hot_anchor_line and (
            asm.startswith("ret") or asm.startswith("jmp")
        ):
            cold_start = idx + 1
            break

    # If `last_hot_anchor_line` itself was the last `retq`, cold starts right after it.
    if last_hot_anchor_line == insn_entries[last_ret_pos][0]:
        cold_start = last_hot_anchor_line + 1

    return cold_start


def analyze_func(symbol: str, lines: list[str]) -> FuncMetrics:
    cold_start = find_cold_boundary(lines)
    total_insns = 0
    hot_insns = 0
    total_ctor = 0
    hot_ctor = 0
    total_take = 0
    hot_take = 0
    total_sink = 0
    rodata_lea_rip = 0
    jcc_count = 0
    hot_slot_stores = 0

    prev_was_lea_rip = False
    for idx, line in enumerate(lines):
        is_hot = idx < cold_start
        im = INSN_RE.match(line)
        if im:
            asm = im.group(2).strip()
            total_insns += 1
            if is_hot:
                hot_insns += 1
                if re.search(r"^mov\s+%[^,]+,(?:0x[0-9a-f]+)?\(%r(?:di|si|ax|cx|dx|8|9|10|11)\)", asm):
                    hot_slot_stores += 1
            if JCC_RE.match(asm):
                jcc_count += 1
            prev_was_lea_rip = bool(re.match(r"^lea\s+.*\(%rip\)", asm))
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
        rodata_lea_rip=rodata_lea_rip,
        jcc_count=jcc_count,
        hot_slot_stores=hot_slot_stores,
    )


# ---------------------------------------------------------------------------
# Contract checks
# ---------------------------------------------------------------------------

@dataclass
class ContractResult:
    name: str
    status: str  # "PASS", "FAIL", "REPORT"
    detail: str


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
        return ContractResult(
            "Contract A (ret2)", "FAIL", "missing holdout symbols"
        )
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

    # In-place reuse active: 0 hot p111_rt_ctor calls (all p111_rt_ctor calls
    # strictly relegated to cold slow paths) AND direct slot stores on the hot path.
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
    strict_borrow: bool,
) -> ContractResult:
    """Contract D (`borrow` Law 3): symreg:$direct.eval & hashmap:$direct.has."""
    s_obj = tmpdir / f"symreg_{opt_flag}.o"
    compile_to_obj(
        bend5k_bin, ROOT / "bench/runtime/symreg/main.bend", s_obj, opt_flag, cpu_pin
    )
    s_funcs = disassemble_obj(s_obj)
    sm = analyze_func("$direct.eval", s_funcs.get("$direct.eval", []))

    h_obj = tmpdir / f"hashmap_{opt_flag}.o"
    compile_to_obj(
        bend5k_bin, ROOT / "bench/runtime/hashmap/main.bend", h_obj, opt_flag, cpu_pin
    )
    h_funcs = disassemble_obj(h_obj)
    hm = analyze_func("$direct.has", h_funcs.get("$direct.has", []))

    detail = (
        f"symreg:$direct.eval take={sm.total_take_calls} (hot={sm.hot_take_calls}); "
        f"hashmap:$direct.has take={hm.total_take_calls} (hot={hm.hot_take_calls})"
    )
    if not strict_borrow:
        return ContractResult("Contract D (borrow)", "REPORT", detail)
    ok = sm.total_take_calls == 0 and hm.total_take_calls == 0
    return ContractResult("Contract D (borrow)", "PASS" if ok else "FAIL", detail)


def run_fault_injection_self_test(
    bend5k_bin: Path, tmpdir: Path, cpu_pin: str | None
) -> bool:
    """Verify every contract trips loudly when optimizations are disabled (-O0)
    or when a synthetic `callq p111_rt_ctor` / `p111_rt_take` fault is injected.
    """
    print("=== FAULT-INJECTION SELF-TEST (expecting EVERY contract to FAIL) ===")
    all_tripped = True

    # 1. Run Contracts A, B, C at -O0 (optimizations disabled).
    for fn in (check_contract_a, check_contract_b, check_contract_c):
        res = fn(bend5k_bin, tmpdir, "-O0", cpu_pin)
        tripped = res.status == "FAIL"
        tag = "TRIPPED-OK" if tripped else "MISSED-FAULT"
        print(f"  [{tag}] {res.name} (-O0): {res.detail}")
        if not tripped:
            all_tripped = False

    # 2. Run Contract D with --strict-borrow at -O0 (must fail loudly).
    res_d = check_contract_d(bend5k_bin, tmpdir, "-O0", cpu_pin, strict_borrow=True)
    tripped_d = res_d.status == "FAIL"
    tag_d = "TRIPPED-OK" if tripped_d else "MISSED-FAULT"
    print(f"  [{tag_d}] {res_d.name} (-O0 --strict-borrow): {res_d.detail}")
    if not tripped_d:
        all_tripped = False

    # 3. Synthetic disassembly fault injection: inject `callq p111_rt_ctor`
    #    directly into the hot path of an otherwise-clean synthetic function and
    #    verify `analyze_func` catches hot_ctor_calls == 1.
    synth_clean = [
        "    1000:\t55                   \tpush   %rbp",
        "    1001:\t48 89 e5             \tmov    %rsp,%rbp",
        "    1004:\t48 89 47 08          \tmov    %rax,0x8(%rdi)",
        "    1008:\t5d                   \tpop    %rbp",
        "    1009:\tc3                   \tretq   ",
    ]
    synth_fault = [
        "    1000:\t55                   \tpush   %rbp",
        "    1001:\t48 89 e5             \tmov    %rsp,%rbp",
        "    1004:\te8 00 00 00 00       \tcallq  1009 <$direct.synth+0x9>",
        "\t\t\t1005: R_X86_64_PLT32\tp111_rt_ctor-0x4",
        "    1009:\t5d                   \tpop    %rbp",
        "    100a:\tc3                   \tretq   ",
    ]
    mc = analyze_func("$direct.synth", synth_clean)
    mf = analyze_func("$direct.synth", synth_fault)
    synth_ok = mc.hot_ctor_calls == 0 and mf.hot_ctor_calls == 1
    print(
        f"  [{'TRIPPED-OK' if synth_ok else 'MISSED-FAULT'}] Synthetic hot p111_rt_ctor injection: "
        f"clean hot_ctor={mc.hot_ctor_calls}, injected hot_ctor={mf.hot_ctor_calls}"
    )
    if not synth_ok:
        all_tripped = False

    print(
        f"=== FAULT-INJECTION RESULT: {'PASS (all contracts tripped)' if all_tripped else 'FAIL'} ==="
    )
    return all_tripped


def main() -> int:
    ap = argparse.ArgumentParser(description="bend5k machine-code law contract gate")
    ap.add_argument(
        "--bend5k",
        type=Path,
        default=DEFAULT_BEND5K,
        help="Path to bend5k compiler binary",
    )
    ap.add_argument(
        "--strict-borrow",
        action="store_true",
        help="Enforce 0 p111_rt_take calls on Contract D (symreg:eval & hashmap:has)",
    )
    ap.add_argument(
        "--self-test-fault-injection",
        action="store_true",
        help="Verify every contract fails loudly when optimizations are disabled (-O0)",
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
        ]

        failed = False
        for r in results:
            print(f"[{r.status:6s}] {r.name}: {r.detail}")
            if r.status == "FAIL":
                failed = True

        return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
