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
  CtorInfo{type_name: String, arity: U32}

type CtorEntry is Data:
  CtorEntry{name: String, info: CtorInfo}

type DefInfo is Data:
  DefInfo{arity: U32, total_arity: U32, ret_fn: Bool, is_import: Bool}

type CheckCtx is Data:
  CheckCtx{
    syms: SymTab,
    types: Map<&2, U32>,
    ctors: Map<&2, Maybe<&2, CtorInfo>>,
    defs: Map<&2, Maybe<&2, DefInfo>>,
    laws: Map<&2, U32>
  }

type VarBind is Data:
  VarBind{sym: U32, dup: Bool}

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
  WCases{env: List<&2, VarBind>, goal: Maybe<&2, String>, cs: List<&2, Case>}
  WCasePat{env: List<&2, VarBind>, goal: Maybe<&2, String>, pr: PatRes, body: Expr}
  WLetPat{env: List<&2, VarBind>, goal: Maybe<&2, String>, pr: PatRes, val: Expr, body: Expr}
  WStmts{env: List<&2, VarBind>, goal: Maybe<&2, String>, ss: List<&2, Stmt>}
  WStmtPat{env: List<&2, VarBind>, goal: Maybe<&2, String>, pr: PatRes, val: Expr, rest: List<&2, Stmt>}

# Fixed Runtime Allowlist & Built-in Base Tables
# ----------------------------------------------

def b5k_chk_snd(-A: Data, -B: Data, p: A & B) -> B:
  (_, b) = p
  b

def b5k_chk_str_in(xs: List<&2, String>, +s: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, t}: Bool.or(String.eq(h, s), b5k_chk_str_in(t, s))

def b5k_chk_has_prefix(ps: List<&2, String>, +s: String) -> Bool:
  match ps:
    case Nil{}: False{}
    case Con{p, t}: Bool.or(String.starts_with(s, p), b5k_chk_has_prefix(t, s))

def b5k_chk_is_runtime_provider(+name: String) -> Bool:
  b5k_chk_str_in([
    "IO.args", "IO.args_bytes", "IO.print", "IO.now", "IO.print_err",
    "File.open", "File.open_bytes", "File.read", "File.read_line",
    "File.read_bytes", "File.read_at", "File.size", "File.write",
    "File.write_at", "File.write_bytes", "File.close",
    "NativeHost.read", "NativeHost.path", "NativeHost.publish"
  ], name)

def b5k_chk_is_base_prefix(+name: String) -> Bool:
  b5k_chk_has_prefix([
    "U32.", "F32.", "Char.", "String.", "Bool.", "Nat.", "List.", "Maybe.",
    "Pair.", "Array.", "IO.", "Map.", "File.", "NativeHost.", "Either.",
    "Result.", "Sigma.", "Cmp.", "Word.", "Poll.", "Tool.", "Event.",
    "Image.", "App.", "Socket.", "Listener.", "Window.", "Audio.", "Chan.", "Base."
  ], name)

def b5k_chk_is_base_type(+name: String) -> Bool:
  b5k_chk_str_in([
    "Empty", "Unit", "Bool", "Cmp", "Either", "Sigma", "Pair", "Nat", "Maybe",
    "Result", "Poll", "List", "Word", "Word.Nil", "Word.Con", "U32", "F32",
    "Char", "String", "Array", "Image", "Tool", "Event", "Map", "IO", "IO.OP",
    "App", "File", "Socket", "Listener", "Window", "Audio", "Chan", "Type", "Data", "Kind", "Set"
  ], name)

def b5k_chk_is_base_name(+name: String) -> Bool:
  Bool.or(b5k_chk_is_base_prefix(name),
    Bool.or(b5k_chk_is_base_type(name), b5k_chk_str_in(["fst", "snd", "pair", "absurd", "id"], name)))

def b5k_chk_base_ctor_step(hit: Bool, info: CtorInfo, rest_res: Maybe<&2, CtorInfo>) -> Maybe<&2, CtorInfo>:
  match hit:
    case True{}: Some{info}
    case False{}: rest_res

def b5k_chk_base_ctor_go(xs: List<&2, CtorEntry>, +name: String) -> Maybe<&2, CtorInfo>:
  match xs:
    case Nil{}: None{}
    case Con{CtorEntry{k, info}, t}: b5k_chk_base_ctor_step(String.eq(k, name), info, b5k_chk_base_ctor_go(t, name))

def b5k_chk_base_ctor(name: String) -> Maybe<&2, CtorInfo>:
  b5k_chk_base_ctor_go([
    CtorEntry{"Unit", CtorInfo{"Unit", 0}}, CtorEntry{"False", CtorInfo{"Bool", 0}},
    CtorEntry{"True", CtorInfo{"Bool", 0}}, CtorEntry{"LT", CtorInfo{"Cmp", 0}},
    CtorEntry{"EQ", CtorInfo{"Cmp", 0}}, CtorEntry{"GT", CtorInfo{"Cmp", 0}},
    CtorEntry{"Inl", CtorInfo{"Either", 1}}, CtorEntry{"Inr", CtorInfo{"Either", 1}},
    CtorEntry{"Tuple", CtorInfo{"Sigma", 2}}, CtorEntry{"Pair", CtorInfo{"Pair", 2}},
    CtorEntry{"Zero", CtorInfo{"Nat", 0}}, CtorEntry{"Succ", CtorInfo{"Nat", 1}},
    CtorEntry{"None", CtorInfo{"Maybe", 0}}, CtorEntry{"Some", CtorInfo{"Maybe", 1}},
    CtorEntry{"Fail", CtorInfo{"Result", 1}}, CtorEntry{"Done", CtorInfo{"Result", 1}},
    CtorEntry{"Ready", CtorInfo{"Poll", 1}}, CtorEntry{"Wait", CtorInfo{"Poll", 1}},
    CtorEntry{"Nil", CtorInfo{"List", 0}}, CtorEntry{"Con", CtorInfo{"List", 2}},
    CtorEntry{"WNil", CtorInfo{"Word.Nil", 0}}, CtorEntry{"WCon", CtorInfo{"Word.Con", 2}},
    CtorEntry{"U32", CtorInfo{"U32", 1}}, CtorEntry{"F32", CtorInfo{"F32", 1}},
    CtorEntry{"Chr", CtorInfo{"Char", 1}}, CtorEntry{"SNil", CtorInfo{"String", 0}},
    CtorEntry{"SCon", CtorInfo{"String", 2}}, CtorEntry{"ALeaf", CtorInfo{"Array", 1}},
    CtorEntry{"ANode", CtorInfo{"Array", 2}}, CtorEntry{"MTip", CtorInfo{"Map", 0}},
    CtorEntry{"MLeaf", CtorInfo{"Map", 2}}, CtorEntry{"MNode", CtorInfo{"Map", 3}},
    CtorEntry{"Emit", CtorInfo{"IO.OP", 1}}, CtorEntry{"Halt", CtorInfo{"IO.OP", 2}},
    CtorEntry{"Exit", CtorInfo{"IO.OP", 1}}, CtorEntry{"Pix", CtorInfo{"Image", 1}},
    CtorEntry{"Qua", CtorInfo{"Image", 4}}, CtorEntry{"App", CtorInfo{"App", 2}}
  ], name)

# Symbol, Type, Constructor, Def & Law Indexing
# ---------------------------------------------

def b5k_chk_index_ctors(+syms: SymTab, +tname: String, cs: List<&2, CtorDef>, cm: Map<&2, Maybe<&2, CtorInfo>>) -> Map<&2, Maybe<&2, CtorInfo>>:
  match cs:
    case Nil{}: cm
    case Con{CtorDef{csym, _, fields}, rest}:
      cname = symtab_name(syms, csym)
      arity = b5k_list_len(Param, fields)
      b5k_chk_index_ctors(syms, tname, rest, Map.set(&2, Maybe<&2, CtorInfo>, cm, cname, Some{CtorInfo{tname, arity}}))

def b5k_chk_index_types(+syms: SymTab, ts: List<&2, TypeDef>, tm: Map<&2, U32>) -> Map<&2, U32>:
  match ts:
    case Nil{}: tm
    case Con{TypeDef{tsym, _, _, _}, rest}:
      b5k_chk_index_types(syms, rest, Map.set(&2, U32, tm, symtab_name(syms, tsym), 1))

def b5k_chk_index_all_ctors(+syms: SymTab, ts: List<&2, TypeDef>, cm: Map<&2, Maybe<&2, CtorInfo>>) -> Map<&2, Maybe<&2, CtorInfo>>:
  match ts:
    case Nil{}: cm
    case Con{TypeDef{tsym, _, _, ctors}, rest}:
      b5k_chk_index_all_ctors(syms, rest, b5k_chk_index_ctors(syms, symtab_name(syms, tsym), ctors, cm))

def b5k_chk_count_live(ps: List<&2, Param>, acc: U32) -> U32:
  match ps:
    case Nil{}: acc
    case Con{Param{_, _, erased, _}, rest}:
      match erased:
        case True{}: b5k_chk_count_live(rest, acc)
        case False{}: b5k_chk_count_live(rest, U32.add(acc, 1))

def b5k_chk_ret_is_fn(ret: Maybe<&2, Expr>) -> Bool:
  match ret:
    case None{}: False{}
    case Some{EAll{_, _}}: True{}
    case Some{_}: False{}

def b5k_chk_index_defs(+syms: SymTab, ds: List<&2, Def>, dm: Map<&2, Maybe<&2, DefInfo>>) -> Map<&2, Maybe<&2, DefInfo>>:
  match ds:
    case Nil{}: dm
    case Con{Def{dsym, +params, ret, _, is_import, _}, rest}:
      b5k_chk_index_defs(syms, rest, Map.set(&2, Maybe<&2, DefInfo>, dm, symtab_name(syms, dsym),
        Some{DefInfo{b5k_chk_count_live(params, 0), b5k_list_len(Param, params), b5k_chk_ret_is_fn(ret), is_import}}))

def b5k_chk_index_laws(+syms: SymTab, ls: List<&2, LawDef>, lm: Map<&2, U32>) -> Map<&2, U32>:
  match ls:
    case Nil{}: lm
    case Con{LawDef{lsym, _, _}, rest}:
      b5k_chk_index_laws(syms, rest, Map.set(&2, U32, lm, symtab_name(syms, lsym), 1))

def b5k_chk_build_ctx(+types: List<&2, TypeDef>, defs: List<&2, Def>, laws: List<&2, LawDef>, +syms: SymTab) -> CheckCtx:
  tm = b5k_chk_index_types(syms, types, Map.new(&2, U32))
  cm = b5k_chk_index_all_ctors(syms, types, Map.new(&2, Maybe<&2, CtorInfo>))
  dm = b5k_chk_index_defs(syms, defs, Map.new(&2, Maybe<&2, DefInfo>))
  lm = b5k_chk_index_laws(syms, laws, Map.new(&2, U32))
  CheckCtx{syms, tm, cm, dm, lm}

# Context Lookup Helpers
# ----------------------

def b5k_chk_sym_name(ctx: CheckCtx, sym: U32) -> String:
  match ctx:
    case CheckCtx{syms, _, _, _, _}: symtab_name(syms, sym)

def b5k_chk_map_has_u32(m: Map<&2, U32>, key: String) -> Bool:
  Bool.not(U32.is_zero(b5k_chk_snd(Map<&2, U32>, U32, Map.get(U32, 0, m, key))))

def b5k_chk_lookup_ctor_fin(res: Maybe<&2, CtorInfo>, name: String) -> Maybe<&2, CtorInfo>:
  match res:
    case Some{info}: Some{info}
    case None{}: b5k_chk_base_ctor(name)

def b5k_chk_lookup_ctor(ctx: CheckCtx, +name: String) -> Maybe<&2, CtorInfo>:
  match ctx:
    case CheckCtx{_, _, ctors, _, _}:
      res = b5k_chk_snd(Map<&2, Maybe<&2, CtorInfo>>, Maybe<&2, CtorInfo>, Map.get(Maybe<&2, CtorInfo>, None{}, ctors, name))
      b5k_chk_lookup_ctor_fin(res, name)

def b5k_chk_lookup_def(ctx: CheckCtx, name: String) -> Maybe<&2, DefInfo>:
  match ctx:
    case CheckCtx{_, _, _, defs, _}:
      b5k_chk_snd(Map<&2, Maybe<&2, DefInfo>>, Maybe<&2, DefInfo>, Map.get(Maybe<&2, DefInfo>, None{}, defs, name))

def b5k_chk_is_some(-A: Data, m: Maybe<&2, A>) -> Bool:
  match m:
    case Some{_}: True{}
    case None{}: False{}

def b5k_chk_is_known_type(ctx: CheckCtx, +name: String) -> Bool:
  match ctx:
    case CheckCtx{_, types, _, _, _}:
      Bool.or(b5k_chk_map_has_u32(types, name), b5k_chk_is_base_type(name))

def b5k_chk_is_known_global(+ctx: CheckCtx, +name: String) -> Bool:
  match ctx:
    case CheckCtx{_, types, _, _, laws}:
      Bool.or(b5k_chk_is_base_name(name),
        Bool.or(b5k_chk_map_has_u32(types, name),
          Bool.or(b5k_chk_map_has_u32(laws, name),
            Bool.or(b5k_chk_is_some(DefInfo, b5k_chk_lookup_def(ctx, name)),
              b5k_chk_is_some(CtorInfo, b5k_chk_lookup_ctor(ctx, name))))))

# Local Environment & Affine Use-Set Algebra
# ------------------------------------------

def b5k_chk_env_step(hit: Bool, dup: Bool, rest_res: LookupRes) -> LookupRes:
  match hit dup:
    case True{} True{}: LFoundDup{}
    case True{} False{}: LFoundLin{}
    case False{} _: rest_res

def b5k_chk_env_lookup(env: List<&2, VarBind>, +sym: U32) -> LookupRes:
  match env:
    case Nil{}: LNotFound{}
    case Con{VarBind{s, dup}, rest}: b5k_chk_env_step(U32.is_eq(s, sym), dup, b5k_chk_env_lookup(rest, sym))

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

def b5k_chk_uses_branch_step(seen: Bool, h: U32, rest_res: List<&2, U32>) -> List<&2, U32>:
  match seen:
    case True{}: rest_res
    case False{}: Con{h, rest_res}

def b5k_chk_uses_branch(u1: List<&2, U32>, +u2: List<&2, U32>) -> List<&2, U32>:
  match u1:
    case Nil{}: u2
    case Con{+h, t}: b5k_chk_uses_branch_step(b5k_chk_u32_mem(u2, h), h, b5k_chk_uses_branch(t, u2))

def b5k_chk_binds_mem(bs: List<&2, VarBind>, +sym: U32) -> Bool:
  match bs:
    case Nil{}: False{}
    case Con{VarBind{s, _}, t}: Bool.or(U32.is_eq(s, sym), b5k_chk_binds_mem(t, sym))

def b5k_chk_uses_strip_step(bound: Bool, h: U32, rest_res: List<&2, U32>) -> List<&2, U32>:
  match bound:
    case True{}: rest_res
    case False{}: Con{h, rest_res}

def b5k_chk_uses_strip(+bs: List<&2, VarBind>, us: List<&2, U32>) -> List<&2, U32>:
  match us:
    case Nil{}: Nil{}
    case Con{+h, t}: b5k_chk_uses_strip_step(b5k_chk_binds_mem(bs, h), h, b5k_chk_uses_strip(bs, t))

def b5k_chk_params_binds(ps: List<&2, Param>) -> List<&2, VarBind>:
  match ps:
    case Nil{}: Nil{}
    case Con{Param{sym, _, erased, dup}, rest}:
      Con{VarBind{sym, Bool.or(erased, dup)}, b5k_chk_params_binds(rest)}

# Pattern Checking & Binding Extraction
# -------------------------------------

def b5k_chk_ctor_err(fn_name: String) -> String:
  "check: " ++ fn_name ++ ": constructor does not belong to goal or field count differs"

def b5k_chk_ctor_ok_goal(eq_arity: Bool, tname: String, goal: Maybe<&2, String>) -> Bool:
  match eq_arity goal:
    case False{} _: False{}
    case True{} None{}: True{}
    case True{} Some{g}: String.eq(tname, g)

def b5k_chk_ctor_ok(info: Maybe<&2, CtorInfo>, nargs: U32, goal: Maybe<&2, String>) -> Bool:
  match info:
    case None{}: False{}
    case Some{CtorInfo{tname, arity}}: b5k_chk_ctor_ok_goal(U32.is_eq(nargs, arity), tname, goal)

def b5k_chk_pat_guard(ok: Bool, fn_name: String, res: PatRes) -> PatRes:
  match ok:
    case False{}: PatErr{b5k_chk_ctor_err(fn_name)}
    case True{}: res

def b5k_chk_pats(fuel: Nat, +ctx: CheckCtx, +fn_name: String, ps: List<&2, Pat>, acc: List<&2, VarBind>) -> PatRes:
  match fuel ps:
    case 0n _: PatOk{acc}
    case _ Nil{}: PatOk{acc}
    case 1n+f Con{PVar{sym, dup}, rest}: b5k_chk_pats(f, ctx, fn_name, rest, Con{VarBind{sym, dup}, acc})
    case 1n+f Con{PWild{}, rest}: b5k_chk_pats(f, ctx, fn_name, rest, acc)
    case 1n+f Con{PNum{_}, rest}: b5k_chk_pats(f, ctx, fn_name, rest, acc)
    case 1n+f Con{PChr{_}, rest}: b5k_chk_pats(f, ctx, fn_name, rest, acc)
    case 1n+f Con{PCtr{sym, +fields}, rest}:
      ok = b5k_chk_ctor_ok(b5k_chk_lookup_ctor(ctx, b5k_chk_sym_name(ctx, sym)), b5k_list_len(Pat, fields), None{})
      b5k_chk_pat_guard(ok, fn_name, b5k_chk_pats(f, ctx, fn_name, b5k_list_app(Pat, fields, rest), acc))
    case 1n+f Con{PPair{fst, snd}, rest}: b5k_chk_pats(f, ctx, fn_name, Con{fst, Con{snd, rest}}, acc)
    case 1n+f Con{PList{elems}, rest}: b5k_chk_pats(f, ctx, fn_name, b5k_list_app(Pat, elems, rest), acc)

# Goal Extraction & Direct Call Arity Check
# -----------------------------------------

def b5k_chk_goal_if(known: Bool, name: String) -> Maybe<&2, String>:
  match known:
    case True{}: Some{name}
    case False{}: None{}

def b5k_chk_goal_sym(+ctx: CheckCtx, sym: U32) -> Maybe<&2, String>:
  +name = b5k_chk_sym_name(ctx, sym)
  b5k_chk_goal_if(b5k_chk_is_known_type(ctx, name), name)

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

def b5k_chk_call_err_if(bad: Bool, fn_name: String, callee: String) -> String:
  match bad:
    case True{}: "check: " ++ fn_name ++ ": call arity mismatch for " ++ callee
    case False{}: ""

def b5k_chk_call_def(info: Maybe<&2, DefInfo>, fn_name: String, callee: String, +nargs: U32) -> String:
  match info:
    case None{}: ""
    case Some{DefInfo{arity, total_arity, ret_fn, _}}:
      over = Bool.and(U32.is_gt(nargs, total_arity), Bool.not(ret_fn))
      zero_bad = Bool.and(U32.is_zero(nargs), Bool.not(U32.is_zero(arity)))
      b5k_chk_call_err_if(Bool.or(over, zero_bad), fn_name, callee)

def b5k_chk_call_lookup(lr: LookupRes, +ctx: CheckCtx, fn_name: String, sym: U32, nargs: U32) -> String:
  match lr:
    case LFoundDup{}: ""
    case LFoundLin{}: ""
    case LNotFound{}:
      +callee = b5k_chk_sym_name(ctx, sym)
      b5k_chk_call_def(b5k_chk_lookup_def(ctx, callee), fn_name, callee, nargs)

def b5k_chk_call_arity(+ctx: CheckCtx, fn_name: String, env: List<&2, VarBind>, fun: Expr, nargs: U32) -> String:
  match fun:
    case EVar{+sym}: b5k_chk_call_lookup(b5k_chk_env_lookup(env, sym), ctx, fn_name, sym, nargs)
    case ERef{+sym}: b5k_chk_call_lookup(b5k_chk_env_lookup(env, sym), ctx, fn_name, sym, nargs)
    case _: ""

# Expression Checker (Scope + Ctor/Goal + Arity + Affine)
# -------------------------------------------------------

def b5k_chk_var_global(known: Bool, is_ref: Bool, fn_name: String, name: String) -> ExprRes:
  match known is_ref:
    case True{} _: ExprOk{Nil{}}
    case False{} True{}: ExprErr{"check: " ++ fn_name ++ ": unbound reference: " ++ name}
    case False{} False{}: ExprErr{"check: " ++ fn_name ++ ": unbound variable: " ++ name}

def b5k_chk_var_lookup(lr: LookupRes, +ctx: CheckCtx, fn_name: String, sym: U32, is_ref: Bool) -> ExprRes:
  match lr:
    case LFoundDup{}: ExprOk{Nil{}}
    case LFoundLin{}: ExprOk{Con{sym, Nil{}}}
    case LNotFound{}:
      +name = b5k_chk_sym_name(ctx, sym)
      b5k_chk_var_global(b5k_chk_is_known_global(ctx, name), is_ref, fn_name, name)

def b5k_chk_var(+ctx: CheckCtx, fn_name: String, env: List<&2, VarBind>, +sym: U32, is_ref: Bool) -> ExprRes:
  b5k_chk_var_lookup(b5k_chk_env_lookup(env, sym), ctx, fn_name, sym, is_ref)

def b5k_chk_pair_fin(fn_name: String, r1: ExprRes, r2: ExprRes) -> ExprRes:
  match r1 r2:
    case ExprErr{err} _: ExprErr{err}
    case ExprOk{_} ExprErr{err}: ExprErr{err}
    case ExprOk{u1} ExprOk{u2}: b5k_chk_uses_sum(fn_name, u1, u2)

def b5k_chk_branch_fin(r1: ExprRes, r2: ExprRes) -> ExprRes:
  match r1 r2:
    case ExprErr{err} _: ExprErr{err}
    case ExprOk{_} ExprErr{err}: ExprErr{err}
    case ExprOk{u1} ExprOk{u2}: ExprOk{b5k_chk_uses_branch(u1, u2)}

def b5k_chk_strip_res(bs: List<&2, VarBind>, r: ExprRes) -> ExprRes:
  match r:
    case ExprErr{err}: ExprErr{err}
    case ExprOk{u}: ExprOk{b5k_chk_uses_strip(bs, u)}

def b5k_chk_guard_err(ok: Bool, err: String, res: ExprRes) -> ExprRes:
  match ok:
    case False{}: ExprErr{err}
    case True{}: res

def b5k_chk_lit_ok(goal: Maybe<&2, String>, +got: String, is_num: Bool) -> Bool:
  match goal:
    case None{}: True{}
    case Some{+g}:
      Bool.or(b5k_str_eq(g, got), Bool.and(is_num, b5k_str_eq(g, "Nat")))

def b5k_chk_lit(goal: Maybe<&2, String>, fn_name: String, +got: String, is_num: Bool) -> ExprRes:
  b5k_chk_guard_err(b5k_chk_lit_ok(goal, got, is_num), "check: " ++ fn_name ++ ": literal type mismatch (" ++ got ++ ")", ExprOk{Nil{}})

def b5k_chk_work(+fuel: Nat, +ctx: CheckCtx, +fn_name: String, w: ChkWork) -> ExprRes:
  match fuel w:
    case 0n _: ExprOk{Nil{}}
    case 1n+f WExprs{_, Nil{}}: ExprOk{Nil{}}
    case 1n+f WExprs{+env, Con{h, t}}:
      b5k_chk_pair_fin(fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, h}), b5k_chk_work(f, ctx, fn_name, WExprs{env, t}))
    case 1n+f WCases{_, _, Nil{}}: ExprOk{Nil{}}
    case 1n+f WCases{+env, +goal, Con{Case{pats, body}, rest}}:
      pr = b5k_chk_pats(U32.to_nat(256), ctx, fn_name, pats, Nil{})
      b5k_chk_branch_fin(b5k_chk_work(f, ctx, fn_name, WCasePat{env, goal, pr, body}), b5k_chk_work(f, ctx, fn_name, WCases{env, goal, rest}))
    case 1n+f WCasePat{_, _, PatErr{err}, _}: ExprErr{err}
    case 1n+f WCasePat{env, goal, PatOk{+bs}, body}:
      b5k_chk_strip_res(bs, b5k_chk_work(f, ctx, fn_name, WExpr{b5k_list_app(VarBind, bs, env), goal, body}))
    case 1n+f WLetPat{_, _, PatErr{err}, _, _}: ExprErr{err}
    case 1n+f WLetPat{+env, goal, PatOk{+bs}, val, body}:
      r1 = b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, val})
      r2 = b5k_chk_strip_res(bs, b5k_chk_work(f, ctx, fn_name, WExpr{b5k_list_app(VarBind, bs, env), goal, body}))
      b5k_chk_pair_fin(fn_name, r1, r2)
    case 1n+f WStmtPat{_, _, PatErr{err}, _, _}: ExprErr{err}
    case 1n+f WStmtPat{+env, goal, PatOk{+bs}, val, rest}:
      r1 = b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, val})
      r2 = b5k_chk_strip_res(bs, b5k_chk_work(f, ctx, fn_name, WStmts{b5k_list_app(VarBind, bs, env), goal, rest}))
      b5k_chk_pair_fin(fn_name, r1, r2)
    case 1n+f WStmts{_, _, Nil{}}: ExprOk{Nil{}}
    case 1n+f WStmts{env, goal, Con{StBind{pat, val}, rest}}:
      b5k_chk_work(f, ctx, fn_name, WStmtPat{env, goal, b5k_chk_pats(U32.to_nat(256), ctx, fn_name, [pat], Nil{}), val, rest})
    case 1n+f WStmts{env, goal, Con{StLet{pat, val}, rest}}:
      b5k_chk_work(f, ctx, fn_name, WStmtPat{env, goal, b5k_chk_pats(U32.to_nat(256), ctx, fn_name, [pat], Nil{}), val, rest})
    case 1n+f WStmts{env, goal, Con{StExpr{val}, Nil{}}}:
      b5k_chk_work(f, ctx, fn_name, WExpr{env, goal, val})
    case 1n+f WStmts{+env, goal, Con{StExpr{val}, rest}}:
      b5k_chk_pair_fin(fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, val}), b5k_chk_work(f, ctx, fn_name, WStmts{env, goal, rest}))
    case 1n+f WStmts{env, goal, Con{StRet{val}, Nil{}}}:
      b5k_chk_work(f, ctx, fn_name, WExpr{env, goal, val})
    case 1n+f WStmts{+env, goal, Con{StRet{val}, rest}}:
      b5k_chk_pair_fin(fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, val}), b5k_chk_work(f, ctx, fn_name, WStmts{env, goal, rest}))
    case 1n+f WExpr{_, goal, ENum{_}}: b5k_chk_lit(goal, fn_name, "U32", True{})
    case 1n+f WExpr{_, goal, EFlt{_}}: b5k_chk_lit(goal, fn_name, "F32", False{})
    case 1n+f WExpr{_, goal, EChr{_}}: b5k_chk_lit(goal, fn_name, "Char", False{})
    case 1n+f WExpr{_, goal, EStr{_}}: b5k_chk_lit(goal, fn_name, "String", False{})
    case 1n+f WExpr{_, _, ESet{}}: ExprOk{Nil{}}
    case 1n+f WExpr{_, _, EEmpty{}}: ExprOk{Nil{}}
    case 1n+f WExpr{_, _, EUnit{}}: ExprOk{Nil{}}
    case 1n+f WExpr{_, _, ERefl{}}: ExprOk{Nil{}}
    case 1n+f WExpr{_, _, EHole{}}: ExprOk{Nil{}}
    case 1n+f WExpr{_, _, EAll{_, _}}: ExprOk{Nil{}}
    case 1n+f WExpr{env, _, EVar{sym}}: b5k_chk_var(ctx, fn_name, env, sym, False{})
    case 1n+f WExpr{env, _, ERef{sym}}: b5k_chk_var(ctx, fn_name, env, sym, True{})
    case 1n+f WExpr{+env, _, EApp{+fun, +args}}:
      +aerr = b5k_chk_call_arity(ctx, fn_name, env, fun, b5k_list_len(Expr, args))
      res = b5k_chk_pair_fin(fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, fun}), b5k_chk_work(f, ctx, fn_name, WExprs{env, args}))
      b5k_chk_guard_err(String.is_empty(aerr), aerr, res)
    case 1n+f WExpr{env, _, ELam{params, body}}:
      +bs = b5k_chk_params_binds(params)
      b5k_chk_strip_res(bs, b5k_chk_work(f, ctx, fn_name, WExpr{b5k_list_app(VarBind, bs, env), None{}, body}))
    case 1n+f WExpr{env, goal, ELet{pat, val, body}}:
      b5k_chk_work(f, ctx, fn_name, WLetPat{env, goal, b5k_chk_pats(U32.to_nat(256), ctx, fn_name, [pat], Nil{}), val, body})
    case 1n+f WExpr{+env, goal, EMat{scruts, cases}}:
      b5k_chk_pair_fin(fn_name, b5k_chk_work(f, ctx, fn_name, WExprs{env, scruts}), b5k_chk_work(f, ctx, fn_name, WCases{env, goal, cases}))
    case 1n+f WExpr{env, goal, ECtr{sym, +fields}}:
      ok = b5k_chk_ctor_ok(b5k_chk_lookup_ctor(ctx, b5k_chk_sym_name(ctx, sym)), b5k_list_len(Expr, fields), goal)
      b5k_chk_guard_err(ok, b5k_chk_ctor_err(fn_name), b5k_chk_work(f, ctx, fn_name, WExprs{env, fields}))
    case 1n+f WExpr{env, _, EAnn{val, typ}}:
      b5k_chk_work(f, ctx, fn_name, WExpr{env, b5k_chk_goal_expr(ctx, typ), val})
    case 1n+f WExpr{+env, _, EEq{lhs, rhs}}:
      b5k_chk_pair_fin(fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, lhs}), b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, rhs}))
    case 1n+f WExpr{+env, _, EOp{_, lhs, rhs}}:
      b5k_chk_pair_fin(fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, lhs}), b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, rhs}))
    case 1n+f WExpr{env, _, EUnOp{_, val}}:
      b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, val})
    case 1n+f WExpr{env, _, EArrNew{elems}}:
      b5k_chk_work(f, ctx, fn_name, WExprs{env, elems})
    case 1n+f WExpr{+env, _, EArrGet{arr, idx}}:
      b5k_chk_pair_fin(fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, arr}), b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, idx}))
    case 1n+f WExpr{+env, _, EArrSet{arr, idx, val}}:
      r12 = b5k_chk_pair_fin(fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, arr}), b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, idx}))
      b5k_chk_pair_fin(fn_name, r12, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, val}))
    case 1n+f WExpr{+env, +goal, EIf{cond, then_e, else_e}}:
      rc = b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, cond})
      rb = b5k_chk_branch_fin(b5k_chk_work(f, ctx, fn_name, WExpr{env, goal, then_e}), b5k_chk_work(f, ctx, fn_name, WExpr{env, goal, else_e}))
      b5k_chk_pair_fin(fn_name, rc, rb)
    case 1n+f WExpr{env, goal, EDo{stmts}}:
      b5k_chk_work(f, ctx, fn_name, WStmts{env, goal, stmts})
    case 1n+f WExpr{+env, _, EPair{fst, snd}}:
      b5k_chk_pair_fin(fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, fst}), b5k_chk_work(f, ctx, fn_name, WExpr{env, None{}, snd}))
    case 1n+f WExpr{env, _, EList{elems}}:
      b5k_chk_work(f, ctx, fn_name, WExprs{env, elems})

# Top-Level Book Entrypoint
# -------------------------

def b5k_chk_expr_err(r: ExprRes) -> String:
  match r:
    case ExprOk{_}: ""
    case ExprErr{err}: err

def b5k_chk_import_err(ok: Bool, path: String) -> String:
  match ok:
    case True{}: ""
    case False{}: "compile: foreign provider unavailable in fixed runtime: " ++ path

def b5k_chk_def(+ctx: CheckCtx, d: Def) -> String:
  match d:
    case Def{sym, params, ret, body, is_import, +import_path}:
      match is_import:
        case True{}: b5k_chk_import_err(b5k_chk_is_runtime_provider(import_path), import_path)
        case False{}:
          fn_name = b5k_chk_sym_name(ctx, sym)
          env = b5k_chk_params_binds(params)
          goal = b5k_chk_goal_opt(ctx, ret)
          b5k_chk_expr_err(b5k_chk_work(U32.to_nat(4096), ctx, fn_name, WExpr{env, goal, body}))

def b5k_chk_defs_step(ok: Bool, err: String, rest_err: String) -> String:
  match ok:
    case True{}: rest_err
    case False{}: err

def b5k_chk_defs(+ctx: CheckCtx, ds: List<&2, Def>) -> String:
  match ds:
    case Nil{}: ""
    case Con{h, t}:
      +err = b5k_chk_def(ctx, h)
      b5k_chk_defs_step(String.is_empty(err), err, b5k_chk_defs(ctx, t))

def b5k_chk_fin(ok: Bool, err: String, book: Book) -> CheckRes:
  match ok:
    case True{}: CheckRes{True{}, "", book}
    case False{}: CheckRes{False{}, err, book}

def b5k_check(+book: Book) -> CheckRes:
  match book:
    case Book{types, +defs, laws, syms}:
      ctx = b5k_chk_build_ctx(types, defs, laws, syms)
      +err = b5k_chk_defs(ctx, defs)
      b5k_chk_fin(String.is_empty(err), err, book)
