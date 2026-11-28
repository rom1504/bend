import Base
# s3_polybench_floyd_warshall: Port of PolyBench/C 4.2.1 floyd-warshall (SMALL_DATASET)
# N=180 all-pairs shortest paths.

type HashSt is Type:
  HS{arr: Array<U32>, acc: U32}

def init_val(+i: U32, +j: U32) -> U32:
  +s = U32.add(i, j)
  +c1 = U32.is_eq(U32.mod(s, 13), 0)
  +c2 = U32.is_eq(U32.mod(s, 7), 0)
  +c3 = U32.is_eq(U32.mod(s, 11), 0)
  +base = U32.inc(U32.mod(U32.mul(i, j), 7))
  +v1 = Bool.pick(U32, c1, 999, base)
  +v2 = Bool.pick(U32, c2, 999, v1)
  Bool.pick(U32, c3, 999, v2)

def init_j(+rem: Nat, +i: U32, +j: U32, +row: U32, p: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      p
    case 1n+q:
      init_j(q, i, U32.inc(j), row, Array.set(U32, p, U32.add(row, j), init_val(i, j)))

def init_i(+rem: Nat, +i: U32, p: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      p
    case 1n+q:
      init_i(q, U32.inc(i), init_j(180n, i, 0, U32.mul(i, 180), p))

def fw_j2(+ij: U32, +pik: U32, +pij: U32, r: Array<U32> & U32) -> Array<U32>:
  (p2, +pkj) = r
  +cand = U32.add(pik, pkj)
  Array.set(U32, p2, ij, Bool.pick(U32, U32.is_lt(pij, cand), pij, cand))

def fw_j1(+ij: U32, +kj: U32, +pik: U32, r: Array<U32> & U32) -> Array<U32>:
  (p1, +pij) = r
  fw_j2(ij, pik, pij, Array.get(U32, p1, kj))

def fw_j(+rem: Nat, +ij: U32, +kj: U32, +pik: U32, p: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      p
    case 1n+q:
      fw_j(q, U32.inc(ij), U32.inc(kj), pik, fw_j1(ij, kj, pik, Array.get(U32, p, ij)))

def fw_i1(+irow: U32, +krow: U32, r: Array<U32> & U32) -> Array<U32>:
  (p1, +pik) = r
  fw_j(180n, irow, krow, pik, p1)

def fw_i(+rem: Nat, +i: U32, +k: U32, +krow: U32, p: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      p
    case 1n+q:
      +irow = U32.mul(i, 180)
      fw_i(q, U32.inc(i), k, krow, fw_i1(irow, krow, Array.get(U32, p, U32.add(irow, k))))

def fw_k(+rem: Nat, +k: U32, p: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      p
    case 1n+q:
      fw_k(q, U32.inc(k), fw_i(180n, 0, k, U32.mul(k, 180), p))

def hash_step(+acc: U32, r: Array<U32> & U32) -> HashSt:
  (arr1, +v) = r
  HS{arr1, U32.mul(U32.xor(acc, v), 16777619)}

def hash_p(+rem: Nat, +idx: U32, st: HashSt) -> U32:
  match rem:
    case 0n:
      HS{arr, +acc} = st
      acc
    case 1n+q:
      HS{arr, +acc} = st
      hash_p(q, U32.inc(idx), hash_step(acc, Array.get(U32, arr, idx)))

def main() -> U32:
  p0 = init_i(180n, 0, Array.new(U32, 15n, 0))
  p1 = fw_k(180n, 0, p0)
  hash_p(32400n, 0, HS{p1, 2166136261})
