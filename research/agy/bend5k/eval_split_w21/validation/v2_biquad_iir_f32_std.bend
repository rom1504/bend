import Base
# v2_biquad_iir_f32 (std): Cascaded 2nd-order Biquad IIR filter bank in F32 (DF-II Transposed)
# Validation family 2: N = 4096 samples, S = 4 cascaded sections, 220 blocks.

type SecOut is Type:
  SOut{sig: Array<F32>, z1: F32, z2: F32}

type BankSt is Type:
  BSt{sig: Array<F32>, st1: Array<F32>, st2: Array<F32>}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def fl(n: U32, d: U32) -> F32:
  F32.div(U32.to_f32(n), U32.to_f32(d))

def init_sig(+n: Nat, +i: U32, r: Array<F32> & F32) -> Array<F32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +q = U32.and(prng(U32.xor(U32.mul(U32.inc(i), 2654435761), 29)), 255)
      +v = F32.sub(fl(q, 256), fl(1, 2))
      init_sig(p, U32.inc(i), Array.swap(F32, a, i, v))

def biquad_sample(
  +i: U32, +b0: F32, +b1: F32, +b2: F32, +a1: F32, +a2: F32, +add_d: F32,
  +z1: F32, +z2: F32, rs: Array<F32> & F32
) -> SecOut:
  (sig, +sv) = rs
  +x = F32.add(sv, add_d)
  +y = F32.add(F32.mul(b0, x), z1)
  +nz1 = F32.add(F32.sub(F32.mul(b1, x), F32.mul(a1, y)), z2)
  +nz2 = F32.sub(F32.mul(b2, x), F32.mul(a2, y))
  SOut{Array.set(F32, sig, i, y), nz1, nz2}

def run_section(
  +rem: Nat, +i: U32, +b0: F32, +b1: F32, +b2: F32, +a1: F32, +a2: F32, +add_d: F32,
  so: SecOut
) -> SecOut:
  match rem:
    case 0n:
      so
    case 1n+p:
      SOut{sig, +z1, +z2} = so
      run_section(
        p, U32.inc(i), b0, b1, b2, a1, a2, add_d,
        biquad_sample(i, b0, b1, b2, a1, a2, add_d, z1, z2, Array.get(F32, sig, i))
      )

def sel_drive(is0: Bool, +drive: F32) -> F32:
  match is0:
    case True{}:
      drive
    case False{}:
      U32.to_f32(0)

def store_sec(+s: U32, st1: Array<F32>, st2: Array<F32>, so: SecOut) -> BankSt:
  SOut{sig, +z1, +z2} = so
  BSt{sig, Array.set(F32, st1, s, z1), Array.set(F32, st2, s, z2)}

def load_z2(+nlen: Nat, +s: U32, +drive: F32, +z1: F32, sig: Array<F32>, st1: Array<F32>, r2: Array<F32> & F32) -> BankSt:
  (st2, +z2) = r2
  +b0 = fl(U32.add(8, U32.and(s, 3)), 32)
  +b1 = fl(U32.add(4, U32.and(s, 1)), 32)
  +b2 = fl(2, 32)
  +a1 = F32.sub(fl(U32.and(s, 3), 16), fl(6, 16))
  +a2 = fl(U32.add(4, U32.and(s, 1)), 32)
  +add_d = sel_drive(U32.is_zero(s), drive)
  store_sec(s, st1, st2, run_section(nlen, 0, b0, b1, b2, a1, a2, add_d, SOut{sig, z1, z2}))

def load_z1(+nlen: Nat, +s: U32, +drive: F32, sig: Array<F32>, r1: Array<F32> & F32, st2: Array<F32>) -> BankSt:
  (st1, +z1) = r1
  load_z2(nlen, s, drive, z1, sig, st1, Array.get(F32, st2, s))

def run_sections(+rem: Nat, +s: U32, +nlen: Nat, +drive: F32, bs: BankSt) -> BankSt:
  match rem:
    case 0n:
      bs
    case 1n+p:
      BSt{sig, st1, st2} = bs
      run_sections(p, U32.inc(s), nlen, drive, load_z1(nlen, s, drive, sig, Array.get(F32, st1, s), st2))

def run_blocks(+rem: Nat, +blk: U32, +nlen: Nat, +secs: Nat, bs: BankSt) -> Array<F32>:
  match rem:
    case 0n:
      BSt{sig, st1, st2} = bs
      sig
    case 1n+p:
      +drive = F32.sub(fl(U32.inc(U32.and(blk, 7)), 32), fl(1, 8))
      run_blocks(p, U32.inc(blk), nlen, secs, run_sections(secs, 0, nlen, drive, bs))

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
  sig = init_sig(4096n, 0, (Array.new(F32, 12n, U32.to_f32(0)), U32.to_f32(0)))
  st1 = Array.new(F32, 2n, U32.to_f32(0))
  st2 = Array.new(F32, 2n, U32.to_f32(0))
  res = run_blocks(360n, 0, 4096n, 4n, BSt{sig, st1, st2})
  checksum(4096n, 0, 2166136261, Array.get(F32, res, 0))
