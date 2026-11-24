# bend5k/lower.bend — Direct-First ANF/CFG Lowerer (Book -> IrProg)
# ==================================================================
# Single-IR lowering with zero CPS duplication:
#   - Dense ctor IDs (0..C-1) and function IDs (0..F-1)
#   - Escape & effect analysis (direct-only by default, incl. mutual recursion)
#   - U32.* intrinsic recognition -> IBin/ICmp
#   - Saturated self-recursion in tail position -> TTailCall
#   - Safe -O0 Perceus RC (IKeep for dup uses > 1, ISink for 0-use bindings)

type LowerRes is Data:
  LowerRes{ok: Bool, err: String, prog: IrProg}

# 16-Level U32 -> U32 Bit-Trie (0 = absent)
# -----------------------------------------
type U32Map is Data:
  UM0{}
  UML{val: U32}
  UMN{lo: U32Map, hi: U32Map}

def um_set_go(depth: Nat, +k: U32, v: U32, m: U32Map, is_lo: Bool) -> U32Map:
  match depth m is_lo:
    case 0n _ _: UML{v}
    case 1n+p UMN{lo, hi} True{}:
      +nxt = U32.shr(k)
      UMN{um_set_go(p, nxt, v, lo, U32.is_zero(U32.and(nxt, 1))), hi}
    case 1n+p UMN{lo, hi} False{}:
      +nxt = U32.shr(k)
      UMN{lo, um_set_go(p, nxt, v, hi, U32.is_zero(U32.and(nxt, 1)))}
    case 1n+p _ True{}:
      +nxt = U32.shr(k)
      UMN{um_set_go(p, nxt, v, UM0{}, U32.is_zero(U32.and(nxt, 1))), UM0{}}
    case 1n+p _ False{}:
      +nxt = U32.shr(k)
      UMN{UM0{}, um_set_go(p, nxt, v, UM0{}, U32.is_zero(U32.and(nxt, 1)))}

def um_set(m: U32Map, +k: U32, v: U32) -> U32Map:
  um_set_go(16n, k, v, m, U32.is_zero(U32.and(k, 1)))

def um_get_go(depth: Nat, +k: U32, m: U32Map, is_lo: Bool) -> U32:
  match depth m is_lo:
    case _ UM0{} _: 0
    case _ UML{v} _: v
    case 0n UMN{_, _} _: 0
    case 1n+p UMN{lo, hi} True{}:
      +nxt = U32.shr(k)
      um_get_go(p, nxt, lo, U32.is_zero(U32.and(nxt, 1)))
    case 1n+p UMN{lo, hi} False{}:
      +nxt = U32.shr(k)
      um_get_go(p, nxt, hi, U32.is_zero(U32.and(nxt, 1)))

def um_get(m: U32Map, +k: U32) -> U32:
  um_get_go(16n, k, m, U32.is_zero(U32.and(k, 1)))

# Lowering Environment & Pass 1 Tables
# ------------------------------------
type LowEnv is Data:
  LowEnv{
    syms: SymTab, ctor_by_sym: U32Map, fn_by_sym: U32Map, fn_arity: U32Map,
    esc_fns: U32Map, eff_fns: U32Map, main_fid: U32,
    cid_nil: U32, cid_con: U32, cid_snil: U32, cid_scon: U32, cid_pair: U32
  }

def env_ctors(e: LowEnv) -> U32Map:
  match e:
    case LowEnv{_, m, _, _, _, _, _, _, _, _, _, _}: m
def env_cid_nil(e: LowEnv) -> U32:
  match e:
    case LowEnv{_, _, _, _, _, _, _, c, _, _, _, _}: c
def env_cid_con(e: LowEnv) -> U32:
  match e:
    case LowEnv{_, _, _, _, _, _, _, _, c, _, _, _}: c
def env_cid_snil(e: LowEnv) -> U32:
  match e:
    case LowEnv{_, _, _, _, _, _, _, _, _, c, _, _}: c
def env_cid_scon(e: LowEnv) -> U32:
  match e:
    case LowEnv{_, _, _, _, _, _, _, _, _, _, c, _}: c
def env_cid_pair(e: LowEnv) -> U32:
  match e:
    case LowEnv{_, _, _, _, _, _, _, _, _, _, _, c}: c

def low_param_arity_go(ps: List<&2, Param>, acc: U32) -> U32:
  match ps:
    case Nil{}: acc
    case Con{Param{_, _, erased, _}, t}:
      match erased:
        case True{}: low_param_arity_go(t, acc)
        case False{}: low_param_arity_go(t, U32.add(acc, 1))

type CtorTabAcc is Data:
  CtorTabAcc{next_cid: U32, by_sym: U32Map, ctors_rev: List<&2, IrCtor>}

def low_add_ctors(+syms: SymTab, cs: List<&2, CtorDef>, acc: CtorTabAcc) -> CtorTabAcc:
  match cs:
    case Nil{}: acc
    case Con{CtorDef{+sym, _, fields}, t}:
      match acc:
        case CtorTabAcc{+cid, by_sym, rev}:
          low_add_ctors(syms, t, CtorTabAcc{U32.add(cid, 1), um_set(by_sym, sym, U32.add(cid, 1)), Con{IrCtor{cid, symtab_name(syms, sym), b5k_list_len(Param, fields), False{}}, rev}})

def low_add_types(+syms: SymTab, ts: List<&2, TypeDef>, acc: CtorTabAcc) -> CtorTabAcc:
  match ts:
    case Nil{}: acc
    case Con{TypeDef{_, _, _, cs}, t}: low_add_types(syms, t, low_add_ctors(syms, cs, acc))

def low_cid_of(by_sym: U32Map, m: Maybe<&2, U32>, fb: U32) -> U32:
  match m:
    case None{}: fb
    case Some{sym}:
      +v = um_get(by_sym, sym)
      Bool.pick(U32, U32.is_zero(v), fb, U32.sub(v, 1))

type FnTabAcc is Data:
  FnTabAcc{next_fid: U32, by_sym: U32Map, arity: U32Map, main_fid: U32}

def low_add_defs(+syms: SymTab, ds: List<&2, Def>, acc: FnTabAcc) -> FnTabAcc:
  match ds:
    case Nil{}: acc
    case Con{Def{+sym, params, _, _, _, _}, t}:
      match acc:
        case FnTabAcc{+fid, by_sym, arity, main_fid}:
          m2 = um_set(by_sym, sym, U32.add(fid, 1))
          a2 = um_set(arity, fid, U32.add(low_param_arity_go(params, 0), 1))
          mf2 = Bool.pick(U32, b5k_str_eq(symtab_name(syms, sym), "main"), fid, main_fid)
          low_add_defs(syms, t, FnTabAcc{U32.add(fid, 1), m2, a2, mf2})

# Pass 1c: Escape & Effect Analysis (single self-recursive def)
# -------------------------------------------------------------
type EscAcc is Data:
  EscAcc{esc: U32Map, eff: U32Map}
type ScanItem is Data:
  SIExpr{e: Expr}
  SIExprs{es: List<&2, Expr>}
  SICases{cs: List<&2, Case>}
  SIStmts{ss: List<&2, Stmt>}

def low_mark_esc_go(v: U32, z: Bool, acc: EscAcc) -> EscAcc:
  match z acc:
    case True{} a: a
    case False{} EscAcc{esc, eff}: EscAcc{um_set(esc, U32.sub(v, 1), 1), eff}
def low_mark_esc(fn_by_sym: U32Map, sym: U32, acc: EscAcc) -> EscAcc:
  +v = um_get(fn_by_sym, sym)
  low_mark_esc_go(v, U32.is_zero(v), acc)
def low_mark_eff_if(is_io: Bool, cur_fid: U32, acc: EscAcc) -> EscAcc:
  match is_io acc:
    case False{} a: a
    case True{} EscAcc{esc, eff}: EscAcc{esc, um_set(eff, cur_fid, 1)}
def low_scan_head_acc(fn_arity: U32Map, argc: U32, +fv: U32, fz: Bool, acc: EscAcc) -> EscAcc:
  match fz:
    case True{}: acc
    case False{}:
      +av = um_get(fn_arity, U32.sub(fv, 1))
      low_mark_esc_go(fv, Bool.and(U32.is_ne(av, 0), U32.is_eq(U32.sub(av, 1), argc)), acc)

def low_scan(fuel: Nat, +syms: SymTab, +fn_by_sym: U32Map, +fn_arity: U32Map, +cur_fid: U32, item: ScanItem, acc: EscAcc) -> EscAcc:
  match fuel item:
    case Zero{} _: acc
    case Succ{+p} SIExprs{Nil{}}: acc
    case Succ{+p} SIExprs{Con{h, t}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExprs{t}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{h}, acc))
    case Succ{+p} SICases{Nil{}}: acc
    case Succ{+p} SICases{Con{Case{_, body}, t}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SICases{t}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{body}, acc))
    case Succ{+p} SIStmts{Nil{}}: acc
    case Succ{+p} SIStmts{Con{StBind{_, v}, t}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIStmts{t}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{v}, low_mark_eff_if(True{}, cur_fid, acc)))
    case Succ{+p} SIStmts{Con{StLet{_, v}, t}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIStmts{t}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{v}, acc))
    case Succ{+p} SIStmts{Con{StExpr{v}, t}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIStmts{t}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{v}, acc))
    case Succ{+p} SIStmts{Con{StRet{v}, t}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIStmts{t}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{v}, acc))
    case Succ{p} SIExpr{ERef{+sym}}: low_mark_esc(fn_by_sym, sym, low_mark_eff_if(String.starts_with(symtab_name(syms, sym), "IO."), cur_fid, acc))
    case Succ{p} SIExpr{EApp{ERef{+sym}, +args}}:
      acc0 = low_mark_eff_if(String.starts_with(symtab_name(syms, sym), "IO."), cur_fid, acc)
      +fv = um_get(fn_by_sym, sym)
      low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExprs{args}, low_scan_head_acc(fn_arity, b5k_list_len(Expr, args), fv, U32.is_zero(fv), acc0))
    case Succ{p} SIExpr{EApp{EVar{+sym}, +args}}:
      acc0 = low_mark_eff_if(String.starts_with(symtab_name(syms, sym), "IO."), cur_fid, acc)
      +fv = um_get(fn_by_sym, sym)
      low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExprs{args}, low_scan_head_acc(fn_arity, b5k_list_len(Expr, args), fv, U32.is_zero(fv), acc0))
    case Succ{+p} SIExpr{EApp{other, args}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExprs{args}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{other}, acc))
    case Succ{p} SIExpr{ELam{_, body}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{body}, acc)
    case Succ{+p} SIExpr{ELet{_, val, body}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{body}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{val}, acc))
    case Succ{+p} SIExpr{EMat{scruts, cases}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SICases{cases}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExprs{scruts}, acc))
    case Succ{p} SIExpr{ECtr{_, fs}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExprs{fs}, acc)
    case Succ{p} SIExpr{EAnn{val, _}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{val}, acc)
    case Succ{p} SIExpr{EArrNew{es}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExprs{es}, acc)
    case Succ{+p} SIExpr{EArrGet{a, i}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{i}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{a}, acc))
    case Succ{+p} SIExpr{EArrSet{a, i, v}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{v}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{i}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{a}, acc)))
    case Succ{+p} SIExpr{EOp{_, a, b}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{b}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{a}, acc))
    case Succ{p} SIExpr{EUnOp{_, a}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{a}, acc)
    case Succ{+p} SIExpr{EIf{c, t, f}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{f}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{t}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{c}, acc)))
    case Succ{p} SIExpr{EDo{ss}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIStmts{ss}, acc)
    case Succ{+p} SIExpr{EPair{a, b}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{b}, low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExpr{a}, acc))
    case Succ{p} SIExpr{EList{es}}: low_scan(p, syms, fn_by_sym, fn_arity, cur_fid, SIExprs{es}, acc)
    case Succ{_} _: acc

def low_scan_defs(ds: List<&2, Def>, +syms: SymTab, +fn_by_sym: U32Map, +fn_arity: U32Map, +fid: U32, acc: EscAcc) -> EscAcc:
  match ds:
    case Nil{}: acc
    case Con{Def{_, _, _, body, _, _}, t}: low_scan_defs(t, syms, fn_by_sym, fn_arity, U32.add(fid, 1), low_scan(U32.to_nat(2048), syms, fn_by_sym, fn_arity, fid, SIExpr{body}, acc))

# Use-Count Scanner for Perceus RC (single self-recursive def)
# ------------------------------------------------------------
def pat_binds_all(fuel: Nat, +sym: U32, ps: List<&2, Pat>) -> Bool:
  match fuel ps:
    case Zero{} _: False{}
    case Succ{_} Nil{}: False{}
    case Succ{p} Con{PVar{s, _}, t}: Bool.or(U32.is_eq(sym, s), pat_binds_all(p, sym, t))
    case Succ{+p} Con{PCtr{_, fs}, t}: Bool.or(pat_binds_all(p, sym, fs), pat_binds_all(p, sym, t))
    case Succ{p} Con{PPair{a, b}, t}: pat_binds_all(p, sym, Con{a, Con{b, t}})
    case Succ{+p} Con{PList{es}, t}: Bool.or(pat_binds_all(p, sym, es), pat_binds_all(p, sym, t))
    case Succ{p} Con{_, t}: pat_binds_all(p, sym, t)

def params_bind(+sym: U32, ps: List<&2, Param>) -> Bool:
  match ps:
    case Nil{}: False{}
    case Con{Param{s, _, _, _}, t}: Bool.or(U32.is_eq(sym, s), params_bind(sym, t))

type UseItem is Data:
  UIExpr{e: Expr}
  UIExprs{es: List<&2, Expr>}
  UICases{cs: List<&2, Case>}
  UIStmts{ss: List<&2, Stmt>}

def count_uses_go(fuel: Nat, +sym: U32, item: UseItem) -> U32:
  match fuel item:
    case Zero{} _: 0
    case Succ{_} UIExprs{Nil{}}: 0
    case Succ{+p} UIExprs{Con{h, t}}: U32.add(count_uses_go(p, sym, UIExpr{h}), count_uses_go(p, sym, UIExprs{t}))
    case Succ{_} UICases{Nil{}}: 0
    case Succ{+p} UICases{Con{Case{ps, body}, t}}: U32.add(Bool.pick(U32, pat_binds_all(64n, sym, ps), 0, count_uses_go(p, sym, UIExpr{body})), count_uses_go(p, sym, UICases{t}))
    case Succ{_} UIStmts{Nil{}}: 0
    case Succ{+p} UIStmts{Con{StBind{pat, v}, t}}: U32.add(count_uses_go(p, sym, UIExpr{v}), Bool.pick(U32, pat_binds_all(64n, sym, Con{pat, Nil{}}), 0, count_uses_go(p, sym, UIStmts{t})))
    case Succ{+p} UIStmts{Con{StLet{pat, v}, t}}: U32.add(count_uses_go(p, sym, UIExpr{v}), Bool.pick(U32, pat_binds_all(64n, sym, Con{pat, Nil{}}), 0, count_uses_go(p, sym, UIStmts{t})))
    case Succ{+p} UIStmts{Con{StExpr{v}, t}}: U32.add(count_uses_go(p, sym, UIExpr{v}), count_uses_go(p, sym, UIStmts{t}))
    case Succ{+p} UIStmts{Con{StRet{v}, t}}: U32.add(count_uses_go(p, sym, UIExpr{v}), count_uses_go(p, sym, UIStmts{t}))
    case Succ{_} UIExpr{EVar{s}}: Bool.to_u32(U32.is_eq(sym, s))
    case Succ{+p} UIExpr{EApp{f, args}}: U32.add(count_uses_go(p, sym, UIExpr{f}), count_uses_go(p, sym, UIExprs{args}))
    case Succ{p} UIExpr{ELam{ps, body}}: Bool.pick(U32, params_bind(sym, ps), 0, count_uses_go(p, sym, UIExpr{body}))
    case Succ{+p} UIExpr{ELet{pat, v, body}}: U32.add(count_uses_go(p, sym, UIExpr{v}), Bool.pick(U32, pat_binds_all(64n, sym, Con{pat, Nil{}}), 0, count_uses_go(p, sym, UIExpr{body})))
    case Succ{+p} UIExpr{EMat{scruts, cs}}: U32.add(count_uses_go(p, sym, UIExprs{scruts}), count_uses_go(p, sym, UICases{cs}))
    case Succ{p} UIExpr{ECtr{_, fs}}: count_uses_go(p, sym, UIExprs{fs})
    case Succ{p} UIExpr{EAnn{v, _}}: count_uses_go(p, sym, UIExpr{v})
    case Succ{p} UIExpr{EArrNew{es}}: count_uses_go(p, sym, UIExprs{es})
    case Succ{+p} UIExpr{EArrGet{a, i}}: U32.add(count_uses_go(p, sym, UIExpr{a}), count_uses_go(p, sym, UIExpr{i}))
    case Succ{+p} UIExpr{EArrSet{a, i, v}}: U32.add(count_uses_go(p, sym, UIExpr{a}), U32.add(count_uses_go(p, sym, UIExpr{i}), count_uses_go(p, sym, UIExpr{v})))
    case Succ{+p} UIExpr{EOp{_, a, b}}: U32.add(count_uses_go(p, sym, UIExpr{a}), count_uses_go(p, sym, UIExpr{b}))
    case Succ{p} UIExpr{EUnOp{_, a}}: count_uses_go(p, sym, UIExpr{a})
    case Succ{+p} UIExpr{EIf{c, t, f}}: U32.add(count_uses_go(p, sym, UIExpr{c}), U32.add(count_uses_go(p, sym, UIExpr{t}), count_uses_go(p, sym, UIExpr{f})))
    case Succ{p} UIExpr{EDo{ss}}: count_uses_go(p, sym, UIStmts{ss})
    case Succ{+p} UIExpr{EPair{a, b}}: U32.add(count_uses_go(p, sym, UIExpr{a}), count_uses_go(p, sym, UIExpr{b}))
    case Succ{p} UIExpr{EList{es}}: count_uses_go(p, sym, UIExprs{es})
    case Succ{_} _: 0

# CFG Builder State (single-threaded, carries res/rlist/vmap)
# -----------------------------------------------------------
type CfgSt is Data:
  CfgSt{
    cur_fid: U32, next_reg: U32, next_blk: U32, cur_blk: U32,
    cur_ops: List<&2, IrOp>, blocks: List<&2, IrBlock>,
    sealed: Bool, res: U32, rlist: List<&2, U32>, vmap: U32Map, merged: Bool
  }

def cfg_new(fid: U32, nparams: U32) -> CfgSt:
  CfgSt{fid, nparams, 1, 0, Nil{}, Nil{}, False{}, 0, Nil{}, UM0{}, False{}}
def cfg_res(st: CfgSt) -> U32:
  match st:
    case CfgSt{_, _, _, _, _, _, _, r, _, _, _}: r
def cfg_rlist(st: CfgSt) -> List<&2, U32>:
  match st:
    case CfgSt{_, _, _, _, _, _, _, _, rl, _, _}: rl
def cfg_vmap(st: CfgSt) -> U32Map:
  match st:
    case CfgSt{_, _, _, _, _, _, _, _, _, vm, _}: vm
def cfg_sealed(st: CfgSt) -> Bool:
  match st:
    case CfgSt{_, _, _, _, _, _, s, _, _, _, _}: s
def cfg_merged(st: CfgSt) -> Bool:
  match st:
    case CfgSt{_, _, _, _, _, _, _, _, _, _, m}: m
def cfg_cur_fid(st: CfgSt) -> U32:
  match st:
    case CfgSt{fid, _, _, _, _, _, _, _, _, _, _}: fid
def cfg_set_res(st: CfgSt, r: U32) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, _, rl, vm, mg}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, mg}
def cfg_set_rlist(st: CfgSt, rl: List<&2, U32>) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, r, _, vm, mg}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, mg}
def cfg_set_vmap(st: CfgSt, vm: U32Map) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, _, mg}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, mg}
def cfg_set_merged(st: CfgSt, mg: Bool) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, _}: CfgSt{f, nr, nb, cb, ops, blks, s, r, rl, vm, mg}
def cfg_alloc_reg(st: CfgSt) -> CfgSt:
  match st:
    case CfgSt{f, +nr, nb, cb, ops, blks, s, _, rl, vm, mg}: CfgSt{f, U32.add(nr, 1), nb, cb, ops, blks, s, nr, rl, vm, mg}
def cfg_alloc_blk(st: CfgSt) -> CfgSt:
  match st:
    case CfgSt{f, nr, +nb, cb, ops, blks, s, _, rl, vm, mg}: CfgSt{f, nr, U32.add(nb, 1), cb, ops, blks, s, nb, rl, vm, mg}
def cfg_emit(st: CfgSt, op: IrOp) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, cb, ops, blks, sealed, r, rl, vm, mg}:
      match sealed:
        case True{}: CfgSt{f, nr, nb, cb, ops, blks, True{}, r, rl, vm, mg}
        case False{}: CfgSt{f, nr, nb, cb, Con{op, ops}, blks, False{}, r, rl, vm, mg}
def cfg_seal(st: CfgSt, term: IrTerm) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, +cb, ops, blks, sealed, r, rl, vm, mg}:
      match sealed:
        case True{}: CfgSt{f, nr, nb, cb, ops, blks, True{}, r, rl, vm, mg}
        case False{}: CfgSt{f, nr, nb, cb, Nil{}, Con{IrBlock{cb, b5k_list_rev(IrOp, ops), term}, blks}, True{}, r, rl, vm, mg}
def cfg_start(st: CfgSt, blk_id: U32) -> CfgSt:
  match st:
    case CfgSt{f, nr, nb, _, _, blks, _, r, rl, vm, mg}: CfgSt{f, nr, nb, blk_id, Nil{}, blks, False{}, r, rl, vm, mg}
def cfg_maybe_start(st: CfgSt, start_it: Bool, blk: U32) -> CfgSt:
  match start_it:
    case True{}: cfg_start(st, blk)
    case False{}: st
def cfg_fin_branch(st: CfgSt, sld: Bool, res_reg: U32, v: U32, merge_blk: U32, prev_mg: Bool) -> CfgSt:
  match sld:
    case True{}: cfg_set_merged(st, prev_mg)
    case False{}: cfg_set_merged(cfg_seal(cfg_emit(st, ICopy{res_reg, v}), TJmp{merge_blk}), True{})
def cfg_emit_keeps_go(k: Nat, st: CfgSt, +v: U32) -> CfgSt:
  match k:
    case 0n: st
    case 1n+p:
      +st1 = cfg_alloc_reg(st)
      cfg_emit_keeps_go(p, cfg_emit(st1, IKeep{cfg_res(st1), v}), v)
def cfg_apply_rc_go(st: CfgSt, +v: U32, z: Bool, do_keep: Bool, uses: U32) -> CfgSt:
  match z do_keep:
    case True{} _: cfg_emit(st, ISink{v})
    case False{} True{}: cfg_emit_keeps_go(U32.to_nat(U32.sub(uses, 1)), st, v)
    case False{} False{}: st
def cfg_apply_rc(st: CfgSt, v: U32, dup: Bool, +uses: U32) -> CfgSt:
  cfg_apply_rc_go(st, v, U32.is_zero(uses), Bool.and(dup, U32.is_gt(uses, 1)), uses)

# Intrinsic Recognition (U32.*)
# -----------------------------
def low_u32_intr(+s: String) -> U32:
  Bool.pick(U32, b5k_str_eq(s, "U32.add"), 1, Bool.pick(U32, b5k_str_eq(s, "U32.sub"), 2,
  Bool.pick(U32, b5k_str_eq(s, "U32.mul"), 3, Bool.pick(U32, b5k_str_eq(s, "U32.div"), 4,
  Bool.pick(U32, b5k_str_eq(s, "U32.mod"), 5, Bool.pick(U32, b5k_str_eq(s, "U32.and"), 6,
  Bool.pick(U32, b5k_str_eq(s, "U32.or"), 7, Bool.pick(U32, b5k_str_eq(s, "U32.xor"), 8,
  Bool.pick(U32, b5k_str_eq(s, "U32.shl"), 9, Bool.pick(U32, b5k_str_eq(s, "U32.shr"), 10,
  Bool.pick(U32, b5k_str_eq(s, "U32.is_eq"), 11, Bool.pick(U32, b5k_str_eq(s, "U32.is_ne"), 12,
  Bool.pick(U32, b5k_str_eq(s, "U32.is_lt"), 13, Bool.pick(U32, b5k_str_eq(s, "U32.is_le"), 14,
  Bool.pick(U32, b5k_str_eq(s, "U32.is_gt"), 15, Bool.pick(U32, b5k_str_eq(s, "U32.is_ge"), 16,
  Bool.pick(U32, b5k_str_eq(s, "U32.inc"), 20, Bool.pick(U32, b5k_str_eq(s, "U32.dec"), 21,
  Bool.pick(U32, b5k_str_eq(s, "U32.is_zero"), 22, 0)))))))))))))))))))

def low_emit_bin_or_cmp(st: CfgSt, is_cmp: Bool, +op: U32, +va: U32, +vb: U32) -> CfgSt:
  +st1 = cfg_alloc_reg(st)
  +dst = cfg_res(st1)
  cfg_emit(st1, Bool.pick(IrOp, is_cmp, ICmp{dst, op, va, vb}, IBin{dst, op, va, vb}))

def low_emit_u32_intr(st: CfgSt, +code: U32, vargs: List<&2, U32>) -> CfgSt:
  match vargs:
    case Con{va, Con{vb, Nil{}}}:
      +is_cmp = U32.is_gt(code, 10)
      low_emit_bin_or_cmp(st, is_cmp, Bool.pick(U32, is_cmp, U32.sub(code, 11), U32.sub(code, 1)), va, vb)
    case Con{va, Nil{}}:
      +st1 = cfg_alloc_reg(st)
      +c = cfg_res(st1)
      +is_z = U32.is_eq(code, 22)
      op = Bool.pick(U32, U32.is_eq(code, 20), B5K_OP_ADD(), Bool.pick(U32, U32.is_eq(code, 21), B5K_OP_SUB(), B5K_CMP_EQ()))
      low_emit_bin_or_cmp(cfg_emit(st1, IConst{c, Bool.pick(U32, is_z, 0, 1)}), is_z, op, va, c)
    case _:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), 0})

# Pattern Binding & Non-Recursive Lowering Helpers
# ------------------------------------------------
def low_alloc_regs_go(n: Nat, st: CfgSt, acc: List<&2, U32>) -> CfgSt:
  match n:
    case 0n: cfg_set_rlist(st, b5k_list_rev(U32, acc))
    case 1n+p:
      +st1 = cfg_alloc_reg(st)
      low_alloc_regs_go(p, st1, Con{cfg_res(st1), acc})

def low_bind_pats(fuel: Nat, st: CfgSt, ps: List<&2, Pat>, regs: List<&2, U32>, +body: Expr) -> CfgSt:
  match fuel ps regs:
    case Zero{} _ _: st
    case Succ{_} Nil{} _: st
    case Succ{_} _ Nil{}: st
    case Succ{p} Con{PWild{}, pt} Con{r, rt}: low_bind_pats(p, cfg_emit(st, ISink{r}), pt, rt, body)
    case Succ{p} Con{PVar{+sym, dup}, pt} Con{+r, rt}:
      +st1 = cfg_apply_rc(st, r, dup, count_uses_go(U32.to_nat(2048), sym, UIExpr{body}))
      low_bind_pats(p, cfg_set_vmap(st1, um_set(cfg_vmap(st1), sym, U32.add(r, 1))), pt, rt, body)
    case Succ{+p} Con{PCtr{_, +fs}, pt} Con{r, rt}:
      +st1 = low_alloc_regs_go(U32.to_nat(b5k_list_len(Pat, fs)), st, Nil{})
      +fregs = cfg_rlist(st1)
      low_bind_pats(p, low_bind_pats(p, cfg_emit(st1, ITake{fregs, r}), fs, fregs, body), pt, rt, body)
    case Succ{p} Con{PPair{a, b}, pt} Con{r, rt}:
      +st1 = cfg_alloc_reg(st)
      +ra = cfg_res(st1)
      +st2 = cfg_alloc_reg(st1)
      +rb = cfg_res(st2)
      low_bind_pats(p, cfg_emit(st2, ITake{Con{ra, Con{rb, Nil{}}}, r}), Con{a, Con{b, pt}}, Con{ra, Con{rb, rt}}, body)
    case Succ{p} Con{_, pt} Con{_, rt}: low_bind_pats(p, st, pt, rt, body)

def low_apply_chain(vargs: List<&2, U32>, st: CfgSt, vfn: U32) -> CfgSt:
  match vargs:
    case Nil{}: cfg_set_res(st, vfn)
    case Con{va, t}:
      +st1 = cfg_alloc_reg(st)
      +dst = cfg_res(st1)
      low_apply_chain(t, cfg_emit(st1, IApply{dst, vfn, va}), dst)
def low_list_chain(vargs: List<&2, U32>, st: CfgSt, +cid_con: U32, cid_nil: U32) -> CfgSt:
  match vargs:
    case Nil{}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, ICtor{cfg_res(st1), cid_nil, Nil{}})
    case Con{h, t}:
      +st1 = low_list_chain(t, st, cid_con, cid_nil)
      +st2 = cfg_alloc_reg(st1)
      cfg_emit(st2, ICtor{cfg_res(st2), cid_con, Con{h, Con{cfg_res(st1), Nil{}}}})
def low_str_chain(s: String, st: CfgSt, +cid_scon: U32, cid_snil: U32) -> CfgSt:
  match s:
    case SNil{}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, ICtor{cfg_res(st1), cid_snil, Nil{}})
    case SCon{c, t}:
      +st1 = low_str_chain(t, st, cid_scon, cid_snil)
      +st2 = cfg_alloc_reg(st1)
      +vc = cfg_res(st2)
      +st3 = cfg_alloc_reg(cfg_emit(st2, IConst{vc, Char.to_u32(c)}))
      cfg_emit(st3, ICtor{cfg_res(st3), cid_scon, Con{vc, Con{cfg_res(st1), Nil{}}}})
def low_ref_val(env: LowEnv, st: CfgSt, +sym: U32) -> CfgSt:
  match env:
    case LowEnv{_, ctor_by_sym, fn_by_sym, _, _, _, _, _, _, _, _, _}:
      +fv = um_get(fn_by_sym, sym)
      +cv = um_get(ctor_by_sym, sym)
      +st1 = cfg_alloc_reg(st)
      +dst = cfg_res(st1)
      cfg_emit(st1, Bool.pick(IrOp, U32.is_zero(fv), Bool.pick(IrOp, U32.is_zero(cv), IConst{dst, 0}, ICtor{dst, U32.sub(cv, 1), Nil{}}), ICallClosure{dst, U32.sub(fv, 1), Nil{}}))
def low_var_go(env: LowEnv, st: CfgSt, sym: U32, lv: U32, lz: Bool) -> CfgSt:
  match lz:
    case False{}: cfg_set_res(st, U32.sub(lv, 1))
    case True{}: low_ref_val(env, st, sym)
def low_app_direct(st: CfgSt, fid: U32, vargs: List<&2, U32>, is_sat: Bool, is_self_tail: Bool) -> CfgSt:
  match is_sat is_self_tail:
    case True{} True{}: cfg_set_res(cfg_seal(st, TTailCall{fid, vargs}), 0)
    case True{} False{}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, ICallDirect{cfg_res(st1), fid, vargs})
    case False{} _:
      +st1 = cfg_alloc_reg(st)
      +clo = cfg_res(st1)
      low_apply_chain(vargs, cfg_emit(st1, ICallClosure{clo, fid, Nil{}}), clo)
def low_app_global(+st: CfgSt, +vargs: List<&2, U32>, icode: U32, has_i: Bool, fv: U32, fz: Bool, fn_arity: U32Map, cv: U32, cz: Bool, is_tail: Bool) -> CfgSt:
  match has_i fz:
    case True{} _: low_emit_u32_intr(st, icode, vargs)
    case False{} False{}:
      +fid = U32.sub(fv, 1)
      +av = um_get(fn_arity, fid)
      is_sat = Bool.and(U32.is_ne(av, 0), U32.is_eq(U32.sub(av, 1), b5k_u32_list_len(vargs)))
      low_app_direct(st, fid, vargs, is_sat, Bool.and(is_tail, U32.is_eq(fid, cfg_cur_fid(st))))
    case False{} True{}:
      +st1 = cfg_alloc_reg(st)
      +dst = cfg_res(st1)
      cfg_emit(st1, Bool.pick(IrOp, cz, IConst{dst, 0}, ICtor{dst, U32.sub(cv, 1), vargs}))
def low_app_sym_go(env: LowEnv, st: CfgSt, vargs: List<&2, U32>, +sym: U32, lv: U32, lz: Bool, is_tail: Bool) -> CfgSt:
  match env lz:
    case _ False{}: low_apply_chain(vargs, st, U32.sub(lv, 1))
    case LowEnv{syms, ctor_by_sym, fn_by_sym, fn_arity, _, _, _, _, _, _, _, _} True{}:
      +icode = low_u32_intr(symtab_name(syms, sym))
      +fv = um_get(fn_by_sym, sym)
      +cv = um_get(ctor_by_sym, sym)
      low_app_global(st, vargs, icode, U32.is_ne(icode, 0), fv, U32.is_zero(fv), fn_arity, cv, U32.is_zero(cv), is_tail)

# Match Planning Helpers (non-recursive in low_go)
# ------------------------------------------------
type MatArmPlan is Data:
  MatArmPlan{blk_id: U32, pat: Pat, rest_pats: List<&2, Pat>, body: Expr}
type MatPrep is Data:
  MatPrep{st: CfgSt, is_ctor_sw: Bool, arms: List<&2, IrSwitchArm>, plans: List<&2, MatArmPlan>, def_blk: U32, def_plan: Maybe<&2, MatArmPlan>}
type PatTag is Data:
  PatTag{has_tag: Bool, is_ctor: Bool, tag: U32}

def low_pat_tag(env: LowEnv, p: Pat) -> PatTag:
  match p:
    case PCtr{sym, _}:
      +cv = um_get(env_ctors(env), sym)
      PatTag{True{}, True{}, Bool.pick(U32, U32.is_zero(cv), 0, U32.sub(cv, 1))}
    case PNum{v}: PatTag{True{}, False{}, v}
    case PChr{c}: PatTag{True{}, False{}, c}
    case _: PatTag{False{}, False{}, 0}
def low_prep_one(pt: PatTag, p0: Pat, rp: List<&2, Pat>, body: Expr, prep: MatPrep) -> MatPrep:
  match pt prep:
    case PatTag{True{}, is_c, tag} MatPrep{st, is_csw, arms, plans, def_blk, def_plan}:
      +st1 = cfg_alloc_blk(st)
      +bid = cfg_res(st1)
      MatPrep{st1, Bool.or(is_csw, is_c), Con{IrArm{tag, bid}, arms}, Con{MatArmPlan{bid, p0, rp, body}, plans}, def_blk, def_plan}
    case PatTag{False{}, _, _} MatPrep{st, is_csw, arms, plans, def_blk, def_plan}:
      match def_plan:
        case None{}:
          +st1 = cfg_alloc_blk(st)
          +bid = cfg_res(st1)
          MatPrep{st1, is_csw, arms, plans, bid, Some{MatArmPlan{bid, p0, rp, body}}}
        case Some{ex}: MatPrep{st, is_csw, arms, plans, def_blk, Some{ex}}
def low_prep_cases(+env: LowEnv, cs: List<&2, Case>, prep: MatPrep) -> MatPrep:
  match cs:
    case Nil{}: prep
    case Con{Case{ps, body}, t}:
      match ps:
        case Nil{}: low_prep_cases(env, t, prep)
        case Con{+p0, rp}: low_prep_cases(env, t, low_prep_one(low_pat_tag(env, p0), p0, rp, body, prep))
def low_seal_switch(st: CfgSt, is_csw: Bool, v0: U32, arms: List<&2, IrSwitchArm>, def_blk: U32) -> CfgSt:
  match is_csw:
    case True{}:
      +st1 = cfg_alloc_reg(st)
      +treg = cfg_res(st1)
      cfg_seal(cfg_emit(st1, ITag{treg, v0}), TSwitch{treg, arms, def_blk})
    case False{}: cfg_seal(st, TSwitch{v0, arms, def_blk})

# Single Self-Recursive Expression -> Flat CFG Lowerer
# ----------------------------------------------------
type LowTask is Data:
  LTExpr{e: Expr}
  LTExprs{es: List<&2, Expr>, acc: List<&2, U32>}
  LTDo{ss: List<&2, Stmt>}
  LTArms{base_vm: U32Map, plans: List<&2, MatArmPlan>, vscrut: U32, rest_scruts: List<&2, U32>, res_reg: U32, merge_blk: U32}
  LTMatch{base_vm: U32Map, prep: MatPrep, v0: U32, vrest: List<&2, U32>, res_reg: U32, merge_blk: U32}
  LTMatScrut{vscruts: List<&2, U32>, cases: List<&2, Case>}

def low_go(fuel: Nat, +env: LowEnv, st: CfgSt, task: LowTask, +is_tail: Bool) -> CfgSt:
  match fuel task:
    case Zero{} _: st
    case Succ{_} LTExprs{Nil{}, acc}: cfg_set_rlist(st, b5k_list_rev(U32, acc))
    case Succ{+p} LTExprs{Con{h, t}, acc}:
      +st1 = low_go(p, env, st, LTExpr{h}, False{})
      low_go(p, env, st1, LTExprs{t, Con{cfg_res(st1), acc}}, False{})
    case Succ{_} LTDo{Nil{}}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), 0})
    case Succ{p} LTDo{Con{StRet{v}, _}}: low_go(p, env, st, LTExpr{v}, is_tail)
    case Succ{p} LTDo{Con{StExpr{v}, Nil{}}}: low_go(p, env, st, LTExpr{v}, is_tail)
    case Succ{+p} LTDo{Con{StExpr{v}, t}}:
      +st1 = low_go(p, env, st, LTExpr{v}, False{})
      low_go(p, env, cfg_emit(st1, ISink{cfg_res(st1)}), LTDo{t}, is_tail)
    case Succ{+p} LTDo{Con{StLet{pat, v}, +t}}:
      +st1 = low_go(p, env, st, LTExpr{v}, False{})
      low_go(p, env, low_bind_pats(64n, st1, Con{pat, Nil{}}, Con{cfg_res(st1), Nil{}}, EDo{t}), LTDo{t}, is_tail)
    case Succ{+p} LTDo{Con{StBind{pat, v}, +t}}:
      +st1 = low_go(p, env, st, LTExpr{v}, False{})
      low_go(p, env, low_bind_pats(64n, st1, Con{pat, Nil{}}, Con{cfg_res(st1), Nil{}}, EDo{t}), LTDo{t}, is_tail)
    case Succ{_} LTArms{_, Nil{}, _, _, _, _}: st
    case Succ{+p} LTArms{+base_vm, Con{MatArmPlan{bid, p0, rp, +body}, t}, +vscrut, +rest_scruts, +res_reg, +merge_blk}:
      +st0 = st
      prev_mg = cfg_merged(st0)
      st1 = low_bind_pats(64n, cfg_set_vmap(cfg_start(st0, bid), base_vm), Con{p0, rp}, Con{vscrut, rest_scruts}, body)
      +st2 = low_go(p, env, st1, LTExpr{body}, is_tail)
      st3 = cfg_fin_branch(st2, cfg_sealed(st2), res_reg, cfg_res(st2), merge_blk, prev_mg)
      low_go(p, env, st3, LTArms{base_vm, t, vscrut, rest_scruts, res_reg, merge_blk}, is_tail)
    case Succ{+p} LTMatch{+base_vm, MatPrep{st4, is_csw, arms_rev, plans_rev, def_blk, def_plan}, +v0, +vrest, +res_reg, +merge_blk}:
      match def_plan:
        case Some{dpl}:
          st5 = cfg_set_merged(low_seal_switch(st4, is_csw, v0, b5k_list_rev(IrSwitchArm, arms_rev), def_blk), False{})
          st6 = low_go(p, env, st5, LTArms{base_vm, b5k_list_rev(MatArmPlan, plans_rev), v0, vrest, res_reg, merge_blk}, is_tail)
          +st7 = low_go(p, env, st6, LTArms{base_vm, Con{dpl, Nil{}}, v0, vrest, res_reg, merge_blk}, is_tail)
          cfg_set_res(cfg_set_vmap(cfg_maybe_start(st7, cfg_merged(st7), merge_blk), base_vm), res_reg)
        case None{}:
          +st5 = cfg_alloc_blk(st4)
          +fail_blk = cfg_res(st5)
          st6 = cfg_set_merged(low_seal_switch(st5, is_csw, v0, b5k_list_rev(IrSwitchArm, arms_rev), fail_blk), False{})
          st7 = low_go(p, env, st6, LTArms{base_vm, b5k_list_rev(MatArmPlan, plans_rev), v0, vrest, res_reg, merge_blk}, is_tail)
          +st8 = cfg_seal(cfg_start(st7, fail_blk), TFail{1})
          cfg_set_res(cfg_set_vmap(cfg_maybe_start(st8, cfg_merged(st8), merge_blk), base_vm), res_reg)
    case Succ{_} LTMatScrut{Nil{}, _}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), 0})
    case Succ{p} LTMatScrut{Con{v0, vrest}, cases}:
      +st0 = st
      +st1 = cfg_alloc_reg(st0)
      +st2 = cfg_alloc_blk(st1)
      prep = low_prep_cases(env, cases, MatPrep{st2, False{}, Nil{}, Nil{}, 0, None{}})
      low_go(p, env, st0, LTMatch{cfg_vmap(st0), prep, v0, vrest, cfg_res(st1), cfg_res(st2)}, is_tail)
    case Succ{_} LTExpr{ENum{v}}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), v})
    case Succ{_} LTExpr{EFlt{bits}}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IFlt{cfg_res(st1), bits})
    case Succ{_} LTExpr{EChr{c}}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), c})
    case Succ{_} LTExpr{EStr{s}}: low_str_chain(s, st, env_cid_scon(env), env_cid_snil(env))
    case Succ{_} LTExpr{EVar{+sym}}:
      +st0 = st
      +lv = um_get(cfg_vmap(st0), sym)
      low_var_go(env, st0, sym, lv, U32.is_zero(lv))
    case Succ{_} LTExpr{ERef{sym}}: low_ref_val(env, st, sym)
    case Succ{+p} LTExpr{EOp{+op, a, b}}:
      +st1 = low_go(p, env, st, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{b}, False{})
      +is_cmp = Bool.and(U32.is_ge(op, 14), U32.is_le(op, 19))
      low_emit_bin_or_cmp(st2, is_cmp, Bool.pick(U32, is_cmp, U32.sub(op, 14), op), cfg_res(st1), cfg_res(st2))
    case Succ{p} LTExpr{EUnOp{op, a}}:
      +st1 = low_go(p, env, st, LTExpr{a}, False{})
      +st2 = cfg_alloc_reg(st1)
      cfg_emit(st2, IUn{cfg_res(st2), op, cfg_res(st1)})
    case Succ{+p} LTExpr{ELet{pat, val, +body}}:
      +st0 = st
      base_vm = cfg_vmap(st0)
      +st1 = low_go(p, env, st0, LTExpr{val}, False{})
      st2 = low_bind_pats(64n, st1, Con{pat, Nil{}}, Con{cfg_res(st1), Nil{}}, body)
      cfg_set_vmap(low_go(p, env, st2, LTExpr{body}, is_tail), base_vm)
    case Succ{+p} LTExpr{EIf{cond, t, f}}:
      +st0 = st
      +base_vm = cfg_vmap(st0)
      +st1 = low_go(p, env, st0, LTExpr{cond}, False{})
      +st2 = cfg_alloc_blk(st1)
      +st3 = cfg_alloc_blk(st2)
      +st4 = cfg_alloc_blk(st3)
      +lbl_m = cfg_res(st4)
      +st5 = cfg_alloc_reg(st4)
      +res_reg = cfg_res(st5)
      +st6 = low_go(p, env, cfg_start(cfg_seal(st5, TBr{cfg_res(st1), cfg_res(st2), cfg_res(st3)}), cfg_res(st2)), LTExpr{t}, is_tail)
      +st7 = cfg_fin_branch(st6, cfg_sealed(st6), res_reg, cfg_res(st6), lbl_m, False{})
      +st8 = low_go(p, env, cfg_set_vmap(cfg_start(st7, cfg_res(st3)), base_vm), LTExpr{f}, is_tail)
      +st9 = cfg_fin_branch(st8, cfg_sealed(st8), res_reg, cfg_res(st8), lbl_m, cfg_merged(st7))
      cfg_set_res(cfg_set_vmap(cfg_maybe_start(st9, cfg_merged(st9), lbl_m), base_vm), res_reg)
    case Succ{p} LTExpr{ECtr{sym, fs}}:
      +st1 = low_go(p, env, st, LTExprs{fs, Nil{}}, False{})
      +cv = um_get(env_ctors(env), sym)
      +st2 = cfg_alloc_reg(st1)
      cfg_emit(st2, ICtor{cfg_res(st2), Bool.pick(U32, U32.is_zero(cv), 0, U32.sub(cv, 1)), cfg_rlist(st1)})
    case Succ{p} LTExpr{EApp{ERef{+sym}, args}}:
      +st0 = st
      +lv = um_get(cfg_vmap(st0), sym)
      +st1 = low_go(p, env, st0, LTExprs{args, Nil{}}, False{})
      low_app_sym_go(env, st1, cfg_rlist(st1), sym, lv, U32.is_zero(lv), is_tail)
    case Succ{p} LTExpr{EApp{EVar{+sym}, args}}:
      +st0 = st
      +lv = um_get(cfg_vmap(st0), sym)
      +st1 = low_go(p, env, st0, LTExprs{args, Nil{}}, False{})
      low_app_sym_go(env, st1, cfg_rlist(st1), sym, lv, U32.is_zero(lv), is_tail)
    case Succ{+p} LTExpr{EApp{other, args}}:
      +st1 = low_go(p, env, st, LTExpr{other}, False{})
      +st2 = low_go(p, env, st1, LTExprs{args, Nil{}}, False{})
      low_apply_chain(cfg_rlist(st2), st2, cfg_res(st1))
    case Succ{+p} LTExpr{EMat{scruts, cs}}:
      +st1 = low_go(p, env, st, LTExprs{scruts, Nil{}}, False{})
      low_go(p, env, st1, LTMatScrut{cfg_rlist(st1), cs}, is_tail)
    case Succ{p} LTExpr{EAnn{v, _}}: low_go(p, env, st, LTExpr{v}, is_tail)
    case Succ{p} LTExpr{EList{es}}:
      +st1 = low_go(p, env, st, LTExprs{es, Nil{}}, False{})
      low_list_chain(cfg_rlist(st1), st1, env_cid_con(env), env_cid_nil(env))
    case Succ{+p} LTExpr{EPair{a, b}}:
      +st1 = low_go(p, env, st, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{b}, False{})
      +st3 = cfg_alloc_reg(st2)
      cfg_emit(st3, ICtor{cfg_res(st3), env_cid_pair(env), Con{cfg_res(st1), Con{cfg_res(st2), Nil{}}}})
    case Succ{p} LTExpr{EArrNew{es}}:
      +st1 = low_go(p, env, st, LTExprs{es, Nil{}}, False{})
      +st2 = cfg_alloc_reg(st1)
      cfg_emit(st2, IArrOp{Con{cfg_res(st2), Nil{}}, 0, cfg_rlist(st1)})
    case Succ{+p} LTExpr{EArrGet{a, i}}:
      +st1 = low_go(p, env, st, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{i}, False{})
      +st3 = cfg_alloc_reg(st2)
      cfg_emit(st3, IArrOp{Con{cfg_res(st3), Nil{}}, 1, Con{cfg_res(st1), Con{cfg_res(st2), Nil{}}}})
    case Succ{+p} LTExpr{EArrSet{a, i, v}}:
      +st1 = low_go(p, env, st, LTExpr{a}, False{})
      +st2 = low_go(p, env, st1, LTExpr{i}, False{})
      +st3 = low_go(p, env, st2, LTExpr{v}, False{})
      +st4 = cfg_alloc_reg(st3)
      cfg_emit(st4, IArrOp{Con{cfg_res(st4), Nil{}}, 2, Con{cfg_res(st1), Con{cfg_res(st2), Con{cfg_res(st3), Nil{}}}}})
    case Succ{p} LTExpr{EDo{ss}}: low_go(p, env, st, LTDo{ss}, is_tail)
    case Succ{_} LTExpr{ELam{_, _}}:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, ICallClosure{cfg_res(st1), 0, Nil{}})
    case Succ{_} _:
      +st1 = cfg_alloc_reg(st)
      cfg_emit(st1, IConst{cfg_res(st1), 0})

# Function & Book Lowering
# ------------------------
def low_bind_params(ps: List<&2, Param>, st: CfgSt, +idx: U32, +body: Expr) -> CfgSt:
  match ps:
    case Nil{}: st
    case Con{Param{+sym, _, erased, dup}, t}:
      match erased:
        case True{}: low_bind_params(t, st, idx, body)
        case False{}:
          +st1 = cfg_apply_rc(st, idx, dup, count_uses_go(U32.to_nat(2048), sym, UIExpr{body}))
          st2 = cfg_set_vmap(st1, um_set(cfg_vmap(st1), sym, U32.add(idx, 1)))
          low_bind_params(t, st2, U32.add(idx, 1), body)

def low_def_fin(env: LowEnv, +fid: U32, sym: U32, ar: U32, st: CfgSt) -> IrFn:
  match env st:
    case LowEnv{syms, _, _, _, esc_fns, eff_fns, main_fid, _, _, _, _, _} CfgSt{_, nregs, _, _, _, blks_rev, _, _, _, _, _}:
      IrFn{fid, symtab_name(syms, sym), ar, nregs, U32.is_ne(um_get(esc_fns, fid), 0), U32.is_ne(um_get(eff_fns, fid), 0), U32.is_eq(fid, main_fid), b5k_list_rev(IrBlock, blks_rev)}
def low_def(+env: LowEnv, +fid: U32, d: Def) -> IrFn:
  match d:
    case Def{sym, +params, _, +body, _, _}:
      +ar = low_param_arity_go(params, 0)
      +st2 = low_go(U32.to_nat(2048), env, low_bind_params(params, cfg_new(fid, ar), 0, body), LTExpr{body}, True{})
      low_def_fin(env, fid, sym, ar, cfg_seal(st2, TRet{cfg_res(st2)}))
def low_defs(ds: List<&2, Def>, +env: LowEnv, +fid: U32, acc: List<&2, IrFn>) -> List<&2, IrFn>:
  match ds:
    case Nil{}: b5k_list_rev(IrFn, acc)
    case Con{d, t}: low_defs(t, env, U32.add(fid, 1), Con{low_def(env, fid, d), acc})
def b5k_lower_s3(+syms: SymTab, defs: List<&2, Def>, +ctor_by_sym: U32Map, ctors_rev: List<&2, IrCtor>, fn_by_sym: U32Map, fn_arity: U32Map, +main_fid: U32, ea: EscAcc) -> LowerRes:
  match ea:
    case EscAcc{esc_fns, +eff_fns}:
      cid_nil = low_cid_of(ctor_by_sym, symtab_lookup(syms, "Nil"), 0)
      cid_con = low_cid_of(ctor_by_sym, symtab_lookup(syms, "Con"), 1)
      cid_snil = low_cid_of(ctor_by_sym, symtab_lookup(syms, "SNil"), 2)
      cid_scon = low_cid_of(ctor_by_sym, symtab_lookup(syms, "SCon"), 3)
      cid_pair = low_cid_of(ctor_by_sym, symtab_lookup(syms, "Pair"), 4)
      fns = low_defs(defs, LowEnv{syms, ctor_by_sym, fn_by_sym, fn_arity, esc_fns, eff_fns, main_fid, cid_nil, cid_con, cid_snil, cid_scon, cid_pair}, 0, Nil{})
      LowerRes{True{}, "", IrProg{fns, b5k_list_rev(IrCtor, ctors_rev), Nil{}, main_fid, U32.is_zero(um_get(eff_fns, main_fid)), Nil{}, Nil{}, Nil{}}}
def b5k_lower_s2(+syms: SymTab, +defs: List<&2, Def>, ctor_by_sym: U32Map, ctors_rev: List<&2, IrCtor>, fa: FnTabAcc) -> LowerRes:
  match fa:
    case FnTabAcc{_, +fn_by_sym, +fn_arity, main_fid}:
      b5k_lower_s3(syms, defs, ctor_by_sym, ctors_rev, fn_by_sym, fn_arity, main_fid, low_scan_defs(defs, syms, fn_by_sym, fn_arity, 0, EscAcc{UM0{}, UM0{}}))
def b5k_lower_s1(+syms: SymTab, +defs: List<&2, Def>, ca: CtorTabAcc) -> LowerRes:
  match ca:
    case CtorTabAcc{_, ctor_by_sym, ctors_rev}:
      b5k_lower_s2(syms, defs, ctor_by_sym, ctors_rev, low_add_defs(syms, defs, FnTabAcc{0, UM0{}, UM0{}, 0}))
def b5k_lower(book: Book) -> LowerRes:
  match book:
    case Book{types, defs, _, +syms}:
      b5k_lower_s1(syms, defs, low_add_types(syms, types, CtorTabAcc{0, UM0{}, Nil{}}))
