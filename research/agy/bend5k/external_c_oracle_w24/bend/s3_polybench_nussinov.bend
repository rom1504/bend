import Base
# s3_polybench_nussinov: Port of PolyBench/C 4.2.1 nussinov (MEDIUM_DATASET)
# N=500 RNA secondary structure 2D DP.

type NSt is Type:
  NS{tab: Array<U32>, best: U32}

type HashSt is Type:
  HS{arr: Array<U32>, acc: U32}

def max_u32(+a: U32, +b: U32) -> U32:
  Bool.pick(U32, U32.is_ge(a, b), a, b)

def base_match(+i: U32, +j: U32) -> U32:
  +si = U32.and(U32.inc(i), 3)
  +sj = U32.and(U32.inc(j), 3)
  Bool.pick(U32, U32.is_eq(U32.add(si, sj), 3), 1, 0)

def k_step2(+best: U32, +tik: U32, r: Array<U32> & U32) -> NSt:
  (tab2, +tk1j) = r
  NS{tab2, max_u32(best, U32.add(tik, tk1j))}

def k_step1(+k: U32, +j: U32, +best: U32, r: Array<U32> & U32) -> NSt:
  (tab1, +tik) = r
  k_step2(best, tik, Array.get(U32, tab1, U32.add(U32.mul(U32.inc(k), 500), j)))

def k_loop(+rem: Nat, +k: U32, +irow: U32, +j: U32, st: NSt) -> NSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      NS{tab, +best} = st
      k_loop(p, U32.inc(k), irow, j, k_step1(k, j, best, Array.get(U32, tab, U32.add(irow, k))))

def j_store(+ij: U32, st: NSt) -> Array<U32>:
  NS{tab, +best} = st
  Array.set(U32, tab, ij, best)

def j_diag(+i: U32, +j: U32, +irow: U32, +ij: U32, +best: U32, r: Array<U32> & U32) -> Array<U32>:
  (tab3, +td) = r
  +bonus = Bool.pick(U32, U32.is_lt(U32.inc(i), j), base_match(i, j), 0)
  +b3 = max_u32(best, U32.add(td, bonus))
  +kcnt = U32.to_nat(U32.sub(U32.sub(j, i), 1))
  j_store(ij, k_loop(kcnt, U32.inc(i), irow, j, NS{tab3, b3}))

def j_down(+i: U32, +j: U32, +irow: U32, +i1row: U32, +ij: U32, +best: U32, r: Array<U32> & U32) -> Array<U32>:
  (tab2, +tdown) = r
  +b2 = max_u32(best, tdown)
  j_diag(i, j, irow, ij, b2, Array.get(U32, tab2, U32.add(i1row, U32.sub(j, 1))))

def j_left(+i: U32, +j: U32, +irow: U32, +i1row: U32, +ij: U32, r: Array<U32> & U32) -> Array<U32>:
  (tab1, +tleft) = r
  j_down(i, j, irow, i1row, ij, tleft, Array.get(U32, tab1, U32.add(i1row, j)))

def j_loop(+rem: Nat, +i: U32, +j: U32, +irow: U32, +i1row: U32, tab: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      tab
    case 1n+p:
      +ij = U32.add(irow, j)
      j_loop(p, i, U32.inc(j), irow, i1row, j_left(i, j, irow, i1row, ij, Array.get(U32, tab, U32.sub(ij, 1))))

def i_loop(+rem: Nat, +i: U32, tab: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      tab
    case 1n+p:
      +irow = U32.mul(i, 500)
      +i1row = U32.add(irow, 500)
      +jcnt = U32.to_nat(U32.sub(499, i))
      i_loop(p, U32.sub(i, 1), j_loop(jcnt, i, U32.inc(i), irow, i1row, tab))

def hash_step(+acc: U32, r: Array<U32> & U32) -> HashSt:
  (arr1, +v) = r
  HS{arr1, U32.mul(U32.xor(acc, v), 16777619)}

def hash_j(+rem: Nat, +idx: U32, st: HashSt) -> HashSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      HS{arr, +acc} = st
      hash_j(p, U32.inc(idx), hash_step(acc, Array.get(U32, arr, idx)))

def hash_i(+rem: Nat, +i: U32, st: HashSt) -> U32:
  match rem:
    case 0n:
      HS{arr, +acc} = st
      acc
    case 1n+p:
      +start = U32.add(U32.mul(i, 500), i)
      +cnt = U32.to_nat(U32.sub(500, i))
      hash_i(p, U32.inc(i), hash_j(cnt, start, st))

def main() -> U32:
  tab0 = Array.new(U32, 18n, 0)
  # i runs from N-2 (498) down to 0 (i=499 has no j > i)
  tab1 = i_loop(499n, 498, tab0)
  hash_i(500n, 0, HS{tab1, 2166136261})
