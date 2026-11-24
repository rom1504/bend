# bend5k/regalloc.bend — Linear-Scan Register Allocator & Typed X64 Peephole
# ==========================================================================
# Exports:
#   - RegAllocRes, b5k_regalloc(fn: IrFn) -> RegAllocRes
#   - b5k_peep(fns: List<&2, X64Fn>) -> List<&2, X64Fn>

# Dense 4-Way U32 Bit-Trie (Depth 8 = 65,536 entries, Zero String Hashing)
type RaVec<-A: Data> is Data:
  RVEmpty{}
  RVLeaf{val: A}
  RVNode{c0: RaVec<A>, c1: RaVec<A>, c2: RaVec<A>, c3: RaVec<A>}

def ra_vec_set_go(-A: Data, d: Nat, +idx: U32, val: A, t: RaVec<A>, q: U32) -> RaVec<A>:
  match d t q:
    case 0n _ _: RVLeaf{val}
    case 1n+p RVNode{c0, c1, c2, c3} 0:
      +nxt = U32.shrn(idx, 2n)
      RVNode{ra_vec_set_go(A, p, nxt, val, c0, U32.and(nxt, 3)), c1, c2, c3}
    case 1n+p RVNode{c0, c1, c2, c3} 1:
      +nxt = U32.shrn(idx, 2n)
      RVNode{c0, ra_vec_set_go(A, p, nxt, val, c1, U32.and(nxt, 3)), c2, c3}
    case 1n+p RVNode{c0, c1, c2, c3} 2:
      +nxt = U32.shrn(idx, 2n)
      RVNode{c0, c1, ra_vec_set_go(A, p, nxt, val, c2, U32.and(nxt, 3)), c3}
    case 1n+p RVNode{c0, c1, c2, c3} _:
      +nxt = U32.shrn(idx, 2n)
      RVNode{c0, c1, c2, ra_vec_set_go(A, p, nxt, val, c3, U32.and(nxt, 3))}
    case 1n+p _ 0:
      +nxt = U32.shrn(idx, 2n)
      RVNode{ra_vec_set_go(A, p, nxt, val, RVEmpty{}, U32.and(nxt, 3)), RVEmpty{}, RVEmpty{}, RVEmpty{}}
    case 1n+p _ 1:
      +nxt = U32.shrn(idx, 2n)
      RVNode{RVEmpty{}, ra_vec_set_go(A, p, nxt, val, RVEmpty{}, U32.and(nxt, 3)), RVEmpty{}, RVEmpty{}}
    case 1n+p _ 2:
      +nxt = U32.shrn(idx, 2n)
      RVNode{RVEmpty{}, RVEmpty{}, ra_vec_set_go(A, p, nxt, val, RVEmpty{}, U32.and(nxt, 3)), RVEmpty{}}
    case 1n+p _ _:
      +nxt = U32.shrn(idx, 2n)
      RVNode{RVEmpty{}, RVEmpty{}, RVEmpty{}, ra_vec_set_go(A, p, nxt, val, RVEmpty{}, U32.and(nxt, 3))}

def ra_vec_set(-A: Data, d: Nat, +idx: U32, val: A, t: RaVec<A>) -> RaVec<A>:
  ra_vec_set_go(A, d, idx, val, t, U32.and(idx, 3))

def ra_vec_get_go(-A: Data, d: Nat, +idx: U32, defv: A, t: RaVec<A>, q: U32) -> A:
  match d t q:
    case _ RVEmpty{} _: defv
    case _ RVLeaf{v} _: v
    case 0n RVNode{_, _, _, _} _: defv
    case 1n+p RVNode{c0, _, _, _} 0:
      +nxt = U32.shrn(idx, 2n)
      ra_vec_get_go(A, p, nxt, defv, c0, U32.and(nxt, 3))
    case 1n+p RVNode{_, c1, _, _} 1:
      +nxt = U32.shrn(idx, 2n)
      ra_vec_get_go(A, p, nxt, defv, c1, U32.and(nxt, 3))
    case 1n+p RVNode{_, _, c2, _} 2:
      +nxt = U32.shrn(idx, 2n)
      ra_vec_get_go(A, p, nxt, defv, c2, U32.and(nxt, 3))
    case 1n+p RVNode{_, _, _, c3} _:
      +nxt = U32.shrn(idx, 2n)
      ra_vec_get_go(A, p, nxt, defv, c3, U32.and(nxt, 3))

def ra_vec_get(-A: Data, d: Nat, defv: A, +idx: U32, t: RaVec<A>) -> A:
  ra_vec_get_go(A, d, idx, defv, t, U32.and(idx, 3))

# Part 1: Linear-Scan Register Allocator (GPR + XMM + Move Coalescing)
type RegAllocRes is Data:
  RegAllocRes{reg_map: RaVec<U32>, vd: Nat, used_callee: List<&2, U32>, spill_count: U32}
type RaIv is Data:
  RaIv{vid: U32, start: U32, end: U32, uses: U32, seen: Bool}
type RaEdge is Data:
  RaEdge{lstart: U32, bend: U32, is_tail: Bool}
type RaScan is Data:
  RaScan{ivs: RaVec<RaIv>, bs: RaVec<U32>, cb: RaVec<U32>, nc: U32, edges: List<&2, RaEdge>, f32s: RaVec<Bool>, nf32s: RaVec<Bool>, hints: RaVec<U32>, cvals: RaVec<Bool>, idx: U32}

def ra_touch_upd_w(cur: RaIv, +v: U32, +idx: U32, dw: U32) -> RaIv:
  match cur:
    case RaIv{_, _, _, _, False{}}: RaIv{v, idx, idx, 1, True{}}
    case RaIv{_, s, e, u, True{}}: RaIv{v, U32.min(s, idx), U32.max(e, idx), U32.add(u, dw), True{}}
def ra_touch_w(+vd: Nat, +ivs: RaVec<RaIv>, +v: U32, +idx: U32, dw: U32) -> RaVec<RaIv>:
  cur = ra_vec_get(RaIv, vd, RaIv{v, idx, idx, 0, False{}}, v, ivs)
  ra_vec_set(RaIv, vd, v, ra_touch_upd_w(cur, v, idx, dw), ivs)
def ra_touch(vd: Nat, ivs: RaVec<RaIv>, v: U32, idx: U32) -> RaVec<RaIv>:
  ra_touch_w(vd, ivs, v, idx, 1)
def ra_touch_rhs(+vd: Nat, ivs: RaVec<RaIv>, +r: U32, idx: U32, fold_ok: Bool, cvals: RaVec<Bool>) -> RaVec<RaIv>:
  is_c = Bool.and(fold_ok, ra_vec_get(Bool, vd, False{}, r, cvals))
  ra_touch_w(vd, ivs, r, idx, Bool.pick(U32, is_c, 0, 1))
def ra_bop_imm_ok(+bop: U32) -> Bool:
  Bool.or(U32.is_le(bop, 1), Bool.and(U32.is_ge(bop, 5), U32.is_le(bop, 9)))
def ra_touch_list(+vd: Nat, vs: List<&2, U32>, ivs: RaVec<RaIv>, +idx: U32) -> RaVec<RaIv>:
  match vs:
    case Nil{}: ivs
    case Con{v, t}: ra_touch_list(vd, t, ra_touch(vd, ivs, v, idx), idx)
def ra_init_params(+vd: Nat, n: Nat, +v: U32, ivs: RaVec<RaIv>) -> RaVec<RaIv>:
  match n:
    case 0n: ivs
    case 1n+p: ra_init_params(vd, p, U32.add(v, 1), ra_touch(vd, ivs, v, 0))
def ra_mark_b(vd: Nat, cond: Bool, v: U32, m: RaVec<Bool>) -> RaVec<Bool>:
  match cond:
    case True{}: ra_vec_set(Bool, vd, v, True{}, m)
    case False{}: m
def ra_mark_b2(+vd: Nat, cond: Bool, a: U32, b: U32, m: RaVec<Bool>) -> RaVec<Bool>:
  match cond:
    case True{}: ra_vec_set(Bool, vd, b, True{}, ra_vec_set(Bool, vd, a, True{}, m))
    case False{}: m
def ra_mark_b3(+vd: Nat, cond: Bool, a: U32, b: U32, c: U32, m: RaVec<Bool>) -> RaVec<Bool>:
  match cond:
    case True{}: ra_vec_set(Bool, vd, c, True{}, ra_vec_set(Bool, vd, b, True{}, ra_vec_set(Bool, vd, a, True{}, m)))
    case False{}: m
def ra_set_hint_go(ok: Bool, vd: Nat, d: U32, s: U32, hs: RaVec<U32>) -> RaVec<U32>:
  match ok:
    case False{}: hs
    case True{}: ra_vec_set(U32, vd, d, U32.add(s, 1), hs)
def ra_set_hint(vd: Nat, +d: U32, +s: U32, hs: RaVec<U32>) -> RaVec<U32>:
  ra_set_hint_go(U32.is_ne(d, s), vd, d, s, hs)
def ra_set_hint_soft(+vd: Nat, +d: U32, +s: U32, +hs: RaVec<U32>) -> RaVec<U32>:
  ok = Bool.and(U32.is_ne(d, s), U32.is_zero(ra_vec_get(U32, vd, 0, d, hs)))
  ra_set_hint_go(ok, vd, d, s, hs)
def ra_tail_hints(+vd: Nat, args: List<&2, U32>, +i: U32, hs: RaVec<U32>) -> RaVec<U32>:
  match args:
    case Nil{}: hs
    case Con{a, t}: ra_tail_hints(vd, t, U32.add(i, 1), ra_set_hint_soft(vd, a, i, hs))
def ra_tail_hints_if(same_fn: Bool, vd: Nat, args: List<&2, U32>, hs: RaVec<U32>) -> RaVec<U32>:
  match same_fn:
    case True{}: ra_tail_hints(vd, args, 0, hs)
    case False{}: hs
def ra_rec_cb(cd: Nat, nz: Bool, idx: U32, nc: U32, cb: RaVec<U32>) -> RaVec<U32>:
  match nz:
    case False{}: cb
    case True{}: ra_vec_set(U32, cd, idx, nc, cb)
def ra_rec(cd: Nat, is_call: Bool, ivs: RaVec<RaIv>, bs: RaVec<U32>, cb: RaVec<U32>, +nc: U32, es: List<&2, RaEdge>, f32s: RaVec<Bool>, nf32s: RaVec<Bool>, hs: RaVec<U32>, cvals: RaVec<Bool>, +idx: U32, nxt: U32) -> RaScan:
  +nc1 = Bool.pick(U32, is_call, U32.add(nc, 1), nc)
  RaScan{ivs, bs, ra_rec_cb(cd, U32.is_ne(nc, 0), idx, nc, cb), nc1, es, f32s, nf32s, hs, cvals, nxt}

def ra_is_nonempty(xs: List<&2, U32>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{_, _}: True{}

def ra_scan_op_go(+vd: Nat, cd: Nat, op: IrOp, ivs: RaVec<RaIv>, bs: RaVec<U32>, cb: RaVec<U32>, nc: U32, es: List<&2, RaEdge>, +f32s: RaVec<Bool>, +nf32s: RaVec<Bool>, hs: RaVec<U32>, +cvals: RaVec<Bool>, +idx: U32, nxt: U32) -> RaScan:
  match op:
    case IConst{+d, val}:
      cv1 = ra_mark_b(vd, U32.is_lt(val, 2147483648), d, cvals)
      ra_rec(cd, False{}, ra_touch(vd, ivs, d, idx), bs, cb, nc, es, f32s, ra_vec_set(Bool, vd, d, True{}, nf32s), hs, cv1, idx, nxt)
    case IFlt{+d, _}: ra_rec(cd, False{}, ra_touch(vd, ivs, d, idx), bs, cb, nc, es, ra_vec_set(Bool, vd, d, True{}, f32s), nf32s, hs, cvals, idx, nxt)
    case ICopy{+d, +s}:
      f1 = ra_mark_b(vd, ra_vec_get(Bool, vd, False{}, s, f32s), d, f32s)
      nf1 = ra_mark_b(vd, ra_vec_get(Bool, vd, False{}, s, nf32s), d, nf32s)
      ra_rec(cd, False{}, ra_touch(vd, ra_touch(vd, ivs, s, idx), d, idx), bs, cb, nc, es, f1, nf1, ra_set_hint(vd, d, s, hs), cvals, idx, nxt)
    case IBin{+d, +bop, +l, +r}:
      +isf = U32.is_ge(bop, 10)
      f1 = ra_mark_b3(vd, isf, d, l, r, f32s)
      nf1 = ra_mark_b3(vd, Bool.not(isf), d, l, r, nf32s)
      ivs1 = ra_touch(vd, ra_touch_rhs(vd, ra_touch(vd, ivs, l, idx), r, idx, ra_bop_imm_ok(bop), cvals), d, idx)
      ra_rec(cd, False{}, ivs1, bs, cb, nc, es, f1, nf1, ra_set_hint(vd, d, l, hs), cvals, idx, nxt)
    case IUn{+d, +uop, +s}:
      df = Bool.and(U32.is_ge(uop, 2), U32.is_le(uop, 4))
      sf = Bool.or(U32.is_eq(uop, 2), Bool.or(U32.is_eq(uop, 3), U32.is_eq(uop, 5)))
      dnf = Bool.or(U32.is_lt(uop, 2), U32.is_eq(uop, 5))
      snf = Bool.or(U32.is_lt(uop, 2), U32.is_eq(uop, 4))
      f1 = ra_mark_b(vd, sf, s, ra_mark_b(vd, df, d, f32s))
      nf1 = ra_mark_b(vd, snf, s, ra_mark_b(vd, dnf, d, nf32s))
      ra_rec(cd, False{}, ra_touch(vd, ra_touch(vd, ivs, s, idx), d, idx), bs, cb, nc, es, f1, nf1, ra_set_hint(vd, d, s, hs), cvals, idx, nxt)
    case ICmp{+d, +cop, +l, +r}:
      +isf = U32.is_ge(cop, 6)
      f1 = ra_mark_b2(vd, isf, l, r, f32s)
      nf1 = ra_mark_b2(vd, Bool.not(isf), l, r, ra_vec_set(Bool, vd, d, True{}, nf32s))
      ivs1 = ra_touch(vd, ra_touch_rhs(vd, ra_touch(vd, ivs, l, idx), r, idx, Bool.not(isf), cvals), d, idx)
      ra_rec(cd, False{}, ivs1, bs, cb, nc, es, f1, nf1, hs, cvals, idx, nxt)
    case ICallDirect{d, _, args}: ra_rec(cd, True{}, ra_touch(vd, ra_touch_list(vd, args, ivs, idx), d, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case ICallClosure{+d, _, caps}: ra_rec(cd, True{}, ra_touch(vd, ra_touch_list(vd, caps, ivs, idx), d, idx), bs, cb, nc, es, f32s, ra_vec_set(Bool, vd, d, True{}, nf32s), hs, cvals, idx, nxt)
    case IApply{+d, +clo, arg}: ra_rec(cd, True{}, ra_touch(vd, ra_touch(vd, ra_touch(vd, ivs, clo, idx), arg, idx), d, idx), bs, cb, nc, es, f32s, ra_mark_b2(vd, True{}, d, clo, nf32s), hs, cvals, idx, nxt)
    case ICtor{+d, _, +fs}: ra_rec(cd, ra_is_nonempty(fs), ra_touch(vd, ra_touch_list(vd, fs, ivs, idx), d, idx), bs, cb, nc, es, f32s, ra_vec_set(Bool, vd, d, True{}, nf32s), hs, cvals, idx, nxt)
    case ITake{+ds, +s}: ra_rec(cd, ra_is_nonempty(ds), ra_touch_list(vd, ds, ra_touch(vd, ivs, s, idx), idx), bs, cb, nc, es, f32s, ra_vec_set(Bool, vd, s, True{}, nf32s), hs, cvals, idx, nxt)
    case ITag{+d, +s}: ra_rec(cd, False{}, ra_touch(vd, ra_touch(vd, ivs, s, idx), d, idx), bs, cb, nc, es, f32s, ra_mark_b2(vd, True{}, d, s, nf32s), ra_set_hint(vd, d, s, hs), cvals, idx, nxt)
    case IKeep{d, s}: ra_rec(cd, True{}, ra_touch(vd, ra_touch(vd, ivs, s, idx), d, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case ISink{s}: ra_rec(cd, True{}, ra_touch(vd, ivs, s, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case IReuse{+d, +sl, _, +fs}: ra_rec(cd, ra_is_nonempty(fs), ra_touch(vd, ra_touch(vd, ra_touch_list(vd, fs, ivs, idx), sl, idx), d, idx), bs, cb, nc, es, f32s, ra_mark_b2(vd, True{}, d, sl, nf32s), hs, cvals, idx, nxt)
    case IStatic{+d, _}: ra_rec(cd, False{}, ra_touch(vd, ivs, d, idx), bs, cb, nc, es, f32s, ra_vec_set(Bool, vd, d, True{}, nf32s), hs, cvals, idx, nxt)
    case IArrOp{ds, _, args}: ra_rec(cd, True{}, ra_touch_list(vd, ds, ra_touch_list(vd, args, ivs, idx), idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case IAlloca{+d, _}: ra_rec(cd, False{}, ra_touch(vd, ivs, d, idx), bs, cb, nc, es, f32s, ra_vec_set(Bool, vd, d, True{}, nf32s), hs, cvals, idx, nxt)
    case ILoad{+d, +b, _}: ra_rec(cd, False{}, ra_touch(vd, ra_touch(vd, ivs, b, idx), d, idx), bs, cb, nc, es, f32s, ra_mark_b2(vd, True{}, d, b, nf32s), hs, cvals, idx, nxt)
    case IStore{+b, _, v}: ra_rec(cd, False{}, ra_touch(vd, ra_touch(vd, ivs, b, idx), v, idx), bs, cb, nc, es, f32s, ra_vec_set(Bool, vd, b, True{}, nf32s), hs, cvals, idx, nxt)
    case IFail{_}: ra_rec(cd, True{}, ivs, bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)

def ra_ops_has_f32(ops: List<&2, IrOp>) -> Bool:
  match ops:
    case Nil{}: False{}
    case Con{IFlt{_, _}, _}: True{}
    case Con{IBin{_, bop, _, _}, t}: Bool.or(U32.is_ge(bop, 10), ra_ops_has_f32(t))
    case Con{IUn{_, uop, _}, t}: Bool.or(U32.is_ge(uop, 2), ra_ops_has_f32(t))
    case Con{ICmp{_, cop, _, _}, t}: Bool.or(U32.is_ge(cop, 6), ra_ops_has_f32(t))
    case Con{_, t}: ra_ops_has_f32(t)
def ra_blks_has_f32(blks: List<&2, IrBlock>) -> Bool:
  match blks:
    case Nil{}: False{}
    case Con{IrBlock{_, ops, _}, t}: Bool.or(ra_ops_has_f32(ops), ra_blks_has_f32(t))
def ra_scan_op_nf(+vd: Nat, cd: Nat, op: IrOp, ivs: RaVec<RaIv>, bs: RaVec<U32>, cb: RaVec<U32>, nc: U32, es: List<&2, RaEdge>, f32s: RaVec<Bool>, nf32s: RaVec<Bool>, hs: RaVec<U32>, +cvals: RaVec<Bool>, +idx: U32, nxt: U32) -> RaScan:
  match op:
    case IConst{+d, val}:
      cv1 = ra_mark_b(vd, U32.is_lt(val, 2147483648), d, cvals)
      ra_rec(cd, False{}, ra_touch(vd, ivs, d, idx), bs, cb, nc, es, f32s, nf32s, hs, cv1, idx, nxt)
    case IFlt{d, _}: ra_rec(cd, False{}, ra_touch(vd, ivs, d, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case ICopy{+d, +s}: ra_rec(cd, False{}, ra_touch(vd, ra_touch(vd, ivs, s, idx), d, idx), bs, cb, nc, es, f32s, nf32s, ra_set_hint(vd, d, s, hs), cvals, idx, nxt)
    case IBin{+d, bop, +l, r}:
      ivs1 = ra_touch(vd, ra_touch_rhs(vd, ra_touch(vd, ivs, l, idx), r, idx, ra_bop_imm_ok(bop), cvals), d, idx)
      ra_rec(cd, False{}, ivs1, bs, cb, nc, es, f32s, nf32s, ra_set_hint(vd, d, l, hs), cvals, idx, nxt)
    case IUn{+d, _, +s}: ra_rec(cd, False{}, ra_touch(vd, ra_touch(vd, ivs, s, idx), d, idx), bs, cb, nc, es, f32s, nf32s, ra_set_hint(vd, d, s, hs), cvals, idx, nxt)
    case ICmp{d, cop, l, r}:
      ivs1 = ra_touch(vd, ra_touch_rhs(vd, ra_touch(vd, ivs, l, idx), r, idx, U32.is_lt(cop, 6), cvals), d, idx)
      ra_rec(cd, False{}, ivs1, bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case ICallDirect{d, _, args}: ra_rec(cd, True{}, ra_touch(vd, ra_touch_list(vd, args, ivs, idx), d, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case ICallClosure{d, _, caps}: ra_rec(cd, True{}, ra_touch(vd, ra_touch_list(vd, caps, ivs, idx), d, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case IApply{d, clo, arg}: ra_rec(cd, True{}, ra_touch(vd, ra_touch(vd, ra_touch(vd, ivs, clo, idx), arg, idx), d, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case ICtor{d, _, +fs}: ra_rec(cd, ra_is_nonempty(fs), ra_touch(vd, ra_touch_list(vd, fs, ivs, idx), d, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case ITake{+ds, s}: ra_rec(cd, ra_is_nonempty(ds), ra_touch_list(vd, ds, ra_touch(vd, ivs, s, idx), idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case ITag{+d, +s}: ra_rec(cd, False{}, ra_touch(vd, ra_touch(vd, ivs, s, idx), d, idx), bs, cb, nc, es, f32s, nf32s, ra_set_hint(vd, d, s, hs), cvals, idx, nxt)
    case IKeep{d, s}: ra_rec(cd, True{}, ra_touch(vd, ra_touch(vd, ivs, s, idx), d, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case ISink{s}: ra_rec(cd, True{}, ra_touch(vd, ivs, s, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case IReuse{d, sl, _, +fs}: ra_rec(cd, ra_is_nonempty(fs), ra_touch(vd, ra_touch(vd, ra_touch_list(vd, fs, ivs, idx), sl, idx), d, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case IStatic{d, _}: ra_rec(cd, False{}, ra_touch(vd, ivs, d, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case IArrOp{ds, _, args}: ra_rec(cd, True{}, ra_touch_list(vd, ds, ra_touch_list(vd, args, ivs, idx), idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case IAlloca{d, _}: ra_rec(cd, False{}, ra_touch(vd, ivs, d, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case ILoad{d, b, _}: ra_rec(cd, False{}, ra_touch(vd, ra_touch(vd, ivs, b, idx), d, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case IStore{b, _, v}: ra_rec(cd, False{}, ra_touch(vd, ra_touch(vd, ivs, b, idx), v, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case IFail{_}: ra_rec(cd, True{}, ivs, bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)

def ra_scan_op(vd: Nat, cd: Nat, track_f: Bool, op: IrOp, st: RaScan) -> RaScan:
  match track_f st:
    case True{} RaScan{ivs, bs, cb, nc, es, f32s, nf32s, hs, cvals, +idx}:
      ra_scan_op_go(vd, cd, op, ivs, bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, U32.add(idx, 1))
    case False{} RaScan{ivs, bs, cb, nc, es, f32s, nf32s, hs, cvals, +idx}:
      ra_scan_op_nf(vd, cd, op, ivs, bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, U32.add(idx, 1))
def ra_scan_ops(+vd: Nat, +cd: Nat, +track_f: Bool, ops: List<&2, IrOp>, st: RaScan) -> RaScan:
  match ops:
    case Nil{}: st
    case Con{op, t}: ra_scan_ops(vd, cd, track_f, t, ra_scan_op(vd, cd, track_f, op, st))
def ra_add_edge_fin(is_z: Bool, is_tail: Bool, s1: U32, idx: U32, es: List<&2, RaEdge>) -> List<&2, RaEdge>:
  match is_z:
    case True{}: es
    case False{}: Con{RaEdge{U32.sub(s1, 1), idx, is_tail}, es}
def ra_check_edge(bs: RaVec<U32>, tgt: U32, idx: U32, is_tail: Bool, es: List<&2, RaEdge>) -> List<&2, RaEdge>:
  +s1 = ra_vec_get(U32, 8n, 0, tgt, bs)
  ra_add_edge_fin(U32.is_zero(s1), is_tail, s1, idx, es)
def ra_check_arms(+bs: RaVec<U32>, arms: List<&2, IrSwitchArm>, +idx: U32, es: List<&2, RaEdge>) -> List<&2, RaEdge>:
  match arms:
    case Nil{}: es
    case Con{IrArm{_, tgt}, t}: ra_check_arms(bs, t, idx, ra_check_edge(bs, tgt, idx, False{}, es))
def ra_tail_edge(same_fn: Bool, bs: RaVec<U32>, idx: U32, es: List<&2, RaEdge>) -> List<&2, RaEdge>:
  match same_fn:
    case True{}: ra_check_edge(bs, 0, idx, True{}, es)
    case False{}: es

def ra_scan_term_go(+vd: Nat, cd: Nat, track_f: Bool, fn_fid: U32, term: IrTerm, ivs: RaVec<RaIv>, +bs: RaVec<U32>, cb: RaVec<U32>, nc: U32, es: List<&2, RaEdge>, f32s: RaVec<Bool>, nf32s: RaVec<Bool>, hs: RaVec<U32>, cvals: RaVec<Bool>, +idx: U32, nxt: U32) -> RaScan:
  match term:
    case TJmp{tgt}: ra_rec(cd, False{}, ivs, bs, cb, nc, ra_check_edge(bs, tgt, idx, False{}, es), f32s, nf32s, hs, cvals, idx, nxt)
    case TBr{+c, tb, eb}:
      es1 = ra_check_edge(bs, eb, idx, False{}, ra_check_edge(bs, tb, idx, False{}, es))
      ra_rec(cd, False{}, ra_touch(vd, ivs, c, idx), bs, cb, nc, es1, f32s, ra_mark_b(vd, track_f, c, nf32s), hs, cvals, idx, nxt)
    case TSwitch{+sc, arms, db}:
      es1 = ra_check_edge(bs, db, idx, False{}, ra_check_arms(bs, arms, idx, es))
      ra_rec(cd, False{}, ra_touch(vd, ivs, sc, idx), bs, cb, nc, es1, f32s, ra_mark_b(vd, track_f, sc, nf32s), hs, cvals, idx, nxt)
    case TRet{v}: ra_rec(cd, False{}, ra_touch(vd, ivs, v, idx), bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
    case TTailCall{fid, +args}:
      +same = U32.is_eq(fid, fn_fid)
      es1 = ra_tail_edge(same, bs, idx, es)
      hs1 = ra_tail_hints_if(same, vd, args, hs)
      is_c = U32.is_gt(b5k_list_len(U32, args), 32)
      ra_rec(cd, is_c, ra_touch_list(vd, args, ivs, idx), bs, cb, nc, es1, f32s, nf32s, hs1, cvals, idx, nxt)
    case TFail{_}: ra_rec(cd, True{}, ivs, bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, nxt)
def ra_scan_term(vd: Nat, cd: Nat, track_f: Bool, fn_fid: U32, term: IrTerm, st: RaScan) -> RaScan:
  match st:
    case RaScan{ivs, bs, cb, nc, es, f32s, nf32s, hs, cvals, +idx}:
      ra_scan_term_go(vd, cd, track_f, fn_fid, term, ivs, bs, cb, nc, es, f32s, nf32s, hs, cvals, idx, U32.add(idx, 1))
def ra_scan_blks(+vd: Nat, +cd: Nat, +track_f: Bool, +fn_fid: U32, blks: List<&2, IrBlock>, st: RaScan) -> RaScan:
  match blks st:
    case Nil{} _: st
    case Con{IrBlock{bid, ops, term}, t} RaScan{ivs, bs, cb, nc, es, f32s, nf32s, hs, cvals, +idx}:
      bs1 = ra_vec_set(U32, 8n, bid, U32.add(idx, 1), bs)
      st1 = ra_scan_term(vd, cd, track_f, fn_fid, term, ra_scan_ops(vd, cd, track_f, ops, RaScan{ivs, bs1, cb, nc, es, f32s, nf32s, hs, cvals, idx}))
      ra_scan_blks(vd, cd, track_f, fn_fid, t, st1)

# Loop Back-Edge Extension & 8x Loop-Depth Weighting
def ra_ext_end_one(arity: U32, iv: RaIv, edge: RaEdge) -> RaIv:
  match iv edge:
    case RaIv{+v, +s, +e, u, seen} RaEdge{+ls, be, is_tail}:
      skip_tail = Bool.and(is_tail, U32.is_lt(v, arity))
      live_hdr = Bool.and(Bool.not(skip_tail), Bool.and(U32.is_le(s, ls), U32.is_ge(e, ls)))
      RaIv{v, s, Bool.pick(U32, live_hdr, U32.max(e, be), e), u, seen}
def ra_ext_end(+arity: U32, es: List<&2, RaEdge>, iv: RaIv) -> RaIv:
  match es:
    case Nil{}: iv
    case Con{edge, t}: ra_ext_end(arity, t, ra_ext_end_one(arity, iv, edge))
def ra_ext_end_all(+arity: U32, es: List<&2, RaEdge>, iv: RaIv) -> RaIv:
  match es:
    case Nil{}: iv
    case Con{e1, Nil{}}: ra_ext_end_one(arity, iv, e1)
    case Con{+e1, Con{+e2, +t}}:
      ra_ext_end(arity, Con{e1, Con{e2, t}}, ra_ext_end(arity, Con{e1, Con{e2, t}}, iv))
def ra_weight_one(iv: RaIv, edge: RaEdge) -> RaIv:
  match iv edge:
    case RaIv{v, +s, +e, +u, seen} RaEdge{+ls, +be, _}:
      in_loop = Bool.and(U32.is_ge(s, ls), U32.is_le(e, be))
      hdr_in = Bool.and(U32.is_lt(s, ls), Bool.and(U32.is_ge(e, ls), U32.is_le(e, be)))
      spans_hot = Bool.and(U32.is_lt(s, ls), Bool.and(U32.is_gt(e, be), U32.is_gt(u, 2)))
      u_span = Bool.pick(U32, spans_hot, U32.add(2, U32.mul(U32.min(U32.sub(u, 2), 1000000), 8)), u)
      u2 = Bool.pick(U32, Bool.or(in_loop, hdr_in), U32.mul(U32.min(u, 1000000), 8), u_span)
      RaIv{v, s, e, u2, seen}
def ra_weight_edges(es: List<&2, RaEdge>, iv: RaIv) -> RaIv:
  match es:
    case Nil{}: iv
    case Con{edge, t}: ra_weight_edges(t, ra_weight_one(iv, edge))

type RaParts is Data:
  RaParts{cross: List<&2, RaIv>, xmm_nc: List<&2, RaIv>, gpr_nc: List<&2, RaIv>}
def ra_add_part_fin(is_cr: Bool, is_f: Bool, iv: RaIv, cr: List<&2, RaIv>, xm: List<&2, RaIv>, nc: List<&2, RaIv>) -> RaParts:
  match is_cr is_f:
    case True{} _: RaParts{Con{iv, cr}, xm, nc}
    case False{} True{}: RaParts{cr, Con{iv, xm}, nc}
    case False{} False{}: RaParts{cr, xm, Con{iv, nc}}
def ra_iv_is_leaf(+cd: Nat, no_calls: Bool, +s: U32, +e: U32, +cb: RaVec<U32>) -> Bool:
  match no_calls:
    case True{}: True{}
    case False{}:
      +e1 = U32.add(e, 1)
      Bool.and(U32.is_gt(s, 0), Bool.and(U32.is_lt(e1, 65536), U32.is_eq(ra_vec_get(U32, cd, 0, e1, cb), ra_vec_get(U32, cd, 0, s, cb))))
def ra_add_part_go(+cd: Nat, iv2: RaIv, is_f: Bool, +cb: RaVec<U32>, cr: List<&2, RaIv>, xm: List<&2, RaIv>, nc: List<&2, RaIv>) -> RaParts:
  match iv2:
    case RaIv{v, +s, +e, u, seen}:
      is_cr = U32.is_gt(ra_vec_get(U32, cd, 0, e, cb), ra_vec_get(U32, cd, 0, U32.add(s, 1), cb))
      ra_add_part_fin(is_cr, is_f, RaIv{v, s, e, u, seen}, cr, xm, nc)
def ra_add_part(cd: Nat, arity: U32, iv: RaIv, is_f: Bool, cb: RaVec<U32>, +es: List<&2, RaEdge>, pts: RaParts) -> RaParts:
  match iv pts:
    case RaIv{_, _, _, _, False{}} _: pts
    case RaIv{v, s, e, u, True{}} RaParts{cr, xm, nc}:
      iv1 = ra_ext_end_all(arity, es, RaIv{v, s, e, u, True{}})
      ra_add_part_go(cd, ra_weight_edges(es, iv1), is_f, cb, cr, xm, nc)
def ra_is_f32(+vd: Nat, track_f: Bool, +v: U32, f32s: RaVec<Bool>, nf32s: RaVec<Bool>) -> Bool:
  match track_f:
    case False{}: False{}
    case True{}: Bool.and(ra_vec_get(Bool, vd, False{}, v, f32s), Bool.not(ra_vec_get(Bool, vd, False{}, v, nf32s)))
def ra_collect_ivs(+vd: Nat, +cd: Nat, +track_f: Bool, +arity: U32, n: Nat, +v: U32, +ivs: RaVec<RaIv>, +cb: RaVec<U32>, +es: List<&2, RaEdge>, +f32s: RaVec<Bool>, +nf32s: RaVec<Bool>, pts: RaParts) -> RaParts:
  match n:
    case 0n: pts
    case 1n+p:
      iv = ra_vec_get(RaIv, vd, RaIv{v, 0, 0, 0, False{}}, v, ivs)
      is_f = ra_is_f32(vd, track_f, v, f32s, nf32s)
      ra_collect_ivs(vd, cd, track_f, arity, p, U32.add(v, 1), ivs, cb, es, f32s, nf32s, ra_add_part(cd, arity, iv, is_f, cb, es, pts))

# Merge Sort by Start Ascending, Weight Descending (O(N log N))
def ra_even(xs: List<&2, RaIv>) -> List<&2, RaIv>:
  match xs:
    case Nil{}: Nil{}
    case Con{x, Nil{}}: Con{x, Nil{}}
    case Con{x, Con{_, t}}: Con{x, ra_even(t)}
def ra_odd(xs: List<&2, RaIv>) -> List<&2, RaIv>:
  match xs:
    case Nil{}: Nil{}
    case Con{_, Nil{}}: Nil{}
    case Con{_, Con{y, t}}: Con{y, ra_odd(t)}
def ra_iv_ge(a: RaIv, b: RaIv) -> Bool:
  match a b:
    case RaIv{_, +sa, _, ua, _} RaIv{_, +sb, _, ub, _}:
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
    case 1n+p RaMergeSt{Con{+x, xt}, Con{+y, yt}, acc}:
      ra_merge_run(p, ra_merge_pick(ra_iv_ge(x, y), x, xt, y, yt, acc))
def ra_merge(+xs: List<&2, RaIv>, +ys: List<&2, RaIv>) -> List<&2, RaIv>:
  tot = U32.add(b5k_list_len(RaIv, xs), b5k_list_len(RaIv, ys))
  ra_merge_run(U32.to_nat(tot), RaMergeSt{xs, ys, Nil{}})
def ra_msort(+d: Nat, xs: List<&2, RaIv>) -> List<&2, RaIv>:
  match d xs:
    case 0n _: xs
    case _ Nil{}: Nil{}
    case _ Con{x, Nil{}}: Con{x, Nil{}}
    case 1n+p Con{x, Con{y, +t}}:
      ra_merge(ra_msort(p, Con{x, ra_even(t)}), ra_msort(p, Con{y, ra_odd(t)}))

# Physical Register Pool Assignment (Linear Scan + Weight Eviction, Short-Circuiting)
type RaSlot is Data:
  RaSlot{reg: U32, vid: U32, start: U32, last_end: U32, weight: U32, used: Bool}
type RaTry is Data:
  RaTry{ok: Bool, reg: U32, pool: List<&2, RaSlot>}
type RaMin is Data:
  RaMin{found: Bool, reg: U32, vid: U32, start: U32, weight: U32, last_end: U32}
type RaAllocSt is Data:
  RaAllocSt{rmap: RaVec<U32>, callee: List<&2, RaSlot>, caller: List<&2, RaSlot>, spills: U32}

def ra_slot_free(used: Bool, last_end: U32, s: U32) -> Bool:
  match used:
    case False{}: True{}
    case True{}: U32.is_lt(last_end, s)
def ra_try_go(pool: List<&2, RaSlot>, found: Bool, +reg: U32, +v: U32, +s: U32, +e: U32, +w: U32, acc: List<&2, RaSlot>) -> RaTry:
  match pool found:
    case rest True{}: RaTry{True{}, reg, b5k_list_rev_go(RaSlot, acc, rest)}
    case Nil{} False{}: RaTry{False{}, 0, b5k_list_rev(RaSlot, acc)}
    case Con{RaSlot{+r, ov, os, +le, ow, +u}, t} False{}:
      +free = ra_slot_free(u, le, s)
      sl = Bool.pick(RaSlot, free, RaSlot{r, v, s, e, w, True{}}, RaSlot{r, ov, os, le, ow, u})
      ra_try_go(t, free, r, v, s, e, w, Con{sl, acc})
def ra_try_pool(pool: List<&2, RaSlot>, v: U32, s: U32, e: U32, w: U32) -> RaTry:
  ra_try_go(pool, False{}, 0, v, s, e, w, Nil{})
def ra_try_pref_go(pool: List<&2, RaSlot>, found: Bool, +reg: U32, +pref: U32, +src: U32, +only_used: Bool, +v: U32, +s: U32, +e: U32, +w: U32, acc: List<&2, RaSlot>) -> RaTry:
  match pool found:
    case rest True{}: RaTry{True{}, reg, b5k_list_rev_go(RaSlot, acc, rest)}
    case Nil{} False{}: RaTry{False{}, 0, b5k_list_rev(RaSlot, acc)}
    case Con{RaSlot{+r, +ov, os, +le, ow, +u}, t} False{}:
      can_coal = Bool.and(u, Bool.and(U32.is_eq(ov, src), U32.is_le(le, s)))
      can_free = Bool.and(Bool.not(only_used), ra_slot_free(u, le, s))
      +hit = Bool.and(U32.is_eq(r, pref), Bool.or(can_coal, can_free))
      sl = Bool.pick(RaSlot, hit, RaSlot{r, v, s, e, w, True{}}, RaSlot{r, ov, os, le, ow, u})
      ra_try_pref_go(t, hit, r, pref, src, only_used, v, s, e, w, Con{sl, acc})
def ra_try_pref_fin(tr: RaTry, fb: Bool, v: U32, s: U32, e: U32, w: U32) -> RaTry:
  match tr fb:
    case RaTry{True{}, r, pl} _: RaTry{True{}, r, pl}
    case RaTry{False{}, _, pl} True{}: ra_try_pool(pl, v, s, e, w)
    case RaTry{False{}, _, pl} False{}: RaTry{False{}, 0, pl}
def ra_try_pref_s2(has_p: Bool, p: U32, src: U32, pool: List<&2, RaSlot>, only_used: Bool, fb: Bool, +v: U32, +s: U32, +e: U32, +w: U32) -> RaTry:
  match has_p fb:
    case True{} _: ra_try_pref_fin(ra_try_pref_go(pool, False{}, 0, p, src, only_used, v, s, e, w, Nil{}), fb, v, s, e, w)
    case False{} True{}: ra_try_pool(pool, v, s, e, w)
    case False{} False{}: RaTry{False{}, 0, pool}
def ra_try_pref_s1(has_h: Bool, vd: Nat, h: U32, rmap: RaVec<U32>, pool: List<&2, RaSlot>, only_used: Bool, fb: Bool, v: U32, s: U32, e: U32, w: U32) -> RaTry:
  match has_h fb:
    case True{} _:
      +src = U32.sub(h, 1)
      +p = ra_vec_get(U32, vd, 0, src, rmap)
      ra_try_pref_s2(Bool.and(U32.is_ne(p, 0), U32.is_lt(p, 100)), p, src, pool, only_used, fb, v, s, e, w)
    case False{} True{}: ra_try_pool(pool, v, s, e, w)
    case False{} False{}: RaTry{False{}, 0, pool}
def ra_try_pool_pref(+vd: Nat, hints: RaVec<U32>, rmap: RaVec<U32>, pool: List<&2, RaSlot>, only_used: Bool, fb: Bool, +v: U32, s: U32, e: U32, w: U32) -> RaTry:
  +h = ra_vec_get(U32, vd, 0, v, hints)
  ra_try_pref_s1(U32.is_ne(h, 0), vd, h, rmap, pool, only_used, fb, v, s, e, w)
def ra_min_pick(better: Bool, r: U32, vid: U32, st: U32, w: U32, le: U32, cur: RaMin) -> RaMin:
  match better:
    case True{}: RaMin{True{}, r, vid, st, w, le}
    case False{}: cur
def ra_find_min_go(pool: List<&2, RaSlot>, cur: RaMin) -> RaMin:
  match pool cur:
    case Nil{} _: cur
    case Con{RaSlot{r, vid, st, le, w, _}, t} RaMin{False{}, _, _, _, _, _}:
      ra_find_min_go(t, RaMin{True{}, r, vid, st, w, le})
    case Con{RaSlot{r, vid, st, +le, +w, _}, t} RaMin{True{}, cr, cv, cs, +cw, +cle}:
      better = Bool.or(U32.is_lt(w, cw), Bool.and(U32.is_eq(w, cw), U32.is_gt(le, cle)))
      ra_find_min_go(t, ra_min_pick(better, r, vid, st, w, le, RaMin{True{}, cr, cv, cs, cw, cle}))
def ra_rep_go(pool: List<&2, RaSlot>, done: Bool, +tgt: U32, +v: U32, +s: U32, +e: U32, +w: U32, acc: List<&2, RaSlot>) -> List<&2, RaSlot>:
  match pool done:
    case rest True{}: b5k_list_rev_go(RaSlot, acc, rest)
    case Nil{} False{}: b5k_list_rev(RaSlot, acc)
    case Con{RaSlot{+r, ov, os, le, ow, u}, t} False{}:
      +hit = U32.is_eq(r, tgt)
      sl = Bool.pick(RaSlot, hit, RaSlot{r, v, s, e, w, True{}}, RaSlot{r, ov, os, le, ow, u})
      ra_rep_go(t, hit, tgt, v, s, e, w, Con{sl, acc})
def ra_replace_slot(pool: List<&2, RaSlot>, tgt: U32, v: U32, s: U32, e: U32, w: U32) -> List<&2, RaSlot>:
  ra_rep_go(pool, False{}, tgt, v, s, e, w, Nil{})

type RaEvictRes is Data:
  RaEvictRes{rmap: RaVec<U32>, pool: List<&2, RaSlot>, spills: U32}
def ra_evict_fin(+vd: Nat, do_ev: Bool, +mr: U32, mvid: U32, +v: U32, s: U32, e: U32, w: U32, rm: RaVec<U32>, pl: List<&2, RaSlot>, +sp: U32) -> RaEvictRes:
  match do_ev:
    case True{}:
      rm1 = ra_vec_set(U32, vd, v, mr, ra_vec_set(U32, vd, mvid, U32.add(100, sp), rm))
      RaEvictRes{rm1, ra_replace_slot(pl, mr, v, s, e, w), U32.add(sp, 1)}
    case False{}:
      RaEvictRes{ra_vec_set(U32, vd, v, U32.add(100, sp), rm), pl, U32.add(sp, 1)}
def ra_evict_pool(vd: Nat, mn: RaMin, v: U32, s: U32, +e: U32, +w: U32, rm: RaVec<U32>, pl: List<&2, RaSlot>, sp: U32) -> RaEvictRes:
  match mn:
    case RaMin{found, mr, mvid, _, +mw, mle}:
      better = Bool.or(U32.is_gt(w, mw), Bool.and(U32.is_eq(w, mw), U32.is_gt(mle, e)))
      ra_evict_fin(vd, Bool.and(found, better), mr, mvid, v, s, e, w, rm, pl, sp)
def ra_put_cross(ev: RaEvictRes, cr: List<&2, RaSlot>) -> RaAllocSt:
  match ev:
    case RaEvictRes{rm, ce2, sp}: RaAllocSt{rm, ce2, cr, sp}
def ra_put_nc(ev: RaEvictRes, ce: List<&2, RaSlot>) -> RaAllocSt:
  match ev:
    case RaEvictRes{rm, cr2, sp}: RaAllocSt{rm, ce, cr2, sp}
def ra_evict_nc_pick(pick_ce: Bool, vd: Nat, me: RaMin, mc: RaMin, v: U32, s: U32, e: U32, w: U32, rm: RaVec<U32>, ce: List<&2, RaSlot>, cr: List<&2, RaSlot>, sp: U32) -> RaAllocSt:
  match pick_ce:
    case True{}: ra_put_cross(ra_evict_pool(vd, me, v, s, e, w, rm, ce, sp), cr)
    case False{}: ra_put_nc(ra_evict_pool(vd, mc, v, s, e, w, rm, cr, sp), ce)
def ra_evict_ce_or_cr(vd: Nat, me: RaMin, mc: RaMin, v: U32, s: U32, e: U32, w: U32, rm: RaVec<U32>, ce: List<&2, RaSlot>, cr: List<&2, RaSlot>, sp: U32) -> RaAllocSt:
  match me mc:
    case RaMin{+fe, re, ve, se, +we, +lee} RaMin{+fc, rc, vc, sc, +wc, +lec}:
      better_e = Bool.or(U32.is_lt(we, wc), Bool.and(U32.is_eq(we, wc), U32.is_gt(lee, lec)))
      pick_ce = Bool.and(fe, Bool.or(Bool.not(fc), better_e))
      ra_evict_nc_pick(pick_ce, vd, RaMin{fe, re, ve, se, we, lee}, RaMin{fc, rc, vc, sc, wc, lec}, v, s, e, w, rm, ce, cr, sp)

def ra_assign_cross_fin(vd: Nat, tr: RaTry, +v: U32, s: U32, e: U32, w: U32, rm: RaVec<U32>, cr: List<&2, RaSlot>, sp: U32) -> RaAllocSt:
  match tr:
    case RaTry{True{}, r, ce2}: RaAllocSt{ra_vec_set(U32, vd, v, r, rm), ce2, cr, sp}
    case RaTry{False{}, _, +ce2}: ra_put_cross(ra_evict_pool(vd, ra_find_min_go(ce2, RaMin{False{}, 0, 0, 0, 0, 0}), v, s, e, w, rm, ce2, sp), cr)
def ra_assign_cross_one(+vd: Nat, hints: RaVec<U32>, iv: RaIv, st: RaAllocSt) -> RaAllocSt:
  match iv st:
    case RaIv{+v, +s, +e, +w, _} RaAllocSt{+rm, ce, cr, sp}:
      ra_assign_cross_fin(vd, ra_try_pool_pref(vd, hints, rm, ce, False{}, True{}, v, s, e, w), v, s, e, w, rm, cr, sp)
def ra_assign_cross(+vd: Nat, +hints: RaVec<U32>, xs: List<&2, RaIv>, st: RaAllocSt) -> RaAllocSt:
  match xs:
    case Nil{}: st
    case Con{iv, t}: ra_assign_cross(vd, hints, t, ra_assign_cross_one(vd, hints, iv, st))

def ra_assign_nc_s3(vd: Nat, tr2: RaTry, +v: U32, s: U32, e: U32, w: U32, rm: RaVec<U32>, +cr2: List<&2, RaSlot>, sp: U32) -> RaAllocSt:
  match tr2:
    case RaTry{True{}, r, ce2}: RaAllocSt{ra_vec_set(U32, vd, v, r, rm), ce2, cr2, sp}
    case RaTry{False{}, _, +ce2}:
      me = ra_find_min_go(ce2, RaMin{False{}, 0, 0, 0, 0, 0})
      mc = ra_find_min_go(cr2, RaMin{False{}, 0, 0, 0, 0, 0})
      ra_evict_ce_or_cr(vd, me, mc, v, s, e, w, rm, ce2, cr2, sp)
def ra_assign_nc_s2(vd: Nat, tr_p: RaTry, +v: U32, +s: U32, +e: U32, +w: U32, rm: RaVec<U32>, cr2: List<&2, RaSlot>, sp: U32) -> RaAllocSt:
  match tr_p:
    case RaTry{True{}, r, ce2}: RaAllocSt{ra_vec_set(U32, vd, v, r, rm), ce2, cr2, sp}
    case RaTry{False{}, _, ce2}: ra_assign_nc_s3(vd, ra_try_pool(ce2, v, s, e, w), v, s, e, w, rm, cr2, sp)
def ra_assign_nc_s1(+vd: Nat, hints: RaVec<U32>, tr1: RaTry, +v: U32, +s: U32, +e: U32, +w: U32, +rm: RaVec<U32>, ce: List<&2, RaSlot>, sp: U32) -> RaAllocSt:
  match tr1:
    case RaTry{True{}, r, cr2}: RaAllocSt{ra_vec_set(U32, vd, v, r, rm), ce, cr2, sp}
    case RaTry{False{}, _, cr2}: ra_assign_nc_s2(vd, ra_try_pool_pref(vd, hints, rm, ce, True{}, False{}, v, s, e, w), v, s, e, w, rm, cr2, sp)
def ra_assign_nc_one(+vd: Nat, +hints: RaVec<U32>, iv: RaIv, st: RaAllocSt) -> RaAllocSt:
  match iv st:
    case RaIv{+v, +s, +e, +w, _} RaAllocSt{+rm, ce, cr, sp}:
      ra_assign_nc_s1(vd, hints, ra_try_pool_pref(vd, hints, rm, cr, False{}, True{}, v, s, e, w), v, s, e, w, rm, ce, sp)
def ra_assign_nocross(+vd: Nat, +hints: RaVec<U32>, xs: List<&2, RaIv>, st: RaAllocSt) -> RaAllocSt:
  match xs:
    case Nil{}: st
    case Con{iv, t}: ra_assign_nocross(vd, hints, t, ra_assign_nc_one(vd, hints, iv, st))

def ra_used_callee(pool: List<&2, RaSlot>) -> List<&2, U32>:
  match pool:
    case Nil{}: Nil{}
    case Con{RaSlot{_, _, _, _, _, False{}}, t}: ra_used_callee(t)
    case Con{RaSlot{r, _, _, _, _, True{}}, t}: Con{r, ra_used_callee(t)}
def ra_init_callee() -> List<&2, RaSlot>:
  Con{RaSlot{3, 0, 0, 0, 0, False{}}, Con{RaSlot{12, 0, 0, 0, 0, False{}}, Con{RaSlot{13, 0, 0, 0, 0, False{}}, Con{RaSlot{14, 0, 0, 0, 0, False{}}, Con{RaSlot{15, 0, 0, 0, 0, False{}}, Nil{}}}}}}
def ra_init_caller() -> List<&2, RaSlot>:
  Con{RaSlot{8, 0, 0, 0, 0, False{}}, Con{RaSlot{9, 0, 0, 0, 0, False{}}, Con{RaSlot{10, 0, 0, 0, 0, False{}}, Con{RaSlot{11, 0, 0, 0, 0, False{}}, Nil{}}}}}
def ra_init_leaf(arity: U32) -> List<&2, RaSlot>:
  r7 = Bool.pick(RaSlot, U32.is_lt(arity, 5), RaSlot{7, 0, 0, 0, 0, False{}}, RaSlot{7, 4294967295, 0, 0, 4294967295, True{}})
  Con{RaSlot{6, 0, 0, 0, 0, False{}}, Con{r7, Nil{}}}
def ra_init_caller_all(no_calls: Bool, arity: U32) -> List<&2, RaSlot>:
  match no_calls:
    case True{}: b5k_list_app(RaSlot, ra_init_caller(), ra_init_leaf(arity))
    case False{}: ra_init_caller()
def ra_init_xmm_go(n: Nat, +r: U32) -> List<&2, RaSlot>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{RaSlot{r, 0, 0, 0, 0, False{}}, ra_init_xmm_go(p, U32.add(r, 1))}

type RaLfSt is Data:
  RaLfSt{rmap: RaVec<U32>, callee: List<&2, RaSlot>, caller: List<&2, RaSlot>, leaf: List<&2, RaSlot>, spills: U32}
def ra_put_lf(ev: RaEvictRes, ce: List<&2, RaSlot>, cr: List<&2, RaSlot>) -> RaLfSt:
  match ev:
    case RaEvictRes{rm, lf2, sp}: RaLfSt{rm, ce, cr, lf2, sp}
def ra_put_cr(ev: RaEvictRes, ce: List<&2, RaSlot>, lf: List<&2, RaSlot>) -> RaLfSt:
  match ev:
    case RaEvictRes{rm, cr2, sp}: RaLfSt{rm, ce, cr2, lf, sp}
def ra_evict_pick(pick_lf: Bool, vd: Nat, ml: RaMin, mc: RaMin, v: U32, s: U32, e: U32, w: U32, rm: RaVec<U32>, ce: List<&2, RaSlot>, cr: List<&2, RaSlot>, lf: List<&2, RaSlot>, sp: U32) -> RaLfSt:
  match pick_lf:
    case True{}: ra_put_lf(ra_evict_pool(vd, ml, v, s, e, w, rm, lf, sp), ce, cr)
    case False{}: ra_put_cr(ra_evict_pool(vd, mc, v, s, e, w, rm, cr, sp), ce, lf)
def ra_evict_lf_or_cr(vd: Nat, ml: RaMin, mc: RaMin, v: U32, s: U32, e: U32, w: U32, rm: RaVec<U32>, ce: List<&2, RaSlot>, cr: List<&2, RaSlot>, lf: List<&2, RaSlot>, sp: U32) -> RaLfSt:
  match ml mc:
    case RaMin{+fl, rl, vl, sl, +wl, lel} RaMin{+fc, rc, vc, sc, +wc, lec}:
      pick_lf = Bool.and(fl, Bool.or(Bool.not(fc), U32.is_le(wl, wc)))
      ra_evict_pick(pick_lf, vd, RaMin{fl, rl, vl, sl, wl, lel}, RaMin{fc, rc, vc, sc, wc, lec}, v, s, e, w, rm, ce, cr, lf, sp)
def ra_assign_lf_s4(vd: Nat, tr3: RaTry, +v: U32, s: U32, e: U32, w: U32, rm: RaVec<U32>, +cr2: List<&2, RaSlot>, +lf2: List<&2, RaSlot>, sp: U32) -> RaLfSt:
  match tr3:
    case RaTry{True{}, r, ce2}: RaLfSt{ra_vec_set(U32, vd, v, r, rm), ce2, cr2, lf2, sp}
    case RaTry{False{}, _, ce2}:
      ml = ra_find_min_go(lf2, RaMin{False{}, 0, 0, 0, 0, 0})
      mc = ra_find_min_go(cr2, RaMin{False{}, 0, 0, 0, 0, 0})
      ra_evict_lf_or_cr(vd, ml, mc, v, s, e, w, rm, ce2, cr2, lf2, sp)
def ra_assign_lf_s3(+vd: Nat, hints: RaVec<U32>, tr2: RaTry, +v: U32, +s: U32, +e: U32, +w: U32, +rm: RaVec<U32>, ce: List<&2, RaSlot>, lf2: List<&2, RaSlot>, sp: U32) -> RaLfSt:
  match tr2:
    case RaTry{True{}, r, cr2}: RaLfSt{ra_vec_set(U32, vd, v, r, rm), ce, cr2, lf2, sp}
    case RaTry{False{}, _, cr2}: ra_assign_lf_s4(vd, ra_try_pool_pref(vd, hints, rm, ce, False{}, True{}, v, s, e, w), v, s, e, w, rm, cr2, lf2, sp)
def ra_assign_lf_s2(+vd: Nat, +hints: RaVec<U32>, tr1: RaTry, +v: U32, +s: U32, +e: U32, +w: U32, +rm: RaVec<U32>, ce: List<&2, RaSlot>, cr: List<&2, RaSlot>, sp: U32) -> RaLfSt:
  match tr1:
    case RaTry{True{}, r, lf2}: RaLfSt{ra_vec_set(U32, vd, v, r, rm), ce, cr, lf2, sp}
    case RaTry{False{}, _, lf2}: ra_assign_lf_s3(vd, hints, ra_try_pool_pref(vd, hints, rm, cr, False{}, True{}, v, s, e, w), v, s, e, w, rm, ce, lf2, sp)
def ra_assign_ncl_s3(vd: Nat, tr2: RaTry, +v: U32, s: U32, e: U32, w: U32, rm: RaVec<U32>, +cr2: List<&2, RaSlot>, lf: List<&2, RaSlot>, sp: U32) -> RaLfSt:
  match tr2:
    case RaTry{True{}, r, ce2}: RaLfSt{ra_vec_set(U32, vd, v, r, rm), ce2, cr2, lf, sp}
    case RaTry{False{}, _, ce2}: ra_put_cr(ra_evict_pool(vd, ra_find_min_go(cr2, RaMin{False{}, 0, 0, 0, 0, 0}), v, s, e, w, rm, cr2, sp), ce2, lf)
def ra_assign_ncl_s2(vd: Nat, tr_p: RaTry, +v: U32, +s: U32, +e: U32, +w: U32, rm: RaVec<U32>, cr2: List<&2, RaSlot>, lf: List<&2, RaSlot>, sp: U32) -> RaLfSt:
  match tr_p:
    case RaTry{True{}, r, ce2}: RaLfSt{ra_vec_set(U32, vd, v, r, rm), ce2, cr2, lf, sp}
    case RaTry{False{}, _, ce2}: ra_assign_ncl_s3(vd, ra_try_pool(ce2, v, s, e, w), v, s, e, w, rm, cr2, lf, sp)
def ra_assign_ncl_s1(+vd: Nat, hints: RaVec<U32>, tr1: RaTry, +v: U32, +s: U32, +e: U32, +w: U32, +rm: RaVec<U32>, ce: List<&2, RaSlot>, lf: List<&2, RaSlot>, sp: U32) -> RaLfSt:
  match tr1:
    case RaTry{True{}, r, cr2}: RaLfSt{ra_vec_set(U32, vd, v, r, rm), ce, cr2, lf, sp}
    case RaTry{False{}, _, cr2}: ra_assign_ncl_s2(vd, ra_try_pool_pref(vd, hints, rm, ce, True{}, False{}, v, s, e, w), v, s, e, w, rm, cr2, lf, sp)
def ra_assign_ncl_disp(is_lf: Bool, +vd: Nat, +hints: RaVec<U32>, +v: U32, +s: U32, +e: U32, +w: U32, +rm: RaVec<U32>, ce: List<&2, RaSlot>, cr: List<&2, RaSlot>, lf: List<&2, RaSlot>, sp: U32) -> RaLfSt:
  match is_lf:
    case True{}: ra_assign_lf_s2(vd, hints, ra_try_pool_pref(vd, hints, rm, lf, False{}, True{}, v, s, e, w), v, s, e, w, rm, ce, cr, sp)
    case False{}: ra_assign_ncl_s1(vd, hints, ra_try_pool_pref(vd, hints, rm, cr, False{}, True{}, v, s, e, w), v, s, e, w, rm, ce, lf, sp)
def ra_assign_ncl_one(+vd: Nat, cd: Nat, +hints: RaVec<U32>, cb: RaVec<U32>, iv: RaIv, st: RaLfSt) -> RaLfSt:
  match iv st:
    case RaIv{+v, +s, +e, +w, _} RaLfSt{+rm, ce, cr, lf, sp}:
      ra_assign_ncl_disp(ra_iv_is_leaf(cd, False{}, s, e, cb), vd, hints, v, s, e, w, rm, ce, cr, lf, sp)
def ra_assign_nc_leaf(+vd: Nat, +cd: Nat, +hints: RaVec<U32>, +cb: RaVec<U32>, xs: List<&2, RaIv>, st: RaLfSt) -> RaLfSt:
  match xs:
    case Nil{}: st
    case Con{iv, t}: ra_assign_nc_leaf(vd, cd, hints, cb, t, ra_assign_ncl_one(vd, cd, hints, cb, iv, st))
def ra_finish_lf(vd: Nat, st: RaLfSt) -> RegAllocRes:
  match st:
    case RaLfSt{rm, ce, _, _, sp}: RegAllocRes{rm, vd, ra_used_callee(ce), sp}
def ra_run_nc_leaf(+vd: Nat, cd: Nat, hints: RaVec<U32>, arity: U32, cb: RaVec<U32>, nc_s: List<&2, RaIv>, st: RaAllocSt) -> RegAllocRes:
  match st:
    case RaAllocSt{rm, ce, cr, sp}:
      ra_finish_lf(vd, ra_assign_nc_leaf(vd, cd, hints, cb, nc_s, RaLfSt{rm, ce, cr, ra_init_leaf(arity), sp}))

type RaXmmSt is Data:
  RaXmmSt{rmap: RaVec<U32>, pool: List<&2, RaSlot>, over: List<&2, RaIv>}
def ra_evict_xmm_fin(+vd: Nat, do_ev: Bool, +mr: U32, +mvid: U32, ms: U32, mw: U32, mle: U32, +v: U32, +s: U32, +e: U32, +w: U32, rm: RaVec<U32>, xp: List<&2, RaSlot>, ov: List<&2, RaIv>) -> RaXmmSt:
  match do_ev:
    case True{}:
      rm1 = ra_vec_set(U32, vd, v, mr, ra_vec_set(U32, vd, mvid, 0, rm))
      RaXmmSt{rm1, ra_replace_slot(xp, mr, v, s, e, w), Con{RaIv{mvid, ms, mle, mw, True{}}, ov}}
    case False{}: RaXmmSt{rm, xp, Con{RaIv{v, s, e, w, True{}}, ov}}
def ra_evict_xmm(vd: Nat, mn: RaMin, v: U32, s: U32, e: U32, +w: U32, rm: RaVec<U32>, xp: List<&2, RaSlot>, ov: List<&2, RaIv>) -> RaXmmSt:
  match mn:
    case RaMin{found, mr, mvid, ms, +mw, mle}:
      ra_evict_xmm_fin(vd, Bool.and(found, U32.is_gt(w, mw)), mr, mvid, ms, mw, mle, v, s, e, w, rm, xp, ov)
def ra_assign_xmm_fin(vd: Nat, tr: RaTry, +v: U32, s: U32, e: U32, w: U32, rm: RaVec<U32>, ov: List<&2, RaIv>) -> RaXmmSt:
  match tr:
    case RaTry{True{}, r, xp2}: RaXmmSt{ra_vec_set(U32, vd, v, r, rm), xp2, ov}
    case RaTry{False{}, _, +xp2}: ra_evict_xmm(vd, ra_find_min_go(xp2, RaMin{False{}, 0, 0, 0, 0, 0}), v, s, e, w, rm, xp2, ov)
def ra_assign_xmm_one(+vd: Nat, hints: RaVec<U32>, iv: RaIv, st: RaXmmSt) -> RaXmmSt:
  match iv st:
    case RaIv{+v, +s, +e, +w, _} RaXmmSt{+rm, xp, ov}:
      ra_assign_xmm_fin(vd, ra_try_pool_pref(vd, hints, rm, xp, False{}, True{}, v, s, e, w), v, s, e, w, rm, ov)
def ra_assign_xmm_ov(+vd: Nat, +hints: RaVec<U32>, xs: List<&2, RaIv>, st: RaXmmSt) -> RaXmmSt:
  match xs:
    case Nil{}: st
    case Con{iv, t}: ra_assign_xmm_ov(vd, hints, t, ra_assign_xmm_one(vd, hints, iv, st))

def ra_finish_st(vd: Nat, st1: RaAllocSt) -> RegAllocRes:
  match st1:
    case RaAllocSt{rm, ce, _, sp}: RegAllocRes{rm, vd, ra_used_callee(ce), sp}
def ra_finish_gpr(+vd: Nat, cd: Nat, +hints: RaVec<U32>, no_calls: Bool, arity: U32, cb: RaVec<U32>, rm0: RaVec<U32>, cr: List<&2, RaIv>, nc: List<&2, RaIv>) -> RegAllocRes:
  match no_calls:
    case True{}:
      nc_s = ra_msort(20n, nc)
      ra_finish_st(vd, ra_assign_nocross(vd, hints, nc_s, RaAllocSt{rm0, ra_init_callee(), ra_init_caller_all(True{}, arity), 0}))
    case False{}:
      cr_s = ra_msort(20n, cr)
      nc_s = ra_msort(20n, nc)
      st1 = ra_assign_cross(vd, hints, cr_s, RaAllocSt{rm0, ra_init_callee(), ra_init_caller(), 0})
      ra_run_nc_leaf(vd, cd, hints, arity, cb, nc_s, st1)
def ra_finish_with_xmm(+vd: Nat, cd: Nat, +hints: RaVec<U32>, no_calls: Bool, arity: U32, cb: RaVec<U32>, cr: List<&2, RaIv>, nc: List<&2, RaIv>, xst: RaXmmSt) -> RegAllocRes:
  match xst:
    case RaXmmSt{rm, _, ov}:
      ra_finish_gpr(vd, cd, hints, no_calls, arity, cb, rm, cr, b5k_list_app(RaIv, nc, ov))
def ra_finish_parts(+vd: Nat, cd: Nat, +hints: RaVec<U32>, no_calls: Bool, arity: U32, cb: RaVec<U32>, pts: RaParts) -> RegAllocRes:
  match pts:
    case RaParts{cr, Nil{}, nc}:
      ra_finish_gpr(vd, cd, hints, no_calls, arity, cb, RVEmpty{}, cr, nc)
    case RaParts{cr, xm, nc}:
      xm_s = ra_msort(20n, xm)
      xst = ra_assign_xmm_ov(vd, hints, xm_s, RaXmmSt{RVEmpty{}, ra_init_xmm_go(14n, 22), Nil{}})
      ra_finish_with_xmm(vd, cd, hints, no_calls, arity, cb, cr, nc, xst)
def ra_finish_scan(+vd: Nat, +cd: Nat, track_f: Bool, +arity: U32, total: U32, scan: RaScan) -> RegAllocRes:
  match scan:
    case RaScan{ivs, _, cb, +nc, es, f32s, nf32s, hints, _, idx}:
      +no_calls = U32.is_zero(nc)
      +cb1 = ra_rec_cb(cd, Bool.not(no_calls), idx, nc, cb)
      ra_finish_parts(vd, cd, hints, no_calls, arity, cb1, ra_collect_ivs(vd, cd, track_f, arity, U32.to_nat(total), 0, ivs, cb1, es, f32s, nf32s, RaParts{Nil{}, Nil{}, Nil{}}))
def ra_vd_of(+tot: U32) -> Nat:
  Bool.pick(Nat, U32.is_le(tot, 64), 3n, Bool.pick(Nat, U32.is_le(tot, 256), 4n, Bool.pick(Nat, U32.is_le(tot, 1024), 5n, 8n)))
def ra_ops_cnt(ops: List<&2, IrOp>, acc: U32) -> U32:
  match ops:
    case Nil{}: acc
    case Con{_, t}: ra_ops_cnt(t, U32.add(acc, 1))
def ra_blks_cnt(blks: List<&2, IrBlock>, acc: U32) -> U32:
  match blks:
    case Nil{}: acc
    case Con{IrBlock{_, ops, _}, t}: ra_blks_cnt(t, ra_ops_cnt(ops, U32.add(acc, 1)))
def b5k_regalloc(fn: IrFn) -> RegAllocRes:
  match fn:
    case IrFn{fid, _, +arity, +nregs, _, _, _, +blocks}:
      +hf = ra_blks_has_f32(blocks)
      +tot = U32.max(nregs, arity)
      +vd = ra_vd_of(tot)
      +nops = U32.add(ra_blks_cnt(blocks, 2), 2)
      +cd = Bool.pick(Nat, U32.is_le(nops, 250), 4n, Bool.pick(Nat, U32.is_le(nops, 1000), 5n, 8n))
      ivs0 = ra_init_params(vd, U32.to_nat(arity), 0, RVEmpty{})
      scan = ra_scan_blks(vd, cd, hf, fid, blocks, RaScan{ivs0, RVEmpty{}, RVEmpty{}, 0, Nil{}, RVEmpty{}, RVEmpty{}, RVEmpty{}, RVEmpty{}, 1})
      ra_finish_scan(vd, cd, hf, arity, tot, scan)

# Part 2: Typed X64Inst Peephole Optimizer (Short-Circuiting)
def peep_is_caller_scratch(+r: U32) -> Bool:
  Bool.or(Bool.or(U32.is_eq(r, 1), U32.is_eq(r, 2)),
  Bool.or(Bool.or(U32.is_eq(r, 6), U32.is_eq(r, 7)),
          Bool.and(U32.is_ge(r, 8), U32.is_le(r, 11))))

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
    case XPush{rg}: Bool.or(U32.is_eq(rg, r), U32.is_eq(r, 4))
    case XPop{_}: U32.is_eq(r, 4)
    case XSubRsp{_}: U32.is_eq(r, 4)
    case XAddRsp{_}: U32.is_eq(r, 4)
    case XXmmRR{_, _, _}: False{}
    case XXmmLoad{_, b, _}: U32.is_eq(b, r)
    case XXmmStore{b, _, _}: U32.is_eq(b, r)
    case XCvt{+op, _, s}: Bool.and(Bool.or(U32.is_eq(op, 0), U32.is_eq(op, 2)), U32.is_eq(s, r))
    case _: True{}

def peep_dead_go(fuel: Nat, st: U32, +r: U32, xs: List<&2, X64Inst>) -> Bool:
  match fuel st xs:
    case _ 1 _: True{}
    case _ 2 _: False{}
    case 0n _ _: False{}
    case _ _ Nil{}: False{}
    case 1n+p _ Con{+h, t}:
      ns = Bool.pick(U32, peep_kills_reg(r, h), 1, Bool.pick(U32, peep_reads_reg(r, h), 2, 0))
      peep_dead_go(p, ns, r, t)
def peep_dead_reg(fuel: Nat, r: U32, xs: List<&2, X64Inst>) -> Bool:
  peep_dead_go(fuel, 0, r, xs)
def peep_and_dead(cond: Bool, fuel: Nat, r: U32, t: List<&2, X64Inst>) -> Bool:
  match cond:
    case False{}: False{}
    case True{}: peep_dead_reg(fuel, r, t)

def peep_uses_flags(inst: X64Inst) -> Bool:
  match inst:
    case XJcc{_, _}: True{}
    case XSetcc{_, _}: True{}
    case _: False{}
def peep_preserves_flags(inst: X64Inst) -> Bool:
  match inst:
    case XMovRR{_, _}: True{}
    case XMovRI32{_, _}: True{}
    case XMovRI64{_, _, _}: True{}
    case XLoad{_, _, _}: True{}
    case XStore{_, _, _}: True{}
    case XLeaRip{_, _}: True{}
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
      ns = Bool.pick(U32, peep_uses_flags(h), 1, Bool.pick(U32, peep_preserves_flags(h), 0, 2))
      peep_fl_go(p, ns, t)
def peep_flags_live(fuel: Nat, xs: List<&2, X64Inst>) -> Bool:
  peep_fl_go(fuel, 0, xs)
def peep_and_nflags(cond: Bool, fuel: Nat, t: List<&2, X64Inst>) -> Bool:
  match cond:
    case False{}: False{}
    case True{}: Bool.not(peep_flags_live(fuel, t))

def peep_dst_ok(+dst: U32, b: U32, r: U32) -> Bool:
  Bool.and(U32.is_ne(dst, b), U32.is_ne(dst, r))
def peep_no_alias(inst: X64Inst, +b: U32, d: U32, +r: U32) -> Bool:
  match inst:
    case XMovRR{dst, _}: peep_dst_ok(dst, b, r)
    case XMovRI32{dst, _}: peep_dst_ok(dst, b, r)
    case XMovRI64{dst, _, _}: peep_dst_ok(dst, b, r)
    case XLeaRip{dst, _}: peep_dst_ok(dst, b, r)
    case XLoad{dst, _, _}: peep_dst_ok(dst, b, r)
    case XAluRR{_, dst, _}: peep_dst_ok(dst, b, r)
    case XAluRI{_, dst, _}: peep_dst_ok(dst, b, r)
    case XShift{_, dst, _, _}: peep_dst_ok(dst, b, r)
    case XMul{dst, _}: peep_dst_ok(dst, b, r)
    case XSetcc{_, dst}: peep_dst_ok(dst, b, r)
    case XStore{sb, sd, _}: Bool.and(Bool.and(U32.is_eq(b, 5), U32.is_eq(sb, 5)), U32.is_ne(sd, d))
    case XCmpRR{_, _}: True{}
    case XCmpRI{_, _}: True{}
    case XTestRR{_, _}: True{}
    case XXmmRR{_, _, _}: True{}
    case XXmmLoad{_, _, _}: True{}
    case _: False{}

def peep_is_jmp(inst: X64Inst) -> Bool:
  match inst:
    case XJmp{_}: True{}
    case _: False{}
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
    case False{} _: False{}
    case True{} Nil{}: False{}
    case True{} Con{+nxt, t}: Bool.or(peep_is_jmp(nxt), peep_dead_reg(4n, 0, Con{nxt, t}))
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
def peep_dead_after_jcc(+d: U32, lbl: U32, +rest: List<&2, X64Inst>) -> Bool:
  Bool.or(peep_dead_after_fin(U32.is_zero(d), rest), Bool.and(peep_dead_reg(8n, d, peep_skip_lbl(rest)), peep_dead_at_lbl(16n, False{}, lbl, d, rest)))
def peep_fuse_jcc(+cc: U32, jcc: U32) -> U32:
  Bool.pick(U32, U32.is_eq(jcc, 4), U32.xor(cc, 1), cc)
def peep_is_z_or_nz(+jcc: U32) -> Bool:
  Bool.or(U32.is_eq(jcc, 4), U32.is_eq(jcc, 5))

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
    case Con{XLabel{+id}, Con{XRet{}, t}}:
      peep_build_lbls(Con{XRet{}, t}, peep_set_lbl(U32.is_lt(id, 65536), id, 1, st))
    case Con{XLabel{+id}, Con{XJmp{+tgt}, t}}:
      ok = Bool.and(Bool.and(U32.is_lt(id, 65536), U32.is_lt(tgt, 65536)), U32.is_ne(id, tgt))
      peep_build_lbls(Con{XJmp{tgt}, t}, peep_set_lbl(ok, id, U32.add(tgt, 2), st))
    case Con{XLabel{+id}, Con{XLabel{+id2}, t}}:
      ok = Bool.and(Bool.and(U32.is_lt(id, 65536), U32.is_lt(id2, 65536)), U32.is_ne(id, id2))
      peep_build_lbls(Con{XLabel{id2}, t}, peep_set_lbl(ok, id, U32.add(id2, 2), st))
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
def peep_resolve_lbl(fuel: Nat, tgt: U32, tbl: RaVec<U32>) -> U32:
  peep_res_go(fuel, False{}, 0, tgt, tbl)
def peep_thread_jmp(+res: U32) -> X64Inst:
  Bool.pick(X64Inst, U32.is_eq(res, 1), XRet{}, XJmp{U32.sub(res, 2)})
def peep_thread_jcc(cc: U32, orig: U32, +res: U32) -> X64Inst:
  XJcc{cc, Bool.pick(U32, U32.is_ge(res, 2), U32.sub(res, 2), orig)}
def peep_thread_go(insts: List<&2, X64Inst>, +tbl: RaVec<U32>, acc: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match insts:
    case Nil{}: b5k_list_rev(X64Inst, acc)
    case Con{XJmp{tgt}, t}: peep_thread_go(t, tbl, Con{peep_thread_jmp(peep_resolve_lbl(4n, tgt, tbl)), acc})
    case Con{XJcc{cc, +tgt}, t}: peep_thread_go(t, tbl, Con{peep_thread_jcc(cc, tgt, peep_resolve_lbl(4n, tgt, tbl)), acc})
    case Con{h, t}: peep_thread_go(t, tbl, Con{h, acc})
def peep_thread_fin(insts: List<&2, X64Inst>, st: PeepLbls) -> List<&2, X64Inst>:
  match st:
    case PeepLbls{_, False{}}: insts
    case PeepLbls{tbl, True{}}: peep_thread_go(insts, tbl, Nil{})
def peep_thread(+insts: List<&2, X64Inst>) -> List<&2, X64Inst>:
  peep_thread_fin(insts, peep_build_lbls(insts, PeepLbls{RVEmpty{}, False{}}))

# Peephole Rewrite Rules
type PeepSt is Data:
  PeepSt{xs: List<&2, X64Inst>, acc: List<&2, X64Inst>}
def peep_drop_dead(dead: Bool, inst: X64Inst, rest: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match dead:
    case True{}: PeepSt{rest, acc}
    case False{}: PeepSt{rest, Con{inst, acc}}

def peep_zero_mov_go(dead: Bool, +r1: U32, +imm: U32, +rest: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match dead:
    case True{}: PeepSt{rest, acc}
    case False{}:
      use_xor = peep_and_nflags(U32.is_zero(imm), 3n, rest)
      PeepSt{rest, Con{Bool.pick(X64Inst, use_xor, XAluRR{7, r1, r1}, XMovRI32{r1, imm}), acc}}
def peep_zero_mov(dlim: Nat, +r1: U32, imm: U32, +rest: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  peep_zero_mov_go(peep_dead_reg(dlim, r1, rest), r1, imm, rest, acc)
def peep_fwd(ok: Bool, new_inst: X64Inst, old1: X64Inst, old2: X64Inst, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t2, Con{new_inst, acc}}
    case False{}: PeepSt{Con{old2, t2}, Con{old1, acc}}
def peep_fwd2(ok: Bool, n1: X64Inst, n2: X64Inst, o1: X64Inst, o2: X64Inst, o3: X64Inst, t3: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t3, Con{n2, Con{n1, acc}}}
    case False{}: PeepSt{Con{o2, Con{o3, t3}}, Con{o1, acc}}
def peep_fwd_alu(ok: Bool, same: Bool, r2: U32, r0: U32, n2: X64Inst, o1: X64Inst, o2: X64Inst, o3: X64Inst, t3: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok same:
    case True{} True{}: PeepSt{t3, Con{n2, acc}}
    case True{} False{}: PeepSt{t3, Con{n2, Con{XMovRR{r2, r0}, acc}}}
    case False{} _: PeepSt{Con{o2, Con{o3, t3}}, Con{o1, acc}}

def peep_mov_next(+r1: U32, +r0: U32, t1: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match t1:
    case Con{XAluRI{+op, +rd, +imm}, Con{XMovRR{+r2, +s}, +t3}}:
      c0 = Bool.and(Bool.and(U32.is_eq(rd, r1), U32.is_eq(s, r1)), U32.is_ne(r2, r1))
      ok = peep_and_dead(c0, 8n, r1, t3)
      peep_fwd_alu(ok, U32.is_eq(r2, r0), r2, r0, XAluRI{op, r2, imm}, XMovRR{r1, r0}, XAluRI{op, rd, imm}, XMovRR{r2, s}, t3, acc)
    case Con{XAluRR{+op, +rd, +rs}, Con{XMovRR{+r2, +s}, +t3}}:
      c0 = Bool.and(Bool.and(U32.is_eq(rd, r1), U32.is_eq(s, r1)), Bool.and(U32.is_ne(r2, r1), U32.is_ne(r2, rs)))
      ok = peep_and_dead(c0, 8n, r1, t3)
      peep_fwd_alu(ok, U32.is_eq(r2, r0), r2, r0, XAluRR{op, r2, rs}, XMovRR{r1, r0}, XAluRR{op, rd, rs}, XMovRR{r2, s}, t3, acc)
    case Con{XShift{+op, +rd, +amt, False{}}, Con{XMovRR{+r2, +s}, +t3}}:
      c0 = Bool.and(Bool.and(U32.is_eq(rd, r1), U32.is_eq(s, r1)), U32.is_ne(r2, r1))
      ok = peep_and_dead(c0, 8n, r1, t3)
      peep_fwd_alu(ok, U32.is_eq(r2, r0), r2, r0, XShift{op, r2, amt, False{}}, XMovRR{r1, r0}, XShift{op, rd, amt, False{}}, XMovRR{r2, s}, t3, acc)
    case Con{XStore{+b, +d, +s}, +t2}:
      ok = peep_and_dead(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, b)), 8n, r1, t2)
      peep_fwd(ok, XStore{b, d, r0}, XMovRR{r1, r0}, XStore{b, d, s}, t2, acc)
    case Con{XMovRR{+r2, +s}, +t2}:
      ok = peep_and_dead(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, r2)), 8n, r1, t2)
      peep_fwd(ok, XMovRR{r2, r0}, XMovRR{r1, r0}, XMovRR{r2, s}, t2, acc)
    case Con{XAluRR{+op, +dst, +s}, +t2}:
      ok = peep_and_dead(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, dst)), 8n, r1, t2)
      peep_fwd(ok, XAluRR{op, dst, r0}, XMovRR{r1, r0}, XAluRR{op, dst, s}, t2, acc)
    case Con{XCmpRR{+a, +b}, +t2}:
      +mb = Bool.and(U32.is_eq(r1, b), U32.is_ne(r1, a))
      +ma = Bool.and(U32.is_eq(r1, a), U32.is_ne(r1, b))
      ok = peep_and_dead(Bool.or(mb, ma), 8n, r1, t2)
      rep = Bool.pick(X64Inst, mb, XCmpRR{a, r0}, XCmpRR{r0, b})
      peep_fwd(ok, rep, XMovRR{r1, r0}, XCmpRR{a, b}, t2, acc)
    case Con{XMul{+dst, +s}, +t2}:
      ok = peep_and_dead(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, dst)), 8n, r1, t2)
      peep_fwd(ok, XMul{dst, r0}, XMovRR{r1, r0}, XMul{dst, s}, t2, acc)
    case Con{XPush{+s}, +t2}:
      ok = peep_and_dead(U32.is_eq(r1, s), 8n, r1, t2)
      peep_fwd(ok, XPush{r0}, XMovRR{r1, r0}, XPush{s}, t2, acc)
    case Con{XTestRR{+a, +b}, +t2}:
      ok = peep_and_dead(Bool.and(U32.is_eq(r1, a), U32.is_eq(r1, b)), 8n, r1, t2)
      peep_fwd(ok, XTestRR{r0, r0}, XMovRR{r1, r0}, XTestRR{a, b}, t2, acc)
    case Con{XCmpRI{+a, +imm}, +t2}:
      ok = peep_and_dead(U32.is_eq(r1, a), 8n, r1, t2)
      peep_fwd(ok, XCmpRI{r0, imm}, XMovRR{r1, r0}, XCmpRI{a, imm}, t2, acc)
    case Con{XLoad{+d, +b, +disp}, +t2}:
      ok = peep_and_dead(U32.is_eq(r1, b), 8n, r1, t2)
      peep_fwd(ok, XLoad{d, r0, disp}, XMovRR{r1, r0}, XLoad{d, b, disp}, t2, acc)
    case Con{XCvt{+op, +d, +s}, +t2}:
      ok = peep_and_dead(Bool.and(Bool.or(U32.is_eq(op, 0), U32.is_eq(op, 2)), U32.is_eq(r1, s)), 8n, r1, t2)
      peep_fwd(ok, XCvt{op, d, r0}, XMovRR{r1, r0}, XCvt{op, d, s}, t2, acc)
    case +rest: peep_drop_dead(peep_dead_reg(8n, r1, rest), XMovRR{r1, r0}, rest, acc)
def peep_mov_step(same: Bool, r1: U32, r0: U32, t1: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match same:
    case True{}: PeepSt{t1, acc}
    case False{}: peep_mov_next(r1, r0, t1, acc)

def peep_r2(drop: Bool, op: U32, d: U32, imm: U32, t: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match drop:
    case True{}: PeepSt{t, acc}
    case False{}: PeepSt{t, Con{XAluRI{op, d, imm}, acc}}
def peep_dead_st(same: Bool, b1: U32, d1: U32, r1: U32, st2: X64Inst, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match same:
    case True{}: PeepSt{Con{st2, t2}, acc}
    case False{}: PeepSt{Con{st2, t2}, Con{XStore{b1, d1, r1}, acc}}
def peep_sl_tail(ok: Bool, same_r: Bool, r2: U32, r1: U32, ld: X64Inst, t2: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ok same_r:
    case True{} True{}: t2
    case True{} False{}: Con{XMovRR{r2, r1}, t2}
    case False{} _: Con{ld, t2}
def peep_r5(same: Bool, lbl1: U32, lbl2: U32, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match same:
    case True{}: PeepSt{Con{XLabel{lbl2}, t2}, acc}
    case False{}: PeepSt{Con{XLabel{lbl2}, t2}, Con{XJmp{lbl1}, acc}}
def peep_r6a(ok: Bool, cmp: X64Inst, z1: U32, zi: U32, cc: U32, d: U32, tst: X64Inst, jcc: U32, lbl: U32, t5: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t5, Con{XJcc{peep_fuse_jcc(cc, jcc), lbl}, Con{cmp, acc}}}
    case False{}: PeepSt{Con{XMovRI32{z1, zi}, Con{XSetcc{cc, d}, Con{tst, Con{XJcc{jcc, lbl}, t5}}}}, Con{cmp, acc}}
def peep_cmp_zset(ok: Bool, cmp: X64Inst, z1: U32, zi: U32, cc: U32, +d: U32, t3: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{Con{XSetcc{cc, d}, t3}, Con{cmp, Con{XAluRR{7, d, d}, acc}}}
    case False{}: PeepSt{Con{XMovRI32{z1, zi}, Con{XSetcc{cc, d}, t3}}, Con{cmp, acc}}
def peep_r6b(ok: Bool, a: U32, b: U32, cc: U32, d: U32, tst: X64Inst, jcc: U32, lbl: U32, t4: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t4, Con{XJcc{peep_fuse_jcc(cc, jcc), lbl}, Con{XCmpRR{a, b}, acc}}}
    case False{}: PeepSt{Con{XSetcc{cc, d}, Con{tst, Con{XJcc{jcc, lbl}, t4}}}, Con{XCmpRR{a, b}, acc}}
def peep_cmp0(ok: Bool, +r: U32, imm: U32, nxt: X64Inst, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{Con{nxt, t2}, Con{XTestRR{r, r}, acc}}
    case False{}: PeepSt{Con{nxt, t2}, Con{XCmpRI{r, imm}, acc}}
def peep_imm_fwd(dlim: Nat, ok: Bool, new_inst: X64Inst, r1: U32, imm: U32, old2: X64Inst, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t2, Con{new_inst, acc}}
    case False{}: peep_zero_mov(dlim, r1, imm, Con{old2, t2}, acc)

def peep_kills_xmm(+x: U32, inst: X64Inst) -> Bool:
  match inst:
    case XXmmRR{+op, d, s}: Bool.and(Bool.or(U32.is_eq(op, 7), U32.is_eq(op, 4)), Bool.and(U32.is_eq(d, x), U32.is_ne(s, x)))
    case XXmmLoad{d, _, _}: U32.is_eq(d, x)
    case XCvt{+op, d, _}: Bool.and(Bool.or(U32.is_eq(op, 0), U32.is_eq(op, 2)), U32.is_eq(d, x))
    case _: False{}
def peep_reads_xmm(+x: U32, inst: X64Inst) -> Bool:
  match inst:
    case XXmmRR{+op, d, s}:
      Bool.or(U32.is_eq(s, x), Bool.and(Bool.and(U32.is_ne(op, 7), U32.is_ne(op, 4)), U32.is_eq(d, x)))
    case XXmmLoad{_, _, _}: False{}
    case XXmmStore{_, _, s}: U32.is_eq(s, x)
    case XCvt{+op, _, s}: Bool.and(Bool.or(U32.is_eq(op, 1), U32.is_eq(op, 3)), U32.is_eq(s, x))
    case XMovRR{_, _}: False{}
    case XMovRI32{_, _}: False{}
    case XMovRI64{_, _, _}: False{}
    case XLoad{_, _, _}: False{}
    case XStore{_, _, _}: False{}
    case XLeaRip{_, _}: False{}
    case XAluRR{_, _, _}: False{}
    case XAluRI{_, _, _}: False{}
    case XShift{_, _, _, _}: False{}
    case XMul{_, _}: False{}
    case XCmpRR{_, _}: False{}
    case XCmpRI{_, _}: False{}
    case XTestRR{_, _}: False{}
    case XSetcc{_, _}: False{}
    case XPush{_}: False{}
    case XPop{_}: False{}
    case XSubRsp{_}: False{}
    case XAddRsp{_}: False{}
    case _: True{}
def peep_dead_xmm_go(fuel: Nat, st: U32, +x: U32, xs: List<&2, X64Inst>) -> Bool:
  match fuel st xs:
    case _ 1 _: True{}
    case _ 2 _: False{}
    case 0n _ _: False{}
    case _ _ Nil{}: False{}
    case 1n+p _ Con{+h, t}:
      ns = Bool.pick(U32, peep_kills_xmm(x, h), 1, Bool.pick(U32, peep_reads_xmm(x, h), 2, 0))
      peep_dead_xmm_go(p, ns, x, t)
def peep_and_dead_xmm(cond: Bool, fuel: Nat, x: U32, t: List<&2, X64Inst>) -> Bool:
  match cond:
    case False{}: False{}
    case True{}: peep_dead_xmm_go(fuel, 0, x, t)
def peep_xmm_mov_next(+x1: U32, +x0: U32, t1: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match t1:
    case Con{XXmmRR{+op, +dst, +s}, +t2}:
      ok = peep_and_dead_xmm(Bool.and(U32.is_eq(x1, s), U32.is_ne(x1, dst)), 8n, x1, t2)
      peep_fwd(ok, XXmmRR{op, dst, x0}, XXmmRR{7, x1, x0}, XXmmRR{op, dst, s}, t2, acc)
    case Con{XXmmStore{+b, +d, +s}, +t2}:
      ok = peep_and_dead_xmm(U32.is_eq(x1, s), 8n, x1, t2)
      peep_fwd(ok, XXmmStore{b, d, x0}, XXmmRR{7, x1, x0}, XXmmStore{b, d, s}, t2, acc)
    case Con{XCvt{+op, +dst, +s}, +t2}:
      ok = peep_and_dead_xmm(Bool.and(Bool.or(U32.is_eq(op, 1), U32.is_eq(op, 3)), U32.is_eq(x1, s)), 8n, x1, t2)
      peep_fwd(ok, XCvt{op, dst, x0}, XXmmRR{7, x1, x0}, XCvt{op, dst, s}, t2, acc)
    case rest: PeepSt{rest, Con{XXmmRR{7, x1, x0}, acc}}
def peep_xmm_mov_step(same: Bool, x1: U32, x0: U32, t1: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match same:
    case True{}: PeepSt{t1, acc}
    case False{}: peep_xmm_mov_next(x1, x0, t1, acc)
def peep_xsl_tail(ok: Bool, same_x: Bool, x2: U32, x1: U32, ld: X64Inst, t2: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match ok same_x:
    case True{} True{}: t2
    case True{} False{}: Con{XXmmRR{7, x2, x1}, t2}
    case False{} _: Con{ld, t2}
def peep_inv_jcc(same: Bool, cc: U32, lbl1: U32, lbl2: U32, lbl3: U32, t3: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match same:
    case True{}: PeepSt{Con{XLabel{lbl3}, t3}, Con{XJcc{U32.xor(cc, 1), lbl2}, acc}}
    case False{}: PeepSt{Con{XJmp{lbl2}, Con{XLabel{lbl3}, t3}}, Con{XJcc{cc, lbl1}, acc}}
def peep_drop_jcc(same: Bool, cc: U32, lbl1: U32, lbl2: U32, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match same:
    case True{}: PeepSt{Con{XLabel{lbl2}, t2}, acc}
    case False{}: PeepSt{Con{XLabel{lbl2}, t2}, Con{XJcc{cc, lbl1}, acc}}
def peep_is_u32_cc(+cc: U32) -> Bool:
  Bool.and(U32.is_ge(cc, 4), U32.is_le(cc, 7))
def peep_next_u32_cc(xs: List<&2, X64Inst>) -> Bool:
  match xs:
    case Con{XJcc{cc, _}, _}: peep_is_u32_cc(cc)
    case Con{XSetcc{cc, _}, _}: peep_is_u32_cc(cc)
    case _: False{}
def peep_drop_mask(ok: Bool, keep: X64Inst, s1: X64Inst, s2: X64Inst, t3: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t3, Con{keep, acc}}
    case False{}: PeepSt{Con{s1, Con{s2, t3}}, Con{keep, acc}}
def peep_drop_pre_mask(ok: Bool, s1: X64Inst, s2: X64Inst, keep: X64Inst, t3: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{Con{keep, t3}, acc}
    case False{}: PeepSt{Con{s2, Con{keep, t3}}, Con{s1, acc}}

def peep_step(dlim: Nat, h: X64Inst, t: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match h t:
    case XMovRR{+r1, +r0} t1: peep_mov_step(U32.is_eq(r1, r0), r1, r0, t1, acc)
    case XXmmRR{7, +x0, +xa} Con{XXmmRR{+op, +xd, +xs}, Con{XXmmRR{7, +x2, +s}, +t3}}:
      c0 = Bool.and(Bool.and(U32.is_lt(op, 4), U32.is_eq(xd, x0)), Bool.and(U32.is_eq(s, x0), U32.is_ne(x2, x0)))
      c1 = Bool.and(c0, Bool.or(U32.is_eq(xs, x0), U32.is_ne(x2, xs)))
      ok = peep_and_dead_xmm(c1, 8n, x0, t3)
      xs2 = Bool.pick(U32, U32.is_eq(xs, x0), x2, xs)
      peep_fwd2(ok, XXmmRR{7, x2, xa}, XXmmRR{op, x2, xs2}, XXmmRR{7, x0, xa}, XXmmRR{op, xd, xs}, XXmmRR{7, x2, s}, t3, acc)
    case XXmmRR{7, +x1, +x0} t1: peep_xmm_mov_step(U32.is_eq(x1, x0), x1, x0, t1, acc)
    case XXmmRR{4, +x0, +x1} Con{XXmmRR{7, +x2, +s}, +t2}:
      ok = peep_and_dead_xmm(Bool.and(U32.is_eq(x0, s), U32.is_ne(x0, x2)), 8n, x0, t2)
      peep_fwd(ok, XXmmRR{4, x2, x1}, XXmmRR{4, x0, x1}, XXmmRR{7, x2, s}, t2, acc)
    case XXmmLoad{+x0, +b, +d} Con{XXmmRR{+op, +xd, +xs}, Con{XXmmRR{7, +x2, +s}, +t3}}:
      c0 = Bool.and(Bool.and(U32.is_lt(op, 4), U32.is_eq(xd, x0)), Bool.and(U32.is_eq(s, x0), U32.is_ne(x2, x0)))
      c1 = Bool.and(c0, Bool.or(U32.is_eq(xs, x0), U32.is_ne(x2, xs)))
      ok = peep_and_dead_xmm(c1, 8n, x0, t3)
      xs2 = Bool.pick(U32, U32.is_eq(xs, x0), x2, xs)
      peep_fwd2(ok, XXmmLoad{x2, b, d}, XXmmRR{op, x2, xs2}, XXmmLoad{x0, b, d}, XXmmRR{op, xd, xs}, XXmmRR{7, x2, s}, t3, acc)
    case XXmmLoad{+x1, +b1, +d1} Con{XXmmLoad{+x2, +b2, +d2}, t2}:
      ok = Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2))
      PeepSt{peep_xsl_tail(ok, U32.is_eq(x1, x2), x2, x1, XXmmLoad{x2, b2, d2}, t2), Con{XXmmLoad{x1, b1, d1}, acc}}
    case XXmmLoad{+x0, +b, +d} Con{XXmmRR{7, +x2, +s}, +t2}:
      ok = peep_and_dead_xmm(Bool.and(U32.is_eq(x0, s), U32.is_ne(x0, x2)), 8n, x0, t2)
      peep_fwd(ok, XXmmLoad{x2, b, d}, XXmmLoad{x0, b, d}, XXmmRR{7, x2, s}, t2, acc)
    case XCvt{+op, +x0, +g} Con{XXmmRR{7, +x2, +s}, +t2}:
      ok = peep_and_dead_xmm(Bool.and(Bool.or(U32.is_eq(op, 0), U32.is_eq(op, 2)), Bool.and(U32.is_eq(x0, s), U32.is_ne(x0, x2))), 8n, x0, t2)
      peep_fwd(ok, XCvt{op, x2, g}, XCvt{op, x0, g}, XXmmRR{7, x2, s}, t2, acc)
    case XXmmStore{+b1, +d1, +x1} Con{XXmmLoad{+x2, +b2, +d2}, t2}:
      ok = Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2))
      PeepSt{peep_xsl_tail(ok, U32.is_eq(x1, x2), x2, x1, XXmmLoad{x2, b2, d2}, t2), Con{XXmmStore{b1, d1, x1}, acc}}
    case XAluRI{5, +d, +imm} Con{XShift{8, +r2, 32, False{}}, Con{XShift{9, +r3, 32, False{}}, +t3}}:
      ok = peep_and_nflags(Bool.and(Bool.and(U32.is_eq(d, r2), U32.is_eq(d, r3)), U32.is_lt(imm, 2147483648)), 3n, t3)
      peep_drop_mask(ok, XAluRI{5, d, imm}, XShift{8, r2, 32, False{}}, XShift{9, r3, 32, False{}}, t3, acc)
    case XShift{9, +d, +amt, False{}} Con{XShift{8, +r2, 32, False{}}, Con{XShift{9, +r3, 32, False{}}, +t3}}:
      ok = peep_and_nflags(Bool.and(Bool.and(U32.is_eq(d, r2), U32.is_eq(d, r3)), U32.is_ge(amt, 32)), 3n, t3)
      peep_drop_mask(ok, XShift{9, d, amt, False{}}, XShift{8, r2, 32, False{}}, XShift{9, r3, 32, False{}}, t3, acc)
    case XShift{8, +r1, 32, False{}} Con{XShift{9, +r2, 32, False{}}, Con{XAluRI{5, +r3, +imm}, +t3}}:
      ok = Bool.and(Bool.and(U32.is_eq(r1, r2), U32.is_eq(r1, r3)), U32.is_lt(imm, 2147483648))
      peep_drop_pre_mask(ok, XShift{8, r1, 32, False{}}, XShift{9, r2, 32, False{}}, XAluRI{5, r3, imm}, t3, acc)
    case XShift{8, +r1, 32, False{}} Con{XShift{9, +r2, 32, False{}}, Con{XMovRI32{+mr, +mi}, Con{XAluRI{5, +r3, +imm}, +t4}}}:
      ok = Bool.and(Bool.and(U32.is_eq(r1, r2), U32.is_eq(r1, r3)), Bool.and(U32.is_ne(mr, r1), U32.is_lt(imm, 2147483648)))
      peep_drop_pre_mask(ok, XShift{8, r1, 32, False{}}, XShift{9, r2, 32, False{}}, XMovRI32{mr, mi}, Con{XAluRI{5, r3, imm}, t4}, acc)
    case XAluRI{+op, d, +imm} +t1:
      peep_r2(peep_and_nflags(peep_is_zero_alu(op, imm), 3n, t1), op, d, imm, t1, acc)
    case XStore{+b1, +d1, r1} Con{XStore{+b2, +d2, r2}, t2}:
      peep_dead_st(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)), b1, d1, r1, XStore{b2, d2, r2}, t2, acc)
    case XStore{+b1, +d1, +r1} Con{XLoad{+r2, +b2, +d2}, t2}:
      ok = Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2))
      PeepSt{peep_sl_tail(ok, U32.is_eq(r1, r2), r2, r1, XLoad{r2, b2, d2}, t2), Con{XStore{b1, d1, r1}, acc}}
    case XStore{+b1, +d1, +r1} Con{+m1, Con{XLoad{+r2, +b2, +d2}, t2}}:
      ok = Bool.and(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)), peep_no_alias(m1, b1, d1, r1))
      PeepSt{Con{m1, peep_sl_tail(ok, U32.is_eq(r1, r2), r2, r1, XLoad{r2, b2, d2}, t2)}, Con{XStore{b1, d1, r1}, acc}}
    case XStore{+b1, +d1, +r1} Con{+m1, Con{+m2, Con{XLoad{+r2, +b2, +d2}, t2}}}:
      ok = Bool.and(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)),
           Bool.and(peep_no_alias(m1, b1, d1, r1), peep_no_alias(m2, b1, d1, r1)))
      PeepSt{Con{m1, Con{m2, peep_sl_tail(ok, U32.is_eq(r1, r2), r2, r1, XLoad{r2, b2, d2}, t2)}}, Con{XStore{b1, d1, r1}, acc}}
    case XLoad{+r1, +b1, +d1} Con{XLoad{+r2, +b2, +d2}, t2}:
      ok = Bool.and(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)), U32.is_ne(r1, b1))
      PeepSt{peep_sl_tail(ok, U32.is_eq(r1, r2), r2, r1, XLoad{r2, b2, d2}, t2), Con{XLoad{r1, b1, d1}, acc}}
    case XLoad{+r1, +b, +d} Con{XMovRR{+r2, +s}, +t2}:
      ok = peep_and_dead(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, r2)), 4n, r1, t2)
      peep_fwd(ok, XLoad{r2, b, d}, XLoad{r1, b, d}, XMovRR{r2, s}, t2, acc)
    case XLoad{+r1, +b1, +d1} Con{+m1, Con{XLoad{+r2, +b2, +d2}, t2}}:
      ok = Bool.and(Bool.and(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)), U32.is_ne(r1, b1)), peep_no_alias(m1, b1, d1, r1))
      PeepSt{Con{m1, peep_sl_tail(ok, U32.is_eq(r1, r2), r2, r1, XLoad{r2, b2, d2}, t2)}, Con{XLoad{r1, b1, d1}, acc}}
    case XJmp{+lbl1} Con{XLabel{+lbl2}, t2}:
      peep_r5(U32.is_eq(lbl1, lbl2), lbl1, lbl2, t2, acc)
    case XJcc{+cc, +lbl1} Con{XJmp{+lbl2}, Con{XLabel{+lbl3}, t3}}:
      peep_inv_jcc(U32.is_eq(lbl1, lbl3), cc, lbl1, lbl2, lbl3, t3, acc)
    case XJcc{+cc, +lbl1} Con{XLabel{+lbl2}, t2}:
      peep_drop_jcc(U32.is_eq(lbl1, lbl2), cc, lbl1, lbl2, t2, acc)
    case XCmpRR{a, b} Con{XMovRI32{+z1, +zi}, Con{XSetcc{+cc, +d}, Con{+tst, Con{XJcc{+jcc, +lbl}, +t5}}}}:
      ok = Bool.and(Bool.and(U32.is_eq(z1, d), U32.is_zero(zi)),
           Bool.and(Bool.and(peep_is_ztest(d, tst), peep_is_z_or_nz(jcc)), peep_dead_after_jcc(d, lbl, t5)))
      peep_r6a(ok, XCmpRR{a, b}, z1, zi, cc, d, tst, jcc, lbl, t5, acc)
    case XTestRR{a, b} Con{XMovRI32{+z1, +zi}, Con{XSetcc{+cc, +d}, Con{+tst, Con{XJcc{+jcc, +lbl}, +t5}}}}:
      ok = Bool.and(Bool.and(U32.is_eq(z1, d), U32.is_zero(zi)),
           Bool.and(Bool.and(peep_is_ztest(d, tst), peep_is_z_or_nz(jcc)), peep_dead_after_jcc(d, lbl, t5)))
      peep_r6a(ok, XTestRR{a, b}, z1, zi, cc, d, tst, jcc, lbl, t5, acc)
    case XCmpRI{a, imm} Con{XMovRI32{+z1, +zi}, Con{XSetcc{+cc, +d}, Con{+tst, Con{XJcc{+jcc, +lbl}, +t5}}}}:
      ok = Bool.and(Bool.and(U32.is_eq(z1, d), U32.is_zero(zi)),
           Bool.and(Bool.and(peep_is_ztest(d, tst), peep_is_z_or_nz(jcc)), peep_dead_after_jcc(d, lbl, t5)))
      peep_r6a(ok, XCmpRI{a, imm}, z1, zi, cc, d, tst, jcc, lbl, t5, acc)
    case XCmpRR{a, b} Con{XSetcc{+cc, +d}, Con{+tst, Con{XJcc{+jcc, +lbl}, +t4}}}:
      ok = Bool.and(Bool.and(peep_is_ztest(d, tst), peep_is_z_or_nz(jcc)), peep_dead_after_jcc(d, lbl, t4))
      peep_r6b(ok, a, b, cc, d, tst, jcc, lbl, t4, acc)
    case XCmpRR{+a, +b} Con{XMovRI32{+z1, +zi}, Con{XSetcc{+cc, +d}, t3}}:
      ok = Bool.and(Bool.and(U32.is_eq(z1, d), U32.is_zero(zi)), Bool.and(U32.is_ne(d, a), U32.is_ne(d, b)))
      peep_cmp_zset(ok, XCmpRR{a, b}, z1, zi, cc, d, t3, acc)
    case XCmpRI{+a, imm} Con{XMovRI32{+z1, +zi}, Con{XSetcc{+cc, +d}, t3}}:
      ok = Bool.and(Bool.and(U32.is_eq(z1, d), U32.is_zero(zi)), U32.is_ne(d, a))
      peep_cmp_zset(ok, XCmpRI{a, imm}, z1, zi, cc, d, t3, acc)
    case XCmpRI{r, +imm} Con{XJcc{+cc, lbl}, t2}:
      peep_cmp0(Bool.and(U32.is_zero(imm), peep_is_z_or_nz(cc)), r, imm, XJcc{cc, lbl}, t2, acc)
    case XCmpRI{r, +imm} Con{XSetcc{+cc, d}, t2}:
      peep_cmp0(Bool.and(U32.is_zero(imm), peep_is_z_or_nz(cc)), r, imm, XSetcc{cc, d}, t2, acc)
    case XMovRI32{+r1, +imm} Con{XShift{8, +r2, 32, False{}}, Con{XShift{9, +r3, 32, False{}}, +t3}}:
      ok = peep_and_nflags(Bool.and(U32.is_eq(r1, r2), U32.is_eq(r1, r3)), 3n, t3)
      peep_drop_mask(ok, XMovRI32{r1, imm}, XShift{8, r2, 32, False{}}, XShift{9, r3, 32, False{}}, t3, acc)
    case XMovRI32{+r1, +imm} Con{XMovRR{+r2, +s}, +t2}:
      ok = peep_and_dead(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, r2)), 4n, r1, t2)
      peep_imm_fwd(dlim, ok, XMovRI32{r2, imm}, r1, imm, XMovRR{r2, s}, t2, acc)
    case XMovRI32{+r1, +imm} Con{XAluRR{+op, +dst, +s}, +t2}:
      ok = peep_and_dead(Bool.and(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, dst)), U32.is_lt(imm, 2147483648)), 5n, r1, t2)
      peep_imm_fwd(dlim, ok, XAluRI{op, dst, imm}, r1, imm, XAluRR{op, dst, s}, t2, acc)
    case XMovRI32{+r1, +imm} Con{XCmpRR{+a, +b}, +t2}:
      ok = peep_and_dead(Bool.and(Bool.and(U32.is_zero(imm), Bool.and(U32.is_eq(r1, b), U32.is_ne(r1, a))), peep_next_u32_cc(t2)), 5n, r1, t2)
      peep_imm_fwd(dlim, ok, XTestRR{a, a}, r1, imm, XCmpRR{a, b}, t2, acc)
    case XMovRI32{r1, imm} t1: peep_zero_mov(dlim, r1, imm, t1, acc)
    case XMovRI64{+r1, lo, hi} +t1:
      peep_drop_dead(peep_dead_reg(dlim, r1, t1), XMovRI64{r1, lo, hi}, t1, acc)
    case XAddRsp{+a} Con{XAddRsp{+b}, +t2}:
      peep_fwd(peep_and_nflags(True{}, 3n, t2), XAddRsp{U32.add(a, b)}, XAddRsp{a}, XAddRsp{b}, t2, acc)
    case XSubRsp{+a} Con{XSubRsp{+b}, +t2}:
      peep_fwd(peep_and_nflags(True{}, 3n, t2), XSubRsp{U32.add(a, b)}, XSubRsp{a}, XSubRsp{b}, t2, acc)
    case XAddRsp{+a} +t1:
      peep_drop_dead(peep_and_nflags(U32.is_zero(a), 3n, t1), XAddRsp{a}, t1, acc)
    case XSubRsp{+a} +t1:
      peep_drop_dead(peep_and_nflags(U32.is_zero(a), 3n, t1), XSubRsp{a}, t1, acc)
    case inst rest: PeepSt{rest, Con{inst, acc}}

def peep_run(+dlim: Nat, fuel: Nat, st: PeepSt) -> List<&2, X64Inst>:
  match fuel st:
    case 0n PeepSt{_, acc}: b5k_list_rev(X64Inst, acc)
    case 1n+p PeepSt{Nil{}, acc}: b5k_list_rev(X64Inst, acc)
    case 1n+p PeepSt{Con{h, t}, acc}: peep_run(dlim, p, peep_step(dlim, h, t, acc))
def peep_pass(dlim: Nat, +insts: List<&2, X64Inst>) -> List<&2, X64Inst>:
  peep_run(dlim, U32.to_nat(b5k_list_len(X64Inst, insts)), PeepSt{insts, Nil{}})
def peep_pass2(is_big: Bool, insts: List<&2, X64Inst>) -> List<&2, X64Inst>:
  match is_big:
    case True{}: peep_pass(24n, insts)
    case False{}: peep_pass(24n, peep_pass(24n, insts))
def peep_fn(fast: Bool, f: X64Fn) -> X64Fn:
  match fast f:
    case True{} X64Fn{name, is_glob, insts}: X64Fn{name, is_glob, peep_pass(4n, insts)}
    case False{} X64Fn{name, is_glob, insts}:
      +t = peep_thread(insts)
      X64Fn{name, is_glob, peep_pass2(U32.is_gt(b5k_list_len(X64Inst, t), 1000), t)}
def b5k_peep_go(+fast: Bool, fns: List<&2, X64Fn>, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match fns:
    case Nil{}: b5k_list_rev(X64Fn, acc)
    case Con{f, t}: b5k_peep_go(fast, t, Con{peep_fn(fast, f), acc})
def b5k_peep(+fns: List<&2, X64Fn>) -> List<&2, X64Fn>:
  b5k_peep_go(U32.is_gt(b5k_list_len(X64Fn, fns), 768), fns, Nil{})
