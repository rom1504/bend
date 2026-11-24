# bend5k/opt.bend — Milestone 4 IR -O2 Optimizer (IrProg -> IrProg)
# ==================================================================
# Four dense-U32 passes (zero string hashing):
#   1. Scalar type inference & unboxed IKeep/ISink elision
#   2. Constant folding, algebraic simplification & strength reduction
#   3. Per-block copy propagation, DCE & unreachable-block elimination
#   4. Small single-block leaf helper inlining (<= 12 ops)
# Shared Vreg Map / Use-Def Helpers
# ---------------------------------
def opt_um_inc(+m: U32Map, +k: U32) -> U32Map:
  um_set(m, k, U32.add(um_get(m, k), 1))
def opt_um_inc_list(xs: List<&2, U32>, m: U32Map) -> U32Map:
  match xs:
    case Nil{}: m
    case Con{v, t}: opt_um_inc_list(t, opt_um_inc(m, v))
def opt_um_set_list(xs: List<&2, U32>, +val: U32, m: U32Map) -> U32Map:
  match xs:
    case Nil{}: m
    case Con{v, t}: opt_um_set_list(t, val, um_set(m, v, val))
def opt_um_lookup_or(+m: U32Map, +v: U32) -> U32:
  +got = um_get(m, v)
  Bool.pick(U32, U32.is_zero(got), v, U32.sub(got, 1))
def opt_map_u32(+m: U32Map, xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{v, t}: Con{opt_um_lookup_or(m, v), opt_map_u32(m, t)}
def opt_shift_u32(+base: U32, xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{v, t}: Con{U32.add(base, v), opt_shift_u32(base, t)}
def opt_op_defs(op: IrOp, m: U32Map) -> U32Map:
  match op:
    case IConst{d, _}: opt_um_inc(m, d)
    case IFlt{d, _}: opt_um_inc(m, d)
    case ICopy{d, _}: opt_um_inc(m, d)
    case IBin{d, _, _, _}: opt_um_inc(m, d)
    case IUn{d, _, _}: opt_um_inc(m, d)
    case ICmp{d, _, _, _}: opt_um_inc(m, d)
    case ICallDirect{d, _, _}: opt_um_inc(m, d)
    case ICallClosure{d, _, _}: opt_um_inc(m, d)
    case IApply{d, _, _}: opt_um_inc(m, d)
    case ICtor{d, _, _}: opt_um_inc(m, d)
    case ITake{ds, _}: opt_um_inc_list(ds, m)
    case ITag{d, _}: opt_um_inc(m, d)
    case IKeep{d, _}: opt_um_inc(m, d)
    case IReuse{d, _, _, _}: opt_um_inc(m, d)
    case IStatic{d, _}: opt_um_inc(m, d)
    case IArrOp{ds, _, _}: opt_um_inc_list(ds, m)
    case IAlloca{d, _}: opt_um_inc(m, d)
    case ILoad{d, _, _}: opt_um_inc(m, d)
    case _: m
def opt_op_uses(op: IrOp, m: U32Map) -> U32Map:
  match op:
    case ICopy{_, s}: opt_um_inc(m, s)
    case IBin{_, _, a, b}: opt_um_inc(opt_um_inc(m, a), b)
    case IUn{_, _, s}: opt_um_inc(m, s)
    case ICmp{_, _, a, b}: opt_um_inc(opt_um_inc(m, a), b)
    case ICallDirect{_, _, args}: opt_um_inc_list(args, m)
    case ICallClosure{_, _, caps}: opt_um_inc_list(caps, m)
    case IApply{_, c, a}: opt_um_inc(opt_um_inc(m, c), a)
    case ICtor{_, _, fs}: opt_um_inc_list(fs, m)
    case ITake{_, s}: opt_um_inc(m, s)
    case ITag{_, s}: opt_um_inc(m, s)
    case IKeep{_, s}: opt_um_inc(m, s)
    case ISink{s}: opt_um_inc(m, s)
    case IReuse{_, sl, _, fs}: opt_um_inc_list(fs, opt_um_inc(m, sl))
    case IArrOp{_, _, args}: opt_um_inc_list(args, m)
    case ILoad{_, b, _}: opt_um_inc(m, b)
    case IStore{b, _, v}: opt_um_inc(opt_um_inc(m, b), v)
    case _: m
def opt_term_uses(term: IrTerm, m: U32Map) -> U32Map:
  match term:
    case TBr{c, _, _}: opt_um_inc(m, c)
    case TSwitch{s, _, _}: opt_um_inc(m, s)
    case TRet{v}: opt_um_inc(m, v)
    case TTailCall{_, args}: opt_um_inc_list(args, m)
    case _: m
def opt_ops_defs(ops: List<&2, IrOp>, m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{op, t}: opt_ops_defs(t, opt_op_defs(op, m))
def opt_blks_defs(blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, _}, t}: opt_blks_defs(t, opt_ops_defs(ops, m))
def opt_ops_uses(ops: List<&2, IrOp>, m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{op, t}: opt_ops_uses(t, opt_op_uses(op, m))
def opt_blks_uses(blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, term}, t}: opt_blks_uses(t, opt_term_uses(term, opt_ops_uses(ops, m)))
def opt_op_pure_dst(op: IrOp) -> U32:
  match op:
    case IConst{d, _}: U32.add(d, 1)
    case IFlt{d, _}: U32.add(d, 1)
    case ICopy{d, _}: U32.add(d, 1)
    case IBin{d, _, _, _}: U32.add(d, 1)
    case IUn{d, _, _}: U32.add(d, 1)
    case ICmp{d, _, _, _}: U32.add(d, 1)
    case ITag{d, _}: U32.add(d, 1)
    case _: 0
# Pass 1 — Scalar Type Inference & Unboxed IKeep/ISink Elision
# ------------------------------------------------------------
# Lattice per vreg: 0 = unvisited, 1 = guaranteed scalar, 2 = non-scalar.
def opt_sc_init_params(n: Nat, +idx: U32, m: U32Map) -> U32Map:
  match n:
    case 0n: m
    case 1n+p: opt_sc_init_params(p, U32.add(idx, 1), um_set(m, idx, 2))
def opt_sc_mark_scalar(+m: U32Map, +d: U32) -> U32Map:
  Bool.pick(U32Map, U32.is_zero(um_get(m, d)), um_set(m, d, 1), m)
def opt_sc_direct_op(+ret_sc: U32Map, op: IrOp, m: U32Map) -> U32Map:
  match op:
    case IConst{d, _}: opt_sc_mark_scalar(m, d)
    case IFlt{d, _}: opt_sc_mark_scalar(m, d)
    case IBin{d, _, _, _}: opt_sc_mark_scalar(m, d)
    case IUn{d, _, _}: opt_sc_mark_scalar(m, d)
    case ICmp{d, _, _, _}: opt_sc_mark_scalar(m, d)
    case ITag{d, _}: opt_sc_mark_scalar(m, d)
    case ICallDirect{+d, fid, _}:
      +m0 = m
      Bool.pick(U32Map, U32.is_ne(um_get(ret_sc, fid), 0), opt_sc_mark_scalar(m0, d), um_set(m0, d, 2))
    case ICallClosure{d, _, _}: um_set(m, d, 2)
    case IApply{d, _, _}: um_set(m, d, 2)
    case ICtor{d, _, _}: um_set(m, d, 2)
    case ITake{ds, _}: opt_um_set_list(ds, 2, m)
    case IReuse{d, _, _, _}: um_set(m, d, 2)
    case IStatic{d, _}: um_set(m, d, 2)
    case IArrOp{ds, _, _}: opt_um_set_list(ds, 2, m)
    case IAlloca{d, _}: um_set(m, d, 2)
    case ILoad{d, _, _}: um_set(m, d, 2)
    case _: m
def opt_sc_direct_ops(+ret_sc: U32Map, ops: List<&2, IrOp>, m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{op, t}: opt_sc_direct_ops(ret_sc, t, opt_sc_direct_op(ret_sc, op, m))
def opt_sc_direct_blks(+ret_sc: U32Map, blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, _}, t}: opt_sc_direct_blks(ret_sc, t, opt_sc_direct_ops(ret_sc, ops, m))
def opt_sc_prop_copy(poison: Bool, +d: U32, s: U32, +m: U32Map) -> U32Map:
  match poison:
    case False{}: Bool.pick(U32Map, Bool.and(U32.is_zero(um_get(m, d)), U32.is_eq(um_get(m, s), 1)), um_set(m, d, 1), m)
    case True{}: Bool.pick(U32Map, U32.is_ne(um_get(m, s), 1), um_set(m, d, 2), m)
def opt_sc_prop_ops(+poison: Bool, ops: List<&2, IrOp>, m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{ICopy{d, s}, t}: opt_sc_prop_ops(poison, t, opt_sc_prop_copy(poison, d, s, m))
    case Con{IKeep{d, s}, t}: opt_sc_prop_ops(poison, t, opt_sc_prop_copy(poison, d, s, m))
    case Con{_, t}: opt_sc_prop_ops(poison, t, m)
def opt_sc_prop_blks(+poison: Bool, blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, _}, t}: opt_sc_prop_blks(poison, t, opt_sc_prop_ops(poison, ops, m))
def opt_sc_prop_n(k: Nat, +poison: Bool, +blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match k:
    case 0n: m
    case 1n+p: opt_sc_prop_n(p, poison, blks, opt_sc_prop_blks(poison, blks, m))
def opt_sc_elide_keep(is_sc: Bool, +d: U32, +s: U32, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match is_sc:
    case False{}: Con{IKeep{d, s}, acc}
    case True{}: Bool.pick(List<&2, IrOp>, U32.is_eq(d, s), acc, Con{ICopy{d, s}, acc})
def opt_sc_rewrite_ops(+sc: U32Map, ops: List<&2, IrOp>, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: b5k_list_rev(IrOp, acc)
    case Con{IKeep{d, +s}, t}:
      opt_sc_rewrite_ops(sc, t, opt_sc_elide_keep(U32.is_eq(um_get(sc, s), 1), d, s, acc))
    case Con{ISink{+s}, t}:
      acc2 = Bool.pick(List<&2, IrOp>, U32.is_eq(um_get(sc, s), 1), acc, Con{ISink{s}, acc})
      opt_sc_rewrite_ops(sc, t, acc2)
    case Con{op, t}: opt_sc_rewrite_ops(sc, t, Con{op, acc})
def opt_sc_rewrite_blks(+sc: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}:
      Con{IrBlock{id, opt_sc_rewrite_ops(sc, ops, Nil{}), term}, opt_sc_rewrite_blks(sc, t)}
def opt_sc_all_rets(+sc: U32Map, blks: List<&2, IrBlock>, has_ret: Bool) -> Bool:
  match blks:
    case Nil{}: has_ret
    case Con{IrBlock{_, _, TRet{rv}}, t}:
      Bool.and(U32.is_eq(um_get(sc, rv), 1), opt_sc_all_rets(sc, t, True{}))
    case Con{IrBlock{_, _, TTailCall{_, _}}, t}: opt_sc_all_rets(sc, t, has_ret)
    case Con{IrBlock{_, _, _}, t}: opt_sc_all_rets(sc, t, has_ret)
def opt_collect_ret_sc(fns: List<&2, IrFn>, m: U32Map) -> U32Map:
  match fns:
    case Nil{}: m
    case Con{IrFn{+fid, _, +ar, _, _, _, _, +blks}, t}:
      +m0 = m
      m1 = opt_sc_direct_blks(m0, blks, opt_sc_init_params(U32.to_nat(ar), 0, UM0{}))
      sc = opt_sc_prop_n(3n, True{}, blks, opt_sc_prop_n(3n, False{}, blks, m1))
      m2 = Bool.pick(U32Map, Bool.and(U32.is_ge(fid, 3), opt_sc_all_rets(sc, blks, False{})), um_set(m0, fid, 1), m0)
      opt_collect_ret_sc(t, m2)
def opt_pass_scalar(+ret_sc: U32Map, f: IrFn) -> IrFn:
  match f:
    case IrFn{fid, nm, +ar, nregs, esc, eff, is_m, +blks}:
      m0 = opt_sc_direct_blks(ret_sc, blks, opt_sc_init_params(U32.to_nat(ar), 0, UM0{}))
      m1 = opt_sc_prop_n(3n, False{}, blks, m0)
      sc = opt_sc_prop_n(3n, True{}, blks, m1)
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_sc_rewrite_blks(sc, blks)}
# Pass 2 — Constant Folding, Algebraic Simplification & Strength Reduction
# ------------------------------------------------------------------------
def opt_fold_bin(+op: U32, +a: U32, +b: U32) -> U32:
  match op:
    case 0: U32.add(a, b)
    case 1: U32.sub(a, b)
    case 2: U32.mul(a, b)
    case 3: Bool.pick(U32, U32.is_zero(b), 0, U32.div(a, b))
    case 4: Bool.pick(U32, U32.is_zero(b), a, U32.mod(a, b))
    case 5: U32.and(a, b)
    case 6: U32.or(a, b)
    case 7: U32.xor(a, b)
    case 8: U32.shln(a, U32.to_nat(b))
    case _: U32.shrn(a, U32.to_nat(b))
def opt_fold_un(op: U32, a: U32) -> U32:
  match op:
    case 0: U32.sub(0, a)
    case _: U32.xor(a, 4294967295)
def opt_fold_cmp(op: U32, a: U32, b: U32) -> U32:
  match op:
    case 0: Bool.to_u32(U32.is_eq(a, b))
    case 1: Bool.to_u32(U32.is_ne(a, b))
    case 2: Bool.to_u32(U32.is_lt(a, b))
    case 3: Bool.to_u32(U32.is_le(a, b))
    case 4: Bool.to_u32(U32.is_gt(a, b))
    case _: Bool.to_u32(U32.is_ge(a, b))
def opt_ctz_go(fuel: Nat, +x: U32, +acc: U32) -> U32:
  match fuel:
    case 0n: acc
    case 1n+p:
      Bool.pick(U32, U32.is_le(x, 1), acc, opt_ctz_go(p, U32.shr(x), U32.add(acc, 1)))
def opt_pow2_log(+c: U32) -> U32:
  ok = Bool.and(U32.is_ge(c, 2), Bool.and(U32.is_le(c, 1073741824), U32.is_zero(U32.and(c, U32.sub(c, 1)))))
  Bool.pick(U32, ok, opt_ctz_go(31n, c, 0), 0)
type CfSt is Data:
  CfSt{has: U32Map, val: U32Map, nregs: U32, ops_rev: List<&2, IrOp>}
def cf_kill_op_dsts(op: IrOp, has: U32Map) -> U32Map:
  match op:
    case IFlt{d, _}: um_set(has, d, 0)
    case IBin{d, _, _, _}: um_set(has, d, 0)
    case IUn{d, _, _}: um_set(has, d, 0)
    case ICmp{d, _, _, _}: um_set(has, d, 0)
    case ICallDirect{d, _, _}: um_set(has, d, 0)
    case ICallClosure{d, _, _}: um_set(has, d, 0)
    case IApply{d, _, _}: um_set(has, d, 0)
    case ICtor{d, _, _}: um_set(has, d, 0)
    case ITake{ds, _}: opt_um_set_list(ds, 0, has)
    case ITag{d, _}: um_set(has, d, 0)
    case IKeep{d, _}: um_set(has, d, 0)
    case IReuse{d, _, _, _}: um_set(has, d, 0)
    case IStatic{d, _}: um_set(has, d, 0)
    case IArrOp{ds, _, _}: opt_um_set_list(ds, 0, has)
    case IAlloca{d, _}: um_set(has, d, 0)
    case ILoad{d, _, _}: um_set(has, d, 0)
    case _: has
def cf_emit_const(has: U32Map, val: U32Map, nregs: U32, rev: List<&2, IrOp>, +d: U32, +v: U32) -> CfSt:
  CfSt{um_set(has, d, 1), um_set(val, d, v), nregs, Con{IConst{d, v}, rev}}
def cf_emit_copy(+has: U32Map, +val: U32Map, nregs: U32, rev: List<&2, IrOp>, +d: U32, +s: U32) -> CfSt:
  +hs = um_get(has, s)
  CfSt{um_set(has, d, hs), um_set(val, d, um_get(val, s)), nregs, Con{ICopy{d, s}, rev}}
def cf_emit_sr(has: U32Map, val: U32Map, +nr: U32, rev: List<&2, IrOp>, +d: U32, sop: U32, x: U32, imm: U32) -> CfSt:
  CfSt{um_set(has, d, 0), val, U32.add(nr, 1), Con{IBin{d, sop, x, nr}, Con{IConst{nr, imm}, rev}}}
def cf_bin_mul_go(is0: Bool, is1: Bool, +has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +a: U32, +b: U32, +x: U32, +c: U32) -> CfSt:
  match is0 is1:
    case True{} _: cf_emit_const(has, val, nr, rev, d, 0)
    case False{} True{}: cf_emit_copy(has, val, nr, rev, d, x)
    case False{} False{}:
      +p2 = opt_pow2_log(c)
      Bool.pick(CfSt, U32.is_ne(p2, 0), cf_emit_sr(has, val, nr, rev, d, B5K_OP_SHL(), x, p2), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 2, a, b}, rev}})
def cf_bin_div_go(is1: Bool, +has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +a: U32, +b: U32, +cb: U32) -> CfSt:
  match is1:
    case True{}: cf_emit_copy(has, val, nr, rev, d, a)
    case False{}:
      +p2 = opt_pow2_log(cb)
      Bool.pick(CfSt, U32.is_ne(p2, 0), cf_emit_sr(has, val, nr, rev, d, B5K_OP_SHR(), a, p2), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 3, a, b}, rev}})
def cf_bin_mod_go(is1: Bool, +has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +a: U32, +b: U32, +cb: U32) -> CfSt:
  match is1:
    case True{}: cf_emit_const(has, val, nr, rev, d, 0)
    case False{}:
      +p2 = opt_pow2_log(cb)
      Bool.pick(CfSt, U32.is_ne(p2, 0), cf_emit_sr(has, val, nr, rev, d, B5K_OP_AND(), a, U32.sub(cb, 1)), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 4, a, b}, rev}})
def cf_bin_rhs_const(+has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32, +b: U32, +cb: U32) -> CfSt:
  match op:
    case 0: Bool.pick(CfSt, U32.is_zero(cb), cf_emit_copy(has, val, nr, rev, d, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 0, a, b}, rev}})
    case 1: Bool.pick(CfSt, U32.is_zero(cb), cf_emit_copy(has, val, nr, rev, d, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 1, a, b}, rev}})
    case 2: cf_bin_mul_go(U32.is_zero(cb), U32.is_eq(cb, 1), has, val, nr, rev, d, a, b, a, cb)
    case 3: cf_bin_div_go(U32.is_eq(cb, 1), has, val, nr, rev, d, a, b, cb)
    case 4: cf_bin_mod_go(U32.is_eq(cb, 1), has, val, nr, rev, d, a, b, cb)
    case 5: Bool.pick(CfSt, U32.is_zero(cb), cf_emit_const(has, val, nr, rev, d, 0), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 5, a, b}, rev}})
    case 6: Bool.pick(CfSt, U32.is_zero(cb), cf_emit_copy(has, val, nr, rev, d, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 6, a, b}, rev}})
    case 7: Bool.pick(CfSt, U32.is_zero(cb), cf_emit_copy(has, val, nr, rev, d, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 7, a, b}, rev}})
    case 8: Bool.pick(CfSt, U32.is_zero(cb), cf_emit_copy(has, val, nr, rev, d, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 8, a, b}, rev}})
    case _: Bool.pick(CfSt, U32.is_zero(cb), cf_emit_copy(has, val, nr, rev, d, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, op, a, b}, rev}})
def cf_bin_lhs_const(+has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32, +b: U32, +ca: U32) -> CfSt:
  match op:
    case 0: Bool.pick(CfSt, U32.is_zero(ca), cf_emit_copy(has, val, nr, rev, d, b), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 0, a, b}, rev}})
    case 2: cf_bin_mul_go(U32.is_zero(ca), U32.is_eq(ca, 1), has, val, nr, rev, d, a, b, b, ca)
    case 5: Bool.pick(CfSt, U32.is_zero(ca), cf_emit_const(has, val, nr, rev, d, 0), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 5, a, b}, rev}})
    case 6: Bool.pick(CfSt, U32.is_zero(ca), cf_emit_copy(has, val, nr, rev, d, b), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 6, a, b}, rev}})
    case 7: Bool.pick(CfSt, U32.is_zero(ca), cf_emit_copy(has, val, nr, rev, d, b), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 7, a, b}, rev}})
    case _: CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, op, a, b}, rev}}
def cf_bin_same(+has: U32Map, +val: U32Map, nr: U32, rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32) -> CfSt:
  match op:
    case 1: cf_emit_const(has, val, nr, rev, d, 0)
    case 5: cf_emit_copy(has, val, nr, rev, d, a)
    case 6: cf_emit_copy(has, val, nr, rev, d, a)
    case 7: cf_emit_const(has, val, nr, rev, d, 0)
    case _: CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, op, a, a}, rev}}
def cf_step_bin_int(ha: Bool, hb: Bool, +has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32, +b: U32) -> CfSt:
  match ha hb:
    case True{} True{}:
      +ca = um_get(val, a)
      +cb = um_get(val, b)
      bad_sh = Bool.and(U32.is_ge(op, 8), U32.is_ge(cb, 32))
      Bool.pick(CfSt, bad_sh, CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, op, a, b}, rev}}, cf_emit_const(has, val, nr, rev, d, opt_fold_bin(op, ca, cb)))
    case False{} True{}: cf_bin_rhs_const(has, val, nr, rev, d, op, a, b, um_get(val, b))
    case True{} False{}: cf_bin_lhs_const(has, val, nr, rev, d, op, a, b, um_get(val, a))
    case False{} False{}:
      Bool.pick(CfSt, U32.is_eq(a, b), cf_bin_same(has, val, nr, rev, d, op, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, op, a, b}, rev}})
def cf_step_bin_flt(is_flt: Bool, +has: U32Map, +val: U32Map, nr: U32, rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32, +b: U32) -> CfSt:
  match is_flt:
    case True{}: CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, op, a, b}, rev}}
    case False{}: cf_step_bin_int(U32.is_ne(um_get(has, a), 0), U32.is_ne(um_get(has, b), 0), has, val, nr, rev, d, op, a, b)
def cf_step_bin(+has: U32Map, +val: U32Map, nr: U32, rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32, +b: U32) -> CfSt:
  cf_step_bin_flt(U32.is_ge(op, 10), has, val, nr, rev, d, op, a, b)
def cf_step_op(st: CfSt, op: IrOp) -> CfSt:
  match st:
    case CfSt{+has, +val, +nr, +rev}:
      match op:
        case IConst{d, v}: cf_emit_const(has, val, nr, rev, d, v)
        case ICopy{d, s}: cf_emit_copy(has, val, nr, rev, d, s)
        case IBin{d, bop, a, b}: cf_step_bin(has, val, nr, rev, d, bop, a, b)
        case IUn{+d, +uop, +s}:
          can = Bool.and(U32.is_lt(uop, 2), U32.is_ne(um_get(has, s), 0))
          Bool.pick(CfSt, can, cf_emit_const(has, val, nr, rev, d, opt_fold_un(uop, um_get(val, s))), CfSt{um_set(has, d, 0), val, nr, Con{IUn{d, uop, s}, rev}})
        case ICmp{+d, +cop, +a, +b}:
          can = Bool.and(U32.is_lt(cop, 6), Bool.and(U32.is_ne(um_get(has, a), 0), U32.is_ne(um_get(has, b), 0)))
          Bool.pick(CfSt, can, cf_emit_const(has, val, nr, rev, d, opt_fold_cmp(cop, um_get(val, a), um_get(val, b))), CfSt{um_set(has, d, 0), val, nr, Con{ICmp{d, cop, a, b}, rev}})
        case other:
          +op0 = other
          CfSt{cf_kill_op_dsts(op0, has), val, nr, Con{op0, rev}}
def cf_step_ops(ops: List<&2, IrOp>, st: CfSt) -> CfSt:
  match ops:
    case Nil{}: st
    case Con{op, t}: cf_step_ops(t, cf_step_op(st, op))
def cf_find_arm(arms: List<&2, IrSwitchArm>, +tag: U32, def_blk: U32) -> U32:
  match arms:
    case Nil{}: def_blk
    case Con{IrArm{t, tgt}, rest}:
      Bool.pick(U32, U32.is_eq(t, tag), tgt, cf_find_arm(rest, tag, def_blk))
def cf_fold_term(+has: U32Map, +val: U32Map, term: IrTerm) -> IrTerm:
  match term:
    case TBr{+c, +tb, +fb}:
      Bool.pick(IrTerm, U32.is_ne(um_get(has, c), 0), TJmp{Bool.pick(U32, U32.is_zero(um_get(val, c)), fb, tb)}, TBr{c, tb, fb})
    case TSwitch{+s, +arms, +def_blk}:
      Bool.pick(IrTerm, U32.is_ne(um_get(has, s), 0), TJmp{cf_find_arm(arms, um_get(val, s), def_blk)}, TSwitch{s, arms, def_blk})
    case other: other
type CfBlksRes is Data:
  CfBlksRes{blks: List<&2, IrBlock>, nregs: U32}
def cf_st_blk(id: U32, term: IrTerm, st: CfSt) -> IrBlock:
  match st:
    case CfSt{has, val, _, rev}: IrBlock{id, b5k_list_rev(IrOp, rev), cf_fold_term(has, val, term)}
def cf_st_nr(st: CfSt) -> U32:
  match st:
    case CfSt{_, _, nr, _}: nr
def cf_blks_go(blks: List<&2, IrBlock>, nr: U32, acc: List<&2, IrBlock>) -> CfBlksRes:
  match blks:
    case Nil{}: CfBlksRes{b5k_list_rev(IrBlock, acc), nr}
    case Con{IrBlock{id, ops, term}, t}:
      +st = cf_step_ops(ops, CfSt{UM0{}, UM0{}, nr, Nil{}})
      cf_blks_go(t, cf_st_nr(st), Con{cf_st_blk(id, term, st), acc})
def cf_fn_fin(fid: U32, nm: String, ar: U32, esc: Bool, eff: Bool, is_m: Bool, r: CfBlksRes) -> IrFn:
  match r:
    case CfBlksRes{blks2, nr2}: IrFn{fid, nm, ar, nr2, esc, eff, is_m, blks2}
def opt_pass_cf(f: IrFn) -> IrFn:
  match f:
    case IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}:
      cf_fn_fin(fid, nm, ar, esc, eff, is_m, cf_blks_go(blks, nregs, Nil{}))
# Pass 3 — Copy Propagation, DCE & Unreachable Block Elimination
# --------------------------------------------------------------
def opt_cp_can_prop(+defc: U32Map, +ar: U32, +r: U32) -> Bool:
  +dc = um_get(defc, r)
  Bool.pick(Bool, U32.is_lt(r, ar), U32.is_zero(dc), U32.is_le(dc, 1))
def opt_cp_rewrite_op(+cm: U32Map, op: IrOp) -> IrOp:
  match op:
    case ICopy{d, s}: ICopy{d, opt_um_lookup_or(cm, s)}
    case IBin{d, bop, a, b}: IBin{d, bop, opt_um_lookup_or(cm, a), opt_um_lookup_or(cm, b)}
    case IUn{d, uop, s}: IUn{d, uop, opt_um_lookup_or(cm, s)}
    case ICmp{d, cop, a, b}: ICmp{d, cop, opt_um_lookup_or(cm, a), opt_um_lookup_or(cm, b)}
    case ICallDirect{d, fid, args}: ICallDirect{d, fid, opt_map_u32(cm, args)}
    case ICallClosure{d, fid, caps}: ICallClosure{d, fid, opt_map_u32(cm, caps)}
    case IApply{d, c, a}: IApply{d, opt_um_lookup_or(cm, c), opt_um_lookup_or(cm, a)}
    case ICtor{d, cid, fs}: ICtor{d, cid, opt_map_u32(cm, fs)}
    case ITake{ds, s}: ITake{ds, opt_um_lookup_or(cm, s)}
    case ITag{d, s}: ITag{d, opt_um_lookup_or(cm, s)}
    case IKeep{d, s}: IKeep{d, opt_um_lookup_or(cm, s)}
    case ISink{s}: ISink{opt_um_lookup_or(cm, s)}
    case IReuse{d, sl, cid, fs}: IReuse{d, opt_um_lookup_or(cm, sl), cid, opt_map_u32(cm, fs)}
    case IArrOp{ds, aop, args}: IArrOp{ds, aop, opt_map_u32(cm, args)}
    case ILoad{d, b, off}: ILoad{d, opt_um_lookup_or(cm, b), off}
    case IStore{b, off, v}: IStore{opt_um_lookup_or(cm, b), off, opt_um_lookup_or(cm, v)}
    case other: other
def opt_cp_kill_dsts(op: IrOp, cm: U32Map) -> U32Map:
  match op:
    case IConst{d, _}: um_set(cm, d, 0)
    case IFlt{d, _}: um_set(cm, d, 0)
    case IBin{d, _, _, _}: um_set(cm, d, 0)
    case IUn{d, _, _}: um_set(cm, d, 0)
    case ICmp{d, _, _, _}: um_set(cm, d, 0)
    case ICallDirect{d, _, _}: um_set(cm, d, 0)
    case ICallClosure{d, _, _}: um_set(cm, d, 0)
    case IApply{d, _, _}: um_set(cm, d, 0)
    case ICtor{d, _, _}: um_set(cm, d, 0)
    case ITake{ds, _}: opt_um_set_list(ds, 0, cm)
    case ITag{d, _}: um_set(cm, d, 0)
    case IKeep{d, _}: um_set(cm, d, 0)
    case IReuse{d, _, _, _}: um_set(cm, d, 0)
    case IStatic{d, _}: um_set(cm, d, 0)
    case IArrOp{ds, _, _}: opt_um_set_list(ds, 0, cm)
    case IAlloca{d, _}: um_set(cm, d, 0)
    case ILoad{d, _, _}: um_set(cm, d, 0)
    case _: cm
type CpOpsRes is Data:
  CpOpsRes{ops: List<&2, IrOp>, cm: U32Map}
def opt_cp_ops(+defc: U32Map, +ar: U32, ops: List<&2, IrOp>, cm: U32Map, +acc: List<&2, IrOp>) -> CpOpsRes:
  match ops:
    case Nil{}: CpOpsRes{b5k_list_rev(IrOp, acc), cm}
    case Con{ICopy{+d, s}, t}:
      +cm0 = cm
      +rs = opt_um_lookup_or(cm0, s)
      cm1 = Bool.pick(U32Map, Bool.and(U32.is_ne(d, rs), opt_cp_can_prop(defc, ar, rs)), um_set(cm0, d, U32.add(rs, 1)), um_set(cm0, d, 0))
      acc1 = Bool.pick(List<&2, IrOp>, U32.is_eq(d, rs), acc, Con{ICopy{d, rs}, acc})
      opt_cp_ops(defc, ar, t, cm1, acc1)
    case Con{op, t}:
      +cm0 = cm
      +op2 = opt_cp_rewrite_op(cm0, op)
      opt_cp_ops(defc, ar, t, opt_cp_kill_dsts(op2, cm0), Con{op2, acc})
def opt_cp_term(+cm: U32Map, term: IrTerm) -> IrTerm:
  match term:
    case TBr{c, tb, fb}: TBr{opt_um_lookup_or(cm, c), tb, fb}
    case TSwitch{s, arms, db}: TSwitch{opt_um_lookup_or(cm, s), arms, db}
    case TRet{v}: TRet{opt_um_lookup_or(cm, v)}
    case TTailCall{fid, args}: TTailCall{fid, opt_map_u32(cm, args)}
    case other: other
def opt_cp_blk_fin(id: U32, term: IrTerm, r: CpOpsRes) -> IrBlock:
  match r:
    case CpOpsRes{ops2, cm2}: IrBlock{id, ops2, opt_cp_term(cm2, term)}
def opt_cp_blks(+defc: U32Map, +ar: U32, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}:
      Con{opt_cp_blk_fin(id, term, opt_cp_ops(defc, ar, ops, UM0{}, Nil{})), opt_cp_blks(defc, ar, t)}
def opt_dce_ops(+uses: U32Map, ops: List<&2, IrOp>, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: b5k_list_rev(IrOp, acc)
    case Con{+op, t}:
      +pd = opt_op_pure_dst(op)
      dead = Bool.and(U32.is_ne(pd, 0), U32.is_zero(um_get(uses, U32.sub(pd, 1))))
      opt_dce_ops(uses, t, Bool.pick(List<&2, IrOp>, dead, acc, Con{op, acc}))
def opt_dce_blks_once(+uses: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}:
      Con{IrBlock{id, opt_dce_ops(uses, ops, Nil{}), term}, opt_dce_blks_once(uses, t)}
def opt_dce_round(+blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  opt_dce_blks_once(opt_blks_uses(blks, UM0{}), blks)
type ReachStep is Data:
  ReachStep{m: U32Map, chg: Bool}
def opt_reach_mark(+m: U32Map, chg: Bool, +bid: U32) -> ReachStep:
  Bool.pick(ReachStep, U32.is_zero(um_get(m, bid)), ReachStep{um_set(m, bid, 1), True{}}, ReachStep{m, chg})
def opt_reach_arms(arms: List<&2, IrSwitchArm>, st: ReachStep) -> ReachStep:
  match arms st:
    case Nil{} _: st
    case Con{IrArm{_, tgt}, t} ReachStep{m, chg}:
      opt_reach_arms(t, opt_reach_mark(m, chg, tgt))
def opt_reach_mark_st(st: ReachStep, bid: U32) -> ReachStep:
  match st:
    case ReachStep{m, chg}: opt_reach_mark(m, chg, bid)
def opt_reach_term(term: IrTerm, st: ReachStep) -> ReachStep:
  match term:
    case TJmp{tgt}: opt_reach_mark_st(st, tgt)
    case TBr{_, tb, fb}: opt_reach_mark_st(opt_reach_mark_st(st, tb), fb)
    case TSwitch{_, arms, db}: opt_reach_arms(arms, opt_reach_mark_st(st, db))
    case _: st
def opt_reach_scan(blks: List<&2, IrBlock>, st: ReachStep) -> ReachStep:
  match blks st:
    case Nil{} _: st
    case Con{IrBlock{id, _, term}, t} ReachStep{+m, +chg}:
      st1 = Bool.pick(ReachStep, U32.is_ne(um_get(m, id), 0), opt_reach_term(term, ReachStep{m, chg}), ReachStep{m, chg})
      opt_reach_scan(t, st1)
def opt_rs_m(st: ReachStep) -> U32Map:
  match st:
    case ReachStep{m, _}: m
def opt_rs_chg(st: ReachStep) -> Bool:
  match st:
    case ReachStep{_, c}: c
def opt_reach_fix(fuel: Nat, +blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match fuel:
    case 0n: m
    case 1n+p:
      +st = opt_reach_scan(blks, ReachStep{m, False{}})
      Bool.pick(U32Map, opt_rs_chg(st), opt_reach_fix(p, blks, opt_rs_m(st)), opt_rs_m(st))
def opt_filter_reach(+reach: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, ops, term}, t}:
      +rest = opt_filter_reach(reach, t)
      Bool.pick(List<&2, IrBlock>, U32.is_ne(um_get(reach, id), 0), Con{IrBlock{id, ops, term}, rest}, rest)
def opt_elim_unreach(+blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  reach = opt_reach_fix(U32.to_nat(b5k_list_len(IrBlock, blks)), blks, um_set(UM0{}, 0, 1))
  opt_filter_reach(reach, blks)
def opt_pass_cp_dce(f: IrFn) -> IrFn:
  match f:
    case IrFn{fid, nm, +ar, nregs, esc, eff, is_m, +blks}:
      +b1 = opt_elim_unreach(blks)
      defc = opt_blks_defs(b1, UM0{})
      b2 = opt_cp_blks(defc, ar, b1)
      b3 = opt_dce_round(opt_dce_round(b2))
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, b3}
# Pass 4 — Small Leaf Helper Inlining (<= 12 ops, 1 block, non-recursive)
# -----------------------------------------------------------------------
type InlEntry is Data:
  InlEntry{fid: U32, arity: U32, nregs: U32, ops: List<&2, IrOp>, rv: U32}
type InlBank is Data:
  InlBank{has: U32Map, entries: List<&2, InlEntry>}
def opt_ops_has_call(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: False{}
    case Con{ICallDirect{_, _, _}, _}: True{}
    case Con{ICallClosure{_, _, _}, _}: True{}
    case Con{IApply{_, _, _}, _}: True{}
    case Con{_, t}: opt_ops_has_call(t)
def opt_collect_one(elig: Bool, +fid: U32, ar: U32, nregs: U32, blks: List<&2, IrBlock>, +has: U32Map, +acc: List<&2, InlEntry>) -> InlBank:
  match elig blks:
    case True{} Con{IrBlock{_, +ops, TRet{rv}}, Nil{}}:
      ok = Bool.and(U32.is_le(b5k_list_len(IrOp, ops), 12), Bool.not(opt_ops_has_call(ops)))
      Bool.pick(InlBank, ok, InlBank{um_set(has, fid, 1), Con{InlEntry{fid, ar, nregs, ops, rv}, acc}}, InlBank{has, acc})
    case _ _: InlBank{has, acc}
def opt_collect_inlines(fns: List<&2, IrFn>, bank: InlBank) -> InlBank:
  match fns bank:
    case Nil{} _: bank
    case Con{IrFn{+fid, _, ar, nregs, esc, eff, is_m, blks}, t} InlBank{has, acc}:
      elig = Bool.and(U32.is_ge(fid, 3), Bool.and(Bool.not(esc), Bool.and(Bool.not(eff), Bool.not(is_m))))
      opt_collect_inlines(t, opt_collect_one(elig, fid, ar, nregs, blks, has, acc))
def opt_find_inline(es: List<&2, InlEntry>, +fid: U32) -> Maybe<&2, InlEntry>:
  match es:
    case Nil{}: None{}
    case Con{InlEntry{+ef, ar, nr, ops, rv}, t}:
      Bool.pick(Maybe<&2, InlEntry>, U32.is_eq(ef, fid), Some{InlEntry{ef, ar, nr, ops, rv}}, opt_find_inline(t, fid))
def opt_shift_op(+b: U32, op: IrOp) -> IrOp:
  match op:
    case IConst{d, v}: IConst{U32.add(b, d), v}
    case IFlt{d, bits}: IFlt{U32.add(b, d), bits}
    case ICopy{d, s}: ICopy{U32.add(b, d), U32.add(b, s)}
    case IBin{d, bop, x, y}: IBin{U32.add(b, d), bop, U32.add(b, x), U32.add(b, y)}
    case IUn{d, uop, s}: IUn{U32.add(b, d), uop, U32.add(b, s)}
    case ICmp{d, cop, x, y}: ICmp{U32.add(b, d), cop, U32.add(b, x), U32.add(b, y)}
    case ICallDirect{d, fid, args}: ICallDirect{U32.add(b, d), fid, opt_shift_u32(b, args)}
    case ICallClosure{d, fid, caps}: ICallClosure{U32.add(b, d), fid, opt_shift_u32(b, caps)}
    case IApply{d, c, a}: IApply{U32.add(b, d), U32.add(b, c), U32.add(b, a)}
    case ICtor{d, cid, fs}: ICtor{U32.add(b, d), cid, opt_shift_u32(b, fs)}
    case ITake{ds, s}: ITake{opt_shift_u32(b, ds), U32.add(b, s)}
    case ITag{d, s}: ITag{U32.add(b, d), U32.add(b, s)}
    case IKeep{d, s}: IKeep{U32.add(b, d), U32.add(b, s)}
    case ISink{s}: ISink{U32.add(b, s)}
    case IReuse{d, sl, cid, fs}: IReuse{U32.add(b, d), U32.add(b, sl), cid, opt_shift_u32(b, fs)}
    case IStatic{d, idx}: IStatic{U32.add(b, d), idx}
    case IArrOp{ds, aop, args}: IArrOp{opt_shift_u32(b, ds), aop, opt_shift_u32(b, args)}
    case IAlloca{d, w}: IAlloca{U32.add(b, d), w}
    case ILoad{d, base, off}: ILoad{U32.add(b, d), U32.add(b, base), off}
    case IStore{base, off, v}: IStore{U32.add(b, base), off, U32.add(b, v)}
    case IFail{c}: IFail{c}
def opt_inl_emit_args(args: List<&2, U32>, +base: U32, +idx: U32, acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match args:
    case Nil{}: acc
    case Con{a, t}: opt_inl_emit_args(t, base, U32.add(idx, 1), Con{ICopy{U32.add(base, idx), a}, acc})
def opt_inl_emit_body(+base: U32, ops: List<&2, IrOp>, acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: acc
    case Con{op, t}: opt_inl_emit_body(base, t, Con{opt_shift_op(base, op), acc})
type InlOpsRes is Data:
  InlOpsRes{ops: List<&2, IrOp>, nregs: U32, budget: U32}
def opt_inl_try_call(me: Maybe<&2, InlEntry>, +d: U32, +cfid: U32, +args: List<&2, U32>, +nr: U32, +bud: U32, +acc: List<&2, IrOp>) -> InlOpsRes:
  match me:
    case None{}: InlOpsRes{Con{ICallDirect{d, cfid, args}, acc}, nr, bud}
    case Some{InlEntry{_, +car, cnr, cops, +rv}}:
      a1 = opt_inl_emit_args(args, nr, 0, acc)
      a2 = opt_inl_emit_body(nr, cops, a1)
      need = U32.max(cnr, U32.max(car, U32.add(rv, 1)))
      Bool.pick(InlOpsRes, U32.is_eq(b5k_u32_list_len(args), car), InlOpsRes{Con{ICopy{d, U32.add(nr, rv)}, a2}, U32.add(nr, need), U32.sub(bud, 1)}, InlOpsRes{Con{ICallDirect{d, cfid, args}, acc}, nr, bud})
def opt_inl_one_call(can: Bool, es: List<&2, InlEntry>, d: U32, +cfid: U32, args: List<&2, U32>, nr: U32, bud: U32, acc: List<&2, IrOp>) -> InlOpsRes:
  match can:
    case False{}: InlOpsRes{Con{ICallDirect{d, cfid, args}, acc}, nr, bud}
    case True{}: opt_inl_try_call(opt_find_inline(es, cfid), d, cfid, args, nr, bud, acc)
def opt_inl_ops_st(+self_fid: U32, +has: U32Map, +es: List<&2, InlEntry>, ops: List<&2, IrOp>, st: InlOpsRes) -> InlOpsRes:
  match ops st:
    case Nil{} InlOpsRes{acc, nr, bud}: InlOpsRes{b5k_list_rev(IrOp, acc), nr, bud}
    case Con{ICallDirect{d, +cfid, args}, t} InlOpsRes{acc, +nr, +bud}:
      can = Bool.and(U32.is_ne(cfid, self_fid), Bool.and(U32.is_gt(bud, 0), Bool.and(U32.is_lt(nr, 2048), U32.is_ne(um_get(has, cfid), 0))))
      opt_inl_ops_st(self_fid, has, es, t, opt_inl_one_call(can, es, d, cfid, args, nr, bud, acc))
    case Con{op, t} InlOpsRes{acc, nr, bud}:
      opt_inl_ops_st(self_fid, has, es, t, InlOpsRes{Con{op, acc}, nr, bud})
def opt_ior_ops(r: InlOpsRes) -> List<&2, IrOp>:
  match r:
    case InlOpsRes{ops, _, _}: ops
def opt_ior_nr(r: InlOpsRes) -> U32:
  match r:
    case InlOpsRes{_, nr, _}: nr
def opt_ior_bud(r: InlOpsRes) -> U32:
  match r:
    case InlOpsRes{_, _, bud}: bud
type InlBlksRes is Data:
  InlBlksRes{blks: List<&2, IrBlock>, nregs: U32}
def opt_inl_blks(+self_fid: U32, +has: U32Map, +es: List<&2, InlEntry>, blks: List<&2, IrBlock>, nr: U32, bud: U32, acc: List<&2, IrBlock>) -> InlBlksRes:
  match blks:
    case Nil{}: InlBlksRes{b5k_list_rev(IrBlock, acc), nr}
    case Con{IrBlock{id, ops, term}, t}:
      +r = opt_inl_ops_st(self_fid, has, es, ops, InlOpsRes{Nil{}, nr, bud})
      opt_inl_blks(self_fid, has, es, t, opt_ior_nr(r), opt_ior_bud(r), Con{IrBlock{id, opt_ior_ops(r), term}, acc})
def opt_inl_fn_fin(fid: U32, nm: String, ar: U32, esc: Bool, eff: Bool, is_m: Bool, r: InlBlksRes) -> IrFn:
  match r:
    case InlBlksRes{blks2, nr2}: IrFn{fid, nm, ar, nr2, esc, eff, is_m, blks2}
def opt_inl_fn(bank: InlBank, f: IrFn) -> IrFn:
  match bank f:
    case InlBank{has, es} IrFn{+fid, nm, ar, nregs, esc, eff, is_m, blks}:
      opt_inl_fn_fin(fid, nm, ar, esc, eff, is_m, opt_inl_blks(fid, has, es, blks, nregs, 32, Nil{}))
def opt_inl_all(+bank: InlBank, fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_inl_fn(bank, f), opt_inl_all(bank, t)}
# Top-Level -O2 Pipeline
# ----------------------
def opt_fn_local(+ret_sc: U32Map, f: IrFn) -> IrFn:
  opt_pass_cp_dce(opt_pass_cf(opt_pass_scalar(ret_sc, f)))
def opt_fns_local(+ret_sc: U32Map, fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_fn_local(ret_sc, f), opt_fns_local(ret_sc, t)}
def b5k_opt(prog: IrProg) -> IrProg:
  match prog:
    case IrProg{+fns, ctors, statics, main_fid, main_pure, effects, show_desc, show_names}:
      +ret_sc0 = opt_collect_ret_sc(fns, UM0{})
      +fns1 = opt_fns_local(ret_sc0, fns)
      bank = opt_collect_inlines(fns1, InlBank{UM0{}, Nil{}})
      +fns2 = opt_inl_all(bank, fns1)
      ret_sc1 = opt_collect_ret_sc(fns2, ret_sc0)
      fns3 = opt_fns_local(ret_sc1, fns2)
      IrProg{fns3, ctors, statics, main_fid, main_pure, effects, show_desc, show_names}
