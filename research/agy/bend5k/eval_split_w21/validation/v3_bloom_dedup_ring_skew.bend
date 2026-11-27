import Base
# v3_bloom_dedup_ring (skew): 3-probe bit-packed Bloom filter + circular ring-buffer dedup
# Validation family 3: hot-set skewed key stream (~75% hot keys), 24 rounds x 65536 keys.

type DedupSt is Type:
  DSt{bloom: Array<U32>, ring: Array<U32>, head: U32, hits: U32, uniques: U32, acc: U32, seed: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def sel_key(hot: Bool, +ns: U32) -> U32:
  match hot:
    case True{}:
      U32.and(U32.shrn(ns, 3n), 511)
    case False{}:
      U32.and(U32.shrn(ns, 3n), 65535)

def ring_insert(
  +k: U32, +head: U32, +hits: U32, +uniques: U32, +acc: U32, +seed: U32,
  bloom: Array<U32>, rr: Array<U32> & U32
) -> DedupSt:
  (ring, +ev) = rr
  +nhead = U32.and(U32.inc(head), 1023)
  +nacc = U32.xor(U32.xor(U32.mul(acc, 2654435761), ev), k)
  DSt{bloom, ring, nhead, hits, U32.inc(uniques), nacc, seed}

def finish_key(
  all_hit: Bool, +k: U32, +head: U32, +hits: U32, +uniques: U32, +acc: U32, +seed: U32,
  bloom: Array<U32>, ring: Array<U32>
) -> DedupSt:
  match all_hit:
    case True{}:
      DSt{bloom, ring, head, U32.inc(hits), uniques, U32.xor(U32.mul(acc, 16777619), k), seed}
    case False{}:
      ring_insert(k, head, hits, uniques, acc, seed, bloom, Array.swap(U32, ring, head, k))

def bool_and(a: Bool, b: Bool) -> Bool:
  match a:
    case True{}:
      b
    case False{}:
      False{}

def probe2(
  +w2: U32, +m2: U32, hit01: Bool, +k: U32, +head: U32, +hits: U32, +uniques: U32, +acc: U32, +seed: U32,
  rb: Array<U32> & U32, ring: Array<U32>
) -> DedupSt:
  (bloom, +old2) = rb
  +hit2 = U32.is_ne(U32.and(old2, m2), 0)
  bloom1 = Array.set(U32, bloom, w2, U32.or(old2, m2))
  finish_key(bool_and(hit01, hit2), k, head, hits, uniques, acc, seed, bloom1, ring)

def probe1(
  +w1: U32, +m1: U32, +w2: U32, +m2: U32, hit0: Bool,
  +k: U32, +head: U32, +hits: U32, +uniques: U32, +acc: U32, +seed: U32,
  rb: Array<U32> & U32, ring: Array<U32>
) -> DedupSt:
  (bloom, +old1) = rb
  +hit1 = U32.is_ne(U32.and(old1, m1), 0)
  bloom1 = Array.set(U32, bloom, w1, U32.or(old1, m1))
  probe2(w2, m2, bool_and(hit0, hit1), k, head, hits, uniques, acc, seed, Array.get(U32, bloom1, w2), ring)

def probe0(
  +w0: U32, +m0: U32, +w1: U32, +m1: U32, +w2: U32, +m2: U32,
  +k: U32, +head: U32, +hits: U32, +uniques: U32, +acc: U32, +seed: U32,
  rb: Array<U32> & U32, ring: Array<U32>
) -> DedupSt:
  (bloom, +old0) = rb
  +hit0 = U32.is_ne(U32.and(old0, m0), 0)
  bloom1 = Array.set(U32, bloom, w0, U32.or(old0, m0))
  probe1(w1, m1, w2, m2, hit0, k, head, hits, uniques, acc, seed, Array.get(U32, bloom1, w1), ring)

def step_keys(+rem: Nat, +salt: U32, st: DedupSt) -> DedupSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      DSt{bloom, ring, +head, +hits, +uniques, +acc, +seed} = st
      +ns = prng(seed)
      +raw_k = sel_key(U32.is_lt(U32.and(ns, 7), 6), ns)
      +k = U32.xor(raw_k, salt)
      +h1 = U32.xor(U32.mul(k, 2654435761), U32.shrn(k, 16n))
      +h2 = U32.or(U32.xor(U32.mul(k, 2246822519), U32.shrn(k, 13n)), 1)
      +p0 = U32.and(h1, 32767)
      +p1 = U32.and(U32.add(h1, h2), 32767)
      +p2 = U32.and(U32.add(h1, U32.shln(h2, 1n)), 32767)
      +w0 = U32.shrn(p0, 5n)
      +m0 = U32.shln(1, U32.to_nat(U32.and(p0, 31)))
      +w1 = U32.shrn(p1, 5n)
      +m1 = U32.shln(1, U32.to_nat(U32.and(p1, 31)))
      +w2 = U32.shrn(p2, 5n)
      +m2 = U32.shln(1, U32.to_nat(U32.and(p2, 31)))
      step_keys(p, salt, probe0(w0, m0, w1, m1, w2, m2, k, head, hits, uniques, acc, ns, Array.get(U32, bloom, w0), ring))

def decay_word(+i: U32, +mask: U32, r: Array<U32> & U32) -> Array<U32>:
  (a, +v) = r
  Array.set(U32, a, i, U32.and(v, mask))

def decay_bloom(+rem: Nat, +i: U32, +mask: U32, a: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      a
    case 1n+p:
      decay_bloom(p, U32.inc(i), mask, decay_word(i, mask, Array.get(U32, a, i)))

def decay_mask(odd: Bool) -> U32:
  match odd:
    case True{}:
      1431655765
    case False{}:
      2863311530

def apply_decay(+rd: U32, st: DedupSt) -> DedupSt:
  DSt{bloom, ring, +head, +hits, +uniques, +acc, +seed} = st
  +mask = decay_mask(U32.is_ne(U32.and(rd, 1), 0))
  bloom1 = decay_bloom(1024n, 0, mask, bloom)
  DSt{bloom1, ring, head, hits, uniques, acc, seed}

def run_rounds(+rem: Nat, +rd: U32, st: DedupSt) -> U32:
  match rem:
    case 0n:
      DSt{bloom, ring, +head, +hits, +uniques, +acc, +seed} = st
      U32.add(U32.add(U32.xor(acc, U32.mul(hits, 2654435761)), U32.mul(uniques, 2246822519)), head)
    case 1n+p:
      run_rounds(p, U32.inc(rd), apply_decay(rd, step_keys(65536n, U32.mul(rd, 10007), st)))

def main() -> U32:
  bloom = Array.new(U32, 10n, 0)
  ring = Array.new(U32, 10n, 0)
  run_rounds(24n, 0, DSt{bloom, ring, 0, 0, 0, 2166136261, 987654321})
