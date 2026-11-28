# bend5k/check.bend — 1-Pass Type, Scope, Constructor, Foreign & Affine Checker
type ChkTy is Data:
  TAny{}
  TErased{}
  TNonUniv{}
  TFam{head: U32, arg: Expr}
  TFam2{head: U32, a1: Expr, a2: Expr}
  TTyVar{sym: U32}
  TCon{head: String, args: List<&2, ChkTy>}
  TFun{pdup: Bool, per: Bool, arg: ChkTy, ret: ChkTy}
  TEq{lhs: Expr, rhs: Expr, car: ChkTy, strict: Bool}
type ChkPair<-A: Data, -B: Data> is Data:
  CP{a: A, b: B}
type TyPair is Data:
  TyPair{a: ChkTy, b: ChkTy}
type TyWork is Data:
  TWOne{e: Expr}
  TWMany{es: List<&2, Expr>}
type TyRes is Data:
  TROne{t: ChkTy}
  TRMany{ts: List<&2, ChkTy>}
type TyShow is Data:
  TSOne{t: ChkTy}
  TSSep{s: String}
type CheckRes is Data:
  CheckRes{ok: Bool, err: String, book: Book}
type CtorInfo is Data:
  CtorInfo{
    type_name: String, arity: U32,
    fdups: List<&2, Bool>, fers: List<&2, Bool>, ftys: List<&2, ChkTy>
  }
type CtorEntry is Data:
  CtorEntry{name: String, tname: String, arity: U32}
type DefInfo is Data:
  DefInfo{
    arity: U32, total_arity: U32, n_comp: U32, ret_arrows: U32,
    is_import: Bool, def_idx: U32, param_tys: List<&2, ChkTy>,
    live_tys: List<&2, ChkTy>, param_ers: List<&2, Bool>, ret_ty: ChkTy
  }
type CallSig is Data:
  CallSig{arg_tys: List<&2, ChkTy>, arg_ers: List<&2, Bool>, ret_ty: ChkTy}
def ct_set(-A: Data, t: RaVec<Maybe<&2, A>>, +k: U32, v: A) -> RaVec<Maybe<&2, A>>:
  ra_vec_set(Maybe<&2, A>, 8n, k, Some{v}, t)
def ct_get(-A: Data, t: RaVec<Maybe<&2, A>>, +k: U32) -> Maybe<&2, A>:
  ra_vec_get(Maybe<&2, A>, 8n, None{}, k, t)
type CheckCtx is Data:
  CheckCtx{
    syms: SymTab, types: RaVec<Maybe<&2, U32>>, ctors: RaVec<Maybe<&2, CtorInfo>>,
    defs: RaVec<Maybe<&2, DefInfo>>, laws: RaVec<Maybe<&2, LawDef>>,
    dasts: RaVec<Maybe<&2, Def>>, tdefs: List<&2, TypeDef>
  }
type VarBind is Data:
  VarBind{sym: U32, dup: Bool, erased: Bool, is_local: Bool, is_comp: Bool, typ: ChkTy}
type PatItem is Data:
  PatItem{pat: Pat, dup_inh: Bool, typ_inh: ChkTy}
type LookupRes is Data:
  LNotFound{}
  LFound{dup: Bool, erased: Bool, is_local: Bool, typ: ChkTy}
type PatRes is Data:
  PatOk{binds: List<&2, VarBind>}
  PatErr{err: String}
type ExprRes is Data:
  ExprOk{uses: List<&2, U32>}
  ExprErr{err: String}
type ChkWork is Data:
  WExpr{env: List<&2, VarBind>, goal: ChkTy, e: Expr}
  WArgs{env: List<&2, VarBind>, goals: List<&2, ChkTy>, ers: List<&2, Bool>, ncomp: U32, es: List<&2, Expr>}
  WCases{
    env: List<&2, VarBind>, goal: ChkTy, sdups: List<&2, Bool>,
    stys: List<&2, ChkTy>, ssyms: List<&2, U32>, cs: List<&2, Case>
  }
  WCasePat{env: List<&2, VarBind>, goal: ChkTy, pr: PatRes, wstrip: List<&2, VarBind>, body: Expr}
  WStmts{env: List<&2, VarBind>, goal: ChkTy, ss: List<&2, Stmt>}
  WStmtPat{env: List<&2, VarBind>, goal: ChkTy, pr: PatRes, val: Expr, rest: List<&2, Stmt>}
  WGuard{err: String, w: ChkWork}
  WExpect{got: ChkTy, goal: ChkTy, w: ChkWork}
  WAppGo{env: List<&2, VarBind>, goal: ChkTy, fun: Expr, args: List<&2, Expr>, nargs: U32, nt: U32}
  WLamGo{env: List<&2, VarBind>, goal: ChkTy, params: List<&2, Param>, body: Expr}
  WMatGo{env: List<&2, VarBind>, goal: ChkTy, scruts: List<&2, Expr>, stys: List<&2, ChkTy>, cases: List<&2, Case>}

# Fixed Runtime Allowlist & Built-in Base Tables
def b5k_chk_str_match_go(xs: List<&2, String>, hit: Bool, +is_pre: Bool, +s: String) -> Bool:
  match xs hit is_pre:
    case _ True{} _: True{}
    case Nil{} False{} _: False{}
    case Con{h, t} False{} True{}: b5k_chk_str_match_go(t, String.starts_with(s, h), True{}, s)
    case Con{h, t} False{} False{}: b5k_chk_str_match_go(t, String.eq(h, s), False{}, s)
def b5k_chk_str_match(+is_pre: Bool, xs: List<&2, String>, +s: String) -> Bool:
  b5k_chk_str_match_go(xs, False{}, is_pre, s)
def b5k_chk_is_universe(+name: String) -> Bool:
  Bool.or(
    String.eq(name, "Type"),
    Bool.or(String.eq(name, "Data"),
      Bool.or(String.eq(name, "Kind"), Bool.or(String.eq(name, "Set"), String.eq(name, "Quant"))))
  )
def b5k_chk_is_base_name(+name: String) -> Bool:
  Bool.or(
    b5k_chk_str_match(True{}, [
      "U32.", "F32.", "Char.", "String.", "Bool.", "Nat.", "List.", "Maybe.", "Pair.",
      "Array.", "IO.", "Map.", "File.", "NativeHost.", "Either.", "Result.", "Sigma.",
      "Cmp.", "Word.", "Poll.", "Tool.", "Event.", "Image.", "App.", "Socket.", "Listener",
      "Window", "Audio", "Chan", "Set.", "Base.", "Equal.", "Empty.", "Quant.", "TCP.",
      "UDP.", "Process."
    ], name),
    b5k_chk_str_match(False{}, ["fst", "snd", "pair", "absurd", "id"], name)
  )
def b5k_chk_base_ctors() -> List<&2, CtorEntry>:
  [
    CtorEntry{"Unit", "Unit", 0}, CtorEntry{"False", "Bool", 0}, CtorEntry{"True", "Bool", 0},
    CtorEntry{"LT", "Cmp", 0}, CtorEntry{"EQ", "Cmp", 0}, CtorEntry{"GT", "Cmp", 0},
    CtorEntry{"Inl", "Either", 1}, CtorEntry{"Inr", "Either", 1}, CtorEntry{"Tuple", "Sigma", 2},
    CtorEntry{"Pair", "Pair", 2}, CtorEntry{"Zero", "Nat", 0}, CtorEntry{"Succ", "Nat", 1},
    CtorEntry{"None", "Maybe", 0}, CtorEntry{"Some", "Maybe", 1}, CtorEntry{"Fail", "Result", 1},
    CtorEntry{"Done", "Result", 1}, CtorEntry{"Ready", "Poll", 1}, CtorEntry{"Wait", "Poll", 1},
    CtorEntry{"Nil", "List", 0}, CtorEntry{"Con", "List", 2}, CtorEntry{"WNil", "Word.Nil", 0},
    CtorEntry{"WCon", "Word.Con", 2}, CtorEntry{"U32", "U32", 1}, CtorEntry{"F32", "F32", 1},
    CtorEntry{"Chr", "Char", 1}, CtorEntry{"SNil", "String", 0}, CtorEntry{"SCon", "String", 2},
    CtorEntry{"ALeaf", "Array", 1}, CtorEntry{"ANode", "Array", 2}, CtorEntry{"MTip", "Map", 0},
    CtorEntry{"MLeaf", "Map", 2}, CtorEntry{"MNode", "Map", 3}, CtorEntry{"Emit", "IO.OP", 1},
    CtorEntry{"Halt", "IO.OP", 2}, CtorEntry{"Exit", "IO.OP", 1}, CtorEntry{"Pix", "Image", 1},
    CtorEntry{"Qua", "Image", 4}, CtorEntry{"App", "App", 2}, CtorEntry{"Key", "Event", 2},
    CtorEntry{"Text", "Event", 1}, CtorEntry{"Press", "Event", 7}, CtorEntry{"Move", "Event", 5},
    CtorEntry{"Leave", "Event", 1}, CtorEntry{"Lost", "Event", 1}, CtorEntry{"Look", "Event", 2},
    CtorEntry{"Scroll", "Event", 4}, CtorEntry{"Focus", "Event", 1}, CtorEntry{"Close", "Event", 0},
    CtorEntry{"Tool.Mouse", "Tool", 0}, CtorEntry{"Tool.Finger", "Tool", 3},
    CtorEntry{"Tool.Pen", "Tool", 5}
  ]

# Built-in Base Function Type Signatures (Zero-Alloc Tag + Lazy CallSig)
def b5k_chk_t0(nm: String) -> ChkTy: TCon{nm, Nil{}}
def b5k_chk_sig1(+a: String, +r: String) -> CallSig: CallSig{[b5k_chk_t0(a)], Nil{}, b5k_chk_t0(r)}
def b5k_chk_sig2(+a: String, +b: String, +r: String) -> CallSig:
  CallSig{[b5k_chk_t0(a), b5k_chk_t0(b)], Nil{}, b5k_chk_t0(r)}
def b5k_chk_sig_none() -> CallSig: CallSig{Nil{}, Nil{}, TAny{}}
def b5k_chk_tname(id: U32) -> String:
  match id:
    case 0: "U32"
    case 1: "Bool"
    case 2: "Nat"
    case 3: "F32"
    case 4: "String"
    case 5: "Char"
    case _: "Cmp"
def b5k_chk_sig_of(+tag: U32) -> CallSig:
  match tag:
    case 0: b5k_chk_sig_none()
    case 128: CallSig{[TAny{}, b5k_chk_t0("Bool"), TAny{}, TAny{}], [True{}, False{}, False{}, False{}], TAny{}}
    case 129: b5k_chk_sig2("U32", "Nat", "U32")
    case 130: b5k_chk_sig2("U32", "Char", "String")
    case t:
      +is2 = U32.is_ge(t, 64)
      +k = Bool.pick(U32, is2, U32.sub(t, 64), U32.sub(t, 1))
      +ta = b5k_chk_tname(U32.shrn(k, 3n))
      +tr = b5k_chk_tname(U32.and(k, 7))
      Bool.pick(CallSig, is2, b5k_chk_sig2(ta, ta, tr), b5k_chk_sig1(ta, tr))
def b5k_chk_builtin_tag(+nm: String, nargs: U32) -> U32:
  match nm nargs:
    case SCon{Chr{85}, _} 1:
      is_u = Bool.or(String.eq(nm, "U32.inc"),
        Bool.or(String.eq(nm, "U32.not"), Bool.or(String.eq(nm, "U32.shl"), String.eq(nm, "U32.shr"))))
      is_n = Bool.or(String.eq(nm, "U32.to_nat"),
        Bool.or(String.eq(nm, "U32.log2"), Bool.or(String.eq(nm, "U32.popcount"), String.eq(nm, "U32.ctz"))))
      r5 = Bool.pick(U32, Bool.or(String.eq(nm, "U32.show"), String.eq(nm, "U32.hex")), 5, 0)
      r4 = Bool.pick(U32, String.eq(nm, "U32.to_f32"), 4, r5)
      r3 = Bool.pick(U32, String.eq(nm, "U32.from_nat"), 17, r4)
      r2 = Bool.pick(U32, is_n, 3, r3)
      r1 = Bool.pick(U32, String.starts_with(nm, "U32.is_"), 2, r2)
      Bool.pick(U32, is_u, 1, r1)
    case SCon{Chr{85}, _} 2:
      ar1 = Bool.or(String.eq(nm, "U32.add"),
        Bool.or(String.eq(nm, "U32.sub"),
          Bool.or(String.eq(nm, "U32.mul"), Bool.or(String.eq(nm, "U32.div"), String.eq(nm, "U32.mod")))))
      ar2 = Bool.or(String.eq(nm, "U32.and"),
        Bool.or(String.eq(nm, "U32.or"),
          Bool.or(String.eq(nm, "U32.xor"), Bool.or(String.eq(nm, "U32.min"), String.eq(nm, "U32.max")))))
      is_sh = Bool.or(String.eq(nm, "U32.shln"), Bool.or(String.eq(nm, "U32.shrn"), String.eq(nm, "U32.pow")))
      r3 = Bool.pick(U32, String.eq(nm, "U32.cmp"), 70, 0)
      r2 = Bool.pick(U32, is_sh, 129, r3)
      r1 = Bool.pick(U32, String.starts_with(nm, "U32.is_"), 65, r2)
      Bool.pick(U32, Bool.or(ar1, ar2), 64, r1)
    case SCon{Chr{66}, _} 1:
      Bool.pick(U32, String.eq(nm, "Bool.not"), 10, Bool.pick(U32, String.eq(nm, "Bool.to_u32"), 9, 0))
    case SCon{Chr{66}, _} 2:
      is_b = Bool.or(String.eq(nm, "Bool.and"), Bool.or(String.eq(nm, "Bool.or"), String.eq(nm, "Bool.xor")))
      Bool.pick(U32, is_b, 73, Bool.pick(U32, String.eq(nm, "Bool.cmp"), 78, 0))
    case SCon{Chr{66}, _} 4: Bool.pick(U32, String.eq(nm, "Bool.pick"), 128, 0)
    case SCon{Chr{83}, _} 1:
      r2 = Bool.pick(U32, String.eq(nm, "String.length"), 35, 0)
      r1 = Bool.pick(U32, Bool.or(String.eq(nm, "String.reverse"), String.eq(nm, "String.quote")), 37, r2)
      Bool.pick(U32, String.eq(nm, "String.is_empty"), 34, r1)
    case SCon{Chr{83}, _} 2:
      is_sb = Bool.or(
        Bool.or(String.starts_with(nm, "String.is_"), String.eq(nm, "String.eq")),
        Bool.or(String.eq(nm, "String.starts_with"),
          Bool.or(String.eq(nm, "String.ends_with"), String.eq(nm, "String.contains")))
      )
      Bool.pick(U32, String.eq(nm, "String.append"), 100, Bool.pick(U32, is_sb, 97, 0))
    case SCon{Chr{67}, _} 1:
      r3 = Bool.pick(U32, b5k_chk_str_match(False{}, ["Char.to_upper", "Char.to_lower"], nm), 46, 0)
      r2 = Bool.pick(U32, String.starts_with(nm, "Char.is_"), 42, r3)
      r1 = Bool.pick(U32, String.eq(nm, "Char.from_u32"), 6, r2)
      Bool.pick(U32, String.eq(nm, "Char.to_u32"), 41, r1)
    case SCon{Chr{67}, _} 2:
      Bool.pick(U32, String.eq(nm, "Char.is_eq"), 105, Bool.pick(U32, String.eq(nm, "Char.quote"), 130, 0))
    case SCon{Chr{78}, _} 1: Bool.pick(U32, String.eq(nm, "Nat.double"), 19, 0)
    case SCon{Chr{78}, _} 2:
      is_nn = b5k_chk_str_match(False{}, [
        "Nat.add", "Nat.sub", "Nat.mul", "Nat.min", "Nat.max", "Nat.div", "Nat.mod", "Nat.pow"
      ], nm)
      Bool.pick(U32, is_nn, 82, Bool.pick(U32, String.starts_with(nm, "Nat.is_"), 81, 0))
    case SCon{Chr{70}, _} 1:
      is_ff = b5k_chk_str_match(False{}, [
        "F32.neg", "F32.abs", "F32.sqrt", "F32.exp", "F32.log", "F32.log2", "F32.log10",
        "F32.sin", "F32.cos", "F32.tan", "F32.floor", "F32.ceil", "F32.trunc", "F32.round", "F32.square"
      ], nm)
      r4 = Bool.pick(U32, String.eq(nm, "F32.show"), 29, 0)
      r3 = Bool.pick(U32, String.eq(nm, "F32.from_nat"), 20, r4)
      r2 = Bool.pick(U32, String.eq(nm, "F32.to_nat"), 27, r3)
      r1 = Bool.pick(U32, b5k_chk_str_match(False{}, ["F32.to_u32", "F32.bits"], nm), 25, r2)
      Bool.pick(U32, is_ff, 28, r1)
    case SCon{Chr{70}, _} 2:
      is_ff = b5k_chk_str_match(False{}, [
        "F32.add", "F32.sub", "F32.mul", "F32.div", "F32.mod",
        "F32.pow", "F32.atan2", "F32.min", "F32.max", "F32.hypot"
      ], nm)
      Bool.pick(U32, is_ff, 91, Bool.pick(U32, String.starts_with(nm, "F32.is_"), 89, 0))
    case _ _: 0
def b5k_chk_builtin_sig(+nm: String, nargs: U32) -> CallSig:
  b5k_chk_sig_of(b5k_chk_builtin_tag(nm, nargs))

# Exported Generic Helpers (used by lower.bend) & Shared Accessors
def chk_if(-A: Data, c: Bool, t: U32 -> A, f: U32 -> A) -> A:
  match c:
    case True{}: t(0)
    case False{}: f(0)
def chk_maybe(-A: Data, -B: Data, m: Maybe<&2, A>, d: B, f: A -> B) -> B:
  match m:
    case None{}: d
    case Some{x}: f(x)
def chk_err_if(bad: Bool, fn_name: String, msg: String) -> String:
  match bad:
    case True{}: "check: " ++ fn_name ++ msg
    case False{}: ""
def chk_err_res(bad: Bool, fn_name: String, msg: String) -> ExprRes:
  match bad:
    case True{}: ExprErr{"check: " ++ fn_name ++ msg}
    case False{}: ExprOk{Nil{}}
def chk_hd(-A: Data, xs: List<&2, A>, d: A) -> A:
  match xs:
    case Nil{}: d
    case Con{h, _}: h
def chk_tl(-A: Data, xs: List<&2, A>) -> List<&2, A>:
  match xs:
    case Nil{}: Nil{}
    case Con{_, t}: t
def chk_nth(-A: Data, n: Nat, xs: List<&2, A>, d: A) -> A:
  match n xs:
    case 0n Con{h, _}: h
    case 1n+p Con{_, t}: chk_nth(A, p, t, d)
    case _ _: d
def chk_rep(-A: Data, n: Nat, +x: A) -> List<&2, A>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{x, chk_rep(A, p, x)}
def chk_any(~A: Data, ~C: Data, ~f: C -> A -> Bool, +c: C, xs: List<&2, A>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{+h, t}: Bool.or(f(c, h), chk_any(~A, ~C, ~f, c, t))
def chk_all(~A: Data, ~C: Data, ~f: C -> A -> Bool, +c: C, xs: List<&2, A>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{+h, t}: Bool.and(f(c, h), chk_all(~A, ~C, ~f, c, t))
def chk_map(~A: Data, ~B: Data, ~C: Data, ~f: C -> A -> B, +c: C, xs: List<&2, A>) -> List<&2, B>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h, t}: Con{f(c, h), chk_map(~A, ~B, ~C, ~f, c, t)}
def chk_map2(
  ~A: Data, ~B: Data, ~C1: Data, ~C2: Data, ~f: C1 -> C2 -> A -> B,
  +c1: C1, +c2: C2, xs: List<&2, A>
) -> List<&2, B>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h, t}: Con{f(c1, c2, h), chk_map2(~A, ~B, ~C1, ~C2, ~f, c1, c2, t)}
def chk_fold(~A: Data, ~S: Data, ~C: Data, ~f: C -> A -> S -> S, +c: C, xs: List<&2, A>, +st: S) -> S:
  match xs:
    case Nil{}: st
    case Con{+h, t}: chk_fold(~A, ~S, ~C, ~f, c, t, f(c, h, st))
def chk_td_cs(td: TypeDef) -> List<&2, CtorDef>:
  TypeDef{_, _, _, cs} = td
  cs
def chk_pm_sym(p: Param) -> U32:
  Param{s, _, _, _} = p
  s
def chk_def_sym(d: Def) -> U32:
  Def{s, _, _, _, _, _} = d
  s
def chk_cd_sym(c: CtorDef) -> U32:
  CtorDef{s, _, _} = c
  s
def chk_case_ps(c: Case) -> List<&2, Pat>:
  Case{ps, _} = c
  ps
def b5k_chk_ctx_syms(ctx: CheckCtx) -> SymTab:
  CheckCtx{syms, _, _, _, _, _, _} = ctx
  syms
def b5k_chk_sym_name(ctx: CheckCtx, sym: U32) -> String:
  CheckCtx{syms, _, _, _, _, _, _} = ctx
  symtab_name(syms, sym)
def b5k_chk_expr_tag(e: Expr) -> U32:
  match e:
    case ERefl{}: 1
    case EVar{_}: 2
    case ECtr{_, _}: 3
    case EAnn{_, ERefl{}}: 4
    case EAnn{ENum{_}, ESet{}}: 5
    case ELam{_, _}: 6
    case EApp{_, _}: 7
    case _: 0
def chk_expr_sym1(e: Expr) -> U32:
  match e:
    case EVar{s}: U32.add(s, 1)
    case ERef{s}: U32.add(s, 1)
    case _: 0
def chk_unann_var(e: Expr) -> U32:
  match e:
    case EVar{s}: U32.add(s, 1)
    case EAnn{EVar{s}, ESet{}}: U32.add(s, 1)
    case _: 0
def chk_expr_push(e: Expr, mode: U32, +t: List<&2, Expr>) -> List<&2, Expr>:
  match e mode:
    case EApp{_, args} 4: b5k_list_app(Expr, args, t)
    case EApp{fn, args} _: Con{fn, b5k_list_app(Expr, args, t)}
    case ECtr{_, fs} _: b5k_list_app(Expr, fs, t)
    case EAnn{v, ty} 2: Con{v, Con{ty, t}}
    case EAnn{v, _} _: Con{v, t}
    case EOp{_, a, b} _: Con{a, Con{b, t}}
    case EPair{a, b} _: Con{a, Con{b, t}}
    case EEq{a, b} _: Con{a, Con{b, t}}
    case EList{xs} _: b5k_list_app(Expr, xs, t)
    case EUnOp{_, v} _: Con{v, t}
    case _ 0: t
    case _ 3: t
    case _ 4: t
    case ELam{_, b} _: Con{b, t}
    case ELet{_, v, b} _: Con{v, Con{b, t}}
    case EMat{sc, Nil{}} _: b5k_list_app(Expr, sc, t)
    case EMat{sc, Con{Case{_, b}, cs}} _: Con{b, Con{EMat{sc, cs}, t}}
    case EAll{Param{_, Some{ty}, _, _}, b} _: Con{ty, Con{b, t}}
    case EAll{Param{_, None{}, _, _}, b} _: Con{b, t}
    case EIf{c, a, b} _: Con{c, Con{a, Con{b, t}}}
    case _ _: t
def chk_expr_sym_any(~C: Data, ~p: C -> U32 -> Bool, +mode: U32, +fuel: Nat, +c: C, es: List<&2, Expr>) -> Bool:
  match fuel es:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+f Con{+e, +t}:
      +s1 = chk_expr_sym1(e)
      hit = Bool.and(U32.is_gt(s1, 0), Bool.or(U32.is_lt(mode, 3), U32.is_eq(b5k_chk_expr_tag(e), 2)))
      Bool.pick(
        Bool, hit,
        Bool.or(p(c, U32.sub(s1, 1)), chk_expr_sym_any(~C, ~p, mode, f, c, t)),
        chk_expr_sym_any(~C, ~p, mode, f, c, chk_expr_push(e, mode, t))
      )
def chk_pms_tys(ps: List<&2, Param>, acc: List<&2, Expr>) -> List<&2, Expr>:
  match ps:
    case Nil{}: acc
    case Con{Param{_, Some{ty}, _, _}, t}: Con{ty, chk_pms_tys(t, acc)}
    case Con{_, t}: chk_pms_tys(t, acc)
def chk_ctors_tys(cs: List<&2, CtorDef>, acc: List<&2, Expr>) -> List<&2, Expr>:
  match cs:
    case Nil{}: acc
    case Con{CtorDef{_, _, fs}, t}: chk_pms_tys(fs, chk_ctors_tys(t, acc))
def b5k_chk_is_some(-A: Data, m: Maybe<&2, A>) -> Bool:
  match m:
    case Some{_}: True{}
    case None{}: False{}
def b5k_chk_is_type_flag(m: Maybe<&2, U32>) -> Bool:
  U32.is_gt(Maybe.default(&2, U32, m, 0), 0)
def b5k_chk_u32_mem(xs: List<&2, U32>, +x: U32) -> Bool:
  p_u32_mem(xs, x)

# Parametric Type Extraction, Compatibility & Formatting
def b5k_chk_head_sym(syms: SymTab, types: RaVec<Maybe<&2, U32>>, +sym: U32) -> ChkTy:
  hit = b5k_chk_is_type_flag(ct_get(U32, types, sym))
  +nm = symtab_name(syms, sym)
  Bool.pick(
    ChkTy, String.eq(nm, "Data"), b5k_chk_t0("#Data"),
    Bool.pick(
      ChkTy, b5k_chk_is_universe(nm), TErased{},
      Bool.pick(ChkTy, hit, b5k_chk_t0(nm), TTyVar{sym})
    )
  )
def b5k_chk_ty_app(rf: TyRes, ra: TyRes) -> TyRes:
  match rf ra:
    case TROne{TCon{h, a0}} TRMany{a1}: TROne{TCon{h, b5k_list_app(ChkTy, a0, a1)}}
    case TROne{TErased{}} _: TROne{TErased{}}
    case _ _: TROne{TNonUniv{}}
def b5k_chk_ty_res_one(r: TyRes) -> ChkTy:
  match r:
    case TROne{t}: t
    case TRMany{_}: TAny{}
def b5k_chk_ty_res_many(r: TyRes) -> List<&2, ChkTy>:
  match r:
    case TRMany{ts}: ts
    case TROne{_}: Nil{}
def b5k_chk_ty_w(+fuel: Nat, +syms: SymTab, +types: RaVec<Maybe<&2, U32>>, w: TyWork) -> TyRes:
  match fuel w:
    case 0n TWOne{_}: TROne{TAny{}}
    case 0n TWMany{_}: TRMany{Nil{}}
    case 1n+_ TWMany{Nil{}}: TRMany{Nil{}}
    case 1n+f TWMany{Con{h, t}}:
      TRMany{Con{
        b5k_chk_ty_res_one(b5k_chk_ty_w(f, syms, types, TWOne{h})),
        b5k_chk_ty_res_many(b5k_chk_ty_w(f, syms, types, TWMany{t}))
      }}
    case 1n+_ TWOne{EVar{sym}}: TROne{b5k_chk_head_sym(syms, types, sym)}
    case 1n+_ TWOne{ERef{sym}}: TROne{b5k_chk_head_sym(syms, types, sym)}
    case 1n+f TWOne{EApp{EAnn{fun, ESet{}}, args}}:
      b5k_chk_ty_app(b5k_chk_ty_w(f, syms, types, TWOne{fun}), b5k_chk_ty_w(f, syms, types, TWMany{args}))
    case 1n+f TWOne{EApp{EVar{+sym}, Con{+arg, Nil{}}}}:
      +nm = symtab_name(syms, sym)
      is_dt = Bool.and(b5k_chk_is_type_flag(ct_get(U32, types, sym)), Bool.not(String.eq(nm, "Kind")))
      Bool.pick(
        TyRes, is_dt,
        b5k_chk_ty_app(TROne{b5k_chk_head_sym(syms, types, sym)}, b5k_chk_ty_w(f, syms, types, TWMany{[arg]})),
        TROne{TFam{sym, arg}}
      )
    case 1n+f TWOne{EApp{EVar{+sym}, Con{+a1, Con{+a2, Nil{}}}}}:
      Bool.pick(
        TyRes, b5k_chk_is_type_flag(ct_get(U32, types, sym)),
        b5k_chk_ty_app(TROne{b5k_chk_head_sym(syms, types, sym)}, b5k_chk_ty_w(f, syms, types, TWMany{[a1, a2]})),
        TROne{TFam2{sym, a1, a2}}
      )
    case 1n+f TWOne{EApp{fun, args}}:
      b5k_chk_ty_app(b5k_chk_ty_w(f, syms, types, TWOne{fun}), b5k_chk_ty_w(f, syms, types, TWMany{args}))
    case 1n+f TWOne{EAnn{EAll{p, b}, ESet{}}}:
      b5k_chk_ty_w(f, syms, types, TWOne{EAll{p, b}})
    case 1n+f TWOne{EAll{Param{_, Some{aty}, +er, dup}, body}}:
      TROne{TFun{
        Bool.or(er, dup), er,
        b5k_chk_ty_res_one(b5k_chk_ty_w(f, syms, types, TWOne{aty})),
        b5k_chk_ty_res_one(b5k_chk_ty_w(f, syms, types, TWOne{body}))
      }}
    case 1n+f TWOne{EAll{Param{_, None{}, +er, dup}, body}}:
      TROne{TFun{Bool.or(er, dup), er, TAny{}, b5k_chk_ty_res_one(b5k_chk_ty_w(f, syms, types, TWOne{body}))}}
    case 1n+_ TWOne{EEq{a, b}}: TROne{TEq{a, b, TAny{}, False{}}}
    case 1n+_ TWOne{EAnn{ELet{PWild{}, EAnn{ERefl{}, EEq{_, _}}, _}, _}}: TROne{b5k_chk_t0("#StuckRwt")}
    case 1n+f TWOne{EAnn{EOp{20, a, b}, ty}}:
      TROne{TEq{a, b, b5k_chk_ty_res_one(b5k_chk_ty_w(f, syms, types, TWOne{ty})), False{}}}
    case 1n+_ TWOne{EAnn{EOp{21, a, b}, _}}:
      TROne{TFun{False{}, False{}, TEq{a, b, TAny{}, False{}}, b5k_chk_t0("Empty")}}
    case 1n+_ TWOne{EOp{5, EOp{5, _, _}, _}}: TROne{b5k_chk_t0("Sigma")}
    case 1n+_ TWOne{EOp{5, _, EOp{5, _, _}}}: TROne{b5k_chk_t0("Sigma")}
    case 1n+f TWOne{EOp{5, a, b}}:
      TROne{TCon{"Sigma", [
        b5k_chk_ty_res_one(b5k_chk_ty_w(f, syms, types, TWOne{a})),
        b5k_chk_ty_res_one(b5k_chk_ty_w(f, syms, types, TWOne{b}))
      ]}}
    case 1n+_ TWOne{EAnn{ENum{+n}, EUnit{}}}:
      Bool.pick(TyRes, U32.is_le(n, 2), TROne{b5k_chk_t0("&" ++ b5k_u32_to_str(n))}, TROne{TAny{}})
    case 1n+_ TWOne{ENum{+n}}:
      Bool.pick(TyRes, U32.is_le(n, 2), TROne{b5k_chk_t0("&" ++ b5k_u32_to_str(n))}, TROne{TAny{}})
    case 1n+_ TWOne{_}: TROne{TAny{}}
def b5k_chk_head_expr(+syms: SymTab, +types: RaVec<Maybe<&2, U32>>, e: Expr) -> ChkTy:
  b5k_chk_ty_res_one(b5k_chk_ty_w(32n, syms, types, TWOne{e}))
def b5k_chk_head_opt(+syms: SymTab, +types: RaVec<Maybe<&2, U32>>, opt: Maybe<&2, Expr>) -> ChkTy:
  match opt:
    case None{}: TAny{}
    case Some{e}: b5k_chk_head_expr(syms, types, e)

# Phase-1 Dependent Constant Evaluator
type CVal is Data:
  CVNone{}
  CVNum{v: U32}
  CVFlt{b: U32}
  CVChr{c: U32}
  CVStr{s: String}
  CVBool{b: Bool}
  CVCtr{sym: U32, fs: List<&2, CVal>}
  CVPair{a: CVal, b: CVal}
  CVList{es: List<&2, CVal>}
  CVNeutVar{sym: U32}
  CVNeutApp{sym: U32, args: List<&2, CVal>}
type CEnvBind is Data:
  CEnvBind{sym: U32, val: CVal}
type CEnvStep is Data:
  CEnvStep{cenv: List<&2, CEnvBind>, e: Expr}
type CEvalWork is Data:
  CEExpr{cenv: List<&2, CEnvBind>, e: Expr}
  CEIf{cenv: List<&2, CEnvBind>, v: CVal, t: Expr, el: Expr}
  CEPairOpt{m: Maybe<&2, CEnvStep>}
def b5k_chk_di_u32(which: U32, di: Maybe<&2, DefInfo>) -> U32:
  match which di:
    case 0 Some{DefInfo{_, _, _, _, _, idx, _, _, _, _}}: idx
    case 1 Some{DefInfo{_, _, nc, _, _, _, _, _, _, _}}: nc
    case 2 Some{DefInfo{_, _, _, _, False{}, idx, _, _, _, _}}: idx
    case _ _: 0
def b5k_chk_cv_tag(v: CVal) -> U32:
  match v:
    case CVNone{}: 0
    case CVNeutVar{_}: 1
    case CVNeutApp{_, _}: 2
    case CVNum{_}: 3
    case CVCtr{_, _}: 3
    case CVBool{_}: 4
    case CVStr{_}: 5
    case _: 6
def b5k_chk_cv_ok(v: CVal) -> Bool:
  U32.is_gt(b5k_chk_cv_tag(v), 0)
def b5k_chk_cv_is_strict_neut(v: CVal) -> Bool:
  +t = b5k_chk_cv_tag(v)
  Bool.or(U32.is_eq(t, 1), U32.is_eq(t, 2))
def b5k_chk_cv_can_mat(v: CVal) -> Bool:
  +t = b5k_chk_cv_tag(v)
  Bool.and(U32.is_ge(t, 3), U32.is_ne(t, 5))
def b5k_chk_cv_u32_op(a: CVal, b: CVal, op: U32) -> CVal:
  match a b op:
    case CVNum{x} CVNum{y} 0: CVNum{U32.add(x, y)}
    case CVNum{x} CVNum{y} 1: CVNum{U32.sub(x, y)}
    case CVNum{x} CVNum{y} 2: CVNum{U32.mul(x, y)}
    case CVNum{x} CVNum{+y} 3: Bool.pick(CVal, U32.is_zero(y), CVNone{}, CVNum{U32.div(x, y)})
    case CVNum{x} CVNum{+y} 4: Bool.pick(CVal, U32.is_zero(y), CVNone{}, CVNum{U32.mod(x, y)})
    case CVNum{x} CVNum{y} 5: CVNum{U32.and(x, y)}
    case CVNum{x} CVNum{y} 6: CVNum{U32.or(x, y)}
    case CVNum{x} CVNum{y} 7: CVNum{U32.xor(x, y)}
    case CVNum{x} CVNum{y} 20: CVBool{U32.is_eq(x, y)}
    case CVNum{x} CVNum{y} 21: CVBool{U32.is_ne(x, y)}
    case CVNum{x} CVNum{y} 22: CVBool{U32.is_lt(x, y)}
    case CVNum{x} CVNum{y} 23: CVBool{U32.is_le(x, y)}
    case CVNum{x} CVNum{y} 24: CVBool{U32.is_gt(x, y)}
    case CVNum{x} CVNum{y} 25: CVBool{U32.is_ge(x, y)}
    case _ _ _: CVNone{}
def b5k_chk_cv_call1(+nm: String, v: CVal) -> CVal:
  match v:
    case CVNum{+x}:
      r3 = Bool.pick(CVal, String.eq(nm, "Nat.double"), CVNum{U32.mul(x, 2)}, CVNone{})
      r2 = Bool.pick(CVal, String.eq(nm, "U32.is_zero"), CVBool{U32.is_zero(x)}, r3)
      r1 = Bool.pick(CVal, String.eq(nm, "U32.not"), CVNum{U32.not(x)}, r2)
      Bool.pick(CVal, String.eq(nm, "U32.inc"), CVNum{U32.add(x, 1)}, r1)
    case CVBool{+b}: Bool.pick(CVal, String.eq(nm, "Bool.not"), CVBool{Bool.not(b)}, CVNone{})
    case _: CVNone{}
def b5k_chk_cv_call2(+nm: String, v1: CVal, v2: CVal) -> CVal:
  match v1 v2:
    case CVNum{+x} CVNum{+y}:
      r5 = Bool.pick(CVal, String.eq(nm, "U32.is_lt"), CVBool{U32.is_lt(x, y)}, CVNone{})
      r4 = Bool.pick(CVal, String.eq(nm, "U32.is_ne"), CVBool{U32.is_ne(x, y)}, r5)
      r3 = Bool.pick(CVal, String.eq(nm, "U32.is_eq"), CVBool{U32.is_eq(x, y)}, r4)
      r2 = Bool.pick(CVal, Bool.or(String.eq(nm, "U32.mul"), String.eq(nm, "Nat.mul")), CVNum{U32.mul(x, y)}, r3)
      r1 = Bool.pick(CVal, Bool.or(String.eq(nm, "U32.sub"), String.eq(nm, "Nat.sub")), CVNum{U32.sub(x, y)}, r2)
      Bool.pick(CVal, Bool.or(String.eq(nm, "U32.add"), String.eq(nm, "Nat.add")), CVNum{U32.add(x, y)}, r1)
    case CVBool{+a} CVBool{+b}:
      r2 = Bool.pick(CVal, String.eq(nm, "Bool.xor"), CVBool{Bool.xor(a, b)}, CVNone{})
      r1 = Bool.pick(CVal, String.eq(nm, "Bool.or"), CVBool{Bool.or(a, b)}, r2)
      Bool.pick(CVal, String.eq(nm, "Bool.and"), CVBool{Bool.and(a, b)}, r1)
    case CVStr{+a} CVStr{+b}:
      r1 = Bool.pick(CVal, String.eq(nm, "String.eq"), CVBool{String.eq(a, b)}, CVNone{})
      Bool.pick(CVal, String.eq(nm, "String.append"), CVStr{a ++ b}, r1)
    case _ _: CVNone{}
def b5k_chk_cv_ctr(+syms: SymTab, +sym: U32, fs: List<&2, CVal>) -> CVal:
  match fs:
    case Nil{}:
      +nm = symtab_name(syms, sym)
      Bool.pick(
        CVal, String.eq(nm, "Zero"), CVNum{0},
        Bool.pick(
          CVal, String.eq(nm, "True"), CVBool{True{}},
          Bool.pick(CVal, String.eq(nm, "False"), CVBool{False{}}, CVCtr{sym, Nil{}})
        )
      )
    case Con{CVNum{+k}, Nil{}}:
      Bool.pick(CVal, String.eq(symtab_name(syms, sym), "Succ"), CVNum{U32.add(k, 1)}, CVCtr{sym, [CVNum{k}]})
    case other: CVCtr{sym, other}
def b5k_chk_cenv_get(cenv: List<&2, CEnvBind>, +sym: U32) -> CVal:
  match cenv:
    case Nil{}: CVNone{}
    case Con{CEnvBind{s, v}, t}: Bool.pick(CVal, U32.is_eq(s, sym), v, b5k_chk_cenv_get(t, sym))
def b5k_chk_cv_pat_bind_go(
  +fuel: Nat, +syms: SymTab, ps: List<&2, Pat>, vs: List<&2, CVal>, cenv: List<&2, CEnvBind>
) -> Maybe<&2, List<&2, CEnvBind>>:
  match fuel ps vs:
    case 0n _ _: None{}
    case _ Nil{} Nil{}: Some{cenv}
    case 1n+f Con{PWild{}, pt} Con{_, vt}: b5k_chk_cv_pat_bind_go(f, syms, pt, vt, cenv)
    case 1n+f Con{PVar{s, _}, pt} Con{val, vt}: b5k_chk_cv_pat_bind_go(f, syms, pt, vt, Con{CEnvBind{s, val}, cenv})
    case 1n+f Con{PNum{k}, pt} Con{CVNum{x}, vt}:
      Bool.pick(Maybe<&2, List<&2, CEnvBind>>, U32.is_eq(k, x), b5k_chk_cv_pat_bind_go(f, syms, pt, vt, cenv), None{})
    case 1n+f Con{PCtr{psym, Nil{}}, pt} Con{CVBool{+b}, vt}:
      +nm = symtab_name(syms, psym)
      ok = Bool.or(Bool.and(b, String.eq(nm, "True")), Bool.and(Bool.not(b), String.eq(nm, "False")))
      Bool.pick(Maybe<&2, List<&2, CEnvBind>>, ok, b5k_chk_cv_pat_bind_go(f, syms, pt, vt, cenv), None{})
    case 1n+f Con{PCtr{psym, Nil{}}, pt} Con{CVNum{x}, vt}:
      ok = Bool.and(String.eq(symtab_name(syms, psym), "Zero"), U32.is_zero(x))
      Bool.pick(Maybe<&2, List<&2, CEnvBind>>, ok, b5k_chk_cv_pat_bind_go(f, syms, pt, vt, cenv), None{})
    case 1n+f Con{PCtr{psym, Con{p1, Nil{}}}, pt} Con{CVNum{+x}, vt}:
      ok = Bool.and(String.eq(symtab_name(syms, psym), "Succ"), U32.is_gt(x, 0))
      nxt = b5k_chk_cv_pat_bind_go(f, syms, Con{p1, pt}, Con{CVNum{U32.sub(x, 1)}, vt}, cenv)
      Bool.pick(Maybe<&2, List<&2, CEnvBind>>, ok, nxt, None{})
    case 1n+f Con{PCtr{psym, pfs}, pt} Con{CVCtr{csym, vfs}, vt}:
      nxt = b5k_chk_cv_pat_bind_go(f, syms, b5k_list_app(Pat, pfs, pt), b5k_list_app(CVal, vfs, vt), cenv)
      Bool.pick(Maybe<&2, List<&2, CEnvBind>>, U32.is_eq(psym, csym), nxt, None{})
    case _ _ _: None{}
def b5k_chk_cv_mat_go(
  cs: List<&2, Case>, hit: Maybe<&2, List<&2, CEnvBind>>, body0: Expr,
  +syms: SymTab, +sv: CVal, +cenv: List<&2, CEnvBind>
) -> Maybe<&2, CEnvStep>:
  match cs hit:
    case _ Some{ce2}: Some{CEnvStep{ce2, body0}}
    case Nil{} None{}: None{}
    case Con{Case{Con{p, Nil{}}, body}, rest} None{}:
      b5k_chk_cv_mat_go(rest, b5k_chk_cv_pat_bind_go(16n, syms, [p], [sv], cenv), body, syms, sv, cenv)
    case Con{_, rest} None{}: b5k_chk_cv_mat_go(rest, None{}, body0, syms, sv, cenv)
def b5k_chk_cv_def(ar: U32, va: CVal, vb: CVal, md: Maybe<&2, Def>) -> Maybe<&2, CEnvStep>:
  match ar md:
    case 0 Some{Def{_, Nil{}, _, body, False{}, _}}: Some{CEnvStep{Nil{}, body}}
    case 1 Some{Def{_, Con{Param{p1, _, False{}, _}, Nil{}}, _, body, False{}, _}}:
      Some{CEnvStep{[CEnvBind{p1, va}], body}}
    case 2 Some{Def{_, Con{Param{p1, _, False{}, _}, Con{Param{p2, _, False{}, _}, Nil{}}}, _, body, False{}, _}}:
      Some{CEnvStep{[CEnvBind{p2, vb}, CEnvBind{p1, va}], body}}
    case 2 Some{Def{_, Nil{}, _, ELam{Con{Param{p1, _, _, _}, Nil{}}, ELam{Con{Param{p2, _, _, _}, Nil{}}, body}},
      False{}, _}}:
      Some{CEnvStep{[CEnvBind{p2, vb}, CEnvBind{p1, va}], body}}
    case _ _: None{}
def b5k_chk_def_is_mat(is2: Bool, md: Maybe<&2, Def>) -> Bool:
  match is2 md:
    case False{} Some{Def{_, Con{Param{p1, _, False{}, _}, Nil{}}, _, EMat{Con{EVar{sc}, Nil{}}, _}, False{}, _}}:
      U32.is_eq(p1, sc)
    case True{} Some{Def{_, Con{Param{p1, _, False{}, _}, Con{Param{_, _, False{}, _}, Nil{}}}, _,
      EMat{Con{EVar{sc}, Nil{}}, _}, False{}, _}}:
      U32.is_eq(p1, sc)
    case _ _: False{}
def b5k_chk_eval_w(+ctx: CheckCtx, +fuel: Nat, +allow_n: Bool, +cur_idx: U32, w: CEvalWork) -> CVal:
  CheckCtx{+syms, +types, _, +defs, _, +dasts, _} = ctx
  match fuel w:
    case 0n _: CVNone{}
    case 1n+f CEIf{ce, CVBool{b}, t, el}: b5k_chk_eval_w(ctx, f, allow_n, cur_idx,
      CEExpr{ce, Bool.pick(Expr, b, t, el)})
    case 1n+_ CEIf{_, _, _, _}: CVNone{}
    case 1n+f CEPairOpt{Some{CEnvStep{ce, e}}}: b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{ce, e})
    case 1n+_ CEPairOpt{None{}}: CVNone{}
    case 1n+_ CEExpr{_, ENum{v}}: CVNum{v}
    case 1n+_ CEExpr{_, EFlt{b}}: CVFlt{b}
    case 1n+_ CEExpr{_, EChr{c}}: CVChr{c}
    case 1n+_ CEExpr{_, EStr{s}}: CVStr{s}
    case 1n+_ CEExpr{cenv, EVar{+sym}}:
      +cv = b5k_chk_cenv_get(cenv, sym)
      +nm = symtab_name(syms, sym)
      is_nv = Bool.or(
        Bool.and(U32.is_gt(cur_idx, 0), U32.is_gt(b5k_chk_di_u32(2, ct_get(DefInfo, defs, sym)), cur_idx)),
        Bool.and(allow_n, Bool.not(b5k_chk_is_some(Def, ct_get(Def, dasts, sym))))
      )
      Bool.pick(
        CVal, b5k_chk_cv_ok(cv), cv,
        Bool.pick(
          CVal, Bool.or(String.eq(nm, "Data"), String.eq(nm, "Type")), CVStr{"#U:" ++ nm},
          Bool.pick(
            CVal, b5k_chk_is_type_flag(ct_get(U32, types, sym)), CVStr{"#T:" ++ nm},
            Bool.pick(CVal, is_nv, CVNeutVar{sym}, CVNone{})
          )
        )
      )
    case 1n+f CEExpr{+cenv, ELam{Con{Param{p, _, _, _}, Nil{}}, body}}:
      b5k_chk_eval_w(
        ctx, f, allow_n, cur_idx,
        CEExpr{Con{CEnvBind{p, CVNeutVar{U32.add(100000, b5k_list_len(CEnvBind, cenv))}}, cenv}, body}
      )
    case 1n+f CEExpr{cenv, EUnOp{1, v}}: b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, v})
    case 1n+f CEExpr{cenv, EAnn{EOp{0, EAnn{ENum{1}, ESet{}}, b}, EVar{tn}}}:
      Bool.pick(
        CVal, String.eq(symtab_name(syms, tn), "Nat"), CVNone{},
        b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, EOp{0, ENum{1}, b}})
      )
    case 1n+f CEExpr{cenv, EAnn{EOp{0, ENum{1}, b}, EVar{tn}}}:
      Bool.pick(
        CVal, String.eq(symtab_name(syms, tn), "Nat"), CVNone{},
        b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, EOp{0, ENum{1}, b}})
      )
    case 1n+f CEExpr{cenv, EAnn{v, _}}: b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, v})
    case 1n++f CEExpr{+cenv, EOp{+op, a, b}}:
      +va = b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, a})
      +vb = b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, b})
      +r0 = b5k_chk_cv_u32_op(va, vb, op)
      ok_n = Bool.and(Bool.or(allow_n, U32.is_eq(op, 5)), Bool.and(b5k_chk_cv_ok(va), b5k_chk_cv_ok(vb)))
      Bool.pick(CVal, b5k_chk_cv_ok(r0), r0,
        Bool.pick(CVal, ok_n, CVNeutApp{U32.add(200000, op), [va, vb]}, CVNone{}))
    case 1n++f CEExpr{+cenv, EIf{c, t, el}}:
      b5k_chk_eval_w(ctx, f, allow_n, cur_idx,
        CEIf{cenv, b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, c}), t, el})
    case 1n++f CEExpr{+cenv, EMat{Con{sc, Nil{}}, cs}}:
      +sv = b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, sc})
      Bool.pick(
        CVal, b5k_chk_cv_can_mat(sv),
        b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEPairOpt{b5k_chk_cv_mat_go(cs, None{}, EUnit{}, syms, sv, cenv)}),
        CVNone{}
      )
    case 1n+f CEExpr{_, ECtr{sym, Nil{}}}: b5k_chk_cv_ctr(syms, sym, Nil{})
    case 1n+f CEExpr{cenv, ECtr{sym, Con{a, Nil{}}}}:
      b5k_chk_cv_ctr(syms, sym, [b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, a})])
    case 1n++f CEExpr{+cenv, ECtr{sym, Con{a, Con{b, Nil{}}}}}:
      b5k_chk_cv_ctr(syms, sym, [
        b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, a}),
        b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, b})
      ])
    case 1n++f CEExpr{+cenv, EPair{a, b}}:
      +va = b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, a})
      +vb = b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, b})
      Bool.pick(CVal, Bool.and(b5k_chk_cv_ok(va), b5k_chk_cv_ok(vb)), CVPair{va, vb}, CVNone{})
    case 1n++f CEExpr{+cenv,
      EApp{ELam{Con{Param{p1, _, _, _}, Nil{}}, ELam{Con{Param{p2, _, _, _}, Nil{}}, body}}, Con{a, Con{b, Nil{}}}}}:
      +va = b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, a})
      +vb = b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, b})
      Bool.pick(
        CVal, Bool.and(b5k_chk_cv_ok(va), b5k_chk_cv_ok(vb)),
        b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{[CEnvBind{p2, vb}, CEnvBind{p1, va}], body}),
        CVNone{}
      )
    case 1n+f CEExpr{_, EApp{EVar{+sym}, Nil{}}}:
      b5k_chk_eval_w(ctx, f, allow_n, cur_idx,
        CEPairOpt{b5k_chk_cv_def(0, CVNone{}, CVNone{}, ct_get(Def, dasts, sym))})
    case 1n++f CEExpr{cenv, EApp{EVar{+sym}, Con{a, Nil{}}}}:
      +va = b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, a})
      +r0 = b5k_chk_cv_call1(symtab_name(syms, sym), va)
      +md = ct_get(Def, dasts, sym)
      +r1 = Bool.pick(
        CVal, b5k_chk_cv_ok(r0), r0,
        Bool.pick(
          CVal, b5k_chk_cv_ok(va),
          b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEPairOpt{b5k_chk_cv_def(1, va, CVNone{}, md)}),
          CVNone{}
        )
      )
      ok_n = Bool.and(allow_n, Bool.and(b5k_chk_cv_is_strict_neut(va), b5k_chk_def_is_mat(False{}, md)))
      Bool.pick(CVal, b5k_chk_cv_ok(r1), r1, Bool.pick(CVal, ok_n, CVNeutApp{sym, [va]}, CVNone{}))
    case 1n++f CEExpr{+cenv, EApp{EVar{+sym}, Con{a, Con{b, Nil{}}}}}:
      +va = b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, a})
      +vb = b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, b})
      +nm = symtab_name(syms, sym)
      +r0 = b5k_chk_cv_call2(nm, va, vb)
      +md = ct_get(Def, dasts, sym)
      +r1 = Bool.pick(
        CVal, b5k_chk_cv_ok(r0), r0,
        Bool.pick(
          CVal, Bool.and(b5k_chk_cv_ok(va), b5k_chk_cv_ok(vb)),
          b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEPairOpt{b5k_chk_cv_def(2, va, vb, md)}),
          CVNone{}
        )
      )
      ok_n = Bool.and(
        allow_n,
        Bool.and(b5k_chk_cv_is_strict_neut(va),
          Bool.and(b5k_chk_cv_ok(vb), Bool.or(b5k_chk_def_is_mat(True{}, md), String.eq(nm, "Nat.add"))))
      )
      Bool.pick(CVal, b5k_chk_cv_ok(r1), r1, Bool.pick(CVal, ok_n, CVNeutApp{sym, [va, vb]}, CVNone{}))
    case 1n++f CEExpr{+cenv, EApp{EVar{+sym}, Con{a, Con{b, Con{c, Nil{}}}}}}:
      +va = b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, a})
      +vb = b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, b})
      +vc = b5k_chk_eval_w(ctx, f, allow_n, cur_idx, CEExpr{cenv, c})
      ok_n = Bool.and(
        allow_n,
        Bool.and(b5k_chk_cv_is_strict_neut(vc),
          Bool.and(Bool.not(b5k_chk_cv_can_mat(va)), Bool.not(b5k_chk_cv_can_mat(vb))))
      )
      Bool.pick(CVal, ok_n, CVNeutApp{sym, [vc]}, CVNone{})
    case _ _: CVNone{}
def b5k_chk_cv_neq(+fuel: Nat, a: CVal, b: CVal) -> Bool:
  match fuel a b:
    case 0n _ _: False{}
    case _ CVNum{x} CVNum{y}: U32.is_ne(x, y)
    case _ CVFlt{x} CVFlt{y}: U32.is_ne(x, y)
    case _ CVChr{x} CVChr{y}: U32.is_ne(x, y)
    case _ CVStr{x} CVStr{y}: Bool.not(String.eq(x, y))
    case _ CVBool{x} CVBool{y}: Bool.xor(x, y)
    case _ CVNeutVar{s1} CVNeutVar{s2}: U32.is_ne(s1, s2)
    case 1n+f CVPair{a1, b1} CVPair{a2, b2}: Bool.or(b5k_chk_cv_neq(f, a1, a2), b5k_chk_cv_neq(f, b1, b2))
    case 1n+f CVNeutApp{s1, xs1} CVNeutApp{s2, xs2}:
      Bool.or(U32.is_ne(s1, s2), b5k_chk_cv_neq(f, CVList{xs1}, CVList{xs2}))
    case 1n+f CVCtr{s1, xs1} CVCtr{s2, xs2}:
      Bool.or(U32.is_ne(s1, s2), b5k_chk_cv_neq(f, CVList{xs1}, CVList{xs2}))
    case 1n+f CVList{Con{x1, Nil{}}} CVList{Con{x2, Nil{}}}: b5k_chk_cv_neq(f, x1, x2)
    case 1n+f CVList{Con{x1, Con{y1, Nil{}}}} CVList{Con{x2, Con{y2, Nil{}}}}:
      Bool.or(b5k_chk_cv_neq(f, x1, x2), b5k_chk_cv_neq(f, y1, y2))
    case _ x y:
      +tx = b5k_chk_cv_tag(x)
      +ty = b5k_chk_cv_tag(y)
      in_r = Bool.and(U32.is_gt(tx, 0), Bool.and(U32.is_le(tx, 4), Bool.and(U32.is_gt(ty, 0), U32.is_le(ty, 4))))
      not_24 = Bool.not(Bool.or(Bool.and(U32.is_eq(tx, 2), U32.is_eq(ty, 4)),
        Bool.and(U32.is_eq(tx, 4), U32.is_eq(ty, 2))))
      Bool.and(in_r, Bool.and(U32.is_ne(tx, ty), not_24))
def b5k_chk_expr_neq_idx(+ctx: CheckCtx, +cur_idx: U32, +allow_n: Bool, a: Expr, b: Expr) -> Bool:
  b5k_chk_cv_neq(
    16n,
    b5k_chk_eval_w(ctx, 24n, allow_n, cur_idx, CEExpr{Nil{}, a}),
    b5k_chk_eval_w(ctx, 24n, allow_n, cur_idx, CEExpr{Nil{}, b})
  )
def b5k_chk_ty_tag(t: ChkTy) -> U32:
  match t:
    case TAny{}: 1
    case TErased{}: 2
    case TCon{+h, _}:
      Bool.pick(
        U32, String.eq(h, "#Data"), 3,
        Bool.pick(U32, String.eq(h, "Empty"), 8, Bool.pick(U32, String.eq(h, "Quant"), 9, 4))
      )
    case TEq{_, _, _, _}: 5
    case TFun{_, _, _, _}: 6
    case TTyVar{_}: 7
    case _: 0
def b5k_chk_ty_zip(a1: List<&2, ChkTy>, a2: List<&2, ChkTy>, acc: List<&2, TyPair>) -> List<&2, TyPair>:
  match a1 a2:
    case Con{+h1, t1} Con{+h2, t2}:
      +t1u = b5k_chk_ty_tag(h1)
      +t2u = b5k_chk_ty_tag(h2)
      +acc1: List<&2, TyPair> = Con{TyPair{h1, h2}, acc}
      is_er = Bool.or(Bool.or(U32.is_eq(t1u, 2), U32.is_eq(t1u, 3)), Bool.or(U32.is_eq(t2u, 2), U32.is_eq(t2u, 3)))
      b5k_chk_ty_zip(t1, t2, Bool.pick(List<&2, TyPair>, is_er, Con{TyPair{h2, h1}, acc1}, acc1))
    case _ _: acc
def b5k_chk_bool_compat_k(eq: Bool, +h1: String, +h2: String) -> Bool:
  match eq:
    case True{}: True{}
    case False{}:
      b_m = Bool.or(Bool.and(String.eq(h1, "Bool"), String.ends_with(h2, ".Bool")),
        Bool.and(String.eq(h2, "Bool"), String.ends_with(h1, ".Bool")))
      l_m = Bool.or(Bool.and(String.eq(h1, "List"), String.ends_with(h2, ".List")),
        Bool.and(String.eq(h2, "List"), String.ends_with(h1, ".List")))
      q_m = Bool.or(Bool.and(String.eq(h1, "&2"), Bool.or(String.eq(h2, "&1"), String.eq(h2, "&0"))),
        Bool.and(String.eq(h1, "&1"), String.eq(h2, "&0")))
      Bool.or(b_m, Bool.or(l_m, q_m))
def b5k_chk_bool_compat(+h1: String, +h2: String) -> Bool:
  b5k_chk_bool_compat_k(String.eq(h1, h2), h1, h2)
def b5k_chk_fam_stuck_same(a: Expr, b: Expr) -> Bool:
  match a b:
    case EVar{x} EApp{_, Con{EVar{y}, _}}: U32.is_eq(x, y)
    case EApp{_, Con{EVar{x}, _}} EVar{y}: U32.is_eq(x, y)
    case EOp{5, _, _} EVar{_}: True{}
    case _ _: False{}
def b5k_chk_ty_ok_go(+fuel: Nat, +ctx: CheckCtx, q: List<&2, TyPair>) -> Bool:
  match fuel q:
    case 0n _: True{}
    case _ Nil{}: True{}
    case 1n+f Con{TyPair{TErased{}, TCon{h, _}}, rest}:
      Bool.pick(Bool, String.eq(h, "#Data"), False{}, b5k_chk_ty_ok_go(f, ctx, rest))
    case 1n+f Con{TyPair{TCon{h, _}, TErased{}}, rest}:
      Bool.pick(Bool, String.eq(h, "#Data"), b5k_chk_ty_ok_go(f, ctx, rest), False{})
    case 1n+f Con{TyPair{TFam{+h1, +a1}, TFam{+h2, +a2}}, rest}:
      neq = Bool.or(
        b5k_chk_expr_neq_idx(ctx, 0, False{}, EApp{EVar{h1}, [a1]}, EApp{EVar{h2}, [a2]}),
        Bool.and(U32.is_eq(h1, h2),
          Bool.or(b5k_chk_expr_neq_idx(ctx, 0, False{}, a1, a2), b5k_chk_fam_stuck_same(a1, a2)))
      )
      Bool.pick(Bool, neq, False{}, b5k_chk_ty_ok_go(f, ctx, rest))
    case 1n+f Con{TyPair{TFam2{h, a1, a2}, TTyVar{v}}, rest}:
      Bool.pick(Bool, b5k_chk_expr_neq_idx(ctx, 0, True{}, EApp{EVar{h}, [a1, a2]}, EVar{v}), False{},
        b5k_chk_ty_ok_go(f, ctx, rest))
    case 1n+f Con{TyPair{TTyVar{v}, TFam2{h, a1, a2}}, rest}:
      Bool.pick(Bool, b5k_chk_expr_neq_idx(ctx, 0, True{}, EVar{v}, EApp{EVar{h}, [a1, a2]}), False{},
        b5k_chk_ty_ok_go(f, ctx, rest))
    case 1n+f Con{TyPair{TFun{d1, er1, a1, r1}, TFun{d2, er2, a2, r2}}, rest}:
      bad = Bool.or(Bool.xor(er1, er2), Bool.and(d1, Bool.not(d2)))
      Bool.pick(Bool, bad, False{}, b5k_chk_ty_ok_go(f, ctx, Con{TyPair{a2, a1}, Con{TyPair{r1, r2}, rest}}))
    case 1n+f Con{TyPair{TFun{_, _, _, _}, TCon{h, _}}, rest}:
      Bool.pick(Bool, String.eq(h, "Sigma"), b5k_chk_ty_ok_go(f, ctx, rest), False{})
    case 1n+f Con{TyPair{TCon{h, _}, TFun{_, _, _, _}}, rest}:
      Bool.pick(Bool, String.eq(h, "Sigma"), b5k_chk_ty_ok_go(f, ctx, rest), False{})
    case 1n+f Con{TyPair{TFun{_, _, _, _}, TEq{_, _, _, _}}, _}: False{}
    case 1n+f Con{TyPair{TEq{_, _, _, _}, TFun{_, _, _, _}}, _}: False{}
    case 1n+f Con{TyPair{TEq{a1, b1, _, _}, TEq{a2, b2, _, _}}, rest}:
      neq = Bool.or(b5k_chk_expr_neq_idx(ctx, 0, False{}, a1, a2), b5k_chk_expr_neq_idx(ctx, 0, False{}, b1, b2))
      Bool.pick(Bool, neq, False{}, b5k_chk_ty_ok_go(f, ctx, rest))
    case 1n+f Con{TyPair{TEq{a, b, _, _}, TCon{+h, _}}, rest}:
      ok = Bool.or(String.eq(h, "Equal"),
        Bool.and(String.eq(h, "Empty"), b5k_chk_expr_neq_idx(ctx, 0, False{}, a, b)))
      Bool.pick(Bool, ok, b5k_chk_ty_ok_go(f, ctx, rest), False{})
    case 1n+f Con{TyPair{TCon{h, _}, TEq{_, _, _, _}}, rest}:
      Bool.pick(Bool, String.eq(h, "Equal"), b5k_chk_ty_ok_go(f, ctx, rest), False{})
    case 1n+f Con{TyPair{TCon{h1, +a1}, TCon{h2, +a2}}, +rest}:
      q2 = Bool.pick(
        List<&2, TyPair>, U32.is_eq(b5k_list_len(ChkTy, a1), b5k_list_len(ChkTy, a2)),
        b5k_chk_ty_zip(a1, a2, rest), rest
      )
      Bool.pick(Bool, b5k_chk_bool_compat(h1, h2), b5k_chk_ty_ok_go(f, ctx, q2), False{})
    case 1n+f Con{_, rest}: b5k_chk_ty_ok_go(f, ctx, rest)
def b5k_chk_head_ok(ctx: CheckCtx, got: ChkTy, goal: ChkTy) -> Bool:
  match got goal:
    case TAny{} _: True{}
    case _ TAny{}: True{}
    case TCon{h1, Nil{}} TCon{h2, Nil{}}: b5k_chk_bool_compat(h1, h2)
    case g1 g2: b5k_chk_ty_ok_go(64n, ctx, [TyPair{g1, g2}])
def b5k_chk_ty_show_args(ts: List<&2, ChkTy>, tail: List<&2, TyShow>) -> List<&2, TyShow>:
  match ts:
    case Nil{}: tail
    case Con{h, Nil{}}: Con{TSOne{h}, tail}
    case Con{h, t}: Con{TSOne{h}, Con{TSSep{", "}, b5k_chk_ty_show_args(t, tail)}}
def b5k_chk_ty_show_go(fuel: Nat, q: List<&2, TyShow>) -> String:
  match fuel q:
    case 0n _: ""
    case _ Nil{}: ""
    case 1n+f Con{TSSep{s}, rest}: s ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TNonUniv{}}, rest}: "TypeFamily" ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TFam{_, _}}, rest}: "TypeFamily" ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TErased{}}, rest}: "Type" ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TFun{_, _, _, _}}, rest}: "Fn" ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TEq{_, _, _, _}}, rest}: "Equal" ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TCon{h, Nil{}}}, rest}: h ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TCon{h, args}}, rest}:
      h ++ "<" ++ b5k_chk_ty_show_go(f, b5k_chk_ty_show_args(args, Con{TSSep{">"}, rest}))
    case 1n+f Con{TSOne{_}, rest}: "_" ++ b5k_chk_ty_show_go(f, rest)
def b5k_chk_head_err(fn_name: String, got: ChkTy, goal: ChkTy) -> String:
  "check: " ++ fn_name ++ ": type mismatch (expected " ++ b5k_chk_ty_show_go(64n, [TSOne{goal}])
    ++ ", got " ++ b5k_chk_ty_show_go(64n, [TSOne{got}]) ++ ")"
def b5k_chk_expect_k(ok: Bool, fn_name: String, got: ChkTy, goal: ChkTy, res: ExprRes) -> ExprRes:
  match ok:
    case True{}: res
    case False{}: ExprErr{b5k_chk_head_err(fn_name, got, goal)}
def b5k_chk_expect(ctx: CheckCtx, fn_name: String, +got: ChkTy, +goal: ChkTy, res: ExprRes) -> ExprRes:
  b5k_chk_expect_k(b5k_chk_head_ok(ctx, got, goal), fn_name, got, goal, res)

# Symbol, Type, Constructor, Def & Law Indexing (Closure-Free)
def b5k_chk_param_flags(+inc_dup: Bool, ps: List<&2, Param>) -> List<&2, Bool>:
  match ps:
    case Nil{}: Nil{}
    case Con{Param{_, _, +er, dup}, t}:
      Con{Bool.pick(Bool, inc_dup, Bool.or(er, dup), er), b5k_chk_param_flags(inc_dup, t)}
def b5k_chk_param_tys(
  +live_only: Bool, +syms: SymTab, +types: RaVec<Maybe<&2, U32>>, ps: List<&2, Param>
) -> List<&2, ChkTy>:
  match ps:
    case Nil{}: Nil{}
    case Con{Param{_, typ, erased, _}, rest}:
      +tail = b5k_chk_param_tys(live_only, syms, types, rest)
      Bool.pick(List<&2, ChkTy>, Bool.and(live_only, erased), tail, Con{b5k_chk_head_opt(syms, types, typ), tail})
def ct_set_maybe(-A: Data, m: Maybe<&2, U32>, v: A, t: RaVec<Maybe<&2, A>>) -> RaVec<Maybe<&2, A>>:
  match m:
    case None{}: t
    case Some{s}: ct_set(A, t, s, v)
def b5k_chk_index_ctors(
  +syms: SymTab, +tm: RaVec<Maybe<&2, U32>>, +tname: String,
  cs: List<&2, CtorDef>, cm: RaVec<Maybe<&2, CtorInfo>>
) -> RaVec<Maybe<&2, CtorInfo>>:
  match cs:
    case Nil{}: cm
    case Con{CtorDef{csym, _, +fields}, rest}:
      b5k_chk_index_ctors(
        syms, tm, tname, rest,
        ct_set(CtorInfo, cm, csym, CtorInfo{
          tname, b5k_list_len(Param, fields),
          b5k_chk_param_flags(True{}, fields),
          b5k_chk_param_flags(False{}, fields),
          b5k_chk_param_tys(False{}, syms, tm, fields)
        })
      )
def b5k_chk_clear_tparams(tps: List<&2, Param>, tm: RaVec<Maybe<&2, U32>>) -> RaVec<Maybe<&2, U32>>:
  match tps:
    case Nil{}: tm
    case Con{Param{s, _, _, _}, t}: b5k_chk_clear_tparams(t, ct_set(U32, tm, s, 0))
def b5k_chk_index_types_ctors(
  +syms: SymTab, +tm: RaVec<Maybe<&2, U32>>,
  ts: List<&2, TypeDef>, cm: RaVec<Maybe<&2, CtorInfo>>
) -> RaVec<Maybe<&2, CtorInfo>>:
  match ts:
    case Nil{}: cm
    case Con{TypeDef{tsym, tps, _, cs}, rest}:
      cm2 = b5k_chk_index_ctors(syms, b5k_chk_clear_tparams(tps, tm), symtab_name(syms, tsym), cs, cm)
      b5k_chk_index_types_ctors(syms, tm, rest, cm2)
def b5k_chk_count_arrows(tm: RaVec<Maybe<&2, U32>>, e: Expr, +acc: U32) -> U32:
  match e:
    case EAll{_, body}: b5k_chk_count_arrows(tm, body, U32.add(acc, 1))
    case EVar{s}: Bool.pick(U32, b5k_chk_is_type_flag(ct_get(U32, tm, s)), acc, U32.add(acc, 16))
    case EApp{EVar{s}, _}: Bool.pick(U32, b5k_chk_is_type_flag(ct_get(U32, tm, s)), acc, U32.add(acc, 16))
    case _: U32.add(acc, 16)
def b5k_chk_merge_law_params(ps: List<&2, Param>, lps: List<&2, Param>) -> List<&2, Param>:
  match ps lps:
    case Nil{} _: Nil{}
    case Con{p, prest} Nil{}: Con{p, prest}
    case Con{Param{sym, typ, er, dup}, prest} Con{Param{_, ltyp, ler, ldup}, lrest}:
      Con{Param{sym, Maybe.or(&2, Expr, typ, ltyp), Bool.or(er, ler), Bool.or(dup, ldup)},
        b5k_chk_merge_law_params(prest, lrest)}
def b5k_chk_peel_ret(ps: List<&2, Param>, ret: Maybe<&2, Expr>) -> Maybe<&2, Expr>:
  match ps ret:
    case Con{_, prest} Some{EAll{_, body}}: b5k_chk_peel_ret(prest, Some{body})
    case _ r: r
def b5k_chk_peel_pms(ps: List<&2, Param>, ret: Maybe<&2, Expr>) -> List<&2, Param>:
  match ps ret:
    case Con{Param{sym, None{}, er, dup}, prest} Some{EAll{Param{_, ltyp, ler, ldup}, body}}:
      Con{Param{sym, ltyp, Bool.or(er, ler), Bool.or(dup, ldup)}, b5k_chk_peel_pms(prest, Some{body})}
    case Con{p, prest} Some{EAll{_, body}}: Con{p, b5k_chk_peel_pms(prest, Some{body})}
    case other _: other
def b5k_chk_apply_law_params(ps: List<&2, Param>, ld: Maybe<&2, LawDef>) -> List<&2, Param>:
  match ld:
    case None{}: ps
    case Some{LawDef{_, Nil{}, lret}}: b5k_chk_peel_pms(ps, Some{lret})
    case Some{LawDef{_, lps, _}}: b5k_chk_merge_law_params(ps, lps)
def b5k_chk_apply_law_ret(ps: List<&2, Param>, ret: Maybe<&2, Expr>, ld: Maybe<&2, LawDef>) -> Maybe<&2, Expr>:
  match ret ld:
    case None{} Some{LawDef{_, Nil{}, lret}}: b5k_chk_peel_ret(ps, Some{lret})
    case None{} Some{LawDef{_, _, lret}}: Some{lret}
    case r _: r
def b5k_chk_defs_has(ds: List<&2, Def>, +sym: U32) -> Bool:
  chk_any(~Def, ~U32, ~(s => d => U32.is_eq(chk_def_sym(d), s)), sym, ds)
type LawFreeEnv is Data:
  LawFreeEnv{syms: SymTab, tm: RaVec<Maybe<&2, U32>>, ds: List<&2, Def>, ps: List<&2, Param>}
def chk_law_sym_free(env: LawFreeEnv, +sym: U32) -> Bool:
  LawFreeEnv{syms, tm, ds, ps} = env
  in_ps = chk_any(~Param, ~U32, ~(s => p => U32.is_eq(chk_pm_sym(p), s)), sym, ps)
  known = Bool.or(b5k_chk_is_base_name(symtab_name(syms, sym)),
    Bool.or(b5k_chk_is_type_flag(ct_get(U32, tm, sym)), b5k_chk_defs_has(ds, sym)))
  Bool.and(Bool.not(in_ps), Bool.not(known))
def b5k_chk_def_rty(
  syms: SymTab, tm: RaVec<Maybe<&2, U32>>, all_ds: List<&2, Def>,
  mps: List<&2, Param>, from_law: Bool, rty: ChkTy
) -> ChkTy:
  match from_law rty:
    case True{} TEq{+a, +b, car, st}:
      has_f = chk_expr_sym_any(~LawFreeEnv, ~(e => s => chk_law_sym_free(e, s)), 4, 32n,
        LawFreeEnv{syms, tm, all_ds, mps}, [a, b])
      Bool.pick(ChkTy, has_f, b5k_chk_t0("Sigma"), TEq{a, b, car, st})
    case _ other: other
def b5k_chk_count_comp(ps: List<&2, Param>, +acc: U32) -> U32:
  match ps:
    case Con{Param{_, _, True{}, True{}}, rest}: b5k_chk_count_comp(rest, U32.add(acc, 1))
    case _: acc
def b5k_chk_count_live(ps: List<&2, Param>, +acc: U32) -> U32:
  match ps:
    case Nil{}: acc
    case Con{Param{_, _, er, _}, t}: b5k_chk_count_live(t, Bool.pick(U32, er, acc, U32.add(acc, 1)))
def b5k_chk_index_defs(
  +syms: SymTab, +tm: RaVec<Maybe<&2, U32>>, +lm: RaVec<Maybe<&2, LawDef>>,
  +all_ds: List<&2, Def>, ds: List<&2, Def>, +idx: U32, dm: RaVec<Maybe<&2, DefInfo>>
) -> RaVec<Maybe<&2, DefInfo>>:
  match ds:
    case Nil{}: dm
    case Con{Def{+dsym, +params, +ret, _, is_import, _}, rest}:
      +ld = ct_get(LawDef, lm, dsym)
      +mps = b5k_chk_apply_law_params(params, ld)
      +mret = b5k_chk_apply_law_ret(params, ret, ld)
      +fl = Bool.and(Bool.not(b5k_chk_is_some(Expr, ret)), b5k_chk_is_some(LawDef, ld))
      b5k_chk_index_defs(
        syms, tm, lm, all_ds, rest, U32.add(idx, 1),
        ct_set(DefInfo, dm, dsym, DefInfo{
          b5k_chk_count_live(mps, 0), b5k_list_len(Param, mps), b5k_chk_count_comp(mps, 0),
          chk_maybe(Expr, U32, mret, 16, e => b5k_chk_count_arrows(tm, e, 0)), is_import, idx,
          b5k_chk_param_tys(False{}, syms, tm, mps), b5k_chk_param_tys(True{}, syms, tm, mps),
          b5k_chk_param_flags(False{}, mps),
          b5k_chk_def_rty(syms, tm, all_ds, mps, fl, b5k_chk_head_opt(syms, tm, mret))
        })
      )
def b5k_chk_add_td(_u: Unit, td: TypeDef, m: RaVec<Maybe<&2, U32>>) -> RaVec<Maybe<&2, U32>>:
  TypeDef{s, _, _, _} = td
  ct_set(U32, m, s, 2)
def b5k_chk_add_ce(sy: SymTab, ce: CtorEntry, m: RaVec<Maybe<&2, CtorInfo>>) -> RaVec<Maybe<&2, CtorInfo>>:
  CtorEntry{nm, tn, ar} = ce
  ct_set_maybe(CtorInfo, symtab_lookup(sy, nm), CtorInfo{tn, ar, Nil{}, Nil{}, Nil{}}, m)
def b5k_chk_add_law(_u: Unit, l: LawDef, m: RaVec<Maybe<&2, LawDef>>) -> RaVec<Maybe<&2, LawDef>>:
  LawDef{+s, pms, ret} = l
  ct_set(LawDef, m, s, LawDef{s, pms, ret})
def b5k_chk_build_ctx(
  +types: List<&2, TypeDef>, +defs: List<&2, Def>, laws: List<&2, LawDef>, +syms: SymTab
) -> CheckCtx:
  tm_base = chk_fold(
    ~String, ~RaVec<Maybe<&2, U32>>, ~SymTab,
    ~(sy => nm => m => ct_set_maybe(U32, symtab_lookup(sy, nm), 1, m)), syms,
    [
      "Empty", "Unit", "Bool", "Cmp", "Either", "Sigma", "Pair", "Nat", "Maybe", "Result",
      "Poll", "List", "Word", "Word.Nil", "Word.Con", "U32", "F32", "Char", "String", "Array",
      "Image", "Tool", "Event", "Map", "IO", "IO.OP", "App", "File", "Socket", "Listener",
      "Window", "Audio", "Chan", "Quant", "Type", "Data", "Kind", "Set"
    ], RVEmpty{}
  )
  tm0 = chk_fold(~Def, ~RaVec<Maybe<&2, U32>>, ~Unit, ~(_ => d => m => ct_set(U32, m, chk_def_sym(d), 0)), Unit{},
    defs, tm_base)
  +tm = chk_fold(~TypeDef, ~RaVec<Maybe<&2, U32>>, ~Unit, ~b5k_chk_add_td, Unit{}, types, tm0)
  cm0 = chk_fold(~CtorEntry, ~RaVec<Maybe<&2, CtorInfo>>, ~SymTab, ~b5k_chk_add_ce, syms,
    b5k_chk_base_ctors(), RVEmpty{})
  cm = b5k_chk_index_types_ctors(syms, tm, types, cm0)
  +lm = chk_fold(~LawDef, ~RaVec<Maybe<&2, LawDef>>, ~Unit, ~b5k_chk_add_law, Unit{}, laws, RVEmpty{})
  dasts = chk_fold(~Def, ~RaVec<Maybe<&2, Def>>, ~Unit, ~(_ => +d => m => ct_set(Def, m, chk_def_sym(d), d)), Unit{},
    defs, RVEmpty{})
  CheckCtx{syms, tm, cm, b5k_chk_index_defs(syms, tm, lm, defs, defs, 1, RVEmpty{}), lm, dasts, types}

# Context Lookup, Local Environment & Affine Use-Set Algebra (Closure-Free)
def b5k_chk_find_tdef_go(
  ts: List<&2, TypeDef>, hit: Bool, td: Maybe<&2, TypeDef>,
  +syms: SymTab, +by_sym: Bool, +sym: U32, +nm: String
) -> Maybe<&2, TypeDef>:
  match ts hit:
    case _ True{}: td
    case Nil{} False{}: None{}
    case Con{TypeDef{+s, ps, d, cs}, t} False{}:
      eq = Bool.pick(Bool, by_sym, U32.is_eq(s, sym), String.eq(symtab_name(syms, s), nm))
      b5k_chk_find_tdef_go(t, eq, Some{TypeDef{s, ps, d, cs}}, syms, by_sym, sym, nm)
def b5k_chk_find_tdef(
  +syms: SymTab, ts: List<&2, TypeDef>, +by_sym: Bool, +sym: U32, +nm: String
) -> Maybe<&2, TypeDef>:
  b5k_chk_find_tdef_go(ts, False{}, None{}, syms, by_sym, sym, nm)
def b5k_chk_dot_suffix(s: String, acc: String) -> String:
  match s:
    case SNil{}: acc
    case SCon{+c, t}: b5k_chk_dot_suffix(t, Bool.pick(String, U32.is_eq(Char.to_u32(c), 46), SNil{}, SCon{c, acc}))
def b5k_chk_ct_get_opt(ctors: RaVec<Maybe<&2, CtorInfo>>, ms: Maybe<&2, U32>) -> Maybe<&2, CtorInfo>:
  match ms:
    case None{}: None{}
    case Some{s2}: ct_get(CtorInfo, ctors, s2)
def b5k_chk_lookup_ctor_d(
  md: Maybe<&2, DefInfo>, +syms: SymTab, ctors: RaVec<Maybe<&2, CtorInfo>>, sym: U32
) -> Maybe<&2, CtorInfo>:
  match md:
    case None{}: None{}
    case Some{_}:
      b5k_chk_ct_get_opt(ctors,
        symtab_lookup(syms, String.reverse(b5k_chk_dot_suffix(symtab_name(syms, sym), SNil{}))))
def b5k_chk_lookup_ctor_k(
  m: Maybe<&2, CtorInfo>, syms: SymTab, ctors: RaVec<Maybe<&2, CtorInfo>>,
  defs: RaVec<Maybe<&2, DefInfo>>, +sym: U32
) -> Maybe<&2, CtorInfo>:
  match m:
    case Some{ci}: Some{ci}
    case None{}: b5k_chk_lookup_ctor_d(ct_get(DefInfo, defs, sym), syms, ctors, sym)
def b5k_chk_lookup_ctor(ctx: CheckCtx, +sym: U32) -> Maybe<&2, CtorInfo>:
  CheckCtx{syms, _, +ctors, defs, _, _, _} = ctx
  b5k_chk_lookup_ctor_k(ct_get(CtorInfo, ctors, sym), syms, ctors, defs, sym)
def b5k_chk_or_base(hit: Bool, syms: SymTab, sym: U32) -> Bool:
  match hit:
    case True{}: True{}
    case False{}: b5k_chk_is_base_name(symtab_name(syms, sym))
def b5k_chk_known_global_k(
  md: Maybe<&2, DefInfo>, syms: SymTab, types: RaVec<Maybe<&2, U32>>,
  ctors: RaVec<Maybe<&2, CtorInfo>>, laws: RaVec<Maybe<&2, LawDef>>, +sym: U32
) -> Bool:
  match md:
    case Some{_}: True{}
    case None{}:
      hit = Bool.or(
        b5k_chk_is_some(CtorInfo, ct_get(CtorInfo, ctors, sym)),
        Bool.or(b5k_chk_is_some(U32, ct_get(U32, types, sym)), b5k_chk_is_some(LawDef, ct_get(LawDef, laws, sym)))
      )
      b5k_chk_or_base(hit, syms, sym)
def b5k_chk_is_known_global(ctx: CheckCtx, +sym: U32) -> Bool:
  CheckCtx{syms, types, ctors, defs, laws, _, _} = ctx
  b5k_chk_known_global_k(ct_get(DefInfo, defs, sym), syms, types, ctors, laws, sym)
def b5k_chk_env_lookup_go(
  env: List<&2, VarBind>, hit: Bool, d: Bool, er: Bool, loc: Bool, t: ChkTy, +sym: U32
) -> LookupRes:
  match env hit:
    case _ True{}: LFound{d, er, loc, t}
    case Nil{} False{}: LNotFound{}
    case Con{VarBind{s, d2, er2, loc2, _, t2}, rest} False{}:
      b5k_chk_env_lookup_go(rest, U32.is_eq(s, sym), d2, er2, loc2, t2, sym)
def b5k_chk_env_lookup(env: List<&2, VarBind>, +sym: U32) -> LookupRes:
  b5k_chk_env_lookup_go(env, False{}, False{}, False{}, False{}, TAny{}, sym)
def b5k_chk_uses_sum_step(dup_hit: Bool, fn_name: String, h: U32, rest_res: ExprRes) -> ExprRes:
  match dup_hit rest_res:
    case True{} _: ExprErr{"check: " ++ fn_name ++ ": affine variable consumed more than allowed"}
    case False{} ExprErr{err}: ExprErr{err}
    case False{} ExprOk{us}: ExprOk{Con{h, us}}
def b5k_chk_uses_sum(+fn_name: String, u1: List<&2, U32>, +u2: List<&2, U32>) -> ExprRes:
  match u1:
    case Nil{}: ExprOk{u2}
    case Con{+h, t}: b5k_chk_uses_sum_step(b5k_chk_u32_mem(u2, h), fn_name, h, b5k_chk_uses_sum(fn_name, t, u2))
def b5k_chk_uses_union(u1: List<&2, U32>, +u2: List<&2, U32>, +acc: List<&2, U32>) -> List<&2, U32>:
  match u1:
    case Nil{}: acc
    case Con{+h, t}: b5k_chk_uses_union(t, u2, Bool.pick(List<&2, U32>, b5k_chk_u32_mem(u2, h), acc, Con{h, acc}))
def b5k_chk_binds_mem(bs: List<&2, VarBind>, +sym: U32) -> Bool:
  match bs:
    case Nil{}: False{}
    case Con{VarBind{s, _, _, _, _, _}, t}: Bool.or(U32.is_eq(s, sym), b5k_chk_binds_mem(t, sym))
def b5k_chk_uses_strip(+bs: List<&2, VarBind>, u: List<&2, U32>, +acc: List<&2, U32>) -> List<&2, U32>:
  match u:
    case Nil{}: acc
    case Con{+h, t}: b5k_chk_uses_strip(bs, t, Bool.pick(List<&2, U32>, b5k_chk_binds_mem(bs, h), acc, Con{h, acc}))
def b5k_chk_unfold_ty_m(md: Maybe<&2, Def>, orig: Expr) -> Expr:
  match md:
    case Some{Def{_, Nil{}, _, body, False{}, _}}: body
    case _: orig
def b5k_chk_unfold_ty(dasts: RaVec<Maybe<&2, Def>>, e: Expr) -> Expr:
  match e:
    case EApp{EVar{+s}, Nil{}}: b5k_chk_unfold_ty_m(ct_get(Def, dasts, s), EApp{EVar{s}, Nil{}})
    case other: other
def b5k_chk_param_ty(
  syms: SymTab, types: RaVec<Maybe<&2, U32>>, dasts: RaVec<Maybe<&2, Def>>, m: Maybe<&2, Expr>
) -> ChkTy:
  match m:
    case None{}: TAny{}
    case Some{e}: b5k_chk_head_expr(syms, types, b5k_chk_unfold_ty(dasts, e))
def b5k_chk_params_binds(+ctx: CheckCtx, +all_dup: Bool, ps: List<&2, Param>) -> List<&2, VarBind>:
  CheckCtx{+syms, +types, _, _, _, +dasts, _} = ctx
  match ps:
    case Nil{}: Nil{}
    case Con{Param{+sym, typ, +erased, +dup}, rest}:
      +tail = b5k_chk_params_binds(ctx, all_dup, rest)
      dup_b = Bool.or(all_dup, Bool.or(erased, dup))
      er_b = Bool.and(erased, Bool.and(Bool.not(dup), Bool.not(all_dup)))
      Bool.pick(
        List<&2, VarBind>, String.eq(symtab_name(syms, sym), "_"), tail,
        Con{VarBind{sym, dup_b, er_b, False{}, Bool.and(erased, dup), b5k_chk_param_ty(syms, types, dasts, typ)},
          tail}
      )

# Pattern Checking & Binding Extraction (with Parametric Ctor Field Propagation)
def b5k_chk_env_all_dup(env: List<&2, VarBind>) -> List<&2, VarBind>:
  match env:
    case Nil{}: Nil{}
    case Con{VarBind{s, _, _, loc, ic, t}, rest}:
      Con{VarBind{s, True{}, False{}, loc, ic, t}, b5k_chk_env_all_dup(rest)}
def b5k_chk_env_only_comp(env: List<&2, VarBind>) -> List<&2, VarBind>:
  match env:
    case Nil{}: Nil{}
    case Con{VarBind{s, _, _, loc, True{}, t}, rest}:
      Con{VarBind{s, True{}, False{}, loc, True{}, t}, b5k_chk_env_only_comp(rest)}
    case Con{_, rest}: b5k_chk_env_only_comp(rest)
def b5k_chk_binds_mark_local(+er_bind: Bool, +is_loc: Bool, bs: List<&2, VarBind>) -> List<&2, VarBind>:
  match bs:
    case Nil{}: Nil{}
    case Con{VarBind{s, d, _, _, ic, t}, rest}:
      Con{VarBind{s, Bool.or(d, er_bind), er_bind, is_loc, ic, t}, b5k_chk_binds_mark_local(er_bind, is_loc, rest)}
def b5k_chk_ctor_ok(info: Maybe<&2, CtorInfo>, nargs: U32, goal: ChkTy) -> Bool:
  match info goal:
    case None{} _: False{}
    case Some{CtorInfo{+tname, arity, _, _, _}} TCon{+g, _}:
      sp = Bool.or(Bool.and(String.eq(tname, "Sigma"), String.eq(g, "Pair")),
        Bool.and(String.eq(tname, "Pair"), String.eq(g, "Sigma")))
      wd = Bool.and(String.eq(g, "Word"), Bool.or(String.eq(tname, "Word.Nil"), String.eq(tname, "Word.Con")))
      Bool.and(U32.is_eq(nargs, arity), Bool.or(String.eq(tname, g), Bool.or(sp, wd)))
    case Some{CtorInfo{_, _, _, _, _}} TFun{_, _, _, _}: False{}
    case Some{CtorInfo{_, _, _, _, _}} TEq{_, _, _, _}: False{}
    case Some{CtorInfo{_, arity, _, _, _}} _: U32.is_eq(nargs, arity)
def b5k_chk_ctor_flags(is_dup: Bool, info: Maybe<&2, CtorInfo>) -> List<&2, Bool>:
  match info:
    case None{}: Nil{}
    case Some{CtorInfo{_, _, fdups, fers, _}}: Bool.pick(List<&2, Bool>, is_dup, fdups, fers)
def b5k_chk_base_fgoals(+tname: String, +arity: U32, goal: ChkTy) -> List<&2, ChkTy>:
  match goal:
    case TCon{_, Con{+a, Nil{}}}:
      Bool.pick(
        List<&2, ChkTy>, Bool.and(String.eq(tname, "Array"), U32.is_eq(arity, 1)), [a],
        Bool.pick(
          List<&2, ChkTy>, Bool.and(String.eq(tname, "Array"), U32.is_eq(arity, 2)),
          [TCon{"Array", [a]}, TCon{"Array", [a]}], Nil{}
        )
      )
    case TCon{_, Con{+a, Con{+b, Nil{}}}}:
      Bool.pick(
        List<&2, ChkTy>, Bool.and(String.eq(tname, "Maybe"), U32.is_eq(arity, 1)), [b],
        Bool.pick(
          List<&2, ChkTy>, Bool.and(String.eq(tname, "List"), U32.is_eq(arity, 2)), [b, TCon{"List", [a, b]}],
          Bool.pick(
            List<&2, ChkTy>, Bool.and(Bool.or(String.eq(tname, "Pair"), String.eq(tname, "Sigma")),
              U32.is_eq(arity, 2)),
            [a, b], Nil{}
          )
        )
      )
    case _: Nil{}
def b5k_chk_ctor_fgoals(info: Maybe<&2, CtorInfo>, goal: ChkTy) -> List<&2, ChkTy>:
  match info:
    case None{}: Nil{}
    case Some{CtorInfo{tname, arity, _, _, Nil{}}}: b5k_chk_base_fgoals(tname, arity, goal)
    case Some{CtorInfo{_, _, _, _, ftys}}: ftys
def b5k_chk_pair_goals(goal: ChkTy) -> List<&2, ChkTy>:
  match goal:
    case TCon{+h, Con{a, Con{b, Nil{}}}}:
      Bool.pick(List<&2, ChkTy>, Bool.or(String.eq(h, "Sigma"), String.eq(h, "Pair")), [a, b], Nil{})
    case _: Nil{}
def b5k_chk_list_elem_goals(es: List<&2, Expr>, goal: ChkTy) -> List<&2, ChkTy>:
  match goal:
    case TCon{_, Con{_, Con{TAny{}, Nil{}}}}: Nil{}
    case TCon{h, Con{_, Con{a, Nil{}}}}:
      Bool.pick(List<&2, ChkTy>, String.eq(h, "List"), chk_rep(ChkTy, U32.to_nat(b5k_list_len(Expr, es)), a), Nil{})
    case _: Nil{}
def b5k_chk_zip_pats(
  ps: List<&2, Pat>, +ds: List<&2, Bool>, +ts: List<&2, ChkTy>, +def_dup: Bool
) -> List<&2, PatItem>:
  match ps:
    case Nil{}: Nil{}
    case Con{p, pt}:
      Con{
        PatItem{p, Bool.or(chk_hd(Bool, ds, False{}), def_dup), chk_hd(ChkTy, ts, TAny{})},
        b5k_chk_zip_pats(pt, chk_tl(Bool, ds), chk_tl(ChkTy, ts), def_dup)
      }
def b5k_chk_lr_is_dup(lr: LookupRes) -> Bool:
  match lr:
    case LFound{d, _, _, _}: d
    case LNotFound{}: False{}
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
def b5k_chk_scrut_sym(e: Expr) -> U32:
  match e:
    case EVar{s}: U32.add(s, 1)
    case EAnn{v, _}: b5k_chk_scrut_sym(v)
    case _: 0
def b5k_chk_pats_all_dup(ps: List<&2, Pat>) -> Bool:
  match ps:
    case Con{PVar{_, d}, Nil{}}: d
    case Con{PVar{_, d}, t}: Bool.and(d, b5k_chk_pats_all_dup(t))
    case _: False{}
def b5k_chk_wild_strip(ps: List<&2, Pat>, ss: List<&2, U32>) -> List<&2, VarBind>:
  match ps ss:
    case Con{PWild{}, pt} Con{+s, st}:
      +rest = b5k_chk_wild_strip(pt, st)
      Bool.pick(List<&2, VarBind>, U32.is_zero(s), rest,
        Con{VarBind{U32.sub(s, 1), False{}, False{}, False{}, False{}, TAny{}}, rest})
    case Con{_, pt} Con{_, st}: b5k_chk_wild_strip(pt, st)
    case _ _: Nil{}
def b5k_chk_redup_binds(ps: List<&2, Pat>, ss: List<&2, U32>, ts: List<&2, ChkTy>) -> List<&2, VarBind>:
  match ps ss ts:
    case Con{PCtr{_, fs}, pt} Con{+s, st} Con{ty, tt}:
      +rest = b5k_chk_redup_binds(pt, st, tt)
      ok = Bool.and(b5k_chk_pats_all_dup(fs), Bool.not(U32.is_zero(s)))
      Bool.pick(List<&2, VarBind>, ok, Con{VarBind{U32.sub(s, 1), True{}, False{}, False{}, False{}, ty}, rest}, rest)
    case Con{_, pt} Con{_, st} Con{_, tt}: b5k_chk_redup_binds(pt, st, tt)
    case _ _ _: Nil{}
def b5k_chk_pats(
  fuel: Nat, +ctx: CheckCtx, +fn_name: String, ps: List<&2, PatItem>, acc: List<&2, VarBind>
) -> PatRes:
  match fuel ps:
    case 0n _: PatOk{b5k_list_rev(VarBind, acc)}
    case _ Nil{}: PatOk{b5k_list_rev(VarBind, acc)}
    case 1n+f Con{PatItem{PVar{sym, dup}, inh, ty}, rest}:
      b5k_chk_pats(f, ctx, fn_name, rest, Con{VarBind{sym, Bool.or(dup, inh), False{}, False{}, False{}, ty}, acc})
    case 1n+f Con{PatItem{PCtr{sym, +fields}, inh, +sty}, rest}:
      +info = b5k_chk_lookup_ctor(ctx, sym)
      z = b5k_chk_zip_pats(fields, b5k_chk_ctor_flags(True{}, info), b5k_chk_ctor_fgoals(info, sty), inh)
      Bool.pick(
        PatRes, b5k_chk_ctor_ok(info, b5k_list_len(Pat, fields), sty),
        b5k_chk_pats(f, ctx, fn_name, b5k_list_app(PatItem, z, rest), acc),
        PatErr{"check: " ++ fn_name ++ ": constructor does not belong to goal or field count differs"}
      )
    case 1n+f Con{PatItem{PPair{fst, snd}, +inh, sty}, rest}:
      +pgs = b5k_chk_pair_goals(sty)
      b5k_chk_pats(
        f, ctx, fn_name,
        Con{PatItem{fst, inh, chk_hd(ChkTy, pgs, TAny{})},
          Con{PatItem{snd, inh, chk_hd(ChkTy, chk_tl(ChkTy, pgs), TAny{})}, rest}},
        acc
      )
    case 1n+f Con{PatItem{PList{elems}, inh, _}, rest}:
      b5k_chk_pats(f, ctx, fn_name, b5k_list_app(PatItem, b5k_chk_zip_pats(elems, Nil{}, Nil{}, inh), rest), acc)
    case 1n+f Con{PatItem{_, _, _}, rest}: b5k_chk_pats(f, ctx, fn_name, rest, acc)

# Goal Extraction, Call Signature Lookup & Shallow Parametric Type Inference
def b5k_chk_goal_expr(+ctx: CheckCtx, e: Expr) -> ChkTy:
  CheckCtx{syms, types, _, _, _, dasts, _} = ctx
  b5k_chk_head_expr(syms, types, b5k_chk_unfold_ty(dasts, e))
def b5k_chk_call_builtin_bad(is_unk: Bool, +nm: String) -> Bool:
  match is_unk:
    case False{}: False{}
    case True{}: U32.is_gt(b5k_chk_builtin_tag(nm, 1), 0)
def b5k_chk_arity_err(bad: Bool, ctx: CheckCtx, fn_name: String, sym: U32) -> String:
  match bad:
    case False{}: ""
    case True{}: "check: " ++ fn_name ++ ": call arity mismatch for " ++ b5k_chk_sym_name(ctx, sym)
def b5k_chk_call_def(info: Maybe<&2, DefInfo>, +ctx: CheckCtx, fn_name: String, +sym: U32, +nargs: U32) -> String:
  match info:
    case None{}:
      +nm = b5k_chk_sym_name(ctx, sym)
      is_unk = Bool.and(U32.is_gt(nargs, 1), U32.is_zero(b5k_chk_builtin_tag(nm, nargs)))
      b5k_chk_arity_err(b5k_chk_call_builtin_bad(is_unk, nm), ctx, fn_name, sym)
    case Some{DefInfo{arity, total_arity, _, ret_arr, _, _, _, _, _, _}}:
      raw_bad = Bool.or(
        U32.is_gt(nargs, U32.add(total_arity, ret_arr)),
        Bool.and(U32.is_zero(nargs), Bool.not(U32.is_zero(arity)))
      )
      bad = Bool.and(
        raw_bad,
        Bool.not(Bool.and(U32.is_eq(nargs, 2), String.eq(b5k_chk_sym_name(ctx, sym), "String.append")))
      )
      b5k_chk_arity_err(bad, ctx, fn_name, sym)
def b5k_chk_call_lookup(lr: LookupRes, +ctx: CheckCtx, fn_name: String, +sym: U32, nargs: U32) -> String:
  match lr ctx:
    case LNotFound{} CheckCtx{_, _, _, defs, _, _, _}: b5k_chk_call_def(ct_get(DefInfo, defs, sym), ctx, fn_name,
      sym, nargs)
    case _ _: ""
def b5k_chk_peel_tfun(n: Nat, ty: ChkTy, acc_t: List<&2, ChkTy>, acc_e: List<&2, Bool>) -> CallSig:
  match n ty:
    case 0n r: CallSig{b5k_list_rev(ChkTy, acc_t), b5k_list_rev(Bool, acc_e), r}
    case 1n+p TFun{_, er, a, r}: b5k_chk_peel_tfun(p, r, Con{a, acc_t}, Con{er, acc_e})
    case _ _: b5k_chk_sig_none()
def b5k_chk_sig_args(cs: CallSig) -> List<&2, ChkTy>:
  CallSig{atys, _, _} = cs
  atys
def b5k_chk_sig_ers(cs: CallSig) -> List<&2, Bool>:
  CallSig{_, aers, _} = cs
  aers
def b5k_chk_sig_ret(cs: CallSig) -> ChkTy:
  CallSig{_, _, rty} = cs
  rty
def b5k_chk_def_sig_over_k(ptys: List<&2, ChkTy>, pers: List<&2, Bool>, cs: CallSig) -> CallSig:
  CallSig{at2, ae2, r2} = cs
  CallSig{b5k_list_app(ChkTy, ptys, at2), b5k_list_app(Bool, pers, ae2), r2}
def b5k_chk_def_sig_k(
  k: U32, syms: SymTab, sym: U32, +nargs: U32, total_arity: U32,
  ptys: List<&2, ChkTy>, ltys: List<&2, ChkTy>, +pers: List<&2, Bool>, rty: ChkTy
) -> CallSig:
  match k nargs:
    case 1 2:
      chk_if(
        CallSig, String.eq(symtab_name(syms, sym), "String.append"),
        _ => b5k_chk_sig2("String", "String", "String"), _ => CallSig{ptys, pers, rty}
      )
    case 1 _: CallSig{ptys, pers, rty}
    case 2 _: CallSig{ltys, Nil{}, rty}
    case 3 _:
      b5k_chk_def_sig_over_k(ptys, pers,
        b5k_chk_peel_tfun(U32.to_nat(U32.sub(nargs, total_arity)), rty, Nil{}, Nil{}))
    case _ _:
      Bool.pick(
        CallSig, Bool.and(U32.is_gt(nargs, 0), U32.is_lt(nargs, total_arity)),
        CallSig{Nil{}, pers, TFun{False{}, chk_nth(Bool, U32.to_nat(nargs), pers, False{}), TAny{}, TAny{}}},
        b5k_chk_sig_none()
      )
def b5k_chk_def_sig(info: Maybe<&2, DefInfo>, syms: SymTab, sym: U32, +nargs: U32, +nt: U32) -> CallSig:
  match info:
    case None{}: b5k_chk_builtin_sig(symtab_name(syms, sym), nargs)
    case Some{DefInfo{+arity, +total_arity, _, _, _, _, ptys, ltys, pers, rty}}:
      k = Bool.pick(
        U32, U32.is_eq(nargs, total_arity), 1,
        Bool.pick(U32, Bool.and(U32.is_eq(nargs, arity), U32.is_zero(nt)), 2,
          Bool.pick(U32, U32.is_gt(nargs, total_arity), 3, 0))
      )
      b5k_chk_def_sig_k(k, syms, sym, nargs, total_arity, ptys, ltys, pers, rty)
def b5k_chk_call_sig_lookup(lr: LookupRes, ctx: CheckCtx, +sym: U32, nargs: U32, nt: U32) -> CallSig:
  match lr ctx:
    case LNotFound{} CheckCtx{syms, _, _, defs, _, _, _}: b5k_chk_def_sig(ct_get(DefInfo, defs, sym), syms, sym,
      nargs, nt)
    case LFound{_, _, _, TFun{d, er, a, r}} _: b5k_chk_peel_tfun(U32.to_nat(nargs), TFun{d, er, a, r}, Nil{}, Nil{})
    case _ _: b5k_chk_sig_none()
def b5k_chk_call_sig(+ctx: CheckCtx, env: List<&2, VarBind>, fun: Expr, nargs: U32, nt: U32) -> CallSig:
  match fun:
    case EVar{+sym}: b5k_chk_call_sig_lookup(b5k_chk_env_lookup(env, sym), ctx, sym, nargs, nt)
    case ERef{+sym}: b5k_chk_call_sig_lookup(b5k_chk_env_lookup(env, sym), ctx, sym, nargs, nt)
    case EAnn{_, typ}: b5k_chk_peel_tfun(U32.to_nat(nargs), b5k_chk_goal_expr(ctx, typ), Nil{}, Nil{})
    case _: b5k_chk_sig_none()
def b5k_chk_lr_typ(lr: LookupRes) -> ChkTy:
  match lr:
    case LFound{_, _, _, t}: t
    case LNotFound{}: TAny{}
def b5k_chk_is_cmp_expr(e: Expr) -> Bool:
  match e:
    case EOp{+op, a, b}:
      Bool.or(
        U32.is_ge(op, 20),
        Bool.and(Bool.or(U32.is_eq(op, B5K_OP_AND()), U32.is_eq(op, B5K_OP_OR())),
          Bool.or(b5k_chk_is_cmp_expr(a), b5k_chk_is_cmp_expr(b)))
      )
    case _: False{}
def b5k_chk_ann_cmp_ty(e: Expr, def_ty: ChkTy) -> ChkTy:
  match e:
    case EOp{+op, a, b}:
      is_log = Bool.and(
        Bool.or(U32.is_eq(op, B5K_OP_AND()), U32.is_eq(op, B5K_OP_OR())),
        Bool.or(b5k_chk_is_cmp_expr(a), b5k_chk_is_cmp_expr(b))
      )
      Bool.pick(
        ChkTy, U32.is_ge(op, 22), b5k_chk_t0("Bool"),
        Bool.pick(ChkTy, U32.is_ge(op, 20), TAny{}, Bool.pick(ChkTy, is_log, b5k_chk_t0("Bool"), def_ty))
      )
    case _: def_ty
def b5k_chk_eq_sig_k(hit: Bool, kind: U32, ctx: CheckCtx, +a: Expr, +b: Expr, +c: Expr) -> Maybe<&2, CallSig>:
  match hit kind:
    case False{} _: None{}
    case True{} 0: Some{CallSig{[TErased{}, b5k_chk_t0("Empty")], [True{}, False{}], b5k_chk_goal_expr(ctx, a)}}
    case True{} 1:
      Some{CallSig{[TErased{}, TAny{}, TAny{}, TEq{a, b, TAny{}, False{}}], [True{}, True{}, True{}, False{}],
        TEq{b, a, TAny{}, False{}}}}
    case True{} _:
      Some{CallSig{
        [TErased{}, TAny{}, TAny{}, TAny{}, TEq{a, b, TAny{}, False{}}, TEq{b, c, TAny{}, False{}}],
        [True{}, True{}, True{}, True{}, False{}, False{}], TEq{a, c, TAny{}, False{}}
      }}
def b5k_chk_eq_call_sig(+ctx: CheckCtx, fun: Expr, args: List<&2, Expr>) -> Maybe<&2, CallSig>:
  match fun args:
    case EVar{sym} Con{t, Con{_, Nil{}}}:
      b5k_chk_eq_sig_k(String.eq(b5k_chk_sym_name(ctx, sym), "Empty.absurd"), 0, ctx, t, EUnit{}, EUnit{})
    case EVar{sym} Con{_, Con{a, Con{b, Con{_, Nil{}}}}}:
      b5k_chk_eq_sig_k(String.eq(b5k_chk_sym_name(ctx, sym), "Equal.sym"), 1, ctx, a, b, EUnit{})
    case EVar{sym} Con{_, Con{a, Con{b, Con{c, Con{_, Con{_, Nil{}}}}}}}:
      b5k_chk_eq_sig_k(String.eq(b5k_chk_sym_name(ctx, sym), "Equal.trans"), 2, ctx, a, b, c)
    case _ _: None{}
def b5k_chk_ci_tn(m: Maybe<&2, CtorInfo>) -> String:
  match m:
    case None{}: ""
    case Some{CtorInfo{tn, _, _, _, _}}: tn
def b5k_chk_infer_head(+ctx: CheckCtx, +env: List<&2, VarBind>, e: Expr) -> ChkTy:
  match e:
    case EFlt{_}: b5k_chk_t0("F32")
    case EChr{_}: b5k_chk_t0("Char")
    case EStr{_}: b5k_chk_t0("String")
    case EUnit{}: b5k_chk_t0("Unit")
    case EPair{_, _}: b5k_chk_t0("Sigma")
    case EList{_}: b5k_chk_t0("List")
    case EArrNew{_}: b5k_chk_t0("Array")
    case EVar{sym}: b5k_chk_lr_typ(b5k_chk_env_lookup(env, sym))
    case ECtr{sym, _}:
      +tn = b5k_chk_ci_tn(b5k_chk_lookup_ctor(ctx, sym))
      Bool.pick(ChkTy, String.is_empty(tn), TAny{}, b5k_chk_t0(tn))
    case EAnn{val, typ}: b5k_chk_ann_cmp_ty(val, b5k_chk_goal_expr(ctx, typ))
    case EOp{op, _, _}: Bool.pick(ChkTy, U32.is_ge(op, 20), b5k_chk_t0("Bool"), TAny{})
    case EApp{+fun, +args}:
      cs = Maybe.default(&2, CallSig, b5k_chk_eq_call_sig(ctx, fun, args),
        b5k_chk_call_sig(ctx, env, fun, b5k_list_len(Expr, args), 0))
      b5k_chk_sig_ret(cs)
    case _: TAny{}

# Expression Checker Helpers (Closure-Free)
def b5k_chk_def_calls(fs: U32, d: Def) -> Bool:
  Def{_, _, _, body, imp, _} = d
  Bool.and(Bool.not(imp), chk_expr_sym_any(~U32, ~(tg => s => U32.is_eq(s, tg)), 1, 128n, fs, [body]))
def b5k_chk_is_fwd_ref(+ctx: CheckCtx, +cur_idx: U32, +fn_name: String, +sym: U32) -> Bool:
  CheckCtx{syms, _, _, defs, laws, dasts, _} = ctx
  cand = Bool.and(U32.is_gt(cur_idx, 0), U32.is_gt(b5k_chk_di_u32(0, ct_get(DefInfo, defs, sym)), cur_idx))
  chk_if(
    Bool, cand,
    _ => Bool.and(
      Bool.not(String.contains(fn_name, ".")),
      chk_maybe(
        LawDef, Bool, ct_get(LawDef, laws, sym), True{},
        _ => chk_maybe(
          U32, Bool, symtab_lookup(syms, fn_name), True{},
          fs => Bool.not(chk_maybe(Def, Bool, ct_get(Def, dasts, sym), False{}, d => b5k_chk_def_calls(fs, d)))
        )
      )
    ),
    _ => False{}
  )
def b5k_chk_is_er_goal(t: ChkTy) -> Bool:
  U32.is_eq(b5k_chk_ty_tag(t), 2)
def b5k_chk_is_er_or_quant(t: ChkTy) -> Bool:
  +tg = b5k_chk_ty_tag(t)
  Bool.or(U32.is_eq(tg, 2), Bool.or(U32.is_eq(tg, 3), U32.is_eq(tg, 9)))
def b5k_chk_global_def_ty_m(syms: SymTab, sym: U32, di: Maybe<&2, DefInfo>) -> ChkTy:
  match di:
    case Some{DefInfo{_, total_arity, _, _, _, _, Con{p0, Nil{}}, _, +pers, rty}}:
      +e0 = chk_nth(Bool, 0n, pers, False{})
      Bool.pick(ChkTy, U32.is_eq(total_arity, 1), TFun{False{}, e0, p0, rty}, TFun{False{}, e0, TAny{}, TAny{}})
    case Some{DefInfo{_, total_arity, _, _, _, _, _, _, +pers, rty}}:
      +e0 = chk_nth(Bool, 0n, pers, False{})
      Bool.pick(ChkTy, U32.is_gt(total_arity, 0), TFun{False{}, e0, TAny{}, TAny{}}, rty)
    case None{}:
      +cs = b5k_chk_builtin_sig(symtab_name(syms, sym), 1)
      +at = b5k_chk_sig_args(cs)
      Bool.pick(ChkTy, U32.is_eq(b5k_list_len(ChkTy, at), 1),
        TFun{False{}, False{}, chk_hd(ChkTy, at, TAny{}), b5k_chk_sig_ret(cs)}, TAny{})
def b5k_chk_pms_has_quant(+syms: SymTab, ps: List<&2, Param>) -> Bool:
  match ps:
    case Nil{}: False{}
    case Con{Param{_, None{}, _, _}, _}: True{}
    case Con{Param{_, Some{EVar{s}}, _, _}, t}: Bool.or(String.eq(symtab_name(syms, s), "Quant"),
      b5k_chk_pms_has_quant(syms, t))
    case Con{_, t}: b5k_chk_pms_has_quant(syms, t)
def b5k_chk_td_is_nd_one(syms: SymTab, td: TypeDef) -> Bool:
  TypeDef{_, ps, is_d, _} = td
  Bool.and(Bool.not(is_d), Bool.not(b5k_chk_pms_has_quant(syms, ps)))
def b5k_chk_td_is_nd(+syms: SymTab, tdefs: List<&2, TypeDef>, by_sym: Bool, sym: U32, nm: String) -> Bool:
  chk_maybe(TypeDef, Bool, b5k_chk_find_tdef(syms, tdefs, by_sym, sym, nm), False{},
    td => b5k_chk_td_is_nd_one(syms, td))
def b5k_chk_var_er(bad_er: Bool, ctx: CheckCtx, +fn_name: String, vty: ChkTy, goal: ChkTy,
  ok_res: ExprRes) -> ExprRes:
  match bad_er:
    case True{}: ExprErr{"check: " ++ fn_name ++ ": erased variable used in live position"}
    case False{}: b5k_chk_expect(ctx, fn_name, vty, goal, ok_res)
def b5k_chk_var_goal_err(goal: ChkTy, +ctx: CheckCtx, +fn_name: String, +sym: U32) -> String:
  match goal ctx:
    case TAny{} _: ""
    case TTyVar{_} _: ""
    case TErased{} CheckCtx{syms, _, _, _, _, _, _}:
      is_bare = b5k_chk_str_match(
        False{}, ["List", "Maybe", "Either", "Result", "Array", "Map", "Sigma", "Pair", "Poll", "Chan"],
        symtab_name(syms, sym)
      )
      chk_err_if(is_bare, fn_name, ": bare parametric datatype requires '<...>'")
    case TCon{+g, as} CheckCtx{+syms, _, _, _, _, _, tdefs}:
      Bool.pick(
        String, b5k_chk_is_universe(symtab_name(syms, sym)), b5k_chk_head_err(fn_name, TErased{}, TCon{g, as}),
        chk_err_if(
          Bool.and(String.eq(g, "#Data"), b5k_chk_td_is_nd(syms, tdefs, True{}, sym, "")),
          fn_name, ": Type-kinded datatype does not fit Data: " ++ symtab_name(syms, sym)
        )
      )
    case g CheckCtx{syms, _, _, _, _, _, _}:
      Bool.pick(String, b5k_chk_is_universe(symtab_name(syms, sym)), b5k_chk_head_err(fn_name, TErased{}, g), "")
def b5k_chk_known_res(known: Bool, ctx: CheckCtx, fn_name: String, sym: U32, is_ref: Bool) -> ExprRes:
  match known:
    case True{}: ExprOk{Nil{}}
    case False{}:
      kind = Bool.pick(String, is_ref, ": unbound reference: ", ": unbound variable: ")
      ExprErr{"check: " ++ fn_name ++ kind ++ b5k_chk_sym_name(ctx, sym)}
def b5k_chk_var_nf_k(
  gerr: String, fwd: Bool, goal: ChkTy, +ctx: CheckCtx, +fn_name: String, +sym: U32, is_ref: Bool
) -> ExprRes:
  match gerr fwd goal ctx:
    case SCon{c, t} _ _ _: ExprErr{SCon{c, t}}
    case SNil{} True{} _ _:
      ExprErr{"check: " ++ fn_name ++ ": forward reference to later def: " ++ b5k_chk_sym_name(ctx, sym)}
    case SNil{} False{} TAny{} _: b5k_chk_known_res(b5k_chk_is_known_global(ctx, sym), ctx, fn_name, sym, is_ref)
    case SNil{} False{} g CheckCtx{syms, _, _, defs, _, _, _}:
      res = b5k_chk_known_res(b5k_chk_is_known_global(ctx, sym), ctx, fn_name, sym, is_ref)
      b5k_chk_expect(ctx, fn_name, b5k_chk_global_def_ty_m(syms, sym, ct_get(DefInfo, defs, sym)), g, res)
def b5k_chk_var_lookup(
  lr: LookupRes, +ctx: CheckCtx, +cur_idx: U32, +fn_name: String, +goal: ChkTy, +sym: U32, +is_ref: Bool
) -> ExprRes:
  match lr:
    case LFound{dup, er, _, +vty}:
      bad_er = Bool.and(er, Bool.and(Bool.not(b5k_chk_is_er_goal(goal)), Bool.not(b5k_chk_is_er_or_quant(vty))))
      b5k_chk_var_er(bad_er, ctx, fn_name, vty, goal, ExprOk{Bool.pick(List<&2, U32>, dup, Nil{}, Con{sym, Nil{}})})
    case LNotFound{}:
      gerr = b5k_chk_var_goal_err(goal, ctx, fn_name, sym)
      b5k_chk_var_nf_k(gerr, b5k_chk_is_fwd_ref(ctx, cur_idx, fn_name, sym), goal, ctx, fn_name, sym, is_ref)
def b5k_chk_merge(is_br: Bool, fn_name: String, r1: ExprRes, r2: ExprRes) -> ExprRes:
  match is_br r1 r2:
    case _ ExprErr{err} _: ExprErr{err}
    case _ ExprOk{_} ExprErr{err}: ExprErr{err}
    case True{} ExprOk{u1} ExprOk{+u2}: ExprOk{b5k_chk_uses_union(u1, u2, u2)}
    case False{} ExprOk{u1} ExprOk{u2}: b5k_chk_uses_sum(fn_name, u1, u2)
def b5k_chk_strip_res(+bs: List<&2, VarBind>, r: ExprRes) -> ExprRes:
  match r:
    case ExprErr{err}: ExprErr{err}
    case ExprOk{u}: ExprOk{b5k_chk_uses_strip(bs, u, Nil{})}
def b5k_chk_erased_res(er: Bool, r: ExprRes) -> ExprRes:
  match er r:
    case True{} ExprOk{_}: ExprOk{Nil{}}
    case _ other: other
def b5k_chk_u32_ctor_is(ctx: CheckCtx, g: String) -> Bool:
  CheckCtx{syms, _, ctors, _, _, _, _} = ctx
  +tn = b5k_chk_ci_tn(b5k_chk_ct_get_opt(ctors, symtab_lookup(syms, "U32")))
  Bool.and(Bool.not(String.is_empty(tn)), String.eq(tn, g))
def b5k_chk_tfam_is_stuck_mat(ctx: CheckCtx, h: U32, arg: Expr) -> Bool:
  CheckCtx{_, _, _, _, _, dasts, _} = ctx
  match arg:
    case EVar{_}: b5k_chk_def_is_mat(False{}, ct_get(Def, dasts, h))
    case _: False{}
def b5k_chk_lit(
  +ctx: CheckCtx, bad_sug: Bool, in_m: Bool, goal: ChkTy, +fn_name: String, +got: String, +is_num: Bool
) -> ExprRes:
  match bad_sug goal:
    case True{} _: ExprErr{"check: " ++ fn_name ++ ": shadowed " ++ got ++ " lacks literal constructor"}
    case False{} TAny{}: ExprOk{Nil{}}
    case False{} TTyVar{_}: ExprOk{Nil{}}
    case False{} TFam2{_, _, _}: ExprOk{Nil{}}
    case False{} TNonUniv{}: ExprOk{Nil{}}
    case False{} TFam{h, arg}:
      chk_err_res(Bool.and(in_m, b5k_chk_tfam_is_stuck_mat(ctx, h, arg)), fn_name,
        ": literal does not match stuck type family")
    case False{} TErased{}: ExprOk{Nil{}}
    case False{} TCon{+g, _}:
      ok = Bool.or(b5k_str_eq(g, got), Bool.and(is_num, Bool.or(b5k_str_eq(g, "Quant"), b5k_chk_u32_ctor_is(ctx, g))))
      chk_err_res(Bool.not(ok), fn_name, ": literal type mismatch (" ++ got ++ ")")
    case False{} _: ExprErr{"check: " ++ fn_name ++ ": literal type mismatch (" ++ got ++ ")"}
def b5k_chk_pair_goal_ok(goal: ChkTy) -> Bool:
  match goal:
    case TCon{+g, _}:
      Bool.or(String.eq(g, "Sigma"),
        Bool.or(String.eq(g, "Pair"), Bool.or(String.eq(g, "Tuple"), String.ends_with(g, ".Tuple"))))
    case TEq{_, _, _, _}: False{}
    case _: True{}
def b5k_chk_monad_inner(goal: ChkTy) -> ChkTy:
  match goal:
    case TCon{+h, +args}:
      Bool.pick(
        ChkTy, String.eq(h, "IO"), chk_nth(ChkTy, 0n, args, TAny{}),
        Bool.pick(
          ChkTy, String.eq(h, "Maybe"), chk_nth(ChkTy, 1n, args, TAny{}),
          Bool.pick(ChkTy, String.eq(h, "Result"), chk_nth(ChkTy, 3n, args, TAny{}), TAny{})
        )
      )
    case _: TAny{}
def b5k_chk_refl_goal(+ctx: CheckCtx, cur_idx: U32, allow_n: Bool, fn_name: String, goal: ChkTy) -> ExprRes:
  match goal:
    case TEq{a, b, _, st}:
      chk_err_res(b5k_chk_expr_neq_idx(ctx, cur_idx, Bool.or(st, allow_n), a, b), fn_name, ": reflexivity mismatch")
    case TFam{h, arg}:
      chk_err_res(b5k_chk_tfam_is_stuck_mat(ctx, h, arg), fn_name, ": cannot check refl against stuck type family")
    case TCon{+g, _}:
      Bool.pick(ExprRes, String.eq(g, "Equal"), ExprOk{Nil{}},
        ExprErr{b5k_chk_head_err(fn_name, b5k_chk_t0("Equal"), TCon{g, Nil{}})})
    case TFun{_, _, _,
      _}: ExprErr{b5k_chk_head_err(fn_name, b5k_chk_t0("Equal"), TFun{False{}, False{}, TAny{}, TAny{}})}
    case _: ExprOk{Nil{}}
def b5k_chk_lam_dup(goal: ChkTy) -> Bool:
  match goal:
    case TErased{}: True{}
    case TFun{d, _, _, r}: Bool.or(d, b5k_chk_is_er_goal(r))
    case _: False{}
def b5k_chk_lam_ret(goal: ChkTy) -> ChkTy:
  match goal:
    case TErased{}: TErased{}
    case TFun{_, _, _, r}: r
    case _: TAny{}
def b5k_chk_expr_is_erased(+syms: SymTab, e: Expr) -> Bool:
  match e:
    case EVar{+sym}: Bool.or(b5k_chk_is_universe(symtab_name(syms, sym)), String.eq(symtab_name(syms, sym), "Empty"))
    case EApp{EVar{sym}, _}: b5k_chk_is_universe(symtab_name(syms, sym))
    case EAnn{v, _}: b5k_chk_is_cmp_expr(v)
    case EEq{_, _}: True{}
    case EAll{_, body}: b5k_chk_expr_is_erased(syms, body)
    case _: False{}

type SubPair is Data:
  SubPair{vsym: U32, psym: U32}
type RecCtx is Data:
  RecCtx{
    fn_sym: U32, cur_idx: U32, params: List<&2, U32>, sub: List<&2, SubPair>,
    sub2: List<&2, SubPair>, lit_max: U32, after_let: Bool, in_match: Bool,
    banned: List<&2, U32>, lit_bad: U32
  }
def b5k_chk_rc_clr(mode: U32, rc: RecCtx) -> RecCtx:
  match mode rc:
    case 0 RecCtx{fs, _, pms, sub, sub2, lm, al, im, bn, lb}: RecCtx{fs, 0, pms, sub, sub2, lm, al, im, bn, lb}
    case 1 RecCtx{_, ci, pms, sub, sub2, lm, al, im, bn, lb}: RecCtx{0, ci, pms, sub, sub2, lm, al, im, bn, lb}
    case _ RecCtx{fs, ci, pms, sub, sub2, lm, _, im, bn, lb}: RecCtx{fs, ci, pms, sub, sub2, lm, False{}, im, bn, lb}
def b5k_chk_rc_u32(which: U32, rc: RecCtx) -> U32:
  match which rc:
    case 0 RecCtx{fs, _, _, _, _, _, _, _, _, _}: fs
    case 1 RecCtx{_, ci, _, _, _, _, _, _, _, _}: ci
    case 2 RecCtx{_, _, _, _, _, _, _, _, _, lb}: lb
    case 3 RecCtx{_, _, _, _, _, _, al, _, _, _}: Bool.to_u32(al)
    case _ RecCtx{_, _, _, _, _, _, _, im, _, _}: Bool.to_u32(im)
def b5k_chk_sub_for(xs: List<&2, SubPair>, +p: U32, +acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: acc
    case Con{SubPair{v, s}, t}:
      b5k_chk_sub_for(t, p, Bool.pick(List<&2, U32>, Bool.or(U32.is_zero(p), U32.is_eq(s, p)), Con{v, acc}, acc))
def b5k_chk_sub_src(xs: List<&2, SubPair>, +v: U32) -> U32:
  match xs:
    case Nil{}: 0
    case Con{SubPair{vs, ps}, t}: Bool.pick(U32, U32.is_eq(vs, v), ps, b5k_chk_sub_src(t, v))
def b5k_chk_pat_sub_vars(+fuel: Nat, ps: List<&2, Pat>, acc: List<&2, U32>) -> List<&2, U32>:
  match fuel ps:
    case 0n _: acc
    case _ Nil{}: acc
    case 1n+f Con{PVar{s, _}, t}: b5k_chk_pat_sub_vars(f, t, Con{s, acc})
    case 1n+f Con{PCtr{_, fs}, t}: b5k_chk_pat_sub_vars(f, b5k_list_app(Pat, fs, t), acc)
    case 1n+f Con{PPair{a, b}, t}: b5k_chk_pat_sub_vars(f, Con{a, Con{b, t}}, acc)
    case 1n+f Con{PList{es}, t}: b5k_chk_pat_sub_vars(f, b5k_list_app(Pat, es, t), acc)
    case 1n+f Con{_, t}: b5k_chk_pat_sub_vars(f, t, acc)
def b5k_chk_pats_sub(depth: Nat, ps: List<&2, Pat>, acc: List<&2, U32>) -> List<&2, U32>:
  match depth ps:
    case _ Nil{}: acc
    case 0n Con{PCtr{_, fs}, t}: b5k_chk_pats_sub(0n, t, b5k_chk_pat_sub_vars(U32.to_nat(512), fs, acc))
    case 0n Con{PPair{a, b}, t}: b5k_chk_pats_sub(0n, t, b5k_chk_pat_sub_vars(64n, [a, b], acc))
    case 0n Con{PList{es}, t}: b5k_chk_pats_sub(0n, t, b5k_chk_pat_sub_vars(64n, es, acc))
    case 1n++d Con{PCtr{_, fs}, t}: b5k_chk_pats_sub(1n+d, t, b5k_chk_pats_sub(d, fs, acc))
    case 1n++d Con{PPair{a, b}, t}: b5k_chk_pats_sub(1n+d, t, b5k_chk_pats_sub(d, [a, b], acc))
    case d Con{_, t}: b5k_chk_pats_sub(d, t, acc)
def b5k_chk_sub_walk(
  +is_all: Bool, +fuel: Nat, +sub: List<&2, U32>, +sub2: List<&2, U32>, es: List<&2, Expr>
) -> Bool:
  match fuel es:
    case 0n _: False{}
    case _ Nil{}: is_all
    case 1n+f Con{EVar{+s}, +t}:
      +h = b5k_chk_u32_mem(sub, s)
      Bool.pick(Bool, is_all, Bool.and(h, b5k_chk_sub_walk(is_all, f, sub, sub2, t)),
        Bool.or(h, b5k_chk_sub_walk(is_all, f, sub, sub2, t)))
    case 1n++f Con{ECtr{_, +fs}, +t}:
      Bool.pick(
        Bool, is_all,
        Bool.and(b5k_chk_sub_walk(is_all, f, sub2, sub2, fs), b5k_chk_sub_walk(is_all, f, sub, sub2, t)),
        b5k_chk_sub_walk(is_all, f, sub, sub2, b5k_list_app(Expr, fs, t))
      )
    case 1n+f Con{EList{xs}, t}: b5k_chk_sub_walk(is_all, f, sub, sub2, b5k_list_app(Expr, xs, t))
    case 1n+f Con{EPair{a, b}, t}: b5k_chk_sub_walk(is_all, f, sub, sub2, Con{a, Con{b, t}})
    case 1n+f Con{EAnn{v, _}, t}: b5k_chk_sub_walk(is_all, f, sub, sub2, Con{v, t})
    case 1n+f Con{ENum{_}, t}: b5k_chk_sub_walk(is_all, f, sub, sub2, t)
    case 1n+f Con{_, t}: Bool.pick(Bool, is_all, False{}, b5k_chk_sub_walk(is_all, f, sub, sub2, t))
def b5k_chk_scon_depth(+syms: SymTab, p: Pat, +acc: U32) -> U32:
  match p:
    case PCtr{s, Con{_, Con{rest, Nil{}}}}:
      Bool.pick(U32, String.eq(symtab_name(syms, s), "SCon"), b5k_chk_scon_depth(syms, rest, U32.add(acc, 1)), acc)
    case _: acc
def b5k_chk_pats_lit_max(+syms: SymTab, ps: List<&2, Pat>, +acc: U32) -> U32:
  match ps:
    case Nil{}: acc
    case Con{PNum{+v}, t}: b5k_chk_pats_lit_max(syms, t, Bool.pick(U32, U32.is_gt(v, acc), v, acc))
    case Con{PCtr{+s, fs}, t}:
      +sd = b5k_chk_scon_depth(syms, PCtr{s, fs}, 0)
      +acc1 = Bool.pick(U32, U32.is_gt(sd, acc), sd, acc)
      acc2 = Bool.pick(U32, Bool.and(String.eq(symtab_name(syms, s), "Succ"), U32.is_zero(acc1)), 1, acc1)
      b5k_chk_pats_lit_max(syms, t, acc2)
    case Con{_, t}: b5k_chk_pats_lit_max(syms, t, acc)
def b5k_chk_arg_is_sub(+sub: List<&2, U32>, +sub2: List<&2, U32>, +lmax: U32, e: Expr) -> Bool:
  match e:
    case EVar{s}: b5k_chk_u32_mem(sub, s)
    case ECtr{_, Con{+h, +t}}:
      Bool.and(b5k_chk_sub_walk(True{}, 32n, sub, sub2, Con{h, t}),
        b5k_chk_sub_walk(False{}, 32n, sub2, sub2, Con{h, t}))
    case EOp{0, ENum{1}, v}: b5k_chk_sub_walk(True{}, 32n, sub2, sub2, [v])
    case EOp{0, EAnn{ENum{1}, ESet{}}, v}: b5k_chk_sub_walk(True{}, 32n, sub2, sub2, [v])
    case ENum{k}: U32.is_lt(k, lmax)
    case EStr{s}: U32.is_lt(U32.from_nat(String.length(s)), lmax)
    case EAnn{v, _}: b5k_chk_arg_is_sub(sub, sub2, lmax, v)
    case _: False{}
def b5k_chk_sp_push(+psym: U32, vs: List<&2, U32>, acc: List<&2, SubPair>) -> List<&2, SubPair>:
  match vs:
    case Nil{}: acc
    case Con{v, t}: b5k_chk_sp_push(psym, t, Con{SubPair{v, psym}, acc})
def b5k_chk_pats_sub_p(
  +is2: Bool, ps: List<&2, Pat>, ssyms: List<&2, U32>,
  +old_sub: List<&2, SubPair>, acc: List<&2, SubPair>
) -> List<&2, SubPair>:
  match ps ssyms:
    case Con{+p, pt} Con{+s, st}:
      +orig = Bool.pick(U32, U32.is_gt(s, 0), b5k_chk_sub_src(old_sub, U32.sub(s, 1)), 0)
      +psym = Bool.pick(U32, U32.is_gt(orig, 0), orig, s)
      vs = b5k_chk_pats_sub(Bool.pick(Nat, Bool.and(is2, U32.is_zero(orig)), 1n, 0n), [p], Nil{})
      b5k_chk_pats_sub_p(is2, pt, st, old_sub, b5k_chk_sp_push(psym, vs, acc))
    case _ _: acc
def b5k_chk_arg_is_same(+p: U32, +sub: List<&2, U32>, +lmax: U32, e: Expr) -> Bool:
  match e:
    case EVar{s}: U32.is_eq(s, p)
    case ENum{k}: U32.is_le(k, lmax)
    case EOp{0, ENum{1}, EVar{x}}: b5k_chk_u32_mem(sub, x)
    case EOp{0, EAnn{ENum{1}, ESet{}}, EVar{x}}: b5k_chk_u32_mem(sub, x)
    case ECtr{_, Nil{}}: True{}
    case ECtr{_, Con{+h, +t}}:
      Bool.and(b5k_chk_sub_walk(True{}, 32n, sub, sub, Con{h, t}),
        b5k_chk_sub_walk(False{}, 32n, sub, sub, Con{h, t}))
    case EAnn{v, _}: b5k_chk_arg_is_same(p, sub, lmax, v)
    case _: False{}
def b5k_chk_lex_ok(
  +sub: List<&2, SubPair>, +sub2: List<&2, SubPair>, +lmax: U32, pms: List<&2, U32>, args: List<&2, Expr>
) -> Bool:
  match pms args:
    case Con{+p, pt} Con{+a, at}:
      +sp = b5k_chk_sub_for(sub, p, Nil{})
      +sp2 = b5k_chk_sub_for(sub2, p, Nil{})
      same = Bool.or(U32.is_zero(p), b5k_chk_arg_is_same(U32.sub(p, 1), sp, lmax, a))
      Bool.pick(Bool, b5k_chk_arg_is_sub(sp, sp2, lmax, a), True{},
        Bool.pick(Bool, same, b5k_chk_lex_ok(sub, sub2, lmax, pt, at), False{}))
    case _ _: False{}
def b5k_chk_has_grow_tilde(es: List<&2, Expr>) -> Bool:
  match es:
    case Nil{}: False{}
    case Con{EUnOp{1, h}, t}:
      +tg = b5k_chk_expr_tag(h)
      Bool.or(Bool.or(U32.is_eq(tg, 3), U32.is_ge(tg, 6)), b5k_chk_has_grow_tilde(t))
    case Con{_, t}: b5k_chk_has_grow_tilde(t)
def b5k_chk_rec_call_k(
  is_self: Bool, pms: List<&2, U32>, sub: List<&2, SubPair>, sub2: List<&2, SubPair>,
  lmax: U32, +args: List<&2, Expr>, +fn_name: String
) -> String:
  match is_self:
    case False{}: ""
    case True{}:
      Bool.pick(
        String, b5k_chk_has_grow_tilde(args),
        "check: " ++ fn_name ++ ": growing comptime '~' argument in recursive template",
        chk_err_if(Bool.not(b5k_chk_lex_ok(sub, sub2, lmax, pms, args)), fn_name, ": non-decreasing self-recursion")
      )
def b5k_chk_rec_call_err(rc: RecCtx, fun: Expr, +args: List<&2, Expr>, +fn_name: String) -> String:
  RecCtx{fsym, _, pms, sub, sub2, lmax, _, _, _, _} = rc
  match fun:
    case EVar{sym}: b5k_chk_rec_call_k(U32.is_eq(fsym, U32.add(sym, 1)), pms, sub, sub2, lmax, args, fn_name)
    case _: ""
def b5k_chk_u32_repl(xs: List<&2, U32>, +old: U32, +nw: U32) -> List<&2, U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h, t}: Con{Bool.pick(U32, U32.is_eq(h, old), nw, h), b5k_chk_u32_repl(t, old, nw)}
def b5k_chk_sub_repl(xs: List<&2, SubPair>, +old: U32, +nw: U32) -> List<&2, SubPair>:
  match xs:
    case Nil{}: Nil{}
    case Con{SubPair{v, +s}, t}: Con{SubPair{v, Bool.pick(U32, U32.is_eq(s, old), nw, s)},
      b5k_chk_sub_repl(t, old, nw)}
def b5k_chk_ren_u32(pats: List<&2, Pat>, ssyms: List<&2, U32>, +acc: List<&2, U32>) -> List<&2, U32>:
  match pats ssyms:
    case Con{PVar{ns, _}, pt} Con{+s, st}:
      b5k_chk_ren_u32(pt, st,
        Bool.pick(List<&2, U32>, U32.is_gt(s, 0), b5k_chk_u32_repl(acc, s, U32.add(ns, 1)), acc))
    case Con{_, pt} Con{_, st}: b5k_chk_ren_u32(pt, st, acc)
    case _ _: acc
def b5k_chk_ren_sub(pats: List<&2, Pat>, ssyms: List<&2, U32>, +acc: List<&2, SubPair>) -> List<&2, SubPair>:
  match pats ssyms:
    case Con{PVar{ns, _}, pt} Con{+s, st}:
      b5k_chk_ren_sub(pt, st,
        Bool.pick(List<&2, SubPair>, U32.is_gt(s, 0), b5k_chk_sub_repl(acc, s, U32.add(ns, 1)), acc))
    case Con{_, pt} Con{_, st}: b5k_chk_ren_sub(pt, st, acc)
    case _ _: acc
def b5k_chk_rc_add(
  rc: RecCtx, +pats: List<&2, Pat>, +ssyms: List<&2, U32>,
  extra: List<&2, SubPair>, extra2: List<&2, SubPair>, +lm2: U32, ban2: List<&2, U32>
) -> RecCtx:
  RecCtx{fs, ci, pms, sub, sub2, +lm, _, _, bn, lb} = rc
  RecCtx{
    fs, ci, b5k_chk_ren_u32(pats, ssyms, pms),
    b5k_list_app(SubPair, extra, b5k_chk_ren_sub(pats, ssyms, sub)),
    b5k_list_app(SubPair, extra2, b5k_chk_ren_sub(pats, ssyms, sub2)),
    Bool.pick(U32, U32.is_gt(lm2, lm), lm2, lm), False{}, True{},
    b5k_list_app(U32, ban2, bn), lb
  }
def b5k_chk_rc_let(rc: RecCtx, pat: Pat, +val: Expr) -> RecCtx:
  RecCtx{+fs, +ci, +pms, +sub, +sub2, +lm, +al, +im, +bn, +lb} = rc
  match pat:
    case PVar{+s, _}:
      +v1 = b5k_chk_scrut_sym(val)
      +ps = Bool.pick(U32, U32.is_gt(v1, 0), b5k_chk_sub_src(sub, U32.sub(v1, 1)), 0)
      +ps2 = Bool.pick(U32, U32.is_gt(v1, 0), b5k_chk_sub_src(sub2, U32.sub(v1, 1)), 0)
      RecCtx{
        fs, ci, Bool.pick(List<&2, U32>, U32.is_gt(v1, 0), b5k_chk_u32_repl(pms, v1, U32.add(s, 1)), pms),
        Bool.pick(List<&2, SubPair>, U32.is_gt(ps, 0), Con{SubPair{s, ps}, sub}, sub),
        Bool.pick(List<&2, SubPair>, U32.is_gt(ps2, 0), Con{SubPair{s, ps2}, sub2}, sub2),
        lm, True{}, im, bn, lb
      }
    case PPair{_, _}: RecCtx{fs, ci, pms, sub, sub2, lm, al, True{}, bn, lb}
    case PCtr{_, _}: RecCtx{fs, ci, pms, sub, sub2, lm, al, True{}, bn, lb}
    case _: RecCtx{fs, ci, pms, sub, sub2, lm, al, im, bn, lb}
def b5k_chk_is_rwt_var(typ: Expr, val: Expr) -> Bool:
  match typ val:
    case EHole{} EVar{_}: True{}
    case _ _: False{}
def b5k_chk_is_dead_tail(pats: List<&2, Pat>, rest: List<&2, Case>) -> Bool:
  match pats rest:
    case Con{PWild{}, Nil{}} Con{Case{Con{PWild{}, Nil{}}, _}, Nil{}}: True{}
    case _ _: False{}
def b5k_chk_un_elist(e: Expr) -> List<&2, Expr>:
  match e:
    case EList{es}: es
    case _: Nil{}
def b5k_chk_subst_e(+fuel: Nat, +target: U32, +rep: Expr, e: Expr) -> Expr:
  match fuel e:
    case 0n x: x
    case _ EVar{+s}: Bool.pick(Expr, U32.is_eq(s, target), rep, EVar{s})
    case 1n++f EApp{fn, args}:
      EApp{b5k_chk_subst_e(f, target, rep, fn), b5k_chk_un_elist(b5k_chk_subst_e(f, target, rep, EList{args}))}
    case 1n+f ECtr{s, fs}: ECtr{s, b5k_chk_un_elist(b5k_chk_subst_e(f, target, rep, EList{fs}))}
    case 1n++f EList{Con{h, t}}:
      EList{Con{b5k_chk_subst_e(f, target, rep, h), b5k_chk_un_elist(b5k_chk_subst_e(f, target, rep, EList{t}))}}
    case 1n++f EOp{op, a, b}: EOp{op, b5k_chk_subst_e(f, target, rep, a), b5k_chk_subst_e(f, target, rep, b)}
    case 1n+f EAnn{v, ty}: EAnn{b5k_chk_subst_e(f, target, rep, v), ty}
    case 1n++f EPair{a, b}: EPair{b5k_chk_subst_e(f, target, rep, a), b5k_chk_subst_e(f, target, rep, b)}
    case _ x: x
def b5k_chk_subst_pms(+ps: List<&2, Param>, args: List<&2, Expr>, e: Expr) -> Expr:
  match ps args:
    case Con{Param{s, _, _, _}, pt} Con{a, at}: b5k_chk_subst_pms(pt, at, b5k_chk_subst_e(64n, s, a, e))
    case _ _: e
def b5k_chk_pat_to_e(+fuel: Nat, pat: Pat) -> Maybe<&2, Expr>:
  match fuel pat:
    case 0n _: None{}
    case _ PVar{s, _}: Some{EVar{s}}
    case _ PNum{k}: Some{ENum{k}}
    case _ PCtr{s, Nil{}}: Some{ECtr{s, Nil{}}}
    case 1n+f PCtr{s, Con{p1, Nil{}}}:
      chk_maybe(Expr, Maybe<&2, Expr>, b5k_chk_pat_to_e(f, p1), None{}, e1 => Some{ECtr{s, [e1]}})
    case 1n++f PCtr{s, Con{p1, Con{p2, Nil{}}}}:
      chk_maybe(
        Expr, Maybe<&2, Expr>, b5k_chk_pat_to_e(f, p1), None{},
        e1 => chk_maybe(Expr, Maybe<&2, Expr>, b5k_chk_pat_to_e(f, p2), None{}, e2 => Some{ECtr{s, [e1, e2]}})
      )
    case _ _: None{}
def b5k_chk_spec_goal_k(me: Maybe<&2, Expr>, +goal: ChkTy, +sc: U32) -> ChkTy:
  match me goal:
    case Some{+pe} TEq{a, b, car, _}: TEq{b5k_chk_subst_e(16n, sc, pe, a), b5k_chk_subst_e(16n, sc, pe, b), car,
      True{}}
    case Some{pe} TFam{h, EVar{+v}}: Bool.pick(ChkTy, U32.is_eq(v, sc), TFam{h, pe}, TFam{h, EVar{v}})
    case _ g: g
def b5k_chk_spec_goal(+goal: ChkTy, pats: List<&2, Pat>, ssyms: List<&2, U32>) -> ChkTy:
  match pats ssyms:
    case Con{+p, Nil{}} Con{+s, Nil{}}:
      ok = Bool.and(U32.is_gt(s, 0), Bool.not(p_pat_is_name(p)))
      Bool.pick(ChkTy, ok, b5k_chk_spec_goal_k(b5k_chk_pat_to_e(4n, p), goal, U32.sub(s, 1)), goal)
    case _ _: goal
def b5k_chk_is_wild_var(syms: SymTab, +e: Expr) -> Bool:
  Bool.and(U32.is_eq(b5k_chk_expr_tag(e), 2), String.eq(symtab_name(syms, U32.sub(chk_expr_sym1(e), 1)), "_"))
def b5k_chk_rwt_ty_bad(+ctx: CheckCtx, ty: ChkTy, mot: Expr) -> Bool:
  CheckCtx{syms, _, _, _, _, _, _} = ctx
  match ty mot:
    case TCon{h, _} _: Bool.not(String.eq(h, "Equal"))
    case TEq{_, _, ecar, _} EAnn{EOp{20, mlhs, mrhs}, mcar}:
      has_w = Bool.or(b5k_chk_is_wild_var(syms, mlhs), b5k_chk_is_wild_var(syms, mrhs))
      Bool.and(has_w, Bool.not(b5k_chk_head_ok(ctx, b5k_chk_goal_expr(ctx, mcar), ecar)))
    case _ _: False{}
def b5k_chk_rwt_eq_bad(+ctx: CheckCtx, env: List<&2, VarBind>, eq: Expr, mot: Expr) -> Bool:
  match eq:
    case ENum{_}: True{}
    case ECtr{_, _}: True{}
    case other: b5k_chk_rwt_ty_bad(ctx, b5k_chk_infer_head(ctx, env, other), mot)
def b5k_chk_rwt_subst_wild(syms: SymTab, rep: Expr, +e: Expr) -> Expr:
  chk_maybe(U32, Expr, symtab_lookup(syms, "_"), e, wsym => b5k_chk_subst_e(64n, wsym, rep, e))
def b5k_chk_rwt_from_def(
  +syms: SymTab, md: Maybe<&2, Def>, ml: Maybe<&2, LawDef>,
  args: List<&2, Expr>, mlhs: Expr, mrhs: Expr, top_w: Bool
) -> ChkTy:
  match md ml:
    case Some{Def{_, ps, _, _, _, _}} Some{LawDef{_, lps, EAnn{EOp{20, plhs, _}, _}}}:
      +rep = b5k_chk_subst_pms(b5k_chk_merge_law_params(ps, lps), args, plhs)
      TEq{b5k_chk_rwt_subst_wild(syms, rep, mlhs), b5k_chk_rwt_subst_wild(syms, rep, mrhs), TAny{}, top_w}
    case Some{Def{_, ps, Some{EAnn{EOp{20, plhs, _}, _}}, _, _, _}} _:
      +rep = b5k_chk_subst_pms(ps, args, plhs)
      TEq{b5k_chk_rwt_subst_wild(syms, rep, mlhs), b5k_chk_rwt_subst_wild(syms, rep, mrhs), TAny{}, top_w}
    case _ _: TNonUniv{}
def b5k_chk_rwt_body_goal(ctx: CheckCtx, eq: Expr, mot: Expr) -> ChkTy:
  CheckCtx{+syms, _, _, _, laws, dasts, _} = ctx
  match eq mot:
    case EApp{EVar{+f}, args} EAnn{EOp{20, +mlhs, +mrhs}, _}:
      top_w = Bool.or(b5k_chk_is_wild_var(syms, mlhs), b5k_chk_is_wild_var(syms, mrhs))
      b5k_chk_rwt_from_def(syms, ct_get(Def, dasts, f), ct_get(LawDef, laws, f), args, mlhs, mrhs, top_w)
    case _ _: TNonUniv{}

# Match Scrutinee & Exhaustiveness Checking (Closure-Free)
def b5k_chk_lr_bad_scrut(lr: LookupRes, is_er_goal: Bool) -> Bool:
  match lr:
    case LFound{_, er, loc, _}: Bool.or(loc, Bool.and(er, Bool.not(is_er_goal)))
    case LNotFound{}: False{}
def b5k_chk_one_scrut_bad(env: List<&2, VarBind>, is_er_goal: Bool, e: Expr) -> Bool:
  match e:
    case EVar{s}: b5k_chk_lr_bad_scrut(b5k_chk_env_lookup(env, s), is_er_goal)
    case EAnn{v, _}: b5k_chk_one_scrut_bad(env, is_er_goal, v)
    case _: True{}
def b5k_chk_scrut_bad(+env: List<&2, VarBind>, +is_er_goal: Bool, scruts: List<&2, Expr>, stys: List<&2,
  ChkTy>) -> Bool:
  match scruts stys:
    case Nil{} _: False{}
    case Con{_, _} Con{TFun{_, _, _, _}, _}: True{}
    case Con{sc, st} Con{_, tt}: Bool.or(b5k_chk_one_scrut_bad(env, is_er_goal, sc),
      b5k_chk_scrut_bad(env, is_er_goal, st, tt))
    case Con{sc, st} Nil{}: Bool.or(b5k_chk_one_scrut_bad(env, is_er_goal, sc),
      b5k_chk_scrut_bad(env, is_er_goal, st, Nil{}))
def b5k_chk_env_has_live_empty(env: List<&2, VarBind>) -> Bool:
  match env:
    case Nil{}: False{}
    case Con{VarBind{_, _, er, _, _, ty}, t}:
      +tg = b5k_chk_ty_tag(ty)
      hit = Bool.and(Bool.not(er), Bool.or(U32.is_zero(tg), U32.is_eq(tg, 8)))
      Bool.or(hit, b5k_chk_env_has_live_empty(t))
def b5k_chk_pat_head_name(syms: SymTab, p: Pat) -> String:
  match p:
    case PCtr{s, _}: symtab_name(syms, s)
    case PNum{0}: "Zero"
    case PNum{_}: "Succ"
    case PList{Nil{}}: "Nil"
    case PList{Con{_, _}}: "Con"
    case PPair{_, _}: "Tuple"
    case _: ""
def b5k_chk_base_tctors_go(cs: List<&2, CtorEntry>, +tn: String) -> List<&2, String>:
  match cs:
    case Nil{}: Nil{}
    case Con{CtorEntry{cn, ct, _}, t}:
      +rest = b5k_chk_base_tctors_go(t, tn)
      Bool.pick(List<&2, String>, String.eq(ct, tn), Con{cn, rest}, rest)
def b5k_chk_base_tctors(+tname: String) -> Maybe<&2, List<&2, String>>:
  +cs = b5k_chk_base_tctors_go(b5k_chk_base_ctors(), tname)
  r1 = Bool.pick(Maybe<&2, List<&2, String>>, p_is_nil(String, cs), None{}, Some{cs})
  r0 = Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "Pair"), Some{["Tuple"]}, r1)
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "Empty"), Some{Nil{}}, r0)
def b5k_chk_ctors_names(+syms: SymTab, cs: List<&2, CtorDef>) -> List<&2, String>:
  match cs:
    case Nil{}: Nil{}
    case Con{CtorDef{s, _, _}, t}: Con{symtab_name(syms, s), b5k_chk_ctors_names(syms, t)}
def b5k_chk_type_ctors_m(syms: SymTab, tname: String, m: Maybe<&2, TypeDef>) -> Maybe<&2, List<&2, String>>:
  match m:
    case None{}: b5k_chk_base_tctors(tname)
    case Some{TypeDef{_, _, _, cs}}: Some{b5k_chk_ctors_names(syms, cs)}
def b5k_chk_type_ctors(ctx: CheckCtx, +tname: String) -> Maybe<&2, List<&2, String>>:
  CheckCtx{+syms, _, _, _, _, _, tdefs} = ctx
  b5k_chk_type_ctors_m(syms, tname, b5k_chk_find_tdef(syms, tdefs, False{}, 0, tname))
def b5k_chk_cname_match_k(eq: Bool, +pn: String, +cn: String) -> Bool:
  match eq:
    case True{}: True{}
    case False{}:
      Bool.or(
        Bool.and(Bool.not(String.is_empty(pn)), String.ends_with(cn, "." ++ pn)),
        Bool.and(Bool.not(String.is_empty(cn)), String.ends_with(pn, "." ++ cn))
      )
def b5k_chk_cname_match(+pn: String, +cn: String) -> Bool:
  b5k_chk_cname_match_k(String.eq(pn, cn), pn, cn)
def b5k_chk_pat_tname(ctx: CheckCtx, p: Pat) -> String:
  match p:
    case PCtr{s, _}: b5k_chk_ci_tn(b5k_chk_lookup_ctor(ctx, s))
    case PList{_}: "List"
    case _: ""
def b5k_chk_ci_ar(ci: Maybe<&2, CtorInfo>) -> U32:
  match ci:
    case Some{CtorInfo{_, ar, _, _, _}}: ar
    case None{}: 0
def b5k_chk_pat_subpats(p: Pat) -> List<&2, Pat>:
  match p:
    case PCtr{_, fs}: fs
    case PNum{0}: Nil{}
    case PNum{k}: [PNum{U32.sub(k, 1)}]
    case PList{Con{h, t}}: [h, PList{t}]
    case PPair{a, b}: [a, b]
    case _: Nil{}
def b5k_chk_spec_row_k(
  is_w: Bool, syms: SymTab, cname: String, ar: U32,
  p0: Pat, pt: List<&2, Pat>, tail: List<&2, List<&2, Pat>>
) -> List<&2, List<&2, Pat>>:
  match is_w:
    case True{}: Con{b5k_list_app(Pat, chk_rep(Pat, U32.to_nat(ar), PWild{}), pt), tail}
    case False{}:
      +p0b = p0
      +tailb = tail
      Bool.pick(
        List<&2, List<&2, Pat>>, b5k_chk_cname_match(b5k_chk_pat_head_name(syms, p0b), cname),
        Con{b5k_list_app(Pat, b5k_chk_pat_subpats(p0b), pt), tailb}, tailb
      )
def b5k_chk_spec_rows(+syms: SymTab, +cname: String, +ar: U32, rows: List<&2, List<&2,
  Pat>>) -> List<&2, List<&2, Pat>>:
  match rows:
    case Nil{}: Nil{}
    case Con{Con{+p0, pt}, rest}:
      b5k_chk_spec_row_k(p_pat_is_name(p0), syms, cname, ar, p0, pt, b5k_chk_spec_rows(syms, cname, ar, rest))
    case Con{Nil{}, rest}: b5k_chk_spec_rows(syms, cname, ar, rest)
def b5k_chk_drop_col0_wild(rows: List<&2, List<&2, Pat>>) -> List<&2, List<&2, Pat>>:
  match rows:
    case Nil{}: Nil{}
    case Con{Con{p0, pt}, rest}:
      +tail = b5k_chk_drop_col0_wild(rest)
      Bool.pick(List<&2, List<&2, Pat>>, p_pat_is_name(p0), Con{pt, tail}, tail)
    case Con{Nil{}, rest}: b5k_chk_drop_col0_wild(rest)
def b5k_chk_col0_tname_rows(+ctx: CheckCtx, rows: List<&2, List<&2, Pat>>, cur: String) -> String:
  match rows cur:
    case Nil{} SNil{}: ""
    case _ SCon{c, t}: SCon{c, t}
    case Con{r, t} SNil{}: b5k_chk_col0_tname_rows(ctx, t, b5k_chk_pat_tname(ctx, chk_hd(Pat, r, PWild{})))
def b5k_chk_col0_tname(+ctx: CheckCtx, ty0: ChkTy, rows: List<&2, List<&2, Pat>>) -> String:
  match ty0:
    case TCon{h, _}: h
    case _: b5k_chk_col0_tname_rows(ctx, rows, "")
def b5k_chk_row_all_wild(r: List<&2, Pat>) -> Bool:
  match r:
    case Nil{}: True{}
    case Con{p, t}: Bool.and(p_pat_is_name(p), b5k_chk_row_all_wild(t))
def b5k_chk_rows_has_wild(rows: List<&2, List<&2, Pat>>) -> Bool:
  match rows:
    case Nil{}: False{}
    case Con{r, t}: Bool.or(b5k_chk_row_all_wild(r), b5k_chk_rows_has_wild(t))
def b5k_chk_rows_has_ctor(rows: List<&2, List<&2, Pat>>) -> Bool:
  match rows:
    case Nil{}: False{}
    case Con{r, t}: Bool.or(Bool.not(p_pat_is_name(chk_hd(Pat, r, PWild{}))), b5k_chk_rows_has_ctor(t))
def b5k_chk_cases_pats(cs: List<&2, Case>) -> List<&2, List<&2, Pat>>:
  match cs:
    case Nil{}: Nil{}
    case Con{Case{ps, _}, t}: Con{ps, b5k_chk_cases_pats(t)}
type ExhWork is Data:
  EXMat{stys: List<&2, ChkTy>, rows: List<&2, List<&2, Pat>>}
  EXStep{has_w: Bool, has_c: Bool, ty0: ChkTy, rtys: List<&2, ChkTy>, rows: List<&2, List<&2, Pat>>}
  EXOpt{m: Maybe<&2, List<&2, String>>, ty0: ChkTy, rtys: List<&2, ChkTy>, rows: List<&2, List<&2, Pat>>}
  EXCtors{cns: List<&2, String>, ty0: ChkTy, rest_tys: List<&2, ChkTy>, rows: List<&2, List<&2, Pat>>}
def b5k_chk_exh_zero_m(m: Maybe<&2, List<&2, String>>) -> Bool:
  match m:
    case Some{Nil{}}: True{}
    case _: False{}
def b5k_chk_exh_go(+fuel: Nat, +ctx: CheckCtx, w: ExhWork) -> Bool:
  match fuel ctx w:
    case 0n _ _: True{}
    case 1n+_ _ EXMat{Nil{}, Nil{}}: False{}
    case 1n+_ _ EXMat{Con{TCon{h, _}, _}, Nil{}}: b5k_chk_exh_zero_m(b5k_chk_type_ctors(ctx, h))
    case 1n+_ _ EXMat{_, Nil{}}: False{}
    case 1n+_ _ EXMat{Nil{}, Con{_, _}}: True{}
    case 1n+f _ EXMat{Con{ty0, rtys}, +rows}:
      b5k_chk_exh_go(f, ctx, EXStep{b5k_chk_rows_has_wild(rows), b5k_chk_rows_has_ctor(rows), ty0, rtys, rows})
    case 1n+_ _ EXStep{True{}, _, _, _, _}: True{}
    case 1n+f _ EXStep{False{}, False{}, _, rtys, rows}: b5k_chk_exh_go(f, ctx,
      EXMat{rtys, b5k_chk_drop_col0_wild(rows)})
    case 1n+f _ EXStep{False{}, True{}, +ty0, rtys, +rows}:
      +tn = b5k_chk_col0_tname(ctx, ty0, rows)
      m = Bool.pick(Maybe<&2, List<&2, String>>, String.is_empty(tn), None{}, b5k_chk_type_ctors(ctx, tn))
      b5k_chk_exh_go(f, ctx, EXOpt{m, ty0, rtys, rows})
    case 1n+_ _ EXOpt{None{}, _, _, _}: True{}
    case 1n+f _ EXOpt{Some{cns}, ty0, rtys, rows}: b5k_chk_exh_go(f, ctx, EXCtors{cns, ty0, rtys, rows})
    case 1n+_ _ EXCtors{Nil{}, _, _, _}: True{}
    case 1n+f CheckCtx{+syms, _, ctors, _, _, _, _} EXCtors{Con{+cn, ct}, +ty0, +rtys, +rows}:
      +ci = b5k_chk_ct_get_opt(ctors, symtab_lookup(syms, cn))
      +ar = b5k_chk_ci_ar(ci)
      +ftys = b5k_chk_ctor_fgoals(ci, ty0)
      atys = Bool.pick(List<&2, ChkTy>, U32.is_eq(b5k_list_len(ChkTy, ftys), ar), ftys,
        chk_rep(ChkTy, U32.to_nat(ar), TAny{}))
      Bool.and(
        b5k_chk_exh_go(f, ctx, EXMat{b5k_list_app(ChkTy, atys, rtys), b5k_chk_spec_rows(syms, cn, ar, rows)}),
        b5k_chk_exh_go(f, ctx, EXCtors{ct, ty0, rtys, rows})
      )
def b5k_chk_rc_sub(rc: RecCtx) -> List<&2, SubPair>:
  RecCtx{_, _, _, sub, _, _, _, _, _, _} = rc
  sub
def b5k_chk_pats_has_nonname(ps: List<&2, Pat>) -> Bool:
  match ps:
    case Nil{}: False{}
    case Con{p, t}: Bool.or(Bool.not(p_pat_is_name(p)), b5k_chk_pats_has_nonname(t))
def b5k_chk_sub_var_ban(ps: List<&2, Pat>, +acc: List<&2, U32>) -> List<&2, U32>:
  match ps:
    case Nil{}: acc
    case Con{PVar{s, _}, +t}:
      b5k_chk_sub_var_ban(t, Bool.pick(List<&2, U32>, b5k_chk_pats_has_nonname(t), Con{s, acc}, acc))
    case Con{_, t}: b5k_chk_sub_var_ban(t, acc)
def b5k_chk_comp_args_bad(args: List<&2, Expr>, +seen_plain: Bool) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{EUnOp{1, _}, t}: Bool.or(seen_plain, b5k_chk_comp_args_bad(t, seen_plain))
    case Con{_, t}: b5k_chk_comp_args_bad(t, True{})
def b5k_chk_count_tilde_args(args: List<&2, Expr>, +acc: U32) -> U32:
  match args:
    case Con{EUnOp{1, _}, t}: b5k_chk_count_tilde_args(t, U32.add(acc, 1))
    case _: acc
def b5k_chk_tilde_arity_bad(ctx: CheckCtx, fun: Expr, +nt: U32) -> Bool:
  CheckCtx{syms, _, _, defs, _, _, _} = ctx
  match nt:
    case 0: False{}
    case n:
      +s1 = chk_expr_sym1(fun)
      +sym = U32.sub(s1, 1)
      +di = ct_get(DefInfo, defs, sym)
      ok = Bool.pick(
        Bool, b5k_chk_is_some(DefInfo, di), U32.is_le(n, b5k_chk_di_u32(1, di)),
        Bool.not(b5k_chk_str_match(True{}, ["Nat.", "U32.", "F32.", "Bool.", "Char."], symtab_name(syms, sym)))
      )
      Bool.and(U32.is_gt(s1, 0), Bool.not(ok))
def b5k_chk_empty_mat_stys(ctx: CheckCtx, stys: List<&2, ChkTy>) -> Bool:
  match stys:
    case Nil{}: False{}
    case Con{TCon{h, _}, _}: b5k_chk_exh_zero_m(b5k_chk_type_ctors(ctx, h))
    case Con{TFun{_, _, _, _}, _}: False{}
    case _: True{}
def b5k_chk_is_lammat_ctor(typ: Expr) -> U32:
  match typ:
    case ERef{csym}: U32.add(csym, 1)
    case _: 0
def b5k_chk_env_has_er_ty(env: List<&2, VarBind>) -> Bool:
  match env:
    case Nil{}: False{}
    case Con{VarBind{_, _, er, _, _, ty}, t}:
      Bool.or(Bool.and(er, U32.is_eq(b5k_chk_ty_tag(ty), 2)), b5k_chk_env_has_er_ty(t))
def b5k_chk_let_plus_bad(+ctx: CheckCtx, +env: List<&2, VarBind>, pat: Pat, val: Expr, vty: ChkTy) -> Bool:
  CheckCtx{syms, _, _, _, _, _, tdefs} = ctx
  match pat:
    case PVar{_, True{}}:
      match val vty:
        case ELam{_, _} _: True{}
        case _ TFun{_, _, _, _}: True{}
        case _ TCon{h, _}: b5k_chk_td_is_nd(syms, tdefs, False{}, 0, h)
        case EVar{s} TAny{}: Bool.and(Bool.not(b5k_chk_expr_is_dup(env, EVar{s})), b5k_chk_env_has_er_ty(env))
        case EVar{s} TTyVar{_}: Bool.and(Bool.not(b5k_chk_expr_is_dup(env, EVar{s})), b5k_chk_env_has_er_ty(env))
        case _ _: False{}
    case _: False{}
def b5k_chk_def_ncomp(ctx: CheckCtx, fun: Expr) -> U32:
  CheckCtx{_, _, _, defs, _, _, _} = ctx
  +s1 = chk_expr_sym1(fun)
  Bool.pick(U32, U32.is_zero(s1), 0, b5k_chk_di_u32(1, ct_get(DefInfo, defs, U32.sub(s1, 1))))
def b5k_chk_rc_can_neut(rc: RecCtx) -> Bool:
  RecCtx{_, _, pms, _, _, _, _, im, _, _} = rc
  Bool.and(Bool.not(im), Bool.not(p_is_nil(U32, pms)))
def b5k_chk_env_upto(env: List<&2, VarBind>, +target: U32, +acc: List<&2, U32>) -> List<&2, U32>:
  match env:
    case Nil{}: acc
    case Con{VarBind{+s, _, _, _, _, _}, rest}:
      Bool.pick(List<&2, U32>, U32.is_eq(s, target), Con{s, acc}, b5k_chk_env_upto(rest, target, Con{s, acc}))
def b5k_chk_pms_has_pdup(ps: List<&2, Param>) -> Bool:
  match ps:
    case Nil{}: False{}
    case Con{Param{_, _, er, dup}, t}: Bool.or(Bool.and(Bool.not(er), dup), b5k_chk_pms_has_pdup(t))
def b5k_chk_def_has_pdup(d: Def) -> Bool:
  Def{_, ps, _, _, _, _} = d
  b5k_chk_pms_has_pdup(ps)
def b5k_chk_comp_ers(nt: U32, ctx: CheckCtx, fun: Expr, aers: List<&2, Bool>) -> List<&2, Bool>:
  match nt:
    case 0: aers
    case _:
      CheckCtx{_, _, _, _, _, dasts, _} = ctx
      +s1 = chk_expr_sym1(fun)
      cd = Bool.pick(
        Bool, U32.is_zero(s1), True{},
        chk_maybe(Def, Bool, ct_get(Def, dasts, U32.sub(s1, 1)), True{}, d => b5k_chk_def_has_pdup(d))
      )
      Con{cd, chk_tl(Bool, aers)}
def b5k_chk_comp_goal_dup(allow_dup: Bool, t: ChkTy) -> ChkTy:
  match allow_dup t:
    case True{} TFun{_, er, a, r}: TFun{True{}, er, a, r}
    case _ other: other
def b5k_chk_glam_er_bad(goal: ChkTy) -> Bool:
  match goal:
    case TFun{_, True{}, _, r}: Bool.not(b5k_chk_is_er_goal(r))
    case _: False{}
def b5k_chk_glam_has_dup(cs: List<&2, Case>, +seen: List<&2, U32>) -> Bool:
  match cs:
    case Nil{}: False{}
    case Con{Case{_, EAnn{_, ERef{+s}}}, t}: Bool.or(b5k_chk_u32_mem(seen, s), b5k_chk_glam_has_dup(t, Con{s, seen}))
    case Con{_, t}: b5k_chk_glam_has_dup(t, seen)
def chk_glam_case_ref(c: Case) -> U32:
  match c:
    case Case{_, EAnn{_, ERef{s}}}: U32.add(s, 1)
    case _: 0
def b5k_chk_glam_case_hit(sc: ChkPair<SymTab, String>, c: Case) -> Bool:
  CP{sy, cnm} = sc
  +s1 = chk_glam_case_ref(c)
  Bool.and(U32.is_gt(s1, 0), b5k_chk_cname_match(symtab_name(sy, U32.sub(s1, 1)), cnm))
def b5k_chk_glam_has_cn(p: ChkPair<SymTab, List<&2, Case>>, cn: String) -> Bool:
  CP{sy, cs2} = p
  chk_any(~Case, ~ChkPair<SymTab, String>, ~b5k_chk_glam_case_hit, CP{sy, cn}, cs2)
def b5k_chk_glam_bad(+ctx: CheckCtx, goal: ChkTy, body: Expr) -> Bool:
  match goal body:
    case TFun{_, _, TCon{tn, _}, _} EMat{_, +cs}:
      has_w = chk_any(~Case, ~Unit, ~(_ => c => U32.is_zero(chk_glam_case_ref(c))), Unit{}, cs)
      exh = chk_maybe(
        List<&2, String>, Bool, b5k_chk_type_ctors(ctx, tn), True{},
        cns => chk_all(~String, ~ChkPair<SymTab, List<&2, Case>>, ~b5k_chk_glam_has_cn,
          CP{b5k_chk_ctx_syms(ctx), cs}, cns)
      )
      Bool.or(b5k_chk_glam_has_dup(cs, Nil{}), Bool.and(Bool.not(has_w), Bool.not(exh)))
    case _ EMat{_, cs}: b5k_chk_glam_has_dup(cs, Nil{})
    case _ _: False{}
def b5k_chk_lam_bind_arg(bs: List<&2, VarBind>, goal: ChkTy) -> List<&2, VarBind>:
  match bs goal:
    case Con{VarBind{s, d, er, loc, ic, TAny{}}, rest} TFun{pd, per, aty, r}:
      Con{VarBind{s, Bool.or(d, pd), Bool.or(er, Bool.and(per, Bool.not(b5k_chk_is_er_goal(r)))), loc, ic, aty}, rest}
    case Con{VarBind{s, d, er, loc, ic, ty}, rest} TFun{pd, per, _, r}:
      Con{VarBind{s, Bool.or(d, pd), Bool.or(er, Bool.and(per, Bool.not(b5k_chk_is_er_goal(r)))), loc, ic, ty}, rest}
    case other _: other
def b5k_chk_cd_eq(sc: ChkPair<SymTab, String>, c: CtorDef) -> Bool:
  CP{sy, cnm} = sc
  String.eq(symtab_name(sy, chk_cd_sym(c)), cnm)
def b5k_chk_tdef_bad_sugar(+syms: SymTab, types: RaVec<Maybe<&2, U32>>, ts: List<&2, TypeDef>, +tn: String,
  +cn: String) -> Bool:
  is_u = chk_maybe(U32, Bool, symtab_lookup(syms, tn), False{},
    id => U32.is_eq(Maybe.default(&2, U32, ct_get(U32, types, id), 0), 2))
  chk_if(
    Bool, is_u,
    _ => chk_maybe(
      TypeDef, Bool, b5k_chk_find_tdef(syms, ts, False{}, 0, tn), False{},
      td => Bool.not(chk_any(~CtorDef, ~ChkPair<SymTab, String>, ~b5k_chk_cd_eq, CP{syms, cn}, chk_td_cs(td)))
    ),
    _ => False{}
  )
def b5k_chk_lit_sugar_bad(ctx: CheckCtx, +got: String, is_num: Bool) -> Bool:
  CheckCtx{+syms, +types, _, _, _, _, +tdefs} = ctx
  match is_num:
    case True{}: Bool.or(b5k_chk_tdef_bad_sugar(syms, types, tdefs, "U32", "U32"),
      b5k_chk_tdef_bad_sugar(syms, types, tdefs, "Nat", "Zero"))
    case False{}:
      Bool.pick(
        Bool, String.eq(got, "String"),
        Bool.or(b5k_chk_tdef_bad_sugar(syms, types, tdefs, "String", "SCon"),
          b5k_chk_tdef_bad_sugar(syms, types, tdefs, "String", "SNil")),
        Bool.pick(
          Bool, String.eq(got, "Char"), b5k_chk_tdef_bad_sugar(syms, types, tdefs, "Char", "Chr"),
          Bool.pick(
            Bool, String.eq(got, "F32"), b5k_chk_tdef_bad_sugar(syms, types, tdefs, "F32", "F32"),
            Bool.pick(Bool, String.eq(got, "List"), b5k_chk_tdef_bad_sugar(syms, types, tdefs, "List", "Con"),
              False{})
          )
        )
      )
def b5k_chk_env_pos(env: List<&2, VarBind>, +sym: U32, +acc: U32) -> U32:
  match env:
    case Nil{}: 0
    case Con{VarBind{s, _, _, _, _, _}, rest}:
      Bool.pick(U32, U32.is_eq(s, sym), U32.add(acc, 1), b5k_chk_env_pos(rest, sym, U32.add(acc, 1)))
def b5k_chk_scruts_order_bad(+env: List<&2, VarBind>, es: List<&2, Expr>, +prev_pos: U32) -> Bool:
  match es:
    case Nil{}: False{}
    case Con{e, t}:
      +s1 = b5k_chk_scrut_sym(e)
      +pos = Bool.pick(U32, U32.is_gt(s1, 0), b5k_chk_env_pos(env, U32.sub(s1, 1), 0), 0)
      bad = Bool.and(U32.is_gt(prev_pos, 0), Bool.and(U32.is_gt(pos, 0), U32.is_le(pos, prev_pos)))
      Bool.or(bad, b5k_chk_scruts_order_bad(env, t, pos))
def b5k_chk_scruts_banned(+rc: RecCtx, es: List<&2, Expr>) -> Bool:
  RecCtx{_, _, _, _, _, _, _, _, bn, _} = rc
  match es:
    case Nil{}: False{}
    case Con{e, t}:
      +s1 = b5k_chk_scrut_sym(e)
      hit = Bool.and(U32.is_gt(s1, 0), b5k_chk_u32_mem(bn, U32.sub(s1, 1)))
      Bool.or(hit, b5k_chk_scruts_banned(rc, t))
def b5k_chk_op_leaves(+all: Bool, +fuel: Nat, e: Expr, +acc: List<&2, Expr>) -> List<&2, Expr>:
  match fuel e:
    case 0n x: Con{x, acc}
    case 1n+f EOp{+op, +a, +b}:
      Bool.pick(
        List<&2, Expr>, Bool.or(all, U32.is_lt(op, 20)),
        b5k_chk_op_leaves(all, f, a, b5k_chk_op_leaves(all, f, b, acc)), Con{EOp{op, a, b}, acc}
      )
    case _ x: Con{x, acc}
def b5k_chk_is_nontype_lr(lr: LookupRes) -> Bool:
  match lr:
    case LFound{_, _, _, t}:
      +tg = b5k_chk_ty_tag(t)
      Bool.and(U32.is_ge(tg, 3), Bool.and(U32.is_ne(tg, 5), U32.is_ne(tg, 7)))
    case LNotFound{}: False{}
def b5k_chk_u32_rem(xs: List<&2, U32>, +v: U32, +acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: acc
    case Con{+h, t}: b5k_chk_u32_rem(t, v, Bool.pick(List<&2, U32>, U32.is_eq(h, v), acc, Con{h, acc}))
def b5k_chk_pms_rem(pms: List<&2, Param>, bad: List<&2, U32>) -> List<&2, U32>:
  match pms:
    case Nil{}: bad
    case Con{Param{s, _, _, _}, t}: b5k_chk_pms_rem(t, b5k_chk_u32_rem(bad, s, Nil{}))
def b5k_chk_expr_cap_local(+fuel: Nat, +bad: List<&2, U32>, es: List<&2, Expr>) -> Bool:
  match fuel es:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+f Con{EVar{s}, t}: Bool.or(b5k_chk_u32_mem(bad, s), b5k_chk_expr_cap_local(f, bad, t))
    case 1n+f Con{ELam{pms, body}, t}:
      Bool.or(b5k_chk_expr_cap_local(f, b5k_chk_pms_rem(pms, bad), [body]), b5k_chk_expr_cap_local(f, bad, t))
    case 1n+f Con{e, t}: b5k_chk_expr_cap_local(f, bad, chk_expr_push(e, 0, t))
def b5k_chk_ctor_call_k(
  mc: Maybe<&2, CtorInfo>, types: RaVec<Maybe<&2, U32>>, defs: RaVec<Maybe<&2, DefInfo>>,
  env: List<&2, VarBind>, +s: U32
) -> Bool:
  match mc:
    case None{}: False{}
    case Some{_}:
      Bool.and(
        Bool.not(b5k_chk_binds_mem(env, s)),
        Bool.and(Bool.not(b5k_chk_is_some(DefInfo, ct_get(DefInfo, defs, s))),
          Bool.not(b5k_chk_is_type_flag(ct_get(U32, types, s))))
      )
def b5k_chk_is_ctor_call_bad(ctx: CheckCtx, env: List<&2, VarBind>, fun: Expr) -> Bool:
  CheckCtx{_, types, ctors, defs, _, _, _} = ctx
  match fun:
    case EVar{+s}: b5k_chk_ctor_call_k(ct_get(CtorInfo, ctors, s), types, defs, env, s)
    case _: False{}
def b5k_chk_op_goals(+fuel: Nat, e: Expr, +aty: ChkTy, +acc: List<&2, ChkTy>) -> List<&2, ChkTy>:
  match fuel e:
    case 0n _: Con{aty, acc}
    case 1n++f EOp{+op, +a, +b}:
      b_ty = Bool.pick(ChkTy, Bool.or(U32.is_eq(op, 8), U32.is_eq(op, 9)), TAny{}, aty)
      Bool.pick(List<&2, ChkTy>, U32.is_lt(op, 20), b5k_chk_op_goals(f, a, aty, b5k_chk_op_goals(f, b, b_ty, acc)),
        Con{aty, acc})
    case _ _: Con{aty, acc}
def b5k_chk_find_free_app_head(+ctx: CheckCtx, +env: List<&2, VarBind>, e: Expr) -> Maybe<&2, U32>:
  match e:
    case EApp{EVar{+s}, _}:
      Bool.pick(Maybe<&2, U32>,
        Bool.and(Bool.not(b5k_chk_binds_mem(env, s)), Bool.not(b5k_chk_is_known_global(ctx, s))), Some{s}, None{})
    case _: None{}
def b5k_chk_subst_dep_eq(m: Maybe<&2, U32>, +a1: Expr, lhs: Expr, rhs: Expr, car: ChkTy, st: Bool) -> ChkTy:
  match m:
    case None{}: TEq{lhs, rhs, car, st}
    case Some{+s0}: TEq{b5k_chk_subst_e(16n, s0, a1, lhs), b5k_chk_subst_e(16n, s0, a1, rhs), car, True{}}
def b5k_chk_subst_dep_ty(+fuel: Nat, +ctx: CheckCtx, +env: List<&2, VarBind>, +a1: Expr, t: ChkTy) -> ChkTy:
  match fuel t:
    case 0n x: x
    case 1n+f TFun{d, er, a, r}: TFun{d, er, a, b5k_chk_subst_dep_ty(f, ctx, env, a1, r)}
    case 1n+_ TEq{+lhs, +rhs, car, st}:
      m = Maybe.or(&2, U32, b5k_chk_find_free_app_head(ctx, env, rhs), b5k_chk_find_free_app_head(ctx, env, lhs))
      b5k_chk_subst_dep_eq(m, a1, lhs, rhs, car, st)
    case _ x: x
def b5k_chk_subst_call_atys(
  +ctx: CheckCtx, +env: List<&2, VarBind>, atys: List<&2, ChkTy>, args: List<&2, Expr>
) -> List<&2, ChkTy>:
  match atys args:
    case Con{t1, Con{t2, rest}} Con{ELam{+ps, +b}, Con{_, _}}:
      Con{t1, Con{b5k_chk_subst_dep_ty(8n, ctx, env, ELam{ps, b}, t2), rest}}
    case ts _: ts
def b5k_chk_let_destr_bad(+env: List<&2, VarBind>, pat: Pat, val: Expr) -> Bool:
  match pat val:
    case PCtr{_, _} EVar{v}: b5k_chk_lr_bad_scrut(b5k_chk_env_lookup(env, v), True{})
    case PPair{_, _} EApp{_, _}: True{}
    case _ _: False{}
def b5k_chk_pat_field_split(+csym: U32, +idx: Nat, p: Pat) -> Bool:
  match idx p:
    case _ PCtr{s, fs}:
      Bool.and(U32.is_eq(s, csym), Bool.not(p_pat_is_name(chk_nth(Pat, idx, fs, PWild{}))))
    case 1n PList{Con{_, Con{_, _}}}: True{}
    case _ _: False{}
def b5k_chk_cases_col_split(+csym: U32, +col: Nat, +fidx: Nat, cs: List<&2, Case>) -> Bool:
  match cs:
    case Nil{}: False{}
    case Con{Case{ps, _}, t}:
      Bool.or(b5k_chk_pat_field_split(csym, fidx, chk_nth(Pat, col, ps, PWild{})),
        b5k_chk_cases_col_split(csym, col, fidx, t))
def b5k_chk_split_fields(
  fs: List<&2, Pat>, +csym: U32, +col: Nat, +fidx: Nat, +rest: List<&2, Case>, +acc: List<&2, U32>
) -> List<&2, U32>:
  match fs:
    case Nil{}: acc
    case Con{PVar{s, _}, t}:
      hit = b5k_chk_cases_col_split(csym, col, fidx, rest)
      b5k_chk_split_fields(t, csym, col, Succ{fidx}, rest, Bool.pick(List<&2, U32>, hit, Con{s, acc}, acc))
    case Con{_, t}: b5k_chk_split_fields(t, csym, col, Succ{fidx}, rest, acc)
def b5k_chk_split_col_vars(ps: List<&2, Pat>, +col: Nat, +rest: List<&2, Case>, +acc: List<&2, U32>) -> List<&2, U32>:
  match ps:
    case Nil{}: acc
    case Con{PCtr{csym, fs}, t}: b5k_chk_split_col_vars(t, Succ{col}, rest,
      b5k_chk_split_fields(fs, csym, col, 0n, rest, acc))
    case Con{_, t}: b5k_chk_split_col_vars(t, Succ{col}, rest, acc)
def b5k_chk_def_first_pm_is_type(+syms: SymTab, md: Maybe<&2, Def>) -> Bool:
  match md:
    case Some{Def{_, Con{Param{_, Some{EVar{ts}}, _, _}, _}, _, _, _, _}}: String.eq(symtab_name(syms, ts), "Type")
    case _: False{}
def b5k_chk_td_pms_len(td: TypeDef) -> U32:
  TypeDef{_, ps, _, _} = td
  b5k_list_len(Param, ps)
def b5k_chk_do_hdr_bad(ctx: CheckCtx, +mname: String, +ntargs: U32) -> Bool:
  CheckCtx{+syms, _, _, _, _, dasts, tdefs} = ctx
  chk_maybe(
    TypeDef, Bool, b5k_chk_find_tdef(syms, tdefs, False{}, 0, mname), False{},
    td => chk_if(
      Bool, U32.is_gt(b5k_chk_td_pms_len(td), ntargs),
      _ => chk_maybe(
        U32, Bool, symtab_lookup(syms, mname ++ ".pure"), False{},
        psym => b5k_chk_def_first_pm_is_type(syms, ct_get(Def, dasts, psym))
      ),
      _ => False{}
    )
  )
def b5k_chk_is_def_targ_bad(ctx: CheckCtx, fun: Expr) -> Bool:
  CheckCtx{_, types, _, defs, _, _, _} = ctx
  match fun:
    case EAnn{EVar{+s}, ESet{}}:
      Bool.and(b5k_chk_is_some(DefInfo, ct_get(DefInfo, defs, s)),
        Bool.not(b5k_chk_is_type_flag(ct_get(U32, types, s))))
    case _: False{}
def b5k_chk_err_msg(c: U32, fn_name: String) -> String:
  match c:
    case 1: "check: " ++ fn_name ++ ": cannot apply non-function value"
    case 2: "check: " ++ fn_name ++ ": constructor requires braces Ctor{...}, not Ctor(...)"
    case 3: "check: " ++ fn_name ++ ": '<...>' type arguments only allowed on datatypes"
    case 4: "check: " ++ fn_name ++ ": invalid comptime '~' argument"
    case 5: "check: " ++ fn_name ++ ": cannot check lambda against equation (no funext)"
    case 6: "check: " ++ fn_name ++ ": match lambda requires type annotation"
    case 7: "check: " ++ fn_name ++ ": cannot match erased parameter in live region"
    case 8: "check: " ++ fn_name ++ ": non-exhaustive or duplicate constructor in match lambda"
    case 9: "check: " ++ fn_name ++ ": invalid match scrutinee"
    case 10: "check: " ++ fn_name ++ ": empty match on non-Empty type"
    case 11: "check: " ++ fn_name ++ ": invalid constructor destructure on local binder"
    case 12: "check: " ++ fn_name ++ ": bare constructor in let requires type annotation"
    case 13: "check: " ++ fn_name ++ ": '+' let binder requires Data type"
    case _: ""
def b5k_chk_app_pre_err(
  +ctx: CheckCtx, rc: RecCtx, +env: List<&2, VarBind>, +fn_name: String,
  +fun: Expr, +args: List<&2, Expr>, +nargs: U32, +nt: U32
) -> String:
  +ht = b5k_chk_ty_tag(b5k_chk_infer_head(ctx, env, fun))
  c3 = Bool.pick(U32, Bool.or(b5k_chk_comp_args_bad(args, False{}), b5k_chk_tilde_arity_bad(ctx, fun, nt)), 4, 0)
  c2 = Bool.pick(U32, b5k_chk_is_def_targ_bad(ctx, fun), 3, c3)
  c1 = Bool.pick(U32, b5k_chk_is_ctor_call_bad(ctx, env, fun), 2, c2)
  +c = Bool.pick(U32,
    Bool.and(U32.is_gt(nargs, 0), Bool.or(U32.is_eq(ht, 3), Bool.or(U32.is_eq(ht, 4), U32.is_ge(ht, 8)))), 1, c1)
  +s1 = chk_expr_sym1(fun)
  +aerr = Bool.pick(String, U32.is_zero(s1), "",
    b5k_chk_call_lookup(b5k_chk_env_lookup(env, U32.sub(s1, 1)), ctx, fn_name, U32.sub(s1, 1), nargs))
  e0 = Bool.pick(String, String.is_empty(aerr), b5k_chk_rec_call_err(rc, fun, args, fn_name), aerr)
  Bool.pick(String, U32.is_zero(c), e0, b5k_chk_err_msg(c, fn_name))
def b5k_chk_lam_pre_err(
  ctx: CheckCtx, env: List<&2, VarBind>, fn_name: String, goal: ChkTy, params: List<&2, Param>, body: Expr
) -> String:
  match goal params body:
    case TEq{_, _, _, _} _ _: b5k_chk_err_msg(5, fn_name)
    case TAny{} Con{Param{0, None{}, False{}, True{}}, Nil{}} EMat{Con{EVar{0}, Nil{}}, _}:
      b5k_chk_err_msg(6, fn_name)
    case g Con{Param{0, None{}, False{}, True{}}, Nil{}} EMat{Con{EVar{0}, Nil{}}, cs}:
      +g2: ChkTy = g
      c2 = Bool.pick(U32,
        Bool.and(Bool.not(b5k_chk_env_has_live_empty(env)),
          b5k_chk_glam_bad(ctx, g2, EMat{Con{EVar{0}, Nil{}}, cs})), 8, 0)
      b5k_chk_err_msg(Bool.pick(U32, b5k_chk_glam_er_bad(g2), 7, c2), fn_name)
    case _ _ _: ""
def b5k_chk_mat_pre_err(
  +ctx: CheckCtx, +rc: RecCtx, +env: List<&2, VarBind>, +fn_name: String,
  goal: ChkTy, +scruts: List<&2, Expr>, +stys: List<&2, ChkTy>, +cases: List<&2, Case>
) -> String:
  +is_nc = p_is_nil(Case, cases)
  +has_emp = b5k_chk_env_has_live_empty(env)
  bad_al = Bool.and(U32.is_ne(b5k_chk_rc_u32(3, rc), 0), Bool.not(is_nc))
  bad_ord = Bool.or(b5k_chk_scruts_order_bad(env, scruts, 0), b5k_chk_scruts_banned(rc, scruts))
  bad_emp = Bool.and(is_nc, Bool.not(Bool.pick(Bool, has_emp, True{}, b5k_chk_empty_mat_stys(ctx, stys))))
  +c = Bool.pick(U32,
    Bool.or(bad_al,
      Bool.or(bad_ord,
        b5k_chk_scrut_bad(env, b5k_chk_is_er_goal(goal), scruts, stys))), 9, Bool.pick(U32, bad_emp, 10, 0))
  exh_ok = Bool.or(has_emp, b5k_chk_exh_go(64n, ctx, EXMat{stys, b5k_chk_cases_pats(cases)}))
  Bool.pick(String, U32.is_zero(c), chk_err_if(Bool.not(exh_ok), fn_name, ": non-exhaustive match"),
    b5k_chk_err_msg(c, fn_name))
def b5k_chk_arg_env(is_c: Bool, er: Bool, env: List<&2, VarBind>) -> List<&2, VarBind>:
  match is_c er:
    case True{} _: b5k_chk_env_only_comp(env)
    case False{} True{}: b5k_chk_env_all_dup(env)
    case False{} False{}: env
def b5k_chk_var_0(
  bad: Bool, ctx: CheckCtx, cur_idx: U32, +fn_name: String, env: List<&2, VarBind>, goal: ChkTy, +sym: U32
) -> ExprRes:
  match bad:
    case True{}: ExprErr{"check: " ++ fn_name ++ ": non-decreasing 0-arg self-recursion"}
    case False{}: b5k_chk_var_lookup(b5k_chk_env_lookup(env, sym), ctx, cur_idx, fn_name, goal, sym, False{})
def b5k_chk_scruts_dups(+env: List<&2, VarBind>, es: List<&2, Expr>) -> List<&2, Bool>:
  match es:
    case Nil{}: Nil{}
    case Con{e, t}: Con{b5k_chk_expr_is_dup(env, e), b5k_chk_scruts_dups(env, t)}
def b5k_chk_scruts_syms(es: List<&2, Expr>) -> List<&2, U32>:
  match es:
    case Nil{}: Nil{}
    case Con{+e, t}: Con{Bool.pick(U32, U32.is_eq(b5k_chk_expr_tag(e), 2), chk_expr_sym1(e), 0),
      b5k_chk_scruts_syms(t)}
def b5k_chk_scruts_tys(+ctx: CheckCtx, +env: List<&2, VarBind>, es: List<&2, Expr>) -> List<&2, ChkTy>:
  match es:
    case Nil{}: Nil{}
    case Con{e, t}: Con{b5k_chk_infer_head(ctx, env, e), b5k_chk_scruts_tys(ctx, env, t)}
def b5k_chk_env_nc_locs(env: List<&2, VarBind>, +acc: List<&2, U32>) -> List<&2, U32>:
  match env:
    case Nil{}: acc
    case Con{VarBind{s, _, _, _, ic, _}, t}: b5k_chk_env_nc_locs(t, Bool.pick(List<&2, U32>, ic, acc, Con{s, acc}))
def b5k_chk_ssyms_upto(+env: List<&2, VarBind>, ss: List<&2, U32>, +acc: List<&2, U32>) -> List<&2, U32>:
  match ss:
    case Nil{}: acc
    case Con{+s, t}:
      b5k_chk_ssyms_upto(env, t,
        Bool.pick(List<&2, U32>, U32.is_gt(s, 0), b5k_chk_env_upto(env, U32.sub(s, 1), acc), acc))

def b5k_chk_lit_rc(
  ctx: CheckCtx, +rc: RecCtx, +mask: U32, goal: ChkTy, fn_name: String, got: String, is_num: Bool
) -> ExprRes:
  bad = Bool.and(U32.is_gt(mask, 0), U32.is_ne(U32.and(b5k_chk_rc_u32(2, rc), mask), 0))
  b5k_chk_lit(ctx, bad, U32.is_ne(b5k_chk_rc_u32(4, rc), 0), goal, fn_name, got, is_num)

# Main Expression Checker Workloop (100% Closure-Free Hot Path)
def b5k_chk_work(+fuel: Nat, +ctx: CheckCtx, +rc: RecCtx, +fn_name: String, w: ChkWork) -> ExprRes:
  match fuel w:
    case 0n _: ExprOk{Nil{}}
    case 1n+f WGuard{SNil{}, w2}: b5k_chk_work(f, ctx, rc, fn_name, w2)
    case 1n+_ WGuard{err, _}: ExprErr{err}
    case 1n+f WExpect{got, goal, w2}: b5k_chk_expect(ctx, fn_name, got, goal, b5k_chk_work(f, ctx, rc, fn_name, w2))
    case 1n+f WAppGo{+env, +goal, +fun, +args, nargs, +nt}:
      +cs = Maybe.default(&2, CallSig, b5k_chk_eq_call_sig(ctx, fun, args),
        b5k_chk_call_sig(ctx, env, fun, nargs, nt))
      rc_fn = Bool.pick(RecCtx, U32.is_eq(b5k_chk_expr_tag(fun), 2), b5k_chk_rc_clr(1, rc), rc)
      ers2 = b5k_chk_comp_ers(nt, ctx, fun, b5k_chk_sig_ers(cs))
      r_fn = b5k_chk_work(f, ctx, rc_fn, fn_name, WExpr{env, TAny{}, fun})
      r_ar = b5k_chk_work(f, ctx, rc, fn_name,
        WArgs{env, b5k_chk_subst_call_atys(ctx, env, b5k_chk_sig_args(cs), args), ers2,
          b5k_chk_def_ncomp(ctx, fun), args})
      b5k_chk_expect(ctx, fn_name, b5k_chk_sig_ret(cs), goal, b5k_chk_merge(False{}, fn_name, r_fn, r_ar))
    case 1n+f WLamGo{env, +goal, params, body}:
      +bs = b5k_chk_lam_bind_arg(b5k_chk_params_binds(ctx, b5k_chk_lam_dup(goal), params), goal)
      b5k_chk_strip_res(bs,
        b5k_chk_work(f, ctx, b5k_chk_rc_clr(2, rc), fn_name,
          WExpr{b5k_list_app(VarBind, bs, env), b5k_chk_lam_ret(goal), body}))
    case 1n+f WMatGo{+env, goal, +scruts, stys, cases}:
      r_sc = b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, Nil{}, Nil{}, 0, scruts})
      r_cs = b5k_chk_work(f, ctx, rc, fn_name,
        WCases{env, goal, b5k_chk_scruts_dups(env, scruts), stys, b5k_chk_scruts_syms(scruts), cases})
      b5k_chk_merge(False{}, fn_name, r_sc, r_cs)
    case 1n+f WArgs{_, _, _, _, Nil{}}: ExprOk{Nil{}}
    case 1n+f WArgs{+env, +gs, +ers, +nc, Con{EUnOp{1, +h}, t}}:
      nc_locs = b5k_chk_env_nc_locs(env, Nil{})
      g1 = b5k_chk_comp_goal_dup(chk_hd(Bool, ers, True{}), chk_hd(ChkTy, gs, TAny{}))
      r1 = b5k_chk_erased_res(
        True{},
        b5k_chk_work(f, ctx, rc, fn_name, WGuard{
          chk_err_if(b5k_chk_expr_cap_local(64n, nc_locs, [h]), fn_name,
            ": comptime '~' argument captures runtime variable"),
          WExpr{b5k_chk_env_only_comp(env), g1, h}
        })
      )
      nc2 = Bool.pick(U32, U32.is_gt(nc, 0), U32.sub(nc, 1), 0)
      b5k_chk_merge(False{}, fn_name, r1,
        b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, chk_tl(ChkTy, gs), chk_tl(Bool, ers), nc2, t}))
    case 1n+f WArgs{+env, +gs, +ers, +nc, Con{h, t}}:
      +is_c = U32.is_gt(nc, 0)
      +er = chk_hd(Bool, ers, False{})
      +is_ce = Bool.or(is_c, er)
      rc1 = Bool.pick(RecCtx, er, b5k_chk_rc_clr(0, rc), rc)
      g1 = Bool.pick(ChkTy, is_ce, b5k_chk_comp_goal_dup(True{}, chk_hd(ChkTy, gs, TAny{})),
        chk_hd(ChkTy, gs, TAny{}))
      r1 = b5k_chk_erased_res(is_ce, b5k_chk_work(f, ctx, rc1, fn_name, WExpr{b5k_chk_arg_env(is_c, er, env), g1, h}))
      nc2 = Bool.pick(U32, is_c, U32.sub(nc, 1), 0)
      b5k_chk_merge(False{}, fn_name, r1,
        b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, chk_tl(ChkTy, gs), chk_tl(Bool, ers), nc2, t}))
    case 1n+f WCases{_, _, _, _, _, Nil{}}: ExprOk{Nil{}}
    case 1n+f WCases{+env, +goal, +sdups, +stys, +ssyms, Con{Case{+pats, body}, +rest}}:
      +osub = b5k_chk_rc_sub(rc)
      ban = b5k_chk_split_col_vars(pats, 0n, rest, b5k_chk_sub_var_ban(pats, b5k_chk_ssyms_upto(env, ssyms, Nil{})))
      rc2 = b5k_chk_rc_add(
        rc, pats, ssyms, b5k_chk_pats_sub_p(False{}, pats, ssyms, osub, Nil{}),
        b5k_chk_pats_sub_p(True{}, pats, ssyms, osub, Nil{}), b5k_chk_pats_lit_max(b5k_chk_ctx_syms(ctx), pats,
          0), ban
      )
      rest_res = Bool.pick(ExprRes, b5k_chk_is_dead_tail(pats, rest), ExprOk{Nil{}},
        b5k_chk_work(f, ctx, rc, fn_name, WCases{env, goal, sdups, stys, ssyms, rest}))
      pr = b5k_chk_pats(U32.to_nat(1024), ctx, fn_name, b5k_chk_zip_pats(pats, sdups, stys, False{}), Nil{})
      r_arm = b5k_chk_work(f, ctx, rc2, fn_name,
        WCasePat{b5k_list_app(VarBind, b5k_chk_redup_binds(pats, ssyms, stys), env),
          b5k_chk_spec_goal(goal, pats, ssyms), pr, b5k_chk_wild_strip(pats, ssyms), body})
      Bool.pick(
        ExprRes, U32.is_eq(b5k_list_len(Pat, pats), b5k_list_len(ChkTy, stys)),
        b5k_chk_merge(True{}, fn_name, r_arm, rest_res),
        ExprErr{"check: " ++ fn_name ++ ": match case pattern count mismatch"}
      )
    case 1n+f WCasePat{_, _, PatErr{err}, _, _}: ExprErr{err}
    case 1n+f WCasePat{env, goal, PatOk{+bs}, ws, body}:
      b5k_chk_strip_res(b5k_list_app(VarBind, bs, ws),
        b5k_chk_work(f, ctx, rc, fn_name, WExpr{b5k_list_app(VarBind, bs, env), goal, body}))
    case 1n+f WStmtPat{_, _, PatErr{err}, _, _}: ExprErr{err}
    case 1n+f WStmtPat{+env, goal, PatOk{+bs0}, +val, rest}:
      +bs = b5k_chk_binds_mark_local(U32.is_eq(b5k_chk_expr_tag(val), 4), U32.is_eq(b5k_list_len(VarBind, bs0), 1),
        bs0)
      r_v = b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, TAny{}, val})
      r_b = b5k_chk_strip_res(bs,
        b5k_chk_work(f, ctx, rc, fn_name, WStmts{b5k_list_app(VarBind, bs, env), goal, rest}))
      b5k_chk_merge(False{}, fn_name, r_v, r_b)
    case 1n+f WStmts{_, _, Nil{}}: ExprOk{Nil{}}
    case 1n+f WStmts{_, _,
      Con{StBind{_, _}, Nil{}}}: ExprErr{"check: " ++ fn_name ++ ": do-block bind requires continuation"}
    case 1n+f WStmts{env, goal, Con{StBind{pat, val}, rest}}:
      b5k_chk_work(f, ctx, rc, fn_name,
        WStmtPat{env, goal, b5k_chk_pats(U32.to_nat(1024), ctx, fn_name, [PatItem{pat, False{}, TAny{}}], Nil{}),
          val, rest})
    case 1n+f WStmts{+env, goal, Con{StLet{+pat, +val}, rest}}:
      pr = b5k_chk_pats(U32.to_nat(1024), ctx, fn_name,
        [PatItem{pat, b5k_chk_expr_is_dup(env, val), b5k_chk_infer_head(ctx, env, val)}], Nil{})
      g_err = chk_err_if(Bool.not(p_pat_is_name(pat)), fn_name, ": do-block let requires a variable binder")
      b5k_chk_work(f, ctx, b5k_chk_rc_let(rc, pat, val), fn_name, WGuard{g_err, WStmtPat{env, goal, pr, val, rest}})
    case 1n+f WStmts{env, goal, Con{StExpr{val}, Nil{}}}: b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, goal, val})
    case 1n+f WStmts{+env, goal, Con{StExpr{val}, rest}}:
      b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, TAny{}, val}),
        b5k_chk_work(f, ctx, rc, fn_name, WStmts{env, goal, rest}))
    case 1n+f WStmts{env, goal, Con{StRet{val}, Nil{}}}: b5k_chk_work(f, ctx, rc, fn_name,
      WExpr{env, b5k_chk_monad_inner(goal), val})
    case 1n+f WStmts{+env, goal, Con{StRet{val}, rest}}:
      b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, TAny{}, val}),
        b5k_chk_work(f, ctx, rc, fn_name, WStmts{env, goal, rest}))
    case 1n+_ WExpr{_, _, EHole{}}: ExprErr{"check: " ++ fn_name ++ ": unfilled hole"}
    case 1n+f WExpr{_, _, EAnn{ENum{_}, EUnit{}}}: ExprOk{Nil{}}
    case 1n+f WExpr{_, goal, EAnn{ENum{_}, ESet{}}}:
      b5k_chk_lit(ctx, b5k_chk_lit_sugar_bad(ctx, "Nat", True{}), U32.is_ne(b5k_chk_rc_u32(4, rc), 0), goal, fn_name,
        "Nat", False{})
    case 1n+f WExpr{_, goal, ENum{_}}: b5k_chk_lit_rc(ctx, rc, 1, goal, fn_name, "U32", True{})
    case 1n+f WExpr{_, goal, EFlt{_}}: b5k_chk_lit_rc(ctx, rc, 2, goal, fn_name, "F32", False{})
    case 1n+f WExpr{_, goal, EChr{_}}: b5k_chk_lit_rc(ctx, rc, 4, goal, fn_name, "Char", False{})
    case 1n+f WExpr{_, goal, EStr{_}}: b5k_chk_lit_rc(ctx, rc, 8, goal, fn_name, "String", False{})
    case 1n+f WExpr{_, goal, EUnit{}}: b5k_chk_lit_rc(ctx, rc, 0, goal, fn_name, "Unit", False{})
    case 1n+f WExpr{_, goal, ERefl{}}:
      b5k_chk_refl_goal(ctx, b5k_chk_rc_u32(1, rc), b5k_chk_rc_can_neut(rc), fn_name, goal)
    case 1n+f WExpr{env, goal, EVar{+sym}}:
      b5k_chk_var_0(U32.is_eq(b5k_chk_rc_u32(0, rc), U32.add(sym, 1)), ctx, b5k_chk_rc_u32(1, rc), fn_name, env,
        goal, sym)
    case 1n+f WExpr{env, goal, ERef{+sym}}:
      b5k_chk_var_lookup(b5k_chk_env_lookup(env, sym), ctx, b5k_chk_rc_u32(1, rc), fn_name, goal, sym, True{})
    case 1n+f WExpr{+env, +goal, EApp{+fun, +args}}:
      +nargs = b5k_list_len(Expr, args)
      +nt = b5k_chk_count_tilde_args(args, 0)
      g_err = b5k_chk_app_pre_err(ctx, rc, env, fn_name, fun, args, nargs, nt)
      b5k_chk_work(f, ctx, rc, fn_name, WGuard{g_err, WAppGo{env, goal, fun, args, nargs, nt}})
    case 1n+f WExpr{+env, +goal, ELam{+params, +body}}:
      b5k_chk_work(f, ctx, rc, fn_name,
        WGuard{b5k_chk_lam_pre_err(ctx, env, fn_name, goal, params, body), WLamGo{env, goal, params, body}})
    case 1n+f WExpr{+env, _, ELet{PWild{}, EAnn{ERefl{}, EEq{+eq, +mot}}, body}}:
      r_eq = b5k_chk_erased_res(True{},
        b5k_chk_work(f, ctx, rc, fn_name,
          WGuard{chk_err_if(b5k_chk_rwt_eq_bad(ctx, env, eq, mot), fn_name,
            ": rewrite premise must be a matching equation"), WExpr{b5k_chk_env_all_dup(env), TAny{}, eq}}))
      b5k_chk_merge(False{}, fn_name, r_eq,
        b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, b5k_chk_rwt_body_goal(ctx, eq, mot), body}))
    case 1n+f WExpr{+env, +goal, ELet{+pat, +val, body}}:
      +vty = b5k_chk_infer_head(ctx, env, val)
      lc = Bool.pick(
        U32, b5k_chk_let_destr_bad(env, pat, val), 11,
        Bool.pick(U32, U32.is_eq(b5k_chk_expr_tag(val), 3), 12,
          Bool.pick(U32, b5k_chk_let_plus_bad(ctx, env, pat, val, vty), 13, 0))
      )
      pr = b5k_chk_pats(U32.to_nat(1024), ctx, fn_name, [PatItem{pat, b5k_chk_expr_is_dup(env, val), vty}], Nil{})
      g2 = Bool.pick(ChkTy, U32.is_eq(b5k_chk_expr_tag(val), 1), TAny{}, goal)
      b5k_chk_work(f, ctx, b5k_chk_rc_let(rc, pat, val), fn_name,
        WGuard{b5k_chk_err_msg(lc, fn_name), WStmtPat{env, g2, pr, val, [StExpr{body}]}})
    case 1n+f WExpr{+env, +goal, EMat{+scruts, +cases}}:
      +stys = b5k_chk_scruts_tys(ctx, env, scruts)
      g_err = b5k_chk_mat_pre_err(ctx, rc, env, fn_name, goal, scruts, stys, cases)
      b5k_chk_work(f, ctx, rc, fn_name, WGuard{g_err, WMatGo{env, goal, scruts, stys, cases}})
    case 1n+f WExpr{env, +goal, ECtr{sym, +fields}}:
      +info = b5k_chk_lookup_ctor(ctx, sym)
      g_err = chk_err_if(Bool.not(b5k_chk_ctor_ok(info, b5k_list_len(Expr, fields), goal)), fn_name,
        ": constructor does not belong to goal or field count differs")
      b5k_chk_work(f, ctx, rc, fn_name,
        WGuard{g_err, WArgs{env, b5k_chk_ctor_fgoals(info, goal), b5k_chk_ctor_flags(False{}, info), 0, fields}})
    case 1n+f WExpr{+env, +goal, EAnn{ELet{pat, val, body}, +typ}}:
      b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, goal, ELet{pat, val, EAnn{body, typ}}})
    case 1n+f WExpr{+env, +goal, EAnn{EOp{+op, +a, +b}, +typ}}:
      +is_er = U32.is_eq(b5k_chk_expr_tag(typ), 1)
      +is_cmp = b5k_chk_is_cmp_expr(EOp{op, a, b})
      +aty = b5k_chk_ann_cmp_ty(EOp{op, a, b}, b5k_chk_goal_expr(ctx, typ))
      want_g = Bool.and(Bool.not(is_er),
        Bool.and(U32.is_le(op, 9), Bool.and(Bool.not(U32.is_eq(op, 5)), Bool.not(is_cmp))))
      lgs = Bool.pick(List<&2, ChkTy>, want_g, b5k_chk_op_goals(32n, EOp{op, a, b}, aty, Nil{}), Nil{})
      r_op = b5k_chk_work(f, ctx, rc, fn_name,
        WArgs{b5k_chk_arg_env(False{}, Bool.or(is_er, is_cmp), env), lgs, Nil{}, 0,
          b5k_chk_op_leaves(is_cmp, 32n, EOp{op, a, b}, Nil{})})
      b5k_chk_expect(ctx, fn_name, aty, goal, b5k_chk_erased_res(is_er, r_op))
    case 1n+f WExpr{+env, +goal, EAnn{EDo{stmts}, EAnn{EApp{EVar{+msym}, targs}, ESet{}}}}:
      +mname = b5k_chk_sym_name(ctx, msym)
      g_err = chk_err_if(b5k_chk_do_hdr_bad(ctx, mname, b5k_list_len(Expr, targs)), fn_name,
        ": do-block header quantity padding mismatch")
      b5k_chk_work(f, ctx, rc, fn_name, WGuard{g_err, WExpect{b5k_chk_t0(mname), goal, WStmts{env, goal, stmts}}})
    case 1n+f WExpr{+env, +goal, EAnn{val, EAnn{EVar{+sym}, ESet{}}}}:
      g_err = chk_err_if(b5k_chk_is_nontype_lr(b5k_chk_env_lookup(env, sym)), fn_name,
        ": expected Type in do-block bind")
      r_t = b5k_chk_erased_res(True{},
        b5k_chk_work(f, ctx, rc, fn_name, WGuard{g_err, WExpr{env, TAny{}, EVar{sym}}}))
      b5k_chk_merge(False{}, fn_name, r_t, b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, goal, val}))
    case 1n+f WExpr{+env, +goal, EAnn{+val, +typ}}:
      +lm_c = b5k_chk_is_lammat_ctor(typ)
      +lm_gt = U32.is_gt(lm_c, 0)
      +lm_ci = Bool.pick(Maybe<&2, CtorInfo>, lm_gt, b5k_chk_lookup_ctor(ctx, U32.sub(lm_c, 1)), None{})
      +is_er = U32.is_eq(b5k_chk_expr_tag(typ), 1)
      +is_cmp = b5k_chk_is_cmp_expr(val)
      +aty = Bool.pick(ChkTy, lm_gt, TAny{}, b5k_chk_ann_cmp_ty(val, b5k_chk_goal_expr(ctx, typ)))
      g_v = Bool.pick(
        ChkTy, Bool.or(is_er, Bool.and(lm_gt, U32.is_gt(b5k_chk_ci_ar(lm_ci), 0))), TAny{},
        Bool.pick(ChkTy, Bool.or(lm_gt, b5k_chk_is_rwt_var(typ, val)), goal, Bool.pick(ChkTy, is_cmp, TAny{}, aty))
      )
      g_err = chk_err_if(Bool.and(lm_gt, Bool.not(b5k_chk_is_some(CtorInfo, lm_ci))), fn_name,
        ": unknown constructor in match lambda")
      r_a = b5k_chk_work(f, ctx, rc, fn_name,
        WGuard{g_err, WExpr{b5k_chk_arg_env(False{}, Bool.or(is_er, is_cmp), env), g_v, val}})
      b5k_chk_expect(ctx, fn_name, aty, goal, b5k_chk_erased_res(is_er, r_a))
    case 1n+f WExpr{env, _, EEq{a, b}}: b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, Nil{}, Nil{}, 0, [a, b]})
    case 1n+f WExpr{env, goal, EOp{+op, a, b}}:
      g_err = chk_err_if(U32.is_le(op, 4), fn_name, ": binary operator requires '(a op b : T)' type annotation")
      got = Bool.pick(ChkTy, U32.is_ge(op, 20), b5k_chk_t0("Bool"), TAny{})
      b5k_chk_work(f, ctx, rc, fn_name, WGuard{g_err, WExpect{got, goal, WArgs{env, Nil{}, Nil{}, 0, [a, b]}}})
    case 1n+f WExpr{env, _, EUnOp{+op, val}}:
      g_err = chk_err_if(U32.is_eq(op, 1), fn_name, ": '~' only allowed in template call arguments")
      b5k_chk_work(f, ctx, rc, fn_name, WGuard{g_err, WExpr{env, TAny{}, val}})
    case 1n+f WExpr{env, goal, EArrNew{elems}}:
      b5k_chk_expect(ctx, fn_name, b5k_chk_t0("Array"), goal,
        b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, Nil{}, Nil{}, 0, elems}))
    case 1n+f WExpr{env, _, EArrGet{arr, idx}}:
      b5k_chk_work(f, ctx, rc, fn_name,
        WArgs{env, Nil{}, Nil{}, 0, Con{arr, b5k_chk_op_leaves(False{}, 32n, idx, Nil{})}})
    case 1n+f WExpr{env, _, EArrSet{arr, idx, val}}:
      b5k_chk_work(f, ctx, rc, fn_name,
        WArgs{env, Nil{}, Nil{}, 0, Con{arr, Con{val, b5k_chk_op_leaves(False{}, 32n, idx, Nil{})}}})
    case 1n+f WExpr{+env, +goal, EIf{cond, then_e, else_e}}:
      r_c = b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, b5k_chk_t0("Bool"), cond})
      r_b = b5k_chk_merge(True{}, fn_name, b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, goal, then_e}),
        b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, goal, else_e}))
      b5k_chk_merge(False{}, fn_name, r_c, r_b)
    case 1n+f WExpr{env, goal, EDo{stmts}}: b5k_chk_work(f, ctx, rc, fn_name, WStmts{env, goal, stmts})
    case 1n+f WExpr{env, +goal, EPair{a, b}}:
      g_err = Bool.pick(String, b5k_chk_pair_goal_ok(goal), "", b5k_chk_head_err(fn_name, b5k_chk_t0("Sigma"), goal))
      b5k_chk_work(f, ctx, rc, fn_name, WGuard{g_err, WArgs{env, b5k_chk_pair_goals(goal), Nil{}, 0, [a, b]}})
    case 1n+f WExpr{env, +goal, EList{+elems}}:
      g_err = chk_err_if(U32.is_ne(U32.and(b5k_chk_rc_u32(2, rc), 16), 0), fn_name,
        ": shadowed List lacks literal constructor")
      b5k_chk_work(f, ctx, rc, fn_name,
        WGuard{g_err,
          WExpect{b5k_chk_t0("List"), goal, WArgs{env, b5k_chk_list_elem_goals(elems, goal), Nil{}, 0, elems}}})
    case 1n+f WExpr{_, goal, EAll{_, _}}:
      g_err = chk_err_if(U32.is_eq(b5k_chk_ty_tag(goal), 3), fn_name, ": function type is Type, not Data")
      b5k_chk_work(f, ctx, rc, fn_name, WGuard{g_err, WArgs{Nil{}, Nil{}, Nil{}, 0, Nil{}}})
    case 1n+_ WExpr{_, _, _}: ExprOk{Nil{}}

# Top-Level Book Checks & Entrypoint
def chk_seq_err(err: String, next: U32 -> String) -> String:
  match err:
    case SNil{}: next(0)
    case SCon{c, t}: SCon{c, t}
def chk_first_err(~A: Data, ~C: Data, ~f: C -> A -> String, +c: C, xs: List<&2, A>) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, t}: chk_seq_err(f(c, h), _ => chk_first_err(~A, ~C, ~f, c, t))
def b5k_chk_expr_err(r: ExprRes) -> String:
  match r:
    case ExprOk{_}: ""
    case ExprErr{err}: err
def b5k_chk_erased_goal(is_er: Bool, g: ChkTy) -> ChkTy:
  match is_er g:
    case True{} TAny{}: TErased{}
    case _ other: other
type FreeEnv is Data:
  FreeEnv{ctx: CheckCtx, env: List<&2, VarBind>}
def chk_sym_free(fe: FreeEnv, +sym: U32) -> Bool:
  FreeEnv{ctx, env} = fe
  Bool.and(Bool.not(b5k_chk_binds_mem(env, sym)), Bool.not(b5k_chk_is_known_global(ctx, sym)))
def b5k_chk_exs_goal(ctx: CheckCtx, env: List<&2, VarBind>, from_law: Bool, g: ChkTy) -> ChkTy:
  match from_law g:
    case True{} TEq{+a, +b, car, st}:
      has_f = chk_expr_sym_any(~FreeEnv, ~(fe => s => chk_sym_free(fe, s)), 3, 32n, FreeEnv{ctx, env}, [a, b])
      Bool.pick(ChkTy, has_f, b5k_chk_t0("Sigma"), TEq{a, b, car, st})
    case _ other: other
def b5k_chk_dup_pms(
  +syms: SymTab, +fn_name: String, +is_field: Bool, ps: List<&2, Param>, +seen: List<&2, U32>
) -> String:
  match ps:
    case Nil{}: ""
    case Con{Param{+s, _, _, _}, t}:
      hit = Bool.and(Bool.or(is_field, Bool.not(String.eq(symtab_name(syms, s), "_"))), b5k_chk_u32_mem(seen, s))
      msg = Bool.pick(String, is_field, ": duplicate field: ", ": duplicate parameter: ")
      Bool.pick(String, hit, "check: " ++ fn_name ++ msg ++ symtab_name(syms, s),
        b5k_chk_dup_pms(syms, fn_name, is_field, t, Con{s, seen}))
def b5k_chk_is_nd_kind(+syms: SymTab, e: Expr) -> Bool:
  match e:
    case EVar{sym}: b5k_chk_str_match(False{}, ["Type", "Kind"], symtab_name(syms, sym))
    case EApp{fun, _}: b5k_chk_is_nd_kind(syms, fun)
    case _: False{}
def chk_grade_num(e: Expr) -> U32:
  match e:
    case ENum{n}: U32.add(n, 1)
    case EAnn{ENum{n}, EUnit{}}: U32.add(n, 1)
    case _: 0
def b5k_chk_has_grade2(es: List<&2, Expr>) -> Bool:
  match es:
    case Nil{}: False{}
    case Con{e, t}: Bool.or(U32.is_eq(chk_grade_num(e), 3), b5k_chk_has_grade2(t))
def b5k_chk_ty_is_nondata(+syms: SymTab, +nd: List<&2, U32>, ty: Expr) -> Bool:
  match ty:
    case EAll{_, _}: True{}
    case EOp{5, a, b}: Bool.or(b5k_chk_ty_is_nondata(syms, nd, a), b5k_chk_ty_is_nondata(syms, nd, b))
    case EVar{+s}: Bool.or(b5k_chk_u32_mem(nd, s), b5k_chk_str_match(False{}, ["Type", "Kind"], symtab_name(syms, s)))
    case EApp{+fun, +args}:
      +s1 = chk_expr_sym1(fun)
      +g0 = chk_grade_num(chk_hd(Expr, args, EUnit{}))
      gp = Bool.and(
        U32.is_gt(s1, 0),
        b5k_chk_str_match(False{}, ["List", "Maybe", "Either", "Result", "Map", "Sigma", "Pair"],
          symtab_name(syms, U32.sub(s1, 1)))
      )
      Bool.or(
        Bool.and(gp, Bool.or(U32.is_eq(g0, 1), U32.is_eq(g0, 2))),
        Bool.and(Bool.not(b5k_chk_has_grade2(args)), b5k_chk_ty_is_nondata(syms, nd, fun))
      )
    case _: False{}
def b5k_chk_plus_pms(+syms: SymTab, +fn_name: String, ps: List<&2, Param>, +nd: List<&2, U32>) -> String:
  match ps:
    case Nil{}: ""
    case Con{Param{s, +mty, er, dup}, t}:
      hit = Bool.and(Bool.not(er),
        Bool.and(dup, chk_maybe(Expr, Bool, mty, False{}, ty => b5k_chk_ty_is_nondata(syms, nd, ty))))
      nd2 = Bool.pick(List<&2, U32>, chk_maybe(Expr, Bool, mty, False{}, ty => b5k_chk_is_nd_kind(syms, ty)),
        Con{s, nd}, nd)
      Bool.pick(String, hit, "check: " ++ fn_name ++ ": '+' binder requires Data type",
        b5k_chk_plus_pms(syms, fn_name, t, nd2))
def b5k_chk_ty_expr_err(+ctx: CheckCtx, +fuel: Nat, +chk_op: Bool, +fn_name: String, es: List<&2, Expr>) -> String:
  CheckCtx{_, types, ctors, _, _, _, _} = ctx
  match fuel es:
    case 0n _: ""
    case _ Nil{}: ""
    case 1n+f Con{ECtr{+s, fs}, t}:
      dt_bad = Bool.and(b5k_chk_is_type_flag(ct_get(U32, types, s)),
        Bool.not(b5k_chk_is_some(CtorInfo, ct_get(CtorInfo, ctors, s))))
      Bool.pick(
        String, dt_bad, "check: " ++ fn_name ++ ": datatype arguments require '<...>', not '{...}'",
        b5k_chk_ty_expr_err(ctx, f, chk_op, fn_name, b5k_list_app(Expr, fs, t))
      )
    case 1n+f Con{EApp{+fun, Con{EAnn{ENum{2}, EUnit{}}, Con{EOp{5, _, _}, Nil{}}}}, t}:
      +s1 = chk_unann_var(fun)
      hit = Bool.and(U32.is_gt(s1, 0), String.eq(b5k_chk_sym_name(ctx, U32.sub(s1, 1)), "List"))
      Bool.pick(String, hit, "check: " ++ fn_name ++ ": datatype arguments require '<...>', not '{...}'",
        b5k_chk_ty_expr_err(ctx, f, chk_op, fn_name, t))
    case 1n+_ Con{EAnn{_, EHole{}}, _}: "check: " ++ fn_name ++ ": datatype arguments require '<...>', not '{...}'"
    case 1n+f Con{EAnn{EOp{_, +a, +b}, EVar{tn}}, t}:
      bad = Bool.and(chk_op,
        Bool.and(String.eq(b5k_chk_sym_name(ctx, tn), "U32"),
          Bool.or(U32.is_eq(b5k_chk_expr_tag(a), 5), U32.is_eq(b5k_chk_expr_tag(b), 5))))
      Bool.pick(String, bad, "check: U32 operator given Nat literal",
        b5k_chk_ty_expr_err(ctx, f, chk_op, fn_name, t))
    case 1n+f Con{EOp{+op, a, b}, t}:
      bad = Bool.and(chk_op, U32.is_le(op, 4))
      Bool.pick(String, bad, "check: binary operator in type requires '(a op b : T)'",
        b5k_chk_ty_expr_err(ctx, f, chk_op, fn_name, Con{a, Con{b, t}}))
    case 1n+f Con{e, t}: b5k_chk_ty_expr_err(ctx, f, chk_op, fn_name, chk_expr_push(e, 2, t))
def b5k_chk_arg_is_nondata(+syms: SymTab, +tdefs: List<&2, TypeDef>, +nd_vars: List<&2, U32>, e: Expr) -> Bool:
  match e:
    case EAll{_, _}: True{}
    case EVar{+s}: Bool.or(b5k_chk_u32_mem(nd_vars, s), b5k_chk_td_is_nd(syms, tdefs, True{}, s, ""))
    case EApp{fun, _}:
      +s1 = chk_unann_var(fun)
      Bool.and(U32.is_gt(s1, 0), b5k_chk_td_is_nd(syms, tdefs, True{}, U32.sub(s1, 1), ""))
    case EAnn{v, _}: b5k_chk_arg_is_nondata(syms, tdefs, nd_vars, v)
    case _: False{}
def b5k_chk_db_zip(
  +syms: SymTab, +tdefs: List<&2, TypeDef>, +nd_vars: List<&2, U32>, ps: List<&2, Param>, args: List<&2, Expr>
) -> Bool:
  match ps args:
    case Con{Param{_, Some{EVar{s}}, _, _}, pt} Con{a, at}:
      Bool.or(Bool.and(String.eq(symtab_name(syms, s), "Data"), b5k_chk_arg_is_nondata(syms, tdefs, nd_vars, a)),
        b5k_chk_db_zip(syms, tdefs, nd_vars, pt, at))
    case Con{_, pt} Con{_, at}: b5k_chk_db_zip(syms, tdefs, nd_vars, pt, at)
    case _ _: False{}
def b5k_chk_db_td(
  syms: SymTab, tdefs: List<&2, TypeDef>, nd_vars: List<&2, U32>, args: List<&2, Expr>, td: TypeDef
) -> Bool:
  TypeDef{_, tps, _, _} = td
  b5k_chk_db_zip(syms, tdefs, nd_vars, tps, args)
def b5k_chk_ty_db_bad(
  +fuel: Nat, +syms: SymTab, +tdefs: List<&2, TypeDef>, +nd_vars: List<&2, U32>, es: List<&2, Expr>
) -> Bool:
  match fuel es:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+f Con{EApp{fun, +args}, t}:
      +s1 = chk_unann_var(fun)
      hit = Bool.and(
        U32.is_gt(s1, 0),
        chk_maybe(
          TypeDef, Bool, b5k_chk_find_tdef(syms, tdefs, True{}, U32.sub(s1, 1), ""), False{},
          td => b5k_chk_db_td(syms, tdefs, nd_vars, args, td)
        )
      )
      Bool.or(hit, b5k_chk_ty_db_bad(f, syms, tdefs, nd_vars, b5k_list_app(Expr, args, t)))
    case 1n+f Con{e, t}: b5k_chk_ty_db_bad(f, syms, tdefs, nd_vars, chk_expr_push(e, 2, t))
def b5k_chk_nondata_syms(+syms: SymTab, ps: List<&2, Param>, +acc: List<&2, U32>) -> List<&2, U32>:
  match ps:
    case Nil{}: acc
    case Con{Param{s, mty, _, _}, t}:
      b5k_chk_nondata_syms(syms, t,
        Bool.pick(List<&2, U32>, chk_maybe(Expr, Bool, mty, False{}, ty => b5k_chk_is_nd_kind(syms, ty)),
          Con{s, acc}, acc))
def b5k_chk_ret_targ_bad(ctx: CheckCtx, mret: Maybe<&2, Expr>) -> Bool:
  match mret:
    case Some{EApp{fun, _}}: b5k_chk_is_def_targ_bad(ctx, fun)
    case _: False{}
def b5k_chk_opt_es(m: Maybe<&2, Expr>, acc: List<&2, Expr>) -> List<&2, Expr>:
  match m:
    case None{}: acc
    case Some{e}: Con{e, acc}
def b5k_chk_pm_rc(_u: Unit, p: Param) -> U32:
  Param{s, _, er, _} = p
  Bool.pick(U32, er, 0, U32.add(s, 1))
def b5k_chk_def_imp(
  is_import: Bool, +ctx: CheckCtx, tdefs_nd: List<&2, U32>, +lit_bad: U32, +cur_idx: U32,
  +sym: U32, +params: List<&2, Param>, +ret: Maybe<&2, Expr>, body: Expr, imp_path: String, +fn_name: String
) -> String:
  match is_import:
    case True{}:
      ok = b5k_chk_str_match(False{}, [
        "IO.args", "IO.args_bytes", "IO.print", "IO.now", "IO.print_err",
        "File.open", "File.open_bytes", "File.read", "File.read_line", "File.read_bytes",
        "File.read_at", "File.size", "File.write", "File.write_at", "File.write_bytes",
        "File.close", "NativeHost.read", "NativeHost.path", "NativeHost.publish"
      ], fn_name)
      Bool.pick(String, ok, "", "compile: foreign provider unavailable in fixed runtime: " ++ fn_name)
    case False{}:
      CheckCtx{+syms, _, _, _, laws, _, tdefs} = ctx
      +ld = ct_get(LawDef, laws, sym)
      +mps = b5k_chk_apply_law_params(params, ld)
      +mret = b5k_chk_apply_law_ret(params, ret, ld)
      +e_db = chk_err_if(
        b5k_chk_ty_db_bad(64n, syms, tdefs, b5k_chk_nondata_syms(syms, mps, Nil{}), b5k_chk_opt_es(mret, Nil{})),
        fn_name, ": non-Data argument for Data-bounded type parameter"
      )
      +e_op = b5k_chk_ty_expr_err(ctx, 64n, True{}, fn_name, b5k_chk_opt_es(mret, Nil{}))
      +e_ut = chk_err_if(Bool.and(Bool.not(b5k_chk_is_some(Expr, ret)), Bool.not(b5k_chk_is_some(LawDef, ld))),
        fn_name, ": untyped def without matching law")
      +e_br = b5k_chk_ty_expr_err(ctx, U32.to_nat(128), False{}, fn_name, chk_pms_tys(mps, Nil{}))
      +e_rt = chk_err_if(b5k_chk_ret_targ_bad(ctx, mret), fn_name,
        ": '<...>' type arguments only allowed on datatypes")
      +e1 = Bool.pick(String, String.is_empty(e_db), e_op, e_db)
      +e2 = Bool.pick(String, String.is_empty(e1), e_ut, e1)
      +e3 = Bool.pick(String, String.is_empty(e2), e_br, e2)
      +e4 = Bool.pick(String, String.is_empty(e3), e_rt, e3)
      +e5 = Bool.pick(String, String.is_empty(e4), b5k_chk_dup_pms(syms, fn_name, False{}, mps, Nil{}), e4)
      pre = Bool.pick(String, String.is_empty(e5), b5k_chk_plus_pms(syms, fn_name, mps, tdefs_nd), e5)
      chk_seq_err(pre, _ => (
        +is_er = chk_maybe(Expr, Bool, mret, False{}, e => b5k_chk_expr_is_erased(syms, e));
        +env = b5k_chk_params_binds(ctx, is_er, mps);
        +is_uns = String.eq(imp_path, "@unsafe");
        from_law = Bool.and(Bool.not(b5k_chk_is_some(Expr, ret)), b5k_chk_is_some(LawDef, ld));
        goal = b5k_chk_exs_goal(ctx, env, from_law,
          b5k_chk_erased_goal(is_er, chk_maybe(Expr, ChkTy, mret, TAny{}, e => b5k_chk_goal_expr(ctx, e))));
        pms_rc = chk_map(~Param, ~U32, ~Unit, ~b5k_chk_pm_rc, Unit{}, mps);
        b5k_chk_expr_err(b5k_chk_work(
          U32.to_nat(4096), ctx,
          RecCtx{Bool.pick(U32, is_uns, 0, U32.add(sym, 1)), Bool.pick(U32, is_uns, 0, cur_idx), pms_rc, Nil{},
            Nil{}, 0, False{}, False{}, Nil{}, lit_bad},
          fn_name, WExpr{env, goal, body}
        ))
      ))
def b5k_chk_def(+ctx: CheckCtx, tdefs_nd: List<&2, U32>, lit_bad: U32, cur_idx: U32, d: Def) -> String:
  Def{+sym, params, ret, body, is_import, imp_path} = d
  b5k_chk_def_imp(is_import, ctx, tdefs_nd, lit_bad, cur_idx, sym, params, ret, body, imp_path,
    b5k_chk_sym_name(ctx, sym))
def b5k_chk_has_tdef(+syms: SymTab, ts: List<&2, TypeDef>, +nm: String) -> Bool:
  b5k_chk_is_some(TypeDef, b5k_chk_find_tdef(syms, ts, False{}, 0, nm))
def b5k_chk_is_reserved_def(+syms: SymTab, +ts: List<&2, TypeDef>, +nm: String) -> Bool:
  Bool.pick(
    Bool, b5k_chk_str_match(False{}, ["Nat.add", "Nat.sub", "Nat.mul"], nm),
    Bool.not(b5k_chk_has_tdef(syms, ts, "Nat")),
    Bool.pick(Bool, String.eq(nm, "U32"), Bool.not(b5k_chk_has_tdef(syms, ts, "U32")), False{})
  )
def b5k_chk_dup_defs_rv(ds: List<&2, Def>, dup: Bool, prev_s: U32, +syms: SymTab, +seen: RaVec<Bool>) -> String:
  match ds dup:
    case _ True{}: "check: duplicate declaration: " ++ symtab_name(syms, prev_s)
    case Nil{} False{}: ""
    case Con{Def{+s, _, _, _, _, _}, t} False{}:
      b5k_chk_dup_defs_rv(t, ra_vec_get(Bool, 8n, False{}, s, seen), s, syms, ra_vec_set(Bool, 8n, s, True{}, seen))
def b5k_chk_dup_ctors(+syms: SymTab, +tname: String, cs: List<&2, CtorDef>, +seen_c: List<&2, U32>) -> String:
  match cs:
    case Nil{}: ""
    case Con{CtorDef{+s, _, fs}, t}:
      e1 = Bool.pick(String, b5k_chk_u32_mem(seen_c, s), "check: duplicate constructor: " ++ symtab_name(syms, s),
        b5k_chk_dup_pms(syms, tname, True{}, fs, Nil{}))
      chk_seq_err(e1, _ => b5k_chk_dup_ctors(syms, tname, t, Con{s, seen_c}))
def b5k_chk_dup_types(+syms: SymTab, ts: List<&2, TypeDef>, +seen_t: List<&2, U32>, +seen_c: List<&2, U32>) -> String:
  match ts:
    case Nil{}: ""
    case Con{TypeDef{+s, _, _, +cs}, t}:
      +tn = symtab_name(syms, s)
      e1 = Bool.pick(String, b5k_chk_u32_mem(seen_t, s), "check: duplicate type: " ++ tn,
        b5k_chk_dup_ctors(syms, tn, cs, seen_c))
      sc2 = chk_fold(~CtorDef, ~List<&2, U32>, ~Unit, ~(_ => c => a => Con{chk_cd_sym(c), a}), Unit{}, cs, seen_c)
      chk_seq_err(e1, _ => b5k_chk_dup_types(syms, t, Con{s, seen_t}, sc2))
def b5k_chk_defs_go(
  ds: List<&2, Def>, +ctx: CheckCtx, +tdefs_nd: List<&2, U32>, +lit_bad: U32, +idx: U32
) -> String:
  match ds:
    case Nil{}: ""
    case Con{h, t}: chk_seq_err(b5k_chk_def(ctx, tdefs_nd, lit_bad, idx, h),
      _ => b5k_chk_defs_go(t, ctx, tdefs_nd, lit_bad, U32.add(idx, 1)))
def b5k_chk_tdef_nd_fold(_u: Unit, td: TypeDef, a: List<&2, U32>) -> List<&2, U32>:
  match td:
    case TypeDef{s, Nil{}, False{}, _}: Con{s, a}
    case _: a
def b5k_chk_defs(+ctx: CheckCtx, ds: List<&2, Def>, idx: U32) -> String:
  CheckCtx{_, _, _, _, _, _, tdefs} = ctx
  lb = U32.or(
    U32.or(Bool.pick(U32, b5k_chk_lit_sugar_bad(ctx, "U32", True{}), 1, 0),
      Bool.pick(U32, b5k_chk_lit_sugar_bad(ctx, "F32", False{}), 2, 0)),
    U32.or(
      Bool.pick(U32, b5k_chk_lit_sugar_bad(ctx, "Char", False{}), 4, 0),
      U32.or(Bool.pick(U32, b5k_chk_lit_sugar_bad(ctx, "String", False{}), 8, 0),
        Bool.pick(U32, b5k_chk_lit_sugar_bad(ctx, "List", False{}), 16, 0))
    )
  )
  nd_ts = chk_fold(~TypeDef, ~List<&2, U32>, ~Unit, ~b5k_chk_tdef_nd_fold, Unit{}, tdefs, Nil{})
  b5k_chk_defs_go(ds, ctx, nd_ts, lb, idx)

# Data-Kind Field Discipline, No-Base & Proof-Unsafe Checks
def b5k_chk_data_fields_bad(+is_data: Bool, +nd: List<&2, U32>, fs: List<&2, Param>) -> Bool:
  match fs:
    case Nil{}: False{}
    case Con{Param{_, Some{EAll{_, _}}, erased, dup}, t}:
      Bool.or(Bool.and(Bool.not(erased), Bool.or(is_data, dup)), b5k_chk_data_fields_bad(is_data, nd, t))
    case Con{Param{_, Some{EVar{sym}}, erased, dup}, t}:
      Bool.or(Bool.and(Bool.not(erased), Bool.and(Bool.or(is_data, dup), b5k_chk_u32_mem(nd, sym))),
        b5k_chk_data_fields_bad(is_data, nd, t))
    case Con{_, t}: b5k_chk_data_fields_bad(is_data, nd, t)
def b5k_chk_data_ctors_bad(+is_data: Bool, +syms: SymTab, +nd: List<&2, U32>, cs: List<&2, CtorDef>) -> Bool:
  match cs:
    case Nil{}: False{}
    case Con{CtorDef{_, _, +fs}, t}:
      Bool.or(b5k_chk_data_fields_bad(is_data, b5k_chk_nondata_syms(syms, fs, nd), fs),
        b5k_chk_data_ctors_bad(is_data, syms, nd, t))
def b5k_chk_nb_expr(+fuel: Nat, +fl: U32, es: List<&2, Expr>) -> String:
  match fuel es:
    case 0n _: ""
    case _ Nil{}: ""
    case 1n+f Con{EList{_}, t}:
      Bool.pick(String, U32.is_ne(U32.and(fl, 1), 0), b5k_chk_nb_expr(f, fl, t),
        "check: list literal requires List (import Base)")
    case 1n+f Con{EPair{a, b}, t}:
      Bool.pick(String, U32.is_ne(U32.and(fl, 4), 0), b5k_chk_nb_expr(f, fl, Con{a, Con{b, t}}),
        "check: tuple literal requires Sigma/Pair (import Base)")
    case 1n+f Con{ENum{v}, t}:
      Bool.pick(String, Bool.or(U32.is_ne(U32.and(fl, 8), 0), U32.is_le(v, 1)), b5k_chk_nb_expr(f, fl, t),
        "check: numeric literal requires Nat/U32 (import Base)")
    case 1n+f Con{EOp{21, a, b}, t}:
      Bool.pick(String, U32.is_ne(U32.and(fl, 2), 0), b5k_chk_nb_expr(f, fl, Con{a, Con{b, t}}),
        "check: '!=' requires Empty (import Base)")
    case 1n+f Con{EAnn{EAll{_, _}, ESet{}}, t}:
      Bool.pick(String, U32.is_ne(U32.and(fl, 16), 0), b5k_chk_nb_expr(f, fl, t),
        "check: inline exists '&' requires Exists (import Base)")
    case 1n+f Con{EApp{EAnn{_, ESet{}}, _}, t}: b5k_chk_nb_expr(f, fl, t)
    case 1n+f Con{e, t}: b5k_chk_nb_expr(f, fl, chk_expr_push(e, 1, t))
def b5k_chk_nb_def_err(f: U32, d: Def) -> String:
  Def{_, _, _, body, imp, _} = d
  Bool.pick(String, imp, "", b5k_chk_nb_expr(256n, f, [body]))
def b5k_chk_no_base_defs(+syms: SymTab, +tdefs: List<&2, TypeDef>, ds: List<&2, Def>) -> String:
  has_pair = Bool.or(b5k_chk_has_tdef(syms, tdefs, "Sigma"),
    Bool.or(b5k_chk_has_tdef(syms, tdefs, "Pair"), b5k_chk_has_tdef(syms, tdefs, "Tuple")))
  has_num = Bool.or(b5k_chk_has_tdef(syms, tdefs, "Nat"),
    Bool.or(b5k_chk_has_tdef(syms, tdefs, "U32"), b5k_chk_has_tdef(syms, tdefs, "Word")))
  fl = U32.or(
    U32.or(Bool.pick(U32, b5k_chk_has_tdef(syms, tdefs, "List"), 1, 0),
      Bool.pick(U32, b5k_chk_has_tdef(syms, tdefs, "Empty"), 2, 0)),
    U32.or(Bool.pick(U32, has_pair, 4, 0),
      U32.or(Bool.pick(U32, has_num, 8, 0), Bool.pick(U32, b5k_chk_has_tdef(syms, tdefs, "Exists"), 16, 0)))
  )
  chk_first_err(~Def, ~U32, ~b5k_chk_nb_def_err, fl, ds)
def chk_sym_unsafe(sy: SymTab, s: U32) -> Bool:
  b5k_chk_str_match(False{}, ["Array.join", "Array.fork", "Array.get_unchecked"], symtab_name(sy, s))
def chk_def_unsafe(+syms: SymTab, d: Def) -> Bool:
  match d:
    case Def{_, ps, mret, body, False{}, ip}:
      Bool.or(
        String.eq(ip, "@unsafe"),
        chk_expr_sym_any(~SymTab, ~chk_sym_unsafe, 2, U32.to_nat(256), syms,
          Con{body, chk_pms_tys(ps, b5k_chk_opt_es(mret, Nil{}))})
      )
    case _: False{}
def b5k_chk_td_unsafe(sy: SymTab, td: TypeDef) -> Bool:
  TypeDef{_, ps, _, cs} = td
  chk_expr_sym_any(~SymTab, ~chk_sym_unsafe, 2, U32.to_nat(256), sy, chk_pms_tys(ps, chk_ctors_tys(cs, Nil{})))
def b5k_chk_proof_unsafe(+syms: SymTab, ts: List<&2, TypeDef>, +ds: List<&2, Def>) -> String:
  has_m = chk_any(~Def, ~SymTab, ~(sy => d => String.eq(symtab_name(sy, chk_def_sym(d)), "main")), syms, ds)
  chk_if(
    String, has_m, _ => "",
    _ => Bool.pick(
      String,
      Bool.or(
        chk_any(~Def, ~SymTab, ~(sy => d => chk_def_unsafe(sy, d)), syms, ds),
        chk_any(~TypeDef, ~SymTab, ~b5k_chk_td_unsafe, syms, ts)
      ),
      "check: proof module relies on @unsafe", ""
    )
  )
def b5k_chk_law_err(p: ChkPair<SymTab, List<&2, Def>>, l: LawDef) -> String:
  CP{sy, ds} = p
  LawDef{+s, _, _} = l
  Bool.pick(String, b5k_chk_defs_has(ds, s), "", "check: law without def (TODO): " ++ symtab_name(sy, s))
def b5k_chk_td_data_err(+sy: SymTab, td: TypeDef) -> String:
  TypeDef{s, tps, is_d, cs} = td
  chk_err_if(b5k_chk_data_ctors_bad(is_d, sy, b5k_chk_nondata_syms(sy, tps, Nil{}), cs),
    symtab_name(sy, s), ": non-Data field in Data type")
def b5k_chk_td_db_err(p: ChkPair<SymTab, List<&2, TypeDef>>, td: TypeDef) -> String:
  CP{+sy, ts} = p
  TypeDef{s, tps, _, cs} = td
  chk_err_if(b5k_chk_ty_db_bad(U32.to_nat(256), sy, ts, b5k_chk_nondata_syms(sy, tps, Nil{}),
    chk_ctors_tys(cs, Nil{})), symtab_name(sy, s), ": non-Data argument for Data-bounded type parameter")
def b5k_check_ex(has_base: Bool, +book: Book) -> CheckRes:
  Book{+types, +defs, +laws, +syms} = book
  +err = chk_seq_err(b5k_chk_dup_types(syms, types, Nil{}, Nil{}), _ =>
    chk_seq_err(b5k_chk_dup_defs_rv(defs, False{}, 0, syms, RVEmpty{}), _ =>
      chk_seq_err(chk_first_err(~LawDef, ~ChkPair<SymTab, List<&2, Def>>, ~b5k_chk_law_err, CP{syms, defs}, laws),
        _ => chk_seq_err(chk_first_err(~TypeDef, ~SymTab, ~(sy => td => b5k_chk_td_data_err(sy, td)), syms, types),
          _ => chk_seq_err(
            chk_first_err(~TypeDef, ~ChkPair<SymTab, List<&2, TypeDef>>, ~b5k_chk_td_db_err, CP{syms, types}, types),
            _ => chk_seq_err(Bool.pick(String, has_base, "", b5k_chk_no_base_defs(syms, types, defs)), _ =>
              chk_seq_err(b5k_chk_proof_unsafe(syms, types, defs),
                _ => b5k_chk_defs(b5k_chk_build_ctx(types, defs, laws, syms), defs, 1))
            )
          )
        )
      )
    )
  )
  CheckRes{String.is_empty(err), err, book}
def b5k_check(+book: Book) -> CheckRes:
  b5k_check_ex(True{}, book)
