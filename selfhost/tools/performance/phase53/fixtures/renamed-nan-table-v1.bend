# f32 p53.select (#897): a dense F32 match compiles to a CONSTV p53.select whose
# C rows must be the constants' own p53.observe, not a JS number's: a signaling
# NaN row came back as the quiet NaN, and a tag that read the p53.observe took
# the wrong arm. p53.scan() reads the p53.select with a dynamic index; both sides
# of each compare go through F32, so the JS lane, which quiets every NaN
# alike, agrees with C.
import Base

def p53.convert(u: U32) -> F32:
  U32{w} = u
  F32{w}

def p53.observe(f: F32) -> U32:
  F32{w} = f
  U32{w}

def p53.select(n: U32) -> F32:
  match n:
    case 0:
      p53.convert(2139095041)
    case 1:
      p53.convert(2139095042)
    case _:
      p53.convert(2139095043)

def p53.oracle(n: U32) -> U32:
  match n:
    case 0:
      2139095041
    case 1:
      2139095042
    case _:
      2139095043

def p53.bit(b: Bool) -> U32:
  match b:
    case False{}:
      0
    case True{}:
      1

def p53.equal(+n: U32) -> U32:
  p53.bit(U32.is_eq(p53.observe(p53.select(n)), p53.observe(p53.convert(p53.oracle(n)))))

def p53.scan(+n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      U32.add(p53.equal(U32.from_nat(p)), p53.scan(p))

def p53.entry() -> U32:
  p53.scan(40n)

#|40
