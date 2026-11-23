#!/usr/bin/env python3
"""Apply W12-F: Inline Boxed-Element Array.get / Array.set Fast-Path.

Reads selfhost/build/agy/wave11_unified/compiler.bend (read-only) and writes:
  - research/agy/w12_campaign/w12f_boxed_array/compiler.bend
  - research/agy/w12_campaign/w12f_boxed_array/w12f_boxed_array.patch

Pure-Bend x86-64 codegen in `agy_rt_inline_try`:
  1. `p113_rt_array_pair(state, 72, inbuf, 2, outbuf, 2)` (boxed Array.get):
     - Live-checks `(p111_program.capabilities & 2) == 0` (!NATIVE_SCALAR_ARRAYS)
     - Checks `!term_rfc(array)` (unique/unshared array handle)
     - Computes `at = (u32)index & (u32)((1ull << ((array >> 40) & 31)) - 1)`
     - Loads `w = H[(array & LOC_MASK) + at]`
     - Fast path A (`term_rfc(w)`): bumps `H[w & LOC_MASK]` refcount (if `< RFC_CNT - 1`)
     - Fast path B (`!term_rfc(w) && term_tag(w) < 2`): trivial element (e.g. CNil{}, U32), no RC op
     - Writes `out[0] = array`, `out[1] = w`, returns 0
     - Exact cold fallback to `p113_rt_array_pair` (restoring `%esi=72, %ecx=2, %r9d=2`)
  2. `p111_rt_op(state, 73, inbuf, 3)` (boxed Array.set):
     - Live-checks `(p111_program.capabilities & 2) == 0` (!NATIVE_SCALAR_ARRAYS)
     - Checks `!term_rfc(array)`
     - Computes `slot_ptr = &H[(array & LOC_MASK) + at]`
     - Validates `old = *slot_ptr` BEFORE mutating anything:
       - RFC with `rc > 1` -> records `old_rfc_ptr` for inline `subq $1, (%r8)`
       - Trivial (`!term_rfc(old) && term_tag(old) < 2`) -> no drop needed
       - Otherwise (`rc == 1` or non-trivial un-RFC'd) -> cold fallback to `p111_rt_op`
     - Validates `value = inbuf[2]` for `rfc_seal(e, value)`:
       - If `(value >> 56) == 2` (`TAG_CTR && !term_rfc`): checks `alc->free[0] != 0`
         BEFORE any mutation; pops 1-word RFC cell (`cls=0`), initializes
         `H[r] = (term_loc(value) << 24) | 1`, forms `(value & ~LOC_MASK) | RFC_BIT | r`
       - Otherwise: `sealed_value = value`
     - Commits: decrements `old_rfc_ptr` (if non-null), stores `sealed_value` to `*slot_ptr`,
       returns `array` in `%rax`
     - Exact cold fallback to `p111_rt_op` (restoring `%esi=73, %ecx=3`)
"""
from __future__ import annotations

import difflib
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
SRC = ROOT / "selfhost/build/agy/wave11_unified/compiler.bend"
OUT_DIR = ROOT / "research/agy/w12_campaign/w12f_boxed_array"
OUT_BEND = OUT_DIR / "compiler.bend"
OUT_PATCH = OUT_DIR / "w12f_boxed_array.patch"

W12F_DEFS = """# === AGY-W12F: Inline Boxed-Element Array.get / Array.set Fast-Path ===

@unsafe
def w12f_arg_is_state(a: N111Arg) -> Bool:
  match a:
    case N111Arg{N111Ptr{},N111Local{nm}}: agy_str_eq(nm,"state")
    case _: False{}

@unsafe
def w12f_arg_is_ptr_local(a: N111Arg) -> Bool:
  match a:
    case N111Arg{N111Ptr{},N111Local{_}}: True{}
    case _: False{}

@unsafe
def w12f_arg_is_u32_eq(a: N111Arg, +want: U32) -> Bool:
  match a:
    case N111Arg{N111U32{},N111Const{lo,hi}}: U32.is_eq(hi,0) && U32.is_eq(lo,want)
    case _: False{}

@unsafe
def w12f_is_array_get_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{a0,Con{a1,Con{a2,Con{a3,Con{a4,Con{a5,Nil{}}}}}}}:
      w12f_arg_is_state(a0) && w12f_arg_is_u32_eq(a1,72) &&
      w12f_arg_is_ptr_local(a2) && w12f_arg_is_u32_eq(a3,2) &&
      w12f_arg_is_ptr_local(a4) && w12f_arg_is_u32_eq(a5,2)
    case _: False{}

@unsafe
def w12f_is_array_set_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{a0,Con{a1,Con{a2,Con{a3,Nil{}}}}}:
      w12f_arg_is_state(a0) && w12f_arg_is_u32_eq(a1,73) &&
      w12f_arg_is_ptr_local(a2) && w12f_arg_is_u32_eq(a3,3)
    case _: False{}

@unsafe
def w12f_rt_array_get_text(+name: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +triv = x181_label(site,frame)
  +store = x181_label(U32.inc(site),frame)
  +slow = x181_label(U32.add(site,2),frame)
  +done = x181_label(U32.add(site,3),frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    # Live check: !NATIVE_SCALAR_ARRAYS (capabilities & 2 == 0)
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{2,0},x188_reg(0,32)),
    x188_i1("jnz",X187Target{slow}),
    # %r10 = array = inbuf[0]; require !term_rfc(array)
    x188_i2("movq",X187Mem{2,0},x188_reg(10,64)),
    x188_i2("testq",x188_reg(10,64),x188_reg(10,64)),
    x188_i1("jl",X187Target{slow}),
    # at = (u32)inbuf[1] & (u32)((1ull << ((array >> 40) & 31)) - 1)
    x188_i2("movq",x188_reg(10,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(1,64)),
    x188_i2("andl",X187Imm{31,0},x188_reg(1,32)),
    x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
    x188_i2("shlq",x188_reg(1,8),x188_reg(0,64)),
    x188_i2("subl",X187Imm{1,0},x188_reg(0,32)),
    x188_i2("movl",X187Mem{2,8},x188_reg(11,32)),
    x188_i2("andl",x188_reg(11,32),x188_reg(0,32)),
    # loc = array & LOC_MASK; w = H[loc + at]
    x188_i2("movq",x188_reg(10,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("addq",x188_reg(0,64),x188_reg(11,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("movq",X187Indexed{9,11,8,0},x188_reg(6,64)),
    # blk_keep(e, loc + at) on %rsi = w
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jge",X187Target{triv}),
    # RFC-wrapped element: bump refcount in H[w & LOC_MASK]
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(0,64)),
    x188_i2("movl",x188_reg(0,32),x188_reg(1,32)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(1,32)),
    x188_i2("cmpl",X187Imm{16777214,0},x188_reg(1,32)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("addq",X187Imm{1,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{11,0}),
    x188_i1("jmp",X187Target{store}),
    x188_label(triv),
    # Non-RFC element: fast only if term_tag(w) < 2 (U32 or TAG_PAK)
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jae",X187Target{slow}),
    x188_label(store),
    x188_i2("movq",x188_reg(10,64),X187Mem{8,0}),
    x188_i2("movq",x188_reg(6,64),X187Mem{8,8}),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("movl",X187Imm{72,0},x188_reg(6,32)),
    x188_i2("movl",X187Imm{2,0},x188_reg(1,32)),
    x188_i2("movl",X187Imm{2,0},x188_reg(9,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p113_rt_array_pair"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def w12f_rt_array_set_text(+name: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +old_triv = x181_label(site,frame)
  +old_ok = x181_label(U32.inc(site),frame)
  +val_wrap = x181_label(U32.add(site,2),frame)
  +commit_old = x181_label(U32.add(site,3),frame)
  +write_slot = x181_label(U32.add(site,4),frame)
  +slow = x181_label(U32.add(site,5),frame)
  +done = x181_label(U32.add(site,6),frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    # Live check: !NATIVE_SCALAR_ARRAYS (capabilities & 2 == 0)
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{2,0},x188_reg(0,32)),
    x188_i1("jnz",X187Target{slow}),
    # %r11 = array = inbuf[0]; require !term_rfc(array)
    x188_i2("movq",X187Mem{2,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jl",X187Target{slow}),
    # at = (u32)inbuf[1] & (u32)((1ull << ((array >> 40) & 31)) - 1)
    x188_i2("movq",x188_reg(11,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(1,64)),
    x188_i2("andl",X187Imm{31,0},x188_reg(1,32)),
    x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
    x188_i2("shlq",x188_reg(1,8),x188_reg(0,64)),
    x188_i2("subl",X187Imm{1,0},x188_reg(0,32)),
    x188_i2("movl",X187Mem{2,8},x188_reg(8,32)),
    x188_i2("andl",x188_reg(8,32),x188_reg(0,32)),
    # %r9 = H = state->e.mem; %r10 = slot_ptr = &H[(array & LOC_MASK) + at]
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("addq",x188_reg(0,64),x188_reg(11,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,11,8,0},x188_reg(10,64)),
    # Validate old = *slot_ptr BEFORE any mutation; %r8 = old_rfc_ptr (or 0)
    x188_i2("movq",X187Mem{10,0},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jge",X187Target{old_triv}),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,0},x188_reg(11,64)),
    x188_i2("movl",x188_reg(11,32),x188_reg(0,32)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("jbe",X187Target{slow}),
    x188_i1("jmp",X187Target{old_ok}),
    x188_label(old_triv),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("xorl",x188_reg(8,32),x188_reg(8,32)),
    x188_label(old_ok),
    # Check value = inbuf[2] for rfc_seal(e, value): wrap iff (value >> 56) == 2
    x188_i2("movq",X187Mem{2,16},x188_reg(6,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("je",X187Target{val_wrap}),
    x188_i1("jmp",X187Target{commit_old}),
    x188_label(val_wrap),
    # Need rfc_wrap(e, value, 1): check class-0 freelist head BEFORE any mutation
    x188_i2("movq",X187Mem{7,8},x188_reg(1,64)),
    x188_i2("movq",X187Mem{1,0},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jz",X187Target{slow}),
    # Point of no return: pop r from alc->free[0]
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{1,0}),
    x188_i2("subq",X187Imm{1,0},X187Mem{1,256}),
    # Write H[r] = (term_loc(value) << 24) | 1
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("addq",X187Imm{1,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{1,0}),
    # sealed_value = (value & ~LOC_MASK) | RFC_BIT | r
    x188_i2("shrq",X187Imm{40,0},x188_reg(6,64)),
    x188_i2("shlq",X187Imm{40,0},x188_reg(6,64)),
    x188_i2("orq",x188_reg(0,64),x188_reg(6,64)),
    x188_i2("movabsq",X187Imm{0,2147483648},x188_reg(11,64)),
    x188_i2("orq",x188_reg(11,64),x188_reg(6,64)),
    x188_label(commit_old),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("jz",X187Target{write_slot}),
    x188_i2("subq",X187Imm{1,0},X187Mem{8,0}),
    x188_label(write_slot),
    x188_i2("movq",x188_reg(6,64),X187Mem{10,0}),
    x188_i2("movq",X187Mem{2,0},x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("movl",X187Imm{73,0},x188_reg(6,32)),
    x188_i2("movl",X187Imm{3,0},x188_reg(1,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_op"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def w12f_ctor2_known(+ctor: String, ids: N111Ids) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      +entry = index_find(constructors,ctor,index_hash(ctor,2166136261),32)
      agy_str_eq(dk(entry),"N111Id") && U32.is_lt(da(entry),65536) && U32.is_eq(dx(entry),2)

@unsafe
def w12f_rt_ctor2_sealed_text(+name: String, +args: List<&2,N111Arg>, +cid: U32,
    +ids: N111Ids, +frame: X181Frame, +site: U32) -> X188Seq:
  +slow = x181_label(site,frame)
  +done = x181_label(U32.inc(site),frame)
  x188_many([
    x186_call_arguments(args,ids,frame),
    # Load both fields; fast path iff neither is an unsealed TAG_CTR ((f >> 56) == 2).
    # When true, rfc_seal is a no-op on both fields regardless of cid_hot or capabilities.
    x188_i2("movq",X187Mem{2,0},x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("je",X187Target{slow}),
    x188_i2("movq",X187Mem{2,8},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("je",X187Target{slow}),
    # Pop 2-word node (cls=1: atOff=8, lenOff=264, words=2) from state->e.alc
    x188_i2("movq",X187Mem{7,8},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,8},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jz",X187Target{slow}),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(1,64)),
    x188_i2("movq",X187Mem{1,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(9,64),X187Mem{8,8}),
    x188_i2("subq",X187Imm{2,0},X187Mem{8,264}),
    x188_i2("movq",x188_reg(10,64),X187Mem{1,0}),
    x188_i2("movq",x188_reg(11,64),X187Mem{1,8}),
    x188_i2("movabsq",X187Imm{0,U32.add(33554432,U32.mul(cid,256))},x188_reg(1,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{done}),
    x188_label(slow),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p125_rt_ctor2"}),
    x188_label(done),
    x181_store(name,frame,x188_reg(0,64))])

@unsafe
def w12f_rt_inline_array(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, +code: X181Code) -> X181Code:
  match typ code:
    case N111U64{} X181Code{chunks,+next,terminal,error}:
      nt_choose(X181Code,agy_str_eq(symbol,"p113_rt_array_pair") &&
          U32.is_le(next,4294967291) && w12f_is_array_get_args(args),
        u => X181Code{Con{w12f_rt_array_get_text(name,args,ids,frame,next),chunks},U32.add(next,4),terminal,error},
        u => nt_choose(X181Code,agy_str_eq(symbol,"p111_rt_op") &&
            U32.is_le(next,4294967288) && w12f_is_array_set_args(args),
          v => X181Code{Con{w12f_rt_array_set_text(name,args,ids,frame,next),chunks},U32.add(next,7),terminal,error},
          v => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)))
    case _ _: agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)

"""

OLD_CTOR_CASE = """    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_ctor_arity(symbol)
      nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          agy_str_eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,n,ids) && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_ctor_text(name,symbol,args,agy_ctor_cid(ctor,ids),n,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code))"""

NEW_CTOR_CASE = """    case N111U64{} Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111CtorId{+ctor}},Con{N111Arg{N111Ptr{},N111Local{+buf}},Nil{}}}} X181Code{chunks,+next,terminal,error}:
      +n = agy_rt_ctor_arity(symbol)
      nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_gt(n,0) &&
          agy_str_eq(state,"state") && p185cb_known(ctor,ids) && p185cc_known(ctor,n,ids) && U32.is_le(next,4294967293),
        u => X181Code{Con{agy_rt_ctor_text(name,symbol,args,agy_ctor_cid(ctor,ids),n,ids,frame,next),chunks},U32.add(next,2),terminal,error},
        u => nt_choose(X181Code,agy_ctor_inline_enabled() && agy_frame_ctor_ok(frame) && U32.is_eq(n,2) &&
            agy_str_eq(state,"state") && w12f_ctor2_known(ctor,ids) && U32.is_le(next,4294967293),
          v => X181Code{Con{w12f_rt_ctor2_sealed_text(name,args,agy_ctor_cid(ctor,ids),ids,frame,next),chunks},U32.add(next,2),terminal,error},
          v => agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)))"""

OLD_FALLBACK = """    case _ _ _: agy_rt_inline_fallback(name,typ,symbol,args,ids,frame,code)

@unsafe
def x185_float_call("""

NEW_FALLBACK = """    case _ _ _: w12f_rt_inline_array(name,typ,symbol,args,ids,frame,code)

@unsafe
def x185_float_call("""

ANCHOR = """@unsafe
def agy_rt_inline_try("""


def main() -> None:
    src_text = SRC.read_text(encoding="utf-8")
    assert src_text.count(ANCHOR) == 1, f"expected 1 anchor, found {src_text.count(ANCHOR)}"
    assert src_text.count(OLD_FALLBACK) == 1, f"expected 1 fallback, found {src_text.count(OLD_FALLBACK)}"
    assert src_text.count(OLD_CTOR_CASE) == 1, f"expected 1 ctor case, found {src_text.count(OLD_CTOR_CASE)}"

    out_text = src_text.replace(ANCHOR, W12F_DEFS + ANCHOR, 1)
    out_text = out_text.replace(OLD_CTOR_CASE, NEW_CTOR_CASE, 1)
    out_text = out_text.replace(OLD_FALLBACK, NEW_FALLBACK, 1)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    OUT_BEND.write_text(out_text, encoding="utf-8")

    diff = "".join(
        difflib.unified_diff(
            src_text.splitlines(keepends=True),
            out_text.splitlines(keepends=True),
            fromfile="selfhost/build/agy/wave11_unified/compiler.bend",
            tofile="research/agy/w12_campaign/w12f_boxed_array/compiler.bend",
        )
    )
    OUT_PATCH.write_text(diff, encoding="utf-8")
    print(f"Wrote {OUT_BEND} ({len(out_text):,} B, +{len(out_text)-len(src_text):,} B)")
    print(f"Wrote {OUT_PATCH} ({len(diff):,} B)")


if __name__ == "__main__":
    main()
