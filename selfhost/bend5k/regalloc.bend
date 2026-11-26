# bend5k/regalloc.bend — Linear-Scan Register Allocator & Typed X64 Peephole
# ==========================================================================
# Exports:
#   - RegAllocRes, b5k_regalloc(fn: IrFn) -> RegAllocRes
#   - b5k_peep(fns: List<&2, X64Fn>) -> List<&2, X64Fn>

# Part 1: Linear-Scan Register Allocator (GPR + XMM + Move Coalescing)
type RegAllocRes is Data:
  RegAllocRes{reg_map: RaVec<U32>, vd: Nat, used_callee: List<&2, U32>, spill_count: U32}
type RaIv is Data:
  RaIv{vid: U32, start: U32, end: U32, uses: U32, luses: U32, seen: Bool}
type RaEdge is Data:
  RaEdge{lstart: U32, bend: U32, is_tail: Bool}
type RaScan is Data:
  RaScan{ivs: RaVec<RaIv>, bs: RaVec<U32>, cb: RaVec<U32>, nc: U32, rb: RaVec<U32>, nr: U32, edges: List<&2, RaEdge>, f32s: RaVec<Bool>, nf32s: RaVec<Bool>, hints: RaVec<U32>, cvals: RaVec<U32>, idx: U32}

def ra_touch_upd_w(cur: RaIv, +v: U32, +idx: U32, +dw: U32, +ldw: U32) -> RaIv:
  match cur:
    case RaIv{_, _, _, _, _, False{}}: RaIv{v, idx, idx, 1, ldw, True{}}
    case RaIv{_, s, e, u, lu, True{}}: RaIv{v, U32.min(s, idx), U32.max(e, idx), U32.add(u, dw), U32.add(lu, ldw), True{}}
def ra_touch_w(+vd: Nat, +ib: U32, +ivs: RaVec<RaIv>, +v: U32, +idx: U32, +dw: U32) -> RaVec<RaIv>:
  cur = ra_vec_get(RaIv, vd, RaIv{v, idx, idx, 0, 0, False{}}, v, ivs)
  ra_vec_set(RaIv, vd, v, ra_touch_upd_w(cur, v, idx, dw, Bool.pick(U32, U32.is_zero(ib), 0, dw)), ivs)
def ra_touch(vd: Nat, ib: U32, ivs: RaVec<RaIv>, v: U32, idx: U32) -> RaVec<RaIv>: ra_touch_w(vd, ib, ivs, v, idx, 1)
def ra_touch_rhs_fin(skip: Bool, vd: Nat, ib: U32, ivs: RaVec<RaIv>, r: U32, idx: U32) -> RaVec<RaIv>:
  match skip:
    case True{}: ivs
    case False{}: ra_touch_w(vd, ib, ivs, r, idx, 2)
def ra_touch_rhs(+vd: Nat, ib: U32, ivs: RaVec<RaIv>, +r: U32, idx: U32, +bop: U32, cvals: RaVec<U32>) -> RaVec<RaIv>:
  +cv = ra_vec_get(U32, vd, 0, r, cvals)
  is_alu = Bool.or(U32.is_le(bop, 1), Bool.and(U32.is_ge(bop, 5), U32.is_le(bop, 7)))
  is_sh = Bool.or(U32.is_eq(bop, 8), U32.is_eq(bop, 9))
  fold = Bool.or(Bool.and(is_alu, U32.is_ne(cv, 0)), Bool.and(is_sh, U32.is_eq(cv, 1)))
  ra_touch_rhs_fin(fold, vd, ib, ivs, r, idx)
def ra_vec_set_if(-A: Data, d: Nat, cond: Bool, idx: U32, val: A, t: RaVec<A>) -> RaVec<A>:
  match cond:
    case False{}: t
    case True{}: ra_vec_set(A, d, idx, val, t)
def ra_rec_cb(cd: Nat, nz: Bool, idx: U32, nc: U32, cb: RaVec<U32>) -> RaVec<U32>: ra_vec_set_if(U32, cd, nz, idx, nc, cb)
def ra_set_cval(vd: Nat, d: U32, +val: U32, cvals: RaVec<U32>) -> RaVec<U32>:
  +cv = Bool.pick(U32, U32.is_lt(val, 64), 1, Bool.pick(U32, U32.is_lt(val, 2147483647), 2, 0))
  ra_rec_cb(vd, U32.is_ne(cv, 0), d, cv, cvals)
def ra_touch_list_w(+vd: Nat, +ib: U32, vs: List<&2, U32>, ivs: RaVec<RaIv>, +idx: U32, +dw: U32) -> RaVec<RaIv>:
  match vs:
    case Nil{}: ivs
    case Con{v, t}: ra_touch_list_w(vd, ib, t, ra_touch_w(vd, ib, ivs, v, idx, dw), idx, dw)
def ra_touch_list(vd: Nat, ib: U32, vs: List<&2, U32>, ivs: RaVec<RaIv>, idx: U32) -> RaVec<RaIv>: ra_touch_list_w(vd, ib, vs, ivs, idx, 1)
def ra_touch_tail(+vd: Nat, +same: Bool, +hs: RaVec<U32>, args: List<&2, U32>, +i: U32, ivs: RaVec<RaIv>, +idx: U32) -> RaVec<RaIv>:
  match args:
    case Nil{}: ivs
    case Con{+a, t}:
      inv = Bool.and(same, Bool.or(U32.is_eq(a, i), U32.is_eq(ra_vec_get(U32, vd, 0, a, hs), U32.add(i, 1))))
      ra_touch_tail(vd, same, hs, t, U32.add(i, 1), ra_touch_w(vd, 1, ivs, a, idx, Bool.pick(U32, inv, 0, 1)), idx)
def ra_is_arr_op(+aop: U32) -> Bool: Bool.or(Bool.and(U32.is_ge(aop, 72), U32.is_le(aop, 75)), Bool.and(U32.is_ge(aop, 78), U32.is_le(aop, 79)))
def ra_touch_arr_args(+vd: Nat, +ib: U32, is_arr: Bool, args: List<&2, U32>, ivs: RaVec<RaIv>, +idx: U32) -> RaVec<RaIv>:
  match is_arr args:
    case True{} Con{a, t}: ra_touch_list_w(vd, ib, t, ra_touch_w(vd, ib, ivs, a, idx, 0), idx, 2)
    case _ xs: ra_touch_list(vd, ib, xs, ivs, idx)
def ra_touch_arr_ds(+vd: Nat, +ib: U32, is_arr: Bool, +aop: U32, ds: List<&2, U32>, ivs: RaVec<RaIv>, +idx: U32) -> RaVec<RaIv>:
  match is_arr ds:
    case True{} Con{da, t}: ra_touch_list(vd, ib, t, ra_touch_w(vd, ib, ivs, da, idx, Bool.pick(U32, U32.is_eq(aop, 78), 1, 0)), idx)
    case _ xs: ra_touch_list(vd, ib, xs, ivs, idx)
def ra_init_params(+vd: Nat, n: Nat, +v: U32, ivs: RaVec<RaIv>) -> RaVec<RaIv>:
  match n:
    case 0n: ivs
    case 1n+p: ra_init_params(vd, p, U32.add(v, 1), ra_touch(vd, 0, ivs, v, 0))
def ra_mark_b(vd: Nat, cond: Bool, v: U32, m: RaVec<Bool>) -> RaVec<Bool>: ra_vec_set_if(Bool, vd, cond, v, True{}, m)
def ra_mark_b2(+vd: Nat, cond: Bool, a: U32, b: U32, m: RaVec<Bool>) -> RaVec<Bool>:
  match cond:
    case True{}: ra_vec_set(Bool, vd, b, True{}, ra_vec_set(Bool, vd, a, True{}, m))
    case False{}: m
def ra_set_hint(vd: Nat, +d: U32, +s: U32, hs: RaVec<U32>) -> RaVec<U32>: ra_rec_cb(vd, U32.is_ne(d, s), d, U32.add(s, 1), hs)
def ra_arr_hint(vd: Nat, is_arr: Bool, aop: U32, ds: List<&2, U32>, args: List<&2, U32>, +hs: RaVec<U32>) -> RaVec<U32>:
  match is_arr ds args:
    case True{} Con{da, _} Con{a, _}: Bool.pick(RaVec<U32>, U32.is_eq(aop, 78), hs, ra_set_hint(vd, da, a, hs))
    case _ _ _: hs
def ra_set_hint_soft(+vd: Nat, +d: U32, +s: U32, +hs: RaVec<U32>) -> RaVec<U32>:
  ok = Bool.and(U32.is_ne(d, s), U32.is_zero(ra_vec_get(U32, vd, 0, d, hs)))
  ra_rec_cb(vd, ok, d, U32.add(s, 1), hs)
def ra_tail_hints(+vd: Nat, args: List<&2, U32>, +i: U32, hs: RaVec<U32>) -> RaVec<U32>:
  match args:
    case Nil{}: hs
    case Con{a, t}: ra_tail_hints(vd, t, U32.add(i, 1), ra_set_hint_soft(vd, a, i, hs))
def ra_tail_hints_if(same_fn: Bool, vd: Nat, args: List<&2, U32>, hs: RaVec<U32>) -> RaVec<U32>:
  match same_fn:
    case True{}: ra_tail_hints(vd, args, 0, hs)
    case False{}: hs
def ra_rec(+cd: Nat, +kind: U32, ivs: RaVec<RaIv>, bs: RaVec<U32>, cb: RaVec<U32>, +nc: U32, rb: RaVec<U32>, +nr: U32, es: List<&2, RaEdge>, f32s: RaVec<Bool>, nf32s: RaVec<Bool>, hs: RaVec<U32>, cvals: RaVec<U32>, +idx: U32) -> RaScan:
  nc1 = Bool.pick(U32, U32.is_eq(kind, 2), U32.add(nc, 1), nc)
  nr1 = Bool.pick(U32, U32.is_ne(kind, 0), U32.add(nr, 1), nr)
  RaScan{ivs, bs, ra_rec_cb(cd, U32.is_ne(nc, 0), idx, nc, cb), nc1, ra_rec_cb(cd, U32.is_ne(nr, 0), idx, nr, rb), nr1, es, f32s, nf32s, hs, cvals, U32.add(idx, 1)}

def ra_is_nonempty(xs: List<&2, U32>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{_, _}: True{}

def ra_scan_op(+vd: Nat, cd: Nat, +track_f: Bool, +ib: U32, st: RaScan, op: IrOp) -> RaScan:
  RaScan{ivs, bs, cb, nc, rb, nr, es, +f32s, +nf32s, hs, +cvals, +idx} = st
  match op:
    case IConst{+d, val}: ra_rec(cd, 0, ra_touch(vd, ib, ivs, d, idx), bs, cb, nc, rb, nr, es, f32s, ra_mark_b(vd, track_f, d, nf32s), hs, ra_set_cval(vd, d, val, cvals), idx)
    case IFlt{+d, _}: ra_rec(cd, 0, ra_touch(vd, ib, ivs, d, idx), bs, cb, nc, rb, nr, es, ra_mark_b(vd, track_f, d, f32s), nf32s, hs, cvals, idx)
    case ICopy{+d, +s}:
      f1 = ra_mark_b(vd, Bool.and(track_f, ra_vec_get(Bool, vd, False{}, s, f32s)), d, f32s)
      nf1 = ra_mark_b(vd, Bool.and(track_f, ra_vec_get(Bool, vd, False{}, s, nf32s)), d, nf32s)
      ra_rec(cd, 0, ra_touch(vd, ib, ra_touch(vd, ib, ivs, s, idx), d, idx), bs, cb, nc, rb, nr, es, f1, nf1, ra_set_hint(vd, d, s, hs), cvals, idx)
    case IBin{+d, +bop, +l, +r}:
      +isf = Bool.and(U32.is_ge(bop, 10), U32.is_le(bop, 13))
      +cf = Bool.and(track_f, isf)
      +cnf = Bool.and(track_f, Bool.not(isf))
      f1 = ra_mark_b(vd, cf, d, ra_mark_b2(vd, cf, l, r, f32s))
      nf1 = ra_mark_b(vd, cnf, d, ra_mark_b2(vd, cnf, l, r, nf32s))
      ivs1 = ra_touch(vd, ib, ra_touch_rhs(vd, ib, ra_touch_w(vd, ib, ivs, l, idx, 2), r, idx, bop, cvals), d, idx)
      ra_rec(cd, 0, ivs1, bs, cb, nc, rb, nr, es, f1, nf1, ra_set_hint(vd, d, l, hs), cvals, idx)
    case IUn{+d, +uop, +s}:
      df = Bool.and(track_f, Bool.and(U32.is_ge(uop, 2), U32.is_le(uop, 4)))
      sf = Bool.and(track_f, Bool.or(U32.is_eq(uop, 2), Bool.or(U32.is_eq(uop, 3), U32.is_eq(uop, 5))))
      dnf = Bool.and(track_f, Bool.or(U32.is_lt(uop, 2), U32.is_eq(uop, 5)))
      snf = Bool.and(track_f, Bool.or(U32.is_lt(uop, 2), U32.is_eq(uop, 4)))
      f1 = ra_mark_b(vd, sf, s, ra_mark_b(vd, df, d, f32s))
      nf1 = ra_mark_b(vd, snf, s, ra_mark_b(vd, dnf, d, nf32s))
      ra_rec(cd, 0, ra_touch(vd, ib, ra_touch_w(vd, ib, ivs, s, idx, 2), d, idx), bs, cb, nc, rb, nr, es, f1, nf1, ra_set_hint(vd, d, s, hs), cvals, idx)
    case ICmp{+d, +cop, +l, +r}:
      +isf = U32.is_ge(cop, 6)
      f1 = ra_mark_b2(vd, Bool.and(track_f, isf), l, r, f32s)
      nf1 = ra_mark_b2(vd, Bool.and(track_f, Bool.not(isf)), l, r, ra_mark_b(vd, track_f, d, nf32s))
      ivs1 = ra_touch(vd, ib, ra_touch_rhs(vd, ib, ra_touch_w(vd, ib, ivs, l, idx, 2), r, idx, Bool.pick(U32, isf, 99, 0), cvals), d, idx)
      ra_rec(cd, 0, ivs1, bs, cb, nc, rb, nr, es, f1, nf1, hs, cvals, idx)
    case ICallDirect{d, _, args}: ra_rec(cd, 2, ra_touch(vd, ib, ra_touch_list(vd, ib, args, ivs, idx), d, idx), bs, cb, nc, rb, nr, es, f32s, nf32s, hs, cvals, idx)
    case ICallClosure{+d, _, caps}: ra_rec(cd, 2, ra_touch(vd, ib, ra_touch_list(vd, ib, caps, ivs, idx), d, idx), bs, cb, nc, rb, nr, es, f32s, ra_mark_b(vd, track_f, d, nf32s), hs, cvals, idx)
    case IApply{+d, +clo, arg}: ra_rec(cd, 2, ra_touch(vd, ib, ra_touch(vd, ib, ra_touch(vd, ib, ivs, clo, idx), arg, idx), d, idx), bs, cb, nc, rb, nr, es, f32s, ra_mark_b2(vd, track_f, d, clo, nf32s), hs, cvals, idx)
    case ICtor{+d, _, +fs}: ra_rec(cd, Bool.to_u32(ra_is_nonempty(fs)), ra_touch(vd, ib, ra_touch_list(vd, ib, fs, ivs, idx), d, idx), bs, cb, nc, rb, nr, es, f32s, ra_mark_b(vd, track_f, d, nf32s), hs, cvals, idx)
    case ITake{+ds, +s}: ra_rec(cd, Bool.to_u32(ra_is_nonempty(ds)), ra_touch_list(vd, ib, ds, ra_touch(vd, ib, ivs, s, idx), idx), bs, cb, nc, rb, nr, es, f32s, ra_mark_b(vd, track_f, s, nf32s), hs, cvals, idx)
    case ITag{+d, +s}: ra_rec(cd, 0, ra_touch(vd, ib, ra_touch(vd, ib, ivs, s, idx), d, idx), bs, cb, nc, rb, nr, es, f32s, ra_mark_b2(vd, track_f, d, s, nf32s), ra_set_hint(vd, d, s, hs), cvals, idx)
    case IKeep{d, s}: ra_rec(cd, 1, ra_touch(vd, ib, ra_touch(vd, ib, ivs, s, idx), d, idx), bs, cb, nc, rb, nr, es, f32s, nf32s, hs, cvals, idx)
    case ISink{s}: ra_rec(cd, 1, ra_touch(vd, ib, ivs, s, idx), bs, cb, nc, rb, nr, es, f32s, nf32s, hs, cvals, idx)
    case IReuse{+d, +sl, _, +fs}: ra_rec(cd, Bool.to_u32(ra_is_nonempty(fs)), ra_touch(vd, ib, ra_touch(vd, ib, ra_touch_list(vd, ib, fs, ivs, idx), sl, idx), d, idx), bs, cb, nc, rb, nr, es, f32s, ra_mark_b2(vd, track_f, d, sl, nf32s), hs, cvals, idx)
    case IStatic{+d, _}: ra_rec(cd, 0, ra_touch(vd, ib, ivs, d, idx), bs, cb, nc, rb, nr, es, f32s, ra_mark_b(vd, track_f, d, nf32s), hs, cvals, idx)
    case IArrOp{+ds, +aop, +args}:
      +is_a = ra_is_arr_op(aop)
      ivs1 = ra_touch_arr_ds(vd, ib, is_a, aop, ds, ra_touch_arr_args(vd, ib, is_a, args, ivs, idx), idx)
      ra_rec(cd, 1, ivs1, bs, cb, nc, rb, nr, es, f32s, nf32s, ra_arr_hint(vd, is_a, aop, ds, args, hs), cvals, idx)
    case IAlloca{+d, _}: ra_rec(cd, 0, ra_touch(vd, ib, ivs, d, idx), bs, cb, nc, rb, nr, es, f32s, ra_mark_b(vd, track_f, d, nf32s), hs, cvals, idx)
    case ILoad{+d, +b, _}: ra_rec(cd, 0, ra_touch(vd, ib, ra_touch(vd, ib, ivs, b, idx), d, idx), bs, cb, nc, rb, nr, es, f32s, ra_mark_b2(vd, track_f, d, b, nf32s), hs, cvals, idx)
    case IStore{+b, _, v}: ra_rec(cd, 0, ra_touch(vd, ib, ra_touch(vd, ib, ivs, b, idx), v, idx), bs, cb, nc, rb, nr, es, f32s, ra_mark_b(vd, track_f, b, nf32s), hs, cvals, idx)
    case IMutField{+o, _, v}: ra_rec(cd, 1, ra_touch(vd, ib, ra_touch(vd, ib, ivs, o, idx), v, idx), bs, cb, nc, rb, nr, es, f32s, ra_mark_b(vd, track_f, o, nf32s), hs, cvals, idx)
    case IFail{_}: ra_rec(cd, 2, ivs, bs, cb, nc, rb, nr, es, f32s, nf32s, hs, cvals, idx)
def ra_scan_ops(+vd: Nat, +cd: Nat, +track_f: Bool, +ib: U32, ops: List<&2, IrOp>, st: RaScan) -> RaScan:
  match ops:
    case Nil{}: st
    case Con{op, t}: ra_scan_ops(vd, cd, track_f, ib, t, ra_scan_op(vd, cd, track_f, ib, st, op))
def ra_check_edge(bs: RaVec<U32>, tgt: U32, idx: U32, is_tail: Bool, +es: List<&2, RaEdge>) -> List<&2, RaEdge>:
  +s1 = ra_vec_get(U32, 8n, 0, tgt, bs)
  Bool.pick(List<&2, RaEdge>, U32.is_zero(s1), es, Con{RaEdge{U32.sub(s1, 1), idx, is_tail}, es})
def ra_check_arms(+bs: RaVec<U32>, arms: List<&2, IrSwitchArm>, +idx: U32, es: List<&2, RaEdge>) -> List<&2, RaEdge>:
  match arms:
    case Nil{}: es
    case Con{IrArm{_, tgt}, t}: ra_check_arms(bs, t, idx, ra_check_edge(bs, tgt, idx, False{}, es))
def ra_tail_edge(same_fn: Bool, bs: RaVec<U32>, idx: U32, es: List<&2, RaEdge>) -> List<&2, RaEdge>:
  match same_fn:
    case True{}: ra_check_edge(bs, 0, idx, True{}, es)
    case False{}: es

def ra_is_exit_term(term: IrTerm) -> Bool:
  match term:
    case TRet{_}: True{}
    case TFail{_}: True{}
    case _: False{}
def ra_scan_term(+vd: Nat, cd: Nat, track_f: Bool, fn_fid: U32, st: RaScan, term: IrTerm) -> RaScan:
  RaScan{ivs, +bs, cb, nc, rb, nr, es, f32s, nf32s, +hs, cvals, +idx} = st
  match term:
    case TJmp{tgt}: ra_rec(cd, 0, ivs, bs, cb, nc, rb, nr, ra_check_edge(bs, tgt, idx, False{}, es), f32s, nf32s, hs, cvals, idx)
    case TBr{+c, tb, eb}:
      es1 = ra_check_edge(bs, eb, idx, False{}, ra_check_edge(bs, tb, idx, False{}, es))
      ra_rec(cd, 0, ra_touch_w(vd, 1, ivs, c, idx, 2), bs, cb, nc, rb, nr, es1, f32s, ra_mark_b(vd, track_f, c, nf32s), hs, cvals, idx)
    case TSwitch{+sc, arms, db}:
      es1 = ra_check_edge(bs, db, idx, False{}, ra_check_arms(bs, arms, idx, es))
      ra_rec(cd, 0, ra_touch_w(vd, 1, ivs, sc, idx, 2), bs, cb, nc, rb, nr, es1, f32s, ra_mark_b(vd, track_f, sc, nf32s), hs, cvals, idx)
    case TRet{v}: ra_rec(cd, 0, ra_touch(vd, 0, ivs, v, idx), bs, cb, nc, rb, nr, es, f32s, nf32s, hs, cvals, idx)
    case TTailCall{fid, +args}:
      +same = U32.is_eq(fid, fn_fid)
      es1 = ra_tail_edge(same, bs, idx, es)
      hs1 = ra_tail_hints_if(same, vd, args, hs)
      k = Bool.pick(U32, U32.is_gt(b5k_list_len(U32, args), 32), 2, 0)
      ra_rec(cd, k, ra_touch_tail(vd, same, hs, args, 0, ivs, idx), bs, cb, nc, rb, nr, es1, f32s, nf32s, hs1, cvals, idx)
    case TFail{_}: ra_rec(cd, 2, ivs, bs, cb, nc, rb, nr, es, f32s, nf32s, hs, cvals, idx)
def ra_scan_blks(+vd: Nat, +cd: Nat, +track_f: Bool, +fn_fid: U32, blks: List<&2, IrBlock>, st: RaScan) -> RaScan:
  match blks st:
    case Nil{} _: st
    case Con{IrBlock{bid, ops, +term}, t} RaScan{ivs, bs, cb, nc, rb, nr, es, f32s, nf32s, hs, cvals, +idx}:
      bs1 = ra_vec_set(U32, 8n, bid, U32.add(idx, 1), bs)
      ib = Bool.pick(U32, ra_is_exit_term(term), 0, 1)
      st1 = ra_scan_term(vd, cd, track_f, fn_fid, ra_scan_ops(vd, cd, track_f, ib, ops, RaScan{ivs, bs1, cb, nc, rb, nr, es, f32s, nf32s, hs, cvals, idx}), term)
      ra_scan_blks(vd, cd, track_f, fn_fid, t, st1)

# Loop Back-Edge Extension & 8x Loop-Depth Weighting
def ra_ext_end_one(arity: U32, iv: RaIv, edge: RaEdge) -> RaIv:
  match iv edge:
    case RaIv{+v, +s, +e, u, lu, seen} RaEdge{+ls, be, is_tail}:
      skip_tail = Bool.and(is_tail, U32.is_lt(v, arity))
      live_hdr = Bool.and(Bool.not(skip_tail), Bool.and(U32.is_le(s, ls), U32.is_ge(e, ls)))
      RaIv{v, s, Bool.pick(U32, live_hdr, U32.max(e, be), e), u, lu, seen}
def ra_ext_end(+arity: U32, es: List<&2, RaEdge>, iv: RaIv) -> RaIv:
  match es:
    case Nil{}: iv
    case Con{edge, t}: ra_ext_end(arity, t, ra_ext_end_one(arity, iv, edge))
def ra_ext_end_all(+arity: U32, es: List<&2, RaEdge>, iv: RaIv) -> RaIv:
  match es:
    case Nil{}: iv
    case Con{e1, Nil{}}: ra_ext_end_one(arity, iv, e1)
    case Con{+e1, Con{+e2, +t}}: ra_ext_end(arity, Con{e1, Con{e2, t}}, ra_ext_end(arity, Con{e1, Con{e2, t}}, iv))
def ra_weight_one(iv: RaIv, edge: RaEdge) -> RaIv:
  match iv edge:
    case RaIv{v, +s, +e, +u, +lu, seen} RaEdge{+ls, +be, _}:
      +hot = U32.is_gt(lu, 0)
      in_loop = Bool.and(hot, Bool.and(U32.is_ge(s, ls), U32.is_le(e, be)))
      hdr_in = Bool.and(hot, Bool.and(U32.is_lt(s, ls), Bool.and(U32.is_ge(e, ls), U32.is_le(e, be))))
      spans_hot = Bool.and(hot, Bool.and(U32.is_lt(s, ls), Bool.and(U32.is_gt(e, be), U32.is_gt(u, 2))))
      u_span = Bool.pick(U32, spans_hot, U32.add(2, U32.mul(U32.min(U32.sub(u, 2), 1000000), 8)), u)
      u2 = Bool.pick(U32, hdr_in, U32.mul(U32.min(u, 1000000), 12), Bool.pick(U32, in_loop, U32.mul(U32.min(u, 1000000), 8), u_span))
      RaIv{v, s, e, u2, lu, seen}
def ra_weight_edges(es: List<&2, RaEdge>, iv: RaIv) -> RaIv:
  match es:
    case Nil{}: iv
    case Con{edge, t}: ra_weight_edges(t, ra_weight_one(iv, edge))

type RaParts is Data:
  RaParts{cross: List<&2, RaIv>, xmm_nc: List<&2, RaIv>, gpr_nc: List<&2, RaIv>}
def ra_iv_is_leaf(+cd: Nat, no_lf: Bool, +s: U32, +e: U32, +cb: RaVec<U32>) -> Bool:
  match no_lf:
    case True{}: False{}
    case False{}:
      +e1 = U32.add(e, 1)
      Bool.and(U32.is_gt(s, 0), Bool.and(U32.is_lt(e1, 65536), U32.is_eq(ra_vec_get(U32, cd, 0, e1, cb), ra_vec_get(U32, cd, 0, s, cb))))
def ra_add_part_go(+cd: Nat, iv2: RaIv, is_f: Bool, +cb: RaVec<U32>, +rb: RaVec<U32>, +cr: List<&2, RaIv>, +xm: List<&2, RaIv>, +nc: List<&2, RaIv>) -> RaParts:
  RaIv{v, +s, +e, u, lu, seen} = iv2
  +s1 = U32.add(s, 1)
  is_cr = U32.is_gt(ra_vec_get(U32, cd, 0, e, cb), ra_vec_get(U32, cd, 0, s1, cb))
  is_rcr = U32.is_gt(ra_vec_get(U32, cd, 0, e, rb), ra_vec_get(U32, cd, 0, s1, rb))
  +iv: RaIv = RaIv{v, s, e, u, lu, seen}
  Bool.pick(RaParts, is_cr, RaParts{Con{iv, cr}, xm, nc}, Bool.pick(RaParts, Bool.and(is_f, Bool.not(is_rcr)), RaParts{cr, Con{iv, xm}, nc}, RaParts{cr, xm, Con{iv, nc}}))
def ra_add_part_chk(skip: Bool, cd: Nat, arity: U32, iv: RaIv, is_f: Bool, cb: RaVec<U32>, rb: RaVec<U32>, +es: List<&2, RaEdge>, cr: List<&2, RaIv>, xm: List<&2, RaIv>, nc: List<&2, RaIv>) -> RaParts:
  match skip:
    case True{}: RaParts{cr, xm, nc}
    case False{}: ra_add_part_go(cd, ra_weight_edges(es, ra_ext_end_all(arity, es, iv)), is_f, cb, rb, cr, xm, nc)
def ra_add_part(cd: Nat, arity: U32, iv: RaIv, is_f: Bool, cval: U32, cb: RaVec<U32>, rb: RaVec<U32>, +es: List<&2, RaEdge>, pts: RaParts) -> RaParts:
  match iv pts:
    case RaIv{_, _, _, _, _, False{}} _: pts
    case RaIv{v, +s, +e, u, lu, True{}} RaParts{cr, xm, nc}:
      ra_add_part_chk(Bool.and(U32.is_eq(s, e), U32.is_ne(cval, 0)), cd, arity, RaIv{v, s, e, u, lu, True{}}, is_f, cb, rb, es, cr, xm, nc)
def ra_is_f32(+vd: Nat, track_f: Bool, +v: U32, f32s: RaVec<Bool>, nf32s: RaVec<Bool>) -> Bool:
  match track_f:
    case False{}: False{}
    case True{}: Bool.and(ra_vec_get(Bool, vd, False{}, v, f32s), Bool.not(ra_vec_get(Bool, vd, False{}, v, nf32s)))
def ra_collect_ivs(+vd: Nat, +cd: Nat, +track_f: Bool, +arity: U32, n: Nat, +v: U32, +ivs: RaVec<RaIv>, +cvals: RaVec<U32>, +cb: RaVec<U32>, +rb: RaVec<U32>, +es: List<&2, RaEdge>, +f32s: RaVec<Bool>, +nf32s: RaVec<Bool>, pts: RaParts) -> RaParts:
  match n:
    case 0n: pts
    case 1n+p:
      iv = ra_vec_get(RaIv, vd, RaIv{v, 0, 0, 0, 0, False{}}, v, ivs)
      is_f = ra_is_f32(vd, track_f, v, f32s, nf32s)
      cv = ra_vec_get(U32, vd, 0, v, cvals)
      ra_collect_ivs(vd, cd, track_f, arity, p, U32.add(v, 1), ivs, cvals, cb, rb, es, f32s, nf32s, ra_add_part(cd, arity, iv, is_f, cv, cb, rb, es, pts))

# Merge Sort by Start Ascending, Weight Descending (O(N log N))
def ra_even(xs: List<&2, RaIv>) -> List<&2, RaIv>:
  match xs:
    case Nil{}: Nil{}
    case Con{x, Nil{}}: Con{x, Nil{}}
    case Con{x, Con{_, t}}: Con{x, ra_even(t)}
def ra_iv_ge(a: RaIv, b: RaIv) -> Bool:
  match a b:
    case RaIv{_, +sa, _, ua, _, _} RaIv{_, +sb, _, ub, _, _}:
      Bool.or(U32.is_lt(sa, sb), Bool.and(U32.is_eq(sa, sb), U32.is_ge(ua, ub)))
type RaMergeSt is Data:
  RaMergeSt{xs: List<&2, RaIv>, ys: List<&2, RaIv>, acc: List<&2, RaIv>}
def ra_merge_pick(ge: Bool, x: RaIv, xt: List<&2, RaIv>, y: RaIv, yt: List<&2, RaIv>, acc: List<&2, RaIv>) -> RaMergeSt:
  match ge:
    case True{}: RaMergeSt{xt, Con{y, yt}, Con{x, acc}}
    case False{}: RaMergeSt{Con{x, xt}, yt, Con{y, acc}}
def ra_merge_run(fuel: Nat, st: RaMergeSt) -> List<&2, RaIv>:
  match fuel st:
    case 0n RaMergeSt{xs, ys, acc}: b5k_list_rev_go(RaIv, acc, b5k_list_app(RaIv, xs, ys))
    case 1n+p RaMergeSt{Nil{}, ys, acc}: b5k_list_rev_go(RaIv, acc, ys)
    case 1n+p RaMergeSt{xs, Nil{}, acc}: b5k_list_rev_go(RaIv, acc, xs)
    case 1n+p RaMergeSt{Con{+x, xt}, Con{+y, yt}, acc}: ra_merge_run(p, ra_merge_pick(ra_iv_ge(x, y), x, xt, y, yt, acc))
def ra_merge(+xs: List<&2, RaIv>, +ys: List<&2, RaIv>) -> List<&2, RaIv>:
  ra_merge_run(U32.to_nat(U32.add(b5k_list_len(RaIv, xs), b5k_list_len(RaIv, ys))), RaMergeSt{xs, ys, Nil{}})
def ra_msort(+d: Nat, xs: List<&2, RaIv>) -> List<&2, RaIv>:
  match d xs:
    case 0n _: xs
    case _ Nil{}: Nil{}
    case _ Con{x, Nil{}}: Con{x, Nil{}}
    case 1n+p Con{x, Con{y, +t}}: ra_merge(ra_msort(p, Con{x, ra_even(t)}), ra_msort(p, ra_even(Con{y, t})))

# Physical Register Pool Assignment (Linear Scan + Weight Eviction, Short-Circuiting)
type RaSlot is Data:
  RaSlot{reg: U32, vid: U32, start: U32, last_end: U32, weight: U32, used: Bool}
type RaTry is Data:
  RaTry{ok: Bool, reg: U32, pool: List<&2, RaSlot>}
type RaMin is Data:
  RaMin{found: Bool, reg: U32, vid: U32, start: U32, weight: U32, last_end: U32}
type RaSpills is Data:
  RaSpills{cnt: U32, svid: RaVec<U32>, send: RaVec<U32>}
type RaAllocSt is Data:
  RaAllocSt{rmap: RaVec<U32>, callee: List<&2, RaSlot>, caller: List<&2, RaSlot>, leaf: List<&2, RaSlot>, spills: RaSpills}

def ra_slot_free(used: Bool, last_end: U32, s: U32) -> Bool: Bool.or(Bool.not(used), U32.is_lt(last_end, s))
def ra_try_go(+use_p: Bool, pool: List<&2, RaSlot>, found: Bool, +reg: U32, +pref: U32, +src: U32, +only_used: Bool, +v: U32, +s: U32, +e: U32, +w: U32, acc: List<&2, RaSlot>) -> RaTry:
  match pool found:
    case rest True{}: RaTry{True{}, reg, b5k_list_rev_go(RaSlot, acc, rest)}
    case Nil{} False{}: RaTry{False{}, 0, b5k_list_rev(RaSlot, acc)}
    case Con{RaSlot{+r, +ov, os, +le, ow, +u}, t} False{}:
      +free = ra_slot_free(u, le, s)
      can_coal = Bool.and(u, Bool.and(U32.is_eq(ov, src), U32.is_le(le, s)))
      phit = Bool.and(U32.is_eq(r, pref), Bool.or(can_coal, Bool.and(Bool.not(only_used), free)))
      +hit = Bool.pick(Bool, use_p, phit, free)
      sl = Bool.pick(RaSlot, hit, RaSlot{r, v, s, e, w, True{}}, RaSlot{r, ov, os, le, ow, u})
      ra_try_go(use_p, t, hit, r, pref, src, only_used, v, s, e, w, Con{sl, acc})
def ra_try_pool(pool: List<&2, RaSlot>, v: U32, s: U32, e: U32, w: U32) -> RaTry: ra_try_go(False{}, pool, False{}, 0, 0, 0, False{}, v, s, e, w, Nil{})
def ra_try_pref_fin(tr: RaTry, fb: Bool, v: U32, s: U32, e: U32, w: U32) -> RaTry:
  match tr fb:
    case RaTry{True{}, r, pl} _: RaTry{True{}, r, pl}
    case RaTry{False{}, _, pl} True{}: ra_try_pool(pl, v, s, e, w)
    case RaTry{False{}, _, pl} False{}: RaTry{False{}, 0, pl}
def ra_try_pref_s2(has_p: Bool, p: U32, src: U32, pool: List<&2, RaSlot>, only_used: Bool, fb: Bool, +v: U32, +s: U32, +e: U32, +w: U32) -> RaTry:
  match has_p:
    case True{}: ra_try_pref_fin(ra_try_go(True{}, pool, False{}, 0, p, src, only_used, v, s, e, w, Nil{}), fb, v, s, e, w)
    case False{}: ra_try_pref_fin(RaTry{False{}, 0, pool}, fb, v, s, e, w)
def ra_try_pref_s1(has_h: Bool, vd: Nat, h: U32, rmap: RaVec<U32>, pool: List<&2, RaSlot>, only_used: Bool, fb: Bool, +v: U32, +s: U32, +e: U32, +w: U32) -> RaTry:
  match has_h:
    case False{}: ra_try_pref_fin(RaTry{False{}, 0, pool}, fb, v, s, e, w)
    case True{}:
      +src = U32.sub(h, 1)
      +p = ra_vec_get(U32, vd, 0, src, rmap)
      ra_try_pref_s2(Bool.and(U32.is_ne(p, 0), U32.is_lt(p, 100)), p, src, pool, only_used, fb, v, s, e, w)
def ra_try_pool_pref(+vd: Nat, hints: RaVec<U32>, rmap: RaVec<U32>, pool: List<&2, RaSlot>, only_used: Bool, fb: Bool, +v: U32, s: U32, e: U32, w: U32) -> RaTry:
  +h = ra_vec_get(U32, vd, 0, v, hints)
  ra_try_pref_s1(U32.is_ne(h, 0), vd, h, rmap, pool, only_used, fb, v, s, e, w)
def ra_find_min_go(pool: List<&2, RaSlot>, cur: RaMin) -> RaMin:
  match pool cur:
    case Nil{} _: cur
    case Con{RaSlot{r, vid, st, le, w, _}, t} RaMin{False{}, _, _, _, _, _}: ra_find_min_go(t, RaMin{True{}, r, vid, st, w, le})
    case Con{RaSlot{r, vid, st, +le, +w, _}, t} RaMin{True{}, cr, cv, cs, +cw, +cle}:
      better = Bool.or(U32.is_lt(w, cw), Bool.and(U32.is_eq(w, cw), U32.is_gt(le, cle)))
      ra_find_min_go(t, Bool.pick(RaMin, better, RaMin{True{}, r, vid, st, w, le}, RaMin{True{}, cr, cv, cs, cw, cle}))
def ra_rep_go(pool: List<&2, RaSlot>, done: Bool, +tgt: U32, +v: U32, +s: U32, +e: U32, +w: U32, acc: List<&2, RaSlot>) -> List<&2, RaSlot>:
  match pool done:
    case rest True{}: b5k_list_rev_go(RaSlot, acc, rest)
    case Nil{} False{}: b5k_list_rev(RaSlot, acc)
    case Con{RaSlot{+r, ov, os, le, ow, u}, t} False{}:
      +hit = U32.is_eq(r, tgt)
      sl = Bool.pick(RaSlot, hit, RaSlot{r, v, s, e, w, True{}}, RaSlot{r, ov, os, le, ow, u})
      ra_rep_go(t, hit, tgt, v, s, e, w, Con{sl, acc})
def ra_replace_slot(pool: List<&2, RaSlot>, tgt: U32, v: U32, s: U32, e: U32, w: U32) -> List<&2, RaSlot>: ra_rep_go(pool, False{}, tgt, v, s, e, w, Nil{})

type RaEvictRes is Data:
  RaEvictRes{rmap: RaVec<U32>, pool: List<&2, RaSlot>, spills: RaSpills}
def ra_spill_v(+vd: Nat, +v: U32, s: U32, +e: U32, hints: RaVec<U32>, +rm: RaVec<U32>, pl: List<&2, RaSlot>, sp: RaSpills) -> RaEvictRes:
  RaSpills{+c, +sv, +se} = sp
  +h = ra_vec_get(U32, vd, 0, v, hints)
  +src = U32.sub(h, 1)
  +p = Bool.pick(U32, U32.is_ne(h, 0), ra_vec_get(U32, vd, 0, src, rm), 0)
  +sl = Bool.pick(U32, U32.is_ge(p, 100), U32.sub(p, 100), 0)
  +ok = Bool.and(U32.is_ge(p, 100), Bool.and(U32.is_eq(ra_vec_get(U32, vd, 4294967295, sl, sv), src), U32.is_le(ra_vec_get(U32, vd, 4294967295, sl, se), s)))
  +us = Bool.pick(U32, ok, sl, c)
  RaEvictRes{ra_vec_set(U32, vd, v, U32.add(100, us), rm), pl, RaSpills{Bool.pick(U32, ok, c, U32.add(c, 1)), ra_vec_set(U32, vd, us, v, sv), ra_vec_set(U32, vd, us, e, se)}}
def ra_evict_fin(+vd: Nat, do_ev: Bool, +mr: U32, +mvid: U32, mle: U32, +v: U32, s: U32, e: U32, w: U32, hints: RaVec<U32>, rm: RaVec<U32>, pl: List<&2, RaSlot>, sp: RaSpills) -> RaEvictRes:
  match do_ev sp:
    case True{} RaSpills{+c, sv, se}:
      rm1 = ra_vec_set(U32, vd, v, mr, ra_vec_set(U32, vd, mvid, U32.add(100, c), rm))
      RaEvictRes{rm1, ra_replace_slot(pl, mr, v, s, e, w), RaSpills{U32.add(c, 1), ra_vec_set(U32, vd, c, mvid, sv), ra_vec_set(U32, vd, c, mle, se)}}
    case False{} sp0: ra_spill_v(vd, v, s, e, hints, rm, pl, sp0)
def ra_evict_pool(vd: Nat, mn: RaMin, v: U32, s: U32, +e: U32, +w: U32, hints: RaVec<U32>, rm: RaVec<U32>, pl: List<&2, RaSlot>, sp: RaSpills) -> RaEvictRes:
  RaMin{found, mr, mvid, _, +mw, +mle} = mn
  better = Bool.or(U32.is_gt(w, mw), Bool.and(U32.is_eq(w, mw), U32.is_gt(mle, e)))
  ra_evict_fin(vd, Bool.and(found, better), mr, mvid, mle, v, s, e, w, hints, rm, pl, sp)
def ra_put_pool(which: U32, ev: RaEvictRes, ce: List<&2, RaSlot>, cr: List<&2, RaSlot>, lf: List<&2, RaSlot>) -> RaAllocSt:
  match which ev:
    case 0 RaEvictRes{rm, p2, sp}: RaAllocSt{rm, p2, cr, lf, sp}
    case 1 RaEvictRes{rm, p2, sp}: RaAllocSt{rm, ce, p2, lf, sp}
    case _ RaEvictRes{rm, p2, sp}: RaAllocSt{rm, ce, cr, p2, sp}
def ra_min_lt(a: RaMin, b: RaMin) -> Bool:
  match a b:
    case RaMin{+fa, _, _, _, +wa, +lea} RaMin{+fb, _, _, _, +wb, +leb}:
      Bool.and(fa, Bool.or(Bool.not(fb), Bool.or(U32.is_lt(wa, wb), Bool.and(U32.is_eq(wa, wb), U32.is_gt(lea, leb)))))
def ra_evict_lce_go(pick_ce: Bool, pick_lf: Bool, vd: Nat, ml: RaMin, mc: RaMin, me: RaMin, v: U32, s: U32, e: U32, w: U32, hints: RaVec<U32>, rm: RaVec<U32>, ce: List<&2, RaSlot>, cr: List<&2, RaSlot>, lf: List<&2, RaSlot>, sp: RaSpills) -> RaAllocSt:
  match pick_ce pick_lf:
    case True{} _: ra_put_pool(0, ra_evict_pool(vd, me, v, s, e, w, hints, rm, ce, sp), Nil{}, cr, lf)
    case False{} True{}: ra_put_pool(2, ra_evict_pool(vd, ml, v, s, e, w, hints, rm, lf, sp), ce, cr, Nil{})
    case False{} False{}: ra_put_pool(1, ra_evict_pool(vd, mc, v, s, e, w, hints, rm, cr, sp), ce, Nil{}, lf)
def ra_evict_lce(can_ce: Bool, vd: Nat, +ml: RaMin, +mc: RaMin, +me: RaMin, v: U32, s: U32, e: U32, w: U32, hints: RaVec<U32>, rm: RaVec<U32>, ce: List<&2, RaSlot>, cr: List<&2, RaSlot>, lf: List<&2, RaSlot>, sp: RaSpills) -> RaAllocSt:
  +pick_lf = ra_min_lt(ml, mc)
  best_lc = Bool.pick(RaMin, pick_lf, ml, mc)
  ra_evict_lce_go(Bool.and(can_ce, ra_min_lt(me, best_lc)), pick_lf, vd, ml, mc, me, v, s, e, w, hints, rm, ce, cr, lf, sp)

def ra_assign_cross_fin(vd: Nat, hints: RaVec<U32>, tr: RaTry, +v: U32, s: U32, e: U32, w: U32, rm: RaVec<U32>, cr: List<&2, RaSlot>, lf: List<&2, RaSlot>, sp: RaSpills) -> RaAllocSt:
  match tr:
    case RaTry{True{}, r, ce2}: RaAllocSt{ra_vec_set(U32, vd, v, r, rm), ce2, cr, lf, sp}
    case RaTry{False{}, _, +ce2}: ra_put_pool(0, ra_evict_pool(vd, ra_find_min_go(ce2, RaMin{False{}, 0, 0, 0, 0, 0}), v, s, e, w, hints, rm, ce2, sp), Nil{}, cr, lf)
def ra_assign_cross(+vd: Nat, +hints: RaVec<U32>, xs: List<&2, RaIv>, st: RaAllocSt) -> RaAllocSt:
  match xs st:
    case Nil{} _: st
    case Con{RaIv{+v, +s, +e, +w, _, _}, t} RaAllocSt{+rm, ce, cr, lf, sp}:
      ra_assign_cross(vd, hints, t, ra_assign_cross_fin(vd, hints, ra_try_pool_pref(vd, hints, rm, ce, False{}, True{}, v, s, e, w), v, s, e, w, rm, cr, lf, sp))

def ra_used_callee(pool: List<&2, RaSlot>) -> List<&2, U32>:
  match pool:
    case Nil{}: Nil{}
    case Con{RaSlot{_, _, _, _, _, False{}}, t}: ra_used_callee(t)
    case Con{RaSlot{r, _, _, _, _, True{}}, t}: Con{r, ra_used_callee(t)}
def ra_mk_slots(rs: List<&2, U32>) -> List<&2, RaSlot>:
  match rs:
    case Nil{}: Nil{}
    case Con{r, t}: Con{RaSlot{r, 0, 0, 0, 0, False{}}, ra_mk_slots(t)}
def ra_init_leaf(arity: U32) -> List<&2, RaSlot>:
  r7 = Bool.pick(RaSlot, U32.is_lt(arity, 5), RaSlot{7, 0, 0, 0, 0, False{}}, RaSlot{7, 4294967295, 0, 0, 4294967295, True{}})
  Con{RaSlot{6, 0, 0, 0, 0, False{}}, Con{r7, Nil{}}}
def ra_init_xmm_go(n: Nat, +r: U32) -> List<&2, RaSlot>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{RaSlot{r, 0, 0, 0, 0, False{}}, ra_init_xmm_go(p, U32.add(r, 1))}

def ra_assign_try(step: Nat, is_lf: Bool, can_ce: Bool, +vd: Nat, +hints: RaVec<U32>, tr: RaTry, +v: U32, +s: U32, +e: U32, +w: U32, +rm: RaVec<U32>, ce: List<&2, RaSlot>, +cr: List<&2, RaSlot>, +lf: List<&2, RaSlot>, sp: RaSpills) -> RaAllocSt:
  match step is_lf tr:
    case 2n True{} RaTry{True{}, r, lf2}: RaAllocSt{ra_vec_set(U32, vd, v, r, rm), ce, cr, lf2, sp}
    case 2n True{} RaTry{False{}, _, lf2}: ra_assign_try(1n, True{}, can_ce, vd, hints, ra_try_pool_pref(vd, hints, rm, cr, False{}, True{}, v, s, e, w), v, s, e, w, rm, ce, Nil{}, lf2, sp)
    case 3n False{} RaTry{True{}, r, cr2}: RaAllocSt{ra_vec_set(U32, vd, v, r, rm), ce, cr2, lf, sp}
    case 3n False{} RaTry{False{}, _, cr2}: ra_assign_try(2n, False{}, can_ce, vd, hints, ra_try_pool_pref(vd, hints, rm, ce, True{}, False{}, v, s, e, w), v, s, e, w, rm, Nil{}, cr2, lf, sp)
    case 2n False{} RaTry{True{}, r, ce2}: RaAllocSt{ra_vec_set(U32, vd, v, r, rm), ce2, cr, lf, sp}
    case 2n False{} RaTry{False{}, _, ce2}: ra_assign_try(1n, False{}, can_ce, vd, hints, ra_try_pool(cr, v, s, e, w), v, s, e, w, rm, ce2, Nil{}, lf, sp)
    case 1n _ RaTry{True{}, r, cr2}: RaAllocSt{ra_vec_set(U32, vd, v, r, rm), ce, cr2, lf, sp}
    case 1n True{} RaTry{False{}, _, cr2}: ra_assign_try(0n, True{}, can_ce, vd, hints, ra_try_pool_pref(vd, hints, rm, ce, False{}, True{}, v, s, e, w), v, s, e, w, rm, Nil{}, cr2, lf, sp)
    case 1n False{} RaTry{False{}, _, cr2}: ra_assign_try(0n, False{}, can_ce, vd, hints, ra_try_pool(ce, v, s, e, w), v, s, e, w, rm, Nil{}, cr2, lf, sp)
    case 0n _ RaTry{True{}, r, ce2}: RaAllocSt{ra_vec_set(U32, vd, v, r, rm), ce2, cr, lf, sp}
    case 0n True{} RaTry{False{}, _, +ce2}: ra_evict_lce(can_ce, vd, ra_find_min_go(lf, RaMin{False{}, 0, 0, 0, 0, 0}), ra_find_min_go(cr, RaMin{False{}, 0, 0, 0, 0, 0}), ra_find_min_go(ce2, RaMin{False{}, 0, 0, 0, 0, 0}), v, s, e, w, hints, rm, ce2, cr, lf, sp)
    case 0n False{} RaTry{False{}, _, +ce2}: ra_evict_lce(can_ce, vd, RaMin{False{}, 0, 0, 0, 0, 0}, ra_find_min_go(cr, RaMin{False{}, 0, 0, 0, 0, 0}), ra_find_min_go(ce2, RaMin{False{}, 0, 0, 0, 0, 0}), v, s, e, w, hints, rm, ce2, cr, lf, sp)
    case _ _ _: RaAllocSt{rm, ce, cr, lf, sp}
def ra_assign_ncl_disp(can_ce: Bool, is_lf: Bool, +vd: Nat, +hints: RaVec<U32>, +v: U32, +s: U32, +e: U32, +w: U32, +rm: RaVec<U32>, ce: List<&2, RaSlot>, cr: List<&2, RaSlot>, lf: List<&2, RaSlot>, sp: RaSpills) -> RaAllocSt:
  match is_lf:
    case True{}: ra_assign_try(2n, True{}, can_ce, vd, hints, ra_try_pool_pref(vd, hints, rm, lf, False{}, True{}, v, s, e, w), v, s, e, w, rm, ce, cr, Nil{}, sp)
    case False{}: ra_assign_try(3n, False{}, can_ce, vd, hints, ra_try_pool_pref(vd, hints, rm, cr, False{}, False{}, v, s, e, w), v, s, e, w, rm, ce, Nil{}, lf, sp)
def ra_assign_nc_leaf(+can_ce: Bool, +no_lf: Bool, +vd: Nat, +cd: Nat, +hints: RaVec<U32>, +cb: RaVec<U32>, xs: List<&2, RaIv>, st: RaAllocSt) -> RaAllocSt:
  match xs st:
    case Nil{} _: st
    case Con{RaIv{+v, +s, +e, +w, _, _}, t} RaAllocSt{+rm, ce, cr, lf, sp}:
      ra_assign_nc_leaf(can_ce, no_lf, vd, cd, hints, cb, t, ra_assign_ncl_disp(can_ce, ra_iv_is_leaf(cd, no_lf, s, e, cb), vd, hints, v, s, e, w, rm, ce, cr, lf, sp))

type RaXmmSt is Data:
  RaXmmSt{rmap: RaVec<U32>, pool: List<&2, RaSlot>, over: List<&2, RaIv>}
def ra_evict_xmm_fin(+vd: Nat, do_ev: Bool, +mr: U32, +mvid: U32, ms: U32, mw: U32, mle: U32, +v: U32, +s: U32, +e: U32, +w: U32, rm: RaVec<U32>, xp: List<&2, RaSlot>, ov: List<&2, RaIv>) -> RaXmmSt:
  match do_ev:
    case True{}:
      rm1 = ra_vec_set(U32, vd, v, mr, ra_vec_set(U32, vd, mvid, 0, rm))
      RaXmmSt{rm1, ra_replace_slot(xp, mr, v, s, e, w), Con{RaIv{mvid, ms, mle, mw, 1, True{}}, ov}}
    case False{}: RaXmmSt{rm, xp, Con{RaIv{v, s, e, w, 1, True{}}, ov}}
def ra_evict_xmm(vd: Nat, mn: RaMin, v: U32, s: U32, e: U32, +w: U32, rm: RaVec<U32>, xp: List<&2, RaSlot>, ov: List<&2, RaIv>) -> RaXmmSt:
  RaMin{found, mr, mvid, ms, +mw, mle} = mn
  ra_evict_xmm_fin(vd, Bool.and(found, U32.is_gt(w, mw)), mr, mvid, ms, mw, mle, v, s, e, w, rm, xp, ov)
def ra_assign_xmm_fin(vd: Nat, tr: RaTry, +v: U32, s: U32, e: U32, w: U32, rm: RaVec<U32>, ov: List<&2, RaIv>) -> RaXmmSt:
  match tr:
    case RaTry{True{}, r, xp2}: RaXmmSt{ra_vec_set(U32, vd, v, r, rm), xp2, ov}
    case RaTry{False{}, _, +xp2}: ra_evict_xmm(vd, ra_find_min_go(xp2, RaMin{False{}, 0, 0, 0, 0, 0}), v, s, e, w, rm, xp2, ov)
def ra_assign_xmm_ov(+vd: Nat, +hints: RaVec<U32>, xs: List<&2, RaIv>, st: RaXmmSt) -> RaXmmSt:
  match xs st:
    case Nil{} _: st
    case Con{RaIv{+v, +s, +e, +w, _, _}, t} RaXmmSt{+rm, xp, ov}:
      ra_assign_xmm_ov(vd, hints, t, ra_assign_xmm_fin(vd, ra_try_pool_pref(vd, hints, rm, xp, False{}, True{}, v, s, e, w), v, s, e, w, rm, ov))

def ra_finish_st(vd: Nat, st1: RaAllocSt) -> RegAllocRes:
  RaAllocSt{rm, ce, _, _, RaSpills{sp, _, _}} = st1
  RegAllocRes{rm, vd, ra_used_callee(ce), sp}
def ra_finish_gpr(+vd: Nat, cd: Nat, +hints: RaVec<U32>, no_calls: Bool, res_h: Bool, can_ce: Bool, arity: U32, cb: RaVec<U32>, rm0: RaVec<U32>, cr: List<&2, RaIv>, nc: List<&2, RaIv>) -> RegAllocRes:
  match no_calls:
    case True{}:
      nc_s = ra_msort(20n, nc)
      ra_finish_st(vd, ra_assign_nc_leaf(True{}, True{}, vd, cd, hints, RVEmpty{}, nc_s, RaAllocSt{rm0, ra_mk_slots([3, 12, 13, 14, 15]), b5k_list_app(RaSlot, ra_mk_slots([8, 9, 10, 11]), ra_init_leaf(arity)), Nil{}, RaSpills{0, RVEmpty{}, RVEmpty{}}}))
    case False{}:
      cr_s = ra_msort(20n, cr)
      nc_s = ra_msort(20n, nc)
      cr0 = ra_mk_slots(Bool.pick(List<&2, U32>, res_h, [8, 9], [8, 9, 10, 11]))
      st1 = ra_assign_cross(vd, hints, cr_s, RaAllocSt{rm0, ra_mk_slots([3, 12, 13, 14, 15]), cr0, ra_init_leaf(arity), RaSpills{0, RVEmpty{}, RVEmpty{}}})
      ra_finish_st(vd, ra_assign_nc_leaf(can_ce, False{}, vd, cd, hints, cb, nc_s, st1))
def ra_finish_with_xmm(+vd: Nat, cd: Nat, +hints: RaVec<U32>, no_calls: Bool, res_h: Bool, can_ce: Bool, arity: U32, cb: RaVec<U32>, cr: List<&2, RaIv>, nc: List<&2, RaIv>, xst: RaXmmSt) -> RegAllocRes:
  RaXmmSt{rm, _, ov} = xst
  ra_finish_gpr(vd, cd, hints, no_calls, res_h, can_ce, arity, cb, rm, cr, b5k_list_app(RaIv, nc, ov))
def ra_finish_parts(+vd: Nat, cd: Nat, +hints: RaVec<U32>, no_calls: Bool, res_h: Bool, can_ce: Bool, arity: U32, cb: RaVec<U32>, pts: RaParts) -> RegAllocRes:
  match pts:
    case RaParts{cr, Nil{}, nc}: ra_finish_gpr(vd, cd, hints, no_calls, res_h, can_ce, arity, cb, RVEmpty{}, cr, nc)
    case RaParts{cr, xm, nc}:
      xm_s = ra_msort(20n, xm)
      xst = ra_assign_xmm_ov(vd, hints, xm_s, RaXmmSt{RVEmpty{}, ra_init_xmm_go(14n, 22), Nil{}})
      ra_finish_with_xmm(vd, cd, hints, no_calls, res_h, can_ce, arity, cb, cr, nc, xst)
def ra_finish_scan(+vd: Nat, +cd: Nat, track_f: Bool, +has_arr: Bool, +arity: U32, total: U32, scan: RaScan) -> RegAllocRes:
  RaScan{ivs, _, cb, +nc, rb, +nr, es, f32s, nf32s, hints, cvals, +idx} = scan
  +no_rt = U32.is_zero(nr)
  +can_ce = U32.is_zero(nc)
  res_h = Bool.and(can_ce, has_arr)
  cb1 = ra_rec_cb(cd, U32.is_ne(nc, 0), idx, nc, cb)
  +rb1 = ra_rec_cb(cd, Bool.not(no_rt), idx, nr, rb)
  ra_finish_parts(vd, cd, hints, no_rt, res_h, can_ce, arity, rb1, ra_collect_ivs(vd, cd, track_f, arity, U32.to_nat(total), 0, ivs, cvals, cb1, rb1, es, f32s, nf32s, RaParts{Nil{}, Nil{}, Nil{}}))
def ra_ops_info(ops: List<&2, IrOp>, +acc: U32) -> U32:
  match ops:
    case Nil{}: acc
    case Con{IFlt{_, _}, t}: ra_ops_info(t, U32.or(U32.add(acc, 4), 2))
    case Con{IBin{_, bop, _, _}, t}: ra_ops_info(t, U32.or(U32.add(acc, 4), Bool.pick(U32, U32.is_ge(bop, 10), 2, 0)))
    case Con{IUn{_, uop, _}, t}: ra_ops_info(t, U32.or(U32.add(acc, 4), Bool.pick(U32, U32.is_ge(uop, 2), 2, 0)))
    case Con{ICmp{_, cop, _, _}, t}: ra_ops_info(t, U32.or(U32.add(acc, 4), Bool.pick(U32, U32.is_ge(cop, 6), 2, 0)))
    case Con{IArrOp{_, _, _}, t}: ra_ops_info(t, U32.or(U32.add(acc, 4), 1))
    case Con{_, t}: ra_ops_info(t, U32.add(acc, 4))
def ra_blks_info(blks: List<&2, IrBlock>, acc: U32) -> U32:
  match blks:
    case Nil{}: acc
    case Con{IrBlock{_, ops, _}, t}: ra_blks_info(t, ra_ops_info(ops, U32.add(acc, 4)))
def ra_vd_of(+tot: U32) -> Nat: Bool.pick(Nat, U32.is_le(tot, 64), 3n, Bool.pick(Nat, U32.is_le(tot, 256), 4n, Bool.pick(Nat, U32.is_le(tot, 1024), 5n, 8n)))
def b5k_regalloc(fn: IrFn) -> RegAllocRes:
  IrFn{fid, _, +arity, +nregs, _, _, _, +blocks} = fn
  +info = ra_blks_info(blocks, 8)
  +hf = U32.is_ne(U32.and(info, 2), 0)
  ha = U32.is_ne(U32.and(info, 1), 0)
  +tot = U32.max(nregs, arity)
  +vd = ra_vd_of(tot)
  +nops = U32.add(U32.shrn(info, 2n), 2)
  +cd = Bool.pick(Nat, U32.is_le(nops, 250), 4n, Bool.pick(Nat, U32.is_le(nops, 1000), 5n, 8n))
  ivs0 = ra_init_params(vd, U32.to_nat(arity), 0, RVEmpty{})
  scan = ra_scan_blks(vd, cd, hf, fid, blocks, RaScan{ivs0, RVEmpty{}, RVEmpty{}, 0, RVEmpty{}, 0, Nil{}, RVEmpty{}, RVEmpty{}, RVEmpty{}, RVEmpty{}, 1})
  ra_finish_scan(vd, cd, hf, ha, arity, tot, scan)

def ra_spill_list(+vd: Nat, xs: List<&2, RaIv>, ev: RaEvictRes) -> RegAllocRes:
  match xs ev:
    case Nil{} RaEvictRes{rm, _, RaSpills{c, _, _}}: RegAllocRes{rm, vd, Nil{}, c}
    case Con{RaIv{v, s, e, _, _, _}, t} RaEvictRes{rm, _, sp}: ra_spill_list(vd, t, ra_spill_v(vd, v, s, e, RVEmpty{}, rm, Nil{}, sp))
def ra_v4_split(xs: List<&2, RaIv>, p0: List<&2, RaIv>, p1: List<&2, RaIv>) -> List<&2, RaIv> & List<&2, RaIv>:
  match xs:
    case Nil{}: (p0, p1)
    case Con{RaIv{v, 0, e, u, lu, sn}, t}: ra_v4_split(t, Con{RaIv{v, 0, e, u, lu, sn}, p0}, p1)
    case Con{iv, t}: ra_v4_split(t, p0, Con{iv, p1})
def ra_v4_s4(vd: Nat, ov0: List<&2, RaIv>, xst1: RaXmmSt) -> RegAllocRes:
  match xst1:
    case RaXmmSt{rm1, _, ov1}: ra_spill_list(vd, ra_msort(20n, b5k_list_app(RaIv, ov0, ov1)), RaEvictRes{rm1, Nil{}, RaSpills{0, RVEmpty{}, RVEmpty{}}})
def ra_v4_s3(+vd: Nat, hints: RaVec<U32>, p1: List<&2, RaIv>, xst0: RaXmmSt) -> RegAllocRes:
  match xst0:
    case RaXmmSt{rm0, _, ov0}: ra_v4_s4(vd, ov0, ra_assign_xmm_ov(vd, hints, ra_msort(20n, p1), RaXmmSt{rm0, ra_init_xmm_go(10n, 26), Nil{}}))
def ra_v4_s2p(+vd: Nat, +hints: RaVec<U32>, sp: List<&2, RaIv> & List<&2, RaIv>) -> RegAllocRes:
  (p0, p1) = sp
  ra_v4_s3(vd, hints, p1, ra_assign_xmm_ov(vd, hints, ra_msort(20n, p0), RaXmmSt{RVEmpty{}, ra_init_xmm_go(4n, 22), Nil{}}))
def ra_v4_s2(+vd: Nat, hints: RaVec<U32>, pts: RaParts) -> RegAllocRes:
  match pts:
    case RaParts{_, xm, nc}: ra_v4_s2p(vd, hints, ra_v4_split(b5k_list_app(RaIv, xm, nc), Nil{}, Nil{}))
def ra_v4_s1(+vd: Nat, cd: Nat, arity: U32, tot: U32, scan: RaScan) -> RegAllocRes:
  match scan:
    case RaScan{ivs, _, cb, _, rb, _, es, f32s, nf32s, hints, cvals, _}:
      ra_v4_s2(vd, hints, ra_collect_ivs(vd, cd, True{}, arity, U32.to_nat(tot), 0, ivs, cvals, cb, rb, es, f32s, nf32s, RaParts{Nil{}, Nil{}, Nil{}}))
def b5k_regalloc_v4(fn: IrFn) -> RegAllocRes:
  IrFn{fid, _, +arity, +nregs, _, _, _, +blocks} = fn
  +tot = U32.max(nregs, arity)
  +vd = ra_vd_of(tot)
  +nops = U32.add(U32.shrn(ra_blks_info(blocks, 8), 2n), 2)
  +cd = Bool.pick(Nat, U32.is_le(nops, 250), 4n, Bool.pick(Nat, U32.is_le(nops, 1000), 5n, 8n))
  ivs0 = ra_init_params(vd, U32.to_nat(U32.sub(arity, 1)), 1, RVEmpty{})
  ra_v4_s1(vd, cd, arity, tot, ra_scan_blks(vd, cd, True{}, fid, blocks, RaScan{ivs0, RVEmpty{}, RVEmpty{}, 0, RVEmpty{}, 0, Nil{}, RVEmpty{}, RVEmpty{}, RVEmpty{}, RVEmpty{}, 1}))

# Part 2: Typed X64Inst Peephole Optimizer (Short-Circuiting)
def peep_is_caller_scratch(+r: U32) -> Bool:
  Bool.or(Bool.or(U32.is_eq(r, 1), U32.is_eq(r, 2)), Bool.or(Bool.or(U32.is_eq(r, 6), U32.is_eq(r, 7)), Bool.and(U32.is_ge(r, 8), U32.is_le(r, 11))))

def peep_kills_reg(+r: U32, inst: X64Inst) -> Bool:
  match inst:
    case XMovRI32{d, _}: U32.is_eq(d, r)
    case XMovRI64{d, _, _}: U32.is_eq(d, r)
    case XLeaRip{d, _}: U32.is_eq(d, r)
    case XLoad{d, b, _}: Bool.and(U32.is_eq(d, r), U32.is_ne(b, r))
    case XMovRR{d, s}: Bool.and(U32.is_eq(d, r), U32.is_ne(s, r))
    case XAluRR{op, d, s}: Bool.and(U32.is_eq(op, 7), Bool.and(U32.is_eq(d, r), U32.is_eq(s, r)))
    case XPop{d}: Bool.and(U32.is_eq(d, r), U32.is_ne(r, 4))
    case XCvt{+op, d, _}: Bool.and(Bool.or(U32.is_eq(op, 1), U32.is_eq(op, 3)), U32.is_eq(d, r))
    case XRet{}: peep_is_caller_scratch(r)
    case XCallSym{_}: Bool.or(U32.is_eq(r, 10), U32.is_eq(r, 11))
    case XCallReg{rg}: Bool.and(Bool.or(U32.is_eq(r, 10), U32.is_eq(r, 11)), U32.is_ne(rg, r))
    case _: False{}

def peep_reads_reg(+r: U32, inst: X64Inst) -> Bool:
  match inst:
    case XMovRR{_, s}: U32.is_eq(s, r)
    case XMovRI32{_, _}: False{}
    case XMovRI64{_, _, _}: False{}
    case XLeaRip{_, _}: False{}
    case XLoad{_, b, _}: U32.is_eq(b, r)
    case XStore{b, _, s}: Bool.or(U32.is_eq(b, r), U32.is_eq(s, r))
    case XAluRR{_, d, s}: Bool.or(U32.is_eq(d, r), U32.is_eq(s, r))
    case XAluRI{_, d, _}: U32.is_eq(d, r)
    case XShift{_, d, _, by_cl}: Bool.or(U32.is_eq(d, r), Bool.and(by_cl, U32.is_eq(r, 1)))
    case XMul{d, s}: Bool.or(U32.is_eq(d, r), U32.is_eq(s, r))
    case XCmpRR{a, b}: Bool.or(U32.is_eq(a, r), U32.is_eq(b, r))
    case XCmpRI{a, _}: U32.is_eq(a, r)
    case XTestRR{a, b}: Bool.or(U32.is_eq(a, r), U32.is_eq(b, r))
    case XSetcc{_, _}: False{}
    case XCmov{_, d, s}: Bool.or(U32.is_eq(d, r), U32.is_eq(s, r))
    case XPush{rg}: Bool.or(U32.is_eq(rg, r), U32.is_eq(r, 4))
    case XPop{_}: U32.is_eq(r, 4)
    case XSubRsp{_}: U32.is_eq(r, 4)
    case XAddRsp{_}: U32.is_eq(r, 4)
    case XXmmRR{_, _, _}: False{}
    case XXmmLoad{_, b, _}: U32.is_eq(b, r)
    case XXmmStore{b, _, _}: U32.is_eq(b, r)
    case XCvt{+op, _, s}: Bool.and(Bool.or(U32.is_eq(op, 0), U32.is_eq(op, 2)), U32.is_eq(s, r))
    case _: True{}

def peep_kills_xmm(+x: U32, inst: X64Inst) -> Bool:
  match inst:
    case XXmmRR{+op, d, s}: Bool.and(Bool.or(U32.is_eq(op, 7), Bool.or(U32.is_eq(op, 4), U32.is_eq(op, 12))), Bool.and(U32.is_eq(d, x), U32.is_ne(s, x)))
    case XXmmLoad{d, _, _}: U32.is_eq(U32.and(d, 15), x)
    case XCvt{+op, d, _}: Bool.and(Bool.or(U32.is_eq(op, 0), U32.is_eq(op, 2)), U32.is_eq(d, x))
    case _: False{}
def peep_reads_xmm(+x: U32, inst: X64Inst) -> Bool:
  match inst:
    case XXmmRR{+op, d, s}:
      Bool.or(U32.is_eq(s, x), Bool.and(Bool.and(U32.is_ne(op, 7), Bool.and(U32.is_ne(op, 4), U32.is_ne(op, 12))), U32.is_eq(d, x)))
    case XXmmStore{_, _, s}: U32.is_eq(U32.and(s, 15), x)
    case XCvt{+op, _, s}: Bool.and(Bool.or(U32.is_eq(op, 1), U32.is_eq(op, 3)), U32.is_eq(s, x))
    case XDiv{_, _}: True{}
    case XLabel{_}: True{}
    case XJmp{_}: True{}
    case XJcc{_, _}: True{}
    case XCallSym{_}: True{}
    case XCallReg{_}: True{}
    case XRet{}: True{}
    case XExtReloc{_, _, _}: True{}
    case _: False{}
def peep_dead_go(is_xmm: Bool, fuel: Nat, st: U32, +r: U32, xs: List<&2, X64Inst>) -> Bool:
  match is_xmm fuel st xs:
    case _ _ 1 _: True{}
    case _ _ 2 _: False{}
    case _ 0n _ _: False{}
    case _ _ _ Nil{}: False{}
    case False{} 1n+p _ Con{+h, t}:
      peep_dead_go(False{}, p, Bool.pick(U32, peep_kills_reg(r, h), 1, Bool.pick(U32, peep_reads_reg(r, h), 2, 0)), r, t)
    case True{} 1n+p _ Con{+h, t}:
      peep_dead_go(True{}, p, Bool.pick(U32, peep_kills_xmm(r, h), 1, Bool.pick(U32, peep_reads_xmm(r, h), 2, 0)), r, t)
def peep_dead_reg(fuel: Nat, r: U32, xs: List<&2, X64Inst>) -> Bool: peep_dead_go(False{}, fuel, 0, r, xs)
def peep_and_dead_k(is_xmm: Bool, cond: Bool, fuel: Nat, r: U32, t: List<&2, X64Inst>) -> Bool:
  match cond:
    case False{}: False{}
    case True{}: peep_dead_go(is_xmm, fuel, 0, r, t)
def peep_and_dead(cond: Bool, fuel: Nat, r: U32, t: List<&2, X64Inst>) -> Bool: peep_and_dead_k(False{}, cond, fuel, r, t)

def peep_flag_cc(inst: X64Inst) -> U32:
  match inst:
    case XJcc{cc, _}: U32.add(cc, 1)
    case XSetcc{cc, _}: U32.add(cc, 1)
    case XCmov{cc, _, _}: U32.add(cc, 1)
    case _: 0
def peep_preserves_flags(inst: X64Inst) -> Bool:
  match inst:
    case XMovRR{_, _}: True{}
    case XMovRI32{_, _}: True{}
    case XMovRI64{_, _, _}: True{}
    case XLoad{_, _, _}: True{}
    case XStore{_, _, _}: True{}
    case XLeaRip{_, _}: True{}
    case XCmov{_, _, _}: True{}
    case XPush{_}: True{}
    case XPop{_}: True{}
    case XXmmLoad{_, _, _}: True{}
    case XXmmStore{_, _, _}: True{}
    case _: False{}
def peep_fl_go(fuel: Nat, st: U32, xs: List<&2, X64Inst>) -> Bool:
  match fuel st xs:
    case _ 1 _: True{}
    case _ 2 _: False{}
    case 0n _ _: False{}
    case _ _ Nil{}: False{}
    case 1n+p _ Con{+h, t}:
      ns = Bool.pick(U32, U32.is_ne(peep_flag_cc(h), 0), 1, Bool.pick(U32, peep_preserves_flags(h), 0, 2))
      peep_fl_go(p, ns, t)
def peep_and_nflags(cond: Bool, fuel: Nat, t: List<&2, X64Inst>) -> Bool:
  match cond:
    case False{}: False{}
    case True{}: Bool.not(peep_fl_go(fuel, 0, t))

def peep_wr_gpr(inst: X64Inst) -> U32:
  match inst:
    case XLoad{d, _, _}: U32.add(d, 1)
    case XMovRI64{d, _, _}: U32.add(d, 1)
    case XLeaRip{d, _}: U32.add(d, 1)
    case XAluRR{_, d, _}: U32.add(d, 1)
    case XAluRI{_, d, _}: U32.add(d, 1)
    case XShift{_, d, _, _}: U32.add(d, 1)
    case XMul{d, _}: U32.add(d, 1)
    case XSetcc{_, d}: U32.add(d, 1)
    case XCmov{_, d, _}: U32.add(d, 1)
    case _: 0
def peep_dst_ok(+dst: U32, b: U32, r: U32) -> Bool: Bool.and(U32.is_ne(dst, b), U32.is_ne(dst, r))
def peep_no_alias(inst: X64Inst, +b: U32, d: U32, +r: U32) -> Bool:
  match inst:
    case XMovRR{dst, _}: peep_dst_ok(dst, b, r)
    case XMovRI32{dst, _}: peep_dst_ok(dst, b, r)
    case XStore{sb, sd, _}: Bool.and(Bool.and(U32.is_eq(b, 5), U32.is_eq(sb, 5)), U32.is_ne(sd, d))
    case XCmpRR{_, _}: True{}
    case XCmpRI{_, _}: True{}
    case XTestRR{_, _}: True{}
    case XXmmRR{_, _, _}: True{}
    case XXmmLoad{_, _, _}: True{}
    case h:
      +w = peep_wr_gpr(h)
      Bool.and(U32.is_ne(w, 0), peep_dst_ok(U32.sub(w, 1), b, r))

def peep_is_zero_alu(+op: U32, imm: U32) -> Bool:
  ok_op = Bool.or(Bool.or(U32.is_eq(op, 0), U32.is_eq(op, 1)), Bool.or(U32.is_eq(op, 6), U32.is_eq(op, 7)))
  Bool.and(ok_op, U32.is_zero(imm))
def peep_is_ztest(+d: U32, inst: X64Inst) -> Bool:
  match inst:
    case XTestRR{a, b}: Bool.and(U32.is_eq(a, d), U32.is_eq(b, d))
    case XCmpRI{a, imm}: Bool.and(U32.is_eq(a, d), U32.is_zero(imm))
    case _: False{}
def peep_dead_after_fin(is_z: Bool, rest: List<&2, X64Inst>) -> Bool:
  match is_z rest:
    case True{} Con{XJmp{_}, _}: True{}
    case True{} Con{nxt, t}: peep_dead_reg(4n, 0, Con{nxt, t})
    case _ _: False{}
def peep_skip_lbl(xs: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match xs:
    case Con{XLabel{_}, t}: t
    case rest: rest
def peep_dead_at_lbl(fuel: Nat, hit: Bool, +lbl: U32, +r: U32, xs: List<&2, X64Inst>) -> Bool:
  match fuel hit xs:
    case _ True{} _: peep_dead_reg(12n, r, xs)
    case 0n False{} _: False{}
    case _ False{} Nil{}: False{}
    case 1n+p False{} Con{XLabel{id}, t}: peep_dead_at_lbl(p, U32.is_eq(id, lbl), lbl, r, t)
    case 1n+p False{} Con{_, t}: peep_dead_at_lbl(p, False{}, lbl, r, t)
def peep_dead_after_jcc(+d: U32, lbl: U32, +rest: List<&2, X64Inst>) -> Bool: Bool.or(peep_dead_after_fin(U32.is_zero(d), rest), Bool.and(peep_dead_reg(8n, d, peep_skip_lbl(rest)), peep_dead_at_lbl(16n, False{}, lbl, d, rest)))
def peep_fuse_jcc(+cc: U32, jcc: U32) -> U32: Bool.pick(U32, U32.is_eq(jcc, 4), U32.xor(cc, 1), cc)
def peep_is_z_or_nz(+jcc: U32) -> Bool: Bool.or(U32.is_eq(jcc, 4), U32.is_eq(jcc, 5))
def peep_is_alu_fl(+op: U32) -> Bool: Bool.or(U32.is_le(op, 1), Bool.and(U32.is_ge(op, 5), U32.is_le(op, 7)))
def peep_is_zs_cc(+cc: U32) -> Bool: Bool.or(peep_is_z_or_nz(cc), Bool.or(U32.is_eq(cc, 8), U32.is_eq(cc, 9)))
def peep_next_flag_cc(ok_sf: Bool, xs: List<&2, X64Inst>) -> Bool:
  match xs:
    case Con{h, t}:
      +c1 = peep_flag_cc(h)
      +cc = U32.sub(c1, 1)
      peep_and_nflags(Bool.and(U32.is_ne(c1, 0), Bool.pick(Bool, ok_sf, peep_is_zs_cc(cc), peep_is_z_or_nz(cc))), 3n, t)
    case _: False{}
def peep_drop_m32_test(ok: Bool, +inst: X64Inst, +s1: X64Inst, +s2: X64Inst, tst: X64Inst, +t4: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt: Bool.pick(PeepSt, ok, PeepSt{t4, Con{s2, Con{s1, Con{inst, acc}}}}, PeepSt{Con{s1, Con{s2, Con{tst, t4}}}, Con{inst, acc}})
def peep_mov_m32(+r1: U32, +r0: U32, +rd: U32, +rs: U32, +m1: U32, +m2: U32, +r2: U32, +s: U32, ni: X64Inst, oi: X64Inst, +t5: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt:
  c0 = Bool.and(Bool.and(Bool.and(U32.is_eq(rd, r1), U32.is_eq(m1, r1)), Bool.and(U32.is_eq(m2, r1), U32.is_eq(s, r1))), Bool.and(U32.is_eq(r2, r0), Bool.and(U32.is_ne(r2, r1), U32.is_ne(r2, rs))))
  Bool.pick(PeepSt, peep_and_dead(c0, 8n, r1, t5), PeepSt{t5, Con{XShift{9, r2, 32, False{}}, Con{XShift{8, r2, 32, False{}}, Con{ni, acc}}}}, PeepSt{Con{oi, Con{XShift{8, m1, 32, False{}}, Con{XShift{9, m2, 32, False{}}, Con{XMovRR{r2, s}, t5}}}}, Con{XMovRR{r1, r0}, acc}})

# Jump Threading & Branch-to-Return (O(N), Short-Circuiting, Skip If Empty)
type PeepLbls is Data:
  PeepLbls{tbl: RaVec<U32>, any: Bool}
def peep_set_lbl(ok: Bool, id: U32, val: U32, st: PeepLbls) -> PeepLbls:
  match ok st:
    case True{} PeepLbls{t, _}: PeepLbls{ra_vec_set(U32, 8n, id, val, t), True{}}
    case False{} _: st
def peep_build_lbls(insts: List<&2, X64Inst>, st: PeepLbls) -> PeepLbls:
  match insts:
    case Nil{}: st
    case Con{XLabel{+id}, Con{XRet{}, t}}: peep_build_lbls(Con{XRet{}, t}, peep_set_lbl(U32.is_lt(id, 65536), id, 1, st))
    case Con{XLabel{+id}, Con{XJmp{+tgt}, t}}:
      peep_build_lbls(Con{XJmp{tgt}, t}, peep_set_lbl(Bool.and(Bool.and(U32.is_lt(id, 65536), U32.is_lt(tgt, 65536)), U32.is_ne(id, tgt)), id, U32.add(tgt, 2), st))
    case Con{XLabel{+id}, Con{XLabel{+id2}, t}}:
      peep_build_lbls(Con{XLabel{id2}, t}, peep_set_lbl(Bool.and(Bool.and(U32.is_lt(id, 65536), U32.is_lt(id2, 65536)), U32.is_ne(id, id2)), id, U32.add(id2, 2), st))
    case Con{_, t}: peep_build_lbls(t, st)
def peep_res_go(fuel: Nat, done: Bool, val: U32, +tgt: U32, +tbl: RaVec<U32>) -> U32:
  match fuel done:
    case _ True{}: val
    case 0n False{}: U32.add(tgt, 2)
    case 1n+p False{}:
      +ent = Bool.pick(U32, U32.is_lt(tgt, 65536), ra_vec_get(U32, 8n, 0, tgt, tbl), 0)
      +is_z = U32.is_zero(ent)
      +is_r = U32.is_eq(ent, 1)
      peep_res_go(p, Bool.or(is_z, is_r), Bool.pick(U32, is_z, U32.add(tgt, 2), 1), U32.sub(ent, 2), tbl)
def peep_thread_go(insts: List<&2, X64Inst>, +tbl: RaVec<U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match insts:
    case Nil{}: b5k_list_rev(X64Inst, acc)
    case Con{XJmp{tgt}, t}:
      +res = peep_res_go(4n, False{}, 0, tgt, tbl)
      peep_thread_go(t, tbl, Con{Bool.pick(X64Inst, U32.is_eq(res, 1), XRet{}, XJmp{U32.sub(res, 2)}), acc})
    case Con{XJcc{cc, +tgt}, t}:
      +res = peep_res_go(4n, False{}, 0, tgt, tbl)
      peep_thread_go(t, tbl, Con{XJcc{cc, Bool.pick(U32, U32.is_ge(res, 2), U32.sub(res, 2), tgt)}, acc})
    case Con{h, t}: peep_thread_go(t, tbl, Con{h, acc})
def peep_thread_fin(insts: List<&2, X64Inst>, st: PeepLbls) -> List<&2, X64Inst>:
  match st:
    case PeepLbls{_, False{}}: insts
    case PeepLbls{tbl, True{}}: peep_thread_go(insts, tbl, Nil{})
def peep_thread(+insts: List<&2, X64Inst>) -> List<&2, X64Inst>: peep_thread_fin(insts, peep_build_lbls(insts, PeepLbls{RVEmpty{}, False{}}))

# Peephole Rewrite Rules
type PeepSt is Data:
  PeepSt{xs: List<&2, X64Inst>, acc: List<&2, X64Inst>}
def peep_drop_dead(dead: Bool, inst: X64Inst, rest: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt: PeepSt{rest, Bool.pick(List<&2, X64Inst>, dead, acc, Con{inst, acc})}
def peep_zero_mov_go(dead: Bool, +r1: U32, +imm: U32, +rest: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match dead:
    case True{}: PeepSt{rest, acc}
    case False{}: PeepSt{rest, Con{Bool.pick(X64Inst, peep_and_nflags(U32.is_zero(imm), 3n, rest), XAluRR{7, r1, r1}, XMovRI32{r1, imm}), acc}}
def peep_zero_mov(dlim: Nat, +r1: U32, imm: U32, +rest: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt: peep_zero_mov_go(peep_dead_reg(dlim, r1, rest), r1, imm, rest, acc)
def peep_fwd(ok: Bool, new_inst: X64Inst, old1: X64Inst, old2: X64Inst, +t2: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt: Bool.pick(PeepSt, ok, PeepSt{t2, Con{new_inst, acc}}, PeepSt{Con{old2, t2}, Con{old1, acc}})
def peep_mov_fwd(cond: Bool, +r1: U32, r0: U32, ni: X64Inst, oi: X64Inst, +t2: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt: peep_fwd(peep_and_dead(cond, 8n, r1, t2), ni, XMovRR{r1, r0}, oi, t2, acc)
def peep_fwd_alu(c0: Bool, +r1: U32, +r2: U32, +r0: U32, s: U32, +n2: X64Inst, o2: X64Inst, +t3: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt:
  ok = peep_and_dead(c0, 8n, r1, t3)
  hit: PeepSt = PeepSt{t3, Bool.pick(List<&2, X64Inst>, U32.is_eq(r2, r0), Con{n2, acc}, Con{n2, Con{XMovRR{r2, r0}, acc}})}
  Bool.pick(PeepSt, ok, hit, PeepSt{Con{o2, Con{XMovRR{r2, s}, t3}}, Con{XMovRR{r1, r0}, acc}})

def peep_mov_next(+r1: U32, +r0: U32, t1: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt:
  match t1:
    case Con{XAluRI{+op, +rd, +imm}, Con{XMovRR{+r2, +s}, +t3}}: peep_fwd_alu(Bool.and(Bool.and(U32.is_eq(rd, r1), U32.is_eq(s, r1)), U32.is_ne(r2, r1)), r1, r2, r0, s, XAluRI{op, r2, imm}, XAluRI{op, rd, imm}, t3, acc)
    case Con{XAluRR{+op, +rd, +rs}, Con{XShift{8, +m1, 32, False{}}, Con{XShift{9, +m2, 32, False{}}, Con{XMovRR{+r2, +s}, +t5}}}}: peep_mov_m32(r1, r0, rd, rs, m1, m2, r2, s, XAluRR{op, r2, rs}, XAluRR{op, rd, rs}, t5, acc)
    case Con{XMul{+rd, +rs}, Con{XShift{8, +m1, 32, False{}}, Con{XShift{9, +m2, 32, False{}}, Con{XMovRR{+r2, +s}, +t5}}}}: peep_mov_m32(r1, r0, rd, rs, m1, m2, r2, s, XMul{r2, rs}, XMul{rd, rs}, t5, acc)
    case Con{XAluRR{+op, +rd, +rs}, Con{XMovRR{+r2, +s}, +t3}}: peep_fwd_alu(Bool.and(Bool.and(U32.is_eq(rd, r1), U32.is_eq(s, r1)), Bool.and(U32.is_ne(r2, r1), U32.is_ne(r2, rs))), r1, r2, r0, s, XAluRR{op, r2, rs}, XAluRR{op, rd, rs}, t3, acc)
    case Con{XShift{+op, +rd, +amt, False{}}, Con{XMovRR{+r2, +s}, +t3}}: peep_fwd_alu(Bool.and(Bool.and(U32.is_eq(rd, r1), U32.is_eq(s, r1)), U32.is_ne(r2, r1)), r1, r2, r0, s, XShift{op, r2, amt, False{}}, XShift{op, rd, amt, False{}}, t3, acc)
    case Con{XStore{+b, +d, +s}, +t2}: peep_mov_fwd(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, b)), r1, r0, XStore{b, d, r0}, XStore{b, d, s}, t2, acc)
    case Con{XMovRR{+r2, +s}, +t2}:
      +is_back = Bool.and(U32.is_eq(r2, r0), U32.is_eq(s, r1))
      ok = Bool.or(is_back, peep_and_dead(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, r2)), 8n, r1, t2))
      peep_fwd(ok, Bool.pick(X64Inst, is_back, XMovRR{r1, r0}, XMovRR{r2, r0}), XMovRR{r1, r0}, XMovRR{r2, s}, t2, acc)
    case Con{XAluRR{+op, +dst, +s}, +t2}: peep_mov_fwd(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, dst)), r1, r0, XAluRR{op, dst, r0}, XAluRR{op, dst, s}, t2, acc)
    case Con{XCmpRR{+a, +b}, +t2}:
      +mb = Bool.and(U32.is_eq(r1, b), U32.is_ne(r1, a))
      peep_mov_fwd(Bool.or(mb, Bool.and(U32.is_eq(r1, a), U32.is_ne(r1, b))), r1, r0, Bool.pick(X64Inst, mb, XCmpRR{a, r0}, XCmpRR{r0, b}), XCmpRR{a, b}, t2, acc)
    case Con{XMul{+dst, +s}, +t2}: peep_mov_fwd(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, dst)), r1, r0, XMul{dst, r0}, XMul{dst, s}, t2, acc)
    case Con{XPush{+s}, +t2}: peep_mov_fwd(U32.is_eq(r1, s), r1, r0, XPush{r0}, XPush{s}, t2, acc)
    case Con{XTestRR{+a, +b}, +t2}: peep_mov_fwd(Bool.and(U32.is_eq(r1, a), U32.is_eq(r1, b)), r1, r0, XTestRR{r0, r0}, XTestRR{a, b}, t2, acc)
    case Con{XCmpRI{+a, +imm}, +t2}: peep_mov_fwd(U32.is_eq(r1, a), r1, r0, XCmpRI{r0, imm}, XCmpRI{a, imm}, t2, acc)
    case Con{XLoad{+d, +b, +disp}, +t2}: peep_mov_fwd(U32.is_eq(r1, b), r1, r0, XLoad{d, r0, disp}, XLoad{d, b, disp}, t2, acc)
    case Con{XCvt{+op, +d, +s}, +t2}: peep_mov_fwd(Bool.and(Bool.or(U32.is_eq(op, 0), U32.is_eq(op, 2)), U32.is_eq(r1, s)), r1, r0, XCvt{op, d, r0}, XCvt{op, d, s}, t2, acc)
    case Con{XCmov{+cc, +dst, +s}, +t2}: peep_mov_fwd(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, dst)), r1, r0, XCmov{cc, dst, r0}, XCmov{cc, dst, s}, t2, acc)
    case +rest: peep_drop_dead(peep_dead_reg(8n, r1, rest), XMovRR{r1, r0}, rest, acc)
def peep_mov_step(same: Bool, r1: U32, r0: U32, t1: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match same:
    case True{}: PeepSt{t1, acc}
    case False{}: peep_mov_next(r1, r0, t1, acc)

def peep_drop_ri_test(ok: Bool, za: Bool, op: U32, d: U32, imm: U32, +tst: X64Inst, +t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t2, Con{XAluRI{op, d, imm}, acc}}
    case False{}: peep_drop_dead(peep_and_nflags(za, 3n, Con{tst, t2}), XAluRI{op, d, imm}, Con{tst, t2}, acc)
def peep_sl_tail(ok: Bool, same_r: Bool, mv: X64Inst, ld: X64Inst, t2: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ok same_r:
    case True{} True{}: t2
    case True{} False{}: Con{mv, t2}
    case False{} _: Con{ld, t2}
def peep_r6(ok: Bool, +cmp: X64Inst, cc: U32, jcc: U32, lbl: U32, rest_ok: List<&2, X64Inst>, rest_fail: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt: Bool.pick(PeepSt, ok, PeepSt{rest_ok, Con{XJcc{peep_fuse_jcc(cc, jcc), lbl}, Con{cmp, acc}}}, PeepSt{rest_fail, Con{cmp, acc}})
def peep_try_r6a(cmp: X64Inst, +z1: U32, +zi: U32, +cc: U32, +d: U32, +tst: X64Inst, +jcc: U32, +lbl: U32, +t5: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  ok = Bool.and(Bool.and(U32.is_eq(z1, d), U32.is_zero(zi)), Bool.and(Bool.and(peep_is_ztest(d, tst), peep_is_z_or_nz(jcc)), peep_dead_after_jcc(d, lbl, t5)))
  peep_r6(ok, cmp, cc, jcc, lbl, t5, Con{XMovRI32{z1, zi}, Con{XSetcc{cc, d}, Con{tst, Con{XJcc{jcc, lbl}, t5}}}}, acc)
def peep_cmp_zset(extra: Bool, +cmp: X64Inst, +z1: U32, +zi: U32, +cc: U32, +d: U32, +t3: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt:
  ok = Bool.and(Bool.and(U32.is_eq(z1, d), U32.is_zero(zi)), extra)
  Bool.pick(PeepSt, ok, PeepSt{Con{XSetcc{cc, d}, t3}, Con{cmp, Con{XAluRR{7, d, d}, acc}}}, PeepSt{Con{XMovRI32{z1, zi}, Con{XSetcc{cc, d}, t3}}, Con{cmp, acc}})
def peep_cmp0(ok: Bool, +r: U32, imm: U32, nxt: X64Inst, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt: PeepSt{Con{nxt, t2}, Con{Bool.pick(X64Inst, ok, XTestRR{r, r}, XCmpRI{r, imm}), acc}}
def peep_imm_fwd(dlim: Nat, ok: Bool, new_inst: X64Inst, r1: U32, imm: U32, old2: X64Inst, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t2, Con{new_inst, acc}}
    case False{}: peep_zero_mov(dlim, r1, imm, Con{old2, t2}, acc)

def peep_xmm_fwd(cond: Bool, +x1: U32, o1: X64Inst, ni: X64Inst, oi: X64Inst, +t2: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt: peep_fwd(peep_and_dead_k(True{}, cond, 8n, x1, t2), ni, o1, oi, t2, acc)
def peep_xmm_mov_next(+x1: U32, +x0: U32, t1: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt:
  match t1:
    case Con{XXmmRR{+op, +dst, +s}, +t2}: peep_xmm_fwd(Bool.and(U32.is_eq(x1, s), U32.is_ne(x1, dst)), x1, XXmmRR{7, x1, x0}, XXmmRR{op, dst, x0}, XXmmRR{op, dst, s}, t2, acc)
    case Con{XXmmStore{+b, +d, +s}, +t2}: peep_xmm_fwd(U32.is_eq(x1, U32.and(s, 15)), x1, XXmmRR{7, x1, x0}, XXmmStore{b, d, U32.or(U32.and(s, 48), x0)}, XXmmStore{b, d, s}, t2, acc)
    case Con{XCvt{+op, +dst, +s}, +t2}: peep_xmm_fwd(Bool.and(Bool.or(U32.is_eq(op, 1), U32.is_eq(op, 3)), U32.is_eq(x1, s)), x1, XXmmRR{7, x1, x0}, XCvt{op, dst, x0}, XCvt{op, dst, s}, t2, acc)
    case rest: PeepSt{rest, Con{XXmmRR{7, x1, x0}, acc}}
def peep_xmm_mov_step(same: Bool, x1: U32, x0: U32, t1: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match same:
    case True{}: PeepSt{t1, acc}
    case False{}: peep_xmm_mov_next(x1, x0, t1, acc)
def peep_next_u32_cc(xs: List<&2, X64Inst>) -> Bool:
  match xs:
    case Con{h, _}:
      +c1 = peep_flag_cc(h)
      Bool.and(U32.is_ge(c1, 5), U32.is_le(c1, 8))
    case _: False{}
def peep_drop_mask(ok: Bool, keep: X64Inst, s1: X64Inst, s2: X64Inst, +t3: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt: PeepSt{Bool.pick(List<&2, X64Inst>, ok, t3, Con{s1, Con{s2, t3}}), Con{keep, acc}}
def peep_drop_pre_mask(ok: Bool, s1: X64Inst, s2: X64Inst, keep: X64Inst, t3: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt:
  +kt: List<&2, X64Inst> = Con{keep, t3}
  Bool.pick(PeepSt, ok, PeepSt{kt, acc}, PeepSt{Con{s2, kt}, Con{s1, acc}})
def peep_inc_lbl(ok: Bool, +id: U32, +cnt: RaVec<U32>) -> RaVec<U32>:
  match ok:
    case False{}: cnt
    case True{}: ra_vec_set(U32, 8n, id, U32.add(ra_vec_get(U32, 8n, 0, id, cnt), 1), cnt)
def peep_count_lbls(insts: List<&2, X64Inst>, cnt: RaVec<U32>) -> RaVec<U32>:
  match insts:
    case Nil{}: cnt
    case Con{XJmp{+tgt}, t}: peep_count_lbls(t, peep_inc_lbl(U32.is_lt(tgt, 65536), tgt, cnt))
    case Con{XJcc{_, +tgt}, t}: peep_count_lbls(t, peep_inc_lbl(U32.is_lt(tgt, 65536), tgt, cnt))
    case Con{_, t}: peep_count_lbls(t, cnt)
def peep_lbl_once(+id: U32, lcnt: RaVec<U32>) -> Bool: Bool.and(U32.is_lt(id, 65536), U32.is_eq(ra_vec_get(U32, 8n, 0, id, lcnt), 1))
def peep_lbl_zero(+id: U32, lcnt: RaVec<U32>) -> Bool: Bool.and(U32.is_lt(id, 65536), U32.is_zero(ra_vec_get(U32, 8n, 0, id, lcnt)))
def peep_cmov_rr_emit(eq1: Bool, eq2: Bool, cc: U32, +d: U32, s1: U32, s2: U32, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match eq1 eq2:
    case True{} _: Con{XCmov{cc, d, s2}, acc}
    case False{} True{}: Con{XCmov{U32.xor(cc, 1), d, s1}, acc}
    case False{} False{}: Con{XCmov{cc, d, s2}, Con{XMovRR{d, s1}, acc}}
def peep_or_jcc(ok: Bool, cc: U32, l1: U32, orig_t: List<&2, X64Inst>, acc: List<&2, X64Inst>, hit: PeepSt) -> PeepSt: Bool.pick(PeepSt, ok, hit, PeepSt{orig_t, Con{XJcc{cc, l1}, acc}})
def peep_cmov_dia(extra: Bool, lcnt: RaVec<U32>, cc: U32, +l1: U32, l1b: U32, l2: U32, +l2b: U32, d1: U32, d2: U32, t6: List<&2, X64Inst>, orig_t: List<&2, X64Inst>, acc: List<&2, X64Inst>, ins: List<&2, X64Inst>) -> PeepSt:
  ok = Bool.and(extra, Bool.and(Bool.and(U32.is_eq(l1, l1b), U32.is_eq(l2, l2b)), Bool.and(U32.is_eq(d1, d2), peep_lbl_once(l1, lcnt))))
  peep_or_jcc(ok, cc, l1, orig_t, acc, PeepSt{Con{XLabel{l2b}, t6}, ins})
def peep_jcc_cmov(lcnt: RaVec<U32>, +cc: U32, +l1: U32, body: List<&2, X64Inst>, orig_t: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt:
  match body:
    case Con{XMovRR{+d1, +s1}, Con{XJmp{+l2}, Con{XLabel{+l1b}, Con{XMovRR{+d2, +s2}, Con{XLabel{+l2b}, t6}}}}}: peep_cmov_dia(True{}, lcnt, cc, l1, l1b, l2, l2b, d1, d2, t6, orig_t, acc, peep_cmov_rr_emit(U32.is_eq(d1, s1), U32.is_eq(d1, s2), cc, d1, s1, s2, acc))
    case Con{XLoad{+d1, +b1, +disp}, Con{XJmp{+l2}, Con{XLabel{+l1b}, Con{XMovRR{+d2, +s2}, Con{XLabel{+l2b}, t6}}}}}: peep_cmov_dia(Bool.and(U32.is_eq(b1, 5), Bool.and(U32.is_ne(d1, 5), U32.is_ne(d1, s2))), lcnt, cc, l1, l1b, l2, l2b, d1, d2, t6, orig_t, acc, Con{XCmov{cc, d1, s2}, Con{XLoad{d1, b1, disp}, acc}})
    case Con{XMovRR{+d1, +s1}, Con{XJmp{+l2}, Con{XLabel{+l1b}, Con{XLoad{+d2, +b2, +disp}, Con{XLabel{+l2b}, t6}}}}}: peep_cmov_dia(Bool.and(U32.is_eq(b2, 5), Bool.and(U32.is_ne(d1, 5), U32.is_ne(d1, s1))), lcnt, cc, l1, l1b, l2, l2b, d1, d2, t6, orig_t, acc, Con{XCmov{U32.xor(cc, 1), d1, s1}, Con{XLoad{d2, b2, disp}, acc}})
    case Con{XMovRI32{+d1, +imm}, Con{XJmp{+l2}, Con{XLabel{+l1b}, Con{XMovRR{+d2, +s2}, Con{XLabel{+l2b}, t6}}}}}: peep_cmov_dia(U32.is_ne(d1, s2), lcnt, cc, l1, l1b, l2, l2b, d1, d2, t6, orig_t, acc, Con{XCmov{cc, d1, s2}, Con{XMovRI32{d1, imm}, acc}})
    case Con{XMovRR{+d1, +s1}, Con{XJmp{+l2}, Con{XLabel{+l1b}, Con{XMovRI32{+d2, +imm}, Con{XLabel{+l2b}, t6}}}}}: peep_cmov_dia(U32.is_ne(d1, s1), lcnt, cc, l1, l1b, l2, l2b, d1, d2, t6, orig_t, acc, Con{XCmov{U32.xor(cc, 1), d1, s1}, Con{XMovRI32{d2, imm}, acc}})
    case Con{XMovRR{+d1, +s1}, Con{XRet{}, Con{XLabel{+l1b}, Con{XMovRR{+d2, +s2}, Con{XRet{}, t6}}}}}:
      ok = Bool.and(Bool.and(U32.is_eq(l1, l1b), U32.is_eq(d1, d2)), Bool.and(Bool.and(U32.is_ne(d1, s1), U32.is_ne(d1, s2)), peep_lbl_once(l1, lcnt)))
      peep_or_jcc(ok, cc, l1, orig_t, acc, PeepSt{t6, Con{XRet{}, Con{XCmov{cc, d1, s2}, Con{XMovRR{d1, s1}, acc}}}})
    case Con{XMovRR{d, s}, Con{XLabel{+l1b}, t3}}: peep_or_jcc(U32.is_eq(l1, l1b), cc, l1, orig_t, acc, PeepSt{Con{XLabel{l1b}, t3}, Con{XCmov{U32.xor(cc, 1), d, s}, acc}})
    case _: PeepSt{orig_t, Con{XJcc{cc, l1}, acc}}
def peep_jcc_try_lbl(is_z: Bool, lcnt: RaVec<U32>, cc: U32, l1: U32, t2: List<&2, X64Inst>, orig_t: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match is_z:
    case True{}: peep_jcc_cmov(lcnt, cc, l1, t2, orig_t, acc)
    case False{}: PeepSt{orig_t, Con{XJcc{cc, l1}, acc}}
def peep_jcc_lbl(same: Bool, use_cmov: Bool, +lcnt: RaVec<U32>, cc: U32, l1: U32, +lbl2: U32, +t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match same use_cmov:
    case True{} _: PeepSt{Con{XLabel{lbl2}, t2}, acc}
    case False{} False{}: PeepSt{Con{XLabel{lbl2}, t2}, Con{XJcc{cc, l1}, acc}}
    case False{} True{}: peep_jcc_try_lbl(peep_lbl_zero(lbl2, lcnt), lcnt, cc, l1, t2, Con{XLabel{lbl2}, t2}, acc)
def peep_jcc_step(use_cmov: Bool, lcnt: RaVec<U32>, +cc: U32, +l1: U32, t: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt:
  match use_cmov t:
    case _ Con{XJmp{+lbl2}, Con{XLabel{+lbl3}, +t3}}:
      Bool.pick(PeepSt, U32.is_eq(l1, lbl3), PeepSt{Con{XLabel{lbl3}, t3}, Con{XJcc{U32.xor(cc, 1), lbl2}, acc}}, PeepSt{Con{XJmp{lbl2}, Con{XLabel{lbl3}, t3}}, Con{XJcc{cc, l1}, acc}})
    case _ Con{XLabel{+lbl2}, t2}: peep_jcc_lbl(U32.is_eq(l1, lbl2), use_cmov, lcnt, cc, l1, lbl2, t2, acc)
    case True{} +orig_t: peep_jcc_cmov(lcnt, cc, l1, orig_t, orig_t, acc)
    case False{} orig_t: PeepSt{orig_t, Con{XJcc{cc, l1}, acc}}

def peep_st_fwd2(+b1: U32, +d1: U32, +r1: U32, t: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match t:
    case Con{XMovRR{+md, +ms}, Con{XLoad{+r2, +b2, +d2}, +t3}}:
      ok = Bool.and(Bool.and(U32.is_eq(b1, 5), Bool.and(U32.is_eq(b2, 5), U32.is_eq(d1, d2))), Bool.and(U32.is_eq(md, r1), Bool.and(U32.is_ne(r2, r1), Bool.and(U32.is_ne(r2, ms), U32.is_ne(r2, 5)))))
      PeepSt{Bool.pick(List<&2, X64Inst>, ok, Con{XMovRR{r2, r1}, Con{XMovRR{md, ms}, t3}}, Con{XMovRR{md, ms}, Con{XLoad{r2, b2, d2}, t3}}), Con{XStore{b1, d1, r1}, acc}}
    case Con{+m1, Con{XLoad{+r2, +b2, +d2}, t2}}:
      ok = Bool.and(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)), peep_no_alias(m1, b1, d1, r1))
      PeepSt{Con{m1, peep_sl_tail(ok, U32.is_eq(r1, r2), XMovRR{r2, r1}, XLoad{r2, b2, d2}, t2)}, Con{XStore{b1, d1, r1}, acc}}
    case Con{+m1, Con{+m2, Con{XLoad{+r2, +b2, +d2}, t2}}}:
      ok = Bool.and(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)), Bool.and(peep_no_alias(m1, b1, d1, r1), peep_no_alias(m2, b1, d1, r1)))
      PeepSt{Con{m1, Con{m2, peep_sl_tail(ok, U32.is_eq(r1, r2), XMovRR{r2, r1}, XLoad{r2, b2, d2}, t2)}}, Con{XStore{b1, d1, r1}, acc}}
    case rest: PeepSt{rest, Con{XStore{b1, d1, r1}, acc}}
def peep_st_st(same: Bool, b1: U32, d1: U32, r1: U32, st2: X64Inst, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match same:
    case True{}: PeepSt{Con{st2, t2}, acc}
    case False{}: peep_st_fwd2(b1, d1, r1, Con{st2, t2}, acc)
def peep_st_ld(same: Bool, +b1: U32, +d1: U32, +r1: U32, +r2: U32, b2: U32, d2: U32, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match same:
    case True{}: PeepSt{peep_sl_tail(True{}, U32.is_eq(r1, r2), XMovRR{r2, r1}, XLoad{r2, b2, d2}, t2), Con{XStore{b1, d1, r1}, acc}}
    case False{}: peep_st_fwd2(b1, d1, r1, Con{XLoad{r2, b2, d2}, t2}, acc)
def peep_st_fwd(+b1: U32, +d1: U32, +r1: U32, t: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match t:
    case Con{XStore{+b2, +d2, r2}, t2}: peep_st_st(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)), b1, d1, r1, XStore{b2, d2, r2}, t2, acc)
    case Con{XLoad{+r2, +b2, +d2}, t2}: peep_st_ld(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)), b1, d1, r1, r2, b2, d2, t2, acc)
    case rest: peep_st_fwd2(b1, d1, r1, rest, acc)

def peep_xmm_fwd3(n1: X64Inst, o1: X64Inst, +x0: U32, +op: U32, +xd: U32, +xs: U32, +x2: U32, +s: U32, +t3: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt:
  c0 = Bool.and(Bool.and(Bool.or(U32.is_lt(op, 4), Bool.and(U32.is_ge(op, 8), U32.is_le(op, 11))), U32.is_eq(xd, x0)), Bool.and(U32.is_eq(s, x0), U32.is_ne(x2, x0)))
  ok = peep_and_dead_k(True{}, Bool.and(c0, Bool.or(U32.is_eq(xs, x0), U32.is_ne(x2, xs))), 8n, x0, t3)
  Bool.pick(PeepSt, ok, PeepSt{t3, Con{XXmmRR{op, x2, Bool.pick(U32, U32.is_eq(xs, x0), x2, xs)}, Con{n1, acc}}}, PeepSt{Con{XXmmRR{op, xd, xs}, Con{XXmmRR{7, x2, s}, t3}}, Con{o1, acc}})
def peep_step(dlim: Nat, use_cmov: Bool, lcnt: RaVec<U32>, h: X64Inst, t: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> PeepSt:
  match h t:
    case XMovRR{+r1, +r0} t1: peep_mov_step(U32.is_eq(r1, r0), r1, r0, t1, acc)
    case XXmmRR{7, +x0, +xa} Con{XXmmRR{+op, +xd, +xs}, Con{XXmmRR{7, +x2, +s}, +t3}}: peep_xmm_fwd3(XXmmRR{7, x2, xa}, XXmmRR{7, x0, xa}, x0, op, xd, xs, x2, s, t3, acc)
    case XXmmRR{7, +x1, +x0} t1: peep_xmm_mov_step(U32.is_eq(x1, x0), x1, x0, t1, acc)
    case XXmmRR{4, +x0, +x1} Con{XXmmRR{7, +x2, +s}, +t2}: peep_xmm_fwd(Bool.and(U32.is_eq(x0, s), U32.is_ne(x0, x2)), x0, XXmmRR{4, x0, x1}, XXmmRR{4, x2, x1}, XXmmRR{7, x2, s}, t2, acc)
    case XXmmRR{12, +x0, +x1} Con{XXmmRR{7, +x2, +s}, +t2}: peep_xmm_fwd(Bool.and(U32.is_eq(x0, s), U32.is_ne(x0, x2)), x0, XXmmRR{12, x0, x1}, XXmmRR{12, x2, x1}, XXmmRR{7, x2, s}, t2, acc)
    case XXmmLoad{+x0, +b, +d} Con{XXmmRR{+op, +xd, +xs}, Con{XXmmRR{7, +x2, +s}, +t3}}: peep_xmm_fwd3(XXmmLoad{U32.or(U32.and(x0, 16), x2), b, d}, XXmmLoad{x0, b, d}, U32.and(x0, 15), op, xd, xs, x2, s, t3, acc)
    case XXmmLoad{+x1, +b1, +d1} Con{XXmmLoad{+x2, +b2, +d2}, t2}: PeepSt{peep_sl_tail(Bool.and(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)), U32.is_eq(U32.and(x1, 16), U32.and(x2, 16))), U32.is_eq(U32.and(x1, 15), U32.and(x2, 15)), XXmmRR{7, U32.and(x2, 15), U32.and(x1, 15)}, XXmmLoad{x2, b2, d2}, t2), Con{XXmmLoad{x1, b1, d1}, acc}}
    case XXmmLoad{+x0, +b, +d} Con{XXmmRR{7, +x2, +s}, +t2}: peep_xmm_fwd(Bool.and(U32.is_eq(U32.and(x0, 15), s), U32.is_ne(U32.and(x0, 15), x2)), U32.and(x0, 15), XXmmLoad{x0, b, d}, XXmmLoad{U32.or(U32.and(x0, 16), x2), b, d}, XXmmRR{7, x2, s}, t2, acc)
    case XCvt{+op, +x0, +g} Con{XXmmRR{7, +x2, +s}, +t2}: peep_xmm_fwd(Bool.and(Bool.or(U32.is_eq(op, 0), U32.is_eq(op, 2)), Bool.and(U32.is_eq(x0, s), U32.is_ne(x0, x2))), x0, XCvt{op, x0, g}, XCvt{op, x2, g}, XXmmRR{7, x2, s}, t2, acc)
    case XCvt{2, +x0, g} +t1: peep_drop_dead(peep_dead_go(True{}, dlim, 0, x0, t1), XCvt{2, x0, g}, t1, acc)
    case XXmmStore{+b1, +d1, +x1} Con{XXmmLoad{+x2, +b2, +d2}, t2}: PeepSt{peep_sl_tail(Bool.and(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)), U32.is_eq(U32.shrn(x1, 4n), U32.shrn(x2, 4n))), U32.is_eq(U32.and(x1, 15), U32.and(x2, 15)), XXmmRR{7, U32.and(x2, 15), U32.and(x1, 15)}, XXmmLoad{x2, b2, d2}, t2), Con{XXmmStore{b1, d1, x1}, acc}}
    case XAluRI{5, +d, +imm} Con{XShift{8, +r2, 32, False{}}, Con{XShift{9, +r3, 32, False{}}, +t3}}: peep_drop_mask(peep_and_nflags(Bool.and(Bool.and(U32.is_eq(d, r2), U32.is_eq(d, r3)), U32.is_lt(imm, 2147483648)), 3n, t3), XAluRI{5, d, imm}, XShift{8, r2, 32, False{}}, XShift{9, r3, 32, False{}}, t3, acc)
    case XAluRI{+op, +d, +imm} Con{XShift{8, +r2, 32, False{}}, Con{XShift{9, +r3, 32, False{}}, Con{XTestRR{+a, +b}, +t4}}}:
      ok = Bool.and(Bool.and(peep_is_alu_fl(op), Bool.not(peep_is_zero_alu(op, imm))), Bool.and(Bool.and(Bool.and(U32.is_eq(r2, d), U32.is_eq(r3, d)), Bool.and(U32.is_eq(a, d), U32.is_eq(b, d))), peep_next_flag_cc(False{}, t4)))
      peep_drop_m32_test(ok, XAluRI{op, d, imm}, XShift{8, r2, 32, False{}}, XShift{9, r3, 32, False{}}, XTestRR{a, b}, t4, acc)
    case XAluRI{+op, +d, +imm} Con{XTestRR{+a, +b}, +t2}:
      +za = peep_is_zero_alu(op, imm)
      ok = Bool.and(Bool.and(peep_is_alu_fl(op), Bool.not(za)), Bool.and(Bool.and(U32.is_eq(a, d), U32.is_eq(b, d)), peep_next_flag_cc(True{}, t2)))
      peep_drop_ri_test(ok, za, op, d, imm, XTestRR{a, b}, t2, acc)
    case XShift{9, +d, +amt, False{}} Con{XShift{8, +r2, 32, False{}}, Con{XShift{9, +r3, 32, False{}}, +t3}}: peep_drop_mask(peep_and_nflags(Bool.and(Bool.and(U32.is_eq(d, r2), U32.is_eq(d, r3)), U32.is_ge(amt, 32)), 3n, t3), XShift{9, d, amt, False{}}, XShift{8, r2, 32, False{}}, XShift{9, r3, 32, False{}}, t3, acc)
    case XShift{8, +r1, 32, False{}} Con{XShift{9, +r2, 32, False{}}, Con{XAluRI{5, +r3, +imm}, +t3}}: peep_drop_pre_mask(Bool.and(Bool.and(U32.is_eq(r1, r2), U32.is_eq(r1, r3)), U32.is_lt(imm, 2147483648)), XShift{8, r1, 32, False{}}, XShift{9, r2, 32, False{}}, XAluRI{5, r3, imm}, t3, acc)
    case XShift{8, +r1, 32, False{}} Con{XShift{9, +r2, 32, False{}}, Con{XMovRI32{+mr, +mi}, Con{XAluRI{5, +r3, +imm}, +t4}}}: peep_drop_pre_mask(Bool.and(Bool.and(U32.is_eq(r1, r2), U32.is_eq(r1, r3)), Bool.and(U32.is_ne(mr, r1), U32.is_lt(imm, 2147483648))), XShift{8, r1, 32, False{}}, XShift{9, r2, 32, False{}}, XMovRI32{mr, mi}, Con{XAluRI{5, r3, imm}, t4}, acc)
    case XAluRI{+op, d, +imm} +t1: peep_drop_dead(peep_and_nflags(peep_is_zero_alu(op, imm), 3n, t1), XAluRI{op, d, imm}, t1, acc)
    case XStore{b1, d1, r1} rest: peep_st_fwd(b1, d1, r1, rest, acc)
    case XLoad{+r1, +b1, +d1} Con{XLoad{+r2, +b2, +d2}, t2}: PeepSt{peep_sl_tail(Bool.and(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)), U32.is_ne(r1, b1)), U32.is_eq(r1, r2), XMovRR{r2, r1}, XLoad{r2, b2, d2}, t2), Con{XLoad{r1, b1, d1}, acc}}
    case XLoad{+r1, +b, +d} Con{XMovRR{+r2, +s}, +t2}: peep_fwd(peep_and_dead(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, r2)), 4n, r1, t2), XLoad{r2, b, d}, XLoad{r1, b, d}, XMovRR{r2, s}, t2, acc)
    case XLoad{+r1, +b1, +d1} Con{+m1, Con{XLoad{+r2, +b2, +d2}, t2}}:
      ok = Bool.and(Bool.and(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)), U32.is_ne(r1, b1)), peep_no_alias(m1, b1, d1, r1))
      PeepSt{Con{m1, peep_sl_tail(ok, U32.is_eq(r1, r2), XMovRR{r2, r1}, XLoad{r2, b2, d2}, t2)}, Con{XLoad{r1, b1, d1}, acc}}
    case XJmp{+lbl1} Con{XLabel{+lbl2}, t2}: peep_drop_dead(U32.is_eq(lbl1, lbl2), XJmp{lbl1}, Con{XLabel{lbl2}, t2}, acc)
    case XLabel{+id} rest: peep_drop_dead(Bool.and(use_cmov, peep_lbl_zero(id, lcnt)), XLabel{id}, rest, acc)
    case XJcc{cc, l1} rest: peep_jcc_step(use_cmov, lcnt, cc, l1, rest, acc)
    case XCmpRR{a, b} Con{XMovRI32{z1, zi}, Con{XSetcc{cc, d}, Con{tst, Con{XJcc{jcc, lbl}, t5}}}}: peep_try_r6a(XCmpRR{a, b}, z1, zi, cc, d, tst, jcc, lbl, t5, acc)
    case XTestRR{a, b} Con{XMovRI32{z1, zi}, Con{XSetcc{cc, d}, Con{tst, Con{XJcc{jcc, lbl}, t5}}}}: peep_try_r6a(XTestRR{a, b}, z1, zi, cc, d, tst, jcc, lbl, t5, acc)
    case XCmpRI{a, imm} Con{XMovRI32{z1, zi}, Con{XSetcc{cc, d}, Con{tst, Con{XJcc{jcc, lbl}, t5}}}}: peep_try_r6a(XCmpRI{a, imm}, z1, zi, cc, d, tst, jcc, lbl, t5, acc)
    case XCmpRR{a, b} Con{XSetcc{+cc, +d}, Con{+tst, Con{XJcc{+jcc, +lbl}, +t4}}}:
      ok = Bool.and(Bool.and(peep_is_ztest(d, tst), peep_is_z_or_nz(jcc)), peep_dead_after_jcc(d, lbl, t4))
      peep_r6(ok, XCmpRR{a, b}, cc, jcc, lbl, t4, Con{XSetcc{cc, d}, Con{tst, Con{XJcc{jcc, lbl}, t4}}}, acc)
    case XCmpRR{+a, +b} Con{XMovRI32{+z1, +zi}, Con{XSetcc{+cc, +d}, t3}}: peep_cmp_zset(Bool.and(U32.is_ne(d, a), U32.is_ne(d, b)), XCmpRR{a, b}, z1, zi, cc, d, t3, acc)
    case XCmpRI{+a, imm} Con{XMovRI32{+z1, +zi}, Con{XSetcc{+cc, +d}, t3}}: peep_cmp_zset(U32.is_ne(d, a), XCmpRI{a, imm}, z1, zi, cc, d, t3, acc)
    case XTestRR{+a, +b} Con{XMovRI32{+z1, +zi}, Con{XSetcc{+cc, +d}, t3}}: peep_cmp_zset(Bool.and(U32.is_ne(d, a), U32.is_ne(d, b)), XTestRR{a, b}, z1, zi, cc, d, t3, acc)
    case XCmpRI{r, +imm} Con{XJcc{+cc, lbl}, t2}: peep_cmp0(Bool.and(U32.is_zero(imm), peep_is_z_or_nz(cc)), r, imm, XJcc{cc, lbl}, t2, acc)
    case XCmpRI{r, +imm} Con{XSetcc{+cc, d}, t2}: peep_cmp0(Bool.and(U32.is_zero(imm), peep_is_z_or_nz(cc)), r, imm, XSetcc{cc, d}, t2, acc)
    case XMovRI32{+r1, +imm} Con{XShift{8, +r2, 32, False{}}, Con{XShift{9, +r3, 32, False{}}, +t3}}: peep_drop_mask(peep_and_nflags(Bool.and(U32.is_eq(r1, r2), U32.is_eq(r1, r3)), 3n, t3), XMovRI32{r1, imm}, XShift{8, r2, 32, False{}}, XShift{9, r3, 32, False{}}, t3, acc)
    case XMovRI32{+r1, +imm} Con{XMovRR{+r2, +s}, +t2}: peep_imm_fwd(dlim, peep_and_dead(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, r2)), 4n, r1, t2), XMovRI32{r2, imm}, r1, imm, XMovRR{r2, s}, t2, acc)
    case XMovRI32{+r1, +imm} Con{XAluRR{+op, +dst, +s}, +t2}: peep_imm_fwd(dlim, peep_and_dead(Bool.and(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, dst)), U32.is_lt(imm, 2147483648)), 5n, r1, t2), XAluRI{op, dst, imm}, r1, imm, XAluRR{op, dst, s}, t2, acc)
    case XMovRI32{+r1, +imm} Con{XCmpRR{+a, +b}, +t2}: peep_imm_fwd(dlim, peep_and_dead(Bool.and(Bool.and(U32.is_zero(imm), Bool.and(U32.is_eq(r1, b), U32.is_ne(r1, a))), peep_next_u32_cc(t2)), 5n, r1, t2), XTestRR{a, a}, r1, imm, XCmpRR{a, b}, t2, acc)
    case XMovRI32{r1, imm} t1: peep_zero_mov(dlim, r1, imm, t1, acc)
    case XMovRI64{+r1, lo, hi} +t1: peep_drop_dead(peep_dead_reg(dlim, r1, t1), XMovRI64{r1, lo, hi}, t1, acc)
    case XAddRsp{+a} Con{XAddRsp{+b}, +t2}: peep_fwd(peep_and_nflags(True{}, 3n, t2), XAddRsp{U32.add(a, b)}, XAddRsp{a}, XAddRsp{b}, t2, acc)
    case XSubRsp{+a} Con{XSubRsp{+b}, +t2}: peep_fwd(peep_and_nflags(True{}, 3n, t2), XSubRsp{U32.add(a, b)}, XSubRsp{a}, XSubRsp{b}, t2, acc)
    case XAddRsp{+a} +t1: peep_drop_dead(peep_and_nflags(U32.is_zero(a), 3n, t1), XAddRsp{a}, t1, acc)
    case XSubRsp{+a} +t1: peep_drop_dead(peep_and_nflags(U32.is_zero(a), 3n, t1), XSubRsp{a}, t1, acc)
    case XAluRR{7, +r1, +r2} +t1: peep_drop_dead(peep_and_nflags(peep_and_dead(U32.is_eq(r1, r2), dlim, r1, t1), 3n, t1), XAluRR{7, r1, r2}, t1, acc)
    case XAluRR{+op, +d, +s} Con{XShift{8, +r2, 32, False{}}, Con{XShift{9, +r3, 32, False{}}, Con{XTestRR{+a, +b}, +t4}}}:
      ok = Bool.and(peep_is_alu_fl(op), Bool.and(Bool.and(Bool.and(U32.is_eq(r2, d), U32.is_eq(r3, d)), Bool.and(U32.is_eq(a, d), U32.is_eq(b, d))), peep_next_flag_cc(False{}, t4)))
      peep_drop_m32_test(ok, XAluRR{op, d, s}, XShift{8, r2, 32, False{}}, XShift{9, r3, 32, False{}}, XTestRR{a, b}, t4, acc)
    case XAluRR{+op, +d, +s} Con{XTestRR{+a, +b}, +t2}: peep_fwd(Bool.and(peep_is_alu_fl(op), Bool.and(Bool.and(U32.is_eq(a, d), U32.is_eq(b, d)), peep_next_flag_cc(True{}, t2))), XAluRR{op, d, s}, XAluRR{op, d, s}, XTestRR{a, b}, t2, acc)
    case inst rest: PeepSt{rest, Con{inst, acc}}

def peep_rbp_key(+d: U32) -> U32:
  +k = U32.shrn(U32.sub(0, d), 3n)
  Bool.pick(U32, Bool.and(U32.is_ge(d, 2147483648), Bool.and(U32.is_zero(U32.and(d, 7)), Bool.and(U32.is_gt(k, 0), U32.is_lt(k, 512)))), k, 0)
def peep_inc_rbp(d: U32, +cnt: RaVec<U32>) -> RaVec<U32>:
  +k = peep_rbp_key(d)
  Bool.pick(RaVec<U32>, U32.is_zero(k), cnt, ra_vec_set(U32, 5n, k, U32.add(ra_vec_get(U32, 5n, 0, k, cnt), 1), cnt))
def peep_count_rbp(insts: List<&2, X64Inst>, cnt: RaVec<U32>) -> RaVec<U32>:
  match insts:
    case Nil{}: cnt
    case Con{XLoad{_, 5, d}, t}: peep_count_rbp(t, peep_inc_rbp(d, cnt))
    case Con{XXmmLoad{_, 5, d}, t}: peep_count_rbp(t, peep_inc_rbp(d, cnt))
    case Con{_, t}: peep_count_rbp(t, cnt)
def peep_rbp_ov(fuel: Nat, +d: U32, xs: List<&2, X64Inst>) -> Bool:
  match fuel xs:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+p Con{XStore{5, d2, _}, t}: Bool.pick(Bool, U32.is_eq(d, d2), True{}, peep_rbp_ov(p, d, t))
    case 1n+p Con{XLoad{_, 5, d2}, t}: Bool.pick(Bool, U32.is_eq(d, d2), False{}, peep_rbp_ov(p, d, t))
    case 1n+p Con{XXmmLoad{_, 5, d2}, t}: Bool.pick(Bool, U32.is_eq(d, d2), False{}, peep_rbp_ov(p, d, t))
    case 1n+p Con{XLabel{_}, _}: False{}
    case 1n+p Con{XJmp{_}, _}: False{}
    case 1n+p Con{XJcc{_, _}, _}: False{}
    case 1n+p Con{XRet{}, _}: False{}
    case 1n+p Con{_, t}: peep_rbp_ov(p, d, t)
type PeepCSt is Data:
  PeepCSt{cm: RaVec<U32>, slbl: U32, scm: RaVec<U32>, nf: Bool}
type PeepSSt is Data:
  PeepSSt{xs: List<&2, X64Inst>, cs: PeepCSt, acc: List<&2, X64Inst>}
def peep_cm_wr(inst: X64Inst) -> U32:
  match inst:
    case XPop{d}: U32.add(d, 1)
    case XCvt{+op, d, _}: Bool.pick(U32, Bool.or(U32.is_eq(op, 1), U32.is_eq(op, 3)), U32.add(d, 1), 0)
    case h: peep_wr_gpr(h)
def peep_cm_upd(lcnt: RaVec<U32>, inst: X64Inst, st: PeepCSt) -> PeepCSt:
  match inst st:
    case XMovRI32{d, +imm} PeepCSt{cm, sl, scm, _}: PeepCSt{ra_vec_set(U32, 2n, d, Bool.pick(U32, U32.is_zero(imm), 1, Bool.pick(U32, U32.is_ge(imm, 2), imm, 0)), cm), sl, scm, False{}}
    case XAluRR{7, +d, +s} PeepCSt{cm, sl, scm, _}: PeepCSt{ra_vec_set(U32, 2n, d, Bool.pick(U32, U32.is_eq(d, s), 1, 0), cm), sl, scm, False{}}
    case XMovRR{d, s} PeepCSt{+cm, sl, scm, _}: PeepCSt{ra_vec_set(U32, 2n, d, ra_vec_get(U32, 2n, 0, s, cm), cm), sl, scm, False{}}
    case XJcc{_, tgt} PeepCSt{+cm, _, _, _}: PeepCSt{cm, tgt, cm, False{}}
    case XJmp{_} PeepCSt{_, sl, scm, _}: PeepCSt{RVEmpty{}, sl, scm, True{}}
    case XRet{} PeepCSt{_, sl, scm, _}: PeepCSt{RVEmpty{}, sl, scm, True{}}
    case XLabel{+id} PeepCSt{_, sl, scm, nf}: PeepCSt{Bool.pick(RaVec<U32>, Bool.and(nf, Bool.and(U32.is_eq(id, sl), peep_lbl_once(id, lcnt))), scm, RVEmpty{}), 4294967295, RVEmpty{}, False{}}
    case XCallSym{_} PeepCSt{_, sl, scm, _}: PeepCSt{RVEmpty{}, sl, scm, False{}}
    case XCallReg{_} PeepCSt{_, sl, scm, _}: PeepCSt{RVEmpty{}, sl, scm, False{}}
    case XDiv{_, _} PeepCSt{cm, sl, scm, _}: PeepCSt{ra_vec_set(U32, 2n, 2, 0, ra_vec_set(U32, 2n, 0, 0, cm)), sl, scm, False{}}
    case h PeepCSt{+cm, sl, scm, _}:
      +w = peep_cm_wr(h)
      PeepCSt{Bool.pick(RaVec<U32>, U32.is_zero(w), cm, ra_vec_set(U32, 2n, U32.sub(w, 1), 0, cm)), sl, scm, False{}}
def peep_asr_ok(+k: U32, mask: U32, +d: U32, +s: U32, s2: U32, s3: U32, s4: U32, +tr: U32, tr2: U32, tr3: U32, zr: U32, cm: RaVec<U32>, +rest: List<&2, X64Inst>) -> Bool:
  +m = Bool.pick(U32, Bool.and(U32.is_ge(k, 1), U32.is_le(k, 31)), U32.shln(4294967295, U32.to_nat(U32.sub(32, k))), 0)
  +c1 = peep_and_dead(Bool.and(Bool.and(Bool.and(U32.is_eq(s, s2), Bool.and(U32.is_eq(s, s3), U32.is_eq(s, s4))), Bool.and(U32.is_eq(tr, tr2), U32.is_eq(tr, tr3))), Bool.and(Bool.and(U32.is_ne(m, 0), U32.is_eq(mask, m)), Bool.and(U32.is_eq(ra_vec_get(U32, 2n, 0, zr, cm), 1), Bool.and(U32.is_ne(d, s), U32.is_ne(tr, d))))), 24n, s, rest)
  peep_and_nflags(Bool.pick(Bool, U32.is_eq(tr, s), c1, peep_and_dead(c1, 24n, tr, rest)), 3n, rest)
def peep_mul_scale(+c: U32) -> U32: Bool.pick(U32, U32.is_eq(c, 3), 1, Bool.pick(U32, U32.is_eq(c, 5), 2, Bool.pick(U32, U32.is_eq(c, 9), 3, 0)))
def peep_sar_step(lcnt: RaVec<U32>, scnt: RaVec<U32>, h: X64Inst, t: List<&2, X64Inst>, st: PeepCSt, +acc: List<&2, X64Inst>) -> PeepSSt:
  match h t st:
    case XMovRI32{+r1, +imm} Con{XMul{+d, +s}, +t2} PeepCSt{+cm, +sl, +scm, nf}:
      +sc = Bool.pick(U32, Bool.and(U32.is_eq(s, r1), Bool.and(U32.is_ne(d, r1), U32.is_ne(d, 4))), peep_mul_scale(imm), 0)
      +ok = peep_and_dead(peep_and_nflags(U32.is_ne(sc, 0), 3n, t2), 6n, r1, t2)
      Bool.pick(PeepSSt, ok, PeepSSt{t2, PeepCSt{ra_vec_set(U32, 2n, d, 0, ra_vec_set(U32, 2n, r1, 0, cm)), sl, scm, False{}}, Con{XMul{d, U32.add(16, sc)}, acc}}, PeepSSt{Con{XMul{d, s}, t2}, peep_cm_upd(lcnt, XMovRI32{r1, imm}, PeepCSt{cm, sl, scm, nf}), Con{XMovRI32{r1, imm}, acc}})
    case XMul{+d, +s} +t1 PeepCSt{+cm, +sl, +scm, nf}:
      +sc = Bool.pick(U32, U32.is_ne(d, 4), peep_mul_scale(ra_vec_get(U32, 2n, 0, s, cm)), 0)
      inst1 = Bool.pick(X64Inst, peep_and_nflags(U32.is_ne(sc, 0), 3n, t1), XMul{d, U32.add(16, sc)}, XMul{d, s})
      PeepSSt{t1, peep_cm_upd(lcnt, XMul{d, s}, PeepCSt{cm, sl, scm, nf}), Con{inst1, acc}}
    case XStore{5, +d, r} +t1 _:
      +k = peep_rbp_key(d)
      PeepSSt{t1, st, Bool.pick(List<&2, X64Inst>, Bool.or(Bool.and(U32.is_ne(k, 0), U32.is_zero(ra_vec_get(U32, 5n, 0, k, scnt))), peep_rbp_ov(12n, d, t1)), acc, Con{XStore{5, d, r}, acc})}
    case XMovRR{+d, +s} Con{XShift{9, +d2, +k, False{}}, Con{XShift{9, +s2, 31, False{}}, Con{XMovRI32{+mr, +mask}, Con{XTestRR{+s3, +s4}, Con{XMovRR{+tr, +zr}, Con{XCmov{5, +tr2, +mr2}, Con{XAluRR{6, +d3, +tr3}, +t8}}}}}}} PeepCSt{+cm, +sl, +scm, nf}:
      ok = Bool.and(Bool.and(Bool.and(U32.is_eq(d, d2), U32.is_eq(d, d3)), Bool.and(U32.is_eq(mr, mr2), Bool.and(U32.is_ne(mr, d), U32.is_ne(mr, s)))), peep_asr_ok(k, mask, d, s, s2, s3, s4, tr, tr2, tr3, zr, cm, t8))
      Bool.pick(PeepSSt, ok, PeepSSt{t8, PeepCSt{ra_vec_set(U32, 2n, d, 0, ra_vec_set(U32, 2n, mr, mask, cm)), sl, scm, False{}}, Con{XShift{10, d, k, False{}}, Con{XMovRR{d, s}, Con{XMovRI32{mr, mask}, acc}}}}, PeepSSt{Con{XShift{9, d2, k, False{}}, Con{XShift{9, s2, 31, False{}}, Con{XMovRI32{mr, mask}, Con{XTestRR{s3, s4}, Con{XMovRR{tr, zr}, Con{XCmov{5, tr2, mr2}, Con{XAluRR{6, d3, tr3}, t8}}}}}}}, peep_cm_upd(lcnt, XMovRR{d, s}, PeepCSt{cm, sl, scm, nf}), Con{XMovRR{d, s}, acc}})
    case XMovRR{+d, +s} Con{XShift{9, +d2, +k, False{}}, Con{XShift{9, +s2, 31, False{}}, Con{XTestRR{+s3, +s4}, Con{XMovRR{+tr, +zr}, Con{XCmov{5, +tr2, +mr}, Con{XAluRR{6, +d3, +tr3}, +t7}}}}}} PeepCSt{+cm, +sl, +scm, nf}:
      ok = Bool.and(Bool.and(U32.is_eq(d, d2), U32.is_eq(d, d3)), peep_asr_ok(k, ra_vec_get(U32, 2n, 0, mr, cm), d, s, s2, s3, s4, tr, tr2, tr3, zr, cm, t7))
      Bool.pick(PeepSSt, ok, PeepSSt{t7, PeepCSt{ra_vec_set(U32, 2n, d, 0, cm), sl, scm, False{}}, Con{XShift{10, d, k, False{}}, Con{XMovRR{d, s}, acc}}}, PeepSSt{Con{XShift{9, d2, k, False{}}, Con{XShift{9, s2, 31, False{}}, Con{XTestRR{s3, s4}, Con{XMovRR{tr, zr}, Con{XCmov{5, tr2, mr}, Con{XAluRR{6, d3, tr3}, t7}}}}}}, peep_cm_upd(lcnt, XMovRR{d, s}, PeepCSt{cm, sl, scm, nf}), Con{XMovRR{d, s}, acc}})
    case XMovRR{+t0, +s} Con{XShift{9, +t0b, +k, False{}}, Con{XStore{5, +dp, +t0c}, Con{XShift{9, +s2, 31, False{}}, Con{XTestRR{+s3, +s4}, Con{XMovRR{+tr, +zr}, Con{XCmov{5, +tr2, +mr}, Con{XLoad{+d, 5, +dp2}, Con{XAluRR{6, +d2, +tr3}, +t9}}}}}}}} PeepCSt{+cm, +sl, +scm, nf}:
      +dk = peep_rbp_key(dp)
      c0 = Bool.and(Bool.and(U32.is_eq(t0, t0b), U32.is_eq(t0, t0c)), Bool.and(Bool.and(U32.is_eq(dp, dp2), Bool.and(U32.is_ne(dk, 0), U32.is_eq(ra_vec_get(U32, 5n, 0, dk, scnt), 1))), U32.is_eq(d, d2)))
      +c1 = Bool.and(c0, peep_asr_ok(k, ra_vec_get(U32, 2n, 0, mr, cm), d, s, s2, s3, s4, tr, tr2, tr3, zr, cm, t9))
      ok = Bool.pick(Bool, Bool.or(U32.is_eq(t0, d), Bool.or(U32.is_eq(t0, s), U32.is_eq(t0, tr))), c1, peep_and_dead(c1, 24n, t0, t9))
      Bool.pick(PeepSSt, ok, PeepSSt{t9, PeepCSt{ra_vec_set(U32, 2n, d, 0, cm), sl, scm, False{}}, Con{XShift{10, d, k, False{}}, Con{XMovRR{d, s}, acc}}}, PeepSSt{Con{XShift{9, t0b, k, False{}}, Con{XStore{5, dp, t0c}, Con{XShift{9, s2, 31, False{}}, Con{XTestRR{s3, s4}, Con{XMovRR{tr, zr}, Con{XCmov{5, tr2, mr}, Con{XLoad{d, 5, dp2}, Con{XAluRR{6, d2, tr3}, t9}}}}}}}}, peep_cm_upd(lcnt, XMovRR{t0, s}, PeepCSt{cm, sl, scm, nf}), Con{XMovRR{t0, s}, acc}})
    case +h1 t1 _: PeepSSt{t1, peep_cm_upd(lcnt, h1, st), Con{h1, acc}}
def peep_strip_lbls(+lcnt: RaVec<U32>, xs: List<&2, X64Inst>, +acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match xs:
    case Nil{}: b5k_list_rev(X64Inst, acc)
    case Con{XLabel{+id}, t}: peep_strip_lbls(lcnt, t, Bool.pick(List<&2, X64Inst>, peep_lbl_zero(id, lcnt), acc, Con{XLabel{id}, acc}))
    case Con{h, t}: peep_strip_lbls(lcnt, t, Con{h, acc})
def peep_sar_run(+lcnt: RaVec<U32>, +scnt: RaVec<U32>, fuel: Nat, st: PeepSSt) -> List<&2, X64Inst>:
  match fuel st:
    case 0n PeepSSt{_, _, acc}: b5k_list_rev(X64Inst, acc)
    case 1n+p PeepSSt{Nil{}, _, acc}: b5k_list_rev(X64Inst, acc)
    case 1n+p PeepSSt{Con{h, t}, cs, acc}: peep_sar_run(lcnt, scnt, p, peep_sar_step(lcnt, scnt, h, t, cs, acc))
def peep_sar_dse(+insts: List<&2, X64Inst>) -> List<&2, X64Inst>:
  +lcnt = peep_count_lbls(insts, RVEmpty{})
  +xs = peep_strip_lbls(lcnt, insts, Nil{})
  peep_sar_run(lcnt, peep_count_rbp(xs, RVEmpty{}), U32.to_nat(b5k_list_len(X64Inst, xs)), PeepSSt{xs, PeepCSt{RVEmpty{}, 4294967295, RVEmpty{}, False{}}, Nil{}})

def peep_run(+dlim: Nat, +use_cmov: Bool, +lcnt: RaVec<U32>, fuel: Nat, st: PeepSt) -> List<&2, X64Inst>:
  match fuel st:
    case 0n PeepSt{_, acc}: b5k_list_rev(X64Inst, acc)
    case 1n+p PeepSt{Nil{}, acc}: b5k_list_rev(X64Inst, acc)
    case 1n+p PeepSt{Con{h, t}, acc}: peep_run(dlim, use_cmov, lcnt, p, peep_step(dlim, use_cmov, lcnt, h, t, acc))
def peep_pass(dlim: Nat, use_cmov: Bool, lcnt: RaVec<U32>, +insts: List<&2, X64Inst>) -> List<&2, X64Inst>: peep_run(dlim, use_cmov, lcnt, U32.to_nat(b5k_list_len(X64Inst, insts)), PeepSt{insts, Nil{}})
def peep_pass2(is_big: Bool, +lcnt: RaVec<U32>, insts: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_big:
    case True{}: peep_sar_dse(peep_pass(24n, True{}, lcnt, insts))
    case False{}: peep_sar_dse(peep_pass(24n, True{}, lcnt, peep_pass(24n, True{}, lcnt, insts)))
def peep_fn(fast: Bool, f: X64Fn) -> X64Fn:
  match fast f:
    case True{} X64Fn{name, is_glob, insts}: X64Fn{name, is_glob, peep_pass(4n, False{}, RVEmpty{}, insts)}
    case False{} X64Fn{name, is_glob, insts}:
      +t = peep_thread(insts)
      X64Fn{name, is_glob, peep_pass2(U32.is_gt(b5k_list_len(X64Inst, t), 1000), peep_count_lbls(t, RVEmpty{}), t)}
def b5k_peep_go(+fast: Bool, fns: List<&2, X64Fn>, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match fns:
    case Nil{}: b5k_list_rev(X64Fn, acc)
    case Con{f, t}: b5k_peep_go(fast, t, Con{peep_fn(fast, f), acc})
def b5k_peep(+fns: List<&2, X64Fn>) -> List<&2, X64Fn>: b5k_peep_go(U32.is_gt(b5k_list_len(X64Fn, fns), 768), fns, Nil{})
