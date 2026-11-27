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
  LNext{s: String, stk: List<&2, U32>, bol: Bool, sp: Bool, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab}
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
def lex_is_valid_esc(+u: U32) -> Bool:
  Bool.or(Bool.or(U32.is_eq(u, 48), U32.is_eq(u, 114)),
  Bool.or(Bool.or(U32.is_eq(u, 116), U32.is_eq(u, 110)),
  Bool.or(U32.is_eq(u, 92), Bool.or(U32.is_eq(u, 39), U32.is_eq(u, 34)))))
def lex_is_sp(+u: U32) -> Bool:
  Bool.or(Bool.or(U32.is_eq(u, 32), U32.is_eq(u, 9)), Bool.or(U32.is_eq(u, 10), U32.is_eq(u, 13)))
def lex_digits_no_n(fuel: Nat, go: Bool, s: String) -> Bool:
  match fuel go s:
    case 0n _ _: False{}
    case _ False{} _: False{}
    case _ True{} SNil{}: True{}
    case 1n+p True{} SCon{Chr{+u}, t}:
      Bool.pick(Bool, Bool.or(lex_is_digit(u), U32.is_eq(u, 95)), lex_digits_no_n(p, True{}, t), Bool.not(U32.is_eq(u, 110)))
def lex_nat_plus_u32_bad(s: String) -> Bool:
  match s:
    case SCon{Chr{u}, t}: lex_digits_no_n(16n, lex_is_digit(u), t)
    case SNil{}: False{}
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
    case SCon{ec, t} 1:
      +eu = Char.to_u32(ec)
      Bool.pick(StrScan, lex_is_valid_esc(eu), lex_scan_str_go(t, 0, 0, SCon{Char.from_u32(lex_unesc(eu)), acc}), StrScan{"", SNil{}, False{}})
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
# IEEE-754 F32 Bits from Decimal (exact single-rounding via F32.read)
def lex_f32_read_mb(m: Maybe<&2, F32>) -> U32:
  match m:
    case None{}: 0
    case Some{f}: F32.bits(f)
def lex_f32_read(s: String) -> U32: lex_f32_read_mb(F32.read(s))
def lex_has_exp_start(s: String) -> Bool:
  match s:
    case SCon{Chr{+u}, t}:
      Bool.pick(Bool, Bool.or(U32.is_eq(u, 43), U32.is_eq(u, 45)), lex_is_digit(lex_peek_u32(t)), lex_is_digit(u))
    case SNil{}: False{}
def lex_if(-T: Data, cond: Bool, t: Unit -> T, f: Unit -> T) -> T:
  match cond:
    case True{}: t(Unit{})
    case False{}: f(Unit{})
def lex_scan_flt_go(s: String, mode: U32, +acc: String) -> StrScan:
  match s mode:
    case SNil{} _: StrScan{String.reverse(acc), SNil{}, True{}}
    case SCon{Chr{+u}, +t} 0:
      lex_if(StrScan, lex_is_digit(u), _ => lex_scan_flt_go(t, 0, SCon{Chr{u}, acc}),
      _ => lex_if(StrScan, U32.is_eq(u, 95), _ => lex_scan_flt_go(t, 0, acc),
      _ => lex_if(StrScan, Bool.and(U32.is_eq(u, 46), lex_is_digit(lex_peek_u32(t))), _ => lex_scan_flt_go(t, 1, SCon{Chr{46}, acc}),
      _ => lex_if(StrScan, Bool.and(Bool.or(U32.is_eq(u, 101), U32.is_eq(u, 69)), lex_has_exp_start(t)), _ => lex_scan_flt_go(t, 2, SCon{Chr{101}, acc}),
      _ => StrScan{String.reverse(acc), SCon{Chr{u}, t}, True{}}))))
    case SCon{Chr{+u}, +t} 1:
      lex_if(StrScan, lex_is_digit(u), _ => lex_scan_flt_go(t, 1, SCon{Chr{u}, acc}),
      _ => lex_if(StrScan, U32.is_eq(u, 95), _ => lex_scan_flt_go(t, 1, acc),
      _ => lex_if(StrScan, Bool.and(Bool.or(U32.is_eq(u, 101), U32.is_eq(u, 69)), lex_has_exp_start(t)), _ => lex_scan_flt_go(t, 2, SCon{Chr{101}, acc}),
      _ => StrScan{String.reverse(acc), SCon{Chr{u}, t}, True{}})))
    case SCon{Chr{+u}, +t} 2:
      lex_if(StrScan, Bool.or(U32.is_eq(u, 43), U32.is_eq(u, 45)), _ => lex_scan_flt_go(t, 3, SCon{Chr{u}, acc}),
      _ => lex_if(StrScan, lex_is_digit(u), _ => lex_scan_flt_go(t, 3, SCon{Chr{u}, acc}),
      _ => StrScan{String.reverse(acc), SCon{Chr{u}, t}, True{}}))
    case SCon{Chr{+u}, +t} _:
      lex_if(StrScan, lex_is_digit(u), _ => lex_scan_flt_go(t, 3, SCon{Chr{u}, acc}),
      _ => lex_if(StrScan, U32.is_eq(u, 95), _ => lex_scan_flt_go(t, 3, acc),
      _ => StrScan{String.reverse(acc), SCon{Chr{u}, t}, True{}}))
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
  LNext{s, stk2, False{}, True{}, depth, line, rev2, syms}
def lex_bol_scan(+stk: List<&2, U32>, +depth: U32, +line: U32, +rev: List<&2, Tok>, +syms: SymTab, sc: IndentScan) -> LStep:
  match sc:
    case IndentScan{_, SNil{}}: LDone{lex_eof(stk, line, rev, syms)}
    case IndentScan{+col, SCon{Chr{+u}, +t}}:
      match u:
        case 10: LNext{t, stk, True{}, True{}, depth, U32.add(line, 1), rev, syms}
        case 35: LNext{lex_skip_comment(t), stk, True{}, True{}, depth, line, rev, syms}
        case _:
          +s1: String = SCon{Chr{u}, t}
          Bool.pick(LStep, U32.is_gt(col, lex_stk_top(stk)), LNext{s1, Con{col, stk}, False{}, True{}, depth, line, Con{Tok{TkIndent{}, line}, rev}, syms}, lex_bol_ded(s1, depth, line, syms, lex_dedent_go(stk, True{}, 0, col, line, rev)))
def lex_ident_intern(rest: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, sr: SymRes) -> LStep:
  SymRes{syms2, id} = sr
  LNext{rest, stk, False{}, False{}, depth, line, Con{Tok{TkIdent{id}, line}, rev}, syms2}
def lex_ident_kw(word: String, rest: String, kw: U32, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, is_id: Bool) -> LStep:
  match is_id:
    case True{}: lex_ident_intern(rest, stk, depth, line, rev, symtab_intern(syms, word))
    case False{}: LNext{rest, stk, False{}, False{}, depth, line, Con{Tok{TkKw{kw}, line}, rev}, syms}
def lex_ident_done(stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, sc: StrScan) -> LStep:
  StrScan{+word, rest, _} = sc
  +kw = lex_kw_code(word)
  lex_ident_kw(word, rest, kw, stk, depth, line, rev, syms, U32.is_zero(kw))
def lex_flt_emit(stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, sc: StrScan) -> LStep:
  StrScan{fstr, rest, _} = sc
  LNext{rest, stk, False{}, False{}, depth, line, Con{Tok{TkFlt{lex_f32_read(fstr)}, line}, rev}, syms}
def lex_num_nat_emit(val: U32, rt: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, +syms: SymTab) -> LStep:
  match rt:
    case SCon{Chr{43}, SCon{Chr{43}, rt2}}: LNext{rt2, stk, False{}, False{}, depth, line, Con{Tok{TkSym{278}, line}, Con{Tok{TkNum{val}, line}, rev}}, syms}
    case SCon{Chr{43}, +rt1}:
      Bool.pick(LStep, lex_nat_plus_u32_bad(rt1), LDone{LexRes{Nil{}, syms, "nat successor requires Nat, not U32"}},
        LNext{rt1, stk, False{}, False{}, depth, line, Con{Tok{TkSym{277}, line}, Con{Tok{TkNum{val}, line}, rev}}, syms})
    case other: LNext{other, stk, False{}, False{}, depth, line, Con{Tok{TkNum{val}, line}, rev}, syms}
def lex_num_dec_tail_k(is_f: Bool, ovf: Bool, raw: String, val: U32, rc: Char, +rt: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, +syms: SymTab, is_nat: Bool) -> LStep:
  match is_f is_nat:
    case True{} _: lex_flt_emit(stk, depth, line, rev, syms, lex_scan_flt_go(raw, 0, SNil{}))
    case False{} True{}: lex_num_nat_emit(val, rt, stk, depth, line, rev, syms)
    case False{} False{}:
      Bool.pick(LStep, ovf, LDone{LexRes{Nil{}, syms, "u32 literal overflow"}},
        LNext{SCon{rc, rt}, stk, False{}, False{}, depth, line, Con{Tok{TkNum{val}, line}, rev}, syms})
def lex_num_dec_tail(ovf: Bool, raw: String, val: U32, +rc: Char, +rt: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, +syms: SymTab, is_flt: Bool, is_nat: Bool) -> LStep:
  +ru = Char.to_u32(rc)
  +is_e = Bool.and(Bool.or(U32.is_eq(ru, 101), U32.is_eq(ru, 69)), lex_has_exp_start(rt))
  lex_num_dec_tail_k(Bool.or(is_flt, is_e), ovf, raw, val, rc, rt, stk, depth, line, rev, syms, is_nat)
def lex_num_dec(raw: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, +syms: SymTab, ns: NumScan) -> LStep:
  match ns:
    case NumScan{val, hi, _, _, exp, SNil{}}:
      ovf = Bool.or(U32.is_gt(hi, 0), U32.is_gt(exp, 0))
      Bool.pick(LStep, ovf, LDone{LexRes{Nil{}, syms, "u32 literal overflow"}},
        LNext{SNil{}, stk, False{}, False{}, depth, line, Con{Tok{TkNum{val}, line}, rev}, syms})
    case NumScan{val, hi, _, _, exp, SCon{+rc, +rt}}:
      +ru = Char.to_u32(rc)
      ovf = Bool.or(U32.is_gt(hi, 0), U32.is_gt(exp, 0))
      lex_num_dec_tail(ovf, raw, val, rc, rt, stk, depth, line, rev, syms, Bool.and(U32.is_eq(ru, 46), lex_is_digit(lex_peek_u32(rt))), U32.is_eq(ru, 110))
def lex_num_if(+u: U32, +t: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, hx: Bool) -> LStep:
  match hx:
    case True{}: LDone{LexRes{Nil{}, syms, "invalid hex literal"}}
    case False{}:
      +d = U32.sub(u, 48)
      lex_num_dec(SCon{Chr{u}, t}, stk, depth, line, rev, syms, lex_scnum_go(t, True{}, Chr{0}, False{}, d, 0, 1, Bool.pick(U32, U32.is_gt(d, 0), 1, 0), 0))
def lex_num_start(+u: U32, t: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match t:
    case SNil{}: lex_num_dec(SCon{Chr{u}, SNil{}}, stk, depth, line, rev, syms, NumScan{U32.sub(u, 48), 0, 1, 1, 0, SNil{}})
    case SCon{+c2, +r}:
      +u2 = Char.to_u32(c2)
      lex_num_if(u, SCon{c2, r}, stk, depth, line, rev, syms, Bool.and(U32.is_eq(u, 48), Bool.or(U32.is_eq(u2, 120), U32.is_eq(u2, 88))))
def lex_str_done(stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, sc: StrScan) -> LStep:
  match sc:
    case StrScan{val, rest, True{}}: LNext{rest, stk, False{}, False{}, depth, line, Con{Tok{TkStr{val}, line}, rev}, syms}
    case StrScan{_, _, False{}}: LDone{LexRes{Nil{}, syms, "unterminated or invalid string literal"}}
def lex_chr_uni_done(stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, ns: NumScan) -> LStep:
  match ns:
    case NumScan{val, _, _, _, _, SCon{Chr{125}, SCon{Chr{39}, t2}}}: LNext{t2, stk, False{}, False{}, depth, line, Con{Tok{TkChr{val}, line}, rev}, syms}
    case _: LDone{LexRes{Nil{}, syms, "unterminated char escape"}}
def lex_tok_chr(t: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match t:
    case SCon{Chr{92}, SCon{Chr{117}, SCon{Chr{123}, t3}}}: lex_chr_uni_done(stk, depth, line, rev, syms, lex_scnum_go(t3, True{}, Chr{0}, True{}, 0, 0, 0, 0, 0))
    case SCon{Chr{92}, SCon{ec, SCon{_, t3}}}: LNext{t3, stk, False{}, False{}, depth, line, Con{Tok{TkChr{lex_unesc(Char.to_u32(ec))}, line}, rev}, syms}
    case SCon{Chr{92}, _}: LDone{LexRes{Nil{}, syms, "unterminated char escape"}}
    case SCon{c1, SCon{_, t2}}: LNext{t2, stk, False{}, False{}, depth, line, Con{Tok{TkChr{Char.to_u32(c1)}, line}, rev}, syms}
    case _: LDone{LexRes{Nil{}, syms, "unterminated char literal"}}
def lex_dot_op(t: String) -> U32:
  match t:
    case SCon{c1, t1}:
      +op = Char.to_u32(c1)
      +code = Bool.pick(U32, U32.is_eq(op, 38), 273, Bool.pick(U32, U32.is_eq(op, 124), 274, Bool.pick(U32, U32.is_eq(op, 94), 275, 0)))
      Bool.pick(U32, Bool.and(U32.is_gt(code, 0), U32.is_eq(lex_peek_u32(t1), 46)), code, 0)
    case SNil{}: 0
def lex_sym_unsafe(+u: U32, t: String, +stk: List<&2, U32>, +sp: Bool, +depth: U32, +line: U32, +rev: List<&2, Tok>, +syms: SymTab, is_u: Bool) -> LStep:
  match t is_u:
    case _ True{}: LNext{String.drop(t, 6n), stk, False{}, False{}, depth, line, Con{Tok{TkKw{17}, line}, rev}, syms}
    case SNil{} False{}: LNext{SNil{}, stk, False{}, False{}, lex_depth_delta(u, depth), line, Con{Tok{TkSym{u}, line}, rev}, syms}
    case SCon{+c2, +t2} False{}:
      +u2 = Char.to_u32(c2)
      +dop = Bool.pick(U32, U32.is_eq(u, 46), lex_dot_op(SCon{c2, t2}), Bool.pick(U32, Bool.and(U32.is_eq(u, 60), Bool.and(U32.is_eq(u2, 38), U32.is_eq(lex_peek_u32(t2), 62))), 272, 0))
      +s2 = lex_sym2(u, u2)
      +u_emit = Bool.pick(U32, Bool.and(U32.is_eq(u, 43), Bool.and(sp, lex_is_sp(u2))), 276, u)
      Bool.pick(LStep, U32.is_gt(dop, 0), LNext{String.drop(t2, 1n), stk, False{}, False{}, depth, line, Con{Tok{TkSym{dop}, line}, rev}, syms},
      Bool.pick(LStep, U32.is_zero(s2), LNext{SCon{c2, t2}, stk, False{}, False{}, lex_depth_delta(u, depth), line, Con{Tok{TkSym{u_emit}, line}, rev}, syms}, LNext{t2, stk, False{}, False{}, depth, line, Con{Tok{TkSym{s2}, line}, rev}, syms}))
def lex_tok_val(c: Char, +u: U32, +t: String, stk: List<&2, U32>, sp: Bool, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, alp: Bool, dig: Bool) -> LStep:
  match alp dig:
    case True{} _: lex_ident_done(stk, depth, line, rev, syms, lex_ident_go(t, True{}, Chr{0}, SCon{c, SNil{}}))
    case False{} True{}: lex_num_start(u, t, stk, depth, line, rev, syms)
    case False{} False{}: lex_sym_unsafe(u, t, stk, sp, depth, line, rev, syms, Bool.and(U32.is_eq(u, 64), String.starts_with(t, "unsafe")))
def lex_tok(s: String, stk: List<&2, U32>, sp: Bool, +depth: U32, +line: U32, +rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match s:
    case SNil{}: LDone{lex_eof(stk, line, rev, syms)}
    case SCon{Chr{+u}, t}:
      match u:
        case 32: LNext{t, stk, False{}, True{}, depth, line, rev, syms}
        case 9: LNext{t, stk, False{}, True{}, depth, line, rev, syms}
        case 13: LNext{t, stk, False{}, True{}, depth, line, rev, syms}
        case 35: LNext{lex_skip_comment(t), stk, False{}, True{}, depth, line, rev, syms}
        case 10:
          +z = U32.is_zero(depth)
          rev2 = Bool.pick(List<&2, Tok>, Bool.and(z, lex_need_nl(rev)), Con{Tok{TkNewline{}, line}, rev}, rev)
          LNext{t, stk, z, True{}, depth, U32.add(line, 1), rev2, syms}
        case 34: lex_str_done(stk, depth, line, rev, syms, lex_scan_str(t, SNil{}))
        case 39: lex_tok_chr(t, stk, depth, line, rev, syms)
        case _: lex_tok_val(Chr{u}, u, t, stk, sp, depth, line, rev, syms, lex_is_alpha(u), lex_is_digit(u))
def lex_step_if(s: String, stk: List<&2, U32>, sp: Bool, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, do_bol: Bool) -> LStep:
  match do_bol:
    case True{}: lex_bol_scan(stk, depth, line, rev, syms, lex_count_indent(s, 0))
    case False{}: lex_tok(s, stk, sp, depth, line, rev, syms)
def lex_chunk(fuel: Nat, st: LStep) -> LStep:
  match fuel st:
    case _ LDone{res}: LDone{res}
    case 0n s: s
    case 1n+p LNext{s, stk, bol, sp, +depth, line, rev, syms}: lex_chunk(p, lex_step_if(s, stk, sp, depth, line, rev, syms, Bool.and(bol, U32.is_zero(depth))))
def lex_run(outer: Nat, st: LStep) -> LexRes:
  match outer st:
    case _ LDone{res}: res
    case 0n LNext{_, stk, _, _, _, line, rev, syms}: lex_eof(stk, line, rev, syms)
    case 1n+p s: lex_run(p, lex_chunk(U32.to_nat(512), s))
def b5k_lex(src: String, syms: SymTab) -> LexRes: lex_run(U32.to_nat(4096), LNext{src, Con{0, Nil{}}, True{}, True{}, 0, 1, Nil{}, syms})
