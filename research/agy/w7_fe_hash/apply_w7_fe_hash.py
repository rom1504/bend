#!/usr/bin/env python3
"""Wave 7 Frontend Optimization Pass (w7_fe_hash):
  1. O(1) BookCache constructor hash-trie (eliminates O(N^2) constructor_exists).
  2. O(1) f_decl_ctor_taken via scope.ctorIndex (eliminates O(N^2) f_ctor_lookup).
  3. 1-step constructor + first-char `switch` dispatch for hottest frontend loops:
     check_node, infer_node, ffw_walk_existing, f_reserved, f_pattern_sub,
     f_context_higher/lower/material_children.
  4. Zero-closure lexer & inner-loop helpers: p150l_cursor/newline/comment/word_done/quote,
     ctx_get, f_rename_var, tele_check_static, f_grow_base/existing.
  5. Automatic zero-closure f_choose / kc / nt_choose -> Bool-helper `def` lowering
     across @unsafe frontend/core/checker defs.

Usage:
  python3 -B research/agy/w7_fe_hash/apply_w7_fe_hash.py --src <in.bend> --dst <out.bend>
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

CHOOSE_NAMES = ("f_choose", "kc", "nt_choose")
LAMBDA_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=>\s*(.*)$", re.S)


def split_top_level_args(s: str) -> list[str] | None:
    args: list[str] = []
    depth = 0
    i = 0
    n = len(s)
    start = 0
    while i < n:
        c = s[i]
        if c == '"' or c == "'":
            q = c
            i += 1
            while i < n:
                if s[i] == "\\":
                    i += 2
                    continue
                if s[i] == q:
                    i += 1
                    break
                i += 1
            continue
        if c in "([{":
            depth += 1
        elif c in ")]}":
            depth -= 1
            if depth < 0:
                return None
        elif c == "," and depth == 0:
            args.append(s[start:i].strip())
            start = i + 1
        i += 1
    if depth != 0:
        return None
    tail = s[start:].strip()
    if tail:
        args.append(tail)
    return args


def split_param_list(s: str) -> list[str] | None:
    args: list[str] = []
    depth = 0
    angle = 0
    i = 0
    n = len(s)
    start = 0
    while i < n:
        c = s[i]
        if c in "([{":
            depth += 1
        elif c in ")]}":
            depth -= 1
            if depth < 0:
                return None
        elif c == "<":
            angle += 1
        elif c == ">":
            if angle > 0:
                angle -= 1
        elif c == "," and depth == 0 and angle == 0:
            args.append(s[start:i].strip())
            start = i + 1
        i += 1
    if depth != 0 or angle != 0:
        return None
    tail = s[start:].strip()
    if tail:
        args.append(tail)
    return args


def strip_literals(s: str) -> str:
    out = []
    i = 0
    n = len(s)
    while i < n:
        c = s[i]
        if c == '"' or c == "'":
            q = c
            out.append(" ")
            i += 1
            while i < n:
                if s[i] == "\\":
                    i += 2
                    continue
                if s[i] == q:
                    i += 1
                    break
                i += 1
            continue
        out.append(c)
        i += 1
    return "".join(out)


def strip_unused_lambda(fn_str: str) -> str | None:
    s = fn_str.strip()
    m = LAMBDA_RE.match(s)
    if not m:
        return None
    param, body = m.group(1), m.group(2).strip()
    if not body:
        return None
    body_no_str = strip_literals(body)
    if re.search(rf"\b{re.escape(param)}\b(?!\s*=>)", body_no_str):
        return None
    return body


def parse_choose_call(expr: str) -> tuple[str, str, str] | None:
    s = expr.strip()
    matched_name = None
    for name in CHOOSE_NAMES:
        if s.startswith(name + "("):
            matched_name = name
            break
    if matched_name is None:
        return None

    open_idx = len(matched_name)
    depth = 0
    i = open_idx
    n = len(s)
    close_idx = -1
    while i < n:
        c = s[i]
        if c == '"' or c == "'":
            q = c
            i += 1
            while i < n:
                if s[i] == "\\":
                    i += 2
                    continue
                if s[i] == q:
                    i += 1
                    break
                i += 1
            continue
        if c in "([{":
            depth += 1
        elif c in ")]}":
            depth -= 1
            if depth == 0:
                close_idx = i
                break
        i += 1
    if close_idx != n - 1:
        return None

    inner = s[open_idx + 1 : close_idx]
    args = split_top_level_args(inner)
    if args is None or len(args) != 4:
        return None

    _ty, cond, yes_fn, no_fn = args
    yes_body = strip_unused_lambda(yes_fn)
    no_body = strip_unused_lambda(no_fn)
    if yes_body is None or no_body is None:
        return None
    cond_clean = " ".join(cond.split())
    return cond_clean, yes_body, no_body


def paren_balance(s: str) -> int:
    bal = 0
    i = 0
    n = len(s)
    while i < n:
        c = s[i]
        if c == '"' or c == "'":
            q = c
            i += 1
            while i < n:
                if s[i] == "\\":
                    i += 2
                    continue
                if s[i] == q:
                    i += 1
                    break
                i += 1
            continue
        if c in "([{":
            bal += 1
        elif c in ")]}":
            bal -= 1
        i += 1
    return bal


# ---------------------------------------------------------------------------
# Helpers injected into compiler.bend
# ---------------------------------------------------------------------------

CTOR_HELPERS = """
@unsafe
def w7_char0(+s: String) -> U32:
  match s:
    case SNil{}:
      0
    case SCon{c, _}:
      Char.to_u32(c)

@unsafe
def w7_ctor_index_add(+ctors: List<&2, KDef>, +tree: KDef) -> KDef:
  match ctors:
    case Nil{}:
      tree
    case Con{c, rest}:
      w7_ctor_index_add(rest, p131i_insert(tree, c, index_hash(dn(c), 2166136261)))

@unsafe
def w7_ctor_index_build_step(isAdt: Bool, +h: KDef, +rest: List<&2, KDef>) -> KDef:
  match isAdt:
    case True{}:
      w7_ctor_index_add(dc(h), w7_ctor_index_build(rest))
    case False{}:
      w7_ctor_index_build(rest)

@unsafe
def w7_ctor_index_build(+book: List<&2, KDef>) -> KDef:
  match book:
    case Nil{}:
      missing()
    case Con{h, rest}:
      w7_ctor_index_build_step(p88_string_eq(dk(h), "ADT"), h, rest)

@unsafe
def w7_ctor_tree_tail(+tail: List<&2, KDef>) -> KDef:
  match tail:
    case Nil{}:
      missing()
    case Con{ctors, _}:
      ctors

@unsafe
def w7_ctor_tree_list(+ds: List<&2, KDef>) -> KDef:
  match ds:
    case Nil{}:
      missing()
    case Con{idx, tail}:
      w7_ctor_tree_tail(tail)

@unsafe
def w7_ctor_tree_of(+cache: KDef) -> KDef:
  w7_ctor_tree_list(dc(cache))

@unsafe
def w7_book_put_ctors_step(isAdt: Bool, +cache: KDef, +d: KDef) -> KDef:
  match isAdt:
    case True{}:
      w7_ctor_index_add(dc(d), w7_ctor_tree_of(cache))
    case False{}:
      w7_ctor_tree_of(cache)

@unsafe
def w7_book_put_ctors(+cache: KDef, +d: KDef) -> KDef:
  w7_book_put_ctors_step(p88_string_eq(dk(d), "ADT"), cache, d)

@unsafe
def w7_book_put_step(isCache: Bool, +h: KDef, +rest: List<&2, KDef>, +book: List<&2, KDef>, +d: KDef) -> List<&2, KDef>:
  match isCache:
    case True{}:
      Con{KDef{dn(h), dk(h), da(h), 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{index_set(index_first(dc(h)), d, index_hash(dn(d), 2166136261), 32), Con{w7_book_put_ctors(h, d), Nil{}}}, True{}, False{}}, Con{d, index_put_rest(h, rest, dn(d))}}
    case False{}:
      Con{d, index_remove(book, dn(d))}

@unsafe
def w7_ctor_exists_hit(isAbs: Bool, +rest: List<&2, KDef>, +name: String) -> Bool:
  match isAbs:
    case True{}:
      w7_ctor_exists_linear(rest, name)
    case False{}:
      True{}

@unsafe
def w7_ctor_exists_adt(isAdt: Bool, +h: KDef, +rest: List<&2, KDef>, +name: String) -> Bool:
  match isAdt:
    case True{}:
      w7_ctor_exists_hit(p88_string_eq(dk(lookup(dc(h), name)), "Absent"), rest, name)
    case False{}:
      w7_ctor_exists_linear(rest, name)

@unsafe
def w7_ctor_exists_linear(+ds: List<&2, KDef>, +name: String) -> Bool:
  match ds:
    case Nil{}:
      False{}
    case Con{h, rest}:
      w7_ctor_exists_adt(p88_string_eq(dk(h), "ADT"), h, rest, name)

@unsafe
def w7_ctor_exists_tail(+tail: List<&2, KDef>, +rest: List<&2, KDef>, +name: String) -> Bool:
  match tail:
    case Nil{}:
      w7_ctor_exists_linear(rest, name)
    case Con{ctors, _}:
      Bool.not(p88_string_eq(dk(index_find(ctors, name, index_hash(name, 2166136261), 32)), "Absent"))

@unsafe
def w7_ctor_exists_cache_dc(+dc_list: List<&2, KDef>, +rest: List<&2, KDef>, +name: String) -> Bool:
  match dc_list:
    case Nil{}:
      w7_ctor_exists_linear(rest, name)
    case Con{idx, tail}:
      w7_ctor_exists_tail(tail, rest, name)

@unsafe
def w7_ctor_exists_head(isCache: Bool, +h: KDef, +rest: List<&2, KDef>, +ds: List<&2, KDef>, +name: String) -> Bool:
  match isCache:
    case True{}:
      w7_ctor_exists_cache_dc(dc(h), rest, name)
    case False{}:
      w7_ctor_exists_linear(ds, name)
"""

FAST_CHECK_INFER = """
@unsafe
def w7_ctx_get_hit(hit: Bool, +h: KTerm, +t: List<&2, KTerm>, +id: U32) -> KTerm:
  match hit:
    case True{}:
      h
    case False{}:
      ctx_get(t, id)
"""

FAST_INFER_NODE = """
@unsafe
def w7_if_infer_var(ok_t: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32) -> KChecking:
  match ok_t:
    case True{}:
      infer_var(e, ctx, t, dem)
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_if_infer_ref(ok_t: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +sp: List<&2, KTerm>) -> KChecking:
  match ok_t:
    case True{}:
      infer_ref(e, ctx, t, dem, sp, lookup(cb(e), nm(t)))
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_if_infer_ann(ok_t: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32) -> KChecking:
  match ok_t:
    case True{}:
      ki_ann(e, ctx, t, dem, check(e, ctx, kid(t, 1), 0, typ(1)))
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_if_infer_all(ok_t: Bool, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32) -> KChecking:
  match ok_t:
    case True{}:
      ki_all(e, ctx, t, dg_kind_check(e, ctx, kid(t, 0), qt(t), nm(t)))
    case False{}:
      w7_if_infer_ann(p88_string_eq(tag, "Ann"), e, ctx, t, dem)

@unsafe
def w7_if_infer_adt(ok_t: Bool, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32) -> KChecking:
  match ok_t:
    case True{}:
      infer_adt(e, ctx, t, dem, lookup(cb(e), nm(t)))
    case False{}:
      w7_if_infer_all(p88_string_eq(tag, "All"), tag, e, ctx, t, dem)

@unsafe
def w7_if_infer_app(ok_t: Bool, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +sp: List<&2, KTerm>) -> KChecking:
  match ok_t:
    case True{}:
      infer_app(e, ctx, t, dem, infer(e, ctx, kid(t, 0), dem, Con{kid(t, 1), sp}))
    case False{}:
      w7_if_infer_adt(p88_string_eq(tag, "ADT"), tag, e, ctx, t, dem)

@unsafe
def w7_if_infer_typ(ok_t: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KChecking:
  match ok_t:
    case True{}:
      ki_one(t, typ(1), check(e, ctx, kid(t, 0), 0, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_if_infer_qua(ok_t: Bool, +e: KEnv, +t: KTerm) -> KChecking:
  match ok_t:
    case True{}:
      ok(cw(e), t, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{})
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_if_infer_qnt(ok_t: Bool, +tag: String, +e: KEnv, +t: KTerm) -> KChecking:
  match ok_t:
    case True{}:
      ok(cw(e), t, typ(1), Nil{})
    case False{}:
      w7_if_infer_qua(p88_string_eq(tag, "Qua"), e, t)

@unsafe
def w7_if_infer_min(ok_t: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32) -> KChecking:
  match ok_t:
    case True{}:
      ki_min(e, ctx, t, dem, check(e, ctx, kid(t, 0), dem, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}))
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_if_infer_eql(ok_t: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm) -> KChecking:
  match ok_t:
    case True{}:
      ki_eql_type(e, ctx, t, check(e, ctx, kid(t, 2), 0, typ(1)))
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_if_infer_unb(ok_t: Bool, +e: KEnv) -> KChecking:
  match ok_t:
    case True{}:
      bad(cw(e), "unbound variable")
    case False{}:
      bad(cw(e), "cannot infer: annotation required")

@unsafe
def w7_infer_tag(c0: U32, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +sp: List<&2, KTerm>) -> KChecking:
  match c0:
    case 86:
      w7_if_infer_var(p88_string_eq(tag, "Var"), e, ctx, t, dem)
    case 65:
      w7_if_infer_app(p88_string_eq(tag, "App"), tag, e, ctx, t, dem, sp)
    case 82:
      w7_if_infer_ref(p88_string_eq(tag, "Ref"), e, ctx, t, dem, sp)
    case 84:
      w7_if_infer_typ(p88_string_eq(tag, "Typ"), e, ctx, t)
    case 81:
      w7_if_infer_qnt(p88_string_eq(tag, "Qnt"), tag, e, t)
    case 77:
      w7_if_infer_min(p88_string_eq(tag, "Min"), e, ctx, t, dem)
    case 69:
      w7_if_infer_eql(p88_string_eq(tag, "Eql"), e, ctx, t)
    case 70:
      w7_if_infer_unb(p88_string_eq(tag, "FUnboundVar"), e)
    case _:
      bad(cw(e), "cannot infer: annotation required")
"""

FAST_CHECK_NODE = """
@unsafe
def w7_check_lit(ok_lit: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match ok_lit:
    case True{}:
      ok(cw(e), t, ty, Nil{})
    case False{}:
      check(e, ctx, core_literal_step(t), dem, ty)

@unsafe
def w7_check_ctr_if(isCtr: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isCtr:
    case True{}:
      check_ctr(e, ctx, t, dem, wnf(cb(e), ty))
    case False{}:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)

@unsafe
def w7_check_mat_if(isMat: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isMat:
    case True{}:
      check_mat(e, ctx, t, dem, wnf(cb(e), ty))
    case False{}:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)

@unsafe
def w7_check_rwt_if(isRwt: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isRwt:
    case True{}:
      check_rwt(e, ctx, t, dem, ty, infer(e, ctx, kid(t, 0), dem, Nil{}))
    case False{}:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)

@unsafe
def w7_check_rfl_if(isRfl: Bool, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isRfl:
    case True{}:
      check_rfl_graph(e, t, ty)
    case False{}:
      w7_check_rwt_if(p88_string_eq(tag, "Rwt"), e, ctx, t, dem, ty)

@unsafe
def w7_check_ref_if(isRef: Bool, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isRef:
    case True{}:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)
    case False{}:
      w7_check_rfl_if(p88_string_eq(tag, "Rfl"), tag, e, ctx, t, dem, ty)

@unsafe
def w7_check_hol_todo(isTodo: Bool, +e: KEnv, +t: KTerm, +ty: KTerm) -> KChecking:
  match isTodo:
    case True{}:
      ok(cw(e), t, ty, Nil{})
    case False{}:
      bad(cw(e), "unresolved hole")

@unsafe
def w7_check_hol_if(isHol: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isHol:
    case True{}:
      w7_check_hol_todo(p88_string_eq(nm(t), "TODO"), e, t, ty)
    case False{}:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)

@unsafe
def w7_check_lam_if(isLam: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isLam:
    case True{}:
      check_lam(e, ctx, t, dem, wnf(cb(e), ty))
    case False{}:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)

@unsafe
def w7_check_let_if(isLet: Bool, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match isLet:
    case True{}:
      check_let(e, ctx, ctx, ks(t), dem, ty, Nil{}, Nil{}, t, Nil{})
    case False{}:
      w7_check_lam_if(p88_string_eq(tag, "Lam"), e, ctx, t, dem, ty)

@unsafe
def w7_check_tag(c0: U32, +tag: String, +e: KEnv, +ctx: List<&2, KTerm>, +t: KTerm, +dem: U32, +ty: KTerm) -> KChecking:
  match c0:
    case 67:
      w7_check_ctr_if(p88_string_eq(tag, "Ctr"), e, ctx, t, dem, ty)
    case 77:
      w7_check_mat_if(p88_string_eq(tag, "Mat"), e, ctx, t, dem, ty)
    case 69:
      w7_check_mat_if(p88_string_eq(tag, "Efq"), e, ctx, t, dem, ty)
    case 82:
      w7_check_ref_if(p88_string_eq(tag, "Ref"), tag, e, ctx, t, dem, ty)
    case 72:
      w7_check_hol_if(p88_string_eq(tag, "Hol"), e, ctx, t, dem, ty)
    case 76:
      w7_check_let_if(p88_string_eq(tag, "Let"), tag, e, ctx, t, dem, ty)
    case _:
      check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)
"""

FAST_LEXER = """
@unsafe
def w7_lex_eof(isZero: Bool, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isZero:
    case True{}:
      List.reverse(&2, FToken, acc)
    case False{}:
      List.reverse(&2, FToken, Con{FToken{"<eof>", 0, 0, 0, offset, offset, previous}, acc})

@unsafe
def w7_lex_ident(isId: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isId:
    case True{}:
      p150l_word_done(p150l_word(rest, SCon{head, ""}, 1, head), l, c, d, acc, offset, previous)
    case False{}:
      p150l_other(head, rest, l, c, d, acc, offset, previous)

@unsafe
def w7_lex_quote(isQ: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isQ:
    case True{}:
      p150l_quoted(p150l_quote(rest, head, SCon{head, ""}, 1, 1, l, U32.add(c, 1)), l, c, d, acc, offset, previous)
    case False{}:
      w7_lex_ident(f_ident(head) && Bool.not(Char.is_eq(head, '.')), head, rest, l, c, d, acc, offset, previous)

@unsafe
def w7_lex_comment(isHash: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32, +code: U32) -> List<&2, FToken>:
  match isHash:
    case True{}:
      p150l_comment(rest, l, c, d, acc, f_cursor_add(offset, 1), previous)
    case False{}:
      w7_lex_quote(U32.is_eq(code, 34) || U32.is_eq(code, 39), head, rest, l, c, d, acc, offset, previous)

@unsafe
def w7_lex_space(isSp: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32, +code: U32) -> List<&2, FToken>:
  match isSp:
    case True{}:
      p150l_cursor(rest, l, U32.add(c, 1), d, acc, f_cursor_add(offset, dg_units(head)), previous)
    case False{}:
      w7_lex_comment(U32.is_eq(code, 35), head, rest, l, c, d, acc, offset, previous, code)

@unsafe
def w7_lex_nl(isNl: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32, +code: U32) -> List<&2, FToken>:
  match isNl:
    case True{}:
      p150l_newline(rest, l, c, d, acc, offset, previous)
    case False{}:
      w7_lex_space(f_ascii_space_code(code), head, rest, l, c, d, acc, offset, previous, code)

@unsafe
def w7_lex_nl_emit(isZero: Bool, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isZero:
    case True{}:
      p150l_cursor(rest, U32.add(l, 1), 0, d, Con{FToken{"\n", l, c, 0, offset, f_cursor_add(offset, 1), previous}, acc}, f_cursor_add(offset, 1), previous)
    case False{}:
      p150l_cursor(rest, U32.add(l, 1), 0, d, acc, f_cursor_add(offset, 1), previous)

@unsafe
def w7_lex_cmt_nl(isNl: Bool, +head: Char, +rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isNl:
    case True{}:
      p150l_newline(rest, l, c, d, acc, offset, previous)
    case False{}:
      p150l_comment(rest, l, c, d, acc, f_cursor_add(offset, dg_units(head)), previous)

@unsafe
def w7_lex_word_ok(isZero: Bool, +word: String, +rest: String, +size: U32, +l: U32, +c: U32, +d: U32, +acc: List<&2, FToken>, +offset: U32, +previous: U32) -> List<&2, FToken>:
  match isZero:
    case True{}:
      p150l_unterminated(l, c, acc, offset, previous)
    case False{}:
      p150l_word_end(word, rest, l, c, d, acc, offset, previous, size, f_cursor_add(offset, size))

@unsafe
def w7_lex_q_eq(isEq: Bool, +head: Char, +rest: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match isEq:
    case True{}:
      P150LQuoted{String.reverse(SCon{head, acc}), rest, U32.add(n, 1), U32.add(width, 1), l, U32.add(c, 1)}
    case False{}:
      p150l_quote(rest, quote, SCon{head, acc}, U32.add(n, 1), U32.add(width, dg_units(head)), l, U32.add(c, 1))

@unsafe
def w7_lex_q_nl(isNl: Bool, +head: Char, +rest: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match isNl:
    case True{}:
      p150l_quote(rest, quote, SCon{head, acc}, U32.add(n, 1), U32.add(width, 1), U32.add(l, 1), 0)
    case False{}:
      w7_lex_q_eq(Char.is_eq(head, quote), head, rest, quote, acc, n, width, l, c)

@unsafe
def w7_lex_q_esc(isEsc: Bool, +head: Char, +rest: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:
  match isEsc:
    case True{}:
      p150l_escape(rest, quote, acc, n, width, l, c)
    case False{}:
      w7_lex_q_nl(f_ascii_char_eq(head, '\n'), head, rest, quote, acc, n, width, l, c)
"""

FAST_PATTERN_SUB = """
@unsafe
def w7_pat_sub_var(hit: Bool, +t: KTerm, +kids: List<&2, KTerm>, +id: U32, +value: KTerm) -> KTerm:
  match hit:
    case True{}:
      f_pattern_value(value, kb(t), ke(t))
    case False{}:
      match kids:
        case Nil{}:
          t
        case Con{_, _}:
          k_with_children(t, f_pattern_subs(kids, id, value))
"""

FAST_MAT = """
@unsafe
def w7_mat_done_app(isLam: Bool, +term: KTerm) -> KTerm:
  match isLam:
    case True{}:
      f_context_higher(f_scope_app_span(kid(term, 0), kid(term, 1), kb(term), ke(term)))
    case False{}:
      term

@unsafe
def w7_mat_done_chk(isApp: Bool, +term: KTerm) -> KTerm:
  match isApp:
    case True{}:
      w7_mat_done_app(f_eq(tg(kid(term, 0)), "Lam"), term)
    case False{}:
      term

@unsafe
def w7_mat_child_eval(lower: Bool, deferred: Bool, +head: KTerm) -> KTerm:
  match lower:
    case True{}:
      match deferred:
        case True{}:
          f_context_lower(f_context_higher(head))
        case False{}:
          f_context_lower(head)
    case False{}:
      f_context_higher(head)

@unsafe
def w7_mat_child_step(skipDef: Bool, +term: KTerm, +head: KTerm, +rest: List<&2, KTerm>, +built: List<&2, KTerm>, +lower: Bool, +deferred: Bool) -> KTerm:
  match skipDef:
    case True{}:
      f_context_material_children(term, rest, Con{head, built}, lower)
    case False{}:
      f_context_material_next(term, rest, built, lower, w7_mat_child_eval(lower, deferred, head))

@unsafe
def w7_mat_nil(+term: KTerm, +built: List<&2, KTerm>, lower: Bool) -> KTerm:
  match built:
    case Nil{}:
      f_context_material_done(term, lower)
    case Con{_, _}:
      f_context_material_done(k_with_children(term, List.reverse(&2, KTerm, built)), lower)

@unsafe
def w7_mat_hi_kids(+term: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match kids:
    case Nil{}:
      term
    case Con{_, _}:
      f_context_material_children(term, kids, Nil{}, False{})

@unsafe
def w7_mat_hi_op(isOp: Bool, +term: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match isOp:
    case True{}:
      f_operator_error(term)
    case False{}:
      w7_mat_hi_kids(term, kids)

@unsafe
def w7_mat_hi_stop(isStop: Bool, +term: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match isStop:
    case True{}:
      term
    case False{}:
      w7_mat_hi_kids(term, kids)

@unsafe
def w7_mat_hi_fname(isFn: Bool, +term: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match isFn:
    case True{}:
      f_context_higher(k_with_span(kid(term, 1), kb(term), ke(term)))
    case False{}:
      w7_mat_hi_kids(term, kids)

@unsafe
def w7_mat_hi_tag(c0: U32, +tag: String, +term: KTerm, +kids: List<&2, KTerm>) -> KTerm:
  match c0:
    case 69:
      w7_mat_hi_stop(f_context_stop(term), term, kids)
    case 70:
      w7_mat_hi_fname(f_eq(tag, "FName"), term, kids)
    case 82:
      w7_mat_hi_op(f_eq(tag, "Ref") && f_implicit_operator(nm(term)), term, kids)
    case _:
      w7_mat_hi_kids(term, kids)
"""

FAST_FFW = """
@unsafe
def w7_ffw_var(isVar: Bool, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match isVar:
    case True{}:
      ffw_done(f_rename_var(term, env), next, stack)
    case False{}:
      ffw_kids(term, env, ks(term), Nil{}, next, stack)

@unsafe
def w7_ffw_all(isAll: Bool, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match isAll:
    case True{}:
      ffw_walk(kid(term, 0), env, U32.add(next, 1), Con{FFAllA{term, env, next}, stack})
    case False{}:
      ffw_kids(term, env, ks(term), Nil{}, next, stack)

@unsafe
def w7_ffw_lam(isLam: Bool, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match isLam:
    case True{}:
      ffw_walk(kid(term, 0), Con{kt("Map", "", ix(term), 0, [var(nm(term), next)]), env}, U32.add(next, 1), Con{FFLambda{term, next}, stack})
    case False{}:
      ffw_kids(term, env, ks(term), Nil{}, next, stack)

@unsafe
def w7_ffw_let(isLet: Bool, +tag: String, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match isLet:
    case True{}:
      ffw_let(env, env, ks(term), Nil{}, next, Con{FFOrigin{kb(term), ke(term)}, stack})
    case False{}:
      w7_ffw_lam(p88_string_eq(tag, "Lam"), term, env, next, stack)

@unsafe
def w7_ffw_funb(isUnb: Bool, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match isUnb:
    case True{}:
      ffw_done(term, next, stack)
    case False{}:
      ffw_kids(term, env, ks(term), Nil{}, next, stack)

@unsafe
def w7_ffw_fglob(isGlob: Bool, +tag: String, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match isGlob:
    case True{}:
      ffw_done(kt_span("Ref", nm(term), 0, 1, Nil{}, kb(term), ke(term)), next, stack)
    case False{}:
      w7_ffw_funb(p88_string_eq(tag, "FUnboundVar"), term, env, next, stack)

@unsafe
def w7_ffw_tag(c0: U32, +tag: String, +term: KTerm, +env: List<&2, KTerm>, +next: U32, +stack: List<&2, FFFrame>) -> FFresh:
  match c0:
    case 86:
      w7_ffw_var(p88_string_eq(tag, "Var"), term, env, next, stack)
    case 65:
      w7_ffw_all(p88_string_eq(tag, "All"), term, env, next, stack)
    case 76:
      w7_ffw_let(p88_string_eq(tag, "Let"), tag, term, env, next, stack)
    case 70:
      w7_ffw_fglob(p88_string_eq(tag, "FGlobal"), tag, term, env, next, stack)
    case _:
      ffw_kids(term, env, ks(term), Nil{}, next, stack)

@unsafe
def w7_rename_ref(isRef: Bool, +t: KTerm, +m: KTerm) -> KTerm:
  match isRef:
    case True{}:
      k_with_span(kid(m, 0), kb(t), ke(t))
    case False{}:
      kt_span("Var", nm(t), ix(kid(m, 0)), qt(t), Nil{}, kb(t), ke(t))

@unsafe
def w7_rename_hit(hit: Bool, +t: KTerm, +m: KTerm, +ms: List<&2, KTerm>) -> KTerm:
  match hit:
    case True{}:
      w7_rename_ref(p98_tag_eq(kid(m, 0), "Ref"), t, m)
    case False{}:
      f_rename_var(t, ms)
"""

FAST_RESERVED = """
@unsafe
def w7_reserved_c(c0: U32, +s: String) -> Bool:
  match c0:
    case 100:
      f_eq(s, "def") || f_eq(s, "do")
    case 116:
      f_eq(s, "type")
    case 108:
      f_eq(s, "law")
    case 109:
      f_eq(s, "match")
    case 99:
      f_eq(s, "case")
    case 114:
      f_eq(s, "return")
    case 102:
      f_eq(s, "for")
    case 101:
      f_eq(s, "exs")
    case 119:
      f_eq(s, "where")
    case 105:
      f_eq(s, "is") || f_eq(s, "import")
    case 84:
      f_eq(s, "Type")
    case 68:
      f_eq(s, "Data")
    case 75:
      f_eq(s, "Kind")
    case 81:
      f_eq(s, "Quant")
    case _:
      False{}
"""

FAST_PARSER_HOT = """
@unsafe
def w7_tele_static_all(isAll: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2, KTerm>, +args: List<&2, KTerm>, +dem: U32) -> KChecking:
  match isAll:
    case True{}:
      ki_tele_static(e, ctx, tel, rest, dem, check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0)))
    case False{}:
      tele_check(e, ctx, tel, args, dem)

@unsafe
def w7_atom_ret_err(isRet: Bool, +ts: FInput) -> FParsed:
  match isRet:
    case True{}:
      fpe_word(ts, "return outside do", "a do-block heading this return")
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_ident_ok(isId: Bool, +ts: FInput) -> FParsed:
  match isId:
    case True{}:
      f_atom_name(ts)
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_word_res(isRes: Bool, +word: String, +ts: FInput) -> FParsed:
  match isRes:
    case True{}:
      w7_atom_ret_err(f_eq(word, "return"), ts)
    case False{}:
      w7_atom_ident_ok(f_ascii_alpha(f_head(word)) || f_ascii_digit(f_head(word)) || Char.is_eq(f_head(word), '_'), ts)

@unsafe
def w7_atom_is_type(isT: Bool, +ts: FInput) -> FParsed:
  match isT:
    case True{}:
      FParsed{kt("Typ", "", 0, 0, [kt("Qua", "", 0, 1, Nil{})]), f_tl(ts)}
    case False{}:
      f_atom_name(ts)

@unsafe
def w7_atom_is_data(isD: Bool, +ts: FInput) -> FParsed:
  match isD:
    case True{}:
      FParsed{kt("Typ", "", 0, 0, [kt("Qua", "", 0, 2, Nil{})]), f_tl(ts)}
    case False{}:
      f_atom_name(ts)

@unsafe
def w7_atom_is_quant(isQ: Bool, +ts: FInput) -> FParsed:
  match isQ:
    case True{}:
      FParsed{kt("Qnt", "", 0, 0, Nil{}), f_tl(ts)}
    case False{}:
      f_atom_name(ts)

@unsafe
def w7_atom_is_kind(isK: Bool, +ts: FInput) -> FParsed:
  match isK:
    case True{}:
      f_kind_wrap(f_expect(f_expr(f_tl(f_tl(ts)), 0), ")"))
    case False{}:
      f_atom_name(ts)

@unsafe
def w7_atom_word_c0(c0: U32, +word: String, +ts: FInput) -> FParsed:
  match c0:
    case 84:
      w7_atom_is_type(f_eq(word, "Type"), ts)
    case 68:
      w7_atom_is_data(f_eq(word, "Data"), ts)
    case 81:
      w7_atom_is_quant(f_eq(word, "Quant"), ts)
    case 75:
      w7_atom_is_kind(f_eq(word, "Kind"), ts)
    case _:
      w7_atom_word_res(f_reserved(word), word, ts)

@unsafe
def w7_atom_bslash(isLbr: Bool, +ts: FInput) -> FParsed:
  match isLbr:
    case True{}:
      f_matcher(f_tl(f_tl(ts)))
    case False{}:
      fpe_error(f_tl(ts), "expected {", "'{'")

@unsafe
def w7_atom_plus1(isP: Bool, +ts: FInput) -> FParsed:
  match isP:
    case True{}:
      f_mark(f_expr(f_tl(ts), 12), 2)
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_plus(isPP: Bool, +word: String, +ts: FInput) -> FParsed:
  match isPP:
    case True{}:
      f_atom_base(f_prepend(FToken{"+", f_line(ts), f_col(ts), 0, f_begin(ts), f_cursor_add(f_begin(ts), 1), f_previous_end(ts)}, f_prepend(FToken{"+", f_line(ts), U32.add(f_col(ts), 1), 0, f_cursor_add(f_begin(ts), 1), f_end(ts), f_cursor_add(f_begin(ts), 1)}, f_tl(ts))))
    case False{}:
      w7_atom_plus1(f_eq(word, "+") || f_eq(word, "+bind"), ts)

@unsafe
def w7_atom_lp(ok: Bool, +ts: FInput) -> FParsed:
  match ok:
    case True{}:
      f_group(f_body(f_tl(ts)))
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_lb(ok: Bool, +ts: FInput) -> FParsed:
  match ok:
    case True{}:
      f_brace(f_tl(ts))
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_ls(ok: Bool, +ts: FInput) -> FParsed:
  match ok:
    case True{}:
      f_array(f_tl(ts))
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_at(ok: Bool, +ts: FInput) -> FParsed:
  match ok:
    case True{}:
      f_all(f_tl(ts), False{})
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_amp(ok: Bool, +ts: FInput) -> FParsed:
  match ok:
    case True{}:
      f_grade(f_tl(ts))
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_q(ok: Bool, +ts: FInput) -> FParsed:
  match ok:
    case True{}:
      FParsed{kt("Hol", f_tx(f_tl(ts)), 0, 0, Nil{}), f_tl(f_tl(ts))}
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_bslash_chk(isBs: Bool, +ts: FInput) -> FParsed:
  match isBs:
    case True{}:
      w7_atom_bslash(f_eq(f_tx(f_tl(ts)), "{"), ts)
    case False{}:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_punct_c0(c0: U32, +word: String, +ts: FInput) -> FParsed:
  match c0:
    case 40:
      w7_atom_lp(f_eq(word, "("), ts)
    case 123:
      w7_atom_lb(f_eq(word, "{"), ts)
    case 91:
      w7_atom_ls(f_eq(word, "["), ts)
    case 64:
      w7_atom_at(f_eq(word, "@"), ts)
    case 38:
      w7_atom_amp(f_eq(word, "&"), ts)
    case 43:
      w7_atom_plus(f_eq(word, "++"), word, ts)
    case 63:
      w7_atom_q(f_eq(word, "?"), ts)
    case 92:
      w7_atom_bslash_chk(f_eq(word, "\\\\"), ts)
    case _:
      fpe_error(ts, "expected term", "a term")

@unsafe
def w7_atom_kind(kind: U32, +word: String, +ts: FInput) -> FParsed:
  match kind:
    case 1:
      w7_atom_word_c0(w7_char0(word), word, ts)
    case 2:
      FParsed{kt("Literal", word, 0, 1, Nil{}), f_tl(ts)}
    case _:
      w7_atom_punct_c0(w7_char0(word), word, ts)

@unsafe
def w7_grow_base_err(isErr: Bool, +n: KTerm, +ts: FInput, +min: U32) -> FParsed:
  match isErr:
    case True{}:
      FParsed{n, ts}
    case False{}:
      p175p_grow_word(n, ts, min, f_tx(ts))

@unsafe
def w7_grow_ex_nl(isNl: Bool, +n: KTerm, +ts: FInput, +min: U32, +word: String) -> FParsed:
  match isNl:
    case True{}:
      p175p_grow_newline(n, ts, min, f_skip(ts))
    case False{}:
      p175p_grow_suffix(n, ts, min, word)

@unsafe
def w7_locate_end(spaced: Bool, +ts: FInput) -> U32:
  match spaced:
    case True{}:
      f_begin(f_space(ts))
    case False{}:
      f_previous_end(ts)

@unsafe
def w7_locate_keep(keep: Bool, +n: KTerm, +begin: U32, +end: U32, +created: Bool, +ts: FInput) -> FParsed:
  match keep:
    case True{}:
      FParsed{n, ts}
    case False{}:
      FParsed{f_located_term(n, begin, end, created), ts}
"""


def replace_exact(text: str, old: str, new: str, label: str) -> str:
    assert old in text, f"Target not found: {label}"
    return text.replace(old, new, 1)


def apply_structural_patches(text: str) -> str:
    # 1. BookCache constructor hash-trie + w7_char0
    text = replace_exact(
        text,
        '@unsafe\n'
        'def book_cached(\n'
        '  +book: List<&2, KDef>,\n'
        '  +bound: U32,\n'
        ') -> List<&2, KDef>:\n'
        '  Con{KDef{"$kernel.cache", "BookCache", bound, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{index_build(book), Nil{}}, True{}, False{}}, book}',
        CTOR_HELPERS.lstrip("\n") + "\n"
        '@unsafe\n'
        'def book_cached(\n'
        '  +book: List<&2, KDef>,\n'
        '  +bound: U32,\n'
        ') -> List<&2, KDef>:\n'
        '  Con{KDef{"$kernel.cache", "BookCache", bound, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{index_build(book), Con{w7_ctor_index_build(book), Nil{}}}, True{}, False{}}, book}',
        "book_cached",
    )

    text = replace_exact(
        text,
        '      kc(List<&2, KDef>, p88_string_eq(dk(h), "BookCache"), '
        'u => Con{KDef{dn(h), dk(h), da(h), 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Con{index_set(index_first(dc(h)), d, index_hash(dn(d), 2166136261), 32), Nil{}}, True{}, False{}}, Con{d, index_put_rest(h, rest, dn(d))}}, '
        'u => Con{d, index_remove(book, dn(d))})',
        '      w7_book_put_step(p88_string_eq(dk(h), "BookCache"), h, rest, book, d)',
        "book_put",
    )

    text = replace_exact(
        text,
        'def constructor_exists(\n'
        '  +ds: List<&2, KDef>,\n'
        '  +name: String,\n'
        ') -> Bool:\n'
        '  match ds:\n'
        '    case Nil{}:\n'
        '      False{}\n'
        '    case Con{h, rest}:\n'
        '      Bool.not(p88_string_eq(dk(h), "BookCache")) && Bool.not(p88_string_eq(dk(lookup(dc(h), name)), "Absent")) || constructor_exists(rest, name)',
        'def constructor_exists(\n'
        '  +ds: List<&2, KDef>,\n'
        '  +name: String,\n'
        ') -> Bool:\n'
        '  match ds:\n'
        '    case Nil{}:\n'
        '      False{}\n'
        '    case Con{h, rest}:\n'
        '      w7_ctor_exists_head(p88_string_eq(dk(h), "BookCache"), h, rest, ds, name)',
        "constructor_exists",
    )

    # 2. Fast ctx_get
    text = replace_exact(
        text,
        '@unsafe\n'
        'def ctx_get(\n'
        '  +ctx: List<&2, KTerm>,\n'
        '  +id: U32,\n'
        ') -> KTerm:\n'
        '  match ctx:\n'
        '    case Nil{}:\n'
        '      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}\n'
        '    case Con{h, t}:\n'
        '      kc(KTerm, U32.is_eq(ix(h), id), u => h, u => ctx_get(t, id))',
        FAST_CHECK_INFER.lstrip("\n") + "\n"
        '@unsafe\n'
        'def ctx_get(\n'
        '  +ctx: List<&2, KTerm>,\n'
        '  +id: U32,\n'
        ') -> KTerm:\n'
        '  match ctx:\n'
        '    case Nil{}:\n'
        '      {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}\n'
        '    case Con{h, t}:\n'
        '      w7_ctx_get_hit(U32.is_eq(ix(h), id), h, t, id)',
        "ctx_get",
    )

    # 3. 1-step infer_node
    text = replace_exact(
        text,
        '@unsafe\n'
        'def infer_node(e, ctx, t, dem, sp):\n'
        '  kc(KChecking, p98_tag_eq(t, "Var"), u => infer_var(e, ctx, t, dem),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "Ref"), u => infer_ref(e, ctx, t, dem, sp, lookup(cb(e), nm(t))),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "Typ"), u => ki_one(t, typ(1), check(e, ctx, kid(t, 0), 0, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "Qnt"), u => ok(cw(e), t, typ(1), Nil{}),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "Qua"), u => ok(cw(e), t, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "Min"), u => ki_min(e, ctx, t, dem, check(e, ctx, kid(t, 0), dem, {KTerm{"Qnt", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "All"), u => ki_all(e, ctx, t, dg_kind_check(e, ctx, kid(t, 0), qt(t), nm(t))),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "App"), u => infer_app(e, ctx, t, dem, infer(e, ctx, kid(t, 0), dem, Con{kid(t, 1), sp})),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "ADT"), u => infer_adt(e, ctx, t, dem, lookup(cb(e), nm(t))),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "Eql"), u => ki_eql_type(e, ctx, t, check(e, ctx, kid(t, 2), 0, typ(1))),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "Ann"), u => ki_ann(e, ctx, t, dem, check(e, ctx, kid(t, 1), 0, typ(1))),\n'
        '   u => kc(KChecking, core_literal(t), u => bad(cw(e), "cannot infer: annotation required"), u => bad(cw(e), kc(String, p98_tag_eq(t, "FUnboundVar"), u => "unbound variable", u => "cannot infer: annotation required"))))))))))))))',
        FAST_INFER_NODE.lstrip("\n") + "\n"
        '@unsafe\n'
        'def infer_node(e, ctx, t, dem, sp):\n'
        '  match t:\n'
        '    case KLiteral{_, _, _, _, _}:\n'
        '      bad(cw(e), "cannot infer: annotation required")\n'
        '    case KLambda{_, _, _, _, _, _, _, _}:\n'
        '      bad(cw(e), "cannot infer: annotation required")\n'
        '    case KTerm{tag, _, _, _, _, _, _, _}:\n'
        '      w7_infer_tag(w7_char0(tag), tag, e, ctx, t, dem, sp)',
        "infer_node",
    )

    # 4. 1-step check_node
    text = replace_exact(
        text,
        '@unsafe\n'
        'def check_node(e, ctx, t, dem, ty):\n'
        '  kc(KChecking, core_literal(t), u => kc(KChecking, core_literal_type(cb(e), t, wnf(cb(e), ty)), u => ok(cw(e), t, ty, Nil{}), u => check(e, ctx, core_literal_step(t), dem, ty)), u =>\n'
        '  kc(KChecking, p98_tag_eq(t, "Lam"), u => check_lam(e, ctx, t, dem, wnf(cb(e), ty)),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "Ctr"), u => check_ctr(e, ctx, t, dem, wnf(cb(e), ty)),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "Mat") || p98_tag_eq(t, "Efq"), u => check_mat(e, ctx, t, dem, wnf(cb(e), ty)),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "Rfl"), u => check_rfl_graph(e, t, ty),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "Hol"), u => kc(KChecking, p88_string_eq(nm(t), "TODO"), u => ok(cw(e), t, ty, Nil{}), u => bad(cw(e), "unresolved hole")),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "Let"), u => check_let(e, ctx, ctx, ks(t), dem, ty, Nil{}, Nil{}, t, Nil{}),\n'
        '   u => kc(KChecking, p98_tag_eq(t, "Rwt"), u => check_rwt(e, ctx, t, dem, ty, infer(e, ctx, kid(t, 0), dem, Nil{})),\n'
        '   u => check_fits(e, infer(e, ctx, t, dem, Nil{}), ty)))))))))',
        FAST_CHECK_NODE.lstrip("\n") + "\n"
        '@unsafe\n'
        'def check_node(e, ctx, t, dem, ty):\n'
        '  match t:\n'
        '    case KLiteral{_, _, _, _, _}:\n'
        '      w7_check_lit(core_literal_type(cb(e), t, wnf(cb(e), ty)), e, ctx, t, dem, ty)\n'
        '    case KLambda{_, _, _, _, _, _, _, _}:\n'
        '      check_lam(e, ctx, t, dem, wnf(cb(e), ty))\n'
        '    case KTerm{tag, _, _, _, _, _, _, _}:\n'
        '      w7_check_tag(w7_char0(tag), tag, e, ctx, t, dem, ty)',
        "check_node",
    )

    # 5. Zero-closure lexer (p150l_cursor, p150l_newline, p150l_comment, p150l_word_done, p150l_quote)
    text = replace_exact(
        text,
        '@unsafe\n'
        'def p150l_cursor(+s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:\n'
        '  match s:\n'
        '    case SNil{}:\n'
        '      List.reverse(&2,FToken,f_choose(List<&2,FToken>,U32.is_eq(offset,0),\n'
        '        u => acc,u => Con{FToken{"<eof>",0,0,0,offset,offset,previous},acc}))\n'
        '    case SCon{+head,+rest}:\n'
        '      +code = Char.to_u32(head)\n'
        '      f_choose(List<&2,FToken>,U32.is_eq(code,10),u => p150l_newline(rest,l,c,d,acc,offset,previous),\n'
        '      u => f_choose(List<&2,FToken>,f_ascii_space_code(code),\n'
        '        u => p150l_cursor(rest,l,U32.add(c,1),d,acc,f_cursor_add(offset,dg_units(head)),previous),\n'
        '      u => f_choose(List<&2,FToken>,U32.is_eq(code,35),u => p150l_comment(rest,l,c,d,acc,f_cursor_add(offset,1),previous),\n'
        '      u => f_choose(List<&2,FToken>,U32.is_eq(code,34) || U32.is_eq(code,39),\n'
        '        u => p150l_quoted(p150l_quote(rest,head,SCon{head,""},1,1,l,U32.add(c,1)),l,c,d,acc,offset,previous),\n'
        '        u => f_choose(List<&2,FToken>,f_ident(head) && Bool.not(Char.is_eq(head,\'.\')),\n'
        '          u => p150l_word_done(p150l_word(rest,SCon{head,""},1,head),l,c,d,acc,offset,previous),\n'
        '          u => p150l_other(head,rest,l,c,d,acc,offset,previous))))))',
        FAST_LEXER.lstrip("\n") + "\n"
        '@unsafe\n'
        'def p150l_cursor(+s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:\n'
        '  match s:\n'
        '    case SNil{}:\n'
        '      w7_lex_eof(U32.is_eq(offset, 0), acc, offset, previous)\n'
        '    case SCon{+head,+rest}:\n'
        '      +code = Char.to_u32(head)\n'
        '      w7_lex_nl(U32.is_eq(code, 10), head, rest, l, c, d, acc, offset, previous, code)',
        "p150l_cursor",
    )

    text = replace_exact(
        text,
        '@unsafe\n'
        'def p150l_newline(rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:\n'
        '  p150l_cursor(rest,U32.add(l,1),0,d,\n'
        '    f_choose(List<&2,FToken>,U32.is_eq(d,0),u => Con{FToken{"\\n",l,c,0,offset,f_cursor_add(offset,1),previous},acc},u => acc),\n'
        '    f_cursor_add(offset,1),previous)',
        '@unsafe\n'
        'def p150l_newline(rest: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:\n'
        '  w7_lex_nl_emit(U32.is_eq(d, 0), rest, l, c, d, acc, offset, previous)',
        "p150l_newline",
    )

    text = replace_exact(
        text,
        '@unsafe\n'
        'def p150l_comment(s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:\n'
        '  match s:\n'
        '    case SNil{}: p150l_cursor("",l,c,d,acc,offset,previous)\n'
        '    case SCon{+head,+rest}:\n'
        '      f_choose(List<&2,FToken>,f_ascii_char_eq(head,\'\\n\'),\n'
        '        u => p150l_newline(rest,l,c,d,acc,offset,previous),\n'
        '        u => p150l_comment(rest,l,c,d,acc,f_cursor_add(offset,dg_units(head)),previous))',
        '@unsafe\n'
        'def p150l_comment(s: String, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:\n'
        '  match s:\n'
        '    case SNil{}: p150l_cursor("",l,c,d,acc,offset,previous)\n'
        '    case SCon{+head,+rest}:\n'
        '      w7_lex_cmt_nl(f_ascii_char_eq(head, \'\\n\'), head, rest, l, c, d, acc, offset, previous)',
        "p150l_comment",
    )

    text = replace_exact(
        text,
        '@unsafe\n'
        'def p150l_word_done(sc: FScanned, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:\n'
        '  match sc:\n'
        '    case FScanned{word,rest,+size}:\n'
        '      f_choose(List<&2,FToken>,U32.is_eq(size,0),\n'
        '        u => p150l_unterminated(l,c,acc,offset,previous),\n'
        '        u => p150l_word_end(word,rest,l,c,d,acc,offset,previous,size,f_cursor_add(offset,size)))',
        '@unsafe\n'
        'def p150l_word_done(sc: FScanned, +l: U32, +c: U32, +d: U32, +acc: List<&2,FToken>, +offset: U32, +previous: U32) -> List<&2,FToken>:\n'
        '  match sc:\n'
        '    case FScanned{word,rest,+size}:\n'
        '      w7_lex_word_ok(U32.is_eq(size, 0), word, rest, size, l, c, d, acc, offset, previous)',
        "p150l_word_done",
    )

    text = replace_exact(
        text,
        '@unsafe\n'
        'def p150l_quote(s: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:\n'
        '  match s:\n'
        '    case SNil{}: P150LQuoted{"","",0,0,0,0}\n'
        '    case SCon{+head,+rest}:\n'
        '      f_choose(P150LQuoted,f_ascii_char_eq(head,\'\\\\\'),u => p150l_escape(rest,quote,acc,n,width,l,c),\n'
        '      u => f_choose(P150LQuoted,f_ascii_char_eq(head,\'\\n\'),\n'
        '        u => p150l_quote(rest,quote,SCon{head,acc},U32.add(n,1),U32.add(width,1),U32.add(l,1),0),\n'
        '      u => f_choose(P150LQuoted,Char.is_eq(head,quote),\n'
        '        u => P150LQuoted{String.reverse(SCon{head,acc}),rest,U32.add(n,1),U32.add(width,1),l,U32.add(c,1)},\n'
        '        u => p150l_quote(rest,quote,SCon{head,acc},U32.add(n,1),U32.add(width,dg_units(head)),l,U32.add(c,1)))))',
        '@unsafe\n'
        'def p150l_quote(s: String, +quote: Char, +acc: String, +n: U32, +width: U32, +l: U32, +c: U32) -> P150LQuoted:\n'
        '  match s:\n'
        '    case SNil{}: P150LQuoted{"","",0,0,0,0}\n'
        '    case SCon{+head,+rest}:\n'
        '      w7_lex_q_esc(f_ascii_char_eq(head, \'\\\\\'), head, rest, quote, acc, n, width, l, c)',
        "p150l_quote",
    )

    # 6. O(1) f_decl_ctor_taken
    text = replace_exact(
        text,
        'def f_decl_ctor_taken(+name: String, +book: List<&2,KDef>, +scope: FParseScope) -> Bool:\n'
        '  match scope:\n'
        '    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:\n'
        '      Bool.not(f_eq(dk(f_ctor_lookup(name, book)), "Missing")) || Bool.not(f_eq(dk(f_ctor_index_find(name, ctorIndex)), "Missing")) || Bool.not(f_eq(dk(f_ctor_index_find(f_qual_name(name, ns), ctorIndex)), "Missing"))',
        'def f_decl_ctor_taken(+name: String, +book: List<&2,KDef>, +scope: FParseScope) -> Bool:\n'
        '  match scope:\n'
        '    case FParseScope{prior, index, ctorIndex, ns, aliases, +p144p_view}:\n'
        '      Bool.not(f_eq(dk(f_ctor_index_find(name, ctorIndex)), "Missing")) || Bool.not(f_eq(dk(f_ctor_index_find(f_qual_name(name, ns), ctorIndex)), "Missing")) || Bool.not(f_eq(dk(f_ctor_index_find(f_alias(name, aliases), ctorIndex)), "Missing"))',
        "f_decl_ctor_taken",
    )

    # 7. Fast leaf-skipping f_pattern_sub
    text = replace_exact(
        text,
        '@unsafe\n'
        'def f_pattern_sub(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:\n'
        '  f_choose(KTerm, f_eq(tg(t), "Var") && U32.is_eq(ix(t), id),\n'
        '    u => f_pattern_value(value, kb(t), ke(t)),\n'
        '    u => k_with_children(t, f_pattern_subs(ks(t), id, value)))',
        FAST_PATTERN_SUB.lstrip("\n") + "\n"
        '@unsafe\n'
        'def f_pattern_sub(+t: KTerm, +id: U32, +value: KTerm) -> KTerm:\n'
        '  match t:\n'
        '    case KLiteral{_, _, _, _, _}:\n'
        '      t\n'
        '    case KLambda{name, lid, quant, kids, rem, ob, oe, pres}:\n'
        '      KLambda{name, lid, quant, f_pattern_subs(kids, id, value), rem, ob, oe, pres}\n'
        '    case KTerm{tag, name, tid, quant, kids, rem, ob, oe}:\n'
        '      w7_pat_sub_var(U32.is_eq(tid, id) && f_eq(tag, "Var"), t, kids, id, value)',
        "f_pattern_sub",
    )

    # 8. Fast leaf-skipping zero-closure f_context_higher / f_context_lower / f_context_material_children / done
    text = replace_exact(
        text,
        '@unsafe\n'
        'def f_context_higher(+term: KTerm) -> KTerm:\n'
        '  f_choose(KTerm, f_context_stop(term), u => term,\n'
        '    u => f_choose(KTerm, f_eq(tg(term), "FName"), u => f_context_higher(k_with_span(kid(term, 1), kb(term), ke(term))),\n'
        '      u => f_choose(KTerm, f_eq(tg(term), "Ref") && f_implicit_operator(nm(term)), u => f_operator_error(term),\n'
        '        u => f_context_material_children(term, ks(term), Nil{}, False{}))))\n'
        '\n'
        '# Module: src/front/literals_arrays.bend:241\n'
        '@unsafe\n'
        'def f_context_lower(+term: KTerm) -> KTerm:\n'
        '  f_choose(KTerm, f_context_stop(term), u => term, u => f_context_material_children(term, ks(term), Nil{}, True{}))\n'
        '\n'
        '# Module: src/front/literals_arrays.bend:245\n'
        '@unsafe\n'
        'def f_context_material_deferred(+term: KTerm, +rest: List<&2,KTerm>, +built: List<&2,KTerm>) -> Bool:\n'
        '  f_eq(tg(term), "Lam") || (f_eq(tg(term), "All") && Bool.not(List.is_empty(&2,KTerm,built))) || (f_eq(tg(term), "Let") && List.is_empty(&2,KTerm,rest))\n'
        '\n'
        '# Module: src/front/literals_arrays.bend:249\n'
        '@unsafe\n'
        'def f_context_material_children(+term: KTerm, +children: List<&2,KTerm>, +built: List<&2,KTerm>, +lower: Bool) -> KTerm:\n'
        '  match children:\n'
        '    case Nil{}: f_context_material_done(f_choose(KTerm, List.is_empty(&2,KTerm,built), u => term, u => k_with_children(term, List.reverse(&2,KTerm,built))), lower)\n'
        '    case Con{head, rest}:\n'
        '      +deferred = f_context_material_deferred(term, rest, built)\n'
        '      f_choose(KTerm, Bool.not(lower) && deferred,\n'
        '        u => f_context_material_children(term, rest, Con{head, built}, lower),\n'
        '        u => f_context_material_next(term, rest, built, lower,\n'
        '          f_choose(KTerm, lower,\n'
        '            u => f_context_lower(f_choose(KTerm, deferred, u => f_context_higher(head), u => head)),\n'
        '            u => f_context_higher(head))))\n'
        '\n'
        '# Module: src/front/literals_arrays.bend:262\n'
        '@unsafe\n'
        'def f_context_material_next(+term: KTerm, +rest: List<&2,KTerm>, +built: List<&2,KTerm>, +lower: Bool, +head: KTerm) -> KTerm:\n'
        '  f_choose(KTerm, f_context_stop(head), u => head, u => f_context_material_children(term, rest, Con{head, built}, lower))\n'
        '\n'
        '# Module: src/front/literals_arrays.bend:266\n'
        '@unsafe\n'
        'def f_context_material_done(+term: KTerm, +lower: Bool) -> KTerm:\n'
        '  f_choose(KTerm, Bool.not(lower) && f_eq(tg(term), "App"),\n'
        '    u => f_choose(KTerm, f_eq(tg(kid(term, 0)), "Lam"),\n'
        '      u => f_context_higher(f_scope_app_span(kid(term, 0), kid(term, 1), kb(term), ke(term))), u => term),\n'
        '    u => term)',
        FAST_MAT.lstrip("\n") + "\n"
        '@unsafe\n'
        'def f_context_higher(+term: KTerm) -> KTerm:\n'
        '  match term:\n'
        '    case KLiteral{_, _, _, _, _}:\n'
        '      term\n'
        '    case KLambda{_, _, _, kids, _, _, _, _}:\n'
        '      match kids:\n'
        '        case Nil{}: term\n'
        '        case Con{_, _}: f_context_material_children(term, kids, Nil{}, False{})\n'
        '    case KTerm{tag, _, _, _, kids, _, _, _}:\n'
        '      w7_mat_hi_tag(w7_char0(tag), tag, term, kids)\n'
        '\n'
        '@unsafe\n'
        'def f_context_lower(+term: KTerm) -> KTerm:\n'
        '  match term:\n'
        '    case KLiteral{_, _, _, _, _}:\n'
        '      term\n'
        '    case KLambda{_, _, _, kids, _, _, _, _}:\n'
        '      match kids:\n'
        '        case Nil{}: term\n'
        '        case Con{_, _}: f_context_material_children(term, kids, Nil{}, True{})\n'
        '    case KTerm{tag, _, _, _, kids, _, _, _}:\n'
        '      match kids:\n'
        '        case Nil{}: term\n'
        '        case Con{_, _}: f_context_material_children(term, kids, Nil{}, True{})\n'
        '\n'
        '@unsafe\n'
        'def f_context_material_deferred(+term: KTerm, +rest: List<&2,KTerm>, +built: List<&2,KTerm>) -> Bool:\n'
        '  match term:\n'
        '    case KLiteral{_, _, _, _, _}: False{}\n'
        '    case KLambda{_, _, _, _, _, _, _, _}: True{}\n'
        '    case KTerm{tag, _, _, _, _, _, _, _}:\n'
        '      f_eq(tag, "Lam") || (f_eq(tag, "All") && Bool.not(List.is_empty(&2,KTerm,built))) || (f_eq(tag, "Let") && List.is_empty(&2,KTerm,rest))\n'
        '\n'
        '@unsafe\n'
        'def f_context_material_children(+term: KTerm, +children: List<&2,KTerm>, +built: List<&2,KTerm>, +lower: Bool) -> KTerm:\n'
        '  match children:\n'
        '    case Nil{}: w7_mat_nil(term, built, lower)\n'
        '    case Con{head, rest}:\n'
        '      +deferred = f_context_material_deferred(term, rest, built)\n'
        '      w7_mat_child_step(Bool.not(lower) && deferred, term, head, rest, built, lower, deferred)\n'
        '\n'
        '@unsafe\n'
        'def f_context_material_next(+term: KTerm, +rest: List<&2,KTerm>, +built: List<&2,KTerm>, +lower: Bool, +head: KTerm) -> KTerm:\n'
        '  f_choose(KTerm, f_context_stop(head), u => head, u => f_context_material_children(term, rest, Con{head, built}, lower))\n'
        '\n'
        '@unsafe\n'
        'def f_context_material_done(+term: KTerm, +lower: Bool) -> KTerm:\n'
        '  match lower:\n'
        '    case True{}: term\n'
        '    case False{}: w7_mat_done_chk(f_eq(tg(term), "App"), term)',
        "f_context_materialize",
    )

    # 9. 1-step ffw_walk_existing + zero-closure f_rename_var
    text = replace_exact(
        text,
        '@unsafe\n'
        'def ffw_walk_existing(+term: KTerm, +env: List<&2,KTerm>, +next: U32, +stack: List<&2,FFFrame>) -> FFresh:\n'
        '  f_choose(FFresh, p98_tag_eq(term, "FGlobal"), u => ffw_done(kt_span("Ref", nm(term), 0, 1, Nil{}, kb(term), ke(term)), next, stack),\n'
        '    u => f_choose(FFresh, p98_tag_eq(term, "FUnboundVar"), u => ffw_done(term, next, stack),\n'
        '    u => f_choose(FFresh, p98_tag_eq(term, "Var"), u => ffw_done(f_rename_var(term, env), next, stack),\n'
        '    u => f_choose(FFresh, p98_tag_eq(term, "All"), u => ffw_walk(kid(term, 0), env, U32.add(next, 1), Con{FFAllA{term, env, next}, stack}),\n'
        '    u => f_choose(FFresh, p98_tag_eq(term, "Lam"), u => ffw_walk(kid(term, 0), Con{kt("Map", "", ix(term), 0, [var(nm(term), next)]), env}, U32.add(next, 1), Con{FFLambda{term, next}, stack}),\n'
        '    u => f_choose(FFresh, p98_tag_eq(term, "Let"), u => ffw_let(env, env, ks(term), Nil{}, next, Con{FFOrigin{kb(term), ke(term)}, stack}),\n'
        '    u => ffw_kids(term, env, ks(term), Nil{}, next, stack)))))))',
        FAST_FFW.lstrip("\n") + "\n"
        '@unsafe\n'
        'def ffw_walk_existing(+term: KTerm, +env: List<&2,KTerm>, +next: U32, +stack: List<&2,FFFrame>) -> FFresh:\n'
        '  match term:\n'
        '    case KLiteral{_, _, _, _, _}:\n'
        '      ffw_done(term, next, stack)\n'
        '    case KLambda{name, id, _, _, _, _, _, _}:\n'
        '      ffw_walk(kid(term, 0), Con{kt("Map", "", id, 0, [var(name, next)]), env}, U32.add(next, 1), Con{FFLambda{term, next}, stack})\n'
        '    case KTerm{tag, _, _, _, _, _, _, _}:\n'
        '      w7_ffw_tag(w7_char0(tag), tag, term, env, next, stack)',
        "ffw_walk_existing",
    )

    text = replace_exact(
        text,
        '@unsafe\n'
        'def f_rename_var(t, env):\n'
        '  match env:\n'
        '    case Nil{}:\n'
        '      t\n'
        '    case Con{+m, ms}:\n'
        '      f_choose(KTerm, U32.is_eq(ix(t), ix(m)), u => f_choose(KTerm, p98_tag_eq(kid(m, 0), "Ref"), u => k_with_span(kid(m, 0), kb(t), ke(t)), u => kt_span("Var", nm(t), ix(kid(m, 0)), qt(t), Nil{}, kb(t), ke(t))), u => f_rename_var(t, ms))',
        '@unsafe\n'
        'def f_rename_var(t, env):\n'
        '  match env:\n'
        '    case Nil{}:\n'
        '      t\n'
        '    case Con{+m, ms}:\n'
        '      w7_rename_hit(U32.is_eq(ix(t), ix(m)), t, m, ms)',
        "f_rename_var",
    )

    # 10. 1-step char-switch f_reserved
    text = replace_exact(
        text,
        '@unsafe\n'
        'def f_reserved(s):\n'
        '  f_eq(s, "def") || f_eq(s, "type") || f_eq(s, "law") || f_eq(s, "match") || f_eq(s, "case") || f_eq(s, "do") || f_eq(s, "return") || f_eq(s, "for") || f_eq(s, "exs") || f_eq(s, "where") || f_eq(s, "is") || f_eq(s, "import") || f_eq(s, "Type") || f_eq(s, "Data") || f_eq(s, "Kind") || f_eq(s, "Quant")',
        FAST_RESERVED.lstrip("\n") + "\n"
        '@unsafe\n'
        'def f_reserved(s):\n'
        '  w7_reserved_c(w7_char0(s), s)',
        "f_reserved",
    )

    # 11. Zero-closure tele_check_static
    text = replace_exact(
        text,
        '@unsafe\n'
        'def tele_check_static(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +args: List<&2,KTerm>, +dem: U32) -> KChecking:\n'
        '  match args:\n'
        '    case Nil{}: ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, tel, Nil{})\n'
        '    case Con{h, rest}:\n'
        '      kc(KChecking, p98_tag_eq(tel, "All"), u => ki_tele_static(e, ctx, tel, rest, dem, check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0))), u => tele_check(e, ctx, tel, args, dem))',
        '@unsafe\n'
        'def w7_tele_static_all(isAll: Bool, +e: KEnv, +ctx: List<&2, KTerm>, +tel: KTerm, +h: KTerm, +rest: List<&2, KTerm>, +args: List<&2, KTerm>, +dem: U32) -> KChecking:\n'
        '  match isAll:\n'
        '    case True{}:\n'
        '      ki_tele_static(e, ctx, tel, rest, dem, check(e, ctx, h, qdem(qt(tel), dem), kid(tel, 0)))\n'
        '    case False{}:\n'
        '      tele_check(e, ctx, tel, args, dem)\n\n'
        '@unsafe\n'
        'def tele_check_static(+e: KEnv, +ctx: List<&2,KTerm>, +tel: KTerm, +args: List<&2,KTerm>, +dem: U32) -> KChecking:\n'
        '  match args:\n'
        '    case Nil{}: ok(cw(e), {KTerm{"Args", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, tel, Nil{})\n'
        '    case Con{h, rest}:\n'
        '      w7_tele_static_all(p98_tag_eq(tel, "All"), e, ctx, tel, h, rest, args, dem)',
        "tele_check_static",
    )

    # 12. 1-step kind+char dispatch for f_atom_base + zero-closure f_grow_base / f_grow_existing / f_locate
    text = replace_exact(
        text,
        '@unsafe\n'
        'def f_atom_base(\n'
        '  +ts: FInput,\n'
        ') -> FParsed:\n'
        '  f_choose(FParsed, f_eq(f_tx(ts), "++"), u => f_atom_base(f_prepend(FToken{"+", f_line(ts), f_col(ts), 0, f_begin(ts), f_cursor_add(f_begin(ts), 1), f_previous_end(ts)}, f_prepend(FToken{"+", f_line(ts), U32.add(f_col(ts), 1), 0, f_cursor_add(f_begin(ts), 1), f_end(ts), f_cursor_add(f_begin(ts), 1)}, f_tl(ts)))),\n'
        '    u => f_choose(FParsed, f_eq(f_tx(ts), "("), u => f_group(f_body(f_tl(ts))),\n'
        '    u => f_choose(FParsed, f_eq(f_tx(ts), "{"), u => f_brace(f_tl(ts)),\n'
        '    u => f_choose(FParsed, f_eq(f_tx(ts), "["), u => f_array(f_tl(ts)),\n'
        '    u => f_choose(FParsed, f_eq(f_tx(ts), "@"), u => f_all(f_tl(ts), False{}),\n'
        '    u => f_choose(FParsed, f_eq(f_tx(ts), "&"), u => f_grade(f_tl(ts)),\n'
        '    u => f_choose(FParsed, f_eq(f_tx(ts), "+") || f_eq(f_tx(ts), "+bind"), u => f_mark(f_expr(f_tl(ts), 12), 2),\n'
        '    u => f_choose(FParsed, f_eq(f_tx(ts), "?"), u => FParsed{kt("Hol", f_tx(f_tl(ts)), 0, 0, Nil{}), f_tl(f_tl(ts))},\n'
        '    u => f_choose(FParsed, f_eq(f_tx(ts), "\\\\"), u => f_choose(FParsed, f_eq(f_tx(f_tl(ts)), "{"), u => f_matcher(f_tl(f_tl(ts))), u => fpe_error(f_tl(ts), "expected {", "\'{\'")),\n'
        '    u => f_choose(FParsed, f_eq(f_tx(ts), "Type") || f_eq(f_tx(ts), "Data"), u => FParsed{kt("Typ", "", 0, 0, [kt("Qua", "", 0, f_choose(U32, f_eq(f_tx(ts), "Data"), u => 2, u => 1), Nil{})]), f_tl(ts)},\n'
        '    u => f_choose(FParsed, f_eq(f_tx(ts), "Quant"), u => FParsed{kt("Qnt", "", 0, 0, Nil{}), f_tl(ts)},\n'
        '    u => f_choose(FParsed, f_eq(f_tx(ts), "Kind"), u => f_kind_wrap(f_expect(f_expr(f_tl(f_tl(ts)), 0), ")")),\n'
        '    u => f_choose(FParsed, U32.is_eq(f_kind_token(ts), 2), u => FParsed{kt("Literal", f_tx(ts), 0, 1, Nil{}), f_tl(ts)},\n'
        '    u => f_choose(FParsed, U32.is_eq(f_kind_token(ts), 1) && Bool.not(f_reserved(f_tx(ts))), u => f_choose(FParsed, f_ascii_alpha(f_head(f_tx(ts))) || f_ascii_digit(f_head(f_tx(ts))) || Char.is_eq(f_head(f_tx(ts)), \'_\'), u => f_atom_name(ts), u => fpe_error(ts, "expected term", "a term")),\n'
        '    u => f_choose(FParsed, f_reserved(f_tx(ts)), u => f_choose(FParsed, f_eq(f_tx(ts), "return"), u => fpe_word(ts, "return outside do", "a do-block heading this return"), u => fpe_error(ts, "expected term", "a term")), u => fpe_error(ts, "expected term", "a term"))))))))))))))))',
        FAST_PARSER_HOT.split("@unsafe\ndef w7_atom_ret_err", 1)[1].replace(
            "(isRet: Bool", "@unsafe\ndef w7_atom_ret_err(isRet: Bool", 1
        ) + "\n"
        '@unsafe\n'
        'def f_atom_base(\n'
        '  +ts: FInput,\n'
        ') -> FParsed:\n'
        '  w7_atom_kind(f_kind_token(ts), f_tx(ts), ts)',
        "f_atom_base",
    )

    text = replace_exact(
        text,
        '@unsafe\n'
        'def f_grow_base(+p: FParsed, +min: U32) -> FParsed:\n'
        '  match p:\n'
        '    case FParsed{n,ts}:\n'
        '      f_choose(FParsed,f_eq(tg(n),"Error"),u => FParsed{n,ts},\n'
        '        u => p175p_grow_word(n,ts,min,f_tx(ts)))',
        '@unsafe\n'
        'def f_grow_base(+p: FParsed, +min: U32) -> FParsed:\n'
        '  match p:\n'
        '    case FParsed{n,ts}:\n'
        '      w7_grow_base_err(f_eq(tg(n), "Error"), n, ts, min)',
        "f_grow_base",
    )

    text = replace_exact(
        text,
        '@unsafe\n'
        'def f_grow_existing(+p: FParsed, +min: U32) -> FParsed:\n'
        '  match p:\n'
        '    case FParsed{n,ts}:\n'
        '      +word = f_tx(ts)\n'
        '      f_choose(FParsed,f_eq(word,"\\n"),\n'
        '        u => p175p_grow_newline(n,ts,min,f_skip(ts)),\n'
        '        u => p175p_grow_suffix(n,ts,min,word))',
        '@unsafe\n'
        'def f_grow_existing(+p: FParsed, +min: U32) -> FParsed:\n'
        '  match p:\n'
        '    case FParsed{n,ts}:\n'
        '      +word = f_tx(ts)\n'
        '      w7_grow_ex_nl(f_eq(word, "\\n"), n, ts, min, word)',
        "f_grow_existing",
    )

    text = replace_exact(
        text,
        '@unsafe\n'
        'def f_locate(+p: FParsed, +begin: U32, +force: Bool, +spaced: Bool, +created: Bool) -> FParsed:\n'
        '  match p:\n'
        '    case FParsed{n, ts}:\n'
        '      +end = f_choose(U32, spaced, u => f_begin(f_space(ts)), u => f_previous_end(ts))\n'
        '      FParsed{f_choose(KTerm, U32.is_eq(begin, 0) || U32.is_lt(end, begin) || f_context_stop(n) || (U32.is_gt(kb(n), 0) && Bool.not(force)), u => n, u => f_located_term(n, begin, end, created)), ts}',
        '@unsafe\n'
        'def f_locate(+p: FParsed, +begin: U32, +force: Bool, +spaced: Bool, +created: Bool) -> FParsed:\n'
        '  match p:\n'
        '    case FParsed{n, ts}:\n'
        '      +end = w7_locate_end(spaced, ts)\n'
        '      w7_locate_keep(U32.is_eq(begin, 0) || U32.is_lt(end, begin) || f_context_stop(n) || (U32.is_gt(kb(n), 0) && Bool.not(force)), n, begin, end, created, ts)',
        "f_locate",
    )

    return text


# ---------------------------------------------------------------------------
# Patch C: Zero-closure Bool-helper def lowering for f_choose / kc / nt_choose
# ---------------------------------------------------------------------------

def in_frontend_scope(line_no_1based: int, def_name: str) -> bool:
    if def_name in ("f_choose", "kc", "nt_choose"):
        return False
    if line_no_1based <= 25500:
        return True
    if def_name.startswith(("p140p_", "p143c", "p144p_", "p150l_", "p156cp_", "p175p_", "p177s_")):
        return True
    return False


def parse_laws(lines: list[str]) -> dict[str, tuple[list[tuple[str, str]], str]]:
    laws: dict[str, tuple[list[tuple[str, str]], str]] = {}
    i = 0
    n = len(lines)
    while i < n:
        m = re.match(r"^law\s+([A-Za-z0-9_]+)\s*:\s*$", lines[i])
        if not m:
            i += 1
            continue
        name = m.group(1)
        params: list[tuple[str, str]] = []
        ret = ""
        j = i + 1
        ok = True
        while j < n:
            l = lines[j]
            if not l.strip():
                break
            if not l.startswith(" "):
                break
            s = l.strip()
            if s.startswith("for "):
                pm = re.match(r"^for\s+([+-]?)([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.+)$", s)
                if not pm or pm.group(1) == "-":
                    ok = False
                    break
                params.append((pm.group(2), pm.group(3).strip()))
            else:
                ret = s
                j += 1
                break
            j += 1
        if ok and ret:
            laws[name] = (params, ret)
        i = j
    return laws


def parse_def_sig(
    header_text: str,
    laws: dict[str, tuple[list[tuple[str, str]], str]],
) -> tuple[str, list[tuple[str, str]], str] | None:
    m = re.match(r"^def\s+([A-Za-z0-9_]+)\s*\((.*)\)\s*(?:->\s*(.+))?:\s*$", header_text, re.S)
    if not m:
        return None
    name = m.group(1)
    raw_params = m.group(2).strip()
    ret = (m.group(3) or "").strip()

    if not ret:
        if name not in laws:
            return None
        law_params, law_ret = laws[name]
        arg_names = [a.strip().lstrip("+") for a in split_top_level_args(raw_params) or []]
        if len(arg_names) != len(law_params):
            return None
        params = [(an, pt) for an, (_ln, pt) in zip(arg_names, law_params)]
        return name, params, law_ret

    if not raw_params:
        return name, [], ret
    parts = split_param_list(raw_params)
    if parts is None:
        return None
    params: list[tuple[str, str]] = []
    for p in parts:
        pm = re.match(r"^([+-]?)([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.+)$", p)
        if not pm or pm.group(1) == "-":
            return None
        params.append((pm.group(2), pm.group(3).strip()))
    return name, params, ret


def lower_choose_to_helpers(text: str) -> tuple[str, int]:
    lines = text.splitlines()
    n = len(lines)
    laws = parse_laws(lines)
    out: list[str] = []
    counter = [0]

    def emit_choose(
        expr: str,
        params: list[tuple[str, str]],
        ret: str,
        helpers_out: list[str],
    ) -> str:
        parsed = parse_choose_call(expr)
        if parsed is None:
            return " ".join(expr.split())
        cond, yes_e, no_e = parsed
        used_text = strip_literals(yes_e + " " + no_e)
        used_params = [
            (pn, pt)
            for pn, pt in params
            if re.search(rf"\b{re.escape(pn)}\b", used_text)
        ]
        yes_call = emit_choose(yes_e, used_params, ret, helpers_out)
        no_call = emit_choose(no_e, used_params, ret, helpers_out)

        idx = counter[0]
        counter[0] += 1
        hname = f"w7_br_{idx}"
        param_sig = ", ".join(["w7_c: Bool"] + [f"+{pn}: {pt}" for pn, pt in used_params])
        helpers_out.append(
            f"@unsafe\n"
            f"def {hname}({param_sig}) -> {ret}:\n"
            f"  match w7_c:\n"
            f"    case True{{}}:\n"
            f"      {yes_call}\n"
            f"    case False{{}}:\n"
            f"      {no_call}\n"
        )
        call_args = ", ".join([cond] + [pn for pn, _pt in used_params])
        return f"{hname}({call_args})"

    i = 0
    while i < n:
        line = lines[i]
        if line.strip() == "@unsafe" and i + 1 < n and lines[i + 1].startswith("def "):
            def_start = i + 1
            h_end = def_start
            h_chunks = [lines[def_start]]
            while h_end < n and not lines[h_end].rstrip().endswith(":"):
                h_end += 1
                if h_end < n:
                    h_chunks.append(lines[h_end].strip())
            header_text = " ".join(h_chunks)
            sig = parse_def_sig(header_text, laws)

            b_start = h_end + 1
            b_end = b_start
            while b_end < n:
                bl = lines[b_end]
                if bl and not bl.startswith(" ") and not bl.startswith("\t"):
                    break
                b_end += 1
            body_end = b_end
            while body_end > b_start and not lines[body_end - 1].strip():
                body_end -= 1

            if sig is not None and in_frontend_scope(def_start + 1, sig[0]):
                def_name, params, ret = sig
                body_lines = lines[b_start:body_end]
                non_empty = [bl for bl in body_lines if bl.strip() and not bl.lstrip().startswith("#")]
                if non_empty and non_empty[0].strip().startswith(("f_choose(", "kc(", "nt_choose(")):
                    full_expr = " ".join(bl.strip() for bl in non_empty)
                    if paren_balance(full_expr) == 0 and parse_choose_call(full_expr) is not None:
                        helpers: list[str] = []
                        call_expr = emit_choose(full_expr, params, ret, helpers)
                        for h in helpers:
                            out.append(h)
                        out.extend(lines[i : h_end + 1])
                        out.append("  " + call_expr)
                        out.extend(lines[body_end:b_end])
                        i = b_end
                        continue

        out.append(line)
        i += 1

    return "\n".join(out) + ("\n" if text.endswith("\n") else ""), counter[0]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, required=True)
    ap.add_argument("--dst", type=Path, required=True)
    args = ap.parse_args()

    text = args.src.read_text(encoding="utf-8")
    text = apply_structural_patches(text)
    text, n_helpers = lower_choose_to_helpers(text)
    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(text, encoding="utf-8")
    print(f"[w7_fe_hash] wrote {args.dst} ({len(text):,} bytes), emitted {n_helpers} zero-closure Bool helpers")


if __name__ == "__main__":
    main()
