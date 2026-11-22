#!/usr/bin/env python3
"""Wave 3B Track B2: Native x86-64 String/Hash/Tag Killer (`AGY-W3B-STRHASH`).

Composable patcher transforming `wave2_unified/compiler.bend` -> `wave3b_strhash/compiler.bend`:
  1. Source-level `String.eq(` -> `p88_string_eq(` rewrite in `compiler.bend` (outside string
     literals and comments), routing all ~2,061 string equality sites away from `Base.String.order.go`
     directly into our native x86-64 fast path.
  2. Dual-seed 64-bit AST certification (`agy_sh_annotate`, matching `AGY-W2-BASEPIN` discipline)
     verifying exact `String`/`Char`/`Bool`/`KTerm` ADT layouts and exact function bodies before
     marking `$agy.sh/{eq_go,eq,base_eq,hash,tageq}` in `N111Ids`.
  3. Tight native x86-64 register loops in `x181_direct` (with `capabilities & 9 == 9`, `!cid_hot[*]`,
     RFC unwrapping, pointer-equality short-circuit, and 100% transparent fallback to original
     `__sh_slow` on thunks/observers/non-standard tags):
     - `p88_string_eq_go` (`$p118borrow.read.*`, `$p128borrow.owned.*`, `$direct.*`)
     - `p88_string_eq`    (`$p118borrow.read.*`, `$p128borrow.owned.*`, `$direct.*`)
     - `String.eq`        (`$p118borrow.read.*`, `$p128borrow.owned.*`, `$direct.*`)
     - `index_hash`       (`$p118borrow.read.*`, `$p128borrow.owned.*`, `$direct.*`) — zero-stack leaf loop!
     - `p98_tag_eq` / `p98_tag_eq_read` (`$p118borrow.read.*`, `$p128borrow.owned.*`, `$direct.*`)
"""
import argparse
from pathlib import Path

DEFAULT_SRC = Path("/home/ai/bend2_agy/selfhost/build/agy/wave2_unified/compiler.bend")
DEFAULT_DST = Path("/home/ai/bend2_agy/selfhost/build/agy/wave3b_strhash/compiler.bend")

STRHASH_ANNOTATE_CODE = r"""
# ============================================================================
# AGY-W3B-STRHASH: Certified Native x86-64 String/Hash/Tag Fast Paths
# ============================================================================

@unsafe
def agy_sh_def_hash(+book: List<&2,KDef>, +name: String, +seed: U32) -> U32:
  +d = lookup(book,name)
  nt_choose(U32,String.eq(dk(d),"Def"),
    u =>
      +h1 = agy_bp_str(name,seed)
      +h2 = agy_bp_mix(agy_bp_mix(h1,da(d)),dx(d))
      agy_bp_term(dv(d),h2),
    u => 0)

@unsafe
def agy_sh_def_pin(+book: List<&2,KDef>, +name: String, +h1: U32, +h2: U32) -> Bool:
  U32.is_eq(agy_sh_def_hash(book,name,2166136261),h1) &&
  U32.is_eq(agy_sh_def_hash(book,name,33554467),h2)

@unsafe
def agy_sh_str_adts_ok(+book: List<&2,KDef>) -> Bool:
  agy_map_has_ctor(book,"String","SNil",0) &&
  agy_map_has_ctor(book,"String","SCon",2) &&
  agy_map_has_ctor(book,"Char","Chr",1) &&
  agy_map_has_ctor(book,"Bool","False",0) &&
  agy_map_has_ctor(book,"Bool","True",0)

@unsafe
def agy_sh_kterm_adt_ok(+book: List<&2,KDef>) -> Bool:
  agy_map_has_ctor(book,"KTerm","KTerm",8) &&
  agy_map_has_ctor(book,"KTerm","KLambda",8) &&
  agy_map_has_ctor(book,"KTerm","KLiteral",5)

@unsafe
def agy_sh_ctx(ctx: P134Context, +eq_go_ok: Bool, +eq_ok: Bool, +base_eq_ok: Bool, +hash_ok: Bool, +tageq_ok: Bool) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      +i1 = nt_choose(N111Ids,eq_go_ok,u => agy_bp_mark_ids(ids,"$agy.sh/eq_go"),u => ids)
      +i2 = nt_choose(N111Ids,eq_ok,u => agy_bp_mark_ids(i1,"$agy.sh/eq"),u => i1)
      +i3 = nt_choose(N111Ids,base_eq_ok,u => agy_bp_mark_ids(i2,"$agy.sh/base_eq"),u => i2)
      +i4 = nt_choose(N111Ids,hash_ok,u => agy_bp_mark_ids(i3,"$agy.sh/hash"),u => i3)
      +i5 = nt_choose(N111Ids,tageq_ok,u => agy_bp_mark_ids(i4,"$agy.sh/tageq"),u => i4)
      P134Context{i5,idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_sh_cursor(cursor: P134Cursor, +eq_go_ok: Bool, +eq_ok: Bool, +base_eq_ok: Bool, +hash_ok: Bool, +tageq_ok: Bool) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_sh_ctx(c,eq_go_ok,eq_ok,base_eq_ok,hash_ok,tageq_ok),agy_sh_cursor(next,eq_go_ok,eq_ok,base_eq_ok,hash_ok,tageq_ok)}
    case P134Public{ss,c,next}: P134Public{ss,agy_sh_ctx(c,eq_go_ok,eq_ok,base_eq_ok,hash_ok,tageq_ok),agy_sh_cursor(next,eq_go_ok,eq_ok,base_eq_ok,hash_ok,tageq_ok)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_sh_ctx(c,eq_go_ok,eq_ok,base_eq_ok,hash_ok,tageq_ok),agy_sh_cursor(next,eq_go_ok,eq_ok,base_eq_ok,hash_ok,tageq_ok)}
    case p: p

@unsafe
def agy_sh_apply(prepared: P169Prepared, +eq_go_ok: Bool, +eq_ok: Bool, +base_eq_ok: Bool, +hash_ok: Bool, +tageq_ok: Bool) -> P169Prepared:
  match prepared:
    case P169Prepared{forwards,+cursor,+error}:
      +any_ok = eq_go_ok || eq_ok || base_eq_ok || hash_ok || tageq_ok
      P169Prepared{forwards,nt_choose(P134Cursor,any_ok && String.is_empty(error),
        u => agy_sh_cursor(cursor,eq_go_ok,eq_ok,base_eq_ok,hash_ok,tageq_ok),u => cursor),error}

@unsafe
def agy_sh_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{source,+book,names,paths,scope,bound}:
      +adts = agy_sh_str_adts_ok(book)
      +chr_eq_ok = agy_sh_def_pin(book,"Char.is_eq",3302228733,42192839)
      +chr_u32_ok = agy_sh_def_pin(book,"Char.to_u32",1968267531,1583642761)
      +eq_go_ok = adts && chr_eq_ok && agy_sh_def_pin(book,"p88_string_eq_go",3024631756,2674381182)
      +eq_ok = eq_go_ok &&
        agy_sh_def_pin(book,"p98_eq_finish",165389557,2460805607) &&
        agy_sh_def_pin(book,"p88_string_eq",3716379759,1182868109)
      +base_eq_ok = adts && chr_u32_ok &&
        agy_sh_def_pin(book,"String.eq",225128774,712577888) &&
        agy_sh_def_pin(book,"String.order",565631753,2204196711) &&
        agy_sh_def_pin(book,"String.order.go",3716281844,3937681030)
      +hash_ok = adts && chr_u32_ok && agy_sh_def_pin(book,"index_hash",1696180074,3131242088)
      +tageq_ok = eq_ok && agy_sh_kterm_adt_ok(book) &&
        agy_sh_def_pin(book,"p98_tag_eq_read",572502218,3139754552) &&
        agy_sh_def_pin(book,"p98_tag_eq_finish",133393152,3410656966) &&
        agy_sh_def_pin(book,"p98_tag_eq",2318141704,1837477542)
      agy_sh_apply(prepared,eq_go_ok,eq_ok,base_eq_ok,hash_ok,tageq_ok)
"""

STRHASH_EMIT_CODE = r"""
# ============================================================================
# AGY-W3B-STRHASH: Native x86-64 Emitters for String Eq / FNV-1a Hash / Tag Eq
# ============================================================================

@unsafe
def agy_sh_cid(ids: N111Ids, +name: String) -> U32:
  match ids:
    case N111Ids{functions,constructors}:
      +found = index_find(constructors,name,index_hash(name,2166136261),32)
      nt_choose(U32,String.eq(dk(found),"N111Id"),u => da(found),u => 4294967295)

@unsafe
def agy_sh_has_mark(+ids: N111Ids, +key: String) -> Bool:
  match ids:
    case N111Ids{fs,_}: String.eq(dk(p111v_get(fs,key)),"AgyBasePinned")

# Check !cid_hot[cid]; expects %rax = cid_hot base, clobbers %r10, %r11
@unsafe
def agy_sh_chk_hot(+cid: U32, +slow: String) -> X188Seq:
  x188_many([
    x188_i2("movl",X187Imm{cid,0},x188_reg(10,32)),
    x188_i2("movzbl",X187Indexed{0,10,1,0},x188_reg(11,32)),
    x188_i2("testl",x188_reg(11,32),x188_reg(11,32)),
    x188_i1("jnz",X187Target{slow})])

# Guard capabilities & 9 == 9 and cid_hot != NULL; leaves cid_hot base in %rax
@unsafe
def agy_sh_guard_caps(+slow: String) -> X188Seq:
  x188_many([
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{9,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{9,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jz",X187Target{slow})])

# Unpack Char in %rax -> u32 in %eax (zero-extended); %r10 = heap; clobbers %r11; jumps to bail on thunk/bad tag
@unsafe
def agy_sh_unpack_chr(+prefix: String, +bail: String, +chr_cid: U32) -> X188Seq:
  +chr_pak = U32.add(65536,chr_cid)
  +chr_ctr = U32.add(131072,chr_cid)
  +l_pak = prefix ++ "_cp"
  +l_dir = prefix ++ "_cd"
  +l_ok = prefix ++ "_ok"
  x188_many([
    x188_i2("movq",x188_reg(0,64),x188_reg(11,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jz",X187Target{l_ok}),
    x188_i2("shrq",X187Imm{8,0},x188_reg(11,64)),
    x188_i2("cmpq",X187Imm{chr_pak,0},x188_reg(11,64)),
    x188_i1("je",X187Target{l_pak}),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(11,32)),
    x188_i2("cmpl",X187Imm{chr_ctr,0},x188_reg(11,32)),
    x188_i1("jne",X187Target{bail}),
    x188_i2("movq",x188_reg(0,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jge",X187Target{l_dir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_dir),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),x188_reg(11,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jnz",X187Target{bail}),
    x188_i1("jmp",X187Target{l_ok}),
    x188_label(l_pak),
    x188_i2("movl",x188_reg(0,32),x188_reg(0,32)),
    x188_label(l_ok)])

# Shared SCon equality loop: expects %r8=cur_a, %r9=cur_b, %r10=heap, %r12=snil_word.
# Clobbers %rax, %rbx, %r8, %r9, %r11, %r13. Preserves %rdi, %rsi, %rdx, %rcx, %r10, %r12.
# Jumps to l_true, l_false, or l_bail.
@unsafe
def agy_sh_streq_loop(+pfx: String, +l_true: String, +l_false: String, +l_bail: String,
    +scon_cid: U32, +chr_cid: U32) -> X188Seq:
  +scon_chk = U32.add(131072,scon_cid)
  +l_lp = pfx ++ "_lp"
  +l_anil = pfx ++ "_an"
  +l_adir = pfx ++ "_ad"
  +l_bdir = pfx ++ "_bd"
  +l_schr = pfx ++ "_sc"
  x188_many([
    x188_label(l_lp),
    x188_i2("cmpq",x188_reg(12,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_anil}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    # r8 is KNOWN SCon: pointer equality short-circuits identical/shared strings!
    x188_i2("cmpq",x188_reg(8,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_true}),
    x188_i2("cmpq",x188_reg(12,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_false}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    # Deref r8 -> h1 (%rax), t1 (%r8)
    x188_i2("movq",x188_reg(8,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("jge",X187Target{l_adir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_adir),
    x188_i2("leaq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(8,64)),
    # Deref r9 -> h2 (%rbx), t2 (%r9)
    x188_i2("movq",x188_reg(9,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(9,64),x188_reg(9,64)),
    x188_i1("jge",X187Target{l_bdir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_bdir),
    x188_i2("leaq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(3,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(9,64)),
    # Fast unboxed Char path: if ((h1 | h2) >> 32) == 0, compare 32-bit directly!
    x188_i2("movq",x188_reg(0,64),x188_reg(11,64)),
    x188_i2("orq",x188_reg(3,64),x188_reg(11,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(11,64),x188_reg(11,64)),
    x188_i1("jnz",X187Target{l_schr}),
    x188_i2("cmpl",x188_reg(3,32),x188_reg(0,32)),
    x188_i1("jne",X187Target{l_false}),
    x188_i1("jmp",X187Target{l_lp}),
    # General Char path (TAG_PAK / TAG_CTR / RFC|TAG_CTR / bail on thunk)
    x188_label(l_schr),
    agy_sh_unpack_chr(pfx ++ "_c1",l_bail,chr_cid),
    x188_i2("movl",x188_reg(0,32),x188_reg(13,32)),
    x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),
    agy_sh_unpack_chr(pfx ++ "_c2",l_bail,chr_cid),
    x188_i2("cmpl",x188_reg(13,32),x188_reg(0,32)),
    x188_i1("jne",X187Target{l_false}),
    x188_i1("jmp",X187Target{l_lp}),
    # a == SNil: true iff b == SNil; else verify b is SCon (bail on thunk!)
    x188_label(l_anil),
    x188_i2("cmpq",x188_reg(12,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_true}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i1("jmp",X187Target{l_false})])

# Epilogue for 2-arg owned/borrowed Bool return (%rax = 0 or 1), after push %rbx, %r12, %r13 (16B aligned).
# Expects %rdi=state, %rsi=orig_a, %rdx=orig_b.
@unsafe
def agy_sh_epilogue_2(+pfx: String, +slow: String, +l_true: String, +l_false: String, +l_bail: String, +owned: Bool) -> X188Seq:
  +l_done = pfx ++ "_dn"
  +l_sk1 = pfx ++ "_s1"
  +l_sk2 = pfx ++ "_s2"
  +sink_seq = nt_choose(X188Seq,owned,
    u => x188_many([
      x188_i2("movl",x188_reg(0,32),x188_reg(13,32)),
      x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
      x188_i2("movq",x188_reg(2,64),x188_reg(3,64)),
      x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
      x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
      x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
      x188_i1("jb",X187Target{l_sk1}),
      x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
      x188_i1("call",X187Target{"p111_rt_sink"}),
      x188_label(l_sk1),
      x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),
      x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
      x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
      x188_i1("jb",X187Target{l_sk2}),
      x188_i2("movq",x188_reg(12,64),x188_reg(7,64)),
      x188_i2("movq",x188_reg(3,64),x188_reg(6,64)),
      x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
      x188_i1("call",X187Target{"p111_rt_sink"}),
      x188_label(l_sk2),
      x188_i2("movl",x188_reg(13,32),x188_reg(0,32))]),
    u => X188Empty{})
  x188_many([
    x188_label(l_false),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jmp",X187Target{l_done}),
    x188_label(l_true),
    x188_i2("movl",X187Imm{1,0},x188_reg(0,32)),
    x188_label(l_done),
    sink_seq,
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    x188_label(l_bail),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("jmp",X187Target{slow})])

# Machine 1: Native String equality (p88_string_eq_go / p88_string_eq / String.eq)
@unsafe
def agy_sh_emit_streq(+symbol: String, +slow: String, +snil: U32, +scon: U32, +chr: U32,
    +check_same: Bool, +owned: Bool) -> X181Output:
  +pfx = ".Lsh_eq_" ++ symbol
  +snil_hi = U32.add(16777216,U32.mul(snil,256))
  +l_true = pfx ++ "_tr"
  +l_false = pfx ++ "_fl"
  +l_bail = pfx ++ "_bl"
  +same_chk = nt_choose(X188Seq,check_same,
    u => x188_many([
      x188_i2("cmpq",X187Imm{1,0},x188_reg(1,64)),
      x188_i1("jne",X187Target{slow})]),
    u => X188Empty{})
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    same_chk,
    agy_sh_guard_caps(slow),
    agy_sh_chk_hot(scon,slow),
    agy_sh_chk_hot(snil,slow),
    agy_sh_chk_hot(chr,slow),
    # 3 pushes -> 16B stack aligned
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(10,64)),
    x188_i2("movabsq",X187Imm{0,snil_hi},x188_reg(12,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("movq",x188_reg(2,64),x188_reg(9,64)),
    agy_sh_streq_loop(pfx,l_true,l_false,l_bail,scon,chr),
    agy_sh_epilogue_2(pfx,slow,l_true,l_false,l_bail,owned),
    X188One{PSize{symbol}}])],""}

# Machine 2: Native FNV-1a index_hash(state=%rdi, name=%rsi, acc=%rdx) -> U32
# Borrowed variant is a ZERO-STACK leaf function!
@unsafe
def agy_sh_emit_hash(+symbol: String, +slow: String, +snil: U32, +scon: U32, +chr: U32, +owned: Bool) -> X181Output:
  +pfx = ".Lsh_hs_" ++ symbol
  +snil_hi = U32.add(16777216,U32.mul(snil,256))
  +scon_chk = U32.add(131072,scon)
  +l_lp = pfx ++ "_lp"
  +l_dir = pfx ++ "_dr"
  +l_done = pfx ++ "_dn"
  +l_sk = pfx ++ "_sk"
  +done_seq = nt_choose(X188Seq,owned,
    u => x188_many([
      x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
      x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
      x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
      x188_i1("jb",X187Target{l_sk}),
      x188_i1("pushq",x188_reg(3,64)),
      x188_i2("movl",x188_reg(1,32),x188_reg(3,32)),
      x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
      x188_i1("call",X187Target{"p111_rt_sink"}),
      x188_i2("movl",x188_reg(3,32),x188_reg(0,32)),
      x188_i1("popq",x188_reg(3,64)),
      x188_i0("ret"),
      x188_label(l_sk),
      x188_i2("movl",x188_reg(1,32),x188_reg(0,32)),
      x188_i0("ret")]),
    u => x188_many([
      x188_i2("movl",x188_reg(1,32),x188_reg(0,32)),
      x188_i0("ret")]))
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    # Verify acc is unboxed U32 (top 32 bits == 0)
    x188_i2("movq",x188_reg(2,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jnz",X187Target{slow}),
    agy_sh_guard_caps(slow),
    agy_sh_chk_hot(scon,slow),
    agy_sh_chk_hot(snil,slow),
    agy_sh_chk_hot(chr,slow),
    # Leaf loop: %r8=cur, %r9=snil, %r10=heap, %ecx=h; %rdi/%rsi/%rdx untouched so bail jumps directly to slow!
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("movabsq",X187Imm{0,snil_hi},x188_reg(9,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(10,64)),
    x188_i2("movl",x188_reg(2,32),x188_reg(1,32)),
    x188_label(l_lp),
    x188_i2("cmpq",x188_reg(9,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_done}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{slow}),
    x188_i2("movq",x188_reg(8,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("jge",X187Target{l_dir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_dir),
    x188_i2("leaq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(8,64)),
    agy_sh_unpack_chr(pfx ++ "_c",slow,chr),
    x188_i2("xorl",x188_reg(0,32),x188_reg(1,32)),
    x188_i2("movl",X187Imm{16777619,0},x188_reg(0,32)),
    x188_i2("imull",x188_reg(0,32),x188_reg(1,32)),
    x188_i1("jmp",X187Target{l_lp}),
    x188_label(l_done),
    done_seq,
    X188One{PSize{symbol}}])],""}

# Helper for p98_tag_eq: match one char in %r9 against expected u32, advancing %r9 to tail.
# Expects %r10=heap, %r12=snil_word. Clobbers %rax, %r11.
@unsafe
def agy_sh_match_ch(+pfx: String, +l_false: String, +l_bail: String, +scon_chk: U32, +chr: U32, +ch: U32) -> X188Seq:
  +l_dir = pfx ++ "_dr"
  x188_many([
    x188_i2("cmpq",x188_reg(12,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_false}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(9,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(9,64),x188_reg(9,64)),
    x188_i1("jge",X187Target{l_dir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_dir),
    x188_i2("leaq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(9,64)),
    agy_sh_unpack_chr(pfx ++ "_c",l_bail,chr),
    x188_i2("cmpl",X187Imm{ch,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_false})])

# Match %r9 against 3-char literal (c0, c1, c2) followed by SNil
@unsafe
def agy_sh_match_lit3(+pfx: String, +l_true: String, +l_false: String, +l_bail: String,
    +scon_chk: U32, +chr: U32, +c0: U32, +c1: U32, +c2: U32) -> X188Seq:
  x188_many([
    agy_sh_match_ch(pfx ++ "_0",l_false,l_bail,scon_chk,chr,c0),
    agy_sh_match_ch(pfx ++ "_1",l_false,l_bail,scon_chk,chr,c1),
    agy_sh_match_ch(pfx ++ "_2",l_false,l_bail,scon_chk,chr,c2),
    x188_i2("cmpq",x188_reg(12,64),x188_reg(9,64)),
    x188_i1("je",X187Target{l_true}),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i1("jmp",X187Target{l_false})])

# Machine 3: Native p98_tag_eq / p98_tag_eq_read(state=%rdi, term=%rsi, key=%rdx) -> Bool
@unsafe
def agy_sh_emit_tageq(+symbol: String, +slow: String, +snil: U32, +scon: U32, +chr: U32,
    +kterm: U32, +klam: U32, +klit: U32, +owned: Bool) -> X181Output:
  +pfx = ".Lsh_tq_" ++ symbol
  +snil_hi = U32.add(16777216,U32.mul(snil,256))
  +scon_chk = U32.add(131072,scon)
  +kterm_chk = U32.add(131072,kterm)
  +klam_chk = U32.add(131072,klam)
  +klit_chk = U32.add(131072,klit)
  +l_true = pfx ++ "_tr"
  +l_false = pfx ++ "_fl"
  +l_bail = pfx ++ "_bl"
  +l_tdir = pfx ++ "_td"
  +l_klam = pfx ++ "_kl"
  +l_klit = pfx ++ "_ki"
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    agy_sh_guard_caps(slow),
    agy_sh_chk_hot(scon,slow),
    agy_sh_chk_hot(snil,slow),
    agy_sh_chk_hot(chr,slow),
    agy_sh_chk_hot(kterm,slow),
    agy_sh_chk_hot(klam,slow),
    agy_sh_chk_hot(klit,slow),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(10,64)),
    x188_i2("movabsq",X187Imm{0,snil_hi},x188_reg(12,64)),
    x188_i2("movq",x188_reg(2,64),x188_reg(9,64)),
    # Dispatch on term (%rsi) tag_aux
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{kterm_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_klam}),
    # KTerm{tag, ...}: load field 0 into %r8, fall into streq_loop
    x188_i2("movq",x188_reg(6,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jge",X187Target{l_tdir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_tdir),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(8,64)),
    agy_sh_streq_loop(pfx,l_true,l_false,l_bail,scon,chr),
    # KLambda -> match "Lam" (76, 97, 109)
    x188_label(l_klam),
    x188_i2("cmpl",X187Imm{klam_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_klit}),
    agy_sh_match_lit3(pfx ++ "_lm",l_true,l_false,l_bail,scon_chk,chr,76,97,109),
    # KLiteral -> match "Lit" (76, 105, 116)
    x188_label(l_klit),
    x188_i2("cmpl",X187Imm{klit_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    agy_sh_match_lit3(pfx ++ "_lt",l_true,l_false,l_bail,scon_chk,chr,76,105,116),
    agy_sh_epilogue_2(pfx,slow,l_true,l_false,l_bail,owned),
    X188One{PSize{symbol}}])],""}

# Dispatcher in x181_direct: matches certified p113d_* functions and wraps with fast x86-64 loop
@unsafe
def agy_sh_wrap(+function: P113DFunction, +ids: N111Ids, +fast: X181Output, +slow: String) -> Maybe<&2,X181Output>:
  match function:
    case P113DFunction{name,params,result,public,body}:
      +pnames : List<&2,String> = Con{"state",x181_param_names(params)}
      Some{x181_program_join(fast,x181_function(slow,pnames,body,ids))}

@unsafe
def agy_sh_try(+function: P113DFunction, +ids: N111Ids) -> Maybe<&2,X181Output>:
  match function:
    case P113DFunction{+name,+params,+result,public,+body}:
      +arity = nt_count(NC_Binding,params)
      +snil = agy_sh_cid(ids,"SNil")
      +scon = agy_sh_cid(ids,"SCon")
      +chr = agy_sh_cid(ids,"Chr")
      +str_cids = U32.is_eq(result,1) && U32.is_lt(snil,65536) && U32.is_lt(scon,65536) && U32.is_lt(chr,65536)
      +sym = p113e_symbol(name)
      +slow = sym ++ "__sh_slow"
      nt_choose(Maybe<&2,X181Output>,Bool.not(str_cids),u => None{},u =>
        # 1. p88_string_eq_go (arity 3)
        nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,3) && agy_sh_has_mark(ids,"$agy.sh/eq_go") &&
            String.eq(name,"$p118borrow.read.p88_string_eq_go"),
          v => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,True{},False{}),slow),
          v => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,3) && agy_sh_has_mark(ids,"$agy.sh/eq_go") &&
              (String.eq(name,"$direct.p88_string_eq_go") || String.eq(name,"$p128borrow.owned.p88_string_eq_go")),
            w => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,True{},True{}),slow),
        # 2. p88_string_eq (arity 2)
            w => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/eq") &&
                String.eq(name,"$p118borrow.read.p88_string_eq"),
              x => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,False{},False{}),slow),
              x => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/eq") &&
                  (String.eq(name,"$direct.p88_string_eq") || String.eq(name,"$p128borrow.owned.p88_string_eq")),
                y => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,False{},True{}),slow),
        # 3. Base String.eq (arity 2)
                y => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/base_eq") &&
                    String.eq(name,"$p118borrow.read.String.eq"),
                  z => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,False{},False{}),slow),
                  z => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/base_eq") &&
                      (String.eq(name,"$direct.String.eq") || String.eq(name,"$p128borrow.owned.String.eq")),
                    a => agy_sh_wrap(function,ids,agy_sh_emit_streq(sym,slow,snil,scon,chr,False{},True{}),slow),
        # 4. index_hash (arity 2)
                    a => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/hash") &&
                        String.eq(name,"$p118borrow.read.index_hash"),
                      b => agy_sh_wrap(function,ids,agy_sh_emit_hash(sym,slow,snil,scon,chr,False{}),slow),
                      b => nt_choose(Maybe<&2,X181Output>,U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/hash") &&
                          (String.eq(name,"$direct.index_hash") || String.eq(name,"$p128borrow.owned.index_hash")),
                        c => agy_sh_wrap(function,ids,agy_sh_emit_hash(sym,slow,snil,scon,chr,True{}),slow),
        # 5. p98_tag_eq / p98_tag_eq_read (arity 2)
                        c =>
                          +kterm = agy_sh_cid(ids,"KTerm")
                          +klam = agy_sh_cid(ids,"KLambda")
                          +klit = agy_sh_cid(ids,"KLiteral")
                          +kt_ok = U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/tageq") &&
                            U32.is_lt(kterm,65536) && U32.is_lt(klam,65536) && U32.is_lt(klit,65536)
                          nt_choose(Maybe<&2,X181Output>,kt_ok &&
                              (String.eq(name,"$p118borrow.read.p98_tag_eq") || String.eq(name,"$p118borrow.read.p98_tag_eq_read")),
                            d => agy_sh_wrap(function,ids,agy_sh_emit_tageq(sym,slow,snil,scon,chr,kterm,klam,klit,False{}),slow),
                            d => nt_choose(Maybe<&2,X181Output>,kt_ok &&
                                (String.eq(name,"$direct.p98_tag_eq") || String.eq(name,"$p128borrow.owned.p98_tag_eq")),
                              e => agy_sh_wrap(function,ids,agy_sh_emit_tageq(sym,slow,snil,scon,chr,kterm,klam,klit,True{}),slow),
                              e => None{})))))))))))

@unsafe
def x181_direct_after_sh(sh: Maybe<&2,X181Output>, +function: P113DFunction, +ids: N111Ids) -> X181Output:
  match sh:
    case Some{out}: out
    case None{}: x181_direct_after_la(agy_la_try(function,ids,agy_la_detect(function)),function,ids)
"""


def once(s: str, old: str, new: str, label: str) -> str:
    n = s.count(old)
    assert n == 1, f"{label}: expected 1 match, got {n}"
    return s.replace(old, new, 1)


def replace_string_eq_calls(src: str) -> tuple[str, int]:
    """Replace real String.eq( calls (outside string literals and comments) with p88_string_eq(."""
    out_lines = []
    count = 0
    for line in src.splitlines(keepends=True):
        stripped = line.lstrip()
        if stripped.startswith("#"):
            out_lines.append(line)
            continue
        res = []
        in_str = False
        esc = False
        i = 0
        n = len(line)
        while i < n:
            c = line[i]
            if in_str:
                res.append(c)
                if esc:
                    esc = False
                elif c == "\\":
                    esc = True
                elif c == '"':
                    in_str = False
                i += 1
            else:
                if c == '"':
                    in_str = True
                    res.append(c)
                    i += 1
                elif c == "#":
                    res.append(line[i:])
                    break
                elif line[i:i + 10] == "String.eq(" and (i == 0 or not (line[i - 1].isalnum() or line[i - 1] in "_.")):
                    res.append("p88_string_eq(")
                    count += 1
                    i += 10
                else:
                    res.append(c)
                    i += 1
        out_lines.append("".join(res))
    return "".join(out_lines), count


def patch(src: str) -> tuple[str, int]:
    if "# AGY-W3B-STRHASH:" in src:
        return src, 0

    # 1. Insert STRHASH_EMIT_CODE right before x181_direct and hook x181_direct
    old_direct = (
        "@unsafe\n"
        "def x181_direct(function,ids):\n"
        "  x181_direct_after_la(agy_la_try(function,ids,agy_la_detect(function)),function,ids)"
    )
    new_direct = (
        STRHASH_EMIT_CODE
        + "\n@unsafe\n"
        + "def x181_direct(function,ids):\n"
        + "  x181_direct_after_sh(agy_sh_try(function,ids),function,ids)"
    )
    src = once(src, old_direct, new_direct, "hook x181_direct")

    # 2. Insert STRHASH_ANNOTATE_CODE right after agy_bp_annotate (before agy_map_has_ctor)
    anchor_ann = "@unsafe\ndef agy_map_has_ctor("
    src = once(src, anchor_ann, STRHASH_ANNOTATE_CODE + "\n\n" + anchor_ann, "insert STRHASH_ANNOTATE_CODE")

    # 3. Hook agy_sh_annotate into x198pw_after right after agy_bp_annotate
    old_hook = "agy_bp_annotate(r,agy_map_annotate(r,agy_da_annotate(agy_fl_annotate(r,agy_zip_annotate(r,x198pw_annotate(r,prepared))))))"
    new_hook = "agy_sh_annotate(r,agy_bp_annotate(r,agy_map_annotate(r,agy_da_annotate(agy_fl_annotate(r,agy_zip_annotate(r,x198pw_annotate(r,prepared)))))))"
    src = once(src, old_hook, new_hook, "hook agy_sh_annotate")

    # 4. Rewrite all String.eq( -> p88_string_eq( in compiler.bend (Track S1 composition!)
    src, n_eq = replace_string_eq_calls(src)
    return src, n_eq


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    a = ap.parse_args()
    out, n_eq = patch(a.src.read_text())
    a.dst.parent.mkdir(parents=True, exist_ok=True)
    a.dst.write_text(out)
    print(f"Patched AGY-W3B-STRHASH -> {a.dst} ({len(out)} bytes, {n_eq} String.eq -> p88_string_eq rewrites)")


if __name__ == "__main__":
    main()
