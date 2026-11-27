# bend5k/lex.bend — Single-Pass Indentation-Aware Lexer
# =====================================================
# Emits TkIndent/TkDedent/TkNewline/TkEof and interns every identifier
# via SymTab so downstream passes only see dense U32 sym IDs.
# Keywords (TkKw): 1=def 2=type 3=law 4=is 5=match 6=case 7=if 8=else
#   9=do 10=return 11=import 13=for 17=@unsafe
# Symbols (TkSym): ASCII for 1-char; 256=-> 257==> 258=== 259=!= 260=<=
#   261=>= 262=&& 263=|| 264=++ 265=<> 266=<- 267=&1 268=&2 269=<< 270=>> 271=&0 272=<&>
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
  LNext{s: String, stk: List<&2, U32>, bol: Bool, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab}
# Character & Table Helpers
def lex_in(+c: U32, lo: U32, hi: U32) -> Bool: Bool.and(U32.is_ge(c, lo), U32.is_le(c, hi))
def lex_is_digit(+c: U32) -> Bool: lex_in(c, 48, 57)
def lex_is_hex(+c: U32) -> Bool: Bool.or(lex_is_digit(c), Bool.or(lex_in(c, 97, 102), lex_in(c, 65, 70)))
def lex_hex_val(+c: U32) -> U32: Bool.pick(U32, lex_is_digit(c), U32.sub(c, 48), Bool.pick(U32, U32.is_ge(c, 97), U32.sub(c, 87), U32.sub(c, 55)))
def lex_is_alpha(+c: U32) -> Bool: Bool.or(Bool.or(lex_in(c, 97, 122), lex_in(c, 65, 90)), U32.is_eq(c, 95))
def lex_is_alnum(+c: U32) -> Bool: Bool.or(lex_is_alpha(c), lex_is_digit(c))
def lex_peek_u32(s: String) -> U32:
  match s:
    case SNil{}: 0
    case SCon{c, _}: Char.to_u32(c)
def lex_unesc(+u: U32) -> U32:
  match u:
    case 48: 0
    case 114: 13
    case 116: 9
    case 110: 10
    case _: u
def lex_kw_code(+w: String) -> U32:
  match w:
    case SCon{Chr{c}, _}:
      match c:
        case 100: Bool.pick(U32, String.eq(w, "def"), 1, Bool.pick(U32, String.eq(w, "do"), 9, 0))
        case 116: Bool.pick(U32, String.eq(w, "type"), 2, 0)
        case 108: Bool.pick(U32, String.eq(w, "law"), 3, 0)
        case 105: Bool.pick(U32, String.eq(w, "is"), 4, Bool.pick(U32, String.eq(w, "if"), 7, Bool.pick(U32, String.eq(w, "import"), 11, 0)))
        case 109: Bool.pick(U32, String.eq(w, "match"), 5, 0)
        case 99: Bool.pick(U32, String.eq(w, "case"), 6, 0)
        case 101: Bool.pick(U32, String.eq(w, "else"), 8, 0)
        case 114: Bool.pick(U32, String.eq(w, "return"), 10, 0)
        case 102: Bool.pick(U32, String.eq(w, "for"), 13, 0)
        case _: 0
    case _: 0
def lex_sym2(+a: U32, +b: U32) -> U32:
  match a:
    case 45: Bool.pick(U32, U32.is_eq(b, 62), 256, 0)
    case 61: Bool.pick(U32, U32.is_eq(b, 62), 257, Bool.pick(U32, U32.is_eq(b, 61), 258, 0))
    case 33: Bool.pick(U32, U32.is_eq(b, 61), 259, 0)
    case 60: Bool.pick(U32, U32.is_eq(b, 61), 260, Bool.pick(U32, U32.is_eq(b, 62), 265, Bool.pick(U32, U32.is_eq(b, 45), 266, Bool.pick(U32, U32.is_eq(b, 60), 269, 0))))
    case 62: Bool.pick(U32, U32.is_eq(b, 61), 261, Bool.pick(U32, U32.is_eq(b, 62), 270, 0))
    case 38: Bool.pick(U32, U32.is_eq(b, 38), 262, Bool.pick(U32, U32.is_eq(b, 49), 267, Bool.pick(U32, U32.is_eq(b, 50), 268, Bool.pick(U32, U32.is_eq(b, 48), 271, 0))))
    case 124: Bool.pick(U32, U32.is_eq(b, 124), 263, 0)
    case 43: Bool.pick(U32, U32.is_eq(b, 43), 264, 0)
    case _: 0
def lex_depth_delta(+u: U32, +d: U32) -> U32:
  op = Bool.or(U32.is_eq(u, 40), Bool.or(U32.is_eq(u, 91), U32.is_eq(u, 123)))
  cl = Bool.or(U32.is_eq(u, 41), Bool.or(U32.is_eq(u, 93), U32.is_eq(u, 125)))
  Bool.pick(U32, op, U32.add(d, 1), Bool.pick(U32, Bool.and(cl, U32.is_gt(d, 0)), U32.sub(d, 1), d))
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
    case SCon{ec, t} 1: lex_scan_str_go(t, 0, 0, SCon{Char.from_u32(lex_unesc(Char.to_u32(ec))), acc})
    case SCon{Chr{123}, t} 2: lex_scan_str_go(t, 3, 0, acc)
    case SCon{_, _} 2: StrScan{"", SNil{}, False{}}
    case SCon{Chr{125}, t} 3: lex_scan_str_go(t, 0, 0, SCon{Char.from_u32(hval), acc})
    case SCon{Chr{+u}, t} 3: Bool.pick(StrScan, lex_is_hex(u), lex_scan_str_go(t, 3, U32.add(U32.mul(hval, 16), lex_hex_val(u)), acc), StrScan{"", SNil{}, False{}})
    case _ _: StrScan{"", SNil{}, False{}}
def lex_scan_str(s: String, acc: String) -> StrScan: lex_scan_str_go(s, 0, 0, acc)
def lex_ident_go(s: String, go: Bool, prev: Char, +acc: String) -> StrScan:
  match s go:
    case rest False{}: StrScan{String.reverse(acc), SCon{prev, rest}, True{}}
    case SNil{} True{}: StrScan{String.reverse(acc), SNil{}, True{}}
    case SCon{+c, +t} True{}:
      +u = Char.to_u32(c)
      +k = Bool.or(lex_is_alnum(u), Bool.and(U32.is_eq(u, 46), lex_is_alpha(lex_peek_u32(t))))
      lex_ident_go(t, k, c, Bool.pick(String, k, SCon{c, acc}, acc))
def lex_u64_m10_lo(+lo: U32, +d: U32) -> U32:
  +t0 = U32.add(U32.mul(U32.and(lo, 65535), 10), d)
  +t1 = U32.add(U32.mul(U32.shrn(lo, 16n), 10), U32.shrn(t0, 16n))
  U32.or(U32.shln(U32.and(t1, 65535), 16n), U32.and(t0, 65535))
def lex_u64_m10_hi(+hi: U32, +lo: U32, +d: U32) -> U32:
  +t0 = U32.add(U32.mul(U32.and(lo, 65535), 10), d)
  +t1 = U32.add(U32.mul(U32.shrn(lo, 16n), 10), U32.shrn(t0, 16n))
  U32.add(U32.mul(hi, 10), U32.shrn(t1, 16n))
def lex_scnum_go(s: String, go: Bool, prev: Char, +is_hex: Bool, +val: U32, +hi: U32, +cnt: U32, +sig: U32, +exp: U32) -> NumScan:
  match s go:
    case rest False{}: NumScan{val, hi, cnt, sig, exp, SCon{prev, rest}}
    case SNil{} True{}: NumScan{val, hi, cnt, sig, exp, SNil{}}
    case SCon{+c, t} True{}:
      +u = Char.to_u32(c)
      +ok = Bool.pick(Bool, is_hex, lex_is_hex(u), lex_is_digit(u))
      +d = Bool.pick(U32, is_hex, lex_hex_val(u), U32.sub(u, 48))
      +keep = Bool.and(ok, Bool.or(is_hex, U32.is_lt(sig, 18)))
      val2 = Bool.pick(U32, keep, Bool.pick(U32, is_hex, U32.add(U32.mul(val, 16), d), lex_u64_m10_lo(val, d)), val)
      hi2 = Bool.pick(U32, Bool.and(keep, Bool.not(is_hex)), lex_u64_m10_hi(hi, val, d), hi)
      nz = Bool.or(U32.is_gt(sig, 0), U32.is_gt(d, 0))
      sig2 = Bool.pick(U32, Bool.and(keep, nz), U32.add(sig, 1), sig)
      exp2 = Bool.pick(U32, Bool.and(ok, Bool.and(Bool.not(is_hex), U32.is_ge(sig, 18))), U32.add(exp, 1), exp)
      lex_scnum_go(t, Bool.or(ok, U32.is_eq(u, 95)), c, is_hex, val2, hi2, Bool.pick(U32, ok, U32.add(cnt, 1), cnt), sig2, exp2)
def lex_u64_m10n_lo(n: Nat, +lo: U32) -> U32:
  match n:
    case 0n: lo
    case 1n+p: lex_u64_m10n_lo(p, lex_u64_m10_lo(lo, 0))
def lex_u64_m10n_hi(n: Nat, +hi: U32, +lo: U32) -> U32:
  match n:
    case 0n: hi
    case 1n+p: lex_u64_m10n_hi(p, lex_u64_m10_hi(hi, lo, 0), lex_u64_m10_lo(lo, 0))
def lex_scfrac_go(s: String, go: Bool, prev: Char, +lo: U32, +hi: U32, +sig: U32, +fexp: U32, +tz: U32) -> NumScan:
  match s go:
    case rest False{}: NumScan{lo, hi, 0, sig, fexp, SCon{prev, rest}}
    case SNil{} True{}: NumScan{lo, hi, 0, sig, fexp, SNil{}}
    case SCon{+c, t} True{}:
      +u = Char.to_u32(c)
      +ok = lex_is_digit(u)
      +d = U32.sub(u, 48)
      +is_z = Bool.and(ok, U32.is_zero(d))
      +is_nz = Bool.and(ok, U32.is_gt(d, 0))
      +sig_z = U32.add(sig, Bool.pick(U32, U32.is_gt(sig, 0), tz, 0))
      +fit = Bool.and(is_nz, U32.is_lt(sig_z, 18))
      +tzn = U32.to_nat(Bool.pick(U32, U32.is_gt(sig, 0), tz, 0))
      +lo_f = lex_u64_m10n_lo(tzn, lo)
      +hi_f = lex_u64_m10n_hi(tzn, hi, lo)
      lo2 = Bool.pick(U32, fit, lex_u64_m10_lo(lo_f, d), lo)
      hi2 = Bool.pick(U32, fit, lex_u64_m10_hi(hi_f, lo_f, d), hi)
      sig2 = Bool.pick(U32, fit, U32.add(sig_z, 1), sig)
      fexp2 = Bool.pick(U32, fit, U32.add(U32.add(fexp, tz), 1), fexp)
      tz2 = Bool.pick(U32, is_z, U32.add(tz, 1), Bool.pick(U32, is_nz, 0, tz))
      lex_scfrac_go(t, Bool.or(ok, U32.is_eq(u, 95)), c, lo2, hi2, sig2, fexp2, tz2)
# IEEE-754 F32 Bits from Decimal (64-bit mantissa + exact power-of-10 scaling)
def lex_f32_pow10(n: Nat, +v: F32) -> F32:
  match n:
    case 0n: v
    case 1n+p: lex_f32_pow10(p, F32.mul(v, 10.0))
def lex_f32_scale_big(fuel: Nat, +neg: Bool, +e: U32, +v: F32) -> F32:
  match fuel:
    case 0n: v
    case 1n+p:
      +big = U32.is_gt(e, 10)
      +step = Bool.pick(U32, big, 10, e)
      +sc = lex_f32_pow10(U32.to_nat(step), 1.0)
      +v2 = Bool.pick(F32, neg, F32.div(v, sc), F32.mul(v, sc))
      Bool.pick(F32, big, lex_f32_scale_big(p, neg, U32.sub(e, 10), v2), v2)
def lex_f32_mul2(n: Nat, +v: F32) -> F32:
  match n:
    case 0n: v
    case 1n+p: lex_f32_mul2(p, F32.mul(v, 2.0))
def lex_u64_to_f32_go(fuel: Nat, +hi: U32, +lo: U32, +sh: U32, +rb: Bool, +st: Bool) -> F32:
  match fuel:
    case 0n: lex_f32_mul2(U32.to_nat(sh), U32.to_f32(lo))
    case 1n+p:
      +big = Bool.or(U32.is_gt(hi, 0), U32.is_ge(lo, 16777216))
      +lo_b = U32.is_ne(U32.and(lo, 1), 0)
      +nlo = U32.or(U32.shrn(lo, 1n), U32.shln(U32.and(hi, 1), 31n))
      +nhi = U32.shrn(hi, 1n)
      +inc = Bool.and(rb, Bool.or(st, lo_b))
      +mant = Bool.pick(U32, inc, U32.add(lo, 1), lo)
      Bool.pick(F32, big, lex_u64_to_f32_go(p, nhi, nlo, U32.add(sh, 1), lo_b, Bool.or(st, rb)), lex_f32_mul2(U32.to_nat(sh), U32.to_f32(mant)))
def lex_f32_from_dec(+hi: U32, +lo: U32, +iexp: U32, +fexp: U32, +e_neg: Bool, +e_val: U32) -> U32:
  +v0 = lex_u64_to_f32_go(48n, hi, lo, 0, False{}, False{})
  +pos = U32.add(iexp, Bool.pick(U32, e_neg, 0, e_val))
  +neg = U32.add(fexp, Bool.pick(U32, e_neg, e_val, 0))
  +is_neg = U32.is_gt(neg, pos)
  +e_abs = U32.min(Bool.pick(U32, is_neg, U32.sub(neg, pos), U32.sub(pos, neg)), 50)
  Bool.pick(U32, Bool.and(U32.is_zero(hi), U32.is_zero(lo)), 0, F32.bits(lex_f32_scale_big(6n, is_neg, e_abs, v0)))
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
def lex_eof(stk: List<&2, U32>, +line: U32, +rev: List<&2, Tok>, syms: SymTab) -> LexRes:
  rev1 = Bool.pick(List<&2, Tok>, lex_need_nl(rev), Con{Tok{TkNewline{}, line}, rev}, rev)
  LexRes{b5k_list_rev(Tok, Con{Tok{TkEof{}, line}, lex_dedent_all(stk, line, rev1)}), syms, ""}
def lex_bol_ded(s: String, depth: U32, line: U32, syms: SymTab, ir: IndentRes) -> LStep:
  IndentRes{stk2, rev2} = ir
  LNext{s, stk2, False{}, depth, line, rev2, syms}
def lex_bol_scan(+stk: List<&2, U32>, +depth: U32, +line: U32, +rev: List<&2, Tok>, +syms: SymTab, sc: IndentScan) -> LStep:
  match sc:
    case IndentScan{_, SNil{}}: LDone{lex_eof(stk, line, rev, syms)}
    case IndentScan{+col, SCon{Chr{+u}, +t}}:
      match u:
        case 10: LNext{t, stk, True{}, depth, U32.add(line, 1), rev, syms}
        case 35: LNext{lex_skip_comment(t), stk, True{}, depth, line, rev, syms}
        case _:
          +s1: String = SCon{Chr{u}, t}
          Bool.pick(LStep, U32.is_gt(col, lex_stk_top(stk)), LNext{s1, Con{col, stk}, False{}, depth, line, Con{Tok{TkIndent{}, line}, rev}, syms}, lex_bol_ded(s1, depth, line, syms, lex_dedent_go(stk, True{}, 0, col, line, rev)))
def lex_ident_intern(rest: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, sr: SymRes) -> LStep:
  SymRes{syms2, id} = sr
  LNext{rest, stk, False{}, depth, line, Con{Tok{TkIdent{id}, line}, rev}, syms2}
def lex_ident_kw(word: String, rest: String, kw: U32, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, is_id: Bool) -> LStep:
  match is_id:
    case True{}: lex_ident_intern(rest, stk, depth, line, rev, symtab_intern(syms, word))
    case False{}: LNext{rest, stk, False{}, depth, line, Con{Tok{TkKw{kw}, line}, rev}, syms}
def lex_ident_done(stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, sc: StrScan) -> LStep:
  StrScan{+word, rest, _} = sc
  +kw = lex_kw_code(word)
  lex_ident_kw(word, rest, kw, stk, depth, line, rev, syms, U32.is_zero(kw))
def lex_num_exp_done(hi: U32, lo: U32, iexp: U32, fexp: U32, e_neg: Bool, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, ns: NumScan) -> LStep:
  NumScan{ev, _, _, _, _, rest} = ns
  LNext{rest, stk, False{}, depth, line, Con{Tok{TkFlt{lex_f32_from_dec(hi, lo, iexp, fexp, e_neg, ev)}, line}, rev}, syms}
def lex_num_exp_start(hi: U32, lo: U32, iexp: U32, fexp: U32, s: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match s:
    case SCon{+c, +t}:
      +u = Char.to_u32(c)
      +is_m = U32.is_eq(u, 45)
      +is_p = U32.is_eq(u, 43)
      rest = Bool.pick(String, Bool.or(is_m, is_p), t, SCon{c, t})
      lex_num_exp_done(hi, lo, iexp, fexp, is_m, stk, depth, line, rev, syms, lex_scnum_go(rest, True{}, Chr{0}, False{}, 0, 0, 0, 0, 0))
    case SNil{}: lex_num_exp_done(hi, lo, iexp, fexp, False{}, stk, depth, line, rev, syms, NumScan{0, 0, 0, 0, 0, SNil{}})
def lex_has_exp_start(s: String) -> Bool:
  match s:
    case SCon{Chr{+u}, t}:
      Bool.pick(Bool, Bool.or(U32.is_eq(u, 43), U32.is_eq(u, 45)), lex_is_digit(lex_peek_u32(t)), lex_is_digit(u))
    case SNil{}: False{}
def lex_num_flt_if(is_e: Bool, hi: U32, lo: U32, iexp: U32, fexp: U32, ec: Char, et: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match is_e:
    case True{}: lex_num_exp_start(hi, lo, iexp, fexp, et, stk, depth, line, rev, syms)
    case False{}: LNext{SCon{ec, et}, stk, False{}, depth, line, Con{Tok{TkFlt{lex_f32_from_dec(hi, lo, iexp, fexp, False{}, 0)}, line}, rev}, syms}
def lex_num_flt_tail(hi: U32, lo: U32, iexp: U32, fexp: U32, rest: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match rest:
    case SCon{+ec, +et}:
      +eu = Char.to_u32(ec)
      is_e = Bool.and(Bool.or(U32.is_eq(eu, 101), U32.is_eq(eu, 69)), lex_has_exp_start(et))
      lex_num_flt_if(is_e, hi, lo, iexp, fexp, ec, et, stk, depth, line, rev, syms)
    case SNil{}: LNext{SNil{}, stk, False{}, depth, line, Con{Tok{TkFlt{lex_f32_from_dec(hi, lo, iexp, fexp, False{}, 0)}, line}, rev}, syms}
def lex_num_done(is_flt: Bool, iexp: U32, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, ns: NumScan) -> LStep:
  match is_flt ns:
    case True{} NumScan{lo, hi, _, _, fexp, rest}: lex_num_flt_tail(hi, lo, iexp, fexp, rest, stk, depth, line, rev, syms)
    case False{} NumScan{val, _, _, _, _, rest}: LNext{rest, stk, False{}, depth, line, Con{Tok{TkNum{val}, line}, rev}, syms}
def lex_num_dec_if(is_e: Bool, hi: U32, val: U32, iexp: U32, rc: Char, +rt: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, is_nat: Bool) -> LStep:
  match is_e:
    case True{}: lex_num_exp_start(hi, val, iexp, 0, rt, stk, depth, line, rev, syms)
    case False{}: LNext{Bool.pick(String, is_nat, rt, SCon{rc, rt}), stk, False{}, depth, line, Con{Tok{TkNum{val}, line}, rev}, syms}
def lex_num_dec_tail(hi: U32, val: U32, sig: U32, iexp: U32, +rc: Char, +rt: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, is_flt: Bool, is_nat: Bool) -> LStep:
  match is_flt:
    case True{}: lex_num_done(True{}, iexp, stk, depth, line, rev, syms, lex_scfrac_go(rt, True{}, Chr{0}, val, hi, sig, 0, 0))
    case False{}:
      +ru = Char.to_u32(rc)
      is_e = Bool.and(Bool.or(U32.is_eq(ru, 101), U32.is_eq(ru, 69)), lex_has_exp_start(rt))
      lex_num_dec_if(is_e, hi, val, iexp, rc, rt, stk, depth, line, rev, syms, is_nat)
def lex_num_dec(stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, ns: NumScan) -> LStep:
  match ns:
    case NumScan{val, _, _, _, _, SNil{}}: LNext{SNil{}, stk, False{}, depth, line, Con{Tok{TkNum{val}, line}, rev}, syms}
    case NumScan{val, hi, _, sig, iexp, SCon{+rc, +rt}}:
      +ru = Char.to_u32(rc)
      lex_num_dec_tail(hi, val, sig, iexp, rc, rt, stk, depth, line, rev, syms, Bool.and(U32.is_eq(ru, 46), lex_is_digit(lex_peek_u32(rt))), U32.is_eq(ru, 110))
def lex_num_if(+u: U32, t: String, t_tail: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, hx: Bool) -> LStep:
  match hx:
    case True{}: lex_num_done(False{}, 0, stk, depth, line, rev, syms, lex_scnum_go(t_tail, True{}, Chr{0}, True{}, 0, 0, 0, 0, 0))
    case False{}:
      +d = U32.sub(u, 48)
      lex_num_dec(stk, depth, line, rev, syms, lex_scnum_go(t, True{}, Chr{0}, False{}, d, 0, 1, Bool.pick(U32, U32.is_gt(d, 0), 1, 0), 0))
def lex_num_start(+u: U32, t: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match t:
    case SNil{}: lex_num_dec(stk, depth, line, rev, syms, NumScan{U32.sub(u, 48), 0, 1, 1, 0, SNil{}})
    case SCon{+c2, +r}:
      +u2 = Char.to_u32(c2)
      lex_num_if(u, SCon{c2, r}, r, stk, depth, line, rev, syms, Bool.and(U32.is_eq(u, 48), Bool.or(U32.is_eq(u2, 120), U32.is_eq(u2, 88))))
def lex_str_done(stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, sc: StrScan) -> LStep:
  match sc:
    case StrScan{val, rest, True{}}: LNext{rest, stk, False{}, depth, line, Con{Tok{TkStr{val}, line}, rev}, syms}
    case StrScan{_, _, False{}}: LDone{LexRes{Nil{}, syms, "unterminated string literal"}}
def lex_chr_uni_done(stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, ns: NumScan) -> LStep:
  match ns:
    case NumScan{val, _, _, _, _, SCon{Chr{125}, SCon{Chr{39}, t2}}}: LNext{t2, stk, False{}, depth, line, Con{Tok{TkChr{val}, line}, rev}, syms}
    case _: LDone{LexRes{Nil{}, syms, "unterminated char escape"}}
def lex_tok_chr(t: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match t:
    case SCon{Chr{92}, SCon{Chr{117}, SCon{Chr{123}, t3}}}: lex_chr_uni_done(stk, depth, line, rev, syms, lex_scnum_go(t3, True{}, Chr{0}, True{}, 0, 0, 0, 0, 0))
    case SCon{Chr{92}, SCon{ec, SCon{_, t3}}}: LNext{t3, stk, False{}, depth, line, Con{Tok{TkChr{lex_unesc(Char.to_u32(ec))}, line}, rev}, syms}
    case SCon{Chr{92}, _}: LDone{LexRes{Nil{}, syms, "unterminated char escape"}}
    case SCon{c1, SCon{_, t2}}: LNext{t2, stk, False{}, depth, line, Con{Tok{TkChr{Char.to_u32(c1)}, line}, rev}, syms}
    case _: LDone{LexRes{Nil{}, syms, "unterminated char literal"}}
def lex_dot_op(t: String) -> U32:
  match t:
    case SCon{c1, t1}:
      +op = Char.to_u32(c1)
      +is_op = Bool.or(U32.is_eq(op, 38), Bool.or(U32.is_eq(op, 124), U32.is_eq(op, 94)))
      Bool.pick(U32, Bool.and(is_op, U32.is_eq(lex_peek_u32(t1), 46)), op, 0)
    case SNil{}: 0
def lex_sym_unsafe(+u: U32, t: String, +stk: List<&2, U32>, +depth: U32, +line: U32, +rev: List<&2, Tok>, +syms: SymTab, is_u: Bool) -> LStep:
  match t is_u:
    case _ True{}: LNext{String.drop(t, 6n), stk, False{}, depth, line, Con{Tok{TkKw{17}, line}, rev}, syms}
    case SNil{} False{}: LNext{SNil{}, stk, False{}, lex_depth_delta(u, depth), line, Con{Tok{TkSym{u}, line}, rev}, syms}
    case SCon{+c2, +t2} False{}:
      +u2 = Char.to_u32(c2)
      +dop = Bool.pick(U32, U32.is_eq(u, 46), lex_dot_op(SCon{c2, t2}), Bool.pick(U32, Bool.and(U32.is_eq(u, 60), Bool.and(U32.is_eq(u2, 38), U32.is_eq(lex_peek_u32(t2), 62))), 272, 0))
      +s2 = lex_sym2(u, u2)
      Bool.pick(LStep, U32.is_gt(dop, 0), LNext{String.drop(t2, 1n), stk, False{}, depth, line, Con{Tok{TkSym{dop}, line}, rev}, syms},
      Bool.pick(LStep, U32.is_zero(s2), LNext{SCon{c2, t2}, stk, False{}, lex_depth_delta(u, depth), line, Con{Tok{TkSym{u}, line}, rev}, syms}, LNext{t2, stk, False{}, depth, line, Con{Tok{TkSym{s2}, line}, rev}, syms}))
def lex_tok_val(c: Char, +u: U32, +t: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, alp: Bool, dig: Bool) -> LStep:
  match alp dig:
    case True{} _: lex_ident_done(stk, depth, line, rev, syms, lex_ident_go(t, True{}, Chr{0}, SCon{c, SNil{}}))
    case False{} True{}: lex_num_start(u, t, stk, depth, line, rev, syms)
    case False{} False{}: lex_sym_unsafe(u, t, stk, depth, line, rev, syms, Bool.and(U32.is_eq(u, 64), String.starts_with(t, "unsafe")))
def lex_tok(s: String, stk: List<&2, U32>, +depth: U32, +line: U32, +rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match s:
    case SNil{}: LDone{lex_eof(stk, line, rev, syms)}
    case SCon{Chr{+u}, t}:
      match u:
        case 32: LNext{t, stk, False{}, depth, line, rev, syms}
        case 9: LNext{t, stk, False{}, depth, line, rev, syms}
        case 13: LNext{t, stk, False{}, depth, line, rev, syms}
        case 35: LNext{lex_skip_comment(t), stk, False{}, depth, line, rev, syms}
        case 10:
          +z = U32.is_zero(depth)
          rev2 = Bool.pick(List<&2, Tok>, Bool.and(z, lex_need_nl(rev)), Con{Tok{TkNewline{}, line}, rev}, rev)
          LNext{t, stk, z, depth, U32.add(line, 1), rev2, syms}
        case 34: lex_str_done(stk, depth, line, rev, syms, lex_scan_str(t, SNil{}))
        case 39: lex_tok_chr(t, stk, depth, line, rev, syms)
        case _: lex_tok_val(Chr{u}, u, t, stk, depth, line, rev, syms, lex_is_alpha(u), lex_is_digit(u))
def lex_step_if(s: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, do_bol: Bool) -> LStep:
  match do_bol:
    case True{}: lex_bol_scan(stk, depth, line, rev, syms, lex_count_indent(s, 0))
    case False{}: lex_tok(s, stk, depth, line, rev, syms)
def lex_chunk(fuel: Nat, st: LStep) -> LStep:
  match fuel st:
    case _ LDone{res}: LDone{res}
    case 0n s: s
    case 1n+p LNext{s, stk, bol, +depth, line, rev, syms}: lex_chunk(p, lex_step_if(s, stk, depth, line, rev, syms, Bool.and(bol, U32.is_zero(depth))))
def lex_run(outer: Nat, st: LStep) -> LexRes:
  match outer st:
    case _ LDone{res}: res
    case 0n LNext{_, stk, _, _, line, rev, syms}: lex_eof(stk, line, rev, syms)
    case 1n+p s: lex_run(p, lex_chunk(U32.to_nat(512), s))
def b5k_lex(src: String, syms: SymTab) -> LexRes: lex_run(U32.to_nat(4096), LNext{src, Con{0, Nil{}}, True{}, 0, 1, Nil{}, syms})
