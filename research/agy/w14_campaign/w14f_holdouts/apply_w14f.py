#!/usr/bin/env python3
"""W14-F: Composable pure-Bend x86-64 -O2 holdout optimization passes on top of W14-A.

Passes:
  1. Straight-Line Loop Optimizer Extension (w14f_sl_ext):
     - Raise w14a_sl_take_body fuel (220 -> 560) and w14a_sl_rounds fuel (8 -> 40)
       so 4x-unrolled straight-line loops (e.g. terrain erode, fill) are optimized.
     - Add %r12 to w14a_pick_free_reg and allow promoting read-only loop-invariant
       stack slots (cnt >= 1) into %r12.
     - Drop redundant 32-bit zero-extending self-move `movl %r32, %r32` after 32-bit writes.
     - Fold 5-insn copy-shift-restore-xor (`movq rA, rB; shll $c, rA32; movq rA, rC;
       movq rB, rA; xorq rC, rA`) into 3-insn (`movq rA, rB; shll $c, rB32; xorq rB, rA`).
     - Fold `movq rA, rB; andq rX, rB; movl (base, rB, sc), rDst` (rA, rB dead)
       into `andq rX, rA; movl (base, rA, sc), rDst`.
     - Hoist loop-invariant `movq %rInv, %rT; imull $imm, %rT32` out of straight-line
       loops when %rInv is saved in pre, only read by that exact pair in body, and never read
       in post before its epilogue restore.
  2. General Inline Hot `p125_rt_ctor2` with Inline `rfc_seal` (w14f_rt_ctor2_hot_text):
     - Keeps compact `agy_rt_ctor_text` for non-hot (`p185cc_known`) constructors.
     - For hot 2-field constructors (`!p185cc_known && w14f_ctor_known`), inlines
       class-1 freelist allocation + class-0 freelist `rfc_seal` for unsealed TAG_CTR
       fields, with strict pre-mutation checks so cold fallback has zero side effects.
  3. General Inline Class-3 (`count = 5..8`) `p111_rt_ctor` and `p111_rt_take`:
     - Inlines 5..8-field constructor allocation (`cls=3, words=8, atOff=24, lenOff=280`)
       for unsealed cold ctors and unique-owner/RFC `p111_rt_take` for 5..8-field ctors,
       restoring `%ecx = count` on the cold fallback path.
"""
from __future__ import annotations

import difflib
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
sys.path.insert(0, str(ROOT / "research/agy/w14_campaign/w14a_edit_expr_1x"))
import build_w14a

ORIG = ROOT / "selfhost/build/agy/wave11_unified/compiler.bend"
OUT_DIR = ROOT / "research/agy/w14_campaign/w14f_holdouts"
PATCH_OUT = OUT_DIR / "w14f_holdouts.patch"
TMP = Path("/tmp/agy_w14f")
COMP_OUT = TMP / "compiler_w14f.bend"
API_OUT = TMP / "api_w14f.mjs"
LOCKED_BUN = ROOT / "research/agy/locked_bun.sh"


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    cnt = text.count(old)
    if cnt != 1:
        raise RuntimeError(f"[{label}] expected 1 occurrence, found {cnt}")
    return text.replace(old, new, 1)


W14F_RT_INLINE_CODE = r"""
# ==== W14-F: General Inline Hot p125_rt_ctor2 & Class-3 (5..8 field) p111_rt_ctor / p111_rt_take ====

@unsafe
def w14f_ctor_known(+ctor: String, +count: U32, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      +entry = index_find(constructors,ctor,index_hash(ctor,2166136261),32)
      agy_str_eq(dk(entry),"N111Id") && U32.is_lt(da(entry),65536) && U32.is_eq(dx(entry),count)

# Inline hot p125_rt_ctor2(state=%rdi, cid=%esi, fields=%rdx) with inline rfc_seal.
# Preserves %rdi, %rsi, %rdx across all pre-checks so cold fallback has zero side effects.
@unsafe
def w14f_rt_ctor2_hot_text(+name: String, +args: List<&2,N111Arg>, +cid: U32,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +lPlain  = x181_label(site,frame)
  +lSeal0  = x181_label(U32.inc(site),frame)
  +lSeal1  = x181_label(U32.add(site,2),frame)
  +lCommit = x181_label(U32.add(site,3),frame)
  +lSlow   = x181_label(U32.add(site,4),frame)
  +lDone   = x181_label(U32.add(site,5),frame)
  +tagHi   = U32.add(33554432,U32.mul(cid,256))
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(1,64)),
    x188_i2("andl",X187Imm{1,0},x188_reg(1,32)),
    x188_i1("jz",X187Target{lSlow}),
    x188_i2("movq",X187Mem{7,8},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,8},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jz",X187Target{lSlow}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    # Count how many fields need rfc_seal ((f >> 56) == 2)
    x188_i2("movq",X187Mem{2,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(10,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(10,64)),
    x188_i1("sete",x188_reg(1,8)),
    x188_i2("movzbl",x188_reg(1,8),x188_reg(1,32)),
    x188_i2("movq",X187Mem{2,8},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(11,64)),
    x188_i1("sete",x188_reg(10,8)),
    x188_i2("movzbl",x188_reg(10,8),x188_reg(10,32)),
    x188_i2("addl",x188_reg(10,32),x188_reg(1,32)),
    x188_i2("testl",x188_reg(1,32),x188_reg(1,32)),
    x188_i1("jz",X187Target{lPlain}),
    # Pre-check class-0 freelist has 1 or 2 cells
    x188_i2("movq",X187Mem{8,0},x188_reg(10,64)),
    x188_i2("testq",x188_reg(10,64),x188_reg(10,64)),
    x188_i1("jz",X187Target{lSlow}),
    x188_i2("cmpl",X187Imm{2,0},x188_reg(1,32)),
    x188_i1("jne",X187Target{lSeal0}),
    x188_i2("movq",X187Indexed{9,10,8,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jz",X187Target{lSlow}),
    # Seal f0 into %r10, f1 into %r11
    x188_label(lSeal0),
    x188_i2("movq",X187Mem{2,0},x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{lSeal1}),
    x188_i2("movq",X187Mem{8,0},x188_reg(11,64)),
    x188_i2("movq",X187Indexed{9,11,8,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{8,0}),
    x188_i2("subq",X187Imm{1,0},X187Mem{8,256}),
    x188_i2("movq",x188_reg(10,64),x188_reg(1,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(1,64)),
    x188_i2("orq",X187Imm{1,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Indexed{9,11,8,0}),
    x188_i2("shrq",X187Imm{40,0},x188_reg(10,64)),
    x188_i2("shlq",X187Imm{40,0},x188_reg(10,64)),
    x188_i2("orq",x188_reg(11,64),x188_reg(10,64)),
    x188_i2("movabsq",X187Imm{0,2147483648},x188_reg(1,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(10,64)),
    x188_label(lSeal1),
    x188_i2("movq",X187Mem{2,8},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{lCommit}),
    x188_i2("movq",X187Mem{8,0},x188_reg(6,64)),
    x188_i2("movq",X187Indexed{9,6,8,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{8,0}),
    x188_i2("subq",X187Imm{1,0},X187Mem{8,256}),
    x188_i2("movq",x188_reg(11,64),x188_reg(1,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(1,64)),
    x188_i2("orq",X187Imm{1,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Indexed{9,6,8,0}),
    x188_i2("shrq",X187Imm{40,0},x188_reg(11,64)),
    x188_i2("shlq",X187Imm{40,0},x188_reg(11,64)),
    x188_i2("orq",x188_reg(6,64),x188_reg(11,64)),
    x188_i2("movabsq",X187Imm{0,2147483648},x188_reg(1,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(11,64)),
    x188_label(lCommit),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(1,64)),
    x188_i2("movq",X187Mem{1,0},x188_reg(6,64)),
    x188_i2("movq",x188_reg(6,64),X187Mem{8,8}),
    x188_i2("subq",X187Imm{2,0},X187Mem{8,264}),
    x188_i2("movq",x188_reg(10,64),X187Mem{1,0}),
    x188_i2("movq",x188_reg(11,64),X187Mem{1,8}),
    x188_i2("movabsq",X187Imm{0,tagHi},x188_reg(1,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{lDone}),
    x188_label(lPlain),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{8,8}),
    x188_i2("subq",X187Imm{2,0},X187Mem{8,264}),
    x188_i2("movq",X187Mem{2,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{10,0}),
    x188_i2("movq",X187Mem{2,8},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{10,8}),
    x188_i2("movabsq",X187Imm{0,tagHi},x188_reg(1,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{lDone}),
    x188_label(lSlow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p125_rt_ctor2"}),
    x188_label(lDone),
    x181_store(name,frame,x188_reg(0,64))])

# Inline class-3 (count = 5..8) p111_rt_ctor(state=%rdi, cid=%esi, buf=%rdx, count=%ecx)
@unsafe
def w14f_rt_ctor_big_text(+name: String, +args: List<&2,N111Arg>, +cid: U32,
    +count: U32, +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +slow = x181_label(site,frame)
  +done = x181_label(U32.inc(site),frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(1,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(1,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(1,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(1,64)),
    x188_i2("movzbl",X187Indexed{1,6,1,0},x188_reg(1,32)),
    x188_i2("testl",x188_reg(1,32),x188_reg(1,32)),
    x188_i1("jnz",X187Target{slow}),
    x188_i2("movq",X187Mem{7,8},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,24},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jz",X187Target{slow}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{8,24}),
    x188_i2("subq",X187Imm{8,0},X187Mem{8,280}),
    agy_copy_words(2,10,11,count,0),
    x188_i2("movabsq",X187Imm{0,U32.add(33554432,U32.mul(cid,256))},x188_reg(1,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("movl",X187Imm{count,0},x188_reg(1,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_ctor"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

# Inline class-3 (count = 5..8) p111_rt_take(state=%rdi, term=%rsi, out=%rdx, count=%ecx)
# Unique-owner (non-RFC TAG_CTR) fast path; falls back cleanly to p111_rt_take on RFC/cold.
@unsafe
def w14f_rt_take_big_text(+name: String, +args: List<&2,N111Arg>,
    +count: U32, +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +slow = x181_label(site,frame)
  +done = x181_label(U32.inc(site),frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    # Unique-owner only (non-RFC => term >= 0) and TAG_CTR (tag == 2)
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jl",X187Target{slow}),
    x188_i2("movq",x188_reg(6,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(1,64)),
    x188_i2("movl",x188_reg(1,32),x188_reg(0,32)),
    x188_i2("shrl",X187Imm{16,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{2,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("andl",X187Imm{65535,0},x188_reg(1,32)),
    x188_i2("movq",X187Rip{"p111_program",24,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(1,64)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",128,0},x188_reg(8,64)),
    x188_i2("movzbl",X187Indexed{8,1,1,0},x188_reg(8,32)),
    x188_i2("cmpl",X187Imm{count,0},x188_reg(8,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(8,64)),
    x188_i2("andl",X187Imm{1,0},x188_reg(8,32)),
    x188_i1("jz",X187Target{slow}),
    # Check dynamic heap address >= heap_min
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(8,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(8,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(8,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{slow}),
    # Check class-3 freelist room: len[3] + 8 < 32768
    x188_i2("movq",X187Mem{7,8},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,280},x188_reg(11,64)),
    x188_i2("addq",X187Imm{8,0},x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
    x188_i1("jae",X187Target{slow}),
    # Copy count fields from H[loc] to out, push loc onto alc->free[3]
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(10,64)),
    agy_copy_words(10,2,1,count,0),
    x188_i2("movq",X187Mem{8,24},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{10,0}),
    x188_i2("movq",x188_reg(0,64),X187Mem{8,24}),
    x188_i2("movq",x188_reg(11,64),X187Mem{8,280}),
    x188_i2("movl",X187Imm{count,0},x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("movl",X187Imm{count,0},x188_reg(1,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_take"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])
"""


W14F_SL_HOIST_CODE = r"""
# ==== W14-F: Straight-Line Loop Peepholes & Loop-Invariant Imull Hoisting ====

@unsafe
def w14f_writes_r32(+r: U32, it: X187Parsed) -> Bool:
  match it:
    case PInst{X187Instruction{+op,Con{_,Con{X187Reg{dr,32,False{}},Nil{}}}}}:
      U32.is_eq(dr,r) && (agy_str_eq(op,"movzbl") || agy_str_eq(op,"movl") || agy_str_eq(op,"addl") ||
                          agy_str_eq(op,"subl") || agy_str_eq(op,"andl") || agy_str_eq(op,"orl") ||
                          agy_str_eq(op,"xorl") || agy_str_eq(op,"shll") || agy_str_eq(op,"shrl"))
    case _: False{}

law w14f_drop_self_movl:
  for body: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w14f_drop_self_movl_pair(+i0: X187Parsed, i1: X187Parsed, +rest: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match i1:
    case PInst{X187Instruction{op,Con{X187Reg{+r,32,False{}},Con{X187Reg{+r2,32,False{}},Nil{}}}}}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op,"movl") && U32.is_eq(r,r2) && w14f_writes_r32(r,i0),
        u => w14f_drop_self_movl(rest,Con{i0,acc}),
        u => w14f_drop_self_movl(Con{PInst{X187Instruction{op,[x188_reg(r,32),x188_reg(r2,32)]}},rest},Con{i0,acc}))
    case other: w14f_drop_self_movl(Con{other,rest},Con{i0,acc})

@unsafe
def w14f_drop_self_movl(body,acc):
  match body:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{+i0,Con{i1,+rest}}: w14f_drop_self_movl_pair(i0,i1,rest,acc)
    case Con{i0,Nil{}}: nt_reverse(X187Parsed,Con{i0,acc},[])

# Extra straight-line peepholes:
#  1) movq rA, rB; shll/shrl $c, rA32; movq rA, rC; movq rB, rA; xorq rC, rA (rB,rC dead)
#     -> movq rA, rB; shll/shrl $c, rB32; xorq rB, rA
#  2) movq rA, rB; andq rX, rB; movl (base, rB, sc), rDst (rA,rB dead, rA != 4, rA != rX, rA != base)
#     -> andq rX, rA; movl (base, rA, sc), rDst
law w14f_sl_extra:
  for body: List<&2,X187Parsed>
  for +afterBody: List<&2,X187Parsed>
  for +fnItems: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w14f_try_xorshift(+rA: U32, +rB: U32, i1: X187Parsed, i2: X187Parsed, i3: X187Parsed, i4: X187Parsed,
    +r5: List<&2,X187Parsed>, +afterBody: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match i1 i2 i3 i4:
    case PInst{X187Instruction{+op1,Con{X187Imm{+c,0},Con{X187Reg{+d1,32,False{}},Nil{}}}}}
         PInst{X187Instruction{op2,Con{X187Reg{+s2,64,False{}},Con{X187Reg{+rC,64,False{}},Nil{}}}}}
         PInst{X187Instruction{op3,Con{X187Reg{+s3,64,False{}},Con{X187Reg{+d3,64,False{}},Nil{}}}}}
         PInst{X187Instruction{+op4,Con{X187Reg{+s4,+w4,False{}},Con{X187Reg{+d4,+dw4,False{}},Nil{}}}}}:
      +ok = (agy_str_eq(op1,"shll") || agy_str_eq(op1,"shrl")) && agy_str_eq(op2,"movq") &&
            agy_str_eq(op3,"movq") && (agy_str_eq(op4,"xorq") || agy_str_eq(op4,"xorl")) &&
            U32.is_eq(d1,rA) && U32.is_eq(s2,rA) && U32.is_eq(s3,rB) && U32.is_eq(d3,rA) &&
            U32.is_eq(s4,rC) && U32.is_eq(d4,rA) && Bool.not(U32.is_eq(rA,rB)) &&
            Bool.not(U32.is_eq(rA,rC)) && Bool.not(U32.is_eq(rB,rC)) &&
            w14a_sl_dead(rB,r5,afterBody,fnItems) && w14a_sl_dead(rC,r5,afterBody,fnItems)
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{w14f_sl_extra(
               Con{PInst{X187Instruction{"movq",[x188_reg(rA,64),x188_reg(rB,64)]}},
               Con{PInst{X187Instruction{op1,[X187Imm{c,0},x188_reg(rB,32)]}},
               Con{PInst{X187Instruction{op4,[x188_reg(rB,w4),x188_reg(rA,dw4)]}},r5}}},
               afterBody,fnItems,acc)},
        u => None{})
    case _ _ _ _: None{}

@unsafe
def w14f_try_and_idx(+rA: U32, +rB: U32, i1: X187Parsed, i2: X187Parsed,
    +r3: List<&2,X187Parsed>, +afterBody: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>,
    +acc: List<&2,X187Parsed>) -> Maybe<&2,List<&2,X187Parsed>>:
  match i1 i2:
    case PInst{X187Instruction{op1,Con{X187Reg{+rX,64,False{}},Con{X187Reg{+d1,64,False{}},Nil{}}}}}
         PInst{X187Instruction{op2,Con{X187Indexed{+b,+ix,+sc,+dp},Con{X187Reg{+rDst,32,False{}},Nil{}}}}}:
      +ok = agy_str_eq(op1,"andq") && agy_str_eq(op2,"movl") && U32.is_eq(d1,rB) && U32.is_eq(ix,rB) &&
            Bool.not(U32.is_eq(rA,rB)) && Bool.not(U32.is_eq(rA,rX)) && Bool.not(U32.is_eq(rA,b)) &&
            Bool.not(U32.is_eq(rA,4)) && Bool.not(U32.is_eq(rB,b)) &&
            w14a_sl_dead(rB,r3,afterBody,fnItems) &&
            (U32.is_eq(rA,rDst) || w14a_sl_dead(rA,r3,afterBody,fnItems))
      nt_choose(Maybe<&2,List<&2,X187Parsed>>,ok,
        u => Some{w14f_sl_extra(
               Con{PInst{X187Instruction{"andq",[x188_reg(rX,64),x188_reg(rA,64)]}},
               Con{PInst{X187Instruction{"movl",[X187Indexed{b,rA,sc,dp},x188_reg(rDst,32)]}},r3}},
               afterBody,fnItems,acc)},
        u => None{})
    case _ _: None{}

@unsafe
def w14f_sl_extra_movq(+rA: U32, +rB: U32, rest: List<&2,X187Parsed>,
    +afterBody: List<&2,X187Parsed>, +fnItems: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match rest:
    case Con{+i1,Con{+i2,Con{+i3,Con{+i4,+r5}}}}:
      +i0 : X187Parsed = PInst{X187Instruction{"movq",[x188_reg(rA,64),x188_reg(rB,64)]}}
      w14a_sl_copy_or(w14f_try_xorshift(rA,rB,i1,i2,i3,i4,r5,afterBody,fnItems,acc),
        u => w14a_sl_copy_or(w14f_try_and_idx(rA,rB,i1,i2,Con{i3,Con{i4,r5}},afterBody,fnItems,acc),
          v => w14f_sl_extra(Con{i1,Con{i2,Con{i3,Con{i4,r5}}}},afterBody,fnItems,Con{i0,acc})))
    case Con{+i1,Con{+i2,+r3}}:
      +i0 : X187Parsed = PInst{X187Instruction{"movq",[x188_reg(rA,64),x188_reg(rB,64)]}}
      w14a_sl_copy_or(w14f_try_and_idx(rA,rB,i1,i2,r3,afterBody,fnItems,acc),
        u => w14f_sl_extra(Con{i1,Con{i2,r3}},afterBody,fnItems,Con{i0,acc}))
    case other:
      w14f_sl_extra(other,afterBody,fnItems,Con{PInst{X187Instruction{"movq",[x188_reg(rA,64),x188_reg(rB,64)]}},acc})

@unsafe
def w14f_sl_extra(body,afterBody,fnItems,acc):
  match body:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{PInst{X187Instruction{+op0,Con{X187Reg{+rA,64,False{}},Con{X187Reg{+rB,64,False{}},Nil{}}}}},+rest}:
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op0,"movq"),
        u => w14f_sl_extra_movq(rA,rB,rest,afterBody,fnItems,acc),
        u => w14f_sl_extra(rest,afterBody,fnItems,Con{PInst{X187Instruction{op0,[x188_reg(rA,64),x188_reg(rB,64)]}},acc}))
    case Con{h,rest}: w14f_sl_extra(rest,afterBody,fnItems,Con{h,acc})

# Loop-invariant `movq %rInv, %rT; imull $imm, %rT32` hoisting (2-operand imull!):
type W14FImulCand is Data:
  W14FImulNo{}
  W14FImulYes{+rInv: U32, +imm: U32}

@unsafe
def w14f_is_imul2_imm(it: X187Parsed, +rT: U32) -> Maybe<&2,U32>:
  match it:
    case PInst{X187Instruction{op,Con{X187Imm{v,0},Con{X187Reg{d,32,False{}},Nil{}}}}}:
      nt_choose(Maybe<&2,U32>,agy_str_eq(op,"imull") && U32.is_eq(d,rT),
        u => Some{v},u => None{})
    case _: None{}

@unsafe
def w14f_post_reg_safe(+r: U32, post: List<&2,X187Parsed>) -> Bool:
  match post:
    case Nil{}: True{}
    case Con{PInst{X187Instruction{op,Con{X187Mem{5,disp},Con{X187Reg{dr,64,False{}},Nil{}}}}},rest}:
      nt_choose(Bool,agy_str_eq(op,"movq") && U32.is_eq(dr,r) && U32.is_ge(disp,4294967256),
        u => True{},
        u => Bool.not(w4b_args_read_reg(r,[X187Mem{5,disp},x188_reg(dr,64)])) && w14f_post_reg_safe(r,rest))
    case Con{PInst{X187Instruction{_,args}},rest}:
      Bool.not(w4b_args_read_reg(r,args)) && w14f_post_reg_safe(r,rest)
    case Con{_,rest}: w14f_post_reg_safe(r,rest)

law w14f_imul_only_pairs:
  for +rInv: U32
  for +imm: U32
  for body: List<&2,X187Parsed>
  for +cnt: U32
  U32

@unsafe
def w14f_imul_only_step(hit: Maybe<&2,U32>, +rInv: U32, +imm: U32, +op0: String, +s0: U32, +rT: U32,
    +i1: X187Parsed, +rest: List<&2,X187Parsed>, +cnt: U32) -> U32:
  match hit:
    case Some{v}:
      nt_choose(U32,agy_str_eq(op0,"movq") && U32.is_eq(s0,rInv) && Bool.not(U32.is_eq(rT,rInv)) && U32.is_eq(v,imm),
        u => w14f_imul_only_pairs(rInv,imm,rest,U32.inc(cnt)),
        u => nt_choose(U32,w4b_args_read_reg(rInv,[x188_reg(s0,64),x188_reg(rT,64)]),
               w => 0,w => w14f_imul_only_pairs(rInv,imm,Con{i1,rest},cnt)))
    case None{}:
      nt_choose(U32,w4b_args_read_reg(rInv,[x188_reg(s0,64),x188_reg(rT,64)]),
        w => 0,w => w14f_imul_only_pairs(rInv,imm,Con{i1,rest},cnt))

@unsafe
def w14f_imul_only_pairs(rInv,imm,body,cnt):
  match body:
    case Nil{}: cnt
    case Con{PInst{X187Instruction{+op0,Con{X187Reg{+s0,64,False{}},Con{X187Reg{+rT,64,False{}},Nil{}}}}},Con{+i1,+rest}}:
      w14f_imul_only_step(w14f_is_imul2_imm(i1,rT),rInv,imm,op0,s0,rT,i1,rest,cnt)
    case Con{PInst{X187Instruction{_,args}},rest}:
      nt_choose(U32,w4b_args_read_reg(rInv,args),u => 0,u => w14f_imul_only_pairs(rInv,imm,rest,cnt))
    case Con{_,rest}: w14f_imul_only_pairs(rInv,imm,rest,cnt)

law w14f_imul_rew:
  for +rInv: U32
  for +imm: U32
  for body: List<&2,X187Parsed>
  for +acc: List<&2,X187Parsed>
  List<&2,X187Parsed>

@unsafe
def w14f_imul_rew_step(hit: Maybe<&2,U32>, +rInv: U32, +imm: U32, +op0: String, +s0: U32, +rT: U32,
    +i1: X187Parsed, +rest: List<&2,X187Parsed>, +acc: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match hit:
    case Some{v}:
      +i0 : X187Parsed = PInst{X187Instruction{op0,[x188_reg(s0,64),x188_reg(rT,64)]}}
      nt_choose(List<&2,X187Parsed>,agy_str_eq(op0,"movq") && U32.is_eq(s0,rInv) && Bool.not(U32.is_eq(rT,rInv)) && U32.is_eq(v,imm),
        u => w14f_imul_rew(rInv,imm,rest,Con{i0,acc}),
        u => w14f_imul_rew(rInv,imm,Con{i1,rest},Con{i0,acc}))
    case None{}:
      w14f_imul_rew(rInv,imm,Con{i1,rest},Con{PInst{X187Instruction{op0,[x188_reg(s0,64),x188_reg(rT,64)]}},acc})

@unsafe
def w14f_imul_rew(rInv,imm,body,acc):
  match body:
    case Nil{}: nt_reverse(X187Parsed,acc,[])
    case Con{PInst{X187Instruction{+op0,Con{X187Reg{+s0,64,False{}},Con{X187Reg{+rT,64,False{}},Nil{}}}}},Con{+i1,+rest}}:
      w14f_imul_rew_step(w14f_is_imul2_imm(i1,rT),rInv,imm,op0,s0,rT,i1,rest,acc)
    case Con{h,rest}: w14f_imul_rew(rInv,imm,rest,Con{h,acc})

law w14f_find_imul_cand:
  for scan: List<&2,X187Parsed>
  for +fullBody: List<&2,X187Parsed>
  for +pre: List<&2,X187Parsed>
  for +post: List<&2,X187Parsed>
  W14FImulCand

@unsafe
def w14f_find_imul_step(hit: Maybe<&2,U32>, +op0: String, +rInv: U32, +rT: U32,
    +i1: X187Parsed, +rest: List<&2,X187Parsed>, +fullBody: List<&2,X187Parsed>,
    +pre: List<&2,X187Parsed>, +post: List<&2,X187Parsed>) -> W14FImulCand:
  match hit:
    case Some{+v}:
      +ok = agy_str_eq(op0,"movq") && Bool.not(U32.is_eq(rInv,rT)) &&
            Bool.not(U32.is_eq(rInv,4)) && Bool.not(U32.is_eq(rInv,5)) &&
            w14a_reg_saved_in(rInv,pre) && w14f_post_reg_safe(rInv,post) &&
            U32.is_ge(w14f_imul_only_pairs(rInv,v,fullBody,0),2)
      nt_choose(W14FImulCand,ok,
        u => W14FImulYes{rInv,v},
        u => w14f_find_imul_cand(Con{i1,rest},fullBody,pre,post))
    case None{}: w14f_find_imul_cand(Con{i1,rest},fullBody,pre,post)

@unsafe
def w14f_find_imul_cand(scan,fullBody,pre,post):
  match scan:
    case Nil{}: W14FImulNo{}
    case Con{PInst{X187Instruction{+op0,Con{X187Reg{+rInv,64,False{}},Con{X187Reg{+rT,64,False{}},Nil{}}}}},Con{+i1,+rest}}:
      w14f_find_imul_step(w14f_is_imul2_imm(i1,rT),op0,rInv,rT,i1,rest,fullBody,pre,post)
    case Con{_,rest}: w14f_find_imul_cand(rest,fullBody,pre,post)
"""


def apply_w14f_patches(text: str) -> str:
    # Start from W14-A baseline (which includes W12-G + W13-E + W14-A on wave11_unified)
    text = build_w14a.apply_w14a_patches(text)

    # 1. Insert W14F_RT_INLINE_CODE right before agy_rt_inline_try and wire Pass 2 & Pass 3
    text = replace_exact(
        text,
        """@unsafe
def agy_rt_inline_try(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,""",
        W14F_RT_INLINE_CODE + """
@unsafe
def agy_rt_inline_try(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,""",
        "insert_w14f_rt_inline",
    )

    # Pass 2: Keep compact agy_rt_ctor_text for non-hot (p185cc_known); use w14f_rt_ctor2_hot_text for hot 2-field ctors
    text = replace_exact(
        text,
        """    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_ctor_arity(symbol)
      nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          agy_str_eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,n,ids) && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_ctor_text(name,symbol,args,agy_ctor_cid(ctor,ids),n,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))""",
        """    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_ctor_arity(symbol)
      nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          agy_str_eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,n,ids) && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_ctor_text(name,symbol,args,agy_ctor_cid(ctor,ids),n,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_eq(n,2) &&
          agy_str_eq(state,"state") && w14f_ctor_known(ctor,2,ids) && U32.is_le(next,4294967288),
        v => X181Code{Con{w14f_rt_ctor2_hot_text(name,args,agy_ctor_cid(ctor,ids),ids,frame,next),chunks},U32.add(next,6),terminal,error},
        v => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)))""",
        "wire_w14f_rt_ctor2_hot",
    )

    # Pass 3: Inline class-3 (count = 5..8) p111_rt_ctor and p111_rt_take
    text = replace_exact(
        text,
        """    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},buf},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_str_eq(symbol,"p111_rt_ctor") && agy_str_eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,0,ids),
        u => X181Code{Con{x188_many([
          x188_i2("movabsq",X187Imm{0,U32.add(16777216,U32.mul(agy_ctor_cid(ctor,ids),256))},x188_reg(0,64)),
          x181_store(name,frame,x188_reg(0,64))]),chunks},next,terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))""",
        """    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},buf},Con{N111Arg{N111U32{},N111Const{+cnt,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_str_eq(symbol,"p111_rt_ctor") && agy_str_eq(state,"state") && U32.is_eq(cnt,0) && p185cb_known(ctor,ids) && p185cc_known(ctor,0,ids),
        u => X181Code{Con{x188_many([
          x188_i2("movabsq",X187Imm{0,U32.add(16777216,U32.mul(agy_ctor_cid(ctor,ids),256))},x188_reg(0,64)),
          x181_store(name,frame,x188_reg(0,64))]),chunks},next,terminal,error},
        u => nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && agy_str_eq(symbol,"p111_rt_ctor") &&
          agy_str_eq(state,"state") && U32.is_ge(cnt,5) && U32.is_le(cnt,8) && p185cb_known(ctor,ids) && p185cc_known(ctor,cnt,ids) &&
          U32.is_le(next,4294967293),
        v => X181Code{Con{w14f_rt_ctor_big_text(name,args,agy_ctor_cid(ctor,ids),cnt,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        v => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)))
    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U64{},term},Con{N111Arg{N111Ptr{},N111Local{+buf}},Con{N111Arg{N111U32{},N111Const{+cnt,0}},Nil{}}}}} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_take_inline_enabled() && agy_frame_ctor_ok(frame) && agy_str_eq(symbol,"p111_rt_take") &&
          agy_str_eq(state,"state") && U32.is_ge(cnt,5) && U32.is_le(cnt,8) && U32.is_le(next,4294967293),
        u => X181Code{Con{w14f_rt_take_big_text(name,args,cnt,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))""",
        "wire_w14f_ctor_take_big",
    )

    # 2. Extend W14-A straight-line loop optimizer (Pass 1)
    text = replace_exact(
        text,
        """    case Con{PLabel{+lTop},+rest}:
      w14a_sl_find_step(w14a_sl_take_body(220,lTop,rest,[],nt_reverse(X187Parsed,preAcc,[]),fnItems),lTop,rest,preAcc,fnItems)""",
        """    case Con{PLabel{+lTop},+rest}:
      w14a_sl_find_step(w14a_sl_take_body(560,lTop,rest,[],nt_reverse(X187Parsed,preAcc,[]),fnItems),lTop,rest,preAcc,fnItems)""",
        "w14f_sl_fuel_560",
    )

    # Add %r12 to temp-promotion candidate register list
    text = replace_exact(
        text,
        """w14a_pick_free_reg([ld,0,11,10,14,3,6,9,2,1,7,8,13,15],fw,lr,ld,body,afterBody,pre,fnItems)""",
        """w14a_pick_free_reg([ld,0,11,10,14,3,6,9,2,1,7,8,12,13,15],fw,lr,ld,body,afterBody,pre,fnItems)""",
        "w14f_pick_free_r12",
    )

    text = replace_exact(
        text,
        """@unsafe
def w14a_sl_loop_opt_go(sp: W14ASLSplit, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match sp:
    case W14ASLNo{}: items
    case W14ASLHit{+pre,+lTop,+body,+backJcc,+post}:
      +bodyDedup = w14a_dedup_stores(body,body,pre,post,[])
      +canR12 = Bool.not(w5b_reg_used(12,bodyDedup)) && w14a_reg_saved_in(12,pre) &&
                w14a_post_r12_safe(post) && Bool.not(w4b_has_any_branch_to(lTop,pre)) &&
                Bool.not(w4b_has_any_branch_to(lTop,post))
      +dCarry = nt_choose(U32,canR12,u => w14a_find_carried_slot(bodyDedup,bodyDedup,pre,post),u => 0)
      +hasCarry = Bool.not(U32.is_eq(dCarry,0))
      +body0 = nt_choose(List<&2,X187Parsed>,hasCarry,u => w5b_rew_items(dCarry,12,False{},bodyDedup,[]),u => bodyDedup)
      +pre2 = nt_choose(List<&2,X187Parsed>,hasCarry,
                u => nt_append(X187Parsed,pre,[PInst{X187Instruction{"movq",[X187Mem{5,dCarry},x188_reg(12,64)]}}]),
                u => pre)
      +post2 = nt_choose(List<&2,X187Parsed>,hasCarry,
                 u => Con{PInst{X187Instruction{"movq",[x188_reg(12,64),X187Mem{5,dCarry}]}},post},
                 u => post)
      +afterBody2 : List<&2,X187Parsed> = Con{backJcc,post2}
      +fn2 = nt_append(X187Parsed,pre2,Con{PLabel{lTop},nt_append(X187Parsed,body0,afterBody2)})
      +bodyOpt = w14a_sl_rounds(8,lTop,body0,afterBody2,pre2,post2,fn2)
      nt_append(X187Parsed,pre2,Con{PLabel{lTop},nt_append(X187Parsed,bodyOpt,afterBody2)})""",
        W14F_SL_HOIST_CODE + """
@unsafe
def w14f_sl_hoist_apply(cand: W14FImulCand, +pre: List<&2,X187Parsed>, +lTop: String,
    +body: List<&2,X187Parsed>, +afterBody: List<&2,X187Parsed>, +post: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match cand:
    case W14FImulNo{}:
      +fn0 = nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,body,afterBody)})
      +b1 = w14a_sl_rounds(40,lTop,body,afterBody,pre,post,fn0)
      +fn1 = nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,b1,afterBody)})
      +b2 = w14f_sl_extra(b1,afterBody,fn1,[])
      +fn2 = nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,b2,afterBody)})
      +b3 = w14a_sl_copy_go(b2,afterBody,fn2,[])
      nt_append(X187Parsed,pre,Con{PLabel{lTop},nt_append(X187Parsed,b3,afterBody)})
    case W14FImulYes{+rInv,+imm}:
      +preH = nt_append(X187Parsed,pre,[PInst{X187Instruction{"imull",[X187Imm{imm,0},x188_reg(rInv,32)]}}])
      +bodyH = w14f_imul_rew(rInv,imm,body,[])
      +fnH = nt_append(X187Parsed,preH,Con{PLabel{lTop},nt_append(X187Parsed,bodyH,afterBody)})
      +b1 = w14a_sl_rounds(40,lTop,bodyH,afterBody,preH,post,fnH)
      +fn1 = nt_append(X187Parsed,preH,Con{PLabel{lTop},nt_append(X187Parsed,b1,afterBody)})
      +b2 = w14f_sl_extra(b1,afterBody,fn1,[])
      +fn2 = nt_append(X187Parsed,preH,Con{PLabel{lTop},nt_append(X187Parsed,b2,afterBody)})
      +b3 = w14a_sl_copy_go(b2,afterBody,fn2,[])
      nt_append(X187Parsed,preH,Con{PLabel{lTop},nt_append(X187Parsed,b3,afterBody)})

@unsafe
def w14a_sl_loop_opt_go(sp: W14ASLSplit, +items: List<&2,X187Parsed>) -> List<&2,X187Parsed>:
  match sp:
    case W14ASLNo{}: items
    case W14ASLHit{+pre,+lTop,+body,+backJcc,+post}:
      +bodyClean = w14f_drop_self_movl(body,[])
      +bodyDedup = w14a_dedup_stores(bodyClean,bodyClean,pre,post,[])
      +canR12 = Bool.not(w5b_reg_used(12,bodyDedup)) && w14a_reg_saved_in(12,pre) &&
                w14a_post_r12_safe(post) && Bool.not(w4b_has_any_branch_to(lTop,pre)) &&
                Bool.not(w4b_has_any_branch_to(lTop,post))
      +dCarry = nt_choose(U32,canR12,u => w14a_find_carried_slot(bodyDedup,bodyDedup,pre,post),u => 0)
      +hasCarry = Bool.not(U32.is_eq(dCarry,0))
      +body0 = nt_choose(List<&2,X187Parsed>,hasCarry,u => w5b_rew_items(dCarry,12,False{},bodyDedup,[]),u => bodyDedup)
      +pre2 = nt_choose(List<&2,X187Parsed>,hasCarry,
                u => nt_append(X187Parsed,pre,[PInst{X187Instruction{"movq",[X187Mem{5,dCarry},x188_reg(12,64)]}}]),
                u => pre)
      +post2 = nt_choose(List<&2,X187Parsed>,hasCarry,
                 u => Con{PInst{X187Instruction{"movq",[x188_reg(12,64),X187Mem{5,dCarry}]}},post},
                 u => post)
      +afterBody2 : List<&2,X187Parsed> = Con{backJcc,post2}
      +canHoist = Bool.not(w4b_has_any_branch_to(lTop,pre2)) && Bool.not(w4b_has_any_branch_to(lTop,post2))
      +cand = nt_choose(W14FImulCand,canHoist,u => w14f_find_imul_cand(body0,body0,pre2,post2),u => W14FImulNo{})
      w14f_sl_hoist_apply(cand,pre2,lTop,body0,afterBody2,post2)""",
        "w14f_sl_loop_opt_ext",
    )

    return text


def main() -> int:
    TMP.mkdir(parents=True, exist_ok=True)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    base_src = ORIG.read_text(encoding="utf-8")
    w14a_src = build_w14a.apply_w14a_patches(base_src)
    w14f_src = apply_w14f_patches(base_src)
    COMP_OUT.write_text(w14f_src, encoding="utf-8")

    diff = "".join(
        difflib.unified_diff(
            w14a_src.splitlines(keepends=True),
            w14f_src.splitlines(keepends=True),
            fromfile="compiler_w14a.bend",
            tofile="compiler_w14f.bend",
            n=3,
        )
    )
    PATCH_OUT.write_text(diff, encoding="utf-8")
    print(f"Wrote {COMP_OUT} ({len(w14f_src):,} B) and {PATCH_OUT} ({len(diff):,} B)", flush=True)

    cpu = 5
    skip_check = "--skip-check" in sys.argv
    if not skip_check:
        t0 = time.perf_counter()
        r = subprocess.run(
            ["timeout", "180", "taskset", "-c", str(cpu), "bash", str(LOCKED_BUN), str(COMP_OUT), "--check-only"],
            capture_output=True, text=True, cwd=ROOT,
        )
        chk_ms = round((time.perf_counter() - t0) * 1000.0, 1)
        (TMP / "check_only.err").write_text(r.stdout + "\n" + r.stderr, encoding="utf-8")
        if r.returncode != 0 and "rely on unsafe or foreign code:" not in (r.stdout + r.stderr):
            print("CHECK FAILED:", r.stdout[:2000], r.stderr[:2000], flush=True)
            return r.returncode
        print(f"  --check-only PASS in {chk_ms} ms", flush=True)

    t0 = time.perf_counter()
    r = subprocess.run(
        ["taskset", "-c", str(cpu), "flock", "/tmp/agy_bun_build.lock", "timeout", "180",
         str(ROOT / "selfhost/.assets/bin/bun"), str(ROOT / "bend2/main.ts"), str(COMP_OUT), "-o", str(API_OUT)],
        capture_output=True, text=True, cwd=ROOT,
    )
    comp_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    (TMP / "compile_js.err").write_text(r.stdout + "\n" + r.stderr, encoding="utf-8")
    if r.returncode != 0:
        print("COMPILE FAILED:", r.stdout[:2000], r.stderr[:2000], flush=True)
        return r.returncode
    print(f"  compiled {API_OUT} ({API_OUT.stat().st_size:,} B) in {comp_ms} ms", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
