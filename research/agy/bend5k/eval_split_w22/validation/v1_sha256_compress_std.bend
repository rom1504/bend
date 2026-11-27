import Base
# v1_sha256_compress (std): FIPS 180-4 SHA-256 64-round compression + message schedule
# Validation family 1: 24,000 blocks x 64 rounds (ARX rotates, Ch/Maj, W[0..63] schedule).

type ShaState is Data:
  S8{a: U32, b: U32, c: U32, d: U32, e: U32, f: U32, g: U32, h: U32}

type ShaRun is Type:
  SR{st: ShaState, w: Array<U32>, k: Array<U32>}

def rotr7(+x: U32) -> U32:
  U32.or(U32.shrn(x, 7n), U32.shln(x, 25n))

def rotr18(+x: U32) -> U32:
  U32.or(U32.shrn(x, 18n), U32.shln(x, 14n))

def rotr17(+x: U32) -> U32:
  U32.or(U32.shrn(x, 17n), U32.shln(x, 15n))

def rotr19(+x: U32) -> U32:
  U32.or(U32.shrn(x, 19n), U32.shln(x, 13n))

def rotr2(+x: U32) -> U32:
  U32.or(U32.shrn(x, 2n), U32.shln(x, 30n))

def rotr13(+x: U32) -> U32:
  U32.or(U32.shrn(x, 13n), U32.shln(x, 19n))

def rotr22(+x: U32) -> U32:
  U32.or(U32.shrn(x, 22n), U32.shln(x, 10n))

def rotr6(+x: U32) -> U32:
  U32.or(U32.shrn(x, 6n), U32.shln(x, 26n))

def rotr11(+x: U32) -> U32:
  U32.or(U32.shrn(x, 11n), U32.shln(x, 21n))

def rotr25(+x: U32) -> U32:
  U32.or(U32.shrn(x, 25n), U32.shln(x, 7n))

def sig0(+x: U32) -> U32:
  U32.xor(U32.xor(rotr7(x), rotr18(x)), U32.shrn(x, 3n))

def sig1(+x: U32) -> U32:
  U32.xor(U32.xor(rotr17(x), rotr19(x)), U32.shrn(x, 10n))

def big_s0(+x: U32) -> U32:
  U32.xor(U32.xor(rotr2(x), rotr13(x)), rotr22(x))

def big_s1(+x: U32) -> U32:
  U32.xor(U32.xor(rotr6(x), rotr11(x)), rotr25(x))

def init_k_0(k: Array<U32>) -> Array<U32>:
  k0 = Array.set(U32, k, 0, 1116352408)
  k1 = Array.set(U32, k0, 1, 1899447441)
  k2 = Array.set(U32, k1, 2, 3049323471)
  k3 = Array.set(U32, k2, 3, 3921009573)
  k4 = Array.set(U32, k3, 4, 961987163)
  k5 = Array.set(U32, k4, 5, 1508970993)
  k6 = Array.set(U32, k5, 6, 2453635748)
  k7 = Array.set(U32, k6, 7, 2870763221)
  k8 = Array.set(U32, k7, 8, 3624381080)
  k9 = Array.set(U32, k8, 9, 310598401)
  k10 = Array.set(U32, k9, 10, 607225278)
  k11 = Array.set(U32, k10, 11, 1426881987)
  k12 = Array.set(U32, k11, 12, 1925078388)
  k13 = Array.set(U32, k12, 13, 2162078206)
  k14 = Array.set(U32, k13, 14, 2614888103)
  Array.set(U32, k14, 15, 3248222580)

def init_k_1(k: Array<U32>) -> Array<U32>:
  k0 = Array.set(U32, k, 16, 3835390401)
  k1 = Array.set(U32, k0, 17, 4022224774)
  k2 = Array.set(U32, k1, 18, 264347078)
  k3 = Array.set(U32, k2, 19, 604807628)
  k4 = Array.set(U32, k3, 20, 770255983)
  k5 = Array.set(U32, k4, 21, 1249150122)
  k6 = Array.set(U32, k5, 22, 1555081692)
  k7 = Array.set(U32, k6, 23, 1996064986)
  k8 = Array.set(U32, k7, 24, 2554220882)
  k9 = Array.set(U32, k8, 25, 2821834349)
  k10 = Array.set(U32, k9, 26, 2952996808)
  k11 = Array.set(U32, k10, 27, 3210313671)
  k12 = Array.set(U32, k11, 28, 3336571891)
  k13 = Array.set(U32, k12, 29, 3584528711)
  k14 = Array.set(U32, k13, 30, 113926993)
  Array.set(U32, k14, 31, 338241895)

def init_k_2(k: Array<U32>) -> Array<U32>:
  k0 = Array.set(U32, k, 32, 666307205)
  k1 = Array.set(U32, k0, 33, 773529912)
  k2 = Array.set(U32, k1, 34, 1294757372)
  k3 = Array.set(U32, k2, 35, 1396182291)
  k4 = Array.set(U32, k3, 36, 1695183700)
  k5 = Array.set(U32, k4, 37, 1986661051)
  k6 = Array.set(U32, k5, 38, 2177026350)
  k7 = Array.set(U32, k6, 39, 2456956037)
  k8 = Array.set(U32, k7, 40, 2730485921)
  k9 = Array.set(U32, k8, 41, 2820302411)
  k10 = Array.set(U32, k9, 42, 3259730800)
  k11 = Array.set(U32, k10, 43, 3345764771)
  k12 = Array.set(U32, k11, 44, 3516065817)
  k13 = Array.set(U32, k12, 45, 3600352804)
  k14 = Array.set(U32, k13, 46, 4094571909)
  Array.set(U32, k14, 47, 275423344)

def init_k_3(k: Array<U32>) -> Array<U32>:
  k0 = Array.set(U32, k, 48, 430227734)
  k1 = Array.set(U32, k0, 49, 506948616)
  k2 = Array.set(U32, k1, 50, 659060556)
  k3 = Array.set(U32, k2, 51, 883997877)
  k4 = Array.set(U32, k3, 52, 958139571)
  k5 = Array.set(U32, k4, 53, 1322822218)
  k6 = Array.set(U32, k5, 54, 1537002063)
  k7 = Array.set(U32, k6, 55, 1747873779)
  k8 = Array.set(U32, k7, 56, 1955562222)
  k9 = Array.set(U32, k8, 57, 2024104815)
  k10 = Array.set(U32, k9, 58, 2227730452)
  k11 = Array.set(U32, k10, 59, 2361852424)
  k12 = Array.set(U32, k11, 60, 2428436474)
  k13 = Array.set(U32, k12, 61, 2756734187)
  k14 = Array.set(U32, k13, 62, 3204031479)
  Array.set(U32, k14, 63, 3329325298)

def fill_w16(+rem: Nat, +i: U32, +mix: U32, +h4: U32, w: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      w
    case 1n+p:
      +nmix = U32.add(U32.add(U32.mul(mix, 1664525), 1013904223), i)
      fill_w16(p, U32.inc(i), nmix, h4, Array.set(U32, w, i, U32.xor(nmix, h4)))

def exp_step3(+i: U32, +v16: U32, +v15: U32, +v7: U32, r: Array<U32> & U32) -> Array<U32>:
  (w, +v2) = r
  +val = U32.add(U32.add(v16, sig0(v15)), U32.add(v7, sig1(v2)))
  Array.set(U32, w, i, val)

def exp_step2(+i: U32, +v16: U32, +v15: U32, r: Array<U32> & U32) -> Array<U32>:
  (w, +v7) = r
  exp_step3(i, v16, v15, v7, Array.get(U32, w, U32.sub(i, 2)))

def exp_step1(+i: U32, +v16: U32, r: Array<U32> & U32) -> Array<U32>:
  (w, +v15) = r
  exp_step2(i, v16, v15, Array.get(U32, w, U32.sub(i, 7)))

def exp_step0(+i: U32, r: Array<U32> & U32) -> Array<U32>:
  (w, +v16) = r
  exp_step1(i, v16, Array.get(U32, w, U32.sub(i, 15)))

def expand_w(+rem: Nat, +i: U32, w: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      w
    case 1n+p:
      expand_w(p, U32.inc(i), exp_step0(i, Array.get(U32, w, U32.sub(i, 16))))

def round_finish(st: ShaState, +ki: U32, rw: Array<U32> & U32, k: Array<U32>) -> ShaRun:
  S8{+a, +b, +c, +d, +e, +f, +g, +h} = st
  (w, +wi) = rw
  +ch = U32.xor(U32.and(e, f), U32.and(U32.not(e), g))
  +t1 = U32.add(U32.add(U32.add(h, big_s1(e)), U32.add(ch, ki)), wi)
  +maj = U32.xor(U32.xor(U32.and(a, b), U32.and(a, c)), U32.and(b, c))
  +t2 = U32.add(big_s0(a), maj)
  SR{S8{U32.add(t1, t2), a, b, c, U32.add(d, t1), e, f, g}, w, k}

def round_getk(+i: U32, st: ShaState, w: Array<U32>, rk: Array<U32> & U32) -> ShaRun:
  (k, +ki) = rk
  round_finish(st, ki, Array.get(U32, w, i), k)

def run_rounds(+rem: Nat, +i: U32, sr: ShaRun) -> ShaRun:
  match rem:
    case 0n:
      sr
    case 1n+p:
      SR{st, w, k} = sr
      run_rounds(p, U32.inc(i), round_getk(i, st, w, Array.get(U32, k, i)))

def add_state(orig: ShaState, fin: ShaState) -> ShaState:
  S8{+h0, +h1, +h2, +h3, +h4, +h5, +h6, +h7} = orig
  S8{+a, +b, +c, +d, +e, +f, +g, +h} = fin
  S8{
    U32.add(h0, a), U32.add(h1, b), U32.add(h2, c), U32.add(h3, d),
    U32.add(h4, e), U32.add(h5, f), U32.add(h6, g), U32.add(h7, h)
  }

def finish_block(+orig: ShaState, sr: ShaRun) -> ShaRun:
  SR{fin, w, k} = sr
  SR{add_state(orig, fin), w, k}

def run_blocks(+rem: Nat, +blk: U32, +salt: U32, sr: ShaRun) -> U32:
  match rem:
    case 0n:
      SR{S8{+h0, +h1, +h2, +h3, +h4, +h5, +h6, +h7}, w, k} = sr
      +c0 = U32.xor(U32.mul(2166136261, 16777619), h0)
      +c1 = U32.xor(U32.mul(c0, 16777619), h1)
      +c2 = U32.xor(U32.mul(c1, 16777619), h2)
      +c3 = U32.xor(U32.mul(c2, 16777619), h3)
      +c4 = U32.xor(U32.mul(c3, 16777619), h4)
      +c5 = U32.xor(U32.mul(c4, 16777619), h5)
      +c6 = U32.xor(U32.mul(c5, 16777619), h6)
      U32.xor(U32.mul(c6, 16777619), h7)
    case 1n+p:
      SR{+st, w, k} = sr
      S8{+h0, +h1, +h2, +h3, +h4, +h5, +h6, +h7} = st
      +mix = U32.xor(U32.xor(U32.mul(blk, 2654435761), h0), salt)
      w1 = fill_w16(16n, 0, mix, h4, w)
      w2 = expand_w(48n, 16, w1)
      sr1 = run_rounds(64n, 0, SR{st, w2, k})
      run_blocks(p, U32.inc(blk), salt, finish_block(st, sr1))

def main() -> U32:
  k0 = Array.new(U32, 6n, 0)
  k1 = init_k_3(init_k_2(init_k_1(init_k_0(k0))))
  w0 = Array.new(U32, 6n, 0)
  run_blocks(24000n, 0, 1367130551, SR{S8{1779033703, 3144134277, 1013904242, 2773480762, 1359893119, 2600822924, 528734635, 1541459225}, w0, k1})
