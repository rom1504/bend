import Base

# Functions are affine Type values, so the closures themselves are used once.
# Two genuine partial applications share a dynamically built Data capture.
def p167closure_capture(n: Nat) -> String:
  match n:
    case 0n: ""
    case 1n+rest: SCon{'x',p167closure_capture(rest)}

def p167closure_offset(captured: String, y: U32) -> U32:
  U32.add(U32.from_nat(String.length(captured)),y)

def p167closure_invoke(f: U32 -> U32, x: U32) -> U32:
  f(x)

@unsafe
def p167closure_descend(n: U32) -> U32:
  match n:
    case 0: 7
    case other: U32.add(1,p167closure_descend(U32.sub(other,1)))

def main() -> U32:
  +captured : String = p167closure_capture(11n)
  f : U32 -> U32 = p167closure_offset(captured)
  g : U32 -> U32 = p167closure_offset(captured)
  U32.add(p167closure_invoke(f,5),U32.add(p167closure_invoke(g,6),p167closure_descend(20000)))
#| 20040
