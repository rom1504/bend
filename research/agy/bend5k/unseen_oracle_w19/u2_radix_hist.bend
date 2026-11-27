import Base
# u2_radix_hist: 2-pass 8-bit LSD radix sort (histogram + exclusive prefix-sum + scatter)
# Unseen benchmark testing indirect RMW indexing, dual-array scatter, and bounds/mask elision.
# N = 65536 U32 keys (16-bit), ROUNDS = 30 full 2-pass sorts.

type RadPair is Type:
  RPair{a: Array<U32>, b: Array<U32>}

type RadTri is Type:
  RTri{src: Array<U32>, dst: Array<U32>, hist: Array<U32>}

type RoundSt is Type:
  RSt{src: Array<U32>, dst: Array<U32>, hist: Array<U32>, acc: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def fill_keys(+n: Nat, +i: U32, +salt: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +v = U32.and(prng(U32.xor(U32.mul(U32.inc(i), 2654435761), salt)), 65535)
      fill_keys(p, U32.inc(i), salt, Array.swap(U32, a, i, v))

def zero_hist(+n: Nat, +i: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (h, old) = r
      h
    case 1n+p:
      (h, old) = r
      zero_hist(p, U32.inc(i), Array.swap(U32, h, i, 0))

def hist_bump(+b: U32, r: Array<U32> & U32) -> Array<U32>:
  (h, +c) = r
  Array.set(U32, h, b, U32.inc(c))

def build_hist.step(+sh: Nat, h: Array<U32>, r: Array<U32> & U32) -> RadPair:
  (src, +v) = r
  +b = U32.and(U32.shrn(v, sh), 255)
  RPair{src, hist_bump(b, Array.get(U32, h, b))}

def build_hist(+n: Nat, +i: U32, +sh: Nat, rp: RadPair) -> RadPair:
  match n:
    case 0n:
      rp
    case 1n+p:
      RPair{src, h} = rp
      build_hist(p, U32.inc(i), sh, build_hist.step(sh, h, Array.get(U32, src, i)))

def prefix_sum(+n: Nat, +i: U32, +acc: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (h, c) = r
      h
    case 1n+p:
      (h, +c) = r
      h2 = Array.set(U32, h, i, acc)
      prefix_sum(p, U32.inc(i), U32.add(acc, c), Array.get(U32, h2, U32.inc(i)))

def scatter_put(+v: U32, +b: U32, src: Array<U32>, dst: Array<U32>,
                r: Array<U32> & U32) -> RadTri:
  (h, +pos) = r
  h2 = Array.set(U32, h, b, U32.inc(pos))
  dst2 = Array.set(U32, dst, pos, v)
  RTri{src, dst2, h2}

def scatter.step(+sh: Nat, dst: Array<U32>, h: Array<U32>,
                 r: Array<U32> & U32) -> RadTri:
  (src, +v) = r
  +b = U32.and(U32.shrn(v, sh), 255)
  scatter_put(v, b, src, dst, Array.get(U32, h, b))

def scatter(+n: Nat, +i: U32, +sh: Nat, rt: RadTri) -> RadTri:
  match n:
    case 0n:
      rt
    case 1n+p:
      RTri{src, dst, h} = rt
      scatter(p, U32.inc(i), sh, scatter.step(sh, dst, h, Array.get(U32, src, i)))

def radix_pass.s2(+sh: Nat, dst: Array<U32>, rp: RadPair) -> RadTri:
  RPair{src1, h1} = rp
  h2 = prefix_sum(256n, 0, 0, Array.get(U32, h1, 0))
  scatter(65536n, 0, sh, RTri{src1, dst, h2})

def radix_pass(+sh: Nat, src: Array<U32>, dst: Array<U32>, h: Array<U32>) -> RadTri:
  h0 = zero_hist(256n, 0, (h, 0))
  radix_pass.s2(sh, dst, build_hist(65536n, 0, sh, RPair{src, h0}))

def hash_arr(+n: Nat, +i: U32, +acc: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  match n:
    case 0n:
      (a, v) = r
      (a, acc)
    case 1n+p:
      (a, +v) = r
      +nacc = U32.xor(U32.mul(acc, 2654435761), U32.add(v, i))
      hash_arr(p, U32.inc(i), nacc, Array.get(U32, a, U32.inc(i)))

def finish_round(dst2: Array<U32>, h2: Array<U32>, r: Array<U32> & U32) -> RoundSt:
  (src3, +nacc) = r
  RSt{src3, dst2, h2, nacc}

def do_hash(+acc: U32, t2: RadTri) -> RoundSt:
  RTri{dst2, src2, h2} = t2
  finish_round(dst2, h2, hash_arr(65536n, 0, acc, Array.get(U32, src2, 0)))

def do_pass2(+acc: U32, t1: RadTri) -> RoundSt:
  RTri{src1, dst1, h1} = t1
  do_hash(acc, radix_pass(8n, dst1, src1, h1))

def run_rounds(+rounds: Nat, +ridx: U32, st: RoundSt) -> U32:
  match rounds:
    case 0n:
      RSt{src, dst, h, acc} = st
      acc
    case 1n+p:
      RSt{src, dst, h, +acc} = st
      src0 = fill_keys(65536n, 0, U32.add(U32.mul(ridx, 7919), 13), (src, 0))
      run_rounds(p, U32.inc(ridx), do_pass2(acc, radix_pass(0n, src0, dst, h)))

def main() -> U32:
  src = Array.new(U32, 16n, 0)
  dst = Array.new(U32, 16n, 0)
  h = Array.new(U32, 8n, 0)
  run_rounds(60n, 1, RSt{src, dst, h, 2166136261})
