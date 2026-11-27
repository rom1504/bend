import Base
# t1_csr_dijkstra_relax (skew): Weighted CSR graph shortest-path relaxation over Array<U32>
# Sealed-Test family 1: V = 2048 hub-heavy power-law CSR graph, 14 sources x 12 sweeps.

type Graph is Type:
  Gr{rptr: Array<U32>, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>, dist: Array<U32>, relax: U32}

type InitGr is Type:
  IGr{rptr: Array<U32>, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def deg_sel2(c: Bool) -> U32:
  match c:
    case True{}:
      12
    case False{}:
      4

def deg_sel1(c: Bool, +u: U32) -> U32:
  match c:
    case True{}:
      32
    case False{}:
      deg_sel2(U32.is_zero(U32.and(u, 3)))

def fill_edges(+rem: Nat, +u: U32, +e: U32, ig: InitGr) -> InitGr:
  match rem:
    case 0n:
      ig
    case 1n+p:
      IGr{rptr, rlen, col, wt} = ig
      +r = prng(U32.xor(U32.mul(U32.inc(e), 2654435761), 97))
      +dst = U32.and(U32.add(U32.inc(u), U32.and(r, 127)), 2047)
      +w = U32.inc(U32.and(U32.shrn(r, 8n), 31))
      fill_edges(p, u, U32.inc(e), IGr{rptr, rlen, Array.set(U32, col, e, dst), Array.set(U32, wt, e, w)})

def build_graph(+rem: Nat, +u: U32, +off: U32, ig: InitGr) -> InitGr:
  match rem:
    case 0n:
      ig
    case 1n+p:
      IGr{rptr, rlen, col, wt} = ig
      +deg = deg_sel1(U32.is_zero(U32.and(u, 15)), u)
      ig2 = fill_edges(U32.to_nat(deg), u, off, IGr{Array.set(U32, rptr, u, off), Array.set(U32, rlen, u, deg), col, wt})
      build_graph(p, U32.inc(u), U32.add(off, deg), ig2)

def init_val(is_src: Bool) -> U32:
  match is_src:
    case True{}:
      0
    case False{}:
      1000000000

def reset_dist(+rem: Nat, +u: U32, +src: U32, d: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      d
    case 1n+p:
      reset_dist(p, U32.inc(u), src, Array.set(U32, d, u, init_val(U32.is_eq(u, src))))

def maybe_relax(lt: Bool, +v: U32, +cand: U32, d: Array<U32>, +relax: U32) -> Array<U32> & U32:
  match lt:
    case True{}:
      (Array.set(U32, d, v, cand), U32.inc(relax))
    case False{}:
      (d, relax)

def pack_graph(rptr: Array<U32>, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>, dr: Array<U32> & U32) -> Graph:
  (dist1, +nrelax) = dr
  Gr{rptr, rlen, col, wt, dist1, nrelax}

def relax_dv(+v: U32, +cand: U32, rd: Array<U32> & U32, rptr: Array<U32>, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>, +relax: U32) -> Graph:
  (dist, +dv) = rd
  pack_graph(rptr, rlen, col, wt, maybe_relax(U32.is_lt(cand, dv), v, cand, dist, relax))

def relax_w(+du: U32, +v: U32, rw: Array<U32> & U32, rptr: Array<U32>, rlen: Array<U32>, col: Array<U32>, dist: Array<U32>, +relax: U32) -> Graph:
  (wt, +w) = rw
  +cand = U32.add(du, w)
  relax_dv(v, cand, Array.get(U32, dist, v), rptr, rlen, col, wt, relax)

def relax_v(+du: U32, +e: U32, rc: Array<U32> & U32, rptr: Array<U32>, rlen: Array<U32>, wt: Array<U32>, dist: Array<U32>, +relax: U32) -> Graph:
  (col, +v) = rc
  relax_w(du, v, Array.get(U32, wt, e), rptr, rlen, col, dist, relax)

def relax_edges(+rem: Nat, +e: U32, +du: U32, gr: Graph) -> Graph:
  match rem:
    case 0n:
      gr
    case 1n+p:
      Gr{rptr, rlen, col, wt, dist, +relax} = gr
      relax_edges(p, U32.inc(e), du, relax_v(du, e, Array.get(U32, col, e), rptr, rlen, wt, dist, relax))

def relax_u_len(+base: U32, +du: U32, rl: Array<U32> & U32, rptr: Array<U32>, col: Array<U32>, wt: Array<U32>, dist: Array<U32>, +relax: U32) -> Graph:
  (rlen, +len) = rl
  relax_edges(U32.to_nat(len), base, du, Gr{rptr, rlen, col, wt, dist, relax})

def relax_u_base(+u: U32, +du: U32, rp: Array<U32> & U32, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>, dist: Array<U32>, +relax: U32) -> Graph:
  (rptr, +base) = rp
  relax_u_len(base, du, Array.get(U32, rlen, u), rptr, col, wt, dist, relax)

def check_reachable(ok: Bool, +u: U32, +du: U32, gr: Graph) -> Graph:
  match ok:
    case True{}:
      Gr{rptr, rlen, col, wt, dist, +relax} = gr
      relax_u_base(u, du, Array.get(U32, rptr, u), rlen, col, wt, dist, relax)
    case False{}:
      gr

def step_vertex(+u: U32, rd: Array<U32> & U32, rptr: Array<U32>, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>, +relax: U32) -> Graph:
  (dist, +du) = rd
  check_reachable(U32.is_lt(du, 1000000000), u, du, Gr{rptr, rlen, col, wt, dist, relax})

def sweep_vertices(+rem: Nat, +u: U32, gr: Graph) -> Graph:
  match rem:
    case 0n:
      gr
    case 1n+p:
      Gr{rptr, rlen, col, wt, dist, +relax} = gr
      sweep_vertices(p, U32.inc(u), step_vertex(u, Array.get(U32, dist, u), rptr, rlen, col, wt, relax))

def run_sweeps(+rem: Nat, gr: Graph) -> Graph:
  match rem:
    case 0n:
      gr
    case 1n+p:
      run_sweeps(p, sweep_vertices(2048n, 0, gr))

def hash_dist(+rem: Nat, +u: U32, +h: U32, rd: Array<U32> & U32) -> Array<U32> & U32:
  match rem:
    case 0n:
      (d, v) = rd
      (d, h)
    case 1n+p:
      (d, +v) = rd
      hash_dist(p, U32.inc(u), U32.xor(U32.mul(h, 16777619), v), Array.get(U32, d, U32.inc(u)))

def finish_source(rptr: Array<U32>, rlen: Array<U32>, col: Array<U32>, wt: Array<U32>, +relax: U32, dh: Array<U32> & U32) -> Graph & U32:
  (dist3, +nth) = dh
  (Gr{rptr, rlen, col, wt, dist3, relax}, nth)

def hash_after_sweeps(+th: U32, gr: Graph) -> Graph & U32:
  Gr{rptr2, rlen2, col2, wt2, dist2, +relax2} = gr
  finish_source(rptr2, rlen2, col2, wt2, relax2, hash_dist(2048n, 0, th, Array.get(U32, dist2, 0)))

def run_sources(+rem: Nat, +s: U32, gh: Graph & U32) -> U32:
  match rem:
    case 0n:
      (gr, +th) = gh
      Gr{rptr, rlen, col, wt, dist, +relax} = gr
      U32.xor(th, U32.mul(relax, 2654435761))
    case 1n+p:
      (gr, +th) = gh
      Gr{rptr, rlen, col, wt, dist, +relax} = gr
      +src = U32.and(U32.mul(s, 173), 2047)
      dist1 = reset_dist(2048n, 0, src, dist)
      run_sources(p, U32.inc(s), hash_after_sweeps(th, run_sweeps(12n, Gr{rptr, rlen, col, wt, dist1, relax})))

def start_main(ig: InitGr) -> U32:
  IGr{rptr, rlen, col, wt} = ig
  dist = Array.new(U32, 11n, 1000000000)
  run_sources(28n, 0, (Gr{rptr, rlen, col, wt, dist, 0}, 2166136261))

def main() -> U32:
  start_main(build_graph(2048n, 0, 0, IGr{Array.new(U32, 11n, 0), Array.new(U32, 11n, 0), Array.new(U32, 14n, 0), Array.new(U32, 14n, 0)}))
