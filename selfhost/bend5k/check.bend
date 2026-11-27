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
  TCon{head: String, args: List<&2, ChkTy>}
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
  CtorInfo{type_name: String, arity: U32, fdups: List<&2, Bool>, ftys: List<&2, ChkTy>}
type CtorEntry is Data:
  CtorEntry{name: String, tname: String, arity: U32}
type DefInfo is Data:
  DefInfo{arity: U32, total_arity: U32, ret_fn: Bool, is_import: Bool, param_tys: List<&2, ChkTy>, live_tys: List<&2, ChkTy>, param_ers: List<&2, Bool>, ret_ty: ChkTy}
type CallSig is Data:
  CallSig{arg_tys: List<&2, ChkTy>, arg_ers: List<&2, Bool>, ret_ty: ChkTy}
def ct_set(-A: Data, t: RaVec<Maybe<&2, A>>, +k: U32, v: A) -> RaVec<Maybe<&2, A>>: ra_vec_set(Maybe<&2, A>, 8n, k, Some{v}, t)
def ct_get(-A: Data, t: RaVec<Maybe<&2, A>>, +k: U32) -> Maybe<&2, A>: ra_vec_get(Maybe<&2, A>, 8n, None{}, k, t)
type CheckCtx is Data:
  CheckCtx{syms: SymTab, types: RaVec<Maybe<&2, U32>>, ctors: RaVec<Maybe<&2, CtorInfo>>, defs: RaVec<Maybe<&2, DefInfo>>, laws: RaVec<Maybe<&2, LawDef>>}
type VarBind is Data:
  VarBind{sym: U32, dup: Bool, typ: ChkTy}
type PatItem is Data:
  PatItem{pat: Pat, dup_inh: Bool, typ_inh: ChkTy}
type LookupRes is Data:
  LNotFound{}
  LFoundDup{typ: ChkTy}
  LFoundLin{typ: ChkTy}
type PatRes is Data:
  PatOk{binds: List<&2, VarBind>}
  PatErr{err: String}
type ExprRes is Data:
  ExprOk{uses: List<&2, U32>}
  ExprErr{err: String}
type ChkWork is Data:
  WExpr{env: List<&2, VarBind>, goal: ChkTy, e: Expr}
  WArgs{env: List<&2, VarBind>, goals: List<&2, ChkTy>, ers: List<&2, Bool>, es: List<&2, Expr>}
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
   "Map", "IO", "IO.OP", "App", "File", "Socket", "Listener", "Window", "Audio", "Chan", "Type", "Data", "Kind", "Set"]
def b5k_chk_is_universe(+name: String) -> Bool:
  Bool.or(Bool.or(String.eq(name, "Type"), String.eq(name, "Data")),
          Bool.or(String.eq(name, "Kind"), String.eq(name, "Set")))
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
def b5k_chk_head_sym(syms: SymTab, types: RaVec<Maybe<&2, U32>>, +sym: U32) -> ChkTy:
  hit = b5k_chk_is_some(U32, ct_get(U32, types, sym))
  +nm = symtab_name(syms, sym)
  Bool.pick(ChkTy, Bool.and(hit, Bool.not(b5k_chk_is_universe(nm))), b5k_chk_t0(nm), TAny{})
def b5k_chk_ty_app(rf: TyRes, ra: TyRes) -> TyRes:
  match rf ra:
    case TROne{TCon{h, a0}} TRMany{a1}: TROne{TCon{h, b5k_list_app(ChkTy, a0, a1)}}
    case _ _: TROne{TAny{}}
def b5k_chk_ty_cons(rh: TyRes, rt: TyRes) -> TyRes:
  match rh rt:
    case TROne{h} TRMany{t}: TRMany{Con{h, t}}
    case _ _: TRMany{Nil{}}
def b5k_chk_ty_sigma(r1: TyRes, r2: TyRes) -> TyRes:
  match r1 r2:
    case TROne{t1} TROne{t2}: TROne{TCon{"Sigma", [t1, t2]}}
    case _ _: TROne{b5k_chk_t0("Sigma")}
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
    case 1n+f TWOne{EApp{fun, args}}: b5k_chk_ty_app(b5k_chk_ty_w(f, syms, types, TWOne{fun}), b5k_chk_ty_w(f, syms, types, TWMany{args}))
    case 1n+f TWOne{EOp{op, +a, +b}}:
      Bool.pick(TyRes, U32.is_eq(op, B5K_OP_AND()),
        Bool.pick(TyRes, Bool.or(b5k_chk_is_and(a), b5k_chk_is_and(b)), TROne{b5k_chk_t0("Sigma")},
          b5k_chk_ty_sigma(b5k_chk_ty_w(f, syms, types, TWOne{a}), b5k_chk_ty_w(f, syms, types, TWOne{b}))),
        TROne{TAny{}})
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
def b5k_chk_ty_zip(a1: List<&2, ChkTy>, a2: List<&2, ChkTy>, acc: List<&2, TyPair>) -> List<&2, TyPair>:
  match a1 a2:
    case Con{h1, t1} Con{h2, t2}: b5k_chk_ty_zip(t1, t2, Con{TyPair{h1, h2}, acc})
    case _ _: acc
def b5k_chk_ty_ok_go(fuel: Nat, q: List<&2, TyPair>) -> Bool:
  match fuel q:
    case 0n _: True{}
    case _ Nil{}: True{}
    case 1n+f Con{TyPair{TAny{}, _}, rest}: b5k_chk_ty_ok_go(f, rest)
    case 1n+f Con{TyPair{_, TAny{}}, rest}: b5k_chk_ty_ok_go(f, rest)
    case 1n+f Con{TyPair{TCon{h1, a1}, TCon{h2, a2}}, rest}:
      Bool.pick(Bool, String.eq(h1, h2), b5k_chk_ty_ok_go(f, b5k_chk_ty_zip(a1, a2, rest)), False{})
def b5k_chk_head_ok(got: ChkTy, goal: ChkTy) -> Bool: b5k_chk_ty_ok_go(64n, [TyPair{got, goal}])
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
    case 1n+f Con{TSOne{TCon{h, Nil{}}}, rest}: h ++ b5k_chk_ty_show_go(f, rest)
    case 1n+f Con{TSOne{TCon{h, args}}, rest}: h ++ "<" ++ b5k_chk_ty_show_go(f, b5k_chk_ty_show_args(args, Con{TSSep{">"}, rest}))
def b5k_chk_ty_show(t: ChkTy) -> String: b5k_chk_ty_show_go(64n, [TSOne{t}])
def b5k_chk_head_err(fn_name: String, got: ChkTy, goal: ChkTy) -> String:
  "check: " ++ fn_name ++ ": type mismatch (expected " ++ b5k_chk_ty_show(goal) ++ ", got " ++ b5k_chk_ty_show(got) ++ ")"
def b5k_chk_expect(fn_name: String, +got: ChkTy, +goal: ChkTy, res: ExprRes) -> ExprRes:
  Bool.pick(ExprRes, b5k_chk_head_ok(got, goal), res, ExprErr{b5k_chk_head_err(fn_name, got, goal)})
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
    case Con{CtorEntry{nm, tn, ar}, rest}: b5k_chk_seed_base_ctors(syms, rest, ct_set_maybe(CtorInfo, symtab_lookup(syms, nm), CtorInfo{tn, ar, Nil{}, Nil{}}, cm))
def b5k_chk_index_ctors(+syms: SymTab, +tm: RaVec<Maybe<&2, U32>>, +tname: String, cs: List<&2, CtorDef>, cm: RaVec<Maybe<&2, CtorInfo>>) -> RaVec<Maybe<&2, CtorInfo>>:
  match cs:
    case Nil{}: cm
    case Con{CtorDef{csym, _, +fields}, rest}:
      b5k_chk_index_ctors(syms, tm, tname, rest, ct_set(CtorInfo, cm, csym, CtorInfo{tname, b5k_list_len(Param, fields), b5k_chk_param_dups(fields), b5k_chk_param_tys(syms, tm, fields)}))
def b5k_chk_index_types(ts: List<&2, TypeDef>, tm: RaVec<Maybe<&2, U32>>) -> RaVec<Maybe<&2, U32>>:
  match ts:
    case Nil{}: tm
    case Con{TypeDef{tsym, _, _, _}, rest}: b5k_chk_index_types(rest, ct_set(U32, tm, tsym, 1))
def b5k_chk_index_all_ctors(+syms: SymTab, +tm: RaVec<Maybe<&2, U32>>, ts: List<&2, TypeDef>, cm: RaVec<Maybe<&2, CtorInfo>>) -> RaVec<Maybe<&2, CtorInfo>>:
  match ts:
    case Nil{}: cm
    case Con{TypeDef{tsym, _, _, ctors}, rest}: b5k_chk_index_all_ctors(syms, tm, rest, b5k_chk_index_ctors(syms, tm, symtab_name(syms, tsym), ctors, cm))
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
    case Con{Param{sym, typ, er, dup}, prest} Con{Param{_, ltyp, ler, ldup}, lrest}: Con{Param{sym, b5k_chk_opt_or(Expr, typ, ltyp), Bool.or(er, ler), Bool.or(dup, ldup)}, b5k_chk_merge_law_params(prest, lrest)}
def b5k_chk_apply_law_params(ps: List<&2, Param>, ld: Maybe<&2, LawDef>) -> List<&2, Param>:
  match ld:
    case None{}: ps
    case Some{LawDef{_, lps, _}}: b5k_chk_merge_law_params(ps, lps)
def b5k_chk_apply_law_ret(ret: Maybe<&2, Expr>, ld: Maybe<&2, LawDef>) -> Maybe<&2, Expr>:
  match ret ld:
    case None{} Some{LawDef{_, _, lret}}: Some{lret}
    case r _: r
def b5k_chk_index_defs(+syms: SymTab, +tm: RaVec<Maybe<&2, U32>>, +lm: RaVec<Maybe<&2, LawDef>>, ds: List<&2, Def>, dm: RaVec<Maybe<&2, DefInfo>>) -> RaVec<Maybe<&2, DefInfo>>:
  match ds:
    case Nil{}: dm
    case Con{Def{+dsym, params, ret, _, is_import, _}, rest}:
      +ld = ct_get(LawDef, lm, dsym)
      +mps = b5k_chk_apply_law_params(params, ld)
      +mret = b5k_chk_apply_law_ret(ret, ld)
      b5k_chk_index_defs(syms, tm, lm, rest, ct_set(DefInfo, dm, dsym, DefInfo{b5k_chk_count_live(mps, 0), b5k_list_len(Param, mps), b5k_chk_ret_is_fn(mret), is_import,
                   b5k_chk_param_tys(syms, tm, mps), b5k_chk_live_tys(syms, tm, mps), b5k_chk_param_ers(mps), b5k_chk_head_opt(syms, tm, mret)}))
def b5k_chk_index_laws(ls: List<&2, LawDef>, lm: RaVec<Maybe<&2, LawDef>>) -> RaVec<Maybe<&2, LawDef>>:
  match ls:
    case Nil{}: lm
    case Con{LawDef{+lsym, lps, lret}, rest}: b5k_chk_index_laws(rest, ct_set(LawDef, lm, lsym, LawDef{lsym, lps, lret}))
def b5k_chk_build_ctx(+types: List<&2, TypeDef>, defs: List<&2, Def>, laws: List<&2, LawDef>, +syms: SymTab) -> CheckCtx:
  +tm = b5k_chk_index_types(types, b5k_chk_seed_base_types(syms, b5k_chk_base_type_names(), RVEmpty{}))
  cm = b5k_chk_index_all_ctors(syms, tm, types, b5k_chk_seed_base_ctors(syms, b5k_chk_base_ctors(), RVEmpty{}))
  +lm = b5k_chk_index_laws(laws, RVEmpty{})
  CheckCtx{syms, tm, cm, b5k_chk_index_defs(syms, tm, lm, defs, RVEmpty{}), lm}
# Context Lookup Helpers
def b5k_chk_sym_name(ctx: CheckCtx, sym: U32) -> String:
  CheckCtx{syms, _, _, _, _} = ctx
  symtab_name(syms, sym)
def b5k_chk_lookup_ctor(ctx: CheckCtx, sym: U32) -> Maybe<&2, CtorInfo>:
  CheckCtx{_, _, ctors, _, _} = ctx
  ct_get(CtorInfo, ctors, sym)
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
def b5k_chk_env_lookup(env: List<&2, VarBind>, +sym: U32) -> LookupRes:
  match env:
    case Nil{}: LNotFound{}
    case Con{VarBind{s, d, +t}, rest}:
      Bool.pick(LookupRes, U32.is_eq(s, sym), Bool.pick(LookupRes, d, LFoundDup{t}, LFoundLin{t}), b5k_chk_env_lookup(rest, sym))
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
    case Con{VarBind{s, _, _}, t}: Bool.or(U32.is_eq(s, sym), b5k_chk_binds_mem(t, sym))
def b5k_chk_uses_strip(+bs: List<&2, VarBind>, us: List<&2, U32>) -> List<&2, U32>:
  match us:
    case Nil{}: Nil{}
    case Con{+h, t}:
      +rest = b5k_chk_uses_strip(bs, t)
      Bool.pick(List<&2, U32>, b5k_chk_binds_mem(bs, h), rest, Con{h, rest})
def b5k_chk_params_binds(+ctx: CheckCtx, +all_dup: Bool, ps: List<&2, Param>) -> List<&2, VarBind>:
  CheckCtx{syms, types, _, _, _} = ctx
  match ps:
    case Nil{}: Nil{}
    case Con{Param{sym, typ, erased, dup}, rest}:
      Con{VarBind{sym, Bool.or(all_dup, Bool.or(erased, dup)), b5k_chk_head_opt(syms, types, typ)}, b5k_chk_params_binds(ctx, all_dup, rest)}
# Pattern Checking & Binding Extraction (with Parametric Ctor Field Propagation)
def b5k_chk_ctor_err(fn_name: String) -> String: "check: " ++ fn_name ++ ": constructor does not belong to goal or field count differs"
def b5k_chk_ctor_ok(info: Maybe<&2, CtorInfo>, nargs: U32, goal: ChkTy) -> Bool:
  match info goal:
    case None{} _: False{}
    case Some{CtorInfo{_, arity, _, _}} TAny{}: U32.is_eq(nargs, arity)
    case Some{CtorInfo{tname, arity, _, _}} TCon{g, _}: Bool.and(U32.is_eq(nargs, arity), String.eq(tname, g))
def b5k_chk_ctor_fdups(info: Maybe<&2, CtorInfo>) -> List<&2, Bool>:
  match info:
    case None{}: Nil{}
    case Some{CtorInfo{_, _, fdups, _}}: fdups
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
    case Some{CtorInfo{tname, arity, _, Nil{}}}: b5k_chk_base_fgoals(tname, arity, goal)
    case Some{CtorInfo{_, _, _, ftys}}: ftys
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
    case LFoundDup{_}: True{}
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
      Bool.pick(List<&2, VarBind>, U32.is_zero(s), rest, Con{VarBind{U32.sub(s, 1), False{}, TAny{}}, rest})
    case Con{_, pt} Con{_, st}: b5k_chk_wild_strip(pt, st)
    case _ _: Nil{}
def b5k_chk_pats(fuel: Nat, +ctx: CheckCtx, +fn_name: String, ps: List<&2, PatItem>, acc: List<&2, VarBind>) -> PatRes:
  match fuel ps:
    case 0n _: PatOk{acc}
    case _ Nil{}: PatOk{acc}
    case 1n+f Con{PatItem{PVar{sym, dup}, inh, ty}, rest}:
      b5k_chk_pats(f, ctx, fn_name, rest, Con{VarBind{sym, Bool.or(dup, inh), ty}, acc})
    case 1n+f Con{PatItem{PCtr{sym, +fields}, inh, sty}, rest}:
      +info = b5k_chk_lookup_ctor(ctx, sym)
      ok = b5k_chk_ctor_ok(info, b5k_list_len(Pat, fields), TAny{})
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
  CheckCtx{syms, types, _, _, _} = ctx
  b5k_chk_head_expr(syms, types, e)
def b5k_chk_goal_opt(+ctx: CheckCtx, opt: Maybe<&2, Expr>) -> ChkTy:
  CheckCtx{syms, types, _, _, _} = ctx
  b5k_chk_head_opt(syms, types, opt)
def b5k_chk_call_err_k(bad: Bool, ctx: CheckCtx, fn_name: String, sym: U32) -> String:
  match bad:
    case True{}: "check: " ++ fn_name ++ ": call arity mismatch for " ++ b5k_chk_sym_name(ctx, sym)
    case False{}: ""
def b5k_chk_call_def(info: Maybe<&2, DefInfo>, ctx: CheckCtx, fn_name: String, sym: U32, +nargs: U32) -> String:
  match info:
    case None{}: ""
    case Some{DefInfo{arity, total_arity, ret_fn, _, _, _, _, _}}:
      b5k_chk_call_err_k(Bool.or(Bool.and(U32.is_gt(nargs, total_arity), Bool.not(ret_fn)), Bool.and(U32.is_zero(nargs), Bool.not(U32.is_zero(arity)))), ctx, fn_name, sym)
def b5k_chk_call_lookup(lr: LookupRes, +ctx: CheckCtx, fn_name: String, +sym: U32, nargs: U32) -> String:
  match lr ctx:
    case LNotFound{} CheckCtx{_, _, _, defs, _}: b5k_chk_call_def(ct_get(DefInfo, defs, sym), ctx, fn_name, sym, nargs)
    case _ _: ""
def b5k_chk_call_arity(+ctx: CheckCtx, fn_name: String, env: List<&2, VarBind>, fun: Expr, nargs: U32) -> String:
  match fun:
    case EVar{+sym}: b5k_chk_call_lookup(b5k_chk_env_lookup(env, sym), ctx, fn_name, sym, nargs)
    case ERef{+sym}: b5k_chk_call_lookup(b5k_chk_env_lookup(env, sym), ctx, fn_name, sym, nargs)
    case _: ""
def b5k_chk_def_sig(info: Maybe<&2, DefInfo>, syms: SymTab, sym: U32, +nargs: U32) -> CallSig:
  match info:
    case None{}: b5k_chk_builtin_sig(symtab_name(syms, sym), nargs)
    case Some{DefInfo{arity, total_arity, _, _, ptys, ltys, pers, +rty}}:
      Bool.pick(CallSig, U32.is_eq(nargs, total_arity), CallSig{ptys, pers, rty},
      Bool.pick(CallSig, U32.is_eq(nargs, arity), CallSig{ltys, Nil{}, rty}, b5k_chk_sig_none()))
def b5k_chk_call_sig_lookup(lr: LookupRes, ctx: CheckCtx, +sym: U32, nargs: U32) -> CallSig:
  match lr ctx:
    case LNotFound{} CheckCtx{syms, _, _, defs, _}: b5k_chk_def_sig(ct_get(DefInfo, defs, sym), syms, sym, nargs)
    case _ _: b5k_chk_sig_none()
def b5k_chk_call_sig(+ctx: CheckCtx, env: List<&2, VarBind>, fun: Expr, nargs: U32) -> CallSig:
  match fun:
    case EVar{+sym}: b5k_chk_call_sig_lookup(b5k_chk_env_lookup(env, sym), ctx, sym, nargs)
    case ERef{+sym}: b5k_chk_call_sig_lookup(b5k_chk_env_lookup(env, sym), ctx, sym, nargs)
    case _: b5k_chk_sig_none()
def b5k_chk_lr_typ(lr: LookupRes) -> ChkTy:
  match lr:
    case LFoundDup{t}: t
    case LFoundLin{t}: t
    case LNotFound{}: TAny{}
def b5k_chk_ctor_tname(info: Maybe<&2, CtorInfo>) -> ChkTy:
  match info:
    case None{}: TAny{}
    case Some{CtorInfo{tname, _, _, _}}: b5k_chk_t0(tname)
def b5k_chk_sig_args(cs: CallSig) -> List<&2, ChkTy>:
  CallSig{atys, _, _} = cs
  atys
def b5k_chk_sig_ers(cs: CallSig) -> List<&2, Bool>:
  CallSig{_, aers, _} = cs
  aers
def b5k_chk_sig_ret(cs: CallSig) -> ChkTy:
  CallSig{_, _, rty} = cs
  rty
def b5k_chk_ann_cmp_ty(e: Expr, def_ty: ChkTy) -> ChkTy:
  match e:
    case EOp{+op, _, _}:
      Bool.pick(ChkTy, U32.is_ge(op, 22), b5k_chk_t0("Bool"),
      Bool.pick(ChkTy, U32.is_ge(op, 20), TAny{}, def_ty))
    case _: def_ty
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
    case EApp{fun, args}: b5k_chk_sig_ret(b5k_chk_call_sig(ctx, env, fun, b5k_list_len(Expr, args)))
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
def b5k_chk_var_lookup(lr: LookupRes, +ctx: CheckCtx, +fn_name: String, goal: ChkTy, +sym: U32, is_ref: Bool) -> ExprRes:
  match lr:
    case LFoundDup{vty}: b5k_chk_expect(fn_name, vty, goal, ExprOk{Nil{}})
    case LFoundLin{vty}: b5k_chk_expect(fn_name, vty, goal, ExprOk{Con{sym, Nil{}}})
    case LNotFound{}: b5k_chk_var_gk(b5k_chk_is_known_global(ctx, sym), is_ref, ctx, fn_name, sym)
def b5k_chk_var(+ctx: CheckCtx, fn_name: String, env: List<&2, VarBind>, goal: ChkTy, +sym: U32, is_ref: Bool) -> ExprRes:
  b5k_chk_var_lookup(b5k_chk_env_lookup(env, sym), ctx, fn_name, goal, sym, is_ref)
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
    case Some{CtorInfo{tn, _, _, _}}: String.eq(tn, g)
    case None{}: False{}
def b5k_chk_u32_ctor_k(ms: Maybe<&2, U32>, ctors: RaVec<Maybe<&2, CtorInfo>>, g: String) -> Bool:
  match ms:
    case None{}: False{}
    case Some{s}: b5k_chk_ctor_is_ty(ct_get(CtorInfo, ctors, s), g)
def b5k_chk_u32_ctor_is(ctx: CheckCtx, g: String) -> Bool:
  CheckCtx{syms, _, ctors, _, _} = ctx
  b5k_chk_u32_ctor_k(symtab_lookup(syms, "U32"), ctors, g)
def b5k_chk_lit_k(ok: Bool, fn_name: String, got: String) -> ExprRes:
  match ok:
    case True{}: ExprOk{Nil{}}
    case False{}: ExprErr{"check: " ++ fn_name ++ ": literal type mismatch (" ++ got ++ ")"}
def b5k_chk_lit(ctx: CheckCtx, goal: ChkTy, fn_name: String, +got: String, +is_num: Bool) -> ExprRes:
  match goal:
    case TAny{}: ExprOk{Nil{}}
    case TCon{+g, _}: b5k_chk_lit_k(Bool.or(b5k_str_eq(g, got), Bool.and(is_num, Bool.or(b5k_str_eq(g, "Nat"), b5k_chk_u32_ctor_is(ctx, g)))), fn_name, got)
def b5k_chk_pair_goal_ok(goal: ChkTy) -> Bool:
  match goal:
    case TAny{}: True{}
    case TCon{+g, _}: Bool.or(String.eq(g, "Sigma"), String.eq(g, "Pair"))
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
    case TAny{}: TAny{}
def b5k_chk_refl_bad_eq(lhs: Expr, rhs: Expr) -> Bool:
  match lhs rhs:
    case ENum{a} ENum{b}: U32.is_ne(a, b)
    case EFlt{a} EFlt{b}: U32.is_ne(a, b)
    case EChr{a} EChr{b}: U32.is_ne(a, b)
    case EStr{a} EStr{b}: Bool.not(String.eq(a, b))
    case ECtr{a, Nil{}} ECtr{b, Nil{}}: U32.is_ne(a, b)
    case _ _: False{}
def b5k_chk_refl_bad_op(e: Expr) -> Bool:
  match e:
    case EOp{op, a, b}: Bool.pick(Bool, U32.is_eq(op, 20), b5k_chk_refl_bad_eq(a, b), False{})
    case _: False{}
def b5k_chk_refl_bad_expr(e: Expr) -> Bool:
  match e:
    case EAnn{v, _}: b5k_chk_refl_bad_op(v)
    case EEq{a, b}: b5k_chk_refl_bad_eq(a, b)
    case _: False{}
def b5k_chk_refl_bad(mret: Maybe<&2, Expr>) -> Bool:
  match mret:
    case Some{e}: b5k_chk_refl_bad_expr(e)
    case None{}: False{}
def b5k_chk_is_cmp_op(e: Expr) -> Bool:
  match e:
    case EOp{op, _, _}: U32.is_ge(op, 20)
    case _: False{}
def b5k_chk_is_refl(e: Expr) -> Bool:
  match e:
    case ERefl{}: True{}
    case _: False{}
def b5k_chk_expr_is_erased(+syms: SymTab, e: Expr) -> Bool:
  match e:
    case EVar{sym}: b5k_chk_is_universe(symtab_name(syms, sym))
    case EApp{EVar{sym}, _}: b5k_chk_is_universe(symtab_name(syms, sym))
    case EAnn{v, _}: b5k_chk_is_cmp_op(v)
    case EEq{_, _}: True{}
    case EAll{_, body}: b5k_chk_expr_is_erased(syms, body)
    case _: False{}
def b5k_chk_ret_is_erased(syms: SymTab, opt: Maybe<&2, Expr>) -> Bool:
  match opt:
    case Some{e}: b5k_chk_expr_is_erased(syms, e)
    case None{}: False{}
def b5k_chk_work(+fuel: Nat, +ctx: CheckCtx, +fn_name: String, w: ChkWork) -> ExprRes:
  match fuel w:
    case 0n _: ExprOk{Nil{}}
    case 1n+f WArgs{_, _, _, Nil{}}: ExprOk{Nil{}}
    case 1n+f WArgs{+env, +gs, +ers, Con{h, t}}:
      r1 = b5k_chk_erased_res(b5k_chk_head_b(ers, False{}), b5k_chk_work(f, ctx, fn_name, WExpr{env, b5k_chk_head_t(gs), h}))
      b5k_chk_merge(False{}, fn_name, r1, b5k_chk_work(f, ctx, fn_name, WArgs{env, b5k_chk_tail_t(gs), b5k_chk_tail_b(ers), t}))
    case 1n+f WCases{_, _, _, _, _, Nil{}}: ExprOk{Nil{}}
    case 1n+f WCases{+env, +goal, +sdups, +stys, +ssyms, Con{Case{+pats, body}, rest}}:
      pr = b5k_chk_pats(U32.to_nat(256), ctx, fn_name, b5k_chk_zip_pats(pats, sdups, stys, False{}), Nil{})
      ws = b5k_chk_wild_strip(pats, ssyms)
      b5k_chk_merge(True{}, fn_name, b5k_chk_work(f, ctx, fn_name, WCasePat{env, goal, pr, ws, body}), b5k_chk_work(f, ctx, fn_name, WCases{env, goal, sdups, stys, ssyms, rest}))
    case 1n+f WCasePat{_, _, PatErr{err}, _, _}: ExprErr{err}
    case 1n+f WCasePat{env, goal, PatOk{+bs}, ws, body}:
      b5k_chk_strip_res(b5k_list_app(VarBind, bs, ws), b5k_chk_work(f, ctx, fn_name, WExpr{b5k_list_app(VarBind, bs, env), goal, body}))
    case 1n+f WStmtPat{_, _, PatErr{err}, _, _}: ExprErr{err}
    case 1n+f WStmtPat{+env, goal, PatOk{+bs}, val, rest}:
      r1 = b5k_chk_work(f, ctx, fn_name, WExpr{env, TAny{}, val})
      r2 = b5k_chk_strip_res(bs, b5k_chk_work(f, ctx, fn_name, WStmts{b5k_list_app(VarBind, bs, env), goal, rest}))
      b5k_chk_merge(False{}, fn_name, r1, r2)
    case 1n+f WStmts{_, _, Nil{}}: ExprOk{Nil{}}
    case 1n+f WStmts{env, goal, Con{StBind{pat, val}, rest}}:
      b5k_chk_work(f, ctx, fn_name, WStmtPat{env, goal, b5k_chk_pats(U32.to_nat(256), ctx, fn_name, [PatItem{pat, False{}, TAny{}}], Nil{}), val, rest})
    case 1n+f WStmts{+env, goal, Con{StLet{pat, +val}, rest}}:
      inh = b5k_chk_expr_is_dup(env, val)
      vty = b5k_chk_infer_head(ctx, env, val)
      b5k_chk_work(f, ctx, fn_name, WStmtPat{env, goal, b5k_chk_pats(U32.to_nat(256), ctx, fn_name, [PatItem{pat, inh, vty}], Nil{}), val, rest})
    case 1n+f WStmts{env, goal, Con{StExpr{val}, Nil{}}}: b5k_chk_work(f, ctx, fn_name, WExpr{env, goal, val})
    case 1n+f WStmts{+env, goal, Con{StExpr{val}, rest}}: b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, TAny{}, val}), b5k_chk_work(f, ctx, fn_name, WStmts{env, goal, rest}))
    case 1n+f WStmts{env, goal, Con{StRet{val}, Nil{}}}: b5k_chk_work(f, ctx, fn_name, WExpr{env, b5k_chk_monad_inner(goal), val})
    case 1n+f WStmts{+env, goal, Con{StRet{val}, rest}}: b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, TAny{}, val}), b5k_chk_work(f, ctx, fn_name, WStmts{env, goal, rest}))
    case 1n+f WExpr{_, goal, ENum{_}}: b5k_chk_lit(ctx, goal, fn_name, "U32", True{})
    case 1n+f WExpr{_, goal, EFlt{_}}: b5k_chk_lit(ctx, goal, fn_name, "F32", False{})
    case 1n+f WExpr{_, goal, EChr{_}}: b5k_chk_lit(ctx, goal, fn_name, "Char", False{})
    case 1n+f WExpr{_, goal, EStr{_}}: b5k_chk_lit(ctx, goal, fn_name, "String", False{})
    case 1n+f WExpr{_, goal, EUnit{}}: b5k_chk_lit(ctx, goal, fn_name, "Unit", False{})
    case 1n+f WExpr{env, goal, EVar{sym}}: b5k_chk_var(ctx, fn_name, env, goal, sym, False{})
    case 1n+f WExpr{env, goal, ERef{sym}}: b5k_chk_var(ctx, fn_name, env, goal, sym, True{})
    case 1n+f WExpr{+env, goal, EApp{+fun, +args}}:
      +nargs = b5k_list_len(Expr, args)
      +aerr = b5k_chk_call_arity(ctx, fn_name, env, fun, nargs)
      +cs = b5k_chk_call_sig(ctx, env, fun, nargs)
      res = b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, TAny{}, fun}), b5k_chk_work(f, ctx, fn_name, WArgs{env, b5k_chk_sig_args(cs), b5k_chk_sig_ers(cs), args}))
      res2 = b5k_chk_expect(fn_name, b5k_chk_sig_ret(cs), goal, res)
      Bool.pick(ExprRes, String.is_empty(aerr), res2, ExprErr{aerr})
    case 1n+f WExpr{env, _, ELam{params, body}}:
      +bs = b5k_chk_params_binds(ctx, False{}, params)
      b5k_chk_strip_res(bs, b5k_chk_work(f, ctx, fn_name, WExpr{b5k_list_app(VarBind, bs, env), TAny{}, body}))
    case 1n+f WExpr{+env, +goal, ELet{pat, +val, body}}:
      inh = b5k_chk_expr_is_dup(env, val)
      vty = b5k_chk_infer_head(ctx, env, val)
      g2 = Bool.pick(ChkTy, b5k_chk_is_refl(val), TAny{}, goal)
      b5k_chk_work(f, ctx, fn_name, WStmtPat{env, g2, b5k_chk_pats(U32.to_nat(256), ctx, fn_name, [PatItem{pat, inh, vty}], Nil{}), val, [StExpr{body}]})
    case 1n+f WExpr{+env, goal, EMat{+scruts, cases}}:
      sdups = b5k_chk_scruts_dups(env, scruts)
      stys = b5k_chk_scruts_tys(ctx, env, scruts)
      ssyms = b5k_chk_scruts_syms(scruts)
      b5k_chk_merge(False{}, fn_name, b5k_chk_work(f, ctx, fn_name, WArgs{env, Nil{}, Nil{}, scruts}), b5k_chk_work(f, ctx, fn_name, WCases{env, goal, sdups, stys, ssyms, cases}))
    case 1n+f WExpr{env, +goal, ECtr{sym, +fields}}:
      +info = b5k_chk_lookup_ctor(ctx, sym)
      ok = b5k_chk_ctor_ok(info, b5k_list_len(Expr, fields), goal)
      Bool.pick(ExprRes, ok, b5k_chk_work(f, ctx, fn_name, WArgs{env, b5k_chk_ctor_fgoals(info, goal), Nil{}, fields}), ExprErr{b5k_chk_ctor_err(fn_name)})
    case 1n+f WExpr{env, goal, EAnn{+val, +typ}}:
      +is_er = b5k_chk_is_refl(typ)
      +is_cmp = b5k_chk_is_cmp_op(val)
      +aty = b5k_chk_ann_cmp_ty(val, b5k_chk_goal_expr(ctx, typ))
      res = b5k_chk_erased_res(is_er, b5k_chk_work(f, ctx, fn_name, WExpr{env, Bool.pick(ChkTy, Bool.or(is_cmp, is_er), TAny{}, aty), val}))
      b5k_chk_expect(fn_name, aty, goal, res)
    case 1n+f WExpr{env, _, EEq{a, b}}: b5k_chk_work(f, ctx, fn_name, WArgs{env, Nil{}, Nil{}, [a, b]})
    case 1n+f WExpr{env, goal, EOp{op, a, b}}:
      oty = Bool.pick(ChkTy, U32.is_ge(op, 20), b5k_chk_t0("Bool"), TAny{})
      b5k_chk_expect(fn_name, oty, goal, b5k_chk_work(f, ctx, fn_name, WArgs{env, Nil{}, Nil{}, [a, b]}))
    case 1n+f WExpr{env, _, EUnOp{_, val}}: b5k_chk_work(f, ctx, fn_name, WExpr{env, TAny{}, val})
    case 1n+f WExpr{env, goal, EArrNew{elems}}: b5k_chk_expect(fn_name, b5k_chk_t0("Array"), goal, b5k_chk_work(f, ctx, fn_name, WArgs{env, Nil{}, Nil{}, elems}))
    case 1n+f WExpr{env, _, EArrGet{arr, idx}}: b5k_chk_work(f, ctx, fn_name, WArgs{env, Nil{}, Nil{}, [arr, idx]})
    case 1n+f WExpr{env, _, EArrSet{arr, idx, val}}: b5k_chk_work(f, ctx, fn_name, WArgs{env, Nil{}, Nil{}, [arr, idx, val]})
    case 1n+f WExpr{+env, +goal, EIf{cond, then_e, else_e}}:
      rc = b5k_chk_work(f, ctx, fn_name, WExpr{env, b5k_chk_t0("Bool"), cond})
      rb = b5k_chk_merge(True{}, fn_name, b5k_chk_work(f, ctx, fn_name, WExpr{env, goal, then_e}), b5k_chk_work(f, ctx, fn_name, WExpr{env, goal, else_e}))
      b5k_chk_merge(False{}, fn_name, rc, rb)
    case 1n+f WExpr{env, goal, EDo{stmts}}: b5k_chk_work(f, ctx, fn_name, WStmts{env, goal, stmts})
    case 1n+f WExpr{env, +goal, EPair{a, b}}:
      res = b5k_chk_work(f, ctx, fn_name, WArgs{env, b5k_chk_pair_goals(goal), Nil{}, [a, b]})
      Bool.pick(ExprRes, b5k_chk_pair_goal_ok(goal), res, ExprErr{b5k_chk_head_err(fn_name, b5k_chk_t0("Sigma"), goal)})
    case 1n+f WExpr{env, +goal, EList{+elems}}:
      b5k_chk_expect(fn_name, b5k_chk_t0("List"), goal, b5k_chk_work(f, ctx, fn_name, WArgs{env, b5k_chk_list_elem_goals(elems, goal), Nil{}, elems}))
    case 1n+_ WExpr{_, _, _}: ExprOk{Nil{}}
# Top-Level Book Entrypoint
def b5k_chk_expr_err(r: ExprRes) -> String:
  match r:
    case ExprOk{_}: ""
    case ExprErr{err}: err
def b5k_chk_def(+ctx: CheckCtx, d: Def) -> String:
  CheckCtx{syms, _, _, _, laws} = ctx
  Def{+sym, params, ret, body, is_import, _} = d
  match is_import:
    case True{}:
      +fn_name = b5k_chk_sym_name(ctx, sym)
      Bool.pick(String, b5k_chk_is_runtime_provider(fn_name), "", "compile: foreign provider unavailable in fixed runtime: " ++ fn_name)
    case False{}:
      +fn_name = b5k_chk_sym_name(ctx, sym)
      +ld = ct_get(LawDef, laws, sym)
      +mret = b5k_chk_apply_law_ret(ret, ld)
      env = b5k_chk_params_binds(ctx, b5k_chk_ret_is_erased(syms, mret), b5k_chk_apply_law_params(params, ld))
      goal = b5k_chk_goal_opt(ctx, mret)
      Bool.pick(String, b5k_chk_refl_bad(mret), "check: " ++ fn_name ++ ": reflexivity mismatch",
        b5k_chk_expr_err(b5k_chk_work(U32.to_nat(4096), ctx, fn_name, WExpr{env, goal, body})))
def b5k_chk_defs(+ctx: CheckCtx, ds: List<&2, Def>) -> String:
  match ds:
    case Nil{}: ""
    case Con{h, t}:
      +err = b5k_chk_def(ctx, h)
      Bool.pick(String, String.is_empty(err), b5k_chk_defs(ctx, t), err)
# Data-Kind Field Discipline Check (rejects non-Data live fields in `is Data` types)
def b5k_chk_is_nondata_kind(+syms: SymTab, e: Expr) -> Bool:
  match e:
    case EVar{sym}:
      +nm = symtab_name(syms, sym)
      Bool.or(String.eq(nm, "Type"), String.eq(nm, "Kind"))
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
def b5k_chk_data_fields(+tname: String, +nd: List<&2, U32>, fs: List<&2, Param>) -> String:
  match fs:
    case Nil{}: ""
    case Con{Param{_, mty, erased, _}, rest}:
      bad = Bool.and(Bool.not(erased), b5k_chk_field_nondata_opt(nd, mty))
      Bool.pick(String, bad, "check: " ++ tname ++ ": non-Data field in Data type", b5k_chk_data_fields(tname, nd, rest))
def b5k_chk_data_ctors(+syms: SymTab, +tname: String, +nd: List<&2, U32>, cs: List<&2, CtorDef>) -> String:
  match cs:
    case Nil{}: ""
    case Con{CtorDef{_, _, +fs}, rest}:
      +nd2 = b5k_chk_nondata_syms(syms, fs, nd)
      +err = b5k_chk_data_fields(tname, nd2, fs)
      Bool.pick(String, String.is_empty(err), b5k_chk_data_ctors(syms, tname, nd, rest), err)
def b5k_chk_types(+syms: SymTab, ts: List<&2, TypeDef>) -> String:
  match ts:
    case Nil{}: ""
    case Con{TypeDef{tsym, tps, is_data, ctors}, rest}:
      +err = Bool.pick(String, is_data, b5k_chk_data_ctors(syms, symtab_name(syms, tsym), b5k_chk_nondata_syms(syms, tps, Nil{}), ctors), "")
      Bool.pick(String, String.is_empty(err), b5k_chk_types(syms, rest), err)
def b5k_check(+book: Book) -> CheckRes:
  Book{+types, +defs, laws, +syms} = book
  +terr = b5k_chk_types(syms, types)
  +err = Bool.pick(String, String.is_empty(terr), b5k_chk_defs(b5k_chk_build_ctx(types, defs, laws, syms), defs), terr)
  CheckRes{String.is_empty(err), err, book}
