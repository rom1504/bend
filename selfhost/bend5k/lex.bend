# bend5k/lex.bend — Single-Pass Indentation-Aware Lexer
type LexRes is Data:
  LexRes{toks: List<&2, Tok>, syms: SymTab, err: String}
type StrScan is Data:
  StrScan{text: String, rest: String, ok: Bool}
type NumScan is Data:
  NumScan{val: U32, hi: U32, cnt: U32, sig: U32, exp: U32, rest: String}
type IndentScan is Data:
  IndentScan{col: U32, rest: String}
type IndentRes is Data:
  IndentRes{stk: List<&2, U32>, rev: List<&2, Tok>}
type LStep is Data:
  LDone{res: LexRes}
  LNext{s: String, bol: Bool, sp: Bool, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab}

# Character & Table Helpers
def lex_in(+c: U32, lo: U32, hi: U32) -> Bool: Bool.and(U32.is_ge(c, lo), U32.is_le(c, hi))
def lex_is_digit(+c: U32) -> Bool: lex_in(c, 48, 57)
def lex_is_hex(+c: U32) -> Bool: Bool.or(lex_is_digit(c), Bool.or(lex_in(c, 97, 102), lex_in(c, 65, 70)))
def lex_hex_val(+c: U32) -> U32:
  Bool.pick(U32, lex_is_digit(c), U32.sub(c, 48), Bool.pick(U32, U32.is_ge(c, 97), U32.sub(c, 87), U32.sub(c, 55)))
def lex_is_alpha(+c: U32) -> Bool: Bool.or(Bool.or(lex_in(c, 97, 122), lex_in(c, 65, 90)), U32.is_eq(c, 95))
def lex_is_alnum(+c: U32) -> Bool: Bool.or(lex_is_alpha(c), lex_is_digit(c))
def lex_peek_u32(s: String) -> U32:
  match s:
    case SNil{}: 0
    case SCon{c, _}: Char.to_u32(c)
def lex_is_valid_esc(u: U32) -> Bool:
  match u:
    case 48: True{}
    case 114: True{}
    case 116: True{}
    case 110: True{}
    case 92: True{}
    case 39: True{}
    case 34: True{}
    case _: False{}
def lex_is_sp(u: U32) -> Bool:
  match u:
    case 32: True{}
    case 9: True{}
    case 10: True{}
    case 13: True{}
    case _: False{}
def lex_unesc(u: U32) -> U32:
  match u:
    case 48: 0
    case 114: 13
    case 116: 9
    case 110: 10
    case other: other
def lex_digits_no_n(fuel: Nat, go: Bool, s: String) -> Bool:
  match fuel go s:
    case 0n _ _: False{}
    case _ False{} _: False{}
    case _ True{} SNil{}: True{}
    case 1n+p True{} SCon{Chr{+u}, t}:
      is_d = Bool.or(lex_is_digit(u), U32.is_eq(u, 95))
      Bool.pick(Bool, is_d, lex_digits_no_n(p, True{}, t), Bool.not(U32.is_eq(u, 110)))
def lex_nat_plus_u32_bad(s: String) -> Bool:
  match s:
    case SCon{Chr{u}, t}: lex_digits_no_n(16n, lex_is_digit(u), t)
    case SNil{}: False{}
def lex_kw_code(+w: String) -> U32:
  match w:
    case SCon{Chr{100}, _}: Bool.pick(U32, String.eq(w, "def"), 1, Bool.pick(U32, String.eq(w, "do"), 9, 0))
    case SCon{Chr{105}, _}:
      k2 = Bool.pick(U32, String.eq(w, "if"), 7, Bool.pick(U32, String.eq(w, "import"), 11, 0))
      Bool.pick(U32, String.eq(w, "is"), 4, k2)
    case SCon{Chr{116}, _}: Bool.pick(U32, String.eq(w, "type"), 2, 0)
    case SCon{Chr{108}, _}: Bool.pick(U32, String.eq(w, "law"), 3, 0)
    case SCon{Chr{109}, _}: Bool.pick(U32, String.eq(w, "match"), 5, 0)
    case SCon{Chr{99}, _}: Bool.pick(U32, String.eq(w, "case"), 6, 0)
    case SCon{Chr{101}, _}: Bool.pick(U32, String.eq(w, "else"), 8, 0)
    case SCon{Chr{114}, _}: Bool.pick(U32, String.eq(w, "return"), 10, 0)
    case SCon{Chr{102}, _}: Bool.pick(U32, String.eq(w, "for"), 13, 0)
    case _: 0
def lex_sym2(a: U32, b: U32) -> U32:
  match a b:
    case 45 62: 256
    case 61 62: 257
    case 61 61: 258
    case 33 61: 259
    case 60 61: 260
    case 60 62: 265
    case 60 45: 266
    case 60 60: 269
    case 62 61: 261
    case 62 62: 270
    case 38 38: 262
    case 38 49: 267
    case 38 50: 268
    case 38 48: 271
    case 124 124: 263
    case 43 43: 264
    case _ _: 0
def lex_depth_delta(u: U32, +d: U32) -> U32:
  match u:
    case 40: U32.add(d, 1)
    case 91: U32.add(d, 1)
    case 123: U32.add(d, 1)
    case 41: Bool.pick(U32, U32.is_gt(d, 0), U32.sub(d, 1), d)
    case 93: Bool.pick(U32, U32.is_gt(d, 0), U32.sub(d, 1), d)
    case 125: Bool.pick(U32, U32.is_gt(d, 0), U32.sub(d, 1), d)
    case _: d

# Sub-Scanners (Pure Safe Structural Self-Recursion)
def lex_skip_comment(s: String) -> String:
  match s:
    case SNil{}: SNil{}
    case SCon{Chr{10}, t}: SCon{Chr{10}, t}
    case SCon{_, t}: lex_skip_comment(t)
def lex_count_indent(s: String, col: U32) -> IndentScan:
  match s:
    case SNil{}: IndentScan{col, SNil{}}
    case SCon{Chr{32}, t}: lex_count_indent(t, U32.add(col, 1))
    case SCon{Chr{9}, t}: lex_count_indent(t, U32.add(col, 2))
    case SCon{Chr{13}, t}: lex_count_indent(t, col)
    case SCon{c, t}: IndentScan{col, SCon{c, t}}
def lex_scan_str_go(s: String, mode: U32, hval: U32, acc: String) -> StrScan:
  match s mode:
    case SNil{} _: StrScan{"", SNil{}, False{}}
    case SCon{Chr{34}, t} 0: StrScan{String.reverse(acc), t, True{}}
    case SCon{Chr{92}, t} 0: lex_scan_str_go(t, 1, 0, acc)
    case SCon{c, t} 0: lex_scan_str_go(t, 0, 0, SCon{c, acc})
    case SCon{Chr{117}, t} 1: lex_scan_str_go(t, 2, 0, acc)
    case SCon{ec, t} 1:
      +eu = Char.to_u32(ec)
      Bool.pick(
        StrScan, lex_is_valid_esc(eu),
        lex_scan_str_go(t, 0, 0, SCon{Char.from_u32(lex_unesc(eu)), acc}), StrScan{"", SNil{}, False{}}
      )
    case SCon{Chr{123}, t} 2: lex_scan_str_go(t, 3, 0, acc)
    case SCon{Chr{125}, t} 3: lex_scan_str_go(t, 0, 0, SCon{Char.from_u32(hval), acc})
    case SCon{Chr{+u}, t} 3:
      Bool.pick(
        StrScan, lex_is_hex(u),
        lex_scan_str_go(t, 3, U32.add(U32.mul(hval, 16), lex_hex_val(u)), acc), StrScan{"", SNil{}, False{}}
      )
    case _ _: StrScan{"", SNil{}, False{}}
def lex_ident_go(s: String, go: Bool, prev: Char, +acc: String) -> StrScan:
  match s go:
    case rest False{}: StrScan{String.reverse(acc), SCon{prev, rest}, True{}}
    case SNil{} True{}: StrScan{String.reverse(acc), SNil{}, True{}}
    case SCon{+c, +t} True{}:
      +u = Char.to_u32(c)
      +k = Bool.or(lex_is_alnum(u), Bool.and(U32.is_eq(u, 46), lex_is_alpha(lex_peek_u32(t))))
      lex_ident_go(t, k, c, Bool.pick(String, k, SCon{c, acc}, acc))
def lex_u64_m10(is_hi: Bool, hi: U32, +lo: U32, +d: U32) -> U32:
  +t0 = U32.add(U32.mul(U32.and(lo, 65535), 10), d)
  +t1 = U32.add(U32.mul(U32.shrn(lo, 16n), 10), U32.shrn(t0, 16n))
  Bool.pick(
    U32, is_hi, U32.add(U32.mul(hi, 10), U32.shrn(t1, 16n)),
    U32.or(U32.shln(U32.and(t1, 65535), 16n), U32.and(t0, 65535))
  )
def lex_scnum_go(
  s: String, go: Bool, prev: Char, +is_hex: Bool,
  +val: U32, +hi: U32, +cnt: U32, +sig: U32, +exp: U32
) -> NumScan:
  match s go:
    case rest False{}: NumScan{val, hi, cnt, sig, exp, SCon{prev, rest}}
    case SNil{} True{}: NumScan{val, hi, cnt, sig, exp, SNil{}}
    case SCon{+c, t} True{}:
      +u = Char.to_u32(c)
      +ok = Bool.pick(Bool, is_hex, lex_is_hex(u), lex_is_digit(u))
      +d = Bool.pick(U32, is_hex, lex_hex_val(u), U32.sub(u, 48))
      +keep = Bool.and(ok, Bool.or(is_hex, U32.is_lt(sig, 18)))
      v_new = Bool.pick(U32, is_hex, U32.add(U32.mul(val, 16), d), lex_u64_m10(False{}, hi, val, d))
      val2 = Bool.pick(U32, keep, v_new, val)
      hi2 = Bool.pick(U32, Bool.and(keep, Bool.not(is_hex)), lex_u64_m10(True{}, hi, val, d), hi)
      sig2 = Bool.pick(U32, Bool.and(keep, Bool.or(U32.is_gt(sig, 0), U32.is_gt(d, 0))), U32.add(sig, 1), sig)
      exp2 = Bool.pick(U32, Bool.and(ok, Bool.and(Bool.not(is_hex), U32.is_ge(sig, 18))), U32.add(exp, 1), exp)
      cnt2 = Bool.pick(U32, ok, U32.add(cnt, 1), cnt)
      lex_scnum_go(t, Bool.or(ok, U32.is_eq(u, 95)), c, is_hex, val2, hi2, cnt2, sig2, exp2)

# IEEE-754 F32 Bits from Decimal (exact single-rounding via F32.read)
def lex_has_exp_start(s: String) -> Bool:
  match s:
    case SCon{Chr{+u}, t}:
      Bool.pick(Bool, Bool.or(U32.is_eq(u, 43), U32.is_eq(u, 45)), lex_is_digit(lex_peek_u32(t)), lex_is_digit(u))
    case SNil{}: False{}
def lex_scan_flt_go(s: String, go: Bool, prev: Char, +mode: U32, +acc: String) -> StrScan:
  match s go:
    case rest False{}: StrScan{String.reverse(acc), SCon{prev, rest}, True{}}
    case SNil{} True{}: StrScan{String.reverse(acc), SNil{}, True{}}
    case SCon{Chr{+u}, +t} True{}:
      +is_d = lex_is_digit(u)
      +is_u = U32.is_eq(u, 95)
      is_dot = Bool.and(U32.is_zero(mode), Bool.and(U32.is_eq(u, 46), lex_is_digit(lex_peek_u32(t))))
      +is_e = Bool.and(U32.is_le(mode, 1), Bool.and(Bool.or(U32.is_eq(u, 101), U32.is_eq(u, 69)), lex_has_exp_start(t)))
      is_m2 = Bool.and(U32.is_eq(mode, 2), Bool.or(is_d, Bool.or(U32.is_eq(u, 43), U32.is_eq(u, 45))))
      m_dot = Bool.pick(U32, is_dot, 1, Bool.pick(U32, is_e, 2, 4))
      +m2 = Bool.pick(U32, is_m2, 3, Bool.pick(U32, Bool.and(U32.is_ne(mode, 2), Bool.or(is_d, is_u)), mode, m_dot))
      +ch = Bool.pick(U32, is_e, 101, Bool.pick(U32, Bool.and(U32.is_ne(mode, 2), is_u), 0, u))
      acc2 = Bool.pick(String, Bool.and(U32.is_lt(m2, 4), U32.is_gt(ch, 0)), SCon{Chr{ch}, acc}, acc)
      lex_scan_flt_go(t, U32.is_lt(m2, 4), Chr{u}, m2, acc2)

# Layout Helpers
def lex_need_nl(rev: List<&2, Tok>) -> Bool:
  match rev:
    case Con{Tok{TkNewline{}, _}, _}: False{}
    case Con{Tok{TkIndent{}, _}, _}: False{}
    case Con{Tok{TkDedent{}, _}, _}: False{}
    case Con{_, _}: True{}
    case Nil{}: False{}
def lex_stk_top(stk: List<&2, U32>) -> U32:
  match stk:
    case Nil{}: 0
    case Con{h, _}: h
def lex_dedent_go(stk: List<&2, U32>, go: Bool, top: U32, +col: U32, +line: U32, +rev: List<&2, Tok>) -> IndentRes:
  match stk go:
    case rest False{}: IndentRes{Con{top, rest}, rev}
    case Nil{} True{}: IndentRes{Con{0, Nil{}}, rev}
    case Con{+t, rest} True{}:
      +gt = U32.is_gt(t, col)
      lex_dedent_go(rest, gt, t, col, line, Bool.pick(List<&2, Tok>, gt, Con{Tok{TkDedent{}, line}, rev}, rev))
def lex_dedent_all(stk: List<&2, U32>, +line: U32, rev: List<&2, Tok>) -> List<&2, Tok>:
  match stk:
    case Nil{}: rev
    case Con{0, rest}: lex_dedent_all(rest, line, rev)
    case Con{_, rest}: lex_dedent_all(rest, line, Con{Tok{TkDedent{}, line}, rev})

# Main Lexer Step & Loop
def lex_emit(s: String, k: TokKind, stk: List<&2, U32>, d: U32, +ln: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  LNext{s, False{}, False{}, stk, d, ln, Con{Tok{k, ln}, rev}, syms}
def lex_eof(stk: List<&2, U32>, +ln: U32, +rev: List<&2, Tok>, syms: SymTab) -> LexRes:
  rev1 = Bool.pick(List<&2, Tok>, lex_need_nl(rev), Con{Tok{TkNewline{}, ln}, rev}, rev)
  LexRes{b5k_list_rev(Tok, Con{Tok{TkEof{}, ln}, lex_dedent_all(stk, ln, rev1)}), syms, ""}
def lex_bol_ded(s: String, d: U32, ln: U32, syms: SymTab, ir: IndentRes) -> LStep:
  IndentRes{stk2, rev2} = ir
  LNext{s, False{}, True{}, stk2, d, ln, rev2, syms}
def lex_bol_scan(
  +stk: List<&2, U32>, +d: U32, +ln: U32, +rev: List<&2, Tok>, +syms: SymTab, sc: IndentScan
) -> LStep:
  match sc:
    case IndentScan{_, SNil{}}: LDone{lex_eof(stk, ln, rev, syms)}
    case IndentScan{+col, SCon{Chr{+u}, +t}}:
      match u:
        case 10: LNext{t, True{}, True{}, stk, d, U32.add(ln, 1), rev, syms}
        case 35: LNext{lex_skip_comment(t), True{}, True{}, stk, d, ln, rev, syms}
        case _:
          +s1: String = SCon{Chr{u}, t}
          Bool.pick(
            LStep, U32.is_gt(col, lex_stk_top(stk)),
            LNext{s1, False{}, True{}, Con{col, stk}, d, ln, Con{Tok{TkIndent{}, ln}, rev}, syms},
            lex_bol_ded(s1, d, ln, syms, lex_dedent_go(stk, True{}, 0, col, ln, rev))
          )
def lex_ident_intern(
  rest: String, stk: List<&2, U32>, d: U32, +ln: U32, rev: List<&2, Tok>, sr: SymRes
) -> LStep:
  SymRes{syms2, id} = sr
  LNext{rest, False{}, False{}, stk, d, ln, Con{Tok{TkIdent{id}, ln}, rev}, syms2}
def lex_ident_kw(
  word: String, rest: String, kw: U32,
  stk: List<&2, U32>, d: U32, +ln: U32, rev: List<&2, Tok>, syms: SymTab
) -> LStep:
  match kw:
    case 0: lex_ident_intern(rest, stk, d, ln, rev, symtab_intern(syms, word))
    case k: lex_emit(rest, TkKw{k}, stk, d, ln, rev, syms)
def lex_ident_done(stk: List<&2, U32>, d: U32, ln: U32, rev: List<&2, Tok>, syms: SymTab, sc: StrScan) -> LStep:
  StrScan{+word, rest, _} = sc
  lex_ident_kw(word, rest, lex_kw_code(word), stk, d, ln, rev, syms)
def lex_str_done(
  +stk: List<&2, U32>, +d: U32, +ln: U32, +rev: List<&2, Tok>, +syms: SymTab, sc: StrScan
) -> LStep:
  StrScan{val, rest, ok} = sc
  Bool.pick(
    LStep, ok, lex_emit(rest, TkStr{val}, stk, d, ln, rev, syms),
    LDone{LexRes{Nil{}, syms, "unterminated or invalid string literal"}}
  )
def lex_num_nat_emit(
  +val: U32, rt: String, +stk: List<&2, U32>, +d: U32, +ln: U32, +rev: List<&2, Tok>, +syms: SymTab
) -> LStep:
  match rt:
    case SCon{Chr{43}, SCon{Chr{43}, rt2}}:
      LNext{rt2, False{}, False{}, stk, d, ln, Con{Tok{TkSym{278}, ln}, Con{Tok{TkNum{val}, ln}, rev}}, syms}
    case SCon{Chr{43}, +rt1}:
      Bool.pick(
        LStep, lex_nat_plus_u32_bad(rt1),
        LDone{LexRes{Nil{}, syms, "nat successor requires Nat, not U32"}},
        LNext{rt1, False{}, False{}, stk, d, ln, Con{Tok{TkSym{277}, ln}, Con{Tok{TkNum{val}, ln}, rev}}, syms}
      )
    case other:
      LNext{other, False{}, False{}, stk, d, ln, Con{Tok{TkNum{val}, ln}, Con{Tok{TkSym{279}, ln}, rev}}, syms}
def lex_flt_emit(
  stk: List<&2, U32>, d: U32, ln: U32, rev: List<&2, Tok>, syms: SymTab, sc: StrScan
) -> LStep:
  StrScan{fstr, rest, _} = sc
  lex_emit(rest, TkFlt{F32.bits(Maybe.default(&2, F32, F32.read(fstr), 0.0))}, stk, d, ln, rev, syms)
def lex_num_dec_k(
  is_f: Bool, is_nat: Bool, ovf: Bool, raw: String, val: U32, rc: Char, rt: String,
  +stk: List<&2, U32>, +d: U32, +ln: U32, +rev: List<&2, Tok>, +syms: SymTab
) -> LStep:
  match is_f is_nat:
    case True{} _: lex_flt_emit(stk, d, ln, rev, syms, lex_scan_flt_go(raw, True{}, Chr{0}, 0, SNil{}))
    case False{} True{}:
      Bool.pick(
        LStep, ovf, LDone{LexRes{Nil{}, syms, "nat literal overflow (up to 4294967295n)"}},
        lex_num_nat_emit(val, rt, stk, d, ln, rev, syms)
      )
    case False{} False{}:
      Bool.pick(
        LStep, ovf, LDone{LexRes{Nil{}, syms, "u32 literal overflow"}},
        lex_emit(SCon{rc, rt}, TkNum{val}, stk, d, ln, rev, syms)
      )
def lex_num_dec(
  raw: String, +stk: List<&2, U32>, +d: U32, +ln: U32, +rev: List<&2, Tok>, +syms: SymTab, ns: NumScan
) -> LStep:
  match ns:
    case NumScan{val, hi, _, _, exp, SNil{}}:
      ovf = Bool.or(U32.is_gt(hi, 0), U32.is_gt(exp, 0))
      Bool.pick(
        LStep, ovf, LDone{LexRes{Nil{}, syms, "u32 literal overflow"}},
        lex_emit(SNil{}, TkNum{val}, stk, d, ln, rev, syms)
      )
    case NumScan{val, hi, _, _, exp, SCon{+rc, +rt}}:
      +ru = Char.to_u32(rc)
      is_f = Bool.or(
        Bool.and(U32.is_eq(ru, 46), lex_is_digit(lex_peek_u32(rt))),
        Bool.and(Bool.or(U32.is_eq(ru, 101), U32.is_eq(ru, 69)), lex_has_exp_start(rt))
      )
      lex_num_dec_k(
        is_f, U32.is_eq(ru, 110), Bool.or(U32.is_gt(hi, 0), U32.is_gt(exp, 0)),
        raw, val, rc, rt, stk, d, ln, rev, syms
      )
def lex_num_if(
  +u: U32, +t: String, stk: List<&2, U32>, d: U32, ln: U32, rev: List<&2, Tok>, syms: SymTab, hx: Bool
) -> LStep:
  match hx:
    case True{}: LDone{LexRes{Nil{}, syms, "invalid hex literal"}}
    case False{}:
      +dg = U32.sub(u, 48)
      sig0 = Bool.pick(U32, U32.is_gt(dg, 0), 1, 0)
      lex_num_dec(SCon{Chr{u}, t}, stk, d, ln, rev, syms, lex_scnum_go(t, True{}, Chr{0}, False{}, dg, 0, 1, sig0, 0))
def lex_num_start(
  +u: U32, t: String, stk: List<&2, U32>, d: U32, ln: U32, rev: List<&2, Tok>, syms: SymTab
) -> LStep:
  match t:
    case SNil{}: lex_num_dec(SCon{Chr{u}, SNil{}}, stk, d, ln, rev, syms, NumScan{U32.sub(u, 48), 0, 1, 1, 0, SNil{}})
    case SCon{+c2, +r}:
      +u2 = Char.to_u32(c2)
      hx = Bool.and(U32.is_eq(u, 48), Bool.or(U32.is_eq(u2, 120), U32.is_eq(u2, 88)))
      lex_num_if(u, SCon{c2, r}, stk, d, ln, rev, syms, hx)
def lex_chr_uni(stk: List<&2, U32>, d: U32, ln: U32, rev: List<&2, Tok>, syms: SymTab, ns: NumScan) -> LStep:
  match ns:
    case NumScan{val, _, _, _, _, SCon{Chr{125}, SCon{Chr{39}, t2}}}: lex_emit(t2, TkChr{val}, stk, d, ln, rev, syms)
    case _: LDone{LexRes{Nil{}, syms, "unterminated char escape"}}
def lex_tok_chr(t: String, stk: List<&2, U32>, d: U32, ln: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match t:
    case SCon{Chr{92}, SCon{Chr{117}, SCon{Chr{123}, t3}}}:
      lex_chr_uni(stk, d, ln, rev, syms, lex_scnum_go(t3, True{}, Chr{0}, True{}, 0, 0, 0, 0, 0))
    case SCon{Chr{92}, SCon{ec, SCon{_, t3}}}: lex_emit(t3, TkChr{lex_unesc(Char.to_u32(ec))}, stk, d, ln, rev, syms)
    case SCon{Chr{92}, _}: LDone{LexRes{Nil{}, syms, "unterminated char escape"}}
    case SCon{c1, SCon{_, t2}}: lex_emit(t2, TkChr{Char.to_u32(c1)}, stk, d, ln, rev, syms)
    case _: LDone{LexRes{Nil{}, syms, "unterminated char literal"}}
def lex_dot_op(t: String) -> U32:
  match t:
    case SCon{Chr{38}, SCon{Chr{46}, _}}: 273
    case SCon{Chr{124}, SCon{Chr{46}, _}}: 274
    case SCon{Chr{94}, SCon{Chr{46}, _}}: 275
    case _: 0
def lex_sym_unsafe(
  +u: U32, t: String, sp: Bool,
  +stk: List<&2, U32>, +d: U32, +ln: U32, +rev: List<&2, Tok>, +syms: SymTab, is_u: Bool
) -> LStep:
  match t is_u:
    case _ True{}: lex_emit(String.drop(t, 6n), TkKw{17}, stk, d, ln, rev, syms)
    case SNil{} False{}: lex_emit(SNil{}, TkSym{u}, stk, lex_depth_delta(u, d), ln, rev, syms)
    case SCon{+c2, +t2} False{}:
      +u2 = Char.to_u32(c2)
      is_lt = Bool.and(U32.is_eq(u, 60), Bool.and(U32.is_eq(u2, 38), U32.is_eq(lex_peek_u32(t2), 62)))
      +dop = Bool.pick(U32, U32.is_eq(u, 46), lex_dot_op(SCon{c2, t2}), Bool.pick(U32, is_lt, 272, 0))
      +s2 = lex_sym2(u, u2)
      u_emit = Bool.pick(U32, Bool.and(U32.is_eq(u, 43), Bool.and(sp, lex_is_sp(u2))), 276, u)
      Bool.pick(
        LStep, U32.is_gt(dop, 0), lex_emit(String.drop(t2, 1n), TkSym{dop}, stk, d, ln, rev, syms),
        Bool.pick(
          LStep, U32.is_zero(s2),
          lex_emit(SCon{c2, t2}, TkSym{u_emit}, stk, lex_depth_delta(u, d), ln, rev, syms),
          lex_emit(t2, TkSym{s2}, stk, d, ln, rev, syms)
        )
      )
def lex_tok_val(
  ch: Char, +u: U32, +t: String, sp: Bool,
  stk: List<&2, U32>, d: U32, ln: U32, rev: List<&2, Tok>, syms: SymTab, alp: Bool, dig: Bool
) -> LStep:
  match alp dig:
    case True{} _: lex_ident_done(stk, d, ln, rev, syms, lex_ident_go(t, True{}, Chr{0}, SCon{ch, SNil{}}))
    case False{} True{}: lex_num_start(u, t, stk, d, ln, rev, syms)
    case False{} False{}:
      lex_sym_unsafe(u, t, sp, stk, d, ln, rev, syms, Bool.and(U32.is_eq(u, 64), String.starts_with(t, "unsafe")))
def lex_tok(s: String, sp: Bool, stk: List<&2, U32>, +d: U32, +ln: U32, +rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match s:
    case SNil{}: LDone{lex_eof(stk, ln, rev, syms)}
    case SCon{Chr{+u}, t}:
      match u:
        case 32: LNext{t, False{}, True{}, stk, d, ln, rev, syms}
        case 9: LNext{t, False{}, True{}, stk, d, ln, rev, syms}
        case 13: LNext{t, False{}, True{}, stk, d, ln, rev, syms}
        case 35: LNext{lex_skip_comment(t), False{}, True{}, stk, d, ln, rev, syms}
        case 10:
          +z = U32.is_zero(d)
          rev2 = Bool.pick(List<&2, Tok>, Bool.and(z, lex_need_nl(rev)), Con{Tok{TkNewline{}, ln}, rev}, rev)
          LNext{t, z, True{}, stk, d, U32.add(ln, 1), rev2, syms}
        case 34: lex_str_done(stk, d, ln, rev, syms, lex_scan_str_go(t, 0, 0, SNil{}))
        case 39: lex_tok_chr(t, stk, d, ln, rev, syms)
        case _: lex_tok_val(Chr{u}, u, t, sp, stk, d, ln, rev, syms, lex_is_alpha(u), lex_is_digit(u))
def lex_chunk(fuel: Nat, st: LStep) -> LStep:
  match fuel st:
    case _ LDone{res}: LDone{res}
    case 0n s: s
    case 1n+p LNext{s, True{}, _, stk, 0, ln, rev, syms}:
      lex_chunk(p, lex_bol_scan(stk, 0, ln, rev, syms, lex_count_indent(s, 0)))
    case 1n+p LNext{s, _, sp, stk, d, ln, rev, syms}:
      lex_chunk(p, lex_tok(s, sp, stk, d, ln, rev, syms))
def lex_run(outer: Nat, st: LStep) -> LexRes:
  match outer st:
    case _ LDone{res}: res
    case 0n LNext{_, _, _, stk, _, ln, rev, syms}: lex_eof(stk, ln, rev, syms)
    case 1n+p s: lex_run(p, lex_chunk(U32.to_nat(512), s))
def b5k_lex(src: String, syms: SymTab) -> LexRes:
  lex_run(U32.to_nat(4096), LNext{src, True{}, True{}, Con{0, Nil{}}, 0, 1, Nil{}, syms})
