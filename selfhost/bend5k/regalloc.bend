# bend5k/regalloc.bend — Linear-Scan Register Allocator & Typed X64 Peephole
# ==========================================================================
# Exports:
#   - RegAllocRes, b5k_regalloc(fn: IrFn) -> RegAllocRes
#   - b5k_peep(fns: List<&2, X64Fn>) -> List<&2, X64Fn>

# Dense U32 Bit-Trie (Zero String Hashing)
# ----------------------------------------

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

# Part 1: Linear-Scan Register Allocator
# --------------------------------------

type RegAllocRes is Data:
  RegAllocRes{reg_map: Map<&2, U32>, used_callee: List<&2, U32>, spill_count: U32}

type RaIv is Data:
  RaIv{vid: U32, start: U32, end: U32, uses: U32, seen: Bool}

type RaEdge is Data:
  RaEdge{lstart: U32, bend: U32}

type RaScan is Data:
  RaScan{ivs: RaVec<RaIv>, blk_s: RaVec<U32>, calls: List<&2, U32>, edges: List<&2, RaEdge>, idx: U32}

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

def ra_scan_op_go(op: IrOp, ivs: RaVec<RaIv>, bs: RaVec<U32>, cs: List<&2, U32>, es: List<&2, RaEdge>, +idx: U32, nxt: U32) -> RaScan:
  match op:
    case IConst{d, _}: RaScan{ra_touch(ivs, d, idx), bs, cs, es, nxt}
    case IFlt{d, _}: RaScan{ra_touch(ivs, d, idx), bs, cs, es, nxt}
    case ICopy{d, s}: RaScan{ra_touch(ra_touch(ivs, s, idx), d, idx), bs, cs, es, nxt}
    case IBin{d, _, l, r}: RaScan{ra_touch(ra_touch(ra_touch(ivs, l, idx), r, idx), d, idx), bs, cs, es, nxt}
    case IUn{d, _, s}: RaScan{ra_touch(ra_touch(ivs, s, idx), d, idx), bs, cs, es, nxt}
    case ICmp{d, _, l, r}: RaScan{ra_touch(ra_touch(ra_touch(ivs, l, idx), r, idx), d, idx), bs, cs, es, nxt}
    case ICallDirect{d, _, args}: RaScan{ra_touch(ra_touch_list(args, ivs, idx), d, idx), bs, Con{idx, cs}, es, nxt}
    case ICallClosure{d, _, caps}: RaScan{ra_touch(ra_touch_list(caps, ivs, idx), d, idx), bs, Con{idx, cs}, es, nxt}
    case IApply{d, clo, arg}: RaScan{ra_touch(ra_touch(ra_touch(ivs, clo, idx), arg, idx), d, idx), bs, Con{idx, cs}, es, nxt}
    case ICtor{d, _, fs}: RaScan{ra_touch(ra_touch_list(fs, ivs, idx), d, idx), bs, Con{idx, cs}, es, nxt}
    case ITake{ds, s}: RaScan{ra_touch_list(ds, ra_touch(ivs, s, idx), idx), bs, Con{idx, cs}, es, nxt}
    case ITag{d, s}: RaScan{ra_touch(ra_touch(ivs, s, idx), d, idx), bs, Con{idx, cs}, es, nxt}
    case IKeep{d, s}: RaScan{ra_touch(ra_touch(ivs, s, idx), d, idx), bs, Con{idx, cs}, es, nxt}
    case ISink{s}: RaScan{ra_touch(ivs, s, idx), bs, Con{idx, cs}, es, nxt}
    case IReuse{d, sl, _, fs}: RaScan{ra_touch(ra_touch(ra_touch_list(fs, ivs, idx), sl, idx), d, idx), bs, Con{idx, cs}, es, nxt}
    case IStatic{d, _}: RaScan{ra_touch(ivs, d, idx), bs, cs, es, nxt}
    case IArrOp{ds, _, args}: RaScan{ra_touch_list(ds, ra_touch_list(args, ivs, idx), idx), bs, Con{idx, cs}, es, nxt}
    case IAlloca{d, _}: RaScan{ra_touch(ivs, d, idx), bs, cs, es, nxt}
    case ILoad{d, b, _}: RaScan{ra_touch(ra_touch(ivs, b, idx), d, idx), bs, cs, es, nxt}
    case IStore{b, _, v}: RaScan{ra_touch(ra_touch(ivs, b, idx), v, idx), bs, cs, es, nxt}
    case IFail{_}: RaScan{ivs, bs, Con{idx, cs}, es, nxt}

def ra_scan_op(op: IrOp, st: RaScan) -> RaScan:
  match st:
    case RaScan{ivs, bs, cs, es, +idx}:
      ra_scan_op_go(op, ivs, bs, cs, es, idx, U32.add(idx, 1))

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

def ra_scan_term_go(fn_fid: U32, term: IrTerm, ivs: RaVec<RaIv>, +bs: RaVec<U32>, cs: List<&2, U32>, es: List<&2, RaEdge>, +idx: U32, nxt: U32) -> RaScan:
  match term:
    case TJmp{tgt}: RaScan{ivs, bs, cs, ra_check_edge(bs, tgt, idx, es), nxt}
    case TBr{c, tb, eb}:
      es1 = ra_check_edge(bs, eb, idx, ra_check_edge(bs, tb, idx, es))
      RaScan{ra_touch(ivs, c, idx), bs, cs, es1, nxt}
    case TSwitch{sc, arms, db}:
      es1 = ra_check_edge(bs, db, idx, ra_check_arms(bs, arms, idx, es))
      RaScan{ra_touch(ivs, sc, idx), bs, cs, es1, nxt}
    case TRet{v}: RaScan{ra_touch(ivs, v, idx), bs, cs, es, nxt}
    case TTailCall{fid, args}:
      es1 = ra_tail_edge(U32.is_eq(fid, fn_fid), bs, idx, es)
      RaScan{ra_touch_list(args, ivs, idx), bs, cs, es1, nxt}
    case TFail{_}: RaScan{ivs, bs, cs, es, nxt}

def ra_scan_term(fn_fid: U32, term: IrTerm, st: RaScan) -> RaScan:
  match st:
    case RaScan{ivs, bs, cs, es, +idx}:
      ra_scan_term_go(fn_fid, term, ivs, bs, cs, es, idx, U32.add(idx, 1))

def ra_scan_blks(+fn_fid: U32, blks: List<&2, IrBlock>, st: RaScan) -> RaScan:
  match blks st:
    case Nil{} _: st
    case Con{IrBlock{bid, ops, term}, t} RaScan{ivs, bs, cs, es, +idx}:
      bs1 = ra_vec_set(U32, bid, U32.add(idx, 1), bs)
      st1 = ra_scan_term(fn_fid, term, ra_scan_ops(ops, RaScan{ivs, bs1, cs, es, idx}))
      ra_scan_blks(fn_fid, t, st1)

def ra_ext_one(iv: RaIv, edge: RaEdge) -> RaIv:
  match iv edge:
    case RaIv{v, +s, +e, +u, seen} RaEdge{+ls, +be}:
      +live_hdr = Bool.and(U32.is_le(s, ls), U32.is_ge(e, ls))
      +in_loop = Bool.and(U32.is_ge(s, ls), U32.is_le(e, be))
      e2 = Bool.pick(U32, live_hdr, U32.max(e, be), e)
      u2 = Bool.pick(U32, live_hdr, U32.add(u, 8), Bool.pick(U32, in_loop, U32.add(u, 4), u))
      RaIv{v, s, e2, u2, seen}

def ra_ext_edges(es: List<&2, RaEdge>, iv: RaIv) -> RaIv:
  match es:
    case Nil{}: iv
    case Con{edge, t}: ra_ext_edges(t, ra_ext_one(iv, edge))

def ra_has_call_in(cs: List<&2, U32>, +s: U32, +e: U32) -> Bool:
  match cs:
    case Nil{}: False{}
    case Con{+cp, t}: Bool.or(Bool.and(U32.is_lt(s, cp), U32.is_lt(cp, e)), ra_has_call_in(t, s, e))

type RaParts is Data:
  RaParts{cross: List<&2, RaIv>, nocross: List<&2, RaIv>}

def ra_add_part_fin(is_cr: Bool, iv: RaIv, cr: List<&2, RaIv>, nc: List<&2, RaIv>) -> RaParts:
  match is_cr:
    case True{}: RaParts{Con{iv, cr}, nc}
    case False{}: RaParts{cr, Con{iv, nc}}

def ra_add_part_go(iv2: RaIv, cs: List<&2, U32>, cr: List<&2, RaIv>, nc: List<&2, RaIv>) -> RaParts:
  match iv2:
    case RaIv{v, +s, +e, u, seen}:
      ra_add_part_fin(ra_has_call_in(cs, s, e), RaIv{v, s, e, u, seen}, cr, nc)

def ra_add_part(iv: RaIv, cs: List<&2, U32>, +es: List<&2, RaEdge>, pts: RaParts) -> RaParts:
  match iv pts:
    case RaIv{_, _, _, _, False{}} _: pts
    case RaIv{v, s, e, u, True{}} RaParts{cr, nc}:
      ra_add_part_go(ra_ext_edges(es, ra_ext_edges(es, RaIv{v, s, e, u, True{}})), cs, cr, nc)

def ra_collect_ivs(n: Nat, +v: U32, +ivs: RaVec<RaIv>, +cs: List<&2, U32>, +es: List<&2, RaEdge>, pts: RaParts) -> RaParts:
  match n:
    case 0n: pts
    case 1n+p:
      iv = ra_vec_get(RaIv, RaIv{v, 0, 0, 0, False{}}, v, ivs)
      ra_collect_ivs(p, U32.add(v, 1), ivs, cs, es, ra_add_part(iv, cs, es, pts))

# Merge Sort by Weight Descending (O(N log N), Structurally Terminating)
# ----------------------------------------------------------------------

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
    case RaIv{_, _, _, ua, _} RaIv{_, _, _, ub, _}: U32.is_ge(ua, ub)

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

# Physical Register Pool Assignment
# ---------------------------------

type RaSpan is Data:
  RaSpan{s: U32, e: U32}

type RaSlot is Data:
  RaSlot{reg: U32, spans: List<&2, RaSpan>}

type RaTry is Data:
  RaTry{ok: Bool, reg: U32, pool: List<&2, RaSlot>}

type RaAllocSt is Data:
  RaAllocSt{rmap: Map<&2, U32>, callee: List<&2, RaSlot>, caller: List<&2, RaSlot>, spills: U32}

def ra_spans_free(spans: List<&2, RaSpan>, +s: U32, +e: U32) -> Bool:
  match spans:
    case Nil{}: True{}
    case Con{RaSpan{s2, e2}, t}:
      Bool.and(Bool.or(U32.is_lt(e, s2), U32.is_lt(e2, s)), ra_spans_free(t, s, e))

def ra_try_pick(free: Bool, +r: U32, sp: List<&2, RaSpan>, s: U32, e: U32, orig_t: List<&2, RaSlot>, rest: RaTry) -> RaTry:
  match free rest:
    case True{} _: RaTry{True{}, r, Con{RaSlot{r, Con{RaSpan{s, e}, sp}}, orig_t}}
    case False{} RaTry{ok, reg, t2}: RaTry{ok, reg, Con{RaSlot{r, sp}, t2}}

def ra_try_pool(pool: List<&2, RaSlot>, +s: U32, +e: U32) -> RaTry:
  match pool:
    case Nil{}: RaTry{False{}, 0, Nil{}}
    case Con{RaSlot{r, +sp}, +t}:
      ra_try_pick(ra_spans_free(sp, s, e), r, sp, s, e, t, ra_try_pool(t, s, e))

def ra_assign_cross_fin(tr: RaTry, v: U32, rm: Map<&2, U32>, cr: List<&2, RaSlot>, +sp: U32) -> RaAllocSt:
  match tr:
    case RaTry{True{}, r, ce2}: RaAllocSt{Map.set(&2, U32, rm, b5k_u32_to_str(v), r), ce2, cr, sp}
    case RaTry{False{}, _, ce2}: RaAllocSt{Map.set(&2, U32, rm, b5k_u32_to_str(v), U32.add(100, sp)), ce2, cr, U32.add(sp, 1)}

def ra_assign_cross_one(iv: RaIv, st: RaAllocSt) -> RaAllocSt:
  match iv st:
    case RaIv{v, s, e, _, _} RaAllocSt{rm, ce, cr, sp}:
      ra_assign_cross_fin(ra_try_pool(ce, s, e), v, rm, cr, sp)

def ra_assign_cross(xs: List<&2, RaIv>, st: RaAllocSt) -> RaAllocSt:
  match xs:
    case Nil{}: st
    case Con{iv, t}: ra_assign_cross(t, ra_assign_cross_one(iv, st))

def ra_assign_nc_s2(tr2: RaTry, v: U32, rm: Map<&2, U32>, cr2: List<&2, RaSlot>, +sp: U32) -> RaAllocSt:
  match tr2:
    case RaTry{True{}, r, ce2}: RaAllocSt{Map.set(&2, U32, rm, b5k_u32_to_str(v), r), ce2, cr2, sp}
    case RaTry{False{}, _, ce2}: RaAllocSt{Map.set(&2, U32, rm, b5k_u32_to_str(v), U32.add(100, sp)), ce2, cr2, U32.add(sp, 1)}

def ra_assign_nc_s1(tr1: RaTry, v: U32, s: U32, e: U32, rm: Map<&2, U32>, ce: List<&2, RaSlot>, sp: U32) -> RaAllocSt:
  match tr1:
    case RaTry{True{}, r, cr2}: RaAllocSt{Map.set(&2, U32, rm, b5k_u32_to_str(v), r), ce, cr2, sp}
    case RaTry{False{}, _, cr2}: ra_assign_nc_s2(ra_try_pool(ce, s, e), v, rm, cr2, sp)

def ra_assign_nc_one(iv: RaIv, st: RaAllocSt) -> RaAllocSt:
  match iv st:
    case RaIv{v, +s, +e, _, _} RaAllocSt{rm, ce, cr, sp}:
      ra_assign_nc_s1(ra_try_pool(cr, s, e), v, s, e, rm, ce, sp)

def ra_assign_nocross(xs: List<&2, RaIv>, st: RaAllocSt) -> RaAllocSt:
  match xs:
    case Nil{}: st
    case Con{iv, t}: ra_assign_nocross(t, ra_assign_nc_one(iv, st))

def ra_used_callee(pool: List<&2, RaSlot>) -> List<&2, U32>:
  match pool:
    case Nil{}: Nil{}
    case Con{RaSlot{_, Nil{}}, t}: ra_used_callee(t)
    case Con{RaSlot{r, Con{_, _}}, t}: Con{r, ra_used_callee(t)}

def ra_init_callee() -> List<&2, RaSlot>:
  Con{RaSlot{3, Nil{}}, Con{RaSlot{12, Nil{}}, Con{RaSlot{13, Nil{}}, Con{RaSlot{14, Nil{}}, Con{RaSlot{15, Nil{}}, Nil{}}}}}}

def ra_init_caller() -> List<&2, RaSlot>:
  Con{RaSlot{8, Nil{}}, Con{RaSlot{9, Nil{}}, Con{RaSlot{10, Nil{}}, Con{RaSlot{11, Nil{}}, Nil{}}}}}

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
    case RaScan{ivs, _, cs, es, _}:
      ra_finish_parts(ra_collect_ivs(U32.to_nat(total), 0, ivs, cs, es, RaParts{Nil{}, Nil{}}))

def b5k_regalloc(fn: IrFn) -> RegAllocRes:
  match fn:
    case IrFn{fid, _, +arity, +nregs, _, _, _, blocks}:
      ivs0 = ra_init_params(U32.to_nat(arity), 0, RVEmpty{})
      scan = ra_scan_blks(fid, blocks, RaScan{ivs0, RVEmpty{}, Nil{}, Nil{}, 1})
      ra_finish_scan(U32.max(nregs, arity), scan)

# Part 2: Typed X64Inst Peephole Optimizer
# ----------------------------------------

def peep_kills_reg(+r: U32, inst: X64Inst) -> Bool:
  match inst:
    case XMovRI32{d, _}: U32.is_eq(d, r)
    case XMovRI64{d, _, _}: U32.is_eq(d, r)
    case XLeaRip{d, _}: U32.is_eq(d, r)
    case XLoad{d, b, _}: Bool.and(U32.is_eq(d, r), U32.is_ne(b, r))
    case XMovRR{d, s}: Bool.and(U32.is_eq(d, r), U32.is_ne(s, r))
    case _: False{}

def peep_uses_flags(inst: X64Inst) -> Bool:
  match inst:
    case XJcc{_, _}: True{}
    case XSetcc{_, _}: True{}
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
    case True{} Con{+nxt, _}: Bool.or(peep_kills_reg(0, nxt), peep_is_jmp(nxt))

def peep_dead_after_jcc(d: U32, rest: List<&2, X64Inst>) -> Bool:
  peep_dead_after_fin(U32.is_zero(d), rest)

def peep_fuse_jcc(+cc: U32, jcc: U32) -> U32:
  Bool.pick(U32, U32.is_eq(jcc, 4), U32.xor(cc, 1), cc)

def peep_is_z_or_nz(+jcc: U32) -> Bool:
  Bool.or(U32.is_eq(jcc, 4), U32.is_eq(jcc, 5))

def peep_next_kills(r: U32, rest: List<&2, X64Inst>) -> Bool:
  match rest:
    case Nil{}: False{}
    case Con{nxt, _}: peep_kills_reg(r, nxt)

def peep_next_flags(rest: List<&2, X64Inst>) -> Bool:
  match rest:
    case Nil{}: False{}
    case Con{nxt, _}: peep_uses_flags(nxt)

type PeepSt is Data:
  PeepSt{xs: List<&2, X64Inst>, acc: List<&2, X64Inst>}

def peep_r1(same: Bool, d: U32, s: U32, t: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match same:
    case True{}: PeepSt{t, acc}
    case False{}: PeepSt{t, Con{XMovRR{d, s}, acc}}

def peep_r2(drop: Bool, op: U32, d: U32, imm: U32, t: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match drop:
    case True{}: PeepSt{t, acc}
    case False{}: PeepSt{t, Con{XAluRI{op, d, imm}, acc}}

def peep_r3(eq_mem: Bool, same_r: Bool, b1: U32, d1: U32, +r1: U32, r2: U32, b2: U32, d2: U32, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match eq_mem same_r:
    case True{} True{}: PeepSt{t2, Con{XStore{b1, d1, r1}, acc}}
    case True{} False{}: PeepSt{t2, Con{XMovRR{r2, r1}, Con{XStore{b1, d1, r1}, acc}}}
    case False{} _: PeepSt{Con{XLoad{r2, b2, d2}, t2}, Con{XStore{b1, d1, r1}, acc}}

def peep_r4(ok: Bool, r1: U32, b: U32, d: U32, r2: U32, s: U32, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t2, Con{XLoad{r2, b, d}, acc}}
    case False{}: PeepSt{Con{XMovRR{r2, s}, t2}, Con{XLoad{r1, b, d}, acc}}

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

def peep_r7(ok: Bool, r1: U32, imm: U32, r2: U32, s: U32, t2: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match ok:
    case True{}: PeepSt{t2, Con{XMovRI32{r2, imm}, acc}}
    case False{}: PeepSt{Con{XMovRR{r2, s}, t2}, Con{XMovRI32{r1, imm}, acc}}

def peep_step(h: X64Inst, t: List<&2, X64Inst>, acc: List<&2, X64Inst>) -> PeepSt:
  match h t:
    # Rule 1: Self-move elimination
    case XMovRR{+d, +s} _: peep_r1(U32.is_eq(d, s), d, s, t, acc)
    # Rule 2: Immediate zero arithmetic (ADD/SUB/OR/XOR r, 0)
    case XAluRI{+op, d, +imm} +t1:
      peep_r2(Bool.and(peep_is_zero_alu(op, imm), Bool.not(peep_next_flags(t1))), op, d, imm, t1, acc)
    # Rule 3: Redundant store-then-load
    case XStore{+b1, +d1, +r1} Con{XLoad{+r2, +b2, +d2}, t2}:
      peep_r3(Bool.and(U32.is_eq(b1, b2), U32.is_eq(d1, d2)), U32.is_eq(r1, r2), b1, d1, r1, r2, b2, d2, t2, acc)
    # Rule 4: Redundant load-then-mov when r1 is dead next
    case XLoad{+r1, b, d} Con{XMovRR{+r2, +s}, +t2}:
      ok = Bool.and(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, r2)), peep_next_kills(r1, t2))
      peep_r4(ok, r1, b, d, r2, s, t2, acc)
    # Rule 5: Fallthrough jump elimination
    case XJmp{+lbl1} Con{XLabel{+lbl2}, t2}:
      peep_r5(U32.is_eq(lbl1, lbl2), lbl1, lbl2, t2, acc)
    # Rule 6a: cmp + mov 0 + setcc + test/cmp 0 + jz/jnz fusion
    case XCmpRR{a, b} Con{XMovRI32{+z1, +zi}, Con{XSetcc{+cc, +d}, Con{+tst, Con{XJcc{+jcc, +lbl}, +t5}}}}:
      ok = Bool.and(Bool.and(U32.is_eq(z1, d), U32.is_zero(zi)),
           Bool.and(Bool.and(peep_is_ztest(d, tst), peep_is_z_or_nz(jcc)), peep_dead_after_jcc(d, t5)))
      peep_r6a(ok, a, b, z1, zi, cc, d, tst, jcc, lbl, t5, acc)
    # Rule 6b: cmp + setcc + test/cmp 0 + jz/jnz fusion
    case XCmpRR{a, b} Con{XSetcc{+cc, +d}, Con{+tst, Con{XJcc{+jcc, +lbl}, +t4}}}:
      ok = Bool.and(Bool.and(peep_is_ztest(d, tst), peep_is_z_or_nz(jcc)), peep_dead_after_jcc(d, t4))
      peep_r6b(ok, a, b, cc, d, tst, jcc, lbl, t4, acc)
    # Rule 7: Double-move folding (mov r1, imm; mov r2, r1 -> mov r2, imm)
    case XMovRI32{+r1, imm} Con{XMovRR{+r2, +s}, +t2}:
      ok = Bool.and(Bool.and(U32.is_eq(r1, s), U32.is_ne(r1, r2)), peep_next_kills(r1, t2))
      peep_r7(ok, r1, imm, r2, s, t2, acc)
    # Default: keep instruction
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
      X64Fn{name, is_glob, peep_pass(peep_pass(insts))}

def b5k_peep_go(fns: List<&2, X64Fn>, acc: List<&2, X64Fn>) -> List<&2, X64Fn>:
  match fns:
    case Nil{}: b5k_list_rev(X64Fn, acc)
    case Con{f, t}: b5k_peep_go(t, Con{peep_fn(f), acc})

def b5k_peep(fns: List<&2, X64Fn>) -> List<&2, X64Fn>:
  b5k_peep_go(fns, Nil{})
