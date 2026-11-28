# bend5k/opt.bend — Aggressive -O2 IR Optimizer (IrProg -> IrProg)
# Core Combinators, Register/Op/Block/Fn Engines & Shared CFG Helpers
def opt_if(-A: Data, c: Bool, t: U32 -> A, f: U32 -> A) -> A: low_if(A, c, t, f)
def opt_maybe(-A: Data, -B: Data, m: Maybe<&2, A>, d: U32 -> B, f: A -> B) -> B:
  match m:
    case None{}: d(0)
    case Some{v}: f(v)
def opt_un_pair(-A: Type, -B: Type, -R: Type, p: A & B, k: A -> B -> R) -> R:
  (a, b) = p
  k(a, b)
def opt_un_blk(-R: Type, b: IrBlock, k: U32 -> List<&2, IrOp> -> IrTerm -> R) -> R:
  IrBlock{id, ops, term} = b
  k(id, ops, term)
def opt_un_arm(-R: Type, a: IrSwitchArm, k: U32 -> U32 -> R) -> R:
  IrArm{tag, tgt} = a
  k(tag, tgt)
def opt_un_fn(-R: Type, f: IrFn, k: U32 -> String -> U32 -> U32 -> Bool -> Bool -> Bool -> List<&2, IrBlock> -> R) -> R:
  IrFn{fid, nm, ar, nr, esc, eff, is_m, blks} = f
  k(fid, nm, ar, nr, esc, eff, is_m, blks)
def opt_fold_blks0(~S: Data, ~f: U32 -> List<&2, IrOp> -> IrTerm -> S -> S, blks: List<&2, IrBlock>, +st: S) -> S:
  match blks:
    case Nil{}: st
    case Con{IrBlock{+id, +ops, +term}, t}: opt_fold_blks0(~S, ~f, t, f(id, ops, term, st))
def opt_fold_blks(~E: Data, ~S: Data, ~f: E -> U32 -> List<&2, IrOp> -> IrTerm -> S -> S, +e: E, blks: List<&2, IrBlock>, +st: S) -> S:
  match blks:
    case Nil{}: st
    case Con{IrBlock{+id, +ops, +term}, t}: opt_fold_blks(~E, ~S, ~f, e, t, f(e, id, ops, term, st))
def opt_all_blks(~E: Data, ~p: E -> U32 -> List<&2, IrOp> -> IrTerm -> Bool, +e: E, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: True{}
    case Con{IrBlock{+id, +ops, +term}, t}: Bool.and(p(e, id, ops, term), opt_all_blks(~E, ~p, e, t))
def opt_term_tc_fid(term: IrTerm) -> U32:
  match term:
    case TTailCall{cfid, _}: U32.add(cfid, 1)
    case _: 0
def opt_term_tag(term: IrTerm) -> U32:
  match term:
    case TJmp{_}: 1
    case TRet{_}: 2
    case TTailCall{_, _}: 3
    case TFail{_}: 5
    case _: 4
def opt_um_inc(+m: U32Map, +k: U32) -> U32Map: um_set(m, k, U32.add(um_get(m, k), 1))
def opt_um_lookup_or(+m: U32Map, +v: U32) -> U32: (+got = um_get(m, v); Bool.pick(U32, U32.is_zero(got), v, U32.sub(got, 1)))
def opt_rv_get(-A: Data, +defv: A, +id: U32, m: RaVec<A>) -> A: Bool.pick(A, U32.is_lt(id, 1024), ra_vec_get(A, 5n, defv, id, m), defv)
def opt_rv_put(-A: Data, ok: Bool, d: Nat, +id: U32, v: A, m: RaVec<A>) -> RaVec<A>:
  match ok:
    case True{}: ra_vec_set(A, d, id, v, m)
    case False{}: m
def opt_blk_get(+bmap: RaVec<Maybe<&2, IrBlock>>, +id: U32) -> Maybe<&2, IrBlock>: opt_rv_get(Maybe<&2, IrBlock>, None{}, id, bmap)
def opt_is_sp(+preds: U32Map, +id: U32, +tgt: U32) -> Bool: Bool.and(U32.is_lt(tgt, 1024), Bool.and(U32.is_ne(tgt, id), U32.is_eq(um_get(preds, tgt), 1)))
def opt_is_diam(+preds: U32Map, +id: U32, +tb: U32, +fb: U32) -> Bool: Bool.and(U32.is_ne(tb, fb), Bool.and(opt_is_sp(preds, id, tb), opt_is_sp(preds, id, fb)))
type RegAct is Data:
  RAInc{}
  RADec{}
  RASet{v: U32}
  RABad{al: U32Map}
  RAHas{al: U32Map}
def opt_ra_v(act: RegAct, +v: U32, +m: U32Map) -> U32Map:
  match act:
    case RAInc{}: opt_um_inc(m, v)
    case RADec{}: (+c = um_get(m, v); Bool.pick(U32Map, U32.is_zero(c), m, um_set(m, v, U32.sub(c, 1))))
    case RASet{val}: um_set(m, v, val)
    case RABad{al}: (+a = um_get(al, v); Bool.pick(U32Map, U32.is_ne(a, 0), um_set(m, U32.sub(a, 1), 1), m))
    case RAHas{al}: Bool.pick(U32Map, U32.is_ne(um_get(al, v), 0), um_set(m, 0, 1), m)
def opt_ra_vs(+act: RegAct, xs: List<&2, U32>, m: U32Map) -> U32Map: opt_foldl(~U32, ~RegAct, ~U32Map, ~(e => v => acc => opt_ra_v(e, v, acc)), act, xs, m)
def opt_um_inc_list(xs: List<&2, U32>, m: U32Map) -> U32Map: opt_ra_vs(RAInc{}, xs, m)
def opt_um_set_list(xs: List<&2, U32>, val: U32, m: U32Map) -> U32Map: opt_ra_vs(RASet{val}, xs, m)
type RegMap is Data:
  RMLookup{m: U32Map}
  RMShift{base: U32}
  RMBump{ar: U32, d: U32}
  RMZero{jl: U32}
def opt_rm_v(rm: RegMap, +v: U32) -> U32:
  match rm:
    case RMLookup{m}: opt_um_lookup_or(m, v)
    case RMShift{b}: U32.add(b, v)
    case RMBump{ar, d}: Bool.pick(U32, U32.is_ge(v, ar), U32.add(v, d), v)
    case RMZero{jl}: Bool.pick(U32, U32.is_zero(v), jl, v)
def opt_rm_vs(+rm: RegMap, xs: List<&2, U32>) -> List<&2, U32>: opt_mapl(~U32, ~RegMap, ~U32, ~(e => v => opt_rm_v(e, v)), rm, xs)
def opt_map_u32(m: U32Map, xs: List<&2, U32>) -> List<&2, U32>: opt_rm_vs(RMLookup{m}, xs)
def opt_shift_u32(base: U32, xs: List<&2, U32>) -> List<&2, U32>: opt_rm_vs(RMShift{base}, xs)
def opt_rm_d(rw: Bool, rm: RegMap, +d: U32) -> U32: Bool.pick(U32, rw, opt_rm_v(rm, d), d)
def opt_rm_ds(rw: Bool, rm: RegMap, +ds: List<&2, U32>) -> List<&2, U32>: Bool.pick(List<&2, U32>, rw, opt_rm_vs(rm, ds), ds)
def opt_rm_op(+rw: Bool, +rm: RegMap, op: IrOp) -> IrOp:
  match op:
    case IConst{d, v}: IConst{opt_rm_d(rw, rm, d), v}
    case IFlt{d, b}: IFlt{opt_rm_d(rw, rm, d), b}
    case ICopy{d, s}: ICopy{opt_rm_d(rw, rm, d), opt_rm_v(rm, s)}
    case IBin{d, bop, a, b}: IBin{opt_rm_d(rw, rm, d), bop, opt_rm_v(rm, a), opt_rm_v(rm, b)}
    case IUn{d, uop, s}: IUn{opt_rm_d(rw, rm, d), uop, opt_rm_v(rm, s)}
    case ICmp{d, cop, a, b}: ICmp{opt_rm_d(rw, rm, d), cop, opt_rm_v(rm, a), opt_rm_v(rm, b)}
    case ICallDirect{d, fid, args}: ICallDirect{opt_rm_d(rw, rm, d), fid, opt_rm_vs(rm, args)}
    case ICallClosure{d, fid, caps}: ICallClosure{opt_rm_d(rw, rm, d), fid, opt_rm_vs(rm, caps)}
    case IApply{d, c, a}: IApply{opt_rm_d(rw, rm, d), opt_rm_v(rm, c), opt_rm_v(rm, a)}
    case ICtor{d, cid, fs}: ICtor{opt_rm_d(rw, rm, d), cid, opt_rm_vs(rm, fs)}
    case ITake{ds, s}: ITake{opt_rm_ds(rw, rm, ds), opt_rm_v(rm, s)}
    case ITag{d, s}: ITag{opt_rm_d(rw, rm, d), opt_rm_v(rm, s)}
    case IKeep{d, s}: IKeep{opt_rm_d(rw, rm, d), opt_rm_v(rm, s)}
    case ISink{s}: ISink{opt_rm_v(rm, s)}
    case IReuse{d, sl, cid, fs}: IReuse{opt_rm_d(rw, rm, d), opt_rm_v(rm, sl), cid, opt_rm_vs(rm, fs)}
    case IStatic{d, idx}: IStatic{opt_rm_d(rw, rm, d), idx}
    case IArrOp{ds, aop, args}: IArrOp{opt_rm_ds(rw, rm, ds), aop, opt_rm_vs(rm, args)}
    case IAlloca{d, w}: IAlloca{opt_rm_d(rw, rm, d), w}
    case ILoad{d, b, off}: ILoad{opt_rm_d(rw, rm, d), opt_rm_v(rm, b), off}
    case IStore{b, off, v}: IStore{opt_rm_v(rm, b), off, opt_rm_v(rm, v)}
    case IMutField{o, idx, v}: IMutField{opt_rm_v(rm, o), idx, opt_rm_v(rm, v)}
    case ILut{d, iv, dv, vs}: ILut{opt_rm_d(rw, rm, d), opt_rm_v(rm, iv), dv, vs}
    case IFail{c}: IFail{c}
def opt_op_dst1(op: IrOp) -> U32:
  match op:
    case IConst{d, _}: U32.add(d, 1)
    case IFlt{d, _}: U32.add(d, 1)
    case ICopy{d, _}: U32.add(d, 1)
    case IBin{d, _, _, _}: U32.add(d, 1)
    case IUn{d, _, _}: U32.add(d, 1)
    case ICmp{d, _, _, _}: U32.add(d, 1)
    case ICallDirect{d, _, _}: U32.add(d, 1)
    case ICallClosure{d, _, _}: U32.add(d, 1)
    case IApply{d, _, _}: U32.add(d, 1)
    case ICtor{d, _, _}: U32.add(d, 1)
    case ITag{d, _}: U32.add(d, 1)
    case IKeep{d, _}: U32.add(d, 1)
    case IReuse{d, _, _, _}: U32.add(d, 1)
    case IStatic{d, _}: U32.add(d, 1)
    case IAlloca{d, _}: U32.add(d, 1)
    case ILoad{d, _, _}: U32.add(d, 1)
    case ILut{d, _, _, _}: U32.add(d, 1)
    case _: 0
def opt_op_dsts(op: IrOp) -> List<&2, U32>:
  match op:
    case ITake{ds, _}: ds
    case IArrOp{ds, _, _}: ds
    case o: (+d1 = opt_op_dst1(o); Bool.pick(List<&2, U32>, U32.is_zero(d1), Nil{}, Con{U32.sub(d1, 1), Nil{}}))
def opt_op_uses_list(op: IrOp) -> List<&2, U32>:
  match op:
    case ICopy{_, s}: [s]
    case IBin{_, _, l, r}: [l, r]
    case IUn{_, _, s}: [s]
    case ICmp{_, _, l, r}: [l, r]
    case ICallDirect{_, _, args}: args
    case ICallClosure{_, _, caps}: caps
    case IApply{_, c, a}: [c, a]
    case ICtor{_, _, fs}: fs
    case ITake{_, s}: [s]
    case ITag{_, s}: [s]
    case IKeep{_, s}: [s]
    case ISink{s}: [s]
    case IReuse{_, sl, _, fs}: Con{sl, fs}
    case IArrOp{_, _, args}: args
    case ILoad{_, b, _}: [b]
    case IStore{b, _, v}: [b, v]
    case IMutField{o, _, v}: [o, v]
    case ILut{_, iv, _, _}: [iv]
    case _: Nil{}
def opt_term_uses_list(term: IrTerm) -> List<&2, U32>:
  match term:
    case TBr{c, _, _}: [c]
    case TSwitch{s, _, _}: [s]
    case TRet{v}: [v]
    case TTailCall{_, args}: args
    case _: Nil{}
def opt_op_defs_act(+act: RegAct, op: IrOp, +m: U32Map) -> U32Map:
  match op:
    case IKeep{+d, +s}: Bool.pick(U32Map, U32.is_eq(d, s), m, opt_ra_v(act, d, m))
    case o: opt_ra_vs(act, opt_op_dsts(o), m)
def opt_op_defs(op: IrOp, m: U32Map) -> U32Map: opt_op_defs_act(RAInc{}, op, m)
def opt_kill_op_dsts(op: IrOp, m: U32Map) -> U32Map: opt_op_defs_act(RASet{0}, op, m)
def opt_op_uses_act(+act: RegAct, op: IrOp, m: U32Map) -> U32Map: opt_ra_vs(act, opt_op_uses_list(op), m)
def opt_op_uses(op: IrOp, m: U32Map) -> U32Map: opt_op_uses_act(RAInc{}, op, m)
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
    case ILut{d, _, _, _}: U32.add(d, 1)
    case _: 0
def opt_cp_can_prop(+defc: U32Map, +ar: U32, +r: U32) -> Bool: (+dc = um_get(defc, r); Bool.pick(Bool, U32.is_lt(r, ar), U32.is_zero(dc), U32.is_le(dc, 1)))
def opt_all_can_prop(+defc: U32Map, +ar: U32, xs: List<&2, U32>) -> Bool: opt_alll2(~U32, ~U32Map, ~U32, ~(d => a => r => opt_cp_can_prop(d, a, r)), defc, ar, xs)
def opt_is_nil_ops(xs: List<&2, IrOp>) -> Bool:
  match xs:
    case Nil{}: True{}
    case _: False{}
def opt_is_su_ctor(+defc: U32Map, +uses: U32Map, +ar: U32, +d: U32, fs: List<&2, U32>) -> Bool: Bool.and(U32.is_lt(d, 4096), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(U32.is_eq(um_get(uses, d), 1), opt_all_can_prop(defc, ar, fs))))
def opt_sa_chk_op(+a0: U32, +al: U32Map, +sc: U32Map, +op: IrOp) -> Bool:
  match op:
    case IArrOp{Con{+d, Nil{}}, 71, Con{vc, Con{vv, Nil{}}}}: Bool.and(U32.is_zero(um_get(al, vc)), Bool.and(U32.is_zero(um_get(al, vv)), Bool.or(U32.is_eq(d, a0), U32.is_zero(um_get(al, d)))))
    case IArrOp{Con{+da, Con{+dv, Nil{}}}, 72, Con{+a, Con{+i, Nil{}}}}: Bool.and(U32.is_zero(um_get(al, i)), Bool.and(U32.is_zero(um_get(al, dv)), U32.is_eq(um_get(al, da), um_get(al, a))))
    case IArrOp{Con{+dv, Nil{}}, 78, Con{_, Con{+i, Nil{}}}}: Bool.and(U32.is_zero(um_get(al, i)), U32.is_zero(um_get(al, dv)))
    case IArrOp{Con{+da, Nil{}}, +aop, Con{+a, Con{+i, Con{+v, Nil{}}}}}: Bool.and(U32.is_zero(um_get(al, i)), Bool.and(U32.is_zero(um_get(al, v)), Bool.and(U32.is_eq(um_get(al, da), um_get(al, a)), Bool.or(U32.is_zero(um_get(al, a)), Bool.and(Bool.or(U32.is_eq(aop, 73), U32.is_eq(aop, 79)), U32.is_eq(um_get(sc, v), 1))))))
    case IArrOp{Con{+da, Con{+dold, Nil{}}}, 74, Con{+a, Con{+i, Con{+v, Nil{}}}}}: Bool.and(U32.is_zero(um_get(al, i)), Bool.and(U32.is_zero(um_get(al, v)), Bool.and(U32.is_zero(um_get(al, dold)), Bool.and(U32.is_eq(um_get(al, da), um_get(al, a)), Bool.or(U32.is_zero(um_get(al, a)), U32.is_eq(um_get(sc, v), 1))))))
    case ICopy{d, s}: U32.is_eq(um_get(al, d), um_get(al, s))
    case ISink{_}: True{}
    case +other: U32.is_zero(um_get(opt_op_defs_act(RAHas{al}, other, opt_op_uses_act(RAHas{al}, other, UM0{})), 0))
# Unified OpPred, OpFold, BlkMap & FnMap Engines
type OpPred is Data:
  OPNoCall{leaf: Bool, fid: U32}
  OPPureStc{allow_arr: Bool}
  OPEscPure{}
  OPAbsPure{}
  OPNoCtor{}
  OPNoArr{}
  OPNoArrOp{}
  OPNoAlloca{}
  OPSaNoBin{rds: U32Map}
  OPSaChk{a0: U32, al: U32Map, sc: U32Map}
  OPNoSelf{fid: U32}
  OPMsEdge{ex: U32Map}
def opt_op_pred(p: OpPred, op: IrOp) -> Bool:
  match p op:
    case OPNoCall{leaf, fid} ICallDirect{_, cfid, _}: Bool.and(Bool.not(leaf), U32.is_ne(cfid, fid))
    case OPNoCall{leaf, _} ICallClosure{_, _, _}: Bool.not(leaf)
    case OPNoCall{leaf, _} IApply{_, _, _}: Bool.not(leaf)
    case OPPureStc{_} ICallDirect{_, _, _}: False{}
    case OPPureStc{_} ICallClosure{_, _, _}: False{}
    case OPPureStc{_} IApply{_, _, _}: False{}
    case OPPureStc{allow_arr} IArrOp{_, _, _}: allow_arr
    case OPPureStc{allow_arr} ICtor{_, _, _}: allow_arr
    case OPPureStc{_} ITake{_, _}: False{}
    case OPPureStc{_} IReuse{_, _, _, _}: False{}
    case OPEscPure{} IConst{_, _}: True{}
    case OPEscPure{} ICopy{_, _}: True{}
    case OPEscPure{} IBin{_, _, _, _}: True{}
    case OPEscPure{} IUn{_, _, _}: True{}
    case OPEscPure{} ICmp{_, _, _, _}: True{}
    case OPEscPure{} ILut{_, _, _, _}: True{}
    case OPEscPure{} _: False{}
    case OPAbsPure{} _: U32.is_ne(opt_op_pure_dst(op), 0)
    case OPNoCtor{} ICtor{_, _, _}: False{}
    case OPNoArr{} IArrOp{_, aop, _}: U32.is_ge(aop, 1000)
    case OPNoArr{} ICallDirect{_, _, _}: False{}
    case OPNoArr{} ICallClosure{_, _, _}: False{}
    case OPNoArr{} IApply{_, _, _}: False{}
    case OPNoArrOp{} IArrOp{_, _, _}: False{}
    case OPNoAlloca{} IAlloca{_, _}: False{}
    case OPSaNoBin{+rds} IBin{_, _, l, r}: Bool.and(U32.is_zero(um_get(rds, l)), U32.is_zero(um_get(rds, r)))
    case OPSaChk{a0, al, sc} _: opt_sa_chk_op(a0, al, sc, op)
    case OPNoSelf{fid} ICallDirect{_, cfid, _}: U32.is_ne(cfid, fid)
    case OPMsEdge{+ex} ICopy{d, s}: U32.is_eq(Bool.to_u32(U32.is_ne(um_get(ex, d), 0)), Bool.to_u32(U32.is_ne(um_get(ex, s), 0)))
    case _ _: True{}
def opt_all_ops(+p: OpPred, ops: List<&2, IrOp>) -> Bool: opt_alll(~IrOp, ~OpPred, ~(e => op => opt_op_pred(e, op)), p, ops)
def opt_all_blks_ops(+p: OpPred, blks: List<&2, IrBlock>) -> Bool: opt_alll(~IrBlock, ~OpPred, ~(e => b => opt_un_blk(Bool, b, _ => ops => _ => opt_all_ops(e, ops))), p, blks)
type OpFold is Data:
  OFDefs{}
  OFUses{}
  OFScDirect{ret_sc: U32Map}
  OFScAdd{defc: U32Map, ar: U32}
  OFScProp{poison: Bool}
  OFIpOrig{defc: U32Map, ar: U32}
  OFIpBad{}
  OFIpObs{sfid: U32, sc: U32Map, orig: U32Map}
  OFKeep{}
  OFGcCp{defc: U32Map, km: U32Map, ar: U32}
  OFCc{}
  OFB01{defc: U32Map, ar: U32}
  OFIdTag{defc: U32Map, ar: U32}
  OFRuKsrc{}
  OFMsChk{arm: U32Map, cidm: U32Map, htag: U32Map}
  OFConsts{}
  OFAbsZctors{}
  OFSaConst{}
  OFSaRds{al: U32Map}
  OFSaProp{}
def opt_sc_mark_scalar(+m: U32Map, +d: U32) -> U32Map: Bool.pick(U32Map, U32.is_zero(um_get(m, d)), um_set(m, d, 1), m)
def opt_sc_direct_op(+ret_sc: U32Map, op: IrOp, +m: U32Map) -> U32Map:
  match op:
    case IConst{d, _}: opt_sc_mark_scalar(m, d)
    case IFlt{d, _}: opt_sc_mark_scalar(m, d)
    case IBin{d, _, _, _}: opt_sc_mark_scalar(m, d)
    case IUn{d, _, _}: opt_sc_mark_scalar(m, d)
    case ICmp{d, _, _, _}: opt_sc_mark_scalar(m, d)
    case ITag{d, _}: opt_sc_mark_scalar(m, d)
    case ILut{d, _, _, _}: opt_sc_mark_scalar(m, d)
    case ICallDirect{+d, fid, _}: Bool.pick(U32Map, U32.is_ne(um_get(ret_sc, fid), 0), opt_sc_mark_scalar(m, d), um_set(m, d, 2))
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
def opt_sc_prop_copy(poison: Bool, +d: U32, s: U32, +m: U32Map) -> U32Map:
  match poison:
    case False{}: Bool.pick(U32Map, Bool.and(U32.is_zero(um_get(m, d)), U32.is_eq(um_get(m, s), 1)), um_set(m, d, 1), m)
    case True{}: Bool.pick(U32Map, U32.is_ne(um_get(m, s), 1), um_set(m, d, 2), m)
def opt_sc_add_op(+defc: U32Map, +ar: U32, op: IrOp, +m: U32Map) -> U32Map:
  match op:
    case IBin{_, 0, +a, +b}: (+ma = um_get(m, a); +mb = um_get(m, b); +m1 = Bool.pick(U32Map, Bool.and(U32.is_eq(mb, 1), Bool.and(U32.is_ne(ma, 1), opt_cp_can_prop(defc, ar, a))), um_set(m, a, 1), m); Bool.pick(U32Map, Bool.and(U32.is_eq(ma, 1), Bool.and(U32.is_ne(mb, 1), opt_cp_can_prop(defc, ar, b))), um_set(m1, b, 1), m1))
    case IBin{_, +bop, +a, +b}: Bool.pick(U32Map, Bool.or(Bool.and(U32.is_ge(bop, 1), U32.is_le(bop, 9)), Bool.or(U32.is_eq(bop, 15), U32.is_eq(bop, 16))), um_set(um_set(m, a, 1), b, 1), m)
    case IUn{_, +uop, +s}: Bool.pick(U32Map, U32.is_le(uop, 1), um_set(m, s, 1), m)
    case ICmp{_, +cop, +a, +b}: Bool.pick(U32Map, Bool.and(U32.is_ge(cop, 2), Bool.and(U32.is_le(cop, 5), Bool.and(U32.is_ne(um_get(m, a), 3), U32.is_ne(um_get(m, b), 3)))), um_set(um_set(m, a, 1), b, 1), m)
    case ICopy{d, +s}: Bool.pick(U32Map, Bool.and(U32.is_eq(um_get(m, d), 1), U32.is_ne(um_get(m, s), 3)), um_set(m, s, 1), m)
    case IKeep{d, +s}: Bool.pick(U32Map, Bool.and(U32.is_eq(um_get(m, d), 1), U32.is_ne(um_get(m, s), 3)), um_set(m, s, 1), m)
    case _: m
def opt_ip_orig_step(+defc: U32Map, +ar: U32, +d: U32, s: U32, +m0: U32Map) -> U32Map: (+os = um_get(m0, s); Bool.pick(U32Map, Bool.and(U32.is_ne(os, 0), Bool.and(U32.is_ge(d, ar), U32.is_eq(um_get(defc, d), 1))), um_set(m0, d, os), m0))
def opt_map_ops_rm(+rw: Bool, +rm: RegMap, ops: List<&2, IrOp>) -> List<&2, IrOp>: opt_mapl2(~IrOp, ~Bool, ~RegMap, ~IrOp, ~(w => r => op => opt_rm_op(w, r, op)), rw, rm, ops)
# Pass 1 & Pass B — Interprocedural Scalar Inference & IKeep/ISink Elision
def opt_pkey(+fid: U32, +idx: U32) -> U32: U32.or(U32.shln(fid, 6n), idx)
def opt_sc_init_params(+fid: U32, +psc: U32Map, n: Nat, +idx: U32, m: U32Map) -> U32Map:
  match n:
    case 0n: m
    case 1n+p: (ok = Bool.and(U32.is_lt(fid, 2048), Bool.and(U32.is_lt(idx, 64), U32.is_eq(um_get(psc, opt_pkey(fid, idx)), 1))); opt_sc_init_params(fid, psc, p, U32.add(idx, 1), um_set(m, idx, Bool.pick(U32, ok, 1, 2))))
def opt_sc_rewrite_ops(+sm: Bool, +sc: U32Map, ops: List<&2, IrOp>, +cm: U32Map, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: b5k_list_rev(IrOp, acc)
    case Con{IKeep{+d, +s}, t}: (acc1 = Bool.pick(List<&2, IrOp>, U32.is_eq(um_get(sc, s), 1), Bool.pick(List<&2, IrOp>, U32.is_eq(d, s), acc, Con{ICopy{d, s}, acc}), Con{IKeep{d, s}, acc}); opt_sc_rewrite_ops(sm, sc, t, Bool.pick(U32Map, sm, um_set(cm, d, 0), cm), acc1))
    case Con{ISink{+s}, t}: opt_sc_rewrite_ops(sm, sc, t, cm, Bool.pick(List<&2, IrOp>, U32.is_eq(um_get(sc, s), 1), acc, Con{ISink{s}, acc}))
    case Con{ITag{+d, +s}, t}: opt_sc_rewrite_ops(sm, sc, t, Bool.pick(U32Map, sm, um_set(cm, d, 0), cm), Con{Bool.pick(IrOp, U32.is_eq(um_get(sc, s), 1), IConst{d, 0}, ITag{d, s}), acc})
    case Con{ICmp{+d, +cop, +a, +b}, t}: (disj = Bool.and(sm, Bool.and(U32.is_le(cop, 1), Bool.or(Bool.and(U32.is_eq(um_get(sc, a), 1), U32.is_ne(um_get(cm, b), 0)), Bool.and(U32.is_eq(um_get(sc, b), 1), U32.is_ne(um_get(cm, a), 0))))); opt_sc_rewrite_ops(sm, sc, t, Bool.pick(U32Map, sm, um_set(cm, d, 0), cm), Con{Bool.pick(IrOp, disj, IConst{d, cop}, ICmp{d, cop, a, b}), acc}))
    case Con{ICtor{+d, cid, fs}, t}: opt_sc_rewrite_ops(sm, sc, t, Bool.pick(U32Map, sm, um_set(cm, d, 1), cm), Con{ICtor{d, cid, fs}, acc})
    case Con{IReuse{+d, sl, cid, fs}, t}: opt_sc_rewrite_ops(sm, sc, t, Bool.pick(U32Map, sm, um_set(cm, d, 1), cm), Con{IReuse{d, sl, cid, fs}, acc})
    case Con{IArrOp{+ds, 73, Con{a, Con{i, Con{+v, Nil{}}}}}, t}: opt_sc_rewrite_ops(sm, sc, t, Bool.pick(U32Map, sm, opt_um_set_list(ds, 0, cm), cm), Con{IArrOp{ds, Bool.pick(U32, Bool.and(sm, U32.is_eq(um_get(sc, v), 1)), 79, 73), [a, i, v]}, acc})
    case Con{+op, t}: opt_sc_rewrite_ops(sm, sc, t, Bool.pick(U32Map, sm, opt_kill_op_dsts(op, cm), cm), Con{op, acc})
def opt_ip_init_orig(n: Nat, +idx: U32, m: U32Map) -> U32Map:
  match n:
    case 0n: m
    case 1n+p: opt_ip_init_orig(p, U32.add(idx, 1), um_set(m, idx, U32.add(idx, 1)))
def opt_ip_obs_args(+self_fid: U32, +cfid: U32, +sc: U32Map, +orig: U32Map, args: List<&2, U32>, +idx: U32, +obs: U32Map) -> U32Map:
  match args:
    case Nil{}: obs
    case Con{+a, t}: (is_self_pass = Bool.and(U32.is_eq(cfid, self_fid), U32.is_eq(um_get(orig, a), U32.add(idx, 1))); ok_range = Bool.and(U32.is_lt(cfid, 2048), U32.is_lt(idx, 64)); +k = opt_pkey(cfid, idx); +cur = um_get(obs, k); +nv = Bool.pick(U32, U32.is_eq(um_get(sc, a), 1), Bool.pick(U32, U32.is_zero(cur), 1, cur), 2); opt_ip_obs_args(self_fid, cfid, sc, orig, t, U32.add(idx, 1), Bool.pick(U32Map, Bool.and(ok_range, Bool.not(is_self_pass)), um_set(obs, k, nv), obs)))
type IpRes is Data:
  IpRes{ret_sc: U32Map, psc: U32Map, chg: Bool}
def opt_ip_promote_params(+fid: U32, +obs: U32Map, n: Nat, +idx: U32, ret_sc: U32Map, +psc: U32Map, chg: Bool) -> IpRes:
  match n:
    case 0n: IpRes{ret_sc, psc, chg}
    case 1n+p: (+k = opt_pkey(fid, idx); +prom = Bool.and(U32.is_lt(idx, 64), Bool.and(U32.is_zero(um_get(psc, k)), U32.is_eq(um_get(obs, k), 1))); opt_ip_promote_params(fid, obs, p, U32.add(idx, 1), ret_sc, Bool.pick(U32Map, prom, um_set(psc, k, 1), psc), Bool.or(chg, prom)))
def opt_ip_promote_fns(+bad: U32Map, +obs: U32Map, fns: List<&2, IrFn>, st: IpRes) -> IpRes:
  match fns st:
    case Nil{} _: st
    case Con{IrFn{+fid, _, +ar, _, _, _, _, _}, t} IpRes{+ret_sc, +psc, +chg}: (st1 = low_if(IpRes, U32.is_zero(um_get(bad, fid)), _ => opt_ip_promote_params(fid, obs, U32.to_nat(U32.min(ar, 64)), 0, ret_sc, psc, chg), _ => IpRes{ret_sc, psc, chg}); opt_ip_promote_fns(bad, obs, t, st1))
type IpScan is Data:
  IpScan{ret_sc: U32Map, obs: U32Map, chg: Bool}
def opt_ip_add_dep_blks(blks: List<&2, IrBlock>, +m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, Con{IBin{+t2, 0, +va, _}, Con{ICopy{+dst, +s}, Nil{}}}, TJmp{_}}, t}: (+oa = um_get(m, va); ok = Bool.and(U32.is_eq(t2, s), Bool.and(U32.is_ne(oa, 0), U32.is_zero(um_get(m, dst)))); opt_ip_add_dep_blks(t, Bool.pick(U32Map, ok, um_set(m, dst, oa), m)))
    case Con{_, t}: opt_ip_add_dep_blks(t, m)
def opt_ip_step(+bad: U32Map, +fns: List<&2, IrFn>, psc0: U32Map, sc: IpScan) -> IpRes:
  match sc:
    case IpScan{ret1, obs1, chg1}: opt_ip_promote_fns(bad, obs1, fns, IpRes{ret1, psc0, chg1})
# Pass A — Local Constructor-Take Fusion (SROA)
type CtorEnt is Data:
  CtorNone{}
  CtorSome{vreg: U32, fs: List<&2, U32>}
def sroa_tag_ops(ops: List<&2, IrOp>, +cids: U32Map, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: b5k_list_rev(IrOp, acc)
    case Con{ICtor{+d, +cid, fs}, t}: sroa_tag_ops(t, um_set(cids, d, U32.add(cid, 1)), Con{ICtor{d, cid, fs}, acc})
    case Con{IReuse{+d, sl, +cid, fs}, t}: sroa_tag_ops(t, um_set(cids, d, U32.add(cid, 1)), Con{IReuse{d, sl, cid, fs}, acc})
    case Con{ITag{+d, +s}, t}: (+got = um_get(cids, s); sroa_tag_ops(t, um_set(cids, d, 0), Con{Bool.pick(IrOp, U32.is_ne(got, 0), IConst{d, U32.sub(got, 1)}, ITag{d, s}), acc}))
    case Con{IArrOp{Con{+r0, Con{+r1, Nil{}}}, 72, Con{+a, Con{+i, Nil{}}}}, t}: (acc1 = Bool.pick(List<&2, IrOp>, U32.is_ne(r1, a), Con{ICopy{r0, a}, Con{IArrOp{[r1], 78, [a, i]}, acc}}, Con{IArrOp{[r0, r1], 72, [a, i]}, acc}); sroa_tag_ops(t, opt_kill_op_dsts(IArrOp{[r0, r1], 72, [a, i]}, cids), acc1))
    case Con{+op, t}: sroa_tag_ops(t, opt_kill_op_dsts(op, cids), Con{op, acc})
def sroa_emit_copies(ds: List<&2, U32>, fs: List<&2, U32>, acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ds fs:
    case Con{d, dt} Con{f, ft}: sroa_emit_copies(dt, ft, Con{ICopy{d, f}, acc})
    case _ _: acc
def sroa_emit_sinks(fs: List<&2, U32>, acc: List<&2, IrOp>) -> List<&2, IrOp>: opt_foldl0(~U32, ~List<&2, IrOp>, ~(f => a => Con{ISink{f}, a}), fs, acc)
type SroaRes is Data:
  SroaRes{ops_rev: List<&2, IrOp>, fused: U32Map}
def sroa_drop_fused(+fused: U32Map, ops_rev: List<&2, IrOp>, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops_rev:
    case Nil{}: acc
    case Con{ICtor{+d, cid, fs}, t}: sroa_drop_fused(fused, t, Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(fused, d), 0), acc, Con{ICtor{d, cid, fs}, acc}))
    case Con{op, t}: sroa_drop_fused(fused, t, Con{op, acc})
def sroa_do_take(ce: CtorEnt, +ds: List<&2, U32>, +s: U32, +fused: U32Map, +acc: List<&2, IrOp>) -> SroaRes:
  match ce:
    case CtorSome{v, +fs}: (+ok = Bool.and(U32.is_eq(v, s), U32.is_eq(b5k_u32_list_len(ds), b5k_u32_list_len(fs))); SroaRes{Bool.pick(List<&2, IrOp>, ok, sroa_emit_copies(ds, fs, acc), Con{ITake{ds, s}, acc}), Bool.pick(U32Map, ok, um_set(fused, s, 1), fused)})
    case CtorNone{}: SroaRes{Con{ITake{ds, s}, acc}, fused}
def sroa_do_sink(ce: CtorEnt, +s: U32, +fused: U32Map, +acc: List<&2, IrOp>) -> SroaRes:
  match ce:
    case CtorSome{v, fs}: (+ok = U32.is_eq(v, s); SroaRes{Bool.pick(List<&2, IrOp>, ok, sroa_emit_sinks(fs, acc), Con{ISink{s}, acc}), Bool.pick(U32Map, ok, um_set(fused, s, 1), fused)})
    case CtorNone{}: SroaRes{Con{ISink{s}, acc}, fused}
def sroa_fuse_ops(+defc: U32Map, +uses: U32Map, +ar: U32, ops: List<&2, IrOp>, +cmap: RaVec<CtorEnt>, st: SroaRes) -> SroaRes:
  match ops st:
    case Nil{} _: st
    case Con{ICtor{+d, cid, +fs}, t} SroaRes{acc, fused}: sroa_fuse_ops(defc, uses, ar, t, opt_rv_put(CtorEnt, opt_is_su_ctor(defc, uses, ar, d, fs), 6n, d, CtorSome{d, fs}, cmap), SroaRes{Con{ICtor{d, cid, fs}, acc}, fused})
    case Con{ITake{ds, +s}, t} SroaRes{acc, fused}: sroa_fuse_ops(defc, uses, ar, t, cmap, sroa_do_take(ra_vec_get(CtorEnt, 6n, CtorNone{}, s, cmap), ds, s, fused, acc))
    case Con{ISink{+s}, t} SroaRes{acc, fused}: sroa_fuse_ops(defc, uses, ar, t, cmap, sroa_do_sink(ra_vec_get(CtorEnt, 6n, CtorNone{}, s, cmap), s, fused, acc))
    case Con{op, t} SroaRes{acc, fused}: sroa_fuse_ops(defc, uses, ar, t, cmap, SroaRes{Con{op, acc}, fused})
def sroa_blk_fin(id: U32, term: IrTerm, r: SroaRes) -> IrBlock:
  match r:
    case SroaRes{rev, fused}: IrBlock{id, sroa_drop_fused(fused, rev, Nil{}), term}
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
    case 15: U32.sub(a, b)
    case 16: U32.or(U32.shln(a, U32.to_nat(b)), U32.shrn(a, U32.to_nat(U32.sub(32, b))))
    case _: U32.shrn(a, U32.to_nat(b))
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
    case 1n+p: Bool.pick(U32, U32.is_le(x, 1), acc, opt_ctz_go(p, U32.shr(x), U32.add(acc, 1)))
def opt_pow2_log(+c: U32) -> U32: Bool.pick(U32, Bool.and(U32.is_ge(c, 2), Bool.and(U32.is_le(c, 1073741824), U32.is_zero(U32.and(c, U32.sub(c, 1))))), opt_ctz_go(31n, c, 0), 0)
def cf_emit_mod255(has: U32Map, val: U32Map, +nr: U32, rev: List<&2, IrOp>, +d: U32, +a: U32, +b: U32, +cb: U32) -> CfSt:
  o1 : List<&2, IrOp> = Con{IBin{U32.add(nr, 4), 0, U32.add(nr, 1), U32.add(nr, 3)}, Con{IBin{U32.add(nr, 3), 9, a, U32.add(nr, 2)}, Con{IConst{U32.add(nr, 2), 16}, Con{IBin{U32.add(nr, 1), 5, a, nr}, Con{IConst{nr, 65535}, rev}}}}}
  o2 : List<&2, IrOp> = Con{IBin{U32.add(nr, 9), 0, U32.add(nr, 6), U32.add(nr, 8)}, Con{IBin{U32.add(nr, 8), 9, U32.add(nr, 4), U32.add(nr, 7)}, Con{IConst{U32.add(nr, 7), 8}, Con{IBin{U32.add(nr, 6), 5, U32.add(nr, 4), U32.add(nr, 5)}, Con{IConst{U32.add(nr, 5), 255}, o1}}}}}
  o3 : List<&2, IrOp> = Con{IBin{d, 1, U32.add(nr, 9), U32.add(nr, 13)}, Con{IBin{U32.add(nr, 13), 2, U32.add(nr, 12), b}, Con{IBin{U32.add(nr, 12), 9, U32.add(nr, 11), U32.add(nr, 2)}, Con{IBin{U32.add(nr, 11), 2, U32.add(nr, 9), U32.add(nr, 10)}, Con{IConst{U32.add(nr, 10), U32.div(U32.add(65535, cb), cb)}, o2}}}}}
  CfSt{um_set(has, d, 0), val, U32.add(nr, 14), o3}
type CfSt is Data:
  CfSt{has: U32Map, val: U32Map, nregs: U32, ops_rev: List<&2, IrOp>}
def cf_emit_const(has: U32Map, val: U32Map, nr: U32, rev: List<&2, IrOp>, +d: U32, +v: U32) -> CfSt: CfSt{um_set(has, d, 1), um_set(val, d, v), nr, Con{IConst{d, v}, rev}}
def cf_emit_flt(has: U32Map, val: U32Map, nr: U32, rev: List<&2, IrOp>, +d: U32, +bits: U32) -> CfSt: CfSt{um_set(has, d, 2), um_set(val, d, bits), nr, Con{IFlt{d, bits}, rev}}
def cf_emit_copy(+has: U32Map, +val: U32Map, nr: U32, rev: List<&2, IrOp>, +d: U32, +s: U32) -> CfSt: CfSt{um_set(has, d, um_get(has, s)), um_set(val, d, um_get(val, s)), nr, Con{ICopy{d, s}, rev}}
def cf_emit_sr(has: U32Map, val: U32Map, +nr: U32, rev: List<&2, IrOp>, +d: U32, sop: U32, x: U32, imm: U32) -> CfSt: CfSt{um_set(has, d, 0), val, U32.add(nr, 1), Con{IBin{d, sop, x, nr}, Con{IConst{nr, imm}, rev}}}
def cf_bin_one_const(+is_rhs: Bool, +has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32, +b: U32, +x: U32, +c: U32) -> CfSt:
  match op:
    case 0: Bool.pick(CfSt, U32.is_zero(c), cf_emit_copy(has, val, nr, rev, d, x), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 0, a, b}, rev}})
    case 1: Bool.pick(CfSt, U32.is_zero(c), Bool.pick(CfSt, is_rhs, cf_emit_copy(has, val, nr, rev, d, a), CfSt{um_set(has, d, 0), val, nr, Con{IUn{d, 0, b}, rev}}), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 1, a, b}, rev}})
    case 2: (+p2 = opt_pow2_log(c); Bool.pick(CfSt, U32.is_zero(c), cf_emit_const(has, val, nr, rev, d, 0), Bool.pick(CfSt, U32.is_eq(c, 1), cf_emit_copy(has, val, nr, rev, d, x), Bool.pick(CfSt, U32.is_ne(p2, 0), cf_emit_sr(has, val, nr, rev, d, B5K_OP_SHL(), x, p2), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 2, a, b}, rev}}))))
    case 3: (+p2 = opt_pow2_log(c); Bool.pick(CfSt, Bool.and(is_rhs, U32.is_eq(c, 1)), cf_emit_copy(has, val, nr, rev, d, a), Bool.pick(CfSt, Bool.and(is_rhs, U32.is_ne(p2, 0)), cf_emit_sr(has, val, nr, rev, d, B5K_OP_SHR(), a, p2), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 3, a, b}, rev}})))
    case 4: (+p2 = opt_pow2_log(c); +is255 = Bool.and(is_rhs, Bool.and(U32.is_ge(c, 15), Bool.and(U32.is_le(c, 85), U32.is_zero(U32.mod(255, c))))); Bool.pick(CfSt, Bool.and(is_rhs, U32.is_eq(c, 1)), cf_emit_const(has, val, nr, rev, d, 0), Bool.pick(CfSt, Bool.and(is_rhs, U32.is_ne(p2, 0)), cf_emit_sr(has, val, nr, rev, d, B5K_OP_AND(), a, U32.sub(c, 1)), Bool.pick(CfSt, is255, cf_emit_mod255(has, val, nr, rev, d, a, b, c), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 4, a, b}, rev}}))))
    case 5: Bool.pick(CfSt, U32.is_zero(c), cf_emit_const(has, val, nr, rev, d, 0), Bool.pick(CfSt, U32.is_eq(c, 4294967295), cf_emit_copy(has, val, nr, rev, d, x), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 5, a, b}, rev}}))
    case 6: Bool.pick(CfSt, U32.is_zero(c), cf_emit_copy(has, val, nr, rev, d, x), Bool.pick(CfSt, U32.is_eq(c, 4294967295), cf_emit_const(has, val, nr, rev, d, 4294967295), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 6, a, b}, rev}}))
    case 7: Bool.pick(CfSt, U32.is_zero(c), cf_emit_copy(has, val, nr, rev, d, x), Bool.pick(CfSt, U32.is_eq(c, 4294967295), CfSt{um_set(has, d, 0), val, nr, Con{IUn{d, 1, x}, rev}}, CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 7, a, b}, rev}}))
    case 15: Bool.pick(CfSt, Bool.and(is_rhs, U32.is_zero(c)), cf_emit_copy(has, val, nr, rev, d, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 15, a, b}, rev}})
    case 16: CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, 16, a, b}, rev}}
    case +op0: Bool.pick(CfSt, U32.is_zero(c), Bool.pick(CfSt, is_rhs, cf_emit_copy(has, val, nr, rev, d, a), cf_emit_const(has, val, nr, rev, d, 0)), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, op0, a, b}, rev}})
def cf_bin_same(+has: U32Map, +val: U32Map, nr: U32, rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32) -> CfSt:
  match op:
    case 1: cf_emit_const(has, val, nr, rev, d, 0)
    case 5: cf_emit_copy(has, val, nr, rev, d, a)
    case 6: cf_emit_copy(has, val, nr, rev, d, a)
    case 7: cf_emit_const(has, val, nr, rev, d, 0)
    case _: CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, op, a, a}, rev}}
def cf_step_bin_int(ha: Bool, hb: Bool, +has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32, +b: U32) -> CfSt:
  match ha hb:
    case True{} True{}: (+cb = um_get(val, b); Bool.pick(CfSt, Bool.and(Bool.and(U32.is_ge(op, 8), U32.is_le(op, 9)), U32.is_ge(cb, 32)), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, op, a, b}, rev}}, cf_emit_const(has, val, nr, rev, d, opt_fold_bin(op, um_get(val, a), cb))))
    case False{} True{}: cf_bin_one_const(True{}, has, val, nr, rev, d, op, a, b, a, um_get(val, b))
    case True{} False{}: cf_bin_one_const(False{}, has, val, nr, rev, d, op, a, b, b, um_get(val, a))
    case False{} False{}: Bool.pick(CfSt, U32.is_eq(a, b), cf_bin_same(has, val, nr, rev, d, op, a), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, op, a, b}, rev}})
def opt_u2f_bits(+c: U32) -> U32:
  match c:
    case 0: 0
    case +n: (+e = U32.from_nat(U32.log2(n)); +hi = U32.is_gt(e, 23); +sh = Bool.pick(U32, hi, U32.sub(e, 23), 0); +q0 = U32.shrn(n, U32.to_nat(sh)); +rem = U32.and(n, U32.sub(U32.shln(1, U32.to_nat(sh)), 1)); +half = Bool.pick(U32, hi, U32.shln(1, U32.to_nat(U32.sub(sh, 1))), 0); +q1 = Bool.pick(U32, Bool.and(hi, Bool.or(U32.is_gt(rem, half), Bool.and(U32.is_eq(rem, half), U32.is_eq(U32.and(q0, 1), 1)))), U32.add(q0, 1), q0); +ov = Bool.and(hi, U32.is_eq(q1, 16777216)); U32.or(U32.shln(U32.add(127, Bool.pick(U32, ov, U32.add(e, 1), e)), 23n), Bool.pick(U32, hi, Bool.pick(U32, ov, 0, U32.and(q1, 8388607)), U32.and(U32.shln(n, U32.to_nat(U32.sub(23, e))), 8388607))))
def opt_f32_to_small_u32(+bits: U32) -> U32: (+exp = U32.shrn(bits, 23n); +ok_e = Bool.and(U32.is_ge(exp, 127), U32.is_le(exp, 142)); +sh = Bool.pick(U32, ok_e, U32.sub(150, exp), 0); +mant = U32.and(bits, 8388607); Bool.pick(U32, Bool.and(ok_e, U32.is_zero(U32.and(mant, U32.sub(U32.shln(1, U32.to_nat(sh)), 1)))), U32.shrn(U32.or(8388608, mant), U32.to_nat(sh)), 0))
type OptFdiv is Data:
  OptFdiv{a: U32, b: U32, e: U32}
def opt_fdiv_shift(+up: Bool, fuel: Nat, go: Bool, +a: U32, +b: U32, +exp: U32) -> OptFdiv:
  match fuel go:
    case 1n+p True{}: (+a1 = Bool.pick(U32, up, U32.shln(a, 1n), a); +b1 = Bool.pick(U32, up, b, U32.shln(b, 1n)); opt_fdiv_shift(up, p, Bool.pick(Bool, up, U32.is_lt(a1, b1), U32.is_ge(a1, U32.shln(b1, 1n))), a1, b1, Bool.pick(U32, up, U32.sub(exp, 1), U32.add(exp, 1))))
    case _ _: OptFdiv{a, b, exp}
def opt_fdiv_loop(n: Nat, +a: U32, +b: U32, +q: U32) -> OptFdiv:
  match n:
    case 0n: OptFdiv{a, b, q}
    case 1n+p: (+a1 = U32.shln(a, 1n); +ge = U32.is_ge(a1, b); opt_fdiv_loop(p, Bool.pick(U32, ge, U32.sub(a1, b), a1), b, Bool.pick(U32, ge, U32.or(U32.shln(q, 1n), 1), U32.shln(q, 1n))))
def opt_un_fd(-R: Type, f: OptFdiv, k: U32 -> U32 -> U32 -> R) -> R:
  OptFdiv{a, b, e} = f
  k(a, b, e)
def opt_fdiv_bits(+a0: U32, +b0: U32) -> U32: opt_un_fd(U32, opt_fdiv_shift(True{}, 20n, U32.is_lt(a0, b0), a0, b0, 127), a1_ => b1_ => e1 => (+a1 = a1_; +b1 = b1_; opt_un_fd(U32, opt_fdiv_shift(False{}, 20n, U32.is_ge(a1, U32.shln(b1, 1n)), a1, b1, e1), a2 => b2_ => e2_ => (+b2 = b2_; +e2 = e2_; opt_un_fd(U32, opt_fdiv_loop(23n, U32.sub(a2, b2), b2, 0), rem => b3_ => q0_ => (+b3 = b3_; +q0 = q0_; +r2 = U32.shln(rem, 1n); +q1 = Bool.pick(U32, Bool.or(U32.is_gt(r2, b3), Bool.and(U32.is_eq(r2, b3), U32.is_eq(U32.and(q0, 1), 1))), U32.add(q0, 1), q0); +ov = U32.is_eq(q1, 8388608); U32.or(U32.shln(Bool.pick(U32, ov, U32.add(e2, 1), e2), 23n), Bool.pick(U32, ov, 0, q1))))))))
def cf_step_bin_flt(+has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32, +b: U32) -> CfSt: (+fok = Bool.and(U32.is_eq(um_get(has, a), 2), U32.is_eq(um_get(has, b), 2)); +va = um_get(val, a); +vb = um_get(val, b); +nb = Bool.pick(U32, U32.is_zero(U32.and(vb, 2147483647)), 0, U32.xor(vb, 2147483648)); +na = Bool.pick(U32, Bool.and(fok, U32.is_eq(op, 13)), opt_f32_to_small_u32(va), 0); +db = Bool.pick(U32, U32.is_ne(na, 0), opt_f32_to_small_u32(vb), 0); Bool.pick(CfSt, Bool.and(fok, Bool.and(U32.is_eq(op, 11), U32.is_zero(va))), cf_emit_flt(has, val, nr, rev, d, nb), Bool.pick(CfSt, U32.is_ne(db, 0), cf_emit_flt(has, val, nr, rev, d, opt_fdiv_bits(na, db)), CfSt{um_set(has, d, 0), val, nr, Con{IBin{d, op, a, b}, rev}})))
def cf_step_bin(+has: U32Map, +val: U32Map, +nr: U32, +rev: List<&2, IrOp>, +d: U32, +op: U32, +a: U32, +b: U32) -> CfSt: low_if(CfSt, U32.is_ge(op, 10), _ => cf_step_bin_flt(has, val, nr, rev, d, op, a, b), _ => cf_step_bin_int(U32.is_eq(um_get(has, a), 1), U32.is_eq(um_get(has, b), 1), has, val, nr, rev, d, op, a, b))
def opt_pred_arms(arms: List<&2, IrSwitchArm>, m: U32Map) -> U32Map: opt_foldl0(~IrSwitchArm, ~U32Map, ~(a => acc => opt_un_arm(U32Map, a, _ => tgt => opt_um_inc(acc, tgt))), arms, m)
def opt_count_preds(blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, _, TJmp{tgt}}, t}: opt_count_preds(t, opt_um_inc(m, tgt))
    case Con{IrBlock{_, _, TBr{_, tb, fb}}, t}: opt_count_preds(t, opt_um_inc(opt_um_inc(m, tb), fb))
    case Con{IrBlock{_, _, TSwitch{_, arms, db}}, t}: opt_count_preds(t, opt_pred_arms(arms, opt_um_inc(m, db)))
    case Con{_, t}: opt_count_preds(t, m)
def opt_preds_init(blks: List<&2, IrBlock>) -> U32Map: opt_count_preds(blks, um_set(UM0{}, 0, 2))
type BrFact is Data:
  BFNone{}
  BFEq{v: U32, k: U32}
  BFNe{v: U32, k: U32}
type BrScan is Data:
  BrScan{has: U32Map, val: U32Map, hit: Bool, cop: U32, a: U32, b: U32}
def cf_br_scan_ops(+c: U32, ops: List<&2, IrOp>, st: BrScan) -> BrScan:
  match ops st:
    case Nil{} _: st
    case Con{IConst{+d, v}, t} BrScan{has, val, hit, cop, a, b}: cf_br_scan_ops(c, t, BrScan{um_set(has, d, 1), um_set(val, d, v), Bool.and(hit, U32.is_ne(d, c)), cop, a, b})
    case Con{ICopy{+d, +s}, t} BrScan{+has, +val, hit, cop, a, b}: cf_br_scan_ops(c, t, BrScan{um_set(has, d, um_get(has, s)), um_set(val, d, um_get(val, s)), Bool.and(hit, U32.is_ne(d, c)), cop, a, b})
    case Con{ICmp{+d, +nc, +na, +nb}, t} BrScan{+has, +val, hit, cop, a, b}: (st1 = Bool.pick(BrScan, Bool.and(U32.is_eq(d, c), U32.is_le(nc, 1)), BrScan{um_set(has, d, 0), val, True{}, nc, na, nb}, BrScan{um_set(has, d, 0), val, Bool.and(hit, U32.is_ne(d, c)), cop, a, b}); cf_br_scan_ops(c, t, st1))
    case Con{+op, t} BrScan{has, val, hit, cop, a, b}: cf_br_scan_ops(c, t, BrScan{opt_kill_op_dsts(op, has), val, hit, cop, a, b})
def cf_br_put(+preds: U32Map, +bid: U32, +tgt: U32, f: BrFact, fm: RaVec<BrFact>) -> RaVec<BrFact>: opt_rv_put(BrFact, Bool.and(U32.is_ne(tgt, 0), opt_is_sp(preds, bid, tgt)), 5n, tgt, f, fm)
def cf_br_record(+defc: U32Map, +ar: U32, +preds: U32Map, +bid: U32, +c: U32, +tb: U32, +fb: U32, sc: BrScan, +fm: RaVec<BrFact>) -> RaVec<BrFact>:
  match sc:
    case BrScan{+has, +val, True{}, +cop, +a, +b}: (+ha = U32.is_ne(um_get(has, a), 0); +hb = U32.is_ne(um_get(has, b), 0); +eq_t = Bool.pick(U32, U32.is_zero(cop), tb, fb); +ne_t = Bool.pick(U32, U32.is_zero(cop), fb, tb); +fm1 = Bool.pick(RaVec<BrFact>, Bool.and(hb, Bool.and(Bool.not(ha), opt_cp_can_prop(defc, ar, a))), cf_br_put(preds, bid, ne_t, BFNe{a, um_get(val, b)}, cf_br_put(preds, bid, eq_t, BFEq{a, um_get(val, b)}, fm)), fm); Bool.pick(RaVec<BrFact>, Bool.and(ha, Bool.and(Bool.not(hb), opt_cp_can_prop(defc, ar, b))), cf_br_put(preds, bid, ne_t, BFNe{b, um_get(val, a)}, cf_br_put(preds, bid, eq_t, BFEq{b, um_get(val, a)}, fm1)), fm1))
    case BrScan{_, _, False{}, _, _, _}: Bool.pick(RaVec<BrFact>, opt_cp_can_prop(defc, ar, c), cf_br_put(preds, bid, tb, BFNe{c, 0}, cf_br_put(preds, bid, fb, BFEq{c, 0}, fm)), fm)
def cf_collect_facts(+defc: U32Map, +ar: U32, +preds: U32Map, blks: List<&2, IrBlock>, fm: RaVec<BrFact>) -> RaVec<BrFact>:
  match blks:
    case Nil{}: fm
    case Con{IrBlock{id, ops, TBr{+c, tb, fb}}, t}: cf_collect_facts(defc, ar, preds, t, cf_br_record(defc, ar, preds, id, c, tb, fb, cf_br_scan_ops(c, ops, BrScan{UM0{}, UM0{}, False{}, 0, 0, 0}), fm))
    case Con{_, t}: cf_collect_facts(defc, ar, preds, t, fm)
def cf_step_op(+ne_v: U32, +ne_k: U32, st: CfSt, op: IrOp) -> CfSt:
  match st op:
    case CfSt{has, val, nr, rev} IConst{d, v}: cf_emit_const(has, val, nr, rev, d, v)
    case CfSt{has, val, nr, rev} IFlt{d, bits}: cf_emit_flt(has, val, nr, rev, d, bits)
    case CfSt{has, val, nr, rev} ICopy{d, s}: cf_emit_copy(has, val, nr, rev, d, s)
    case CfSt{has, val, nr, rev} IBin{d, bop, a, b}: cf_step_bin(has, val, nr, rev, d, bop, a, b)
    case CfSt{+has, +val, +nr, +rev} IUn{+d, +uop, +s}: (+hs = um_get(has, s); +vs = um_get(val, s); Bool.pick(CfSt, Bool.and(U32.is_lt(uop, 2), U32.is_eq(hs, 1)), cf_emit_const(has, val, nr, rev, d, Bool.pick(U32, U32.is_zero(uop), U32.sub(0, vs), U32.xor(vs, 4294967295))), Bool.pick(CfSt, Bool.and(U32.is_eq(uop, 2), U32.is_eq(hs, 2)), cf_emit_flt(has, val, nr, rev, d, U32.xor(vs, 2147483648)), Bool.pick(CfSt, Bool.and(U32.is_eq(uop, 4), U32.is_eq(hs, 1)), cf_emit_flt(has, val, nr, rev, d, opt_u2f_bits(vs)), CfSt{um_set(has, d, 0), val, nr, Con{IUn{d, uop, s}, rev}}))))
    case CfSt{+has, +val, +nr, +rev} ICmp{+d, +cop, +a, +b}: (+ha = U32.is_eq(um_get(has, a), 1); +hb = U32.is_eq(um_get(has, b), 1); +nv = U32.sub(ne_v, 1); ne_hit = Bool.and(U32.is_ne(ne_v, 0), Bool.and(U32.is_le(cop, 1), Bool.or(Bool.and(U32.is_eq(a, nv), Bool.and(hb, U32.is_eq(um_get(val, b), ne_k))), Bool.and(U32.is_eq(b, nv), Bool.and(ha, U32.is_eq(um_get(val, a), ne_k)))))); same_v = Bool.to_u32(Bool.or(U32.is_eq(cop, 0), Bool.or(U32.is_eq(cop, 3), U32.is_eq(cop, 5)))); Bool.pick(CfSt, Bool.and(U32.is_lt(cop, 6), Bool.and(ha, hb)), cf_emit_const(has, val, nr, rev, d, opt_fold_cmp(cop, um_get(val, a), um_get(val, b))), Bool.pick(CfSt, Bool.and(U32.is_lt(cop, 6), U32.is_eq(a, b)), cf_emit_const(has, val, nr, rev, d, same_v), Bool.pick(CfSt, ne_hit, cf_emit_const(has, val, nr, rev, d, cop), CfSt{um_set(has, d, 0), val, nr, Con{ICmp{d, cop, a, b}, rev}}))))
    case CfSt{has, val, nr, rev} +op0: CfSt{opt_kill_op_dsts(op0, has), val, nr, Con{op0, rev}}
def cf_step_ops(+ne_v: U32, +ne_k: U32, ops: List<&2, IrOp>, st: CfSt) -> CfSt: opt_foldl2(~IrOp, ~U32, ~U32, ~CfSt, ~(v => k => op => s => cf_step_op(v, k, s, op)), ne_v, ne_k, ops, st)
def cf_find_arm(arms: List<&2, IrSwitchArm>, +tag: U32, def_blk: U32) -> U32:
  match arms:
    case Nil{}: def_blk
    case Con{IrArm{t, tgt}, rest}: Bool.pick(U32, U32.is_eq(t, tag), tgt, cf_find_arm(rest, tag, def_blk))
def cf_fold_term(+ne_v: U32, +ne_k: U32, +has: U32Map, +val: U32Map, term: IrTerm) -> IrTerm:
  match term:
    case TBr{+c, +tb, +fb}: (+ne_nz = Bool.and(U32.is_ne(ne_v, 0), Bool.and(U32.is_eq(c, U32.sub(ne_v, 1)), U32.is_zero(ne_k))); Bool.pick(IrTerm, U32.is_eq(um_get(has, c), 1), TJmp{Bool.pick(U32, U32.is_zero(um_get(val, c)), fb, tb)}, Bool.pick(IrTerm, ne_nz, TJmp{tb}, TBr{c, tb, fb})))
    case TSwitch{+s, +arms, +def_blk}: Bool.pick(IrTerm, U32.is_eq(um_get(has, s), 1), TJmp{cf_find_arm(arms, um_get(val, s), def_blk)}, TSwitch{s, arms, def_blk})
    case other: other
type CfBlksRes is Data:
  CfBlksRes{blks: List<&2, IrBlock>, nregs: U32}
type CfGConsts is Data:
  CfGConsts{ghas: U32Map, gval: U32Map}
def cf_gc_ops(+defc: U32Map, +ar: U32, ops: List<&2, IrOp>, st: CfGConsts) -> CfGConsts:
  match ops st:
    case Nil{} _: st
    case Con{IConst{+d, v}, t} CfGConsts{+gh, +gv}: (ok = Bool.and(U32.is_ge(d, ar), U32.is_eq(um_get(defc, d), 1)); cf_gc_ops(defc, ar, t, Bool.pick(CfGConsts, ok, CfGConsts{um_set(gh, d, 1), um_set(gv, d, v)}, CfGConsts{gh, gv})))
    case Con{ICopy{+d, +s}, t} CfGConsts{+gh, +gv}: (ok = Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_eq(um_get(defc, d), 1), U32.is_ne(um_get(gh, s), 0))); cf_gc_ops(defc, ar, t, Bool.pick(CfGConsts, ok, CfGConsts{um_set(gh, d, 1), um_set(gv, d, um_get(gv, s))}, CfGConsts{gh, gv})))
    case Con{_, t} _: cf_gc_ops(defc, ar, t, st)
def cf_gc_blks(+defc: U32Map, +ar: U32, blks: List<&2, IrBlock>, st: CfGConsts) -> CfGConsts: opt_foldl2(~IrBlock, ~U32Map, ~U32, ~CfGConsts, ~(d => a => b => s => opt_un_blk(CfGConsts, b, _ => ops => _ => cf_gc_ops(d, a, ops, s))), defc, ar, blks, st)
def opt_un_gc(-R: Type, g: CfGConsts, k: U32Map -> U32Map -> R) -> R:
  CfGConsts{gh, gv} = g
  k(gh, gv)
def cf_blks_step(ne_v: U32, ne_k: U32, id: U32, term: IrTerm, acc: List<&2, IrBlock>, st: CfSt) -> CfBlksRes:
  CfSt{has, val, nr1, rev} = st
  CfBlksRes{Con{IrBlock{id, b5k_list_rev(IrOp, rev), cf_fold_term(ne_v, ne_k, has, val, term)}, acc}, nr1}
def cf_blks_one(f: BrFact, +gh: U32Map, +gv: U32Map, id: U32, ops: List<&2, IrOp>, term: IrTerm, acc: List<&2, IrBlock>, nr: U32) -> CfBlksRes:
  match f:
    case BFNone{}: cf_blks_step(0, 0, id, term, acc, cf_step_ops(0, 0, ops, CfSt{gh, gv, nr, Nil{}}))
    case BFEq{+v, k}: cf_blks_step(0, 0, id, term, acc, cf_step_ops(0, 0, ops, CfSt{um_set(gh, v, 1), um_set(gv, v, k), nr, Nil{}}))
    case BFNe{+v, +k}: cf_blks_step(U32.add(v, 1), k, id, term, acc, cf_step_ops(U32.add(v, 1), k, ops, CfSt{gh, gv, nr, Nil{}}))
def cf_blks_go(+fm: RaVec<BrFact>, +gh: U32Map, +gv: U32Map, blks: List<&2, IrBlock>, st: CfBlksRes) -> CfBlksRes:
  match blks st:
    case Nil{} CfBlksRes{acc, nr}: CfBlksRes{b5k_list_rev(IrBlock, acc), nr}
    case Con{IrBlock{+id, ops, term}, t} CfBlksRes{acc, nr}: cf_blks_go(fm, gh, gv, t, cf_blks_one(opt_rv_get(BrFact, BFNone{}, id, fm), gh, gv, id, ops, term, acc, nr))
def cf_fn_fin(fid: U32, nm: String, ar: U32, esc: Bool, eff: Bool, is_m: Bool, r: CfBlksRes) -> IrFn:
  CfBlksRes{blks2, nr2} = r
  IrFn{fid, nm, ar, nr2, esc, eff, is_m, blks2}
# Pass 3 & Pass D — Copy Prop, CSE, DCE, Unreach & Block Merge
def opt_cp_rewrite_op(cm: U32Map, op: IrOp) -> IrOp: opt_rm_op(False{}, RMLookup{cm}, op)
type CseEnt is Data:
  CseNone{}
  CseSome{k: U32, op: U32, a: U32, b: U32, dst: U32}
def cse_hash(+k: U32, +op: U32, +a: U32, +b: U32) -> U32: (+h1 = U32.xor(U32.mul(a, 2654435761), U32.mul(b, 2246822519)); U32.and(U32.xor(U32.shrn(h1, 16n), U32.xor(h1, U32.add(U32.shln(k, 4n), op))), 1023))
def cse_match_ent(e: CseEnt, +k: U32, +op: U32, +a: U32, +b: U32) -> U32:
  match e:
    case CseNone{}: 0
    case CseSome{ek, eop, ea, eb, dst}: Bool.pick(U32, Bool.and(U32.is_eq(ek, k), Bool.and(U32.is_eq(eop, op), Bool.and(U32.is_eq(ea, a), U32.is_eq(eb, b)))), U32.add(dst, 1), 0)
def cse_is_comm(+bop: U32) -> Bool: Bool.or(U32.is_eq(bop, 0), Bool.or(U32.is_eq(bop, 2), Bool.or(U32.is_eq(bop, 5), Bool.or(U32.is_eq(bop, 6), Bool.or(U32.is_eq(bop, 7), Bool.or(U32.is_eq(bop, 10), U32.is_eq(bop, 12)))))))
type DomCse is Data:
  DomCse{csem: RaVec<CseEnt>, cnt: U32}
type CpOpsRes is Data:
  CpOpsRes{ops: List<&2, IrOp>, cm: U32Map, dc: DomCse}
def opt_um_dec(+m: U32Map, +k: U32) -> U32Map: (+v = um_get(m, k); Bool.pick(U32Map, U32.is_zero(v), m, um_set(m, k, U32.sub(v, 1))))
def opt_dec_op_dsts(op: IrOp, +m: U32Map) -> U32Map:
  match op:
    case IKeep{+d, +s}: Bool.pick(U32Map, U32.is_eq(d, s), m, opt_um_dec(m, d))
    case o: opt_ra_vs(RADec{}, opt_op_dsts(o), m)
def opt_cp_bdefs(ops: List<&2, IrOp>, m: U32Map) -> U32Map: opt_foldl0(~IrOp, ~U32Map, ~(op => a => opt_op_defs(op, a)), ops, m)
type CpSt is Data:
  CpSt{cm: U32Map, bdef: U32Map, csem: RaVec<CseEnt>, dcsem: RaVec<CseEnt>, ccnt: U32, acc: List<&2, IrOp>}
def opt_cp_cse_miss(+defc: U32Map, +ar: U32, +h: U32, +k: U32, +op: U32, +a: U32, +b: U32, +d: U32, orig_op: IrOp, ok_ops: Bool, cm: U32Map, bdef: U32Map, csem: RaVec<CseEnt>, dcsem: RaVec<CseEnt>, +ccnt: U32, acc: List<&2, IrOp>) -> CpSt:
  +can_ins = Bool.and(ok_ops, opt_cp_can_prop(defc, ar, d))
  +is_dom_op = Bool.or(Bool.and(U32.is_eq(k, 4), Bool.or(U32.is_eq(op, 5), Bool.or(U32.is_eq(op, 9), U32.is_eq(op, 2)))), U32.is_eq(k, 5))
  +d_ok = Bool.and(can_ins, Bool.or(U32.is_eq(k, 1), Bool.and(U32.is_lt(ccnt, 6), is_dom_op)))
  CpSt{um_set(cm, d, 0), opt_um_dec(bdef, d), opt_rv_put(CseEnt, can_ins, 5n, h, CseSome{k, op, a, b, d}, csem), opt_rv_put(CseEnt, d_ok, 5n, h, CseSome{k, op, a, b, d}, dcsem), Bool.pick(U32, Bool.and(d_ok, is_dom_op), U32.add(ccnt, 1), ccnt), Con{orig_op, acc}}
def opt_cp_cse_step(+defc: U32Map, +ar: U32, +k: U32, +op: U32, +a: U32, +b: U32, +d: U32, +orig_op: IrOp, +ok_ops: Bool, +cm: U32Map, +bdef: U32Map, +csem: RaVec<CseEnt>, +dcsem: RaVec<CseEnt>, +ccnt: U32, +acc: List<&2, IrOp>) -> CpSt: (+h = cse_hash(k, op, a, b); +hit = cse_match_ent(ra_vec_get(CseEnt, 5n, CseNone{}, h, csem), k, op, a, b); +rs = U32.sub(hit, 1); low_if(CpSt, U32.is_ne(hit, 0), _ => (+bd1 = opt_um_dec(bdef, d); CpSt{Bool.pick(U32Map, Bool.and(U32.is_ne(d, rs), Bool.or(opt_cp_can_prop(defc, ar, rs), U32.is_zero(um_get(bd1, rs)))), um_set(cm, d, hit), um_set(cm, d, 0)), bd1, csem, dcsem, ccnt, Bool.pick(List<&2, IrOp>, U32.is_eq(d, rs), acc, Con{ICopy{d, rs}, acc})}), _ => opt_cp_cse_miss(defc, ar, h, k, op, a, b, d, orig_op, ok_ops, cm, bdef, csem, dcsem, ccnt, acc)))
def opt_cp_ops(+defc: U32Map, +ar: U32, ops: List<&2, IrOp>, st: CpSt) -> CpOpsRes:
  match ops st:
    case Nil{} CpSt{cm, _, _, dcsem, ccnt, acc}: CpOpsRes{b5k_list_rev(IrOp, acc), cm, DomCse{dcsem, ccnt}}
    case Con{ICopy{+d, s}, t} CpSt{+cm0, bdef, csem, dcsem, ccnt, +acc}: (+rs = opt_um_lookup_or(cm0, s); +bd1 = opt_um_dec(bdef, d); opt_cp_ops(defc, ar, t, CpSt{Bool.pick(U32Map, Bool.and(U32.is_ne(d, rs), Bool.or(opt_cp_can_prop(defc, ar, rs), U32.is_zero(um_get(bd1, rs)))), um_set(cm0, d, U32.add(rs, 1)), um_set(cm0, d, 0)), bd1, csem, dcsem, ccnt, Bool.pick(List<&2, IrOp>, U32.is_eq(d, rs), acc, Con{ICopy{d, rs}, acc})}))
    case Con{IConst{+d, +v}, t} CpSt{cm, bdef, csem, dcsem, ccnt, acc}: opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 1, 0, v, 0, d, IConst{d, v}, True{}, cm, bdef, csem, dcsem, ccnt, acc))
    case Con{IFlt{+d, +bits}, t} CpSt{cm, bdef, csem, dcsem, ccnt, acc}: opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 2, 0, bits, 0, d, IFlt{d, bits}, True{}, cm, bdef, csem, dcsem, ccnt, acc))
    case Con{IUn{+d, +uop, s}, t} CpSt{+cm0, bdef, csem, dcsem, ccnt, acc}: (+rs = opt_um_lookup_or(cm0, s); opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 3, uop, rs, 0, d, IUn{d, uop, rs}, opt_cp_can_prop(defc, ar, rs), cm0, bdef, csem, dcsem, ccnt, acc)))
    case Con{IBin{+d, +bop, a, b}, t} CpSt{+cm0, bdef, csem, dcsem, ccnt, acc}: (+ra = opt_um_lookup_or(cm0, a); +rb = opt_um_lookup_or(cm0, b); +comm = cse_is_comm(bop); opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 4, bop, Bool.pick(U32, comm, U32.min(ra, rb), ra), Bool.pick(U32, comm, U32.max(ra, rb), rb), d, IBin{d, bop, ra, rb}, Bool.and(opt_cp_can_prop(defc, ar, ra), opt_cp_can_prop(defc, ar, rb)), cm0, bdef, csem, dcsem, ccnt, acc)))
    case Con{ICmp{+d, +cop, a, b}, t} CpSt{+cm0, bdef, csem, dcsem, ccnt, acc}: (+ra = opt_um_lookup_or(cm0, a); +rb = opt_um_lookup_or(cm0, b); +comm = U32.is_le(cop, 1); opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 5, cop, Bool.pick(U32, comm, U32.min(ra, rb), ra), Bool.pick(U32, comm, U32.max(ra, rb), rb), d, ICmp{d, cop, ra, rb}, Bool.and(opt_cp_can_prop(defc, ar, ra), opt_cp_can_prop(defc, ar, rb)), cm0, bdef, csem, dcsem, ccnt, acc)))
    case Con{ITag{+d, s}, t} CpSt{+cm0, bdef, csem, dcsem, ccnt, acc}: (+rs = opt_um_lookup_or(cm0, s); opt_cp_ops(defc, ar, t, opt_cp_cse_step(defc, ar, 6, 0, rs, 0, d, ITag{d, rs}, opt_cp_can_prop(defc, ar, rs), cm0, bdef, csem, dcsem, ccnt, acc)))
    case Con{op, t} CpSt{+cm0, bdef, csem, dcsem, ccnt, acc}: (+op2 = opt_cp_rewrite_op(cm0, op); opt_cp_ops(defc, ar, t, CpSt{opt_kill_op_dsts(op2, cm0), opt_dec_op_dsts(op2, bdef), csem, dcsem, ccnt, Con{op2, acc}}))
def opt_jmp_tgts(blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{id, _, TJmp{tgt}}, t}: opt_jmp_tgts(t, um_set(m, id, U32.add(tgt, 1)))
    case Con{_, t}: opt_jmp_tgts(t, m)
def opt_cse_prop_term(+preds: U32Map, +jmps: U32Map, +id: U32, term: IrTerm, +dc: DomCse, +cmap: RaVec<DomCse>) -> RaVec<DomCse>:
  match term:
    case TJmp{+tgt}: opt_rv_put(DomCse, opt_is_sp(preds, id, tgt), 5n, tgt, dc, cmap)
    case TBr{_, +tb, +fb}: (+ok_t = opt_is_sp(preds, id, tb); +ok_f = opt_is_sp(preds, id, fb); +cm1 = opt_rv_put(DomCse, ok_f, 5n, fb, dc, opt_rv_put(DomCse, ok_t, 5n, tb, dc, cmap)); +jt = um_get(jmps, tb); +m = U32.sub(jt, 1); ok_m = Bool.and(ok_t, Bool.and(ok_f, Bool.and(U32.is_ne(tb, fb), Bool.and(U32.is_ne(jt, 0), Bool.and(U32.is_eq(jt, um_get(jmps, fb)), Bool.and(U32.is_lt(m, 1024), Bool.and(U32.is_ne(m, id), U32.is_eq(um_get(preds, m), 2)))))))); opt_rv_put(DomCse, ok_m, 5n, m, dc, cm1))
    case _: cmap

def opt_dce_ops(+uses: U32Map, ops: List<&2, IrOp>, acc: List<&2, IrOp>) -> List<&2, IrOp>: b5k_list_rev(IrOp, opt_foldl(~IrOp, ~U32Map, ~List<&2, IrOp>, ~(u => +op => +a => (+pd = opt_op_pure_dst(op); Bool.pick(List<&2, IrOp>, Bool.and(U32.is_ne(pd, 0), U32.is_zero(um_get(u, U32.sub(pd, 1)))), a, Con{op, a}))), uses, ops, acc))
type ReachStep is Data:
  ReachStep{m: U32Map, chg: Bool}
def opt_reach_mark(+m: U32Map, chg: Bool, +bid: U32) -> ReachStep: Bool.pick(ReachStep, U32.is_zero(um_get(m, bid)), ReachStep{um_set(m, bid, 1), True{}}, ReachStep{m, chg})
def opt_reach_mark_st(st: ReachStep, bid: U32) -> ReachStep:
  ReachStep{m, chg} = st
  opt_reach_mark(m, chg, bid)
def opt_reach_arms(arms: List<&2, IrSwitchArm>, st: ReachStep) -> ReachStep: opt_foldl0(~IrSwitchArm, ~ReachStep, ~(a => s => opt_un_arm(ReachStep, a, _ => tgt => opt_reach_mark_st(s, tgt))), arms, st)
def opt_reach_term(term: IrTerm, st: ReachStep) -> ReachStep:
  match term:
    case TJmp{tgt}: opt_reach_mark_st(st, tgt)
    case TBr{_, tb, fb}: opt_reach_mark_st(opt_reach_mark_st(st, tb), fb)
    case TSwitch{_, arms, db}: opt_reach_arms(arms, opt_reach_mark_st(st, db))
    case _: st
def opt_un_rs(-R: Type, st: ReachStep, k: U32Map -> Bool -> R) -> R:
  ReachStep{m, chg} = st
  k(m, chg)
def opt_reach_scan(blks: List<&2, IrBlock>, st: ReachStep) -> ReachStep: opt_fold_blks0(~ReachStep, ~(id => _ => term => s => opt_un_rs(ReachStep, s, +m => +chg => Bool.pick(ReachStep, U32.is_ne(um_get(m, id), 0), opt_reach_term(term, ReachStep{m, chg}), ReachStep{m, chg}))), blks, st)
def opt_reach_fix(fuel: Nat, +blks: List<&2, IrBlock>, st: ReachStep) -> U32Map:
  match fuel st:
    case 0n ReachStep{m, _}: m
    case _ ReachStep{m, False{}}: m
    case 1n+p ReachStep{m, True{}}: opt_reach_fix(p, blks, opt_reach_scan(blks, ReachStep{m, False{}}))
def opt_filter_reach(+reach: U32Map, blks: List<&2, IrBlock>) -> List<&2, IrBlock>: b5k_list_rev(IrBlock, opt_fold_blks(~U32Map, ~List<&2, IrBlock>, ~(r => +id => ops => term => +acc => Bool.pick(List<&2, IrBlock>, U32.is_ne(um_get(r, id), 0), Con{IrBlock{id, ops, term}, acc}, acc)), reach, blks, Nil{}))
def opt_elim_unreach(+blks: List<&2, IrBlock>) -> List<&2, IrBlock>: opt_filter_reach(opt_reach_fix(U32.to_nat(b5k_list_len(IrBlock, blks)), blks, ReachStep{um_set(UM0{}, 0, 1), True{}}), blks)
# Single-Predecessor Block Merger
def opt_index_blks(blks: List<&2, IrBlock>, m: RaVec<Maybe<&2, IrBlock>>) -> RaVec<Maybe<&2, IrBlock>>: opt_foldl0(~IrBlock, ~RaVec<Maybe<&2, IrBlock>>, ~(b => acc => opt_un_blk(RaVec<Maybe<&2, IrBlock>>, b, id => ops => term => (+i = id; opt_rv_put(Maybe<&2, IrBlock>, U32.is_lt(i, 1024), 5n, i, Some{IrBlock{i, ops, term}}, acc)))), blks, m)
type MergeSt is Data:
  MergeSt{skip: U32Map, used: U32Map, acc: List<&2, IrBlock>}
def opt_merge_apply(mb: Maybe<&2, IrBlock>, +id: U32, ops: List<&2, IrOp>, +tgt: U32, sk0: U32Map, us0: U32Map, acc: List<&2, IrBlock>) -> MergeSt:
  match mb:
    case None{}: MergeSt{sk0, us0, Con{IrBlock{id, ops, TJmp{tgt}}, acc}}
    case Some{IrBlock{_, bops, bterm}}: MergeSt{um_set(sk0, tgt, 1), um_set(us0, id, 1), Con{IrBlock{id, b5k_list_app(IrOp, ops, bops), bterm}, acc}}
def opt_merge_one(skipped: Bool, +bmap: RaVec<Maybe<&2, IrBlock>>, +preds: U32Map, +id: U32, +ops: List<&2, IrOp>, term: IrTerm, +sk0: U32Map, +us0: U32Map, +acc: List<&2, IrBlock>) -> MergeSt:
  match skipped term:
    case True{} _: MergeSt{sk0, us0, acc}
    case False{} TJmp{+tgt}: (can = Bool.and(opt_is_sp(preds, id, tgt), Bool.and(U32.is_zero(um_get(sk0, tgt)), U32.is_zero(um_get(us0, tgt)))); low_if(MergeSt, can, _ => opt_merge_apply(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tgt, bmap), id, ops, tgt, sk0, us0, acc), _ => MergeSt{sk0, us0, Con{IrBlock{id, ops, TJmp{tgt}}, acc}}))
    case False{} other: MergeSt{sk0, us0, Con{IrBlock{id, ops, other}, acc}}
def opt_merge_go(+bmap: RaVec<Maybe<&2, IrBlock>>, +preds: U32Map, blks: List<&2, IrBlock>, st: MergeSt) -> List<&2, IrBlock>:
  match blks st:
    case Nil{} MergeSt{_, _, acc}: b5k_list_rev(IrBlock, acc)
    case Con{IrBlock{+id, ops, term}, t} MergeSt{+sk0, used, acc}: opt_merge_go(bmap, preds, t, opt_merge_one(U32.is_ne(um_get(sk0, id), 0), bmap, preds, id, ops, term, sk0, used, acc))
def opt_merge_n(k: Nat, +blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match k:
    case 0n: blks
    case 1n+p: opt_merge_n(p, opt_merge_go(opt_index_blks(blks, RVEmpty{}), opt_preds_init(blks), blks, MergeSt{UM0{}, UM0{}, Nil{}}))
def opt_stc_args(+orig: U32Map, args: List<&2, U32>, +idx: U32) -> List<&2, U32>:
  match args:
    case Nil{}: Nil{}
    case Con{+a, t}: Con{Bool.pick(U32, U32.is_eq(um_get(orig, a), U32.add(idx, 1)), idx, a), opt_stc_args(orig, t, U32.add(idx, 1))}
# Pass C — Deeper Multi-Block Inlining
type InlEntry is Data:
  InlEntry{fid: U32, arity: U32, nregs: U32, max_blk: U32, blks: List<&2, IrBlock>}
type InlBank is Data:
  InlBank{has: U32Map, trie: RaVec<Maybe<&2, InlEntry>>}
type FnMap is Data:
  FMLocal{small: Bool, ret_sc: U32Map, psc: U32Map}
  FMMid{}
  FMInl{loop_tc: Bool, sa_only: Bool, bud0: U32, bank: InlBank}
  FMWwCallee{pidx: U32Map, par: U32Map, pcid: U32Map}
  FMWwCaller{pidx: U32Map, par: U32Map, pcid: U32Map}
  FMSelMask{}
  FMFuseSink{}
  FMIdArm{}
  FMTcoLarge{}
  FMReuse{}
  FMJtRu{}
  FMEarlyExit{}
  FMTrmc{}
  FMHoBeta{cf: U32Map, cn: U32Map}
  FMMsroa{}
  FMCadt{}
  FMArrRmw{}
  FMLut{}
  FMStackArr{ret_sc: U32Map, psc: U32Map}
def opt_blks_op_count(blks: List<&2, IrBlock>, acc: U32) -> U32: opt_foldl0(~IrBlock, ~U32, ~(b => a => opt_un_blk(U32, b, _ => ops => _ => U32.add(a, b5k_list_len(IrOp, ops)))), blks, acc)
def opt_blks_max_id(blks: List<&2, IrBlock>, acc: U32) -> U32: opt_foldl0(~IrBlock, ~U32, ~(b => a => opt_un_blk(U32, b, id => _ => _ => U32.max(a, id))), blks, acc)
def opt_fn_mark_calls_ops(ops: List<&2, IrOp>, st: ReachStep) -> ReachStep:
  match ops st:
    case Nil{} _: st
    case Con{ICallDirect{_, cfid, _}, t} ReachStep{m, chg}: opt_fn_mark_calls_ops(t, opt_reach_mark(m, chg, cfid))
    case Con{ICallClosure{_, cfid, _}, t} ReachStep{m, chg}: opt_fn_mark_calls_ops(t, opt_reach_mark(m, chg, cfid))
    case Con{_, t} _: opt_fn_mark_calls_ops(t, st)
def opt_fn_reach_init(fns: List<&2, IrFn>, m: U32Map) -> U32Map: opt_foldl0(~IrFn, ~U32Map, ~(f => acc => opt_un_fn(U32Map, f, fid => _ => _ => _ => esc => eff => is_m => _ => (+fi = fid; +ac = acc; Bool.pick(U32Map, Bool.or(U32.is_lt(fi, 3), Bool.or(esc, Bool.or(eff, is_m))), um_set(ac, fi, 1), ac)))), fns, m)
def opt_collect_put(ok: Bool, +fid: U32, ar: U32, nregs: U32, +blks: List<&2, IrBlock>, has: U32Map, tr: RaVec<Maybe<&2, InlEntry>>) -> InlBank:
  match ok:
    case False{}: InlBank{has, tr}
    case True{}: InlBank{um_set(has, fid, 1), ra_vec_set(Maybe<&2, InlEntry>, 6n, fid, Some{InlEntry{fid, ar, nregs, opt_blks_max_id(blks, 0), blks}}, tr)}
def opt_shift_arms(+bb: U32, arms: List<&2, IrSwitchArm>) -> List<&2, IrSwitchArm>: opt_mapl(~IrSwitchArm, ~U32, ~IrSwitchArm, ~(e => a => opt_un_arm(IrSwitchArm, a, tag => tgt => IrArm{tag, U32.add(e, tgt)})), bb, arms)
def opt_inl_emit_args(args: List<&2, U32>, +base: U32, +idx: U32, acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match args:
    case Nil{}: acc
    case Con{a, t}: opt_inl_emit_args(t, base, U32.add(idx, 1), Con{ICopy{U32.add(base, idx), a}, acc})
def opt_inl_emit_body(+base: U32, ops: List<&2, IrOp>, acc: List<&2, IrOp>) -> List<&2, IrOp>: opt_foldl(~IrOp, ~U32, ~List<&2, IrOp>, ~(e => op => a => Con{opt_rm_op(True{}, RMShift{e}, op), a}), base, ops, acc)
def opt_inl_stc_p(+p2: Bool, +bv: U32, +car: U32, +scr: U32, args: List<&2, U32>, +idx: U32, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match args:
    case Nil{}: acc
    case Con{+a, t}: (acc1 = Bool.pick(List<&2, IrOp>, p2, Bool.pick(List<&2, IrOp>, U32.is_eq(a, idx), acc, Con{ICopy{U32.add(bv, idx), Bool.pick(U32, U32.is_lt(a, car), U32.add(scr, idx), U32.add(bv, a))}, acc}), Bool.pick(List<&2, IrOp>, Bool.and(U32.is_ne(a, idx), U32.is_lt(a, car)), Con{ICopy{U32.add(scr, idx), U32.add(bv, a)}, acc}, acc)); opt_inl_stc_p(p2, bv, car, scr, t, U32.add(idx, 1), acc1))
type InlCur is Data:
  InlCur{cur_id: U32, ops_rev: List<&2, IrOp>, blks_rev: List<&2, IrBlock>, nr: U32, nb: U32, bud: U32}
# Pass E — N-Field Worker-Wrapper Unboxing (arity 2..4, IKeep aliases, loop-hoist)
def opt_u32_rep_app(xs: List<&2, U32>, +idx: U32, +cur: U32, +f0: U32, tail: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: tail
    case Con{v, t}: Con{Bool.pick(U32, U32.is_eq(cur, idx), f0, v), opt_u32_rep_app(t, idx, U32.add(cur, 1), f0, tail)}
def opt_ww_seq(n: Nat, +b: U32) -> List<&2, U32>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{b, opt_ww_seq(p, U32.add(b, 1))}
def opt_ww_tag_ops(+al: U32Map, ops: List<&2, IrOp>, +tgs: U32Map, +cmps: U32Map) -> U32Map:
  match ops:
    case Nil{}: cmps
    case Con{ITag{d, s}, t}: opt_ww_tag_ops(al, t, Bool.pick(U32Map, U32.is_ne(um_get(al, s), 0), um_set(tgs, d, 1), tgs), cmps)
    case Con{ICmp{d, _, a, b}, t}: opt_ww_tag_ops(al, t, tgs, Bool.pick(U32Map, Bool.or(U32.is_ne(um_get(tgs, a), 0), U32.is_ne(um_get(tgs, b), 0)), um_set(cmps, d, 1), cmps))
    case Con{_, t}: opt_ww_tag_ops(al, t, tgs, cmps)
def opt_ww_tag_tgts(+al: U32Map, blks: List<&2, IrBlock>, +m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, TBr{c, tb, _}}, t}: opt_ww_tag_tgts(al, t, Bool.pick(U32Map, U32.is_ne(um_get(opt_ww_tag_ops(al, ops, UM0{}, UM0{}), c), 0), um_set(m, tb, 1), m))
    case Con{_, t}: opt_ww_tag_tgts(al, t, m)
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
      WwScan{Bool.pick(U32Map, Bool.and(U32.is_ne(a, 0), Bool.not(ok)), um_set(bp, p, 1), bp), Bool.pick(U32Map, Bool.and(U32.is_ne(a, 0), ok), um_set(ta, p, k), ta), ht, hs, Bool.pick(U32Map, Bool.and(U32.is_ne(a, 0), Bool.and(ok, Bool.not(in_tag))), um_set(hr, p, 1), hr), hrt}
def opt_ww_scan_copy(+al: U32Map, +d: U32, +s: U32, st: WwScan) -> WwScan:
  match st:
    case WwScan{+bp, ta, ht, hs, hr, hrt}: (+as0 = um_get(al, s); WwScan{Bool.pick(U32Map, Bool.or(U32.is_zero(as0), Bool.or(U32.is_eq(d, s), U32.is_eq(um_get(al, d), as0))), bp, um_set(bp, U32.sub(as0, 1), 1)), ta, ht, hs, hr, hrt})
def opt_ww_scan_ops(+in_tag: Bool, +al: U32Map, ops: List<&2, IrOp>, st: WwScan) -> WwScan:
  match ops st:
    case Nil{} _: st
    case Con{ITake{ds, s}, t} _: opt_ww_scan_ops(in_tag, al, t, opt_ww_scan_take(in_tag, al, ds, s, st))
    case Con{ITag{_, s}, t} WwScan{bp, ta, +ht, hs, hr, hrt}: opt_ww_scan_ops(in_tag, al, t, WwScan{bp, ta, opt_ra_v(RABad{al}, s, ht), hs, hr, hrt})
    case Con{ISink{_}, t} _: opt_ww_scan_ops(in_tag, al, t, st)
    case Con{ICopy{d, s}, t} _: opt_ww_scan_ops(in_tag, al, t, opt_ww_scan_copy(al, d, s, st))
    case Con{IKeep{d, s}, t} _: opt_ww_scan_ops(in_tag, al, t, opt_ww_scan_copy(al, d, s, st))
    case Con{ICtor{_, _, fs}, t} WwScan{bp, ta, ht, hs, hr, hrt}: opt_ww_scan_ops(in_tag, al, t, WwScan{bp, ta, ht, hs, hr, opt_ra_vs(RABad{al}, fs, hrt)})
    case Con{op, t} WwScan{bp, ta, ht, hs, hr, hrt}: opt_ww_scan_ops(in_tag, al, t, WwScan{opt_op_uses_act(RABad{al}, op, bp), ta, ht, hs, hr, hrt})
def opt_ww_scan_self(+al: U32Map, args: List<&2, U32>, +idx: U32, st: WwScan) -> WwScan:
  match args st:
    case Nil{} _: st
    case Con{v, t} WwScan{+bp, ta, ht, +hs, hr, hrt}: (+a = um_get(al, v); +is_sp = U32.is_eq(a, U32.add(idx, 1)); opt_ww_scan_self(al, t, U32.add(idx, 1), WwScan{Bool.pick(U32Map, Bool.and(U32.is_ne(a, 0), Bool.not(is_sp)), um_set(bp, U32.sub(a, 1), 1), bp), ta, ht, Bool.pick(U32Map, is_sp, um_set(hs, idx, 1), hs), hr, hrt}))
def opt_ww_mark_cands(+fid: U32, +ar: U32, +defc: U32Map, st: WwScan, n: Nat, +idx: U32, +cm: U32Map) -> U32Map:
  match st n:
    case _ 0n: cm
    case WwScan{+bp, +ta, +ht, +hs, +hr, +hrt} 1n+p: (+k = um_get(ta, idx); ok = Bool.and(U32.is_zero(um_get(defc, idx)), Bool.and(U32.is_zero(um_get(bp, idx)), Bool.and(U32.is_ge(k, 2), Bool.and(U32.is_le(k, 8), U32.is_le(U32.add(ar, k), 28))))); +can_h = Bool.and(U32.is_zero(um_get(hrt, idx)), Bool.and(U32.is_ne(um_get(hs, idx), 0), U32.is_ne(um_get(hr, idx), 0))); is_rec = Bool.and(Bool.not(can_h), Bool.and(U32.is_zero(um_get(ht, idx)), U32.is_ne(um_get(hr, idx), 0))); code = U32.add(k, Bool.pick(U32, can_h, Bool.pick(U32, U32.is_ne(um_get(ht, idx), 0), 20, 10), Bool.pick(U32, is_rec, 30, 0))); opt_ww_mark_cands(fid, ar, defc, WwScan{bp, ta, ht, hs, hr, hrt}, p, U32.add(idx, 1), Bool.pick(U32Map, ok, um_set(cm, opt_pkey(fid, idx), code), cm)))
type WwCtorEnt is Data:
  WNone{}
  WSome{vreg: U32, cid: U32, ar: U32, fs: List<&2, U32>}
def opt_ww_obs_ent(pe: WwCtorEnt, +a: U32, +ck: U32, +k: U32, +obs: U32Map) -> U32Map:
  match pe:
    case WNone{}: (+cur = um_get(obs, k); +is_rec = U32.is_ge(ck, 30); +nv = Bool.pick(U32, is_rec, Bool.pick(U32, U32.is_zero(cur), 4294967292, cur), Bool.pick(U32, Bool.and(U32.is_ge(ck, 10), U32.is_ne(cur, 4294967295)), 4294967294, 4294967295)); um_set(obs, k, nv))
    case WSome{v, +cid, ar, _}: (+cur = um_get(obs, k); +is_rec = U32.is_ge(ck, 30); +fb = Bool.pick(U32, Bool.and(Bool.not(is_rec), Bool.and(U32.is_ge(ck, 10), U32.is_ne(cur, 4294967295))), 4294967294, 4294967295); +c1 = U32.add(cid, 1); um_set(obs, k, Bool.pick(U32, Bool.and(U32.is_eq(v, a), U32.is_eq(ar, U32.mod(ck, 10))), Bool.pick(U32, Bool.or(U32.is_zero(cur), U32.is_eq(cur, 4294967292)), c1, Bool.pick(U32, U32.is_eq(cur, c1), cur, fb)), fb)))
def opt_ww_obs_args(+sfid: U32, +cfid: U32, +cand: U32Map, +al: U32Map, +pc: RaVec<WwCtorEnt>, args: List<&2, U32>, +idx: U32, +obs: U32Map) -> U32Map:
  match args:
    case Nil{}: obs
    case Con{+a, t}: (+k = opt_pkey(cfid, idx); +ck = Bool.pick(U32, Bool.and(U32.is_lt(cfid, 2048), U32.is_lt(idx, 64)), um_get(cand, k), 0); chk = Bool.and(U32.is_ne(ck, 0), Bool.not(Bool.and(U32.is_eq(cfid, sfid), U32.is_eq(um_get(al, a), U32.add(idx, 1))))); opt_ww_obs_args(sfid, cfid, cand, al, pc, t, U32.add(idx, 1), Bool.pick(U32Map, chk, opt_ww_obs_ent(ra_vec_get(WwCtorEnt, 6n, WNone{}, a, pc), a, ck, k, obs), obs)))
type WwObsBlk is Data:
  WwObsBlk{pc: RaVec<WwCtorEnt>, obs: U32Map}
def opt_ww_obs_ops(+sfid: U32, +defc: U32Map, +uses: U32Map, +ar: U32, +al: U32Map, +cand: U32Map, +rc: U32Map, ops: List<&2, IrOp>, st: WwObsBlk) -> WwObsBlk:
  match ops st:
    case Nil{} _: st
    case Con{ICtor{+d, cid, +fs}, +t} WwObsBlk{pc, obs}: (+k = b5k_u32_list_len(fs); +su_d = Bool.and(U32.is_lt(d, 4095), Bool.and(U32.is_eq(um_get(defc, d), 1), U32.is_eq(um_get(uses, d), 1))); ok = Bool.and(U32.is_ge(k, 2), Bool.and(U32.is_le(k, 8), Bool.and(su_d, Bool.or(opt_all_can_prop(defc, ar, fs), opt_is_nil_ops(t))))); opt_ww_obs_ops(sfid, defc, uses, ar, al, cand, rc, t, WwObsBlk{opt_rv_put(WwCtorEnt, ok, 6n, d, WSome{d, cid, k, fs}, pc), obs}))
    case Con{ICallDirect{+d, +cfid, args}, t} WwObsBlk{+pc, obs}: (+re = um_get(rc, cfid); ok = Bool.and(U32.is_ne(re, 0), Bool.and(U32.is_lt(d, 4095), Bool.and(U32.is_eq(um_get(defc, d), 1), U32.is_eq(um_get(uses, d), 1)))); opt_ww_obs_ops(sfid, defc, uses, ar, al, cand, rc, t, WwObsBlk{opt_rv_put(WwCtorEnt, ok, 6n, d, WSome{d, U32.sub(U32.shrn(re, 4n), 1), U32.and(re, 15), Nil{}}, pc), opt_ww_obs_args(sfid, cfid, cand, al, pc, args, 0, obs)}))
    case Con{_, t} _: opt_ww_obs_ops(sfid, defc, uses, ar, al, cand, rc, t, st)
type WwPlan is Data:
  WwPlan{pidx: U32Map, par: U32Map, pcid: U32Map, any: Bool}
def opt_ww_pick_param(+fid: U32, +cand: U32Map, +obs: U32Map, n: Nat, +idx: U32, pl: WwPlan) -> WwPlan:
  match n pl:
    case 0n _: pl
    case 1n+p WwPlan{+pi, +pa, +pc, +any}: (+k = opt_pkey(fid, idx); +ck = um_get(cand, k); +c = um_get(obs, k); ok = Bool.and(U32.is_ne(ck, 0), Bool.and(U32.is_ne(c, 0), Bool.and(U32.is_ne(c, 4294967295), U32.is_ne(c, 4294967292)))); cinfo = Bool.pick(U32, U32.is_eq(c, 4294967294), Bool.pick(U32, U32.is_ge(ck, 20), 4294967294, 4294967293), c); Bool.pick(WwPlan, ok, WwPlan{um_set(pi, fid, U32.add(idx, 1)), um_set(pa, fid, U32.mod(ck, 10)), um_set(pc, fid, cinfo), True{}}, opt_ww_pick_param(fid, cand, obs, p, U32.add(idx, 1), WwPlan{pi, pa, pc, any})))
def opt_ww_build_plan(+bad_fn: U32Map, +cand: U32Map, +obs: U32Map, fns: List<&2, IrFn>, pl: WwPlan) -> WwPlan: opt_foldl3(~IrFn, ~U32Map, ~U32Map, ~U32Map, ~WwPlan, ~(bf => ca => ob => f => p0 => opt_un_fn(WwPlan, f, fid => _ => ar => _ => _ => _ => _ => _ => (+fi = fid; +a = ar; +p = p0; Bool.pick(WwPlan, Bool.and(U32.is_zero(um_get(bf, fi)), Bool.and(U32.is_ge(a, 1), U32.is_lt(a, 26))), opt_ww_pick_param(fi, ca, ob, U32.to_nat(a), 0, p), p)))), bad_fn, cand, obs, fns, pl)
type WwExSt is Data:
  WwExSt{ex: U32Map, nr: U32}
def opt_ww_alloc_ex_ops(+pi1: U32, +k1: U32, +al: U32Map, ops: List<&2, IrOp>, st: WwExSt) -> WwExSt:
  match ops st:
    case Nil{} _: st
    case Con{ICopy{+d, +s}, t} WwExSt{+ex, +nr}: (need = Bool.and(U32.is_ne(d, s), Bool.and(U32.is_eq(um_get(al, d), pi1), U32.is_zero(um_get(ex, d)))); opt_ww_alloc_ex_ops(pi1, k1, al, t, Bool.pick(WwExSt, need, WwExSt{um_set(ex, d, U32.add(nr, 1)), U32.add(nr, k1)}, WwExSt{ex, nr})))
    case Con{IKeep{+d, +s}, t} WwExSt{+ex, +nr}: (need = Bool.and(U32.is_ne(d, s), Bool.and(U32.is_eq(um_get(al, d), pi1), U32.is_zero(um_get(ex, d)))); opt_ww_alloc_ex_ops(pi1, k1, al, t, Bool.pick(WwExSt, need, WwExSt{um_set(ex, d, U32.add(nr, 1)), U32.add(nr, k1)}, WwExSt{ex, nr})))
    case Con{_, t} _: opt_ww_alloc_ex_ops(pi1, k1, al, t, st)
def opt_ww_alloc_ex_blks(+pi1: U32, +k1: U32, +al: U32Map, blks: List<&2, IrBlock>, st: WwExSt) -> WwExSt: opt_foldl3(~IrBlock, ~U32, ~U32, ~U32Map, ~WwExSt, ~(p => k => a => b => s => opt_un_blk(WwExSt, b, _ => ops => _ => opt_ww_alloc_ex_ops(p, k, a, ops, s))), pi1, k1, al, blks, st)
def opt_ww_fields(+v: U32, +ex: U32Map, +k1: U32) -> List<&2, U32>: Con{v, opt_ww_seq(U32.to_nat(k1), U32.sub(um_get(ex, v), 1))}
def opt_ww_emit_keeps(ds: List<&2, U32>, ss: List<&2, U32>, acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ds ss:
    case Con{d, dt} Con{s, st}: opt_ww_emit_keeps(dt, st, Con{IKeep{d, s}, acc})
    case _ _: acc
def opt_ww_rw_callee_op(+ar: U32, +pi1: U32, +k1: U32, +cinfo: U32, +al: U32Map, +ex: U32Map, op: IrOp, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match op:
    case ITake{+ds, +s}: Bool.pick(List<&2, IrOp>, U32.is_eq(um_get(al, s), pi1), sroa_emit_copies(ds, opt_ww_fields(s, ex, k1), acc), Con{ITake{ds, s}, acc})
    case ITag{+d, +s}: Con{Bool.pick(IrOp, U32.is_eq(um_get(al, s), pi1), Bool.pick(IrOp, U32.is_eq(cinfo, 4294967294), ICopy{d, U32.add(ar, k1)}, IConst{d, U32.sub(cinfo, 1)}), ITag{d, s}), acc}
    case ISink{+s}: Bool.pick(List<&2, IrOp>, U32.is_eq(um_get(al, s), pi1), sroa_emit_sinks(opt_ww_fields(s, ex, k1), acc), Con{ISink{s}, acc})
    case IKeep{+d, +s}: Bool.pick(List<&2, IrOp>, U32.is_eq(um_get(al, s), pi1), opt_ww_emit_keeps(opt_ww_fields(d, ex, k1), opt_ww_fields(s, ex, k1), acc), Con{IKeep{d, s}, acc})
    case ICopy{+d, +s}: Bool.pick(List<&2, IrOp>, U32.is_eq(um_get(al, s), pi1), sroa_emit_copies(opt_ww_fields(d, ex, k1), opt_ww_fields(s, ex, k1), acc), Con{ICopy{d, s}, acc})
    case other: Con{other, acc}
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
    case Con{+v, t}: (+hit = U32.is_eq(um_get(al, v), pi1); opt_ww_rw_ctor_cons(Bool.pick(U32, hit, nr, v), opt_ww_rw_ctor_fs(pi1, k1, cid, al, ex, t, Bool.pick(List<&2, IrOp>, hit, Con{ICtor{nr, cid, opt_ww_fields(v, ex, k1)}, orev}, orev), Bool.pick(U32, hit, U32.add(nr, 1), nr))))
def opt_ww_rw_ctor_fin(d: U32, c2: U32, r: WwFsRes) -> WwOpsRes:
  match r:
    case WwFsRes{fs2, orev2, nr2}: WwOpsRes{Con{ICtor{d, c2, fs2}, orev2}, nr2}
def opt_ww_rw_callee_ops(+ar: U32, +pi1: U32, +k1: U32, +cinfo: U32, +al: U32Map, +ex: U32Map, ops: List<&2, IrOp>, st: WwOpsRes) -> WwOpsRes:
  match ops st:
    case Nil{} _: st
    case Con{ICtor{d, c2, fs}, t} WwOpsRes{acc, nr}: opt_ww_rw_callee_ops(ar, pi1, k1, cinfo, al, ex, t, opt_ww_rw_ctor_fin(d, c2, opt_ww_rw_ctor_fs(pi1, k1, U32.sub(cinfo, 1), al, ex, fs, acc, nr)))
    case Con{op, t} WwOpsRes{acc, nr}: opt_ww_rw_callee_ops(ar, pi1, k1, cinfo, al, ex, t, WwOpsRes{opt_ww_rw_callee_op(ar, pi1, k1, cinfo, al, ex, op, acc), nr})
def opt_ww_rw_callee_tc(+ar: U32, +pi1: U32, +k1: U32, +cinfo: U32, +al: U32Map, +ex: U32Map, cfid: U32, +args: List<&2, U32>) -> IrTerm:
  +pi = U32.sub(pi1, 1)
  +a = low_nth(U32, U32.to_nat(pi), 4294967295, args)
  +tail0 = opt_ww_seq(U32.to_nat(k1), U32.sub(um_get(ex, a), 1))
  tail = Bool.pick(List<&2, U32>, U32.is_eq(cinfo, 4294967294), b5k_list_app(U32, tail0, Con{U32.add(ar, k1), Nil{}}), tail0)
  TTailCall{cfid, Bool.pick(List<&2, U32>, Bool.and(U32.is_ne(a, 4294967295), U32.is_eq(um_get(al, a), pi1)), opt_u32_rep_app(args, pi, 0, a, tail), args)}
def opt_rm_term(+rm: RegMap, term: IrTerm) -> IrTerm:
  match term:
    case TBr{c, tb, fb}: TBr{opt_rm_v(rm, c), tb, fb}
    case TSwitch{s, arms, db}: TSwitch{opt_rm_v(rm, s), arms, db}
    case TRet{v}: TRet{opt_rm_v(rm, v)}
    case TTailCall{fid, args}: TTailCall{fid, opt_rm_vs(rm, args)}
    case other: other
def opt_term_uses(term: IrTerm, m: U32Map) -> U32Map: opt_um_inc_list(opt_term_uses_list(term), m)
def opt_sc_all_rets(+self_fid: U32, +ret_sc: U32Map, +sc: U32Map, blks: List<&2, IrBlock>, has_ret: Bool) -> Bool:
  match blks:
    case Nil{}: has_ret
    case Con{IrBlock{_, _, TRet{rv}}, t}: Bool.and(U32.is_eq(um_get(sc, rv), 1), opt_sc_all_rets(self_fid, ret_sc, sc, t, True{}))
    case Con{IrBlock{_, _, TTailCall{+cfid, _}}, t}: (+is_other_sc = Bool.and(U32.is_ne(cfid, self_fid), U32.is_ne(um_get(ret_sc, cfid), 0)); Bool.and(Bool.or(U32.is_eq(cfid, self_fid), is_other_sc), opt_sc_all_rets(self_fid, ret_sc, sc, t, Bool.or(has_ret, is_other_sc))))
    case Con{_, t}: opt_sc_all_rets(self_fid, ret_sc, sc, t, has_ret)
def opt_cp_term(cm: U32Map, term: IrTerm) -> IrTerm: opt_rm_term(RMLookup{cm}, term)
def opt_un_cp(-R: Type, r: CpOpsRes, k: List<&2, IrOp> -> U32Map -> DomCse -> R) -> R:
  CpOpsRes{ops2, cm2, dc2} = r
  k(ops2, cm2, dc2)
def opt_un_dc(-R: Type, dc: DomCse, k: RaVec<CseEnt> -> U32 -> R) -> R:
  DomCse{cm, cnt} = dc
  k(cm, cnt)
def opt_cp_blks_dom(+defc: U32Map, +ar: U32, +gcm: U32Map, +preds: U32Map, +jmps: U32Map, blks: List<&2, IrBlock>, +cmap: RaVec<DomCse>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, +ops, +term}, t}: opt_un_dc(List<&2, IrBlock>, opt_rv_get(DomCse, DomCse{RVEmpty{}, 0}, id, cmap), cm0 => cnt0 => (+csem0 = cm0; opt_un_cp(List<&2, IrBlock>, opt_cp_ops(defc, ar, ops, CpSt{gcm, opt_cp_bdefs(ops, UM0{}), csem0, csem0, cnt0, Nil{}}), ops2 => cm2 => dc2 => Con{IrBlock{id, ops2, opt_cp_term(cm2, term)}, opt_cp_blks_dom(defc, ar, gcm, preds, jmps, t, opt_cse_prop_term(preds, jmps, id, term, dc2, cmap))})))
def opt_stc_ret_go(+id: U32, +self_fid: U32, rev: List<&2, IrOp>, +rv: U32) -> IrBlock:
  match rev:
    case Con{ICallDirect{+d, +cfid, +args}, +rest}: Bool.pick(IrBlock, Bool.and(U32.is_eq(d, rv), U32.is_eq(cfid, self_fid)), IrBlock{id, b5k_list_rev(IrOp, rest), TTailCall{cfid, args}}, IrBlock{id, b5k_list_rev(IrOp, Con{ICallDirect{d, cfid, args}, rest}), TRet{rv}})
    case r: IrBlock{id, b5k_list_rev(IrOp, r), TRet{rv}}
def opt_empty_blks(blks: List<&2, IrBlock>, m: RaVec<Maybe<&2, IrTerm>>) -> RaVec<Maybe<&2, IrTerm>>: opt_fold_blks0(~RaVec<Maybe<&2, IrTerm>>, ~(+id => ops => +tm => acc => opt_rv_put(Maybe<&2, IrTerm>, Bool.and(U32.is_lt(id, 1024), Bool.and(U32.is_zero(b5k_list_len(IrOp, ops)), U32.is_le(opt_term_tag(tm), 3))), 5n, id, Some{tm}, acc)), blks, m)
def opt_blks_has_bad(+leaf: Bool, +tc_ok: Bool, +fid: U32, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: False{}
    case Con{IrBlock{_, ops, TTailCall{cfid, _}}, t}: Bool.or(Bool.or(Bool.and(leaf, Bool.not(tc_ok)), U32.is_eq(cfid, fid)), Bool.or(Bool.not(opt_all_ops(OPNoCall{leaf, fid}, ops)), opt_blks_has_bad(leaf, tc_ok, fid, t)))
    case Con{IrBlock{_, ops, _}, t}: Bool.or(Bool.not(opt_all_ops(OPNoCall{leaf, fid}, ops)), opt_blks_has_bad(leaf, tc_ok, fid, t))
def opt_fn_mark_calls_blks(blks: List<&2, IrBlock>, st: ReachStep) -> ReachStep: opt_fold_blks0(~ReachStep, ~(_ => ops => tm => s => (+s1 = opt_fn_mark_calls_ops(ops, s); +cf = opt_term_tc_fid(tm); Bool.pick(ReachStep, U32.is_zero(cf), s1, opt_reach_mark_st(s1, U32.sub(cf, 1))))), blks, st)
def opt_fn_reach_scan(fns: List<&2, IrFn>, st: ReachStep) -> ReachStep: opt_foldl0(~IrFn, ~ReachStep, ~(f => s => opt_un_fn(ReachStep, f, fid => _ => _ => _ => _ => _ => _ => blks => opt_un_rs(ReachStep, s, +m => +chg => Bool.pick(ReachStep, U32.is_ne(um_get(m, fid), 0), opt_fn_mark_calls_blks(blks, ReachStep{m, chg}), ReachStep{m, chg})))), fns, st)
def opt_fn_reach_fix(fuel: Nat, +fns: List<&2, IrFn>, st: ReachStep) -> U32Map:
  match fuel st:
    case 0n ReachStep{m, _}: m
    case _ ReachStep{m, False{}}: m
    case 1n+p ReachStep{m, True{}}: opt_fn_reach_fix(p, fns, opt_fn_reach_scan(fns, ReachStep{m, False{}}))
def opt_fn_reach(+fns: List<&2, IrFn>) -> U32Map: opt_fn_reach_fix(32n, fns, ReachStep{opt_fn_reach_init(fns, UM0{}), True{}})
def opt_collect_inlines_go(+sc_only: Bool, +cc: U32Map, +leaf: Bool, +max_ops: U32, +max_blks: U32, fns: List<&2, IrFn>, bank: InlBank) -> InlBank:
  match fns bank:
    case Nil{} _: bank
    case Con{IrFn{+fid, _, +ar, +nregs, _, eff, is_m, +blks}, t} InlBank{+has, +tr}: (elig = Bool.and(U32.is_ge(fid, 3), Bool.and(Bool.not(eff), Bool.not(is_m))); b1 = low_if(InlBank, elig, _ => opt_collect_put(Bool.and(Bool.or(Bool.not(sc_only), U32.is_eq(um_get(cc, fid), 1)), Bool.and(U32.is_lt(fid, 2048), Bool.and(U32.is_le(nregs, Bool.pick(U32, sc_only, 640, 320)), Bool.and(U32.is_ge(b5k_list_len(IrBlock, blks), 1), Bool.and(U32.is_le(b5k_list_len(IrBlock, blks), max_blks), Bool.and(U32.is_le(opt_blks_op_count(blks, 0), max_ops), Bool.not(opt_blks_has_bad(leaf, sc_only, fid, blks)))))))), fid, ar, nregs, blks, has, tr), _ => InlBank{has, tr}); opt_collect_inlines_go(sc_only, cc, leaf, max_ops, max_blks, t, b1))
def opt_blks_self_tc_only(+allow_arr: Bool, +fid: U32, blks: List<&2, IrBlock>, has_tc: Bool) -> Bool:
  match blks:
    case Nil{}: has_tc
    case Con{IrBlock{_, ops, TTailCall{+cfid, _}}, t}: Bool.and(U32.is_eq(cfid, fid), Bool.and(opt_all_ops(OPPureStc{allow_arr}, ops), opt_blks_self_tc_only(allow_arr, fid, t, True{})))
    case Con{IrBlock{_, ops, _}, t}: Bool.and(opt_all_ops(OPPureStc{allow_arr}, ops), opt_blks_self_tc_only(allow_arr, fid, t, has_tc))
def opt_collect_self_tc_go(+en_arr: Bool, +cc: U32Map, fns: List<&2, IrFn>, bank: InlBank) -> InlBank:
  match fns bank:
    case Nil{} _: bank
    case Con{IrFn{+fid, _, +ar, +nregs, _, eff, is_m, +blks}, t} InlBank{+has, +tr}: (elig = Bool.and(U32.is_ge(fid, 3), Bool.and(Bool.not(eff), Bool.not(is_m))); +cc_f = um_get(cc, fid); +hot1 = Bool.and(en_arr, Bool.and(U32.is_ge(cc_f, 1), U32.is_le(cc_f, 8))); +max_ar = Bool.pick(U32, hot1, 12, 8); +max_bk = Bool.pick(U32, hot1, 14, 6); +max_op = Bool.pick(U32, hot1, 96, 36); +allow_arr = Bool.and(en_arr, Bool.and(U32.is_le(cc_f, 8), Bool.and(U32.is_le(ar, Bool.pick(U32, hot1, 12, 6)), Bool.not(opt_all_blks_ops(OPNoArrOp{}, blks))))); +max_nr = Bool.pick(U32, allow_arr, 512, Bool.pick(U32, hot1, 128, 48)); b1 = low_if(InlBank, Bool.and(elig, Bool.or(Bool.not(en_arr), allow_arr)), _ => opt_collect_put(Bool.and(U32.is_lt(fid, 2048), Bool.and(U32.is_le(ar, max_ar), Bool.and(U32.is_le(nregs, max_nr), Bool.and(U32.is_ge(b5k_list_len(IrBlock, blks), 1), Bool.and(U32.is_le(b5k_list_len(IrBlock, blks), max_bk), Bool.and(U32.is_le(opt_blks_op_count(blks, 0), max_op), opt_blks_self_tc_only(allow_arr, fid, blks, False{}))))))), fid, ar, nregs, blks, has, tr), _ => InlBank{has, tr}); opt_collect_self_tc_go(en_arr, cc, t, b1))
def opt_remap_tc(is_self: Bool, is_tail: Bool, +bv: U32, +bb: U32, +car: U32, +scr: U32, +dst: U32, +cont: U32, id: U32, ops: List<&2, IrOp>, cfid: U32, +args: List<&2, U32>) -> IrBlock:
  match is_self is_tail:
    case True{} _: IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_stc_p(True{}, bv, car, scr, args, 0, opt_inl_stc_p(False{}, bv, car, scr, args, 0, opt_inl_emit_body(bv, ops, Nil{})))), TJmp{bb}}
    case False{} True{}: IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TTailCall{cfid, opt_shift_u32(bv, args)}}
    case False{} False{}: IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, Con{ICallDirect{dst, cfid, opt_shift_u32(bv, args)}, opt_inl_emit_body(bv, ops, Nil{})}), TJmp{cont}}
def opt_remap_one_blk(is_tail: Bool, +loop_tc: Bool, +callee: U32, +car: U32, +scr: U32, +bv: U32, +bb: U32, +dst: U32, +cont: U32, blk: IrBlock) -> IrBlock:
  match is_tail blk:
    case True{} IrBlock{id, ops, TRet{rv}}: IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TRet{U32.add(bv, rv)}}
    case False{} IrBlock{id, ops, TRet{rv}}: IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, Con{ICopy{dst, U32.add(bv, rv)}, opt_inl_emit_body(bv, ops, Nil{})}), TJmp{cont}}
    case _ IrBlock{id, ops, TTailCall{+cfid, +args}}: opt_remap_tc(Bool.and(loop_tc, Bool.and(U32.is_eq(cfid, callee), U32.is_eq(b5k_u32_list_len(args), car))), is_tail, bv, bb, car, scr, dst, cont, id, ops, cfid, args)
    case _ IrBlock{id, ops, TJmp{tgt}}: IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TJmp{U32.add(bb, tgt)}}
    case _ IrBlock{id, ops, TBr{c, tb, fb}}: IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TBr{U32.add(bv, c), U32.add(bb, tb), U32.add(bb, fb)}}
    case _ IrBlock{id, ops, TSwitch{s, arms, db}}: IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TSwitch{U32.add(bv, s), opt_shift_arms(bb, arms), U32.add(bb, db)}}
    case _ IrBlock{id, ops, TFail{c}}: IrBlock{U32.add(bb, id), b5k_list_rev(IrOp, opt_inl_emit_body(bv, ops, Nil{})), TFail{c}}
def opt_remap_blks(+is_tail: Bool, +loop_tc: Bool, +callee: U32, +car: U32, +scr: U32, +bv: U32, +bb: U32, +dst: U32, +cont: U32, blks: List<&2, IrBlock>, acc: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: acc
    case Con{b, t}: opt_remap_blks(is_tail, loop_tc, callee, car, scr, bv, bb, dst, cont, t, Con{opt_remap_one_blk(is_tail, loop_tc, callee, car, scr, bv, bb, dst, cont, b), acc})
def opt_inl_call_body(ok: Bool, +loop_tc: Bool, +car: U32, +cnr: U32, +cmb: U32, cblks: List<&2, IrBlock>, +d: U32, +cfid: U32, +args: List<&2, U32>, +cid: U32, +orev: List<&2, IrOp>, +brev: List<&2, IrBlock>, +nr: U32, +nb: U32, +bud: U32) -> InlCur:
  match ok cblks:
    case False{} _: InlCur{cid, Con{ICallDirect{d, cfid, args}, orev}, brev, nr, nb, bud}
    case True{} Con{IrBlock{_, cops, TRet{+rv}}, Nil{}}: (a2 = opt_inl_emit_body(nr, cops, opt_inl_emit_args(args, nr, 0, orev)); InlCur{cid, Con{ICopy{d, U32.add(nr, rv)}, a2}, brev, U32.add(nr, U32.max(cnr, U32.max(car, U32.add(rv, 1)))), nb, U32.sub(bud, 1)})
    case True{} cblks0:
      +scr = U32.add(nr, U32.max(cnr, U32.max(car, 1)))
      +cont = U32.add(nb, U32.add(cmb, 1))
      brev1 = opt_remap_blks(False{}, loop_tc, cfid, car, scr, nr, nb, d, cont, cblks0, Con{IrBlock{cid, b5k_list_rev(IrOp, opt_inl_emit_args(args, nr, 0, orev)), TJmp{nb}}, brev})
      InlCur{cont, Nil{}, brev1, Bool.pick(U32, loop_tc, U32.add(scr, car), scr), U32.add(cont, 1), U32.sub(bud, 1)}
def opt_inl_call_apply(+loop_tc: Bool, me: Maybe<&2, InlEntry>, d: U32, cfid: U32, +args: List<&2, U32>, st: InlCur) -> InlCur:
  match me st:
    case None{} InlCur{cid, orev, brev, nr, nb, bud}: InlCur{cid, Con{ICallDirect{d, cfid, args}, orev}, brev, nr, nb, bud}
    case Some{InlEntry{_, +car, cnr, cmb, cblks}} InlCur{cid, orev, brev, nr, nb, bud}: opt_inl_call_body(U32.is_eq(b5k_u32_list_len(args), car), loop_tc, car, cnr, cmb, cblks, d, cfid, args, cid, orev, brev, nr, nb, bud)
def opt_inl_ops(+loop_tc: Bool, +self_fid: U32, +has: U32Map, +tr: RaVec<Maybe<&2, InlEntry>>, ops: List<&2, IrOp>, st: InlCur) -> InlCur:
  match ops st:
    case Nil{} _: st
    case Con{ICallDirect{+d, +cfid, +args}, t} InlCur{+cid, +orev, +brev, +nr, +nb, +bud}: (can = Bool.and(U32.is_ne(cfid, self_fid), Bool.and(U32.is_gt(bud, 0), Bool.and(U32.is_lt(nr, 4096), Bool.and(U32.is_lt(nb, Bool.pick(U32, loop_tc, 1024, 512)), U32.is_ne(um_get(has, cfid), 0))))); st1 = low_if(InlCur, can, _ => opt_inl_call_apply(loop_tc, ra_vec_get(Maybe<&2, InlEntry>, 6n, None{}, cfid, tr), d, cfid, args, InlCur{cid, orev, brev, nr, nb, bud}), _ => InlCur{cid, Con{ICallDirect{d, cfid, args}, orev}, brev, nr, nb, bud}); opt_inl_ops(loop_tc, self_fid, has, tr, t, st1))
    case Con{op, t} InlCur{cid, orev, brev, nr, nb, bud}: opt_inl_ops(loop_tc, self_fid, has, tr, t, InlCur{cid, Con{op, orev}, brev, nr, nb, bud})
def opt_inl_tail_apply(+loop_tc: Bool, me: Maybe<&2, InlEntry>, +cfid: U32, +args: List<&2, U32>, st: InlCur) -> InlCur:
  match me st:
    case Some{InlEntry{_, +car, +cnr, +cmb, +cblks}} InlCur{+cid, +orev, +brev, +nr, +nb, +bud}: (+scr = U32.add(nr, U32.max(cnr, U32.max(car, 1))); low_if(InlCur, U32.is_eq(b5k_u32_list_len(args), car), _ => InlCur{cid, Nil{}, opt_remap_blks(True{}, loop_tc, cfid, car, scr, nr, nb, 0, 0, cblks, Con{IrBlock{cid, b5k_list_rev(IrOp, opt_inl_emit_args(args, nr, 0, orev)), TJmp{nb}}, brev}), Bool.pick(U32, loop_tc, U32.add(scr, car), scr), U32.add(nb, U32.add(cmb, 1)), U32.sub(bud, 1)}, _ => InlCur{cid, Nil{}, Con{IrBlock{cid, b5k_list_rev(IrOp, orev), TTailCall{cfid, args}}, brev}, nr, nb, bud}))
    case None{} InlCur{+cid, orev, brev, nr, nb, bud}: InlCur{cid, Nil{}, Con{IrBlock{cid, b5k_list_rev(IrOp, orev), TTailCall{cfid, args}}, brev}, nr, nb, bud}
def opt_inl_fin_term(+loop_tc: Bool, +self_fid: U32, +has: U32Map, +tr: RaVec<Maybe<&2, InlEntry>>, term: IrTerm, st: InlCur) -> InlCur:
  match term st:
    case TTailCall{+cfid, +args} InlCur{+cid, +orev, +brev, +nr, +nb, +bud}: (can = Bool.and(U32.is_ne(cfid, self_fid), Bool.and(U32.is_gt(bud, 0), Bool.and(U32.is_lt(nr, 2048), Bool.and(U32.is_lt(nb, 256), U32.is_ne(um_get(has, cfid), 0))))); low_if(InlCur, can, _ => opt_inl_tail_apply(loop_tc, ra_vec_get(Maybe<&2, InlEntry>, 6n, None{}, cfid, tr), cfid, args, InlCur{cid, orev, brev, nr, nb, bud}), _ => InlCur{cid, Nil{}, Con{IrBlock{cid, b5k_list_rev(IrOp, orev), TTailCall{cfid, args}}, brev}, nr, nb, bud}))
    case other InlCur{+cid, orev, brev, nr, nb, bud}: InlCur{cid, Nil{}, Con{IrBlock{cid, b5k_list_rev(IrOp, orev), other}, brev}, nr, nb, bud}
def opt_inl_blks(+loop_tc: Bool, +self_fid: U32, +has: U32Map, +tr: RaVec<Maybe<&2, InlEntry>>, blks: List<&2, IrBlock>, st: InlCur) -> CfBlksRes:
  match blks st:
    case Nil{} InlCur{_, _, brev, nr, _, _}: CfBlksRes{b5k_list_rev(IrBlock, brev), nr}
    case Con{IrBlock{id, ops, term}, t} InlCur{_, _, brev, nr, nb, bud}: opt_inl_blks(loop_tc, self_fid, has, tr, t, opt_inl_fin_term(loop_tc, self_fid, has, tr, term, opt_inl_ops(loop_tc, self_fid, has, tr, ops, InlCur{id, Nil{}, brev, nr, nb, bud})))
def opt_sa_caller_ops(+has: U32Map, ops: List<&2, IrOp>, st: U32) -> U32:
  match ops:
    case Nil{}: st
    case Con{IArrOp{_, 71, _}, t}: opt_sa_caller_ops(has, t, 2)
    case Con{ICallDirect{_, cfid, _}, t}: Bool.pick(U32, U32.is_ne(um_get(has, cfid), 0), opt_sa_caller_ops(has, t, st), 0)
    case Con{ICallClosure{_, _, _}, _}: 0
    case Con{IApply{_, _, _}, _}: 0
    case Con{_, t}: opt_sa_caller_ops(has, t, st)
def opt_sa_caller_term(+has: U32Map, term: IrTerm) -> Bool:
  match term:
    case TTailCall{tfid, _}: U32.is_ne(um_get(has, tfid), 0)
    case _: True{}
def opt_sa_caller_ok(+has: U32Map, blks: List<&2, IrBlock>, st: U32) -> Bool:
  match blks:
    case Nil{}: U32.is_eq(st, 2)
    case Con{IrBlock{_, ops, term}, t}: (+s1 = Bool.pick(U32, opt_sa_caller_term(has, term), opt_sa_caller_ops(has, ops, st), 0); Bool.and(U32.is_ne(s1, 0), opt_sa_caller_ok(has, t, s1)))
def opt_stc_is_pass(+aop: U32) -> Bool:
  Bool.or(
    Bool.and(U32.is_ge(aop, 72), U32.is_le(aop, 75)),
    Bool.and(U32.is_ge(aop, 79), U32.is_le(aop, 81)),
  )
def opt_stc_is_use(+aop: U32) -> Bool:
  Bool.or(
    Bool.and(U32.is_ge(aop, 72), U32.is_le(aop, 74)),
    Bool.and(U32.is_ge(aop, 78), U32.is_le(aop, 81)),
  )
def opt_stc_mark_ds(ds: List<&2, U32>, +v: U32, org: U32Map) -> U32Map:
  match ds:
    case Nil{}: org
    case Con{d, t}: opt_stc_mark_ds(t, v, um_set(org, d, v))
def opt_stc_org_op(+has: U32Map, op: IrOp, +org: U32Map) -> U32Map:
  match op:
    case ICopy{d, s}: um_set(org, d, um_get(org, s))
    case IArrOp{Con{da, _}, +aop, Con{a, _}}:
      Bool.pick(U32Map, opt_stc_is_pass(aop), um_set(org, da, um_get(org, a)), org)
    case ICallDirect{d, cfid, _}:
      Bool.pick(U32Map, U32.is_ne(um_get(has, cfid), 0), um_set(org, d, 131072), org)
    case ITake{ds, s}:
      Bool.pick(U32Map, U32.is_eq(um_get(org, s), 131072), opt_stc_mark_ds(ds, 131072, org), org)
    case _: org
def opt_stc_org_blks(+has: U32Map, blks: List<&2, IrBlock>, org: U32Map) -> U32Map:
  match blks:
    case Nil{}: org
    case Con{IrBlock{_, ops, _}, t}:
      o1 = opt_foldl(~IrOp, ~U32Map, ~U32Map, ~(h => op => o => opt_stc_org_op(h, op, o)), has, ops, org)
      opt_stc_org_blks(has, t, o1)
def opt_stc_build_org(+has: U32Map, +ar: U32, +blks: List<&2, IrBlock>) -> U32Map:
  +o0 = opt_ip_init_orig(U32.to_nat(ar), 0, UM0{})
  opt_stc_org_blks(has, blks, opt_stc_org_blks(has, blks, o0))
def opt_stc_apm_op(+org: U32Map, +ar: U32, op: IrOp, +m: U32) -> U32:
  match op:
    case IArrOp{_, +aop, Con{a, _}}:
      +ao = um_get(org, a)
      +ok = Bool.and(
        opt_stc_is_use(aop),
        Bool.and(U32.is_gt(ao, 0), Bool.and(U32.is_le(ao, ar), U32.is_le(ao, 31))),
      )
      Bool.pick(U32, ok, U32.or(m, U32.shln(1, U32.to_nat(U32.sub(ao, 1)))), m)
    case _: m
def opt_stc_apm_blks(+org: U32Map, +ar: U32, blks: List<&2, IrBlock>, +m: U32) -> U32:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, _}, t}:
      m1 = opt_foldl2(~IrOp, ~U32Map, ~U32, ~U32, ~(o => a => op => k => opt_stc_apm_op(o, a, op, k)), org, ar, ops, m)
      opt_stc_apm_blks(org, ar, t, m1)
def opt_stc_callee_apm(me: Maybe<&2, InlEntry>) -> U32:
  match me:
    case Some{InlEntry{_, +car, _, _, +cblks}}:
      opt_stc_apm_blks(opt_stc_build_org(UM0{}, car, cblks), car, cblks, 0)
    case None{}: 0
def opt_stc_args_hoist(+corg: U32Map, +car: U32, +apm: U32, args: List<&2, U32>, +idx: U32, +am: U32) -> U32:
  match args:
    case Nil{}: am
    case Con{+a, t}:
      +need = Bool.and(U32.is_lt(idx, 31), U32.is_ne(U32.and(apm, U32.shln(1, U32.to_nat(idx))), 0))
      +ao = um_get(corg, a)
      +is_p = Bool.and(U32.is_gt(ao, 0), Bool.and(U32.is_le(ao, car), U32.is_le(ao, 31)))
      +bit = U32.shln(1, U32.to_nat(U32.sub(ao, 1)))
      +am_p = Bool.pick(U32, is_p, U32.or(am, bit), Bool.pick(U32, U32.is_eq(ao, 131072), am, 4294967295))
      +am1 = Bool.pick(U32, need, am_p, am)
      Bool.pick(
        U32,
        U32.is_eq(am1, 4294967295),
        4294967295,
        opt_stc_args_hoist(corg, car, apm, t, U32.add(idx, 1), am1),
      )
def opt_popcnt32(n: Nat, +m: U32, +acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: opt_popcnt32(p, U32.shrn(m, 1n), U32.add(acc, U32.and(m, 1)))
type StcScan is Data:
  StcScan{mask: U32, am: U32, nc: U32}
def opt_stc_call_op(
  +has: U32Map, +tr: RaVec<Maybe<&2, InlEntry>>, +corg: U32Map, +car: U32, op: IrOp, st: StcScan
) -> StcScan:
  match op st:
    case ICallDirect{_, +cfid, +args} StcScan{+m, +am, +nc}:
      +in_h = U32.is_ne(um_get(has, cfid), 0)
      +apm = Bool.pick(U32, in_h, opt_stc_callee_apm(ra_vec_get(Maybe<&2, InlEntry>, 6n, None{}, cfid, tr)), 0)
      +am1 = Bool.pick(U32, in_h, opt_stc_args_hoist(corg, car, apm, args, 0, am), 4294967295)
      +bad = Bool.or(Bool.not(in_h), U32.is_eq(am1, 4294967295))
      StcScan{Bool.pick(U32, bad, U32.or(m, 8), U32.or(m, 1)), Bool.pick(U32, bad, am, am1), U32.add(nc, 1)}
    case IArrOp{_, +aop, Con{a, _}} StcScan{+m, +am, nc}:
      +ao = um_get(corg, a)
      +ok = Bool.and(
        opt_stc_is_use(aop),
        Bool.and(U32.is_gt(ao, 0), Bool.and(U32.is_le(ao, car), U32.is_le(ao, 31))),
      )
      StcScan{m, Bool.pick(U32, ok, U32.or(am, U32.shln(1, U32.to_nat(U32.sub(ao, 1)))), am), nc}
    case IFlt{_, _} StcScan{m, am, nc}: StcScan{U32.or(m, 8), am, nc}
    case IBin{_, +bop, _, _} StcScan{+m, am, nc}:
      StcScan{Bool.pick(U32, Bool.and(U32.is_ge(bop, 10), U32.is_le(bop, 13)), U32.or(m, 8), m), am, nc}
    case _ _: st
def opt_stc_scan_ops(
  +has: U32Map, +tr: RaVec<Maybe<&2, InlEntry>>, +corg: U32Map, +car: U32, ops: List<&2, IrOp>, st: StcScan
) -> StcScan:
  match ops:
    case Nil{}: st
    case Con{op, t}: opt_stc_scan_ops(has, tr, corg, car, t, opt_stc_call_op(has, tr, corg, car, op, st))
def opt_stc_scan_term(+fid: U32, term: IrTerm, st: StcScan) -> StcScan:
  StcScan{+m1, am1, nc1} = st
  StcScan{Bool.pick(U32, U32.is_eq(opt_term_tc_fid(term), U32.add(fid, 1)), U32.or(m1, 2), m1), am1, nc1}
def opt_stc_caller_scan(
  +fid: U32, +has: U32Map, +tr: RaVec<Maybe<&2, InlEntry>>, +corg: U32Map, +car: U32,
  blks: List<&2, IrBlock>, st: StcScan
) -> StcScan:
  match blks:
    case Nil{}: st
    case Con{IrBlock{_, ops, term}, t}:
      s1 = opt_stc_scan_term(fid, term, opt_stc_scan_ops(has, tr, corg, car, ops, st))
      opt_stc_caller_scan(fid, has, tr, corg, car, t, s1)
def opt_stc_caller_chk(st: StcScan) -> Bool:
  StcScan{m, am, nc} = st
  Bool.and(U32.is_eq(m, 3), Bool.and(U32.is_le(nc, 2), U32.is_le(opt_popcnt32(24n, am, 0), 8)))
def opt_stc_caller_ok(
  +fid: U32, +ar: U32, +has: U32Map, +tr: RaVec<Maybe<&2, InlEntry>>, +blks: List<&2, IrBlock>
) -> Bool:
  +sz_ok = Bool.and(
    U32.is_ge(fid, 3),
    Bool.and(
      U32.is_le(ar, 24),
      Bool.and(U32.is_le(b5k_list_len(IrBlock, blks), 32), U32.is_le(opt_blks_op_count(blks, 0), 180)),
    ),
  )
  low_if(
    Bool,
    sz_ok,
    _ => opt_stc_caller_chk(
      opt_stc_caller_scan(fid, has, tr, opt_stc_build_org(has, ar, blks), ar, blks, StcScan{0, 0, 0})
    ),
    _ => False{},
  )
def opt_inl_fn(+loop_tc: Bool, +sa_only: Bool, +bud0: U32, bank: InlBank, f: IrFn) -> IrFn:
  InlBank{+has, +tr} = bank
  IrFn{+fid, +nm, +ar, +nregs, +esc, +eff, +is_m, +blks} = f
  +is_sa = Bool.and(sa_only, opt_sa_caller_ok(has, blks, 1))
  +ok = Bool.or(Bool.not(sa_only), Bool.or(is_sa, opt_stc_caller_ok(fid, ar, has, tr, blks)))
  +bud = Bool.pick(U32, Bool.or(Bool.not(sa_only), is_sa), bud0, 2)
  low_if(IrFn, ok, _ => cf_fn_fin(fid, nm, ar, esc, eff, is_m, opt_inl_blks(loop_tc, fid, has, tr, blks, InlCur{0, Nil{}, Nil{}, nregs, U32.add(opt_blks_max_id(blks, 0), 1), bud})), _ => IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks})
def opt_ww_scan_term(+sfid: U32, +al: U32Map, term: IrTerm, st: WwScan) -> WwScan:
  match term st:
    case TTailCall{cfid, +args} WwScan{+bp, +ta, +ht, +hs, +hr, +hrt}: Bool.pick(WwScan, U32.is_eq(cfid, sfid), opt_ww_scan_self(al, args, 0, WwScan{bp, ta, ht, hs, hr, hrt}), WwScan{opt_ra_vs(RABad{al}, args, bp), ta, ht, hs, hr, hrt})
    case TBr{c, _, _} WwScan{bp, ta, ht, hs, hr, hrt}: WwScan{opt_ra_v(RABad{al}, c, bp), ta, ht, hs, hr, hrt}
    case TSwitch{s, _, _} WwScan{bp, ta, ht, hs, hr, hrt}: WwScan{opt_ra_v(RABad{al}, s, bp), ta, ht, hs, hr, hrt}
    case TRet{v} WwScan{bp, ta, ht, hs, hr, hrt}: WwScan{bp, ta, ht, hs, hr, opt_ra_v(RABad{al}, v, hrt)}
    case _ _: st
def opt_ww_scan_blks(+sfid: U32, +al: U32Map, +tgts: U32Map, blks: List<&2, IrBlock>, st: WwScan) -> WwScan: opt_foldl3(~IrBlock, ~U32, ~U32Map, ~U32Map, ~WwScan, ~(sf => a => tg => b => s => (+a0 = a; opt_un_blk(WwScan, b, id => ops => term => opt_ww_scan_term(sf, a0, term, opt_ww_scan_ops(U32.is_ne(um_get(tg, id), 0), a0, ops, s))))), sfid, al, tgts, blks, st)
def opt_ww_obs_term(+sfid: U32, +al: U32Map, +cand: U32Map, term: IrTerm, st: WwObsBlk) -> U32Map:
  match term st:
    case TTailCall{cfid, args} WwObsBlk{pc, obs}: opt_ww_obs_args(sfid, cfid, cand, al, pc, args, 0, obs)
    case _ WwObsBlk{_, obs}: obs
def opt_ww_obs_blks(+sfid: U32, +defc: U32Map, +uses: U32Map, +ar: U32, +al: U32Map, +cand: U32Map, +rc: U32Map, blks: List<&2, IrBlock>, obs: U32Map) -> U32Map:
  match blks:
    case Nil{}: obs
    case Con{IrBlock{_, ops, term}, t}: opt_ww_obs_blks(sfid, defc, uses, ar, al, cand, rc, t, opt_ww_obs_term(sfid, al, cand, term, opt_ww_obs_ops(sfid, defc, uses, ar, al, cand, rc, ops, WwObsBlk{RVEmpty{}, obs})))
def opt_ww_rw_callee_blk_go(id: U32, +sfid: U32, +ar: U32, +pi1: U32, +k1: U32, +cinfo: U32, +al: U32Map, +ex: U32Map, r: WwOpsRes, term: IrTerm, acc_b: List<&2, IrBlock>) -> CfBlksRes:
  match r term:
    case WwOpsRes{orev, nr2} TTailCall{+cfid, +args}: CfBlksRes{Con{IrBlock{id, b5k_list_rev(IrOp, orev), low_if(IrTerm, U32.is_eq(cfid, sfid), _ => opt_ww_rw_callee_tc(ar, pi1, k1, cinfo, al, ex, cfid, args), _ => TTailCall{cfid, args})}, acc_b}, nr2}
    case WwOpsRes{+orev, +nr2} TRet{+v}: (+hit = U32.is_eq(um_get(al, v), pi1); CfBlksRes{Con{IrBlock{id, b5k_list_rev(IrOp, Bool.pick(List<&2, IrOp>, hit, Con{ICtor{nr2, U32.sub(cinfo, 1), opt_ww_fields(v, ex, k1)}, orev}, orev)), TRet{Bool.pick(U32, hit, nr2, v)}}, acc_b}, Bool.pick(U32, hit, U32.add(nr2, 1), nr2)})
    case WwOpsRes{orev, nr2} other: CfBlksRes{Con{IrBlock{id, b5k_list_rev(IrOp, orev), other}, acc_b}, nr2}
def opt_ww_rw_callee_blks(+sfid: U32, +ar: U32, +pi1: U32, +k1: U32, +cinfo: U32, +al: U32Map, +ex: U32Map, blks: List<&2, IrBlock>, st: CfBlksRes) -> CfBlksRes:
  match blks st:
    case Nil{} CfBlksRes{acc_b, nr}: CfBlksRes{b5k_list_rev(IrBlock, acc_b), nr}
    case Con{IrBlock{id, ops, term}, t} CfBlksRes{acc_b, nr}: opt_ww_rw_callee_blks(sfid, ar, pi1, k1, cinfo, al, ex, t, opt_ww_rw_callee_blk_go(id, sfid, ar, pi1, k1, cinfo, al, ex, opt_ww_rw_callee_ops(ar, pi1, k1, cinfo, al, ex, ops, WwOpsRes{Nil{}, nr}), term, acc_b))
def opt_ww_has_call(+a: U32, acc: List<&2, IrOp>) -> Bool:
  match acc:
    case Nil{}: False{}
    case Con{ICallDirect{d, _, _}, t}: Bool.or(U32.is_eq(d, a), opt_ww_has_call(a, t))
    case Con{_, t}: opt_ww_has_call(a, t)
def opt_ww_ins_after_call(+a: U32, +tk: IrOp, acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match acc:
    case Nil{}: Con{tk, Nil{}}
    case Con{ICallDirect{+d, +cfid, +args}, +t}: Bool.pick(List<&2, IrOp>, U32.is_eq(d, a), Con{tk, Con{ICallDirect{d, cfid, args}, t}}, Con{ICallDirect{d, cfid, args}, opt_ww_ins_after_call(a, tk, t)})
    case Con{op, t}: Con{op, opt_ww_ins_after_call(a, tk, t)}
def opt_ww_rw_call_unpack(+a: U32, +pi: U32, +k: U32, +cinfo: U32, +args: List<&2, U32>, +acc: List<&2, IrOp>, +drop: U32Map, +nr: U32) -> WwCallRw:
  +need_tg = U32.is_eq(cinfo, 4294967294)
  +tg = U32.add(nr, k)
  +tail0 = opt_ww_seq(U32.to_nat(U32.sub(k, 1)), U32.add(nr, 1))
  +tk: IrOp = ITake{opt_ww_seq(U32.to_nat(k), nr), a}
  acc1 = Bool.pick(List<&2, IrOp>, Bool.and(Bool.not(need_tg), opt_ww_has_call(a, acc)), opt_ww_ins_after_call(a, tk, acc), Con{tk, Bool.pick(List<&2, IrOp>, need_tg, Con{ITag{tg, a}, acc}, acc)})
  WwCallRw{opt_u32_rep_app(args, pi, 0, nr, Bool.pick(List<&2, U32>, need_tg, b5k_list_app(U32, tail0, Con{tg, Nil{}}), tail0)), acc1, drop, Bool.pick(U32, need_tg, U32.add(tg, 1), tg)}
type WwCallRw is Data:
  WwCallRw{args: List<&2, U32>, acc: List<&2, IrOp>, drop: U32Map, nr: U32}
def opt_ww_rw_call_ent(pe: WwCtorEnt, +a: U32, +pi: U32, +k: U32, +cinfo: U32, +args: List<&2, U32>, +acc: List<&2, IrOp>, +drop: U32Map, +nr: U32) -> WwCallRw:
  match pe:
    case WSome{+v, +cid, ar, Con{+f0, +ft}}: (+need_tg = U32.is_eq(cinfo, 4294967294); low_if(WwCallRw, Bool.and(U32.is_eq(v, a), U32.is_eq(ar, k)), _ => WwCallRw{opt_u32_rep_app(args, pi, 0, f0, Bool.pick(List<&2, U32>, need_tg, b5k_list_app(U32, ft, Con{nr, Nil{}}), ft)), Bool.pick(List<&2, IrOp>, need_tg, Con{IConst{nr, cid}, acc}, acc), um_set(drop, v, 1), Bool.pick(U32, need_tg, U32.add(nr, 1), nr)}, _ => opt_ww_rw_call_unpack(a, pi, k, cinfo, args, acc, drop, nr)))
    case _: opt_ww_rw_call_unpack(a, pi, k, cinfo, args, acc, drop, nr)
def opt_ww_rw_call_pi(+pi: U32, +cfid: U32, +par: U32Map, +pcid: U32Map, +pc: RaVec<WwCtorEnt>, +args: List<&2, U32>, +acc: List<&2, IrOp>, +drop: U32Map, +nr: U32) -> WwCallRw: (+a = low_nth(U32, U32.to_nat(pi), 4294967295, args); low_if(WwCallRw, U32.is_ne(a, 4294967295), _ => opt_ww_rw_call_ent(ra_vec_get(WwCtorEnt, 6n, WNone{}, a, pc), a, pi, um_get(par, cfid), um_get(pcid, cfid), args, acc, drop, nr), _ => WwCallRw{args, acc, drop, nr}))
def opt_ww_rw_call_args(+sfid: U32, +sf_ar: U32, +cfid: U32, +pidx: U32Map, +par: U32Map, +pcid: U32Map, +pc: RaVec<WwCtorEnt>, +args: List<&2, U32>, +acc: List<&2, IrOp>, +drop: U32Map, +nr: U32) -> WwCallRw: (+pi1 = Bool.pick(U32, Bool.and(U32.is_eq(cfid, sfid), U32.is_ge(b5k_u32_list_len(args), sf_ar)), 0, um_get(pidx, cfid)); low_if(WwCallRw, U32.is_ne(pi1, 0), _ => opt_ww_rw_call_pi(U32.sub(pi1, 1), cfid, par, pcid, pc, args, acc, drop, nr), _ => WwCallRw{args, acc, drop, nr}))
type WwBlkRw is Data:
  WwBlkRw{pc: RaVec<WwCtorEnt>, acc: List<&2, IrOp>, drop: U32Map, nr: U32}
def opt_un_wwc(-R: Type, r: WwCallRw, k: List<&2, U32> -> List<&2, IrOp> -> U32Map -> U32 -> R) -> R:
  WwCallRw{a, b, c, d} = r
  k(a, b, c, d)
def opt_ww_rw_caller_ops(+sfid: U32, +defc: U32Map, +uses: U32Map, +ar: U32, +pidx: U32Map, +par: U32Map, +pcid: U32Map, ops: List<&2, IrOp>, st: WwBlkRw) -> WwBlkRw:
  match ops st:
    case Nil{} _: st
    case Con{ICtor{+d, +cid, +fs}, +t} WwBlkRw{pc, acc, drop, nr}: (+k = b5k_u32_list_len(fs); +su_d = Bool.and(U32.is_lt(d, 4096), Bool.and(U32.is_eq(um_get(defc, d), 1), U32.is_eq(um_get(uses, d), 1))); ok = Bool.and(U32.is_ge(k, 2), Bool.and(U32.is_le(k, 8), Bool.and(su_d, Bool.or(opt_all_can_prop(defc, ar, fs), opt_is_nil_ops(t))))); opt_ww_rw_caller_ops(sfid, defc, uses, ar, pidx, par, pcid, t, WwBlkRw{opt_rv_put(WwCtorEnt, ok, 6n, d, WSome{d, cid, k, fs}, pc), Con{ICtor{d, cid, fs}, acc}, drop, nr}))
    case Con{ICallDirect{dst, +cfid, args}, t} WwBlkRw{+pc, acc, drop, nr}: opt_ww_rw_caller_ops(sfid, defc, uses, ar, pidx, par, pcid, t, opt_un_wwc(WwBlkRw, opt_ww_rw_call_args(sfid, ar, cfid, pidx, par, pcid, pc, args, acc, drop, nr), a2 => ac2 => dr2 => nr2 => WwBlkRw{pc, Con{ICallDirect{dst, cfid, a2}, ac2}, dr2, nr2}))
    case Con{op, t} WwBlkRw{pc, acc, drop, nr}: opt_ww_rw_caller_ops(sfid, defc, uses, ar, pidx, par, pcid, t, WwBlkRw{pc, Con{op, acc}, drop, nr})
def opt_ww_rw_caller_fin(id: U32, +sfid: U32, +ar: U32, +pidx: U32Map, +par: U32Map, +pcid: U32Map, term: IrTerm, acc_b: List<&2, IrBlock>, st: WwBlkRw) -> CfBlksRes:
  match term st:
    case TTailCall{+cfid, args} WwBlkRw{pc, acc, drop, nr}: opt_un_wwc(CfBlksRes, opt_ww_rw_call_args(sfid, ar, cfid, pidx, par, pcid, pc, args, acc, drop, nr), a2 => ac2 => dr2 => nr2 => CfBlksRes{Con{IrBlock{id, sroa_drop_fused(dr2, ac2, Nil{}), TTailCall{cfid, a2}}, acc_b}, nr2})
    case other WwBlkRw{_, acc, drop, nr}: CfBlksRes{Con{IrBlock{id, sroa_drop_fused(drop, acc, Nil{}), other}, acc_b}, nr}
def opt_ww_rw_caller_blks(+sfid: U32, +defc: U32Map, +uses: U32Map, +ar: U32, +pidx: U32Map, +par: U32Map, +pcid: U32Map, blks: List<&2, IrBlock>, st: CfBlksRes) -> CfBlksRes:
  match blks st:
    case Nil{} CfBlksRes{acc_b, nr}: CfBlksRes{b5k_list_rev(IrBlock, acc_b), nr}
    case Con{IrBlock{id, ops, term}, t} CfBlksRes{acc_b, nr}: opt_ww_rw_caller_blks(sfid, defc, uses, ar, pidx, par, pcid, t, opt_ww_rw_caller_fin(id, sfid, ar, pidx, par, pcid, term, acc_b, opt_ww_rw_caller_ops(sfid, defc, uses, ar, pidx, par, pcid, ops, WwBlkRw{RVEmpty{}, Nil{}, UM0{}, nr})))
# Pass F — Branchless sel(0/1,0,K) Fold, abs-sq Fold, b2u-is_zero Invert, Diamond Fusion & Pure-Op Sinking
type SelAux is Data:
  SelAux{zinv: U32Map, suba: U32Map, subb: U32Map, sq: U32Map}
def opt_sel_aux_ops(+defc: U32Map, +uses: U32Map, +ar: U32, +b01: U32Map, +gh: U32Map, +gv: U32Map, ops: List<&2, IrOp>, st: SelAux) -> SelAux:
  match ops st:
    case Nil{} _: st
    case Con{ICmp{+d, 0, +a, +b}, t} SelAux{+zi, sa, sb, sq}: (+za = Bool.and(U32.is_ne(um_get(gh, b), 0), Bool.and(U32.is_zero(um_get(gv, b)), U32.is_ne(um_get(b01, a), 0))); +zb = Bool.and(U32.is_ne(um_get(gh, a), 0), Bool.and(U32.is_zero(um_get(gv, a)), U32.is_ne(um_get(b01, b), 0))); +nv = Bool.pick(U32, za, U32.add(a, 1), Bool.pick(U32, zb, U32.add(b, 1), 0)); opt_sel_aux_ops(defc, uses, ar, b01, gh, gv, t, SelAux{Bool.pick(U32Map, U32.is_ne(nv, 0), um_set(zi, d, nv), zi), sa, sb, sq}))
    case Con{IBin{+d, 1, +a, +b}, t} SelAux{zi, +sa, +sb, sq}: (+ok = Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(opt_cp_can_prop(defc, ar, a), opt_cp_can_prop(defc, ar, b)))); opt_sel_aux_ops(defc, uses, ar, b01, gh, gv, t, SelAux{zi, Bool.pick(U32Map, ok, um_set(sa, d, U32.add(a, 1)), sa), Bool.pick(U32Map, ok, um_set(sb, d, U32.add(b, 1)), sb), sq}))
    case Con{IBin{_, 2, +a, +b}, t} SelAux{zi, sa, sb, +sq}: opt_sel_aux_ops(defc, uses, ar, b01, gh, gv, t, SelAux{zi, sa, sb, Bool.pick(U32Map, Bool.and(U32.is_eq(a, b), U32.is_eq(um_get(uses, a), 2)), um_set(sq, a, 1), sq)})
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
def opt_is_sar_mask(+v: U32) -> Bool: (+inv = U32.xor(v, 4294967295); Bool.and(U32.is_ge(v, 2147483648), Bool.and(U32.is_lt(v, 4294967295), U32.is_zero(U32.and(inv, U32.add(inv, 1))))))
def opt_sel_fold(at: SelArm, af: SelArm, +sa: U32Map, +sb: U32Map, +sq: U32Map, +id: U32, +ops: List<&2, IrOp>, +c: U32, tb: U32, fb: U32, +nr: U32, +acc: List<&2, IrBlock>) -> CfBlksRes:
  match at af:
    case SASome{+dt, +vt, +jt} SASome{df, +vf, jf}: (+same = Bool.and(U32.is_eq(dt, df), U32.is_eq(jt, jf)); Bool.pick(CfBlksRes, Bool.and(same, Bool.and(U32.is_zero(vt), Bool.and(U32.is_ne(vf, 0), Bool.not(opt_is_sar_mask(vf))))), CfBlksRes{Con{IrBlock{id, b5k_list_app(IrOp, ops, [IConst{nr, 1}, IBin{U32.add(nr, 1), 1, c, nr}, IConst{U32.add(nr, 2), vf}, IBin{dt, 5, U32.add(nr, 1), U32.add(nr, 2)}]), TJmp{jt}}, acc}, U32.add(nr, 3)}, Bool.pick(CfBlksRes, Bool.and(same, Bool.and(U32.is_zero(vf), U32.is_ne(vt, 0))), CfBlksRes{Con{IrBlock{id, b5k_list_app(IrOp, ops, Bool.pick(List<&2, IrOp>, U32.is_eq(vt, 1), [ICopy{dt, c}], [IUn{nr, 0, c}, IConst{U32.add(nr, 1), vt}, IBin{dt, 5, nr, U32.add(nr, 1)}])), TJmp{jt}}, acc}, Bool.pick(U32, U32.is_eq(vt, 1), nr, U32.add(nr, 2))}, CfBlksRes{Con{IrBlock{id, ops, TBr{c, tb, fb}}, acc}, nr})))
    case SAVar{+dt, +st, +jt} SAVar{df, +sf, jf}: (+neg_sq = Bool.and(U32.is_eq(dt, df), Bool.and(U32.is_eq(jt, jf), Bool.and(U32.is_ne(um_get(sq, dt), 0), Bool.and(U32.is_ne(um_get(sa, st), 0), Bool.and(U32.is_eq(um_get(sa, st), um_get(sb, sf)), U32.is_eq(um_get(sb, st), um_get(sa, sf))))))); Bool.pick(CfBlksRes, neg_sq, CfBlksRes{Con{IrBlock{id, b5k_list_app(IrOp, ops, [ICopy{dt, st}]), TJmp{jt}}, acc}, nr}, CfBlksRes{Con{IrBlock{id, ops, TBr{c, tb, fb}}, acc}, nr}))
    case _ _: CfBlksRes{Con{IrBlock{id, ops, TBr{c, tb, fb}}, acc}, nr}
def opt_sel_go(+b01: U32Map, +gh: U32Map, +gv: U32Map, +zi: U32Map, +sa: U32Map, +sb: U32Map, +sq: U32Map, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>, st: CfBlksRes) -> CfBlksRes:
  match blks st:
    case Nil{} CfBlksRes{acc, nr}: CfBlksRes{b5k_list_rev(IrBlock, acc), nr}
    case Con{IrBlock{+id, ops, TBr{+c0, +tb0, +fb0}}, t} CfBlksRes{acc, nr}: (+inv = um_get(zi, c0); +c = Bool.pick(U32, U32.is_ne(inv, 0), U32.sub(inv, 1), c0); +tb = Bool.pick(U32, U32.is_ne(inv, 0), fb0, tb0); +fb = Bool.pick(U32, U32.is_ne(inv, 0), tb0, fb0); ok = Bool.and(U32.is_ne(um_get(b01, c), 0), opt_is_diam(preds, id, tb, fb)); opt_sel_go(b01, gh, gv, zi, sa, sb, sq, preds, bmap, t, opt_sel_fold(Bool.pick(SelArm, ok, opt_sel_arm(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bmap), gh, gv), SANone{}), opt_sel_arm(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap), gh, gv), sa, sb, sq, id, ops, c, tb, fb, nr, acc)))
    case Con{b, t} CfBlksRes{acc, nr}: opt_sel_go(b01, gh, gv, zi, sa, sb, sq, preds, bmap, t, CfBlksRes{Con{b, acc}, nr})
def opt_fuse_set(mt2: Maybe<&2, IrBlock>, mf2: Maybe<&2, IrBlock>, +tb1: U32, opsT1: List<&2, IrOp>, +fb1: U32, opsF1: List<&2, IrOp>, rep: RaVec<Maybe<&2, IrBlock>>) -> RaVec<Maybe<&2, IrBlock>>:
  match mt2 mf2:
    case Some{IrBlock{_, opsT2, termT2}} Some{IrBlock{_, opsF2, termF2}}: ra_vec_set(Maybe<&2, IrBlock>, 5n, fb1, Some{IrBlock{fb1, b5k_list_app(IrOp, opsF1, opsF2), termF2}}, ra_vec_set(Maybe<&2, IrBlock>, 5n, tb1, Some{IrBlock{tb1, b5k_list_app(IrOp, opsT1, opsT2), termT2}}, rep))
    case _ _: rep
def opt_fuse_j1(mj: Maybe<&2, IrBlock>, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, +c: U32, +tb1: U32, opsT1: List<&2, IrOp>, +fb1: U32, opsF1: List<&2, IrOp>, +j1: U32, rep: RaVec<Maybe<&2, IrBlock>>) -> RaVec<Maybe<&2, IrBlock>>:
  match mj:
    case Some{IrBlock{_, Nil{}, TBr{c2, +tb2, +fb2}}}: opt_fuse_set(Bool.pick(Maybe<&2, IrBlock>, Bool.and(U32.is_eq(c2, c), opt_is_diam(preds, j1, tb2, fb2)), ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb2, bmap), None{}), ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb2, bmap), tb1, opsT1, fb1, opsF1, rep)
    case _: rep
def opt_fuse_arms(mt1: Maybe<&2, IrBlock>, mf1: Maybe<&2, IrBlock>, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, +id: U32, +c: U32, +tb1: U32, +fb1: U32, rep: RaVec<Maybe<&2, IrBlock>>) -> RaVec<Maybe<&2, IrBlock>>:
  match mt1 mf1:
    case Some{IrBlock{_, opsT1, TJmp{+jt}}} Some{IrBlock{_, opsF1, TJmp{jf}}}: opt_fuse_j1(Bool.pick(Maybe<&2, IrBlock>, Bool.and(U32.is_eq(jt, jf), Bool.and(U32.is_lt(jt, 1024), Bool.and(U32.is_ne(jt, id), U32.is_eq(um_get(preds, jt), 2)))), ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, jt, bmap), None{}), preds, bmap, c, tb1, opsT1, fb1, opsF1, jt, rep)
    case _ _: rep
def opt_fuse_scan(+defc: U32Map, +ar: U32, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>, rep: RaVec<Maybe<&2, IrBlock>>) -> RaVec<Maybe<&2, IrBlock>>:
  match blks:
    case Nil{}: rep
    case Con{IrBlock{+id, _, TBr{+c, +tb1, +fb1}}, t}: opt_fuse_scan(defc, ar, preds, bmap, t, opt_fuse_arms(Bool.pick(Maybe<&2, IrBlock>, Bool.and(opt_cp_can_prop(defc, ar, c), opt_is_diam(preds, id, tb1, fb1)), ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb1, bmap), None{}), ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb1, bmap), preds, bmap, id, c, tb1, fb1, rep))
    case Con{_, t}: opt_fuse_scan(defc, ar, preds, bmap, t, rep)
def opt_sink_info(+defc: U32Map, +ar: U32, op: IrOp) -> U32:
  match op:
    case IBin{+d, +bop, a, b}: Bool.pick(U32, Bool.and(U32.is_ne(bop, 3), Bool.and(U32.is_ne(bop, 4), Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(opt_cp_can_prop(defc, ar, a), opt_cp_can_prop(defc, ar, b)))))), U32.or(U32.shln(U32.add(d, 1), 3n), Bool.pick(U32, U32.is_eq(bop, 2), 4, 1)), 0)
    case IUn{+d, _, s}: Bool.pick(U32, Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_eq(um_get(defc, d), 1), opt_cp_can_prop(defc, ar, s))), U32.or(U32.shln(U32.add(d, 1), 3n), 1), 0)
    case ICmp{+d, _, a, b}: Bool.pick(U32, Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(opt_cp_can_prop(defc, ar, a), opt_cp_can_prop(defc, ar, b)))), U32.or(U32.shln(U32.add(d, 1), 3n), 1), 0)
    case IConst{+d, _}: Bool.pick(U32, Bool.and(U32.is_ge(d, ar), U32.is_eq(um_get(defc, d), 1)), U32.or(U32.shln(U32.add(d, 1), 3n), 1), 0)
    case _: 0
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
    case Con{+op, t} SinkSt{+ut, +uf, keep, st, sf, ct, cf}: (+inf = opt_sink_info(defc, ar, op); +d = U32.sub(U32.shrn(inf, 3n), 1); +tu = Bool.pick(U32, U32.is_ne(inf, 0), um_get(uses, d), 0); +go_t = Bool.and(okt, Bool.and(U32.is_ne(tu, 0), U32.is_eq(um_get(ut, d), tu))); opt_sink_walk(defc, uses, ar, okt, okf, t, opt_sink_step(go_t, Bool.and(Bool.not(go_t), Bool.and(okf, Bool.and(U32.is_ne(tu, 0), U32.is_eq(um_get(uf, d), tu)))), op, U32.and(inf, 7), ut, uf, keep, st, sf, ct, cf)))
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

# Pass G — Identity Match-Arm Elision
type TagFact is Data:
  TFNone{}
  TFSome{src: U32, cid: U32}
  TFNe{src: U32, cid: U32}
def opt_u32_list_eq(xs: List<&2, U32>, ys: List<&2, U32>) -> Bool:
  match xs ys:
    case Nil{} Nil{}: True{}
    case Con{x, xt} Con{y, yt}: Bool.and(U32.is_eq(x, y), opt_u32_list_eq(xt, yt))
    case _ _: False{}
def opt_id_ds_ok(+defc: U32Map, +uses: U32Map, +ar: U32, ds: List<&2, U32>) -> Bool: opt_alll3(~U32, ~U32Map, ~U32Map, ~U32, ~(d => u => a => v => (+v0 = v; Bool.and(U32.is_ge(v0, a), Bool.and(U32.is_eq(um_get(d, v0), 1), U32.is_eq(um_get(u, v0), 1))))), defc, uses, ar, ds)
def opt_id_tf_put(+preds: U32Map, +bid: U32, +tgt: U32, tf: TagFact, fm: RaVec<TagFact>) -> RaVec<TagFact>: opt_rv_put(TagFact, Bool.and(U32.is_ne(tgt, 0), opt_is_sp(preds, bid, tgt)), 5n, tgt, tf, fm)
def opt_id_tf_arms(+preds: U32Map, +bid: U32, +src: U32, arms: List<&2, IrSwitchArm>, fm: RaVec<TagFact>) -> RaVec<TagFact>: opt_foldl3(~IrSwitchArm, ~U32Map, ~U32, ~U32, ~RaVec<TagFact>, ~(pr => bi => sr => a => m => opt_un_arm(RaVec<TagFact>, a, k => tgt => opt_id_tf_put(pr, bi, tgt, TFSome{sr, k}, m))), preds, bid, src, arms, fm)
def opt_id_is_none(tf: TagFact) -> Bool:
  match tf:
    case TFNone{}: True{}
    case _: False{}
def opt_id_tf_br(+tm: U32Map, +preds: U32Map, +bid: U32, +tb: U32, +fb: U32, sc: BrScan, +fm: RaVec<TagFact>) -> RaVec<TagFact>:
  match sc:
    case BrScan{+has, +val, True{}, +cop, +a, +b}:
      +eq_t = Bool.pick(U32, U32.is_zero(cop), tb, fb)
      +ne_t = Bool.pick(U32, U32.is_zero(cop), fb, tb)
      +ta = um_get(tm, a); +tb2 = um_get(tm, b)
      +can_ne = opt_id_is_none(opt_rv_get(TagFact, TFNone{}, bid, fm))
      +ok_a = Bool.and(U32.is_ne(ta, 0), U32.is_ne(um_get(has, b), 0))
      +ok_b = Bool.and(U32.is_ne(tb2, 0), U32.is_ne(um_get(has, a), 0))
      +fm1 = Bool.pick(RaVec<TagFact>, ok_a, opt_id_tf_put(preds, bid, eq_t, TFSome{U32.sub(ta, 1), um_get(val, b)}, fm), fm)
      +fm2 = Bool.pick(RaVec<TagFact>, Bool.and(ok_a, can_ne), opt_id_tf_put(preds, bid, ne_t, TFNe{U32.sub(ta, 1), um_get(val, b)}, fm1), fm1)
      +fm3 = Bool.pick(RaVec<TagFact>, ok_b, opt_id_tf_put(preds, bid, eq_t, TFSome{U32.sub(tb2, 1), um_get(val, a)}, fm2), fm2)
      Bool.pick(RaVec<TagFact>, Bool.and(ok_b, can_ne), opt_id_tf_put(preds, bid, ne_t, TFNe{U32.sub(tb2, 1), um_get(val, a)}, fm3), fm3)
    case _: fm
def opt_id_blk_tm(ops: List<&2, IrOp>, +tm: U32Map) -> U32Map:
  match ops:
    case Nil{}: tm
    case Con{ITag{d, s}, t}: opt_id_blk_tm(t, um_set(tm, d, U32.add(s, 1)))
    case Con{op, t}: (+d1 = opt_op_dst1(op); opt_id_blk_tm(t, Bool.pick(U32Map, U32.is_ne(d1, 0), um_set(tm, U32.sub(d1, 1), 0), tm)))
def opt_id_collect_tf(+tm: U32Map, +gh: U32Map, +gv: U32Map, +preds: U32Map, blks: List<&2, IrBlock>, +fm: RaVec<TagFact>) -> RaVec<TagFact>:
  match blks:
    case Nil{}: fm
    case Con{IrBlock{+id, +ops, TBr{c, tb, fb}}, t}: opt_id_collect_tf(tm, gh, gv, preds, t, opt_id_tf_br(opt_id_blk_tm(ops, tm), preds, id, tb, fb, cf_br_scan_ops(c, ops, BrScan{gh, gv, False{}, 0, 0, 0}), fm))
    case Con{IrBlock{+id, +ops, TSwitch{s, arms, _}}, t}: (+ts = um_get(opt_id_blk_tm(ops, tm), s); opt_id_collect_tf(tm, gh, gv, preds, t, Bool.pick(RaVec<TagFact>, U32.is_ne(ts, 0), opt_id_tf_arms(preds, id, U32.sub(ts, 1), arms, fm), fm)))
    case Con{_, t}: opt_id_collect_tf(tm, gh, gv, preds, t, fm)
def opt_id_orig_ds(+o: U32, ds: List<&2, U32>, +m: U32Map) -> U32Map:
  match ds:
    case Nil{}: m
    case Con{+d, t}: opt_id_orig_ds(o, t, Bool.pick(U32Map, U32.is_zero(um_get(m, d)), um_set(m, d, o), m))
def opt_id_orig_ops(ops: List<&2, IrOp>, +m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{ICopy{d, s}, t}: (+o = um_get(m, s); opt_id_orig_ops(t, Bool.pick(U32Map, U32.is_ne(o, 0), opt_id_orig_ds(o, Con{d, Nil{}}, m), m)))
    case Con{IKeep{d, s}, t}: (+o = um_get(m, s); opt_id_orig_ops(t, Bool.pick(U32Map, U32.is_ne(o, 0), opt_id_orig_ds(o, Con{d, Nil{}}, m), m)))
    case Con{ITake{ds, s}, t}: (+o = um_get(m, s); opt_id_orig_ops(t, Bool.pick(U32Map, U32.is_ne(o, 0), opt_id_orig_ds(o, ds, m), m)))
    case Con{_, t}: opt_id_orig_ops(t, m)
def opt_id_orig_blks(blks: List<&2, IrBlock>, +m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, _}, t}: opt_id_orig_blks(t, opt_id_orig_ops(ops, m))
def opt_id_tc_args(args: List<&2, U32>, +idx: U32, +m: U32Map) -> U32Map:
  match args:
    case Nil{}: m
    case Con{a, t}: opt_id_tc_args(t, U32.add(idx, 1), um_set(m, a, U32.add(idx, 1)))
def opt_id_tc_bwd_ops(ops_rev: List<&2, IrOp>, +m: U32Map) -> U32Map:
  match ops_rev:
    case Nil{}: m
    case Con{ICopy{d, s}, t}: (+v = um_get(m, d); opt_id_tc_bwd_ops(t, Bool.pick(U32Map, U32.is_ne(v, 0), um_set(m, s, v), m)))
    case Con{IKeep{d, s}, t}: (+v = um_get(m, d); opt_id_tc_bwd_ops(t, Bool.pick(U32Map, U32.is_ne(v, 0), um_set(m, s, v), m)))
    case Con{_, t}: opt_id_tc_bwd_ops(t, m)
def opt_id_tc_blks(+fid: U32, blks: List<&2, IrBlock>, +m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, TTailCall{tfid, args}}, t}: opt_id_tc_blks(fid, t, opt_id_tc_bwd_ops(b5k_list_rev(IrOp, ops), Bool.pick(U32Map, U32.is_eq(tfid, fid), opt_id_tc_args(args, 0, m), m)))
    case Con{IrBlock{_, ops, _}, t}: opt_id_tc_blks(fid, t, opt_id_tc_bwd_ops(b5k_list_rev(IrOp, ops), m))
def opt_id_has_ctor_cid(+c0: U32, blks: List<&2, IrBlock>, ops: List<&2, IrOp>) -> Bool:
  match blks ops:
    case Nil{} Nil{}: False{}
    case Con{IrBlock{_, ops1, _}, t} Nil{}: opt_id_has_ctor_cid(c0, t, ops1)
    case _ Con{ICtor{_, c, _}, ot}: Bool.or(U32.is_eq(c, c0), opt_id_has_ctor_cid(c0, blks, ot))
    case _ Con{_, ot}: opt_id_has_ctor_cid(c0, blks, ot)
def opt_id_ne_ok(+orig: U32Map, +tcm: U32Map, +has_c0: Bool, +src: U32, +c0: U32, +d: U32, +c2: U32) -> Bool:
  +ne = U32.is_ne(c2, c0)
  +adj = Bool.or(U32.is_eq(c2, U32.add(c0, 1)), U32.is_eq(c0, U32.add(c2, 1)))
  +so = um_get(orig, src)
  +tc_ok = Bool.and(U32.is_ne(so, 0), U32.is_eq(um_get(tcm, d), so))
  Bool.and(ne, Bool.or(tc_ok, Bool.and(has_c0, adj)))
def opt_id_cp_ops(+defc: U32Map, +ar: U32, ops: List<&2, IrOp>, +m: U32Map) -> U32Map:
  match ops:
    case Nil{}: m
    case Con{ICopy{+d, +s}, t}: opt_id_cp_ops(defc, ar, t, Bool.pick(U32Map, Bool.and(U32.is_ge(d, ar), U32.is_eq(um_get(defc, d), 1)), um_set(m, d, U32.add(s, 1)), m))
    case Con{_, t}: opt_id_cp_ops(defc, ar, t, m)
def opt_id_cp_blks(+defc: U32Map, +ar: U32, blks: List<&2, IrBlock>, +m: U32Map) -> U32Map:
  match blks:
    case Nil{}: m
    case Con{IrBlock{_, ops, _}, t}: opt_id_cp_blks(defc, ar, t, opt_id_cp_ops(defc, ar, ops, m))
def opt_id_same_src(+cpm: U32Map, +s: U32, +src: U32) -> Bool:
  Bool.or(U32.is_eq(s, src), U32.is_eq(um_get(cpm, s), U32.add(src, 1)))
type IdRw is Data:
  IdRw{ops_rev: List<&2, IrOp>, has_tk: Bool, tk_src: U32, tk_ds: List<&2, U32>, hit: Bool}
def opt_id_rw_ops(+orig: U32Map, +tcm: U32Map, +cpm: U32Map, +has_c0: Bool, +is_ne: Bool, +defc: U32Map, +uses: U32Map, +ar: U32, +src: U32, +cid: U32, ops: List<&2, IrOp>, st: IdRw) -> IdRw:
  match ops st:
    case Nil{} _: st
    case Con{ITake{+ds, +s}, t} IdRw{+rev, +htk, +tsrc, +tds, +hit}: (+ok = Bool.and(Bool.not(htk), Bool.and(Bool.not(hit), Bool.and(opt_id_same_src(cpm, s, src), Bool.and(U32.is_ne(b5k_u32_list_len(ds), 0), opt_id_ds_ok(defc, uses, ar, ds))))); opt_id_rw_ops(orig, tcm, cpm, has_c0, is_ne, defc, uses, ar, src, cid, t, Bool.pick(IdRw, ok, IdRw{Con{ITake{ds, s}, rev}, True{}, s, ds, False{}}, IdRw{Con{ITake{ds, s}, rev}, htk, tsrc, tds, hit})))
    case Con{ICtor{+d, +c2, +fs}, t} IdRw{+rev, +htk, +tsrc, +tds, +hit}: (+cid_ok = Bool.pick(Bool, is_ne, opt_id_ne_ok(orig, tcm, has_c0, tsrc, cid, d, c2), U32.is_eq(c2, cid)); +ok = Bool.and(htk, Bool.and(cid_ok, opt_u32_list_eq(tds, fs))); opt_id_rw_ops(orig, tcm, cpm, has_c0, is_ne, defc, uses, ar, src, cid, t, Bool.pick(IdRw, ok, IdRw{Con{ICopy{d, tsrc}, rev}, False{}, tsrc, tds, True{}}, IdRw{Con{ICtor{d, c2, fs}, rev}, htk, tsrc, tds, hit})))
    case Con{op, t} IdRw{rev, htk, tsrc, tds, hit}: opt_id_rw_ops(orig, tcm, cpm, has_c0, is_ne, defc, uses, ar, src, cid, t, IdRw{Con{op, rev}, htk, tsrc, tds, hit})
def opt_id_drop_take(+src: U32, +tds: List<&2, U32>, ops_rev: List<&2, IrOp>, +dropped: Bool, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops_rev:
    case Nil{}: acc
    case Con{ITake{+ds, +s}, t}: (+dn = Bool.and(Bool.not(dropped), Bool.and(U32.is_eq(s, src), opt_u32_list_eq(ds, tds))); opt_id_drop_take(src, tds, t, Bool.or(dropped, dn), Bool.pick(List<&2, IrOp>, dn, acc, Con{ITake{ds, s}, acc})))
    case Con{op, t}: opt_id_drop_take(src, tds, t, dropped, Con{op, acc})
def opt_id_fin_blk(orig: List<&2, IrOp>, r: IdRw) -> List<&2, IrOp>:
  IdRw{rev, _, tsrc, tds, hit} = r
  Bool.pick(List<&2, IrOp>, hit, opt_id_drop_take(tsrc, tds, rev, False{}, Nil{}), orig)
def opt_id_rw_one(+orig: U32Map, +tcm: U32Map, +cpm: U32Map, +blks: List<&2, IrBlock>, tf: TagFact, defc: U32Map, uses: U32Map, ar: U32, +ops: List<&2, IrOp>) -> List<&2, IrOp>:
  match tf:
    case TFNone{}: ops
    case TFSome{+src, cid}: opt_id_fin_blk(ops, opt_id_rw_ops(orig, tcm, cpm, False{}, False{}, defc, uses, ar, src, cid, ops, IdRw{Nil{}, False{}, 0, Nil{}, False{}}))
    case TFNe{+src, +cid}: opt_id_fin_blk(ops, opt_id_rw_ops(orig, tcm, cpm, opt_id_has_ctor_cid(cid, blks, Nil{}), True{}, defc, uses, ar, src, cid, ops, IdRw{Nil{}, False{}, 0, Nil{}, False{}}))
# Pass H — Large-Arity Self-TCO Lowering
type TcoSt is Data:
  TcoSt{p1_rev: List<&2, IrOp>, p2_rev: List<&2, IrOp>, nr: U32}
def opt_tco_fuse_map(+ar: U32, +fu: U32Map, +bu: U32Map, +au: U32Map, args: List<&2, U32>, +idx: U32, +fm: U32Map) -> U32Map:
  match args:
    case Nil{}: fm
    case Con{+a, t}: (ok = Bool.and(U32.is_ge(a, ar), Bool.and(U32.is_eq(um_get(fu, a), 1), Bool.and(U32.is_zero(um_get(bu, a)), Bool.and(U32.is_eq(um_get(au, a), 1), Bool.and(U32.is_zero(um_get(au, idx)), U32.is_eq(um_get(bu, idx), 1)))))); opt_tco_fuse_map(ar, fu, bu, au, t, U32.add(idx, 1), Bool.pick(U32Map, ok, um_set(fm, a, U32.add(idx, 1)), fm)))
type TcoFRes is Data:
  TcoFRes{ops: List<&2, IrOp>, done: U32Map}
def opt_tco_fuse_ops(+fm: U32Map, ops: List<&2, IrOp>, +done: U32Map, +acc: List<&2, IrOp>) -> TcoFRes:
  match ops:
    case Nil{}: TcoFRes{b5k_list_rev(IrOp, acc), done}
    case Con{IBin{+d, bop, +x, +y}, t}: (+f = um_get(fm, d); +pi = U32.sub(f, 1); +hit = Bool.and(U32.is_ne(f, 0), Bool.or(U32.is_eq(x, pi), U32.is_eq(y, pi))); opt_tco_fuse_ops(fm, t, Bool.pick(U32Map, hit, um_set(done, pi, 1), done), Con{IBin{Bool.pick(U32, hit, pi, d), bop, x, y}, acc}))
    case Con{op, t}: opt_tco_fuse_ops(fm, t, done, Con{op, acc})
def opt_tco_args(+ar: U32, +done: U32Map, args: List<&2, U32>, +idx: U32, st: TcoSt) -> TcoSt:
  match args st:
    case Nil{} _: st
    case Con{+a, t} TcoSt{+p1, +p2, +nr}: (+skip = Bool.or(U32.is_eq(a, idx), U32.is_ne(um_get(done, idx), 0)); +nt = Bool.and(Bool.not(skip), U32.is_lt(a, ar)); opt_tco_args(ar, done, t, U32.add(idx, 1), TcoSt{Bool.pick(List<&2, IrOp>, nt, Con{ICopy{nr, a}, p1}, p1), Bool.pick(List<&2, IrOp>, skip, p2, Con{ICopy{idx, Bool.pick(U32, nt, nr, a)}, p2}), Bool.pick(U32, nt, U32.add(nr, 1), nr)}))
def opt_un_tco(-R: Type, st: TcoSt, k: List<&2, IrOp> -> List<&2, IrOp> -> U32 -> R) -> R:
  TcoSt{a, b, c} = st
  k(a, b, c)
def opt_tco_emit_f(id: U32, hdr: U32, ar: U32, args: List<&2, U32>, acc: List<&2, IrBlock>, nr: U32, fr: TcoFRes) -> CfBlksRes:
  TcoFRes{ops2, done} = fr
  opt_un_tco(CfBlksRes, opt_tco_args(ar, done, args, 0, TcoSt{Nil{}, Nil{}, nr}), p1r => p2r => nr2 => CfBlksRes{Con{IrBlock{id, b5k_list_app(IrOp, ops2, b5k_list_app(IrOp, b5k_list_rev(IrOp, p1r), b5k_list_rev(IrOp, p2r))), TJmp{hdr}}, acc}, nr2})
# Pass I — Perceus In-Place IReuse Token Pairing
type ReuseTok is Data:
  RTok{slot: U32, ar: U32}
type RuPick is Data:
  RuNo{}
  RuYes{slot: U32, rest: List<&2, ReuseTok>}
type RuSt is Data:
  RuSt{pool: List<&2, ReuseTok>, seen: U32Map, rev: List<&2, IrOp>}
def opt_ru_filter_m(+m: U32Map, ps: List<&2, ReuseTok>) -> List<&2, ReuseTok>:
  match ps:
    case Nil{}: Nil{}
    case Con{RTok{+sl, ar}, t}: (+rest = opt_ru_filter_m(m, t); Bool.pick(List<&2, ReuseTok>, U32.is_zero(um_get(m, sl)), Con{RTok{sl, ar}, rest}, rest))
def opt_ru_kill_op(op: IrOp, ps: List<&2, ReuseTok>) -> List<&2, ReuseTok>:
  match ps:
    case Nil{}: Nil{}
    case Con{h, t}: opt_ru_filter_m(opt_op_defs(op, UM0{}), Con{h, t})
def opt_ru_take_cons(h: ReuseTok, pk: RuPick) -> RuPick:
  match pk:
    case RuNo{}: RuNo{}
    case RuYes{sl, rest}: RuYes{sl, Con{h, rest}}
def opt_ru_cls(+n: U32) -> U32: Bool.pick(U32, U32.is_le(n, 1), 0, Bool.pick(U32, U32.is_eq(n, 2), 1, Bool.pick(U32, U32.is_le(n, 4), 2, 3)))
def opt_ru_take_ar(+k: U32, ps: List<&2, ReuseTok>) -> RuPick:
  match ps:
    case Nil{}: RuNo{}
    case Con{RTok{+sl, +ar}, +t}: Bool.pick(RuPick, U32.is_eq(opt_ru_cls(ar), opt_ru_cls(k)), RuYes{sl, t}, opt_ru_take_cons(RTok{sl, ar}, opt_ru_take_ar(k, t)))
def opt_ru_ctor_go(pk: RuPick, pool: List<&2, ReuseTok>, +d: U32, cid: U32, fs: List<&2, U32>, seen: U32Map, rev: List<&2, IrOp>) -> RuSt:
  match pk:
    case RuYes{sl, rest}: RuSt{opt_ru_filter_m(um_set(UM0{}, d, 1), rest), seen, Con{IReuse{d, sl, cid, fs}, rev}}
    case RuNo{}: RuSt{opt_ru_filter_m(um_set(UM0{}, d, 1), pool), seen, Con{ICtor{d, cid, fs}, rev}}
def opt_ru_ops(+ksrc: U32Map, +bu: U32Map, ops: List<&2, IrOp>, st: RuSt) -> RuSt:
  match ops st:
    case Nil{} _: st
    case Con{ITake{+ds, +s}, t} RuSt{pool, seen, rev}: (+seen1 = opt_um_inc(seen, s); +k = b5k_u32_list_len(ds); +dm = opt_um_inc_list(ds, UM0{}); +p1 = opt_ru_filter_m(dm, pool); ok = Bool.and(U32.is_ge(k, 1), Bool.and(U32.is_le(k, 8), Bool.and(U32.is_zero(um_get(ksrc, s)), Bool.and(U32.is_zero(um_get(dm, s)), U32.is_eq(um_get(seen1, s), um_get(bu, s)))))); opt_ru_ops(ksrc, bu, t, RuSt{Bool.pick(List<&2, ReuseTok>, ok, Con{RTok{s, k}, p1}, p1), seen1, Con{ITake{ds, s}, rev}}))
    case Con{ICtor{+d, cid, +fs}, t} RuSt{+pool, seen, rev}: opt_ru_ops(ksrc, bu, t, opt_ru_ctor_go(opt_ru_take_ar(b5k_u32_list_len(fs), pool), pool, d, cid, fs, opt_um_inc_list(fs, seen), rev))
    case Con{+op, t} RuSt{pool, seen, rev}: opt_ru_ops(ksrc, bu, t, RuSt{opt_ru_kill_op(op, pool), opt_op_uses(op, seen), Con{op, rev}})
def opt_ru_blk_has_ctor(mb: Maybe<&2, IrBlock>) -> Bool:
  match mb:
    case Some{IrBlock{_, ops, _}}: Bool.not(opt_all_ops(OPNoCtor{}, ops))
    case None{}: False{}

# Pass J — Pure Test-Block Jump Threading, ITake Sink, Scalar Ctor-Swap Fold & Early Exit
type JtTest is Data:
  JTNone{}
  JTSome{v: U32, k: U32, is_ne: Bool, tb: U32, fb: U32}
type BlkMap is Data:
  BMScRw{small: Bool, sc: U32Map}
  BMSroaTag{}
  BMSroaFuse{defc: U32Map, uses: U32Map, ar: U32}
  BMCp{defc: U32Map, ar: U32, gcm: U32Map}
  BMDce{uses: U32Map}
  BMStc{sfid: U32, orig: U32Map}
  BMFwd{em: RaVec<Maybe<&2, IrTerm>>}
  BMBump{ar: U32, e: U32}
  BMFuseApply{rep: RaVec<Maybe<&2, IrBlock>>}
  BMSinkPrep{prep: RaVec<List<&2, IrOp>>}
  BMIdRw{orig: U32Map, tcm: U32Map, cpm: U32Map, blks: List<&2, IrBlock>, defc: U32Map, uses: U32Map, ar: U32, fm: RaVec<TagFact>}
  BMJtRw{defc: U32Map, ar: U32, gh: U32Map, gv: U32Map, fm: RaVec<BrFact>, jtm: RaVec<JtTest>}
  BMEscApply{pret: U32, hits: U32Map}
  BMAbsRw{fid: U32, ar: U32, pn: U32, eb: U32, decs: U32Map, fm: RaVec<TagFact>}
  BMHoBeta{cf: U32Map, cn: U32Map, defc: U32Map, uses: U32Map, ar: U32}
  BMMsRw{arm: U32Map, cidm: U32Map, ex: U32Map}
  BMRmw{no_arr: Bool, cs: U32Map, uses: U32Map}
  BMSaRw{a0: U32, al: U32Map, c: U32, nw: U32}
def opt_jt_mk(+cop: U32, +a: U32, +b: U32, +ha: Bool, +va: U32, +hb: Bool, +vb: U32, +tb: U32, +fb: U32) -> JtTest: (+ne = U32.is_eq(cop, 1); Bool.pick(JtTest, Bool.and(U32.is_le(cop, 1), Bool.and(hb, Bool.not(ha))), JTSome{a, vb, ne, tb, fb}, Bool.pick(JtTest, Bool.and(U32.is_le(cop, 1), Bool.and(ha, Bool.not(hb))), JTSome{b, va, ne, tb, fb}, JTNone{})))
def opt_jt_blk_test(+uses: U32Map, +gh: U32Map, +gv: U32Map, ops: List<&2, IrOp>, term: IrTerm) -> JtTest:
  match ops term:
    case Con{IConst{+kr, +kv}, Con{ICmp{+cr, +cop, +a, +b}, Nil{}}} TBr{+c, tb, fb}: Bool.pick(JtTest, Bool.and(U32.is_eq(cr, c), Bool.and(U32.is_eq(um_get(uses, cr), 1), U32.is_eq(um_get(uses, kr), 1))), opt_jt_mk(cop, a, b, U32.is_eq(a, kr), kv, U32.is_eq(b, kr), kv, tb, fb), JTNone{})
    case Con{ICmp{+cr, +cop, +a, +b}, Nil{}} TBr{+c, tb, fb}: Bool.pick(JtTest, Bool.and(U32.is_eq(cr, c), U32.is_eq(um_get(uses, cr), 1)), opt_jt_mk(cop, a, b, U32.is_ne(um_get(gh, a), 0), um_get(gv, a), U32.is_ne(um_get(gh, b), 0), um_get(gv, b), tb, fb), JTNone{})
    case _ _: JTNone{}
def opt_jt_collect(+uses: U32Map, +gh: U32Map, +gv: U32Map, blks: List<&2, IrBlock>, m: RaVec<JtTest>) -> RaVec<JtTest>: opt_foldl3(~IrBlock, ~U32Map, ~U32Map, ~U32Map, ~RaVec<JtTest>, ~(u => h => v => b => acc => opt_un_blk(RaVec<JtTest>, b, id => ops => term => (+i = id; opt_rv_put(JtTest, U32.is_lt(i, 1024), 5n, i, opt_jt_blk_test(u, h, v, ops, term), acc)))), uses, gh, gv, blks, m)
def opt_jt_step(jt: JtTest, fact: BrFact, +tgt: U32) -> U32:
  match jt fact:
    case JTSome{tv, +tk, is_ne, tb, fb} BFEq{fv, fk}: (+eq = U32.is_eq(tk, fk); Bool.pick(U32, U32.is_eq(tv, fv), Bool.pick(U32, Bool.pick(Bool, is_ne, Bool.not(eq), eq), tb, fb), tgt))
    case JTSome{tv, tk, is_ne, tb, fb} BFNe{fv, fk}: Bool.pick(U32, Bool.and(U32.is_eq(tv, fv), U32.is_eq(tk, fk)), Bool.pick(U32, is_ne, tb, fb), tgt)
    case _ _: tgt
def opt_jt_chase(fuel: Nat, +jtm: RaVec<JtTest>, +fact: BrFact, +tgt: U32) -> U32:
  match fuel:
    case 0n: tgt
    case 1n+p: (+nxt = opt_jt_step(opt_rv_get(JtTest, JTNone{}, tgt, jtm), fact, tgt); Bool.pick(U32, U32.is_eq(nxt, tgt), tgt, opt_jt_chase(p, jtm, fact, nxt)))
def opt_jt_br_fact(is_t: Bool, +defc: U32Map, +ar: U32, sc: BrScan) -> BrFact:
  match sc:
    case BrScan{+has, +val, True{}, +cop, +a, +b}: (+ha = U32.is_ne(um_get(has, a), 0); +hb = U32.is_ne(um_get(has, b), 0); +ie = Bool.pick(Bool, is_t, U32.is_zero(cop), U32.is_ne(cop, 0)); Bool.pick(BrFact, Bool.and(hb, Bool.and(Bool.not(ha), opt_cp_can_prop(defc, ar, a))), Bool.pick(BrFact, ie, BFEq{a, um_get(val, b)}, BFNe{a, um_get(val, b)}), Bool.pick(BrFact, Bool.and(ha, Bool.and(Bool.not(hb), opt_cp_can_prop(defc, ar, b))), Bool.pick(BrFact, ie, BFEq{b, um_get(val, a)}, BFNe{b, um_get(val, a)}), BFNone{})))
    case _: BFNone{}
def opt_jt_lut_step(jt: JtTest, v: U32, k: U32) -> U32:
  match jt:
    case JTSome{tv, tk, is_ne, tb, fb}: Bool.pick(U32, Bool.and(U32.is_eq(tv, v), U32.is_eq(tk, k)), U32.add(Bool.pick(U32, is_ne, tb, fb), 1), 0)
    case JTNone{}: 0
def opt_jt_is_lut_head(fuel: Nat, +jtm: RaVec<JtTest>, +v: U32, +k: U32, +tgt: U32) -> Bool:
  match fuel:
    case 0n: True{}
    case 1n+p: (+n1 = opt_jt_lut_step(opt_rv_get(JtTest, JTNone{}, tgt, jtm), v, k); Bool.and(U32.is_ne(n1, 0), opt_jt_is_lut_head(p, jtm, v, U32.add(k, 1), U32.sub(n1, 1))))
def opt_jt_is_lut_tgt_go(jt: JtTest, jtm: RaVec<JtTest>) -> Bool:
  match jt:
    case JTSome{v, 0, is_ne, tb, fb}: opt_jt_is_lut_head(4n, jtm, v, 1, Bool.pick(U32, is_ne, tb, fb))
    case _: False{}
def opt_jt_is_lut_tgt(+jtm: RaVec<JtTest>, +tgt: U32) -> Bool: opt_jt_is_lut_tgt_go(opt_rv_get(JtTest, JTNone{}, tgt, jtm), jtm)
def opt_tsink_pure(op: IrOp) -> Bool:
  match op:
    case IConst{_, _}: True{}
    case ICmp{_, _, _, _}: True{}
    case ITag{_, _}: True{}
    case _: False{}
def opt_tsink_any(+m: U32Map, xs: List<&2, U32>) -> Bool: Bool.not(opt_alll(~U32, ~U32Map, ~(m0 => x => U32.is_zero(um_get(m0, x))), m, xs))
type TSinkRes is Data:
  TSNo{}
  TSHit{ops: List<&2, IrOp>, tk: IrOp}
def opt_tsink_find(ops_rev: List<&2, IrOp>, tail: List<&2, IrOp>, +pu: U32Map, +pd: U32Map) -> TSinkRes:
  match ops_rev:
    case Nil{}: TSNo{}
    case Con{ITake{+ds, +s}, rest}: (+k = b5k_u32_list_len(ds); Bool.pick(TSinkRes, Bool.and(U32.is_ge(k, 1), Bool.and(U32.is_le(k, 8), Bool.and(Bool.not(opt_tsink_any(pu, ds)), Bool.and(U32.is_zero(um_get(pu, s)), U32.is_zero(um_get(pd, s)))))), TSHit{b5k_list_app(IrOp, b5k_list_rev(IrOp, rest), tail), ITake{ds, s}}, TSNo{}))
    case Con{+op, rest}: Bool.pick(TSinkRes, opt_tsink_pure(op), opt_tsink_find(rest, Con{op, tail}, opt_op_uses(op, pu), opt_op_defs(op, pd)), TSNo{})
def opt_tsink_apply(r: TSinkRes, id: U32, orig: List<&2, IrOp>, c: U32, +tb: U32, +fb: U32, acc: List<&2, IrBlock>, prep: RaVec<List<&2, IrOp>>) -> SinkBlksRes:
  match r:
    case TSNo{}: SinkBlksRes{Con{IrBlock{id, orig, TBr{c, tb, fb}}, acc}, prep}
    case TSHit{nops, +tk}: SinkBlksRes{Con{IrBlock{id, nops, TBr{c, tb, fb}}, acc}, ra_vec_set(List<&2, IrOp>, 5n, fb, Con{tk, Nil{}}, ra_vec_set(List<&2, IrOp>, 5n, tb, Con{tk, Nil{}}, prep))}
def opt_tsink_scan(+preds: U32Map, blks: List<&2, IrBlock>, r: SinkBlksRes) -> SinkBlksRes:
  match blks r:
    case Nil{} _: r
    case Con{IrBlock{+id, +ops, TBr{+c, +tb, +fb}}, t} SinkBlksRes{acc, prep}: opt_tsink_scan(preds, t, opt_tsink_apply(Bool.pick(TSinkRes, opt_is_diam(preds, id, tb, fb), opt_tsink_find(b5k_list_rev(IrOp, ops), Nil{}, um_set(UM0{}, c, 1), UM0{}), TSNo{}), id, ops, c, tb, fb, acc, prep))
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
    case CSArm{+c1, +c2, +y, +x} CSArm{c1b, c2b, xb, yb}: (ok = Bool.and(U32.is_eq(c1, c1b), Bool.and(U32.is_eq(c2, c2b), Bool.and(U32.is_eq(x, xb), Bool.and(U32.is_eq(y, yb), Bool.and(U32.is_ne(x, y), Bool.and(U32.is_eq(um_get(sc, x), 1), U32.is_eq(um_get(sc, y), 1))))))); Bool.pick(CfBlksRes, ok, CfBlksRes{Con{IrBlock{id, b5k_list_app(IrOp, ops, [IConst{nr, 0}, ICmp{U32.add(nr, 1), 1, c, nr}, IUn{U32.add(nr, 2), 0, U32.add(nr, 1)}, IBin{U32.add(nr, 3), 7, x, y}, IBin{U32.add(nr, 4), 5, U32.add(nr, 3), U32.add(nr, 2)}, IBin{U32.add(nr, 5), 7, x, U32.add(nr, 4)}, IBin{U32.add(nr, 6), 7, y, U32.add(nr, 4)}, ICtor{U32.add(nr, 7), c1, [U32.add(nr, 5)]}, ICtor{U32.add(nr, 8), c1, [U32.add(nr, 6)]}, ICtor{U32.add(nr, 9), c2, [U32.add(nr, 7), U32.add(nr, 8)]}]), TRet{U32.add(nr, 9)}}, acc}, U32.add(nr, 10)}, CfBlksRes{Con{IrBlock{id, ops, TBr{c, tb, fb}}, acc}, nr}))
    case _ _: CfBlksRes{Con{IrBlock{id, ops, TBr{c, tb, fb}}, acc}, nr}
def opt_cswap_go(+sc: U32Map, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>, st: CfBlksRes) -> CfBlksRes:
  match blks st:
    case Nil{} CfBlksRes{acc, nr}: CfBlksRes{opt_elim_unreach(b5k_list_rev(IrBlock, acc)), nr}
    case Con{IrBlock{+id, ops, TBr{+c, +tb, +fb}}, t} CfBlksRes{acc, nr}: opt_cswap_go(sc, preds, bmap, t, opt_cswap_fold(sc, Bool.pick(CSwapArm, opt_is_diam(preds, id, tb, fb), opt_cswap_arm(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bmap)), CSNo{}), opt_cswap_arm(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap)), id, ops, c, tb, fb, nr, acc))
    case Con{b, t} CfBlksRes{acc, nr}: opt_cswap_go(sc, preds, bmap, t, CfBlksRes{Con{b, acc}, nr})
def opt_esc_pure_blks(blks: List<&2, IrBlock>) -> Bool: opt_all_blks(~U32, ~(_ => _ => ops => tm => Bool.and(U32.is_ne(opt_term_tag(tm), 5), opt_all_ops(OPEscPure{}, ops))), 0, blks)
def opt_esc_params_clean(+defc: U32Map, n: Nat, +idx: U32) -> Bool:
  match n:
    case 0n: True{}
    case 1n+p: Bool.and(U32.is_zero(um_get(defc, idx)), opt_esc_params_clean(defc, p, U32.add(idx, 1)))
type EscInfo is Data:
  EscInfo{decs: U32Map, ors: U32Map, zcs: U32Map}
def opt_esc_scan_ops(+defc: U32Map, +ar: U32, +gh: U32Map, +gv: U32Map, ops: List<&2, IrOp>, st: EscInfo) -> EscInfo:
  match ops st:
    case Nil{} _: st
    case Con{IBin{+d, 1, +a, +b}, t} EscInfo{+decs, ors, zcs}: opt_esc_scan_ops(defc, ar, gh, gv, t, EscInfo{Bool.pick(U32Map, Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(U32.is_lt(a, ar), Bool.and(U32.is_ne(um_get(gh, b), 0), U32.is_eq(um_get(gv, b), 1)))), um_set(decs, d, U32.add(a, 1)), decs), ors, zcs})
    case Con{IBin{+d, 15, +a, +b}, t} EscInfo{+decs, ors, zcs}: opt_esc_scan_ops(defc, ar, gh, gv, t, EscInfo{Bool.pick(U32Map, Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(U32.is_lt(a, ar), Bool.and(U32.is_ne(um_get(gh, b), 0), U32.is_eq(um_get(gv, b), 1)))), um_set(decs, d, U32.add(a, 1)), decs), ors, zcs})
    case Con{IBin{+d, 6, +a, +b}, t} EscInfo{decs, +ors, zcs}: (+p = Bool.pick(U32, U32.is_lt(a, ar), U32.add(a, 1), Bool.pick(U32, U32.is_lt(b, ar), U32.add(b, 1), 0)); opt_esc_scan_ops(defc, ar, gh, gv, t, EscInfo{decs, Bool.pick(U32Map, Bool.and(U32.is_eq(um_get(defc, d), 1), U32.is_ne(p, 0)), um_set(ors, d, p), ors), zcs}))
    case Con{ICmp{+d, 0, +a, +b}, t} EscInfo{decs, ors, +zcs}: (+ev = Bool.pick(U32, Bool.and(U32.is_ne(um_get(gh, b), 0), U32.is_zero(um_get(gv, b))), U32.add(a, 1), Bool.pick(U32, Bool.and(U32.is_ne(um_get(gh, a), 0), U32.is_zero(um_get(gv, a))), U32.add(b, 1), 0)); opt_esc_scan_ops(defc, ar, gh, gv, t, EscInfo{decs, ors, Bool.pick(U32Map, Bool.and(U32.is_eq(um_get(defc, d), 1), U32.is_ne(ev, 0)), um_set(zcs, d, ev), zcs)}))
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
    case Con{+a, t}: (+v = opt_um_lookup_or(fcm, a); Bool.and(Bool.pick(Bool, U32.is_eq(idx, pn), U32.is_eq(um_get(decs, a), U32.add(pn, 1)), Bool.pick(Bool, U32.is_eq(idx, pe), U32.is_eq(v, e2), U32.is_eq(v, idx))), opt_esc_chk_args(pn, pe, e2, decs, fcm, t, U32.add(idx, 1))))
def opt_esc_chk_join(mm: Maybe<&2, U32Map>, +fid: U32, +ar: U32, +pn: U32, +pe: U32, +e2: U32, +decs: U32Map, +c: U32, mj: Maybe<&2, IrBlock>) -> Bool:
  match mm mj:
    case Some{m1} Some{IrBlock{_, jops, TTailCall{cfid, +args}}}: Bool.and(U32.is_eq(cfid, fid), Bool.and(U32.is_eq(b5k_u32_list_len(args), ar), opt_maybe(U32Map, Bool, opt_esc_sim_ops(c, jops, m1), _ => False{}, m2 => opt_esc_chk_args(pn, pe, e2, decs, m2, args, 0))))
    case _ _: False{}
def opt_esc_chk_fb(mb: Maybe<&2, IrBlock>, +fid: U32, +ar: U32, +pn: U32, +pe: U32, +e2: U32, +decs: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, +c: U32) -> Bool:
  match mb:
    case Some{IrBlock{_, fops, TJmp{+jb}}}: Bool.and(U32.is_lt(jb, 1024), opt_esc_chk_join(opt_esc_sim_ops(c, fops, UM0{}), fid, ar, pn, pe, e2, decs, c, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, jb, bmap)))
    case _: False{}
def opt_esc_find_fb(+fid: U32, +ar: U32, +pn: U32, +pret: U32, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, ei: EscInfo, blks: List<&2, IrBlock>, +hits: U32Map) -> U32Map:
  match ei blks:
    case _ Nil{}: hits
    case EscInfo{+decs, +ors, +zcs} Con{IrBlock{_, _, TBr{+c, _, +fb}}, t}: (+ev1 = um_get(zcs, c); +e2 = U32.sub(ev1, 1); +pe1 = Bool.pick(U32, U32.is_ne(ev1, 0), um_get(ors, e2), 0); +pe = U32.sub(pe1, 1); ok = Bool.and(U32.is_ne(pe1, 0), Bool.and(U32.is_ne(pe, pn), Bool.and(U32.is_ne(pe, pret), Bool.and(U32.is_lt(fb, 1024), Bool.and(U32.is_eq(um_get(preds, fb), 1), opt_esc_chk_fb(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap), fid, ar, pn, pe, e2, decs, bmap, c)))))); opt_esc_find_fb(fid, ar, pn, pret, preds, bmap, EscInfo{decs, ors, zcs}, t, Bool.pick(U32Map, ok, um_set(hits, fb, 1), hits)))
    case ei0 Con{_, t}: opt_esc_find_fb(fid, ar, pn, pret, preds, bmap, ei0, t, hits)
def opt_esc_ret_param(mb: Maybe<&2, IrBlock>, +ar: U32) -> U32:
  match mb:
    case Some{IrBlock{_, Nil{}, TRet{+rv}}}: Bool.pick(U32, U32.is_lt(rv, ar), U32.add(rv, 1), 0)
    case _: 0
def opt_abs_args(+pn: U32, +decs: U32Map, +zcs: U32Map, +tf: TagFact, args: List<&2, U32>, +idx: U32) -> Bool:
  match tf args:
    case _ Nil{}: True{}
    case TFSome{src, cid} Con{+a, t}: Bool.and(Bool.pick(Bool, U32.is_eq(idx, pn), U32.is_eq(um_get(decs, a), U32.add(pn, 1)), Bool.or(U32.is_eq(a, idx), Bool.and(U32.is_eq(src, idx), U32.is_eq(U32.add(cid, 1), um_get(zcs, a))))), opt_abs_args(pn, decs, zcs, tf, t, U32.add(idx, 1)))
    case _ Con{+a, t}: Bool.and(Bool.pick(Bool, U32.is_eq(idx, pn), U32.is_eq(um_get(decs, a), U32.add(pn, 1)), U32.is_eq(a, idx)), opt_abs_args(pn, decs, zcs, tf, t, U32.add(idx, 1)))
def opt_esc_b0_pn(+c0: U32, +ar: U32, ops: List<&2, IrOp>, +zm: U32Map) -> U32:
  match ops:
    case Nil{}: 0
    case Con{IConst{+d, v}, t}: opt_esc_b0_pn(c0, ar, t, Bool.pick(U32Map, U32.is_zero(v), um_set(zm, d, 1), zm))
    case Con{ICmp{+d, 0, +a, +b}, t}: (+p = Bool.pick(U32, Bool.and(U32.is_eq(d, c0), Bool.and(U32.is_lt(a, ar), U32.is_ne(um_get(zm, b), 0))), U32.add(a, 1), Bool.pick(U32, Bool.and(U32.is_eq(d, c0), Bool.and(U32.is_lt(b, ar), U32.is_ne(um_get(zm, a), 0))), U32.add(b, 1), 0)); Bool.pick(U32, U32.is_ne(p, 0), p, opt_esc_b0_pn(c0, ar, t, zm)))
    case Con{_, t}: opt_esc_b0_pn(c0, ar, t, zm)
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
def trmc_no_self(fid: U32, ops: List<&2, IrOp>) -> Bool: opt_all_ops(OPNoSelf{fid}, ops)
def trmc_term_ok(+fid: U32, +ar: U32, term: IrTerm) -> Bool:
  match term:
    case TJmp{tgt}: U32.is_ne(tgt, 0)
    case TBr{_, tb, fb}: Bool.and(U32.is_ne(tb, 0), U32.is_ne(fb, 0))
    case TSwitch{_, arms, db}: Bool.and(U32.is_ne(db, 0), U32.is_zero(um_get(opt_pred_arms(arms, UM0{}), 0)))
    case TTailCall{cfid, args}: Bool.and(U32.is_eq(cfid, fid), U32.is_eq(b5k_u32_list_len(args), ar))
    case _: True{}
def trmc_chase_copies(ops: List<&2, IrOp>, +v: U32) -> U32:
  match ops:
    case Nil{}: U32.add(v, 1)
    case Con{ICopy{d, s}, t}: Bool.pick(U32, U32.is_eq(s, v), trmc_chase_copies(t, d), 0)
    case _: 0
def trmc_is_ret_chain(fuel: Nat, +bmap: RaVec<Maybe<&2, IrBlock>>, mb: Maybe<&2, IrBlock>, +v: U32) -> Bool:
  match fuel mb:
    case 0n _: False{}
    case 1n+p Some{IrBlock{_, ops, TRet{+rv}}}: (+v1 = trmc_chase_copies(ops, v); Bool.and(U32.is_ne(v1, 0), U32.is_eq(U32.sub(v1, 1), rv)))
    case 1n+p Some{IrBlock{_, ops, TJmp{+nxt}}}: (+v1 = trmc_chase_copies(ops, v); Bool.and(U32.is_ne(v1, 0), trmc_is_ret_chain(p, bmap, opt_blk_get(bmap, nxt), U32.sub(v1, 1))))
    case _ _: False{}
def trmc_jmp_find(+fid: U32, +ar: U32, +bmap: RaVec<Maybe<&2, IrBlock>>, +tgt: U32, ops: List<&2, IrOp>, +rev: List<&2, IrOp>) -> TrmcDir:
  match ops:
    case Con{ICallDirect{+rec, +cfid, +args}, Con{ICtor{+c, +cid, +fs}, +tail}}: (+h1 = trmc_last_eq(fs, rec, 0); +v1 = trmc_chase_copies(tail, c); Bool.pick(TrmcDir, Bool.and(U32.is_eq(cfid, fid), Bool.and(U32.is_eq(b5k_u32_list_len(args), ar), Bool.and(U32.is_ne(h1, 0), Bool.and(U32.is_ne(v1, 0), Bool.and(trmc_no_self(fid, rev), trmc_is_ret_chain(8n, bmap, opt_blk_get(bmap, tgt), U32.sub(v1, 1))))))), TrmcDirHit{b5k_list_rev(IrOp, rev), c, cid, fs, args, U32.sub(h1, 1)}, TrmcDirNo{}))
    case Con{op, t}: trmc_jmp_find(fid, ar, bmap, tgt, t, Con{op, rev})
    case Nil{}: TrmcDirNo{}
def trmc_dir_find(+fid: U32, +ar: U32, +rv: U32, ops: List<&2, IrOp>, +rev: List<&2, IrOp>) -> TrmcDir:
  match ops:
    case Con{ICallDirect{+rec, +cfid, +args}, Con{ICtor{+c, +cid, +fs}, Nil{}}}: (+h1 = trmc_last_eq(fs, rec, 0); Bool.pick(TrmcDir, Bool.and(U32.is_eq(cfid, fid), Bool.and(U32.is_eq(b5k_u32_list_len(args), ar), Bool.and(U32.is_eq(c, rv), Bool.and(U32.is_ne(h1, 0), trmc_no_self(fid, rev))))), TrmcDirHit{b5k_list_rev(IrOp, rev), c, cid, fs, args, U32.sub(h1, 1)}, TrmcDirNo{}))
    case Con{op, t}: trmc_dir_find(fid, ar, rv, t, Con{op, rev})
    case Nil{}: TrmcDirNo{}
def trmc_post_ok(+rec: U32, +am: U32Map, ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: True{}
    case Con{+op, t}: (+d1 = opt_op_pure_dst(op); Bool.and(Bool.and(U32.is_ne(d1, 0), Bool.and(U32.is_zero(um_get(am, U32.sub(d1, 1))), U32.is_zero(um_get(opt_op_uses(op, UM0{}), rec)))), trmc_post_ok(rec, am, t)))
def trmc_flt_split(+fid: U32, +ar: U32, ops: List<&2, IrOp>, +rev: List<&2, IrOp>) -> TrmcFlt:
  match ops:
    case Nil{}: TrmcFltNo{}
    case Con{ICallDirect{+rec, +cfid, +args}, +post}: Bool.pick(TrmcFlt, Bool.and(U32.is_eq(cfid, fid), Bool.and(U32.is_eq(b5k_u32_list_len(args), ar), Bool.and(trmc_no_self(fid, rev), trmc_post_ok(rec, opt_um_inc_list(args, UM0{}), post)))), TrmcFltHit{b5k_list_rev(IrOp, rev), rec, args, post}, TrmcFltNo{})
    case Con{op, t}: trmc_flt_split(fid, ar, t, Con{op, rev})
def trmc_chk_cons(mb: Maybe<&2, IrBlock>, +rec: U32) -> TrmcDir:
  match mb:
    case Some{IrBlock{_, Con{ICtor{+c, +cid, +fs}, Nil{}}, TRet{+rv}}}: (+h1 = trmc_last_eq(fs, rec, 0); Bool.pick(TrmcDir, Bool.and(U32.is_eq(c, rv), U32.is_ne(h1, 0)), TrmcDirHit{Nil{}, c, cid, fs, Nil{}, U32.sub(h1, 1)}, TrmcDirNo{}))
    case _: TrmcDirNo{}
def trmc_merge_h(+cur: U32, +cid: U32, +hidx: U32) -> U32: (+h1 = U32.add(U32.or(U32.shln(cid, 4n), hidx), 1); Bool.pick(U32, Bool.or(U32.is_zero(cur), U32.is_eq(cur, h1)), h1, 4294967295))
def trmc_scan_flt2(cd: TrmcDir, sk: Bool, +id: U32, +cbid: U32, +sbid: U32, +args: List<&2, U32>, st: TrmcScan) -> TrmcScan:
  match cd sk st:
    case TrmcDirHit{_, c, +cid, fs, _, hidx} True{} TrmcScan{ok, cnt, h1, mb, flth, arms}: (+nh = trmc_merge_h(h1, cid, hidx); TrmcScan{Bool.and(ok, U32.is_ne(nh, 4294967295)), U32.add(cnt, 1), nh, mb, um_set(flth, id, 1), ra_vec_set(TrmcArm, 5n, sbid, TrmcASkip{args}, ra_vec_set(TrmcArm, 5n, cbid, TrmcACons{c, cid, fs, args}, arms))})
    case _ _ TrmcScan{_, cnt, h1, mb, flth, arms}: TrmcScan{False{}, cnt, h1, mb, flth, arms}
def trmc_scan_dir(dh: TrmcDir, +fid: U32, ops: List<&2, IrOp>, st: TrmcScan) -> TrmcScan:
  match dh st:
    case TrmcDirHit{_, _, cid, _, _, hidx} TrmcScan{ok, cnt, h1, mb, flth, arms}: (+nh = trmc_merge_h(h1, cid, hidx); TrmcScan{Bool.and(ok, U32.is_ne(nh, 4294967295)), U32.add(cnt, 1), nh, mb, flth, arms})
    case TrmcDirNo{} TrmcScan{ok, cnt, h1, mb, flth, arms}: TrmcScan{Bool.and(ok, trmc_no_self(fid, ops)), cnt, h1, mb, flth, arms}
def trmc_emit_cons(tc: TcoSt, +bloop: U32, +rh: U32, +rp: U32, +cidx: U32, +nid: U32, pre: List<&2, IrOp>, +c: U32, cid: U32, fs: List<&2, U32>, mrev: List<&2, IrBlock>, erev: List<&2, IrBlock>, +nb: U32) -> TrmcRw:
  match tc:
    case TcoSt{p1r, p2r, +nr2}: (+cops = b5k_list_app(IrOp, b5k_list_rev(IrOp, p1r), b5k_list_rev(IrOp, p2r)); TrmcRw{Con{IrBlock{nb, Con{IMutField{rp, cidx, c}, Con{ICopy{rp, c}, cops}}, TJmp{bloop}}, Con{IrBlock{nid, b5k_list_app(IrOp, pre, [IConst{nr2, 0}, ICtor{c, cid, trmc_rep_last(fs, nr2)}]), TBr{rp, nb, U32.add(nb, 1)}}, mrev}}, Con{IrBlock{U32.add(nb, 1), Con{ICopy{rh, c}, Con{ICopy{rp, c}, cops}}, TJmp{bloop}}, erev}, U32.add(nr2, 1), U32.add(nb, 2)})
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
    case TrmcASkip{args} TrmcRw{mrev, erev, nr, nb}: opt_un_tco(TrmcRw, opt_tco_args(ar, UM0{}, args, 0, TcoSt{Nil{}, Nil{}, nr}), p1r => p2r => nr2 => TrmcRw{Con{IrBlock{nid, b5k_list_app(IrOp, ops, b5k_list_app(IrOp, b5k_list_rev(IrOp, p1r), b5k_list_rev(IrOp, p2r))), TJmp{bloop}}, mrev}, erev, nr2, nb})
    case TrmcANone{} rw0: trmc_rw_dir(trmc_dir_find(fid, ar, rv, ops, Nil{}), ar, bloop, rh, rp, cidx, nid, ops, rv, rw0)
def trmc_rw_jmp(dh: TrmcDir, ar: U32, bloop: U32, rh: U32, +rp: U32, cidx: U32, nid: U32, ops: List<&2, IrOp>, tgt: U32, rw: TrmcRw) -> TrmcRw:
  match dh rw:
    case TrmcDirHit{pre, c, cid, fs, args, _} TrmcRw{mrev, erev, nr, nb}: trmc_emit_cons(opt_tco_args(ar, UM0{}, args, 0, TcoSt{Nil{}, Nil{}, nr}), bloop, rh, rp, cidx, nid, pre, c, cid, fs, mrev, erev, nb)
    case TrmcDirNo{} TrmcRw{mrev, erev, nr, nb}: TrmcRw{Con{IrBlock{nid, ops, TJmp{tgt}}, mrev}, erev, nr, nb}
def trmc_emit_skip(tc: TcoSt, bloop: U32, nid: U32, ops: List<&2, IrOp>, mrev: List<&2, IrBlock>, erev: List<&2, IrBlock>, nb: U32) -> TrmcRw:
  TcoSt{p1r, p2r, nr2} = tc
  TrmcRw{Con{IrBlock{nid, b5k_list_app(IrOp, ops, b5k_list_app(IrOp, b5k_list_rev(IrOp, p1r), b5k_list_rev(IrOp, p2r))), TJmp{bloop}}, mrev}, erev, nr2, nb}
def trmc_rw_blks(+fid: U32, +ar: U32, +bloop: U32, +rh: U32, +rp: U32, +cidx: U32, +bmap: RaVec<Maybe<&2, IrBlock>>, +flth: U32Map, +arms: RaVec<TrmcArm>, blks: List<&2, IrBlock>, rw: TrmcRw) -> TrmcRw:
  match blks rw:
    case Nil{} _: rw
    case Con{IrBlock{+id, +ops, TRet{rv}}, t} rw0: trmc_rw_blks(fid, ar, bloop, rh, rp, cidx, bmap, flth, arms, t, trmc_rw_ret(fid, ar, bloop, rh, rp, cidx, Bool.pick(U32, U32.is_zero(id), bloop, id), ops, rv, opt_rv_get(TrmcArm, TrmcANone{}, id, arms), rw0))
    case Con{IrBlock{+id, +ops, TJmp{+tgt}}, t} rw0: trmc_rw_blks(fid, ar, bloop, rh, rp, cidx, bmap, flth, arms, t, trmc_rw_jmp(trmc_jmp_find(fid, ar, bmap, tgt, ops, Nil{}), ar, bloop, rh, rp, cidx, Bool.pick(U32, U32.is_zero(id), bloop, id), ops, tgt, rw0))
    case Con{IrBlock{+id, +ops, TBr{c, tb, fb}}, t} TrmcRw{mrev, erev, nr, nb}: trmc_rw_blks(fid, ar, bloop, rh, rp, cidx, bmap, flth, arms, t, TrmcRw{Con{IrBlock{Bool.pick(U32, U32.is_zero(id), bloop, id), Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(flth, id), 0), trmc_drop_call(trmc_flt_split(fid, ar, ops, Nil{}), ops), ops), TBr{c, tb, fb}}, mrev}, erev, nr, nb})
    case Con{IrBlock{+id, +ops, TTailCall{_, args}}, t} TrmcRw{mrev, erev, nr, nb}: trmc_rw_blks(fid, ar, bloop, rh, rp, cidx, bmap, flth, arms, t, trmc_emit_skip(opt_tco_args(ar, UM0{}, args, 0, TcoSt{Nil{}, Nil{}, nr}), bloop, Bool.pick(U32, U32.is_zero(id), bloop, id), ops, mrev, erev, nb))
    case Con{IrBlock{+id, ops, term}, t} TrmcRw{mrev, erev, nr, nb}: trmc_rw_blks(fid, ar, bloop, rh, rp, cidx, bmap, flth, arms, t, TrmcRw{Con{IrBlock{Bool.pick(U32, U32.is_zero(id), bloop, id), ops, term}, mrev}, erev, nr, nb})
def trmc_fin_rw(fid: U32, nm: String, ar: U32, esc: Bool, eff: Bool, is_m: Bool, bloop: U32, rh: U32, rp: U32, rw: TrmcRw) -> IrFn:
  TrmcRw{mrev, erev, nr, _} = rw
  IrFn{fid, nm, ar, nr, esc, eff, is_m, Con{IrBlock{0, [IConst{rh, 0}, IConst{rp, 0}], TJmp{bloop}}, b5k_list_app(IrBlock, b5k_list_rev(IrBlock, mrev), b5k_list_rev(IrBlock, erev))}}
def trmc_apply_sc(+fid: U32, +nm: String, +ar: U32, +nregs: U32, +esc: Bool, +eff: Bool, +is_m: Bool, +bmap: RaVec<Maybe<&2, IrBlock>>, +blks: List<&2, IrBlock>, sc: TrmcScan) -> IrFn:
  match sc:
    case TrmcScan{True{}, cnt, +h1, +maxb, flth, arms}: (+rh = U32.max(nregs, ar); low_if(IrFn, Bool.and(U32.is_gt(cnt, 0), Bool.and(U32.is_ne(h1, 0), U32.is_ne(h1, 4294967295))), _ => trmc_fin_rw(fid, nm, ar, esc, eff, is_m, U32.add(maxb, 1), rh, U32.add(rh, 1), trmc_rw_blks(fid, ar, U32.add(maxb, 1), rh, U32.add(rh, 1), U32.sub(h1, 1), bmap, flth, arms, blks, TrmcRw{Nil{}, Nil{}, U32.add(rh, 2), U32.add(maxb, 2)})), _ => IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}))
    case _: IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}
# Pass K — Higher-Order Closure Beta-Reduction & Multi-Block Record SROA
type CloTab is Data:
  CloTab{cfid: U32Map, cnc: U32Map}
def opt_ho_arm(mb: Maybe<&2, IrBlock>, +cid: U32, st: CloTab) -> CloTab:
  match mb st:
    case Some{IrBlock{_, Con{ITake{caps, 0}, Con{ICallDirect{_, tfid, _}, Nil{}}}, TRet{_}}} CloTab{cf, cn}: CloTab{um_set(cf, cid, U32.add(tfid, 1)), um_set(cn, cid, b5k_u32_list_len(caps))}
    case Some{IrBlock{_, Con{ISink{0}, Con{ICallDirect{_, tfid, _}, Nil{}}}, TRet{_}}} CloTab{cf, cn}: CloTab{um_set(cf, cid, U32.add(tfid, 1)), um_set(cn, cid, 0)}
    case _ _: st
def opt_ho_arms(+bmap: RaVec<Maybe<&2, IrBlock>>, arms: List<&2, IrSwitchArm>, st: CloTab) -> CloTab: opt_foldl(~IrSwitchArm, ~RaVec<Maybe<&2, IrBlock>>, ~CloTab, ~(bm => a => s0 => opt_un_arm(CloTab, a, cid => tgt => (+c = cid; +t = tgt; +s = s0; Bool.pick(CloTab, Bool.and(U32.is_ne(c, 38), U32.is_lt(t, 1024)), opt_ho_arm(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, t, bm), c, s), s)))), bmap, arms, st)
def opt_ho_table(fns: List<&2, IrFn>) -> CloTab:
  match fns:
    case Nil{}: CloTab{UM0{}, UM0{}}
    case Con{IrFn{0, _, _, _, _, _, _, Con{IrBlock{0, _, TSwitch{_, arms, _}}, rest}}, _}: opt_ho_arms(opt_index_blks(rest, RVEmpty{}), arms, CloTab{UM0{}, UM0{}})
    case Con{_, t}: opt_ho_table(t)
def opt_ho_beta_apply(pe: WwCtorEnt, +cf: U32Map, +cn: U32Map, +d: U32, +c: U32, +arg: U32, +acc: List<&2, IrOp>, +fused: U32Map) -> SroaRes:
  match pe:
    case WSome{v, +cid, +k, +fs}: (+ok = Bool.and(U32.is_eq(v, c), Bool.and(U32.is_ne(um_get(cf, cid), 0), U32.is_eq(k, um_get(cn, cid)))); SroaRes{Con{Bool.pick(IrOp, ok, ICallDirect{d, U32.sub(um_get(cf, cid), 1), b5k_list_app(U32, fs, [arg])}, ICallDirect{d, 0, [c, arg]}), acc}, Bool.pick(U32Map, ok, um_set(fused, c, 1), fused)})
    case WNone{}: SroaRes{Con{ICallDirect{d, 0, [c, arg]}, acc}, fused}
def opt_ho_beta_ops(+cf: U32Map, +cn: U32Map, +defc: U32Map, +uses: U32Map, +ar: U32, ops: List<&2, IrOp>, +pc: RaVec<WwCtorEnt>, st: SroaRes) -> SroaRes:
  match ops st:
    case Nil{} _: st
    case Con{ICtor{+d, +cid, +fs}, t} SroaRes{acc, fused}: opt_ho_beta_ops(cf, cn, defc, uses, ar, t, opt_rv_put(WwCtorEnt, Bool.and(U32.is_ne(um_get(cf, cid), 0), opt_is_su_ctor(defc, uses, ar, d, fs)), 6n, d, WSome{d, cid, b5k_u32_list_len(fs), fs}, pc), SroaRes{Con{ICtor{d, cid, fs}, acc}, fused})
    case Con{ICallDirect{d, 0, Con{+c, Con{+arg, Nil{}}}}, t} SroaRes{acc, fused}: opt_ho_beta_ops(cf, cn, defc, uses, ar, t, pc, opt_ho_beta_apply(ra_vec_get(WwCtorEnt, 6n, WNone{}, c, pc), cf, cn, d, c, arg, acc, fused))
    case Con{op, t} SroaRes{acc, fused}: opt_ho_beta_ops(cf, cn, defc, uses, ar, t, pc, SroaRes{Con{op, acc}, fused})
type MsInfo is Data:
  MsInfo{arm: U32Map, cidm: U32Map, bad: U32Map, htag: U32Map}
def ms_merge_cid(+c0: U32, +c1: U32) -> U32: Bool.pick(U32, U32.is_zero(c1), c0, Bool.pick(U32, Bool.or(U32.is_zero(c0), U32.is_eq(c0, c1)), c1, 4294967295))
def ms_scan_ops(ops: List<&2, IrOp>, st: MsInfo) -> MsInfo:
  match ops st:
    case Nil{} _: st
    case Con{ICtor{+d, +cid, +fs}, t} MsInfo{+arm, +cidm, +bad, htag}: (+k = b5k_u32_list_len(fs); +ok = Bool.and(U32.is_lt(d, 4096), Bool.and(U32.is_ge(k, 2), Bool.and(U32.is_le(k, 8), Bool.or(U32.is_zero(um_get(arm, d)), U32.is_eq(um_get(arm, d), k))))); ms_scan_ops(t, MsInfo{Bool.pick(U32Map, ok, um_set(arm, d, k), arm), Bool.pick(U32Map, ok, um_set(cidm, d, ms_merge_cid(um_get(cidm, d), U32.add(cid, 1))), cidm), Bool.pick(U32Map, ok, opt_um_inc_list(fs, bad), um_set(opt_um_inc_list(fs, bad), d, 1)), htag}))
    case Con{ITake{+ds, +s}, t} MsInfo{+arm, cidm, +bad, htag}: (+k = b5k_u32_list_len(ds); +ok = Bool.and(U32.is_lt(s, 4096), Bool.and(U32.is_ge(k, 2), Bool.and(U32.is_le(k, 8), Bool.or(U32.is_zero(um_get(arm, s)), U32.is_eq(um_get(arm, s), k))))); ms_scan_ops(t, MsInfo{Bool.pick(U32Map, ok, um_set(arm, s, k), arm), cidm, Bool.pick(U32Map, ok, opt_um_inc_list(ds, bad), um_set(opt_um_inc_list(ds, bad), s, 1)), htag}))
    case Con{ICopy{_, _}, t} _: ms_scan_ops(t, st)
    case Con{ISink{+s}, t} MsInfo{arm, cidm, +bad, htag}: ms_scan_ops(t, MsInfo{arm, cidm, Bool.pick(U32Map, U32.is_lt(s, 4096), bad, um_set(bad, s, 1)), htag})
    case Con{ITag{+d, +s}, t} MsInfo{arm, cidm, bad, htag}: ms_scan_ops(t, MsInfo{arm, cidm, um_set(bad, d, 1), um_set(htag, s, 1)})
    case Con{+op, t} MsInfo{arm, cidm, bad, htag}: ms_scan_ops(t, MsInfo{arm, cidm, opt_op_defs(op, opt_op_uses(op, bad)), htag})
def opt_un_ms(-R: Type, m: MsInfo, k: U32Map -> U32Map -> U32Map -> U32Map -> R) -> R:
  MsInfo{a, b, c, d} = m
  k(a, b, c, d)
def ms_scan_blks(blks: List<&2, IrBlock>, st: MsInfo) -> MsInfo: opt_fold_blks0(~MsInfo, ~(_ => ops => tm => s => opt_un_ms(MsInfo, s, arm => cidm => bad => htag => ms_scan_ops(ops, MsInfo{arm, cidm, opt_term_uses(tm, bad), htag}))), blks, st)
def ms_prop_ops(ops: List<&2, IrOp>, st: MsInfo) -> MsInfo:
  match ops st:
    case Nil{} _: st
    case Con{ICopy{+d, +s}, t} MsInfo{+arm, +cidm, +bad, +htag}: (+ad = um_get(arm, d); +as0 = um_get(arm, s); +conf = Bool.or(U32.is_ge(d, 4096), Bool.or(U32.is_ge(s, 4096), Bool.or(U32.is_ne(um_get(bad, d), 0), Bool.or(U32.is_ne(um_get(bad, s), 0), Bool.and(U32.is_ne(ad, 0), Bool.and(U32.is_ne(as0, 0), U32.is_ne(ad, as0))))))); +a2 = Bool.pick(U32, U32.is_ne(ad, 0), ad, as0); ms_prop_ops(t, Bool.pick(MsInfo, U32.is_eq(d, s), MsInfo{arm, cidm, bad, htag}, MsInfo{Bool.pick(U32Map, Bool.and(Bool.not(conf), U32.is_ne(a2, 0)), um_set(um_set(arm, d, a2), s, a2), arm), Bool.pick(U32Map, conf, cidm, um_set(cidm, d, ms_merge_cid(um_get(cidm, d), um_get(cidm, s)))), Bool.pick(U32Map, conf, um_set(um_set(bad, d, 1), s, 1), bad), Bool.pick(U32Map, Bool.and(Bool.not(conf), Bool.or(U32.is_ne(um_get(htag, d), 0), U32.is_ne(um_get(htag, s), 0))), um_set(um_set(htag, d, 1), s, 1), htag)})))
    case Con{_, t} _: ms_prop_ops(t, st)
def ms_prop_blks(blks: List<&2, IrBlock>, st: MsInfo) -> MsInfo: opt_foldl0(~IrBlock, ~MsInfo, ~(b => s => opt_un_blk(MsInfo, b, _ => ops => _ => ms_prop_ops(ops, s))), blks, st)
def ms_prop_n(k: Nat, +blks: List<&2, IrBlock>, st: MsInfo) -> MsInfo:
  match k:
    case 0n: st
    case 1n+p: ms_prop_n(p, blks, ms_prop_blks(blks, st))
def ms_v_ok(+arm: U32Map, +cidm: U32Map, +bad: U32Map, +htag: U32Map, +v: U32) -> Bool: Bool.and(U32.is_zero(um_get(bad, v)), Bool.and(U32.is_ge(um_get(arm, v), 2), Bool.and(U32.is_ne(um_get(cidm, v), 0), Bool.or(U32.is_zero(um_get(htag, v)), U32.is_ne(um_get(cidm, v), 4294967295)))))
def ms_chk_v(+arm: U32Map, +cidm: U32Map, +htag: U32Map, +v: U32, +bad: U32Map) -> U32Map: Bool.pick(U32Map, ms_v_ok(arm, cidm, bad, htag, v), bad, um_set(bad, v, 1))
def opt_op_fold_step(k: OpFold, op: IrOp, +m: U32Map) -> U32Map:
  match k op:
    case OFDefs{} _: opt_op_defs(op, m)
    case OFUses{} _: opt_op_uses(op, m)
    case OFScDirect{ret_sc} _: opt_sc_direct_op(ret_sc, op, m)
    case OFScAdd{defc, ar} _: opt_sc_add_op(defc, ar, op, m)
    case OFScProp{p} ICopy{d, s}: opt_sc_prop_copy(p, d, s, m)
    case OFScProp{p} IKeep{d, s}: opt_sc_prop_copy(p, d, s, m)
    case OFIpOrig{defc, ar} ICopy{d, s}: opt_ip_orig_step(defc, ar, d, s, m)
    case OFIpOrig{defc, ar} IKeep{d, s}: opt_ip_orig_step(defc, ar, d, s, m)
    case OFIpBad{} ICallClosure{_, fid, _}: um_set(m, fid, 1)
    case OFIpObs{sfid, sc, orig} ICallDirect{_, cfid, args}: opt_ip_obs_args(sfid, cfid, sc, orig, args, 0, m)
    case OFKeep{} IKeep{d, _}: um_set(m, d, 1)
    case OFGcCp{+defc, +km, +ar} ICopy{+d, s}: (+rs = opt_um_lookup_or(m, s); Bool.pick(U32Map, Bool.and(U32.is_ge(d, ar), Bool.and(U32.is_eq(um_get(defc, d), 1), Bool.and(U32.is_zero(um_get(km, d)), Bool.and(U32.is_zero(um_get(km, rs)), Bool.and(U32.is_ne(d, rs), opt_cp_can_prop(defc, ar, rs)))))), um_set(m, d, U32.add(rs, 1)), m))
    case OFCc{} ICallDirect{_, cfid, _}: opt_um_inc(m, cfid)
    case OFCc{} ICallClosure{_, cfid, _}: opt_um_inc(m, cfid)
    case OFB01{defc, ar} ICmp{+d, +cop, _, _}: Bool.pick(U32Map, Bool.and(U32.is_lt(cop, 6), Bool.and(U32.is_ge(d, ar), U32.is_eq(um_get(defc, d), 1))), um_set(m, d, 1), m)
    case OFIdTag{+defc, +ar} ITag{+d, +s}: Bool.pick(U32Map, Bool.and(opt_cp_can_prop(defc, ar, d), opt_cp_can_prop(defc, ar, s)), um_set(m, d, U32.add(s, 1)), m)
    case OFRuKsrc{} IKeep{_, s}: um_set(m, s, 1)
    case OFMsChk{+arm, +cidm, +htag} ICopy{d, s}: ms_chk_v(arm, cidm, htag, d, ms_chk_v(arm, cidm, htag, s, m))
    case OFMsChk{arm, cidm, htag} ITake{_, s}: ms_chk_v(arm, cidm, htag, s, m)
    case OFMsChk{arm, cidm, htag} ITag{_, s}: ms_chk_v(arm, cidm, htag, s, m)
    case OFMsChk{arm, cidm, htag} ISink{s}: ms_chk_v(arm, cidm, htag, s, m)
    case OFConsts{} IConst{d, _}: um_set(m, d, 1)
    case OFAbsZctors{} ICtor{d, cid, Nil{}}: um_set(m, d, U32.add(cid, 1))
    case OFSaConst{} IConst{d, v}: um_set(m, d, U32.add(v, 1))
    case OFSaRds{al} IArrOp{Con{_, Con{dv, Nil{}}}, 72, Con{a, _}}: Bool.pick(U32Map, U32.is_ne(um_get(al, a), 0), um_set(m, dv, 1), m)
    case OFSaRds{al} IArrOp{Con{dv, Nil{}}, 78, Con{a, _}}: Bool.pick(U32Map, U32.is_ne(um_get(al, a), 0), um_set(m, dv, 1), m)
    case OFSaProp{} ICopy{d, s}: Bool.pick(U32Map, U32.is_ne(um_get(m, s), 0), um_set(m, d, 1), m)
    case OFSaProp{} IArrOp{Con{da, _}, +aop, Con{a, _}}: Bool.pick(U32Map, Bool.and(Bool.or(Bool.and(U32.is_ge(aop, 72), U32.is_le(aop, 74)), Bool.and(U32.is_ge(aop, 79), U32.is_le(aop, 81))), U32.is_ne(um_get(m, a), 0)), um_set(m, da, 1), m)
    case _ _: m
def opt_fold_ops(+k: OpFold, ops: List<&2, IrOp>, m: U32Map) -> U32Map: opt_foldl(~IrOp, ~OpFold, ~U32Map, ~(e => op => acc => opt_op_fold_step(e, op, acc)), k, ops, m)
def opt_fold_blks_ops(+k: OpFold, blks: List<&2, IrBlock>, m: U32Map) -> U32Map: opt_foldl(~IrBlock, ~OpFold, ~U32Map, ~(e => b => acc => opt_un_blk(U32Map, b, _ => ops => _ => opt_fold_ops(e, ops, acc))), k, blks, m)
def opt_rep_um(+k: OpFold, n: Nat, +blks: List<&2, IrBlock>, m: U32Map) -> U32Map:
  match n:
    case 0n: m
    case 1n+p: opt_rep_um(k, p, blks, opt_fold_blks_ops(k, blks, m))
def opt_ops_defs(ops: List<&2, IrOp>, m: U32Map) -> U32Map: opt_fold_ops(OFDefs{}, ops, m)
def opt_blks_defs(blks: List<&2, IrBlock>, m: U32Map) -> U32Map: opt_fold_blks_ops(OFDefs{}, blks, m)
def opt_ops_uses(ops: List<&2, IrOp>, m: U32Map) -> U32Map: opt_fold_ops(OFUses{}, ops, m)
def opt_blks_uses(blks: List<&2, IrBlock>, m: U32Map) -> U32Map: opt_foldl0(~IrBlock, ~U32Map, ~(b => acc => opt_un_blk(U32Map, b, _ => ops => term => opt_term_uses(term, opt_ops_uses(ops, acc)))), blks, m)
def opt_sc_compute(+small: Bool, +ret_sc: U32Map, +psc: U32Map, +fid: U32, +ar: U32, +blks: List<&2, IrBlock>) -> U32Map: (m0 = opt_fold_blks_ops(OFScDirect{ret_sc}, blks, opt_sc_init_params(fid, psc, U32.to_nat(ar), 0, UM0{})); +pn = Bool.pick(Nat, small, 2n, 1n); +m1 = opt_rep_um(OFScProp{True{}}, pn, blks, opt_rep_um(OFScProp{False{}}, pn, blks, m0)); low_if(U32Map, Bool.and(small, U32.is_ge(fid, 3)), _ => opt_rep_um(OFScAdd{opt_blks_defs(blks, UM0{}), ar}, 6n, blks, m1), _ => m1))
def opt_ip_orig_blks(defc: U32Map, ar: U32, blks: List<&2, IrBlock>, m: U32Map) -> U32Map: opt_fold_blks_ops(OFIpOrig{defc, ar}, blks, m)
def opt_ip_bad_fns(fns: List<&2, IrFn>, m: U32Map) -> U32Map: opt_foldl0(~IrFn, ~U32Map, ~(f => acc => opt_un_fn(U32Map, f, fid => _ => _ => _ => esc => _ => is_m => blks => (+fi = fid; +ac = acc; opt_fold_blks_ops(OFIpBad{}, blks, Bool.pick(U32Map, Bool.or(U32.is_lt(fi, 3), Bool.or(U32.is_ge(fi, 2048), Bool.or(esc, is_m))), um_set(ac, fi, 1), ac))))), fns, m)
def opt_ip_obs_blks(+self_fid: U32, +sc: U32Map, +orig: U32Map, blks: List<&2, IrBlock>, obs: U32Map) -> U32Map:
  match blks:
    case Nil{}: obs
    case Con{IrBlock{_, ops, TTailCall{cfid, args}}, t}: opt_ip_obs_blks(self_fid, sc, orig, t, opt_ip_obs_args(self_fid, cfid, sc, orig, args, 0, opt_fold_ops(OFIpObs{self_fid, sc, orig}, ops, obs)))
    case Con{IrBlock{_, ops, _}, t}: opt_ip_obs_blks(self_fid, sc, orig, t, opt_fold_ops(OFIpObs{self_fid, sc, orig}, ops, obs))
def opt_ip_scan_fns(+small: Bool, +psc: U32Map, fns: List<&2, IrFn>, st: IpScan) -> IpScan:
  match fns st:
    case Nil{} _: st
    case Con{IrFn{+fid, _, +ar, _, _, _, _, +blks}, t} IpScan{+ret_sc, obs, chg}: (+sc = opt_sc_compute(small, ret_sc, psc, fid, ar, blks); orig = opt_ip_add_dep_blks(blks, opt_ip_orig_blks(opt_blks_defs(blks, UM0{}), ar, blks, opt_ip_init_orig(U32.to_nat(ar), 0, UM0{}))); obs1 = opt_ip_obs_blks(fid, sc, orig, blks, obs); +new_ret = Bool.and(U32.is_ge(fid, 3), Bool.and(U32.is_zero(um_get(ret_sc, fid)), opt_sc_all_rets(fid, ret_sc, sc, blks, False{}))); opt_ip_scan_fns(small, psc, t, IpScan{Bool.pick(U32Map, new_ret, um_set(ret_sc, fid, 1), ret_sc), obs1, Bool.or(chg, new_ret)}))
def opt_ip_fix(fuel: Nat, +small: Bool, +bad: U32Map, +fns: List<&2, IrFn>, st: IpRes) -> IpRes:
  match fuel st:
    case 0n _: st
    case _ IpRes{ret_sc, psc, False{}}: IpRes{ret_sc, psc, False{}}
    case 1n+p IpRes{ret_sc, +psc0, True{}}: opt_ip_fix(p, small, bad, fns, opt_ip_step(bad, fns, psc0, opt_ip_scan_fns(small, psc0, fns, IpScan{ret_sc, UM0{}, False{}})))
def opt_collect_ip(+small: Bool, +fns: List<&2, IrFn>, ret_sc: U32Map) -> IpRes: opt_ip_fix(Bool.pick(Nat, small, 16n, 1n), small, opt_ip_bad_fns(fns, UM0{}), fns, IpRes{ret_sc, UM0{}, True{}})
def opt_collect_ret_only(fns: List<&2, IrFn>, m: U32Map) -> U32Map: opt_foldl0(~IrFn, ~U32Map, ~(f => acc => opt_un_fn(U32Map, f, fid => _ => ar => _ => _ => _ => _ => blks => (+fi = fid; +a = ar; +bl = blks; +ac = acc; Bool.pick(U32Map, Bool.and(U32.is_ge(fi, 3), opt_sc_all_rets(fi, ac, opt_sc_compute(True{}, ac, UM0{}, fi, a, bl), bl, False{})), um_set(ac, fi, 1), ac)))), fns, m)
type RotSt is Data:
  RotSt{gh: U32Map, gv: U32Map, sx: U32Map, sk: U32Map, nr: U32, rev: List<&2, IrOp>}
def opt_rot_op(+defc: U32Map, +ar: U32, op: IrOp, st: RotSt) -> RotSt:
  match op st:
    case IConst{+d, +v} RotSt{gh, gv, sx, sk, nr, rev}:
      RotSt{um_set(gh, d, 1), um_set(gv, d, v), um_set(sx, d, 0), sk, nr, Con{IConst{d, v}, rev}}
    case ICopy{+d, +s} RotSt{+gh, +gv, +sx, +sk, nr, rev}:
      g1 = um_set(gh, d, um_get(gh, s))
      v1 = um_set(gv, d, um_get(gv, s))
      x1 = um_set(sx, d, um_get(sx, s))
      k1 = um_set(sk, d, um_get(sk, s))
      RotSt{g1, v1, x1, k1, nr, Con{ICopy{d, s}, rev}}
    case IBin{+d, +bop, +a, +b} RotSt{+gh, +gv, +sx, +sk, +nr, +rev}:
      +k = um_get(gv, b)
      +k_ok = Bool.and(U32.is_eq(um_get(gh, b), 1), Bool.and(U32.is_ge(k, 1), U32.is_le(k, 31)))
      +is_sh = Bool.and(Bool.or(U32.is_eq(bop, 8), U32.is_eq(bop, 9)), Bool.and(k_ok, opt_cp_can_prop(defc, ar, a)))
      +xa = um_get(sx, a)
      +xb = um_get(sx, b)
      +ka = um_get(sk, a)
      +kb = um_get(sk, b)
      +oa = U32.shrn(ka, 5n)
      +aa = U32.and(ka, 31)
      +ob = U32.shrn(kb, 5n)
      +ab = U32.and(kb, 31)
      +pair_ok = Bool.and(U32.is_ne(xa, 0), Bool.and(U32.is_eq(xa, xb), U32.is_ne(oa, ob)))
      +is_rot = Bool.and(
        Bool.or(U32.is_eq(bop, 6), U32.is_eq(bop, 7)),
        Bool.and(pair_ok, U32.is_eq(U32.add(aa, ab), 32)),
      )
      +rl = Bool.pick(U32, U32.is_eq(oa, 8), aa, ab)
      sx1 = Bool.pick(U32Map, is_sh, um_set(sx, d, U32.add(a, 1)), um_set(sx, d, 0))
      sk1 = Bool.pick(U32Map, is_sh, um_set(sk, d, U32.or(U32.shln(bop, 5n), k)), sk)
      low_if(
        RotSt,
        is_rot,
        _ => RotSt{
          um_set(gh, d, 0), gv, um_set(sx, d, 0), sk, U32.add(nr, 1),
          Con{IBin{d, 16, U32.sub(xa, 1), nr}, Con{IConst{nr, rl}, rev}},
        },
        _ => RotSt{um_set(gh, d, 0), gv, sx1, sk1, nr, Con{IBin{d, bop, a, b}, rev}},
      )
    case +op0 RotSt{gh, gv, sx, sk, nr, rev}:
      RotSt{opt_kill_op_dsts(op0, gh), gv, opt_kill_op_dsts(op0, sx), sk, nr, Con{op0, rev}}
def opt_rot_ops(+defc: U32Map, +ar: U32, ops: List<&2, IrOp>, st: RotSt) -> RotSt:
  match ops:
    case Nil{}: st
    case Con{op, t}: opt_rot_ops(defc, ar, t, opt_rot_op(defc, ar, op, st))
def opt_rot_step(id: U32, term: IrTerm, acc: List<&2, IrBlock>, st: RotSt) -> CfBlksRes:
  RotSt{_, _, _, _, nr1, rev} = st
  CfBlksRes{Con{IrBlock{id, b5k_list_rev(IrOp, rev), term}, acc}, nr1}
def opt_rot_blks(
  +defc: U32Map, +ar: U32, +gh: U32Map, +gv: U32Map, blks: List<&2, IrBlock>, st: CfBlksRes
) -> CfBlksRes:
  match blks st:
    case Nil{} CfBlksRes{acc, nr}: CfBlksRes{b5k_list_rev(IrBlock, acc), nr}
    case Con{IrBlock{id, ops, term}, t} CfBlksRes{acc, nr}:
      s1 = opt_rot_step(id, term, acc, opt_rot_ops(defc, ar, ops, RotSt{gh, gv, UM0{}, UM0{}, nr, Nil{}}))
      opt_rot_blks(defc, ar, gh, gv, t, s1)
def opt_rot_fin(+defc: U32Map, +ar: U32, +gh: U32Map, +gv: U32Map, r: CfBlksRes) -> CfBlksRes:
  CfBlksRes{blks1, nr1} = r
  opt_rot_blks(defc, ar, gh, gv, blks1, CfBlksRes{Nil{}, nr1})
def opt_pass_cf(do_facts: Bool, f: IrFn) -> IrFn:
  match do_facts f:
    case False{} IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}: cf_fn_fin(fid, nm, ar, esc, eff, is_m, cf_blks_go(RVEmpty{}, UM0{}, UM0{}, blks, CfBlksRes{Nil{}, nregs}))
    case True{} IrFn{fid, nm, +ar, nregs, esc, eff, is_m, +blks}: (+defc = opt_blks_defs(blks, UM0{}); opt_un_gc(IrFn, cf_gc_blks(defc, ar, blks, cf_gc_blks(defc, ar, blks, CfGConsts{UM0{}, UM0{}})), +gh => +gv => cf_fn_fin(fid, nm, ar, esc, eff, is_m, opt_rot_fin(defc, ar, gh, gv, cf_blks_go(cf_collect_facts(defc, ar, opt_preds_init(blks), blks, RVEmpty{}), gh, gv, blks, CfBlksRes{Nil{}, nregs})))))
def opt_cc_blks(blks: List<&2, IrBlock>, m: U32Map) -> U32Map: opt_fold_blks0(~U32Map, ~(_ => ops => tm => acc => (+m1 = opt_fold_ops(OFCc{}, ops, acc); +cf = opt_term_tc_fid(tm); Bool.pick(U32Map, U32.is_zero(cf), m1, opt_um_inc(m1, U32.sub(cf, 1))))), blks, m)
def opt_cc_fns(+reach: U32Map, fns: List<&2, IrFn>, m: U32Map) -> U32Map: opt_foldl(~IrFn, ~U32Map, ~U32Map, ~(r => f => acc => opt_un_fn(U32Map, f, fid => _ => _ => _ => _ => _ => _ => blks => (+ac = acc; Bool.pick(U32Map, U32.is_ne(um_get(r, fid), 0), opt_cc_blks(blks, ac), ac)))), reach, fns, m)
def opt_collect_inlines(+sc_only: Bool, +leaf: Bool, +max_ops: U32, +max_blks: U32, +fns: List<&2, IrFn>, bank: InlBank) -> InlBank: opt_collect_inlines_go(sc_only, low_if(U32Map, sc_only, _ => opt_cc_fns(opt_fn_reach(fns), fns, UM0{}), _ => UM0{}), leaf, max_ops, max_blks, fns, bank)
def opt_collect_self_tc(+en_arr: Bool, +fns: List<&2, IrFn>, bank: InlBank) -> InlBank: opt_collect_self_tc_go(en_arr, low_if(U32Map, en_arr, _ => opt_cc_fns(opt_fn_reach(fns), fns, UM0{}), _ => UM0{}), fns, bank)
def opt_ww_alias(+defc: U32Map, +ar: U32, +blks: List<&2, IrBlock>) -> U32Map: opt_rep_um(OFIpOrig{defc, ar}, 2n, blks, opt_ip_init_orig(U32.to_nat(ar), 0, UM0{}))
def opt_ww_cand_one(+fid: U32, +ar: U32, +blks: List<&2, IrBlock>, cm: U32Map) -> U32Map: (+defc = opt_blks_defs(blks, UM0{}); +al = opt_ww_alias(defc, ar, blks); opt_ww_mark_cands(fid, ar, defc, opt_ww_scan_blks(fid, al, opt_ww_tag_tgts(al, blks, UM0{}), blks, WwScan{UM0{}, UM0{}, UM0{}, UM0{}, UM0{}, UM0{}}), U32.to_nat(ar), 0, cm))
def opt_ww_cand_fns(+bad_fn: U32Map, fns: List<&2, IrFn>, cm: U32Map) -> U32Map: opt_foldl(~IrFn, ~U32Map, ~U32Map, ~(bf => f => acc => opt_un_fn(U32Map, f, fid => _ => ar => _ => _ => _ => _ => blks => (+fi = fid; +a = ar; +ac = acc; low_if(U32Map, Bool.and(U32.is_zero(um_get(bf, fi)), Bool.and(U32.is_ge(a, 1), U32.is_lt(a, 26))), _ => opt_ww_cand_one(fi, a, blks, ac), _ => ac)))), bad_fn, fns, cm)
def opt_ww_ret_ops(+v: U32, ops: List<&2, IrOp>, +cur: U32) -> U32:
  match ops:
    case Con{ICtor{d, +cid, +fs}, Nil{}}: (+k = b5k_u32_list_len(fs); +enc = U32.or(U32.shln(U32.add(cid, 1), 4n), k); Bool.pick(U32, Bool.and(U32.is_eq(d, v), Bool.and(U32.is_ge(k, 2), Bool.and(U32.is_le(k, 3), Bool.or(U32.is_zero(cur), U32.is_eq(cur, enc))))), enc, 4294967295))
    case Con{_, Nil{}}: 4294967295
    case Con{_, t}: opt_ww_ret_ops(v, t, cur)
    case Nil{}: 4294967295
def opt_ww_ret_blks(+fid: U32, blks: List<&2, IrBlock>, cur: U32) -> U32:
  match blks:
    case Nil{}: cur
    case Con{IrBlock{_, ops, TRet{v}}, t}: opt_ww_ret_blks(fid, t, opt_ww_ret_ops(v, ops, cur))
    case Con{IrBlock{_, _, TTailCall{tfid, _}}, t}: opt_ww_ret_blks(fid, t, Bool.pick(U32, U32.is_eq(tfid, fid), cur, 4294967295))
    case Con{_, t}: opt_ww_ret_blks(fid, t, cur)
def opt_ww_ret_fns(fns: List<&2, IrFn>, m: U32Map) -> U32Map: opt_foldl0(~IrFn, ~U32Map, ~(f => acc => opt_un_fn(U32Map, f, fid => _ => _ => _ => esc => eff => is_m => blks => (+fi = fid; +ac = acc; +r = Bool.pick(U32, Bool.and(U32.is_ge(fi, 3), Bool.and(Bool.not(esc), Bool.and(Bool.not(eff), Bool.not(is_m)))), opt_ww_ret_blks(fi, blks, 0), 0); Bool.pick(U32Map, Bool.and(U32.is_ne(r, 0), U32.is_lt(r, 4294967295)), um_set(ac, fi, r), ac)))), fns, m)
def opt_ww_obs_one(+fid: U32, +ar: U32, +cand: U32Map, +rc: U32Map, +blks: List<&2, IrBlock>, obs: U32Map) -> U32Map: (+defc = opt_blks_defs(blks, UM0{}); opt_ww_obs_blks(fid, defc, opt_blks_uses(blks, UM0{}), ar, opt_ww_alias(defc, ar, blks), cand, rc, blks, obs))
def opt_ww_obs_fns(+reach: U32Map, +cand: U32Map, +rc: U32Map, fns: List<&2, IrFn>, obs: U32Map) -> U32Map: opt_foldl3(~IrFn, ~U32Map, ~U32Map, ~U32Map, ~U32Map, ~(re => ca => rc0 => f => acc => opt_un_fn(U32Map, f, fid => _ => ar => _ => _ => _ => _ => blks => (+fi = fid; +ac = acc; low_if(U32Map, U32.is_ne(um_get(re, fi), 0), _ => opt_ww_obs_one(fi, ar, ca, rc0, blks, ac), _ => ac)))), reach, cand, rc, fns, obs)
def opt_un_sel(-R: Type, s: SelAux, k: U32Map -> U32Map -> U32Map -> U32Map -> R) -> R:
  SelAux{a, b, c, d} = s
  k(a, b, c, d)
def opt_sel_fn(f: IrFn) -> IrFn:
  IrFn{fid, nm, +ar, nregs, esc, eff, is_m, +blks} = f
  +defc = opt_blks_defs(blks, UM0{})
  +b01 = opt_fold_blks_ops(OFB01{defc, ar}, blks, UM0{})
  opt_un_gc(IrFn, cf_gc_blks(defc, ar, blks, CfGConsts{UM0{}, UM0{}}), gh0 => gv0 => (+gh = gh0; +gv = gv0; opt_un_sel(IrFn, opt_sel_aux_blks(defc, opt_blks_uses(blks, UM0{}), ar, b01, gh, gv, blks, SelAux{UM0{}, UM0{}, UM0{}, UM0{}}), zi => sa => sb => sq => cf_fn_fin(fid, nm, ar, esc, eff, is_m, opt_sel_go(b01, gh, gv, zi, sa, sb, sq, opt_preds_init(blks), opt_index_blks(blks, RVEmpty{}), blks, CfBlksRes{Nil{}, nregs})))))
def opt_blk_uses_mb(mb: Maybe<&2, IrBlock>) -> U32Map:
  match mb:
    case Some{IrBlock{_, ops, term}}: opt_term_uses(term, opt_ops_uses(ops, UM0{}))
    case None{}: UM0{}
def opt_un_sink(-R: Type, s: SinkSt, k: List<&2, IrOp> -> List<&2, IrOp> -> List<&2, IrOp> -> U32 -> U32 -> R) -> R:
  SinkSt{_, _, keep, st, sf, ct, cf} = s
  k(keep, st, sf, ct, cf)
def opt_sink_blk(id: U32, +ops: List<&2, IrOp>, c: U32, +tb: U32, +fb: U32, +okt: Bool, +okf: Bool, +defc: U32Map, +uses: U32Map, +ar: U32, +bmap: RaVec<Maybe<&2, IrBlock>>, acc: List<&2, IrBlock>, prep: RaVec<List<&2, IrOp>>) -> SinkBlksRes: (+ut0 = Bool.pick(U32Map, okt, opt_blk_uses_mb(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bmap)), UM0{}); +uf0 = Bool.pick(U32Map, okf, opt_blk_uses_mb(ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap)), UM0{}); opt_un_sink(SinkBlksRes, opt_sink_walk(defc, uses, ar, okt, okf, b5k_list_rev(IrOp, ops), SinkSt{ut0, uf0, Nil{}, Nil{}, Nil{}, 0, 0}), keep => st => sf => ct => cf => opt_sink_commit(U32.is_ge(ct, 4), U32.is_ge(cf, 4), id, ops, c, tb, fb, defc, uses, ar, ut0, uf0, keep, st, sf, acc, prep)))
def opt_sink_scan(+defc: U32Map, +uses: U32Map, +ar: U32, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>, r: SinkBlksRes) -> SinkBlksRes:
  match blks r:
    case Nil{} _: r
    case Con{IrBlock{+id, +ops, TBr{+c, +tb, +fb}}, t} SinkBlksRes{+acc, +prep}: (+okt = Bool.and(U32.is_ne(tb, fb), opt_is_sp(preds, id, tb)); +okf = Bool.and(U32.is_ne(tb, fb), opt_is_sp(preds, id, fb)); r1 = low_if(SinkBlksRes, Bool.or(okt, okf), _ => opt_sink_blk(id, ops, c, tb, fb, okt, okf, defc, uses, ar, bmap, acc, prep), _ => SinkBlksRes{Con{IrBlock{id, ops, TBr{c, tb, fb}}, acc}, prep}); opt_sink_scan(defc, uses, ar, preds, bmap, t, r1))
    case Con{b, t} SinkBlksRes{acc, prep}: opt_sink_scan(defc, uses, ar, preds, bmap, t, SinkBlksRes{Con{b, acc}, prep})
def opt_tco_blks(+fid: U32, +ar: U32, +hdr: U32, +fu: U32Map, blks: List<&2, IrBlock>, st: CfBlksRes) -> CfBlksRes:
  match blks st:
    case Nil{} CfBlksRes{acc, nr}: CfBlksRes{b5k_list_rev(IrBlock, acc), nr}
    case Con{IrBlock{+id, +ops, TTailCall{+cfid, +args}}, t} CfBlksRes{+acc, +nr}: (st1 = low_if(CfBlksRes, Bool.and(U32.is_eq(cfid, fid), U32.is_eq(b5k_u32_list_len(args), ar)), _ => opt_tco_emit_f(id, hdr, ar, args, acc, nr, opt_tco_fuse_ops(opt_tco_fuse_map(ar, fu, opt_ops_uses(ops, UM0{}), opt_um_inc_list(args, UM0{}), args, 0, UM0{}), ops, UM0{}, Nil{})), _ => CfBlksRes{Con{IrBlock{id, ops, TTailCall{cfid, args}}, acc}, nr}); opt_tco_blks(fid, ar, hdr, fu, t, st1))
    case Con{b, t} CfBlksRes{acc, nr}: opt_tco_blks(fid, ar, hdr, fu, t, CfBlksRes{Con{b, acc}, nr})
def opt_self_tc_rev(fid: U32, ar: U32, +id: U32, ops: List<&2, IrOp>, +val: U32, rev: List<&2, IrOp>) -> IrBlock:
  match rev:
    case Con{ICallDirect{dst, +cfid, +args}, rest}: Bool.pick(IrBlock, Bool.and(U32.is_eq(dst, val), Bool.and(U32.is_eq(cfid, fid), U32.is_eq(b5k_u32_list_len(args), ar))), IrBlock{id, b5k_list_rev(IrOp, rest), TTailCall{cfid, args}}, IrBlock{id, ops, TRet{val}})
    case _: IrBlock{id, ops, TRet{val}}
def opt_self_tc_blk(+fid: U32, +ar: U32, b: IrBlock) -> IrBlock:
  match b:
    case IrBlock{id, +ops, TRet{val}}: opt_self_tc_rev(fid, ar, id, ops, val, b5k_list_rev(IrOp, ops))
    case other: other
def opt_self_tc_blks(+fid: U32, +ar: U32, blks: List<&2, IrBlock>) -> List<&2, IrBlock>: opt_mapl2(~IrBlock, ~U32, ~U32, ~IrBlock, ~(f => a => b => opt_self_tc_blk(f, a, b)), fid, ar, blks)
def opt_tco_fn(f: IrFn) -> IrFn:
  match f:
    case IrFn{+fid, +nm, +ar, +nregs, +esc, +eff, +is_m, Con{IrBlock{+hdr, ops0, t0}, rest}}: (+blks : List<&2, IrBlock> = opt_self_tc_blks(fid, ar, Con{IrBlock{hdr, ops0, t0}, rest}); low_if(IrFn, U32.is_gt(ar, 32), _ => cf_fn_fin(fid, nm, ar, esc, eff, is_m, opt_tco_blks(fid, ar, hdr, opt_blks_uses(blks, UM0{}), blks, CfBlksRes{Nil{}, U32.max(nregs, ar)})), _ => IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}))
    case other: other
def opt_ru_blk_ud(mb: Maybe<&2, IrBlock>, m: U32Map) -> U32Map:
  match mb:
    case Some{IrBlock{_, +ops, term}}: opt_ops_defs(ops, opt_term_uses(term, opt_ops_uses(ops, m)))
    case None{}: m
def opt_ru_prop_arms(+preds: U32Map, +id: U32, +ps: List<&2, ReuseTok>, arms: List<&2, IrSwitchArm>, +pmap: RaVec<List<&2, ReuseTok>>) -> RaVec<List<&2, ReuseTok>>:
  match arms:
    case Nil{}: pmap
    case Con{IrArm{_, +tgt}, t}: opt_ru_prop_arms(preds, id, ps, t, opt_rv_put(List<&2, ReuseTok>, opt_is_sp(preds, id, tgt), 5n, tgt, ps, pmap))
def opt_ru_prop(+preds: U32Map, +jmps: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, +id: U32, term: IrTerm, ps: List<&2, ReuseTok>, +pmap: RaVec<List<&2, ReuseTok>>) -> RaVec<List<&2, ReuseTok>>:
  match term ps:
    case _ Nil{}: pmap
    case TJmp{+tgt} Con{h, t}: opt_rv_put(List<&2, ReuseTok>, opt_is_sp(preds, id, tgt), 5n, tgt, Con{h, t}, pmap)
    case TBr{_, +tb, +fb} Con{+h, +t}: (+diam = opt_is_diam(preds, id, tb, fb); +jt = um_get(jmps, tb); +m = U32.sub(jt, 1); +mbt = opt_blk_get(bmap, tb); +mbf = opt_blk_get(bmap, fb); +ok_m = Bool.and(Bool.not(Bool.or(opt_ru_blk_has_ctor(mbt), opt_ru_blk_has_ctor(mbf))), Bool.and(diam, Bool.and(U32.is_ne(jt, 0), Bool.and(U32.is_eq(jt, um_get(jmps, fb)), Bool.and(U32.is_lt(m, 1024), Bool.and(U32.is_ne(m, id), U32.is_eq(um_get(preds, m), 2))))))); Bool.pick(RaVec<List<&2, ReuseTok>>, ok_m, ra_vec_set(List<&2, ReuseTok>, 5n, m, opt_ru_filter_m(opt_ru_blk_ud(mbf, opt_ru_blk_ud(mbt, UM0{})), Con{h, t}), pmap), Bool.pick(RaVec<List<&2, ReuseTok>>, diam, ra_vec_set(List<&2, ReuseTok>, 5n, fb, Con{h, t}, ra_vec_set(List<&2, ReuseTok>, 5n, tb, Con{h, t}, pmap)), pmap)))
    case TSwitch{_, arms, +db} Con{+h, +t}: opt_rv_put(List<&2, ReuseTok>, opt_is_sp(preds, id, db), 5n, db, Con{h, t}, opt_ru_prop_arms(preds, id, Con{h, t}, arms, pmap))
    case _ _: pmap
def opt_un_ru(-R: Type, s: RuSt, k: List<&2, ReuseTok> -> List<&2, IrOp> -> R) -> R:
  RuSt{pool, _, rev} = s
  k(pool, rev)
def opt_ru_blks(+ksrc: U32Map, +preds: U32Map, +jmps: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>, +pmap: RaVec<List<&2, ReuseTok>>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{+id, +ops, +term}, t}: (+bu = opt_term_uses(term, opt_ops_uses(ops, UM0{})); opt_un_ru(List<&2, IrBlock>, opt_ru_ops(ksrc, bu, ops, RuSt{opt_ru_filter_m(bu, opt_rv_get(List<&2, ReuseTok>, Nil{}, id, pmap)), UM0{}, Nil{}}), pool => rev => Con{IrBlock{id, b5k_list_rev(IrOp, rev), term}, opt_ru_blks(ksrc, preds, jmps, bmap, t, opt_ru_prop(preds, jmps, bmap, id, term, pool, pmap))}))
def opt_ru_fn(f: IrFn) -> IrFn:
  match f:
    case IrFn{fid, nm, ar, nregs, esc, eff, is_m, +blks}: IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_ru_blks(opt_fold_blks_ops(OFRuKsrc{}, blks, UM0{}), opt_preds_init(blks), opt_jmp_tgts(blks, UM0{}), opt_index_blks(blks, RVEmpty{}), blks, RVEmpty{})}
def opt_abs_eb_ok(mb: Maybe<&2, IrBlock>, +pn: U32) -> Bool:
  match mb:
    case Some{IrBlock{_, ops, TRet{rv}}}: U32.is_zero(um_get(opt_term_uses(TRet{rv}, opt_ops_uses(ops, UM0{})), pn))
    case _: False{}
def trmc_chk_skip(mb: Maybe<&2, IrBlock>, +fid: U32, +rec: U32) -> Bool:
  match mb:
    case Some{IrBlock{_, +sops, TRet{rv}}}: Bool.and(U32.is_eq(rv, rec), Bool.and(trmc_no_self(fid, sops), U32.is_zero(um_get(opt_ops_uses(sops, UM0{}), rec))))
    case _: False{}
def trmc_scan_flt_p(ct: TrmcDir, fid: U32, +rec: U32, id: U32, tb: U32, fb: U32, mt: Maybe<&2, IrBlock>, mf: Maybe<&2, IrBlock>, args: List<&2, U32>, st: TrmcScan) -> TrmcScan:
  match ct:
    case TrmcDirHit{pre, c, cid, fs, a0, hidx}: trmc_scan_flt2(TrmcDirHit{pre, c, cid, fs, a0, hidx}, trmc_chk_skip(mf, fid, rec), id, tb, fb, args, st)
    case TrmcDirNo{}: trmc_scan_flt2(trmc_chk_cons(mf, rec), trmc_chk_skip(mt, fid, rec), id, fb, tb, args, st)
def trmc_scan_flt(+fid: U32, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, +id: U32, +tb: U32, +fb: U32, flt: TrmcFlt, st: TrmcScan) -> TrmcScan:
  match flt st:
    case TrmcFltHit{_, +rec, +args, _} _: (+br_ok = Bool.and(U32.is_ne(tb, fb), Bool.and(U32.is_lt(tb, 1024), Bool.and(U32.is_lt(fb, 1024), Bool.and(U32.is_eq(um_get(preds, tb), 1), U32.is_eq(um_get(preds, fb), 1))))); +mt = Bool.pick(Maybe<&2, IrBlock>, br_ok, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tb, bmap), None{}); +mf = Bool.pick(Maybe<&2, IrBlock>, br_ok, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, fb, bmap), None{}); trmc_scan_flt_p(trmc_chk_cons(mt, rec), fid, rec, id, tb, fb, mt, mf, args, st))
    case TrmcFltNo{} TrmcScan{_, cnt, h1, mb, flth, arms}: TrmcScan{False{}, cnt, h1, mb, flth, arms}
def trmc_scan_blks(+fid: U32, +ar: U32, +preds: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>, st: TrmcScan) -> TrmcScan:
  match blks st:
    case Nil{} _: st
    case Con{IrBlock{+id, +ops, TRet{rv}}, t} TrmcScan{ok, cnt, h1, mb, flth, arms}: trmc_scan_blks(fid, ar, preds, bmap, t, trmc_scan_dir(trmc_dir_find(fid, ar, rv, ops, Nil{}), fid, ops, TrmcScan{ok, cnt, h1, U32.max(mb, id), flth, arms}))
    case Con{IrBlock{+id, +ops, TJmp{+tgt}}, t} TrmcScan{ok, cnt, h1, mb, flth, arms}: (+st0 : TrmcScan = TrmcScan{Bool.and(ok, U32.is_ne(tgt, 0)), cnt, h1, U32.max(mb, id), flth, arms}; trmc_scan_blks(fid, ar, preds, bmap, t, Bool.pick(TrmcScan, trmc_no_self(fid, ops), st0, trmc_scan_dir(trmc_jmp_find(fid, ar, bmap, tgt, ops, Nil{}), fid, ops, st0))))
    case Con{IrBlock{+id, +ops, TBr{_, +tb, +fb}}, t} TrmcScan{ok, cnt, h1, mb, flth, arms}: (+st0 : TrmcScan = TrmcScan{Bool.and(ok, Bool.and(U32.is_ne(tb, 0), U32.is_ne(fb, 0))), cnt, h1, U32.max(mb, id), flth, arms}; trmc_scan_blks(fid, ar, preds, bmap, t, Bool.pick(TrmcScan, trmc_no_self(fid, ops), st0, trmc_scan_flt(fid, preds, bmap, id, tb, fb, trmc_flt_split(fid, ar, ops, Nil{}), st0))))
    case Con{IrBlock{+id, +ops, +term}, t} TrmcScan{ok, cnt, h1, mb, flth, arms}: trmc_scan_blks(fid, ar, preds, bmap, t, TrmcScan{Bool.and(Bool.and(ok, trmc_term_ok(fid, ar, term)), trmc_no_self(fid, ops)), cnt, h1, U32.max(mb, id), flth, arms})
def opt_trmc_fn(f: IrFn) -> IrFn:
  match f:
    case IrFn{+fid, +nm, +ar, +nregs, +esc, +eff, +is_m, +blks}: low_if(IrFn, Bool.and(U32.is_ge(fid, 3), Bool.and(Bool.not(eff), Bool.and(Bool.not(is_m), Bool.and(U32.is_ge(ar, 1), U32.is_le(ar, 16))))), _ => (+bm = opt_index_blks(blks, RVEmpty{}); trmc_apply_sc(fid, nm, ar, nregs, esc, eff, is_m, bm, blks, trmc_scan_blks(fid, ar, opt_preds_init(blks), bm, blks, TrmcScan{True{}, 0, 0, 0, UM0{}, RVEmpty{}}))), _ => IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks})
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
def ms_rw_ops(+arm: U32Map, +cidm: U32Map, +ex: U32Map, ops: List<&2, IrOp>, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: b5k_list_rev(IrOp, acc)
    case Con{ICtor{+d, cid, +fs}, t}: ms_rw_ops(arm, cidm, ex, t, Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(ex, d), 0), sroa_emit_copies(opt_ww_seq(U32.to_nat(um_get(arm, d)), U32.sub(um_get(ex, d), 1)), fs, acc), Con{ICtor{d, cid, fs}, acc}))
    case Con{ICopy{+d, +s}, t}: ms_rw_ops(arm, cidm, ex, t, Bool.pick(List<&2, IrOp>, Bool.and(U32.is_ne(um_get(ex, d), 0), U32.is_ne(um_get(ex, s), 0)), sroa_emit_copies(opt_ww_seq(U32.to_nat(um_get(arm, d)), U32.sub(um_get(ex, d), 1)), opt_ww_seq(U32.to_nat(um_get(arm, s)), U32.sub(um_get(ex, s), 1)), acc), Con{ICopy{d, s}, acc}))
    case Con{ITake{+ds, +s}, t}: ms_rw_ops(arm, cidm, ex, t, Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(ex, s), 0), sroa_emit_copies(ds, opt_ww_seq(U32.to_nat(um_get(arm, s)), U32.sub(um_get(ex, s), 1)), acc), Con{ITake{ds, s}, acc}))
    case Con{ISink{+s}, t}: ms_rw_ops(arm, cidm, ex, t, Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(ex, s), 0), sroa_emit_sinks(opt_ww_seq(U32.to_nat(um_get(arm, s)), U32.sub(um_get(ex, s), 1)), acc), Con{ISink{s}, acc}))
    case Con{ITag{+d, +s}, t}: ms_rw_ops(arm, cidm, ex, t, Con{Bool.pick(IrOp, U32.is_ne(um_get(ex, s), 0), IConst{d, U32.sub(um_get(cidm, s), 1)}, ITag{d, s}), acc})
    case Con{op, t}: ms_rw_ops(arm, cidm, ex, t, Con{op, acc})
# Pass RMW — IR Array RMW Fusion & Exit-Block In-Place Dst Coalescing
def opt_rmw_ok(+uses: U32Map, +dv: U32, +a_exp: U32, +i: U32, +v2: U32, +bop: U32, +bl: U32, +aop3: U32, +a2: U32, +i2: U32, +v3: U32, +da_ok: Bool) -> Bool: Bool.and(Bool.and(U32.is_le(bop, 1), Bool.or(U32.is_eq(aop3, 73), U32.is_eq(aop3, 79))), Bool.and(Bool.and(U32.is_eq(bl, dv), Bool.and(U32.is_eq(v3, v2), Bool.and(U32.is_eq(a2, a_exp), U32.is_eq(i2, i)))), Bool.and(U32.is_eq(um_get(uses, dv), 1), Bool.and(U32.is_eq(um_get(uses, v2), 1), da_ok))))
def opt_rmw_tail(+uses: U32Map, +orig: IrOp, +dv: U32, +achk: U32, +a: U32, +i: U32, +da_ok: Bool, rest: List<&2, IrOp>, +acc: List<&2, IrOp>) -> Nat & List<&2, IrOp>:
  match rest:
    case Con{IBin{+v2, +bop, +bl, +cv}, Con{IArrOp{Con{+da2, Nil{}}, +aop3, Con{+a2, Con{+i2, Con{+v3, Nil{}}}}}, _}}: Bool.pick(Nat & List<&2, IrOp>, opt_rmw_ok(uses, dv, achk, i, v2, bop, bl, aop3, a2, i2, v3, da_ok), (2n, Con{IArrOp{[da2], U32.add(80, bop), [a, i, cv]}, acc}), (0n, Con{orig, acc}))
    case Con{IConst{+c1, +c0}, Con{IBin{+v2, +bop, +bl, +cv}, Con{IArrOp{Con{+da2, Nil{}}, +aop3, Con{+a2, Con{+i2, Con{+v3, Nil{}}}}}, _}}}: Bool.pick(Nat & List<&2, IrOp>, opt_rmw_ok(uses, dv, achk, i, v2, bop, bl, aop3, a2, i2, v3, da_ok), (3n, Con{IArrOp{[da2], U32.add(80, bop), [a, i, cv]}, Con{IConst{c1, c0}, acc}}), (0n, Con{orig, acc}))
    case _: (0n, Con{orig, acc})
def opt_rmw_fuse_go(+uses: U32Map, ops: List<&2, IrOp>, skip: Nat, acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops skip:
    case Nil{} _: b5k_list_rev(IrOp, acc)
    case Con{_, t} 1n+p: opt_rmw_fuse_go(uses, t, p, acc)
    case Con{IArrOp{Con{+dv, Nil{}}, 78, Con{+a, Con{+i, Nil{}}}}, +rest} 0n: opt_un_pair(Nat, List<&2, IrOp>, List<&2, IrOp>, opt_rmw_tail(uses, IArrOp{[dv], 78, [a, i]}, dv, a, a, i, True{}, rest, acc), sk => a1 => opt_rmw_fuse_go(uses, rest, sk, a1))
    case Con{IArrOp{Con{+da, Con{+dv, Nil{}}}, 72, Con{+a, Con{+i, Nil{}}}}, +rest} 0n: opt_un_pair(Nat, List<&2, IrOp>, List<&2, IrOp>, opt_rmw_tail(uses, IArrOp{[da, dv], 72, [a, i]}, dv, da, a, i, U32.is_eq(um_get(uses, da), 1), rest, acc), sk => a1 => opt_rmw_fuse_go(uses, rest, sk, a1))
    case Con{op, t} 0n: opt_rmw_fuse_go(uses, t, 0n, Con{op, acc})
def opt_rmw_fuse_ops(uses: U32Map, ops: List<&2, IrOp>, acc: List<&2, IrOp>) -> List<&2, IrOp>: opt_rmw_fuse_go(uses, ops, 0n, acc)
def opt_is_exit_term(term: IrTerm) -> Bool: (+t = opt_term_tag(term); Bool.or(U32.is_eq(t, 2), Bool.or(U32.is_eq(t, 3), U32.is_eq(t, 5))))
def opt_is_tc_term(term: IrTerm) -> Bool: U32.is_eq(opt_term_tag(term), 3)
def opt_is_jmp_term(term: IrTerm) -> Bool: U32.is_eq(opt_term_tag(term), 1)
def opt_arr_inpl_ops(+no_arr: Bool, +cs: U32Map, +uses: U32Map, +id: U32, ops: List<&2, IrOp>, +cm: U32Map, +term: IrTerm, +acc: List<&2, IrOp>) -> IrBlock:
  match ops:
    case Nil{}: IrBlock{id, b5k_list_rev(IrOp, acc), opt_cp_term(cm, term)}
    case Con{IArrOp{Con{+da, Nil{}}, +aop, Con{+a0, +ra0}}, +t}: (+a = opt_um_lookup_or(cm, a0); +is_w = Bool.or(U32.is_eq(aop, 73), Bool.and(U32.is_ge(aop, 79), U32.is_le(aop, 81))); +lu = opt_ops_uses(t, opt_term_uses(term, UM0{})); +ok = Bool.and(Bool.and(is_w, U32.is_ne(da, a)), Bool.and(U32.is_zero(um_get(lu, a0)), Bool.and(U32.is_zero(um_get(lu, a)), Bool.and(U32.is_eq(um_get(lu, da), um_get(uses, da)), U32.is_zero(um_get(opt_ops_defs(t, UM0{}), da)))))); opt_arr_inpl_ops(no_arr, cs, uses, id, t, Bool.pick(U32Map, ok, um_set(cm, da, U32.add(a, 1)), cm), term, Con{IArrOp{[Bool.pick(U32, ok, a, da)], aop, Con{a, opt_map_u32(cm, ra0)}}, acc}))
    case Con{IBin{+da, +bop, +l0, +r0}, +t}: (+l = opt_um_lookup_or(cm, l0); +r = opt_um_lookup_or(cm, r0); +is_b = Bool.and(no_arr, Bool.and(Bool.and(U32.is_ne(l, 0), U32.is_zero(um_get(cs, l))), Bool.or(U32.is_le(bop, 2), Bool.or(U32.is_eq(bop, 15), Bool.and(U32.is_ge(bop, 5), U32.is_le(bop, 7)))))); +lu = opt_ops_uses(t, opt_term_uses(term, UM0{})); +td = opt_ops_defs(t, UM0{}); +l_dead = Bool.and(U32.is_zero(um_get(lu, l0)), U32.is_zero(um_get(lu, l))); +ok_out = Bool.or(opt_is_tc_term(term), U32.is_eq(um_get(td, l), 1)); +ok = Bool.and(Bool.and(is_b, Bool.and(U32.is_ne(da, l), U32.is_ne(l, r))), Bool.and(l_dead, Bool.and(ok_out, Bool.and(U32.is_eq(um_get(lu, da), um_get(uses, da)), U32.is_zero(um_get(td, da)))))); opt_arr_inpl_ops(no_arr, cs, uses, id, t, Bool.pick(U32Map, ok, um_set(cm, da, U32.add(l, 1)), cm), term, Con{IBin{Bool.pick(U32, ok, l, da), bop, l, r}, acc}))
    case Con{op, t}: opt_arr_inpl_ops(no_arr, cs, uses, id, t, cm, term, Con{opt_cp_rewrite_op(cm, op), acc})
# L17-SPEED Pass 2b: Non-Escaping Fixed-Size Local Array<U32> Stack-Promotion
type StArrCand is Data:
  StArrNo{}
  StArrHit{a0: U32, vc: U32, c: U32, vv: U32}
def opt_sa_find0(+cm: U32Map, ops: List<&2, IrOp>) -> StArrCand:
  match ops:
    case Nil{}: StArrNo{}
    case Con{IArrOp{Con{+a0, Nil{}}, 71, Con{+vc, Con{+vv, Nil{}}}}, t}: (+cv = um_get(cm, vc); +c = U32.sub(cv, 1); Bool.pick(StArrCand, Bool.and(U32.is_ne(cv, 0), Bool.and(U32.is_ge(c, 1), U32.is_le(c, 9))), StArrHit{a0, vc, c, vv}, opt_sa_find0(cm, t)))
    case Con{_, t}: opt_sa_find0(cm, t)
def opt_sa_terms_ok(+al: U32Map, blks: List<&2, IrBlock>) -> Bool: opt_all_blks(~U32Map, ~(a => _ => _ => tm => opt_alll(~U32, ~U32Map, ~(m => r => U32.is_zero(um_get(m, r))), a, opt_term_uses_list(tm))), al, blks)
def opt_sa_rw_ops(+a0: U32, +al: U32Map, +c: U32, +nw: U32, ops: List<&2, IrOp>, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: b5k_list_rev(IrOp, acc)
    case Con{IArrOp{Con{+d, Nil{}}, 71, Con{+vc, Con{+vv, Nil{}}}}, +t}: opt_sa_rw_ops(a0, al, c, nw, t, Bool.pick(List<&2, IrOp>, U32.is_eq(d, a0), Con{IArrOp{Nil{}, U32.add(1000, c), [a0, vv]}, Con{IAlloca{a0, nw}, acc}}, Con{IArrOp{[d], 71, [vc, vv]}, acc}))
    case Con{IArrOp{Con{+da, Con{+dv, Nil{}}}, 72, Con{+a, Con{+i, Nil{}}}}, +t}: opt_sa_rw_ops(a0, al, c, nw, t, Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(al, a), 0), Con{IArrOp{[dv], U32.add(1100, c), [a0, i]}, acc}, Con{IArrOp{[da, dv], 72, [a, i]}, acc}))
    case Con{IArrOp{Con{+dv, Nil{}}, 78, Con{+a, Con{+i, Nil{}}}}, +t}: opt_sa_rw_ops(a0, al, c, nw, t, Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(al, a), 0), Con{IArrOp{[dv], U32.add(1100, c), [a0, i]}, acc}, Con{IArrOp{[dv], 78, [a, i]}, acc}))
    case Con{IArrOp{Con{+da, Nil{}}, +aop, Con{+a, Con{+i, Con{+v, Nil{}}}}}, +t}: opt_sa_rw_ops(a0, al, c, nw, t, Bool.pick(List<&2, IrOp>, Bool.and(U32.is_ne(um_get(al, a), 0), Bool.or(U32.is_eq(aop, 73), U32.is_eq(aop, 79))), Con{IArrOp{Nil{}, U32.add(1200, c), [a0, i, v]}, acc}, Con{IArrOp{[da], aop, [a, i, v]}, acc}))
    case Con{IArrOp{Con{+da, Con{+dold, Nil{}}}, 74, Con{+a, Con{+i, Con{+v, Nil{}}}}}, +t}: opt_sa_rw_ops(a0, al, c, nw, t, Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(al, a), 0), Con{IArrOp{Nil{}, U32.add(1200, c), [a0, i, v]}, Con{IArrOp{[dold], U32.add(1100, c), [a0, i]}, acc}}, Con{IArrOp{[da, dold], 74, [a, i, v]}, acc}))
    case Con{ICopy{+d, +s}, t}: opt_sa_rw_ops(a0, al, c, nw, t, Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(al, s), 0), acc, Con{ICopy{d, s}, acc}))
    case Con{ISink{+s}, t}: opt_sa_rw_ops(a0, al, c, nw, t, Bool.pick(List<&2, IrOp>, U32.is_ne(um_get(al, s), 0), acc, Con{ISink{s}, acc}))
    case Con{op, t}: opt_sa_rw_ops(a0, al, c, nw, t, Con{op, acc})
def opt_map_blk_step(k: BlkMap, b: IrBlock) -> IrBlock:
  match k b:
    case BMScRw{sm, sc} IrBlock{id, ops, term}: IrBlock{id, opt_sc_rewrite_ops(sm, sc, ops, UM0{}, Nil{}), term}
    case BMSroaTag{} IrBlock{id, ops, term}: IrBlock{id, sroa_tag_ops(ops, UM0{}, Nil{}), term}
    case BMSroaFuse{defc, uses, ar} IrBlock{id, ops, term}: sroa_blk_fin(id, term, sroa_fuse_ops(defc, uses, ar, ops, RVEmpty{}, SroaRes{Nil{}, UM0{}}))
    case BMCp{defc, ar, gcm} IrBlock{id, +ops, term}: opt_un_cp(IrBlock, opt_cp_ops(defc, ar, ops, CpSt{gcm, opt_cp_bdefs(ops, UM0{}), RVEmpty{}, RVEmpty{}, 0, Nil{}}), ops2 => cm2 => _ => IrBlock{id, ops2, opt_cp_term(cm2, term)})
    case BMDce{uses} IrBlock{id, ops, term}: IrBlock{id, opt_dce_ops(uses, ops, Nil{}), term}
    case BMStc{+sfid, orig} IrBlock{id, ops, TTailCall{+cfid, +args}}: IrBlock{id, ops, TTailCall{cfid, Bool.pick(List<&2, U32>, U32.is_eq(cfid, sfid), opt_stc_args(orig, args, 0), args)}}
    case BMStc{sfid, _} IrBlock{id, ops, TRet{rv}}: opt_stc_ret_go(id, sfid, b5k_list_rev(IrOp, ops), rv)
    case BMStc{_, _} other: other
    case BMFwd{em} IrBlock{+id, ops, TJmp{+tgt}}: IrBlock{id, ops, low_if(IrTerm, Bool.and(U32.is_ne(tgt, id), U32.is_lt(tgt, 1024)), _ => opt_maybe(IrTerm, IrTerm, ra_vec_get(Maybe<&2, IrTerm>, 5n, None{}, tgt, em), _ => TJmp{tgt}, t2 => t2), _ => TJmp{tgt})}
    case BMFwd{_} other: other
    case BMBump{+ar, +e} IrBlock{id, ops, term}: IrBlock{id, opt_map_ops_rm(True{}, RMBump{ar, e}, ops), opt_rm_term(RMBump{ar, e}, term)}
    case BMFuseApply{rep} IrBlock{+id, ops, term}: opt_maybe(IrBlock, IrBlock, opt_blk_get(rep, id), _ => IrBlock{id, ops, term}, nb => nb)
    case BMSinkPrep{prep} IrBlock{+id, ops, term}: IrBlock{id, b5k_list_app(IrOp, opt_rv_get(List<&2, IrOp>, Nil{}, id, prep), ops), term}
    case BMIdRw{orig, tcm, cpm, blks, defc, uses, ar, fm} IrBlock{+id, ops, term}: IrBlock{id, opt_id_rw_one(orig, tcm, cpm, blks, opt_rv_get(TagFact, TFNone{}, id, fm), defc, uses, ar, ops), term}
    case BMJtRw{+defc, +ar, gh, gv, fm, +jtm} IrBlock{+id, +ops, TBr{+c, tb, fb}}:
      +inf = opt_rv_get(BrFact, BFNone{}, id, fm)
      +sc = cf_br_scan_ops(c, ops, BrScan{gh, gv, False{}, 0, 0, 0})
      IrBlock{id, ops, TBr{c, opt_jt_chase(8n, jtm, inf, opt_jt_chase(8n, jtm, opt_jt_br_fact(True{}, defc, ar, sc), tb)), opt_jt_chase(8n, jtm, inf, opt_jt_chase(8n, jtm, opt_jt_br_fact(False{}, defc, ar, sc), fb))}}
    case BMJtRw{_, _, _, _, fm, +jtm} IrBlock{+id, ops, TJmp{+tgt}}: IrBlock{id, ops, TJmp{Bool.pick(U32, opt_jt_is_lut_tgt(jtm, tgt), tgt, opt_jt_chase(8n, jtm, opt_rv_get(BrFact, BFNone{}, id, fm), tgt))}}
    case BMJtRw{_, _, _, _, _, _} other: other
    case BMEscApply{pret, hits} IrBlock{+id, ops, term}: Bool.pick(IrBlock, U32.is_ne(um_get(hits, id), 0), IrBlock{id, Nil{}, TRet{pret}}, IrBlock{id, ops, term})
    case BMAbsRw{fid, ar, pn, +eb, decs, fm} IrBlock{+id, +ops, TTailCall{+cfid, +args}}: Bool.pick(IrBlock, Bool.and(U32.is_eq(cfid, fid), Bool.and(U32.is_eq(b5k_u32_list_len(args), ar), Bool.and(U32.is_ne(id, eb), Bool.and(opt_all_ops(OPAbsPure{}, ops), opt_abs_args(pn, decs, opt_fold_ops(OFAbsZctors{}, ops, UM0{}), opt_rv_get(TagFact, TFNone{}, id, fm), args, 0))))), IrBlock{id, Nil{}, TJmp{eb}}, IrBlock{id, ops, TTailCall{cfid, args}})
    case BMAbsRw{_, _, _, _, _, _} other: other
    case BMHoBeta{cf, cn, defc, uses, ar} IrBlock{id, ops, term}: sroa_blk_fin(id, term, opt_ho_beta_ops(cf, cn, defc, uses, ar, ops, RVEmpty{}, SroaRes{Nil{}, UM0{}}))
    case BMMsRw{arm, cidm, ex} IrBlock{id, ops, term}: IrBlock{id, ms_rw_ops(arm, cidm, ex, ops, Nil{}), term}
    case BMRmw{+no_arr, cs, +uses} IrBlock{+id, ops, +term}: (+ops1 = opt_rmw_fuse_ops(uses, ops, Nil{}); +do_inpl = Bool.or(opt_is_exit_term(term), Bool.and(no_arr, opt_is_jmp_term(term))); Bool.pick(IrBlock, do_inpl, opt_arr_inpl_ops(Bool.and(no_arr, Bool.or(opt_is_tc_term(term), opt_is_jmp_term(term))), cs, uses, id, ops1, UM0{}, term, Nil{}), IrBlock{id, ops1, term}))
    case BMSaRw{a0, al, c, nw} IrBlock{id, ops, term}: IrBlock{id, opt_sa_rw_ops(a0, al, c, nw, ops, Nil{}), term}
def opt_map_blks(+k: BlkMap, blks: List<&2, IrBlock>) -> List<&2, IrBlock>: opt_mapl(~IrBlock, ~BlkMap, ~IrBlock, ~(e => b => opt_map_blk_step(e, b)), k, blks)
def opt_dce_round(+blks: List<&2, IrBlock>) -> List<&2, IrBlock>: opt_map_blks(BMDce{opt_blks_uses(blks, UM0{})}, blks)
def opt_pass_cp_dce(do_merge: Bool, f: IrFn) -> IrFn:
  match do_merge f:
    case True{} IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, blks}:
      +b0 = opt_merge_n(5n, opt_elim_unreach(blks))
      +b1 = opt_elim_unreach(opt_map_blks(BMFwd{opt_empty_blks(b0, RVEmpty{})}, b0))
      +defc = opt_blks_defs(b1, UM0{})
      +b1b = opt_map_blks(BMStc{fid, opt_ip_orig_blks(defc, ar, b1, opt_ip_init_orig(U32.to_nat(ar), 0, UM0{}))}, b1)
      gcm = opt_rep_um(OFGcCp{defc, opt_fold_blks_ops(OFKeep{}, b1b, UM0{}), ar}, 2n, b1b, UM0{})
      b2 = opt_cp_blks_dom(defc, ar, gcm, opt_preds_init(b1b), opt_jmp_tgts(b1b, UM0{}), b1b, RVEmpty{})
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_dce_round(opt_dce_round(b2))}
    case False{} IrFn{fid, nm, +ar, nregs, esc, eff, is_m, blks}: (+b1 = opt_elim_unreach(blks); IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_dce_round(opt_map_blks(BMCp{opt_blks_defs(b1, UM0{}), ar, UM0{}}, b1))})
def opt_un_ex(-R: Type, s: WwExSt, k: U32Map -> U32 -> R) -> R:
  WwExSt{ex, nr} = s
  k(ex, nr)
def opt_ww_rw_callee_one(+pi1: U32, +k: U32, +cinfo: U32, +fid: U32, nm: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, blks: List<&2, IrBlock>) -> IrFn: (+k1 = U32.sub(k, 1); +ex_cnt = Bool.pick(U32, U32.is_eq(cinfo, 4294967294), k, k1); +b1 = opt_map_blks(BMBump{ar, ex_cnt}, blks); +al = opt_ww_alias(opt_blks_defs(b1, UM0{}), ar, b1); opt_un_ex(IrFn, opt_ww_alloc_ex_blks(pi1, k1, al, b1, WwExSt{um_set(UM0{}, U32.sub(pi1, 1), U32.add(ar, 1)), U32.add(U32.max(nregs, ar), ex_cnt)}), ex => nr2 => cf_fn_fin(fid, nm, U32.add(ar, ex_cnt), esc, eff, is_m, opt_ww_rw_callee_blks(fid, ar, pi1, k1, cinfo, al, ex, b1, CfBlksRes{Nil{}, nr2}))))
def opt_ww_rw_callee_fn(+pidx: U32Map, +par: U32Map, +pcid: U32Map, f: IrFn) -> IrFn:
  IrFn{+fid, +nm, +ar, +nregs, +esc, +eff, +is_m, +blks} = f
  +pi1 = um_get(pidx, fid)
  low_if(IrFn, U32.is_ne(pi1, 0), _ => opt_ww_rw_callee_one(pi1, um_get(par, fid), um_get(pcid, fid), fid, nm, ar, nregs, esc, eff, is_m, blks), _ => IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks})
def opt_sink_fin(r: SinkBlksRes) -> List<&2, IrBlock>:
  SinkBlksRes{rev, prep} = r
  opt_map_blks(BMSinkPrep{prep}, b5k_list_rev(IrBlock, rev))
def opt_fn_fuse_sink(f: IrFn) -> IrFn:
  IrFn{fid, nm, +ar, nregs, esc, eff, is_m, +blks} = f
  +b1 = opt_elim_unreach(opt_map_blks(BMFuseApply{opt_fuse_scan(opt_blks_defs(blks, UM0{}), ar, opt_preds_init(blks), opt_index_blks(blks, RVEmpty{}), blks, RVEmpty{})}, blks))
  IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_sink_fin(opt_sink_scan(opt_blks_defs(b1, UM0{}), opt_blks_uses(b1, UM0{}), ar, opt_preds_init(b1), opt_index_blks(b1, RVEmpty{}), b1, SinkBlksRes{Nil{}, RVEmpty{}}))}
def opt_id_fn(f: IrFn) -> IrFn:
  IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, +blks} = f
  +defc = opt_blks_defs(blks, UM0{})
  +orig = opt_id_orig_blks(blks, opt_id_orig_blks(blks, opt_ip_init_orig(U32.to_nat(ar), 0, UM0{})))
  +tcm = opt_id_tc_blks(fid, blks, opt_id_tc_blks(fid, blks, UM0{}))
  +cpm = opt_id_cp_blks(defc, ar, blks, UM0{})
  opt_un_gc(IrFn, cf_gc_blks(defc, ar, blks, CfGConsts{UM0{}, UM0{}}), gh => gv => IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_map_blks(BMIdRw{orig, tcm, cpm, blks, defc, opt_blks_uses(blks, UM0{}), ar, opt_id_collect_tf(opt_fold_blks_ops(OFIdTag{defc, ar}, blks, UM0{}), gh, gv, opt_preds_init(blks), blks, RVEmpty{})}, blks)})
def opt_jt_round(+ar: U32, +blks: List<&2, IrBlock>) -> List<&2, IrBlock>: (+defc = opt_blks_defs(blks, UM0{}); opt_un_gc(List<&2, IrBlock>, cf_gc_blks(defc, ar, blks, CfGConsts{UM0{}, UM0{}}), gh0 => gv0 => (+gh = gh0; +gv = gv0; opt_elim_unreach(opt_map_blks(BMJtRw{defc, ar, gh, gv, cf_collect_facts(defc, ar, opt_preds_init(blks), blks, RVEmpty{}), opt_jt_collect(opt_blks_uses(blks, UM0{}), gh, gv, blks, RVEmpty{})}, blks)))))
def opt_fn_jt_ru(f: IrFn) -> IrFn:
  IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, blks} = f
  +b1 = opt_jt_round(ar, opt_jt_round(ar, blks))
  +b2 = opt_sink_fin(opt_tsink_scan(opt_preds_init(b1), b1, SinkBlksRes{Nil{}, RVEmpty{}}))
  cf_fn_fin(fid, nm, ar, esc, eff, is_m, opt_cswap_go(opt_sc_compute(True{}, UM0{}, UM0{}, fid, ar, b2), opt_preds_init(b2), opt_index_blks(b2, RVEmpty{}), b2, CfBlksRes{Nil{}, nregs}))
def opt_un_esc(-R: Type, e: EscInfo, k: U32Map -> R) -> R:
  EscInfo{decs, _, _} = e
  k(decs)
def opt_esc_fn_gc(ok: Bool, abs_ok: Bool, +fid: U32, nm: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +pn: U32, +eb: U32, +pret: U32, +defc: U32Map, +bmap: RaVec<Maybe<&2, IrBlock>>, +blks: List<&2, IrBlock>, gc: CfGConsts) -> IrFn:
  match ok abs_ok gc:
    case True{} _ CfGConsts{gh, gv}: IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_map_blks(BMEscApply{pret, opt_esc_find_fb(fid, ar, pn, pret, opt_preds_init(blks), bmap, opt_esc_scan_blks(defc, ar, gh, gv, blks, EscInfo{UM0{}, UM0{}, UM0{}}), blks, UM0{})}, blks)}
    case False{} True{} CfGConsts{+gh, +gv}: opt_un_esc(IrFn, opt_esc_scan_blks(defc, ar, gh, gv, blks, EscInfo{UM0{}, UM0{}, UM0{}}), decs => IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_map_blks(BMAbsRw{fid, ar, pn, eb, decs, opt_id_collect_tf(opt_fold_blks_ops(OFIdTag{defc, ar}, blks, UM0{}), gh, gv, opt_preds_init(blks), blks, RVEmpty{})}, blks)})
    case _ _ _: IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}
def opt_esc_fn(f: IrFn) -> IrFn:
  match f:
    case IrFn{fid, nm, +ar, nregs, esc, +eff, is_m, Con{IrBlock{0, +ops0, TBr{+c0, +tb, +fb}}, rest}}: (+blks : List<&2, IrBlock> = Con{IrBlock{0, ops0, TBr{c0, tb, fb}}, rest}; +zp = opt_esc_b0_pn(c0, ar, ops0, UM0{}); +pn = Bool.pick(U32, U32.is_lt(c0, ar), c0, U32.sub(zp, 1)); +eb = Bool.pick(U32, U32.is_lt(c0, ar), fb, tb); +bmap = opt_index_blks(blks, RVEmpty{}); +ebm = Bool.pick(Maybe<&2, IrBlock>, Bool.or(U32.is_lt(c0, ar), U32.is_ne(zp, 0)), opt_blk_get(bmap, eb), None{}); +pr1 = opt_esc_ret_param(ebm, ar); +defc = opt_blks_defs(blks, UM0{}); +clean = opt_esc_params_clean(defc, U32.to_nat(ar), 0); +ok = Bool.and(U32.is_ne(pr1, 0), Bool.and(U32.is_ne(U32.sub(pr1, 1), pn), Bool.and(opt_esc_pure_blks(blks), clean))); +abs_ok = Bool.and(Bool.not(ok), Bool.and(Bool.not(eff), Bool.and(clean, opt_abs_eb_ok(ebm, pn)))); opt_esc_fn_gc(ok, abs_ok, fid, nm, ar, nregs, esc, eff, is_m, pn, eb, U32.sub(pr1, 1), defc, bmap, blks, low_if(CfGConsts, Bool.or(ok, abs_ok), _ => cf_gc_blks(defc, ar, blks, CfGConsts{UM0{}, UM0{}}), _ => CfGConsts{UM0{}, UM0{}})))
    case other: other
def opt_msroa_go(go: Bool, fid: U32, nm: String, +ar: U32, +nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>) -> IrFn:
  match go:
    case False{}: IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}
    case True{}: opt_un_ms(IrFn, ms_prop_n(8n, blks, ms_scan_blks(blks, MsInfo{UM0{}, UM0{}, opt_um_set_list(opt_ww_seq(U32.to_nat(ar), 0), 1, UM0{}), UM0{}})), a0 => c0 => bd0 => h0 => (+arm0 = a0; +cidm0 = c0; +htag0 = h0; opt_un_ms(IrFn, ms_prop_n(8n, blks, MsInfo{arm0, cidm0, opt_fold_blks_ops(OFMsChk{arm0, cidm0, htag0}, blks, bd0), htag0}), a1 => c1 => bd1 => h1 => (+arm = a1; +cidm = c1; opt_un_ex(IrFn, ms_alloc_blks(arm, cidm, bd1, h1, blks, WwExSt{UM0{}, nregs}), ex0 => nr2_ => (+ex = ex0; +nr2 = nr2_; +ok = Bool.and(U32.is_gt(nr2, nregs), Bool.and(U32.is_lt(nr2, 7500), opt_all_blks_ops(OPMsEdge{ex}, blks))); IrFn{fid, nm, ar, Bool.pick(U32, ok, nr2, nregs), esc, eff, is_m, Bool.pick(List<&2, IrBlock>, ok, opt_map_blks(BMMsRw{arm, cidm, ex}, blks), blks)}))))))
def opt_msroa_fn(f: IrFn) -> IrFn:
  IrFn{+fid, nm, ar, +nregs, esc, eff, is_m, blks} = f
  opt_msroa_go(Bool.and(U32.is_ge(fid, 3), U32.is_lt(nregs, 4096)), fid, nm, ar, nregs, esc, eff, is_m, blks)
def opt_sa_apply(cand: StArrCand, fid: U32, nm: String, +ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, +sc: U32Map) -> IrFn:
  match cand:
    case StArrNo{}: IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}
    case StArrHit{+a0, _, +c, vv}:
      +al = opt_rep_um(OFSaProp{}, 6n, blks, um_set(UM0{}, a0, 1))
      +vv_ok = Bool.or(U32.is_eq(um_get(sc, vv), 1), Bool.not(opt_all_blks_ops(OPSaNoBin{opt_fold_blks_ops(OFSaRds{al}, blks, UM0{})}, blks)))
      +ok = Bool.and(vv_ok, Bool.and(U32.is_zero(um_get(opt_ra_vs(RAHas{al}, opt_ww_seq(U32.to_nat(ar), 0), UM0{}), 0)), Bool.and(opt_sa_terms_ok(al, blks), opt_all_blks_ops(OPSaChk{a0, al, sc}, blks))))
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, Bool.pick(List<&2, IrBlock>, ok, opt_map_blks(BMSaRw{a0, al, c, U32.shln(1, U32.to_nat(c))}, blks), blks)}
def opt_sa_fn(+ret_sc: U32Map, +psc: U32Map, f: IrFn) -> IrFn:
  match f:
    case IrFn{+fid, nm, +ar, +nregs, esc, +eff, +is_m, Con{IrBlock{0, +ops0, +t0}, +rest}}: (+blks : List<&2, IrBlock> = Con{IrBlock{0, ops0, t0}, rest}; +can = Bool.and(U32.is_ge(fid, 3), Bool.and(Bool.not(eff), Bool.and(Bool.not(is_m), Bool.and(U32.is_lt(nregs, 2048), opt_all_blks_ops(OPNoAlloca{}, blks))))); +sc = Bool.pick(U32Map, can, opt_sc_compute(True{}, ret_sc, psc, fid, ar, blks), UM0{}); opt_sa_apply(Bool.pick(StArrCand, can, opt_sa_find0(opt_fold_ops(OFSaConst{}, ops0, UM0{}), ops0), StArrNo{}), fid, nm, ar, nregs, esc, eff, is_m, blks, sc))
    case other: other
# Pass L — Dense Switch / Table-Dispatch IR Lowering (ILut)
type LutTest is Data:
  LutTNo{}
  LutTSome{idx: U32, kv: U32, is_ne: Bool, tb: U32, fb: U32, pre: List<&2, IrOp>}
type OptLutArm is Data:
  LutANo{}
  LutASome{is_ret: Bool, dst: U32, join: U32, val: U32}
type LutWalk is Data:
  LutWNo{}
  LutWHit{is_ret: Bool, dst: U32, join: U32, def_val: U32, vals: List<&2, U32>}
def opt_lut_test_mk(+cop: U32, +a: U32, +b: U32, +ha: Bool, +va: U32, +hb: Bool, +vb: U32, +tb: U32, +fb: U32, +pre: List<&2, IrOp>) -> LutTest: (+ne = U32.is_eq(cop, 1); Bool.pick(LutTest, Bool.and(U32.is_le(cop, 1), Bool.and(hb, Bool.not(ha))), LutTSome{a, vb, ne, tb, fb, pre}, Bool.pick(LutTest, Bool.and(U32.is_le(cop, 1), Bool.and(ha, Bool.not(hb))), LutTSome{b, va, ne, tb, fb, pre}, LutTNo{})))
def opt_lut_test_rev(+allow_pre: Bool, +gh: U32Map, +gv: U32Map, rev: List<&2, IrOp>, +c: U32, +tb: U32, +fb: U32) -> LutTest:
  match rev:
    case Con{ICmp{+cr, +cop, +a, +b}, Con{IConst{+kr, +kv}, +rest}}: (+ok = Bool.and(U32.is_eq(cr, c), Bool.or(allow_pre, opt_is_nil_ops(rest))); +ha = Bool.or(U32.is_eq(a, kr), U32.is_ne(um_get(gh, a), 0)); +va = Bool.pick(U32, U32.is_eq(a, kr), kv, um_get(gv, a)); +hb = Bool.or(U32.is_eq(b, kr), U32.is_ne(um_get(gh, b), 0)); +vb = Bool.pick(U32, U32.is_eq(b, kr), kv, um_get(gv, b)); Bool.pick(LutTest, ok, opt_lut_test_mk(cop, a, b, ha, va, hb, vb, tb, fb, Bool.pick(List<&2, IrOp>, allow_pre, b5k_list_rev(IrOp, Con{IConst{kr, kv}, rest}), Nil{})), LutTNo{}))
    case Con{ICmp{+cr, +cop, +a, +b}, +rest}: (+ok = Bool.and(U32.is_eq(cr, c), Bool.or(allow_pre, opt_is_nil_ops(rest))); Bool.pick(LutTest, ok, opt_lut_test_mk(cop, a, b, U32.is_ne(um_get(gh, a), 0), um_get(gv, a), U32.is_ne(um_get(gh, b), 0), um_get(gv, b), tb, fb, Bool.pick(List<&2, IrOp>, allow_pre, b5k_list_rev(IrOp, rest), Nil{})), LutTNo{}))
    case +rest: Bool.pick(LutTest, Bool.or(allow_pre, opt_is_nil_ops(rest)), LutTSome{c, 0, True{}, tb, fb, Bool.pick(List<&2, IrOp>, allow_pre, b5k_list_rev(IrOp, rest), Nil{})}, LutTNo{})
def opt_lut_test_blk(allow_pre: Bool, +gh: U32Map, +gv: U32Map, ops: List<&2, IrOp>, term: IrTerm) -> LutTest:
  match term:
    case TBr{c, tb, fb}: opt_lut_test_rev(allow_pre, gh, gv, b5k_list_rev(IrOp, ops), c, tb, fb)
    case _: LutTNo{}
def opt_lut_arm_ops(+gh: U32Map, +gv: U32Map, ops: List<&2, IrOp>, term: IrTerm) -> OptLutArm:
  match ops term:
    case Nil{} TRet{+r}: Bool.pick(OptLutArm, U32.is_ne(um_get(gh, r), 0), LutASome{True{}, 0, 0, um_get(gv, r)}, LutANo{})
    case Con{IConst{+d, +v}, Nil{}} TRet{+r}: Bool.pick(OptLutArm, U32.is_eq(d, r), LutASome{True{}, 0, 0, v}, Bool.pick(OptLutArm, U32.is_ne(um_get(gh, r), 0), LutASome{True{}, 0, 0, um_get(gv, r)}, LutANo{}))
    case Con{ICopy{+d, +s}, Nil{}} TRet{+r}: Bool.pick(OptLutArm, Bool.and(U32.is_eq(d, r), U32.is_ne(um_get(gh, s), 0)), LutASome{True{}, 0, 0, um_get(gv, s)}, LutANo{})
    case Con{IConst{+d1, +v}, Con{ICopy{+d2, +s}, Nil{}}} TRet{+r}: Bool.pick(OptLutArm, Bool.and(U32.is_eq(d1, s), U32.is_eq(d2, r)), LutASome{True{}, 0, 0, v}, LutANo{})
    case Con{IConst{+d, +v}, Nil{}} TJmp{j}: LutASome{False{}, d, j, v}
    case Con{ICopy{+d, +s}, Nil{}} TJmp{j}: Bool.pick(OptLutArm, U32.is_ne(um_get(gh, s), 0), LutASome{False{}, d, j, um_get(gv, s)}, LutANo{})
    case Con{IConst{+d1, +v}, Con{ICopy{+d2, +s}, Nil{}}} TJmp{j}: Bool.pick(OptLutArm, U32.is_eq(d1, s), LutASome{False{}, d2, j, v}, LutANo{})
    case Con{IBin{_, 1, _, _}, rest} tm: opt_lut_arm_ops(gh, gv, rest, tm)
    case Con{IBin{_, 15, _, _}, rest} tm: opt_lut_arm_ops(gh, gv, rest, tm)
    case _ _: LutANo{}
def opt_lut_arm_blk(+gh: U32Map, +gv: U32Map, mb: Maybe<&2, IrBlock>) -> OptLutArm:
  match mb:
    case Some{IrBlock{_, ops, term}}: opt_lut_arm_ops(gh, gv, ops, term)
    case None{}: LutANo{}
def opt_lut_arm_fin(+k: U32, +is_ret: Bool, +dst: U32, +join: U32, a: OptLutArm, acc: List<&2, U32>) -> LutWalk:
  match is_ret a:
    case True{} LutASome{True{}, _, _, dv}: Bool.pick(LutWalk, U32.is_ge(k, 4), LutWHit{True{}, 0, 0, dv, b5k_list_rev(U32, acc)}, LutWNo{})
    case False{} LutASome{False{}, d, j, dv}: Bool.pick(LutWalk, Bool.and(U32.is_ge(k, 4), Bool.and(U32.is_eq(d, dst), U32.is_eq(j, join))), LutWHit{False{}, dst, join, dv, b5k_list_rev(U32, acc)}, LutWNo{})
    case _ _: LutWNo{}
type LutStep is Data:
  LutSNext{ne_b: U32, val: U32}
  LutSDone{w: LutWalk}
def opt_lut_walk_arm(+is_ret: Bool, +dst: U32, +join: U32, +ne_blk: U32, a: OptLutArm) -> LutStep:
  match is_ret a:
    case True{} LutASome{True{}, _, _, v}: LutSNext{ne_blk, v}
    case False{} LutASome{False{}, d, j, v}: Bool.pick(LutStep, Bool.and(U32.is_eq(d, dst), U32.is_eq(j, join)), LutSNext{ne_blk, v}, LutSDone{LutWNo{}})
    case _ _: LutSDone{LutWNo{}}
def opt_lut_walk_step(+bmap: RaVec<Maybe<&2, IrBlock>>, +gh: U32Map, +gv: U32Map, +idx: U32, +k: U32, +is_ret: Bool, +dst: U32, +join: U32, +ops: List<&2, IrOp>, +term: IrTerm, t: LutTest, +acc: List<&2, U32>) -> LutStep:
  match t:
    case LutTSome{tv, tk, +is_ne, +tb, +fb, _}: (+ok = Bool.and(U32.is_eq(tv, idx), U32.is_eq(tk, k)); +eq_b = Bool.pick(U32, is_ne, fb, tb); +ne_b = Bool.pick(U32, is_ne, tb, fb); Bool.pick(LutStep, ok, opt_lut_walk_arm(is_ret, dst, join, ne_b, opt_lut_arm_blk(gh, gv, opt_blk_get(bmap, eq_b))), LutSDone{opt_lut_arm_fin(k, is_ret, dst, join, opt_lut_arm_ops(gh, gv, ops, term), acc)}))
    case LutTNo{}: LutSDone{opt_lut_arm_fin(k, is_ret, dst, join, opt_lut_arm_ops(gh, gv, ops, term), acc)}
def opt_lut_walk_blk(+bmap: RaVec<Maybe<&2, IrBlock>>, +preds: U32Map, +gh: U32Map, +gv: U32Map, +idx: U32, +k: U32, +is_ret: Bool, +dst: U32, +join: U32, +bid: U32, mb: Maybe<&2, IrBlock>, +acc: List<&2, U32>) -> LutStep:
  match mb:
    case Some{IrBlock{_, +ops, +term}}: (+ok_t = U32.is_eq(um_get(preds, bid), 1); Bool.pick(LutStep, ok_t, opt_lut_walk_step(bmap, gh, gv, idx, k, is_ret, dst, join, ops, term, opt_lut_test_blk(False{}, gh, gv, ops, term), acc), LutSDone{opt_lut_arm_fin(k, is_ret, dst, join, opt_lut_arm_ops(gh, gv, ops, term), acc)}))
    case None{}: LutSDone{LutWNo{}}
def opt_lut_walk(fuel: Nat, +bmap: RaVec<Maybe<&2, IrBlock>>, +preds: U32Map, +gh: U32Map, +gv: U32Map, +idx: U32, +k: U32, +is_ret: Bool, +dst: U32, +join: U32, st: LutStep, +acc: List<&2, U32>) -> LutWalk:
  match fuel st:
    case 0n _: LutWNo{}
    case _ LutSDone{w}: w
    case 1n+p LutSNext{+bid, +v}: opt_lut_walk(p, bmap, preds, gh, gv, idx, U32.add(k, 1), is_ret, dst, join, opt_lut_walk_blk(bmap, preds, gh, gv, idx, U32.add(k, 1), is_ret, dst, join, bid, opt_blk_get(bmap, bid), Con{v, acc}), Con{v, acc})
type LutBlkRes is Data:
  LutBlkRes{blk: IrBlock, nr: U32, hit: Bool}
type LutFnRes is Data:
  LutFnRes{blks: List<&2, IrBlock>, nr: U32, chg: Bool}
def opt_lut_head_w(w: LutWalk, id: U32, +idx: U32, ops: List<&2, IrOp>, term: IrTerm, pre: List<&2, IrOp>, +nr: U32) -> LutBlkRes:
  match w:
    case LutWHit{True{}, _, _, dv, vs}: LutBlkRes{IrBlock{id, b5k_list_app(IrOp, pre, Con{ILut{nr, idx, dv, vs}, Nil{}}), TRet{nr}}, U32.add(nr, 1), True{}}
    case LutWHit{False{}, d, j, dv, vs}: LutBlkRes{IrBlock{id, b5k_list_app(IrOp, pre, Con{ILut{d, idx, dv, vs}, Nil{}}), TJmp{j}}, nr, True{}}
    case LutWNo{}: LutBlkRes{IrBlock{id, ops, term}, nr, False{}}
def opt_lut_head_arm(a: OptLutArm, +bmap: RaVec<Maybe<&2, IrBlock>>, +preds: U32Map, +gh: U32Map, +gv: U32Map, id: U32, +idx: U32, +ne_b: U32, ops: List<&2, IrOp>, term: IrTerm, pre: List<&2, IrOp>, nr: U32) -> LutBlkRes:
  match a:
    case LutASome{+is_ret, +dst, +join, +v0}: opt_lut_head_w(opt_lut_walk(256n, bmap, preds, gh, gv, idx, 0, is_ret, dst, join, LutSNext{ne_b, v0}, Nil{}), id, idx, ops, term, pre, nr)
    case LutANo{}: LutBlkRes{IrBlock{id, ops, term}, nr, False{}}
def opt_lut_head_t(t: LutTest, +bmap: RaVec<Maybe<&2, IrBlock>>, +preds: U32Map, +gh: U32Map, +gv: U32Map, id: U32, ops: List<&2, IrOp>, term: IrTerm, nr: U32) -> LutBlkRes:
  match t:
    case LutTSome{+idx, 0, +is_ne, +tb, +fb, pre}: (+eq_b = Bool.pick(U32, is_ne, fb, tb); +ne_b = Bool.pick(U32, is_ne, tb, fb); opt_lut_head_arm(opt_lut_arm_blk(gh, gv, opt_blk_get(bmap, eq_b)), bmap, preds, gh, gv, id, idx, ne_b, ops, term, pre, nr))
    case _: LutBlkRes{IrBlock{id, ops, term}, nr, False{}}
def opt_lut_try_head(+bmap: RaVec<Maybe<&2, IrBlock>>, +preds: U32Map, +gh: U32Map, +gv: U32Map, +id: U32, +ops: List<&2, IrOp>, +term: IrTerm, +nr: U32) -> LutBlkRes: opt_lut_head_t(opt_lut_test_blk(True{}, gh, gv, ops, term), bmap, preds, gh, gv, id, ops, term, nr)
def opt_lut_acc_res(r: LutBlkRes, chg: Bool, acc: List<&2, IrBlock>) -> LutFnRes:
  LutBlkRes{nb, nr1, hit} = r
  LutFnRes{Con{nb, acc}, nr1, Bool.or(chg, hit)}
def opt_lut_blks(+bmap: RaVec<Maybe<&2, IrBlock>>, +preds: U32Map, +gh: U32Map, +gv: U32Map, blks: List<&2, IrBlock>, st: LutFnRes) -> LutFnRes:
  match blks st:
    case Nil{} LutFnRes{acc, nr, chg}: LutFnRes{b5k_list_rev(IrBlock, acc), nr, chg}
    case Con{IrBlock{id, ops, term}, t} LutFnRes{acc, nr, chg}: opt_lut_blks(bmap, preds, gh, gv, t, opt_lut_acc_res(opt_lut_try_head(bmap, preds, gh, gv, id, ops, term, nr), chg, acc))
def opt_lut_strip_consts(ops: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Con{IConst{_, _}, t}: opt_lut_strip_consts(t)
    case xs: xs
def opt_lut_norm_ops(fid: U32, nm: String, +ar: U32, nr: U32, esc: Bool, eff: Bool, is_m: Bool, +ops: List<&2, IrOp>, +r: U32, stripped: List<&2, IrOp>) -> IrFn:
  match stripped:
    case Con{ILut{+d, +iv, +dv, +vs}, Nil{}}:
      +ok = Bool.and(U32.is_eq(d, r), U32.is_lt(iv, ar))
      IrFn{fid, nm, ar, Bool.pick(U32, ok, U32.add(ar, 1), nr), esc, eff, is_m, Con{IrBlock{0, Bool.pick(List<&2, IrOp>, ok, Con{ILut{ar, iv, dv, vs}, Nil{}}, ops), TRet{Bool.pick(U32, ok, ar, r)}}, Nil{}}}
    case _: IrFn{fid, nm, ar, nr, esc, eff, is_m, Con{IrBlock{0, ops, TRet{r}}, Nil{}}}
def opt_lut_norm_fn(fid: U32, nm: String, +ar: U32, nr: U32, esc: Bool, eff: Bool, is_m: Bool, blks: List<&2, IrBlock>) -> IrFn:
  match blks:
    case Con{IrBlock{0, +ops, TRet{+r}}, Nil{}}: opt_lut_norm_ops(fid, nm, ar, nr, esc, eff, is_m, ops, r, opt_lut_strip_consts(ops))
    case bs: IrFn{fid, nm, ar, nr, esc, eff, is_m, bs}
def opt_lut_fn_fin(fid: U32, nm: String, ar: U32, esc: Bool, eff: Bool, is_m: Bool, orig: List<&2, IrBlock>, res: LutFnRes) -> IrFn:
  LutFnRes{blks1, nr1, chg} = res
  opt_lut_norm_fn(fid, nm, ar, nr1, esc, eff, is_m, Bool.pick(List<&2, IrBlock>, chg, opt_elim_unreach(blks1), orig))
def opt_lut_fn_gc(fid: U32, nm: String, ar: U32, nregs: U32, esc: Bool, eff: Bool, is_m: Bool, +blks: List<&2, IrBlock>, gc: CfGConsts) -> IrFn:
  CfGConsts{+gh, +gv} = gc
  opt_lut_fn_fin(fid, nm, ar, esc, eff, is_m, blks, opt_lut_blks(opt_index_blks(blks, RVEmpty{}), opt_preds_init(blks), gh, gv, blks, LutFnRes{Nil{}, nregs, False{}}))
def opt_lut_fn(f: IrFn) -> IrFn:
  match f:
    case IrFn{+fid, +nm, +ar, +nregs, +esc, +eff, +is_m, +blks}: (+go = Bool.and(U32.is_ge(fid, 3), Bool.and(U32.is_ge(b5k_list_len(IrBlock, blks), 10), U32.is_le(b5k_list_len(IrBlock, blks), 512))); low_if(IrFn, go, _ => opt_lut_fn_gc(fid, nm, ar, nregs, esc, eff, is_m, blks, cf_gc_blks(opt_blks_defs(blks, UM0{}), ar, blks, CfGConsts{UM0{}, UM0{}})), _ => IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}))
# Pass L23 — Continuation-ADT Deforestation (Tail-State-Machine Elimination)
type CadtArm is Data:
  CadtArm{cid: U32, is_def: Bool, bid: U32, byp: U32, dsts: List<&2, U32>}
type CadtArms is Data:
  CadtArms{arms: List<&2, CadtArm>, nb: U32}
type CadtNz is Data:
  CadtNz{fd: U32, tr: U32, rp: U32}
type CadtPar is Data:
  CadtPar{ops: List<&2, IrOp>, nr: U32}
type CadtInfo is Data:
  CadtNo{}
  CadtOk{has_f: Bool, fp: U32, f_dec: U32, z_bid: U32, z_uses_rp: Bool, rp: U32, arms: List<&2, CadtArm>, nb: U32}
type CadtCtor is Data:
  CCNo{}
  CCOk{cid: U32, fs: List<&2, U32>, rest_ops: List<&2, IrOp>}
type CadtRw is Data:
  CadtRw{blks_rev: List<&2, IrBlock>, nr: U32, nb: U32, chg: Bool}
def opt_un_carms(-R: Type, p: CadtArms, k: List<&2, CadtArm> -> U32 -> R) -> R:
  CadtArms{a, b} = p
  k(a, b)
def opt_un_cpar(-R: Type, p: CadtPar, k: List<&2, IrOp> -> U32 -> R) -> R:
  CadtPar{a, b} = p
  k(a, b)
def opt_cadt_take_dsts(+rp: U32, mb: Maybe<&2, IrBlock>) -> List<&2, U32>:
  match mb:
    case Some{IrBlock{_, Con{ITake{ds, s}, _}, _}}: Bool.pick(List<&2, U32>, U32.is_eq(s, rp), ds, Nil{})
    case _: Nil{}
def opt_cadt_add_arm(+rp: U32, +cid: U32, +is_def: Bool, +bid: U32, +bmap: RaVec<Maybe<&2, IrBlock>>, +arms: List<&2, CadtArm>, +nb: U32) -> CadtArms:
  +ds = opt_cadt_take_dsts(rp, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, bid, bmap))
  Bool.pick(CadtArms, U32.is_ne(b5k_u32_list_len(ds), 0), CadtArms{Con{CadtArm{cid, is_def, bid, nb, ds}, arms}, U32.add(nb, 1)}, CadtArms{arms, nb})
def opt_cadt_sw_arms(+rp: U32, +bmap: RaVec<Maybe<&2, IrBlock>>, sw: List<&2, IrSwitchArm>, +db: U32, arms: List<&2, CadtArm>, +nb: U32) -> CadtArms:
  match sw:
    case Nil{}: opt_cadt_add_arm(rp, 0, True{}, db, bmap, arms, nb)
    case Con{IrArm{cid, tgt}, t}: opt_un_carms(CadtArms, opt_cadt_add_arm(rp, cid, False{}, tgt, bmap, arms, nb), a1 => nb1 => opt_cadt_sw_arms(rp, bmap, t, db, a1, nb1))
def opt_cadt_find_cmp(+c0: U32, +tr: U32, ops: List<&2, IrOp>, +cm: U32Map) -> U32:
  match ops:
    case Nil{}: 0
    case Con{IConst{d, v}, t}: opt_cadt_find_cmp(c0, tr, t, um_set(cm, d, U32.add(v, 1)))
    case Con{ICmp{d, +cop, +l, +r}, t}: (+k1 = um_get(cm, r); +ok = Bool.and(U32.is_eq(d, c0), Bool.and(U32.is_le(cop, 1), Bool.and(U32.is_eq(l, tr), U32.is_ne(k1, 0)))); Bool.pick(U32, ok, U32.or(U32.shln(k1, 1n), cop), opt_cadt_find_cmp(c0, tr, t, cm)))
    case Con{_, t}: opt_cadt_find_cmp(c0, tr, t, cm)
def opt_cadt_chain(d: Nat, mb: Maybe<&2, IrBlock>, +rp: U32, +tr: U32, +bmap: RaVec<Maybe<&2, IrBlock>>, +bid: U32, +arms: List<&2, CadtArm>, +nb: U32) -> CadtArms:
  match d mb:
    case 0n _: CadtArms{arms, nb}
    case 1n+p Some{IrBlock{_, +ops, TBr{c0, +tb, +fb}}}:
      +cc = opt_cadt_find_cmp(c0, tr, ops, UM0{})
      +cid = U32.sub(U32.shrn(cc, 1n), 1)
      +is_ne = U32.is_eq(U32.and(cc, 1), 1)
      +hit_b = Bool.pick(U32, is_ne, fb, tb)
      +else_b = Bool.pick(U32, is_ne, tb, fb)
      low_if(CadtArms, U32.is_ne(cc, 0), _ => opt_un_carms(CadtArms, opt_cadt_add_arm(rp, cid, False{}, hit_b, bmap, arms, nb), a1 => nb1 => opt_cadt_chain(p, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, else_b, bmap), rp, tr, bmap, else_b, a1, nb1)), _ => opt_cadt_add_arm(rp, 0, True{}, bid, bmap, arms, nb))
    case _ _: opt_cadt_add_arm(rp, 0, True{}, bid, bmap, arms, nb)
def opt_cadt_scan_nz(+ar: U32, +has_f: Bool, +fp: U32, ops: List<&2, IrOp>, +cm: U32Map, +f_dec: U32, +tr: U32, +rp: U32) -> CadtNz:
  match ops:
    case Nil{}: CadtNz{f_dec, tr, rp}
    case Con{IConst{d, v}, t}: opt_cadt_scan_nz(ar, has_f, fp, t, um_set(cm, d, U32.add(v, 1)), f_dec, tr, rp)
    case Con{IBin{+d, +bop, +a, +b}, t}: (+ok = Bool.and(has_f, Bool.and(Bool.or(U32.is_eq(bop, 1), U32.is_eq(bop, 15)), Bool.and(U32.is_eq(a, fp), U32.is_eq(um_get(cm, b), 2)))); opt_cadt_scan_nz(ar, has_f, fp, t, cm, Bool.pick(U32, ok, U32.add(d, 1), f_dec), tr, rp))
    case Con{ITag{+d, +s}, t}: (+ok = Bool.and(U32.is_lt(s, ar), Bool.or(Bool.not(has_f), U32.is_ne(s, fp))); opt_cadt_scan_nz(ar, has_f, fp, t, cm, f_dec, Bool.pick(U32, ok, U32.add(d, 1), tr), Bool.pick(U32, ok, U32.add(s, 1), rp)))
    case Con{_, t}: opt_cadt_scan_nz(ar, has_f, fp, t, cm, f_dec, tr, rp)
def opt_cadt_rp_safe_op(+rp: U32, op: IrOp) -> Bool:
  match op:
    case ITag{_, _}: True{}
    case ITake{_, _}: True{}
    case o: opt_alll(~U32, ~U32, ~(r => u => U32.is_ne(u, r)), rp, opt_op_uses_list(o))
def opt_cadt_rp_safe(+rp: U32, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: True{}
    case Con{IrBlock{_, ops, term}, t}: Bool.and(opt_alll(~IrOp, ~U32, ~(r => o => opt_cadt_rp_safe_op(r, o)), rp, ops), Bool.and(opt_alll(~U32, ~U32, ~(r => u => U32.is_ne(u, r)), rp, opt_term_uses_list(term)), opt_cadt_rp_safe(rp, t)))
def opt_cadt_z_pure(+rp: U32, mb: Maybe<&2, IrBlock>) -> Bool:
  match mb:
    case Some{IrBlock{_, ops, TRet{rv}}}: Bool.and(U32.is_ne(rv, rp), opt_alll(~IrOp, ~U32, ~(r => o => opt_alll(~U32, ~U32, ~(r2 => u => U32.is_ne(u, r2)), r, opt_op_uses_list(o))), rp, ops))
    case _: False{}
def opt_cadt_disp_term(+rp: U32, +tr: U32, +bid: U32, +bmap: RaVec<Maybe<&2, IrBlock>>, +nb0: U32, term: IrTerm) -> CadtArms:
  match term:
    case TSwitch{s, sw, db}: Bool.pick(CadtArms, U32.is_eq(s, tr), opt_cadt_sw_arms(rp, bmap, sw, db, Nil{}, nb0), CadtArms{Nil{}, nb0})
    case TBr{_, _, _}: opt_cadt_chain(4n, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, bid, bmap), rp, tr, bmap, bid, Nil{}, nb0)
    case _: CadtArms{Nil{}, nb0}
def opt_cadt_disp_go(+has_f: Bool, +fp: U32, +z_bid: U32, +bmap: RaVec<Maybe<&2, IrBlock>>, +blks: List<&2, IrBlock>, +nb0: U32, +bid: U32, term: IrTerm, nz: CadtNz) -> CadtInfo:
  CadtNz{+fd1, +tr1, +rp1} = nz
  +ok_f = Bool.or(Bool.not(has_f), U32.is_ne(fd1, 0))
  +ok_r = Bool.and(ok_f, Bool.and(U32.is_ne(tr1, 0), Bool.and(U32.is_ne(rp1, 0), opt_cadt_rp_safe(U32.sub(rp1, 1), blks))))
  +rp = U32.sub(rp1, 1); +tr = U32.sub(tr1, 1); +fd = U32.sub(fd1, 1)
  low_if(CadtInfo, ok_r, _ => opt_un_carms(CadtInfo, opt_cadt_disp_term(rp, tr, bid, bmap, nb0, term), +arms => nb1 => Bool.pick(CadtInfo, U32.is_ge(b5k_list_len(CadtArm, arms), 2), CadtOk{has_f, fp, fd, z_bid, Bool.not(opt_cadt_z_pure(rp, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, z_bid, bmap))), rp, arms, nb1}, CadtNo{})), _ => CadtNo{})
def opt_cadt_disp(+ar: U32, +has_f: Bool, +fp: U32, +z_bid: U32, +bmap: RaVec<Maybe<&2, IrBlock>>, +blks: List<&2, IrBlock>, +nb0: U32, mb: Maybe<&2, IrBlock>) -> CadtInfo:
  match mb:
    case Some{IrBlock{+bid, +ops, +term}}: opt_cadt_disp_go(has_f, fp, z_bid, bmap, blks, nb0, bid, term, opt_cadt_scan_nz(ar, has_f, fp, ops, UM0{}, 0, 0, 0))
    case _: CadtNo{}
def opt_cadt_analyze(+ar: U32, +bmap: RaVec<Maybe<&2, IrBlock>>, +blks: List<&2, IrBlock>, +nb0: U32) -> CadtInfo:
  match blks:
    case Con{IrBlock{0, +ops0, TBr{+c0, +tb, +fb}}, _}:
      +zp = opt_esc_b0_pn(c0, ar, ops0, UM0{})
      +is_f = Bool.or(U32.is_lt(c0, ar), U32.is_ne(zp, 0))
      +fp = Bool.pick(U32, U32.is_lt(c0, ar), c0, U32.sub(zp, 1))
      +nz_b = Bool.pick(U32, U32.is_lt(c0, ar), tb, fb)
      +z_b = Bool.pick(U32, U32.is_lt(c0, ar), fb, tb)
      low_if(CadtInfo, is_f, _ => opt_cadt_disp(ar, True{}, fp, z_b, bmap, blks, nb0, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, nz_b, bmap)), _ => opt_cadt_disp(ar, False{}, 0, 0, bmap, blks, nb0, Some{IrBlock{0, ops0, TBr{c0, tb, fb}}}))
    case Con{IrBlock{0, ops0, TSwitch{s, sw, db}}, _}: opt_cadt_disp(ar, False{}, 0, 0, bmap, blks, nb0, Some{IrBlock{0, ops0, TSwitch{s, sw, db}}})
    case _: CadtNo{}
def opt_cadt_jmp_tc_mb(+fid: U32, +tgt: U32, mb: Maybe<&2, IrBlock>) -> IrTerm:
  match mb:
    case Some{IrBlock{_, Nil{}, TTailCall{+cfid, args}}}: Bool.pick(IrTerm, U32.is_eq(cfid, fid), TTailCall{cfid, args}, TJmp{tgt})
    case _: TJmp{tgt}
def opt_cadt_jmp_tc(+fid: U32, +bmap: RaVec<Maybe<&2, IrBlock>>, term: IrTerm) -> IrTerm:
  match term:
    case TJmp{+tgt}: opt_cadt_jmp_tc_mb(fid, tgt, ra_vec_get(Maybe<&2, IrBlock>, 5n, None{}, tgt, bmap))
    case t: t
def opt_cadt_thread_blks(+fid: U32, +bmap: RaVec<Maybe<&2, IrBlock>>, blks: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: Nil{}
    case Con{IrBlock{id, ops, term}, t}: Con{IrBlock{id, ops, opt_cadt_jmp_tc(fid, bmap, term)}, opt_cadt_thread_blks(fid, bmap, t)}
def opt_cadt_chase_cp(+v: U32, ops_rev: List<&2, IrOp>) -> U32:
  match ops_rev:
    case Nil{}: v
    case Con{ICopy{+d, +s}, t}: Bool.pick(U32, U32.is_eq(d, v), s, opt_cadt_chase_cp(v, t))
    case Con{_, t}: opt_cadt_chase_cp(v, t)
def opt_cadt_drop_cp(+v0: U32, +v: U32, ops: List<&2, IrOp>) -> List<&2, IrOp>:
  match ops:
    case Nil{}: Nil{}
    case Con{ICopy{+d, +s}, +t}: Bool.pick(List<&2, IrOp>, Bool.and(U32.is_eq(d, v0), U32.is_eq(s, v)), opt_cadt_drop_cp(v0, v, t), Con{ICopy{d, s}, opt_cadt_drop_cp(v0, v, t)})
    case Con{op, t}: Con{op, opt_cadt_drop_cp(v0, v, t)}
def opt_cadt_find_ctor(+v0: U32, +v: U32, ops: List<&2, IrOp>, +acc: List<&2, IrOp>) -> CadtCtor:
  match ops:
    case Nil{}: CCNo{}
    case Con{ICtor{+d, +cid, +fs}, +t}:
      +hit = U32.is_eq(d, v)
      +td = Bool.pick(U32Map, hit, opt_ops_defs(t, UM0{}), UM0{})
      +ok = Bool.and(hit, opt_alll(~U32, ~U32Map, ~(m => f => U32.is_zero(um_get(m, f))), td, fs))
      Bool.pick(CadtCtor, ok, CCOk{cid, fs, b5k_list_rev_go(IrOp, acc, Bool.pick(List<&2, IrOp>, U32.is_eq(v0, v), t, opt_cadt_drop_cp(v0, v, t)))}, opt_cadt_find_ctor(v0, v, t, Con{ICtor{d, cid, fs}, acc}))
    case Con{op, t}: opt_cadt_find_ctor(v0, v, t, Con{op, acc})
def opt_cadt_lookup_arm(+cid: U32, +nf: U32, arms: List<&2, CadtArm>, +def_a: Maybe<&2, CadtArm>) -> Maybe<&2, CadtArm>:
  match arms:
    case Nil{}: def_a
    case Con{CadtArm{+c, +is_d, +bid, +byp, +ds}, t}:
      +ok_d = Bool.and(is_d, U32.is_eq(b5k_u32_list_len(ds), nf))
      +ok_e = Bool.and(Bool.not(is_d), Bool.and(U32.is_eq(c, cid), U32.is_eq(b5k_u32_list_len(ds), nf)))
      Bool.pick(Maybe<&2, CadtArm>, ok_e, Some{CadtArm{c, is_d, bid, byp, ds}}, opt_cadt_lookup_arm(cid, nf, t, Bool.pick(Maybe<&2, CadtArm>, ok_d, Some{CadtArm{c, is_d, bid, byp, ds}}, def_a)))
def opt_cadt_par_p1(+rp: U32, args: List<&2, U32>, +idx: U32, +nr: U32, +acc: List<&2, IrOp>) -> CadtPar:
  match args:
    case Nil{}: CadtPar{acc, nr}
    case Con{+a, +t}: Bool.pick(CadtPar, Bool.or(U32.is_eq(idx, rp), U32.is_eq(a, idx)), opt_cadt_par_p1(rp, t, U32.add(idx, 1), nr, acc), opt_cadt_par_p1(rp, t, U32.add(idx, 1), U32.add(nr, 1), Con{ICopy{nr, a}, acc}))
def opt_cadt_par_p2(+rp: U32, args: List<&2, U32>, +idx: U32, +nr: U32, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match args:
    case Nil{}: acc
    case Con{+a, +t}: Bool.pick(List<&2, IrOp>, Bool.or(U32.is_eq(idx, rp), U32.is_eq(a, idx)), opt_cadt_par_p2(rp, t, U32.add(idx, 1), nr, acc), opt_cadt_par_p2(rp, t, U32.add(idx, 1), U32.add(nr, 1), Con{ICopy{idx, nr}, acc}))
def opt_cadt_fs_p1(fs: List<&2, U32>, +nr: U32, +acc: List<&2, IrOp>) -> CadtPar:
  match fs:
    case Nil{}: CadtPar{acc, nr}
    case Con{f, t}: opt_cadt_fs_p1(t, U32.add(nr, 1), Con{ICopy{nr, f}, acc})
def opt_cadt_fs_p2(ds: List<&2, U32>, +nr: U32, +acc: List<&2, IrOp>) -> List<&2, IrOp>:
  match ds:
    case Nil{}: acc
    case Con{d, t}: opt_cadt_fs_p2(t, U32.add(nr, 1), Con{ICopy{d, nr}, acc})
def opt_cadt_rw_tc(+has_f: Bool, +fp: U32, +f_dec: U32, +z_bid: U32, +z_rp: Bool, +rp: U32, +bid: U32, +rest: List<&2, IrOp>, +args: List<&2, U32>, +cid: U32, +fs: List<&2, U32>, arm: CadtArm, +st: CadtRw) -> CadtRw:
  CadtArm{_, _, _, +byp, +ds} = arm
  CadtRw{+brev, +nr0, +nb0, _} = st
  opt_un_cpar(CadtRw, opt_cadt_par_p1(rp, args, 0, nr0, Nil{}), p1a => +nr1 => opt_un_cpar(CadtRw, opt_cadt_fs_p1(fs, nr1, p1a), p1b => +nr2 => (+cops = b5k_list_rev(IrOp, opt_cadt_fs_p2(ds, nr1, opt_cadt_par_p2(rp, args, 0, nr0, p1b))); +ops_out = b5k_list_app(IrOp, rest, cops); low_if(CadtRw, has_f, _ => (+dec_b = nb0; +z_tgt = Bool.pick(U32, z_rp, U32.add(nb0, 1), z_bid); +nb1 = Bool.pick(U32, z_rp, U32.add(nb0, 2), U32.add(nb0, 1)); +b_dec: IrBlock = IrBlock{dec_b, [IConst{nr2, 1}, IBin{f_dec, 15, fp, nr2}], TJmp{byp}}; +b_cur: IrBlock = IrBlock{bid, ops_out, TBr{fp, dec_b, z_tgt}}; +brev1 = Bool.pick(List<&2, IrBlock>, z_rp, Con{IrBlock{z_tgt, [ICtor{rp, cid, ds}], TJmp{z_bid}}, Con{b_dec, Con{b_cur, brev}}}, Con{b_dec, Con{b_cur, brev}}); CadtRw{brev1, U32.add(nr2, 1), nb1, True{}}), _ => CadtRw{Con{IrBlock{bid, ops_out, TJmp{byp}}, brev}, nr2, nb0, True{}}))))
def opt_cadt_try_ma(+has_f: Bool, +fp: U32, +f_dec: U32, +z_bid: U32, +z_rp: Bool, +rp: U32, +bid: U32, +ops: List<&2, IrOp>, +cfid: U32, +args: List<&2, U32>, +rest: List<&2, IrOp>, +cid: U32, +fs: List<&2, U32>, ma: Maybe<&2, CadtArm>, st: CadtRw) -> CadtRw:
  match ma st:
    case None{} CadtRw{brev, nr, nb, chg}: CadtRw{Con{IrBlock{bid, ops, TTailCall{cfid, args}}, brev}, nr, nb, chg}
    case Some{arm} s: opt_cadt_rw_tc(has_f, fp, f_dec, z_bid, z_rp, rp, bid, rest, args, cid, fs, arm, s)
def opt_cadt_try_cc(+has_f: Bool, +fp: U32, +f_dec: U32, +z_bid: U32, +z_rp: Bool, +rp: U32, +arms: List<&2, CadtArm>, +bid: U32, +ops: List<&2, IrOp>, +cfid: U32, +args: List<&2, U32>, cc: CadtCtor, st: CadtRw) -> CadtRw:
  match cc st:
    case CCNo{} CadtRw{brev, nr, nb, chg}: CadtRw{Con{IrBlock{bid, ops, TTailCall{cfid, args}}, brev}, nr, nb, chg}
    case CCOk{+cid, +fs, +rest} s: opt_cadt_try_ma(has_f, fp, f_dec, z_bid, z_rp, rp, bid, ops, cfid, args, rest, cid, fs, opt_cadt_lookup_arm(cid, b5k_u32_list_len(fs), arms, None{}), s)
def opt_cadt_try_tc(+fid: U32, +ar: U32, +uses: U32Map, +has_f: Bool, +fp: U32, +f_dec: U32, +z_bid: U32, +z_rp: Bool, +rp: U32, +arms: List<&2, CadtArm>, +bid: U32, +ops: List<&2, IrOp>, +cfid: U32, +args: List<&2, U32>, st: CadtRw) -> CadtRw:
  +v_req0 = low_nth(U32, U32.to_nat(rp), 4294967295, args)
  +v_req = opt_cadt_chase_cp(v_req0, b5k_list_rev(IrOp, ops))
  +ok0 = Bool.and(U32.is_eq(cfid, fid), Bool.and(U32.is_eq(b5k_u32_list_len(args), ar), U32.is_eq(um_get(uses, v_req), 1)))
  opt_cadt_try_cc(has_f, fp, f_dec, z_bid, z_rp, rp, arms, bid, ops, cfid, args, Bool.pick(CadtCtor, ok0, opt_cadt_find_ctor(v_req0, v_req, ops, Nil{}), CCNo{}), st)
def opt_cadt_rw_blks(+fid: U32, +ar: U32, +uses: U32Map, +has_f: Bool, +fp: U32, +f_dec: U32, +z_bid: U32, +z_rp: Bool, +rp: U32, +arms: List<&2, CadtArm>, blks: List<&2, IrBlock>, st: CadtRw) -> CadtRw:
  match blks st:
    case Nil{} _: st
    case Con{IrBlock{bid, ops, TTailCall{cfid, args}}, t} s: opt_cadt_rw_blks(fid, ar, uses, has_f, fp, f_dec, z_bid, z_rp, rp, arms, t, opt_cadt_try_tc(fid, ar, uses, has_f, fp, f_dec, z_bid, z_rp, rp, arms, bid, ops, cfid, args, s))
    case Con{b, t} CadtRw{brev, nr, nb, chg}: opt_cadt_rw_blks(fid, ar, uses, has_f, fp, f_dec, z_bid, z_rp, rp, arms, t, CadtRw{Con{b, brev}, nr, nb, chg})
def opt_cadt_byp_of(+bid: U32, arms: List<&2, CadtArm>) -> U32:
  match arms:
    case Nil{}: 0
    case Con{CadtArm{_, _, ab, byp, _}, t}: Bool.pick(U32, U32.is_eq(ab, bid), U32.add(byp, 1), opt_cadt_byp_of(bid, t))
def opt_cadt_split_arms(+arms: List<&2, CadtArm>, blks: List<&2, IrBlock>, +acc: List<&2, IrBlock>) -> List<&2, IrBlock>:
  match blks:
    case Nil{}: b5k_list_rev(IrBlock, acc)
    case Con{IrBlock{+bid, Con{ITake{+ds, +s}, +rest}, +term}, t}:
      +b1 = opt_cadt_byp_of(bid, arms)
      opt_cadt_split_arms(arms, t, Bool.pick(List<&2, IrBlock>, U32.is_ne(b1, 0), Con{IrBlock{U32.sub(b1, 1), rest, term}, Con{IrBlock{bid, [ITake{ds, s}], TJmp{U32.sub(b1, 1)}}, acc}}, Con{IrBlock{bid, Con{ITake{ds, s}, rest}, term}, acc}))
    case Con{b, t}: opt_cadt_split_arms(arms, t, Con{b, acc})
def opt_cadt_has_stc(+fid: U32, blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: False{}
    case Con{IrBlock{_, _, TTailCall{cfid, _}}, t}: Bool.or(U32.is_eq(cfid, fid), opt_cadt_has_stc(fid, t))
    case Con{_, t}: opt_cadt_has_stc(fid, t)
def opt_cadt_fin(+fid: U32, +nm: String, +ar: U32, +nregs: U32, +esc: Bool, +eff: Bool, +is_m: Bool, +blks: List<&2, IrBlock>, +arms: List<&2, CadtArm>, rw: CadtRw) -> IrFn:
  CadtRw{brev, nr1, _, chg} = rw
  low_if(IrFn, chg, _ => opt_pass_cp_dce(True{}, opt_pass_cf(True{}, IrFn{fid, nm, ar, nr1, esc, eff, is_m, opt_map_blks(BMSroaTag{}, opt_cadt_split_arms(arms, b5k_list_rev(IrBlock, brev), Nil{}))})), _ => IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks})
def opt_cadt_fn_k(+fid: U32, +nm: String, +ar: U32, +nregs: U32, +esc: Bool, +eff: Bool, +is_m: Bool, +blks: List<&2, IrBlock>, info: CadtInfo) -> IrFn:
  match info:
    case CadtNo{}: IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks}
    case CadtOk{hf, fp, fd, zb, zrp, rp, +arms, nb0}:
      +tblks = opt_cadt_thread_blks(fid, opt_index_blks(blks, RVEmpty{}), blks)
      opt_cadt_fin(fid, nm, ar, nregs, esc, eff, is_m, blks, arms, opt_cadt_rw_blks(fid, ar, opt_blks_uses(tblks, UM0{}), hf, fp, fd, zb, zrp, rp, arms, tblks, CadtRw{Nil{}, nregs, nb0, False{}}))
def opt_cadt_fn(f: IrFn) -> IrFn:
  IrFn{+fid, +nm, +ar, +nregs, +esc, +eff, +is_m, +blks} = f
  +go = Bool.and(U32.is_ge(fid, 3), Bool.and(Bool.not(eff), Bool.and(Bool.not(is_m), Bool.and(U32.is_le(ar, 16), Bool.and(U32.is_le(b5k_list_len(IrBlock, blks), 128), opt_cadt_has_stc(fid, blks))))))
  low_if(IrFn, go, _ => opt_cadt_fn_k(fid, nm, ar, nregs, esc, eff, is_m, blks, opt_cadt_analyze(ar, opt_index_blks(blks, RVEmpty{}), blks, U32.add(opt_blks_max_id(blks, 0), 1))), _ => IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks})
# Top-Level -O2 Pipeline
def opt_fn_sroa(f: IrFn) -> IrFn:
  IrFn{fid, nm, +ar, nregs, esc, eff, is_m, +blks} = f
  IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_map_blks(BMSroaFuse{opt_blks_defs(blks, UM0{}), opt_blks_uses(blks, UM0{}), ar}, blks)}
def opt_fn_local(small: Bool, +ret_sc: U32Map, +psc: U32Map, f: IrFn) -> IrFn:
  match small f:
    case True{} IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, +blks}: opt_un_fn(IrFn, opt_pass_cp_dce(True{}, opt_pass_cf(True{}, IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_map_blks(BMSroaTag{}, opt_map_blks(BMScRw{True{}, opt_sc_compute(True{}, ret_sc, psc, fid, ar, blks)}, blks))})), fi2 => nm2 => ar2 => nr2 => es2 => ef2 => im2 => b2 => opt_pass_cp_dce(False{}, opt_fn_sroa(IrFn{fi2, nm2, ar2, nr2, es2, ef2, im2, opt_map_blks(BMSroaTag{}, b2)})))
    case False{} IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, +blks}: opt_pass_cf(False{}, IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_map_blks(BMScRw{False{}, opt_sc_compute(False{}, ret_sc, psc, fid, ar, blks)}, blks)})
def opt_map_fn_step(k: FnMap, f: IrFn) -> IrFn:
  match k:
    case FMLocal{sm, ret_sc, psc}: opt_fn_local(sm, ret_sc, psc, f)
    case FMMid{}:
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, blks} = f
      opt_pass_cp_dce(True{}, opt_fn_sroa(opt_pass_cf(True{}, IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_map_blks(BMSroaTag{}, blks)})))
    case FMInl{lt, so, bud, bank}: opt_inl_fn(lt, so, bud, bank, f)
    case FMWwCallee{pi, pa, pc}: opt_ww_rw_callee_fn(pi, pa, pc, f)
    case FMWwCaller{pi, pa, pc}:
      IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, +blks} = f
      cf_fn_fin(fid, nm, ar, esc, eff, is_m, opt_ww_rw_caller_blks(fid, opt_blks_defs(blks, UM0{}), opt_blks_uses(blks, UM0{}), ar, pi, pa, pc, blks, CfBlksRes{Nil{}, nregs}))
    case FMSelMask{}: opt_sel_fn(f)
    case FMFuseSink{}: opt_fn_fuse_sink(f)
    case FMIdArm{}: opt_id_fn(f)
    case FMTcoLarge{}: opt_tco_fn(f)
    case FMReuse{}: opt_ru_fn(f)
    case FMJtRu{}: opt_fn_jt_ru(f)
    case FMEarlyExit{}: opt_esc_fn(f)
    case FMTrmc{}: opt_trmc_fn(f)
    case FMHoBeta{cf, cn}:
      IrFn{+fid, nm, +ar, nregs, esc, eff, is_m, +blks} = f
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, low_if(List<&2, IrBlock>, U32.is_ge(fid, 3), _ => opt_map_blks(BMHoBeta{cf, cn, opt_blks_defs(blks, UM0{}), opt_blks_uses(blks, UM0{}), ar}, blks), _ => blks)}
    case FMMsroa{}: opt_msroa_fn(f)
    case FMCadt{}: opt_cadt_fn(f)
    case FMArrRmw{}:
      IrFn{fid, nm, ar, +nregs, esc, eff, is_m, +blks} = f
      IrFn{fid, nm, ar, nregs, esc, eff, is_m, opt_map_blks(BMRmw{Bool.and(U32.is_le(nregs, 128), opt_all_blks_ops(OPNoArr{}, blks)), opt_fold_blks_ops(OFConsts{}, blks, UM0{}), opt_blks_uses(blks, UM0{})}, blks)}
    case FMStackArr{r, p}: opt_sa_fn(r, p, f)
    case FMLut{}: opt_lut_fn(f)
def opt_map_fns(+k: FnMap, fns: List<&2, IrFn>) -> List<&2, IrFn>: opt_mapl(~IrFn, ~FnMap, ~IrFn, ~(e => f => opt_map_fn_step(e, f)), k, fns)
def opt_un_wwp(-R: Type, pl: WwPlan, k: U32Map -> U32Map -> U32Map -> Bool -> R) -> R:
  WwPlan{pi, pa, pc, any} = pl
  k(pi, pa, pc, any)
def opt_ww_loop(fuel: Nat, +fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match fuel:
    case 0n: fns
    case 1n+p:
      +bad_fn = opt_ip_bad_fns(fns, UM0{})
      +cand = opt_ww_cand_fns(bad_fn, fns, UM0{})
      opt_un_wwp(List<&2, IrFn>, opt_ww_build_plan(bad_fn, cand, opt_ww_obs_fns(opt_fn_reach(fns), cand, opt_ww_ret_fns(fns, UM0{}), fns, UM0{}), fns, WwPlan{UM0{}, UM0{}, UM0{}, False{}}), pi => pa => pc => any => (+pi1 = pi; +pa1 = pa; +pc1 = pc; low_if(List<&2, IrFn>, any, _ => opt_ww_loop(p, opt_map_fns(FMMid{}, opt_map_fns(FMWwCaller{pi1, pa1, pc1}, opt_map_fns(FMWwCallee{pi1, pa1, pc1}, fns)))), _ => fns)))
def opt_ho_beta_fns(ct: CloTab, fns: List<&2, IrFn>) -> List<&2, IrFn>:
  CloTab{cf, cn} = ct
  opt_map_fns(FMHoBeta{cf, cn}, fns)
def opt_sa_ip(ip: IpRes, fns: List<&2, IrFn>) -> List<&2, IrFn>:
  IpRes{r, p, _} = ip
  opt_map_fns(FMMid{}, opt_map_fns(FMStackArr{r, p}, fns))
def b5k_opt_fin(+small: Bool, fns3: List<&2, IrFn>, ip1: IpRes) -> List<&2, IrFn>:
  IpRes{ret1, psc1, _} = ip1
  opt_map_fns(FMLocal{small, ret1, psc1}, fns3)
def opt_inl_r(sc: Bool, leaf: Bool, mo: U32, mb: U32, bud: U32, +fns: List<&2, IrFn>) -> List<&2, IrFn>: opt_map_fns(FMMid{}, opt_map_fns(FMInl{False{}, False{}, bud, opt_collect_inlines(sc, leaf, mo, mb, fns, InlBank{UM0{}, RVEmpty{}})}, fns))
def opt_inl_beta(ctab: CloTab, sc: Bool, leaf: Bool, mo: U32, mb: U32, bud: U32, +fns: List<&2, IrFn>) -> List<&2, IrFn>: opt_map_fns(FMMid{}, opt_ho_beta_fns(ctab, opt_map_fns(FMInl{False{}, False{}, bud, opt_collect_inlines(sc, leaf, mo, mb, fns, InlBank{UM0{}, RVEmpty{}})}, fns)))
def b5k_opt_go(small: Bool, +fns: List<&2, IrFn>) -> List<&2, IrFn>:
  match small:
    case True{}: (+ctab = opt_ho_table(fns); +ret0 = opt_collect_ret_only(fns, UM0{}); +fns0 = opt_map_fns(FMLut{}, b5k_opt_fin(True{}, fns, opt_collect_ip(True{}, fns, ret0))); +fns2 = opt_inl_r(False{}, True{}, 224, 40, 64, opt_inl_r(False{}, True{}, 160, 24, 64, opt_inl_r(False{}, True{}, 128, 20, 64, opt_inl_beta(ctab, False{}, True{}, 64, 16, 64, fns0)))); +fns3d = opt_inl_r(True{}, False{}, 512, 64, 48, opt_inl_r(True{}, False{}, 512, 64, 48, opt_inl_r(True{}, False{}, 512, 64, 48, opt_inl_beta(ctab, False{}, False{}, 160, 28, 48, fns2)))); +fns3e = opt_map_fns(FMLut{}, opt_map_fns(FMMid{}, opt_ho_beta_fns(ctab, opt_inl_r(False{}, False{}, 32, 4, 16, opt_inl_r(False{}, True{}, 224, 40, 64, opt_inl_beta(ctab, True{}, False{}, 512, 64, 48, fns3d)))))); +fns4a = opt_map_fns(FMCadt{}, opt_map_fns(FMMid{}, opt_map_fns(FMMsroa{}, opt_ww_loop(6n, fns3e)))); +fns4b = opt_map_fns(FMMid{}, opt_map_fns(FMInl{False{}, False{}, 4, opt_collect_self_tc(False{}, fns4a, InlBank{UM0{}, RVEmpty{}})}, fns4a)); +fns4c = opt_map_fns(FMMid{}, opt_map_fns(FMInl{True{}, False{}, 4, opt_collect_self_tc(False{}, fns4b, InlBank{UM0{}, RVEmpty{}})}, fns4b)); +fns4 = opt_map_fns(FMMid{}, opt_map_fns(FMMsroa{}, opt_map_fns(FMMid{}, opt_map_fns(FMInl{True{}, True{}, 4, opt_collect_self_tc(True{}, fns4c, InlBank{UM0{}, RVEmpty{}})}, fns4c)))); +fns5 = opt_map_fns(FMIdArm{}, opt_map_fns(FMSelMask{}, b5k_opt_fin(True{}, fns4, opt_collect_ip(True{}, fns4, ret0)))); +ip6 = opt_collect_ip(True{}, fns5, ret0); +fns6 = opt_map_fns(FMMid{}, opt_map_fns(FMSelMask{}, b5k_opt_fin(True{}, fns5, ip6))); +fns7 = opt_sa_ip(ip6, fns6); opt_map_fns(FMArrRmw{}, opt_map_fns(FMTcoLarge{}, opt_map_fns(FMReuse{}, opt_map_fns(FMJtRu{}, opt_map_fns(FMTrmc{}, opt_map_fns(FMEarlyExit{}, opt_map_fns(FMFuseSink{}, fns7))))))))
    case False{}: opt_map_fns(FMTcoLarge{}, opt_map_fns(FMLocal{False{}, UM0{}, UM0{}}, fns))
def b5k_opt(prog: IrProg) -> IrProg:
  match prog:
    case IrProg{+fns, ctors, statics, main_fid, main_pure, effects, show_desc, show_names}: IrProg{b5k_opt_go(U32.is_le(b5k_list_len(IrFn, fns), 384), fns), ctors, statics, main_fid, main_pure, effects, show_desc, show_names}
