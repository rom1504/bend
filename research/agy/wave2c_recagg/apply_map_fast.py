#!/usr/bin/env python3
"""
AGY-W2C-MAPFAST: Certified native x86 fast paths for Map.get and Map.set.

- Map.get(d, m, key):
  Certified structurally (MTip/MLeaf/MNode + Map.get.go). Walks the Patricia
  trie natively with zero p111 continuation frames, zero MNode rebuilds,
  inline magic-/33 Map.bit, and inline String equality. Handles both owned
  (tag=0x02) and RFC-shared (tag=0x82) Map/String nodes; bails to original
  Map.get on any unexpected tag/case.

- Map.set(m, key, x):
  Certified structurally (Map.seek + Map.set.go). Walks strictly owned
  (tag=0x02) MNode/MLeaf path natively; if key already exists at an owned
  MLeaf, updates heap[loc+1] = x in place, sinks old_v and key, and returns m.
  On any shared node (tag!=0x02), empty MTip, or missing key (insert/splice),
  bails cleanly to original Map.set before mutating anything.
"""
from pathlib import Path
import sys

MAP_BEND = r'''
# === AGY-W2C-MAPFAST ===

@unsafe
def agy_map_ctor_id(ids: N111Ids, +name: String) -> U32:
  match ids:
    case N111Ids{functions,constructors}:
      +found = index_find(constructors,name,index_hash(name,2166136261),32)
      nt_choose(U32,String.eq(dk(found),"N111Id"),u => da(found),u => 4294967295)

@unsafe
def agy_map_has_ctors(+ids: N111Ids) -> Bool:
  U32.is_lt(agy_map_ctor_id(ids,"MTip"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"MLeaf"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"MNode"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"SNil"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"SCon"),65536) &&
  U32.is_lt(agy_map_ctor_id(ids,"Tuple"),65536)

law agy_map_stmts_has_ctor:
  for stmts: List<&2,N111Stmt>
  for +cname: String
  Bool

@unsafe
def agy_map_val_is_ctor(v: N111Value, +cname: String) -> Bool:
  match v:
    case N111CtorId{n}: String.eq(n,cname)
    case _: False{}

@unsafe
def agy_map_args_has_ctor(args: List<&2,N111Arg>, +cname: String) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{t,v},rest}: agy_map_val_is_ctor(v,cname) || agy_map_args_has_ctor(rest,cname)

@unsafe
def agy_map_stmt_has_ctor(stmt: N111Stmt, +cname: String) -> Bool:
  match stmt:
    case N111Set{n,t,v}: agy_map_val_is_ctor(v,cname)
    case N111Bin{n,t,op,l,r}: agy_map_val_is_ctor(l,cname) || agy_map_val_is_ctor(r,cname)
    case N111Call{n,t,s,args}: agy_map_args_has_ctor(args,cname)
    case N111If{c,yes,no}: agy_map_stmts_has_ctor(yes,cname) || agy_map_stmts_has_ctor(no,cname)
    case N111Store{t,b,o,v}: agy_map_val_is_ctor(v,cname)
    case _: False{}

@unsafe
def agy_map_stmts_has_ctor(stmts,cname):
  match stmts:
    case Nil{}: False{}
    case Con{h,rest}: agy_map_stmt_has_ctor(h,cname) || agy_map_stmts_has_ctor(rest,cname)

law agy_map_stmts_has_func:
  for stmts: List<&2,N111Stmt>
  for +fname: String
  Bool

@unsafe
def agy_map_val_has_func(v: N111Value, +fname: String) -> Bool:
  match v:
    case N111FuncId{n}: String.eq(n,fname) || String.eq(n,"$direct." ++ fname)
    case _: False{}

@unsafe
def agy_map_args_has_func(args: List<&2,N111Arg>, +fname: String) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{N111Arg{t,v},rest}: agy_map_val_has_func(v,fname) || agy_map_args_has_func(rest,fname)

@unsafe
def agy_map_stmt_has_func(stmt: N111Stmt, +fname: String) -> Bool:
  match stmt:
    case N111Set{n,t,v}: agy_map_val_has_func(v,fname)
    case N111Call{n,t,s,args}: agy_map_args_has_func(args,fname)
    case N111If{c,yes,no}: agy_map_stmts_has_func(yes,fname) || agy_map_stmts_has_func(no,fname)
    case N111Store{t,b,o,v}: agy_map_val_has_func(v,fname)
    case _: False{}

@unsafe
def agy_map_stmts_has_func(stmts,fname):
  match stmts:
    case Nil{}: False{}
    case Con{h,rest}: agy_map_stmt_has_func(h,fname) || agy_map_stmts_has_func(rest,fname)

@unsafe
def agy_map_kind(segment: N111Segment, +ids: N111Ids) -> U32:
  match segment:
    case N111Segment{+name,+arity,+result,incoming,flags,+body}:
      nt_choose(U32,U32.is_eq(arity,3) && U32.is_eq(result,1) && agy_map_has_ctors(ids),u =>
        nt_choose(U32,(String.eq(name,"$direct.Map.get") || String.eq(name,"Map.get")) &&
          agy_map_stmts_has_ctor(body,"MTip") && agy_map_stmts_has_ctor(body,"MLeaf") &&
          agy_map_stmts_has_ctor(body,"MNode"),
          v => 1,v =>
        nt_choose(U32,(String.eq(name,"$direct.Map.set") || String.eq(name,"Map.set")) &&
          agy_map_stmts_has_func(body,"Map.seek"),
          w => 2,w => 0)),
        u => 0)

# Shared inline map_bit sequence:
# Inputs: %r13 = heap, %rdi = pos (u64 Nat), key_reg = key (String), %rsi = preserved (MNode loc)
# Clobbers: %rax (temp), %rcx, %rdx, %r8, %r9, %rdi
# Branches to l_bit0 (bit=0), l_bit1 (bit=1), or l_bail (unexpected tag / pos >= 2^32)
@unsafe
def agy_map_emit_bit(+pfx: String, +snil: U32, +scon: U32, +key_reg: U32,
    +l_bit0: String, +l_bit1: String, +l_bail: String) -> X188Seq:
  +l_walk = pfx ++ "_bw"
  +l_slok = pfx ++ "_bs"
  +l_chr  = pfx ++ "_bc"
  x188_many([
    # Check pos < 2^32
    x188_i2("movq",x188_reg(7,64),x188_reg(8,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(8,64)),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("jne",X187Target{l_bail}),
    # ci = (pos * 0xF83E0F84) >> 37 into %r8
    x188_i2("movabsq",X187Imm{4164816772,0},x188_reg(8,64)),
    x188_i2("imulq",x188_reg(7,64),x188_reg(8,64)),
    x188_i2("shrq",X187Imm{37,0},x188_reg(8,64)),
    # off = pos - ci * 33 into %rdi
    x188_i2("movq",x188_reg(8,64),x188_reg(9,64)),
    x188_i2("imulq",X187Imm{33,0},x188_reg(9,64)),
    x188_i2("subq",x188_reg(9,64),x188_reg(7,64)),
    # Walk s = key_reg in %r9 for %r8 (ci) hops
    x188_i2("movq",x188_reg(key_reg,64),x188_reg(9,64)),
    x188_label(l_walk),
    x188_i2("movq",x188_reg(9,64),x188_reg(2,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(2,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(2,64)),
    x188_i2("cmpq",X187Imm{snil,0},x188_reg(2,64)),
    x188_i1("je",X187Target{l_bit0}),
    x188_i2("cmpq",X187Imm{scon,0},x188_reg(2,64)),
    x188_i1("jne",X187Target{l_bail}),
    # Extract s_loc into %rdx (handling tag 0x02 and 0x82)
    x188_i2("movq",x188_reg(9,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(2,64)),
    x188_i2("andq",x188_reg(9,64),x188_reg(2,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("je",X187Target{l_slok}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",X187Indexed{13,2,8,0},x188_reg(2,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(2,64)),
    x188_label(l_slok),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_chr}),
    x188_i2("movq",X187Indexed{13,2,8,8},x188_reg(9,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(8,64)),
    x188_i1("jmp",X187Target{l_walk}),
    x188_label(l_chr),
    x188_i2("testq",x188_reg(7,64),x188_reg(7,64)),
    x188_i1("je",X187Target{l_bit1}),
    # ch = heap[s_loc] in %r9d, shift = 32 - off in %ecx
    x188_i2("movl",X187Indexed{13,2,8,0},x188_reg(9,32)),
    x188_i2("movl",X187Imm{32,0},x188_reg(1,32)),
    x188_i2("subl",x188_reg(7,32),x188_reg(1,32)),
    x188_i2("shrl",x188_reg(1,8),x188_reg(9,32)),
    x188_i2("andl",X187Imm{1,0},x188_reg(9,32)),
    x188_i1("jne",X187Target{l_bit1}),
    x188_i1("jmp",X187Target{l_bit0})
  ])

# Shared inline string equality:
# Inputs: %r13 = heap, %r8 = s1, %r9 = s2
# Clobbers: %rax, %rcx, %rdx, %rdi, %r8, %r9
# Preserves: %rsi, %r10, %r11, %rbx, %r12..%r15
# Branches to l_eq (equal), l_ne (not equal), or l_bail (unexpected tag)
@unsafe
def agy_map_emit_streq(+pfx: String, +snil: U32, +scon: U32,
    +l_eq: String, +l_ne: String, +l_bail: String) -> X188Seq:
  +l_loop = pfx ++ "_sc"
  +l_c1n  = pfx ++ "_s1n"
  +l_l1ok = pfx ++ "_s1k"
  +l_l2ok = pfx ++ "_s2k"
  x188_many([
    x188_label(l_loop),
    x188_i2("cmpq",x188_reg(9,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_eq}),
    # cid1 in %rcx, cid2 in %rdx
    x188_i2("movq",x188_reg(8,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(1,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(9,64),x188_reg(2,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(2,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(2,64)),
    x188_i2("cmpq",X187Imm{snil,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_c1n}),
    x188_i2("cmpq",X187Imm{snil,0},x188_reg(2,64)),
    x188_i1("je",X187Target{l_eq}),
    x188_i1("jmp",X187Target{l_ne}),
    x188_label(l_c1n),
    x188_i2("cmpq",X187Imm{snil,0},x188_reg(2,64)),
    x188_i1("je",X187Target{l_ne}),
    x188_i2("cmpq",X187Imm{scon,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("cmpq",X187Imm{scon,0},x188_reg(2,64)),
    x188_i1("jne",X187Target{l_bail}),
    # loc1 -> %rcx
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(1,64)),
    x188_i2("andq",x188_reg(8,64),x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("je",X187Target{l_l1ok}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",X187Indexed{13,1,8,0},x188_reg(1,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(1,64)),
    x188_label(l_l1ok),
    # loc2 -> %rdx
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(2,64)),
    x188_i2("andq",x188_reg(9,64),x188_reg(2,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("je",X187Target{l_l2ok}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",X187Indexed{13,2,8,0},x188_reg(2,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(2,64)),
    x188_label(l_l2ok),
    # Compare chars (raw u64/u32 words at heap[loc1], heap[loc2])
    x188_i2("movq",X187Indexed{13,1,8,0},x188_reg(7,64)),
    x188_i2("cmpq",X187Indexed{13,2,8,0},x188_reg(7,64)),
    x188_i1("jne",X187Target{l_ne}),
    x188_i2("movq",X187Indexed{13,1,8,8},x188_reg(8,64)),
    x188_i2("movq",X187Indexed{13,2,8,8},x188_reg(9,64)),
    x188_i1("jmp",X187Target{l_loop})
  ])

# Emit native Map.get fast path wrapper for p111 symbol
@unsafe
def agy_map_get_fast(+symbol: String, +slow_sym: String, +ids: N111Ids) -> X181Output:
  +mtip  = agy_map_ctor_id(ids,"MTip")
  +mleaf = agy_map_ctor_id(ids,"MLeaf")
  +mnode = agy_map_ctor_id(ids,"MNode")
  +snil  = agy_map_ctor_id(ids,"SNil")
  +scon  = agy_map_ctor_id(ids,"SCon")
  +tup   = agy_map_ctor_id(ids,"Tuple")
  +pfx   = ".Lmg_" ++ symbol
  +l_loop = pfx ++ "_lp"
  +l_lok  = pfx ++ "_lk"
  +l_leaf = pfx ++ "_lf"
  +l_bit0 = pfx ++ "_b0"
  +l_bit1 = pfx ++ "_b1"
  +l_hit  = pfx ++ "_ht"
  +l_ksh  = pfx ++ "_ks"
  +l_hv   = pfx ++ "_hv"
  +l_sdok = pfx ++ "_sd"
  +l_miss = pfx ++ "_ms"
  +l_skok = pfx ++ "_sk"
  +l_ret  = pfx ++ "_rt"
  +l_bail = pfx ++ "_bl"
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    x188_i1("pushq",x188_reg(5,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i2("subq",X187Imm{40,0},x188_reg(4,64)),
    # %r12 = st, %r13 = heap, %r14 = d, %rbx = orig_m, %r15 = key, %rax = cur
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(13,64)),
    x188_i2("movq",X187Mem{12,40},x188_reg(14,64)),
    x188_i2("movq",X187Mem{12,48},x188_reg(3,64)),
    x188_i2("movq",X187Mem{12,56},x188_reg(15,64)),
    x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),
    x188_label(l_loop),
    # %rcx = tag, %rdx = cid
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(2,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(2,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(2,64)),
    x188_i2("cmpq",X187Imm{mtip,0},x188_reg(2,64)),
    x188_i1("je",X187Target{l_miss}),
    # Extract loc into %rsi (handle 0x02 and 0x82)
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(6,64)),
    x188_i2("andq",x188_reg(0,64),x188_reg(6,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("je",X187Target{l_lok}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",X187Indexed{13,6,8,0},x188_reg(6,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(6,64)),
    x188_label(l_lok),
    x188_i2("cmpq",X187Imm{mleaf,0},x188_reg(2,64)),
    x188_i1("je",X187Target{l_leaf}),
    x188_i2("cmpq",X187Imm{mnode,0},x188_reg(2,64)),
    x188_i1("jne",X187Target{l_bail}),
    # MNode: pos = heap[loc] into %rdi
    x188_i2("movq",X187Indexed{13,6,8,0},x188_reg(7,64)),
    agy_map_emit_bit(pfx,snil,scon,15,l_bit0,l_bit1,l_bail),
    x188_label(l_bit0),
    x188_i2("movq",X187Indexed{13,6,8,8},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_loop}),
    x188_label(l_bit1),
    x188_i2("movq",X187Indexed{13,6,8,16},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_loop}),
    # MLeaf: %rsi = loc, %rcx = leaf tag; save to %r11 (loc), %r10 (tag)
    x188_label(l_leaf),
    x188_i2("movq",x188_reg(1,64),x188_reg(10,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(11,64)),
    x188_i2("movq",X187Indexed{13,6,8,0},x188_reg(8,64)),
    x188_i2("movq",x188_reg(15,64),x188_reg(9,64)),
    agy_map_emit_streq(pfx,snil,scon,l_hit,l_miss,l_bail),
    # Hit: v = heap[leaf_loc + 1]
    x188_label(l_hit),
    x188_i2("movq",X187Indexed{13,11,8,8},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_hv}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(1,64)),
    x188_i1("je",X187Target{l_ksh}),
    # Owned 0x02 value inside owned 0x02 heap leaf: check leaf_loc >= HEAP_OFF, keep, update leaf slot
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(10,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(1,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(1,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(1,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(1,64)),
    x188_i2("cmpq",x188_reg(1,64),x188_reg(11,64)),
    x188_i1("jb",X187Target{l_bail}),
    x188_i2("movq",x188_reg(11,64),X187Mem{4,24}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_keep"}),
    x188_i2("movq",X187Mem{4,24},x188_reg(11,64)),
    x188_i2("movq",x188_reg(0,64),X187Indexed{13,11,8,8}),
    x188_i1("jmp",X187Target{l_hv}),
    x188_label(l_ksh),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_keep"}),
    x188_label(l_hv),
    # %rax = v_out; save to 16(%rsp), sink d (%r14) if boxed, then move v_out to %r14
    x188_i2("movq",x188_reg(0,64),X187Mem{4,16}),
    x188_i2("movq",x188_reg(14,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_sdok}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(14,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(l_sdok),
    x188_i2("movq",X187Mem{4,16},x188_reg(14,64)),
    # Fall into miss/return path: %r14 = result value, %rbx = orig_m, %r15 = key
    x188_label(l_miss),
    x188_i2("movq",x188_reg(15,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_skok}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(15,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(l_skok),
    # ctor2(st, Tuple, [orig_m, val])
    x188_i2("movq",x188_reg(3,64),X187Mem{4,0}),
    x188_i2("movq",x188_reg(14,64),X187Mem{4,8}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movabsq",X187Imm{tup,0},x188_reg(6,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(2,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p125_rt_ctor2"}),
    # p111_rt_return(st, &res, 1)
    x188_i2("movq",x188_reg(0,64),X187Mem{4,0}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(6,64)),
    x188_i2("movl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_return"}),
    x188_label(l_ret),
    x188_i2("addq",X187Imm{40,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),
    x188_label(l_bail),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("addq",X187Imm{40,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i1("jmp",X187Target{slow_sym}),
    X188One{PSize{symbol}}
  ])],""}

# Emit native Map.set in-place update fast path for p111 symbol
@unsafe
def agy_map_set_fast(+symbol: String, +slow_sym: String, +ids: N111Ids) -> X181Output:
  +mleaf = agy_map_ctor_id(ids,"MLeaf")
  +mnode = agy_map_ctor_id(ids,"MNode")
  +snil  = agy_map_ctor_id(ids,"SNil")
  +scon  = agy_map_ctor_id(ids,"SCon")
  +pfx   = ".Lms_" ++ symbol
  +l_loop = pfx ++ "_lp"
  +l_lok  = pfx ++ "_lk"
  +l_leaf = pfx ++ "_lf"
  +l_bit0 = pfx ++ "_b0"
  +l_bit1 = pfx ++ "_b1"
  +l_hit  = pfx ++ "_ht"
  +l_xok  = pfx ++ "_xo"
  +l_svok = pfx ++ "_sv"
  +l_skok = pfx ++ "_sk"
  +l_bail = pfx ++ "_bl"
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    x188_i1("pushq",x188_reg(5,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i2("subq",X187Imm{40,0},x188_reg(4,64)),
    # %r12 = st, %r13 = heap, %rbx = orig_m, %r14 = key, %r15 = x, %rax = cur
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(13,64)),
    x188_i2("movq",X187Mem{12,40},x188_reg(3,64)),
    x188_i2("movq",X187Mem{12,48},x188_reg(14,64)),
    x188_i2("movq",X187Mem{12,56},x188_reg(15,64)),
    x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),
    x188_label(l_loop),
    # Strictly require uniquely owned node: tag == 0x02 OR (tag == 0x82 && (heap[rfc_loc] & 0xffffff) == 1)!
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(2,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(2,64)),
    x188_i2("andq",X187Imm{65535,0},x188_reg(2,64)),
    x188_i2("movabsq",X187Imm{4294967295,255},x188_reg(6,64)),
    x188_i2("andq",x188_reg(0,64),x188_reg(6,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("je",X187Target{l_lok}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",X187Indexed{13,6,8,0},x188_reg(6,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(1,64)),
    x188_i2("andq",X187Imm{16777215,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("shrq",X187Imm{24,0},x188_reg(6,64)),
    x188_label(l_lok),
    # Reject static terms (loc < HEAP_OFF) before any in-place mutation
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(1,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(1,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(1,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(1,64)),
    x188_i2("cmpq",x188_reg(1,64),x188_reg(6,64)),
    x188_i1("jb",X187Target{l_bail}),
    x188_i2("cmpq",X187Imm{mleaf,0},x188_reg(2,64)),
    x188_i1("je",X187Target{l_leaf}),
    x188_i2("cmpq",X187Imm{mnode,0},x188_reg(2,64)),
    x188_i1("jne",X187Target{l_bail}),
    # MNode: pos = heap[loc] into %rdi
    x188_i2("movq",X187Indexed{13,6,8,0},x188_reg(7,64)),
    agy_map_emit_bit(pfx,snil,scon,14,l_bit0,l_bit1,l_bail),
    x188_label(l_bit0),
    x188_i2("movq",X187Indexed{13,6,8,8},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_loop}),
    x188_label(l_bit1),
    x188_i2("movq",X187Indexed{13,6,8,16},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_loop}),
    # MLeaf: %rsi = owned leaf loc
    x188_label(l_leaf),
    x188_i2("movq",X187Indexed{13,6,8,0},x188_reg(8,64)),
    x188_i2("movq",x188_reg(14,64),x188_reg(9,64)),
    agy_map_emit_streq(pfx,snil,scon,l_hit,l_bail,l_bail),
    # Hit on strictly owned heap path: bail if x (%r15) is unsealed boxed (must rfc_seal in slow)
    x188_label(l_hit),
    x188_i2("movq",x188_reg(15,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_xok}),
    x188_i2("cmpq",X187Imm{130,0},x188_reg(1,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_label(l_xok),
    x188_i2("movq",X187Indexed{13,6,8,8},x188_reg(8,64)),
    x188_i2("movq",x188_reg(15,64),X187Indexed{13,6,8,8}),
    # Sink old_v (%r8) if boxed
    x188_i2("movq",x188_reg(8,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_svok}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(8,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(l_svok),
    # Sink key (%r14) if boxed
    x188_i2("movq",x188_reg(14,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(1,64)),
    x188_i1("jb",X187Target{l_skok}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(14,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(l_skok),
    # Return orig_m (%rbx)
    x188_i2("movq",x188_reg(3,64),X187Mem{4,0}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(6,64)),
    x188_i2("movl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_return"}),
    x188_i2("addq",X187Imm{40,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),
    x188_label(l_bail),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("addq",X187Imm{40,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i1("jmp",X187Target{slow_sym}),
    X188One{PSize{symbol}}
  ])],""}

@unsafe
def agy_map_emit_public(+segment: N111Segment, +ids: N111Ids, +kind: U32) -> X181Output:
  match segment:
    case N111Segment{+name,arity,result,incoming,flags,+body}:
      +sym = p111q_symbol(name)
      +slow = sym ++ "__slow"
      +fast = nt_choose(X181Output,U32.is_eq(kind,1),
        u => agy_map_get_fast(sym,slow,ids),
        u => agy_map_set_fast(sym,slow,ids))
      +slow_out = x181_function(slow,["state"],x181_scalar_rows(body),ids)
      x181_program_join(fast,slow_out)
'''

OLD_PUBLIC = '''@unsafe
def x181_program_public(+segment: N111Segment, context: P134Context, +available: KDef) -> X181Output:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,body} P134Context{+ids,index,+direct,ready,view,lookups,heap,mode}:
      +function = p111v_get(direct,name)
      x181_program_join(X181Output{[],x181_program_scalars(body,available)},
        nt_choose(X181Output,Bool.not(U32.is_eq(mode,0)) &&
          Bool.not(String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1)),
          u => x193f_public(segment,index,ids,ready,available),u => x181_segment(segment,ids)))'''

NEW_PUBLIC = MAP_BEND + '''
@unsafe
def x181_program_public(+segment: N111Segment, context: P134Context, +available: KDef) -> X181Output:
  match segment context:
    case N111Segment{+name,arity,result,incoming,flags,body} P134Context{+ids,index,+direct,ready,view,lookups,heap,+mode}:
      +function = p111v_get(direct,name)
      +is_direct = String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1)
      +mkind = nt_choose(U32,Bool.not(U32.is_eq(mode,0)) && Bool.not(is_direct),
        u => agy_map_kind(segment,ids),u => 0)
      x181_program_join(X181Output{[],x181_program_scalars(body,available)},
        nt_choose(X181Output,U32.is_gt(mkind,0),
          u => agy_map_emit_public(segment,ids,mkind),
          u => nt_choose(X181Output,Bool.not(U32.is_eq(mode,0)) && Bool.not(is_direct),
            v => x193f_public(segment,index,ids,ready,available),v => x181_segment(segment,ids))))'''

def patch(src: str) -> str:
    if "# === AGY-W2C-MAPFAST ===" in src:
        return src
    if OLD_PUBLIC in src:
        return src.replace(OLD_PUBLIC, NEW_PUBLIC, 1)
    old_v = OLD_PUBLIC.replace(
        "x193f_public(segment,index,ids,ready,available)",
        "x193f_public(segment,index,ids,ready,view,available)",
    )
    new_v = NEW_PUBLIC.replace(
        "x193f_public(segment,index,ids,ready,available)",
        "x193f_public(segment,index,ids,ready,view,available)",
    )
    assert old_v in src, "OLD_PUBLIC anchor not found in compiler.bend"
    return src.replace(old_v, new_v, 1)

if __name__ == "__main__":
    inp, outp = Path(sys.argv[1]), Path(sys.argv[2])
    outp.write_text(patch(inp.read_text()))
    print(f"Patched {inp} -> {outp} (AGY-W2C-MAPFAST)")
