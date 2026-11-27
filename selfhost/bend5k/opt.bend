# bend5k/opt.bend — Aggressive -O2 IR Optimizer (IrProg -> IrProg)
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
def opt_op_defs(op: IrOp, +m: U32Map) -> U32Map:
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
    case IKeep{+d, +s}: Bool.pick(U32Map, U32.is_eq(d, s), m, opt_um_inc(m, d))
    case IReuse{d, _, _, _}: opt_um_inc(m, d)
    case IStatic{d, _}: opt_um_inc(m, d)
    case IArrOp{ds, _, _}: opt_um_inc_list(ds, m)
    case IAlloca{d, _}: opt_um_inc(m, d)
    case ILoad{d, _, _}: opt_um_inc(m, d)
    case _: m
def opt_kill_op_dsts(op: IrOp, +m: U32Map) -> U32Map:
  match op:
    case IConst{d, _}: um_set(m, d, 0)
    case IFlt{d, _}: um_set(m, d, 0)
    case ICopy{d, _}: um_set(m, d, 0)
    case IBin{d, _, _, _}: um_set(m, d, 0)
    case IUn{d, _, _}: um_set(m, d, 0)
    case ICmp{d, _, _, _}: um_set(m, d, 0)
    case ICallDirect{d, _, _}: um_set(m, d, 0)
    case ICallClosure{d, _, _}: um_set(m, d, 0)
    case IApply{d, _, _}: um_set(m, d, 0)
    case ICtor{d, _, _}: um_set(m, d, 0)
    case ITake{ds, _}: opt_um_set_list(ds, 0, m)
    case ITag{d, _}: um_set(m, d, 0)
    case IKeep{+d, +s}: Bool.pick(U32Map, U32.is_eq(d, s), m, um_set(m, d, 0))
    case IReuse{d, _, _, _}: um_set(m, d, 0)
    case IStatic{d, _}: um_set(m, d, 0)
    case IArrOp{ds, _, _}: opt_um_set_list(ds, 0, m)
    case IAlloca{d, _}: um_set(m, d, 0)
    case ILoad{d, _, _}: um_set(m, d, 0)
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
    case IMutField{o, _, v}: opt_um_inc(opt_um_inc(m, o), v)
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
    case ICtor{d, _, Nil{}}: U32.add(d, 1)
    case _: 0
def opt_cp_can_prop(+defc: U32Map, +ar: U32, +r: U32) -> Bool:
  +dc = um_get(defc, r)
  Bool.pick(Bool, U32.is_lt(r, ar), U32.is_zero(dc), U32.is_le(dc, 1))
def opt_all_can_prop(+defc: U32Map, +ar: U32, xs: List<&2, U32>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{r, t}: Bool.and(opt_cp_can_prop(defc, ar, r), opt_all_can_prop(defc, ar, t))
# Pass 1 & Pass B — Interprocedural Scalar Inference & IKeep/ISink Elision
def opt_pkey(+fid: U32, +idx: U32) -> U32:
  U32.or(U32.shln(fid, 6n), idx)
def opt_sc_init_params(+fid: U32, +psc: U32Map, n: Nat, +idx: U32, m: U32Map) -> U32Map:
  match n:
    case 0n: m
    case 1n+p:
      ok = Bool.and(U32.is_lt(fid, 2048), Bool.and(U32.is_lt(idx, 64), U32.is_eq(um_get(psc, opt_pkey(fid, idx)), 1)))
      opt_sc_init_params(fid, psc, p, U32.add(idx, 1), um_set(m, idx, Bool.pick(U32, ok, 1, 2)))
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
    case ICallClosure{d, _, _}: um_set(m, d, 3)
    case IApply{d, _, _}: um_set(m, d, 2)
    case ICtor{d, _, _}: um_set(m, d, 3)
    case ITake{ds, _}: opt_um_set_list(ds, 2, m)
    case IReuse{d, _, _, _}: um_set(m, d, 3)
    case IStatic{d, _}: um_set(m, d, 3)
    case IArrOp{Con{r0, Con{r1, Nil{}}}, 75, _}: opt_sc_mark_scalar(um_set(m, r0, 3), r1)
    case IArrOp{ds, _, _}: opt_um_set_list(ds, 2, m)
    case IAlloca{d, _}: um_set(m, d, 3)
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
def opt_sc_prop_add(+defc: U32Map, +ar: U32, +a: U32, +b: U32, +m: U32Map) -> U32Map:
  +ma = um_get(m, a)
  +mb = um_get(m, b)
  +m1 = Bool.pick(U32Map, Bool.and(U32.is_eq(mb, 1), Bool.and(U32.is_ne(ma, 1), opt_cp_can_prop(defc, ar, a))), um_set(m, a, 1), m)
  Bool.pick(U32Map, Bool.and(U32.is_eq(ma, 1), Bool.and(U32.is_ne(mb, 1), opt_cp_can_prop(defc, ar, b))), um_set(m1, b, 1), m1)
def opt_sc_add_ops(+defc: U32Map, +ar: U32, ops: List<&2, IrOp>, +m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{IBin{_, 0, a, b}, t}: opt_sc_add_ops(defc, ar, t, opt_sc_prop_add(defc, ar, a, b, m))
    case Con{IBin{_, +bop, +a, +b}, t}:
      m1 = Bool.pick(U32Map, Bool.and(U32.is_ge(bop, 1), U32.is_le(bop, 9)), um_set(um_set(m, a, 1), b, 1), m)
      opt_sc_add_ops(defc, ar, t, m1)
    case Con{IUn{_, +uop, +s}, t}:
      m1 = Bool.pick(U32Map, U32.is_le(uop, 1), um_set(m, s, 1), m)
      opt_sc_add_ops(defc, ar, t, m1)
    case Con{ICmp{_, +cop, +a, +b}, t}:
      m1 = Bool.pick(U32Map, Bool.and(U32.is_ge(cop, 2), Bool.and(U32.is_le(cop, 5), Bool.and(U32.is_ne(um_get(m, a), 3), U32.is_ne(um_get(m, b), 3)))), um_set(um_set(m, a, 1), b, 1), m)
      opt_sc_add_ops(defc, ar, t, m1)
    case Con{ICopy{d, +s}, t}:
      m1 = Bool.pick(U32Map, Bool.and(U32.is_eq(um_get(m, d), 1), U32.is_ne(um_get(m, s), 3)), um_set(m, s, 1), m)
      opt_sc_add_ops(defc, ar, t, m1)
    case Con{IKeep{d, +s}, t}:
      m1 = Bool.pick(U32Map, Bool.and(U32.is_eq(um_get(m, d), 1), U32.is_ne(um_get(m, s), 3)), um_set(m, s, 1), m)
      opt_sc_add_ops(defc, ar, t, m1)
    case Con{_, t}: opt_sc_add_ops(defc, ar, t, m)
def opt_sc_add_blks(+defc: U32Map, +ar: U32, blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, _}, t}: opt_sc_add_blks(defc, ar, t, opt_sc_add_ops(defc, ar, ops, m))
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
def opt_sc_add_n(k: Nat, +defc: U32Map, +ar: U32, +blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match k:
    case 0n: m
    case 1n+p: opt_sc_add_n(p, defc, ar, blks, opt_sc_add_blks(defc, ar, blks, m))
def opt_sc_compute_fin(small: Bool, +ar: U32, +blks: List<&2, IrBlock>, m1: U32Map) -> U32Map:
  match small:
    case False{}: m1
    case True{}: opt_sc_add_n(6n, opt_blks_defs(blks, UM0{}), ar, blks, m1)
def opt_sc_compute(+small: Bool, +ret_sc: U32Map, +psc: U32Map, +fid: U32, +ar: U32, +blks: List<&2, IrBlock>) -> U32Map:
  m0 = opt_sc_direct_blks(ret_sc, blks, opt_sc_init_params(fid, psc, U32.to_nat(ar), 0, UM0{}))
  +pn = Bool.pick(Nat, small, 2n, 1n)
  m1 = opt_sc_prop_n(pn, True{}, blks, opt_sc_prop_n(pn, False{}, blks, m0))
  opt_sc_compute_fin(Bool.and(small, U32.is_ge(fid, 3)), ar, blks, m1)
def opt_sc_elide_keep(is_sc: Bool, +d: U32, +s: U32, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match is_sc:
    case False{}: Con{IKeep{d, s}, acc}
    case True{}: Bool.pick(List<&2, IrOp>, U32.is_eq(d, s), acc, Con{ICopy{d, s}, acc})
def opt_sc_rewrite_ops(+sc: U32Map, ops: List<&2, IrOp>, +cm: U32Map, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: b5k_list_rev(IrOp, acc)
    case Con{IKeep{+d, +s}, t}:
      opt_sc_rewrite_ops(sc, t, um_set(cm, d, 0), opt_sc_elide_keep(U32.is_eq(um_get(sc, s), 1), d, s, acc))
    case Con{ISink{+s}, t}:
      acc2 = Bool.pick(List<&2, IrOp>, U32.is_eq(um_get(sc, s), 1), acc, Con{ISink{s}, acc})
      opt_sc_rewrite_ops(sc, t, cm, acc2)
    case Con{ITag{+d, +s}, t}:
      op2 = Bool.pick(IrOp, U32.is_eq(um_get(sc, s), 1), IConst{d, 0}, ITag{d, s})
      opt_sc_rewrite_ops(sc, t, um_set(cm, d, 0), Con{op2, acc})
    case Con{ICmp{+d, +cop, +a, +b}, t}:
      disj = Bool.and(U32.is_le(cop, 1), Bool.or(Bool.and(U32.is_eq(um_get(sc, a), 1), U32.is_ne(um_get(cm, b), 0)), Bool.and(U32.is_eq(um_get(sc, b), 1), U32.is_ne(um_get(cm, a), 0))))
      op2 = Bool.pick(IrOp, disj, IConst{d, cop}, ICmp{d, cop, a, b})
      opt_sc_rewrite_ops(sc, t, um_set(cm, d, 0), Con{op2, acc})
    case Con{ICtor{+d, cid, fs}, t}:
      opt_sc_rewrite_ops(sc, t, um_set(cm, d, 1), Con{ICtor{d, cid, fs}, acc})
    case Con{IReuse{+d, sl, cid, fs}, t}:
      opt_sc_rewrite_ops(sc, t, um_set(cm, d, 1), Con{IReuse{d, sl, cid, fs}, acc})
    case Con{IArrOp{+ds, 73, Con{a, Con{i, Con{+v, Nil{}}}}}, t}:
      opt_sc_rewrite_ops(sc, t, opt_um_set_list(ds, 0, cm), Con{IArrOp{ds, Bool.pick(U32, U32.is_eq(um_get(sc, v), 1), 79, 73), [a, i, v]}, acc})
    case Con{+op, t}:
      opt_sc_rewrite_ops(sc, t, opt_kill_op_dsts(op, cm), Con{op, acc})
def opt_sc_rewrite_blks(+sc: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}:
      Con{IrBlock{id, opt_sc_rewrite_ops(sc, ops, UM0{}, Nil{}), term}, opt_sc_rewrite_blks(sc, t)}
def opt_sc_all_rets(+self_fid: U32, +ret_sc: U32Map, +sc: U32Map, blks: List<&2, IrBlock>, has_ret: Bool) -> Bool:
  match blks:
    case Nil{}: has_ret
    case Con{IrBlock{_, _, TRet{rv}}, t}:
      Bool.and(U32.is_eq(um_get(sc, rv), 1), opt_sc_all_rets(self_fid, ret_sc, sc, t, True{}))
    case Con{IrBlock{_, _, TTailCall{+cfid, _}}, t}:
      +is_other_sc = Bool.and(U32.is_ne(cfid, self_fid), U32.is_ne(um_get(ret_sc, cfid), 0))
      ok = Bool.or(U32.is_eq(cfid, self_fid), is_other_sc)
      Bool.and(ok, opt_sc_all_rets(self_fid, ret_sc, sc, t, Bool.or(has_ret, is_other_sc)))
    case Con{IrBlock{_, _, _}, t}: opt_sc_all_rets(self_fid, ret_sc, sc, t, has_ret)
def opt_ip_init_orig(n: Nat, +idx: U32, m: U32Map) -> U32Map:
  match n:
    case 0n: m
    case 1n+p: opt_ip_init_orig(p, U32.add(idx, 1), um_set(m, idx, U32.add(idx, 1)))
def opt_ip_orig_step(+defc: U32Map, +ar: U32, +d: U32, s: U32, +m0: U32Map) -> U32Map:
  +os = um_get(m0, s)
  ok = Bool.and(U32.is_ne(os, 0), Bool.and(U32.is_ge(d, ar), U32.is_eq(um_get(defc, d), 1)))
  Bool.pick(U32Map, ok, um_set(m0, d, os), m0)
def opt_ip_orig_ops(+defc: U32Map, +ar: U32, ops: List<&2, IrOp>, m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{ICopy{d, s}, t}: opt_ip_orig_ops(defc, ar, t, opt_ip_orig_step(defc, ar, d, s, m))
    case Con{IKeep{d, s}, t}: opt_ip_orig_ops(defc, ar, t, opt_ip_orig_step(defc, ar, d, s, m))
    case Con{_, t}: opt_ip_orig_ops(defc, ar, t, m)
def opt_ip_orig_blks(+defc: U32Map, +ar: U32, blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, _}, t}: opt_ip_orig_blks(defc, ar, t, opt_ip_orig_ops(defc, ar, ops, m))
def opt_ip_bad_ops(ops: List<&2, IrOp>, m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{ICallClosure{_, fid, _}, t}: opt_ip_bad_ops(t, um_set(m, fid, 1))
    case Con{_, t}: opt_ip_bad_ops(t, m)
def opt_ip_bad_blks(blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, _}, t}: opt_ip_bad_blks(t, opt_ip_bad_ops(ops, m))
def opt_ip_bad_fns(fns: List<&2, IrFn>, +m: U32Map) -> U32Map:
  match fns:
    case Nil{}: m
    case Con{IrFn{+fid, _, _, _, esc, _, is_m, blks}, t}:
      bad = Bool.or(U32.is_lt(fid, 3), Bool.or(U32.is_ge(fid, 2048), Bool.or(esc, is_m)))
      m1 = Bool.pick(U32Map, bad, um_set(m, fid, 1), m)
      opt_ip_bad_fns(t, opt_ip_bad_blks(blks, m1))
def opt_ip_obs_args(+self_fid: U32, +cfid: U32, +sc: U32Map, +orig: U32Map, args: List<&2, U32>, +idx: U32, obs: U32Map) -> U32Map:
  match args:
    case Nil{}: obs
    case Con{+a, t}:
      +obs0 = obs
      is_self_pass = Bool.and(U32.is_eq(cfid, self_fid), U32.is_eq(um_get(orig, a), U32.add(idx, 1)))
      ok_range = Bool.and(U32.is_lt(cfid, 2048), U32.is_lt(idx, 64))
      +k = opt_pkey(cfid, idx)
      +cur = um_get(obs0, k)
      +nv = Bool.pick(U32, U32.is_eq(um_get(sc, a), 1), Bool.pick(U32, U32.is_zero(cur), 1, cur), 2)
      obs1 = Bool.pick(U32Map, Bool.and(ok_range, Bool.not(is_self_pass)), um_set(obs0, k, nv), obs0)
      opt_ip_obs_args(self_fid, cfid, sc, orig, t, U32.add(idx, 1), obs1)
def opt_ip_obs_ops(+self_fid: U32, +sc: U32Map, +orig: U32Map, ops: List<&2, IrOp>, obs: U32Map) -> U32Map:
  match ops:
    case Nil{}: obs
    case Con{ICallDirect{_, cfid, args}, t}:
      opt_ip_obs_ops(self_fid, sc, orig, t, opt_ip_obs_args(self_fid, cfid, sc, orig, args, 0, obs))
    case Con{_, t}: opt_ip_obs_ops(self_fid, sc, orig, t, obs)
def opt_ip_obs_blks(+self_fid: U32, +sc: U32Map, +orig: U32Map, blks: List<&2, IrBlock>, obs: U32Map) -> U32Map:
  match blks:
    case Nil{}: obs
    case Con{IrBlock{_, ops, TTailCall{cfid, args}}, t}:
      obs1 = opt_ip_obs_ops(self_fid, sc, orig, ops, obs)
      opt_ip_obs_blks(self_fid, sc, orig, t, opt_ip_obs_args(self_fid, cfid, sc, orig, args, 0, obs1))
    case Con{IrBlock{_, ops, _}, t}:
      opt_ip_obs_blks(self_fid, sc, orig, t, opt_ip_obs_ops(self_fid, sc, orig, ops, obs))
type IpRes is Data:
  IpRes{ret_sc: U32Map, psc: U32Map, chg: Bool}
def opt_ip_promote_params(+fid: U32, +obs: U32Map, n: Nat, +idx: U32, ret_sc: U32Map, psc: U32Map, chg: Bool) -> IpRes:
  match n:
    case 0n: IpRes{ret_sc, psc, chg}
    case 1n+p:
      +psc0 = psc
      +k = opt_pkey(fid, idx)
      +prom = Bool.and(U32.is_lt(idx, 64), Bool.and(U32.is_zero(um_get(psc0, k)), U32.is_eq(um_get(obs, k), 1)))
      opt_ip_promote_params(fid, obs, p, U32.add(idx, 1), ret_sc, Bool.pick(U32Map, prom, um_set(psc0, k, 1), psc0), Bool.or(chg, prom))
def opt_ip_prom_one(ok: Bool, +fid: U32, +obs: U32Map, ar: U32, ret_sc: U32Map, psc: U32Map, chg: Bool) -> IpRes:
  match ok:
    case False{}: IpRes{ret_sc, psc, chg}
    case True{}: opt_ip_promote_params(fid, obs, U32.to_nat(U32.min(ar, 64)), 0, ret_sc, psc, chg)
def opt_ip_promote_fns(+bad: U32Map, +obs: U32Map, fns: List<&2, IrFn>, st: IpRes) -> IpRes:
  match fns st:
    case Nil{} _: st
    case Con{IrFn{+fid, _, ar, _, _, _, _, _}, t} IpRes{ret_sc, psc, chg}:
      opt_ip_promote_fns(bad, obs, t, opt_ip_prom_one(U32.is_zero(um_get(bad, fid)), fid, obs, ar, ret_sc, psc, chg))
type IpScan is Data:
  IpScan{ret_sc: U32Map, obs: U32Map, chg: Bool}
def opt_ip_add_dep_blks(blks: List<&2, IrBlock>, +m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, Con{IBin{+t2, 0, +va, _}, Con{ICopy{+dst, +s}, Nil{}}}, TJmp{_}}, t}:
      +oa = um_get(m, va)
      ok = Bool.and(U32.is_eq(t2, s), Bool.and(U32.is_ne(oa, 0), U32.is_zero(um_get(m, dst))))
      opt_ip_add_dep_blks(t, Bool.pick(U32Map, ok, um_set(m, dst, oa), m))
    case Con{_, t}: opt_ip_add_dep_blks(t, m)
def opt_ip_scan_fns(+small: Bool, +psc: U32Map, fns: List<&2, IrFn>, st: IpScan) -> IpScan:
  match fns st:
    case Nil{} _: st
    case Con{IrFn{+fid, _, +ar, _, _, _, _, +blks}, t} IpScan{+ret_sc, obs, chg}:
      +sc = opt_sc_compute(small, ret_sc, psc, fid, ar, blks)
      defc = opt_blks_defs(blks, UM0{})
      orig0 = opt_ip_orig_blks(defc, ar, blks, opt_ip_init_orig(U32.to_nat(ar), 0, UM0{}))
      orig = opt_ip_add_dep_blks(blks, orig0)
      obs1 = opt_ip_obs_blks(fid, sc, orig, blks, obs)
      +new_ret = Bool.and(U32.is_ge(fid, 3), Bool.and(U32.is_zero(um_get(ret_sc, fid)), opt_sc_all_rets(fid, ret_sc, sc, blks, False{})))
      ret1 = Bool.pick(U32Map, new_ret, um_set(ret_sc, fid, 1), ret_sc)
      opt_ip_scan_fns(small, psc, t, IpScan{ret1, obs1, Bool.or(chg, new_ret)})
def opt_ip_step(+bad: U32Map, +fns: List<&2, IrFn>, psc0: U32Map, sc: IpScan) -> IpRes:
  match sc:
    case IpScan{ret1, obs1, chg1}: opt_ip_promote_fns(bad, obs1, fns, IpRes{ret1, psc0, chg1})
def opt_ip_fix(fuel: Nat, +small: Bool, +bad: U32Map, +fns: List<&2, IrFn>, st: IpRes) -> IpRes:
  match fuel st:
    case 0n _: st
    case _ IpRes{ret_sc, psc, False{}}: IpRes{ret_sc, psc, False{}}
    case 1n+p IpRes{ret_sc, +psc0, True{}}:
      opt_ip_fix(p, small, bad, fns, opt_ip_step(bad, fns, psc0, opt_ip_scan_fns(small, psc0, fns, IpScan{ret_sc, UM0{}, False{}})))
def opt_collect_ip(+small: Bool, +fns: List<&2, IrFn>, ret_sc: U32Map) -> IpRes:
  bad = opt_ip_bad_fns(fns, UM0{})
  fuel = Bool.pick(Nat, small, 16n, 1n)
  opt_ip_fix(fuel, small, bad, fns, IpRes{ret_sc, UM0{}, True{}})
def opt_collect_ret_only(fns: List<&2, IrFn>, m: U32Map) -> U32Map:
  match fns:
    case Nil{}: m
    case Con{IrFn{+fid, _, +ar, _, _, _, _, +blks}, t}:
      +m0 = m
      sc = opt_sc_compute(True{}, m0, UM0{}, fid, ar, blks)
      m1 = Bool.pick(U32Map, Bool.and(U32.is_ge(fid, 3), opt_sc_all_rets(fid, m0, sc, blks, False{})), um_set(m0, fid, 1), m0)
      opt_collect_ret_only(t, m1)
def opt_sc_rw_fast_ops(+sc: U32Map, ops: List<&2, IrOp>, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: b5k_list_rev(IrOp, acc)
    case Con{IKeep{+d, +s}, t}: opt_sc_rw_fast_ops(sc, t, opt_sc_elide_keep(U32.is_eq(um_get(sc, s), 1), d, s, acc))
    case Con{ISink{+s}, t}: opt_sc_rw_fast_ops(sc, t, Bool.pick(List<&2, IrOp>, U32.is_eq(um_get(sc, s), 1), acc, Con{ISink{s}, acc}))
    case Con{ITag{+d, +s}, t}: opt_sc_rw_fast_ops(sc, t, Con{Bool.pick(IrOp, U32.is_eq(um_get(sc, s), 1), IConst{d, 0}, ITag{d, s}), acc})
    case Con{op, t}: opt_sc_rw_fast_ops(sc, t, Con{op, acc})
def opt_sc_rw_fast_blks(+sc: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}: Con{IrBlock{id, opt_sc_rw_fast_ops(sc, ops, Nil{}), term}, opt_sc_rw_fast_blks(sc, t)}
def opt_sc_rw_pick(small: Bool, sc: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match small:
    case True{}: opt_sc_rewrite_blks(sc, blks)
    case False{}: opt_sc_rw_fast_blks(sc, blks)
def opt_pass_scalar(+small: Bool, +ret_sc: U32Map, +psc: U32Map, f: IrFn) -> IrFn:
  match f:
    case IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, +blks}:
      sc = opt_sc_compute(small, ret_sc, psc, fid, ar, blks)
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_sc_rw_pick(small, sc, blks)}
# Pass A — Local Constructor-Take Fusion (SROA)
type CtorEnt is Data:
  CtorNone{}
  CtorSome{vreg: U32, fs: List<&2, U32>}
def sroa_tag_ops(ops: List<&2, IrOp>, cids: U32Map, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: b5k_list_rev(IrOp, acc)
    case Con{ICtor{+d, +cid, fs}, t}:
      sroa_tag_ops(t, um_set(cids, d, U32.add(cid, 1)), Con{ICtor{d, cid, fs}, acc})
    case Con{IReuse{+d, sl, +cid, fs}, t}:
      sroa_tag_ops(t, um_set(cids, d, U32.add(cid, 1)), Con{IReuse{d, sl, cid, fs}, acc})
    case Con{ITag{+d, +s}, t}:
      +cids0 = cids
      +got = um_get(cids0, s)
      op2 = Bool.pick(IrOp, U32.is_ne(got, 0), IConst{d, U32.sub(got, 1)}, ITag{d, s})
      sroa_tag_ops(t, um_set(cids0, d, 0), Con{op2, acc})
    case Con{IArrOp{Con{+r0, Con{+r1, Nil{}}}, 72, Con{+a, Con{+i, Nil{}}}}, t}:
      +ok = U32.is_ne(r1, a)
      cids1 = opt_kill_op_dsts(IArrOp{[r0, r1], 72, [a, i]}, cids)
      acc1 = Bool.pick(List<&2, IrOp>, ok, Con{ICopy{r0, a}, Con{IArrOp{[r1], 78, [a, i]}, acc}}, Con{IArrOp{[r0, r1], 72, [a, i]}, acc})
      sroa_tag_ops(t, cids1, acc1)
    case Con{+op, t}:
      sroa_tag_ops(t, opt_kill_op_dsts(op, cids), Con{op, acc})
def sroa_tag_blks(blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}:
      Con{IrBlock{id, sroa_tag_ops(ops, UM0{}, Nil{}), term}, sroa_tag_blks(t)}
def sroa_emit_copies(ds: List<&2, U32>, fs: List<&2, U32>, acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ds fs:
    case Con{d, dt} Con{f, ft}: sroa_emit_copies(dt, ft, Con{ICopy{d, f}, acc})
    case _ _: acc
def sroa_emit_sinks(fs: List<&2, U32>, acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match fs:
    case Nil{}: acc
    case Con{f, ft}: sroa_emit_sinks(ft, Con{ISink{f}, acc})
type SroaRes is Data:
  SroaRes{ops_rev: List<&2, IrOp>, fused: U32Map}
def sroa_drop_fused(+fused: U32Map, ops_rev: List<&2, IrOp>, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops_rev:
    case Nil{}: acc
    case Con{ICtor{+d, cid, fs}, t}:
      acc1 = Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(fused, d), 0), acc, Con{ICtor{d, cid, fs}, acc})
      sroa_drop_fused(fused, t, acc1)
    case Con{op, t}: sroa_drop_fused(fused, t, Con{op, acc})
def sroa_put_ctor(ok: Bool, cmap: RaVec<CtorEnt>, +d: U32, fs: List<&2, U32>) -> RaVec<CtorEnt>:
  match ok:
    case True{}: ra_vec_set(CtorEnt, 6n, d, CtorSome{d, fs}, cmap)
    case False{}: cmap
def sroa_do_take(ce: CtorEnt, +ds: List<&2, U32>, +s: U32, +fused: U32Map, +acc: List<&2, IrOp>) -> SroaRes:
  match ce:
    case CtorSome{v, +fs}:
      +ok = Bool.and(U32.is_eq(v, s), U32.is_eq(b5k_u32_list_len(ds), b5k_u32_list_len(fs)))
      SroaRes{Bool.pick(List<&2, IrOp>, ok, sroa_emit_copies(ds, fs, acc), Con{ITake{ds, s}, acc}), Bool.pick(U32Map, ok, um_set(fused, s, 1), fused)}
    case CtorNone{}: SroaRes{Con{ITake{ds, s}, acc}, fused}
def sroa_do_sink(ce: CtorEnt, +s: U32, +fused: U32Map, +acc: List<&2, IrOp>) -> SroaRes:
  match ce:
    case CtorSome{v, fs}:
      +ok = U32.is_eq(v, s)
      SroaRes{Bool.pick(List<&2, IrOp>, ok, sroa_emit_sinks(fs, acc), Con{ISink{s}, acc}), Bool.pick(U32Map, ok, um_set(fused, s, 1), fused)}
    case CtorNone{}: SroaRes{Con{ISink{s}, acc}, fused}
def sroa_fuse_ops(+defc: U32Map, +uses: U32Map, +ar: U32, ops: List<&2, IrOp>, cmap: RaVec<CtorEnt>, st: SroaRes) -> SroaRes:
  match ops st:
    case Nil{} _: st
    case Con{ICtor{+d, cid, +fs}, t} SroaRes{acc, fused}:
      ok = Bool.and(U32.is_lt(d, 4096), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(U32.is_eq(um_get(uses, d), 1), opt_all_can_prop(defc, ar, fs))))
      sroa_fuse_ops(defc, uses, ar, t, sroa_put_ctor(ok, cmap, d, fs), SroaRes{Con{ICtor{d, cid, fs}, acc}, fused})
    case Con{ITake{ds, +s}, t} SroaRes{acc, fused}:
      +cm0 = cmap
      sroa_fuse_ops(defc, uses, ar, t, cm0, sroa_do_take(ra_vec_get(CtorEnt, 6n, CtorNone{}, s, cm0), ds, s, fused, acc))
    case Con{ISink{+s}, t} SroaRes{acc, fused}:
      +cm0 = cmap
      sroa_fuse_ops(defc, uses, ar, t, cm0, sroa_do_sink(ra_vec_get(CtorEnt, 6n, CtorNone{}, s, cm0), s, fused, acc))
    case Con{op, t} SroaRes{acc, fused}: sroa_fuse_ops(defc, uses, ar, t, cmap, SroaRes{Con{op, acc}, fused})
def sroa_blk_fin(id: U32, term: IrTerm, r: SroaRes) -> IrBlock:
  match r:
    case SroaRes{rev, fused}: IrBlock{id, sroa_drop_fused(fused, rev, Nil{}), term}
def sroa_fuse_blks(+defc: U32Map, +uses: U32Map, +ar: U32, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}:
      Con{sroa_blk_fin(id, term, sroa_fuse_ops(defc, uses, ar, ops, RVEmpty{}, SroaRes{Nil{}, UM0{}})), sroa_fuse_blks(defc, uses, ar, t)}
def opt_pass_sroa_tag(f: IrFn) -> IrFn:
  match f:
    case IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}:
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, sroa_tag_blks(blks)}
def opt_pass_sroa_fuse(f: IrFn) -> IrFn:
  match f:
    case IrFn{fid, nm, +ar, nregs, esc, eff, is_m, +blks}:
      defc = opt_blks_defs(blks, UM0{})
      uses = opt_blks_uses(blks, UM0{})
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, sroa_fuse_blks(defc, uses, ar, blks)}
# Pass 2 — Constant Folding & Strength Reduction
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
def cf_emit_mod255(has: U32Map, val: U32Map, +nr: U32, rev: List<&2, IrOp>, +d: U32, +a: U32, +b: U32, +cb: U32) -> CfSt:
  +m = U32.div(U32.add(65535, cb), cb)
  +r0 = nr
  +r1 = U32.add(nr, 1)
  +r2 = U32.add(nr, 2)
  +r3 = U32.add(nr, 3)
  +r4 = U32.add(nr, 4)
  +r5 = U32.add(nr, 5)
  +r6 = U32.add(nr, 6)
  +r7 = U32.add(nr, 7)
  +r8 = U32.add(nr, 8)
  +r9 = U32.add(nr, 9)
  +r10 = U32.add(nr, 10)
  +r11 = U32.add(nr, 11)
  +r12 = U32.add(nr, 12)
  +r13 = U32.add(nr, 13)
  o1 : List<&2, IrOp> = Con{IBin{r4, 0, r1, r3}, Con{IBin{r3, 9, a, r2}, Con{IConst{r2, 16}, Con{IBin{r1, 5, a, r0}, Con{IConst{r0, 65535}, rev}}}}}
  o2 : List<&2, IrOp> = Con{IBin{r9, 0, r6, r8}, Con{IBin{r8, 9, r4, r7}, Con{IConst{r7, 8}, Con{IBin{r6, 5, r4, r5}, Con{IConst{r5, 255}, o1}}}}}
  o3 : List<&2, IrOp> = Con{IBin{d, 1, r9, r13}, Con{IBin{r13, 2, r12, b}, Con{IBin{r12, 9, r11, r2}, Con{IBin{r11, 2, r9, r10}, Con{IConst{r10, m}, o2}}}}}
  CfSt{um_set(has, d, 0), val, U32.add(nr, 14), o3}
def cf_bin_mod_go(is1: Bool, +has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +a: U32, +b: U32, +cb: U32) -> CfSt:
  match is1:
    case True{}: cf_emit_const(has, val, nr, rev, d, 0)
    case False{}:
      +p2 = opt_pow2_log(cb)
      +is255 = Bool.and(U32.is_ge(cb, 15), Bool.and(U32.is_le(cb, 85), U32.is_zero(U32.mod(255, cb))))
      Bool.pick(CfSt, U32.is_ne(p2, 0), cf_emit_sr(has, val, nr, rev, d, B5K_OP_AND(), a, U32.sub(cb, 1)),
        Bool.pick(CfSt, is255, cf_emit_mod255(has, val, nr, rev, d, a, b, cb),
          CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 4, a, b}, rev}}))
def cf_bin_rhs_const(+has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32, +b: U32, +cb: U32) -> CfSt:
  match op:
    case 0: Bool.pick(CfSt, U32.is_zero(cb), cf_emit_copy(has, val, nr, rev, d, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 0, a, b}, rev}})
    case 1: Bool.pick(CfSt, U32.is_zero(cb), cf_emit_copy(has, val, nr, rev, d, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 1, a, b}, rev}})
    case 2: cf_bin_mul_go(U32.is_zero(cb), U32.is_eq(cb, 1), has, val, nr, rev, d, a, b, a, cb)
    case 3: cf_bin_div_go(U32.is_eq(cb, 1), has, val, nr, rev, d, a, b, cb)
    case 4: cf_bin_mod_go(U32.is_eq(cb, 1), has, val, nr, rev, d, a, b, cb)
    case 5:
      Bool.pick(CfSt, U32.is_zero(cb), cf_emit_const(has, val, nr, rev, d, 0),
        Bool.pick(CfSt, U32.is_eq(cb, 4294967295), cf_emit_copy(has, val, nr, rev, d, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 5, a, b}, rev}}))
    case 6:
      Bool.pick(CfSt, U32.is_zero(cb), cf_emit_copy(has, val, nr, rev, d, a),
        Bool.pick(CfSt, U32.is_eq(cb, 4294967295), cf_emit_const(has, val, nr, rev, d, 4294967295), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 6, a, b}, rev}}))
    case 7:
      Bool.pick(CfSt, U32.is_zero(cb), cf_emit_copy(has, val, nr, rev, d, a),
        Bool.pick(CfSt, U32.is_eq(cb, 4294967295), CfSt{um_set(has, d, 0), val, nr, Con{IUn{d, 1, a}, rev}}, CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 7, a, b}, rev}}))
    case 8: Bool.pick(CfSt, U32.is_zero(cb), cf_emit_copy(has, val, nr, rev, d, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 8, a, b}, rev}})
    case _: Bool.pick(CfSt, U32.is_zero(cb), cf_emit_copy(has, val, nr, rev, d, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, op, a, b}, rev}})
def cf_bin_lhs_const(+has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32, +b: U32, +ca: U32) -> CfSt:
  match op:
    case 0: Bool.pick(CfSt, U32.is_zero(ca), cf_emit_copy(has, val, nr, rev, d, b), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 0, a, b}, rev}})
    case 1: Bool.pick(CfSt, U32.is_zero(ca), CfSt{um_set(has, d, 0), val, nr, Con{IUn{d, 0, b}, rev}}, CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 1, a, b}, rev}})
    case 2: cf_bin_mul_go(U32.is_zero(ca), U32.is_eq(ca, 1), has, val, nr, rev, d, a, b, b, ca)
    case 5:
      Bool.pick(CfSt, U32.is_zero(ca), cf_emit_const(has, val, nr, rev, d, 0),
        Bool.pick(CfSt, U32.is_eq(ca, 4294967295), cf_emit_copy(has, val, nr, rev, d, b), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 5, a, b}, rev}}))
    case 6:
      Bool.pick(CfSt, U32.is_zero(ca), cf_emit_copy(has, val, nr, rev, d, b),
        Bool.pick(CfSt, U32.is_eq(ca, 4294967295), cf_emit_const(has, val, nr, rev, d, 4294967295), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 6, a, b}, rev}}))
    case 7:
      Bool.pick(CfSt, U32.is_zero(ca), cf_emit_copy(has, val, nr, rev, d, b),
        Bool.pick(CfSt, U32.is_eq(ca, 4294967295), CfSt{um_set(has, d, 0), val, nr, Con{IUn{d, 1, b}, rev}}, CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 7, a, b}, rev}}))
    case 8: Bool.pick(CfSt, U32.is_zero(ca), cf_emit_const(has, val, nr, rev, d, 0), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 8, a, b}, rev}})
    case 9: Bool.pick(CfSt, U32.is_zero(ca), cf_emit_const(has, val, nr, rev, d, 0), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 9, a, b}, rev}})
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
def opt_u2f_bits(+c: U32) -> U32:
  match c:
    case 0: 0
    case +n:
      +e = U32.from_nat(U32.log2(n))
      +hi = U32.is_gt(e, 23)
      +sh = Bool.pick(U32, hi, U32.sub(e, 23), 0)
      +q0 = U32.shrn(n, U32.to_nat(sh))
      +rem = U32.and(n, U32.sub(U32.shln(1, U32.to_nat(sh)), 1))
      +half = Bool.pick(U32, hi, U32.shln(1, U32.to_nat(U32.sub(sh, 1))), 0)
      +rnd = Bool.and(hi, Bool.or(U32.is_gt(rem, half), Bool.and(U32.is_eq(rem, half), U32.is_eq(U32.and(q0, 1), 1))))
      +q1 = Bool.pick(U32, rnd, U32.add(q0, 1), q0)
      +ov = Bool.and(hi, U32.is_eq(q1, 16777216))
      +exp = U32.add(127, Bool.pick(U32, ov, U32.add(e, 1), e))
      +mant = Bool.pick(U32, hi, Bool.pick(U32, ov, 0, U32.and(q1, 8388607)), U32.and(U32.shln(n, U32.to_nat(U32.sub(23, e))), 8388607))
      U32.or(U32.shln(exp, 23n), mant)
def opt_f32_to_small_u32(+bits: U32) -> U32:
  +exp = U32.shrn(bits, 23n)
  +ok_e = Bool.and(U32.is_ge(exp, 127), U32.is_le(exp, 142))
  +sh = Bool.pick(U32, ok_e, U32.sub(150, exp), 0)
  +mant = U32.and(bits, 8388607)
  +lmask = U32.sub(U32.shln(1, U32.to_nat(sh)), 1)
  Bool.pick(U32, Bool.and(ok_e, U32.is_zero(U32.and(mant, lmask))), U32.shrn(U32.or(8388608, mant), U32.to_nat(sh)), 0)
type OptFdiv is Data:
  OptFdiv{a: U32, b: U32, e: U32}
def opt_fdiv_up(fuel: Nat, lt: Bool, +a: U32, +b: U32, +exp: U32) -> OptFdiv:
  match fuel lt:
    case 0n _: OptFdiv{a, b, exp}
    case _ False{}: OptFdiv{a, b, exp}
    case 1n+p True{}:
      +a1 = U32.shln(a, 1n)
      opt_fdiv_up(p, U32.is_lt(a1, b), a1, b, U32.sub(exp, 1))
def opt_fdiv_dn(fuel: Nat, ge: Bool, +a: U32, +b: U32, +exp: U32) -> OptFdiv:
  match fuel ge:
    case 0n _: OptFdiv{a, b, exp}
    case _ False{}: OptFdiv{a, b, exp}
    case 1n+p True{}:
      +b1 = U32.shln(b, 1n)
      opt_fdiv_dn(p, U32.is_ge(a, U32.shln(b1, 1n)), a, b1, U32.add(exp, 1))
def opt_fdiv_loop(n: Nat, +a: U32, +b: U32, +q: U32) -> OptFdiv:
  match n:
    case 0n: OptFdiv{a, b, q}
    case 1n+p:
      +a1 = U32.shln(a, 1n)
      +ge = U32.is_ge(a1, b)
      opt_fdiv_loop(p, Bool.pick(U32, ge, U32.sub(a1, b), a1), b, Bool.pick(U32, ge, U32.or(U32.shln(q, 1n), 1), U32.shln(q, 1n)))
def opt_fdiv_s3(st: OptFdiv, +e2: U32) -> U32:
  match st:
    case OptFdiv{rem, +b2, +q0}:
      +r2 = U32.shln(rem, 1n)
      rnd = Bool.or(U32.is_gt(r2, b2), Bool.and(U32.is_eq(r2, b2), U32.is_eq(U32.and(q0, 1), 1)))
      +q1 = Bool.pick(U32, rnd, U32.add(q0, 1), q0)
      +ov = U32.is_eq(q1, 8388608)
      U32.or(U32.shln(Bool.pick(U32, ov, U32.add(e2, 1), e2), 23n), Bool.pick(U32, ov, 0, q1))
def opt_fdiv_s2(st: OptFdiv) -> U32:
  match st:
    case OptFdiv{a2, +b2, e2}: opt_fdiv_s3(opt_fdiv_loop(23n, U32.sub(a2, b2), b2, 0), e2)
def opt_fdiv_s1(st: OptFdiv) -> U32:
  match st:
    case OptFdiv{+a1, +b1, e1}: opt_fdiv_s2(opt_fdiv_dn(20n, U32.is_ge(a1, U32.shln(b1, 1n)), a1, b1, e1))
def opt_fdiv_bits(+a0: U32, +b0: U32) -> U32:
  opt_fdiv_s1(opt_fdiv_up(20n, U32.is_lt(a0, b0), a0, b0, 127))
def cf_emit_flt(has: U32Map, val: U32Map, nregs: U32, rev: List<&2, IrOp>, +d: U32, +bits: U32) -> CfSt:
  CfSt{um_set(has, d, 2), um_set(val, d, bits), nregs, Con{IFlt{d, bits}, rev}}
def cf_step_bin_flt(is_flt: Bool, +has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32, +b: U32) -> CfSt:
  match is_flt:
    case True{}:
      +fok = Bool.and(U32.is_eq(um_get(has, a), 2), U32.is_eq(um_get(has, b), 2))
      +va = um_get(val, a)
      +vb = um_get(val, b)
      +is_neg = Bool.and(fok, Bool.and(U32.is_eq(op, 11), U32.is_zero(va)))
      +nb = Bool.pick(U32, U32.is_zero(U32.and(vb, 2147483647)), 0, U32.xor(vb, 2147483648))
      +na = Bool.pick(U32, Bool.and(fok, U32.is_eq(op, 13)), opt_f32_to_small_u32(va), 0)
      +db = Bool.pick(U32, U32.is_ne(na, 0), opt_f32_to_small_u32(vb), 0)
      Bool.pick(CfSt, is_neg, cf_emit_flt(has, val, nr, rev, d, nb),
        Bool.pick(CfSt, U32.is_ne(db, 0), cf_emit_flt(has, val, nr, rev, d, opt_fdiv_bits(na, db)),
          CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, op, a, b}, rev}}))
    case False{}: cf_step_bin_int(U32.is_eq(um_get(has, a), 1), U32.is_eq(um_get(has, b), 1), has, val, nr, rev, d, op, a, b)
def cf_step_bin(+has: U32Map, +val: U32Map, nr: U32, rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32, +b: U32) -> CfSt:
  cf_step_bin_flt(U32.is_ge(op, 10), has, val, nr, rev, d, op, a, b)
def opt_pred_arms(arms: List<&2, IrSwitchArm>, m: U32Map) -> U32Map:
  match arms:
    case Nil{}: m
    case Con{IrArm{_, tgt}, t}: opt_pred_arms(t, opt_um_inc(m, tgt))
def opt_count_preds(blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, _, TJmp{tgt}}, t}: opt_count_preds(t, opt_um_inc(m, tgt))
    case Con{IrBlock{_, _, TBr{_, tb, fb}}, t}: opt_count_preds(t, opt_um_inc(opt_um_inc(m, tb), fb))
    case Con{IrBlock{_, _, TSwitch{_, arms, db}}, t}: opt_count_preds(t, opt_pred_arms(arms, opt_um_inc(m, db)))
    case Con{_, t}: opt_count_preds(t, m)
type BrFact is Data:
  BFNone{}
  BFEq{v: U32, k: U32}
  BFNe{v: U32, k: U32}
type BrScan is Data:
  BrScan{has: U32Map, val: U32Map, hit: Bool, cop: U32, a: U32, b: U32}
def cf_br_scan_ops(+c: U32, ops: List<&2, IrOp>, st: BrScan) -> BrScan:
  match ops st:
    case Nil{} _: st
    case Con{IConst{+d, v}, t} BrScan{has, val, hit, cop, a, b}:
      cf_br_scan_ops(c, t, BrScan{um_set(has, d, 1), um_set(val, d, v), Bool.and(hit, U32.is_ne(d, c)), cop, a, b})
    case Con{ICopy{+d, +s}, t} BrScan{+has, +val, hit, cop, a, b}:
      cf_br_scan_ops(c, t, BrScan{um_set(has, d, um_get(has, s)), um_set(val, d, um_get(val, s)), Bool.and(hit, U32.is_ne(d, c)), cop, a, b})
    case Con{ICmp{+d, +nc, +na, +nb}, t} BrScan{+has, +val, hit, cop, a, b}:
      +is_c = Bool.and(U32.is_eq(d, c), U32.is_le(nc, 1))
      st1 = Bool.pick(BrScan, is_c, BrScan{um_set(has, d, 0), val, True{}, nc, na, nb}, BrScan{um_set(has, d, 0), val, Bool.and(hit, U32.is_ne(d, c)), cop, a, b})
      cf_br_scan_ops(c, t, st1)
    case Con{+op, t} BrScan{has, val, hit, cop, a, b}:
      cf_br_scan_ops(c, t, BrScan{opt_kill_op_dsts(op, has), val, hit, cop, a, b})
def cf_br_put(+preds: U32Map, +bid: U32, +tgt: U32, f: BrFact, +fm: RaVec<BrFact>) -> RaVec<BrFact>:
  ok = Bool.and(U32.is_ne(tgt, bid), Bool.and(U32.is_ne(tgt, 0), Bool.and(U32.is_lt(tgt, 1024), U32.is_eq(um_get(preds, tgt), 1))))
  Bool.pick(RaVec<BrFact>, ok, ra_vec_set(BrFact, 5n, tgt, f, fm), fm)
def cf_br_record(+defc: U32Map, +ar: U32, +preds: U32Map, +bid: U32, +c: U32, +tb: U32, +fb: U32, sc: BrScan, +fm: RaVec<BrFact>) -> RaVec<BrFact>:
  match sc:
    case BrScan{+has, +val, True{}, +cop, +a, +b}:
      +ha = U32.is_ne(um_get(has, a), 0)
      +hb = U32.is_ne(um_get(has, b), 0)
      +eq_t = Bool.pick(U32, U32.is_zero(cop), tb, fb)
      +ne_t = Bool.pick(U32, U32.is_zero(cop), fb, tb)
      +ok_a = Bool.and(hb, Bool.and(Bool.not(ha), opt_cp_can_prop(defc, ar, a)))
      +ok_b = Bool.and(ha, Bool.and(Bool.not(hb), opt_cp_can_prop(defc, ar, b)))
      +fm1 = Bool.pick(RaVec<BrFact>, ok_a, cf_br_put(preds, bid, ne_t, BFNe{a, um_get(val, b)}, cf_br_put(preds, bid, eq_t, BFEq{a, um_get(val, b)}, fm)), fm)
      Bool.pick(RaVec<BrFact>, ok_b, cf_br_put(preds, bid, ne_t, BFNe{b, um_get(val, a)}, cf_br_put(preds, bid, eq_t, BFEq{b, um_get(val, a)}, fm1)), fm1)
    case BrScan{_, _, False{}, _, _, _}:
      Bool.pick(RaVec<BrFact>, opt_cp_can_prop(defc, ar, c), cf_br_put(preds, bid, tb, BFNe{c, 0}, cf_br_put(preds, bid, fb, BFEq{c, 0}, fm)), fm)
def cf_collect_facts(+defc: U32Map, +ar: U32, +preds: U32Map, blks: List<&2, IrBlock>, fm: RaVec<BrFact>) -> RaVec<BrFact>:
  match blks:
    case Nil{}: fm
    case Con{IrBlock{id, ops, TBr{+c, tb, fb}}, t}:
      sc = cf_br_scan_ops(c, ops, BrScan{UM0{}, UM0{}, False{}, 0, 0, 0})
      cf_collect_facts(defc, ar, preds, t, cf_br_record(defc, ar, preds, id, c, tb, fb, sc, fm))
    case Con{_, t}: cf_collect_facts(defc, ar, preds, t, fm)
def cf_step_op(+ne_v: U32, +ne_k: U32, st: CfSt, op: IrOp) -> CfSt:
  match st:
    case CfSt{+has, +val, +nr, +rev}:
      match op:
        case IConst{d, v}: cf_emit_const(has, val, nr, rev, d, v)
        case IFlt{d, bits}: cf_emit_flt(has, val, nr, rev, d, bits)
        case ICopy{d, s}: cf_emit_copy(has, val, nr, rev, d, s)
        case IBin{d, bop, a, b}: cf_step_bin(has, val, nr, rev, d, bop, a, b)
        case IUn{+d, +uop, +s}:
          +hs = um_get(has, s)
          +vs = um_get(val, s)
          +can_i = Bool.and(U32.is_lt(uop, 2), U32.is_eq(hs, 1))
          +can_fn = Bool.and(U32.is_eq(uop, 2), U32.is_eq(hs, 2))
          +can_u2f = Bool.and(U32.is_eq(uop, 4), U32.is_eq(hs, 1))
          Bool.pick(CfSt, can_i, cf_emit_const(has, val, nr, rev, d, opt_fold_un(uop, vs)),
            Bool.pick(CfSt, can_fn, cf_emit_flt(has, val, nr, rev, d, U32.xor(vs, 2147483648)),
              Bool.pick(CfSt, can_u2f, cf_emit_flt(has, val, nr, rev, d, opt_u2f_bits(vs)),
                CfSt{um_set(has, d, 0), val, nr, Con{IUn{d, uop, s}, rev}})))
        case ICmp{+d, +cop, +a, +b}:
          +ha = U32.is_eq(um_get(has, a), 1)
          +hb = U32.is_eq(um_get(has, b), 1)
          can = Bool.and(U32.is_lt(cop, 6), Bool.and(ha, hb))
          same_i = Bool.and(U32.is_lt(cop, 6), U32.is_eq(a, b))
          same_v = Bool.to_u32(Bool.or(U32.is_eq(cop, 0), Bool.or(U32.is_eq(cop, 3), U32.is_eq(cop, 5))))
          +nv = U32.sub(ne_v, 1)
          ne_hit = Bool.and(U32.is_ne(ne_v, 0), Bool.and(U32.is_le(cop, 1),
            Bool.or(Bool.and(U32.is_eq(a, nv), Bool.and(hb, U32.is_eq(um_get(val, b), ne_k))),
                    Bool.and(U32.is_eq(b, nv), Bool.and(ha, U32.is_eq(um_get(val, a), ne_k))))))
          Bool.pick(CfSt, can, cf_emit_const(has, val, nr, rev, d, opt_fold_cmp(cop, um_get(val, a), um_get(val, b))),
            Bool.pick(CfSt, same_i, cf_emit_const(has, val, nr, rev, d, same_v),
              Bool.pick(CfSt, ne_hit, cf_emit_const(has, val, nr, rev, d, cop),
                CfSt{um_set(has, d, 0), val, nr, Con{ICmp{d, cop, a, b}, rev}})))
        case other:
          +op0 = other
          CfSt{opt_kill_op_dsts(op0, has), val, nr, Con{op0, rev}}
def cf_step_ops(+ne_v: U32, +ne_k: U32, ops: List<&2, IrOp>, st: CfSt) -> CfSt:
  match ops:
    case Nil{}: st
    case Con{op, t}: cf_step_ops(ne_v, ne_k, t, cf_step_op(ne_v, ne_k, st, op))
def cf_find_arm(arms: List<&2, IrSwitchArm>, +tag: U32, def_blk: U32) -> U32:
  match arms:
    case Nil{}: def_blk
    case Con{IrArm{t, tgt}, rest}:
      Bool.pick(U32, U32.is_eq(t, tag), tgt, cf_find_arm(rest, tag, def_blk))
def cf_fold_term(+ne_v: U32, +ne_k: U32, +has: U32Map, +val: U32Map, term: IrTerm) -> IrTerm:
  match term:
    case TBr{+c, +tb, +fb}:
      +ne_nz = Bool.and(U32.is_ne(ne_v, 0), Bool.and(U32.is_eq(c, U32.sub(ne_v, 1)), U32.is_zero(ne_k)))
      Bool.pick(IrTerm, U32.is_eq(um_get(has, c), 1), TJmp{Bool.pick(U32, U32.is_zero(um_get(val, c)), fb, tb)},
        Bool.pick(IrTerm, ne_nz, TJmp{tb}, TBr{c, tb, fb}))
    case TSwitch{+s, +arms, +def_blk}:
      Bool.pick(IrTerm, U32.is_eq(um_get(has, s), 1), TJmp{cf_find_arm(arms, um_get(val, s), def_blk)}, TSwitch{s, arms, def_blk})
    case other: other
type CfBlksRes is Data:
  CfBlksRes{blks: List<&2, IrBlock>, nregs: U32}
def cf_blks_step(id: U32, term: IrTerm, +ne_v: U32, +ne_k: U32, acc: List<&2, IrBlock>, st: CfSt) -> CfBlksRes:
  match st:
    case CfSt{has, val, nr1, rev}:
      CfBlksRes{Con{IrBlock{id, b5k_list_rev(IrOp, rev), cf_fold_term(ne_v, ne_k, has, val, term)}, acc}, nr1}
type CfGConsts is Data:
  CfGConsts{ghas: U32Map, gval: U32Map}
def cf_gc_ops(+defc: U32Map, +ar: U32, ops: List<&2, IrOp>, st: CfGConsts) -> CfGConsts:
  match ops st:
    case Nil{} _: st
    case Con{IConst{+d, v}, t} CfGConsts{+gh, +gv}:
      ok = Bool.and(U32.is_ge(d, ar), U32.is_eq(um_get(defc, d), 1))
      st1 = Bool.pick(CfGConsts, ok, CfGConsts{um_set(gh, d, 1), um_set(gv, d, v)}, CfGConsts{gh, gv})
      cf_gc_ops(defc, ar, t, st1)
    case Con{ICopy{+d, +s}, t} CfGConsts{+gh, +gv}:
      ok = Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_eq(um_get(defc, d), 1), U32.is_ne(um_get(gh, s), 0)))
      st1 = Bool.pick(CfGConsts, ok, CfGConsts{um_set(gh, d, 1), um_set(gv, d, um_get(gv, s))}, CfGConsts{gh, gv})
      cf_gc_ops(defc, ar, t, st1)
    case Con{_, t} _: cf_gc_ops(defc, ar, t, st)
def cf_gc_blks(+defc: U32Map, +ar: U32, blks: List<&2, IrBlock>, st: CfGConsts) -> CfGConsts:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, _}, t}: cf_gc_blks(defc, ar, t, cf_gc_ops(defc, ar, ops, st))
def cf_blks_one(f: BrFact, +gh: U32Map, +gv: U32Map, id: U32, ops: List<&2, IrOp>, term: IrTerm, acc: List<&2, IrBlock>, nr: U32) -> CfBlksRes:
  match f:
    case BFNone{}: cf_blks_step(id, term, 0, 0, acc, cf_step_ops(0, 0, ops, CfSt{gh, gv, nr, Nil{}}))
    case BFEq{+v, k}: cf_blks_step(id, term, 0, 0, acc, cf_step_ops(0, 0, ops, CfSt{um_set(gh, v, 1), um_set(gv, v, k), nr, Nil{}}))
    case BFNe{+v, +k}: cf_blks_step(id, term, U32.add(v, 1), k, acc, cf_step_ops(U32.add(v, 1), k, ops, CfSt{gh, gv, nr, Nil{}}))
def cf_blks_go(+fm: RaVec<BrFact>, +gh: U32Map, +gv: U32Map, blks: List<&2, IrBlock>, st: CfBlksRes) -> CfBlksRes:
  match blks st:
    case Nil{} CfBlksRes{acc, nr}: CfBlksRes{b5k_list_rev(IrBlock, acc), nr}
    case Con{IrBlock{+id, ops, term}, t} CfBlksRes{acc, nr}:
      f = Bool.pick(BrFact, U32.is_lt(id, 1024), ra_vec_get(BrFact, 5n, BFNone{}, id, fm), BFNone{})
      cf_blks_go(fm, gh, gv, t, cf_blks_one(f, gh, gv, id, ops, term, acc, nr))
def cf_blks_fast(blks: List<&2, IrBlock>, st: CfBlksRes) -> CfBlksRes:
  match blks st:
    case Nil{} CfBlksRes{acc, nr}: CfBlksRes{b5k_list_rev(IrBlock, acc), nr}
    case Con{IrBlock{id, ops, term}, t} CfBlksRes{acc, nr}:
      cf_blks_fast(t, cf_blks_step(id, term, 0, 0, acc, cf_step_ops(0, 0, ops, CfSt{UM0{}, UM0{}, nr, Nil{}})))
def cf_fn_fin(fid: U32, nm: String, ar: U32, esc: Bool, eff: Bool, is_m: Bool, r: CfBlksRes) -> IrFn:
  match r:
    case CfBlksRes{blks2, nr2}: IrFn{fid, nm, ar, nr2, esc, eff, is_m, blks2}
def cf_pass_full(+fid: U32, nm: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, +defc: U32Map, gc: CfGConsts) -> IrFn:
  match gc:
    case CfGConsts{gh, gv}:
      preds = opt_count_preds(blks, um_set(UM0{}, 0, 2))
      fm = cf_collect_facts(defc, ar, preds, blks, RVEmpty{})
      cf_fn_fin(fid, nm, ar, esc, eff, is_m, cf_blks_go(fm, gh, gv, blks, CfBlksRes{Nil{}, nregs}))
def opt_pass_cf(do_facts: Bool, f: IrFn) -> IrFn:
  match do_facts f:
    case False{} IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}:
      cf_fn_fin(fid, nm, ar, esc, eff, is_m, cf_blks_fast(blks, CfBlksRes{Nil{}, nregs}))
    case True{} IrFn{fid, nm, +ar, nregs, esc, eff, is_m, +blks}:
      +defc = opt_blks_defs(blks, UM0{})
      gc = cf_gc_blks(defc, ar, blks, cf_gc_blks(defc, ar, blks, CfGConsts{UM0{}, UM0{}}))
      cf_pass_full(fid, nm, ar, nregs, esc, eff, is_m, blks, defc, gc)
# Pass 3 & Pass D — Copy Prop, CSE, DCE, Unreach & Block Merge
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
    case IMutField{o, idx, v}: IMutField{opt_um_lookup_or(cm, o), idx, opt_um_lookup_or(cm, v)}
    case other: other
# Direct-mapped 8-level (256-slot) CSE table
type CseEnt is Data:
  CseNone{}
  CseSome{k: U32, op: U32, a: U32, b: U32, dst: U32}
def cse_hash(+k: U32, +op: U32, +a: U32, +b: U32) -> U32:
  +h1 = U32.xor(U32.mul(a, 2654435761), U32.mul(b, 2246822519))
  U32.and(U32.xor(U32.shrn(h1, 16n), U32.xor(h1, U32.add(U32.shln(k, 4n), op))), 1023)
def cse_match_ent(e: CseEnt, +k: U32, +op: U32, +a: U32, +b: U32) -> U32:
  match e:
    case CseNone{}: 0
    case CseSome{ek, eop, ea, eb, dst}:
      eq = Bool.and(U32.is_eq(ek, k), Bool.and(U32.is_eq(eop, op), Bool.and(U32.is_eq(ea, a), U32.is_eq(eb, b))))
      Bool.pick(U32, eq, U32.add(dst, 1), 0)
def cse_lookup(m: RaVec<CseEnt>, +k: U32, +op: U32, +a: U32, +b: U32) -> U32:
  cse_match_ent(ra_vec_get(CseEnt, 5n, CseNone{}, cse_hash(k, op, a, b), m), k, op, a, b)
def cse_insert(m: RaVec<CseEnt>, +k: U32, +op: U32, +a: U32, +b: U32, dst: U32) -> RaVec<CseEnt>:
  ra_vec_set(CseEnt, 5n, cse_hash(k, op, a, b), CseSome{k, op, a, b, dst}, m)
def cse_maybe_ins(ok: Bool, m: RaVec<CseEnt>, k: U32, op: U32, a: U32, b: U32, d: U32) -> RaVec<CseEnt>:
  match ok:
    case True{}: cse_insert(m, k, op, a, b, d)
    case False{}: m
def cse_is_comm(+bop: U32) -> Bool:
  Bool.or(U32.is_eq(bop, 0), Bool.or(U32.is_eq(bop, 2), Bool.or(U32.is_eq(bop, 5), Bool.or(U32.is_eq(bop, 6), Bool.or(U32.is_eq(bop, 7), Bool.or(U32.is_eq(bop, 10), U32.is_eq(bop, 12)))))))
type DomCse is Data:
  DomCse{csem: RaVec<CseEnt>, cnt: U32}
type CpOpsRes is Data:
  CpOpsRes{ops: List<&2, IrOp>, cm: U32Map, dc: DomCse}
type CpSt is Data:
  CpSt{cm: U32Map, csem: RaVec<CseEnt>, dcsem: RaVec<CseEnt>, ccnt: U32, acc: List<&2, IrOp>}
def opt_cp_cse_go(is_hit: Bool, +hit: U32, +defc: U32Map, +ar: U32, +k: U32, +op: U32, +a: U32, +b: U32, +d: U32, orig_op: IrOp, ok_ops: Bool, +cm: U32Map, csem: RaVec<CseEnt>, dcsem: RaVec<CseEnt>, +ccnt: U32, +acc: List<&2, IrOp>) -> CpSt:
  match is_hit:
    case True{}:
      +rs = U32.sub(hit, 1)
      cm1 = Bool.pick(U32Map, Bool.and(U32.is_ne(d, rs), opt_cp_can_prop(defc, ar, rs)), um_set(cm, d, hit), um_set(cm, d, 0))
      acc1 = Bool.pick(List<&2, IrOp>, U32.is_eq(d, rs), acc, Con{ICopy{d, rs}, acc})
      CpSt{cm1, csem, dcsem, ccnt, acc1}
    case False{}:
      +can_ins = Bool.and(ok_ops, opt_cp_can_prop(defc, ar, d))
      csem1 = cse_maybe_ins(can_ins, csem, k, op, a, b, d)
      +is_const = U32.is_eq(k, 1)
      +is_and = Bool.and(U32.is_eq(k, 4), U32.is_eq(op, 5))
      +is_shr = Bool.and(U32.is_eq(k, 4), U32.is_eq(op, 9))
      +is_mul = Bool.and(U32.is_eq(k, 4), U32.is_eq(op, 2))
      +is_cmp = U32.is_eq(k, 5)
      +is_dom_op = Bool.or(is_and, Bool.or(is_shr, Bool.or(is_mul, is_cmp)))
      +d_ok = Bool.and(can_ins, Bool.or(is_const, Bool.and(U32.is_lt(ccnt, 6), is_dom_op)))
      dcsem1 = cse_maybe_ins(d_ok, dcsem, k, op, a, b, d)
      ccnt1 = Bool.pick(U32, Bool.and(d_ok, is_dom_op), U32.add(ccnt, 1), ccnt)
      CpSt{um_set(cm, d, 0), csem1, dcsem1, ccnt1, Con{orig_op, acc}}
def opt_cp_cse_step(+defc: U32Map, +ar: U32, +k: U32, +op: U32, +a: U32, +b: U32, d: U32, orig_op: IrOp, ok_ops: Bool, cm: U32Map, +csem: RaVec<CseEnt>, dcsem: RaVec<CseEnt>, ccnt: U32, acc: List<&2, IrOp>) -> CpSt:
  +hit = cse_lookup(csem, k, op, a, b)
  opt_cp_cse_go(U32.is_ne(hit, 0), hit, defc, ar, k, op, a, b, d, orig_op, ok_ops, cm, csem, dcsem, ccnt, acc)
def opt_cp_ops(+defc: U32Map, +ar: U32, ops: List<&2, IrOp>, st: CpSt) -> CpOpsRes:
  match ops st:
    case Nil{} CpSt{cm, _, dcsem, ccnt, acc}: CpOpsRes{b5k_list_rev(IrOp, acc), cm, DomCse{dcsem, ccnt}}
    case Con{ICopy{+d, s}, t} CpSt{+cm0, csem, dcsem, ccnt, +acc}:
      +rs = opt_um_lookup_or(cm0, s)
      cm1 = Bool.pick(U32Map, Bool.and(U32.is_ne(d, rs), opt_cp_can_prop(defc, ar, rs)), um_set(cm0, d, U32.add(rs, 1)), um_set(cm0, d, 0))
      acc1 = Bool.pick(List<&2, IrOp>, U32.is_eq(d, rs), acc, Con{ICopy{d, rs}, acc})
      opt_cp_ops(defc, ar, t, CpSt{cm1, csem, dcsem, ccnt, acc1})
    case Con{IConst{+d, +v}, t} CpSt{cm, csem, dcsem, ccnt, acc}:
      opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 1, 0, v, 0, d, IConst{d, v}, True{}, cm, csem, dcsem, ccnt, acc))
    case Con{IFlt{+d, +bits}, t} CpSt{cm, csem, dcsem, ccnt, acc}:
      opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 2, 0, bits, 0, d, IFlt{d, bits}, True{}, cm, csem, dcsem, ccnt, acc))
    case Con{IUn{+d, +uop, s}, t} CpSt{+cm0, csem, dcsem, ccnt, acc}:
      +rs = opt_um_lookup_or(cm0, s)
      opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 3, uop, rs, 0, d, IUn{d, uop, rs}, opt_cp_can_prop(defc, ar, rs), cm0, csem, dcsem, ccnt, acc))
    case Con{IBin{+d, +bop, a, b}, t} CpSt{+cm0, csem, dcsem, ccnt, acc}:
      +ra = opt_um_lookup_or(cm0, a)
      +rb = opt_um_lookup_or(cm0, b)
      +comm = cse_is_comm(bop)
      ka = Bool.pick(U32, comm, U32.min(ra, rb), ra)
      kb = Bool.pick(U32, comm, U32.max(ra, rb), rb)
      ok = Bool.and(opt_cp_can_prop(defc, ar, ra), opt_cp_can_prop(defc, ar, rb))
      opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 4, bop, ka, kb, d, IBin{d, bop, ra, rb}, ok, cm0, csem, dcsem, ccnt, acc))
    case Con{ICmp{+d, +cop, a, b}, t} CpSt{+cm0, csem, dcsem, ccnt, acc}:
      +ra = opt_um_lookup_or(cm0, a)
      +rb = opt_um_lookup_or(cm0, b)
      +comm = U32.is_le(cop, 1)
      ka = Bool.pick(U32, comm, U32.min(ra, rb), ra)
      kb = Bool.pick(U32, comm, U32.max(ra, rb), rb)
      ok = Bool.and(opt_cp_can_prop(defc, ar, ra), opt_cp_can_prop(defc, ar, rb))
      opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 5, cop, ka, kb, d, ICmp{d, cop, ra, rb}, ok, cm0, csem, dcsem, ccnt, acc))
    case Con{ITag{+d, s}, t} CpSt{+cm0, csem, dcsem, ccnt, acc}:
      +rs = opt_um_lookup_or(cm0, s)
      opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 6, 0, rs, 0, d, ITag{d, rs}, opt_cp_can_prop(defc, ar, rs), cm0, csem, dcsem, ccnt, acc))
    case Con{op, t} CpSt{+cm0, csem, dcsem, ccnt, acc}:
      +op2 = opt_cp_rewrite_op(cm0, op)
      opt_cp_ops(defc, ar, t, CpSt{opt_kill_op_dsts(op2, cm0), csem, dcsem, ccnt, Con{op2, acc}})
def opt_cp_term(+cm: U32Map, term: IrTerm) -> IrTerm:
  match term:
    case TBr{c, tb, fb}: TBr{opt_um_lookup_or(cm, c), tb, fb}
    case TSwitch{s, arms, db}: TSwitch{opt_um_lookup_or(cm, s), arms, db}
    case TRet{v}: TRet{opt_um_lookup_or(cm, v)}
    case TTailCall{fid, args}: TTailCall{fid, opt_map_u32(cm, args)}
    case other: other
def opt_cp_blk_fin(id: U32, term: IrTerm, r: CpOpsRes) -> IrBlock:
  match r:
    case CpOpsRes{ops2, cm2, _}: IrBlock{id, ops2, opt_cp_term(cm2, term)}
def opt_jmp_tgts(blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{id, _, TJmp{tgt}}, t}: opt_jmp_tgts(t, um_set(m, id, U32.add(tgt, 1)))
    case Con{_, t}: opt_jmp_tgts(t, m)
def opt_cse_put(ok: Bool, +tgt: U32, dc: DomCse, cmap: RaVec<DomCse>) -> RaVec<DomCse>:
  match ok:
    case True{}: ra_vec_set(DomCse, 5n, tgt, dc, cmap)
    case False{}: cmap
def opt_cse_prop_term(+preds: U32Map, +jmps: U32Map, +id: U32, term: IrTerm, +dc: DomCse, +cmap: RaVec<DomCse>) -> RaVec<DomCse>:
  match term:
    case TJmp{+tgt}:
      ok = Bool.and(U32.is_lt(tgt, 1024), Bool.and(U32.is_ne(tgt, id), U32.is_eq(um_get(preds, tgt), 1)))
      opt_cse_put(ok, tgt, dc, cmap)
    case TBr{_, +tb, +fb}:
      +ok_t = Bool.and(U32.is_lt(tb, 1024), Bool.and(U32.is_ne(tb, id), U32.is_eq(um_get(preds, tb), 1)))
      +ok_f = Bool.and(U32.is_lt(fb, 1024), Bool.and(U32.is_ne(fb, id), U32.is_eq(um_get(preds, fb), 1)))
      +cm1 = opt_cse_put(ok_f, fb, dc, opt_cse_put(ok_t, tb, dc, cmap))
      +jt = um_get(jmps, tb)
      +jf = um_get(jmps, fb)
      +m = U32.sub(jt, 1)
      ok_m = Bool.and(ok_t, Bool.and(ok_f, Bool.and(U32.is_ne(tb, fb), Bool.and(U32.is_ne(jt, 0), Bool.and(U32.is_eq(jt, jf), Bool.and(U32.is_lt(m, 1024), Bool.and(U32.is_ne(m, id), U32.is_eq(um_get(preds, m), 2))))))))
      opt_cse_put(ok_m, m, dc, cm1)
    case _: cmap
def opt_cp_blk_cmap(+preds: U32Map, +jmps: U32Map, +id: U32, term: IrTerm, r: CpOpsRes, cmap: RaVec<DomCse>) -> RaVec<DomCse>:
  match r:
    case CpOpsRes{_, _, dc2}: opt_cse_prop_term(preds, jmps, id, term, dc2, cmap)
def opt_cp_ops_dc(+defc: U32Map, +ar: U32, gcm: U32Map, ops: List<&2, IrOp>, dc: DomCse) -> CpOpsRes:
  match dc:
    case DomCse{+csem0, cnt0}: opt_cp_ops(defc, ar, ops, CpSt{gcm, csem0, csem0, cnt0, Nil{}})
def opt_cp_blks_dom(+defc: U32Map, +ar: U32, +gcm: U32Map, +preds: U32Map, +jmps: U32Map, blks: List<&2, IrBlock>, +cmap: RaVec<DomCse>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, ops, +term}, t}:
      dc0 = Bool.pick(DomCse, U32.is_lt(id, 1024), ra_vec_get(DomCse, 5n, DomCse{RVEmpty{}, 0}, id, cmap), DomCse{RVEmpty{}, 0})
      +r = opt_cp_ops_dc(defc, ar, gcm, ops, dc0)
      Con{opt_cp_blk_fin(id, term, r), opt_cp_blks_dom(defc, ar, gcm, preds, jmps, t, opt_cp_blk_cmap(preds, jmps, id, term, r, cmap))}
def opt_keep_ops(ops: List<&2, IrOp>, m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{IKeep{d, _}, t}: opt_keep_ops(t, um_set(m, d, 1))
    case Con{_, t}: opt_keep_ops(t, m)
def opt_keep_blks(blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, _}, t}: opt_keep_blks(t, opt_keep_ops(ops, m))
def opt_gc_cp_ops(+defc: U32Map, +km: U32Map, +ar: U32, ops: List<&2, IrOp>, +cm: U32Map) -> U32Map:
  match ops:
    case Nil{}: cm
    case Con{ICopy{+d, s}, t}:
      +rs = opt_um_lookup_or(cm, s)
      opt_gc_cp_ops(defc, km, ar, t, Bool.pick(U32Map, Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(U32.is_zero(um_get(km, d)), Bool.and(U32.is_zero(um_get(km, rs)), Bool.and(U32.is_ne(d, rs), opt_cp_can_prop(defc, ar, rs)))))), um_set(cm, d, U32.add(rs, 1)), cm))
    case Con{_, t}: opt_gc_cp_ops(defc, km, ar, t, cm)
def opt_gc_cp_blks(+defc: U32Map, +km: U32Map, +ar: U32, blks: List<&2, IrBlock>, cm: U32Map) -> U32Map:
  match blks:
    case Nil{}: cm
    case Con{IrBlock{_, ops, _}, t}: opt_gc_cp_blks(defc, km, ar, t, opt_gc_cp_ops(defc, km, ar, ops, cm))
def opt_cp_blks(+defc: U32Map, +ar: U32, +gcm: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}:
      Con{opt_cp_blk_fin(id, term, opt_cp_ops(defc, ar, ops, CpSt{gcm, RVEmpty{}, RVEmpty{}, 0, Nil{}})), opt_cp_blks(defc, ar, gcm, t)}
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
def opt_reach_fix(fuel: Nat, +blks: List<&2, IrBlock>, st: ReachStep) -> U32Map:
  match fuel st:
    case 0n ReachStep{m, _}: m
    case _ ReachStep{m, False{}}: m
    case 1n+p ReachStep{m, True{}}: opt_reach_fix(p, blks, opt_reach_scan(blks, ReachStep{m, False{}}))
def opt_filter_reach(+reach: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, ops, term}, t}:
      +rest = opt_filter_reach(reach, t)
      Bool.pick(List<&2, IrBlock>, U32.is_ne(um_get(reach, id), 0), Con{IrBlock{id, ops, term}, rest}, rest)
def opt_elim_unreach(+blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  reach = opt_reach_fix(U32.to_nat(b5k_list_len(IrBlock, blks)), blks, ReachStep{um_set(UM0{}, 0, 1), True{}})
  opt_filter_reach(reach, blks)
# Single-Predecessor Block Merger (unlocks cross-block SROA/CF/CSE after inlining)
def opt_index_put(ok: Bool, +id: U32, ops: List<&2, IrOp>, term: IrTerm, m: RaVec<Maybe<&2, IrBlock>>) -> RaVec<Maybe<&2, IrBlock>>:
  match ok:
    case True{}: ra_vec_set(Maybe<&2, IrBlock>, 5n, id, Some{IrBlock{id, ops, term}}, m)
    case False{}: m
def opt_index_blks(blks: List<&2, IrBlock>, m: RaVec<Maybe<&2, IrBlock>>) -> RaVec<Maybe<&2, IrBlock>>:
  match blks:
    case Nil{}: m
    case Con{IrBlock{+id, ops, term}, t}:
      opt_index_blks(t, opt_index_put(U32.is_lt(id, 1024), id, ops, term, m))
type MergeSt is Data:
  MergeSt{skip: U32Map, used: U32Map, acc: List<&2, IrBlock>}
def opt_merge_apply(mb: Maybe<&2, IrBlock>, +id: U32, ops: List<&2, IrOp>, +tgt: U32, sk0: U32Map, us0: U32Map, acc: List<&2, IrBlock>) -> MergeSt:
  match mb:
    case None{}: MergeSt{sk0, us0, Con{IrBlock{id, ops, TJmp{tgt}}, acc}}
    case Some{IrBlock{_, bops, bterm}}:
      MergeSt{um_set(sk0, tgt, 1), um_set(us0, id, 1), Con{IrBlock{id, b5k_list_app(IrOp, ops, bops), bterm}, acc}}
def opt_merge_try_jmp(can: Bool, bmap: RaVec<Maybe<&2, IrBlock>>, id: U32, ops: List<&2, IrOp>, +tgt: U32, sk0: U32Map, us0: U32Map, acc: List<&2, IrBlock>) -> MergeSt:
  match can:
    case False{}: MergeSt{sk0, us0, Con{IrBlock{id, ops, TJmp{tgt}}, acc}}
    case True{}: opt_merge_apply(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tgt, bmap), id, ops, tgt, sk0, us0, acc)
def opt_merge_one(skipped: Bool, bmap: RaVec<Maybe<&2, IrBlock>>, preds: U32Map, +id: U32, ops: List<&2, IrOp>, term: IrTerm, +sk0: U32Map, +us0: U32Map, acc: List<&2, IrBlock>) -> MergeSt:
  match skipped term:
    case True{} _: MergeSt{sk0, us0, acc}
    case False{} TJmp{+tgt}:
      can = Bool.and(U32.is_lt(tgt, 1024), Bool.and(U32.is_ne(tgt, id), Bool.and(U32.is_eq(um_get(preds, tgt), 1), Bool.and(U32.is_zero(um_get(sk0, tgt)), U32.is_zero(um_get(us0, tgt))))))
      opt_merge_try_jmp(can, bmap, id, ops, tgt, sk0, us0, acc)
    case False{} other: MergeSt{sk0, us0, Con{IrBlock{id, ops, other}, acc}}
def opt_merge_go(+bmap: RaVec<Maybe<&2, IrBlock>>, +preds: U32Map, blks: List<&2, IrBlock>, st: MergeSt) -> List<&2, IrBlock>:
  match blks st:
    case Nil{} MergeSt{_, _, acc}: b5k_list_rev(IrBlock, acc)
    case Con{IrBlock{+id, ops, term}, t} MergeSt{+sk0, used, acc}:
      opt_merge_go(bmap, preds, t, opt_merge_one(U32.is_ne(um_get(sk0, id), 0), bmap, preds, id, ops, term, sk0, used, acc))
def opt_merge_once(+blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  preds = opt_count_preds(blks, um_set(UM0{}, 0, 2))
  bmap = opt_index_blks(blks, RVEmpty{})
  opt_merge_go(bmap, preds, blks, MergeSt{UM0{}, UM0{}, Nil{}})
def opt_merge_n(k: Nat, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match k:
    case 0n: blks
    case 1n+p: opt_merge_n(p, opt_merge_once(blks))
def opt_stc_args(+orig: U32Map, args: List<&2, U32>, +idx: U32) -> List<&2, U32>:
  match args:
    case Nil{}: Nil{}
    case Con{+a, t}:
      a2 = Bool.pick(U32, U32.is_eq(um_get(orig, a), U32.add(idx, 1)), idx, a)
      Con{a2, opt_stc_args(orig, t, U32.add(idx, 1))}
def opt_stc_term(same: Bool, orig: U32Map, cfid: U32, args: List<&2, U32>) -> IrTerm:
  match same:
    case True{}: TTailCall{cfid, opt_stc_args(orig, args, 0)}
    case False{}: TTailCall{cfid, args}
def opt_stc_ret_go(+id: U32, +self_fid: U32, rev: List<&2, IrOp>, +rv: U32) -> IrBlock:
  match rev:
    case Con{ICallDirect{+d, +cfid, +args}, +rest}: Bool.pick(IrBlock, Bool.and(U32.is_eq(d, rv), U32.is_eq(cfid, self_fid)), IrBlock{id, b5k_list_rev(IrOp, rest), TTailCall{cfid, args}}, IrBlock{id, b5k_list_rev(IrOp, Con{ICallDirect{d, cfid, args}, rest}), TRet{rv}})
    case r: IrBlock{id, b5k_list_rev(IrOp, r), TRet{rv}}
def opt_stc_blks(+self_fid: U32, +orig: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, TTailCall{+cfid, args}}, t}: Con{IrBlock{id, ops, opt_stc_term(U32.is_eq(cfid, self_fid), orig, cfid, args)}, opt_stc_blks(self_fid, orig, t)}
    case Con{IrBlock{id, ops, TRet{rv}}, t}: Con{opt_stc_ret_go(id, self_fid, b5k_list_rev(IrOp, ops), rv), opt_stc_blks(self_fid, orig, t)}
    case Con{b, t}: Con{b, opt_stc_blks(self_fid, orig, t)}
def opt_empty_blks(blks: List<&2, IrBlock>, +m: RaVec<Maybe<&2, IrTerm>>) -> RaVec<Maybe<&2, IrTerm>>:
  match blks:
    case Nil{}: m
    case Con{IrBlock{+id, Nil{}, TJmp{x}}, t}: opt_empty_blks(t, Bool.pick(RaVec<Maybe<&2, IrTerm>>, U32.is_lt(id, 1024), ra_vec_set(Maybe<&2, IrTerm>, 5n, id, Some{TJmp{x}}, m), m))
    case Con{IrBlock{+id, Nil{}, TRet{x}}, t}: opt_empty_blks(t, Bool.pick(RaVec<Maybe<&2, IrTerm>>, U32.is_lt(id, 1024), ra_vec_set(Maybe<&2, IrTerm>, 5n, id, Some{TRet{x}}, m), m))
    case Con{IrBlock{+id, Nil{}, TTailCall{f, xs}}, t}: opt_empty_blks(t, Bool.pick(RaVec<Maybe<&2, IrTerm>>, U32.is_lt(id, 1024), ra_vec_set(Maybe<&2, IrTerm>, 5n, id, Some{TTailCall{f, xs}}, m), m))
    case Con{_, t}: opt_empty_blks(t, m)
def opt_fwd_term(mt: Maybe<&2, IrTerm>, tgt: U32) -> IrTerm:
  match mt:
    case Some{t2}: t2
    case None{}: TJmp{tgt}
def opt_fwd_blks(+em: RaVec<Maybe<&2, IrTerm>>, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, ops, TJmp{+tgt}}, t}:
      Con{IrBlock{id, ops, Bool.pick(IrTerm, Bool.and(U32.is_ne(tgt, id), U32.is_lt(tgt, 1024)), opt_fwd_term(ra_vec_get(Maybe<&2, IrTerm>, 5n, None{}, tgt, em), tgt), TJmp{tgt})}, opt_fwd_blks(em, t)}
    case Con{b, t}: Con{b, opt_fwd_blks(em, t)}
def opt_pass_cp_dce(do_merge: Bool, f: IrFn) -> IrFn:
  match do_merge f:
    case True{} IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, blks}:
      +b0 = opt_merge_n(5n, opt_elim_unreach(blks))
      +b1 = opt_elim_unreach(opt_fwd_blks(opt_empty_blks(b0, RVEmpty{}), b0))
      +defc = opt_blks_defs(b1, UM0{})
      +b1b = opt_stc_blks(fid, opt_ip_orig_blks(defc, ar, b1, opt_ip_init_orig(U32.to_nat(ar), 0, UM0{})), b1)
      +km = opt_keep_blks(b1b, UM0{})
      +preds = opt_count_preds(b1b, um_set(UM0{}, 0, 2))
      +jmps = opt_jmp_tgts(b1b, UM0{})
      b2 = opt_cp_blks_dom(defc, ar, opt_gc_cp_blks(defc, km, ar, b1b, opt_gc_cp_blks(defc, km, ar, b1b, UM0{})), preds, jmps, b1b, RVEmpty{})
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_dce_round(opt_dce_round(b2))}
    case False{} IrFn{fid, nm, +ar, nregs, esc, eff, is_m, blks}:
      +b1 = opt_elim_unreach(blks)
      b2 = opt_cp_blks(opt_blks_defs(b1, UM0{}), ar, UM0{}, b1)
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_dce_round(b2)}
# Pass C — Deeper Multi-Block Inlining (<= 32 ops, <= 4 blocks, 2 rounds)
type InlEntry is Data:
  InlEntry{fid: U32, arity: U32, nregs: U32, max_blk: U32, blks: List<&2, IrBlock>}
type InlBank is Data:
  InlBank{has: U32Map, trie: RaVec<Maybe<&2, InlEntry>>}
def opt_blks_op_count(blks: List<&2, IrBlock>, acc: U32) -> U32:
  match blks:
    case Nil{}: acc
    case Con{IrBlock{_, ops, _}, t}: opt_blks_op_count(t, U32.add(acc, b5k_list_len(IrOp, ops)))
def opt_blks_max_id(blks: List<&2, IrBlock>, acc: U32) -> U32:
  match blks:
    case Nil{}: acc
    case Con{IrBlock{id, _, _}, t}: opt_blks_max_id(t, U32.max(acc, id))
def opt_ops_has_call(+leaf: Bool, +fid: U32, ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: False{}
    case Con{ICallDirect{_, cfid, _}, t}: Bool.or(Bool.or(leaf, U32.is_eq(cfid, fid)), opt_ops_has_call(leaf, fid, t))
    case Con{ICallClosure{_, _, _}, t}: Bool.or(leaf, opt_ops_has_call(leaf, fid, t))
    case Con{IApply{_, _, _}, t}: Bool.or(leaf, opt_ops_has_call(leaf, fid, t))
    case Con{_, t}: opt_ops_has_call(leaf, fid, t)
def opt_blks_has_bad(+leaf: Bool, +tc_ok: Bool, +fid: U32, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: False{}
    case Con{IrBlock{_, ops, TTailCall{cfid, _}}, t}:
      bad_tc = Bool.or(Bool.and(leaf, Bool.not(tc_ok)), U32.is_eq(cfid, fid))
      Bool.or(bad_tc, Bool.or(opt_ops_has_call(leaf, fid, ops), opt_blks_has_bad(leaf, tc_ok, fid, t)))
    case Con{IrBlock{_, ops, _}, t}:
      Bool.or(opt_ops_has_call(leaf, fid, ops), opt_blks_has_bad(leaf, tc_ok, fid, t))
def opt_fn_mark_calls_ops(ops: List<&2, IrOp>, st: ReachStep) -> ReachStep:
  match ops st:
    case Nil{} _: st
    case Con{ICallDirect{_, cfid, _}, t} ReachStep{m, chg}:
      opt_fn_mark_calls_ops(t, opt_reach_mark(m, chg, cfid))
    case Con{ICallClosure{_, cfid, _}, t} ReachStep{m, chg}:
      opt_fn_mark_calls_ops(t, opt_reach_mark(m, chg, cfid))
    case Con{_, t} _: opt_fn_mark_calls_ops(t, st)
def opt_fn_mark_calls_blks(blks: List<&2, IrBlock>, st: ReachStep) -> ReachStep:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, TTailCall{cfid, _}}, t}:
      opt_fn_mark_calls_blks(t, opt_reach_mark_st(opt_fn_mark_calls_ops(ops, st), cfid))
    case Con{IrBlock{_, ops, _}, t}:
      opt_fn_mark_calls_blks(t, opt_fn_mark_calls_ops(ops, st))
def opt_fn_reach_init(fns: List<&2, IrFn>, +m: U32Map) -> U32Map:
  match fns:
    case Nil{}: m
    case Con{IrFn{+fid, _, _, _, esc, eff, is_m, _}, t}:
      root = Bool.or(U32.is_lt(fid, 3), Bool.or(esc, Bool.or(eff, is_m)))
      opt_fn_reach_init(t, Bool.pick(U32Map, root, um_set(m, fid, 1), m))
def opt_fn_reach_scan(fns: List<&2, IrFn>, st: ReachStep) -> ReachStep:
  match fns st:
    case Nil{} _: st
    case Con{IrFn{fid, _, _, _, _, _, _, blks}, t} ReachStep{+m, +chg}:
      st1 = Bool.pick(ReachStep, U32.is_ne(um_get(m, fid), 0), opt_fn_mark_calls_blks(blks, ReachStep{m, chg}), ReachStep{m, chg})
      opt_fn_reach_scan(t, st1)
def opt_fn_reach_fix(fuel: Nat, +fns: List<&2, IrFn>, st: ReachStep) -> U32Map:
  match fuel st:
    case 0n ReachStep{m, _}: m
    case _ ReachStep{m, False{}}: m
    case 1n+p ReachStep{m, True{}}: opt_fn_reach_fix(p, fns, opt_fn_reach_scan(fns, ReachStep{m, False{}}))
def opt_fn_reach(+fns: List<&2, IrFn>) -> U32Map:
  opt_fn_reach_fix(32n, fns, ReachStep{opt_fn_reach_init(fns, UM0{}), True{}})
def opt_cc_ops(ops: List<&2, IrOp>, m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{ICallDirect{_, cfid, _}, t}: opt_cc_ops(t, opt_um_inc(m, cfid))
    case Con{ICallClosure{_, cfid, _}, t}: opt_cc_ops(t, opt_um_inc(m, cfid))
    case Con{_, t}: opt_cc_ops(t, m)
def opt_cc_blks(blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, TTailCall{cfid, _}}, t}: opt_cc_blks(t, opt_um_inc(opt_cc_ops(ops, m), cfid))
    case Con{IrBlock{_, ops, _}, t}: opt_cc_blks(t, opt_cc_ops(ops, m))
def opt_cc_fns(+reach: U32Map, fns: List<&2, IrFn>, +m: U32Map) -> U32Map:
  match fns:
    case Nil{}: m
    case Con{IrFn{fid, _, _, _, _, _, _, blks}, t}:
      opt_cc_fns(reach, t, Bool.pick(U32Map, U32.is_ne(um_get(reach, fid), 0), opt_cc_blks(blks, m), m))
def opt_collect_put(ok: Bool, +fid: U32, ar: U32, nregs: U32, +blks: List<&2, IrBlock>, has: U32Map, tr: RaVec<Maybe<&2, InlEntry>>) -> InlBank:
  match ok:
    case False{}: InlBank{has, tr}
    case True{}: InlBank{um_set(has, fid, 1), ra_vec_set(Maybe<&2, InlEntry>, 6n, fid, Some{InlEntry{fid, ar, nregs, opt_blks_max_id(blks, 0), blks}}, tr)}
def opt_collect_one(elig: Bool, +sc_only: Bool, +cc: U32Map, +leaf: Bool, +max_ops: U32, +max_blks: U32, +fid: U32, ar: U32, +nregs: U32, +blks: List<&2, IrBlock>, has: U32Map, tr: RaVec<Maybe<&2, InlEntry>>) -> InlBank:
  match elig:
    case False{}: InlBank{has, tr}
    case True{}:
      +nb = b5k_list_len(IrBlock, blks)
      +is_sc = U32.is_eq(um_get(cc, fid), 1)
      +max_nr = Bool.pick(U32, sc_only, 640, 320)
      +sc_ok = Bool.or(Bool.not(sc_only), is_sc)
      ok = Bool.and(sc_ok, Bool.and(U32.is_lt(fid, 2048), Bool.and(U32.is_le(nregs, max_nr), Bool.and(U32.is_ge(nb, 1), Bool.and(U32.is_le(nb, max_blks), Bool.and(U32.is_le(opt_blks_op_count(blks, 0), max_ops), Bool.not(opt_blks_has_bad(leaf, sc_only, fid, blks))))))))
      opt_collect_put(ok, fid, ar, nregs, blks, has, tr)
def opt_collect_inlines_go(+sc_only: Bool, +cc: U32Map, +leaf: Bool, +max_ops: U32, +max_blks: U32, fns: List<&2, IrFn>, bank: InlBank) -> InlBank:
  match fns bank:
    case Nil{} _: bank
    case Con{IrFn{+fid, _, ar, nregs, _, eff, is_m, blks}, t} InlBank{has, tr}:
      elig = Bool.and(U32.is_ge(fid, 3), Bool.and(Bool.not(eff), Bool.not(is_m)))
      opt_collect_inlines_go(sc_only, cc, leaf, max_ops, max_blks, t, opt_collect_one(elig, sc_only, cc, leaf, max_ops, max_blks, fid, ar, nregs, blks, has, tr))
def opt_collect_inlines(+sc_only: Bool, +leaf: Bool, +max_ops: U32, +max_blks: U32, +fns: List<&2, IrFn>, bank: InlBank) -> InlBank:
  cc = Bool.pick(U32Map, sc_only, opt_cc_fns(opt_fn_reach(fns), fns, UM0{}), UM0{})
  opt_collect_inlines_go(sc_only, cc, leaf, max_ops, max_blks, fns, bank)
def opt_ops_pure_stc(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{ICallDirect{_, _, _}, _}: False{}
    case Con{ICallClosure{_, _, _}, _}: False{}
    case Con{IApply{_, _, _}, _}: False{}
    case Con{IArrOp{_, _, _}, _}: False{}
    case Con{ICtor{_, _, _}, _}: False{}
    case Con{ITake{_, _}, _}: False{}
    case Con{IReuse{_, _, _, _}, _}: False{}
    case Con{_, t}: opt_ops_pure_stc(t)
def opt_blks_self_tc_only(+fid: U32, blks: List<&2, IrBlock>, has_tc: Bool) -> Bool:
  match blks:
    case Nil{}: has_tc
    case Con{IrBlock{_, ops, TTailCall{+cfid, _}}, t}:
      Bool.and(U32.is_eq(cfid, fid), Bool.and(opt_ops_pure_stc(ops), opt_blks_self_tc_only(fid, t, True{})))
    case Con{IrBlock{_, ops, _}, t}:
      Bool.and(opt_ops_pure_stc(ops), opt_blks_self_tc_only(fid, t, has_tc))
def opt_collect_stc_one(elig: Bool, +fid: U32, +ar: U32, +nregs: U32, +blks: List<&2, IrBlock>, has: U32Map, tr: RaVec<Maybe<&2, InlEntry>>) -> InlBank:
  match elig:
    case False{}: InlBank{has, tr}
    case True{}:
      +nb = b5k_list_len(IrBlock, blks)
      ok = Bool.and(U32.is_lt(fid, 2048), Bool.and(U32.is_le(ar, 8), Bool.and(U32.is_le(nregs, 48), Bool.and(U32.is_ge(nb, 1), Bool.and(U32.is_le(nb, 4), Bool.and(U32.is_le(opt_blks_op_count(blks, 0), 30), opt_blks_self_tc_only(fid, blks, False{})))))))
      opt_collect_put(ok, fid, ar, nregs, blks, has, tr)
def opt_collect_self_tc(fns: List<&2, IrFn>, bank: InlBank) -> InlBank:
  match fns bank:
    case Nil{} _: bank
    case Con{IrFn{+fid, _, ar, nregs, _, eff, is_m, blks}, t} InlBank{has, tr}:
      elig = Bool.and(U32.is_ge(fid, 3), Bool.and(Bool.not(eff), Bool.not(is_m)))
      opt_collect_self_tc(t, opt_collect_stc_one(elig, fid, ar, nregs, blks, has, tr))
def opt_find_inline(tr: RaVec<Maybe<&2, InlEntry>>, +fid: U32) -> Maybe<&2, InlEntry>:
  ra_vec_get(Maybe<&2, InlEntry>, 6n, None{}, fid, tr)
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
    case IMutField{o, idx, v}: IMutField{U32.add(b, o), idx, U32.add(b, v)}
    case IFail{c}: IFail{c}
def opt_shift_arms(+bb: U32, arms: List<&2, IrSwitchArm>) -> List<&2, IrSwitchArm>:
  match arms:
    case Nil{}: Nil{}
    case Con{IrArm{tag, tgt}, t}: Con{IrArm{tag, U32.add(bb, tgt)}, opt_shift_arms(bb, t)}
def opt_inl_emit_args(args: List<&2, U32>, +base: U32, +idx: U32, acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match args:
    case Nil{}: acc
    case Con{a, t}: opt_inl_emit_args(t, base, U32.add(idx, 1), Con{ICopy{U32.add(base, idx), a}, acc})
def opt_inl_emit_body(+base: U32, ops: List<&2, IrOp>, acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: acc
    case Con{op, t}: opt_inl_emit_body(base, t, Con{opt_shift_op(base, op), acc})
def opt_inl_stc_p1(+bv: U32, +car: U32, +scr: U32, args: List<&2, U32>, +idx: U32, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match args:
    case Nil{}: acc
    case Con{+a, t}:
      acc1 = Bool.pick(List<&2, IrOp>, Bool.and(U32.is_ne(a, idx), U32.is_lt(a, car)), Con{ICopy{U32.add(scr, idx), U32.add(bv, a)}, acc}, acc)
      opt_inl_stc_p1(bv, car, scr, t, U32.add(idx, 1), acc1)
def opt_inl_stc_p2(+bv: U32, +car: U32, +scr: U32, args: List<&2, U32>, +idx: U32, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match args:
    case Nil{}: acc
    case Con{+a, t}:
      src = Bool.pick(U32, U32.is_lt(a, car), U32.add(scr, idx), U32.add(bv, a))
      acc1 = Bool.pick(List<&2, IrOp>, U32.is_eq(a, idx), acc, Con{ICopy{U32.add(bv, idx), src}, acc})
      opt_inl_stc_p2(bv, car, scr, t, U32.add(idx, 1), acc1)
def opt_remap_tc(is_self: Bool, is_tail: Bool, +bv: U32, +bb: U32, +car: U32, +scr: U32, +dst: U32, +cont: U32, id: U32, ops: List<&2, IrOp>, cfid: U32, +args: List<&2, U32>) -> IrBlock:
  match is_self is_tail:
    case True{} _:
      a0 = opt_inl_emit_body(bv, ops, Nil{})
      a2 = opt_inl_stc_p2(bv, car, scr, args, 0, opt_inl_stc_p1(bv, car, scr, args, 0, a0))
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, a2), TJmp{bb}}
    case False{} True{}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TTailCall{cfid, opt_shift_u32(bv, args)}}
    case False{} False{}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, Con{ICallDirect{dst, cfid, opt_shift_u32(bv, args)}, opt_inl_emit_body(bv, ops, Nil{})}), TJmp{cont}}
def opt_remap_one_blk(is_tail: Bool, +loop_tc: Bool, +callee: U32, +car: U32, +scr: U32, +bv: U32, +bb: U32, +dst: U32, +cont: U32, blk: IrBlock) -> IrBlock:
  match is_tail blk:
    case True{} IrBlock{id, ops, TRet{rv}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TRet{U32.add(bv, rv)}}
    case False{} IrBlock{id, ops, TRet{rv}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, Con{ICopy{dst, U32.add(bv, rv)}, opt_inl_emit_body(bv, ops, Nil{})}), TJmp{cont}}
    case _ IrBlock{id, ops, TTailCall{+cfid, +args}}:
      opt_remap_tc(Bool.and(loop_tc, Bool.and(U32.is_eq(cfid, callee), U32.is_eq(b5k_u32_list_len(args), car))), is_tail, bv, bb, car, scr, dst, cont, id, ops, cfid, args)
    case _ IrBlock{id, ops, TJmp{tgt}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TJmp{U32.add(bb, tgt)}}
    case _ IrBlock{id, ops, TBr{c, tb, fb}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TBr{U32.add(bv, c), U32.add(bb, tb), U32.add(bb, fb)}}
    case _ IrBlock{id, ops, TSwitch{s, arms, db}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TSwitch{U32.add(bv, s), opt_shift_arms(bb, arms), U32.add(bb, db)}}
    case _ IrBlock{id, ops, TFail{c}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TFail{c}}
def opt_remap_blks(+is_tail: Bool, +loop_tc: Bool, +callee: U32, +car: U32, +scr: U32, +bv: U32, +bb: U32, +dst: U32, +cont: U32, blks: List<&2, IrBlock>, acc: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: acc
    case Con{b, t}: opt_remap_blks(is_tail, loop_tc, callee, car, scr, bv, bb, dst, cont, t, Con{opt_remap_one_blk(is_tail, loop_tc, callee, car, scr, bv, bb, dst, cont, b), acc})
type InlCur is Data:
  InlCur{cur_id: U32, ops_rev: List<&2, IrOp>, blks_rev: List<&2, IrBlock>, nr: U32, nb: U32, bud: U32}
def opt_inl_call_body(ok: Bool, +loop_tc: Bool, +car: U32, +cnr: U32, +cmb: U32, cblks: List<&2, IrBlock>, +d: U32, +cfid: U32, +args: List<&2, U32>, +cid: U32, +orev: List<&2, IrOp>, +brev: List<&2, IrBlock>, +nr: U32, +nb: U32, +bud: U32) -> InlCur:
  match ok cblks:
    case False{} _: InlCur{cid, Con{ICallDirect{d, cfid, args}, orev}, brev, nr, nb, bud}
    case True{} Con{IrBlock{_, cops, TRet{+rv}}, Nil{}}:
      a1 = opt_inl_emit_args(args, nr, 0, orev)
      a2 = opt_inl_emit_body(nr, cops, a1)
      need = U32.max(cnr, U32.max(car, U32.add(rv, 1)))
      InlCur{cid, Con{ICopy{d, U32.add(nr, rv)}, a2}, brev, U32.add(nr, need), nb, U32.sub(bud, 1)}
    case True{} cblks0:
      need = U32.max(cnr, U32.max(car, 1))
      +scr = U32.add(nr, need)
      +cont = U32.add(nb, U32.add(cmb, 1))
      brev1 = opt_remap_blks(False{}, loop_tc, cfid, car, scr, nr, nb, d, cont, cblks0, Con{IrBlock{cid, b5k_list_rev(IrOp, opt_inl_emit_args(args, nr, 0, orev)), TJmp{nb}}, brev})
      InlCur{cont, Nil{}, brev1, Bool.pick(U32, loop_tc, U32.add(scr, car), scr), U32.add(cont, 1), U32.sub(bud, 1)}
def opt_inl_call_apply(+loop_tc: Bool, me: Maybe<&2, InlEntry>, d: U32, cfid: U32, +args: List<&2, U32>, st: InlCur) -> InlCur:
  match me st:
    case None{} InlCur{cid, orev, brev, nr, nb, bud}:
      InlCur{cid, Con{ICallDirect{d, cfid, args}, orev}, brev, nr, nb, bud}
    case Some{InlEntry{_, +car, cnr, cmb, cblks}} InlCur{cid, orev, brev, nr, nb, bud}:
      opt_inl_call_body(U32.is_eq(b5k_u32_list_len(args), car), loop_tc, car, cnr, cmb, cblks, d, cfid, args, cid, orev, brev, nr, nb, bud)
def opt_inl_one_call(can: Bool, loop_tc: Bool, tr: RaVec<Maybe<&2, InlEntry>>, d: U32, +cfid: U32, args: List<&2, U32>, st: InlCur) -> InlCur:
  match can st:
    case False{} InlCur{cid, orev, brev, nr, nb, bud}: InlCur{cid, Con{ICallDirect{d, cfid, args}, orev}, brev, nr, nb, bud}
    case True{} st0: opt_inl_call_apply(loop_tc, opt_find_inline(tr, cfid), d, cfid, args, st0)
def opt_inl_ops(+loop_tc: Bool, +self_fid: U32, +has: U32Map, +tr: RaVec<Maybe<&2, InlEntry>>, ops: List<&2, IrOp>, st: InlCur) -> InlCur:
  match ops st:
    case Nil{} _: st
    case Con{ICallDirect{d, +cfid, args}, t} InlCur{cid, orev, brev, +nr, +nb, +bud}:
      can = Bool.and(U32.is_ne(cfid, self_fid), Bool.and(U32.is_gt(bud, 0), Bool.and(U32.is_lt(nr, 4096), Bool.and(U32.is_lt(nb, 512), U32.is_ne(um_get(has, cfid), 0)))))
      opt_inl_ops(loop_tc, self_fid, has, tr, t, opt_inl_one_call(can, loop_tc, tr, d, cfid, args, InlCur{cid, orev, brev, nr, nb, bud}))
    case Con{op, t} InlCur{cid, orev, brev, nr, nb, bud}:
      opt_inl_ops(loop_tc, self_fid, has, tr, t, InlCur{cid, Con{op, orev}, brev, nr, nb, bud})
def opt_inl_tail_body(ok: Bool, +loop_tc: Bool, +car: U32, +cnr: U32, +cmb: U32, cblks: List<&2, IrBlock>, +cfid: U32, args: List<&2, U32>, +cid: U32, orev: List<&2, IrOp>, brev: List<&2, IrBlock>, +nr: U32, +nb: U32, bud: U32) -> InlCur:
  match ok:
    case False{}: InlCur{cid, Nil{}, Con{IrBlock{cid, b5k_list_rev(IrOp, orev), TTailCall{cfid, args}}, brev}, nr, nb, bud}
    case True{}:
      need = U32.max(cnr, U32.max(car, 1))
      +scr = U32.add(nr, need)
      brev1 = opt_remap_blks(True{}, loop_tc, cfid, car, scr, nr, nb, 0, 0, cblks, Con{IrBlock{cid, b5k_list_rev(IrOp, opt_inl_emit_args(args, nr, 0, orev)), TJmp{nb}}, brev})
      InlCur{cid, Nil{}, brev1, Bool.pick(U32, loop_tc, U32.add(scr, car), scr), U32.add(nb, U32.add(cmb, 1)), U32.sub(bud, 1)}
def opt_inl_tail_apply(+loop_tc: Bool, me: Maybe<&2, InlEntry>, cfid: U32, +args: List<&2, U32>, st: InlCur) -> InlCur:
  match me st:
    case None{} InlCur{+cid, orev, brev, nr, nb, bud}:
      InlCur{cid, Nil{}, Con{IrBlock{cid, b5k_list_rev(IrOp, orev), TTailCall{cfid, args}}, brev}, nr, nb, bud}
    case Some{InlEntry{_, +car, cnr, cmb, cblks}} InlCur{cid, orev, brev, nr, nb, bud}:
      opt_inl_tail_body(U32.is_eq(b5k_u32_list_len(args), car), loop_tc, car, cnr, cmb, cblks, cfid, args, cid, orev, brev, nr, nb, bud)
def opt_inl_one_tail(can: Bool, loop_tc: Bool, tr: RaVec<Maybe<&2, InlEntry>>, +cfid: U32, args: List<&2, U32>, st: InlCur) -> InlCur:
  match can st:
    case False{} InlCur{+cid, orev, brev, nr, nb, bud}:
      InlCur{cid, Nil{}, Con{IrBlock{cid, b5k_list_rev(IrOp, orev), TTailCall{cfid, args}}, brev}, nr, nb, bud}
    case True{} st0: opt_inl_tail_apply(loop_tc, opt_find_inline(tr, cfid), cfid, args, st0)
def opt_inl_fin_term(+loop_tc: Bool, +self_fid: U32, +has: U32Map, +tr: RaVec<Maybe<&2, InlEntry>>, term: IrTerm, st: InlCur) -> InlCur:
  match term st:
    case TTailCall{+cfid, args} InlCur{cid, orev, brev, +nr, +nb, +bud}:
      can = Bool.and(U32.is_ne(cfid, self_fid), Bool.and(U32.is_gt(bud, 0), Bool.and(U32.is_lt(nr, 2048), Bool.and(U32.is_lt(nb, 256), U32.is_ne(um_get(has, cfid), 0)))))
      opt_inl_one_tail(can, loop_tc, tr, cfid, args, InlCur{cid, orev, brev, nr, nb, bud})
    case other InlCur{+cid, orev, brev, nr, nb, bud}:
      InlCur{cid, Nil{}, Con{IrBlock{cid, b5k_list_rev(IrOp, orev), other}, brev}, nr, nb, bud}
type InlBlksRes is Data:
  InlBlksRes{blks: List<&2, IrBlock>, nregs: U32}
def opt_inl_blks(+loop_tc: Bool, +self_fid: U32, +has: U32Map, +tr: RaVec<Maybe<&2, InlEntry>>, blks: List<&2, IrBlock>, st: InlCur) -> InlBlksRes:
  match blks st:
    case Nil{} InlCur{_, _, brev, nr, _, _}: InlBlksRes{b5k_list_rev(IrBlock, brev), nr}
    case Con{IrBlock{id, ops, term}, t} InlCur{_, _, brev, nr, nb, bud}:
      st1 = opt_inl_ops(loop_tc, self_fid, has, tr, ops, InlCur{id, Nil{}, brev, nr, nb, bud})
      opt_inl_blks(loop_tc, self_fid, has, tr, t, opt_inl_fin_term(loop_tc, self_fid, has, tr, term, st1))
def opt_inl_fn_fin(fid: U32, nm: String, ar: U32, esc: Bool, eff: Bool, is_m: Bool, r: InlBlksRes) -> IrFn:
  match r:
    case InlBlksRes{blks2, nr2}: IrFn{fid, nm, ar, nr2, esc, eff, is_m, blks2}
def opt_inl_fn(+loop_tc: Bool, +bud0: U32, bank: InlBank, f: IrFn) -> IrFn:
  match bank f:
    case InlBank{has, tr} IrFn{+fid, nm, ar, nregs, esc, eff, is_m, +blks}:
      nb0 = U32.add(opt_blks_max_id(blks, 0), 1)
      opt_inl_fn_fin(fid, nm, ar, esc, eff, is_m, opt_inl_blks(loop_tc, fid, has, tr, blks, InlCur{0, Nil{}, Nil{}, nregs, nb0, bud0}))
def opt_inl_all(+loop_tc: Bool, +bud0: U32, +bank: InlBank, fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_inl_fn(loop_tc, bud0, bank, f), opt_inl_all(loop_tc, bud0, bank, t)}
# Pass E — N-Field Worker-Wrapper Unboxing (arity 2..4, IKeep aliases, loop-hoist)
def opt_u32_nth_go(xs: List<&2, U32>, n: Nat) -> U32:
  match xs n:
    case Nil{} _: 0
    case Con{v, _} 0n: U32.add(v, 1)
    case Con{_, t} 1n+p: opt_u32_nth_go(t, p)
def opt_u32_nth(xs: List<&2, U32>, idx: U32) -> U32:
  opt_u32_nth_go(xs, U32.to_nat(idx))
def opt_u32_rep_app(xs: List<&2, U32>, +idx: U32, +cur: U32, +f0: U32, tail: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: tail
    case Con{v, t}: Con{Bool.pick(U32, U32.is_eq(cur, idx), f0, v), opt_u32_rep_app(t, idx, U32.add(cur, 1), f0, tail)}
def opt_ww_seq(n: Nat, +b: U32) -> List<&2, U32>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{b, opt_ww_seq(p, U32.add(b, 1))}
def opt_ww_alias(+defc: U32Map, +ar: U32, +blks: List<&2, IrBlock>) -> U32Map:
  m0 = opt_ip_init_orig(U32.to_nat(ar), 0, UM0{})
  opt_ip_orig_blks(defc, ar, blks, opt_ip_orig_blks(defc, ar, blks, m0))
def opt_ww_tag_ops(+al: U32Map, ops: List<&2, IrOp>, +tgs: U32Map, +cmps: U32Map) -> U32Map:
  match ops:
    case Nil{}: cmps
    case Con{ITag{d, s}, t}:
      opt_ww_tag_ops(al, t, Bool.pick(U32Map, U32.is_ne(um_get(al, s), 0), um_set(tgs, d, 1), tgs), cmps)
    case Con{ICmp{d, _, a, b}, t}:
      is_t = Bool.or(U32.is_ne(um_get(tgs, a), 0), U32.is_ne(um_get(tgs, b), 0))
      opt_ww_tag_ops(al, t, tgs, Bool.pick(U32Map, is_t, um_set(cmps, d, 1), cmps))
    case Con{_, t}: opt_ww_tag_ops(al, t, tgs, cmps)
def opt_ww_tag_tgts(+al: U32Map, blks: List<&2, IrBlock>, +m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, TBr{c, tb, _}}, t}:
      cmps = opt_ww_tag_ops(al, ops, UM0{}, UM0{})
      opt_ww_tag_tgts(al, t, Bool.pick(U32Map, U32.is_ne(um_get(cmps, c), 0), um_set(m, tb, 1), m))
    case Con{_, t}: opt_ww_tag_tgts(al, t, m)
def opt_ww_bad_one(+al: U32Map, u: U32, +bp: U32Map) -> U32Map:
  +a = um_get(al, u)
  Bool.pick(U32Map, U32.is_ne(a, 0), um_set(bp, U32.sub(a, 1), 1), bp)
def opt_ww_bad_list(+al: U32Map, xs: List<&2, U32>, bp: U32Map) -> U32Map:
  match xs:
    case Nil{}: bp
    case Con{u, t}: opt_ww_bad_list(al, t, opt_ww_bad_one(al, u, bp))
def opt_ww_bad_op(+al: U32Map, op: IrOp, bp: U32Map) -> U32Map:
  match op:
    case ICopy{_, s}: opt_ww_bad_one(al, s, bp)
    case IBin{_, _, a, b}: opt_ww_bad_one(al, b, opt_ww_bad_one(al, a, bp))
    case IUn{_, _, s}: opt_ww_bad_one(al, s, bp)
    case ICmp{_, _, a, b}: opt_ww_bad_one(al, b, opt_ww_bad_one(al, a, bp))
    case ICallDirect{_, _, args}: opt_ww_bad_list(al, args, bp)
    case ICallClosure{_, _, caps}: opt_ww_bad_list(al, caps, bp)
    case IApply{_, c, a}: opt_ww_bad_one(al, a, opt_ww_bad_one(al, c, bp))
    case ICtor{_, _, fs}: opt_ww_bad_list(al, fs, bp)
    case ITake{_, s}: opt_ww_bad_one(al, s, bp)
    case ITag{_, s}: opt_ww_bad_one(al, s, bp)
    case IKeep{_, s}: opt_ww_bad_one(al, s, bp)
    case ISink{s}: opt_ww_bad_one(al, s, bp)
    case IReuse{_, sl, _, fs}: opt_ww_bad_list(al, fs, opt_ww_bad_one(al, sl, bp))
    case IArrOp{_, _, args}: opt_ww_bad_list(al, args, bp)
    case ILoad{_, b, _}: opt_ww_bad_one(al, b, bp)
    case IStore{b, _, v}: opt_ww_bad_one(al, v, opt_ww_bad_one(al, b, bp))
    case IMutField{o, _, v}: opt_ww_bad_one(al, v, opt_ww_bad_one(al, o, bp))
    case _: bp
type WwScan is Data:
  WwScan{bp: U32Map, tk_ar: U32Map, has_tag: U32Map, has_self: U32Map, has_raw: U32Map, has_ret: U32Map}
def opt_ww_scan_take(+in_tag: Bool, +al: U32Map, ds: List<&2, U32>, s: U32, st: WwScan) -> WwScan:
  match st:
    case WwScan{+bp, +ta, ht, hs, +hr, hrt}:
      +a = um_get(al, s)
      +k = b5k_u32_list_len(ds)
      +p = U32.sub(a, 1)
      +cur = um_get(ta, p)
      +ok = Bool.and(U32.is_ge(k, 2), Bool.and(U32.is_le(k, 8), Bool.or(U32.is_zero(cur), U32.is_eq(cur, k))))
      bp1 = Bool.pick(U32Map, Bool.and(U32.is_ne(a, 0), Bool.not(ok)), um_set(bp, p, 1), bp)
      ta1 = Bool.pick(U32Map, Bool.and(U32.is_ne(a, 0), ok), um_set(ta, p, k), ta)
      hr1 = Bool.pick(U32Map, Bool.and(U32.is_ne(a, 0), Bool.and(ok, Bool.not(in_tag))), um_set(hr, p, 1), hr)
      WwScan{bp1, ta1, ht, hs, hr1, hrt}
def opt_ww_scan_copy(+al: U32Map, +d: U32, +s: U32, st: WwScan) -> WwScan:
  match st:
    case WwScan{+bp, ta, ht, hs, hr, hrt}:
      +as0 = um_get(al, s)
      ok = Bool.or(U32.is_zero(as0), Bool.or(U32.is_eq(d, s), U32.is_eq(um_get(al, d), as0)))
      WwScan{Bool.pick(U32Map, ok, bp, um_set(bp, U32.sub(as0, 1), 1)), ta, ht, hs, hr, hrt}
def opt_ww_scan_ctor(+al: U32Map, fs: List<&2, U32>, +hrt: U32Map) -> U32Map:
  match fs:
    case Nil{}: hrt
    case Con{v, t}:
      +a = um_get(al, v)
      opt_ww_scan_ctor(al, t, Bool.pick(U32Map, U32.is_ne(a, 0), um_set(hrt, U32.sub(a, 1), 1), hrt))
def opt_ww_scan_ops(+in_tag: Bool, +al: U32Map, ops: List<&2, IrOp>, st: WwScan) -> WwScan:
  match ops st:
    case Nil{} _: st
    case Con{ITake{ds, s}, t} _: opt_ww_scan_ops(in_tag, al, t, opt_ww_scan_take(in_tag, al, ds, s, st))
    case Con{ITag{_, s}, t} WwScan{bp, ta, +ht, hs, hr, hrt}:
      +a = um_get(al, s)
      opt_ww_scan_ops(in_tag, al, t, WwScan{bp, ta, Bool.pick(U32Map, U32.is_ne(a, 0), um_set(ht, U32.sub(a, 1), 1), ht), hs, hr, hrt})
    case Con{ISink{_}, t} _: opt_ww_scan_ops(in_tag, al, t, st)
    case Con{ICopy{d, s}, t} _: opt_ww_scan_ops(in_tag, al, t, opt_ww_scan_copy(al, d, s, st))
    case Con{IKeep{d, s}, t} _: opt_ww_scan_ops(in_tag, al, t, opt_ww_scan_copy(al, d, s, st))
    case Con{ICtor{_, _, fs}, t} WwScan{bp, ta, ht, hs, hr, hrt}:
      opt_ww_scan_ops(in_tag, al, t, WwScan{bp, ta, ht, hs, hr, opt_ww_scan_ctor(al, fs, hrt)})
    case Con{op, t} WwScan{bp, ta, ht, hs, hr, hrt}:
      opt_ww_scan_ops(in_tag, al, t, WwScan{opt_ww_bad_op(al, op, bp), ta, ht, hs, hr, hrt})
def opt_ww_scan_self(+al: U32Map, args: List<&2, U32>, +idx: U32, st: WwScan) -> WwScan:
  match args st:
    case Nil{} _: st
    case Con{v, t} WwScan{+bp, ta, ht, +hs, hr, hrt}:
      +a = um_get(al, v)
      +is_sp = U32.is_eq(a, U32.add(idx, 1))
      bp1 = Bool.pick(U32Map, Bool.and(U32.is_ne(a, 0), Bool.not(is_sp)), um_set(bp, U32.sub(a, 1), 1), bp)
      hs1 = Bool.pick(U32Map, is_sp, um_set(hs, idx, 1), hs)
      opt_ww_scan_self(al, t, U32.add(idx, 1), WwScan{bp1, ta, ht, hs1, hr, hrt})
def opt_ww_scan_term(+sfid: U32, +al: U32Map, term: IrTerm, st: WwScan) -> WwScan:
  match term st:
    case TTailCall{cfid, +args} WwScan{+bp, +ta, +ht, +hs, +hr, +hrt}:
      Bool.pick(WwScan, U32.is_eq(cfid, sfid), opt_ww_scan_self(al, args, 0, WwScan{bp, ta, ht, hs, hr, hrt}), WwScan{opt_ww_bad_list(al, args, bp), ta, ht, hs, hr, hrt})
    case TBr{c, _, _} WwScan{bp, ta, ht, hs, hr, hrt}: WwScan{opt_ww_bad_one(al, c, bp), ta, ht, hs, hr, hrt}
    case TSwitch{s, _, _} WwScan{bp, ta, ht, hs, hr, hrt}: WwScan{opt_ww_bad_one(al, s, bp), ta, ht, hs, hr, hrt}
    case TRet{v} WwScan{bp, ta, ht, hs, hr, +hrt}:
      +a = um_get(al, v)
      WwScan{bp, ta, ht, hs, hr, Bool.pick(U32Map, U32.is_ne(a, 0), um_set(hrt, U32.sub(a, 1), 1), hrt)}
    case _ _: st
def opt_ww_scan_blks(+sfid: U32, +al: U32Map, +tgts: U32Map, blks: List<&2, IrBlock>, st: WwScan) -> WwScan:
  match blks st:
    case Nil{} _: st
    case Con{IrBlock{id, ops, term}, t} _:
      st1 = opt_ww_scan_ops(U32.is_ne(um_get(tgts, id), 0), al, ops, st)
      opt_ww_scan_blks(sfid, al, tgts, t, opt_ww_scan_term(sfid, al, term, st1))
def opt_ww_mark_cands(+fid: U32, +ar: U32, +defc: U32Map, st: WwScan, n: Nat, +idx: U32, +cm: U32Map) -> U32Map:
  match st n:
    case _ 0n: cm
    case WwScan{+bp, +ta, +ht, +hs, +hr, +hrt} 1n+p:
      +k = um_get(ta, idx)
      ok = Bool.and(U32.is_zero(um_get(defc, idx)), Bool.and(U32.is_zero(um_get(bp, idx)), Bool.and(U32.is_ge(k, 2), Bool.and(U32.is_le(k, 8), U32.is_le(U32.add(ar, k), 28)))))
      can_h = Bool.and(U32.is_zero(um_get(hrt, idx)), Bool.and(U32.is_ne(um_get(hs, idx), 0), U32.is_ne(um_get(hr, idx), 0)))
      code = U32.add(k, Bool.pick(U32, can_h, Bool.pick(U32, U32.is_ne(um_get(ht, idx), 0), 20, 10), 0))
      cm1 = Bool.pick(U32Map, ok, um_set(cm, opt_pkey(fid, idx), code), cm)
      opt_ww_mark_cands(fid, ar, defc, WwScan{bp, ta, ht, hs, hr, hrt}, p, U32.add(idx, 1), cm1)
def opt_ww_cand_one(elig: Bool, +fid: U32, +ar: U32, +blks: List<&2, IrBlock>, cm: U32Map) -> U32Map:
  match elig:
    case False{}: cm
    case True{}:
      +defc = opt_blks_defs(blks, UM0{})
      +al = opt_ww_alias(defc, ar, blks)
      tgts = opt_ww_tag_tgts(al, blks, UM0{})
      st = opt_ww_scan_blks(fid, al, tgts, blks, WwScan{UM0{}, UM0{}, UM0{}, UM0{}, UM0{}, UM0{}})
      opt_ww_mark_cands(fid, ar, defc, st, U32.to_nat(ar), 0, cm)
def opt_ww_cand_fns(+bad_fn: U32Map, fns: List<&2, IrFn>, cm: U32Map) -> U32Map:
  match fns:
    case Nil{}: cm
    case Con{IrFn{+fid, _, +ar, _, _, _, _, blks}, t}:
      elig = Bool.and(U32.is_zero(um_get(bad_fn, fid)), Bool.and(U32.is_ge(ar, 1), U32.is_lt(ar, 26)))
      opt_ww_cand_fns(bad_fn, t, opt_ww_cand_one(elig, fid, ar, blks, cm))
type WwCtorEnt is Data:
  WNone{}
  WSome{vreg: U32, cid: U32, ar: U32, fs: List<&2, U32>}
def opt_ww_put_pc(ok: Bool, pc: RaVec<WwCtorEnt>, +d: U32, cid: U32, k: U32, fs: List<&2, U32>) -> RaVec<WwCtorEnt>:
  match ok:
    case True{}: ra_vec_set(WwCtorEnt, 6n, d, WSome{d, cid, k, fs}, pc)
    case False{}: pc
def opt_ww_obs_ent(pe: WwCtorEnt, +a: U32, +ck: U32, +k: U32, +obs: U32Map) -> U32Map:
  match pe:
    case WNone{}:
      +can_h = U32.is_ge(ck, 10)
      +cur = um_get(obs, k)
      um_set(obs, k, Bool.pick(U32, Bool.and(can_h, U32.is_ne(cur, 4294967295)), 4294967294, 4294967295))
    case WSome{v, +cid, ar, _}:
      +need_ar = U32.mod(ck, 10)
      +can_h = U32.is_ge(ck, 10)
      +cur = um_get(obs, k)
      +c1 = U32.add(cid, 1)
      ok = Bool.and(U32.is_eq(v, a), U32.is_eq(ar, need_ar))
      +fb = Bool.pick(U32, Bool.and(can_h, U32.is_ne(cur, 4294967295)), 4294967294, 4294967295)
      nv = Bool.pick(U32, ok, Bool.pick(U32, U32.is_zero(cur), c1, Bool.pick(U32, U32.is_eq(cur, c1), cur, fb)), fb)
      um_set(obs, k, nv)
def opt_ww_obs_args(+sfid: U32, +cfid: U32, +cand: U32Map, +al: U32Map, +pc: RaVec<WwCtorEnt>, args: List<&2, U32>, +idx: U32, +obs: U32Map) -> U32Map:
  match args:
    case Nil{}: obs
    case Con{+a, t}:
      +k = opt_pkey(cfid, idx)
      +ck = Bool.pick(U32, Bool.and(U32.is_lt(cfid, 2048), U32.is_lt(idx, 64)), um_get(cand, k), 0)
      is_sp = Bool.and(U32.is_eq(cfid, sfid), U32.is_eq(um_get(al, a), U32.add(idx, 1)))
      chk = Bool.and(U32.is_ne(ck, 0), Bool.not(is_sp))
      obs1 = Bool.pick(U32Map, chk, opt_ww_obs_ent(ra_vec_get(WwCtorEnt, 6n, WNone{}, a, pc), a, ck, k, obs), obs)
      opt_ww_obs_args(sfid, cfid, cand, al, pc, t, U32.add(idx, 1), obs1)
type WwObsBlk is Data:
  WwObsBlk{pc: RaVec<WwCtorEnt>, obs: U32Map}
def opt_ww_obs_ops(+sfid: U32, +defc: U32Map, +uses: U32Map, +ar: U32, +al: U32Map, +cand: U32Map, ops: List<&2, IrOp>, st: WwObsBlk) -> WwObsBlk:
  match ops st:
    case Nil{} _: st
    case Con{ICtor{+d, cid, +fs}, t} WwObsBlk{pc, obs}:
      +k = b5k_u32_list_len(fs)
      ok = Bool.and(U32.is_ge(k, 2), Bool.and(U32.is_le(k, 8), Bool.and(U32.is_lt(d, 4095), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(U32.is_eq(um_get(uses, d), 1), opt_all_can_prop(defc, ar, fs))))))
      opt_ww_obs_ops(sfid, defc, uses, ar, al, cand, t, WwObsBlk{opt_ww_put_pc(ok, pc, d, cid, k, fs), obs})
    case Con{ICallDirect{_, cfid, args}, t} WwObsBlk{+pc, obs}:
      opt_ww_obs_ops(sfid, defc, uses, ar, al, cand, t, WwObsBlk{pc, opt_ww_obs_args(sfid, cfid, cand, al, pc, args, 0, obs)})
    case Con{_, t} _: opt_ww_obs_ops(sfid, defc, uses, ar, al, cand, t, st)
def opt_ww_obs_term(+sfid: U32, +al: U32Map, +cand: U32Map, term: IrTerm, st: WwObsBlk) -> U32Map:
  match term st:
    case TTailCall{cfid, args} WwObsBlk{pc, obs}: opt_ww_obs_args(sfid, cfid, cand, al, pc, args, 0, obs)
    case _ WwObsBlk{_, obs}: obs
def opt_ww_obs_blks(+sfid: U32, +defc: U32Map, +uses: U32Map, +ar: U32, +al: U32Map, +cand: U32Map, blks: List<&2, IrBlock>, obs: U32Map) -> U32Map:
  match blks:
    case Nil{}: obs
    case Con{IrBlock{_, ops, term}, t}:
      obs1 = opt_ww_obs_term(sfid, al, cand, term, opt_ww_obs_ops(sfid, defc, uses, ar, al, cand, ops, WwObsBlk{RVEmpty{}, obs}))
      opt_ww_obs_blks(sfid, defc, uses, ar, al, cand, t, obs1)
def opt_ww_obs_one(live: Bool, +fid: U32, +ar: U32, +cand: U32Map, +blks: List<&2, IrBlock>, obs: U32Map) -> U32Map:
  match live:
    case False{}: obs
    case True{}:
      +defc = opt_blks_defs(blks, UM0{})
      uses = opt_blks_uses(blks, UM0{})
      al = opt_ww_alias(defc, ar, blks)
      opt_ww_obs_blks(fid, defc, uses, ar, al, cand, blks, obs)
def opt_ww_obs_fns(+reach: U32Map, +cand: U32Map, fns: List<&2, IrFn>, obs: U32Map) -> U32Map:
  match fns:
    case Nil{}: obs
    case Con{IrFn{+fid, _, ar, _, _, _, _, blks}, t}:
      opt_ww_obs_fns(reach, cand, t, opt_ww_obs_one(U32.is_ne(um_get(reach, fid), 0), fid, ar, cand, blks, obs))
type WwPlan is Data:
  WwPlan{pidx: U32Map, par: U32Map, pcid: U32Map, any: Bool}
def opt_ww_pick_param(+fid: U32, +cand: U32Map, +obs: U32Map, n: Nat, +idx: U32, pl: WwPlan) -> WwPlan:
  match n pl:
    case 0n _: pl
    case 1n+p WwPlan{+pi, +pa, +pc, +any}:
      +k = opt_pkey(fid, idx)
      +ck = um_get(cand, k)
      +c = um_get(obs, k)
      ok = Bool.and(U32.is_ne(ck, 0), Bool.and(U32.is_ne(c, 0), U32.is_ne(c, 4294967295)))
      cinfo = Bool.pick(U32, U32.is_eq(c, 4294967294), Bool.pick(U32, U32.is_ge(ck, 20), 4294967294, 4294967293), c)
      Bool.pick(WwPlan, ok, WwPlan{um_set(pi, fid, U32.add(idx, 1)), um_set(pa, fid, U32.mod(ck, 10)), um_set(pc, fid, cinfo), True{}},
        opt_ww_pick_param(fid, cand, obs, p, U32.add(idx, 1), WwPlan{pi, pa, pc, any}))
def opt_ww_build_plan(+bad_fn: U32Map, +cand: U32Map, +obs: U32Map, fns: List<&2, IrFn>, +pl: WwPlan) -> WwPlan:
  match fns:
    case Nil{}: pl
    case Con{IrFn{+fid, _, +ar, _, _, _, _, _}, t}:
      elig = Bool.and(U32.is_zero(um_get(bad_fn, fid)), Bool.and(U32.is_ge(ar, 1), U32.is_lt(ar, 26)))
      pl1 = Bool.pick(WwPlan, elig, opt_ww_pick_param(fid, cand, obs, U32.to_nat(ar), 0, pl), pl)
      opt_ww_build_plan(bad_fn, cand, obs, t, pl1)
def opt_bump_v(+ar: U32, +d: U32, +v: U32) -> U32:
  Bool.pick(U32, U32.is_ge(v, ar), U32.add(v, d), v)
def opt_bump_vs(+ar: U32, +d: U32, xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{v, t}: Con{opt_bump_v(ar, d, v), opt_bump_vs(ar, d, t)}
def opt_bump_op(+ar: U32, +e: U32, op: IrOp) -> IrOp:
  match op:
    case IConst{d, v}: IConst{opt_bump_v(ar, e, d), v}
    case IFlt{d, b}: IFlt{opt_bump_v(ar, e, d), b}
    case ICopy{d, s}: ICopy{opt_bump_v(ar, e, d), opt_bump_v(ar, e, s)}
    case IBin{d, bop, x, y}: IBin{opt_bump_v(ar, e, d), bop, opt_bump_v(ar, e, x), opt_bump_v(ar, e, y)}
    case IUn{d, uop, s}: IUn{opt_bump_v(ar, e, d), uop, opt_bump_v(ar, e, s)}
    case ICmp{d, cop, x, y}: ICmp{opt_bump_v(ar, e, d), cop, opt_bump_v(ar, e, x), opt_bump_v(ar, e, y)}
    case ICallDirect{d, fid, args}: ICallDirect{opt_bump_v(ar, e, d), fid, opt_bump_vs(ar, e, args)}
    case ICallClosure{d, fid, caps}: ICallClosure{opt_bump_v(ar, e, d), fid, opt_bump_vs(ar, e, caps)}
    case IApply{d, c, a}: IApply{opt_bump_v(ar, e, d), opt_bump_v(ar, e, c), opt_bump_v(ar, e, a)}
    case ICtor{d, cid, fs}: ICtor{opt_bump_v(ar, e, d), cid, opt_bump_vs(ar, e, fs)}
    case ITake{ds, s}: ITake{opt_bump_vs(ar, e, ds), opt_bump_v(ar, e, s)}
    case ITag{d, s}: ITag{opt_bump_v(ar, e, d), opt_bump_v(ar, e, s)}
    case IKeep{d, s}: IKeep{opt_bump_v(ar, e, d), opt_bump_v(ar, e, s)}
    case ISink{s}: ISink{opt_bump_v(ar, e, s)}
    case IReuse{d, sl, cid, fs}: IReuse{opt_bump_v(ar, e, d), opt_bump_v(ar, e, sl), cid, opt_bump_vs(ar, e, fs)}
    case IStatic{d, idx}: IStatic{opt_bump_v(ar, e, d), idx}
    case IArrOp{ds, aop, args}: IArrOp{opt_bump_vs(ar, e, ds), aop, opt_bump_vs(ar, e, args)}
    case IAlloca{d, w}: IAlloca{opt_bump_v(ar, e, d), w}
    case ILoad{d, b, off}: ILoad{opt_bump_v(ar, e, d), opt_bump_v(ar, e, b), off}
    case IStore{b, off, v}: IStore{opt_bump_v(ar, e, b), off, opt_bump_v(ar, e, v)}
    case IMutField{o, idx, v}: IMutField{opt_bump_v(ar, e, o), idx, opt_bump_v(ar, e, v)}
    case IFail{c}: IFail{c}
def opt_bump_ops(+ar: U32, +e: U32, ops: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: Nil{}
    case Con{op, t}: Con{opt_bump_op(ar, e, op), opt_bump_ops(ar, e, t)}
def opt_bump_term(+ar: U32, +e: U32, term: IrTerm) -> IrTerm:
  match term:
    case TBr{c, tb, fb}: TBr{opt_bump_v(ar, e, c), tb, fb}
    case TSwitch{s, arms, db}: TSwitch{opt_bump_v(ar, e, s), arms, db}
    case TRet{v}: TRet{opt_bump_v(ar, e, v)}
    case TTailCall{fid, args}: TTailCall{fid, opt_bump_vs(ar, e, args)}
    case other: other
def opt_bump_blks(+ar: U32, +e: U32, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}: Con{IrBlock{id, opt_bump_ops(ar, e, ops), opt_bump_term(ar, e, term)}, opt_bump_blks(ar, e, t)}
type WwExSt is Data:
  WwExSt{ex: U32Map, nr: U32}
def opt_ww_alloc_ex_ops(+pi1: U32, +k1: U32, +al: U32Map, ops: List<&2, IrOp>, st: WwExSt) -> WwExSt:
  match ops st:
    case Nil{} _: st
    case Con{ICopy{+d, +s}, t} WwExSt{+ex, +nr}:
      need = Bool.and(U32.is_ne(d, s), Bool.and(U32.is_eq(um_get(al, d), pi1), U32.is_zero(um_get(ex, d))))
      st1 = Bool.pick(WwExSt, need, WwExSt{um_set(ex, d, U32.add(nr, 1)), U32.add(nr, k1)}, WwExSt{ex, nr})
      opt_ww_alloc_ex_ops(pi1, k1, al, t, st1)
    case Con{IKeep{+d, +s}, t} WwExSt{+ex, +nr}:
      need = Bool.and(U32.is_ne(d, s), Bool.and(U32.is_eq(um_get(al, d), pi1), U32.is_zero(um_get(ex, d))))
      st1 = Bool.pick(WwExSt, need, WwExSt{um_set(ex, d, U32.add(nr, 1)), U32.add(nr, k1)}, WwExSt{ex, nr})
      opt_ww_alloc_ex_ops(pi1, k1, al, t, st1)
    case Con{_, t} _: opt_ww_alloc_ex_ops(pi1, k1, al, t, st)
def opt_ww_alloc_ex_blks(+pi1: U32, +k1: U32, +al: U32Map, blks: List<&2, IrBlock>, st: WwExSt) -> WwExSt:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, _}, t}: opt_ww_alloc_ex_blks(pi1, k1, al, t, opt_ww_alloc_ex_ops(pi1, k1, al, ops, st))
def opt_ww_fields(+v: U32, +ex: U32Map, +k1: U32) -> List<&2, U32>:
  Con{v, opt_ww_seq(U32.to_nat(k1), U32.sub(um_get(ex, v), 1))}
def opt_ww_emit_keeps(ds: List<&2, U32>, ss: List<&2, U32>, acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ds ss:
    case Con{d, dt} Con{s, st}: opt_ww_emit_keeps(dt, st, Con{IKeep{d, s}, acc})
    case _ _: acc
def opt_ww_rw_callee_op(+ar: U32, +pi1: U32, +k1: U32, +cinfo: U32, +al: U32Map, +ex: U32Map, op: IrOp, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match op:
    case ITake{+ds, +s}:
      Bool.pick(List<&2, IrOp>, U32.is_eq(um_get(al, s), pi1), sroa_emit_copies(ds, opt_ww_fields(s, ex, k1), acc), Con{ITake{ds, s}, acc})
    case ITag{+d, +s}:
      hit = U32.is_eq(um_get(al, s), pi1)
      rep = Bool.pick(IrOp, U32.is_eq(cinfo, 4294967294), ICopy{d, U32.add(ar, k1)}, IConst{d, U32.sub(cinfo, 1)})
      Con{Bool.pick(IrOp, hit, rep, ITag{d, s}), acc}
    case ISink{+s}:
      Bool.pick(List<&2, IrOp>, U32.is_eq(um_get(al, s), pi1), sroa_emit_sinks(opt_ww_fields(s, ex, k1), acc), Con{ISink{s}, acc})
    case IKeep{+d, +s}:
      Bool.pick(List<&2, IrOp>, U32.is_eq(um_get(al, s), pi1), opt_ww_emit_keeps(opt_ww_fields(d, ex, k1), opt_ww_fields(s, ex, k1), acc), Con{IKeep{d, s}, acc})
    case ICopy{+d, +s}:
      Bool.pick(List<&2, IrOp>, U32.is_eq(um_get(al, s), pi1), sroa_emit_copies(opt_ww_fields(d, ex, k1), opt_ww_fields(s, ex, k1), acc), Con{ICopy{d, s}, acc})
    case other: Con{other, acc}
type WwBlksRes is Data:
  WwBlksRes{blks: List<&2, IrBlock>, nr: U32}
type WwOpsRes is Data:
  WwOpsRes{orev: List<&2, IrOp>, nr: U32}
type WwFsRes is Data:
  WwFsRes{fs: List<&2, U32>, orev: List<&2, IrOp>, nr: U32}
def opt_ww_rw_ctor_cons(v: U32, r: WwFsRes) -> WwFsRes:
  match r:
    case WwFsRes{ft, orev, nr}: WwFsRes{Con{v, ft}, orev, nr}
def opt_ww_rw_ctor_fs(+pi1: U32, +k1: U32, +cid: U32, +al: U32Map, +ex: U32Map, fs: List<&2, U32>, +orev: List<&2, IrOp>, +nr: U32) -> WwFsRes:
  match fs:
    case Nil{}: WwFsRes{Nil{}, orev, nr}
    case Con{+v, t}:
      +hit = U32.is_eq(um_get(al, v), pi1)
      opt_ww_rw_ctor_cons(Bool.pick(U32, hit, nr, v), opt_ww_rw_ctor_fs(pi1, k1, cid, al, ex, t, Bool.pick(List<&2, IrOp>, hit, Con{ICtor{nr, cid, opt_ww_fields(v, ex, k1)}, orev}, orev), Bool.pick(U32, hit, U32.add(nr, 1), nr)))
def opt_ww_rw_ctor_fin(d: U32, c2: U32, r: WwFsRes) -> WwOpsRes:
  match r:
    case WwFsRes{fs2, orev2, nr2}: WwOpsRes{Con{ICtor{d, c2, fs2}, orev2}, nr2}
def opt_ww_rw_callee_ops(+ar: U32, +pi1: U32, +k1: U32, +cinfo: U32, +al: U32Map, +ex: U32Map, ops: List<&2, IrOp>, st: WwOpsRes) -> WwOpsRes:
  match ops st:
    case Nil{} _: st
    case Con{ICtor{d, c2, fs}, t} WwOpsRes{acc, nr}: opt_ww_rw_callee_ops(ar, pi1, k1, cinfo, al, ex, t, opt_ww_rw_ctor_fin(d, c2, opt_ww_rw_ctor_fs(pi1, k1, U32.sub(cinfo, 1), al, ex, fs, acc, nr)))
    case Con{op, t} WwOpsRes{acc, nr}: opt_ww_rw_callee_ops(ar, pi1, k1, cinfo, al, ex, t, WwOpsRes{opt_ww_rw_callee_op(ar, pi1, k1, cinfo, al, ex, op, acc), nr})
def opt_ww_rw_callee_tc(is_self: Bool, +ar: U32, +pi1: U32, +k1: U32, +cinfo: U32, +al: U32Map, +ex: U32Map, cfid: U32, +args: List<&2, U32>) -> IrTerm:
  match is_self:
    case False{}: TTailCall{cfid, args}
    case True{}:
      +pi = U32.sub(pi1, 1)
      +a1 = opt_u32_nth(args, pi)
      +a = U32.sub(a1, 1)
      +is_sp = Bool.and(U32.is_ne(a1, 0), U32.is_eq(um_get(al, a), pi1))
      +tail0 = opt_ww_seq(U32.to_nat(k1), U32.sub(um_get(ex, a), 1))
      tail = Bool.pick(List<&2, U32>, U32.is_eq(cinfo, 4294967294), b5k_list_app(U32, tail0, Con{U32.add(ar, k1), Nil{}}), tail0)
      args2 = Bool.pick(List<&2, U32>, is_sp, opt_u32_rep_app(args, pi, 0, a, tail), args)
      TTailCall{cfid, args2}
def opt_ww_rw_callee_blk(id: U32, +sfid: U32, +ar: U32, +pi1: U32, +k1: U32, +cinfo: U32, +al: U32Map, +ex: U32Map, +orev: List<&2, IrOp>, term: IrTerm, acc_b: List<&2, IrBlock>, +nr: U32) -> WwBlksRes:
  match term:
    case TTailCall{+cfid, args}:
      WwBlksRes{Con{IrBlock{id, b5k_list_rev(IrOp, orev), opt_ww_rw_callee_tc(U32.is_eq(cfid, sfid), ar, pi1, k1, cinfo, al, ex, cfid, args)}, acc_b}, nr}
    case TRet{+v}:
      +hit = U32.is_eq(um_get(al, v), pi1)
      orev2 = Bool.pick(List<&2, IrOp>, hit, Con{ICtor{nr, U32.sub(cinfo, 1), opt_ww_fields(v, ex, k1)}, orev}, orev)
      rv2 = Bool.pick(U32, hit, nr, v)
      nr2 = Bool.pick(U32, hit, U32.add(nr, 1), nr)
      WwBlksRes{Con{IrBlock{id, b5k_list_rev(IrOp, orev2), TRet{rv2}}, acc_b}, nr2}
    case other:
      WwBlksRes{Con{IrBlock{id, b5k_list_rev(IrOp, orev), other}, acc_b}, nr}
def opt_ww_rw_callee_blk_go(id: U32, sfid: U32, ar: U32, pi1: U32, k1: U32, cinfo: U32, al: U32Map, ex: U32Map, r: WwOpsRes, term: IrTerm, acc_b: List<&2, IrBlock>) -> WwBlksRes:
  match r:
    case WwOpsRes{orev, nr2}: opt_ww_rw_callee_blk(id, sfid, ar, pi1, k1, cinfo, al, ex, orev, term, acc_b, nr2)
def opt_ww_rw_callee_blks(+sfid: U32, +ar: U32, +pi1: U32, +k1: U32, +cinfo: U32, +al: U32Map, +ex: U32Map, blks: List<&2, IrBlock>, st: WwBlksRes) -> WwBlksRes:
  match blks st:
    case Nil{} WwBlksRes{acc_b, nr}: WwBlksRes{b5k_list_rev(IrBlock, acc_b), nr}
    case Con{IrBlock{id, ops, term}, t} WwBlksRes{acc_b, nr}:
      r = opt_ww_rw_callee_ops(ar, pi1, k1, cinfo, al, ex, ops, WwOpsRes{Nil{}, nr})
      opt_ww_rw_callee_blks(sfid, ar, pi1, k1, cinfo, al, ex, t, opt_ww_rw_callee_blk_go(id, sfid, ar, pi1, k1, cinfo, al, ex, r, term, acc_b))
def opt_ww_rw_callee_fin2(fid: U32, nm: String, ar2: U32, esc: Bool, eff: Bool, is_m: Bool, r: WwBlksRes) -> IrFn:
  match r:
    case WwBlksRes{blks2, nr2}: IrFn{fid, nm, ar2, nr2, esc, eff, is_m, blks2}
def opt_ww_rw_callee_fin(+fid: U32, nm: String, +ar: U32, +ex_cnt: U32, esc: Bool, eff: Bool, is_m: Bool, +pi1: U32, +k1: U32, +cinfo: U32, +al: U32Map, blks: List<&2, IrBlock>, st: WwExSt) -> IrFn:
  match st:
    case WwExSt{ex, nr2}:
      opt_ww_rw_callee_fin2(fid, nm, U32.add(ar, ex_cnt), esc, eff, is_m, opt_ww_rw_callee_blks(fid, ar, pi1, k1, cinfo, al, ex, blks, WwBlksRes{Nil{}, nr2}))
def opt_ww_rw_callee_one(hit: Bool, +pi1: U32, +k: U32, +cinfo: U32, f: IrFn) -> IrFn:
  match hit f:
    case False{} _: f
    case True{} IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, blks}:
      +k1 = U32.sub(k, 1)
      +ex_cnt = Bool.pick(U32, U32.is_eq(cinfo, 4294967294), k, k1)
      +b1 = opt_bump_blks(ar, ex_cnt, blks)
      +nr1 = U32.add(U32.max(nregs, ar), ex_cnt)
      defc = opt_blks_defs(b1, UM0{})
      +al = opt_ww_alias(defc, ar, b1)
      st = opt_ww_alloc_ex_blks(pi1, k1, al, b1, WwExSt{um_set(UM0{}, U32.sub(pi1, 1), U32.add(ar, 1)), nr1})
      opt_ww_rw_callee_fin(fid, nm, ar, ex_cnt, esc, eff, is_m, pi1, k1, cinfo, al, b1, st)
def opt_ww_rw_callees(+pidx: U32Map, +par: U32Map, +pcid: U32Map, fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{IrFn{+fid, nm, ar, nregs, esc, eff, is_m, blks}, t}:
      +pi1 = um_get(pidx, fid)
      f1 = opt_ww_rw_callee_one(U32.is_ne(pi1, 0), pi1, um_get(par, fid), um_get(pcid, fid), IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks})
      Con{f1, opt_ww_rw_callees(pidx, par, pcid, t)}
type WwCallRw is Data:
  WwCallRw{args: List<&2, U32>, acc: List<&2, IrOp>, drop: U32Map, nr: U32}
def opt_ww_rw_call_unpack(+a: U32, +pi: U32, +k: U32, +cinfo: U32, +args: List<&2, U32>, +acc: List<&2, IrOp>, +drop: U32Map, +nr: U32) -> WwCallRw:
  +need_tg = U32.is_eq(cinfo, 4294967294)
  +fs = opt_ww_seq(U32.to_nat(k), nr)
  +tg = U32.add(nr, k)
  acc1 = Bool.pick(List<&2, IrOp>, need_tg, Con{ITag{tg, a}, acc}, acc)
  acc2 : List<&2, IrOp> = Con{ITake{fs, a}, acc1}
  nr2 = Bool.pick(U32, need_tg, U32.add(tg, 1), tg)
  +tail0 = opt_ww_seq(U32.to_nat(U32.sub(k, 1)), U32.add(nr, 1))
  tail = Bool.pick(List<&2, U32>, need_tg, b5k_list_app(U32, tail0, Con{tg, Nil{}}), tail0)
  WwCallRw{opt_u32_rep_app(args, pi, 0, nr, tail), acc2, drop, nr2}
def opt_ww_rw_call_hit(ok: Bool, +v: U32, +cid: U32, f0: U32, +ft: List<&2, U32>, +a: U32, +pi: U32, +k: U32, +cinfo: U32, +args: List<&2, U32>, +acc: List<&2, IrOp>, +drop: U32Map, +nr: U32) -> WwCallRw:
  match ok:
    case False{}: opt_ww_rw_call_unpack(a, pi, k, cinfo, args, acc, drop, nr)
    case True{}:
      +need_tg = U32.is_eq(cinfo, 4294967294)
      tail = Bool.pick(List<&2, U32>, need_tg, b5k_list_app(U32, ft, Con{nr, Nil{}}), ft)
      acc1 = Bool.pick(List<&2, IrOp>, need_tg, Con{IConst{nr, cid}, acc}, acc)
      nr1 = Bool.pick(U32, need_tg, U32.add(nr, 1), nr)
      WwCallRw{opt_u32_rep_app(args, pi, 0, f0, tail), acc1, um_set(drop, v, 1), nr1}
def opt_ww_rw_call_ent(pe: WwCtorEnt, +a: U32, +pi: U32, +k: U32, +cinfo: U32, +args: List<&2, U32>, +acc: List<&2, IrOp>, +drop: U32Map, +nr: U32) -> WwCallRw:
  match pe:
    case WSome{+v, cid, ar, Con{f0, ft}}:
      opt_ww_rw_call_hit(Bool.and(U32.is_eq(v, a), U32.is_eq(ar, k)), v, cid, f0, ft, a, pi, k, cinfo, args, acc, drop, nr)
    case _: opt_ww_rw_call_unpack(a, pi, k, cinfo, args, acc, drop, nr)
def opt_ww_rw_call_has_arg(has: Bool, +a1: U32, +pi: U32, +cfid: U32, +par: U32Map, +pcid: U32Map, pc: RaVec<WwCtorEnt>, args: List<&2, U32>, acc: List<&2, IrOp>, drop: U32Map, nr: U32) -> WwCallRw:
  match has:
    case False{}: WwCallRw{args, acc, drop, nr}
    case True{}:
      +a = U32.sub(a1, 1)
      opt_ww_rw_call_ent(ra_vec_get(WwCtorEnt, 6n, WNone{}, a, pc), a, pi, um_get(par, cfid), um_get(pcid, cfid), args, acc, drop, nr)
def opt_ww_rw_call_has_pi(has: Bool, +pi1: U32, +cfid: U32, +par: U32Map, +pcid: U32Map, pc: RaVec<WwCtorEnt>, +args: List<&2, U32>, acc: List<&2, IrOp>, drop: U32Map, nr: U32) -> WwCallRw:
  match has:
    case False{}: WwCallRw{args, acc, drop, nr}
    case True{}:
      +pi = U32.sub(pi1, 1)
      +a1 = opt_u32_nth(args, pi)
      opt_ww_rw_call_has_arg(U32.is_ne(a1, 0), a1, pi, cfid, par, pcid, pc, args, acc, drop, nr)
def opt_ww_rw_call_args(+sfid: U32, +sf_ar: U32, +cfid: U32, +pidx: U32Map, +par: U32Map, +pcid: U32Map, pc: RaVec<WwCtorEnt>, +args: List<&2, U32>, acc: List<&2, IrOp>, drop: U32Map, nr: U32) -> WwCallRw:
  +skip_self = Bool.and(U32.is_eq(cfid, sfid), U32.is_ge(b5k_u32_list_len(args), sf_ar))
  +pi1 = Bool.pick(U32, skip_self, 0, um_get(pidx, cfid))
  opt_ww_rw_call_has_pi(U32.is_ne(pi1, 0), pi1, cfid, par, pcid, pc, args, acc, drop, nr)
type WwBlkRw is Data:
  WwBlkRw{pc: RaVec<WwCtorEnt>, acc: List<&2, IrOp>, drop: U32Map, nr: U32}
def opt_ww_rw_caller_step(dst: U32, cfid: U32, pc: RaVec<WwCtorEnt>, r: WwCallRw) -> WwBlkRw:
  match r:
    case WwCallRw{args2, acc2, drop2, nr2}: WwBlkRw{pc, Con{ICallDirect{dst, cfid, args2}, acc2}, drop2, nr2}
def opt_ww_rw_caller_ops(+sfid: U32, +defc: U32Map, +uses: U32Map, +ar: U32, +pidx: U32Map, +par: U32Map, +pcid: U32Map, ops: List<&2, IrOp>, st: WwBlkRw) -> WwBlkRw:
  match ops st:
    case Nil{} _: st
    case Con{ICtor{+d, +cid, +fs}, t} WwBlkRw{pc, acc, drop, nr}:
      +k = b5k_u32_list_len(fs)
      ok = Bool.and(U32.is_ge(k, 2), Bool.and(U32.is_le(k, 8), Bool.and(U32.is_lt(d, 4096), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(U32.is_eq(um_get(uses, d), 1), opt_all_can_prop(defc, ar, fs))))))
      opt_ww_rw_caller_ops(sfid, defc, uses, ar, pidx, par, pcid, t, WwBlkRw{opt_ww_put_pc(ok, pc, d, cid, k, fs), Con{ICtor{d, cid, fs}, acc}, drop, nr})
    case Con{ICallDirect{dst, +cfid, args}, t} WwBlkRw{+pc, acc, drop, nr}:
      st1 = opt_ww_rw_caller_step(dst, cfid, pc, opt_ww_rw_call_args(sfid, ar, cfid, pidx, par, pcid, pc, args, acc, drop, nr))
      opt_ww_rw_caller_ops(sfid, defc, uses, ar, pidx, par, pcid, t, st1)
    case Con{op, t} WwBlkRw{pc, acc, drop, nr}:
      opt_ww_rw_caller_ops(sfid, defc, uses, ar, pidx, par, pcid, t, WwBlkRw{pc, Con{op, acc}, drop, nr})
def opt_ww_rw_tail_fin(id: U32, cfid: U32, acc_b: List<&2, IrBlock>, r: WwCallRw) -> WwBlksRes:
  match r:
    case WwCallRw{args2, acc2, drop2, nr2}: WwBlksRes{Con{IrBlock{id, sroa_drop_fused(drop2, acc2, Nil{}), TTailCall{cfid, args2}}, acc_b}, nr2}
def opt_ww_rw_caller_fin(id: U32, +sfid: U32, +ar: U32, +pidx: U32Map, +par: U32Map, +pcid: U32Map, term: IrTerm, acc_b: List<&2, IrBlock>, st: WwBlkRw) -> WwBlksRes:
  match term st:
    case TTailCall{+cfid, args} WwBlkRw{pc, acc, drop, nr}:
      opt_ww_rw_tail_fin(id, cfid, acc_b, opt_ww_rw_call_args(sfid, ar, cfid, pidx, par, pcid, pc, args, acc, drop, nr))
    case other WwBlkRw{_, acc, drop, nr}: WwBlksRes{Con{IrBlock{id, sroa_drop_fused(drop, acc, Nil{}), other}, acc_b}, nr}
def opt_ww_rw_caller_blks(+sfid: U32, +defc: U32Map, +uses: U32Map, +ar: U32, +pidx: U32Map, +par: U32Map, +pcid: U32Map, blks: List<&2, IrBlock>, st: WwBlksRes) -> WwBlksRes:
  match blks st:
    case Nil{} WwBlksRes{acc_b, nr}: WwBlksRes{b5k_list_rev(IrBlock, acc_b), nr}
    case Con{IrBlock{id, ops, term}, t} WwBlksRes{acc_b, nr}:
      st1 = opt_ww_rw_caller_fin(id, sfid, ar, pidx, par, pcid, term, acc_b, opt_ww_rw_caller_ops(sfid, defc, uses, ar, pidx, par, pcid, ops, WwBlkRw{RVEmpty{}, Nil{}, UM0{}, nr}))
      opt_ww_rw_caller_blks(sfid, defc, uses, ar, pidx, par, pcid, t, st1)
def opt_ww_rw_caller_fn_fin(fid: U32, nm: String, ar: U32, esc: Bool, eff: Bool, is_m: Bool, r: WwBlksRes) -> IrFn:
  match r:
    case WwBlksRes{blks2, nr2}: IrFn{fid, nm, ar, nr2, esc, eff, is_m, blks2}
def opt_ww_rw_callers(+pidx: U32Map, +par: U32Map, +pcid: U32Map, fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, +blks}, t}:
      defc = opt_blks_defs(blks, UM0{})
      uses = opt_blks_uses(blks, UM0{})
      f1 = opt_ww_rw_caller_fn_fin(fid, nm, ar, esc, eff, is_m, opt_ww_rw_caller_blks(fid, defc, uses, ar, pidx, par, pcid, blks, WwBlksRes{Nil{}, nregs}))
      Con{f1, opt_ww_rw_callers(pidx, par, pcid, t)}
def opt_ww_apply(pl: WwPlan, fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match pl:
    case WwPlan{_, _, _, False{}}: fns
    case WwPlan{+pidx, +par, +pcid, True{}}: opt_ww_rw_callers(pidx, par, pcid, opt_ww_rw_callees(pidx, par, pcid, fns))
def opt_ww_pass(+fns: List<&2, IrFn>) -> List<&2, IrFn>:
  +bad_fn = opt_ip_bad_fns(fns, UM0{})
  +cand = opt_ww_cand_fns(bad_fn, fns, UM0{})
  obs = opt_ww_obs_fns(opt_fn_reach(fns), cand, fns, UM0{})
  opt_ww_apply(opt_ww_build_plan(bad_fn, cand, obs, fns, WwPlan{UM0{}, UM0{}, UM0{}, False{}}), fns)
# Pass F — Branchless sel(0/1,0,K) Fold, abs-sq Fold, b2u-is_zero Invert, Diamond Fusion & Pure-Op Sinking
def opt_b01_ops(+defc: U32Map, +ar: U32, ops: List<&2, IrOp>, +m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{ICmp{+d, +cop, _, _}, t}: opt_b01_ops(defc, ar, t, Bool.pick(U32Map, Bool.and(U32.is_lt(cop, 6), Bool.and(U32.is_ge(d, ar), U32.is_eq(um_get(defc, d), 1))), um_set(m, d, 1), m))
    case Con{_, t}: opt_b01_ops(defc, ar, t, m)
def opt_b01_blks(+defc: U32Map, +ar: U32, blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, _}, t}: opt_b01_blks(defc, ar, t, opt_b01_ops(defc, ar, ops, m))
type SelAux is Data:
  SelAux{zinv: U32Map, suba: U32Map, subb: U32Map, sq: U32Map}
def opt_sel_aux_ops(+defc: U32Map, +uses: U32Map, +ar: U32, +b01: U32Map, +gh: U32Map, +gv: U32Map, ops: List<&2, IrOp>, st: SelAux) -> SelAux:
  match ops st:
    case Nil{} _: st
    case Con{ICmp{+d, 0, +a, +b}, t} SelAux{+zi, sa, sb, sq}:
      +za = Bool.and(U32.is_ne(um_get(gh, b), 0), Bool.and(U32.is_zero(um_get(gv, b)), U32.is_ne(um_get(b01, a), 0)))
      +zb = Bool.and(U32.is_ne(um_get(gh, a), 0), Bool.and(U32.is_zero(um_get(gv, a)), U32.is_ne(um_get(b01, b), 0)))
      +nv = Bool.pick(U32, za, U32.add(a, 1), Bool.pick(U32, zb, U32.add(b, 1), 0))
      opt_sel_aux_ops(defc, uses, ar, b01, gh, gv, t, SelAux{Bool.pick(U32Map, U32.is_ne(nv, 0), um_set(zi, d, nv), zi), sa, sb, sq})
    case Con{IBin{+d, 1, +a, +b}, t} SelAux{zi, +sa, +sb, sq}:
      +ok = Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(opt_cp_can_prop(defc, ar, a), opt_cp_can_prop(defc, ar, b))))
      opt_sel_aux_ops(defc, uses, ar, b01, gh, gv, t, SelAux{zi, Bool.pick(U32Map, ok, um_set(sa, d, U32.add(a, 1)), sa), Bool.pick(U32Map, ok, um_set(sb, d, U32.add(b, 1)), sb), sq})
    case Con{IBin{_, 2, +a, +b}, t} SelAux{zi, sa, sb, +sq}:
      +ok = Bool.and(U32.is_eq(a, b), U32.is_eq(um_get(uses, a), 2))
      opt_sel_aux_ops(defc, uses, ar, b01, gh, gv, t, SelAux{zi, sa, sb, Bool.pick(U32Map, ok, um_set(sq, a, 1), sq)})
    case Con{_, t} _: opt_sel_aux_ops(defc, uses, ar, b01, gh, gv, t, st)
def opt_sel_aux_blks(+defc: U32Map, +uses: U32Map, +ar: U32, +b01: U32Map, +gh: U32Map, +gv: U32Map, blks: List<&2, IrBlock>, st: SelAux) -> SelAux:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, _}, t}: opt_sel_aux_blks(defc, uses, ar, b01, gh, gv, t, opt_sel_aux_ops(defc, uses, ar, b01, gh, gv, ops, st))
type SelArm is Data:
  SANone{}
  SASome{d: U32, v: U32, j: U32}
  SAVar{d: U32, s: U32, j: U32}
def opt_sel_arm(mb: Maybe<&2, IrBlock>, +gh: U32Map, +gv: U32Map) -> SelArm:
  match mb:
    case Some{IrBlock{_, Con{IConst{d, v}, Nil{}}, TJmp{j}}}: SASome{d, v, j}
    case Some{IrBlock{_, Con{ICopy{+d, +s}, Nil{}}, TJmp{+j}}}: Bool.pick(SelArm, U32.is_ne(um_get(gh, s), 0), SASome{d, um_get(gv, s), j}, SAVar{d, s, j})
    case _: SANone{}
def opt_is_sar_mask(+v: U32) -> Bool:
  +inv = U32.xor(v, 4294967295)
  Bool.and(U32.is_ge(v, 2147483648), Bool.and(U32.is_lt(v, 4294967295), U32.is_zero(U32.and(inv, U32.add(inv, 1)))))
def opt_sel_fold(at: SelArm, af: SelArm, +sa: U32Map, +sb: U32Map, +sq: U32Map, +id: U32, +ops: List<&2, IrOp>, +c: U32, tb: U32, fb: U32, +nr: U32, +acc: List<&2, IrBlock>) -> CfBlksRes:
  match at af:
    case SASome{+dt, +vt, +jt} SASome{df, +vf, jf}:
      +same = Bool.and(U32.is_eq(dt, df), U32.is_eq(jt, jf))
      Bool.pick(CfBlksRes, Bool.and(same, Bool.and(U32.is_zero(vt), Bool.and(U32.is_ne(vf, 0), Bool.not(opt_is_sar_mask(vf))))), CfBlksRes{Con{IrBlock{id, b5k_list_app(IrOp, ops, [IConst{nr, 1}, IBin{U32.add(nr, 1), 1, c, nr}, IConst{U32.add(nr, 2), vf}, IBin{dt, 5, U32.add(nr, 1), U32.add(nr, 2)}]), TJmp{jt}}, acc}, U32.add(nr, 3)}, Bool.pick(CfBlksRes, Bool.and(same, Bool.and(U32.is_zero(vf), U32.is_ne(vt, 0))), CfBlksRes{Con{IrBlock{id, b5k_list_app(IrOp, ops, Bool.pick(List<&2, IrOp>, U32.is_eq(vt, 1), [ICopy{dt, c}], [IUn{nr, 0, c}, IConst{U32.add(nr, 1), vt}, IBin{dt, 5, nr, U32.add(nr, 1)}])), TJmp{jt}}, acc}, Bool.pick(U32, U32.is_eq(vt, 1), nr, U32.add(nr, 2))}, CfBlksRes{Con{IrBlock{id, ops, TBr{c, tb, fb}}, acc}, nr}))
    case SAVar{+dt, +st, +jt} SAVar{df, +sf, jf}:
      +neg_sq = Bool.and(U32.is_eq(dt, df), Bool.and(U32.is_eq(jt, jf), Bool.and(U32.is_ne(um_get(sq, dt), 0), Bool.and(U32.is_ne(um_get(sa, st), 0), Bool.and(U32.is_eq(um_get(sa, st), um_get(sb, sf)), U32.is_eq(um_get(sb, st), um_get(sa, sf)))))))
      Bool.pick(CfBlksRes, neg_sq, CfBlksRes{Con{IrBlock{id, b5k_list_app(IrOp, ops, [ICopy{dt, st}]), TJmp{jt}}, acc}, nr}, CfBlksRes{Con{IrBlock{id, ops, TBr{c, tb, fb}}, acc}, nr})
    case _ _: CfBlksRes{Con{IrBlock{id, ops, TBr{c, tb, fb}}, acc}, nr}
def opt_sel_go(+b01: U32Map, +gh: U32Map, +gv: U32Map, +zi: U32Map, +sa: U32Map, +sb: U32Map, +sq: U32Map, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>, st: CfBlksRes) -> CfBlksRes:
  match blks st:
    case Nil{} CfBlksRes{acc, nr}: CfBlksRes{b5k_list_rev(IrBlock, acc), nr}
    case Con{IrBlock{+id, ops, TBr{+c0, +tb0, +fb0}}, t} CfBlksRes{acc, nr}:
      +inv = um_get(zi, c0)
      +c = Bool.pick(U32, U32.is_ne(inv, 0), U32.sub(inv, 1), c0)
      +tb = Bool.pick(U32, U32.is_ne(inv, 0), fb0, tb0)
      +fb = Bool.pick(U32, U32.is_ne(inv, 0), tb0, fb0)
      ok = Bool.and(U32.is_ne(um_get(b01, c), 0), Bool.and(U32.is_lt(tb, 1024), Bool.and(U32.is_lt(fb, 1024), Bool.and(U32.is_ne(tb, fb), Bool.and(U32.is_ne(tb, id), Bool.and(U32.is_ne(fb, id), Bool.and(U32.is_eq(um_get(preds, tb), 1), U32.is_eq(um_get(preds, fb), 1))))))))
      opt_sel_go(b01, gh, gv, zi, sa, sb, sq, preds, bmap, t, opt_sel_fold(Bool.pick(SelArm, ok, opt_sel_arm(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bmap), gh, gv), SANone{}), opt_sel_arm(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap), gh, gv), sa, sb, sq, id, ops, c, tb, fb, nr, acc))
    case Con{b, t} CfBlksRes{acc, nr}: opt_sel_go(b01, gh, gv, zi, sa, sb, sq, preds, bmap, t, CfBlksRes{Con{b, acc}, nr})
def opt_sel_fn_aux(fid: U32, nm: String, ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, +b01: U32Map, +gh: U32Map, +gv: U32Map, aux: SelAux) -> IrFn:
  match aux:
    case SelAux{zi, sa, sb, sq}: cf_fn_fin(fid, nm, ar, esc, eff, is_m, opt_sel_go(b01, gh, gv, zi, sa, sb, sq, opt_count_preds(blks, um_set(UM0{}, 0, 2)), opt_index_blks(blks, RVEmpty{}), blks, CfBlksRes{Nil{}, nregs}))
def opt_sel_fn_gc(fid: U32, nm: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, +defc: U32Map, gc: CfGConsts) -> IrFn:
  match gc:
    case CfGConsts{+gh, +gv}:
      +b01 = opt_b01_blks(defc, ar, blks, UM0{})
      opt_sel_fn_aux(fid, nm, ar, nregs, esc, eff, is_m, blks, b01, gh, gv, opt_sel_aux_blks(defc, opt_blks_uses(blks, UM0{}), ar, b01, gh, gv, blks, SelAux{UM0{}, UM0{}, UM0{}, UM0{}}))
def opt_fns_sel_mask(fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{IrFn{fid, nm, +ar, nregs, esc, eff, is_m, +blks}, t}:
      +defc = opt_blks_defs(blks, UM0{})
      Con{opt_sel_fn_gc(fid, nm, ar, nregs, esc, eff, is_m, blks, defc, cf_gc_blks(defc, ar, blks, CfGConsts{UM0{}, UM0{}})), opt_fns_sel_mask(t)}
def opt_fuse_set(mt2: Maybe<&2, IrBlock>, mf2: Maybe<&2, IrBlock>, +tb1: U32, opsT1: List<&2, IrOp>, +fb1: U32, opsF1: List<&2, IrOp>, rep: RaVec<Maybe<&2, IrBlock>>) -> RaVec<Maybe<&2, IrBlock>>:
  match mt2 mf2:
    case Some{IrBlock{_, opsT2, termT2}} Some{IrBlock{_, opsF2, termF2}}: ra_vec_set(Maybe<&2, IrBlock>, 5n, fb1, Some{IrBlock{fb1, b5k_list_app(IrOp, opsF1, opsF2), termF2}}, ra_vec_set(Maybe<&2, IrBlock>, 5n, tb1, Some{IrBlock{tb1, b5k_list_app(IrOp, opsT1, opsT2), termT2}}, rep))
    case _ _: rep
def opt_fuse_j1(mj: Maybe<&2, IrBlock>, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, +c: U32, +tb1: U32, opsT1: List<&2, IrOp>, +fb1: U32, opsF1: List<&2, IrOp>, +j1: U32, rep: RaVec<Maybe<&2, IrBlock>>) -> RaVec<Maybe<&2, IrBlock>>:
  match mj:
    case Some{IrBlock{_, Nil{}, TBr{c2, +tb2, +fb2}}}: opt_fuse_set(Bool.pick(Maybe<&2, IrBlock>, Bool.and(U32.is_eq(c2, c), Bool.and(U32.is_lt(tb2, 1024), Bool.and(U32.is_lt(fb2, 1024), Bool.and(U32.is_ne(tb2, fb2), Bool.and(U32.is_ne(tb2, j1), Bool.and(U32.is_ne(fb2, j1), Bool.and(U32.is_eq(um_get(preds, tb2), 1), U32.is_eq(um_get(preds, fb2), 1)))))))), ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb2, bmap), None{}), ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb2, bmap), tb1, opsT1, fb1, opsF1, rep)
    case _: rep
def opt_fuse_arms(mt1: Maybe<&2, IrBlock>, mf1: Maybe<&2, IrBlock>, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, +id: U32, +c: U32, +tb1: U32, +fb1: U32, rep: RaVec<Maybe<&2, IrBlock>>) -> RaVec<Maybe<&2, IrBlock>>:
  match mt1 mf1:
    case Some{IrBlock{_, opsT1, TJmp{+jt}}} Some{IrBlock{_, opsF1, TJmp{jf}}}: opt_fuse_j1(Bool.pick(Maybe<&2, IrBlock>, Bool.and(U32.is_eq(jt, jf), Bool.and(U32.is_lt(jt, 1024), Bool.and(U32.is_ne(jt, id), U32.is_eq(um_get(preds, jt), 2)))), ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, jt, bmap), None{}), preds, bmap, c, tb1, opsT1, fb1, opsF1, jt, rep)
    case _ _: rep
def opt_fuse_scan(+defc: U32Map, +ar: U32, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>, rep: RaVec<Maybe<&2, IrBlock>>) -> RaVec<Maybe<&2, IrBlock>>:
  match blks:
    case Nil{}: rep
    case Con{IrBlock{+id, _, TBr{+c, +tb1, +fb1}}, t}:
      ok = Bool.and(opt_cp_can_prop(defc, ar, c), Bool.and(U32.is_lt(tb1, 1024), Bool.and(U32.is_lt(fb1, 1024), Bool.and(U32.is_ne(tb1, fb1), Bool.and(U32.is_ne(tb1, id), Bool.and(U32.is_ne(fb1, id), Bool.and(U32.is_eq(um_get(preds, tb1), 1), U32.is_eq(um_get(preds, fb1), 1))))))))
      opt_fuse_scan(defc, ar, preds, bmap, t, opt_fuse_arms(Bool.pick(Maybe<&2, IrBlock>, ok, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb1, bmap), None{}), ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb1, bmap), preds, bmap, id, c, tb1, fb1, rep))
    case Con{_, t}: opt_fuse_scan(defc, ar, preds, bmap, t, rep)
def opt_fuse_rep(mb: Maybe<&2, IrBlock>, orig: IrBlock) -> IrBlock:
  match mb:
    case Some{nb}: nb
    case None{}: orig
def opt_fuse_apply(+rep: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, ops, term}, t}: Con{opt_fuse_rep(Bool.pick(Maybe<&2, IrBlock>, U32.is_lt(id, 1024), ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, id, rep), None{}), IrBlock{id, ops, term}), opt_fuse_apply(rep, t)}
def opt_sink_info(+defc: U32Map, +ar: U32, op: IrOp) -> U32:
  match op:
    case IBin{+d, +bop, a, b}: Bool.pick(U32, Bool.and(U32.is_ne(bop, 3), Bool.and(U32.is_ne(bop, 4), Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(opt_cp_can_prop(defc, ar, a), opt_cp_can_prop(defc, ar, b)))))), U32.or(U32.shln(U32.add(d, 1), 3n), Bool.pick(U32, U32.is_eq(bop, 2), 4, 1)), 0)
    case IUn{+d, _, s}: Bool.pick(U32, Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_eq(um_get(defc, d), 1), opt_cp_can_prop(defc, ar, s))), U32.or(U32.shln(U32.add(d, 1), 3n), 1), 0)
    case ICmp{+d, _, a, b}: Bool.pick(U32, Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(opt_cp_can_prop(defc, ar, a), opt_cp_can_prop(defc, ar, b)))), U32.or(U32.shln(U32.add(d, 1), 3n), 1), 0)
    case IConst{+d, _}: Bool.pick(U32, Bool.and(U32.is_ge(d, ar), U32.is_eq(um_get(defc, d), 1)), U32.or(U32.shln(U32.add(d, 1), 3n), 1), 0)
    case _: 0
def opt_blk_uses_mb(mb: Maybe<&2, IrBlock>) -> U32Map:
  match mb:
    case Some{IrBlock{_, ops, term}}: opt_term_uses(term, opt_ops_uses(ops, UM0{}))
    case None{}: UM0{}
type SinkSt is Data:
  SinkSt{ut: U32Map, uf: U32Map, keep: List<&2, IrOp>, st: List<&2, IrOp>, sf: List<&2, IrOp>, ct: U32, cf: U32}
def opt_sink_step(go_t: Bool, go_f: Bool, +op: IrOp, cost: U32, ut: U32Map, uf: U32Map, keep: List<&2, IrOp>, st: List<&2, IrOp>, sf: List<&2, IrOp>, ct: U32, cf: U32) -> SinkSt:
  match go_t go_f:
    case True{} _: SinkSt{opt_op_uses(op, ut), uf, keep, Con{op, st}, sf, U32.add(ct, cost), cf}
    case False{} True{}: SinkSt{ut, opt_op_uses(op, uf), keep, st, Con{op, sf}, ct, U32.add(cf, cost)}
    case _ _: SinkSt{ut, uf, Con{op, keep}, st, sf, ct, cf}
def opt_sink_walk(+defc: U32Map, +uses: U32Map, +ar: U32, +okt: Bool, +okf: Bool, ops_rev: List<&2, IrOp>, s: SinkSt) -> SinkSt:
  match ops_rev s:
    case Nil{} _: s
    case Con{+op, t} SinkSt{+ut, +uf, keep, st, sf, ct, cf}:
      +inf = opt_sink_info(defc, ar, op)
      +d = U32.sub(U32.shrn(inf, 3n), 1)
      +tu = Bool.pick(U32, U32.is_ne(inf, 0), um_get(uses, d), 0)
      +go_t = Bool.and(okt, Bool.and(U32.is_ne(tu, 0), U32.is_eq(um_get(ut, d), tu)))
      opt_sink_walk(defc, uses, ar, okt, okf, t, opt_sink_step(go_t, Bool.and(Bool.not(go_t), Bool.and(okf, Bool.and(U32.is_ne(tu, 0), U32.is_eq(um_get(uf, d), tu)))), op, U32.and(inf, 7), ut, uf, keep, st, sf, ct, cf))
type SinkBlksRes is Data:
  SinkBlksRes{blks_rev: List<&2, IrBlock>, prep: RaVec<List<&2, IrOp>>}
def opt_sink_side(is_t: Bool, id: U32, c: U32, +tb: U32, +fb: U32, s: SinkSt, acc: List<&2, IrBlock>, prep: RaVec<List<&2, IrOp>>) -> SinkBlksRes:
  match is_t s:
    case True{} SinkSt{_, _, k2, st2, _, _, _}: SinkBlksRes{Con{IrBlock{id, k2, TBr{c, tb, fb}}, acc}, ra_vec_set(List<&2, IrOp>, 5n, tb, st2, prep)}
    case False{} SinkSt{_, _, k2, _, sf2, _, _}: SinkBlksRes{Con{IrBlock{id, k2, TBr{c, tb, fb}}, acc}, ra_vec_set(List<&2, IrOp>, 5n, fb, sf2, prep)}
def opt_sink_commit(wt: Bool, wf: Bool, id: U32, orig: List<&2, IrOp>, c: U32, +tb: U32, +fb: U32, defc: U32Map, uses: U32Map, ar: U32, ut0: U32Map, uf0: U32Map, keep: List<&2, IrOp>, st: List<&2, IrOp>, sf: List<&2, IrOp>, acc: List<&2, IrBlock>, prep: RaVec<List<&2, IrOp>>) -> SinkBlksRes:
  match wt wf:
    case False{} False{}: SinkBlksRes{Con{IrBlock{id, orig, TBr{c, tb, fb}}, acc}, prep}
    case True{} True{}: SinkBlksRes{Con{IrBlock{id, keep, TBr{c, tb, fb}}, acc}, ra_vec_set(List<&2, IrOp>, 5n, fb, sf, ra_vec_set(List<&2, IrOp>, 5n, tb, st, prep))}
    case True{} False{}: opt_sink_side(True{}, id, c, tb, fb, opt_sink_walk(defc, uses, ar, True{}, False{}, b5k_list_rev(IrOp, orig), SinkSt{ut0, UM0{}, Nil{}, Nil{}, Nil{}, 0, 0}), acc, prep)
    case False{} True{}: opt_sink_side(False{}, id, c, tb, fb, opt_sink_walk(defc, uses, ar, False{}, True{}, b5k_list_rev(IrOp, orig), SinkSt{UM0{}, uf0, Nil{}, Nil{}, Nil{}, 0, 0}), acc, prep)
def opt_sink_blk_go(id: U32, orig: List<&2, IrOp>, c: U32, tb: U32, fb: U32, defc: U32Map, uses: U32Map, ar: U32, ut0: U32Map, uf0: U32Map, s: SinkSt, acc: List<&2, IrBlock>, prep: RaVec<List<&2, IrOp>>) -> SinkBlksRes:
  match s:
    case SinkSt{_, _, keep, st, sf, ct, cf}: opt_sink_commit(U32.is_ge(ct, 4), U32.is_ge(cf, 4), id, orig, c, tb, fb, defc, uses, ar, ut0, uf0, keep, st, sf, acc, prep)
def opt_sink_blk(any: Bool, id: U32, +ops: List<&2, IrOp>, c: U32, +tb: U32, +fb: U32, +okt: Bool, +okf: Bool, +defc: U32Map, +uses: U32Map, +ar: U32, +bmap: RaVec<Maybe<&2, IrBlock>>, acc: List<&2, IrBlock>, prep: RaVec<List<&2, IrOp>>) -> SinkBlksRes:
  match any:
    case False{}: SinkBlksRes{Con{IrBlock{id, ops, TBr{c, tb, fb}}, acc}, prep}
    case True{}:
      +ut0 = Bool.pick(U32Map, okt, opt_blk_uses_mb(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bmap)), UM0{})
      +uf0 = Bool.pick(U32Map, okf, opt_blk_uses_mb(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap)), UM0{})
      opt_sink_blk_go(id, ops, c, tb, fb, defc, uses, ar, ut0, uf0, opt_sink_walk(defc, uses, ar, okt, okf, b5k_list_rev(IrOp, ops), SinkSt{ut0, uf0, Nil{}, Nil{}, Nil{}, 0, 0}), acc, prep)
def opt_sink_scan(+defc: U32Map, +uses: U32Map, +ar: U32, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>, r: SinkBlksRes) -> SinkBlksRes:
  match blks r:
    case Nil{} _: r
    case Con{IrBlock{+id, ops, TBr{c, +tb, +fb}}, t} SinkBlksRes{acc, prep}:
      +okt = Bool.and(U32.is_ne(tb, fb), Bool.and(U32.is_lt(tb, 1024), Bool.and(U32.is_ne(tb, id), U32.is_eq(um_get(preds, tb), 1))))
      +okf = Bool.and(U32.is_ne(tb, fb), Bool.and(U32.is_lt(fb, 1024), Bool.and(U32.is_ne(fb, id), U32.is_eq(um_get(preds, fb), 1))))
      opt_sink_scan(defc, uses, ar, preds, bmap, t, opt_sink_blk(Bool.or(okt, okf), id, ops, c, tb, fb, okt, okf, defc, uses, ar, bmap, acc, prep))
    case Con{b, t} SinkBlksRes{acc, prep}: opt_sink_scan(defc, uses, ar, preds, bmap, t, SinkBlksRes{Con{b, acc}, prep})
def opt_sink_prepend(+prep: RaVec<List<&2, IrOp>>, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, ops, term}, t}: Con{IrBlock{id, b5k_list_app(IrOp, Bool.pick(List<&2, IrOp>, U32.is_lt(id, 1024), ra_vec_get(List<&2, IrOp>, 5n, Nil{}, id, prep), Nil{}), ops), term}, opt_sink_prepend(prep, t)}
def opt_sink_fin(r: SinkBlksRes) -> List<&2, IrBlock>:
  match r:
    case SinkBlksRes{rev, prep}: opt_sink_prepend(prep, b5k_list_rev(IrBlock, rev))
def opt_fn_fuse_sink(f: IrFn) -> IrFn:
  match f:
    case IrFn{fid, nm, +ar, nregs, esc, eff, is_m, +blks}:
      +b1 = opt_elim_unreach(opt_fuse_apply(opt_fuse_scan(opt_blks_defs(blks, UM0{}), ar, opt_count_preds(blks, um_set(UM0{}, 0, 2)), opt_index_blks(blks, RVEmpty{}), blks, RVEmpty{}), blks))
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_sink_fin(opt_sink_scan(opt_blks_defs(b1, UM0{}), opt_blks_uses(b1, UM0{}), ar, opt_count_preds(b1, um_set(UM0{}, 0, 2)), opt_index_blks(b1, RVEmpty{}), b1, SinkBlksRes{Nil{}, RVEmpty{}}))}
def opt_fns_fuse_sink(fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_fn_fuse_sink(f), opt_fns_fuse_sink(t)}
# Pass G — Identity Match-Arm Elision (ITake{ds, s} ... ICtor{d, cid, ds} -> ICopy{d, s})
type TagFact is Data:
  TFNone{}
  TFSome{src: U32, cid: U32}
def opt_u32_list_eq(xs: List<&2, U32>, ys: List<&2, U32>) -> Bool:
  match xs ys:
    case Nil{} Nil{}: True{}
    case Con{x, xt} Con{y, yt}: Bool.and(U32.is_eq(x, y), opt_u32_list_eq(xt, yt))
    case _ _: False{}
def opt_id_ds_ok(+defc: U32Map, +uses: U32Map, +ar: U32, ds: List<&2, U32>) -> Bool:
  match ds:
    case Nil{}: True{}
    case Con{+v, t}: Bool.and(Bool.and(U32.is_ge(v, ar), Bool.and(U32.is_eq(um_get(defc, v), 1), U32.is_eq(um_get(uses, v), 1))), opt_id_ds_ok(defc, uses, ar, t))
def opt_id_tag_ops(+defc: U32Map, +ar: U32, ops: List<&2, IrOp>, +tm: U32Map) -> U32Map:
  match ops:
    case Nil{}: tm
    case Con{ITag{+d, +s}, t}: opt_id_tag_ops(defc, ar, t, Bool.pick(U32Map, Bool.and(opt_cp_can_prop(defc, ar, d), opt_cp_can_prop(defc, ar, s)), um_set(tm, d, U32.add(s, 1)), tm))
    case Con{_, t}: opt_id_tag_ops(defc, ar, t, tm)
def opt_id_tag_blks(+defc: U32Map, +ar: U32, blks: List<&2, IrBlock>, tm: U32Map) -> U32Map:
  match blks:
    case Nil{}: tm
    case Con{IrBlock{_, ops, _}, t}: opt_id_tag_blks(defc, ar, t, opt_id_tag_ops(defc, ar, ops, tm))
def opt_id_tf_put(+preds: U32Map, +bid: U32, +tgt: U32, tf: TagFact, +fm: RaVec<TagFact>) -> RaVec<TagFact>:
  Bool.pick(RaVec<TagFact>, Bool.and(U32.is_ne(tgt, bid), Bool.and(U32.is_ne(tgt, 0), Bool.and(U32.is_lt(tgt, 1024), U32.is_eq(um_get(preds, tgt), 1)))), ra_vec_set(TagFact, 5n, tgt, tf, fm), fm)
def opt_id_tf_arms(+preds: U32Map, +bid: U32, +src: U32, arms: List<&2, IrSwitchArm>, fm: RaVec<TagFact>) -> RaVec<TagFact>:
  match arms:
    case Nil{}: fm
    case Con{IrArm{k, tgt}, t}: opt_id_tf_arms(preds, bid, src, t, opt_id_tf_put(preds, bid, tgt, TFSome{src, k}, fm))
def opt_id_tf_br(+tm: U32Map, +preds: U32Map, +bid: U32, +tb: U32, +fb: U32, sc: BrScan, +fm: RaVec<TagFact>) -> RaVec<TagFact>:
  match sc:
    case BrScan{+has, +val, True{}, +cop, +a, +b}:
      +eq_t = Bool.pick(U32, U32.is_zero(cop), tb, fb)
      +ta = um_get(tm, a)
      +tb2 = um_get(tm, b)
      +fm1 = Bool.pick(RaVec<TagFact>, Bool.and(U32.is_ne(ta, 0), U32.is_ne(um_get(has, b), 0)), opt_id_tf_put(preds, bid, eq_t, TFSome{U32.sub(ta, 1), um_get(val, b)}, fm), fm)
      Bool.pick(RaVec<TagFact>, Bool.and(U32.is_ne(tb2, 0), U32.is_ne(um_get(has, a), 0)), opt_id_tf_put(preds, bid, eq_t, TFSome{U32.sub(tb2, 1), um_get(val, a)}, fm1), fm1)
    case _: fm
def opt_id_collect_tf(+tm: U32Map, +gh: U32Map, +gv: U32Map, +preds: U32Map, blks: List<&2, IrBlock>, +fm: RaVec<TagFact>) -> RaVec<TagFact>:
  match blks:
    case Nil{}: fm
    case Con{IrBlock{+id, ops, TBr{c, tb, fb}}, t}: opt_id_collect_tf(tm, gh, gv, preds, t, opt_id_tf_br(tm, preds, id, tb, fb, cf_br_scan_ops(c, ops, BrScan{gh, gv, False{}, 0, 0, 0}), fm))
    case Con{IrBlock{+id, _, TSwitch{s, arms, _}}, t}:
      +ts = um_get(tm, s)
      opt_id_collect_tf(tm, gh, gv, preds, t, Bool.pick(RaVec<TagFact>, U32.is_ne(ts, 0), opt_id_tf_arms(preds, id, U32.sub(ts, 1), arms, fm), fm))
    case Con{_, t}: opt_id_collect_tf(tm, gh, gv, preds, t, fm)
type IdRw is Data:
  IdRw{ops_rev: List<&2, IrOp>, has_tk: Bool, tk_ds: List<&2, U32>, hit: Bool}
def opt_id_rw_ops(+defc: U32Map, +uses: U32Map, +ar: U32, +src: U32, +cid: U32, ops: List<&2, IrOp>, st: IdRw) -> IdRw:
  match ops st:
    case Nil{} _: st
    case Con{ITake{+ds, +s}, t} IdRw{+rev, +htk, +tds, +hit}:
      +ok = Bool.and(Bool.not(htk), Bool.and(Bool.not(hit), Bool.and(U32.is_eq(s, src), Bool.and(U32.is_ne(b5k_u32_list_len(ds), 0), opt_id_ds_ok(defc, uses, ar, ds)))))
      opt_id_rw_ops(defc, uses, ar, src, cid, t, Bool.pick(IdRw, ok, IdRw{Con{ITake{ds, s}, rev}, True{}, ds, False{}}, IdRw{Con{ITake{ds, s}, rev}, htk, tds, hit}))
    case Con{ICtor{+d, +c2, +fs}, t} IdRw{+rev, +htk, +tds, +hit}:
      +ok = Bool.and(htk, Bool.and(U32.is_eq(c2, cid), opt_u32_list_eq(tds, fs)))
      opt_id_rw_ops(defc, uses, ar, src, cid, t, Bool.pick(IdRw, ok, IdRw{Con{ICopy{d, src}, rev}, False{}, tds, True{}}, IdRw{Con{ICtor{d, c2, fs}, rev}, htk, tds, hit}))
    case Con{op, t} IdRw{rev, htk, tds, hit}: opt_id_rw_ops(defc, uses, ar, src, cid, t, IdRw{Con{op, rev}, htk, tds, hit})
def opt_id_drop_take(+src: U32, +tds: List<&2, U32>, ops_rev: List<&2, IrOp>, +dropped: Bool, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops_rev:
    case Nil{}: acc
    case Con{ITake{+ds, +s}, t}:
      +dn = Bool.and(Bool.not(dropped), Bool.and(U32.is_eq(s, src), opt_u32_list_eq(ds, tds)))
      opt_id_drop_take(src, tds, t, Bool.or(dropped, dn), Bool.pick(List<&2, IrOp>, dn, acc, Con{ITake{ds, s}, acc}))
    case Con{op, t}: opt_id_drop_take(src, tds, t, dropped, Con{op, acc})
def opt_id_fin_blk(+src: U32, orig: List<&2, IrOp>, r: IdRw) -> List<&2, IrOp>:
  match r:
    case IdRw{rev, _, tds, True{}}: opt_id_drop_take(src, tds, rev, False{}, Nil{})
    case IdRw{_, _, _, False{}}: orig
def opt_id_rw_one(tf: TagFact, defc: U32Map, uses: U32Map, ar: U32, +ops: List<&2, IrOp>) -> List<&2, IrOp>:
  match tf:
    case TFNone{}: ops
    case TFSome{+src, cid}: opt_id_fin_blk(src, ops, opt_id_rw_ops(defc, uses, ar, src, cid, ops, IdRw{Nil{}, False{}, Nil{}, False{}}))
def opt_id_rw_blks(+defc: U32Map, +uses: U32Map, +ar: U32, +fm: RaVec<TagFact>, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, ops, term}, t}: Con{IrBlock{id, opt_id_rw_one(Bool.pick(TagFact, U32.is_lt(id, 1024), ra_vec_get(TagFact, 5n, TFNone{}, id, fm), TFNone{}), defc, uses, ar, ops), term}, opt_id_rw_blks(defc, uses, ar, fm, t)}
def opt_id_fn_gc(fid: U32, nm: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, +defc: U32Map, gc: CfGConsts) -> IrFn:
  match gc:
    case CfGConsts{gh, gv}: IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_id_rw_blks(defc, opt_blks_uses(blks, UM0{}), ar, opt_id_collect_tf(opt_id_tag_blks(defc, ar, blks, UM0{}), gh, gv, opt_count_preds(blks, um_set(UM0{}, 0, 2)), blks, RVEmpty{}), blks)}
def opt_fns_id_arm(fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{IrFn{fid, nm, +ar, nregs, esc, eff, is_m, +blks}, t}:
      +defc = opt_blks_defs(blks, UM0{})
      Con{opt_id_fn_gc(fid, nm, ar, nregs, esc, eff, is_m, blks, defc, cf_gc_blks(defc, ar, blks, CfGConsts{UM0{}, UM0{}})), opt_fns_id_arm(t)}
# Pass H — Large-Arity Self-TCO Lowering (arity > 32 -> in-place IBin fusion + parallel ICopy + TJmp hdr)
type TcoSt is Data:
  TcoSt{p1_rev: List<&2, IrOp>, p2_rev: List<&2, IrOp>, nr: U32}
def opt_tco_fuse_map(+ar: U32, +fu: U32Map, +bu: U32Map, +au: U32Map, args: List<&2, U32>, +idx: U32, +fm: U32Map) -> U32Map:
  match args:
    case Nil{}: fm
    case Con{+a, t}:
      ok = Bool.and(U32.is_ge(a, ar), Bool.and(U32.is_eq(um_get(fu, a), 1), Bool.and(U32.is_zero(um_get(bu, a)), Bool.and(U32.is_eq(um_get(au, a), 1), Bool.and(U32.is_zero(um_get(au, idx)), U32.is_eq(um_get(bu, idx), 1))))))
      opt_tco_fuse_map(ar, fu, bu, au, t, U32.add(idx, 1), Bool.pick(U32Map, ok, um_set(fm, a, U32.add(idx, 1)), fm))
type TcoFRes is Data:
  TcoFRes{ops: List<&2, IrOp>, done: U32Map}
def opt_tco_fuse_ops(+fm: U32Map, ops: List<&2, IrOp>, +done: U32Map, +acc: List<&2, IrOp>) -> TcoFRes:
  match ops:
    case Nil{}: TcoFRes{b5k_list_rev(IrOp, acc), done}
    case Con{IBin{+d, bop, +x, +y}, t}:
      +f = um_get(fm, d)
      +pi = U32.sub(f, 1)
      +hit = Bool.and(U32.is_ne(f, 0), Bool.or(U32.is_eq(x, pi), U32.is_eq(y, pi)))
      opt_tco_fuse_ops(fm, t, Bool.pick(U32Map, hit, um_set(done, pi, 1), done), Con{IBin{Bool.pick(U32, hit, pi, d), bop, x, y}, acc})
    case Con{op, t}: opt_tco_fuse_ops(fm, t, done, Con{op, acc})
def opt_tco_args(+ar: U32, +done: U32Map, args: List<&2, U32>, +idx: U32, st: TcoSt) -> TcoSt:
  match args st:
    case Nil{} _: st
    case Con{+a, t} TcoSt{+p1, +p2, +nr}:
      +skip = Bool.or(U32.is_eq(a, idx), U32.is_ne(um_get(done, idx), 0))
      +nt = Bool.and(Bool.not(skip), U32.is_lt(a, ar))
      p1b = Bool.pick(List<&2, IrOp>, nt, Con{ICopy{nr, a}, p1}, p1)
      p2b = Bool.pick(List<&2, IrOp>, skip, p2, Con{ICopy{idx, Bool.pick(U32, nt, nr, a)}, p2})
      opt_tco_args(ar, done, t, U32.add(idx, 1), TcoSt{p1b, p2b, Bool.pick(U32, nt, U32.add(nr, 1), nr)})
def opt_tco_emit(id: U32, hdr: U32, ops: List<&2, IrOp>, acc: List<&2, IrBlock>, st: TcoSt) -> CfBlksRes:
  match st:
    case TcoSt{p1r, p2r, nr2}: CfBlksRes{Con{IrBlock{id, b5k_list_app(IrOp, ops, b5k_list_app(IrOp, b5k_list_rev(IrOp, p1r), b5k_list_rev(IrOp, p2r))), TJmp{hdr}}, acc}, nr2}
def opt_tco_emit_f(id: U32, hdr: U32, ar: U32, args: List<&2, U32>, acc: List<&2, IrBlock>, nr: U32, fr: TcoFRes) -> CfBlksRes:
  match fr:
    case TcoFRes{ops2, done}: opt_tco_emit(id, hdr, ops2, acc, opt_tco_args(ar, done, args, 0, TcoSt{Nil{}, Nil{}, nr}))
def opt_tco_blk_tc(ok: Bool, id: U32, hdr: U32, +ar: U32, fu: U32Map, +ops: List<&2, IrOp>, cfid: U32, +args: List<&2, U32>, acc: List<&2, IrBlock>, nr: U32) -> CfBlksRes:
  match ok:
    case False{}: CfBlksRes{Con{IrBlock{id, ops, TTailCall{cfid, args}}, acc}, nr}
    case True{}: opt_tco_emit_f(id, hdr, ar, args, acc, nr, opt_tco_fuse_ops(opt_tco_fuse_map(ar, fu, opt_ops_uses(ops, UM0{}), opt_um_inc_list(args, UM0{}), args, 0, UM0{}), ops, UM0{}, Nil{}))
def opt_tco_blks(+fid: U32, +ar: U32, +hdr: U32, +fu: U32Map, blks: List<&2, IrBlock>, st: CfBlksRes) -> CfBlksRes:
  match blks st:
    case Nil{} CfBlksRes{acc, nr}: CfBlksRes{b5k_list_rev(IrBlock, acc), nr}
    case Con{IrBlock{id, ops, TTailCall{+cfid, +args}}, t} CfBlksRes{acc, nr}:
      opt_tco_blks(fid, ar, hdr, fu, t, opt_tco_blk_tc(Bool.and(U32.is_eq(cfid, fid), U32.is_eq(b5k_u32_list_len(args), ar)), id, hdr, ar, fu, ops, cfid, args, acc, nr))
    case Con{b, t} CfBlksRes{acc, nr}: opt_tco_blks(fid, ar, hdr, fu, t, CfBlksRes{Con{b, acc}, nr})
def opt_tco_fn_go(big: Bool, +fid: U32, nm: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, hdr: U32, +blks: List<&2, IrBlock>) -> IrFn:
  match big:
    case False{}: IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}
    case True{}: cf_fn_fin(fid, nm, ar, esc, eff, is_m, opt_tco_blks(fid, ar, hdr, opt_blks_uses(blks, UM0{}), blks, CfBlksRes{Nil{}, U32.max(nregs, ar)}))
def opt_tco_fn(f: IrFn) -> IrFn:
  match f:
    case IrFn{fid, nm, +ar, nregs, esc, eff, is_m, Con{IrBlock{+hdr, ops0, t0}, rest}}:
      opt_tco_fn_go(U32.is_gt(ar, 32), fid, nm, ar, nregs, esc, eff, is_m, hdr, Con{IrBlock{hdr, ops0, t0}, rest})
    case other: other
def opt_fns_tco_large(fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_tco_fn(f), opt_fns_tco_large(t)}
# Pass I — Perceus In-Place IReuse Token Pairing (same-block & post-dom diamond)
type ReuseTok is Data:
  RTok{slot: U32, ar: U32}
type RuPick is Data:
  RuNo{}
  RuYes{slot: U32, rest: List<&2, ReuseTok>}
type RuSt is Data:
  RuSt{pool: List<&2, ReuseTok>, seen: U32Map, rev: List<&2, IrOp>}
def opt_ru_ksrc_ops(ops: List<&2, IrOp>, m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{IKeep{_, s}, t}: opt_ru_ksrc_ops(t, um_set(m, s, 1))
    case Con{_, t}: opt_ru_ksrc_ops(t, m)
def opt_ru_ksrc_blks(blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, _}, t}: opt_ru_ksrc_blks(t, opt_ru_ksrc_ops(ops, m))
def opt_ru_filter_m(+m: U32Map, ps: List<&2, ReuseTok>) -> List<&2, ReuseTok>:
  match ps:
    case Nil{}: Nil{}
    case Con{RTok{+sl, ar}, t}:
      +rest = opt_ru_filter_m(m, t)
      Bool.pick(List<&2, ReuseTok>, U32.is_zero(um_get(m, sl)), Con{RTok{sl, ar}, rest}, rest)
def opt_ru_kill_op(op: IrOp, ps: List<&2, ReuseTok>) -> List<&2, ReuseTok>:
  match ps:
    case Nil{}: Nil{}
    case Con{h, t}: opt_ru_filter_m(opt_op_defs(op, UM0{}), Con{h, t})
def opt_ru_take_cons(h: ReuseTok, pk: RuPick) -> RuPick:
  match pk:
    case RuNo{}: RuNo{}
    case RuYes{sl, rest}: RuYes{sl, Con{h, rest}}
def opt_ru_cls(+n: U32) -> U32:
  Bool.pick(U32, U32.is_le(n, 1), 0, Bool.pick(U32, U32.is_eq(n, 2), 1, Bool.pick(U32, U32.is_le(n, 4), 2, 3)))
def opt_ru_take_ar(+k: U32, ps: List<&2, ReuseTok>) -> RuPick:
  match ps:
    case Nil{}: RuNo{}
    case Con{RTok{+sl, +ar}, +t}:
      Bool.pick(RuPick, U32.is_eq(opt_ru_cls(ar), opt_ru_cls(k)), RuYes{sl, t}, opt_ru_take_cons(RTok{sl, ar}, opt_ru_take_ar(k, t)))
def opt_ru_ctor_go(pk: RuPick, pool: List<&2, ReuseTok>, +d: U32, cid: U32, fs: List<&2, U32>, seen: U32Map, rev: List<&2, IrOp>) -> RuSt:
  match pk:
    case RuYes{sl, rest}: RuSt{opt_ru_filter_m(um_set(UM0{}, d, 1), rest), seen, Con{IReuse{d, sl, cid, fs}, rev}}
    case RuNo{}: RuSt{opt_ru_filter_m(um_set(UM0{}, d, 1), pool), seen, Con{ICtor{d, cid, fs}, rev}}
def opt_ru_ops(+ksrc: U32Map, +bu: U32Map, ops: List<&2, IrOp>, st: RuSt) -> RuSt:
  match ops st:
    case Nil{} _: st
    case Con{ITake{+ds, +s}, t} RuSt{pool, seen, rev}:
      +seen1 = opt_um_inc(seen, s)
      +k = b5k_u32_list_len(ds)
      +dm = opt_um_inc_list(ds, UM0{})
      +p1 = opt_ru_filter_m(dm, pool)
      ok = Bool.and(U32.is_ge(k, 1), Bool.and(U32.is_le(k, 8), Bool.and(U32.is_zero(um_get(ksrc, s)), Bool.and(U32.is_zero(um_get(dm, s)), U32.is_eq(um_get(seen1, s), um_get(bu, s))))))
      opt_ru_ops(ksrc, bu, t, RuSt{Bool.pick(List<&2, ReuseTok>, ok, Con{RTok{s, k}, p1}, p1), seen1, Con{ITake{ds, s}, rev}})
    case Con{ICtor{+d, cid, +fs}, t} RuSt{+pool, seen, rev}:
      +seen1 = opt_um_inc_list(fs, seen)
      +k = b5k_u32_list_len(fs)
      opt_ru_ops(ksrc, bu, t, opt_ru_ctor_go(opt_ru_take_ar(k, pool), pool, d, cid, fs, seen1, rev))
    case Con{+op, t} RuSt{pool, seen, rev}:
      opt_ru_ops(ksrc, bu, t, RuSt{opt_ru_kill_op(op, pool), opt_op_uses(op, seen), Con{op, rev}})
def opt_ru_blk_ud(mb: Maybe<&2, IrBlock>, m: U32Map) -> U32Map:
  match mb:
    case Some{IrBlock{_, +ops, term}}: opt_ops_defs(ops, opt_term_uses(term, opt_ops_uses(ops, m)))
    case None{}: m
def opt_ru_put(ok: Bool, +tgt: U32, ps: List<&2, ReuseTok>, pmap: RaVec<List<&2, ReuseTok>>) -> RaVec<List<&2, ReuseTok>>:
  match ok:
    case True{}: ra_vec_set(List<&2, ReuseTok>, 5n, tgt, ps, pmap)
    case False{}: pmap
def opt_ru_ops_has_ctor(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: False{}
    case Con{ICtor{_, _, _}, _}: True{}
    case Con{_, t}: opt_ru_ops_has_ctor(t)
def opt_ru_blk_has_ctor(mb: Maybe<&2, IrBlock>) -> Bool:
  match mb:
    case Some{IrBlock{_, ops, _}}: opt_ru_ops_has_ctor(ops)
    case None{}: False{}
def opt_ru_prop(+preds: U32Map, +jmps: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, +id: U32, term: IrTerm, ps: List<&2, ReuseTok>, +pmap: RaVec<List<&2, ReuseTok>>) -> RaVec<List<&2, ReuseTok>>:
  match term ps:
    case _ Nil{}: pmap
    case TJmp{+tgt} Con{h, t}:
      ok = Bool.and(U32.is_lt(tgt, 1024), Bool.and(U32.is_ne(tgt, id), U32.is_eq(um_get(preds, tgt), 1)))
      opt_ru_put(ok, tgt, Con{h, t}, pmap)
    case TBr{_, +tb, +fb} Con{+h, +t}:
      +ok_t = Bool.and(U32.is_lt(tb, 1024), Bool.and(U32.is_ne(tb, id), U32.is_eq(um_get(preds, tb), 1)))
      +ok_f = Bool.and(U32.is_lt(fb, 1024), Bool.and(U32.is_ne(fb, id), U32.is_eq(um_get(preds, fb), 1)))
      +jt = um_get(jmps, tb)
      +jf = um_get(jmps, fb)
      +m = U32.sub(jt, 1)
      +mbt = ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bmap)
      +mbf = ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap)
      +has_c = Bool.or(opt_ru_blk_has_ctor(mbt), opt_ru_blk_has_ctor(mbf))
      +ok_m = Bool.and(Bool.not(has_c), Bool.and(ok_t, Bool.and(ok_f, Bool.and(U32.is_ne(tb, fb), Bool.and(U32.is_ne(jt, 0), Bool.and(U32.is_eq(jt, jf), Bool.and(U32.is_lt(m, 1024), Bool.and(U32.is_ne(m, id), U32.is_eq(um_get(preds, m), 2)))))))))
      ud = opt_ru_blk_ud(mbf, opt_ru_blk_ud(mbt, UM0{}))
      Bool.pick(RaVec<List<&2, ReuseTok>>, ok_m, opt_ru_put(True{}, m, opt_ru_filter_m(ud, Con{h, t}), pmap), Bool.pick(RaVec<List<&2, ReuseTok>>, Bool.and(ok_t, Bool.and(ok_f, U32.is_ne(tb, fb))), opt_ru_put(True{}, fb, Con{h, t}, opt_ru_put(True{}, tb, Con{h, t}, pmap)), pmap))
    case _ _: pmap
def opt_ru_blk_ir(id: U32, term: IrTerm, st: RuSt) -> IrBlock:
  match st:
    case RuSt{_, _, rev}: IrBlock{id, b5k_list_rev(IrOp, rev), term}
def opt_ru_blk_pm(+preds: U32Map, +jmps: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, +id: U32, term: IrTerm, st: RuSt, pmap: RaVec<List<&2, ReuseTok>>) -> RaVec<List<&2, ReuseTok>>:
  match st:
    case RuSt{pool, _, _}: opt_ru_prop(preds, jmps, bmap, id, term, pool, pmap)
def opt_ru_blks(+ksrc: U32Map, +preds: U32Map, +jmps: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>, +pmap: RaVec<List<&2, ReuseTok>>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, +ops, +term}, t}:
      +bu = opt_term_uses(term, opt_ops_uses(ops, UM0{}))
      p0 = opt_ru_filter_m(bu, Bool.pick(List<&2, ReuseTok>, U32.is_lt(id, 1024), ra_vec_get(List<&2, ReuseTok>, 5n, Nil{}, id, pmap), Nil{}))
      +st = opt_ru_ops(ksrc, bu, ops, RuSt{p0, UM0{}, Nil{}})
      Con{opt_ru_blk_ir(id, term, st), opt_ru_blks(ksrc, preds, jmps, bmap, t, opt_ru_blk_pm(preds, jmps, bmap, id, term, st, pmap))}
def opt_ru_fn(f: IrFn) -> IrFn:
  match f:
    case IrFn{fid, nm, ar, nregs, esc, eff, is_m, +blks}:
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_ru_blks(opt_ru_ksrc_blks(blks, UM0{}), opt_count_preds(blks, um_set(UM0{}, 0, 2)), opt_jmp_tgts(blks, UM0{}), opt_index_blks(blks, RVEmpty{}), blks, RVEmpty{})}
def opt_fns_reuse(fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_ru_fn(f), opt_fns_reuse(t)}
# Pass J — Pure Test-Block Jump Threading, ITake Sink & Scalar Ctor-Swap Fold
type JtTest is Data:
  JTNone{}
  JTSome{v: U32, k: U32, is_ne: Bool, tb: U32, fb: U32}
def opt_jt_mk(+cop: U32, +a: U32, +b: U32, +ha: Bool, +va: U32, +hb: Bool, +vb: U32, +tb: U32, +fb: U32) -> JtTest:
  +ne = U32.is_eq(cop, 1)
  Bool.pick(JtTest, Bool.and(U32.is_le(cop, 1), Bool.and(hb, Bool.not(ha))), JTSome{a, vb, ne, tb, fb}, Bool.pick(JtTest, Bool.and(U32.is_le(cop, 1), Bool.and(ha, Bool.not(hb))), JTSome{b, va, ne, tb, fb}, JTNone{}))
def opt_jt_blk_test(+uses: U32Map, +gh: U32Map, +gv: U32Map, ops: List<&2, IrOp>, term: IrTerm) -> JtTest:
  match ops term:
    case Con{IConst{+kr, +kv}, Con{ICmp{+cr, +cop, +a, +b}, Nil{}}} TBr{+c, tb, fb}: Bool.pick(JtTest, Bool.and(U32.is_eq(cr, c), Bool.and(U32.is_eq(um_get(uses, cr), 1), U32.is_eq(um_get(uses, kr), 1))), opt_jt_mk(cop, a, b, U32.is_eq(a, kr), kv, U32.is_eq(b, kr), kv, tb, fb), JTNone{})
    case Con{ICmp{+cr, +cop, +a, +b}, Nil{}} TBr{+c, tb, fb}: Bool.pick(JtTest, Bool.and(U32.is_eq(cr, c), U32.is_eq(um_get(uses, cr), 1)), opt_jt_mk(cop, a, b, U32.is_ne(um_get(gh, a), 0), um_get(gv, a), U32.is_ne(um_get(gh, b), 0), um_get(gv, b), tb, fb), JTNone{})
    case _ _: JTNone{}
def opt_jt_collect(+uses: U32Map, +gh: U32Map, +gv: U32Map, blks: List<&2, IrBlock>, +m: RaVec<JtTest>) -> RaVec<JtTest>:
  match blks:
    case Nil{}: m
    case Con{IrBlock{+id, ops, term}, t}: opt_jt_collect(uses, gh, gv, t, Bool.pick(RaVec<JtTest>, U32.is_lt(id, 1024), ra_vec_set(JtTest, 5n, id, opt_jt_blk_test(uses, gh, gv, ops, term), m), m))
def opt_jt_step(jt: JtTest, fact: BrFact, +tgt: U32) -> U32:
  match jt fact:
    case JTSome{tv, +tk, is_ne, tb, fb} BFEq{fv, fk}:
      +eq = U32.is_eq(tk, fk)
      Bool.pick(U32, U32.is_eq(tv, fv), Bool.pick(U32, Bool.pick(Bool, is_ne, Bool.not(eq), eq), tb, fb), tgt)
    case JTSome{tv, tk, is_ne, tb, fb} BFNe{fv, fk}: Bool.pick(U32, Bool.and(U32.is_eq(tv, fv), U32.is_eq(tk, fk)), Bool.pick(U32, is_ne, tb, fb), tgt)
    case _ _: tgt
def opt_jt_chase(fuel: Nat, +jtm: RaVec<JtTest>, +fact: BrFact, +tgt: U32) -> U32:
  match fuel:
    case 0n: tgt
    case 1n+p:
      +nxt = Bool.pick(U32, U32.is_lt(tgt, 1024), opt_jt_step(ra_vec_get(JtTest, 5n, JTNone{}, tgt, jtm), fact, tgt), tgt)
      Bool.pick(U32, U32.is_eq(nxt, tgt), tgt, opt_jt_chase(p, jtm, fact, nxt))
def opt_jt_br_fact(is_t: Bool, +defc: U32Map, +ar: U32, sc: BrScan) -> BrFact:
  match sc:
    case BrScan{+has, +val, True{}, +cop, +a, +b}:
      +ha = U32.is_ne(um_get(has, a), 0)
      +hb = U32.is_ne(um_get(has, b), 0)
      +ie = Bool.pick(Bool, is_t, U32.is_zero(cop), U32.is_ne(cop, 0))
      Bool.pick(BrFact, Bool.and(hb, Bool.and(Bool.not(ha), opt_cp_can_prop(defc, ar, a))), Bool.pick(BrFact, ie, BFEq{a, um_get(val, b)}, BFNe{a, um_get(val, b)}), Bool.pick(BrFact, Bool.and(ha, Bool.and(Bool.not(hb), opt_cp_can_prop(defc, ar, b))), Bool.pick(BrFact, ie, BFEq{b, um_get(val, a)}, BFNe{b, um_get(val, a)}), BFNone{}))
    case _: BFNone{}
def opt_jt_lut_step(jt: JtTest, v: U32, k: U32) -> U32:
  match jt:
    case JTSome{tv, tk, is_ne, tb, fb}:
      Bool.pick(U32, Bool.and(U32.is_eq(tv, v), U32.is_eq(tk, k)), U32.add(Bool.pick(U32, is_ne, tb, fb), 1), 0)
    case JTNone{}: 0
def opt_jt_is_lut_head(fuel: Nat, +jtm: RaVec<JtTest>, +v: U32, +k: U32, +tgt: U32) -> Bool:
  match fuel:
    case 0n: True{}
    case 1n+p:
      +n1 = Bool.pick(U32, U32.is_lt(tgt, 1024), opt_jt_lut_step(ra_vec_get(JtTest, 5n, JTNone{}, tgt, jtm), v, k), 0)
      Bool.and(U32.is_ne(n1, 0), opt_jt_is_lut_head(p, jtm, v, U32.add(k, 1), U32.sub(n1, 1)))
def opt_jt_is_lut_tgt_go(jt: JtTest, jtm: RaVec<JtTest>) -> Bool:
  match jt:
    case JTSome{v, 0, is_ne, tb, fb}: opt_jt_is_lut_head(4n, jtm, v, 1, Bool.pick(U32, is_ne, tb, fb))
    case _: False{}
def opt_jt_is_lut_tgt(+jtm: RaVec<JtTest>, +tgt: U32) -> Bool:
  opt_jt_is_lut_tgt_go(Bool.pick(JtTest, U32.is_lt(tgt, 1024), ra_vec_get(JtTest, 5n, JTNone{}, tgt, jtm), JTNone{}), jtm)
def opt_jt_rw_blks(+defc: U32Map, +ar: U32, +gh: U32Map, +gv: U32Map, +fm: RaVec<BrFact>, +jtm: RaVec<JtTest>, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, +ops, TBr{+c, tb, fb}}, t}:
      +inf = Bool.pick(BrFact, U32.is_lt(id, 1024), ra_vec_get(BrFact, 5n, BFNone{}, id, fm), BFNone{})
      +sc = cf_br_scan_ops(c, ops, BrScan{gh, gv, False{}, 0, 0, 0})
      Con{IrBlock{id, ops, TBr{c, opt_jt_chase(8n, jtm, inf, opt_jt_chase(8n, jtm, opt_jt_br_fact(True{}, defc, ar, sc), tb)), opt_jt_chase(8n, jtm, inf, opt_jt_chase(8n, jtm, opt_jt_br_fact(False{}, defc, ar, sc), fb))}}, opt_jt_rw_blks(defc, ar, gh, gv, fm, jtm, t)}
    case Con{IrBlock{+id, ops, TJmp{+tgt}}, t}:
      nt = Bool.pick(U32, opt_jt_is_lut_tgt(jtm, tgt), tgt, opt_jt_chase(8n, jtm, Bool.pick(BrFact, U32.is_lt(id, 1024), ra_vec_get(BrFact, 5n, BFNone{}, id, fm), BFNone{}), tgt))
      Con{IrBlock{id, ops, TJmp{nt}}, opt_jt_rw_blks(defc, ar, gh, gv, fm, jtm, t)}
    case Con{b, t}: Con{b, opt_jt_rw_blks(defc, ar, gh, gv, fm, jtm, t)}
def opt_jt_round_gc(+ar: U32, +defc: U32Map, +blks: List<&2, IrBlock>, gc: CfGConsts) -> List<&2, IrBlock>:
  match gc:
    case CfGConsts{+gh, +gv}: opt_elim_unreach(opt_jt_rw_blks(defc, ar, gh, gv, cf_collect_facts(defc, ar, opt_count_preds(blks, um_set(UM0{}, 0, 2)), blks, RVEmpty{}), opt_jt_collect(opt_blks_uses(blks, UM0{}), gh, gv, blks, RVEmpty{}), blks))
def opt_jt_round(+ar: U32, +blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  +defc = opt_blks_defs(blks, UM0{})
  opt_jt_round_gc(ar, defc, blks, cf_gc_blks(defc, ar, blks, CfGConsts{UM0{}, UM0{}}))
def opt_tsink_pure(op: IrOp) -> Bool:
  match op:
    case IConst{_, _}: True{}
    case ICmp{_, _, _, _}: True{}
    case ITag{_, _}: True{}
    case _: False{}
def opt_tsink_any(+m: U32Map, xs: List<&2, U32>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{x, t}: Bool.or(U32.is_ne(um_get(m, x), 0), opt_tsink_any(m, t))
type TSinkRes is Data:
  TSNo{}
  TSHit{ops: List<&2, IrOp>, tk: IrOp}
def opt_tsink_find(ops_rev: List<&2, IrOp>, tail: List<&2, IrOp>, +pu: U32Map, +pd: U32Map) -> TSinkRes:
  match ops_rev:
    case Nil{}: TSNo{}
    case Con{ITake{+ds, +s}, rest}:
      +k = b5k_u32_list_len(ds)
      Bool.pick(TSinkRes, Bool.and(U32.is_ge(k, 1), Bool.and(U32.is_le(k, 8), Bool.and(Bool.not(opt_tsink_any(pu, ds)), Bool.and(U32.is_zero(um_get(pu, s)), U32.is_zero(um_get(pd, s)))))), TSHit{b5k_list_app(IrOp, b5k_list_rev(IrOp, rest), tail), ITake{ds, s}}, TSNo{})
    case Con{+op, rest}: Bool.pick(TSinkRes, opt_tsink_pure(op), opt_tsink_find(rest, Con{op, tail}, opt_op_uses(op, pu), opt_op_defs(op, pd)), TSNo{})
def opt_tsink_apply(r: TSinkRes, id: U32, orig: List<&2, IrOp>, c: U32, +tb: U32, +fb: U32, acc: List<&2, IrBlock>, prep: RaVec<List<&2, IrOp>>) -> SinkBlksRes:
  match r:
    case TSNo{}: SinkBlksRes{Con{IrBlock{id, orig, TBr{c, tb, fb}}, acc}, prep}
    case TSHit{nops, +tk}: SinkBlksRes{Con{IrBlock{id, nops, TBr{c, tb, fb}}, acc}, ra_vec_set(List<&2, IrOp>, 5n, fb, Con{tk, Nil{}}, ra_vec_set(List<&2, IrOp>, 5n, tb, Con{tk, Nil{}}, prep))}
def opt_tsink_scan(+preds: U32Map, blks: List<&2, IrBlock>, r: SinkBlksRes) -> SinkBlksRes:
  match blks r:
    case Nil{} _: r
    case Con{IrBlock{+id, +ops, TBr{+c, +tb, +fb}}, t} SinkBlksRes{acc, prep}:
      ok = Bool.and(U32.is_ne(tb, fb), Bool.and(U32.is_lt(tb, 1024), Bool.and(U32.is_lt(fb, 1024), Bool.and(U32.is_ne(tb, id), Bool.and(U32.is_ne(fb, id), Bool.and(U32.is_eq(um_get(preds, tb), 1), U32.is_eq(um_get(preds, fb), 1)))))))
      opt_tsink_scan(preds, t, opt_tsink_apply(Bool.pick(TSinkRes, ok, opt_tsink_find(b5k_list_rev(IrOp, ops), Nil{}, um_set(UM0{}, c, 1), UM0{}), TSNo{}), id, ops, c, tb, fb, acc, prep))
    case Con{b, t} SinkBlksRes{acc, prep}: opt_tsink_scan(preds, t, SinkBlksRes{Con{b, acc}, prep})
type CSwapArm is Data:
  CSNo{}
  CSArm{c1: U32, c2: U32, x: U32, y: U32}
def opt_cswap_arm(mb: Maybe<&2, IrBlock>) -> CSwapArm:
  match mb:
    case Some{IrBlock{_, Con{ICtor{+l1, +c1, Con{+x, Nil{}}}, Con{ICtor{+l2, c1b, Con{+y, Nil{}}}, Con{ICtor{+r, c2, Con{a, Con{b, Nil{}}}}, Nil{}}}}, TRet{rv}}}: Bool.pick(CSwapArm, Bool.and(U32.is_eq(c1, c1b), Bool.and(U32.is_ne(l1, l2), Bool.and(U32.is_eq(a, l1), Bool.and(U32.is_eq(b, l2), U32.is_eq(r, rv))))), CSArm{c1, c2, x, y}, CSNo{})
    case _: CSNo{}
def opt_cswap_fold(+sc: U32Map, at: CSwapArm, af: CSwapArm, +id: U32, +ops: List<&2, IrOp>, +c: U32, tb: U32, fb: U32, +nr: U32, +acc: List<&2, IrBlock>) -> CfBlksRes:
  match at af:
    case CSArm{+c1, +c2, +y, +x} CSArm{c1b, c2b, xb, yb}:
      ok = Bool.and(U32.is_eq(c1, c1b), Bool.and(U32.is_eq(c2, c2b), Bool.and(U32.is_eq(x, xb), Bool.and(U32.is_eq(y, yb), Bool.and(U32.is_ne(x, y), Bool.and(U32.is_eq(um_get(sc, x), 1), U32.is_eq(um_get(sc, y), 1)))))))
      Bool.pick(CfBlksRes, ok, CfBlksRes{Con{IrBlock{id, b5k_list_app(IrOp, ops, [IConst{nr, 0}, ICmp{U32.add(nr, 1), 1, c, nr}, IUn{U32.add(nr, 2), 0, U32.add(nr, 1)}, IBin{U32.add(nr, 3), 7, x, y}, IBin{U32.add(nr, 4), 5, U32.add(nr, 3), U32.add(nr, 2)}, IBin{U32.add(nr, 5), 7, x, U32.add(nr, 4)}, IBin{U32.add(nr, 6), 7, y, U32.add(nr, 4)}, ICtor{U32.add(nr, 7), c1, [U32.add(nr, 5)]}, ICtor{U32.add(nr, 8), c1, [U32.add(nr, 6)]}, ICtor{U32.add(nr, 9), c2, [U32.add(nr, 7), U32.add(nr, 8)]}]), TRet{U32.add(nr, 9)}}, acc}, U32.add(nr, 10)}, CfBlksRes{Con{IrBlock{id, ops, TBr{c, tb, fb}}, acc}, nr})
    case _ _: CfBlksRes{Con{IrBlock{id, ops, TBr{c, tb, fb}}, acc}, nr}
def opt_cswap_go(+sc: U32Map, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>, st: CfBlksRes) -> CfBlksRes:
  match blks st:
    case Nil{} CfBlksRes{acc, nr}: CfBlksRes{opt_elim_unreach(b5k_list_rev(IrBlock, acc)), nr}
    case Con{IrBlock{+id, ops, TBr{+c, +tb, +fb}}, t} CfBlksRes{acc, nr}:
      ok = Bool.and(U32.is_ne(tb, fb), Bool.and(U32.is_lt(tb, 1024), Bool.and(U32.is_lt(fb, 1024), Bool.and(U32.is_ne(tb, id), Bool.and(U32.is_ne(fb, id), Bool.and(U32.is_eq(um_get(preds, tb), 1), U32.is_eq(um_get(preds, fb), 1)))))))
      opt_cswap_go(sc, preds, bmap, t, opt_cswap_fold(sc, Bool.pick(CSwapArm, ok, opt_cswap_arm(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bmap)), CSNo{}), opt_cswap_arm(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap)), id, ops, c, tb, fb, nr, acc))
    case Con{b, t} CfBlksRes{acc, nr}: opt_cswap_go(sc, preds, bmap, t, CfBlksRes{Con{b, acc}, nr})
def opt_fn_jt_ru(f: IrFn) -> IrFn:
  match f:
    case IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, blks}:
      +b1 = opt_jt_round(ar, opt_jt_round(ar, blks))
      +b2 = opt_sink_fin(opt_tsink_scan(opt_count_preds(b1, um_set(UM0{}, 0, 2)), b1, SinkBlksRes{Nil{}, RVEmpty{}}))
      cf_fn_fin(fid, nm, ar, esc, eff, is_m, opt_cswap_go(opt_sc_compute(True{}, UM0{}, UM0{}, fid, ar, b2), opt_count_preds(b2, um_set(UM0{}, 0, 2)), opt_index_blks(b2, RVEmpty{}), b2, CfBlksRes{Nil{}, nregs}))
def opt_esc_pure_ops(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{IConst{_, _}, t}: opt_esc_pure_ops(t)
    case Con{ICopy{_, _}, t}: opt_esc_pure_ops(t)
    case Con{IBin{_, _, _, _}, t}: opt_esc_pure_ops(t)
    case Con{IUn{_, _, _}, t}: opt_esc_pure_ops(t)
    case Con{ICmp{_, _, _, _}, t}: opt_esc_pure_ops(t)
    case _: False{}
def opt_esc_pure_blks(blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: True{}
    case Con{IrBlock{_, _, TFail{_}}, _}: False{}
    case Con{IrBlock{_, ops, _}, t}: Bool.and(opt_esc_pure_ops(ops), opt_esc_pure_blks(t))
def opt_esc_params_clean(+defc: U32Map, n: Nat, +idx: U32) -> Bool:
  match n:
    case 0n: True{}
    case 1n+p: Bool.and(U32.is_zero(um_get(defc, idx)), opt_esc_params_clean(defc, p, U32.add(idx, 1)))
type EscInfo is Data:
  EscInfo{decs: U32Map, ors: U32Map, zcs: U32Map}
def opt_esc_scan_ops(+defc: U32Map, +ar: U32, +gh: U32Map, +gv: U32Map, ops: List<&2, IrOp>, st: EscInfo) -> EscInfo:
  match ops st:
    case Nil{} _: st
    case Con{IBin{+d, 1, +a, +b}, t} EscInfo{+decs, ors, zcs}:
      opt_esc_scan_ops(defc, ar, gh, gv, t, EscInfo{Bool.pick(U32Map, Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(U32.is_lt(a, ar), Bool.and(U32.is_ne(um_get(gh, b), 0), U32.is_eq(um_get(gv, b), 1)))), um_set(decs, d, U32.add(a, 1)), decs), ors, zcs})
    case Con{IBin{+d, 6, +a, +b}, t} EscInfo{decs, +ors, zcs}:
      +p = Bool.pick(U32, U32.is_lt(a, ar), U32.add(a, 1), Bool.pick(U32, U32.is_lt(b, ar), U32.add(b, 1), 0))
      opt_esc_scan_ops(defc, ar, gh, gv, t, EscInfo{decs, Bool.pick(U32Map, Bool.and(U32.is_eq(um_get(defc, d), 1), U32.is_ne(p, 0)), um_set(ors, d, p), ors), zcs})
    case Con{ICmp{+d, 0, +a, +b}, t} EscInfo{decs, ors, +zcs}:
      +ev = Bool.pick(U32, Bool.and(U32.is_ne(um_get(gh, b), 0), U32.is_zero(um_get(gv, b))), U32.add(a, 1), Bool.pick(U32, Bool.and(U32.is_ne(um_get(gh, a), 0), U32.is_zero(um_get(gv, a))), U32.add(b, 1), 0))
      opt_esc_scan_ops(defc, ar, gh, gv, t, EscInfo{decs, ors, Bool.pick(U32Map, Bool.and(U32.is_eq(um_get(defc, d), 1), U32.is_ne(ev, 0)), um_set(zcs, d, ev), zcs)})
    case Con{_, t} _: opt_esc_scan_ops(defc, ar, gh, gv, t, st)
def opt_esc_scan_blks(+defc: U32Map, +ar: U32, +gh: U32Map, +gv: U32Map, blks: List<&2, IrBlock>, st: EscInfo) -> EscInfo:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, _}, t}: opt_esc_scan_blks(defc, ar, gh, gv, t, opt_esc_scan_ops(defc, ar, gh, gv, ops, st))
def opt_esc_sim_ops(+c: U32, ops: List<&2, IrOp>, +m: U32Map) -> Maybe<&2, U32Map>:
  match ops:
    case Nil{}: Some{m}
    case Con{ICopy{+d, s}, t}: opt_esc_sim_ops(c, t, um_set(m, d, U32.add(opt_um_lookup_or(m, s), 1)))
    case Con{IBin{+d, 0, +a, +b}, +t}: Bool.pick(Maybe<&2, U32Map>, U32.is_eq(b, c), opt_esc_sim_ops(c, t, um_set(m, d, U32.add(opt_um_lookup_or(m, a), 1))), Bool.pick(Maybe<&2, U32Map>, U32.is_eq(a, c), opt_esc_sim_ops(c, t, um_set(m, d, U32.add(opt_um_lookup_or(m, b), 1))), None{}))
    case _: None{}
def opt_esc_chk_args(+pn: U32, +pe: U32, +e2: U32, +decs: U32Map, +fcm: U32Map, args: List<&2, U32>, +idx: U32) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{+a, t}:
      +v = opt_um_lookup_or(fcm, a)
      Bool.and(Bool.pick(Bool, U32.is_eq(idx, pn), U32.is_eq(um_get(decs, a), U32.add(pn, 1)), Bool.pick(Bool, U32.is_eq(idx, pe), U32.is_eq(v, e2), U32.is_eq(v, idx))), opt_esc_chk_args(pn, pe, e2, decs, fcm, t, U32.add(idx, 1)))
def opt_esc_chk_j2(mm2: Maybe<&2, U32Map>, +pn: U32, +pe: U32, +e2: U32, +decs: U32Map, args: List<&2, U32>) -> Bool:
  match mm2:
    case Some{m2}: opt_esc_chk_args(pn, pe, e2, decs, m2, args, 0)
    case None{}: False{}
def opt_esc_chk_join(mm: Maybe<&2, U32Map>, +fid: U32, +ar: U32, +pn: U32, +pe: U32, +e2: U32, +decs: U32Map, +c: U32, mj: Maybe<&2, IrBlock>) -> Bool:
  match mm mj:
    case Some{m1} Some{IrBlock{_, jops, TTailCall{cfid, +args}}}: Bool.and(U32.is_eq(cfid, fid), Bool.and(U32.is_eq(b5k_u32_list_len(args), ar), opt_esc_chk_j2(opt_esc_sim_ops(c, jops, m1), pn, pe, e2, decs, args)))
    case _ _: False{}
def opt_esc_chk_fb(mb: Maybe<&2, IrBlock>, +fid: U32, +ar: U32, +pn: U32, +pe: U32, +e2: U32, +decs: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, +c: U32) -> Bool:
  match mb:
    case Some{IrBlock{_, fops, TJmp{+jb}}}: Bool.and(U32.is_lt(jb, 1024), opt_esc_chk_join(opt_esc_sim_ops(c, fops, UM0{}), fid, ar, pn, pe, e2, decs, c, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, jb, bmap)))
    case _: False{}
def opt_esc_find_fb(+fid: U32, +ar: U32, +pn: U32, +pret: U32, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, ei: EscInfo, blks: List<&2, IrBlock>, +hits: U32Map) -> U32Map:
  match ei blks:
    case _ Nil{}: hits
    case EscInfo{+decs, +ors, +zcs} Con{IrBlock{_, _, TBr{+c, _, +fb}}, t}:
      +ev1 = um_get(zcs, c)
      +e2 = U32.sub(ev1, 1)
      +pe1 = Bool.pick(U32, U32.is_ne(ev1, 0), um_get(ors, e2), 0)
      +pe = U32.sub(pe1, 1)
      ok = Bool.and(U32.is_ne(pe1, 0), Bool.and(U32.is_ne(pe, pn), Bool.and(U32.is_ne(pe, pret), Bool.and(U32.is_lt(fb, 1024), Bool.and(U32.is_eq(um_get(preds, fb), 1), opt_esc_chk_fb(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap), fid, ar, pn, pe, e2, decs, bmap, c))))))
      opt_esc_find_fb(fid, ar, pn, pret, preds, bmap, EscInfo{decs, ors, zcs}, t, Bool.pick(U32Map, ok, um_set(hits, fb, 1), hits))
    case ei0 Con{_, t}: opt_esc_find_fb(fid, ar, pn, pret, preds, bmap, ei0, t, hits)
def opt_esc_apply(+pret: U32, +hits: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, ops, term}, t}: Con{Bool.pick(IrBlock, U32.is_ne(um_get(hits, id), 0), IrBlock{id, Nil{}, TRet{pret}}, IrBlock{id, ops, term}), opt_esc_apply(pret, hits, t)}
def opt_esc_ret_param(mb: Maybe<&2, IrBlock>, +ar: U32) -> U32:
  match mb:
    case Some{IrBlock{_, Nil{}, TRet{+rv}}}: Bool.pick(U32, U32.is_lt(rv, ar), U32.add(rv, 1), 0)
    case _: 0
def opt_abs_pure(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{op, t}: Bool.and(U32.is_ne(opt_op_pure_dst(op), 0), opt_abs_pure(t))
def opt_abs_zctors(ops: List<&2, IrOp>, m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{ICtor{d, cid, Nil{}}, t}: opt_abs_zctors(t, um_set(m, d, U32.add(cid, 1)))
    case Con{_, t}: opt_abs_zctors(t, m)
def opt_abs_args(+pn: U32, +decs: U32Map, +zcs: U32Map, +tf: TagFact, args: List<&2, U32>, +idx: U32) -> Bool:
  match tf args:
    case _ Nil{}: True{}
    case TFSome{src, cid} Con{+a, t}: Bool.and(Bool.pick(Bool, U32.is_eq(idx, pn), U32.is_eq(um_get(decs, a), U32.add(pn, 1)), Bool.or(U32.is_eq(a, idx), Bool.and(U32.is_eq(src, idx), U32.is_eq(U32.add(cid, 1), um_get(zcs, a))))), opt_abs_args(pn, decs, zcs, tf, t, U32.add(idx, 1)))
    case TFNone{} Con{+a, t}: Bool.and(Bool.pick(Bool, U32.is_eq(idx, pn), U32.is_eq(um_get(decs, a), U32.add(pn, 1)), U32.is_eq(a, idx)), opt_abs_args(pn, decs, zcs, TFNone{}, t, U32.add(idx, 1)))
def opt_abs_eb_ok(mb: Maybe<&2, IrBlock>, +pn: U32) -> Bool:
  match mb:
    case Some{IrBlock{_, ops, TRet{rv}}}: U32.is_zero(um_get(opt_term_uses(TRet{rv}, opt_ops_uses(ops, UM0{})), pn))
    case _: False{}
def opt_abs_rw_blks(+fid: U32, +ar: U32, +pn: U32, +eb: U32, +decs: U32Map, +fm: RaVec<TagFact>, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, +ops, TTailCall{+cfid, +args}}, t}: Con{Bool.pick(IrBlock, Bool.and(U32.is_eq(cfid, fid), Bool.and(U32.is_eq(b5k_u32_list_len(args), ar), Bool.and(U32.is_ne(id, eb), Bool.and(opt_abs_pure(ops), opt_abs_args(pn, decs, opt_abs_zctors(ops, UM0{}), Bool.pick(TagFact, U32.is_lt(id, 1024), ra_vec_get(TagFact, 5n, TFNone{}, id, fm), TFNone{}), args, 0))))), IrBlock{id, Nil{}, TJmp{eb}}, IrBlock{id, ops, TTailCall{cfid, args}}), opt_abs_rw_blks(fid, ar, pn, eb, decs, fm, t)}
    case Con{b, t}: Con{b, opt_abs_rw_blks(fid, ar, pn, eb, decs, fm, t)}
def opt_esc_fn_abs(+fid: U32, nm: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, pn: U32, eb: U32, ei: EscInfo, fm: RaVec<TagFact>, blks: List<&2, IrBlock>) -> IrFn:
  match ei:
    case EscInfo{decs, _, _}: IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_abs_rw_blks(fid, ar, pn, eb, decs, fm, blks)}
def opt_esc_fn_gc(ok: Bool, abs_ok: Bool, +fid: U32, nm: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +pn: U32, +eb: U32, +pret: U32, +defc: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, +blks: List<&2, IrBlock>, gc: CfGConsts) -> IrFn:
  match ok abs_ok gc:
    case True{} _ CfGConsts{gh, gv}: IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_esc_apply(pret, opt_esc_find_fb(fid, ar, pn, pret, opt_count_preds(blks, um_set(UM0{}, 0, 2)), bmap, opt_esc_scan_blks(defc, ar, gh, gv, blks, EscInfo{UM0{}, UM0{}, UM0{}}), blks, UM0{}), blks)}
    case False{} True{} CfGConsts{+gh, +gv}: opt_esc_fn_abs(fid, nm, ar, nregs, esc, eff, is_m, pn, eb, opt_esc_scan_blks(defc, ar, gh, gv, blks, EscInfo{UM0{}, UM0{}, UM0{}}), opt_id_collect_tf(opt_id_tag_blks(defc, ar, blks, UM0{}), gh, gv, opt_count_preds(blks, um_set(UM0{}, 0, 2)), blks, RVEmpty{}), blks)
    case _ _ _: IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}
def opt_esc_b0_pn(+c0: U32, +ar: U32, ops: List<&2, IrOp>, +zm: U32Map) -> U32:
  match ops:
    case Nil{}: 0
    case Con{IConst{+d, v}, t}: opt_esc_b0_pn(c0, ar, t, Bool.pick(U32Map, U32.is_zero(v), um_set(zm, d, 1), zm))
    case Con{ICmp{+d, 0, +a, +b}, t}:
      +p = Bool.pick(U32, Bool.and(U32.is_eq(d, c0), Bool.and(U32.is_lt(a, ar), U32.is_ne(um_get(zm, b), 0))), U32.add(a, 1), Bool.pick(U32, Bool.and(U32.is_eq(d, c0), Bool.and(U32.is_lt(b, ar), U32.is_ne(um_get(zm, a), 0))), U32.add(b, 1), 0))
      Bool.pick(U32, U32.is_ne(p, 0), p, opt_esc_b0_pn(c0, ar, t, zm))
    case Con{_, t}: opt_esc_b0_pn(c0, ar, t, zm)
def opt_esc_fn(f: IrFn) -> IrFn:
  match f:
    case IrFn{fid, nm, +ar, nregs, esc, +eff, is_m, Con{IrBlock{0, +ops0, TBr{+c0, +tb, +fb}}, rest}}:
      +blks : List<&2, IrBlock> = Con{IrBlock{0, ops0, TBr{c0, tb, fb}}, rest}
      +zp = opt_esc_b0_pn(c0, ar, ops0, UM0{})
      +pn = Bool.pick(U32, U32.is_lt(c0, ar), c0, U32.sub(zp, 1))
      +eb = Bool.pick(U32, U32.is_lt(c0, ar), fb, tb)
      +bmap = opt_index_blks(blks, RVEmpty{})
      +ebm = Bool.pick(Maybe<&2, IrBlock>, Bool.and(Bool.or(U32.is_lt(c0, ar), U32.is_ne(zp, 0)), U32.is_lt(eb, 1024)), ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, eb, bmap), None{})
      +pr1 = opt_esc_ret_param(ebm, ar)
      +defc = opt_blks_defs(blks, UM0{})
      +clean = opt_esc_params_clean(defc, U32.to_nat(ar), 0)
      +ok = Bool.and(U32.is_ne(pr1, 0), Bool.and(U32.is_ne(U32.sub(pr1, 1), pn), Bool.and(opt_esc_pure_blks(blks), clean)))
      +abs_ok = Bool.and(Bool.not(ok), Bool.and(Bool.not(eff), Bool.and(clean, opt_abs_eb_ok(ebm, pn))))
      opt_esc_fn_gc(ok, abs_ok, fid, nm, ar, nregs, esc, eff, is_m, pn, eb, U32.sub(pr1, 1), defc, bmap, blks, Bool.pick(CfGConsts, Bool.or(ok, abs_ok), cf_gc_blks(defc, ar, blks, CfGConsts{UM0{}, UM0{}}), CfGConsts{UM0{}, UM0{}}))
    case other: other
def opt_fns_early_exit(fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_esc_fn(f), opt_fns_early_exit(t)}
# Pass L — True 1-Pass TRMC (Tail Recursion Modulo Cons) with IMutField
type TrmcDir is Data:
  TrmcDirNo{}
  TrmcDirHit{pre: List<&2, IrOp>, c: U32, cid: U32, fs: List<&2, U32>, args: List<&2, U32>, hidx: U32}
type TrmcFlt is Data:
  TrmcFltNo{}
  TrmcFltHit{pre: List<&2, IrOp>, rec: U32, args: List<&2, U32>, post: List<&2, IrOp>}
type TrmcArm is Data:
  TrmcANone{}
  TrmcACons{c: U32, cid: U32, fs: List<&2, U32>, args: List<&2, U32>}
  TrmcASkip{args: List<&2, U32>}
type TrmcScan is Data:
  TrmcScan{ok: Bool, cnt: U32, hidx1: U32, maxb: U32, flth: U32Map, arms: RaVec<TrmcArm>}
type TrmcRw is Data:
  TrmcRw{main_rev: List<&2, IrBlock>, extra_rev: List<&2, IrBlock>, nr: U32, nb: U32}
def trmc_last_eq(fs: List<&2, U32>, +rec: U32, +idx: U32) -> U32:
  match fs:
    case Nil{}: 0
    case Con{+x, Nil{}}: Bool.pick(U32, Bool.and(U32.is_eq(x, rec), Bool.and(U32.is_ge(idx, 1), U32.is_le(idx, 7))), U32.add(idx, 1), 0)
    case Con{+x, t}: Bool.pick(U32, U32.is_eq(x, rec), 0, trmc_last_eq(t, rec, U32.add(idx, 1)))
def trmc_rep_last(fs: List<&2, U32>, +z: U32) -> List<&2, U32>:
  match fs:
    case Nil{}: Nil{}
    case Con{_, Nil{}}: Con{z, Nil{}}
    case Con{x, t}: Con{x, trmc_rep_last(t, z)}
def trmc_no_self(+fid: U32, ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{ICallDirect{_, cfid, _}, t}: Bool.and(U32.is_ne(cfid, fid), trmc_no_self(fid, t))
    case Con{_, t}: trmc_no_self(fid, t)
def trmc_term_ok(term: IrTerm) -> Bool:
  match term:
    case TJmp{tgt}: U32.is_ne(tgt, 0)
    case TBr{_, tb, fb}: Bool.and(U32.is_ne(tb, 0), U32.is_ne(fb, 0))
    case TSwitch{_, arms, db}: Bool.and(U32.is_ne(db, 0), U32.is_zero(um_get(opt_pred_arms(arms, UM0{}), 0)))
    case TTailCall{_, _}: False{}
    case _: True{}
def trmc_dir_find(+fid: U32, +ar: U32, +rv: U32, ops: List<&2, IrOp>, +rev: List<&2, IrOp>) -> TrmcDir:
  match ops:
    case Con{ICallDirect{+rec, +cfid, +args}, Con{ICtor{+c, +cid, +fs}, Nil{}}}:
      +h1 = trmc_last_eq(fs, rec, 0)
      Bool.pick(TrmcDir, Bool.and(U32.is_eq(cfid, fid), Bool.and(U32.is_eq(b5k_u32_list_len(args), ar), Bool.and(U32.is_eq(c, rv), Bool.and(U32.is_ne(h1, 0), trmc_no_self(fid, rev))))), TrmcDirHit{b5k_list_rev(IrOp, rev), c, cid, fs, args, U32.sub(h1, 1)}, TrmcDirNo{})
    case Con{op, t}: trmc_dir_find(fid, ar, rv, t, Con{op, rev})
    case Nil{}: TrmcDirNo{}
def trmc_post_ok(+rec: U32, +am: U32Map, ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{+op, t}:
      +d1 = opt_op_pure_dst(op)
      Bool.and(Bool.and(U32.is_ne(d1, 0), Bool.and(U32.is_zero(um_get(am, U32.sub(d1, 1))), U32.is_zero(um_get(opt_op_uses(op, UM0{}), rec)))), trmc_post_ok(rec, am, t))
def trmc_flt_split(+fid: U32, +ar: U32, ops: List<&2, IrOp>, +rev: List<&2, IrOp>) -> TrmcFlt:
  match ops:
    case Nil{}: TrmcFltNo{}
    case Con{ICallDirect{+rec, +cfid, +args}, +post}: Bool.pick(TrmcFlt, Bool.and(U32.is_eq(cfid, fid), Bool.and(U32.is_eq(b5k_u32_list_len(args), ar), Bool.and(trmc_no_self(fid, rev), trmc_post_ok(rec, opt_um_inc_list(args, UM0{}), post)))), TrmcFltHit{b5k_list_rev(IrOp, rev), rec, args, post}, TrmcFltNo{})
    case Con{op, t}: trmc_flt_split(fid, ar, t, Con{op, rev})
def trmc_chk_cons(mb: Maybe<&2, IrBlock>, +rec: U32) -> TrmcDir:
  match mb:
    case Some{IrBlock{_, Con{ICtor{+c, +cid, +fs}, Nil{}}, TRet{+rv}}}:
      +h1 = trmc_last_eq(fs, rec, 0)
      Bool.pick(TrmcDir, Bool.and(U32.is_eq(c, rv), U32.is_ne(h1, 0)), TrmcDirHit{Nil{}, c, cid, fs, Nil{}, U32.sub(h1, 1)}, TrmcDirNo{})
    case _: TrmcDirNo{}
def trmc_chk_skip(mb: Maybe<&2, IrBlock>, +fid: U32, +rec: U32) -> Bool:
  match mb:
    case Some{IrBlock{_, +sops, TRet{rv}}}: Bool.and(U32.is_eq(rv, rec), Bool.and(trmc_no_self(fid, sops), U32.is_zero(um_get(opt_ops_uses(sops, UM0{}), rec))))
    case _: False{}
def trmc_merge_h(+cur: U32, +cid: U32, +hidx: U32) -> U32:
  +h1 = U32.add(U32.or(U32.shln(cid, 4n), hidx), 1)
  Bool.pick(U32, Bool.or(U32.is_zero(cur), U32.is_eq(cur, h1)), h1, 4294967295)
def trmc_scan_flt2(cd: TrmcDir, sk: Bool, +id: U32, +cbid: U32, +sbid: U32, +args: List<&2, U32>, st: TrmcScan) -> TrmcScan:
  match cd sk st:
    case TrmcDirHit{_, c, +cid, fs, _, hidx} True{} TrmcScan{ok, cnt, h1, mb, flth, arms}:
      +nh = trmc_merge_h(h1, cid, hidx)
      TrmcScan{Bool.and(ok, U32.is_ne(nh, 4294967295)), U32.add(cnt, 1), nh, mb, um_set(flth, id, 1), ra_vec_set(TrmcArm, 5n, sbid, TrmcASkip{args}, ra_vec_set(TrmcArm, 5n, cbid, TrmcACons{c, cid, fs, args}, arms))}
    case _ _ TrmcScan{_, cnt, h1, mb, flth, arms}: TrmcScan{False{}, cnt, h1, mb, flth, arms}
def trmc_scan_flt_p(ct: TrmcDir, fid: U32, +rec: U32, id: U32, tb: U32, fb: U32, mt: Maybe<&2, IrBlock>, mf: Maybe<&2, IrBlock>, args: List<&2, U32>, st: TrmcScan) -> TrmcScan:
  match ct:
    case TrmcDirHit{pre, c, cid, fs, a0, hidx}: trmc_scan_flt2(TrmcDirHit{pre, c, cid, fs, a0, hidx}, trmc_chk_skip(mf, fid, rec), id, tb, fb, args, st)
    case TrmcDirNo{}: trmc_scan_flt2(trmc_chk_cons(mf, rec), trmc_chk_skip(mt, fid, rec), id, fb, tb, args, st)
def trmc_scan_flt(+fid: U32, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, +id: U32, +tb: U32, +fb: U32, flt: TrmcFlt, st: TrmcScan) -> TrmcScan:
  match flt st:
    case TrmcFltHit{_, +rec, +args, _} _:
      +br_ok = Bool.and(U32.is_ne(tb, fb), Bool.and(U32.is_lt(tb, 1024), Bool.and(U32.is_lt(fb, 1024), Bool.and(U32.is_eq(um_get(preds, tb), 1), U32.is_eq(um_get(preds, fb), 1)))))
      +mt = Bool.pick(Maybe<&2, IrBlock>, br_ok, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bmap), None{})
      +mf = Bool.pick(Maybe<&2, IrBlock>, br_ok, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap), None{})
      trmc_scan_flt_p(trmc_chk_cons(mt, rec), fid, rec, id, tb, fb, mt, mf, args, st)
    case TrmcFltNo{} TrmcScan{_, cnt, h1, mb, flth, arms}: TrmcScan{False{}, cnt, h1, mb, flth, arms}
def trmc_scan_dir(dh: TrmcDir, +fid: U32, ops: List<&2, IrOp>, st: TrmcScan) -> TrmcScan:
  match dh st:
    case TrmcDirHit{_, _, cid, _, _, hidx} TrmcScan{ok, cnt, h1, mb, flth, arms}:
      +nh = trmc_merge_h(h1, cid, hidx)
      TrmcScan{Bool.and(ok, U32.is_ne(nh, 4294967295)), U32.add(cnt, 1), nh, mb, flth, arms}
    case TrmcDirNo{} TrmcScan{ok, cnt, h1, mb, flth, arms}: TrmcScan{Bool.and(ok, trmc_no_self(fid, ops)), cnt, h1, mb, flth, arms}
def trmc_scan_blks(+fid: U32, +ar: U32, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>, st: TrmcScan) -> TrmcScan:
  match blks st:
    case Nil{} _: st
    case Con{IrBlock{+id, +ops, TRet{rv}}, t} TrmcScan{ok, cnt, h1, mb, flth, arms}: trmc_scan_blks(fid, ar, preds, bmap, t, trmc_scan_dir(trmc_dir_find(fid, ar, rv, ops, Nil{}), fid, ops, TrmcScan{ok, cnt, h1, U32.max(mb, id), flth, arms}))
    case Con{IrBlock{+id, +ops, TBr{_, +tb, +fb}}, t} TrmcScan{ok, cnt, h1, mb, flth, arms}:
      +st0 : TrmcScan = TrmcScan{Bool.and(ok, Bool.and(U32.is_ne(tb, 0), U32.is_ne(fb, 0))), cnt, h1, U32.max(mb, id), flth, arms}
      trmc_scan_blks(fid, ar, preds, bmap, t, Bool.pick(TrmcScan, trmc_no_self(fid, ops), st0, trmc_scan_flt(fid, preds, bmap, id, tb, fb, trmc_flt_split(fid, ar, ops, Nil{}), st0)))
    case Con{IrBlock{+id, +ops, +term}, t} TrmcScan{ok, cnt, h1, mb, flth, arms}: trmc_scan_blks(fid, ar, preds, bmap, t, TrmcScan{Bool.and(Bool.and(ok, trmc_term_ok(term)), trmc_no_self(fid, ops)), cnt, h1, U32.max(mb, id), flth, arms})
def trmc_emit_cons(tc: TcoSt, +bloop: U32, +rh: U32, +rp: U32, +cidx: U32, +nid: U32, pre: List<&2, IrOp>, +c: U32, cid: U32, fs: List<&2, U32>, mrev: List<&2, IrBlock>, erev: List<&2, IrBlock>, +nb: U32) -> TrmcRw:
  match tc:
    case TcoSt{p1r, p2r, +nr2}:
      +cops = b5k_list_app(IrOp, b5k_list_rev(IrOp, p1r), b5k_list_rev(IrOp, p2r))
      TrmcRw{Con{IrBlock{nb, Con{IMutField{rp, cidx, c}, Con{ICopy{rp, c}, cops}}, TJmp{bloop}}, Con{IrBlock{nid, b5k_list_app(IrOp, pre, [IConst{nr2, 0}, ICtor{c, cid, trmc_rep_last(fs, nr2)}]), TBr{rp, nb, U32.add(nb, 1)}}, mrev}}, Con{IrBlock{U32.add(nb, 1), Con{ICopy{rh, c}, Con{ICopy{rp, c}, cops}}, TJmp{bloop}}, erev}, U32.add(nr2, 1), U32.add(nb, 2)}
def trmc_emit_skip(tc: TcoSt, bloop: U32, nid: U32, ops: List<&2, IrOp>, mrev: List<&2, IrBlock>, erev: List<&2, IrBlock>, nb: U32) -> TrmcRw:
  match tc:
    case TcoSt{p1r, p2r, nr2}: TrmcRw{Con{IrBlock{nid, b5k_list_app(IrOp, ops, b5k_list_app(IrOp, b5k_list_rev(IrOp, p1r), b5k_list_rev(IrOp, p2r))), TJmp{bloop}}, mrev}, erev, nr2, nb}
def trmc_drop_call(flt: TrmcFlt, orig: List<&2, IrOp>) -> List<&2, IrOp>:
  match flt:
    case TrmcFltHit{pre, _, _, post}: b5k_list_app(IrOp, pre, post)
    case TrmcFltNo{}: orig
def trmc_rw_dir(dh: TrmcDir, ar: U32, bloop: U32, rh: U32, +rp: U32, cidx: U32, nid: U32, ops: List<&2, IrOp>, +rv: U32, rw: TrmcRw) -> TrmcRw:
  match dh rw:
    case TrmcDirHit{pre, c, cid, fs, args, _} TrmcRw{mrev, erev, nr, nb}: trmc_emit_cons(opt_tco_args(ar, UM0{}, args, 0, TcoSt{Nil{}, Nil{}, nr}), bloop, rh, rp, cidx, nid, pre, c, cid, fs, mrev, erev, nb)
    case TrmcDirNo{} TrmcRw{mrev, erev, nr, +nb}: TrmcRw{Con{IrBlock{U32.add(nb, 1), Nil{}, TRet{rv}}, Con{IrBlock{nb, [IMutField{rp, cidx, rv}], TRet{rh}}, Con{IrBlock{nid, ops, TBr{rp, nb, U32.add(nb, 1)}}, mrev}}}, erev, nr, U32.add(nb, 2)}
def trmc_rw_ret(+fid: U32, +ar: U32, +bloop: U32, +rh: U32, +rp: U32, +cidx: U32, +nid: U32, +ops: List<&2, IrOp>, +rv: U32, arm: TrmcArm, rw: TrmcRw) -> TrmcRw:
  match arm rw:
    case TrmcACons{c, cid, fs, args} TrmcRw{mrev, erev, nr, nb}: trmc_emit_cons(opt_tco_args(ar, UM0{}, args, 0, TcoSt{Nil{}, Nil{}, nr}), bloop, rh, rp, cidx, nid, Nil{}, c, cid, fs, mrev, erev, nb)
    case TrmcASkip{args} TrmcRw{mrev, erev, nr, nb}: trmc_emit_skip(opt_tco_args(ar, UM0{}, args, 0, TcoSt{Nil{}, Nil{}, nr}), bloop, nid, ops, mrev, erev, nb)
    case TrmcANone{} rw0: trmc_rw_dir(trmc_dir_find(fid, ar, rv, ops, Nil{}), ar, bloop, rh, rp, cidx, nid, ops, rv, rw0)
def trmc_rw_blks(+fid: U32, +ar: U32, +bloop: U32, +rh: U32, +rp: U32, +cidx: U32, +flth: U32Map, +arms: RaVec<TrmcArm>, blks: List<&2, IrBlock>, rw: TrmcRw) -> TrmcRw:
  match blks rw:
    case Nil{} _: rw
    case Con{IrBlock{+id, +ops, TRet{rv}}, t} rw0: trmc_rw_blks(fid, ar, bloop, rh, rp, cidx, flth, arms, t, trmc_rw_ret(fid, ar, bloop, rh, rp, cidx, Bool.pick(U32, U32.is_zero(id), bloop, id), ops, rv, Bool.pick(TrmcArm, U32.is_lt(id, 1024), ra_vec_get(TrmcArm, 5n, TrmcANone{}, id, arms), TrmcANone{}), rw0))
    case Con{IrBlock{+id, +ops, TBr{c, tb, fb}}, t} TrmcRw{mrev, erev, nr, nb}: trmc_rw_blks(fid, ar, bloop, rh, rp, cidx, flth, arms, t, TrmcRw{Con{IrBlock{Bool.pick(U32, U32.is_zero(id), bloop, id), Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(flth, id), 0), trmc_drop_call(trmc_flt_split(fid, ar, ops, Nil{}), ops), ops), TBr{c, tb, fb}}, mrev}, erev, nr, nb})
    case Con{IrBlock{+id, ops, term}, t} TrmcRw{mrev, erev, nr, nb}: trmc_rw_blks(fid, ar, bloop, rh, rp, cidx, flth, arms, t, TrmcRw{Con{IrBlock{Bool.pick(U32, U32.is_zero(id), bloop, id), ops, term}, mrev}, erev, nr, nb})
def trmc_fin(fid: U32, nm: String, ar: U32, esc: Bool, eff: Bool, is_m: Bool, bloop: U32, rh: U32, rp: U32, rw: TrmcRw) -> IrFn:
  match rw:
    case TrmcRw{mrev, erev, nr, _}: IrFn{fid, nm, ar, nr, esc, eff, is_m, Con{IrBlock{0, [IConst{rh, 0}, IConst{rp, 0}], TJmp{bloop}}, b5k_list_app(IrBlock, b5k_list_rev(IrBlock, mrev), b5k_list_rev(IrBlock, erev))}}
def trmc_apply_go(go: Bool, +fid: U32, nm: String, +ar: U32, +nregs: U32, esc: Bool, eff: Bool, is_m: Bool, blks: List<&2, IrBlock>, h1: U32, +maxb: U32, flth: U32Map, arms: RaVec<TrmcArm>) -> IrFn:
  match go:
    case False{}: IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}
    case True{}:
      +rh = U32.max(nregs, ar)
      trmc_fin(fid, nm, ar, esc, eff, is_m, U32.add(maxb, 1), rh, U32.add(rh, 1), trmc_rw_blks(fid, ar, U32.add(maxb, 1), rh, U32.add(rh, 1), U32.sub(h1, 1), flth, arms, blks, TrmcRw{Nil{}, Nil{}, U32.add(rh, 2), U32.add(maxb, 2)}))
def trmc_apply_sc(fid: U32, nm: String, ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, blks: List<&2, IrBlock>, sc: TrmcScan) -> IrFn:
  match sc:
    case TrmcScan{True{}, cnt, +h1, maxb, flth, arms}: trmc_apply_go(Bool.and(U32.is_gt(cnt, 0), Bool.and(U32.is_ne(h1, 0), U32.is_ne(h1, 4294967295))), fid, nm, ar, nregs, esc, eff, is_m, blks, h1, maxb, flth, arms)
    case _: IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}
def trmc_apply(can: Bool, +fid: U32, nm: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>) -> IrFn:
  match can:
    case False{}: IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}
    case True{}: trmc_apply_sc(fid, nm, ar, nregs, esc, eff, is_m, blks, trmc_scan_blks(fid, ar, opt_count_preds(blks, um_set(UM0{}, 0, 2)), opt_index_blks(blks, RVEmpty{}), blks, TrmcScan{True{}, 0, 0, 0, UM0{}, RVEmpty{}}))
def opt_fns_trmc(fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{IrFn{+fid, nm, +ar, nregs, esc, +eff, +is_m, blks}, t}: Con{trmc_apply(Bool.and(U32.is_ge(fid, 3), Bool.and(Bool.not(eff), Bool.and(Bool.not(is_m), Bool.and(U32.is_ge(ar, 1), U32.is_le(ar, 16))))), fid, nm, ar, nregs, esc, eff, is_m, blks), opt_fns_trmc(t)}
def opt_fns_jt_ru(fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_fn_jt_ru(f), opt_fns_jt_ru(t)}
# Pass K — Higher-Order Closure Beta-Reduction & Multi-Block Record SROA
type CloTab is Data:
  CloTab{cfid: U32Map, cnc: U32Map}
def opt_ho_arm(mb: Maybe<&2, IrBlock>, +cid: U32, st: CloTab) -> CloTab:
  match mb st:
    case Some{IrBlock{_, Con{ITake{caps, 0}, Con{ICallDirect{_, tfid, _}, Nil{}}}, TRet{_}}} CloTab{cf, cn}: CloTab{um_set(cf, cid, U32.add(tfid, 1)), um_set(cn, cid, b5k_u32_list_len(caps))}
    case Some{IrBlock{_, Con{ISink{0}, Con{ICallDirect{_, tfid, _}, Nil{}}}, TRet{_}}} CloTab{cf, cn}: CloTab{um_set(cf, cid, U32.add(tfid, 1)), um_set(cn, cid, 0)}
    case _ _: st
def opt_ho_arms(+bmap: RaVec<Maybe<&2, IrBlock>>, arms: List<&2, IrSwitchArm>, +st: CloTab) -> CloTab:
  match arms:
    case Nil{}: st
    case Con{IrArm{+cid, +tgt}, t}: opt_ho_arms(bmap, t, Bool.pick(CloTab, Bool.and(U32.is_ne(cid, 38), U32.is_lt(tgt, 1024)), opt_ho_arm(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tgt, bmap), cid, st), st))
def opt_ho_table(fns: List<&2, IrFn>) -> CloTab:
  match fns:
    case Nil{}: CloTab{UM0{}, UM0{}}
    case Con{IrFn{0, _, _, _, _, _, _, Con{IrBlock{0, _, TSwitch{_, arms, _}}, rest}}, _}: opt_ho_arms(opt_index_blks(rest, RVEmpty{}), arms, CloTab{UM0{}, UM0{}})
    case Con{_, t}: opt_ho_table(t)
def opt_ho_beta_apply(pe: WwCtorEnt, +cf: U32Map, +cn: U32Map, +d: U32, +c: U32, +arg: U32, +acc: List<&2, IrOp>, +fused: U32Map) -> SroaRes:
  match pe:
    case WSome{v, +cid, +k, +fs}:
      +ok = Bool.and(U32.is_eq(v, c), Bool.and(U32.is_ne(um_get(cf, cid), 0), U32.is_eq(k, um_get(cn, cid))))
      SroaRes{Con{Bool.pick(IrOp, ok, ICallDirect{d, U32.sub(um_get(cf, cid), 1), b5k_list_app(U32, fs, [arg])}, ICallDirect{d, 0, [c, arg]}), acc}, Bool.pick(U32Map, ok, um_set(fused, c, 1), fused)}
    case WNone{}: SroaRes{Con{ICallDirect{d, 0, [c, arg]}, acc}, fused}
def opt_ho_beta_ops(+cf: U32Map, +cn: U32Map, +defc: U32Map, +uses: U32Map, +ar: U32, ops: List<&2, IrOp>, +pc: RaVec<WwCtorEnt>, st: SroaRes) -> SroaRes:
  match ops st:
    case Nil{} _: st
    case Con{ICtor{+d, +cid, +fs}, t} SroaRes{acc, fused}: opt_ho_beta_ops(cf, cn, defc, uses, ar, t, opt_ww_put_pc(Bool.and(U32.is_ne(um_get(cf, cid), 0), Bool.and(U32.is_lt(d, 4096), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(U32.is_eq(um_get(uses, d), 1), opt_all_can_prop(defc, ar, fs))))), pc, d, cid, b5k_u32_list_len(fs), fs), SroaRes{Con{ICtor{d, cid, fs}, acc}, fused})
    case Con{ICallDirect{d, 0, Con{+c, Con{+arg, Nil{}}}}, t} SroaRes{acc, fused}: opt_ho_beta_ops(cf, cn, defc, uses, ar, t, pc, opt_ho_beta_apply(ra_vec_get(WwCtorEnt, 6n, WNone{}, c, pc), cf, cn, d, c, arg, acc, fused))
    case Con{op, t} SroaRes{acc, fused}: opt_ho_beta_ops(cf, cn, defc, uses, ar, t, pc, SroaRes{Con{op, acc}, fused})
def opt_ho_beta_blks(+cf: U32Map, +cn: U32Map, +defc: U32Map, +uses: U32Map, +ar: U32, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}: Con{sroa_blk_fin(id, term, opt_ho_beta_ops(cf, cn, defc, uses, ar, ops, RVEmpty{}, SroaRes{Nil{}, UM0{}})), opt_ho_beta_blks(cf, cn, defc, uses, ar, t)}
def opt_ho_beta_fns(ct: CloTab, fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match ct fns:
    case _ Nil{}: Nil{}
    case CloTab{+cf, +cn} Con{IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, +blks}, t}:
      Con{IrFn{fid, nm, ar, nregs, esc, eff, is_m, Bool.pick(List<&2, IrBlock>, U32.is_ge(fid, 3), opt_ho_beta_blks(cf, cn, opt_blks_defs(blks, UM0{}), opt_blks_uses(blks, UM0{}), ar, blks), blks)}, opt_ho_beta_fns(CloTab{cf, cn}, t)}
type MsInfo is Data:
  MsInfo{arm: U32Map, cidm: U32Map, bad: U32Map, htag: U32Map}
def ms_merge_cid(+c0: U32, +c1: U32) -> U32:
  Bool.pick(U32, U32.is_zero(c1), c0, Bool.pick(U32, Bool.or(U32.is_zero(c0), U32.is_eq(c0, c1)), c1, 4294967295))
def ms_scan_ops(ops: List<&2, IrOp>, st: MsInfo) -> MsInfo:
  match ops st:
    case Nil{} _: st
    case Con{ICtor{+d, +cid, +fs}, t} MsInfo{+arm, +cidm, +bad, htag}:
      +k = b5k_u32_list_len(fs)
      +ok = Bool.and(U32.is_lt(d, 4096), Bool.and(U32.is_ge(k, 2), Bool.and(U32.is_le(k, 8), Bool.or(U32.is_zero(um_get(arm, d)), U32.is_eq(um_get(arm, d), k)))))
      ms_scan_ops(t, MsInfo{Bool.pick(U32Map, ok, um_set(arm, d, k), arm), Bool.pick(U32Map, ok, um_set(cidm, d, ms_merge_cid(um_get(cidm, d), U32.add(cid, 1))), cidm), Bool.pick(U32Map, ok, opt_um_inc_list(fs, bad), um_set(opt_um_inc_list(fs, bad), d, 1)), htag})
    case Con{ITake{+ds, +s}, t} MsInfo{+arm, cidm, +bad, htag}:
      +k = b5k_u32_list_len(ds)
      +ok = Bool.and(U32.is_lt(s, 4096), Bool.and(U32.is_ge(k, 2), Bool.and(U32.is_le(k, 8), Bool.or(U32.is_zero(um_get(arm, s)), U32.is_eq(um_get(arm, s), k)))))
      ms_scan_ops(t, MsInfo{Bool.pick(U32Map, ok, um_set(arm, s, k), arm), cidm, Bool.pick(U32Map, ok, opt_um_inc_list(ds, bad), um_set(opt_um_inc_list(ds, bad), s, 1)), htag})
    case Con{ICopy{_, _}, t} _: ms_scan_ops(t, st)
    case Con{ISink{+s}, t} MsInfo{arm, cidm, +bad, htag}: ms_scan_ops(t, MsInfo{arm, cidm, Bool.pick(U32Map, U32.is_lt(s, 4096), bad, um_set(bad, s, 1)), htag})
    case Con{ITag{+d, +s}, t} MsInfo{arm, cidm, bad, htag}: ms_scan_ops(t, MsInfo{arm, cidm, um_set(bad, d, 1), um_set(htag, s, 1)})
    case Con{+op, t} MsInfo{arm, cidm, bad, htag}: ms_scan_ops(t, MsInfo{arm, cidm, opt_op_defs(op, opt_op_uses(op, bad)), htag})
def ms_scan_blks(blks: List<&2, IrBlock>, st: MsInfo) -> MsInfo:
  match blks st:
    case Nil{} _: st
    case Con{IrBlock{_, ops, term}, t} MsInfo{arm, cidm, bad, htag}: ms_scan_blks(t, ms_scan_ops(ops, MsInfo{arm, cidm, opt_term_uses(term, bad), htag}))
def ms_prop_ops(ops: List<&2, IrOp>, st: MsInfo) -> MsInfo:
  match ops st:
    case Nil{} _: st
    case Con{ICopy{+d, +s}, t} MsInfo{+arm, +cidm, +bad, +htag}:
      +ad = um_get(arm, d)
      +as0 = um_get(arm, s)
      +conf = Bool.or(U32.is_ge(d, 4096), Bool.or(U32.is_ge(s, 4096), Bool.or(U32.is_ne(um_get(bad, d), 0), Bool.or(U32.is_ne(um_get(bad, s), 0), Bool.and(U32.is_ne(ad, 0), Bool.and(U32.is_ne(as0, 0), U32.is_ne(ad, as0)))))))
      +a2 = Bool.pick(U32, U32.is_ne(ad, 0), ad, as0)
      ms_prop_ops(t, Bool.pick(MsInfo, U32.is_eq(d, s), MsInfo{arm, cidm, bad, htag}, MsInfo{Bool.pick(U32Map, Bool.and(Bool.not(conf), U32.is_ne(a2, 0)), um_set(um_set(arm, d, a2), s, a2), arm), Bool.pick(U32Map, conf, cidm, um_set(cidm, d, ms_merge_cid(um_get(cidm, d), um_get(cidm, s)))), Bool.pick(U32Map, conf, um_set(um_set(bad, d, 1), s, 1), bad), Bool.pick(U32Map, Bool.and(Bool.not(conf), Bool.or(U32.is_ne(um_get(htag, d), 0), U32.is_ne(um_get(htag, s), 0))), um_set(um_set(htag, d, 1), s, 1), htag)}))
    case Con{_, t} _: ms_prop_ops(t, st)
def ms_prop_blks(blks: List<&2, IrBlock>, st: MsInfo) -> MsInfo:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, _}, t}: ms_prop_blks(t, ms_prop_ops(ops, st))
def ms_prop_n(k: Nat, +blks: List<&2, IrBlock>, st: MsInfo) -> MsInfo:
  match k:
    case 0n: st
    case 1n+p: ms_prop_n(p, blks, ms_prop_blks(blks, st))
def ms_v_ok(+arm: U32Map, +cidm: U32Map, +bad: U32Map, +htag: U32Map, +v: U32) -> Bool:
  Bool.and(U32.is_zero(um_get(bad, v)), Bool.and(U32.is_ge(um_get(arm, v), 2), Bool.and(U32.is_ne(um_get(cidm, v), 0), Bool.or(U32.is_zero(um_get(htag, v)), U32.is_ne(um_get(cidm, v), 4294967295)))))
def ms_chk_v(+arm: U32Map, +cidm: U32Map, +htag: U32Map, +v: U32, +bad: U32Map) -> U32Map:
  Bool.pick(U32Map, ms_v_ok(arm, cidm, bad, htag, v), bad, um_set(bad, v, 1))
def ms_chk_ops(+arm: U32Map, +cidm: U32Map, +htag: U32Map, ops: List<&2, IrOp>, bad: U32Map) -> U32Map:
  match ops:
    case Nil{}: bad
    case Con{ICopy{d, s}, t}: ms_chk_ops(arm, cidm, htag, t, ms_chk_v(arm, cidm, htag, d, ms_chk_v(arm, cidm, htag, s, bad)))
    case Con{ITake{_, s}, t}: ms_chk_ops(arm, cidm, htag, t, ms_chk_v(arm, cidm, htag, s, bad))
    case Con{ITag{_, s}, t}: ms_chk_ops(arm, cidm, htag, t, ms_chk_v(arm, cidm, htag, s, bad))
    case Con{ISink{s}, t}: ms_chk_ops(arm, cidm, htag, t, ms_chk_v(arm, cidm, htag, s, bad))
    case Con{_, t}: ms_chk_ops(arm, cidm, htag, t, bad)
def ms_chk_blks(+arm: U32Map, +cidm: U32Map, +htag: U32Map, blks: List<&2, IrBlock>, bad: U32Map) -> U32Map:
  match blks:
    case Nil{}: bad
    case Con{IrBlock{_, ops, _}, t}: ms_chk_blks(arm, cidm, htag, t, ms_chk_ops(arm, cidm, htag, ops, bad))
def ms_alloc_v(+arm: U32Map, +cidm: U32Map, +bad: U32Map, +htag: U32Map, +v: U32, st: WwExSt) -> WwExSt:
  match st:
    case WwExSt{+ex, +nr}: Bool.pick(WwExSt, Bool.and(U32.is_zero(um_get(ex, v)), Bool.and(U32.is_lt(nr, 7500), ms_v_ok(arm, cidm, bad, htag, v))), WwExSt{um_set(ex, v, U32.add(nr, 1)), U32.add(nr, um_get(arm, v))}, WwExSt{ex, nr})
def ms_alloc_ops(+arm: U32Map, +cidm: U32Map, +bad: U32Map, +htag: U32Map, ops: List<&2, IrOp>, st: WwExSt) -> WwExSt:
  match ops:
    case Nil{}: st
    case Con{ICtor{d, _, _}, t}: ms_alloc_ops(arm, cidm, bad, htag, t, ms_alloc_v(arm, cidm, bad, htag, d, st))
    case Con{ICopy{d, s}, t}: ms_alloc_ops(arm, cidm, bad, htag, t, ms_alloc_v(arm, cidm, bad, htag, d, ms_alloc_v(arm, cidm, bad, htag, s, st)))
    case Con{ITake{_, s}, t}: ms_alloc_ops(arm, cidm, bad, htag, t, ms_alloc_v(arm, cidm, bad, htag, s, st))
    case Con{_, t}: ms_alloc_ops(arm, cidm, bad, htag, t, st)
def ms_alloc_blks(+arm: U32Map, +cidm: U32Map, +bad: U32Map, +htag: U32Map, blks: List<&2, IrBlock>, st: WwExSt) -> WwExSt:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, _}, t}: ms_alloc_blks(arm, cidm, bad, htag, t, ms_alloc_ops(arm, cidm, bad, htag, ops, st))
def ms_edges_ok_ops(+ex: U32Map, ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{ICopy{d, s}, t}: Bool.and(U32.is_eq(Bool.to_u32(U32.is_ne(um_get(ex, d), 0)), Bool.to_u32(U32.is_ne(um_get(ex, s), 0))), ms_edges_ok_ops(ex, t))
    case Con{_, t}: ms_edges_ok_ops(ex, t)
def ms_edges_ok_blks(+ex: U32Map, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: True{}
    case Con{IrBlock{_, ops, _}, t}: Bool.and(ms_edges_ok_ops(ex, ops), ms_edges_ok_blks(ex, t))
def ms_rw_ops(+arm: U32Map, +cidm: U32Map, +ex: U32Map, ops: List<&2, IrOp>, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: b5k_list_rev(IrOp, acc)
    case Con{ICtor{+d, cid, +fs}, t}: ms_rw_ops(arm, cidm, ex, t, Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(ex, d), 0), sroa_emit_copies(opt_ww_seq(U32.to_nat(um_get(arm, d)), U32.sub(um_get(ex, d), 1)), fs, acc), Con{ICtor{d, cid, fs}, acc}))
    case Con{ICopy{+d, +s}, t}: ms_rw_ops(arm, cidm, ex, t, Bool.pick(List<&2, IrOp>, Bool.and(U32.is_ne(um_get(ex, d), 0), U32.is_ne(um_get(ex, s), 0)), sroa_emit_copies(opt_ww_seq(U32.to_nat(um_get(arm, d)), U32.sub(um_get(ex, d), 1)), opt_ww_seq(U32.to_nat(um_get(arm, s)), U32.sub(um_get(ex, s), 1)), acc), Con{ICopy{d, s}, acc}))
    case Con{ITake{+ds, +s}, t}: ms_rw_ops(arm, cidm, ex, t, Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(ex, s), 0), sroa_emit_copies(ds, opt_ww_seq(U32.to_nat(um_get(arm, s)), U32.sub(um_get(ex, s), 1)), acc), Con{ITake{ds, s}, acc}))
    case Con{ISink{+s}, t}: ms_rw_ops(arm, cidm, ex, t, Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(ex, s), 0), sroa_emit_sinks(opt_ww_seq(U32.to_nat(um_get(arm, s)), U32.sub(um_get(ex, s), 1)), acc), Con{ISink{s}, acc}))
    case Con{ITag{+d, +s}, t}: ms_rw_ops(arm, cidm, ex, t, Con{Bool.pick(IrOp, U32.is_ne(um_get(ex, s), 0), IConst{d, U32.sub(um_get(cidm, s), 1)}, ITag{d, s}), acc})
    case Con{op, t}: ms_rw_ops(arm, cidm, ex, t, Con{op, acc})
def ms_rw_blks(+arm: U32Map, +cidm: U32Map, +ex: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}: Con{IrBlock{id, ms_rw_ops(arm, cidm, ex, ops, Nil{}), term}, ms_rw_blks(arm, cidm, ex, t)}
def ms_fin2(fid: U32, nm: String, ar: U32, +nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, arm: U32Map, cidm: U32Map, st: WwExSt) -> IrFn:
  match st:
    case WwExSt{+ex, +nr2}:
      +ok = Bool.and(U32.is_gt(nr2, nregs), Bool.and(U32.is_lt(nr2, 7500), ms_edges_ok_blks(ex, blks)))
      IrFn{fid, nm, ar, Bool.pick(U32, ok, nr2, nregs), esc, eff, is_m, Bool.pick(List<&2, IrBlock>, ok, ms_rw_blks(arm, cidm, ex, blks), blks)}
def ms_fin1(fid: U32, nm: String, ar: U32, +nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, info: MsInfo) -> IrFn:
  match info:
    case MsInfo{+arm, +cidm, +bad, +htag}: ms_fin2(fid, nm, ar, nregs, esc, eff, is_m, blks, arm, cidm, ms_alloc_blks(arm, cidm, bad, htag, blks, WwExSt{UM0{}, nregs}))
def ms_chk_fin(fid: U32, nm: String, ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, info: MsInfo) -> IrFn:
  match info:
    case MsInfo{+arm, +cidm, bad, +htag}: ms_fin1(fid, nm, ar, nregs, esc, eff, is_m, blks, ms_prop_n(8n, blks, MsInfo{arm, cidm, ms_chk_blks(arm, cidm, htag, blks, bad), htag}))
def opt_msroa_go(ok: Bool, fid: U32, nm: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>) -> IrFn:
  match ok:
    case False{}: IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}
    case True{}: ms_chk_fin(fid, nm, ar, nregs, esc, eff, is_m, blks, ms_prop_n(8n, blks, ms_scan_blks(blks, MsInfo{UM0{}, UM0{}, opt_um_set_list(opt_ww_seq(U32.to_nat(ar), 0), 1, UM0{}), UM0{}})))
def opt_msroa_fn(f: IrFn) -> IrFn:
  match f:
    case IrFn{+fid, nm, ar, +nregs, esc, eff, is_m, blks}: opt_msroa_go(Bool.and(U32.is_ge(fid, 3), U32.is_lt(nregs, 4096)), fid, nm, ar, nregs, esc, eff, is_m, blks)
def opt_fns_msroa(fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_msroa_fn(f), opt_fns_msroa(t)}
# Pass I — IR Array RMW Fusion (72/78 + add/sub + 73/79 -> 80/81) & Exit-Block In-Place Dst Coalescing
def opt_rmw_fuse_ops(+uses: U32Map, ops: List<&2, IrOp>, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: b5k_list_rev(IrOp, acc)
    case Con{IArrOp{Con{+dv, Nil{}}, 78, Con{+a, Con{+i, Nil{}}}}, Con{IBin{+v2, +bop, +bl, +cv}, Con{IArrOp{Con{+da2, Nil{}}, +aop3, Con{+a2, Con{+i2, Con{+v3, Nil{}}}}}, +t}}}:
      ok = Bool.and(Bool.and(U32.is_le(bop, 1), Bool.or(U32.is_eq(aop3, 73), U32.is_eq(aop3, 79))), Bool.and(Bool.and(U32.is_eq(bl, dv), Bool.and(U32.is_eq(v3, v2), Bool.and(U32.is_eq(a2, a), U32.is_eq(i2, i)))), Bool.and(U32.is_eq(um_get(uses, dv), 1), U32.is_eq(um_get(uses, v2), 1))))
      Bool.pick(List<&2, IrOp>, ok,
        opt_rmw_fuse_ops(uses, t, Con{IArrOp{[da2], U32.add(80, bop), [a, i, cv]}, acc}),
        opt_rmw_fuse_ops(uses, Con{IBin{v2, bop, bl, cv}, Con{IArrOp{[da2], aop3, [a2, i2, v3]}, t}}, Con{IArrOp{[dv], 78, [a, i]}, acc}))
    case Con{IArrOp{Con{+dv, Nil{}}, 78, Con{+a, Con{+i, Nil{}}}}, Con{IConst{+c1, +c0}, Con{IBin{+v2, +bop, +bl, +cv}, Con{IArrOp{Con{+da2, Nil{}}, +aop3, Con{+a2, Con{+i2, Con{+v3, Nil{}}}}}, +t}}}}:
      ok = Bool.and(Bool.and(U32.is_le(bop, 1), Bool.or(U32.is_eq(aop3, 73), U32.is_eq(aop3, 79))), Bool.and(Bool.and(U32.is_eq(bl, dv), Bool.and(U32.is_eq(v3, v2), Bool.and(U32.is_eq(a2, a), U32.is_eq(i2, i)))), Bool.and(U32.is_eq(um_get(uses, dv), 1), U32.is_eq(um_get(uses, v2), 1))))
      Bool.pick(List<&2, IrOp>, ok,
        opt_rmw_fuse_ops(uses, t, Con{IArrOp{[da2], U32.add(80, bop), [a, i, cv]}, Con{IConst{c1, c0}, acc}}),
        opt_rmw_fuse_ops(uses, Con{IConst{c1, c0}, Con{IBin{v2, bop, bl, cv}, Con{IArrOp{[da2], aop3, [a2, i2, v3]}, t}}}, Con{IArrOp{[dv], 78, [a, i]}, acc}))
    case Con{IArrOp{Con{+da, Con{+dv, Nil{}}}, 72, Con{+a, Con{+i, Nil{}}}}, Con{IBin{+v2, +bop, +bl, +cv}, Con{IArrOp{Con{+da2, Nil{}}, +aop3, Con{+a2, Con{+i2, Con{+v3, Nil{}}}}}, +t}}}:
      ok = Bool.and(Bool.and(U32.is_le(bop, 1), Bool.or(U32.is_eq(aop3, 73), U32.is_eq(aop3, 79))), Bool.and(Bool.and(U32.is_eq(bl, dv), Bool.and(U32.is_eq(v3, v2), Bool.and(U32.is_eq(a2, da), U32.is_eq(i2, i)))), Bool.and(U32.is_eq(um_get(uses, dv), 1), Bool.and(U32.is_eq(um_get(uses, v2), 1), U32.is_eq(um_get(uses, da), 1)))))
      Bool.pick(List<&2, IrOp>, ok,
        opt_rmw_fuse_ops(uses, t, Con{IArrOp{[da2], U32.add(80, bop), [a, i, cv]}, acc}),
        opt_rmw_fuse_ops(uses, Con{IBin{v2, bop, bl, cv}, Con{IArrOp{[da2], aop3, [a2, i2, v3]}, t}}, Con{IArrOp{[da, dv], 72, [a, i]}, acc}))
    case Con{IArrOp{Con{+da, Con{+dv, Nil{}}}, 72, Con{+a, Con{+i, Nil{}}}}, Con{IConst{+c1, +c0}, Con{IBin{+v2, +bop, +bl, +cv}, Con{IArrOp{Con{+da2, Nil{}}, +aop3, Con{+a2, Con{+i2, Con{+v3, Nil{}}}}}, +t}}}}:
      ok = Bool.and(Bool.and(U32.is_le(bop, 1), Bool.or(U32.is_eq(aop3, 73), U32.is_eq(aop3, 79))), Bool.and(Bool.and(U32.is_eq(bl, dv), Bool.and(U32.is_eq(v3, v2), Bool.and(U32.is_eq(a2, da), U32.is_eq(i2, i)))), Bool.and(U32.is_eq(um_get(uses, dv), 1), Bool.and(U32.is_eq(um_get(uses, v2), 1), U32.is_eq(um_get(uses, da), 1)))))
      Bool.pick(List<&2, IrOp>, ok,
        opt_rmw_fuse_ops(uses, t, Con{IArrOp{[da2], U32.add(80, bop), [a, i, cv]}, Con{IConst{c1, c0}, acc}}),
        opt_rmw_fuse_ops(uses, Con{IConst{c1, c0}, Con{IBin{v2, bop, bl, cv}, Con{IArrOp{[da2], aop3, [a2, i2, v3]}, t}}}, Con{IArrOp{[da, dv], 72, [a, i]}, acc}))
    case Con{op, t}: opt_rmw_fuse_ops(uses, t, Con{op, acc})
def opt_is_exit_term(term: IrTerm) -> Bool:
  match term:
    case TRet{_}: True{}
    case TTailCall{_, _}: True{}
    case TFail{_}: True{}
    case _: False{}
def opt_arr_inpl_ops(+uses: U32Map, +id: U32, ops: List<&2, IrOp>, +cm: U32Map, +term: IrTerm, +acc: List<&2, IrOp>) -> IrBlock:
  match ops:
    case Nil{}: IrBlock{id, b5k_list_rev(IrOp, acc), opt_cp_term(cm, term)}
    case Con{IArrOp{Con{+da, Nil{}}, +aop, Con{+a0, +ra0}}, +t}:
      +a = opt_um_lookup_or(cm, a0)
      +ra = opt_map_u32(cm, ra0)
      +is_w = Bool.or(U32.is_eq(aop, 73), Bool.and(U32.is_ge(aop, 79), U32.is_le(aop, 81)))
      +lu = opt_ops_uses(t, opt_term_uses(term, UM0{}))
      +ok = Bool.and(Bool.and(is_w, U32.is_ne(da, a)), Bool.and(U32.is_zero(um_get(lu, a0)), Bool.and(U32.is_zero(um_get(lu, a)), Bool.and(U32.is_eq(um_get(lu, da), um_get(uses, da)), U32.is_zero(um_get(opt_ops_defs(t, UM0{}), da))))))
      opt_arr_inpl_ops(uses, id, t, Bool.pick(U32Map, ok, um_set(cm, da, U32.add(a, 1)), cm), term, Con{IArrOp{[Bool.pick(U32, ok, a, da)], aop, Con{a, ra}}, acc})
    case Con{op, t}: opt_arr_inpl_ops(uses, id, t, cm, term, Con{opt_cp_rewrite_op(cm, op), acc})
def opt_rmw_blk(+uses: U32Map, b: IrBlock) -> IrBlock:
  match b:
    case IrBlock{+id, ops, +term}:
      +ops1 = opt_rmw_fuse_ops(uses, ops, Nil{})
      Bool.pick(IrBlock, opt_is_exit_term(term), opt_arr_inpl_ops(uses, id, ops1, UM0{}, term, Nil{}), IrBlock{id, ops1, term})
def opt_rmw_blks(+uses: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{b, t}: Con{opt_rmw_blk(uses, b), opt_rmw_blks(uses, t)}
def opt_fn_arr_rmw(f: IrFn) -> IrFn:
  match f:
    case IrFn{fid, nm, ar, nregs, esc, eff, is_m, +blks}:
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_rmw_blks(opt_blks_uses(blks, UM0{}), blks)}
def opt_fns_arr_rmw(fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_fn_arr_rmw(f), opt_fns_arr_rmw(t)}
# Top-Level -O2 Pipeline
def opt_fn_local(+small: Bool, +ret_sc: U32Map, +psc: U32Map, f: IrFn) -> IrFn:
  match small:
    case True{}: opt_pass_cp_dce(False{}, opt_pass_sroa_fuse(opt_pass_sroa_tag(opt_pass_cp_dce(True{}, opt_pass_cf(True{}, opt_pass_sroa_tag(opt_pass_scalar(True{}, ret_sc, psc, f)))))))
    case False{}: opt_pass_cf(False{}, opt_pass_scalar(False{}, ret_sc, psc, f))
def opt_fns_local(+small: Bool, +ret_sc: U32Map, +psc: U32Map, fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_fn_local(small, ret_sc, psc, f), opt_fns_local(small, ret_sc, psc, t)}
def opt_fns_mid(fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_pass_cp_dce(True{}, opt_pass_sroa_fuse(opt_pass_cf(True{}, opt_pass_sroa_tag(f)))), opt_fns_mid(t)}
def b5k_opt_fin(+small: Bool, fns3: List<&2, IrFn>, ip1: IpRes) -> List<&2, IrFn>:
  match ip1:
    case IpRes{ret1, psc1, _}: opt_fns_local(small, ret1, psc1, fns3)
def b5k_opt_go(small: Bool, +fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match small:
    case True{}:
      +ctab = opt_ho_table(fns)
      +ret0 = opt_collect_ret_only(fns, UM0{})
      +fns0 = b5k_opt_fin(True{}, fns, opt_collect_ip(True{}, fns, ret0))
      +fns1a = opt_fns_mid(opt_ho_beta_fns(ctab, opt_inl_all(False{}, 64, opt_collect_inlines(False{}, True{}, 64, 16, fns0, InlBank{UM0{}, RVEmpty{}}), fns0)))
      +fns1 = opt_fns_mid(opt_inl_all(False{}, 64, opt_collect_inlines(False{}, True{}, 128, 20, fns1a, InlBank{UM0{}, RVEmpty{}}), fns1a))
      +fns2a = opt_fns_mid(opt_inl_all(False{}, 64, opt_collect_inlines(False{}, True{}, 160, 24, fns1, InlBank{UM0{}, RVEmpty{}}), fns1))
      +fns2 = opt_fns_mid(opt_inl_all(False{}, 64, opt_collect_inlines(False{}, True{}, 224, 24, fns2a, InlBank{UM0{}, RVEmpty{}}), fns2a))
      +fns3a = opt_fns_mid(opt_ho_beta_fns(ctab, opt_inl_all(False{}, 48, opt_collect_inlines(False{}, False{}, 160, 28, fns2, InlBank{UM0{}, RVEmpty{}}), fns2)))
      +fns3b = opt_fns_mid(opt_inl_all(False{}, 48, opt_collect_inlines(True{}, False{}, 512, 64, fns3a, InlBank{UM0{}, RVEmpty{}}), fns3a))
      +fns3c = opt_fns_mid(opt_inl_all(False{}, 48, opt_collect_inlines(True{}, False{}, 512, 64, fns3b, InlBank{UM0{}, RVEmpty{}}), fns3b))
      +fns3d = opt_fns_mid(opt_inl_all(False{}, 48, opt_collect_inlines(True{}, False{}, 512, 64, fns3c, InlBank{UM0{}, RVEmpty{}}), fns3c))
      +fns3 = opt_fns_mid(opt_ho_beta_fns(ctab, opt_inl_all(False{}, 48, opt_collect_inlines(True{}, False{}, 512, 64, fns3d, InlBank{UM0{}, RVEmpty{}}), fns3d)))
      +fns3e = opt_fns_mid(opt_inl_all(False{}, 64, opt_collect_inlines(False{}, True{}, 224, 24, fns3, InlBank{UM0{}, RVEmpty{}}), fns3))
      +fns4a = opt_fns_mid(opt_fns_msroa(opt_fns_mid(opt_ww_pass(opt_fns_mid(opt_ww_pass(fns3e))))))
      +fns4b = opt_fns_mid(opt_inl_all(False{}, 4, opt_collect_self_tc(fns4a, InlBank{UM0{}, RVEmpty{}}), fns4a))
      +fns4 = opt_fns_mid(opt_inl_all(True{}, 4, opt_collect_self_tc(fns4b, InlBank{UM0{}, RVEmpty{}}), fns4b))
      +fns5 = opt_fns_id_arm(opt_fns_sel_mask(b5k_opt_fin(True{}, fns4, opt_collect_ip(True{}, fns4, ret0))))
      +fns6 = opt_fns_mid(opt_fns_sel_mask(b5k_opt_fin(True{}, fns5, opt_collect_ip(True{}, fns5, ret0))))
      opt_fns_arr_rmw(opt_fns_tco_large(opt_fns_reuse(opt_fns_jt_ru(opt_fns_trmc(opt_fns_early_exit(opt_fns_fuse_sink(fns6)))))))
    case False{}:
      opt_fns_tco_large(opt_fns_local(False{}, UM0{}, UM0{}, fns))
def b5k_opt(prog: IrProg) -> IrProg:
  match prog:
    case IrProg{+fns, ctors, statics, main_fid, main_pure, effects, show_desc, show_names}:
      small = U32.is_le(b5k_list_len(IrFn, fns), 384)
      IrProg{b5k_opt_go(small, fns), ctors, statics, main_fid, main_pure, effects, show_desc, show_names}
