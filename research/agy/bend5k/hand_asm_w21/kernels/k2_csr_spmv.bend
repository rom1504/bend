import Base
# k2_csr_spmv: Compressed Sparse Row (CSR) graph-step / integer SpMV kernel
# Fresh non-suite kernel 2: 4096 rows, 32768 edges, 160 rounds.

type CsrState is Type:
  CSt{row_ptr: Array<U32>, col_idx: Array<U32>, vals: Array<U32>, x: Array<U32>, h: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def fill_row_ptr(+n: Nat, +i: U32, +off: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      # Each row has 4..12 edges, average 8, total <= 32768 (we clamp by mask)
      +deg = U32.add(4, U32.and(prng(U32.add(U32.mul(U32.inc(i), 2654435761), 17)), 7))
      fill_row_ptr(p, U32.inc(i), U32.add(off, deg), Array.swap(U32, a, i, off))

def fill_cols(+n: Nat, +i: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +c = U32.and(prng(U32.add(U32.mul(U32.inc(i), 2246822519), 31)), 4095)
      fill_cols(p, U32.inc(i), Array.swap(U32, a, i, c))

def fill_vals(+n: Nat, +i: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +v = U32.inc(U32.and(prng(U32.add(U32.mul(U32.inc(i), 3266489917), 47)), 255))
      fill_vals(p, U32.inc(i), Array.swap(U32, a, i, v))

def fill_x(+n: Nat, +i: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +v = U32.and(prng(U32.add(U32.mul(U32.inc(i), 668265263), 59)), 65535)
      fill_x(p, U32.inc(i), Array.swap(U32, a, i, v))

type EdgeAcc is Type:
  EAcc{col_idx: Array<U32>, vals: Array<U32>, x: Array<U32>, sum: U32}

def edge_step_x(+w: U32, +sum: U32, col_idx: Array<U32>, vals: Array<U32>, rx: Array<U32> & U32) -> EdgeAcc:
  (x, +xv) = rx
  EAcc{col_idx, vals, x, U32.add(sum, U32.mul(w, xv))}

def edge_step_w(+c: U32, +sum: U32, col_idx: Array<U32>, rv: Array<U32> & U32, x: Array<U32>) -> EdgeAcc:
  (vals, +w) = rv
  edge_step_x(w, sum, col_idx, vals, Array.get(U32, x, c))

def edge_step_c(+e: U32, +sum: U32, rc: Array<U32> & U32, vals: Array<U32>, x: Array<U32>) -> EdgeAcc:
  (col_idx, +c) = rc
  edge_step_w(c, sum, col_idx, Array.get(U32, vals, e), x)

def scan_edges(+rem: Nat, +e: U32, ea: EdgeAcc) -> EdgeAcc:
  match rem:
    case 0n:
      ea
    case 1n+p:
      EAcc{col_idx, vals, x, +sum} = ea
      +ei = U32.and(e, 32767)
      scan_edges(p, U32.inc(e), edge_step_c(ei, sum, Array.get(U32, col_idx, ei), vals, x))

def row_step_fin(row_ptr: Array<U32>, +h: U32, ea: EdgeAcc) -> CsrState:
  EAcc{col2, vals2, x2, +sum} = ea
  +nh = U32.mul(U32.xor(h, sum), 16777619)
  CSt{row_ptr, col2, vals2, x2, nh}

def row_step_end(+start: U32, +h: U32, +salt: U32, rr: Array<U32> & U32, col_idx: Array<U32>, vals: Array<U32>, x: Array<U32>) -> CsrState:
  (row_ptr, +end_idx) = rr
  +cnt = U32.sub(end_idx, start)
  row_step_fin(row_ptr, h, scan_edges(U32.to_nat(cnt), start, EAcc{col_idx, vals, x, salt}))

def row_step_start(+r_idx: U32, +h: U32, +salt: U32, rr: Array<U32> & U32, col_idx: Array<U32>, vals: Array<U32>, x: Array<U32>) -> CsrState:
  (row_ptr, +start) = rr
  row_step_end(start, h, salt, Array.get(U32, row_ptr, U32.inc(r_idx)), col_idx, vals, x)

def scan_rows(+rem: Nat, +r_idx: U32, +salt: U32, st: CsrState) -> CsrState:
  match rem:
    case 0n:
      st
    case 1n+p:
      CSt{row_ptr, col_idx, vals, x, +h} = st
      scan_rows(p, U32.inc(r_idx), salt, row_step_start(r_idx, h, salt, Array.get(U32, row_ptr, r_idx), col_idx, vals, x))

def run_rounds(+rem: Nat, +r: U32, st: CsrState) -> U32:
  match rem:
    case 0n:
      CSt{row_ptr, col_idx, vals, x, +h} = st
      h
    case 1n+p:
      run_rounds(p, U32.inc(r), scan_rows(4095n, 0, U32.mul(r, 2654435761), st))

def main() -> U32:
  row_ptr = fill_row_ptr(4096n, 0, 0, (Array.new(U32, 12n, 0), 0))
  col_idx = fill_cols(32768n, 0, (Array.new(U32, 15n, 0), 0))
  vals = fill_vals(32768n, 0, (Array.new(U32, 15n, 0), 0))
  x = fill_x(4096n, 0, (Array.new(U32, 12n, 0), 0))
  run_rounds(160n, 0, CSt{row_ptr, col_idx, vals, x, 2166136261})
