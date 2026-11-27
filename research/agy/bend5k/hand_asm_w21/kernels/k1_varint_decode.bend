import Base
# k1_varint_decode: Variable-length LEB128 varint stream decoder + integer mixer
# Fresh non-suite kernel 1: N = 65536 bytes, 180 rounds.

type VarSt is Type:
  VSt{buf: Array<U32>, acc: U32, shift: U32, h: U32, count: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def make_byte_cont(is_term: Bool, +r: U32) -> U32:
  match is_term:
    case True{}:
      U32.and(r, 127)
    case False{}:
      U32.or(128, U32.and(r, 127))

def make_byte_sel(is_end: Bool, +r: U32) -> U32:
  match is_end:
    case True{}:
      U32.and(r, 127)
    case False{}:
      make_byte_cont(U32.is_zero(U32.and(r, 3)), r)

def make_byte(+i: U32) -> U32:
  +r = prng(U32.add(U32.mul(U32.inc(i), 2654435761), 83))
  make_byte_sel(U32.is_zero(U32.and(i, 3)), r)

def fill_buf(+n: Nat, +i: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      fill_buf(p, U32.inc(i), Array.swap(U32, a, i, make_byte(i)))

def mix32(+h: U32, +v: U32) -> U32:
  +x = U32.mul(U32.xor(h, v), 2246822519)
  +y = U32.or(U32.shln(x, 13n), U32.shrn(x, 19n))
  U32.mul(U32.xor(y, U32.shrn(y, 15n)), 3266489917)

def step_byte_branch(is_done: Bool, +nacc: U32, +shift: U32, +h: U32, +count: U32, buf: Array<U32>) -> VarSt:
  match is_done:
    case True{}:
      VSt{buf, 0, 0, mix32(h, nacc), U32.inc(count)}
    case False{}:
      VSt{buf, nacc, U32.add(shift, 7), h, count}

def step_byte(+acc: U32, +shift: U32, +h: U32, +count: U32, r: Array<U32> & U32) -> VarSt:
  (buf, +b) = r
  +low = U32.and(b, 127)
  +nacc = U32.or(acc, U32.shln(low, U32.to_nat(U32.and(shift, 31))))
  step_byte_branch(U32.is_zero(U32.and(b, 128)), nacc, shift, h, count, buf)

def scan_varint(+rem: Nat, +i: U32, st: VarSt) -> VarSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      VSt{buf, +acc, +shift, +h, +count} = st
      scan_varint(p, U32.inc(i), step_byte(acc, shift, h, count, Array.get(U32, buf, i)))

def run_rounds(+rem: Nat, st: VarSt) -> U32:
  match rem:
    case 0n:
      VSt{buf, +acc, +shift, +h, +count} = st
      U32.xor(h, U32.mul(count, 2654435761))
    case 1n+p:
      VSt{buf, +acc, +shift, +h, +count} = st
      run_rounds(p, scan_varint(65536n, 0, VSt{buf, 0, 0, h, count}))

def main() -> U32:
  buf = fill_buf(65536n, 0, (Array.new(U32, 16n, 0), 0))
  run_rounds(180n, VSt{buf, 0, 0, 2166136261, 0})
