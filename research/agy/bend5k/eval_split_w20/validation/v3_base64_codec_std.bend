import Base
# v3_base64_codec (std): Table-driven 64-entry Base64 encoder + FNV-1a checksum over Array<U32>
# Validation family 3: N = 16384 uniform bytes, 5461 3-byte groups, 880 rounds.

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
      +b = U32.and(prng(U32.add(U32.mul(U32.inc(i), 2654435761), 37)), 255)
      fill_bytes(p, U32.inc(i), Array.swap(U32, a, i, b))

def b64_lut(i: Nat) -> U32:
  match i:
    case 0n:
      65
    case 1n:
      66
    case 2n:
      67
    case 3n:
      68
    case 4n:
      69
    case 5n:
      70
    case 6n:
      71
    case 7n:
      72
    case 8n:
      73
    case 9n:
      74
    case 10n:
      75
    case 11n:
      76
    case 12n:
      77
    case 13n:
      78
    case 14n:
      79
    case 15n:
      80
    case 16n:
      81
    case 17n:
      82
    case 18n:
      83
    case 19n:
      84
    case 20n:
      85
    case 21n:
      86
    case 22n:
      87
    case 23n:
      88
    case 24n:
      89
    case 25n:
      90
    case 26n:
      97
    case 27n:
      98
    case 28n:
      99
    case 29n:
      100
    case 30n:
      101
    case 31n:
      102
    case 32n:
      103
    case 33n:
      104
    case 34n:
      105
    case 35n:
      106
    case 36n:
      107
    case 37n:
      108
    case 38n:
      109
    case 39n:
      110
    case 40n:
      111
    case 41n:
      112
    case 42n:
      113
    case 43n:
      114
    case 44n:
      115
    case 45n:
      116
    case 46n:
      117
    case 47n:
      118
    case 48n:
      119
    case 49n:
      120
    case 50n:
      121
    case 51n:
      122
    case 52n:
      48
    case 53n:
      49
    case 54n:
      50
    case 55n:
      51
    case 56n:
      52
    case 57n:
      53
    case 58n:
      54
    case 59n:
      55
    case 60n:
      56
    case 61n:
      57
    case 62n:
      43
    case 63n+p:
      47

def fold_ch(+h: U32, +c: U32) -> U32:
  U32.mul(U32.xor(h, c), 16777619)

def encode_word(+h: U32, +b0: U32, +b1: U32, +b2: U32) -> U32:
  +w = U32.or(U32.or(U32.shln(b0, 16n), U32.shln(b1, 8n)), b2)
  +c0 = b64_lut(U32.to_nat(U32.and(U32.shrn(w, 18n), 63)))
  +c1 = b64_lut(U32.to_nat(U32.and(U32.shrn(w, 12n), 63)))
  +c2 = b64_lut(U32.to_nat(U32.and(U32.shrn(w, 6n), 63)))
  +c3 = b64_lut(U32.to_nat(U32.and(w, 63)))
  fold_ch(fold_ch(fold_ch(fold_ch(h, c0), c1), c2), c3)

def step_b2(+h: U32, +b0: U32, +b1: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (buf, +b2) = r
  (buf, encode_word(h, b0, b1, b2))

def step_b1(+idx: U32, +h: U32, +b0: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (buf, +b1) = r
  step_b2(h, b0, b1, Array.get(U32, buf, U32.add(idx, 2)))

def step_b0(+idx: U32, +salt: U32, +h: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (buf, +raw0) = r
  +b0 = U32.and(U32.xor(raw0, salt), 255)
  step_b1(idx, h, b0, Array.get(U32, buf, U32.inc(idx)))

def scan_groups(+rem: Nat, +idx: U32, +salt: U32, st: Array<U32> & U32) -> Array<U32> & U32:
  match rem:
    case 0n:
      st
    case 1n+p:
      (buf, +h) = st
      scan_groups(p, U32.add(idx, 3), salt, step_b0(idx, salt, h, Array.get(U32, buf, idx)))

def run_rounds(+rem: Nat, +r_idx: U32, r: Array<U32> & U32) -> U32:
  match rem:
    case 0n:
      (buf, +h) = r
      h
    case 1n+p:
      run_rounds(p, U32.inc(r_idx), scan_groups(5461n, 0, U32.and(r_idx, 255), r))

def main() -> U32:
  buf = fill_bytes(16384n, 0, (Array.new(U32, 14n, 0), 0))
  run_rounds(220n, 0, (buf, 2166136261))
