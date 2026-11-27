import Base
# u5_matvec_f32: Dense F32 matrix-vector multiply / dot-product reduction
# Unseen benchmark testing inner-loop FP reduction, unrolling, and dual-array hoisting.
# Matrix A: 512x512 (Array<F32> of 2^18), vector x: 512 (Array<F32> of 2^9), ITERS = 60.

type MvRes is Type:
  MVR{mat: Array<F32>, x: Array<F32>, acc: F32}

type MvAll is Type:
  MVA{mat: Array<F32>, x: Array<F32>, y: Array<F32>}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def fl(n: U32, d: U32) -> F32:
  F32.div(U32.to_f32(n), U32.to_f32(d))

def init_arr(+n: Nat, +i: U32, +salt: U32, r: Array<F32> & F32) -> Array<F32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +q = U32.and(prng(U32.xor(U32.mul(U32.inc(i), 2654435761), salt)), 255)
      +v = F32.sub(fl(q, 256), fl(1, 2))
      init_arr(p, U32.inc(i), salt, Array.swap(F32, a, i, v))

def dot_step.s2(+acc: F32, +a_val: F32, mat: Array<F32>, rx: Array<F32> & F32) -> MvRes:
  (x, +x_val) = rx
  MVR{mat, x, F32.add(acc, F32.mul(a_val, x_val))}

def dot_step.s1(+col: U32, +acc: F32, rm: Array<F32> & F32, x: Array<F32>) -> MvRes:
  (mat, +a_val) = rm
  dot_step.s2(acc, a_val, mat, Array.get(F32, x, col))

def dot_row(+n: Nat, +m_idx: U32, +col: U32, mr: MvRes) -> MvRes:
  match n:
    case 0n:
      mr
    case 1n+p:
      MVR{mat, x, +acc} = mr
      dot_row(p, U32.inc(m_idx), U32.inc(col),
              dot_step.s1(col, acc, Array.get(F32, mat, m_idx), x))

def store_row(+row_idx: U32, y: Array<F32>, mr: MvRes) -> MvAll:
  MVR{mat1, x1, +d} = mr
  +nv = F32.add(F32.mul(d, fl(1, 64)), fl(1, 8))
  MVA{mat1, x1, Array.set(F32, y, row_idx, nv)}

def matvec_rows(+rows: Nat, +row_idx: U32, +m_base: U32, mv: MvAll) -> MvAll:
  match rows:
    case 0n:
      mv
    case 1n+p:
      MVA{mat, x, y} = mv
      matvec_rows(p, U32.inc(row_idx), U32.add(m_base, 512),
                  store_row(row_idx, y, dot_row(512n, m_base, 0, MVR{mat, x, U32.to_f32(0)})))

def swap_xy(mv: MvAll) -> MvAll:
  MVA{mat, x, y} = mv
  MVA{mat, y, x}

def run_iters(+iters: Nat, mv: MvAll) -> Array<F32>:
  match iters:
    case 0n:
      MVA{mat, x, y} = mv
      x
    case 1n+p:
      run_iters(p, swap_xy(matvec_rows(512n, 0, 0, mv)))

def checksum(+n: Nat, +i: U32, +h: U32, r: Array<F32> & F32) -> U32:
  match n:
    case 0n:
      (a, v) = r
      h
    case 1n+p:
      (a, +v) = r
      +q = F32.to_u32(F32.mul(F32.add(v, U32.to_f32(16)), U32.to_f32(65536)))
      checksum(p, U32.inc(i), U32.xor(U32.mul(h, 2654435761), q), Array.get(F32, a, U32.inc(i)))

def main() -> U32:
  mat = init_arr(262144n, 0, 11, (Array.new(F32, 18n, U32.to_f32(0)), U32.to_f32(0)))
  x = init_arr(512n, 0, 97, (Array.new(F32, 9n, U32.to_f32(0)), U32.to_f32(0)))
  y = Array.new(F32, 9n, U32.to_f32(0))
  res = run_iters(180n, MVA{mat, x, y})
  checksum(512n, 0, 2166136261, Array.get(F32, res, 0))
