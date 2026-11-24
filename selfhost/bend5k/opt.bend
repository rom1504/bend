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
def opt_kill_op_dsts(op: IrOp, m: U32Map) -> U32Map:
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
    case IKeep{d, _}: um_set(m, d, 0)
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
def opt_cp_can_prop(+defc: U32Map, +ar: U32, +r: U32) -> Bool:
  +dc = um_get(defc, r)
  Bool.pick(Bool, U32.is_lt(r, ar), U32.is_zero(dc), U32.is_le(dc, 1))
def opt_all_can_prop(+defc: U32Map, +ar: U32, xs: List<&2, U32>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{r, t}: Bool.and(opt_cp_can_prop(defc, ar, r), opt_all_can_prop(defc, ar, t))
# Pass 1 & Pass B — Interprocedural Scalar Inference & IKeep/ISink Elision
def opt_pkey(+fid: U32, +idx: U32) -> U32:
  U32.or(U32.shln(fid, 5n), idx)
def opt_sc_init_params(+fid: U32, +psc: U32Map, n: Nat, +idx: U32, m: U32Map) -> U32Map:
  match n:
    case 0n: m
    case 1n+p:
      ok = Bool.and(U32.is_lt(fid, 2048), Bool.and(U32.is_lt(idx, 32), U32.is_eq(um_get(psc, opt_pkey(fid, idx)), 1)))
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
def opt_sc_compute(+ret_sc: U32Map, +psc: U32Map, +fid: U32, +ar: U32, +blks: List<&2, IrBlock>) -> U32Map:
  m0 = opt_sc_direct_blks(ret_sc, blks, opt_sc_init_params(fid, psc, U32.to_nat(ar), 0, UM0{}))
  opt_sc_prop_n(2n, True{}, blks, opt_sc_prop_n(2n, False{}, blks, m0))
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
      ok_range = Bool.and(U32.is_lt(cfid, 2048), U32.is_lt(idx, 32))
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
      +prom = Bool.and(U32.is_lt(idx, 32), Bool.and(U32.is_zero(um_get(psc0, k)), U32.is_eq(um_get(obs, k), 1)))
      opt_ip_promote_params(fid, obs, p, U32.add(idx, 1), ret_sc, Bool.pick(U32Map, prom, um_set(psc0, k, 1), psc0), Bool.or(chg, prom))
def opt_ip_prom_one(ok: Bool, +fid: U32, +obs: U32Map, ar: U32, ret_sc: U32Map, psc: U32Map, chg: Bool) -> IpRes:
  match ok:
    case False{}: IpRes{ret_sc, psc, chg}
    case True{}: opt_ip_promote_params(fid, obs, U32.to_nat(U32.min(ar, 32)), 0, ret_sc, psc, chg)
def opt_ip_promote_fns(+bad: U32Map, +obs: U32Map, fns: List<&2, IrFn>, st: IpRes) -> IpRes:
  match fns st:
    case Nil{} _: st
    case Con{IrFn{+fid, _, ar, _, _, _, _, _}, t} IpRes{ret_sc, psc, chg}:
      opt_ip_promote_fns(bad, obs, t, opt_ip_prom_one(U32.is_zero(um_get(bad, fid)), fid, obs, ar, ret_sc, psc, chg))
type IpScan is Data:
  IpScan{ret_sc: U32Map, obs: U32Map, chg: Bool}
def opt_ip_scan_fns(+psc: U32Map, fns: List<&2, IrFn>, st: IpScan) -> IpScan:
  match fns st:
    case Nil{} _: st
    case Con{IrFn{+fid, _, +ar, _, _, _, _, +blks}, t} IpScan{+ret_sc, obs, chg}:
      +sc = opt_sc_compute(ret_sc, psc, fid, ar, blks)
      defc = opt_blks_defs(blks, UM0{})
      orig = opt_ip_orig_blks(defc, ar, blks, opt_ip_init_orig(U32.to_nat(ar), 0, UM0{}))
      obs1 = opt_ip_obs_blks(fid, sc, orig, blks, obs)
      +new_ret = Bool.and(U32.is_ge(fid, 3), Bool.and(U32.is_zero(um_get(ret_sc, fid)), opt_sc_all_rets(fid, ret_sc, sc, blks, False{})))
      ret1 = Bool.pick(U32Map, new_ret, um_set(ret_sc, fid, 1), ret_sc)
      opt_ip_scan_fns(psc, t, IpScan{ret1, obs1, Bool.or(chg, new_ret)})
def opt_ip_step(+bad: U32Map, +fns: List<&2, IrFn>, psc0: U32Map, sc: IpScan) -> IpRes:
  match sc:
    case IpScan{ret1, obs1, chg1}: opt_ip_promote_fns(bad, obs1, fns, IpRes{ret1, psc0, chg1})
def opt_ip_fix(fuel: Nat, +bad: U32Map, +fns: List<&2, IrFn>, st: IpRes) -> IpRes:
  match fuel st:
    case 0n _: st
    case _ IpRes{ret_sc, psc, False{}}: IpRes{ret_sc, psc, False{}}
    case 1n+p IpRes{ret_sc, +psc0, True{}}:
      opt_ip_fix(p, bad, fns, opt_ip_step(bad, fns, psc0, opt_ip_scan_fns(psc0, fns, IpScan{ret_sc, UM0{}, False{}})))
def opt_collect_ip(small: Bool, +fns: List<&2, IrFn>, ret_sc: U32Map) -> IpRes:
  bad = opt_ip_bad_fns(fns, UM0{})
  fuel = Bool.pick(Nat, small, 16n, 2n)
  opt_ip_fix(fuel, bad, fns, IpRes{ret_sc, UM0{}, True{}})
def opt_collect_ret_only(fns: List<&2, IrFn>, m: U32Map) -> U32Map:
  match fns:
    case Nil{}: m
    case Con{IrFn{+fid, _, +ar, _, _, _, _, +blks}, t}:
      +m0 = m
      sc = opt_sc_compute(m0, UM0{}, fid, ar, blks)
      m1 = Bool.pick(U32Map, Bool.and(U32.is_ge(fid, 3), opt_sc_all_rets(fid, m0, sc, blks, False{})), um_set(m0, fid, 1), m0)
      opt_collect_ret_only(t, m1)
def opt_pass_scalar(+ret_sc: U32Map, +psc: U32Map, f: IrFn) -> IrFn:
  match f:
    case IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, +blks}:
      sc = opt_sc_compute(ret_sc, psc, fid, ar, blks)
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_sc_rewrite_blks(sc, blks)}
# Shared Polymorphic Bit-Trie (for SROA CtorMap & Local CSE)
type OptTrie<-A: Data> is Data:
  OT0{}
  OTL{val: A}
  OTN{lo: OptTrie<A>, hi: OptTrie<A>}
def ot_set_go(-A: Data, d: Nat, +k: U32, v: A, m: OptTrie<A>, is_lo: Bool) -> OptTrie<A>:
  match d m is_lo:
    case 0n _ _: OTL{v}
    case 1n+p OTN{lo, hi} True{}:
      +nx = U32.shr(k)
      OTN{ot_set_go(A, p, nx, v, lo, U32.is_zero(U32.and(nx, 1))), hi}
    case 1n+p OTN{lo, hi} False{}:
      +nx = U32.shr(k)
      OTN{lo, ot_set_go(A, p, nx, v, hi, U32.is_zero(U32.and(nx, 1)))}
    case 1n+p _ True{}:
      +nx = U32.shr(k)
      OTN{ot_set_go(A, p, nx, v, OT0{}, U32.is_zero(U32.and(nx, 1))), OT0{}}
    case 1n+p _ False{}:
      +nx = U32.shr(k)
      OTN{OT0{}, ot_set_go(A, p, nx, v, OT0{}, U32.is_zero(U32.and(nx, 1)))}
def ot_get_go(-A: Data, d: Nat, +k: U32, defv: A, m: OptTrie<A>, is_lo: Bool) -> A:
  match d m is_lo:
    case _ OT0{} _: defv
    case _ OTL{v} _: v
    case 0n OTN{_, _} _: defv
    case 1n+p OTN{lo, hi} True{}:
      +nx = U32.shr(k)
      ot_get_go(A, p, nx, defv, lo, U32.is_zero(U32.and(nx, 1)))
    case 1n+p OTN{lo, hi} False{}:
      +nx = U32.shr(k)
      ot_get_go(A, p, nx, defv, hi, U32.is_zero(U32.and(nx, 1)))
def ot_set(-A: Data, d: Nat, m: OptTrie<A>, +k: U32, v: A) -> OptTrie<A>:
  ot_set_go(A, d, k, v, m, U32.is_zero(U32.and(k, 1)))
def ot_get(-A: Data, d: Nat, defv: A, m: OptTrie<A>, +k: U32) -> A:
  ot_get_go(A, d, k, defv, m, U32.is_zero(U32.and(k, 1)))
# Pass A — Local Constructor-Take Fusion (SROA)
type CtorEnt is Data:
  CtorNone{}
  CtorSome{vreg: U32, fs: List<&2, U32>}
def sroa_tag_ops(ops: List<&2, IrOp>, cids: U32Map, acc: List<&2, IrOp>) -> List<&2, IrOp>:
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
def sroa_put_ctor(ok: Bool, cmap: OptTrie<CtorEnt>, +d: U32, fs: List<&2, U32>) -> OptTrie<CtorEnt>:
  match ok:
    case True{}: ot_set(CtorEnt, 12n, cmap, d, CtorSome{d, fs})
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
def sroa_fuse_ops(+defc: U32Map, +uses: U32Map, +ar: U32, ops: List<&2, IrOp>, cmap: OptTrie<CtorEnt>, st: SroaRes) -> SroaRes:
  match ops st:
    case Nil{} _: st
    case Con{ICtor{+d, cid, +fs}, t} SroaRes{acc, fused}:
      ok = Bool.and(U32.is_lt(d, 4096), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(U32.is_eq(um_get(uses, d), 1), opt_all_can_prop(defc, ar, fs))))
      sroa_fuse_ops(defc, uses, ar, t, sroa_put_ctor(ok, cmap, d, fs), SroaRes{Con{ICtor{d, cid, fs}, acc}, fused})
    case Con{ITake{ds, +s}, t} SroaRes{acc, fused}:
      +cm0 = cmap
      sroa_fuse_ops(defc, uses, ar, t, cm0, sroa_do_take(ot_get(CtorEnt, 12n, CtorNone{}, cm0, s), ds, s, fused, acc))
    case Con{ISink{+s}, t} SroaRes{acc, fused}:
      +cm0 = cmap
      sroa_fuse_ops(defc, uses, ar, t, cm0, sroa_do_sink(ot_get(CtorEnt, 12n, CtorNone{}, cm0, s), s, fused, acc))
    case Con{op, t} SroaRes{acc, fused}: sroa_fuse_ops(defc, uses, ar, t, cmap, SroaRes{Con{op, acc}, fused})
def sroa_blk_fin(id: U32, term: IrTerm, r: SroaRes) -> IrBlock:
  match r:
    case SroaRes{rev, fused}: IrBlock{id, sroa_drop_fused(fused, rev, Nil{}), term}
def sroa_fuse_blks(+defc: U32Map, +uses: U32Map, +ar: U32, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}:
      Con{sroa_blk_fin(id, term, sroa_fuse_ops(defc, uses, ar, ops, OT0{}, SroaRes{Nil{}, UM0{}})), sroa_fuse_blks(defc, uses, ar, t)}
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
          CfSt{opt_kill_op_dsts(op0, has), val, nr, Con{op0, rev}}
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
def cf_blks_step(id: U32, term: IrTerm, acc: List<&2, IrBlock>, st: CfSt) -> CfBlksRes:
  match st:
    case CfSt{has, val, nr1, rev}:
      CfBlksRes{Con{IrBlock{id, b5k_list_rev(IrOp, rev), cf_fold_term(has, val, term)}, acc}, nr1}
def cf_blks_go(blks: List<&2, IrBlock>, st: CfBlksRes) -> CfBlksRes:
  match blks st:
    case Nil{} CfBlksRes{acc, nr}: CfBlksRes{b5k_list_rev(IrBlock, acc), nr}
    case Con{IrBlock{id, ops, term}, t} CfBlksRes{acc, nr}:
      cf_blks_go(t, cf_blks_step(id, term, acc, cf_step_ops(ops, CfSt{UM0{}, UM0{}, nr, Nil{}})))
def cf_fn_fin(fid: U32, nm: String, ar: U32, esc: Bool, eff: Bool, is_m: Bool, r: CfBlksRes) -> IrFn:
  match r:
    case CfBlksRes{blks2, nr2}: IrFn{fid, nm, ar, nr2, esc, eff, is_m, blks2}
def opt_pass_cf(f: IrFn) -> IrFn:
  match f:
    case IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}:
      cf_fn_fin(fid, nm, ar, esc, eff, is_m, cf_blks_go(blks, CfBlksRes{Nil{}, nregs}))
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
    case other: other
# Direct-mapped 8-level (256-slot) CSE table
type CseEnt is Data:
  CseNone{}
  CseSome{k: U32, op: U32, a: U32, b: U32, dst: U32}
def cse_hash(+k: U32, +op: U32, +a: U32, +b: U32) -> U32:
  +h1 = U32.xor(U32.mul(a, 2654435761), U32.mul(b, 2246822519))
  U32.and(U32.xor(U32.shrn(h1, 16n), U32.xor(h1, U32.add(U32.shln(k, 4n), op))), 255)
def cse_match_ent(e: CseEnt, +k: U32, +op: U32, +a: U32, +b: U32) -> U32:
  match e:
    case CseNone{}: 0
    case CseSome{ek, eop, ea, eb, dst}:
      eq = Bool.and(U32.is_eq(ek, k), Bool.and(U32.is_eq(eop, op), Bool.and(U32.is_eq(ea, a), U32.is_eq(eb, b))))
      Bool.pick(U32, eq, U32.add(dst, 1), 0)
def cse_lookup(m: OptTrie<CseEnt>, +k: U32, +op: U32, +a: U32, +b: U32) -> U32:
  cse_match_ent(ot_get(CseEnt, 8n, CseNone{}, m, cse_hash(k, op, a, b)), k, op, a, b)
def cse_insert(m: OptTrie<CseEnt>, +k: U32, +op: U32, +a: U32, +b: U32, dst: U32) -> OptTrie<CseEnt>:
  ot_set(CseEnt, 8n, m, cse_hash(k, op, a, b), CseSome{k, op, a, b, dst})
def cse_maybe_ins(ok: Bool, m: OptTrie<CseEnt>, k: U32, op: U32, a: U32, b: U32, d: U32) -> OptTrie<CseEnt>:
  match ok:
    case True{}: cse_insert(m, k, op, a, b, d)
    case False{}: m
def cse_is_comm(+bop: U32) -> Bool:
  Bool.or(U32.is_eq(bop, 0), Bool.or(U32.is_eq(bop, 2), Bool.or(U32.is_eq(bop, 5), Bool.or(U32.is_eq(bop, 6), Bool.or(U32.is_eq(bop, 7), Bool.or(U32.is_eq(bop, 10), U32.is_eq(bop, 12)))))))
type CpOpsRes is Data:
  CpOpsRes{ops: List<&2, IrOp>, cm: U32Map}
type CpSt is Data:
  CpSt{cm: U32Map, csem: OptTrie<CseEnt>, acc: List<&2, IrOp>}
def opt_cp_cse_go(is_hit: Bool, +hit: U32, +defc: U32Map, +ar: U32, k: U32, op: U32, a: U32, b: U32, +d: U32, orig_op: IrOp, ok_ops: Bool, +cm: U32Map, csem: OptTrie<CseEnt>, +acc: List<&2, IrOp>) -> CpSt:
  match is_hit:
    case True{}:
      +rs = U32.sub(hit, 1)
      cm1 = Bool.pick(U32Map, Bool.and(U32.is_ne(d, rs), opt_cp_can_prop(defc, ar, rs)), um_set(cm, d, hit), um_set(cm, d, 0))
      acc1 = Bool.pick(List<&2, IrOp>, U32.is_eq(d, rs), acc, Con{ICopy{d, rs}, acc})
      CpSt{cm1, csem, acc1}
    case False{}:
      csem1 = cse_maybe_ins(Bool.and(ok_ops, opt_cp_can_prop(defc, ar, d)), csem, k, op, a, b, d)
      CpSt{um_set(cm, d, 0), csem1, Con{orig_op, acc}}
def opt_cp_cse_step(+defc: U32Map, +ar: U32, +k: U32, +op: U32, +a: U32, +b: U32, d: U32, orig_op: IrOp, ok_ops: Bool, cm: U32Map, +csem: OptTrie<CseEnt>, acc: List<&2, IrOp>) -> CpSt:
  +hit = cse_lookup(csem, k, op, a, b)
  opt_cp_cse_go(U32.is_ne(hit, 0), hit, defc, ar, k, op, a, b, d, orig_op, ok_ops, cm, csem, acc)
def opt_cp_ops(+defc: U32Map, +ar: U32, ops: List<&2, IrOp>, st: CpSt) -> CpOpsRes:
  match ops st:
    case Nil{} CpSt{cm, _, acc}: CpOpsRes{b5k_list_rev(IrOp, acc), cm}
    case Con{ICopy{+d, s}, t} CpSt{+cm0, csem, +acc}:
      +rs = opt_um_lookup_or(cm0, s)
      cm1 = Bool.pick(U32Map, Bool.and(U32.is_ne(d, rs), opt_cp_can_prop(defc, ar, rs)), um_set(cm0, d, U32.add(rs, 1)), um_set(cm0, d, 0))
      acc1 = Bool.pick(List<&2, IrOp>, U32.is_eq(d, rs), acc, Con{ICopy{d, rs}, acc})
      opt_cp_ops(defc, ar, t, CpSt{cm1, csem, acc1})
    case Con{IConst{+d, +v}, t} CpSt{cm, csem, acc}:
      opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 1, 0, v, 0, d, IConst{d, v}, True{}, cm, csem, acc))
    case Con{IFlt{+d, +bits}, t} CpSt{cm, csem, acc}:
      opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 2, 0, bits, 0, d, IFlt{d, bits}, True{}, cm, csem, acc))
    case Con{IUn{+d, +uop, s}, t} CpSt{+cm0, csem, acc}:
      +rs = opt_um_lookup_or(cm0, s)
      opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 3, uop, rs, 0, d, IUn{d, uop, rs}, opt_cp_can_prop(defc, ar, rs), cm0, csem, acc))
    case Con{IBin{+d, +bop, a, b}, t} CpSt{+cm0, csem, acc}:
      +ra = opt_um_lookup_or(cm0, a)
      +rb = opt_um_lookup_or(cm0, b)
      +comm = cse_is_comm(bop)
      ka = Bool.pick(U32, comm, U32.min(ra, rb), ra)
      kb = Bool.pick(U32, comm, U32.max(ra, rb), rb)
      ok = Bool.and(opt_cp_can_prop(defc, ar, ra), opt_cp_can_prop(defc, ar, rb))
      opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 4, bop, ka, kb, d, IBin{d, bop, ra, rb}, ok, cm0, csem, acc))
    case Con{ICmp{+d, +cop, a, b}, t} CpSt{+cm0, csem, acc}:
      +ra = opt_um_lookup_or(cm0, a)
      +rb = opt_um_lookup_or(cm0, b)
      +comm = U32.is_le(cop, 1)
      ka = Bool.pick(U32, comm, U32.min(ra, rb), ra)
      kb = Bool.pick(U32, comm, U32.max(ra, rb), rb)
      ok = Bool.and(opt_cp_can_prop(defc, ar, ra), opt_cp_can_prop(defc, ar, rb))
      opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 5, cop, ka, kb, d, ICmp{d, cop, ra, rb}, ok, cm0, csem, acc))
    case Con{ITag{+d, s}, t} CpSt{+cm0, csem, acc}:
      +rs = opt_um_lookup_or(cm0, s)
      opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 6, 0, rs, 0, d, ITag{d, rs}, opt_cp_can_prop(defc, ar, rs), cm0, csem, acc))
    case Con{op, t} CpSt{+cm0, csem, acc}:
      +op2 = opt_cp_rewrite_op(cm0, op)
      opt_cp_ops(defc, ar, t, CpSt{opt_kill_op_dsts(op2, cm0), csem, Con{op2, acc}})
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
      Con{opt_cp_blk_fin(id, term, opt_cp_ops(defc, ar, ops, CpSt{UM0{}, OT0{}, Nil{}})), opt_cp_blks(defc, ar, t)}
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
def opt_index_put(ok: Bool, +id: U32, ops: List<&2, IrOp>, term: IrTerm, m: OptTrie<Maybe<&2, IrBlock>>) -> OptTrie<Maybe<&2, IrBlock>>:
  match ok:
    case True{}: ot_set(Maybe<&2, IrBlock>, 10n, m, id, Some{IrBlock{id, ops, term}})
    case False{}: m
def opt_index_blks(blks: List<&2, IrBlock>, m: OptTrie<Maybe<&2, IrBlock>>) -> OptTrie<Maybe<&2, IrBlock>>:
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
def opt_merge_try_jmp(can: Bool, bmap: OptTrie<Maybe<&2, IrBlock>>, id: U32, ops: List<&2, IrOp>, +tgt: U32, sk0: U32Map, us0: U32Map, acc: List<&2, IrBlock>) -> MergeSt:
  match can:
    case False{}: MergeSt{sk0, us0, Con{IrBlock{id, ops, TJmp{tgt}}, acc}}
    case True{}: opt_merge_apply(ot_get(Maybe<&2, IrBlock>, 10n, None{}, bmap, tgt), id, ops, tgt, sk0, us0, acc)
def opt_merge_one(skipped: Bool, bmap: OptTrie<Maybe<&2, IrBlock>>, preds: U32Map, +id: U32, ops: List<&2, IrOp>, term: IrTerm, +sk0: U32Map, +us0: U32Map, acc: List<&2, IrBlock>) -> MergeSt:
  match skipped term:
    case True{} _: MergeSt{sk0, us0, acc}
    case False{} TJmp{+tgt}:
      can = Bool.and(U32.is_lt(tgt, 1024), Bool.and(U32.is_ne(tgt, id), Bool.and(U32.is_eq(um_get(preds, tgt), 1), Bool.and(U32.is_zero(um_get(sk0, tgt)), U32.is_zero(um_get(us0, tgt))))))
      opt_merge_try_jmp(can, bmap, id, ops, tgt, sk0, us0, acc)
    case False{} other: MergeSt{sk0, us0, Con{IrBlock{id, ops, other}, acc}}
def opt_merge_go(+bmap: OptTrie<Maybe<&2, IrBlock>>, +preds: U32Map, blks: List<&2, IrBlock>, st: MergeSt) -> List<&2, IrBlock>:
  match blks st:
    case Nil{} MergeSt{_, _, acc}: b5k_list_rev(IrBlock, acc)
    case Con{IrBlock{+id, ops, term}, t} MergeSt{+sk0, used, acc}:
      opt_merge_go(bmap, preds, t, opt_merge_one(U32.is_ne(um_get(sk0, id), 0), bmap, preds, id, ops, term, sk0, used, acc))
def opt_merge_once(+blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  preds = opt_count_preds(blks, um_set(UM0{}, 0, 2))
  bmap = opt_index_blks(blks, OT0{})
  opt_merge_go(bmap, preds, blks, MergeSt{UM0{}, UM0{}, Nil{}})
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
def opt_stc_blks(+self_fid: U32, +orig: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, TTailCall{+cfid, args}}, t}:
      Con{IrBlock{id, ops, opt_stc_term(U32.is_eq(cfid, self_fid), orig, cfid, args)}, opt_stc_blks(self_fid, orig, t)}
    case Con{b, t}: Con{b, opt_stc_blks(self_fid, orig, t)}
def opt_pass_cp_dce(do_merge: Bool, f: IrFn) -> IrFn:
  match do_merge f:
    case True{} IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, blks}:
      +b1 = opt_merge_once(opt_merge_once(opt_elim_unreach(blks)))
      +defc = opt_blks_defs(b1, UM0{})
      orig = opt_ip_orig_blks(defc, ar, b1, opt_ip_init_orig(U32.to_nat(ar), 0, UM0{}))
      b2 = opt_cp_blks(defc, ar, opt_stc_blks(fid, orig, b1))
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_dce_round(opt_dce_round(b2))}
    case False{} IrFn{fid, nm, +ar, nregs, esc, eff, is_m, blks}:
      +b1 = opt_elim_unreach(blks)
      b2 = opt_cp_blks(opt_blks_defs(b1, UM0{}), ar, b1)
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_dce_round(opt_dce_round(b2))}
# Pass C — Deeper Multi-Block Inlining (<= 32 ops, <= 4 blocks, 2 rounds)
type InlEntry is Data:
  InlEntry{fid: U32, arity: U32, nregs: U32, max_blk: U32, blks: List<&2, IrBlock>}
type InlBank is Data:
  InlBank{has: U32Map, trie: OptTrie<Maybe<&2, InlEntry>>}
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
def opt_blks_has_bad(+leaf: Bool, +fid: U32, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: False{}
    case Con{IrBlock{_, ops, TTailCall{cfid, _}}, t}:
      Bool.or(Bool.or(leaf, U32.is_eq(cfid, fid)), Bool.or(opt_ops_has_call(leaf, fid, ops), opt_blks_has_bad(leaf, fid, t)))
    case Con{IrBlock{_, ops, _}, t}:
      Bool.or(opt_ops_has_call(leaf, fid, ops), opt_blks_has_bad(leaf, fid, t))
def opt_collect_put(ok: Bool, +fid: U32, ar: U32, nregs: U32, +blks: List<&2, IrBlock>, has: U32Map, tr: OptTrie<Maybe<&2, InlEntry>>) -> InlBank:
  match ok:
    case False{}: InlBank{has, tr}
    case True{}: InlBank{um_set(has, fid, 1), ot_set(Maybe<&2, InlEntry>, 11n, tr, fid, Some{InlEntry{fid, ar, nregs, opt_blks_max_id(blks, 0), blks}})}
def opt_collect_one(elig: Bool, +leaf: Bool, +max_ops: U32, +max_blks: U32, +fid: U32, ar: U32, +nregs: U32, +blks: List<&2, IrBlock>, has: U32Map, tr: OptTrie<Maybe<&2, InlEntry>>) -> InlBank:
  match elig:
    case False{}: InlBank{has, tr}
    case True{}:
      +nb = b5k_list_len(IrBlock, blks)
      ok = Bool.and(U32.is_lt(fid, 2048), Bool.and(U32.is_le(nregs, 96), Bool.and(U32.is_ge(nb, 1), Bool.and(U32.is_le(nb, max_blks), Bool.and(U32.is_le(opt_blks_op_count(blks, 0), max_ops), Bool.not(opt_blks_has_bad(leaf, fid, blks)))))))
      opt_collect_put(ok, fid, ar, nregs, blks, has, tr)
def opt_collect_inlines(+leaf: Bool, +max_ops: U32, +max_blks: U32, fns: List<&2, IrFn>, bank: InlBank) -> InlBank:
  match fns bank:
    case Nil{} _: bank
    case Con{IrFn{+fid, _, ar, nregs, esc, eff, is_m, blks}, t} InlBank{has, tr}:
      elig = Bool.and(U32.is_ge(fid, 3), Bool.and(Bool.not(esc), Bool.and(Bool.not(eff), Bool.not(is_m))))
      opt_collect_inlines(leaf, max_ops, max_blks, t, opt_collect_one(elig, leaf, max_ops, max_blks, fid, ar, nregs, blks, has, tr))
def opt_find_inline(tr: OptTrie<Maybe<&2, InlEntry>>, +fid: U32) -> Maybe<&2, InlEntry>:
  ot_get(Maybe<&2, InlEntry>, 11n, None{}, tr, fid)
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
def opt_remap_one_blk(is_tail: Bool, +bv: U32, +bb: U32, +dst: U32, +cont: U32, blk: IrBlock) -> IrBlock:
  match is_tail blk:
    case True{} IrBlock{id, ops, TRet{rv}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TRet{U32.add(bv, rv)}}
    case True{} IrBlock{id, ops, TTailCall{cfid, args}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TTailCall{cfid, opt_shift_u32(bv, args)}}
    case False{} IrBlock{id, ops, TRet{rv}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, Con{ICopy{dst, U32.add(bv, rv)}, opt_inl_emit_body(bv, ops, Nil{})}), TJmp{cont}}
    case False{} IrBlock{id, ops, TTailCall{cfid, args}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, Con{ICallDirect{dst, cfid, opt_shift_u32(bv, args)}, opt_inl_emit_body(bv, ops, Nil{})}), TJmp{cont}}
    case _ IrBlock{id, ops, TJmp{tgt}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TJmp{U32.add(bb, tgt)}}
    case _ IrBlock{id, ops, TBr{c, tb, fb}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TBr{U32.add(bv, c), U32.add(bb, tb), U32.add(bb, fb)}}
    case _ IrBlock{id, ops, TSwitch{s, arms, db}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TSwitch{U32.add(bv, s), opt_shift_arms(bb, arms), U32.add(bb, db)}}
    case _ IrBlock{id, ops, TFail{c}}:
      IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TFail{c}}
def opt_remap_blks(+is_tail: Bool, +bv: U32, +bb: U32, +dst: U32, +cont: U32, blks: List<&2, IrBlock>, acc: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: acc
    case Con{b, t}: opt_remap_blks(is_tail, bv, bb, dst, cont, t, Con{opt_remap_one_blk(is_tail, bv, bb, dst, cont, b), acc})
type InlCur is Data:
  InlCur{cur_id: U32, ops_rev: List<&2, IrOp>, blks_rev: List<&2, IrBlock>, nr: U32, nb: U32, bud: U32}
def opt_inl_call_body(ok: Bool, +car: U32, +cnr: U32, +cmb: U32, cblks: List<&2, IrBlock>, +d: U32, +cfid: U32, +args: List<&2, U32>, +cid: U32, +orev: List<&2, IrOp>, +brev: List<&2, IrBlock>, +nr: U32, +nb: U32, +bud: U32) -> InlCur:
  match ok cblks:
    case False{} _: InlCur{cid, Con{ICallDirect{d, cfid, args}, orev}, brev, nr, nb, bud}
    case True{} Con{IrBlock{_, cops, TRet{+rv}}, Nil{}}:
      a1 = opt_inl_emit_args(args, nr, 0, orev)
      a2 = opt_inl_emit_body(nr, cops, a1)
      need = U32.max(cnr, U32.max(car, U32.add(rv, 1)))
      InlCur{cid, Con{ICopy{d, U32.add(nr, rv)}, a2}, brev, U32.add(nr, need), nb, U32.sub(bud, 1)}
    case True{} cblks0:
      need = U32.max(cnr, U32.max(car, 1))
      +cont = U32.add(nb, U32.add(cmb, 1))
      brev1 = opt_remap_blks(False{}, nr, nb, d, cont, cblks0, Con{IrBlock{cid, b5k_list_rev(IrOp, opt_inl_emit_args(args, nr, 0, orev)), TJmp{nb}}, brev})
      InlCur{cont, Nil{}, brev1, U32.add(nr, need), U32.add(cont, 1), U32.sub(bud, 1)}
def opt_inl_call_apply(me: Maybe<&2, InlEntry>, d: U32, cfid: U32, +args: List<&2, U32>, st: InlCur) -> InlCur:
  match me st:
    case None{} InlCur{cid, orev, brev, nr, nb, bud}:
      InlCur{cid, Con{ICallDirect{d, cfid, args}, orev}, brev, nr, nb, bud}
    case Some{InlEntry{_, +car, cnr, cmb, cblks}} InlCur{cid, orev, brev, nr, nb, bud}:
      opt_inl_call_body(U32.is_eq(b5k_u32_list_len(args), car), car, cnr, cmb, cblks, d, cfid, args, cid, orev, brev, nr, nb, bud)
def opt_inl_one_call(can: Bool, tr: OptTrie<Maybe<&2, InlEntry>>, d: U32, +cfid: U32, args: List<&2, U32>, st: InlCur) -> InlCur:
  match can st:
    case False{} InlCur{cid, orev, brev, nr, nb, bud}: InlCur{cid, Con{ICallDirect{d, cfid, args}, orev}, brev, nr, nb, bud}
    case True{} st0: opt_inl_call_apply(opt_find_inline(tr, cfid), d, cfid, args, st0)
def opt_inl_ops(+self_fid: U32, +has: U32Map, +tr: OptTrie<Maybe<&2, InlEntry>>, ops: List<&2, IrOp>, st: InlCur) -> InlCur:
  match ops st:
    case Nil{} _: st
    case Con{ICallDirect{d, +cfid, args}, t} InlCur{cid, orev, brev, +nr, +nb, +bud}:
      can = Bool.and(U32.is_ne(cfid, self_fid), Bool.and(U32.is_gt(bud, 0), Bool.and(U32.is_lt(nr, 1024), Bool.and(U32.is_lt(nb, 256), U32.is_ne(um_get(has, cfid), 0)))))
      opt_inl_ops(self_fid, has, tr, t, opt_inl_one_call(can, tr, d, cfid, args, InlCur{cid, orev, brev, nr, nb, bud}))
    case Con{op, t} InlCur{cid, orev, brev, nr, nb, bud}:
      opt_inl_ops(self_fid, has, tr, t, InlCur{cid, Con{op, orev}, brev, nr, nb, bud})
def opt_inl_tail_body(ok: Bool, +car: U32, +cnr: U32, +cmb: U32, cblks: List<&2, IrBlock>, cfid: U32, args: List<&2, U32>, +cid: U32, orev: List<&2, IrOp>, brev: List<&2, IrBlock>, +nr: U32, +nb: U32, bud: U32) -> InlCur:
  match ok:
    case False{}: InlCur{cid, Nil{}, Con{IrBlock{cid, b5k_list_rev(IrOp, orev), TTailCall{cfid, args}}, brev}, nr, nb, bud}
    case True{}:
      need = U32.max(cnr, U32.max(car, 1))
      brev1 = opt_remap_blks(True{}, nr, nb, 0, 0, cblks, Con{IrBlock{cid, b5k_list_rev(IrOp, opt_inl_emit_args(args, nr, 0, orev)), TJmp{nb}}, brev})
      InlCur{cid, Nil{}, brev1, U32.add(nr, need), U32.add(nb, U32.add(cmb, 1)), U32.sub(bud, 1)}
def opt_inl_tail_apply(me: Maybe<&2, InlEntry>, cfid: U32, +args: List<&2, U32>, st: InlCur) -> InlCur:
  match me st:
    case None{} InlCur{+cid, orev, brev, nr, nb, bud}:
      InlCur{cid, Nil{}, Con{IrBlock{cid, b5k_list_rev(IrOp, orev), TTailCall{cfid, args}}, brev}, nr, nb, bud}
    case Some{InlEntry{_, +car, cnr, cmb, cblks}} InlCur{cid, orev, brev, nr, nb, bud}:
      opt_inl_tail_body(U32.is_eq(b5k_u32_list_len(args), car), car, cnr, cmb, cblks, cfid, args, cid, orev, brev, nr, nb, bud)
def opt_inl_one_tail(can: Bool, tr: OptTrie<Maybe<&2, InlEntry>>, +cfid: U32, args: List<&2, U32>, st: InlCur) -> InlCur:
  match can st:
    case False{} InlCur{+cid, orev, brev, nr, nb, bud}:
      InlCur{cid, Nil{}, Con{IrBlock{cid, b5k_list_rev(IrOp, orev), TTailCall{cfid, args}}, brev}, nr, nb, bud}
    case True{} st0: opt_inl_tail_apply(opt_find_inline(tr, cfid), cfid, args, st0)
def opt_inl_fin_term(+self_fid: U32, +has: U32Map, +tr: OptTrie<Maybe<&2, InlEntry>>, term: IrTerm, st: InlCur) -> InlCur:
  match term st:
    case TTailCall{+cfid, args} InlCur{cid, orev, brev, +nr, +nb, +bud}:
      can = Bool.and(U32.is_ne(cfid, self_fid), Bool.and(U32.is_gt(bud, 0), Bool.and(U32.is_lt(nr, 1024), Bool.and(U32.is_lt(nb, 256), U32.is_ne(um_get(has, cfid), 0)))))
      opt_inl_one_tail(can, tr, cfid, args, InlCur{cid, orev, brev, nr, nb, bud})
    case other InlCur{+cid, orev, brev, nr, nb, bud}:
      InlCur{cid, Nil{}, Con{IrBlock{cid, b5k_list_rev(IrOp, orev), other}, brev}, nr, nb, bud}
type InlBlksRes is Data:
  InlBlksRes{blks: List<&2, IrBlock>, nregs: U32}
def opt_inl_blks(+self_fid: U32, +has: U32Map, +tr: OptTrie<Maybe<&2, InlEntry>>, blks: List<&2, IrBlock>, st: InlCur) -> InlBlksRes:
  match blks st:
    case Nil{} InlCur{_, _, brev, nr, _, _}: InlBlksRes{b5k_list_rev(IrBlock, brev), nr}
    case Con{IrBlock{id, ops, term}, t} InlCur{_, _, brev, nr, nb, bud}:
      st1 = opt_inl_ops(self_fid, has, tr, ops, InlCur{id, Nil{}, brev, nr, nb, bud})
      opt_inl_blks(self_fid, has, tr, t, opt_inl_fin_term(self_fid, has, tr, term, st1))
def opt_inl_fn_fin(fid: U32, nm: String, ar: U32, esc: Bool, eff: Bool, is_m: Bool, r: InlBlksRes) -> IrFn:
  match r:
    case InlBlksRes{blks2, nr2}: IrFn{fid, nm, ar, nr2, esc, eff, is_m, blks2}
def opt_inl_fn(+bud0: U32, bank: InlBank, f: IrFn) -> IrFn:
  match bank f:
    case InlBank{has, tr} IrFn{+fid, nm, ar, nregs, esc, eff, is_m, +blks}:
      nb0 = U32.add(opt_blks_max_id(blks, 0), 1)
      opt_inl_fn_fin(fid, nm, ar, esc, eff, is_m, opt_inl_blks(fid, has, tr, blks, InlCur{0, Nil{}, Nil{}, nregs, nb0, bud0}))
def opt_inl_all(+bud0: U32, +bank: InlBank, fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_inl_fn(bud0, bank, f), opt_inl_all(bud0, bank, t)}
# Top-Level -O2 Pipeline
def opt_fn_local(+small: Bool, +ret_sc: U32Map, +psc: U32Map, f: IrFn) -> IrFn:
  match small:
    case True{}: opt_pass_cp_dce(False{}, opt_pass_sroa_fuse(opt_pass_sroa_tag(opt_pass_cp_dce(True{}, opt_pass_cf(opt_pass_sroa_tag(opt_pass_scalar(ret_sc, psc, f)))))))
    case False{}: opt_pass_cp_dce(False{}, opt_pass_cf(opt_pass_scalar(ret_sc, psc, f)))
def opt_fns_local(+small: Bool, +ret_sc: U32Map, +psc: U32Map, fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_fn_local(small, ret_sc, psc, f), opt_fns_local(small, ret_sc, psc, t)}
def opt_fns_pre(do_cp: Bool, +ret_sc: U32Map, fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match do_cp fns:
    case _ Nil{}: Nil{}
    case True{} Con{f, t}: Con{opt_pass_cp_dce(True{}, opt_pass_cf(opt_pass_scalar(ret_sc, UM0{}, f))), opt_fns_pre(True{}, ret_sc, t)}
    case False{} Con{f, t}: Con{opt_pass_cf(opt_pass_scalar(ret_sc, UM0{}, f)), opt_fns_pre(False{}, ret_sc, t)}
def opt_fns_mid(fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fns:
    case Nil{}: Nil{}
    case Con{f, t}: Con{opt_pass_cp_dce(True{}, opt_pass_sroa_fuse(opt_pass_cf(opt_pass_sroa_tag(f)))), opt_fns_mid(t)}
def b5k_opt_fin(+small: Bool, fns3: List<&2, IrFn>, ip1: IpRes) -> List<&2, IrFn>:
  match ip1:
    case IpRes{ret1, psc1, _}: opt_fns_local(small, ret1, psc1, fns3)
def b5k_opt_go(small: Bool, +fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match small:
    case True{}:
      +ret0 = opt_collect_ret_only(fns, UM0{})
      +fns1 = opt_fns_pre(True{}, ret0, fns)
      +fns2 = opt_fns_mid(opt_inl_all(24, opt_collect_inlines(False{}, 48, 6, fns1, InlBank{UM0{}, OT0{}}), fns1))
      +fns3 = opt_inl_all(24, opt_collect_inlines(False{}, 48, 6, fns2, InlBank{UM0{}, OT0{}}), fns2)
      b5k_opt_fin(True{}, fns3, opt_collect_ip(True{}, fns3, ret0))
    case False{}:
      +ret0 = opt_collect_ret_only(fns, UM0{})
      +fns2 = opt_inl_all(16, opt_collect_inlines(True{}, 12, 1, fns, InlBank{UM0{}, OT0{}}), fns)
      b5k_opt_fin(False{}, fns2, opt_collect_ip(False{}, fns2, ret0))
def b5k_opt(prog: IrProg) -> IrProg:
  match prog:
    case IrProg{+fns, ctors, statics, main_fid, main_pure, effects, show_desc, show_names}:
      small = U32.is_le(b5k_list_len(IrFn, fns), 384)
      IrProg{b5k_opt_go(small, fns), ctors, statics, main_fid, main_pure, effects, show_desc, show_names}
