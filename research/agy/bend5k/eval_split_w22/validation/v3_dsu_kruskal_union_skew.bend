import Base
# v3_dsu_kruskal_union (skew): Disjoint-Set Union (path halving + union by rank)
# Validation family 3: N = 4096 nodes, 80 rounds x 8192 chain/cluster-biased edges.

type DsuSt is Type:
  DS{par: Array<U32>, rnk: Array<U32>, acc: U32, merges: U32, cycles: U32, seed: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

type PairArr is Type:
  PA{par: Array<U32>, rnk: Array<U32>}

type FindOut is Type:
  FO{par: Array<U32>, root: U32}

def reset_dsu(+rem: Nat, +i: U32, par: Array<U32>, rnk: Array<U32>) -> PairArr:
  match rem:
    case 0n:
      PA{par, rnk}
    case 1n+p:
      reset_dsu(p, U32.inc(i), Array.set(U32, par, i, i), Array.set(U32, rnk, i, 0))

type FindStep is Type:
  FSt{par: Array<U32>, cur: U32, done: Bool}

def find_step2(+x: U32, r2: Array<U32> & U32) -> FindStep:
  (par, +ppx) = r2
  FSt{Array.set(U32, par, x, ppx), ppx, False{}}

def find_branch(done: Bool, +x: U32, +px: U32, par: Array<U32>) -> FindStep:
  match done:
    case True{}:
      FSt{par, x, True{}}
    case False{}:
      find_step2(x, Array.get(U32, par, px))

def find_step1(+x: U32, r1: Array<U32> & U32) -> FindStep:
  (par, +px) = r1
  find_branch(U32.is_eq(px, x), x, px, par)

def dsu_find_go(+rem: Nat, fs: FindStep) -> FindOut:
  match rem:
    case 0n:
      FSt{par, +cur, done} = fs
      FO{par, cur}
    case 1n+p:
      FSt{par, +cur, done} = fs
      match done:
        case True{}:
          FO{par, cur}
        case False{}:
          dsu_find_go(p, find_step1(cur, Array.get(U32, par, cur)))

def dsu_find(+x: U32, par: Array<U32>) -> FindOut:
  dsu_find_go(16n, FSt{par, x, False{}})

def union_gt(
  gt: Bool, +ru: U32, +rv: U32, +rku: U32,
  +acc: U32, +merges: U32, +cycles: U32, +seed: U32,
  par: Array<U32>, rnk: Array<U32>
) -> DsuSt:
  match gt:
    case True{}:
      DS{Array.set(U32, par, rv, ru), rnk, acc, merges, cycles, seed}
    case False{}:
      DS{Array.set(U32, par, rv, ru), Array.set(U32, rnk, ru, U32.inc(rku)), acc, merges, cycles, seed}

def union_lt(
  lt: Bool, +ru: U32, +rv: U32, +rku: U32, +rkv: U32,
  +acc: U32, +merges: U32, +cycles: U32, +seed: U32,
  par: Array<U32>, rnk: Array<U32>
) -> DsuSt:
  match lt:
    case True{}:
      DS{Array.set(U32, par, ru, rv), rnk, acc, merges, cycles, seed}
    case False{}:
      union_gt(U32.is_gt(rku, rkv), ru, rv, rku, acc, merges, cycles, seed, par, rnk)

def union_rkv(
  +ru: U32, +rv: U32, +rku: U32,
  +acc: U32, +merges: U32, +cycles: U32, +seed: U32,
  par: Array<U32>, r2: Array<U32> & U32
) -> DsuSt:
  (rnk, +rkv) = r2
  union_lt(U32.is_lt(rku, rkv), ru, rv, rku, rkv, acc, merges, cycles, seed, par, rnk)

def union_rku(
  +ru: U32, +rv: U32,
  +acc: U32, +merges: U32, +cycles: U32, +seed: U32,
  par: Array<U32>, r1: Array<U32> & U32
) -> DsuSt:
  (rnk, +rku) = r1
  union_rkv(ru, rv, rku, acc, merges, cycles, seed, par, Array.get(U32, rnk, rv))

def union_roots(
  same: Bool, +ru: U32, +rv: U32,
  +acc: U32, +merges: U32, +cycles: U32, +seed: U32,
  par: Array<U32>, rnk: Array<U32>
) -> DsuSt:
  match same:
    case True{}:
      +nacc = U32.xor(U32.mul(acc, 16777619), ru)
      DS{par, rnk, nacc, merges, U32.inc(cycles), seed}
    case False{}:
      +nacc = U32.xor(U32.xor(U32.mul(acc, 2654435761), ru), U32.shln(rv, 12n))
      union_rku(ru, rv, nacc, U32.inc(merges), cycles, seed, par, Array.get(U32, rnk, ru))

def sel_u32(cond: Bool, +t: U32, +f: U32) -> U32:
  match cond:
    case True{}:
      t
    case False{}:
      f

def edge_after_v(
  +ru: U32, +acc: U32, +merges: U32, +cycles: U32, +ns: U32,
  rnk: Array<U32>, fv: FindOut
) -> DsuSt:
  FO{par2, +rv} = fv
  union_roots(U32.is_eq(ru, rv), ru, rv, acc, merges, cycles, ns, par2, rnk)

def edge_after_u(
  +v: U32, +acc: U32, +merges: U32, +cycles: U32, +ns: U32,
  rnk: Array<U32>, fu: FindOut
) -> DsuSt:
  FO{par1, +ru} = fu
  edge_after_v(ru, acc, merges, cycles, ns, rnk, dsu_find(v, par1))

def run_edges(+rem: Nat, +e: U32, +salt: U32, st: DsuSt) -> DsuSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      DS{par, rnk, +acc, +merges, +cycles, +seed} = st
      +ns = prng(seed)
      +base = U32.and(U32.add(e, salt), 4095)
      +is_chain = U32.is_ne(U32.and(ns, 7), 0)
      +u = sel_u32(is_chain, base, U32.and(ns, 4095))
      +v = sel_u32(is_chain, U32.and(U32.add(U32.inc(base), U32.and(ns, 3)), 4095), U32.and(U32.shrn(ns, 12n), 4095))
      run_edges(p, U32.inc(e), salt, edge_after_u(v, acc, merges, cycles, ns, rnk, dsu_find(u, par)))

def round_after_reset(+rd: U32, +acc: U32, +merges: U32, +cycles: U32, +seed: U32, pa: PairArr) -> DsuSt:
  PA{par0, rnk0} = pa
  run_edges(8192n, 0, U32.mul(rd, 10007), DS{par0, rnk0, acc, merges, cycles, seed})

def run_rounds(+rem: Nat, +rd: U32, st: DsuSt) -> U32:
  match rem:
    case 0n:
      DS{par, rnk, +acc, +merges, +cycles, +seed} = st
      U32.add(U32.xor(acc, U32.mul(merges, 2654435761)), U32.mul(cycles, 2246822519))
    case 1n+p:
      DS{par, rnk, +acc, +merges, +cycles, +seed} = st
      run_rounds(p, U32.inc(rd), round_after_reset(rd, acc, merges, cycles, seed, reset_dsu(4096n, 0, par, rnk)))

def main() -> U32:
  par = Array.new(U32, 12n, 0)
  rnk = Array.new(U32, 12n, 0)
  run_rounds(80n, 0, DS{par, rnk, 2166136261, 0, 0, 987654321})
