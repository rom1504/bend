# bend5k/lex.bend — Single-Pass Indentation-Aware Lexer
# =====================================================
# Emits TkIndent/TkDedent/TkNewline/TkEof and interns every identifier
# via SymTab so downstream passes only see dense U32 sym IDs.
# Keywords (TkKw): 1=def 2=type 3=law 4=is 5=match 6=case 7=if 8=else
#   9=do 10=return 11=import 12=as 13=for 14=exs 15=where 16=with 17=@unsafe
# Symbols (TkSym): ASCII for 1-char; 256=-> 257==> 258=== 259=!= 260=<=
#   261=>= 262=&& 263=|| 264=++ 265=<> 266=<- 267=&1 268=&2 269=<< 270=>>
type LexRes is Data:
  LexRes{toks: List<&2, Tok>, syms: SymTab, err: String}
type StrScan is Data:
  StrScan{text: String, rest: String, ok: Bool}
type NumScan is Data:
  NumScan{val: U32, cnt: U32, rest: String}
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
        case 101: Bool.pick(U32, String.eq(w, "else"), 8, Bool.pick(U32, String.eq(w, "exs"), 14, 0))
        case 114: Bool.pick(U32, String.eq(w, "return"), 10, 0)
        case 97: Bool.pick(U32, String.eq(w, "as"), 12, 0)
        case 102: Bool.pick(U32, String.eq(w, "for"), 13, 0)
        case 119: Bool.pick(U32, String.eq(w, "where"), 15, Bool.pick(U32, String.eq(w, "with"), 16, 0))
        case _: 0
    case _: 0
def lex_sym2(+a: U32, +b: U32) -> U32:
  match a:
    case 45: Bool.pick(U32, U32.is_eq(b, 62), 256, 0)
    case 61: Bool.pick(U32, U32.is_eq(b, 62), 257, Bool.pick(U32, U32.is_eq(b, 61), 258, 0))
    case 33: Bool.pick(U32, U32.is_eq(b, 61), 259, 0)
    case 60: Bool.pick(U32, U32.is_eq(b, 61), 260, Bool.pick(U32, U32.is_eq(b, 62), 265, Bool.pick(U32, U32.is_eq(b, 45), 266, Bool.pick(U32, U32.is_eq(b, 60), 269, 0))))
    case 62: Bool.pick(U32, U32.is_eq(b, 61), 261, Bool.pick(U32, U32.is_eq(b, 62), 270, 0))
    case 38: Bool.pick(U32, U32.is_eq(b, 38), 262, Bool.pick(U32, U32.is_eq(b, 49), 267, Bool.pick(U32, U32.is_eq(b, 50), 268, 0)))
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
def lex_scan_str(s: String, acc: String) -> StrScan:
  match s:
    case SNil{}: StrScan{"", SNil{}, False{}}
    case SCon{Chr{34}, t}: StrScan{String.reverse(acc), t, True{}}
    case SCon{Chr{92}, SNil{}}: StrScan{"", SNil{}, False{}}
    case SCon{Chr{92}, SCon{ec, t2}}: lex_scan_str(t2, SCon{Char.from_u32(lex_unesc(Char.to_u32(ec))), acc})
    case SCon{c, t}: lex_scan_str(t, SCon{c, acc})
def lex_ident_go(s: String, go: Bool, prev: Char, +acc: String) -> StrScan:
  match s go:
    case rest False{}: StrScan{String.reverse(acc), SCon{prev, rest}, True{}}
    case SNil{} True{}: StrScan{String.reverse(acc), SNil{}, True{}}
    case SCon{+c, +t} True{}:
      +u = Char.to_u32(c)
      +k = Bool.or(lex_is_alnum(u), Bool.and(U32.is_eq(u, 46), lex_is_alpha(lex_peek_u32(t))))
      lex_ident_go(t, k, c, Bool.pick(String, k, SCon{c, acc}, acc))
def lex_scnum_go(s: String, go: Bool, prev: Char, +is_hex: Bool, +val: U32, +cnt: U32) -> NumScan:
  match s go:
    case rest False{}: NumScan{val, cnt, SCon{prev, rest}}
    case SNil{} True{}: NumScan{val, cnt, SNil{}}
    case SCon{+c, t} True{}:
      +u = Char.to_u32(c)
      +ok = Bool.pick(Bool, is_hex, lex_is_hex(u), lex_is_digit(u))
      val2 = Bool.pick(U32, ok, U32.add(U32.mul(val, Bool.pick(U32, is_hex, 16, 10)), Bool.pick(U32, is_hex, lex_hex_val(u), U32.sub(u, 48))), val)
      lex_scnum_go(t, Bool.or(ok, U32.is_eq(u, 95)), c, is_hex, val2, Bool.pick(U32, ok, U32.add(cnt, 1), cnt))
# IEEE-754 F32 Bits from Decimal
def lex_pow10(n: Nat, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: lex_pow10(p, U32.mul(acc, 10))
def lex_f32_run(fuel: Nat, done: Bool, +num: U32, +den: U32, +exp: U32) -> U32:
  match fuel done:
    case 1n+p False{}:
      +q = U32.div(num, den)
      +hi = U32.is_ge(q, 16777216)
      +lo = U32.is_lt(q, 8388608)
      num2 = Bool.pick(U32, Bool.and(Bool.not(hi), lo), U32.shl(num), num)
      den2 = Bool.pick(U32, hi, U32.shl(den), den)
      exp2 = Bool.pick(U32, hi, U32.add(exp, 1), Bool.pick(U32, lo, U32.sub(exp, 1), exp))
      lex_f32_run(p, Bool.not(Bool.or(hi, lo)), num2, den2, exp2)
    case _ _: U32.or(U32.shln(exp, 23n), U32.and(U32.div(num, den), 8388607))
def lex_f32_bits_if(ip: U32, fp: U32, fc: U32, zero: Bool) -> U32:
  match zero:
    case True{}: 0
    case False{}:
      +den = lex_pow10(U32.to_nat(U32.min(fc, 6)), 1)
      lex_f32_run(40n, False{}, U32.add(U32.mul(ip, den), fp), den, 150)
def lex_f32_bits(+ip: U32, +fp: U32, fc: U32) -> U32: lex_f32_bits_if(ip, fp, fc, Bool.and(U32.is_zero(ip), U32.is_zero(fp)))
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
def lex_num_done(is_flt: Bool, ip: U32, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, ns: NumScan) -> LStep:
  NumScan{+val, fc, rest} = ns
  LNext{rest, stk, False{}, depth, line, Con{Tok{Bool.pick(TokKind, is_flt, TkFlt{lex_f32_bits(ip, val, fc)}, TkNum{val}), line}, rev}, syms}
def lex_num_dec_tail(val: U32, rc: Char, +rt: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, is_flt: Bool, is_nat: Bool) -> LStep:
  match is_flt:
    case True{}: lex_num_done(True{}, val, stk, depth, line, rev, syms, lex_scnum_go(rt, True{}, Chr{0}, False{}, 0, 0))
    case False{}: LNext{Bool.pick(String, is_nat, rt, SCon{rc, rt}), stk, False{}, depth, line, Con{Tok{TkNum{val}, line}, rev}, syms}
def lex_num_dec(stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, ns: NumScan) -> LStep:
  match ns:
    case NumScan{val, _, SNil{}}: LNext{SNil{}, stk, False{}, depth, line, Con{Tok{TkNum{val}, line}, rev}, syms}
    case NumScan{val, _, SCon{+rc, +rt}}:
      +ru = Char.to_u32(rc)
      lex_num_dec_tail(val, rc, rt, stk, depth, line, rev, syms, Bool.and(U32.is_eq(ru, 46), lex_is_digit(lex_peek_u32(rt))), U32.is_eq(ru, 110))
def lex_num_if(u: U32, t: String, t_tail: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, hx: Bool) -> LStep:
  match hx:
    case True{}: lex_num_done(False{}, 0, stk, depth, line, rev, syms, lex_scnum_go(t_tail, True{}, Chr{0}, True{}, 0, 0))
    case False{}: lex_num_dec(stk, depth, line, rev, syms, lex_scnum_go(t, True{}, Chr{0}, False{}, U32.sub(u, 48), 1))
def lex_num_start(+u: U32, t: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match t:
    case SNil{}: lex_num_dec(stk, depth, line, rev, syms, NumScan{U32.sub(u, 48), 1, SNil{}})
    case SCon{+c2, +r}:
      +u2 = Char.to_u32(c2)
      lex_num_if(u, SCon{c2, r}, r, stk, depth, line, rev, syms, Bool.and(U32.is_eq(u, 48), Bool.or(U32.is_eq(u2, 120), U32.is_eq(u2, 88))))
def lex_str_done(stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, sc: StrScan) -> LStep:
  match sc:
    case StrScan{val, rest, True{}}: LNext{rest, stk, False{}, depth, line, Con{Tok{TkStr{val}, line}, rev}, syms}
    case StrScan{_, _, False{}}: LDone{LexRes{Nil{}, syms, "unterminated string literal"}}
def lex_tok_chr(t: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match t:
    case SCon{Chr{92}, SCon{ec, SCon{_, t3}}}: LNext{t3, stk, False{}, depth, line, Con{Tok{TkChr{lex_unesc(Char.to_u32(ec))}, line}, rev}, syms}
    case SCon{Chr{92}, _}: LDone{LexRes{Nil{}, syms, "unterminated char escape"}}
    case SCon{c1, SCon{_, t2}}: LNext{t2, stk, False{}, depth, line, Con{Tok{TkChr{Char.to_u32(c1)}, line}, rev}, syms}
    case _: LDone{LexRes{Nil{}, syms, "unterminated char literal"}}
def lex_sym_unsafe(+u: U32, t: String, +stk: List<&2, U32>, +depth: U32, +line: U32, +rev: List<&2, Tok>, +syms: SymTab, is_u: Bool) -> LStep:
  match t is_u:
    case _ True{}: LNext{String.drop(t, 6n), stk, False{}, depth, line, Con{Tok{TkKw{17}, line}, rev}, syms}
    case SNil{} False{}: LNext{SNil{}, stk, False{}, lex_depth_delta(u, depth), line, Con{Tok{TkSym{u}, line}, rev}, syms}
    case SCon{+c2, +t2} False{}:
      +s2 = lex_sym2(u, Char.to_u32(c2))
      Bool.pick(LStep, U32.is_zero(s2), LNext{SCon{c2, t2}, stk, False{}, lex_depth_delta(u, depth), line, Con{Tok{TkSym{u}, line}, rev}, syms}, LNext{t2, stk, False{}, depth, line, Con{Tok{TkSym{s2}, line}, rev}, syms})
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
