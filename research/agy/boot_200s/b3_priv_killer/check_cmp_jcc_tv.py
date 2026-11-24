#!/usr/bin/env python3
"""Translation-Validation Checker for x86-64 Compare/Branch Rewrites (w11_cmp_jcc_emit / w5c2_bits_nz).

Validates compare/branch fusion rewrites across BOTH successor paths (fallthrough AND taken
branch) using exact backward dataflow liveness over the function's CFG, plus condition-code
polarity equivalence.

Specifically catches the historical Wave 16 bug in `w11_cmp_jcc_emit` where checking only
fallthrough liveness allowed fusing:
    cmpq $1, %r8
    sete %dl
    movzbl %dl, %edx
    movq %rdx, %r10
    testl %r10d, %r10d
    jz .L_b0
into:
    cmpq $1, %r8
    jne .L_b0
even when `%edx` was live at `.L_b0` (`xorl $1, %edx` in `w5c2_bits_nz`).
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Set, Tuple

# Canonical 64-bit GPR mapping for all sub-register aliases (8/16/32/64-bit).
REG_CANON: Dict[str, str] = {}
for canon, aliases in [
    ("rax", ("rax", "eax", "ax", "al", "ah")),
    ("rbx", ("rbx", "ebx", "bx", "bl", "bh")),
    ("rcx", ("rcx", "ecx", "cx", "cl", "ch")),
    ("rdx", ("rdx", "edx", "dx", "dl", "dh")),
    ("rsi", ("rsi", "esi", "si", "sil")),
    ("rdi", ("rdi", "edi", "di", "dil")),
    ("rbp", ("rbp", "ebp", "bp", "bpl")),
    ("rsp", ("rsp", "esp", "sp", "spl")),
    ("r8", ("r8", "r8d", "r8w", "r8b")),
    ("r9", ("r9", "r9d", "r9w", "r9b")),
    ("r10", ("r10", "r10d", "r10w", "r10b")),
    ("r11", ("r11", "r11d", "r11w", "r11b")),
    ("r12", ("r12", "r12d", "r12w", "r12b")),
    ("r13", ("r13", "r13d", "r13w", "r13b")),
    ("r14", ("r14", "r14d", "r14w", "r14b")),
    ("r15", ("r15", "r15d", "r15w", "r15b")),
]:
    for a in aliases:
        REG_CANON[a] = canon

INV_CC: Dict[str, str] = {
    "e": "ne", "ne": "e",
    "z": "nz", "nz": "z",
    "a": "be", "be": "a",
    "ae": "b", "b": "ae",
    "g": "le", "le": "g",
    "ge": "l", "l": "ge",
}
CC_NORM: Dict[str, str] = {"z": "e", "nz": "ne"}
JCC_OPS = {f"j{cc}" for cc in INV_CC}
SETCC_OPS = {f"set{cc}" for cc in INV_CC}
CALL_CLOBBERED = {"rax", "rcx", "rdx", "rsi", "rdi", "r8", "r9", "r10", "r11"}
CALL_ARG_REGS = {"rdi", "rsi", "rdx", "rcx", "r8", "r9"}
CALLEE_SAVED = {"rbx", "rbp", "r12", "r13", "r14", "r15"}


def norm_cc(cc: str) -> str:
    return CC_NORM.get(cc, cc)


def inv_cc(cc: str) -> str:
    return norm_cc(INV_CC[norm_cc(cc)])


def canon_reg(tok: str) -> Optional[str]:
    t = tok.strip()
    if t.startswith("%"):
        t = t[1:]
    return REG_CANON.get(t)


def regs_in_operand(op: str) -> Set[str]:
    out: Set[str] = set()
    for m in re.finditer(r"%([a-z0-9]+)", op):
        r = REG_CANON.get(m.group(1))
        if r:
            out.add(r)
    return out


def is_mem_operand(op: str) -> bool:
    return "(" in op


@dataclass
class Insn:
    raw: str
    label: Optional[str] = None
    op: str = ""
    ops: List[str] = field(default_factory=list)


def parse_insns(lines: List[str]) -> List[Insn]:
    out: List[Insn] = []
    for raw in lines:
        s = raw.split("#", 1)[0].strip()
        if not s:
            continue
        if s.endswith(":"):
            out.append(Insn(raw=s, label=s[:-1].strip()))
            continue
        parts = s.split(None, 1)
        op = parts[0].lower()
        ops: List[str] = []
        if len(parts) == 2:
            # Split operands respecting parentheses in memory addressing: disp(%base,%idx,scale)
            cur: List[str] = []
            depth = 0
            for ch in parts[1]:
                if ch == "(":
                    depth += 1
                    cur.append(ch)
                elif ch == ")":
                    depth -= 1
                    cur.append(ch)
                elif ch == "," and depth == 0:
                    ops.append("".join(cur).strip())
                    cur = []
                else:
                    cur.append(ch)
            if cur:
                ops.append("".join(cur).strip())
        out.append(Insn(raw=s, op=op, ops=ops))
    return out


def insn_use_def(ins: Insn) -> Tuple[Set[str], Set[str]]:
    """Return (uses, full_defs) of canonical 64-bit GPRs for AT&T-syntax x86-64 insn."""
    if ins.label is not None:
        return set(), set()
    op, ops = ins.op, ins.ops
    if op == "ret" or op == "retq":
        return {"rax"} | CALLEE_SAVED, set()
    if op in ("jmp", "jmpq") or op in JCC_OPS:
        return set(), set()
    if op in ("call", "callq"):
        uses = set(CALL_ARG_REGS)
        if ops:
            uses |= regs_in_operand(ops[0])
        return uses, set(CALL_CLOBBERED)
    if op in SETCC_OPS and len(ops) == 1:
        # setcc writes low 8 bits (partial write, not full 64-bit clobber, though
        # followed by movzbl in the pattern). Treat as partial write (no full def).
        if is_mem_operand(ops[0]):
            return regs_in_operand(ops[0]), set()
        return set(), set()
    if op in ("cmpq", "cmpl", "cmpw", "cmpb", "testq", "testl", "testw", "testb"):
        uses: Set[str] = set()
        for o in ops:
            uses |= regs_in_operand(o)
        return uses, set()
    if op in ("movq", "movl", "movzbl", "movzwl", "movzbq", "movzwq", "movslq", "leaq", "leal") and len(ops) == 2:
        src, dst = ops
        uses = regs_in_operand(src)
        if is_mem_operand(dst):
            return uses | regs_in_operand(dst), set()
        d = canon_reg(dst)
        # 32-bit/64-bit write zero-extends / writes full 64-bit GPR
        if d is not None:
            return uses, {d}
        return uses, set()
    if op in ("xorl", "xorq") and len(ops) == 2:
        src, dst = ops
        d = canon_reg(dst)
        s = canon_reg(src)
        if d is not None and s == d:
            # xor %r, %r zeroes register without reading it
            return set(), {d}
        uses = regs_in_operand(src) | regs_in_operand(dst)
        if not is_mem_operand(dst) and d is not None:
            return uses, {d}
        return uses, set()
    if op in ("addq", "addl", "subq", "subl", "andq", "andl", "orq", "orl",
              "shlq", "shll", "shrq", "shrl", "sarq", "sarl", "imulq", "imull") and len(ops) == 2:
        src, dst = ops
        uses = regs_in_operand(src) | regs_in_operand(dst)
        d = canon_reg(dst)
        if not is_mem_operand(dst) and d is not None:
            return uses, {d}
        return uses, set()
    if op in ("pushq", "pushl") and len(ops) == 1:
        return regs_in_operand(ops[0]) | {"rsp"}, {"rsp"}
    if op in ("popq", "popl") and len(ops) == 1:
        d = canon_reg(ops[0])
        return {"rsp"}, ({"rsp", d} if d else {"rsp"})
    # Conservative default: all regs mentioned are used, none killed.
    uses = set()
    for o in ops:
        uses |= regs_in_operand(o)
    return uses, set()


def compute_liveness(insns: List[Insn]) -> Tuple[List[Set[str]], List[Set[str]], Dict[str, int]]:
    n = len(insns)
    label_pos: Dict[str, int] = {}
    for i, ins in enumerate(insns):
        if ins.label is not None:
            label_pos[ins.label] = i

    succs: List[List[int]] = [[] for _ in range(n)]
    uses_defs = [insn_use_def(ins) for ins in insns]
    for i, ins in enumerate(insns):
        if ins.op in ("ret", "retq"):
            succs[i] = []
        elif ins.op in ("jmp", "jmpq") and ins.ops and ins.ops[0] in label_pos:
            succs[i] = [label_pos[ins.ops[0]]]
        elif ins.op in JCC_OPS and ins.ops and ins.ops[0] in label_pos:
            s: List[int] = []
            if i + 1 < n:
                s.append(i + 1)
            s.append(label_pos[ins.ops[0]])
            succs[i] = s
        else:
            if i + 1 < n:
                succs[i] = [i + 1]

    live_in: List[Set[str]] = [set() for _ in range(n)]
    live_out: List[Set[str]] = [set() for _ in range(n)]

    changed = True
    while changed:
        changed = False
        for i in range(n - 1, -1, -1):
            new_out: Set[str] = set()
            for s in succs[i]:
                new_out |= live_in[s]
            u, d = uses_defs[i]
            new_in = u | (new_out - d)
            if new_out != live_out[i] or new_in != live_in[i]:
                live_out[i] = new_out
                live_in[i] = new_in
                changed = True
    return live_in, live_out, label_pos


def find_first_use(insns: List[Insn], start_idx: int, reg: str, label_pos: Dict[str, int]) -> Optional[Tuple[int, str]]:
    """BFS from start_idx to find a concrete instruction that reads `reg` before any full def."""
    q = [start_idx]
    seen: Set[int] = set()
    n = len(insns)
    while q:
        i = q.pop(0)
        if i in seen or i < 0 or i >= n:
            continue
        seen.add(i)
        ins = insns[i]
        u, d = insn_use_def(ins)
        if reg in u:
            return (i, ins.raw)
        if reg in d:
            continue
        if ins.op in ("ret", "retq"):
            continue
        elif ins.op in ("jmp", "jmpq") and ins.ops and ins.ops[0] in label_pos:
            q.append(label_pos[ins.ops[0]])
        elif ins.op in JCC_OPS and ins.ops and ins.ops[0] in label_pos:
            q.append(i + 1)
            q.append(label_pos[ins.ops[0]])
        else:
            q.append(i + 1)
    return None


@dataclass
class CmpJccPattern:
    cmp_insn: Insn
    cc: str
    rA: str
    rB: str
    inverted: bool
    jcc_is_nz: bool
    target_label: str
    window_len: int


def match_cmp_jcc_before(insns: List[Insn], idx: int) -> Optional[CmpJccPattern]:
    """Match w5b_try_cmp_jcc / w11_cmp_jcc_* pattern starting at idx."""
    n = len(insns)
    if idx + 5 >= n:
        return None
    i_cmp = insns[idx]
    if i_cmp.op not in ("cmpq", "cmpl"):
        return None
    i_set = insns[idx + 1]
    if i_set.op not in SETCC_OPS or len(i_set.ops) != 1:
        return None
    cc = norm_cc(i_set.op[3:])
    rA = canon_reg(i_set.ops[0])
    if rA is None:
        return None
    i_z = insns[idx + 2]
    if i_z.op != "movzbl" or len(i_z.ops) != 2 or canon_reg(i_z.ops[0]) != rA or canon_reg(i_z.ops[1]) != rA:
        return None

    pos = idx + 3
    inverted = False
    if pos < n and insns[pos].op == "xorl" and len(insns[pos].ops) == 2:
        if insns[pos].ops[0] == "$1" and canon_reg(insns[pos].ops[1]) == rA:
            inverted = True
            pos += 1
    if pos >= n or insns[pos].op != "movq" or len(insns[pos].ops) != 2 or canon_reg(insns[pos].ops[0]) != rA:
        return None
    rB = canon_reg(insns[pos].ops[1])
    if rB is None:
        return None
    pos += 1
    if not inverted and pos < n and insns[pos].op == "xorl" and len(insns[pos].ops) == 2:
        if insns[pos].ops[0] == "$1" and canon_reg(insns[pos].ops[1]) == rB:
            inverted = True
            pos += 1
    if pos + 1 >= n:
        return None
    i_t = insns[pos]
    if i_t.op != "testl" or len(i_t.ops) != 2 or canon_reg(i_t.ops[0]) != rB or canon_reg(i_t.ops[1]) != rB:
        return None
    i_j = insns[pos + 1]
    if i_j.op not in ("je", "jz", "jne", "jnz") or len(i_j.ops) != 1:
        return None
    jcc_is_nz = i_j.op in ("jne", "jnz")
    return CmpJccPattern(
        cmp_insn=i_cmp,
        cc=cc,
        rA=rA,
        rB=rB,
        inverted=inverted,
        jcc_is_nz=jcc_is_nz,
        target_label=i_j.ops[0],
        window_len=(pos + 2) - idx,
    )


def validate_cmp_jcc_rewrite(
    before_lines: List[str],
    after_lines: List[str],
    site_idx: int,
) -> Dict[str, object]:
    """Validate a compare/branch rewrite at `site_idx` across BOTH successor paths."""
    before = parse_insns(before_lines)
    after = parse_insns(after_lines)
    pat = match_cmp_jcc_before(before, site_idx)
    if pat is None:
        return {"ok": False, "reason": f"no cmp+setcc+test+jcc pattern at index {site_idx}"}

    # Case 1: Rewrite abstained (identity / preserved original instructions) -> always sound.
    if [i.raw for i in before] == [i.raw for i in after]:
        return {
            "ok": True,
            "kind": "abstained_identity",
            "site_idx": site_idx,
            "target_label": pat.target_label,
            "eliminated_regs": [],
            "violations": [],
        }

    # Case 2: Fused into `cmp; j<cc'> target`
    if site_idx + 1 >= len(after):
        return {"ok": False, "reason": "after sequence too short at site_idx"}
    a_cmp, a_jcc = after[site_idx], after[site_idx + 1]
    if a_cmp.raw != pat.cmp_insn.raw:
        return {"ok": False, "reason": f"cmp mismatch: {a_cmp.raw!r} != {pat.cmp_insn.raw!r}"}
    if a_jcc.op not in JCC_OPS or len(a_jcc.ops) != 1:
        return {"ok": False, "reason": f"expected jcc after cmp, got {a_jcc.raw!r}"}
    if a_jcc.ops[0] != pat.target_label:
        return {"ok": False, "reason": f"target mismatch: {a_jcc.ops[0]} != {pat.target_label}"}

    # Expected branch condition:
    # Original jumps to target iff (bool(cc) ^ inverted) != 0 (if jnz) else == 0 (if jz).
    # Equivalently: flip = inverted if jcc_is_nz else (not inverted).
    flip = pat.inverted if pat.jcc_is_nz else (not pat.inverted)
    expected_cc = inv_cc(pat.cc) if flip else norm_cc(pat.cc)
    actual_cc = norm_cc(a_jcc.op[1:])
    if actual_cc != expected_cc:
        return {
            "ok": False,
            "kind": "polarity_mismatch",
            "reason": f"branch condition mismatch: got j{actual_cc}, expected j{expected_cc}",
        }

    # Check tail matches identically after the fused window
    before_tail = [i.raw for i in before[site_idx + pat.window_len:]]
    after_tail = [i.raw for i in after[site_idx + 2:]]
    if before_tail != after_tail:
        return {"ok": False, "reason": "post-window instruction streams differ"}

    # Exact CFG liveness on `after` at BOTH successors of `a_jcc`
    live_in, _, label_pos = compute_liveness(after)
    if pat.target_label not in label_pos:
        return {"ok": False, "reason": f"branch target label {pat.target_label} not found"}

    fallthrough_idx = site_idx + 2
    taken_idx = label_pos[pat.target_label]
    eliminated_regs = sorted({pat.rA, pat.rB})

    violations: List[Dict[str, object]] = []
    for reg in eliminated_regs:
        if fallthrough_idx < len(after) and reg in live_in[fallthrough_idx]:
            use = find_first_use(after, fallthrough_idx, reg, label_pos)
            violations.append({
                "reg": f"%{reg}",
                "branch": "fallthrough",
                "target": f"insn[{fallthrough_idx}]",
                "first_use": use[1] if use else "<live-out>",
            })
        if reg in live_in[taken_idx]:
            use = find_first_use(after, taken_idx, reg, label_pos)
            violations.append({
                "reg": f"%{reg}",
                "branch": f"taken ({pat.target_label})",
                "target": pat.target_label,
                "first_use": use[1] if use else "<live-out>",
            })

    if violations:
        summary = "; ".join(
            f"eliminated {v['reg']} is LIVE on {v['branch']} (read by `{v['first_use']}`)"
            for v in violations
        )
        return {
            "ok": False,
            "kind": "live_eliminated_reg",
            "site_idx": site_idx,
            "target_label": pat.target_label,
            "eliminated_regs": [f"%{r}" for r in eliminated_regs],
            "violations": violations,
            "reason": summary,
        }

    return {
        "ok": True,
        "kind": "fused_verified",
        "site_idx": site_idx,
        "target_label": pat.target_label,
        "expected_jcc": f"j{expected_cc}",
        "eliminated_regs": [f"%{r}" for r in eliminated_regs],
        "violations": [],
    }


def run_self_tests() -> Dict[str, object]:
    # Test 1: Historical Wave 16 bad rewrite on w5c2_bits_nz (%edx live at .L_b0 via `xorl $1, %edx`)
    w16_before = [
        "cmpq $1, %r8",
        "sete %dl",
        "movzbl %dl, %edx",
        "movq %rdx, %r10",
        "testl %r10d, %r10d",
        "jz .L_b0",
        "movq $0, %rax",
        "ret",
        ".L_b0:",
        "xorl $1, %edx",
        "movq %rdx, %rax",
        "ret",
    ]
    w16_bad_after = [
        "cmpq $1, %r8",
        "jne .L_b0",
        "movq $0, %rax",
        "ret",
        ".L_b0:",
        "xorl $1, %edx",
        "movq %rdx, %rax",
        "ret",
    ]
    t1 = validate_cmp_jcc_rewrite(w16_before, w16_bad_after, 0)
    assert not t1["ok"] and t1["kind"] == "live_eliminated_reg", f"Test 1 failed: {t1}"
    assert any(v["reg"] == "%rdx" and ".L_b0" in str(v["branch"]) for v in t1["violations"]), f"Test 1 missing rdx/.L_b0: {t1}"

    # Test 2: O2-C fixed behavior on w5c2_bits_nz (abstains from fusion because %rdx live on taken branch)
    t2 = validate_cmp_jcc_rewrite(w16_before, w16_before, 0)
    assert t2["ok"] and t2["kind"] == "abstained_identity", f"Test 2 failed: {t2}"

    # Test 3: O2-C fixed fusion when BOTH %rdx and %r10 are dead on BOTH fallthrough and taken
    valid_before = [
        "cmpq $1, %r8",
        "sete %dl",
        "movzbl %dl, %edx",
        "movq %rdx, %r10",
        "testl %r10d, %r10d",
        "jz .L_b0",
        "movq $0, %rax",
        "ret",
        ".L_b0:",
        "movq $1, %rax",
        "ret",
    ]
    valid_after = [
        "cmpq $1, %r8",
        "jne .L_b0",
        "movq $0, %rax",
        "ret",
        ".L_b0:",
        "movq $1, %rax",
        "ret",
    ]
    t3 = validate_cmp_jcc_rewrite(valid_before, valid_after, 0)
    assert t3["ok"] and t3["kind"] == "fused_verified", f"Test 3 failed: {t3}"

    # Test 4: Inverted fusion (xorl $1, %edx) with correct polarity (je) -> ACCEPTED
    inv_before = [
        "cmpq $1, %r8",
        "sete %dl",
        "movzbl %dl, %edx",
        "xorl $1, %edx",
        "movq %rdx, %r10",
        "testl %r10d, %r10d",
        "jz .L_b0",
        "movq $0, %rax",
        "ret",
        ".L_b0:",
        "movq $1, %rax",
        "ret",
    ]
    inv_after_ok = [
        "cmpq $1, %r8",
        "je .L_b0",
        "movq $0, %rax",
        "ret",
        ".L_b0:",
        "movq $1, %rax",
        "ret",
    ]
    inv_after_bad_pol = [
        "cmpq $1, %r8",
        "jne .L_b0",
        "movq $0, %rax",
        "ret",
        ".L_b0:",
        "movq $1, %rax",
        "ret",
    ]
    t4_ok = validate_cmp_jcc_rewrite(inv_before, inv_after_ok, 0)
    t4_bad = validate_cmp_jcc_rewrite(inv_before, inv_after_bad_pol, 0)
    assert t4_ok["ok"], f"Test 4a failed: {t4_ok}"
    assert not t4_bad["ok"] and t4_bad["kind"] == "polarity_mismatch", f"Test 4b failed: {t4_bad}"

    # Test 5: Fallthrough-live rejection (%r10 live on fallthrough, dead on taken)
    ft_before = [
        "cmpq $1, %r8",
        "sete %dl",
        "movzbl %dl, %edx",
        "movq %rdx, %r10",
        "testl %r10d, %r10d",
        "jz .L_b0",
        "movq %r10, %rax",
        "ret",
        ".L_b0:",
        "movq $1, %rax",
        "ret",
    ]
    ft_bad_after = [
        "cmpq $1, %r8",
        "jne .L_b0",
        "movq %r10, %rax",
        "ret",
        ".L_b0:",
        "movq $1, %rax",
        "ret",
    ]
    t5 = validate_cmp_jcc_rewrite(ft_before, ft_bad_after, 0)
    assert not t5["ok"] and any(v["reg"] == "%r10" and v["branch"] == "fallthrough" for v in t5["violations"]), f"Test 5 failed: {t5}"

    # Test 6: Transitive / loop-carried liveness through taken branch
    loop_before = [
        "cmpq $1, %r8",
        "sete %dl",
        "movzbl %dl, %edx",
        "movq %rdx, %r10",
        "testl %r10d, %r10d",
        "jz .L_loop",
        "movq $0, %rax",
        "ret",
        ".L_loop:",
        "addq $1, %r9",
        "cmpq $10, %r9",
        "jl .L_loop",
        "movq %rdx, %rax",
        "ret",
    ]
    loop_bad_after = [
        "cmpq $1, %r8",
        "jne .L_loop",
        "movq $0, %rax",
        "ret",
        ".L_loop:",
        "addq $1, %r9",
        "cmpq $10, %r9",
        "jl .L_loop",
        "movq %rdx, %rax",
        "ret",
    ]
    t6 = validate_cmp_jcc_rewrite(loop_before, loop_bad_after, 0)
    assert not t6["ok"] and any(v["reg"] == "%rdx" and ".L_loop" in str(v["branch"]) for v in t6["violations"]), f"Test 6 failed: {t6}"

    return {
        "all_passed": True,
        "tests": {
            "w16_bad_w5c2_bits_nz_rejected": t1,
            "o2c_fixed_w5c2_bits_nz_accepted": t2,
            "o2c_valid_fusion_accepted": t3,
            "inverted_xorl_valid_accepted": t4_ok,
            "inverted_xorl_bad_polarity_rejected": t4_bad,
            "fallthrough_live_r10_rejected": t5,
            "loop_carried_taken_live_rdx_rejected": t6,
        },
    }


def main() -> int:
    ap = argparse.ArgumentParser(description="Validate x86-64 compare/branch rewrites across both successor paths.")
    ap.add_argument("--self-test", action="store_true", help="Run built-in Wave 16 / O2-C validation suite")
    ap.add_argument("--json", type=str, help="Validate a JSON file with {before: [...], after: [...], site_idx: 0}")
    args = ap.parse_args()

    if args.json:
        with open(args.json, "r", encoding="utf-8") as f:
            data = json.load(f)
        res = validate_cmp_jcc_rewrite(data["before"], data["after"], int(data.get("site_idx", 0)))
        print(json.dumps(res, indent=2))
        return 0 if res["ok"] else 1

    res = run_self_tests()
    print(json.dumps(res, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
