import Base
# t4_utf8_state_machine (std): Table-driven UTF-8 DFA validator & codepoint accumulator
# Sealed-Test family 4: N = 32768 mixed UTF-8 bytes, 380 rounds.

type UtfRes is Type:
  URes{buf: Array<U32>, st: U32, cp: U32, h: U32, valid: U32, errs: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def gen_lead(+r: U32, m: Nat) -> U32:
  match m:
    case 0n:
      U32.and(r, 127)
    case 1n:
      U32.and(r, 127)
    case 2n:
      U32.and(r, 127)
    case 3n:
      U32.and(r, 127)
    case 4n:
      U32.and(r, 127)
    case 5n:
      U32.and(r, 127)
    case 6n:
      U32.or(200, U32.and(r, 23))
    case 7n:
      U32.or(200, U32.and(r, 23))
    case 8n:
      U32.or(200, U32.and(r, 23))
    case 9n:
      U32.or(200, U32.and(r, 23))
    case 10n:
      U32.or(224, U32.and(r, 15))
    case 11n:
      U32.or(224, U32.and(r, 15))
    case 12n:
      U32.or(224, U32.and(r, 15))
    case 13n:
      U32.or(224, U32.and(r, 15))
    case 14n+p:
      U32.or(240, U32.and(r, 7))

def gen_byte_sel(is0: Bool, +r: U32) -> U32:
  match is0:
    case True{}:
      gen_lead(r, U32.to_nat(U32.and(r, 15)))
    case False{}:
      U32.or(128, U32.and(r, 63))

def gen_byte(+i: U32) -> U32:
  +r = prng(U32.add(U32.mul(U32.inc(i), 2654435761), 61))
  gen_byte_sel(U32.is_zero(U32.and(i, 3)), r)

def fill_bytes(+n: Nat, +i: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      fill_bytes(p, U32.inc(i), Array.swap(U32, a, i, gen_byte(i)))

def cls_lut(idx: Nat) -> U32:
  match idx:
    case 0n:
      0
    case 1n:
      0
    case 2n:
      0
    case 3n:
      0
    case 4n:
      0
    case 5n:
      0
    case 6n:
      0
    case 7n:
      0
    case 8n:
      0
    case 9n:
      0
    case 10n:
      0
    case 11n:
      0
    case 12n:
      0
    case 13n:
      0
    case 14n:
      0
    case 15n:
      0
    case 16n:
      1
    case 17n:
      1
    case 18n:
      1
    case 19n:
      1
    case 20n:
      2
    case 21n:
      2
    case 22n:
      2
    case 23n:
      2
    case 24n:
      6
    case 25n:
      3
    case 26n:
      3
    case 27n:
      3
    case 28n:
      4
    case 29n:
      4
    case 30n:
      5
    case 31n+p:
      6

def trans_lut(idx: Nat) -> U32:
  match idx:
    case 0n:
      0
    case 1n:
      4
    case 2n:
      4
    case 3n:
      1
    case 4n:
      2
    case 5n:
      3
    case 6n:
      4
    case 7n:
      4
    case 8n:
      4
    case 9n:
      0
    case 10n:
      0
    case 11n:
      4
    case 12n:
      4
    case 13n:
      4
    case 14n:
      4
    case 15n:
      4
    case 16n:
      4
    case 17n:
      1
    case 18n:
      1
    case 19n:
      4
    case 20n:
      4
    case 21n:
      4
    case 22n:
      4
    case 23n:
      4
    case 24n:
      4
    case 25n:
      2
    case 26n:
      2
    case 27n:
      4
    case 28n:
      4
    case 29n:
      4
    case 30n:
      4
    case 31n+p:
      4

def next_cp(is_start: Bool, +cp: U32, +b: U32) -> U32:
  match is_start:
    case True{}:
      U32.and(b, 127)
    case False{}:
      U32.or(U32.shln(cp, 6n), U32.and(b, 63))

def dfa_update(is0: Bool, is4: Bool, +nst: U32, +ncp: U32, +h: U32, +valid: U32, +errs: U32, buf: Array<U32>) -> UtfRes:
  match is0:
    case True{}:
      URes{buf, 0, 0, U32.mul(U32.xor(h, ncp), 16777619), U32.inc(valid), errs}
    case False{}:
      match is4:
        case True{}:
          URes{buf, 0, 0, h, valid, U32.inc(errs)}
        case False{}:
          URes{buf, nst, ncp, h, valid, errs}

def dfa_step(+st: U32, +cp: U32, +h: U32, +valid: U32, +errs: U32, r: Array<U32> & U32) -> UtfRes:
  (buf, +b) = r
  +cls = cls_lut(U32.to_nat(U32.and(U32.shrn(b, 3n), 31)))
  +nst = trans_lut(U32.to_nat(U32.or(U32.shln(st, 3n), cls)))
  +ncp = next_cp(U32.is_zero(st), cp, b)
  dfa_update(U32.is_zero(nst), U32.is_eq(nst, 4), nst, ncp, h, valid, errs, buf)

def scan_utf8(+rem: Nat, +i: U32, res: UtfRes) -> UtfRes:
  match rem:
    case 0n:
      res
    case 1n+p:
      URes{buf, +st, +cp, +h, +valid, +errs} = res
      scan_utf8(p, U32.inc(i), dfa_step(st, cp, h, valid, errs, Array.get(U32, buf, i)))

def run_rounds(+rem: Nat, res: UtfRes) -> U32:
  match rem:
    case 0n:
      URes{buf, +st, +cp, +h, +valid, +errs} = res
      U32.add(U32.xor(h, valid), U32.mul(errs, 2654435761))
    case 1n+p:
      URes{buf, +st, +cp, +h, +valid, +errs} = res
      run_rounds(p, scan_utf8(32768n, 0, URes{buf, 0, 0, h, valid, errs}))

def main() -> U32:
  buf = fill_bytes(32768n, 0, (Array.new(U32, 15n, 0), 0))
  run_rounds(125n, URes{buf, 0, 0, 2166136261, 0, 0})
