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
  GParam{erased: Bool, dup: Bool, no_gt: Bool}
  GExprList{cc: U32, acc: List<&2, Expr>}
  GPatList{cc: U32, acc: List<&2, Pat>}
  GCasePats{acc: List<&2, Pat>}
  GParams{cc: U32, acc: List<&2, Param>}
  GScruts{acc: List<&2, Expr>}
  GCases{acc: List<&2, Case>}
  GDo{acc: List<&2, Stmt>}
  GCtors{acc: List<&2, CtorDef>}
  GLawBody{lsym: U32, pms: List<&2, Param>, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  GFimp{path: String}
  GIf{}
type PKont is Data:
  KPatList{cc: U32, acc: List<&2, Pat>}
  KPatCtr{id: U32}
  KPatSucc{n: U32, sid: U32}
  KPatCons{lhs: Pat}
  KPairPat{}
  KPList{}
  KCasePats{acc: List<&2, Pat>}
  KParamTy{id: U32, erased: Bool, dup: Bool}
  KParams{cc: U32, acc: List<&2, Param>}
  KExprList{cc: U32, acc: List<&2, Expr>}
  KParen{}
  KParenTy{e: Expr}
  KBrace{}
  KBraceTy{e: Expr}
  KBrackFirst{}
  KArrTy{e0: Expr}
  KArrLen{e0: Expr}
  KList{}
  KPostApp{lhs: Expr}
  KPostCtr{lhs: Expr}
  KPostArrIdx{lhs: Expr}
  KPostArrSet{lhs: Expr, idx: Expr}
  KUnaryPost{}
  KUnOp{op: U32}
  KBinRhs0{min_p: U32, prec: U32, op: U32, lhs: Expr}
  KBinRhs{min_p: U32, op: U32, lhs: Expr}
  KArrowBin{no_gt: Bool}
  KArrowLhs{no_gt: Bool}
  KArrowRhs{lhs: Expr}
  KScruts{acc: List<&2, Expr>}
  KMatchScruts{}
  KMatchCases{sc: List<&2, Expr>}
  KCaseBody{acc: List<&2, Case>, pats: List<&2, Pat>}
  KCaseHead{acc: List<&2, Case>}
  KIfCond{}
  KIfThen{cond: Expr}
  KIfElse{cond: Expr, thn: Expr}
  KDoRet{acc: List<&2, Stmt>}
  KDoBindPat{acc: List<&2, Stmt>}
  KDoBindVal{acc: List<&2, Stmt>, pt: Pat}
  KDoLetPat{acc: List<&2, Stmt>}
  KDoLetVal{acc: List<&2, Stmt>, pt: Pat}
  KDoPatTy{acc: List<&2, Stmt>, pt: Pat, is_bind: Bool}
  KDoExpr{acc: List<&2, Stmt>}
  KDoWrap{}
  KBlkLetPat{}
  KBlkLetTy{pt: Pat}
  KBlkForkP2{p1: Pat}
  KBlkForkE1{p1: Pat, p2: Pat}
  KBlkForkE2{p1: Pat, p2: Pat, e1: Expr}
  KBlkLetVal{pt: Pat}
  KBlkLetBody{pt: Pat, val: Expr}
  KBlkExpr{}
  KBlkExprRest{e: Expr}
  KILetPat{}
  KILetVal{pt: Pat}
  KILetBody{pt: Pat, val: Expr}
  KLamPms{no_gt: Bool}
  KLamPm{no_gt: Bool}
  KLamBody{pms: List<&2, Param>}
  KPiPm{}
  KPiBody{pm: Param}
  KCtorFs{csym: U32, cid: U32, acc: List<&2, CtorDef>}
  KTypePms{tsym: U32, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KTypeCtors{tsym: U32, pms: List<&2, Param>, is_data: Bool, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KLawPm{lsym: U32, pms: List<&2, Param>, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KLawRet{lsym: U32, pms: List<&2, Param>, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KDefPms{dsym: U32, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KDefRet{dsym: U32, pms: List<&2, Param>, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KDefBody{dsym: U32, pms: List<&2, Param>, ret: Maybe<&2, Expr>, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KDefFimp{dsym: U32, pms: List<&2, Param>, ret: Maybe<&2, Expr>, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
type PStep is Data:
  SEval{g: PGoal, st: PState, ks: List<&2, PKont>}
  SApply{v: PVal, st: PState, ks: List<&2, PKont>}
  SDone{ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>, st: PState}
type ScanStep is Data:
  ScDone{hit: Bool}
  ScNext{toks: List<&2, Tok>, d: U32}

# State & Token Helpers
# ---------------------
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
def p_is_sym(st: PState, code: U32) -> Bool:
  match st:
    case PState{Con{Tok{TkSym{c}, _}, _}, _, _, _}: U32.is_eq(c, code)
    case _: False{}
def p_is_kw(st: PState, code: U32) -> Bool:
  match st:
    case PState{Con{Tok{TkKw{c}, _}, _}, _, _, _}: U32.is_eq(c, code)
    case _: False{}
def p_is_indent(st: PState) -> Bool:
  match st:
    case PState{Con{Tok{TkIndent{}, _}, _}, _, _, _}: True{}
    case _: False{}
def p_is_dedent(st: PState) -> Bool:
  match st:
    case PState{Con{Tok{TkDedent{}, _}, _}, _, _, _}: True{}
    case _: False{}
def p_is_eof(st: PState) -> Bool:
  match st:
    case PState{Nil{}, _, _, _}: True{}
    case PState{Con{Tok{TkEof{}, _}, _}, _, _, _}: True{}
    case _: False{}
def p_skip_nls_go(toks: List<&2, Tok>) -> List<&2, Tok>:
  match toks:
    case Con{Tok{TkNewline{}, _}, t}: p_skip_nls_go(t)
    case xs: xs
def p_skip_nls(st: PState) -> PState:
  PState{toks, syms, ncid, err} = st
  PState{p_skip_nls_go(toks), syms, ncid, err}
def p_eat_sym(+st: PState, code: U32, msg: String) -> PState:
  Bool.pick(PState, p_is_sym(st, code), p_drop(st), p_fail(st, msg))
def p_is_close(+st: PState, +cc: U32) -> Bool:
  Bool.or(p_is_sym(st, cc), Bool.and(U32.is_eq(cc, 62), p_is_sym(st, 270)))
def p_split_shr(st: PState) -> PState:
  match st:
    case PState{Con{Tok{TkSym{270}, l}, t}, syms, ncid, err}: PState{Con{Tok{TkSym{62}, l}, t}, syms, ncid, err}
    case other: other
def p_split_larrow(st: PState) -> PState:
  match st:
    case PState{Con{Tok{TkSym{266}, l}, t}, syms, ncid, err}: PState{Con{Tok{TkSym{45}, l}, t}, syms, ncid, err}
    case other: other
def p_eat_close(+st: PState, +cc: U32, msg: String) -> PState:
  Bool.pick(PState, Bool.and(U32.is_eq(cc, 62), p_is_sym(st, 270)), p_split_shr(st), p_eat_sym(st, cc, msg))
def p_eat_kw(+st: PState, code: U32, msg: String) -> PState:
  Bool.pick(PState, p_is_kw(st, code), p_drop(st), p_fail(st, msg))
def p_eat_dedent(st: PState) -> PState:
  +st1 = p_skip_nls(st)
  Bool.pick(PState, p_is_dedent(st1), p_drop(st1), st1)
def p_sym_eq(st: PState, id: U32, s: String) -> Bool:
  PState{_, syms, _, _} = st
  String.eq(symtab_name(syms, id), s)
def p_skip_to_nl_go(toks: List<&2, Tok>) -> List<&2, Tok>:
  match toks:
    case Nil{}: Nil{}
    case Con{Tok{TkNewline{}, _}, t}: t
    case Con{Tok{TkEof{}, l}, t}: Con{Tok{TkEof{}, l}, t}
    case Con{_, t}: p_skip_to_nl_go(t)
def p_skip_to_nl(st: PState) -> PState:
  PState{toks, syms, ncid, err} = st
  PState{p_skip_to_nl_go(toks), syms, ncid, err}
def p_skip_kind_go(toks: List<&2, Tok>) -> List<&2, Tok>:
  match toks:
    case Nil{}: Nil{}
    case Con{Tok{TkSym{58}, l}, t}: Con{Tok{TkSym{58}, l}, t}
    case Con{Tok{TkEof{}, l}, t}: Con{Tok{TkEof{}, l}, t}
    case Con{_, t}: p_skip_kind_go(t)
def p_skip_kind(st: PState) -> PState:
  PState{toks, syms, ncid, err} = st
  PState{p_skip_kind_go(toks), syms, ncid, err}

# Lookahead Helpers (Pure Safe Self-Recursion)
# --------------------------------------------
def p_tok_depth_d(+c: U32, +d: U32) -> U32:
  op = Bool.or(U32.is_eq(c, 40), Bool.or(U32.is_eq(c, 91), U32.is_eq(c, 123)))
  cl = Bool.or(U32.is_eq(c, 41), Bool.or(U32.is_eq(c, 93), U32.is_eq(c, 125)))
  Bool.pick(U32, op, U32.add(d, 1), Bool.pick(U32, Bool.and(cl, U32.is_gt(d, 0)), U32.sub(d, 1), d))
def p_assign_step(toks: List<&2, Tok>, target: U32, +d: U32) -> ScanStep:
  match toks:
    case Nil{}: ScDone{False{}}
    case Con{Tok{TkNewline{}, _}, _}: ScDone{False{}}
    case Con{Tok{TkIndent{}, _}, _}: ScDone{False{}}
    case Con{Tok{TkDedent{}, _}, _}: ScDone{False{}}
    case Con{Tok{TkEof{}, _}, _}: ScDone{False{}}
    case Con{Tok{TkSym{+c}, _}, t}:
      +z = U32.is_zero(d)
      s1 = Bool.or(U32.is_eq(c, 59), Bool.or(U32.is_eq(c, 257), U32.is_eq(c, 256)))
      stop = Bool.and(z, Bool.or(s1, Bool.or(U32.is_eq(c, 61), U32.is_eq(c, 266))))
      nxt = Bool.pick(ScanStep, stop, ScDone{False{}}, ScNext{t, p_tok_depth_d(c, d)})
      Bool.pick(ScanStep, Bool.and(z, U32.is_eq(c, target)), ScDone{True{}}, nxt)
    case Con{_, t}: ScNext{t, d}
def p_assign_run(fuel: Nat, +target: U32, st: ScanStep) -> Bool:
  match fuel st:
    case _ ScDone{b}: b
    case 0n _: False{}
    case 1n+p ScNext{toks, d}: p_assign_run(p, target, p_assign_step(toks, target, d))
def p_scan_assign(toks: List<&2, Tok>, target: U32) -> Bool:
  match toks:
    case Con{Tok{TkKw{_}, _}, _}: False{}
    case xs: p_assign_run(64n, target, ScNext{xs, 0})
def p_is_fat(t: List<&2, Tok>) -> Bool:
  match t:
    case Con{Tok{TkSym{257}, _}, _}: True{}
    case _: False{}
def p_plam_step(toks: List<&2, Tok>, +d: U32) -> ScanStep:
  match toks:
    case Nil{}: ScDone{False{}}
    case Con{Tok{TkEof{}, _}, _}: ScDone{False{}}
    case Con{Tok{TkSym{40}, _}, t}: ScNext{t, U32.add(d, 1)}
    case Con{Tok{TkSym{41}, _}, +t}:
      Bool.pick(ScanStep, U32.is_eq(d, 1), ScDone{p_is_fat(t)}, ScNext{t, U32.sub(d, 1)})
    case Con{_, t}: ScNext{t, d}
def p_plam_run(fuel: Nat, st: ScanStep) -> Bool:
  match fuel st:
    case _ ScDone{b}: b
    case 0n _: False{}
    case 1n+p ScNext{toks, d}: p_plam_run(p, p_plam_step(toks, d))
def p_is_lam(toks: List<&2, Tok>) -> Bool:
  match toks:
    case Con{Tok{TkIdent{_}, _}, Con{Tok{TkSym{257}, _}, _}}: True{}
    case Con{Tok{TkSym{+c1}, _}, Con{Tok{TkIdent{_}, _}, Con{Tok{TkSym{257}, _}, _}}}:
      Bool.or(U32.is_eq(c1, 43), Bool.or(U32.is_eq(c1, 45), U32.is_eq(c1, 126)))
    case Con{Tok{TkSym{40}, _}, t}: p_plam_run(64n, ScNext{t, 1})
    case _: False{}
def p_after_targs(toks: List<&2, Tok>) -> Bool:
  match toks:
    case Nil{}: True{}
    case Con{Tok{TkNewline{}, _}, _}: True{}
    case Con{Tok{TkDedent{}, _}, _}: True{}
    case Con{Tok{TkEof{}, _}, _}: True{}
    case Con{Tok{TkSym{+c}, _}, _}:
      a = Bool.or(U32.is_eq(c, 40), Bool.or(U32.is_eq(c, 123), Bool.or(U32.is_eq(c, 44), U32.is_eq(c, 41))))
      b = Bool.or(U32.is_eq(c, 93), Bool.or(U32.is_eq(c, 125), Bool.or(U32.is_eq(c, 58), U32.is_eq(c, 62))))
      Bool.or(a, Bool.or(b, Bool.or(U32.is_eq(c, 256), Bool.or(U32.is_eq(c, 38), U32.is_eq(c, 59)))))
    case _: False{}
def p_targs_step(toks: List<&2, Tok>, +d: U32) -> ScanStep:
  match toks:
    case Nil{}: ScDone{False{}}
    case Con{Tok{TkNewline{}, _}, _}: ScDone{False{}}
    case Con{Tok{TkDedent{}, _}, _}: ScDone{False{}}
    case Con{Tok{TkEof{}, _}, _}: ScDone{False{}}
    case Con{Tok{TkSym{59}, _}, _}: ScDone{False{}}
    case Con{Tok{TkSym{60}, _}, t}: ScNext{t, U32.add(d, 1)}
    case Con{Tok{TkSym{62}, _}, +t}:
      Bool.pick(ScanStep, U32.is_eq(d, 1), ScDone{p_after_targs(t)}, ScNext{t, U32.sub(d, 1)})
    case Con{Tok{TkSym{270}, l}, +t}:
      d1 = Bool.pick(ScanStep, U32.is_eq(d, 1), ScDone{p_after_targs(Con{Tok{TkSym{62}, l}, t})}, ScNext{t, U32.sub(d, 2)})
      Bool.pick(ScanStep, U32.is_eq(d, 2), ScDone{p_after_targs(t)}, d1)
    case Con{_, t}: ScNext{t, d}
def p_targs_run(fuel: Nat, st: ScanStep) -> Bool:
  match fuel st:
    case _ ScDone{b}: b
    case 0n _: False{}
    case 1n+p ScNext{toks, d}: p_targs_run(p, p_targs_step(toks, d))
def p_is_targs(toks: List<&2, Tok>) -> Bool:
  match toks:
    case Con{Tok{TkSym{60}, _}, t}: p_targs_run(64n, ScNext{t, 1})
    case _: False{}

# Operator Precedence & Pair Builders
# -----------------------------------
def p_binop_prec(+c: U32) -> U32:
  cmp = Bool.or(U32.is_eq(c, 258), Bool.or(U32.is_eq(c, 259), Bool.or(U32.is_eq(c, 60), Bool.or(U32.is_eq(c, 260), Bool.or(U32.is_eq(c, 62), U32.is_eq(c, 261))))))
  bit = Bool.or(U32.is_eq(c, 124), Bool.or(U32.is_eq(c, 94), U32.is_eq(c, 38)))
  sh = Bool.or(U32.is_eq(c, 269), Bool.or(U32.is_eq(c, 270), U32.is_eq(c, 265)))
  add = Bool.or(U32.is_eq(c, 43), Bool.or(U32.is_eq(c, 45), U32.is_eq(c, 264)))
  mul = Bool.or(U32.is_eq(c, 42), Bool.or(U32.is_eq(c, 47), U32.is_eq(c, 37)))
  r = Bool.pick(U32, mul, 7, 0)
  r = Bool.pick(U32, add, 6, r)
  r = Bool.pick(U32, sh, 5, r)
  r = Bool.pick(U32, bit, 4, r)
  r = Bool.pick(U32, cmp, 3, r)
  r = Bool.pick(U32, U32.is_eq(c, 262), 2, r)
  Bool.pick(U32, U32.is_eq(c, 263), 1, r)
def p_binop_code(+c: U32) -> U32:
  r = Bool.pick(U32, U32.is_eq(c, 265), 30, B5K_OP_ADD())
  r = Bool.pick(U32, U32.is_eq(c, 261), U32.add(20, B5K_CMP_GE()), r)
  r = Bool.pick(U32, U32.is_eq(c, 62), U32.add(20, B5K_CMP_GT()), r)
  r = Bool.pick(U32, U32.is_eq(c, 260), U32.add(20, B5K_CMP_LE()), r)
  r = Bool.pick(U32, U32.is_eq(c, 60), U32.add(20, B5K_CMP_LT()), r)
  r = Bool.pick(U32, U32.is_eq(c, 259), U32.add(20, B5K_CMP_NE()), r)
  r = Bool.pick(U32, U32.is_eq(c, 258), U32.add(20, B5K_CMP_EQ()), r)
  r = Bool.pick(U32, U32.is_eq(c, 270), B5K_OP_SHR(), r)
  r = Bool.pick(U32, U32.is_eq(c, 269), B5K_OP_SHL(), r)
  r = Bool.pick(U32, U32.is_eq(c, 94), B5K_OP_XOR(), r)
  r = Bool.pick(U32, Bool.or(U32.is_eq(c, 124), U32.is_eq(c, 263)), B5K_OP_OR(), r)
  r = Bool.pick(U32, Bool.or(U32.is_eq(c, 38), U32.is_eq(c, 262)), B5K_OP_AND(), r)
  r = Bool.pick(U32, U32.is_eq(c, 37), B5K_OP_MOD(), r)
  r = Bool.pick(U32, U32.is_eq(c, 47), B5K_OP_DIV(), r)
  r = Bool.pick(U32, U32.is_eq(c, 42), B5K_OP_MUL(), r)
  r = Bool.pick(U32, U32.is_eq(c, 45), B5K_OP_SUB(), r)
  Bool.pick(U32, U32.is_eq(c, 43), B5K_OP_ADD(), r)
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
# ------------------------------------------
def p_pat_done(+p: Pat, +st: PState, +ks: List<&2, PKont>) -> PStep:
  Bool.pick(PStep, p_is_sym(st, 265), SEval{GPat{}, p_drop(st), Con{KPatCons{p}, ks}}, SApply{VPat{p}, st, ks})
def p_wrap_succ(n: Nat, +sid: U32, sub: Pat) -> Pat:
  match n:
    case 0n: sub
    case 1n+p: PCtr{sid, Con{p_wrap_succ(p, sid, sub), Nil{}}}
def p_ev_pat_plus(st1: PState, ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkIdent{id}: p_pat_done(PVar{id, True{}}, p_drop(st1), ks)
    case _: SEval{GPat{}, st1, ks}
def p_ev_pat_id(id: U32, st1: PState, ks: List<&2, PKont>, wild: Bool, ctr: Bool) -> PStep:
  match wild ctr:
    case True{} _: p_pat_done(PWild{}, st1, ks)
    case False{} True{}: SEval{GPatList{125, Nil{}}, p_drop(st1), Con{KPatCtr{id}, ks}}
    case False{} False{}: p_pat_done(PVar{id, False{}}, st1, ks)
def p_ev_pat_succ(+v: U32, r: PSym, +ks: List<&2, PKont>, dup: Bool) -> PStep:
  PSym{+sid, +st2} = r
  Bool.pick(PStep, dup, p_ev_pat_plus(st2, Con{KPatSucc{v, sid}, ks}, p_peek(st2)), SEval{GPat{}, st2, Con{KPatSucc{v, sid}, ks}})
def p_ev_pat_num(v: U32, st1: PState, ks: List<&2, PKont>, is_p: Bool, is_pp: Bool) -> PStep:
  match is_p is_pp:
    case True{} _: p_ev_pat_succ(v, p_intern(p_drop(st1), "Succ"), ks, False{})
    case False{} True{}: p_ev_pat_succ(v, p_intern(p_drop(st1), "Succ"), ks, True{})
    case False{} False{}: p_pat_done(PNum{v}, st1, ks)
def p_ev_pat(st: PState, ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkSym{43}:
      +st1 = p_drop(st)
      p_ev_pat_plus(st1, ks, p_peek(st1))
    case TkSym{45}: SEval{GPat{}, p_drop(st), ks}
    case TkSym{126}: SEval{GPat{}, p_drop(st), ks}
    case TkIdent{+id}:
      +st1 = p_drop(st)
      p_ev_pat_id(id, st1, ks, p_sym_eq(st1, id, "_"), p_is_sym(st1, 123))
    case TkNum{+v}:
      +st1 = p_drop(st)
      +nz = U32.is_gt(v, 0)
      p_ev_pat_num(v, st1, ks, Bool.and(nz, p_is_sym(st1, 43)), Bool.and(nz, p_is_sym(st1, 264)))
    case TkFlt{b}: p_pat_done(PNum{b}, p_drop(st), ks)
    case TkChr{c}: p_pat_done(PChr{c}, p_drop(st), ks)
    case TkStr{_}: p_pat_done(PWild{}, p_drop(st), ks)
    case TkSym{40}: SEval{GPatList{41, Nil{}}, p_drop(st), Con{KPairPat{}, ks}}
    case TkSym{91}: SEval{GPatList{93, Nil{}}, p_drop(st), Con{KPList{}, ks}}
    case _: SApply{VPat{PWild{}}, p_fail(st, "unexpected token in pattern"), ks}
def p_ev_param_ty(id: U32, er: Bool, dup: Bool, no_gt: Bool, st1: PState, ks: List<&2, PKont>, has_t: Bool) -> PStep:
  match has_t:
    case True{}: SEval{Bool.pick(PGoal, no_gt, GTypeArg{}, GExpr{}), p_drop(st1), Con{KParamTy{id, er, dup}, ks}}
    case False{}: SApply{VParam{Param{id, None{}, er, dup}}, st1, ks}
def p_ev_param(er: Bool, dup: Bool, no_gt: Bool, st: PState, ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkSym{43}: SEval{GParam{er, True{}, no_gt}, p_drop(st), ks}
    case TkSym{45}: SEval{GParam{True{}, dup, no_gt}, p_drop(st), ks}
    case TkSym{126}: SEval{GParam{True{}, dup, no_gt}, p_drop(st), ks}
    case TkIdent{id}:
      +st1 = p_drop(st)
      p_ev_param_ty(id, er, dup, no_gt, st1, ks, p_is_sym(st1, 58))
    case _: SApply{VParam{Param{0, None{}, er, dup}}, p_fail(st, "expected parameter name"), ks}
def p_ev_unary(st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkSym{45}: SEval{GUnary{}, p_drop(st), Con{KUnOp{0}, ks}}
    case TkSym{33}: SEval{GUnary{}, p_drop(st), Con{KUnOp{1}, ks}}
    case TkSym{126}: SEval{GUnary{}, p_drop(st), Con{KUnOp{1}, ks}}
    case TkNum{v}: SEval{GPost{ENum{v}}, p_drop(st), ks}
    case TkFlt{b}: SEval{GPost{EFlt{b}}, p_drop(st), ks}
    case TkChr{c}: SEval{GPost{EChr{c}}, p_drop(st), ks}
    case TkStr{s}: SEval{GPost{EStr{s}}, p_drop(st), ks}
    case TkIdent{id}: SEval{GPost{EVar{id}}, p_drop(st), ks}
    case TkSym{63}: SEval{GPost{EHole{}}, p_drop(st), ks}
    case TkSym{267}: SEval{GPost{ENum{1}}, p_drop(st), ks}
    case TkSym{268}: SEval{GPost{ENum{2}}, p_drop(st), ks}
    case TkSym{40}: SEval{GExprList{41, Nil{}}, p_drop(st), Con{KParen{}, Con{KUnaryPost{}, ks}}}
    case TkSym{91}:
      +st1 = p_drop(st)
      Bool.pick(PStep, p_is_sym(st1, 93), SEval{GPost{EList{Nil{}}}, p_drop(st1), ks}, SEval{GExpr{}, st1, Con{KBrackFirst{}, ks}})
    case TkSym{123}:
      +st1 = p_drop(st)
      Bool.pick(PStep, p_is_sym(st1, 125), SEval{GPost{ERefl{}}, p_drop(st1), ks}, SEval{GExpr{}, st1, Con{KBrace{}, ks}})
    case _: SApply{VExpr{EHole{}}, p_fail(st, "unexpected token in expression"), ks}
def p_ev_post_ta(lhs: Expr, st: PState, ks: List<&2, PKont>, yes: Bool) -> PStep:
  match yes:
    case True{}: SEval{GExprList{62, Nil{}}, p_drop(st), Con{KPostApp{lhs}, ks}}
    case False{}: SApply{VExpr{lhs}, st, ks}
def p_ev_post(+lhs: Expr, +st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkSym{40}: SEval{GExprList{41, Nil{}}, p_drop(st), Con{KPostApp{lhs}, ks}}
    case TkSym{33}:
      +st1 = p_drop(st)
      Bool.pick(PStep, p_is_sym(st1, 40), SEval{GExprList{41, Nil{}}, p_drop(st1), Con{KPostApp{lhs}, ks}}, SApply{VExpr{lhs}, st, ks})
    case TkSym{123}: SEval{GExprList{125, Nil{}}, p_drop(st), Con{KPostCtr{lhs}, ks}}
    case TkSym{91}: SEval{GExpr{}, p_drop(st), Con{KPostArrIdx{lhs}, ks}}
    case TkSym{60}: p_ev_post_ta(lhs, st, ks, p_is_targs(p_toks(st)))
    case _: SApply{VExpr{lhs}, st, ks}
def p_ev_bin_if(min_p: U32, prec: U32, c: U32, lhs: Expr, st: PState, ks: List<&2, PKont>, go: Bool) -> PStep:
  match go:
    case True{}: SEval{GUnary{}, p_skip_nls(p_drop(st)), Con{KBinRhs0{min_p, prec, p_binop_code(c), lhs}, ks}}
    case False{}: SApply{VExpr{lhs}, st, ks}
def p_ev_bin(+min_p: U32, lhs: Expr, st: PState, ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkSym{+c}:
      +no_gt = U32.is_ge(min_p, 16)
      +mp = Bool.pick(U32, no_gt, U32.sub(min_p, 16), min_p)
      +prec = p_binop_prec(c)
      ok = Bool.and(Bool.and(U32.is_gt(prec, 0), U32.is_ge(prec, mp)), Bool.not(Bool.and(no_gt, Bool.or(U32.is_eq(c, 62), U32.is_eq(c, 270)))))
      p_ev_bin_if(min_p, prec, c, lhs, st, ks, ok)
    case _: SApply{VExpr{lhs}, st, ks}
def p_bin_cons(mp: U32, lhs: Expr, rhs: Expr, r: PSym, ks: List<&2, PKont>) -> PStep:
  PSym{cid, st2} = r
  SEval{GBin{mp, ECtr{cid, Con{lhs, Con{rhs, Nil{}}}}}, st2, ks}
def p_bin_finish(mp: U32, op: U32, lhs: Expr, rhs: Expr, st: PState, ks: List<&2, PKont>, is_cons: Bool) -> PStep:
  match is_cons:
    case True{}: p_bin_cons(mp, lhs, rhs, p_intern(st, "Con"), ks)
    case False{}: SEval{GBin{mp, EOp{op, lhs, rhs}}, st, ks}
def p_pat_cons(lhs: Pat, rhs: Pat, r: PSym, ks: List<&2, PKont>) -> PStep:
  PSym{cid, st2} = r
  SApply{VPat{PCtr{cid, Con{lhs, Con{rhs, Nil{}}}}}, st2, ks}
def p_is_ident_k(k: TokKind) -> Bool:
  match k:
    case TkIdent{_}: True{}
    case _: False{}
def p_skip_to_colon_k(fuel: Nat, +st: PState, k: TokKind) -> PState:
  match fuel k:
    case 0n _: st
    case _ TkSym{58}: st
    case _ TkNewline{}: st
    case _ TkEof{}: st
    case 1n+f _:
      +st1 = p_drop(st)
      p_skip_to_colon_k(f, st1, p_peek(st1))
def p_ev_do_head(+st1: PState, ks: List<&2, PKont>, k: TokKind) -> PStep:
  st2 = p_skip_to_colon_k(32n, st1, k)
  +st4 = p_skip_nls(p_eat_sym(st2, 58, "expected ':' after do"))
  st5 = Bool.pick(PState, p_is_indent(st4), p_drop(st4), st4)
  SEval{GDo{Nil{}}, st5, Con{KDoWrap{}, ks}}
def p_ev_lam_if(st: PState, ks: List<&2, PKont>, paren: Bool, no_gt: Bool) -> PStep:
  match paren:
    case True{}: SEval{GParams{41, Nil{}}, p_drop(st), Con{KLamPms{no_gt}, ks}}
    case False{}: SEval{GParam{False{}, False{}, False{}}, st, Con{KLamPm{no_gt}, ks}}
def p_ev_expr_other(+st: PState, ks: List<&2, PKont>, is_l: Bool, is_a: Bool) -> PStep:
  match is_l is_a:
    case True{} _: p_ev_lam_if(st, ks, p_is_sym(st, 40), False{})
    case False{} True{}: SEval{GPat{}, st, Con{KILetPat{}, ks}}
    case False{} False{}: SEval{GArrow{False{}}, st, ks}
def p_ev_expr(+st: PState, ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkKw{5}: SEval{GScruts{Nil{}}, p_drop(st), Con{KMatchScruts{}, ks}}
    case TkKw{7}: SEval{GIf{}, p_drop(st), ks}
    case TkKw{9}:
      +st1 = p_drop(st)
      p_ev_do_head(st1, ks, p_peek(st1))
    case TkSym{64}: SEval{GParam{False{}, False{}, False{}}, p_drop(st), Con{KPiPm{}, ks}}
    case _:
      +ts = p_toks(st)
      p_ev_expr_other(st, ks, p_is_lam(ts), p_scan_assign(ts, 61))
def p_ev_do_step(acc: List<&2, Stmt>, st1: PState, ks: List<&2, PKont>, is_r: Bool, is_b: Bool, is_l: Bool) -> PStep:
  match is_r is_b is_l:
    case True{} _ _: SEval{GExpr{}, p_drop(st1), Con{KDoRet{acc}, ks}}
    case False{} True{} _: SEval{GPat{}, st1, Con{KDoBindPat{acc}, ks}}
    case False{} False{} True{}: SEval{GPat{}, st1, Con{KDoLetPat{acc}, ks}}
    case False{} False{} False{}: SEval{GExpr{}, st1, Con{KDoExpr{acc}, ks}}
def p_ev_ctor_has(+csym: U32, +cid: U32, +acc: List<&2, CtorDef>, +st3: PState, +ks: List<&2, PKont>) -> PStep:
  Bool.pick(PStep, p_is_sym(st3, 123), SEval{GParams{125, Nil{}}, p_drop(st3), Con{KCtorFs{csym, cid, acc}, ks}}, SEval{GCtors{Con{CtorDef{csym, cid, Nil{}}, acc}}, st3, ks})
def p_ev_ctor_bump(csym: U32, acc: List<&2, CtorDef>, st2: PState, ks: List<&2, PKont>) -> PStep:
  PState{toks2, syms2, +cid, err2} = st2
  p_ev_ctor_has(csym, cid, acc, PState{toks2, syms2, U32.add(cid, 1), err2}, ks)
def p_ev_ctor_k(acc: List<&2, CtorDef>, st1: PState, ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkIdent{csym}: p_ev_ctor_bump(csym, acc, p_drop(st1), ks)
    case _: SApply{VCtors{b5k_list_rev(CtorDef, acc)}, p_fail(st1, "expected ctor name"), ks}
def p_ev_fimp_k(+path: String, st2: PState, ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkStr{p}: SEval{GFimp{Bool.pick(String, String.is_empty(path), p, path)}, p_drop(st2), ks}
    case _: SEval{GFimp{path}, p_skip_to_nl(st2), ks}
def p_ev_fimp_if(path: String, st1: PState, ks: List<&2, PKont>, stop: Bool, is_i: Bool) -> PStep:
  match stop is_i:
    case True{} _: SApply{VStr{path}, p_eat_dedent(st1), ks}
    case False{} True{}:
      +st2 = p_drop(st1)
      p_ev_fimp_k(path, st2, ks, p_peek(st2))
    case False{} False{}: SEval{GFimp{path}, p_skip_to_nl(st1), ks}
def p_is_data_k(st1: PState, k: TokKind) -> Bool:
  match k:
    case TkIdent{kid}: p_sym_eq(st1, kid, "Data")
    case _: False{}
def p_type_body_go(+tsym: U32, +pms: List<&2, Param>, +st: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>) -> PStep:
  +st1 = Bool.pick(PState, p_is_kw(st, 4), p_drop(st), st)
  +is_data = p_is_data_k(st1, p_peek(st1))
  +st3 = p_skip_nls(p_eat_sym(p_skip_kind(st1), 58, "expected ':' in type"))
  Bool.pick(PStep, p_is_indent(st3), SEval{GCtors{Nil{}}, p_drop(st3), Con{KTypeCtors{tsym, pms, is_data, ts, ds, ls}, Nil{}}}, SEval{GTop{Con{TypeDef{tsym, pms, is_data, Nil{}}, ts}, ds, ls}, st3, Nil{}})
def p_top_type(st: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>, k: TokKind) -> PStep:
  match k:
    case TkIdent{+tsym}:
      +st1 = p_drop(st)
      +is_la = p_is_sym(st1, 266)
      st_tp = Bool.pick(PState, is_la, p_split_larrow(st1), p_drop(st1))
      Bool.pick(PStep, Bool.or(p_is_sym(st1, 60), is_la), SEval{GParams{62, Nil{}}, st_tp, Con{KTypePms{tsym, ts, ds, ls}, Nil{}}}, p_type_body_go(tsym, Nil{}, st1, ts, ds, ls))
    case _: SDone{ts, ds, ls, p_fail(st, "expected type name")}
def p_top_law(st: PState, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>, k: TokKind) -> PStep:
  match k:
    case TkIdent{lsym}:
      +st2 = p_skip_nls(p_eat_sym(p_drop(st), 58, "expected ':' after law"))
      st3 = Bool.pick(PState, p_is_indent(st2), p_drop(st2), st2)
      SEval{GLawBody{lsym, Nil{}, ts, ds, ls}, st3, Nil{}}
    case _: SDone{ts, ds, ls, p_fail(st, "expected law name")}
def p_def_body_go(+dsym: U32, +pms: List<&2, Param>, +ret: Maybe<&2, Expr>, st: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>) -> PStep:
  +st2 = p_skip_nls(p_eat_sym(st, 58, "expected ':' in def"))
  +st3 = p_skip_nls(p_drop(st2))
  ind_step = Bool.pick(PStep, p_is_kw(st3, 11), SEval{GFimp{""}, st3, Con{KDefFimp{dsym, pms, ret, ts, ds, ls}, Nil{}}}, SEval{GBlock{}, st3, Con{KDefBody{dsym, pms, ret, ts, ds, ls}, Nil{}}})
  Bool.pick(PStep, p_is_indent(st2), ind_step, SEval{GExpr{}, st2, Con{KDefBody{dsym, pms, ret, ts, ds, ls}, Nil{}}})
def p_def_ret_go(+dsym: U32, +pms: List<&2, Param>, +st: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>) -> PStep:
  Bool.pick(PStep, p_is_sym(st, 256), SEval{GExpr{}, p_skip_nls(p_drop(st)), Con{KDefRet{dsym, pms, ts, ds, ls}, Nil{}}}, p_def_body_go(dsym, pms, None{}, st, ts, ds, ls))
def p_top_def(st: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>, k: TokKind) -> PStep:
  match k:
    case TkIdent{+dsym}:
      +st1 = p_drop(st)
      Bool.pick(PStep, p_is_sym(st1, 40), SEval{GParams{41, Nil{}}, p_drop(st1), Con{KDefPms{dsym, ts, ds, ls}, Nil{}}}, p_def_ret_go(dsym, Nil{}, st1, ts, ds, ls))
    case _: SDone{ts, ds, ls, p_fail(st, "expected def name")}
def p_ev_top(st1: PState, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>, k: TokKind) -> PStep:
  match k:
    case TkKw{11}: SEval{GTop{ts, ds, ls}, p_skip_to_nl(st1), Nil{}}
    case TkKw{2}:
      +st2 = p_drop(st1)
      p_top_type(st2, ts, ds, ls, p_peek(st2))
    case TkKw{3}:
      +st2 = p_drop(st1)
      p_top_law(st2, ts, ds, ls, p_peek(st2))
    case TkKw{17}:
      +st2 = p_eat_kw(p_skip_nls(p_drop(st1)), 1, "expected 'def' after @unsafe")
      p_top_def(st2, ts, ds, ls, p_peek(st2))
    case TkKw{1}:
      +st2 = p_drop(st1)
      p_top_def(st2, ts, ds, ls, p_peek(st2))
    case TkDedent{}: SEval{GTop{ts, ds, ls}, p_drop(st1), Nil{}}
    case _: SDone{b5k_list_rev(TypeDef, ts), b5k_list_rev(Def, ds), b5k_list_rev(LawDef, ls), p_fail(st1, "unexpected top-level token")}

# Main Eval & Apply Dispatch (100% Non-Recursive)
# -----------------------------------------------
def p_eval(g: PGoal, +st: PState, +ks: List<&2, PKont>) -> PStep:
  match g:
    case GTop{+ts, +ds, +ls}:
      +st1 = p_skip_nls(st)
      stop = Bool.or(p_has_err(st1), p_is_eof(st1))
      Bool.pick(PStep, stop, SDone{b5k_list_rev(TypeDef, ts), b5k_list_rev(Def, ds), b5k_list_rev(LawDef, ls), st1}, p_ev_top(st1, ts, ds, ls, p_peek(st1)))
    case GExpr{}:
      Bool.pick(PStep, p_has_err(st), SApply{VExpr{EHole{}}, st, ks}, p_ev_expr(st, ks, p_peek(st)))
    case GUnary{}: p_ev_unary(st, ks, p_peek(st))
    case GPost{+lhs}:
      Bool.pick(PStep, p_has_err(st), SApply{VExpr{lhs}, st, ks}, p_ev_post(lhs, st, ks, p_peek(st)))
    case GBin{min_p, +lhs}:
      Bool.pick(PStep, p_has_err(st), SApply{VExpr{lhs}, st, ks}, p_ev_bin(min_p, lhs, st, ks, p_peek(st)))
    case GArrow{no_gt}: SEval{GUnary{}, st, Con{KArrowBin{no_gt}, ks}}
    case GTypeArg{}:
      Bool.pick(PStep, p_is_lam(p_toks(st)), p_ev_lam_if(st, ks, p_is_sym(st, 40), True{}), SEval{GArrow{True{}}, st, ks})
    case GSuite{}:
      +st1 = p_skip_nls(st)
      Bool.pick(PStep, p_is_indent(st1), SEval{GBlock{}, p_drop(st1), ks}, SEval{GExpr{}, st1, ks})
    case GBlock{}:
      +st1 = p_skip_nls(st)
      stop = Bool.or(p_has_err(st1), Bool.or(p_is_dedent(st1), p_is_eof(st1)))
      is_l = p_scan_assign(p_toks(st1), 61)
      non_stop = Bool.pick(PStep, is_l, SEval{GPat{}, st1, Con{KBlkLetPat{}, ks}}, SEval{GExpr{}, st1, Con{KBlkExpr{}, ks}})
      Bool.pick(PStep, stop, SApply{VExpr{EUnit{}}, p_eat_dedent(st1), ks}, non_stop)
    case GPat{}: p_ev_pat(st, ks, p_peek(st))
    case GParam{er, dup, no_gt}: p_ev_param(er, dup, no_gt, st, ks, p_peek(st))
    case GExprList{+cc, +acc}:
      stop = Bool.or(p_has_err(st), Bool.or(p_is_close(st, cc), p_is_eof(st)))
      elem_g = Bool.pick(PGoal, U32.is_eq(cc, 62), GTypeArg{}, GExpr{})
      Bool.pick(PStep, stop, SApply{VExprs{b5k_list_rev(Expr, acc)}, p_eat_close(st, cc, "expected closing delimiter"), ks}, SEval{elem_g, st, Con{KExprList{cc, acc}, ks}})
    case GPatList{+cc, +acc}:
      stop = Bool.or(p_has_err(st), Bool.or(p_is_sym(st, cc), p_is_eof(st)))
      Bool.pick(PStep, stop, SApply{VPats{b5k_list_rev(Pat, acc)}, p_eat_sym(st, cc, "expected closing delimiter"), ks}, SEval{GPat{}, st, Con{KPatList{cc, acc}, ks}})
    case GCasePats{+acc}:
      stop = Bool.or(p_has_err(st), Bool.or(p_is_sym(st, 58), p_is_eof(st)))
      Bool.pick(PStep, stop, SApply{VPats{b5k_list_rev(Pat, acc)}, st, ks}, SEval{GPat{}, st, Con{KCasePats{acc}, ks}})
    case GParams{+cc, +acc}:
      stop = Bool.or(p_has_err(st), Bool.or(p_is_close(st, cc), p_is_eof(st)))
      Bool.pick(PStep, stop, SApply{VParams{b5k_list_rev(Param, acc)}, p_eat_close(st, cc, "expected closing delimiter"), ks}, SEval{GParam{False{}, False{}, U32.is_eq(cc, 62)}, st, Con{KParams{cc, acc}, ks}})
    case GScruts{+acc}:
      stop = Bool.or(p_has_err(st), Bool.or(p_is_sym(st, 58), p_is_eof(st)))
      Bool.pick(PStep, stop, SApply{VExprs{b5k_list_rev(Expr, acc)}, st, ks}, SEval{GArrow{False{}}, st, Con{KScruts{acc}, ks}})
    case GCases{+acc}:
      +st1 = p_skip_nls(st)
      stop = Bool.or(p_has_err(st1), Bool.or(p_is_dedent(st1), p_is_eof(st1)))
      Bool.pick(PStep, stop, SApply{VCases{b5k_list_rev(Case, acc)}, p_eat_dedent(st1), ks}, SEval{GCasePats{Nil{}}, p_eat_kw(st1, 6, "expected 'case'"), Con{KCaseHead{acc}, ks}})
    case GDo{+acc}:
      +st1 = p_skip_nls(st)
      stop = Bool.or(p_has_err(st1), Bool.or(p_is_dedent(st1), p_is_eof(st1)))
      +ts = p_toks(st1)
      Bool.pick(PStep, stop, SApply{VStmts{b5k_list_rev(Stmt, acc)}, p_eat_dedent(st1), ks}, p_ev_do_step(acc, st1, ks, p_is_kw(st1, 10), p_scan_assign(ts, 266), p_scan_assign(ts, 61)))
    case GCtors{+acc}:
      +st1 = p_skip_nls(st)
      stop = Bool.or(p_has_err(st1), Bool.or(p_is_dedent(st1), p_is_eof(st1)))
      Bool.pick(PStep, stop, SApply{VCtors{b5k_list_rev(CtorDef, acc)}, p_eat_dedent(st1), ks}, p_ev_ctor_k(acc, st1, ks, p_peek(st1)))
    case GLawBody{+lsym, +pms, +ts, +ds, +ls}:
      +st1 = p_skip_nls(st)
      Bool.pick(PStep, p_is_kw(st1, 13), SEval{GParam{False{}, False{}, False{}}, p_drop(st1), Con{KLawPm{lsym, pms, ts, ds, ls}, Nil{}}}, SEval{GExpr{}, st1, Con{KLawRet{lsym, pms, ts, ds, ls}, Nil{}}})
    case GFimp{path}:
      +st1 = p_skip_nls(st)
      p_ev_fimp_if(path, st1, ks, Bool.or(p_is_dedent(st1), p_is_eof(st1)), p_is_kw(st1, 11))
    case GIf{}: SEval{GExpr{}, st, Con{KIfCond{}, ks}}
def p_apply_k(k: PKont, v: PVal, +st: PState, +ks: List<&2, PKont>) -> PStep:
  match k v:
    case KPatList{cc, acc} VPat{p}:
      SEval{GPatList{cc, Con{p, acc}}, Bool.pick(PState, p_is_sym(st, 44), p_drop(st), st), ks}
    case KPatCtr{id} VPats{fs}: p_pat_done(PCtr{id, fs}, st, ks)
    case KPatSucc{n, sid} VPat{sub}: p_pat_done(p_wrap_succ(U32.to_nat(n), sid, sub), st, ks)
    case KPatCons{lhs} VPat{rhs}: p_pat_cons(lhs, rhs, p_intern(st, "Con"), ks)
    case KPairPat{} VPats{ps}: p_pat_done(p_pair_pat(ps), st, ks)
    case KPList{} VPats{ps}: p_pat_done(PList{ps}, st, ks)
    case KCasePats{acc} VPat{p}:
      SEval{GCasePats{Con{p, acc}}, Bool.pick(PState, p_is_sym(st, 44), p_drop(st), st), ks}
    case KParamTy{id, er, dup} VExpr{ty}: SApply{VParam{Param{id, Some{ty}, er, dup}}, st, ks}
    case KParams{cc, acc} VParam{pm}:
      SEval{GParams{cc, Con{pm, acc}}, Bool.pick(PState, p_is_sym(st, 44), p_drop(st), st), ks}
    case KExprList{+cc, +acc} VExpr{+e}:
      is_ann = Bool.and(U32.is_eq(cc, 41), p_is_sym(st, 58))
      Bool.pick(PStep, is_ann, SEval{GExpr{}, p_drop(st), Con{KParenTy{e}, ks}}, SEval{GExprList{cc, Con{e, acc}}, Bool.pick(PState, p_is_sym(st, 44), p_drop(st), st), ks})
    case KParen{} VExprs{es}: SApply{VExpr{p_pair_expr(es)}, st, ks}
    case KParenTy{e} VExpr{ty}: SApply{VExprs{Con{EAnn{e, ty}, Nil{}}}, p_eat_sym(st, 41, "expected ')'"), ks}
    case KBrace{} VExpr{+e}:
      Bool.pick(PStep, p_is_sym(st, 58), SEval{GExpr{}, p_drop(st), Con{KBraceTy{e}, ks}}, SEval{GPost{e}, p_eat_sym(st, 125, "expected '}'"), ks})
    case KBraceTy{e} VExpr{ty}: SEval{GPost{EAnn{e, ty}}, p_eat_sym(st, 125, "expected '}'"), ks}
    case KBrackFirst{} VExpr{+e0}:
      lst_st = Bool.pick(PState, p_is_sym(st, 44), p_drop(st), st)
      Bool.pick(PStep, p_is_sym(st, 58), SEval{GUnary{}, p_drop(st), Con{KArrTy{e0}, ks}}, SEval{GExprList{93, Con{e0, Nil{}}}, lst_st, Con{KList{}, Con{KUnaryPost{}, ks}}})
    case KArrTy{e0} VExpr{_}:
      st2 = Bool.pick(PState, Bool.or(p_is_sym(st, 42), p_is_sym(st, 94)), p_drop(st), p_fail(st, "expected '*' or '^' in array literal"))
      SEval{GExpr{}, st2, Con{KArrLen{e0}, ks}}
    case KArrLen{e0} VExpr{len}: SEval{GPost{EArrNew{Con{e0, Con{len, Nil{}}}}}, p_eat_sym(st, 93, "expected ']'"), ks}
    case KList{} VExprs{es}: SApply{VExpr{EList{es}}, st, ks}
    case KPostApp{lhs} VExprs{args}: SEval{GPost{EApp{lhs, args}}, st, ks}
    case KPostCtr{lhs} VExprs{fs}: SEval{GPost{p_ctr_wrap(lhs, fs)}, st, ks}
    case KPostArrIdx{+lhs} VExpr{+idx}:
      +st2 = p_eat_sym(st, 93, "expected ']'")
      Bool.pick(PStep, p_is_sym(st2, 266), SEval{GExpr{}, p_drop(st2), Con{KPostArrSet{lhs, idx}, ks}}, SEval{GPost{EArrGet{lhs, idx}}, st2, ks})
    case KPostArrSet{lhs, idx} VExpr{val}: SEval{GPost{EArrSet{lhs, idx, val}}, st, ks}
    case KUnaryPost{} VExpr{e}: SEval{GPost{e}, st, ks}
    case KUnOp{op} VExpr{e}: SApply{VExpr{EUnOp{op, e}}, st, ks}
    case KBinRhs0{+mp, +prec, +op, lhs} VExpr{r0}:
      +next_p = Bool.pick(U32, U32.is_eq(op, 30), prec, U32.add(prec, 1))
      rhs_mp = Bool.pick(U32, U32.is_ge(mp, 16), U32.add(16, next_p), next_p)
      SEval{GBin{rhs_mp, r0}, st, Con{KBinRhs{mp, op, lhs}, ks}}
    case KBinRhs{mp, +op, lhs} VExpr{rhs}: p_bin_finish(mp, op, lhs, rhs, st, ks, U32.is_eq(op, 30))
    case KArrowBin{+no_gt} VExpr{e0}: SEval{GBin{Bool.pick(U32, no_gt, 17, 1), e0}, st, Con{KArrowLhs{no_gt}, ks}}
    case KArrowLhs{no_gt} VExpr{+lhs}:
      rhs_g = Bool.pick(PGoal, no_gt, GTypeArg{}, GExpr{})
      Bool.pick(PStep, p_is_sym(st, 256), SEval{rhs_g, p_skip_nls(p_drop(st)), Con{KArrowRhs{lhs}, ks}}, SApply{VExpr{lhs}, st, ks})
    case KArrowRhs{lhs} VExpr{rhs}: SApply{VExpr{EAll{Param{0, Some{lhs}, False{}, False{}}, rhs}}, st, ks}
    case KScruts{acc} VExpr{e}:
      SEval{GScruts{Con{e, acc}}, Bool.pick(PState, p_is_sym(st, 44), p_drop(st), st), ks}
    case KMatchScruts{} VExprs{sc}:
      +st3 = p_skip_nls(p_eat_sym(st, 58, "expected ':' after match"))
      SEval{GCases{Nil{}}, Bool.pick(PState, p_is_indent(st3), p_drop(st3), st3), Con{KMatchCases{sc}, ks}}
    case KMatchCases{sc} VCases{cs}: SApply{VExpr{EMat{sc, cs}}, st, ks}
    case KCaseHead{acc} VPats{pats}: SEval{GSuite{}, p_eat_sym(st, 58, "expected ':' after case"), Con{KCaseBody{acc, pats}, ks}}
    case KCaseBody{acc, pats} VExpr{body}: SEval{GCases{Con{Case{pats, body}, acc}}, st, ks}
    case KIfCond{} VExpr{cond}: SEval{GSuite{}, p_eat_sym(st, 58, "expected ':' after if"), Con{KIfThen{cond}, ks}}
    case KIfThen{+cond} VExpr{+thn}:
      +st4 = p_skip_nls(st)
      +st5 = p_drop(st4)
      els = Bool.pick(PStep, p_is_kw(st5, 7), SEval{GIf{}, p_drop(st5), Con{KIfElse{cond, thn}, ks}}, SEval{GSuite{}, p_eat_sym(st5, 58, "expected ':' after else"), Con{KIfElse{cond, thn}, ks}})
      Bool.pick(PStep, p_is_kw(st4, 8), els, SApply{VExpr{EIf{cond, thn, EUnit{}}}, st4, ks})
    case KIfElse{cond, thn} VExpr{els}: SApply{VExpr{EIf{cond, thn, els}}, st, ks}
    case KDoRet{acc} VExpr{val}: SEval{GDo{Con{StRet{val}, acc}}, st, ks}
    case KDoBindPat{+acc} VPat{+pt}:
      Bool.pick(PStep, p_is_sym(st, 58), SEval{GArrow{False{}}, p_drop(st), Con{KDoPatTy{acc, pt, True{}}, ks}}, SEval{GExpr{}, p_eat_sym(st, 266, "expected '<-'"), Con{KDoBindVal{acc, pt}, ks}})
    case KDoBindVal{acc, pt} VExpr{val}: SEval{GDo{Con{StBind{pt, val}, acc}}, st, ks}
    case KDoLetPat{+acc} VPat{+pt}:
      Bool.pick(PStep, p_is_sym(st, 58), SEval{GArrow{False{}}, p_drop(st), Con{KDoPatTy{acc, pt, False{}}, ks}}, SEval{GExpr{}, p_eat_sym(st, 61, "expected '='"), Con{KDoLetVal{acc, pt}, ks}})
    case KDoPatTy{+acc, +pt, is_bind} VExpr{_}:
      Bool.pick(PStep, is_bind, SEval{GExpr{}, p_eat_sym(st, 266, "expected '<-'"), Con{KDoBindVal{acc, pt}, ks}}, SEval{GExpr{}, p_eat_sym(st, 61, "expected '='"), Con{KDoLetVal{acc, pt}, ks}})
    case KDoLetVal{acc, pt} VExpr{val}: SEval{GDo{Con{StLet{pt, val}, acc}}, st, ks}
    case KDoExpr{acc} VExpr{val}: SEval{GDo{Con{StExpr{val}, acc}}, st, ks}
    case KDoWrap{} VStmts{ss}: SApply{VExpr{EDo{ss}}, st, ks}
    case KBlkLetPat{} VPat{+pt}:
      non_eq = Bool.pick(PStep, p_is_sym(st, 58), SEval{GArrow{False{}}, p_drop(st), Con{KBlkLetTy{pt}, ks}}, SEval{GPat{}, st, Con{KBlkForkP2{pt}, ks}})
      Bool.pick(PStep, p_is_sym(st, 61), SEval{GExpr{}, p_drop(st), Con{KBlkLetVal{pt}, ks}}, non_eq)
    case KBlkLetTy{pt} VExpr{_}: SEval{GExpr{}, p_eat_sym(st, 61, "expected '=' in let"), Con{KBlkLetVal{pt}, ks}}
    case KBlkForkP2{p1} VPat{p2}: SEval{GExpr{}, p_eat_sym(st, 61, "expected '=' in let"), Con{KBlkForkE1{p1, p2}, ks}}
    case KBlkForkE1{p1, p2} VExpr{e1}: SEval{GExpr{}, st, Con{KBlkForkE2{p1, p2, e1}, ks}}
    case KBlkForkE2{p1, p2, e1} VExpr{e2}:
      st5 = Bool.pick(PState, p_is_sym(st, 59), p_drop(st), st)
      SEval{GBlock{}, st5, Con{KBlkLetBody{p2, e2}, Con{KBlkLetBody{p1, e1}, ks}}}
    case KBlkLetVal{pt} VExpr{val}:
      st5 = Bool.pick(PState, p_is_sym(st, 59), p_drop(st), st)
      SEval{GBlock{}, st5, Con{KBlkLetBody{pt, val}, ks}}
    case KBlkLetBody{pt, val} VExpr{body}: SApply{VExpr{ELet{pt, val, body}}, st, ks}
    case KBlkExpr{} VExpr{+e}:
      st3 = Bool.pick(PState, p_is_sym(st, 59), p_drop(st), st)
      +st4 = p_skip_nls(st3)
      Bool.pick(PStep, Bool.or(p_is_dedent(st4), p_is_eof(st4)), SApply{VExpr{e}, p_eat_dedent(st4), ks}, SEval{GBlock{}, st4, Con{KBlkExprRest{e}, ks}})
    case KBlkExprRest{e} VExpr{rest}: SApply{VExpr{ELet{PWild{}, e, rest}}, st, ks}
    case KILetPat{} VPat{pt}: SEval{GExpr{}, p_eat_sym(st, 61, "expected '=' in let"), Con{KILetVal{pt}, ks}}
    case KILetVal{+pt} VExpr{+val}:
      Bool.pick(PStep, p_is_sym(st, 59), SEval{GExpr{}, p_drop(st), Con{KILetBody{pt, val}, ks}}, SApply{VExpr{ELet{pt, val, EUnit{}}}, st, ks})
    case KILetBody{pt, val} VExpr{body}: SApply{VExpr{ELet{pt, val, body}}, st, ks}
    case KLamPms{no_gt} VParams{pms}: SEval{Bool.pick(PGoal, no_gt, GTypeArg{}, GExpr{}), p_eat_sym(st, 257, "expected '=>'"), Con{KLamBody{pms}, ks}}
    case KLamPm{no_gt} VParam{pm}: SEval{Bool.pick(PGoal, no_gt, GTypeArg{}, GExpr{}), p_eat_sym(st, 257, "expected '=>'"), Con{KLamBody{Con{pm, Nil{}}}, ks}}
    case KLamBody{pms} VExpr{body}: SApply{VExpr{ELam{pms, body}}, st, ks}
    case KPiPm{} VParam{pm}: SEval{GExpr{}, p_skip_nls(p_eat_sym(st, 256, "expected '->'")), Con{KPiBody{pm}, ks}}
    case KPiBody{pm} VExpr{body}: SApply{VExpr{EAll{pm, body}}, st, ks}
    case KCtorFs{csym, cid, acc} VParams{fs}: SEval{GCtors{Con{CtorDef{csym, cid, fs}, acc}}, st, ks}
    case KTypePms{tsym, ts, ds, ls} VParams{pms}: p_type_body_go(tsym, pms, st, ts, ds, ls)
    case KTypeCtors{tsym, pms, is_data, ts, ds, ls} VCtors{cs}: SEval{GTop{Con{TypeDef{tsym, pms, is_data, cs}, ts}, ds, ls}, st, Nil{}}
    case KLawPm{lsym, pms, ts, ds, ls} VParam{pm}: SEval{GLawBody{lsym, Con{pm, pms}, ts, ds, ls}, st, Nil{}}
    case KLawRet{lsym, pms, ts, ds, ls} VExpr{ret}: SEval{GTop{ts, ds, Con{LawDef{lsym, b5k_list_rev(Param, pms), ret}, ls}}, p_eat_dedent(st), Nil{}}
    case KDefPms{dsym, ts, ds, ls} VParams{pms}: p_def_ret_go(dsym, pms, st, ts, ds, ls)
    case KDefRet{dsym, pms, ts, ds, ls} VExpr{ret}: p_def_body_go(dsym, pms, Some{ret}, st, ts, ds, ls)
    case KDefBody{dsym, pms, ret, ts, ds, ls} VExpr{body}: SEval{GTop{ts, Con{Def{dsym, pms, ret, body, False{}, ""}, ds}, ls}, st, Nil{}}
    case KDefFimp{dsym, pms, ret, ts, ds, ls} VStr{path}: SEval{GTop{ts, Con{Def{dsym, pms, ret, EUnit{}, True{}, path}, ds}, ls}, st, Nil{}}
    case _ _: SDone{Nil{}, Nil{}, Nil{}, p_fail(st, "internal parser continuation mismatch")}
def p_apply(v: PVal, st: PState, ks: List<&2, PKont>) -> PStep:
  match ks:
    case Nil{}: SDone{Nil{}, Nil{}, Nil{}, p_fail(st, "unexpected empty continuation")}
    case Con{k, rest}: p_apply_k(k, v, st, rest)

# Driver Loop & Entry Point
# -------------------------
def p_chunk(fuel: Nat, step: PStep) -> PStep:
  match fuel step:
    case _ SDone{ts, ds, ls, st}: SDone{ts, ds, ls, st}
    case 0n s: s
    case 1n+f SEval{g, st, ks}: p_chunk(f, p_eval(g, st, ks))
    case 1n+f SApply{v, st, ks}: p_chunk(f, p_apply(v, st, ks))
def p_run(outer: Nat, step: PStep) -> ParseRes:
  match outer step:
    case _ SDone{ts, ds, ls, PState{_, syms, _, +err}}:
      ParseRes{String.is_empty(err), err, Book{ts, ds, ls, syms}}
    case 0n SEval{_, PState{_, syms, _, _}, _}:
      ParseRes{False{}, "parser fuel exhausted", Book{Nil{}, Nil{}, Nil{}, syms}}
    case 0n SApply{_, PState{_, syms, _, _}, _}:
      ParseRes{False{}, "parser fuel exhausted", Book{Nil{}, Nil{}, Nil{}, syms}}
    case 1n+f s: p_run(f, p_chunk(U32.to_nat(512), s))
def b5k_parse_lex_if(toks: List<&2, Tok>, syms1: SymTab, lerr: String, ok: Bool) -> ParseRes:
  match ok:
    case False{}: ParseRes{False{}, lerr, Book{Nil{}, Nil{}, Nil{}, syms1}}
    case True{}: p_run(U32.to_nat(4096), SEval{GTop{Nil{}, Nil{}, Nil{}}, PState{toks, syms1, 0, ""}, Nil{}})
def b5k_parse_lex(lr: LexRes) -> ParseRes:
  LexRes{toks, syms1, +lerr} = lr
  b5k_parse_lex_if(toks, syms1, lerr, String.is_empty(lerr))
def b5k_parse(src: String, syms: SymTab) -> ParseRes:
  b5k_parse_lex(b5k_lex(src, syms))
