#!/usr/bin/env python3
"""AGY-W2C-1: Certified In-Place Radix-Trie `Map.set` & `Map.del` Fast Paths.

Certifies Base's `Map<a, V>` radix-trie ADT layout (`MTip{}`, `MLeaf{String, V}`,
`MNode{Nat, Map, Map}`) and `Map.set` / `Map.del` definitions in `book`, and wraps
`p111_direct.Map.set` and `p111_direct.Map.del` with guarded, single-pass, in-place
x86 fast paths (preserving `agy_map_slow_<sym>` as exact fallback):
  - Unpacks `key` (`String`) once into a 64-char stack buffer (supporting both
    `TAG_CTR` and `RFC|TAG_CTR` strings read-only);
  - Computes `Map.bit(key, pos)` in O(1) using exact multiply-shift `pos / 33`
    (`M = 0xf83e0f84`, exact for all `pos < 65536`) with zero `divq` and zero
    string re-traversal;
  - Descends uniquely-owned cold heap `MNode`s in a single pass, recording
    `(slot_ptr, pos)` on the local stack (zero `MNode` rebuilds, zero `p111_`
    continuation frames);
  - Compares leaf key and computes `Map.diff` in one pass;
  - On `Map.set` hit: drops old `key` and `val` via `p111_rt_sink` and overwrites
    `val` in-place (0 allocations);
  - On `Map.set` miss: allocates 1 `MLeaf` + 1 `MNode` and splices in-place at
    the exact first `path[i].pos > diff`;
  - On `Map.del` hit: frees `MLeaf` + parent `MNode` in-place, splices sibling,
    and drops `key`, `k`, `v` via `p111_rt_sink` (0 allocations);
  - Bails cleanly with ZERO heap mutations on RFC-shared maps, static maps
    (`loc < HEAP_OFF`), hot ctors (`cid_hot != 0`), disabled capabilities,
    keys > 64 chars, depth > 64, empty freelist, or `KEEP_WORDS` boundary.
"""
import argparse
from pathlib import Path

DEFAULT_SRC = Path("/home/ai/bend2_agy/selfhost/build/agy/wave2_bst_b/compiler_all.bend")
DEFAULT_DST = Path("/home/ai/bend2_agy/selfhost/build/agy/wave2c_map/compiler.bend")

MAP_CODE = r"""
# ============================================================================
# AGY-W2C-1: Certified In-Place Radix-Trie `Map.set` & `Map.del` Fast Paths
# ============================================================================

@unsafe
def agy_map_has_ctor(+book: List<&2,KDef>, +adt_name: String, +ctor_name: String, +arity: U32) -> Bool:
  +adt = lookup(book,adt_name)
  +c = lookup(dc(adt),ctor_name)
  String.eq(dk(adt),"ADT") && String.eq(dk(c),"Ctr") && (U32.is_eq(da(c),arity) || U32.is_eq(U32.sub(da(c),dx(c)),arity))

@unsafe
def agy_map_has_def(+book: List<&2,KDef>, +name: String, +arity: U32) -> Bool:
  +d = lookup(book,name)
  String.eq(dk(d),"Def") && U32.is_eq(da(d),arity) && Bool.not(du(d))

@unsafe
def agy_map_book_ok(+book: List<&2,KDef>) -> Bool:
  agy_map_has_ctor(book,"Map","MTip",0) &&
  agy_map_has_ctor(book,"Map","MLeaf",2) &&
  agy_map_has_ctor(book,"Map","MNode",3) &&
  agy_map_has_ctor(book,"String","SNil",0) &&
  agy_map_has_ctor(book,"String","SCon",2) &&
  agy_map_has_ctor(book,"Char","Chr",1) &&
  agy_map_has_ctor(book,"Sigma","Tuple",2) &&
  agy_map_has_def(book,"Map.set",5) &&
  agy_map_has_def(book,"Map.set.go",4) &&
  agy_map_has_def(book,"Map.seek",4) &&
  agy_map_has_def(book,"Map.put",5) &&
  agy_map_has_def(book,"Map.ins",6) &&
  agy_map_has_def(book,"Map.diff",2) &&
  agy_map_has_def(book,"Map.bit",2) &&
  agy_map_has_def(book,"Map.del",4) &&
  agy_map_has_def(book,"Map.pop",4) &&
  agy_map_has_def(book,"Map.get",4) &&
  agy_map_has_def(book,"Map.get.go",4)

def agy_map_key(name: String) -> String: "$agy.map/" ++ name

@unsafe
def agy_map_mark_one(ids: N111Ids, +name: String, +kind: String) -> N111Ids:
  match ids:
    case N111Ids{+fs,cs}:
      +key = agy_map_key(name)
      +entry : KDef = KDef{key,kind,0,0,atom("Absent"),atom("Absent"),[],False{},False{}}
      N111Ids{nt_choose(KDef,String.eq(dk(p111v_get(fs,key)),"Absent"),
        u => index_set(fs,entry,index_hash(key,2166136261),32),u => fs),cs}

def agy_map_context(ctx: P134Context) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      P134Context{agy_map_mark_one(agy_map_mark_one(agy_map_mark_one(ids,
          "$direct.Map.set","AgyMapSet"),"$direct.Map.del","AgyMapDel"),"$direct.Map.get","AgyMapGet"),
        idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_map_cursor(cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_map_context(c),agy_map_cursor(next)}
    case P134Public{ss,c,next}: P134Public{ss,agy_map_context(c),agy_map_cursor(next)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_map_context(c),agy_map_cursor(next)}
    case p: p

@unsafe
def agy_map_ready(ok: Bool, p: P169Prepared) -> P169Prepared:
  match p:
    case P169Prepared{forwards,+cursor,+error}:
      P169Prepared{forwards,nt_choose(P134Cursor,ok && String.is_empty(error),
        u => agy_map_cursor(cursor),u => cursor),error}

@unsafe
def agy_map_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{source,+book,names,paths,scope,bound}:
      agy_map_ready(agy_map_book_ok(book),prepared)

@unsafe
def agy_map_get_mark(name: String, ids: N111Ids) -> KDef:
  match ids:
    case N111Ids{fs,cs}: p111v_get(fs,agy_map_key(name))

# Helper: emit sink-if-nontrivial for value in reg %rsi (clobbers %rax, %rcx, %rdx, %rdi, %rsi, %r8..%r11)
@unsafe
def agy_map_sink_rsi(+skip_lbl: String) -> X188Seq:
  x188_many([
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jb",X187Target{skip_lbl}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(skip_lbl)])

# Helper: unpack Chr{code} in %rax -> u32 code in %eax (handles unboxed U32 TAG_NUM, TAG_PAK, TAG_CTR, RFC|TAG_CTR); clobbers %rcx
@unsafe
def agy_map_unpack_chr(+prefix: String, +bail: String, +chr_cid: U32) -> X188Seq:
  +chr_pak = U32.add(65536,chr_cid)
  +chr_ctr = U32.add(131072,chr_cid)
  +l_pak = prefix ++ "_cp"
  +l_dir = prefix ++ "_cd"
  x188_many([
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(1,64)),
    x188_i2("testq",x188_reg(1,64),x188_reg(1,64)),
    x188_i1("jz",X187Target{l_pak}),
    x188_i2("shrq",X187Imm{8,0},x188_reg(1,64)),
    x188_i2("cmpq",X187Imm{chr_pak,0},x188_reg(1,64)),
    x188_i1("je",X187Target{l_pak}),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(1,32)),
    x188_i2("cmpl",X187Imm{chr_ctr,0},x188_reg(1,32)),
    x188_i1("jne",X187Target{bail}),
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(1,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(1,64)),
    x188_i2("shrq",X187Imm{63,0},x188_reg(0,64)),
    x188_i2("testl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jz",X187Target{l_dir}),
    x188_i2("movq",X187Indexed{13,1,8,0},x188_reg(1,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(1,64)),
    x188_label(l_dir),
    x188_i2("movl",X187Indexed{13,1,8,0},x188_reg(0,32)),
    x188_label(l_pak)])

# Shared key-unpack sequence: unpacks %r8 (String) into kbuf[0..%r15) at 0(%rbp), jumps to bail on >64 or bad tag
@unsafe
def agy_map_unpack_key(+prefix: String, +bail: String, +snil_hi: U32, +scon_cid: U32, +chr_cid: U32) -> X188Seq:
  +scon_chk = U32.add(131072,scon_cid)
  +l_lp = prefix ++ "_uk_lp"
  +l_dir = prefix ++ "_uk_dr"
  +l_dn = prefix ++ "_uk_dn"
  x188_many([
    x188_i2("xorl",x188_reg(15,32),x188_reg(15,32)),
    x188_label(l_lp),
    x188_i2("movabsq",X187Imm{0,snil_hi},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_dn}),
    x188_i2("cmpq",X187Imm{64,0},x188_reg(15,64)),
    x188_i1("jae",X187Target{bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(8,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{63,0},x188_reg(1,64)),
    x188_i2("testl",x188_reg(1,32),x188_reg(1,32)),
    x188_i1("jz",X187Target{l_dir}),
    x188_i2("movq",X187Indexed{13,0,8,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_label(l_dir),
    x188_i2("leaq",X187Indexed{13,0,8,0},x188_reg(9,64)),
    x188_i2("movq",X187Mem{9,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{9,8},x188_reg(8,64)),
    agy_map_unpack_chr(prefix ++ "_ukc",bail,chr_cid),
    x188_i2("movl",x188_reg(0,32),X187Indexed{5,15,4,0}),
    x188_i2("addq",X187Imm{1,0},x188_reg(15,64)),
    x188_i1("jmp",X187Target{l_lp}),
    x188_label(l_dn)])

# Shared bit(kbuf, %r15=klen, %rax=pos) -> %eax in {0,1}; clobbers %rcx, %rdx; jumps to bail if pos >= 2112
@unsafe
def agy_map_bit_at(+prefix: String, +bail: String) -> X188Seq:
  +l_b0 = prefix ++ "_b0"
  +l_b1 = prefix ++ "_b1"
  +l_bd = prefix ++ "_bd"
  x188_many([
    x188_i2("cmpq",X187Imm{2112,0},x188_reg(0,64)),
    x188_i1("jae",X187Target{bail}),
    x188_i2("movq",x188_reg(0,64),x188_reg(2,64)),
    x188_i2("movl",X187Imm{4164816772,0},x188_reg(1,32)),
    x188_i2("imulq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{37,0},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(15,64),x188_reg(0,64)),
    x188_i1("jae",X187Target{l_b0}),
    x188_i2("movq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("shlq",X187Imm{5,0},x188_reg(1,64)),
    x188_i2("addq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("subq",x188_reg(1,64),x188_reg(2,64)),
    x188_i2("testl",x188_reg(2,32),x188_reg(2,32)),
    x188_i1("jz",X187Target{l_b1}),
    x188_i2("movl",X187Indexed{5,0,4,0},x188_reg(0,32)),
    x188_i2("movl",X187Imm{32,0},x188_reg(1,32)),
    x188_i2("subl",x188_reg(2,32),x188_reg(1,32)),
    x188_i2("shrl",x188_reg(1,8),x188_reg(0,32)),
    x188_i2("andl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("jmp",X187Target{l_bd}),
    x188_label(l_b0),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jmp",X187Target{l_bd}),
    x188_label(l_b1),
    x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
    x188_label(l_bd)])

# Shared cmp_and_diff: compares kbuf[0..%r15) against %r9 (leaf_k).
# Jumps to eq_lbl if equal; jumps to diff_lbl with diff in %rax if unequal; jumps to bail on bad tag.
# Clobbers %rax, %rcx, %rdx, %r9, %r10, %r11.
@unsafe
def agy_map_cmp_diff(+prefix: String, +eq_lbl: String, +diff_lbl: String, +bail: String,
    +snil_hi: U32, +scon_cid: U32, +chr_cid: U32) -> X188Seq:
  +scon_chk = U32.add(131072,scon_cid)
  +chr_chk = U32.add(65536,chr_cid)
  +l_lp = prefix ++ "_cd_lp"
  +l_dir = prefix ++ "_cd_dr"
  +l_len = prefix ++ "_cd_ln"
  +l_msb = prefix ++ "_cd_mb"
  +l_dif = prefix ++ "_cd_df"
  x188_many([
    x188_i2("xorl",x188_reg(10,32),x188_reg(10,32)),
    x188_label(l_lp),
    x188_i2("movabsq",X187Imm{0,snil_hi},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_len}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{bail}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(9,64),x188_reg(1,64)),
    x188_i2("shrq",X187Imm{63,0},x188_reg(1,64)),
    x188_i2("testl",x188_reg(1,32),x188_reg(1,32)),
    x188_i1("jz",X187Target{l_dir}),
    x188_i2("movq",X187Indexed{13,0,8,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_label(l_dir),
    x188_i2("leaq",X187Indexed{13,0,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(9,64)),
    agy_map_unpack_chr(prefix ++ "_cdc",bail,chr_cid),
    x188_i2("cmpq",x188_reg(15,64),x188_reg(10,64)),
    x188_i1("je",X187Target{l_dif}),
    x188_i2("movl",X187Indexed{5,10,4,0},x188_reg(1,32)),
    x188_i2("xorl",x188_reg(1,32),x188_reg(0,32)),
    x188_i2("testl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jnz",X187Target{l_msb}),
    x188_i2("addq",X187Imm{1,0},x188_reg(10,64)),
    x188_i1("jmp",X187Target{l_lp}),
    # leaf_k hit SNil: equal iff ci == klen, else diff = ci * 33
    x188_label(l_len),
    x188_i2("cmpq",x188_reg(15,64),x188_reg(10,64)),
    x188_i1("je",X187Target{eq_lbl}),
    x188_label(l_dif),
    x188_i2("movq",x188_reg(10,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{5,0},x188_reg(0,64)),
    x188_i2("addq",x188_reg(10,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{diff_lbl}),
    # Char mismatch: %eax = cx ^ cy != 0 -> off = 33 - msb32(%eax)
    x188_label(l_msb),
    x188_i2("movl",X187Imm{33,0},x188_reg(2,32)),
    x188_label(prefix ++ "_cd_m2"),
    x188_i2("subl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("shrl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("jnz",X187Target{prefix ++ "_cd_m2"}),
    x188_i2("movq",x188_reg(10,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{5,0},x188_reg(0,64)),
    x188_i2("addq",x188_reg(10,64),x188_reg(0,64)),
    x188_i2("addq",x188_reg(2,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{diff_lbl})])

@unsafe
def agy_map_set_machine(+prefix: String, +slow: String, +mtip: U32, +mleaf: U32, +mnode: U32,
    +snil: U32, +scon: U32, +chr: U32) -> X188Seq:
  +mtip_hi = U32.add(16777216,U32.mul(mtip,256))
  +mleaf_hi = U32.add(33554432,U32.mul(mleaf,256))
  +mnode_hi = U32.add(33554432,U32.mul(mnode,256))
  +snil_hi = U32.add(16777216,U32.mul(snil,256))
  +mleaf_chk = U32.add(131072,mleaf)
  +mnode_chk = U32.add(131072,mnode)
  +l_bail = prefix ++ "_bl"
  +l_ret = prefix ++ "_rt"
  +l_tip_root = prefix ++ "_tr"
  +l_desc = prefix ++ "_ds"
  +l_leaf = prefix ++ "_lf"
  +l_eq = prefix ++ "_eq"
  +l_diff = prefix ++ "_df"
  +l_sp_lp = prefix ++ "_sl"
  +l_sp_ok = prefix ++ "_so"
  +l_sp_b1 = prefix ++ "_s1"
  +l_sp_wr = prefix ++ "_sw"
  x188_many([
    # Live descriptor checks: capabilities & 9 == 9, !cid_hot[mleaf], !cid_hot[mnode]
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("movl",X187Imm{mleaf,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(11,32)),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jnz",X187Target{slow}),
    x188_i2("movl",X187Imm{mnode,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(11,32)),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jnz",X187Target{slow}),
    # Prologue: 6 pushes (%rbp + 5) + sub $1320 -> 16B aligned; %rbp = %rsp
    x188_i1("pushq",x188_reg(5,64)),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i2("subq",X187Imm{1320,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(13,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(14,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(14,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(14,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(14,64)),
    # Load m, key, x from state->regs[0..2]
    x188_i2("movq",X187Mem{12,40},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,1280}),
    x188_i2("movq",X187Mem{12,48},x188_reg(8,64)),
    x188_i2("movq",x188_reg(8,64),X187Mem{4,1288}),
    x188_i2("movq",X187Mem{12,56},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{4,1296}),
    # Check if m == MTip{} (fast empty-map insert!)
    x188_i2("movabsq",X187Imm{0,mtip_hi},x188_reg(1,64)),
    x188_i2("cmpq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("je",X187Target{l_tip_root}),
    # Unpack key (%r8) into kbuf[0..%r15)
    agy_map_unpack_key(prefix,l_bail,snil_hi,scon,chr),
    # Descend map: %r8=cur, %r9=slot_ptr (0=root), %rbx=depth (0..64)
    x188_i2("movq",X187Mem{4,1280},x188_reg(8,64)),
    x188_i2("xorl",x188_reg(9,32),x188_reg(9,32)),
    x188_i2("xorl",x188_reg(3,32),x188_reg(3,32)),
    x188_label(l_desc),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{mleaf_chk,0},x188_reg(0,64)),
    x188_i1("je",X187Target{l_leaf}),
    x188_i2("cmpq",X187Imm{mnode_chk,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("cmpq",X187Imm{64,0},x188_reg(3,64)),
    x188_i1("jae",X187Target{l_bail}),
    # Extract loc, check loc >= HEAP_OFF
    x188_i2("movq",x188_reg(8,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("cmpq",x188_reg(14,64),x188_reg(10,64)),
    x188_i1("jb",X187Target{l_bail}),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(10,64)),
    # Record path[depth] = {slot_ptr=%r9, pos=mem[loc+0]} at 256(%rsp + depth*16)
    x188_i2("movq",x188_reg(3,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{4,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(9,64),X187Indexed{5,11,1,256}),
    x188_i2("movq",X187Mem{10,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Indexed{5,11,1,264}),
    x188_i2("addq",X187Imm{1,0},x188_reg(3,64)),
    # Compute bit(kbuf, klen, pos=%rax) -> %eax in {0,1}
    agy_map_bit_at(prefix ++ "_d",l_bail),
    # Next slot_ptr = &mem[loc + 1 + bit] = %r10 + 8 + bit*8
    x188_i2("leaq",X187Indexed{10,0,8,8},x188_reg(9,64)),
    x188_i2("movq",X187Mem{9,0},x188_reg(8,64)),
    x188_i1("jmp",X187Target{l_desc}),

    # Hit MTip at root: alloc MLeaf{key, x} from class-1 freelist (atOff=8, lenOff=264, words=2)
    x188_label(l_tip_root),
    x188_i2("movq",X187Mem{12,8},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,8},x188_reg(10,64)),
    x188_i2("testq",x188_reg(10,64),x188_reg(10,64)),
    x188_i1("jz",X187Target{l_bail}),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{0,8}),
    x188_i2("subq",X187Imm{2,0},X187Mem{0,264}),
    x188_i2("movq",X187Mem{4,1288},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{11,0}),
    x188_i2("movq",X187Mem{4,1296},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{11,8}),
    x188_i2("movabsq",X187Imm{0,mleaf_hi},x188_reg(0,64)),
    x188_i2("orq",x188_reg(10,64),x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_ret}),

    # Hit MLeaf (%r8=leaf_term, %r9=leaf_slot_ptr, %rbx=depth)
    x188_label(l_leaf),
    x188_i2("movq",x188_reg(8,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("cmpq",x188_reg(14,64),x188_reg(10,64)),
    x188_i1("jb",X187Target{l_bail}),
    # Save leaf_slot_ptr at 1304(%rsp) temporarily, leaf_ptr in %r8
    x188_i2("movq",x188_reg(9,64),X187Mem{4,1304}),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(8,64)),
    # Compare kbuf[0..%r15) against leaf_k = (%r8)
    x188_i2("movq",X187Mem{8,0},x188_reg(9,64)),
    agy_map_cmp_diff(prefix,l_eq,l_diff,l_bail,snil_hi,scon,chr),

    # Equal: replace value in-place! Save leaf_ptr in %rbx, old_v in %r15, overwrite (%rbx+8)=orig_x, sink orig_key & old_v
    x188_label(l_eq),
    x188_i2("movq",x188_reg(8,64),x188_reg(3,64)),
    x188_i2("movq",X187Mem{3,8},x188_reg(15,64)),
    x188_i2("movq",X187Mem{4,1296},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{3,8}),
    x188_i2("movq",X187Mem{4,1288},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk1"),
    x188_i2("movq",x188_reg(15,64),x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk2"),
    x188_i2("movq",X187Mem{4,1280},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_ret}),

    # Unequal: %rax = diff. Check class-1 (atOff=8) AND class-2 (atOff=16) freelists non-empty BEFORE mutating!
    x188_label(l_diff),
    x188_i2("movq",X187Mem{12,8},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,8},x188_reg(11,64)),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jz",X187Target{l_bail}),
    x188_i2("movq",X187Mem{10,16},x188_reg(9,64)),
    x188_i2("testq",x188_reg(9,64),x188_reg(9,64)),
    x188_i1("jz",X187Target{l_bail}),
    # Save diff in %r8
    x188_i2("movq",x188_reg(0,64),x188_reg(8,64)),
    # Compute new_bit = bit(kbuf, klen, diff=%rax) -> %eax in {0,1}; save in %r15 (klen no longer needed!)
    agy_map_bit_at(prefix ++ "_n",l_bail),
    x188_i2("movl",x188_reg(0,32),x188_reg(15,32)),
    # Find splice_slot_ptr: first path[i].pos > diff (%r8), else leaf_slot_ptr (1304(%rsp))
    x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
    x188_label(l_sp_lp),
    x188_i2("cmpq",x188_reg(3,64),x188_reg(1,64)),
    x188_i1("je",X187Target{l_sp_ok}),
    x188_i2("movq",x188_reg(1,64),x188_reg(2,64)),
    x188_i2("shlq",X187Imm{4,0},x188_reg(2,64)),
    x188_i2("movq",X187Indexed{5,2,1,264},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(8,64),x188_reg(0,64)),
    x188_i1("ja",X187Target{prefix ++ "_sf"}),
    x188_i2("addq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("jmp",X187Target{l_sp_lp}),
    x188_label(prefix ++ "_sf"),
    x188_i2("movq",X187Indexed{5,2,1,256},x188_reg(3,64)),
    x188_i1("jmp",X187Target{prefix ++ "_sa"}),
    x188_label(l_sp_ok),
    x188_i2("movq",X187Mem{4,1304},x188_reg(3,64)),
    # %rbx = splice_slot_ptr (0 if root!). Load old_sub into %r9:
    x188_label(prefix ++ "_sa"),
    x188_i2("testq",x188_reg(3,64),x188_reg(3,64)),
    x188_i1("jz",X187Target{prefix ++ "_sr"}),
    x188_i2("movq",X187Mem{3,0},x188_reg(9,64)),
    x188_i1("jmp",X187Target{prefix ++ "_al"}),
    x188_label(prefix ++ "_sr"),
    x188_i2("movq",X187Mem{4,1280},x188_reg(9,64)),
    # Pop MLeaf (class 1) -> %r11, MNode (class 2) -> %r10 (both verified non-empty above!)
    x188_label(prefix ++ "_al"),
    x188_i2("movq",X187Mem{12,8},x188_reg(0,64)),
    # Alloc MLeaf (class 1)
    x188_i2("movq",X187Mem{0,8},x188_reg(11,64)),
    x188_i2("leaq",X187Indexed{13,11,8,0},x188_reg(1,64)),
    x188_i2("movq",X187Mem{1,0},x188_reg(2,64)),
    x188_i2("movq",x188_reg(2,64),X187Mem{0,8}),
    x188_i2("subq",X187Imm{2,0},X187Mem{0,264}),
    x188_i2("movq",X187Mem{4,1288},x188_reg(2,64)),
    x188_i2("movq",x188_reg(2,64),X187Mem{1,0}),
    x188_i2("movq",X187Mem{4,1296},x188_reg(2,64)),
    x188_i2("movq",x188_reg(2,64),X187Mem{1,8}),
    x188_i2("movabsq",X187Imm{0,mleaf_hi},x188_reg(2,64)),
    x188_i2("orq",x188_reg(2,64),x188_reg(11,64)),
    # Alloc MNode (class 2): %r11=new_leaf, %r9=old_sub, %r8=diff, %r15=new_bit
    x188_i2("movq",X187Mem{0,16},x188_reg(10,64)),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(1,64)),
    x188_i2("movq",X187Mem{1,0},x188_reg(2,64)),
    x188_i2("movq",x188_reg(2,64),X187Mem{0,16}),
    x188_i2("subq",X187Imm{4,0},X187Mem{0,272}),
    x188_i2("movq",x188_reg(8,64),X187Mem{1,0}),
    x188_i2("testl",x188_reg(15,32),x188_reg(15,32)),
    x188_i1("jnz",X187Target{l_sp_b1}),
    x188_i2("movq",x188_reg(11,64),X187Mem{1,8}),
    x188_i2("movq",x188_reg(9,64),X187Mem{1,16}),
    x188_i1("jmp",X187Target{l_sp_wr}),
    x188_label(l_sp_b1),
    x188_i2("movq",x188_reg(9,64),X187Mem{1,8}),
    x188_i2("movq",x188_reg(11,64),X187Mem{1,16}),
    x188_label(l_sp_wr),
    x188_i2("movabsq",X187Imm{0,mnode_hi},x188_reg(0,64)),
    x188_i2("orq",x188_reg(10,64),x188_reg(0,64)),
    x188_i2("testq",x188_reg(3,64),x188_reg(3,64)),
    x188_i1("jz",X187Target{l_ret}),
    x188_i2("movq",x188_reg(0,64),X187Mem{3,0}),
    x188_i2("movq",X187Mem{4,1280},x188_reg(0,64)),

    # Return result_m (%rax) via p111_rt_return(state, &out, 1)
    x188_label(l_ret),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,1304}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("leaq",X187Mem{4,1304},x188_reg(6,64)),
    x188_i2("movl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_return"}),
    x188_i2("addq",X187Imm{1320,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),

    # Bailout: zero heap mutations occurred! Restore %rdi=state and jump to slow
    x188_label(l_bail),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("addq",X187Imm{1320,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i1("jmp",X187Target{slow})])

@unsafe
def agy_map_del_machine(+prefix: String, +slow: String, +mtip: U32, +mleaf: U32, +mnode: U32,
    +snil: U32, +scon: U32, +chr: U32) -> X188Seq:
  +mtip_hi = U32.add(16777216,U32.mul(mtip,256))
  +snil_hi = U32.add(16777216,U32.mul(snil,256))
  +mleaf_chk = U32.add(131072,mleaf)
  +mnode_chk = U32.add(131072,mnode)
  +l_bail = prefix ++ "_bl"
  +l_ret = prefix ++ "_rt"
  +l_tip_root = prefix ++ "_tr"
  +l_desc = prefix ++ "_ds"
  +l_leaf = prefix ++ "_lf"
  +l_eq = prefix ++ "_eq"
  +l_miss = prefix ++ "_ms"
  +l_pfree = prefix ++ "_pf"
  +l_sink = prefix ++ "_sn"
  x188_many([
    # Live descriptor checks: capabilities & 1 != 0 (fast free)
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i1("pushq",x188_reg(5,64)),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    # Stack layout (328 bytes, 16B aligned after 6 pushes; %rbp = %rsp):
    #   0..255: kbuf[64]
    #   256: orig_m
    #   264: orig_key
    #   272: parent_loc (0 if root)
    #   280: parent_slot_ptr (0 if parent is root)
    #   288: sibling_term
    #   296: saved leaf_k / leaf_v
    #   304: out_slot
    x188_i2("subq",X187Imm{328,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(13,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(14,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(14,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(14,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(14,64)),
    x188_i2("movq",X187Mem{12,40},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,256}),
    x188_i2("movq",X187Mem{12,48},x188_reg(8,64)),
    x188_i2("movq",x188_reg(8,64),X187Mem{4,264}),
    # Check if m == MTip{}
    x188_i2("movabsq",X187Imm{0,mtip_hi},x188_reg(1,64)),
    x188_i2("cmpq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("je",X187Target{l_tip_root}),
    # Unpack key (%r8) into kbuf[0..%r15)
    agy_map_unpack_key(prefix,l_bail,snil_hi,scon,chr),
    # Descend: %r8=cur, %rbx=cur_slot_ptr (0=root); parent_loc=0
    x188_i2("movq",X187Mem{4,256},x188_reg(8,64)),
    x188_i2("xorl",x188_reg(3,32),x188_reg(3,32)),
    x188_i2("movq",x188_reg(3,64),X187Mem{4,272}),
    x188_i2("movq",x188_reg(3,64),X187Mem{4,280}),
    x188_label(l_desc),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{mleaf_chk,0},x188_reg(0,64)),
    x188_i1("je",X187Target{l_leaf}),
    x188_i2("cmpq",X187Imm{mnode_chk,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("cmpq",x188_reg(14,64),x188_reg(10,64)),
    x188_i1("jb",X187Target{l_bail}),
    # Save parent_loc=%r10, parent_slot_ptr=%rbx
    x188_i2("movq",x188_reg(10,64),X187Mem{4,272}),
    x188_i2("movq",x188_reg(3,64),X187Mem{4,280}),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(0,64)),
    agy_map_bit_at(prefix ++ "_d",l_bail),
    # Child slot = &mem[loc + 1 + bit], sibling = mem[loc + 1 + (1 - bit)]
    x188_i2("leaq",X187Indexed{10,0,8,8},x188_reg(3,64)),
    x188_i2("xorl",X187Imm{1,0},x188_reg(0,32)),
    x188_i2("movq",X187Indexed{10,0,8,8},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{4,288}),
    x188_i2("movq",X187Mem{3,0},x188_reg(8,64)),
    x188_i1("jmp",X187Target{l_desc}),

    # Root MTip: sink key, return MTip
    x188_label(l_tip_root),
    x188_i2("movq",X187Mem{4,264},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk0"),
    x188_i2("movabsq",X187Imm{0,mtip_hi},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_ret}),

    # Hit MLeaf (%r8=leaf_term)
    x188_label(l_leaf),
    x188_i2("movq",x188_reg(8,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("cmpq",x188_reg(14,64),x188_reg(10,64)),
    x188_i1("jb",X187Target{l_bail}),
    # Save leaf_loc in %rbx, leaf_ptr in %r8
    x188_i2("movq",x188_reg(10,64),x188_reg(3,64)),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(8,64)),
    x188_i2("movq",X187Mem{8,0},x188_reg(9,64)),
    agy_map_cmp_diff(prefix,l_eq,l_miss,l_bail,snil_hi,scon,chr),

    # Key not found: sink orig_key, return orig_m unchanged!
    x188_label(l_miss),
    x188_i2("movq",X187Mem{4,264},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_skm"),
    x188_i2("movq",X187Mem{4,256},x188_reg(0,64)),
    x188_i1("jmp",X187Target{l_ret}),

    # Key found! Check freelist room (ALC_LEN[1]+2 < 32768 and ALC_LEN[2]+4 < 32768) BEFORE mutating!
    x188_label(l_eq),
    x188_i2("movq",X187Mem{12,8},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,264},x188_reg(10,64)),
    x188_i2("addq",X187Imm{2,0},x188_reg(10,64)),
    x188_i2("cmpq",X187Imm{32768,0},x188_reg(10,64)),
    x188_i1("jae",X187Target{l_bail}),
    x188_i2("movq",X187Mem{0,272},x188_reg(11,64)),
    x188_i2("addq",X187Imm{4,0},x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{32768,0},x188_reg(11,64)),
    x188_i1("jae",X187Target{l_bail}),
    # Load leaf_k (%r14, HEAP_OFF no longer needed!) and leaf_v (%r15, klen no longer needed!)
    x188_i2("movq",X187Mem{8,0},x188_reg(14,64)),
    x188_i2("movq",X187Mem{8,8},x188_reg(15,64)),
    # Free leaf_loc (%rbx) to class 1
    x188_i2("movq",X187Mem{0,8},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{8,0}),
    x188_i2("movq",x188_reg(3,64),X187Mem{0,8}),
    x188_i2("movq",x188_reg(10,64),X187Mem{0,264}),
    # Check parent_loc (272(%rsp)): if 0 -> root was MLeaf -> result = MTip!
    x188_i2("movq",X187Mem{4,272},x188_reg(2,64)),
    x188_i2("testq",x188_reg(2,64),x188_reg(2,64)),
    x188_i1("jnz",X187Target{l_pfree}),
    x188_i2("movabsq",X187Imm{0,mtip_hi},x188_reg(3,64)),
    x188_i1("jmp",X187Target{l_sink}),
    # Free parent_loc (%rdx) to class 2 and splice sibling (288(%rsp))
    x188_label(l_pfree),
    x188_i2("leaq",X187Indexed{13,2,8,0},x188_reg(8,64)),
    x188_i2("movq",X187Mem{0,16},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{8,0}),
    x188_i2("movq",x188_reg(2,64),X187Mem{0,16}),
    x188_i2("movq",x188_reg(11,64),X187Mem{0,272}),
    x188_i2("movq",X187Mem{4,280},x188_reg(9,64)),
    x188_i2("movq",X187Mem{4,288},x188_reg(3,64)),
    x188_i2("testq",x188_reg(9,64),x188_reg(9,64)),
    x188_i1("jz",X187Target{l_sink}),
    x188_i2("movq",x188_reg(3,64),X187Mem{9,0}),
    x188_i2("movq",X187Mem{4,256},x188_reg(3,64)),
    # Sink orig_key (264(%rsp)), leaf_k (%r14), leaf_v (%r15); result_m is in %rbx!
    x188_label(l_sink),
    x188_i2("movq",X187Mem{4,264},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk1"),
    x188_i2("movq",x188_reg(14,64),x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk2"),
    x188_i2("movq",x188_reg(15,64),x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk3"),
    x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),

    x188_label(l_ret),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,304}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("leaq",X187Mem{4,304},x188_reg(6,64)),
    x188_i2("movl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_return"}),
    x188_i2("addq",X187Imm{328,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),

    x188_label(l_bail),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("addq",X187Imm{328,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i1("jmp",X187Target{slow})])

@unsafe
def agy_map_get_machine(+prefix: String, +slow: String, +mtip: U32, +mleaf: U32, +mnode: U32,
    +snil: U32, +scon: U32, +chr: U32, +tup: U32) -> X188Seq:
  +mtip_hi = U32.add(16777216,U32.mul(mtip,256))
  +tup_hi = U32.add(33554432,U32.mul(tup,256))
  +snil_hi = U32.add(16777216,U32.mul(snil,256))
  +mleaf_chk = U32.add(131072,mleaf)
  +mnode_chk = U32.add(131072,mnode)
  +l_bail = prefix ++ "_bl"
  +l_ret = prefix ++ "_rt"
  +l_desc = prefix ++ "_ds"
  +l_ndir = prefix ++ "_nd"
  +l_leaf = prefix ++ "_lf"
  +l_ldir = prefix ++ "_ld"
  +l_hit = prefix ++ "_ht"
  +l_miss = prefix ++ "_ms"
  +l_mk = prefix ++ "_mk"
  x188_many([
    # Live descriptor checks: capabilities & 9 == 9, !cid_hot[tup]
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("movl",X187Imm{tup,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(11,32)),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jnz",X187Target{slow}),
    # Prologue: 6 pushes + sub $328 -> 16B aligned; %rbp = %rsp
    # 0..255: kbuf; 256: orig_d; 264: orig_m; 272: orig_key; 280: out_slot
    x188_i1("pushq",x188_reg(5,64)),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i1("pushq",x188_reg(14,64)),
    x188_i1("pushq",x188_reg(15,64)),
    x188_i2("subq",X187Imm{328,0},x188_reg(4,64)),
    x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(13,64)),
    # Load d (40), m (48), key (56)
    x188_i2("movq",X187Mem{12,40},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,256}),
    x188_i2("movq",X187Mem{12,48},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{4,264}),
    x188_i2("movq",X187Mem{12,56},x188_reg(8,64)),
    x188_i2("movq",x188_reg(8,64),X187Mem{4,272}),
    # Check m == MTip{}
    x188_i2("movabsq",X187Imm{0,mtip_hi},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(1,64)),
    x188_i1("je",X187Target{l_miss}),
    # Unpack key (%r8) into kbuf[0..%r15)
    agy_map_unpack_key(prefix,l_bail,snil_hi,scon,chr),
    # Read-only descent (supports both TAG_CTR and RFC|TAG_CTR and static maps!)
    x188_i2("movq",X187Mem{4,264},x188_reg(8,64)),
    x188_label(l_desc),
    x188_i2("movabsq",X187Imm{0,mtip_hi},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_miss}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{mleaf_chk,0},x188_reg(0,32)),
    x188_i1("je",X187Target{l_leaf}),
    x188_i2("cmpl",X187Imm{mnode_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{63,0},x188_reg(8,64)),
    x188_i2("testl",x188_reg(8,32),x188_reg(8,32)),
    x188_i1("jz",X187Target{l_ndir}),
    x188_i2("movq",X187Indexed{13,10,8,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_label(l_ndir),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(0,64)),
    agy_map_bit_at(prefix ++ "_g",l_bail),
    x188_i2("movq",X187Indexed{10,0,8,8},x188_reg(8,64)),
    x188_i1("jmp",X187Target{l_desc}),

    # Leaf reached: unwrap RFC if needed, compare leaf_k against kbuf
    x188_label(l_leaf),
    x188_i2("movq",x188_reg(8,64),x188_reg(10,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{63,0},x188_reg(8,64)),
    x188_i2("testl",x188_reg(8,32),x188_reg(8,32)),
    x188_i1("jz",X187Target{l_ldir}),
    x188_i2("movq",X187Indexed{13,10,8,0},x188_reg(10,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(10,64)),
    x188_label(l_ldir),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(3,64)),
    x188_i2("movq",X187Mem{3,0},x188_reg(9,64)),
    agy_map_cmp_diff(prefix,l_hit,l_miss,l_bail,snil_hi,scon,chr),

    # Hit: check leaf_v is trivial (< 0x0200000000000000) and class-1 freelist non-empty
    x188_label(l_hit),
    x188_i2("movq",X187Mem{3,8},x188_reg(15,64)),
    x188_i2("movq",x188_reg(15,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jae",X187Target{l_bail}),
    x188_i2("movq",X187Mem{12,8},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,8},x188_reg(10,64)),
    x188_i2("testq",x188_reg(10,64),x188_reg(10,64)),
    x188_i1("jz",X187Target{l_bail}),
    # Sink orig_key and orig_d, then build Tuple{orig_m, %r15}
    x188_i2("movq",X187Mem{4,272},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk1"),
    x188_i2("movq",X187Mem{4,256},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk2"),
    x188_i1("jmp",X187Target{l_mk}),

    # Miss: check class-1 freelist non-empty, sink orig_key, build Tuple{orig_m, orig_d}
    x188_label(l_miss),
    x188_i2("movq",X187Mem{12,8},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,8},x188_reg(10,64)),
    x188_i2("testq",x188_reg(10,64),x188_reg(10,64)),
    x188_i1("jz",X187Target{l_bail}),
    x188_i2("movq",X187Mem{4,272},x188_reg(6,64)),
    agy_map_sink_rsi(prefix ++ "_sk3"),
    x188_i2("movq",X187Mem{4,256},x188_reg(15,64)),

    # Allocate Tuple{orig_m, %r15} from class-1 freelist
    x188_label(l_mk),
    x188_i2("movq",X187Mem{12,8},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,8},x188_reg(10,64)),
    x188_i2("leaq",X187Indexed{13,10,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{0,8}),
    x188_i2("subq",X187Imm{2,0},X187Mem{0,264}),
    x188_i2("movq",X187Mem{4,264},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{11,0}),
    x188_i2("movq",x188_reg(15,64),X187Mem{11,8}),
    x188_i2("movabsq",X187Imm{0,tup_hi},x188_reg(0,64)),
    x188_i2("orq",x188_reg(10,64),x188_reg(0,64)),

    x188_label(l_ret),
    x188_i2("movq",x188_reg(0,64),X187Mem{4,280}),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("leaq",X187Mem{4,280},x188_reg(6,64)),
    x188_i2("movl",X187Imm{1,0},x188_reg(2,32)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_return"}),
    x188_i2("addq",X187Imm{328,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),

    x188_label(l_bail),
    x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
    x188_i2("addq",X187Imm{328,0},x188_reg(4,64)),
    x188_i1("popq",x188_reg(15,64)),
    x188_i1("popq",x188_reg(14,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("popq",x188_reg(5,64)),
    x188_i1("jmp",X187Target{slow})])

@unsafe
def agy_map_emit_wrap(+symbol: String, +slow: String, +kind: U32, +mtip: U32, +mleaf: U32, +mnode: U32,
    +snil: U32, +scon: U32, +chr: U32, +tup: U32) -> X181Output:
  +body = nt_choose(X188Seq,U32.is_eq(kind,0),
    u => agy_map_set_machine(".Lagy_ms_" ++ symbol,slow,mtip,mleaf,mnode,snil,scon,chr),
    u => nt_choose(X188Seq,U32.is_eq(kind,1),
      v => agy_map_del_machine(".Lagy_md_" ++ symbol,slow,mtip,mleaf,mnode,snil,scon,chr),
      v => agy_map_get_machine(".Lagy_mg_" ++ symbol,slow,mtip,mleaf,mnode,snil,scon,chr,tup)))
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},X188One{PLabel{symbol}},
    body,X188One{PSize{symbol}}])],""}

@unsafe
def agy_map_emit_segment(+segment: N111Segment, +ids: N111Ids, +kind: U32) -> X181Output:
  match segment:
    case N111Segment{+name,arity,result,incoming,flags,body}:
      +sym = p111q_symbol(name)
      +slow = "agy_map_slow_" ++ sym
      +mtip = x198pw_cid("MTip",ids)
      +mleaf = x198pw_cid("MLeaf",ids)
      +mnode = x198pw_cid("MNode",ids)
      +snil = x198pw_cid("SNil",ids)
      +scon = x198pw_cid("SCon",ids)
      +chr = x198pw_cid("Chr",ids)
      +tup = x198pw_cid("Tuple",ids)
      nt_choose(X181Output,
          x198pw_has_cid(mtip,0) && x198pw_has_cid(mleaf,2) && x198pw_has_cid(mnode,3) &&
          x198pw_has_cid(snil,0) && x198pw_has_cid(scon,2) && x198pw_has_cid(chr,1) &&
          x198pw_has_cid(tup,2),
        u => x181_program_join(
          agy_map_emit_wrap(sym,slow,kind,da(mtip),da(mleaf),da(mnode),da(snil),da(scon),da(chr),da(tup)),
          x181_function(slow,["state"],x181_scalar_rows(body),ids)),
        u => x181_segment(segment,ids))

@unsafe
def agy_map_try_public(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +view: KDef, +available: KDef) -> X181Output:
  match segment:
    case N111Segment{+name,arity,result,incoming,flags,body}:
      +mark = agy_map_get_mark(name,ids)
      nt_choose(X181Output,String.eq(dk(mark),"AgyMapSet"),
        u => agy_map_emit_segment(segment,ids,0),
        u => nt_choose(X181Output,String.eq(dk(mark),"AgyMapDel"),
          v => agy_map_emit_segment(segment,ids,1),
          v => nt_choose(X181Output,String.eq(dk(mark),"AgyMapGet"),
            w => agy_map_emit_segment(segment,ids,2),
            w => x193f_public(segment,index,ids,ready,view,available))))
"""

def once(s: str, old: str, new: str, label: str) -> str:
    n = s.count(old)
    assert n == 1, f"{label}: expected 1 match, got {n}"
    return s.replace(old, new, 1)

def patch(text: str) -> str:
    # Avoid symbol collision if wave2c_recagg/apply_map_fast.py is already present
    code = MAP_CODE
    if "# === AGY-W2C-MAPFAST ===" in text:
        # Chain Map.set slow path into wave2c_recagg's agy_map_set_fast (for 0x82 rc==1 record-aggregation)
        # and delegate Map.get to wave2c_recagg's agy_map_emit_public (which handles both 0x02 and 0x82)!
        code = code.replace(
            '        u => x181_program_join(\n'
            '          agy_map_emit_wrap(sym,slow,kind,da(mtip),da(mleaf),da(mnode),da(snil),da(scon),da(chr),da(tup)),\n'
            '          x181_function(slow,["state"],x181_scalar_rows(body),ids)),',
            '        u => x181_program_join(\n'
            '          agy_map_emit_wrap(sym,slow,kind,da(mtip),da(mleaf),da(mnode),da(snil),da(scon),da(chr),da(tup)),\n'
            '          nt_choose(X181Output,U32.is_eq(kind,0),\n'
            '            q => x181_program_join(agy_map_set_fast(slow,slow ++ "__rec",ids),\n'
            '              x181_function(slow ++ "__rec",["state"],x181_scalar_rows(body),ids)),\n'
            '            q => x181_function(slow,["state"],x181_scalar_rows(body),ids))),',
        )
        code = code.replace(
            '          v => nt_choose(X181Output,String.eq(dk(mark),"AgyMapGet"),\n'
            '            w => agy_map_emit_segment(segment,ids,2),\n'
            '            w => x193f_public(segment,index,ids,ready,view,available))))',
            '          v => nt_choose(X181Output,String.eq(dk(mark),"AgyMapGet"),\n'
            '            w => agy_map_emit_public(segment,ids,1),\n'
            '            w => x193f_public(segment,index,ids,ready,view,available))))',
        )
        anchor = "@unsafe\ndef x181_program_public("
        text = once(text, anchor, code + "\n\n" + anchor, "insert MAP_CODE_CHAIN")
        old_pub_chain = (
            '      +mkind = nt_choose(U32,Bool.not(U32.is_eq(mode,0)) && Bool.not(is_direct),\n'
            '        u => agy_map_kind(segment,ids),u => 0)\n'
            '      x181_program_join(X181Output{[],x181_program_scalars(body,available)},\n'
            '        nt_choose(X181Output,U32.is_gt(mkind,0),\n'
            '          u => agy_map_emit_public(segment,ids,mkind),\n'
            '          u => nt_choose(X181Output,Bool.not(U32.is_eq(mode,0)) && Bool.not(is_direct),\n'
            '            v => x193f_public(segment,index,ids,ready,view,available),v => x181_segment(segment,ids))))'
        )
        new_pub_chain = (
            '      +mark = agy_map_get_mark(name,ids)\n'
            '      +use_w2cm = Bool.not(U32.is_eq(mode,0)) && Bool.not(is_direct) &&\n'
            '        (String.eq(dk(mark),"AgyMapSet") || String.eq(dk(mark),"AgyMapDel") || String.eq(dk(mark),"AgyMapGet"))\n'
            '      +mkind = nt_choose(U32,Bool.not(U32.is_eq(mode,0)) && Bool.not(is_direct) && Bool.not(use_w2cm),\n'
            '        u => agy_map_kind(segment,ids),u => 0)\n'
            '      x181_program_join(X181Output{[],x181_program_scalars(body,available)},\n'
            '        nt_choose(X181Output,use_w2cm,\n'
            '          u => agy_map_try_public(segment,index,ids,ready,view,available),\n'
            '          u => nt_choose(X181Output,U32.is_gt(mkind,0),\n'
            '            v => agy_map_emit_public(segment,ids,mkind),\n'
            '            v => nt_choose(X181Output,Bool.not(U32.is_eq(mode,0)) && Bool.not(is_direct),\n'
            '              w => x193f_public(segment,index,ids,ready,view,available),w => x181_segment(segment,ids)))))'
        )
        text = once(text, old_pub_chain, new_pub_chain, "hook x181_program_public_chain")
    else:
        anchor = "@unsafe\ndef x181_program_public("
        text = once(text, anchor, code + "\n\n" + anchor, "insert MAP_CODE")
        old_pub = "u => x193f_public(segment,index,ids,ready,view,available),u => x181_segment(segment,ids)))"
        new_pub = "u => agy_map_try_public(segment,index,ids,ready,view,available),u => x181_segment(segment,ids)))"
        text = once(text, old_pub, new_pub, "hook x181_program_public")
    # Hook annotate at the single caller site (chains cleanly on top of agy_da_annotate / agy_fl_annotate / agy_zip_annotate / x198pw_annotate)
    if "agy_da_annotate(agy_fl_annotate(r,agy_zip_annotate(r,x198pw_annotate(r,prepared))))" in text:
        text = once(
            text,
            "agy_da_annotate(agy_fl_annotate(r,agy_zip_annotate(r,x198pw_annotate(r,prepared))))",
            "agy_map_annotate(r,agy_da_annotate(agy_fl_annotate(r,agy_zip_annotate(r,x198pw_annotate(r,prepared)))))",
            "hook agy_map_annotate_da",
        )
    elif "agy_fl_annotate(r,agy_zip_annotate(r,x198pw_annotate(r,prepared)))" in text:
        text = once(
            text,
            "agy_fl_annotate(r,agy_zip_annotate(r,x198pw_annotate(r,prepared)))",
            "agy_map_annotate(r,agy_fl_annotate(r,agy_zip_annotate(r,x198pw_annotate(r,prepared))))",
            "hook agy_map_annotate",
        )
    elif "x198pw_annotate(r,prepared)" in text:
        text = once(
            text,
            "u => x198pw_annotate(r,prepared),u => prepared)",
            "u => agy_map_annotate(r,x198pw_annotate(r,prepared)),u => prepared)",
            "hook agy_map_annotate",
        )
    else:
        raise RuntimeError("Could not find annotate hook point")
    return text

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    a = ap.parse_args()
    out = patch(a.src.read_text())
    a.dst.parent.mkdir(parents=True, exist_ok=True)
    a.dst.write_text(out)
    print(f"Patched AGY-W2C-1 (certified Map.set/del fast path) -> {a.dst} ({len(out)} bytes)")

if __name__ == "__main__":
    main()
