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
type IdStep is Data:
  IdDone{res: StrScan}
  IdNext{s: String, acc: String}
type NumStep is Data:
  NmDone{res: NumScan}
  NmNext{s: String, val: U32, cnt: U32}
type DedStep is Data:
  DdDone{res: IndentRes}
  DdNext{stk: List<&2, U32>, rev: List<&2, Tok>}
type F32Step is Data:
  F32Done{bits: U32}
  F32Next{num: U32, den: U32, exp: U32}
type LStep is Data:
  LDone{res: LexRes}
  LNext{s: String, stk: List<&2, U32>, bol: Bool, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab}

# Character & Table Helpers
# -------------------------
def lex_is_digit(+c: U32) -> Bool:
  Bool.and(U32.is_ge(c, 48), U32.is_le(c, 57))
def lex_is_hex(+c: U32) -> Bool:
  Bool.or(lex_is_digit(c), Bool.or(Bool.and(U32.is_ge(c, 97), U32.is_le(c, 102)), Bool.and(U32.is_ge(c, 65), U32.is_le(c, 70))))
def lex_hex_val(+c: U32) -> U32:
  Bool.pick(U32, lex_is_digit(c), U32.sub(c, 48), Bool.pick(U32, U32.is_ge(c, 97), U32.sub(c, 87), U32.sub(c, 55)))
def lex_is_alpha(+c: U32) -> Bool:
  Bool.or(Bool.or(Bool.and(U32.is_ge(c, 97), U32.is_le(c, 122)), Bool.and(U32.is_ge(c, 65), U32.is_le(c, 90))), U32.is_eq(c, 95))
def lex_is_alnum(+c: U32) -> Bool:
  Bool.or(lex_is_alpha(c), lex_is_digit(c))
def lex_peek_alpha(s: String) -> Bool:
  match s:
    case SNil{}: False{}
    case SCon{c, _}: lex_is_alpha(Char.to_u32(c))
def lex_peek_digit(s: String) -> Bool:
  match s:
    case SNil{}: False{}
    case SCon{c, _}: lex_is_digit(Char.to_u32(c))
def lex_unesc(+u: U32) -> U32:
  r0 = Bool.pick(U32, U32.is_eq(u, 48), 0, u)
  r1 = Bool.pick(U32, U32.is_eq(u, 114), 13, r0)
  r2 = Bool.pick(U32, U32.is_eq(u, 116), 9, r1)
  Bool.pick(U32, U32.is_eq(u, 110), 10, r2)
def lex_kw_code(+w: String) -> U32:
  r = Bool.pick(U32, String.eq(w, "with"), 16, 0)
  r = Bool.pick(U32, String.eq(w, "where"), 15, r)
  r = Bool.pick(U32, String.eq(w, "exs"), 14, r)
  r = Bool.pick(U32, String.eq(w, "for"), 13, r)
  r = Bool.pick(U32, String.eq(w, "as"), 12, r)
  r = Bool.pick(U32, String.eq(w, "import"), 11, r)
  r = Bool.pick(U32, String.eq(w, "return"), 10, r)
  r = Bool.pick(U32, String.eq(w, "do"), 9, r)
  r = Bool.pick(U32, String.eq(w, "else"), 8, r)
  r = Bool.pick(U32, String.eq(w, "if"), 7, r)
  r = Bool.pick(U32, String.eq(w, "case"), 6, r)
  r = Bool.pick(U32, String.eq(w, "match"), 5, r)
  r = Bool.pick(U32, String.eq(w, "is"), 4, r)
  r = Bool.pick(U32, String.eq(w, "law"), 3, r)
  r = Bool.pick(U32, String.eq(w, "type"), 2, r)
  Bool.pick(U32, String.eq(w, "def"), 1, r)
def lex_sym2(+a: U32, +b: U32) -> U32:
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 62), U32.is_eq(b, 62)), 270, 0)
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 60), U32.is_eq(b, 60)), 269, r)
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 38), U32.is_eq(b, 50)), 268, r)
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 38), U32.is_eq(b, 49)), 267, r)
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 60), U32.is_eq(b, 45)), 266, r)
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 60), U32.is_eq(b, 62)), 265, r)
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 43), U32.is_eq(b, 43)), 264, r)
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 124), U32.is_eq(b, 124)), 263, r)
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 38), U32.is_eq(b, 38)), 262, r)
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 62), U32.is_eq(b, 61)), 261, r)
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 60), U32.is_eq(b, 61)), 260, r)
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 33), U32.is_eq(b, 61)), 259, r)
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 61), U32.is_eq(b, 61)), 258, r)
  r = Bool.pick(U32, Bool.and(U32.is_eq(a, 61), U32.is_eq(b, 62)), 257, r)
  Bool.pick(U32, Bool.and(U32.is_eq(a, 45), U32.is_eq(b, 62)), 256, r)
def lex_depth_delta(+u: U32, +d: U32) -> U32:
  op = Bool.or(U32.is_eq(u, 40), Bool.or(U32.is_eq(u, 91), U32.is_eq(u, 123)))
  cl = Bool.or(U32.is_eq(u, 41), Bool.or(U32.is_eq(u, 93), U32.is_eq(u, 125)))
  Bool.pick(U32, op, U32.add(d, 1), Bool.pick(U32, Bool.and(cl, U32.is_gt(d, 0)), U32.sub(d, 1), d))

# Sub-Scanners (Pure Safe Self-Recursion)
# ---------------------------------------
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
def lex_ident_step(s: String, +acc: String) -> IdStep:
  match s:
    case SNil{}: IdDone{StrScan{String.reverse(acc), SNil{}, True{}}}
    case SCon{+c, +t}:
      +u = Char.to_u32(c)
      keep = Bool.or(lex_is_alnum(u), Bool.and(U32.is_eq(u, 46), lex_peek_alpha(t)))
      Bool.pick(IdStep, keep, IdNext{t, SCon{c, acc}}, IdDone{StrScan{String.reverse(acc), SCon{c, t}, True{}}})
def lex_ident_run(fuel: Nat, st: IdStep) -> StrScan:
  match fuel st:
    case _ IdDone{r}: r
    case 0n IdNext{s, acc}: StrScan{String.reverse(acc), s, True{}}
    case 1n+p IdNext{s, acc}: lex_ident_run(p, lex_ident_step(s, acc))
def lex_scan_ident(+s: String, acc: String) -> StrScan:
  lex_ident_run(Succ{String.length(s)}, IdNext{s, acc})
def lex_dec_step(s: String, +val: U32, +cnt: U32) -> NumStep:
  match s:
    case SNil{}: NmDone{NumScan{val, cnt, SNil{}}}
    case SCon{+c, +t}:
      +u = Char.to_u32(c)
      ustep = Bool.pick(NumStep, U32.is_eq(u, 95), NmNext{t, val, cnt}, NmDone{NumScan{val, cnt, SCon{c, t}}})
      Bool.pick(NumStep, lex_is_digit(u), NmNext{t, U32.add(U32.mul(val, 10), U32.sub(u, 48)), U32.add(cnt, 1)}, ustep)
def lex_dec_run(fuel: Nat, st: NumStep) -> NumScan:
  match fuel st:
    case _ NmDone{r}: r
    case 0n NmNext{s, val, cnt}: NumScan{val, cnt, s}
    case 1n+p NmNext{s, val, cnt}: lex_dec_run(p, lex_dec_step(s, val, cnt))
def lex_scan_dec(+s: String, val: U32, cnt: U32) -> NumScan:
  lex_dec_run(Succ{String.length(s)}, NmNext{s, val, cnt})
def lex_hex_step(s: String, +val: U32, +cnt: U32) -> NumStep:
  match s:
    case SNil{}: NmDone{NumScan{val, cnt, SNil{}}}
    case SCon{+c, +t}:
      +u = Char.to_u32(c)
      ustep = Bool.pick(NumStep, U32.is_eq(u, 95), NmNext{t, val, cnt}, NmDone{NumScan{val, cnt, SCon{c, t}}})
      Bool.pick(NumStep, lex_is_hex(u), NmNext{t, U32.add(U32.mul(val, 16), lex_hex_val(u)), U32.add(cnt, 1)}, ustep)
def lex_hex_run(fuel: Nat, st: NumStep) -> NumScan:
  match fuel st:
    case _ NmDone{r}: r
    case 0n NmNext{s, val, cnt}: NumScan{val, cnt, s}
    case 1n+p NmNext{s, val, cnt}: lex_hex_run(p, lex_hex_step(s, val, cnt))
def lex_scan_hex(+s: String, val: U32, cnt: U32) -> NumScan:
  lex_hex_run(Succ{String.length(s)}, NmNext{s, val, cnt})

# IEEE-754 F32 Bits from Decimal
# ------------------------------
def lex_pow10(n: Nat, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: lex_pow10(p, U32.mul(acc, 10))
def lex_f32_step(+num: U32, +den: U32, +exp: U32) -> F32Step:
  +q = U32.div(num, den)
  lo = Bool.pick(F32Step, U32.is_lt(q, 8388608), F32Next{U32.shl(num), den, U32.sub(exp, 1)}, F32Done{U32.or(U32.shln(exp, 23n), U32.and(q, 8388607))})
  Bool.pick(F32Step, U32.is_ge(q, 16777216), F32Next{num, U32.shl(den), U32.add(exp, 1)}, lo)
def lex_f32_run(fuel: Nat, st: F32Step) -> U32:
  match fuel st:
    case _ F32Done{b}: b
    case 0n F32Next{num, den, exp}: U32.or(U32.shln(exp, 23n), U32.and(U32.div(num, den), 8388607))
    case 1n+p F32Next{num, den, exp}: lex_f32_run(p, lex_f32_step(num, den, exp))
def lex_f32_bits_if(ip: U32, fp: U32, fc: U32, zero: Bool) -> U32:
  match zero:
    case True{}: 0
    case False{}:
      +den = lex_pow10(U32.to_nat(U32.min(fc, 6)), 1)
      lex_f32_run(40n, F32Next{U32.add(U32.mul(ip, den), fp), den, 150})
def lex_f32_bits(+ip: U32, +fp: U32, fc: U32) -> U32:
  lex_f32_bits_if(ip, fp, fc, Bool.and(U32.is_zero(ip), U32.is_zero(fp)))

# Layout Helpers
# --------------
def lex_need_nl(rev: List<&2, Tok>) -> Bool:
  match rev:
    case Nil{}: False{}
    case Con{Tok{k, _}, _}:
      match k:
        case TkNewline{}: False{}
        case TkIndent{}: False{}
        case TkDedent{}: False{}
        case _: True{}
def lex_stk_top(stk: List<&2, U32>) -> U32:
  match stk:
    case Nil{}: 0
    case Con{h, _}: h
def lex_ded_step(stk: List<&2, U32>, col: U32, line: U32, +rev: List<&2, Tok>) -> DedStep:
  match stk:
    case Nil{}: DdDone{IndentRes{Con{0, Nil{}}, rev}}
    case Con{+top, +rest}:
      Bool.pick(DedStep, U32.is_gt(top, col), DdNext{rest, Con{Tok{TkDedent{}, line}, rev}}, DdDone{IndentRes{Con{top, rest}, rev}})
def lex_ded_run(fuel: Nat, +col: U32, +line: U32, st: DedStep) -> IndentRes:
  match fuel st:
    case _ DdDone{r}: r
    case 0n DdNext{stk, rev}: IndentRes{stk, rev}
    case 1n+p DdNext{stk, rev}: lex_ded_run(p, col, line, lex_ded_step(stk, col, line, rev))
def lex_dedent_to(stk: List<&2, U32>, col: U32, line: U32, rev: List<&2, Tok>) -> IndentRes:
  lex_ded_run(64n, col, line, DdNext{stk, rev})
def lex_dedent_all(stk: List<&2, U32>, +line: U32, rev: List<&2, Tok>) -> List<&2, Tok>:
  match stk:
    case Nil{}: rev
    case Con{0, rest}: lex_dedent_all(rest, line, rev)
    case Con{_, rest}: lex_dedent_all(rest, line, Con{Tok{TkDedent{}, line}, rev})

# Main Lexer Step & Loop
# ----------------------
def lex_eof(stk: List<&2, U32>, +line: U32, +rev: List<&2, Tok>, syms: SymTab) -> LexRes:
  rev1 = Bool.pick(List<&2, Tok>, lex_need_nl(rev), Con{Tok{TkNewline{}, line}, rev}, rev)
  rev2 = lex_dedent_all(stk, line, rev1)
  LexRes{b5k_list_rev(Tok, Con{Tok{TkEof{}, line}, rev2}), syms, ""}
def lex_bol_ded(s: String, depth: U32, line: U32, syms: SymTab, ir: IndentRes) -> LStep:
  IndentRes{stk2, rev2} = ir
  LNext{s, stk2, False{}, depth, line, rev2, syms}
def lex_bol_line(c: Char, t: String, +col: U32, +stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, nl: Bool, hash: Bool, gt: Bool) -> LStep:
  match nl hash gt:
    case True{} _ _: LNext{t, stk, True{}, depth, U32.add(line, 1), rev, syms}
    case False{} True{} _: LNext{lex_skip_comment(t), stk, True{}, depth, line, rev, syms}
    case False{} False{} True{}: LNext{SCon{c, t}, Con{col, stk}, False{}, depth, line, Con{Tok{TkIndent{}, line}, rev}, syms}
    case False{} False{} False{}: lex_bol_ded(SCon{c, t}, depth, line, syms, lex_dedent_to(stk, col, line, rev))
def lex_bol_scan(+stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, sc: IndentScan) -> LStep:
  IndentScan{+col, rest} = sc
  match rest:
    case SNil{}: LDone{lex_eof(stk, line, rev, syms)}
    case SCon{+c, t}:
      +u = Char.to_u32(c)
      lex_bol_line(c, t, col, stk, depth, line, rev, syms, U32.is_eq(u, 10), U32.is_eq(u, 35), U32.is_gt(col, lex_stk_top(stk)))
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
def lex_num_hex_done(stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, ns: NumScan) -> LStep:
  NumScan{val, _, rest} = ns
  LNext{rest, stk, False{}, depth, line, Con{Tok{TkNum{val}, line}, rev}, syms}
def lex_num_flt_done(ip: U32, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, ns: NumScan) -> LStep:
  NumScan{fp, fc, rest} = ns
  LNext{rest, stk, False{}, depth, line, Con{Tok{TkFlt{lex_f32_bits(ip, fp, fc)}, line}, rev}, syms}
def lex_num_dec_tail(val: U32, rc: Char, rt: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, is_flt: Bool, is_nat: Bool) -> LStep:
  match is_flt is_nat:
    case True{} _: lex_num_flt_done(val, stk, depth, line, rev, syms, lex_scan_dec(rt, 0, 0))
    case False{} True{}: LNext{rt, stk, False{}, depth, line, Con{Tok{TkNum{val}, line}, rev}, syms}
    case False{} False{}: LNext{SCon{rc, rt}, stk, False{}, depth, line, Con{Tok{TkNum{val}, line}, rev}, syms}
def lex_num_dec_done(stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, ns: NumScan) -> LStep:
  NumScan{val, _, rest} = ns
  match rest:
    case SNil{}: LNext{SNil{}, stk, False{}, depth, line, Con{Tok{TkNum{val}, line}, rev}, syms}
    case SCon{+rc, +rt}:
      +ru = Char.to_u32(rc)
      lex_num_dec_tail(val, rc, rt, stk, depth, line, rev, syms, Bool.and(U32.is_eq(ru, 46), lex_peek_digit(rt)), U32.is_eq(ru, 110))
def lex_num_if(u: U32, t: String, t_tail: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, hx: Bool) -> LStep:
  match hx:
    case True{}: lex_num_hex_done(stk, depth, line, rev, syms, lex_scan_hex(t_tail, 0, 0))
    case False{}: lex_num_dec_done(stk, depth, line, rev, syms, lex_scan_dec(t, U32.sub(u, 48), 1))
def lex_num_start(+u: U32, t: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match t:
    case SNil{}: lex_num_dec_done(stk, depth, line, rev, syms, NumScan{U32.sub(u, 48), 1, SNil{}})
    case SCon{+c2, +r}:
      +u2 = Char.to_u32(c2)
      lex_num_if(u, SCon{c2, r}, r, stk, depth, line, rev, syms, Bool.and(U32.is_eq(u, 48), Bool.or(U32.is_eq(u2, 120), U32.is_eq(u2, 88))))
def lex_str_done(stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, sc: StrScan) -> LStep:
  StrScan{val, rest, ok} = sc
  match ok:
    case True{}: LNext{rest, stk, False{}, depth, line, Con{Tok{TkStr{val}, line}, rev}, syms}
    case False{}: LDone{LexRes{Nil{}, syms, "unterminated string literal"}}
def lex_tok_chr(t: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match t:
    case SNil{}: LDone{LexRes{Nil{}, syms, "unterminated char literal"}}
    case SCon{Chr{92}, SCon{ec, SCon{_, t3}}}: LNext{t3, stk, False{}, depth, line, Con{Tok{TkChr{lex_unesc(Char.to_u32(ec))}, line}, rev}, syms}
    case SCon{Chr{92}, _}: LDone{LexRes{Nil{}, syms, "unterminated char escape"}}
    case SCon{c1, SCon{_, t2}}: LNext{t2, stk, False{}, depth, line, Con{Tok{TkChr{Char.to_u32(c1)}, line}, rev}, syms}
    case SCon{_, SNil{}}: LDone{LexRes{Nil{}, syms, "unterminated char literal"}}
def lex_sym_two(+u: U32, c2: Char, t2: String, s2: U32, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, hit: Bool) -> LStep:
  match hit:
    case True{}: LNext{t2, stk, False{}, depth, line, Con{Tok{TkSym{s2}, line}, rev}, syms}
    case False{}: LNext{SCon{c2, t2}, stk, False{}, lex_depth_delta(u, depth), line, Con{Tok{TkSym{u}, line}, rev}, syms}
def lex_sym_unsafe(+u: U32, t: String, stk: List<&2, U32>, depth: U32, +line: U32, rev: List<&2, Tok>, syms: SymTab, is_u: Bool) -> LStep:
  match t is_u:
    case _ True{}: LNext{String.drop(t, 6n), stk, False{}, depth, line, Con{Tok{TkKw{17}, line}, rev}, syms}
    case SNil{} False{}: LNext{SNil{}, stk, False{}, lex_depth_delta(u, depth), line, Con{Tok{TkSym{u}, line}, rev}, syms}
    case SCon{+c2, t2} False{}:
      +s2 = lex_sym2(u, Char.to_u32(c2))
      lex_sym_two(u, c2, t2, s2, stk, depth, line, rev, syms, Bool.not(U32.is_zero(s2)))
def lex_lit_or_sym(+u: U32, +t: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, is_str: Bool, is_chr: Bool) -> LStep:
  match is_str is_chr:
    case True{} _: lex_str_done(stk, depth, line, rev, syms, lex_scan_str(t, SNil{}))
    case False{} True{}: lex_tok_chr(t, stk, depth, line, rev, syms)
    case False{} False{}: lex_sym_unsafe(u, t, stk, depth, line, rev, syms, Bool.and(U32.is_eq(u, 64), String.starts_with(t, "unsafe")))
def lex_tok_val(c: Char, +u: U32, t: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, alp: Bool, dig: Bool) -> LStep:
  match alp dig:
    case True{} _: lex_ident_done(stk, depth, line, rev, syms, lex_scan_ident(t, SCon{c, SNil{}}))
    case False{} True{}: lex_num_start(u, t, stk, depth, line, rev, syms)
    case False{} False{}: lex_lit_or_sym(u, t, stk, depth, line, rev, syms, U32.is_eq(u, 34), U32.is_eq(u, 39))
def lex_tok_ws(c: Char, +u: U32, t: String, stk: List<&2, U32>, +depth: U32, +line: U32, +rev: List<&2, Tok>, syms: SymTab, sp: Bool, hash: Bool, nl: Bool) -> LStep:
  match sp hash nl:
    case True{} _ _: LNext{t, stk, False{}, depth, line, rev, syms}
    case False{} True{} _: LNext{lex_skip_comment(t), stk, False{}, depth, line, rev, syms}
    case False{} False{} True{}:
      +z = U32.is_zero(depth)
      rev2 = Bool.pick(List<&2, Tok>, Bool.and(z, lex_need_nl(rev)), Con{Tok{TkNewline{}, line}, rev}, rev)
      LNext{t, stk, z, depth, U32.add(line, 1), rev2, syms}
    case False{} False{} False{}:
      lex_tok_val(c, u, t, stk, depth, line, rev, syms, lex_is_alpha(u), lex_is_digit(u))
def lex_tok(s: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab) -> LStep:
  match s:
    case SNil{}: LDone{lex_eof(stk, line, rev, syms)}
    case SCon{+c, t}:
      +u = Char.to_u32(c)
      sp = Bool.or(U32.is_eq(u, 32), Bool.or(U32.is_eq(u, 9), U32.is_eq(u, 13)))
      lex_tok_ws(c, u, t, stk, depth, line, rev, syms, sp, U32.is_eq(u, 35), U32.is_eq(u, 10))
def lex_step_if(s: String, stk: List<&2, U32>, depth: U32, line: U32, rev: List<&2, Tok>, syms: SymTab, do_bol: Bool) -> LStep:
  match do_bol:
    case True{}: lex_bol_scan(stk, depth, line, rev, syms, lex_count_indent(s, 0))
    case False{}: lex_tok(s, stk, depth, line, rev, syms)
def lex_run(fuel: Nat, st: LStep) -> LexRes:
  match fuel st:
    case _ LDone{res}: res
    case 0n LNext{_, stk, _, _, line, rev, syms}: lex_eof(stk, line, rev, syms)
    case 1n+p LNext{s, stk, bol, +depth, line, rev, syms}:
      lex_run(p, lex_step_if(s, stk, depth, line, rev, syms, Bool.and(bol, U32.is_zero(depth))))
def lex_str_fuel(s: String, acc: Nat) -> Nat:
  match s:
    case SNil{}: acc
    case SCon{_, t}: lex_str_fuel(t, Succ{Succ{acc}})
def b5k_lex(+src: String, syms: SymTab) -> LexRes:
  lex_run(lex_str_fuel(src, 8n), LNext{src, Con{0, Nil{}}, True{}, 0, 1, Nil{}, syms})
