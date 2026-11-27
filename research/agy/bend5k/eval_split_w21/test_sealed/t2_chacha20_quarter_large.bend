import Base
# t2_chacha20_quarter (large): RFC-7539 ChaCha20 20-round ARX stream cipher with chained rekeying
# Sealed-Test family 2: 48,000 blocks x 10 double-rounds with key/nonce feedback.

type Row4 is Data:
  R4{a: U32, b: U32, c: U32, d: U32}

type ChaMat is Data:
  CM{r0: Row4, r1: Row4, r2: Row4, r3: Row4}

def rotl16(+x: U32) -> U32:
  U32.or(U32.shln(x, 16n), U32.shrn(x, 16n))

def rotl12(+x: U32) -> U32:
  U32.or(U32.shln(x, 12n), U32.shrn(x, 20n))

def rotl8(+x: U32) -> U32:
  U32.or(U32.shln(x, 8n), U32.shrn(x, 24n))

def rotl7(+x: U32) -> U32:
  U32.or(U32.shln(x, 7n), U32.shrn(x, 25n))

def qr(+a0: U32, +b0: U32, +c0: U32, +d0: U32) -> Row4:
  +a1 = U32.add(a0, b0)
  +d1 = rotl16(U32.xor(d0, a1))
  +c1 = U32.add(c0, d1)
  +b1 = rotl12(U32.xor(b0, c1))
  +a2 = U32.add(a1, b1)
  +d2 = rotl8(U32.xor(d1, a2))
  +c2 = U32.add(c1, d2)
  +b2 = rotl7(U32.xor(b1, c2))
  R4{a2, b2, c2, d2}

def dr_diags(q0: Row4, q1: Row4, q2: Row4, q3: Row4) -> ChaMat:
  R4{+d0, +d5, +d10, +d15} = q0
  R4{+d1, +d6, +d11, +d12} = q1
  R4{+d2, +d7, +d8, +d13} = q2
  R4{+d3, +d4, +d9, +d14} = q3
  CM{R4{d0, d1, d2, d3}, R4{d4, d5, d6, d7}, R4{d8, d9, d10, d11}, R4{d12, d13, d14, d15}}

def dr_cols(q0: Row4, q1: Row4, q2: Row4, q3: Row4) -> ChaMat:
  R4{+c0, +c4, +c8, +c12} = q0
  R4{+c1, +c5, +c9, +c13} = q1
  R4{+c2, +c6, +c10, +c14} = q2
  R4{+c3, +c7, +c11, +c15} = q3
  dr_diags(qr(c0, c5, c10, c15), qr(c1, c6, c11, c12), qr(c2, c7, c8, c13), qr(c3, c4, c9, c14))

def double_round(m: ChaMat) -> ChaMat:
  CM{R4{+x0, +x1, +x2, +x3}, R4{+x4, +x5, +x6, +x7}, R4{+x8, +x9, +x10, +x11}, R4{+x12, +x13, +x14, +x15}} = m
  dr_cols(qr(x0, x4, x8, x12), qr(x1, x5, x9, x13), qr(x2, x6, x10, x14), qr(x3, x7, x11, x15))

def run_dr(+rem: Nat, m: ChaMat) -> ChaMat:
  match rem:
    case 0n:
      m
    case 1n+p:
      run_dr(p, double_round(m))

type BlockSt is Data:
  BSt{k0: U32, k4: U32, n2: U32, h: U32}

def finish_block(m: ChaMat, +ctr: U32, +k0: U32, +k4: U32, +n2: U32, +h: U32) -> BlockSt:
  CM{R4{+x0, +x1, +x2, +x3}, R4{+x4, +x5, +x6, +x7}, R4{+x8, +x9, +x10, +x11}, R4{+x12, +x13, +x14, +x15}} = m
  +w0 = U32.add(x0, 1634760805)
  +w1 = U32.add(x1, 857760878)
  +w2 = U32.add(x2, 2036477234)
  +w3 = U32.add(x3, 1797285236)
  +w4 = U32.add(x4, k0)
  +w5 = U32.add(x5, 117835012)
  +w6 = U32.add(x6, 185207048)
  +w7 = U32.add(x7, 252579084)
  +w8 = U32.add(x8, k4)
  +w9 = U32.add(x9, 387323156)
  +w10 = U32.add(x10, 454695192)
  +w11 = U32.add(x11, 522067228)
  +w12 = U32.add(x12, ctr)
  +w13 = U32.add(x13, 150994944)
  +w14 = U32.add(x14, 1241513984)
  +w15 = U32.add(x15, n2)
  +f0 = U32.xor(U32.xor(w0, w1), U32.xor(w2, w3))
  +f1 = U32.xor(U32.xor(w4, w5), U32.xor(w6, w7))
  +f2 = U32.xor(U32.xor(w8, w9), U32.xor(w10, w11))
  +f3 = U32.xor(U32.xor(w12, w13), U32.xor(w14, w15))
  +fold = U32.add(U32.add(f0, f1), U32.add(f2, f3))
  BSt{U32.xor(k0, w0), U32.xor(k4, w8), U32.xor(n2, w15), U32.xor(U32.mul(h, 16777619), fold)}

def mk_r4(a: U32, b: U32, c: U32, d: U32) -> Row4:
  R4{a, b, c, d}

def run_blocks(+rem: Nat, +ctr: U32, bs: BlockSt) -> U32:
  match rem:
    case 0n:
      BSt{+k0, +k4, +n2, +h} = bs
      h
    case 1n+p:
      BSt{+k0, +k4, +n2, +h} = bs
      +o0 = mk_r4(1634760805, 857760878, 2036477234, 1797285236)
      +o1 = mk_r4(k0, 117835012, 185207048, 252579084)
      +o2 = mk_r4(k4, 387323156, 454695192, 522067228)
      +o3 = mk_r4(ctr, 150994944, 1241513984, n2)
      run_blocks(p, U32.inc(ctr), finish_block(run_dr(10n, CM{o0, o1, o2, o3}), ctr, k0, k4, n2, h))

def main() -> U32:
  run_blocks(96000n, 0, BSt{50462976, 319951120, 0, 2166136261})
