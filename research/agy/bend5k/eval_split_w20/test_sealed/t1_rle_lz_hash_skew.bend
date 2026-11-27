import Base
# t1_rle_lz_hash (skew): Sliding-window LZ77-style hash-table match finder over Array<U32>
# Sealed-Test family 1: N = 32768 high-repetition symbols, 130 rounds.

type LzSt is Type:
  LSt{src: Array<U32>, ht: Array<U32>, h: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def fill_src(+n: Nat, +i: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +rv = prng(U32.add(U32.mul(U32.inc(i), 2654435761), 73))
      +v = U32.and(U32.xor(U32.shrn(i, 2n), rv), 7)
      fill_src(p, U32.inc(i), Array.swap(U32, a, i, v))

def update_hash(eq: Bool, +i: U32, +prev: U32, +s0: U32, +s1: U32, +salt: U32, +h: U32) -> U32:
  match eq:
    case True{}:
      +dist = U32.sub(i, prev)
      U32.xor(U32.mul(U32.xor(h, U32.inc(dist)), 16777619), U32.add(s1, salt))
    case False{}:
      U32.mul(U32.xor(h, U32.add(s0, 17)), 16777619)

def step_sp(+i: U32, +prev: U32, +s0: U32, +s1: U32, +salt: U32, +h: U32, rs: Array<U32> & U32, ht: Array<U32>) -> LzSt:
  (src, +sp) = rs
  +nh = update_hash(U32.is_eq(sp, s0), i, prev, s0, s1, salt, h)
  LSt{src, ht, nh}

def step_ht(+i: U32, +s0: U32, +s1: U32, +salt: U32, +h: U32, src: Array<U32>, rh: Array<U32> & U32) -> LzSt:
  (ht, +prev) = rh
  step_sp(i, prev, s0, s1, salt, h, Array.get(U32, src, prev), ht)

def step_s2(+i: U32, +s0: U32, +s1: U32, +salt: U32, +h: U32, rs: Array<U32> & U32, ht: Array<U32>) -> LzSt:
  (src, +s2) = rs
  +h0 = U32.xor(U32.xor(U32.mul(s0, 2654435761), U32.mul(s1, 2246822519)), U32.mul(s2, 3266489917))
  +hv = U32.and(U32.shrn(h0, 20n), 4095)
  step_ht(i, s0, s1, salt, h, src, Array.swap(U32, ht, hv, i))

def step_s1(+i: U32, +s0: U32, +salt: U32, +h: U32, rs: Array<U32> & U32, ht: Array<U32>) -> LzSt:
  (src, +s1) = rs
  step_s2(i, s0, s1, salt, h, Array.get(U32, src, U32.add(i, 2)), ht)

def step_s0(+i: U32, +salt: U32, +h: U32, rs: Array<U32> & U32, ht: Array<U32>) -> LzSt:
  (src, +s0) = rs
  step_s1(i, s0, salt, h, Array.get(U32, src, U32.inc(i)), ht)

def scan_lz(+rem: Nat, +i: U32, +salt: U32, st: LzSt) -> LzSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      LSt{src, ht, +h} = st
      scan_lz(p, U32.inc(i), salt, step_s0(i, salt, h, Array.get(U32, src, i), ht))

def run_rounds(+rem: Nat, +r_idx: U32, st: LzSt) -> U32:
  match rem:
    case 0n:
      LSt{src, ht, +h} = st
      h
    case 1n+p:
      run_rounds(p, U32.inc(r_idx), scan_lz(32766n, 0, U32.mul(r_idx, 16777619), st))

def main() -> U32:
  src = fill_src(32768n, 0, (Array.new(U32, 15n, 0), 0))
  ht = Array.new(U32, 12n, 0)
  run_rounds(130n, 0, LSt{src, ht, 2166136261})
