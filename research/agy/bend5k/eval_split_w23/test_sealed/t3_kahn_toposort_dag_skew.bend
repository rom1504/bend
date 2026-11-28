import Base
# t3_kahn_toposort_dag (skew): Kahn's Topological Sort + Longest-Path DP on skewed CSR DAG
# Sealed-Test family 3: V = 2048 vertices, hub/chain skewed out-degree, 70 rounds.

type DagBuild is Type:
  DB{rptr: Array<U32>, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>, indeg0: Array<U32>, epos: U32, seed: U32}

type EdgeBuild is Type:
  EB{col: Array<U32>, wt: Array<U32>, indeg0: Array<U32>, epos: U32, seed: U32}

type InitQ is Type:
  IQ{indeg0: Array<U32>, indeg: Array<U32>, queue: Array<U32>, dist: Array<U32>, qtail: U32}

type DagRun is Type:
  DR{rptr: Array<U32>, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>, indeg0: Array<U32>, indeg: Array<U32>, queue: Array<U32>, dist: Array<U32>, acc: U32}

type KahnSt is Type:
  KS{rptr: Array<U32>, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>, indeg: Array<U32>, queue: Array<U32>, dist: Array<U32>, qhead: U32, qtail: U32, visited: U32, acc: U32}

type KahnWrap is Type:
  KW{ks: KahnSt, done: Bool}

type RelaxSt is Type:
  RS{col: Array<U32>, wt: Array<U32>, indeg: Array<U32>, queue: Array<U32>, dist: Array<U32>, qtail: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def min_u32(gt: Bool, +a: U32, +b: U32) -> U32:
  match gt:
    case True{}:
      b
    case False{}:
      a

def inc_indeg(+v: U32, r: Array<U32> & U32) -> Array<U32>:
  (indeg0, +d) = r
  Array.set(U32, indeg0, v, U32.inc(d))

def build_edges(+rem: Nat, +u: U32, +span: U32, eb: EdgeBuild) -> EdgeBuild:
  match rem:
    case 0n:
      eb
    case 1n+p:
      EB{col, wt, indeg0, +epos, +seed} = eb
      +ns = prng(seed)
      +v = U32.add(U32.inc(u), U32.mod(ns, span))
      +w = U32.inc(U32.and(U32.shrn(ns, 8n), 31))
      col1 = Array.set(U32, col, epos, v)
      wt1 = Array.set(U32, wt, epos, w)
      ind1 = inc_indeg(v, Array.get(U32, indeg0, v))
      build_edges(p, u, span, EB{col1, wt1, ind1, U32.inc(epos), ns})

def build_v_pack(rptr1: Array<U32>, rlen1: Array<U32>, eb: EdgeBuild) -> DagBuild:
  EB{col1, wt1, ind1, +epos1, +seed1} = eb
  DB{rptr1, rlen1, col1, wt1, ind1, epos1, seed1}

def sel_hub_deg(is_hub: Bool) -> U32:
  match is_hub:
    case True{}:
      12
    case False{}:
      3

def build_v_deg(at_end: Bool, +u: U32) -> U32:
  match at_end:
    case True{}:
      0
    case False{}:
      +rem = U32.sub(2047, u)
      +raw = sel_hub_deg(U32.is_zero(U32.and(u, 15)))
      min_u32(U32.is_gt(raw, rem), raw, rem)

def build_dag(+rem: Nat, +u: U32, db: DagBuild) -> DagBuild:
  match rem:
    case 0n:
      db
    case 1n+p:
      DB{rptr, rlen, col, wt, indeg0, +epos, +seed} = db
      +deg = build_v_deg(U32.is_ge(U32.inc(u), 2048), u)
      +remv = U32.sub(2047, u)
      +span = min_u32(U32.is_gt(remv, 64), remv, 64)
      rptr1 = Array.set(U32, rptr, u, epos)
      rlen1 = Array.set(U32, rlen, u, deg)
      db1 = build_v_pack(rptr1, rlen1, build_edges(U32.to_nat(deg), u, span, EB{col, wt, indeg0, epos, seed}))
      build_dag(p, U32.inc(u), db1)

def init_q_branch(is_z: Bool, +u: U32, +rd: U32, indeg0: Array<U32>, indeg1: Array<U32>, queue: Array<U32>, dist: Array<U32>, +qtail: U32) -> InitQ:
  match is_z:
    case True{}:
      dist1 = Array.set(U32, dist, u, U32.and(U32.add(u, rd), 15))
      q1 = Array.set(U32, queue, qtail, u)
      IQ{indeg0, indeg1, q1, dist1, U32.inc(qtail)}
    case False{}:
      dist1 = Array.set(U32, dist, u, 0)
      IQ{indeg0, indeg1, queue, dist1, qtail}

def init_q_step(+u: U32, +rd: U32, r: Array<U32> & U32, indeg: Array<U32>, queue: Array<U32>, dist: Array<U32>, +qtail: U32) -> InitQ:
  (indeg0, +d) = r
  indeg1 = Array.set(U32, indeg, u, d)
  init_q_branch(U32.is_zero(d), u, rd, indeg0, indeg1, queue, dist, qtail)

def init_q_loop(+rem: Nat, +u: U32, +rd: U32, iq: InitQ) -> InitQ:
  match rem:
    case 0n:
      iq
    case 1n+p:
      IQ{indeg0, indeg, queue, dist, +qtail} = iq
      init_q_loop(p, U32.inc(u), rd, init_q_step(u, rd, Array.get(U32, indeg0, u), indeg, queue, dist, qtail))

def push_if_zero(is_z: Bool, +v: U32, col: Array<U32>, wt: Array<U32>, indeg: Array<U32>, queue: Array<U32>, dist: Array<U32>, +qtail: U32) -> RelaxSt:
  match is_z:
    case True{}:
      RS{col, wt, indeg, Array.set(U32, queue, qtail, v), dist, U32.inc(qtail)}
    case False{}:
      RS{col, wt, indeg, queue, dist, qtail}

def dec_indeg(+v: U32, col: Array<U32>, wt: Array<U32>, r: Array<U32> & U32, queue: Array<U32>, dist: Array<U32>, +qtail: U32) -> RelaxSt:
  (indeg, +d) = r
  +nd = U32.sub(d, 1)
  indeg1 = Array.set(U32, indeg, v, nd)
  push_if_zero(U32.is_zero(nd), v, col, wt, indeg1, queue, dist, qtail)

def maybe_set_dist(gt: Bool, +v: U32, +cand: U32, dist: Array<U32>) -> Array<U32>:
  match gt:
    case True{}:
      Array.set(U32, dist, v, cand)
    case False{}:
      dist

def relax_dv(+v: U32, +cand: U32, col: Array<U32>, wt: Array<U32>, indeg: Array<U32>, queue: Array<U32>, r: Array<U32> & U32, +qtail: U32) -> RelaxSt:
  (dist, +dv) = r
  dist1 = maybe_set_dist(U32.is_gt(cand, dv), v, cand, dist)
  dec_indeg(v, col, wt, Array.get(U32, indeg, v), queue, dist1, qtail)

def relax_w(+v: U32, +du: U32, +rdm: U32, col: Array<U32>, r: Array<U32> & U32, indeg: Array<U32>, queue: Array<U32>, dist: Array<U32>, +qtail: U32) -> RelaxSt:
  (wt, +w) = r
  +cand = U32.add(U32.add(du, w), rdm)
  relax_dv(v, cand, col, wt, indeg, queue, Array.get(U32, dist, v), qtail)

def relax_v(+e: U32, +du: U32, +rdm: U32, r: Array<U32> & U32, wt: Array<U32>, indeg: Array<U32>, queue: Array<U32>, dist: Array<U32>, +qtail: U32) -> RelaxSt:
  (col, +v) = r
  relax_w(v, du, rdm, col, Array.get(U32, wt, e), indeg, queue, dist, qtail)

def relax_loop(+rem: Nat, +e: U32, +du: U32, +rdm: U32, rs: RelaxSt) -> RelaxSt:
  match rem:
    case 0n:
      rs
    case 1n+p:
      RS{col, wt, indeg, queue, dist, +qtail} = rs
      relax_loop(p, U32.inc(e), du, rdm, relax_v(e, du, rdm, Array.get(U32, col, e), wt, indeg, queue, dist, qtail))

def kahn_after_relax(+u: U32, +du: U32, rptr: Array<U32>, rlen: Array<U32>, +qhead1: U32, +vis1: U32, +acc: U32, rs: RelaxSt) -> KahnWrap:
  RS{col1, wt1, indeg1, queue1, dist1, +qtail1} = rs
  +nacc = U32.xor(U32.mul(acc, 16777619), U32.xor(u, U32.shln(du, 8n)))
  KW{KS{rptr, rlen, col1, wt1, indeg1, queue1, dist1, qhead1, qtail1, vis1, nacc}, False{}}

def kahn_got_len(+u: U32, +du: U32, +e0: U32, +rdm: U32, rptr: Array<U32>, r: Array<U32> & U32, col: Array<U32>, wt: Array<U32>, indeg: Array<U32>, queue: Array<U32>, dist: Array<U32>, +qhead1: U32, +qtail: U32, +vis1: U32, +acc: U32) -> KahnWrap:
  (rlen, +len) = r
  kahn_after_relax(u, du, rptr, rlen, qhead1, vis1, acc, relax_loop(U32.to_nat(len), e0, du, rdm, RS{col, wt, indeg, queue, dist, qtail}))

def kahn_got_ptr(+u: U32, +du: U32, +rdm: U32, r: Array<U32> & U32, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>, indeg: Array<U32>, queue: Array<U32>, dist: Array<U32>, +qhead1: U32, +qtail: U32, +vis1: U32, +acc: U32) -> KahnWrap:
  (rptr, +e0) = r
  kahn_got_len(u, du, e0, rdm, rptr, Array.get(U32, rlen, u), col, wt, indeg, queue, dist, qhead1, qtail, vis1, acc)

def kahn_got_du(+u: U32, +rdm: U32, rptr: Array<U32>, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>, indeg: Array<U32>, queue: Array<U32>, r: Array<U32> & U32, +qhead1: U32, +qtail: U32, +vis1: U32, +acc: U32) -> KahnWrap:
  (dist, +du) = r
  kahn_got_ptr(u, du, rdm, Array.get(U32, rptr, u), rlen, col, wt, indeg, queue, dist, qhead1, qtail, vis1, acc)

def kahn_popped(+rdm: U32, rptr: Array<U32>, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>, indeg: Array<U32>, r: Array<U32> & U32, dist: Array<U32>, +qhead1: U32, +qtail: U32, +vis1: U32, +acc: U32) -> KahnWrap:
  (queue, +u) = r
  kahn_got_du(u, rdm, rptr, rlen, col, wt, indeg, queue, Array.get(U32, dist, u), qhead1, qtail, vis1, acc)

def kahn_step(has_more: Bool, +rdm: U32, ks: KahnSt) -> KahnWrap:
  match has_more:
    case True{}:
      KS{rptr, rlen, col, wt, indeg, queue, dist, +qhead, +qtail, +vis, +acc} = ks
      kahn_popped(rdm, rptr, rlen, col, wt, indeg, Array.get(U32, queue, qhead), dist, U32.inc(qhead), qtail, U32.inc(vis), acc)
    case False{}:
      KW{ks, True{}}

def kahn_dispatch(+rdm: U32, ks: KahnSt) -> KahnWrap:
  KS{rptr, rlen, col, wt, indeg, queue, dist, +qhead, +qtail, +vis, +acc} = ks
  kahn_step(U32.is_lt(qhead, qtail), rdm, KS{rptr, rlen, col, wt, indeg, queue, dist, qhead, qtail, vis, acc})

def kahn_loop(+rem: Nat, +rdm: U32, kw: KahnWrap) -> KahnSt:
  match rem:
    case 0n:
      KW{ks, done} = kw
      ks
    case 1n+p:
      KW{ks, done} = kw
      match done:
        case True{}:
          ks
        case False{}:
          kahn_loop(p, rdm, kahn_dispatch(rdm, ks))

def rd_after_kahn(indeg0: Array<U32>, ks: KahnSt) -> DagRun:
  KS{rptr, rlen, col, wt, indeg, queue, dist, +qhead, +qtail, +vis, +acc} = ks
  +acc1 = U32.xor(U32.mul(acc, 2654435761), vis)
  DR{rptr, rlen, col, wt, indeg0, indeg, queue, dist, acc1}

def rd_after_init(+rdm: U32, rptr: Array<U32>, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>, +acc: U32, iq: InitQ) -> DagRun:
  IQ{indeg0, indeg, queue, dist, +qtail} = iq
  rd_after_kahn(indeg0, kahn_loop(2048n, rdm, KW{KS{rptr, rlen, col, wt, indeg, queue, dist, 0, qtail, 0, acc}, False{}}))

def run_rounds(+rem: Nat, +rd: U32, dr: DagRun) -> U32:
  match rem:
    case 0n:
      DR{rptr, rlen, col, wt, indeg0, indeg, queue, dist, +acc} = dr
      acc
    case 1n+p:
      DR{rptr, rlen, col, wt, indeg0, indeg, queue, dist, +acc} = dr
      dr1 = rd_after_init(U32.and(rd, 3), rptr, rlen, col, wt, acc, init_q_loop(2048n, 0, rd, IQ{indeg0, indeg, queue, dist, 0}))
      run_rounds(p, U32.inc(rd), dr1)

def main_go(db: DagBuild) -> U32:
  DB{rptr, rlen, col, wt, indeg0, +epos, +seed} = db
  indeg = Array.new(U32, 11n, 0)
  queue = Array.new(U32, 11n, 0)
  dist = Array.new(U32, 11n, 0)
  run_rounds(70n, 0, DR{rptr, rlen, col, wt, indeg0, indeg, queue, dist, 2166136261})

def main() -> U32:
  rptr = Array.new(U32, 11n, 0)
  rlen = Array.new(U32, 11n, 0)
  col = Array.new(U32, 14n, 0)
  wt = Array.new(U32, 14n, 0)
  indeg0 = Array.new(U32, 11n, 0)
  main_go(build_dag(2048n, 0, DB{rptr, rlen, col, wt, indeg0, 0, 888777666}))
