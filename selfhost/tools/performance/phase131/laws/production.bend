import Base

# These exact safe bodies are embedded in the production usage-summary candidate.
# Inputs to add/low/high are saturated counts 0,1,2; modes are0seq/1branch/2pattern.
# No proof about arbitrary wrapping U32 additions is implied by that interface.
def p131a_add(a: U32, b: U32) -> U32:
  U32.min(2,U32.add(a,b))

def p131a_low(mode: U32, a: U32, b: U32) -> U32:
  match mode:
    case 0: p131a_add(a,b)
    case 1: U32.min(a,b)
    case other: 0

def p131a_high(mode: U32, a: U32, b: U32) -> U32:
  match mode:
    case 0: p131a_add(a,b)
    case other: U32.max(a,b)
