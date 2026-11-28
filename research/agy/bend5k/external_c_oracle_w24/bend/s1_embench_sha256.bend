import Base
# s1_embench_sha256: Port of Embench-IoT nettle-sha256 (nettle-sha256.c)
# FIPS 180-4 SHA-256 iterated 24,000 times on 32-byte state.

type ShaState is Type:
  SS{k: Array<U32>, w: Array<U32>, h0: U32, h1: U32, h2: U32, h3: U32, h4: U32, h5: U32, h6: U32, h7: U32}

type CompSt is Type:
  CS{k: Array<U32>, w: Array<U32>, a: U32, b: U32, c: U32, d: U32, e: U32, f: U32, g: U32, h: U32}

def rotr(+x: U32, +n: Nat, +m: Nat) -> U32:
  U32.or(U32.shrn(x, n), U32.shln(x, m))

def set_k(a: Array<U32>) -> Array<U32>:
  a = Array.set(U32, a, 0, 1116352408)
  a = Array.set(U32, a, 1, 1899447441)
  a = Array.set(U32, a, 2, 3049323471)
  a = Array.set(U32, a, 3, 3921009573)
  a = Array.set(U32, a, 4, 961987163)
  a = Array.set(U32, a, 5, 1508970993)
  a = Array.set(U32, a, 6, 2453635748)
  a = Array.set(U32, a, 7, 2870763221)
  a = Array.set(U32, a, 8, 3624381080)
  a = Array.set(U32, a, 9, 310598401)
  a = Array.set(U32, a, 10, 607225278)
  a = Array.set(U32, a, 11, 1426881987)
  a = Array.set(U32, a, 12, 1925078388)
  a = Array.set(U32, a, 13, 2162078206)
  a = Array.set(U32, a, 14, 2614888103)
  a = Array.set(U32, a, 15, 3248222580)
  a = Array.set(U32, a, 16, 3835390401)
  a = Array.set(U32, a, 17, 4022224774)
  a = Array.set(U32, a, 18, 264347078)
  a = Array.set(U32, a, 19, 604807628)
  a = Array.set(U32, a, 20, 770255983)
  a = Array.set(U32, a, 21, 1249150122)
  a = Array.set(U32, a, 22, 1555081692)
  a = Array.set(U32, a, 23, 1996064986)
  a = Array.set(U32, a, 24, 2554220882)
  a = Array.set(U32, a, 25, 2821834349)
  a = Array.set(U32, a, 26, 2952996808)
  a = Array.set(U32, a, 27, 3210313671)
  a = Array.set(U32, a, 28, 3336571891)
  a = Array.set(U32, a, 29, 3584528711)
  a = Array.set(U32, a, 30, 113926993)
  a = Array.set(U32, a, 31, 338241895)
  a = Array.set(U32, a, 32, 666307205)
  a = Array.set(U32, a, 33, 773529912)
  a = Array.set(U32, a, 34, 1294757372)
  a = Array.set(U32, a, 35, 1396182291)
  a = Array.set(U32, a, 36, 1695183700)
  a = Array.set(U32, a, 37, 1986661051)
  a = Array.set(U32, a, 38, 2177026350)
  a = Array.set(U32, a, 39, 2456956037)
  a = Array.set(U32, a, 40, 2730485921)
  a = Array.set(U32, a, 41, 2820302411)
  a = Array.set(U32, a, 42, 3259730800)
  a = Array.set(U32, a, 43, 3345764771)
  a = Array.set(U32, a, 44, 3516065817)
  a = Array.set(U32, a, 45, 3600352804)
  a = Array.set(U32, a, 46, 4094571909)
  a = Array.set(U32, a, 47, 275423344)
  a = Array.set(U32, a, 48, 430227734)
  a = Array.set(U32, a, 49, 506948616)
  a = Array.set(U32, a, 50, 659060556)
  a = Array.set(U32, a, 51, 883997877)
  a = Array.set(U32, a, 52, 958139571)
  a = Array.set(U32, a, 53, 1322822218)
  a = Array.set(U32, a, 54, 1537002063)
  a = Array.set(U32, a, 55, 1747873779)
  a = Array.set(U32, a, 56, 1955562222)
  a = Array.set(U32, a, 57, 2024104815)
  a = Array.set(U32, a, 58, 2227730452)
  a = Array.set(U32, a, 59, 2361852424)
  a = Array.set(U32, a, 60, 2428436474)
  a = Array.set(U32, a, 61, 2756734187)
  a = Array.set(U32, a, 62, 3204031479)
  Array.set(U32, a, 63, 3329325298)

def expand_w_4(+i: U32, +w15: U32, +w2v: U32, +w16: U32, r: Array<U32> & U32) -> Array<U32>:
  (w4, +w7) = r
  +s0 = U32.xor(U32.xor(rotr(w15, 7n, 25n), rotr(w15, 18n, 14n)), U32.shrn(w15, 3n))
  +s1 = U32.xor(U32.xor(rotr(w2v, 17n, 15n), rotr(w2v, 19n, 13n)), U32.shrn(w2v, 10n))
  +val = U32.add(U32.add(w16, s0), U32.add(w7, s1))
  Array.set(U32, w4, i, val)

def expand_w_3(+i: U32, +w15: U32, +w2v: U32, r: Array<U32> & U32) -> Array<U32>:
  (w3, +w16) = r
  expand_w_4(i, w15, w2v, w16, Array.get(U32, w3, U32.sub(i, 7)))

def expand_w_2(+i: U32, +w15: U32, r: Array<U32> & U32) -> Array<U32>:
  (w2, +w2v) = r
  expand_w_3(i, w15, w2v, Array.get(U32, w2, U32.sub(i, 16)))

def expand_w_1(+i: U32, r: Array<U32> & U32) -> Array<U32>:
  (w1, +w15) = r
  expand_w_2(i, w15, Array.get(U32, w1, U32.sub(i, 2)))

def expand_w(+rem: Nat, +i: U32, w: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      w
    case 1n+p:
      expand_w(p, U32.inc(i), expand_w_1(i, Array.get(U32, w, U32.sub(i, 15))))

def comp_step2(k1: Array<U32>, +ki: U32, +a: U32, +b: U32, +c: U32, +d: U32, +e: U32, +f: U32, +g: U32, +h: U32, rw: Array<U32> & U32) -> CompSt:
  (w1, +wi) = rw
  +s1 = U32.xor(U32.xor(rotr(e, 6n, 26n), rotr(e, 11n, 21n)), rotr(e, 25n, 7n))
  +ch = U32.xor(U32.and(e, f), U32.and(U32.not(e), g))
  +t1 = U32.add(U32.add(U32.add(h, s1), ch), U32.add(ki, wi))
  +s0 = U32.xor(U32.xor(rotr(a, 2n, 30n), rotr(a, 13n, 19n)), rotr(a, 22n, 10n))
  +maj = U32.xor(U32.xor(U32.and(a, b), U32.and(a, c)), U32.and(b, c))
  +t2 = U32.add(s0, maj)
  CS{k1, w1, U32.add(t1, t2), a, b, c, U32.add(d, t1), e, f, g}

def comp_step1(+i: U32, w: Array<U32>, +a: U32, +b: U32, +c: U32, +d: U32, +e: U32, +f: U32, +g: U32, +h: U32, rk: Array<U32> & U32) -> CompSt:
  (k1, +ki) = rk
  comp_step2(k1, ki, a, b, c, d, e, f, g, h, Array.get(U32, w, i))

def compress_loop(+rem: Nat, +i: U32, st: CompSt) -> CompSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      CS{k, w, +a, +b, +c, +d, +e, +f, +g, +h} = st
      compress_loop(p, U32.inc(i), comp_step1(i, w, a, b, c, d, e, f, g, h, Array.get(U32, k, i)))

def finish_sha(cs: CompSt) -> ShaState:
  CS{k1, w1, +a, +b, +c, +d, +e, +f, +g, +h} = cs
  SS{
    k1, w1,
    U32.add(1779033703, a), U32.add(3144134277, b),
    U32.add(1013904242, c), U32.add(2773480762, d),
    U32.add(1359893119, e), U32.add(2600822924, f),
    U32.add(528734635, g), U32.add(1541459225, h)
  }

def sha256_one(st: ShaState) -> ShaState:
  SS{k, w, +m0, +m1, +m2, +m3, +m4, +m5, +m6, +m7} = st
  w = Array.set(U32, w, 0, m0)
  w = Array.set(U32, w, 1, m1)
  w = Array.set(U32, w, 2, m2)
  w = Array.set(U32, w, 3, m3)
  w = Array.set(U32, w, 4, m4)
  w = Array.set(U32, w, 5, m5)
  w = Array.set(U32, w, 6, m6)
  w = Array.set(U32, w, 7, m7)
  w = Array.set(U32, w, 8, 2147483648)
  w = Array.set(U32, w, 9, 0)
  w = Array.set(U32, w, 10, 0)
  w = Array.set(U32, w, 11, 0)
  w = Array.set(U32, w, 12, 0)
  w = Array.set(U32, w, 13, 0)
  w = Array.set(U32, w, 14, 0)
  w = Array.set(U32, w, 15, 256)
  w = expand_w(48n, 16, w)
  finish_sha(compress_loop(64n, 0, CS{
    k, w,
    1779033703, 3144134277, 1013904242, 2773480762,
    1359893119, 2600822924, 528734635, 1541459225
  }))

def run_rounds(+rem: Nat, st: ShaState) -> ShaState:
  match rem:
    case 0n:
      st
    case 1n+p:
      run_rounds(p, sha256_one(st))

def fold_be32(+acc: U32, +w: U32) -> U32:
  +b0 = U32.and(U32.shrn(w, 24n), 255)
  +b1 = U32.and(U32.shrn(w, 16n), 255)
  +b2 = U32.and(U32.shrn(w, 8n), 255)
  +b3 = U32.and(w, 255)
  +a1 = U32.mul(U32.xor(acc, b0), 16777619)
  +a2 = U32.mul(U32.xor(a1, b1), 16777619)
  +a3 = U32.mul(U32.xor(a2, b2), 16777619)
  U32.mul(U32.xor(a3, b3), 16777619)

def mk_word(+i: U32) -> U32:
  +b0 = U32.and(U32.add(U32.mul(i, 7), 3), 255)
  +b1 = U32.and(U32.add(U32.mul(U32.add(i, 1), 7), 3), 255)
  +b2 = U32.and(U32.add(U32.mul(U32.add(i, 2), 7), 3), 255)
  +b3 = U32.and(U32.add(U32.mul(U32.add(i, 3), 7), 3), 255)
  U32.or(U32.or(U32.shln(b0, 24n), U32.shln(b1, 16n)), U32.or(U32.shln(b2, 8n), b3))

def fold_final(st: ShaState) -> U32:
  SS{k1, w1, +h0, +h1, +h2, +h3, +h4, +h5, +h6, +h7} = st
  +a0 = fold_be32(2166136261, h0)
  +a1 = fold_be32(a0, h1)
  +a2 = fold_be32(a1, h2)
  +a3 = fold_be32(a2, h3)
  +a4 = fold_be32(a3, h4)
  +a5 = fold_be32(a4, h5)
  +a6 = fold_be32(a5, h6)
  fold_be32(a6, h7)

def main() -> U32:
  k = set_k(Array.new(U32, 6n, 0))
  w = Array.new(U32, 6n, 0)
  fold_final(run_rounds(24000n, SS{k, w, mk_word(0), mk_word(4), mk_word(8), mk_word(12), mk_word(16), mk_word(20), mk_word(24), mk_word(28)}))
