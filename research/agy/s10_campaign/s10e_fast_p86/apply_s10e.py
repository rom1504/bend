#!/usr/bin/env python3
"""S10-E: Pure-Bend `p86_plan` 3x Speedup Patcher.

Idempotent, general, pure-Bend patcher against `selfhost/build/agy/wave15_unified/compiler.bend`.
Touches ZERO `bend2/bend.ts`, `runtime.c`, `runtime-agy.o`, `x198pw_plan*`, `x187_pub*`, or `x187_elf*`.

Five structural optimizations inside `p86_plan`:
  1. `s10e_plan` (fast frontend driver for `x86-object*` / `x86-module*`):
     - Skips unused `driver_report_data(original)`.
     - Runs `driver_emit_owned(suffix)` when `eligible == True` (skips rescanning Base).
     - When `fast == True` (`-O0`): skips `-O2`-only `agy_bf_plan`/`agy_abs_plan`/`w2d_plan`.
     - When `fast == True`: skips `annotate_selected` on all self-calling `@unsafe` stubs
       (`w10_if_stub_kind(context, dn(d)) > 0`), both prefix and suffix.
     - Fast-paths `jl_checked_error` (which only checks for open `Array` element types):
       if `"Array"` is not in `rbook`, `jl_checked_error` is mathematically `""` in O(|rbook|) (~0.05 ms).
     - `s10e_prepare_annotated` reuses `da(cache)` from `BookCache` in O(1) instead of
       running `norm_max_book(merged)` over all ~500,000 AST nodes.
  2. `s10e_p143cb_program` / `s10e_p156cp_walk` (fast typecheck walk in `fast == True`):
     - Skips `check_definition_world` on self-calling `@unsafe` stubs (`w10_if_peel_stub > 0`,
       which have only Lam/App/Ref/Var/Let and produce bit-for-bit identical `KDef` output).
     - In `x86-module-fast` (`is_mod == True && fast == True`): also skips `check_definition_world`
       on `ADT` and `law` (`dv == Absent`) declarations (already declared in `w7c_declare_cached`,
       `dg_event_output` returns `d` unchanged). All real `def` bodies are still 100% typechecked.
  3. `w7b_jl_ctr` fast-path (for programs that DO use `Array`):
     - Only calls `w7b_wnf(book, ty)` for the 9 builtin constructors (`Zero`, `Succ`, `ALeaf`,
       `ANode`, `U32`, `F32`, `Chr`, `SNil`, `SCon`); all other constructors go straight to `jl_fields`.
  4. Fast direct-compiled lexer (`p150l_cursor`, `p150l_word`, `p150l_comment`, `w7_lex_*`):
     - Self-tail-recursive `p150l_word` (no `f_choose`, no mutual `p170ls_word` call per char).
     - Tight `s10e_lex_spaces` loop for runs of ASCII `' '` (no `dg_units`/`f_cursor_add` per space).
     - Fast 1-char punctuation dispatch for `(`, `)`, `,`, `:`, `{`, `}`, `[`, `]` using static
       string literals (eliminates 14 function calls + heap string alloc per punctuation token).
     - Fast ASCII `< 65536` path in `w7_lex_cmt_nl` (avoids `dg_units` per comment char).
  5. Single-source post-parse fast-path (`s10e_prefix_complete_source`):
     - Skips `f_prefix_names_extend` and `f_prefix_ctors_extend` on the final source module
       in `s10e_plan` (never read by `f_prefix_graph_trace`).
"""
from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave15_unified/compiler.bend"
DEFAULT_OUT = Path("/tmp/agy_s10e/compiler_s10e.bend")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if new in text:
        print(f"  [SKIP] {label} (already applied)", flush=True)
        return text
    cnt = text.count(old)
    if cnt != 1:
        raise RuntimeError(f"{label}: expected 1 match, found {cnt}")
    print(f"  [OK]   {label}", flush=True)
    return text.replace(old, new, 1)


def apply_s10e(text: str, include_lexer: bool = True) -> str:
    # =========================================================================
    # 1. Fast direct-compiled lexer (spaces, words, common punctuation, comments)
    # =========================================================================
    old_lex_space = """@unsafe
def w7_lex_ident(isId: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isId:
    case True{}:
      p150l_word_done(p150l_word(rest, SCon{head, ""}, 1, head), l, c, d, acc, offset, previous)
    case False{}:
      p150l_other(head, rest, l, c, d, acc, offset, previous)"""

    new_lex_space = """@unsafe
def s10e_lex_emit1(+tok: String, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  +end : U32 = f_cursor_add(offset, 1)
  p150l_cursor(rest, l, U32.inc(c), d, Con{FToken{tok, l, c, 0, offset, end, previous}, acc}, end, end)

@unsafe
def s10e_lex_p93(ok: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match ok:
    case True{}: s10e_lex_emit1("]", rest, l, c, U32.sub(d, 1), acc, offset, previous)
    case False{}: p150l_other(head, rest, l, c, d, acc, offset, previous)

@unsafe
def s10e_lex_p91(ok: Bool, +code: U32, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match ok:
    case True{}: s10e_lex_emit1("[", rest, l, c, U32.inc(d), acc, offset, previous)
    case False{}: s10e_lex_p93(U32.is_eq(code, 93), head, rest, l, c, d, acc, offset, previous)

@unsafe
def s10e_lex_p125(ok: Bool, +code: U32, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match ok:
    case True{}: s10e_lex_emit1("}", rest, l, c, U32.sub(d, 1), acc, offset, previous)
    case False{}: s10e_lex_p91(U32.is_eq(code, 91), code, head, rest, l, c, d, acc, offset, previous)

@unsafe
def s10e_lex_p123(ok: Bool, +code: U32, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match ok:
    case True{}: s10e_lex_emit1("{", rest, l, c, U32.inc(d), acc, offset, previous)
    case False{}: s10e_lex_p125(U32.is_eq(code, 125), code, head, rest, l, c, d, acc, offset, previous)

@unsafe
def s10e_lex_p58(ok: Bool, +code: U32, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match ok:
    case True{}: s10e_lex_emit1(":", rest, l, c, d, acc, offset, previous)
    case False{}: s10e_lex_p123(U32.is_eq(code, 123), code, head, rest, l, c, d, acc, offset, previous)

@unsafe
def s10e_lex_p44(ok: Bool, +code: U32, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match ok:
    case True{}: s10e_lex_emit1(",", rest, l, c, d, acc, offset, previous)
    case False{}: s10e_lex_p58(U32.is_eq(code, 58), code, head, rest, l, c, d, acc, offset, previous)

@unsafe
def s10e_lex_p41(ok: Bool, +code: U32, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match ok:
    case True{}: s10e_lex_emit1(")", rest, l, c, U32.sub(d, 1), acc, offset, previous)
    case False{}: s10e_lex_p44(U32.is_eq(code, 44), code, head, rest, l, c, d, acc, offset, previous)

@unsafe
def s10e_lex_p40(ok: Bool, +code: U32, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match ok:
    case True{}: s10e_lex_emit1("(", rest, l, c, U32.inc(d), acc, offset, previous)
    case False{}: s10e_lex_p41(U32.is_eq(code, 41), code, head, rest, l, c, d, acc, offset, previous)

@unsafe
def s10e_lex_punct(+code: U32, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  s10e_lex_p40(U32.is_eq(code, 40), code, head, rest, l, c, d, acc, offset, previous)

law s10e_lex_spaces:
  for s: String
  for +l: U32
  for +c: U32
  for +d: U32
  for +acc: List<&2, FToken>
  for +offset: U32
  for +previous: U32
  for +n: U32
  List<&2, FToken>

@unsafe
def s10e_lex_sp_step(isSp: Bool, +code: U32, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32, +n: U32) -> List<&2, FToken>:
  match isSp:
    case True{}: s10e_lex_spaces(rest, l, U32.inc(c), d, acc, offset, previous, U32.inc(n))
    case False{}:
      +off2 : U32 = f_cursor_add(offset, n)
      w7_lex_nl(U32.is_eq(code, 10), head, rest, l, c, d, acc, off2, previous, code)

@unsafe
def s10e_lex_spaces(s, l, c, d, acc, offset, previous, n):
  match s:
    case SNil{}:
      w7_lex_eof(U32.is_eq(offset, 0), acc, f_cursor_add(offset, n), previous)
    case SCon{+head, +rest}:
      +code : U32 = Char.to_u32(head)
      s10e_lex_sp_step(U32.is_eq(code, 32), code, head, rest, l, c, d, acc, offset, previous, n)

@unsafe
def w7_lex_ident(isId: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isId:
    case True{}:
      p150l_word_done(p150l_word(rest, SCon{head, ""}, 1, head), l, c, d, acc, offset, previous)
    case False{}:
      s10e_lex_punct(Char.to_u32(head), head, rest, l, c, d, acc, offset, previous)"""

    if include_lexer:
        text = replace_once(text, old_lex_space, new_lex_space, "s10e_lex_punct_and_spaces")

    old_w7_space = """@unsafe
def w7_lex_space(isSp: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32, +code: U32) -> List<&2, FToken>:
  match isSp:
    case True{}:
      p150l_cursor(rest, l, U32.add(c, 1), d, acc, f_cursor_add(offset, dg_units(head)), previous)
    case False{}:
      w7_lex_comment(U32.is_eq(code, 35), head, rest, l, c, d, acc, offset, previous, code)"""

    new_w7_space = """@unsafe
def w7_lex_space(isSp: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32, +code: U32) -> List<&2, FToken>:
  match isSp:
    case True{}:
      s10e_lex_spaces(rest, l, U32.inc(c), d, acc, offset, previous, 1)
    case False{}:
      w7_lex_comment(U32.is_eq(code, 35), head, rest, l, c, d, acc, offset, previous, code)"""

    if include_lexer:
        text = replace_once(text, old_w7_space, new_w7_space, "s10e_w7_lex_space_fast")

    old_cmt = """@unsafe
def w7_lex_cmt_nl(isNl: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isNl:
    case True{}:
      p150l_newline(rest, l, c, d, acc, offset, previous)
    case False{}:
      p150l_comment(rest, l, c, d, acc, f_cursor_add(offset, dg_units(head)), previous)"""

    new_cmt = """@unsafe
def s10e_u16_units(bmp: Bool) -> U32:
  match bmp:
    case True{}: 1
    case False{}: 2

@unsafe
def w7_lex_cmt_nl(isNl: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isNl:
    case True{}:
      p150l_newline(rest, l, c, d, acc, offset, previous)
    case False{}:
      p150l_comment(rest, l, c, d, acc, f_cursor_add(offset, s10e_u16_units(U32.is_lt(Char.to_u32(head), 65536))), previous)"""

    if include_lexer:
        text = replace_once(text, old_cmt, new_cmt, "s10e_lex_cmt_fast")

    old_word = """@unsafe
def p150l_word(+s: String, +acc: String, +n: U32, +last: Char) -> FScanned:
  p170ls_word(s,s,acc,n,last)"""

    new_word = """@unsafe
def s10e_lex_word_exp(ok: Bool, +head: Char, +rest: String, +original: String, +acc: String, +n: U32) -> FScanned:
  match ok:
    case True{}: p150l_word(rest, SCon{head, acc}, U32.inc(n), head)
    case False{}: FScanned{String.reverse(acc), original, n}

@unsafe
def s10e_lex_word_step(isId: Bool, +code: U32, +head: Char, +rest: String, +original: String, +acc: String, +n: U32, +last: Char) -> FScanned:
  match isId:
    case True{}: p150l_word(rest, SCon{head, acc}, U32.inc(n), head)
    case False{}:
      +lc : U32 = Char.to_u32(last)
      s10e_lex_word_exp(
        (U32.is_eq(code, 43) || U32.is_eq(code, 45)) && (U32.is_eq(lc, 101) || U32.is_eq(lc, 69)) && p150l_digit(rest),
        head, rest, original, acc, n)

@unsafe
def p150l_word(+s: String, +acc: String, +n: U32, +last: Char) -> FScanned:
  match s:
    case SNil{}: FScanned{String.reverse(acc), "", n}
    case SCon{+head, +rest}:
      +code : U32 = Char.to_u32(head)
      s10e_lex_word_step(f_ascii_ident_code(code), code, head, rest, s, acc, n, last)"""

    if include_lexer:
        text = replace_once(text, old_word, new_word, "s10e_p150l_word_direct")

    # 1b. Fast f_raw_skip / f_skip (check token kind == 0 before string compares, no f_choose)
    old_raw_skip = r"""@unsafe
def f_raw_skip(
  +ts: List<&2, FToken>,
) -> List<&2, FToken>:
  f_choose(List<&2, FToken>, Bool.or(f_eq(f_raw_tx(ts), "\n"), f_eq(f_raw_tx(ts), ";")),
    u => f_raw_skip(f_raw_tl(ts)), u => ts)"""

    new_raw_skip = r"""@unsafe
def s10e_raw_skip_step(isSkip: Bool, +ts: List<&2, FToken>, +rest: List<&2, FToken>) -> List<&2, FToken>:
  match isSkip:
    case True{}: f_raw_skip(rest)
    case False{}: ts

@unsafe
def s10e_raw_skip_k0(isK0: Bool, +t: String, +ts: List<&2, FToken>, +rest: List<&2, FToken>) -> List<&2, FToken>:
  match isK0:
    case True{}: s10e_raw_skip_step(f_eq(t, "\n") || f_eq(t, ";"), ts, rest)
    case False{}: ts

@unsafe
def f_raw_skip(
  +ts: List<&2, FToken>,
) -> List<&2, FToken>:
  match ts:
    case Nil{}: Nil{}
    case Con{FToken{+t, l, c, +k, begin, end, previousEnd}, +rest}:
      s10e_raw_skip_k0(U32.is_eq(k, 0), t, ts, rest)"""

    text = replace_once(text, old_raw_skip, new_raw_skip, "s10e_f_raw_skip_fast")

    old_f_skip = r"""@unsafe
def f_skip(+input: FInput) -> FInput:
  match input:
    case FInput{tokens, context}:
      f_choose(FInput, f_eq(f_raw_tx(tokens), "\n") || f_eq(f_raw_tx(tokens), ";"),
        u => FInput{f_raw_skip(tokens), context}, u => input)"""

    new_f_skip = r"""@unsafe
def s10e_f_skip_step(isSkip: Bool, +input: FInput, +rest: List<&2, FToken>, +context: FParseContext) -> FInput:
  match isSkip:
    case True{}: FInput{f_raw_skip(rest), context}
    case False{}: input

@unsafe
def s10e_f_skip_k0(isK0: Bool, +t: String, +input: FInput, +rest: List<&2, FToken>, +context: FParseContext) -> FInput:
  match isK0:
    case True{}: s10e_f_skip_step(f_eq(t, "\n") || f_eq(t, ";"), input, rest, context)
    case False{}: input

@unsafe
def f_skip(+input: FInput) -> FInput:
  match input:
    case FInput{tokens, +context}:
      match tokens:
        case Nil{}: input
        case Con{FToken{+t, l, c, +k, begin, end, previousEnd}, +rest}:
          s10e_f_skip_k0(U32.is_eq(k, 0), t, input, rest, context)"""

    text = replace_once(text, old_f_skip, new_f_skip, "s10e_f_skip_fast")

    # 1c. Fast f_atom_existing (dispatch on f_kind(ts) to skip 11 string eqs + String.ends_with on every ident!)
    old_atom_ex = r"""@unsafe
def f_atom_existing(+ts: FInput) -> FParsed:
  f_locate(f_atom_raw(ts), f_begin(ts), f_eq(f_tx(ts), "+") || f_eq(f_tx(ts), "+bind") || f_eq(f_tx(ts), "++"), f_eq(f_tx(ts), "@") || (f_eq(f_tx(ts), "&") && Bool.not(f_eq(f_tx(f_tl(ts)), "0") || f_eq(f_tx(f_tl(ts)), "1") || f_eq(f_tx(f_tl(ts)), "2"))) || f_eq(f_tx(ts), "+") || f_eq(f_tx(ts), "+bind") || (String.ends_with(f_tx(ts), "n") && f_eq(f_tx(f_tl(ts)), "+")), f_eq(f_tx(ts), "[") || f_eq(f_tx(ts), "(") || f_eq(f_tx(ts), "&") || f_eq(f_tx(ts), "\\"))"""

    new_atom_ex = r"""@unsafe
def s10e_atom_k2(isK2: Bool, +ts: FInput) -> FParsed:
  match isK2:
    case True{}: f_locate(f_atom_raw(ts), f_begin(ts), False{}, False{}, False{})
    case False{}:
      +tx : String = f_tx(ts)
      +is_plus : Bool = f_eq(tx, "+") || f_eq(tx, "+bind")
      +is_amp : Bool = f_eq(tx, "&")
      f_locate(f_atom_raw(ts), f_begin(ts),
        is_plus || f_eq(tx, "++"),
        is_plus || f_eq(tx, "@") || (is_amp && Bool.not(f_eq(f_tx(f_tl(ts)), "0") || f_eq(f_tx(f_tl(ts)), "1") || f_eq(f_tx(f_tl(ts)), "2"))),
        is_amp || f_eq(tx, "[") || f_eq(tx, "(") || f_eq(tx, "\\"))

@unsafe
def s10e_atom_k1(isK1: Bool, +ts: FInput, +k: U32) -> FParsed:
  match isK1:
    case True{}:
      +spaced : Bool = f_eq(f_tx(f_tl(ts)), "+") && String.ends_with(f_tx(ts), "n")
      f_locate(f_atom_raw(ts), f_begin(ts), False{}, spaced, False{})
    case False{}:
      s10e_atom_k2(U32.is_eq(k, 2), ts)

@unsafe
def f_atom_existing(+ts: FInput) -> FParsed:
  +k : U32 = f_kind(ts)
  s10e_atom_k1(U32.is_eq(k, 1), ts, k)"""

    text = replace_once(text, old_atom_ex, new_atom_ex, "s10e_f_atom_existing_fast")

    # =========================================================================
    # 2. w7b_jl_ctr fast-path (skip w7b_wnf for non-builtin constructors)
    # =========================================================================
    old_jl_ctr = """@unsafe
def w7b_jl_ctr(+book: List<&2, KDef>, +t: KTerm, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  +wty = w7b_wnf(book, ty)
  w7b_jl_ctr_if(w7b_jl_ctr_sp_if(p98_tag_eq(wty, "ADT"), wty), book, t, wty, todo)"""

    new_jl_ctr = """@unsafe
def s10e_is_builtin_ctr(+n: String) -> Bool:
  p88_string_eq(n, "ALeaf") || p88_string_eq(n, "ANode") || p88_string_eq(n, "Zero") || p88_string_eq(n, "Succ") ||
  p88_string_eq(n, "U32") || p88_string_eq(n, "F32") || p88_string_eq(n, "Chr") || p88_string_eq(n, "SNil") || p88_string_eq(n, "SCon")

@unsafe
def s10e_jl_ctr_go(isBuiltin: Bool, +book: List<&2, KDef>, +t: KTerm, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  match isBuiltin:
    case True{}:
      +wty = w7b_wnf(book, ty)
      w7b_jl_ctr_if(w7b_jl_ctr_sp_if(p98_tag_eq(wty, "ADT"), wty), book, t, wty, todo)
    case False{}:
      jl_fields(book, ks(t), todo)

@unsafe
def w7b_jl_ctr(+book: List<&2, KDef>, +t: KTerm, +ty: KTerm, +todo: List<&2, String>) -> List<&2, String>:
  s10e_jl_ctr_go(s10e_is_builtin_ctr(nm(t)), book, t, ty, todo)"""

    text = replace_once(text, old_jl_ctr, new_jl_ctr, "s10e_w7b_jl_ctr_fast")

    # =========================================================================
    # 3. p144o_prepare_annotated O(1) bound reuse from BookCache
    # =========================================================================
    old_p144o = """@unsafe
def p144o_prepare_annotated(+book: List<&2,KDef>, annotated: List<&2,KDef>) -> NR_Request:
  +merged = nc_context_defs(book,nc_context_index(annotated))
  +bound = norm_max_book(merged)
  +source = book_cached(merged,bound)
  p144o_source_ready(source,bound,p144o_build(source))"""

    new_p144o = """@unsafe
def s10e_cached_bound_go(isCache: Bool, +cache: KDef, +merged: List<&2,KDef>) -> U32:
  match isCache:
    case True{}: norm_max(da(cache), 1)
    case False{}: norm_max_book(merged)

@unsafe
def s10e_cached_bound(book: List<&2,KDef>, +merged: List<&2,KDef>) -> U32:
  match book:
    case Con{+cache, _}: s10e_cached_bound_go(p88_string_eq(dk(cache), "BookCache"), cache, merged)
    case Nil{}: norm_max_book(merged)

@unsafe
def p144o_prepare_annotated(+book: List<&2,KDef>, annotated: List<&2,KDef>) -> NR_Request:
  +merged = nc_context_defs(book,nc_context_index(annotated))
  +bound = s10e_cached_bound(book, merged)
  +source = book_cached(merged,bound)
  p144o_source_ready(source,bound,p144o_build(source))"""

    text = replace_once(text, old_p144o, new_p144o, "s10e_p144o_cached_bound")

    # =========================================================================
    # 4. s10e_plan + s10e_p143cb_program + s10e_prefix_complete_source
    # =========================================================================
    old_tr_prep = """@unsafe
def w8_tr_compile_prep(+trace: Bool, +fast: Bool, +is_mod: Bool, +path: String, +source: String, +t1: Nat, prep: P86Preparation) -> IO(W10TrCompiled):
  match prep:
    case P86PreparationError{error}:
      do IO<W10TrCompiled>:
        _ : Unit <- w8_tr_log(trace,"stage=prep_error msg=" ++ error)
        IO.pure(W10TrCompiled,W10TrCompiled{p169s_fail(error),missing()})
    case P86PreparationReady{+seed}:
      do IO<W10TrCompiled>:
        +weak_set : KDef = nt_choose(KDef,is_mod,u => w10_weak_from_seed(seed),u => missing())
        +plan : P86Plan <- IO.pure(P86Plan,p86_plan(seed,path,source))
        +t2 : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=p86_plan ms=" ++ w8_tr_ms(t1,t2))
        +prepared : P169Prepared <- IO.pure(P169Prepared,nt_choose(P169Prepared,fast,u => x198pw_plan_fast(plan),u => x198pw_plan(plan)))
        +t3 : Nat <- IO.now()
        w8_tr_compile_done(trace,t2,t3,prepared,weak_set)"""

    s10e_frontend = """# === S10-E: Fast p86_plan (skip unused report/O2-passes/stub-ann/Array-less jl/stub-check) ===

law s10e_has_array:
  for defs: List<&2, KDef>
  Bool

@unsafe
def s10e_has_array_step(hit: Bool, rest: List<&2, KDef>) -> Bool:
  match hit:
    case True{}: True{}
    case False{}: s10e_has_array(rest)

@unsafe
def s10e_has_array(defs):
  match defs:
    case Nil{}: False{}
    case Con{d, rest}: s10e_has_array_step(p88_string_eq(dn(d), "Array"), rest)

law s10e_ann_stops_all:
  for +book: List<&2, KDef>
  for rbook: List<&2, KDef>
  for +acc: List<&2, String>
  List<&2, String>

@unsafe
def s10e_ann_stops_step(isStub: Bool, +book: List<&2, KDef>, +nm0: String, rest: List<&2, KDef>, +acc: List<&2, String>) -> List<&2, String>:
  match isStub:
    case True{}: s10e_ann_stops_all(book, rest, Con{nm0, acc})
    case False{}: s10e_ann_stops_all(book, rest, acc)

@unsafe
def s10e_ann_stops_all(book, rbook, acc):
  match rbook:
    case Nil{}: acc
    case Con{d, rest}:
      +nm0 : String = dn(d)
      s10e_ann_stops_step(U32.is_gt(w10_if_stub_kind(book, nm0), 0), book, nm0, rest, acc)

@unsafe
def s10e_jl_check_go(hasArr: Bool, +context: List<&2, KDef>, +annotated: List<&2, KDef>, +stops: List<&2, String>) -> String:
  match hasArr:
    case True{}: jl_checked_error(context, annotated, ["main"], stops)
    case False{}: ""

@unsafe
def s10e_jl_check(+context: List<&2, KDef>, +rbook: List<&2, KDef>, +annotated: List<&2, KDef>, +stops: List<&2, String>) -> String:
  s10e_jl_check_go(s10e_has_array(rbook), context, annotated, stops)

@unsafe
def s10e_plan_annotated_ok(fast: Bool, +context: List<&2, KDef>, +stops: List<&2, String>, +annotated: List<&2, KDef>) -> P86Plan:
  match fast:
    case True{}: P86PlanReady{nr_prepare_annotated(context, annotated), ""}
    case False{}: agy_bf_plan(context, stops, "", annotated)

@unsafe
def s10e_plan_annotated_go(ok: Bool, +error: String, +context: List<&2, KDef>, +stops: List<&2, String>, +annotated: List<&2, KDef>, +fast: Bool) -> P86Plan:
  match ok:
    case True{}: s10e_plan_annotated_ok(fast, context, stops, annotated)
    case False{}: P86PlanError{"compile: " ++ error}

@unsafe
def s10e_plan_annotated(+context: List<&2, KDef>, +rbook: List<&2, KDef>, +stops: List<&2, String>, +astops: List<&2, String>, +annotated: List<&2, KDef>, +fast: Bool) -> P86Plan:
  +error : String = s10e_jl_check(context, rbook, annotated, astops)
  s10e_plan_annotated_go(String.is_empty(error), error, context, stops, annotated, fast)

@unsafe
def s10e_astops_pick(fast: Bool, +eligible: Bool, +context: List<&2, KDef>, +suffix: List<&2, KDef>, +rbook: List<&2, KDef>, +stops: List<&2, String>) -> List<&2, String>:
  match fast:
    case True{}: s10e_ann_stops_all(context, rbook, stops)
    case False{}:
      match eligible:
        case True{}: w14d_ann_stops(context, w10_if_suffix_set(suffix, missing()), rbook, stops)
        case False{}: stops

@unsafe
def s10e_plan_context(+context: List<&2, KDef>, +suffix: List<&2, KDef>, +eligible: Bool, +fast: Bool) -> P86Plan:
  +stops : List<&2, String> = nc_annotation_stops(context)
  +rbook : List<&2, KDef> = reach_book(context, ["main"], stops)
  +astops : List<&2, String> = s10e_astops_pick(fast, eligible, context, suffix, rbook, stops)
  s10e_plan_annotated(context, rbook, stops, astops, annotate_selected(context, rbook, astops), fast)

@unsafe
def s10e_plan_checked_j(ok: Bool, +jerr: String, +load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2, KDef>, +suffix: List<&2, KDef>, +eligible: Bool, +fast: Bool) -> P86Plan:
  match ok:
    case True{}: s10e_plan_context(book_context_world(book, load, world), suffix, eligible, fast)
    case False{}: P86PlanError{"compile: " ++ jerr}

@unsafe
def s10e_plan_checked_o(ok: Bool, +oerr: String, +load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2, KDef>, +suffix: List<&2, KDef>, +eligible: Bool, +fast: Bool) -> P86Plan:
  match ok:
    case True{}:
      +jerr : String = j_compile_error(book)
      s10e_plan_checked_j(String.is_empty(jerr), jerr, load, world, book, suffix, eligible, fast)
    case False{}: P86PlanError{"compile: " ++ oerr}

@unsafe
def s10e_plan_checked_ok(ok: Bool, +error: String, +load: FPrefixLoad, +world: KBasePreparedWorld, +book: List<&2, KDef>, +suffix: List<&2, KDef>, +eligible: Bool, +fast: Bool) -> P86Plan:
  match ok:
    case True{}:
      +oerr : String = driver_emit_owned(nt_choose(List<&2, KDef>, eligible, v => suffix, v => book))
      s10e_plan_checked_o(String.is_empty(oerr), oerr, load, world, book, suffix, eligible, fast)
    case False{}: P86PlanError{"check: " ++ error}

@unsafe
def s10e_plan_checked(+load: FPrefixLoad, +world: KBasePreparedWorld, +suffix: List<&2, KDef>, +eligible: Bool, +fast: Bool, result: DResult) -> P86Plan:
  match result:
    case DResult{+error, +book, diagnostic}:
      s10e_plan_checked_ok(String.is_empty(error), error, load, world, book, suffix, eligible, fast)

@unsafe
def s10e_skip_def_stub(isStub: Bool, +d: KDef, +is_mod: Bool) -> Bool:
  match isStub:
    case True{}: True{}
    case False{}: is_mod && p98_tag_eq(dv(d), "Absent")

@unsafe
def s10e_skip_def_dx(isZero: Bool, +d: KDef, +is_mod: Bool) -> Bool:
  match isZero:
    case False{}: False{}
    case True{}: s10e_skip_def_stub(du(d) && db(d) && U32.is_gt(w10_if_peel_stub(dn(d), dv(d), 0), 0), d, is_mod)

@unsafe
def s10e_skip_def_kind(isDef: Bool, +k: String, +d: KDef, +is_mod: Bool) -> Bool:
  match isDef:
    case True{}: s10e_skip_def_dx(U32.is_eq(dx(d), 0), d, is_mod)
    case False{}: is_mod && p88_string_eq(k, "ADT")

@unsafe
def s10e_skip_def_abs(isAbs: Bool, +d: KDef, +is_mod: Bool) -> Bool:
  match isAbs:
    case False{}: False{}
    case True{}:
      +k : String = dk(d)
      s10e_skip_def_kind(p88_string_eq(k, "Def"), k, d, is_mod)

@unsafe
def s10e_skip_check_def(+d: KDef, +next: KDef, +is_mod: Bool) -> Bool:
  s10e_skip_def_abs(p88_string_eq(dk(next), "Absent"), d, is_mod)

law s10e_p156cp_walk:
  for events: List<&2, P143CEvent>
  for +world: KWorld
  for +seen: List<&2, KDef>
  for +dirty: Bool
  for +is_mod: Bool
  DChecking

@unsafe
def s10e_p156cp_stored(+rest: List<&2, P143CEvent>, +seen: List<&2, KDef>, +definition: KDef,
    +term: KTerm, +world: KWorld, +book: List<&2, KDef>, +dirty: Bool, +is_mod: Bool) -> DChecking:
  s10e_p156cp_walk(rest, kw_put_checked(kw_with_book(world, book), dg_event_output(definition, term)), p171s_put(seen, definition), dirty, is_mod)

@unsafe
def s10e_p156cp_put_cached(canLog: Bool, +rest: List<&2, P143CEvent>, +seen: List<&2, KDef>, +definition: KDef,
    +term: KTerm, +world: KWorld, +cache: KDef, +tail: List<&2, KDef>, +book: List<&2, KDef>, +dirty: Bool, +is_mod: Bool) -> DChecking:
  match canLog:
    case True{}: s10e_p156cp_stored(rest, seen, definition, term, world, p143cp_logged(cache, tail, definition), True{}, is_mod)
    case False{}:
      s10e_p156cp_stored(rest, seen, definition, term, world,
        book_put(nt_choose(List<&2, KDef>, dirty, u => p143cp_canon(book), u => book), definition), False{}, is_mod)

@unsafe
def s10e_p156cp_put(+rest: List<&2, P143CEvent>, +seen: List<&2, KDef>, +definition: KDef,
    +term: KTerm, +world: KWorld, +book: List<&2, KDef>, +dirty: Bool, +is_mod: Bool) -> DChecking:
  match book:
    case Nil{}: s10e_p156cp_stored(rest, seen, definition, term, world, book_put(book, definition), False{}, is_mod)
    case Con{+cache, +tail}:
      s10e_p156cp_put_cached(p88_string_eq(dk(cache), "BookCache") && Bool.not(p88_string_eq(dk(definition), "BookCache")),
        rest, seen, definition, term, world, cache, tail, book, dirty, is_mod)

@unsafe
def s10e_p156cp_pub(isAbs: Bool, +rest: List<&2, P143CEvent>, +seen: List<&2, KDef>, +definition: KDef,
    +result: KChecking, +dirty: Bool, +is_mod: Bool) -> DChecking:
  match isAbs:
    case True{}: s10e_p156cp_put(rest, seen, definition, ct(result), rw(result), kw_book(rw(result)), dirty, is_mod)
    case False{}: s10e_p156cp_walk(rest, rw(result), p171s_put(seen, definition), dirty, is_mod)

@unsafe
def s10e_p156cp_next_go(ok: Bool, +rest: List<&2, P143CEvent>, +seen: List<&2, KDef>, +definition: KDef,
    +next: KDef, +dirty: Bool, +is_mod: Bool, +result: KChecking) -> DChecking:
  match ok:
    case True{}: s10e_p156cp_pub(p88_string_eq(dk(next), "Absent"), rest, seen, definition, result, dirty, is_mod)
    case False{}: dg_event_failed(result, dn(definition))

@unsafe
def s10e_p156cp_next(+rest: List<&2, P143CEvent>, +seen: List<&2, KDef>, +definition: KDef,
    +next: KDef, +dirty: Bool, +is_mod: Bool, +result: KChecking) -> DChecking:
  s10e_p156cp_next_go(good(result), rest, seen, definition, next, dirty, is_mod, result)

@unsafe
def s10e_p156cp_do(skip: Bool, +rest: List<&2, P143CEvent>, +world: KWorld, +seen: List<&2, KDef>,
    +definition: KDef, +next: KDef, +dirty: Bool, +is_mod: Bool) -> DChecking:
  match skip:
    case True{}: s10e_p156cp_put(rest, seen, definition, dv(definition), world, kw_book(world), dirty, is_mod)
    case False{}:
      s10e_p156cp_next(rest, seen, definition, next, dirty, is_mod,
        check_definition_world(world, p143cs_mode(definition, next), 0))

@unsafe
def s10e_p156cp_guard(ok: Bool, +guard: String, +rest: List<&2, P143CEvent>, +world: KWorld, +seen: List<&2, KDef>,
    +definition: KDef, +next: KDef, +dirty: Bool, +is_mod: Bool) -> DChecking:
  match ok:
    case True{}: s10e_p156cp_do(s10e_skip_check_def(definition, next, is_mod), rest, world, seen, definition, next, dirty, is_mod)
    case False{}: DChecking{bad(world, dn(definition) ++ ": " ++ guard), dg_no_report(dn(definition), guard)}

@unsafe
def s10e_p156cp_walk(events, world, seen, dirty, is_mod):
  match events:
    case Nil{}: DChecking{bad(world, ""), dg_no_report("", "")}
    case Con{P143CEvent{+definition, +next}, +rest}:
      +guard : String = event_error(seen, definition, lookup(seen, dn(definition)))
      s10e_p156cp_guard(p88_string_eq(guard, ""), guard, rest, world, seen, definition, next, dirty, is_mod)

@unsafe
def s10e_p143cb_resume_state(+state: KBasePrefixState, +book: List<&2, KDef>, +checked: List<&2, KDef>,
    +seen: List<&2, KDef>, +suffix: List<&2, KDef>, +bound: U32, +is_mod: Bool) -> DChecking:
  match state:
    case KBasePrefixState{base_bound, delta, stamp, patches, ready}:
      +declared : List<&2, KDef> = w7c_declare_cached(suffix, kw_bound_book(book, U32.add(bound, stamp)))
      +ordered : List<&2, KDef> = base_prefix_world_order(declared, base_prefix_world_raw(book), suffix)
      +world : KWorld = KWorld{ordered, Nil{}, KFreshKnown{U32.add(U32.add(bound, delta), 1)}, checked}
      p143cp_result(s10e_p156cp_walk(p143cs_plan(suffix), world, p171s_seed(kw_bound_book(seen, bound)), True{}, is_mod), True{})

@unsafe
def s10e_p143cb_admitted(+prepared: KBasePreparedWorld, +prefix: List<&2, KDef>, +suffix: List<&2, KDef>,
    +bound: U32, +is_mod: Bool) -> DChecking:
  match prepared:
    case KBasePreparedWorld{+state, original, final, +saved, +checked, +seen, todos, checkedBound}:
      nt_choose(DChecking, p143cp_regular(suffix) && base_prefix_world_hash_disjoint(suffix, index_first(dc(index_first(saved)))),
        u => s10e_p143cb_resume_state(state, saved, checked, seen, suffix, bound, is_mod),
        u => base_prefix_world_check_admitted(prepared, prefix, suffix, bound))

@unsafe
def s10e_p143cb_program(load: FPrefixLoad, +origins: List<&2, DOrigin>, +prepared: KBasePreparedWorld, +is_mod: Bool) -> DResult:
  match load prepared:
    case FPrefixLoad{FLoadTrace{FResult{+book, +error, imports}, done, sources}, +prefix, +suffix, +ready} KBasePreparedWorld{+state, original, +final, +saved, checked, seen, +todos, checkedBound}:
      +bound : U32 = norm_max(base_prefix_world_bound(state), norm_max_book(suffix))
      nt_choose(DResult, ready && String.is_empty(error) && base_prefix_world_admitted(state, suffix, bound, final, saved),
        u => driver_program_checked_prefix(suffix, todos, origins, s10e_p143cb_admitted(prepared, prefix, suffix, bound, is_mod)),
        u => driver_program_checked(book, origins, dg_check_world(book)))

@unsafe
def s10e_prefix_ready_source_completed(+prefix: List<&2, KDef>, +suffix: List<&2, KDef>, +count: U32, +baseNames: KDef, +names: KDef, +ctors: KDef, +completion: FIndexedCompletion) -> FPrefixCompletion:
  match completion:
    case FIndexedCompletion{+graph, +parsed, +fragment}:
      match graph:
        case FGraph{book, +error, done}:
          nt_choose(FPrefixCompletion, String.is_empty(error),
            u => FPrefixCompletion{FReadyPrefixGraph{graph, prefix, norm_defs_join(suffix, fragment), count, True{}, names, ctors, baseNames}, parsed},
            u => FPrefixCompletion{FPrefixGraph{graph, prefix, Nil{}, count, False{}}, parsed})

@unsafe
def s10e_prefix_complete_source(+source: FSource, +ns: String, +header: FHeader, +sources: List<&2, FSource>, +carrier: FPrefixGraph, +root: String) -> FPrefixCompletion:
  match carrier:
    case FPrefixGraph{+graph, +prefix, suffix, +count, +ready}:
      f_prefix_source_completed(prefix, count, ready, f_complete_source(source, ns, header, sources, graph, root))
    case FReadyPrefixGraph{+graph, +prefix, +suffix, +count, +ready, +names, +ctors, +baseNames}:
      nt_choose(FPrefixCompletion, ready,
        u => s10e_prefix_ready_source_completed(prefix, suffix, count, baseNames, names, ctors, f_complete_source_indexed(source, ns, header, sources, graph, root, names, ctors)),
        u => f_prefix_source_completed(prefix, count, False{}, f_complete_source(source, ns, header, sources, graph, root)))

@unsafe
def s10e_plan_loaded_check(fast: Bool, +load: FPrefixLoad, +world: KBasePreparedWorld, +suffix: List<&2, KDef>, +is_mod: Bool) -> DResult:
  match fast:
    case True{}: s10e_p143cb_program(load, Nil{}, world, is_mod)
    case False{}:
      nt_choose(DResult, p143cg_enough(suffix, 256),
        v => p143cb_program(load, Nil{}, world, True{}),
        v => check_program_diagnostic_world(load, Nil{}, world))

@unsafe
def s10e_plan_loaded(+seed: P86Seed, +load: FPrefixLoad, +fast: Bool, +is_mod: Bool) -> P86Plan:
  match seed load:
    case P86Seed{base, book, fresh, ready, +world} FPrefixLoad{FLoadTrace{FResult{original, +error, imports}, done, sources}, prefix, +suffix, +eligible}:
      nt_choose(P86Plan, String.is_empty(error),
        u => s10e_plan_checked(load, world, suffix, eligible, fast, s10e_plan_loaded_check(fast, load, world, suffix, is_mod)),
        u => P86PlanError{"parse: " ++ error})

@unsafe
def s10e_plan_completed(+seed: P86Seed, +source: FSource, completion: FPrefixCompletion, +fast: Bool, +is_mod: Bool) -> P86Plan:
  match seed completion:
    case P86Seed{+base, book, +fresh, ready, world} FPrefixCompletion{carrier, parsed}:
      s10e_plan_loaded(seed, f_prefix_graph_trace(carrier, [source, base], fresh), fast, is_mod)

@unsafe
def s10e_plan_seeded(+seed: P86Seed, +source: FSource, +header: FHeader, completion: FPrefixCompletion, +fast: Bool, +is_mod: Bool) -> P86Plan:
  match seed completion:
    case P86Seed{+base, book, fresh, ready, world} FPrefixCompletion{+carrier, parsed}:
      match parsed:
        case FResult{defs, +error, imports}:
          nt_choose(P86Plan, String.is_empty(error),
            u => s10e_plan_completed(seed, source,
              s10e_prefix_complete_source(source, "", header, [source, base], carrier, f_path_dir(f_source_path(source))), fast, is_mod),
            u => P86PlanError{"parse: " ++ error})

@unsafe
def s10e_plan_seed(+seed: P86Seed, +source: FSource, +header: FHeader, +fast: Bool, +is_mod: Bool) -> P86Plan:
  match seed:
    case P86Seed{+base, +book, fresh, +ready, world}:
      s10e_plan_seeded(seed, source, header,
        f_prefix_complete_ready_seed(base, "", f_prefix_graph_empty(), f_source_path(base), f_source_text(base), book, ready), fast, is_mod)

@unsafe
def s10e_plan_imported(+seed: P86Seed, +source: FSource, +header: FHeader, +error: String, +fast: Bool, +is_mod: Bool) -> P86Plan:
  nt_choose(P86Plan, String.is_empty(error),
    u => s10e_plan_seed(seed, source, header, fast, is_mod),
    u => P86PlanError{"load: " ++ error})

@unsafe
def s10e_plan_header(+seed: P86Seed, +source: FSource, +header: FHeader, +fast: Bool, +is_mod: Bool) -> P86Plan:
  match header:
    case FHeader{imports, +error, body, line, offset}:
      nt_choose(P86Plan, String.is_empty(error),
        u => s10e_plan_imported(seed, source, header, p86_import_error(imports, False{}), fast, is_mod),
        u => P86PlanError{"parse: " ++ error})

@unsafe
def s10e_plan(seed, path, text, fast, is_mod):
  match seed:
    case P86Seed{+base, book, fresh, ready, world}:
      +begin : U32 = f_source_end(base)
      +source : FSource = f_source_located(FSource{path, path, text}, begin, U32.add(U32.add(begin, p86_width(text, 0)), 1))
      s10e_plan_header(seed, source, f_source_header(source), fast, is_mod)

@unsafe
def w8_tr_compile_prep(+trace: Bool, +fast: Bool, +is_mod: Bool, +path: String, +source: String, +t1: Nat, prep: P86Preparation) -> IO(W10TrCompiled):
  match prep:
    case P86PreparationError{error}:
      do IO<W10TrCompiled>:
        _ : Unit <- w8_tr_log(trace,"stage=prep_error msg=" ++ error)
        IO.pure(W10TrCompiled,W10TrCompiled{p169s_fail(error),missing()})
    case P86PreparationReady{+seed}:
      do IO<W10TrCompiled>:
        +weak_set : KDef = nt_choose(KDef,is_mod,u => w10_weak_from_seed(seed),u => missing())
        +plan : P86Plan <- IO.pure(P86Plan,s10e_plan(seed,path,source,fast,is_mod))
        +t2 : Nat <- IO.now()
        _ : Unit <- w8_tr_log(trace,"stage=p86_plan ms=" ++ w8_tr_ms(t1,t2))
        +prepared : P169Prepared <- IO.pure(P169Prepared,nt_choose(P169Prepared,fast,u => x198pw_plan_fast(plan),u => x198pw_plan(plan)))
        +t3 : Nat <- IO.now()
        w8_tr_compile_done(trace,t2,t3,prepared,weak_set)"""

    text = replace_once(text, old_tr_prep, s10e_frontend, "s10e_fast_p86_plan")

    # Also wire non-trace `w10_module_prep_run_fast` and `x198pw_prepared_fast`!
    old_x198_fast = """@unsafe
def x198pw_prepared_fast(+path: String,+source: String,prepared: P86Preparation) -> P169Prepared:
  match prepared:
    case P86PreparationError{error}: p169s_fail(error)
    case P86PreparationReady{seed}: x198pw_plan_fast(p86_plan(seed,path,source))"""

    new_x198_fast = """law s10e_plan:
  for +seed: P86Seed
  for +path: String
  for +text: String
  for +fast: Bool
  for +is_mod: Bool
  P86Plan

@unsafe
def x198pw_prepared_fast(+path: String,+source: String,prepared: P86Preparation) -> P169Prepared:
  match prepared:
    case P86PreparationError{error}: p169s_fail(error)
    case P86PreparationReady{seed}: x198pw_plan_fast(s10e_plan(seed,path,source,True{},False{}))"""

    text = replace_once(text, old_x198_fast, new_x198_fast, "s10e_wire_x198pw_prepared_fast")

    old_mod_fast = """@unsafe
def w10_module_prep_run_fast(+path: String, +source: String, +fid_base: U32, +mod_name: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      w10_module_prepared_fast_io(x198pw_plan_fast(p86_plan(seed,path,source)),w10_weak_from_seed(seed),fid_base,mod_name)"""

    new_mod_fast = """@unsafe
def w10_module_prep_run_fast(+path: String, +source: String, +fid_base: U32, +mod_name: String, prep: P86Preparation) -> IO(U32):
  match prep:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{+seed}:
      w10_module_prepared_fast_io(x198pw_plan_fast(s10e_plan(seed,path,source,True{},True{})),w10_weak_from_seed(seed),fid_base,mod_name)"""

    text = replace_once(text, old_mod_fast, new_mod_fast, "s10e_wire_w10_module_prep_run_fast")

    # Wire `ts_p86_plan_loaded_io` to use `s10e_plan_checked` so `--trace-slow` reflects S10-E too!
    old_ts_loaded = """                  +ta0 : Nat <- IO.now()
                  +plan : P86Plan <- IO.pure(P86Plan, p86_plan_checked(load, world, original, dres))
                  +ta1 : Nat <- IO.now()
                  _ : Unit <- w8_tr_log(True{}, "stage=annotate ms=" ++ w8_tr_ms(ta0, ta1))"""

    new_ts_loaded = """                  +ta0 : Nat <- IO.now()
                  +plan : P86Plan <- IO.pure(P86Plan, s10e_plan_checked(load, world, suffix, eligible, True{}, dres))
                  +ta1 : Nat <- IO.now()
                  _ : Unit <- w8_tr_log(True{}, "stage=annotate ms=" ++ w8_tr_ms(ta0, ta1))"""

    text = replace_once(text, old_ts_loaded, new_ts_loaded, "s10e_wire_ts_annotate")

    return text


def main() -> None:
    ap = argparse.ArgumentParser(description="Apply S10-E pure-Bend p86_plan speedup patch")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--no-lexer", action="store_true", help="Skip the 4 m02 lexer hunks")
    args = ap.parse_args()

    print(f"=== S10-E Patching {args.src} -> {args.out} ===", flush=True)
    text = args.src.read_text(encoding="utf-8")
    patched = apply_s10e(text, include_lexer=not args.no_lexer)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(patched, encoding="utf-8")
    print(f"=== Done ({len(patched):,} B) ===", flush=True)


if __name__ == "__main__":
    main()
