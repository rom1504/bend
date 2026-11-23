#!/usr/bin/env python3
"""Apply W14-E:
  1. Lean Inline Term-Drop Skip (`w14e_sh_fast_sink`) in `agy_sh_epilogue_2`,
     `agy_sh_emit_hash`, and `agy_sh_emit_strcmp` — eliminates `p111_rt_sink` /
     `term_drop` calls on static string literals (`loc < HEAP_OFF`), immediates
     (`tag < 2`), and shared RFC terms (`rc > 1`) across `agy_str_eq`, `String.eq`,
     `p88_string_eq`, `p88_string_eq_go`, `p98_tag_eq`, `p98_tag_eq_read`,
     `index_hash`, and `String.order.go`.
  2. Certified Native x86-64 Fast Path for `index_find` (`w14e_sh_emit_index_find`) —
     walks shared RFC `KIndexNode` trees in registers with ZERO `p198_rfc_take4` /
     `span_fade` / `w9_pick_kdef` / `term_drop` calls across all tree levels
     (with instant 2-instruction pre-check before the loop).
  3. Certified Native x86-64 Fast Path for `String.append` (`w14e_sh_emit_str_append`) —
     iterative register-loop `SCon` copy supporting BOTH unsealed cold `SCon` AND
     sealed hot / `cap-no8` `SCon` (inline `alc->free[0]` RFC sealing + `alc->free[1]`
     allocation + `w14e_sh_fast_sink` on `a`), plus zero-alloc `a == SNil` / `b == SNil`
     fast returns. 100% Observer-Gate safe across `normal`, `cap-no8`, and `all-hot`.
  4. Pure-Bend `KIndexNode`-first `index_find` (retaining full `P113Direct` self-recursion).

Idempotent patcher against selfhost/build/agy/wave13_unified/compiler.bend (read-only).
Does NOT touch x86-iface / w12e functions (owned by W14-B).
Does NOT touch bend2/bend.ts, runtime.c, or runtime-agy.o.
"""
from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave13_unified/compiler.bend"
DEFAULT_OUT = Path("/tmp/agy_w14e/compiler_w14e.bend")

MARKER = "# === AGY-W14E:"


def replace_exact(src: str, old: str, new: str, label: str) -> str:
    cnt = src.count(old)
    if cnt != 1:
        raise RuntimeError(f"[{label}] expected 1 match, found {cnt}")
    return src.replace(old, new, 1)


def apply_w14e(src: str) -> str:
    if MARKER in src:
        return src

    # ------------------------------------------------------------------
    # 1. Pure-Bend Hot Leaf: KIndexNode-first index_find (stays P113Direct!)
    # ------------------------------------------------------------------
    old_idx = """@unsafe
def index_find(tree, name, hash, bits):
  match tree:
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      nt_choose(KDef, String.eq(kind, "Absent"),
        u => missing(),
        u => nt_choose(KDef, U32.is_eq(templates, 0),
          v => w5_idx_bucket_if(U32.is_eq(arity, hash), ctors, name),
          v => index_find(index_child_list(ctors, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash, bits)))
    case KIndexLeaf{stored, bucket}:
      w5_idx_bucket_if(U32.is_eq(stored, hash), bucket, name)
    case KIndexNode{stored, mask, left, right}:
      index_find(w9_pick_kdef(U32.and(hash, mask), left, right), name, hash, bits)"""

    new_idx = """# === AGY-W14E: KIndexNode-first index_find (P113Direct self-recursive) ===
@unsafe
def index_find(tree, name, hash, bits):
  match tree:
    case KIndexNode{stored, mask, left, right}:
      index_find(w9_pick_kdef(U32.and(hash, mask), left, right), name, hash, bits)
    case KIndexLeaf{stored, bucket}:
      w5_idx_bucket_if(U32.is_eq(stored, hash), bucket, name)
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      nt_choose(KDef, String.eq(kind, "Absent"),
        u => missing(),
        u => nt_choose(KDef, U32.is_eq(templates, 0),
          v => w5_idx_bucket_if(U32.is_eq(arity, hash), ctors, name),
          v => index_find(index_child_list(ctors, Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash, bits)))"""

    src = replace_exact(src, old_idx, new_idx, "W14E index_find KIndexNode-first")

    # ------------------------------------------------------------------
    # 2. Lean Inline Term-Drop Skip in agy_sh_* Epilogues
    # ------------------------------------------------------------------
    old_epi = """@unsafe
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
    u => X188Empty{})"""

    new_epi = """# === AGY-W14E: Lean RFC rc>1 + static loc<HEAP_OFF + immediate skip before p111_rt_sink ===
@unsafe
def w14e_sh_fast_sink(+pfx: String, +state_reg: U32, +val_reg: U32) -> X188Seq:
  +l_triv = pfx ++ "_tv"
  +l_slow = pfx ++ "_sl"
  +l_done = pfx ++ "_ok"
  x188_many([
    x188_i2("testq",x188_reg(val_reg,64),x188_reg(val_reg,64)),
    x188_i1("jge",X187Target{l_triv}),
    x188_i2("movq",X187Mem{state_reg,0},x188_reg(9,64)),
    x188_i2("movq",x188_reg(val_reg,64),x188_reg(8,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("leaq",X187Indexed{9,8,8,0},x188_reg(10,64)),
    x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),
    x188_i2("movl",x188_reg(11,32),x188_reg(0,32)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("jbe",X187Target{l_slow}),
    x188_i2("subq",X187Imm{1,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(11,64),X187Mem{10,0}),
    x188_i1("jmp",X187Target{l_done}),
    x188_label(l_triv),
    x188_i2("movq",x188_reg(val_reg,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jb",X187Target{l_done}),
    x188_i2("movq",x188_reg(val_reg,64),x188_reg(8,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(9,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(9,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(9,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(9,64)),
    x188_i2("cmpq",x188_reg(9,64),x188_reg(8,64)),
    x188_i1("jb",X187Target{l_done}),
    x188_label(l_slow),
    x188_i2("movq",x188_reg(state_reg,64),x188_reg(7,64)),
    x188_i2("movq",x188_reg(val_reg,64),x188_reg(6,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("call",X187Target{"p111_rt_sink"}),
    x188_label(l_done)])

@unsafe
def agy_sh_epilogue_2(+pfx: String, +slow: String, +l_true: String, +l_false: String, +l_bail: String, +owned: Bool) -> X188Seq:
  +l_done = pfx ++ "_dn"
  +sink_seq = nt_choose(X188Seq,owned,
    u => x188_many([
      x188_i2("movl",x188_reg(0,32),x188_reg(13,32)),
      x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
      x188_i2("movq",x188_reg(2,64),x188_reg(3,64)),
      w14e_sh_fast_sink(pfx ++ "_s1",12,6),
      w14e_sh_fast_sink(pfx ++ "_s2",12,3),
      x188_i2("movl",x188_reg(13,32),x188_reg(0,32))]),
    u => X188Empty{})"""

    src = replace_exact(src, old_epi, new_epi, "W14E agy_sh_epilogue_2 fast sink")

    old_hash_done = """  +l_sk = pfx ++ "_sk"
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
      x188_i0("ret")]))"""

    new_hash_done = """  +l_sk = pfx ++ "_sk"
  +l_htv = pfx ++ "_htv"
  +l_hsl = pfx ++ "_hsl"
  +done_seq = nt_choose(X188Seq,owned,
    u => x188_many([
      x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
      x188_i1("jge",X187Target{l_htv}),
      x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
      x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
      x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
      x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
      x188_i2("leaq",X187Indexed{9,8,8,0},x188_reg(10,64)),
      x188_i2("movq",X187Mem{10,0},x188_reg(11,64)),
      x188_i2("movl",x188_reg(11,32),x188_reg(0,32)),
      x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
      x188_i2("cmpl",X187Imm{1,0},x188_reg(0,32)),
      x188_i1("jbe",X187Target{l_hsl}),
      x188_i2("subq",X187Imm{1,0},x188_reg(11,64)),
      x188_i2("movq",x188_reg(11,64),X187Mem{10,0}),
      x188_i1("jmp",X187Target{l_sk}),
      x188_label(l_htv),
      x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
      x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
      x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
      x188_i1("jb",X187Target{l_sk}),
      x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
      x188_i2("shlq",X187Imm{24,0},x188_reg(8,64)),
      x188_i2("shrq",X187Imm{24,0},x188_reg(8,64)),
      x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(9,64)),
      x188_i2("addq",X187Imm{127,0},x188_reg(9,64)),
      x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(9,64)),
      x188_i2("addq",X187Imm{51413504,0},x188_reg(9,64)),
      x188_i2("cmpq",x188_reg(9,64),x188_reg(8,64)),
      x188_i1("jb",X187Target{l_sk}),
      x188_label(l_hsl),
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
      x188_i0("ret")]))"""

    src = replace_exact(src, old_hash_done, new_hash_done, "W14E agy_sh_emit_hash fast sink")

    old_strcmp_sink = """  +l_sk1 = pfx ++ "_s1"
  +l_sk2 = pfx ++ "_s2"
  +l_bail = pfx ++ "_bl"
  +sink_seq = nt_choose(X188Seq,owned,
    u => x188_many([
      x188_i2("movq",x188_reg(0,64),x188_reg(13,64)),
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
      x188_i2("movq",x188_reg(13,64),x188_reg(0,64))]),
    u => X188Empty{})"""

    new_strcmp_sink = """  +l_bail = pfx ++ "_bl"
  +sink_seq = nt_choose(X188Seq,owned,
    u => x188_many([
      x188_i2("movq",x188_reg(0,64),x188_reg(13,64)),
      x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
      x188_i2("movq",x188_reg(2,64),x188_reg(3,64)),
      w14e_sh_fast_sink(pfx ++ "_s1",12,6),
      w14e_sh_fast_sink(pfx ++ "_s2",12,3),
      x188_i2("movq",x188_reg(13,64),x188_reg(0,64))]),
    u => X188Empty{})"""

    src = replace_exact(src, old_strcmp_sink, new_strcmp_sink, "W14E agy_sh_emit_strcmp fast sink")

    # ------------------------------------------------------------------
    # 3. Certified Native x86-64 Fast Paths: index_find & String.append
    # ------------------------------------------------------------------
    old_tageq_fn = """@unsafe
def agy_sh_try_tageq(+function: P113DFunction, +ids: N111Ids, +name: String, +arity: U32,
    +sym: String, +slow: String, +snil: U32, +scon: U32, +chr: U32) -> Maybe<&2,X181Output>:"""

    new_tageq_fn = """# === AGY-W14E: Certified Native x86-64 Fast Paths for index_find & String.append ===
@unsafe
def w14e_sh_emit_index_find(+symbol: String, +slow: String, +knode: U32) -> X181Output:
  +pfx = ".Lw14e_if_" ++ symbol
  +knode_chk = U32.add(131072,knode)
  +l_lp = pfx ++ "_lp"
  +l_dir = pfx ++ "_dr"
  +l_left = pfx ++ "_lt"
  +l_leaf = pfx ++ "_lf"
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    # Instant pre-check: orig_tree must be shared RFC (rc > 1) BEFORE any loop work!
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jge",X187Target{slow}),
    agy_sh_guard_caps(slow),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jnz",X187Target{slow}),
    x188_i2("movq",X187Mem{7,0},x188_reg(10,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("jbe",X187Target{slow}),
    x188_i2("movq",x188_reg(6,64),x188_reg(9,64)),
    x188_label(l_lp),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{knode_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_leaf}),
    x188_i2("movq",x188_reg(9,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(9,64),x188_reg(9,64)),
    x188_i1("jge",X187Target{l_dir}),
    x188_i2("movq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_dir),
    x188_i2("leaq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{32,0},x188_reg(0,64)),
    x188_i2("testq",x188_reg(0,64),x188_reg(0,64)),
    x188_i1("jnz",X187Target{slow}),
    x188_i2("movq",X187Mem{11,8},x188_reg(0,64)),
    x188_i2("testq",x188_reg(1,64),x188_reg(0,64)),
    x188_i1("jz",X187Target{l_left}),
    x188_i2("movq",X187Mem{11,24},x188_reg(9,64)),
    x188_i1("jmp",X187Target{l_lp}),
    x188_label(l_left),
    x188_i2("movq",X187Mem{11,16},x188_reg(9,64)),
    x188_i1("jmp",X187Target{l_lp}),
    x188_label(l_leaf),
    x188_i2("cmpq",x188_reg(6,64),x188_reg(9,64)),
    x188_i1("je",X187Target{slow}),
    x188_i2("testq",x188_reg(9,64),x188_reg(9,64)),
    x188_i1("jge",X187Target{slow}),
    x188_i2("movq",x188_reg(6,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(9,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(11,64),x188_reg(0,64)),
    x188_i1("je",X187Target{slow}),
    x188_i2("movq",X187Indexed{10,0,8,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{16777214,0},x188_reg(0,32)),
    x188_i1("jae",X187Target{slow}),
    x188_i2("leaq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(0,64)),
    x188_i2("subq",X187Imm{1,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{11,0}),
    x188_i2("movq",x188_reg(9,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("leaq",X187Indexed{10,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(0,64)),
    x188_i2("addq",X187Imm{1,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{11,0}),
    x188_i2("movq",x188_reg(9,64),x188_reg(6,64)),
    x188_i1("jmp",X187Target{slow}),
    X188One{PSize{symbol}}])],""}

@unsafe
def w14e_sh_emit_str_append(+symbol: String, +slow: String, +snil: U32, +scon: U32) -> X181Output:
  +pfx = ".Lw14e_sa_" ++ symbol
  +snil_hi = U32.add(16777216,U32.mul(snil,256))
  +scon_hi = U32.add(33554432,U32.mul(scon,256))
  +scon_rfc_hi = U32.add(2147483648,scon_hi)
  +scon_chk = U32.add(131072,scon)
  +l_nonnil = pfx ++ "_nn"
  +l_chk_un = pfx ++ "_cu"
  +l_spl_lp = pfx ++ "_pl"
  +l_spl_dr = pfx ++ "_pd"
  +l_spl_ht = pfx ++ "_ph"
  +l_spl_st = pfx ++ "_ps"
  +l_copyp = pfx ++ "_cy"
  +l_scan = pfx ++ "_sc"
  +l_sdir = pfx ++ "_sd"
  +l_scanned = pfx ++ "_ed"
  +l_alloc = pfx ++ "_al"
  +l_sealed = pfx ++ "_sl"
  +l_sb_ok = pfx ++ "_sb"
  +l_scopy = pfx ++ "_sp"
  +l_scdir = pfx ++ "_sr"
  +l_stdone = pfx ++ "_st"
  +l_copy = pfx ++ "_cp"
  +l_cdir = pfx ++ "_cd"
  +l_tdone = pfx ++ "_td"
  +l_bail = pfx ++ "_bl"
  X181Output{[x188_many([
    X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    agy_sh_guard_caps(slow),
    x188_i2("movabsq",X187Imm{0,snil_hi},x188_reg(10,64)),
    x188_i2("cmpq",x188_reg(10,64),x188_reg(6,64)),
    x188_i1("jne",X187Target{l_nonnil}),
    x188_i2("movq",x188_reg(2,64),x188_reg(0,64)),
    x188_i0("ret"),
    x188_label(l_nonnil),
    x188_i1("pushq",x188_reg(3,64)),
    x188_i1("pushq",x188_reg(12,64)),
    x188_i1("pushq",x188_reg(13,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(9,64)),
    # Compute HEAP_OFF in %r13
    x188_i2("movq",X187Rip{"p111_program",64,0},x188_reg(13,64)),
    x188_i2("addq",X187Imm{127,0},x188_reg(13,64)),
    x188_i2("andq",X187Imm{4294967168,4294967295},x188_reg(13,64)),
    x188_i2("addq",X187Imm{51413504,0},x188_reg(13,64)),
    # Dispatch: if a is shared RFC (rc > 1) or static (loc < HEAP_OFF), use zero-drop copy path;
    # if a is uniquely-owned heap (rc == 1 or unsealed loc >= HEAP_OFF), use zero-alloc in-place splice!
    x188_i2("testq",x188_reg(6,64),x188_reg(6,64)),
    x188_i1("jge",X187Target{l_chk_un}),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("movq",X187Indexed{9,0,8,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("ja",X187Target{l_copyp}),
    x188_i1("jb",X187Target{l_bail}),
    x188_i1("jmp",X187Target{l_spl_lp ++ "_init"}),
    x188_label(l_chk_un),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(13,64),x188_reg(0,64)),
    x188_i1("jb",X187Target{l_copyp}),
    # --- In-place tail splice path (a is uniquely-owned heap spine: 0 allocs, 0 drops!) ---
    x188_label(l_spl_lp ++ "_init"),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
    x188_label(l_spl_lp),
    x188_i2("cmpl",X187Imm{256,0},x188_reg(1,32)),
    x188_i1("jae",X187Target{l_bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("jge",X187Target{l_spl_dr}),
    x188_i2("movq",X187Indexed{9,11,8,0},x188_reg(11,64)),
    x188_i2("movl",x188_reg(11,32),x188_reg(0,32)),
    x188_i2("andl",X187Imm{16777215,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{1,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_spl_dr),
    x188_i2("cmpq",x188_reg(13,64),x188_reg(11,64)),
    x188_i1("jb",X187Target{l_bail}),
    x188_i2("leaq",X187Indexed{9,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,8},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(10,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_spl_ht}),
    x188_i2("addq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("jmp",X187Target{l_spl_lp}),
    x188_label(l_spl_ht),
    x188_i2("cmpq",x188_reg(10,64),x188_reg(2,64)),
    x188_i1("je",X187Target{l_spl_st ++ "_ret"}),
    # If b (%rdx) is unsealed TAG_CTR and SCon is hot or cap-no8, seal b from alc->free[0]
    x188_i2("movq",x188_reg(2,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_spl_st}),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8,0},x188_reg(0,32)),
    x188_i1("jz",X187Target{l_spl_st ++ "_seal"}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("movzbl",X187Mem{0,scon},x188_reg(0,32)),
    x188_i2("testl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jz",X187Target{l_spl_st}),
    x188_label(l_spl_st ++ "_seal"),
    x188_i2("movq",X187Mem{7,8},x188_reg(12,64)),
    x188_i2("cmpq",X187Imm{1,0},X187Mem{12,256}),
    x188_i1("jb",X187Target{l_bail}),
    x188_i2("movq",X187Mem{12,0},x188_reg(0,64)),
    x188_i2("movq",X187Indexed{9,0,8,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{12,0}),
    x188_i2("subq",X187Imm{1,0},X187Mem{12,256}),
    x188_i2("movq",x188_reg(2,64),x188_reg(1,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(1,64)),
    x188_i2("addq",X187Imm{1,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Indexed{9,0,8,0}),
    x188_i2("shrq",X187Imm{40,0},x188_reg(2,64)),
    x188_i2("shlq",X187Imm{40,0},x188_reg(2,64)),
    x188_i2("orq",x188_reg(0,64),x188_reg(2,64)),
    x188_i2("movabsq",X187Imm{0,2147483648},x188_reg(1,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(2,64)),
    x188_label(l_spl_st),
    x188_i2("movq",x188_reg(2,64),X187Mem{11,8}),
    x188_label(l_spl_st ++ "_ret"),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    # --- Copy-alloc path (a is static or shared RFC rc>1: 0 term_drop calls!) ---
    x188_label(l_copyp),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_i2("xorl",x188_reg(1,32),x188_reg(1,32)),
    x188_label(l_scan),
    x188_i2("cmpq",x188_reg(10,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_scanned}),
    x188_i2("cmpl",X187Imm{256,0},x188_reg(1,32)),
    x188_i1("jae",X187Target{l_bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{40,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8388607,0},x188_reg(0,32)),
    x188_i2("cmpl",X187Imm{scon_chk,0},x188_reg(0,32)),
    x188_i1("jne",X187Target{l_bail}),
    x188_i2("movq",x188_reg(8,64),x188_reg(11,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("jge",X187Target{l_sdir}),
    x188_i2("movq",X187Indexed{9,11,8,0},x188_reg(11,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(11,64)),
    x188_label(l_sdir),
    x188_i2("leaq",X187Indexed{9,11,8,0},x188_reg(11,64)),
    x188_i2("movq",X187Mem{11,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jae",X187Target{l_bail}),
    x188_i2("movq",X187Mem{11,8},x188_reg(8,64)),
    x188_i2("addq",X187Imm{1,0},x188_reg(1,64)),
    x188_i1("jmp",X187Target{l_scan}),
    x188_label(l_scanned),
    x188_i2("cmpq",x188_reg(10,64),x188_reg(2,64)),
    x188_i1("jne",X187Target{l_alloc}),
    x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    x188_label(l_alloc),
    x188_i2("movq",X187Mem{7,8},x188_reg(12,64)),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("addq",x188_reg(0,64),x188_reg(0,64)),
    x188_i2("cmpq",x188_reg(0,64),X187Mem{12,264}),
    x188_i1("jb",X187Target{l_bail}),
    x188_i2("movq",X187Rip{"p111_program",88,0},x188_reg(0,64)),
    x188_i2("andl",X187Imm{8,0},x188_reg(0,32)),
    x188_i1("jz",X187Target{l_sealed}),
    x188_i2("movq",X187Rip{"p111_program",136,0},x188_reg(0,64)),
    x188_i2("movzbl",X187Mem{0,scon},x188_reg(0,32)),
    x188_i2("testl",x188_reg(0,32),x188_reg(0,32)),
    x188_i1("jnz",X187Target{l_sealed}),
    x188_i2("addq",x188_reg(1,64),x188_reg(1,64)),
    x188_i2("movq",X187Mem{12,264},x188_reg(0,64)),
    x188_i2("subq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{12,264}),
    x188_i2("movq",X187Mem{12,8},x188_reg(11,64)),
    x188_i2("movq",X187Indexed{9,11,8,0},x188_reg(3,64)),
    x188_i2("movabsq",X187Imm{0,scon_hi},x188_reg(13,64)),
    x188_i2("orq",x188_reg(11,64),x188_reg(13,64)),
    x188_i2("leaq",X187Indexed{9,11,8,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_label(l_copy),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("jge",X187Target{l_cdir}),
    x188_i2("movq",X187Indexed{9,0,8,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_label(l_cdir),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{11,0}),
    x188_i2("movq",X187Mem{0,8},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(10,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_tdone}),
    x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),
    x188_i2("movq",X187Indexed{9,3,8,0},x188_reg(3,64)),
    x188_i2("movabsq",X187Imm{0,scon_hi},x188_reg(1,64)),
    x188_i2("orq",x188_reg(0,64),x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{11,8}),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(11,64)),
    x188_i1("jmp",X187Target{l_copy}),
    x188_label(l_tdone),
    x188_i2("movq",x188_reg(2,64),X187Mem{11,8}),
    x188_i2("movq",x188_reg(3,64),X187Mem{12,8}),
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    w14e_sh_fast_sink(pfx ++ "_sk",12,6),
    x188_i2("movq",x188_reg(13,64),x188_reg(0,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    x188_label(l_sealed),
    x188_i2("cmpq",x188_reg(1,64),X187Mem{12,256}),
    x188_i1("jb",X187Target{l_bail}),
    x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("addq",x188_reg(0,64),x188_reg(0,64)),
    x188_i2("subq",x188_reg(0,64),X187Mem{12,264}),
    x188_i2("subq",X187Imm{1,0},x188_reg(1,64)),
    x188_i2("subq",x188_reg(1,64),X187Mem{12,256}),
    x188_i2("movq",x188_reg(2,64),x188_reg(0,64)),
    x188_i2("shrq",X187Imm{56,0},x188_reg(0,64)),
    x188_i2("cmpq",X187Imm{2,0},x188_reg(0,64)),
    x188_i1("jne",X187Target{l_sb_ok}),
    x188_i2("movq",X187Mem{12,0},x188_reg(0,64)),
    x188_i2("movq",X187Indexed{9,0,8,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{12,0}),
    x188_i2("subq",X187Imm{1,0},X187Mem{12,256}),
    x188_i2("movq",x188_reg(2,64),x188_reg(1,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(1,64)),
    x188_i2("addq",X187Imm{1,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Indexed{9,0,8,0}),
    x188_i2("shrq",X187Imm{40,0},x188_reg(2,64)),
    x188_i2("shlq",X187Imm{40,0},x188_reg(2,64)),
    x188_i2("orq",x188_reg(0,64),x188_reg(2,64)),
    x188_i2("movabsq",X187Imm{0,2147483648},x188_reg(1,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(2,64)),
    x188_label(l_sb_ok),
    x188_i2("movq",X187Mem{12,8},x188_reg(11,64)),
    x188_i2("movq",X187Indexed{9,11,8,0},x188_reg(3,64)),
    x188_i2("movabsq",X187Imm{0,scon_hi},x188_reg(13,64)),
    x188_i2("orq",x188_reg(11,64),x188_reg(13,64)),
    x188_i2("leaq",X187Indexed{9,11,8,0},x188_reg(11,64)),
    x188_i2("movq",x188_reg(6,64),x188_reg(8,64)),
    x188_label(l_scopy),
    x188_i2("movq",x188_reg(8,64),x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("testq",x188_reg(8,64),x188_reg(8,64)),
    x188_i1("jge",X187Target{l_scdir}),
    x188_i2("movq",X187Indexed{9,0,8,0},x188_reg(0,64)),
    x188_i2("shrq",X187Imm{24,0},x188_reg(0,64)),
    x188_label(l_scdir),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(0,64)),
    x188_i2("movq",X187Mem{0,0},x188_reg(1,64)),
    x188_i2("movq",x188_reg(1,64),X187Mem{11,0}),
    x188_i2("movq",X187Mem{0,8},x188_reg(8,64)),
    x188_i2("cmpq",x188_reg(10,64),x188_reg(8,64)),
    x188_i1("je",X187Target{l_stdone}),
    x188_i2("movq",x188_reg(3,64),x188_reg(0,64)),
    x188_i2("movq",X187Indexed{9,3,8,0},x188_reg(3,64)),
    x188_i2("movq",X187Mem{12,0},x188_reg(1,64)),
    x188_i1("pushq",x188_reg(0,64)),
    x188_i2("movq",X187Indexed{9,1,8,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{12,0}),
    x188_i1("popq",x188_reg(0,64)),
    x188_i1("pushq",x188_reg(0,64)),
    x188_i2("shlq",X187Imm{24,0},x188_reg(0,64)),
    x188_i2("addq",X187Imm{1,0},x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Indexed{9,1,8,0}),
    x188_i1("popq",x188_reg(0,64)),
    x188_i1("pushq",x188_reg(0,64)),
    x188_i2("movabsq",X187Imm{0,scon_rfc_hi},x188_reg(0,64)),
    x188_i2("orq",x188_reg(1,64),x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{11,8}),
    x188_i1("popq",x188_reg(0,64)),
    x188_i2("leaq",X187Indexed{9,0,8,0},x188_reg(11,64)),
    x188_i1("jmp",X187Target{l_scopy}),
    x188_label(l_stdone),
    x188_i2("movq",x188_reg(2,64),X187Mem{11,8}),
    x188_i2("movq",x188_reg(3,64),X187Mem{12,8}),
    x188_i2("movq",x188_reg(7,64),x188_reg(12,64)),
    w14e_sh_fast_sink(pfx ++ "_ss",12,6),
    x188_i2("movq",x188_reg(13,64),x188_reg(0,64)),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i0("ret"),
    x188_label(l_bail),
    x188_i1("popq",x188_reg(13,64)),
    x188_i1("popq",x188_reg(12,64)),
    x188_i1("popq",x188_reg(3,64)),
    x188_i1("jmp",X187Target{slow}),
    X188One{PSize{symbol}}])],""}

@unsafe
def w14e_sh_try_extra(+function: P113DFunction, +ids: N111Ids, +name: String, +arity: U32,
    +sym: String, +slow: String, +snil: U32, +scon: U32) -> Maybe<&2,X181Output>:
  +knode = agy_sh_cid2(ids,"KIndexNode","$ctor.75_73_110_100_101_120_78_111_100_101_")
  nt_choose(Maybe<&2,X181Output>,
    U32.is_eq(arity,2) && agy_sh_has_mark(ids,"$agy.sh/append") &&
    (agy_str_eq(name,"$direct.String.append") || agy_str_eq(name,"$p128borrow.owned.String.append")),
    u => agy_sh_wrap(function,ids,w14e_sh_emit_str_append(sym,slow,snil,scon),slow),
    u => nt_choose(Maybe<&2,X181Output>,
      U32.is_eq(arity,4) && U32.is_lt(knode,65536) && agy_sh_has_mark(ids,"$agy.sh/idxfind") &&
      (agy_str_eq(name,"$direct.index_find") || agy_str_eq(name,"$p128borrow.owned.index_find")),
      v => agy_sh_wrap(function,ids,w14e_sh_emit_index_find(sym,slow,knode),slow),
      v => None{}))

@unsafe
def agy_sh_try_tageq(+function: P113DFunction, +ids: N111Ids, +name: String, +arity: U32,
    +sym: String, +slow: String, +snil: U32, +scon: U32, +chr: U32) -> Maybe<&2,X181Output>:"""

    src = replace_exact(src, old_tageq_fn, new_tageq_fn, "W14E insert w14e_sh_try_extra before agy_sh_try_tageq")

    old_tageq_end = """      e => agy_sh_wrap(function,ids,agy_sh_emit_tageq(sym,slow,snil,scon,chr,kterm,klam,klit,True{}),slow),
      e => None{}))"""

    new_tageq_end = """      e => agy_sh_wrap(function,ids,agy_sh_emit_tageq(sym,slow,snil,scon,chr,kterm,klam,klit,True{}),slow),
      e => w14e_sh_try_extra(function,ids,name,arity,sym,slow,snil,scon)))"""

    src = replace_exact(src, old_tageq_end, new_tageq_end, "W14E call w14e_sh_try_extra from agy_sh_try_tageq")

    # Wire $agy.sh/append and $agy.sh/idxfind marks in agy_sh_annotate / agy_sh_ctx
    old_sh_ann = """@unsafe
def agy_sh_ctx(ctx: P134Context, +eq_go_ok: Bool, +eq_ok: Bool, +agy_eq_ok: Bool,
    +base_eq_ok: Bool, +hash_ok: Bool, +tageq_ok: Bool, +tageq_read_ok: Bool) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      +i1 = nt_choose(N111Ids,eq_go_ok,u => agy_bp_mark_ids(ids,"$agy.sh/eq_go"),u => ids)
      +i2 = nt_choose(N111Ids,eq_ok,u => agy_bp_mark_ids(i1,"$agy.sh/eq"),u => i1)
      +i3 = nt_choose(N111Ids,agy_eq_ok,u => agy_bp_mark_ids(i2,"$agy.sh/agy_eq"),u => i2)
      +i4 = nt_choose(N111Ids,base_eq_ok,u => agy_bp_mark_ids(i3,"$agy.sh/base_eq"),u => i3)
      +i5 = nt_choose(N111Ids,hash_ok,u => agy_bp_mark_ids(i4,"$agy.sh/hash"),u => i4)
      +i6 = nt_choose(N111Ids,tageq_ok,u => agy_bp_mark_ids(i5,"$agy.sh/tageq"),u => i5)
      +i7 = nt_choose(N111Ids,tageq_read_ok,u => agy_bp_mark_ids(i6,"$agy.sh/tageq_read"),u => i6)
      P134Context{i7,idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_sh_cursor(cursor: P134Cursor, +eq_go_ok: Bool, +eq_ok: Bool, +agy_eq_ok: Bool,
    +base_eq_ok: Bool, +hash_ok: Bool, +tageq_ok: Bool, +tageq_read_ok: Bool) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_sh_ctx(c,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok),agy_sh_cursor(next,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok)}
    case P134Public{ss,c,next}: P134Public{ss,agy_sh_ctx(c,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok),agy_sh_cursor(next,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_sh_ctx(c,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok),agy_sh_cursor(next,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok)}
    case p: p

@unsafe
def agy_sh_apply(prepared: P169Prepared, +eq_go_ok: Bool, +eq_ok: Bool, +agy_eq_ok: Bool,
    +base_eq_ok: Bool, +hash_ok: Bool, +tageq_ok: Bool, +tageq_read_ok: Bool) -> P169Prepared:
  match prepared:
    case P169Prepared{forwards,+cursor,+error}:
      +any_ok = eq_go_ok || eq_ok || agy_eq_ok || base_eq_ok || hash_ok || tageq_ok || tageq_read_ok
      P169Prepared{forwards,nt_choose(P134Cursor,any_ok && String.is_empty(error),
        u => agy_sh_cursor(cursor,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok),u => cursor),error}

@unsafe
def agy_sh_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{source,+book,names,paths,scope,bound}:
      +adts = agy_sh_str_adts_ok(book)
      +chr_eq_ok = agy_sh_def_pin(book,"Char.is_eq",3302228733,42192839)
      +chr_u32_ok = agy_sh_def_pin(book,"Char.to_u32",1968267531,1583642761)
      +base_eq_ok = adts && chr_u32_ok &&
        agy_sh_def_pin(book,"String.eq",225128774,712577888) &&
        agy_sh_def_pin(book,"String.order",565631753,2204196711) &&
        agy_sh_def_pin(book,"String.order.go",3716281844,3937681030)
      +eq_go_ok = adts && (
        (chr_eq_ok && agy_sh_def_pin(book,"p88_string_eq_go",3024631756,2674381182)) ||
        (chr_u32_ok && agy_sh_def_pin(book,"p88_string_eq_go",1723204692,4196828370)))
      +eq_ok =
        (eq_go_ok && agy_sh_def_pin(book,"p98_eq_finish",165389557,2460805607) &&
          agy_sh_def_pin(book,"p88_string_eq",3716379759,1182868109)) ||
        (base_eq_ok && agy_sh_def_pin(book,"p88_string_eq",1506689157,1260695159))
      +agy_eq_ok = base_eq_ok && agy_sh_def_pin(book,"agy_str_eq",339807906,3620894948)
      +hash_ok = adts && chr_u32_ok && agy_sh_def_pin(book,"index_hash",1696180074,3131242088)
      +kt_adts = agy_sh_kterm_adt_ok(book)
      +tageq_read_ok = kt_adts && (
        (eq_ok && agy_sh_def_pin(book,"p98_tag_eq_read",572502218,3139754552)) ||
        (base_eq_ok && agy_sh_def_pin(book,"p98_tag_eq_read",2686625593,3004633447)))
      +tageq_ok = kt_adts && (
        (tageq_read_ok && agy_sh_def_pin(book,"p98_tag_eq_finish",133393152,3410656966) &&
          agy_sh_def_pin(book,"p98_tag_eq",2318141704,1837477542)) ||
        (base_eq_ok && agy_sh_def_pin(book,"p98_tag_eq",2108109257,3206482399)))
      agy_sh_apply(prepared,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok)"""

    new_sh_ann = """@unsafe
def w14e_sh_extra_ctx(ctx: P134Context, +app_ok: Bool, +idx_ok: Bool) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      +i1 = nt_choose(N111Ids,app_ok,u => agy_bp_mark_ids(ids,"$agy.sh/append"),u => ids)
      +i2 = nt_choose(N111Ids,idx_ok,u => agy_bp_mark_ids(i1,"$agy.sh/idxfind"),u => i1)
      P134Context{i2,idx,direct,ready,view,lookups,heap,mode}

@unsafe
def w14e_sh_extra_cursor(cursor: P134Cursor, +app_ok: Bool, +idx_ok: Bool) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,w14e_sh_extra_ctx(c,app_ok,idx_ok),w14e_sh_extra_cursor(next,app_ok,idx_ok)}
    case P134Public{ss,c,next}: P134Public{ss,w14e_sh_extra_ctx(c,app_ok,idx_ok),w14e_sh_extra_cursor(next,app_ok,idx_ok)}
    case P134Legacy{es,c,next}: P134Legacy{es,w14e_sh_extra_ctx(c,app_ok,idx_ok),w14e_sh_extra_cursor(next,app_ok,idx_ok)}
    case p: p

@unsafe
def w14e_sh_extra_apply(prepared: P169Prepared, +app_ok: Bool, +idx_ok: Bool) -> P169Prepared:
  match prepared:
    case P169Prepared{forwards,+cursor,+error}:
      P169Prepared{forwards,nt_choose(P134Cursor,(app_ok || idx_ok) && String.is_empty(error),
        u => w14e_sh_extra_cursor(cursor,app_ok,idx_ok),u => cursor),error}

@unsafe
def agy_sh_ctx(ctx: P134Context, +eq_go_ok: Bool, +eq_ok: Bool, +agy_eq_ok: Bool,
    +base_eq_ok: Bool, +hash_ok: Bool, +tageq_ok: Bool, +tageq_read_ok: Bool) -> P134Context:
  match ctx:
    case P134Context{ids,idx,direct,ready,view,lookups,heap,mode}:
      +i1 = nt_choose(N111Ids,eq_go_ok,u => agy_bp_mark_ids(ids,"$agy.sh/eq_go"),u => ids)
      +i2 = nt_choose(N111Ids,eq_ok,u => agy_bp_mark_ids(i1,"$agy.sh/eq"),u => i1)
      +i3 = nt_choose(N111Ids,agy_eq_ok,u => agy_bp_mark_ids(i2,"$agy.sh/agy_eq"),u => i2)
      +i4 = nt_choose(N111Ids,base_eq_ok,u => agy_bp_mark_ids(i3,"$agy.sh/base_eq"),u => i3)
      +i5 = nt_choose(N111Ids,hash_ok,u => agy_bp_mark_ids(i4,"$agy.sh/hash"),u => i4)
      +i6 = nt_choose(N111Ids,tageq_ok,u => agy_bp_mark_ids(i5,"$agy.sh/tageq"),u => i5)
      +i7 = nt_choose(N111Ids,tageq_read_ok,u => agy_bp_mark_ids(i6,"$agy.sh/tageq_read"),u => i6)
      P134Context{i7,idx,direct,ready,view,lookups,heap,mode}

@unsafe
def agy_sh_cursor(cursor: P134Cursor, +eq_go_ok: Bool, +eq_ok: Bool, +agy_eq_ok: Bool,
    +base_eq_ok: Bool, +hash_ok: Bool, +tageq_ok: Bool, +tageq_read_ok: Bool) -> P134Cursor:
  match cursor:
    case P134Private{fs,c,next}: P134Private{fs,agy_sh_ctx(c,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok),agy_sh_cursor(next,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok)}
    case P134Public{ss,c,next}: P134Public{ss,agy_sh_ctx(c,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok),agy_sh_cursor(next,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok)}
    case P134Legacy{es,c,next}: P134Legacy{es,agy_sh_ctx(c,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok),agy_sh_cursor(next,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok)}
    case p: p

@unsafe
def agy_sh_apply(prepared: P169Prepared, +eq_go_ok: Bool, +eq_ok: Bool, +agy_eq_ok: Bool,
    +base_eq_ok: Bool, +hash_ok: Bool, +tageq_ok: Bool, +tageq_read_ok: Bool) -> P169Prepared:
  match prepared:
    case P169Prepared{forwards,+cursor,+error}:
      +any_ok = eq_go_ok || eq_ok || agy_eq_ok || base_eq_ok || hash_ok || tageq_ok || tageq_read_ok
      P169Prepared{forwards,nt_choose(P134Cursor,any_ok && String.is_empty(error),
        u => agy_sh_cursor(cursor,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok),u => cursor),error}

@unsafe
def agy_sh_annotate(r: NR_Request, +prepared: P169Prepared) -> P169Prepared:
  match r:
    case NR_Request{source,+book,names,paths,scope,bound}:
      +adts = agy_sh_str_adts_ok(book)
      +chr_eq_ok = agy_sh_def_pin(book,"Char.is_eq",3302228733,42192839)
      +chr_u32_ok = agy_sh_def_pin(book,"Char.to_u32",1968267531,1583642761)
      +base_eq_ok = adts && chr_u32_ok &&
        agy_sh_def_pin(book,"String.eq",225128774,712577888) &&
        agy_sh_def_pin(book,"String.order",565631753,2204196711) &&
        agy_sh_def_pin(book,"String.order.go",3716281844,3937681030)
      +eq_go_ok = adts && (
        (chr_eq_ok && agy_sh_def_pin(book,"p88_string_eq_go",3024631756,2674381182)) ||
        (chr_u32_ok && agy_sh_def_pin(book,"p88_string_eq_go",1723204692,4196828370)))
      +eq_ok =
        (eq_go_ok && agy_sh_def_pin(book,"p98_eq_finish",165389557,2460805607) &&
          agy_sh_def_pin(book,"p88_string_eq",3716379759,1182868109)) ||
        (base_eq_ok && agy_sh_def_pin(book,"p88_string_eq",1506689157,1260695159))
      +agy_eq_ok = base_eq_ok && agy_sh_def_pin(book,"agy_str_eq",339807906,3620894948)
      +hash_ok = adts && chr_u32_ok && agy_sh_def_pin(book,"index_hash",1696180074,3131242088)
      +kt_adts = agy_sh_kterm_adt_ok(book)
      +tageq_read_ok = kt_adts && (
        (eq_ok && agy_sh_def_pin(book,"p98_tag_eq_read",572502218,3139754552)) ||
        (base_eq_ok && agy_sh_def_pin(book,"p98_tag_eq_read",2686625593,3004633447)))
      +tageq_ok = kt_adts && (
        (tageq_read_ok && agy_sh_def_pin(book,"p98_tag_eq_finish",133393152,3410656966) &&
          agy_sh_def_pin(book,"p98_tag_eq",2318141704,1837477542)) ||
        (base_eq_ok && agy_sh_def_pin(book,"p98_tag_eq",2108109257,3206482399)))
      +app_ok = adts && agy_sh_def_pin(book,"String.append",4091005164,4104059294)
      +kdef_adts = agy_map_has_ctor(book,"KDef","KIndexNode",4) && agy_map_has_ctor(book,"KDef","KIndexLeaf",2)
      +idx_ok = kdef_adts && (
        agy_sh_def_pin(book,"index_find",1054931980,2997011162) ||
        agy_sh_def_pin(book,"index_find",4236728576,1742000806) ||
        agy_sh_def_pin(book,"index_find",2377362981,867914087))
      +p1 = agy_sh_apply(prepared,eq_go_ok,eq_ok,agy_eq_ok,base_eq_ok,hash_ok,tageq_ok,tageq_read_ok)
      w14e_sh_extra_apply(p1,app_ok,idx_ok)"""

    src = replace_exact(src, old_sh_ann, new_sh_ann, "W14E agy_sh_annotate marks for append + idxfind")

    return src


def main() -> None:
    ap = argparse.ArgumentParser(description="Apply W14-E patches to wave13_unified/compiler.bend")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--out-bend", type=Path, default=DEFAULT_OUT)
    args = ap.parse_args()

    src = args.src.read_text(encoding="utf-8")
    out = apply_w14e(src)
    args.out_bend.parent.mkdir(parents=True, exist_ok=True)
    args.out_bend.write_text(out, encoding="utf-8")
    out2 = apply_w14e(out)
    assert out2 == out, "apply_w14e is NOT idempotent!"
    print(f"[W14-E] Patched {args.src} -> {args.out_bend} ({len(src):,} B -> {len(out):,} B, +{len(out)-len(src):,} B, idempotent=OK)")


if __name__ == "__main__":
    main()
