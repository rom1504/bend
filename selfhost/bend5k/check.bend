# bend5k/check.bend — 1-Pass Type, Scope, Constructor, Foreign & Affine Checker
# =============================================================================
# Validates a parsed `Book` in one total pass (0 `@unsafe` defs):
#   1. Symbol, type, constructor (with field types), def (with param/ret
#      parametric types) & law table indexing (+ Base builtins)
#   2. Foreign provider allowlist check (fixed runtime)
#   3. Constructor existence, arity, goal-type membership & field types
#   4. Affine / linearity use-count checking (non-dup vars <= 1 use per path)
#   5. Scope (unbound var/ref), direct Def call arity & parametric type checking
#      (return values, call args, ctor fields, match/if branches, let bindings)
type ChkTy is Data:
  TAny{}
  TErased{}
  TNonUniv{}
  TCon{head: String, args: List<&2, ChkTy>}
  TFun{pdup: Bool, per: Bool, arg: ChkTy, ret: ChkTy}
  TEq{lhs: Expr, rhs: Expr}
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
  CtorInfo{type_name: String, arity: U32, fdups: List<&2, Bool>, fers: List<&2, Bool>, ftys: List<&2, ChkTy>}
type CtorEntry is Data:
  CtorEntry{name: String, tname: String, arity: U32}
type DefInfo is Data:
  DefInfo{arity: U32, total_arity: U32, n_comp: U32, ret_arrows: U32, is_import: Bool, def_idx: U32, param_tys: List<&2, ChkTy>, live_tys: List<&2, ChkTy>, param_ers: List<&2, Bool>, ret_ty: ChkTy}
type CallSig is Data:
  CallSig{arg_tys: List<&2, ChkTy>, arg_ers: List<&2, Bool>, ret_ty: ChkTy}
def ct_set(-A: Data, t: RaVec<Maybe<&2, A>>, +k: U32, v: A) -> RaVec<Maybe<&2, A>>: ra_vec_set(Maybe<&2, A>, 8n, k, Some{v}, t)
def ct_get(-A: Data, t: RaVec<Maybe<&2, A>>, +k: U32) -> Maybe<&2, A>: ra_vec_get(Maybe<&2, A>, 8n, None{}, k, t)
type CheckCtx is Data:
  CheckCtx{syms: SymTab, types: RaVec<Maybe<&2, U32>>, ctors: RaVec<Maybe<&2, CtorInfo>>, defs: RaVec<Maybe<&2, DefInfo>>, laws: RaVec<Maybe<&2, LawDef>>, dasts: RaVec<Maybe<&2, Def>>, tdefs: List<&2, TypeDef>}
type VarBind is Data:
  VarBind{sym: U32, dup: Bool, erased: Bool, is_local: Bool, is_comp: Bool, typ: ChkTy}
type PatItem is Data:
  PatItem{pat: Pat, dup_inh: Bool, typ_inh: ChkTy}
type LookupRes is Data:
  LNotFound{}
  LFoundDup{erased: Bool, is_local: Bool, typ: ChkTy}
  LFoundLin{erased: Bool, is_local: Bool, typ: ChkTy}
type PatRes is Data:
  PatOk{binds: List<&2, VarBind>}
  PatErr{err: String}
type ExprRes is Data:
  ExprOk{uses: List<&2, U32>}
  ExprErr{err: String}
type ChkWork is Data:
  WExpr{env: List<&2, VarBind>, goal: ChkTy, e: Expr}
  WArgs{env: List<&2, VarBind>, goals: List<&2, ChkTy>, ers: List<&2, Bool>, ncomp: U32, es: List<&2, Expr>}
  WCases{env: List<&2, VarBind>, goal: ChkTy, sdups: List<&2, Bool>, stys: List<&2, ChkTy>, ssyms: List<&2, U32>, cs: List<&2, Case>}
  WCasePat{env: List<&2, VarBind>, goal: ChkTy, pr: PatRes, wstrip: List<&2, VarBind>, body: Expr}
  WStmts{env: List<&2, VarBind>, goal: ChkTy, ss: List<&2, Stmt>}
  WStmtPat{env: List<&2, VarBind>, goal: ChkTy, pr: PatRes, val: Expr, rest: List<&2, Stmt>}
# Fixed Runtime Allowlist & Built-in Base Tables
def b5k_chk_str_match(+is_pre: Bool, xs: List<&2, String>, +s: String) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{+h, t}: Bool.or(Bool.pick(Bool, is_pre, String.starts_with(s, h), String.eq(h, s)), b5k_chk_str_match(is_pre, t, s))
def b5k_chk_is_runtime_provider(+name: String) -> Bool:
  b5k_chk_str_match(False{}, ["IO.args", "IO.args_bytes", "IO.print", "IO.now", "IO.print_err",
    "File.open", "File.open_bytes", "File.read", "File.read_line", "File.read_bytes", "File.read_at",
    "File.size", "File.write", "File.write_at", "File.write_bytes", "File.close",
    "NativeHost.read", "NativeHost.path", "NativeHost.publish"], name)
def b5k_chk_base_type_names() -> List<&2, String>:
  ["Empty", "Unit", "Bool", "Cmp", "Either", "Sigma", "Pair", "Nat", "Maybe", "Result", "Poll", "List",
   "Word", "Word.Nil", "Word.Con", "U32", "F32", "Char", "String", "Array", "Image", "Tool", "Event",
   "Map", "IO", "IO.OP", "App", "File", "Socket", "Listener", "Window", "Audio", "Chan", "Quant", "Type", "Data", "Kind", "Set"]
def b5k_chk_is_universe(+name: String) -> Bool:
  Bool.or(Bool.or(String.eq(name, "Type"), String.eq(name, "Data")),
          Bool.or(String.eq(name, "Kind"), Bool.or(String.eq(name, "Set"), String.eq(name, "Quant"))))
def b5k_chk_is_base_name(+name: String) -> Bool:
  Bool.or(b5k_chk_str_match(True{}, ["U32.", "F32.", "Char.", "String.", "Bool.", "Nat.", "List.", "Maybe.",
    "Pair.", "Array.", "IO.", "Map.", "File.", "NativeHost.", "Either.", "Result.", "Sigma.", "Cmp.", "Word.",
    "Poll.", "Tool.", "Event.", "Image.", "App.", "Socket.", "Listener", "Window.", "Audio.", "Chan.", "Set.",
    "Base.", "Equal.", "Empty.", "Quant.", "TCP.", "UDP.", "Process."], name),
    b5k_chk_str_match(False{}, ["fst", "snd", "pair", "absurd", "id"], name))
def b5k_chk_base_ctors() -> List<&2, CtorEntry>:
  [CtorEntry{"Unit", "Unit", 0}, CtorEntry{"False", "Bool", 0}, CtorEntry{"True", "Bool", 0}, CtorEntry{"LT", "Cmp", 0},
   CtorEntry{"EQ", "Cmp", 0}, CtorEntry{"GT", "Cmp", 0}, CtorEntry{"Inl", "Either", 1}, CtorEntry{"Inr", "Either", 1},
   CtorEntry{"Tuple", "Sigma", 2}, CtorEntry{"Pair", "Pair", 2}, CtorEntry{"Zero", "Nat", 0}, CtorEntry{"Succ", "Nat", 1},
   CtorEntry{"None", "Maybe", 0}, CtorEntry{"Some", "Maybe", 1}, CtorEntry{"Fail", "Result", 1}, CtorEntry{"Done", "Result", 1},
   CtorEntry{"Ready", "Poll", 1}, CtorEntry{"Wait", "Poll", 1}, CtorEntry{"Nil", "List", 0}, CtorEntry{"Con", "List", 2},
   CtorEntry{"WNil", "Word.Nil", 0}, CtorEntry{"WCon", "Word.Con", 2}, CtorEntry{"U32", "U32", 1}, CtorEntry{"F32", "F32", 1},
   CtorEntry{"Chr", "Char", 1}, CtorEntry{"SNil", "String", 0}, CtorEntry{"SCon", "String", 2}, CtorEntry{"ALeaf", "Array", 1},
   CtorEntry{"ANode", "Array", 2}, CtorEntry{"MTip", "Map", 0}, CtorEntry{"MLeaf", "Map", 2}, CtorEntry{"MNode", "Map", 3},
   CtorEntry{"Emit", "IO.OP", 1}, CtorEntry{"Halt", "IO.OP", 2}, CtorEntry{"Exit", "IO.OP", 1}, CtorEntry{"Pix", "Image", 1},
   CtorEntry{"Qua", "Image", 4}, CtorEntry{"App", "App", 2},
   CtorEntry{"Key", "Event", 2}, CtorEntry{"Text", "Event", 1}, CtorEntry{"Press", "Event", 7}, CtorEntry{"Move", "Event", 5},
   CtorEntry{"Leave", "Event", 1}, CtorEntry{"Lost", "Event", 1}, CtorEntry{"Look", "Event", 2}, CtorEntry{"Scroll", "Event", 4},
   CtorEntry{"Focus", "Event", 1}, CtorEntry{"Close", "Event", 0},
   CtorEntry{"Tool.Mouse", "Tool", 0}, CtorEntry{"Tool.Finger", "Tool", 3}, CtorEntry{"Tool.Pen", "Tool", 5}]
# Built-in Base Function Type Signatures (conservative: unknown -> CallSig{Nil{}, Nil{}, TAny{}})
def b5k_chk_t0(nm: String) -> ChkTy: TCon{nm, Nil{}}
def b5k_chk_sig1(+a: String, +r: String) -> CallSig: CallSig{[b5k_chk_t0(a)], Nil{}, b5k_chk_t0(r)}
def b5k_chk_sig2(+a: String, +b: String, +r: String) -> CallSig: CallSig{[b5k_chk_t0(a), b5k_chk_t0(b)], Nil{}, b5k_chk_t0(r)}
def b5k_chk_sig_none() -> CallSig: CallSig{Nil{}, Nil{}, TAny{}}
def b5k_chk_builtin_u32(+nm: String, +nargs: U32) -> CallSig:
  match nargs:
    case 1:
      b1 = b5k_chk_str_match(False{}, ["U32.inc", "U32.not", "U32.shl", "U32.shr"], nm)
      b2 = b5k_chk_str_match(False{}, ["U32.is_zero", "U32.is_even"], nm)
      b3 = b5k_chk_str_match(False{}, ["U32.to_nat", "U32.log2", "U32.popcount", "U32.ctz"], nm)
      Bool.pick(CallSig, b1, b5k_chk_sig1("U32", "U32"),
      Bool.pick(CallSig, b2, b5k_chk_sig1("U32", "Bool"),
      Bool.pick(CallSig, b3, b5k_chk_sig1("U32", "Nat"),
      Bool.pick(CallSig, String.eq(nm, "U32.from_nat"), b5k_chk_sig1("Nat", "U32"),
      Bool.pick(CallSig, String.eq(nm, "U32.to_f32"), b5k_chk_sig1("U32", "F32"),
      Bool.pick(CallSig, String.eq(nm, "U32.show"), b5k_chk_sig1("U32", "String"), b5k_chk_sig_none()))))))
    case 2:
      b1 = b5k_chk_str_match(False{}, ["U32.add", "U32.sub", "U32.mul", "U32.div", "U32.mod", "U32.and", "U32.or", "U32.xor", "U32.min", "U32.max"], nm)
      b2 = b5k_chk_str_match(False{}, ["U32.is_eq", "U32.is_ne", "U32.is_lt", "U32.is_le", "U32.is_gt", "U32.is_ge"], nm)
      b3 = b5k_chk_str_match(False{}, ["U32.shln", "U32.shrn", "U32.pow"], nm)
      Bool.pick(CallSig, b1, b5k_chk_sig2("U32", "U32", "U32"),
      Bool.pick(CallSig, b2, b5k_chk_sig2("U32", "U32", "Bool"),
      Bool.pick(CallSig, b3, b5k_chk_sig2("U32", "Nat", "U32"),
      Bool.pick(CallSig, String.eq(nm, "U32.cmp"), b5k_chk_sig2("U32", "U32", "Cmp"), b5k_chk_sig_none()))))
    case _: b5k_chk_sig_none()
def b5k_chk_builtin_f32(+nm: String, +nargs: U32) -> CallSig:
  match nargs:
    case 1:
      b1 = b5k_chk_str_match(False{}, ["F32.neg", "F32.abs", "F32.sqrt", "F32.exp", "F32.log", "F32.log2", "F32.log10", "F32.sin", "F32.cos", "F32.tan", "F32.floor", "F32.ceil", "F32.trunc", "F32.round", "F32.square"], nm)
      Bool.pick(CallSig, b1, b5k_chk_sig1("F32", "F32"),
      Bool.pick(CallSig, String.eq(nm, "F32.to_u32"), b5k_chk_sig1("F32", "U32"),
      Bool.pick(CallSig, String.eq(nm, "F32.bits"), b5k_chk_sig1("F32", "U32"),
      Bool.pick(CallSig, String.eq(nm, "F32.to_nat"), b5k_chk_sig1("F32", "Nat"),
      Bool.pick(CallSig, String.eq(nm, "F32.from_nat"), b5k_chk_sig1("Nat", "F32"),
      Bool.pick(CallSig, String.eq(nm, "F32.show"), b5k_chk_sig1("F32", "String"), b5k_chk_sig_none()))))))
    case 2:
      b1 = b5k_chk_str_match(False{}, ["F32.add", "F32.sub", "F32.mul", "F32.div", "F32.mod", "F32.pow", "F32.atan2", "F32.min", "F32.max", "F32.hypot"], nm)
      b2 = b5k_chk_str_match(False{}, ["F32.is_eq", "F32.is_ne", "F32.is_lt", "F32.is_le", "F32.is_gt", "F32.is_ge"], nm)
      Bool.pick(CallSig, b1, b5k_chk_sig2("F32", "F32", "F32"),
      Bool.pick(CallSig, b2, b5k_chk_sig2("F32", "F32", "Bool"), b5k_chk_sig_none()))
    case _: b5k_chk_sig_none()
def b5k_chk_builtin_bool(+nm: String, +nargs: U32) -> CallSig:
  match nargs:
    case 1:
      Bool.pick(CallSig, String.eq(nm, "Bool.not"), b5k_chk_sig1("Bool", "Bool"),
      Bool.pick(CallSig, String.eq(nm, "Bool.to_u32"), b5k_chk_sig1("Bool", "U32"), b5k_chk_sig_none()))
    case 2:
      b1 = b5k_chk_str_match(False{}, ["Bool.and", "Bool.or", "Bool.xor"], nm)
      Bool.pick(CallSig, b1, b5k_chk_sig2("Bool", "Bool", "Bool"),
      Bool.pick(CallSig, String.eq(nm, "Bool.cmp"), b5k_chk_sig2("Bool", "Bool", "Cmp"), b5k_chk_sig_none()))
    case 4:
      Bool.pick(CallSig, String.eq(nm, "Bool.pick"), CallSig{[TAny{}, b5k_chk_t0("Bool"), TAny{}, TAny{}], [True{}, False{}, False{}, False{}], TAny{}}, b5k_chk_sig_none())
    case _: b5k_chk_sig_none()
def b5k_chk_builtin_other(+nm: String, +nargs: U32) -> CallSig:
  match nargs:
    case 1:
      b_cs = b5k_chk_str_match(False{}, ["Char.is_digit", "Char.is_upper", "Char.is_lower", "Char.is_alpha", "Char.is_space"], nm)
      b_cc = b5k_chk_str_match(False{}, ["Char.to_upper", "Char.to_lower"], nm)
      Bool.pick(CallSig, String.eq(nm, "Char.to_u32"), b5k_chk_sig1("Char", "U32"),
      Bool.pick(CallSig, String.eq(nm, "Char.from_u32"), b5k_chk_sig1("U32", "Char"),
      Bool.pick(CallSig, b_cs, b5k_chk_sig1("Char", "Bool"),
      Bool.pick(CallSig, b_cc, b5k_chk_sig1("Char", "Char"),
      Bool.pick(CallSig, String.eq(nm, "String.is_empty"), b5k_chk_sig1("String", "Bool"),
      Bool.pick(CallSig, String.eq(nm, "String.reverse"), b5k_chk_sig1("String", "String"),
      Bool.pick(CallSig, String.eq(nm, "String.length"), b5k_chk_sig1("String", "Nat"),
      Bool.pick(CallSig, String.eq(nm, "Nat.double"), b5k_chk_sig1("Nat", "Nat"), b5k_chk_sig_none()))))))))
    case 2:
      b_sb = b5k_chk_str_match(False{}, ["String.eq", "String.starts_with", "String.ends_with", "String.contains", "String.is_lt", "String.is_le", "String.is_gt", "String.is_ge"], nm)
      b_nn = b5k_chk_str_match(False{}, ["Nat.add", "Nat.sub", "Nat.mul", "Nat.min", "Nat.max", "Nat.div", "Nat.mod", "Nat.pow"], nm)
      b_nb = b5k_chk_str_match(False{}, ["Nat.is_lt", "Nat.is_eq", "Nat.is_ne", "Nat.is_le", "Nat.is_gt", "Nat.is_ge"], nm)
      Bool.pick(CallSig, String.eq(nm, "Char.is_eq"), b5k_chk_sig2("Char", "Char", "Bool"),
      Bool.pick(CallSig, String.eq(nm, "String.append"), b5k_chk_sig2("String", "String", "String"),
      Bool.pick(CallSig, b_sb, b5k_chk_sig2("String", "String", "Bool"),
      Bool.pick(CallSig, b_nn, b5k_chk_sig2("Nat", "Nat", "Nat"),
      Bool.pick(CallSig, b_nb, b5k_chk_sig2("Nat", "Nat", "Bool"), b5k_chk_sig_none())))))
    case _: b5k_chk_sig_none()
def b5k_chk_builtin_sig(+nm: String, +nargs: U32) -> CallSig:
  Bool.pick(CallSig, String.starts_with(nm, "U32."), b5k_chk_builtin_u32(nm, nargs),
  Bool.pick(CallSig, String.starts_with(nm, "F32."), b5k_chk_builtin_f32(nm, nargs),
  Bool.pick(CallSig, String.starts_with(nm, "Bool."), b5k_chk_builtin_bool(nm, nargs),
  b5k_chk_builtin_other(nm, nargs))))
# Parametric Type Extraction, Compatibility & Formatting
def b5k_chk_is_some(-A: Data, m: Maybe<&2, A>) -> Bool:
  match m:
    case Some{_}: True{}
    case None{}: False{}
def b5k_chk_is_type_flag(m: Maybe<&2, U32>) -> Bool:
  match m:
    case Some{v}: U32.is_eq(v, 1)
    case None{}: False{}
def b5k_chk_head_sym(syms: SymTab, types: RaVec<Maybe<&2, U32>>, +sym: U32) -> ChkTy:
  hit = b5k_chk_is_type_flag(ct_get(U32, types, sym))
  +nm = symtab_name(syms, sym)
  Bool.pick(ChkTy, b5k_chk_is_universe(nm), TErased{}, Bool.pick(ChkTy, hit, b5k_chk_t0(nm), TAny{}))
def b5k_chk_ty_app(rf: TyRes, ra: TyRes) -> TyRes:
  match rf ra:
    case TROne{TCon{h, a0}} TRMany{a1}: TROne{TCon{h, b5k_list_app(ChkTy, a0, a1)}}
    case TROne{TErased{}} _: TROne{TErased{}}
    case _ _: TROne{TNonUniv{}}
def b5k_chk_ty_cons(rh: TyRes, rt: TyRes) -> TyRes:
  match rh rt:
    case TROne{h} TRMany{t}: TRMany{Con{h, t}}
    case _ _: TRMany{Nil{}}
def b5k_chk_ty_sigma(r1: TyRes, r2: TyRes) -> TyRes:
  match r1 r2:
    case TROne{t1} TROne{t2}: TROne{TCon{"Sigma", [t1, t2]}}
    case _ _: TROne{b5k_chk_t0("Sigma")}
def b5k_chk_ty_fun(pdup: Bool, per: Bool, a: TyRes, r: TyRes) -> TyRes:
  match a r:
    case TROne{at} TROne{rt}: TROne{TFun{pdup, per, at, rt}}
    case TROne{at} _: TROne{TFun{pdup, per, at, TAny{}}}
    case _ TROne{rt}: TROne{TFun{pdup, per, TAny{}, rt}}
    case _ _: TROne{TFun{pdup, per, TAny{}, TAny{}}}
def b5k_chk_is_and(e: Expr) -> Bool:
  match e:
    case EOp{op, _, _}: U32.is_eq(op, B5K_OP_AND())
    case _: False{}
def b5k_chk_ty_w(+fuel: Nat, +syms: SymTab, +types: RaVec<Maybe<&2, U32>>, w: TyWork) -> TyRes:
  match fuel w:
    case 0n TWOne{_}: TROne{TAny{}}
    case 0n TWMany{_}: TRMany{Nil{}}
    case 1n+_ TWMany{Nil{}}: TRMany{Nil{}}
    case 1n+f TWMany{Con{h, t}}: b5k_chk_ty_cons(b5k_chk_ty_w(f, syms, types, TWOne{h}), b5k_chk_ty_w(f, syms, types, TWMany{t}))
    case 1n+_ TWOne{EVar{sym}}: TROne{b5k_chk_head_sym(syms, types, sym)}
    case 1n+_ TWOne{ERef{sym}}: TROne{b5k_chk_head_sym(syms, types, sym)}
    case 1n+f TWOne{EApp{EAnn{fun, ESet{}}, args}}: b5k_chk_ty_app(b5k_chk_ty_w(f, syms, types, TWOne{fun}), b5k_chk_ty_w(f, syms, types, TWMany{args}))
    case 1n+f TWOne{EApp{fun, args}}: b5k_chk_ty_app(b5k_chk_ty_w(f, syms, types, TWOne{fun}), b5k_chk_ty_w(f, syms, types, TWMany{args}))
    case 1n+f TWOne{EAll{Param{_, Some{aty}, +er, dup}, body}}: b5k_chk_ty_fun(Bool.or(er, dup), er, b5k_chk_ty_w(f, syms, types, TWOne{aty}), b5k_chk_ty_w(f, syms, types, TWOne{body}))
    case 1n+f TWOne{EAll{Param{_, None{}, +er, dup}, body}}: b5k_chk_ty_fun(Bool.or(er, dup), er, TROne{TAny{}}, b5k_chk_ty_w(f, syms, types, TWOne{body}))
    case 1n+_ TWOne{EEq{a, b}}: TROne{TEq{a, b}}
    case 1n+_ TWOne{EAnn{EOp{20, a, b}, _}}: TROne{TEq{a, b}}
    case 1n+_ TWOne{EAnn{EOp{21, a, b}, _}}: TROne{TFun{False{}, False{}, TEq{a, b}, b5k_chk_t0("Empty")}}
    case 1n+f TWOne{EOp{op, +a, +b}}:
      Bool.pick(TyRes, U32.is_eq(op, B5K_OP_AND()),
        Bool.pick(TyRes, Bool.or(b5k_chk_is_and(a), b5k_chk_is_and(b)), TROne{b5k_chk_t0("Sigma")},
          b5k_chk_ty_sigma(b5k_chk_ty_w(f, syms, types, TWOne{a}), b5k_chk_ty_w(f, syms, types, TWOne{b}))),
        TROne{TAny{}})
    case 1n+_ TWOne{ENum{0}}: TROne{b5k_chk_t0("&0")}
    case 1n+_ TWOne{ENum{1}}: TROne{b5k_chk_t0("&1")}
    case 1n+_ TWOne{ENum{2}}: TROne{b5k_chk_t0("&2")}
    case 1n+_ TWOne{_}: TROne{TAny{}}
def b5k_chk_ty_res_one(r: TyRes) -> ChkTy:
  match r:
    case TROne{t}: t
    case TRMany{_}: TAny{}
def b5k_chk_head_expr(+syms: SymTab, +types: RaVec<Maybe<&2, U32>>, e: Expr) -> ChkTy:
  b5k_chk_ty_res_one(b5k_chk_ty_w(32n, syms, types, TWOne{e}))
def b5k_chk_head_opt(+syms: SymTab, +types: RaVec<Maybe<&2, U32>>, opt: Maybe<&2, Expr>) -> ChkTy:
  match opt:
    case None{}: TAny{}
    case Some{e}: b5k_chk_head_expr(syms, types, e)
# Phase-1 Dependent Constant Evaluator (Closed Pure Expressions -> Value)
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
def b5k_chk_cv_ok(v: CVal) -> Bool:
  match v:
    case CVNone{}: False{}
    case _: True{}
def b5k_chk_cv_u32_op(a: CVal, b: CVal, op: U32) -> CVal:
  match a b:
    case CVNum{+x} CVNum{+y}:
      match op:
        case 0: CVNum{U32.add(x, y)}
        case 1: CVNum{U32.sub(x, y)}
        case 2: CVNum{U32.mul(x, y)}
        case 3: Bool.pick(CVal, U32.is_zero(y), CVNone{}, CVNum{U32.div(x, y)})
        case 4: Bool.pick(CVal, U32.is_zero(y), CVNone{}, CVNum{U32.mod(x, y)})
        case 5: CVNum{U32.and(x, y)}
        case 6: CVNum{U32.or(x, y)}
        case 7: CVNum{U32.xor(x, y)}
        case 20: CVBool{U32.is_eq(x, y)}
        case 21: CVBool{U32.is_ne(x, y)}
        case 22: CVBool{U32.is_lt(x, y)}
        case 23: CVBool{U32.is_le(x, y)}
        case 24: CVBool{U32.is_gt(x, y)}
        case 25: CVBool{U32.is_ge(x, y)}
        case _: CVNone{}
    case _ _: CVNone{}
def b5k_chk_cv_call1(+nm: String, v: CVal) -> CVal:
  match v:
    case CVNum{+x}:
      Bool.pick(CVal, String.eq(nm, "U32.inc"), CVNum{U32.add(x, 1)},
      Bool.pick(CVal, String.eq(nm, "U32.not"), CVNum{U32.not(x)},
      Bool.pick(CVal, String.eq(nm, "U32.is_zero"), CVBool{U32.is_zero(x)},
      Bool.pick(CVal, String.eq(nm, "Nat.double"), CVNum{U32.mul(x, 2)}, CVNone{}))))
    case CVBool{+b}: Bool.pick(CVal, String.eq(nm, "Bool.not"), CVBool{Bool.not(b)}, CVNone{})
    case _: CVNone{}
def b5k_chk_cv_call2(+nm: String, v1: CVal, v2: CVal) -> CVal:
  match v1 v2:
    case CVNum{+x} CVNum{+y}:
      Bool.pick(CVal, Bool.or(String.eq(nm, "U32.add"), String.eq(nm, "Nat.add")), CVNum{U32.add(x, y)},
      Bool.pick(CVal, Bool.or(String.eq(nm, "U32.sub"), String.eq(nm, "Nat.sub")), CVNum{U32.sub(x, y)},
      Bool.pick(CVal, Bool.or(String.eq(nm, "U32.mul"), String.eq(nm, "Nat.mul")), CVNum{U32.mul(x, y)},
      Bool.pick(CVal, String.eq(nm, "U32.is_eq"), CVBool{U32.is_eq(x, y)},
      Bool.pick(CVal, String.eq(nm, "U32.is_ne"), CVBool{U32.is_ne(x, y)},
      Bool.pick(CVal, String.eq(nm, "U32.is_lt"), CVBool{U32.is_lt(x, y)}, CVNone{}))))))
    case CVBool{+a} CVBool{+b}:
      Bool.pick(CVal, String.eq(nm, "Bool.and"), CVBool{Bool.and(a, b)},
      Bool.pick(CVal, String.eq(nm, "Bool.or"), CVBool{Bool.or(a, b)},
      Bool.pick(CVal, String.eq(nm, "Bool.xor"), CVBool{Bool.xor(a, b)}, CVNone{})))
    case CVStr{+a} CVStr{+b}:
      Bool.pick(CVal, String.eq(nm, "String.append"), CVStr{a ++ b},
      Bool.pick(CVal, String.eq(nm, "String.eq"), CVBool{String.eq(a, b)}, CVNone{}))
    case _ _: CVNone{}
def b5k_chk_cv_ctr(+syms: SymTab, +sym: U32, fs: List<&2, CVal>) -> CVal:
  match fs:
    case Nil{}:
      +nm = symtab_name(syms, sym)
      Bool.pick(CVal, String.eq(nm, "Zero"), CVNum{0},
      Bool.pick(CVal, String.eq(nm, "True"), CVBool{True{}},
      Bool.pick(CVal, String.eq(nm, "False"), CVBool{False{}}, CVCtr{sym, Nil{}})))
    case Con{CVNum{+k}, Nil{}}: Bool.pick(CVal, String.eq(symtab_name(syms, sym), "Succ"), CVNum{U32.add(k, 1)}, CVCtr{sym, [CVNum{k}]})
    case other: CVCtr{sym, other}
type CEnvBind is Data:
  CEnvBind{sym: U32, val: CVal}
def b5k_chk_cenv_get(cenv: List<&2, CEnvBind>, +sym: U32) -> CVal:
  match cenv:
    case Nil{}: CVNone{}
    case Con{CEnvBind{s, v}, t}: Bool.pick(CVal, U32.is_eq(s, sym), v, b5k_chk_cenv_get(t, sym))
def b5k_chk_cv_pat_bind(+syms: SymTab, pat: Pat, v: CVal, cenv: List<&2, CEnvBind>) -> Maybe<&2, List<&2, CEnvBind>>:
  match pat v:
    case PWild{} _: Some{cenv}
    case PVar{s, _} val: Some{Con{CEnvBind{s, val}, cenv}}
    case PNum{k} CVNum{x}: Bool.pick(Maybe<&2, List<&2, CEnvBind>>, U32.is_eq(k, x), Some{cenv}, None{})
    case PCtr{psym, Nil{}} CVBool{+b}:
      +nm = symtab_name(syms, psym)
      Bool.pick(Maybe<&2, List<&2, CEnvBind>>, Bool.or(Bool.and(b, String.eq(nm, "True")), Bool.and(Bool.not(b), String.eq(nm, "False"))), Some{cenv}, None{})
    case PCtr{psym, Nil{}} CVNum{x}:
      Bool.pick(Maybe<&2, List<&2, CEnvBind>>, Bool.and(String.eq(symtab_name(syms, psym), "Zero"), U32.is_zero(x)), Some{cenv}, None{})
    case PCtr{psym, Con{PVar{s, _}, Nil{}}} CVNum{+x}:
      Bool.pick(Maybe<&2, List<&2, CEnvBind>>, Bool.and(String.eq(symtab_name(syms, psym), "Succ"), U32.is_gt(x, 0)), Some{Con{CEnvBind{s, CVNum{U32.sub(x, 1)}}, cenv}}, None{})
    case PCtr{psym, Nil{}} CVCtr{csym, Nil{}}: Bool.pick(Maybe<&2, List<&2, CEnvBind>>, U32.is_eq(psym, csym), Some{cenv}, None{})
    case PCtr{psym, Con{PVar{s, _}, Nil{}}} CVCtr{csym, Con{v1, Nil{}}}: Bool.pick(Maybe<&2, List<&2, CEnvBind>>, U32.is_eq(psym, csym), Some{Con{CEnvBind{s, v1}, cenv}}, None{})
    case _ _: None{}
type CEnvStep is Data:
  CEnvStep{cenv: List<&2, CEnvBind>, e: Expr}
def b5k_chk_cv_mat_go(cs: List<&2, Case>, hit: Maybe<&2, List<&2, CEnvBind>>, body0: Expr, +syms: SymTab, +sv: CVal, +cenv: List<&2, CEnvBind>) -> Maybe<&2, CEnvStep>:
  match cs hit:
    case _ Some{ce2}: Some{CEnvStep{ce2, body0}}
    case Nil{} None{}: None{}
    case Con{Case{Con{p, Nil{}}, body}, rest} None{}: b5k_chk_cv_mat_go(rest, b5k_chk_cv_pat_bind(syms, p, sv, cenv), body, syms, sv, cenv)
    case Con{_, rest} None{}: b5k_chk_cv_mat_go(rest, None{}, body0, syms, sv, cenv)
def b5k_chk_cv_can_mat(v: CVal) -> Bool:
  match v:
    case CVNone{}: False{}
    case CVStr{_}: False{}
    case CVNeutVar{_}: False{}
    case CVNeutApp{_, _}: False{}
    case _: True{}
def b5k_chk_cv_mat_find(syms: SymTab, +sv: CVal, cs: List<&2, Case>, cenv: List<&2, CEnvBind>) -> Maybe<&2, CEnvStep>:
  Bool.pick(Maybe<&2, CEnvStep>, b5k_chk_cv_can_mat(sv), b5k_chk_cv_mat_go(cs, None{}, EUnit{}, syms, sv, cenv), None{})
def b5k_chk_cv_if_k(v: CVal, t: Expr, el: Expr) -> Maybe<&2, Expr>:
  match v:
    case CVBool{True{}}: Some{t}
    case CVBool{False{}}: Some{el}
    case _: None{}
def b5k_chk_cv_def0(md: Maybe<&2, Def>) -> Maybe<&2, Expr>:
  match md:
    case Some{Def{_, Nil{}, _, body, False{}, _}}: Some{body}
    case _: None{}
def b5k_chk_cv_def1(va: CVal, md: Maybe<&2, Def>) -> Maybe<&2, CEnvStep>:
  match md:
    case Some{Def{_, Con{Param{p1, _, False{}, _}, Nil{}}, _, body, False{}, _}}: Some{CEnvStep{[CEnvBind{p1, va}], body}}
    case _: None{}
def b5k_chk_cv_def2(va: CVal, vb: CVal, md: Maybe<&2, Def>) -> Maybe<&2, CEnvStep>:
  match md:
    case Some{Def{_, Con{Param{p1, _, False{}, _}, Con{Param{p2, _, False{}, _}, Nil{}}}, _, body, False{}, _}}: Some{CEnvStep{[CEnvBind{p1, va}, CEnvBind{p2, vb}], body}}
    case _: None{}
type CEvalWork is Data:
  CEExpr{cenv: List<&2, CEnvBind>, e: Expr}
  CEOpt{cenv: List<&2, CEnvBind>, me: Maybe<&2, Expr>}
  CEPairOpt{m: Maybe<&2, CEnvStep>}
def b5k_chk_cv_is_strict_neut(v: CVal) -> Bool:
  match v:
    case CVNeutVar{_}: True{}
    case CVNeutApp{_, _}: True{}
    case _: False{}
def b5k_chk_def_is_mat1(md: Maybe<&2, Def>) -> Bool:
  match md:
    case Some{Def{_, Con{Param{p1, _, False{}, _}, Nil{}}, _, EMat{Con{EVar{sc}, Nil{}}, _}, False{}, _}}: U32.is_eq(p1, sc)
    case _: False{}
def b5k_chk_def_is_mat2(md: Maybe<&2, Def>) -> Bool:
  match md:
    case Some{Def{_, Con{Param{p1, _, False{}, _}, Con{Param{_, _, False{}, _}, Nil{}}}, _, EMat{Con{EVar{sc}, Nil{}}, _}, False{}, _}}: U32.is_eq(p1, sc)
    case _: False{}
def b5k_chk_eval_w(+fuel: Nat, +allow_n: Bool, +syms: SymTab, +dasts: RaVec<Maybe<&2, Def>>, w: CEvalWork) -> CVal:
  match fuel w:
    case 0n _: CVNone{}
    case 1n+f CEOpt{ce, Some{e}}: b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{ce, e})
    case 1n+_ CEOpt{_, None{}}: CVNone{}
    case 1n+f CEPairOpt{Some{CEnvStep{ce, e}}}: b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{ce, e})
    case 1n+_ CEPairOpt{None{}}: CVNone{}
    case 1n+_ CEExpr{_, ENum{v}}: CVNum{v}
    case 1n+_ CEExpr{_, EFlt{b}}: CVFlt{b}
    case 1n+_ CEExpr{_, EChr{c}}: CVChr{c}
    case 1n+_ CEExpr{_, EStr{s}}: CVStr{s}
    case 1n+_ CEExpr{cenv, EVar{+sym}}:
      +cv = b5k_chk_cenv_get(cenv, sym)
      is_g = b5k_chk_is_some(Def, ct_get(Def, dasts, sym))
      Bool.pick(CVal, b5k_chk_cv_ok(cv), cv, Bool.pick(CVal, Bool.and(allow_n, Bool.not(is_g)), CVNeutVar{sym}, CVNone{}))
    case 1n+f CEExpr{cenv, ELam{Con{Param{p, _, _, _}, Nil{}}, body}}:
      Bool.pick(CVal, allow_n, b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{Con{CEnvBind{p, CVNeutVar{0}}, cenv}, body}), CVNone{})
    case 1n+f CEExpr{cenv, EAnn{v, _}}: b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{cenv, v})
    case 1n++f CEExpr{+cenv, EOp{op, a, b}}: b5k_chk_cv_u32_op(b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{cenv, a}), b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{cenv, b}), op)
    case 1n++f CEExpr{+cenv, EIf{c, t, el}}: b5k_chk_eval_w(f, allow_n, syms, dasts, CEOpt{cenv, b5k_chk_cv_if_k(b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{cenv, c}), t, el)})
    case 1n++f CEExpr{+cenv, EMat{Con{sc, Nil{}}, cs}}:
      +sv = b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{cenv, sc})
      Bool.pick(CVal, b5k_chk_cv_ok(sv), b5k_chk_eval_w(f, allow_n, syms, dasts, CEPairOpt{b5k_chk_cv_mat_find(syms, sv, cs, cenv)}), CVNone{})
    case 1n+f CEExpr{_, ECtr{sym, Nil{}}}: b5k_chk_cv_ctr(syms, sym, Nil{})
    case 1n+f CEExpr{cenv, ECtr{sym, Con{a, Nil{}}}}:
      +va = b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{cenv, a})
      Bool.pick(CVal, b5k_chk_cv_ok(va), b5k_chk_cv_ctr(syms, sym, [va]), CVNone{})
    case 1n++f CEExpr{+cenv, ECtr{sym, Con{a, Con{b, Nil{}}}}}:
      +va = b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{cenv, a})
      +vb = b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{cenv, b})
      Bool.pick(CVal, Bool.and(b5k_chk_cv_ok(va), b5k_chk_cv_ok(vb)), b5k_chk_cv_ctr(syms, sym, [va, vb]), CVNone{})
    case 1n++f CEExpr{+cenv, EPair{a, b}}:
      +va = b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{cenv, a})
      +vb = b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{cenv, b})
      Bool.pick(CVal, Bool.and(b5k_chk_cv_ok(va), b5k_chk_cv_ok(vb)), CVPair{va, vb}, CVNone{})
    case 1n+f CEExpr{_, EApp{EVar{+sym}, Nil{}}}:
      b5k_chk_eval_w(f, allow_n, syms, dasts, CEOpt{Nil{}, b5k_chk_cv_def0(ct_get(Def, dasts, sym))})
    case 1n++f CEExpr{cenv, EApp{EVar{+sym}, Con{a, Nil{}}}}:
      +va = b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{cenv, a})
      +r0 = b5k_chk_cv_call1(symtab_name(syms, sym), va)
      +md = ct_get(Def, dasts, sym)
      +r1 = Bool.pick(CVal, b5k_chk_cv_ok(r0), r0, Bool.pick(CVal, b5k_chk_cv_ok(va), b5k_chk_eval_w(f, allow_n, syms, dasts, CEPairOpt{b5k_chk_cv_def1(va, md)}), CVNone{}))
      can_st = Bool.and(allow_n, Bool.and(b5k_chk_cv_is_strict_neut(va), b5k_chk_def_is_mat1(md)))
      Bool.pick(CVal, b5k_chk_cv_ok(r1), r1, Bool.pick(CVal, can_st, CVNeutApp{sym, [va]}, CVNone{}))
    case 1n++f CEExpr{+cenv, EApp{EVar{+sym}, Con{a, Con{b, Nil{}}}}}:
      +va = b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{cenv, a})
      +vb = b5k_chk_eval_w(f, allow_n, syms, dasts, CEExpr{cenv, b})
      +nm = symtab_name(syms, sym)
      +r0 = b5k_chk_cv_call2(nm, va, vb)
      +md = ct_get(Def, dasts, sym)
      +r1 = Bool.pick(CVal, b5k_chk_cv_ok(r0), r0, Bool.pick(CVal, Bool.and(b5k_chk_cv_ok(va), b5k_chk_cv_ok(vb)), b5k_chk_eval_w(f, allow_n, syms, dasts, CEPairOpt{b5k_chk_cv_def2(va, vb, md)}), CVNone{}))
      can_st = Bool.and(allow_n, Bool.and(b5k_chk_cv_is_strict_neut(va), Bool.and(b5k_chk_cv_ok(vb), Bool.or(b5k_chk_def_is_mat2(md), String.eq(nm, "Nat.add")))))
      Bool.pick(CVal, b5k_chk_cv_ok(r1), r1, Bool.pick(CVal, can_st, CVNeutApp{sym, [va, vb]}, CVNone{}))
    case _ _: CVNone{}
def b5k_chk_eval_c(fuel: Nat, allow_n: Bool, syms: SymTab, dasts: RaVec<Maybe<&2, Def>>, cenv: List<&2, CEnvBind>, e: Expr) -> CVal:
  b5k_chk_eval_w(fuel, allow_n, syms, dasts, CEExpr{cenv, e})
def b5k_chk_cv_neq(+fuel: Nat, a: CVal, b: CVal) -> Bool:
  match fuel a b:
    case 0n _ _: False{}
    case _ CVNone{} _: False{}
    case _ _ CVNone{}: False{}
    case _ CVNum{x} CVNum{y}: U32.is_ne(x, y)
    case _ CVFlt{x} CVFlt{y}: U32.is_ne(x, y)
    case _ CVChr{x} CVChr{y}: U32.is_ne(x, y)
    case _ CVStr{x} CVStr{y}: Bool.not(String.eq(x, y))
    case _ CVBool{x} CVBool{y}: Bool.xor(x, y)
    case _ CVNeutVar{s1} CVNeutVar{s2}: U32.is_ne(s1, s2)
    case _ CVNeutVar{_} CVNum{_}: True{}
    case _ CVNum{_} CVNeutVar{_}: True{}
    case _ CVNeutVar{_} CVBool{_}: True{}
    case _ CVBool{_} CVNeutVar{_}: True{}
    case _ CVNeutVar{_} CVCtr{_, _}: True{}
    case _ CVCtr{_, _} CVNeutVar{_}: True{}
    case _ CVNeutVar{_} CVNeutApp{_, _}: True{}
    case _ CVNeutApp{_, _} CVNeutVar{_}: True{}
    case 1n+f CVNeutApp{s1, Nil{}} CVNeutApp{s2, Nil{}}: U32.is_ne(s1, s2)
    case 1n+f CVNeutApp{s1, Con{x1, Nil{}}} CVNeutApp{s2, Con{x2, Nil{}}}: Bool.or(U32.is_ne(s1, s2), b5k_chk_cv_neq(f, x1, x2))
    case 1n+f CVNeutApp{s1, Con{x1, Con{y1, Nil{}}}} CVNeutApp{s2, Con{x2, Con{y2, Nil{}}}}: Bool.or(U32.is_ne(s1, s2), Bool.or(b5k_chk_cv_neq(f, x1, x2), b5k_chk_cv_neq(f, y1, y2)))
    case _ CVNeutApp{s1, _} CVNeutApp{s2, _}: U32.is_ne(s1, s2)
    case _ CVNeutApp{_, _} CVCtr{_, _}: True{}
    case _ CVCtr{_, _} CVNeutApp{_, _}: True{}
    case _ CVNeutApp{_, _} CVNum{_}: True{}
    case _ CVNum{_} CVNeutApp{_, _}: True{}
    case 1n+f CVPair{a1, b1} CVPair{a2, b2}: Bool.or(b5k_chk_cv_neq(f, a1, a2), b5k_chk_cv_neq(f, b1, b2))
    case 1n+f CVCtr{s1, Nil{}} CVCtr{s2, Nil{}}: U32.is_ne(s1, s2)
    case 1n+f CVCtr{s1, Con{x1, Nil{}}} CVCtr{s2, Con{x2, Nil{}}}: Bool.or(U32.is_ne(s1, s2), b5k_chk_cv_neq(f, x1, x2))
    case 1n+f CVCtr{s1, Con{x1, Con{y1, Nil{}}}} CVCtr{s2, Con{x2, Con{y2, Nil{}}}}: Bool.or(U32.is_ne(s1, s2), Bool.or(b5k_chk_cv_neq(f, x1, x2), b5k_chk_cv_neq(f, y1, y2)))
    case _ CVCtr{s1, _} CVCtr{s2, _}: U32.is_ne(s1, s2)
    case _ _ _: False{}
def b5k_chk_expr_neq(+ctx: CheckCtx, +allow_n: Bool, a: Expr, b: Expr) -> Bool:
  CheckCtx{syms, _, _, _, _, dasts, _} = ctx
  b5k_chk_cv_neq(16n, b5k_chk_eval_c(24n, allow_n, syms, dasts, Nil{}, a), b5k_chk_eval_c(24n, allow_n, syms, dasts, Nil{}, b))
def b5k_chk_ty_zip(a1: List<&2, ChkTy>, a2: List<&2, ChkTy>, acc: List<&2, TyPair>) -> List<&2, TyPair>:
  match a1 a2:
    case Con{h1, t1} Con{h2, t2}: b5k_chk_ty_zip(t1, t2, Con{TyPair{h1, h2}, acc})
    case _ _: acc
def b5k_chk_ty_zip_eq(+a1: List<&2, ChkTy>, +a2: List<&2, ChkTy>, +acc: List<&2, TyPair>) -> List<&2, TyPair>:
  Bool.pick(List<&2, TyPair>, U32.is_eq(b5k_list_len(ChkTy, a1), b5k_list_len(ChkTy, a2)), b5k_chk_ty_zip(a1, a2, acc), acc)
def b5k_chk_bool_compat(+h1: String, +h2: String) -> Bool:
  b = Bool.or(Bool.and(String.eq(h1, "Bool"), String.ends_with(h2, ".Bool")), Bool.and(String.eq(h2, "Bool"), String.ends_with(h1, ".Bool")))
  l = Bool.or(Bool.and(String.eq(h1, "List"), String.ends_with(h2, ".List")), Bool.and(String.eq(h2, "List"), String.ends_with(h1, ".List")))
  g = Bool.or(Bool.and(String.eq(h1, "&2"), String.eq(h2, "&1")), Bool.or(Bool.and(String.eq(h1, "&2"), String.eq(h2, "&0")), Bool.and(String.eq(h1, "&1"), String.eq(h2, "&0"))))
  Bool.or(String.eq(h1, h2), Bool.or(b, Bool.or(l, g)))
def b5k_chk_ty_ok_go(+fuel: Nat, +ctx: CheckCtx, q: List<&2, TyPair>) -> Bool:
  match fuel q:
    case 0n _: True{}
    case _ Nil{}: True{}
    case 1n+f Con{TyPair{TAny{}, _}, rest}: b5k_chk_ty_ok_go(f, ctx, rest)
    case 1n+f Con{TyPair{_, TAny{}}, rest}: b5k_chk_ty_ok_go(f, ctx, rest)
    case 1n+f Con{TyPair{TNonUniv{}, _}, rest}: b5k_chk_ty_ok_go(f, ctx, rest)
    case 1n+f Con{TyPair{_, TNonUniv{}}, rest}: b5k_chk_ty_ok_go(f, ctx, rest)
    case 1n+f Con{TyPair{TErased{}, _}, rest}: b5k_chk_ty_ok_go(f, ctx, rest)
    case 1n+f Con{TyPair{_, TErased{}}, rest}: b5k_chk_ty_ok_go(f, ctx, rest)
    case 1n+f Con{TyPair{TFun{d1, _, a1, r1}, TFun{d2, _, a2, r2}}, rest}:
      Bool.pick(Bool, Bool.and(d1, Bool.not(d2)), False{}, b5k_chk_ty_ok_go(f, ctx, Con{TyPair{a1, a2}, Con{TyPair{r1, r2}, rest}}))
    case 1n+f Con{TyPair{TFun{_, _, _, _}, TCon{h, _}}, rest}: Bool.pick(Bool, String.eq(h, "Sigma"), b5k_chk_ty_ok_go(f, ctx, rest), False{})
    case 1n+f Con{TyPair{TCon{h, _}, TFun{_, _, _, _}}, rest}: Bool.pick(Bool, String.eq(h, "Sigma"), b5k_chk_ty_ok_go(f, ctx, rest), False{})
    case 1n+f Con{TyPair{TFun{_, _, _, _}, _}, rest}: b5k_chk_ty_ok_go(f, ctx, rest)
    case 1n+f Con{TyPair{_, TFun{_, _, _, _}}, rest}: b5k_chk_ty_ok_go(f, ctx, rest)
    case 1n+f Con{TyPair{TEq{a1, b1}, TEq{a2, b2}}, rest}:
      Bool.pick(Bool, Bool.or(b5k_chk_expr_neq(ctx, False{}, a1, a2), b5k_chk_expr_neq(ctx, False{}, b1, b2)), False{}, b5k_chk_ty_ok_go(f, ctx, rest))
    case 1n+f Con{TyPair{TEq{a, b}, TCon{+h, _}}, rest}:
      Bool.pick(Bool, Bool.or(String.eq(h, "Equal"), Bool.and(String.eq(h, "Empty"), b5k_chk_expr_neq(ctx, False{}, a, b))), b5k_chk_ty_ok_go(f, ctx, rest), False{})
    case 1n+f Con{TyPair{TCon{h, _}, TEq{_, _}}, rest}: Bool.pick(Bool, String.eq(h, "Equal"), b5k_chk_ty_ok_go(f, ctx, rest), False{})
    case 1n+f Con{TyPair{TCon{h1, a1}, TCon{h2, a2}}, rest}:
      Bool.pick(Bool, b5k_chk_bool_compat(h1, h2), b5k_chk_ty_ok_go(f, ctx, b5k_chk_ty_zip_eq(a1, a2, rest)), False{})
    case 1n+f Con{_, rest}: b5k_chk_ty_ok_go(f, ctx, rest)
def b5k_chk_head_ok(ctx: CheckCtx, got: ChkTy, goal: ChkTy) -> Bool: b5k_chk_ty_ok_go(64n, ctx, [TyPair{got, goal}])
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
    case 1n+f Con{TSOne{TAny{}}, rest}: "_" ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TNonUniv{}}, rest}: "TypeFamily" ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TErased{}}, rest}: "Type" ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TFun{_, _, _, _}}, rest}: "Fn" ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TEq{_, _}}, rest}: "Equal" ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TCon{h, Nil{}}}, rest}: h ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TCon{h, args}}, rest}: h ++ "<" ++ b5k_chk_ty_show_go(f, b5k_chk_ty_show_args(args, Con{TSSep{">"}, rest}))
def b5k_chk_ty_show(t: ChkTy) -> String: b5k_chk_ty_show_go(64n, [TSOne{t}])
def b5k_chk_head_err(fn_name: String, got: ChkTy, goal: ChkTy) -> String:
  "check: " ++ fn_name ++ ": type mismatch (expected " ++ b5k_chk_ty_show(goal) ++ ", got " ++ b5k_chk_ty_show(got) ++ ")"
def b5k_chk_expect(ctx: CheckCtx, fn_name: String, +got: ChkTy, +goal: ChkTy, res: ExprRes) -> ExprRes:
  Bool.pick(ExprRes, b5k_chk_head_ok(ctx, got, goal), res, ExprErr{b5k_chk_head_err(fn_name, got, goal)})
# Symbol, Type, Constructor, Def & Law Indexing
def b5k_chk_param_dups(ps: List<&2, Param>) -> List<&2, Bool>:
  match ps:
    case Nil{}: Nil{}
    case Con{Param{_, _, erased, dup}, rest}: Con{Bool.or(erased, dup), b5k_chk_param_dups(rest)}
def b5k_chk_param_ers(ps: List<&2, Param>) -> List<&2, Bool>:
  match ps:
    case Nil{}: Nil{}
    case Con{Param{_, _, erased, _}, rest}: Con{erased, b5k_chk_param_ers(rest)}
def b5k_chk_param_tys(+syms: SymTab, +types: RaVec<Maybe<&2, U32>>, ps: List<&2, Param>) -> List<&2, ChkTy>:
  match ps:
    case Nil{}: Nil{}
    case Con{Param{_, typ, _, _}, rest}: Con{b5k_chk_head_opt(syms, types, typ), b5k_chk_param_tys(syms, types, rest)}
def b5k_chk_live_tys(+syms: SymTab, +types: RaVec<Maybe<&2, U32>>, ps: List<&2, Param>) -> List<&2, ChkTy>:
  match ps:
    case Nil{}: Nil{}
    case Con{Param{_, typ, erased, _}, rest}:
      +tail = b5k_chk_live_tys(syms, types, rest)
      Bool.pick(List<&2, ChkTy>, erased, tail, Con{b5k_chk_head_opt(syms, types, typ), tail})
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
    case Con{CtorEntry{nm, tn, ar}, rest}: b5k_chk_seed_base_ctors(syms, rest, ct_set_maybe(CtorInfo, symtab_lookup(syms, nm), CtorInfo{tn, ar, Nil{}, Nil{}, Nil{}}, cm))
def b5k_chk_index_ctors(+syms: SymTab, +tm: RaVec<Maybe<&2, U32>>, +tname: String, cs: List<&2, CtorDef>, cm: RaVec<Maybe<&2, CtorInfo>>) -> RaVec<Maybe<&2, CtorInfo>>:
  match cs:
    case Nil{}: cm
    case Con{CtorDef{csym, _, +fields}, rest}:
      b5k_chk_index_ctors(syms, tm, tname, rest, ct_set(CtorInfo, cm, csym, CtorInfo{tname, b5k_list_len(Param, fields), b5k_chk_param_dups(fields), b5k_chk_param_ers(fields), b5k_chk_param_tys(syms, tm, fields)}))
def b5k_chk_index_types(ts: List<&2, TypeDef>, tm: RaVec<Maybe<&2, U32>>) -> RaVec<Maybe<&2, U32>>:
  match ts:
    case Nil{}: tm
    case Con{TypeDef{tsym, _, _, _}, rest}: b5k_chk_index_types(rest, ct_set(U32, tm, tsym, 1))
def b5k_chk_unseed_pms(ps: List<&2, Param>, tm: RaVec<Maybe<&2, U32>>) -> RaVec<Maybe<&2, U32>>:
  match ps:
    case Nil{}: tm
    case Con{Param{sym, _, _, _}, rest}: b5k_chk_unseed_pms(rest, ct_set(U32, tm, sym, 0))
def b5k_chk_index_all_ctors(+syms: SymTab, +tm: RaVec<Maybe<&2, U32>>, ts: List<&2, TypeDef>, cm: RaVec<Maybe<&2, CtorInfo>>) -> RaVec<Maybe<&2, CtorInfo>>:
  match ts:
    case Nil{}: cm
    case Con{TypeDef{tsym, tps, _, ctors}, rest}: b5k_chk_index_all_ctors(syms, tm, rest, b5k_chk_index_ctors(syms, b5k_chk_unseed_pms(tps, tm), symtab_name(syms, tsym), ctors, cm))
def b5k_chk_count_live(ps: List<&2, Param>, +acc: U32) -> U32:
  match ps:
    case Nil{}: acc
    case Con{Param{_, _, erased, _}, rest}: b5k_chk_count_live(rest, Bool.pick(U32, erased, acc, U32.add(acc, 1)))
def b5k_chk_count_arrows(tm: RaVec<Maybe<&2, U32>>, e: Expr, +acc: U32) -> U32:
  match e:
    case EAll{_, body}: b5k_chk_count_arrows(tm, body, U32.add(acc, 1))
    case EVar{s}: Bool.pick(U32, b5k_chk_is_type_flag(ct_get(U32, tm, s)), acc, U32.add(acc, 16))
    case EApp{EVar{s}, _}: Bool.pick(U32, b5k_chk_is_type_flag(ct_get(U32, tm, s)), acc, U32.add(acc, 16))
    case _: U32.add(acc, 16)
def b5k_chk_ret_arrows(tm: RaVec<Maybe<&2, U32>>, ret: Maybe<&2, Expr>) -> U32:
  match ret:
    case Some{e}: b5k_chk_count_arrows(tm, e, 0)
    case None{}: 16
def b5k_chk_opt_or(-A: Data, a: Maybe<&2, A>, b: Maybe<&2, A>) -> Maybe<&2, A>:
  match a:
    case Some{x}: Some{x}
    case None{}: b
def b5k_chk_merge_law_params(ps: List<&2, Param>, lps: List<&2, Param>) -> List<&2, Param>:
  match ps lps:
    case Nil{} _: Nil{}
    case Con{p, prest} Nil{}: Con{p, prest}
    case Con{Param{sym, typ, er, dup}, prest} Con{Param{_, ltyp, ler, ldup}, lrest}: Con{Param{sym, b5k_chk_opt_or(Expr, typ, ltyp), Bool.or(er, ler), Bool.or(dup, ldup)}, b5k_chk_merge_law_params(prest, lrest)}
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
  match ds:
    case Nil{}: False{}
    case Con{Def{s, _, _, _, _, _}, t}: Bool.or(U32.is_eq(s, sym), b5k_chk_defs_has(t, sym))
def b5k_chk_param_mem(ps: List<&2, Param>, +sym: U32) -> Bool:
  match ps:
    case Nil{}: False{}
    case Con{Param{s, _, _, _}, t}: Bool.or(U32.is_eq(s, sym), b5k_chk_param_mem(t, sym))
def b5k_chk_law_has_free_var(+fuel: Nat, +syms: SymTab, +tm: RaVec<Maybe<&2, U32>>, +ds: List<&2, Def>, +ps: List<&2, Param>, es: List<&2, Expr>) -> Bool:
  match fuel es:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+f Con{EVar{+sym}, t}:
      is_g = Bool.or(b5k_chk_is_base_name(symtab_name(syms, sym)), Bool.or(b5k_chk_is_type_flag(ct_get(U32, tm, sym)), b5k_chk_defs_has(ds, sym)))
      is_f = Bool.and(Bool.not(b5k_chk_param_mem(ps, sym)), Bool.not(is_g))
      Bool.or(is_f, b5k_chk_law_has_free_var(f, syms, tm, ds, ps, t))
    case 1n+f Con{EApp{_, args}, t}: b5k_chk_law_has_free_var(f, syms, tm, ds, ps, b5k_list_app(Expr, args, t))
    case 1n+f Con{ECtr{_, fs}, t}: b5k_chk_law_has_free_var(f, syms, tm, ds, ps, b5k_list_app(Expr, fs, t))
    case 1n+f Con{EOp{_, a, b}, t}: b5k_chk_law_has_free_var(f, syms, tm, ds, ps, Con{a, Con{b, t}})
    case 1n+f Con{EAnn{v, _}, t}: b5k_chk_law_has_free_var(f, syms, tm, ds, ps, Con{v, t})
    case 1n+f Con{_, t}: b5k_chk_law_has_free_var(f, syms, tm, ds, ps, t)
def b5k_chk_def_rty(syms: SymTab, tm: RaVec<Maybe<&2, U32>>, all_ds: List<&2, Def>, mps: List<&2, Param>, from_law: Bool, rty: ChkTy) -> ChkTy:
  match from_law rty:
    case True{} TEq{+a, +b}: Bool.pick(ChkTy, b5k_chk_law_has_free_var(32n, syms, tm, all_ds, mps, [a, b]), b5k_chk_t0("Sigma"), TEq{a, b})
    case _ other: other
def b5k_chk_count_comp(ps: List<&2, Param>, +acc: U32) -> U32:
  match ps:
    case Con{Param{_, _, True{}, True{}}, rest}: b5k_chk_count_comp(rest, U32.add(acc, 1))
    case _: acc
def b5k_chk_index_defs(+syms: SymTab, +tm: RaVec<Maybe<&2, U32>>, +lm: RaVec<Maybe<&2, LawDef>>, +all_ds: List<&2, Def>, ds: List<&2, Def>, +idx: U32, dm: RaVec<Maybe<&2, DefInfo>>) -> RaVec<Maybe<&2, DefInfo>>:
  match ds:
    case Nil{}: dm
    case Con{Def{+dsym, +params, +ret, _, is_import, _}, rest}:
      +ld = ct_get(LawDef, lm, dsym)
      +mps = b5k_chk_apply_law_params(params, ld)
      +mret = b5k_chk_apply_law_ret(params, ret, ld)
      +fl = Bool.and(Bool.not(b5k_chk_is_some(Expr, ret)), b5k_chk_is_some(LawDef, ld))
      b5k_chk_index_defs(syms, tm, lm, all_ds, rest, U32.add(idx, 1), ct_set(DefInfo, dm, dsym, DefInfo{b5k_chk_count_live(mps, 0), b5k_list_len(Param, mps), b5k_chk_count_comp(mps, 0), b5k_chk_ret_arrows(tm, mret), is_import, idx,
                   b5k_chk_param_tys(syms, tm, mps), b5k_chk_live_tys(syms, tm, mps), b5k_chk_param_ers(mps), b5k_chk_def_rty(syms, tm, all_ds, mps, fl, b5k_chk_head_opt(syms, tm, mret))}))
def b5k_chk_index_dasts(ds: List<&2, Def>, da: RaVec<Maybe<&2, Def>>) -> RaVec<Maybe<&2, Def>>:
  match ds:
    case Nil{}: da
    case Con{Def{+dsym, ps, ret, body, imp, uns}, rest}: b5k_chk_index_dasts(rest, ct_set(Def, da, dsym, Def{dsym, ps, ret, body, imp, uns}))
def b5k_chk_index_laws(ls: List<&2, LawDef>, lm: RaVec<Maybe<&2, LawDef>>) -> RaVec<Maybe<&2, LawDef>>:
  match ls:
    case Nil{}: lm
    case Con{LawDef{+lsym, lps, lret}, rest}: b5k_chk_index_laws(rest, ct_set(LawDef, lm, lsym, LawDef{lsym, lps, lret}))
def b5k_chk_unseed_defs(ds: List<&2, Def>, tm: RaVec<Maybe<&2, U32>>) -> RaVec<Maybe<&2, U32>>:
  match ds:
    case Nil{}: tm
    case Con{Def{dsym, _, _, _, _, _}, rest}: b5k_chk_unseed_defs(rest, ct_set(U32, tm, dsym, 0))
def b5k_chk_build_ctx(+types: List<&2, TypeDef>, +defs: List<&2, Def>, laws: List<&2, LawDef>, +syms: SymTab) -> CheckCtx:
  +tm0 = b5k_chk_unseed_defs(defs, b5k_chk_seed_base_types(syms, b5k_chk_base_type_names(), RVEmpty{}))
  +tm = b5k_chk_index_types(types, tm0)
  cm = b5k_chk_index_all_ctors(syms, tm, types, b5k_chk_seed_base_ctors(syms, b5k_chk_base_ctors(), RVEmpty{}))
  +lm = b5k_chk_index_laws(laws, RVEmpty{})
  CheckCtx{syms, tm, cm, b5k_chk_index_defs(syms, tm, lm, defs, defs, 1, RVEmpty{}), lm, b5k_chk_index_dasts(defs, RVEmpty{}), types}
# Context Lookup Helpers
def b5k_chk_sym_name(ctx: CheckCtx, sym: U32) -> String:
  CheckCtx{syms, _, _, _, _, _, _} = ctx
  symtab_name(syms, sym)
def b5k_chk_dot_suffix(s: String, acc: String) -> String:
  match s:
    case SNil{}: acc
    case SCon{+c, t}: b5k_chk_dot_suffix(t, Bool.pick(String, U32.is_eq(Char.to_u32(c), 46), SNil{}, SCon{c, acc}))
def b5k_chk_ct_get_opt(ctors: RaVec<Maybe<&2, CtorInfo>>, ms: Maybe<&2, U32>) -> Maybe<&2, CtorInfo>:
  match ms:
    case Some{s2}: ct_get(CtorInfo, ctors, s2)
    case None{}: None{}
def b5k_chk_lookup_ctor_k(hit: Maybe<&2, CtorInfo>, +syms: SymTab, ctors: RaVec<Maybe<&2, CtorInfo>>, defs: RaVec<Maybe<&2, DefInfo>>, +sym: U32) -> Maybe<&2, CtorInfo>:
  match hit:
    case Some{ci}: Some{ci}
    case None{}:
      Bool.pick(Maybe<&2, CtorInfo>, b5k_chk_is_some(DefInfo, ct_get(DefInfo, defs, sym)),
        b5k_chk_ct_get_opt(ctors, symtab_lookup(syms, String.reverse(b5k_chk_dot_suffix(symtab_name(syms, sym), SNil{})))), None{})
def b5k_chk_lookup_ctor(ctx: CheckCtx, +sym: U32) -> Maybe<&2, CtorInfo>:
  CheckCtx{syms, _, +ctors, defs, _, _, _} = ctx
  b5k_chk_lookup_ctor_k(ct_get(CtorInfo, ctors, sym), syms, ctors, defs, sym)
def b5k_chk_known_g2(hit: Bool, syms: SymTab, sym: U32) -> Bool:
  match hit:
    case True{}: True{}
    case False{}: b5k_chk_is_base_name(symtab_name(syms, sym))
def b5k_chk_is_known_global(ctx: CheckCtx, +sym: U32) -> Bool:
  CheckCtx{syms, types, ctors, defs, laws, _, _} = ctx
  hit = Bool.or(Bool.or(b5k_chk_is_some(DefInfo, ct_get(DefInfo, defs, sym)), b5k_chk_is_some(CtorInfo, ct_get(CtorInfo, ctors, sym))),
                Bool.or(b5k_chk_is_some(U32, ct_get(U32, types, sym)), b5k_chk_is_some(LawDef, ct_get(LawDef, laws, sym))))
  b5k_chk_known_g2(hit, syms, sym)
# Local Environment & Affine Use-Set Algebra
def b5k_chk_env_lookup(env: List<&2, VarBind>, +sym: U32) -> LookupRes:
  match env:
    case Nil{}: LNotFound{}
    case Con{VarBind{s, d, +er, +loc, _, +t}, rest}:
      Bool.pick(LookupRes, U32.is_eq(s, sym), Bool.pick(LookupRes, d, LFoundDup{er, loc, t}, LFoundLin{er, loc, t}), b5k_chk_env_lookup(rest, sym))
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
    case Con{VarBind{s, _, _, _, _, _}, t}: Bool.or(U32.is_eq(s, sym), b5k_chk_binds_mem(t, sym))
def b5k_chk_uses_strip(+bs: List<&2, VarBind>, us: List<&2, U32>) -> List<&2, U32>:
  match us:
    case Nil{}: Nil{}
    case Con{+h, t}:
      +rest = b5k_chk_uses_strip(bs, t)
      Bool.pick(List<&2, U32>, b5k_chk_binds_mem(bs, h), rest, Con{h, rest})
def b5k_chk_params_binds(+ctx: CheckCtx, +all_dup: Bool, ps: List<&2, Param>) -> List<&2, VarBind>:
  CheckCtx{+syms, types, _, _, _, _, _} = ctx
  match ps:
    case Nil{}: Nil{}
    case Con{Param{+sym, typ, +erased, +dup}, rest}:
      +tail = b5k_chk_params_binds(ctx, all_dup, rest)
      Bool.pick(List<&2, VarBind>, String.eq(symtab_name(syms, sym), "_"), tail,
        Con{VarBind{sym, Bool.or(all_dup, Bool.or(erased, dup)), Bool.and(erased, Bool.and(Bool.not(dup), Bool.not(all_dup))), False{}, Bool.and(erased, dup), b5k_chk_head_opt(syms, types, typ)}, tail})
# Pattern Checking & Binding Extraction (with Parametric Ctor Field Propagation)
def b5k_chk_env_all_dup(env: List<&2, VarBind>) -> List<&2, VarBind>:
  match env:
    case Nil{}: Nil{}
    case Con{VarBind{s, _, _, loc, ic, t}, rest}: Con{VarBind{s, True{}, False{}, loc, ic, t}, b5k_chk_env_all_dup(rest)}
def b5k_chk_env_only_comp(env: List<&2, VarBind>) -> List<&2, VarBind>:
  match env:
    case Nil{}: Nil{}
    case Con{VarBind{s, d, er, loc, True{}, t}, rest}: Con{VarBind{s, True{}, False{}, loc, True{}, t}, b5k_chk_env_only_comp(rest)}
    case Con{_, rest}: b5k_chk_env_only_comp(rest)
def b5k_chk_binds_mark_local(+er_bind: Bool, +is_loc: Bool, bs: List<&2, VarBind>) -> List<&2, VarBind>:
  match bs:
    case Nil{}: Nil{}
    case Con{VarBind{s, d, _, _, ic, t}, rest}: Con{VarBind{s, Bool.or(d, er_bind), er_bind, is_loc, ic, t}, b5k_chk_binds_mark_local(er_bind, is_loc, rest)}
def b5k_chk_ctor_err(fn_name: String) -> String: "check: " ++ fn_name ++ ": constructor does not belong to goal or field count differs"
def b5k_chk_ctor_tmatch(+tname: String, +g: String) -> Bool:
  sp = Bool.or(Bool.and(String.eq(tname, "Sigma"), String.eq(g, "Pair")), Bool.and(String.eq(tname, "Pair"), String.eq(g, "Sigma")))
  Bool.or(String.eq(tname, g), Bool.or(sp, Bool.and(String.eq(g, "Word"), Bool.or(String.eq(tname, "Word.Nil"), String.eq(tname, "Word.Con")))))
def b5k_chk_ctor_ok(info: Maybe<&2, CtorInfo>, nargs: U32, goal: ChkTy) -> Bool:
  match info goal:
    case None{} _: False{}
    case Some{CtorInfo{_, arity, _, _, _}} TAny{}: U32.is_eq(nargs, arity)
    case Some{CtorInfo{_, arity, _, _, _}} TNonUniv{}: U32.is_eq(nargs, arity)
    case Some{CtorInfo{_, arity, _, _, _}} TErased{}: U32.is_eq(nargs, arity)
    case Some{CtorInfo{tname, arity, _, _, _}} TCon{g, _}: Bool.and(U32.is_eq(nargs, arity), b5k_chk_ctor_tmatch(tname, g))
    case Some{CtorInfo{_, _, _, _, _}} _: False{}
def b5k_chk_ctor_fdups(info: Maybe<&2, CtorInfo>) -> List<&2, Bool>:
  match info:
    case None{}: Nil{}
    case Some{CtorInfo{_, _, fdups, _, _}}: fdups
def b5k_chk_ctor_fers(info: Maybe<&2, CtorInfo>) -> List<&2, Bool>:
  match info:
    case None{}: Nil{}
    case Some{CtorInfo{_, _, _, fers, _}}: fers
def b5k_chk_base_fgoals(+tname: String, +arity: U32, goal: ChkTy) -> List<&2, ChkTy>:
  match goal:
    case TCon{_, Con{+a, Nil{}}}:
      Bool.pick(List<&2, ChkTy>, Bool.and(String.eq(tname, "Array"), U32.is_eq(arity, 1)), [a],
      Bool.pick(List<&2, ChkTy>, Bool.and(String.eq(tname, "Array"), U32.is_eq(arity, 2)), [TCon{"Array", [a]}, TCon{"Array", [a]}], Nil{}))
    case TCon{_, Con{+a, Con{+b, Nil{}}}}:
      Bool.pick(List<&2, ChkTy>, Bool.and(String.eq(tname, "Maybe"), U32.is_eq(arity, 1)), [b],
      Bool.pick(List<&2, ChkTy>, Bool.and(String.eq(tname, "List"), U32.is_eq(arity, 2)), [b, TCon{"List", [a, b]}],
      Bool.pick(List<&2, ChkTy>, Bool.and(Bool.or(String.eq(tname, "Pair"), String.eq(tname, "Sigma")), U32.is_eq(arity, 2)), [a, b], Nil{})))
    case _: Nil{}
def b5k_chk_ctor_fgoals(info: Maybe<&2, CtorInfo>, goal: ChkTy) -> List<&2, ChkTy>:
  match info:
    case None{}: Nil{}
    case Some{CtorInfo{tname, arity, _, _, Nil{}}}: b5k_chk_base_fgoals(tname, arity, goal)
    case Some{CtorInfo{_, _, _, _, ftys}}: ftys
def b5k_chk_pair_goals(goal: ChkTy) -> List<&2, ChkTy>:
  match goal:
    case TCon{+h, Con{a, Con{b, Nil{}}}}: Bool.pick(List<&2, ChkTy>, Bool.or(String.eq(h, "Sigma"), String.eq(h, "Pair")), [a, b], Nil{})
    case _: Nil{}
def b5k_chk_rep_goals(es: List<&2, Expr>, +g: ChkTy) -> List<&2, ChkTy>:
  match es:
    case Nil{}: Nil{}
    case Con{_, t}: Con{g, b5k_chk_rep_goals(t, g)}
def b5k_chk_list_elem_goals(es: List<&2, Expr>, goal: ChkTy) -> List<&2, ChkTy>:
  match goal:
    case TCon{_, Con{_, Con{TAny{}, Nil{}}}}: Nil{}
    case TCon{h, Con{_, Con{a, Nil{}}}}: Bool.pick(List<&2, ChkTy>, String.eq(h, "List"), b5k_chk_rep_goals(es, a), Nil{})
    case _: Nil{}
def b5k_chk_head_b(xs: List<&2, Bool>, defv: Bool) -> Bool:
  match xs:
    case Nil{}: defv
    case Con{h, _}: h
def b5k_chk_tail_b(xs: List<&2, Bool>) -> List<&2, Bool>:
  match xs:
    case Nil{}: Nil{}
    case Con{_, t}: t
def b5k_chk_head_t(xs: List<&2, ChkTy>) -> ChkTy:
  match xs:
    case Nil{}: TAny{}
    case Con{h, _}: h
def b5k_chk_tail_t(xs: List<&2, ChkTy>) -> List<&2, ChkTy>:
  match xs:
    case Nil{}: Nil{}
    case Con{_, t}: t
def b5k_chk_zip_pats(ps: List<&2, Pat>, +ds: List<&2, Bool>, +ts: List<&2, ChkTy>, +def_dup: Bool) -> List<&2, PatItem>:
  match ps:
    case Nil{}: Nil{}
    case Con{p, pt}:
      d = Bool.or(b5k_chk_head_b(ds, False{}), def_dup)
      Con{PatItem{p, d, b5k_chk_head_t(ts)}, b5k_chk_zip_pats(pt, b5k_chk_tail_b(ds), b5k_chk_tail_t(ts), def_dup)}
def b5k_chk_lr_is_dup(lr: LookupRes) -> Bool:
  match lr:
    case LFoundDup{_, _, _}: True{}
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
def b5k_chk_pats_all_dup(ps: List<&2, Pat>) -> Bool:
  match ps:
    case Nil{}: False{}
    case Con{PVar{_, d}, Nil{}}: d
    case Con{PVar{_, d}, t}: Bool.and(d, b5k_chk_pats_all_dup(t))
    case _: False{}
def b5k_chk_wild_strip(ps: List<&2, Pat>, ss: List<&2, U32>) -> List<&2, VarBind>:
  match ps ss:
    case Con{PWild{}, pt} Con{+s, st}:
      +rest = b5k_chk_wild_strip(pt, st)
      Bool.pick(List<&2, VarBind>, U32.is_zero(s), rest, Con{VarBind{U32.sub(s, 1), False{}, False{}, False{}, False{}, TAny{}}, rest})
    case Con{_, pt} Con{_, st}: b5k_chk_wild_strip(pt, st)
    case _ _: Nil{}
def b5k_chk_redup_binds(ps: List<&2, Pat>, ss: List<&2, U32>, ts: List<&2, ChkTy>) -> List<&2, VarBind>:
  match ps ss ts:
    case Con{PCtr{_, fs}, pt} Con{+s, st} Con{ty, tt}:
      +rest = b5k_chk_redup_binds(pt, st, tt)
      Bool.pick(List<&2, VarBind>, Bool.and(b5k_chk_pats_all_dup(fs), Bool.not(U32.is_zero(s))), Con{VarBind{U32.sub(s, 1), True{}, False{}, False{}, False{}, ty}, rest}, rest)
    case Con{_, pt} Con{_, st} Con{_, tt}: b5k_chk_redup_binds(pt, st, tt)
    case _ _ _: Nil{}
def b5k_chk_pats(fuel: Nat, +ctx: CheckCtx, +fn_name: String, ps: List<&2, PatItem>, acc: List<&2, VarBind>) -> PatRes:
  match fuel ps:
    case 0n _: PatOk{b5k_list_rev(VarBind, acc)}
    case _ Nil{}: PatOk{b5k_list_rev(VarBind, acc)}
    case 1n+f Con{PatItem{PVar{sym, dup}, inh, ty}, rest}:
      b5k_chk_pats(f, ctx, fn_name, rest, Con{VarBind{sym, Bool.or(dup, inh), False{}, False{}, False{}, ty}, acc})
    case 1n+f Con{PatItem{PCtr{sym, +fields}, inh, +sty}, rest}:
      +info = b5k_chk_lookup_ctor(ctx, sym)
      ok = b5k_chk_ctor_ok(info, b5k_list_len(Pat, fields), sty)
      items = b5k_chk_zip_pats(fields, b5k_chk_ctor_fdups(info), b5k_chk_ctor_fgoals(info, sty), inh)
      Bool.pick(PatRes, ok, b5k_chk_pats(f, ctx, fn_name, b5k_list_app(PatItem, items, rest), acc), PatErr{b5k_chk_ctor_err(fn_name)})
    case 1n+f Con{PatItem{PPair{fst, snd}, +inh, sty}, rest}:
      +pgs = b5k_chk_pair_goals(sty)
      b5k_chk_pats(f, ctx, fn_name, Con{PatItem{fst, inh, b5k_chk_head_t(pgs)}, Con{PatItem{snd, inh, b5k_chk_head_t(b5k_chk_tail_t(pgs))}, rest}}, acc)
    case 1n+f Con{PatItem{PList{elems}, inh, _}, rest}:
      b5k_chk_pats(f, ctx, fn_name, b5k_list_app(PatItem, b5k_chk_zip_pats(elems, Nil{}, Nil{}, inh), rest), acc)
    case 1n+f Con{PatItem{_, _, _}, rest}: b5k_chk_pats(f, ctx, fn_name, rest, acc)
# Goal Extraction, Call Signature Lookup & Shallow Parametric Type Inference
def b5k_chk_goal_expr(+ctx: CheckCtx, e: Expr) -> ChkTy:
  CheckCtx{syms, types, _, _, _, _, _} = ctx
  b5k_chk_head_expr(syms, types, e)
def b5k_chk_goal_opt(+ctx: CheckCtx, opt: Maybe<&2, Expr>) -> ChkTy:
  CheckCtx{syms, types, _, _, _, _, _} = ctx
  b5k_chk_head_opt(syms, types, opt)
def b5k_chk_call_err_k(bad: Bool, ctx: CheckCtx, fn_name: String, sym: U32) -> String:
  match bad:
    case True{}: "check: " ++ fn_name ++ ": call arity mismatch for " ++ b5k_chk_sym_name(ctx, sym)
    case False{}: ""
def b5k_chk_sig_has_ret(cs: CallSig) -> Bool:
  match cs:
    case CallSig{_, _, TAny{}}: False{}
    case _: True{}
def b5k_chk_builtin_over(+nm: String, +nargs: U32) -> Bool:
  Bool.and(U32.is_gt(nargs, 1), Bool.and(b5k_chk_sig_has_ret(b5k_chk_builtin_sig(nm, 1)), Bool.not(b5k_chk_sig_has_ret(b5k_chk_builtin_sig(nm, nargs)))))
def b5k_chk_call_def(info: Maybe<&2, DefInfo>, +ctx: CheckCtx, fn_name: String, +sym: U32, +nargs: U32) -> String:
  match info:
    case None{}: b5k_chk_call_err_k(b5k_chk_builtin_over(b5k_chk_sym_name(ctx, sym), nargs), ctx, fn_name, sym)
    case Some{DefInfo{arity, total_arity, _, ret_arr, _, _, _, _, _, _}}:
      b5k_chk_call_err_k(Bool.or(U32.is_gt(nargs, U32.add(total_arity, ret_arr)), Bool.and(U32.is_zero(nargs), Bool.not(U32.is_zero(arity)))), ctx, fn_name, sym)
def b5k_chk_call_lookup(lr: LookupRes, +ctx: CheckCtx, fn_name: String, +sym: U32, nargs: U32) -> String:
  match lr ctx:
    case LNotFound{} CheckCtx{_, _, _, defs, _, _, _}: b5k_chk_call_def(ct_get(DefInfo, defs, sym), ctx, fn_name, sym, nargs)
    case _ _: ""
def b5k_chk_call_arity(+ctx: CheckCtx, fn_name: String, env: List<&2, VarBind>, fun: Expr, nargs: U32) -> String:
  match fun:
    case EVar{+sym}: b5k_chk_call_lookup(b5k_chk_env_lookup(env, sym), ctx, fn_name, sym, nargs)
    case ERef{+sym}: b5k_chk_call_lookup(b5k_chk_env_lookup(env, sym), ctx, fn_name, sym, nargs)
    case _: ""
def b5k_chk_def_sig(info: Maybe<&2, DefInfo>, syms: SymTab, sym: U32, +nargs: U32, +nt: U32) -> CallSig:
  match info:
    case None{}: b5k_chk_builtin_sig(symtab_name(syms, sym), nargs)
    case Some{DefInfo{+arity, +total_arity, _, _, _, _, ptys, ltys, +pers, +rty}}:
      Bool.pick(CallSig, U32.is_eq(nargs, total_arity), CallSig{ptys, pers, rty},
      Bool.pick(CallSig, Bool.and(U32.is_eq(nargs, arity), U32.is_zero(nt)), CallSig{ltys, Nil{}, rty},
      Bool.pick(CallSig, Bool.and(U32.is_gt(nargs, 0), U32.is_lt(nargs, total_arity)), CallSig{Nil{}, pers, TFun{False{}, False{}, TAny{}, TAny{}}}, b5k_chk_sig_none())))
def b5k_chk_call_sig_lookup(lr: LookupRes, ctx: CheckCtx, +sym: U32, nargs: U32, nt: U32) -> CallSig:
  match lr ctx:
    case LNotFound{} CheckCtx{syms, _, _, defs, _, _, _}: b5k_chk_def_sig(ct_get(DefInfo, defs, sym), syms, sym, nargs, nt)
    case _ _: b5k_chk_sig_none()
def b5k_chk_call_sig(+ctx: CheckCtx, env: List<&2, VarBind>, fun: Expr, nargs: U32, nt: U32) -> CallSig:
  match fun:
    case EVar{+sym}: b5k_chk_call_sig_lookup(b5k_chk_env_lookup(env, sym), ctx, sym, nargs, nt)
    case ERef{+sym}: b5k_chk_call_sig_lookup(b5k_chk_env_lookup(env, sym), ctx, sym, nargs, nt)
    case _: b5k_chk_sig_none()
def b5k_chk_lr_typ(lr: LookupRes) -> ChkTy:
  match lr:
    case LFoundDup{_, _, t}: t
    case LFoundLin{_, _, t}: t
    case LNotFound{}: TAny{}
def b5k_chk_ctor_tname(info: Maybe<&2, CtorInfo>) -> ChkTy:
  match info:
    case None{}: TAny{}
    case Some{CtorInfo{tname, _, _, _, _}}: b5k_chk_t0(tname)
def b5k_chk_sig_args(cs: CallSig) -> List<&2, ChkTy>:
  CallSig{atys, _, _} = cs
  atys
def b5k_chk_sig_ers(cs: CallSig) -> List<&2, Bool>:
  CallSig{_, aers, _} = cs
  aers
def b5k_chk_sig_ret(cs: CallSig) -> ChkTy:
  CallSig{_, _, rty} = cs
  rty
def b5k_chk_is_cmp_expr(e: Expr) -> Bool:
  match e:
    case EOp{+op, a, b}:
      Bool.or(U32.is_ge(op, 20), Bool.and(Bool.or(U32.is_eq(op, B5K_OP_AND()), U32.is_eq(op, B5K_OP_OR())), Bool.or(b5k_chk_is_cmp_expr(a), b5k_chk_is_cmp_expr(b))))
    case _: False{}
def b5k_chk_ann_cmp_ty(e: Expr, def_ty: ChkTy) -> ChkTy:
  match e:
    case EOp{+op, a, b}:
      Bool.pick(ChkTy, U32.is_ge(op, 22), b5k_chk_t0("Bool"),
      Bool.pick(ChkTy, U32.is_ge(op, 20), TAny{},
      Bool.pick(ChkTy, Bool.and(Bool.or(U32.is_eq(op, B5K_OP_AND()), U32.is_eq(op, B5K_OP_OR())), Bool.or(b5k_chk_is_cmp_expr(a), b5k_chk_is_cmp_expr(b))), b5k_chk_t0("Bool"), def_ty)))
    case _: def_ty
def b5k_chk_eq_call_sig(+ctx: CheckCtx, fun: Expr, args: List<&2, Expr>) -> Maybe<&2, CallSig>:
  match fun args:
    case EVar{sym} Con{t, Con{_, Nil{}}}:
      Bool.pick(Maybe<&2, CallSig>, String.eq(b5k_chk_sym_name(ctx, sym), "Empty.absurd"),
        Some{CallSig{[TErased{}, b5k_chk_t0("Empty")], [True{}, False{}], b5k_chk_goal_expr(ctx, t)}}, None{})
    case EVar{sym} Con{_, Con{+a, Con{+b, Con{_, Nil{}}}}}:
      Bool.pick(Maybe<&2, CallSig>, String.eq(b5k_chk_sym_name(ctx, sym), "Equal.sym"),
        Some{CallSig{[TErased{}, TAny{}, TAny{}, TEq{a, b}], [True{}, True{}, True{}, False{}], TEq{b, a}}}, None{})
    case EVar{sym} Con{_, Con{+a, Con{+b, Con{+c, Con{_, Con{_, Nil{}}}}}}}:
      Bool.pick(Maybe<&2, CallSig>, String.eq(b5k_chk_sym_name(ctx, sym), "Equal.trans"),
        Some{CallSig{[TErased{}, TAny{}, TAny{}, TAny{}, TEq{a, b}, TEq{b, c}], [True{}, True{}, True{}, True{}, False{}, False{}], TEq{a, c}}}, None{})
    case _ _: None{}
def b5k_chk_opt_sig(m: Maybe<&2, CallSig>, def_s: CallSig) -> CallSig:
  match m:
    case Some{s}: s
    case None{}: def_s
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
    case ECtr{sym, _}: b5k_chk_ctor_tname(b5k_chk_lookup_ctor(ctx, sym))
    case EAnn{val, typ}: b5k_chk_ann_cmp_ty(val, b5k_chk_goal_expr(ctx, typ))
    case EOp{op, _, _}: Bool.pick(ChkTy, U32.is_ge(op, 20), b5k_chk_t0("Bool"), TAny{})
    case EApp{+fun, +args}: b5k_chk_sig_ret(b5k_chk_opt_sig(b5k_chk_eq_call_sig(ctx, fun, args), b5k_chk_call_sig(ctx, env, fun, b5k_list_len(Expr, args), 0)))
    case _: TAny{}
def b5k_chk_scruts_tys(+ctx: CheckCtx, +env: List<&2, VarBind>, es: List<&2, Expr>) -> List<&2, ChkTy>:
  match es:
    case Nil{}: Nil{}
    case Con{h, t}: Con{b5k_chk_infer_head(ctx, env, h), b5k_chk_scruts_tys(ctx, env, t)}
# Expression Checker (Scope + Ctor/Goal + Arity + Affine + Parametric Types)
def b5k_chk_var_gk(ok: Bool, is_ref: Bool, ctx: CheckCtx, fn_name: String, sym: U32) -> ExprRes:
  match ok is_ref:
    case True{} _: ExprOk{Nil{}}
    case False{} True{}: ExprErr{"check: " ++ fn_name ++ ": unbound reference: " ++ b5k_chk_sym_name(ctx, sym)}
    case False{} False{}: ExprErr{"check: " ++ fn_name ++ ": unbound variable: " ++ b5k_chk_sym_name(ctx, sym)}
def b5k_chk_goal_rejects_univ(t: ChkTy) -> Bool:
  match t:
    case TAny{}: False{}
    case TErased{}: False{}
    case _: True{}
def b5k_chk_def_is_fwd(di: Maybe<&2, DefInfo>, cur_idx: U32) -> Bool:
  match di:
    case Some{DefInfo{_, _, _, _, _, idx, _, _, _, _}}: U32.is_gt(idx, cur_idx)
    case None{}: False{}
def b5k_chk_is_fwd_ref(ctx: CheckCtx, +cur_idx: U32, +fn_name: String, +sym: U32) -> Bool:
  CheckCtx{_, _, _, defs, laws, _, _} = ctx
  has_law = b5k_chk_is_some(LawDef, ct_get(LawDef, laws, sym))
  is_imp_fn = String.contains(fn_name, ".")
  Bool.and(U32.is_gt(cur_idx, 0), Bool.and(Bool.not(is_imp_fn), Bool.and(Bool.not(has_law), b5k_chk_def_is_fwd(ct_get(DefInfo, defs, sym), cur_idx))))
def b5k_chk_is_er_goal(t: ChkTy) -> Bool:
  match t:
    case TErased{}: True{}
    case _: False{}
def b5k_chk_is_er_or_quant(t: ChkTy) -> Bool:
  match t:
    case TErased{}: True{}
    case TCon{h, _}: String.eq(h, "Quant")
    case _: False{}
def b5k_chk_var_lookup(lr: LookupRes, +ctx: CheckCtx, cur_idx: U32, +fn_name: String, +goal: ChkTy, +sym: U32, is_ref: Bool) -> ExprRes:
  match lr:
    case LFoundDup{er, _, +vty}:
      bad_er = Bool.and(er, Bool.and(Bool.not(b5k_chk_is_er_goal(goal)), Bool.not(b5k_chk_is_er_or_quant(vty))))
      Bool.pick(ExprRes, bad_er, ExprErr{"check: " ++ fn_name ++ ": erased variable used in live position"}, b5k_chk_expect(ctx, fn_name, vty, goal, ExprOk{Nil{}}))
    case LFoundLin{er, _, +vty}:
      bad_er = Bool.and(er, Bool.and(Bool.not(b5k_chk_is_er_goal(goal)), Bool.not(b5k_chk_is_er_or_quant(vty))))
      Bool.pick(ExprRes, bad_er, ExprErr{"check: " ++ fn_name ++ ": erased variable used in live position"}, b5k_chk_expect(ctx, fn_name, vty, goal, ExprOk{Con{sym, Nil{}}}))
    case LNotFound{}:
      bad_u = Bool.and(b5k_chk_is_universe(b5k_chk_sym_name(ctx, sym)), b5k_chk_goal_rejects_univ(goal))
      bad_f = b5k_chk_is_fwd_ref(ctx, cur_idx, fn_name, sym)
      Bool.pick(ExprRes, bad_u, ExprErr{b5k_chk_head_err(fn_name, TErased{}, goal)},
      Bool.pick(ExprRes, bad_f, ExprErr{"check: " ++ fn_name ++ ": forward reference to later def: " ++ b5k_chk_sym_name(ctx, sym)},
        b5k_chk_var_gk(b5k_chk_is_known_global(ctx, sym), is_ref, ctx, fn_name, sym)))
def b5k_chk_var(+ctx: CheckCtx, cur_idx: U32, fn_name: String, env: List<&2, VarBind>, goal: ChkTy, +sym: U32, is_ref: Bool) -> ExprRes:
  b5k_chk_var_lookup(b5k_chk_env_lookup(env, sym), ctx, cur_idx, fn_name, goal, sym, is_ref)
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
def b5k_chk_erased_res(er: Bool, r: ExprRes) -> ExprRes:
  match er r:
    case True{} ExprOk{_}: ExprOk{Nil{}}
    case _ other: other
def b5k_chk_ctor_is_ty(ci: Maybe<&2, CtorInfo>, g: String) -> Bool:
  match ci:
    case Some{CtorInfo{tn, _, _, _, _}}: String.eq(tn, g)
    case None{}: False{}
def b5k_chk_u32_ctor_k(ms: Maybe<&2, U32>, ctors: RaVec<Maybe<&2, CtorInfo>>, g: String) -> Bool:
  match ms:
    case None{}: False{}
    case Some{s}: b5k_chk_ctor_is_ty(ct_get(CtorInfo, ctors, s), g)
def b5k_chk_u32_ctor_is(ctx: CheckCtx, g: String) -> Bool:
  CheckCtx{syms, _, ctors, _, _, _, _} = ctx
  b5k_chk_u32_ctor_k(symtab_lookup(syms, "U32"), ctors, g)
def b5k_chk_lit_k(ok: Bool, fn_name: String, got: String) -> ExprRes:
  match ok:
    case True{}: ExprOk{Nil{}}
    case False{}: ExprErr{"check: " ++ fn_name ++ ": literal type mismatch (" ++ got ++ ")"}
def b5k_chk_lit(ctx: CheckCtx, goal: ChkTy, fn_name: String, +got: String, +is_num: Bool) -> ExprRes:
  match goal:
    case TAny{}: ExprOk{Nil{}}
    case TNonUniv{}: ExprOk{Nil{}}
    case TErased{}: ExprOk{Nil{}}
    case TCon{+g, _}: b5k_chk_lit_k(Bool.or(b5k_str_eq(g, got), Bool.and(is_num, Bool.or(b5k_str_eq(g, "Nat"), b5k_chk_u32_ctor_is(ctx, g)))), fn_name, got)
    case _: ExprErr{"check: " ++ fn_name ++ ": literal type mismatch (" ++ got ++ ")"}
def b5k_chk_pair_goal_ok(goal: ChkTy) -> Bool:
  match goal:
    case TAny{}: True{}
    case TNonUniv{}: True{}
    case TErased{}: True{}
    case TFun{_, _, _, _}: True{}
    case TCon{+g, _}: Bool.or(String.eq(g, "Sigma"), Bool.or(String.eq(g, "Pair"), Bool.or(String.eq(g, "Tuple"), String.ends_with(g, ".Tuple"))))
    case _: False{}
def b5k_chk_ty_nth(n: Nat, xs: List<&2, ChkTy>) -> ChkTy:
  match n xs:
    case 0n Con{h, _}: h
    case 1n+p Con{_, t}: b5k_chk_ty_nth(p, t)
    case _ Nil{}: TAny{}
def b5k_chk_monad_inner(goal: ChkTy) -> ChkTy:
  match goal:
    case TCon{+h, +args}:
      Bool.pick(ChkTy, String.eq(h, "IO"), b5k_chk_ty_nth(0n, args),
      Bool.pick(ChkTy, String.eq(h, "Maybe"), b5k_chk_ty_nth(1n, args),
      Bool.pick(ChkTy, String.eq(h, "Result"), b5k_chk_ty_nth(3n, args), TAny{})))
    case _: TAny{}
def b5k_chk_refl_goal(ctx: CheckCtx, allow_n: Bool, fn_name: String, goal: ChkTy) -> ExprRes:
  match goal:
    case TEq{a, b}: Bool.pick(ExprRes, b5k_chk_expr_neq(ctx, allow_n, a, b), ExprErr{"check: " ++ fn_name ++ ": reflexivity mismatch"}, ExprOk{Nil{}})
    case TCon{+g, _}: Bool.pick(ExprRes, String.eq(g, "Equal"), ExprOk{Nil{}}, ExprErr{b5k_chk_head_err(fn_name, b5k_chk_t0("Equal"), TCon{g, Nil{}})})
    case TFun{_, _, _, _}: ExprErr{b5k_chk_head_err(fn_name, b5k_chk_t0("Equal"), TFun{False{}, False{}, TAny{}, TAny{}})}
    case _: ExprOk{Nil{}}
def b5k_chk_is_erased_ty(t: ChkTy) -> Bool:
  match t:
    case TErased{}: True{}
    case _: False{}
def b5k_chk_lam_dup(goal: ChkTy) -> Bool:
  match goal:
    case TErased{}: True{}
    case TFun{d, _, _, r}: Bool.or(d, b5k_chk_is_erased_ty(r))
    case _: False{}
def b5k_chk_lam_ret(goal: ChkTy) -> ChkTy:
  match goal:
    case TErased{}: TErased{}
    case TFun{_, _, _, r}: r
    case _: TAny{}
def b5k_chk_is_cmp_op(e: Expr) -> Bool:
  b5k_chk_is_cmp_expr(e)
def b5k_chk_is_refl(e: Expr) -> Bool:
  match e:
    case ERefl{}: True{}
    case _: False{}
def b5k_chk_expr_is_erased(+syms: SymTab, e: Expr) -> Bool:
  match e:
    case EVar{+sym}: Bool.or(b5k_chk_is_universe(symtab_name(syms, sym)), String.eq(symtab_name(syms, sym), "Empty"))
    case EApp{EVar{sym}, _}: b5k_chk_is_universe(symtab_name(syms, sym))
    case EAnn{v, _}: b5k_chk_is_cmp_op(v)
    case EEq{_, _}: True{}
    case EAll{_, body}: b5k_chk_expr_is_erased(syms, body)
    case _: False{}
def b5k_chk_ret_is_erased(syms: SymTab, opt: Maybe<&2, Expr>) -> Bool:
  match opt:
    case Some{e}: b5k_chk_expr_is_erased(syms, e)
    case None{}: False{}
type RecCtx is Data:
  RecCtx{fn_sym: U32, cur_idx: U32, params: List<&2, U32>, sub: List<&2, U32>, sub2: List<&2, U32>, lit_max: U32, after_let: Bool, in_match: Bool, banned: List<&2, U32>}
def b5k_chk_rc_idx(rc: RecCtx) -> U32:
  RecCtx{_, ci, _, _, _, _, _, _, _} = rc
  ci
def b5k_chk_rc_after_let(rc: RecCtx) -> Bool:
  RecCtx{_, _, _, _, _, _, al, _, _} = rc
  al
def b5k_chk_rc_clear_al(rc: RecCtx) -> RecCtx:
  RecCtx{fs, ci, pms, sub, sub2, lm, _, im, bn} = rc
  RecCtx{fs, ci, pms, sub, sub2, lm, False{}, im, bn}
def b5k_chk_pat_is_var(p: Pat) -> Bool:
  match p:
    case PVar{_, _}: True{}
    case PWild{}: True{}
    case _: False{}
def b5k_chk_pat_sub_vars(+fuel: Nat, ps: List<&2, Pat>, acc: List<&2, U32>) -> List<&2, U32>:
  match fuel ps:
    case 0n _: acc
    case _ Nil{}: acc
    case 1n+f Con{PVar{s, _}, t}: b5k_chk_pat_sub_vars(f, t, Con{s, acc})
    case 1n+f Con{PCtr{_, fs}, t}: b5k_chk_pat_sub_vars(f, b5k_list_app(Pat, fs, t), acc)
    case 1n+f Con{PPair{a, b}, t}: b5k_chk_pat_sub_vars(f, Con{a, Con{b, t}}, acc)
    case 1n+f Con{PList{es}, t}: b5k_chk_pat_sub_vars(f, b5k_list_app(Pat, es, t), acc)
    case 1n+f Con{_, t}: b5k_chk_pat_sub_vars(f, t, acc)
def b5k_chk_pats_sub(ps: List<&2, Pat>, acc: List<&2, U32>) -> List<&2, U32>:
  match ps:
    case Nil{}: acc
    case Con{PCtr{_, fs}, t}: b5k_chk_pats_sub(t, b5k_chk_pat_sub_vars(U32.to_nat(512), fs, acc))
    case Con{PPair{a, b}, t}: b5k_chk_pats_sub(t, b5k_chk_pat_sub_vars(64n, [a, b], acc))
    case Con{PList{es}, t}: b5k_chk_pats_sub(t, b5k_chk_pat_sub_vars(64n, es, acc))
    case Con{_, t}: b5k_chk_pats_sub(t, acc)
def b5k_chk_pats_sub2(ps: List<&2, Pat>, acc: List<&2, U32>) -> List<&2, U32>:
  match ps:
    case Nil{}: acc
    case Con{PCtr{_, fs}, t}: b5k_chk_pats_sub2(t, b5k_chk_pats_sub(fs, acc))
    case Con{PPair{a, b}, t}: b5k_chk_pats_sub2(t, b5k_chk_pats_sub([a, b], acc))
    case Con{_, t}: b5k_chk_pats_sub2(t, acc)
def b5k_chk_any_sub2(+fuel: Nat, +sub2: List<&2, U32>, es: List<&2, Expr>) -> Bool:
  match fuel es:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+f Con{EVar{s}, t}: Bool.or(b5k_chk_u32_mem(sub2, s), b5k_chk_any_sub2(f, sub2, t))
    case 1n+f Con{ECtr{_, fs}, t}: b5k_chk_any_sub2(f, sub2, b5k_list_app(Expr, fs, t))
    case 1n+f Con{EList{xs}, t}: b5k_chk_any_sub2(f, sub2, b5k_list_app(Expr, xs, t))
    case 1n+f Con{EPair{a, b}, t}: b5k_chk_any_sub2(f, sub2, Con{a, Con{b, t}})
    case 1n+f Con{EAnn{v, _}, t}: b5k_chk_any_sub2(f, sub2, Con{v, t})
    case 1n+f Con{_, t}: b5k_chk_any_sub2(f, sub2, t)
def b5k_chk_all_sub2(+fuel: Nat, +sub2: List<&2, U32>, es: List<&2, Expr>) -> Bool:
  match fuel es:
    case 0n _: False{}
    case _ Nil{}: True{}
    case 1n+f Con{EVar{s}, t}: Bool.and(b5k_chk_u32_mem(sub2, s), b5k_chk_all_sub2(f, sub2, t))
    case 1n+f Con{ECtr{_, fs}, t}: b5k_chk_all_sub2(f, sub2, b5k_list_app(Expr, fs, t))
    case 1n+f Con{EList{xs}, t}: b5k_chk_all_sub2(f, sub2, b5k_list_app(Expr, xs, t))
    case 1n+f Con{EPair{a, b}, t}: b5k_chk_all_sub2(f, sub2, Con{a, Con{b, t}})
    case 1n+f Con{EAnn{v, _}, t}: b5k_chk_all_sub2(f, sub2, Con{v, t})
    case 1n+f Con{ENum{_}, t}: b5k_chk_all_sub2(f, sub2, t)
    case _ _: False{}
def b5k_chk_pats_lit_max(+syms: SymTab, ps: List<&2, Pat>, +acc: U32) -> U32:
  match ps:
    case Nil{}: acc
    case Con{PNum{+v}, t}: b5k_chk_pats_lit_max(syms, t, Bool.pick(U32, U32.is_gt(v, acc), v, acc))
    case Con{PCtr{s, _}, t}:
      is_sc = String.eq(symtab_name(syms, s), "Succ")
      b5k_chk_pats_lit_max(syms, t, Bool.pick(U32, Bool.and(is_sc, U32.is_zero(acc)), 1, acc))
    case Con{_, t}: b5k_chk_pats_lit_max(syms, t, acc)
def b5k_chk_arg_is_sub(+sub: List<&2, U32>, +sub2: List<&2, U32>, +lmax: U32, e: Expr) -> Bool:
  match e:
    case EVar{s}: b5k_chk_u32_mem(sub, s)
    case ECtr{_, Con{+h, +t}}: Bool.and(b5k_chk_all_sub2(32n, sub, Con{h, t}), b5k_chk_any_sub2(32n, sub2, Con{h, t}))
    case EOp{0, ENum{1}, v}: b5k_chk_all_sub2(32n, sub2, [v])
    case ENum{k}: U32.is_lt(k, lmax)
    case EAnn{v, _}: b5k_chk_arg_is_sub(sub, sub2, lmax, v)
    case _: False{}
def b5k_chk_arg_is_same(+p: U32, +sub: List<&2, U32>, +lmax: U32, e: Expr) -> Bool:
  match e:
    case EVar{s}: U32.is_eq(s, p)
    case ENum{k}: U32.is_le(k, lmax)
    case EOp{0, ENum{1}, EVar{x}}: b5k_chk_u32_mem(sub, x)
    case ECtr{_, fs}: b5k_chk_all_sub2(32n, sub, fs)
    case EAnn{v, _}: b5k_chk_arg_is_same(p, sub, lmax, v)
    case _: False{}
def b5k_chk_lex_ok(+sub: List<&2, U32>, +sub2: List<&2, U32>, +lmax: U32, pms: List<&2, U32>, args: List<&2, Expr>) -> Bool:
  match pms args:
    case Nil{} _: False{}
    case _ Nil{}: False{}
    case Con{+p, pt} Con{+a, at}:
      Bool.pick(Bool, b5k_chk_arg_is_sub(sub, sub2, lmax, a), True{},
      Bool.pick(Bool, Bool.or(U32.is_zero(p), b5k_chk_arg_is_same(U32.sub(p, 1), sub, lmax, a)), b5k_chk_lex_ok(sub, sub2, lmax, pt, at), False{}))
def b5k_chk_rec_call_err(rc: RecCtx, fun: Expr, args: List<&2, Expr>, fn_name: String) -> String:
  RecCtx{fsym, _, pms, sub, sub2, lmax, _, _, _} = rc
  match fun:
    case EVar{+sym}:
      is_self = U32.is_eq(fsym, U32.add(sym, 1))
      bad = Bool.and(is_self, Bool.not(b5k_chk_lex_ok(sub, sub2, lmax, pms, args)))
      Bool.pick(String, bad, "check: " ++ fn_name ++ ": non-decreasing self-recursion", "")
    case _: ""
def b5k_chk_u32_repl(xs: List<&2, U32>, +old: U32, +nw: U32) -> List<&2, U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h, t}: Con{Bool.pick(U32, U32.is_eq(h, old), nw, h), b5k_chk_u32_repl(t, old, nw)}
def b5k_chk_pms_rename(pats: List<&2, Pat>, ssyms: List<&2, U32>, +pms: List<&2, U32>) -> List<&2, U32>:
  match pats ssyms:
    case Con{PVar{ns, _}, pt} Con{+s, st}:
      pms2 = Bool.pick(List<&2, U32>, U32.is_gt(s, 0), b5k_chk_u32_repl(pms, s, U32.add(ns, 1)), pms)
      b5k_chk_pms_rename(pt, st, pms2)
    case Con{_, pt} Con{_, st}: b5k_chk_pms_rename(pt, st, pms)
    case _ _: pms
def b5k_chk_rc_add(rc: RecCtx, pats: List<&2, Pat>, ssyms: List<&2, U32>, extra: List<&2, U32>, extra2: List<&2, U32>, +lm2: U32, ban2: List<&2, U32>) -> RecCtx:
  RecCtx{fs, ci, pms, sub, sub2, +lm, _, _, bn} = rc
  RecCtx{fs, ci, b5k_chk_pms_rename(pats, ssyms, pms), b5k_list_app(U32, extra, sub), b5k_list_app(U32, extra2, sub2), Bool.pick(U32, U32.is_gt(lm2, lm), lm2, lm), False{}, True{}, b5k_list_app(U32, ban2, bn)}
def b5k_chk_rc_let(rc: RecCtx, pat: Pat, +val: Expr) -> RecCtx:
  RecCtx{+fs, +ci, +pms, +sub, +sub2, +lm, +al, +im, +bn} = rc
  match pat:
    case PVar{+s, _}:
      sub_n = Bool.pick(List<&2, U32>, b5k_chk_arg_is_sub(sub, sub2, 0, val), Con{s, sub}, sub)
      sub2_n = Bool.pick(List<&2, U32>, b5k_chk_all_sub2(32n, sub2, [val]), Con{s, sub2}, sub2)
      RecCtx{fs, ci, pms, sub_n, sub2_n, lm, True{}, im, bn}
    case _: RecCtx{fs, ci, pms, sub, sub2, lm, al, im, bn}
def b5k_chk_is_rwt_var(typ: Expr, val: Expr) -> Bool:
  match typ val:
    case EHole{} EVar{_}: True{}
    case _ _: False{}
def b5k_chk_is_dead_tail(pats: List<&2, Pat>, rest: List<&2, Case>) -> Bool:
  match pats rest:
    case Con{PWild{}, Nil{}} Con{Case{Con{PWild{}, Nil{}}, _}, Nil{}}: True{}
    case _ _: False{}
def b5k_chk_rwt_ty_bad(ty: ChkTy) -> Bool:
  match ty:
    case TCon{h, _}: Bool.not(String.eq(h, "Equal"))
    case _: False{}
def b5k_chk_rwt_eq_bad(ctx: CheckCtx, env: List<&2, VarBind>, eq: Expr) -> Bool:
  match eq:
    case ENum{_}: True{}
    case EFlt{_}: True{}
    case EChr{_}: True{}
    case EStr{_}: True{}
    case EUnit{}: True{}
    case EPair{_, _}: True{}
    case EList{_}: True{}
    case ECtr{_, _}: True{}
    case other: b5k_chk_rwt_ty_bad(b5k_chk_infer_head(ctx, env, other))
def b5k_chk_rwt_body_goal(goal: ChkTy) -> ChkTy: TNonUniv{}
# Match Scrutinee & Exhaustiveness Checking
def b5k_chk_lr_bad_scrut(lr: LookupRes, is_er_goal: Bool) -> Bool:
  match lr:
    case LFoundDup{er, loc, _}: Bool.or(loc, Bool.and(er, Bool.not(is_er_goal)))
    case LFoundLin{er, loc, _}: Bool.or(loc, Bool.and(er, Bool.not(is_er_goal)))
    case LNotFound{}: False{}
def b5k_chk_one_scrut_bad(env: List<&2, VarBind>, is_er_goal: Bool, e: Expr) -> Bool:
  match e:
    case EVar{s}: b5k_chk_lr_bad_scrut(b5k_chk_env_lookup(env, s), is_er_goal)
    case EAnn{v, _}: b5k_chk_one_scrut_bad(env, is_er_goal, v)
    case _: True{}
def b5k_chk_scrut_bad(+env: List<&2, VarBind>, +is_er_goal: Bool, scruts: List<&2, Expr>, stys: List<&2, ChkTy>) -> Bool:
  match scruts stys:
    case Nil{} _: False{}
    case Con{_, _} Con{TFun{_, _, _, _}, _}: True{}
    case Con{sc, st} Con{_, tt}: Bool.or(b5k_chk_one_scrut_bad(env, is_er_goal, sc), b5k_chk_scrut_bad(env, is_er_goal, st, tt))
    case Con{sc, st} Nil{}: Bool.or(b5k_chk_one_scrut_bad(env, is_er_goal, sc), b5k_chk_scrut_bad(env, is_er_goal, st, Nil{}))
def b5k_chk_ty_is_empty(t: ChkTy) -> Bool:
  match t:
    case TCon{h, _}: String.eq(h, "Empty")
    case _: False{}
def b5k_chk_env_has_live_empty(env: List<&2, VarBind>) -> Bool:
  match env:
    case Nil{}: False{}
    case Con{VarBind{_, _, er, _, _, ty}, t}: Bool.or(Bool.and(Bool.not(er), b5k_chk_ty_is_empty(ty)), b5k_chk_env_has_live_empty(t))
def b5k_chk_pat_is_catchall(p: Pat) -> Bool:
  match p:
    case PWild{}: True{}
    case PVar{_, _}: True{}
    case _: False{}
def b5k_chk_pat_head_name(syms: SymTab, p: Pat) -> String:
  match p:
    case PCtr{s, _}: symtab_name(syms, s)
    case PNum{0}: "Zero"
    case PList{Nil{}}: "Nil"
    case PList{Con{_, _}}: "Con"
    case PPair{_, _}: "Tuple"
    case _: ""
def b5k_chk_ctor_names(+syms: SymTab, cs: List<&2, CtorDef>) -> List<&2, String>:
  match cs:
    case Nil{}: Nil{}
    case Con{CtorDef{s, _, _}, t}: Con{symtab_name(syms, s), b5k_chk_ctor_names(syms, t)}
def b5k_chk_find_tdef_ctors(+syms: SymTab, ts: List<&2, TypeDef>, +tname: String) -> Maybe<&2, List<&2, String>>:
  match ts:
    case Nil{}: None{}
    case Con{TypeDef{s, _, _, cs}, t}:
      Bool.pick(Maybe<&2, List<&2, String>>, String.eq(symtab_name(syms, s), tname), Some{b5k_chk_ctor_names(syms, cs)}, b5k_chk_find_tdef_ctors(syms, t, tname))
def b5k_chk_base_tctors(+tname: String) -> Maybe<&2, List<&2, String>>:
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "Bool"), Some{["False", "True"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "Nat"), Some{["Zero", "Succ"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "List"), Some{["Nil", "Con"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "Maybe"), Some{["None", "Some"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "Either"), Some{["Inl", "Inr"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "Result"), Some{["Fail", "Done"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "Cmp"), Some{["LT", "EQ", "GT"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "Unit"), Some{["Unit"]},
  Bool.pick(Maybe<&2, List<&2, String>>, Bool.or(String.eq(tname, "Sigma"), String.eq(tname, "Pair")), Some{["Tuple"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "String"), Some{["SNil", "SCon"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "Char"), Some{["Chr"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "U32"), Some{["U32"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "F32"), Some{["F32"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "Array"), Some{["ALeaf", "ANode"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "Map"), Some{["MTip", "MLeaf", "MNode"]},
  Bool.pick(Maybe<&2, List<&2, String>>, String.eq(tname, "Empty"), Some{Nil{}}, None{}))))))))))))))))
def b5k_chk_type_ctors(ctx: CheckCtx, +tname: String) -> Maybe<&2, List<&2, String>>:
  CheckCtx{syms, _, _, _, _, _, tdefs} = ctx
  b5k_chk_opt_or(List<&2, String>, b5k_chk_find_tdef_ctors(syms, tdefs, tname), b5k_chk_base_tctors(tname))
def b5k_chk_is_prim_ty(tname: String) -> Bool: False{}
def b5k_chk_pat_nth(n: Nat, ps: List<&2, Pat>) -> Pat:
  match n ps:
    case 0n Con{h, _}: h
    case 1n+p Con{_, t}: b5k_chk_pat_nth(p, t)
    case _ Nil{}: PWild{}
def b5k_chk_cases_col_wild(+col: Nat, cs: List<&2, Case>) -> Bool:
  match cs:
    case Nil{}: False{}
    case Con{Case{ps, _}, t}: Bool.or(b5k_chk_pat_is_catchall(b5k_chk_pat_nth(col, ps)), b5k_chk_cases_col_wild(col, t))
def b5k_chk_cname_match(+pn: String, +cn: String) -> Bool:
  Bool.or(String.eq(pn, cn), Bool.and(Bool.not(String.is_empty(pn)), String.ends_with(cn, "." ++ pn)))
def b5k_chk_cases_col_has(+syms: SymTab, +col: Nat, +cname: String, cs: List<&2, Case>) -> Bool:
  match cs:
    case Nil{}: False{}
    case Con{Case{ps, _}, t}:
      +p = b5k_chk_pat_nth(col, ps)
      hit = Bool.or(b5k_chk_pat_is_catchall(p), b5k_chk_cname_match(b5k_chk_pat_head_name(syms, p), cname))
      Bool.or(hit, b5k_chk_cases_col_has(syms, col, cname, t))
def b5k_chk_cases_all_ctors(+syms: SymTab, +col: Nat, cnames: List<&2, String>, +cs: List<&2, Case>) -> Bool:
  match cnames:
    case Nil{}: True{}
    case Con{cn, t}: Bool.and(b5k_chk_cases_col_has(syms, col, cn, cs), b5k_chk_cases_all_ctors(syms, col, t, cs))
def b5k_chk_ci_tname(ci: Maybe<&2, CtorInfo>) -> String:
  match ci:
    case Some{CtorInfo{tn, _, _, _, _}}: tn
    case None{}: ""
def b5k_chk_pat_tname(ctx: CheckCtx, p: Pat) -> String:
  match p:
    case PCtr{s, _}: b5k_chk_ci_tname(b5k_chk_lookup_ctor(ctx, s))
    case PList{_}: "List"
    case _: ""
def b5k_chk_col_tname_from_cases(+ctx: CheckCtx, +col: Nat, cs: List<&2, Case>) -> String:
  match cs:
    case Nil{}: ""
    case Con{Case{ps, _}, t}:
      +tn = b5k_chk_pat_tname(ctx, b5k_chk_pat_nth(col, ps))
      Bool.pick(String, String.is_empty(tn), b5k_chk_col_tname_from_cases(ctx, col, t), tn)
def b5k_chk_col_tname(+ctx: CheckCtx, col: Nat, ty: ChkTy, cs: List<&2, Case>) -> String:
  match ty:
    case TCon{h, _}: h
    case _: b5k_chk_col_tname_from_cases(ctx, col, cs)
def b5k_chk_col_exh_ctors(syms: SymTab, col: Nat, m: Maybe<&2, List<&2, String>>, cs: List<&2, Case>) -> Bool:
  match m:
    case None{}: True{}
    case Some{cns}: b5k_chk_cases_all_ctors(syms, col, cns, cs)
def b5k_chk_col_exh_tn(+ctx: CheckCtx, col: Nat, tn: String, cs: List<&2, Case>) -> Bool:
  CheckCtx{syms, _, _, _, _, _, _} = ctx
  match tn:
    case SNil{}: True{}
    case +s: Bool.pick(Bool, b5k_chk_is_prim_ty(s), False{}, b5k_chk_col_exh_ctors(syms, col, b5k_chk_type_ctors(ctx, s), cs))
def b5k_chk_col_exhaustive(+ctx: CheckCtx, +col: Nat, ty: ChkTy, +cs: List<&2, Case>) -> Bool:
  Bool.pick(Bool, b5k_chk_cases_col_wild(col, cs), True{}, b5k_chk_col_exh_tn(ctx, col, b5k_chk_col_tname(ctx, col, ty, cs), cs))
def b5k_chk_filter_col0(+syms: SymTab, +cname: String, cs: List<&2, Case>) -> List<&2, Case>:
  match cs:
    case Nil{}: Nil{}
    case Con{Case{+ps, +b}, t}:
      +p0 = b5k_chk_pat_nth(0n, ps)
      keep = Bool.or(b5k_chk_pat_is_catchall(p0), String.eq(b5k_chk_pat_head_name(syms, p0), cname))
      +rest = b5k_chk_filter_col0(syms, cname, t)
      Bool.pick(List<&2, Case>, keep, Con{Case{ps, b}, rest}, rest)
def b5k_chk_2col_rows(+ctx: CheckCtx, cns0: List<&2, String>, +ty1: ChkTy, +cs: List<&2, Case>) -> Bool:
  CheckCtx{+syms, _, _, _, _, _, _} = ctx
  match cns0:
    case Nil{}: True{}
    case Con{cn, t}:
      +sub_cs = b5k_chk_filter_col0(syms, cn, cs)
      Bool.and(b5k_chk_col_exhaustive(ctx, 1n, ty1, sub_cs), b5k_chk_2col_rows(ctx, t, ty1, cs))
def b5k_chk_2col_m(+ctx: CheckCtx, m: Maybe<&2, List<&2, String>>, ty1: ChkTy, cs: List<&2, Case>) -> Bool:
  match m:
    case None{}: True{}
    case Some{cns0}: b5k_chk_2col_rows(ctx, cns0, ty1, cs)
def b5k_chk_2col_tn(+ctx: CheckCtx, tn0: String, ty1: ChkTy, cs: List<&2, Case>) -> Bool:
  match tn0:
    case SNil{}: True{}
    case s: b5k_chk_2col_m(ctx, b5k_chk_type_ctors(ctx, s), ty1, cs)
def b5k_chk_cases_has_2wild(cs: List<&2, Case>) -> Bool:
  match cs:
    case Nil{}: False{}
    case Con{Case{Con{p0, Con{p1, Nil{}}}, _}, t}: Bool.or(Bool.and(b5k_chk_pat_is_catchall(p0), b5k_chk_pat_is_catchall(p1)), b5k_chk_cases_has_2wild(t))
    case Con{_, t}: b5k_chk_cases_has_2wild(t)
def b5k_chk_mat_exh_go(+ctx: CheckCtx, stys: List<&2, ChkTy>, +cs: List<&2, Case>) -> Bool:
  match stys:
    case Con{ty0, Nil{}}: b5k_chk_col_exhaustive(ctx, 0n, ty0, cs)
    case Con{+ty0, Con{+ty1, Nil{}}}:
      Bool.pick(Bool, b5k_chk_cases_has_2wild(cs), True{},
        Bool.and(b5k_chk_col_exhaustive(ctx, 0n, ty0, cs), b5k_chk_2col_tn(ctx, b5k_chk_col_tname(ctx, 0n, ty0, cs), ty1, cs)))
    case _: True{}
def b5k_chk_mat_exhaustive(+ctx: CheckCtx, env: List<&2, VarBind>, stys: List<&2, ChkTy>, +cs: List<&2, Case>) -> Bool:
  Bool.pick(Bool, b5k_chk_env_has_live_empty(env), True{}, b5k_chk_mat_exh_go(ctx, stys, cs))
def b5k_chk_is_nonfun_con(t: ChkTy) -> Bool:
  match t:
    case TCon{_, _}: True{}
    case _: False{}
def b5k_chk_val_is_erased_let(val: Expr) -> Bool:
  match val:
    case EAnn{_, ERefl{}}: True{}
    case _: False{}
def b5k_chk_ctx_syms(ctx: CheckCtx) -> SymTab:
  CheckCtx{syms, _, _, _, _, _, _} = ctx
  syms
def b5k_chk_val_is_var(val: Expr) -> Bool:
  match val:
    case EVar{_}: True{}
    case EAnn{v, _}: b5k_chk_val_is_var(v)
    case _: False{}
def b5k_chk_binds_len_one(bs: List<&2, VarBind>) -> Bool:
  match bs:
    case Con{_, Nil{}}: True{}
    case _: False{}
def b5k_chk_scruts_in_sub(+rc: RecCtx, ssyms: List<&2, U32>) -> Bool:
  RecCtx{_, _, _, +sub, _, _, _, _, _} = rc
  match ssyms:
    case Nil{}: False{}
    case Con{+s, t}: Bool.or(Bool.and(U32.is_gt(s, 0), b5k_chk_u32_mem(sub, U32.sub(s, 1))), b5k_chk_scruts_in_sub(rc, t))
def b5k_chk_rc_0arg_self(rc: RecCtx, sym: U32) -> Bool:
  RecCtx{fsym, _, pms, _, _, _, _, _, _} = rc
  match pms:
    case Nil{}: U32.is_eq(fsym, U32.add(sym, 1))
    case _: False{}
def b5k_chk_is_tilde_expr(e: Expr) -> Bool:
  match e:
    case EUnOp{1, _}: True{}
    case _: False{}
def b5k_chk_comp_args_bad(args: List<&2, Expr>, +seen_plain: Bool) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{EUnOp{1, _}, t}: Bool.or(seen_plain, b5k_chk_comp_args_bad(t, seen_plain))
    case Con{_, t}: b5k_chk_comp_args_bad(t, True{})
def b5k_chk_count_tilde_args(args: List<&2, Expr>, +acc: U32) -> U32:
  match args:
    case Con{EUnOp{1, _}, t}: b5k_chk_count_tilde_args(t, U32.add(acc, 1))
    case _: acc
def b5k_chk_def_ncomp_ok(di: Maybe<&2, DefInfo>, nt: U32) -> Bool:
  match di:
    case None{}: True{}
    case Some{DefInfo{_, _, nc, _, _, _, _, _, _, _}}: U32.is_le(nt, nc)
def b5k_chk_tilde_arity_bad(ctx: CheckCtx, fun: Expr, +nt: U32) -> Bool:
  CheckCtx{_, _, _, defs, _, _, _} = ctx
  match fun:
    case EVar{s}: Bool.and(U32.is_gt(nt, 0), Bool.not(b5k_chk_def_ncomp_ok(ct_get(DefInfo, defs, s), nt)))
    case ERef{s}: Bool.and(U32.is_gt(nt, 0), Bool.not(b5k_chk_def_ncomp_ok(ct_get(DefInfo, defs, s), nt)))
    case _: False{}
def b5k_chk_is_zero_ctor(m: Maybe<&2, List<&2, String>>) -> Bool:
  match m:
    case Some{Nil{}}: True{}
    case _: False{}
def b5k_chk_empty_mat_stys(ctx: CheckCtx, stys: List<&2, ChkTy>) -> Bool:
  match stys:
    case Nil{}: False{}
    case Con{TCon{h, _}, _}: b5k_chk_is_zero_ctor(b5k_chk_type_ctors(ctx, h))
    case Con{TFun{_, _, _, _}, _}: False{}
    case _: True{}
def b5k_chk_empty_mat_ok(ctx: CheckCtx, env: List<&2, VarBind>, stys: List<&2, ChkTy>) -> Bool:
  Bool.pick(Bool, b5k_chk_env_has_live_empty(env), True{}, b5k_chk_empty_mat_stys(ctx, stys))
def b5k_chk_is_nil_cases(cs: List<&2, Case>) -> Bool:
  match cs:
    case Nil{}: True{}
    case _: False{}
def b5k_chk_is_lammat_ctor(typ: Expr) -> U32:
  match typ:
    case ERef{csym}: U32.add(csym, 1)
    case _: 0
def b5k_chk_let_plus_bad(pat: Pat, val: Expr, vty: ChkTy) -> Bool:
  match pat:
    case PVar{_, True{}}:
      match val vty:
        case ELam{_, _} _: True{}
        case _ TFun{_, _, _, _}: True{}
        case _ _: False{}
    case _: False{}
def b5k_chk_def_ncomp_get(di: Maybe<&2, DefInfo>) -> U32:
  match di:
    case Some{DefInfo{_, _, nc, _, _, _, _, _, _, _}}: nc
    case None{}: 0
def b5k_chk_def_ncomp(ctx: CheckCtx, fun: Expr) -> U32:
  CheckCtx{_, _, _, defs, _, _, _} = ctx
  match fun:
    case EVar{s}: b5k_chk_def_ncomp_get(ct_get(DefInfo, defs, s))
    case ERef{s}: b5k_chk_def_ncomp_get(ct_get(DefInfo, defs, s))
    case _: 0
def b5k_chk_rc_can_neut(rc: RecCtx) -> Bool:
  RecCtx{_, _, pms, _, _, _, _, im, _} = rc
  match pms im:
    case Con{_, _} False{}: True{}
    case _ _: False{}
def b5k_chk_env_upto(env: List<&2, VarBind>, +target: U32, +acc: List<&2, U32>) -> List<&2, U32>:
  match env:
    case Nil{}: acc
    case Con{VarBind{+s, _, _, _, _, _}, rest}:
      Bool.pick(List<&2, U32>, U32.is_eq(s, target), Con{s, acc}, b5k_chk_env_upto(rest, target, Con{s, acc}))
def b5k_chk_ban_for_scruts(+env: List<&2, VarBind>, ssyms: List<&2, U32>, +acc: List<&2, U32>) -> List<&2, U32>:
  match ssyms:
    case Nil{}: acc
    case Con{+s, t}:
      acc2 = Bool.pick(List<&2, U32>, U32.is_gt(s, 0), b5k_chk_env_upto(env, U32.sub(s, 1), acc), acc)
      b5k_chk_ban_for_scruts(env, t, acc2)
def b5k_chk_comp_goal(t: ChkTy) -> ChkTy:
  match t:
    case TFun{_, er, a, r}: TFun{True{}, er, a, r}
    case other: other
def b5k_chk_glam_er_bad(goal: ChkTy) -> Bool:
  match goal:
    case TFun{_, True{}, _, r}: Bool.not(b5k_chk_is_erased_ty(r))
    case _: False{}
def b5k_chk_is_glam_mat(params: List<&2, Param>, body: Expr) -> Bool:
  match params body:
    case Con{Param{0, None{}, False{}, True{}}, Nil{}} EMat{Con{EVar{0}, Nil{}}, _}: True{}
    case _ _: False{}
def b5k_chk_goal_is_any(goal: ChkTy) -> Bool:
  match goal:
    case TAny{}: True{}
    case _: False{}
def b5k_chk_lam_bind_arg(bs: List<&2, VarBind>, goal: ChkTy) -> List<&2, VarBind>:
  match bs goal:
    case Con{VarBind{s, d, er, loc, ic, TAny{}}, rest} TFun{_, _, aty, _}: Con{VarBind{s, d, er, loc, ic, aty}, rest}
    case other _: other
def b5k_chk_is_some_u32(m: Maybe<&2, U32>) -> Bool:
  match m:
    case Some{_}: True{}
    case None{}: False{}
def b5k_chk_has_tdef_m(types: RaVec<Maybe<&2, U32>>, m: Maybe<&2, U32>) -> Bool:
  match m:
    case None{}: False{}
    case Some{id}: b5k_chk_is_some_u32(ra_vec_get(Maybe<&2, U32>, 8n, None{}, id, types))
def b5k_chk_has_tdef_fast(syms: SymTab, types: RaVec<Maybe<&2, U32>>, name: String) -> Bool:
  b5k_chk_has_tdef_m(types, symtab_lookup(syms, name))
def b5k_chk_tdef_has_ctor(+syms: SymTab, cs: List<&2, CtorDef>, +cn: String) -> Bool:
  match cs:
    case Nil{}: False{}
    case Con{CtorDef{s, _, _}, t}: Bool.or(String.eq(symtab_name(syms, s), cn), b5k_chk_tdef_has_ctor(syms, t, cn))
def b5k_chk_tdef_bad_sugar_go(+syms: SymTab, ts: List<&2, TypeDef>, +tn: String, +cn: String) -> Bool:
  match ts:
    case Nil{}: False{}
    case Con{TypeDef{s, _, _, cs}, t}:
      Bool.pick(Bool, String.eq(symtab_name(syms, s), tn), Bool.not(b5k_chk_tdef_has_ctor(syms, cs, cn)), b5k_chk_tdef_bad_sugar_go(syms, t, tn, cn))
def b5k_chk_tdef_bad_sugar_if(hit: Bool, syms: SymTab, ts: List<&2, TypeDef>, tn: String, cn: String) -> Bool:
  match hit:
    case False{}: False{}
    case True{}: b5k_chk_tdef_bad_sugar_go(syms, ts, tn, cn)
def b5k_chk_tdef_bad_sugar(+syms: SymTab, types: RaVec<Maybe<&2, U32>>, ts: List<&2, TypeDef>, +tn: String, cn: String) -> Bool:
  b5k_chk_tdef_bad_sugar_if(b5k_chk_has_tdef_fast(syms, types, tn), syms, ts, tn, cn)
def b5k_chk_lit_sugar_str(is_sc: Bool, syms: SymTab, types: RaVec<Maybe<&2, U32>>, tdefs: List<&2, TypeDef>) -> Bool:
  match is_sc:
    case True{}: b5k_chk_tdef_bad_sugar(syms, types, tdefs, "String", "SCon")
    case False{}: False{}
def b5k_chk_lit_sugar_bad(ctx: CheckCtx, +got: String, is_num: Bool) -> Bool:
  CheckCtx{+syms, +types, _, _, _, _, +tdefs} = ctx
  match is_num:
    case True{}: Bool.or(b5k_chk_tdef_bad_sugar(syms, types, tdefs, "U32", "U32"), b5k_chk_tdef_bad_sugar(syms, types, tdefs, "Nat", "Zero"))
    case False{}: b5k_chk_lit_sugar_str(Bool.or(String.eq(got, "String"), String.eq(got, "Char")), syms, types, tdefs)
def b5k_chk_list_sugar_bad(ctx: CheckCtx) -> Bool:
  CheckCtx{syms, types, _, _, _, _, tdefs} = ctx
  b5k_chk_tdef_bad_sugar(syms, types, tdefs, "List", "Con")
def b5k_chk_env_pos(env: List<&2, VarBind>, +sym: U32, +acc: U32) -> U32:
  match env:
    case Nil{}: 0
    case Con{VarBind{s, _, _, _, _, _}, rest}:
      Bool.pick(U32, U32.is_eq(s, sym), U32.add(acc, 1), b5k_chk_env_pos(rest, sym, U32.add(acc, 1)))
def b5k_chk_scrut_sym(e: Expr) -> U32:
  match e:
    case EVar{s}: U32.add(s, 1)
    case EAnn{v, _}: b5k_chk_scrut_sym(v)
    case _: 0
def b5k_chk_scruts_order_bad(+env: List<&2, VarBind>, es: List<&2, Expr>, +prev_pos: U32) -> Bool:
  match es:
    case Nil{}: False{}
    case Con{e, t}:
      +s1 = b5k_chk_scrut_sym(e)
      +pos = Bool.pick(U32, U32.is_gt(s1, 0), b5k_chk_env_pos(env, U32.sub(s1, 1), 0), 0)
      bad = Bool.and(U32.is_gt(prev_pos, 0), Bool.and(U32.is_gt(pos, 0), U32.is_le(pos, prev_pos)))
      Bool.or(bad, b5k_chk_scruts_order_bad(env, t, pos))
def b5k_chk_scruts_banned(+rc: RecCtx, es: List<&2, Expr>) -> Bool:
  RecCtx{_, _, _, _, _, _, _, _, +bn} = rc
  match es:
    case Nil{}: False{}
    case Con{e, t}:
      +s1 = b5k_chk_scrut_sym(e)
      hit = Bool.and(U32.is_gt(s1, 0), b5k_chk_u32_mem(bn, U32.sub(s1, 1)))
      Bool.or(hit, b5k_chk_scruts_banned(rc, t))
def b5k_chk_op_leaves(+fuel: Nat, e: Expr, acc: List<&2, Expr>) -> List<&2, Expr>:
  match fuel e:
    case 0n x: Con{x, acc}
    case 1n+f EOp{_, a, b}: b5k_chk_op_leaves(f, a, b5k_chk_op_leaves(f, b, acc))
    case _ x: Con{x, acc}
def b5k_chk_op_needs_ann(+op: U32) -> Bool:
  Bool.and(U32.is_ge(op, 1), U32.is_le(op, 4))
def b5k_chk_is_def_targ_bad(ctx: CheckCtx, fun: Expr) -> Bool:
  CheckCtx{_, types, _, defs, _, _, _} = ctx
  match fun:
    case EAnn{EVar{+s}, ESet{}}: Bool.and(b5k_chk_is_some(DefInfo, ct_get(DefInfo, defs, s)), Bool.not(b5k_chk_is_type_flag(ct_get(U32, types, s))))
    case _: False{}
def b5k_chk_work(+fuel: Nat, +ctx: CheckCtx, +rc: RecCtx, +fn_name: String, w: ChkWork) -> ExprRes:
  match fuel w:
    case 0n _: ExprOk{Nil{}}
    case 1n+f WArgs{_, _, _, _, Nil{}}: ExprOk{Nil{}}
    case 1n+f WArgs{+env, +gs, +ers, +nc, Con{EUnOp{1, h}, t}}:
      nc2 = Bool.pick(U32, U32.is_gt(nc, 0), U32.sub(nc, 1), 0)
      r1 = b5k_chk_erased_res(True{}, b5k_chk_work(f, ctx, rc, fn_name, WExpr{b5k_chk_env_only_comp(env), b5k_chk_comp_goal(b5k_chk_head_t(gs)), h}))
      b5k_chk_merge(False{}, fn_name, r1, b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, b5k_chk_tail_t(gs), b5k_chk_tail_b(ers), nc2, t}))
    case 1n+f WArgs{+env, +gs, +ers, +nc, Con{h, t}}:
      +is_c = U32.is_gt(nc, 0)
      nc2 = Bool.pick(U32, is_c, U32.sub(nc, 1), 0)
      +er = b5k_chk_head_b(ers, False{})
      +env_a = Bool.pick(List<&2, VarBind>, is_c, b5k_chk_env_only_comp(env), Bool.pick(List<&2, VarBind>, er, b5k_chk_env_all_dup(env), env))
      +g_a = Bool.pick(ChkTy, is_c, b5k_chk_comp_goal(b5k_chk_head_t(gs)), Bool.pick(ChkTy, er, TErased{}, b5k_chk_head_t(gs)))
      r1 = b5k_chk_erased_res(Bool.or(er, is_c), b5k_chk_work(f, ctx, rc, fn_name, WExpr{env_a, g_a, h}))
      b5k_chk_merge(False{}, fn_name, r1, b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, b5k_chk_tail_t(gs), b5k_chk_tail_b(ers), nc2, t}))
    case 1n+f WCases{_, _, _, _, _, Nil{}}: ExprOk{Nil{}}
    case 1n+f WCases{+env, +goal, +sdups, +stys, +ssyms, Con{Case{+pats, body}, +rest}}:
      ar_ok = U32.is_eq(b5k_list_len(Pat, pats), b5k_list_len(ChkTy, stys))
      pr = b5k_chk_pats(U32.to_nat(1024), ctx, fn_name, b5k_chk_zip_pats(pats, sdups, stys, False{}), Nil{})
      ws = b5k_chk_wild_strip(pats, ssyms)
      env2 = b5k_list_app(VarBind, b5k_chk_redup_binds(pats, ssyms, stys), env)
      +sub1 = b5k_chk_pats_sub(pats, Nil{})
      +sub2_a = b5k_chk_pats_sub2(pats, Nil{})
      sub2_b = Bool.pick(List<&2, U32>, b5k_chk_scruts_in_sub(rc, ssyms), b5k_list_app(U32, sub1, sub2_a), sub2_a)
      rc2 = b5k_chk_rc_add(rc, pats, ssyms, sub1, sub2_b, b5k_chk_pats_lit_max(b5k_chk_ctx_syms(ctx), pats, 0), b5k_chk_ban_for_scruts(env, ssyms, Nil{}))
      +dead_t = b5k_chk_is_dead_tail(pats, rest)
      rest_res = Bool.pick(ExprRes, dead_t, ExprOk{Nil{}}, b5k_chk_work(f, ctx, rc, fn_name, WCases{env, goal, sdups, stys, ssyms, rest}))
      Bool.pick(ExprRes, ar_ok,
        b5k_chk_merge(True{}, fn_name, b5k_chk_work(f, ctx, rc2, fn_name, WCasePat{env2, goal, pr, ws, body}), rest_res),
        ExprErr{"check: " ++ fn_name ++ ": match case pattern count mismatch"})
    case 1n+f WCasePat{_, _, PatErr{err}, _, _}: ExprErr{err}
    case 1n+f WCasePat{env, goal, PatOk{+bs}, ws, body}:
      b5k_chk_strip_res(b5k_list_app(VarBind, bs, ws), b5k_chk_work(f, ctx, rc, fn_name, WExpr{b5k_list_app(VarBind, bs, env), goal, body}))
    case 1n+f WStmtPat{_, _, PatErr{err}, _, _}: ExprErr{err}
    case 1n+f WStmtPat{+env, goal, PatOk{+bs0}, +val, rest}:
      is_loc = Bool.and(b5k_chk_binds_len_one(bs0), Bool.not(b5k_chk_val_is_var(val)))
      +bs = b5k_chk_binds_mark_local(b5k_chk_val_is_erased_let(val), is_loc, bs0)
      r1 = b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, TAny{}, val})
      r2 = b5k_chk_strip_res(bs, b5k_chk_work(f, ctx, rc, fn_name, WStmts{b5k_list_app(VarBind, bs, env), goal, rest}))
      b5k_chk_merge(False{}, fn_name, r1, r2)
    case 1n+f WStmts{_, _, Nil{}}: ExprOk{Nil{}}
    case 1n+f WStmts{_, _, Con{StBind{_, _}, Nil{}}}:
      ExprErr{"check: " ++ fn_name ++ ": do-block bind requires continuation"}
    case 1n+f WStmts{env, goal, Con{StBind{pat, val}, rest}}:
      b5k_chk_work(f, ctx, rc, fn_name, WStmtPat{env, goal, b5k_chk_pats(U32.to_nat(1024), ctx, fn_name, [PatItem{pat, False{}, TAny{}}], Nil{}), val, rest})
    case 1n+f WStmts{+env, goal, Con{StLet{+pat, +val}, rest}}:
      inh = b5k_chk_expr_is_dup(env, val)
      vty = b5k_chk_infer_head(ctx, env, val)
      Bool.pick(ExprRes, b5k_chk_pat_is_var(pat),
        b5k_chk_work(f, ctx, b5k_chk_rc_let(rc, pat, val), fn_name, WStmtPat{env, goal, b5k_chk_pats(U32.to_nat(1024), ctx, fn_name, [PatItem{pat, inh, vty}], Nil{}), val, rest}),
        ExprErr{"check: " ++ fn_name ++ ": do-block let requires a variable binder"})
    case 1n+f WStmts{env, goal, Con{StExpr{val}, Nil{}}}: b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, goal, val})
    case 1n+f WStmts{+env, goal, Con{StExpr{val}, rest}}: b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, TAny{}, val}), b5k_chk_work(f, ctx, rc, fn_name, WStmts{env, goal, rest}))
    case 1n+f WStmts{env, goal, Con{StRet{val}, Nil{}}}: b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, b5k_chk_monad_inner(goal), val})
    case 1n+f WStmts{+env, goal, Con{StRet{val}, rest}}: b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, TAny{}, val}), b5k_chk_work(f, ctx, rc, fn_name, WStmts{env, goal, rest}))
    case 1n+_ WExpr{_, _, EHole{}}: ExprErr{"check: " ++ fn_name ++ ": unfilled hole"}
    case 1n+f WExpr{_, goal, ENum{_}}:
      Bool.pick(ExprRes, b5k_chk_lit_sugar_bad(ctx, "U32", True{}), ExprErr{"check: " ++ fn_name ++ ": shadowed U32/Nat lacks literal constructor"}, b5k_chk_lit(ctx, goal, fn_name, "U32", True{}))
    case 1n+f WExpr{_, goal, EFlt{_}}: b5k_chk_lit(ctx, goal, fn_name, "F32", False{})
    case 1n+f WExpr{_, goal, EChr{_}}:
      Bool.pick(ExprRes, b5k_chk_lit_sugar_bad(ctx, "Char", False{}), ExprErr{"check: " ++ fn_name ++ ": shadowed String lacks literal constructor"}, b5k_chk_lit(ctx, goal, fn_name, "Char", False{}))
    case 1n+f WExpr{_, goal, EStr{_}}:
      Bool.pick(ExprRes, b5k_chk_lit_sugar_bad(ctx, "String", False{}), ExprErr{"check: " ++ fn_name ++ ": shadowed String lacks literal constructor"}, b5k_chk_lit(ctx, goal, fn_name, "String", False{}))
    case 1n+f WExpr{_, goal, EUnit{}}: b5k_chk_lit(ctx, goal, fn_name, "Unit", False{})
    case 1n+f WExpr{_, goal, ERefl{}}: b5k_chk_refl_goal(ctx, b5k_chk_rc_can_neut(rc), fn_name, goal)
    case 1n+f WExpr{env, goal, EVar{+sym}}:
      Bool.pick(ExprRes, b5k_chk_rc_0arg_self(rc, sym), ExprErr{"check: " ++ fn_name ++ ": non-decreasing 0-arg self-recursion"}, b5k_chk_var(ctx, b5k_chk_rc_idx(rc), fn_name, env, goal, sym, False{}))
    case 1n+f WExpr{env, goal, ERef{sym}}: b5k_chk_var(ctx, b5k_chk_rc_idx(rc), fn_name, env, goal, sym, True{})
    case 1n+f WExpr{+env, +goal, EApp{+fun, +args}}:
      +nargs = b5k_list_len(Expr, args)
      +nt = b5k_chk_count_tilde_args(args, 0)
      +aerr = b5k_chk_call_arity(ctx, fn_name, env, fun, nargs)
      +rerr = b5k_chk_rec_call_err(rc, fun, args, fn_name)
      +over = Bool.and(U32.is_gt(nargs, 0), b5k_chk_is_nonfun_con(b5k_chk_infer_head(ctx, env, fun)))
      +bad_t = Bool.or(b5k_chk_comp_args_bad(args, False{}), b5k_chk_tilde_arity_bad(ctx, fun, nt))
      +bad_ta = b5k_chk_is_def_targ_bad(ctx, fun)
      +cs = b5k_chk_opt_sig(b5k_chk_eq_call_sig(ctx, fun, args), b5k_chk_call_sig(ctx, env, fun, nargs, nt))
      res = b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, TAny{}, fun}), b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, b5k_chk_sig_args(cs), b5k_chk_sig_ers(cs), b5k_chk_def_ncomp(ctx, fun), args}))
      res2 = b5k_chk_expect(ctx, fn_name, b5k_chk_sig_ret(cs), goal, res)
      Bool.pick(ExprRes, over, ExprErr{"check: " ++ fn_name ++ ": cannot apply non-function value"},
      Bool.pick(ExprRes, bad_ta, ExprErr{"check: " ++ fn_name ++ ": '<...>' type arguments only allowed on datatypes"},
      Bool.pick(ExprRes, bad_t, ExprErr{"check: " ++ fn_name ++ ": invalid comptime '~' argument"},
      Bool.pick(ExprRes, String.is_empty(aerr), Bool.pick(ExprRes, String.is_empty(rerr), res2, ExprErr{rerr}), ExprErr{aerr}))))
    case 1n+f WExpr{env, +goal, ELam{+params, +body}}:
      +bs = b5k_chk_lam_bind_arg(b5k_chk_params_binds(ctx, b5k_chk_lam_dup(goal), params), goal)
      +is_gm = b5k_chk_is_glam_mat(params, body)
      bad_gm = Bool.and(is_gm, b5k_chk_goal_is_any(goal))
      bad_ger = Bool.and(is_gm, b5k_chk_glam_er_bad(goal))
      Bool.pick(ExprRes, bad_gm, ExprErr{"check: " ++ fn_name ++ ": match lambda requires type annotation"},
      Bool.pick(ExprRes, bad_ger, ExprErr{"check: " ++ fn_name ++ ": cannot match erased parameter in live region"},
        b5k_chk_strip_res(bs, b5k_chk_work(f, ctx, b5k_chk_rc_clear_al(rc), fn_name, WExpr{b5k_list_app(VarBind, bs, env), b5k_chk_lam_ret(goal), body}))))
    case 1n+f WExpr{+env, +goal, ELet{PWild{}, EAnn{ERefl{}, EEq{+eq, _}}, body}}:
      r_eq = Bool.pick(ExprRes, b5k_chk_rwt_eq_bad(ctx, env, eq),
        ExprErr{"check: " ++ fn_name ++ ": rewrite premise must be an equation"},
        b5k_chk_erased_res(True{}, b5k_chk_work(f, ctx, rc, fn_name, WExpr{b5k_chk_env_all_dup(env), TErased{}, eq})))
      b5k_chk_merge(False{}, fn_name, r_eq, b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, b5k_chk_rwt_body_goal(goal), body}))
    case 1n+f WExpr{+env, +goal, ELet{+pat, +val, body}}:
      inh = b5k_chk_expr_is_dup(env, val)
      +vty = b5k_chk_infer_head(ctx, env, val)
      g2 = Bool.pick(ChkTy, b5k_chk_is_refl(val), TAny{}, goal)
      Bool.pick(ExprRes, b5k_chk_let_plus_bad(pat, val, vty), ExprErr{"check: " ++ fn_name ++ ": '+' let binder requires Data type"},
        b5k_chk_work(f, ctx, b5k_chk_rc_let(rc, pat, val), fn_name, WStmtPat{env, g2, b5k_chk_pats(U32.to_nat(1024), ctx, fn_name, [PatItem{pat, inh, vty}], Nil{}), val, [StExpr{body}]}))
    case 1n+f WExpr{+env, +goal, EMat{+scruts, +cases}}:
      sdups = b5k_chk_scruts_dups(env, scruts)
      +stys = b5k_chk_scruts_tys(ctx, env, scruts)
      ssyms = b5k_chk_scruts_syms(scruts)
      bad_al = Bool.and(b5k_chk_rc_after_let(rc), Bool.not(b5k_chk_is_nil_cases(cases)))
      bad_ord = Bool.or(b5k_chk_scruts_order_bad(env, scruts, 0), b5k_chk_scruts_banned(rc, scruts))
      bad_sc = Bool.or(bad_al, Bool.or(bad_ord, b5k_chk_scrut_bad(env, b5k_chk_is_er_goal(goal), scruts, stys)))
      bad_em = Bool.and(b5k_chk_is_nil_cases(cases), Bool.not(b5k_chk_empty_mat_ok(ctx, env, stys)))
      exh_ok = b5k_chk_mat_exhaustive(ctx, env, stys, cases)
      Bool.pick(ExprRes, bad_sc, ExprErr{"check: " ++ fn_name ++ ": invalid match scrutinee"},
      Bool.pick(ExprRes, bad_em, ExprErr{"check: " ++ fn_name ++ ": empty match on non-Empty type"},
      Bool.pick(ExprRes, Bool.not(exh_ok), ExprErr{"check: " ++ fn_name ++ ": non-exhaustive match"},
        b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, Nil{}, Nil{}, 0, scruts}), b5k_chk_work(f, ctx, rc, fn_name, WCases{env, goal, sdups, stys, ssyms, cases})))))
    case 1n+f WExpr{env, +goal, ECtr{sym, +fields}}:
      +info = b5k_chk_lookup_ctor(ctx, sym)
      ok = b5k_chk_ctor_ok(info, b5k_list_len(Expr, fields), goal)
      Bool.pick(ExprRes, ok, b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, b5k_chk_ctor_fgoals(info, goal), b5k_chk_ctor_fers(info), 0, fields}), ExprErr{b5k_chk_ctor_err(fn_name)})
    case 1n+f WExpr{+env, +goal, EAnn{EOp{+op, +a, +b}, +typ}}:
      +is_er = b5k_chk_is_refl(typ)
      +is_cmp = U32.is_ge(op, 20)
      +aty = b5k_chk_ann_cmp_ty(EOp{op, a, b}, b5k_chk_goal_expr(ctx, typ))
      +env_v = Bool.pick(List<&2, VarBind>, Bool.or(is_er, is_cmp), b5k_chk_env_all_dup(env), env)
      res = b5k_chk_erased_res(is_er, b5k_chk_work(f, ctx, rc, fn_name, WArgs{env_v, Nil{}, Nil{}, 0, b5k_chk_op_leaves(32n, EOp{op, a, b}, Nil{})}))
      b5k_chk_expect(ctx, fn_name, aty, goal, res)
    case 1n+f WExpr{+env, +goal, EAnn{+val, +typ}}:
      +lm_c = b5k_chk_is_lammat_ctor(typ)
      +bad_lm = Bool.and(U32.is_gt(lm_c, 0), Bool.not(b5k_chk_is_some(CtorInfo, b5k_chk_lookup_ctor(ctx, U32.sub(lm_c, 1)))))
      +is_er = b5k_chk_is_refl(typ)
      +is_cmp = b5k_chk_is_cmp_op(val)
      +aty = Bool.pick(ChkTy, U32.is_gt(lm_c, 0), TAny{}, b5k_chk_ann_cmp_ty(val, b5k_chk_goal_expr(ctx, typ)))
      +env_v = Bool.pick(List<&2, VarBind>, Bool.or(is_er, is_cmp), b5k_chk_env_all_dup(env), env)
      +g_v = Bool.pick(ChkTy, is_er, TErased{}, Bool.pick(ChkTy, Bool.or(U32.is_gt(lm_c, 0), b5k_chk_is_rwt_var(typ, val)), goal, Bool.pick(ChkTy, is_cmp, TAny{}, aty)))
      res = b5k_chk_erased_res(is_er, b5k_chk_work(f, ctx, rc, fn_name, WExpr{env_v, g_v, val}))
      Bool.pick(ExprRes, bad_lm, ExprErr{"check: " ++ fn_name ++ ": unknown constructor in match lambda"}, b5k_chk_expect(ctx, fn_name, aty, goal, res))
    case 1n+f WExpr{env, _, EEq{a, b}}: b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, Nil{}, Nil{}, 0, [a, b]})
    case 1n+f WExpr{env, goal, EOp{+op, a, b}}:
      oty = Bool.pick(ChkTy, U32.is_ge(op, 20), b5k_chk_t0("Bool"), TAny{})
      Bool.pick(ExprRes, b5k_chk_op_needs_ann(op), ExprErr{"check: " ++ fn_name ++ ": binary operator requires '(a op b : T)' type annotation"},
        b5k_chk_expect(ctx, fn_name, oty, goal, b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, Nil{}, Nil{}, 0, [a, b]})))
    case 1n+f WExpr{env, goal, EUnOp{+op, val}}:
      Bool.pick(ExprRes, U32.is_eq(op, 1), ExprErr{"check: " ++ fn_name ++ ": '~' only allowed in template call arguments"},
        b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, Bool.pick(ChkTy, b5k_chk_is_erased_ty(goal), TErased{}, TAny{}), val}))
    case 1n+f WExpr{env, goal, EArrNew{elems}}: b5k_chk_expect(ctx, fn_name, b5k_chk_t0("Array"), goal, b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, Nil{}, Nil{}, 0, elems}))
    case 1n+f WExpr{env, _, EArrGet{arr, idx}}: b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, Nil{}, Nil{}, 0, [arr, idx]})
    case 1n+f WExpr{env, _, EArrSet{arr, idx, val}}: b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, Nil{}, Nil{}, 0, [arr, idx, val]})
    case 1n+f WExpr{+env, +goal, EIf{cond, then_e, else_e}}:
      rc0 = b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, b5k_chk_t0("Bool"), cond})
      rb = b5k_chk_merge(True{}, fn_name, b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, goal, then_e}), b5k_chk_work(f, ctx, rc, fn_name, WExpr{env, goal, else_e}))
      b5k_chk_merge(False{}, fn_name, rc0, rb)
    case 1n+f WExpr{env, goal, EDo{stmts}}: b5k_chk_work(f, ctx, rc, fn_name, WStmts{env, goal, stmts})
    case 1n+f WExpr{env, +goal, EPair{a, b}}:
      res = b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, b5k_chk_pair_goals(goal), Nil{}, 0, [a, b]})
      Bool.pick(ExprRes, b5k_chk_pair_goal_ok(goal), res, ExprErr{b5k_chk_head_err(fn_name, b5k_chk_t0("Sigma"), goal)})
    case 1n+f WExpr{env, +goal, EList{+elems}}:
      Bool.pick(ExprRes, b5k_chk_list_sugar_bad(ctx), ExprErr{"check: " ++ fn_name ++ ": shadowed List lacks literal constructor"},
        b5k_chk_expect(ctx, fn_name, b5k_chk_t0("List"), goal, b5k_chk_work(f, ctx, rc, fn_name, WArgs{env, b5k_chk_list_elem_goals(elems, goal), Nil{}, 0, elems})))
    case 1n+_ WExpr{_, _, _}: ExprOk{Nil{}}
# Top-Level Book Entrypoint
def b5k_chk_expr_err(r: ExprRes) -> String:
  match r:
    case ExprOk{_}: ""
    case ExprErr{err}: err
def b5k_chk_erased_goal(is_er: Bool, g: ChkTy) -> ChkTy:
  match is_er g:
    case True{} TAny{}: TErased{}
    case _ other: other
def b5k_chk_expr_has_free(+fuel: Nat, +ctx: CheckCtx, +env: List<&2, VarBind>, es: List<&2, Expr>) -> Bool:
  match fuel es:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+f Con{EVar{+sym}, t}:
      is_f = Bool.and(Bool.not(b5k_chk_binds_mem(env, sym)), Bool.not(b5k_chk_is_known_global(ctx, sym)))
      Bool.or(is_f, b5k_chk_expr_has_free(f, ctx, env, t))
    case 1n+f Con{EApp{fn, args}, t}: b5k_chk_expr_has_free(f, ctx, env, Con{fn, b5k_list_app(Expr, args, t)})
    case 1n+f Con{ECtr{_, fs}, t}: b5k_chk_expr_has_free(f, ctx, env, b5k_list_app(Expr, fs, t))
    case 1n+f Con{EOp{_, a, b}, t}: b5k_chk_expr_has_free(f, ctx, env, Con{a, Con{b, t}})
    case 1n+f Con{EAnn{v, _}, t}: b5k_chk_expr_has_free(f, ctx, env, Con{v, t})
    case 1n+f Con{EPair{a, b}, t}: b5k_chk_expr_has_free(f, ctx, env, Con{a, Con{b, t}})
    case 1n+f Con{_, t}: b5k_chk_expr_has_free(f, ctx, env, t)
def b5k_chk_exs_goal(ctx: CheckCtx, env: List<&2, VarBind>, from_law: Bool, g: ChkTy) -> ChkTy:
  match from_law g:
    case True{} TEq{+a, +b}: Bool.pick(ChkTy, b5k_chk_expr_has_free(32n, ctx, env, [a, b]), b5k_chk_t0("Sigma"), TEq{a, b})
    case _ other: other
def b5k_chk_dup_pms(+syms: SymTab, +fn_name: String, ps: List<&2, Param>, +seen: List<&2, U32>) -> String:
  match ps:
    case Nil{}: ""
    case Con{Param{+s, _, _, _}, t}:
      is_w = String.eq(symtab_name(syms, s), "_")
      bad = Bool.and(Bool.not(is_w), b5k_chk_u32_mem(seen, s))
      Bool.pick(String, bad, "check: " ++ fn_name ++ ": duplicate parameter: " ++ symtab_name(syms, s), b5k_chk_dup_pms(syms, fn_name, t, Con{s, seen}))
def b5k_chk_pm_has_grade(ps: List<&2, Param>) -> Bool:
  match ps:
    case Nil{}: False{}
    case Con{Param{_, None{}, _, _}, _}: True{}
    case Con{_, t}: b5k_chk_pm_has_grade(t)
def b5k_chk_tdefs_nondata(ts: List<&2, TypeDef>, +acc: List<&2, U32>) -> List<&2, U32>:
  match ts:
    case Nil{}: acc
    case Con{TypeDef{s, tps, False{}, _}, t}: b5k_chk_tdefs_nondata(t, Bool.pick(List<&2, U32>, b5k_chk_pm_has_grade(tps), acc, Con{s, acc}))
    case Con{_, t}: b5k_chk_tdefs_nondata(t, acc)
def b5k_chk_is_nd_kind(+syms: SymTab, e: Expr) -> Bool:
  match e:
    case EVar{sym}:
      +nm = symtab_name(syms, sym)
      Bool.or(String.eq(nm, "Type"), String.eq(nm, "Kind"))
    case EApp{fun, _}: b5k_chk_is_nd_kind(syms, fun)
    case _: False{}
def b5k_chk_is_nd_opt(syms: SymTab, opt: Maybe<&2, Expr>) -> Bool:
  match opt:
    case Some{ty}: b5k_chk_is_nd_kind(syms, ty)
    case None{}: False{}
def b5k_chk_args_has_g2(es: List<&2, Expr>) -> Bool:
  match es:
    case Nil{}: False{}
    case Con{ENum{2}, _}: True{}
    case Con{_, t}: b5k_chk_args_has_g2(t)
def b5k_chk_ty_is_nondata(+syms: SymTab, +nd: List<&2, U32>, ty: Expr) -> Bool:
  match ty:
    case EAll{_, _}: True{}
    case EOp{5, a, b}: Bool.or(b5k_chk_ty_is_nondata(syms, nd, a), b5k_chk_ty_is_nondata(syms, nd, b))
    case EVar{+s}: Bool.or(b5k_chk_u32_mem(nd, s), Bool.or(String.eq(symtab_name(syms, s), "Type"), String.eq(symtab_name(syms, s), "Kind")))
    case EApp{fun, args}: Bool.and(Bool.not(b5k_chk_args_has_g2(args)), b5k_chk_ty_is_nondata(syms, nd, fun))
    case _: False{}
def b5k_chk_ty_nd_opt(syms: SymTab, nd: List<&2, U32>, opt: Maybe<&2, Expr>) -> Bool:
  match opt:
    case Some{ty}: b5k_chk_ty_is_nondata(syms, nd, ty)
    case None{}: False{}
def b5k_chk_plus_pms(+syms: SymTab, +fn_name: String, ps: List<&2, Param>, +nd: List<&2, U32>) -> String:
  match ps:
    case Nil{}: ""
    case Con{Param{s, +mty, er, dup}, t}:
      nd2 = Bool.pick(List<&2, U32>, b5k_chk_is_nd_opt(syms, mty), Con{s, nd}, nd)
      bad = Bool.and(Bool.not(er), Bool.and(dup, b5k_chk_ty_nd_opt(syms, nd, mty)))
      Bool.pick(String, bad, "check: " ++ fn_name ++ ": '+' binder requires Data type", b5k_chk_plus_pms(syms, fn_name, t, nd2))
def b5k_chk_pm_rc_syms(ps: List<&2, Param>) -> List<&2, U32>:
  match ps:
    case Nil{}: Nil{}
    case Con{Param{s, _, er, _}, t}: Con{Bool.pick(U32, er, 0, U32.add(s, 1)), b5k_chk_pm_rc_syms(t)}
def b5k_chk_ret_targ_bad(ctx: CheckCtx, mret: Maybe<&2, Expr>) -> Bool:
  match mret:
    case Some{EApp{fun, _}}: b5k_chk_is_def_targ_bad(ctx, fun)
    case _: False{}
def b5k_chk_def(+ctx: CheckCtx, cur_idx: U32, d: Def) -> String:
  CheckCtx{+syms, _, _, _, laws, _, tdefs} = ctx
  Def{+sym, +params, +ret, body, is_import, imp_path} = d
  match is_import:
    case True{}:
      +fn_name = b5k_chk_sym_name(ctx, sym)
      Bool.pick(String, b5k_chk_is_runtime_provider(fn_name), "", "compile: foreign provider unavailable in fixed runtime: " ++ fn_name)
    case False{}:
      +fn_name = b5k_chk_sym_name(ctx, sym)
      +ld = ct_get(LawDef, laws, sym)
      no_sig = Bool.and(Bool.not(b5k_chk_is_some(Expr, ret)), Bool.not(b5k_chk_is_some(LawDef, ld)))
      +mps = b5k_chk_apply_law_params(params, ld)
      +mret = b5k_chk_apply_law_ret(params, ret, ld)
      +is_er = b5k_chk_ret_is_erased(syms, mret)
      +env = b5k_chk_params_binds(ctx, is_er, mps)
      +from_law = Bool.and(Bool.not(b5k_chk_is_some(Expr, ret)), b5k_chk_is_some(LawDef, ld))
      goal = b5k_chk_exs_goal(ctx, env, from_law, b5k_chk_erased_goal(is_er, b5k_chk_goal_opt(ctx, mret)))
      +is_uns = String.eq(imp_path, "@unsafe")
      rc_sym = Bool.pick(U32, is_uns, 0, U32.add(sym, 1))
      rc_ci = Bool.pick(U32, is_uns, 0, cur_idx)
      +dperr = b5k_chk_dup_pms(syms, fn_name, mps, Nil{})
      +pperr = b5k_chk_plus_pms(syms, fn_name, mps, b5k_chk_tdefs_nondata(tdefs, Nil{}))
      bad_rt = b5k_chk_ret_targ_bad(ctx, mret)
      Bool.pick(String, no_sig, "check: " ++ fn_name ++ ": untyped def without matching law",
      Bool.pick(String, bad_rt, "check: " ++ fn_name ++ ": '<...>' type arguments only allowed on datatypes",
      Bool.pick(String, Bool.not(String.is_empty(dperr)), dperr,
      Bool.pick(String, Bool.not(String.is_empty(pperr)), pperr,
        b5k_chk_expr_err(b5k_chk_work(U32.to_nat(4096), ctx, RecCtx{rc_sym, rc_ci, b5k_chk_pm_rc_syms(mps), Nil{}, Nil{}, 0, False{}, False{}, Nil{}}, fn_name, WExpr{env, goal, body}))))))
def b5k_chk_has_tdef(+syms: SymTab, ts: List<&2, TypeDef>, +nm: String) -> Bool:
  match ts:
    case Nil{}: False{}
    case Con{TypeDef{s, _, _, _}, t}: Bool.or(String.eq(symtab_name(syms, s), nm), b5k_chk_has_tdef(syms, t, nm))
def b5k_chk_is_reserved_def(+syms: SymTab, +ts: List<&2, TypeDef>, +nm: String) -> Bool:
  Bool.pick(Bool, Bool.or(String.eq(nm, "Nat.add"), Bool.or(String.eq(nm, "Nat.sub"), String.eq(nm, "Nat.mul"))), Bool.not(b5k_chk_has_tdef(syms, ts, "Nat")),
  Bool.pick(Bool, String.eq(nm, "U32"), Bool.not(b5k_chk_has_tdef(syms, ts, "U32")), False{}))
def b5k_chk_dup_defs(+syms: SymTab, +ts: List<&2, TypeDef>, ds: List<&2, Def>, +seen: List<&2, U32>) -> String:
  match ds:
    case Nil{}: ""
    case Con{Def{+s, _, _, _, _, _}, t}:
      Bool.pick(String, b5k_chk_u32_mem(seen, s), "check: duplicate declaration: " ++ symtab_name(syms, s), b5k_chk_dup_defs(syms, ts, t, Con{s, seen}))
def b5k_chk_laws_filled(+syms: SymTab, ls: List<&2, LawDef>, +ds: List<&2, Def>) -> String:
  match ls:
    case Nil{}: ""
    case Con{LawDef{+s, _, _}, t}:
      Bool.pick(String, b5k_chk_defs_has(ds, s), b5k_chk_laws_filled(syms, t, ds), "check: law without def (TODO): " ++ symtab_name(syms, s))
def b5k_chk_dup_fields(+syms: SymTab, +tname: String, fs: List<&2, Param>, +seen: List<&2, U32>) -> String:
  match fs:
    case Nil{}: ""
    case Con{Param{+s, _, _, _}, t}:
      Bool.pick(String, b5k_chk_u32_mem(seen, s), "check: " ++ tname ++ ": duplicate field: " ++ symtab_name(syms, s), b5k_chk_dup_fields(syms, tname, t, Con{s, seen}))
def b5k_chk_dup_ctors(+syms: SymTab, +tname: String, cs: List<&2, CtorDef>, +seen_c: List<&2, U32>) -> String:
  match cs:
    case Nil{}: ""
    case Con{CtorDef{+s, _, fs}, t}:
      +ferr = b5k_chk_dup_fields(syms, tname, fs, Nil{})
      Bool.pick(String, b5k_chk_u32_mem(seen_c, s), "check: duplicate constructor: " ++ symtab_name(syms, s),
        Bool.pick(String, String.is_empty(ferr), b5k_chk_dup_ctors(syms, tname, t, Con{s, seen_c}), ferr))
def b5k_chk_add_csyms(cs: List<&2, CtorDef>, acc: List<&2, U32>) -> List<&2, U32>:
  match cs:
    case Nil{}: acc
    case Con{CtorDef{s, _, _}, t}: b5k_chk_add_csyms(t, Con{s, acc})
def b5k_chk_dup_types(+syms: SymTab, ts: List<&2, TypeDef>, +seen_t: List<&2, U32>, +seen_c: List<&2, U32>) -> String:
  match ts:
    case Nil{}: ""
    case Con{TypeDef{+s, _, _, +cs}, t}:
      +tn = symtab_name(syms, s)
      +cerr = b5k_chk_dup_ctors(syms, tn, cs, seen_c)
      Bool.pick(String, b5k_chk_u32_mem(seen_t, s), "check: duplicate type: " ++ tn,
        Bool.pick(String, String.is_empty(cerr), b5k_chk_dup_types(syms, t, Con{s, seen_t}, b5k_chk_add_csyms(cs, seen_c)), cerr))
def b5k_chk_defs(+ctx: CheckCtx, ds: List<&2, Def>, +idx: U32) -> String:
  match ds:
    case Nil{}: ""
    case Con{h, t}:
      +err = b5k_chk_def(ctx, idx, h)
      Bool.pick(String, String.is_empty(err), b5k_chk_defs(ctx, t, U32.add(idx, 1)), err)
# Data-Kind Field Discipline Check (rejects non-Data live fields in `is Data` types)
def b5k_chk_is_nondata_kind(+syms: SymTab, e: Expr) -> Bool:
  match e:
    case EVar{sym}: String.eq(symtab_name(syms, sym), "Type")
    case EApp{fun, _}: b5k_chk_is_nondata_kind(syms, fun)
    case _: False{}
def b5k_chk_is_nondata_opt(syms: SymTab, opt: Maybe<&2, Expr>) -> Bool:
  match opt:
    case Some{ty}: b5k_chk_is_nondata_kind(syms, ty)
    case None{}: False{}
def b5k_chk_nondata_syms(+syms: SymTab, ps: List<&2, Param>, +acc: List<&2, U32>) -> List<&2, U32>:
  match ps:
    case Nil{}: acc
    case Con{Param{sym, mty, _, _}, rest}:
      acc2 = Bool.pick(List<&2, U32>, b5k_chk_is_nondata_opt(syms, mty), Con{sym, acc}, acc)
      b5k_chk_nondata_syms(syms, rest, acc2)
def b5k_chk_field_is_nondata(+nd: List<&2, U32>, ty: Expr) -> Bool:
  match ty:
    case EAll{_, _}: True{}
    case EVar{sym}: b5k_chk_u32_mem(nd, sym)
    case _: False{}
def b5k_chk_field_nondata_opt(nd: List<&2, U32>, opt: Maybe<&2, Expr>) -> Bool:
  match opt:
    case Some{ty}: b5k_chk_field_is_nondata(nd, ty)
    case None{}: False{}
def b5k_chk_data_fields(+is_data: Bool, +tname: String, +nd: List<&2, U32>, fs: List<&2, Param>) -> String:
  match fs:
    case Nil{}: ""
    case Con{Param{_, mty, erased, dup}, rest}:
      bad = Bool.and(Bool.not(erased), Bool.and(Bool.or(is_data, dup), b5k_chk_field_nondata_opt(nd, mty)))
      Bool.pick(String, bad, "check: " ++ tname ++ ": non-Data field in Data type", b5k_chk_data_fields(is_data, tname, nd, rest))
def b5k_chk_data_ctors(+is_data: Bool, +syms: SymTab, +tname: String, +nd: List<&2, U32>, cs: List<&2, CtorDef>) -> String:
  match cs:
    case Nil{}: ""
    case Con{CtorDef{_, _, +fs}, rest}:
      +nd2 = b5k_chk_nondata_syms(syms, fs, nd)
      +err = b5k_chk_data_fields(is_data, tname, nd2, fs)
      Bool.pick(String, String.is_empty(err), b5k_chk_data_ctors(is_data, syms, tname, nd, rest), err)
def b5k_chk_types(+syms: SymTab, ts: List<&2, TypeDef>) -> String:
  match ts:
    case Nil{}: ""
    case Con{TypeDef{tsym, tps, is_data, ctors}, rest}:
      +err = b5k_chk_data_ctors(is_data, syms, symtab_name(syms, tsym), b5k_chk_nondata_syms(syms, tps, Nil{}), ctors)
      Bool.pick(String, String.is_empty(err), b5k_chk_types(syms, rest), err)
def b5k_check(+book: Book) -> CheckRes:
  Book{+types, +defs, +laws, +syms} = book
  +dterr = b5k_chk_dup_types(syms, types, Nil{}, Nil{})
  +dderr = Bool.pick(String, String.is_empty(dterr), b5k_chk_dup_defs(syms, types, defs, Nil{}), dterr)
  +lerr = Bool.pick(String, String.is_empty(dderr), b5k_chk_laws_filled(syms, laws, defs), dderr)
  +terr = Bool.pick(String, String.is_empty(lerr), b5k_chk_types(syms, types), lerr)
  +err = Bool.pick(String, String.is_empty(terr), b5k_chk_defs(b5k_chk_build_ctx(types, defs, laws, syms), defs, 1), terr)
  CheckRes{String.is_empty(err), err, book}
