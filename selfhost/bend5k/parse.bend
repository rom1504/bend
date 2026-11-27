# bend5k/parse.bend — Continuation-Stack Layout-Aware Parser
# ==========================================================
# Consumes tokens from b5k_lex and builds core.bend's frozen Book AST.
# Pure safe Bend2 (zero @unsafe): uses an explicit continuation stack
# (PGoal/PKont) driven by a single self-recursive p_run loop.
# EOp codes: 0..9 = B5K_OP_ADD..B5K_OP_SHR; 20..25 = 20 + B5K_CMP_EQ..GE.
# EUnOp codes: 0=NEG (-), 1=NOT (!, ~).
type ParseRes is Data:
  ParseRes{ok: Bool, err: String, book: Book}
type PState is Data:
  PState{toks: List<&2, Tok>, syms: SymTab, next_cid: U32, err: String}
type PSym is Data:
  PSym{id: U32, st: PState}
type PVal is Data:
  VExpr{e: Expr}
  VExprs{es: List<&2, Expr>}
  VPat{p: Pat}
  VPats{ps: List<&2, Pat>}
  VParam{pm: Param}
  VParams{pms: List<&2, Param>}
  VCases{cs: List<&2, Case>}
  VStmts{ss: List<&2, Stmt>}
  VCtors{cs: List<&2, CtorDef>}
  VStr{s: String}
type PGoal is Data:
  GTop{ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  GExpr{}
  GUnary{}
  GPost{lhs: Expr}
  GBin{min_p: U32, lhs: Expr}
  GArrow{no_gt: Bool}
  GTypeArg{}
  GSuite{}
  GBlock{}
  GPat{}
  GParam{erased: Bool, dup: Bool, mode: U32}
  GExprList{cc: U32, acc: List<&2, Expr>}
  GPatList{cc: U32, eat: Bool, acc: List<&2, Pat>}
  GParams{cc: U32, acc: List<&2, Param>}
  GCases{acc: List<&2, Case>}
  GLamMat{acc: List<&2, Case>}
  GDo{acc: List<&2, Stmt>}
  GCtors{ind: Bool, acc: List<&2, CtorDef>}
  GLawBody{lsym: U32, pms: List<&2, Param>, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  GFimp{path: String}
type PKont is Data:
  KPatList{cc: U32, eat: Bool, acc: List<&2, Pat>}
  KPatCtr{id: U32}
  KPatSucc{n: U32, sid: U32}
  KPatCons{lhs: Pat}
  KPWrap{is_list: Bool}
  KParamTy{id: U32, erased: Bool, dup: Bool}
  KParams{cc: U32, acc: List<&2, Param>}
  KExprList{cc: U32, acc: List<&2, Expr>}
  KWrapExprs{is_list: Bool}
  KParenTy{acc: List<&2, Expr>, e: Expr}
  KBrace{}
  KBraceTy{e: Expr}
  KBrackFirst{}
  KArrTy{e0: Expr}
  KArrLen{e0: Expr}
  KPostCall{lhs: Expr, is_ctr: Bool}
  KPostArrIdx{lhs: Expr}
  KPostArrSet{lhs: Expr, idx: Expr}
  KUnOp{op: U32}
  KBinRhs0{min_p: U32, prec: U32, op: U32, lhs: Expr}
  KBinRhs{min_p: U32, op: U32, lhs: Expr}
  KArrowBin{no_gt: Bool}
  KArrowLhs{no_gt: Bool}
  KMatchScruts{}
  KMatchCases{sc: List<&2, Expr>}
  KCaseBody{acc: List<&2, Case>, pats: List<&2, Pat>}
  KCaseHead{acc: List<&2, Case>}
  KIfCond{}
  KIfThen{cond: Expr}
  KIfElse{cond: Expr, thn: Expr}
  KDoStmt{acc: List<&2, Stmt>, is_ret: Bool}
  KDoPat{acc: List<&2, Stmt>, is_bind: Bool}
  KDoVal{acc: List<&2, Stmt>, pt: Pat, is_bind: Bool}
  KEatExpr{sym: U32, msg: String}
  KDoWrap{}
  KBlkLetPat{er: Bool}
  KBlkForkPats{ps: List<&2, Pat>}
  KBlkForkExprs{cur: Pat, rem: List<&2, Pat>, ind: Bool}
  KBlkLetVal{pt: Pat, er: Bool}
  KBlkLetBody{pt: Pat, val: Expr}
  KBlkExpr{}
  KILetPat{}
  KILetVal{pt: Pat}
  KLam{no_gt: Bool}
  KLamBody{pms: List<&2, Param>}
  KPiPm{no_gt: Bool}
  KPiBody{pm: Param}
  KBinOnly{no_gt: Bool}
  KRewrite{st: U32}
  KLamMatArm{acc: List<&2, Case>}
  KCtorFs{ind: Bool, csym: U32, cid: U32, acc: List<&2, CtorDef>}
  KTypePms{tsym: U32, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KTypeCtors{tsym: U32, pms: List<&2, Param>, is_data: Bool, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KLaw{kind: U32, lsym: U32, pms: List<&2, Param>, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KDefPms{dsym: U32, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KDefRet{dsym: U32, pms: List<&2, Param>, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KDefBody{dsym: U32, pms: List<&2, Param>, ret: Maybe<&2, Expr>, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
type PStep is Data:
  SEval{g: PGoal, st: PState, ks: List<&2, PKont>}
  SApply{v: PVal, st: PState, ks: List<&2, PKont>}
  SDone{ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>, st: PState}
# State & Token Helpers
def p_has_err(st: PState) -> Bool:
  PState{_, _, _, err} = st
  Bool.not(String.is_empty(err))
def p_fail(st: PState, msg: String) -> PState:
  PState{toks, syms, ncid, +err} = st
  PState{toks, syms, ncid, Bool.pick(String, String.is_empty(err), msg, err)}
def p_peek(st: PState) -> TokKind:
  match st:
    case PState{Con{Tok{k, _}, _}, _, _, _}: k
    case _: TkEof{}
def p_toks(st: PState) -> List<&2, Tok>:
  PState{toks, _, _, _} = st
  toks
def p_drop(st: PState) -> PState:
  match st:
    case PState{Con{_, t}, syms, ncid, err}: PState{t, syms, ncid, err}
    case PState{Nil{}, syms, ncid, err}: PState{Nil{}, syms, ncid, err}
def p_intern_k(toks: List<&2, Tok>, ncid: U32, err: String, sr: SymRes) -> PSym:
  SymRes{syms2, id} = sr
  PSym{id, PState{toks, syms2, ncid, err}}
def p_intern(st: PState, name: String) -> PSym:
  PState{toks, syms, ncid, err} = st
  p_intern_k(toks, ncid, err, symtab_intern(syms, name))
def p_is_tok(st: PState, is_kw: Bool, code: U32) -> Bool:
  match st is_kw:
    case PState{Con{Tok{TkSym{c}, _}, _}, _, _, _} False{}: U32.is_eq(c, code)
    case PState{Con{Tok{TkKw{c}, _}, _}, _, _, _} True{}: U32.is_eq(c, code)
    case _ _: False{}
def p_is_sym(st: PState, code: U32) -> Bool: p_is_tok(st, False{}, code)
def p_is_kw(st: PState, code: U32) -> Bool: p_is_tok(st, True{}, code)
def p_tok_tag(st: PState) -> U32:
  match st:
    case PState{Con{Tok{TkIndent{}, _}, _}, _, _, _}: 1
    case PState{Con{Tok{TkIdent{_}, _}, _}, _, _, _}: 2
    case PState{Con{Tok{TkNewline{}, _}, _}, _, _, _}: 3
    case PState{Con{Tok{TkDedent{}, _}, _}, _, _, _}: 4
    case PState{Con{Tok{TkEof{}, _}, _}, _, _, _}: 5
    case PState{Nil{}, _, _, _}: 5
    case _: 0
def p_is_indent(st: PState) -> Bool: U32.is_eq(p_tok_tag(st), 1)
def p_is_ident(st: PState) -> Bool: U32.is_eq(p_tok_tag(st), 2)
def p_is_nl(st: PState) -> Bool: U32.is_eq(p_tok_tag(st), 3)
def p_is_eof(st: PState) -> Bool: U32.is_eq(p_tok_tag(st), 5)
def p_at_end(+st: PState) -> Bool: Bool.or(p_has_err(st), U32.is_ge(p_tok_tag(st), 4))
def p_skip_go(toks: List<&2, Tok>, mode: U32) -> List<&2, Tok>:
  match toks mode:
    case Con{Tok{TkNewline{}, _}, t} 0: p_skip_go(t, 0)
    case xs 0: xs
    case Con{Tok{TkNewline{}, _}, t} 3: p_skip_go(t, 3)
    case Con{Tok{TkIndent{}, _}, t} 3: p_skip_go(t, 3)
    case Con{Tok{TkDedent{}, _}, t} 3: p_skip_go(t, 3)
    case xs 3: xs
    case Nil{} _: Nil{}
    case Con{Tok{TkEof{}, l}, t} _: Con{Tok{TkEof{}, l}, t}
    case Con{Tok{TkNewline{}, l}, t} 2: Con{Tok{TkNewline{}, l}, t}
    case Con{Tok{TkNewline{}, _}, t} 1: t
    case Con{Tok{TkSym{58}, l}, t} 2: Con{Tok{TkSym{58}, l}, t}
    case Con{_, t} m: p_skip_go(t, m)
def p_skip(mode: U32, st: PState) -> PState:
  PState{toks, syms, ncid, err} = st
  PState{p_skip_go(toks, mode), syms, ncid, err}
def p_skip_nls(st: PState) -> PState: p_skip(0, st)
def p_skip_ws(st: PState) -> PState: p_skip(3, st)
def p_is_ident_eq(st: PState, name: String) -> Bool:
  match st:
    case PState{Con{Tok{TkIdent{id}, _}, _}, syms, _, _}: String.eq(symtab_name(syms, id), name)
    case _: False{}
def p_eat_sym(+st: PState, code: U32, msg: String) -> PState: Bool.pick(PState, p_is_sym(st, code), p_drop(st), p_fail(st, msg))
def p_is_close(+st: PState, +cc: U32) -> Bool: Bool.or(p_is_sym(st, cc), Bool.and(U32.is_eq(cc, 62), p_is_sym(st, 270)))
def p_stop_at(+st: PState, cc: U32) -> Bool: Bool.or(p_has_err(st), Bool.or(p_is_close(st, cc), p_is_eof(st)))
def p_split_sym(st: PState, from_c: U32, to_c: U32) -> PState:
  match st:
    case PState{Con{Tok{TkSym{+c}, l}, t}, syms, ncid, err}: PState{Con{Tok{TkSym{Bool.pick(U32, U32.is_eq(c, from_c), to_c, c)}, l}, t}, syms, ncid, err}
    case other: other
def p_eat_close(+st: PState, +cc: U32, msg: String) -> PState: Bool.pick(PState, Bool.and(U32.is_eq(cc, 62), p_is_sym(st, 270)), p_split_sym(st, 270, 62), p_eat_sym(st, cc, msg))
def p_eat_kw(+st: PState, code: U32, msg: String) -> PState: Bool.pick(PState, p_is_kw(st, code), p_drop(st), p_fail(st, msg))
def p_eat_dedent(st: PState) -> PState:
  +st1 = p_skip_nls(st)
  Bool.pick(PState, U32.is_eq(p_tok_tag(st1), 4), p_drop(st1), st1)
def p_opt_drop(+st: PState, code: U32) -> PState: Bool.pick(PState, p_is_sym(st, code), p_drop(st), st)
def p_sym_eq(st: PState, id: U32, s: String) -> Bool:
  PState{_, syms, _, _} = st
  String.eq(symtab_name(syms, id), s)
# Lookahead Helpers (Pure Safe Structural Self-Recursion)
def p_scan_assign_go(toks: List<&2, Tok>, done: Bool, hit: Bool, +target: U32, +d: U32) -> Bool:
  match toks done:
    case _ True{}: hit
    case Nil{} False{}: False{}
    case Con{Tok{TkNewline{}, _}, _} False{}: False{}
    case Con{Tok{TkIndent{}, _}, _} False{}: False{}
    case Con{Tok{TkDedent{}, _}, _} False{}: False{}
    case Con{Tok{TkEof{}, _}, _} False{}: False{}
    case Con{Tok{TkSym{+c}, _}, t} False{}:
      +z = U32.is_zero(d)
      +eq = Bool.and(z, U32.is_eq(c, target))
      p_scan_assign_go(t, Bool.or(eq, Bool.and(z, Bool.or(Bool.or(U32.is_eq(c, 59), U32.is_eq(c, 257)), Bool.or(U32.is_eq(c, 61), Bool.or(U32.is_eq(c, 266), Bool.or(U32.is_eq(c, 41), Bool.or(U32.is_eq(c, 93), U32.is_eq(c, 125)))))))), eq, target, lex_depth_delta(c, d))
    case Con{_, t} False{}: p_scan_assign_go(t, False{}, False{}, target, d)
def p_scan_assign(toks: List<&2, Tok>, target: U32) -> Bool:
  match toks:
    case Con{Tok{TkKw{_}, _}, _}: False{}
    case xs: p_scan_assign_go(xs, False{}, False{}, target, 0)
def p_scan_plam(fuel: Nat, done: Bool, hit: Bool, toks: List<&2, Tok>, +d: U32) -> Bool:
  match fuel done toks:
    case _ True{} _: hit
    case 1n+p False{} Con{Tok{TkSym{40}, _}, t}: p_scan_plam(p, False{}, False{}, t, U32.add(d, 1))
    case 1n+p False{} Con{Tok{TkSym{41}, _}, Con{Tok{TkSym{257}, l}, t}}: p_scan_plam(p, U32.is_eq(d, 1), True{}, Con{Tok{TkSym{257}, l}, t}, U32.sub(d, 1))
    case 1n+p False{} Con{Tok{TkSym{41}, _}, t}: p_scan_plam(p, U32.is_eq(d, 1), False{}, t, U32.sub(d, 1))
    case 1n+p False{} Con{Tok{TkEof{}, _}, _}: False{}
    case 1n+p False{} Con{_, t}: p_scan_plam(p, False{}, False{}, t, d)
    case _ _ _: False{}
def p_is_lam(toks: List<&2, Tok>) -> Bool:
  match toks:
    case Con{Tok{TkIdent{_}, _}, Con{Tok{TkSym{257}, _}, _}}: True{}
    case Con{Tok{TkSym{+c1}, _}, Con{Tok{TkIdent{_}, _}, Con{Tok{TkSym{257}, _}, _}}}: Bool.or(U32.is_eq(c1, 43), Bool.or(U32.is_eq(c1, 45), U32.is_eq(c1, 126)))
    case Con{Tok{TkSym{40}, _}, t}: p_scan_plam(64n, False{}, False{}, t, 1)
    case _: False{}
def p_after_targs(toks: List<&2, Tok>) -> Bool:
  match toks:
    case Nil{}: True{}
    case Con{Tok{TkNewline{}, _}, _}: True{}
    case Con{Tok{TkDedent{}, _}, _}: True{}
    case Con{Tok{TkEof{}, _}, _}: True{}
    case Con{Tok{TkSym{+c}, _}, _}: Bool.or(Bool.or(U32.is_eq(c, 40), Bool.or(U32.is_eq(c, 123), Bool.or(U32.is_eq(c, 44), U32.is_eq(c, 41)))), Bool.or(Bool.or(U32.is_eq(c, 93), Bool.or(U32.is_eq(c, 125), Bool.or(U32.is_eq(c, 58), Bool.or(U32.is_eq(c, 62), U32.is_eq(c, 270))))), Bool.or(U32.is_eq(c, 256), Bool.or(U32.is_eq(c, 38), Bool.or(U32.is_eq(c, 59), Bool.or(U32.is_eq(c, 266), Bool.or(U32.is_eq(c, 61), Bool.or(U32.is_eq(c, 42), U32.is_eq(c, 94)))))))))
    case _: False{}
def p_scan_targs(toks: List<&2, Tok>, done: Bool, hit: Bool, +d: U32, +pd: U32) -> Bool:
  match toks done:
    case _ True{}: hit
    case Nil{} False{}: False{}
    case Con{Tok{TkEof{}, _}, _} False{}: False{}
    case Con{Tok{TkSym{59}, _}, t} False{}: Bool.pick(Bool, U32.is_zero(pd), False{}, p_scan_targs(t, False{}, False{}, d, pd))
    case Con{Tok{TkSym{60}, _}, t} False{}: p_scan_targs(t, False{}, False{}, Bool.pick(U32, U32.is_zero(pd), U32.add(d, 1), d), pd)
    case Con{Tok{TkSym{62}, _}, +t} False{}:
      +z = U32.is_zero(pd)
      +is1 = Bool.and(z, U32.is_eq(d, 1))
      p_scan_targs(t, is1, Bool.and(is1, p_after_targs(t)), Bool.pick(U32, z, U32.sub(d, 1), d), pd)
    case Con{Tok{TkSym{270}, l}, +t} False{}:
      +z = U32.is_zero(pd)
      +is1 = Bool.and(z, U32.is_eq(d, 1))
      +is2 = Bool.and(z, U32.is_eq(d, 2))
      p_scan_targs(t, Bool.or(is1, is2), Bool.pick(Bool, is2, p_after_targs(t), Bool.and(is1, p_after_targs(Con{Tok{TkSym{62}, l}, t}))), Bool.pick(U32, z, U32.sub(d, 2), d), pd)
    case Con{Tok{TkSym{c}, _}, t} False{}: p_scan_targs(t, False{}, False{}, d, lex_depth_delta(c, pd))
    case Con{_, t} False{}: p_scan_targs(t, False{}, False{}, d, pd)
def p_is_targs(toks: List<&2, Tok>) -> Bool:
  match toks:
    case Con{Tok{TkSym{60}, _}, t}: p_scan_targs(t, False{}, False{}, 1, 0)
    case _: False{}
# Operator Precedence & Pair Builders
def p_binop_info(c: U32) -> U32:
  match c:
    case 263: U32.add(64, B5K_OP_OR())
    case 262: U32.add(128, B5K_OP_AND())
    case 258: U32.add(192, U32.add(20, B5K_CMP_EQ()))
    case 259: U32.add(192, U32.add(20, B5K_CMP_NE()))
    case 60: U32.add(192, U32.add(20, B5K_CMP_LT()))
    case 260: U32.add(192, U32.add(20, B5K_CMP_LE()))
    case 62: U32.add(192, U32.add(20, B5K_CMP_GT()))
    case 261: U32.add(192, U32.add(20, B5K_CMP_GE()))
    case 124: U32.add(256, B5K_OP_OR())
    case 94: U32.add(256, B5K_OP_XOR())
    case 38: U32.add(256, B5K_OP_AND())
    case 272: U32.add(256, B5K_OP_AND())
    case 269: U32.add(320, B5K_OP_SHL())
    case 270: U32.add(320, B5K_OP_SHR())
    case 265: U32.add(320, 30)
    case 43: U32.add(384, B5K_OP_ADD())
    case 45: U32.add(384, B5K_OP_SUB())
    case 264: U32.add(384, B5K_OP_ADD())
    case 42: U32.add(448, B5K_OP_MUL())
    case 47: U32.add(448, B5K_OP_DIV())
    case 37: U32.add(448, B5K_OP_MOD())
    case _: 0
def p_pair_pat(ps: List<&2, Pat>) -> Pat:
  match ps:
    case Nil{}: PWild{}
    case Con{p, Nil{}}: p
    case Con{p, rest}: PPair{p, p_pair_pat(rest)}
def p_pair_expr(es: List<&2, Expr>) -> Expr:
  match es:
    case Nil{}: EUnit{}
    case Con{e, Nil{}}: e
    case Con{e, rest}: EPair{e, p_pair_expr(rest)}
def p_ctr_wrap(lhs: Expr, fs: List<&2, Expr>) -> Expr:
  match lhs:
    case EVar{id}: ECtr{id, fs}
    case other: EApp{other, fs}
# Goal Dispatch Helpers (100% Non-Recursive)
def p_pat_done(+p: Pat, +st: PState, +ks: List<&2, PKont>) -> PStep: Bool.pick(PStep, p_is_sym(st, 265), SEval{GPat{}, p_drop(st), Con{KPatCons{p}, ks}}, SApply{VPat{p}, st, ks})
def p_wrap_succ(n: Nat, +sid: U32, sub: Pat) -> Pat:
  match n:
    case 0n: sub
    case 1n+p: PCtr{sid, Con{p_wrap_succ(p, sid, sub), Nil{}}}
def p_ev_pat_plus(st1: PState, ks: List<&2, PKont>) -> PStep:
  match st1:
    case PState{Con{Tok{TkIdent{id}, _}, t}, syms, ncid, err}: p_pat_done(PVar{id, True{}}, PState{t, syms, ncid, err}, ks)
    case other: SEval{GPat{}, other, ks}
def p_ev_pat_succ(+v: U32, r: PSym, +ks: List<&2, PKont>, dup: Bool) -> PStep:
  PSym{+sid, +st2} = r
  Bool.pick(PStep, dup, p_ev_pat_plus(st2, Con{KPatSucc{v, sid}, ks}), SEval{GPat{}, st2, Con{KPatSucc{v, sid}, ks}})
def p_ev_pat_num(v: U32, st1: PState, ks: List<&2, PKont>, is_p: Bool, is_pp: Bool) -> PStep:
  match is_p is_pp:
    case False{} False{}: p_pat_done(PNum{v}, st1, ks)
    case _ dup: p_ev_pat_succ(v, p_intern(p_drop(st1), "Succ"), ks, dup)
def p_ev_pat(st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkSym{43}: p_ev_pat_plus(p_drop(st), ks)
    case TkSym{45}: SEval{GPat{}, p_drop(st), ks}
    case TkSym{126}: SEval{GPat{}, p_drop(st), ks}
    case TkIdent{+id}:
      +st1 = p_drop(st)
      Bool.pick(PStep, p_sym_eq(st1, id, "_"), p_pat_done(PWild{}, st1, ks), Bool.pick(PStep, p_is_sym(st1, 123), SEval{GPatList{125, True{}, Nil{}}, p_drop(st1), Con{KPatCtr{id}, ks}}, p_pat_done(PVar{id, False{}}, st1, ks)))
    case TkNum{+v}:
      +st1 = p_drop(st)
      +nz = U32.is_gt(v, 0)
      p_ev_pat_num(v, st1, ks, Bool.and(nz, p_is_sym(st1, 43)), Bool.and(nz, p_is_sym(st1, 264)))
    case TkFlt{b}: p_pat_done(PNum{b}, p_drop(st), ks)
    case TkChr{c}: p_pat_done(PChr{c}, p_drop(st), ks)
    case TkStr{_}: p_pat_done(PWild{}, p_drop(st), ks)
    case TkSym{40}: SEval{GPatList{41, True{}, Nil{}}, p_drop(st), Con{KPWrap{False{}}, ks}}
    case TkSym{91}: SEval{GPatList{93, True{}, Nil{}}, p_drop(st), Con{KPWrap{True{}}, ks}}
    case _: SApply{VPat{PWild{}}, p_fail(st, "unexpected token in pattern"), ks}
def p_ev_param(+er: Bool, +dup: Bool, +mode: U32, st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkSym{43}: SEval{GParam{er, True{}, mode}, p_drop(st), ks}
    case TkSym{45}: SEval{GParam{True{}, dup, mode}, p_drop(st), ks}
    case TkSym{126}: SEval{GParam{True{}, dup, mode}, p_drop(st), ks}
    case TkIdent{+id}:
      +st1 = p_drop(st)
      +no_arr = U32.is_ge(mode, 2)
      +no_gt = Bool.or(U32.is_eq(mode, 1), U32.is_eq(mode, 3))
      +ks_ty = Bool.pick(List<&2, PKont>, no_arr, Con{KBinOnly{no_gt}, Con{KParamTy{id, er, dup}, ks}}, Con{KParamTy{id, er, dup}, ks})
      +g_ty = Bool.pick(PGoal, no_arr, GUnary{}, Bool.pick(PGoal, no_gt, GTypeArg{}, GExpr{}))
      Bool.pick(PStep, p_is_sym(st1, 58), SEval{g_ty, p_drop(st1), ks_ty}, SApply{VParam{Param{id, None{}, er, dup}}, st1, ks})
    case _: SApply{VParam{Param{0, None{}, er, dup}}, p_fail(st, "expected parameter name"), ks}
def p_is_var(e: Expr) -> Bool:
  match e:
    case EVar{_}: True{}
    case _: False{}
def p_arrset_pat(e: Expr) -> Pat:
  match e:
    case EArrSet{EVar{sym}, _, _}: PVar{sym, False{}}
    case _: PWild{}
def p_do_stmt_mk(val: Expr) -> Stmt:
  match val:
    case EArrSet{EVar{+sym}, idx, rhs}: StLet{PVar{sym, False{}}, EArrSet{EVar{sym}, idx, rhs}}
    case v: StExpr{v}
def p_lam_mat_step(acc: List<&2, Case>, st1: PState, ks: List<&2, PKont>) -> PStep:
  match st1:
    case PState{Con{Tok{TkIdent{_}, _}, Con{Tok{TkSym{58}, _}, t}}, syms, ncid, err}: SEval{GExpr{}, PState{t, syms, ncid, err}, Con{KLamMatArm{acc}, ks}}
    case other: SEval{GExpr{}, other, Con{KLamMatArm{acc}, ks}}
def p_ev_unary(+st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkSym{43}: SEval{GUnary{}, p_drop(st), ks}
    case TkSym{45}: SEval{GUnary{}, p_drop(st), Con{KUnOp{0}, ks}}
    case TkSym{33}: SEval{GUnary{}, p_drop(st), Con{KUnOp{1}, ks}}
    case TkSym{126}: SEval{GUnary{}, p_drop(st), Con{KUnOp{1}, ks}}
    case TkSym{37}: SEval{GUnary{}, p_drop(st), Con{KRewrite{0}, ks}}
    case TkSym{92}:
      +st1 = p_drop(st)
      Bool.pick(PStep, p_is_sym(st1, 123), SEval{GLamMat{Nil{}}, p_drop(st1), ks}, SApply{VExpr{EHole{}}, p_fail(st, "unexpected token in expression"), ks})
    case TkNum{v}: SEval{GPost{ENum{v}}, p_drop(st), ks}
    case TkFlt{b}: SEval{GPost{EFlt{b}}, p_drop(st), ks}
    case TkChr{c}: SEval{GPost{EChr{c}}, p_drop(st), ks}
    case TkStr{s}: SEval{GPost{EStr{s}}, p_drop(st), ks}
    case TkIdent{id}: SEval{GPost{EVar{id}}, p_drop(st), ks}
    case TkSym{63}: SEval{GPost{EHole{}}, p_drop(st), ks}
    case TkSym{267}: SEval{GPost{ENum{1}}, p_drop(st), ks}
    case TkSym{268}: SEval{GPost{ENum{2}}, p_drop(st), ks}
    case TkSym{271}: SEval{GPost{ENum{0}}, p_drop(st), ks}
    case TkSym{40}: SEval{GExprList{41, Nil{}}, p_drop(st), Con{KWrapExprs{False{}}, ks}}
    case TkSym{91}:
      +st1 = p_drop(st)
      Bool.pick(PStep, p_is_sym(st1, 93), SEval{GPost{EList{Nil{}}}, p_drop(st1), ks}, SEval{GExpr{}, st1, Con{KBrackFirst{}, ks}})
    case TkSym{123}:
      +st1 = p_drop(st)
      Bool.pick(PStep, p_is_sym(st1, 125), SEval{GPost{ERefl{}}, p_drop(st1), ks}, Bool.pick(PStep, Bool.and(p_is_sym(st1, 258), p_is_sym(p_drop(st1), 125)), SEval{GPost{ERefl{}}, p_drop(p_drop(st1)), ks}, SEval{GExpr{}, st1, Con{KBrace{}, ks}}))
    case _: SApply{VExpr{EHole{}}, p_fail(st, "unexpected token in expression"), ks}
def p_ev_post(+lhs: Expr, +st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkSym{40}: SEval{GExprList{41, Nil{}}, p_drop(st), Con{KPostCall{lhs, False{}}, ks}}
    case TkSym{33}:
      +st1 = p_drop(st)
      Bool.pick(PStep, p_is_sym(st1, 40), SEval{GExprList{41, Nil{}}, p_drop(st1), Con{KPostCall{lhs, False{}}, ks}}, SApply{VExpr{lhs}, st, ks})
    case TkSym{123}: Bool.pick(PStep, p_is_var(lhs), SEval{GExprList{125, Nil{}}, p_drop(st), Con{KPostCall{lhs, True{}}, ks}}, SApply{VExpr{lhs}, st, ks})
    case TkSym{91}: SEval{GExpr{}, p_drop(st), Con{KPostArrIdx{lhs}, ks}}
    case TkSym{60}: Bool.pick(PStep, p_is_targs(p_toks(st)), SEval{GExprList{62, Nil{}}, p_drop(st), Con{KPostCall{lhs, False{}}, ks}}, SApply{VExpr{lhs}, st, ks})
    case _: SApply{VExpr{lhs}, st, ks}
def p_do_bind_pat(st: PState, pt: Pat) -> Pat:
  match pt:
    case PVar{+sym, False{}}: Bool.pick(Pat, p_sym_eq(st, sym, "Unit"), PWild{}, PVar{sym, False{}})
    case other: other
def p_ev_bin(+min_p: U32, +lhs: Expr, +st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkSym{+c}:
      +no_gt = U32.is_ge(min_p, 16)
      +mp = Bool.pick(U32, no_gt, U32.sub(min_p, 16), min_p)
      +info = p_binop_info(c)
      +prec = U32.shrn(info, 6n)
      ok = Bool.and(Bool.and(U32.is_gt(prec, 0), U32.is_ge(prec, mp)), Bool.not(Bool.and(no_gt, Bool.or(U32.is_eq(c, 62), U32.is_eq(c, 270)))))
      Bool.pick(PStep, ok, SEval{GUnary{}, p_skip_nls(p_drop(st)), Con{KBinRhs0{min_p, prec, U32.and(info, 63), lhs}, ks}}, SApply{VExpr{lhs}, st, ks})
    case TkNewline{}:
      +st1 = p_skip_ws(st)
      +mp = Bool.pick(U32, U32.is_ge(min_p, 16), U32.sub(min_p, 16), min_p)
      Bool.pick(PStep, Bool.and(p_is_sym(st1, 264), U32.is_ge(6, mp)), SEval{GUnary{}, p_skip_nls(p_drop(st1)), Con{KBinRhs0{min_p, 6, B5K_OP_ADD(), lhs}, ks}}, Bool.pick(PStep, Bool.and(p_is_sym(st1, 38), U32.is_ge(4, mp)), SEval{GUnary{}, p_skip_nls(p_drop(st1)), Con{KBinRhs0{min_p, 4, B5K_OP_AND(), lhs}, ks}}, SApply{VExpr{lhs}, st, ks}))
    case _: SApply{VExpr{lhs}, st, ks}
def p_bin_cons(mp: U32, lhs: Expr, rhs: Expr, r: PSym, ks: List<&2, PKont>) -> PStep:
  PSym{cid, st2} = r
  SEval{GBin{mp, ECtr{cid, Con{lhs, Con{rhs, Nil{}}}}}, st2, ks}
def p_pat_cons(lhs: Pat, rhs: Pat, r: PSym, ks: List<&2, PKont>) -> PStep:
  PSym{cid, st2} = r
  SApply{VPat{PCtr{cid, Con{lhs, Con{rhs, Nil{}}}}}, st2, ks}
def p_ev_lam(+st: PState, +ks: List<&2, PKont>, +no_gt: Bool) -> PStep: Bool.pick(PStep, p_is_sym(st, 40), SEval{GParams{41, Nil{}}, p_drop(st), Con{KLam{no_gt}, ks}}, SEval{GParam{False{}, False{}, 0}, st, Con{KLam{no_gt}, ks}})
def p_ev_expr(+st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkKw{5}: SEval{GExprList{58, Nil{}}, p_drop(st), Con{KMatchScruts{}, ks}}
    case TkKw{7}: SEval{GExpr{}, p_drop(st), Con{KIfCond{}, ks}}
    case TkKw{9}:
      +st4 = p_skip_nls(p_eat_sym(p_skip(2, p_drop(st)), 58, "expected ':' after do"))
      SEval{GDo{Nil{}}, Bool.pick(PState, p_is_indent(st4), p_drop(st4), st4), Con{KDoWrap{}, ks}}
    case TkSym{64}: SEval{GParam{False{}, False{}, 2}, p_drop(st), Con{KPiPm{False{}}, ks}}
    case TkSym{38}: SEval{GParam{False{}, False{}, 2}, p_drop(st), Con{KPiPm{False{}}, ks}}
    case _:
      +ts = p_toks(st)
      Bool.pick(PStep, p_is_lam(ts), p_ev_lam(st, ks, False{}), Bool.pick(PStep, p_scan_assign(ts, 61), SEval{GPat{}, st, Con{KILetPat{}, ks}}, SEval{GArrow{False{}}, st, ks}))
def p_ev_ctor_k(+ind: Bool, +acc: List<&2, CtorDef>, st1: PState, +ks: List<&2, PKont>) -> PStep:
  match st1:
    case PState{Con{Tok{TkIdent{+csym}, _}, t}, syms2, +cid, err2}:
      +st3: PState = PState{t, syms2, U32.add(cid, 1), err2}
      Bool.pick(PStep, p_is_sym(st3, 123), SEval{GParams{125, Nil{}}, p_drop(st3), Con{KCtorFs{ind, csym, cid, acc}, ks}}, SEval{GCtors{ind, Con{CtorDef{csym, cid, Nil{}}, acc}}, st3, ks})
    case other: SApply{VCtors{b5k_list_rev(CtorDef, acc)}, p_fail(other, "expected ctor name"), ks}
def p_ev_fimp_k(+path: String, st2: PState, ks: List<&2, PKont>) -> PStep:
  match st2:
    case PState{Con{Tok{TkStr{p}, _}, t}, syms, ncid, err}: SEval{GFimp{Bool.pick(String, String.is_empty(path), p, path)}, PState{t, syms, ncid, err}, ks}
    case other: SEval{GFimp{path}, p_skip(1, other), ks}
def p_type_body_go(+tsym: U32, +pms: List<&2, Param>, +st: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>) -> PStep:
  +st1 = Bool.pick(PState, p_is_kw(st, 4), p_drop(st), st)
  +is_data = p_is_ident_eq(st1, "Data")
  +st3 = p_skip_nls(p_eat_sym(p_skip(2, st1), 58, "expected ':' in type"))
  Bool.pick(PStep, p_is_indent(st3), SEval{GCtors{True{}, Nil{}}, p_drop(st3), Con{KTypeCtors{tsym, pms, is_data, ts, ds, ls}, Nil{}}}, Bool.pick(PStep, p_is_ident(st3), SEval{GCtors{False{}, Nil{}}, st3, Con{KTypeCtors{tsym, pms, is_data, ts, ds, ls}, Nil{}}}, SEval{GTop{Con{TypeDef{tsym, pms, is_data, Nil{}}, ts}, ds, ls}, st3, Nil{}}))
def p_def_body_go(+dsym: U32, +pms: List<&2, Param>, +ret: Maybe<&2, Expr>, st: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>) -> PStep:
  +st1 = p_eat_sym(p_skip_ws(st), 58, "expected ':' in def")
  +st2 = p_skip_nls(st1)
  +ind = p_is_indent(st2)
  +st3 = p_skip_nls(Bool.pick(PState, ind, p_drop(st2), st2))
  Bool.pick(PStep, Bool.or(ind, p_is_nl(st1)), Bool.pick(PStep, p_is_kw(st3, 11), SEval{GFimp{""}, st3, Con{KDefBody{dsym, pms, ret, ts, ds, ls}, Nil{}}}, SEval{GBlock{}, st3, Con{KDefBody{dsym, pms, ret, ts, ds, ls}, Nil{}}}), SEval{GExpr{}, st2, Con{KDefBody{dsym, pms, ret, ts, ds, ls}, Nil{}}})
def p_def_ret_go(+dsym: U32, +pms: List<&2, Param>, +st: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>) -> PStep:
  +st1 = p_skip_ws(st)
  Bool.pick(PStep, p_is_sym(st1, 256), SEval{GExpr{}, p_skip_ws(p_drop(st1)), Con{KDefRet{dsym, pms, ts, ds, ls}, Nil{}}}, p_def_body_go(dsym, pms, None{}, st, ts, ds, ls))
def p_top_named(kind: U32, st: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>) -> PStep:
  match kind st:
    case 1 PState{Con{Tok{TkIdent{+sym}, _}, t}, syms, ncid, err}:
      +st1: PState = p_opt_drop(PState{t, syms, ncid, err}, 63)
      Bool.pick(PStep, p_is_sym(st1, 40), SEval{GParams{41, Nil{}}, p_drop(st1), Con{KDefPms{sym, ts, ds, ls}, Nil{}}}, p_def_ret_go(sym, Nil{}, st1, ts, ds, ls))
    case 2 PState{Con{Tok{TkIdent{+sym}, _}, t}, syms, ncid, err}:
      +st1: PState = PState{t, syms, ncid, err}
      +is_la = p_is_sym(st1, 266)
      Bool.pick(PStep, Bool.or(p_is_sym(st1, 60), is_la), SEval{GParams{62, Nil{}}, Bool.pick(PState, is_la, p_split_sym(st1, 266, 45), p_drop(st1)), Con{KTypePms{sym, ts, ds, ls}, Nil{}}}, p_type_body_go(sym, Nil{}, st1, ts, ds, ls))
    case _ PState{Con{Tok{TkIdent{sym}, _}, t}, syms, ncid, err}:
      +st2 = p_skip_nls(p_eat_sym(PState{t, syms, ncid, err}, 58, "expected ':' after law"))
      SEval{GLawBody{sym, Nil{}, ts, ds, ls}, Bool.pick(PState, p_is_indent(st2), p_drop(st2), st2), Nil{}}
    case _ other: SDone{ts, ds, ls, p_fail(other, "expected declaration name")}
def p_ev_top(st1: PState, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>, k: TokKind) -> PStep:
  match k:
    case TkKw{11}: SEval{GTop{ts, ds, ls}, p_skip(1, st1), Nil{}}
    case TkKw{2}: p_top_named(2, p_drop(st1), ts, ds, ls)
    case TkKw{3}: p_top_named(3, p_drop(st1), ts, ds, ls)
    case TkKw{17}: p_top_named(1, p_eat_kw(p_skip_nls(p_drop(st1)), 1, "expected 'def' after @unsafe"), ts, ds, ls)
    case TkKw{1}: p_top_named(1, p_drop(st1), ts, ds, ls)
    case TkDedent{}: SEval{GTop{ts, ds, ls}, p_drop(st1), Nil{}}
    case _: SDone{b5k_list_rev(TypeDef, ts), b5k_list_rev(Def, ds), b5k_list_rev(LawDef, ls), p_fail(st1, "unexpected top-level token")}
# Main Eval & Apply Dispatch (100% Non-Recursive)
def p_eval(g: PGoal, +st: PState, +ks: List<&2, PKont>) -> PStep:
  match g:
    case GTop{+ts, +ds, +ls}:
      +st1 = p_skip_nls(st)
      Bool.pick(PStep, Bool.or(p_has_err(st1), p_is_eof(st1)), SDone{b5k_list_rev(TypeDef, ts), b5k_list_rev(Def, ds), b5k_list_rev(LawDef, ls), st1}, p_ev_top(st1, ts, ds, ls, p_peek(st1)))
    case GExpr{}: Bool.pick(PStep, p_has_err(st), SApply{VExpr{EHole{}}, st, ks}, p_ev_expr(st, ks, p_peek(st)))
    case GUnary{}: p_ev_unary(st, ks, p_peek(st))
    case GPost{+lhs}: Bool.pick(PStep, p_has_err(st), SApply{VExpr{lhs}, st, ks}, p_ev_post(lhs, st, ks, p_peek(st)))
    case GBin{min_p, +lhs}: Bool.pick(PStep, p_has_err(st), SApply{VExpr{lhs}, st, ks}, p_ev_bin(min_p, lhs, st, ks, p_peek(st)))
    case GArrow{+no_gt}: Bool.pick(PStep, Bool.or(p_is_sym(st, 64), p_is_sym(st, 38)), SEval{GParam{False{}, False{}, Bool.pick(U32, no_gt, 3, 2)}, p_drop(st), Con{KPiPm{no_gt}, ks}}, SEval{GUnary{}, st, Con{KArrowBin{no_gt}, ks}})
    case GTypeArg{}: Bool.pick(PStep, p_is_lam(p_toks(st)), p_ev_lam(st, ks, True{}), SEval{GArrow{True{}}, st, ks})
    case GSuite{}:
      +st1 = p_skip_nls(st)
      +st2 = Bool.pick(PState, U32.is_eq(p_tok_tag(st1), 4), p_drop(st1), st1)
      Bool.pick(PStep, p_is_indent(st2), SEval{GBlock{}, p_drop(st2), ks}, SEval{GExpr{}, st2, ks})
    case GBlock{}:
      +st1 = p_skip_nls(st)
      Bool.pick(PStep, p_at_end(st1), SApply{VExpr{EUnit{}}, p_eat_dedent(st1), ks}, Bool.pick(PStep, p_scan_assign(p_toks(st1), 61), SEval{GPat{}, st1, Con{KBlkLetPat{p_is_sym(st1, 45)}, ks}}, SEval{GExpr{}, st1, Con{KBlkExpr{}, ks}}))
    case GPat{}: p_ev_pat(st, ks, p_peek(st))
    case GParam{er, dup, mode}: p_ev_param(er, dup, mode, st, ks, p_peek(st))
    case GExprList{+cc, +acc}:
      +st1 = Bool.pick(PState, U32.is_eq(cc, 62), p_skip_ws(st), st)
      Bool.pick(PStep, p_stop_at(st1, cc), SApply{VExprs{b5k_list_rev(Expr, acc)}, Bool.pick(PState, U32.is_eq(cc, 58), st1, p_eat_close(st1, cc, "expected closing delimiter")), ks}, SEval{Bool.pick(PGoal, U32.is_eq(cc, 58), GArrow{False{}}, Bool.pick(PGoal, U32.is_eq(cc, 62), GTypeArg{}, GExpr{})), st1, Con{KExprList{cc, acc}, ks}})
    case GPatList{+cc, +eat, +acc}: Bool.pick(PStep, p_stop_at(st, cc), SApply{VPats{b5k_list_rev(Pat, acc)}, Bool.pick(PState, eat, p_eat_sym(st, cc, "expected closing delimiter"), st), ks}, SEval{GPat{}, st, Con{KPatList{cc, eat, acc}, ks}})
    case GParams{+cc, +acc}:
      +st1 = Bool.pick(PState, U32.is_eq(cc, 62), p_skip_ws(st), st)
      Bool.pick(PStep, p_stop_at(st1, cc), SApply{VParams{b5k_list_rev(Param, acc)}, p_eat_close(st1, cc, "expected closing delimiter"), ks}, SEval{GParam{False{}, False{}, Bool.pick(U32, U32.is_eq(cc, 62), 1, 0)}, st1, Con{KParams{cc, acc}, ks}})
    case GCases{+acc}:
      +st1 = p_skip_nls(st)
      +st2 = Bool.pick(PState, Bool.and(Bool.or(p_is_indent(st1), U32.is_eq(p_tok_tag(st1), 4)), p_is_kw(p_drop(st1), 6)), p_drop(st1), st1)
      Bool.pick(PStep, p_at_end(st2), SApply{VCases{b5k_list_rev(Case, acc)}, p_eat_dedent(st2), ks}, SEval{GPatList{58, False{}, Nil{}}, p_eat_kw(st2, 6, "expected 'case'"), Con{KCaseHead{acc}, ks}})
    case GLamMat{+acc}:
      +st1 = p_skip_ws(st)
      Bool.pick(PStep, p_stop_at(st1, 125), SApply{VExpr{ELam{Con{Param{0, None{}, False{}, True{}}, Nil{}}, EMat{Con{EVar{0}, Nil{}}, b5k_list_rev(Case, acc)}}}, p_eat_sym(st1, 125, "expected '}'"), ks}, p_lam_mat_step(acc, st1, ks))
    case GDo{+acc}:
      +st0 = p_skip_nls(st)
      +st1 = Bool.pick(PState, p_is_indent(st0), p_drop(st0), st0)
      +ts = p_toks(st1)
      +do_end = Bool.or(p_at_end(st1), Bool.or(p_is_sym(st1, 41), Bool.or(p_is_sym(st1, 93), Bool.or(p_is_sym(st1, 125), p_is_sym(st1, 44)))))
      Bool.pick(PStep, do_end, SApply{VStmts{b5k_list_rev(Stmt, acc)}, p_eat_dedent(st1), ks}, Bool.pick(PStep, p_is_kw(st1, 10), SEval{GExpr{}, p_drop(st1), Con{KDoStmt{acc, True{}}, ks}}, Bool.pick(PStep, p_scan_assign(ts, 266), SEval{GPat{}, st1, Con{KDoPat{acc, True{}}, ks}}, Bool.pick(PStep, p_scan_assign(ts, 61), SEval{GPat{}, st1, Con{KDoPat{acc, False{}}, ks}}, SEval{GExpr{}, st1, Con{KDoStmt{acc, False{}}, ks}}))))
    case GCtors{True{}, +acc}:
      +st1 = p_skip_nls(st)
      Bool.pick(PStep, p_at_end(st1), SApply{VCtors{b5k_list_rev(CtorDef, acc)}, p_eat_dedent(st1), ks}, p_ev_ctor_k(True{}, acc, st1, ks))
    case GCtors{False{}, +acc}:
      +st1 = p_skip_nls(st)
      Bool.pick(PStep, Bool.or(p_has_err(st1), Bool.not(p_is_ident(st1))), SApply{VCtors{b5k_list_rev(CtorDef, acc)}, st1, ks}, p_ev_ctor_k(False{}, acc, st1, ks))
    case GLawBody{+lsym, +pms, +ts, +ds, +ls}:
      +st1 = p_skip_nls(st)
      Bool.pick(PStep, p_is_kw(st1, 13), SEval{GParam{False{}, False{}, 0}, p_drop(st1), Con{KLaw{0, lsym, pms, ts, ds, ls}, Nil{}}}, Bool.pick(PStep, p_is_ident_eq(st1, "exs"), SEval{GParam{False{}, False{}, 0}, p_drop(st1), Con{KLaw{1, lsym, pms, ts, ds, ls}, Nil{}}}, Bool.pick(PStep, p_is_ident_eq(st1, "where"), SEval{GExpr{}, p_drop(st1), Con{KLaw{1, lsym, pms, ts, ds, ls}, Nil{}}}, SEval{GExpr{}, st1, Con{KLaw{2, lsym, pms, ts, ds, ls}, Nil{}}})))
    case GFimp{+path}:
      +st1 = p_skip_nls(st)
      Bool.pick(PStep, U32.is_ge(p_tok_tag(st1), 4), SApply{VStr{path}, p_eat_dedent(st1), ks}, Bool.pick(PStep, p_is_kw(st1, 11), p_ev_fimp_k(path, p_drop(st1), ks), SEval{GFimp{path}, p_skip(1, st1), ks}))
def p_clear_hd_ty(ps: List<&2, Param>) -> List<&2, Param>:
  match ps:
    case Con{Param{sym, _, er, dup}, t}: Con{Param{sym, None{}, er, dup}, t}
    case Nil{}: Nil{}
def p_ilet_cont(+st: PState) -> Bool:
  Bool.not(Bool.or(p_at_end(st), Bool.or(p_is_nl(st), Bool.or(p_is_sym(st, 41), Bool.or(p_is_sym(st, 93), Bool.or(p_is_sym(st, 125), p_is_sym(st, 44)))))))
def p_fork_start(ps: List<&2, Pat>, st: PState, ks: List<&2, PKont>) -> PStep:
  match ps:
    case Con{p0, rest}: SEval{GExpr{}, st, Con{KBlkForkExprs{p0, rest, False{}}, ks}}
    case Nil{}: SApply{VExpr{EUnit{}}, p_fail(st, "expected pattern in let"), ks}
def p_apply_k(k: PKont, v: PVal, +st: PState, +ks: List<&2, PKont>) -> PStep:
  match k v:
    case KPatList{cc, eat, acc} VPat{p}: SEval{GPatList{cc, eat, Con{p, acc}}, p_opt_drop(st, 44), ks}
    case KPatCtr{id} VPats{fs}: p_pat_done(PCtr{id, fs}, st, ks)
    case KPatSucc{n, sid} VPat{sub}: p_pat_done(p_wrap_succ(U32.to_nat(n), sid, sub), st, ks)
    case KPatCons{lhs} VPat{rhs}: p_pat_cons(lhs, rhs, p_intern(st, "Con"), ks)
    case KPWrap{is_list} VPats{+ps}: p_pat_done(Bool.pick(Pat, is_list, PList{ps}, p_pair_pat(ps)), st, ks)
    case KParamTy{id, er, dup} VExpr{ty}: SApply{VParam{Param{id, Some{ty}, er, dup}}, st, ks}
    case KParams{cc, acc} VParam{pm}: SEval{GParams{cc, Con{pm, acc}}, p_opt_drop(st, 44), ks}
    case KExprList{+cc, +acc} VExpr{+e}: Bool.pick(PStep, Bool.and(U32.is_eq(cc, 41), p_is_sym(st, 58)), SEval{GExpr{}, p_drop(st), Con{KParenTy{acc, e}, ks}}, SEval{GExprList{cc, Con{e, acc}}, p_opt_drop(st, 44), ks})
    case KWrapExprs{is_list} VExprs{+es}: SEval{GPost{Bool.pick(Expr, is_list, EList{es}, p_pair_expr(es))}, st, ks}
    case KParenTy{acc, e} VExpr{ty}: SApply{VExprs{b5k_list_rev(Expr, Con{EAnn{e, ty}, acc})}, p_eat_sym(st, 41, "expected ')'"), ks}
    case KBrace{} VExpr{+e}: Bool.pick(PStep, p_is_sym(st, 58), SEval{GExpr{}, p_drop(st), Con{KBraceTy{e}, ks}}, SEval{GPost{e}, p_eat_sym(st, 125, "expected '}'"), ks})
    case KBraceTy{e} VExpr{ty}: SEval{GPost{EAnn{e, ty}}, p_eat_sym(st, 125, "expected '}'"), ks}
    case KBrackFirst{} VExpr{+e0}: Bool.pick(PStep, p_is_sym(st, 58), SEval{GUnary{}, p_drop(st), Con{KArrTy{e0}, ks}}, SEval{GExprList{93, Con{e0, Nil{}}}, p_opt_drop(st, 44), Con{KWrapExprs{True{}}, ks}})
    case KArrTy{e0} VExpr{_}: SEval{GExpr{}, Bool.pick(PState, Bool.or(p_is_sym(st, 42), p_is_sym(st, 94)), p_drop(st), p_fail(st, "expected '*' or '^' in array literal")), Con{KArrLen{e0}, ks}}
    case KArrLen{e0} VExpr{len}: SEval{GPost{EArrNew{Con{e0, Con{len, Nil{}}}}}, p_eat_sym(st, 93, "expected ']'"), ks}
    case KPostCall{+lhs, is_ctr} VExprs{+args}: SEval{GPost{Bool.pick(Expr, is_ctr, p_ctr_wrap(lhs, args), EApp{lhs, args})}, st, ks}
    case KPostArrIdx{+lhs} VExpr{+idx}:
      +st2 = p_eat_sym(st, 93, "expected ']'")
      Bool.pick(PStep, p_is_sym(st2, 266), SEval{GExpr{}, p_drop(st2), Con{KPostArrSet{lhs, idx}, ks}}, SEval{GPost{EArrGet{lhs, idx}}, st2, ks})
    case KPostArrSet{lhs, idx} VExpr{val}: SEval{GPost{EArrSet{lhs, idx, val}}, st, ks}
    case KUnOp{op} VExpr{e}: SApply{VExpr{EUnOp{op, e}}, st, ks}
    case KBinRhs0{+mp, +prec, +op, lhs} VExpr{r0}:
      +next_p = Bool.pick(U32, U32.is_eq(op, 30), prec, U32.add(prec, 1))
      rhs_mp = Bool.pick(U32, U32.is_ge(mp, 16), U32.add(16, next_p), next_p)
      SEval{GBin{rhs_mp, r0}, st, Con{KBinRhs{mp, op, lhs}, ks}}
    case KBinRhs{mp, 30, lhs} VExpr{rhs}: p_bin_cons(mp, lhs, rhs, p_intern(st, "Con"), ks)
    case KBinRhs{mp, op, lhs} VExpr{rhs}: SEval{GBin{mp, EOp{op, lhs, rhs}}, st, ks}
    case KArrowBin{+no_gt} VExpr{e0}: SEval{GBin{Bool.pick(U32, no_gt, 17, 1), e0}, st, Con{KArrowLhs{no_gt}, ks}}
    case KArrowLhs{no_gt} VExpr{+lhs}: Bool.pick(PStep, p_is_sym(st, 256), SEval{Bool.pick(PGoal, no_gt, GTypeArg{}, GExpr{}), p_skip_nls(p_drop(st)), Con{KPiBody{Param{0, Some{lhs}, False{}, False{}}}, ks}}, SApply{VExpr{lhs}, st, ks})
    case KMatchScruts{} VExprs{+sc}:
      +st3 = p_skip_nls(p_eat_sym(st, 58, "expected ':' after match"))
      Bool.pick(PStep, p_is_indent(st3), SEval{GCases{Nil{}}, p_drop(st3), Con{KMatchCases{sc}, ks}}, Bool.pick(PStep, p_is_kw(st3, 6), SEval{GCases{Nil{}}, st3, Con{KMatchCases{sc}, ks}}, SApply{VExpr{EMat{sc, Nil{}}}, st3, ks}))
    case KMatchCases{sc} VCases{cs}: SApply{VExpr{EMat{sc, cs}}, st, ks}
    case KCaseHead{acc} VPats{pats}: SEval{GSuite{}, p_eat_sym(st, 58, "expected ':' after case"), Con{KCaseBody{acc, pats}, ks}}
    case KCaseBody{acc, pats} VExpr{body}: SEval{GCases{Con{Case{pats, body}, acc}}, st, ks}
    case KIfCond{} VExpr{cond}: SEval{GSuite{}, p_eat_sym(st, 58, "expected ':' after if"), Con{KIfThen{cond}, ks}}
    case KIfThen{+cond} VExpr{+thn}:
      +st4 = p_skip_nls(st)
      +st5 = p_drop(st4)
      Bool.pick(PStep, p_is_kw(st4, 8), Bool.pick(PStep, p_is_kw(st5, 7), SEval{GExpr{}, p_drop(st5), Con{KIfCond{}, Con{KIfElse{cond, thn}, ks}}}, SEval{GSuite{}, p_eat_sym(st5, 58, "expected ':' after else"), Con{KIfElse{cond, thn}, ks}}), SApply{VExpr{EIf{cond, thn, EUnit{}}}, st4, ks})
    case KIfElse{cond, thn} VExpr{els}: SApply{VExpr{EIf{cond, thn, els}}, st, ks}
    case KDoStmt{acc, True{}} VExpr{val}: SApply{VStmts{b5k_list_rev(Stmt, Con{StRet{val}, acc})}, p_eat_dedent(p_opt_drop(st, 59)), ks}
    case KDoStmt{acc, False{}} VExpr{val}: SEval{GDo{Con{p_do_stmt_mk(val), acc}}, p_opt_drop(st, 59), ks}
    case KDoPat{+acc, +is_bind} VPat{+pt}:
      +sym = Bool.pick(U32, is_bind, 266, 61)
      +msg = Bool.pick(String, is_bind, "expected '<-'", "expected '='")
      Bool.pick(PStep, p_is_sym(st, 58), SEval{GArrow{False{}}, p_drop(st), Con{KEatExpr{sym, msg}, Con{KDoVal{acc, pt, is_bind}, ks}}}, Bool.pick(PStep, Bool.and(is_bind, Bool.or(p_is_sym(st, 60), p_is_sym(st, 40))), SEval{GPost{EHole{}}, st, Con{KEatExpr{266, "expected '<-'"}, Con{KDoVal{acc, PWild{}, True{}}, ks}}}, SEval{GSuite{}, p_eat_sym(st, sym, msg), Con{KDoVal{acc, Bool.pick(Pat, is_bind, p_do_bind_pat(st, pt), pt), is_bind}, ks}}))
    case KEatExpr{sym, msg} VExpr{_}: SEval{GSuite{}, p_eat_sym(st, sym, msg), ks}
    case KDoVal{acc, +pt, is_bind} VExpr{+val}: SEval{GDo{Con{Bool.pick(Stmt, is_bind, StBind{pt, val}, StLet{pt, val}), acc}}, p_opt_drop(st, 59), ks}
    case KDoWrap{} VStmts{ss}: SApply{VExpr{EDo{ss}}, st, ks}
    case KBlkLetPat{+er} VPat{+pt}: Bool.pick(PStep, p_is_sym(st, 61), SEval{GSuite{}, p_drop(st), Con{KBlkLetVal{pt, er}, ks}}, Bool.pick(PStep, p_is_sym(st, 58), SEval{GArrow{False{}}, p_drop(st), Con{KEatExpr{61, "expected '=' in let"}, Con{KBlkLetVal{pt, er}, ks}}}, SEval{GPat{}, st, Con{KBlkForkPats{Con{pt, Nil{}}}, ks}}))
    case KBlkForkPats{+ps} VPat{+p}: Bool.pick(PStep, p_is_sym(st, 61), p_fork_start(b5k_list_rev(Pat, Con{p, ps}), p_drop(st), ks), Bool.pick(PStep, Bool.or(p_has_err(st), p_is_eof(st)), SApply{VExpr{EUnit{}}, p_fail(st, "expected '=' in let"), ks}, SEval{GPat{}, st, Con{KBlkForkPats{Con{p, ps}}, ks}}))
    case KBlkForkExprs{cur, Nil{}, ind} VExpr{e}: SEval{GBlock{}, p_opt_drop(Bool.pick(PState, ind, p_eat_dedent(p_skip_nls(st)), st), 59), Con{KBlkLetBody{cur, e}, ks}}
    case KBlkForkExprs{cur, Con{p_next, p_rest}, +ind} VExpr{e}:
      +st1 = p_skip_nls(st)
      +is_ind = Bool.and(Bool.not(ind), p_is_indent(st1))
      SEval{GExpr{}, Bool.pick(PState, is_ind, p_drop(st1), st1), Con{KBlkForkExprs{p_next, p_rest, Bool.or(ind, is_ind)}, Con{KBlkLetBody{cur, e}, ks}}}
    case KBlkLetVal{pt, er} VExpr{+val}: SEval{GBlock{}, p_opt_drop(st, 59), Con{KBlkLetBody{pt, Bool.pick(Expr, er, EAnn{val, ERefl{}}, val)}, ks}}
    case KBlkLetBody{pt, val} VExpr{body}: SApply{VExpr{ELet{pt, val, body}}, st, ks}
    case KBlkExpr{} VExpr{+e}:
      +st4 = p_skip_nls(p_opt_drop(st, 59))
      Bool.pick(PStep, U32.is_ge(p_tok_tag(st4), 4), SApply{VExpr{e}, p_eat_dedent(st4), ks}, SEval{GBlock{}, st4, Con{KBlkLetBody{p_arrset_pat(e), e}, ks}})
    case KILetPat{} VPat{+pt}: Bool.pick(PStep, p_is_sym(st, 58), SEval{GArrow{False{}}, p_drop(st), Con{KEatExpr{61, "expected '=' in let"}, Con{KILetVal{pt}, ks}}}, SEval{GExpr{}, p_eat_sym(st, 61, "expected '=' in let"), Con{KILetVal{pt}, ks}})
    case KILetVal{+pt} VExpr{+val}: Bool.pick(PStep, p_is_sym(st, 59), SEval{GExpr{}, p_drop(st), Con{KBlkLetBody{pt, val}, ks}}, Bool.pick(PStep, p_ilet_cont(st), SEval{GExpr{}, st, Con{KBlkLetBody{pt, val}, ks}}, SApply{VExpr{ELet{pt, val, EUnit{}}}, st, ks}))
    case KLam{no_gt} VParams{pms}: SEval{Bool.pick(PGoal, no_gt, GTypeArg{}, GSuite{}), p_eat_sym(st, 257, "expected '=>'"), Con{KLamBody{pms}, ks}}
    case KLam{no_gt} VParam{pm}: SEval{Bool.pick(PGoal, no_gt, GTypeArg{}, GSuite{}), p_eat_sym(st, 257, "expected '=>'"), Con{KLamBody{Con{pm, Nil{}}}, ks}}
    case KLamBody{pms} VExpr{body}: SApply{VExpr{ELam{pms, body}}, st, ks}
    case KPiPm{no_gt} VParam{pm}: SEval{Bool.pick(PGoal, no_gt, GTypeArg{}, GArrow{False{}}), p_skip_nls(p_eat_sym(st, 256, "expected '->'")), Con{KPiBody{pm}, ks}}
    case KPiBody{pm} VExpr{body}: SApply{VExpr{EAll{pm, body}}, st, ks}
    case KBinOnly{no_gt} VExpr{e0}: SEval{GBin{Bool.pick(U32, no_gt, 17, 1), e0}, st, ks}
    case KRewrite{0} VExpr{_}: Bool.pick(PStep, p_is_sym(st, 64), SEval{GUnary{}, p_drop(st), Con{KRewrite{0}, ks}}, Bool.pick(PStep, p_is_sym(st, 58), SEval{GExpr{}, p_drop(st), Con{KRewrite{1}, ks}}, SApply{VExpr{ERefl{}}, st, ks}))
    case KRewrite{1} VExpr{_}: Bool.pick(PStep, p_is_sym(st, 59), SEval{GExpr{}, p_skip_nls(p_drop(st)), Con{KRewrite{2}, ks}}, SApply{VExpr{ERefl{}}, st, ks})
    case KRewrite{_} VExpr{b}: SApply{VExpr{EAnn{b, EHole{}}}, st, ks}
    case KLamMatArm{acc} VExpr{body}: SEval{GLamMat{Con{Case{Con{PWild{}, Nil{}}, body}, acc}}, p_opt_drop(st, 59), ks}
    case KCtorFs{ind, csym, cid, acc} VParams{fs}: SEval{GCtors{ind, Con{CtorDef{csym, cid, fs}, acc}}, st, ks}
    case KTypePms{tsym, ts, ds, ls} VParams{pms}: p_type_body_go(tsym, pms, st, ts, ds, ls)
    case KTypeCtors{tsym, pms, is_data, ts, ds, ls} VCtors{cs}: SEval{GTop{Con{TypeDef{tsym, pms, is_data, cs}, ts}, ds, ls}, st, Nil{}}
    case KLaw{0, lsym, pms, ts, ds, ls} VParam{pm}: SEval{GLawBody{lsym, Con{pm, pms}, ts, ds, ls}, st, Nil{}}
    case KLaw{1, lsym, pms, ts, ds, ls} VExpr{_}: SEval{GLawBody{lsym, p_clear_hd_ty(pms), ts, ds, ls}, st, Nil{}}
    case KLaw{1, lsym, pms, ts, ds, ls} VParam{_}: SEval{GLawBody{lsym, pms, ts, ds, ls}, st, Nil{}}
    case KLaw{_, lsym, pms, ts, ds, ls} VExpr{ret}: SEval{GTop{ts, ds, Con{LawDef{lsym, b5k_list_rev(Param, pms), ret}, ls}}, p_eat_dedent(st), Nil{}}
    case KDefPms{dsym, ts, ds, ls} VParams{pms}: p_def_ret_go(dsym, pms, st, ts, ds, ls)
    case KDefRet{dsym, pms, ts, ds, ls} VExpr{ret}: p_def_body_go(dsym, pms, Some{ret}, st, ts, ds, ls)
    case KDefBody{dsym, pms, ret, ts, ds, ls} VExpr{body}: SEval{GTop{ts, Con{Def{dsym, pms, ret, body, False{}, ""}, ds}, ls}, st, Nil{}}
    case KDefBody{dsym, pms, ret, ts, ds, ls} VStr{path}: SEval{GTop{ts, Con{Def{dsym, pms, ret, EUnit{}, True{}, path}, ds}, ls}, st, Nil{}}
    case _ _: SDone{Nil{}, Nil{}, Nil{}, p_fail(st, "internal parser continuation mismatch")}
# Driver Loop & Entry Point
def p_chunk(fuel: Nat, step: PStep) -> PStep:
  match fuel step:
    case _ SDone{ts, ds, ls, st}: SDone{ts, ds, ls, st}
    case 0n s: s
    case 1n+f SEval{g, st, ks}: p_chunk(f, p_eval(g, st, ks))
    case 1n+f SApply{_, st, Nil{}}: SDone{Nil{}, Nil{}, Nil{}, p_fail(st, "unexpected empty continuation")}
    case 1n+f SApply{v, st, Con{k, rest}}: p_chunk(f, p_apply_k(k, v, st, rest))
def p_run(outer: Nat, step: PStep) -> ParseRes:
  match outer step:
    case _ SDone{ts, ds, ls, PState{_, syms, _, +err}}: ParseRes{String.is_empty(err), err, Book{ts, ds, ls, syms}}
    case 0n SEval{_, PState{_, syms, _, _}, _}: ParseRes{False{}, "parser fuel exhausted", Book{Nil{}, Nil{}, Nil{}, syms}}
    case 0n SApply{_, PState{_, syms, _, _}, _}: ParseRes{False{}, "parser fuel exhausted", Book{Nil{}, Nil{}, Nil{}, syms}}
    case 1n+f s: p_run(f, p_chunk(U32.to_nat(512), s))
def b5k_parse_lex_if(toks: List<&2, Tok>, syms1: SymTab, lerr: String, ok: Bool) -> ParseRes:
  match ok:
    case False{}: ParseRes{False{}, lerr, Book{Nil{}, Nil{}, Nil{}, syms1}}
    case True{}: p_run(U32.to_nat(4096), SEval{GTop{Nil{}, Nil{}, Nil{}}, PState{toks, syms1, 0, ""}, Nil{}})
def b5k_parse_lex(lr: LexRes) -> ParseRes:
  LexRes{toks, syms1, +lerr} = lr
  b5k_parse_lex_if(toks, syms1, lerr, String.is_empty(lerr))
def b5k_parse(src: String, syms: SymTab) -> ParseRes: b5k_parse_lex(b5k_lex(src, syms))
