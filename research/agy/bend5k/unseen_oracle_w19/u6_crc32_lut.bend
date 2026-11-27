import Base
# u6_crc32_lut: Table-driven nibble CRC32 scanner over Array<U32>
# Unseen benchmark testing .rodata LUT lowering, scalar bit-ops, and shift/xor loops.
# Buffer: 65536 bytes in Array<U32>, ROUNDS = 300 passes (~19.6M bytes, 39.3M LUT lookups).

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def fill_bytes(+n: Nat, +i: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +b = U32.and(prng(U32.add(U32.mul(U32.inc(i), 2654435761), 42)), 255)
      fill_bytes(p, U32.inc(i), Array.swap(U32, a, i, b))

def crc_nib(i: Nat) -> U32:
  match i:
    case 0n:
      0
    case 1n:
      498536548
    case 2n:
      997073096
    case 3n:
      651767980
    case 4n:
      1994146192
    case 5n:
      1802195444
    case 6n:
      1303535960
    case 7n:
      1342533948
    case 8n:
      3988292384
    case 9n:
      4027552580
    case 10n:
      3604390888
    case 11n:
      3412177804
    case 12n:
      2607071920
    case 13n:
      2261957332
    case 14n:
      2685067896
    case 15n+p:
      3183342108

def crc_step(+crc: U32, +byte: U32) -> U32:
  +c0 = U32.xor(crc, byte)
  +c1 = U32.xor(U32.shrn(c0, 4n), crc_nib(U32.to_nat(U32.and(c0, 15))))
  U32.xor(U32.shrn(c1, 4n), crc_nib(U32.to_nat(U32.and(c1, 15))))

def crc_scan(+n: Nat, +i: U32, +crc: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  match n:
    case 0n:
      (buf, byte) = r
      (buf, crc)
    case 1n+p:
      (buf, +byte) = r
      crc_scan(p, U32.inc(i), crc_step(crc, byte), Array.get(U32, buf, U32.inc(i)))

def run_rounds(+rounds: Nat, r: Array<U32> & U32) -> U32:
  match rounds:
    case 0n:
      (buf, +crc) = r
      U32.xor(crc, 4294967295)
    case 1n+p:
      (buf, +crc) = r
      run_rounds(p, crc_scan(65536n, 0, crc, Array.get(U32, buf, 0)))

def main() -> U32:
  buf = fill_bytes(65536n, 0, (Array.new(U32, 16n, 0), 0))
  run_rounds(200n, (buf, 4294967295))
