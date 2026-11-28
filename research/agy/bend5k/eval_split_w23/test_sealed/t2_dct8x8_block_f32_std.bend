import Base
# t2_dct8x8_block_f32 (std): 8x8 2D Separable DCT-II + Quantize + IDCT-II in F32
# Sealed-Test family 2: 260 blocks x (2D DCT-II + freq scaling + 2D IDCT-II).

type DctSt is Type:
  DS{c: Array<F32>, b: Array<F32>, t: Array<F32>, y: Array<F32>, acc: U32}

type Dot2 is Type:
  D2{m1: Array<F32>, m2: Array<F32>, sum: F32}

type Mat3 is Type:
  M3{m1: Array<F32>, m2: Array<F32>, dst: Array<F32>}

type ChkF is Type:
  CF{b: Array<F32>, acc: U32}

def fl(+n: U32, +d: U32) -> F32:
  F32.div(U32.to_f32(n), U32.to_f32(d))

def poly_cos(+x: F32) -> F32:
  +z = U32.to_f32(0)
  +x2 = F32.mul(x, x)
  +t3 = F32.sub(z, fl(1, 720))
  +t2 = F32.add(fl(1, 24), F32.mul(x2, t3))
  +t1 = F32.add(F32.sub(z, fl(1, 2)), F32.mul(x2, t2))
  F32.add(fl(1, 1), F32.mul(x2, t1))

def red_sub(ge: Bool, +x: F32, +two_pi: F32) -> F32:
  match ge:
    case True{}:
      F32.sub(x, two_pi)
    case False{}:
      x

def red_loop(+rem: Nat, +x: F32, +two_pi: F32) -> F32:
  match rem:
    case 0n:
      x
    case 1n+p:
      red_loop(p, red_sub(F32.is_ge(x, two_pi), x, two_pi), two_pi)

def fold_pi(gt: Bool, +x: F32, +two_pi: F32) -> F32:
  match gt:
    case True{}:
      F32.sub(two_pi, x)
    case False{}:
      x

def fold_hpi(gt: Bool, +x: F32, +pi: F32) -> F32:
  match gt:
    case True{}:
      F32.sub(U32.to_f32(0), poly_cos(F32.sub(pi, x)))
    case False{}:
      poly_cos(x)

def cos_approx(+x: F32) -> F32:
  +pi = fl(3141593, 1000000)
  +hpi = fl(1570796, 1000000)
  +two_pi = F32.add(pi, pi)
  +x1 = red_loop(6n, x, two_pi)
  +x2 = fold_pi(F32.is_gt(x1, pi), x1, two_pi)
  fold_hpi(F32.is_gt(x2, hpi), x2, pi)

def sel_alpha(is_z: Bool, +s0: F32, +s1: F32) -> F32:
  match is_z:
    case True{}:
      s0
    case False{}:
      s1

def init_c_col(+rem: Nat, +u: U32, +x: U32, +alpha: F32, +pi: F32, c: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      c
    case 1n+p:
      +num = U32.mul(U32.inc(U32.shln(x, 1n)), u)
      +angle = F32.div(F32.mul(pi, U32.to_f32(num)), U32.to_f32(16))
      +val = F32.mul(alpha, cos_approx(angle))
      init_c_col(p, u, U32.inc(x), alpha, pi, Array.set(F32, c, U32.add(U32.shln(u, 3n), x), val))

def init_c_row(+rem: Nat, +u: U32, +s0: F32, +s1: F32, +pi: F32, c: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      c
    case 1n+p:
      +alpha = sel_alpha(U32.is_zero(u), s0, s1)
      c1 = init_c_col(8n, u, 0, alpha, pi, c)
      init_c_row(p, U32.inc(u), s0, s1, pi, c1)

def fill_blk_col(+rem: Nat, +r: U32, +c: U32, +blk: U32, b: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      b
    case 1n+p:
      +v = U32.and(U32.add(U32.add(U32.mul(r, 19), U32.mul(c, 31)), U32.mul(blk, 7)), 255)
      +fv = F32.sub(U32.to_f32(v), U32.to_f32(128))
      fill_blk_col(p, r, U32.inc(c), blk, Array.set(F32, b, U32.add(U32.shln(r, 3n), c), fv))

def fill_blk(+rem: Nat, +r: U32, +blk: U32, b: Array<F32>) -> Array<F32>:
  match rem:
    case 0n:
      b
    case 1n+p:
      fill_blk(p, U32.inc(r), blk, fill_blk_col(8n, r, 0, blk, b))

def dot_b(+va: F32, +sum: F32, m1: Array<F32>, r2: Array<F32> & F32) -> Dot2:
  (m2, +vb) = r2
  D2{m1, m2, F32.add(sum, F32.mul(va, vb))}

def dot_a(+idx2: U32, +sum: F32, r1: Array<F32> & F32, m2: Array<F32>) -> Dot2:
  (m1, +va) = r1
  dot_b(va, sum, m1, Array.get(F32, m2, idx2))

# mode 0: dst = m1 * m2; mode 1: dst = m1 * m2^T (scaled); mode 2: dst = m1^T * m2
def mm_dot_nn(+rem: Nat, +i: U32, +j: U32, +k: U32, d: Dot2) -> Dot2:
  match rem:
    case 0n:
      d
    case 1n+p:
      D2{m1, m2, +sum} = d
      +idx1 = U32.add(U32.shln(i, 3n), k)
      +idx2 = U32.add(U32.shln(k, 3n), j)
      mm_dot_nn(p, i, j, U32.inc(k), dot_a(idx2, sum, Array.get(F32, m1, idx1), m2))

def mm_nn_store(+idx: U32, dst: Array<F32>, d: Dot2) -> Mat3:
  D2{m1, m2, +sum} = d
  M3{m1, m2, Array.set(F32, dst, idx, sum)}

def mm_nn_j(+rem: Nat, +i: U32, +j: U32, m: Mat3) -> Mat3:
  match rem:
    case 0n:
      m
    case 1n+p:
      M3{m1, m2, dst} = m
      +idx = U32.add(U32.shln(i, 3n), j)
      mm_nn_j(p, i, U32.inc(j), mm_nn_store(idx, dst, mm_dot_nn(8n, i, j, 0, D2{m1, m2, U32.to_f32(0)})))

def mm_nn(+rem: Nat, +i: U32, m: Mat3) -> Mat3:
  match rem:
    case 0n:
      m
    case 1n+p:
      mm_nn(p, U32.inc(i), mm_nn_j(8n, i, 0, m))

def mm_dot_nt(+rem: Nat, +i: U32, +j: U32, +k: U32, d: Dot2) -> Dot2:
  match rem:
    case 0n:
      d
    case 1n+p:
      D2{m1, m2, +sum} = d
      +idx1 = U32.add(U32.shln(i, 3n), k)
      +idx2 = U32.add(U32.shln(j, 3n), k)
      mm_dot_nt(p, i, j, U32.inc(k), dot_a(idx2, sum, Array.get(F32, m1, idx1), m2))

def mm_nt_store(+i: U32, +j: U32, +inv_q: F32, +fq: F32, dst: Array<F32>, d: Dot2) -> Mat3:
  D2{m1, m2, +sum} = d
  +fij = U32.to_f32(U32.inc(U32.add(i, j)))
  +w = F32.div(inv_q, fij)
  +val = F32.mul(F32.mul(sum, w), F32.mul(fq, fij))
  M3{m1, m2, Array.set(F32, dst, U32.add(U32.shln(i, 3n), j), val)}

def mm_nt_j(+rem: Nat, +i: U32, +j: U32, +inv_q: F32, +fq: F32, m: Mat3) -> Mat3:
  match rem:
    case 0n:
      m
    case 1n+p:
      M3{m1, m2, dst} = m
      mm_nt_j(p, i, U32.inc(j), inv_q, fq, mm_nt_store(i, j, inv_q, fq, dst, mm_dot_nt(8n, i, j, 0, D2{m1, m2, U32.to_f32(0)})))

def mm_nt(+rem: Nat, +i: U32, +inv_q: F32, +fq: F32, m: Mat3) -> Mat3:
  match rem:
    case 0n:
      m
    case 1n+p:
      mm_nt(p, U32.inc(i), inv_q, fq, mm_nt_j(8n, i, 0, inv_q, fq, m))

def mm_dot_tn(+rem: Nat, +i: U32, +j: U32, +k: U32, d: Dot2) -> Dot2:
  match rem:
    case 0n:
      d
    case 1n+p:
      D2{m1, m2, +sum} = d
      +idx1 = U32.add(U32.shln(k, 3n), i)
      +idx2 = U32.add(U32.shln(k, 3n), j)
      mm_dot_tn(p, i, j, U32.inc(k), dot_a(idx2, sum, Array.get(F32, m1, idx1), m2))

def mm_tn_j(+rem: Nat, +i: U32, +j: U32, m: Mat3) -> Mat3:
  match rem:
    case 0n:
      m
    case 1n+p:
      M3{m1, m2, dst} = m
      +idx = U32.add(U32.shln(i, 3n), j)
      mm_tn_j(p, i, U32.inc(j), mm_nn_store(idx, dst, mm_dot_tn(8n, i, j, 0, D2{m1, m2, U32.to_f32(0)})))

def mm_tn(+rem: Nat, +i: U32, m: Mat3) -> Mat3:
  match rem:
    case 0n:
      m
    case 1n+p:
      mm_tn(p, U32.inc(i), mm_tn_j(8n, i, 0, m))

def chk_step(+acc: U32, r: Array<F32> & F32) -> ChkF:
  (b, +v) = r
  +q = F32.to_u32(F32.mul(F32.add(v, U32.to_f32(512)), U32.to_f32(256)))
  CF{b, U32.xor(U32.mul(acc, 16777619), q)}

def chk_loop(+rem: Nat, +i: U32, cf: ChkF) -> ChkF:
  match rem:
    case 0n:
      cf
    case 1n+p:
      CF{b, +acc} = cf
      chk_loop(p, U32.inc(i), chk_step(acc, Array.get(F32, b, i)))

def blk_after_chk(c: Array<F32>, t: Array<F32>, y: Array<F32>, cf: ChkF) -> DctSt:
  CF{b2, +acc1} = cf
  DS{c, b2, t, y, acc1}

def blk_after_m4(y: Array<F32>, +acc: U32, m: Mat3) -> DctSt:
  M3{t2, c4, b2} = m
  blk_after_chk(c4, t2, y, chk_loop(64n, 0, CF{b2, acc}))

def blk_after_m3(b1: Array<F32>, +acc: U32, m: Mat3) -> DctSt:
  M3{c3, y2, t2} = m
  blk_after_m4(y2, acc, mm_nn(8n, 0, M3{t2, c3, b1}))

def blk_after_m2(b1: Array<F32>, +acc: U32, m: Mat3) -> DctSt:
  M3{t1, c2, y1} = m
  blk_after_m3(b1, acc, mm_tn(8n, 0, M3{c2, y1, t1}))

def blk_after_m1(y: Array<F32>, +inv_q: F32, +fq: F32, +acc: U32, m: Mat3) -> DctSt:
  M3{c1, b1, t1} = m
  blk_after_m2(b1, acc, mm_nt(8n, 0, inv_q, fq, M3{t1, c1, y}))

def run_blocks(+rem: Nat, +blk: U32, +inv_q: F32, +fq: F32, st: DctSt) -> U32:
  match rem:
    case 0n:
      DS{c, b, t, y, +acc} = st
      acc
    case 1n+p:
      DS{c, b, t, y, +acc} = st
      b0 = fill_blk(8n, 0, blk, b)
      st1 = blk_after_m1(y, inv_q, fq, acc, mm_nn(8n, 0, M3{c, b0, t}))
      run_blocks(p, U32.inc(blk), inv_q, fq, st1)

def main() -> U32:
  +z = U32.to_f32(0)
  c0 = Array.new(F32, 6n, z)
  c1 = init_c_row(8n, 0, fl(353553, 1000000), fl(5, 10), fl(3141593, 1000000), c0)
  b = Array.new(F32, 6n, z)
  t = Array.new(F32, 6n, z)
  y = Array.new(F32, 6n, z)
  run_blocks(2200n, 0, fl(1, 4), U32.to_f32(4), DS{c1, b, t, y, 2166136261})
