import Base
# s1_xxhash32: Port of Cyan4973/xxHash XXH32
# 4096-byte buffer (1024 LE U32 words), 24,000 iterated rounds.

type XxhSt is Type:
  XS{buf: Array<U32>, v1: U32, v2: U32, v3: U32, v4: U32}

type RoundSt is Type:
  RS{buf: Array<U32>, seed: U32}

def rotl(+x: U32, +n: Nat, +m: Nat) -> U32:
  U32.or(U32.shln(x, n), U32.shrn(x, m))

def xxh_round(+acc: U32, +inp: U32) -> U32:
  +a1 = U32.add(acc, U32.mul(inp, 2246822519))
  +a2 = rotl(a1, 13n, 19n)
  U32.mul(a2, 2654435761)

def fill_words(+rem: Nat, +i: U32, +s: U32, buf: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      buf
    case 1n+p:
      +s0 = U32.add(U32.mul(s, 1664525), 1013904223)
      +b0 = U32.shrn(s0, 24n)
      +s1 = U32.add(U32.mul(s0, 1664525), 1013904223)
      +b1 = U32.shrn(s1, 24n)
      +s2 = U32.add(U32.mul(s1, 1664525), 1013904223)
      +b2 = U32.shrn(s2, 24n)
      +s3 = U32.add(U32.mul(s2, 1664525), 1013904223)
      +b3 = U32.shrn(s3, 24n)
      +w = U32.or(U32.or(b0, U32.shln(b1, 8n)), U32.or(U32.shln(b2, 16n), U32.shln(b3, 24n)))
      fill_words(p, U32.inc(i), s3, Array.set(U32, buf, i, w))

def stripe_4(+v1: U32, +v2: U32, +v3: U32, +v4: U32, r: Array<U32> & U32) -> XxhSt:
  (buf4, +w3) = r
  XS{buf4, v1, v2, v3, xxh_round(v4, w3)}

def stripe_3(+i: U32, +v1: U32, +v2: U32, +v3: U32, +v4: U32, r: Array<U32> & U32) -> XxhSt:
  (buf3, +w2) = r
  stripe_4(v1, v2, xxh_round(v3, w2), v4, Array.get(U32, buf3, U32.add(i, 3)))

def stripe_2(+i: U32, +v1: U32, +v2: U32, +v3: U32, +v4: U32, r: Array<U32> & U32) -> XxhSt:
  (buf2, +w1) = r
  stripe_3(i, v1, xxh_round(v2, w1), v3, v4, Array.get(U32, buf2, U32.add(i, 2)))

def stripe_1(+i: U32, +v1: U32, +v2: U32, +v3: U32, +v4: U32, r: Array<U32> & U32) -> XxhSt:
  (buf1, +w0) = r
  stripe_2(i, xxh_round(v1, w0), v2, v3, v4, Array.get(U32, buf1, U32.add(i, 1)))

def stripe_loop(+rem: Nat, +i: U32, st: XxhSt) -> XxhSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      XS{buf, +v1, +v2, +v3, +v4} = st
      stripe_loop(p, U32.add(i, 4), stripe_1(i, v1, v2, v3, v4, Array.get(U32, buf, i)))

def finish_xxh(st: XxhSt) -> RoundSt:
  XS{buf1, +a1, +a2, +a3, +a4} = st
  +h0 = U32.add(U32.add(rotl(a1, 1n, 31n), rotl(a2, 7n, 25n)), U32.add(rotl(a3, 12n, 20n), rotl(a4, 18n, 14n)))
  +h1 = U32.add(h0, 4096)
  +h2 = U32.mul(U32.xor(h1, U32.shrn(h1, 15n)), 2246822519)
  +h3 = U32.mul(U32.xor(h2, U32.shrn(h2, 13n)), 3266489917)
  +h4 = U32.xor(h3, U32.shrn(h3, 16n))
  RS{buf1, h4}

def xxh32_once(buf: Array<U32>, +seed: U32) -> RoundSt:
  +v1 = U32.add(U32.add(seed, 2654435761), 2246822519)
  +v2 = U32.add(seed, 2246822519)
  +v3 = seed
  +v4 = U32.sub(seed, 2654435761)
  finish_xxh(stripe_loop(256n, 0, XS{buf, v1, v2, v3, v4}))

def run_rounds(+rem: Nat, st: RoundSt) -> U32:
  match rem:
    case 0n:
      RS{buf, +seed} = st
      seed
    case 1n+p:
      RS{buf, +seed} = st
      run_rounds(p, xxh32_once(buf, seed))

def main() -> U32:
  buf = fill_words(1024n, 0, 305419896, Array.new(U32, 10n, 0))
  run_rounds(24000n, RS{buf, 2654435761})
