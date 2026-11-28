# bend5k/parse.bend — Continuation-Stack Layout-Aware Parser
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
  KArrLen{e0: Expr, is_mul: Bool}
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
  KDoHdr{msym: U32}
  KDoWrap{hdr: Expr}
  KBlkLetPat{er: Bool}
  KBlkForkPats{ps: List<&2, Pat>}
  KBlkForkExprs{cur: Pat, rem: List<&2, Pat>, ind: Bool}
  KBlkLetVal{pt: Pat, er: Bool, ty: Maybe<&2, Expr>}
  KBlkLetBody{pt: Pat, val: Expr}
  KBlkExpr{}
  KILetPat{}
  KILetVal{pt: Pat, ty: Maybe<&2, Expr>}
  KLetTy{sym: U32, msg: String, pt: Pat, er: Bool, is_blk: Bool}
  KLam{no_gt: Bool}
  KLamBody{pms: List<&2, Param>}
  KPiPm{no_gt: Bool, is_ex: Bool}
  KPiBody{pm: Param, is_ex: Bool}
  KBinOnly{no_gt: Bool}
  KRewriteEq{}
  KRewriteMot{eq: Expr}
  KRewriteBody{eq: Expr, mot: Expr}
  KLamMatArm{csym: U32, acc: List<&2, Case>}
  KCtorFs{ind: Bool, csym: U32, cid: U32, acc: List<&2, CtorDef>}
  KTypePms{tsym: U32, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KTypeCtors{tsym: U32, pms: List<&2, Param>, is_data: Bool, ksym: U32, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KLaw{kind: U32, lsym: U32, pms: List<&2, Param>, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KDefPms{dsym: U32, is_unsafe: Bool, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KDefRet{dsym: U32, is_unsafe: Bool, pms: List<&2, Param>, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
  KDefBody{dsym: U32, is_unsafe: Bool, pms: List<&2, Param>, ret: Maybe<&2, Expr>, ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>}
type PStep is Data:
  SEval{g: PGoal, st: PState, ks: List<&2, PKont>}
  SApply{v: PVal, st: PState, ks: List<&2, PKont>}
  SDone{ts: List<&2, TypeDef>, ds: List<&2, Def>, ls: List<&2, LawDef>, st: PState}
# State & Token Helpers
def p_has_err(st: PState) -> Bool:
  PState{_, _, _, err} = st; Bool.not(String.is_empty(err))
def p_fail(st: PState, msg: String) -> PState:
  PState{toks, syms, ncid, +err} = st; PState{toks, syms, ncid, Bool.pick(String, String.is_empty(err), msg, err)}
def p_peek(st: PState) -> TokKind:
  match st:
    case PState{Con{Tok{k, _}, _}, _, _, _}: k
    case _: TkEof{}
def p_toks(st: PState) -> List<&2, Tok>:
  PState{toks, _, _, _} = st; toks
def p_drop(st: PState) -> PState:
  match st:
    case PState{Con{_, t}, syms, ncid, err}: PState{t, syms, ncid, err}
    case PState{Nil{}, syms, ncid, err}: PState{Nil{}, syms, ncid, err}
def p_intern_k(toks: List<&2, Tok>, ncid: U32, err: String, sr: SymRes) -> PSym:
  SymRes{syms2, id} = sr; PSym{id, PState{toks, syms2, ncid, err}}
def p_intern(st: PState, name: String) -> PSym:
  PState{toks, syms, ncid, err} = st; p_intern_k(toks, ncid, err, symtab_intern(syms, name))
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
  PState{toks, syms, ncid, err} = st; PState{p_skip_go(toks, mode), syms, ncid, err}
def p_skip_nls(st: PState) -> PState: p_skip(0, st)
def p_skip_ws(st: PState) -> PState: p_skip(3, st)
def p_is_ident_eq(st: PState, name: String) -> Bool:
  match st:
    case PState{Con{Tok{TkIdent{id}, _}, _}, syms, _, _}: String.eq(symtab_name(syms, id), name)
    case _: False{}
def p_eat_sym(+st: PState, code: U32, msg: String) -> PState: Bool.pick(PState, p_is_sym(st, code), p_drop(st), p_fail(st, msg))
def p_eat_kw(+st: PState, code: U32, msg: String) -> PState: Bool.pick(PState, p_is_kw(st, code), p_drop(st), p_fail(st, msg))
def p_stop_at(+st: PState, +cc: U32) -> Bool: Bool.or(p_has_err(st), Bool.or(Bool.or(p_is_sym(st, cc), Bool.and(U32.is_eq(cc, 62), p_is_sym(st, 270))), p_is_eof(st)))
def p_split_sym(st: PState, from_c: U32, to_c: U32) -> PState:
  match st:
    case PState{Con{Tok{TkSym{+c}, l}, t}, syms, ncid, err}: PState{Con{Tok{TkSym{Bool.pick(U32, U32.is_eq(c, from_c), to_c, c)}, l}, t}, syms, ncid, err}
    case other: other
def p_eat_close(+st: PState, +cc: U32, msg: String) -> PState: Bool.pick(PState, Bool.and(U32.is_eq(cc, 62), p_is_sym(st, 270)), p_split_sym(st, 270, 62), p_eat_sym(st, cc, msg))
def p_drop_if(ok: Bool, +st: PState) -> PState: Bool.pick(PState, ok, p_drop(st), st)
def p_eat_dedent(st: PState) -> PState: (+st1 = p_skip_nls(st); p_drop_if(U32.is_eq(p_tok_tag(st1), 4), st1))
def p_opt_drop(+st: PState, code: U32) -> PState: p_drop_if(p_is_sym(st, code), st)
def p_sym_eq(st: PState, id: U32, s: String) -> Bool:
  PState{_, syms, _, _} = st; String.eq(symtab_name(syms, id), s)
def p_u32_mem_go(xs: List<&2, U32>, hit: Bool, +v: U32) -> Bool:
  match xs hit:
    case _ True{}: True{}
    case Nil{} False{}: False{}
    case Con{h, t} False{}: p_u32_mem_go(t, U32.is_eq(h, v), v)
def p_u32_mem(xs: List<&2, U32>, +v: U32) -> Bool: p_u32_mem_go(xs, False{}, v)
def p_str_mem(xs: List<&2, String>, +v: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, t}: Bool.or(String.eq(h, v), p_str_mem(t, v))
def p_is_nil(-A: Data, xs: List<&2, A>) -> Bool:
  match xs:
    case Nil{}: True{}
    case _: False{}
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
      +z = U32.is_zero(d); +eq = Bool.and(z, U32.is_eq(c, target))
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
    case Con{Tok{TkSym{62}, _}, +t} False{}: (+z = U32.is_zero(pd); +is1 = Bool.and(z, U32.is_eq(d, 1)); p_scan_targs(t, is1, Bool.and(is1, p_after_targs(t)), Bool.pick(U32, z, U32.sub(d, 1), d), pd))
    case Con{Tok{TkSym{270}, l}, +t} False{}: (+z = U32.is_zero(pd); +is1 = Bool.and(z, U32.is_eq(d, 1)); +is2 = Bool.and(z, U32.is_eq(d, 2)); p_scan_targs(t, Bool.or(is1, is2), Bool.pick(Bool, is2, p_after_targs(t), Bool.and(is1, p_after_targs(Con{Tok{TkSym{62}, l}, t}))), Bool.pick(U32, z, U32.sub(d, 2), d), pd))
    case Con{Tok{TkSym{c}, _}, t} False{}: p_scan_targs(t, False{}, False{}, d, lex_depth_delta(c, pd))
    case Con{_, t} False{}: p_scan_targs(t, False{}, False{}, d, pd)
def p_is_targs(toks: List<&2, Tok>) -> Bool:
  match toks:
    case Con{Tok{TkSym{60}, _}, t}: p_scan_targs(t, False{}, False{}, 1, 0)
    case _: False{}
# Operator Precedence & Pair Builders
def p_binop_info(+c: U32) -> U32:
  lo = Bool.pick(U32, U32.is_eq(c, 37), U32.add(576, B5K_OP_MOD()), Bool.pick(U32, U32.is_eq(c, 38), U32.add(384, B5K_OP_AND()), Bool.pick(U32, U32.is_eq(c, 42), U32.add(576, B5K_OP_MUL()), Bool.pick(U32, U32.is_eq(c, 45), U32.add(512, B5K_OP_SUB()), Bool.pick(U32, U32.is_eq(c, 47), U32.add(576, B5K_OP_DIV()), Bool.pick(U32, U32.is_eq(c, 60), U32.add(192, U32.add(20, B5K_CMP_LT())), Bool.pick(U32, U32.is_eq(c, 62), U32.add(192, U32.add(20, B5K_CMP_GT())), Bool.pick(U32, U32.is_eq(c, 124), U32.add(256, B5K_OP_OR()), 0))))))))
  h1 = Bool.pick(U32, U32.is_eq(c, 258), U32.add(192, U32.add(20, B5K_CMP_EQ())), Bool.pick(U32, U32.is_eq(c, 259), U32.add(192, U32.add(20, B5K_CMP_NE())), Bool.pick(U32, U32.is_eq(c, 260), U32.add(192, U32.add(20, B5K_CMP_LE())), Bool.pick(U32, U32.is_eq(c, 261), U32.add(192, U32.add(20, B5K_CMP_GE())), Bool.pick(U32, U32.is_eq(c, 262), U32.add(128, B5K_OP_AND()), Bool.pick(U32, U32.is_eq(c, 263), U32.add(64, B5K_OP_OR()), Bool.pick(U32, U32.is_eq(c, 264), U32.add(512, 31), Bool.pick(U32, U32.is_eq(c, 265), U32.add(448, 30), 0))))))))
  h2 = Bool.pick(U32, U32.is_eq(c, 269), U32.add(448, B5K_OP_SHL()), Bool.pick(U32, U32.is_eq(c, 270), U32.add(448, B5K_OP_SHR()), Bool.pick(U32, Bool.or(U32.is_eq(c, 272), U32.is_eq(c, 273)), U32.add(384, B5K_OP_AND()), Bool.pick(U32, U32.is_eq(c, 274), U32.add(256, B5K_OP_OR()), Bool.pick(U32, U32.is_eq(c, 275), U32.add(320, B5K_OP_XOR()), Bool.pick(U32, U32.is_eq(c, 276), U32.add(512, B5K_OP_ADD()), Bool.pick(U32, U32.is_eq(c, 277), U32.add(512, 32), 0)))))))
  Bool.pick(U32, U32.is_lt(c, 256), lo, Bool.pick(U32, U32.is_le(c, 265), h1, h2))
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
  PSym{+sid, +st2} = r; Bool.pick(PStep, dup, p_ev_pat_plus(st2, Con{KPatSucc{v, sid}, ks}), SEval{GPat{}, st2, Con{KPatSucc{v, sid}, ks}})
def p_wrap_str_pat(s: String, +sc: U32, +sn: U32) -> Pat:
  match s:
    case SNil{}: PCtr{sn, Nil{}}
    case SCon{c, t}: PCtr{sc, Con{PChr{Char.to_u32(c)}, Con{p_wrap_str_pat(t, sc, sn), Nil{}}}}
def p_ev_pat_str_k(s: String, sc: U32, r2: PSym, ks: List<&2, PKont>) -> PStep:
  PSym{sn, st3} = r2; p_pat_done(p_wrap_str_pat(s, sc, sn), st3, ks)
def p_ev_pat_str(s: String, r1: PSym, ks: List<&2, PKont>) -> PStep:
  PSym{sc, st2} = r1; p_ev_pat_str_k(s, sc, p_intern(st2, "SNil"), ks)
def p_ev_pat(st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkSym{43}: p_ev_pat_plus(p_drop(st), ks)
    case TkSym{45}: SEval{GPat{}, p_drop(st), ks}
    case TkSym{126}: SEval{GPat{}, p_drop(st), ks}
    case TkSym{279}: SEval{GPat{}, p_drop(st), ks}
    case TkIdent{+id}: (+st1 = p_drop(st); Bool.pick(PStep, p_sym_eq(st1, id, "_"), p_pat_done(PWild{}, st1, ks), Bool.pick(PStep, p_is_sym(st1, 123), SEval{GPatList{125, True{}, Nil{}}, p_drop(st1), Con{KPatCtr{id}, ks}}, p_pat_done(PVar{id, False{}}, st1, ks))))
    case TkNum{+v}: (+st1 = p_drop(st); +nz = U32.is_gt(v, 0); +is_pp = Bool.and(nz, p_is_sym(st1, 278)); Bool.pick(PStep, Bool.or(Bool.and(nz, p_is_sym(st1, 277)), is_pp), p_ev_pat_succ(v, p_intern(p_drop(st1), "Succ"), ks, is_pp), p_pat_done(PNum{v}, st1, ks)))
    case TkFlt{b}: p_pat_done(PNum{b}, p_drop(st), ks)
    case TkChr{c}: p_pat_done(PChr{c}, p_drop(st), ks)
    case TkStr{s}: p_ev_pat_str(s, p_intern(p_drop(st), "SCon"), ks)
    case TkSym{40}: SEval{GPatList{41, True{}, Nil{}}, p_drop(st), Con{KPWrap{False{}}, ks}}
    case TkSym{91}: SEval{GPatList{93, True{}, Nil{}}, p_drop(st), Con{KPWrap{True{}}, ks}}
    case _: SApply{VPat{PWild{}}, p_fail(st, "unexpected token in pattern"), ks}
def p_ev_param(+er: Bool, +dup: Bool, +mode: U32, +st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkSym{43}: SEval{GParam{er, True{}, mode}, p_drop(st), ks}
    case TkSym{45}: SEval{GParam{True{}, dup, mode}, p_drop(st), ks}
    case TkSym{126}: Bool.pick(PStep, U32.is_ge(mode, 2), SApply{VParam{Param{0, None{}, er, dup}}, p_fail(st, "unexpected '~' in function type"), ks}, SEval{GParam{True{}, True{}, mode}, p_drop(st), ks})
    case TkIdent{+id}:
      +st1 = p_drop(st); +no_arr = U32.is_ge(mode, 2); +no_gt = Bool.or(U32.is_eq(mode, 1), U32.is_eq(mode, 3))
      +ks_ty = Bool.pick(List<&2, PKont>, no_arr, Con{KBinOnly{no_gt}, Con{KParamTy{id, er, dup}, ks}}, Con{KParamTy{id, er, dup}, ks})
      +g_ty = Bool.pick(PGoal, no_arr, GUnary{}, Bool.pick(PGoal, no_gt, GTypeArg{}, GExpr{}))
      Bool.pick(PStep, p_is_sym(st1, 58), SEval{g_ty, p_drop(st1), ks_ty}, SApply{VParam{Param{id, None{}, er, dup}}, st1, ks})
    case _: SApply{VParam{Param{0, None{}, er, dup}}, p_fail(st, "expected parameter name"), ks}
def p_is_var(e: Expr) -> Bool:
  match e:
    case EVar{_}: True{}
    case _: False{}
def p_lam_mat_step(acc: List<&2, Case>, st1: PState, ks: List<&2, PKont>) -> PStep:
  match st1:
    case PState{Con{Tok{TkIdent{+cid}, _}, Con{Tok{TkSym{58}, _}, t}}, syms, ncid, err}: (+st2: PState = PState{t, syms, ncid, err}; SEval{GExpr{}, st2, Con{KLamMatArm{Bool.pick(U32, p_sym_eq(st2, cid, "_"), 0, U32.add(cid, 1)), acc}, ks}})
    case other: SEval{GExpr{}, other, Con{KLamMatArm{0, acc}, ks}}
def p_is_upper_ident(st: PState) -> Bool:
  match st:
    case PState{Con{Tok{TkIdent{id}, _}, _}, syms, _, _}: lex_in(lex_peek_u32(symtab_name(syms, id)), 65, 90)
    case _: False{}
def p_ev_nat_lit(st: PState, ks: List<&2, PKont>) -> PStep:
  match st:
    case PState{Con{Tok{TkNum{v}, _}, t}, syms, ncid, err}: SEval{GPost{EAnn{ENum{v}, ESet{}}}, PState{t, syms, ncid, err}, ks}
    case other: SApply{VExpr{EHole{}}, p_fail(other, "expected nat literal"), ks}
def p_ev_unary(+st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match k:
    case TkSym{279}: p_ev_nat_lit(p_drop(st), ks)
    case TkSym{43}: (+st1 = p_drop(st); Bool.pick(PStep, p_is_upper_ident(st1), SEval{GUnary{}, st1, ks}, SApply{VExpr{EHole{}}, p_fail(st, "unexpected '+' in expression"), ks}))
    case TkSym{33}: SEval{GUnary{}, p_drop(st), Con{KUnOp{1}, ks}}
    case TkSym{126}: SEval{GUnary{}, p_drop(st), Con{KUnOp{1}, ks}}
    case TkSym{37}: SEval{GUnary{}, p_drop(st), Con{KRewriteEq{}, ks}}
    case TkSym{92}: (+st1 = p_drop(st); Bool.pick(PStep, p_is_sym(st1, 123), SEval{GLamMat{Nil{}}, p_drop(st1), ks}, SApply{VExpr{EHole{}}, p_fail(st, "unexpected token in expression"), ks}))
    case TkNum{v}: SEval{GPost{ENum{v}}, p_drop(st), ks}
    case TkFlt{b}: SEval{GPost{EFlt{b}}, p_drop(st), ks}
    case TkChr{c}: SEval{GPost{EChr{c}}, p_drop(st), ks}
    case TkStr{s}: SEval{GPost{EStr{s}}, p_drop(st), ks}
    case TkIdent{id}: SEval{GPost{EVar{id}}, p_drop(st), ks}
    case TkSym{63}: SEval{GPost{EHole{}}, p_drop(st), ks}
    case TkSym{267}: SEval{GPost{EAnn{ENum{1}, EUnit{}}}, p_drop(st), ks}
    case TkSym{268}: SEval{GPost{EAnn{ENum{2}, EUnit{}}}, p_drop(st), ks}
    case TkSym{271}: SEval{GPost{EAnn{ENum{0}, EUnit{}}}, p_drop(st), ks}
    case TkSym{40}: SEval{GExprList{41, Nil{}}, p_drop(st), Con{KWrapExprs{False{}}, ks}}
    case TkSym{91}: (+st1 = p_drop(st); Bool.pick(PStep, p_is_sym(st1, 93), SEval{GPost{EList{Nil{}}}, p_drop(st1), ks}, SEval{GExpr{}, st1, Con{KBrackFirst{}, ks}}))
    case TkSym{123}: (+st1 = p_drop(st); Bool.pick(PStep, p_is_sym(st1, 125), SEval{GPost{ERefl{}}, p_drop(st1), ks}, Bool.pick(PStep, Bool.and(p_is_sym(st1, 258), p_is_sym(p_drop(st1), 125)), SEval{GPost{ERefl{}}, p_drop(p_drop(st1)), ks}, SEval{GExpr{}, st1, Con{KBrace{}, ks}})))
    case _: SApply{VExpr{EHole{}}, p_fail(st, "unexpected token in expression"), ks}
def p_is_base_tname(st: PState, e: Expr) -> Bool:
  PState{_, syms, _, _} = st
  match e:
    case EVar{id}: p_str_mem(["List", "Array", "Maybe", "Either", "Result", "Map", "Sigma", "Pair", "Poll", "Chan", "IO", "Word"], symtab_name(syms, id))
    case _: False{}
def p_ev_post(err: Bool, +lhs: Expr, +st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match err k:
    case True{} _: SApply{VExpr{lhs}, st, ks}
    case False{} TkSym{40}: SEval{GExprList{41, Nil{}}, p_drop(st), Con{KPostCall{lhs, False{}}, ks}}
    case False{} TkSym{33}: (+st1 = p_drop(st); Bool.pick(PStep, p_is_sym(st1, 40), SEval{GExprList{41, Nil{}}, p_drop(st1), Con{KPostCall{lhs, False{}}, ks}}, SApply{VExpr{lhs}, st, ks}))
    case False{} TkSym{123}: Bool.pick(PStep, p_is_var(lhs), SEval{GExprList{125, Nil{}}, p_drop(st), Con{KPostCall{lhs, True{}}, ks}}, SApply{VExpr{lhs}, st, ks})
    case False{} TkSym{91}: SEval{GExpr{}, p_drop(st), Con{KPostArrIdx{lhs}, ks}}
    case False{} TkSym{60}: Bool.pick(PStep, p_is_targs(p_toks(st)), SEval{GExprList{62, Nil{}}, p_drop(st), Con{KPostCall{Bool.pick(Expr, Bool.and(p_is_var(lhs), Bool.not(p_is_base_tname(st, lhs))), EAnn{lhs, ESet{}}, lhs), False{}}, ks}}, SApply{VExpr{lhs}, st, ks})
    case _ _: SApply{VExpr{lhs}, st, ks}
def p_ev_bin(err: Bool, +min_p: U32, +lhs: Expr, +st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match err k:
    case True{} _: SApply{VExpr{lhs}, st, ks}
    case False{} TkSym{+c}:
      +no_gt = U32.is_ge(min_p, 16); +mp = Bool.pick(U32, no_gt, U32.sub(min_p, 16), min_p); +info = p_binop_info(c); +prec = U32.shrn(info, 6n)
      ok = Bool.and(Bool.and(U32.is_gt(prec, 0), U32.is_ge(prec, mp)), Bool.not(Bool.and(no_gt, Bool.or(U32.is_eq(c, 62), U32.is_eq(c, 270)))))
      Bool.pick(PStep, ok, SEval{GUnary{}, p_skip_nls(p_drop(st)), Con{KBinRhs0{min_p, prec, U32.and(info, 63), lhs}, ks}}, SApply{VExpr{lhs}, st, ks})
    case False{} TkNewline{}:
      +st1 = p_skip_ws(st); +mp = Bool.pick(U32, U32.is_ge(min_p, 16), U32.sub(min_p, 16), min_p)
      Bool.pick(PStep, Bool.and(p_is_sym(st1, 264), U32.is_ge(8, mp)), SEval{GUnary{}, p_skip_nls(p_drop(st1)), Con{KBinRhs0{min_p, 8, 31, lhs}, ks}}, Bool.pick(PStep, Bool.and(p_is_sym(st1, 38), U32.is_ge(6, mp)), SEval{GUnary{}, p_skip_nls(p_drop(st1)), Con{KBinRhs0{min_p, 6, B5K_OP_AND(), lhs}, ks}}, SApply{VExpr{lhs}, st, ks}))
    case _ _: SApply{VExpr{lhs}, st, ks}
def p_ev_lam(+st: PState, +ks: List<&2, PKont>, +no_gt: Bool) -> PStep: Bool.pick(PStep, p_is_sym(st, 40), SEval{GParams{41, Nil{}}, p_drop(st), Con{KLam{no_gt}, ks}}, SEval{GParam{False{}, False{}, 0}, st, Con{KLam{no_gt}, ks}})
def p_do_start(st: PState, ks: List<&2, PKont>) -> PStep:
  match st:
    case PState{Con{Tok{TkIdent{msym}, _}, Con{Tok{TkSym{60}, _}, t}}, syms, ncid, err}: SEval{GExprList{62, Nil{}}, PState{t, syms, ncid, err}, Con{KDoHdr{msym}, ks}}
    case other: SApply{VExpr{EHole{}}, p_fail(other, "expected '<' after do monad"), ks}
def p_ev_expr(err: Bool, +st: PState, +ks: List<&2, PKont>, k: TokKind) -> PStep:
  match err k:
    case True{} _: SApply{VExpr{EHole{}}, st, ks}
    case False{} TkKw{5}: SEval{GExprList{58, Nil{}}, p_drop(st), Con{KMatchScruts{}, ks}}
    case False{} TkKw{7}: SEval{GExpr{}, p_drop(st), Con{KIfCond{}, ks}}
    case False{} TkKw{9}: p_do_start(p_drop(st), ks)
    case False{} TkSym{64}: SEval{GParam{False{}, False{}, 2}, p_drop(st), Con{KPiPm{False{}, False{}}, ks}}
    case False{} TkSym{38}: SEval{GParam{False{}, False{}, 2}, p_drop(st), Con{KPiPm{False{}, True{}}, ks}}
    case _ _: Bool.pick(PStep, p_is_lam(p_toks(st)), p_ev_lam(st, ks, False{}), Bool.pick(PStep, p_scan_assign(p_toks(st), 61), SEval{GPat{}, st, Con{KILetPat{}, ks}}, SEval{GArrow{False{}}, st, ks}))
def p_ev_ctor_k(+ind: Bool, +acc: List<&2, CtorDef>, st1: PState, +ks: List<&2, PKont>) -> PStep:
  match st1:
    case PState{Con{Tok{TkIdent{+csym}, _}, t}, syms2, +cid, err2}: (+st3: PState = PState{t, syms2, U32.add(cid, 1), err2}; Bool.pick(PStep, p_is_sym(st3, 123), SEval{GParams{125, Nil{}}, p_drop(st3), Con{KCtorFs{ind, csym, cid, acc}, ks}}, SEval{GCtors{ind, Con{CtorDef{csym, cid, Nil{}}, acc}}, st3, ks}))
    case other: SApply{VCtors{b5k_list_rev(CtorDef, acc)}, p_fail(other, "expected ctor name"), ks}
def p_ev_fimp_k(+path: String, st2: PState, ks: List<&2, PKont>) -> PStep:
  match st2:
    case PState{Con{Tok{TkStr{p}, _}, t}, syms, ncid, err}: SEval{GFimp{Bool.pick(String, String.is_empty(path), p, path)}, PState{t, syms, ncid, err}, ks}
    case other: SEval{GFimp{path}, p_skip(1, other), ks}
def p_kind_arg_sym(st: PState) -> U32:
  match st:
    case PState{Con{Tok{TkIdent{kid}, _}, Con{Tok{TkSym{40}, _}, Con{Tok{TkIdent{asym}, _}, Con{Tok{TkSym{41}, _}, _}}}}, syms, _, _}: Bool.pick(U32, String.eq(symtab_name(syms, kid), "Kind"), U32.add(asym, 1), 0)
    case _: 0
def p_type_body_go(+tsym: U32, +pms: List<&2, Param>, +st: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>) -> PStep:
  +st1 = p_eat_kw(st, 4, "expected 'is' in type")
  +st1b = Bool.pick(PState, Bool.or(p_has_err(st1), Bool.or(p_is_ident_eq(st1, "Data"), Bool.or(p_is_ident_eq(st1, "Type"), p_is_ident_eq(st1, "Kind")))), st1, p_fail(st1, "expected kind (Data, Type, or Kind) after 'is'"))
  +is_data = p_is_ident_eq(st1b, "Data"); +ksym = p_kind_arg_sym(st1b); +st3 = p_skip_nls(p_eat_sym(p_skip(2, st1b), 58, "expected ':' in type"))
  Bool.pick(PStep, p_is_indent(st3), SEval{GCtors{True{}, Nil{}}, p_drop(st3), Con{KTypeCtors{tsym, pms, is_data, ksym, ts, ds, ls}, Nil{}}}, Bool.pick(PStep, p_is_ident(st3), SEval{GCtors{False{}, Nil{}}, st3, Con{KTypeCtors{tsym, pms, is_data, ksym, ts, ds, ls}, Nil{}}}, SEval{GTop{Con{TypeDef{tsym, pms, is_data, Nil{}}, ts}, ds, ls}, st3, Nil{}}))
def p_def_body_go(+dsym: U32, +is_u: Bool, +pms: List<&2, Param>, +ret: Maybe<&2, Expr>, st: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>) -> PStep:
  +st1 = p_eat_sym(p_skip_ws(st), 58, "expected ':' in def"); +st2 = p_skip_nls(st1); +ind = p_is_indent(st2); +st3 = p_skip_nls(Bool.pick(PState, ind, p_drop(st2), st2))
  Bool.pick(PStep, Bool.or(ind, p_is_nl(st1)), Bool.pick(PStep, p_is_kw(st3, 11), SEval{GFimp{""}, st3, Con{KDefBody{dsym, is_u, pms, ret, ts, ds, ls}, Nil{}}}, SEval{GBlock{}, st3, Con{KDefBody{dsym, is_u, pms, ret, ts, ds, ls}, Nil{}}}), SEval{GExpr{}, st2, Con{KDefBody{dsym, is_u, pms, ret, ts, ds, ls}, Nil{}}})
def p_def_ret_go(+dsym: U32, +is_u: Bool, +pms: List<&2, Param>, +st: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>) -> PStep:
  +st1 = p_skip_ws(st); Bool.pick(PStep, p_is_sym(st1, 256), SEval{GExpr{}, p_skip_ws(p_drop(st1)), Con{KDefRet{dsym, is_u, pms, ts, ds, ls}, Nil{}}}, p_def_body_go(dsym, is_u, pms, None{}, st, ts, ds, ls))
def p_top_named(kind: U32, st: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>) -> PStep:
  match kind st:
    case 2 PState{Con{Tok{TkIdent{+sym}, _}, t}, syms, ncid, err}: (+st1: PState = PState{t, syms, ncid, err}; +is_la = p_is_sym(st1, 266); Bool.pick(PStep, p_is_sym(st1, 265), p_type_body_go(sym, Nil{}, p_drop(st1), ts, ds, ls), Bool.pick(PStep, Bool.or(p_is_sym(st1, 60), is_la), SEval{GParams{62, Nil{}}, Bool.pick(PState, is_la, p_split_sym(st1, 266, 45), p_drop(st1)), Con{KTypePms{sym, ts, ds, ls}, Nil{}}}, p_type_body_go(sym, Nil{}, st1, ts, ds, ls))))
    case 3 PState{Con{Tok{TkIdent{sym}, _}, t}, syms, ncid, err}: (+st2 = p_skip_nls(p_eat_sym(PState{t, syms, ncid, err}, 58, "expected ':' after law")); SEval{GLawBody{sym, Nil{}, ts, ds, ls}, Bool.pick(PState, p_is_indent(st2), p_drop(st2), st2), Nil{}})
    case +k PState{Con{Tok{TkIdent{+sym}, _}, t}, syms, ncid, err}: (+st0: PState = PState{t, syms, ncid, err}; +is_u = Bool.or(U32.is_eq(k, 4), p_is_sym(st0, 63)); +st1 = p_opt_drop(st0, 63); Bool.pick(PStep, p_is_sym(st1, 40), SEval{GParams{41, Nil{}}, p_drop(st1), Con{KDefPms{sym, is_u, ts, ds, ls}, Nil{}}}, p_def_ret_go(sym, is_u, Nil{}, st1, ts, ds, ls)))
    case _ other: SDone{ts, ds, ls, p_fail(other, "expected declaration name")}
def p_ev_top(+st1: PState, +ts: List<&2, TypeDef>, +ds: List<&2, Def>, +ls: List<&2, LawDef>, k: TokKind) -> PStep:
  match k:
    case TkKw{11}: Bool.pick(PStep, Bool.not(Bool.and(p_is_nil(TypeDef, ts), Bool.and(p_is_nil(Def, ds), p_is_nil(LawDef, ls)))), SDone{b5k_list_rev(TypeDef, ts), b5k_list_rev(Def, ds), b5k_list_rev(LawDef, ls), p_fail(st1, "import must appear before declarations")}, SEval{GTop{ts, ds, ls}, p_skip(1, st1), Nil{}})
    case TkKw{2}: p_top_named(2, p_drop(st1), ts, ds, ls)
    case TkKw{3}: p_top_named(3, p_drop(st1), ts, ds, ls)
    case TkKw{17}: p_top_named(4, p_eat_kw(p_skip_nls(p_drop(st1)), 1, "expected 'def' after @unsafe"), ts, ds, ls)
    case TkKw{1}: p_top_named(1, p_drop(st1), ts, ds, ls)
    case TkDedent{}: SEval{GTop{ts, ds, ls}, p_drop(st1), Nil{}}
    case _: SDone{b5k_list_rev(TypeDef, ts), b5k_list_rev(Def, ds), b5k_list_rev(LawDef, ls), p_fail(st1, "unexpected top-level token")}
# Main Eval & Apply Dispatch (100% Non-Recursive)
def p_has_plain_pm(ps: List<&2, Param>) -> Bool:
  match ps:
    case Nil{}: False{}
    case Con{Param{_, _, er, dup}, t}: Bool.or(Bool.not(Bool.and(er, dup)), p_has_plain_pm(t))
def p_opt_ann(val: Expr, ty: Maybe<&2, Expr>) -> Expr:
  match ty:
    case None{}: val
    case Some{t}: EAnn{val, t}
def p_eval(g: PGoal, +st: PState, +ks: List<&2, PKont>) -> PStep:
  match g:
    case GTop{+ts, +ds, +ls}: (+st1 = p_skip_nls(st); Bool.pick(PStep, Bool.or(p_has_err(st1), p_is_eof(st1)), SDone{b5k_list_rev(TypeDef, ts), b5k_list_rev(Def, ds), b5k_list_rev(LawDef, ls), st1}, p_ev_top(st1, ts, ds, ls, p_peek(st1))))
    case GExpr{}: p_ev_expr(p_has_err(st), st, ks, p_peek(st))
    case GUnary{}: p_ev_unary(st, ks, p_peek(st))
    case GPost{lhs}: p_ev_post(p_has_err(st), lhs, st, ks, p_peek(st))
    case GBin{min_p, lhs}: p_ev_bin(p_has_err(st), min_p, lhs, st, ks, p_peek(st))
    case GArrow{+no_gt}: Bool.pick(PStep, Bool.or(p_is_sym(st, 64), p_is_sym(st, 38)), SEval{GParam{False{}, False{}, Bool.pick(U32, no_gt, 3, 2)}, p_drop(st), Con{KPiPm{no_gt, p_is_sym(st, 38)}, ks}}, SEval{GUnary{}, st, Con{KArrowBin{no_gt}, ks}})
    case GTypeArg{}: Bool.pick(PStep, p_is_lam(p_toks(st)), p_ev_lam(st, ks, True{}), SEval{GArrow{True{}}, st, ks})
    case GSuite{}: (+st1 = p_skip_nls(st); +st2 = p_drop_if(U32.is_eq(p_tok_tag(st1), 4), st1); Bool.pick(PStep, p_is_indent(st2), SEval{GBlock{}, p_drop(st2), ks}, SEval{GExpr{}, st2, ks}))
    case GBlock{}: (+st1 = p_skip_nls(st); Bool.pick(PStep, p_at_end(st1), SApply{VExpr{EUnit{}}, p_eat_dedent(st1), ks}, Bool.pick(PStep, p_scan_assign(p_toks(st1), 61), SEval{GPat{}, st1, Con{KBlkLetPat{p_is_sym(st1, 45)}, ks}}, SEval{GExpr{}, st1, Con{KBlkExpr{}, ks}})))
    case GPat{}: p_ev_pat(st, ks, p_peek(st))
    case GParam{er, dup, mode}: p_ev_param(er, dup, mode, st, ks, p_peek(st))
    case GExprList{+cc, +acc}: (+st1 = Bool.pick(PState, U32.is_eq(cc, 62), p_skip_ws(st), st); first_ta = Bool.and(U32.is_eq(cc, 62), Bool.and(p_is_nil(Expr, acc), Bool.and(Bool.not(p_is_sym(st1, 40)), Bool.and(Bool.not(p_is_lam(p_toks(st1))), Bool.and(Bool.not(p_is_sym(st1, 64)), Bool.not(p_is_sym(st1, 38))))))); Bool.pick(PStep, p_stop_at(st1, cc), SApply{VExprs{b5k_list_rev(Expr, acc)}, Bool.pick(PState, U32.is_eq(cc, 58), st1, p_eat_close(st1, cc, "expected closing delimiter")), ks}, SEval{Bool.pick(PGoal, U32.is_eq(cc, 58), GArrow{False{}}, Bool.pick(PGoal, U32.is_eq(cc, 62), GTypeArg{}, GExpr{})), st1, Con{KExprList{Bool.pick(U32, first_ta, 63, cc), acc}, ks}}))
    case GPatList{+cc, +eat, +acc}: Bool.pick(PStep, p_stop_at(st, cc), SApply{VPats{b5k_list_rev(Pat, acc)}, Bool.pick(PState, eat, p_eat_sym(st, cc, "expected closing delimiter"), st), ks}, SEval{GPat{}, st, Con{KPatList{cc, eat, acc}, ks}})
    case GParams{+cc, +acc}: (+st1 = Bool.pick(PState, U32.is_eq(cc, 62), p_skip_ws(st), st); Bool.pick(PStep, Bool.and(U32.is_eq(cc, 41), Bool.and(p_is_sym(st1, 126), p_has_plain_pm(acc))), SApply{VParams{Nil{}}, p_fail(st1, "comptime '~' param must precede plain params"), ks}, Bool.pick(PStep, p_stop_at(st1, cc), SApply{VParams{b5k_list_rev(Param, acc)}, p_eat_close(st1, cc, "expected closing delimiter"), ks}, SEval{GParam{False{}, False{}, Bool.pick(U32, U32.is_eq(cc, 62), 1, 0)}, st1, Con{KParams{cc, acc}, ks}})))
    case GCases{+acc}: (+st1 = p_skip_nls(st); +st2 = p_drop_if(Bool.and(Bool.or(p_is_indent(st1), U32.is_eq(p_tok_tag(st1), 4)), p_is_kw(p_drop(st1), 6)), st1); Bool.pick(PStep, p_at_end(st2), SApply{VCases{b5k_list_rev(Case, acc)}, p_eat_dedent(st2), ks}, SEval{GPatList{58, False{}, Nil{}}, p_eat_kw(st2, 6, "expected 'case'"), Con{KCaseHead{acc}, ks}}))
    case GLamMat{+acc}: (+st1 = p_skip_ws(st); Bool.pick(PStep, p_stop_at(st1, 125), SApply{VExpr{ELam{Con{Param{0, None{}, False{}, True{}}, Nil{}}, EMat{Con{EVar{0}, Nil{}}, b5k_list_rev(Case, acc)}}}, p_eat_sym(st1, 125, "expected '}'"), ks}, p_lam_mat_step(acc, st1, ks)))
    case GDo{+acc}:
      +st0 = p_skip_nls(st); +st1 = p_drop_if(p_is_indent(st0), st0); +ts = p_toks(st1)
      +do_end = Bool.or(p_at_end(st1), Bool.or(p_is_sym(st1, 41), Bool.or(p_is_sym(st1, 93), Bool.or(p_is_sym(st1, 125), p_is_sym(st1, 44)))))
      Bool.pick(PStep, do_end, SApply{VStmts{b5k_list_rev(Stmt, acc)}, p_eat_dedent(st1), ks}, Bool.pick(PStep, p_is_kw(st1, 10), SEval{GExpr{}, p_drop(st1), Con{KDoStmt{acc, True{}}, ks}}, Bool.pick(PStep, p_scan_assign(ts, 266), SEval{GPat{}, st1, Con{KDoPat{acc, True{}}, ks}}, Bool.pick(PStep, p_scan_assign(ts, 61), SEval{GPat{}, st1, Con{KDoPat{acc, False{}}, ks}}, SEval{GExpr{}, st1, Con{KDoStmt{acc, False{}}, ks}}))))
    case GCtors{+ind, +acc}: (+st1 = p_skip_nls(st); Bool.pick(PStep, Bool.pick(Bool, ind, p_at_end(st1), Bool.or(p_has_err(st1), Bool.not(p_is_ident(st1)))), SApply{VCtors{b5k_list_rev(CtorDef, acc)}, Bool.pick(PState, ind, p_eat_dedent(st1), st1), ks}, p_ev_ctor_k(ind, acc, st1, ks)))
    case GLawBody{+lsym, +pms, +ts, +ds, +ls}:
      +st1 = p_skip_nls(st); +st_for = p_drop(st1)
      Bool.pick(PStep, Bool.and(p_is_kw(st1, 13), Bool.and(p_is_sym(st_for, 126), p_has_plain_pm(pms))), SDone{ts, ds, ls, p_fail(st_for, "comptime '~' clause must precede plain clauses")},
      Bool.pick(PStep, p_is_kw(st1, 13), SEval{GParam{False{}, False{}, 0}, st_for, Con{KLaw{0, lsym, pms, ts, ds, ls}, Nil{}}}, Bool.pick(PStep, p_is_ident_eq(st1, "exs"), SEval{GParam{False{}, False{}, 0}, st_for, Con{KLaw{1, lsym, pms, ts, ds, ls}, Nil{}}}, Bool.pick(PStep, p_is_ident_eq(st1, "where"), SEval{GExpr{}, st_for, Con{KLaw{1, lsym, pms, ts, ds, ls}, Nil{}}}, SEval{GExpr{}, st1, Con{KLaw{2, lsym, pms, ts, ds, ls}, Nil{}}}))))
    case GFimp{+path}: (+st1 = p_skip_nls(st); Bool.pick(PStep, U32.is_ge(p_tok_tag(st1), 4), SApply{VStr{path}, p_eat_dedent(st1), ks}, Bool.pick(PStep, p_is_kw(st1, 11), p_ev_fimp_k(path, p_drop(st1), ks), SEval{GFimp{path}, p_skip(1, st1), ks})))
def p_fork_start(ps: List<&2, Pat>, st: PState, ks: List<&2, PKont>) -> PStep:
  match ps:
    case Con{p0, rest}: SEval{GExpr{}, st, Con{KBlkForkExprs{p0, rest, False{}}, ks}}
    case Nil{}: SApply{VExpr{EUnit{}}, p_fail(st, "expected pattern in let"), ks}
def p_bad_grade_pms(+st: PState, +ksym: U32, ps: List<&2, Param>) -> List<&2, U32>:
  match ps:
    case Nil{}: Nil{}
    case Con{Param{s, Some{EApp{EVar{k}, Con{EVar{g}, Nil{}}}}, _, _}, t}: (+rest = p_bad_grade_pms(st, ksym, t); Bool.pick(List<&2, U32>, Bool.and(p_sym_eq(st, k, "Kind"), Bool.not(U32.is_eq(U32.add(g, 1), ksym))), Con{s, rest}, rest))
    case Con{_, t}: p_bad_grade_pms(st, ksym, t)
def p_fields_bad_grade(+bad_pms: List<&2, U32>, fs: List<&2, Param>) -> Bool:
  match fs:
    case Nil{}: False{}
    case Con{Param{_, Some{EVar{s}}, False{}, _}, t}: Bool.or(p_u32_mem(bad_pms, s), p_fields_bad_grade(bad_pms, t))
    case Con{_, t}: p_fields_bad_grade(bad_pms, t)
def p_ctors_bad_grade(+bad_pms: List<&2, U32>, cs: List<&2, CtorDef>) -> Bool:
  match cs:
    case Nil{}: False{}
    case Con{CtorDef{_, _, fs}, t}: Bool.or(p_fields_bad_grade(bad_pms, fs), p_ctors_bad_grade(bad_pms, t))
def p_pat_is_name(p: Pat) -> Bool:
  match p:
    case PVar{_, _}: True{}
    case PWild{}: True{}
    case _: False{}
def p_do_untyped_bind_pat(pt: Pat) -> Pat:
  match pt:
    case PVar{sym, False{}}: PNum{U32.add(sym, 1)}
    case _: PWild{}
def p_bin_sym(is_ctr: Bool, mp: U32, +lhs: Expr, +rhs: Expr, r: PSym, ks: List<&2, PKont>) -> PStep:
  PSym{+id, st2} = r; SEval{GBin{mp, Bool.pick(Expr, is_ctr, ECtr{id, [lhs, rhs]}, EApp{EVar{id}, [lhs, rhs]})}, st2, ks}
def p_bin_nsucc(mp: U32, lhs: Expr, rhs: Expr, r: PSym, ks: List<&2, PKont>) -> PStep:
  match lhs r:
    case EUnOp{1, v} PSym{nid, st2}: SEval{GBin{mp, EUnOp{1, EAnn{EOp{B5K_OP_ADD(), EAnn{v, ESet{}}, rhs}, EVar{nid}}}}, st2, ks}
    case v PSym{nid, st2}: SEval{GBin{mp, EAnn{EOp{B5K_OP_ADD(), EAnn{v, ESet{}}, rhs}, EVar{nid}}}, st2, ks}
def p_is_res_lam(st: PState, s: U32) -> Bool:
  PState{_, syms, _, _} = st; p_str_mem(["Type", "Data", "Kind", "Set"], symtab_name(syms, s))
def p_pat_cons(lhs: Pat, rhs: Pat, r: PSym, ks: List<&2, PKont>) -> PStep:
  PSym{cid, st2} = r; SApply{VPat{PCtr{cid, [lhs, rhs]}}, st2, ks}
def p_apply_k(k: PKont, v: PVal, +st: PState, +ks: List<&2, PKont>) -> PStep:
  match k v:
    case KPatList{cc, eat, acc} VPat{p}: SEval{GPatList{cc, eat, Con{p, acc}}, p_opt_drop(st, 44), ks}
    case KPatCtr{id} VPats{fs}: p_pat_done(PCtr{id, fs}, st, ks)
    case KPatSucc{n, sid} VPat{sub}: p_pat_done(p_wrap_succ(U32.to_nat(n), sid, sub), st, ks)
    case KPatCons{lhs} VPat{rhs}: p_pat_cons(lhs, rhs, p_intern(st, "Con"), ks)
    case KPWrap{+is_list} VPats{+ps}: Bool.pick(PStep, Bool.and(Bool.not(is_list), p_is_nil(Pat, ps)), SApply{VPat{PWild{}}, p_fail(st, "empty '()' is not a valid pattern"), ks}, p_pat_done(Bool.pick(Pat, is_list, PList{ps}, p_pair_pat(ps)), st, ks))
    case KParamTy{id, er, dup} VExpr{ty}: SApply{VParam{Param{id, Some{ty}, er, dup}}, st, ks}
    case KParams{41, _} VParam{Param{_, None{}, True{}, True{}}}: SApply{VParams{Nil{}}, p_fail(st, "comptime '~' param requires type annotation"), ks}
    case KParams{cc, acc} VParam{pm}: SEval{GParams{cc, Con{pm, acc}}, p_opt_drop(st, 44), ks}
    case KExprList{63, acc} VExpr{EAll{p, b}}: SEval{GExprList{62, Con{EAnn{EAll{p, b}, EHole{}}, acc}}, p_opt_drop(st, 44), ks}
    case KExprList{63, acc} VExpr{EOp{+op, +a, +b}}: SEval{GExprList{62, Con{Bool.pick(Expr, Bool.or(U32.is_eq(op, B5K_OP_AND()), U32.is_eq(op, B5K_OP_OR())), EAnn{EOp{op, a, b}, EHole{}}, EOp{op, a, b}), acc}}, p_opt_drop(st, 44), ks}
    case KExprList{63, acc} VExpr{e}: SEval{GExprList{62, Con{e, acc}}, p_opt_drop(st, 44), ks}
    case KExprList{+cc, +acc} VExpr{+e}: Bool.pick(PStep, Bool.and(U32.is_eq(cc, 41), p_is_sym(st, 58)), SEval{GExpr{}, p_drop(st), Con{KParenTy{acc, e}, ks}}, SEval{GExprList{cc, Con{e, acc}}, p_opt_drop(st, 44), ks})
    case KWrapExprs{+is_list} VExprs{+es}: Bool.pick(PStep, Bool.and(Bool.not(is_list), p_is_nil(Expr, es)), SApply{VExpr{EUnit{}}, p_fail(st, "empty '()' is not a valid expression"), ks}, SEval{GPost{Bool.pick(Expr, is_list, EList{es}, p_pair_expr(es))}, st, ks})
    case KParenTy{acc, e} VExpr{ty}: SApply{VExprs{b5k_list_rev(Expr, Con{EAnn{e, ty}, acc})}, p_eat_sym(st, 41, "expected ')'"), ks}
    case KBrace{} VExpr{ELet{_, _, _}}: SApply{VExpr{EUnit{}}, p_fail(st, "inline block '{let; expr}' is not allowed"), ks}
    case KBrace{} VExpr{+e}: Bool.pick(PStep, p_is_sym(st, 58), SEval{GExpr{}, p_drop(st), Con{KBraceTy{e}, ks}}, SEval{GPost{e}, p_eat_sym(st, 125, "expected '}'"), ks})
    case KBraceTy{EOp{+op, a, b}} VExpr{ty}: SEval{GPost{EAnn{EOp{op, a, b}, ty}}, Bool.pick(PState, Bool.and(Bool.not(U32.is_eq(op, 20)), Bool.and(Bool.not(U32.is_eq(op, 21)), Bool.not(U32.is_eq(op, 5)))), p_fail(st, "operator requires '(a op b : T)' not '{...}'"), p_eat_sym(st, 125, "expected '}'")), ks}
    case KBraceTy{e} VExpr{ty}: SEval{GPost{EAnn{e, ty}}, p_eat_sym(st, 125, "expected '}'"), ks}
    case KBrackFirst{} VExpr{+e0}: Bool.pick(PStep, p_is_sym(st, 58), SEval{GUnary{}, p_drop(st), Con{KArrTy{e0}, ks}}, SEval{GExprList{93, Con{e0, Nil{}}}, p_opt_drop(st, 44), Con{KWrapExprs{True{}}, ks}})
    case KArrTy{e0} VExpr{ty}: (+is_m = p_is_sym(st, 42); SEval{GExpr{}, Bool.pick(PState, Bool.or(is_m, p_is_sym(st, 94)), p_drop(st), p_fail(st, "expected '*' or '^' in array literal")), Con{KArrLen{EAnn{e0, ty}, is_m}, ks}})
    case KArrLen{e0, +is_m} VExpr{EAnn{ENum{+n}, ESet{}}}: SEval{GPost{EArrNew{Con{e0, Con{ENum{n}, Bool.pick(List<&2, Expr>, is_m, Nil{}, Con{EUnit{}, Nil{}})}}}}, Bool.pick(PState, Bool.and(is_m, Bool.not(Bool.and(U32.is_gt(n, 0), U32.is_zero(U32.and(n, U32.sub(n, 1)))))), p_fail(st, "array count must be a power of two"), p_eat_sym(st, 93, "expected ']'")), ks}
    case KArrLen{e0, +is_m} VExpr{ENum{+n}}: SEval{GPost{EArrNew{Con{e0, Con{ENum{n}, Bool.pick(List<&2, Expr>, is_m, Nil{}, Con{EUnit{}, Nil{}})}}}}, Bool.pick(PState, Bool.and(is_m, Bool.not(Bool.and(U32.is_gt(n, 0), U32.is_zero(U32.and(n, U32.sub(n, 1)))))), p_fail(st, "array count must be a power of two"), p_eat_sym(st, 93, "expected ']'")), ks}
    case KArrLen{e0, is_m} VExpr{len}: SEval{GPost{EArrNew{Con{e0, Con{len, Bool.pick(List<&2, Expr>, is_m, Nil{}, Con{EUnit{}, Nil{}})}}}}, p_eat_sym(st, 93, "expected ']'"), ks}
    case KPostCall{EVar{id}, True{}} VExprs{args}: SEval{GPost{ECtr{id, args}}, st, ks}
    case KPostCall{lhs, _} VExprs{args}: SEval{GPost{EApp{lhs, args}}, st, ks}
    case KPostArrIdx{+lhs} VExpr{+idx}: (+st2 = p_eat_sym(st, 93, "expected ']'"); Bool.pick(PStep, p_is_sym(st2, 266), SEval{GExpr{}, p_drop(st2), Con{KPostArrSet{lhs, idx}, ks}}, SEval{GPost{EArrGet{lhs, idx}}, st2, ks}))
    case KPostArrSet{lhs, idx} VExpr{val}: SEval{GPost{EArrSet{lhs, idx, val}}, st, ks}
    case KUnOp{op} VExpr{e}: SApply{VExpr{EUnOp{op, e}}, st, ks}
    case KBinRhs0{+mp, +prec, +op, lhs} VExpr{r0}: (+next_p = Bool.pick(U32, Bool.or(U32.is_eq(op, 30), U32.is_eq(op, 31)), prec, U32.add(prec, 1)); SEval{GBin{Bool.pick(U32, U32.is_ge(mp, 16), U32.add(16, next_p), next_p), r0}, st, Con{KBinRhs{mp, op, lhs}, ks}})
    case KBinRhs{mp, 30, lhs} VExpr{rhs}: p_bin_sym(True{}, mp, lhs, rhs, p_intern(st, "Con"), ks)
    case KBinRhs{mp, 31, lhs} VExpr{rhs}: p_bin_sym(False{}, mp, lhs, rhs, p_intern(st, "String.append"), ks)
    case KBinRhs{mp, 32, lhs} VExpr{rhs}: p_bin_nsucc(mp, lhs, rhs, p_intern(st, "Nat"), ks)
    case KBinRhs{mp, op, lhs} VExpr{rhs}: SEval{GBin{mp, EOp{op, lhs, rhs}}, st, ks}
    case KArrowBin{+no_gt} VExpr{e0}: SEval{GBin{Bool.pick(U32, no_gt, 17, 1), e0}, st, Con{KArrowLhs{no_gt}, ks}}
    case KArrowLhs{no_gt} VExpr{+lhs}: Bool.pick(PStep, p_is_sym(st, 256), SEval{Bool.pick(PGoal, no_gt, GTypeArg{}, GArrow{False{}}), p_skip_nls(p_drop(st)), Con{KPiBody{Param{0, Some{lhs}, False{}, False{}}, False{}}, ks}}, SApply{VExpr{lhs}, st, ks})
    case KMatchScruts{} VExprs{+sc}: (+st3 = p_skip_nls(p_eat_sym(st, 58, "expected ':' after match")); Bool.pick(PStep, p_is_indent(st3), SEval{GCases{Nil{}}, p_drop(st3), Con{KMatchCases{sc}, ks}}, Bool.pick(PStep, p_is_kw(st3, 6), SEval{GCases{Nil{}}, st3, Con{KMatchCases{sc}, ks}}, SApply{VExpr{EMat{sc, Nil{}}}, st3, ks})))
    case KMatchCases{sc} VCases{cs}: SApply{VExpr{EMat{sc, cs}}, st, ks}
    case KCaseHead{acc} VPats{pats}: SEval{GSuite{}, p_eat_sym(st, 58, "expected ':' after case"), Con{KCaseBody{acc, pats}, ks}}
    case KCaseBody{acc, pats} VExpr{body}: SEval{GCases{Con{Case{pats, body}, acc}}, st, ks}
    case KIfCond{} VExpr{cond}: SEval{GSuite{}, p_eat_sym(st, 58, "expected ':' after if"), Con{KIfThen{cond}, ks}}
    case KIfThen{+cond} VExpr{+thn}: (+st4 = p_skip_nls(st); +st5 = p_drop(st4); Bool.pick(PStep, p_is_kw(st4, 8), Bool.pick(PStep, p_is_kw(st5, 7), SEval{GExpr{}, p_drop(st5), Con{KIfCond{}, Con{KIfElse{cond, thn}, ks}}}, SEval{GSuite{}, p_eat_sym(st5, 58, "expected ':' after else"), Con{KIfElse{cond, thn}, ks}}), SApply{VExpr{EIf{cond, thn, EUnit{}}}, st4, ks}))
    case KIfElse{cond, thn} VExpr{els}: SApply{VExpr{EIf{cond, thn, els}}, st, ks}
    case KDoStmt{acc, True{}} VExpr{val}: SApply{VStmts{b5k_list_rev(Stmt, Con{StRet{val}, acc})}, p_eat_dedent(p_opt_drop(st, 59)), ks}
    case KDoStmt{acc, False{}} VExpr{EArrSet{EVar{+sym}, idx, rhs}}: SEval{GDo{Con{StLet{PVar{sym, False{}}, EArrSet{EVar{sym}, idx, rhs}}, acc}}, p_opt_drop(st, 59), ks}
    case KDoStmt{acc, False{}} VExpr{val}: SEval{GDo{Con{StExpr{val}, acc}}, p_opt_drop(st, 59), ks}
    case KDoPat{+acc, +is_bind} VPat{+pt}: (+sym = Bool.pick(U32, is_bind, 266, 61); +msg = Bool.pick(String, is_bind, "expected '<-'", "expected '='"); Bool.pick(PStep, p_is_sym(st, 58), SEval{GArrow{False{}}, p_drop(st), Con{KEatExpr{sym, msg}, Con{KDoVal{acc, pt, is_bind}, ks}}}, Bool.pick(PStep, Bool.not(is_bind), SApply{VStmts{b5k_list_rev(Stmt, acc)}, p_fail(st, "expected ':' in do-block let"), ks}, Bool.pick(PStep, Bool.or(p_is_sym(st, 60), p_is_sym(st, 40)), SEval{GPost{EHole{}}, st, Con{KEatExpr{266, "expected '<-'"}, Con{KDoVal{acc, PWild{}, True{}}, ks}}}, SEval{GSuite{}, p_eat_sym(st, sym, msg), Con{KDoVal{acc, p_do_untyped_bind_pat(pt), True{}}, ks}}))))
    case KEatExpr{sym, msg} VExpr{_}: SEval{GSuite{}, p_eat_sym(st, sym, msg), ks}
    case KDoVal{acc, PNum{+s1}, True{}} VExpr{+val}: SEval{GDo{Con{StBind{PWild{}, Bool.pick(Expr, U32.is_zero(s1), val, EAnn{val, EAnn{EVar{U32.sub(s1, 1)}, ESet{}}})}, acc}}, p_opt_drop(st, 59), ks}
    case KDoVal{acc, +pt, is_bind} VExpr{+val}: SEval{GDo{Con{Bool.pick(Stmt, is_bind, StBind{pt, val}, StLet{pt, val}), acc}}, p_opt_drop(st, 59), ks}
    case KDoHdr{msym} VExprs{targs}: (+st4 = p_skip_nls(p_eat_sym(st, 58, "expected ':' after do")); SEval{GDo{Nil{}}, Bool.pick(PState, p_is_indent(st4), p_drop(st4), st4), Con{KDoWrap{EApp{EVar{msym}, targs}}, ks}})
    case KDoWrap{hdr} VStmts{ss}: SApply{VExpr{EAnn{EDo{ss}, EAnn{hdr, ESet{}}}}, st, ks}
    case KBlkLetPat{+er} VPat{+pt}: Bool.pick(PStep, p_is_sym(st, 61), SEval{GSuite{}, p_drop(st), Con{KBlkLetVal{pt, er, None{}}, ks}}, Bool.pick(PStep, p_is_sym(st, 58), Bool.pick(PStep, p_pat_is_name(pt), SEval{GArrow{False{}}, p_drop(st), Con{KLetTy{61, "expected '=' in let", pt, er, True{}}, ks}}, SApply{VExpr{EUnit{}}, p_fail(st, "typed let requires a variable name"), ks}), SEval{GPat{}, st, Con{KBlkForkPats{Con{pt, Nil{}}}, ks}}))
    case KLetTy{+sym, +msg, +pt, er, is_blk} VExpr{+ty}: Bool.pick(PStep, is_blk, SEval{GSuite{}, p_eat_sym(st, sym, msg), Con{KBlkLetVal{pt, er, Some{ty}}, ks}}, SEval{GExpr{}, p_eat_sym(st, sym, msg), Con{KILetVal{pt, Some{ty}}, ks}})
    case KBlkForkPats{+ps} VPat{+p}: Bool.pick(PStep, p_is_sym(st, 61), p_fork_start(b5k_list_rev(Pat, Con{p, ps}), p_drop(st), ks), Bool.pick(PStep, Bool.or(p_has_err(st), p_is_eof(st)), SApply{VExpr{EUnit{}}, p_fail(st, "expected '=' in let"), ks}, SEval{GPat{}, st, Con{KBlkForkPats{Con{p, ps}}, ks}}))
    case KBlkForkExprs{cur, Nil{}, ind} VExpr{e}: SEval{GBlock{}, p_opt_drop(Bool.pick(PState, ind, p_eat_dedent(p_skip_nls(st)), st), 59), Con{KBlkLetBody{cur, e}, ks}}
    case KBlkForkExprs{cur, Con{p_next, p_rest}, +ind} VExpr{e}: (+st1 = p_skip_nls(st); +is_ind = Bool.and(Bool.not(ind), p_is_indent(st1)); SEval{GExpr{}, Bool.pick(PState, is_ind, p_drop(st1), st1), Con{KBlkForkExprs{p_next, p_rest, Bool.or(ind, is_ind)}, Con{KBlkLetBody{cur, e}, ks}}})
    case KBlkLetVal{pt, er, ty} VExpr{+val}: SEval{GBlock{}, p_opt_drop(st, 59), Con{KBlkLetBody{pt, Bool.pick(Expr, er, EAnn{val, ERefl{}}, p_opt_ann(val, ty))}, ks}}
    case KBlkLetBody{pt, val} VExpr{body}: SApply{VExpr{ELet{pt, val, body}}, st, ks}
    case KBlkExpr{} VExpr{EArrSet{EVar{+sym}, +idx, +rhs}}: (+st4 = p_skip_nls(p_opt_drop(st, 59)); +e: Expr = EArrSet{EVar{sym}, idx, rhs}; Bool.pick(PStep, U32.is_ge(p_tok_tag(st4), 4), SApply{VExpr{e}, p_eat_dedent(st4), ks}, SEval{GBlock{}, st4, Con{KBlkLetBody{PVar{sym, False{}}, e}, ks}}))
    case KBlkExpr{} VExpr{+e}: (+st4 = p_skip_nls(p_opt_drop(st, 59)); Bool.pick(PStep, U32.is_ge(p_tok_tag(st4), 4), SApply{VExpr{e}, p_eat_dedent(st4), ks}, SEval{GBlock{}, st4, Con{KBlkLetBody{PWild{}, e}, ks}}))
    case KILetPat{} VPat{+pt}: Bool.pick(PStep, p_is_sym(st, 58), SEval{GArrow{False{}}, p_drop(st), Con{KLetTy{61, "expected '=' in let", pt, False{}, False{}}, ks}}, SEval{GExpr{}, p_eat_sym(st, 61, "expected '=' in let"), Con{KILetVal{pt, None{}}, ks}})
    case KILetVal{+pt, ty} VExpr{val0}: (+val = p_opt_ann(val0, ty); cont = Bool.not(Bool.or(p_at_end(st), Bool.or(p_is_nl(st), Bool.or(p_is_sym(st, 41), Bool.or(p_is_sym(st, 93), Bool.or(p_is_sym(st, 125), p_is_sym(st, 44))))))); Bool.pick(PStep, p_is_sym(st, 59), SEval{GExpr{}, p_drop(st), Con{KBlkLetBody{pt, val}, ks}}, Bool.pick(PStep, cont, SEval{GExpr{}, st, Con{KBlkLetBody{pt, val}, ks}}, SApply{VExpr{ELet{pt, val, EUnit{}}}, st, ks})))
    case KLam{no_gt} VParams{pms}: SEval{Bool.pick(PGoal, no_gt, GTypeArg{}, GSuite{}), p_eat_sym(st, 257, "expected '=>'"), Con{KLamBody{pms}, ks}}
    case KLam{no_gt} VParam{Param{+s, ty, er, dup}}: Bool.pick(PStep, p_is_res_lam(st, s), SApply{VExpr{EHole{}}, p_fail(st, "reserved name cannot be a lambda binder"), ks}, SEval{Bool.pick(PGoal, no_gt, GTypeArg{}, GSuite{}), p_eat_sym(st, 257, "expected '=>'"), Con{KLamBody{Con{Param{s, ty, er, dup}, Nil{}}}, ks}})
    case KLamBody{pms} VExpr{body}: SApply{VExpr{ELam{pms, body}}, st, ks}
    case KPiPm{no_gt, is_ex} VParam{pm}: SEval{Bool.pick(PGoal, no_gt, GTypeArg{}, GArrow{False{}}), p_skip_nls(p_eat_sym(st, 256, "expected '->'")), Con{KPiBody{pm, is_ex}, ks}}
    case KPiBody{+pm, is_ex} VExpr{+body}: SApply{VExpr{Bool.pick(Expr, is_ex, EAnn{EAll{pm, body}, ESet{}}, EAll{pm, body})}, st, ks}
    case KBinOnly{no_gt} VExpr{e0}: SEval{GBin{Bool.pick(U32, no_gt, 21, 1), e0}, st, ks}
    case KRewriteEq{} VExpr{+eq}: Bool.pick(PStep, p_is_sym(st, 64), SEval{GUnary{}, p_drop(st), Con{KRewriteEq{}, ks}}, Bool.pick(PStep, p_is_sym(st, 58), SEval{GExpr{}, p_drop(st), Con{KRewriteMot{eq}, ks}}, SApply{VExpr{EAnn{ERefl{}, EEq{eq, EHole{}}}}, st, ks}))
    case KRewriteMot{+eq} VExpr{+mot}: Bool.pick(PStep, p_is_sym(st, 59), SEval{GExpr{}, p_skip_nls(p_drop(st)), Con{KRewriteBody{eq, mot}, ks}}, SApply{VExpr{EAnn{ERefl{}, EEq{eq, mot}}}, st, ks})
    case KRewriteBody{eq, mot} VExpr{b}: SApply{VExpr{ELet{PWild{}, EAnn{ERefl{}, EEq{eq, mot}}, b}}, st, ks}
    case KLamMatArm{+csym, acc} VExpr{+body}: SEval{GLamMat{Con{Case{Con{PWild{}, Nil{}}, Bool.pick(Expr, U32.is_zero(csym), body, EAnn{body, ERef{U32.sub(csym, 1)}})}, acc}}, p_opt_drop(st, 59), ks}
    case KCtorFs{ind, csym, cid, acc} VParams{fs}: SEval{GCtors{ind, Con{CtorDef{csym, cid, fs}, acc}}, st, ks}
    case KTypePms{tsym, ts, ds, ls} VParams{pms}: p_type_body_go(tsym, pms, st, ts, ds, ls)
    case KTypeCtors{tsym, +pms, is_data, +ksym, ts, ds, ls} VCtors{+cs}: SEval{GTop{Con{TypeDef{tsym, pms, is_data, cs}, ts}, ds, ls}, Bool.pick(PState, Bool.and(U32.is_gt(ksym, 0), p_ctors_bad_grade(p_bad_grade_pms(st, ksym, pms), cs)), p_fail(st, "constructor field grade does not match type kind"), st), Nil{}}
    case KLaw{0, lsym, pms, ts, ds, ls} VParam{pm}: SEval{GLawBody{lsym, Con{pm, pms}, ts, ds, ls}, st, Nil{}}
    case KLaw{1, lsym, Con{Param{sym, _, er, dup}, t}, ts, ds, ls} VExpr{_}: SEval{GLawBody{lsym, Con{Param{sym, None{}, er, dup}, t}, ts, ds, ls}, st, Nil{}}
    case KLaw{1, lsym, pms, ts, ds, ls} _: SEval{GLawBody{lsym, pms, ts, ds, ls}, st, Nil{}}
    case KLaw{_, lsym, pms, ts, ds, ls} VExpr{ret}: SEval{GTop{ts, ds, Con{LawDef{lsym, b5k_list_rev(Param, pms), ret}, ls}}, p_eat_dedent(st), Nil{}}
    case KDefPms{dsym, is_u, ts, ds, ls} VParams{pms}: p_def_ret_go(dsym, is_u, pms, st, ts, ds, ls)
    case KDefRet{dsym, is_u, pms, ts, ds, ls} VExpr{ret}: p_def_body_go(dsym, is_u, pms, Some{ret}, st, ts, ds, ls)
    case KDefBody{dsym, is_u, pms, ret, ts, ds, ls} VExpr{body}: SEval{GTop{ts, Con{Def{dsym, pms, ret, body, False{}, Bool.pick(String, is_u, "@unsafe", "")}, ds}, ls}, st, Nil{}}
    case KDefBody{dsym, _, pms, ret, ts, ds, ls} VStr{path}: SEval{GTop{ts, Con{Def{dsym, pms, ret, EUnit{}, True{}, path}, ds}, ls}, st, Nil{}}
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
def b5k_parse_lex(lr: LexRes) -> ParseRes:
  match lr:
    case LexRes{toks, syms1, SNil{}}: p_run(U32.to_nat(4096), SEval{GTop{Nil{}, Nil{}, Nil{}}, PState{toks, syms1, 0, ""}, Nil{}})
    case LexRes{_, syms1, lerr}: ParseRes{False{}, lerr, Book{Nil{}, Nil{}, Nil{}, syms1}}
def b5k_parse(src: String, syms: SymTab) -> ParseRes: b5k_parse_lex(b5k_lex(src, syms))
