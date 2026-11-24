# bend5k/regalloc.bend — Linear-Scan Register Allocator & Typed X64 Peephole
# ==========================================================================
# Exports:
#   - RegAllocRes, b5k_regalloc(fn: IrFn) -> RegAllocRes
#   - b5k_xmm_alloc(fn: IrFn) -> Map<&2, U32>
#   - b5k_peep(fns: List<&2, X64Fn>) -> List<&2, X64Fn>

# Dense U32 Bit-Trie (Zero String Hashing)
type RaVec<-A: Data> is Data:
  RVEmpty{}
  RVLeaf{val: A}
  RVNode{lo: RaVec<A>, hi: RaVec<A>}

def ra_vec_set_go(-A: Data, d: Nat, +idx: U32, val: A, t: RaVec<A>, is_lo: Bool) -> RaVec<A>:
  match d t is_lo:
    case 0n _ _: RVLeaf{val}
    case 1n+p RVEmpty{} True{}:
      +nxt = U32.shr(idx)
      RVNode{ra_vec_set_go(A, p, nxt, val, RVEmpty{}, U32.is_zero(U32.and(nxt, 1))), RVEmpty{}}
    case 1n+p RVEmpty{} False{}:
      +nxt = U32.shr(idx)
      RVNode{RVEmpty{}, ra_vec_set_go(A, p, nxt, val, RVEmpty{}, U32.is_zero(U32.and(nxt, 1)))}
    case 1n+p RVLeaf{_} True{}:
      +nxt = U32.shr(idx)
      RVNode{ra_vec_set_go(A, p, nxt, val, RVEmpty{}, U32.is_zero(U32.and(nxt, 1))), RVEmpty{}}
    case 1n+p RVLeaf{_} False{}:
      +nxt = U32.shr(idx)
      RVNode{RVEmpty{}, ra_vec_set_go(A, p, nxt, val, RVEmpty{}, U32.is_zero(U32.and(nxt, 1)))}
    case 1n+p RVNode{lo, hi} True{}:
      +nxt = U32.shr(idx)
      RVNode{ra_vec_set_go(A, p, nxt, val, lo, U32.is_zero(U32.and(nxt, 1))), hi}
    case 1n+p RVNode{lo, hi} False{}:
      +nxt = U32.shr(idx)
      RVNode{lo, ra_vec_set_go(A, p, nxt, val, hi, U32.is_zero(U32.and(nxt, 1)))}

def ra_vec_set(-A: Data, +idx: U32, val: A, t: RaVec<A>) -> RaVec<A>:
  ra_vec_set_go(A, 16n, idx, val, t, U32.is_zero(U32.and(idx, 1)))

def ra_vec_get_go(-A: Data, d: Nat, +idx: U32, defv: A, t: RaVec<A>, is_lo: Bool) -> A:
  match d t is_lo:
    case _ RVEmpty{} _: defv
    case _ RVLeaf{v} _: v
    case 0n RVNode{_, _} _: defv
    case 1n+p RVNode{lo, hi} True{}:
      +nxt = U32.shr(idx)
      ra_vec_get_go(A, p, nxt, defv, lo, U32.is_zero(U32.and(nxt, 1)))
    case 1n+p RVNode{lo, hi} False{}:
      +nxt = U32.shr(idx)
      ra_vec_get_go(A, p, nxt, defv, hi, U32.is_zero(U32.and(nxt, 1)))

def ra_vec_get(-A: Data, defv: A, +idx: U32, t: RaVec<A>) -> A:
  ra_vec_get_go(A, 16n, idx, defv, t, U32.is_zero(U32.and(idx, 1)))

# Part 1: Linear-Scan Register Allocator (GPR + XMM)
type RegAllocRes is Data:
  RegAllocRes{reg_map: Map<&2, U32>, used_callee: List<&2, U32>, spill_count: U32}
type RaIv is Data:
  RaIv{vid: U32, start: U32, end: U32, uses: U32, seen: Bool}
type RaEdge is Data:
  RaEdge{lstart: U32, bend: U32}
type RaScan is Data:
  RaScan{ivs: RaVec<RaIv>, blk_s: RaVec<U32>, cbef: RaVec<U32>, caft: RaVec<U32>, nc: U32, edges: List<&2, RaEdge>, f32s: RaVec<Bool>, idx: U32}

def ra_touch_upd(cur: RaIv, +v: U32, +idx: U32) -> RaIv:
  match cur:
    case RaIv{_, _, _, _, False{}}: RaIv{v, idx, idx, 1, True{}}
    case RaIv{_, s, e, u, True{}}: RaIv{v, U32.min(s, idx), U32.max(e, idx), U32.add(u, 1), True{}}
def ra_touch(+ivs: RaVec<RaIv>, +v: U32, +idx: U32) -> RaVec<RaIv>:
  cur = ra_vec_get(RaIv, RaIv{v, idx, idx, 0, False{}}, v, ivs)
  ra_vec_set(RaIv, v, ra_touch_upd(cur, v, idx), ivs)
def ra_touch_list(vs: List<&2, U32>, ivs: RaVec<RaIv>, +idx: U32) -> RaVec<RaIv>:
  match vs:
    case Nil{}: ivs
    case Con{v, t}: ra_touch_list(t, ra_touch(ivs, v, idx), idx)
def ra_init_params(n: Nat, +v: U32, ivs: RaVec<RaIv>) -> RaVec<RaIv>:
  match n:
    case 0n: ivs
    case 1n+p: ra_init_params(p, U32.add(v, 1), ra_touch(ivs, v, 0))
def ra_mark_f32(is_f: Bool, d: U32, f32s: RaVec<Bool>) -> RaVec<Bool>:
  match is_f:
    case True{}: ra_vec_set(Bool, d, True{}, f32s)
    case False{}: f32s
def ra_rec(is_call: Bool, ivs: RaVec<RaIv>, bs: RaVec<U32>, cb: RaVec<U32>, ca: RaVec<U32>, +nc: U32, es: List<&2, RaEdge>, f32s: RaVec<Bool>, +idx: U32, nxt: U32) -> RaScan:
  +nc1 = Bool.pick(U32, is_call, U32.add(nc, 1), nc)
  RaScan{ivs, bs, ra_vec_set(U32, idx, nc, cb), ra_vec_set(U32, idx, nc1, ca), nc1, es, f32s, nxt}

def ra_scan_op_go(op: IrOp, ivs: RaVec<RaIv>, bs: RaVec<U32>, cb: RaVec<U32>, ca: RaVec<U32>, nc: U32, es: List<&2, RaEdge>, +f32s: RaVec<Bool>, +idx: U32, nxt: U32) -> RaScan:
  match op:
    case IConst{d, _}: ra_rec(False{}, ra_touch(ivs, d, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case IFlt{+d, _}: ra_rec(False{}, ra_touch(ivs, d, idx), bs, cb, ca, nc, es, ra_vec_set(Bool, d, True{}, f32s), idx, nxt)
    case ICopy{+d, +s}:
      f1 = ra_mark_f32(ra_vec_get(Bool, False{}, s, f32s), d, f32s)
      ra_rec(False{}, ra_touch(ra_touch(ivs, s, idx), d, idx), bs, cb, ca, nc, es, f1, idx, nxt)
    case IBin{+d, bop, l, r}:
      f1 = ra_mark_f32(U32.is_ge(bop, 10), d, f32s)
      ra_rec(False{}, ra_touch(ra_touch(ra_touch(ivs, l, idx), r, idx), d, idx), bs, cb, ca, nc, es, f1, idx, nxt)
    case IUn{+d, +uop, s}:
      f1 = ra_mark_f32(Bool.and(U32.is_ge(uop, 2), U32.is_le(uop, 4)), d, f32s)
      ra_rec(False{}, ra_touch(ra_touch(ivs, s, idx), d, idx), bs, cb, ca, nc, es, f1, idx, nxt)
    case ICmp{d, _, l, r}: ra_rec(False{}, ra_touch(ra_touch(ra_touch(ivs, l, idx), r, idx), d, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case ICallDirect{d, _, args}: ra_rec(True{}, ra_touch(ra_touch_list(args, ivs, idx), d, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case ICallClosure{d, _, caps}: ra_rec(True{}, ra_touch(ra_touch_list(caps, ivs, idx), d, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case IApply{d, clo, arg}: ra_rec(True{}, ra_touch(ra_touch(ra_touch(ivs, clo, idx), arg, idx), d, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case ICtor{d, _, fs}: ra_rec(True{}, ra_touch(ra_touch_list(fs, ivs, idx), d, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case ITake{ds, s}: ra_rec(True{}, ra_touch_list(ds, ra_touch(ivs, s, idx), idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case ITag{d, s}: ra_rec(True{}, ra_touch(ra_touch(ivs, s, idx), d, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case IKeep{d, s}: ra_rec(True{}, ra_touch(ra_touch(ivs, s, idx), d, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case ISink{s}: ra_rec(True{}, ra_touch(ivs, s, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case IReuse{d, sl, _, fs}: ra_rec(True{}, ra_touch(ra_touch(ra_touch_list(fs, ivs, idx), sl, idx), d, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case IStatic{d, _}: ra_rec(False{}, ra_touch(ivs, d, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case IArrOp{ds, _, args}: ra_rec(True{}, ra_touch_list(ds, ra_touch_list(args, ivs, idx), idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case IAlloca{d, _}: ra_rec(False{}, ra_touch(ivs, d, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case ILoad{d, b, _}: ra_rec(False{}, ra_touch(ra_touch(ivs, b, idx), d, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case IStore{b, _, v}: ra_rec(False{}, ra_touch(ra_touch(ivs, b, idx), v, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case IFail{_}: ra_rec(True{}, ivs, bs, cb, ca, nc, es, f32s, idx, nxt)

def ra_scan_op(op: IrOp, st: RaScan) -> RaScan:
  match st:
    case RaScan{ivs, bs, cb, ca, nc, es, f32s, +idx}:
      ra_scan_op_go(op, ivs, bs, cb, ca, nc, es, f32s, idx, U32.add(idx, 1))
def ra_scan_ops(ops: List<&2, IrOp>, st: RaScan) -> RaScan:
  match ops:
    case Nil{}: st
    case Con{op, t}: ra_scan_ops(t, ra_scan_op(op, st))
def ra_add_edge_fin(is_z: Bool, s1: U32, idx: U32, es: List<&2, RaEdge>) -> List<&2, RaEdge>:
  match is_z:
    case True{}: es
    case False{}: Con{RaEdge{U32.sub(s1, 1), idx}, es}
def ra_check_edge(bs: RaVec<U32>, tgt: U32, idx: U32, es: List<&2, RaEdge>) -> List<&2, RaEdge>:
  +s1 = ra_vec_get(U32, 0, tgt, bs)
  ra_add_edge_fin(U32.is_zero(s1), s1, idx, es)
def ra_check_arms(+bs: RaVec<U32>, arms: List<&2, IrSwitchArm>, +idx: U32, es: List<&2, RaEdge>) -> List<&2, RaEdge>:
  match arms:
    case Nil{}: es
    case Con{IrArm{_, tgt}, t}: ra_check_arms(bs, t, idx, ra_check_edge(bs, tgt, idx, es))
def ra_tail_edge(same_fn: Bool, bs: RaVec<U32>, idx: U32, es: List<&2, RaEdge>) -> List<&2, RaEdge>:
  match same_fn:
    case True{}: ra_check_edge(bs, 0, idx, es)
    case False{}: es

def ra_scan_term_go(fn_fid: U32, term: IrTerm, ivs: RaVec<RaIv>, +bs: RaVec<U32>, cb: RaVec<U32>, ca: RaVec<U32>, nc: U32, es: List<&2, RaEdge>, f32s: RaVec<Bool>, +idx: U32, nxt: U32) -> RaScan:
  match term:
    case TJmp{tgt}: ra_rec(False{}, ivs, bs, cb, ca, nc, ra_check_edge(bs, tgt, idx, es), f32s, idx, nxt)
    case TBr{c, tb, eb}:
      es1 = ra_check_edge(bs, eb, idx, ra_check_edge(bs, tb, idx, es))
      ra_rec(False{}, ra_touch(ivs, c, idx), bs, cb, ca, nc, es1, f32s, idx, nxt)
    case TSwitch{sc, arms, db}:
      es1 = ra_check_edge(bs, db, idx, ra_check_arms(bs, arms, idx, es))
      ra_rec(False{}, ra_touch(ivs, sc, idx), bs, cb, ca, nc, es1, f32s, idx, nxt)
    case TRet{v}: ra_rec(False{}, ra_touch(ivs, v, idx), bs, cb, ca, nc, es, f32s, idx, nxt)
    case TTailCall{fid, args}:
      es1 = ra_tail_edge(U32.is_eq(fid, fn_fid), bs, idx, es)
      ra_rec(False{}, ra_touch_list(args, ivs, idx), bs, cb, ca, nc, es1, f32s, idx, nxt)
    case TFail{_}: ra_rec(False{}, ivs, bs, cb, ca, nc, es, f32s, idx, nxt)
def ra_scan_term(fn_fid: U32, term: IrTerm, st: RaScan) -> RaScan:
  match st:
    case RaScan{ivs, bs, cb, ca, nc, es, f32s, +idx}:
      ra_scan_term_go(fn_fid, term, ivs, bs, cb, ca, nc, es, f32s, idx, U32.add(idx, 1))
def ra_scan_blks(+fn_fid: U32, blks: List<&2, IrBlock>, st: RaScan) -> RaScan:
  match blks st:
    case Nil{} _: st
    case Con{IrBlock{bid, ops, term}, t} RaScan{ivs, bs, cb, ca, nc, es, f32s, +idx}:
      bs1 = ra_vec_set(U32, bid, U32.add(idx, 1), bs)
      st1 = ra_scan_term(fn_fid, term, ra_scan_ops(ops, RaScan{ivs, bs1, cb, ca, nc, es, f32s, idx}))
      ra_scan_blks(fn_fid, t, st1)

# Loop Back-Edge Extension & 8x Loop-Depth Weighting
def ra_ext_end_one(iv: RaIv, edge: RaEdge) -> RaIv:
  match iv edge:
    case RaIv{v, +s, +e, u, seen} RaEdge{+ls, be}:
      live_hdr = Bool.and(U32.is_le(s, ls), U32.is_ge(e, ls))
      RaIv{v, s, Bool.pick(U32, live_hdr, U32.max(e, be), e), u, seen}
def ra_ext_end(es: List<&2, RaEdge>, iv: RaIv) -> RaIv:
  match es:
    case Nil{}: iv
    case Con{edge, t}: ra_ext_end(t, ra_ext_end_one(iv, edge))
def ra_weight_one(iv: RaIv, edge: RaEdge) -> RaIv:
  match iv edge:
    case RaIv{v, +s, +e, +u, seen} RaEdge{+ls, +be}:
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
  RaParts{cross: List<&2, RaIv>, nocross: List<&2, RaIv>}
def ra_add_part_fin(is_cr: Bool, iv: RaIv, cr: List<&2, RaIv>, nc: List<&2, RaIv>) -> RaParts:
  match is_cr:
    case True{}: RaParts{Con{iv, cr}, nc}
    case False{}: RaParts{cr, Con{iv, nc}}
def ra_add_part_go(iv2: RaIv, cb: RaVec<U32>, ca: RaVec<U32>, cr: List<&2, RaIv>, nc: List<&2, RaIv>) -> RaParts:
  match iv2:
    case RaIv{v, +s, +e, u, seen}:
      is_cr = U32.is_gt(ra_vec_get(U32, 0, e, cb), ra_vec_get(U32, 0, s, ca))
      ra_add_part_fin(is_cr, RaIv{v, s, e, u, seen}, cr, nc)
def ra_add_part(iv: RaIv, cb: RaVec<U32>, ca: RaVec<U32>, +es: List<&2, RaEdge>, pts: RaParts) -> RaParts:
  match iv pts:
    case RaIv{_, _, _, _, False{}} _: pts
    case RaIv{v, s, e, u, True{}} RaParts{cr, nc}:
      iv1 = ra_ext_end(es, ra_ext_end(es, RaIv{v, s, e, u, True{}}))
      ra_add_part_go(ra_weight_edges(es, iv1), cb, ca, cr, nc)
def ra_collect_ivs(n: Nat, +v: U32, +ivs: RaVec<RaIv>, +cb: RaVec<U32>, +ca: RaVec<U32>, +es: List<&2, RaEdge>, pts: RaParts) -> RaParts:
  match n:
    case 0n: pts
    case 1n+p:
      iv = ra_vec_get(RaIv, RaIv{v, 0, 0, 0, False{}}, v, ivs)
      ra_collect_ivs(p, U32.add(v, 1), ivs, cb, ca, es, ra_add_part(iv, cb, ca, es, pts))

def ra_add_xmm_fin(is_cr: Bool, iv: RaIv, acc: List<&2, RaIv>) -> List<&2, RaIv>:
  match is_cr:
    case True{}: acc
    case False{}: Con{iv, acc}
def ra_add_xmm_go(iv2: RaIv, cb: RaVec<U32>, ca: RaVec<U32>, acc: List<&2, RaIv>) -> List<&2, RaIv>:
  match iv2:
    case RaIv{v, +s, +e, u, seen}:
      is_cr = U32.is_gt(ra_vec_get(U32, 0, e, cb), ra_vec_get(U32, 0, s, ca))
      ra_add_xmm_fin(is_cr, RaIv{v, s, e, u, seen}, acc)
def ra_add_xmm(is_f: Bool, iv: RaIv, cb: RaVec<U32>, ca: RaVec<U32>, +es: List<&2, RaEdge>, acc: List<&2, RaIv>) -> List<&2, RaIv>:
  match is_f iv:
    case False{} _: acc
    case _ RaIv{_, _, _, _, False{}}: acc
    case True{} RaIv{v, s, e, u, True{}}:
      iv1 = ra_ext_end(es, ra_ext_end(es, RaIv{v, s, e, u, True{}}))
      ra_add_xmm_go(ra_weight_edges(es, iv1), cb, ca, acc)
def ra_collect_xmm(n: Nat, +v: U32, +ivs: RaVec<RaIv>, +cb: RaVec<U32>, +ca: RaVec<U32>, +es: List<&2, RaEdge>, +f32s: RaVec<Bool>, acc: List<&2, RaIv>) -> List<&2, RaIv>:
  match n:
    case 0n: acc
    case 1n+p:
      iv = ra_vec_get(RaIv, RaIv{v, 0, 0, 0, False{}}, v, ivs)
      is_f = ra_vec_get(Bool, False{}, v, f32s)
      ra_collect_xmm(p, U32.add(v, 1), ivs, cb, ca, es, f32s, ra_add_xmm(is_f, iv, cb, ca, es, acc))

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

# Physical Register Pool Assignment (Linear Scan + Weight Eviction)
type RaSlot is Data:
  RaSlot{reg: U32, vid: U32, last_end: U32, weight: U32, used: Bool}
type RaTry is Data:
  RaTry{ok: Bool, reg: U32, pool: List<&2, RaSlot>}
type RaMin is Data:
  RaMin{found: Bool, reg: U32, vid: U32, weight: U32, last_end: U32}
type RaAllocSt is Data:
  RaAllocSt{rmap: Map<&2, U32>, callee: List<&2, RaSlot>, caller: List<&2, RaSlot>, spills: U32}

def ra_slot_free(used: Bool, last_end: U32, s: U32) -> Bool:
  match used:
    case False{}: True{}
    case True{}: U32.is_lt(last_end, s)
def ra_try_pick(free: Bool, +r: U32, ov: U32, le: U32, ow: U32, u: Bool, v: U32, e: U32, w: U32, orig_t: List<&2, RaSlot>, rest: RaTry) -> RaTry:
  match free rest:
    case True{} _: RaTry{True{}, r, Con{RaSlot{r, v, e, w, True{}}, orig_t}}
    case False{} RaTry{ok, reg, t2}: RaTry{ok, reg, Con{RaSlot{r, ov, le, ow, u}, t2}}
def ra_try_pool(pool: List<&2, RaSlot>, +v: U32, +s: U32, +e: U32, +w: U32) -> RaTry:
  match pool:
    case Nil{}: RaTry{False{}, 0, Nil{}}
    case Con{RaSlot{r, ov, +le, ow, +u}, +t}:
      ra_try_pick(ra_slot_free(u, le, s), r, ov, le, ow, u, v, e, w, t, ra_try_pool(t, v, s, e, w))
def ra_min_pick(better: Bool, r: U32, vid: U32, w: U32, le: U32, cur: RaMin) -> RaMin:
  match better:
    case True{}: RaMin{True{}, r, vid, w, le}
    case False{}: cur
def ra_find_min_go(pool: List<&2, RaSlot>, cur: RaMin) -> RaMin:
  match pool cur:
    case Nil{} _: cur
    case Con{RaSlot{r, vid, le, w, _}, t} RaMin{False{}, _, _, _, _}:
      ra_find_min_go(t, RaMin{True{}, r, vid, w, le})
    case Con{RaSlot{r, vid, +le, +w, _}, t} RaMin{True{}, cr, cv, +cw, +cle}:
      better = Bool.or(U32.is_lt(w, cw), Bool.and(U32.is_eq(w, cw), U32.is_gt(le, cle)))
      ra_find_min_go(t, ra_min_pick(better, r, vid, w, le, RaMin{True{}, cr, cv, cw, cle}))
def ra_rep_one(hit: Bool, +r: U32, ov: U32, le: U32, ow: U32, u: Bool, v: U32, e: U32, w: U32, rest: List<&2, RaSlot>) -> List<&2, RaSlot>:
  match hit:
    case True{}: Con{RaSlot{r, v, e, w, True{}}, rest}
    case False{}: Con{RaSlot{r, ov, le, ow, u}, rest}
def ra_replace_slot(pool: List<&2, RaSlot>, +tgt: U32, +v: U32, +e: U32, +w: U32) -> List<&2, RaSlot>:
  match pool:
    case Nil{}: Nil{}
    case Con{RaSlot{+r, ov, le, ow, u}, t}:
      ra_rep_one(U32.is_eq(r, tgt), r, ov, le, ow, u, v, e, w, ra_replace_slot(t, tgt, v, e, w))

type RaEvictRes is Data:
  RaEvictRes{rmap: Map<&2, U32>, pool: List<&2, RaSlot>, spills: U32}
def ra_evict_fin(do_ev: Bool, +mr: U32, mvid: U32, +v: U32, e: U32, w: U32, rm: Map<&2, U32>, pl: List<&2, RaSlot>, +sp: U32) -> RaEvictRes:
  match do_ev:
    case True{}:
      rm1 = Map.set(&2, U32, Map.set(&2, U32, rm, b5k_u32_to_str(mvid), U32.add(100, sp)), b5k_u32_to_str(v), mr)
      RaEvictRes{rm1, ra_replace_slot(pl, mr, v, e, w), U32.add(sp, 1)}
    case False{}:
      RaEvictRes{Map.set(&2, U32, rm, b5k_u32_to_str(v), U32.add(100, sp)), pl, U32.add(sp, 1)}
def ra_evict_pool(mn: RaMin, v: U32, e: U32, +w: U32, rm: Map<&2, U32>, pl: List<&2, RaSlot>, sp: U32) -> RaEvictRes:
  match mn:
    case RaMin{found, mr, mvid, mw, _}:
      ra_evict_fin(Bool.and(found, U32.is_gt(w, mw)), mr, mvid, v, e, w, rm, pl, sp)
def ra_put_cross(ev: RaEvictRes, cr: List<&2, RaSlot>) -> RaAllocSt:
  match ev:
    case RaEvictRes{rm, ce2, sp}: RaAllocSt{rm, ce2, cr, sp}
def ra_put_nc(ev: RaEvictRes, ce: List<&2, RaSlot>) -> RaAllocSt:
  match ev:
    case RaEvictRes{rm, cr2, sp}: RaAllocSt{rm, ce, cr2, sp}

def ra_assign_cross_fin(tr: RaTry, v: U32, e: U32, w: U32, rm: Map<&2, U32>, cr: List<&2, RaSlot>, sp: U32) -> RaAllocSt:
  match tr:
    case RaTry{True{}, r, ce2}: RaAllocSt{Map.set(&2, U32, rm, b5k_u32_to_str(v), r), ce2, cr, sp}
    case RaTry{False{}, _, +ce2}: ra_put_cross(ra_evict_pool(ra_find_min_go(ce2, RaMin{False{}, 0, 0, 0, 0}), v, e, w, rm, ce2, sp), cr)
def ra_assign_cross_one(iv: RaIv, st: RaAllocSt) -> RaAllocSt:
  match iv st:
    case RaIv{+v, s, +e, +w, _} RaAllocSt{rm, ce, cr, sp}:
      ra_assign_cross_fin(ra_try_pool(ce, v, s, e, w), v, e, w, rm, cr, sp)
def ra_assign_cross(xs: List<&2, RaIv>, st: RaAllocSt) -> RaAllocSt:
  match xs:
    case Nil{}: st
    case Con{iv, t}: ra_assign_cross(t, ra_assign_cross_one(iv, st))

def ra_assign_nc_s2(tr2: RaTry, v: U32, e: U32, w: U32, rm: Map<&2, U32>, +cr2: List<&2, RaSlot>, sp: U32) -> RaAllocSt:
  match tr2:
    case RaTry{True{}, r, ce2}: RaAllocSt{Map.set(&2, U32, rm, b5k_u32_to_str(v), r), ce2, cr2, sp}
    case RaTry{False{}, _, ce2}: ra_put_nc(ra_evict_pool(ra_find_min_go(cr2, RaMin{False{}, 0, 0, 0, 0}), v, e, w, rm, cr2, sp), ce2)
def ra_assign_nc_s1(tr1: RaTry, +v: U32, s: U32, +e: U32, +w: U32, rm: Map<&2, U32>, ce: List<&2, RaSlot>, sp: U32) -> RaAllocSt:
  match tr1:
    case RaTry{True{}, r, cr2}: RaAllocSt{Map.set(&2, U32, rm, b5k_u32_to_str(v), r), ce, cr2, sp}
    case RaTry{False{}, _, cr2}: ra_assign_nc_s2(ra_try_pool(ce, v, s, e, w), v, e, w, rm, cr2, sp)
def ra_assign_nc_one(iv: RaIv, st: RaAllocSt) -> RaAllocSt:
  match iv st:
    case RaIv{+v, +s, +e, +w, _} RaAllocSt{rm, ce, cr, sp}:
      ra_assign_nc_s1(ra_try_pool(cr, v, s, e, w), v, s, e, w, rm, ce, sp)
def ra_assign_nocross(xs: List<&2, RaIv>, st: RaAllocSt) -> RaAllocSt:
  match xs:
    case Nil{}: st
    case Con{iv, t}: ra_assign_nocross(t, ra_assign_nc_one(iv, st))

def ra_used_callee(pool: List<&2, RaSlot>) -> List<&2, U32>:
  match pool:
    case Nil{}: Nil{}
    case Con{RaSlot{_, _, _, _, False{}}, t}: ra_used_callee(t)
    case Con{RaSlot{r, _, _, _, True{}}, t}: Con{r, ra_used_callee(t)}
def ra_init_callee() -> List<&2, RaSlot>:
  Con{RaSlot{3, 0, 0, 0, False{}}, Con{RaSlot{12, 0, 0, 0, False{}}, Con{RaSlot{13, 0, 0, 0, False{}}, Con{RaSlot{14, 0, 0, 0, False{}}, Con{RaSlot{15, 0, 0, 0, False{}}, Nil{}}}}}}
def ra_init_caller() -> List<&2, RaSlot>:
  Con{RaSlot{8, 0, 0, 0, False{}}, Con{RaSlot{9, 0, 0, 0, False{}}, Con{RaSlot{10, 0, 0, 0, False{}}, Con{RaSlot{11, 0, 0, 0, False{}}, Nil{}}}}}
def ra_init_xmm_go(n: Nat, +r: U32) -> List<&2, RaSlot>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{RaSlot{r, 0, 0, 0, False{}}, ra_init_xmm_go(p, U32.add(r, 1))}

type RaXmmSt is Data:
  RaXmmSt{xmap: Map<&2, U32>, pool: List<&2, RaSlot>}
def ra_evict_xmm_fin(do_ev: Bool, +mr: U32, mvid: U32, +v: U32, e: U32, w: U32, xm: Map<&2, U32>, xp: List<&2, RaSlot>) -> RaXmmSt:
  match do_ev:
    case True{}:
      xm1 = Map.set(&2, U32, Map.set(&2, U32, xm, b5k_u32_to_str(mvid), 0), b5k_u32_to_str(v), mr)
      RaXmmSt{xm1, ra_replace_slot(xp, mr, v, e, w)}
    case False{}: RaXmmSt{xm, xp}
def ra_evict_xmm(mn: RaMin, v: U32, e: U32, +w: U32, xm: Map<&2, U32>, xp: List<&2, RaSlot>) -> RaXmmSt:
  match mn:
    case RaMin{found, mr, mvid, mw, _}:
      ra_evict_xmm_fin(Bool.and(found, U32.is_gt(w, mw)), mr, mvid, v, e, w, xm, xp)
def ra_assign_xmm_fin(tr: RaTry, v: U32, e: U32, w: U32, xm: Map<&2, U32>) -> RaXmmSt:
  match tr:
    case RaTry{True{}, r, xp2}: RaXmmSt{Map.set(&2, U32, xm, b5k_u32_to_str(v), r), xp2}
    case RaTry{False{}, _, +xp2}: ra_evict_xmm(ra_find_min_go(xp2, RaMin{False{}, 0, 0, 0, 0}), v, e, w, xm, xp2)
def ra_assign_xmm_one(iv: RaIv, st: RaXmmSt) -> RaXmmSt:
  match iv st:
    case RaIv{+v, s, +e, +w, _} RaXmmSt{xm, xp}:
      ra_assign_xmm_fin(ra_try_pool(xp, v, s, e, w), v, e, w, xm)
def ra_assign_xmm(xs: List<&2, RaIv>, st: RaXmmSt) -> Map<&2, U32>:
  match xs st:
    case Nil{} RaXmmSt{xm, _}: xm
    case Con{iv, t} _: ra_assign_xmm(t, ra_assign_xmm_one(iv, st))

def ra_finish_st(st1: RaAllocSt) -> RegAllocRes:
  match st1:
    case RaAllocSt{rm, ce, _, sp}: RegAllocRes{rm, ra_used_callee(ce), sp}
def ra_finish_parts(pts: RaParts) -> RegAllocRes:
  match pts:
    case RaParts{cr, nc}:
      cr_s = ra_msort(20n, cr)
      nc_s = ra_msort(20n, nc)
      ra_finish_st(ra_assign_nocross(nc_s, ra_assign_cross(cr_s, RaAllocSt{Map.new(&2, U32), ra_init_callee(), ra_init_caller(), 0})))
def ra_finish_scan(total: U32, scan: RaScan) -> RegAllocRes:
  match scan:
    case RaScan{ivs, _, cb, ca, _, es, _, _}:
      ra_finish_parts(ra_collect_ivs(U32.to_nat(total), 0, ivs, cb, ca, es, RaParts{Nil{}, Nil{}}))
def b5k_regalloc(fn: IrFn) -> RegAllocRes:
  match fn:
    case IrFn{fid, _, +arity, +nregs, _, _, _, blocks}:
      ivs0 = ra_init_params(U32.to_nat(arity), 0, RVEmpty{})
      scan = ra_scan_blks(fid, blocks, RaScan{ivs0, RVEmpty{}, RVEmpty{}, RVEmpty{}, 0, Nil{}, RVEmpty{}, 1})
      ra_finish_scan(U32.max(nregs, arity), scan)

def ra_finish_xmm(total: U32, scan: RaScan) -> Map<&2, U32>:
  match scan:
    case RaScan{ivs, _, cb, ca, _, es, f32s, _}:
      xs = ra_msort(20n, ra_collect_xmm(U32.to_nat(total), 0, ivs, cb, ca, es, f32s, Nil{}))
      ra_assign_xmm(xs, RaXmmSt{Map.new(&2, U32), ra_init_xmm_go(14n, 2)})
def b5k_xmm_alloc(fn: IrFn) -> Map<&2, U32>:
  match fn:
    case IrFn{fid, _, +arity, +nregs, _, _, _, blocks}:
      ivs0 = ra_init_params(U32.to_nat(arity), 0, RVEmpty{})
      scan = ra_scan_blks(fid, blocks, RaScan{ivs0, RVEmpty{}, RVEmpty{}, RVEmpty{}, 0, Nil{}, RVEmpty{}, 1})
      ra_finish_xmm(U32.max(nregs, arity), scan)

# Part 2: Typed X64Inst Peephole Optimizer
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

def peep_dead_reg(fuel: Nat, +r: U32, xs: List<&2, X64Inst>) -> Bool:
  match fuel xs:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+p Con{+h, t}:
      Bool.pick(Bool, peep_kills_reg(r, h), True{},
        Bool.pick(Bool, peep_reads_reg(r, h), False{}, peep_dead_reg(p, r, t)))

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
def peep_flags_live(fuel: Nat, xs: List<&2, X64Inst>) -> Bool:
  match fuel xs:
    case 0n _: False{}
    case _ Nil{}: False{}
    case 1n+p Con{+h, t}:
      Bool.pick(Bool, peep_uses_flags(h), True{},
        Bool.pick(Bool, peep_preserves_flags(h), peep_flags_live(p, t), False{}))

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
def peep_dead_after_jcc(d: U32, rest: List<&2, X64Inst>) -> Bool:
  peep_dead_after_fin(U32.is_zero(d), rest)
def peep_fuse_jcc(+cc: U32, jcc: U32) -> U32:
  Bool.pick(U32, U32.is_eq(jcc, 4), U32.xor(cc, 1), cc)
def peep_is_z_or_nz(+jcc: U32) -> Bool:
  Bool.or(U32.is_eq(jcc, 4), U32.is_eq(jcc, 5))

# Jump Threading & Branch-to-Return (O(N), Zero Strings)
def peep_set_lbl(ok: Bool, id: U32, val: U32, t: RaVec<U32>) -> RaVec<U32>:
  match ok:
    case True{}: ra_vec_set(U32, id, val, t)
    case False{}: t
def peep_build_lbls(insts: List<&2, X64Inst>, tbl: RaVec<U32>) -> RaVec<U32>:
  match insts:
    case Nil{}: tbl
    case Con{XLabel{+id}, Con{XRet{}, t}}:
      peep_build_lbls(Con{XRet{}, t}, peep_set_lbl(U32.is_lt(id, 65536), id, 1, tbl))
    case Con{XLabel{+id}, Con{XJmp{+tgt}, t}}:
      ok = Bool.and(Bool.and(U32.is_lt(id, 65536), U32.is_lt(tgt, 65536)), U32.is_ne(id, tgt))
      peep_build_lbls(Con{XJmp{tgt}, t}, peep_set_lbl(ok, id, U32.add(tgt, 2), tbl))
    case Con{XLabel{+id}, Con{XLabel{+id2}, t}}:
      ok = Bool.and(Bool.and(U32.is_lt(id, 65536), U32.is_lt(id2, 65536)), U32.is_ne(id, id2))
      peep_build_lbls(Con{XLabel{id2}, t}, peep_set_lbl(ok, id, U32.add(id2, 2), tbl))
    case Con{_, t}: peep_build_lbls(t, tbl)
def peep_resolve_lbl(fuel: Nat, +tgt: U32, +tbl: RaVec<U32>) -> U32:
  match fuel:
    case 0n: U32.add(tgt, 2)
    case 1n+p:
      +ent = Bool.pick(U32, U32.is_lt(tgt, 65536), ra_vec_get(U32, 0, tgt, tbl), 0)
      Bool.pick(U32, U32.is_zero(ent), U32.add(tgt, 2),
        Bool.pick(U32, U32.is_eq(ent, 1), 1, peep_resolve_lbl(p, U32.sub(ent, 2), tbl)))
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
def peep_thread(+insts: List<&2, X64Inst>) -> List<&2, X64Inst>:
  peep_thread_go(insts, peep_build_lbls(insts, RVEmpty{}), Nil{})

# Peephole Rewrite Rules
type PeepSt is Data:
  PeepSt{xs: List<&2, X64Inst>, acc: List<&2, X64Inst>}
def peep_zero_mov(+r1: U32, +imm: U32, +rest: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  use_xor = Bool.and(U32.is_zero(imm), Bool.not(peep_flags_live(3n, rest)))
  PeepSt{rest, Con{Bool.pick(X64Inst, use_xor, XAluRR{7, r1, r1}, XMovRI32{r1, imm}), acc}}
def peep_fwd(ok: Bool, new_inst: X64Inst, old1: X64Inst, old2: X64Inst, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t2, Con{new_inst, acc}}
    case False{}: PeepSt{Con{old2, t2}, Con{old1, acc}}

def peep_mov_next(+r1: U32, +r0: U32, t1: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match t1:
    case Con{XStore{+b, +d, +s}, +t2}:
      ok = Bool.and(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, b)), peep_dead_reg(4n, r1, t2))
      peep_fwd(ok, XStore{b, d, r0}, XMovRR{r1, r0}, XStore{b, d, s}, t2, acc)
    case Con{XMovRR{+r2, +s}, +t2}:
      ok = Bool.and(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, r2)), peep_dead_reg(4n, r1, t2))
      peep_fwd(ok, XMovRR{r2, r0}, XMovRR{r1, r0}, XMovRR{r2, s}, t2, acc)
    case Con{XAluRR{+op, +dst, +s}, +t2}:
      ok = Bool.and(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, dst)), peep_dead_reg(5n, r1, t2))
      peep_fwd(ok, XAluRR{op, dst, r0}, XMovRR{r1, r0}, XAluRR{op, dst, s}, t2, acc)
    case Con{XCmpRR{+a, +b}, +t2}:
      +ok_b = Bool.and(Bool.and(U32.is_eq(r1, b), U32.is_ne(r1, a)), peep_dead_reg(4n, r1, t2))
      +ok_a = Bool.and(Bool.and(U32.is_eq(r1, a), U32.is_ne(r1, b)), peep_dead_reg(4n, r1, t2))
      rep = Bool.pick(X64Inst, ok_b, XCmpRR{a, r0}, XCmpRR{r0, b})
      peep_fwd(Bool.or(ok_b, ok_a), rep, XMovRR{r1, r0}, XCmpRR{a, b}, t2, acc)
    case Con{XMul{+dst, +s}, +t2}:
      ok = Bool.and(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, dst)), peep_dead_reg(5n, r1, t2))
      peep_fwd(ok, XMul{dst, r0}, XMovRR{r1, r0}, XMul{dst, s}, t2, acc)
    case Con{XPush{+s}, +t2}:
      ok = Bool.and(U32.is_eq(r1, s), peep_dead_reg(4n, r1, t2))
      peep_fwd(ok, XPush{r0}, XMovRR{r1, r0}, XPush{s}, t2, acc)
    case rest: PeepSt{rest, Con{XMovRR{r1, r0}, acc}}
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
def peep_r6a(ok: Bool, a: U32, b: U32, z1: U32, zi: U32, cc: U32, d: U32, tst: X64Inst, jcc: U32, lbl: U32, t5: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t5, Con{XJcc{peep_fuse_jcc(cc, jcc), lbl}, Con{XCmpRR{a, b}, acc}}}
    case False{}: PeepSt{Con{XMovRI32{z1, zi}, Con{XSetcc{cc, d}, Con{tst, Con{XJcc{jcc, lbl}, t5}}}}, Con{XCmpRR{a, b}, acc}}
def peep_r6b(ok: Bool, a: U32, b: U32, cc: U32, d: U32, tst: X64Inst, jcc: U32, lbl: U32, t4: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t4, Con{XJcc{peep_fuse_jcc(cc, jcc), lbl}, Con{XCmpRR{a, b}, acc}}}
    case False{}: PeepSt{Con{XSetcc{cc, d}, Con{tst, Con{XJcc{jcc, lbl}, t4}}}, Con{XCmpRR{a, b}, acc}}
def peep_cmp0(ok: Bool, +r: U32, imm: U32, nxt: X64Inst, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{Con{nxt, t2}, Con{XTestRR{r, r}, acc}}
    case False{}: PeepSt{Con{nxt, t2}, Con{XCmpRI{r, imm}, acc}}
def peep_imm_fwd(ok: Bool, new_inst: X64Inst, r1: U32, imm: U32, old2: X64Inst, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t2, Con{new_inst, acc}}
    case False{}: peep_zero_mov(r1, imm, Con{old2, t2}, acc)

def peep_step(h: X64Inst, t: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match h t:
    case XMovRR{+r1, +r0} t1: peep_mov_step(U32.is_eq(r1, r0), r1, r0, t1, acc)
    case XAluRI{+op, d, +imm} +t1:
      peep_r2(Bool.and(peep_is_zero_alu(op, imm), Bool.not(peep_flags_live(3n, t1))), op, d, imm, t1, acc)
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
    case XLoad{+r1, +b, +d} Con{XMovRR{+r2, +s}, +t2}:
      ok = Bool.and(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, r2)), peep_dead_reg(4n, r1, t2))
      peep_fwd(ok, XLoad{r2, b, d}, XLoad{r1, b, d}, XMovRR{r2, s}, t2, acc)
    case XJmp{+lbl1} Con{XLabel{+lbl2}, t2}:
      peep_r5(U32.is_eq(lbl1, lbl2), lbl1, lbl2, t2, acc)
    case XCmpRR{a, b} Con{XMovRI32{+z1, +zi}, Con{XSetcc{+cc, +d}, Con{+tst, Con{XJcc{+jcc, +lbl}, +t5}}}}:
      ok = Bool.and(Bool.and(U32.is_eq(z1, d), U32.is_zero(zi)),
           Bool.and(Bool.and(peep_is_ztest(d, tst), peep_is_z_or_nz(jcc)), peep_dead_after_jcc(d, t5)))
      peep_r6a(ok, a, b, z1, zi, cc, d, tst, jcc, lbl, t5, acc)
    case XCmpRR{a, b} Con{XSetcc{+cc, +d}, Con{+tst, Con{XJcc{+jcc, +lbl}, +t4}}}:
      ok = Bool.and(Bool.and(peep_is_ztest(d, tst), peep_is_z_or_nz(jcc)), peep_dead_after_jcc(d, t4))
      peep_r6b(ok, a, b, cc, d, tst, jcc, lbl, t4, acc)
    case XCmpRI{r, +imm} Con{XJcc{+cc, lbl}, t2}:
      peep_cmp0(Bool.and(U32.is_zero(imm), peep_is_z_or_nz(cc)), r, imm, XJcc{cc, lbl}, t2, acc)
    case XCmpRI{r, +imm} Con{XSetcc{+cc, d}, t2}:
      peep_cmp0(Bool.and(U32.is_zero(imm), peep_is_z_or_nz(cc)), r, imm, XSetcc{cc, d}, t2, acc)
    case XMovRI32{+r1, +imm} Con{XMovRR{+r2, +s}, +t2}:
      ok = Bool.and(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, r2)), peep_dead_reg(4n, r1, t2))
      peep_imm_fwd(ok, XMovRI32{r2, imm}, r1, imm, XMovRR{r2, s}, t2, acc)
    case XMovRI32{+r1, +imm} Con{XAluRR{+op, +dst, +s}, +t2}:
      ok = Bool.and(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, dst)),
           Bool.and(U32.is_lt(imm, 2147483648), peep_dead_reg(5n, r1, t2)))
      peep_imm_fwd(ok, XAluRI{op, dst, imm}, r1, imm, XAluRR{op, dst, s}, t2, acc)
    case XMovRI32{r1, imm} t1: peep_zero_mov(r1, imm, t1, acc)
    case inst rest: PeepSt{rest, Con{inst, acc}}

def peep_run(fuel: Nat, st: PeepSt) -> List<&2, X64Inst>:
  match fuel st:
    case 0n PeepSt{_, acc}: b5k_list_rev(X64Inst, acc)
    case 1n+p PeepSt{Nil{}, acc}: b5k_list_rev(X64Inst, acc)
    case 1n+p PeepSt{Con{h, t}, acc}: peep_run(p, peep_step(h, t, acc))
def peep_pass(+insts: List<&2, X64Inst>) -> List<&2, X64Inst>:
  peep_run(U32.to_nat(b5k_list_len(X64Inst, insts)), PeepSt{insts, Nil{}})
def peep_fn(f: X64Fn) -> X64Fn:
  match f:
    case X64Fn{name, is_glob, insts}:
      X64Fn{name, is_glob, peep_pass(peep_pass(peep_thread(insts)))}
def b5k_peep_go(fns: List<&2, X64Fn>, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match fns:
    case Nil{}: b5k_list_rev(X64Fn, acc)
    case Con{f, t}: b5k_peep_go(t, Con{peep_fn(f), acc})
def b5k_peep(fns: List<&2, X64Fn>) -> List<&2, X64Fn>:
  b5k_peep_go(fns, Nil{})
