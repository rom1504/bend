import Base
# k1_bsearch_branchless: Power-of-2 branchless lower-bound binary search over Array<U32>
# Fresh Non-Suite Kernel 1 (Wave 22): 16384 sorted U32s, 1,000,000 queries x 14 levels.

type BSt is Type:
  BS{arr: Array<U32>, seed: U32, acc: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def fill_sorted(+rem: Nat, +i: U32, +prev: U32, +seed: U32, arr: Array<U32>) -> BSt:
  match rem:
    case 0n:
      BS{arr, seed, prev}
    case 1n+p:
      +ns = prng(seed)
      +nv = U32.add(prev, U32.inc(U32.and(ns, 15)))
      fill_sorted(p, U32.inc(i), nv, ns, Array.set(U32, arr, i, nv))

def choose_lo(le: Bool, +lo: U32, +cand: U32) -> U32:
  match le:
    case True{}:
      cand
    case False{}:
      lo

def bsearch_step(+rem: Nat, +lo: U32, +step: U32, +key: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  match rem:
    case 0n:
      (arr, +v) = r
      +nlo = choose_lo(U32.is_le(v, key), lo, U32.add(lo, step))
      (arr, nlo)
    case 1n+p:
      (arr, +v) = r
      +nlo = choose_lo(U32.is_le(v, key), lo, U32.add(lo, step))
      +nstep = U32.shrn(step, 1n)
      bsearch_step(p, nlo, nstep, key, Array.get(U32, arr, U32.add(nlo, nstep)))

def finish_query(+acc: U32, +ns: U32, +idx: U32, r: Array<U32> & U32) -> BSt:
  (arr, +v) = r
  +nacc = U32.xor(U32.mul(acc, 16777619), U32.xor(idx, v))
  BS{arr, ns, nacc}

def after_search(+acc: U32, +ns: U32, r: Array<U32> & U32) -> BSt:
  (arr, +idx) = r
  finish_query(acc, ns, idx, Array.get(U32, arr, idx))

def run_queries(+rem: Nat, +maxv: U32, st: BSt) -> BSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      BS{arr, +seed, +acc} = st
      +ns = prng(seed)
      +key = U32.and(ns, maxv)
      run_queries(p, maxv, after_search(acc, ns, bsearch_step(13n, 0, 8192, key, Array.get(U32, arr, 8192))))

def extract_acc(st: BSt) -> U32:
  BS{arr2, +s2, +acc} = st
  acc

def start_queries(st: BSt) -> U32:
  BS{arr, +seed, +maxv} = st
  extract_acc(run_queries(1000000n, 131071, BS{arr, seed, 2166136261}))

def main() -> U32:
  arr = Array.new(U32, 14n, 0)
  start_queries(fill_sorted(16384n, 0, 0, 2463534242, arr))
