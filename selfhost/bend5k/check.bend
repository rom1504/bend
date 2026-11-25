# bend5k/check.bend — 1-Pass Type, Scope, Constructor, Foreign & Affine Checker
# =============================================================================
# Validates a parsed `Book` in one total pass (0 `@unsafe` defs):
#   1. Symbol, type, constructor, def & law table indexing (+ Base builtins)
#   2. Foreign provider allowlist check (fixed runtime)
#   3. Constructor existence, arity & goal-type membership (ECtr & PCtr)
#   4. Affine / linearity use-count checking (non-dup vars <= 1 use per path)
#   5. Scope (unbound var/ref) & direct Def call arity checking
type CheckRes is Data:
  CheckRes{ok: Bool, err: String, book: Book}
type CtorInfo is Data:
  CtorInfo{type_name: String, arity: U32, fdups: List<&2, Bool>}
type CtorEntry is Data:
  CtorEntry{name: String, info: CtorInfo}
type DefInfo is Data:
  DefInfo{arity: U32, total_arity: U32, ret_fn: Bool, is_import: Bool}
def ct_set(-A: Data, t: RaVec<Maybe<&2, A>>, +k: U32, v: A) -> RaVec<Maybe<&2, A>>:
  ra_vec_set(Maybe<&2, A>, 8n, k, Some{v}, t)
def ct_get(-A: Data, t: RaVec<Maybe<&2, A>>, +k: U32) -> Maybe<&2, A>:
  ra_vec_get(Maybe<&2, A>, 8n, None{}, k, t)
type CheckCtx is Data:
  CheckCtx{syms: SymTab, types: RaVec<Maybe<&2, U32>>, ctors: RaVec<Maybe<&2, CtorInfo>>, defs: RaVec<Maybe<&2, DefInfo>>, laws: RaVec<Maybe<&2, LawDef>>}
type VarBind is Data:
  VarBind{sym: U32, dup: Bool}
type PatItem is Data:
  PatItem{pat: Pat, dup_inh: Bool}
type LookupRes is Data:
  LNotFound{}
  LFoundDup{}
  LFoundLin{}
type PatRes is Data:
  PatOk{binds: List<&2, VarBind>}
  PatErr{err: String}
type ExprRes is Data:
  ExprOk{uses: List<&2, U32>}
  ExprErr{err: String}
type ChkWork is Data:
  WExpr{env: List<&2, VarBind>, goal: Maybe<&2, String>, e: Expr}
  WExprs{env: List<&2, VarBind>, es: List<&2, Expr>}
  WCases{env: List<&2, VarBind>, goal: Maybe<&2, String>, sdups: List<&2, Bool>, ssyms: List<&2, U32>, cs: List<&2, Case>}
  WCasePat{env: List<&2, VarBind>, goal: Maybe<&2, String>, pr: PatRes, wstrip: List<&2, VarBind>, body: Expr}
  WStmts{env: List<&2, VarBind>, goal: Maybe<&2, String>, ss: List<&2, Stmt>}
  WStmtPat{env: List<&2, VarBind>, goal: Maybe<&2, String>, pr: PatRes, val: Expr, rest: List<&2, Stmt>}
# Fixed Runtime Allowlist & Built-in Base Tables
# ----------------------------------------------
def b5k_chk_str_match(+is_pre: Bool, xs: List<&2, String>, +s: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{+h, t}: Bool.or(Bool.pick(Bool, is_pre, String.starts_with(s, h), String.eq(h, s)), b5k_chk_str_match(is_pre, t, s))
def b5k_chk_is_runtime_provider(+name: String) -> Bool:
  b5k_chk_str_match(False{}, [
    "IO.args", "IO.args_bytes", "IO.print", "IO.now", "IO.print_err",
    "File.open", "File.open_bytes", "File.read", "File.read_line",
    "File.read_bytes", "File.read_at", "File.size", "File.write",
    "File.write_at", "File.write_bytes", "File.close",
    "NativeHost.read", "NativeHost.path", "NativeHost.publish"
  ], name)
def b5k_chk_base_type_names() -> List<&2, String>:
  [
    "Empty", "Unit", "Bool", "Cmp", "Either", "Sigma", "Pair", "Nat", "Maybe",
    "Result", "Poll", "List", "Word", "Word.Nil", "Word.Con", "U32", "F32",
    "Char", "String", "Array", "Image", "Tool", "Event", "Map", "IO", "IO.OP",
    "App", "File", "Socket", "Listener", "Window", "Audio", "Chan", "Type", "Data", "Kind", "Set"
  ]
def b5k_chk_is_base_name(+name: String) -> Bool:
  Bool.or(b5k_chk_str_match(True{}, [
    "U32.", "F32.", "Char.", "String.", "Bool.", "Nat.", "List.", "Maybe.",
    "Pair.", "Array.", "IO.", "Map.", "File.", "NativeHost.", "Either.",
    "Result.", "Sigma.", "Cmp.", "Word.", "Poll.", "Tool.", "Event.",
    "Image.", "App.", "Socket.", "Listener.", "Window.", "Audio.", "Chan.", "Set.", "Base."
  ], name), b5k_chk_str_match(False{}, ["fst", "snd", "pair", "absurd", "id"], name))
def b5k_chk_base_ctors() -> List<&2, CtorEntry>:
  [
    CtorEntry{"Unit", CtorInfo{"Unit", 0, Nil{}}}, CtorEntry{"False", CtorInfo{"Bool", 0, Nil{}}},
    CtorEntry{"True", CtorInfo{"Bool", 0, Nil{}}}, CtorEntry{"LT", CtorInfo{"Cmp", 0, Nil{}}},
    CtorEntry{"EQ", CtorInfo{"Cmp", 0, Nil{}}}, CtorEntry{"GT", CtorInfo{"Cmp", 0, Nil{}}},
    CtorEntry{"Inl", CtorInfo{"Either", 1, Nil{}}}, CtorEntry{"Inr", CtorInfo{"Either", 1, Nil{}}},
    CtorEntry{"Tuple", CtorInfo{"Sigma", 2, Nil{}}}, CtorEntry{"Pair", CtorInfo{"Pair", 2, Nil{}}},
    CtorEntry{"Zero", CtorInfo{"Nat", 0, Nil{}}}, CtorEntry{"Succ", CtorInfo{"Nat", 1, Nil{}}},
    CtorEntry{"None", CtorInfo{"Maybe", 0, Nil{}}}, CtorEntry{"Some", CtorInfo{"Maybe", 1, Nil{}}},
    CtorEntry{"Fail", CtorInfo{"Result", 1, Nil{}}}, CtorEntry{"Done", CtorInfo{"Result", 1, Nil{}}},
    CtorEntry{"Ready", CtorInfo{"Poll", 1, Nil{}}}, CtorEntry{"Wait", CtorInfo{"Poll", 1, Nil{}}},
    CtorEntry{"Nil", CtorInfo{"List", 0, Nil{}}}, CtorEntry{"Con", CtorInfo{"List", 2, Nil{}}},
    CtorEntry{"WNil", CtorInfo{"Word.Nil", 0, Nil{}}}, CtorEntry{"WCon", CtorInfo{"Word.Con", 2, Nil{}}},
    CtorEntry{"U32", CtorInfo{"U32", 1, Nil{}}}, CtorEntry{"F32", CtorInfo{"F32", 1, Nil{}}},
    CtorEntry{"Chr", CtorInfo{"Char", 1, Nil{}}}, CtorEntry{"SNil", CtorInfo{"String", 0, Nil{}}},
    CtorEntry{"SCon", CtorInfo{"String", 2, Nil{}}}, CtorEntry{"ALeaf", CtorInfo{"Array", 1, Nil{}}},
    CtorEntry{"ANode", CtorInfo{"Array", 2, Nil{}}}, CtorEntry{"MTip", CtorInfo{"Map", 0, Nil{}}},
    CtorEntry{"MLeaf", CtorInfo{"Map", 2, Nil{}}}, CtorEntry{"MNode", CtorInfo{"Map", 3, Nil{}}},
    CtorEntry{"Emit", CtorInfo{"IO.OP", 1, Nil{}}}, CtorEntry{"Halt", CtorInfo{"IO.OP", 2, Nil{}}},
    CtorEntry{"Exit", CtorInfo{"IO.OP", 1, Nil{}}}, CtorEntry{"Pix", CtorInfo{"Image", 1, Nil{}}},
    CtorEntry{"Qua", CtorInfo{"Image", 4, Nil{}}}, CtorEntry{"App", CtorInfo{"App", 2, Nil{}}}
  ]
# Symbol, Type, Constructor, Def & Law Indexing
# ---------------------------------------------
def b5k_chk_param_dups(ps: List<&2, Param>) -> List<&2, Bool>:
  match ps:
    case Nil{}: Nil{}
    case Con{Param{_, _, erased, dup}, rest}: Con{Bool.or(erased, dup), b5k_chk_param_dups(rest)}
def ct_set_maybe(-A: Data, m: Maybe<&2, U32>, v: A, t: RaVec<Maybe<&2, A>>) -> RaVec<Maybe<&2, A>>:
  match m:
    case None{}: t
    case Some{s}: ct_set(A, t, s, v)
def b5k_chk_seed_base_types(+syms: SymTab, ns: List<&2, String>, tm: RaVec<Maybe<&2, U32>>) -> RaVec<Maybe<&2, U32>>:
  match ns:
    case Nil{}: tm
    case Con{nm, rest}: b5k_chk_seed_base_types(syms, rest, ct_set_maybe(U32, symtab_lookup(syms, nm), 1, tm))
def b5k_chk_seed_base_ctors(+syms: SymTab, cs: List<&2, CtorEntry>, cm: RaVec<Maybe<&2, CtorInfo>>) -> RaVec<Maybe<&2, CtorInfo>>:
  match cs:
    case Nil{}: cm
    case Con{CtorEntry{nm, info}, rest}: b5k_chk_seed_base_ctors(syms, rest, ct_set_maybe(CtorInfo, symtab_lookup(syms, nm), info, cm))
def b5k_chk_index_ctors(+tname: String, cs: List<&2, CtorDef>, cm: RaVec<Maybe<&2, CtorInfo>>) -> RaVec<Maybe<&2, CtorInfo>>:
  match cs:
    case Nil{}: cm
    case Con{CtorDef{csym, _, +fields}, rest}:
      b5k_chk_index_ctors(tname, rest, ct_set(CtorInfo, cm, csym, CtorInfo{tname, b5k_list_len(Param, fields), b5k_chk_param_dups(fields)}))
def b5k_chk_index_types(ts: List<&2, TypeDef>, tm: RaVec<Maybe<&2, U32>>) -> RaVec<Maybe<&2, U32>>:
  match ts:
    case Nil{}: tm
    case Con{TypeDef{tsym, _, _, _}, rest}: b5k_chk_index_types(rest, ct_set(U32, tm, tsym, 1))
def b5k_chk_index_all_ctors(+syms: SymTab, ts: List<&2, TypeDef>, cm: RaVec<Maybe<&2, CtorInfo>>) -> RaVec<Maybe<&2, CtorInfo>>:
  match ts:
    case Nil{}: cm
    case Con{TypeDef{tsym, _, _, ctors}, rest}:
      b5k_chk_index_all_ctors(syms, rest, b5k_chk_index_ctors(symtab_name(syms, tsym), ctors, cm))
def b5k_chk_count_live(ps: List<&2, Param>, +acc: U32) -> U32:
  match ps:
    case Nil{}: acc
    case Con{Param{_, _, erased, _}, rest}: b5k_chk_count_live(rest, Bool.pick(U32, erased, acc, U32.add(acc, 1)))
def b5k_chk_ret_is_fn(ret: Maybe<&2, Expr>) -> Bool:
  match ret:
    case Some{EAll{_, _}}: True{}
    case _: False{}
def b5k_chk_opt_or(-A: Data, a: Maybe<&2, A>, b: Maybe<&2, A>) -> Maybe<&2, A>:
  match a:
    case Some{x}: Some{x}
    case None{}: b
def b5k_chk_merge_law_params(ps: List<&2, Param>, lps: List<&2, Param>) -> List<&2, Param>:
  match ps lps:
    case Nil{} _: Nil{}
    case Con{p, prest} Nil{}: Con{p, prest}
    case Con{Param{sym, typ, er, dup}, prest} Con{Param{_, ltyp, ler, ldup}, lrest}:
      Con{Param{sym, b5k_chk_opt_or(Expr, typ, ltyp), Bool.or(er, ler), Bool.or(dup, ldup)}, b5k_chk_merge_law_params(prest, lrest)}
def b5k_chk_apply_law_params(ps: List<&2, Param>, ld: Maybe<&2, LawDef>) -> List<&2, Param>:
  match ld:
    case None{}: ps
    case Some{LawDef{_, lps, _}}: b5k_chk_merge_law_params(ps, lps)
def b5k_chk_apply_law_ret(ret: Maybe<&2, Expr>, ld: Maybe<&2, LawDef>) -> Maybe<&2, Expr>:
  match ret ld:
    case Some{e} _: Some{e}
    case None{} Some{LawDef{_, _, lret}}: Some{lret}
    case None{} None{}: None{}
def b5k_chk_index_defs(+lm: RaVec<Maybe<&2, LawDef>>, ds: List<&2, Def>, dm: RaVec<Maybe<&2, DefInfo>>) -> RaVec<Maybe<&2, DefInfo>>:
  match ds:
    case Nil{}: dm
    case Con{Def{+dsym, params, ret, _, is_import, _}, rest}:
      +ld = ct_get(LawDef, lm, dsym)
      +mps = b5k_chk_apply_law_params(params, ld)
      mret = b5k_chk_apply_law_ret(ret, ld)
      b5k_chk_index_defs(lm, rest, ct_set(DefInfo, dm, dsym,
        DefInfo{b5k_chk_count_live(mps, 0), b5k_list_len(Param, mps), b5k_chk_ret_is_fn(mret), is_import}))
def b5k_chk_index_laws(ls: List<&2, LawDef>, lm: RaVec<Maybe<&2, LawDef>>) -> RaVec<Maybe<&2, LawDef>>:
  match ls:
    case Nil{}: lm
    case Con{LawDef{+lsym, lps, lret}, rest}: b5k_chk_index_laws(rest, ct_set(LawDef, lm, lsym, LawDef{lsym, lps, lret}))
def b5k_chk_build_ctx(+types: List<&2, TypeDef>, defs: List<&2, Def>, laws: List<&2, LawDef>, +syms: SymTab) -> CheckCtx:
  tm = b5k_chk_index_types(types, b5k_chk_seed_base_types(syms, b5k_chk_base_type_names(), RVEmpty{}))
  cm = b5k_chk_index_all_ctors(syms, types, b5k_chk_seed_base_ctors(syms, b5k_chk_base_ctors(), RVEmpty{}))
  +lm = b5k_chk_index_laws(laws, RVEmpty{})
  CheckCtx{syms, tm, cm, b5k_chk_index_defs(lm, defs, RVEmpty{}), lm}
# Context Lookup Helpers
# ----------------------
def b5k_chk_sym_name(ctx: CheckCtx, sym: U32) -> String:
  CheckCtx{syms, _, _, _, _} = ctx
  symtab_name(syms, sym)
def b5k_chk_lookup_ctor(ctx: CheckCtx, sym: U32) -> Maybe<&2, CtorInfo>:
  CheckCtx{_, _, ctors, _, _} = ctx
  ct_get(CtorInfo, ctors, sym)
def b5k_chk_is_some(-A: Data, m: Maybe<&2, A>) -> Bool:
  match m:
    case Some{_}: True{}
    case None{}: False{}
def b5k_chk_known_g2(hit: Bool, syms: SymTab, sym: U32) -> Bool:
  match hit:
    case True{}: True{}
    case False{}: b5k_chk_is_base_name(symtab_name(syms, sym))
def b5k_chk_is_known_global(ctx: CheckCtx, +sym: U32) -> Bool:
  CheckCtx{syms, types, ctors, defs, laws} = ctx
  hit = Bool.or(Bool.or(b5k_chk_is_some(DefInfo, ct_get(DefInfo, defs, sym)), b5k_chk_is_some(CtorInfo, ct_get(CtorInfo, ctors, sym))),
                Bool.or(b5k_chk_is_some(U32, ct_get(U32, types, sym)), b5k_chk_is_some(LawDef, ct_get(LawDef, laws, sym))))
  b5k_chk_known_g2(hit, syms, sym)
# Local Environment & Affine Use-Set Algebra
# ------------------------------------------
def b5k_chk_env_go(env: List<&2, VarBind>, hit: Bool, dup: Bool, +sym: U32) -> LookupRes:
  match env hit dup:
    case _ True{} True{}: LFoundDup{}
    case _ True{} False{}: LFoundLin{}
    case Nil{} False{} _: LNotFound{}
    case Con{VarBind{s, d}, rest} False{} _: b5k_chk_env_go(rest, U32.is_eq(s, sym), d, sym)
def b5k_chk_env_lookup(env: List<&2, VarBind>, sym: U32) -> LookupRes:
  b5k_chk_env_go(env, False{}, False{}, sym)
def b5k_chk_u32_mem(xs: List<&2, U32>, +x: U32) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, t}: Bool.or(U32.is_eq(h, x), b5k_chk_u32_mem(t, x))
def b5k_chk_uses_sum_step(dup_hit: Bool, fn_name: String, h: U32, rest_res: ExprRes) -> ExprRes:
  match dup_hit rest_res:
    case True{} _: ExprErr{"check: " ++ fn_name ++ ": affine variable consumed more than allowed"}
    case False{} ExprErr{err}: ExprErr{err}
    case False{} ExprOk{us}: ExprOk{Con{h, us}}
def b5k_chk_uses_sum(+fn_name: String, u1: List<&2, U32>, +u2: List<&2, U32>) -> ExprRes:
  match u1:
    case Nil{}: ExprOk{u2}
    case Con{+h, t}: b5k_chk_uses_sum_step(b5k_chk_u32_mem(u2, h), fn_name, h, b5k_chk_uses_sum(fn_name, t, u2))
def b5k_chk_uses_branch(u1: List<&2, U32>, +u2: List<&2, U32>) -> List<&2, U32>:
  match u1:
    case Nil{}: u2
    case Con{+h, t}:
      +rest = b5k_chk_uses_branch(t, u2)
      Bool.pick(List<&2, U32>, b5k_chk_u32_mem(u2, h), rest, Con{h, rest})
def b5k_chk_binds_mem(bs: List<&2, VarBind>, +sym: U32) -> Bool:
  match bs:
    case Nil{}: False{}
    case Con{VarBind{s, _}, t}: Bool.or(U32.is_eq(s, sym), b5k_chk_binds_mem(t, sym))
def b5k_chk_uses_strip(+bs: List<&2, VarBind>, us: List<&2, U32>) -> List<&2, U32>:
  match us:
    case Nil{}: Nil{}
    case Con{+h, t}:
      +rest = b5k_chk_uses_strip(bs, t)
      Bool.pick(List<&2, U32>, b5k_chk_binds_mem(bs, h), rest, Con{h, rest})
def b5k_chk_params_binds(ps: List<&2, Param>) -> List<&2, VarBind>:
  match ps:
    case Nil{}: Nil{}
    case Con{Param{sym, _, erased, dup}, rest}: Con{VarBind{sym, Bool.or(erased, dup)}, b5k_chk_params_binds(rest)}
# Pattern Checking & Binding Extraction
# -------------------------------------
def b5k_chk_ctor_err(fn_name: String) -> String:
  "check: " ++ fn_name ++ ": constructor does not belong to goal or field count differs"
def b5k_chk_ctor_ok(info: Maybe<&2, CtorInfo>, nargs: U32, goal: Maybe<&2, String>) -> Bool:
  match info goal:
    case None{} _: False{}
    case Some{CtorInfo{_, arity, _}} None{}: U32.is_eq(nargs, arity)
    case Some{CtorInfo{tname, arity, _}} Some{g}: Bool.and(U32.is_eq(nargs, arity), String.eq(tname, g))
def b5k_chk_ctor_fdups(info: Maybe<&2, CtorInfo>) -> List<&2, Bool>:
  match info:
    case None{}: Nil{}
    case Some{CtorInfo{_, _, fdups}}: fdups
def b5k_chk_zip_pats(ps: List<&2, Pat>, ds: List<&2, Bool>, +def_dup: Bool) -> List<&2, PatItem>:
  match ps ds:
    case Nil{} _: Nil{}
    case Con{p, pt} Nil{}: Con{PatItem{p, def_dup}, b5k_chk_zip_pats(pt, Nil{}, def_dup)}
    case Con{p, pt} Con{d, dt}: Con{PatItem{p, Bool.or(d, def_dup)}, b5k_chk_zip_pats(pt, dt, def_dup)}
def b5k_chk_lr_is_dup(lr: LookupRes) -> Bool:
  match lr:
    case LFoundDup{}: True{}
    case _: False{}
def b5k_chk_expr_is_dup(env: List<&2, VarBind>, e: Expr) -> Bool:
  match e:
    case EVar{sym}: b5k_chk_lr_is_dup(b5k_chk_env_lookup(env, sym))
    case EAnn{val, _}: b5k_chk_expr_is_dup(env, val)
    case ENum{_}: True{}
    case EFlt{_}: True{}
    case EChr{_}: True{}
    case EStr{_}: True{}
    case EUnit{}: True{}
    case _: False{}
def b5k_chk_scruts_dups(+env: List<&2, VarBind>, es: List<&2, Expr>) -> List<&2, Bool>:
  match es:
    case Nil{}: Nil{}
    case Con{h, t}: Con{b5k_chk_expr_is_dup(env, h), b5k_chk_scruts_dups(env, t)}
def b5k_chk_scruts_syms(es: List<&2, Expr>) -> List<&2, U32>:
  match es:
    case Nil{}: Nil{}
    case Con{EVar{sym}, t}: Con{U32.add(sym, 1), b5k_chk_scruts_syms(t)}
    case Con{_, t}: Con{0, b5k_chk_scruts_syms(t)}
def b5k_chk_wild_strip(ps: List<&2, Pat>, ss: List<&2, U32>) -> List<&2, VarBind>:
  match ps ss:
    case Con{PWild{}, pt} Con{+s, st}:
      +rest = b5k_chk_wild_strip(pt, st)
      Bool.pick(List<&2, VarBind>, U32.is_zero(s), rest, Con{VarBind{U32.sub(s, 1), False{}}, rest})
    case Con{_, pt} Con{_, st}: b5k_chk_wild_strip(pt, st)
    case _ _: Nil{}
def b5k_chk_pat_guard(ok: Bool, fn_name: String, res: PatRes) -> PatRes:
  match ok:
    case False{}: PatErr{b5k_chk_ctor_err(fn_name)}
    case True{}: res
def b5k_chk_pats(fuel: Nat, +ctx: CheckCtx, +fn_name: String, ps: List<&2, PatItem>, acc: List<&2, VarBind>) -> PatRes:
  match fuel ps:
    case 0n _: PatOk{acc}
    case _ Nil{}: PatOk{acc}
    case 1n+f Con{PatItem{PVar{sym, dup}, inh}, rest}: b5k_chk_pats(f, ctx, fn_name, rest, Con{VarBind{sym, Bool.or(dup, inh)}, acc})
    case 1n+f Con{PatItem{PCtr{sym, +fields}, inh}, rest}:
      +info = b5k_chk_lookup_ctor(ctx, sym)
      ok = b5k_chk_ctor_ok(info, b5k_list_len(Pat, fields), None{})
      items = b5k_chk_zip_pats(fields, b5k_chk_ctor_fdups(info), inh)
      b5k_chk_pat_guard(ok, fn_name, b5k_chk_pats(f, ctx, fn_name, b5k_list_app(PatItem, items, rest), acc))
    case 1n+f Con{PatItem{PPair{fst, snd}, +inh}, rest}: b5k_chk_pats(f, ctx, fn_name, Con{PatItem{fst, inh}, Con{PatItem{snd, inh}, rest}}, acc)
    case 1n+f Con{PatItem{PList{elems}, inh}, rest}: b5k_chk_pats(f, ctx, fn_name, b5k_list_app(PatItem, b5k_chk_zip_pats(elems, Nil{}, inh), rest), acc)
    case 1n+f Con{PatItem{_, _}, rest}: b5k_chk_pats(f, ctx, fn_name, rest, acc)
# Goal Extraction & Direct Call Arity Check
# -----------------------------------------
def b5k_chk_goal_sym(ctx: CheckCtx, +sym: U32) -> Maybe<&2, String>:
  CheckCtx{syms, types, _, _, _} = ctx
  Bool.pick(Maybe<&2, String>, b5k_chk_is_some(U32, ct_get(U32, types, sym)), Some{symtab_name(syms, sym)}, None{})
def b5k_chk_goal_expr(+ctx: CheckCtx, e: Expr) -> Maybe<&2, String>:
  match e:
    case EVar{sym}: b5k_chk_goal_sym(ctx, sym)
    case ERef{sym}: b5k_chk_goal_sym(ctx, sym)
    case EApp{fun, _}: b5k_chk_goal_expr(ctx, fun)
    case _: None{}
def b5k_chk_goal_opt(+ctx: CheckCtx, opt: Maybe<&2, Expr>) -> Maybe<&2, String>:
  match opt:
    case None{}: None{}
    case Some{e}: b5k_chk_goal_expr(ctx, e)
def b5k_chk_call_err_k(bad: Bool, ctx: CheckCtx, fn_name: String, sym: U32) -> String:
  match bad:
    case True{}: "check: " ++ fn_name ++ ": call arity mismatch for " ++ b5k_chk_sym_name(ctx, sym)
    case False{}: ""
def b5k_chk_call_def(info: Maybe<&2, DefInfo>, ctx: CheckCtx, fn_name: String, sym: U32, +nargs: U32) -> String:
  match info:
    case None{}: ""
    case Some{DefInfo{arity, total_arity, ret_fn, _}}:
      bad = Bool.or(Bool.and(U32.is_gt(nargs, total_arity), Bool.not(ret_fn)), Bool.and(U32.is_zero(nargs), Bool.not(U32.is_zero(arity))))
      b5k_chk_call_err_k(bad, ctx, fn_name, sym)
def b5k_chk_call_lookup(lr: LookupRes, +ctx: CheckCtx, fn_name: String, +sym: U32, nargs: U32) -> String:
  match lr ctx:
    case LNotFound{} CheckCtx{_, _, _, defs, _}: b5k_chk_call_def(ct_get(DefInfo, defs, sym), ctx, fn_name, sym, nargs)
    case _ _: ""
def b5k_chk_call_arity(+ctx: CheckCtx, fn_name: String, env: List<&2, VarBind>, fun: Expr, nargs: U32) -> String:
  match fun:
    case EVar{+sym}: b5k_chk_call_lookup(b5k_chk_env_lookup(env, sym), ctx, fn_name, sym, nargs)
    case ERef{+sym}: b5k_chk_call_lookup(b5k_chk_env_lookup(env, sym), ctx, fn_name, sym, nargs)
    case _: ""
# Expression Checker (Scope + Ctor/Goal + Arity + Affine)
# -------------------------------------------------------
def b5k_chk_var_gk(ok: Bool, is_ref: Bool, ctx: CheckCtx, fn_name: String, sym: U32) -> ExprRes:
  match ok is_ref:
    case True{} _: ExprOk{Nil{}}
    case False{} True{}: ExprErr{"check: " ++ fn_name ++ ": unbound reference: " ++ b5k_chk_sym_name(ctx, sym)}
    case False{} False{}: ExprErr{"check: " ++ fn_name ++ ": unbound variable: " ++ b5k_chk_sym_name(ctx, sym)}
def b5k_chk_var_lookup(lr: LookupRes, +ctx: CheckCtx, fn_name: String, +sym: U32, is_ref: Bool) -> ExprRes:
  match lr:
    case LFoundDup{}: ExprOk{Nil{}}
    case LFoundLin{}: ExprOk{Con{sym, Nil{}}}
    case LNotFound{}: b5k_chk_var_gk(b5k_chk_is_known_global(ctx, sym), is_ref, ctx, fn_name, sym)
def b5k_chk_var(+ctx: CheckCtx, fn_name: String, env: List<&2, VarBind>, +sym: U32, is_ref: Bool) -> ExprRes:
  b5k_chk_var_lookup(b5k_chk_env_lookup(env, sym), ctx, fn_name, sym, is_ref)
def b5k_chk_merge(is_br: Bool, fn_name: String, r1: ExprRes, r2: ExprRes) -> ExprRes:
  match is_br r1 r2:
    case _ ExprErr{err} _: ExprErr{err}
    case _ ExprOk{_} ExprErr{err}: ExprErr{err}
    case True{} ExprOk{u1} ExprOk{u2}: ExprOk{b5k_chk_uses_branch(u1, u2)}
    case False{} ExprOk{u1} ExprOk{u2}: b5k_chk_uses_sum(fn_name, u1, u2)
def b5k_chk_strip_res(bs: List<&2, VarBind>, r: ExprRes) -> ExprRes:
  match r:
    case ExprErr{err}: ExprErr{err}
    case ExprOk{u}: ExprOk{b5k_chk_uses_strip(bs, u)}
def b5k_chk_ctr_guard(ok: Bool, fn_name: String, res: ExprRes) -> ExprRes:
  match ok:
    case True{}: res
    case False{}: ExprErr{b5k_chk_ctor_err(fn_name)}
def b5k_chk_lit_k(ok: Bool, fn_name: String, got: String) -> ExprRes:
  match ok:
    case True{}: ExprOk{Nil{}}
    case False{}: ExprErr{"check: " ++ fn_name ++ ": literal type mismatch (" ++ got ++ ")"}
def b5k_chk_lit(goal: Maybe<&2, String>, fn_name: String, +got: String, is_num: Bool) -> ExprRes:
  match goal:
    case None{}: ExprOk{Nil{}}
    case Some{+g}: b5k_chk_lit_k(Bool.or(b5k_str_eq(g, got), Bool.and(is_num, b5k_str_eq(g, "Nat"))), fn_name, got)
def b5k_chk_work(+fuel: Nat, +ctx: CheckCtx, +fn_name: String, w: ChkWork) -> ExprRes:
  match fuel w:
    case 0n _: ExprOk{Nil{}}
    case 1n+f WExprs{_, Nil{}}: ExprOk{Nil{}}
    case 1n+f WExprs{+env, Con{h, t}}:
      b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, h}), b5k_chk_work(f, ctx, fn_name, WExprs{env, t}))
    case 1n+f WCases{_, _, _, _, Nil{}}: ExprOk{Nil{}}
    case 1n+f WCases{+env, +goal, +sdups, +ssyms, Con{Case{+pats, body}, rest}}:
      pr = b5k_chk_pats(U32.to_nat(256), ctx, fn_name, b5k_chk_zip_pats(pats, sdups, False{}), Nil{})
      ws = b5k_chk_wild_strip(pats, ssyms)
      b5k_chk_merge(True{}, fn_name, b5k_chk_work(f, ctx, fn_name, WCasePat{env, goal, pr, ws, body}), b5k_chk_work(f, ctx, fn_name, WCases{env, goal, sdups, ssyms, rest}))
    case 1n+f WCasePat{_, _, PatErr{err}, _, _}: ExprErr{err}
    case 1n+f WCasePat{env, goal, PatOk{+bs}, ws, body}:
      b5k_chk_strip_res(b5k_list_app(VarBind, bs, ws), b5k_chk_work(f, ctx, fn_name, WExpr{b5k_list_app(VarBind, bs, env), goal, body}))
    case 1n+f WStmtPat{_, _, PatErr{err}, _, _}: ExprErr{err}
    case 1n+f WStmtPat{+env, goal, PatOk{+bs}, val, rest}:
      r1 = b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, val})
      r2 = b5k_chk_strip_res(bs, b5k_chk_work(f, ctx, fn_name, WStmts{b5k_list_app(VarBind, bs, env), goal, rest}))
      b5k_chk_merge(False{}, fn_name, r1, r2)
    case 1n+f WStmts{_, _, Nil{}}: ExprOk{Nil{}}
    case 1n+f WStmts{env, goal, Con{StBind{pat, val}, rest}}:
      b5k_chk_work(f, ctx, fn_name, WStmtPat{env, goal, b5k_chk_pats(U32.to_nat(256), ctx, fn_name, [PatItem{pat, False{}}], Nil{}), val, rest})
    case 1n+f WStmts{+env, goal, Con{StLet{pat, +val}, rest}}:
      inh = b5k_chk_expr_is_dup(env, val)
      b5k_chk_work(f, ctx, fn_name, WStmtPat{env, goal, b5k_chk_pats(U32.to_nat(256), ctx, fn_name, [PatItem{pat, inh}], Nil{}), val, rest})
    case 1n+f WStmts{env, goal, Con{StExpr{val}, Nil{}}}: b5k_chk_work(f, ctx, fn_name, WExpr{env, goal, val})
    case 1n+f WStmts{+env, goal, Con{StExpr{val}, rest}}:
      b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, val}), b5k_chk_work(f, ctx, fn_name, WStmts{env, goal, rest}))
    case 1n+f WStmts{env, goal, Con{StRet{val}, Nil{}}}: b5k_chk_work(f, ctx, fn_name, WExpr{env, goal, val})
    case 1n+f WStmts{+env, goal, Con{StRet{val}, rest}}:
      b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, val}), b5k_chk_work(f, ctx, fn_name, WStmts{env, goal, rest}))
    case 1n+f WExpr{_, goal, ENum{_}}: b5k_chk_lit(goal, fn_name, "U32", True{})
    case 1n+f WExpr{_, goal, EFlt{_}}: b5k_chk_lit(goal, fn_name, "F32", False{})
    case 1n+f WExpr{_, goal, EChr{_}}: b5k_chk_lit(goal, fn_name, "Char", False{})
    case 1n+f WExpr{_, goal, EStr{_}}: b5k_chk_lit(goal, fn_name, "String", False{})
    case 1n+f WExpr{env, _, EVar{sym}}: b5k_chk_var(ctx, fn_name, env, sym, False{})
    case 1n+f WExpr{env, _, ERef{sym}}: b5k_chk_var(ctx, fn_name, env, sym, True{})
    case 1n+f WExpr{+env, _, EApp{+fun, +args}}:
      +aerr = b5k_chk_call_arity(ctx, fn_name, env, fun, b5k_list_len(Expr, args))
      res = b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, fun}), b5k_chk_work(f, ctx, fn_name, WExprs{env, args}))
      Bool.pick(ExprRes, String.is_empty(aerr), res, ExprErr{aerr})
    case 1n+f WExpr{env, _, ELam{params, body}}:
      +bs = b5k_chk_params_binds(params)
      b5k_chk_strip_res(bs, b5k_chk_work(f, ctx, fn_name, WExpr{b5k_list_app(VarBind, bs, env), None{}, body}))
    case 1n+f WExpr{+env, goal, ELet{pat, +val, body}}:
      inh = b5k_chk_expr_is_dup(env, val)
      b5k_chk_work(f, ctx, fn_name, WStmtPat{env, goal, b5k_chk_pats(U32.to_nat(256), ctx, fn_name, [PatItem{pat, inh}], Nil{}), val, [StExpr{body}]})
    case 1n+f WExpr{+env, goal, EMat{+scruts, cases}}:
      sdups = b5k_chk_scruts_dups(env, scruts)
      ssyms = b5k_chk_scruts_syms(scruts)
      b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, fn_name, WExprs{env, scruts}), b5k_chk_work(f, ctx, fn_name, WCases{env, goal, sdups, ssyms, cases}))
    case 1n+f WExpr{env, goal, ECtr{sym, +fields}}:
      ok = b5k_chk_ctor_ok(b5k_chk_lookup_ctor(ctx, sym), b5k_list_len(Expr, fields), goal)
      b5k_chk_ctr_guard(ok, fn_name, b5k_chk_work(f, ctx, fn_name, WExprs{env, fields}))
    case 1n+f WExpr{env, _, EAnn{val, typ}}: b5k_chk_work(f, ctx, fn_name, WExpr{env, b5k_chk_goal_expr(ctx, typ), val})
    case 1n+f WExpr{env, _, EEq{a, b}}: b5k_chk_work(f, ctx, fn_name, WExprs{env, [a, b]})
    case 1n+f WExpr{env, _, EOp{_, a, b}}: b5k_chk_work(f, ctx, fn_name, WExprs{env, [a, b]})
    case 1n+f WExpr{env, _, EUnOp{_, val}}: b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, val})
    case 1n+f WExpr{env, _, EArrNew{elems}}: b5k_chk_work(f, ctx, fn_name, WExprs{env, elems})
    case 1n+f WExpr{env, _, EArrGet{arr, idx}}: b5k_chk_work(f, ctx, fn_name, WExprs{env, [arr, idx]})
    case 1n+f WExpr{env, _, EArrSet{arr, idx, val}}: b5k_chk_work(f, ctx, fn_name, WExprs{env, [arr, idx, val]})
    case 1n+f WExpr{+env, +goal, EIf{cond, then_e, else_e}}:
      rc = b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, cond})
      rb = b5k_chk_merge(True{}, fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, goal, then_e}), b5k_chk_work(f, ctx, fn_name, WExpr{env, goal, else_e}))
      b5k_chk_merge(False{}, fn_name, rc, rb)
    case 1n+f WExpr{env, goal, EDo{stmts}}: b5k_chk_work(f, ctx, fn_name, WStmts{env, goal, stmts})
    case 1n+f WExpr{env, _, EPair{a, b}}: b5k_chk_work(f, ctx, fn_name, WExprs{env, [a, b]})
    case 1n+f WExpr{env, _, EList{elems}}: b5k_chk_work(f, ctx, fn_name, WExprs{env, elems})
    case 1n+_ WExpr{_, _, _}: ExprOk{Nil{}}
# Top-Level Book Entrypoint
# -------------------------
def b5k_chk_expr_err(r: ExprRes) -> String:
  match r:
    case ExprOk{_}: ""
    case ExprErr{err}: err
def b5k_chk_def(+ctx: CheckCtx, d: Def) -> String:
  CheckCtx{_, _, _, _, laws} = ctx
  Def{+sym, params, ret, body, is_import, _} = d
  match is_import:
    case True{}:
      +fn_name = b5k_chk_sym_name(ctx, sym)
      Bool.pick(String, b5k_chk_is_runtime_provider(fn_name), "", "compile: foreign provider unavailable in fixed runtime: " ++ fn_name)
    case False{}:
      +fn_name = b5k_chk_sym_name(ctx, sym)
      +ld = ct_get(LawDef, laws, sym)
      env = b5k_chk_params_binds(b5k_chk_apply_law_params(params, ld))
      goal = b5k_chk_goal_opt(ctx, b5k_chk_apply_law_ret(ret, ld))
      b5k_chk_expr_err(b5k_chk_work(U32.to_nat(4096), ctx, fn_name, WExpr{env, goal, body}))
def b5k_chk_defs(+ctx: CheckCtx, ds: List<&2, Def>) -> String:
  match ds:
    case Nil{}: ""
    case Con{h, t}:
      +err = b5k_chk_def(ctx, h)
      Bool.pick(String, String.is_empty(err), b5k_chk_defs(ctx, t), err)
def b5k_check(+book: Book) -> CheckRes:
  Book{types, +defs, laws, syms} = book
  +err = b5k_chk_defs(b5k_chk_build_ctx(types, defs, laws, syms), defs)
  CheckRes{String.is_empty(err), err, book}
